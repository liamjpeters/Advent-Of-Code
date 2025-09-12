# Advent of code

Advent of Code is an Advent calendar of small programming puzzles for a variety
of skill levels that can be solved in any programming language you like.

I have chosen to solve them in [PowerShell](https://github.com/PowerShell/PowerShell/).

## Modules

There are a collection of modules (developed while doing the AOC puzzle). They
hold common/shared code that can be used in any day.

## Day Template

Import the `AOC` module.

```powershell
Import-Module .\_modules\AOC
```

And run the `New-Day` command. It will prompt to pick a year, enter a day and
title, before creating the file structure for that day.

## Useful Websites

[RegExr](https://regexr.com/)