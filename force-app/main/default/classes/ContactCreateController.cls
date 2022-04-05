public with sharing class ContactCreateController {

  // the contact record you are adding values to
  public Contact contact {
    get {
      if (contact == null)
        contact = new Contact();
      return contact;
    }
    set;
  }

  public ContactCreateController() {
    // blank constructor
  }

  // save button is clicked
  public PageReference save() {

    try {
      //insert contact; // inserts the new record into the database
      List<Contact> conList = new List<Contact>();
      Contact tempCon = new Contact();
      tempCon = contact;
      conList.add(tempCon );
      Savepoint sp = Database.setSavepoint();
      Database.SaveResult[] saveResultList = Database.insert(conList, false);
      for(Database.SaveResult res : saveResultList){
          //if(!res.isSuccess()){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,string.valueOf(res)));
          //}else{
          //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'SUCCESS'));
          //}
      }
      Database.rollback(sp);
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,string.valueOf(e)));
      return null;
    }

    // if successfully inserted new contact, then displays the thank you page.
    //return Page.Contact_Create_Thankyou;
    return null;
  }

}