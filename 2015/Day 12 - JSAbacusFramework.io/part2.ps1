<#
Uh oh - the Accounting-Elves have realized that they double-counted everything
red.

Ignore any object (and all of its children) which has any property with the
value "red". Do this only for objects ({...}), not arrays ([...]).

- [1,2,3] still has a sum of 6.
- [1,{"c":"red","b":2},3] now has a sum of 4, because the middle object is
  ignored.
- {"d":"red","e":[1,2,3,4],"f":5} now has a sum of 0, because the entire
  structure is ignored.
- [1,"red",5] has a sum of 6, because "red" in an array has no effect.
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt" -Raw

# Parse the JSON into objects
$parsedJson = ConvertFrom-Json -InputObject $rawInput -AsHashtable

# Function that takes in a value of some (Hashtable, Array, String, Number) kind
# and processes it. Calls recursively until it hits a string (ignored) or a
# number. Any hashtables (objects) are checked if they contain a 'red' value.
# If they do, it and it's children are ignored and a sum of 0 is returned.

function SumJsonNumbers($node) {
    if ($node -is [hashtable]) {
        if ($node.Values -contains 'red') { return 0 }
        $sum = 0
        foreach ($value in $node.Values) {
            $sum += SumJsonNumbers $value
        }
        return $sum
    } elseif ($node -is [array]) {
        $sum = 0
        foreach ($item in $node) {
            $sum += SumJsonNumbers $item
        }
        return $sum
    } elseif ($node -is [int] -or $node -is [int64]) {
        return $node
    } else {
        return 0
    }
}

SumJsonNumbers $parsedJson
