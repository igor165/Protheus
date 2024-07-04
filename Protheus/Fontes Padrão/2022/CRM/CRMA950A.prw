#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA950A.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA950A

Rotina para visualização do histórico de processamento e log do rodízio.

@sample	CRMA950A()

@param		Nenhum

@return	Nenhum

@author	Jonatas Martins
@since		03/07/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function CRMA950A(cCodTer,cCodFla,cTpMem,cCodMem)

Local aArea := GetArea()

RestArea(aArea)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Monta modelo de dados do histórico de processamento e log do rodízio.

@sample	ModelDef()

@param		Nenhum

@return	oModel - Obejto com estrutura do modelo de Dados

@author	Jonatas Martins 
@since		03/11/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel	 := Nil

Local cCpoAZ4Fld 		:= "AZ4_FILIAL|AZ4_TPMEM|AZ4_CODMEM|AZ4_DSCMEM|"
Local bAvCpoAZ4Fld	:= {|cCampo| (AllTrim(cCampo)+"|" $ cCpoAZ4Fld)}

Local oStruAZ4Fld		:= FWFormStruct(1,"AZ4",bAvCpoAZ4Fld,/*lViewUsado*/)
Local oStruAZ4Grd		:= FWFormStruct(1,"AZ4",/*bAvalCampo*/,/*lViewUsado*/)

//------------------------------------------
// Cria campo apra exibir o log do processo
//------------------------------------------	
oStruAZ4Grd:AddField("Log","","AZ4_LOG","C",4,0,/*bValid*/,/*bWhen*/,/*aValues*/,/*lObrigat*/,{||"LUPA"},/*lKey*/,/*LNoUpd*/,.T.,/*cValid*/)

//----------------------------------------
// Cria o objeto da classe do modelo 
//----------------------------------------
oModel := MPFormModel():New("CRMA950A",/*bPreValidacao*/,/*bPosVldMdl*/,/*bCommitMdl*/,/*bCancel*/)

//----------------------------------------
// Define a estrutura do modelo 
//----------------------------------------
oModel:AddFields("AZ4FIELD",/*cOwner*/,oStruAZ4Fld,/*bPreValidacao*/,/*bPosValidacao*/,/*bCargaField*/)
oModel:AddGrid("AZ4GRID","AZ4FIELD",oStruAZ4Grd,/*bPreValidacao*/,/*bPosValidacao*/,/*bCargaGrid*/)

oModel:SetRelation("AZ4GRID", {{ 'AZ4_FILIAL'	, 'xFilial("AZ4")' } ,;
									{ 'AZ4_CODROD'	, 'AZ3_CODROD' } }, AZ4->(IndexKey(1)) )

//-------------------------------------------------------------------
// Define a descrição do modelo de dados. 
//-------------------------------------------------------------------	
oModel:SetDescription(STR0001) //"Membro"
oModel:GetModel("AZ4GRID"):SetDescription(STR0002)  //"Histórico do Processamento"

//----------------------------------------
// Define a chave primária do modelo
//----------------------------------------
oModel:SetPrimaryKey({})

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Monta interface do histórico de processamento e log do rodízio.

@sample	ViewDef()

@param		Nenhum

@return	oView - Interface do Agrupador de Registros

@author	Jonatas Martins
@since		03/07/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= Nil
Local oView		:= Nil

Local cCpoAZ4Fld 		:= "AZ4_TPMEM|AZ4_CODMEM|AZ4_DSCMEM|"
Local cCpoAZ4Grid    := "AZ4_CODROD|AZ4_CODFLA|AZ4_SEQFLA|AZ4_TPMEM|AZ4_CODMEM|AZ4_LGPROC|"

Local bAvCpoAZ4Fld	:= {|cCampo| (AllTrim(cCampo)+"|" $ cCpoAZ4Fld)}
Local bAvCpoAZ4Grid  := {|cCampo| !(AllTrim(cCampo)+"|" $ cCpoAZ4Grid)}

Local oStruAZ4Fld	:= FWFormStruct(2,"AZ4",bAvCpoAZ4Fld,/*lViewUsado*/)
Local oStruAZ4Grd	:= FWFormStruct(2,"AZ4",bAvCpoAZ4Grid,/*lViewUsado*/)

//------------------------------------------
// Cria campo apra exibir o log do processo
//------------------------------------------
oStruAZ4Grd:AddField("AZ4_LOG","01","Log","",{},"C","@BMP",{||}/*bPictVar*/,/*cLookup*/,/*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,/*lVirtual*/,/*cPictVar*/,/*lInsertLine*/)

//-------------------------------------------------------------------
// Instancia os Objetos da View e do Model que serão utilizados
//-------------------------------------------------------------------	
oView 	:= FWFormView():New()
oModel	:= FWLoadModel("CRMA950A")

//-----------------------------------------
// Define o Model que será usada na View.
//-----------------------------------------
oView:SetModel(oModel)

//-------------------------------------------------------------------
// Define as estruturas de visualização. 
//-------------------------------------------------------------------
oView:AddField("VIEW_AZ4FLD",oStruAZ4Fld,"AZ4FIELD")
oView:AddGrid("VIEW_AZ4GRD",oStruAZ4Grd,"AZ4GRID")

//-------------------------------------------------------------------
// Define os Box's da View  
//-------------------------------------------------------------------
oView:CreateHorizontalBox("TOP",30)
oView:CreateHorizontalBox("CENTRAL",70)

//-------------------------------------------------------------------
// Define a relação entre Box e estrutura de visualização   
//-------------------------------------------------------------------
oView:SetOwnerView("VIEW_AZ4FLD","TOP")
oView:SetOwnerView("VIEW_AZ4GRD","CENTRAL")

//------------------------------------
// Habilita título das visualizações   
//------------------------------------
oView:EnableTitleView("VIEW_AZ4FLD",STR0001) //"Membro"
oView:EnableTitleView("VIEW_AZ4GRD",STR0002) //"Histórico do Processamento"

//-------------------------------------------------------------------
// Evento de duplo click no Grid pra exibir o log do processamento
//-------------------------------------------------------------------
oView:SetViewProperty("VIEW_AZ4GRD","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| CRM950ALog(oFormulario,cFieldName,nLineGrid,nLineModel,oView)}})

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM950ALog

Rotina que exibe o log do processamento no duplo click do campo AZ4_LOG

@sample	CRM950ALog(oFormulario,cFieldName,nLineGrid,nLineModel,oView)

@param		oFormulario - Objeto do Formulário
			cFieldName  - Nome do Campo
			nLineGrid   - Linha do Grid
			nLineModel  - Linha do Model	
			oView - Objetio do modelo de interface

@author	Jonatas Martins
@since		02/07/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Static Function CRM950ALog( oFormulario, cFieldName, nLineGrid, nLineModel, oView )
	Local oModel      := Nil

	Default oFormulario := Nil
	Default oView       := Nil
	Default cFieldName  := ""
	Default nLineGrid   := 0
	Default nLineModel  := 0

	If ( oView <> Nil .And. ValType(oView) == "O" .And. cFieldName == "AZ4_LOG" ) 
		oModel := oView:GetModel() 
		
		If ! ( Empty( oModel:GetModel("AZ4GRID"):GetValue("AZ4_LGPROC") ) )
		   	CRMA950Viewer( oModel:GetModel("AZ4GRID"):GetValue("AZ4_LGPROC") )
		Else
			Help(" ",1,"CRM930LOGP")
		EndIf	   	
	EndIf
Return 
