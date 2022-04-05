public class XmlDRMSParserController {
    
    public Blob contentFile { get; set; }
    public String nameFile { get; set; }  
    public String textToParse { get; set; }  
    public String parsedText { get; set; }  
    
    
    public list<Account> accList {get;set;}
    
    public PageReference upload() {
        DOM.Document xmlDOC = new DOM.Document(); 
        textToParse = contentFile.toString();    
        xmlDOC.load(textToParse);
        parse(textToParse);
      return null;
    }       

    Public XmlDRMSParserController(){
    }
    
    private String parse(String toParse) {
      DOM.Document doc = new DOM.Document();      
      try {
        doc.load(toParse);    
        DOM.XMLNode root = doc.getRootElement();
        return walkThrough(root);
        
        } catch (System.XMLException e) {  // invalid XML
            return e.getMessage();
        }
    }
    
    private String walkThrough(DOM.XMLNode node) {
      String result = '\n';
      if (node.getNodeType() == DOM.XMLNodeType.COMMENT) {
        return 'Comment (' +  node.getText() + ')';
      }
      if (node.getNodeType() == DOM.XMLNodeType.TEXT) {
        return 'Text (' + node.getText() + ')';
      }
      if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
        result += 'Element: ' + node.getName();
        if (node.getText().trim() != '') {
          result += ', text=' + node.getText().trim();
        }
        if (node.getAttributeCount() > 0) { 
          for (Integer i = 0; i< node.getAttributeCount(); i++ ) {
            result += ', attribute #' + i + ':' + node.getAttributeKeyAt(i) + '=' + node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i));
          }  
        }
        for (Dom.XMLNode child: node.getChildElements()) {
          result += walkThrough(child);
        }
        parsedText = result;
        return result;
      }
      return '';  //should never reach here 
    }

    
    
}