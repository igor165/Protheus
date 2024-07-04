#INCLUDE "JURA238.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

Static _nOperacao := 0

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA238
Cadastro de Rateio

@author Jorge Luis Branco Martins Junior
@since 21/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA238()
Local oBrowse := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetDescription(STR0001) //"Cadastro de Rateio"
oBrowse:SetAlias("OH6")
oBrowse:SetLocate()
oBrowse:SetCacheView(.F.)
JurSetLeg(oBrowse, "OH6")
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
@since 21/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "J238VIEW(1)"    , 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "J238VIEW(3)"    , 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "J238VIEW(4)"    , 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "J238VIEW(5)"    , 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA238", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Rateio.

@author Jorge Luis Branco Martins Junior
@since 21/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel     := FwLoadModel( "JURA238" )
Local oStructOH6 := Nil
Local oStructOH7 := Nil
Local oStructOH8 := Nil
Local oView      := Nil
Local cCamposOH7 := "OH7_CODRAT|OH7_CODDET|OH7_CPARTI|"
Local cCamposOH8 := "OH8_CODRAT|OH8_CODDET|OH8_CPARTI|"
Local lUsaHist   := SuperGetMV( 'MV_JURHS1',, .F. )
Local cTipo      := Iif(_nOperacao != MODEL_OPERATION_INSERT, OH6->OH6_TIPO, ' ')

Do Case
	Case cTipo == '1' //Escritório
		cCamposOH7 += "OH7_CCCUST|OH7_DCCUST|OH7_SIGLA|OH7_DPARTI"
		cCamposOH8 += "OH8_CCCUST|OH8_DCCUST|OH8_SIGLA|OH8_DPARTI"
	Case cTipo == '2' //Centro de Custo
		cCamposOH7 += "OH7_SIGLA|OH7_DPARTI"
		cCamposOH8 += "OH8_SIGLA|OH8_DPARTI"
	Case cTipo == '3' //Participante
		cCamposOH7 += "OH7_CCCUST|OH7_DCCUST|OH7_CESCRI|OH7_DESCRI"
		cCamposOH8 += "OH8_CCCUST|OH8_DCCUST|OH8_CESCRI|OH8_DESCRI"
EndCase

oStructOH6 := FWFormStruct( 2, "OH6" )
oStructOH7 := FWFormStruct( 2, "OH7", {|x| !AllTrim(x) $ cCamposOH7}) // Bloco para remover os campos da estrutura conforme o tipo
oStructOH8 := FWFormStruct( 2, "OH8", {|x| !AllTrim(x) $ cCamposOH8}) // Bloco para remover os campos da estrutura conforme o tipo

