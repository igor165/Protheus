#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} RemCharEsp
Remove da string enviada caracteres especiais(",",".","-")

@param   cString String que dejesa retivar os caracteres

@author  Caio Quiqueto dos Ssntos
@version P11
@since   18/03/2013
@return  cString Ira retornar a string sem os caracteres

@sample  RemCharEsp("1,2-3.4")
			ir· retornar "1234"
/*/

Function RemCharEsp(cString)
local nAux := 1
local aCharEspec := {",",".","-","(",")","[","]"," "}
		
	while nAux <= Len(aCharEspec)
		cString:= strtran(cString,aCharEspec[nAux],"")
		nAux++
	End
Return cString

/*/{Protheus.doc} RemDddTel
Separa o DDD e DDI do telefone, caso passado juntos:
Regra de separaÁ„o
tamanho	resultado
08 - 8 - Telefone Fixo
09 - 9 - Telefone Celular
10 - 2 - DDD 8 - Telefone Fixo
11 - 2 - DDD 9 - Telefone Celular
11 - 3 - DDD 8 - Telefone Fixo
12 - 3 - DDD 9 - Telefone Celular
12 - 2 - DDI 2 - DDD - 8 - Telefone Fixo
13 - 2 - DDI 2 - DDD - 9 - Telefone Celular
13 - 2 - DDI 3 - DDD - 8 - Telefone Fixo
14 - 2 - DDI 3 - DDD - 9 - Telefone Celular
Caso n„o entre em nenhuma das regras o retorno 
ser· apenas o numero enviado, sem modificaÁıes

@param   cString String que contem o telefone

@author  Caio Quiqueto dos Ssntos
@version P11
@since   18/03/2013
@return  	cTel Numero de Telefone 8 ou 9 digitos
			cDDD Numero de DDD de duas posiÁıes
			cDDI Numero de DDI de duas posiÁıe( pode retornar nulo)

@sample  RemDddTel("5511987654321")
			ir· retornar {"987654321","11","55"}
/*/

Function RemDddTel(cString)
Local cTel 	:= ""
Local cDDD 	:= ""
Local cDDI 	:= ""
Local nTelTam:= 0

cString := AllTrim( StrTran( cString, ' ','' ) )
nTelTam:= Len( cString )
		
If nTelTam == 8 .Or. nTelTam == 9
	cTel := cString
Elseif nTelTam == 10
	cDDD 	:= SubStr(cString,1,2)
	cTel	:= SubStr(cString,3,Len(cString))
Elseif nTelTam == 11
	If SubStr(cString,1,1) == "0"
		cDDD 	:= SubStr(cString,1,3)
		cTel	:= SubStr(cString,4,Len(cString))
	Else
		cDDD 	:= SubStr(cString,1,2)
		cTel	:= SubStr(cString,3,Len(cString))
	Endif
Elseif nTelTam == 12
	If SubStr(cString,1,1) == "0"
		cDDD 	:= SubStr(cString,1,3)
		cTel	:= SubStr(cString,4,Len(cString))
	Else
		cDDI 	:= substr(cString,1,2)
		cDDD 	:= SubStr(cString,3,2)
		cTel	:= SubStr(cString,5,Len(cString))
	Endif
Elseif nTelTam == 13
	cDDI 	:= substr(cString,1,2)
	If SubStr(cString,3,1) == '0'
		cDDD 	:= SubStr(cString,3,3)
		cTel	:= SubStr(cString,6,Len(cString))
	Else
		cDDD 	:= SubStr(cString,3,2)
		cTel	:= SubStr(cString,5,Len(cString))
	EndIf
Elseif nTelTam >= 14
	cDDI 	:= substr(cString,1,2)
	If SubStr(cString,3,1) == '0'
		cDDD 	:= SubStr(cString,3,3)
		cTel	:= SubStr(cString,6,Len(cString))
	Else
		cDDD 	:= SubStr(cString,3,2)
		cTel	:= SubStr(cString,5,Len(cString))
	EndIf
Endif
	
Return {cTel,cDDD,cDDI}

/*/{Protheus.doc} RemAcenC
FunÁ„o que retira AcentuaÁ„o e o «

@param   cString String que dejesa retivar os caracteres

@author  Caio Quiqueto dos Ssntos
@version P11
@since   26/03/2013
@return  cString Ira retornar a string sem os acentos

@sample  RemDddTel("«‘‹¿Ì")
			ir· retornar "COUAi"
/*/

function RemAcenC(cString)
Local cRet

	cString 	:= StrTran(cString,"Á","c")
	cString 	:= StrTran(cString,"«","C")
	cString 	:= NoAcento(cString)
	
	cRet		:= cString
Return cRet