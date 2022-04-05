public class CSVParserController {
    
    public Blob contentFile { get; set; }
    public String nameFile { get; set; }  
    public String textToParse { get; set; }  
    public String parsedText { get; set; } 
    
    public CSVParserController(){
        
    }
    
    public void Parse(){
        
        //textToParse = contentFile.tostring();
        string csvContent = contentFile.tostring();
        csvContent = csvContent.replace('"','\'');
        List<String> strList = csvContent.split('\n');
        for(string str: strList){
            List<String> fieldValues = str.split(',');
            
            system.debug(str);
            for(String strVal: fieldValues){
            parsedText += strVal+'\n';
                system.debug(strVal);
            }
        }
        //s = EncodingUtil.base64Decode(EncodingUtil.base64Encode(s)).toString();
        //parsedText += csvContent;


    }

}