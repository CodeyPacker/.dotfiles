# Lists or sets the Herdr desktop app background image.
#   set-background.ps1          -> prints image file names in Pictures\herdr
#   set-background.ps1 <name>   -> copies that image into the app's backgrounds
#                                  folder and points the active layout at it
param([string]$Name)

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

$image = $images | Where-Object Name -eq $Name
if (-not $image) { throw "No image named '$Name' in $source" }

# The active layout name is stored in shared.json as "layout".
$shared = Get-Content (Join-Path $appHome 'shared.json') -Raw | ConvertFrom-Json -Depth 100 -AsHashtable
$layoutName = if ($shared['layout']) { $shared['layout'] } else { 'main' }
$layoutPath = Join-Path $appHome "layouts\$layoutName.json"
if (-not (Test-Path $layoutPath)) { throw "Layout file not found: $layoutPath" }

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

$json = ($layout | ConvertTo-Json -Depth 100) -replace "`r`n", "`n"
[IO.File]::WriteAllText($layoutPath, "$json`n")

"Set $layoutName background to backgrounds/$($image.Name)"
