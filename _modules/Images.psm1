function SaveBitGridToBitmap {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [bool[, ]]
        $Grid,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileName,
        [Parameter()]
        [ValidateNotNull()]
        [System.Drawing.Color]
        $TrueColour = [System.Drawing.Color]::Black,
        [Parameter()]
        [ValidateNotNull()]
        [System.Drawing.Color]
        $FalseColour = [System.Drawing.Color]::White
    )
    # Ensure System.Drawing is loaded
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop

    $height = $Grid.GetLength(0)
    $width = $Grid.GetLength(1)

    $bitmap = New-Object System.Drawing.Bitmap($width, $height)
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            # Check the boolean value at the current grid coordinate
            if ($grid[$x, $y] -eq $true) {
                # If true, set the pixel to black
                $bitmap.SetPixel($x, $y, $TrueColour)
            } else {
                # If false, set the pixel to white
                $bitmap.SetPixel($x, $y, $FalseColour)
            }
        }
    }
    $bitmap.Save(
        $FileName,
        [System.Drawing.Imaging.ImageFormat]::Png
    )
}

function SaveConnectedPointsToBitmap {
    param (
        # An array of points with an X and Y property
        [Parameter(Mandatory)]
        [PSCustomObject[]]
        $Points,
        [Parameter(Mandatory)]
        [string]
        $OutputPath,
        [Parameter()]
        [System.Drawing.Color]
        $ForegroundColor = [System.Drawing.Color]::Blue,
        [Parameter()]
        [System.Drawing.Color]
        $BackgroundColor = [System.Drawing.Color]::White,
        [Parameter()]
        [int]
        $PenWidth = 2
    )

    try {
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop

        # Define the dimensions of the image
        $width = $Points |
            Measure-Object -Maximum -Property X |
            Select-Object -ExpandProperty Maximum

        $height = $Points |
            Measure-Object -Maximum -Property Y |
            Select-Object -ExpandProperty Maximum

        # Create a new Bitmap object
        $bitmap = [System.Drawing.Bitmap]::new([int]$width, [int]$height)

        # Create a Graphics object from the bitmap to draw on it
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

        # Set the background color
        $graphics.Clear($BackgroundColor)

        # Define the pen (Color, Width)
        $pen = [System.Drawing.Pen]::new($ForegroundColor, $PenWidth)

        $graphicsPoints = $Points | ForEach-Object {
            [System.Drawing.Point]::new([int]$_.X, [int]$_.Y)
        }

        # Draw the lines connecting the points
        $graphics.DrawLines($pen, $graphicsPoints)

        $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    } catch {
        throw "An error occurred: $($_.Exception.Message)"
    } finally {
        if ($pen) { $pen.Dispose() }
        if ($graphics) { $graphics.Dispose() }
        if ($bitmap) { $bitmap.Dispose() }
    }
}

function Convert-PngFolderToBWGif {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $InputFolder,
        [Parameter(Mandatory)]
        [string]
        $OutputGif,
        [int]
        $Framerate = 10,
        [int]
        $Scale = 1
    )

    # Ensure ffmpeg is available
    if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
        throw 'ffmpeg is not installed or not on the PATH.'
    }

    $inputPattern = Join-Path $InputFolder '%03d.png'
    $palettePath = Join-Path $InputFolder 'palette.png'

    # Step 1: Generate a 2-color palette
    $paletteCmd = if ($Scale -gt 1) {
        "ffmpeg -y -framerate $Framerate -i `"$inputPattern`" -vf `"scale=iw*$($Scale):ih*$($Scale):flags=neighbor,palettegen`" `"$palettePath`""
    } else {
        "ffmpeg -y -framerate $Framerate -i `"$inputPattern`" -vf `"palettegen`" `"$palettePath`""
    }
    Invoke-Expression $paletteCmd

    # Step 2: Create GIF using the palette, disable dithering, use nearest neighbor scaling
    $gifCmd = if ($Scale -gt 1) {
        "ffmpeg -y -framerate $Framerate -i `"$inputPattern`" -i `"$palettePath`" -lavfi `"scale=iw*$($Scale):ih*$($Scale):flags=neighbor [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=0`" `"$OutputGif`""
    } else {
        "ffmpeg -y -framerate $Framerate -i `"$inputPattern`" -i `"$palettePath`" -lavfi `"paletteuse=dither=bayer:bayer_scale=0`" `"$OutputGif`""
    }
    Invoke-Expression $gifCmd

    Remove-Item $palettePath -ErrorAction SilentlyContinue
}