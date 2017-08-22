/* 
**   General Utility Class which will contain common routines that can be resused within the system
*/
public class UTIL_System 
{
    public class AssertionException extends exception {}
    public class InvalidMethodParametersException extends exception {}

    private static final String JSON_STRING_FMT = '"{0}"';
    private static final String JSON_QUOTE = '"';
    
    public virtual class JlException extends Exception {}
    public class RecordTypeException extends JlException {}
    public class PageReferenceException extends JlException {}
    public class DataGenerationException extends JlException {}
    
    private static Integer FISCAL_YEAR_START_MONTH = 7;
    private static Integer YEAR_END_MONTH = 12;

    public static void justThrow()
    {
        throw new JlException();
    }
    public static void justThrow(String message)
    {
        throw new JlException(message);
    }

    public static void throwDataGenerationException(String what, String why)
    {
        throw new DataGenerationException(String.format(UTIL_Constants.XM_GEN_ERROR, new List<String> {what, why}));
    }

    public static void throwFieldValueAsertionException(String subject, String fieldName, Object expected, Object got, String message)
    {
        throw new AssertionException(String.format(UTIL_Constants.XM_ASSERT_VALUE, new List<String> {subject, fieldName, String.valueOf(expected), String.valueOf(got), message}));
    }

    public static void throwInvalidMethodParametersException(String methodName, String message)
    {
        throw new InvalidMethodParametersException(String.format(UTIL_Constants.XM_INVALID_METHOD_PARAMS, new List<String> {methodName, message}));
    }
    
    public static String convertAddressToString(Address addressToConvert)
    {
        String address = '';
        if(addressToConvert.getStreet() != null)
            address += addressToConvert.Street + ', ';
        if(addressToConvert.getCity() != null)
            address += addressToConvert.City + ', ';
        if(addressToConvert.getState() != null)
            address += addressToConvert.State + ', ';
        if(addressToConvert.getPostalCode() != null)
            address += addressToConvert.getPostalCode() + ', ';
        if(addressToConvert.getCountry() != null)
            address += addressToConvert.Country + ', ';

        address = address.Substring(0,address.length()-2);

        return address;
    }   

    public static List<SObject> extractListFromMap(Map<String, List<SObject>> objectMap)
    {
        List<SObject> objectList = new List<SObject>();
                
        if (objectMap != null &&  objectMap.values() != null && !objectMap.values().isEmpty())
            for (List<SObject> valuesList : objectMap.values())
                objectList.addAll(valuesList);              

        
        return objectList;
    }   

    public static Boolean matches(SObject obj, Map<String, Object> filter)
    {
        Boolean bMatches;

        for (String name : filter.keySet()) {
            Object fieldVal = obj.get(name);
            Object filterVal = filter.get(name);

            // Special case: we assume a match when [boolean] false == null.
            // Extend these special cases, as needed (e.g. string null = ''). Also, we may want to specify a "strict match" at some stage.
            if (filterVal instanceof Boolean && (Boolean)filterVal == false)
                bMatches = fieldVal == false || fieldVal == null;
            else
                bMatches = fieldVal == filterVal;

            if (!bMatches) return false;
        }

        return true;
    }

    public static List<SObject> findWhere(List<SObject> objects, String fieldName, Object value)
    {
        return findWhere(objects, new Map<String, Object>{ fieldName => value });
    }

    public static List<SObject> findWhere(List<SObject> objects, Map<String, Object> filter)
    {
        List<SObject> result = new List<SObject>();
        for (SObject obj : objects)
            if (matches(obj, filter))
                result.add(obj);

        return result;
    }

    public static List<SObject> findWhereIn(List<SObject> objects, String fieldName, List<Object> values)
    {       
        Set<Object> valueSet = new Set<Object>(values);
        Object fieldVal;
        List<SObject> result = new List<SObject>();
        
        for (SObject obj : objects)
        {
            fieldVal = obj.get(fieldName);

            if (valueSet.contains(fieldVal))
                result.add(obj);
        }

        return result;
    }

    public static List<SObject> omitWhere(List<SObject> objects, String fieldName, Object value)
    {
        return omitWhere(objects, new Map<String, Object>{ fieldName => value });
    }

    public static List<SObject> omitWhere(List<SObject> objects, Map<String, Object> filter)
    {
        if (objects == null) return null;

        List<SObject> result = new List<SObject>();
        for (SObject obj : objects)
            if (!matches(obj, filter))  {
                result.add(obj);
            }

        return result;
    }

