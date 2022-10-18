<#	
	.NOTES
	===========================================================================
	 Filename:     	CompressingFTPlogs.ps1
	===========================================================================
	.DESCRIPTION
		The purpose of this script is to compress log files that are more than a month old.
#>

$Locate = "C:\Program Files (x86)\FTP Server\Logging Server\Logs\"
$Folderlog = "C:\Outils-Infogerance\Logs\"
$Date = $(Get-Date -UFormat "%Y%m%d-%HH%M")
$DateFile = $(Get-Date -UFormat "%Y%m%d")
$Name = "_Compressed-files.log"
$CompressionName = "_FTPLogsCompressed"
$FileLog = $Folderlog + $DateFile + $Name
$Limit = (Get-Date).AddDays(-30)
[Int]$CountFileCompressed = 0


function Compress
{
	$CheckPath = Test-Path $Locate
	If ($CheckPath -eq "True")
	{
		Try 
		{
			$Get = Get-ChildItem -Path $Locate -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $Limit -and $_.Name -like "*.xml" } 
			$Get | Compress-Archive -Destination $Locate$DateFile$CompressionName -CompressionLevel Optimal
			Foreach ($File in $Get)
			{
				$CountFileCompressed++
				$File | Remove-Item -Force
			}				
		}
		Catch
		{
			$LogErrorException = $_.Exception.Message
		}
		Finally
		{
			If ([String]::IsNullOrEmpty($LogErrorException))
		{
			$LogAction = "$CountFileCompressed fichiers de plus de 30 jours ont ete compresses."
		}
		else
		{
			$LogAction = $LogErrorException
		}
		}
	}
	Else 
	{
		$LogAction = "Le dossier de logs est introuvable !"
	}
    $Obj = New-Object psObject
	$Obj | Add-Member -Name "Date" -membertype Noteproperty -Value $Date
	$Obj | Add-Member -Name "Status" -membertype Noteproperty -Value $LogAction
	$Tableau += $Obj
	$Tableau | export-Csv $FileLog -NoTypeInformation -Append -Force -Encoding "UTF8"
}

Compress
