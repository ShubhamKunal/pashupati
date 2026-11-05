Add-Type -AssemblyName System.Drawing

function Render-PashupatiLogo([int]$size, [bool]$transparentBg = $false) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $scale = $size / 512.0

    if (-not $transparentBg) {
        $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#F5F1E7"))
        $g.FillRectangle($bgBrush, 0, 0, $size, $size)
        $bgBrush.Dispose()

        # Outer accent circle
        $circleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#E9F1E9"))
        $circlePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(38, 36, 77, 56), (4.0 * $scale))
        $r = 210.0 * $scale
        $cx = 256.0 * $scale
        $cy = 256.0 * $scale
        $g.FillEllipse($circleBrush, ($cx - $r), ($cy - $r), ($r * 2), ($r * 2))
        $g.DrawEllipse($circlePen, ($cx - $r), ($cy - $r), ($r * 2), ($r * 2))
        $circleBrush.Dispose()
        $circlePen.Dispose()
    }

    # Center translation: (256, 265)
    $g.TranslateTransform((256.0 * $scale), (265.0 * $scale))
    $g.ScaleTransform($scale, $scale)

    # Brushes
    $pashuBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.PointF(-100, -150)),
        (New-Object System.Drawing.PointF(100, 100)),
        [System.Drawing.ColorTranslator]::FromHtml("#244D38"),
        [System.Drawing.ColorTranslator]::FromHtml("#183B2B")
    )
    $saffronBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.PointF(-100, 0)),
        (New-Object System.Drawing.PointF(100, 120)),
        [System.Drawing.ColorTranslator]::FromHtml("#E5A952"),
        [System.Drawing.ColorTranslator]::FromHtml("#D99A45")
    )

    # Main heart/palm path
    $path1 = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path1.StartFigure()
    $path1.AddBezier(
        (New-Object System.Drawing.PointF(0, 60)),
        (New-Object System.Drawing.PointF(-55, 60)),
        (New-Object System.Drawing.PointF(-95, 15)),
        (New-Object System.Drawing.PointF(-90, -45))
    )
    $path1.AddBezier(
        (New-Object System.Drawing.PointF(-90, -45)),
        (New-Object System.Drawing.PointF(-85, -95)),
        (New-Object System.Drawing.PointF(-25, -120)),
        (New-Object System.Drawing.PointF(0, -70))
    )
    $path1.AddBezier(
        (New-Object System.Drawing.PointF(0, -70)),
        (New-Object System.Drawing.PointF(25, -120)),
        (New-Object System.Drawing.PointF(85, -95)),
        (New-Object System.Drawing.PointF(90, -45))
    )
    $path1.AddBezier(
        (New-Object System.Drawing.PointF(90, -45)),
        (New-Object System.Drawing.PointF(95, 15)),
        (New-Object System.Drawing.PointF(55, 60)),
        (New-Object System.Drawing.PointF(0, 60))
    )
    $path1.CloseFigure()
    $g.FillPath($pashuBrush, $path1)
    $path1.Dispose()

    # Cradle curve
    $path2 = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path2.StartFigure()
    $path2.AddBezier(
        (New-Object System.Drawing.PointF(-110, 35)),
        (New-Object System.Drawing.PointF(-70, 120)),
        (New-Object System.Drawing.PointF(70, 120)),
        (New-Object System.Drawing.PointF(110, 35))
    )
    $path2.AddBezier(
        (New-Object System.Drawing.PointF(110, 35)),
        (New-Object System.Drawing.PointF(85, 85)),
        (New-Object System.Drawing.PointF(-85, 85)),
        (New-Object System.Drawing.PointF(-110, 35))
    )
    $path2.CloseFigure()
    $g.FillPath($saffronBrush, $path2)
    $path2.Dispose()

    # 4 Outer Paw Pads
    $pads = @(
        @{ cx = -85; cy = -95; rx = 26; ry = 34; rot = -28 },
        @{ cx = -32; cy = -145; rx = 26; ry = 36; rot = -10 },
        @{ cx = 32; cy = -145; rx = 26; ry = 36; rot = 10 },
        @{ cx = 85; cy = -95; rx = 26; ry = 34; rot = 28 }
    )

    foreach ($pad in $pads) {
        $state = $g.Save()
        $g.TranslateTransform($pad.cx, $pad.cy)
        $g.RotateTransform($pad.rot)
        $g.FillEllipse($pashuBrush, -$pad.rx, -$pad.ry, ($pad.rx * 2), ($pad.ry * 2))
        $g.Restore($state)
    }

    # Center Pad Spark
    $ivoryBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#F5F1E7"))
    $g.FillEllipse($ivoryBrush, -14, -34, 28, 28)
    $ivoryBrush.Dispose()

    # Inner flame heart
    $flamePath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $flamePath.StartFigure()
    $flamePath.AddBezier(
        (New-Object System.Drawing.PointF(0, -28)),
        (New-Object System.Drawing.PointF(-8, -38)),
        (New-Object System.Drawing.PointF(-20, -24)),
        (New-Object System.Drawing.PointF(0, -6))
    )
    $flamePath.AddBezier(
        (New-Object System.Drawing.PointF(0, -6)),
        (New-Object System.Drawing.PointF(20, -24)),
        (New-Object System.Drawing.PointF(8, -38)),
        (New-Object System.Drawing.PointF(0, -28))
    )
    $flamePath.CloseFigure()
    $g.FillPath($saffronBrush, $flamePath)
    $flamePath.Dispose()

    $pashuBrush.Dispose()
    $saffronBrush.Dispose()
    $g.Dispose()

    return $bmp
}

# 1. Main branding logo
$logo512 = Render-PashupatiLogo 512 $false
$logo512.Save("assets/branding/app_logo.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 2. Foreground transparent logo for adaptive icon
$fgLogo = Render-PashupatiLogo 512 $true
$fgLogo.Save("assets/branding/app_icon_foreground.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 3. Android Mipmap icons
$sizes = @{
    "android/app/src/main/res/mipmap-mdpi" = 48
    "android/app/src/main/res/mipmap-hdpi" = 72
    "android/app/src/main/res/mipmap-xhdpi" = 96
    "android/app/src/main/res/mipmap-xxhdpi" = 144
    "android/app/src/main/res/mipmap-xxxhdpi" = 192
}

foreach ($dir in $sizes.Keys) {
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $s = $sizes[$dir]
    $icon = Render-PashupatiLogo $s $false
    $icon.Save("$dir/ic_launcher.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $icon.Dispose()
}

# Splash screen logo
$splashLogo = Render-PashupatiLogo 256 $false
$splashLogo.Save("android/app/src/main/res/drawable/launch_image.png", [System.Drawing.Imaging.ImageFormat]::Png)
$splashLogo.Dispose()
$logo512.Dispose()
$fgLogo.Dispose()

Write-Host "Pashupati branding and app icons generated successfully!"

