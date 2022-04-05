public with sharing class renderingPageController{

public boolean renderb1{get;set;}
public boolean renderb2{get;set;}
public List<Account> accList{get;set;}
public List<Contact> conList{get;set;}

public renderingPageController(){
    renderb1 = true;
    renderb2 = false;
}


public pagereference renderb2(){
    renderb1 = false;
    renderb2 = true;
    accList = [select id,name from Account limit 5];
    return null;
}

public pagereference renderb1(){
    renderb1 = true;
    renderb2 = false;
    conList = [select id,firstname from contact limit 5];
    return null;
}

}