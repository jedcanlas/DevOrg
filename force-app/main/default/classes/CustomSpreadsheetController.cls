public class CustomSpreadsheetController{
   
                List<Account> accountList;

                public PageReference reset() {
                     accountList = [select name,Type,billingCity,parentid,SLAExpirationDate__c 
                                from account order by createddate asc limit 6 ];
      
                     return null;
                }  
             
                public List<Account> getAccounts() {
                     if(accountList == null) reset(); 
                     return accountList;
                }
 
                public void setAccounts(List<Account> accounts) {
                      accountList = accounts;
                }
 
                public PageReference save() {
                      upsert accountList;
                      return null;
                }
 
                public PageReference add() {
                                accountList.add(New Account());
                                return null;
                }
 
 
 
}