public class DAL_User
{
    private static final String USER_TYPE_STANDARD = 'Standard';
    
    public static final String FIELD_EMAIL_ENCODING_KEY = User.EmailEncodingKey.getDescribe().getLocalName();
    public static final String OBJECT_NAME = User.sObjectType.getDescribe().getLocalName();

    public static User getCurrentUser()
    {
        User user;
        try 
        {
            user = 
                [
                    SELECT
                        Id,
                        Email                   
                    FROM
                        User
                    WHERE
                        Username = :UserInfo.getUserName()
                    LIMIT 1
                ];
        } 
        catch (QueryException e)
        {
            System.debug('DAL_User.getCurrentUser:' + e.getStackTraceString());
        }       

        return user;
    }

    public static List<User> getByIds(Set<Id> userIds)
    {
        List<User> users = new List<User>();
        try 
        {
            users = 
                [
                    SELECT
                        Id,
                        Name,
                        Firstname,
                        LastName,
                        Email
                    FROM 
                        User 
                    WHERE 
                        Id IN :userIds
                ]; 
        } 
        catch(QueryException e)
        {
            System.debug('DAL_User.getByIds:' + e.getStackTraceString());
        }
        return users;
    }   
    
    public static List<User> getActiveUsers()
    {
        return 
        [
            SELECT Id, Name
            FROM User 
            WHERE IsActive = true
            AND UserType = :USER_TYPE_STANDARD
        ];
    }
    
    public static User getRandomActiveUser()
    {
        List<User> users = getActiveUsers();
        System.assert(!users.isEmpty());
        Integer index = al.RandomUtils.nextInteger(users.size() - 1);
        return users[index];
    }

}