JurSetAgrp( 'OH6',, oStructOH6 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:SetDescription( STR0001 ) //"Cadastro de Rateio"

oView:AddField( "JURA238_OH6", oStructOH6, "OH6MASTER" )
oView:AddGrid(  "JURA238_OH7", oStructOH7, "OH7DETAIL" )
If lUsaHist
	oView:AddGrid(  "JURA238_OH8", oStructOH8, "OH8DETAIL" )
EndIf

oView:CreateHorizontalBox( "FORM_OH6", 10,,,, )
If lUsaHist
	oView:CreateHorizontalBox( "FORM_OH7", 45 ,,,,)
	oView:CreateHorizontalBox( "FORM_OH8", 45 ,,,,)
Else
	oView:CreateHorizontalBox( "FORM_OH7", 90 ,,,,)
EndIf

oView:SetOwnerView( "OH6MASTER", "FORM_OH6" )
oView:SetOwnerView( "OH7DETAIL", "FORM_OH7" )

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

oView:EnableTitleView( "JURA238_OH7" )

If lUsaHist
	oView:SetOwnerView( "OH8DETAIL", "FORM_OH8" )
	oView:EnableTitleView( "JURA238_OH8" )
EndIf

oView:SetViewProperty( "*", "GRIDNOORDER") //Devido a ordenação do grid, o recurso de ordenação precisou ser desabilitado

Return oView
	
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Rateio.

@author Jorge Luis Branco Martins Junior
@since 21/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructOH6 := Nil
Local oStructOH7 := Nil
Local oStructOH8 := Nil
Local oModel     := Nil
Local oCommit    := JA238COMMIT():New()

oStructOH6 := FWFormStruct(1,"OH6")
oStructOH7 := FWFormStruct(1,"OH7")
oStructOH8 := FWFormStruct(1,"OH8")

oModel:= MpFormModel():New( "JURA238", /*Pre-Validacao*/, {|oModel| J238TOK(oModel)} /*Pos-Validacao*/, /*Commit*/ )
oModel:SetDescription( STR0001 ) //"Cadastro de Rateio"

oModel:AddFields( "OH6MASTER", /*cOwner*/, oStructOH6,/*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:GetModel( "OH6MASTER" ):SetDescription( STR0001 ) //"Cadastro de Rateio"

// OH7 - Localização 2º Nivel
oModel:AddGrid( "OH7DETAIL", "OH6MASTER" /*cOwner*/, oStructOH7, /*bLinePre*/,  {|oX| J238VLDOH7(oX)} /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "OH7DETAIL" ):SetDescription( STR0008 ) //"Detalhe do Rateio"
oModel:SetRelation( "OH7DETAIL", { { "OH7_FILIAL", "XFILIAL('OH7')" }, { "OH7_CODRAT", "OH6_CODIGO" } }, OH7->( IndexKey( 1 ) ) )

// OH8 - Localização 3º Nivel
oModel:AddGrid( "OH8DETAIL", "OH6MASTER" /*cOwner*/, oStructOH8, /*bLinePre*/, {|oX| J238VLDOH8(oX)} /*bLinePost*/,/*bPre*/, /*bPost*/, { |oGrid| LoadOH8(oGrid) } )
oModel:GetModel( "OH8DETAIL"  ):SetDescription( STR0009 ) //"Histórico do Detalhe do Rateio"
oModel:SetRelation( "OH8DETAIL", { { "OH8_FILIAL", "XFILIAL('OH8')" }, { "OH8_CODRAT", "OH6_CODIGO" } }, "OH8_FILIAL+OH8_CODRAT+OH8_AMINI" )

oModel:GetModel( "OH7DETAIL" ):SetUniqueLine( { "OH7_CESCRI", "OH7_CCCUST", "OH7_SIGLA" } )
oModel:GetModel( "OH8DETAIL" ):SetUniqueLine( { "OH8_AMINI", "OH8_CESCRI", "OH8_CCCUST", "OH8_SIGLA" } )

oModel:SetOptional( "OH8DETAIL" , .T. )

JurSetRules( oModel, 'OH6MASTER',, 'OH6' )
JurSetRules( oModel, 'OH7DETAIL',, 'OH7' )
JurSetRules( oModel, 'OH8DETAIL',, 'OH8' )

oModel:SetOnDemand()

oModel:InstallEvent("JA238COMMIT", /*cOwner*/, oCommit)


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J238VLDOH7
Pós validação da linha do grid OH7 - Detalhe

@param oGrid Grid de detalhes a ser validado

@author Jorge Luis Branco Martins Junior
@since 27/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J238VLDOH7(oGrid)
Local lRet := .T.
	
	//Validação do tipo de rateio preenchido no Detalhe
	Iif (lRet, lRet := J238VldTipo(oGrid, "OH7"), )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J238VLDOH8
Pós validação da linha do grid OH8 - Histórico

@param oGrid Grid de histórico a ser validado

@author bruno.ritter
@since 21/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J238VLDOH8(oGrid)
Local lRet := .T.

	//Validação das datas Inicial e Final
	lRet := JHistValid(oGrid, {"OH8_CESCRI", "OH8_CCCUST", "OH8_CPARTI"})

	//Validação do tipo de rateio preenchido no histórico
	Iif (lRet, lRet := J238VldTipo(oGrid, "OH8"), )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J238VldTipo
Valida se linha atual do grid (OH7 - Detalhe ou OH8 - Histórico) 
está preenchida com o Tipo de Rateio correto.

@param oGrid Grid (Detalhes ou histórico) a ser validado
@param cTab  Tabela que faz referência ao Grid indicado

@author bruno.ritter
@since 21/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J238VldTipo(oGrid, cTab)
Local lRet       := .T.
Local oModel     := FwModelActive()
Local cTipoModel := oModel:GetValue("OH6MASTER", "OH6_TIPO")
Local lVzoEscrit := Empty(oGrid:GetValue(cTab + "_CESCRI"))
Local lVzoCCusto := Empty(oGrid:GetValue(cTab + "_CCCUST"))
Local lVzoPartic := Empty(oGrid:GetValue(cTab + "_SIGLA"))
Local cTitleEsc  := AllTrim(RetTitle(cTab + "_CESCRI"))
Local cTitleCus  := AllTrim(RetTitle(cTab + "_CCCUST"))
Local cTitlePar  := AllTrim(RetTitle(cTab + "_SIGLA"))

	If oGrid:IsUpdated() .And. !oGrid:IsDeleted()
		Do Case
			Case cTipoModel == "1" //Escritório
				If lVzoEscrit 
					lRet := .F.
					JurMsgErro( i18n(STR0013, {cTitleEsc}),,; //"O campo '#1' é obrigatório."
								i18n(STR0014, {cTitleEsc})) //"Informe um valor para o campo '#1'."
				EndIf

			Case cTipoModel == "2" //Centro de Custo
				If lVzoEscrit 
					lRet := .F.
					JurMsgErro( i18n(STR0013, {cTitleEsc}),,; //"O campo '#1' é obrigatório."
								i18n(STR0014, {cTitleEsc})) //"Informe um valor para o campo '#1'."
				EndIf

				If lRet .And. lVzoCCusto 
					lRet := .F.
					JurMsgErro( i18n(STR0013, {cTitleCus}),,; //"O campo '#1' é obrigatório."
								i18n(STR0014, {cTitleCus})) //"Informe um valor para o campo '#1'."
				EndIf

			Case cTipoModel == "3" //Participante
				If lVzoPartic 
					lRet := .F.
					JurMsgErro( i18n(STR0013, {cTitlePar}),,; //"O campo '#1' é obrigatório."
								i18n(STR0014, {cTitlePar})) //"Informe um valor para o campo '#1'."
				EndIf

		EndCase
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J238PerOH8
Valida a soma dos percentuais por período na grid OH8 - Histórico.

@param oModel Modelo de Dados em que se encontra o grid OH8 - Histórico

@author bruno.ritter
@since 21/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J238PerOH8(oModel)
	Local lRet       := .T.
	Local aPeriodo   := {}
	Local aPerIni    := {}
	Local aPerFim    := {}
	Local nI         := 0
	Local nLine      := 0
	Local nPeriod    := 0
	Local nPos       := 0
	Local nPosIni    := 0
	Local nPosFim    := 0
	Local nQtdPerio  := 0
	Local nPosDtIni  := 1
	Local nPosDtFim  := 2
	Local nPosPerc   := 3
	Local oGrid      := oModel:GetModel("OH8DETAIL")
	Local nQtdLin    := oGrid:GetQtdLine()
	Local cDtIniVld  := ""
	Local cDtFimVld  := ""
	Local cPercVld   := ""
	Local cDtFimPer  := ""

	For nLine := 1 to nQtdLin
		If !oGrid:IsDeleted(nLine) .And. !oGrid:IsEmpty(nLine)
			cDtIniVld := oGrid:GetValue("OH8_AMINI", nLine)
			cDtFimVld := oGrid:GetValue("OH8_AMFIM", nLine)
			cDtFimPer := Iif(Empty(cDtFimVld), '999912', cDtFimVld)
			cPercVld  := oGrid:GetValue("OH8_PERCEN", nLine)

			// Valida se existem períodos com mesmo ano-mês inicial, porém com ano-mês final diferentes
			nPosIni := aScan( aPerIni, { |aX| aX[1] == cDtIniVld })

			If nPosIni == 0
				aAdd(aPerIni, { cDtIniVld, cDtFimVld, cPercVld } )
			ElseIf cDtFimVld != aPerIni[nPosIni][2]
				lRet := .F.
				JurMsgErro( i18n( STR0018, { TRANSFORM(aPerIni[nPosIni][1], X3Picture( "OH8_AMINI" )),;
												TRANSFORM(aPerIni[nPosIni][2], X3Picture( "OH8_AMFIM" ))}),,; // "Existem períodos com o mesmo ano-mês inicial, porém com ano-mês final diferentes. Verifique o período de '#1' e '#2'."
									STR0020) // "Os períodos devem ter mesmo ano-mês inicial e final"
				Exit
			EndIf
			
			If lRet
				// Valida se existem períodos com mesmo ano-mês final, porém com ano-mês inicial diferentes
				nPosFim := aScan( aPerFim, { |aX| aX[1] == cDtFimVld })
				If nPosFim == 0
					aAdd(aPerFim, { cDtIniVld, cDtFimVld, cPercVld } )
				EndIf
			EndIf

			If lRet
				// Monta o array com as porcentagens por período
				nPos := 0
				For nI := 1 To Len(aPeriodo)
					If aPeriodo[nI][nPosDtIni] >= cDtIniVld .And.  aPeriodo[nI][nPosDtIni] <= cDtFimPer;
							.Or. aPeriodo[nI][nPosDtFim] >= cDtIniVld .And.  aPeriodo[nI][nPosDtFim] <= cDtFimPer;
							.Or.  aPeriodo[nI][nPosDtIni] <= cDtIniVld .And. aPeriodo[nI][nPosDtFim] >= cDtFimPer
						nPos := nI
						Exit
					EndIf
				Next nI

				If nPos == 0
					aAdd(aPeriodo, { cDtIniVld, cDtFimPer, cPercVld, cDtFimVld } )
				Else
					aPeriodo[nPos][3] += cPercVld
				EndIf
			EndIf

		EndIf
	Next nLine

	If lRet
		// Valida as porcentagens por período indicado
		nQtdPerio := Len(aPeriodo)
		For nI := 1 to nQtdPerio
			If aPeriodo[nI][3] != 100
				lRet := .F.
				JurMsgErro(i18n(STR0011,{TRANSFORM(aPeriodo[nI][nPosDtIni], X3Picture( "OH8_AMINI" )),TRANSFORM(aPeriodo[nI][4], X3Picture( "OH8_AMFIM" )) ,aPeriodo[nI][3]}),,;//"O período de '#1' e '#2' do hisórico de rateio está com a soma igual '#3%'."
								STR0012) // "A soma do período deve ser igual a 100%"
				Exit
			EndIf
		Next
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J238PerOH7
Validar a soma dos percentuais no grid OH7 - Detalhe 

@param oModel Modelo de Dados em que se encontra o grid OH7 - Detalhe 

@author Jorge Luis Branco Martins Junior
@since 24/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J238PerOH7(oModel)
Local lRet      := .T.
Local nTotal    := 0
Local oGrid     := oModel:GetModel("OH7DETAIL")
Local nQtdLine  := oGrid:GetQtdLine()
Local nFirstLin := 0
Local nI        := 0

	// Verifica o total de linhas deletadas, para validar o total do rateio somente se tiver ao menos uma linha nao deletada
	For nI := 1 To nQtdLine
		If !oGrid:IsDeleted(nI)
			nFirstLin := nI	// Localiza a primeira linha nao deletada
			Exit
		Endif
	Next

	// Soma total do Rateio, apenas se houver linhas validas digitadas
	If nFirstLin > 0
		For nI := 1 To nQtdLine
			If !oGrid:IsDeleted(nI)
				nTotal += oGrid:GetValue( "OH7_PERCEN", nI )
			Endif	
		Next	
		
		If nTotal <> 100
			lRet := .F.
			JurMsgErro( STR0010,, ; //"Total do Rateio deve ser igual a 100%"
			            STR0022 + STR0008 + ": " + Alltrim(RetTitle("OH7_PERCEN")) )  //"Verifique o preenchimento do seguinte campo na aba " + "Detalhe do Rateio" 
		Endif
	Endif	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J238TOK(oModel)
Tudo ok do modelo

@param oModel Modelo de Dados

@author bruno.ritter
@since 21/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J238TOK(oModel)
Local lRet      := .T.
Local nOpc      := oModel:GetOperation()
Local oModelOH8 := oModel:GetModel("OH8DETAIL")

If nOpc == OP_INCLUIR .Or. nOpc == OP_ALTERAR

	// Validação de lacunas de periodo e linhas duplicadas na tabela de histórico.
	lRet := JURPerHist( oModelOH8, .T., { "OH8_CESCRI", "OH8_CCCUST", "OH8_CPARTI" } )

	// Validação do percentual dos lançamentos do modelo de Detalhe OH7
	If lRet
		lRet := J238PerOH7(oModel)
	EndIf

	// Validação do percentual dos períodos lançados do modelo de Histórico OH8 e 
	// Verifica se o ano-mês final é maior ou igual a algum ano-mês final em outro registro, ou se ano-mês inicial é menor ou igual ao inicial
	If lRet
		lRet := J238PerOH8(oModel)
	EndIf

	// Criação dos novos registros de Histórico OH8
	// Manter sempre como última função a ser chamada
	If lRet
		lRet := J238HisOH8(oModel)
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J238HisOH8(oModel)
Rotinas de histórico para rateio

@param oModel Modelo de Dados

@author Jorge Luis Branco Martins Junior
@since 24/07/2017
@version 1.0


/*/
//-------------------------------------------------------------------
Static Function J238HisOH8(oModel)
	Local lRet      := .T.
	Local lGrid     := .T.
	Local oModelOH6 := oModel:GetModel("OH6MASTER")
	Local cTipo     := oModelOH6:GetValue("OH6_TIPO")
	Local cCpoOrig  := ""
	Local cCpoHist  := ""
	Local aOH7Cpo   := {}
	Local aCpoMdls  := {}

	Do Case
		Case cTipo == '1'
			cCpoOrig    := "OH7_CESCRI"
			cCpoHist    := "OH8_CESCRI"
		Case cTipo == '2'
			cCpoOrig    := "OH7_CCCUST"
			cCpoHist    := "OH8_CCCUST"
		Case cTipo == '3'
			cCpoOrig    := "OH7_CPARTI"
			cCpoHist    := "OH8_CPARTI"
	EndCase

	aAdd(aOH7Cpo, {"OH7_CESCRI", "OH8_CESCRI"})
	aAdd(aOH7Cpo, {"OH7_CCCUST", "OH8_CCCUST"})
	aAdd(aOH7Cpo, {"OH7_PERCEN", "OH8_PERCEN"})
	aAdd(aOH7Cpo, {"OH7_SIGLA" , "OH8_SIGLA"})
	aAdd(aOH7Cpo, {"OH7_CPARTI", "OH8_CPARTI"})
	aAdd(aCpoMdls, {"OH7DETAIL", aOH7Cpo})
	lGrid := .T.
	lRet := JurHist(oModel, "OH8DETAIL", aCpoMdls, lGrid, {cCpoOrig,cCpoHist})

	JurFreeArr(@aOH7Cpo)
	JurFreeArr(@aCpoMdls)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J238LimpaTp
Limpa os campos do grid OH7 - Detalhe conforme a opção preenchida no 
Tipo de Rateio

@author Jorge Luis Branco Martins Junior
@since 27/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J238LimpaTp()
Local oModel     := FwModelActive()
Local oGrid      := oModel:GetModel("OH7DETAIL") // Detalhe
Local cTipo      := oModel:GetValue("OH6MASTER", "OH6_TIPO")
Local nLinAtu    := oGrid:GetLine()
Local nQtdLin    := oGrid:GetQtdLine()
Local aCampos    := {}
Local nI         := 0
Local nJ         := 0
Local lGridEmpty := oGrid:IsEmpty() // Indica se o Grid está vazio
Local lGridDel   := .T.             // Caso o grid não esteja vazio indica se o Grid está com todas as linhas deletadas

If !(lGridEmpty)
	For nI := 1 to nQtdLin
		If !oGrid:IsDeleted(nI) 
			lGridDel := .F. // Existem linhas não deletadas
			Exit
		EndIf
	Next

	oGrid:GoLine(nLinAtu)

EndIf

// O IsBlind está sendo usado para tratar quando for automação de testes, para que não exiba pergunta.
If !(lGridEmpty) .And. !(lGridDel) .And. ( IsBlind() .Or. ApMsgYesNo(STR0021) ) // "Devido a alteração do tipo de rateio, as informações indicadas na sessão 'Detalhe do Rateio' serão excluidas. Deseja continuar?"

	Do Case
		Case cTipo == "1" //Escritório
			aCampos := {"OH7_PERCEN","OH7_CCCUST","OH7_DCCUST","OH7_SIGLA","OH7_CPARTI","OH7_DPARTI"}
		Case cTipo == "2" //Centro de Custo
			aCampos := {"OH7_PERCEN","OH7_SIGLA","OH7_CPARTI","OH7_DPARTI"}
		Case cTipo == "3"  //Participante
			aCampos := {"OH7_PERCEN","OH7_CESCRI","OH7_DESCRI","OH7_CCCUST","OH7_DCCUST"}
	EndCase

	For nI := 1 to nQtdLin
		If !oGrid:IsEmpty(nI)
			oGrid:GoLine(nI)
			For nJ := 1 to Len(aCampos)
				oGrid:ClearField(aCampos[nJ])
			Next
			If !oGrid:IsDeleted()
				oGrid:DeleteLine()
			EndIf
		EndIf
	Next

	oGrid:GoLine(nLinAtu)

EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadOH8
Load dos dados da OH8 para possibilitar a ordenação também por data
decrescente na grid de Histórico

@Param  Grid da OH8

@author Jorge Luis Branco Martins Junior 
@since 04/08/2017
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function LoadOH8(oGrid)
Local aRet     := FormLoadGrid(oGrid)
Local aStruct  := {}
Local nEscrit  := 0
Local nCCusto  := 0
Local nSigla   := 0
Local nAnoMes  := 0

aStruct  := oGrid:oFormModelStruct:GetFields()

nEscrit := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == "OH8_CESCRI" } )
nCCusto := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == "OH8_CCCUST" } )
nSigla  := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == "OH8_SIGLA"  } )
nAnoMes := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == "OH8_AMINI"  } )

If nEscrit > 0 .And. nCCusto > 0 .And. nSigla > 0 .And. nAnoMes > 0
	aSort( aRet,,, { |aX,aY| aX[2][nAnoMes]+aX[2][nEscrit]+aX[2][nCCusto]+aX[2][nSigla] > aY[2][nAnoMes]+aY[2][nEscrit]+aY[2][nCCusto]+aY[2][nSigla] } )
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J238View
Executa a view do cadastro de Rateio.

@Param nOper Operação do modelo 4 - alteração, 5 - exclusão

@author Abner Fogaça de Oliveira
@since 29/08/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J238View( nOpc )
Local cOperac := ''

If nOpc == 1
	cOperac := STR0003 // "Visualizar"
ElseIf nOpc == 3
	cOperac := STR0004 // "Incluir"
ElseIf nOpc == 4
	cOperac := STR0005 // "Alterar"
ElseIf nOpc == 5
	cOperac := STR0006 // "Excluir"
EndIf

_nOperacao := nOpc
	
FWExecView( cOperac, 'JURA238', nOpc )

Return NIL

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA238COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Abner Fogaça de Oliveira
@since 18/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA238COMMIT FROM FWModelEvent
	Method New()
	Method InTTS()
	Method GridLinePreVld()
End Class

Method New() Class JA238COMMIT
Return

Method InTTS(oModel, cModelId) Class JA238COMMIT
	JFILASINC(oModel:GetModel(), "OH6", "OH6MASTER", "OH6_CODIGO")
Return

//-------------------------------------------------------------------
/*/ { Protheus.doc } GridLinePreVld
Método que é chamado pelo MVC quando ocorrer as ações de pre validação da linha do Grid

@author Bruno Ritter
@since 22/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class JA238COMMIT
	Local lRet       := .T.
	Local cCodRateio := ""
	Local cDtValue   := ""
	Local lExibMsgEr := ""
	Local oModel     := Nil
	Local lHstMesAnt := .F.
	Local cDtCorrent := ""


	If cModelID == "OH8DETAIL" .And. cAction $ "DELETE|CANSETVALUE"
		oModel     := oSubModel:GetModel()
		cCodRateio := oModel:GetValue("OH6MASTER", "OH6_CODIGO")

		If cAction != "DELETE" .And. (cId == "OH8_AMINI" .Or. cId == "OH8_AMFIM")
			cDtValue  := OH8->(FieldGet( FieldPos(cId) ))
			If !Empty(cDtValue)
				lRet := J238BloqRt(cCodRateio, cDtValue, cDtValue)
			EndIf

		Else
			If !Empty(oSubModel:GetValue("OH8_AMINI", nLine))
				lExibMsgEr := cAction == "DELETE"
				lRet := J238BloqRt(cCodRateio, oSubModel:GetValue("OH8_AMINI", nLine), oSubModel:GetValue("OH8_AMFIM", nLine), lExibMsgEr)
			EndIf
		EndIf
	EndIf
	
	If cModelID == "OH7DETAIL" .And. cAction $ "DELETE|CANSETVALUE" //Valida se existe periodo fechado no mês corrente.
		oModel     := oSubModel:GetModel()
		cCodRateio := oModel:GetValue("OH6MASTER", "OH6_CODIGO")
		lHstMesAnt := SuperGetMV( 'MV_JURHS2',, .F. )
		cDtValue   := ""
		lExibMsgEr := cAction == "DELETE"
		
		cDtCorrent := AnoMes(MsSomaMes(MsDate(), Iif(lHstMesAnt, -1, 0)))
		
		lRet := J238BloqRt(cCodRateio, cDtCorrent, cDtValue, lExibMsgEr)
	EndIf
	
	
Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J238BloqRt
Verifica se existe uma restrição de alteração devido ao calendário contábil,
para isso é verificado se o processo do perído recebido por parâmetro éstá bloqueado
e se existe algum lançamento, desdobramento e ou desdobramento pós-pagamento com o 
rateio recebido por parâmetro.

@param cCodRateio, Código de rateio para ser avaliado
@param cAMInicio , Ano/Mês inicio para validar o bloqueio
@param cAMFim    , Ano/Mês fim para validar o bloqueio
@param lMsgError , Se deve exibir mensagem de erro

@author Bruno Ritter
@since 23/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J238BloqRt(cCodRateio, cAMInicio, cAMFim, lMsgError)
	Local aArea     := GetArea()
	Local lRet      := .T.
	Local cDtInicio := cAMInicio+"01"
	Local cDtFim    := ""
	Local aDtBloq   := {}
	Local nI        := {}
	Local aLanc     := {}
	Local aDesd     := {}
	Local aTabs     := {'CTG','SE2','OHB','OHG','OHF'}

	Default lMsgError := .F.

	If Empty(cAMFim)
		cDtFim := '99990101'
	Else
		cDtFim := DtoS( Lastday( StoD(cAMFim+"01") ))
	EndIf
	
	If lRet := JurCompart(aTabs) //verifica o compartilhamento das tabelas

		aDtBloq := J238BlqPer(cDtInicio, cDtFim)
		If !Empty(aDtBloq[1]) 
			aLanc  := aDtBloq[1]
			For nI := 1 To Len(aLanc)
				If J238TemLac(cCodRateio, aLanc[nI])
					lRet := .F.
					If lMsgError
						JurMsgErro(STR0024,, i18n(STR0025, {"PFS001"})) // "Não foi possível concluir a operação, pois existem lançamentos para esse rateio com calendário contábil bloqueado." "Verifique o processo '#1' do calendário contábil."
					EndIf
					Exit
				EndIf
			Next
		EndIf
	
		If lRet
			If !Empty(aDtBloq[2])
				aDesd := aDtBloq[2]
				For nI := 1 to Len(aDesd) 
					If J238TDesdb(cCodRateio, aDesd[nI])
						lRet := .F.
						If lMsgError
							JurMsgErro(STR0026,, i18n(STR0025, {"FIN001"}) ) // "Não foi possível concluir a operação, pois existem desdobramentos para esse rateio com calendário contábil bloqueado." "Verifique o processo '#1' do calendário contábil."
						EndIf
						Exit
					ElseIf J238TDesPg(cCodRateio, aDesd[nI])
						lRet := .F.
						If lMsgError
							JurMsgErro(STR0027,, i18n(STR0025, {"FIN001"}) ) // "Não foi possível concluir a operação, pois existem desdobramentos pós-pagamento para esse rateio com calendário contábil bloqueado." "Verifique o processo '#1' do calendário contábil."
						EndIf
						Exit
					EndIf
				Next nI
			EndIf
		EndIf
	EndIf
	RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/ { Protheus.doc } J238BlqPer
Verifica se existe um periódo bloqueado

@param cCodRateio, Código de rateio para ser avaliado
@param cAMInicio , Ano/Mês inicio para validar o bloqueio
@param cAMFim    , Ano/Mês fim para validar o bloqueio

@ret aDtBloq, [1]Menor data do canlendário bloqueado
              [2]Maior data do canlendário bloqueado

@author Bruno Ritter
@since 23/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J238BlqPer(cDtInicio, cDtFim)
	Local aDtBloq := {}
	Local aLanc   := {}
	Local aDesd   := {}
	Local cQuery  := ""
	Local cTmp    := ""

	cQuery := " SELECT MIN(CTG.CTG_DTINI) DTINI, MAX(CTG.CTG_DTFIM) DTFIM, CTG.CTG_FILIAL, CQD.CQD_PROC "
	cQuery += " FROM " + RetSqlName("CTG") + " CTG "
	cQuery += " INNER JOIN " + RetSqlName("CQD") + " CQD "
	cQuery +=    " ON CQD.CQD_FILIAL = CTG.CTG_FILIAL "
	cQuery +=   " AND CQD.CQD_CALEND = CTG.CTG_CALEND "
	cQuery +=   " AND CQD.CQD_EXERC = CTG.CTG_EXERC "
	cQuery +=   " AND CQD.CQD_PERIOD = CTG_PERIOD "
	cQuery +=   " AND CQD.CQD_PROC IN ('PFS001', 'FIN001') "
	cQuery +=   " AND CQD.CQD_STATUS > '1' "
	cQuery +=   " AND CQD.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE CTG.CTG_DTINI BETWEEN '" + cDtInicio + "' AND '" + cDtFim + "' "
	If !Empty(xFilial("OH6"))
		cQuery += " AND CTG.CTG_FILIAL = '" + xFilial("CTG") + "' "
	EndIf
	cQuery +=   " AND CTG.D_E_L_E_T_ = ' ' "
	cQuery +=   " GROUP BY CTG.CTG_FILIAL, CQD.CQD_PROC "

	cTmp  := GetNextAlias()
	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTmp, .T., .F. )

	While !(cTmp)->( EOF() )
		If (cTmp)->CQD_PROC == 'PFS001'
			aAdd(aLanc, {(cTmp)->DTINI, (cTmp)->DTFIM, (cTmp)->CTG_FILIAL})
		Else
			aAdd(aDesd, {(cTmp)->DTINI, (cTmp)->DTFIM, (cTmp)->CTG_FILIAL})
		EndIf
		(cTmp)->(DbSkip())
	EndDo
	(cTmp)->( dbCloseArea() )
	
	aDtBloq := {aLanc, aDesd}

