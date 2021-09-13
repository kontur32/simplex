module namespace avatar = "header/avatar";


declare function avatar:main( $params as map(*) ){
  
  let $userLabel :=
    if( session:get( 'userName') )
    then( session:get( 'userName' ) )
    else( 'Гость' )
    
  return
    map{
      "userLabel" : $userLabel,
      "userAvatarURL" : $params?_config( 'defaultAvatarURL' )
    }
};