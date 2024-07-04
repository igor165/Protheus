#INCLUDE "UBAA020.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} UBAW020
//Este fonte é usado com unicamente com o propóstio de disponibilizar, via Web Service
//acesso à tabela N71 (Vínculo de esteira x fardão).
//Qualquer validação que seja relativa a este processo, deve ser inserida neste fonte respeitando o MVC 
@author brunosilva
@since 01/12/2017
@version undefined
@type function
/*/
Function UBAW020()
Return

//----------------------------------------------------------------
Static Function ModelDef()
	Local oModel  := Nil
	Local oWebN71 := FWFormStruct(1, "N71")
	
	oModel := MPFormModel():New("UBAW020", , , {|oModel| GrvModelo(oModel)})
	oModel:setDescription(STR0001) //Esteira x fardão
	
	oModel:addFields( 'N71UBAA020', /*cOwner*/, oWebN71)
	oModel:getModel('N71UBAA020'):setDescription(STR0001)//"Esteira x Fardão"
	
	oModel:SetPrimaryKey( { "N71_FILIAL" , "N71_CODEST" , "N71_FARDAO" , "N71_SAFRA", "N71_PRODUT" , "N71_LOJA" , "N71_FAZEN"  } ) // Seta as chaves primárias
Return oModel


/*/{Protheus.doc} GrvModelo
//TODO Descrição auto-gerada.
@author brunosilva
@since 27/04/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function GrvModelo(oModel)
	Local lRet := .T.
	
	If Empty(oModel:GetValue(  'N71UBAA020', "N71_CODEST" ))
		lRet := .F.
		//"Não é possível confirmar o relacionamento entre Esteira x Fardão." - "Código da Esteira não informado."
		oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0027 , STR0028, "", "")
	EndIf
	
	If lRet
		lRet := oModel:VldData()
		If lRet
			FwFormCommit(oModel, , {|oModel,cID,cAlias| .T.})
		EndIf
		If .Not. lRet
			oModel:SetErrorMessage( , , oModel:GetId() , "", "", oModel:GetErrorMessage()[7] , oModel:GetErrorMessage()[6], "", "")
		EndIf
	EndiF
	
Return lRet


