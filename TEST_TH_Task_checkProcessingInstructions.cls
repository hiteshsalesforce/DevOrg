@isTest(seeAllData = false) 
private class TEST_TH_Task_checkProcessingInstructions 
{   
    private static final String ACCOUNT_DESCRIPTION = 'Account updated by Processing Instruction';
    private static final String VALUE_TRUE = 'true';
    
    private static final String TEST_PROCESSING_INSTRUCTION = 
    '       [' + 
    '           "WhatId":' +  //after this task is closed the processing instruction should account the description.
    '           [' +  
    '               "Description" : "' + ACCOUNT_DESCRIPTION + '"' +  
    '           ]' +  
    '       ]'; 
    
    private static final String TEST_INCORRECT_PROCESSING_INSTRUCTION = 
    '       {' + 
    '           "true":' +  //after this task is closed the processing instruction should account the description.
    '           {' +  
    '               "Description" : "' + VALUE_TRUE + '"' +  
    '           }' +  
    '       }';
    
    private static final String TEST_INVALID_PROCESSING_INSTRUCTION = 
    '       {' + 
    '           "Stage":' +  //after this task is closed the processing instruction should account the description.
    '           {' +  
    '               "Description" : "' + ACCOUNT_DESCRIPTION + '"' +  
    '           }' +  
    '       }';
    
    static testMethod void closeTaskWithUpdateOperation()
    {
        List<Task> newTaskList = new List<Task>();
        Account newAccount = DAL_Account.insertItem();
        
        Task newTask = DAL_Task.insertItem(newAccount.Id);
        
        newTask.Processing_Instructions__c = TEST_PROCESSING_INSTRUCTION;       
        newTask.Status = DAL_Task.STATUS_COMPLETED;
        
        Task secondNewTask = DAL_Task.insertItem(newAccount.Id);
        
        secondNewTask.Processing_Instructions__c = TEST_INCORRECT_PROCESSING_INSTRUCTION;       
        secondNewTask.Status = DAL_Task.STATUS_COMPLETED;
        
        Task thirdNewTask = DAL_Task.insertItem(newAccount.Id);
        thirdNewTask.Processing_Instructions__c = TEST_INVALID_PROCESSING_INSTRUCTION;       
        
        
        newtaskList.add(secondNewTask);
        newtaskList.add(newTask);
        newtaskList.add(thirdNewTask);
        
        Test.startTest();
        
        DAL_BaseObject.updateDBObjects(newtaskList, false);
        
        Test.stopTest();  
        
        //To ensure we get coverage on delete and undelete trigger methods in base classes we are going
        //just delete and undelete test data
        
        DAL_BaseObject.deleteDBObject(newTask);
        Database.undelete(newTask);
                
        newAccount = DAL_Account.findById(newAccount);
        System.assertEquals(ACCOUNT_DESCRIPTION, newAccount.Description, 'Account Description not correctly set.');   
        
    }
    
    static testMethod void checkExceptionCondition_closeTaskWithUpdateOperation()
    {
        
        Account newAccount = DAL_Account.insertItem();           
        
        Task secondNewTask = DAL_Task.insertItem(newAccount.Id);
        
        secondNewTask.Processing_Instructions__c = TEST_INCORRECT_PROCESSING_INSTRUCTION;       
        secondNewTask.Status = DAL_Task.STATUS_COMPLETED;
        
        //To ensure we get coverage on exception statements in base classes we are going to
        //first remove a required field and try to update test data
        //then delete and delete again test data
        //to throw error
        
        secondNewTask.Priority = null;
        
        Test.startTest();        
            
            try{        
                DAL_BaseObject.updateDBObject(secondNewTask);    // This is for the update exception
                
                DAL_BaseObject.deleteDBObject(secondNewTask); 
                
                DAL_BaseObject.deleteDBObject(secondNewTask);    // This is for the Delete Exception
                
            }
            catch(exception ex){}
            
        Test.stopTest();
    }
}