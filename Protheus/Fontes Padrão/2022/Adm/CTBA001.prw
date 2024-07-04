#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CTBA001.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA001
Controles Contábeis

@author David Moraes

@since 22/01/2014                           	
@version 1.0
/*/
//-------------------------------------------------------------------
Function CTBA001(cAlias,nOpc, nReg)

If CT1->CT1_CLASSE == '2'
	FWExecView(STR0001,"CTBA001",MODEL_OPERATION_UPDATE,,{ || .T.}) //'Inclusão'
Else
	Help("",1,"HELP","CTBA001",STR0002,1,0) //"Somente contas do tipo analiticas poderam ser configuradas no Controle Contábil!"
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author David Moraes

@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStrCT1   := FWFormStruct(1,"CT1")
Local oStrCVP1  := FWFormStruct(1,"CVP")
Local oStrCVP2  := FWFormStruct(1,"CVP")
Local oStrCVP3  := FWFormStruct(1,"CVP")
  
oModel := MPFormModel():New('CTBA001',/*bPreValidacao*/,{ |oMdl| ValidCtba001( oMdl ) },{ |oMdl| CtbGrv( oMdl ) },/*bCommit*/, /*bCancel*/ )
 
// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( "CT1MASTER", /*cOwner*/, oStrCT1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:AddGrid ( 	"CVPGRID1"	,	"CT1MASTER" /*cOwner*/, oStrCVP1, /*bLinePre*/,{ |oMdl| VldLinhaGrid1(oModel) }/*bLinePost*/ ,/*bPre*/, /*bPost*/ )
oModel:getmodel("CVPGRID1"):SetLoadFilter(Nil, "CVP_LOTE <> '' AND  CVP_SUBLOT <> ''", NIL)
oModel:GetModel( "CVPGRID1" ):SetOptional(.T.) //Grid subItem não é obrigatório.

oModel:GetModel( "CVPGRID1" ):SetUniqueLine( {"CVP_LOTE", "CVP_SUBLOT"} )

oModel:SetRelation( "CVPGRID1", { { "CVP_FILIAL", "xFilial('CVP')" }, { "CVP_CONTA", "CT1_CONTA" } }, CVP->( IndexKey( 1 ) ) )

