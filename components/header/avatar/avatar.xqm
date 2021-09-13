module namespace avatar = "header/avatar";


declare function avatar:main( $params as map(*) ){
  
  let $userLabel :=
    if( session:get( 'userName') )
    then( session:get( 'userName' ) )
    else( 'Гость' )
  let $avatar :=
    if( session:get( 'avatar') )
    then( session:get( 'avatar' ) )
    else( $params?_config( 'defaultAvatarURL' ) ) 
  return
    map{
      "userLabel" : $userLabel,
      "userAvatarURL" : $avatar
    }
};