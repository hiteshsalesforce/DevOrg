@isTest(SeeAllData=false)
private class TEST_DAL_BaseObject_safeDelete
{

    static testMethod void test_safeDelete()
    {
        Account newAccount = DAL_Account.newItem();

        Boolean isInserted = DAL_BaseObject.InsertDBObject(newAccount);
        System.assertEquals(true, isInserted);
        
        String name = newAccount.Name;
        
        newAccount = DAL_Account.findById(newAccount.Id);
        System.assertEquals(name, newAccount.Name);

        SObjectType objectType = Schema.Account.getSObjectType();
        List<Account> objects = new List<Account>{newAccount};

        Test.startTest();
        DAL_BaseObject.safeDelete(objectType, objects, DAL_BaseObject.ID_FIELD);
        Test.stopTest();
    }
}