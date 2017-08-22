@isTest(SeeAllData=false)
private class TEST_DAL_Search_dynamicSearch
{   
    public static final List<String> SEARCH_FIELDS = new List<String> {DAL_BaseObject.NAME_FIELD}; 
    public static final Set<String> SELECT_FIELDS = new Set<String>{DAL_BaseObject.ID_FIELD, DAL_BaseObject.NAME_FIELD};

    static testMethod void test_dynamicSearch()
    {
        Account newAccount = DAL_Account.insertItem();

        Test.startTest();

        List<Account> accounts = DAL_Search.dynamicSearch(DAL_Account.OBJECT_NAME, newAccount.Name, SEARCH_FIELDS, SELECT_FIELDS, null, 1, 0);

        Test.stopTest();
        
        System.assert(!accounts.isEmpty(), 'Account not Found.');
    }   
}