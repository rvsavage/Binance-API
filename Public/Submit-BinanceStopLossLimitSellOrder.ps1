#--------------------------------------------------------------------------------#
# Submit-BinanceStopLossLimitSellOrder                                           #
#--------------------------------------------------------------------------------#
function Submit-BinanceStopLossLimitSellOrder
{
    param(
        [Parameter(Mandatory=$false)]$Market,
        [Parameter(Mandatory=$false)]$Quantity,
        [Parameter(Mandatory=$false)]$SellPercentage,
        [Parameter(Mandatory=$false)][decimal]$StopPrice,
        [Parameter(Mandatory=$false)][decimal]$Price,
        [Parameter(Mandatory=$false)][switch]$WaitForCompletion = $false,
        [Parameter(Mandatory=$false)][switch]$TestMode = $false
    )

    $ParamCount = 0
    if (-not([string]::IsNullOrEmpty($Quantity))) { $ParamCount = $ParamCount + 1 }
    if (-not([string]::IsNullOrEmpty($SellPercentage))) { $ParamCount = $ParamCount + 1 }
    
    if ($ParamCount -eq 0)
    {
        Write-Host "Error: You need to provide a value for either 'Quantity' or 'SellPercentage'. They both appear to be missing." -ForegroundColor Magenta
        return
    }

    if ($ParamCount -gt 1)
    {
        Write-Host "Error: You need to provide a value for either 'Quantity' or 'SellPercentage', not both." -ForegroundColor Magenta
        return
    }

    if ($StopPrice -le $Price)
    {
        Write-Host "Error: The StopPrice should be higher than the Price. It is the StopPrice that will trigger the sale at the supplied Price." -ForegroundColor Magenta
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
        $QueryString = Get-BinanceSignedQueryString -Param1 "symbol=$Market" -Param2 "side=SELL" -Param3 "type=STOP_LOSS_LIMIT" -Param4 "timeInForce=GTC" -Param5 "quantity=$SellQty" -Param6 "stopPrice=$StopPrice" -Param7 "price=$Price" -Param8 "recvWindow=5000"
    }

    if (-not([string]::IsNullOrEmpty($SellPercentage)))
    {
        $BaseAsset = $ExchangeInfo.symbols[$ExchangeInfo.symbols.symbol.IndexOf($Market)].baseAsset
        $SellQty = Get-BinanceSellQty -Token $BaseAsset -SellPercentage $SellPercentage -RefreshAccountInfo
        $QueryString = Get-BinanceSignedQueryString -Param1 "symbol=$Market" -Param2 "side=SELL" -Param3 "type=STOP_LOSS_LIMIT" -Param4 "timeInForce=GTC" -Param5 "quantity=$SellQty" -Param6 "stopPrice=$StopPrice" -Param7 "price=$Price" -Param8 "recvWindow=5000"
    }
    
    $Signature = Get-BinanceAPISignature -QueryString $QueryString -EndPoint $EndPoint
    $uri = "https://api.binance.com$($EndPoint)?$QueryString&signature=$signature"

    Test-BinanceOrderParameters -Market $Market -Price $Price -Quantity $SellQty -Type "STOP_LOSS_LIMIT"

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