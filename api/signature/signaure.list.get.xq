module  namespace ivgpu = '/sandbox/ivgpu/signature/get/list';

import module namespace request = 'http://exquery.org/ns/request';

import module namespace 
  bitrix.disk = 'bitrix.disk' 
    at '../../../sandbox.ivgpu/modules/bitrix.disk.xqm';

import module namespace 
  signature = 'simplex/signature' 
    at '../../../sandbox.ivgpu/modules/signature.xqm';

declare variable  $ivgpu:путьХранилищаПодписей := 
  'Дела учебные по кафедре ЭУФ/simplex/хранилища/цифровые подписи/';

declare variable  $ivgpu:секрет  := 'secret key';
     
declare
  %rest:path( '/simplex/api/v01/signature/list.get' )
  %rest:query-param( "path", "{ $полноеИмяФайла }",  "" )
  %output:method( 'text' )
function ivgpu:main( $полноеИмяФайла as xs:string ){
  let $путьПодписи := 
    $ivgpu:путьХранилищаПодписей || string( xs:hexBinary( hash:sha256( $полноеИмяФайла ) ) )
  let $подписи :=
      bitrix.disk:getFileList( bitrix.disk:getFolderID( $путьПодписи ), map{ 'name' : '.sig$'} )
  let $субъекты :=
   signature:найтиПодписиОбъекта(
      $полноеИмяФайла,
      $ivgpu:секрет,
      $ivgpu:путьХранилищаПодписей
    )
  return
    string-join( $субъекты, ',')
};