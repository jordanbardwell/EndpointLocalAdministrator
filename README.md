# EndpointLocalAdministrator

# Overview
Endpoint Local Administrator is a Power Platform solution that allows you to add and remove users as local administrators on an Intune device from a Power App. No more needing to assign the **Azure AD joined device local administrator** role.

![Dashboard](/images/ELA_Dashboard.png)

**Note: Currently, this solution utilizes PowerShell to add and remove local administrators. Once Microsoft _further develops the Graph API for Account Protection_, I will re-work the solution and switch it over to that.**

## Features
- Add user permanently as a local administrator
- Add user temporarily as a local administrator
- Remove user from local administrator

### Job Overview
View the status of a job. If a job is deleted, Azure AD Group(s) and Script(s) associated with the job will be deleted.
![Job Overview](/images/ELA_JobOverview.png)

### Notifications
Receive Teams and/or Outlook adaptivbe card notifications.

![Admin Removed](/images/ELA_Remove_Notification.png)

**Note:** *Adaptive Card notifications are only viewable in Microsoft Teams and Microsoft Outlook*

# Install
## Licensing
Premium licensing in Power Platform is required for this solution to function since it utilizes Dataverse and other premium connectors. You will need Power Automate per user or Power Automate per flow AND either Power Apps per User, App Passes, or Pay as you go subscription.

## Create Originator ID for Actionable Emails
You'll need to create an originator ID from the **[Actionable Email Developer Dashboard](https://outlook.office.com/connectors/oam/publish)**. This will allow you to send actionalable messages within your organization. This is needed if you want to receive alerts via Outlook.

## Find Environment Publisher Prefix
1. Go to [Power Apps](https://make.powerapps.com)
2. Select the **environment** from the **top-right corner** you'll be installing the solution in.
3. Select the **Solutions** tab on the left-side of the page.
4. Select the **Publishers** tab on the top
5. Notate the prefix of the publisher you will use during import. **Example:** *crfb2*

## Installation Instructions
1. Download the un-managed zip file
2. Create an App Registration in Azure AD.
    - Grant the App Registration the following **Microsoft Graph - _Application_** API Permissions:
      - Device.Read.All
      - DeviceManagementConfiguration.ReadWrite.All
      - DeviceManagementManagedDevices.Read.All
      - Directory.Read.All
      - Group.ReadWrite.All
      - GroupMember.ReadWrite.All
    - Once granted, **_Grant admin consent_**.
    - Create a client secret and save the **secret value**.
3. Import the solution into an environment.
    - Set the following environment variables:
      - **AppRegistration_ClientID:** *Use the Application(client) ID from the App Registration you created*
      - **AppRegistration_ClientSecret:** *Use the client secret you created*
      - **AppRegistration_TenantID:** *Use your tenant id*
      - **MothershipURI:** *Copy the URL from the from **Flow - PowerShell Script Listener** within the solution.*
      - **AdaptiveCardOriginatorGUID:** *Originator ID from [Actionable Email Developer Dashboard](https://outlook.office.com/connectors/oam/publish)*
      - **EnvironmentPublisherPrefix:** *Your environment publisher prefix*
 4. Turn on each Flow within the solution.
