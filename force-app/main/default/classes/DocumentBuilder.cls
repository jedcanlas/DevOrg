/*------------------------------------------------------------
    Author:        Sumit Gupta
    Company:       
    Description:   
    History
    <Date>          <Authors Name>        <Brief Description of Change>
    23/Nov/2016       Sumit Gupta           Last modified date
    11/Apr/2017    Christian Jed Canlas     Added comments and headers
    ------------------------------------------------------------*/ 
public class DocumentBuilder {
    //person role Id
    public Id recordId{get; set;}
    public Id solutionId;
        
    public String objectName{get; set;}
    public String objectLabel{get; set;}
    public String sensitivityValue{get; set;}
    public String congaFrameURL{get; set;}  
    
    public String step{get; set;}
    public String selectedChildObject{get; set;}
    public String selectedDocumentType{get; set;}
    
    public Date lastModifiedDateFrom{get; set;}
    public Date lastModifiedDateTo{get; set;}
    
    public Map<String, ChildObject> childObjects;
    public Map<String, SelectedChildObject> selectedChildObjects;
    
    public Map<String, ChildObject> documentTypes;
    public Map<String, SelectedChildObject> selectedDocumentTypes;
    
    public List<Field> columns{get; set;}
    public List<SelectOption> childObjectOptions{get; set;}
    public List<SelectOption> documentTypeOptions{get; set;}
    
    public List<Record> records{get; set;}
    public List<SelectedChildObject> selectedRecords{get; set;}
    
    public List<Record> documents{get; set;}
    public List<SelectedChildObject> selectedDocuments{get; set;}
    
    public List<Template> templates{get; set;}
    
    public String renderingService { get; private set; }
    public String renderedFileName { get;  set { renderedFileName = this.sanitizeFileName(value); }}
    
    
    /*------------------------------------------------------------
    Author:        Sumit Gupta
    Company:       
    Description:  method to render the document as PDF along with the desired
                  filename
    History
    <Date>          <Authors Name>        <Brief Description of Change>
    23/Nov/2016       Sumit Gupta           Last modified date
    11/Apr/2017    Christian Jed Canlas     Added comments and headers
    ------------------------------------------------------------*/ 
    
    public String renderedContentType {
        get {
            String renderedContentType = 'text/html'; // the default
            if(!this.renderingAsHtml()) {
                renderedContentType = 'application/pdf';
                if(this.renderedFileName != null) {
                    renderedContentType += '#' + this.renderedFileName;
                    ApexPages.currentPage().getHeaders().put(
                        'content-disposition', 'attachment; filename=' + this.renderedFileName
                    );
                }
            }
            system.debug('---METHOD---renderedContentType:---' + renderedContentType);
            return renderedContentType;
        }
    }
    
    //render content type as HTML
    public Boolean renderingAsHtml() {
        system.debug('---METHOD---renderingAsHtml:---' + renderingService);
        return renderingService == null || !renderingService.startsWith('PDF');
    }
    
    //remove unnecessary characters when rendering filename
    private String sanitizeFileName(String unsafeName) {
        system.debug('---METHOD---sanitizeFileName:---' + unsafeName.replaceAll('[^' + '0-9a-zA-Z-_.' + ']', ''));
        return unsafeName.replaceAll('[^' + '0-9a-zA-Z-_.' + ']', '');
    }
    
    //wrapper class for field APi and label
    public Class Field{
        
        public String name{get; set;}
        public String label{get; set;}
        
        public Field(String name, String label){
            this.name = name;
            this.label = label;
        }
    }
    
    //wrapper class to get all related list from person role record which has records
    public class ChildObject{
        String name;
        String nameField;
        String relationField;
        
        public List<Field> fields{get; set;}
        
        public ChildObject(String name, String relationField){
            this.name = name;
            this.relationField = relationField;
        }
        
        public ChildObject(String name, List<FieldSetMember> fieldSetMembers, String relationField){
            this(name, relationField);
            
            fields = new List<Field>();
            for(FieldSetMember fld :fieldSetMembers){
                fields.add(new Field(fld.getFieldPath(), fld.getLabel()));
            }
        }
        
        public ChildObject(String name, List<Field> fields, String relationField){
            this(name, relationField);
            this.fields = fields;
        }
        
