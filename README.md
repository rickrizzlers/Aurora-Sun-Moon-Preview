# Sun & Moon Preview

An independent Windows x64 viewer based on Aurora Viewer 0.9.11 beta (November 17, 2026), modified November 18, 2026 by Rizz. It brings Privé’s volumetric sun and moon rays to Aurora’s Graphics preferences. Aurora Viewer and Linden Lab do not provide or support this preview.

Download the Windows ZIP from [Releases](https://github.com/rickrizzlers/Aurora-Sun-Moon-Preview/releases). Extract the entire folder, then open the viewer executable inside. The preview has its own settings, cache and saved-login storage. You can also run the included Offline demo to try it without an account.

In **Preferences → Graphics → Light → Shadows**, choose a shadow quality above Disabled, then turn on **Volumetric Sun & Moon rays**. **Automatic** follows the active shadow-casting body. **Sun** enables the effect in sunlight only. **Moon** requires the sun below the horizon and the moon above it. Nearby trees, windows and other shadow casters make useful subjects.

**Ray strength** controls brightness, **Near fade** sets how far from the camera the effect builds up, and **Ray samples** trades GPU time for smoother beams. Try the default 32 samples first. The effect starts off. Hardware ray tracing is unnecessary.

The comparison images in the release use the offline scene, a fixed camera and matching lighting for each off/on pair. For reproducible captures see scripts/Capture-SkyRays.ps1. To build from source, install Aurora's Windows Rust dependencies, run `cargo build --locked -p aurora-viewer`, then use scripts/package.ps1 to assemble the portable folder.

This software is distributed under the upstream GNU GPL v3 or later. See LICENSE, NOTICE.md and THIRD-PARTY-LICENSES.md for copyright and asset credits.
