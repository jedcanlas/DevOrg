public class exportExcel {
   
    public string header{get;set;}
    public List<Account> a {get;set;}
    public string Filetype{get;set;}
    public boolean isExcel {get;set;}
    public boolean isCsv {get;set;}   
    public List<String> fieldNames {get; set;}
 
 
 
 
    public exportExcel(){
        fieldNames = new List<String>();
        fieldNames.add('id');
        fieldNames.add('Name');
            Filetype = '';
           	a  = [select id,name from account limit 10];
        SObjectType obj = Schema.getGlobalDescribe().get('Account'); 
        Map<String,Schema.SObjectField> mfields = obj.getDescribe().fields.getMap(); 
        string header ='';
        for(String s: mfields.keySet())
        {  
            header += mfields.get(s)+','; 
            //string ss = mfields.get(s);
            //fieldNames.add(s);
        }
        	header = header.substring(0,header.length()-1);
            header += '\r\n';   
        	
    }
 
   public static void exportToExcel(){
    
   }
    
   public static String constructQueryString(string objName,string whereClause) 
    {
        SObjectType obj = Schema.getGlobalDescribe().get(objName); 
        Map<String,Schema.SObjectField> mfields = obj.getDescribe().fields.getMap(); 
        string queryStr ='Select ';       
        for(String s: mfields.keySet())
        {  
            queryStr += mfields.get(s)+',';     
        }
        queryStr = queryStr.substring(0,queryStr.length()-1);
        queryStr += ' From '+objName + ' limit 10';
        if(!string.isEmpty(whereClause) && whereClause != null && whereClause != '')
        { 
            queryStr +=  ' Where '+whereClause;   
        } 
        return queryStr;
    }
 
}