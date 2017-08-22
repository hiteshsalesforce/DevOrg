/**
	Visualforce controller for a page that renders the XML output Pick List values on Custom or Standard Objects
	Original code was sourced from https://github.com/abhinavguptas/Multi-RecordType-Sobject-Picklist-Describer.git
*/
public class CTRL_PickListDescriber 
{
	public SObject SObj {get;set;}
	public String PickListFieldName {get;set;}		
	
	public CTRL_PickListDescriber() 
	{
		Map<String, String> requiredParameters = ApexPages.currentPage().getParameters();

		String sobjId = requiredParameters.get(UTIL_PickList.PARAM_OBJECT_ID);
		PickListFieldName = requiredParameters.get(UTIL_PickList.PARAM_PICK_LIST_NAME); 
		String sobjectTypeName = requiredParameters.get(UTIL_PickList.PARAM_OBJECT_TYPE);
		
		if (String.isNotBlank(sObjId))
		{
			SObj = Database.query(
							new al.SoqlBuilder()
		           			.selectx(PickListFieldName)
							.fromx(sobjectTypeName)
							.wherex(new al.FieldCondition(DAL_BaseObject.ID_FIELD, sobjId))
							.toSoql(new al.SoqlOptions().escapeSingleQuotes())
						);
		}	
		else
		{
			//Construct an SObject using it's API Name
			SObj = DAL_BaseObject.newObject(sobjectTypeName);
			
			if (SObj != null)
			{
				String recordTypeName = requiredParameters.get(UTIL_PickList.PARAM_RECORD_TYPE);
				
				if (String.isNotBlank(recordTypeName))
				{
					Id recordTypeId = DAL_BaseObject.getRecordTypeByDeveloperName(SObj.getSObjectType(), recordTypeName);
					
					if (recordTypeId != null)
					{
						//Get all the recordtypes available for this object, if one of them matches
						//the name of the passed recordtype name, then assign it to the SObject (if the user is allowed access)
						Map<Id, Schema.RecordTypeInfo> recordTypes = SObj.getSObjectType().getDescribe().getRecordTypeInfosById();
						
						Schema.RecordTypeInfo recordType = recordTypes.get(recordTypeId);
						
						if (recordType != null && recordType.isAvailable())
							SObj.put(DAL_BaseObject.RECORDTYPE_ID_FIELD, recordTypeId);
					}
				}

			}

		}
	}  
	
}