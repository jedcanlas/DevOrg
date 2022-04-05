/**
 * @description       : 
 * @author            : Jed Canlas - DNATA
 * @group             : 
 * @last modified on  : 04-05-2022
 * @last modified by  : Jed Canlas - DNATA
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   05-25-2021   Jed Canlas - DNATA   Initial Version
**/
public class AccountContactDataTableController {
	@AuraEnabled
	public static List<Contact> getAccountContacts (Id recordId){

		List<Contact> contacts = [SELECT FirstName, LastName, Email FROM Contact limit 10];
		//test
		return contacts;
		//2212
	}

}