@isTest(SeeAllData=false)
private class TEST_UTIL_Email_sendEmail
{
    static testMethod void test_sendEmail()
    {
        List<String> toAddresses = new List<String> {DAL_BaseObject.generateRandomEmail()};
        String replyToAddress = DAL_BaseObject.generateRandomEmail();

        UTIL_Email email = new UTIL_Email(toAddresses);
        email.setSubject(DAL_BaseObject.generateRandomName());
        email.setPlainTextBody(DAL_BaseObject.generateRandomDescription());
        email.sendEmail();
    }
}