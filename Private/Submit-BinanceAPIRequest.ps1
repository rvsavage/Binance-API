#--------------------------------------------------------------------------------#
# Submit-BinanceAPIRequest                                                       #
#--------------------------------------------------------------------------------#
function Submit-BinanceAPIRequest
{
    param(
        [Parameter(Mandatory=$true)]$Uri,
        [Parameter(Mandatory=$true)]$Method,
        [Parameter(Mandatory=$false)]$Headers
    )
    
    if ([decimal]$UsedWeight1m -gt 1150 -and ((Get-Date) -le ([datetime](Get-Date($LastRequestTime).AddMinutes(1)))))
    {
        Write-Host "ERROR: The 'UsedWeight1m' is currently greater than 1150. Requests have been paused for 1 minute to avoid getting a ban."
        break
    }
    else
    {
        try
        {
            if ([string]::IsNullOrEmpty($Headers))
            {
                $WebRequest = Invoke-WebRequest -Uri $Uri -Method $Method
            }
            else
            {
                $WebRequest = Invoke-WebRequest -Uri $Uri -Headers $Headers -Method $Method
            }
        
            [decimal]$global:UsedWeight1m = $WebRequest.Headers.'x-mbx-used-weight-1m'
            [datetime]$global:LastRequestTime = Get-Date

            return $WebRequest.Content | ConvertFrom-Json
        }
        catch
        {
            $Exception = $_.Exception

            Write-Host "ERROR: $($Exception.Message)"
    
            if ($Exception.Response.StatusCode.value__ -eq 400)
            {
                $result = $_.Exception.Response.GetResponseStream();
                $reader = New-Object System.IO.StreamReader($result);
                $reader.BaseStream.Position = 0;
                $reader.DiscardBufferedData();
                $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
        
                Write-Host ""
                Write-Host "Binance Error:" -ForegroundColor Yellow
                Write-Host "  Error Code: $($responseBody.code)"
                Write-Host "  Message   : $($responseBody.msg)"
            }
    
            break
        }
    }
}