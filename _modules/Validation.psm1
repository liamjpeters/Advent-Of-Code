<#
.SYNOPSIS
    Determines whether the specified input is a numeric value.

.DESCRIPTION
    The IsNumeric function checks if the provided input can be interpreted as a
    numeric value.
    It returns $true if the input is numeric; otherwise, it returns $false.

.PARAMETER InputObject
    The value to be evaluated for numeric type.

.EXAMPLE
    IsNumeric -InputObject "123"
    Returns $true because "123" is a numeric value.

.EXAMPLE
    IsNumeric -InputObject "abc"
    Returns $false because "abc" is not a numeric value.

.NOTES
    Useful for validating user input or parsing data where numeric values are
    expected.
#>
function IsNumeric {
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        [string]
        $InputObject
    )
    if ($null -eq $InputObject) {
        return $false
    }
    return [int]::TryParse($InputObject, [ref]$null)
}

<#
.SYNOPSIS
    Determines whether a given number falls within a specified range.

.DESCRIPTION
    The IsNumberInRange function checks if the provided number is greater than
    or equal to the minimum value and less than or equal to the maximum value.

.PARAMETER Value
    The number to be evaluated.

.PARAMETER Min
    The minimum value of the range.

.PARAMETER Max
    The maximum value of the range.

.EXAMPLE
    IsNumberInRange -Value 5 -Min 1 -Max 10
    Returns $true because 5 is within the range 1 to 10.

.NOTES
    Returns $true if the number is within the range, otherwise returns $false.
#>
function IsNumberInRange {
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param (
        # The minimum value of the range.
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNull()]
        [int]
        $Min,
        # The maximum value of the range.
        [Parameter(Mandatory, Position = 1)]
        [int]
        $Max,
        # The number to be evaluated
        [Parameter(Mandatory, Position = 2)]
        [int]
        $Value
    )
    return $Value -le $Max -and $Value -ge $Min
}