/**
 * This class contains unit tests for validating the behavior of CTRL_MassUpdater
 * and triggers.
 */
@isTest(seeAllData=false)
private class TEST_CTRL_MassUpdater
{
    static testMethod void singleUpdateTest() 
    {
    	Account acc = DAL_Account.insertItem();
	    Opportunity opp = DAL_Opportunity.insertItem(acc.Id, DAL_Opportunity.STAGE_PROSPECTING);
	    List<Opportunity> oppList = [SELECT name FROM Opportunity LIMIT 20];
	      
	    ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
	    setCtr.setSelected(new Opportunity[]{ opp });

	    CTRL_MassUpdater controller = new CTRL_MassUpdater(setCtr);
	    System.assertEquals(1, controller.getRecordSize());
	    System.assertEquals(Opportunity.SObjectType.getDescribe().getLocalName(), controller.getsType());
	    System.assertEquals(null, controller.filterId);
	    
	    System.assert(controller.getFieldTypeOptions().size() > 1);	    
	    System.assertEquals(1, controller.objsToUpdate.size());
	    
	    String value = '123test';
	    controller.fieldName = 'name';
	    controller.valueToUpdate = value;   
	    controller.step4();
	    controller.step5();
	    
	    System.assert(opp.name == value);
	    System.assert(controller.getStep() == '5');
	    
	    value ='123';
	    controller.step3();
	    controller.fieldName = DAL_Opportunity.FIELD_AMOUNT;
	    controller.valueToUpdate = value;  
	    controller.step4();
	    controller.step5();
	      
	    System.assert(opp.amount == decimal.valueOf(value));
	    // make sure no exception from display tips
	    System.assert(controller.getFieldInfoToDisplay() != null);
	            
	    value = '2009-4-7';
	    controller.fieldName = DAL_Opportunity.FIELD_CLOSE_DATE;
	    controller.valueToUpdate = value;    
	    controller.step4();
	    controller.step5();
	    System.assert(opp.CloseDate == Date.valueOf(value));
	      
	    value = 'Closed';
	    controller.fieldName = DAL_Opportunity.FIELD_STAGENAME;
	    controller.valueToUpdate = value;    
	    controller.step4();
	    controller.step5();
	    System.assert(opp.StageName == 'Closed');

	    value = 'true';
	    controller.fieldName = 'IsPrivate';
	    controller.valueToUpdate = value;    
	    controller.step4();
	    controller.step5();
	    System.assert(opp.IsPrivate);

	    value = 'false';
	    controller.fieldName = 'IsPrivate';
	    controller.valueToUpdate = value;    
	    controller.step4();
	    controller.step5();
	    System.assertEquals(false, opp.IsPrivate);

	    Contract contr = new Contract(AccountId = acc.Id);
	    DAL_BaseObject.InsertDBObject(contr);
	    value = String.valueOf(contr.Id);
	    controller.fieldName = 'ContractId';
	    controller.valueToUpdate = value;    
	    controller.step4();
	    controller.step5();
	    System.assert(opp.ContractId == contr.Id);
    }
    
    static testMethod void linkTest() 
    {
	    Opportunity opp = new Opportunity();
	    List<Opportunity> oppList = [SELECT name FROM Opportunity LIMIT 20];
	      
	    ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
	    setCtr.setSelected(new Opportunity[]{ opp });
	    CTRL_MassUpdater controller = new CTRL_MassUpdater(setCtr);
	    
	    // verify following steps will not cause exception
	    System.assert(controller.step1() != null);
	    System.assert(controller.step2() != null);
	    System.assert(controller.step3() != null);
	    System.assert(controller.step4() != null);
	    System.assert(controller.step5() != null);
	    
	    System.assert(controller.getFieldTypeOptions() != null);
    }
    
    static testMethod void fieldTest() 
    {      
	    List<Opportunity> oppList = new Opportunity[]{};
	      
	    ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
	    CTRL_MassUpdater controller = new CTRL_MassUpdater(setCtr);
	    System.assert(controller.cancel() != null);
	    System.assert(controller.getFieldTypeOptions() == null);
    }
    
    static testMethod void miscTest() 
    {      
	    List<Opportunity> oppList = new Opportunity[]{};
	      
	    ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
	    CTRL_MassUpdater controller = new CTRL_MassUpdater(setCtr);
	    
	    System.assert(controller.getNow(true) != null);
	    System.assert(controller.getNow(false) != null);
	    System.assert(controller.getRecordSize() == 0);
	    System.assert(controller.getPicklistValues() == null);
    }

    static testMethod void negative()
    {
    	List<Opportunity> oppList = new Opportunity[]{};
	      
	    ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
	    CTRL_MassUpdater controller = new CTRL_MassUpdater(setCtr);

	    Test.startTest();

	    System.assert(controller.testNegativeStep4() != null);

	    Test.stopTest();
    } 
}