module namespace data = '/sandbox/ivgpu/generate/data';
 
declare function data:getProgrammData(){
  let $Программы :=
    db:open( 'simplex-saivpds', '.366164.simplex.xml' )
    /Программы/Программа
  
  return 
    $Программы 
};