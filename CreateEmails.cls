global class CreateEmails {
    public class CreateEmailRequest {
        @InvocableVariable
		public Id opportunityId;
        
		@InvocableVariable
		public Id contactId;
    }

    private GoogleForce gForce;
    
    // This function extract the first letter of the first name
    public static String getFirstLetter (String firstName) {
        String firstLetter = '';
        String firstNameCopy = firstName;
        String currentLetter = '';
        String lastLetter = '';
        
        if (String.isBlank(firstNameCopy)) {
            return firstLetter;
        }
        
        while (String.isNotBlank(firstNameCopy)) {
            currentLetter = firstNameCopy.left(1);
            
            if (String.isBlank(lastLetter) && String.isNotBlank(currentLetter) && currentLetter.isWhitespace() == false) {
                firstLetter += currentLetter;
            }
            lastLetter = currentLetter;
            
            if (firstNameCopy.length() > 1) {
                firstNameCopy = firstNameCopy.right(firstNameCopy.length() - 1);
            }
            else {
                firstNameCopy = '';
            }
        }
        
        return firstLetter;
    }
    
    @future(callout=true) global static void doAreaCalloutAsync(Id opp_id, Id con_id) {
        List<Contact> lstCon = [select id, FirstName, LastName from Contact where id = :con_id limit 1];
		Contact con = lstCon.get(0);
                
		Boolean dup_email = true;
		String exist_email;
		Integer random_index = Math.round((Math.random() * (499) + 101));
        // Email format is F.Lastname.Integer@domain
        String prefix = getFirstLetter(con.FirstName) + '.' + con.LastName.replaceAll( '\\s+', '')
		String temp_email = prefix + '.' + random_index  + '@domain';
        
        // Loop until no more duplicate email found
        while (dup_email) {
            String endpoint = 'https://admin.googleapis.com/admin/directory/v1/users/' + temp_email;
            GoogleForce gForce = new GoogleForce('AdminTest');
            HttpResponse resp = gForce.sendRequest(new Map<String, String> {
                'method' 	=> 'GET',
                'endpoint' 	=> endpoint
        	});
            Map<String, Object> respParams = (Map<String, Object>)
                JSON.deserializeUntyped(resp.getBody());
            if ((String) respParams.get('id') != null) {
                random_index = Math.round((Math.random() * (499) + 101));
                temp_email = prefix + '.' + random_index + '@domain';
            }
            else {
                dup_email = false;
            }
        }
                
		String endpoint = 'https://admin.googleapis.com/admin/directory/v1/users/';
		GoogleForce gForce = new GoogleForce('AdminTest');
		String json_body = '{' + '"name" : {' + '"familyName" : "' + con.LastName + '",' +
                    '"givenName" : "' + con.Firstname + '"},' +
                    '"password" : "SomeText' + random_index + '",' +
                    '"primaryEmail" : "' + temp_email + '",' +
                    '"orgUnitPath": "/OU",' +
                    '"changePasswordAtNextLogin" : true}';
		HttpResponse resp = gForce.sendRequest(new Map<String, String>{
                    'method'   => 'POST',
                    'endpoint' => endpoint,
                    'body' => json_body
		});
		Map<String, Object> respParams = (Map<String, Object>)
                JSON.deserializeUntyped(resp.getBody());
        System.debug(respParams);
        Opportunity opp = new Opportunity(id=opp_id);
        opp.WU_Email__c = temp_email;
        opp.WU_Password__c = 'SomeText' + random_index;
        update opp;
    }
	
    @InvocableMethod
    public static void CreateEmails(List<CreateEmailRequest> requests) {
        for (CreateEmailRequest request : requests) {
			    doAreaCalloutAsync(request.opportunityId, request.contactId);
        }
    }
}
