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

$Command = $args[0]
$Arguments = $args[1..($args.Length)]

if ($args.Length -ge 2)
{
  if (!(Test-Path $LIBEXEC_DIR\wake-$args[0]-$args[1]))
  {
    $Command = $args[0] + "-" + $args[1]
    if ($args.Length -eq 2)
    {
      $Arguments = @()
    }
    else
    {
      $Arguments = $args[2..($args.Length)]
    }
  }
}

if (!(Test-Path $LIBEXEC_DIR\wake-$Command))
{
  Throw "Incorrect command"
}

# Start Wake
Invoke-Expression "$RUBY $LIBEXEC_DIR\wake-$Command $args"
Write-Host
exit $LASTEXITCODE
