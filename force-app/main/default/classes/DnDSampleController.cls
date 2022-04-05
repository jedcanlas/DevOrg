public with sharing class DnDSampleController{

    public class OpportunityTileWrapper {
        public Opportunity opp {get; set;}
        //public String shortedAccountName {get; set;}
    
        public Date lastActivityDate {get; set;}
        public String applicableStageBuckets {get; set;}        
        public String opportunityId {get; set;}

        public OpportunityTileWrapper(Opportunity opp, String oppId){
            this.opp = opp; 
            this.opportunityId = oppId; 
            //shortedAccountName = getShortAccountName(opp.Account.Name);
          
            applicableStageBuckets = '';            

            if(!opp.Tasks.isEmpty()){
                lastActivityDate = opp.Tasks[0].ActivityDate;
            }          
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

        private String getShortConsultants(String consultants){
            String result;

            if(!String.isBlank(consultants) && consultants.contains(';')){              
                result = consultants.substring(0, consultants.indexOf(';'));    

                if(result.length() > 27){
                    result = result.substring(0, 27) + '...';
                }        
            }

            return result;
        }               
    }

    public transient List<OpportunityTileWrapper> opportunityTiles {get; set;}
    public String oppStageName {get; set;}
    public String selectedOppId {get; set;}
    public String selectedAccId {get; set;}
    public Opportunity selectedOpp {get; set;}  
    public Opportunity genericOpportunity {get; set;}
    public Contact genericContact {get; set;}
    public Account genericAccount {get; set;}
    public OpportunityTileWrapper updatedOpportunityTile {get; set;} 
    public String updatedOpportunityErrorMsg {get; set;}
    public Boolean isSaving {get; set;}
    public Boolean isCreatingPGIMOpportunity {get; set;}

    public String selectedOppTopics {get; set;}       
    public List<String> sortedStageBuckets {get; set;}
    public String selectedAccountManagerName {get; set;}
    public Boolean viewingAsAll {get; set;}
    public String methodOfContact {get; set;}// by pk
    public String activityStatus {get; set;}// by pk
    public String saveOpportunityActivityErrorMsg {get; set;} // by pk
    private Id taskRTId;//by pk    
    public String conToUpdate {get; set;}

    public String keywordFilter {get; set;}
    public String tierFilter {get; set;}
    public String activitiesGroupFilter {get; set;}
    public String activitiesDaysRangeFilter {get; set;}
    public String stageBucketsFilter {get; set;}
    public String productsFilter {get; set;}
    public String regionsFilter {get; set;}
    public String sortBy {get; set;}
    public String sortOrder {get; set;}
    public Boolean filterCriteriaChanged {get; set;} 

    public String currentOpportunityIdsStr {get; set;}
    public Integer currentPage {get; set;}
    public Integer totalPages {get; set;}

    public Map<String, Integer> opportunityCountByStageBucket {get; set;}
    public Map<String, Decimal> mandateSizeTotalByStageBucket {get; set;}

    private List<Id> currentOpportunityIds = new List<Id>();    
    private Map<String, Set<String>> stageNamesByBucket = new Map<String, Set<String>>();
    private Map<String, String> stageBucketMapping = new Map<String, String>();
    private Id oppRTId;

    private final Integer NUMBER_OF_TILES_PER_PAGE = 200;
    //Ketan Benegal
    public transient List<Task> selectedOppMostRecentTPs {get; set;}
    public transient List<Event> selectedOppMostRecentMeetings {get; set;}
    public transient List<Contact> selectedOppContacts {get; set;}    
    public transient String selectedOppTPs_JSONString {get; set;}
    public transient String selectedOppMtgs_JSONString {get; set;}
    public transient String selectedOppContacts_JSONString {get; set;}
    
    public DnDSampleController(){
        try{
            isSaving = false;
            isCreatingPGIMOpportunity = false;
            viewingAsAll = True;

            oppRTId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Sales').getRecordTypeId();

            opportunityTiles = new List<OpportunityTileWrapper>();           
            genericOpportunity = new Opportunity(LeadSource = 'Account Manager', StageName = 'Stage A', RecordTypeId = oppRTId);
  
            genericAccount = new Account();           
            genericContact = new Contact();
            
            selectedAccountManagerName = UserInfo.getName();
            
            sortedStageBuckets = new List<String>();            
            for(Stage_Names__c setting : [SELECT Id, Name, Stages__c FROM Stage_Names__c ORDER BY Stage_Order__c ASC]){
                sortedStageBuckets.add(setting.Name);

                stageNamesByBucket.put(setting.Name, new Set<String>());
                for(String stageName : setting.Stages__c.split('\r\n')){
                    stageNamesByBucket.get(setting.Name).add(stageName);

                    stageBucketMapping.put(stageName, setting.Name);
                }                                      
            }   
            

            activitiesDaysRangeFilter = 'all';
            stageBucketsFilter = 'All';
            sortBy = 'StageName';
            sortOrder = 'ASC';
            stageBucketsFilter = 'Stage A,Stage B,Stage C';

            populateOpportunityTiles(true);
            
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    public void refreshOpportunityList(){
        try{
            System.debug(keywordFilter);
            System.debug(tierFilter);
            System.debug(activitiesGroupFilter);
            System.debug(activitiesDaysRangeFilter);
            System.debug(stageBucketsFilter);
            System.debug(productsFilter);
            System.debug(regionsFilter);
            System.debug(sortBy);
            System.debug(sortOrder);      

            populateOpportunityTiles(false);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    private void populateOpportunityTiles(Boolean refreshFullList){     
        Set<Id> opportunityIdsWithMatchedActivities = new Set<Id>();
        Date activityDateRangeFrom;
        Date activityDateRangeTo;

        currentPage = 0;
        totalPages = 0;

        if(refreshFullList || filterCriteriaChanged){

            currentOpportunityIds = new List<Id>();
            opportunityCountByStageBucket = new Map<String, Integer>();
            mandateSizeTotalByStageBucket = new Map<String, Decimal>();

            for(String stageBucket : stageNamesByBucket.keySet()){
                opportunityCountByStageBucket.put(stageBucket, 0);
                mandateSizeTotalByStageBucket.put(stageBucket, 0);
            }
             
            


            String mainFilterQuery = '';
            mainFilterQuery += 'SELECT Id, StageName, Account.Name';
            mainFilterQuery += ' FROM Opportunity';
            mainFilterQuery += ' WHERE IsClosed = false';            
            //mainFilterQuery += ' AND RecordTypeId = : oppRTId';      

            
            /*
            if(!viewingAsAll){
                mainFilterQuery += ' AND Account_Manager__c = \'' + genericOpportunity.Account_Manager__c + '\'';
            }

            if(!String.isBlank(tierFilter) && tierFilter <> '*'){
                tierFilter = tierFilter == '9' ? null : tierFilter;             
                mainFilterQuery += ' AND Opportunity_Tier__c =: tierFilter';
            }

            if(!String.isBlank(productsFilter)){
                List<String> products = new List<String>();
                for(String product : productsFilter.split(',')){
                    products.add(String.escapeSingleQuotes(product));
                }               
                mainFilterQuery += ' AND Product__c IN (\'' + String.join(products, '\',\'') + '\')';
            }

            if(!String.isBlank(regionsFilter)){
                List<String> regions = new List<String>();
                for(String region : regionsFilter.split(',')){
                    regions.add(String.escapeSingleQuotes(region));
                }               
                mainFilterQuery += ' AND Continental_Region__c IN (\'' + String.join(regions, '\',\'') + '\')';             
            }
            */
            
            if(!String.isBlank(stageBucketsFilter)){
                List<String> stagesToQuery = new List<String>();                
                for(String bucketFilter : stageBucketsFilter.split(',')){                   
                    if(stageNamesByBucket.containsKey(bucketFilter)){
                        stagesToQuery.addAll(stageNamesByBucket.get(bucketFilter));
                    }
                }               

                if(!stagesToQuery.isEmpty()){           
                    mainFilterQuery += ' AND StageName IN (\'' + String.join(stagesToQuery, '\',\'') + '\')';
                }
            }

            if(!opportunityIdsWithMatchedActivities.isEmpty()){
                mainFilterQuery += ' AND Id IN (\'' + String.join(new List<Id>(opportunityIdsWithMatchedActivities), '\',\'') + '\')';              
            }

            List<Opportunity> aa = Database.query(mainFilterQuery);
            if(!opportunityIdsWithMatchedActivities.isEmpty() || activitiesDaysRangeFilter == 'all'){   
                // First Apply all these criteria to get the matching Opportunities
                Map<Id, Opportunity> opps = new Map<Id, Opportunity>((List<Opportunity>)Database.query(mainFilterQuery));
                currentOpportunityIds = new List<Id>(opps.keySet());
                for(Id oppId : currentOpportunityIds){
                    Opportunity opp = opps.get(oppId);

                    // Summarize fields by Stage bucket
                    if(stageBucketMapping.containsKey(opp.StageName)){
                        String currentBucket = stageBucketMapping.get(opp.StageName);

                        if(!opportunityCountByStageBucket.containsKey(currentBucket)){
                            opportunityCountByStageBucket.put(currentBucket, 0);
                        }
                        opportunityCountByStageBucket.put(currentBucket, opportunityCountByStageBucket.get(currentBucket) + 1);

                        if(!mandateSizeTotalByStageBucket.containsKey(currentBucket)){
                            mandateSizeTotalByStageBucket.put(currentBucket, 0);
                        }
                        mandateSizeTotalByStageBucket.put(currentBucket, mandateSizeTotalByStageBucket.get(currentBucket) + 1);
                    }
                }
            } 
                               
        }

        totalPages = (currentOpportunityIds.size() / NUMBER_OF_TILES_PER_PAGE);       

        // Apply sorting based on the options selected in the VF page
        String sortByField = 'Account.Name';
        String sortDirection = 'ASC';
        
        //if(!String.isBlank(sortBy)){
            //sortByField = sortBy == 'StageName' ? 'Opp.StageName' : sortByField;

        //}
        if(!String.isBlank(sortOrder)){
            sortDirection = sortOrder + (sortOrder == 'DESC' ? ' NULLS FIRST' : ' NULLS LAST');              
        }
 
        String sortQuery = 'SELECT Id FROM Opportunity WHERE Id IN : currentOpportunityIds';        
        sortQuery += ' ORDER BY ' + sortByField + ' ' + sortDirection;


        List<Opportunity> sortedOpportunities = Database.query(sortQuery);
        
 

        currentOpportunityIds = new List<Id>();
        for(Opportunity opp : sortedOpportunities){                     
            currentOpportunityIds.add(opp.Id);                              
        }

        currentOpportunityIdsStr = String.join(currentOpportunityIds, ',');
        generateCurrentPageOpportunityTiles();

    } 

    private void generateCurrentPageOpportunityTiles(){
        opportunityTiles = new List<OpportunityTileWrapper>();

        if(!currentOpportunityIds.isEmpty()){
            List<Id> sortedOppIds = new List<Id>();
            Integer currentOppIdsIndex = NUMBER_OF_TILES_PER_PAGE * currentPage;

            for(Integer i = currentOppIdsIndex; i < currentOppIdsIndex + NUMBER_OF_TILES_PER_PAGE && i < currentOpportunityIds.size(); i++){
                sortedOppIds.add(currentOpportunityIds[i]);
            }   
            String query = '';
            query += 'SELECT Id, Name, StageName,AccountId';
            //query += 'SELECT Id, Name, Opportunity_Tier__c, StageName, Product__c, Total_Days_Opened__c, Mandate_Size_Mil_USD__c,';
            //query += ' AccountId, Account.Name, Account.Consultants__c, Account.Inst_l_Client_Status__c, Account.MMD_Total_Plan_Assets_Mil__c,';
            //query += ' Client_Contact__c, Client_Contact__r.Name, Consultant__c, Consultant__r.Name,';            
            //query += ' (SELECT Id, IsClosed, ActivityDate FROM Tasks WHERE IsClosed = true AND ActivityDate <> null AND ActivityDate <= TODAY AND RecordType.Name = \'Instl Activity Record Type\' ORDER BY ActivityDate DESC LIMIT 1)';            
            query += ' FROM Opportunity';
            query += ' WHERE Id IN : sortedOppIds';
     

            Map<Id, Opportunity> currentPageOpps = new Map<Id, Opportunity>((List<Opportunity>)Database.query(query));            

            for(Id oppId : sortedOppIds){
                opportunityTiles.add(new OpportunityTileWrapper(currentPageOpps.get(oppId), oppId));    
            }
            
        }
    }

    public void nextPage(){
        currentPage++;
        generateCurrentPageOpportunityTiles();
    }

    public void previousPage(){
        currentPage--;
        generateCurrentPageOpportunityTiles();
    }



    public void updateOpportunityStage(){
    system.debug('UPDATE');
        updatedOpportunityErrorMsg = null;
        isSaving = false;
        try{
            if(oppStageName <> null && selectedOppId <> null){
                Opportunity currentOpp = [SELECT Id,StageName FROM Opportunity WHERE Id =: selectedOppId];                            

                Opportunity opp = new Opportunity(Id = selectedOppId);
                opp.StageName = oppStageName;                                                           
                update opp;
                populateOpportunityTiles(true);                               
            }
        }catch(Exception e){            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

    }

    public void displayOpportunityRecord(){
        updatedOpportunityErrorMsg = null;
        isSaving = false;
        try{                            

            selectedOpp = [SELECT Id, Name, AccountId, StageName
                           FROM Opportunity WHERE Id =: selectedOppId];        

                      

        }catch(Exception e){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }


    public void saveOpportunityFields(){
        updatedOpportunityErrorMsg = null;
        isSaving = false;
        try{        
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Id =: selectedOppId];

            Opportunity opp2Update = genericOpportunity.clone();
            opp2Update.Id = selectedOppId;  
          

            update opp2Update;

            updatedOpportunityTile = new OpportunityTileWrapper(opp2Update, opp2Update.Id);

                      

            displayOpportunityRecord();
            populateOpportunityTiles(true);

            isSaving = true;
        }catch(Exception e){
            String result = e.getMessage();
            if(result.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                Integer lastIndex = result.length();
                if(result.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') < result.lastIndexOf(':')){
                    lastIndex = result.lastIndexOf(':');
                }
                result = result.substring(result.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') + 'FIELD_CUSTOM_VALIDATION_EXCEPTION'.length()+2, lastIndex);
            }
            updatedOpportunityErrorMsg = 'Update failed. ' + result;            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }        
    }
    
    
    
}