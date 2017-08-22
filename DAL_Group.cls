public class DAL_Group 
{
	private static String QUEUE_TYPE = 'Queue';
	
	public static Group findQueueByName(String name)
	{
		List<Group> queues =
		[
			SELECT Id
			FROM Group
			WHERE Name = :name
			AND Type = :QUEUE_TYPE
		];
		
		if (queues.isEmpty())
			return null;
		else
			return queues[0];
	}
}