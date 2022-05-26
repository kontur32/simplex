module namespace inkwi = "simplex";

import module namespace funct="funct" at "../functions/functions.xqm";

declare 
  %rest:GET
  %rest:path( "/simplex" )
  %output:method( "html" )
  %output:doctype-public( "www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" )
function inkwi:main(){
  let $params :=    
     map{
      'header' : funct:tpl('header', map{'area' : 'teacher'}),
      'content' : funct:tpl('content/start', map{}),
      'footer' : funct:tpl('footer', map{})
    }
  return
    funct:tpl('main', $params)
};

 