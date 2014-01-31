<#
.Synopsis
   Encrypts a string using another string as a password.
.DESCRIPTION
   Encrypts a string using another string as a password and optionally compresses the original string before encryption.
.INPUTS
   String
.OUTPUTS
   String
.PARAMETER InputObject
   The string to be encrypted.
.PARAMETER Password
   The password to use for encryption.
.PARAMETER Compress
   Compress data before encryption.
.EXAMPLE
   PS: > "Some string" | Write-EncryptedString -Password "hardtoguess"
   5t9BFtBZl2XDTUdx4bZ28PiIvP4wSRI5Y9asa/O5Id5A3MEdKdGYGjliOR/1dVcOupD4e7voaFceESYgpGecTRyLgzk=
.EXAMPLE
   PS: > "Some string" | Write-EncryptedString -Password "hardtoguess" -Compress
   qXcNjxLiD6dROvwJF3ElZP1YjhMUh0JomrOQcQA68YNdPdjJ3W2FsDqyPCMyzKwaGLNLnVifHPlSyY+EXyim0t1li51l9aA2CyTBOy2jTC5MmxFtYtQk1RqhjmG6KQx+i40ClQ==
.NOTES
    The cipher is Rijndael, and the key schedule is RFC2898 with a random 256 bit salt. Compression is generally useless if the original string is under 1KB.

    Originally written by lunaticexperiments
.LINK
    http://lunaticexperiments.wordpress.com/2009/05/16/powershell-and-string-encryption-and-compression/
.ROLE
    Data
.FUNCTIONALITY
    Encryption
#>
function Write-EncryptedString
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline, Position=0)]
        [string]
        $InputObject,

        [Parameter(Mandatory, Position=1)]
        [string]
        $Password,
        
        [Parameter()]
        [switch]
        $Compress
    )

    $Rfc2898 = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Password,32)
	$Salt = $Rfc2898.Salt
	$AESKey = $Rfc2898.GetBytes(32)
	$AESIV = $Rfc2898.GetBytes(16)
	$Hmac = New-Object System.Security.Cryptography.HMACSHA1(,$Rfc2898.GetBytes(20))
		
	$AES = New-Object Security.Cryptography.RijndaelManaged
	$AESEncryptor = $AES.CreateEncryptor($AESKey, $AESIV)
		
	$InputDataStream = New-Object System.IO.MemoryStream
	if ($Compress) { $InputEncodingStream = (New-Object System.IO.Compression.GZipStream($InputDataStream, [IO.Compression.CompressionMode]::Compress, $True)) }
	else { $InputEncodingStream = $InputDataStream }
	$StreamWriter = New-Object System.IO.StreamWriter($InputEncodingStream, (New-Object System.Text.Utf8Encoding($true)))
	$StreamWriter.Write($InputObject)
	$StreamWriter.Flush()
	if ($Compress) { $InputEncodingStream.Close() }
	$InputData = $InputDataStream.ToArray()
		
	$EncryptedEncodedInputString = $AESEncryptor.TransformFinalBlock($InputData, 0, $InputData.Length)
		
	$AuthCode = $Hmac.ComputeHash($EncryptedEncodedInputString)
		
	$OutputData = New-Object Byte[](52 + $EncryptedEncodedInputString.Length)
	[Array]::Copy($Salt, 0, $OutputData, 0, 32)
	[Array]::Copy($AuthCode, 0, $OutputData, 32, 20)
	[Array]::Copy($EncryptedEncodedInputString, 0, $OutputData, 52, $EncryptedEncodedInputString.Length)
		
	$OutputDataAsString = [Convert]::ToBase64String($OutputData)
		
	$OutputDataAsString | Write-Output
}

<#
.Synopsi
   Decrypts a string using another string as a password.
.DESCRIPTION
   Decrypts a string using another string as a password.
.INPUTS
   String
.OUTPUTS
   String
.PARAMETER InputObject
   The string to be encrypted.
.PARAMETER Password
   The password to use for encryption.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   PS > "5t9BFtBZl2XDTUdx4bZ28PiIvP4wSRI5Y9asa/O5Id5A3MEdKdGYGjliOR/1dVcOupD4e7voaFceESYgpGecTRyLgzk=" | Read-EncryptedString -Password "hardtoguess"
   Some string
.NOTES
    Originally written by lunaticexperiments
.LINK
    http://lunaticexperiments.wordpress.com/2009/05/16/powershell-and-string-encryption-and-compression/
.ROLE
    Data
.FUNCTIONALITY
    Encryption
