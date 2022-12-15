trigger Proyecto_Completo on Proyecto__c (after update) {
    
    if(Trigger.new.size()>0){
        List<Proyecto__c> upProyectos = Trigger.new;
        //system.debug(upProyectos);
        taresARealizar(upProyectos);
    }
    
    public void taresARealizar(Proyecto__c[] upProyectos) {
        List<Id> idsProyectos = new List<Id>();
        Map<Id, Proyecto__c> mapProyectosActualizados = new Map<Id, Proyecto__c>();
        
        for(Proyecto__c p : upProyectos){
            if(p.Estado__c == 'Completo' || p.Estado__c == 'Inactivo-Incompleto') {
                idsProyectos.add(p.Id);
                mapProyectosActualizados.put(p.Id,p);
            }
        }
        
        List<Asignaci_n__c> asignaciones = [select id, Proyecto__c from Asignaci_n__c where Estado__c = 'Activo' AND Proyecto__c in :idsProyectos];
        
        /*List<Asignaci_n__c> asignacionesActualizar = new List<Asignaci_n__c>();
        for(Asignaci_n__c a : asignaciones){
            a.Estado__c = 'Completo';
            a.Fecha_de_baja__c = Date.today();
            asignacionesActualizar.add(a);
        }*/
        
        for(Integer i = 0; i < asignaciones.size(); i++){
            asignaciones[i].Estado__c = 'Completo';
            asignaciones[i].Fecha_de_baja__c = mapProyectosActualizados.get(asignaciones[i].Proyecto__c).Fecha_de_finalizaci_n__c;
        }
        
        if (asignaciones.size() > 0) {
            Database.SaveResult[] lsr = Database.update(asignaciones, false);
        }
        //system.debug(asigUpdate);
    }

}