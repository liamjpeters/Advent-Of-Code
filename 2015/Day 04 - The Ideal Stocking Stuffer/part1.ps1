<#
Santa needs help mining some AdventCoins (very similar to bitcoins) to use as
gifts for all the economically forward-thinking little girls and boys.

To do this, he needs to find MD5 hashes which, in hexadecimal, start with at
least five zeroes. The input to the MD5 hash is some secret key (your puzzle
input, given below) followed by a number in decimal. To mine AdventCoins, you
must find Santa the lowest positive number (no leading zeroes: 1, 2, 3, ...)
that produces such a hash.

For example:

- If your secret key is abcdef, the answer is 609043, because the MD5 hash of
  abcdef609043 starts with five zeroes (000001dbbfa...), and it is the lowest
  such number to do so.
- If your secret key is pqrstuv, the lowest number it combines with to make an
  MD5 hash starting with five zeroes is 1048970; that is, the MD5 hash of
  pqrstuv1048970 looks like 000006136ef....
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
    # Convert to a hex string. [System.BitConverter] returns the hex with
    # dashes. Comparing the dashed string is quicker than replacing the dashes.
    $first5Hex = (
        [System.BitConverter]::ToString($hashBytes)
    ).Substring(0,7)
    if ($first5Hex -eq '00-00-0') {
        Write-Host "$index"
        break
    }

    if ($index -ge 10000000) {
        Write-Host "failed to find after 10M attempts"
        exit
    }
    $index++
}