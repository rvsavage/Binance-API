#--------------------------------------------------------------------------------#
# Get-BinanceExchangeInfo                                                        #
#--------------------------------------------------------------------------------#
function Get-BinanceExchangeInfo
{
    $EndPoint = "/api/v3/exchangeInfo"
    $QueryString = Get-BinanceUnsignedQueryString
    $uri = "https://api.binance.com$($EndPoint)?$($QueryString)"

    $global:ExchangeInfo = Submit-BinanceAPIRequest -Uri $uri -Method Get
}