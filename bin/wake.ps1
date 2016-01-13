$LIBEXEC_DIR = Join-Path $PSScriptRoot "..\libexec"

# Is Ruby installed?
$RUBY = $(Get-Command Ruby -ErrorAction SilentlyContinue).Source

if (!$RUBY -or !(Test-Path $RUBY))
{
  Throw "Error: Ruby.exe is not installed!"
}

$env:RUBY_EXE_PATH=$RUBY
$env:ISPOWERSHELL=1
$env:WAKE_ROOT=$LIBEXEC_DIR

if ($args.Length -eq 0)
{
  Throw "No arguments"
}

$Command = $args[0]
$Arguments = $args[1..($args.Length)]

if (!(Test-Path $LIBEXEC_DIR\wake-$Command))
{
  Throw "Incorrect command"
}

# Start Wake
Invoke-Expression "$RUBY $LIBEXEC_DIR\wake-$Command $Arguments"
Write-Host
exit $LASTEXITCODE
