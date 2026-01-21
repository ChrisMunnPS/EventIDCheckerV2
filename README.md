# 🔍 Enhanced Event Log Viewer v2.0 - SOC Edition

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)
[![Maintenance](https://img.shields.io/badge/Maintained-Yes-brightgreen.svg)](https://github.com/ChrisMunnPS/EventIDCheckerV2)

A powerful GUI-based Windows Event Log analysis tool designed for Security Operations Centers (SOC), forensic analysts, and system administrators. Search and analyze event logs from both live machines and imported EVTX files with an intuitive interface.

![Event Log Viewer](https://via.placeholder.com/800x400/2C3E50/ECF0F1?text=Enhanced+Event+Log+Viewer+v2.0)

---

## 📋 Executive Summary

### What Is It?

Enhanced Event Log Viewer v2.0 is a comprehensive PowerShell-based GUI application that simplifies the analysis of Windows Event Logs. Whether you're investigating security incidents, troubleshooting system issues, or conducting forensic analysis, this tool provides a streamlined interface to search, filter, and export event data.

### 🎯 Key Features at a Glance

- **🖥️ Dual Source Support**: Query live machines or analyze imported EVTX files
- **🛡️ 15 Preconfigured Categories**: From basic account activity to advanced Sysmon telemetry and Kerberos security
- **⚡ Optimized Performance**: FilterHashtable queries and pagination for handling large datasets
- **📊 Multiple Export Formats**: CSV and Excel export capabilities
- **🔄 Auto-Refresh**: Real-time monitoring with configurable intervals
- **🎨 User-Friendly Interface**: Intuitive GUI with color-coded event categories
- **🔎 Advanced Filtering**: Filter by date range, event ID, and text search
- **🔐 Kerberos Security**: NEW - Track weak RC4 encryption and KDC issues

### 👥 Who Should Use This?

- **Security Analysts**: Investigate security events, failed logons, privilege escalations
- **Forensic Investigators**: Analyze EVTX files from compromised systems
- **System Administrators**: Troubleshoot server health and application issues
- **Incident Responders**: Quickly triage and export relevant event data
- **IT Auditors**: Review authentication and access control events
- **Active Directory Admins**: Monitor Kerberos encryption and KDC health

### ⏱️ Quick Start

1. Download all 5 PowerShell files to the same directory
2. Right-click `EventLogViewer_V2.ps1` → **Run with PowerShell** (as Administrator)
3. Select a category, set date range, and click **Search**
4. Export results or import EVTX files for offline analysis

---

## 🚀 Installation & Requirements

### System Requirements

| Component | Requirement |
|-----------|-------------|
| **Operating System** | Windows 10/11, Windows Server 2016+ |
| **PowerShell** | Version 5.1 or higher |
| **Privileges** | Administrator rights (for Security log access) |
| **Memory** | 4GB RAM minimum, 8GB+ recommended |
| **.NET Framework** | 4.5+ (included in Windows 10+) |

### 📦 Installation Steps

1. **Download the repository**:
   ```powershell
   git clone https://github.com/ChrisMunnPS/EventIDCheckerV2.git
   cd EventIDCheckerV2
   ```

2. **Verify all files are present**:
   - `EventLogViewer_V2.ps1` (Main launcher)
   - `EventLogViewer_Categories.ps1` (Event definitions)
   - `EventLogViewer_Functions.ps1` (Core logic)
   - `EventLogViewer_UI.ps1` (GUI definition)
   - `EventLogViewer_Handlers.ps1` (Event handlers)

3. **Set execution policy** (if needed):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

4. **Launch the application**:
   ```powershell
   .\EventLogViewer_V2.ps1
   ```

### ⚠️ Important Notes

- **Administrator privileges** are required to access Security event logs
- **Excel export** requires Microsoft Excel to be installed
- For **Sysmon logs**, ensure Sysmon is installed and configured on target systems
- **Kerberos/KDC events** (Event ID 205) only appear on Domain Controllers

---

## 📚 Feature Overview

### 🗂️ Event Categories

The tool organizes events into **15 specialized categories**:

#### **Windows Security Events** (Standard)
| Category | Events Tracked | Use Case |
|----------|---------------|----------|
| 🔐 **Account Activity** | Logons, logoffs, Kerberos, NTLM | Track user authentication patterns |
| 👤 **AD Account Changes** | Account creation, deletion, modifications | Monitor user lifecycle |
| ⚠️ **Security Threats** | Audit log clearing, LDAP attacks, file access | Detect suspicious activity |
| 🖥️ **Server Health** | Unexpected shutdowns, system errors | Troubleshoot reliability issues |
| 📱 **Application Issues** | Crashes, hangs, installation errors | Debug application problems |

#### **SOC & Forensic Logs** (Advanced)
| Category | Events Tracked | Use Case |
|----------|---------------|----------|
| 🔬 **Sysmon Process Activity** | Process creation, network connections, registry changes | Advanced threat hunting |
| 💻 **PowerShell Activity** | Script execution, command logging | Detect malicious PowerShell usage |
| 🛡️ **Defender Threats** | Malware detections, real-time protection events | Monitor antivirus activity |
| 🔥 **Windows Firewall** | Rule changes, blocked connections | Audit firewall configuration |
| ⏰ **Task Scheduler** | Task creation, execution, deletion | Identify persistence mechanisms |

#### **Advanced Monitoring**
| Category | Events Tracked | Use Case |
|----------|---------------|----------|
| 🖥️ **Remote Desktop** | RDP connections, authentication | Monitor remote access |
| ✅ **Code Integrity** | Driver validation, unsigned code | Detect rootkits and malware |
| 🔧 **WMI Activity** | WMI queries, event registrations | Identify WMI-based attacks |
| 🔒 **BitLocker** | Encryption status, unlock failures | Track drive encryption |
| 🔐 **Kerberos/KDC** ⭐ **NEW** | RC4 encryption, KDC certificates, processing errors | Secure Kerberos infrastructure |

### 🆕 NEW: Kerberos/KDC Category

The latest addition focuses on Active Directory authentication security:

**Event IDs Included:**
- **205** - Service account using weak RC4 encryption ⚠️ **CRITICAL**
- **206** - KDC certificate about to expire
- **207** - KDC certificate expired
- **27** - KDC failed to find suitable certificate
- **28** - KDC using self-signed certificate
- **29** - KDC certificate missing Extended Key Usage
- **30** - KDC received invalid request
- **31** - KDC processing error
- **32** - KDC unable to generate referral

**Why Event ID 205 Matters:**
```
⚠️ SECURITY RISK: RC4 encryption is cryptographically weak
✅ COMPLIANCE: PCI DSS, HIPAA, SOX may require strong encryption
🎯 DETECTION: Identify accounts vulnerable to credential attacks
📊 AUDIT: Document encryption standards before disabling RC4
```

**Remediation for Event ID 205:**
```powershell
# Update service account to use AES encryption
Set-ADUser -Identity "ServiceAccountName" -KerberosEncryptionType AES128,AES256

# Verify the change
Get-ADUser "ServiceAccountName" -Properties msDS-SupportedEncryptionTypes
```

### 🎛️ Search Capabilities

#### **Live Machine Search**
Query event logs from local or remote Windows systems in real-time.

```powershell
# Example: Search for failed logons on remote server
Source: Live Machine
Computer: SERVER01
Category: Account Activity
Event ID: 4625 - Failed logon attempt
Date Range: Last 7 days
```

#### **Imported File Search**
Analyze EVTX files collected from offline systems or incident response.

```powershell
# Example: Analyze multiple EVTX files from compromised workstation
1. Click "Import EVTX"
2. Select multiple .evtx files
3. Tool auto-detects date range
4. Search across all imported files simultaneously
```

### 📤 Export Options

| Format | Use Case | Features |
|--------|----------|----------|
| **CSV** | Data analysis, SIEM import | Lightweight, compatible with all tools |
| **Excel** | Reporting, formatted analysis | Auto-formatted headers, colored cells |

---

## 🎓 Usage Examples

### Example 1: Investigating Failed Logon Attempts

**Scenario**: Detect potential brute-force attacks

```
1. Select "Account Activity" category
2. Choose Event ID: "4625 - Failed logon attempt"
3. Set date range: Last 24 hours
4. Click "Search"
5. Export to Excel for detailed analysis
```

**What to look for**:
- Multiple failures from same source IP
- Failures across multiple accounts
- High volume in short time period

---

### Example 2: Forensic Analysis of Sysmon Logs

**Scenario**: Analyze process execution on compromised system

```
1. Click "Import EVTX" → Select Sysmon.evtx files
2. Select "Sysmon Process Activity" category
3. Choose "1 - Process creation"
4. Use text filter: "powershell" or "cmd.exe"
5. Review command-line arguments in Message column
```

**Detection opportunities**:
- Suspicious PowerShell commands (Invoke-Expression, DownloadString)
- Lateral movement tools (psexec, wmic)
- Credential dumping (mimikatz, procdump)

---

### Example 3: Monitoring Privilege Escalation

**Scenario**: Track accounts added to administrative groups

```
1. Select "AD Account Changes" category
2. Choose Event ID: "4732 - User added to security group"
3. Date range: Last 30 days
4. Click "Search"
5. Double-click events to view full details
```

**Red flags**:
- Non-administrator accounts added to Domain Admins
- Service accounts granted administrative privileges
- After-hours group membership changes

---

### Example 4: Tracking PowerShell Script Execution

**Scenario**: Identify malicious script activity

```
1. Select "PowerShell Activity" category
2. Choose Event ID: "4104 - Script block logging"
3. Text Search: "Invoke-Mimikatz" or "bypass"
4. Export results for threat intelligence correlation
```

**Indicators of compromise**:
- Obfuscated code (Base64, compression)
- Downloads from suspicious domains
- Attempts to disable security controls

---

### Example 5: 🆕 Auditing Weak Kerberos Encryption

**Scenario**: Find service accounts using RC4 before disabling it domain-wide

```
1. Select "Kerberos/KDC" category
2. Choose Event ID: "205 - Service account using weak RC4 encryption"
3. Date range: Last 30 days
4. Click "Search"
5. Document all accounts for remediation
```

**Action items**:
- Create inventory of affected service accounts
- Test AES encryption compatibility
- Update accounts to use AES128/AES256
- Disable RC4 via Group Policy once all accounts updated

---

## 🔧 Technical Details

### Architecture

The application is modular, consisting of 5 interconnected PowerShell scripts:

```
EventLogViewer_V2.ps1 (Main)
├── EventLogViewer_Categories.ps1    # Event ID definitions (15 categories)
├── EventLogViewer_Functions.ps1     # Search & processing logic
├── EventLogViewer_UI.ps1            # XAML-based GUI
└── EventLogViewer_Handlers.ps1      # Button/event handlers
```

### Performance Optimizations

1. **FilterHashtable Queries**: Uses native Windows Event Log filtering for speed
2. **Pagination**: Displays 100 events per page (configurable: 50/100/250/500)
3. **Virtualization**: DataGrid virtualizes rows for smooth scrolling
4. **Cancellable Searches**: Stop long-running queries with "Stop" button
5. **In-Memory Processing**: Events stored in ArrayList for fast filtering

### Search Algorithm

```powershell
# Simplified search flow
1. Determine source (Live vs Imported)
2. Build FilterHashtable with:
   - LogName (Security, System, Application, Sysmon, etc.)
   - Event IDs (from selected category)
   - StartTime / EndTime (date range)
3. Query events using Get-WinEvent
4. Apply text filter (if specified)
5. Paginate results
6. Display in DataGrid
```

### Event ID Mapping

Each category contains specific event IDs with human-readable descriptions:

```powershell
# Example: Account Activity category
4624 → "Successful logon"
4625 → "Failed logon attempt"
4634 → "Logoff"
4648 → "Explicit credentials used"
4768 → "Kerberos TGT request"

# Example: NEW Kerberos/KDC category
205 → "Service account using weak RC4 encryption"
206 → "KDC certificate about to expire"
207 → "KDC certificate expired"
```

This eliminates the need to memorize event ID numbers.

---

## 🎨 User Interface Guide

### Main Window Layout

```
┌─────────────────────────────────────────────────────────────┐
│  [Windows Security Events: 5 categories]                    │
├─────────────────────────────────────────────────────────────┤
│  [SOC and Forensic Logs: 5 categories]                      │
├─────────────────────────────────────────────────────────────┤
│  [Advanced Monitoring: 5 categories including Kerberos]     │
├─────────────────────────────────────────────────────────────┤
│  Source: [Live/Imported]  Computer: [____]                  │
│  Start Date: [____]  End Date: [____]                       │
│  Event ID: [Dropdown]  Text Search: [____]                  │
├─────────────────────────────────────────────────────────────┤
│  [Search] [Stop] [Clear] | [Import] [Manage Files]          │
│  [Export CSV] [Export Excel] [Web Search] [Auto-Refresh]    │
├─────────────────────────────────────────────────────────────┤
│  Status: "Showing 1-100 of 4,177 events"                    │
├─────────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────────┐  │
│  │   [Event Grid - 7 columns]                           │   │
│  │   Time | Log | Source | ID | Meaning | Level | Msg   │   │
│  │   ───────────────────────────────────────────────────│   │
│  │   2025-01-16 14:32:18 | Security | ...               │   │
│  │   2025-01-16 14:31:05 | Security | ...               │   │
│  └───────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│  [First] [Prev]  Page 1 of 42  [Next] [Last]  Per Page    │
└─────────────────────────────────────────────────────────────┘
```

### Color Coding

- **Green Search Button**: Initiate search
- **Red Stop Button**: Cancel running search
- **Yellow Status Bar**: Shows imported file count
- **Blue Status Text**: Real-time operation status
- **Cornsilk Background**: SOC/Forensic logs section
- **Light Blue Background**: Advanced Monitoring section (includes Kerberos)
- **Alternating Rows**: Gray/white for readability
- **Hover Effect**: Light blue highlight

---

## 🆘 Troubleshooting

### Common Issues

#### ❌ "Access Denied" Error
**Problem**: Cannot access Security event log  
**Solution**: Run PowerShell as Administrator

```powershell
# Right-click PowerShell → Run as Administrator
.\EventLogViewer_V2.ps1
```

#### ❌ "Execution Policy" Error
**Problem**: Script execution is disabled  
**Solution**: Set execution policy

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### ❌ No Sysmon Events Found
**Problem**: Sysmon logs don't appear  
**Solution**: Install Sysmon on target system

```powershell
# Download Sysmon from Microsoft Sysinternals
sysmon64.exe -accepteula -i
```

#### ❌ No Event ID 205 (Kerberos RC4) Found
**Problem**: Kerberos/KDC events don't appear  
**Solution**: 
- Event ID 205 only logs on **Domain Controllers**, not workstations
- Ensure you're searching the **System** log (automatic with category selection)
- If no events found, congratulations! Your environment isn't using RC4

```powershell
# To manually check for RC4 usage:
Get-WinEvent -FilterHashtable @{LogName='System'; ID=205} -MaxEvents 10
```

#### ❌ Excel Export Fails
**Problem**: "Excel is not installed" error  
**Solution**: Use CSV export or install Microsoft Excel

#### ❌ Remote Computer Search Fails
**Problem**: Cannot connect to remote system  
**Solution**: Verify:
- Remote system is online
- Windows Remote Management (WinRM) is enabled
- Firewall allows WMI/RPC traffic
- You have administrative credentials

```powershell
# Test WinRM connectivity
Test-WSMan -ComputerName SERVER01
```

#### ⚠️ Slow Search Performance
**Problem**: Search takes too long  
**Solution**: 
- Narrow date range
- Select specific Event ID instead of "All"
- Import files to local disk (not network share)
- Increase RAM allocation

#### ❌ Pagination Not Visible
**Problem**: Can't see page navigation buttons  
**Solution**: 
- Ensure you're using the latest version (v2.0+)
- The pagination bar is now always visible at the bottom
- Try maximizing the window

---

## 🔐 Security Considerations

### Permissions Required

- **Local Security Log**: Administrator or "Manage auditing and security log" right
- **Remote Queries**: Member of Administrators group on target system
- **EVTX Files**: Read access to file location
- **Kerberos Events**: Domain Controller access for Event ID 205

### Best Practices

1. **Limit Remote Access**: Only query trusted systems
2. **Secure EVTX Files**: Store forensic evidence on encrypted drives
3. **Audit Tool Usage**: Log who runs searches and what data is exported
4. **Protect Exports**: CSV/Excel files may contain sensitive information
5. **Use Read-Only Accounts**: For forensic analysis, avoid write access
6. **Monitor RC4 Usage**: Regular Event ID 205 audits before disabling RC4

---

## 📖 Additional Resources

### Learning Resources

- [Microsoft Event ID Documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-policy)
- [Sysmon Configuration Guide](https://github.com/SwiftOnSecurity/sysmon-config)
- [Windows Event Log Reference](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/)
- [SANS Digital Forensics Posters](https://www.sans.org/posters/)
- [Kerberos Encryption Types](https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/network-security-configure-encryption-types-allowed-for-kerberos)
- [Disabling RC4 in Active Directory](https://techcommunity.microsoft.com/t5/ask-the-directory-services-team/weak-kerberos-encryption-types-and-you/ba-p/400520)


---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Report Bugs**: Open an issue with detailed reproduction steps
2. **Suggest Features**: Propose new event categories or functionality
3. **Submit Pull Requests**: Add new features or fix bugs
4. **Improve Documentation**: Enhance this README or add code comments
5. **Share Use Cases**: Describe how you use the tool in your environment

### Development Setup

```powershell
# Fork the repository
git clone https://github.com/YourUsername/EventIDCheckerV2.git

# Create a feature branch
git checkout -b feature/new-category

# Make changes and test
.\EventLogViewer_V2.ps1

# Commit and push
git add .
git commit -m "Add DNS query event category"
git push origin feature/new-category
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Chris Munn**

- GitHub: [@ChrisMunnPS](https://github.com/ChrisMunnPS)
- LinkedIn: [Connect](https://www.linkedin.com/in/chrismunnps)

---

## ⭐ Acknowledgments

- Microsoft Sysinternals team for Sysmon
- PowerShell community for WPF/XAML examples
- Security researchers for event ID documentation
- Active Directory community for Kerberos best practices
- Contributors and users who provide feedback

---

## 📊 Statistics

![GitHub stars](https://img.shields.io/github/stars/ChrisMunnPS/EventIDCheckerV2?style=social)
![GitHub forks](https://img.shields.io/github/forks/ChrisMunnPS/EventIDCheckerV2?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/ChrisMunnPS/EventIDCheckerV2?style=social)

---

## 🗺️ Roadmap

### Recently Added (v2.0)

- ✅ **Kerberos/KDC Category**: Track weak RC4 encryption (Event ID 205)
- ✅ **Fixed Pagination**: Always visible navigation bar
- ✅ **Improved Performance**: Optimized EVTX file searching
- ✅ **15 Event Categories**: Expanded from 14 to 15



## 📋 Version History

### v2.0 (Current) - January 2025
- ✅ Added Kerberos/KDC category with Event ID 205
- ✅ Fixed pagination visibility issues
- ✅ Improved DataGrid layout and performance
- ✅ 15 total event categories
- ✅ Enhanced EVTX file import with auto date detection

### v1.0 - 2024
- 14 event categories
- Basic event log searching
- CSV/Excel export
- Live machine and EVTX file support

---

## 🔍 Event Category Quick Reference

| # | Category | Log Source | Key Event IDs | Primary Use |
|---|----------|-----------|---------------|-------------|
| 1 | Account Activity | Security | 4624, 4625, 4768, 4769 | Authentication tracking |
| 2 | AD Account Changes | Security | 4720, 4726, 4732, 4740 | User lifecycle |
| 3 | Security Threats | Security | 1102, 4688, 5140 | Threat detection |
| 4 | Server Health | System | 41, 6008, 1074 | Reliability |
| 5 | Application Issues | Application | 1000, 1001, 1002 | App debugging |
| 6 | Sysmon | Sysmon/Operational | 1, 3, 7, 10, 11 | Threat hunting |
| 7 | PowerShell | PowerShell/Operational | 4103, 4104 | Script monitoring |
| 8 | Defender | Defender/Operational | 1006, 1116, 1117 | Malware detection |
| 9 | Firewall | Firewall/Firewall | 2003, 2004, 2005 | Network security |
| 10 | Task Scheduler | TaskScheduler/Operational | 106, 129, 141 | Persistence |
| 11 | Remote Desktop | TerminalServices | 1149, 261, 1158 | RDP monitoring |
| 12 | Code Integrity | CodeIntegrity/Operational | 3001, 3004 | Rootkit detection |
| 13 | WMI Activity | WMI-Activity/Operational | 5857, 5859, 5861 | WMI attacks |
| 14 | BitLocker | BitLocker/Management | 24577, 24578 | Encryption |
| 15 | **Kerberos/KDC** ⭐ | System | **205**, 206, 207 | **Auth security** |

---

<div align="center">

### 💙 If this tool helped you, please consider giving it a ⭐!

**Made with ❤️ for the cybersecurity community**

### 🔐 Secure Your Active Directory - Track RC4 Encryption Today!

</div>
