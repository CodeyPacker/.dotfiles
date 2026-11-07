// Popup workspace and tab list for herdr, like tmux's prefix+w.
// j/k or arrows move, Enter switches, 1-9 jumps to a workspace, Esc or q closes.
// r renames, x closes, and n adds a tab to the highlighted row's workspace.
//
// Windows only. Talks to herdr's named pipe directly, because PowerShell and
// the herdr CLI each take hundreds of milliseconds to start.
// Build: go build -C herdr/picker -o herdr-picker.exe .
package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"syscall"
	"unicode/utf8"
	"unsafe"
)

type workspace struct {
	ID      string `json:"workspace_id"`
	Number  int    `json:"number"`
	Label   string `json:"label"`
	Focused bool   `json:"focused"`
}

type tab struct {
	ID          string `json:"tab_id"`
	WorkspaceID string `json:"workspace_id"`
	Number      int    `json:"number"`
	Label       string `json:"label"`
	Focused     bool   `json:"focused"`
}

// One row per workspace, followed by a row per tab in it.
type row struct {
	ws   workspace
	tab  *tab
	text string
}

// id identifies a row across reloads.
func (r row) id() string {
	if r.tab != nil {
		return r.tab.ID
	}
	return r.ws.ID
}

func (r row) label() string {
	if r.tab != nil {
		return r.tab.Label
	}
	return r.ws.Label
}

