Import-Module @(
    "$PSScriptRoot\Validation.psm1"
) -Force -DisableNameChecking

function New-Day {

    # Sanitises a proposed folder name
    function New-SafeFolderName {
        [CmdletBinding()]
        [OutputType([string])]
        param (
            # The proposed folder name
            [Parameter(Mandatory, Position = 0)]
            [string]
            $FolderName
        )

        # Trim leading/trailing whitespace
        $safeName = $FolderName.Trim()

        # Define invalid characters to replace
        $invalidChars = [IO.Path]::GetInvalidFileNameChars()

        # Replace each invalid character with an underscore
        foreach ($char in $invalidChars) {
            $safeName = $safeName.Replace($char, '_')
        }

        # Handle reserved names by prepending an underscore
        $reservedNames = @(
            "CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3", "COM4", "COM5",
            "COM6", "COM7", "COM8", "COM9", "LPT1", "LPT2", "LPT3", "LPT4",
            "LPT5", "LPT6", "LPT7", "LPT8", "LPT9"
        )
        if ($reservedNames -contains $safeName.ToUpper()) {
            $safeName = "_$safeName"
        }

        # Remove trailing periods, as these are invalid in folder names on Windows
        if ($safeName.EndsWith('.')) {
            $safeName = $safeName.TrimEnd('.')
        }

        # Ensure the name is not empty or just an underscore
        if ([string]::IsNullOrWhiteSpace($safeName) -or $safeName -eq '_') {
            $safeName = "DefaultFolder"
        }

        return $safeName
    }

    # Get the list of year folders
    $rootDir = "$PSScriptRoot\..\"
    $yearFolders = Get-ChildItem $rootDir -Directory -Exclude '_modules' |
        Sort-Object Name -Descending

    # Get the choice of folder
    # The parameters are:
    # 1. Title (string)
    # 2. Message (string)
    # 3. Choices (array of ChoiceDescription)
    # 4. DefaultChoice (integer index of the default choice)
    $choiceIndex = $host.ui.PromptForChoice(
        "Year Selection",
        "Pick a Year:",
        $yearFolders.Name,
        0
    )

    # Resolve that to a directory
    $destFolder = $yearFolders[$choiceIndex]

    # Pick the Day Number
    $dayNumber = Read-Host -Prompt "Pick a Day Number (01-25):"

    if (-not (IsNumeric $dayNumber)) {
        Write-Host "Day Number must be numeric"
        return
    }

    if (-not (IsNumberInRange 1 25 $dayNumber)) {
        Write-Host "Day Number must be between 1 and 25 (inclusive)"
        return
    }

    $title = Read-Host -Prompt "Enter a title:"

    if ([string]::IsNullOrWhiteSpace($title)) {
        Write-Host "Title cannot be Empty/Whitespace"
        return
    }

    $dirName = "Day $('{0:D2}' -f ([int]$dayNumber)) - $title"
    $dirName = New-SafeFolderName $dirName

    Push-Location $destFolder

    try {
        $newDir = New-Item -ItemType Directory -Name $dirName -ErrorAction Stop
    } catch {
        Write-Host "Failed to create folder: $($_.Exception.Message)"
    } finally {
        Pop-Location
    }

    Push-Location $newDir

    # Make the files
    try {
        New-Item -ItemType File -Name 'input.txt' | Out-Null
        New-Item -ItemType File -Name 'input_test.txt' | Out-Null
        New-Item -ItemType File -Name 'part1.ps1' | Out-Null
        New-Item -ItemType File -Name 'part2.ps1' | Out-Null
    } catch {
        Pop-Location
    }

    try {
        Set-Content -Path 'part1.ps1' -Value @'
<#

#>

$rawInput = Get-Content "$PSScriptRoot\input.txt" -Raw
'@

    } catch {
        Write-Host "Failed to set content of file 'part1.ps1': $($_.Exception.Message)"
        Pop-Location
    }

    try {
        Set-Content -Path 'part2.ps1' -Value @'
<#

#>

$rawInput = Get-Content "$PSScriptRoot\input.txt" -Raw
'@

    } catch {
        Write-Host "Failed to set content of file 'part2.ps1': $($_.Exception.Message)"
        Pop-Location
    }
    Pop-Location
    Write-Host "Day Created"
}