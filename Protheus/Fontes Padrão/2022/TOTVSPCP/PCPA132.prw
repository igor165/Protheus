#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA132.CH"

Static aLinhas := {}

/*/{Protheus.doc} PCPA132()
Conforme o período informado em tela, serão listados os períodos sem calendário
@author Marcelo Neumann
@since 23/07/2018
@version 1.0
@return NIL
/*/
Function PCPA132()

	Local aArea := GetArea()

	//Proteção do fonte para não ser utilizado pelos clientes neste momento.
	If !(FindFunction("RodaNewPCP") .And. RodaNewPCP())
		HELP(' ',1,"Help" ,,STR0009,2,0,,,,,,) //"Rotina não disponível nesta release."
		Return
	EndIf

	If Pergunte("PCPA132N",.T.)
		P132Proces()
	EndIf

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author Marcelo Neumann
@since 23/07/2018
@version 1.0
@return oModel
/*/
Static Function ModelDef()

	Local oModel
	Local oStruCab := P132StrCab(.T.)
	Local oStruDet := P132StrDet(.T.)

	oModel := MPFormModel():New("PCPA132")

	//Mestre
	oModel:AddFields( "MASTER", /*cOwner*/, oStruCab, , ,{|| P132LoadM()})
	oModel:GetModel ( "MASTER" ):SetDescription(STR0001)
	oModel:GetModel ( "MASTER" ):SetOnlyQuery()

	//Detalhe
	oModel:AddGrid ( "DETAIL", "MASTER", oStruDet, , , , ,{|| P132LoadD()})
	oModel:GetModel( "DETAIL" ):SetDescription(STR0001)
	oModel:GetModel( "DETAIL" ):SetOptional( .T. )
	oModel:GetModel( "DETAIL" ):SetOnlyQuery()

	//Demais definições do modelo
	oModel:SetPrimaryKey( {} )
	oModel:SetDescription(STR0001)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author Marcelo Neumann
