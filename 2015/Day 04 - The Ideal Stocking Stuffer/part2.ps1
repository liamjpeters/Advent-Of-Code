<#
Now find one that starts with six zeroes.
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt" -Raw

# Instantiate .NET MD5 hasher
$md5Hasher = [System.Security.Cryptography.MD5]::Create()

# Start at 1
$index = 1
while ($true) {
    # Construct the string to hash. Our secret key followed by current digits
    $stringToHash = "$rawInput$index"

    # Compute the hash
    $hashBytes = $md5Hasher.ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes(
            $stringToHash
        )
    )

    # Can simplify from part 1 and just check first 3 bytes
    if ($hashBytes[0] -eq 0 -and $hashBytes[1] -eq 0 -and $hashBytes[2] -eq 0) {
        Write-Host "$index"
        break
    }

    if ($index -ge 10000000) {
        Write-Host "failed to find after 10M attempts"
        exit
    }
    $index++
}