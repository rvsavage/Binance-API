#--------------------------------------------------------------------------------#
# Get-BinanceCandleData                                                          #
#--------------------------------------------------------------------------------#
function Get-BinanceCandleData
{
    param(
        [Parameter(Mandatory=$false)]$CandleStart,
        [Parameter(Mandatory=$false)]$CandleEnd,
        [Parameter(Mandatory=$false)]$Symbol,
        [Parameter(Mandatory=$false)]$Interval,
        [Parameter(Mandatory=$false)]$SleepTimeSecs = 0
    )

    $startTime = ([long](Get-Date -Date ($CandleStart) -UFormat %s) * 1000)
    $endTime = ([long](Get-Date -Date ($CandleEnd) -UFormat %s) * 1000)

    $TimestampOrigin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0

    $CandleData = @()
    While ($startTime -le $endTime)
    {
        $Candles = Submit-BinanceAPIRequest -Uri "https://api.binance.com/api/v3/klines?symbol=$Symbol&interval=$Interval&limit=1000&startTime=$startTime" -Method Get
        
        $TimestampOrigin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0

        foreach ($Candle in $Candles)
        {
            $obj = [PSCustomObject]@{
                OpenTime = Get-Date -date ($TimestampOrigin.AddSeconds(($Candle[0]/1000))).ToString("yyyy-MM-dd HH:mm:ss")
                Open = [decimal]$Candle[1]
                High = [decimal]$Candle[2]
                Low = [decimal]$Candle[3]
                Close = [decimal]$Candle[4]
                Volume = [decimal]$Candle[5]
                CloseTime = Get-Date -date ($TimestampOrigin.AddSeconds(($Candle[6]/1000))).ToString("yyyy-MM-dd HH:mm:ss")
                QuoteAssetVolume = [decimal]$Candle[7]
                NumberOfTrades = [long]$Candle[8]
                TakerBuyBaseAssetVolume = [decimal]$Candle[9]
                TakerBuyQuoteAssetVolume = [decimal]$Candle[10]
            }
        
            if  ((Get-Date -Date ($obj.OpenTime)) -le (Get-Date -Date ($CandleEnd)))
            {
                $CandleData += $obj
            }
        }

        $CandleStart = Get-Date -date ($TimestampOrigin.AddSeconds(($Candle[0]/1000))).ToString("yyyy-MM-dd HH:mm:ss")
        $CandleStart = $CandleStart.AddMinutes(1)
        $startTime = ([long](Get-Date -Date ($CandleStart) -UFormat %s) * 1000)

        Write-Host "$CandleStart >" (Get-Date -Date $CandleEnd)

        SLEEP $SleepTimeSecs
    }

    return $CandleData
}