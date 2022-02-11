#--------------------------------------------------------------------------------#
# Show-BinanceCurrentTrade                                                       #
#--------------------------------------------------------------------------------#
function Show-BinanceCurrentTrade
{
    param(
        [Parameter(Mandatory=$true)][pscustomobject]$CurrentPosition,
        [Parameter(Mandatory=$true)][string]$Format # Table or Wide
    )

    # Write Position Summary
    if ($Format -eq "Wide")
    {
        Write-Host "$($CurrentPosition.Date) | Exit Strategy: $($CurrentPosition.Strategy) - Current Price: " -NoNewline

        if ($CurrentPosition.PriceMove -eq 0)
        {
            Write-Host "$($CurrentPosition.CurrentPrice) $($CurrentPosition.QuoteAsset) ($($CurrentPosition.PriceMove) $($CurrentPosition.QuoteAsset)) " -ForegroundColor Gray -NoNewline
        }
            elseif ($CurrentPosition.PriceMove -gt 0)
            {
                Write-Host "$($CurrentPosition.CurrentPrice) $($CurrentPosition.QuoteAsset) ($($CurrentPosition.PriceMove) $($CurrentPosition.QuoteAsset)) " -ForegroundColor Green -NoNewline
            }
                else
                {
                    Write-Host "$($CurrentPosition.CurrentPrice) $($CurrentPosition.QuoteAsset) ($($CurrentPosition.PriceMove) $($CurrentPosition.QuoteAsset)) " -ForegroundColor Magenta -NoNewline
                }
        
        Write-Host "Entry Price (Inc Fees): $($CurrentPosition.EntryPriceIncFees) $($CurrentPosition.QuoteAsset) " -ForegroundColor Gray -NoNewline
        Write-Host "Low Sell Price: $($CurrentPosition.LowerQuotePrice) $($CurrentPosition.QuoteAsset) ($($CurrentPosition.LowerQuotePriceGap) $($CurrentPosition.QuoteAsset)) " -ForegroundColor Yellow -NoNewline
        Write-Host "High Sell Price: $($CurrentPosition.UpperQuotePrice) $($CurrentPosition.QuoteAsset) ($($CurrentPosition.UpperQuotePriceGap) $($CurrentPosition.QuoteAsset)) " -ForegroundColor Cyan -NoNewline

        Write-Host "Profit: " -NoNewline

        if ($CurrentPosition.Profit -eq 0)
        {
            Write-Host "$($CurrentPosition.Profit) $($CurrentPosition.QuoteAsset)" -ForegroundColor Gray
        }
            elseif ($CurrentPosition.Profit - $CurrentPosition.LastProfit -gt 0)
            {
                Write-Host "$($CurrentPosition.Profit) $($CurrentPosition.QuoteAsset)" -ForegroundColor Green
            }
                else
                {
                    Write-Host "$($CurrentPosition.Profit) $($CurrentPosition.QuoteAsset)" -ForegroundColor Magenta
                }
    }
    elseif ($Format -eq "Table")
    {
        CLS
        Write-Host "##################### TRADE DETAILS #####################" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Date                  : $($CurrentPosition.Date)"
        
        if ($CurrentPosition.Strategy -eq "Min\Max Profit")
        {
            Write-Host "Exit Strategy         : $($CurrentPosition.Strategy) ($($CurrentPosition.ProfitLow) / $($CurrentPosition.ProfitHigh))"
        }
        else
        {
            Write-Host "Exit Strategy         : $($CurrentPosition.Strategy)"
        }
        
        Write-Host "Market                : $($CurrentPosition.Market)"
        Write-Host "Quantity              : $($CurrentPosition.Quantity)"

        Write-Host "Entry Price           : " -NoNewline
        Write-Host "$($CurrentPosition.EntryPrice) $($CurrentPosition.QuoteAsset)"

        Write-Host "Entry Price (Inc Fees): " -NoNewline
        Write-Host "$($CurrentPosition.EntryPriceIncFees) $($CurrentPosition.QuoteAsset)"

        Write-Host "Current Price         : " -NoNewline
        if ($CurrentPosition.PriceMove -eq 0)
        {
            Write-Host "$($CurrentPosition.CurrentPrice) $($CurrentPosition.QuoteAsset) ($($CurrentPosition.PriceMove) $($CurrentPosition.QuoteAsset))" -ForegroundColor Gray
        }
            elseif ($CurrentPosition.PriceMove -gt 0)
            {
                Write-Host "$($CurrentPosition.CurrentPrice) $($CurrentPosition.QuoteAsset) ($($CurrentPosition.PriceMove) $($CurrentPosition.QuoteAsset))" -ForegroundColor Green
            }
                else
                {
                    Write-Host "$($CurrentPosition.CurrentPrice) $($CurrentPosition.QuoteAsset) ($($CurrentPosition.PriceMove) $($CurrentPosition.QuoteAsset))" -ForegroundColor Magenta
                }

        Write-Host "Low Sell Price        : " -NoNewline
        Write-Host "$($CurrentPosition.LowerQuotePrice) $($CurrentPosition.QuoteAsset) ($($CurrentPosition.LowerQuotePriceGap) $($CurrentPosition.QuoteAsset))" -ForegroundColor Yellow

        Write-Host "High Sell Price       : " -NoNewline
        Write-Host "$($CurrentPosition.UpperQuotePrice) $($CurrentPosition.QuoteAsset) ($($CurrentPosition.UpperQuotePriceGap) $($CurrentPosition.QuoteAsset))" -ForegroundColor Cyan

        Write-Host "Profit                : " -NoNewline

        if ($CurrentPosition.Profit -eq 0)
        {
            Write-Host "$($CurrentPosition.Profit) $($CurrentPosition.QuoteAsset) " -ForegroundColor Gray -NoNewline
        }
            elseif ($CurrentPosition.Profit -gt 0)
            {
                Write-Host "$($CurrentPosition.Profit) $($CurrentPosition.QuoteAsset) " -ForegroundColor Green -NoNewline
            }
                else
                {
                    Write-Host "$($CurrentPosition.Profit) $($CurrentPosition.QuoteAsset) " -ForegroundColor Magenta -NoNewline
                }

        if ($CurrentPosition.ProfitMove -eq 0)
        {
            Write-Host "($($CurrentPosition.ProfitMove) $($CurrentPosition.QuoteAsset))" -ForegroundColor Gray -NoNewline
        }
            elseif ($CurrentPosition.ProfitMove -gt 0)
            {
                Write-Host "($($CurrentPosition.ProfitMove) $($CurrentPosition.QuoteAsset))" -ForegroundColor Green -NoNewline
            }
                else
                {
                    Write-Host "($($CurrentPosition.ProfitMove) $($CurrentPosition.QuoteAsset))" -ForegroundColor Magenta -NoNewline
                }
    }
}