    public static Set<ID> omit(Set<ID> masterList, Set<ID> toBeOmitted)
    {
        if (masterList == null) return null;
        Set<ID> result = masterList.clone();
        result.removeAll(toBeOmitted);
        return result;
    }

    public static Set<ID> concat(Set<ID> set1, Set<ID> set2)
    {
        Set<ID> result = new Set<ID>(set1);
        result.addAll(set2);
        return result;
    }

    public static Set<String> pluck(List<SObject> objects, String fieldName, Map<String, Object> filter)
    {
        Set<String> fieldSet = new Set<String>();

        if (objects != null)
            for (SObject obj : objects)
                if (matches(obj, filter))
                    fieldSet.add(String.valueOf(obj.get(fieldName)));

        return fieldSet;
    }

    public static Set<String> pluck(List<SObject> objects, String fieldName, String filterField, Object filterValue)
    {
        return pluck(objects, fieldName, new Map<String, Object>{ filterField => filterValue });
    }

    public static Set<String> pluck(List<SObject> objects, String fieldName)
    {
        return pluck(objects, fieldName, new Map<String, Object>());
    }

     public static List<SObject> excludeItemsFromList(List<SObject> sourceItems, List<SObject> excludeItems)
     {
        List<SObject> resultList = new List<SObject>();
        
        if (sourceItems == null || sourceItems.isEmpty())
            return resultList;
            
        if (excludeItems == null || excludeItems.isEmpty())
        {
            resultList.addAll(sourceItems);
            return resultList;
        }
            
        Set<SObject> objectSet = new Set<SObject>(sourceItems);
        objectSet.removeAll(excludeItems);
        resultList.addAll(objectSet);
        
        return resultList;
    }

    public static Boolean hasSObjectField(SObject so, String fieldName)
    {
        try
        {
            so.get(fieldName);
            return true;
        }
        catch( Exception ex )
        {
            return false;
        }
    }

    public static Map<Id, String> getRecordTypeMap(String objectType)
    {
        Map<Id, String> recordTypeMap = new Map<Id, String>();
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :objectType];

        for(RecordType recordType : recordTypes)
            recordTypeMap.put(recordType.Id, recordType.DeveloperName);

