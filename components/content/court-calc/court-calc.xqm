module namespace court-calc = 'content/court-calc';

import module namespace functx = "http://www.functx.com";
import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function court-calc:main($params){
  let $rawData :=
    if($params?file instance of map(*))
    then(map:get($params?file, map:keys($params?file)[1]))
    else()
  
  let $результат :=
     if($rawData instance of xs:base64Binary)
     then(
       let $расчет := court-calc:summ($rawData)
       let $hash := random:uuid()
       let $fileName := 'court-calc-' || $hash || '-' ||'outpu.docx'
       let $форма :=
         court-calc:fillTemplate(
           fetch:binary("http://dbx.iro37.ru/zapolnititul/api/v2/forms/541baf4f-6367-4513-8fdc-4e520d466481/template"),
           court-calc:output-trci($расчет)
         )
       let $save := file:write-binary(file:temp-dir() || '/' || $fileName, $форма)
       return
         map{
            'содержание' : 
              <table class="table">
                <tr>
                 <th>Год</th>
                 <th>Месяц</th>
                 <th>Сумма в пользовании, руб.</th>
                 <th>Индекс цен, %</th>
                 <th>Дней в пользовании</th>
                 <th>Сумма за месяц, руб.</th>
               </tr>
               {court-calc:output-table($расчет)}
             </table>,
            'ссылка': <a href="/simplex/api/v0.1/files/temp/court-calc/{$fileName}" class="btn btn-primary mb-2">скачать расчет</a>
          }
     )
     else(
       map{
         'ссылка':'',
         'содержание':''
       }
     )
  return
    $результат
};


declare function court-calc:trci($rawData){
  let $endPoint := "http://localhost:8984/ooxml/api/v1.1/xlsx/parse/workbook"
  let $request := 
    <http:request method='POST'>
      <http:header name="Content-type" value="multipart/form-data"/>
      <http:multipart media-type = "multipart/form-data">
        <http:header name='Content-Disposition' value='form-data; name="data"'/>
        <http:body media-type = "application/octet-stream">{$rawData}</http:body>
      </http:multipart> 
      </http:request>
  let $response := http:send-request($request, $endPoint)
  return
   $response[ 2 ]
};

declare function court-calc:proc($proc as element(table)){
  for $p in $proc/row
  return
    map{
      "Год":$p/cell[@label="Год"]/text(),
      "Месяц":$p/cell[@label="Месяц"]/text(),
      "индексЦен":$p/cell[@label="Проценты"]/text()
    }
};

declare function court-calc:days($s, $e){ 
  let $d := functx:last-day-of-month($s)-$s
  let $next := $s+$d+functx:dayTimeDuration(1,0,0,0)
  let $days := 
    if($next < $e)
    then(days-from-duration($d)+1)
    else(days-from-duration($e - $s)+1)
  return
    (
      map{
        "Год":year-from-date($s),
        "Месяц":month-from-date($s),
        "Дней":$days,
        "днейВМесяце":functx:days-in-month($s)
      },
      if($next < $e)then(court-calc:days($next, $e))else()
    )
};

declare function court-calc:summ($rawData) as map(*)* {
  let $данные := court-calc:trci($rawData)
  let $индексыЦен := $данные//table[@label="Индекс цен"]
  let $платежи := $данные//table[@label="Данные"]/row
  
  for $заПериод in $платежи
  let $sum := $заПериод/cell[@label="Сумма на начало"]/text()
  let $startDate := dateTime:dateParse($заПериод/cell[@label="Начальная"]/text())
  let $endDate := dateTime:dateParse($заПериод/cell[@label="Конечная"]/text())
  
  let $суммаПоМесяцам := 
    for $i in court-calc:days($startDate, $endDate)
    let $индексЦен := 
      court-calc:proc($индексыЦен)[?Год=$i?Год and ?Месяц=$i?Месяц]?индексЦен div 100 - 1
    let $суммаЗаМесяц := ($i?Дней div $i?днейВМесяце) * $индексЦен * $sum
    return
      map{
      "Год":$i?Год,
      "Месяц":$i?Месяц,
      "Дней":$i?Дней,
      "индексЦен":$индексЦен * 100,
      "суммаВПользовании":$sum,
      "суммаЗаМесяц":$суммаЗаМесяц
    }
  return
    $суммаПоМесяцам
  
};

declare function court-calc:output-table($расчет){
  let $поМесяцам :=  
      for $i in $расчет
      return
         <tr>
           <td>{$i?Год}</td>
           <td>{$i?Месяц}</td>
           <td>{round($i?суммаВПользовании, 2)}</td>
           <td>{round($i?индексЦен, 2)}</td>
           <td>{$i?Дней}</td>
           <td>{round($i?суммаЗаМесяц, 2)}</td>
         </tr>
  let $суммаВсего := sum($расчет?суммаЗаМесяц)
  return
     (
       $поМесяцам,
       <tr>
         <td colspan="5">Всего</td>
         <td><b>{round($суммаВсего, 2)}</b></td>
       </tr>
     )
};

declare function court-calc:output-trci($расчет){
  <table>
    <row id='tables'>
      <cell id="Таблица">
        <table>
          {
            for $i in $расчет
            return
             <row>
               <cell>{$i?Год}</cell>
               <cell>{$i?Месяц}</cell>
               <cell>{round($i?суммаВПользовании, 2)}</cell>
               <cell>{round($i?индексЦен, 2)}</cell>
               <cell>{$i?Дней}</cell>
               <cell>{round($i?суммаЗаМесяц, 2)}</cell>
             </row>
          }
          <row>
            <cell>Всего</cell>
            <cell></cell>
            <cell></cell>
            <cell></cell>
            <cell></cell>
            <cell>{round(sum($расчет?суммаЗаМесяц), 2)}</cell>
          </row>
        </table>
      </cell>
    </row>
  </table>
};

declare function court-calc:fillTemplate($template, $data){
 let $request :=
    <http:request method='post'>
      <http:multipart media-type = "multipart/form-data" >
        <http:header name="Content-Disposition" value= 'form-data; name="template";'/>
        <http:body media-type = "application/octet-stream">{$template}</http:body>
        <http:header name="Content-Disposition" value= 'form-data; name="data";'/>
        <http:body media-type = "application/xml">{$data}</http:body>
      </http:multipart> 
    </http:request> 
  let $fileName := iri-to-uri('file.docx')  
  let $ContentDispositionValue := "attachment; filename=" || $fileName
  let $response := 
    http:send-request (
      $request,
      'http://localhost:8984' || '/api/v1/ooxml/docx/template/complete'
    )
  return 
      $response[2]
};