        public ChildObject(String name, List<Field> fields, String relationField, String nameField){
            this(name, fields, relationField);
            this.nameField = nameField;
        }
    }
    
    public class Record{
        public String name;
        public SObject record;
        public Boolean selected{get; set;}
        public Map<String, String> values{get; set;}
        
        public Record(List<Field> field, SObject record){
            this.record = record;
            values = new Map<String, String>();
            for(Field fld :field){
                String value;
                if(fld.name.contains('.')){
                    String[] arr = fld.name.split('\\.');
                    SObject parent = record.getSObject(arr.get(0));
                    value = String.valueOf(parent.get(arr.get(1)));
                } else {
                    value = String.valueOf(record.get(fld.name));
                }
                values.put(fld.name, value != null ? value : '');
            }
            values.put('Id', String.valueOf(record.get('Id')));
        }
        
        public Record(List<Field> field, SObject record, String name){
            this(field, record);
            this.name = name;
        }
        
        public SObject getSObject(){
            return record;
        }
    }
    
    //wrapper class containing all of the selected objects/records
    public class SelectedChildObject{
        public String name{get; set;}
        public String dname{get; set;}
        public Integer count{get; set;}
        
        public ChildObject childObject{get; set;} 
        public ChildObject documentType{get; set;} 
        
        private Map<String, Record> records;
        
        public SelectedChildObject(String name, ChildObject childObject){
            this.name = name;
            this.childObject = childObject;
            records = new Map<String, Record>();
            count = 0;
        }
        
        public SelectedChildObject(String name, String dname, ChildObject childObject, ChildObject documentType){
            this.name = name;
            this.dname = dname;
            this.childObject = childObject;
            this.documentType = documentType;
            records = new Map<String, Record>();
            count = 0;
        }
        
        public void addRecord(Record record){
            String recId = record.values.get('Id');
            if(!records.containsKey(recId)){
                records.put(recId, record);
            }
            count = records.size();
        }
        
        public void removeRecord(Record record){
            records.remove(record.values.get('Id'));
            count = records.size();
        }
        
        public List<String> getRecordIds(){
            List<String> recordIds = new List<String>();
            for(String recId :records.keySet()){
                recordIds.add(records.get(recId).values.get('Id'));
            }
            return recordIds;
        }
 
        public List<Record> getRecords(){
            return records.values();
        }
    }
    
    //wrapper class containing all templates in creating the document specifically from each related objects
    public class TemplateChildObject{
        public String name{get; set;}
        public String queryName{get; set;}
        public Integer recordsCount{get; set;}
        public Integer documentsCount{get; set;}
        
        public TemplateChildObject(String name, String queryName, Integer recordsCount, Integer documentsCount){
            this.name = name;
            this.queryName = queryName;
            this.recordsCount = recordsCount;
            this.documentsCount = documentsCount;
        }
    }
    
    public class Template{
        public String id{get; set;}
        public String name{get; set;}
        public Boolean selected{get; set;}
        public List<TemplateChildObject> childObjects{get; set;}
        
        public Template(String id, String name){
            this.id = id;
            this.name = name;
            childObjects = new List<TemplateChildObject>();
        }
        
        public void addChildObject(String name, String queryName, SelectedChildObject childObject, SelectedChildObject document){
            childObjects.add(new TemplateChildObject(name, queryName, childObject != null ? childObject.count : 0, document != null ? document.count : 0));
        }
    }
    
    public class applicationException extends Exception {}
    
