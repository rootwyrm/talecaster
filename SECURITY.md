# Security Policy

To keep the workload at a manageable level, TaleCaster follows a 'latest + 1' security support model and actively retracts unsupported versions where possible.
What this means is that only 'latest' and the most recent quarterly will receive security updates.

We employ various methods to reduce the occurrence and risk of vulnerabilities within TaleCaster itself. These include static and dynamic code analysis, regular scanning, and following general best practices.

# .NET Security Procedures

In the event of vulnerabilities in the .NET runtime, the version will be updated as quickly as prudent. Running containers will generally update and automatically remediate within 24 hours.

# Data Collection Statement

TaleCaster does NOT currently collect any data or personally identifying information except where information is explicitly provided as part of sponsorship or donation.
In a future update, installations will ping a registration server using a securely generated UUID that cannot be de-anonymized. Your IP address may be incidentally collected as part of this, but will not be retained longer than 7 days.

As part of using the application, your data may or will be collected by third party services which we have no control over. We take all reasonable measures to prevent, reduce, or eliminate unwanted data collection. 
We strongly recommend reviewing the data collection policies of services you connect to TaleCaster. 

## Supported Versions

| Version | Supported                     |
| ------- | ----------------------------- |
| latest  | :white_check_mark: **always** |
| 4Q21    | :white_check_mark:            |

## Reporting a Vulnerability

### Note that security issues in the applications within TaleCaster (e.g. Sonarr, Lidarr, NZBget, qBittorrent, etc.) should be addressed with the maintainers of that software!
**We do NOT maintain or have commit access to their respective repositories!**

If you suspect you have identified a vulnerability in TaleCaster (i.e. downrev package with a vulnerability, bad code on our part, etc,) we ask that you open a public issue at this time. 

We're not Enterprise-class FizzBuzz here, and strongly believe that the only way security improves overall is through being transparent about what was done incorrectly.
