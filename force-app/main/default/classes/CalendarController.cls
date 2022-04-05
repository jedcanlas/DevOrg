global with sharing class CalendarController {
    
    //public Static List<Account> accList {get;set;}    
    
    
    public CalendarController(){  }
    
    @RemoteAction
	global static List<Account> getAccount() {
  
        return [select id,name,title__c,start__c,End__c from account where title__c != null];
    }
    


}