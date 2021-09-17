module namespace header = "header";

declare function header:main( $params as map(*) ){
   let $requestParams := 
     map:merge(
       for $i in request:parameter-names()
       return
         map{ $i : request:parameter( $i ) }
     )

   let $authURL :=
     'https://accounts.ivgpu.com/login?redirect=' ||
     web:encode-url(
       'https://sm2.ivgpu.com/sandbox/ivgpu/statistic/login?redirect=' ||
       web:encode-url( 
         web:create-url( request:uri(), $requestParams )
       )
     )

  let $p := 
    if( session:get( 'login' ) )
    then(
       map{
          'логотип' : $params?_tpl( 'header/logo', map{} ),
          'mainMenu' : $params?_tpl( 'header/mainMenu', $params  ),
          'avatar' : $params?_tpl( 'header/avatar', map{} )
        } 
    )
    else(
       map{
          'логотип' : $params?_tpl( 'header/logo', map{} ),
          'mainMenu' : $params?_tpl( 'header/mainMenu', $params  ),
          'avatar' : 
            <a href = '{  $authURL }' type="button" class="btn btn-info" >ВОЙТИ</a>
        }
    )
  return
    $p
};