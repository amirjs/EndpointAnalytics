Reporting on Application Crashes Using Intune Analytics and Microsoft Graph Powershell

In today’s modern workplace, ensuring device performance and application reliability is critical for maintaining user productivity. Microsoft Intune’s Endpoint Analytics provides valuable insights into device health, enabling IT administrators to proactively identify and resolve application issues before they impact end users.

One powerful feature within Endpoint Analytics is Application Reliability, which helps IT teams monitor application crashes, hangs, and failures across managed devices. Using PowerShell with Microsoft Graph API, we can take this a step further—automating the process of identifying devices that need attention, retrieving the primary user, and sending an HTML email notification using the PSWriteHTML module.

Application Reliability & Licensing Requirements
Application Reliability in Endpoint Analytics provides deep insights into how frequently applications crash and how they affect end-user productivity. It helps IT teams take data-driven actions to mitigate software issues. However, to use Application Reliability, devices must have appropriate licensing, including:

Microsoft 365 Business Premium, E3, or E5
Windows 10/11 Enterprise E3 or E5 (part of M365 F3, E3, or E5)
Windows Virtual Desktop Access E3 or E5
For a complete breakdown, check Microsoft’s official documentation. 


Automating Insights with PowerShell and Microsoft Graph API
While Endpoint Analytics offers a user-friendly dashboard, automation can take things further. The script available at Github demonstrates how we can:

✔ Authenticate to Microsoft Graph API

✔ Fetch a list of devices flagged by Endpoint Analytics

✔ Retrieve the primary user of each affected device

✔ Generate a structured HTML email using the PSWriteHTML module

✔ Notify users about detected issues with a professional-looking email


This approach allows IT administrators to move from passive monitoring to proactive communication.

The script requires DeviceManagementConfiguration.Read.All API permissions (least Privileged)



By implementing such a script, organizations can proactively engage users in the troubleshooting process, potentially reducing downtime and enhancing the overall efficiency of IT operations. This approach not only showcases the technical capabilities of integrating PowerShell with the Microsoft Graph API but also emphasizes the importance of user communication in maintaining application reliability.

Users (or IT Support) would get an email showing details of apps crashing in the last 14 days

 


Expanding the Use Case: IT Support Notifications
While this script is designed to notify end users, it can easily be repurposed for IT teams. Instead of notifying users directly, we can send a report to IT support, highlighting devices with repeated failures and suggesting proactive troubleshooting steps.

 

Conclusion
This PowerShell + Microsoft Graph API integration, combined with PSWriteHTML, showcases “the art of what’s possible” with Intune Endpoint Analytics. By automating issue detection and proactively engaging users, IT teams can minimize downtime, enhance user experience, and demonstrate the power of automation in device management.

🚀 Ready to try it out? Grab the script here: EndpointAnalyticsGraph.ps1.

Let me know if you’d like further refinements!
