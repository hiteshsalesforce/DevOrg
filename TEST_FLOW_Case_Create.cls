/*
* @description Unit test method(s) to ensure the Apex Process Builder invocationmethod works as expected
*/
@isTest(seeAllData = false) 
private class TEST_FLOW_Case_Create 
{
    static testMethod void createCase() 
    {
		Account newAccount = DAL_Account.insertItem();
	
		Opportunity newOpportunity = DAL_Opportunity.insertItem(newAccount.Id, DAL_Opportunity.STAGE_PROSPECTING);
		
		DAL_Case.CaseDefinition definition = 
			DAL_Case.newCaseDefinition
			(
				newAccount.Id, 
				newOpportunity.Id, 
				DAL_CASE.RT_DEFAULT, 
				DAL_CASE.QUEUE_DEFAULT
			);
		
		Test.startTest();  
		
		FLOW_Case_Create.createCases(new List<DAL_Case.CaseDefinition>{definition});
		
		Test.StopTest(); 
		
		
		List<Case> cases = DAL_Case.findByOpportunityId(newOpportunity.Id);
		
		System.assert(!cases.isEmpty(), 'No Cases were Created.');
		
		Case newCase = cases[0];
		String subject = String.format(DAL_BaseObject.SUBJECT_FMT, new String[]{definition.subjectPrefix, definition.subject});
		System.assertEquals(subject, newCase.Subject, 'The Case subject was not set correctly.');
    }
}