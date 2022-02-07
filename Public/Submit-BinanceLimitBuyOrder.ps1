#--------------------------------------------------------------------------------#
# Submit-BinanceLimitBuyOrder                                                    #
#--------------------------------------------------------------------------------#
function Submit-BinanceLimitBuyOrder
{
    param(
        [Parameter(Mandatory=$false)]$Market,
        [Parameter(Mandatory=$false)]$Quantity,
        [Parameter(Mandatory=$false)]$Price,
        [Parameter(Mandatory=$false)][switch]$WaitForCompletion = $false,
        [Parameter(Mandatory=$false)][switch]$TestMode = $false
    )

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
        
    $BuyQty = Set-BinanceQtyPrecision -Market $Market -BuyQty $Quantity
    $QueryString = Get-BinanceSignedQueryString -Param1 "symbol=$Market" -Param2 "side=BUY" -Param3 "type=LIMIT" -Param4 "timeInForce=GTC" -Param5 "quantity=$BuyQty" -Param6 "price=$Price" -Param7 "recvWindow=5000"

    Test-BinanceOrderParameters -Market $Market -Price $Price -Quantity $BuyQty -Type "LIMIT"

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