oModel:AddGrid ( 	"CVPGRID2"	,	"CT1MASTER" /*cOwner*/, oStrCVP2, /*bLinePre*/,/*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:Getmodel("CVPGRID2"):SetLoadFilter(Nil, "CVP_DIACTB <> ''", NIL)
oModel:GetModel( "CVPGRID2" ):SetOptional(.T.) //Grid subItem não é obrigatório.
oModel:GetModel( "CVPGRID2" ):SetUniqueLine( {"CVP_DIACTB"} )

oModel:SetRelation( "CVPGRID2", { { "CVP_FILIAL", "xFilial('CVP')" }, { "CVP_CONTA", "CT1_CONTA" } }, CVP->( IndexKey( 1 ) ) )

oModel:AddFields( "FIELD3", "CT1MASTER"/*cOwner*/, oStrCVP3, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetRelation( "FIELD3", { { "CVP_FILIAL", "xFilial('CVP')" }, { "CVP_CONTA", "CT1_CONTA" } }, CVP->( IndexKey( 1 ) ) )
oModel:GetModel( "FIELD3" ):SetOptional(.F.) //Grid subItem não é obrigatório.

//Não gravar dados de um componente do modelo de dados, será gravado manualmente
oModel:GetModel( 'FIELD3' ):SetOnlyQuery ( .T. )

//Desabilita a edição dos campos
oStrCT1:SetProperty('CT1_CONTA'	, 	MODEL_FIELD_WHEN	,FWBuildFeature( STRUCT_FEATURE_WHEN,'.F.'))
oStrCT1:SetProperty('CT1_DESC01', 	MODEL_FIELD_WHEN	,FWBuildFeature( STRUCT_FEATURE_WHEN,'.F.'))
oStrCT1:SetProperty('CT1_CLASSE', 	MODEL_FIELD_WHEN	,FWBuildFeature( STRUCT_FEATURE_WHEN,'.F.'))
oStrCT1:SetProperty('CT1_NORMAL', 	MODEL_FIELD_WHEN	,FWBuildFeature( STRUCT_FEATURE_WHEN,'.F.'))
oStrCT1:SetProperty('CT1_RES'	, 	MODEL_FIELD_WHEN	,FWBuildFeature( STRUCT_FEATURE_WHEN,'.F.'))

oStrCVP1:SetProperty( 'CVP_LOTE' 	, MODEL_FIELD_VALID,{||VldLote(oModel)})

oModel:SetDescription(STR0003)//'Modelo Principal da Estrutura de Controles Contábeis'

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author David

@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oModel := ModelDef("CTBA001")
Local oView
Local oStrCt1 := FWFormStruct( 2, "CT1", { |cCampo| COMPSTRU(cCampo) }/*bAvalCampo*/,/*lViewUsado*/ )
Local oStrCVP1:= FWFormStruct( 2, "CVP", { |cCampo| COMPABA1(cCampo)})
Local oStrCVP2:= FWFormStruct( 2, "CVP", { |cCampo| COMPABA2(cCampo)})
Local oStrCVP3:= FWFormStruct( 2, 'CVP', { |cCampo| COMPABA3(cCampo)})
  
oView := FWFormView():New()

oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField(	'VIEW_CT1'	, oStrCt1	,'CT1MASTER')

oView:AddGrid(  'VIEW_CVP1' , oStrCVP1	,'CVPGRID1'	)
oView:AddGrid(	'VIEW_CVP2' , oStrCVP2	,'CVPGRID2'	)
oView:AddField(	'VIEW_CVP3' , oStrCVP3	,'FIELD3' 	)  

oView:CreateHorizontalBox(	"CABECALHO"	, 30 )
oView:CreateHorizontalBox(	"FOLDER"	, 70 )

oView:CreateFolder( 'FOLDER1', 'FOLDER')

oView:AddSheet('FOLDER1','ABA1',STR0006)//'Lote/SubLotes'
oView:AddSheet('FOLDER1','ABA2',STR0007)//'Diários'
oView:AddSheet('FOLDER1','ABA3',STR0008)//'Configuração de Lançamentos'

oView:CreateHorizontalBox( 'GRID1', 100, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'ABA1')
oView:CreateHorizontalBox( 'GRID2', 100, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'ABA2')
oView:CreateHorizontalBox( 'FIELD', 100, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'ABA3')

// Liga a identificacao do componente
oView:EnableTitleView(	'VIEW_CVP1'		, STR0006)//'Lote/SubLotes'
oView:EnableTitleView(	'VIEW_CVP2'		, STR0007)//'Diários'
oView:EnableTitleView(	'VIEW_CVP3'		, STR0008)//'Configuração de Lançamentos'

oView:SetOwnerView( 'VIEW_CT1'	,	'CABECALHO'	)
oView:SetOwnerView('VIEW_CVP1'	,	'GRID1'		)
oView:SetOwnerView('VIEW_CVP2'	,	'GRID2'		)
oView:SetOwnerView('VIEW_CVP3'	,	'FIELD'		)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPSTRU
Campos que compoem a estrutura do cabeçalho

@author David Moraes

@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function COMPSTRU(cCampo)
Local lRet := .F.

If Alltrim(cCampo) $ 'CT1_DESC01|CT1_CONTA|CT1_CLASSE|CT1_NORMAL|CT1_REST'
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPABA1
Campos que compoem a estrutura da aba lote/sublotes

@author David Moraes

@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function COMPABA1(cCampo)
Local lRet := .F.

If Alltrim(cCampo) $ 'CVP_LOTE|CVP_SUBLOT'
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPABA2
Campos que compoem a estrutura da aba Diários

@author David Moraes

@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function COMPABA2(cCampo)
Local lRet := .F.

If Alltrim(cCampo) $ 'CVP_DIACTB'
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPABA3
Campos que compoem a estrutura da aba Configuração Lançamentos

@author David Moraes

@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function COMPABA3(cCampo)
Local lRet := .F.

If Alltrim(cCampo) $ 'CVP_LCTMAN|CVP_AVISO|CVP_ATIVO'
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CtbGrv
Efetua gravação manual de alguns campos

@author David Moraes

@return Retorna booleano se a gravação está correta  
@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CtbGrv(oModel)
Local oMdlMaster := oModel:GetModel(	'CT1MASTER'	)
Local oModelAba1 := oModel:GetModel(	'CVPGRID1'	)
Local oModelAba2 := oModel:GetModel(	'CVPGRID2'	)
Local oModelAba3 := oModel:GetModel(	'FIELD3'	)
Local nI         := 0
Local aErro      := {}
Local nOperation := oModel:GetOperation()
Local lRet       := .T.

If 	nOperation != MODEL_OPERATION_DELETE .And.;
	nOperation != MODEL_OPERATION_VIEW
	
	CVP->(DbSelectArea('CVP'))
	CVP->(DbSetOrder(1))

	For nI := 1 To oModelAba1:GetQtdLine()
		oModelAba1:GoLine( nI )
		If !oModelAba1:IsDeleted()
		
			If !oModel:SetValue("CVPGRID1", "CVP_ATIVO", oModelAba3:GetValue("CVP_ATIVO"))
				aErro := oModel:GetErrorMessage()
				Help("",1,"HELP","CTBA001",aErro[5]+" - "+aErro[6],1,0)
				lRet := .F.
			EndIf
		
		
			If !oModel:SetValue("CVPGRID1", "CVP_LCTMAN", oModelAba3:GetValue("CVP_LCTMAN"))
				aErro := oModel:GetErrorMessage()
				Help("",1,"HELP","CTBA001",aErro[5]+" - "+aErro[6],1,0)
				lRet := .F.
			EndIf
			
			If !oModel:SetValue("CVPGRID1", "CVP_AVISO", oModelAba3:GetValue("CVP_AVISO"))
				aErro := oModel:GetErrorMessage()
				Help("",1,"HELP","CTBA001",aErro[5]+" - "+aErro[6],1,0)
				lRet := .F.
			EndIf
		EndIf
	Next nI
	
	For nI := 1 To oModelAba2:GetQtdLine()
		oModelAba2:GoLine( nI )
		If !oModelAba2:IsDeleted()
		
			If !oModel:SetValue("CVPGRID2", "CVP_ATIVO", oModelAba3:GetValue("CVP_ATIVO"))
				aErro := oModel:GetErrorMessage()
				Help("",1,"HELP","CTBA001",aErro[5]+" - "+aErro[6],1,0)
				lRet := .F.
			EndIf
		
			If !oModel:SetValue("CVPGRID2", "CVP_LCTMAN", oModelAba3:GetValue("CVP_LCTMAN"))
				aErro := oModel:GetErrorMessage()
				Help("",1,"HELP","CTBA001",aErro[5]+" - "+aErro[6],1,0)
				lRet := .F.
			EndIf
			
			If !oModel:SetValue("CVPGRID2", "CVP_AVISO", oModelAba3:GetValue("CVP_AVISO")) 
				aErro := oModel:GetErrorMessage()
				Help("",1,"HELP","CTBA001",aErro[5]+" - "+aErro[6],1,0)
				lRet := .F.
			EndIf
		EndIf
	Next nI

EndIf      

lRet := FWFormCommit( oModel ) // Salva o Model

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCtba001
Validação 

@author David Moraes

@return Retorna booleano se permite a gravação  
@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function ValidCtba001(oModel)
Local oMdlMaster := oModel:GetModel(	'CT1MASTER'	)
Local oModelAba1 := oModel:GetModel(	'CVPGRID1'	)
Local oModelAba2 := oModel:GetModel(	'CVPGRID2'	)
Local oModelAba3 := oModel:GetModel(	'FIELD3'	)
Local nOperation := oModel:GetOperation()
Local nI         := 0
Local nLinDel    := 0
Local lRet       := .F.
Local lItem      := .F.
Local lSegOfi	 := !(GetMv( "MV_SEGOFI" , .F. , "0" ) == "0")

If 	nOperation != MODEL_OPERATION_DELETE .And.;
	nOperation != MODEL_OPERATION_VIEW
	
	CVP->(DbSelectArea('CVP'))
	CVP->(DbSetOrder(1))
	
	For nI := 1 To oModelAba1:GetQtdLine()
		oModelAba1:GoLine( nI )
		
		If !oModelAba1:IsDeleted()
		
			If !Empty(oModelAba1:GetValue("CVP_LOTE")) .Or. !Empty(oModelAba1:GetValue("CVP_SUBLOT"))
				lItem := .T.
				Exit
			EndIf
			
		EndIf
	Next nI
	
	If lItem
		If !lSegOfi
			lRet := .T.
		Else
			For nI := 1 To oModelAba2:GetQtdLine()
				oModelAba2:GoLine( nI )
			
				If !oModelAba2:IsDeleted() 
								
					If !Empty(oModelAba2:GetValue("CVP_DIACTB"))
						lRet := .T.
						Exit
					EndIf
				Else
					nLinDel++				
				EndIf
			Next nI 
		
			If !lRet .Or. nLinDel == oModelAba2:GetQtdLine()
				Help("",1,"HELP","CTBA001",STR0004,1,0)//"Favor informar o Código do Diário na Aba Diários!"
				lRet := .F.
			EndIf
		Endif
	EndIf
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldLote
Valida o lote e preenche com 6 posições

@author David Moraes

@return Retorna booleano se permite a gravação  
@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function VldLote(oModel)
Local oModelAba1 := oModel:GetModel(	'CVPGRID1'	)
Local nOperation := oModel:GetOperation()
Local aArea := GetArea()
Local cQuery     := ""
Local lRet       := .T.
Local cAlias     := GetNextAlias()
Local cLote      := Alltrim(oModelAba1:GetValue("CVP_LOTE"))

If 	nOperation != MODEL_OPERATION_DELETE .And. nOperation != MODEL_OPERATION_VIEW

	cQuery := "SELECT X5_DESCRI FROM "+CRLF
	cQuery += RetSqlName('SX5')+" SX5"+CRLF
	cQuery += "WHERE SX5.X5_DESCRI ='"+Alltrim(cLote)+"' "+CRLF
	cQuery += "AND SX5.D_E_L_E_T_ <> '*'"+CRLF
	
	IF SELECT(cAlias) > 0
		(cAlias)->(DBCLOSEAREA())
	ENDIF
	                                        
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAlias )
	
	If (cAlias)->(!EOF())
		IF LEN(Alltrim(cLote)) < 5
			If !oModelAba1:LoadValue("CVP_LOTE","00"+cLote)
				aErro := oModel:GetErrorMessage()
				Help("",1,"HELP","CTBA001",aErro[5]+" - "+aErro[6],1,0)
			EndIf
		EndIf
	EndIf
	
	IF SELECT(cAlias) > 0
		(cAlias)->(DBCLOSEAREA())
	ENDIF
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldLinhaGrid1
Valida o Sublote

@author David Moraes

@return Retorna booleano se permite a gravação  
@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function VldLinhaGrid1(oModel)
Local oModelAba1 := oModel:GetModel(	'CVPGRID1'	)
Local nOperation := oModel:GetOperation()
Local lRet       := .T.

If 	nOperation != MODEL_OPERATION_DELETE .And.;
	nOperation != MODEL_OPERATION_VIEW
	
	If !Empty(oModelAba1:GetValue("CVP_LOTE"))
		If Empty(oModelAba1:GetValue("CVP_SUBLOT")) 
			Help("",1,"HELP","VLDLINCTBA",STR0005,1,0) //"Favor informar um Lote Contábil!"
			lRet := .F.		                                       
		EndIf
	EndIf
	
	If !Empty(oModelAba1:GetValue("CVP_SUBLOT"))
		If Empty(oModelAba1:GetValue("CVP_LOTE")) 
			Help("",1,"HELP","VLDLINCTBA",STR0005,1,0) //"Favor informar um Lote Contábil!"
			lRet := .F.		                                       
		EndIf
	EndIf
EndIf

Return lRet