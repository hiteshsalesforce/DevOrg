/*
** This is the class which contains all the DML and SOQL statements related to Cases  
** It impements various common functions which can be reused
*/
public class DAL_Case extends TH_BaseObject
{
	public static final String CASE_STATUS_NEW = 'New';
	public static final String CASE_STATUS_CLOSED = 'Closed';
	public static final String CASE_STATUS_WORKING = 'Escalated';
	public static final String RT_DEFAULT ='Default_Case_RecordType';
	public static final String QUEUE_DEFAULT = 'Default';
	public static final String FIELD_STATUS = Case.Status.getDescribe().getLocalName();
	public static final String OBJECT_NAME = Case.sObjectType.getDescribe().getLocalName();
	
	public class CaseDefinition
	{
		@InvocableVariable(label='Account ID' description='The Account against which to relate this case' required=true)
    	public ID accountId;
		
		@InvocableVariable(label='Subject' description='Please enter the Subject of the Case' required=true)
    	public String subject;
    	
		@InvocableVariable(label='Record Type Name' description='The Record Type Developer Name' required=true)
		public String recordTypeDeveloperName;
		
		@InvocableVariable(label='Origin' description='The Origin of the case.' required=false)
		public String origin;
    	
		@InvocableVariable(label='Queue Name' description='The name of Queue which will be set as the Owner of the Case' required=false)
		public String ownerQueue;
    	
		@InvocableVariable(label='Subject Prefix' description='The prefix for the Case subject' required=false)
		public String subjectPrefix;
		
		@InvocableVariable(label='Processing Instructions' description='A Processing Instruction that will update related fields when the case is closed' required=false)
		public String processingInstructions;
		
		@InvocableVariable(label='Opportunity ID' description='The Opportunity against which to relate this case' required=false)
    	public ID opportunityId; 
    	
    	@InvocableVariable(label='Status' description='The status of the case, such as "New," "Closed," or "Escalated.""' required=false)
    	public String status; 
	}
	
	public static CaseDefinition newCaseDefinition(ID accountId, ID opportunityId, String recordTypeName, String queueName)
	{
		CaseDefinition newDefinition = new CaseDefinition();
		
		newDefinition.accountId = accountId;
		newDefinition.opportunityId = opportunityId;	
		newDefinition.recordTypeDeveloperName = recordTypeName;	
		newDefinition.ownerQueue = queueName;	
		newDefinition.subject = DAL_BaseObject.generateRandomName();
		newDefinition.origin = DAL_BaseObject.generateRandomName();	
		newDefinition.subjectPrefix = DAL_BaseObject.generateRandomName();	
		newDefinition.processingInstructions = DAL_BaseObject.generateRandomName();
		newDefinition.status = CASE_STATUS_NEW;	
		
		return newDefinition;
	}
		
	public static Case insertItem(Account account, String recordTypeName, String status)
	{
		Case newCase = insertItem(account.Id, recordTypeName, status);
		return newCase;
	}
	
	public static Case insertItem(ID accountId, String recordTypeName, String status)
	{
		Case newCase = newItem(accountId, recordTypeName, status);
		DAL_BaseObject.insertDBObject(newCase);
		return newCase;
	}
	
	public static Case newItem(Account account, String recordTypeName, String status)
	{
		Case newCase = newItem(account.Id, recordTypeName, status);
		return newCase;
	}
	
	public static Case newItem(ID accountId, String recordTypeName, String status)
	{
		Case newCase = new Case();
		
		newCase.AccountId = accountId;
		newCase.Status = status;
		if (String.isNotBlank(recordTypeName))
			newCase.RecordTypeId = DAL_BaseObject.getRecordTypeByDeveloperName(Case.SObjectType, recordTypeName);

		return newCase;
	}
	
	public static Case newItem(CaseDefinition definition)
	{
		Case newCase = newItem(definition.accountId, definition.recordTypeDeveloperName, definition.status);
		
		newCase.Subject = String.isBlank(definition.subjectPrefix) ? definition.subject : String.format(DAL_BaseObject.SUBJECT_FMT, new String[]{definition.subjectPrefix, definition.subject});
		newCase.Origin = definition.origin;
		newCase.Processing_Instructions__c = definition.processingInstructions;
		newCase.Opportunity__c = definition.opportunityId;
		
		ID ownerID = null;
		
		if (String.isNotBlank(definition.ownerQueue))
		{
			Group ownerQueue = DAL_Group.findQueueByName(definition.ownerQueue);
			if (ownerQueue != null)
				ownerID = ownerQueue.Id;
		}
		
		newCase.OwnerId = ownerID;
			
		return newCase;
	}
	
	public static List<Case> newItems(List<CaseDefinition> definitions)
	{
		List<Case> newCases = new List<Case>();
		
		for (CaseDefinition definition : definitions)
			newCases.add(newItem(definition));
			
		return newCases;
	}
		
	public static List<Case> findById(Set<Id> caseIds)
	{
		return
		[
			SELECT 
			  Id, 
			  ParentId, 
			  Subject,
			  Processing_Instructions__c,  
			  AccountId,
			  Status,
			  RecordTypeId,
			  Reason,
			  IsClosed
			FROM Case  
			WHERE Id IN :caseIds
		];
	}
		
	public static Case findById(ID caseID)
	{
		List<Case> cases = findById(new Set<ID>{caseID});
		if (cases.isEmpty())
			return null;
		else
			return cases[0];
	}
	
	public static Case findById(Case aCase)
	{
		return findById(aCase.ID);
	}
	
	public static List<Case> findByOpportunityId(ID opportunityId)
	{
		return
		[
			SELECT 
			  Id,
			  Subject
			FROM Case  
			WHERE Opportunity__c = :opportunityId
		];
	}
}