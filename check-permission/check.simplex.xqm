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
         json:parse( $t )/json
      
      let $кафедра :=
        let $пользователи := 
            csv:parse(  
              fetch:text(
                'https://docs.google.com/spreadsheets/d/e/2PACX-1vSG_nG0Rfo3iJndyRD3WKPrukd4gNR1FYP0MVu6ddveIGNRkKX21vdUp6D0P4rMxJBVwgWLW35y-Lr7/pub?gid=1161096430&amp;single=true&amp;output=csv'
            ), map{ 'header' : true() } )/csv/record
        return
          $пользователи[ email/text() = $login/email/text() ]/Кафедра/text()
      
      let $пользователь := 
        if( $login )then( $login/email/text() )else( 'unknown' )
      
      let $userName := 
        if( $login/last__name/text() )
        then(
          $login/last__name/text() || ' ' ||
          substring( $login/first__name/text(), 1, 1 ) || '.' ||
          substring( $login/middle__name/text(), 1, 1 ) || '.'
        )
        else( 'John Doe' )
      return
        (
          session:set( 'login', $пользователь ),
          session:set( 'department', $кафедра ),
          session:set( 'userName', $userName )
        )
     )
     else()
};