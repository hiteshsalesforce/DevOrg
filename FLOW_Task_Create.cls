public class FLOW_Task_Create 
{
	@InvocableMethod(label='Create Tasks' 
					description='This method can be called to create a list of Tasks'
					)
	public static void createTasks(List<DAL_Task.TaskDefinition> taskDefinitions)
	{		
		DAL_BaseObject.insertDBObjects(DAL_Task.newItems(taskDefinitions));
	}	
}