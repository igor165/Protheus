#Include 'Protheus.ch'
#Include 'PCPA147.ch'
#Include 'FWEditPanel.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA147
Função MVC sem dicionários
/*/
//-------------------------------------------------------------------
Function PCPA147()
	//Chamando a função Incluindo
	FWExecView(STR0001,"PCPA147",3,,{|| .T.})
	 
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao do ModelDef MVC
@author  Christopher.miranda
@since   02/12/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStr 	:= getModelStruct()	// CAMPOS DO FIELD
Local oStr1 := getMStr1() 		// CAMPOS DA GRID  

	oModel := MPFormModel():New('MVCTEMPF',,,)
	
	oModel:SetDescription(STR0002)
	oModel:AddFields("MASTER",,oStr,,,)
    oModel:addGrid('DETAILSTR1','MASTER',oStr1)
  
	oModel:getModel("MASTER"):SetDescription("FORM FIELD")
    oModel:getModel("DETAILSTR1"):SetDescription("GRID")
	oModel:SetPrimaryKey({})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao do ViewDef MVC
@author  Christopher.miranda
@since   02/12/19
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef() 
Local oStr	:= getViewStruct()    // CAMPOS DO FORM FIELD DA VIEW 

	oView := FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField('FORM1' , oStr,'MASTER' ) 

	oView:CreateHorizontalBox( 'BOXSUPERIOR', 100)
	oView:SetOwnerView('FORM1','BOXSUPERIOR')

	oView:EnableTitleView('FORM1' , STR0003 ) 


Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} getModelStruct
Montagem dos campos no model para o oSTR
/*/
//-------------------------------------------------------------------
Static function getModelStruct()
Local oStruct := FWFormModelStruct():New()
	
	oStruct:AddField('Codigo','Codigo' , 'COD', 'C', 6, 0, , , {}, .T., , .F., .F., .F.,  )
	//Adicionar um botao no MVC
	oStruct:AddField('Anonimizar','Anonimizar' , 'LOAD', 'BT', 1, 0, { |oMdl| Anoni147(oMdl), .T. }, , {}, .F., , .F., .F., .F., , )
	
return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} getViewStruct
Montagem dos campos na View para o oSTR
/*/
//-------------------------------------------------------------------
static function getViewStruct()

Local oStruct := FWFormViewStruct():New()
 
	oStruct:AddField( 'COD','1','Codigo','Codigo',, 'C' ,'@!',,,.T.,,,,,,.F.,, )
	oStruct:AddField( 'LOAD','2','Anonimizar','Anonimizar',, 'BT' ,,,,,,,,,,,, )

return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} Gerar
Botao Gerar dentro do field MVC 
/*/
//-------------------------------------------------------------------
Static Function Anoni147(oField)

	Local cAlias  	:= "SHR"
	Local aFields 	:= {}
	Local cCod 	  	:= oField:GetValue("COD")
	Local cMessage	:= ""
	Local lRet		:= .F.
	
	// aFields := FwProtectedDataUtil():GetAliasFieldsInList( cAlias )

	SHR->(dbSetOrder(1))
	If SHR->(dbSeek(xFilial("SHR")+cCod))
		
		lRet := FwProtectedDataUtil():ToAnonymizeByRecno( cAlias, {SHR->(Recno())}, /*aFields*/, @cMessage ) 
	EndIf

	If lRet
		MsgInfo( STR0004 + cCod )
	else
		Alert( STR0005 + cCod )
	EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getModelStruct
Montagem dos campos na Model para o oStr1
/*/
//-------------------------------------------------------------------
Static function getMStr1()

Local oStruct := FWFormModelStruct():New()

	oStruct:AddField('Codigo','Codigo' , 'COD', 'C', 6, 0, , , {}, .T., , .F., .F., .F.,  )
	
return oStruct