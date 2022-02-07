#--------------------------------------------------------------------------------#
# Get-BinanceSignedQueryString                                                   #
#--------------------------------------------------------------------------------#
function Get-BinanceSignedQueryString
{
    param(
        [Parameter(Mandatory=$false)]$Param1,
        [Parameter(Mandatory=$false)]$Param2,
        [Parameter(Mandatory=$false)]$Param3,
        [Parameter(Mandatory=$false)]$Param4,
        [Parameter(Mandatory=$false)]$Param5,
        [Parameter(Mandatory=$false)]$Param6,
        [Parameter(Mandatory=$false)]$Param7,
        [Parameter(Mandatory=$false)]$Param8,
        [Parameter(Mandatory=$false)]$Param9,
        [Parameter(Mandatory=$false)]$Param10
    )
   
    $EmptyParams = 1

    if (-not([string]::IsNullOrEmpty($Param1)))
    {
        $Param1 = "$Param1"
        $EmptyParams = 0
    }
    if (-not([string]::IsNullOrEmpty($Param2)))
    {
        $Param2 = "&$Param2"
        $EmptyParams = 0
    }
    if (-not([string]::IsNullOrEmpty($Param3)))
    {
        $Param3 = "&$Param3"
        $EmptyParams = 0
    }
    if (-not([string]::IsNullOrEmpty($Param4)))
    {
        $Param4 = "&$Param4"
        $EmptyParams = 0
    }
    if (-not([string]::IsNullOrEmpty($Param5)))
    {
        $Param5 = "&$Param5"
        $EmptyParams = 0
    }
    if (-not([string]::IsNullOrEmpty($Param6)))
    {
        $Param6 = "&$Param6"
        $EmptyParams = 0
    }
    if (-not([string]::IsNullOrEmpty($Param7)))
    {
        $Param7 = "&$Param7"
        $EmptyParams = 0
    }
    if (-not([string]::IsNullOrEmpty($Param8)))
    {
        $Param8 = "&$Param8"
        $EmptyParams = 0
    }
    if (-not([string]::IsNullOrEmpty($Param9)))
    {
        $Param9 = "&$Param9"
        $EmptyParams = 0
    }
    if (-not([string]::IsNullOrEmpty($Param10)))
    {
        $Param10 = "&$Param10"
        $EmptyParams = 0
    }

    if ($EmptyParams -eq 1)
    {
        $QueryString = "timestamp=" + $(Get-Date (Get-Date).ToUniversalTime() -UFormat %s).replace(',', '').replace('.', '').SubString(0,13)
    }
    else
    {
        $QueryString = $Param1 + $Param2 + $Param3 + $Param4 + $Param5 + $Param6 + $Param7 + $Param8 + $Param9 + $Param10 + "&timestamp=" + $(Get-Date (Get-Date).ToUniversalTime() -UFormat %s).replace(',', '').replace('.', '').SubString(0,13)
    }
    return $QueryString

    <#
        .SYNOPSIS
        Dynamically builds a Binance API query string for signed transactions.

        .DESCRIPTION
        Dynamically builds a Binance API query string that can consist of up to 10 parameters for use with signed transactions.

        A unix format timestamp is also generated and appended to the query string.

        .PARAMETER Param1
        The 1st parameter you wish to pass to the Binance API.

        .PARAMETER Param2
        The 2nd parameter you wish to pass to the Binance API.

        .PARAMETER Param3
        The 3rd parameter you wish to pass to the Binance API.

        .PARAMETER Param4
        The 4th parameter you wish to pass to the Binance API.

        .PARAMETER Param5
        The 5th parameter you wish to pass to the Binance API.

        .PARAMETER Param6
        The 6th parameter you wish to pass to the Binance API.

        .PARAMETER Param7
        The 7th parameter you wish to pass to the Binance API.

        .PARAMETER Param8
        The 8th parameter you wish to pass to the Binance API.

        .PARAMETER Param9
        The 9th parameter you wish to pass to the Binance API.

        .PARAMETER Param10
        The 10th parameter you wish to pass to the Binance API.

        .INPUTS
        None. You cannot pipe objects to Get-BinanceSignedQueryString.

        .OUTPUTS
        System.String. Get-BinanceSignedQueryString returns a string with the generated Query String.

        .EXAMPLE
        PS> Get-BinanceSignedQueryString -Param1 "symbol=LINKUSDC" -Param2 "side=BUY" -Param3 "type=LIMIT" -Param4 "timeInForce=GTC" -Param5 "quantity=100" -Param6 "price=0.12" -Param7 "recvWindow=5000"
        
        symbol=LINKUSDC&side=BUY&type=LIMIT&timeInForce=GTC&quantity=100&price=0.12&recvWindow=5000&timestamp=1642695378901
    #>
}