    /*------------------------------------------------------------
    Author:        Sumit Gupta
    Company:       
    Description:   class constructor
    History
    <Date>          <Authors Name>        <Brief Description of Change>
    23/Nov/2016       Sumit Gupta           Last modified date
    11/Apr/2017    Christian Jed Canlas     Added comments and headers
    ------------------------------------------------------------*/ 
    public DocumentBuilder(){
        system.debug('--INITIAL LOAD OF THE PAGE--');
        step = '1';
        recordId = ApexPages.currentPage().getParameters().get('id');
        solutionId = ApexPages.currentPage().getParameters().get('solutionId');
        
        DescribeSObjectResult objectDescribe = recordId.getSObjectType().getDescribe();
        objectName = objectDescribe.getName();
        objectLabel = objectDescribe.getLabel();
        
        system.debug('--CONSTRUCTOR--objectName     ' + objectName);
        system.debug('--CONSTRUCTOR--objectLabel        ' + objectLabel);
        
        childObjects = new Map<String, ChildObject>();
        childObjectOptions = new List<SelectOption>();
        selectedChildObjects = new Map<String, SelectedChildObject>();
        
        for(ChildRelationship cr :objectDescribe.getChildRelationships()){ 
            DescribeSObjectResult dr = cr.getChildSObject().getDescribe();
            Map<String, Schema.FieldSet> fieldSets = dr.fieldSets.getMap();
            
            system.debug('--CONSTRUCTOR--ChildRelationship      ' + cr);
            system.debug('--CONSTRUCTOR--DescribeSObjectResult      ' + dr);
            system.debug('--CONSTRUCTOR--fieldSets      ' + fieldSets);
            
            if(fieldSets.containsKey('Document_Generation')){
                DescribeFieldResult relationField = dr.fields.getMap().get(String.valueOf(cr.getField())).getDescribe();
                String uniqueName = dr.getLabel() + ' (' + relationField.getLabel() + ')';
                
                if(!childObjects.containsKey(uniqueName)){
                    ChildObject childObject = new ChildObject(dr.getName(), fieldSets.get('Document_Generation').getFields(), relationField.getName());
                    childObjects.put(uniqueName, childObject);
                    childObjectOptions.add(new SelectOption(uniqueName, uniqueName));
                }
            }
        }
        
        
        
        if(!childObjectOptions.isEmpty()){
            selectedChildObject = childObjectOptions.get(0).getValue();
            system.debug('--CONSTRUCTOR--getRecords()--CALL--');
            getRecords();
        }
        
        system.debug('--CONSTRUCTOR--childObjects' + childObjects);
        system.debug('--CONSTRUCTOR--childObjects' + childObjects);
        system.debug('--CONSTRUCTOR--childObjectOptions' + childObjectOptions);
        system.debug('--CONSTRUCTOR--selectedChildObject' + selectedChildObject);
        
        //Document_Sensitivity_Mapping__mdt[] mapping = [SELECT Value__c FROM Document_Sensitivity_Mapping__mdt WHERE Object__c =: objectName];
        //if(!mapping.isEmpty()){
            //sensitivityValue = mapping.get(0).Value__c;
        //}
        system.debug('--INITIAL LOAD OF THE PAGE--END--');
    }
    
    /*------------------------------------------------------------
    Author:        Sumit Gupta
    Company:       
    Description:   fetch all related records/fields selected to be displayed
                   on the document
    History
    <Date>          <Authors Name>        <Brief Description of Change>
    23/Nov/2016       Sumit Gupta           Last modified date
    11/Apr/2017    Christian Jed Canlas     Added comments and headers
    ------------------------------------------------------------*/ 
    public void getRecords(){
        try{
            records = new List<Record>();
            ChildObject co = childObjects.get(selectedChildObject);
            system.debug('--METHOD--getRecords()--co--:' + co);
            
            String query = '';
            for(Field fld :co.fields){
                if(String.isEmpty(query)){
                    query += fld.name;
                } else {
                    query += ',' + fld.name;
                }
            }
            query = 'SELECT ' + query + ' FROM ' + co.name + ' WHERE ' + co.relationField + ' =: recordId';
            system.debug('--METHOD--getRecords()--query--:' + query);
            /*
            if(lastModifiedDateFrom != null || lastModifiedDateTo != null){
                query += ' AND (';
                if(lastModifiedDateFrom != null){
                    query += 'LastModifiedDate >=: lastModifiedDateFrom';
                    
                    if(lastModifiedDateTo != null){
                        query += ' AND ';
                    }
                }
                if(lastModifiedDateTo != null){
                    query += 'LastModifiedDate <=: lastModifiedDateTo';
                }
                query += ')';
            }*/
            
            for(SObject record :Database.query(query)){
                records.add(new Record(co.fields, record));
            }
            columns = co.fields; 
            
            SelectedChildObject so = selectedChildObjects.get(selectedChildObject);
            if(so != null){
                for(Record rec :records){
                    if(so.records.containsKey(rec.values.get('Id'))){
                        rec.selected = true;
                    }
                }
            }
            
            system.debug('--METHOD--getRecords()--records--:' + records);
        } catch (Exception ex){
            throw new applicationException(ex.getMessage());
            records = null;
        }
    }
    
