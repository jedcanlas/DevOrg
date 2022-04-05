public class XmlAccountController {
    
    public Blob contentFile { get; set; }
    public String nameFile { get; set; }  
    public String textToParse { get; set; }  
    public String parsedText { get; set; }  
    public string debugStr {get; set;}
    
    
    public List<Account> accList {get;set;}
    public Map<Id,Account> accMap {get;set;}
    public Account acc {get;set;}
    
    Public XmlAccountController (){
        accList = new List<Account>();
    }
    
    public PageReference processXML() {  
          
        DOM.Document xmlDOC = new DOM.Document(); 
        textToParse = contentFile.toString();   
        xmlDOC.load(textToParse);         
        System.XmlStreamReader reader = new System.XmlStreamReader(textToParse);
        readResponse(reader);
        
        
      return null;
    }       


    private String parse(String toParse) {
      DOM.Document doc = new DOM.Document();      
      try {
        doc.load(toParse);    
        DOM.XMLNode root = doc.getRootElement();
        
        return null;
        
        } catch (System.XMLException e) {  // invalid XML
            return e.getMessage();
        }
    }
    
    
    public void readResponse(System.XmlStreamReader reader) {
    // Account record we will be looping
    Account accountRecord; 
    // List of accounts to store the value
    List < Account > accountList = new list < Account > (); 
    // Is there any element next?
    while (reader.hasNext()) { 
        // Is the next element an opening tag?
        if (reader.getEventType() == XmlTag.START_ELEMENT) { 
            // Check if the first element is Account
            if ('Account' == reader.getLocalName()) {
                // if opening tag of account is found initialize AccountRecord
                accountRecord = new Account(); 
                
               
               if (reader.getAttributeCount() > 0) { 
                  for (Integer i = 0; i< reader.getAttributeCount(); i++ ) {
                  if(reader.getAttributeLocalName(i) == 'Name'){
                      accountRecord.Name = reader.getAttributeValueAt(i);
                  }else if(reader.getAttributeLocalName(i) == 'Industry'){
                      accountRecord.Industry = reader.getAttributeValueAt(i);
                  }
                  }  
                }
               
               
                
            } else if ('Name' == reader.getLocalName()) {
                // If you find any other opening tag, extract the string value
                accountRecord.Name = getValueFromTag(reader);
            } else if ('AccountNumber' == reader.getLocalName()) {
                // If you find any other opening tag, extract the string value
                accountRecord.AccountNumber= getValueFromTag(reader);
            }
        } else if (reader.getEventType() == XmlTag.END_ELEMENT) {
            // Is the next element an end tag? If yes is it an Account or an Accounts tag?
            if ('Account' == reader.getLocalName()) {
                // If you find end tag called account, push the account record in list
                accountList.add(accountRecord);
            } else if ('Accounts' == reader.getLocalName()) {
                // We have reached end of file, just exit
                break;
            }
        } else if (reader.getEventType() == XmlTag.CHARACTERS) {
        }
        reader.next();
    }
    
    debugStr += string.valueOf(accountList);
    system.debug(accountList);
}

// This is an extra function to read data between opening and closing tag. 
// It will return the string of value from between tags
public string getValueFromTag(System.XMLStreamReader reader) {
    String DataValue;

    while (reader.hasNext()) {
        if (reader.getEventType() == XmlTag.END_ELEMENT) {
            break;
        } else if (reader.getEventType() == XmlTag.CHARACTERS) {
            DataValue = reader.getText();
        }
        reader.next();
    }

    return DataValue;
}
    
    
}