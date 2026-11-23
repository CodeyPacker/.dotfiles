# Lists or sets the Herdr desktop app background image.
#   set-background.ps1          -> prints image file names in Pictures\herdr
#   set-background.ps1 <name> solid|clear
#                               -> copies that image into the app's backgrounds
#                                  folder and points the active layout at it
# solid: the terminals are drawn in the theme color, so the image shows only around the panes.
# clear: the terminals are drawn at 85% so the image shows faintly behind them. The panes' own
#        background colors are removed, or they would hide it.
# Keep in step with set-background.sh.
param([string]$Name, [string]$Panes)

$ErrorActionPreference = 'Stop'

$source = Join-Path ([Environment]::GetFolderPath('MyPictures')) 'herdr'
$appHome = Join-Path $HOME '.config\herdr-app'
$imageTypes = '.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'

if (-not (Test-Path $source)) { throw "Picture folder not found: $source" }

$images = Get-ChildItem $source -File | Where-Object { $imageTypes -contains $_.Extension.ToLower() }

if (-not $Name) {
    $images | Sort-Object Name | ForEach-Object Name
    exit 0
}

# Herdr draws terminals twice at 0.61: they look 85% solid.
$opacity = switch ($Panes) { 'solid' { 1 } 'clear' { 0.61 } default { throw 'Usage: set-background.ps1 <name> solid|clear' } }

$image = $images | Where-Object Name -eq $Name
if (-not $image) { throw "No image named '$Name' in $source" }

# The active layout name is stored in shared.json as "layout".
$shared = Get-Content (Join-Path $appHome 'shared.json') -Raw | ConvertFrom-Json -Depth 100 -AsHashtable
$layoutName = if ($shared['layout']) { $shared['layout'] } else { 'main' }
$layoutPath = Join-Path $appHome "layouts\$layoutName.json"
if (-not (Test-Path $layoutPath)) { throw "Layout file not found: $layoutPath" }
if ((Get-Item $layoutPath).LinkType) { throw "$layoutName is a linked layout. Clone it in Herdr's settings first, then run this again." }

# Herdr only reads background images from inside its home folder.
$backgrounds = Join-Path $appHome 'backgrounds'
New-Item -ItemType Directory -Force $backgrounds | Out-Null
Copy-Item $image.FullName (Join-Path $backgrounds $image.Name) -Force

$layout = Get-Content $layoutPath -Raw | ConvertFrom-Json -Depth 100
$fit = if ($layout.background.fit) { $layout.background.fit } else { 'cover' }
$value = [pscustomobject]@{ image = "backgrounds/$($image.Name)"; fit = $fit }
# Assign in place when the key exists so the file keeps its key order.
if ($layout.PSObject.Properties['background']) { $layout.background = $value }
else { $layout | Add-Member -NotePropertyName background -NotePropertyValue $value }
if ($layout.PSObject.Properties['terminal_opacity']) { $layout.terminal_opacity = $opacity }
else { $layout | Add-Member -NotePropertyName terminal_opacity -NotePropertyValue $opacity }

# Clear panes: remove each pane's own background so the image shows behind the terminals.
function Remove-PaneBackground($node) {
    if ($node -is [System.Collections.IEnumerable] -and $node -isnot [string]) { foreach ($item in $node) { Remove-PaneBackground $item }; return }
    if ($node -isnot [pscustomobject]) { return }
    $pane = $node.PSObject.Properties['pane']
    if ($pane -and $pane.Value -is [pscustomobject] -and $pane.Value.PSObject.Properties['background']) { $pane.Value.PSObject.Properties.Remove('background') }
    foreach ($p in $node.PSObject.Properties) { Remove-PaneBackground $p.Value }
}
if ($Panes -eq 'clear') { Remove-PaneBackground $layout }

$json = ($layout | ConvertTo-Json -Depth 100) -replace "`r`n", "`n"
[IO.File]::WriteAllText($layoutPath, "$json`n")

"Set $layoutName background to backgrounds/$($image.Name) with $Panes panes"
