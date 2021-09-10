module namespace teachers.tabel = 'content/teacher/teachers.tabel';

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

import module namespace functx = "http://www.functx.com";

declare function teachers.tabel:main( $params ){
  let $data :=
     (fetch:xml('http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/1c23aa46-fa19-413f-b99c-6ab5ffff5c28'))//file
    
  let $данныеПланЧасы := ($data//table )



let $result :=    


			for $x in ('сентябрь')
 
				for $числа in $данныеПланЧасы/row
				where matches ($числа/data(), $x)

			return

				let $c := $числа/cell [1]/@label/data()
return

( <tr>
  
  <td> { $c } </td>
  
  </tr> 
 )

return	
	map{ 
      
	  'данные' : <table border='1'> 
	  
	  
				<tr>
				{$result }
				</tr>
				
				</table>
	  
  

 
	  
	  

    }
	

};