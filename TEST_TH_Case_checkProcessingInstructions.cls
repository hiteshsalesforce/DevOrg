/*
** This is the test class that tests the functionality for 
   checkProcessingInstuctions() method present in TH_Case on update
*/
   @isTest(seeAllData = false) 
   private class TEST_TH_Case_checkProcessingInstructions
   {
    private static final String CASE_REASON_SALES = 'Sales Agent - No Contact';
    private static final String ACCOUNT_DESCRIPTION = 'Account updated by Processing Instruction';
    private static final String ACCOUNT_SITE = 'London, England';

    //Processing instructions using the square bracket notation
    private static final String TEST_PROCESSING_INSTRUCTION = 
    '       [' + 
    '           "AccountId":' + //The account object associated with Case that should be updated
    '           [' +  
    '               "Description" : "' + ACCOUNT_DESCRIPTION +  '"' +
    '           ],' + 
    '           "Id":' +  //after this case is closed the processing instruction should set the reason.
    '           [' +  
    '               "Reason" : "' + CASE_REASON_SALES + '"' +  
    '           ]' +  
    '       ]'; 

    static testMethod void closeCaseWithUpdateOperation()
    {         
        Account newAccount = DAL_Account.insertItem();
        
        Case newCase1 = DAL_Case.insertItem(newAccount, DAL_Case.RT_DEFAULT, DAL_Case.CASE_STATUS_NEW);
        Case newCase2 = DAL_Case.insertItem(newAccount, DAL_Case.RT_DEFAULT, DAL_Case.CASE_STATUS_NEW);
        
        List<Case> cases = new List<Case>{newCase1, newCase2};
        


        newCase1.Status = DAL_Case.CASE_STATUS_CLOSED;
        newCase1.Processing_Instructions__c = TEST_PROCESSING_INSTRUCTION;
        
        //Check that trigger handler doesn't fail because of no processing instruction
        newCase2.Status = DAL_Case.CASE_STATUS_CLOSED;
        
        Test.startTest();   
        
        DAL_BaseObject.UpdateDBObjects(cases);
        
        Test.StopTest();
        
        newAccount = DAL_Account.findById(newAccount);
        System.assertEquals(ACCOUNT_DESCRIPTION, newAccount.Description, 'Account Description not correctly set.');
        
        newCase1 = DAL_Case.findById(newCase1);
        System.assertEquals(CASE_REASON_SALES, newCase1.Reason, 'Case Reason not correctly set.');
    }
        
    static testMethod void closeCaseWithBadProcessingInstruction()
    {         
        Account newAccount = DAL_Account.insertItem();
        
        Case newCase = DAL_Case.newItem(newAccount, DAL_Case.RT_DEFAULT, DAL_Case.CASE_STATUS_CLOSED);
        newCase.Processing_Instructions__c = DAL_BaseObject.generateRandomDescription();

        try
        {
            Test.startTest();   
            
            DAL_BaseObject.insertDBObject(newCase);
            
            Test.stopTest();
        }
        catch (Exception e)
        {
            System.assert(false, 'Exception was thrown when parsing bad Processing Instructions.'); 
        }
    }
    
    
}