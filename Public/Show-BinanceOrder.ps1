#--------------------------------------------------------------------------------#
# Show-BinanceOrder                                                              #
#--------------------------------------------------------------------------------#
function Show-BinanceOrder
{
    param(
        [Parameter(Mandatory=$false)]$Market,
        [Parameter(Mandatory=$false)]$OrderId
    )

    if ([string]::IsNullOrEmpty($env:Binance_Key))
    {
        Write-Host "Error: The environmental variable 'Binance_Key' has not been set." -ForegroundColor Magenta
        break
    }
    
    $APIKey = $env:Binance_Key

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-MBX-APIKEY",$APIKey)

    $EndPoint = "/api/v3/order"
    $QueryString = Get-BinanceSignedQueryString -Param1 "symbol=$Market" -Param2 "orderId=$OrderId"

    $Signature = Get-BinanceAPISignature -QueryString $QueryString -EndPoint $EndPoint
    $uri = "https://api.binance.com$($EndPoint)?$QueryString&signature=$signature"

    return Submit-BinanceAPIRequest -Uri $uri -Headers $headers -Method Get
}