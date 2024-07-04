#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA580A.CH"

Static _aFilters	:= {}
Static _oBrwFil		:= Nil
Static _oBrwView	:= Nil
Static _aBtnFil		:= {}

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580A

Cadastro de Níveis do Agrupador Dinamico.

@sample		CRMA580A()

@param		Nenhum

@return		Nenhum

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580A()
Return Nil
  
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Monta modelo de dados do Níveis do Agrupador Dinamico.

@sample		ModelDef()

@param		Nenhum

@return		ExpO - Modelo de Dados

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oStructAOL	:= FWFormStruct(1,"AOL",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAOM	:= FWFormStruct(1,"AOM",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel 	 	:= Nil
Local bPosVldGrid	:= {|oMdlGrid| CRM580APVldAOM(oMdlGrid) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo de marca da tabela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructAOM:AddField("","","AOM_MARK","L",1,0,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

// Instancia o modelo de dados da Agrupador de Registros.
oModel := MPFormModel():New("CRMA580A",/*bPreValidacao*/,/*bPosVldMdl*/,/*bCommitMdl*/,/*bCancel*/)

// ModelField Agrupador x Entidades ³
oModel:AddFields("AOLMASTER",/*cOwner*/,oStructAOL,/*bPreValidacao*/,/*bPosVldMdl*/,/*bCarga*/)
oModel:AddGrid("AOMDETAIL","AOLMASTER",oStructAOM,/*bLinPre*/,/*bLinePost*/,/*bPreVal*/,bPosVldGrid,/*bLoad*/)

// Relacionamentos
oModel:SetRelation("AOMDETAIL",{{"AOM_FILIAL","xFilial('AOL')"},{"AOM_CODAGR","AOL_CODAGR"}},AOM->(IndexKey(1)))

oModel:SetDescription(STR0001) // "Níveis do Agrupador"

// Define o grid dos níveis como opcional
oModel:GetModel("AOMDETAIL"):SetOptional(.T.)

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Monta interface do Níveis do Agrupador Dinamico.

@sample		ViewDef()

@param		Nenhum

@return		ExpO - Interface do Agrupador de Registros

@author		Jonatas Martins 
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oStructAOM	:= FWFormStruct(2,"AOM",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel   		:= FWLoadModel('CRMA580A')
Local oView	 		:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo de marca da tabela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructAOM:AddField("AOM_MARK","01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddGrid("VIEW_AOM",oStructAOM,"AOMDETAIL")

//Painel Superior
oView:CreateHorizontalBox("SUPERIOR",40) 

//Painel Vertical
oView:CreateVerticalBox("VERTICAL_TREE"	,60,"SUPERIOR")
oView:CreateVerticalBox("VERTICAL_FIL_REL",40,"SUPERIOR")

//Painel Inferior
oView:CreateHorizontalBox("MEIO",60)

//Oculta a View
oView:CreateHorizontalBox("INFERIOR",0)

//Cria objetos
oView:AddOtherObject("OBJ_TREE"		, {|oPanel| CRM580DTree(oPanel,oView,oView:GetModel())})
oView:AddOtherObject("OBJ_FIL_REL"	, {|oPanel| CRMA580AFil(oPanel,oView,oView:GetModel())})
oView:AddOtherObject("OBJ_BRW_REG"	, {|oPanel| CRMA580BView(oPanel)})

oView:EnableTitleView("OBJ_TREE"	,STR0001)	//"Níveis do Agrupador"
oView:EnableTitleView("OBJ_FIL_REL"	,STR0002)	//"Filtros Relacionados"
oView:EnableTitleView("OBJ_BRW_REG"	,STR0003)	//"Registros"

oView:SetOwnerView("OBJ_TREE"	,"VERTICAL_TREE")
oView:SetOwnerView("OBJ_FIL_REL","VERTICAL_FIL_REL")
oView:SetOwnerView("OBJ_BRW_REG","MEIO")
oView:SetOwnerView("VIEW_AOM"	,"INFERIOR")
	
oView:AddIncrementField("VIEW_AOM","AOM_CODNIV")
 

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580AFil

Monta no panel do MVC os componentes visuais para apresentar os filtros relacionados.

@sample		CRMA580AFil(oPanel,oViewActive,oMdlActive)

@param		ExpO1 - Panel AddOtherObject
			ExpO2 - FWFormView Ativa
			ExpO3 - MPFormModel Ativo

@return		Nenhum

@author		Anderson Silva
@since		26/04/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580AFil(oPanel,oViewActive,oMdlActive)

Local oTree			:= CRMA580DGTree()
Local oPanelBtn 	:= Nil
Local oPanelFil 	:= Nil
Local aSizeOBtn		:= {}
Local oBtnNew		:= Nil
Local oBtnEdit		:= Nil
Local oBtnDel		:= Nil
Local oBtnAppl		:= Nil

// Cria Painel de botões
oPanelBtn	:= TPanel():New(01,01,"",oPanel,,,,CLR_WHITE,CLR_WHITE,25,25)
oPanelBtn:Align := CONTROL_ALIGN_TOP

// Obtem Dimensões do Painel de Botões
aSizeOBtn := FWGetDialogSize(oPanelBtn)

// Cria Botões e Adiciona ao Painel
@01,01 To aSizeOBtn[3],aSizeOBtn[4] OF oPanelBtn PIXEL

oBtnNew	 := TButton():New(005,005,STR0004,oPanelBtn,{|| CRM580FwFil(oTree,oViewActive,oMdlActive,1) },40,15,,,.F.,.T.,.F.,,.F.,{|| .F. },,.F. ) //"+ Criar"
oBtnEdit := TButton():New(005,050,STR0005,oPanelBtn,{|| CRM580FwFil(oTree,oViewActive,oMdlActive,2) },40,15,,,.F.,.T.,.F.,,.F.,{|| .F. },,.F. )//"Editar"
oBtnDel  := TButton():New(005,095,STR0006,oPanelBtn,{|| CRM580FwFil(oTree,oViewActive,oMdlActive,3) },40,15,,,.F.,.T.,.F.,,.F.,{|| .F. },,.F. )//"Excluir"
oBtnAppl := TButton():New(005,140,STR0007,oPanelBtn,{|| CRM580AplFil(oTree,oViewActive,oMdlActive)  },40,15,,,.F.,.T.,.F.,,.F.,{|| .T. },,.F. )//"Aplicar" 

_aBtnFil := {oBtnNew,oBtnEdit,oBtnDel}

// Cria Painel de Filtros
oPanelFil	:= TPanel():New(01,01,"",oPanel,,,,CLR_WHITE,CLR_WHITE,100,100)
oPanelFil:Align := CONTROL_ALIGN_ALLCLIENT

// Cria Browse com dados do filtro
CRM580BrwFil(oPanelFil)

CRMA580DSTree(oTree)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRM580ABWhen

Bloqueia e Desbloqueia os campos para manipulação dos filtros.

@sample		CRM580ABWhen(aButtons,lWhen)

@param		ExpA1 - Array com os botões
			ExpL2 - Flag para bloquear ou desbloquear

@return		Nenhum

@author		Anderson Silva
@since		26/04/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRM580ABWhen(aButtons,lWhen)

Local nX 		:= 0

// Quando formulario for visual nao habilita os botoes criar editar e excluir.
For nX := 1 To Len(aButtons)
	aButtons[nX]:bWhen  := {|| lWhen }
Next nX

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRM580BrwFil

Monta o browse para listar os filtros do nível selecionado.

@sample		CRM580BrwFil(oPanelFil)

@param		ExpO1 - Panel para montar browse.

@return		Nenhum

@author		Anderson Silva
@since		26/04/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580BrwFil(oPanelFil)

Local oColluns	:= Nil

_aFilters := {}

DEFINE FWBROWSE _oBrwFil DATA ARRAY ARRAY _aFilters LINE BEGIN 1 OF oPanelFil

	
	ADD COLUMN oColluns DATA &("{|| _aFilters[_oBrwFil:At()][2] }") TITLE "" SIZE 10 OF _oBrwFil //"Expressão Literal / Nome"

	_oBrwFil:DisableReport()
	_oBrwFil:OptionConfig(.F.)

ACTIVATE FWBROWSE _oBrwFil

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRMA580ALFil

Carrega os filtros relacinado ao nivel marcado no browse de filtros relacionados.

@sample		CRMA580ALFil(oTree,oMdlActive)

@param		ExpO1 - Objeto DbTree
			ExpO2 - MPFormModel Ativo

@return		Nenhum

@author		Anderson Silva
@since		26/04/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580ALFil(oTree,oMdlActive)

Local oMdlAOMGrid		:= Nil
Local cXml				:= ""
Local nX				:= 0
Local aFilAux			:= {}

Default oMdlActive := FwModelActive()

_aFilters	:= {}
oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
If oMdlAOMGrid:SeekLine({{"AOM_CODNIV",AllTrim(oTree:GetCargo())}})
	cXml:= oMdlAOMGrid:GetValue("AOM_FILXML")
	If !Empty(cXml)
		aFilAux := CRMA580XTA(cXml)
		For nX := 1 To Len(aFilAux)
			aAdd(_aFilters,{.T.,aFilAux[nX][1],aFilAux[nX][9],aFilAux[nX],aFilAux[nX][11],aFilAux[nX][12]})
		Next nX
		If _oBrwFil <> Nil 
			_oBrwFil:SetArray(_aFilters)
			_oBrwFil:Refresh()
		EndIf 
	EndIf
EndIf

//Libera os botoes para manipular o filtros
CRM580ABWhen(_aBtnFil,.T.)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRM580FwFil

Manipula o objeto FWFilterEdit (Criar, Alterar Excluir).

@sample		CRM580FwFil(oTree,oViewActive,oMdlActive,nOpcFil)

@param		ExpO1 - Objeto DbTree
			ExpO2 - FWFormView Ativa
			ExpO3 - MPFormModel Ativo
			ExpO4 - Operacao para manipular o filtro(Criar,Alterar,Excluir)

@return		Nenhum

@author		Anderson Silva
@since		26/04/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580FwFil(oTree,oViewActive,oMdlActive,nOpcFil)

Local oMdlAOL			:= oMdlActive:GetModel("AOLMASTER")
Local oMdlAOMGrid		:= oMdlActive:GetModel("AOMDETAIL")
Local cEntidad		:= oMdlAOL:GetValue("AOL_ENTIDA")
Local oFilEdit		:= Nil
Local cIdFilter		:= ""
Local aRelation		:= FWLoadCDom(cEntidad)
Local nPos 			:= 0
Local cXml				:= ""
Local cNameFil		:= ""
Local aExprFilEdit	:= {}
Local lRetorno 		:= .T.
Local nPosDom			:= 0
Local cDomain			:= ""
Local cCTDomain		:= ""

If oMdlAOMGrid:SeekLine({{"AOM_CODNIV",AllTrim(oTree:GetCargo())}})
	
	If nOpcFil == 1 .OR. nOpcFil == 2
		oFilEdit := FWFilterEdit():New(,cEntidad)
		oFilEdit:DisableExpression()
		oFilEdit:DisableFunction()
	EndIf
	
	//Criar Filtro
	If nOpcFil == 1
		
		cIdFilter := oMdlAOL:GetValue("AOL_CODAGR")+oMdlAOMGrid:GetValue("AOM_CODNIV")+StrZero(Len(_aFilters)+1,2)
		oFilEdit:SetID(cIdFilter)
		
		If MsgYesNo(STR0009) //"Deseja criar filtros com tabela relacionada a entidade deste agrupador?"
			//------------------------------------------------------
			// exibe tela para perguntar sobre relacionamentos
			//------------------------------------------------------
			If Len(aRelation) > 0
				aRelation := FwFilterRelation(aRelation)
				oFilEdit:SetRelation(aRelation)
			EndIf
		EndIf
		// Alteração do Filtro 
	ElseIf nOpcFil == 2
		If Len(_aFilters) > 0
			nPos := _oBrwFil:At()    
			cDomain	:= _aFilters[nPos][5]
			cCTDomain	:= _aFilters[nPos][6]
			oFilEdit:SetRelation({{.T.,_aFilters[nPos][4][8],CRM580NTab(_aFilters[nPos][4][8]),_aFilters[nPos][5],_aFilters[nPos][6]}})
			oFilEdit:SetFilter(_aFilters[nPos][4])
		Else
			MsgAlert(STR0015) //Não há filtros cadastrados!
			lRetorno := .F.
		EndIf
		//Exclusão do Filtro
	ElseIf  nOpcFil == 3 
		If Len(_aFilters) > 0
			nPos := _oBrwFil:At()
			If MsgYesNo(STR0011) //"Deseja excluir o filtro selecionado?"
				aDel(_aFilters,nPos)
				aSize(_aFilters,Len(_aFilters)-1)
				CRM580ClrFilBrw()
				_oBrwView:oFwFilter:ExecuteFilter(.T.)
			Else
				lRetorno := .F.
			EndIf
		Else
			MsgAlert(STR0015) //Não há filtros cadastrados!
			lRetorno := .F.
		EndIf
	EndIf
	
	// Ativa o filtro na Inclusão ou Alteração
	If ( lRetorno .And. oFilEdit <> Nil .And. ( nOpcFil == 1 .Or. nOpcFil == 2 ) )
		
		oFilEdit:Activate() 
		
		//--------------------------------------------
		// pega retorno do filtro montado pelo usuário
		//--------------------------------------------
		aExprFilEdit := aClone(oFilEdit:GetExpression())
		
		If Len(aExprFilEdit) > 0
			cNameFil 	:= oFilEdit:GetName()
			cNameFil 	:= IIF(Empty(cNameFil),oFilEdit:GetCompleteExpression("LITERAL"),cNameFil)
			cIdFilter	:= oFilEdit:GetID()
			nPos 		:= aScan(_aFilters,{|x| x[3] ==  cIdFilter})
			
			If ( nOpcFil == 1 ) 
				nPosDom 	:= aScan( aRelation,{|x| x[1] == AlwaysTrue()})
				
				If nPosDom > 0 
				   cDomain		:= aRelation[nPosDom][4]
				   cCTDomain	:= aRelation[nPosDom][5]	
				EndIf
			Else
				If ( _aFilters[nPos][4][8] == cEntidad )
					cDomain		:= ""
					cCTDomain	:= ""
				Endif 
			EndIf 
			
			If nPos == 0
				aAdd(_aFilters,{.F.,cNameFil,cIdFilter,aExprFilEdit,cDomain,cCTDomain})
			Else
				_aFilters[nPos][1] := .F.
				_aFilters[nPos][2] := cNameFil
				_aFilters[nPos][3] := cIdFilter
				_aFilters[nPos][4] := aExprFilEdit
				_aFilters[nPos][5] := cDomain
				_aFilters[nPos][6] := cCTDomain  
			EndIf
		EndIf
		
		oFilEdit:Destroy()
		
	EndIf
	
	If Len(_aFilters) > 0
		If lRetorno 
			cXml := CRMA580MXml(_aFilters)
			oMdlAOMGrid:SetValue("AOM_FILXML",cXml)
		EndIf
	Else
		oMdlAOMGrid:SetValue("AOM_FILXML",Space(TamSx3("AOM_FILXML")[1]))
	EndIf
	
	_oBrwFil:SetArray(_aFilters)
	_oBrwFil:Refresh()
EndIf

oViewActive:Refresh()
oTree:SetFocus()
 
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRMA580BView

Browse para exibir os registros após aplicação do filtro

@sample		CRMA580BView(oPanel)

@param		ExpO1 - Panel AddOtherObject

@return		Nenhum

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRMA580BView(oPanel)

Local cAlias := AOL->AOL_ENTIDA

_oBrwView := FWFormBrowse():New()
_oBrwView:SetOwner(oPanel)
_oBrwView:SetDataTable()
_oBrwView:SetAlias(cAlias)
_oBrwView:SetColumns(CRM580BCol(cAlias))
_oBrwView:SetUseFilter()
_oBrwView:SetSeek()
_oBrwView:SetProfileID("CRMA580A")
_oBrwView:SetClrAlterRow(RGB(241, 241, 241))

//Desabilita componentes do Browse
_oBrwView:DisableReports()
_oBrwView:DisableConfig()
_oBrwView:DisableDetails()
_oBrwView:Activate()
_oBrwView:oFwFilter:DisableAdd()
_oBrwView:oFwFilter:DisableDel()
_oBrwView:oFwFilter:DisableExecute()
_oBrwView:oFwFilter:DisableSave()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRM580AplFil

Aplica os filtros no browse.

@sample		CRM580AplFil(oTree,oViewActive,oMdlActive)

@param		ExpO1 - Objeto DbTree
			ExpO2 - FWFormView Ativa
			ExpO3 - MPFormModel Ativo

@return		Nenhum

@author		Anderson Silva
@since		26/04/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580AplFil(oTree,oViewActive,oMdlActive)

Local oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")

If oMdlAOMGrid:SeekLine({{"AOM_CODNIV",AllTrim(oTree:GetCargo())}})
	
	// Limpa filtros do browse
	CRM580ClrFilBrw()
	
	CRM580MFil(oMdlAOMGrid,oMdlAOMGrid:GetValue("AOM_NIVPAI"))
	_oBrwView:oFwFilter:ExecuteFilter(.T.)
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRM580ClrFilBrw

Limpa filtros do Browse.

@sample	CRM580ClrFilBrw()

@param		Nenhum

@return	Nenhum

@author	Jonatas Martins
@since		17/04/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580ClrFilBrw()

Local aFilters	:= {}
Local nX			:= 0
Local nY			:= 0

//Obtem filtros
aadd(aFilters,_oBrwView:oFwFilter:GetFilter())
aadd(aFilters,_oBrwView:oFwFilter:GetFilterRelation())

//Deleta filtros 
For nX := 1 To Len(aFilters)
	If !Empty(aFilters[nX])
		For nY := 1 To Len(aFilters[nX])
			_oBrwView:oFwFilter:DeleteFilter(aFilters[nX][nY][9])
		Next nY
	EndIf
Next nX

//Refresh Filtro
_oBrwView:oFwFilter:OUIFilter:ListFilter()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRM580MFil

Monta os filtros para serem aplicados no browse.

@sample		CRM580MFil(oMdlAOMGrid,cNivelPai)

@param		ExpO1 - ModelGrid do Nível do Agrupador
			ExpC2 - Código do Nivel Pai

@return		Nenhum

@author		Anderson Silva
@since		26/04/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580MFil(oMdlAOMGrid,cNivelPai,aRelation)
	Local bError 		:= ErrorBlock( { || } )
	Local aToken 		:= {}
	Local aFilAux 		:= {}
	Local aParser		:= {}
	Local cXml			:= ""
	Local cFilter 		:= ""
	Local cExpression	:= ""
	Local cAliasFil		:= ""
	Local cId			:= ""
	Local cDomain		:= ""
	Local cCTDomain		:= ""
	Local nLinha		:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local nToken		:= 0
	
	Default aRelation 	:= {}
	
	If oMdlAOMGrid:GetValue("AOM_MARK")
		cXml := oMdlAOMGrid:GetValue("AOM_FILXML")
		If !Empty(cXml)
			aFilAux := CRMA580XTA(cXml)
			For nY := 1 To Len(aFilAux)
				cFilter 		:= aFilAux[nY][1]
				cExpression		:= CRM580ERel(aFilAux[nY][8],aFilAux[nY][2],aFilAux[nY][3])
				cAliasFil		:= aFilAux[nY][8]
				lFilterAsk		:= aFilAux[nY][7]
				aParser			:= aFilAux[nY][4]
				cId				:= aFilAux[nY][9]
				cDomain 		:= aFilAux[nY][11] 
				cCTDomain 		:= aFilAux[nY][12]
				
				//-------------------------------------------------------------------
				// Recupera os camponentes da expressão.  
				//-------------------------------------------------------------------	
				If ! ( Empty( cExpression ) )
					aToken := StrTokArr( cExpression, "#" )
				EndIf 
				
				//-------------------------------------------------------------------
				// Avalia os componentes da expressão.   
				//-------------------------------------------------------------------
				BEGIN SEQUENCE	
					For nToken := 1 To Len( aToken )	
						If ( "FWMNTFILDT" $ Upper( aToken[nToken] ) )
							aToken[nToken] := &( aToken[nToken] )
						EndIf 
					Next nToken	
				END SEQUENCE	
				
				//-------------------------------------------------------------------
				// Monta a expressão de filtro.  
				//-------------------------------------------------------------------
				cExpression := cBIConcatWSep( "", aToken )			
				
				//-------------------------------------------------------------------
				// Adiciona o filtro no browse.  
				//-------------------------------------------------------------------
				_oBrwView:AddFilter( cFilter, cExpression, .T. , .T. , cAliasFil, .F., aParser, cId )
				
				If ! ( Empty( cDomain ) ) .And. ! ( Empty( cCTDomain ) )
					aAdd( aRelation, { .T., cAliasFil, CRM580NTab( cAliasFil ), cDomain, cCTDomain } )
				EndIf
			Next nY
			
		Else
			MsgAlert(STR0015) //Não há filtros cadastrados!
		EndIf
	EndIf
	
	If oMdlAOMGrid:SeekLine({{"AOM_CODNIV",cNivelPai}})
		nLinha := oMdlAOMGrid:GetLine()
		For nX := nLinha To oMdlAOMGrid:Length()
			oMdlAOMGrid:GoLine(nX)
			If oMdlAOMGrid:GetValue("AOM_CODNIV") == cNivelPai
				CRM580MFil(oMdlAOMGrid,oMdlAOMGrid:GetValue("AOM_NIVPAI"), aRelation)
				oMdlAOMGrid:GoLine(nX)
			EndIf
		Next nX
	EndIf

	
	If Len( aRelation ) > 0
		_oBrwView:oFwFilter:SetRelation ( aRelation, {||.T.} )
	EndIf

	
	ErrorBlock( bError ) 
Return(.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRM580ERel

Verifica se é relacional a mesma tabela de origem

@sample	CRM580ERel(cAliasFil,cExpAdvpl,cExpSQL)

@param		cAliasFil	- Alias de relacionamento do filtro
			cExpAdvpl	- Expressão ADVPL do filtro
			cExpSQL	- Expressão SQL do filtro

@return	cExpress	- Caso o filtro for relacional a mesma tabela de origem retorna a expressão ADVPL

@author	Jonatas Martins
@since		01/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580ERel(cAliasFil,cExpAdvpl,cExpSQL)

Local cExpress := ""

If Empty(cAliasFil) .Or. cAliasFil == AOL->AOL_ENTIDA
	cExpress := cExpAdvpl //Expressão ADVPL
Else //Filtro Relacional
	cExpress := cExpSQL //Expressão SQL
EndIf

Return (cExpress)

//------------------------------------------------------------------------------
/*/{Protheus.doc}  CRM580NTab

Retorna o nome da tabela do relacionamento

@sample	CRM580NTab(cAliasFil)

@param		cAliasFil - Tabela do relacionamento

@return	cNomTab - Nome da tabela do relacionamento

@author	Jonatas Martins
@since		07/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580NTab(cAliasFil)

Local aAreaAtu := GetArea()
Local aAreaSX2 := SX2->(GetArea())
Local cNomTab	 := ""

SX2->(DbSetOrder(1))

If SX2->(DbSeek(cAliasFil))
	cNomTab := AllTrim(X2Nome())
EndIf

RestArea(aAreaSX2)
RestArea(aAreaAtu)

Return (cNomTab)

//------------------------------------------------------------------------------*/
/*/{Protheus.doc} CRM580BCol

Monta as colunas da entidade agrupada para apresentar no browse.

@sample		CRM580BCol(cAlias)

@param		ExpC1 - Entidade Agrupada.

@return		ExpA - Colunas da entidade agrupada

@author		Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580BCol(cAlias)

Local aArea		:= GetArea()
Local aColumns	:= {}
Local nLinha	:= 0
Local cCampo	:= ""

DbSelectArea("SX3")
DbSetOrder(1)//X3_ARQUIVO

If SX3->(DbSeek(cAlias))
	
	While !(SX3->(EOF())) .And. SX3->X3_ARQUIVO == cAlias
		
		If ( X3Uso(SX3->X3_USADO) .AND. SX3->X3_BROWSE == "S" .AND. SX3->X3_CONTEXT <> "V" .AND. SX3->X3_TIPO <> "M" )
			
			AAdd(aColumns,FWBrwColumn():New())
			nLinha := Len(aColumns)
			cCampo := SX3->X3_CAMPO
			If Empty(X3CBox())
				aColumns[nLinha]:SetData(&("{ || " + SX3->X3_CAMPO + " }"))
			Else
				aColumns[nLinha]:SetData(&("{|| X3Combo('"+SX3->X3_CAMPO+"',"+SX3->X3_CAMPO+")}") )
			EndIf
			aColumns[nLinha]:SetTitle(X3Titulo())
			aColumns[nLinha]:SetType(SX3->X3_TIPO)
			aColumns[nLinha]:SetSize(SX3->X3_TAMANHO)
			aColumns[nLinha]:SetDecimal(SX3->X3_DECIMAL)
			
		EndIf
		SX3->(DbSkip())
	End
	
EndIf

RestArea(aArea)

Return(aColumns)

//------------------------------------------------------------------------------
/*/ {Protheus.doc}

Limpa os filtros aplicado no browse.

@sample	CRM580FilClear()

@param		Nenhum

@return		Nenhum

@author		Anderson Silva
@since		31/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580AFClr()

Local aFilters	:= {}

If _oBrwFil <> Nil
	_oBrwFil:SetArray(aFilters)
	_oBrwFil:Refresh()
	CRM580ABWhen(_aBtnFil,.F.) 
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/ {Protheus.doc}

Pos Validacao do ModelGrid Niveis do Agrupador

@sample	CRM580FilClear()

@param		ExpO1 - ModelGrid Niveis do Agrupador

@return		Nenhum

@author		Anderson Silva
@since		31/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580APVldAOM(oMdlAOMGrid)
Local nX 		:= 0
Local lRetorno	:= .T.

For nX := 1 To oMdlAOMGrid:Length()
	oMdlAOMGrid:GoLine(nX)
	If !oMdlAOMGrid:IsDeleted() .And. Empty(oMdlAOMGrid:GetValue("AOM_FILXML"))
		Help("",1,"CRM580FILVZO",,STR0013+oMdlAOMGrid:GetValue("AOM_DESCRI")+STR0014,1) //"O nível "###"não possui filtros relacionados."    
		lRetorno := .F.
		Exit
	EndIf
Next nX 

Return(lRetorno)