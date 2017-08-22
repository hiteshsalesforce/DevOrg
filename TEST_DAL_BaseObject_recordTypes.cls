@isTest(SeeAllData=false)
private class TEST_DAL_BaseObject_recordTypes
{   
    static testMethod void test_getRecordTypeById()
    {
        Schema.sObjectType accountType = Schema.Account.getSObjectType();
        
        List<RecordType> recordTypes = DAL_BaseObject.getRecordTypes(accountType);      
        
        if (recordTypes.size() > 0)
        {
            RecordType rt = recordTypes.get(0);
        
            // TEST 1
            Id rt_id = rt.Id;
            String expectedName = rt.Name;
            String fetchedName = DAL_BaseObject.getRecordTypeById(rt_id);
            System.assertEquals(expectedName, fetchedName);

            //TEST 2
            String emptyName = DAL_BaseObject.getRecordTypeById(null);
            System.assertEquals(true, String.isEmpty(emptyName));
        }               
    }

    static testMethod void test_getRecordTypesByIds()
    {
        Schema.sObjectType accountType = Schema.Account.getSObjectType();       
        List<RecordType> accountRecordTypes = DAL_BaseObject.getRecordTypes(accountType);

        Set<Id> ids = new Set<Id>();
        for (RecordType rt : accountRecordTypes)
        {
            ids.add(rt.Id);
        }

        List<RecordType> fetchedRecordTypes = DAL_BaseObject.getRecordTypesByIds(ids);
        System.assertEquals(accountRecordTypes.size(), fetchedRecordTypes.size());
    }

    static testMethod void test_getRecordTypeByDeveloperName()
    {
        Schema.sObjectType accountType = Schema.Account.getSObjectType();
        
        List<RecordType> recordTypes = DAL_BaseObject.getRecordTypes(accountType);      
        
        if (recordTypes.size() > 0)
        {
            RecordType rt = recordTypes.get(0);
        
            String developerName = rt.DeveloperName;        

            Id fetchedId = DAL_BaseObject.getRecordTypeByDeveloperName(accountType, developerName);
            System.assertEquals(rt.Id, fetchedId);
        }       
    }

    static testMethod void test_getRecordTypesByDeveloperNames()
    {
        Schema.sObjectType accountType = Schema.Account.getSObjectType();       
        List<RecordType> accountRecordTypes = DAL_BaseObject.getRecordTypes(accountType);

        Set<String> developerNames = new Set<String>();
        Set<Id> expectedIds = new Set<Id>();
        for (RecordType rt : accountRecordTypes)
        {
            developerNames.add(rt.DeveloperName);
            expectedIds.add(rt.Id);
        }

        Set<Id> fetchedIds = DAL_BaseObject.getRecordTypesByDeveloperNames(developerNames);
        System.assertEquals(expectedIds, fetchedIds);
    }

}