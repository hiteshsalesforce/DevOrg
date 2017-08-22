/*
* @description Unit test method(s) to ensure the Apex Process Builder invocationmethod works as expected
*/
@isTest(seeAllData = false) 
private class TEST_FLOW_Task_Create 
{
	
	
    static testMethod void createTaskAllDateFields() 
    {
		Account newAccount = DAL_Account.insertItem();
		
		DAL_Task.TaskDefinition definition = DAL_Task.newTaskDefinition(newAccount.Id);

		Test.startTest();  
		
		FLOW_Task_Create.createTasks(new List<DAL_Task.TaskDefinition>{definition});
		
		Test.StopTest(); 
		
		List<Task> tasks = DAL_Task.findByWhatId(newAccount.Id);
		
		System.assert(!tasks.isEmpty(), 'No Tasks were Created.');
		
		Task newTask = tasks[0];
		String subject = String.format(DAL_BaseObject.SUBJECT_FMT, new String[]{definition.subjectPrefix, definition.subject});
		System.assertEquals(subject, newTask.Subject, 'The Task subject was not set correctly.');
		
		//Check that the due date, and reminder date where set correctly
		Integer dueDateDays = definition.dueDateDays == null ? 0 : definition.dueDateDays;
		Integer dueDaysBefore = definition.dueDaysBefore == null ? 0 : -1*definition.dueDaysBefore;
		Date dueDate = null;
		DateTime reminderDateTime = null;
		
		if (definition.dueDateDays > 0)
		{
			dueDate = Date.Today().addDays(dueDateDays);
			
			if (definition.dueDate != null && definition.dueDate < dueDate)
				dueDate = definition.dueDate;
		}
		else if (definition.dueDate != null)
			dueDate = definition.dueDate;	

		//if we have an task due date then shift it based on dueDatesBefoe
		if (dueDate != null)
		{
			dueDate = UTIL_Date.lastWeekDay(dueDate.addDays(dueDaysBefore));
	
			if(definition.reminderDays > 0)
			{
				reminderDateTime = Datetime.newInstance(dueDate, Time.newInstance(DAL_Task.REMINDER_TIME, 0, 0, 0)).addDays(-1*definition.reminderDays);
				//Make sure the reminder date is on weekday
				reminderDateTime = Datetime.newInstance(UTIL_Date.lastWeekDay(reminderDateTime.date()), reminderDateTime.time());
			}
		}
		
		System.assertEquals(dueDate, newTask.ActivityDate, 'The Task Due Date was not set correctly.');
		System.assertEquals(reminderDateTime, newTask.ReminderDateTime, 'The Task Reminder was not set correctly.');	
    }
}