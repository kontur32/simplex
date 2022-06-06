module namespace avatar = "header/avatar";

declare function avatar:main($params as map(*)){
  let $requestParams := 
     map:merge(
       for $i in request:parameter-names()
       let $param := request:parameter($i)
       where not($param instance of map(*))
       return
         map{$i : $param}
     )
     
  let $redirectURL :=
     web:encode-url( 
       web:create-url(request:uri(), $requestParams)
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