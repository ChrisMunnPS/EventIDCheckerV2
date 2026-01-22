# Define event categories with their associated log names, event IDs, and providers
$script:categories = @{
    "AccountActivity" = @{ 
        Log = "Security"
        Provider = "Microsoft-Windows-Security-Auditing"
        IDs = @(
            @{ ID = 4624; Meaning = "Successful logon" }
            @{ ID = 4625; Meaning = "Failed logon attempt" }
            @{ ID = 4634; Meaning = "Logoff" }
            @{ ID = 4647; Meaning = "User-initiated logoff" }
            @{ ID = 4648; Meaning = "Explicit credentials used" }
            @{ ID = 4672; Meaning = "Security ID assigned to user" }
            @{ ID = 4768; Meaning = "Kerberos TGT request" }
            @{ ID = 4769; Meaning = "Kerberos service ticket request" }
            @{ ID = 4771; Meaning = "Kerberos pre-authentication failed" }
            @{ ID = 4776; Meaning = "NTLM authentication attempt" }
        )
    }
    
    "ADAccountChanges" = @{ 
        Log = "Security"
        Provider = "Microsoft-Windows-Security-Auditing"
        IDs = @(
            @{ ID = 4720; Meaning = "User account created" }
            @{ ID = 4722; Meaning = "User account enabled" }
            @{ ID = 4723; Meaning = "Password change attempt" }
            @{ ID = 4724; Meaning = "Password reset attempt" }
            @{ ID = 4725; Meaning = "User account disabled" }
            @{ ID = 4726; Meaning = "User account deleted" }
            @{ ID = 4732; Meaning = "User added to security group" }
            @{ ID = 4735; Meaning = "Security group modified" }
            @{ ID = 4738; Meaning = "User account modified" }
            @{ ID = 4740; Meaning = "Account locked out" }
            @{ ID = 4756; Meaning = "Security group membership change" }
            @{ ID = 4767; Meaning = "Account unlocked" }
        )
    }
    
    "SecurityThreatIndicators" = @{ 
        Log = "Security"
        Provider = "Microsoft-Windows-Security-Auditing"
        IDs = @(
            @{ ID = 1102; Meaning = "Audit log cleared"; Provider = "Microsoft-Windows-Eventlog" }
            @{ ID = 2886; Meaning = "LDAP unsigned/simple bind detected"; Provider = "Microsoft-Windows-ActiveDirectory_DomainService" }
            @{ ID = 2887; Meaning = "Count of unsigned/simple bind attempts"; Provider = "Microsoft-Windows-ActiveDirectory_DomainService" }
            @{ ID = 2889; Meaning = "Source of unsigned/simple bind"; Provider = "Microsoft-Windows-ActiveDirectory_DomainService" }
            @{ ID = 1644; Meaning = "Expensive LDAP query detected"; Provider = "Microsoft-Windows-ActiveDirectory_DomainService" }
            @{ ID = 4627; Meaning = "Group membership information" }
            @{ ID = 4663; Meaning = "Access to an object" }
            @{ ID = 4688; Meaning = "Process created" }
            @{ ID = 4689; Meaning = "Process terminated" }
            @{ ID = 5140; Meaning = "Network share accessed" }
            @{ ID = 5145; Meaning = "Network share object accessed" }
        )
    }
    
    "ServerHealthReliability" = @{ 
        Log = "System"
        Provider = $null  # Multiple providers
        IDs = @(
            @{ ID = 41; Meaning = "Kernel-Power: unexpected restart/shutdown"; Provider = "Microsoft-Windows-Kernel-Power" }
            @{ ID = 55; Meaning = "NTFS file system corruption detected"; Provider = "Ntfs" }
            @{ ID = 6005; Meaning = "Event log service started"; Provider = "EventLog" }
            @{ ID = 6006; Meaning = "Event log service stopped"; Provider = "EventLog" }
            @{ ID = 6008; Meaning = "Unexpected shutdown"; Provider = "EventLog" }
            @{ ID = 6009; Meaning = "System startup information"; Provider = "EventLog" }
            @{ ID = 1074; Meaning = "System shutdown/restart initiated"; Provider = "User32" }
            @{ ID = 1014; Meaning = "DNS name resolution failure"; Provider = "Microsoft-Windows-DNS-Client" }
            @{ ID = 1058; Meaning = "Group Policy failure to read from DC"; Provider = "Microsoft-Windows-GroupPolicy" }
            @{ ID = 5719; Meaning = "Netlogon: no DC available"; Provider = "NETLOGON" }
        )
    }
    
    "ApplicationLevelIssues" = @{ 
        Log = "Application"
        Provider = $null  # Multiple providers
        IDs = @(
            @{ ID = 1000; Meaning = "Application error (crash)"; Provider = "Application Error" }
            @{ ID = 1001; Meaning = "Application hang or bugcheck info"; Provider = "Windows Error Reporting" }
            @{ ID = 1002; Meaning = "Application hang"; Provider = "Application Hang" }
            @{ ID = 1309; Meaning = "ASP.NET application error (IIS)"; Provider = "ASP.NET" }
            @{ ID = 11707; Meaning = "Application installation"; Provider = "MsiInstaller" }
        )
    }
    
    "SysmonProcessActivity" = @{
        Log = "Microsoft-Windows-Sysmon/Operational"
        Provider = "Microsoft-Windows-Sysmon"
        IDs = @(
            @{ ID = 1; Meaning = "Process creation" }
            @{ ID = 2; Meaning = "File creation time changed" }
            @{ ID = 3; Meaning = "Network connection" }
            @{ ID = 5; Meaning = "Process terminated" }
            @{ ID = 6; Meaning = "Driver loaded" }
            @{ ID = 7; Meaning = "Image/DLL loaded" }
            @{ ID = 8; Meaning = "CreateRemoteThread detected" }
            @{ ID = 9; Meaning = "RawAccessRead detected" }
            @{ ID = 10; Meaning = "Process access" }
            @{ ID = 11; Meaning = "File created" }
            @{ ID = 12; Meaning = "Registry object added/deleted" }
            @{ ID = 13; Meaning = "Registry value set" }
            @{ ID = 14; Meaning = "Registry object renamed" }
            @{ ID = 15; Meaning = "File stream created" }
            @{ ID = 17; Meaning = "Pipe created" }
            @{ ID = 18; Meaning = "Pipe connected" }
            @{ ID = 19; Meaning = "WMI event filter activity" }
            @{ ID = 20; Meaning = "WMI event consumer activity" }
            @{ ID = 21; Meaning = "WMI event consumer to filter activity" }
            @{ ID = 22; Meaning = "DNS query" }
            @{ ID = 23; Meaning = "File delete archived" }
            @{ ID = 24; Meaning = "Clipboard capture" }
            @{ ID = 25; Meaning = "Process tampering" }
            @{ ID = 26; Meaning = "File delete logged" }
            @{ ID = 27; Meaning = "File block executable" }
            @{ ID = 28; Meaning = "File block shredding" }
            @{ ID = 29; Meaning = "File executable detected" }
        )
    }
    
    "PowerShellActivity" = @{
        Log = "Microsoft-Windows-PowerShell/Operational"
        Provider = "Microsoft-Windows-PowerShell"
        IDs = @(
            @{ ID = 4103; Meaning = "Module logging (pipeline execution)" }
            @{ ID = 4104; Meaning = "Script block logging" }
            @{ ID = 4105; Meaning = "Script block logging (start)" }
            @{ ID = 4106; Meaning = "Script block logging (stop)" }
            @{ ID = 40961; Meaning = "PowerShell console starting" }
            @{ ID = 40962; Meaning = "PowerShell console ready" }
            @{ ID = 53504; Meaning = "PowerShell named pipe IPC" }
        )
    }
    
    "DefenderThreats" = @{
        Log = "Microsoft-Windows-Windows Defender/Operational"
        Provider = "Microsoft-Windows-Windows Defender"
        IDs = @(
            @{ ID = 1006; Meaning = "Malware detected" }
            @{ ID = 1007; Meaning = "Malware action taken" }
            @{ ID = 1008; Meaning = "Malware action failed" }
            @{ ID = 1009; Meaning = "Malware restore failed" }
            @{ ID = 1013; Meaning = "Malware history deleted" }
            @{ ID = 1015; Meaning = "Suspicious behavior detected" }
            @{ ID = 1116; Meaning = "Malware detected by real-time protection" }
            @{ ID = 1117; Meaning = "Action taken to protect system" }
            @{ ID = 1118; Meaning = "Action failed" }
            @{ ID = 1119; Meaning = "Critical error in action" }
            @{ ID = 5001; Meaning = "Real-time protection disabled" }
            @{ ID = 5004; Meaning = "Real-time protection config changed" }
            @{ ID = 5007; Meaning = "Platform configuration changed" }
            @{ ID = 5010; Meaning = "Scanning for malware disabled" }
            @{ ID = 5012; Meaning = "Scanning for viruses disabled" }
        )
    }
    
    "WindowsFirewall" = @{
        Log = "Microsoft-Windows-Windows Firewall With Advanced Security/Firewall"
        Provider = "Microsoft-Windows-Windows Firewall With Advanced Security"
        IDs = @(
            @{ ID = 2003; Meaning = "Firewall rule added" }
            @{ ID = 2004; Meaning = "Firewall rule modified" }
            @{ ID = 2005; Meaning = "Firewall rule deleted" }
            @{ ID = 2006; Meaning = "Firewall rule deleted (local)" }
            @{ ID = 2033; Meaning = "Firewall rule add failed" }
        )
    }
    
    "TaskScheduler" = @{
        Log = "Microsoft-Windows-TaskScheduler/Operational"
        Provider = "Microsoft-Windows-TaskScheduler"
        IDs = @(
            @{ ID = 106; Meaning = "Task registered" }
            @{ ID = 129; Meaning = "Task launched" }
            @{ ID = 141; Meaning = "Task removed" }
            @{ ID = 200; Meaning = "Task executed" }
            @{ ID = 201; Meaning = "Task completed" }
        )
    }
    
    "RemoteDesktop" = @{
        Log = "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational"
        Provider = "Microsoft-Windows-TerminalServices-RemoteConnectionManager"
        IDs = @(
            @{ ID = 1149; Meaning = "RDP authentication successful" }
            @{ ID = 261; Meaning = "RDP connection received" }
            @{ ID = 1158; Meaning = "RDP connection allowed" }
        )
    }
    
    "CodeIntegrity" = @{
        Log = "Microsoft-Windows-CodeIntegrity/Operational"
        Provider = "Microsoft-Windows-CodeIntegrity"
        IDs = @(
            @{ ID = 3001; Meaning = "Code integrity check failed" }
            @{ ID = 3002; Meaning = "Code integrity check passed" }
            @{ ID = 3004; Meaning = "Unsigned driver blocked" }
            @{ ID = 3033; Meaning = "Driver revoked" }
            @{ ID = 3076; Meaning = "Image validation failure" }
            @{ ID = 3077; Meaning = "Image validated" }
        )
    }
    
    "WMIActivity" = @{
        Log = "Microsoft-Windows-WMI-Activity/Operational"
        Provider = "Microsoft-Windows-WMI-Activity"
        IDs = @(
            @{ ID = 5857; Meaning = "WMI activity detected" }
            @{ ID = 5858; Meaning = "WMI error" }
            @{ ID = 5859; Meaning = "WMI permanent event registration" }
            @{ ID = 5860; Meaning = "WMI temporary event registration" }
            @{ ID = 5861; Meaning = "WMI event filter activity" }
        )
    }
    
    "BitLocker" = @{
        Log = "Microsoft-Windows-BitLocker/BitLocker Management"
        Provider = "Microsoft-Windows-BitLocker-API"
        IDs = @(
            @{ ID = 24577; Meaning = "BitLocker encryption started" }
            @{ ID = 24578; Meaning = "BitLocker encryption completed" }
            @{ ID = 24579; Meaning = "BitLocker encryption paused" }
            @{ ID = 24580; Meaning = "BitLocker decryption started" }
            @{ ID = 24622; Meaning = "BitLocker unlock failed" }
        )
    }
    
    "KerberosKDC" = @{
        Log = "System"
        Provider = "Microsoft-Windows-Kdc"  # Specific provider for KDC events
        IDs = @(
            @{ ID = 205; Meaning = "Service account using weak RC4 encryption"; Provider = "Microsoft-Windows-Kdc" }
            @{ ID = 206; Meaning = "KDC certificate about to expire"; Provider = "Microsoft-Windows-Kdc" }
            @{ ID = 207; Meaning = "KDC certificate expired"; Provider = "Microsoft-Windows-Kdc" }
            @{ ID = 27; Meaning = "KDC failed to find suitable certificate"; Provider = "Microsoft-Windows-Kdc" }
            @{ ID = 28; Meaning = "KDC using self-signed certificate"; Provider = "Microsoft-Windows-Kdc" }
            @{ ID = 29; Meaning = "KDC certificate missing Extended Key Usage"; Provider = "Microsoft-Windows-Kdc" }
            @{ ID = 30; Meaning = "KDC received invalid request"; Provider = "Microsoft-Windows-Kdc" }
            @{ ID = 31; Meaning = "KDC processing error"; Provider = "Microsoft-Windows-Kdc" }
            @{ ID = 32; Meaning = "KDC unable to generate referral"; Provider = "Microsoft-Windows-Kdc" }
        )
    }
}

<#
.NOTES
Event ID Conflict Resolution:
- Each event now includes Provider information where conflicts exist
- Event ID 27: Sysmon (File block) vs KDC (Cert not found) - resolved by provider
- Event ID 28: Sysmon (File shredding) vs KDC (Self-signed cert) - resolved by provider
- Event ID 55: Kernel-Processor-Power vs NTFS corruption - resolved by provider (Ntfs)
- Event ID 41: Kernel-Power shutdown - specified provider for accuracy
- Event ID 1102: Security log cleared - specified Eventlog provider

Search functions will filter by both Log and Provider (when specified) to eliminate conflicts.
#>