@since 23/07/2018
@version 1.0
@return oView
/*/
Static Function ViewDef()

	Local oModel   := FWLoadModel("PCPA132")
	Local oStruCab := P132StrCab(.F.)
	Local oStruDet := P132StrDet(.F.)
	Local oView

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField("VIEW_MASTER", oStruCab, "MASTER" )
	oView:AddGrid( "VIEW_DETAIL", oStruDet, "DETAIL" )
	oView:SetViewProperty("VIEW_DETAIL", "GRIDSEEK")

	oView:CreateHorizontalBox( "HEADER",   0 ) //Não exibe cabeçalho
	oView:CreateHorizontalBox( "DETAIL", 100 )

	oView:SetOwnerView( "VIEW_MASTER", "HEADER" )
	oView:SetOwnerView( "VIEW_DETAIL", "DETAIL" )

	oView:SetViewCanActivate( {|oView| P132ViewAc(oView) } )

	oView:AddUserButton(STR0002, "", {|oModel| P132IncCal(oModel) }, , , MODEL_OPERATION_VIEW, .T.) //"Novo Calendário"

Return oView

/*/{Protheus.doc} P132ViewAc
Valida se existem dados para serem exibidos
@author Marcelo Neumann
@since 23/07/2018
@version 1.0
@return lAbreTela
/*/
Static Function P132ViewAc(oView)

	Local lAbreTela := .F.

	If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
		If MV_PAR01 <= MV_PAR02
			aLinhas := P132Busca()
			If Empty(aLinhas)
				MsgInfo(STR0007) //"Não existem períodos sem calendários para os parâmetros informados."
			Else
				lAbreTela := .T.
			EndIf
		Else
			MsgInfo(STR0011)//"A data inicial do período deve ser anterior à data final."
			PCPA132()
		EndIf
	Else
		MsgInfo(STR0012)//"Não é possível executar a consulta sem ambas as datas preenchidas."
		PCPA132()
	EndIf

Return lAbreTela

/*/{Protheus.doc} P132StrCab
Monta estrutura de campos do Cabeçalho (não será exibido o cabeçalho)
@author Marcelo Neumann
@since 23/07/2018
@version 1.0
@return oStru
/*/
Static Function P132StrCab(lModel)

	Local oStru := NIL

	//MVC exige que tenha campo no modelo Mestre - Esses campos não são exibidos na VIEW
	If lModel
		oStru := FWFormModelStruct():New()
		oStru:AddField(STR0004,STR0004,"CABECALHO","C",1,0,NIL,NIL,NIL,.F.,NIL,NIL,NIL,.T.) //"Cabeçalho"
	Else
		oStru := FWFormViewStruct():New()
		oStru:AddField("CABECALHO","01",STR0004,STR0004,NIL,"C","",NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL,NIL) //"Cabeçalho"
	EndIf

Return oStru

/*/{Protheus.doc} P132StrCab
Monta estrutura de campos para modelo e view do Grid
@author Marcelo Neumann
@since 23/07/2018
@version 1.0
@return oStru
/*/
Static Function P132StrDet(lModel)

	Local oStru := NIL

	If lModel
		oStru := FWFormModelStruct():New()
		// [01]  C   Titulo do campo  - Produto
		// [02]  C   ToolTip do campo - Código do Produto
		// [03]  C   Id do Field
		// [04]  C   Tipo do campo
		// [05]  N   Tamanho do campo
		// [06]  N   Decimal do campo
		// [07]  B   Code-block de validação do campo
		// [08]  B   Code-block de validação When do campo
	 	// [09]  A   Lista de valores permitido do campo
	 	// [10]  L   Indica se o campo tem preenchimento obrigatório
		// [11]  B   Code-block de inicializacao do campo
		// [12]  L   Indica se trata-se de um campo chave
		// [13]  L   Indica se o campo pode receber valor em uma operação de update.
		// [14]  L   Indica se o campo é virtual
		oStru:AddField( RetTitle("VX_DATAINI"),RetTitle("VX_DATAINI"),"DET_DATAINI","D",GetSx3Cache("VX_DATAINI","X3_TAMANHO"),0,NIL,NIL,NIL,.F.,NIL,NIL,NIL,.T. )
		oStru:AddField( RetTitle("VX_DATAFIM"),RetTitle("VX_DATAFIM"),"DET_DATAFIM","D",GetSx3Cache("VX_DATAFIM","X3_TAMANHO"),0,NIL,NIL,NIL,.F.,NIL,NIL,NIL,.T. )
		oStru:AddField( STR0010,STR0010,"DET_QUANT","C",10,0,NIL,NIL,NIL,.F.,NIL,NIL,NIL,.T. )//Dias no periodo
	Else
		oStru := FWFormViewStruct():New()
		// [01]  C   Nome do Campo
		// [02]  C   Ordem
		// [03]  C   Titulo do campo
		// [04]  C   Descricao do campo
		// [05]  A   Array com Help
		// [06]  C   Tipo do campo
		// [07]  C   Picture
		// [08]  B   Bloco de Picture Var
		// [09]  C   Consulta F3
		// [10]  L   Indica se o campo é alteravel
		// [11]  C   Pasta do campo
		// [12]  C   Agrupamento do campo
		// [13]  A   Lista de valores permitido do campo (Combo)
		// [14]  N   Tamanho maximo da maior opção do combo
		// [15]  C   Inicializador de Browse
		// [16]  L   Indica se o campo é virtual
		// [17]  C   Picture Variavel
		// [18]  L   Indica pulo de linha após o campo

		oStru:AddField( "DET_DATAINI","01",RetTitle("VX_DATAINI"),RetTitle("VX_DATAINI"),NIL,"D","",NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL,NIL )
		oStru:AddField( "DET_DATAFIM","02",RetTitle("VX_DATAFIM"),RetTitle("VX_DATAFIM"),NIL,"D","",NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL,NIL )
		oStru:AddField( "DET_QUANT","03",STR0010,STR0010,NIL,"C","",NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL,NIL )//Dias no periodo
	EndIf

Return oStru

/*/{Protheus.doc} P132Proces
Função para abertura da tela
@author Marcelo Neumann
@since 23/07/2018
@version 1.0
@return Nil
/*/
Static Function P132Proces()

	Local oModel	:= FWLoadModel("PCPA132")
	Local aButtons	:= { {.F.,Nil},;        // 1 - Copiar
	                     {.F.,Nil},;        // 2 - Recortar
	                     {.F.,Nil},;        // 3 - Colar
	                     {.F.,Nil},;        // 4 - Calculadora
	                     {.F.,Nil},;        // 5 - Spool
	                     {.F.,Nil},;        // 6 - Imprimir
	                     {.F.,""} ,;        // 7 - "Cancelar"
	                     {.T.,STR0008},;    // 8 - "Fechar"
	                     {.F.,Nil},;        // 9 - WalkTrhough
	                     {.F.,Nil},;        // 10 - Ambiente
	                     {.F.,Nil},;        // 11 - Mashup
	                     {.F.,Nil},;        // 12 - Help
	                     {.F.,Nil},;        // 13 - Formulário HTML
	                     {.F.,Nil} }        // 14 - ECM

	FWExecView(STR0001,"PCPA132",OP_PESQUISAR,/*oDlg*/,{||.T.},/*bOk*/,50,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,oModel)

