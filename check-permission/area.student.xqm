module namespace check = "check";


declare 
  %perm:check( "/saivpds/s" )
function check:userArea(){
 let $grants := session:get( "grants" )
  where  not( $grants = 'student' )
  return
    web:redirect("/saivpds")
};