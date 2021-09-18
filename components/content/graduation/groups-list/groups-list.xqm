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
      'списокВыпускныхГрупп' : content:списокГрупп( $год, $кафедра, $params )
    }
};

declare function content:списокГрупп( $год, $кафедра, $params ){
  let $user := session:get( 'login' )    
  let $путьФайлы := 
    'Дела учебные по кафедре ЭУФ/ГИА по ЭУФ/ВКР приказы, нормативка/ВКР 2021/'
  
  let $идентификаторПапкиКорня := 
    bitrix.disk:getFolderID( $путьФайлы )
  let $группы := 
    bitrix.disk:getFileXLSX( $идентификаторПапкиКорня, map{ 'recursive' : 'yes', 'name' : 'Список групп.xlsx' } )
  
  let $идентификаторПапкиСписковГрупп := 
    bitrix.disk:getFolderID( $путьФайлы || 'Группы' )
  let $группыЗагруженные := 
    bitrix.disk:getFileList( $идентификаторПапкиСписковГрупп, map{ 'name' : '.xlsx$' } )
    [ NAME/substring-before( text(), '.' )[ matches( ., '-[0-9]{2}' ) ] ]
  
  
  let $ресурсы := 
    bitrix.disk:getFileXLSX( 
      $идентификаторПапкиКорня,
      map{ 'name' : '_Ресурсы.xlsx' }
    )/file/table[ 1 ]/row 
  let $пользователи := 
   bitrix.disk:getFileXLSX(
     bitrix.disk:getFolderID( 'Дела учебные по кафедре ЭУФ/simplex/' ), 
     map{ 'name' : 'Пользователи.xlsx' }
   )/file/table[ 1 ]/row
   
  let $списокГрупп :=
      <table class = "table">
      <tr>
        <th>Группа</th>
        <th>Подписал(а)</th>
        <th>Еще не подписал(а)</th>
        <th></th>
        <th></th>
      </tr>
      {
        for $i in $группы/file/table[ 1 ]/row
        let $номерГруппы := $i/cell[ @label = "Группа" ]/text()
        let $ресурс := $путьФайлы || 'Группы/' || $номерГруппы || '.xlsx'
        
        let $субъектыПодписи := 
          $ресурсы[ starts-with( $ресурс, cell[ @label = "Ресурс" ]/text() ) ]
          /cell[ @label = "Субъект" ]
          /tokenize( replace( text(), '\s', '' ), ',' )
        
        let $подписи :=
          if( $номерГруппы = $группыЗагруженные/NAME/substring-before( text(), '.' ) )
          then(
            let $путьПроверкиПодписей :=
              web:create-url(
                $params?_config( 'host' ) || '/simplex/api/v01/signature/list.get', 
                map{ 'path' : $ресурс }
              )
            return
              tokenize( fetch:text( $путьПроверкиПодписей ), ',' )
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
        let $стильКнопки := 
           if( empty( distinct-values( $субъектыПодписи[ not( .= $подписи ) ] ) ) )
           then( "btn btn-success" )
           else( "btn btn-info" )
        let $кнопкаПодписать :=
          if(
             $номерГруппы || '.xlsx' = $группыЗагруженные/NAME/text() and
             ( ( $user = $субъектыПодписи ) and not ( $user = $подписи ) )
           )
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
               <div><a href = "{ $hrefSign }" class = "btn btn-info">Подписать</a></div>
           )
           else()
        return
           <tr>
             <td><a href = "{ $href }">{ $номерГруппы }</a></td>
             <td>
               {
                 content:пользователи(
                   $пользователи[ cell[ @label = 'Логин' ] = $подписи[ . = $субъектыПодписи ] ]
                 )
               }
               { $кнопкаПодписать }
             </td>
             <td>{
                if( $номерГруппы = $группыЗагруженные/NAME/substring-before( text(), '.' )  )
                then(
                  content:пользователи(
                   $пользователи[ cell[ @label = 'Логин' ] = distinct-values( $субъектыПодписи[ not( .= $подписи ) ] ) ]
                 )
                )
                else()
              }</td>
             <td>
               {
                 if(  $номерГруппы = $группыЗагруженные/NAME/substring-before( text(), '.' )  )
                 then(
                   <a href = "{ $hrefСлужебка }" class="{ $стильКнопки }">Скачать служебку на темы</a>
                 )
                 else()
               }</td>
             <td>
               {
                 if( $номерГруппы || '.xlsx' = $группыЗагруженные/NAME/text() )
                 then(
                   let $hrefПравка :=
                     $группыЗагруженные
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

declare function content:пользователи( $пользователи ){
  let $список :=
    for $i in $пользователи
    return
     substring( $i/cell[ @label = 'Имя' ]/text() , 1, 1 ) || '. ' ||
     $i/cell[ @label = 'Фамилия' ]/text()
  return
    string-join( $список, ', ')
};