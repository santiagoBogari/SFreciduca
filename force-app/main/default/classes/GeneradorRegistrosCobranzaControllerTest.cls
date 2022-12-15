@isTest
private class GeneradorRegistrosCobranzaControllerTest {

    static testMethod void testBatch() {
        Account acc = new Account(Name='test2011');
        insert acc;
    
        List<Contact> donantesTests = new List<Contact>();
        List<Compromiso__c> compromisosTests = new List<Compromiso__c>();
        for(integer i=0;i<10;i++){
            Contact persona = new Contact(
                FirstName='Nombre'+i,
                LastName='Apellido'+i,
                Title='Titulo',
                Email='contacto'+i+'@test.com',
                AccountId = acc.Id);
            insert persona;
            date hoy = Date.today();
        
            Compromiso__c compromiso = new Compromiso__c(
                Donante__c=persona.Id,
                Estado__c='Activo',
                Frecuencia__c='Mensual',
                Monto_en_pesos__c=100,
        Monto_de_ajuste__c=0,
                Fecha_de_compromiso__c=hoy,
                Fecha_para_realizar_primer_cobranza__c=hoy.addDays(5));
            
            compromisosTests.add(compromiso);
            
            Compromiso__c compromisoUnico = new Compromiso__c(
                Donante__c=persona.Id,
                Estado__c='Activo',
                Frecuencia__c='Única vez',
                Monto_en_pesos__c=500,
        Monto_de_ajuste__c=0,
                Fecha_de_compromiso__c=hoy,
                Fecha_para_realizar_primer_cobranza__c=hoy.addDays(1));
            
            compromisosTests.add(compromisoUnico);
        }
        insert compromisosTests;
        
        Test.StartTest();
        GeneradorRegistrosCobranzaController generador= new GeneradorRegistrosCobranzaController();
        generador.query = 'Select c.id, c.Mes_adelantado__c, c.Monto_en_pesos__c, c.Monto_de_ajuste__c, c.Moneda__c, c.Donante__c, c.Fecha_de_pr_xima_cobranza__c, c.Fecha_Ultima_Cobranza__c, c.Fecha_para_realizar_primer_cobranza__c, c.Frecuencia__c from Compromiso__c c where c.Estado__c in (\'Primer cobranza pendiente\',\'Activo\') and ((c.Mes_adelantado__c = false and (c.Fecha_para_realizar_primer_cobranza__c <= THIS_MONTH and c.Fecha_para_realizar_primer_cobranza__c <= THIS_YEAR) and (c.Fecha_de_pr_xima_cobranza__c = null or (c.Fecha_de_pr_xima_cobranza__c = THIS_MONTH and c.Fecha_de_pr_xima_cobranza__c = THIS_YEAR))) or (c.Mes_adelantado__c = true and (c.Fecha_para_realizar_primer_cobranza__c <= NEXT_MONTH and c.Fecha_para_realizar_primer_cobranza__c <= THIS_YEAR) and (c.Fecha_de_pr_xima_cobranza__c = null or (c.Fecha_de_pr_xima_cobranza__c = NEXT_MONTH and c.Fecha_de_pr_xima_cobranza__c = THIS_YEAR)))) LIMIT 100';
        generador.runProcess();
        
        Estado_Ejecuciones_Reg_Cobranza__c procesoActivo = generador.getProcesoActivo();

        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :procesoActivo.Id_Job__c];
        System.debug('\n\nEl resultado del batch fue: '+a);

        System.AssertEquals('Queued', a.Status);
        Test.StopTest();
        
        AsyncApexJob b = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :procesoActivo.Id_Job__c];
        System.debug('\n\nEl resultado del batch fue: '+b);
        
        generador.cancelProcess();
        Estado_Ejecuciones_Reg_Cobranza__c ultimoProceso = generador.getUltimoProceso();
        
        System.debug('La pagina actual es la: ' +ApexPages.currentPage() );
        
        System.AssertEquals('Completed', b.Status);
        System.AssertEquals(0, a.NumberOfErrors);
        System.AssertEquals(ultimoProceso.Id_Job__c, procesoActivo.Id_Job__c);
    }
    
    static testMethod void testCancelBatch() {
        Test.StartTest();
        GeneradorRegistrosCobranzaController generador= new GeneradorRegistrosCobranzaController ();
      
        generador.runProcess();
        Estado_Ejecuciones_Reg_Cobranza__c procesoActivo = generador.getProcesoActivo();
        generador.cancelProcess();
        Estado_Ejecuciones_Reg_Cobranza__c a = [Select Id_Job__c, Estado_Ejecucion__c  from Estado_Ejecuciones_Reg_Cobranza__c where Id_Job__c = :procesoActivo.Id_Job__c];
        System.AssertEquals(a.Estado_Ejecucion__c, 'Cancelado');
        Test.StopTest();
    }
    
    static testMethod void testDeleteBatch() {
    Account acc = new Account(Name='test2011');
        insert acc;
    
        List<Contact> donantesTests = new List<Contact>();
        List<Compromiso__c> compromisosTests = new List<Compromiso__c>();
        for(integer i=0;i<5;i++){
            Contact persona = new Contact(
                FirstName='Nombre'+i,
                LastName='Apellido'+i,
                Title='Titulo',
                Email='contacto'+i+'@test.com',
                AccountId = acc.Id);
            insert persona;
            date hoy = Date.today();
        
            Compromiso__c compromiso = new Compromiso__c(
                Donante__c=persona.Id,
                Estado__c='Activo',
                Frecuencia__c='Mensual',
                Monto_en_pesos__c=100,
        Monto_de_ajuste__c=0,
                Fecha_de_compromiso__c=hoy,
                Fecha_para_realizar_primer_cobranza__c=hoy.addDays(1));
            
            compromisosTests.add(compromiso);
        }
        insert compromisosTests;
        
    Test.StartTest();
        GeneradorRegistrosCobranzaController generador= new GeneradorRegistrosCobranzaController ();
        generador.runProcess();
    Test.StopTest();
 
    Task t = generador.getTask();
    t.activitydate = Date.today();
        
    generador.deleteProcess();
    }
}