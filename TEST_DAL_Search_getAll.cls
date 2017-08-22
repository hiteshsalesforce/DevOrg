@isTest(SeeAllData=false)
private class TEST_DAL_Search_getAll
{   
    static testMethod void test_getAll()
    {
        Account newAccount = DAL_Account.insertItem();
        
        Test.startTest();

        List<Account> accounts = DAL_Search.getAll(Account.SObjectType, newAccount.Name);
       
        Test.stopTest();

        System.assert(!accounts.isEmpty(), 'No Accounts retrieved.');
    }
}