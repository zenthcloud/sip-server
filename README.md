# Zenth SIP Server

**Zenth SIP Server** is a fully open-source, sovereign SIP/VoIP solution developed as part of the Zenth Cloud ecosystem by Sky Genesis Enterprise. It provides a modular, secure, and extensible platform for real-time voice communication using open standards like SIP and RTP.

## 🚀 Features

- ✅ Full SIP/VoIP stack (INVITE, REGISTER, BYE, etc.)
- ✅ Native support for audio call routing and SIP trunking
- ✅ LDAP authentication and user provisioning
- ✅ Integrated with Zenth API (`api-server`) and Zenth OS
- ✅ Built-in NAT traversal (STUN/TURN/ICE)
- ✅ Support for TLS/SRTP for secure communication
- ✅ Fully customizable dial plans and extensions
- ✅ Modular backend compatible with Asterisk or Kamailio

## 📦 Part of the Zenth Cloud Stack

Zenth SIP Server is part of the sovereign and ethical Zenth Cloud suite, and integrates seamlessly with:

- `ldap-server` – User directory
- `panel-server` – Web administration interface
- `status-server` – Real-time service monitoring
- `api-server` – Central unified API interface
- `firewall-server` – Secure VoIP network perimeter
- `dns-server` – SIP SRV and ENUM support

## 🛠️ Technology

- SIP stack based on [Asterisk](https://www.asterisk.org/) or [Kamailio](https://www.kamailio.org/) (depending on mode)
- Containerized for deployment in Proxmox, Docker, or Kubernetes
- AGPLv3 licensed for maximum openness and transparency

## 📖 Documentation

Full documentation is available in the `/docs` folder or on [Documentations](https://docs.zenthcloud.com).

## 🛡️ License

This project is licensed under the **GNU Affero General Public License v3 (AGPLv3)**. See `LICENSE` for more details.

---

For contributions, issues, or forks, feel free to open a pull request or start a discussion on [github.com/zenthcloud](https://github.com/zenthcloud).
