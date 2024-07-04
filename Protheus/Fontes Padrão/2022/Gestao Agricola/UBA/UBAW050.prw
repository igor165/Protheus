#INCLUDE "UBAA050.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} UBAW050
//Este fonte é usado com unicamente com o propóstio de disponibilizar, via Web Service
//acesso à tabela NPX (Lançamento de contaminantes).
//Qualquer validação que seja relativa a este processo, deve ser inserida neste fonte  respeitando o MVC 
@author brunosilva
@since 01/12/2017
@version undefined

@type function
/*/
Function UBAW050()
Return

//----------------------------------------------------------------
Static Function ModelDef()
	Local oModel  := Nil
	Local oWebNPX := FWFormStruct(1, "NPX")
	
	oModel := MPFormModel():New("UBAW050")//Cadastro de contaminantes
	oModel:setDescription(STR0001)
	
	oModel:addFields('RESTNPX', , oWebNPX)
	oModel:getModel('RESTNPX'):setDescription(STR0013)//Dados
Return oModel