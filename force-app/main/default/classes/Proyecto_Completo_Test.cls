@isTest
private class Proyecto_Completo_Test {
	
    static testMethod void ProyectoCompletoTest() {

        Proyecto__c proyecto = new Proyecto__c(Name='Proyecto Testing');
        insert proyecto;
        
        Account acc = new Account(Name='test2010');
        insert acc;
        
        Contact con1 = new Contact(
            FirstName='Primario',
            LastName='Contacto1',
            Title='Primary',
            Email='contacto@primario.com',
            AccountId = acc.Id
        );
        Contact con2 = new Contact(
            FirstName='Secundario',
            LastName='Contacto2',
            Title='Secondary',
            Email='contacto@secundario.com',
            AccountId = acc.Id
        );
        insert con1;
        insert con2;
        
        Asignaci_n__c asig1 = new Asignaci_n__c(
        	Proyecto__c = proyecto.Id,
        	Voluntario__c = con1.Id,
        	Estado__c = 'Activo'
        );
        insert asig1;
        
        proyecto.Estado__c = 'Completo';
        proyecto.Fecha_de_finalizaci_n__c = Date.today();
        
        update proyecto;
        
        Asignaci_n__c asigActualizada = [select id, Estado__c, Fecha_de_baja__c  from Asignaci_n__c where Proyecto__c = :proyecto.Id];
        
        system.assertEquals(asigActualizada.Estado__c, 'Completo');
		system.assertEquals(asigActualizada.Fecha_de_baja__c, proyecto.Fecha_de_finalizaci_n__c);
    }
}