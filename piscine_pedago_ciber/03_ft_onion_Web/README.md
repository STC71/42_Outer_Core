# 🧅 ft_onion - Tor Hidden Service

**Version**: 1.00  
**Project Type**: Web Server + Tor Network

## 📋 Table of Contents
- [Overview](#overview)
- [Objective](#objective)
- [Mandatory Part](#mandatory-part)
- [Technical Implementation](#technical-implementation)
- [Deliverables](#deliverables)
- [Bonus Features](#bonus-features)
- [Setup Guide](#setup-guide)
- [Security Considerations](#security-considerations)

---

## 🎯 Objective

Create a web page and make it accessible from the Tor network by creating a **hidden service**. A hidden service is a web service that is hidden in the Tor network, providing anonymity for both the server and users.

---

## 📖 Overview

This project consists of deploying a web server that displays a web page on the Tor network, leveraging the power of anonymity on the Internet. You need to properly configure the necessary services (Nginx, Tor, SSH) to make the page accessible through a `.onion` address.

**Key Concepts**:
- **Tor Network**: The Onion Router - anonymity network
- **Hidden Service**: Server accessible only through Tor
- **`.onion` address**: Special-use top-level domain for anonymous hidden services

---

## ✅ Mandatory Part

### Requirements

You must run a web server that displays a web page on the Tor network.

### Technical Specifications

#### 1. Static Web Page
- Create a static `index.html` file
- The page will be accessible via URL format: `xxxxxxxxx.onion`
- **Content is your choice**

#### 2. Web Server - Nginx
- **Mandatory server:** Nginx
- **Not allowed:** Any other server or framework
- **Port:** HTTP on port 80 must be enabled

#### 3. SSH Access
- SSH must be enabled on **port 4242**
- Properly configured through `sshd_config`

#### 4. Network Configuration
- **DO NOT** open ports manually
- **DO NOT** configure firewall rules manually
- Configuration should be handled through proper service setup

---

## 📦 Deliverables

### Required Files

| File | Description |
|------|-------------|
| `index.html` | Static web page content |
| `nginx.conf` | Nginx server configuration |
| `sshd_config` | SSH service configuration |
| `torrc` | Tor configuration file |

### Implementation Options

You can use any of these methods to validate the project:
- **Docker image** (recommended for portability)
- **Virtual machine** (not necessary to upload to repository)
- **Other justified method**

⚠️ **Important**: You must **justify your choices** and add necessary files to the repository.

---

## 🔧 Technical Implementation

### System Components

```
┌─────────────────────────────────────┐
│       Tor Network (.onion)          │
│                                     │
│  xxxxxxxxx.onion ──► Hidden Service │
└──────────────┬──────────────────────┘
               │
               ▼
      ┌────────────────┐
      │   Tor Daemon   │
      │    (torrc)     │
      └────────┬───────┘
               │
               ▼
      ┌────────────────┐
      │     Nginx      │
      │  Port: 80      │
      └────────┬───────┘
               │
               ▼
      ┌────────────────┐
      │  index.html    │
      │  Static Page   │
      └────────────────┘

      SSH Access → Port 4242
```

### Ports Configuration

| Service | Port | Protocol |
|---------|------|----------|
| Nginx (HTTP) | 80 | HTTP |
| SSH | 4242 | SSH |
| Tor | Internal | SOCKS5 |

---

## ⭐ Bonus Features

Bonuses will **ONLY** be evaluated if the mandatory part is **PERFECT**.

### 1. SSH Hardening
Implement advanced security measures for SSH:
- Key-based authentication only
- Disable root login
- Fail2ban integration
- Port knocking
- Two-factor authentication

**Note:** Will be thoroughly tested during evaluation.

### 2. Interactive Application
Create something more impressive than a static web page:
- Dynamic content with backend
- Database integration
- User authentication
- Interactive features (chat, forms, etc.)
- Web application framework

---

## 🚀 Setup Guide

### Prerequisites
```bash
# Install required packages
apt-get update
apt-get install -y nginx tor ssh
```

### Step 1: Configure Nginx

Create/edit `nginx.conf`:
```nginx
server {
    listen 127.0.0.1:80;
    server_name localhost;
    
    root /var/www/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Step 2: Configure Tor Hidden Service

Edit `torrc`:
```bash
# Hidden Service configuration
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServicePort 80 127.0.0.1:80
```

### Step 3: Configure SSH

Edit `sshd_config`:
```bash
Port 4242
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication yes
```

### Step 4: Deploy and Start Services

```bash
# Copy configuration files
cp nginx.conf /etc/nginx/sites-available/default
cp torrc /etc/tor/torrc
cp sshd_config /etc/ssh/sshd_config

# Create web directory
mkdir -p /var/www/html
cp index.html /var/www/html/

# Start services
systemctl start nginx
systemctl start tor
systemctl start ssh

# Get your .onion address
cat /var/lib/tor/hidden_service/hostname
```

---

## 🐳 Docker Implementation Example

### Dockerfile
```dockerfile
FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    tor \
    openssh-server

COPY nginx.conf /etc/nginx/sites-available/default
COPY torrc /etc/tor/torrc
COPY sshd_config /etc/ssh/sshd_config
COPY index.html /var/www/html/

EXPOSE 80 4242

CMD service tor start && \
    service ssh start && \
    nginx -g 'daemon off;'
```

### docker-compose.yml
```yaml
version: '3'
services:
  ft_onion:
    build: .
    ports:
      - "4242:4242"
    volumes:
      - tor_data:/var/lib/tor
volumes:
  tor_data:
```

---

## 🛡️ Security Considerations

### Tor Network Security
- Never log user activity
- Respect user anonymity
- Don't mix clearnet and onion services
- Keep Tor daemon updated

### SSH Hardening (Bonus)
```bash
# Disable password authentication
PasswordAuthentication no

# Use key-based authentication only
PubkeyAuthentication yes

# Disable root login
PermitRootLogin no

# Limit user access
AllowUsers your_user

# Use fail2ban
apt-get install fail2ban
```

### Nginx Security
```nginx
# Hide version
server_tokens off;

# Security headers
add_header X-Frame-Options "SAMEORIGIN";
add_header X-Content-Type-Options "nosniff";
add_header X-XSS-Protection "1; mode=block";
```

---

## 🔍 Testing Your Hidden Service

### 1. Verify Services Are Running
```bash
# Check Nginx
systemctl status nginx
curl http://127.0.0.1:80

# Check Tor
systemctl status tor

# Check SSH
systemctl status ssh
ssh -p 4242 localhost
```

### 2. Get Your .onion Address
```bash
cat /var/lib/tor/hidden_service/hostname
# Output: xxxxxxxxxxxxxxxxx.onion
```

### 3. Access from Tor Browser
1. Download and install [Tor Browser](https://www.torproject.org/download/)
2. Open Tor Browser
3. Navigate to your `.onion` address
4. Verify your page loads correctly

---

## 📝 Evaluation Checklist

### Mandatory Requirements
- [ ] Nginx server configured and running
- [ ] Page accessible via HTTP on port 80
- [ ] Tor service configured correctly (torrc)
- [ ] Page accessible from .onion address
- [ ] SSH enabled on port 4242
- [ ] SSH properly configured (sshd_config)
- [ ] No manually opened ports or firewall rules
- [ ] All required files present
- [ ] Implementation method justified

### Bonus (if applicable)
- [ ] SSH hardening implemented and functional
- [ ] Interactive application functional
- [ ] Additional security measures documented

---

## 📚 Resources

### Official Documentation
- [Tor Project](https://www.torproject.org/)
- [Tor Hidden Service Setup](https://community.torproject.org/onion-services/setup/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [SSH Hardening Guide](https://www.ssh.com/academy/ssh/sshd_config)

### Useful Tools
- [Tor Browser](https://www.torproject.org/download/) - For testing
- [OnionShare](https://onionshare.org/) - Inspiration for hidden services
- [Docker](https://www.docker.com/) - For containerization

---

## ⚠️ Important Notes

1. **Security**: Be careful not to go too far in configuration
2. **Justification**: Must explain all technical decisions
3. **Flexibility**: Can use Docker, VM, or other justified methods
4. **VM**: If using virtual machine, not necessary to upload to repo
5. **File Names**: Verify folders and files have correct names
6. **Testing**: Test your hidden service from Tor Browser before submission
7. **Anonymity**: Never host illegal content or services

---

## 🎓 Learning Outcomes

After completing this project, you will understand:
- How Tor network works
- Hidden service architecture
- Web server configuration
- SSH security practices
- Network anonymity concepts
- Service deployment methods

---

**Note**: This project is part of the 42 Cybersecurity Piscine. The full subject is available in `en.subject.pdf`.

**Remember**: With great power comes great responsibility. Use Tor and hidden services ethically and legally.
