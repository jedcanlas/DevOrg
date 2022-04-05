/**
 * HOW to use:
 * BatchRecordDML(object,where clause,dml event);
 * 
 * FOR UNDELETE*
 * BatchRecordDML obj = new BatchRecordDML('EmailMessage','WHERE IsDeleted = True ALL ROWS','undelete');
 * DataBase.executeBatch(obj,1); 
 * 
 * FOR DELETE*
 * BatchRecordDML obj = new BatchRecordDML('EmailMessage','limit 1','delete');
 * DataBase.executeBatch(obj,1);  
 * 
 * 
**/
global class BatchRecordDML implements Database.Batchable<sObject>{
        
    private String strObjName; 
    private String strParameter;
    private String strEvent; 
    
 	public BatchRecordDML(String objName, String strParam, String event) {
        strObjName = objName;
        strParameter = strParam;  
        strEvent = event;
    }
    
	global Database.queryLocator start(Database.BatchableContext bc){
        
        String query = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get(strObjName).getDescribe().fields.getMap().keySet()), ',');        
        query += ' From ' + strObjName+ ' ' + strParameter;//IsDeleted = True ALL ROWS';
		return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext BC, List<EmailMessage> scope){
        
        try{
            if(strEvent == 'delete'){
                delete scope;
            }
            if(strEvent == 'undelete'){
                undelete scope;
            }
            
        }catch (exception e){
            system.debug(e.getMessage());
        }
        
    }
    global void finish(Database.BatchableContext bc){}

}