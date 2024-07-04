#INCLUDE 'DPRC322.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'pmsicons.ch'

#DEFINE PULALINHA CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRC322
Preço Novo Produto

@author Samantha Preima
@since 16/01/2013
@version P11
/*/
//-------------------------------------------------------------------
Function DPRC322()
Local oDlg
Local aMetodo    := {STR0001,STR0002} // Adição de Custos, Subtração Preço-Teto
Local nRadio     := 0
Local cProduto   := Criavar("DG0_CDACDV",.F.)
Local cVersao    := '0000000000'
Local cArquiv	 := ''
Local aValidaDPR := {}
Local oTabBrw
Private aDados   := {cProduto,cVersao,'','','','',1,0,1,0,0,0,0,0}
Private aTabela
Private cTabBrw  := ''
Private aCampos
Default lAutoMacao := .F.

IF !lAutoMacao
	aValidaDPR := ValidaDPR()

	// Valida se o programa pode ser aberto
	If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
		Final(aValidaDPR[2])
	ElseIf !Empty( aValidaDPR[2] )
		DPRXError( 'DPRC322', aValidaDPR[2], 3 )
	EndIf
ENDIF

aTabela := DPRC322TAB()
oTabBrw := SFCCriFWTa(aTabela)
cTabBrw := oTabBrw:GetAlias()

IF !lAutoMacao
	// Cria a janela de seleção
	oDlg := MsDialog():New( 0, 0, 380, 605, STR0003,,,,, CLR_BLACK, CLR_WHITE,,, .T. ) // Preço Novo Produto

	// Separando em grupos
	oProduto := TGroup():New(  05,  05, 70 , 300, '', oDlg,,, .T. )
	oDetalhe := TGroup():New(  75,  05, 170, 300, STR0004, oDlg,,, .T. ) // Método Utilizado

	// Preenche a lista de campos para Desenvolvedor de Produto
	TSay():New( 15, 15 , {|| STR0005 }, oProduto,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Produto Desenvolvido
	TSay():New( 15, 90 , {|| STR0006 }, oProduto,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Versão
	TSay():New( 15, 155, {|| STR0007 }, oProduto,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Descrição Produto
	TSay():New( 40, 15 , {|| STR0008 }, oProduto,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Estratégia Desenvolvimento
	TSay():New( 40, 90 , {|| STR0009 }, oProduto,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Projeto
	TSay():New( 40, 155, {|| STR0010 }, oProduto,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Descrição Projeto
	@ 23,15  MsGet oCDACDV Var aDados[1] F3 "DG0001" Size 70 , 10 Of oProduto Pixel HasButton Valid DPRC322VDV() PICTURE X3Picture("DG0_CDACDV")
	@ 23,90  MsGet oNRVRAC Var aDados[2]             Size 60 , 10 Of oProduto Pixel HasButton Valid DPRC322VDV() PICTURE X3Picture("DG0_NRVRAC")
	@ 23,155 MsGet oDSVR   Var aDados[3]             Size 130, 10 Of oProduto Pixel HasButton WHEN .F. PICTURE X3Picture("DG0_DSVR")
	@ 48,15  MsGet oEstrat Var aDados[4]             Size 70 , 10 Of oProduto Pixel HasButton WHEN .F.
	@ 48,90  MsGet oProjet Var aDados[5]             Size 60 , 10 Of oProduto Pixel HasButton WHEN .F. PICTURE X3Picture("DG0_CDPJ")
	@ 48,155 MsGet oDescPr Var aDados[6]             Size 130, 10 Of oProduto Pixel HasButton WHEN .F. PICTURE X3Picture("DG0_DSPJ")

	TSay():New( 115, 15 , {|| STR0009 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Projeto Desenvolvimento
	TSay():New( 115, 90 , {|| STR0011 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Fator Diluição
	TSay():New( 115,165 , {|| STR0012 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Desenvolvimento (Unitário)
	TSay():New( 140, 15 , {|| STR0013 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Custo Fabricação
	TSay():New( 140, 90 , {|| STR0014 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Custos Diversos
	TSay():New( 140,165 , {|| STR0015 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Preço-Teto
	@ 123, 15  MsGet aDados[8]                 Size 65, 10 Of oDetalhe Pixel HasButton WHEN .F. PICTURE X3Picture("DG0_VLPJDV") // Projeto Desenvolvimento
	@ 123, 90  MsGet aDados[9]                 Size 65, 10 Of oDetalhe Pixel HasButton WHEN .T. PICTURE "@E 9,999,999,999.9999" // Fator Diluição
	@ 123, 165 MsGet aDados[10]                Size 65, 10 Of oDetalhe Pixel HasButton WHEN .F. PICTURE "@E 9,999,999,999.9999" // Desenvolvimento (Unitário)
	@ 148, 15  MsGet aDados[11]                Size 65, 10 Of oDetalhe Pixel HasButton WHEN .F. PICTURE X3Picture("DG0_VLCSPO") // Custo Fabricação
	@ 148, 90  MsGet aDados[12]                Size 65, 10 Of oDetalhe Pixel HasButton WHEN .F. PICTURE X3Picture("DG0_VLCS") // Custos Diversos
	@ 148, 165 MsGet oPreTeto   Var aDados[13] Size 65, 10 Of oDetalhe Pixel HasButton          PICTURE X3Picture("DG0_VLPR") // Preço-Teto

	oMenu1 := TRadMenu():New( 90, 15, aMetodo, , oDetalhe,,,,,,,, 100, 25,,,, .T.)
	oMenu1:bSetGet := { |nRadio| If(PCount() == 0,aDados[7],aDados[7] := nRadio)  }
	oMenu1:bChange := { || if(aDados[7] == 1, oPreTeto:Disable(), oPreTeto:Enable())  }
	oMenu1:SetOption(aDados[7])

	TButton():New(175,  90, STR0018, oDlg, {|| If(DPRC324(aDados[1],aDados[2]), , )},75,10,,,,.T.) // Calcular Custo Fabricação
	TButton():New(175, 170, STR0016, oDlg, {|| If(DPRC322CAL(), , )},40,10,,,,.T.) // Calcular
	TButton():New(175, 215, STR0019, oDlg, {|| If(DPRC322SAL(), oDlg:End(), )},40,10,,,,.T.) // Salvar
	TButton():New(175, 260, STR0017, oDlg, {|| oDlg:End() },40,10,,,,.T.) // Sair

	// Ativação da janela de seleção
	Activate MsDialog oDlg Centered

ENDIF

oTabBrw:Delete()

Return NIL

//-------------------------------------------------------------------
// MenuDef
//-------------------------------------------------------------------
Static Function MenuDef()

Return {}

//-------------------------------------------------------------------------
// DPRC322SAL - Salva as informações calculadas
//-------------------------------------------------------------------------
Function DPRC322SAL()
Local lRet := .T.

dbSelectArea('DG0')
DG0->(dbSetOrder(1))
if DG0->(dbSeek(xFilial('DG0')+aDados[1]+aDados[2]))

	if DG0->DG0_TPST == '1'

		RecLock('DG0',.F.)

		DG0->DG0_VLPJDV := aDados[8]  // Projeto Desenvolvimento
		DG0->DG0_VLCSPO := aDados[11] // Custo Fabricação
		DG0->DG0_VLCS   := aDados[12] // Custos Diversos
		DG0->DG0_VLPR   := aDados[13] // Preço-Teto
		DG0->DG0_VLPJ   := aDados[14] // Projeto

		MsUnLock()
	Else
		DPRXError('DPRC322', 'DPRC322_NAOSAL', 3) // Produto Desenvolvido não pode ter seus valores salvos devida a situação do mesmo.
		lRet := .F.
	Endif
Else
	DPRXError('DPRC322', 'DPRC322_NAOEXI', 3) // Não existe registro para o Produto e Versão informados.
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------------
// DPRC322VDV - Valida campos de produto e versão
//-------------------------------------------------------------------------
Function DPRC322VDV()
Local lRet := .T.

if !Empty(aDados[1])

	dbSelectArea('DG0')
	DG0->(dbSetOrder(1))
	if DG0->(dbSeek(xFilial('DG0')+aDados[1]+aDados[2]))

		dbSelectArea('DG3')
		DG3->(dbSetOrder(1))
		DG3->(dbSeek(xFilial('DG3')+aDados[1]))

		aDados[3] := DG0->DG0_DSVR
		aDados[4] := X3Combo( 'DG3_TPEGDV', DG3->DG3_TPEGDV )
		aDados[5] := DG0->DG0_CDPJ
		aDados[6] := DG0->DG0_DSPJ
	Endif
Endif

Return lRet

//-------------------------------------------------------------------------
// DPRC322CAL - Calcula
//-------------------------------------------------------------------------
Function DPRC322CAL()
Local lRet       := .T.
Local nResProj   := 0
Local nResDiv    := 0
Local nPrecoTeto := 0
Local nCustoFabr := 0
Local nDesUnit   := 0
Local nProjPMS   := 0
Local cLog       := ''
Default lAutoMacao := .F.

//dbSelectArea(cTabBrw)
(cTabBrw)->(dbGoTop())
While (cTabBrw)->(!EOF())
	RecLock(cTabBrw, .F., .T.)
	IF !lAutoMacao
		(cTabBrw)->(dbDelete())
	ENDIF
	(cTabBrw)->(MsUnLock())

	(cTabBrw)->(dbSkip())
End

dbSelectArea('DG0')
DG0->(dbSetOrder(1))
IF DG0->(dbSeek(xFilial('DG0')+aDados[1]+aDados[2]))

	if aDados[9] == 0
		cLog := STR0021 + " - " // Não foi informado Fator Diluição. Será adotado valor 1
		aDados[9] := 1
	Endif

	RecLock(cTabBrw, .T.)
	(cTabBrw)->SEQ    := 1
	(cTabBrw)->DSCRI  := STR0011 // Fator Diluição
	(cTabBrw)->RESULT := aDados[9]
	MsUnlock()

	if !Empty(DG0->DG0_CDPJ)
		if !Empty(DG0->DG0_CDATPJ)
			// Custo Projeto/Tarefa
			nProjPMS := PMSAF9CusTrf(0, DG0->DG0_CDPJ, PMSRevAtu(DG0->DG0_CDPJ), DG0->DG0_CDATPJ)[1]
		Else
			// Custo Projeto
			nProjPMS := DPRC322PMS(DG0->DG0_CDPJ)
		Endif
	Endif

	if nProjPMS == 0
		nProjPMS := DG0->DG0_VLPJ
	Endif

	RecLock(cTabBrw, .T.)
	(cTabBrw)->SEQ    := 2
	(cTabBrw)->DSCRI   := STR0026 // Valor Projeto
	(cTabBrw)->RESULT := nProjPMS
	MsUnlock()

	aCampos := DPRXARRDG0(.T., nProjPMS)

	// Calcular Projeto
	nResProj := DPRC321PRO(DG0->DG0_DSFOPJ, DG0->DG0_VLPJDV)

	RecLock(cTabBrw, .T.)
	(cTabBrw)->SEQ     := 3
	(cTabBrw)->DSCRI   := STR0027 // Fórmula Projeto Desenvolvimento
	(cTabBrw)->RESCHAR := IF(Empty(DG0->DG0_DSFOPJ),STR0022,'_' + DG0->DG0_DSFOPJ)
	MsUnlock()

	RecLock(cTabBrw, .T.)
	(cTabBrw)->SEQ    := 4
	(cTabBrw)->DSCRI  := STR0028 // Valor Projeto Desenvolvimento
	(cTabBrw)->RESULT := nResProj
	MsUnlock()

	// Calcular Custos Diversos
	nResDiv := DPRC321DIV(DG0->DG0_DSFOCS, DG0->DG0_VLCS)

	RecLock(cTabBrw, .T.)
	(cTabBrw)->SEQ     := 5
	(cTabBrw)->DSCRI   := STR0029 // Fórmula Custos Diversos
	(cTabBrw)->RESCHAR := if(Empty(DG0->DG0_DSFOCS),STR0023,'_' + DG0->DG0_DSFOCS)
	MsUnlock()

	RecLock(cTabBrw, .T.)
	(cTabBrw)->SEQ    := 6
	(cTabBrw)->DSCRI  := STR0030 // Valor Custos Diversos
	(cTabBrw)->RESULT := nResDiv
	MsUnlock()

	// Desenvolvimento Unitário
	nDesUnit := nResProj / if(aDados[9] > 0, aDados[9], 1)

	RecLock(cTabBrw, .T.)
	(cTabBrw)->SEQ    := 7
	(cTabBrw)->DSCRI  := STR0031 // Valor Desenvolvimento Unitário
	(cTabBrw)->RESULT := nDesUnit
	MsUnlock()

	if aDados[7] == 1 // Adição
		// Calcular Preço-Teto
		nPrecoTeto := DG0->DG0_VLCSPO + nDesUnit + nResDiv
		nCustoFabr := DG0->DG0_VLCSPO
	Else
		// Calcular Custo Fabricação
		nPrecoTeto := aDados[13]
		nCustoFabr := nPrecoTeto - nResDiv - nDesUnit
	Endif

	RecLock(cTabBrw, .T.)
	(cTabBrw)->SEQ     := 8
	(cTabBrw)->DSCRI   := STR0032 // Valor Preço Teto
	(cTabBrw)->RESULT  := nPrecoTeto
	(cTabBrw)->RESCHAR := if(aDados[7]==2 .AND. aDados[13]==0,STR0024,'')
	MsUnlock()

	RecLock(cTabBrw, .T.)
	(cTabBrw)->SEQ    := 9
	(cTabBrw)->DSCRI  := STR0033 // Valor Custo Fabricação
	(cTabBrw)->RESULT := nCustoFabr
	MsUnlock()

	RecLock(cTabBrw, .T.)
	(cTabBrw)->SEQ     := 10
	(cTabBrw)->DSCRI   := STR0034 // Observação
	(cTabBrw)->RESCHAR := cLog
	MsUnlock()
Else
	DPRXError('DPRC322','DPRC322_NAOEXI', 3) // Não existe registro para o Produto e Versão informados.
	lRet := .F.
Endif

if lRet

	aDados[8]  := nResProj   // Projeto
	aDados[10] := nDesUnit   // Desenvolvimento (Unitário)
	aDados[11] := nCustoFabr // Custo Fabricação
	aDados[12] := nResDiv    // Custos Diversos
	aDados[13] := nPrecoTeto // Preço-Teto
	aDados[14] := nProjPMS   // Projeto PMS

	DPRC322EXL(aDados[1],aDados[2])
Endif

Return lRet

//-------------------------------------------------------------------------
// DPRC322PMS - Calcula custo apenas do projeto
//-------------------------------------------------------------------------
Static Function DPRC322PMS(cCodPrj)
Local aHandle   := {}
Local nCustoPrj := 0

AF8->(dbSetOrder(1))
AF8->(dbSeek(xFilial("AF8")+cCodPrj))
aHandle   := PmsIniCOTP(cCodPrj,PMSRevAtu(cCodPrj),PMS_MAX_DATE)
nCustoPrj := PmsRetCOTP(aHandle,2,PadR(cCodPrj,TamSX3("AFC_EDT")[1]))[01]

Return nCustoPrj

//-------------------------------------------------------------------
// DPRC323TAB - Define a tabela a ser utilizada no browse
//-------------------------------------------------------------------
Static Function DPRC322TAB()
Local aDBF := {}

aDBF := { { "SEQ"    , "N",  10, 0, STR0035, .T., "@!" } , ; // Sequência
          { "DSCRI"  , "C", 100, 0, STR0036, .T., "@!" } , ; // Descrição          
		  { "RESULT" , "N",  25, 6, STR0037, .T., x3picture('DG0_VLPR') }, ; // Resultado
		  { "RESCHAR", "C", 500, 0,      '', .T., "@!" } }

Return { aDBF , {"SEQ"} }

//-------------------------------------------------------------------
// DPRC323EXL - Gera Excel
//-------------------------------------------------------------------
Static Function DPRC322EXL(cProduto, cVersao)
Local aCabExcel    := {}
Local aItensExcel  := {}
Local aItem        := {}
Local aCols        := {}
Local lExcel       := .F.
Local cLog         := ''
Default lAutoMacao := .F.

If ! ( GetRemoteType() == 5 )
	lExcel := ApOleClient("MsExcel")
EndIf

if !lExcel
	cLog := STR0042 + ' - ' + STR0005 + ': ' + cProduto + ' ' + STR0006 + ': ' + cVersao + PULALINHA + PULALINHA
	cLog += STR0038 + ';' + STR0039 + PULALINHA
Else
	// AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
	AADD(aCabExcel, {STR0038, "C", 100, 0}) // DESCRIÇÃO
	AADD(aCabExcel, {STR0039, "N", 100, 0}) // RESULTADO
	AADD(aCabExcel, {''     , "C", 500, 0})
	AADD(aCabExcel, {""     , "C", 500, 0})
Endif

dbSelectArea(cTabBrw)
(cTabBrw)->(dbSetOrder(1))
(cTabBrw)->(dbGoTop())
While (cTabBrw)->(!EOF())

	if lExcel
		aItem := Array(Len(aCabExcel))

		aItem[1] := (cTabBrw)->DSCRI
		aItem[2] := if(!Empty((cTabBrw)->RESCHAR),'',(cTabBrw)->RESULT)
		aItem[3] := (cTabBrw)->RESCHAR

		AADD(aCols,aItem)
		aItem := {}
	Else
		IF !lAutoMacao
			cLog += ALLTRIM((cTabBrw)->DSCRI) + ';' + ALLTRIM((cTabBrw)->RESULT) + ';' + ALLTRIM((cTabBrw)->RESCHAR) + PULALINHA
		ENDIF
	Endif

	(cTabBrw)->(dbSkip())
End

if lExcel
	MsgRun(STR0040, STR0041,{||DlgToExcel({{"GETDADOS",STR0042 + ' - ' + STR0005 + ': ' + cProduto + ' ' + STR0006 + ': ' + cVersao,aCabExcel,aCols}})}) // Favor Aguardar.. ## Exportando os Registros para o Arquivo ## Detalhe Preço Novo Produto
Else
	If GetRemoteType() == 5
		MsgInfo(STR0044, STR0045) // "Relatório não disponível para visualização no SmartClient HTML." ### "Aviso"
	Else
	    MemoWrite('c:\preçoNovoProduto.CSV', cLog)
	    DPRXError('DPRC322',STR0043 + 'c:\preçoNovoProduto.CSV',2)
    Endif
Endif

Return
