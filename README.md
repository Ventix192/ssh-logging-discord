# SSH Login Webhook Logger

This Bash script logs SSH login and logout events and sends detailed notifications to a Discord webhook using embeds. It provides enhanced security monitoring by notifying administrators of login attempts, including authentication details, TTY sessions, and IP addresses.

## Features

- Real-time SSH login & logout notifications  
- Discord embed formatting for structured messages  
- Mentions role/users in Discord for critical events  
- IP tracking to detect new login locations  
- Customizable alerts for admins  
- Server identity & authentication method logging  

## Setup

### 1. Install the Script
Copy the script to `/sbin/` and make it executable:
```bash
sudo cp sshd-login /sbin/sshd-login
sudo chmod +x /sbin/sshd-login
```

### 2. Modify PAM Configuration
Edit the PAM SSHD configuration file:
```bash
sudo nano /etc/pam.d/sshd
```
Add the following line at the bottom:
```plaintext
session  optional  pam_exec.so /sbin/sshd-login
```

### 3. Set Up Your Webhook
Replace `WEBHOOK_URL` in the script with your Discord webhook URL.

### 4. Restart SSH Service
```bash
sudo systemctl restart sshd
```

## How It Works

- When a user logs in via SSH, the script checks if the IP is new.
  - If new, it pings an urgent role in Discord.
  - If known, it sends a normal login message.
- When a user logs out, a logout notification is sent.
- Includes additional details:
  - User, Host, IP Address, TTY, and Authentication Method.
  - Server branding with a custom logo.

## Example Discord Notification

> **SSH - Logging**  
> **User:** `root`  
> **Host:** `ceru-service`  
> **IP Address:** `123.123.123.123`  
> **TTY:** `ssh`  
> **Auth Method:** `password`  
> *SSH Logging Service*  

## Future Enhancements

- GeoIP lookup for location tracking  
- Integration with fail2ban for automatic IP bans  
- Login anomaly detection (time-based alerts)  

## Troubleshooting

### Common Issues

**1. No notifications appearing in Discord?**  
- Check if the webhook URL is correct.  
- Verify that the script is executable (`chmod +x`).  
- Ensure SSHD PAM module is correctly configured.

**2. PAM execution errors?**  
- Run `journalctl -xe` to check system logs.  
- Ensure `/sbin/sshd-login` has proper permissions.

---

### Credits  

This script was inspired by a template provided by **Trixzyy**.  
Special thanks to **Trixzyy** for the original concept and structure!  

For support, contact `ventix192` on Discord.
