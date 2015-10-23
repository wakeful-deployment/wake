$LIBEXEC_DIR = Join-Path $PSScriptRoot "..\libexec"

# Is Ruby installed?
$RUBY = $(Get-Command Ruby -ErrorAction SilentlyContinue).Source

if (!(Test-Path $RUBY))
{
  Throw "Error: Ruby.exe is not installed!"
}

$env:WAKE_ROOT=$LIBEXEC_DIR

if ($args.Length -eq 0)
{
  Throw "No arguments"
}

Write-Host $Command
Write-Host $Arguments

if (!(Test-Path $LIBEXEC_DIR\wake-$Command))
{
  Throw "Incorrect command"
}

# Start Wake
Invoke-Expression "$RUBY $LIBEXEC_DIR\wake-$Command $args"
Write-Host
exit $LASTEXITCODE
