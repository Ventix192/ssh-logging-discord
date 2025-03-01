# !/bin/bash
# SSH Login Webhook Logger
# Logs SSH login and logout events and sends notifications to a Discord webhook.
# Add to /sbin/ and make executable
# Edit /etc/pam.d/sshd and add:
# session  optional  pam_exec.so /sbin/sshd-login
# to the bottom of the file

# Configuration
WEBHOOK_URL="WEBHOOK_URL"
DISCORDUSER="<@USER_ID>"
URGENT_ROLE="<@ROLE_ID>"
GUILD_ICON_URL="YOUR_GUILD_ICON_URL_HERE"

# File to store previously seen IP addresses
IP_FILE="/var/log/seen_ips.log"

# Function to check if IP is new
is_new_ip() {
    local ip="$1"
    grep -Fxq "$ip" "$IP_FILE"
}

# Function to record seen IP
record_ip() {
    local ip="$1"
    echo "$ip" >> "$IP_FILE"
}

# Ensure the file exists
touch "$IP_FILE"

# Get the current date and time
CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")

# Define Embed Template
create_embed() {
    local title="$1"
    local color="$2"
    local description="$3"
    local user="$4"
    local hostname="$5"
    local ip="$6"
    local tty="$7"
    local method="$8"
    local ping="$9"

    cat <<EOF
{
  "content": "$ping",
  "embeds": [
    {
      "title": "$title",
      "color": $color,
      "description": "$description",
      "fields": [
        { "name": "User", "value": "$user", "inline": true },
        { "name": "Host", "value": "$hostname", "inline": true },
        { "name": "IP Address", "value": "$ip", "inline": true },
        { "name": "TTY", "value": "$tty", "inline": true },
        { "name": "Auth Method", "value": "$method", "inline": true },
        { "name": "Timestamp", "value": "$CURRENT_TIME", "inline": false }
      ],
      "author": {
        "name": "SSH Logger",
        "icon_url": "$GUILD_ICON_URL"
      },
      "footer": {
        "text": "SSH Logging Service",
        "icon_url": "$GUILD_ICON_URL"
      }
    }
  ]
}
EOF
}

# Capture only open and close sessions.
case "$PAM_TYPE" in
    open_session)
        if ! is_new_ip "$PAM_RHOST"; then
            PAYLOAD=$(create_embed "SSH - Logging" 16711680 "New SSH login detected." "$PAM_USER" "$HOSTNAME" "$PAM_RHOST" "$PAM_TTY" "$PAM_SERVICE" "$URGENT_ROLE")
            record_ip "$PAM_RHOST"
        else
            PAYLOAD=$(create_embed "SSH - Logging" 65280 "SSH login successful." "$PAM_USER" "$HOSTNAME" "$PAM_RHOST" "$PAM_TTY" "$PAM_SERVICE" "$DISCORDUSER")
        fi
        ;;
    close_session)
        PAYLOAD=$(create_embed "SSH - Logging" 16753920 "SSH logout detected." "$PAM_USER" "$HOSTNAME" "$PAM_RHOST" "$PAM_TTY" "$PAM_SERVICE" "$DISCORDUSER")
        ;;
esac

# If payload exists, fire webhook
if [ -n "$PAYLOAD" ]; then
    curl -X POST -H 'Content-Type: application/json' -d "$PAYLOAD" "$WEBHOOK_URL"
fi
