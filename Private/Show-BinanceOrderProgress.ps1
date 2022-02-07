#--------------------------------------------------------------------------------#
# Show-BinanceOrderProgress                                                      #
#--------------------------------------------------------------------------------#
function Show-BinanceOrderProgress
{
    param(
        [Parameter(Mandatory=$false)]$Market,
        [Parameter(Mandatory=$false)]$OrderId,
        [Parameter(Mandatory=$false)]$PollingInterval = 5
    )

    $Order = Show-BinanceOrder -Market $Market -OrderId $OrderId

    $Market = $Order.symbol
    $RequestedQty = $Order.origQty
    $Filled = $Order.executedQty
    $Type = $Order.type
    $Side = $Order.side
    $Price = $Order.price
    $Status = $Order.status

    $FillPercent = 0

    $BaseAsset = $ExchangeInfo.symbols[$ExchangeInfo.symbols.symbol.IndexOf($Market)].baseAsset
    $QuoteAsset = $ExchangeInfo.symbols[$ExchangeInfo.symbols.symbol.IndexOf($Market)].quoteAsset

    if ($Type -eq "LIMIT")
    {
        if ($Side -eq "SELL")
        {
            $Activity = "$((Get-Culture).TextInfo.ToTitleCase($Type.ToLower())) $((Get-Culture).TextInfo.ToTitleCase($Side.ToLower())) order of $RequestedQty $BaseAsset on the $Market market at $Price $QuoteAsset"
        }
        else
        {
            $Activity = "$((Get-Culture).TextInfo.ToTitleCase($Type.ToLower())) $((Get-Culture).TextInfo.ToTitleCase($Side.ToLower())) order for $RequestedQty $BaseAsset on the $Market market at $Price $QuoteAsset"
        }
        
    }
    else
    {
        if ($Side -eq "SELL")
        {
            $Activity = "$((Get-Culture).TextInfo.ToTitleCase($Type.ToLower())) $((Get-Culture).TextInfo.ToTitleCase($Side.ToLower())) order of $RequestedQty $BaseAsset on the $Market market"
        }
        else
        {
            $Activity = "$((Get-Culture).TextInfo.ToTitleCase($Type.ToLower())) $((Get-Culture).TextInfo.ToTitleCase($Side.ToLower())) order for $RequestedQty $BaseAsset on the $Market market"
        }
    }
    
    $CompletedStatus = @("FILLED","CANCELED","REJECTED","EXPIRED")

    if ($CompletedStatus.IndexOf($Status) -eq -1)
    {
        WHILE ($CompletedStatus.IndexOf($Status) -eq -1)
        {
            $FillPercent = ([math]::floor(((100 / $RequestedQty) * $Filled) / 1)) * 1
            Write-Progress -Activity $Activity -PercentComplete $FillPercent -Id 1 -Status "Waiting for order to fill" -CurrentOperation "$Filled Filled : ($FillPercent% Complete)"
            SLEEP $PollingInterval
            $Order = Show-BinanceOrder -Market $Market -OrderId $OrderId
            $Filled = $Order.executedQty
            $Status = $Order.status
        }
    }

    Write-Host "INFO: The order completed with a status of $Status." -ForegroundColor Green
    $Order
}