Return Nil

/*/{Protheus.doc} P132LoadM()
Função para carregar o cabeçalho (não exibido)
@author Marcelo Neumann
@since 23/07/2018
@version 1.0
/*/
Static Function P132LoadM()

	Local aLoad := {" "}

Return aLoad

/*/{Protheus.doc} P132LoadD()
Função para carregar o Grid
@author Marcelo Neumann
@since 23/07/2018
@version 1.0
/*/
Static Function P132LoadD()

	Local aLoad := {}

	If Empty(aLinhas)
		aLoad := P132Busca()
	Else
		aLoad := aClone(aLinhas)
	EndIf

Return aLoad

/*/{Protheus.doc} P132Busca()
Função para carregar o Grid
@author Marcelo Neumann
@since 23/07/2018
@version 1.0
/*/
Static Function P132Busca()

	Local aLoad      := {}
	Local cAliasCal  := GetNextAlias()
	Local dFimCalAnt := ""
	Local dPerIni    := MV_PAR01
	Local dPerFim    := MV_PAR02

	If !Empty(dPerIni) .And. !Empty(dPerFim)
		BeginSQL Alias cAliasCal
			SELECT SVX.VX_FILIAL, SVX.VX_CALEND, SVX.VX_DATAINI, SVX.VX_DATAFIM
			  FROM %Table:SVX% SVX
			 WHERE SVX.VX_FILIAL  = %XFilial:SVX%
			   AND SVX.VX_DATAINI >= %Exp:MV_PAR01%
			   AND SVX.VX_DATAFIM <= %Exp:MV_PAR02%
			   AND SVX.%NotDel%
			 ORDER BY SVX.VX_DATAINI
		EndSQL

		While !(cAliasCal)->(Eof())
			If Empty(dFimCalAnt)
				If DateDiffDay( dPerIni, STOD((cAliasCal)->VX_DATAINI) ) > 1
					aAdd(aLoad,{0,{ dPerIni, STOD((cAliasCal)->VX_DATAINI) -1,  DateDiffDay(STOD((cAliasCal)->VX_DATAINI), dPerIni) }})
				EndIf
			Else
				If DateDiffDay(dFimCalAnt, STOD((cAliasCal)->VX_DATAINI)) > 1
					aAdd(aLoad,{0,{ dFimCalAnt+1, STOD((cAliasCal)->VX_DATAINI)-1 , DateDiffDay(STOD((cAliasCal)->VX_DATAINI), dFimCalAnt) - 1}})
				EndIf
			EndIf

			dFimCalAnt := STOD((cAliasCal)->VX_DATAFIM)
			(cAliasCal)->(dbSkip())
		End

		If Empty(dFimCalAnt)
			aAdd(aLoad,{0,{ dPerIni, dPerFim, DateDiffDay(dPerFim, dPerIni) + 1 }})
		Else
			If dFimCalAnt < dPerFim
				aAdd(aLoad,{0,{ dFimCalAnt+1, dPerFim , DateDiffDay(dPerFim, dFimCalAnt) }})
			EndIf
		EndIf

		(cAliasCal)->(DbCloseArea())
	EndIf

Return aLoad

/*/{Protheus.doc} P132IncCal()
Atalho para incluir calendário MRP (PCPA132)
@author Marcelo Neumann
@since 23/07/2018
@version 1.0
/*/
Static Function P132IncCal(oModel)

	Local nLine		:= oModel:GetModel("DETAIL"):GetLine()
	Local oModelCal := FwLoadModel("PCPA131")
	Local dDataIni	:= oModel:GetModel("DETAIL"):GetValue("DET_DATAINI", nLine)
	Local dDataFim	:= oModel:GetModel("DETAIL"):GetValue("DET_DATAFIM", nLine)

	oModelCal:SetOperation(MODEL_OPERATION_INSERT)
	oModelCal:Activate()

	If !Empty(dDataIni)
		oModelCal:SetValue("SVX_MASTER","VX_DATAINI",dDataIni)
		oModelCal:SetValue("SVX_MASTER","VX_DATAFIM",dDataFim)
	EndIf

	FWExecView(STR0005,"PCPA131",OP_INCLUIR,/*oDlg*/,{||.T.},/*bOk*/,20,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,oModelCal) //"Incluir Calendário MRP"

Return

