function ConvertTo-ReversedString {
    [CmdletBinding()]
    param(
        # The string to be reversed
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string]
        $String
    )
    process {
        # The core logic to reverse the string
        -join $String[($String.Length-1)..0]
    }
}