func pipePath() string {
	path := os.Getenv("HERDR_SOCKET_PATH")
	if path == "" {
		path = filepath.Join(os.Getenv("APPDATA"), "herdr", "herdr.sock")
	}
	return `\\.\pipe\` + path
}

// call sends one request and decodes the result field into out.
func call(method string, params any, out any) error {
	conn, err := os.OpenFile(pipePath(), os.O_RDWR, 0)
	if err != nil {
		return err
	}
	defer conn.Close()

	req, _ := json.Marshal(map[string]any{"id": "picker", "method": method, "params": params})
	if _, err := conn.Write(append(req, '\n')); err != nil {
		return err
	}
	line, err := bufio.NewReader(conn).ReadBytes('\n')
	if err != nil {
		return err
	}
	var resp struct {
		Result json.RawMessage `json:"result"`
		Error  json.RawMessage `json:"error"`
	}
	if err := json.Unmarshal(line, &resp); err != nil {
		return err
	}
	if len(resp.Error) > 0 {
		return fmt.Errorf("%s", resp.Error)
	}
	if out == nil {
		return nil
	}
	return json.Unmarshal(resp.Result, out)
}

// load builds the rows. Without a previous row ID, it starts on the focused
// tab of the focused workspace.
func load(keepID string) ([]row, int, error) {
	var workspaces struct {
		Workspaces []workspace `json:"workspaces"`
	}
	var tabs struct {
		Tabs []tab `json:"tabs"`
	}
	if err := call("workspace.list", map[string]any{}, &workspaces); err != nil {
		return nil, 0, err
	}
	call("tab.list", map[string]any{}, &tabs)

	var rows []row
	index := 0
	for _, ws := range workspaces.Workspaces {
		if ws.ID == keepID {
			index = len(rows)
		}
		rows = append(rows, row{ws: ws, text: fmt.Sprintf("%d  %s", ws.Number, ws.Label)})
		for i := range tabs.Tabs {
			t := &tabs.Tabs[i]
			if t.WorkspaceID != ws.ID {
				continue
			}
			if t.ID == keepID || (keepID == "" && ws.Focused && t.Focused) {
				index = len(rows)
			}
			rows = append(rows, row{ws: ws, tab: t, text: fmt.Sprintf("     %d: %s", t.Number, t.Label)})
		}
	}
	return rows, index, nil
}

func switchTo(r row) {
	call("workspace.focus", map[string]string{"workspace_id": r.ws.ID}, nil)
	if r.tab != nil {
		call("tab.focus", map[string]string{"tab_id": r.tab.ID}, nil)
	}
}

// rawInput turns off line buffering and echo so single keys arrive at once.
func rawInput() func() {
	kernel32 := syscall.NewLazyDLL("kernel32.dll")
	getMode := kernel32.NewProc("GetConsoleMode")
	setMode := kernel32.NewProc("SetConsoleMode")
	handle := syscall.Handle(os.Stdin.Fd())

	var mode uint32
	getMode.Call(uintptr(handle), uintptr(unsafe.Pointer(&mode)))
	const lineInput, echoInput, processedInput, vtInput = 0x2, 0x4, 0x1, 0x200
	setMode.Call(uintptr(handle), uintptr(mode&^(lineInput|echoInput|processedInput)|vtInput))
	return func() { setMode.Call(uintptr(handle), uintptr(mode)) }
}

// PReview palette, matching the Neovim picker and herdr's theme.
const (
	accent    = "\x1b[38;2;181;166;255m" // accent
	ink       = "\x1b[38;2;244;243;249m" // ink
	secondary = "\x1b[38;2;171;168;189m" // ink-secondary
	dim       = "\x1b[38;2;140;137;160m" // ink-tertiary
	selected  = "\x1b[48;2;41;35;74m"    // accent-soft row background
	bold      = "\x1b[1m"
	reset     = "\x1b[0m"
	clearEOL  = "\x1b[K" // fills the rest of the line with the current background
)

var hints = hintLine("enter", "switch", "r", "rename", "n", "new tab", "x", "close", "q", "quit")

// hintLine shows each key in the accent color and its action dimmed.
func hintLine(pairs ...string) string {
	var line strings.Builder
	for i := 0; i < len(pairs); i += 2 {
		line.WriteString(accent + pairs[i] + " " + dim + pairs[i+1] + "   ")
	}
	return line.String() + reset
}

var (
	out = bufio.NewWriter(os.Stdout)
	buf = make([]byte, 64)
)

// draw shows the rows with a bottom line for hints, prompts, or errors.
func draw(rows []row, index int, footer string) {
	var frame strings.Builder
	frame.WriteString("\x1b[?25l\x1b[H\x1b[2J")
	for i, r := range rows {
		style := bold + ink
		if r.tab != nil {
			style = secondary
		}
		if i == index {
			frame.WriteString(selected + accent + " › " + ink + bold + r.text + clearEOL + reset + "\r\n")
		} else {
			frame.WriteString("   " + style + r.text + reset + "\r\n")
		}
	}
	frame.WriteString("\r\n" + footer)
	out.WriteString(frame.String())
	out.Flush()
}

func readKey() (string, bool) {
	n, err := os.Stdin.Read(buf)
	if err != nil {
		return "", false
	}
	return string(buf[:n]), true
}

// prompt reads a line of text in the footer. ok is false if Esc cancels it.
func prompt(rows []row, index int, label, text string) (string, bool) {
	for {
		draw(rows, index, accent+label+reset+text+"\x1b[?25h")
		key, ok := readKey()
		if !ok {
			return "", false
		}
		switch {
		case key == "\r" || key == "\n":
			return strings.TrimSpace(text), true
		case key == "\x1b" || key == "\x03":
			return "", false
		case key == "\x7f" || key == "\b":
			if text != "" {
				_, size := utf8.DecodeLastRuneInString(text)
				text = text[:len(text)-size]
			}
		case key[0] >= ' ' && key[0] != 0x7f:
			// Typed or pasted text. Drop any control characters in a paste.
			text += strings.Map(func(r rune) rune {
				if r < ' ' {
					return -1
				}
				return r
			}, key)
		}
	}
}

func confirm(rows []row, index int, question string) bool {
	draw(rows, index, accent+question+" y/n"+reset)
	key, ok := readKey()
	return ok && (key == "y" || key == "Y")
}

func main() {
	rows, index, err := load("")
	if err != nil {
		fmt.Println("herdr:", err)
		return
	}
	if len(rows) == 0 {
		return
	}

	restore := rawInput()
	defer restore()

	footer := hints
	for {
		draw(rows, index, footer)
		footer = hints

		key, ok := readKey()
		if !ok {
			return
		}
		// Arrow keys arrive as one escape sequence. Anything else is one key.
		if len(key) > 1 && key[0] != 0x1b {
			key = key[:1]
		}

		current := rows[index]
		keepID := current.id()
		var actionErr error
		switch {
		case key == "j" || key == "\x1b[B":
			index = (index + 1) % len(rows)
			continue
		case key == "k" || key == "\x1b[A":
			index = (index - 1 + len(rows)) % len(rows)
			continue
		case key == "\r" || key == "\n":
			switchTo(current)
			return
		case key == "q" || key == "\x1b" || key == "\x03":
			return
		case len(key) == 1 && key[0] >= '1' && key[0] <= '9':
			for _, r := range rows {
				if r.tab == nil && r.ws.Number == int(key[0]-'0') {
					switchTo(r)
					return
				}
			}
			continue

		case key == "r":
			name, ok := prompt(rows, index, "Rename to: ", current.label())
			if !ok || name == "" {
				continue
			}
			if current.tab != nil {
				actionErr = call("tab.rename", map[string]string{"tab_id": current.tab.ID, "label": name}, nil)
			} else {
				actionErr = call("workspace.rename", map[string]string{"workspace_id": current.ws.ID, "label": name}, nil)
			}

		case key == "x":
			if current.tab != nil {
				if !confirm(rows, index, fmt.Sprintf("Close tab %q?", current.tab.Label)) {
					continue
				}
				actionErr = call("tab.close", map[string]string{"tab_id": current.tab.ID}, nil)
			} else {
				if !confirm(rows, index, fmt.Sprintf("Close workspace %q and all its tabs?", current.ws.Label)) {
					continue
				}
				actionErr = call("workspace.close", map[string]string{"workspace_id": current.ws.ID}, nil)
			}
			// The closed row is gone. Stay near where it was.
			if actionErr == nil && index > 0 {
				keepID = rows[index-1].id()
			}

		case key == "n":
			name, ok := prompt(rows, index, fmt.Sprintf("New tab in %s: ", current.ws.Label), "")
			if !ok {
				continue
			}
			params := map[string]any{"workspace_id": current.ws.ID}
			if name != "" {
				params["label"] = name
			}
			var created struct {
				Tab tab `json:"tab"`
			}
			actionErr = call("tab.create", params, &created)
			if created.Tab.ID != "" {
				keepID = created.Tab.ID
			}

		default:
			continue
		}

		if actionErr != nil {
			footer = accent + "herdr: " + actionErr.Error() + reset
		}
		newRows, newIndex, err := load(keepID)
		if err != nil {
			footer = accent + "herdr: " + err.Error() + reset
			continue
		}
		if len(newRows) == 0 {
			return
		}
		rows, index = newRows, newIndex
	}
}
