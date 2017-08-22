public class FLOW_Case_Create 
{
	@InvocableMethod(label='Create Cases' 
					description='This method can be called to create a list of Cases'
					)
	public static void createCases(List<DAL_Case.CaseDefinition> caseDefinitions)
	{		
		DAL_BaseObject.insertDBObjects(DAL_Case.newItems(caseDefinitions));
	}	
}