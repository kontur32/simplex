module namespace saivpds = "saivpds/graduation/groups";

import module namespace funct="funct" at "../functions/functions.xqm";

declare 
  %rest:GET
  %rest:path( "/simplex/graduation/groups" )
  %output:method( "xhtml" )
  %output:doctype-public( "www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" )
function saivpds:main(){
    
    let $params :=    
       map{
        'header' : funct:tpl( 'header', map{ 'area' : 'teacher' } ),
        'content' : funct:tpl( 'content/graduation/groups-list', map{} ),
        'footer' : funct:tpl( 'footer', map{} )
      }
    return
      funct:tpl( 'main', $params )
};