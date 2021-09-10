module namespace content = 'content';

declare function content:main( $params ){
    map{
      'содержание' : $params?_tpl( 'content/teacher', map{ 'страница' : $params?страница } )
    }
};