#>
function Read-EncryptedString
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline, Position=0)]
        [string]
        $InputObject,

        [Parameter(Mandatory, Position=1)]
        [string]
        $Password
    )

	$InputData = [Convert]::FromBase64String($InputObject)
		
	$Salt = New-Object Byte[](32)
	[Array]::Copy($InputData, 0, $Salt, 0, 32)
	$Rfc2898 = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Password,$Salt)
	$AESKey = $Rfc2898.GetBytes(32)
	$AESIV = $Rfc2898.GetBytes(16)
	$Hmac = New-Object System.Security.Cryptography.HMACSHA1(,$Rfc2898.GetBytes(20))
		
	$AuthCode = $Hmac.ComputeHash($InputData, 52, $InputData.Length - 52)
		
	if (Compare-Object $AuthCode ($InputData[32..51]) -SyncWindow 0) {
		throw 'Checksum failure.'
	}
		
	$AES = New-Object Security.Cryptography.RijndaelManaged
	$AESDecryptor = $AES.CreateDecryptor($AESKey, $AESIV)
		
	$DecryptedInputData = $AESDecryptor.TransformFinalBlock($InputData, 52, $InputData.Length - 52)
		
	$DataStream = New-Object System.IO.MemoryStream($DecryptedInputData, $false)
	if ($DecryptedInputData[0] -eq 0x1f) {
		$DataStream = New-Object System.IO.Compression.GZipStream($DataStream, [IO.Compression.CompressionMode]::Decompress)
	}
		
	$StreamReader = New-Object System.IO.StreamReader($DataStream, $true)
	$StreamReader.ReadToEnd() | Write-Output
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Write-ScanResults
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        $InputObject,

        # Param2 help description
        [Parameter(Mandatory=$true, Position=1)]
        [string]
        $Path,

        [Parameter(Mandatory=$true, Position=2)]      
        [string]
        $ModuleName,

        [Parameter(Mandatory=$true, Position=3)]      
        [string]
        $Computer,

        [Parameter(Mandatory=$true, Position=4)]      
        [string]
        $Password,

        [Parameter(Position=5)] 
        [ValidateSet("CSV", "JSON")]     
        [string]
        $SerializeAs = "CSV",

        [Parameter(Position=6)] 
        [switch]
        $Compress = $true
    )

    Begin
    {
        $objects = @()
    }
    Process
    {
        foreach ($object in $InputObject)
        {
            $objects += $object
        }
    }
    End
    {
        $string = [string]::Empty
        $datestamp = Get-Date -Format "yyyy-MM-dd"
        $reportFileName = "$($ModuleName)_$datestamp.dat"
        $reportFolderPath = Join-Path -Path $Path -ChildPath $Computer
        $reportFullPath = Join-Path -Path $reportFolderPath -ChildPath $reportFileName

        switch ($SerializeAs)
        {
            'JSON' {$string = $objects | ConvertTo-Json}
            Default {$string = ($objects | ConvertTo-Csv) -join "`n`r"}
        }

        $encryptParams = @{"Password" = $Password
                           "Compress" = $Compress}
        $secureResults = Write-EncryptedString $string @encryptParams

        if (-not (Test-Path -Path $reportFolderPath -PathType Container))
        {
            New-Item -Path $Path -Name $Computer -ItemType Directory -Force
        }
        Set-Content -Value $secureResults -Path $reportFileName -Encoding UTF8 -Force
    }
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Read-ScanResults
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        # Param2 help description
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $Path,

        [Parameter(Mandatory=$true, Position=1)]      
        [string]
        $Computer,

        [Parameter(Mandatory=$true, Position=2)]      
        [string]
        $ModuleName,

        [Parameter(Mandatory=$true, Position=3)]      
        [DateTime]
        $Date,

        [Parameter(Mandatory=$true, Position=4)]      
        [string]
        $Password,

        [Parameter(Position=5)] 
        [ValidateSet("CSV", "JSON")]     
        [string]
        $SerializeAs
    )

    $string = [string]::Empty
    $datestamp = Get-Date -Format "yyyy-MM-dd"
    $reportFileName = "$($ModuleName)_$datestamp.dat"
    $reportFolderPath = Join-Path -Path $Path -ChildPath $Computer
    $reportFullPath = Join-Path -Path $reportFolderPath -ChildPath $reportFileName

    if (Test-Path -Path $reportFullPath -PathType Leaf)
    {
        $contents = Get-Content $reportFullPath -Raw

        $decrypted = Read-EncryptedString -InputObject $contents -Password Password

        if ($decrypted[0] -match '{' -or $SerializeAs -eq "JSON")
        {
            $decrypted | ConvertFrom-Json
        }
        else
        {
            $decrypted | ConvertFrom-Csv
        }
    }
}

Export-ModuleMember -Function Read-ScanResults, Write-ScanResults