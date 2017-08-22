@isTest(SeeAllData = false) 
private class TEST_CTRL_PickListDescriber 
{

    static testMethod void getExistingObjectPickValues() 
    {
        //This controller will test the behaviour of the controller retrieving pick values
        //for a user (i.e. based on what they can see for a recordtype)
        //on an existing object's pick field
		User user = DAL_User.getRandomActiveUser();

		PageReference pickListDescriberPage = Page.VFP_PickListDescriber;
		Test.setCurrentPage(pickListDescriberPage);

		//Make sure we set the page's required parameters
		Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
		
		pageParameters.put(UTIL_PickList.PARAM_OBJECT_ID, User.Id);
		pageParameters.put(UTIL_PickList.PARAM_PICK_LIST_NAME, DAL_User.FIELD_EMAIL_ENCODING_KEY);
		pageParameters.put(UTIL_PickList.PARAM_OBJECT_TYPE, DAL_User.OBJECT_NAME);
	
		Test.startTest();
		
		//On contructing the controller, the controller will retrieve the relevant object for the page.
		CTRL_PickListDescriber controller = new CTRL_PickListDescriber();
		
		Test.stopTest();

		System.assert(controller.SObj != null);
    }
    
   	static testMethod void getNewObjectPickValues() 
    {
        //This controller will test the behaviour of the controller retrieving pick values
        //for a Account (i.e. based on what they can see for a recordtype)
		PageReference pickListDescriberPage = Page.VFP_PickListDescriber;
		Test.setCurrentPage(pickListDescriberPage);

		//Make sure we set the page's required parameters
		Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
		
		pageParameters.put(UTIL_PickList.PARAM_RECORD_TYPE, DAL_Case.RT_DEFAULT);
		pageParameters.put(UTIL_PickList.PARAM_PICK_LIST_NAME, DAL_Case.FIELD_STATUS);
		pageParameters.put(UTIL_PickList.PARAM_OBJECT_TYPE, DAL_Case.OBJECT_NAME);
	
		Test.startTest();
		
		//On contructing the controller, the controller will retrieve the relevant object for the page.
		CTRL_PickListDescriber controller = new CTRL_PickListDescriber();
		
		Test.stopTest();

		System.assert(controller.SObj != null);
    }
}