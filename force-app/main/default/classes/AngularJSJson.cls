public with sharing class AngularJSJson {
  
        /**
         * Webkul Software.
         *
         * @category  Webkul
         * @author    Webkul
         * @copyright Copyright (c) 2010-2016 Webkul Software Private Limited (https://webkul.com)
         * @license   https://store.webkul.com/license.html
         */
 
 public static String getContacts() {
       return JSON.serialize([select id, name, email
           from contact ]);
   }
}