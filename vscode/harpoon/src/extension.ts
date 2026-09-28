import * as os from "os";
import * as path from "path";
import * as vscode from "vscode";

const MARKS_KEY = "harpoon.marks";
const MENU_FILENAME = "harpoon-marks";
const COLUMN_GAP = 3;

export async function activate(context: vscode.ExtensionContext) {
    await vscode.workspace.fs.createDirectory(context.globalStorageUri);
    const menuUri = vscode.Uri.joinPath(context.globalStorageUri, MENU_FILENAME);
    const directoryColor = vscode.window.createTextEditorDecorationType({
        color: new vscode.ThemeColor("descriptionForeground")
    });
    const fileNameColor = vscode.window.createTextEditorDecorationType({
        color: new vscode.ThemeColor("harpoon.fileName")
    });
    const currentFileHighlight = vscode.window.createTextEditorDecorationType({
        isWholeLine: true,
        backgroundColor: new vscode.ThemeColor("editor.selectionHighlightBackground")
    });

    // Rendered line text -> absolute path. Reordering a line keeps its text, so
    // the list survives edits even though the buffer no longer holds real paths.
    let shownPaths = new Map<string, string>();

    // The file that was open before the menu took over as the active editor.
    let lastFile = vscode.window.activeTextEditor?.document.uri.fsPath;

    const getMarks = () => context.workspaceState.get<string[]>(MARKS_KEY, []);
    const setMarks = (marks: string[]) => context.workspaceState.update(MARKS_KEY, marks);
    const isMenu = (document: vscode.TextDocument) => document.uri.fsPath === menuUri.fsPath;

    function displayPath(file: string) {
        const folder = vscode.workspace.getWorkspaceFolder(vscode.Uri.file(file));
        if (!folder) {
            const home = os.homedir();
            return file.startsWith(home) ? `~${file.slice(home.length)}` : file;
        }

        const relative = path.relative(folder.uri.fsPath, file);
        const roots = vscode.workspace.workspaceFolders ?? [];
        return roots.length > 1 ? path.join(folder.name, relative) : relative;
    }

    function render(marks: string[]) {
        const rows = marks.map(file => {
            const shown = displayPath(file);
            const directory = path.dirname(shown);
            return {
                file,
                directory: directory === "." ? "" : directory + path.sep,
                name: path.basename(shown)
            };
        });

        const width = Math.max(0, ...rows.map(row => row.directory.length));
        shownPaths = new Map();

        return rows
            .map(row => {
                const line = row.directory.padEnd(width + COLUMN_GAP) + row.name;
                shownPaths.set(line.trim(), row.file);
                return line;
            })
            .join("\n");
    }

    function resolve(line: string) {
        const trimmed = line.trim();
        const known = shownPaths.get(trimmed);
        if (known) {
            return known;
        }
        return path.isAbsolute(trimmed) ? trimmed : undefined;
    }

    function decorate(editor: vscode.TextEditor | undefined) {
        if (!editor || !isMenu(editor.document)) {
            return;
        }

        const directories: vscode.Range[] = [];
        const names: vscode.Range[] = [];
        const current: vscode.Range[] = [];
        for (let line = 0; line < editor.document.lineCount; line++) {
            const text = editor.document.lineAt(line).text;
            const trimmed = text.trim();
            if (!trimmed) {
                continue;
            }

            const known = shownPaths.get(trimmed);
            const directoryEnd = text.lastIndexOf(path.sep) + 1;
            const nameStart = known ? text.length - path.basename(known).length : directoryEnd;

            if (directoryEnd > 0) {
                directories.push(new vscode.Range(line, 0, line, directoryEnd));
            }
            names.push(new vscode.Range(line, nameStart, line, text.length));

            if (known && known === lastFile) {
                current.push(new vscode.Range(line, 0, line, text.length));
            }
        }

        editor.setDecorations(directoryColor, directories);
        editor.setDecorations(fileNameColor, names);
        editor.setDecorations(currentFileHighlight, current);
    }

    async function mark() {
        const editor = vscode.window.activeTextEditor;
        if (!editor || editor.document.uri.scheme !== "file" || isMenu(editor.document)) {
            return;
        }

        const file = editor.document.uri.fsPath;
        const marks = getMarks();
        if (!marks.includes(file)) {
            await setMarks([...marks, file]);
        }
        vscode.window.setStatusBarMessage(`Harpoon: marked ${path.basename(file)}`, 2000);
    }

    async function menu() {
        const active = vscode.window.activeTextEditor;
        if (active && isMenu(active.document)) {
            await vscode.commands.executeCommand("workbench.action.closeActiveEditor");
            return;
        }

        const contents = Buffer.from(render(getMarks()), "utf8");
        await vscode.workspace.fs.writeFile(menuUri, contents);
        const document = await vscode.workspace.openTextDocument(menuUri);
        decorate(await vscode.window.showTextDocument(document, { preview: false }));
    }

    async function open() {
        const editor = vscode.window.activeTextEditor;
        if (!editor || !isMenu(editor.document)) {
            return;
        }

        const target = resolve(editor.document.lineAt(editor.selection.active.line).text);
        if (!target) {
            return;
        }

        const uri = vscode.Uri.file(target);
        try {
            await vscode.workspace.fs.stat(uri);
        } catch {
            vscode.window.showWarningMessage(`Harpoon: ${target} no longer exists`);
            return;
        }

        await vscode.commands.executeCommand("workbench.action.closeActiveEditor");
        await vscode.window.showTextDocument(uri, { preview: false });
    }

    async function syncFromMenu(document: vscode.TextDocument) {
        const marks = document
            .getText()
            .split(/\r?\n/)
            .map(resolve)
            .filter((file): file is string => file !== undefined);
        await setMarks(marks);

        if (document.isDirty) {
            await document.save();
        }
    }

    context.subscriptions.push(
        directoryColor,
        fileNameColor,
        currentFileHighlight,
        vscode.commands.registerCommand("harpoon.mark", mark),
        vscode.commands.registerCommand("harpoon.menu", menu),
        vscode.commands.registerCommand("harpoon.open", open),
        vscode.window.onDidChangeActiveTextEditor(editor => {
            if (editor && !isMenu(editor.document) && editor.document.uri.scheme === "file") {
                lastFile = editor.document.uri.fsPath;
            }
            decorate(editor);
        }),
        vscode.workspace.onDidChangeTextDocument(async event => {
            if (!isMenu(event.document)) {
                return;
            }
            await syncFromMenu(event.document);
            decorate(vscode.window.activeTextEditor);
        })
    );
}

export function deactivate() {}
