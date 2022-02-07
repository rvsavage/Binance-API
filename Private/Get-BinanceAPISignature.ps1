#--------------------------------------------------------------------------------#
# Get-BinanceAPISignature                                                        #
#--------------------------------------------------------------------------------#
function Get-BinanceAPISignature
{
    param(
        [Parameter(Mandatory=$true)]$QueryString,
        [Parameter(Mandatory=$true)]$EndPoint
    )
  
    if ([string]::IsNullOrEmpty($env:Binance_Secret))
    {
        Write-Host "Error: The environmental variable 'Binance_Secret' has not been set." -ForegroundColor Magenta
        return 1
    }
    else
    {
        $APISecret = $env:Binance_Secret

        $hmacsha     = New-Object System.Security.Cryptography.HMACSHA256
        $hmacsha.key = [Text.Encoding]::ASCII.GetBytes($APISecret)
        $signature   = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($QueryString))
        $signature   = [System.BitConverter]::ToString($signature).Replace('-', '').ToLower()

	    return $signature
    }
}