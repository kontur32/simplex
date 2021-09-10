module namespace getData = "getData";

import module namespace config = "app/config" at "config.xqm";
import module namespace funct = "funct" at "functions.xqm";

declare function getData:getTemplateData1( $templateID, $accessToken ){
  getData:getTemplateData( $templateID, $accessToken, map{} )
};

declare function getData:getTemplateData( $templateID, $accessToken, $params as map(*) ){ 
  let $host := $config:param( 'host' )
  let $path := '/zapolnititul/api/v2.1/data/users/' || $config:param( "accessID" ) || '/templates/' || $templateID (: 21 :)
  
  let $uri := web:create-url( $host || $path, $params )
  
  return 
  http:send-request(
    <http:request method='get'
       href= "{ $uri }">
      <http:header name="Authorization" value= '{ "Bearer " || $accessToken }' />
    </http:request>
  )[2]
};

declare function getData:getToken( $host, $username, $password )
{
  let $request := 
    <http:request method='post'>
        <http:multipart media-type = "multipart/form-data" >
            <http:header name="Content-Disposition" value= 'form-data; name="username";'/>
            <http:body media-type = "text/plain" >{ $username }</http:body>
            <http:header name="Content-Disposition" value= 'form-data; name="password";' />
            <http:body media-type = "text/plain">{ $password }</http:body>
        </http:multipart> 
      </http:request>
  
  let $response := 
      http:send-request(
        $request,
        $host || "/wp-json/jwt-auth/v1/token"
    )
    return
      if ( $response[ 1 ]/@status/data() = "200" )
      then(
        $response[ 2 ]//token/text()
      )
      else()
};

declare function getData:userMeta( $token )
{
  let $request := 
  <http:request method='get'>
    <http:header name="Authorization" value= '{ "Bearer " || $token }' />
  </http:request>
  
  let $response := 
      http:send-request(
        $request,
        "http://portal.titul24.ru" || "/wp-json/wp/v2/users/me?context=edit"
    )
    return
      $response[ 2 ]
};

(: ---------------- функции нового механизма ----------------------- :)

declare variable $getData:funct := 
  map{
    'booksList' : $getData:booksList,
    'partsPages' : $getData:partsPages
  };
  
declare variable $getData:booksList := 
  function() as element ( row )* {
      let $booksList := 
            getData:getTemplateData(
            "7fcadd8a-0f0d-44ac-8b40-c65779c56ffe",
            session:get( "accessToken" ), map{}
          )/data/table/row
      return
        $booksList
  };

(: получает данные из API ЗаполниТитул :)
declare
  %private
function getData:dataRequest(
  $book,
  $mode,
  $access_token
){
  let $templateIDs := $config:templateIDs( $book )
  return
    fetch:xml(
        web:create-url(
          'http://localhost:9984/zapolnititul/api/v2.1/data/users/21/uqx/promis.' || $book,
          map{
            'mode' : $mode,
            'partsTemplateID' : $templateIDs?partsTemplateID,
            'pagesTemplateID' : $templateIDs?pagesTemplateID,
            'access_token' : $access_token
          }
        )
      )
};

(: основная фукнция получения данных разделов и странциц :)

declare variable $getData:partsPages := 
  function( $params ) as map(*) {
  let $templateIDs := $config:templateIDs( $params?book ) 
  
  let $mode := 
    if( substring-before( $params?mode, ':' ) = ( 'up', 'down' ) )
    then( $params?mode )
    else( 'self:' || $params?part )
  
  let $data := getData:dataRequest( $params?book, $mode, $params?accessToken )
  
  let $result := 
    switch ( $params?book ) 
    case 'patient'      
      return
        let $partsList := $data/data/row[ @type = "https://schema.org/Patient" ]
        let $currentPart :=
          if( $params?part = $partsList/@id/substring-after( ./data(), "#" ) )
          then( $params?part )
          else( substring-after( $partsList[ 1 ]/@id/data(), "#" ) )
        let $pagesList := 
          $data/data/row[ cell [ @id = "partID" ] = 'http://dbx.iro37.ru/promis/сущности/пациенты#' || $currentPart ]
        let $currentPage := 
          if( $params?page = ( $pagesList/@id/substring-after( ./data(), "#" ), 'passport' ) )
          then( $params?page )
          else( 
            if( count( $pagesList ) >= 1 )
            then( substring-after( $pagesList[ 1 ]/@id/data(), "#" ) )
            else( 'passport' )
          )
        return
          map{
            'partsList' : $partsList,
            'pagesList' : $pagesList,
            'currentPart' : $currentPart,
            'currentPage' : $currentPage,
            'pagesTemplateID' : $templateIDs?pagesTemplateID,
            'partsTemplateID' : $templateIDs?partsTemplateID
          }
    case 'template' 
      return
        let $partsList := 
           $data/data/table[ @templateID = $config:param( "templatesGroupTemplateID" ) ]
            [ position() = ( 1 to 3 ) ]/row (: костыль - править пагинацию в API :)
          
        let $currentPart :=
          if( $params?part = $partsList/@id/substring-after( ./data(), "#" ) )
          then( $params?part )
          else( substring-after( $partsList[ 1 ]/@id/data(), "#" ) )
        
        let $pagesList := 
          for $i in $data/data/table/row[ cell [ @id = "templatePartID" ] = 'http://dbx.iro37.ru/promis/сущности/шаблоны#' || $currentPart ]
          order by lower-case( $i/cell[ @id = 'label' ]/text() )
          return
            $i
        let $currentPage := 
          if( $params?page = ( $pagesList/@id/substring-after( ./data(), "#" ), 'passport' ) )
          then( $params?page )
          else( 
            if( count( $pagesList ) >= 1 )
            then( substring-after( $pagesList[ 1 ]/@id/data(), "#" ) )
            else( 'passport' )
          )  
        return
          map{
            'partsList' : $partsList,
            'pagesList' : $pagesList,
            'currentPart' : $currentPart,
            'currentPage' : $currentPage,
            'pagesTemplateID' : $templateIDs?pagesTemplateID,
            'partsTemplateID' : $templateIDs?partsTemplateID
          }
    case 'price' 
      return
        let $partsList := $data/data/parts/table[ position() = ( 1 to 3 ) ]/row
        let $currentPart := $data/data/currentPartID/text()
        let $pagesList := $data/data/pages/table/row
        let $currentPage := 
          if( $params?page = ( $pagesList/@id/substring-after( ./data(), "#" ), 'passport' ) )
          then( $params?page )
          else( 
            if( count( $pagesList ) >= 1 )
            then( substring-after( $pagesList[ 1 ]/@id/data(), "#" ) )
            else( 'passport' )
          )  
        return
          map{
            'partsList' : $partsList,
            'pagesList' : $pagesList,
            'currentPart' : $currentPart,
            'currentPage' : $currentPage,
            'pagesTemplateID' : $templateIDs?pagesTemplateID,
            'partsTemplateID' : $templateIDs?partsTemplateID
          }
    default 
      return ()
  
  return
    $result
  };