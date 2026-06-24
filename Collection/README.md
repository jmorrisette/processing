# Collection

Sketches live here — one folder per project. Each sketch folder contains a `.pde` file with the same name as the folder (Processing convention).

## Sketches

| Sketch | Description |
|--------|-------------|
| [CircleSketch](CircleSketch/) | Timed loot-collection game (requires **Sound** library — install from the Library Manager) |
| [HelloSketch](HelloSketch/) | Animated color grid — starter template |

## Shared libraries

Place contributed Processing libraries in [`libraries/`](libraries/). They are available to every sketch in this folder when the Processing sketchbook is set to `Collection/`.

Install libraries from the IDE via **Sketch → Import Library → Add Library…** — they will land in this folder automatically if your sketchbook location points here. Library folders are **gitignored** (not pushed to GitHub); each developer installs them locally.

## Add a new sketch

1. Create a folder: `Collection/MySketch/`
2. Add the main tab: `Collection/MySketch/MySketch.pde`
3. Open it in Processing (**File → Open**) or run from the repo root:

   ```powershell
   .\scripts\run.ps1 MySketch
   ```

   ```bash
   ./scripts/run.sh MySketch
   ```

Optional tabs and a `data/` folder for images, fonts, and sounds can live alongside the main `.pde` file.
