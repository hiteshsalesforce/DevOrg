/*
** This is the class which contains all the DML and SOQL statements related to Tasks 
** It impements various common functions which can be reused
*/
public class DAL_Task
{
	public static final String STATUS_COMPLETED = 'Completed';
	public static final Integer ONE_MONTH_DAYS = 30;
	public static final Integer WEEK_DAYS = 5;
	public static final Integer FULL_WEEK_DAYS = 7;
	public static final Integer REMINDER_TIME = 9;
	public static final String NORMAL_PRIORITY = 'Normal';
	
	public class TaskDefinition
	{
		@InvocableVariable(label='Related To' description='The nonhuman object to which this task is related.' required=true)
    	public ID whatId;
		
		@InvocableVariable(label='Subject' description='Please enter the Subject of the Task' required=true)
    	public String subject;
    	
		@InvocableVariable(label='Related Person' description='The Contact or Lead related to this Task' required=false)
		public ID whoId;
		
		@InvocableVariable(label='Type' description='The type of Task, such as Call or Meeting.' required=false)
		public String type;
		
		@InvocableVariable(label='Subject Prefix' description='The prefix for the Task subject' required=false)
		public String subjectPrefix;
			
		@InvocableVariable(label='Owner' description='The Owner of the Task' required=false)
		public ID ownerID;
		
		@InvocableVariable(label='Description' description='The description of the Task.' required=false)
		public String description;
		
		@InvocableVariable(label='Due Date' description='The due date of the Task.' required=false)
		public Date dueDate;
		
		@InvocableVariable(label='Due Date Days' description='The number of days from Today when this Task is due.' required=false)
		public Integer dueDateDays;	
		
		@InvocableVariable(label='Reminder Days' description='The number of days before the Task is due when a reminder should be fired. ' required=false)
		public Integer reminderDays;
		
		@InvocableVariable(label='Due Days Before' description='The number of days before the Due Date (calculated) when this Task is due.' required=false)
		public Integer dueDaysBefore;
		
		@InvocableVariable(label='Due First Working Day' description='Set the Task to be due on the first working day of the Due Date (calculated) month.' required=false)
		public Boolean dueFirstWorkingDay;
		
		@InvocableVariable(label='Priority' description='Indicates the importance or urgency of a Task.' required=true)
		public String priority = NORMAL_PRIORITY;
		
		@InvocableVariable(label='Processing Instructions' description='A Processing Instruction that will update related fields when the case is closed' required=false)
		public String processingInstructions;
	}
	
	public static TaskDefinition newTaskDefinition(ID whatId)
	{
		TaskDefinition newDefinition = new TaskDefinition();
		
		newDefinition.whatId = whatId;
		newDefinition.subject = DAL_BaseObject.generateRandomName();
		newDefinition.type = DAL_BaseObject.generateRandomName();
		newDefinition.subjectPrefix = DAL_BaseObject.generateRandomName();		
		newDefinition.description = DAL_BaseObject.generateRandomName();	
		newDefinition.dueDateDays = ONE_MONTH_DAYS;	//This will add 30 days to today's date
		newDefinition.reminderDays = FULL_WEEK_DAYS; //This will set a reminder 7 days before due date
		newDefinition.dueDaysBefore = WEEK_DAYS; //This will set the due date 5 days before today + 30 days (i.e.)
		newDefinition.dueDate = Date.Today().addDays(ONE_MONTH_DAYS + FULL_WEEK_DAYS);
		newDefinition.processingInstructions = DAL_BaseObject.generateRandomName();	
        
		return newDefinition;
	}
	
	public static Task newItem(TaskDefinition definition)
	{
		Task newTask = newItem(definition.whatId);

		newTask.WhoId = definition.whoId;
		newTask.Subject = String.isBlank(definition.subjectPrefix) ? definition.subject : String.format(DAL_BaseObject.SUBJECT_FMT, new String[]{definition.subjectPrefix, definition.subject});
		newTask.Type = definition.type;
		newTask.Description = definition.description;
		
		newTask.OwnerId = definition.ownerId == null ? UserInfo.getUserId() : definition.ownerId;
		newTask.Priority = definition.priority;
		newTask.Processing_Instructions__c = definition.processingInstructions;
		
		Integer dueDateDays = definition.dueDateDays == null ? 0 : definition.dueDateDays;
		Integer dueDaysBefore = definition.dueDaysBefore == null ? 0 : -1*definition.dueDaysBefore;
		
		//Calculate the activity due date based on dueDateDays
		if (definition.dueDateDays > 0)
		{
			newTask.ActivityDate = Date.Today().addDays(dueDateDays);
			
			if (definition.dueDate != null && definition.dueDate < newTask.ActivityDate)
				newTask.ActivityDate = definition.dueDate;
		}
		else if (definition.dueDate != null)
			newTask.ActivityDate = definition.dueDate;
			
		//if we have an task due date then shift it based on dueDatesBefore
		if (newTask.ActivityDate != null)
		{
			//If this task should be due on the first working day of the current ActivityDate (dueDate) then shift the ActivityDate to the first working day
			if (definition.dueFirstWorkingDay == true)
				newTask.ActivityDate = UTIL_Date.firstWeekDay(newTask.ActivityDate.toStartOfMonth());
			else
				//Make sure the Activity Date is on a weekday using dueDaysBefore (assuming it's set)
				newTask.ActivityDate = UTIL_Date.lastWeekDay(newTask.ActivityDate.addDays(dueDaysBefore));

			//Set the reminder only if we have a due date
			if(definition.reminderDays > 0)
			{
				newTask.IsReminderSet = true;
				Time reminderTime = Time.newInstance(REMINDER_TIME, 0, 0, 0);
				newTask.ReminderDateTime = Datetime.newInstance(newTask.ActivityDate, reminderTime).addDays(-1*definition.reminderDays);
				
				//Make sure the reminder date is on weekday
				newTask.ReminderDateTime = Datetime.newInstance(UTIL_Date.lastWeekDay(newTask.ReminderDateTime.date()), newTask.ReminderDateTime.time());
			}	
		}
		
		return newTask;
	}
	
	public static List<Task> newItems(List<TaskDefinition> definitions)
	{
		List<Task> newTasks = new List<Task>();
		
		for (TaskDefinition definition : definitions)
			newTasks.add(newItem(definition));
			
		return newTasks;
	}	

	public static Task newItem(ID whatId)
	{
		Task newTask = new Task();
		
		newTask.Type = DAL_BaseObject.generateRandomEmail();
		newTask.Description = DAL_BaseObject.generateRandomName();
		newTask.Priority = NORMAL_PRIORITY;
		newTask.Subject = DAL_BaseObject.generateRandomName();
		newTask.WhatId = whatId;
		
		return newTask;
	}
	
	public static Task InsertItem(ID whatId)
	{
		Task newTask = newItem(whatId);
		DAL_BaseObject.insertDBObject(newTask);
		return newTask;
	}
	
	public static List<Task> findByWhatId(ID whatID)
	{
		return
		[
			SELECT 
			  Id,
			  Subject,
			  ActivityDate,
			  ReminderDateTime
			FROM Task  
			WHERE WhatId = :whatID
		];
	}	
}