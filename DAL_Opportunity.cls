public class DAL_Opportunity 
{
    public static String STAGE_PROSPECTING = 'Prospecting';
        
    public static String FIELD_STAGENAME = Opportunity.StageName.getDescribe().getLocalName();
    public static String FIELD_AMOUNT = Opportunity.Amount.getDescribe().getLocalName();
    public static String FIELD_CLOSE_DATE = Opportunity.CloseDate.getDescribe().getLocalName();

    private static Map<String, OpportunityStage> stagesMap = null;
    
    public static Opportunity newItem(ID accountId, String name, String stageName, Date closeDate, String recordTypeName)
    {
        Opportunity newOpportunity = new Opportunity();
        
        newOpportunity.AccountId = accountId;
        newOpportunity.Name = name;
        newOpportunity.CloseDate = closeDate;
        
        if (String.isNotBlank(recordTypeName))
            newOpportunity.RecordTypeId = DAL_BaseObject.getRecordTypeByDeveloperName(Opportunity.SObjectType, recordTypeName);
        
        if (String.isNotBlank(stageName))
        {
            OpportunityStage stage = getStageByName(stageName);
            
            if (stage != null)
            {
                newOpportunity.StageName = stage.MasterLabel;
                newOpportunity.Probability = stage.DefaultProbability;
            }
        }
                
        return newOpportunity;
    }
    
    public static Opportunity newItem(ID accountId, String stageName)
    {
        Opportunity newOpportunity = newItem(accountId, DAL_BaseObject.generateRandomName(), stageName, Date.Today(), null);
        return newOpportunity;
    }
        
    public static Opportunity insertItem(ID accountId, String stageName)
    {
        Opportunity newOpportunity = newItem(accountId, stageName);
        DAL_BaseObject.insertDBObject(newOpportunity);
        return newOpportunity;
    }
    
    public static Opportunity insertItem(ID accountId, String name, String stageName, Date closeDate, String recordTypeName)
    {
        Opportunity newOpportunity = newItem(accountId, name, stageName, closeDate, recordTypeName);
        DAL_BaseObject.insertDBObject(newOpportunity);
        return newOpportunity;
    }
    
    public static OpportunityStage getStageByName(String stageName)
    {
		populateStagesMap();
        
        return stagesMap.get(stageName);
    }
    
    public static List<OpportunityStage> getStagesByName(Set<String> stageNames)
    {
		List<OpportunityStage> stages = new  List<OpportunityStage>();
    	
		populateStagesMap();
        
        for (String stageName : stageNames)
        {
        	OpportunityStage stage = stagesMap.get(stageName);
        	if (stage != null)
        		stages.add(stage);
        }
        
        return stages;
    }
    
    private static void populateStagesMap()
    {
		if (stagesMap == null)
        {
            stagesMap = new Map<String, OpportunityStage>();
            
            List<OpportunityStage> stages = 
            [
                SELECT
                    Id,
                    DefaultProbability,
                    Description,
                    MasterLabel
                FROM OpportunityStage
                LIMIT 1000
            ];
            
            for (OpportunityStage stage : stages)
                stagesMap.put(stage.MasterLabel, stage);            
        }
    }

}