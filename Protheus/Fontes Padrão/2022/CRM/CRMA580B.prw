#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA580B.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580B

Cadastro de Níveis do Agrupador Fixo.

@sample		CRMA580B()
 
@param		Nenhum

@return		Nenhum

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580B()
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Monta modelo de dados do Níveis do Agrupador Fixo.

@sample		ModelDef()

@param		Nenhum

@return		ExpO - Modelo de Dados

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oStructAOL := FWFormStruct(1,"AOL",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAOM := FWFormStruct(1,"AOM",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAON := FWFormStruct(1,"AON",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel 	 := Nil


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo de marca da tabela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructAOM:AddField("","","AOM_MARK","L",1,0,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

// Inicializa o campo de entidade para montado do F3 da entidade.
oStructAON:SetProperty("AON_ENTIDA",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"AOL->AOL_ENTIDA"))

// Inicializa o campo de entidade para montado do F3 da entidade.
oStructAON:SetProperty("AON_CHAVE",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,"CRMA580BVChv()"))


// Instancia o modelo de dados da Agrupador de Registros.
oModel := MPFormModel():New("CRMA580B",/*bPreValidacao*/,/*bPosVldMdl*/,/*bCommitMdl*/,/*bCancel*/)

// ModelField Agrupador x Entidades ³ 
oModel:AddFields("AOLMASTER",/*cOwner*/,oStructAOL,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:AddGrid("AOMDETAIL","AOLMASTER",oStructAOM,/*bLinPre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)
oModel:AddGrid("AONDETAIL","AOMDETAIL",oStructAON,/*bLinPre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)

// Relacionamentos 
oModel:SetRelation("AOMDETAIL",{{"AOM_FILIAL","xFilial('AOL')"},{"AOM_CODAGR","AOL_CODAGR"}},AOM->(IndexKey(1)))
oModel:SetRelation("AONDETAIL",{{"AON_FILIAL","xFilial('AOM')"},{"AON_CODAGR","AOL->AOL_CODAGR"},{"AON_ENTIDA","AOL->AOL_ENTIDA"},{"AON_CODNIV","AOM_CODNIV"}},AON->(IndexKey(1)))

//Verificar linhas duplicadas
oModel:GetModel("AONDETAIL"):SetUniqueLine({"AON_CHAVE"})

oModel:SetDescription(STR0001) //"Níveis do Agrupador"

// Define o grid dos níveis como opcional
oModel:GetModel("AOMDETAIL"):SetOptional(.T.)
oModel:GetModel("AONDETAIL"):SetOptional(.T.)

// Inicializador do campo AON_DSCCHV.
oModel:SetActivate( {|oModel| CRM580Inic(oModel)})
 
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Monta interface do Níveis do Agrupador Fixo.

@sample		ViewDef()
 
@param		Nenhum

@return		ExpO - Interface do Agrupador de Registros

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local cCamposAON	:= "AON_FILIAL|AON_CHAVE|AON_DSCCHV|"
Local bAvCpoAON  	:= {|cCampo| AllTrim(cCampo)+"|" $ cCamposAON}
Local oStructAOM	:= FWFormStruct(2,"AOM",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAON	:= FWFormStruct(2,"AON",bAvCpoAON,/*lViewUsado*/)	
Local oModel 		:= FWLoadModel("CRMA580B")
Local oView	 		:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo de marca da tabela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructAOM:AddField("AOM_MARK","01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

oView := FWFormView():New()
oView:SetModel(oModel)

oView:CreateHorizontalBox("SUPERIOR",40)
oView:CreateHorizontalBox("MEIO",0)

//Oculta View do AOM
oView:CreateHorizontalBox("INFERIOR",60)

oView:AddOtherObject("OBJ_TREE"		, {|oPanel| CRM580DTree(oPanel,oView,oView:GetModel())})

oView:AddGrid("VIEW_AOM",oStructAOM	,"AOMDETAIL")
oView:AddGrid("VIEW_AON",oStructAON	,"AONDETAIL")

oView:EnableTitleView("OBJ_TREE",STR0001)	//"Níveis do Agrupador"
oView:EnableTitleView("VIEW_AON",STR0002)	//"Registros"

oView:SetOwnerView("OBJ_TREE","SUPERIOR")
oView:SetOwnerView("VIEW_AOM","MEIO")
oView:SetOwnerView("VIEW_AON","INFERIOR")

oView:AddIncrementField("VIEW_AOM","AOM_CODNIV")

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580Inic

Inicializa o campo de descrição(AON_DSCCHV) da chave da entidade.

@sample	CRM580Inic(oModel)

@param		Nenhum

@return		oModel - Modelo de dados ativo

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------*/
Static Function CRM580Inic(oModel)

Local cAlias   	:= AOL->AOL_ENTIDA
Local aAreaAl  	:= (cAlias)->(GetArea())
Local cDisplay 	:= CRMXGetSX2(cAlias)[2]
Local oMdlAOM	:= oModel:GetModel("AOMDETAIL")
Local oMdlAON	:= oModel:GetModel("AONDETAIL") 
Local cRet     	:= ""
Local cChave 	:= ""
Local nX		:= 0
Local nXLin		:= 0
Local nY		:= 0
Local nYLin		:= 0

DbSelectArea(cAlias)
(cAlias)->(DbSetOrder(1))

For nX := 1 To oMdlAOM:Length()
	
	nXLin := oMdlAOM:GetLine() 
	oMdlAOM:GoLine(nX)
	  
	For nY := 1 To oMdlAON:Length() 

		nYLin := oMdlAON:GetLine() 
		oMdlAON:GoLine(nY)
		
		cChave := oMdlAON:GetValue("AON_CHAVE")
	
		If !Empty(cChave)	
			If (cAlias)->(Dbseek(xFilial(cAlias)+cChave))
				cRet :=  AllTrim((cAlias)->&(cDisplay))
				oMdlAON:SetValue("AON_DSCCHV",SubStr(cRet,1,TamSx3("AON_DSCCHV")[1]))
			EndIf					 
		EndIf
	
	Next nY

	oMdlAON:GoLine(1)
		
Next nX 

oMdlAOM:GoLine(1)

RestArea(aAreaAl)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580Gat

Cria o gatilho do campo AON_CHAVE para retornar a descricao(AON_DSCCHV) da entidade.

@sample		CRMA580Gat()

@param		Nenhum

@return		ExpC - Display da Entidade

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580Gat()

Local cAlias   	:= AOL->AOL_ENTIDA
Local aAreaAl  	:= (cAlias)->(GetArea())
Local cDisplay 	:= CRMXGetSX2(cAlias)[2]
Local oModel	:= FwModelActive()
Local cRet     	:= ""

DbSelectArea(cAlias)
(cAlias)->(DbSetOrder(1))

If oModel:GetOperation() <> MODEL_OPERATION_INSERT  
	If (cAlias)->(Dbseek(xFilial(cAlias)+AllTrim(oModel:GetValue("AONDETAIL","AON_CHAVE"))))
		cRet := Substr(Alltrim((cAlias)->&(cDisplay)),1,TAMSX3("AON_DSCCHV")[1])
	EndIf
EndIf

RestArea(aAreaAl)

Return(cRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580BVChv

Valida a chave da entidade.

@sample		CRMA580BVChv

@param		Nenhum 

@return		ExpL -  Verdadeiro / Falso

@author		Anderson Silva
@since		03/04/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580BVChv()
	Local oTree 	:= CRMA580DGTree()
Local oModel	:= FwModelActivate()
Local oMdlAOL	:= oModel:GetModel("AOLMASTER")
Local oMdlAON	:= oModel:GetModel("AONDETAIL")
Local lRetorno 	:= .T.

If ! ( Empty( oTree ) ) .And. ( oTree:Total() > 1 )
	lRetorno := ExistCpo(oMdlAOL:GetValue("AOL_ENTIDA"),oMdlAON:GetValue("AON_CHAVE"),1)	
Else
	lRetorno := .F.
	Help(,1,"CRM580BEXTNVL")
EndIf
Return(lRetorno)


//-------------------------------------------------------------------------------------------
/*/ {Protheus.doc}

Funcao para posicionar na primeira linha do modelgrid ( Nivel do Agrupador x Registros )

@sample		CRM580BChgLine(oModel)

@param		ExpO1 - Model Ativo

@return		Nenhum

@author		Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//--------------------------------------------------------------------------------------------
Function CRMA580BAONTop(oModel)
	
Local oMdlAON := oModel:GetModel("AONDETAIL")

oMdlAON:GoLine(1)

Return Nil