Return aDtBloq

//-------------------------------------------------------------------
/*/ { Protheus.doc } J238TDesdb
Verifica se existe um desdobramento usando o rateio

@param cCodRateio, Código de rateio para ser avaliado
@Param aPerBloq[n]    Array com o periodo a ser verificado
               [n][1] Data inicio para verificar o lançamento
               [n][2] Data fim para verificar o lançamento
               [n][3] Filial para verificar o lançamento

@obs cDtInicio/cDtFim, Considera a data de pagamento do título, caso não tenha, considerar a data de vencimento do título

@author Bruno Ritter
@since 23/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J238TDesdb(cCodRateio, aPerBloq)
	Local cQuery     := ""
	Local cTmp       := ""
	Local lExistReg  := .F.
	Local cDtInicio  := aPerBloq[1]
	Local cDtFim     := aPerBloq[2]
	Local cFilPer    := aPerBloq[3]

	cQuery := " SELECT COUNT(SE2.R_E_C_N_O_) TOTAL "
	cQuery += " FROM " + RetSqlName("SE2") + " SE2 "
	cQuery += " INNER JOIN " + RetSqlName("FK7") + " FK7 "
	cQuery +=         " ON SE2.E2_FILIAL ||'|'|| SE2.E2_PREFIXO ||'|'|| SE2.E2_NUM ||'|'|| SE2.E2_PARCELA ||'|'|| SE2.E2_TIPO ||'|'|| SE2.E2_FORNECE ||'|'|| SE2.E2_LOJA = FK7.FK7_CHAVE "
	cQuery +=        " AND FK7.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("OHF") + " OHF "
	cQuery +=         " ON FK7.FK7_IDDOC = OHF.OHF_IDDOC "
	cQuery +=        " AND OHF.OHF_CRATEI = '" + cCodRateio + "' "
	cQuery +=        " AND OHF.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSqlName("FK2") + " FK2 "
	cQuery +=        " ON FK2.FK2_IDDOC = FK7.FK7_IDDOC  "
	cQuery +=       " AND FK2.FK2_TPDOC = 'VL' "
	cQuery +=       " AND FK2.FK2_DATA BETWEEN '" + cDtInicio + "' AND '" + cDtFim + "'  " // Data da baixa
	cQuery +=       " AND FK2.D_E_L_E_T_ = ' ' "
	cQuery +=       " AND NOT EXISTS( "
	cQuery +=                 " SELECT FK2EST.R_E_C_N_O_ FROM " + RetSqlName("FK2") + " FK2EST "
	cQuery +=                 " WHERE FK2EST.FK2_TPDOC = 'ES' "
	cQuery +=                 " AND FK2EST.FK2_IDDOC = FK2.FK2_IDDOC "
	cQuery +=                 " AND FK2EST.FK2_SEQ = FK2.FK2_SEQ  "
	cQuery +=                 " AND FK2EST.D_E_L_E_T_ = ' ' "
	cQuery +=                " ) "
	cQuery += " WHERE SE2.D_E_L_E_T_ = ' '"
	cQuery +=   " AND (FK2.R_E_C_N_O_ IS NOT NULL "
	cQuery +=          " OR ( SE2.E2_SALDO > 0 AND SE2.E2_VENCTO BETWEEN '" + cDtInicio + "' AND '" + cDtFim + "')) " // Se não tem baixa
	If !Empty(cFilPer)
		cQuery +=   " AND SE2.E2_FILIAL = '" + cFilPer + "' "
	EndIf

	cTmp  := GetNextAlias()
	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTmp, .T., .F. )
	lExistReg := (cTmp)->TOTAL > 0
	(cTmp)->(dbCloseArea())

Return lExistReg


//-------------------------------------------------------------------
/*/ { Protheus.doc } J238TDesPg
Verifica se existe um desdobramento pós-pagamento usando o rateio

