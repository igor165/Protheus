#INCLUDE "Protheus.ch"

/*/{Protheus.doc} A050VldDF6
//TODO Função de consulta de MDF-e. 
@author arume.alexandre
@since 29/10/2019
@type function
/*/
Function TMSAE73B()

	TMSAE73()

Return

/*/{Protheus.doc} TMSA73BX1
//TODO Função que verifica se existe o pergunte TMSAE73B cadastrado. 
@author arume.alexandre
@since 30/10/2019
@type function
/*/
Function TMSA73BX1()

    Local oObj := FWSX1Util():New()
    Local lRet := .F.

    oObj:AddGroup("TMSAE73B")
    oObj:SearchGroup()
    lRet := Len(oObj:GetGroup("TMSAE73B")[2]) > 0

    FreeObj(oObj)
    
Return lRet