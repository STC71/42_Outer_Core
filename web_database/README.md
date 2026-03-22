# 🌐 Web & Database Projects

Esta carpeta contiene proyectos del currículo de Desarrollo Web y Bases de Datos de 42 School, enfocados en aplicaciones full-stack, arquitectura web y seguridad.

---

## 📚 Projects Overview

| Project | Type | Difficulty | Status |
|---------|------|------------|--------|
| [Camagru](./camagru/) | Full-Stack Web App | ⭐⭐⭐ | ✅ Complete |
| [Darkly](./darkly/) | Web Security Audit | ⭐⭐⭐ | ✅ Complete |

---

## 📸 [Camagru](./camagru/) - Instagram-like Web Application

Aplicación web full-stack con captura de fotos desde webcam, edición con stickers y funcionalidades sociales.

### 🎯 Key Features
- 📸 **Webcam Capture**: getUserMedia API for real-time photo capture
- 🎨 **Sticker Overlay**: Real-time image editing with stickers
- 👥 **Authentication System**: Complete user management (register, login, email verification)
- 💬 **Social Interaction**: Likes, comments with AJAX
- 📤 **File Upload**: Secure file validation and handling
- 📱 **Responsive Design**: Mobile, tablet, desktop support
- ✨ **Bonus Features**: Live preview, infinite scroll, animated GIFs

### 🛠️ Tech Stack
- **Backend**: PHP 8.2 (Custom MVC framework)
- **Database**: MySQL 8.0
- **Frontend**: JavaScript Vanilla, HTML5/CSS3
- **DevOps**: Docker, Docker Compose
- **Architecture**: MVC Pattern, RESTful API

### 📖 Documentation
- 19 detailed README files
- 80+ educational videos in Spanish
- Complete project overview and quickstart guide

[📖 Full Documentation](./camagru/README.md)

---

## 🌑 [Darkly](./darkly/) - Web Security Audit

Proyecto de introducción a ciberseguridad web y OWASP. Audita un sitio web vulnerable para descubrir 14 vulnerabilidades de seguridad comunes.

### 🎯 Objectives
- 🔍 **Security Audit**: Discover 14 web vulnerabilities
- 📝 **Documentation**: Comprehensive exploitation documentation
- 🎓 **Learning**: Understand OWASP Top 10 vulnerabilities
- 🛡️ **Prevention**: Learn secure coding practices

### 🔓 Vulnerabilities Covered
1. **SQL Injection** (Basic & Advanced)
2. **Cross-Site Scripting** (XSS - Basic & Advanced)
3. **File Inclusion** vulnerabilities
4. **Cookie Manipulation**
5. **HTTP Header Spoofing**
6. **Authentication Bypass** (htpasswd, Brute Force)
7. **File Upload** bypass
8. **Open Redirect**
9. **Information Disclosure** (Hidden files)
10. **Survey Manipulation**
11. **Account Recovery** vulnerabilities

### 🛠️ Skills Developed
- Web vulnerability assessment (14 vulnerabilities)
- SQL injection techniques (basic & advanced)
- XSS exploitation (reflected & data URI)
- Authentication bypass (cookies, brute force, reset password)
- HTTP header spoofing and manipulation
- File upload bypass techniques
- Path traversal exploitation
- Information disclosure discovery
- Security documentation and reporting
- OWASP Top 10 understanding and analysis
- Automatic flag validation with evaluation.sh

### 📖 Documentation
- [README.md](./darkly/README.md) - Complete project guide with Quick Start
- [VULNERABILITIES_INDEX.md](./darkly/VULNERABILITIES_INDEX.md) - Quick reference table
- [QUICK_SOLUTIONS.md](./darkly/QUICK_SOLUTIONS.md) - Payloads and commands
- [evaluation.sh](./darkly/evaluation.sh) - Automatic flag validation script
- Individual folder for each vulnerability with complete documentation

### 🚀 Getting Started
```bash
cd darkly/
./evaluation.sh  # Automated validation of all flags
```

[📖 Full Documentation](./darkly/README.md)

---

## 🎓 Learning Outcomes

### Web Development (Camagru)
- ✅ Full-stack web application architecture
- ✅ MVC design pattern implementation
- ✅ RESTful API design
- ✅ Database design and optimization
- ✅ Authentication and session management
- ✅ Real-time media handling (webcam)
- ✅ AJAX and asynchronous JavaScript
- ✅ Responsive web design
- ✅ Docker containerization

### Web Security (Darkly)
- ✅ OWASP Top 10 vulnerabilities
- ✅ SQL injection attacks
- ✅ Cross-Site Scripting (XSS)
- ✅ Authentication vulnerabilities
- ✅ Security assessment methodology
- ✅ Vulnerability documentation
- ✅ Secure coding practices
- ✅ HTTP protocol security
- ✅ Attack prevention strategies

---

## 🚀 Quick Start

### Camagru
```bash
cd camagru
make          # Build and start the application
# Access at: http://localhost:8080
```

### Darkly
```bash
cd darkly
# Boot the Darkly_i386.iso in a VM
# Access at: http://172.16.60.128
# Follow IMPLEMENTATION_GUIDE.md for vulnerability discovery
```

---

## 📂 Project Structure

```
web_database/
├── README.md                  # This file
│
├── camagru/                   # Instagram-like web app
│   ├── app/                   # Application source code
│   ├── config/                # Configuration files
│   ├── database/              # Database migrations
│   ├── public/                # Public assets
│   ├── docker-compose.yml     # Docker configuration
│   └── README.md              # Project documentation
│
└── darkly/                    # Web security audit
    ├── 01_sql_injection_basic/
    ├── 02_sql_injection_advanced/
    ├── ... (14 vulnerability folders)
    ├── IMPLEMENTATION_GUIDE.md
    └── README.md
```

---

## 🛡️ Security Considerations

### Camagru Security Features
- ✅ Password hashing (bcrypt)
- ✅ SQL injection prevention (PDO prepared statements)
- ✅ XSS prevention (output escaping)
- ✅ CSRF token protection
- ✅ File upload validation
- ✅ Email verification
- ✅ Secure session handling

### Darkly Security Lessons
- 🔍 Understanding common vulnerabilities
- 🛡️ Learning prevention techniques
- 📝 Documenting security findings
- 🎓 Ethical hacking principles

---

## 📚 Resources

### Web Development
- **PHP Official Documentation**: https://www.php.net/docs.php
- **MySQL Documentation**: https://dev.mysql.com/doc/
- **MDN Web Docs**: https://developer.mozilla.org/
- **Docker Documentation**: https://docs.docker.com/

### Web Security
- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **OWASP Testing Guide**: https://owasp.org/www-project-web-security-testing-guide/
- **PortSwigger Academy**: https://portswigger.net/web-security
- **SQL Injection Guide**: https://owasp.org/www-community/attacks/SQL_Injection

---

## 🤝 Contributing

Improvements and suggestions are welcome:
1. Document the improvement clearly
2. Test thoroughly
3. Follow existing code style
4. Update documentation

---

## 📝 Notes

- **Camagru** is production-ready with comprehensive security measures
- **Darkly** is intentionally vulnerable for educational purposes
- Never deploy Darkly in a production environment
- Always practice responsible disclosure with security findings

---

<div align="center">

**Built with ❤️ for learning web development and security**

[⬅️ Volver al repositorio principal](../)

</div>
