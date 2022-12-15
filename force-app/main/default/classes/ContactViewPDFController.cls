public class ContactViewPDFController {

    private Id recordId;
    private Contact contacto {get;set;}
    private Seguimiento_Educativo__c seguimiento {get;set;}
    public List<contactWrapper> resultList {get;set;}
    
    public ContactViewPDFController(ApexPages.StandardController controller) {
        resultList = new List<contactWrapper>();
        this.recordId = controller.getId();
        String sObjectName = this.recordId.getSobjectType().getDescribe().getName();
        List<Contact> becariosList = new List<Contact>();
        String condition = '';
        
        if(sObjectName == 'Account')
        {
            contacto = [SELECT Id, RecordType.Name FROM Contact WHERE npsp__Primary_Affiliation__c =:recordId LIMIT 1];
            condition = 'WHERE npsp__Primary_Affiliation__c = :recordId';
        }
        else if(sObjectName == 'Contact')
        {
            contacto = [SELECT Id, RecordType.Name FROM Contact WHERE id=: recordId LIMIT 1];
            
            if(contacto.RecordType.Name == 'NPSP Becarios')
            	condition = 'WHERE Id = :recordId';
            else if(contacto.RecordType.Name == 'NPSP Contactos Generales')
            	condition = 'WHERE Padrino__c = :recordId';            
        }
            
        String qr = 'SELECT Id,(select Id, CreatedDate, Alumno__c, Estado__c, Programa__r.Name from Pertenencias_a_Programas__r order by CreatedDate desc limit 1),(Select Id,Alumno__c, a_Espacio_de_Estudio__c, a_Observaciones_Espacio_de_Estudio__c, Estado__c, c_Practica_Educativa__c, c_Observaciones_Practica_Educativa__c, d_Espacio_Desarrollo_Personal__c, d_Observaciones_Desarrollo_Personal__c, Fecha_de_Informe__c, a_Observaciones_Personales__c, c_Conducta__c, c_Observaciones_Conducta__c, d_Asistencia_a_Clase__c, b_Capacitaciones__c, b_Observaciones_Capacitaci_n__c, CreatedDate, Nro_de_Informe__c from Seguimientos_Educativos__r ORDER BY CreatedDate DESC LIMIT 1), (Select Id,Alumno__c,Alumno__r.Name, Alumno__r.Birthdate, Alumno__r.Edad__c, Alumno__r.npsp__Primary_Affiliation__r.Name,Alumno__r.Account.Name, Alumno__r.MailingCity, Anio_calendario__c, Primer_Promedio__c, Segundo_Promedio__c, Tercer_Promedio__c, Final_Promedio__c, Esfuerzo__c,Observaciones_Esfuerzo__c, Observaciones_de_Inasistencia_a_Clase__c, CreatedDate FROM Boletines__r ORDER BY CreatedDate DESC LIMIT 1) FROM Contact ' + condition;
        becariosList = Database.query(qr);

        
        List<Id> becariosId = new List<Id>();
        List<Id> boletinesIds = new List<Id>();
        List<Seguimiento_Educativo__c> seguimientosList = new List<Seguimiento_Educativo__c>();
        List<Boletin__c> boletinesList = new List<Boletin__c>();
        List<Pertenencia_a_Programas__c> pertenenciaList = new List<Pertenencia_a_Programas__c>();
        Map<Id, Pertenencia_a_Programas__c> pertenenciasMap = new Map<Id, Pertenencia_a_Programas__c>();
        Map<Id, Seguimiento_Educativo__c> seguimientoMap = new Map<Id, Seguimiento_Educativo__c>();
        Map<Id, Boletin__c> boletinMap = new Map<Id, Boletin__c>();
        Map<Id, List<Inasistencia__c>> faltasMap = new Map<Id, List<Inasistencia__c>>();
        Map<Id, List<Calificacion__c>> calificacionesMap = new Map<Id, List<Calificacion__c>>();
        Map<Id, Id> IdImagenAlumnoByIdAlumno = new  Map<Id, Id>();
               
        for(Contact cont: becariosList)
        {   
            if(cont.Pertenencias_a_Programas__r[0].Estado__c == 'Activo'){
                becariosId.add(cont.Id);
                seguimientosList.addAll(cont.Seguimientos_Educativos__r);
                pertenenciaList.addAll(cont.Pertenencias_a_Programas__r);
                for(Boletin__c bol: cont.Boletines__r)
                {
                    boletinesIds.add(bol.Id);
                    boletinesList.add(bol);
                }
            }
            
        }
        List<ContentVersion> listaImagenes = [SELECT Id, FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId IN: becariosId];
        List<Inasistencia__c> faltasList = BoletinDataService.getListInasistencias(boletinesIds);
        List<Calificacion__c> calificacionesList = BoletinDataService.getListCalificaciones(boletinesIds);
        
        for(ContentVersion imagenAlumno : listaImagenes){
            IdImagenAlumnoByIdAlumno.put(imagenAlumno.FirstPublishLocationId, imagenAlumno.Id);
        }

        for(Seguimiento_Educativo__c seg: seguimientosList)
            seguimientoMap.put(seg.Alumno__c, seg);
        
        for(Boletin__c bol :boletinesList)
            boletinMap.put(bol.Alumno__c, bol);
        
        for(Pertenencia_a_Programas__c p: pertenenciaList)
            pertenenciasMap.put(p.Alumno__c, p);
        
        for(Inasistencia__c fal :faltasList)
            if(faltasMap.containsKey(fal.Boletin__r.Alumno__c))
                faltasMap.get(fal.Boletin__r.Alumno__c).add(fal);                    
            else
                faltasMap.put(fal.Boletin__r.Alumno__c,new List<Inasistencia__c>{fal});
            
        
        for(Calificacion__c cal :calificacionesList)
            if(calificacionesMap.containsKey(cal.Boletin__r.Alumno__c))
                calificacionesMap.get(cal.Boletin__r.Alumno__c).add(cal);                    
            else
                calificacionesMap.put(cal.Boletin__r.Alumno__c,new List<Calificacion__c>{cal});
        
        for(Contact con :becariosList)
        {   
            if(con.Pertenencias_a_Programas__r[0].Estado__c == 'Activo'){
                contactWrapper res = new contactWrapper(boletinMap.get(con.Id), calificacionesMap.get(con.Id), faltasMap.get(con.Id), seguimientoMap.get(con.Id), pertenenciasMap.get(con.Id), IdImagenAlumnoByIdAlumno.get(con.Id));
                resultList.add(res);               
            }
        }
        
    }
    
    
    public class contactWrapper{
        public Boletin__c boletin {get;set;}
        public List<Calificacion__c> listaDeCalificaciones {get; set;}
        public List<Inasistencia__c> listaDeInasistencias {get; set;}
        public Seguimiento_Educativo__c seguimiento {get;set;}
        public Pertenencia_a_Programas__c programa {get;set;}
        public Id ImagenDeAlumno {get;set;}

        public contactWrapper(Boletin__c boletinParaSetear, List<Calificacion__c> calificaciones, List<Inasistencia__c> faltas, Seguimiento_Educativo__c seguimiento, Pertenencia_a_Programas__c pertenencia, Id imagenDeAlumno){
           this.boletin = boletinParaSetear;
           this.listaDeCalificaciones = calificaciones;
           this.listaDeInasistencias = faltas;
           this.seguimiento = seguimiento;
           this.programa = pertenencia;
           this.ImagenDeAlumno = imagenDeAlumno;
        }
    }
}