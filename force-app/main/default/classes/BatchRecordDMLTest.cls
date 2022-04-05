@isTest 
public class BatchRecordDMLTest {

    static testMethod void TestUndelete(){
        
        Account acc = new Account();
        acc.name = 'test';
        //acc.FirstName ='test';
        //acc.LastName ='test';
        //acc.PersonMobilePhone = '589736044';
        //acc.MobileBrand__c = '589736044';
        //acc.Org_Brand__c = 'dnata';
        //acc.recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId(); 
        //acc.No_Email_on_Account__c = true;
        insert acc;        
        Case cas = new Case();
        //cas.Org_Brand__c = 'dnata';
        cas.SuppliedPhone = '589736044';
        cas.Origin = 'Email'; 
        cas.SuppliedName = 'Merul Shah';
        //cas.recordTypeID = Schema.SObjectType.case.getRecordTypeInfosByName().get('dTME - After Sales').getRecordTypeId(); 
        cas.Status = 'New';
        insert cas;         
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = cas.Id)); 
        insert newEmail;
        
        delete newEmail;
        
        Test.startTest();        
        BatchRecordDML obj = new BatchRecordDML('EmailMessage','WHERE IsDeleted = True ALL ROWS','undelete');
        DataBase.executeBatch(obj,1);         
        Test.stopTest();
    }
    
    static testMethod void TestDelete(){
        
        Account acc = new Account();
        acc.name = 'test';
        //acc.FirstName ='test';
        //acc.LastName ='test';
        //acc.PersonMobilePhone = '589736044';
        //acc.MobileBrand__c = '589736044';
        //acc.Org_Brand__c = 'dnata';
        //acc.recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId(); 
        //acc.No_Email_on_Account__c = true;
        insert acc;        
        Case cas = new Case();
        //cas.Org_Brand__c = 'dnata';
        cas.SuppliedPhone = '589736044';
        cas.Origin = 'Email'; 
        cas.SuppliedName = 'Merul Shah';
        //cas.recordTypeID = Schema.SObjectType.case.getRecordTypeInfosByName().get('dTME - After Sales').getRecordTypeId(); 
        cas.Status = 'New';
        insert cas;         
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = cas.Id)); 
        insert newEmail;

        Test.startTest();        
        BatchRecordDML obj = new BatchRecordDML('EmailMessage','limit 1','delete');
        DataBase.executeBatch(obj,1);         
        Test.stopTest();
    }
}