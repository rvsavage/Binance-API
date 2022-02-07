#--------------------------------------------------------------------------------#
# Get-BinanceBalances                                                            #
#--------------------------------------------------------------------------------#
function Get-BinanceBalances
{
    param(
        [Parameter(Mandatory=$false)][switch]$RefreshAccountInfo = $false
    )
    
    if ($RefreshAccountInfo)
    {
        Get-BinanceAccountInfo
    }
    else
    {
        if ($AccInfo -eq $null) { Get-BinanceAccountInfo }
    }
    
    $StableCoins = @('USDC','USDT','BUSD','DAI','LDUSDC','LDUSDT','LDBUSD','LDDAI')
    $Prices = Get-BinanceCurrentPrices

    foreach ($Balance in $AccInfo.balances)
    {
        if ([decimal]$Balance.free -gt 0)
        {
            if ($StableCoins.IndexOf($Balance.asset) -eq -1)
            {
                $PreferedMarket = (Get-BinanceStableCoinMarket -Token $Balance.asset)
                $Balance | Add-Member -Name "PreferedMarket" -MemberType NoteProperty -Value $PreferedMarket -Force
                
                if (-not([string]::IsNullOrEmpty($PreferedMarket)))
                {
                    $CurrentPrice = ([math]::floor(($Prices[$Prices.Market.IndexOf($PreferedMarket)].Price) / 0.01) * 0.01)
                    $Balance | Add-Member -Name "CurrentPrice" -MemberType NoteProperty -Value $CurrentPrice -Force
                    $Balance | Add-Member -Name "CurrentValue" -MemberType NoteProperty -Value ([math]::floor(([decimal]$Balance.free * $CurrentPrice) / 0.01) * 0.01) -Force
                }
            }
            
            $Balance
        }
    }
}