module namespace login = "login";

import module namespace config = "app/config" at '../functions/config.xqm';

declare 
  %rest:GET
  %rest:query-param( "redirect", "{ $redirect }", "https://sm2.ivgpu.com/simplex" )
  %rest:path( "/simplex/api/v01/login" )
function login:main( $redirect  ){
  web:redirect( $redirect )
};