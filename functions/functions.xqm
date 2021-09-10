module namespace funct = "funct";

import module namespace getData = "getData" at "getData.xqm";
import module namespace config = "app/config" at "../functions/config.xqm";

declare function funct:log( $fileName, $data, $params ) {
  switch ( $params?mode )
  case 'rewrite'
    return
      file:write-text(
           funct:param( 'logDir' ) || $fileName,
            string-join( ( current-dateTime() || '--' || $data, '&#xD;&#xA;' ) )
         )
    case 'add'
    return
      file:append-text(
           funct:param( 'logDir' ) || $fileName,
            string-join( ( current-dateTime() || '--' || $data, '&#xD;&#xA;' ) )
         )
   default 
     return
     file:append-text(
         funct:param( 'logDir' ) || $fileName,
          string-join( ( current-dateTime() || '--' || $data, '&#xD;&#xA;' ) )
       )
       
};

declare function funct:log ( $fileName, $data ) {
  funct:log( $fileName, $data, map{ 'mode' : 'add' } )
};

declare function funct:param ( $param ) {
   doc( "../config.xml" )/config/param[ @id = $param ]/text()
};

declare function funct:replace( $string, $map ){
  fold-left(
        map:for-each( $map, function( $key, $value ){ map{ $key : $value } } ),
        $string, 
        function( $string, $d ){
           replace(
            $string,
            "\{\{" || map:keys( $d )[ 1 ] || "\}\}",
            replace( serialize( map:get( $d, map:keys( $d )[ 1 ] ) ), '\\', '\\\\' ) (: проблема \ в заменяемой строке :)
          ) 
        }
      )
};

declare function funct:xhtml( $app as xs:string, $map as item(), $componentPath ){
  let $appAlias := if( contains( $app, "/") ) then( tokenize( $app, "/" )[ last()] ) else( $app )
  let $string := 
    file:read-text(
      file:base-dir() || $componentPath ||  '/' || $app || "/"  || $appAlias || ".html"
    )
  
  return
    parse-xml(
      funct:replace( $string, $map )
    )
};

declare function funct:tpl( $app, $params ){
  let $componentPath := '../components'
  let $queryTpl := '
    import module namespace {{appAlias}} = "{{app}}" at "{{rootPath}}/{{app}}/{{appAlias}}.xqm";  
    declare variable $params external;
    {{appAlias}}:main( $params )'
  
  let $appAlias := 
    if( contains( $app, "/") ) then( tokenize( $app, "/")[ last() ] )  else( $app )
  
  let $query := 
    funct:replace(
      $queryTpl,
      map{
        'rootPath' : $componentPath,
        'app' : $app,
        'appAlias' : $appAlias
      }
    )
  
  let $tpl := function( $app, $params ){ funct:tpl( $app, $params ) }
  let $config := function( $param ){ $config:param( $param ) }
  let $getFile := function( $path,$xq ){ funct:getFile( $path, $xq ) }
  
  let $result :=
    prof:track( 
      xquery:eval(
          $query, 
          map{ 'params':
            map:merge( 
              ( $params, map{ '_tpl' : $tpl, '_data' : $getData:funct, '_config' : $config:param, '_getFile' : $getFile } )
            )
          }
        ),
      map { 'time': true() }
      )
  (:
    let $log :=
    funct:log(
      'profiling.log',
      $app || '--' || $result?time,
      map{ 'mode' : 'add
      ' }
    )
  
  :)
  
  return
     funct:xhtml( $app, $result?value, $componentPath )
};


declare
  %public
function funct:getFile(  $fileName, $xq, $storeID, $access_token ){
 let $href := 
   web:create-url(
     $config:param( "api.method.getData" ) || 'stores/' ||  $storeID,
     map{
       'access_token' : $access_token,
       'path' : $fileName,
       'xq' : $xq
     }
   )
 return
   try{
     fetch:xml( $href )
   }catch*{
     try{ fetch:text( $href ) }catch*{}
   }
};


declare
  %public
function funct:getFile( $fileName, $xq, $storeLabel as xs:string ){
  funct:getFile(
    $fileName,
    $xq,
    $config:param( $storeLabel ), 
    session:get( 'access_token' )
  )
};

declare
  %public
function funct:getFile( $fileName, $xq ){
  funct:getFile(
    $fileName,
    $xq,
    $config:param( "store.yandex.jornal" ), 
    session:get( 'access_token' )
  )
};

declare
  %public
function funct:getFile( $fileName ){
  funct:getFile(
    $fileName,
    '.',
    $config:param( "store.yandex.jornal" ), 
    session:get( 'access_token' )
  )
};


declare
  %public
function funct:getFileWithParams(  $fileName, $xq, $params as map(*), $access_token ){
 let $href := 
   web:create-url(
     $config:param( "api.method.getData" ) || 'stores/' ||  $config:param( "store.yandex.jornal" ),
     map:merge(
       (
         $params,
         map{
           'access_token' : $access_token,
           'path' : $fileName,
           'xq' : $xq
         }
       )
     )
   )
 return
   try{
     fetch:xml( $href )
   }catch*{
     try{ fetch:text( $href ) }catch*{}
   }
};

declare
  %public
function funct:getFileWithParams(  $fileName, $xq, $params as map(*) ){
  funct:getFileWithParams( $fileName, $xq, $params, session:get( 'access_token' ) )
};