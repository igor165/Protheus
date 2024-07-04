#INCLUDE "JURA266.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA266
Classificação de Naturezas

@author Jorge Luis Branco Martins Junior
@since  24/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA266()
	Local oBrowse := Nil
	
	Processa({|| JA266Carga()}, STR0011, STR0010, .F.) // "Aguarde... "###"Carga. Inicial"
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0007) // "Classificação de Naturezas"
	oBrowse:SetAlias("OHP")
	oBrowse:SetLocate()
	JurSetLeg(oBrowse, "OHP")
	JurSetBSize(oBrowse)
	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Jorge Luis Branco Martins Junior
@since  24/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	aAdd(aRotina, {STR0001, "PesqBrw"        , 0, 1, 0, .T.}) //"Pesquisar"
	aAdd(aRotina, {STR0002, "VIEWDEF.JURA266", 0, 2, 0, NIL}) //"Visualizar"
	aAdd(aRotina, {STR0003, "VIEWDEF.JURA266", 0, 3, 0, NIL}) //"Incluir"
	aAdd(aRotina, {STR0004, "VIEWDEF.JURA266", 0, 4, 0, NIL}) //"Alterar"
	aAdd(aRotina, {STR0005, "VIEWDEF.JURA266", 0, 5, 0, NIL}) //"Excluir"
	aAdd(aRotina, {STR0006, "VIEWDEF.JURA266", 0, 8, 0, NIL}) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Classificação de Naturezas

@author Jorge Luis Branco Martins Junior
@since  24/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView      := Nil
	Local oModel     := FWLoadModel("JURA266")
	Local oStructOHP := FWFormStruct(2, "OHP")
	
	oStructOHP:RemoveField("OHP_COD")
	oStructOHP:RemoveField("OHP_TIPOMV")
	
	JurSetAgrp('OHP',, oStructOHP)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("JURA266_VIEW", oStructOHP, "OHPMASTER")
	oView:CreateHorizontalBox("FORMFIELD", 100)
	oView:SetOwnerView("JURA266_VIEW", "FORMFIELD")
	oView:SetDescription(STR0007) // "Classificação de Naturezas"
	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Classificação de Naturezas

@author Jorge Luis Branco Martins Junior
@since  24/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     := NIL
	Local oStructOHP := FWFormStruct(1, "OHP")
	
	oModel:= MPFormModel():New("JURA266", /*Pre-Validacao*/, {|oModel| JURA266TOK(oModel)}, /*Commit*/, /*Cancel*/)
	oModel:AddFields("OHPMASTER", NIL, oStructOHP, /*Pre-Validacao*/, /*Pos-Validacao*/)
	oModel:SetDescription(STR0008) //"Modelo de Dados de Classificação de Naturezas"
	oModel:GetModel("OHPMASTER"):SetDescription( STR0009 ) //"Dados de Classificação de Naturezas"
	
	JurSetRules(oModel, 'OHPMASTER',, 'OHP')

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA266Carga
Realiza a carga inicial da configuração das classificações de naturezas

@Return lRet   .T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since  24/10/2018
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA266Carga()
	Local aCampos := {"OHP_FILIAL", "OHP_COD", "OHP_ORIGEM", "OHP_DESC", "OHP_DEFLAN", "OHP_TIPOMV"}
	Local aDados  := {}
	Local nI      := 0
	Local cFilOHP := xFilial("OHP")
	
	// Contas a Pagar
	
	//            Filial , Código, Origem, Descrição                 , Def. Lancto     , Tipo da Mov.
	aAdd(aDados, {cFilOHP, '001' , '1'   , STR0012 + " / " + STR0017 , '1' /*Origem*/  , 'DC'        }) // "Desconto / Contas a Pagar"
	aAdd(aDados, {cFilOHP, '002' , '1'   , STR0013 + " / " + STR0017 , '2' /*Destino*/ , 'MT'        }) // "Multa / Contas a Pagar"
	aAdd(aDados, {cFilOHP, '003' , '1'   , STR0014 + " / " + STR0017 , '2' /*Destino*/ , 'JR'        }) // "Taxa de Permanência + Juros + Acréscimos / Contas a Pagar"
	aAdd(aDados, {cFilOHP, '004' , '1'   , STR0015 + " / " + STR0017 , '3' /*Valor*/   , 'VA'        }) // "Valores Acessórios / Contas a Pagar"
	aAdd(aDados, {cFilOHP, '009' , '1'   , STR0021 + " / " + STR0017 , '1' /*IRRF*/    , 'IR'        }) // "IRRF de terceiros / Contas a Pagar"
	aAdd(aDados, {cFilOHP, '010' , '1'   , STR0022 + " / " + STR0017 , '1' /*ISS*/     , 'IS'        }) // "ISS de terceiros / Contas a Pagar"
	aAdd(aDados, {cFilOHP, '011' , '1'   , STR0023 + " / " + STR0017 , '1' /*INSS*/    , 'IN'        }) // "INSS de terceiros / Contas a Pagar"
	aAdd(aDados, {cFilOHP, '012' , '1'   , STR0024 + " / " + STR0017 , '1' /*PIS*/     , 'PI'        }) // "PIS de terceiros / Contas a Pagar"
	aAdd(aDados, {cFilOHP, '013' , '1'   , STR0025 + " / " + STR0017 , '1' /*COFINS*/  , 'CO'        }) // "COFINS de terceiros / Contas a Pagar"
	aAdd(aDados, {cFilOHP, '014' , '1'   , STR0026 + " / " + STR0017 , '1' /*CSLL*/    , 'CS'        }) // "CSLL de terceiros / Contas a Pagar"
	
	// Contas a Receber
	
	//            Filial , Código, Origem, Descrição                 , Def. Lancto     , Tipo da Mov.
	aAdd(aDados, {cFilOHP, '005' , '2'   , STR0013 + " / " + STR0018 , '1' /*Origem*/  , 'MT'        }) // "Multa / Contas a Receber"
	aAdd(aDados, {cFilOHP, '006' , '2'   , STR0014 + " / " + STR0018 , '1' /*Origem*/  , 'JR'        }) // "Taxa de Permanência + Juros + Acréscimos / Contas a Receber"
	aAdd(aDados, {cFilOHP, '007' , '2'   , STR0015 + " / " + STR0018 , '3' /*Valor*/   , 'VA'        }) // "Valores Acessórios / Contas a Receber"
	
	// Participante

	//            Filial , Código, Origem, Descrição                 , Def. Lancto           , Tipo da Mov.
	aAdd(aDados, {cFilOHP, '008' , '4'   , STR0020                   , '4' /*Não se aplica*/ , 'NP'  }) // "Natureza pai para as naturezas de participantes"
	aAdd(aDados, {cFilOHP, '015' , '4'   , STR0027                   , '4' /*Não se aplica*/ , 'FP'  }) // "Natureza pai para fechamento de conta de participantes" 

	ProcRegua(Len(aDados))
	
	dbSelectArea('OHP')
	OHP->(DBSetOrder(1)) // OHP_FILIAL + OHP_ORIGEM + OHP_TIPOMV
	
	For nI := 1 To Len(aDados)
	
		IncProc(STR0019 + aDados[nI][4]) // "Configurando Classificação: "
	
		If Empty(AllTrim(JurGetDados("OHP", 1, xFilial("OHP") + aDados[nI][3] + aDados[nI][6], "OHP_COD")))
			JurOperacao(3, "OHP", , , aCampos, aDados[nI])
		EndIf
	
	Next nI
	
	// Limpa Arrays
	JurFreeArr(aCampos)
	JurFreeArr(aDados)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J266VldNat
