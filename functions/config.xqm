module namespace config = "app/config";

declare  variable $config:param:= function( $param ) {
  doc ( "../config.xml" ) 
  /config/param[ @id = $param ]/text()
};


declare  variable $config:templateIDs:= function( $book ) {
  switch ( $book ) 
    case 'patient'      
      return
        map{
          'partsTemplateID' : $config:param( "partsTemplateID" ),
          'pagesTemplateID' : $config:param( "pagesTemplateID" )
        }
    case 'template' 
      return
        map{
          'partsTemplateID' : $config:param( "templatesGroupTemplateID" ),
          'pagesTemplateID' : $config:param( "templatesTemplateID" )
        }   
    case 'price' 
      return
        map{
          'partsTemplateID' : $config:param( "pricesGroupTemplateID" ),
          'pagesTemplateID' : $config:param( "pricesTemplateID" )
        }
    default 
      return ()
};
