#!/bin/bash
set -u

# Basic safety: don't use -e because whiptail/curl errors may be handled manually
# set -euo pipefail   # enable if you want the script to stop on first error

# Global variables
STARTINI=""
ENDDOTS=""

# Set up directories
I_AM=$(whoami)
sudo mkdir -p /opt/dizcord/playerdb/html /opt/dizcord/times /opt/dizcord/boidbot
sudo chown -R "$I_AM":"$I_AM" /opt/dizcord

# helper: escape replacement for sed (escape &, / and | )
_escape_sed_repl() {
  printf '%s' "$1" | sed -e 's/[&|/]/\\&/g'
}

# FUNCTIONS

# Setting up the crontab to restart the server
ADDCRON(){
  EVERY="* * *"
  COMMAND="/opt/dizcord/restart.sh"

  RESTART_FREQUENCY=$(whiptail --title "Restart Frequency" --menu "How many times a day do you want to restart the server?" 15 80 5 \
    "0" "No automatic restart" \
    "1" "Once a day" \
    "2" "Every 12 hours" \
    "3" "Every 8 hours" \
    "4" "Every 6 hours" 3>&1 1>&2 2>&3)

  case $RESTART_FREQUENCY in
    0)
      # Remove scheduled restart from crontab
      crontab -l 2>/dev/null | grep -v '/opt/dizcord/restart.sh' | crontab - 2>/dev/null || true
      whiptail --title "Scheduling removed" --msgbox "The scheduled server restart has been removed and will now *not* restart on a daily basis." 8 80
      SCHEDULE="false"
      SCHEDULEMIN=""
      SCHEDULEHRS=""
      ;;

    1)
      while true; do
        RESTART_TIME=$(whiptail --title "Restart Time" --inputbox "Enter the restart time (24-hour format, e.g., 13:30):" 10 80 3>&1 1>&2 2>&3)
        if [[ "$RESTART_TIME" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
          break
        else
          whiptail --title "Invalid Time" --msgbox "Please enter a valid time in 24-hour format (e.g., 13:30)." 10 80
        fi
      done
      CRONMIN=$(echo "$RESTART_TIME" | awk -F":" '{print $2}' | sed 's/^0//')
      CRONHRS=$(echo "$RESTART_TIME" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONINS="$CRONMIN $CRONHRS $EVERY $COMMAND"

      crontab -l 2>/dev/null | grep -v '/opt/dizcord/restart.sh' | crontab - 2>/dev/null || true
      (crontab -l 2>/dev/null ; echo "$CRONINS") | sort - | uniq - | crontab -
      SCHEDULE="true"
      SCHEDULEHRS="$CRONHRS"
      SCHEDULEMIN="$CRONMIN"
      ;;

    2)
      while true; do
        RESTART_TIME1=$(whiptail --title "Restart Time" --inputbox "Enter first restart time (24-hour format, e.g., 13:30):" 10 80 3>&1 1>&2 2>&3)
        if [[ "$RESTART_TIME1" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
          break
        else
          whiptail --title "Invalid Time" --msgbox "Please enter a valid time in 24-hour format (e.g., 13:30)." 10 80
        fi
      done

      TIMESTAMP1=$(date -d "$RESTART_TIME1" "+%s")
      SECONDS=43200
      TIMESTAMP2=$((TIMESTAMP1 + SECONDS))
      RESTART_TIME2=$(date -d "@$TIMESTAMP2" +%H:%M)
      CRONMIN=$(echo "$RESTART_TIME1" | awk -F":" '{print $2}' | sed 's/^0//')
      CRONHRS1=$(echo "$RESTART_TIME1" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS2=$(echo "$RESTART_TIME2" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS=$(printf "%s\n%s" "$CRONHRS1" "$CRONHRS2" | sort -n | paste -sd, -)
      CRONINS="$CRONMIN $CRONHRS $EVERY $COMMAND"

      crontab -l 2>/dev/null | grep -v '/opt/dizcord/restart.sh' | crontab - 2>/dev/null || true
      (crontab -l 2>/dev/null ; echo "$CRONINS") | sort - | uniq - | crontab -
      SCHEDULE="true"
      SCHEDULEHRS="$CRONHRS"
      SCHEDULEMIN="$CRONMIN"
      ;;

    3)
      while true; do
        RESTART_TIME1=$(whiptail --title "Restart Time" --inputbox "Enter first restart time (24-hour format, e.g., 13:30):" 10 80 3>&1 1>&2 2>&3)
        if [[ "$RESTART_TIME1" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
          break
        else
          whiptail --title "Invalid Time" --msgbox "Please enter a valid time in 24-hour format (e.g., 13:30)." 10 80
        fi
      done

      TIMESTAMP1=$(date -d "$RESTART_TIME1" "+%s")
      SECONDS=28800
      TIMESTAMP2=$((TIMESTAMP1 + SECONDS))
      TIMESTAMP3=$((TIMESTAMP2 + SECONDS))
      RESTART_TIME2=$(date -d "@$TIMESTAMP2" +%H:%M)
      RESTART_TIME3=$(date -d "@$TIMESTAMP3" +%H:%M)
      CRONMIN=$(echo "$RESTART_TIME1" | awk -F":" '{print $2}' | sed 's/^0//')
      CRONHRS1=$(echo "$RESTART_TIME1" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS2=$(echo "$RESTART_TIME2" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS3=$(echo "$RESTART_TIME3" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS=$(printf "%s\n%s\n%s" "$CRONHRS1" "$CRONHRS2" "$CRONHRS3" | sort -n | paste -sd, -)
      CRONINS="$CRONMIN $CRONHRS $EVERY $COMMAND"

      crontab -l 2>/dev/null | grep -v '/opt/dizcord/restart.sh' | crontab - 2>/dev/null || true
      (crontab -l 2>/dev/null ; echo "$CRONINS") | sort - | uniq - | crontab -
      SCHEDULE="true"
      SCHEDULEHRS="$CRONHRS"
      SCHEDULEMIN="$CRONMIN"
      ;;

    4)
      while true; do
        RESTART_TIME1=$(whiptail --title "Restart Time" --inputbox "Enter first restart time (24-hour format, e.g., 13:30):" 10 80 3>&1 1>&2 2>&3)
        if [[ "$RESTART_TIME1" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
          break
        else
          whiptail --title "Invalid Time" --msgbox "Please enter a valid time in 24-hour format (e.g., 13:30)." 10 80
        fi
      done

      TIMESTAMP1=$(date -d "$RESTART_TIME1" "+%s")
      SECONDS=21600
      TIMESTAMP2=$((TIMESTAMP1 + SECONDS))
      TIMESTAMP3=$((TIMESTAMP2 + SECONDS))
      TIMESTAMP4=$((TIMESTAMP3 + SECONDS))
      RESTART_TIME2=$(date -d "@$TIMESTAMP2" +%H:%M)
      RESTART_TIME3=$(date -d "@$TIMESTAMP3" +%H:%M)
      RESTART_TIME4=$(date -d "@$TIMESTAMP4" +%H:%M)
      CRONMIN=$(echo "$RESTART_TIME1" | awk -F":" '{print $2}' | sed 's/^0//')
      CRONHRS1=$(echo "$RESTART_TIME1" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS2=$(echo "$RESTART_TIME2" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS3=$(echo "$RESTART_TIME3" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS4=$(echo "$RESTART_TIME4" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS=$(printf "%s\n%s\n%s\n%s" "$CRONHRS1" "$CRONHRS2" "$CRONHRS3" "$CRONHRS4" | sort -n | paste -sd, -)
      CRONINS="$CRONMIN $CRONHRS $EVERY $COMMAND"

      crontab -l 2>/dev/null | grep -v '/opt/dizcord/restart.sh' | crontab - 2>/dev/null || true
      (crontab -l 2>/dev/null ; echo "$CRONINS") | sort - | uniq - | crontab -
      SCHEDULE="true"
      SCHEDULEHRS="$CRONHRS"
      SCHEDULEMIN="$CRONMIN"
      ;;

    *)
      ;;
  esac
}

# Function to prompt the user for a server name
ASK(){
  GENERATED_NAMES=0
  SERVER_NAME=$(whiptail --title "Server Name" --inputbox "Please enter a server name for your Project Zomboid server.\n\nIf left blank, a random name will be generated." 12 80 3>&1 1>&2 2>&3)
  if [[ -z "${SERVER_NAME:-}" ]]; then
    SUGGEST
  fi
}

# Function to suggest a random server name if the entered one is empty
SUGGEST(){
  RANDOM_NAMES=( \
    "Zombocalypse Haven" "Undead Utopia" "Survival Sanctuary" "Outbreak Outpost" \
    "Infected Inn" "Apocalypse Alcove" "Cataclysmic Citadel" "Quarantine Quarter" \
    "Endgame Enclave" "Deadzone Dwelling" "Survival Stronghold" "Pandemic Playground" \
    "Aftermath Asylum" "Undying Utopia" "Blighted Dominion" "Rotting Domain" )
  GENERATED_NAMES=0
  while [ $GENERATED_NAMES -lt 3 ]; do
    if [ -z "${SERVER_NAME:-}" ]; then
      GENERATED_NAMES=$((GENERATED_NAMES + 1))
      RANDOM_SERVER_NAME=$(shuf -n 1 -e "${RANDOM_NAMES[@]}")
      if whiptail --title "Generated Name" --yesno "Generated Server Name: $RANDOM_SERVER_NAME\n\nIs this name acceptable?" 10 80; then
        SERVER_NAME="$RANDOM_SERVER_NAME"
        return
      fi
    else
      return
    fi
  done
  ASK
}

VALIDATE_WEBHOOK() {
  local HOOKREGEX="^https://(discord\.com|discordapp\.com)/api/webhooks/[0-9]+/[a-zA-Z0-9_-]+$"
  [[ $1 =~ $HOOKREGEX ]]
}

WELCOME(){
  whiptail --title "Project Zomboid Server Integration" --msgbox "Welcome to the installation wizard.\n\nThis tool will help you integrate your Project Zomboid Server with your Discord server.\n\nYou should already have your Project Zomboid Server set up and running." 16 80
}

SETTINGSCHECK(){
  SETNUM=$(find /opt/dizcord/ -type f -name "settings-*" 2>/dev/null | wc -l)
  if [[ $SETNUM -eq 1 ]]; then
    # if there's one existing settings file
    SETFILE=$(find /opt/dizcord/ -type f -name "settings-*" -print -quit)
    EXISTING_SERVER=$(jq -r '.server // empty' "$SETFILE" 2>/dev/null || true)
    if whiptail --title "Existing Install found" --yesno --yes-button "Update" --no-button "New Instance" "The settings for $EXISTING_SERVER were found. Would you like to update them or create a new instance?" 26 80; then
      # TODO: implement update flow
      :
    else
      # create new instance flow continues
      :
    fi
  elif [[ $SETNUM -gt 1 ]]; then
    # more than one existing settings files
    mapfile -t SETTINGS_LIST < <(find /opt/dizcord/ -type f -name "settings-*" -print 2>/dev/null)
    MENU_ITEMS=()
    for ((i=0; i<${#SETTINGS_LIST[@]}; i++)); do
      NAME=$(jq -r '.server // empty' "${SETTINGS_LIST[i]}" 2>/dev/null || echo "${SETTINGS_LIST[i]}")
      MENU_ITEMS+=("$((i+1))" "$NAME")
    done
    SELECTEDINI=$(whiptail --menu "Select option" 15 60 6 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then
      SELECT_INDEX=$((SELECTEDINI-1))
      # TODO: implement edit/delete/create for selected settings file
      :
    else
      exit
    fi
  else
    # no settings exist - continue as normal
    :
  fi
}

LICENSE(){
  LICENSE_TEXT="GNU General Public License v3.0\n\nCopyright (c) 2023 Jim Sher\n\nThis program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation\n\nThis program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.\n\nBy selecting \"Yes\" you agree to the above."
  if whiptail --title "GNU GPL v3 License" --yesno "$LICENSE_TEXT" 26 80; then
    echo -e "You can find a copy of this license in /opt/dizcord/licence.txt"
  else
    exit
  fi
}

FINDINI(){
  INIARR=()
  echo -n "Finding Server configuration files, please wait."

  # background dots indicator
  touch /tmp/stop_dots 2>/dev/null || true
  ( while true; do
      echo -n "."
      sleep 0.5
      [ -f /tmp/stop_dots ] || break
    done ) &
  DOTS_PID=$!

  # find ini files
  while IFS= read -r -d $'\0' file; do
    INIARR+=("$file")
  done < <(find / -type f -path "*/Zomboid/Server/*.ini" -print0 2>/dev/null)

  # stop dots
  rm -f /tmp/stop_dots
  wait $DOTS_PID 2>/dev/null || true
  echo ""

  if [ "${#INIARR[@]}" -eq 0 ]; then
    INIFILE=$(whiptail --inputbox "I could not find the Project Zomboid installation. Please enter the full path to the .INI file for your Project Zomboid Server:" 10 80 3>&1 1>&2 2>&3)
    if [ -z "${INIFILE:-}" ]; then
      whiptail --title "Error" --msgbox "Installation directory cannot be empty. Exiting." 10 80
      exit 1
    fi
  elif [ "${#INIARR[@]}" -eq 1 ]; then
    INIFILE="${INIARR[0]}"
    if whiptail --title "Confirm Config File" --yesno "I found a Project Zomboid configuration file called $INIFILE.\n\nIs this the correct config file from your server?" 10 80; then
      :
    else
      INIFILE=$(whiptail --inputbox "Please enter the full path to the .INI file for Project Zomboid (including the file itself):" 10 80 3>&1 1>&2 2>&3)
    fi
  else
    SELINI=()
    for ((i=0;i<${#INIARR[@]};i++)); do
      tag=$((i+1))
      label=$(basename "${INIARR[i]}")
      SELINI+=("$tag" "$label" "off")
    done
    CHOICE=$(whiptail --radiolist "Please select the .INI file for your Server.\n\nSpace to select, Enter to lock it in." 20 80 10 "${SELINI[@]}" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
      exit
    fi
    # CHOICE is the tag number. Map back to index
    INDEX=$((CHOICE-1))
    INIFILE="${INIARR[INDEX]}"
  fi

  # set STARTINI (basename without .ini)
  STARTINI=$(basename "$INIFILE" .ini)
}

HUMANNAME(){
  SERVER_NAME=""
  ASK
}

DISCORDHOOK(){
  WEBHOOK=""
  while true; do
    WEBHOOK=$(whiptail --title "Discord Webhook" --inputbox "Please enter the Discord server's full webhook." 12 80 "" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
      exit 1
    fi
    if VALIDATE_WEBHOOK "$WEBHOOK"; then
      break
    else
      whiptail --title "Invalid Webhook" --msgbox "The entered Discord webhook is invalid. Please enter a valid webhook URL." 10 80
    fi
  done

  OTP=$(printf '%06d' "$(shuf -i0-999999 -n1)")
  curl -s -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": 8388736, \"title\": \"Verification Code\", \"description\": \"Please enter these numbers into the Discord installation wizard:\\n\\n$OTP\" }] }" "$WEBHOOK" || true

  USER_INPUT=""
  while [ "$USER_INPUT" != "$OTP" ]; do
    USER_INPUT=$(whiptail --title "Verification Code" --inputbox "Please enter the 6-digit verification code sent to Discord:" 12 80 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
      exit
    fi
  done
}

DISCORDBOT(){
  TOKEN=""
  while true; do
    TOKEN=$(whiptail --title "Discord Bot Token" --inputbox "Please enter the full token for your bot." 12 80 "" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
      exit 1
    fi
    if [[ -n "${TOKEN:-}" ]]; then
      break
    fi
  done
}

CRONTAB(){
  whiptail --title "Start on reboot" --yesno "Do you want the Project Zomboid server to start automatically when the server boots up?" 10 80
  if [[ $? -eq 0 ]]; then
    CRONINS="@reboot /opt/dizcord/start.sh"
    (crontab -l 2>/dev/null ; echo "$CRONINS") | sort - | uniq - | crontab -
    RESTARTONREBOOT="true"
  else
    crontab -l 2>/dev/null | grep -v '/opt/dizcord/start.sh' | crontab - 2>/dev/null || true
    RESTARTONREBOOT="false"
  fi

  # Check if there's a restart command in crontab for current user
  if crontab -l 2>/dev/null | grep -q '/opt/dizcord/restart.sh'; then
    LINE=$(crontab -l 2>/dev/null | grep 'dizcord/restart.sh' | head -n1)
    MIN=$(echo "$LINE" | awk '{print $1}')
    HRS=$(echo "$LINE" | awk '{print $2}')
    if echo "$HRS" | grep -q ","; then
      MULTIPLE=" these times"
    else
      MULTIPLE=""
    fi
    RESTART_TIMES=$(echo $HRS | awk -v MIN="$MIN" -F, '{for(i=1; i<=NF; i++) {printf "%02d:%02d\n", $i, MIN}}')
    whiptail --title "Cronjob Times" --yesno "The Project Zomboid Server is currently configured to restart at$MULTIPLE:\n\n$RESTART_TIMES\n\nDo you want to keep this schedule?" 15 80
    SETCRON=$?
    if [[ $SETCRON -eq 0 ]]; then
      whiptail --title "Schedule maintained" --msgbox "No changes made to the restart schedule." 8 78
      SCHEDULE="true"
      SCHEDULEHRS="$HRS"
      SCHEDULEMIN="$MIN"
    else
      ADDCRON
    fi
  else
    whiptail --title "Cronjob Times" --yesno "\
The Project Zomboid Server is not currently configured to restart automatically\n\n\
Restarting the server helps with performance and cleanup. Would you like to set up automatic restarts?" 17 80
    SETCRON=$?
    if [[ $SETCRON -eq 0 ]]; then
      ADDCRON
    else
      whiptail --title "Schedule maintained" --msgbox "No changes made to the restart schedule." 8 78
      SCHEDULE="false"
      SCHEDULEHRS=""
      SCHEDULEMIN=""
    fi
  fi
}

DOWNLOAD(){
  # required tools
  for cmd in curl jq wget tar sed; do
    command -v $cmd >/dev/null 2>&1 || { whiptail --msgbox "Required command '$cmd' not found. Please install it and re-run." 10 60; exit 1; }
  done

  LATEST_VERSION=$(curl -sL https://api.github.com/repos/Blyzz616/diZcord/releases/latest | jq -r '.tag_name // empty')
  CURRENT_VERSION=""
  if [ -f /opt/dizcord/current.version ]; then
    CURRENT_VERSION=$(< /opt/dizcord/current.version)
  fi

  if [[ -n "$LATEST_VERSION" && "$CURRENT_VERSION" !=  "$LATEST_VERSION" ]]; then
    TMP="/tmp/${LATEST_VERSION}.tar.gz"
    wget -q -O "$TMP" "https://github.com/Blyzz616/diZcord/archive/${LATEST_VERSION}.tar.gz"
    tar -zxf "$TMP" -C /tmp
    # Move contents safely
    SRC="/tmp/diZcord-${LATEST_VERSION#v}"
    if [ -d "$SRC" ]; then
      mv "$SRC"/* /opt/dizcord/ 2>/dev/null || cp -a "$SRC"/* /opt/dizcord/
    fi
    sudo chmod ug+x /opt/dizcord/*.sh 2>/dev/null || true
    rm -f "$TMP"
    echo "$LATEST_VERSION" > /opt/dizcord/current.version
    CURRENT_VERSION="$LATEST_VERSION"
  fi

  # Replace placeholders in script files
  for FILE in /opt/dizcord/kill.sh /opt/dizcord/obit.sh /opt/dizcord/reader.sh /opt/dizcord/restart.sh /opt/dizcord/start.sh; do
    [ -f "$FILE" ] || continue
    sed -i "s|USERPLACEHOLDER|$(_escape_sed_repl "$I_AM")|g" "$FILE"
    sed -i "s|WEBHOOKPLACEHOLDER|$(_escape_sed_repl "$WEBHOOK")|g" "$FILE"
    sed -i "s|HRNAME|$(_escape_sed_repl "$SERVER_NAME")|g" "$FILE"
    sed -i "s|ININAME|$(_escape_sed_repl "$STARTINI")|g" "$FILE"
  done

  sudo chmod ug+x /opt/dizcord/*.sh 2>/dev/null || true
  ln -sf /opt/dizcord/restart.sh /home/"$I_AM"/restart.sh 2>/dev/null
  ln -sf /opt/dizcord/start.sh /home/"$I_AM"/start.sh 2>/dev/null
}

INSTRUCTIONS(){
  whiptail --title "How to use." --msgbox "Once you are all done here, head to your home directory and start the Project Zomboid server by typing:\n\n./start.sh\n\nTo restart: ./restart.sh\n" 18 80
}

THANKS(){
  whiptail --title "Thanks for using dizcord." --msgbox "Maybe consider a small donation: https://ko-fi.com/blyzz" 12 80
}

SAVE(){
  # Write settings to file
  SCHEDULEHRS="${SCHEDULEHRS:-}"
  echo -e "{
  \"user\": \"$I_AM\",
  \"file\": \"$INIFILE\",
  \"INI\": \"$STARTINI\",
  \"server\": \"$SERVER_NAME\",
  \"url\": \"$WEBHOOK\",
  \"token\": \"$TOKEN\",
  \"startonboot\": \"${RESTARTONREBOOT:-false}\",
  \"daily\": \"${SCHEDULE:-false}\",
  \"dailyH\": \"$SCHEDULEHRS\",
  \"dailyM\": \"${SCHEDULEMIN:-}\",
  \"version\": \"${CURRENT_VERSION:-}\"
  }" > /opt/dizcord/"settings-${STARTINI}.ini"
}

# Main flow
WELCOME
SETTINGSCHECK
LICENSE
FINDINI
HUMANNAME
DISCORDHOOK
DISCORDBOT
CRONTAB
DOWNLOAD
INSTRUCTIONS
THANKS
SAVE
