public class renderAsPDFController {

    public List<Account> getAccounts(){
        List<Account> a = new List<Account>();
        a.addAll([select id,name from account]);  
        a.addAll([select id,name from account]);  
        a.addAll([select id,name from account]);  
        return a;
    }
    
}