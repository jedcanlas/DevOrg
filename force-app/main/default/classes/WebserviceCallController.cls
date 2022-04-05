public class WebserviceCallController{
    
    public string strEndpoint{get;set;}
    public string strResponse{get;set;}
    
    public WebserviceCallController(){
        string strEndpoint = 'http://api.acmecorp.com:8888/InvoiceService/list';
    }

  // Pass in the endpoint to be used using the string url
  public Pagereference getCalloutResponseContents() {
    
    string strEndpoint = 'http://api.acmecorp.com:8888/InvoiceService/list';
    string strEndpoint2 = 'https://test.salesforce.com/services/Soap/c/31.0/00D280000011cS6EAI';
    
    
    // https://test.salesforce.com/services/Soap/c/31.0/00D280000011cS6EAI
    
    // Instantiate a new http object
    Http h = new Http();

     // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint(strEndpoint2);
    req.setMethod('GET');

    // Send the request, and return a response
    HttpResponse res = h.send(req);
    strResponse = string.valueOf(res.getBody());
    return null;
  }

}