#--------------------------------------------------------------------------------#
# Submit-BinanceTradingStrategy                                                  #
#--------------------------------------------------------------------------------#
function Submit-BinanceTradingStrategy
{
    param(
        [Parameter(Mandatory=$true)][string]$Market,
        [Parameter(Mandatory=$false)][long]$ExistingOrderId,
        [Parameter(Mandatory=$false)][Decimal]$EntryPrice,
        [Parameter(Mandatory=$false)][Decimal]$Quantity,
        [Parameter(Mandatory=$false)][Decimal]$LowerQuotePrice,
        [Parameter(Mandatory=$false)][Decimal]$UpperQuotePrice,
        [Parameter(Mandatory=$false)][Decimal]$ProfitLow,
        [Parameter(Mandatory=$false)][Decimal]$ProfitHigh,
        [Parameter(Mandatory=$false)][switch]$Simulation,
        [Parameter(Mandatory=$false)][string]$Format = "Table",
        [Parameter(Mandatory=$false)][decimal]$FeePercentage = 0.08
    )
    
    $OrderDetailsParamBit = 0
    if ($ExistingOrderId -ne 0) { $OrderDetailsParamBit = $OrderDetailsParamBit + 1 }
    if ($EntryPrice      -ne 0) { $OrderDetailsParamBit = $OrderDetailsParamBit + 2 }
    if ($Quantity        -ne 0) { $OrderDetailsParamBit = $OrderDetailsParamBit + 4 }
    
    if ($OrderDetailsParamBit -ne 1 -and $OrderDetailsParamBit -ne 6)
    {
        Write-Host "Error: You need to provide a value for either 'ExistingOrderId' only, or both 'EntryPrice' and 'Quantity'." -ForegroundColor Magenta
        return
    }
        
    $StrategyParamBit = 0
    if ($LowerQuotePrice -ne 0) { $StrategyParamBit = $StrategyParamBit + 1 }
    if ($UpperQuotePrice -ne 0) { $StrategyParamBit = $StrategyParamBit + 2 }
    if ($ProfitLow  -ne 0) { $StrategyParamBit = $StrategyParamBit + 4 }
    if ($ProfitHigh -ne 0) { $StrategyParamBit = $StrategyParamBit + 8 }
    
    if ($StrategyParamBit -ne 3 -and $StrategyParamBit -ne 12)
    {
        Write-Host "Error: You need to provide a value for either 'LowerQuotePrice' and 'UpperQuotePrice', or 'ProfitLow' and 'ProfitHigh'." -ForegroundColor Magenta
        return
    }

    if ($OrderDetailsParamBit -eq 1)
    {
        $Trade = Show-BinanceOrder -Market $Market -OrderId $ExistingOrderId
        $EntryPrice = $Trade.cummulativeQuoteQty / $Trade.executedQty
        $Quantity = $Trade.executedQty
    }

    if ($ExchangeInfo -eq $null) { Get-BinanceExchangeInfo }

    $Filters = $ExchangeInfo.symbols[$ExchangeInfo.symbols.symbol.IndexOf($Market)].filters

    if ($CurrentPosition.QuoteAssetPrecision -eq 1) {$Rounding = 0}
    elseif ($CurrentPosition.QuoteAssetPrecision -eq 0.1) {$Rounding = 1}
    elseif ($CurrentPosition.QuoteAssetPrecision -eq 0.01) {$Rounding = 2}
    elseif ($CurrentPosition.QuoteAssetPrecision -eq 0.001) {$Rounding = 3}
    elseif ($CurrentPosition.QuoteAssetPrecision -eq 0.0001) {$Rounding = 4}
    elseif ($CurrentPosition.QuoteAssetPrecision -eq 0.00001) {$Rounding = 5}
    elseif ($CurrentPosition.QuoteAssetPrecision -eq 0.000001) {$Rounding = 6}
    elseif ($CurrentPosition.QuoteAssetPrecision -eq 0.0000001) {$Rounding = 7}
    elseif ($CurrentPosition.QuoteAssetPrecision -eq 0.00000001) {$Rounding = 8}
    else {$Rounding = 2}

    $InTrade = $true
    $PositionData = @()

    WHILE ($InTrade)
    {
        [Decimal]$CurrentPrice = (Get-BinanceCurrentPrices -Market $Market).Price
        [Decimal]$Fees = ($EntryPrice * ($FeePercentage / 100) * $Quantity) + ($CurrentPrice * ($FeePercentage / 100) * $Quantity)
        [Decimal]$Profit = (($CurrentPrice - $EntryPrice) * $Quantity) - $Fees
        
        if ($StrategyParamBit -eq 3)
        {
            $ExitStrategy = "High\Low Price"
        }
        
        if ($StrategyParamBit -eq 12)
        {
            $ExitStrategy = "Min\Max Profit"
            $LowerQuotePrice = $EntryPrice + ($Fees / $Quantity) + ($ProfitLow / $Quantity)
            $UpperQuotePrice = $EntryPrice + ($Fees / $Quantity) + ($ProfitHigh / $Quantity)
        }

        $obj = [PSCustomObject]@{
            Date = Get-Date
            Market = $Market
            BaseAsset = $ExchangeInfo.symbols[$ExchangeInfo.symbols.symbol.IndexOf($Market)].baseAsset
            QuoteAsset = $ExchangeInfo.symbols[$ExchangeInfo.symbols.symbol.IndexOf($Market)].quoteAsset
            QuoteAssetPrecision = [decimal]$Filters[$Filters.filterType.IndexOf("PRICE_FILTER")].minPrice
            Strategy = $ExitStrategy
            CurrentPrice = [math]::Round($CurrentPrice,$Rounding)
            LastPrice = [math]::Round($LastPrice,$Rounding)
            PriceMove = [math]::Round($CurrentPrice - $LastPrice,$Rounding)
            EntryPrice = [math]::Round($EntryPrice,$Rounding)
            EntryPriceIncFees = [math]::Round($EntryPrice + ($Fees/$Quantity),$Rounding)
            LowerQuotePrice = [math]::Round($LowerQuotePrice,$Rounding)
            Quantity = $Quantity
            ProfitLow = $ProfitLow
            ProfitHigh = $ProfitHigh
            LowerQuotePriceGap = [math]::Round($CurrentPrice - $LowerQuotePrice,$Rounding)
            UpperQuotePrice = [math]::Round($UpperQuotePrice,$Rounding)
            UpperQuotePriceGap = [math]::Round($UpperQuotePrice - $CurrentPrice,$Rounding)
            Profit = [math]::Round($Profit,$Rounding)
            LastProfit = [math]::Round($LastProfit,$Rounding)
            ProfitMove = [math]::Round($Profit,$Rounding) - [math]::Round($LastProfit,$Rounding)
        }
        
        $PositionData += $obj
        $CurrentPosition = $PositionData[$PositionData.Count - 1]

        # Write Position Summary
        Show-BinanceCurrentTrade -CurrentPosition $CurrentPosition -Format $Format

        if (($CurrentPrice -le $LowerQuotePrice -or $CurrentPrice -ge $UpperQuotePrice) -and -not([string]::IsNullOrEmpty($CurrentPrice)))
        {
            if ($Simulation)
            {
                Write-Host "If this wasn't a simulation, a sell order would now be placed." -ForegroundColor Yellow
            }
            else
            {
                Submit-BinanceMarketSellOrder -Market $Market -Quantity $CurrentPosition.Quantity
                $InTrade = $false
            }
        }
    
        [Decimal]$LastPrice = $CurrentPrice
        [Decimal]$LastProfit = $Profit
        SLEEP 5
    }
}