        return recordTypeMap;
    }
    
   public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName)
    {
        //Generate a map of tokens for all the Record Types for the desired object
        Map<String, Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();

        if(!recordTypeInfo.containsKey(recordTypeName))
            throw new RecordTypeException('Record type "'+ recordTypeName +'" does not exist.');

        //Retrieve the record type id by name
        return recordTypeInfo.get(recordTypeName).getRecordTypeId();
    }

    
    public static Set<Id> extractListIds(List<SObject> objects, String fieldName, Boolean removeNulls)
    {
        Set<Id> Ids = new Set<Id>();

        ID itemId;
        if (objects != null)
            for (SObject item : objects)
            {
                itemId = (Id)item.get(fieldName);
                if (!removeNulls || itemId != null)
                    Ids.add(itemId);
            }

        return Ids;
    }

    public static Set<Id> extractListIds(List<SObject> objects, String fieldName)
    {
        return extractListIds(objects, fieldName, false);
    }
    
    public static Set<Id> extractListIds(List<SObject> objects)
    {
        return extractListIds(objects, false);
    }

    public static Set<Id> extractListIds(List<SObject> objects, Boolean removeNulls)
    {
        Set<Id> result = (new Map<Id, SObject>(objects)).keySet();
        if (removeNulls)
            result.remove(null);
        return result;
    }
    
    public static Set<Date> extractListDates(List<SObject> objects, String fieldName)
    {
        Set<Date> result = new Set<Date>();

        if (objects != null)
            for (SObject item : objects)
                result.add((Date)item.get(fieldName));

        return result;
    }

    public static List<String> extractListValues(List<SObject> objects, String fieldName)
    {
        List<String> result = new List<String>();

        if (objects != null)
            for (SObject item : objects)
                result.add((String)item.get(fieldName));

        return result;
    }

    public static Set<Id> trimSet(Set<Id> idList)
    {
        Set<Id> result = new Set<Id>();
        for(Id item: idList)
            if(item != null)
                result.add(item);
                
        return result;
                
    }
    
    public static Set<String> trimSet(Set<String> stringSet)
    {
        Set<String> result = new Set<String>();
        for(String item: stringSet)
            if(String.isNotBlank(item))
                result.add(item);
                
        return result;
                
    }
    
    public static Map<Id, Set<Id>> convertListToMapSet(List<SObject> objectList, String objectFieldName,String KeyFieldName)
    {
         Map<Id, Set<Id>> objectMap = new Map<Id, Set<Id>>();
    
        if (objectList != null)
            for (SObject item : objectList)
            {
                Id idFromField = (Id)item.get(objectFieldName);

                if ( !objectMap.containsKey(idFromField))
                {
                    Set<Id> SetInMap = new Set<Id>();
                    SetInMap.add((Id)item.get(KeyFieldName));
                    objectMap.put(idFromField , SetInMap);
                }
                else
                {
                    Set<Id> SetInMap = objectMap.get(idFromField);
                    SetInMap.add((Id)item.get(KeyFieldName));
                }
            }
         
        return objectMap;
    }

    public static Map<Id, List<SObject>> convertListToMap(List<SObject> objectList, String objectFieldName)
    {
         Map<Id, List<SObject>> objectMap = new Map<Id, List<SObject>>();
         
         if (objectList != null)
             for (SObject item : objectList)
             {
                Id idFromField = (Id)item.get(objectFieldName);

                if ( !objectMap.containsKey(idFromField))
                {
                    List<SObject> listInMap = new List<SObject>();
                    listInMap.add(item);
                    objectMap.put(idFromField , listInMap);
                }
                else
                {
                    List<SObject> listInMap = objectMap.get(idFromField);
                    listInMap.add(item);
                }
             }
         
         return objectMap;
    }

    public static Map<Id, SObject> convertListToSingleMap(List<SObject> objectList, String objectFieldName)
    {
         Map<Id, SObject> objectMap = new Map<Id, SObject>();
         
         if (objectList != null)
             for (SObject item : objectList)
             {
                Id idFromField = (Id)item.get(objectFieldName);
                objectMap.put(idFromField, item);
             }
         
         return objectMap;
    }

    public static Map<String, List<SObject>> convertListToStringMap(List<SObject> objectList, String objectFieldName)
    {
         Map<String, List<SObject>> objectMap = new Map<String, List<SObject>>();
         
         if (objectList != null)
             for (SObject item : objectList)
             {
                String idFromField = (String)item.get(objectFieldName);
                
                List<SObject> listInMap = objectMap.get(idFromField);

                if (listInMap == null)
                {
                    listInMap = new List<SObject>();
                    objectMap.put(idFromField, listInMap);
                }
                
                listInMap.add(item);
    
             }
         
         return objectMap;
    }

    public static Map<String, SObject> convertListToSingleStringMap(List<SObject> objectList, String objectFieldName)
    {
         Map<String, SObject> objectMap = new Map<String, SObject>();
         
         if (objectList != null)
             for (SObject item : objectList)
             {
                String idFromField = (String)item.get(objectFieldName);
                objectMap.put(idFromField, item);
             }
         
         return objectMap;
    }

    public static String getCompoundKey(SObject obj, String[] objectFieldNames)
    {
        String result = '';

        for (String field : objectFieldNames)
            result += String.valueOf(obj.get(field));

        return result;
    }

    public static Map<String, SObject> convertListToSingleMap(List<SObject> objectList, String[] objectFieldNames)
    {
        Map<String, SObject> objectMap = new Map<String, SObject>();

        if (objectList != null)
            for (SObject item : objectList)
                objectMap.put(getCompoundKey(item, objectFieldNames), item);

        return objectMap;
    }

	public static void logException(Exception error)
	{
		if (error instanceof System.DMLException)
		{
			System.DMLException dmlError = (System.DMLException)error;
			for (Integer i = 0; i < dmlError.getNumDml(); i++)
				System.debug(dmlError.getDmlMessage(i));
		}
		else
			System.debug(error);
	}

    public static void processException(Exception error, SObject so)
    {
        logException(error);

        if (error instanceof System.DMLException)
        {
            System.DMLException dmlError = (System.DMLException)error;

            if (dmlError.getNumDml() > 0)
                so.addError(dmlError.getDmlMessage(0), false);
            else
                so.addError(error, false);
        }
        else
            so.addError(error, false);
    }

    public static List<Id> setToList(Set<Id> aSet) 
    {
        List<Id> returnValue = null;
        if (aSet != null)
            returnValue = new List<Id>(aSet);
        return returnValue;
    }

    public static List<String> setToList(Set<String> aSet) 
    {
        List<String> returnValue = null;
        if (aSet != null)
            returnValue = new List<String>(aSet);
        return returnValue;
    }    
    
	public static String getObjectNameFromId(Id objId)
	{
		return al.StringUtils.capitalize(al.DatabaseUtils.retrieveObjectName(objId));
	}
	
	public static SObjectType getSObjectTypeByName(String sobjectTypeName)
	{
    	if (String.isBlank(sobjectTypeName))
      		return null;
      
    	return Schema.getGlobalDescribe().get(sobjectTypeName);
	}
	
	public static Boolean isEmpty(String str)
    {
        return str == null || str == '';
    }
	
	public static List<Schema.PicklistEntry> getPicklistEntries(String objType, String fieldName)
	{
		Schema.SObjectType token = Schema.getGlobalDescribe().get(objType);
		return getPicklistEntries(token, fieldName);
	}

	public static List<Schema.PicklistEntry> getPicklistEntries(Schema.SObjectType token, String fieldName)
	{
		Schema.DescribeSObjectResult describe = token.getDescribe();
		Map<String, Schema.SObjectField> fieldMap = describe.fields.getMap();
		return fieldMap.get(fieldName).getDescribe().getPickListValues();
	}

	public static Map<String,String> getPicklistEntriesMap(Schema.SObjectType token, String fieldName)
	{
		List<Schema.PicklistEntry> picklistEntries = getPicklistEntries(token, fieldName);
		Map<String,String> picklistEntriesMap = new Map<String,String>();
		for(Schema.PicklistEntry picklistEntry : picklistEntries)
      		picklistEntriesMap.put(picklistEntry.getLabel(),picklistEntry.getValue());

    	return picklistEntriesMap;
	}
	
	public static Date dateTimeToDate(Datetime inDate)
    {
        return Date.newinstance(inDate.year(), inDate.month(), inDate.day());
    }

    // =================== Testing Helpers
    public static void assertEmptyList(List<SObject> items, String message)
    {
        assertSizeEquals(items, 0, message);
    }

    public static void assertSizeEquals(List<SObject> items, Integer size, String message)
    {
        if (items.size() != size) 
        {
            String msg = String.format('Assertion error: List is size {0}, and should be {1}. {2}', new String[] {string.valueOf(items.size()), string.valueOf(size), message != null ? ', for: ' + message : ''});
            throw new AssertionException(msg);
        }
    }

    public static void assertIDSetEquals(Set<ID> set1, Set<ID> set2, String message)
    {
        if (set1.size() != set2.size())
        {
            String msg = String.format('Assertion error: Lists of mismatching size {0} and {1}. {2}', new String[] {string.valueOf(set1.size()), string.valueOf(set2.size()), message != null ? ', for: ' + message : ''});
            throw new AssertionException(msg);
        }

        for (ID s : set1)
            if (!set2.contains(s))
            {
                String msg = String.format('Assertion error: List content mismatch - Element {0} not found. {1}', new String[] {s, message != null ? ', for: ' + message : ''});
                throw new AssertionException(msg);
            }
    }
    
    public static void assertDateSetEquals(Set<Date> set1, Set<Date> set2, String message)
    {
        if (set1.size() != set2.size())
        {
            String msg = String.format('Assertion error: Lists of mismatching size {0} and {1}. {2}', new String[] {string.valueOf(set1.size()), string.valueOf(set2.size()), message != null ? ', for: ' + message : ''});
            throw new AssertionException(msg);
        }

        for (Date s : set1)
            if (!set2.contains(s))
            {
                String msg = String.format('Assertion error: List content mismatch - Element {0} not found. {1}', new String[] {s.format(), message != null ? ', for: ' + message : ''});
                throw new AssertionException(msg);
            }
    }

    public static void assertObjectValues(SObject obj, String[] fieldNames, Object[] values, String message)
    {
        String objName = obj.getSObjectType().getDescribe().getLocalName();
        for (Integer i = 0; i < Math.min(fieldNames.size(), values.size()); i++)
            if (obj.get(fieldNames[i]) != values[i])
                throwFieldValueAsertionException(objName, fieldNames[i], values[i], obj.get(fieldNames[i]), message);
    }

    /**
     * Remove all matching items from a list
     *
     * @param   sourceItems The list containing the original source items
     * @param   deleteItems The set of items we want to remove
     * @return  A list containing the remaining items after removing matching deleteItems
     */
    public static List<String> removeItems(List<String> sourceItems, Set<String> deleteItems)
    {
        List<String> result = new List<String>(sourceItems);
        
        if (sourceItems.isEmpty() || deleteItems.isEmpty())
            return result;
            
        //Loop backwards through the list so that the index remains valid
        for(Integer i = result.size() - 1; i >= 0; i--)
            if (deleteItems.contains(result[i]))
                    result.remove(i);
                    
        return result;
    }
            
}