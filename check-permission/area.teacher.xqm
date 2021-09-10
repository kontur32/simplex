module namespace check = "check";


declare 
  %perm:check( "/saivpds/t" )
function check:userArea(){
  let $grants := session:get( "grants" )
  where  not( $grants = 'teacher' )
  return
    web:redirect("/saivpds")
};