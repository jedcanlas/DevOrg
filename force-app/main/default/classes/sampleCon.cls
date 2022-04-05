/*** Controller: ***/
public class sampleCon {
    String[] countries = new String[]{};

    public PageReference test() {
        return null;
    }

    public List<SelectOption> getItems() {
        
        List<Account> a = [select id,name from Account];
        
        List<SelectOption> options = new List<SelectOption>();
        for(Account aa: a){
            options.add(new SelectOption(aa.Name, aa.Name));
        
        }
        
        

        return options;
    }

    public String[] getCountries() {
        return countries;
    }

    public void setCountries(String[] countries) {
        this.countries = countries;
    }
}