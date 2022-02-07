#--------------------------------------------------------------------------------#
# Get-BinanceAccountInfo                                                         #
#--------------------------------------------------------------------------------#
function Get-BinanceAccountInfo
{
    if ([string]::IsNullOrEmpty($env:Binance_Key))
    {
        Write-Host "Error: The environmental variable 'Binance_Key' has not been set." -ForegroundColor Magenta
        return 1
    }
    else
    {
        $APIKey = $env:Binance_Key

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("X-MBX-APIKEY",$APIKey)

        $EndPoint = "/api/v3/account"
        $QueryString = Get-BinanceSignedQueryString

        $Signature = Get-BinanceAPISignature -QueryString $QueryString -EndPoint $EndPoint
        $uri = "https://api.binance.com$($EndPoint)?$QueryString&signature=$signature"

        $global:AccInfo = Submit-BinanceAPIRequest -Uri $uri -Headers $headers -Method Get
    }
}