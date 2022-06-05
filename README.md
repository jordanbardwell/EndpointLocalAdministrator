# EndpointLocalAdministrator

# Overview
Endpoint Local Administrator is a Power Platform solution that allows you to add and remove users as local administrators on an Intune device from a Power App. No more needing to assign the **Azure AD joined device local administrator** role.

![Dashboard](/images/ELA_Dashboard.png)

**Note: Currently, this solution utilizes PowerShell to add and remove local administrators. Once Microsoft _further develops the Graph API for Account Protection_, I will re-work the solution and switch it over to that.**

## Features
- Add user permanently as a local administrator
- Add user temporarily as a local administrator
- Remove user from local administrator

### Temporary Local Administrators
When assigning a temporary local administrator, the job goes into a sleeping state once the user has been added. A flow runs every 4 hours in the background to compare the date the granted date vs the ending date you selected. Once it has been reached, the job will move to a removing permissions state and remove the user from local administrator.
![Configure a Temporary Local Administrator](/images/ELA_Temporary_Configuration.png)

### Job Overview
***If a job is deleted, Azure AD Group(s) and Script(s) associated with the job will be deleted.***
Job overview of granting a permanent administrator

![Job Overview](/images/ELA_JobOverview.png)

Job overview of granting a temporary administrator
![Job Overview](/images/ELA_Temporary_JobOverview.png)

### Notifications
Receive Teams and/or Outlook adaptivbe card notifications.

![Admin Removed](/images/ELA_Remove_Notification.png)

**Note:** *Adaptive Card notifications are only viewable in Microsoft Teams and Microsoft Outlook. Adaptive cards will not render on other email clients.*

# Installation Instructions
## Licensing
Premium licensing in Power Platform is required for this solution to function since it utilizes Dataverse and other premium connectors. You will need Power Automate per user or Power Automate per flow AND either Power Apps per User, App Passes, or Pay as you go subscription.

## 1. Create Originator ID for Actionable Emails
You'll need to create an originator ID from the **[Actionable Email Developer Dashboard](https://outlook.office.com/connectors/oam/publish)**. This will allow you to send actionalable messages within your organization. This is needed if you want to receive alerts via Outlook.

## 2. Find Environment Publisher Prefix
1. Go to [Power Apps](https://make.powerapps.com)
2. Select the **environment** from the **top-right corner** you'll be installing the solution in.
3. Select the **Solutions** tab on the left-side of the page.
4. Select the **Publishers** tab on the top
5. Notate the prefix of the publisher you will use during import. **Example:** *crfb2*

## 3. Create an App Registration in Azure AD
1. Go to [Azure Active Directory Admin Center](https://aad.portal.azure.com/)
2. Select **App Registrations**
3. Select **New Registration**. 
    1. Name the App Registration. Ex: *Endpoint Local Administrator*
    2. Leave everything else as the default settings. Select **Register**
    3. Grant the App Registration the following **Microsoft Graph - _Application_** API Permissions:
        - Device.Read.All
        - DeviceManagementConfiguration.ReadWrite.All
        - DeviceManagementManagedDevices.Read.All
        - Directory.Read.All
        - Group.ReadWrite.All
        - GroupMember.ReadWrite.All
    4. Once granted, **_Grant admin consent_**.
    5. Create a client secret and save the **secret value**.

## 4. Create Dataverse Application User
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/home)
2. Seelct **Environments** tab
3. Select the **environment** you'll be importing the solution into and select **Settings** on the toolbar
4. Expand **Users + Permissions**
5. Select **Application Users** and select **New App User**
6. Select **Add an app** and select the App Registraition you created then select Add
7. Select your **business unit** and select **Create**

*Leave the security role blank. We will come back to this later after importing the solution.*

## 5. Create Dataverse Application User Connection
Before we import the solution, we need to create the Dataverse Application User Connection.
1. Go to [Power Automate](https://us.flow.microsoft.com/)
2. **Select the environment** from the top-right that you'll be importing the solution into.
3. Select **Create** on the left-side toolbar and select Instant Cloud Flow
4. On the new flow page, select one of the **Dataverse** triggers or actions.
5. Click the elipses on the action (...) and select **Add New Connection**
6. Select **Connect with service principal** and name the connection. Ex: *ELA - Application User*
7. Enter in the Tenant ID, Client ID, and Client Secret from the app registration you created earlier.
8. Select **Create**.

*At this point the service principal connection should be created. You can close out of this flow without saving it.*

## 6. Import Solution
1. Download the un-managed zip file
2. Import the solution into your environment.
    - Set the following environment variables:
      - **AppRegistration_ClientID:** *Use the Application(client) ID from the App Registration you created*
      - **AppRegistration_ClientSecret:** *Use the client secret you created*
      - **AppRegistration_TenantID:** *Use your tenant id*
      - **MothershipURI:** *Leave this blank for now.*
      - **AdaptiveCardOriginatorGUID:** *Originator ID from [Actionable Email Developer Dashboard](https://outlook.office.com/connectors/oam/publish)*
      - **EnvironmentPublisherPrefix:** *Your environment publisher prefix*
 4. Turn on each Flow within the solution.

# How to Guide

## Managing a Local Administrator
1. On the main screen, select **Manage Device**
2. Enter an Intune device name then select **Search**
3. **Scroll down** to the bottom and adjust the configuration to your desired settings.
4. Select **submit**.

## Modifying Notification Users
To modify Teams or Outlook users to notify upon various job statuses, click the **gear icon** on the top-right of the app. From there, you'll be able to add and remove users.

## Sharing the Power App
When sharing the Power App, make sure to assign the user or group the **ELA - Administrator** Dataverse security role.
