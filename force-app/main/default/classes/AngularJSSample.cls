public class AngularJSSample {
    
   @RemoteAction
   public static List<Contact> GetAllContactsByFilter(String searchText) 
   {
       String searchString = '%' + searchText + '%';
       //system.debug('@@@@@@@		' + searchString);
       List<Contact> contactList = [SELECT FirstName, LastName, Phone, Email, Title, Account.Name FROM Contact where FirstName like :searchString OR LastName like :searchString];
       return contactList; 
   }
    
}