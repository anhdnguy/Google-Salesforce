# Integration between Google and Salesforce to create Gmail for customers
The purpose of this project is to build a workflow to create Gmail account for customer when the opportunity satisfies the criteria and send the login credentials to customer. However, this repo only focuses on the Apex classes that are invoked by a Flow to generate the Gmail username, check for duplication, create the Gmail account via API, and save the Gmail username to the opportunity.

Before starting this project, one must create a project on Google Console with the Admin SDK API enabled. In this project, create a service account and save the Private Key.

In order for Apex class to use this Private Key to make API calls to the Google project, create a Custom Metadata Type called Google Service, the API name is `Google_Service__mdt`. Once the new metadata type is created, create custom fields to store the Private key along with other information, so Apex class can query:
- `Client_Email__c` to store the email address of the google service account.
- `Private_Key__c` to store the Private Key of the service account.
- `Scope__c` to store the scope of the project. In our case, it's https://www.googleapis.com/auth/admin.directory.user

Create a record and fill in the information.

Next, create a custom data in Custom Settings to store access token required by Google API and select list as type, the API name is `Google_SA_Token__c`. Then, create custom fields:
- `Timestamp__c` to store the stamp the time of token creation. Since token is only valid for 60 minutes, using the timestamp of when the token is created, Apex class can check if the token is expired.
- `Token__c` to store the access token.