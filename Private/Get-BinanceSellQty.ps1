#--------------------------------------------------------------------------------#
# Get-BinanceSellQty                                                             #
#--------------------------------------------------------------------------------#
function Get-BinanceSellQty
{
    param(
        [Parameter(Mandatory=$false)]$Token,
        [Parameter(Mandatory=$false)]$SellPercentage = 100,
        [Parameter(Mandatory=$false)][switch]$RefreshAccountInfo = $false
    )
    
    if ($RefreshAccountInfo)
    {
        if ($ExchangeInfo -eq $null) { Get-BinanceExchangeInfo }
        Get-BinanceAccountInfo
    }
    else
    {
        if ($ExchangeInfo -eq $null) { Get-BinanceExchangeInfo }
        if ($AccInfo      -eq $null) { Get-BinanceAccountInfo  }
    }
    
    $Market = Get-BinanceStableCoinMarket -Token $Token

    $MarketIndex = $ExchangeInfo.symbols.symbol.IndexOf($Market)
    $LotSizeIndex = $ExchangeInfo.symbols[$MarketIndex].filters.filterType.IndexOf('LOT_SIZE')
    $MinQty = $ExchangeInfo.symbols[$MarketIndex].filters[$LotSizeIndex].minqty

    $OwnedQty = [decimal]($AccInfo.balances[$AccInfo.balances.asset.IndexOf($Token)]).free
    $SellQty = ([math]::floor((($OwnedQty / 100) * $SellPercentage) / $MinQty)) * $MinQty

    return $SellQty
}