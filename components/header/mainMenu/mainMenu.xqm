module namespace mainMenu = "header/mainMenu";

declare function mainMenu:main( $params as map(*) ){
  let $пункты :=
  (
    [ 'Выпуск 2021/2022', '/sandbox/ivgpu/graduation/2022/21/groups' ],
    [ 'Документы ООП', '/sandbox/ivgpu/statistic' ]
  )

  let $меню :=
    map{
      'главная' : '/simplex',
      'названиеРаздела' : 'Разделы',
      'пункты' : mainMenu:items( $пункты )
    }
  return
     $меню
};

declare function mainMenu:items( $items ){
  for $i in $items
  let $href := $i?2
  return
   <a class="dropdown-item" href="{ $href }">{ $i?1 }</a>       
};