    /*------------------------------------------------------------
    Author:        Sumit Gupta
    Company:       
    Description:  fetch related documents
    History
    <Date>          <Authors Name>        <Brief Description of Change>
    23/Nov/2016       Sumit Gupta           Last modified date
    11/Apr/2017    Christian Jed Canlas     Added comments and headers
    ------------------------------------------------------------*/ 
    public void getDocuments(){
        try{
            SelectedChildObject sco = selectedChildObjects.get(selectedChildObject);
            ChildObject dt = documentTypes.get(selectedDocumentType);
            documents = new List<Record>();
            
            if(sco == null){
                columns = dt.fields;
                return;
            }
            String query = '';
            for(Field fld :dt.fields){
                if(String.isEmpty(query)){
                    query += fld.name;
                } else {
                    query += ',' + fld.name;
                }
            }
            List<String> recordIds = sco.getRecordIds();
            query = 'SELECT ' + query + ' FROM ' + dt.name + ' WHERE ' + dt.relationField + ' IN: recordIds'; 
            
            for(SObject record :Database.query(query)){
                documents.add(new Record(dt.fields, record));
            }
            columns = dt.fields; 
            
            SelectedChildObject so = selectedDocumentTypes.get(selectedDocumentType);
            if(so != null){
                for(Record rec :records){
                    if(so.records.containsKey(rec.values.get('Id'))){
                        rec.selected = true;
                    }
                }
            }
            system.debug('--METHOD--getDocuments()--records--:' + records);
        } catch (Exception ex){
            throw new applicationException(ex.getMessage());
            records = null;
            columns = null;
        }
    }
    
    public void addRecords(){
        ChildObject co = childObjects.get(selectedChildObject);
        SelectedChildObject so = selectedChildObjects.get(selectedChildObject);
        
        if(so == null){
            so = new SelectedChildObject(selectedChildObject, co);
        }
        for(Record rec :records){
            if(rec.selected){
                so.addRecord(rec);
            } else {
                so.removeRecord(rec);
            }
        }
        if(!so.records.isEmpty()){
            selectedChildObjects.put(selectedChildObject, so);
        } else {
            selectedChildObjects.remove(selectedChildObject);
        }
        selectedRecords = selectedChildObjects.values();
    }
    
    public void addAllRecords(){
        String oldValue = selectedChildObject;
        for(SelectOption so :childObjectOptions){
            selectedChildObject = so.getValue();
            getRecords();
            for(Record rec :records){
                rec.selected = true;
            }
            addRecords();
        }
        selectedChildObject = oldValue;
    }
    
    /*------------------------------------------------------------
    Author:        Sumit Gupta
    Company:       
    Description:   method to enable adding of additional documents to render as PDF
    History
    <Date>          <Authors Name>        <Brief Description of Change>
    23/Nov/2016       Sumit Gupta           Last modified date
    11/Apr/2017    Christian Jed Canlas     Added comments and headers
    ------------------------------------------------------------*/ 
    public void addDocuments(){
        ChildObject co = childObjects.get(selectedChildObject);
        ChildObject dt = documentTypes.get(selectedDocumentType);
        SelectedChildObject so = selectedDocumentTypes.get(selectedChildObject);
        
        if(so == null){
            selectedDocumentTypes.put(selectedChildObject, so = new SelectedChildObject(selectedChildObject, selectedDocumentType, co, dt));
        }
        for(Record rec :documents){
            if(rec.selected){
                so.addRecord(rec);
            } else {
                so.removeRecord(rec);
            }
        }
        selectedDocuments = selectedDocumentTypes.values();
        
        if(selectedDocuments.isEmpty()){
            selectedDocumentTypes.remove(selectedDocumentType);
        }
    }
    
    public void step1(){
        step = '1';
        getRecords();
    }
    
