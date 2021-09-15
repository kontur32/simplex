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
  
  let $спискиГрупп := 
    bitrix.disk:getFileList( $content:folderID, map{ 'recursive' : 'yes', 'name' : '.xlsx$' } )
  let $группыЗагруженные := 
    $спискиГрупп
    /NAME/substring-before( text(), '.' )[ matches( ., '-[0-9]{2}' ) ]
    
 
  let $списокГрупп :=
      <table class = "table">
      <tr>
        <th>Группа</th>
        <th>Наличие ЭЦП</th>
        <th></th>
        <th></th>
      </tr>
      {
        for $i in $группы/file/table[ 1 ]/row
        let $номерГруппы := $i/cell[ @label = "Группа" ]/text()
        let $подписи :=
          if( $номерГруппы = $группыЗагруженные )
          then(
            fetch:text(
              web:create-url(
                'http://localhost:8984/simplex/api/v01/signature/list.get', 
                map{
                  'path' : 'Дела учебные по кафедре ЭУФ/ГИА по ЭУФ/ВКР приказы, нормативка/ВКР 2021/Группы/' || $номерГруппы || '.xlsx'
                }
              )
            )
          )
          else()
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
           if( $подписи )
           then( "btn btn-success" )
           else( "btn btn-info" )
        return
           <tr>
             <td><a href = "{ $href }">{ $номерГруппы }</a></td>
               <td>{
                 if( $подписи )
                 then( '(' || $подписи || ')' )
                 else(
                   if( $номерГруппы = $группыЗагруженные )
                   then(
                     let $hrefSign :=
                       web:create-url(
                         '/simplex/api/v01/signature/file.sign',
                         map{
                           'path' : 'Дела учебные по кафедре ЭУФ/ГИА по ЭУФ/ВКР приказы, нормативка/ВКР 2021/Группы/' || $номерГруппы || '.xlsx',
                           'redirect' : '/simplex/graduation/groups?year=2021&amp;dep=21'
                         }
                       ) 
                     return
                       <a href = "{ $hrefSign }" class = "btn btn-info">Подписать</a>
                   )
                   else()
                 )
               }</td>
             <td>
               {
                 if( $номерГруппы = $группыЗагруженные )
                 then(
                   <a href = "{ $hrefСлужебка }" class="{ $кнопка }">Скачать служебку на темы</a>
                 )
                 else()
               }</td>
             <td>
               {
                 if( $номерГруппы = $группыЗагруженные )
                 then(
                   let $hrefПравка :=
                     $спискиГрупп
                     [ NAME [ matches( text(), $номерГруппы ) ] ]/DETAIL__URL/text()
                   return  
                     <a href = "{ $hrefПравка }" >Править темы</a>
                 )
                 else()
               }</td>
           </tr>
      }
      </table>
  return
    $списокГрупп
};