Validação das naturezas. 

@Return lRet   .T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since  18/12/2018
@version 1.0
/*/
//------------------------------------------------------------------- 
Function J266VldNat()
	Local lRet       := .T.
	Local cOrigem    := FwFldGet("OHP_ORIGEM") 
	Local lSintetica := (cOrigem == "4") // Participante

	If cOrigem == "5" //NF Saída
		lRet := ExistChav("OHP", M->OHP_ORIGEM + M->OHP_CNATUR, 3)
	EndIf
	
	lRet := lRet .And. JurValNat("OHP_CNATUR", , , , , , , , lSintetica)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J266FilNat
Filtro da consulta padrão de natureza financeira. 

@param lNewF3 - Indica se o filtro está sendo feito pela nova consulta JF3SED

@Return cRet   Condição do filtro

@author Cristina Cintra
@since 18/12/2018
@version 1.0
/*/
//------------------------------------------------------------------- 
Function J266FilNat(lNewF3)
	Local cRet      := "@# SED->ED_MSBLQL == '2'"
	Local cOrigem   := FwFldGet("OHP_ORIGEM")
	Default lNewF3  := .F.
	
	If lNewF3
		cRet  := "@# SED.ED_MSBLQL = '2'"
		If cOrigem == "4" // Participante
			cRet += " AND SED.ED_TIPO = '1' @#"
		Else
			cRet += " AND SED.ED_TIPO = '2' AND SED.ED_CMOEJUR != '' @#"
		EndIf
	Else
		If cOrigem == "4" // Participante
			cRet += " .AND. SED->ED_TIPO == '1' @#"
		Else
			cRet += " .AND. SED->ED_TIPO == '2' .AND. !Empty(SED->ED_CMOEJUR) @#"
		EndIf
	EndIf
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J266DscPad
Retorno da Descrição padrão. 

@return cRet   Descrição padrão

@author fabiana.silva
@since 09/09/2021
@version 1.0
/*/
//------------------------------------------------------------------- 
Function J266DscPad()

Return STR0028 //"TES de Nota Fiscal Saída de Faturas"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA266TOK
Rotina de validação da exclusão. 

@param oModel  Modelo a ser validado
@Return lRet   Retorno da rotina

@author fabiana.silva
@since 09/09/2021
@version 1.0
/*/
//------------------------------------------------------------------- 
Static Function JURA266TOK(oModel)
Local nOpc := oModel:GetOperation()
Local lRet := .T.
Local cTitTES := RetTitle("OHP_TES")

If nOpc == OP_EXCLUIR .And. oModel:GetValue("OHPMASTER", "OHP_ORIGEM") <> "5"
	lRet := JurMsgErro(STR0029) //"Somente registros da rotina de Nota Fiscal de Saída podem ser excluídos."
ElseIf oModel:GetValue("OHPMASTER", "OHP_ORIGEM") == "5" .And.( nOpc == OP_INCLUIR .Or. nOpc == OP_ALTERAR) .And. Empty(oModel:GetValue("OHPMASTER", "OHP_TES") ) 
	lRet := JurMsgErro( STR0030 + cTitTES) //"Para registros de Nota Fiscal de Saída deve ser informado o campo "
EndIf

Return lRet
