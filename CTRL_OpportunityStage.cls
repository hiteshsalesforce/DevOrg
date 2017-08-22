public with sharing class CTRL_OpportunityStage 
{

    private final Opportunity opportunityRecord;
    public String oppStageList {get;set;}
    public String oppStageNum {get;set;}

    public CTRL_OpportunityStage(ApexPages.StandardController stdController) 
    {
        this.opportunityRecord = (Opportunity)stdController.getRecord();

        oppStageList = '[\'';
        oppStageNum = '[\'';

        getPicklistValues();
    }

    public void getPicklistValues()
    {
        
        Set<String> stages = new Set<String>(UTIL_PickList.describe(opportunityRecord.Id, DAL_Opportunity.FIELD_STAGENAME));

        Integer i = 1;
        for (String stage : stages)
        {
            oppStageList += stage + '\', \'';
            oppStageNum += i + '\', \'';
            i += 1;  
        }

        oppStageList = oppStageList.substring(0, oppStageList.length() - 3);
        oppStageList = oppStageList + ']';

        oppStageNum = oppStageNum.substring(0, oppStageNum.length() - 3);
        oppStageNum = oppStageNum + ']';
    }
}