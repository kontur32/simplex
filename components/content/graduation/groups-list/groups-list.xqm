module namespace content = 'content/graduation/groups-list';

import module namespace 
  bitrix.disk = 'bitrix.disk' 
    at '../../../../../sandbox.ivgpu/modules/bitrix.disk.xqm';

declare variable $content:folderID := '428956';

declare function content:main( $params ){
    let $год := request:parameter( 'year' )
    let $кафедра := request:parameter( 'dep' )
   
    return
    
    map{
      'год' : request:parameter( 'year' ),
      'кафедра' : request:parameter( 'dep' ),
      'списокВыпускныхГрупп' : content:списокГрупп( $год, $кафедра )
    }
};

declare function content:списокГрупп( $год, $кафедра ){
  let $группы := 
    bitrix.disk:getFileXLSX( $content:folderID, map{ 'recursive' : 'yes', 'name' : 'Список групп.xlsx' } )
  let $спискиГруппЗагруженные := 
    bitrix.disk:getFileList( $content:folderID, map{ 'recursive' : 'yes', 'name' : '.' } )/NAME/substring-before( text(), '.' )[ matches( ., '-[0-9]{2}' ) ]
  
  let $провекаПодписей := 
    content:провекаПодписей( $content:folderID, '.xlsx$' )
  
  let $списокГрупп :=
      <table class = "table">
      <tr>
        <th>Группа</th>
        <th>Наличие ЭЦП</th>
        <th></th>
      </tr>
      {
        for $i in $группы/file/table[ 1 ]/row
        let $номерГруппы := $i/cell[ @label = "Группа" ]/text()
        let $href := 
          web:create-url(
            '/simplex/graduation/students',
            map{
              'year' : $год,
              'group' : $номерГруппы,
              'dep' : $кафедра
            }
          )
        let $hrefСлужебка := 
          '/sandbox/ivgpu/generate/Служебная/21/ТемыВКР/' || $номерГруппы
        let $кнопка := 
           if( $провекаПодписей[ ?1 = $номерГруппы ]?2 )
           then( "btn btn-success" )
           else( "btn btn-info" )
        return
           <tr>
             <td><a href = "{ $href }">{ $номерГруппы }</a></td>
             
               <td>{
                 if( $провекаПодписей[ ?1 = $номерГруппы ]?2 )
                 then( 'подписана' )
                 else()
               }</td>
             <td>
               {
                 if( $номерГруппы = $спискиГруппЗагруженные )
                 then(
                   <a href = "{ $hrefСлужебка }" class="{ $кнопка }">Скачать служебку на темы</a>
                 )
                 else()
               }</td>
           </tr>
      }
      </table>
  return
    $списокГрупп
};

declare function content:провекаПодписей( $folderID, $mask ){
  let $писокФайлов := 
    bitrix.disk:getFileList(  $folderID, map{ 'recursive' : 'yes', 'name' : $mask } )
  let $списокПодписей := 
    bitrix.disk:getFileList(  $folderID, map{ 'recursive' : 'yes', 'name' : '.sig$' } )
  
   for $i in $писокФайлов
   let $имяФайла := $i/NAME/text()
   let $файл := fetch:binary( $i/DOWNLOAD__URL/text() ) 
   let $имяФайлаПодписи := $имяФайла || '.sig'
   let $путьФайлаПодписи := 
     $списокПодписей[ starts-with( NAME/text(), $имяФайла ) ]/DOWNLOAD__URL/text()
   let $подпись :=
     if( $путьФайлаПодписи )then( fetch:text( $путьФайлаПодписи ) )else()
   return
     [ tokenize( $имяФайла, '\.' )[ 1 ],  $подпись = string( hash:sha256( $файл ) ) ]
};