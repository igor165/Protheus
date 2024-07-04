//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё 10/04/2007                                             Ё
//Ё Bops 123498:                                           Ё
//Ё Esta funcao foi renomeada de PWSC052 para PWSC052B paraЁ
//Ё evitar erro de duplicidade de funcao no repositorio.   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
User Function PWSC052B()

Local aReturn := {}

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Campos a serem mostrados             									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aAdd( aReturn, "ORDERID" )
aAdd( aReturn, "ORDERTYPECODE" )
aAdd( aReturn, "CARRIERCODE" )
aAdd( aReturn, "FINANCIALDISCOUNT" )
aAdd( aReturn, "REGISTERDATE" )
aAdd( aReturn, "BIDNUMBER" )
aAdd( aReturn, "FREIGHTTYPE" )
aAdd( aReturn, "FREIGHTVALUE" )
aAdd( aReturn, "INSURANCEVALUE" )
aAdd( aReturn, "ADDITIONALEXPENSEVALUE" )

Return aReturn