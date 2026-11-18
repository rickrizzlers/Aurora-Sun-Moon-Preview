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
        $settings = @{ sky_rays_enabled=($mode -eq 'on'); sky_ray_source=@{sun=1;moon=2}[$source]; sky_ray_strength=2.5; sky_ray_samples=32; shadow_quality=3 }
        [IO.File]::WriteAllText((Join-Path $profile 'settings.json'), ($settings | ConvertTo-Json))
        $proc = [Diagnostics.ProcessStartInfo]::new()
        $proc.FileName = Join-Path $install 'aurora-viewer.exe'
        $proc.WorkingDirectory = $install
        $proc.UseShellExecute = $false
        $proc.WindowStyle = 'Hidden'
        foreach ($pair in @{
            AURORA_UPDATE_TEST_ROOT=$root; AURORA_DEMO='1'; AURORA_DEMO_SKY='midday'; AURORA_DEMO_SKY_RAYS=$source
            AURORA_WINDOW_SIZE='1280,720'; AURORA_CAPTURE=$image; AURORA_CAPTURE_FRAMES='400'; AURORA_CAPTURE_EXIT='1'
            AURORA_SHADOWS='3'; AURORA_LOG_NAME=$name; RUST_LOG='info,wgpu_core=warn,wgpu_hal=warn'
        }.GetEnumerator()) { $proc.EnvironmentVariables[$pair.Key]=$pair.Value }
        $p = [Diagnostics.Process]::Start($proc)
        if (!$p.WaitForExit(420000)) { throw "$name capture timed out. See $root/logs." }
        if ($p.ExitCode -ne 0 -or !(Test-Path -LiteralPath $image)) { throw "$name failed. See $root/logs." }
        Write-Output $image
    }
}
Write-Output "Capture diagnostics are in $root"