@param cCodRateio, Código de rateio para ser avaliado
@Param aPerBloq[n]    Array com o periodo a ser verificado
               [n][1] Data inicio para verificar o lançamento
               [n][2] Data fim para verificar o lançamento
               [n][3] Filial para verificar o lançamento

@obs cDtInicio/cDtFim, Considera a data de inclusão do desdobramento.

@author Bruno Ritter
@since 23/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J238TDesPg(cCodRateio, aPerBloq)
	Local cQuery     := ""
	Local cTmp       := ""
	Local lExistReg  := .F.
	Local cDtInicio  := aPerBloq[1]
	Local cDtFim     := aPerBloq[2]
	Local cFilPer    := aPerBloq[3]

	cQuery := " SELECT COUNT(SE2.R_E_C_N_O_) TOTAL "
	cQuery += " FROM " + RetSqlName("SE2") + " SE2 "
	cQuery += " INNER JOIN " + RetSqlName("FK7") + " FK7 "
	cQuery +=         " ON SE2.E2_FILIAL ||'|'|| SE2.E2_PREFIXO ||'|'|| SE2.E2_NUM ||'|'|| SE2.E2_PARCELA ||'|'|| SE2.E2_TIPO ||'|'|| SE2.E2_FORNECE ||'|'|| SE2.E2_LOJA = FK7.FK7_CHAVE "
	cQuery +=        " AND FK7.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("OHG") + " OHG "
	cQuery +=         " ON OHG.OHG_FILIAL = FK7.FK7_FILIAL "
	cQuery +=        " AND FK7.FK7_IDDOC = OHG.OHG_IDDOC "
	cQuery +=        " AND OHG.OHG_CRATEI = '" + cCodRateio + "' "
	cQuery +=        " AND OHG.OHG_DTINCL BETWEEN '" + cDtInicio + "' AND '" + cDtFim + "' "
	cQuery +=        " AND OHG.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE  SE2.D_E_L_E_T_ = ' ' "
	If !Empty(cFilPer)
		cQuery +=   " AND SE2.E2_FILIAL = '" + cFilPer + "' "
	EndIf

	cTmp  := GetNextAlias()
	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTmp, .T., .F. )
	lExistReg := (cTmp)->TOTAL > 0
	(cTmp)->( dbCloseArea() )

