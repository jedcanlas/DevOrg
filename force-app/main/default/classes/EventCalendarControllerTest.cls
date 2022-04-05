@isTest 
public class EventCalendarControllerTest 
{
	static testMethod void testMethod1() 
	{
		Account testAccount = new Account();
		testAccount.Name='Test Account' ;
		insert testAccount;
		
		Sales_Calendar__c s = new Sales_Calendar__c();
        s.Brand__c = 'ALL';
        s.Offer_Description__c = 'test';
        s.Offer_Start_Date__c = dateTime.now();
        s.Offer_End_Date__c = dateTime.now();
        s.Offer_Region__c = 'Asia';
        s.Account__c = testAccount.Id;
        s.Offer_Name__c = 'test name';
        insert s;
		
        
        EventCalendarController con = new EventCalendarController();
		PageReference pageRef = Page.EventCalendar;
        Test.setCurrentPage(pageRef);
        
		
		Test.StartTest();        	
       	EventCalendarController.getData(new List<String>{'ALL'},'Test Account','Asia');
        con.refresh();
        con.showPopup();
        con.SC.Account__c = testAccount.Id;
        con.createOffer();
        con.hidePopup();
		Test.StopTest();
	}
}