    public void step2(){
        step = '2';
        
        documentTypes = new Map<String, ChildObject>();
        documentTypeOptions = new List<SelectOption>();
        selectedDocumentTypes = new Map<String, SelectedChildObject>();
        
        List<Map<String, String>> types = new List<Map<String, String>>{
            new Map<String, String>{
                'name' => 'Note',
                'label' => 'Notes',
                'nameField' => 'Title',
                'relationField' => 'ParentId'
            },
            new Map<String, String>{
                'name' => 'Attachment',
                'label' => 'Attachments',
                'nameField' => 'Name',
                'relationField' => 'ParentId'    
            },
            new Map<String, String>{
                'name' => 'ContentDocumentLink',
                'label' => 'Document Contents',
                'nameField' => 'ContentDocument.Title',
                'relationField' => 'LinkedEntityId'    
            }
        }; 
            
        Map<String, List<Field>> fields = new Map<String, List<Field>>{
            'Note' => new List<Field>{
                new Field('Title', 'Title'),
                new Field('ParentId', 'ParentId')
            },
            'Attachment' => new List<Field>{
                new Field('Name', 'Name'),
                new Field('ParentId', 'ParentId')
            },
            'ContentDocumentLink' => new List<Field>{
                new Field('LinkedEntityId', 'Linked Entity Id'),
                new Field('ContentDocument.Title', 'Content Document Title'),
                new Field('ContentDocumentId', 'Content Document Id'),
                new Field('ShareType', 'Share Type')
            } 
        };  
        
        for(Map<String, String> type :types){
            String uniqueName = type.get('label') + ' (' + type.get('relationField') + ')';
            ChildObject childObject = new ChildObject(type.get('name'), fields.get(type.get('name')), type.get('relationField'), type.get('nameField'));
            
            documentTypes.put(uniqueName, childObject);
            documentTypeOptions.add(new SelectOption(uniqueName, uniqueName));
        }
        
        selectedChildObject = childObjectOptions.get(0).getValue();
        selectedDocumentType = documentTypeOptions.get(2).getValue();
        
        getDocuments();
    }
    
    public void step3(){
        step = '3';
        templates = new List<Template>();
        Map<String, List<String>> childObjectMap = new Map<String, List<String>>(); 
        
        for(String name :selectedChildObjects.keySet()){
            String uniqueName = selectedChildObjects.get(name).childObject.name;
            if(childObjectMap.containsKey(uniqueName)){
                childObjectMap.get(uniqueName).add(name);
            } else {
                childObjectMap.put(uniqueName, new List<String>{name});
            }
        }    
        
        for(APXTConga4__Conga_Template__c temp :[SELECT APXTConga4__Name__c, APXTConga4__Description__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Template_Group__c =: objectName]){
            Template template = new Template(temp.Id, temp.APXTConga4__Name__c);    
            
            if(temp.APXTConga4__Description__c != null){
                for(String name :temp.APXTConga4__Description__c.split(',')){
                    List<String> configs = name.split('=');
                    
                    if(configs.size() > 0){
                        name = configs.get(0).trim();
                        
                        if(childObjectMap.containsKey(name)){
                            for(String uniqueName :childObjectMap.get(name)){
                                template.addChildObject(uniqueName, configs.get(1).trim(), selectedChildObjects.get(uniqueName), selectedDocumentTypes.get(uniqueName));
                            }
                        }
                    }
                }
            }
            templates.add(template);
        }
    }
    