Return lExistReg


//-------------------------------------------------------------------
/*/ { Protheus.doc } J238TemLac
Verifica se existe um lançamento usando o rateio para um periodo bloqueado

@param cCodRateio     Código de rateio para ser avaliado
@Param aPerBloq[n]    Array com o periodo a ser verificado
               [n][1] Data inicio para verificar o lançamento
               [n][2] Data fim para verificar o lançamento
               [n][3] Filial para verificar o lançamento

@obs cDtInicio/cDtFim, Considera a data do lançamento (não a data de inclusão).

@author Bruno Ritter
@since 23/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J238TemLac(cCodRateio, aPerBloq)
	Local cQuery     := ""
	Local cTmp       := ""
	Local lExistReg  := .F.
	Local cDtInicio  := aPerBloq[1]
	Local cDtFim     := aPerBloq[2]
	Local cFilPer    := aPerBloq[3]

	cQuery := " SELECT COUNT(LANC.R_E_C_N_O_) TOTAL "
	cQuery += " FROM ( "
	cQuery +=      " SELECT OHB.R_E_C_N_O_ FROM " + RetSqlName("OHB") + " OHB "
	cQuery +=      " WHERE OHB.OHB_CTRATO = '" + cCodRateio + "' "
	cQuery +=        " AND OHB.OHB_DTLANC BETWEEN '" + cDtInicio + "' AND '" + cDtFim + "' "
	cQuery +=        " AND OHB.D_E_L_E_T_ = ' ' "
	If !Empty(cFilPer)
		cQuery +=        " AND OHB.OHB_FILIAL = '" + cFilPer + "' "
	EndIf
	cQuery +=      " UNION ALL "
	cQuery +=      " SELECT OHB.R_E_C_N_O_ FROM " + RetSqlName("OHB") + " OHB "
	cQuery +=      " WHERE OHB.OHB_CTRATD = '" + cCodRateio + "' "
	cQuery +=        " AND OHB.OHB_DTLANC BETWEEN '" + cDtInicio + "' AND '" + cDtFim + "' "
	cQuery +=        " AND OHB.D_E_L_E_T_ = ' ' "
	If !Empty(cFilPer)
		cQuery +=        " AND OHB.OHB_FILIAL = '" + cFilPer + "' "
	EndIf
	cQuery += " ) LANC "

	cTmp  := GetNextAlias()
	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTmp, .T., .F. )
	lExistReg := (cTmp)->TOTAL > 0
	(cTmp)->( dbCloseArea() )

Return lExistReg


//-------------------------------------------------------------------
/*/ { Protheus.doc } J238AMHist
Validação do Ano/Mês inicial e final do histórico

