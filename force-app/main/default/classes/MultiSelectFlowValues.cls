global class MultiSelectFlowValues {

	@InvocableMethod
    //los InvocableMethods deben recibir parámetros tipo lista
   	public static List<List<String>> CheckValues(List<String> values) {

		if(!(values.isEmpty())) {
    		String valuesStr = values[0];								//toma el primer string de la lista
        	List<String> newList = valuesStr.split(';');				//crea una lista a partir del string
        	List<List<String>> finalList = new List<List<String>>();	//crea la lista a retornar, una lista de listas
        	finalList.add(newList);
        	return finalList;
		}
    	else return null;
   	}
}