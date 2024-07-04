#include "protheus.ch"
#include "RU99XFUN.CH"

#define FUNCT_NOME 1
#define FUNCT_NUM 2

/*
Addresses functionalitty.
*/
Function RU99CAdr(cField)
	
Local cResult
Local aArea as array
Local nCount as numeric
Default cField := "CO_ADDRESS"

aArea:= {{'CO_OKOPF','12247'},{'CO_OKFS','31'},{'CO_OKPO','27099446'},{'CO_OKVED','29.4'},;
	{'CO_NAME',STR0002},{'CO_TIN','7816274161'},;
	{'CO_KPP','7816274161'},{'CO_ADDRESS', STR0003}}

For nCount := 1 To Len(aArea)
	
	If cField == aArea[nCount ,FUNCT_NOME]
		
		cResult := aArea[nCount ,FUNCT_NUM]
	Endif
	
Next nCount
	
Return cResult