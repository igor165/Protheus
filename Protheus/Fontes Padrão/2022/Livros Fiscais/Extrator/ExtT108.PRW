#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtT108

@author Luccas Curcio
@since 08/09/2015
@version  

/*/
//-------------------------------------------------------------------
function ExtT108( aRegT108 , dDataAte )

local	nX		:=	0

local	cStrST1	:=	''

for nX := 1 to len( aRegT108 )

	cStrST1	:=	'|T108'						//Registro
	cStrST1	+=	'|' + dToS( dDataAte )					//Periodo 
	cStrST1	+=	'|' + aRegT108[ nX , 7 ]	//CNPJ
	cStrST1	+=	'|' + ALLTRIM(aRegT108[ nX , 8 ])	//Nome Empresarial
	cStrST1	+=	'|' + aRegT108[ nX , 9 ]	//Indicador de Orgao Publico
	cStrST1	+=	'|' + aRegT108[ nX , 10 ]	//Codigo da Receita
	cStrST1	+=	'|' + val2str(val(substr(aRegT108[ nX , 11 ],1,12)+'.'+substr(aRegT108[ nX , 11 ],13,2)),14,2)	//Rendimento Bruto/Receita
	cStrST1	+=	'|' + val2str(val(substr(aRegT108[ nX , 12 ],1,12)+'.'+substr(aRegT108[ nX , 12 ],13,2)),14,2)	//IR Retido na Fonte
	cStrST1	+=	'|' + val2str(val(substr(aRegT108[ nX , 13 ],1,12)+'.'+substr(aRegT108[ nX , 13 ],13,2)),14,2)	//CSLL Retida na Fonte
	
	ECFParseDIPJ( cStrST1 )
	
	cStrST1	:=	''

next nX

return