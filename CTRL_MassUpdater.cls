public with sharing class CTRL_MassUpdater 
{
    private final ApexPages.StandardSetController cntr;
    private final PageReference fromPage;
    private final List<SObject> objs;
    private Map<String, Schema.SObjectField> fieldMap;
    private transient ApexPages.Message currentMsg;
    private final String newLine ='<br/>';
    private Schema.SObjectField field;
    private String sType;
    private Object convertedFieldData;
    private List<SelectOption> picklistValues;
    private String currentStep;

    private static final String STEP_ONE = '1';  
    private static final String STEP_TWO = '2';
    private static final String STEP_THREE = '3';
    private static final String STEP_FOUR = '4';
    private static final String STEP_FIVE = '5';

    private static final String NOTHING_SELECTED = 'No record was selected on the list view. Please click Previous button and select records for mass update.';
    private static final String NUMBER_SELECTED = 'Number of records selected for update: ';
   
    public CTRL_MassUpdater(ApexPages.StandardSetController controller) 
    {
        currentStep = STEP_ONE;
        controller.setPageSize(1000);
        cntr = (ApexPages.StandardSetController)controller;
        fromPage = cntr.cancel();
        String msg;

        if (this.objs == null) 
            this.objs = (List<SObject>)cntr.getSelected();      

        if (getRecordSize()<1) 
        {
            msg = NOTHING_SELECTED; 
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
        } 
        else 
        {
            sType = discoverSObjectType(objs.get(0)).getName(); 
            msg = NUMBER_SELECTED + getRecordSize(); 
            currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
        }

        ApexPages.addMessage(currentMsg);       
    }      

    public String getStep() 
    {
        return currentStep;
    }
  
    public String getsType() 
    {
        return sType;
    }     
   
    public integer getRecordSize() 
    {
        if (objs!=null) 
            return objs.size();
        else 
            return 0;     
    }
    
    public String filterId 
    {
        get;
        set;    
    }     
   
    public String getNow(Boolean bShowTime) 
    {
        if (bShowTime)
            return UTIL_Date.fullDateTimeString(Datetime.now());
        else
            return UTIL_Date.fullDateString(Datetime.now());
    }
   
    public List<SObject> objsToUpdate 
    {
        get 
        {
            return (List<SObject>) cntr.getSelected();
        }
        
        set;
    }
  
    public String valueToUpdate 
    {
        get;
        set;    
    }
    
    public String fieldName 
    {
        get;
        set 
        {
            fieldName=value;
            field = fieldMap.get(value);
            fieldType = field.getDescribe().getType().name();
        }   
    }
    
    public String fieldType
    {
        get;
        set;    
    }
    
    private Object convertUserInputToFieldData()
    {
        if (field == null) 
            return null;

        DisplayType type = field.getDescribe().getType();
        Object fieldData = null;
        
        try 
        {       
            if (type == DisplayType.Double || type == DisplayType.Currency || type == DisplayType.Integer || type == DisplayType.Percent)            
                fieldData = decimal.valueOf((String)valueToupdate);              
            else if (type == DisplayType.Boolean)
            {                 
                if (valueToUpdate == String.valueOf(true))                
                    fieldData = true;                    
                else if (valueToUpdate == String.valueOf(false))                
                    fieldData = false;                   
                else                 
                    fieldData = Boolean.valueOf(valueToUpdate);                
            } 
            else if (type == DisplayType.Date)             
                fieldData = Date.valueOf(valueToUpdate);             
            else if (type == DisplayType.DateTime)             
                fieldData = DateTime.valueOf(valueToUpdate);             
            else if (type == DisplayType.PickList && valueToUpdate == null)             
                fieldData = '';            
            else             
                fieldData = valueToupdate;            
        } 
        catch (System.TypeException e)
        {
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
            return null;
        }  
        
        return fieldData;
    }
    
    
    public String getFieldInfoToDisplay() 
    {
        if (field==null) 
            return '';

        String msg = 'Field type of selected field: ' + fieldType + newline;
        
        Schema.DescribeFieldResult describe = field.getDescribe();
        
        if (describe.getType() == DisplayType.TextArea || describe.getType() == (DisplayType.String) || describe.getType() == (DisplayType.URL)) 
        {
            msg += 'Max lengh: ' + describe.getLength();
            valueToUpdate = '';
        } 
        else if (describe.getType() == DisplayType.DateTime )
        {
            msg += 'Format: yyyy-MM-dd HH:mm:ss';
            valueToUpdate = getNow(true);
        } 
        else if (describe.getType() == DisplayType.Date)
        {
            msg += 'Format: yyyy-MM-dd';
            valueToUpdate = getNow(false);
        } 
        else if (describe.getType() == DisplayType.Picklist)
        {            
            picklistValues = new List<SelectOption>(); 

            if (describe.isNillable()) 
                picklistValues.add(new SelectOption('', '--None--'));
            
            for (Schema.PicklistEntry p : describe.getPickListValues()) 
                picklistValues.add(new SelectOption(p.getValue(), p.getLabel()));
            
            msg += newline + 'Please select a picklist value';
        } 
        else if (describe.getType() == DisplayType.MultiPicklist)
        {
            
            msg += 'Valid Picklist Values: ';
            String combined = '';
            
            for (Schema.PicklistEntry p : describe.getPickListValues()) 
            {
                msg += newLine + '&nbsp;&nbsp;&nbsp;&nbsp;<b>' + p.getValue() + '</b>';
                combined += p.getValue() + ';';
            }

            msg += newline + 'Use ; to seperate each picklist value you want to select';
            msg += newline + 'For example, to select all the picklist values, enter <b>' + combined + '</b> in the textbox below to select all picklist values';
        } 
        else if (describe.getType() == DisplayType.Integer)        
            msg += 'Max digits: ' + describe.getDigits();        
        else if (describe.getType() == DisplayType.String)        
            msg += 'Max length: ' + describe.getLength();         
        else if (describe.getType() == DisplayType.Double || describe.getType() == DisplayType.Currency || describe.getType() == DisplayType.Percent)        
            msg += 'Format: (' + (describe.getPrecision() - describe.getScale()) + ',' + describe.getScale() + ')';         
        else if (describe.getType() == DisplayType.Reference)
        {
            msg += 'Use this to change selected records to reference a different record, or even dereference records if the filed is left blank' + newLine;
            msg += 'Please enter ' + describe.getName() + ' that the selected records should reference to';
        }
        
        return msg;
    }
    
       
    public PageReference cancel() 
    {
        return fromPage;
    }

    public PageReference step1() 
    { 
        currentStep = STEP_ONE;          
        return ApexPages.currentPage();
    }
    
    public PageReference step2() 
    {
        if(getRecordSize()<1) 
            return fromPage;     

        currentStep = STEP_TWO;   
        return ApexPages.currentPage();
    }
    
    public PageReference step3() 
    {
        currentMsg = new ApexPages.Message(ApexPages.severity.INFO, getFieldInfoToDisplay());
        ApexPages.addMessage(currentMsg);
        currentStep = STEP_THREE;          
        return ApexPages.currentPage();
    } 
  
    public PageReference step4() 
    {
        convertedFieldData = convertUserInputToFieldData();
        
        // data type validation
        if (currentMsg!=null) 
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.INFO, getFieldInfoToDisplay());
            ApexPages.addMessage(msg);
            ApexPages.addMessage(currentMsg);
            return ApexPages.currentPage();
        }
        
        String msg = 'Please review your selections before confirm: <br></br>'; 
        msg = msg + '<br><b>Records Selected:</b>    ' + getRecordSize() +'</br>';
        msg = msg + '<br><b>Field To Be Updated:</b> ' + fieldName + '</br>';
        msg = msg + '<br><b>New Value:</b>           ' + convertedFieldData + '</br>';

        currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
        ApexPages.addMessage(currentMsg);
        currentStep = STEP_FOUR;  

        return ApexPages.currentPage();
    } 
      
    public PageReference step5() 
    {        
        currentMsg = UTIL_MassUpdater.massUpdate(objs, field, convertedFieldData);
        ApexPages.addMessage(currentMsg);
        currentStep = STEP_FIVE;          
        return ApexPages.currentPage();
    }
   
    public DescribeSObjectResult discoverSObjectType(SObject xObject) 
    {
        Map<String, Schema.SObjectType> description = Schema.getGlobalDescribe();
        
        for(Schema.SObjectType obj : description.values()) 
            if(xObject.getSObjectType() == obj) 
                return obj.getDescribe();                 
        
        return null;
    }
   
    public List<SelectOption> getFieldTypeOptions() 
    {
        // prevent url hacking
        if (objs.size()<1) 
            return null;
        
        List<SelectOption> options = new List<SelectOption>();      
        options.add(new SelectOption('','-None-'));
                
        Schema.DescribeSObjectResult sObj = discoverSObjectType(objs.get(0));        
        fieldMap = sObj.fields.getMap();        
        List<String> keys = sortByFieldLabel(fieldMap);
        
        for(String key:keys) 
        {
            Schema.DescribeFieldResult d = fieldMap.get(key).getDescribe();

            if(d.isAccessible() && d.isUpdateable() && isSupportedFieldType(d))             
            {
                String label = d.getLabel();

                if(d.isCustom()) label += ' (' + key +  ')';
                    options.add(new SelectOption(key, label));
            }            
        }

        return options;
    }
   
    private List<String> sortByFieldLabel(Map<String, Schema.SObjectField> schemaMap) 
    {
        List<String> keys = new List<String>();        
        Map<String, List<String>> labelMap = new Map<String, List<String>>();
        
        for(Schema.SObjectField objField : schemaMap.values()) 
        {
            String label = objField.getDescribe().getLabel();

            if(labelMap.get(label) == null) 
                labelMap.put(label, new List<String>());            
            
            labelMap.get(label).add(objField.getDescribe().getName());        
        }
        
        List<String> labels = new List<String>(labelMap.keySet());
        labels.sort();
        
        for(String label : labels)
            keys.addAll(labelMap.get(label));        
        
        return keys;
    }
    
    public List<SelectOption> getPicklistValues() 
    {
        return picklistValues;
    }
    
    private boolean isSupportedFieldType(DescribeFieldResult d) 
    {
        // always return true for now, but in future some fields might not be supported
        return true;
    }

    @TestVisible
    public PageReference testNegativeStep4()
    {
        currentMsg = null;
        return step4();
    }
}