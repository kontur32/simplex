module namespace content = 'content/graduation/students-list';

import module namespace 
  bitrix.disk = 'bitrix.disk' 
    at '../../../../../sandbox.ivgpu/modules/bitrix.disk.xqm';

declare variable $content:folderID := '428956';

declare function content:main( $params ){
    let $год := request:parameter( 'year' )
    let $номерГруппы := request:parameter( 'group' )
    let $кафедра := request:parameter( 'dep' )
   
    return
    
    map{
      'год' :$год,
      'номерГруппы' : $номерГруппы,
      'кафедра' : $кафедра,
      'списокСтудентов' : content:списокСтудентов( $год, $номерГруппы )
    }
};

declare function content:списокСтудентов( $год, $номерГруппы ){
  let $сотрудники :=
    csv:parse(
      fetch:text(
        'https://docs.google.com/spreadsheets/d/e/2PACX-1vROdb3IiQ7EkWEIvZ6bAPp9c4-a0j-MrbC8f8pMRQS8BFl3c81gvGoJTpokCD0BRzn7yvfKgmhAmbII/pub?gid=868243229&amp;single=true&amp;output=csv'
      ), map{ 'header' : 'yes'}
    )
    /csv/record
  
  let $группа := 
    bitrix.disk:getFileXLSX( '428956', map{ 'recursive' : 'yes', 'name' : $номерГруппы || '.*xlsx$' } )
  
  let $списокСтудентов :=
    <table class = "table">
      <tr>
        <td>№ пп</td>
        <td>Студент</td>
        <td>Тема ВКР</td>
        <td>Руководитель</td>
      </tr>
      {
        for $i in $группа/file/table[ 1 ]/row
        count $c
        let $href-титулПрактика := 
          '/sandbox/ivgpu/generate/титул/преддипломная/' ||
          $номерГруппы || '/' ||
          $i/cell[ @label = "Студент" ]/text()
        let $href-титулВКР := 
          '/sandbox/ivgpu/generate/титул/ВКР/' ||
          $номерГруппы || '/' ||
          $i/cell[ @label = "Студент" ]/text()
        let $руководитель := 
              $сотрудники[ Фамилия = substring-before( $i/cell[ @label = "ФИО руководителя ВКР" ]/text(), ' ') ][ 1 ]
        let $учанаяСтепеньРуководителя := 
          if( $руководитель/Степень != "" )
          then( $руководитель/Степень || ", ")
          else()
        let $учаноеЗваниеРуководителя := 
          if( $руководитель/Звание != "" )
          then( $руководитель/Звание || ", ")
          else()
        let $ссылкаНаПроект :=
          if( $i/cell[ @label = 'Проект']/text() )
          then( <b >(<a href = "{ $i/cell[ @label = 'Проект']/text() }">описание проекта</a>)</b> )
          else()
        let $стартап :=
          if( $i/cell[ @label = 'Стартап']/text() = 'да' )
          then( <b>Диплом как стартап<br/></b> )
          else()
        return
           <tr>
            <td>{ $c }.</td>
            <td>{ $i/cell[ @label = "Студент" ]/text() }</td>
            <td>
              { $стартап }
              { $i/cell[ @label = "Тема ВКР" ]/text() }
              { $ссылкаНаПроект }
            </td>
            <td>{
               $руководитель/ФИО || ', ' || 
               $учанаяСтепеньРуководителя || 
               $учаноеЗваниеРуководителя || 
               $руководитель/Должность 
            }</td>
            <td><a href = "{ $href-титулПрактика }" class="btn btn-primary">Титул отчета по практике</a></td>
            <td><a href = "{ $href-титулВКР }" class="btn btn-primary">Титул ВКР</a></td>
          </tr>
      }
    </table>
  return
    $списокСтудентов
};