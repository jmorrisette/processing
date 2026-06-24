# processing

Creative coding sketches built with [Processing](https://processing.org/). Clone this repo, point Processing at the `Collection/` folder, and run or extend any sketch.

## Requirements

- [Processing 4](https://processing.org/download) (4.4+ recommended for CLI support)
- Java is bundled with Processing — no separate install needed

## Quick start

### Option A — Processing IDE (easiest)

1. Install Processing from [processing.org/download](https://processing.org/download).
2. Open Processing → **File → Preferences** and set **Sketchbook location** to the `Collection` folder in this repo:

   ```
   /path/to/processing/Collection
   ```

3. Open a sketch: **File → Open** → `Collection/HelloSketch/HelloSketch.pde`
4. Press **Run** (▶).

### Option B — Command line

From the repo root, pass the sketch folder name (not the `.pde` path).

**Git Bash / WSL** — use the shell script (`.ps1` is PowerShell-only):

```bash
./scripts/run.sh HelloSketch
```

**PowerShell** — use the PowerShell script:

```powershell
.\scripts\run.ps1 HelloSketch
```

Or invoke PowerShell from Git Bash:

```bash
powershell.exe -File ./scripts/run.ps1 HelloSketch
```

If Processing is not on your PATH, set `PROCESSING_HOME` to your install directory:

```powershell
$env:PROCESSING_HOME = "C:\Program Files\Processing"
.\scripts\run.ps1 HelloSketch
```

```bash
export PROCESSING_HOME="/c/Program Files/Processing"
./scripts/run.sh HelloSketch
```

## Repository layout

```
processing/
├── Collection/              # All sketches live here (set as sketchbook root)
│   ├── libraries/           # Shared contributed libraries
│   ├── HelloSketch/         # Example starter sketch
│   │   └── HelloSketch.pde
│   └── README.md            # Sketch index and how to add new ones
├── scripts/
│   ├── run.ps1              # Run a sketch on Windows
│   └── run.sh               # Run a sketch on macOS/Linux
└── README.md
```

## Add a new sketch

1. Create `Collection/YourSketch/YourSketch.pde` (folder name and main tab must match).
2. Add optional tabs (`YourSketch/OtherTab.pde`) or assets in `YourSketch/data/`.
3. List it in [`Collection/README.md`](Collection/README.md).
4. Run it with `.\scripts\run.ps1 YourSketch` or open it in the IDE.

See [`Collection/README.md`](Collection/README.md) for library and asset conventions.

## Extending sketches

- **Additional code tabs** — add more `.pde` files in the sketch folder; Processing merges them automatically.
- **Media assets** — put images, fonts, and sounds in a `data/` subfolder inside the sketch directory.
- **Third-party libraries** — install via **Sketch → Import Library → Add Library…** (with sketchbook set to `Collection/`). Libraries are not committed to this repo (see `.gitignore`). LootSeeker needs the **Sound** library.

## Exporting

To export a standalone app from the command line (Processing 4.4+):

```powershell
& "$env:PROCESSING_HOME\Processing.exe" cli --sketch="C:\full\path\to\Collection\HelloSketch" --export
```

Export output is gitignored (`application.*/`).