    public void step4(){
        step = '4';
        
        String uniqueName = 'Document Bundle - ' + UserInfo.getUserId() + '_' + recordId;
        String congaURL = getCongoEndPoint(uniqueName) + '&id=' + recordId;
        
        system.debug('---STEP1---uniqueName:---' + uniqueName);
        system.debug('---STEP1---congaURL:---'+congaURL);
        
        List<Id> templateIds = new List<Id>();
        
        for(Template temp :templates){
            if(temp.selected){
                Map<String, APXTConga4__Conga_Merge_Query__c> congaQueries = new Map<String, APXTConga4__Conga_Merge_Query__c>();
                
                Map<String, String> queries = new Map<String, String>();
                Map<String, String> whereClauses = new Map<String, String>();
                
                for(TemplateChildObject tc :temp.childObjects){
                    SelectedChildObject sc = selectedChildObjects.get(tc.name);
                    ChildObject co = sc.childObject;
                    
                    if(!queries.containsKey(tc.queryName)){
                        String query = '';
                        for(Field fld :co.fields){
                            if(String.isEmpty(query)){
                                query += fld.name;
                            } else {
                                query += ',' + fld.name;
                            }
                        }
                        queries.put(tc.queryName, 'SELECT ' + query + ' FROM ' + co.name);
                    }
                    String whereClause = co.relationField + ' = \'' + recordId + '\' AND Id IN(\''+ String.join(sc.getRecordIds(), '\',\'') +'\')';
                    
                    if(whereClauses.containsKey(tc.queryName)){
                        whereClauses.put(tc.queryName, whereClauses.get(tc.queryName) + ' OR (' + whereClause + ')'); 
                    } else {
                        whereClauses.put(tc.queryName, ' (' + whereClause + ')'); 
                    }
                }
                
                for(String name :queries.keySet()){
                    congaQueries.put(name, new APXTConga4__Conga_Merge_Query__c(
                        APXTConga4__Name__c = name + ' - ' + recordId + ' - ' + UserInfo.getUserId(),
                        APXTConga4__Query__c = queries.get(name) + ' WHERE ' + whereClauses.get(name)
                    ));
                }
                
                String queryId = '';
                if(!congaQueries.isEmpty()){
                    insert congaQueries.values();
                    for(String name :congaQueries.keySet()){
                        if(!String.isEmpty(queryId)){
                            queryId += ',';
                        } 
                        queryId += '[' + name + ']' + congaQueries.get(name).Id;
                    }
                } 
                congaURL += '&QueryId=' + (String.isEmpty(queryId) ? '' : queryId + ',');
                
                APXTConga4__Conga_Merge_Query__c[] mergeQueries = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c =: 'Document Sensitivity'];
                if(!mergeQueries.isEmpty()){
                    congaURL += '[Sensitivity]' + mergeQueries.get(0).Id + '?pv0=' + objectName;
                }
                
                templateIds.add(temp.id);
            }
        }
        
        if(!selectedDocumentTypes.isEmpty()){
            Map<String, APXTConga4__Conga_Template__c> templates = new Map<String, APXTConga4__Conga_Template__c>();
            
            for(SelectedChildObject sc :selectedDocumentTypes.values()){
                for(Record rec :sc.getRecords()){
                    templates.put(rec.values.get('Id'), new APXTConga4__Conga_Template__c(APXTConga4__Name__c = rec.values.get(sc.documentType.nameField), APXTConga4__Template_Group__c = uniqueName));
                }
            }
            insert templates.values(); 
            
            List<SObject> records = new List<SObject>();
            for(SelectedChildObject sc :selectedDocumentTypes.values()){
                for(Record rec :sc.getRecords()){
                    String templateId = templates.get(rec.values.get('Id')).Id;
                    SObject record = rec.getSObject();
                    
                    record.put('Id', null);
                    record.put(sc.documentType.relationField, templateId);
                    records.add(record);
                    
                    templateIds.add(templateId);
                }
            }
            insert records;
        }
        congaURL += '&TemplateId=' + String.join(templateIds, ',');
        congaFrameURL = congaURL;
    }
    
    /*------------------------------------------------------------
    Author:        Sumit Gupta
    Company:       
    Description:   return the conga composer endpoint to process the document rendering
    History
    <Date>          <Authors Name>        <Brief Description of Change>
    23/Nov/2016       Sumit Gupta           Last modified date
    11/Apr/2017    Christian Jed Canlas     Added comments and headers
    ------------------------------------------------------------*/ 
    private String getCongoEndPoint(String uniqueName){
        String partnerURL = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/services/Soap/u/36.0/'+ UserInfo.getOrganizationId();
        return 'https://composer.congamerge.com'+ '?sessionid='+UserInfo.getSessionId() + '&serverUrl=' + partnerURL + '&DefaultPDF=1&APDF=1&UF0=1&OFN=' + uniqueName + '&MFTS1=Details__c&MFTSValue1=Done';
        //return null;
    }
    
    //method to perform printing of document
    public void print(){
        step = '5';
        renderedFileName = objectName + ' - ' + recordId;
        renderingService = 'PDF';
    }
}