@isTest(seeAllData = false)
private class TEST_DAL_Search_SOSL_Search 
{
	private static final String NAME = 'Name';

	static testMethod void findObjects()
	{
		Account account1 = DAL_Account.newItem();
		account1.Name = NAME;
		Account account2 = DAL_Account.newItem();
		account2.Name = NAME;
		Account account3 = DAL_Account.newItem();
		account3.Name = NAME;

		DAL_BaseObject.InsertDBObjects(new List<SObject>{
														account1,
														account2,
														account3
														});

		Test.setFixedSearchResults(new List<String> {
														account1.Id,
														account2.Id,
														account3.Id
													});

		String term = '{' + NAME + '}';
		DAL_Search.SOSLSearchParameters parameters = new DAL_Search.SOSLSearchParameters(Account.SObjectType, term);

		Test.startTest();

		List<SObject> response1 = DAL_Search.soslSearch(DAL_Account.OBJECT_NAME, term);
		DAL_Search.SearchResponse response2 = DAL_Search.soslSearch(parameters);

		Test.stopTest();

		System.assertEquals(3, response1.size());
		System.assertNotEquals(null, response2);
		System.assertEquals(3, response2.ItemList.size());
	}	
}