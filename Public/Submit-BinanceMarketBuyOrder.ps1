#--------------------------------------------------------------------------------#
# Submit-BinanceMarketBuyOrder                                                   #
#--------------------------------------------------------------------------------#
function Submit-BinanceMarketBuyOrder
{
    param(
        [Parameter(Mandatory=$false)]$Market,
        [Parameter(Mandatory=$false)]$Quantity,
        [Parameter(Mandatory=$false)]$QuoteOrderQty,
        [Parameter(Mandatory=$false)][switch]$WaitForCompletion = $false,
        [Parameter(Mandatory=$false)][switch]$TestMode = $false
    )

    if ([string]::IsNullOrEmpty($Quantity) -and [string]::IsNullOrEmpty($QuoteOrderQty))
    {
        Write-Host "Error: You need to provide a value for either 'Quantity' or 'QuoteOrderQty'. They both appear to be missing." -ForegroundColor Magenta
        return
    }

    if ((-not([string]::IsNullOrEmpty($Quantity))) -and (-not([string]::IsNullOrEmpty($QuoteOrderQty))))
    {
        Write-Host "Error: You need to provide a value for either 'Quantity' or 'QuoteOrderQty', not both." -ForegroundColor Magenta
        return
    }

    if ([string]::IsNullOrEmpty($env:Binance_Key))
    {
        Write-Host "Error: The environmental variable 'Binance_Key' has not been set." -ForegroundColor Magenta
        return
    }

    $APIKey = $env:Binance_Key

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-MBX-APIKEY",$APIKey)

    if ($TestMode)
    {
        $EndPoint = "/api/v3/order/test"
    }
    else
    {
        $EndPoint = "/api/v3/order"
    }
        
    if ([string]::IsNullOrEmpty($QuoteOrderQty))
    {
        $BuyQty = Set-BinanceQtyPrecision -Market $Market -BuyQty $Quantity
        $QueryString = Get-BinanceSignedQueryString -Param1 "symbol=$Market" -Param2 "side=BUY" -Param3 "type=MARKET" -Param4 "quantity=$BuyQty" -Param5 "recvWindow=5000"
        Test-BinanceOrderParameters -Market $Market -Quantity $BuyQty -Type "MARKET"
    }
    else
    {
        $QueryString = Get-BinanceSignedQueryString -Param1 "symbol=$Market" -Param2 "side=BUY" -Param3 "type=MARKET" -Param4 "quoteOrderQty=$QuoteOrderQty" -Param5 "recvWindow=5000"
    }
        
    $Signature = Get-BinanceAPISignature -QueryString $QueryString -EndPoint $EndPoint
    $uri = "https://api.binance.com$($EndPoint)?$QueryString&signature=$signature"

    $Response = Submit-BinanceAPIRequest -Uri $uri -Headers $headers -Method Post

    if ($WaitForCompletion -and (-not($TestMode)))
    {
        Show-BinanceOrderProgress -Market $Response.symbol -OrderId $Response.orderId
    }
    else
    {
        return $Response
    }
}