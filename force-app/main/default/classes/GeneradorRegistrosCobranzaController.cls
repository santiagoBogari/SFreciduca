global class GeneradorRegistrosCobranzaController implements Database.Batchable<sObject>, Schedulable{

    Task t = new Task();
    public Task getTask() { return t; }
    public String query = '';
    
    global map<String, Integer> periodos = new Map<String, Integer>{'Mensual' => 1, 'Cada 2 meses' => 2, 'Cada 3 meses' => 3, 'Cada 6 meses' => 6, 'Anual' => 12, 'Única vez' => 0};
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(query == ''){
            query = 'Select c.id, c.Mes_adelantado__c, c.Monto_en_pesos__c, c.Monto_de_ajuste__c, c.Moneda__c, c.Donante__c, c.Fecha_de_pr_xima_cobranza__c, c.Fecha_Ultima_Cobranza__c, c.Fecha_para_realizar_primer_cobranza__c, c.Frecuencia__c from Compromiso__c c where c.Estado__c in (\'Primer cobranza pendiente\',\'Activo\') and ((c.Mes_adelantado__c = false and (c.Fecha_para_realizar_primer_cobranza__c <= THIS_MONTH and c.Fecha_para_realizar_primer_cobranza__c <= THIS_YEAR) and (c.Fecha_de_pr_xima_cobranza__c = null or (c.Fecha_de_pr_xima_cobranza__c = THIS_MONTH and c.Fecha_de_pr_xima_cobranza__c = THIS_YEAR))) or (c.Mes_adelantado__c = true and (c.Fecha_para_realizar_primer_cobranza__c <= NEXT_MONTH and c.Fecha_para_realizar_primer_cobranza__c <= THIS_YEAR) and (c.Fecha_de_pr_xima_cobranza__c = null or (c.Fecha_de_pr_xima_cobranza__c = NEXT_MONTH and c.Fecha_de_pr_xima_cobranza__c = THIS_YEAR))))';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> listaCompromisos){
        List<Registro_de_cobranza__c> registrosCobroInsertar = new List<Registro_de_cobranza__c>();
        List<Compromiso__c> compromisosUpdate = new List<Compromiso__c>();
        
        for(sObject obj: listaCompromisos){         
            Compromiso__c c=(Compromiso__c)obj;
            c.Backup_Fecha_de_pr_ximo__c = c.Fecha_de_pr_xima_cobranza__c;
            if(c.Fecha_de_pr_xima_cobranza__c == null){
                if (c.Frecuencia__c != 'Test'){
                    c.Fecha_de_pr_xima_cobranza__c = c.Fecha_para_realizar_primer_cobranza__c.addMonths(periodos.get(c.Frecuencia__c));
                    Registro_de_cobranza__c registroCobranza=new Registro_de_cobranza__c();
                    registroCobranza.Moneda__c=c.Moneda__c;
                    registroCobranza.Fecha_de_cobr__c=c.Fecha_para_realizar_primer_cobranza__c; //Date.today();
                    registroCobranza.Compromiso__c=c.Id;
                    registroCobranza.Donante__c=c.Donante__c ;
                    registroCobranza.Monto_esperado__c=c.Monto_en_pesos__c;
                    registroCobranza.Monto_de_ajuste__c= c.Monto_de_ajuste__c;
                    registrosCobroInsertar.add(registroCobranza);
                    compromisosUpdate.add(c);
                    //insert registroCobranza;
                } // Fin If Frecuencia
            } else {
                
                Registro_de_cobranza__c registroCobranza=new Registro_de_cobranza__c();
                registroCobranza.Moneda__c=c.Moneda__c;
                registroCobranza.Fecha_de_cobr__c=c.Fecha_de_pr_xima_cobranza__c; //Date.today();
                c.Fecha_de_pr_xima_cobranza__c = c.Fecha_de_pr_xima_cobranza__c.addMonths(periodos.get(c.Frecuencia__c));registroCobranza.Compromiso__c=c.Id;
                registroCobranza.Donante__c=c.Donante__c ;
                registroCobranza.Monto_esperado__c=c.Monto_en_pesos__c;
                registroCobranza.Monto_de_ajuste__c= c.Monto_de_ajuste__c;
                registrosCobroInsertar.add(registroCobranza);
                compromisosUpdate.add(c);
                //insert registroCobranza;
            } // Fin If proxima cobranza
            //update c;
            
        } // Fin For listaCompromisos
        
        if(registrosCobroInsertar.size()>0){
            insert registrosCobroInsertar;
        }
        
        if(compromisosUpdate.size()>0){
            update compromisosUpdate;
        }

    }
    
    global void finish(Database.BatchableContext BC){
        Estado_Ejecuciones_Reg_Cobranza__c procesoActivo=getProcesoActivo();
        
        if(procesoActivo!=null){
            AsyncApexJob a = [Select Id,  NumberOfErrors, JobItemsProcessed,TotalJobItems from AsyncApexJob where Id =:BC.getJobId()];
            procesoActivo.Items_Procesados__c=a.JobItemsProcessed;
            procesoActivo.Items_Procesados_Erroneos__c=a.NumberOfErrors;
            procesoActivo.Estado_Ejecucion__c='Ejecutado';
            procesoActivo.endDate__c=Datetime.now();
            update procesoActivo;
        }
    }
    
    public Estado_Ejecuciones_Reg_Cobranza__c getProcesoActivo(){
        List<Estado_Ejecuciones_Reg_Cobranza__c> procesosActivo=[Select Items_Procesados__c,Items_Procesados_Erroneos__c,Id_Job__c,Id,Estado_Ejecucion__c,startDate__c from Estado_Ejecuciones_Reg_Cobranza__c where Estado_Ejecucion__c='Ejecutando' order by startDate__c desc limit 1];
        if(procesosActivo.size()>0){ 
            return procesosActivo[0];
        }
        return null;
    }
    
    public Estado_Ejecuciones_Reg_Cobranza__c getUltimoProceso(){
        List<Estado_Ejecuciones_Reg_Cobranza__c> procesosActivo=[Select Items_Procesados__c,Items_Procesados_Erroneos__c,Id_Job__c,Id,Estado_Ejecucion__c,startDate__c from Estado_Ejecuciones_Reg_Cobranza__c order by startDate__c desc limit 1];
        if(procesosActivo.size()>0){ 
            return procesosActivo[0];
        }
        return null;
    }    
     
    public PageReference deleteProcess(){
        if(t.activitydate==null){
            writeError('Debe ingresar una fecha para poder borrar');
            return null;
        }
        System.debug('Fecha para borrar: ' +t.activitydate);
        
        List<Registro_de_cobranza__c> listaRegistros = [Select Id, Compromiso__c From Registro_de_cobranza__c where DAY_ONLY(CreatedDate) =: t.activitydate];
        
        System.debug('Cantidad de Registros: ' +listaRegistros.size());
        
        if (listaRegistros.size() > 0) {
            String idsCompromisosDeRegistros= getStringDeListaDeRegistros(listaRegistros);
          
            String stringSOQLInfoCompromiso = 'SELECT Id, Fecha_de_pr_xima_cobranza__c, Fecha_para_realizar_primer_cobranza__c, Frecuencia__c, Backup_Fecha_de_pr_ximo__c FROM Compromiso__c where id IN '+idsCompromisosDeRegistros;
        
            System.debug(stringSOQLInfoCompromiso);
        
            List<Compromiso__c> listaCompromisos = database.query(stringSOQLInfoCompromiso);
            List<Compromiso__c> compromisosUpdate = new List<Compromiso__c>();
        
            for(Compromiso__c c: listaCompromisos){
                if(c.Fecha_de_pr_xima_cobranza__c != null){
                    c.Fecha_de_pr_xima_cobranza__c = c.Backup_Fecha_de_pr_ximo__c;
                    compromisosUpdate.add(c);
                }
            }
            if(compromisosUpdate.size()>0){
                update compromisosUpdate;
            }
        
            delete listaRegistros;
        
            writeInfo('Registros Borrados correctamente. Cantiad de registros: '+listaRegistros.size());
        }
        return null;
    } 
    
    private string getStringDeListaDeRegistros(list<Registro_de_cobranza__c> listaRegistros){
        String stringADevolver = '(';
        for(Registro_de_cobranza__c item : listaRegistros){
            if(stringADevolver.length() > 1) // si stringADevolver no esta vacio entonces agregarle una coma como separador antes de agregar otro.
                stringADevolver += ',';
            stringADevolver += '\'' + item.Compromiso__c + '\'';
        }
        stringADevolver += ')';
        return stringADevolver;
    }
    
    public PageReference runProcess(){
        Estado_Ejecuciones_Reg_Cobranza__c procesoActivo=getProcesoActivo();
        if(procesoActivo!=null){        
            writeError('Hay un proceso de generación de registros de cobranza ejecutandose. Fecha de inicio del proceso: '+procesoActivo.startDate__c.format('dd/MM/yyyy HH:mm:ss'));
        }
        else{
            ID batchProcessId=Database.executeBatch(this, 100);
            Estado_Ejecuciones_Reg_Cobranza__c estado=new Estado_Ejecuciones_Reg_Cobranza__c();
            estado.startDate__c=Datetime.now();
            estado.Id_Job__c=batchProcessId;
            estado.Estado_Ejecucion__c='Ejecutando';
            insert estado;
            writeInfo('Proceso iniciado.');        
        }
        return null;
    }
    
    public PageReference cancelProcess(){
        Estado_Ejecuciones_Reg_Cobranza__c procesoActivo=getProcesoActivo();
        if(procesoActivo==null){
            writeError('No hay ningun proceso de generación de registros de cobranza ejecutandose.');
        }
        else{
            System.abortJob(procesoActivo.Id_Job__c);
            procesoActivo.Estado_Ejecucion__c='Cancelado';
            procesoActivo.endDate__c=Datetime.now();
            update procesoActivo;
            writeInfo('Proceso Cancelado.');
        }
        return null;
    }
    
    private void writeMsg(ApexPages.Severity severity, String msg){
        ApexPages.Message myMsg = new ApexPages.Message(severity,msg);
        ApexPages.addMessage(myMsg);
    }
    
    private void writeError(String errorMsg){
        writeMsg(ApexPages.Severity.ERROR,errorMsg);        
    }
    
    private void writeInfo(String infoMsg){
        writeMsg(ApexPages.Severity.INFO,infoMsg);        
    }
    
    global void execute(SchedulableContext SC) {
      Database.executeBatch(this, 100);
    }
}