global class MilestoneTimer implements Support.MilestoneTriggerTimeCalculator {   

     global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        try{
            integer milestoneTimeToSet = 1;
            MilestoneType mt = new MilestoneType();
            mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
            //Bed Brief Milestone         
            if(mt.Name == 'My Milestone'){
                // Bed Brief     
                Case c = [SELECT id,Priority,
                isclosed,
                createddate,
                SLA_Target_Date_Minutes__c,parent.SLA_Target_Date_Minutes__c,
                (select id,completionDate from casemilestones) 
                FROM Case WHERE Id=:caseId];
                milestoneTimeToSet = integer.valueof(c.SLA_Target_Date_Minutes__c);                
            }
            return milestoneTimeToSet;               
        }catch(exception e){
            return 1;               
        }
     
}
}