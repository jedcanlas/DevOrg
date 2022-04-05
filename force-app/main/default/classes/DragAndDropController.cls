public with sharing class DragAndDropController{

    public List<Id> currentOpportunityIds = new List<Id>();   
    public String currentOpportunityIdsStr {get; set;}
    public transient List<OpportunityTileWrapper> opportunityTiles {get; set;}
    public List<Opportunity> opportunityList {get; set;}
    
    
    public DragAndDropController(){
        opportunityTiles = new List<OpportunityTileWrapper>();  
        populateOpportunityTiles(true);
    }
    
     private void populateOpportunityTiles(Boolean refreshFullList){     

        if(refreshFullList){
            currentOpportunityIds = new List<Id>();
            String mainFilterQuery = '';
            mainFilterQuery += 'SELECT Id, StageName';
            mainFilterQuery += ' FROM Opportunity';
            mainFilterQuery += ' WHERE IsClosed = false';            
            //mainFilterQuery += ' AND RecordTypeId = : oppRTId';       
            //mainFilterQuery += ' AND StageName NOT IN (\'Prospect No Bid\', \'Inflows\')';
            Map<Id, Opportunity> opps = new Map<Id, Opportunity>((List<Opportunity>)Database.query(mainFilterQuery));
           opportunityList = Database.query(mainFilterQuery);
                  
        }
  
        
        system.debug('@@@            ' + opportunityList);
        
        currentOpportunityIds = new List<Id>();
        for(Opportunity opp : opportunityList){                     
            currentOpportunityIds.add(opp.Id);                              
        }

        currentOpportunityIdsStr = String.join(currentOpportunityIds, ',');
        generateCurrentPageOpportunityTiles();
    }
    
    private void generateCurrentPageOpportunityTiles(){
        opportunityTiles = new List<OpportunityTileWrapper>();

        if(!currentOpportunityIds.isEmpty()){
        system.debug('@@@            ' + currentOpportunityIds);
            List<Id> sortedOppIds = new List<Id>();
            Integer currentOppIdsIndex = 10;

            for(Integer i = currentOppIdsIndex; i < currentOppIdsIndex + 10 && i < currentOpportunityIds.size(); i++){
                sortedOppIds.add(currentOpportunityIds[i]);
            }
            System.debug('sortedOppIds: ' + sortedOppIds);      
            String query = '';
            query += 'SELECT Id, Name, StageName,';
            query += ' AccountId, Account.Name';
            //query += ' Client_Contact__c, Client_Contact__r.Name, Consultant__c, Consultant__r.Name,';            
            //query += ' (SELECT Id, IsClosed, ActivityDate FROM Tasks WHERE IsClosed = true AND ActivityDate <> null AND ActivityDate <= TODAY AND RecordType.Name = \'Instl Activity Record Type\' ORDER BY ActivityDate DESC LIMIT 1)';            
            query += ' FROM Opportunity';
            query += ' WHERE Id IN : sortedOppIds';

            System.debug(query);       

            Map<Id, Opportunity> currentPageOpps = new Map<Id, Opportunity>((List<Opportunity>)Database.query(query));            
            system.debug('@@@currentPageOpps             ' + currentPageOpps );
            
            for(Id oppId : sortedOppIds){
            system.debug('@@oppId ' + oppId );
                opportunityTiles.add(new OpportunityTileWrapper(currentPageOpps.get(oppId), oppId));    
                system.debug('@@opportunityTiles' + opportunityTiles);
            }
        }
    }
    
    
    
    
    /**********************************************/
    public class OpportunityTileWrapper {
        public Opportunity opp {get; set;}
        public String shortedAccountName {get; set;} 
        public String opportunityId {get; set;}

        public OpportunityTileWrapper(Opportunity opp, String oppId){
            this.opp = opp; 
            this.opportunityId = oppId; 
            //shortedAccountName = getShortAccountName(opp.Account.Name);       
        }

        private String getShortAccountName(String accName){
            String result = '';
            if(accName <> null){
                result = accName;            
                if(accName.contains(' ')){
                    result = '';
                    List<String> accWords = accName.split(' ');
                    for(Integer i = 0; i < 2; i++){
                        result += ' ' + accWords[i];
                    }
                    result = result.substring(1);
                }
            }
            return result;
        }              
    }
    /**********************************************/
    
    
    
}