/**
 * @description       : 
 * @author            : Jed Canlas - DNATA
 * @group             : 
 * @last modified on  : 05-25-2021
 * @last modified by  : Jed Canlas - DNATA
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   05-25-2021   Jed Canlas - DNATA   Initial Version  
**/

public class AngularJS {
   @RemoteAction
   public static List<Contact> GetAllContactsByFilter(String searchText)
   {
       String searchString = '%' + searchText + '%';
       //system.debug('@@@@@@@		' + searchString);   
       List<Contact> contactList = [SELECT FirstName, LastName, Phone, Email, Title, Account.Name FROM Contact where FirstName like :searchString OR LastName like :searchString];
       return contactList; 
   }
}