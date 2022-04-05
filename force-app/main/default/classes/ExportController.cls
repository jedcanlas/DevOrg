public class ExportController {
    
   
    public string header{get;set;}
    public List<wrapper> lstwrapper {get; set;}
    public Boolean isExport {get; set;}
    public class wrapper{
        public string accName {get; set;}
       
    }
   
    public string Filetype{get;set;}
    public string FileName{get;set;}
    public boolean isExcel {get;set;}
    public boolean isCsv {get;set;}   
   
 
 
 
    public PageReference export(){
    //done();
    PageReference pageRef = new PageReference('/apex/ExportToExcelPage'); 
    
    //pageRef.setRedirect(true);
    return pageRef;
    }
    
    //public void done(){
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Success!'));
    //}
    

    public ExportController(){
            Filetype = '';
            FileName = 'Test_Export.xls';
            isExport = false;
            lstwrapper = new List<wrapper>();
            header = 'Name\r\n';                      
    }
 
   
    public void fetchData(){ 
          string queryString = 'Select Id,Name from Account'; 
          List<Account> accList = DataBase.Query(queryString);
          if(accList.size()>0){
              isExport = true;
              for(Account csd :accList){
                  wrapper w = new wrapper();
                  w.accName = csd.name ;
                  lstwrapper.add(w);               
              }             
          }
    }
 
   
 


}