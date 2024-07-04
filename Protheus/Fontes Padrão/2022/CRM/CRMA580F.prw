#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA580F.CH"

#DEFINE NTAM_COD_INT  2

Static _aFilters 	:= {}
Static _aBtnFil	 	:= {}
Static _oBrwFil	 	:= Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580F

Cadastro do Agrupador de Registros Lógico.

@sample	CRMA580F()

@param		Nenhum

@return	Nenhum

@author	Jonatas Martins
@since		03/06/2016
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580F()
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Monta modelo de dados do Agrupador de Registros Lógico.

@sample	ModelDef()

@param		Nenhum

@return	oModel - Objeto com estrutura de dados do modelo

@author	Jonatas Martins
@since		03/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef() 

Local oStructAOL	:= FWFormStruct(1,"AOL",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAOM	:= FWFormStruct(1,"AOM",/*bAvalCampo*/,/*lViewUsado*/)
Local bPosVldGrid	:= {|oMdlGrid| CRM580FVldAOM(oMdlGrid) }
Local oModel 	 	:= Nil

//---------------------------
// Campo de marca da tabela
//---------------------------
oStructAOM:AddField("","","AOM_MARK","L",1,0,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

//--------------------------------------------------------
// Instancia o modelo de dados da Agrupador de Registros
//--------------------------------------------------------
oModel := MPFormModel():New("CRMA580F",/*bPreValidacao*/,/*bPosVldMdl*/,/*bCommitMdl*/,/*bCancel*/)

//-----------------------------------
// ModelField Agrupador x Entidades
//-----------------------------------
oModel:AddFields("AOLMASTER",/*cOwner*/,oStructAOL,/*bPreValidacao*/,/*bPosVldMdl*/,/*bCarga*/)
oModel:AddGrid("AOMDETAIL","AOLMASTER",oStructAOM,/*bLinPre*/,/*bLinePost*/,/*bPreVal*/,bPosVldGrid,/*bLoad*/)

//-----------------
// Relacionamentos
//-----------------
oModel:SetRelation("AOMDETAIL",{{"AOM_FILIAL","xFilial('AOL')"},{"AOM_CODAGR","AOL_CODAGR"}},AOM->(IndexKey(1)))

//----------------------------------------
// Define o grid dos níveis como opcional
//----------------------------------------
oModel:GetModel("AOMDETAIL"):SetOptional(.T.)

// Exibe título
oModel:SetDescription(STR0001) //"Níveis do Agrupador"

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Monta interface do Agrupador Lógico.

@sample	ViewDef()

@param		Nenhum

@return	oView - Objeto com estrutura da interface do Agrupador de Registros Lógico

@author	Jonatas Martins
@since		03/06/2016
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oStructAOL	:= FWFormStruct(2,"AOL",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAOM	:= FWFormStruct(2,"AOM",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel   	:= FWLoadModel('CRMA580F')
Local oView	 	:= Nil

//--------------------------
// Campo de marca da tabela 
//--------------------------
oStructAOM:AddField("AOM_MARK","01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddGrid("VIEW_AOM",oStructAOM,"AOMDETAIL")

//-----------------
// Painel Superior
//-----------------
oView:CreateHorizontalBox("SUPERIOR",50)

//-----------------
// Painel Mediano
//-----------------
oView:CreateHorizontalBox("MEIO",50)

//--------------------------
// Painel vertical no meio
//--------------------------
oView:CreateVerticalBox("MEIO_LEFTH",60,"MEIO")
oView:CreateVerticalBox("MEIO_RIGHT",40,"MEIO")

//-----------------------------
// Cria painel inferior oculto
//-----------------------------
oView:CreateHorizontalBox("INFERIOR",0)

//--------------
// Cria objetos
//--------------
oView:AddOtherObject("OBJ_TREE"		, {|oPanel| CRM580DTree(oPanel,oView,oView:GetModel())})
oView:AddOtherObject("OBJ_FIL_REL"	, {|oPanel| CRMA580BFil(oPanel,oView,oView:GetModel())})

oView:EnableTitleView("OBJ_TREE"	,STR0001)	//"Níveis do Agrupador"
oView:EnableTitleView("OBJ_FIL_REL",STR0002)	//"Filtros Relacionados"

oView:SetOwnerView("OBJ_TREE"		,"SUPERIOR")
oView:SetOwnerView("OBJ_FIL_REL"	,"MEIO")
oView:SetOwnerView("VIEW_AOM"		,"INFERIOR")
	
oView:AddIncrementField("VIEW_AOM","AOM_CODNIV")

Return oView 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580BFil

Monta no panel do MVC os componentes visuais para apresentar os filtros relacionados.

@sample	CRMA580BFil(oPanel,oViewActive,oMdlActive)

@param		oPanel			- Panel AddOtherObject
			oViewActive	- FWFormView Ativa
			oMdlActive		- MPFormModel Ativo

@return	Nenhum

@author	Jonatas Martins
@since		09/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRMA580BFil(oPanel,oViewActive,oMdlActive)

Local oTree		:= CRMA580DGTree()
Local oPanelBtn 	:= Nil
Local oPanelFil 	:= Nil
Local oBtnNew		:= Nil
Local oBtnEdit	:= Nil
Local oBtnDel		:= Nil
Local aSizeOBtn	:= {}

//------------------------
// Cria Painel de botões
//------------------------
oPanelBtn	:= TPanel():New(01,01,"",oPanel,,,,CLR_WHITE,CLR_WHITE,25,25)
oPanelBtn:Align := CONTROL_ALIGN_TOP

//-------------------------------------  
// Obtem Dimensões do Painel de Botões
//-------------------------------------
aSizeOBtn := FWGetDialogSize(oPanelBtn)

//----------------------------------
// Cria Botões e Adiciona ao Painel
//----------------------------------
@01,01 To aSizeOBtn[3],aSizeOBtn[4] OF oPanelBtn PIXEL

oBtnNew 	:= TButton():New(005,005,STR0003,oPanelBtn,{|| CRM580FMFil(oTree,oViewActive,oMdlActive,1) },40,15,,,.F.,.T.,.F.,,.F.,{|| .F. },,.F. ) //"+ Criar"
oBtnEdit	:= TButton():New(005,050,STR0004,oPanelBtn,{|| CRM580FMFil(oTree,oViewActive,oMdlActive,2) },40,15,,,.F.,.T.,.F.,,.F.,{|| .F. },,.F. )//"Editar"
oBtnDel 	:= TButton():New(005,095,STR0005,oPanelBtn,{|| CRM580FMFil(oTree,oViewActive,oMdlActive,3) },40,15,,,.F.,.T.,.F.,,.F.,{|| .F. },,.F. )//"Excluir"

_aBtnFil := {oBtnNew,oBtnEdit,oBtnDel}

//-------------------------
// Cria Painel de Filtros
//-------------------------
oPanelFil	:= TPanel():New(01,01,"",oPanel,,,,CLR_WHITE,CLR_WHITE,100,100)
oPanelFil:Align := CONTROL_ALIGN_ALLCLIENT

//----------------------------------
// Cria Browse com dados do filtro
//----------------------------------
CRM580BrwFil(oPanelFil)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRM580BrwFil

Monta o browse para listar os filtros do nível selecionado.

@sample	CRM580BrwFil(oPanelFil)

@param		oPanelFil	- Panel para montar browse.

@return	Nenhum

@author	Jonatas Martins
@since		09/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580BrwFil(oPanelFil)

Local oColluns	:= Nil

_aFilters := {}

DEFINE FWBROWSE _oBrwFil DATA ARRAY ARRAY _aFilters LINE BEGIN 1 OF oPanelFil

	//---------------------------------------------------------
	// Adiciona colunas da tabela dos indicadores de conversao
	//---------------------------------------------------------
	ADD COLUMN oColluns DATA &("{ || _aFilters[_oBrwFil:At()][2]}") TITLE "" SIZE 10 OF _oBrwFil //"Expressão Literal / Nome"

	_oBrwFil:DisableReport()
	_oBrwFil:OptionConfig(.F.)

ACTIVATE FWBROWSE _oBrwFil

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRM580FwFil

Manipula o objeto FWFilterEdit (Criar, Alterar Excluir).

@sample	CRM580FwFil(oTree,oViewActive,oMdlActive,nOpcFil)

@param		ExpO1 - Objeto DbTree
			ExpO2 - FWFormView Ativa
			ExpO3 - MPFormModel Ativo
			ExpO4 - Operacao para manipular o filtro(Criar,Alterar,Excluir)

@return	Nenhum

@author	Anderson Silva
@since		19/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580FMFil(oTree,oViewActive,oMdlActive,nOpcFil)
Local oMdlAOL			:= oMdlActive:GetModel("AOLMASTER")
Local oMdlAOMGrid		:= oMdlActive:GetModel("AOMDETAIL")
Local oFilEdit			:= Nil
Local aExprFilEdit		:= {}
Local aFields 			:= {}
Local cType 			:= oMdlAOL:GetValue("AOL_LOGTIP")
Local nLength 			:= oMdlAOL:GetValue("AOL_LOGTAM")
Local nDecimal			:= oMdlAOL:GetValue("AOL_LOGDEC")
Local cPicture			:= oMdlAOL:GetValue("AOL_LOGPIC")
Local cNameFil			:= ""	
Local cIdFilter			:= ""
Local cDomain			:= ""
Local cCTDomain			:= ""
Local cXml				:= ""
Local nPos				:= 0
Local lRetorno 			:= .T.

Private xCRM580WC  		:= Nil //Wildcard para construção do filtro.

If oMdlAOMGrid:SeekLine({{"AOM_CODNIV",AllTrim(oTree:GetCargo())}})  

	If ( nOpcFil == 1 .OR. nOpcFil == 2 )
		//-------------------------------------------------------------------
		// Cria o objeto do filtro. 
		//-------------------------------------------------------------------
		If ( cType == "1" )
			cType 		:= "C"
			xCRM580WC	:= ""
		ElseIf( cType == "2" ) 
			cType 		:= "N"
			xCRM580WC	:= 0
		ElseIf( cType == "3" ) 
			cType 		:= "D"
			xCRM580WC	:= cTod(" / / ") 
		EndIf 

		aFields	:= {{"xCRM580WC",STR0006, cType, nLength, nDecimal, cPicture,{},"",{||.T.},""}} //"Conteudo"    
		
		//-------------------------------------------------------------------
		// Cria o objeto do filtro. 
		//-------------------------------------------------------------------
		oFilEdit := FWFilterEdit():New()
		oFilEdit:DisableExpression()
		oFilEdit:DisableFunction()
		oFilEdit:SetField(aFields) 
	EndIf

	If ( nOpcFil == 1 )
		//-------------------------------------------------------------------
		// Inclusão de filtro.
		//-------------------------------------------------------------------
		cIdFilter := oMdlAOL:GetValue("AOL_CODAGR")+oMdlAOMGrid:GetValue("AOM_CODNIV")+StrZero(Len(_aFilters)+1,2)
		oFilEdit:SetID(cIdFilter)
	ElseIf nOpcFil == 2 
		//-------------------------------------------------------------------
		// Alteração de filtro.
		//-------------------------------------------------------------------
		If Len(_aFilters) > 0
			oFilEdit:SetFilter( _aFilters[ _oBrwFil:At() ][4] )
		Else
			MsgAlert(STR0008) //"Não há filtros cadastrados!"
			lRetorno := .F.
		EndIf
	ElseIf  nOpcFil == 3 
		//-------------------------------------------------------------------
		// Exclusão de filtro.
		//-------------------------------------------------------------------	
		If Len(_aFilters) > 0
			If MsgYesNo(STR0009) //"Deseja excluir o filtro selecionado?"
				aDel(_aFilters, _oBrwFil:At() )
				aSize(_aFilters, Len( _aFilters ) - 1 )				
			Else
				lRetorno := .F.
			EndIf
		Else
			MsgAlert(STR0008) //"Não há filtros cadastrados!"
			lRetorno := .F.
		EndIf
	EndIf
	
	//-------------------------------------------------
	// Exibe tela de filtro na Inclusão ou Alteração
	//-------------------------------------------------
	If lRetorno .And. ( nOpcFil == 1 .Or. nOpcFil == 2 )
		oFilEdit:Activate()
	  
		//-------------------------------------------------
		// Captura retorno do filtro montado pelo usuário
		//-------------------------------------------------
		aExprFilEdit := aClone(oFilEdit:GetExpression())
	
		If Len(aExprFilEdit) > 0
			cNameFil 	:= oFilEdit:GetName()
			cNameFil 	:= IIF(Empty(cNameFil),oFilEdit:GetCompleteExpression("LITERAL"),cNameFil)
			cIdFilter	:= oFilEdit:GetID()
			nPos 		:= aScan(_aFilters,{|x| x[3] == cIdFilter})
			
			If nPos == 0
				aAdd(_aFilters,{.T.,cNameFil,cIdFilter,aExprFilEdit,cDomain,cCTDomain})
			Else
				_aFilters[nPos][1] := .F.
				_aFilters[nPos][2] := cNameFil
				_aFilters[nPos][3] := cIdFilter
				_aFilters[nPos][4] := aExprFilEdit
				_aFilters[nPos][5] := cDomain
				_aFilters[nPos][6] := cCTDomain  
			EndIf
		EndIf
		
		//--------------------------------------
		// Destroi obejto de filtro após o uso
		//--------------------------------------
		oFilEdit:Destroy() 
	EndIf
	
	//------------------------------------------------
	// Insere expressão do filtro no campo AOM_LOGEXP
	//------------------------------------------------
	If Len(_aFilters) > 0
		If lRetorno 
			cXml := CRMA580MXml(_aFilters)
			oMdlAOMGrid:SetValue("AOM_FILXML",cXml)
		EndIf
	Else
		oMdlAOMGrid:SetValue("AOM_FILXML",Space(TamSx3("AOM_FILXML")[1]))
	EndIf
	
	//--------------------------------------------
	// Atualiza browse de exibição dos filtros
	//--------------------------------------------
	_oBrwFil:SetArray(_aFilters)
	_oBrwFil:Refresh()
EndIf

oViewActive:Refresh()
oTree:SetFocus()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRMA580FNFil

Carrega os filtros relacinado ao nivel marcado no browse de filtros relacionados.

@sample	CRMA580FNFil(oTree,oMdlActive)

@param		oTree		- Objeto DbTree
			oMdlActive	- MPFormModel Ativo

@return	Nenhum

@author	Jonatas Martins
@since		15/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580FNFil(oTree,oMdlActive)

Local oMdlAOMGrid		:= Nil
Local cXml				:= ""
Local nX				:= 0
Local aFilAux			:= {}

Default oMdlActive := FwModelActive()

_aFilters	:= {}
If oMdlActive <> Nil .And. _oBrwFil <> Nil

	oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
	
	If oMdlAOMGrid:SeekLine({{"AOM_CODNIV",AllTrim(oTree:GetCargo())}})
		cXml:= oMdlAOMGrid:GetValue("AOM_FILXML")
		If !Empty(cXml)
			cXml	:= StrTran(cXml, "V.", "xCRM580WC") //Troca o Wildcard para passar no novo parser do framework
			aFilAux := CRMA580XTA(cXml)  
			For nX := 1 To Len(aFilAux)
				aAdd(_aFilters,{.T.,aFilAux[nX][1],aFilAux[nX][9],aFilAux[nX],aFilAux[nX][11],aFilAux[nX][12]})
			Next nX
			_oBrwFil:SetArray(_aFilters)
			_oBrwFil:Refresh()
		EndIf
	EndIf

	//--------------------------------------------
	// Libera os botoes para manipular o filtros
	//--------------------------------------------
	CRMA580FWhen(_aBtnFil,.T.)  
EndIf 

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRMA580FWhen

Bloqueia e Desbloqueia os campos para manipulação dos filtros.

@sample	CRMA580FWhen(aButtons,lWhen)

@param		aButtons	- Array com os botões
			lWhen		- Flag para bloquear ou desbloquear

@return	Nenhum

@author	Jonatas Martins
@since		15/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580FWhen(aButtons,lWhen)

Local nX 		:= 0

//-----------------------------------------------------------------------------
// Quando formulario for visual nao habilita os botoes criar editar e excluir
//-----------------------------------------------------------------------------
For nX := 1 To Len(aButtons)
	aButtons[nX]:bWhen  := {|| lWhen }
Next nX

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580FFClr

Limpa os filtros aplicado no browse.

@sample	CRMA580FFClr()

@param		oMdlActive	- Modelo de dados ativo

@return	Nenhum

@author	Jonatas Martins
@since		15/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580FFClr()

Local aFilters	:= {}

_oBrwFil:SetArray(aFilters)
_oBrwFil:Refresh()
CRMA580FWhen(_aBtnFil,.F.)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580FComp

Monta os componentes visuais para avaliar o agrupador logico.

@sample	CRMA580FComp(oPnlLogic,oTree,oMdlActive,oViewActive)

@param		oPanel			- Panel criado no MVC
			oTree 			- Componente DbTree
			oMdlActive	 	- Model ativo do Agrupador
			oViewActive	- View ativa do Agrupador			
	
@return	Nenhum

@author	Anderson Silva
@since		18/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580FComp(oPnlLogic,oTree,oMdlActive,oViewActive)

Local oBtnAval	:= Nil
Local oGetExpr	:= Nil
Local xGetExpr	:= Nil
Local oSayExpr	:= Nil
Local cPicExpr	:= AllTrim(AOL->AOL_LOGPIC)
Local cTipo		:= ""
Local nTamGet 	:= 0
Local aGroupMark	:= CRM580ERNvl(oMdlActive,/*lSelection*/)

Default oPnlLogic 	:= Nil 
Default oTree		 	:= Nil
Default oMdlActive 	:= Nil
Default oViewActive	:= Nil

Do Case
	//Caracter
	Case AOL->AOL_LOGTIP == "1"
		cTipo	:= "C"
		xGetExpr := Space(AOL->AOL_LOGTAM)
		If Empty(cPicExpr)
			cPicExpr := "@S23"
		EndIf
	//Numerico	
	Case AOL->AOL_LOGTIP == "2"
		cTipo	:= "N"
		xGetExpr := 0
		If Empty(cPicExpr)
			cPicExpr := FwSuggestP(AOL->AOL_LOGTAM,AOL->AOL_LOGDEC) 
		EndIf 
	Case AOL->AOL_LOGTIP == "3"
		cTipo	:= "D"
		xGetExpr := cTod(" / / ")
		cPicExpr := "@D"
EndCase

nTamGet := (CalcFieldSize(cTipo,AOL->AOL_LOGTAM,AOL->AOL_LOGDEC,cPicExpr)+10)
oSayExpr	:= TSay():New(008,001,{|| STR0010 },oPnlLogic,,,,,,.T.,CLR_BLACK,CLR_WHITE)	//"Expressão:" 
oGetExpr	:= TGet():New(006,035,{|u| If( PCount() > 0, xGetExpr := u, xGetExpr) },oPnlLogic,nTamGet,10,AllTrim(AOL->AOL_LOGPIC),,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,,.T.)
oBtnAval 	:= TButton():New(005,(036+nTamGet),STR0011,oPnlLogic,{|| CRMA580FEval( oTree, oMdlActive, oViewActive, AOL->AOL_CODAGR, xGetExpr )  },40,15,,,.F.,.T.,.F.,,.F.,{|| CRMA580FBtn() },,.F.) //"Avaliar"

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580FAvl

Monta a interface para avaliação do agrupador logico.

@sample	CRMA580FAvl()

@param		Nenhum
	
@return	Nenhum

@author	Anderson Silva
@since		18/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580FAvl() 

Local aCodAgrup	:= {AOL->AOL_CODAGR}
Local lExecView	:= .T.
Local cTitView	:= STR0012 	//"Avaliação do Agrupador Lógico"
Local lEvalLogic	:= .T.

If AOL->AOL_TIPO == "3"
	CRMA580E(aCodAgrup,/*lParents*/,/*lMarkAll*/,lExecView,cTitView,/*lSelection*/,/*aFilEnt*/,/*lF3*/,lEvalLogic)
Else
	MsgAlert(STR0013) //"Por favor, selecione um agrupador do tipo lógico!"
EndIf	

Return Nil
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580FEval

Faz a avaliacao no agrupador logico da expressao passada pela usuario

@sample	CRMA580FEval(oTree,oMdlActive,oViewActive,aGroupMark,xGetExpr)

@param		oTree 			- Componente DbTree
			oMdlActive	 	- Model ativo do Agrupador
			oViewActive		- View ativa do Agrupador
			cPool			- Agrupador
			xGetExpr		- Expressao para ser avaliada
			
@return	Nenhum

@author	Anderson Silva
@since		18/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRMA580FEval(oTree,oMdlActive,oViewActive, cPool ,xGetExpr)

Local aRetorno 	 := {}
Local oMdlAOMGrid	 := Nil
	
aRetorno := CRMA580Group( cPool, {{"X",xGetExpr}} )
		
If !Empty(aRetorno[1])
	If oTree:TreeSeek(aRetorno[2])
		CRMA580DTClick(oViewActive,oMdlActive)
	EndIf
Else
	MsgAlert(STR0014) //Este agrupador não atende esta expressão!"
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580FVldAOM

Pos Validacao do ModelGrid Niveis do Agrupador

@sample	CRM580FVldAOM(oMdlAOMGrid)

@param		oMdlAOMGrid, Objeto, ModelGrid Niveis do Agrupador

@return	Nenhum

@author	Jonatas Martins
@since		31/07/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580FVldAOM(oMdlAOMGrid)

Local nX 			:= 0
Local lRetorno	:= .T.

For nX := 1 To oMdlAOMGrid:Length()
	oMdlAOMGrid:GoLine(nX)
	If !oMdlAOMGrid:IsDeleted() .And. Empty(oMdlAOMGrid:GetValue("AOM_FILXML"))
		Help("",1,"CRM580FVZO",,STR0015+oMdlAOMGrid:GetValue("AOM_DESCRI")+STR0016,1) //"O nível "###"não possui filtros relacionados."    
		lRetorno := .F.
		Exit
	EndIf
Next nX 

Return(lRetorno)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580FBtn

Função que habilita/desabilita o botão de "AVALIAR" no agrupador lógico

@sample	CRMA580FBtn()

@param		Nenhum

@return		lRet, logico, Verdadeiro/Falso

@author		Jonatas Martins
@since		17/09/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRMA580FBtn()

Local cAliasTmp	:= GetNextAlias()
Local lRet			:= .T.

//--------------------------------
// Consulta quantidade de níveis
//--------------------------------
BeginSql Alias cAliasTmp
	SELECT COUNT(AOM_CODNIV) TOTAL
	FROM %Table:AOM%
	WHERE AOM_FILIAL = %xFilial:AOM%
		AND AOM_CODAGR = %Exp:AOL->AOL_CODAGR%
		AND %NotDel%
EndSql

//---------------------------------------
// Avalia se existem níveis cadastrados
//---------------------------------------
If (cAliasTmp)->( Eof() ) .Or. (cAliasTmp)->TOTAL <= 0 
	lRet := .F.
EndIf

(cAliasTmp)->( DbCloseArea() )

Return ( lRet )