#--------------------------------------------------------------------------------#
# Get-BinanceAveragePrice                                                        #
#--------------------------------------------------------------------------------#
function Get-BinanceAveragePrice
{
    param(
        [Parameter(Mandatory=$true)]$Market
    )

    $PriceData = Submit-BinanceAPIRequest -Uri "https://api.binance.com/api/v3/avgPrice?symbol=$Market" -Method Get
    
    return $PriceData.price
}