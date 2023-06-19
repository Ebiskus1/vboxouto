# '1.1.1.1', '12.13.211.231', '12.180.88.99' Location: https://ip
# 
# 186.192.90.12 -H "Host: globo.com"		Location: https://www.globo.com/
# 20.127.141.51 -H "Host: kli.org"			location: https://www.kli.org/
# 98.136.103.23 -H "Host: altavista.com"	Location: http://www.altavista.com/
# 188.184.9.234 -H "Host: cern.ch"			Location: http://home.web.cern.ch/
# 208.82.237.129 -H "Host: craigslist.org"	Location: https://craigslist.org/
# 

function WriteOK()
{
	Write-Host -ForegroundColor Green 'OK'
}

function WriteFAIL()
{
	Write-Host -ForegroundColor Red 'FAIL'
}

function WriteRepeatContinue()
{
	Write-Host -NoNewLine "("
	Write-Host -NoNewLine -BackgroundColor DarkBlue -ForegroundColor Yellow "[R]"
	Write-Host -NoNewLine "epeat)/"
	Write-Host -NoNewLine -BackgroundColor DarkBlue -ForegroundColor Yellow "[C]"
	Write-Host "ontinue)"
}

function WaitForRetryOrContinue()
{
	$key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
	if ($key.Character -eq 'R' -or $key.Character -eq 'r')
	{
		return 1
	}
	elseif ($key.Character -eq 'C' -or $key.Character -eq 'c')
	{
		return 0
	}
	else
	{
		return 1
	}
}

while(1)
{
	$testaddr = @{
			ip = @('1.1.1.1', '12.13.211.231', '12.180.88.99', '186.192.90.12', '20.127.141.51', '98.136.103.23', '188.184.9.234', '208.82.237.129');
			host = @($null, $null, $null, 'globo.com', 'kli.org', 'altavista.com', 'cern.ch', 'craigslist.org');
			reply = @('1.1.1.1', '12.13.211.231', '12.180.88.99', 'globo.com', 'kli.org', 'altavista.com', 'cern.ch', 'craigslist.org');
		}
	$successful = 0
	$passtcp = $False
	Write-Host -NoNewLine 'Testing TCP connectivity '
	$testidx = [Object[]]::new($testaddr.ip.Length)
	For($i = 0; $i -lt $testaddr.ip.Length; $i++)
	{
		$testidx[$i] = $i;
	}
	$testidx = $testidx | Sort-Object {Get-Random} | Select-Object -First 4
	$ctest = $testidx.Length
	For($i = 0; $i -lt $ctest; $i++)
	{
		$headers = @{ }
		if ($testaddr.host[$testidx[$i]] -ne $null)
		{
			$headers.Add('Host', $testaddr.host[$testidx[$i]]);
		}
		$res=try { Invoke-WebRequest -UseBasicParsing -MaximumRedirection 0 -TimeoutSec 5 -ErrorAction Stop -Headers $headers $testaddr.ip[$testidx[$i]] } catch { $_.Exception.Response }
		if ($res.Headers -and $res.Headers.Location -and ($res.Headers.Location.IndexOf($testaddr.reply[$testidx[$i]]) -ge 0))
		{
			$successful++;
			Write-Host -NoNewLine '+'
		}
		else
		{
			Write-Host -NoNewLine '-'
		}
	}
	Write-Host -NoNewLine "`t`t"
	if ($successful -eq $ctest)
	{
		Write-Host -NoNewline "$successful/$ctest "
		WriteOK
		$passtcp = $True
	}
	elseif ($successful -eq 0)
	{
		Write-Host -NoNewline "$successful/$ctest "
		WriteFAIL
	}
	else
	{
		Write-Host -NoNewline "$successful/$ctest "
		Write-Host -ForegroundColor Green 'FINE'
		$passtcp = $True
	}

	$successful = 0
	$dnstests = 0
	$defdnstests = 0
	$passudp = $False
	Write-Host -NoNewLine "Testing DNS (default server, UDP)...`t"
	$res = $null
	try { $res = Resolve-DnsName -QuickTimeout -DnsOnly -Name msn.com -ErrorAction Stop } catch { }
	$dnstests++
	if($res)
	{
		$successful++
		$defdnstests++
		WriteOK
	}
	else
	{
		WriteFAIL
	}

	Write-Host -NoNewLine "Testing DNS (default server, TCP)...`t"
	$res = $null
	try { $res = Resolve-DnsName -QuickTimeout -TcpOnly -DnsOnly -Name msn.com -ErrorAction Stop } catch { }
	$dnstests++
	if($res)
	{
		$successful++
		$defdnstests++
		WriteOK
	}
	else
	{
		WriteFAIL
	}

	Write-Host -NoNewLine "Testing DNS (Cloudflare, UDP)...`t"
	$res = $null
	try { $res = Resolve-DnsName -QuickTimeout -DnsOnly -Server 1.1.1.1 -Name msn.com -ErrorAction Stop } catch { }
	$dnstests++
	if($res)
	{
		$successful++
		WriteOK
	}
	else
	{
		WriteFAIL
	}

	Write-Host -NoNewLine "Testing DNS (Cloudflare, TCP)...`t"
	$res = $null
	try { $res = Resolve-DnsName -QuickTimeout -DnsOnly -TcpOnly -Server 1.1.1.1 -Name msn.com -ErrorAction Stop } catch { }
	$dnstests++
	if($res)
	{
		$successful++
		WriteOK
	}
	else
	{
		WriteFAIL
	}

	$passdns = ($dnstests -eq $successful)
	if ($passtcp -and $passdns)
	{
		exit
	}
	elseif ($passtcp -eq 0 -and $successful -eq 0)
	{
		Write-Host -NoNewLine "You're offline, perhaps the network cable is disconnected? "
		WriteRepeatContinue
	}
	elseif ($defdnstests -eq 0 -and $successful -ne 0)
	{
		$ifindex = (Get-NetRoute -ErrorAction SilentlyContinue -DestinationPrefix '0.0.0.0/0', '::/0' | Sort-Object -Property { $_.InterfaceMetric + $_.RouteMetric } | Select-Object -First 1).ifIndex
		$dns = Get-DnsClientServerAddress -InterfaceIndex $ifindex
		Write-Host -NoNewLine 'DNS servers '([system.String]::Join(', ', $dns.ServerAddresses))' for interface '($dns.InterfaceAlias | Select-Object -First 1)' are not responding. '
		WriteRepeatContinue
	}
	else
	{
		Write-Host -NoNewLine "Some tests are failed. "
		WriteRepeatContinue
	}
	if (WaitForRetryOrContinue)
	{
		continue
	}
	else
	{
		break
	}
}
