#--------------------------------------------------------------------------------#
# Get-BinanceStableCoinMarket                                                    #
#--------------------------------------------------------------------------------#
function Get-BinanceStableCoinMarket
{
    param(
        [Parameter(Mandatory=$true)]$Token
    )

    if ($ExchangeInfo -eq $null) { Get-BinanceExchangeInfo }
    
    [System.Collections.ArrayList]$Markets = @()
    if (-not([string]::IsNullOrEmpty($ExchangeInfo.symbols.symbol -match "^$($Token)USDC")))
    {
        $Markets.Add($ExchangeInfo.symbols.symbol -match "^$($Token)USDC") > $null
    }
    if (-not([string]::IsNullOrEmpty($ExchangeInfo.symbols.symbol -match "^$($Token)USDT")))
    {
        $Markets.Add($ExchangeInfo.symbols.symbol -match "^$($Token)USDT") > $null
    }
    if (-not([string]::IsNullOrEmpty($ExchangeInfo.symbols.symbol -match "^$($Token)BUSD")))
    {
        $Markets.Add($ExchangeInfo.symbols.symbol -match "^$($Token)BUSD") > $null
    }
    if (-not([string]::IsNullOrEmpty($ExchangeInfo.symbols.symbol -match "^$($Token)DAI")))
    {
        $Markets.Add($ExchangeInfo.symbols.symbol -match "^$($Token)DAI") > $null
    }
    if (-not([string]::IsNullOrEmpty($ExchangeInfo.symbols.symbol -match "^$($Token)BTC")))
    {
        $Markets.Add($ExchangeInfo.symbols.symbol -match "^$($Token)BTC") > $null
    }
    if (-not([string]::IsNullOrEmpty($ExchangeInfo.symbols.symbol -match "^$($Token)ETH")))
    {
        $Markets.Add($ExchangeInfo.symbols.symbol -match "^$($Token)ETH") > $null
    }

    $Markets[0]
}