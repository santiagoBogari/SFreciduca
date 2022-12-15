@isTest
public with sharing class MultiSelectFlowValuesTest 
{
    @isTest
    public static void testCheckValuesNormal()
    {
        List<List<String>> result = MultiSelectFlowValues.CheckValues(new List<String> {'a;b'});
        
        System.assertEquals(result[0][0],'a');
        System.assertEquals(result[0][1],'b');
    }
    
    @isTest
    public static void testCheckValuesEmpty()
    {
        List<List<String>> result = MultiSelectFlowValues.CheckValues(new List<String>{});
        
        System.assertEquals(result,null);
    }
}