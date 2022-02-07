#--------------------------------------------------------------------------------#
# Test-BinanceOrderParameters                                                    #
#--------------------------------------------------------------------------------#
function Test-BinanceOrderParameters
{
    param(
        [Parameter(Mandatory=$true)]$Market,
        [Parameter(Mandatory=$false)][Decimal]$Price,
        [Parameter(Mandatory=$true)][Decimal]$Quantity,
        [Parameter(Mandatory=$true)]$Type
    )

    if ($ExchangeInfo -eq $null) { Get-BinanceExchangeInfo }

    $Filters = $ExchangeInfo.symbols[$ExchangeInfo.symbols.symbol.IndexOf($Market)].filters

    [Decimal]$PRICE_FILTER_minPrice = $Filters[$Filters.filterType.IndexOf("PRICE_FILTER")].minPrice
    [Decimal]$PRICE_FILTER_maxPrice = $Filters[$Filters.filterType.IndexOf("PRICE_FILTER")].maxPrice
    [Decimal]$PRICE_FILTER_tickSize = $Filters[$Filters.filterType.IndexOf("PRICE_FILTER")].tickSize

    [Decimal]$PERCENT_PRICE_multiplierUp = $Filters[$Filters.filterType.IndexOf("PERCENT_PRICE")].multiplierUp
    [Decimal]$PERCENT_PRICE_multiplierDown = $Filters[$Filters.filterType.IndexOf("PERCENT_PRICE")].multiplierDown
    [Decimal]$PERCENT_PRICE_avgPriceMins = $Filters[$Filters.filterType.IndexOf("PERCENT_PRICE")].avgPriceMins

    [Decimal]$LOT_SIZE_minQty = $Filters[$Filters.filterType.IndexOf("LOT_SIZE")].minQty
    [Decimal]$LOT_SIZE_maxQty = $Filters[$Filters.filterType.IndexOf("LOT_SIZE")].maxQty
    [Decimal]$LOT_SIZE_stepSize = $Filters[$Filters.filterType.IndexOf("LOT_SIZE")].stepSize

    [Decimal]$MARKET_LOT_SIZE_minQty = $Filters[$Filters.filterType.IndexOf("MARKET_LOT_SIZE")].minQty
    [Decimal]$MARKET_LOT_SIZE_maxQty = $Filters[$Filters.filterType.IndexOf("MARKET_LOT_SIZE")].maxQty
    [Decimal]$MARKET_LOT_SIZE_stepSize = $Filters[$Filters.filterType.IndexOf("MARKET_LOT_SIZE")].stepSize

    [Decimal]$MIN_NOTIONAL_minNotional = $Filters[$Filters.filterType.IndexOf("MIN_NOTIONAL")].minNotional
    [Decimal]$MIN_NOTIONAL_applyToMarket = $Filters[$Filters.filterType.IndexOf("MIN_NOTIONAL")].applyToMarket
    [Decimal]$MIN_NOTIONAL_avgPriceMins = $Filters[$Filters.filterType.IndexOf("MIN_NOTIONAL")].avgPriceMins

    if ($Type -eq "LIMIT" -or $Type -eq "STOP_LOSS_LIMIT")
    {
        $PRICE_FILTER = "PRICE_FILTER:`r`n"
        [Decimal]$PRICE_FILTER_Failed = 0

        if ($PRICE_FILTER_minPrice -ne 0 -and -not($Price -ge $PRICE_FILTER_minPrice))
        {
            $PRICE_FILTER = $PRICE_FILTER + "  - The Price supplied is lower than the minimum price/stopPrice ($PRICE_FILTER_minPrice) allowed.`r`n"
            $PRICE_FILTER_Failed = 1
        }

        if ($PRICE_FILTER_maxPrice -ne 0 -and -not($Price -le $PRICE_FILTER_maxPrice))
        {
            $PRICE_FILTER = $PRICE_FILTER + "  - The Price supplied is greater than the maximum price/stopPrice ($PRICE_FILTER_maxPrice) allowed.`r`n"
            $PRICE_FILTER_Failed = 1
        }

        if ($PRICE_FILTER_tickSize -ne 0 -and -not(([math]::floor($Price / $PRICE_FILTER_minPrice)) * $PRICE_FILTER_tickSize -eq $Price))
        {
            $PRICE_FILTER = $PRICE_FILTER + "  - The decimal precision of the Price supplied does not match the tick size interval ($PRICE_FILTER_tickSize) allowed.`r`n"
            $PRICE_FILTER_Failed = 1
        }

        if ($PRICE_FILTER_Failed -ne 0)
        {
            Write-Host $PRICE_FILTER
        }

        $PERCENT_PRICE = "PERCENT_PRICE:`r`n"
        [Decimal]$PERCENT_PRICE_Failed = 0

        if ($PERCENT_PRICE_avgPriceMins -eq 0)
        {
            if ([string]::IsNullOrEmpty($CurrentPrice))
            {
                [Decimal]$CurrentPrice = (Get-BinanceCurrentPrices -Market $Market).Price
            }
            [Decimal]$WeightedAveragePrice = $CurrentPrice
        }
        else
        {
            if ([string]::IsNullOrEmpty($AveragePrice))
            {
                [Decimal]$AveragePrice = (Get-BinanceAveragePrice -Market $Market)
            }
            [Decimal]$WeightedAveragePrice = $AveragePrice
        }

        if (-not($Price -le ($WeightedAveragePrice * $PERCENT_PRICE_multiplierUp)))
        {
            $PERCENT_PRICE = $PERCENT_PRICE + "  - The Price supplied is greater than the valid range for a price based on the average of the previous trades.`r`n"
            $PERCENT_PRICE_Failed = 1
        }

        if (-not($Price -ge ($WeightedAveragePrice * $PERCENT_PRICE_multiplierDown)))
        {
            $PERCENT_PRICE = $PERCENT_PRICE + "  - The Price supplied is lower than the valid range for a price based on the average of the previous trades.`r`n"
            $PERCENT_PRICE_Failed = 1
        }

        if ($PERCENT_PRICE_Failed -ne 0)
        {
            Write-Host $PERCENT_PRICE
        }

        $LOT_SIZE = "LOT_SIZE:`r`n"
        [Decimal]$LOT_SIZE_Failed = 0

        if (-not($Quantity -ge $LOT_SIZE_minQty))
        {
            $LOT_SIZE = $LOT_SIZE + "  - The Quantity supplied is lower than the minimum Quantity ($LOT_SIZE_minQty) allowed.`r`n"
            $LOT_SIZE_Failed = 1
        }

        if (-not($Quantity -le $LOT_SIZE_maxQty))
        {
            $LOT_SIZE = $LOT_SIZE + "  - The Quantity supplied is greater than the maximum Quantity ($LOT_SIZE_maxQty) allowed.`r`n"
            $LOT_SIZE_Failed = 1
        }

        if (-not(([math]::floor($Quantity / $LOT_SIZE_stepSize)) * $LOT_SIZE_stepSize -eq $Quantity))
        {
            $LOT_SIZE = $LOT_SIZE + "  - The decimal precision of the Quantity supplied does not match the step size interval ($LOT_SIZE_stepSize) allowed.`r`n"
            $LOT_SIZE_Failed = 1
        }

        if ($LOT_SIZE_Failed -ne 0)
        {
            Write-Host $LOT_SIZE
        }
    }

    if ($Type -eq "MARKET" -or $Type -eq "STOP_LOSS")
    {
        $MARKET_LOT_SIZE = "MARKET_LOT_SIZE:`r`n"
        [Decimal]$MARKET_LOT_SIZE_Failed = 0

        if (-not($Quantity -ge $MARKET_LOT_SIZE_minQty))
        {
            $MARKET_LOT_SIZE = $MARKET_LOT_SIZE + "  - The Quantity supplied is lower than the minimum Quantity ($MARKET_LOT_SIZE_minQty) allowed.`r`n"
            $MARKET_LOT_SIZE_Failed = 1
        }

        if (-not($Quantity -le $MARKET_LOT_SIZE_maxQty))
        {
            $MARKET_LOT_SIZE = $MARKET_LOT_SIZE + "  - The Quantity supplied is greater than the maximum Quantity ($MARKET_LOT_SIZE_maxQty) allowed.`r`n"
            $MARKET_LOT_SIZE_Failed = 1
        }

        if ($MARKET_LOT_SIZE_stepSize -ne 0 -and -not(([math]::floor($Quantity / $MARKET_LOT_SIZE_stepSize)) * $MARKET_LOT_SIZE_stepSize -eq $Quantity))
        {
            $MARKET_LOT_SIZE = $MARKET_LOT_SIZE + "  - The decimal precision of the Quantity supplied does not match the step size interval ($MARKET_LOT_SIZE_stepSize) allowed.`r`n"
            $MARKET_LOT_SIZE_Failed = 1
        }

        if ($MARKET_LOT_SIZE_Failed -ne 0)
        {
            Write-Host $MARKET_LOT_SIZE
        }
    }

    $MIN_NOTIONAL = "MIN_NOTIONAL:`r`n"
    [Decimal]$MIN_NOTIONAL_Failed = 0

    if ($Type -eq "MARKET" -or $Type -eq "STOP_LOSS")
    {
        if ($MIN_NOTIONAL_avgPriceMins -eq 0)
        {
            if ([string]::IsNullOrEmpty($CurrentPrice))
            {
                [Decimal]$CurrentPrice = (Get-BinanceCurrentPrices -Market $Market).Price
            }
            [Decimal]$Price = $CurrentPrice
        }
        else
        {
            if ([string]::IsNullOrEmpty($AveragePrice))
            {
                [Decimal]$AveragePrice = (Get-BinanceAveragePrice -Market $Market)
            }
            [Decimal]$Price = $AveragePrice
        }
    }

    if (-not(($Price * $Quantity) -ge $MIN_NOTIONAL_minNotional))
    {
        $MIN_NOTIONAL = $MIN_NOTIONAL + "  - The total order value ($($Price * $Quantity)) is less than minimum notional value ($MIN_NOTIONAL_minNotional) allowed.`r`n"
        if ((($Type -eq "MARKET" -or $Type -eq "STOP_LOSS") -and $MIN_NOTIONAL_applyToMarket -eq 1) -or ($Type -eq "LIMIT" -or $Type -eq "STOP_LOSS_LIMIT"))
        {
            $MIN_NOTIONAL_Failed = 1
        }
    }

    if ($MIN_NOTIONAL_Failed -ne 0)
    {
        Write-Host $MIN_NOTIONAL
    }

    if (($PRICE_FILTER_Failed + $PERCENT_PRICE_Failed + $LOT_SIZE_Failed + $MARKET_LOT_SIZE_Failed + $MIN_NOTIONAL_Failed) -gt 0)
    {
        break
    }
}