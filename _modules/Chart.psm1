function Save-LineChart {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject[]] $Points,   # each with X, Y

        [Parameter(Mandatory)]
        [string] $Path,

        [int] $Width  = 800,
        [int] $Height = 600,

        [string] $Title  = "Line Chart",
        [string] $XAxisTitle = "X",
        [string] $YAxisTitle = "Y"
    )

    if (-not $Points -or $Points.Count -eq 0) {
        throw "Points collection is empty."
    }

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Windows.Forms.DataVisualization

    # Extract X/Y series
    $xVals = $Points | ForEach-Object { [double]$_.X }
    $yVals = $Points | ForEach-Object { [double]$_.Y }

    $xMin = ($xVals | Measure-Object -Minimum).Minimum
    $xMax = ($xVals | Measure-Object -Maximum).Maximum
    $yMin = ($yVals | Measure-Object -Minimum).Minimum
    $yMax = ($yVals | Measure-Object -Maximum).Maximum

    $chart = [System.Windows.Forms.DataVisualization.Charting.Chart]::new()
    $chart.Width  = $Width
    $chart.Height = $Height

    $chartArea = [System.Windows.Forms.DataVisualization.Charting.ChartArea]::new("MainArea")
    $chart.ChartAreas.Add($chartArea)

    # Limit bounds to the data
    $xa = $chart.ChartAreas["MainArea"].AxisX
    $ya = $chart.ChartAreas["MainArea"].AxisY

    $xa.Minimum = $xMin
    $xa.Maximum = $xMax
    $ya.Minimum = $yMin
    $ya.Maximum = $yMax

    $xa.Title = $XAxisTitle
    $ya.Title = $YAxisTitle

    $series = [System.Windows.Forms.DataVisualization.Charting.Series]::new("Series1")
    $series.ChartType =
        [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line
    $series.BorderWidth = 2
    $chart.Series.Add($series)

    foreach ($p in $Points) {
        [void]$series.Points.AddXY($p.X, $p.Y)
    }

    if ($Title) {
        [void]$chart.Titles.Add($Title)
    }

    # Ensure directory exists
    $dir = [System.IO.Path]::GetDirectoryName($Path)
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $chart.SaveImage(
        $Path,
        [System.Windows.Forms.DataVisualization.Charting.ChartImageFormat]::Png
    )

    $chart.Dispose()
}