#--------------------------------------------------------------------------------#
# Get-BinanceUnsignedQueryString                                                 #
#--------------------------------------------------------------------------------#
function Get-BinanceUnsignedQueryString
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
        $QueryString = ""
    }
    else
    {
        $QueryString = $Param1 + $Param2 + $Param3 + $Param4 + $Param5 + $Param6 + $Param7 + $Param8 + $Param9 + $Param10
    }
    return $QueryString
}