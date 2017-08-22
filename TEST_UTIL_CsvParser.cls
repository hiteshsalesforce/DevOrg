@isTest(seeAllData = false)
private class TEST_UTIL_CsvParser {

    static testMethod void testParseLine() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String[] nextItem = parser.parseLine('This, is, a, test.');
        System.assertEquals(4, nextItem.size());
        System.assertEquals('This', nextItem[0]);
        System.assertEquals(' is', nextItem[1]);
        System.assertEquals(' a', nextItem[2]);
        System.assertEquals(' test.', nextItem[3]);
    }

    static testMethod void parseSimpleString() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String[] nextLine = parser.parseLine('a,b,c');
        System.assertEquals(3, nextLine.size());
        System.assertEquals('a', nextLine[0]);
        System.assertEquals('b', nextLine[1]);
        System.assertEquals('c', nextLine[2]);
        System.assertEquals(false, parser.isPending());
    }

    
    static testMethod void testParsedLineWithInternalQuota() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String[] nextLine = parser.parseLine('a,123\"4\"567,c');
        System.assertEquals(3, nextLine.size());
        System.assertEquals('123\"4\"567', nextLine[1]);
    }

    
    static testMethod void parseQuotedStringWithCommas() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String[] nextLine = parser.parseLine('a,\"b,b,b\",c');
        System.assertEquals('a', nextLine[0]);
        System.assertEquals('b,b,b', nextLine[1]);
        System.assertEquals('c', nextLine[2]);
        System.assertEquals(3, nextLine.size());
    }

    
    static testMethod void parseEmptyElements() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String[] nextLine = parser.parseLine(',,');
        System.assertEquals(3, nextLine.size());
        System.assertEquals('', nextLine[0]);
        System.assertEquals('', nextLine[1]);
        System.assertEquals('', nextLine[2]);
    }

    
    static testMethod void parseMultiLinedQuoted() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String[] nextLine = parser.parseLine('a,\"PO Box 123,\nKippax,ACT. 2615.\nAustralia\",d.\n');
        System.assertEquals(3, nextLine.size());
        System.assertEquals('a', nextLine[0]);
        System.assertEquals('PO Box 123,\nKippax,ACT. 2615.\nAustralia', nextLine[1]);
        System.assertEquals('d.\n', nextLine[2]);
    }

    
    static testMethod void testADoubleQuoteAsDataElement() {
        UTIL_CsvParser parser = new UTIL_CsvParser();

        // a,"""",c
        String[] nextLine = parser.parseLine('a,\"\"\"\",c');

        System.assertEquals(3, nextLine.size());

        System.assertEquals('a', nextLine[0]);
        System.assertEquals(1, nextLine[1].length());
        System.assertEquals('\"', nextLine[1]);
        System.assertEquals('c', nextLine[2]);
    }

    
    static testMethod void testEscapedDoubleQuoteAsDataElement() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        
        // "test","this,test,is,good","\"test\",\"quote\""
        String[] nextLine = parser.parseLine('\"test\",\"this,test,is,good\",\"\\\"test\\\"\",\"\\\"quote\\\"\"');

        System.assertEquals(4, nextLine.size());

        System.assertEquals('test', nextLine[0]);
        System.assertEquals('this,test,is,good', nextLine[1]);
        System.assertEquals('\"test\"', nextLine[2]);
        System.assertEquals('\"quote\"', nextLine[3]);
    }
    
    
    static testMethod void parseQuotedQuoteCharacters() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String[] nextLine = parser.parseLineMulti('\"Glen \"\"The Man\"\" Smith\",Athlete,Developer\n');
        System.assertEquals(3, nextLine.size());
        System.assertEquals('Glen \"The Man\" Smith', nextLine[0]);
        System.assertEquals('Athlete', nextLine[1]);
        System.assertEquals('Developer\n', nextLine[2]);
    }

    
    static testMethod void parseMultipleQuotes() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        // """""","test"  representing:  "", test
        String[] nextLine = parser.parseLine('\"\"\"\"\"\",\"test\"\n'); 
        System.assertEquals('\"\"',nextLine[0]); // check the tricky situation
        System.assertEquals('test\"\n', nextLine[1]); // make sure we didn't ruin the next field..
        System.assertEquals(2, nextLine.size());
    }

    
    static testMethod void parseTrickyString() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String[] nextLine = parser.parseLine('\"a\nb\",b,\"\nd\",e\n');
        System.assertEquals(4, nextLine.size());
        System.assertEquals('a\nb', nextLine[0]);
        System.assertEquals('b', nextLine[1]);
        System.assertEquals('\nd', nextLine[2]);
        System.assertEquals('e\n', nextLine[3]);
    }

    private static String setUpMultiLineInsideQuotes(){
        return 'Small test,\"This is a test across \ntwo lines.\"';
    }

    
    static testMethod void testAMultiLineInsideQuotes() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String testString = setUpMultiLineInsideQuotes();

        String[] nextLine = parser.parseLine(testString);
        System.assertEquals(2, nextLine.size());
        System.assertEquals('Small test', nextLine[0]);
        System.assertEquals('This is a test across \ntwo lines.', nextLine[1]);
        System.assertEquals(false, parser.isPending());
    }

    /**
     * Test issue 2726363
     *
     * Data given:
     *
     *  "804503689","London",""London""shop","address","116.453182","39.918884"
     *  "453074125","NewYork","brief","address"","121.514683","31.228511"
     */
    
    static testMethod void testIssue2726363() {    
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String[] nextLine = parser.parseLine(
                '\"804503689\",\"London\",\"\"London\"shop\",\"address\",\"116.453182\",\"39.918884\"');

        System.assertEquals(6, nextLine.size());

        System.assertEquals('804503689', nextLine[0]);
        System.assertEquals('London', nextLine[1]);
        System.assertEquals('\"London\"shop', nextLine[2]);
        System.assertEquals('address', nextLine[3]);
        System.assertEquals('116.453182', nextLine[4]);
        System.assertEquals('39.918884', nextLine[5]);
    }

    
    static testMethod void testExceptionThrownifStringEndsInsideAQuotedString() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        try {
            String[] nextLine = parser.parseLine('This,is a \"bad line to parse.');
            System.assert(false, 'Exception expected');
        } catch (UTIL_CsvParser.UTIL_CsvParserException e) {
            // expected
        }
    }

    
    static testMethod void parseLineMultiAllowsQuotesAcrossMultipleLines() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String[] nextLine = parser.parseLineMulti('This,\"is a \"good\" line\\\\ to parse');

        System.assertEquals(1, nextLine.size());
        System.assertEquals('This', nextLine[0]);
        System.assertEquals(true, parser.isPending());

        nextLine = parser.parseLineMulti('because we are using parseLineMulti.\"');

        System.assertEquals(1, nextLine.size());
        System.assertEquals('is a \"good\" line\\ to parse\nbecause we are using parseLineMulti.', nextLine[0]);
        System.assertEquals(false, parser.isPending());
    }

    
    static testMethod void pendingIsClearedAfterCallToParseLine() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String[] nextLine = parser.parseLineMulti('This,\"is a \"good\" line\\\\ to parse');

        System.assertEquals(1, nextLine.size());
        System.assertEquals('This', nextLine[0]);
        System.assertEquals(true, parser.isPending());

        nextLine = parser.parseLine('because we are using parseLineMulti.');

        System.assertEquals(1, nextLine.size());
        System.assertEquals('because we are using parseLineMulti.', nextLine[0]);
        System.assertEquals(false, parser.isPending());
    }

    
    static testMethod void returnPendingIfNullIsPassedIntoParseLineMulti() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String[] nextLine = parser.parseLineMulti('This,\"is a \"goo\\d\" line\\\\ to parse\\');

        System.assertEquals(1, nextLine.size());
        System.assertEquals('This', nextLine[0]);
        System.assertEquals(true, parser.isPending());

        nextLine = parser.parseLineMulti(null);

        System.assertEquals(1, nextLine.size());
        System.assertEquals('is a \"good\" line\\ to parse\n', nextLine[0]);
        System.assertEquals(false, parser.isPending());
    }

    
    static testMethod void returnNullWhenNullPassedIn() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        String[] nextLine = parser.parseLine(null);
        System.assertEquals(null, nextLine);
    }

    private static final String ESCAPE_TEST_STRING = '\\\\1\\2\\\"3\\'; // \\1\2\"\

    
    static testMethod void validateEscapeString() {
        System.assertEquals(9, ESCAPE_TEST_STRING.length());
    }

    
    static testMethod void whichCharactersAreEscapable() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        
        System.assertEquals(true, parser.isNextCharacterEscapable(ESCAPE_TEST_STRING, true, 0));
        System.assertEquals(false, parser.isNextCharacterEscapable(ESCAPE_TEST_STRING, false, 0));
        // Second character is not escapable because there is a non quote or non slash after it. 
        System.assertEquals(false, parser.isNextCharacterEscapable(ESCAPE_TEST_STRING, true, 1));
        System.assertEquals(false, parser.isNextCharacterEscapable(ESCAPE_TEST_STRING, false, 1));
        // Fourth character is not escapable because there is a non quote or non slash after it.
        System.assertEquals(false, parser.isNextCharacterEscapable(ESCAPE_TEST_STRING, true, 3));
        System.assertEquals(false, parser.isNextCharacterEscapable(ESCAPE_TEST_STRING, false, 3));

        System.assertEquals(true, parser.isNextCharacterEscapable(ESCAPE_TEST_STRING, true, 5));
        System.assertEquals(false, parser.isNextCharacterEscapable(ESCAPE_TEST_STRING, false, 5));

        Integer lastChar = ESCAPE_TEST_STRING.length() - 1;
        System.assertEquals(false, parser.isNextCharacterEscapable(ESCAPE_TEST_STRING, true, lastChar));
        System.assertEquals(false, parser.isNextCharacterEscapable(ESCAPE_TEST_STRING, false, lastChar));
    }
    
    
    static testMethod void whitespaceBeforeEscape() {
        UTIL_CsvParser parser = new UTIL_CsvParser();
        //"this", "is","a test"
        String[] nextItem = parser.parseLine('\"this\", \"is\",\"a test\"');
        System.assertEquals('this', nextItem[0]);
        System.assertEquals('is', nextItem[1]);
        System.assertEquals('a test', nextItem[2]);
    }
}