public with sharing class CustomPopUpController {  
    
    public List<Account> getAccounts()
    {
        List<Account> accounttList = new List<Account>();
        accounttList = [Select Id, Name, (select name from Account.Contacts) from Account LIMIT 10];
        return accounttList ;
        
    }

}