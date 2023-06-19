function RandSleep()
{
    sleep -Milliseconds (Get-Random  -Min 1000 -Max 6000)
}

function RandSleep2()
{
    sleep -Milliseconds (Get-Random  -Min 100 -Max 500)
}

Add-Type -Path "$PWD\WebDriver.dll"
$edgeOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions

$edgeOptions.AddAdditionalCapability("useAutomationExtension", 0)
$edgeOptions.AddExcludedArgument("enable-automation")
$edgeOptions.AddArgument("disable-blink-features")
$edgeOptions.AddArgument("disable-blink-features=AutomationControlled")
$edgeOptions.AddArgument("remote-allow-origins=*")
$edgeOptions.AddArgument("start-maximized")
$edgeOptions.AddArgument("user-data-dir=$env:localappdata\Microsoft\Edge\User Data");

$workingDriver = ''

$browserVer = (Get-AppxPackage -Name *MicrosoftEdge.Stable* | Foreach Version)
if(!$browserVer)
{
	Write-Host "Couldn't get Edge version from Microsoft Store, trying through Installed Programs..."
	$ins = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion; $ins += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName,DisplayVersion; $browserVer = ($ins | ?{ $_.DisplayName -eq 'Microsoft Edge' } | Select-Object -First 1).DisplayVersion
}

$browserVer = [int]::Parse($browserVer.Split('.')[0])
Write-Host $browserVer ' detected'

$file = 'msedgedriver.' + $browserVer + '.exe'

$driver = $null
$retries = 10;

while($driver -eq $null)
{
    if ($retries -eq 0) { Exit }
    $retries--

    Write-Host $file
    if (! (Test-Path $file) )
    {
        Write-Host -NoNewLine "$file not found! Press any key to continue...";
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        Exit
    }

    Rename-Item $file 'msedgedriver.exe'
    try
    {
        $driver = New-Object OpenQA.Selenium.Edge.EdgeDriver($edgeOptions)
    }
	catch
	{
		Rename-Item 'msedgedriver.exe' $file
		$err = $Error[0].ToString()
		$incompatstr = 'Current browser version is ';
		$erridx = $err.IndexOf($incompatstr)
		if ($erridx -ge 0)
		{
			$browserVer = [int]::Parse($err.SubString($erridx + $incompatstr.Length, 4).Split('.')[0])
			Write-Host $browserVer ' detected'
			$file = 'msedgedriver.' + $browserVer + '.exe' 
		}
		else
		{
			Write-Host $err
			$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
			Exit
		}
	}
    if ( $driver -ne $null )
    {
        $workingDriver = $file 
        Break
    }
}


$driver.Navigate().GoToURL('https://amazon.com/')

RandSleep

$maxsearches = 50
$randomterms = $searchterms | Sort-Object {Get-Random}
$firstsearch = 1

ForEach($text in $randomterms)
{
    $actions = New-Object OpenQA.Selenium.Interactions.Actions($driver)

    $input = $driver.FindElement([OpenQA.Selenium.By]::Id("twotabsearchtextbox"))
	if ($input -eq $null) { Write-Host 'No input field! Giving up.'; Break }
	
    $searchbtn = $driver.FindElement([OpenQA.Selenium.By]::Id("nav-search-submit-button"))
	if ($searchbtn -eq $null) { Write-Host 'No search btn! Giving up.'; Break }
	
    $actions.MoveToElement($input).Build().Perform()
    $actions.Click($input).Build().Perform()
    RandSleep

    if ($firstsearch -eq 0)
    {
        $input.sendKeys([OpenQA.Selenium.Keys]::LeftControl + "a")
        $input.sendKeys([OpenQA.Selenium.Keys]::Backspace)
        RandSleep
    }

    foreach ($char in $text.ToCharArray()) { $input.SendKeys($char); sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 500) }
    RandSleep2

    $actions.MoveToElement($searchbtn).Build().Perform()
    $actions.Click($searchbtn).Build().Perform()
    $firstsearch = 0

    $maxsearches--
    if ($maxsearches -eq 0) { Break }

    RandSleep
}

$driver.Close()
$driver.Quit()

Rename-Item 'msedgedriver.exe' $workingDriver