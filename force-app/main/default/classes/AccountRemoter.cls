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

global with sharing class AccountRemoter {

    public String accountName { get; set; }
    public static Account account { get; set; }
    public AccountRemoter() { } // empty constructor
    
    @RemoteAction
    global static Account getAccount(String accountName) {
        account = [SELECT Id, Name, Phone, Type, NumberOfEmployees 
                   FROM Account WHERE Name = :accountName];
        return account;
    }
}