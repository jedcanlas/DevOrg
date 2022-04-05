public class EmailMessageToAttachment {
    
    
    
    public void convert(){ 
        Set<Id> pId = new Set<Id>{'5000K00002U4isUQAR'}; 
            
        List<EmailMessage> eList = new List<EmailMessage>();
        String query = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('EmailMessage').getDescribe().fields.getMap().keySet()), ',') + ' FROM EmailMessage where parentId =: pId';    
        eList = database.query(query); 
        system.debug(eList);
        
        List<Attachment> atts = [SELECT id,name FROM Attachment WHERE ParentId IN (SELECT Id FROM EmailMessage WHERE parentId IN: pId)  ];
		System.debug(atts);
        

            
            
            
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(eList[0].HtmlBody.stripHtmlTags());
        string csvname= 'test.msg';
        csvAttc.contenttype ='application/vnd.ms-outlook';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        email.setSubject(eList[0].subject);
        email.setToAddresses( eList[0].ToAddress.split(','));
        email.setPlainTextBody(eList[0].TextBody);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
            
            
        
        
    }
    
    
    
    
    /**

string s = [select id, HtmlBody from emailmessage where id ='02s0K00000gXZlO'].HtmlBody;
System.debug('*********************' + s.stripHtmlTags());

List<Account > acclist = [Select id,name , CreatedDate , lastModifiedDate from Account limit 10];
string header = 'Record Id, Name , Created Date, Modified Date \n';
string finalstr = header ;
for(Account a: acclist)
{

string recordString = a.id+','+a.Name+','+a.CreatedDate+','+a.LastModifiedDate +'\n';

finalstr = finalstr +recordString;

}

Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
blob csvBlob = Blob.valueOf(finalstr);
string csvname= 'Account.csv';
csvAttc.setFileName(csvname);
csvAttc.setBody(csvBlob);
Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
String[] toAddresses = new list<string> {'jed.dnata@gmail.com'};
String subject ='Account CSV';
email.setSubject(subject);
email.setToAddresses( toAddresses );
email.setPlainTextBody('Account CSV ');
email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});




Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
message.toAddresses = new String[] { 'jed.dnata@i-1vte88nu7zieq38d70vi2ozgl6efmb4vddw3su73obntdy2nzo.28-11cs6eai.ap6.case.salesforce.com' };
message.optOutPolicy = 'FILTER';
message.subject = '111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
message.plainTextBody = 'This is the message body.';
Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

if (results[0].success) 
{
System.debug('The email was sent successfully.');
} else 
{
System.debug('The email failed to send: ' + results[0].errors[0].message);
}
**/
    
}