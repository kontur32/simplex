module namespace saivpds = "saivpds/teacher";

import module namespace funct="funct" at "../functions/functions.xqm";

declare 
  %rest:POST
  %rest:GET
  %rest:path("/simplex/court-calc/procenti-za-polzovanie")
  %rest:form-param ("file", "{$file}")
  %output:method("xhtml" )
  %output:doctype-public("www.w3.org/TR/xhtml11/DTD/xhtml11.dtd")
function saivpds:main($file){
    let $f := if($file instance of map(*))then(map{'file':$file})else(map{})
    let $params :=    
       map{
        'content' : funct:tpl('content/court-calc', $f),
        'footer' : funct:tpl('footer', map{}),
        'header' : funct:tpl('header', map{})
      }
    return
      funct:tpl('main', $params)
};

declare 
  %rest:GET
  %rest:path("/simplex/api/v0.1/files/temp/court-calc/{$file}")
function saivpds:main2($file){
  let $ContentDisposition := 
    "attachment; filename=" || iri-to-uri($file)
  return
    (
      <rest:response>
        <http:response status="200">
          <http:header name="Content-Disposition" value="{$ContentDisposition}"/>
          <http:header name="Content-type" value="text"/>
        </http:response>
      </rest:response>,
      file:read-binary(file:temp-dir() || '/' || $file)
    )
};