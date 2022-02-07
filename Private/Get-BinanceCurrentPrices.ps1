#--------------------------------------------------------------------------------#
# Get-BinanceCurrentPrices                                                       #
#--------------------------------------------------------------------------------#
function Get-BinanceCurrentPrices
{
    param(
        [Parameter(Mandatory=$false)]$Market
    )

    if ([string]::IsNullOrEmpty($Market))
    {
        $Prices = Submit-BinanceAPIRequest -Uri "https://api.binance.com/api/v3/ticker/price" -Method Get
    }
    else
    {
        $Prices = Submit-BinanceAPIRequest -Uri "https://api.binance.com/api/v3/ticker/price?symbol=$Market" -Method Get
    }
    
    $PriceData = @()

    foreach ($Price in $Prices)
    {
        $obj = [PSCustomObject]@{
            Market = $Price.symbol
            Price = [decimal]$Price.price
        }
        
        $PriceData += $obj        
    }

    return $PriceData
}