/*
** This is the class which contains all the DML and SOQL statements related to Accounts  
** It impements various common functions which can be reused
*/
public class DAL_Account
{
	public static final String OBJECT_NAME = Account.SObjectType.getDescribe().getLocalName();
	
	public static Account newItem()
	{
		Account newAccount = new Account();
		newAccount.Name = DAL_BaseObject.generateRandomName();
		newAccount.OwnerId = UserInfo.getUserId();
		newAccount.AccountSource = DAL_BaseObject.generateRandomEmail();

		return newAccount;
	}
	
	public static Account insertItem()
	{
		Account newAccount = newItem();

		DAL_BaseObject.insertDBObject(newAccount);
		
		return newAccount;
	}
	
	public static List<Account> getAll()
	{
		List<Account> accounts = new List<Account>();

		return
		[
			SELECT
   				Id,
   				Name,
   				OwnerId,
   				Phone,
				Website
   			FROM
   				Account
   			LIMIT 10000
   		];
	}
	
	public static List<Account> findById(Set<Id> accountIds)
	{
		return 
		[
			SELECT 
				Id, 
				Description,
				LastModifiedById,
				Name
			FROM Account 
			WHERE Id IN :accountIds
		];
	}

	public static Account findById(ID AccountID)
	{
		List<Account> accounts = findById(new Set<ID>{AccountID});
		if (accounts.isEmpty())
			return null;
		else
			return accounts[0];
	}  
			
	public static Account findById(Account account)
	{
		return findById(account.Id);
	}  
}