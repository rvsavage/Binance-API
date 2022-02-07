#--------------------------------------------------------------------------------#
# Submit-BinanceMarketSellOrder                                                  #
#--------------------------------------------------------------------------------#
function Submit-BinanceMarketSellOrder
{
    param(
        [Parameter(Mandatory=$false)]$Market,
        [Parameter(Mandatory=$false)]$Quantity,
        [Parameter(Mandatory=$false)]$QuoteOrderQty,
        [Parameter(Mandatory=$false)]$SellPercentage,
        [Parameter(Mandatory=$false)][switch]$WaitForCompletion = $false,
        [Parameter(Mandatory=$false)][switch]$TestMode = $false
    )

    $ParamCount = 0
    if (-not([string]::IsNullOrEmpty($Quantity))) { $ParamCount = $ParamCount + 1 }
    if (-not([string]::IsNullOrEmpty($QuoteOrderQty))) { $ParamCount = $ParamCount + 1 }
    if (-not([string]::IsNullOrEmpty($SellPercentage))) { $ParamCount = $ParamCount + 1 }
    
    if ($ParamCount -eq 0)
    {
        Write-Host "Error: You need to provide a value for either 'Quantity', 'QuoteOrderQty' or 'SellPercentage'. They all appear to be missing." -ForegroundColor Magenta
        return
    }

    if ($ParamCount -gt 1)
    {
        Write-Host "Error: You need to provide a value for either 'Quantity', 'QuoteOrderQty' or 'SellPercentage'. More than one has been provided." -ForegroundColor Magenta
        return
    }

    if ([string]::IsNullOrEmpty($env:Binance_Key))
    {
        Write-Host "Error: The environmental variable 'Binance_Key' has not been set." -ForegroundColor Magenta
        return 1
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
        
    if (-not([string]::IsNullOrEmpty($Quantity)))
    {
        $SellQty = Set-BinanceQtyPrecision -Market $Market -BuyQty $Quantity
        $QueryString = Get-BinanceSignedQueryString -Param1 "symbol=$Market" -Param2 "side=SELL" -Param3 "type=MARKET" -Param4 "quantity=$SellQty" -Param5 "recvWindow=5000"
        Test-BinanceOrderParameters -Market $Market -Quantity $SellQty -Type "MARKET"
    }

    if (-not([string]::IsNullOrEmpty($QuoteOrderQty)))
    {
        $QueryString = Get-BinanceSignedQueryString -Param1 "symbol=$Market" -Param2 "side=SELL" -Param3 "type=MARKET" -Param4 "quoteOrderQty=$QuoteOrderQty" -Param5 "recvWindow=5000"
    }
        
    if (-not([string]::IsNullOrEmpty($SellPercentage)))
    {
        if ($ExchangeInfo -eq $null) { Get-BinanceExchangeInfo }
        $BaseAsset = $ExchangeInfo.symbols[$ExchangeInfo.symbols.symbol.IndexOf($Market)].baseAsset
        $SellQty = Get-BinanceSellQty -Token $BaseAsset -SellPercentage $SellPercentage -RefreshAccountInfo
        $QueryString = Get-BinanceSignedQueryString -Param1 "symbol=$Market" -Param2 "side=SELL" -Param3 "type=MARKET" -Param4 "quantity=$SellQty" -Param5 "recvWindow=5000"
        Test-BinanceOrderParameters -Market $Market -Quantity $SellQty -Type "MARKET"
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