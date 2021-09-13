module namespace simplex = "simplex/graduation/groups";

import module namespace funct="funct" at "../functions/functions.xqm";

declare 
  %rest:GET
  %rest:path( "/simplex/graduation/students" )
  %output:method( "xhtml" )
  %output:doctype-public( "www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" )
function simplex:main(){
    
    let $params :=    
       map{
        'header' : funct:tpl( 'header', map{ } ),
        'content' : funct:tpl( 'content/graduation/students-list', map{} ),
        'footer' : funct:tpl( 'footer', map{} )
      }
    return
      funct:tpl( 'main', $params )
};