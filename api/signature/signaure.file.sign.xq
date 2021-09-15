module  namespace ivgpu = '/sandbox/ivgpu/signature/file/sign';

import module namespace request = 'http://exquery.org/ns/request';

import module namespace 
  bitrix.disk = 'bitrix.disk' 
    at '../../../sandbox.ivgpu/modules/bitrix.disk.xqm';

import module namespace 
  signature = 'simplex/signature' 
    at '../../../sandbox.ivgpu/modules/signature.xqm';

declare variable  $ivgpu:путьХранилищаПодписей := 
  'Дела учебные по кафедре ЭУФ/simplex/хранилища/цифровые подписи/';

declare variable  $ivgpu:секрет := 'secret key';
     
declare
  %rest:path( '/simplex/api/v01/signature/file.sign' )
  %rest:query-param( "path", "{ $полноеИмяФайла }",  "" )
  %rest:query-param( "redirect", "{ $redirect }",  "" )
function ivgpu:main( $полноеИмяФайла as xs:string, $redirect ){
  let $result :=
    if( session:get( 'login' ) )
    then(
      signature:подписатьФайл(
        $полноеИмяФайла,
        session:get( 'login' ),
        $ivgpu:секрет,
        $ivgpu:путьХранилищаПодписей
      )
    )
    else(
      signature:подписатьФайл(
        $полноеИмяФайла,
        'kontur32@yandex.ru',
        $ivgpu:секрет,
        $ivgpu:путьХранилищаПодписей
      )
    )
  return
    web:redirect( request:scheme() || '://' || request:hostname() || $redirect )
};