@isTest(seeAllData=false)
private class TEST_CTRL_OpportunityStage 
{
	private static final String COUNTRY = 'Austria';
	private static final String PERIOD = 'Jun';

    static testMethod void getExistingObjectPickValues() 
    {
		//This controller will test the behaviour of the controller retrieving pick values
		//for a user (i.e. based on what they can see for a recordtype)
		//on an existing object's pick field
		User user = DAL_User.getRandomActiveUser();

		PageReference opportunityStagePage = Page.VFP_OpportunityStage;
		Test.setCurrentPage(opportunityStagePage);

		Account account = DAL_Account.newItem();

		Opportunity opp = DAL_Opportunity.newItem(account.Id, DAL_Opportunity.STAGE_PROSPECTING);

		DAL_BaseObject.InsertDBObject(opp);

	    ApexPages.StandardController sc = new ApexPages.standardController(opp);

	    System.runAs(user)
	    {
		    Test.startTest();

		    CTRL_OpportunityStage controller = new CTRL_OpportunityStage(sc);

		    Test.stopTest();		

		    //Due to getContent() method not being available for unit tests, we cannot test the below functionality. Controller will return
		    //all stages for all record types, rather than just those relevant to the specific record type
		    //System.assertEquals('[\'Open\', \'Engaging Client\', \'Preparing Filing\', \'Filed\', \'Cancelled\']', controller.oppStageList);
		    //System.assertEquals('[\'1\', \'2\', \'3\', \'4\', \'5\']', controller.oppStageNum);

		    System.assertNotEquals(null, controller.oppStageList);
		    System.assertNotEquals(null, controller.oppStageNum);
		}
	}
}