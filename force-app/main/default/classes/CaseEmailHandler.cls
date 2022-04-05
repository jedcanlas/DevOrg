global class CaseEmailHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) 
    {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        system.debug(email);
        system.debug(envelope);
        system.debug(result);
        Map<String, DNIS_Mapping__mdt> cmdMap = new Map<String, DNIS_Mapping__mdt>();
        for(DNIS_Mapping__mdt cm: [select id,Label,DNIS__c from DNIS_Mapping__mdt]){
            cmdMap.put(cm.DNIS__c,cm); 
        }
        system.debug(cmdMap);
        Id newCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CX - CSAT').getRecordTypeId();
        Case c = new Case();
        for(string s: email.plainTextBody.split('\n')){ 
            if(!String.isEmpty(s)){
                s = s.replaceAll( '\\s+', '');
                if(s.startsWithIgnoreCase('DNIS:')){
                    c.CSAT_DNIS__c = s.substring(5,s.length());
                    if(cmdMap.containskey(c.CSAT_DNIS__c)){
                        c.CSAT_LOB__c = cmdMap.get(c.CSAT_DNIS__c).Label;    
                    }else{
                        c.CSAT_LOB__c = 'No DNIS Mapping Found!';
                    }                   
                    c.Subject = email.subject;
                    c.RecordTypeId = newCaseRT;
                    system.debug('FOUND!' + c.CSAT_DNIS__c); 
                }    
            } 
        }
        
        Database.SaveResult[] srList = Database.insert(new List<Case>{c}, false);
        for (Database.SaveResult sr : srList) {
            system.debug('@@@@@@@@' + sr);
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                Id networkId = [Select id from PartnerNetworkConnection where ConnectionStatus = 'Accepted' and connectionName = 'IBM' limit 1].Id;  
                PartnerNetworkRecordConnection newConnection = new PartnerNetworkRecordConnection();
                newConnection.ConnectionId = networkId;
                newConnection.LocalRecordId = sr.getId(); 
                newConnection.SendClosedTasks = false;
                newConnection.SendOpenTasks = false;
                newConnection.SendEmails = false;
                
                
                Database.SaveResult[] srList2 = Database.insert(new List<PartnerNetworkRecordConnection>{newConnection}, false);
                for (Database.SaveResult sr2 : srList2) {
                    if (sr.isSuccess()) {
                        //deleteCSAT(New List<Id>{c.Id});
                    }else{
                        system.debug('Case Deletion Failed');
                    }
                }
            }else{
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Case fields that affected this error: ' + err.getFields());
                }
            }
        }
        
        
        
        /*
if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
Attachment attachment = new Attachment();
// attach to the newly created contact record
attachment.ParentId = contact.Id;
attachment.Name = email.binaryAttachments[i].filename;
attachment.Body = email.binaryAttachments[i].body;
insert attachment;
}
}*/
        
        return result;
        
    }
    
    @future
    public static void deleteCSAT(List<Id> caseIdList){
        
        try{
            delete [select id from Case where id =: caseIdList];
        }catch (exception e){
            system.debug(e.getMessage());
        }
        
    }
    
    
}