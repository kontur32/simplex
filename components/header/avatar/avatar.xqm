module namespace avatar = "header/avatar";

declare function avatar:main( $params as map(*) ){
  let $requestParams := 
     map:merge(
       for $i in request:parameter-names()
       return
         map{ $i : request:parameter( $i ) }
     )
     
  let $redirectURL :=
     web:encode-url( 
       web:create-url( request:uri(), $requestParams )
     )

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
      "userAvatarURL" : $avatar,
      "redirect" : $redirectURL
    }
};