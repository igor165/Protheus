// …ÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕª
// ∫ Versao ∫ 27     ∫
// »ÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕº

#Include "Protheus.ch"
#Include "VEIVC080.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  29/01/2018
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007641_1"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ VEIVC080 ≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 11/06/07 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Consulta Negocios com Veiculos (VV9/VV0)                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VEIVC080(cPAREmp, aPAREmp, cPARCom, nPARCom, dPARDtI, dPARDtF, cPARCod, cPARLoj, cPARNom)
//variaveis controle de janela
Local aObjects  := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local nTam      := 0
////////////////////////////////////////////////////////////////////////////////////////////
Local lDClik    := .f.
Local aFWArrFilAtu := FWArrFilAtu()
Local cTitCol   := ""
Local nDivCol   := 1000
Local cMasCol   := ""
Local cDirCol   := ""
Private aSizeAut   := MsAdvSize(.F.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private lMarcar := .f.
Private aVetEmp := {}
Private aEmpr   := {} // Filiais Consolidadas
Private cEmpr   := "" // Nome da Empresa
Private aNVei   := {} // VV9 / VV0 - ATENDIMENTOS
Private aGrp    := {} // Grupo Modelo
Private aGrpE   := {} // Especif do Grupo
Private aGrpEA  := {} // Especif Acessorios
Private aGrpEG  := {} // Especif Agregados
Private aMod    := {} // Modelo
Private aModE   := {} // Especif do Modelo
Private aModEA  := {} // Especif Acessorios
Private aModEG  := {} // Especif Agregados
Private aAte    := {} // Atendimento
Private aAteE   := {} // Especif do Atendimento
Private aAteEA  := {} // Especif Acessorios
Private aAteEG  := {} // Especif Agregados
Private oDiaHrG
Private oDiaHrM
Private cDiaHrG := ""
Private cDiaHrM := ""
Private cDiaHrA := ""
Private cDiaHrE := ""
Private cTitulo := ""
Private cFiltro := ""
Private aCombo  := {STR0004,STR0005}             // Analise por: "1-Valor / 2-Qtde."
Private cComboG := cComboM := cComboA := STR0004 // Analise por: "1-Valor / 2-Qtde."
Private nComboG := nComboM := nComboA := 1       // Analisepor : "1-Valor / 2-Qtde."
Private cCodCli := space(TamSX3("A1_COD")[1])
Private cLojCli := space(TamSX3("A1_LOJA")[1])
Private cNomCli := space(TamSX3("A1_NOME")[1])
Private dDatIni := dDataBase
Private dDatFin := dDataBase
Private nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nQtde := 0
Private Inclui  := .f. // Variavel INTERNA utilizada no VEIVM011
Private Altera  := .f. // Variavel INTERNA utilizada no VEIVM011
Private lEmiNfi := .t. // Variavel INTERNA utilizada no VEIVM011
Private lNegPag := .t. // Variavel INTERNA utilizada no VEIVM011
Private lLibVei := .f. // Variavel INTERNA utilizada no VEIVM011
Private lAutFat := .f. // Variavel INTERNA utilizada no VEIVM011
Private _lVerBotoes := .f. // Variavel INTERNA utilizada no VEIVM011
Private bFiltraBrw := {|| Nil}
Private aCampos := {}
Private cCadastro := (STR0007) // Atendimento de Venda
Private aNewBot := {}
Private aRotina := {{"","PesqV011", 0, 1},;
					{"","ATEND011", 0, 2},;
					{"","ATEND011", 0, 3},;
					{"","ATEND011", 0, 4},;
					{"","ATEND011", 0, 5}}
Default cPARCom := cComboG
Default nPARCom := nComboG
Default dPARDtI := dDatIni
Default dPARDtF := dDatFin
Default cPARCod := cCodCli
Default cPARLoj := cLojCli
Default cPARNom := cNomCli
Default cPAREmp := ""
Default aPAREmp := aEmpr

aEmpr := aPAREmp
If !Empty(cPAREmp)
	cEmpr := " - "+STR0010+" " // Consolidado:
	aEmpr := FS_FILIAIS() // Levantamento das Filiais
	If len(aEmpr) == 0
		MsgAlert(STR0003,STR0002) // N„o existem dados para esta Consulta ! / AtenÁ„o
		Return
	EndIf
Else
	aAdd(aEmpr,{ cFilAnt , aFWArrFilAtu[SM0_FILIAL] })
EndIf

If len(aEmpr) == 1 .and. (aEmpr[1,1]==cFilAnt)
	cEmpr := " - " + Alltrim(FWFilialName()) + " ( " + cFilAnt + " )"
EndIf

cComboG := cComboM := cComboA := cPARCom
nComboG := nComboM := nComboA := nPARCom
dDatIni := dPARDtI
dDatFin := dPARDtF
cCodCli := cPARCod
cLojCli := cPARLoj
cNomCli := cPARNom

Processa( {|| FS_GRPMOD(0) } )

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 000, 020 , .T. , .F. } ) //cabecalho
AAdd( aObjects, { 000, 000 , .T. , .T. } ) //listbox
AAdd( aObjects, { 000, 022 , .T. , .F. } ) //rodape

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oNegVei FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE (STR0001 + " (" + STR0006 + ")" + cEmpr) OF oMainWnd ;
	PIXEL STYLE DS_MODALFRAME STATUS // Negocios com Veiculos / Valor em Milhar

	oNegVei:lEscClose := .F.

	// Vari·veis (Valor/Qtde.)
	nDivCol := Iif(cComboG==STR0004, 1000, 1)
	cMasCol := Iif(cComboG==STR0004, "@E 99,999,999.99", "@E 99,999,999")
	cDirCol := Iif(cComboG==STR0004, "RIGHT", "LEFT")
	// Fim Vari·veis (Valor/Qtde.)

	// CabeÁalho
	// Analise
	@ aPos[1,1], aPos[1,2] TO aPos[1,3], aPos[1,4] - 160 LABEL (" " + STR0012 + " ") OF oNegVei PIXEL // Filtrar

	@ aPos[1,1] + 007, aPos[1,2] + 004 SAY STR0031 SIZE 30,08 OF oNegVei PIXEL COLOR CLR_BLUE // Analise por:

	@ aPos[1,1] + 006, aPos[1,2] + 034 MSCOMBOBOX oNegCombo VAR cComboG ITEMS aCombo ;
		VALID( nComboG:=Iif(cComboG==STR0004, 1, 2), FS_GRPMOD(2) ) ;
		SIZE 35,07 OF oNegVei PIXEL COLOR CLR_BLUE // Analise por: "1-Valor / 2-Qtde."
	// Fim Analise

	// Periodo
	@ aPos[1,1] + 007, aPos[1,2] + 072 SAY STR0013 SIZE 35,08 OF oNegVei PIXEL COLOR CLR_BLUE // Periodo:

	@ aPos[1,1] + 006, aPos[1,2] + 092 MSGET oDatIni VAR dDatIni VALID( dDatIni <= dDataBase ) ;
		SIZE 45,08 OF oNegVei PIXEL COLOR CLR_BLUE

	@ aPos[1,1] + 007, aPos[1,2] + 138 SAY STR0014 SIZE 10,08 OF oNegVei PIXEL COLOR CLR_BLUE // a

	@ aPos[1,1] + 006, aPos[1,2] + 143 MSGET oDatFin VAR dDatFin VALID( dDatIni <= dDatFin .and. dDatFin <= dDataBase ) ;
		SIZE 45,08 OF oNegVei PIXEL COLOR CLR_BLUE
	// Fim Periodo

	// Cliente
	@ aPos[1,1] + 007, aPos[1,2] + 190 SAY STR0015 SIZE 35,08 OF oNegVei PIXEL COLOR CLR_BLUE // Cliente:

	@ aPos[1,1] + 006, aPos[1,2] + 210 MSGET oCodCli VAR cCodCli VALID FS_NOMCLI() F3 "SA1" ;
		SIZE 31,08 OF oNegVei PIXEL COLOR CLR_BLUE

	@ aPos[1,1] + 006, aPos[1,2] + 243 MSGET oLojCli VAR cLojCli VALID FS_NOMCLI() ;
		SIZE 10,08 OF oNegVei PIXEL COLOR CLR_BLUE

	@ aPos[1,1] + 007, aPos[1,2] + 310 SAY cNomCli SIZE 80,08 OF oNegVei PIXEL COLOR CLR_BLUE
	// Fim Cliente

	// Botıes
	@ aPos[1,1] + 006, aPos[1,4] - 152 BUTTON oOk PROMPT STR0016 OF oNegVei SIZE 45,10 PIXEL ACTION Processa( {|| FS_GRPMOD(1) } ) // < OK >

	@ aPos[1,1] + 006, aPos[1,4] - 100 BUTTON oEmpr PROMPT UPPER(STR0017) OF oNegVei ;
		SIZE 45,10 PIXEL ACTION (lDClik:=.t.,oNegVei:End()) // Filiais

	@ aPos[1,1] + 006, aPos[1,4] - 048 BUTTON oLegG PROMPT UPPER(STR0088) OF oNegVei SIZE 45,10 PIXEL ACTION VEIVC80LEG("G") // Legenda
	// Fim Botıes
	// Fim CabeÁalho

	// Criar o objeto ListBox (Grupo Modelo)
	oLbGrp := TWBrowse():New(aPos[2,1] + 002, aPos[2,2] + 001, (aPos[2,4] - aPos[2,2]), (aPos[2,3] - aPos[2,1]),,,,oNegVei,,,,,                                       ;
		{ || nComboM:=nComboG, cComboM:=cComboG, FS_ANALIT("M", oLbGrp:nAt) },,,,,,,.F.,,.T.,,.F.,,,)

	oLbGrp:addColumn( TCColumn():New( STR0023, { || aGrp[oLbGrp:nAt,9] + " " + Alltrim(left(aGrp[oLbGrp:nAt,1],6)) + " " + Alltrim(substr(aGrp[oLbGrp:nAt,1],7)) }   ,;
		,,,"LEFT" ,101,.F.,.F.,,,,.F.,) ) // Grupo Modelo

	oLbGrp:addColumn( TCColumn():New( STR0024, { || Transform(aGrp[oLbGrp:nAt,2],"@E 9,999,999") }                                                                   ,;
		,,,"LEFT" , 28,.F.,.F.,,,,.F.,) ) // Pedidos

	oLbGrp:addColumn( TCColumn():New( STR0055, { || Transform(aGrp[oLbGrp:nAt,3],"@E 9,999,999") }                                                                   ,;
		,,,"LEFT" , 63,.F.,.F.,,,,.F.,) ) // Tr‚nsito / Progresso

	oLbGrp:addColumn( TCColumn():New( STR0026, { || Transform(aGrp[oLbGrp:nAt,4],"@E 9,999,999") }                                                                   ,;
		,,,"LEFT" , 28,.F.,.F.,,,,.F.,) ) // Estoque


	cTitCol := Iif(cComboG==STR0004, STR0027, STR0064)
	oLbGrp:addColumn( TCColumn():New( cTitCol, { || Transform(aGrp[oLbGrp:nAt,5] / nDivCol, cMasCol) }                                                               ,;
		,,,cDirCol, 63,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) Total do Grupo

	oLbGrp:addColumn( TCColumn():New( "% (1)", { || Transform((aGrp[oLbGrp:nAt,5] / aGrp[1,5]) * 100, "@E 9999") + "%" }                                             ,;
		,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % Total de RepresentaÁ„o no Grupo (STR0056)


	cTitCol := Iif(cComboG==STR0004, STR0028, STR0066)
	oLbGrp:addColumn( TCColumn():New( cTitCol, { || IIf(aGrp[oLbGrp:nAt,6] > 0 , Transform(aGrp[oLbGrp:nAt,6] / nDivCol, cMasCol), "") }                             ,;
		,,,cDirCol, 80,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos Finalizados

	oLbGrp:addColumn( TCColumn():New( "% (2)", { || IIf(aGrp[oLbGrp:nAt,6] > 0, Transform((aGrp[oLbGrp:nAt,6] / aGrp[oLbGrp:nAt,5]) * 100, "@E 9999") + "%", "") }   ,;
		,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. Finalizados no Grupo (STR0058)


	cTitCol := Iif(cComboG==STR0004, STR0029, STR0067)
	oLbGrp:addColumn( TCColumn():New( cTitCol, { || IIf(aGrp[oLbGrp:nAt,7] > 0, Transform(aGrp[oLbGrp:nAt,7] / nDivCol, cMasCol), "") }                              ,;
		,,,cDirCol, 92,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos N„o Finalizados

	oLbGrp:addColumn( TCColumn():New( "% (3)", { || IIf(aGrp[oLbGrp:nAt,7] > 0, Transform((aGrp[oLbGrp:nAt,7] / aGrp[oLbGrp:nAt,5]) * 100, "@E 9999") + "%", "") }   ,;
		,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. N„o Finalizados no Grupo (STR0060)


	cTitCol := Iif(cComboG==STR0004, STR0030, STR0068)
	oLbGrp:addColumn( TCColumn():New( cTitCol, { || IIf(aGrp[oLbGrp:nAt,8] > 0, Transform(aGrp[oLbGrp:nAt,8] / nDivCol, cMasCol), "") }                              ,;
		,,,cDirCol, 82,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos Cancelados

	oLbGrp:addColumn( TCColumn():New( "% (4)", { || IIf(aGrp[oLbGrp:nAt,8] > 0, Transform((aGrp[oLbGrp:nAt,8] / aGrp[oLbGrp:nAt,5]) * 100, "@E 9999") + "%", "") }   ,;
		,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. Cancelados no Grupo (STR0062)

	oLbGrp:nAT := 1
	oLbGrp:SetArray(aGrp)
	oLbGrp:SetFocus()
	oLbGrp:Refresh()
	// Fim Criar o objeto ListBox (Grupo Modelo)

	// RodapÈ
	// Divide a janela em trÍs colunas
	nTam := ( (aPos[1,4] - 81 - 102) / 5 )

	@ aPos[3,1] + 001, 002 SAY oDiaHrG VAR cDiaHrG SIZE 80,08 OF oNegVei PIXEL COLOR CLR_RED

	@ aPos[3,1] + 009, 002 BUTTON oGrpAtual PROMPT STR0032 OF oNegVei SIZE 71,10 PIXEL ACTION Processa( {|| FS_GRPMOD(1) } ) // <<<     ATUALIZAR     >>>

	// Botıes An·lise Gr·fica (Gr·ficos)
	@ aPos[3,1] + 000, 077 + (nTam * 0) TO aPos[3,3], 077 + (nTam * 5) LABEL (" " + STR0017 + " ") OF oNegVei PIXEL // Analise Gr·fica

	@ aPos[3,1] + 009, 077 + (nTam * 0) + ((((nTam * 1) - (nTam * 0)) - 43) / 2) BUTTON oGrpGra1 PROMPT STR0033 OF oNegVei ;
		SIZE 45,10 PIXEL ACTION FS_GRAFICO("1", aGrp, oLbGrp:nAt, 6, STR0036, cComboG) // Linha do Grupo / Grupo

	@ aPos[3,1] + 009, 077 + (nTam * 1) + ((((nTam * 2) - (nTam * 1)) - 43) / 2) BUTTON oGrpGra2 PROMPT STR0069 OF oNegVei ;
		SIZE 45,10 PIXEL ACTION FS_GRAFICO("2", aGrp, 6, 6, STR0037, cComboG) // Finalizados/ Grupos

	@ aPos[3,1] + 009, 077 + (nTam * 2) + ((((nTam * 3) - (nTam * 2)) - 43) / 2) BUTTON oGrpGra3 PROMPT STR0070 OF oNegVei ;
		SIZE 45,10 PIXEL ACTION FS_GRAFICO("2", aGrp, 7, 6, STR0037, cComboG) // N„o Finalizados / Grupos

	@ aPos[3,1] + 009, 077 + (nTam * 3) + ((((nTam * 4) - (nTam * 3)) - 43) / 2) BUTTON oGrpGra4 PROMPT STR0071 OF oNegVei ;
		SIZE 45,10 PIXEL ACTION FS_GRAFICO("2", aGrp, 8, 6, STR0037, cComboG) // Cancelados / Grupos

	@ aPos[3,1] + 009, 077 + (nTam * 4) + ((((nTam * 5) - (nTam * 4)) - 43) / 2) BUTTON oGrpGra5 PROMPT STR0035 OF oNegVei ;
		SIZE 45,10 PIXEL ACTION FS_GRAFICO("3", aGrp, 1, 6, UPPER(STR0037), cComboG) // Total / Grupos
	// Fim Botıes An·lise Gr·fica (Gr·ficos)

	// Botıes
	@ aPos[3,1] + 000, aPos[1,4] - 102 TO aPos[3,3], aPos[1,4] - 52 LABEL (" " + STR0019 + " ") OF oNegVei PIXEL // Ranking

	@ aPos[3,1] + 009, aPos[1,4] - 100 BUTTON oRanking PROMPT STR0021 OF oNegVei ;
		SIZE 45,10 PIXEL ACTION FS_RANKING(aGrp[oLbGrp:nAt,9], aGrp[oLbGrp:nAt,1],, nComboG, cComboG) // Vendedor

	@ aPos[3,1] + 009, aPos[1,4] - 48 BUTTON oGrpSair PROMPT STR0034 OF oNegVei SIZE 45,10 PIXEL ACTION oNegVei:End() // <<<  S A I R  >>>
	// Fim Botıes
	// Fim RodapÈ

ACTIVATE MSDIALOG oNegVei CENTER

If lDClik
	VEIVC080(cEmpr, aEmpr, cComboG, nComboG, dDatIni, dDatFin, cCodCli, cLojCli, cNomCli)
EndIf
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_NOMCLI≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 11/06/07 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Levantamento do Nome do Cliente (SA1)                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_NOMCLI()
Local lRet := .f.
Local cQuery  := ""
Local cQAlSA1 := "SQLSA1"

cNomCli := space(TamSX3("A1_NOME")[1])

If Empty(cCodCli)
	lRet := .t.
	cLojCli := space(TamSX3("A1_LOJA")[1])
Else
	// Posiciona no SA1
	cQuery := "SELECT SA1.A1_NOME, SA1.A1_COD, SA1.A1_LOJA FROM " + RetSqlName("SA1") + " SA1 WHERE "
	cQuery += "SA1.A1_FILIAL='" + xFilial("SA1") + "' AND SA1.A1_COD='" + cCodCli + "' AND "
	cQuery += IIf(!Empty(cLojCli), "SA1.A1_LOJA='" + cLojCli + "' AND ", "") + "SA1.D_E_L_E_T_=' '"
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA1, .F., .T. )

	If ( cQAlSA1 )->( A1_COD ) == cCodCli .and. ( Empty(cLojCli) .or. ( cQAlSA1 )->( A1_LOJA ) == cLojCli )
		lRet := .t.
		cNomCli := ( cQAlSA1 )->( A1_NOME )
		cLojCli := ( cQAlSA1 )->( A1_LOJA )
	EndIf

	( cQAlSA1 )->( dbCloseArea() )
EndIf
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_ATEND ≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 11/06/07 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Levantamento dos Atendimentos conforme o Filtro            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_ATEND(lLevant)
Local nEmpr    := 0
Local cQuery   := ""
Local cQAlVV09 := "SQLVV09" // VV0 / VV9
Local cFilSALVA:= cFilAnt
Default lLevant:= .f.

If dDatFin == dDataBase .or. lLevant
	aNVei := {}

	For nEmpr := 1 to len(aEmpr)
		cFilAnt := aEmpr[nEmpr,1]

		// Levanta os Atendimentos VV9 / VV0
		cQuery := FS_ABRESQL("VV09_1",,,,,)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )

		Do While !( cQAlVV09 )->( Eof() )
			If !Empty( ( cQAlVV09 )->( VV9_NUMATE ) )
				Aadd(aNVei,{ ( cQAlVV09 )->( VV9_NUMATE ) , aEmpr[nEmpr,1] , aEmpr[nEmpr,2] })
			EndIf

			( cQAlVV09 )->( DbSkip() )
		EndDo

		( cQAlVV09 )->( dbCloseArea() )
	Next

	aSort(aNVei, 1,, {|x , y| x[2] + x[3] + x[1] < y[2] + y[3] + y[1] })
EndIf

cFilAnt := cFilSALVA
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_GRPMOD≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 11/06/07 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Levantamento pela Marca / Grupos de Modelo                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_GRPMOD(nx)
Local nNVei   := 0
Local nPos    := 0
Local nPosAnt := 0
Local ni      := 0
Local cData   := ""
Local cDtAux  := ""
Local cQuery  := ""
Local cQAlVV09:= "SQLVV09" // VV0 / VV9
Local cQAlVV1 := "SQLVV1"
Local cQAlVVR := "SQLVVR"
Local nEstoq  := 0
Local aEstoq  := {}
Local cFilSALVA:= cFilAnt
Local cTitCol := ""
Local nDivCol := 1000
Local cMasCol := ""
Local cDirCol := ""

nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nQtde := 0
aGrp := {}

If nx # 2
	cFiltro := STR0013 + " " + Transform(dDatIni, "@D") + " " + STR0014 + " " + Transform(dDatFin, "@D") +;
		IIf(!Empty(cCodCli+cLojCli), "      " + STR0015 + " "+ cCodCli + "-" + cLojCli + "  " + cNomCli, "") // Periodo: / a / Cliente:

	FS_ATEND(.t.)
EndIf

For nNVei := 1 to len(aNVei)
	cFilAnt := aNVei[nNVei,2]

	// Posiciona no VV9/VV0 com NRO.ATENDIMENTO
	cQuery := FS_ABRESQL("VV09_2",aNVei[nNVei,1],,,,)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )

	If !Empty( ( cQAlVV09 )->( VVA_GRUMOD ) + ( cQAlVV09 )->( VVA_MODVEI ) )
		nPos := aScan(aGrp, {|x| x[9] + left(x[1], 6) == ( cQAlVV09 )->( VVA_CODMAR ) + left(( cQAlVV09 )->( VVA_GRUMOD ), 6) })
		If nPos == 0
			// Posiciona no VVR com VVA_CODMAR+VVA_GRUMOD
			cQuery := FS_ABRESQL("VVR",( cQAlVV09 )->( VVA_CODMAR ), left(( cQAlVV09 )->( VVA_GRUMOD ), 6),,,)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVR, .F., .T. )

			Aadd(aGrp, { left(( cQAlVV09 )->( VVA_GRUMOD ), 6) + " - " + ( cQAlVVR )->( VVR_DESCRI ),;
						 0 ,;
						 0 ,;
						 0 ,;
						 0 ,;
						 0 ,;
						 0 ,;
						 0 ,;
						 ( cQAlVV09 )->( VVA_CODMAR );
					   })

			( cQAlVVR )->( dbCloseArea() )

			nPos := len(aGrp)
		EndIf

		nEstoq := aScan(aEstoq, {|x| x[1] == ( cQAlVV09 )->( VVA_CODMAR ) + left(( cQAlVV09 )->( VVA_GRUMOD ), 6) + aNVei[nNVei,2] })
		If nEstoq == 0
			Aadd(aEstoq, {( cQAlVV09 )->( VVA_CODMAR ) + left(( cQAlVV09 )->( VVA_GRUMOD ), 6) + aNVei[nNVei,2] })

			// Levanta Qtde de Estoque no VV1 por Grupo de Modelo
			nQtde := 0

			cQuery := FS_ABRESQL("VV1_1", ( cQAlVV09 )->( VVA_CODMAR ), left(( cQAlVV09 )->( VVA_GRUMOD ), 6),,,)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. )

			If !( cQAlVV1 )->( Eof() )
				nQtde := ( cQAlVV1 )->( QTDVEI )
			EndIf

			( cQAlVV1 )->( dbCloseArea() )

			aGrp[nPos,3] += nQtde
			nTot3 += nQtde

			// Levanta Qtde de Veiculos Pedidos no VV1 por Grupo de Modelo
			nQtde := 0

			cQuery := FS_ABRESQL("VV1_2",( cQAlVV09 )->( VVA_CODMAR ), left(( cQAlVV09 )->( VVA_GRUMOD ), 6),,,)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. )

			If !( cQAlVV1 )->( Eof() )
				nQtde := ( cQAlVV1 )->( QTDVEI )
			EndIf

			( cQAlVV1 )->( dbCloseArea() )

			aGrp[nPos,2] += nQtde
			nTot2 += nQtde

			// Levanta Qtde de Veiculos Tr‚nsito / Progresso no VV1 por Grupo de Modelo
			nQtde := 0

			cQuery := FS_ABRESQL("VV1_3",( cQAlVV09 )->( VVA_CODMAR ),left(( cQAlVV09 )->( VVA_GRUMOD ), 6),,,)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. )

			If !( cQAlVV1 )->( Eof() )
				nQtde := ( cQAlVV1 )->( QTDVEI )
			EndIf

			( cQAlVV1 )->( dbCloseArea() )

			aGrp[nPos,4] += nQtde
			nTot4 += nQtde
		EndIf

		nComboM := nComboA := nComboG
		cComboM := cComboA := cComboG
		ni := 0

		If ( cQAlVV09 )->( VV9_STATUS ) $ "FT" // Finalizados
			ni := 6
		ElseIf ( cQAlVV09 )->( VV9_STATUS ) $ "ORLAP" // N„o Finalizados
			ni := 7
		ElseIf ( cQAlVV09 )->( VV9_STATUS ) $ "CD" // Canceladas
			ni := 8
		EndIf

		If ni > 0
			If nComboG == 1 // Por Valor
				nTot1 := ( cQAlVV09 )->( VV0_VALMOV ) + ( cQAlVV09 )->( VV0_ACESSO ) + ( cQAlVV09 )->( VV0_AGREGA ) // Vlr Movto + Acessorios + Agregados
				If nTot1 == 0
					nTot1 := (0.0000001)
				EndIf
			Else // Por Qtde.
				nTot1 := 1
			EndIf

			aGrp[nPos,5] += nTot1
			nTot5 += nTot1
			aGrp[nPos,ni] += nTot1
			&("nTot"+strzero(ni,1)) += nTot1
		EndIf
	EndIf

	( cQAlVV09 )->( dbCloseArea() )
Next

cFilAnt := cFilSALVA

If len(aGrp) > 0
	Aadd(aGrp, { space(6) + "***  " + STR0038 + "  ***",;
				 nTot2,;
				 nTot3,;
				 nTot4,;
				 nTot5,;
				 nTot6,;
				 nTot7,;
				 nTot8,;
				 "";
			   }) // T O T A L   G E R A L

	aSort(aGrp, 1,, {|x , y| x[9] + x[1] < y[9] + y[1] })
Else
	Aadd(aGrp, { "",;
				  0,;
				  0,;
				  0,;
				  0,;
				  0,;
				  0,;
				  0,;
				  "";
			   })
EndIf

cDtAux  := Transform(dDataBase, "@D")
cDiaHrG := STR0039 + " " + left(cDtAux, 6) + right(cDtAux, 2) + " " + left(time(), 5) + STR0040 // PosiÁ„o de / hs

If nx # 0
	nPosAnt := oLbGrp:nAt
	If nPosAnt > len(aGrp)
		nPosAnt := 1
	EndIf

	oDiaHrG:Refresh()

	// Vari·veis (Valor/Qtde.)
	nDivCol := Iif(cComboG==STR0004, 1000, 1)
	cMasCol := Iif(cComboG==STR0004, "@E 99,999,999.99", "@E 99,999,999")
	cDirCol := Iif(cComboG==STR0004, "RIGHT", "LEFT")
	// Fim Vari·veis (Valor/Qtde.)

	// Destruir o objeto
	oLbGrp := Nil
	// Fim Destruir o objeto

	// Criar novamente o objeto ListBox (Grupo Modelo)
	oLbGrp := TWBrowse():New(aPos[2,1] + 002, aPos[2,2] + 001, (aPos[2,4] - aPos[2,2]), (aPos[2,3] - aPos[2,1]),,,,oNegVei,,,,,                                       ;
		{ || nComboM:=nComboG, cComboM:=cComboG, FS_ANALIT("M", oLbGrp:nAt) },,,,,,,.F.,,.T.,,.F.,,,)

	oLbGrp:addColumn( TCColumn():New( STR0023, { || aGrp[oLbGrp:nAt,9] + " " + Alltrim(left(aGrp[oLbGrp:nAt,1], 6)) + " " + Alltrim(substr(aGrp[oLbGrp:nAt,1], 7)) } ,;
		,,,"LEFT" ,101,.F.,.F.,,,,.F.,) ) // Grupo Modelo

	oLbGrp:addColumn( TCColumn():New( STR0024, { || Transform(aGrp[oLbGrp:nAt,2],"@E 9,999,999") }                                                                   ,;
		,,,"LEFT" , 28,.F.,.F.,,,,.F.,) ) // Pedidos

	oLbGrp:addColumn( TCColumn():New( STR0055, { || Transform(aGrp[oLbGrp:nAt,3],"@E 9,999,999") }                                                                   ,;
		,,,"LEFT" , 63,.F.,.F.,,,,.F.,) ) // Tr‚nsito / Progresso

	oLbGrp:addColumn( TCColumn():New( STR0026, { || Transform(aGrp[oLbGrp:nAt,4],"@E 9,999,999") }                                                                   ,;
		,,,"LEFT" , 28,.F.,.F.,,,,.F.,) ) // Estoque


	cTitCol := Iif(cComboG==STR0004, STR0027, STR0064)
	oLbGrp:addColumn( TCColumn():New( cTitCol, { || Transform(aGrp[oLbGrp:nAt,5] / nDivCol, cMasCol) }                                                               ,;
		,,,cDirCol, 63,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) Total do Grupo

	oLbGrp:addColumn( TCColumn():New( "% (1)", { || Transform((aGrp[oLbGrp:nAt,5] / aGrp[1,5]) * 100, "@E 9999") + "%" }                                             ,;
		,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % Total de RepresentaÁ„o no Grupo (STR0056)


	cTitCol := Iif(cComboG==STR0004, STR0028, STR0066)
	oLbGrp:addColumn( TCColumn():New( cTitCol, { || IIf(aGrp[oLbGrp:nAt,6] > 0 , Transform(aGrp[oLbGrp:nAt,6] / nDivCol, cMasCol), "") }                             ,;
		,,,cDirCol, 80,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos Finalizados

	oLbGrp:addColumn( TCColumn():New( "% (2)", { || IIf(aGrp[oLbGrp:nAt,6] > 0, Transform((aGrp[oLbGrp:nAt,6] / aGrp[oLbGrp:nAt,5]) * 100, "@E 9999") + "%", "") }   ,;
		,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. Finalizados no Grupo (STR0058)


	cTitCol := Iif(cComboG==STR0004, STR0029, STR0067)
	oLbGrp:addColumn( TCColumn():New( cTitCol, { || IIf(aGrp[oLbGrp:nAt,7] > 0, Transform(aGrp[oLbGrp:nAt,7] / nDivCol, cMasCol), "") }                              ,;
		,,,cDirCol, 92,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos N„o Finalizados

	oLbGrp:addColumn( TCColumn():New( "% (3)", { || IIf(aGrp[oLbGrp:nAt,7] > 0, Transform((aGrp[oLbGrp:nAt,7] / aGrp[oLbGrp:nAt,5]) * 100, "@E 9999") + "%", "") }   ,;
		,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. N„o Finalizados no Grupo (STR0060)


	cTitCol := Iif(cComboG==STR0004, STR0030, STR0068)
	oLbGrp:addColumn( TCColumn():New( cTitCol, { || IIf(aGrp[oLbGrp:nAt,8] > 0, Transform(aGrp[oLbGrp:nAt,8] / nDivCol, cMasCol), "") }                              ,;
		,,,cDirCol, 82,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos Cancelados

	oLbGrp:addColumn( TCColumn():New( "% (4)", { || IIf(aGrp[oLbGrp:nAt,8] > 0, Transform((aGrp[oLbGrp:nAt,8] / aGrp[oLbGrp:nAt,5]) * 100, "@E 9999") + "%", "") }   ,;
		,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. Cancelados no Grupo (STR0062)

	If nx == 3
		oLbGrp:nAT := nPosAnt
	Else
		oLbGrp:nAT := 1
	EndIf

	oLbGrp:SetArray(aGrp)
	oLbGrp:SetFocus()
	oLbGrp:Refresh()
	// Fim Criar novamente o objeto ListBox (Grupo Modelo)
EndIf
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_ANALIT≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 11/06/07 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Levantamento por Modelo / Atendimento                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_ANALIT(cx, nx, cEmpF)
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.F.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0
Local nTam := 0
////////////////////////////////////////////////////////////////////////////////////////////
Local ni     := 0
Local nNVei  := 0
Local nAtVet := 0
Local lDClik := .f.
Local nCMAux := nComboM
Local cCMAux := cComboM
Local cQuery  := ""
Local cQAlVV09:= "SQLVV09" // VV0 / VV9
Local cQAlVV1 := "SQLVV1"
Local cQAlVV2 := "SQLVV2"
Local cQAlSA1 := "SQLSA1"
Local nEstoq  := 0
Local aEstoq  := {}
Local cFilSALVA:= cFilAnt
Local cDtAux  := ""
Local cTitCol := ""
Local nDivCol := 1000
Local cMasCol := ""
Local cDirCol := ""

Default cEmpF := cFilAnt

If cx $ "MA" // Modelo/Atendimento
	If cx == "M" .and. dDatFin == dDataBase .and. left(Alltrim(aGrp[oLbGrp:nAt,1]), 3) # "***"
		//Processa( {|| FS_GRPMOD(3) } )
		nComboM := nCMAux
		cComboM := cCMAux
	Else
		FS_ATEND()
	EndIf
EndIf

nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nQtde := 0

If cx == "M" // Modelo
	If left(Alltrim(aGrp[nx,1]), 3) # "***" .and. !Empty(aGrp[nx,1])
		cTitulo := aGrp[nx,9] + " " + Alltrim(left(aGrp[nx,1], 6)) + " " + Alltrim(substr(aGrp[nx,1], 7))
		cDtAux := Transform(dDataBase, "@D")
		cDiaHrM := STR0039 + " " + left(cDtAux, 6) + right(cDtAux, 2) + " " + left(time(), 5) + STR0040 // PosiÁ„o de / hs
		aMod := {}

		For nNVei := 1 to len(aNVei)
			cFilAnt := aNVei[nNVei, 2]

			// Posiciona no VV9/VV0 com NRO.ATENDIMENTO
			cQuery := FS_ABRESQL("VV09_2", aNVei[nNVei,1], aGrp[nx,9], left(aGrp[nx,1], 6),,)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )

			If !Empty( ( cQAlVV09 )->( VVA_GRUMOD ) + ( cQAlVV09 )->( VVA_MODVEI ) )
				nPos := aScan(aMod, {|x| x[9] + left(x[1], 30) == ( cQAlVV09 )->( VVA_CODMAR ) + left(( cQAlVV09 )->( VVA_MODVEI ), 30) })
				If nPos == 0
					// Posiciona no VV2 para mostrar a Descricao do Modelo
					cQuery := FS_ABRESQL("VV2", ( cQAlVV09 )->( VVA_CODMAR ), ( cQAlVV09 )->( VVA_MODVEI ),,,)
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV2, .F., .T. )

					Aadd(aMod, { ( cQAlVV09 )->( VVA_MODVEI ) + " - " + left(( cQAlVV2 )->( VV2_DESMOD ), 30) ,;
								 0 ,;
								 0 ,;
								 0 ,;
								 0 ,;
								 0 ,;
								 0 ,;
								 0 ,;
						 		 ( cQAlVV09 )->( VVA_CODMAR );
							   })

					( cQAlVV2 )->( dbCloseArea() )

					nPos := len(aMod)
				EndIf

				nEstoq := aScan(aEstoq, {|x| x[1] == ( cQAlVV09 )->( VVA_CODMAR ) + left(( cQAlVV09 )->( VVA_GRUMOD ), 6) +;
					left(( cQAlVV09 )->( VVA_MODVEI ), 30) + aNVei[nNVei,2] })
				If nEstoq == 0
					Aadd(aEstoq, {( cQAlVV09 )->( VVA_CODMAR ) + left(( cQAlVV09 )->( VVA_GRUMOD ), 6) +;
						left(( cQAlVV09 )->( VVA_MODVEI ), 30) + aNVei[nNVei,2] })

					// Levanta Qtde de Estoque no VV1 por Modelo
					nQtde := 0

					cQuery := FS_ABRESQL("VV1_1", ( cQAlVV09 )->( VVA_CODMAR ), left(( cQAlVV09 )->( VVA_GRUMOD ), 6),;
						left(( cQAlVV09 )->( VVA_MODVEI ), 30),,)
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. )

					If !( cQAlVV1 )->( Eof() )
						nQtde := ( cQAlVV1 )->( QTDVEI )
					EndIf

					( cQAlVV1 )->( dbCloseArea() )

					aMod[nPos,3] += nQtde
					nTot3 += nQtde

					// Levanta Qtde de Veiculos Pedidos no VV1 por Modelo
					nQtde := 0

					cQuery := FS_ABRESQL("VV1_2", ( cQAlVV09 )->( VVA_CODMAR ), left(( cQAlVV09 )->( VVA_GRUMOD ), 6),;
						left(( cQAlVV09 )->( VVA_MODVEI ), 30),,)
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. )

					If !( cQAlVV1 )->( Eof() )
						nQtde := ( cQAlVV1 )->( QTDVEI )
					EndIf

					( cQAlVV1 )->( dbCloseArea() )

					aMod[nPos,2] += nQtde
					nTot2 += nQtde

					// Levanta Qtde de Veiculos Tr‚nsito / Progresso no VV1 por Modelo
					nQtde := 0

					cQuery := FS_ABRESQL("VV1_3", ( cQAlVV09 )->( VVA_CODMAR ), left(( cQAlVV09 )->( VVA_GRUMOD ), 6),;
						left(( cQAlVV09 )->( VVA_MODVEI ), 30),,)
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. )

					If !( cQAlVV1 )->( Eof() )
						nQtde := ( cQAlVV1 )->( QTDVEI )
					EndIf

					( cQAlVV1 )->( dbCloseArea() )

					aMod[nPos,4] += nQtde
					nTot4 += nQtde
				EndIf

				nComboA := nComboM
				cComboA := cComboM
				ni := 0

				If ( cQAlVV09 )->( VV9_STATUS ) $ "FT" // Finalizados
					ni := 6
				ElseIf ( cQAlVV09 )->( VV9_STATUS ) $ "ORLAP" // Nao Finalizados
					ni := 7
				ElseIf ( cQAlVV09 )->( VV9_STATUS ) $ "CD" // Canceladas
					ni := 8
				EndIf

				If ni > 0
					If nComboM == 1 // Por Valor
						nTot1 := ( cQAlVV09 )->( VV0_VALMOV ) + ( cQAlVV09 )->( VV0_ACESSO ) + ( cQAlVV09 )->( VV0_AGREGA ) // Vlr Movto + Acessorios + Agregados
						If nTot1 == 0
							nTot1 := (0.0000001)
						EndIf
					Else // Por Qtde.
						nTot1 := 1
					EndIf

					aMod[nPos,5] += nTot1
					nTot5 += nTot1
					aMod[nPos,ni] += nTot1
					&("nTot"+strzero(ni,1)) += nTot1
				EndIf
			EndIf

			( cQAlVV09 )->( dbCloseArea() )
		Next

		If len(aMod) > 0
			Aadd(aMod, { space(6) + "***  " + STR0038 + "  ***",;
						 nTot2,;
						 nTot3,;
						 nTot4,;
						 nTot5,;
						 nTot6,;
						 nTot7,;
						 nTot8,;
						 "";
					   }) // T O T A L   G E R A L

			aSort(aMod, 1,, {|x , y| x[9] + x[1] < y[9] + y[1] })
		Else
			Aadd(aMod, { "",;
						  0,;
						  0,;
						  0,;
						  0,;
						  0,;
						  0,;
						  0,;
						  "";
					   })
		EndIf

		// Configura os tamanhos dos objetos
		aObjects := {}
		AAdd( aObjects, { 000, 020 , .T. , .F. } ) //cabecalho
		AAdd( aObjects, { 000, 000 , .T. , .T. } ) //listbox
		AAdd( aObjects, { 000, 022 , .T. , .F. } ) //rodape
		
		aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
		aPos  := MsObjSize (aInfo, aObjects,.F.)
		
		DEFINE MSDIALOG oMod FROM aSizeAut[7], 0 TO aSizeAut[6], aSizeAut[5] TITLE (cTitulo + " (" + STR0006 + ")" + cEmpr) OF oMainWnd ;
			PIXEL STYLE DS_MODALFRAME STATUS // Valor em Milhar

		oMod:lEscClose := .F.

		// Vari·veis (Valor/Qtde.)
		nDivCol := Iif(cComboM==STR0004, 1000, 1)
		cMasCol := Iif(cComboM==STR0004, "@E 99,999,999.99", "@E 99,999,999")
		cDirCol := Iif(cComboM==STR0004, "RIGHT", "LEFT")
		// Fim Vari·veis (Valor/Qtde.)

		// CabeÁalho
		// Analise
		@ aPos[1,1], aPos[1,2] TO aPos[1,3], aPos[1,4] - 55 LABEL (" " + STR0008 + " ") OF oMod PIXEL // Filtro

		@ aPos[1,1] + 007, aPos[1,2] + 004 SAY STR0031 SIZE 30,08 OF oMod PIXEL COLOR CLR_BLUE // Analise por:

		@ aPos[1,1] + 006, aPos[1,2] + 034 MSCOMBOBOX oModCombo VAR cComboM ITEMS aCombo ;
			VALID( nComboM:=IIf(cComboM==STR0004, 1, 2), lDClik:=.t., nAtVet:=oLbGrp:nAt, oMod:End() ) ;
			SIZE 35,08 OF oMod PIXEL COLOR CLR_BLUE // Analise por: "1-Valor / 2-Qtde."
		// Fim Analise

		// Periodo e Cliente
		@ aPos[1,1] + 007, aPos[1,2] + 072 SAY cFiltro SIZE 380,08 OF oMod PIXEL COLOR CLR_BLUE
		// Fim Periodo e Cliente

		// Botıes
		@ aPos[1,1] + 006, aPos[1,4] - 48 BUTTON oLegM PROMPT UPPER(STR0088) OF oMod SIZE 45,10 PIXEL ACTION VEIVC80LEG("M") // Legenda
		// Fim Botıes
		// Fim CabeÁalho

		// Destruir o objeto
		oLbMod := Nil
		// Fim Destruir o objeto

		// Criar novamente o objeto ListBox (Modelo)
		oLbMod := TWBrowse():New(aPos[2,1] + 002, aPos[2,2] + 001, (aPos[2,4] - aPos[2,2]), (aPos[2,3] - aPos[2,1]),,,,oMod,,,,,                                       ;
			{ || nComboA:=nComboM,cComboA:=cComboM, FS_ANALIT("A", oLbMod:nAt) },,,,,,,.F.,,.T.,,.F.,,,)

		oLbMod:addColumn( TCColumn():New( STR0025, { || aMod[oLbMod:nAt,9] + " " + IIf(left(Alltrim(aMod[oLbMod:nAt,1]), 3)=="***", Alltrim(aMod[oLbMod:nAt,1])       ,;
			Alltrim(left(aMod[oLbMod:nAt,1], 30)) + " " + Alltrim(substr(aMod[oLbMod:nAt,1], 31))) },;
			,,,"LEFT" ,100,.F.,.F.,,,,.F.,) ) // Modelo

		oLbMod:addColumn( TCColumn():New( STR0024, { || Transform(aMod[oLbMod:nAt,2], "@E 9,999,999") }                                                               ,;
			,,,"LEFT" , 28,.F.,.F.,,,,.F.,) ) // Pedidos

		oLbMod:addColumn( TCColumn():New( STR0055, { || Transform(aMod[oLbMod:nAt,3], "@E 9,999,999") }                                                               ,;
			,,,"LEFT" , 63,.F.,.F.,,,,.F.,) ) // Tr‚nsito / Progresso

		oLbMod:addColumn( TCColumn():New( STR0026, { || Transform(aMod[oLbMod:nAt,4], "@E 9,999,999") }                                                               ,;
			,,,"LEFT" , 28,.F.,.F.,,,,.F.,) ) // Estoque


		cTitCol := Iif(cComboM==STR0004,STR0041,STR0065)
		oLbMod:addColumn( TCColumn():New( cTitCol, { || Transform(aMod[oLbMod:nAt,5] / nDivCol, cMasCol) }                                                            ,;
			,,,cDirCol, 64,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) Total do Modelo

		oLbMod:addColumn( TCColumn():New( "% (1)", { || Transform((aMod[oLbMod:nAt,5] / aMod[1,5]) * 100, "@E 9999") + "%" }                                          ,;
			,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % Total de RepresentaÁ„o no Modelo (STR0057)


		cTitCol := Iif(cComboM==STR0004, STR0028, STR0066)
		oLbMod:addColumn( TCColumn():New( cTitCol, { || IIf(aMod[oLbMod:nAt,6] > 0, Transform(aMod[oLbMod:nAt,6] / nDivCol, cMasCol), "") }                           ,;
			,,,cDirCol, 80,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos Finalizados

		oLbMod:addColumn( TCColumn():New( "% (2)", { || IIf(aMod[oLbMod:nAt,6] > 0, Transform((aMod[oLbMod:nAt,6] / aMod[oLbMod:nAt,5]) * 100, "@E 9999") + "%", "") },;
			,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. Finalizados no Modelo (STR0059)


		cTitCol := Iif(cComboM==STR0004, STR0029, STR0067)
		oLbMod:addColumn( TCColumn():New( cTitCol, { || IIf(aMod[oLbMod:nAt,7] > 0, Transform(aMod[oLbMod:nAt,7] / nDivCol, cMasCol), "") }                           ,;
			,,,cDirCol, 92,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos N„o Finalizados

		oLbMod:addColumn( TCColumn():New( "% (3)", { || IIf(aMod[oLbMod:nAt,7] > 0, Transform((aMod[oLbMod:nAt,7] / aMod[oLbMod:nAt,5]) * 100, "@E 9999") + "%", "") },;
			,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. N„o Finalizados no Modelo (STR0061)


		cTitCol := Iif(cComboM==STR0004, STR0030, STR0068)
		oLbMod:addColumn( TCColumn():New( cTitCol, { || IIf(aMod[oLbMod:nAt,8] > 0, Transform(aMod[oLbMod:nAt,8] / nDivCol, cMasCol), "") }                           ,;
			,,,cDirCol, 82,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos Cancelados

		oLbMod:addColumn( TCColumn():New( "% (4)", { || IIf(aMod[oLbMod:nAt,8] > 0, Transform((aMod[oLbMod:nAt,8] / aMod[oLbMod:nAt,5]) * 100, "@E 9999") + "%", "") },;
			,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. Cancelados no Modelo (STR0063)

		oLbMod:nAT := 1
		oLbMod:SetArray(aMod)
		oLbMod:SetFocus()
		oLbMod:Refresh()
		// Fim Criar novamente o objeto ListBox (Modelo)

		// RodapÈ
		// Divide a janela em trÍs colunas
		nTam := ( (aPos[1,4] - 81 - 102) / 5 )

		@ aPos[3,1] + 001, 002 SAY oDiaHrM VAR cDiaHrM SIZE 80,08 OF oMod PIXEL COLOR CLR_RED

		@ aPos[3,1] + 009, 002 BUTTON oModAtual PROMPT STR0032 OF oMod ;
			SIZE 71,10 PIXEL ACTION (Processa( {|| FS_GRPMOD(3) } ), oDiaHrM:Refresh(), lDClik:=.t., nAtVet:=oLbGrp:nAt, oMod:End()) // <<<     ATUALIZAR     >>>

		// Botıes An·lise Gr·fica (Gr·ficos)
		@ aPos[3,1] + 000, 077 + (nTam * 0) TO aPos[3,3], 077 + (nTam * 5) LABEL (" " + STR0018 + " ") OF oMod PIXEL // Analise Gr·fica

		@ aPos[3,1] + 009, 077 + (nTam * 0) + ((((nTam * 1) - (nTam * 0)) - 43) / 2) BUTTON oModGra1 PROMPT STR0042 OF oMod ;
			SIZE 45,10 PIXEL ACTION FS_GRAFICO("1", aMod, oLbMod:nAt, 30, STR0025, cComboM) // Linha do Modelo // Modelo

		@ aPos[3,1] + 009, 077 + (nTam * 1) + ((((nTam * 2) - (nTam * 1)) - 43) / 2) BUTTON oModGra2 PROMPT STR0069 OF oMod ;
			SIZE 45,10 PIXEL ACTION FS_GRAFICO("2", aMod, 6, 30, STR0043, cComboM) // Finalizados / Modelos

		@ aPos[3,1] + 009, 077 + (nTam * 2) + ((((nTam * 3) - (nTam * 2)) - 43) / 2) BUTTON oModGra3 PROMPT STR0070 OF oMod ;
			SIZE 45,10 PIXEL ACTION FS_GRAFICO("2", aMod, 7, 30, STR0043, cComboM) // N„o Finalizados / Modelos

		@ aPos[3,1] + 009, 077 + (nTam * 3) + ((((nTam * 4) - (nTam * 3)) - 43) / 2) BUTTON oModGra4 PROMPT STR0071 OF oMod ;
			SIZE 45,10 PIXEL ACTION FS_GRAFICO("2", aMod, 8, 30, STR0043, cComboM) // Cancelados / Modelos

		@ aPos[3,1] + 009, 077 + (nTam * 4) + ((((nTam * 5) - (nTam * 4)) - 43) / 2) BUTTON oModGra5 PROMPT STR0035 OF oMod ;
			SIZE 45,10 PIXEL ACTION FS_GRAFICO("3", aMod, 1, 10, UPPER(STR0043), cComboM) // Total / Modelos
		// Fim Botıes An·lise Gr·fica (Gr·ficos)

		// Botıes
		@ aPos[3,1] + 000, aPos[1,4] - 102 TO aPos[3,3], aPos[1,4] - 52 LABEL (" " + STR0019 + " ") OF oMod PIXEL // Ranking

		@ aPos[3,1] + 009, aPos[1,4] - 100 BUTTON oRanking PROMPT STR0021 OF oMod ;
			SIZE 45,10 PIXEL ACTION FS_RANKING(aMod[oLbMod:nAt,9],, aMod[oLbMod:nAt,1], nComboM, cComboM) // Vendedor

		@ aPos[3,1] + 009, aPos[1,4] - 48 BUTTON oModVolta PROMPT STR0044 OF oMod SIZE 45,10 PIXEL ACTION oMod:End() // <<< VOLTAR >>>
		// Fim Botıes
		// Fim RodapÈ

		ACTIVATE MSDIALOG oMod
		
		If lDClik
			FS_ANALIT("M", nAtVet)
		EndIf
	EndIf
ElseIf cx == "A" // Atendimento
	If left(Alltrim(aMod[nx,1]), 3) # "***" .and. !Empty(aMod[nx,1])
		cTitulo := aMod[nx,9] + " " + Alltrim(left(aMod[nx,1], 30)) + " " + Alltrim(substr(aMod[nx,1], 31))
		cDtAux  := Transform(dDataBase, "@D")
		cDiaHrA := STR0039 +" " + left(cDtAux, 6) + right(cDtAux, 2) + " " + left(time(), 5) + STR0040 // PosiÁ„o de / hs
		aAte := {}

		For nNVei := 1 to len(aNVei)
			cFilAnt := aNVei[nNVei,2]

			// Posiciona no VV9/VV0 com NRO.ATENDIMENTO
			cQuery := FS_ABRESQL("VV09_2", aNVei[nNVei,1], aMod[nx,9],, left(aMod[nx,1], 30),)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )

			If !Empty( ( cQAlVV09 )->( VVA_GRUMOD ) + ( cQAlVV09 )->( VVA_MODVEI ) )
				nPos := aScan(aAte, {|x| x[6] + x[1] == aNVei[nNVei,2] + ( cQAlVV09 )->( VV9_NUMATE ) })
				If nPos == 0
					If !Empty( ( cQAlVV09 )->( VV9_CODCLI) + ( cQAlVV09 )->( VV9_LOJA ) )
						// Posiciona no SA1 para mostrar A1_NOME
						cQuery := FS_ABRESQL("SA1", ( cQAlVV09 )->( VV9_CODCLI ), ( cQAlVV09 )->( VV9_LOJA ),,,)
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA1, .F., .T. )

						Aadd(aAte, { ( cQAlVV09 )->( VV9_NUMATE ) + " - " + Transform(stod(( cQAlVV09 )->( VV9_DATVIS )), "@D") + " - " + left(( cQAlSA1 )->( A1_NOME ), 25),;
									 0,;
									 0,;
									 0,;
									 0,;
									 aNVei[nNVei,2];
								   })

						( cQAlSA1 )->( dbCloseArea() )
					Else
						Aadd(aAte, { ( cQAlVV09 )->( VV9_NUMATE ) + " - " + Transform(stod(( cQAlVV09 )->( VV9_DATVIS )), "@D") + " - " + left(( cQAlVV09 )->( VV9_NOMVIS ), 25),;
									 0,;
									 0,;
									 0,;
									 0,;
									 aNVei[nNVei,2];
								   })
					EndIf

					nPos := len(aAte)
				EndIf

				ni := 0
				If ( cQAlVV09 )->( VV9_STATUS ) $ "FT" // Finalizados
					ni := 3
				ElseIf ( cQAlVV09 )->( VV9_STATUS ) $ "ORLAP" // N„o Finalizados
					ni := 4
				ElseIf ( cQAlVV09 )->( VV9_STATUS ) $ "CD" // Canceladas
					ni := 5
				EndIf

				If ni > 0
					If nComboA == 1 // Por Valor
						nTot1 := ( cQAlVV09 )->( VV0_VALMOV ) + ( cQAlVV09 )->( VV0_ACESSO ) + ( cQAlVV09 )->( VV0_AGREGA ) // Vlr Movto + Acessorios + Agregados
						If nTot1 == 0
							nTot1 := (0.0000001)
						EndIf
					Else // Por Qtde.
						nTot1 := 1
					EndIf

					aAte[nPos,2] += nTot1
					nTot2 += nTot1
					aAte[nPos,ni] += nTot1
					&("nTot"+strzero(ni,1)) += nTot1
				EndIf
			EndIf

			( cQAlVV09 )->( dbCloseArea() )
		Next

		If len(aAte) > 0
			Aadd(aAte, { space(6) + "***  " + STR0038 + "  ***",;
						 nTot2,;
						 nTot3,;
						 nTot4,;
						 nTot5,;
						 "";
					   }) // T O T A L   G E R A L

			aSort(aAte, 1,, {|x , y| x[6] + x[1] < y[6] + y[1] })
		Else
			Aadd(aAte, { "",;
						  0,;
						  0,;
						  0,;
						  0,;
						  "";
					   })
		EndIf
		
		// Configura os tamanhos dos objetos
		aObjects := {}
		AAdd( aObjects, { 000, 020 , .T. , .F. } ) //cabecalho
		AAdd( aObjects, { 000, 000 , .T. , .T. } ) //listbox
		AAdd( aObjects, { 000, 022 , .T. , .F. } ) //rodape
		
		aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
		aPos  := MsObjSize (aInfo, aObjects,.F.)
		
		DEFINE MSDIALOG oAte FROM aSizeAut[7], 0 TO aSizeAut[6], aSizeAut[5] TITLE (cTitulo + cEmpr) OF oMainWnd ;
			PIXEL STYLE DS_MODALFRAME STATUS

		oAte:lEscClose := .F.

		// Vari·veis (Valor/Qtde.)
		nDivCol := Iif(cComboA==STR0004, 1000, 1)
		cMasCol := Iif(cComboA==STR0004, "@E 99,999,999.99", "@E 99,999,999")
		cDirCol := Iif(cComboA==STR0004, "RIGHT", "LEFT")
		// Fim Vari·veis (Valor/Qtde.)

		// CabeÁalho
		// Analise
		@ aPos[1,1], aPos[1,2] TO aPos[1,3], aPos[1,4] - 55 LABEL (" " + STR0008 + " ") OF oAte PIXEL // Filtro

		@ aPos[1,1] + 007, aPos[1,2] + 004 SAY STR0031 SIZE 30,08 OF oAte PIXEL COLOR CLR_BLUE // Analise por:

		@ aPos[1,1] + 006, aPos[1,2] + 034 MSCOMBOBOX oModCombo VAR cComboA ITEMS aCombo ;
			VALID( nComboA:=IIf(cComboA==STR0004, 1, 2), lDClik:=.t., nAtVet:=oLbMod:nAt, oAte:End()) ;
			SIZE 35,08 OF oAte PIXEL COLOR CLR_BLUE // Analise por: "1-Valor / 2-Qtde."
		// Fim Analise

		// Periodo e Cliente
		@ aPos[1,1] + 007, aPos[1,2] + 072 SAY cFiltro SIZE 380,08 OF oAte PIXEL COLOR CLR_BLUE
		// Fim Periodo e Cliente

		// Botıes
		@ aPos[1,1] + 006, aPos[1,4] - 48 BUTTON oLegA PROMPT UPPER(STR0088) OF oAte SIZE 45,10 PIXEL ACTION VEIVC80LEG("A") // Legenda
		// Fim Botıes
		// Fim CabeÁalho

		// Destruir o objeto
		oLbAte := Nil
		// Fim Destruir o objeto

		// Criar novamente o objeto ListBox (Atendimento)
		oLbAte := TWBrowse():New(aPos[2,1] + 002, aPos[2,2] + 001, (aPos[2,4] - aPos[2,2]), (aPos[2,3] - aPos[2,1]),,,,oAte,,,,,                                       ;
			{ || FS_ANALIT("X" + left(aAte[oLbAte:nAt,1], 10),, aAte[oLbAte:nAt,6]) },,,,,,,.F.,,.T.,,.F.,,,)

		oLbAte:addColumn( TCColumn():New( STR0045, { || aAte[oLbAte:nAt,6] + " " + Alltrim(aAte[oLbAte:nAt,1]) }                                                      ,;
			,,,"LEFT" ,246,.F.,.F.,,,,.F.,) ) // Atendimento


		cTitCol := Iif(cComboA==STR0004, STR0076, STR0077)
		oLbAte:addColumn( TCColumn():New( cTitCol, { || Transform(aAte[oLbAte:nAt,2] / nDivCol, cMasCol) }                                                            ,;
			,,,cDirCol, 37,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) Total

		oLbAte:addColumn( TCColumn():New( "% (1)", { || Transform((aAte[oLbAte:nAt,2] / aAte[1,2]) * 100, "@E 9999") + "%" }                                          ,;
			,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % Total de RepresentaÁ„o (STR0072)


		cTitCol := Iif(cComboA==STR0004, STR0028, STR0066)
		oLbAte:addColumn( TCColumn():New( cTitCol, { || IIf(aAte[oLbAte:nAt,3] > 0, Transform(aAte[oLbAte:nAt,3] / nDivCol, cMasCol), "") }                           ,;
			,,,cDirCol, 80,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos Finalizados

		oLbAte:addColumn( TCColumn():New( "% (2)", { || IIf(aAte[oLbAte:nAt,3] > 0, Transform((aAte[oLbAte:nAt,3] / aAte[oLbAte:nAt,2]) * 100, "@E 9999") + "%", "") },;
			,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. Finalizados (STR0073)


		cTitCol := Iif(cComboA==STR0004, STR0029, STR0067)
		oLbAte:addColumn( TCColumn():New( cTitCol, { || IIf(aAte[oLbAte:nAt,4] > 0, Transform(aAte[oLbAte:nAt,4] / nDivCol, cMasCol), "") }                           ,;
			,,,cDirCol, 92,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos N„o Finalizados

		oLbAte:addColumn( TCColumn():New( "% (3)", { || IIf(aAte[oLbAte:nAt,4] > 0, Transform((aAte[oLbAte:nAt,4] / aAte[oLbAte:nAt,2]) * 100, "@E 9999") + "%", "") },;
			,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. N„o Finalizados (STR0074)


		cTitCol := Iif(cComboA==STR0004, STR0030, STR0068)
		oLbAte:addColumn( TCColumn():New( cTitCol, { || IIf(aAte[oLbAte:nAt,5] > 0, Transform(aAte[oLbAte:nAt,5] / nDivCol, cMasCol), "") }                           ,;
			,,,cDirCol, 82,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos Cancelados

		oLbAte:addColumn( TCColumn():New( "% (4)", { || IIf(aAte[oLbAte:nAt,5] > 0, Transform((aAte[oLbAte:nAt,5] / aAte[oLbAte:nAt,2]) * 100, "@E 9999") + "%", "") },;
			,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. Cancelados (STR0075)

		oLbAte:nAT := 1
		oLbAte:SetArray(aAte)
		oLbAte:SetFocus()
		oLbAte:Refresh()
		// Fim Criar novamente o objeto ListBox (Atendimento)

		// RodapÈ
		@ aPos[3,1] + 008, aPos[3,2] + 005 SAY cDiaHrA SIZE 80,08 OF oAte PIXEL COLOR CLR_RED

		// Botıes
		@ aPos[3,1] + 007, aPos[3,4] - 050 BUTTON oAteVolta PROMPT STR0044 OF oAte SIZE 45,10 PIXEL ACTION oAte:End() // <<< VOLTAR >>>
		// Fim Botıes
		// Fim RodapÈ

		ACTIVATE MSDIALOG oAte
		If lDClik
			FS_ANALIT("A", nAtVet)
		EndIf
	EndIf
ElseIf left(cx, 1) == "X" // Visualiza Atendimento
	If left(cx, 4) # "X***"
		DbSelectArea("VV9")

		cFilAnt := cEmpF

		DbSelectArea("VV9")
		DbSetOrder(1)

		If DbSeek( xFilial("VV9") + substr(cx, 2, 10) )
			If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
				VEIXX002(NIL, NIL, NIL, 2,)
			EndIf
		EndIf
	EndIf
EndIf

cFilAnt := cFilSALVA
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_GRAFICO≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 11/06/07 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Monta GRAFICOS                                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_GRAFICO(cTp, aVet, nx, nt, cTit, cAna)
Local aGrafico := {}
Local cTitGraf := ""
Local nGraf    := 4
Local ni       := 0
Local nDivGra  := 1000
Local aLegen   := { {STR0069,.t.}, {STR0070,.t.}, {STR0071,.t.} }
Default nt     := 6
Default cTit   := ""
Default cAna   := ""

nDivGra := IIf(cAna==STR0004, 1000, 1)

If cTp == "1"
	nGraf := 10

	cTitGraf := IIf(!Empty(cTit), cTit + " ", "") + aVet[nx,9] + Alltrim(left(aVet[nx,1], nt)) + " " + Alltrim(substr(aVet[nx,1], nt + 1))

	Aadd(aGrafico, { int((aVet[nx,6] / nDivGra) + (0.49)), STR0069 + Transform((aVet[nx,6] / nDivGra), "@E 999,999,999") +;
		Transform((aVet[nx,6] / aVet[nx,5]) * 100, "@E 9999") + "%", CLR_GREEN })  // (Valor/Quantidade) Finalizados

	Aadd(aGrafico, { int((aVet[nx,7] / nDivGra) + (0.49)), STR0070 + Transform((aVet[nx,7] / nDivGra), "@E 999,999,999") +;
		Transform((aVet[nx,7] / aVet[nx,5]) * 100, "@E 9999") + "%", CLR_YELLOW }) // (Valor/Quantidade) N„o Finalizados

	Aadd(aGrafico, { int((aVet[nx,8] / nDivGra) + (0.49)), STR0071 + Transform((aVet[nx,8] / nDivGra), "@E 999,999,999") +;
		Transform((aVet[nx,8] / aVet[nx,5]) * 100, "@E 9999") + "%", CLR_RED })    // (Valor/Quantidade) Cancelados
ElseIf cTp == "2"
	If nx == 6
		cTitGraf := IIf(!Empty(cTit), cTit + " ", "") + STR0069 // Finalizados

		aLegen := { {STR0069,.t.} }
	ElseIf nx == 7
		cTitGraf := IIf(!Empty(cTit), cTit + " ", "") + STR0070 // N„o Finalizados

		aLegen := { {STR0070,.t.} }
	ElseIf nx == 8
		cTitGraf := IIf(!Empty(cTit), cTit + " ", "") + STR0071 // Cancelados

		aLegen := { {STR0071,.t.} }
	EndIf

	For ni := 1 to len(aVet)
		If left(Alltrim(aVet[ni,1]), 3) # "***"
			Aadd(aGrafico, { int((aVet[ni,nx] / nDivGra) + (0.49)), Alltrim(aVet[ni,5]) + "-" + Alltrim(left(aVet[ni,1], nt)), }) // (Valor/Quantidade)
		EndIf
	Next
ElseIf cTp == "3"
	cTitGraf := IIf(!Empty(cTit), cTit + " ", "") + STR0035 // Total

	For ni := 1 to len(aVet)
		If left(Alltrim(aVet[ni,1]), 3) # "***"
			Aadd(aGrafico, { int((aVet[ni,6] / nDivGra) + (0.49)), Alltrim(aVet[ni,5]) + "-" + Alltrim(left(aVet[ni,1], nt)), }) // (Valor/Quantidade)

			Aadd(aGrafico, { int((aVet[ni,7] / nDivGra) + (0.49)), Alltrim(aVet[ni,5]) + "-" + Alltrim(left(aVet[ni,1], nt)), }) // (Valor/Quantidade)

			Aadd(aGrafico, { int((aVet[ni,8] / nDivGra) + (0.49)), Alltrim(aVet[ni,5]) + "-" + Alltrim(left(aVet[ni,1], nt)), }) // (Valor/Quantidade)
		EndIf
	Next
EndIf

cTitGraf += IIf(cAna==STR0004, " (" + STR0006 + ")", " (" + STR0005 + ")") + cEmpr // Valor / Valor em Milhar / Qtde.

FG_GRAFICO(, cTitGraf,,,,, aGrafico, nGraf,, aLegen)
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_RANKING≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 11/06/07 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Ranking dos Vendedores                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_RANKING(cRMar, cRGrp, cRMod, nComboR, cComboR)
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.F.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0
Local nTam := 0
////////////////////////////////////////////////////////////////////////////////////////////
Local lDClik := .f.
Local nNVei  := 0
Local nPos   := 0
Local ni     := 0
Local aRankT := {}
Local aRankF := {}
Local aRankN := {}
Local aRankC := {}
Local cRTit  := ""
Local cFilSALVA := cFilAnt
Local cQAlVV09  := "SQLVV09"
Local cQAlSA3   := "SQLSA3"
Local cTitCol := ""
Local nDivCol := 1000
Local cMasCol := ""
Local cDirCol := ""
Local cDtAux  := ""

Default cRMar := ""
Default cRGrp := ""
Default cRMod := ""
Default nComboR := nComboG
Default cComboR := cComboG

nTot1 := 0

If !Empty(cRGrp+cRMod)
	FS_ATEND()

	cRTit := cRMar + " " + IIf(!Empty(cRGrp), Alltrim(left(cRGrp, 6)) + " " + Alltrim(substr(cRGrp, 7)), Alltrim(left(cRMod, 30) ) + " " + Alltrim(substr(cRMod, 31)))

	If left(Alltrim(cRMod),3) == "***"
		cRGrp := aGrp[oLbGrp:nAt,1]
		cRTit := Alltrim(left(aGrp[oLbGrp:nAt,1], 6)) + " " + Alltrim(substr(aGrp[oLbGrp:nAt,1], 7))
	EndIf

	Aadd(aRankT, { 0, UPPER(STR0046), 0 }) // TOTAL ATENDIMENTOS
	Aadd(aRankF, { 0, UPPER(STR0047), 0, 0 }) // TOTAL FINALIZADOS
	Aadd(aRankN, { 0, UPPER(STR0048), 0, 0 }) // TOTAL NAO FINALIZADOS
	Aadd(aRankC, { 0, UPPER(STR0049), 0, 0 }) // TOTAL CANCELADOS

	For nNVei := 1 to len(aNVei)
		cFilAnt := aNVei[nNVei,2]

		If Empty(cRGrp) .or. left(Alltrim(cRGrp), 3)=="***"
			If Empty(cRMod) .or. left(Alltrim(cRMod), 3)=="***"
				cQuery := FS_ABRESQL("VV09_2", aNVei[nNVei,1], cRMar,,, "T")
			Else
				cQuery := FS_ABRESQL("VV09_2", aNVei[nNVei,1], cRMar,, left(cRMod, 30), "T")
			EndIf
		Else
			If Empty(cRMod) .or. left(Alltrim(cRMod), 3)=="***"
				cQuery := FS_ABRESQL("VV09_2", aNVei[nNVei,1], cRMar, left(cRGrp, 6),, "T")
			Else
				cQuery := FS_ABRESQL("VV09_2", aNVei[nNVei,1], cRMar, left(cRGrp, 6), left(cRMod, 30), "T")
			EndIf
		EndIf

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
		If !Empty( ( cQAlVV09 )->( VV0_CODVEN ) )
			nPos := aScan(aRankT, {|x| left(x[2], len(aNVei[nNVei,2] + " " + ( cQAlVV09 )->( VV0_CODVEN ))) == aNVei[nNVei,2] + " " + ( cQAlVV09 )->( VV0_CODVEN ) })
			If nPos == 0
				cQuery := FS_ABRESQL("SA3", ( cQAlVV09 )->( VV0_CODVEN ),,,,)
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA3, .F., .T. )

				Aadd(aRankT,{ 1, aNVei[nNVei,2] + " " + ( cQAlVV09 )->( VV0_CODVEN ) + " - " + ( cQAlSA3 )->( A3_NOME ), 0 })
				Aadd(aRankF,{ 1, aNVei[nNVei,2] + " " + ( cQAlVV09 )->( VV0_CODVEN ) + " - " + ( cQAlSA3 )->( A3_NOME ), 0, 0 })
				Aadd(aRankN,{ 1, aNVei[nNVei,2] + " " + ( cQAlVV09 )->( VV0_CODVEN ) + " - " + ( cQAlSA3 )->( A3_NOME ), 0, 0 })
				Aadd(aRankC,{ 1, aNVei[nNVei,2] + " " + ( cQAlVV09 )->( VV0_CODVEN ) + " - " + ( cQAlSA3 )->( A3_NOME ), 0, 0 })

				( cQAlSA3 )->( dbCloseArea() )

				nPos := len(aRankT)
			EndIf

			nTot1 := 0

			If nComboR == 1 // Por Valor
				nTot1 := ( cQAlVV09 )->( VV0_VALMOV ) + ( cQAlVV09 )->( VV0_ACESSO ) + ( cQAlVV09 )->( VV0_AGREGA ) // Vlr Movto + Acessorios + Agregados
				If nTot1 == 0
					nTot1 := (0.0000001)
				EndIf
			Else // Por Qtde.
				nTot1 := 1
			EndIf

			If nTot1 > 0
				aRankT[1,3]    += nTot1
				aRankT[nPos,3] += nTot1
				If ( cQAlVV09 )->( VV9_STATUS ) $ "FT" // Finalizados
					aRankF[1,3]    += nTot1
					aRankF[nPos,3] += nTot1
				ElseIf ( cQAlVV09 )->( VV9_STATUS ) $ "ORLAP" // N„o Finalizados
					aRankN[1,3]    += nTot1
					aRankN[nPos,3] += nTot1
				ElseIf ( cQAlVV09 )->( VV9_STATUS ) $ "CD" // Canceladas
					aRankC[1,3]    += nTot1
					aRankC[nPos,3] += nTot1
				EndIf
			EndIf
		EndIf

		( cQAlVV09 )->( dbCloseArea() )
	Next

	For ni := 1 to len(aRankT)
		aRankF[ni,4] := aRankT[ni,3]
		aRankN[ni,4] := aRankT[ni,3]
		aRankC[ni,4] := aRankT[ni,3]
	Next

	aSort(aRankT, 1,, { |x,y| (1000000000 - x[1]) + x[3] > (1000000000 - y[1]) + y[3] })
	aSort(aRankF, 1,, { |x,y| (1000000000 - x[1]) + x[3] > (1000000000 - y[1]) + y[3] })
	aSort(aRankN, 1,, { |x,y| (1000000000 - x[1]) + x[3] > (1000000000 - y[1]) + y[3] })
	aSort(aRankC, 1,, { |x,y| (1000000000 - x[1]) + x[3] > (1000000000 - y[1]) + y[3] })

	// Rank Total
	nPos := 1
	For ni := 1 to len(aRankT)
		If aRankT[ni,1] == 1
			aRankT[ni,1] := nPos++
		EndIf
	Next

	// Rank Finalizados
	nPos := 1
	For ni := 1 to len(aRankF)
		If aRankF[ni,1] == 1
			aRankF[ni,1] := nPos++
		EndIf
	Next

	// Rank N„o Finalizados
	nPos := 1
	For ni := 1 to len(aRankN)
		If aRankN[ni,1] == 1
			aRankN[ni,1] := nPos++
		EndIf
	Next

	// Rank Cancelados
	nPos := 1
	For ni := 1 to len(aRankC)
		If aRankC[ni,1] == 1
			aRankC[ni,1] := nPos++
		EndIf
	Next
	
	// Configura os tamanhos dos objetos
	aObjects := {}

	AAdd( aObjects, { 000, 020 , .T. , .F. } ) //cabecalho
	AAdd( aObjects, { 000, 000 , .T. , .T. } ) //listbox 1
	AAdd( aObjects, { 000, 000 , .T. , .T. } ) //listbox 2
	AAdd( aObjects, { 000, 000 , .T. , .T. } ) //listbox 3
	AAdd( aObjects, { 000, 000 , .T. , .T. } ) //listbox 4
	AAdd( aObjects, { 000, 022 , .T. , .F. } ) //rodape
	
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosR := MsObjSize (aInfo, aObjects,.F.)
	
	DEFINE MSDIALOG oRank FROM aSizeAut[7], 0 TO aSizeAut[6], aSizeAut[5] TITLE (cRTit+cEmpr) OF oMainWnd ;
		PIXEL STYLE DS_MODALFRAME STATUS
	
	oRank:lEscClose := .F.

	// Vari·veis (Valor/Qtde.)
	nDivCol := Iif(cComboR==STR0004, 1000, 1)
	cMasCol := Iif(cComboR==STR0004, "@E 99,999,999.99", "@E 99,999,999")
	cDirCol := Iif(cComboR==STR0004, "RIGHT", "LEFT")
	cDtAux  := Transform(dDataBase, "@D")
	// Fim Vari·veis (Valor/Qtde.)

	// CabeÁalho
	// Analise
	@ aPosR[1,1], aPosR[1,2] TO aPosR[1,3], aPosR[1,4] LABEL (" " + STR0008 + " ") OF oRank PIXEL // Filtro

	@ aPosR[1,1] + 007, aPosR[1,2] + 004 SAY STR0031 SIZE 30,08 OF oRank PIXEL COLOR CLR_BLUE // Analise por:

	@ aPosR[1,1] + 006, aPosR[1,2] + 034 MSCOMBOBOX oRankCombo VAR cComboR ITEMS aCombo ;
		VALID( nComboR:=IIf(cComboR==STR0004, 1, 2), lDClik:=.t., oRank:End() ) ;
		SIZE 35,07 OF oRank PIXEL COLOR CLR_BLUE // Analise por: "1-Valor / 2-Qtde."
	// Fim Analise

	// Periodo e Cliente
	@ aPosR[1,1] + 007, aPosR[1,2] + 072 SAY cFiltro SIZE 380,08 OF oRank PIXEL COLOR CLR_BLUE
	// Fim Periodo e Cliente
	// Fim CabeÁalho

	// Destruir o primeiro objeto
	oLbRankT := Nil
	// Fim Destruir o primeiro objeto

	// Criar novamente o objeto ListBox (Rank Total)
	oLbRankT := TWBrowse():New(aPosR[2,1] + 002, aPosR[2,2] + 001, (aPosR[2,4] - aPosR[2,2]), (aPosR[2,3] - aPos[2,1]),,,,oRank,,,,,;
		,,,,,,,.F.,,.T.,,.F.,,,)

	oLbRankT:addColumn( TCColumn():New( STR0022, { || IIf(aRankT[oLbRankT:nAt,1] > 0, strzero(aRankT[oLbRankT:nAt,1], 4), " ") }   ,;
		,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // Rank

	oLbRankT:addColumn( TCColumn():New( STR0021, { || aRankT[oLbRankT:nAt,2] }                                                     ,;
		,,,"LEFT" ,175,.F.,.F.,,,,.F.,) ) // Vendedor


	cTitCol := Iif(cComboR==STR0004, STR0076, STR0077)
	oLbRankT:addColumn( TCColumn():New( cTitCol, { || Transform(aRankT[oLbRankT:nAt,3] / nDivCol, cMasCol) }                       ,;
		,,,cDirCol,133,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) Total

	oLbRankT:addColumn( TCColumn():New( STR0072, { || Transform((aRankT[oLbRankT:nAt,3] / aRankT[1,3]) * 100, "@E 9999") + "%" }   ,;
		,,,"LEFT" ,  0,.F.,.F.,,,,.F.,) ) // % Total de RepresentaÁ„o

	oLbRankT:nAT := 1
	oLbRankT:SetArray(aRankT)
	oLbRankT:SetFocus()
	oLbRankT:Refresh()
	// Fim Criar novamente o objeto ListBox (Rank Total)

	// Destruir o segundo objeto
	oLbRankF := Nil
	// Fim Destruir o segundo objeto

	// Criar novamente o objeto ListBox (Rank Finalizados)
	oLbRankF := TWBrowse():New(aPosR[3,1] + 002, aPosR[3,2] + 001, (aPosR[3,4] - aPosR[3,2]), (aPosR[3,3] - aPosR[3,1]),,,,oRank,,,,,       ;
		,,,,,,,.F.,,.T.,,.F.,,,)

	oLbRankF:addColumn( TCColumn():New( STR0022, { || IIf(aRankF[oLbRankF:nAt,1] > 0, strzero(aRankF[oLbRankF:nAt,1], 4), " ") }           ,;
		,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // Rank

	oLbRankF:addColumn( TCColumn():New( STR0021, { || aRankF[oLbRankF:nAt,2] }                                                             ,;
		,,,"LEFT" ,175,.F.,.F.,,,,.F.,) ) // Vendedor


	cTitCol := Iif(cComboR==STR0004, STR0028, STR0066)
	oLbRankF:addColumn( TCColumn():New( cTitCol, { || Transform(aRankF[oLbRankF:nAt,3] / nDivCol, cMasCol) }                               ,;
		,,,cDirCol,133,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos Finalizados

	oLbRankF:addColumn( TCColumn():New( STR0073, { || Transform((aRankF[oLbRankF:nAt,3] / aRankF[1,3]) * 100, "@E 9999") + "%" }           ,;
		,,,"LEFT" ,137,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. Finalizados
	
	oLbRankF:addColumn( TCColumn():New( STR0051, { || Transform((aRankF[oLbRankF:nAt,3] / aRankF[oLbRankF:nAt,4]) * 100, "@E 9999") + "%" },;
		,,,"LEFT" ,  0,.F.,.F.,,,,.F.,) ) // % do Total de Atendimentos do Vendedor

	oLbRankF:nAT := 1
	oLbRankF:SetArray(aRankF)
	oLbRankF:SetFocus()
	oLbRankF:Refresh()
	// Fim Criar novamente o objeto ListBox (Rank Finalizados)

	// Destruir o terceiro objeto
	oLbRankN := Nil
	// Fim Destruir o terceiro objeto

	// Criar novamente o objeto ListBox (Rank N„o Finalizados)
	oLbRankN := TWBrowse():New(aPosR[4,1] + 002, aPosR[4,2] + 001, (aPosR[4,4] - aPosR[4,2]), (aPosR[4,3] - aPosR[4,1]),,,,oRank,,,,,       ;
		,,,,,,,.F.,,.T.,,.F.,,,)

	oLbRankN:addColumn( TCColumn():New( STR0022, { || IIf(aRankN[oLbRankN:nAt,1] > 0, strzero(aRankN[oLbRankN:nAt,1], 4), " ") }           ,;
		,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // Rank

	oLbRankN:addColumn( TCColumn():New( STR0021, { || aRankN[oLbRankN:nAt,2] }                                                             ,;
		,,,"LEFT" ,175,.F.,.F.,,,,.F.,) ) // Vendedor


	cTitCol := Iif(cComboR==STR0004, STR0029, STR0067)
	oLbRankN:addColumn( TCColumn():New( cTitCol, { || Transform(aRankN[oLbRankN:nAt,3] / nDivCol, cMasCol) }                               ,;
		,,,cDirCol,133,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos N„o Finalizados

	oLbRankN:addColumn( TCColumn():New( STR0074, { || Transform((aRankN[oLbRankN:nAt,3] / aRankN[1,3]) * 100, "@E 9999") + "%" }           ,;
		,,,"LEFT" ,137,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. N„o Finalizados

	oLbRankN:addColumn( TCColumn():New( STR0051, { || Transform((aRankN[oLbRankN:nAt,3] / aRankN[oLbRankN:nAt,4]) * 100, "@E 9999") + "%" },;
		,,,"LEFT" ,  0,.F.,.F.,,,,.F.,) ) // % do Total de Atendimentos do Vendedor

	oLbRankN:nAT := 1
	oLbRankN:SetArray(aRankN)
	oLbRankN:SetFocus()
	oLbRankN:Refresh()
	// Fim Criar novamente o objeto ListBox (Rank N„o Finalizados)

	// Destruir o quarto objeto
	oLbRankC := Nil
	// Fim Destruir o quarto objeto

	// Criar novamente o objeto ListBox (Rank Cancelados)
	oLbRankC := TWBrowse():New(aPosR[5,1] + 005, aPosR[5,2] + 001, (aPosR[5,4] - aPosR[5,2]), (aPosR[5,3] - aPosR[5,1]),,,,oRank,,,,,       ;
		,,,,,,,.F.,,.T.,,.F.,,,)

	oLbRankC:addColumn( TCColumn():New( STR0022, { || IIf(aRankC[oLbRankC:nAt,1] > 0, strzero(aRankC[oLbRankC:nAt,1], 4), " ") }           ,;
		,,,"LEFT" , 20,.F.,.F.,,,,.F.,) ) // Rank

	oLbRankC:addColumn( TCColumn():New( STR0021, { || aRankC[oLbRankC:nAt,2] }                                                             ,;
		,,,"LEFT" ,175,.F.,.F.,,,,.F.,) ) // Vendedor


	cTitCol := Iif(cComboR==STR0004, STR0030, STR0068)
	oLbRankC:addColumn( TCColumn():New( cTitCol, { || Transform(aRankC[oLbRankC:nAt,3] / nDivCol, cMasCol) }                               ,;
		,,,cDirCol,133,.F.,.F.,,,,.F.,) ) // (Valor/Qtde.) de Atendimentos Cancelados

	oLbRankC:addColumn( TCColumn():New( STR0075, { || Transform((aRankC[oLbRankC:nAt,3] / aRankC[1,3]) * 100, "@E 9999") + "%" }           ,;
		,,,"LEFT" ,137,.F.,.F.,,,,.F.,) ) // % de RepresentaÁ„o de Atend. Cancelados

	oLbRankC:addColumn( TCColumn():New( STR0051, { || Transform((aRankC[oLbRankC:nAt,3] / aRankC[oLbRankC:nAt,4]) * 100, "@E 9999") + "%" },;
		,,,"LEFT" ,  0,.F.,.F.,,,,.F.,) ) // % do Total de Atendimentos do Vendedor

	oLbRankC:nAT := 1
	oLbRankC:SetArray(aRankC)
	oLbRankC:SetFocus()
	oLbRankC:Refresh()
	// Fim Criar novamente o objeto ListBox (Rank Cancelados)

	// RodapÈ
	// Divide a janela em trÍs colunas
	nTam := ( aPosR[1,4] / 3 )

	@ aPosR[6,1] + 007, aPosR[6,2] + 004 SAY (STR0039 + " " + left(cDtAux, 6) + right(cDtAux, 2) + " " + left(time(), 5) + STR0040) SIZE 80,08 OF oRank PIXEL COLOR CLR_RED // PosiÁ„o de / hs

	@ aPosR[6,1] + 007, (nTam * 1) + ((((nTam * 2) - (nTam * 1)) - 150) / 2) SAY UPPER(STR0020) SIZE 150,08 OF oRank PIXEL COLOR CLR_BLACK // R A N K I N G    D E    V E N D E D O R E S

	// Botıes
	@ aPosR[6,1] + 007, aPosR[6,4] - 050 BUTTON oRankVolta PROMPT STR0044 OF oRank SIZE 45,10 PIXEL ACTION oRank:End() // <<< VOLTAR >>>
	// Fim Botıes
	// Fim RodapÈ

	ACTIVATE MSDIALOG oRank CENTER

	If lDClik
		FS_RANKING(cRMar, cRGrp, cRMod, nComboR, cComboR)
	EndIf
EndIf

cFilAnt := cFilSALVA
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_FILIAIS≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 11/06/07 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Levanta Filiais                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_FILIAIS()
Local aVetAux      := {}
Local ni           := {}
Local aFilAtu      := FWArrFilAtu()
Local aSM0         := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt   := cFilAnt
Local nCont        := 0
Local aFWArrFilAtu := {}
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]

	aFWArrFilAtu := FWArrFilAtu()

	ni := aScan(aEmpr, {|x| x[1] == cFilAnt})

	aAdd(aVetEmp, { (ni>0), cFilAnt, aFWArrFilAtu[SM0_FILIAL], FWFilialName() })
Next

cFilAnt := cBkpFilAnt

If Len(aVetEmp) > 1
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0017 PIXEL // Filiais

	@ 001, 001 LISTBOX oLbEmp FIELDS HEADER "", STR0009, STR0011 COLSIZES 10,15,50 ;
		SIZE 165,120 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL // Filial / Nome

	oLbEmp:SetArray(aVetEmp)
	oLbEmp:bLine := { || { IIf(aVetEmp[oLbEmp:nAt,1], oOk, oNo), aVetEmp[oLbEmp:nAt,3], aVetEmp[oLbEmp:nAt,4] }}

	DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp

	@ 002, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgEmp ON CLICK IIf(FS_TIK(lMarcar), .t., (lMarcar:=!lMarcar, oDlgEmp:Refresh())) ;
		SIZE 70,08 PIXEL COLOR CLR_BLUE

	ACTIVATE MSDIALOG oDlgEmp CENTER
EndIf

If len(aVetEmp) == 1
	aVetEmp[1,1] := .t.
EndIf

For ni := 1 to len(aVetEmp)
	If aVetEmp[ni,1]
		aAdd(aVetAux, { aVetEmp[ni,2], aVetEmp[ni,3]})
		cEmpr += Alltrim(aVetEmp[ni,2]) + ", "
	EndIf
Next

If len(aVetAux) > 1
	cEmpr := substr(cEmpr, 1, len(cEmpr) - 2)
EndIf
Return(aVetAux)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_TIK   ≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 11/06/07 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ TIK das Filais                                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_TIK(lMarcar)
Local ni := 0

Default lMarcar := .f.

For ni := 1 to Len(aVetEmp)
	If lMarcar
		aVetEmp[ni,1] := .t.
	Else
		aVetEmp[ni,1] := .f.
	EndIf
Next

oLbEmp:SetFocus()
oLbEmp:Refresh()
Return(.t.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_ABRESQL≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 11/06/07 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Monta cQuery para os SQLs da Consulta                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_ABRESQL(cTp, cAux1, cAux2, cAux3, cAux4, cAux5)
Local cQuery  := ""

Default cAux1 := ""
Default cAux2 := ""
Default cAux3 := ""
Default cAux4 := ""
Default cAux5 := ""

Do Case
	Case left(cTp, 4) == "VV09" // Atendimentos ( VV9 / VV0 )
		If cTp == "VV09_1"
			cQuery := "SELECT VV9.VV9_NUMATE FROM " + RetSqlName("VV9") + " VV9 "
			cQuery += "INNER JOIN " + RetSqlName("VV0") + " VV0 ON VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND "
			cQuery += "      VV0.VV0_FILIAL='" + xFilial("VV0") + "' AND VV0.D_E_L_E_T_=' ' WHERE "
			cQuery += "VV9.VV9_FILIAL='" + xFilial("VV9") + "' AND "
			cQuery += "VV9.VV9_DATVIS>='" + dtos(dDatIni) + "' AND VV9.VV9_DATVIS<='" + dtos(dDatFin) + "' AND "
			cQuery += "VV9.VV9_STATUS IN ('F','T','O','R','L','A','P','C','D') AND "

			// Cliente e Loja
			If !Empty(cCodCli + cLojCli)
				cQuery += "VV9.VV9_CODCLI='" + cCodCli + "' AND VV9.VV9_LOJA='" + cLojCli + "' AND "
			EndIf

		ElseIf cTp == "VV09_2" // Atendimentos ( VV9 / VV0 / VVA )
			cQuery := "SELECT * FROM " + RetSqlName("VV9") + " VV9 "
			cQuery += "INNER JOIN " + RetSqlName("VV0") + " VV0 ON VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND "
			cQuery += "      VV0.VV0_FILIAL='" + xFilial("VV0") + "' AND VV0.D_E_L_E_T_=' ' "
			cQuery += "INNER JOIN " + RetSqlName("VVA") + " VVA ON VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND "
			cQuery += "      VVA.VVA_FILIAL='" + xFilial("VVA") + "' AND VVA.D_E_L_E_T_=' ' WHERE "
			cQuery += "VV9.VV9_FILIAL='" + xFilial("VV9") + "' AND "
			cQuery += "VV9.VV9_NUMATE='" + cAux1 + "' AND "

			// Marca
			If !Empty(cAux2)
				cQuery += "VVA.VVA_CODMAR='" + cAux2 + "' AND "
			EndIf

			// Grupo de Modelo
			If !Empty(cAux3)
				cQuery += "VVA.VVA_GRUMOD='" + cAux3 + "' AND "
			EndIf

			// Modelo de VeÌculo
			If !Empty(cAux4)
				cQuery += "VVA.VVA_MODVEI='" + cAux4 + "' AND "
			EndIf

			// Status
			If !Empty(cAux5)
				If cAux5 # "T"
					If cAux5 == "F"
						cQuery += "VV9.VV9_STATUS IN ('F','T') AND "
					ElseIf cAux5 == "C"
						cQuery += "VV9.VV9_STATUS IN ('C','D') AND "
					ElseIf cAux5 == "N"
						cQuery += "VV9.VV9_STATUS IN ('O','R','L','A','P') AND "
					EndIf
				Else
					cQuery += "VV9.VV9_STATUS IN ('F','T','O','R','L','A','P','C','D') AND "
				EndIf
			EndIf
		EndIf

		cQuery += "VV9.D_E_L_E_T_=' '"

	Case left(cTp, 3) == "VV1" // VeÌculos
		cQuery := "SELECT COUNT(VV1.VV1_CHAINT) QTDVEI FROM " + RetSqlName("VV1") + " VV1 "
		cQuery += "INNER JOIN " + RetSqlName("VV2") + " VV2 ON VV1.VV1_CODMAR=VV2.VV2_CODMAR AND "
		cQuery += "      VV1.VV1_MODVEI=VV2.VV2_MODVEI AND VV2.VV2_FILIAL='" + xFilial("VV2") + "' AND VV2.D_E_L_E_T_=' ' WHERE "
		cQuery += "VV1.VV1_FILIAL='" + xFilial("VV1") + "' AND "

		If cTp == "VV1_1"
			cQuery += "VV1.VV1_SITVEI IN ('0','4','5','6') AND " // Estoque ( 0-Estoque / 4-Consignado / 5-Transferido / 6-Reservado )
		ElseIf cTp == "VV1_2"
			cQuery += "VV1.VV1_SITVEI = '8' AND " // Pedidos ( 8-Pedidos )
		ElseIf cTp == "VV1_3"
			cQuery += "VV1.VV1_SITVEI IN ('2','7') AND " // Tr‚nsito / Progresso ( 2-Em Transito / 7-Progresso )
		EndIf

		cQuery += "VV2.VV2_CODMAR='" + cAux1 + "' AND VV2.VV2_GRUMOD='" + cAux2 + "' AND "

		If !Empty(cAux3)
			cQuery += "VV2.VV2_MODVEI='" + cAux3 + "' AND "
		EndIf

		cQuery += "VV1.D_E_L_E_T_=' '"

	Case cTp == "VV2" // Modelos de VeÌculos
		cQuery := "SELECT VV2.VV2_DESMOD FROM " + RetSqlName("VV2") + " VV2 WHERE "
		cQuery += "VV2.VV2_FILIAL='" + xFilial("VV2") + "' AND VV2.VV2_CODMAR='" + cAux1 + "' AND "
		cQuery += "VV2.VV2_MODVEI='" + cAux2 + "' AND VV2.D_E_L_E_T_=' '"

	Case cTp == "VVR" // Grupos de Modelos
		cQuery := "SELECT VVR.VVR_DESCRI FROM " + RetSqlName("VVR") + " VVR WHERE "
		cQuery += "VVR.VVR_FILIAL='" + xFilial("VVR") + "' AND VVR.VVR_CODMAR='" + cAux1 + "' AND "
		cQuery += "VVR.VVR_GRUMOD='" + cAux2 + "' AND VVR.D_E_L_E_T_=' '"

	Case cTp == "SA1" // Cliente
		cQuery := "SELECT SA1.A1_NOME FROM " + RetSqlName("SA1") + " SA1 WHERE "
		cQuery += "SA1.A1_FILIAL='" + xFilial("SA1") + "' AND SA1.A1_COD='" + cAux1 + "' AND "
		cQuery += "SA1.A1_LOJA='" + cAux2 + "' AND SA1.D_E_L_E_T_=' '"

	Case cTp == "SA3" // Vendedor
		cQuery := "SELECT SA3.A3_NOME FROM " + RetSqlName("SA3") + " SA3 WHERE "
		cQuery += "SA3.A3_FILIAL='" + xFilial("SA3") + "' AND SA3.A3_COD='" + cAux1 + "' AND SA3.D_E_L_E_T_=' '"
EndCase
Return( cQuery )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao  ≥VEIVC80LEG≥ Autor ≥  Fernando Vitor Cavani  ≥ Data ≥ 26/02/18 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Legenda para todas as Tabelas                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function VEIVC80LEG(cTipo)
Local cPulaLinha := CHR(13) + CHR(10)

Do Case
	Case cTipo == "G"
		// Grupo Modelo
		AVISO(STR0089,                                           ; // Legenda de %
			'1 - ' + STR0056 + cPulaLinha +                      ; // % Total de RepresentaÁ„o no Grupo
			'     (' + STR0078 + ')' + cPulaLinha + cPulaLinha + ; // Deve ser considerada na vertical. Cada linha contÈm o % que somado aos demais, totalizam 100%
			'2 - ' + STR0058 + cPulaLinha +                      ; // % de RepresentaÁ„o de Atend. Finalizados no Grupo
			'     (' + STR0079 + ')' + cPulaLinha + cPulaLinha + ; // Deve ser considerada na horizontal. A linha contÈm o % de Finalizados em relaÁ„o ‡ linha do Grupo
			'3 - ' + STR0060 + cPulaLinha +                      ; // % de RepresentaÁ„o de Atend. N„o Finalizados no Grupo
			'     (' + STR0080 + ')' + cPulaLinha + cPulaLinha + ; // Deve ser considerada na horizontal. A linha contÈm o % de N„o Finalizados em relaÁ„o ‡ linha do Grupo
			'4 - ' + STR0062 + cPulaLinha +                      ; // % de RepresentaÁ„o de Atend. Cancelados no Grupo
			'     (' + STR0081 + ')' + cPulaLinha + cPulaLinha   ; // Deve ser considerada na horizontal. A linha contÈm o % de Cancelados em relaÁ„o ‡ linha do Grupo
		, { "Ok" } , 3)
	Case cTipo == "M"
		// Modelo
		AVISO(STR0089,                                           ; // Legenda de %
			'1 - ' + STR0057 + cPulaLinha +                      ; // % Total de RepresentaÁ„o no Modelo
			'     (' + STR0078 + ')' + cPulaLinha + cPulaLinha + ; // Deve ser considerada na vertical. Cada linha contÈm o % que somado aos demais, totalizam 100%
			'2 - ' + STR0059 + cPulaLinha +                      ; // % de RepresentaÁ„o de Atend. Finalizados no Modelo
			'     (' + STR0082 + ')' + cPulaLinha + cPulaLinha + ; // Deve ser considerada na horizontal. A linha contÈm o % de Finalizados em relaÁ„o ‡ linha do Modelo
			'3 - ' + STR0061 + cPulaLinha +                      ; // % de RepresentaÁ„o de Atend. N„o Finalizados no Modelo
			'     (' + STR0083 + ')' + cPulaLinha + cPulaLinha + ; // Deve ser considerada na horizontal. A linha contÈm o % de N„o Finalizados em relaÁ„o ‡ linha do Modelo
			'4 - ' + STR0063 + cPulaLinha +                      ; // % de RepresentaÁ„o de Atend. Cancelados no Modelo
			'     (' + STR0084 + ')' + cPulaLinha + cPulaLinha   ; // Deve ser considerada na horizontal. A linha contÈm o % de Cancelados em relaÁ„o ‡ linha do Modelo
		, { "Ok" } , 3)
	Case cTipo == "A"
		// Atendimento
		AVISO(STR0089,                                           ; // Legenda de %
			'1 - ' + STR0072 + cPulaLinha +                      ; // % Total de RepresentaÁ„o
			'     (' + STR0078 + ')' + cPulaLinha + cPulaLinha + ; // Deve ser considerada na vertical. Cada linha contÈm o % que somado aos demais, totalizam 100%
			'2 - ' + STR0073 + cPulaLinha +                      ; // % de RepresentaÁ„o de Atend. Finalizados
			'     (' + STR0085 + ')' + cPulaLinha + cPulaLinha + ; // Deve ser considerada na horizontal e somente a linha *** TOTAL GERAL ***. Essa linha contÈm o % de Finalizados em relaÁ„o ao % Total de RepresentaÁ„o
			'3 - ' + STR0074 + cPulaLinha +                      ; // % de RepresentaÁ„o de Atend. N„o Finalizados
			'     (' + STR0086 + ')' + cPulaLinha + cPulaLinha + ; // Deve ser considerada na horizontal e somente a linha *** TOTAL GERAL ***. Essa linha contÈm o % de N„o Finalizados em relaÁ„o ao % Total de RepresentaÁ„o
			'4 - ' + STR0075 + cPulaLinha +                      ; // % de RepresentaÁ„o de Atend. Cancelados
			'     (' + STR0087 + ')' + cPulaLinha + cPulaLinha   ; // Deve ser considerada na horizontal e somente a linha *** TOTAL GERAL ***. Essa linha contÈm o % de Cancelados em relaÁ„o ao % Total de RepresentaÁ„o
		, { "Ok" } , 3)
EndCase
Return