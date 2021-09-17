module namespace check = "check";

import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session";

declare 
  %perm:check( "/simplex" )
function check:userArea(){
 let $token := request:cookie( 'ivgpu_auth' )
 return
   if( $token and not( session:get( 'login' ) ) )
   then(
      let $login := 
        let $t :=
          convert:binary-to-string(
            xs:base64Binary(
              tokenize( $token, '\.' )[ 2 ] || '=' 
            )
          )
        return
         json:parse( $t )
      
      let $кафедра :=
        let $пользователи := 
            csv:parse(  
              fetch:text(
                'https://docs.google.com/spreadsheets/d/e/2PACX-1vSG_nG0Rfo3iJndyRD3WKPrukd4gNR1FYP0MVu6ddveIGNRkKX21vdUp6D0P4rMxJBVwgWLW35y-Lr7/pub?gid=1161096430&amp;single=true&amp;output=csv'
            ), map{ 'header' : true() } )/csv/record
        return
          $пользователи[ email/text() = $login/json/email/text() ]/Кафедра/text()
      
      let $пользователь := 
        if( $login )then( $login/json/email/text() )else( 'unknown' )
      
      return
        (
          session:set( 'login', $пользователь ),
          session:set( 'department', $кафедра ),
          session:set( 'userName', $login/json/last_name/text() )
        )
     )
     else()
};