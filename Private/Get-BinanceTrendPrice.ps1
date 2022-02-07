#--------------------------------------------------------------------------------#
# Get-BinanceTrendPrice                                                          #
#--------------------------------------------------------------------------------#
function Get-BinanceTrendPrice
{
    param(
        [Parameter(Mandatory=$true)][string]$Date1,
        [Parameter(Mandatory=$true)][Decimal]$Price1,
        [Parameter(Mandatory=$true)][string]$Date2,
        [Parameter(Mandatory=$true)][Decimal]$Price2
    )

    [DateTime]$DateTime1 = Get-Date -date $Date1
    [DateTime]$DateTime2 = Get-Date -date $Date2

    [Decimal]$Increment = ($Price2 - $Price1) / ($DateTime2 - $DateTime1).TotalMinutes
    return $Price2 + ((Get-Date) - $DateTime2).TotalMinutes * $Increment
}