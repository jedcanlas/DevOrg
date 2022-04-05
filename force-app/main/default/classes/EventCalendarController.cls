global class EventCalendarController {
    

    public Sales_Calendar__c SC {get;set;}
    public Account ACC {get;set;}
    public boolean isCreate {get;set;}
    	
    
    public EventCalendarController(){
        SC = new Sales_Calendar__c();
        ACC = new Account();
        isCreate = false;
        
    }
    
    public PageReference refresh() { 
        return null;
    }
    
    
    public void showPopup(){
        SC = new Sales_Calendar__c();
        isCreate = true; 
    }
    
    public void hidePopup(){
        isCreate = false; 
     }
    
    public void createOffer(){
        insert SC;
        isCreate = false;
    }
    
    
    @RemoteAction
    global static List<Sales_Calendar__c> getData(List<String> brandStrList,String accName,string region) {  
        

        String queryStr = constructQueryString('Sales_Calendar__c','Account__r.Name,Account__r.Region__c',' Offer_Year__c=\''+string.valueOf(system.today().year())+'\'  ');
            
            //if(brandStrList.size()>0){
                querystr+= '  and brand__c INCLUDES (\'';
                for(String b: brandStrList){
                    querystr +=  b + '\',\'';        
                }
                querystr = querystr.removeEnd('\',\'') +'\')';
            //}
            
            if(accName.length() > 0){
                querystr+= '  and Account__r.Name LIKE \''+accName+'%\'';
            }
        
        	if(region.length() > 0){
                querystr+= '  and Account__r.Region__c = \''+region+'\'';
            }
             
        system.debug(queryStr);
        return database.query(queryStr);
    }
    
    
    public static String constructQueryString(string objName,string additionalQuery,string whereClause) 
    {
        SObjectType obj = Schema.getGlobalDescribe().get(objName); 
        Map<String,Schema.SObjectField> mfields = obj.getDescribe().fields.getMap(); 
        string queryStr ='Select ';       
        for(String s: mfields.keySet())
        {  
            queryStr += mfields.get(s)+',';     
        }
        queryStr = queryStr.substring(0,queryStr.length()-1);
        if(additionalQuery.length()>0){
            queryStr += ','+additionalQuery;
        }
        queryStr += ' From '+objName;
        if(!string.isEmpty(whereClause) && whereClause != null && whereClause != '')
        { 
            queryStr +=  ' Where '+whereClause;   
        } 
        return queryStr;
    }
}