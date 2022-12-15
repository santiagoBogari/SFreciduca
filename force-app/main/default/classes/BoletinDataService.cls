public with sharing class BoletinDataService {

    @AuraEnabled(Cacheable=true)
    public static List<Calificacion__c> getCalificaciones(String boletinId) {
        List<Calificacion__c> listaDeCalificaciones = [SELECT Id, Materia__r.Name, Primer_trimestre__c, Segundo_trimestre__c, Tercer_trimestre__c, Final__c, Estado__c FROM Calificacion__c WHERE Boletin__c = :boletinId];
        return listaDeCalificaciones;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Inasistencia__c> getInasistencias(String boletinId) {
        List<Inasistencia__c> listaDeInasistencias = [SELECT Id, Primer_trimestre__c, Segundo_trimestre__c, Tercer_trimestre__c, Boletin__c, Acumulado_Anual__c FROM Inasistencia__c
                                                      WHERE Boletin__c = :boletinId];
        return listaDeInasistencias;
    }
    
    @AuraEnabled
    public static List<Calificacion__c> getListCalificaciones(List<ID> boletinIdList) {
        List<Calificacion__c> listaDeCalificaciones = [SELECT Id, Materia__r.Name, Primer_trimestre__c, Segundo_trimestre__c, Tercer_trimestre__c, Final__c, Boletin__c, Boletin__r.Alumno__c FROM Calificacion__c
                                                       WHERE Boletin__c IN :boletinIdList];
        return listaDeCalificaciones;
    }
    
    @AuraEnabled
    public static List<Inasistencia__c> getListInasistencias(List<ID> boletinIdList) {
        List<Inasistencia__c> listaDeInasistencias = [SELECT Id, Primer_trimestre__c, Segundo_trimestre__c, Tercer_trimestre__c, Boletin__r.Alumno__c, Acumulado_Anual__c FROM Inasistencia__c
                                                      WHERE Boletin__c IN :boletinIdList];
        return listaDeInasistencias;
    }

    @AuraEnabled
    public static String updateCalificacion(List<Calificacion__c> data) {
        try {
            update data;
            return 'Boletín actualizado';
        }
        catch(exception error) {
            return error.getMessage();
        }
        
    }

    @AuraEnabled
    public static String updateInasistencia(List<Inasistencia__c> data) {
        try {
            update data;
            return 'Boletín actualizado';
        }
        catch(exception error) {
            return error.getMessage();
        }
    }
}