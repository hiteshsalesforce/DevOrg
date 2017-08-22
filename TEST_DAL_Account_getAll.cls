@isTest(SeeAllData=false)
private class TEST_DAL_Account_getAll
{
    static testMethod void testGetAll() 
    {
        Account a = DAL_Account.insertItem();

        Test.startTest();
        List<Account> listAccount =  DAL_Account.getAll();
        Test.stopTest();
     
        //Dummy test for code coverage.
        system.assertEquals(listAccount.size(), 1);
    }
}