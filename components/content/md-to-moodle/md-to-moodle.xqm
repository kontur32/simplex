module namespace md-to-moodle = 'content/md-to-moodle';

declare function md-to-moodle:main($params){
  let $mdText := if($params?file)then($params?file)else('')
  let $html := md-to-moodle:renderMd(map{"текст":$mdText})/body/ol/li
  let $quiz := md-to-moodle:quiz(map{"вопросы":$html})
  let $hash := random:uuid()
  let $fileName := 'quiz-' || $hash ||'.xml'
  let $save := file:write( file:temp-dir() || '/' || $fileName, $quiz)
  let $ссылка :=
     if($params?file)
     then(
       <a href="/simplex/api/v0.1/files/temp/{$fileName}" class="btn btn-primary mb-2">скачать тест</a>
     )
     else('')
  return
    map{
      'содержание' : <ol>{$html}</ol>,
      'ссылка': $ссылка
    }
};

declare
  %private
function md-to-moodle:renderMd($params as map(*)) as element(html)*{
  html:parse(
  http:send-request(
      <http:request method='post'>
        <http:multipart media-type = "multipart/form-data" >
            <http:header name="Content-Disposition" value= 'form-data; name="text";'/>
            <http:body media-type = "text/plain">{$params?текст}</http:body>
            <http:header name="Content-Disposition" value= 'form-data; name="gfm";'/>
            <http:body media-type = "text/plain">true</http:body>
        </http:multipart>
       </http:request>,
      "https://gitlab.com/api/v4/markdown"
    )[2]//html/text()
  )/html
};

declare
  %private
function md-to-moodle:answer($params as map(*)) as element(answer){
  <answer fraction="{$params?оценка}" format="moodle_auto_format">
    <text>{$params?ответ}</text>
    <feedback format="moodle_auto_format">
      <text></text>
    </feedback>
  </answer>
};

declare
  %private
function md-to-moodle:question($params as map(*)) as element(question){
  <question type="multichoice">
    <name>
      <text>{$params?вопрос}</text>
    </name>
    <questiontext format="moodle_auto_format">
      <text>{$params?вопрос}</text>
    </questiontext>
    <generalfeedback format="moodle_auto_format">
      <text></text>
    </generalfeedback>
    <defaultgrade>1.0000000</defaultgrade>
    <penalty>0.3333333</penalty>
    <hidden>0</hidden>
    <idnumber></idnumber>
    <single>{$params?типВопроса}</single>
    <shuffleanswers>true</shuffleanswers>
    <answernumbering>abc</answernumbering>
    <showstandardinstruction>0</showstandardinstruction>
    <correctfeedback format="moodle_auto_format">
      <text></text>
    </correctfeedback>
    <partiallycorrectfeedback format="moodle_auto_format">
      <text></text>
    </partiallycorrectfeedback>
    <incorrectfeedback format="moodle_auto_format">
      <text></text>
    </incorrectfeedback>
  </question>
};

declare
  %private
function md-to-moodle:quiz($params as map(*)) as element(quiz){
  <quiz>{
    for $вопрос in $params?вопросы
    let $оценкаПравильных := (1 div count($вопрос/ul/li/strong)) * 100
    let $оценкаНеправильных :=
      if($оценкаПравильных = 100)
      then(0)
      else((1 div count($вопрос/ul/li[not(strong)])) * -100)
    let $типВопроса :=
      if($оценкаПравильных = 100)
      then("true")
      else("false")
    let $телоВопроса :=
      md-to-moodle:question(
        map{
          "вопрос":$вопрос/p/text(),
          "типВопроса":$типВопроса
        }
      )
    let $ответы :=
      for $ответ in $вопрос/ul/li
      let $оценка := $ответ/strong ?? $оценкаПравильных !! $оценкаНеправильных
      return
        md-to-moodle:answer(
          map{
            "ответ":$ответ//text(),
            "оценка":$оценка
          }
        )
    return
      $телоВопроса update insert node $ответы into .
  }</quiz>
};