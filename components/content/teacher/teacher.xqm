module namespace content = 'content/teacher';

declare function content:main( $params ){
    map{
      'содержание' : $params?_tpl( 'content/teacher/teacher.profil', map{} )
    }
};