param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Sketch
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$sketchPath = Join-Path (Join-Path $repoRoot "Collection") $Sketch

if (-not (Test-Path $sketchPath)) {
  Write-Error "Sketch not found: $sketchPath`nCreate Collection\$Sketch\$Sketch.pde first."
}

$pdeFile = Join-Path $sketchPath "$Sketch.pde"
if (-not (Test-Path $pdeFile)) {
  Write-Error "Main sketch file not found: $pdeFile"
}

function Find-ProcessingExecutable {
  if ($env:PROCESSING_HOME) {
    foreach ($name in @("processing.exe", "Processing.exe")) {
      $fromEnv = Join-Path $env:PROCESSING_HOME $name
      if (Test-Path $fromEnv) { return $fromEnv }
    }
  }

  $dirs = @(
    "C:\Program Files\Processing",
    "$env:LOCALAPPDATA\Programs\Processing",
    "$env:ProgramFiles\Processing"
  )

  foreach ($dir in $dirs) {
    foreach ($name in @("processing.exe", "Processing.exe")) {
      $path = Join-Path $dir $name
      if (Test-Path $path) { return $path }
    }
  }

  foreach ($cmd in @("processing", "processing-java")) {
    $fromPath = (Get-Command $cmd -ErrorAction SilentlyContinue).Source
    if ($fromPath) { return $fromPath }
  }

  return $null
}

$processingExe = Find-ProcessingExecutable
if (-not $processingExe) {
  Write-Error @"
Processing was not found.

Install Processing 4 from https://processing.org/download
Then either:
  - add processing.exe to your PATH, or
  - set PROCESSING_HOME to your Processing install directory

You can also open sketches in the IDE:
  File -> Open -> $pdeFile
"@
}

$absoluteSketchPath = (Resolve-Path $sketchPath).Path
Write-Host "Running $Sketch with $processingExe"
& $processingExe cli --sketch="$absoluteSketchPath" --run
