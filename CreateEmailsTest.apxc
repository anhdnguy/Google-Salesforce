@isTest
public class CreateEmailsTest {
    private static final Integer OPP_NUM = 1;
    
    @testSetup
    private static void TestSetup() {
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<Contact> lstCon = new List<Contact>();
        for (Integer i = 0; i < OPP_NUM; i++) {
            Contact newCon = new Contact(FirstName='First', LastName='Last', Email='test'+i+'@gmail.com');
            lstCon.add(newCon);
            System.debug('Record ' + i + ' is ' + lstCon[i]);
        }
        insert lstCon;
        
        for (Integer i = 0; i < OPP_NUM; i++) {
            Opportunity newOpp = new Opportunity(Name='Test'+i, StageName='New',
                                                 CloseDate=Date.valueOf('2018-01-01'), Contact__c=lstCon[i].id);
            lstOpp.add(newOpp);
        }        
        insert lstOpp;
    }
    
	@isTest
    private static void TestGenerate() {
        List<Opportunity> lstOpp = [select id, contact__c, WU_Email__c from Opportunity order by CreatedDate desc];
        List<CreateEmails.CreateEmailRequest> lstWUEmailRequest = new List<CreateEmails.CreateEmailRequest>();
        for (Integer i = 0; i < lstOpp.size(); i++) {
			CreateEmails.CreateEmailRequest request = new CreateEmails.CreateEmailRequest();
            request.opportunityId = lstOpp[i].id;
            request.contactId = lstOpp[i].contact__c;
                        
            lstWUEmailRequest.add(request);
        }
		String temp_email;
		String status;
		String body;
		Map<String, String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Length', '1141');
        body = '{"name" : "' + lstOpp[0].WU_Email__c + '"}';
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleMockResponse(200, 'Ok', body, responseHeaders));
        CreateEmails.CreateEmails(lstWUEmailRequest);
        Test.stopTest();
        
        lstOpp = [select id, Name, WU_Email__c from Opportunity order by CreatedDate desc];
        
		for (Integer i=0; i < lstOpp.size(); i++) {
            System.debug('Record ' + i + ' is ' + lstOpp[i].Name + ' WU Email is ' + lstOpp[i].WU_Email__c);
        }
        System.assertEquals(lstOpp.size(), 1);
        System.debug(lstOpp[0].WU_Email__c);
    }
}
