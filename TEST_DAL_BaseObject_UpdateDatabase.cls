@isTest(SeeAllData=false)
private class TEST_DAL_BaseObject_UpdateDatabase
{   
    static testMethod void test_UpdateDatabase_Success()
    {
        Account a = DAL_Account.newItem();  
        
        //TEST 1 - Insert object
        Boolean isInserted = DAL_BaseObject.InsertDBObject(a);
        System.assertEquals(isInserted, true);

        a.Name = DAL_BaseObject.generateRandomName();
        
        //TEST 2 - Update object
        Boolean isUpdated = DAL_BaseObject.UpdateDBObject(a);
        System.assertEquals(isUpdated, true);

        //TEST 3 - Delete object
        Boolean isDeleted = DAL_BaseObject.DeleteDBObject(a);
        System.assertEquals(isDeleted, true);
    }

    static testMethod void test_UpdateDatabase_Fail()
    {
        Account a = DAL_Account.newItem();  
        List<Account> accounts = new List<Account>();
        accounts.add(a);        
        
        //TEST 1 - Insert object (Causes exception but does not fail because allInsertsMustSucceed=false)
        Boolean isInserted = DAL_BaseObject.InsertDBObjects(accounts, false);
        System.assertEquals(isInserted, true);

        //TEST 2 - Update object (Causes exception but does not fail because allUpdatesMustSucceed=false)
        Boolean isUpdated = DAL_BaseObject.UpdateDBObjects(accounts, false);
        System.assertEquals(isUpdated, true);

        //TEST 3
        //Preparing test data;
        accounts = new List<Account>();
        Account a2 = DAL_Account.newItem(); 
        accounts.add(a2);
        isInserted = DAL_BaseObject.InsertDBObjects(accounts, true);

        //Deleting objects
        Boolean isDeleted = DAL_BaseObject.DeleteDBObjects(accounts, true);

        //Deleting objects second time causes exception but does not fail because allDeletesMustSucceed=false
        isDeleted = DAL_BaseObject.DeleteDBObjects(accounts, false);
        System.assertEquals(isDeleted, true);
    }


}