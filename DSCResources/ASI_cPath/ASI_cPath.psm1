function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Path
    )
    
    $paths = Convert-Path ([Environment]::GetEnvironmentVariable("Path", "Machine").Split(";"))
      
    $result = @{
        Ensure = $(if ($paths.Contains($(Convert-Path $Path))) { 'Present' } else { 'Absent' })
    }

    return $result
}

function Set-TargetResource {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]
        $Ensure = "Present"
    )

    $paths = Convert-Path ([Environment]::GetEnvironmentVariable("Path", "Machine").Split(";"))
    $list = New-Object System.Collections.ArrayList($null)
    $list.AddRange($paths)

    if ($Ensure -eq 'Present') {
        $list.Add($(Convert-Path $Path))
    }
    else {
        $list.Remove($(Convert-Path $Path))
    }

    $newPath = [String]::Join(";", $list.ToArray())
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
}

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]
        $Ensure = "Present"
    )
    
    $actualValues = Get-TargetResource -Path $Path

    Write-Verbose "The path '$Path' is $($actualValues.Ensure)"

    $result = $actualValues.Ensure -eq $Ensure
        
    return $result
}

Export-ModuleMember -Function *-TargetResource