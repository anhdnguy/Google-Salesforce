@isTest
public class GoogleForceTest {
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
            Opportunity newOpp = new Opportunity(Name='Test'+i, StageName='New', WU_Email__c='Test12@westcliff.edu',
                                                 CloseDate=Date.valueOf('2018-01-01'), Contact__c=lstCon[i].id);
            lstOpp.add(newOpp);
        }        
        insert lstOpp;
    }
    
    @isTest static void TestEmailExist() {
        List<Opportunity> lstOpp = [select id, contact__c, WU_Email__c from Opportunity order by CreatedDate desc];
		String temp_email;
		String status;
		String body;
		Map<String, String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Length', '1141');
        
        for (Integer i = 0; i < lstOpp.size(); i++) {            
            String endpoint = 'https://admin.googleapis.com/admin/directory/v1/users/' + lstOpp[i].WU_Email__c;
            body = '{"name" : "' + lstOpp[i].WU_Email__c + '"}';
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GoogleMockResponse(200, 'Ok', body, responseHeaders));
            GoogleForce gForce = new GoogleForce('AdminTest');
            HttpResponse resp = gForce.sendRequest(new Map<String, String> {
                        'method' 	=> 'GET',
                        'endpoint' 	=> endpoint
            });
            Test.stopTest();
            Map<String, Object> respParams = (Map<String, Object>)
                JSON.deserializeUntyped(resp.getBody());
            System.debug(respParams);            
        }
    }
}
