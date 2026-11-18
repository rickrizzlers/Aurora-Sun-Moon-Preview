param([Parameter(Mandatory)][string]$Package, [Parameter(Mandatory)][string]$Output)
$ErrorActionPreference = 'Stop'
$root = Join-Path ([IO.Path]::GetTempPath()) ('SunMoonCapture-' + [guid]::NewGuid())
$install = Join-Path $root 'install'
$profile = Join-Path $root 'profile'
New-Item -ItemType Directory -Path $profile -Force | Out-Null
Copy-Item -LiteralPath (Resolve-Path $Package).Path -Destination $install -Recurse
$out = (New-Item -ItemType Directory -Force -Path $Output).FullName
[IO.File]::WriteAllText((Join-Path $root 'aurora-update-test.json'), '{"schema":1,"feed":"http://127.0.0.1:1/feed.json"}')
foreach ($source in 'sun','moon') {
    foreach ($mode in 'off','on') {
        $name = "$source-$mode"
        $image = Join-Path $out "$name.png"
        if (Test-Path -LiteralPath $image) { throw "$image already exists" }
        $settings = @{ sky_rays_enabled=($mode -eq 'on'); sky_ray_source=@{sun=1;moon=2}[$source]; sky_ray_strength=1.2; sky_ray_samples=32; shadow_quality=3 }
        [IO.File]::WriteAllText((Join-Path $profile 'settings.json'), ($settings | ConvertTo-Json))
        $shots = (New-Item -ItemType Directory -Path (Join-Path $root $name)).FullName
        $proc = [Diagnostics.ProcessStartInfo]::new()
        $proc.FileName = Join-Path $install 'aurora-viewer.exe'
        $proc.WorkingDirectory = $install
        $proc.UseShellExecute = $false
        $proc.WindowStyle = 'Hidden'
        foreach ($pair in @{
            AURORA_UPDATE_TEST_ROOT=$root; AURORA_DEMO='1'; AURORA_DEMO_SKY='midday'; AURORA_DEMO_SKY_RAYS=$source
            AURORA_WINDOW_SIZE='1280,720'; AURORA_CAPTURE=(Join-Path $root "$name-window.png"); AURORA_CAPTURE_FRAMES='800'; AURORA_CAPTURE_EXIT='1'
            AURORA_DEMO_POS='80,100'; AURORA_DEMO_PLANTS='dense'; AURORA_DEMO_SNAPSHOT="save:1280x720:png:$shots"
            AURORA_DEMO_SNAPSHOT_FRAME='660'; AURORA_DEMO_SNAPSHOT_TILE='768'; AURORA_SHADOWS='3'; AURORA_LOG_NAME=$name; RUST_LOG='info,wgpu_core=warn,wgpu_hal=warn'
        }.GetEnumerator()) { $proc.EnvironmentVariables[$pair.Key]=$pair.Value }
        $p = [Diagnostics.Process]::Start($proc)
        if (!$p.WaitForExit(420000)) { throw "$name capture timed out. See $root/logs." }
        $photos = @(Get-ChildItem -LiteralPath $shots -Filter '*.png')
        if ($p.ExitCode -ne 0 -or $photos.Count -ne 1) { throw "$name failed. See $root/logs." }
        Copy-Item -LiteralPath $photos[0].FullName -Destination $image
        Write-Output $image
    }
}
Write-Output "Capture diagnostics are in $root"
