#--------------------------------------------------------------------------------#
# Set-BinanceQtyPrecision                                                        #
#--------------------------------------------------------------------------------#
function Set-BinanceQtyPrecision
{
    param(
        [Parameter(Mandatory=$false)]$Market,
        [Parameter(Mandatory=$false)]$BuyQty
    )
    
    if ($ExchangeInfo -eq $null) { Get-BinanceExchangeInfo }
    if ($AccInfo      -eq $null) { Get-BinanceAccountInfo  }

    $MarketIndex = $ExchangeInfo.symbols.symbol.IndexOf($Market)
    $LotSizeIndex = $ExchangeInfo.symbols[$MarketIndex].filters.filterType.IndexOf('LOT_SIZE')
    $MinQty = $ExchangeInfo.symbols[$MarketIndex].filters[$LotSizeIndex].minqty

    return ([math]::floor($BuyQty / $MinQty)) * $MinQty
}