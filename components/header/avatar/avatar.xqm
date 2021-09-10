module namespace avatar = "header/avatar";


declare function avatar:main( $params as map(*) ){
  
  let $userLabel :=
    if( session:get('роль') )
    then( session:get('роль') )
    else( 'Гость' )
    
  return
    map{
      "userLabel" : $userLabel,
      "userAvatarURL" : $params?_config( 'defaultAvatarURL' )
    }
};