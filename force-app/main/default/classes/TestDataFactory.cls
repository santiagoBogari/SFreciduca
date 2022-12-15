@isTest
public class TestDataFactory 
{
    
    public static Programa__c createPrograma(String name)
    {
    	id cfc = Schema.SObjectType.Programa__c.getRecordTypeInfosByName().get('CFC').getRecordTypeId();

		Programa__c programa = new Programa__c(RecordTypeId=cfc, Name=name);
       
		insert programa;
        
        return programa;
    }
    
    public static Pertenencia_a_Programas__c createPertenencia(id idAlumno, id idPrograma)
    {
        Pertenencia_a_Programas__c pertenencia = new Pertenencia_a_Programas__c(Alumno__c=idAlumno,Programa__c=idPrograma, Estado__c='Activo');

		insert pertenencia;
        
        return pertenencia;
    }
    
    public static Seguimiento_Educativo__c createSeguimiento(id idAlumno, id idPrograma)
    {
    	Seguimiento_Educativo__c segEduc = new Seguimiento_Educativo__c(
            Alumno__c=idAlumno,
            Estado__c='Cursando 5° Año',
            Nro_de_Informe__c = '4',
            Programa__c=idPrograma,
            Cu_ntas__c=2,
            Fecha_de_Informe__c=Date.newInstance(2021, 2, 17),
            Cantidad_de_Materias_Previas__c=2
            );

		insert segEduc;
        
        return segEduc;
	}
    
}