@param cCampo, Campo que está sendo validado

@author Bruno Ritter
@since 23/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J238AMHist(cCampo)
	Local lRet       := .T.

	If cCampo == "OH8_AMINI"
		lRet := JHISTVMIni("OH8")
	ElseIf cCampo == "OH8_AMFIM"
		lRet := JHISTVMFim("OH8")
	EndIf

	lRet := lRet .And. J238AMDin(cCampo)

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J238AMDin
Verifica se Ano/Mês inicial e final é valido após diminuir o período do histórico

@param cCampo, Campo que está sendo validado

@author Bruno Ritter
@since 23/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J238AMDin(cCampo)
	Local lRet := .T.

	Local aArea      := {}
	Local cCodRateio := ""
	Local oModel     := Nil
	Local oModelOH8  := Nil
	Local dDtInicio  := ""
	Local dDtFim     := ""
	Local nRecOH8    := 0
	Local cAMBanco   := ""
	Local cAMGrid    := ""
	Local nAltMesIni := 0
	Local nAltMesFim := 0
	Local nOldRec    := 0

	oModel     := FwModelActive()
	oModelOH8  := oModel:GetModel("OH8DETAIL")
	nRecOH8    := oModelOH8:GetDataId()
	cCodRateio := oModelOH8:GetValue("OH8_CODRAT")
	cAMGrid    := oModelOH8:GetValue(cCampo)

	If nRecOH8 > 0
		aArea := OH8->(GetArea())
		nOldRec := OH8->(Recno())
		OH8->(dbGoTo(nRecOH8))
		cAMBanco := OH8->(FieldGet( FieldPos(cCampo) ))

		If (( cCampo == "OH8_AMFIM" .And. cAMGrid < cAMBanco ) .Or. ( Empty(cAMBanco) .And. !Empty(cAMGrid) ));
		      .OR. ( cCampo == "OH8_AMINI" .And. cAMGrid > cAMBanco )

			If cCampo == "OH8_AMFIM"
				dDtInicio  := StoD(cAMGrid+"01")
				dDtFim     := Iif(Empty(cAMBanco), StoD('99990601'), StoD(cAMBanco+"01"))
				nAltMesIni := 1
				nAltMesFim := 0

			ElseIf cCampo == "OH8_AMINI"
				dDtInicio  := StoD(cAMBanco+"01")
				dDtFim     := Iif(Empty(cAMGrid), StoD('99990601'), StoD(cAMGrid+"01"))
				nAltMesIni := 0
				nAltMesFim := -1
			EndIf

			dDtInicio := MonthSum(dDtInicio, nAltMesIni)
			dDtFim    := MonthSum(dDtFim, nAltMesFim)

			lRet := J238BloqRt(cCodRateio, AnoMes(dDtInicio), AnoMes(dDtFim), .T.)
		EndIf

		OH8->(dbGoTo(nOldRec))
		RestArea(aArea)
	EndIf

Return lRet