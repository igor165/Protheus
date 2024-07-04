#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR933  ³ Autor ³ Edstron E.C. Rosario  ³ Data ³ 20/12/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Transferencia de Precos - Metodo PRL                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Livros Fiscais                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATR933()

Local dDataIni := CTOD("//")
Local dDataFim := CTOD("//")
Local Titulo   := "Demonstrativo de Preco de Transferencia"
Local cDesc1   := "A utilizacao deste relatorio auxiliara no controle de precos de transferencia que "
Local cDesc2   := "objetivam coibir a pratica de transferencias de resultados para o exterior mediante"
Local cDesc3   := "a manipulacao dos precos pactuados nas importacoes ou exportacoes de bens, servicos ou direitos."
Local NomeProg := "MATR933"
Local cPerg    := "MTR933"
Local cString  := "SD1"
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

Private aReturn  := {"Zebrado",1,"Administracao",2,2,1,"",1}
Private nLastKey := 0
Private Limite   := 220
Private Tamanho  := "G"
Private lEnd     := .F.
Private cFiltro  := ""

If lVerpesssen
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                             ³
	//³ mv_par01             // Data Inicial     ?                       ³
	//³ mv_par02             // Data Final       ?                       ³
	//³ mv_par03             // Seleciona Filiais?                       ³
	//³ mv_par04             // Ordem            ?                       ³
	//³ mv_par05             // Média SELIC (%)?                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := "MATR933" // nome default do relatorio em disco
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

	dDataIni := mv_par01
	dDataFim := mv_par02

	If nLastKey == 27
		dbClearFilter()
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		dbClearFilter()
		Return
	Endif

	cFiltro := aReturn[7]

	RptStatus({|lEnd| R933Transfer(@lEnd,wnRel,cString,Tamanho,dDataIni,dDataFim)},Titulo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura Ambiente                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	dbSetOrder(1)
	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		OurSpool(wnrel)
	Endif
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R933Transfer ³ Autor ³Edstron E. Correia  ³ Data ³ 06/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Relatorio de Transferencia de Precos          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR933()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function R933Transfer(lEnd,wnRel,cString,Tamanho,dDataIni,dDataFim,lDipj,aTotal,aTotalProd,lExtTaf,nMedSelic)
Local aAreaSM0   := SM0->(GetArea())
Local aRelImp    := MaFisRelImp("MT100",{ "SD1" })
Local aRelImp2   := MaFisRelImp("MT100",{ "SD2" })
Local aLay       := Array(42)
Local aProcessa  := {}
Local aCustMed	 := {}
Local aCustEnt	 := {}
Local aCustSai	 := {}
Local cTipo      := ""
Local cAliasSD1  := "SD1"
Local cAliasSD2  := "SD2"
Local cChave     := ""
Local cProduto   := ""
Local cDesc      := ""
Local lMVEASY    := SuperGetMV("MV_EASY") == "S"
Local cRevenda   := GetNewPar("MV_REVENDA", "5101/6101/7101") //CFOPs que deverão ser processados no tratamento  das saídas para o cálculo do Transfer Pricing.
Local nTransPc   := GetNewPar("MV_TRANSPC", 20) //Define qual porcentagem aplicada no metodo PRL. Relatório Transfer Pricing.
Local cMVR933AD0 := AllTrim(GetNewPar("MV_R933AD0", "XXX")) //Campo da tabela SD1 que contém o valor do imposto de importação para o cálculo do Transfer Pricing.
Local lMVR933AD0 := Iif("XXX"$cMVR933AD0, .F., .T.)
Local nPorcTP    := 0
Local cCpVlCofEn := ""
Local cCpVlPisSa := ""
Local cCpVlPisEn := ""
Local cCpVlCofSa := ""
Local cQuebra    := ""
Local lSaiuENT   := .T.
Local lEntrouSAI := .F.
Local nFolha     := 0
Local nLin       := 80
Local nQuant     := 0
Local nPrecoTot  := 0
Local nDescIte   := 0
Local nImpIte    := 0
Local nComIte    := 0
Local nMarIte    := 0
Local nMedia     := 0
Local nDesconto  := 0
Local nImpostos  := 0
Local nComissao  := 0
Local nDocMarg	 := 0
Local nBsMargem  := 0
Local nAjustFin  := 0
Local nMargem    := 0
Local nPerImp    := 0
Local nTotal	 := 0
Local nPartic    := 0
Local nPreco     := 0
Local nDoc		 := 0
Local nDiver     := 0
Local nPsVlPisEn := 0
Local nPsVlPisSa := 0
Local nPsVlCofEn := 0
Local nPsVlCofSa := 0
Local nPos       := 0
Local nMedEntr   := 0
Local nNumEntr   := 0
Local nAjuste    := 0
Local nCodave    := 0
Local nToQuan    := 0
Local nToPrcUn   := 0
Local nToPrcPr   := 0
Local nToPrat    := 0
Local nToImp     := 0
Local nToDesc    := 0
Local nToIcms    := 0
Local nToPis     := 0
Local nToCofi    := 0
Local nToCom     := 0
Local nToMargLu  := 0
Local nSelicMed	 := 0
Local aAve       := {}
Local nPosAv     := 0
Local nY         := 0
Local nZ		 := 0
Local nPosProd   := 0
Local nXX        := 0
Local nPos1      := 0
Local aComp      := {}
Local cFilDe     := ""
Local cFilAte    := ""
Local nFilial    := 0
Local aLisFil    := {}
Local bWhileSM0  := {|| }
Local aTAjust    := {}
Local nTAjust    := 0
Local lCustMed   := .F.

#IFDEF TOP
	Local cArq010   := ""
	Local cArq020   := ""
	Local cQuery    := ""
	Local nX        := 0
#ELSE
	Local cFiltroTmp:= ""
	Local cIndSd1   := ""
	Local cIndSd2   := ""
	Local nRetInd   := 0
#ENDIF

Default lDipj       := .F.
Default aTotalProd  := {}
Default aTotal      := {}
Default lExtTaf     := .F.

If lMVR933AD0 .and. !lMVEASY
	If (SD1->(FieldPos (cMVR933AD0))==0)
		lMVR933AD0 := .F.
		xMagHelpFis ("Campo não existe",;
		"O parâmetro [MV_R933AD0] relaciona um campo que não existe no dicionário de dados",;
		"Para que a rotina continue corretamente será necessário criá-lo e referenciá-lo com um campo da tabela SD1 que identifica um valor de importação. Como padrão para será assumido [0].")
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para os campos do PIS - Entrada                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALPS2"} ) )
	cCpVlPisEn := aRelImp[nScanPis,2]
	nPsVlPisEn := SD1->(FieldPos(cCpVlPisEn))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para os campos do PIS - Saida                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_VALPS2"} ) )
	cCpVlPisSa := aRelImp2[nScanPis,2]
	nPsVlPisSa := SD2->(FieldPos(cCpVlPisSa))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para os campos do COF - Entrada                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALCF2"} ) )
	cCpVlCofEn := aRelImp[nScanCof,2]
	nPsVlCofEn := SD1->(FieldPos(cCpVlCofEn))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para os campos do COF - Saida                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( nScanCof := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_VALCF2"} ) )
	cCpVlCofSa := aRelImp2[nScanCof,2]
	nPsVlCofSa := SD2->(FieldPos(cCpVlCofSa))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o arquivo temporario para notas fiscais de entrada e saida³
//³para o relatorio do Transfer Price.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lDipj
	aTRBs := R933CriaArq()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se devo abrir a tela para fazer o processamento de multifiliais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lExtTaf
	If mv_par03 == 1
		aLisFil := MatFilCalc(.T.)
		If !Empty(aLisFil)
			cFilDe  := PadR("",FWGETTAMFILIAL)
			cFilAte := Repl("Z",FWGETTAMFILIAL)
		Else
			MsgAlert(OemToAnsi("Nenhuma filial foi selecionada para o processamento. Será considerada a filial corrente."))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para considerar a filial corrente, preciso alem de atribuir o cFilAnt, preciso forcar a ³
			//³   opcao 2 neste array que eh o resultado do wizard                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			mv_par03 := 2
			cFilDe   := cFilAnt
			cFilAte  := cFilAnt
		EndIf
	EndIf
else
	cFilDe   := cFilAnt
	cFilAte  := cFilAnt
endif

If (Empty(cFilDe) .And. Empty(cFilAte))
	cFilDe  := cFilAnt
	cFilAte := cFilAnt
EndIf

if !lExtTaf
	bWhileSM0 := {||!SM0->(Eof()) .And. ((mv_par03<>1 .And. cEmpAnt==SM0->M0_CODIGO .And. FWGETCODFILIAL<=cFilAte) .Or. (mv_par03==1 .And. Len(aLisFil)>0 .And. cEmpAnt==SM0->M0_CODIGO))}
else
	bWhileSM0 := {||!SM0->(Eof()) .And. cEmpAnt==SM0->M0_CODIGO .And. FWGETCODFILIAL=cFilAte }
endif

dbSelectArea("SM0")
SM0->(DbGoTop())
SM0->(MsSeek(cEmpAnt+cFilDe,.T.)) //Filial mais proxima
Do While Eval(bWhileSM0)
	cFilAnt	:= 	FWGETCODFILIAL	
	If Len(aLisFil) > 0 .And. cFilAnt <= cFilAte
		nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
		If nFilial==0 .Or. !(aLisFil[nFilial,1]) //Filial não marcada, vai para proxima
			SM0->(dbSkip())
			Loop
		EndIf
	EndIf

	dbSelectArea("SD1")
	SD1->(dbsetorder(1))
	#IFDEF TOP
		cAliasSD1 := "AliasSD1"
		aStruSD1  := SD1->(dbStruct())
		cQuery := "SELECT "
		cQuery += "SD1.D1_FILIAL,SD1.D1_DTDIGIT,SD1.D1_DOC,SD1.D1_COD,SD1.D1_SERIE,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_TIPO,SD1.R_E_C_N_O_ SD1RECNO,"
		cQuery += "SD1.D1_QUANT,SD1.D1_VUNIT,SD1.D1_VALDESC,SD1.D1_VALICM,SD1.D1_CF,SD1.D1_TIPO_NF,SD1.D1_PEDIDO,SD1.D1_ITEMPC,"
		cQuery += "SD1.D1_TOTAL,SD1.D1_CODISS"
		If (lMVR933AD0) .and. !lMVEASY
			cQuery += "," + cMVR933AD0
		EndIf
		If !Empty(nPsVlPisEn)
			cQuery += "," + cCpVlPisEn
		EndIf
		If !Empty(nPsVlCofEn)
			cQuery += "," + cCpVlCofEn
		EndIf
		cQuery += " FROM "+RetSqlName("SD1")+" SD1 "
		cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD1.D1_COD AND SB1.B1_POSIPI <> '' AND SB1.D_E_L_E_T_ = '' " 
		cQuery += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND " 
		cQuery += "SD1.D1_DTDIGIT >= '"+DTOS(dDataIni)+"' AND "
		cQuery += "SD1.D1_DTDIGIT <= '"+DTOS(dDataFim)+"' AND "
		cQuery += "SB1.B1_ORIGEM IN ('1','6')  AND "
		cQuery += "SD1.D_E_L_E_T_=' ' " 
		cQuery += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
		For nX := 1 To Len(aStruSD1)
			If ( aStruSD1[nX][2] <> "C" )
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX
				
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda a posicao dos campos de PIS e de COFINS na query.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cAliasSD1)
		nPsVlPisEn := (cAliasSD1)->(FieldPos(cCpVlPisEn))
		nPsVlCofEn := (cAliasSD1)->(FieldPos(cCpVlCofEn))
	#ELSE
		cIndSd1    := CriaTrab (NIL, .F.)
		cChave     := IndexKey()
		cFiltroTmp := "D1_FILIAL=='"+xFilial("SD1")+"'"
		cFiltroTmp += " .And. DTOS(SD1->D1_DTDIGIT)>='"+DTOS(dDataIni)+"' .AND. DTOS(SD1->D1_DTDIGIT)<='"+DTOS(dDataFim)+"' "
		IndRegua (cAliasSd1, cIndSd1, cChave,, cFiltroTmp)
		nRetInd := RetIndex (cAliasSd1)
		DbSetIndex (cIndSd1+OrdBagExt ())
		DbSetOrder (nRetInd+1)
		DbGoTop ()
	#ENDIF
	While !(cAliasSd1)->(Eof ())
		If (cAliasSD1)->D1_TIPO$"DB"
			dbSelectArea("SA1")
		Else
			dbSelectArea("SA2")
		Endif
		If !lExtTaf 
		 	If !Empty(cFiltro)
				SD1->(MsGoto((cAliasSD1)->SD1RECNO))
				If SD1->(!(&cFiltro))
					(cAliasSD1)->(DbSkip())
					Loop
				EndIf
			Endif
		EndIf
		If dbSeek(xFilial()+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
			cRazao   := IIF((cAliasSD1)->D1_TIPO$"DB",SA1->A1_NOME,SA2->A2_NOME)
			cTipo    := IIF((cAliasSD1)->D1_TIPO$"DB",SA1->A1_TIPO,SA2->A2_TIPO)
			cVinculo := IIF((cAliasSD1)->D1_TIPO$"DB",SA1->A1_VINCULO,SA2->A2_VINCULO)
			dbSelectArea(cAliasSD1)
			cProduto := (cAliasSD1)->D1_COD
			cChave   := (cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_COD
			If (cTipo=="X" .And. cVinculo<>" ")
							
				If ENT->(dbseek(cChave))
					RecLock("ENT",.F.)
				Else
					RecLock("ENT",.T.)
					ENT->FILIAL  := cFilAnt
					ENT->TIPO    := "Revenda"
					ENT->DTAQUIS := CTOD("//")
					ENT->NFISCAL := (cAliasSD1)->D1_DOC
					ENT->SERIE   := (cAliasSD1)->&(SerieNfId("SD1",3,"D1_SERIE"))
					ENT->PRODUTO := (cAliasSD1)->D1_COD
					If lMVEASY .And. !Empty(SF1->F1_HAWB)
						//-- Tratamento para pegar informação do modulo EIC
						aAve   := getNFEImp(.F.,(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA, (cAliasSD1)->D1_TIPO_NF,(cAliasSD1)->D1_PEDIDO, (cAliasSD1)->D1_ITEMPC)
						nPosAv := aScan(aAve,{|x| x[1]=="P04"})
						If  nPosAv > 0
							nCodave := aAve [nPosAv][3]
						EndIf
						Aadd(aCustEnt,{(cAliasSD1)->D1_COD})
					EndIf
				EndIf
				ENT->DTAQUIS    := (cAliasSD1)->D1_DTDIGIT
				ENT->DESCFOR    := cRazao
				ENT->QUANTIDADE += (cAliasSD1)->D1_QUANT
				ENT->PRECOUNIT  := (cAliasSD1)->D1_VUNIT
				If	!lMVEASY
					ENT->ADICAO += Iif(lMVR933AD0, &(cAliasSD1+"->"+cMVR933AD0),  0)
					ENT->IMPORT	+= Iif(lMVR933AD0, &(cAliasSD1+"->"+cMVR933AD0),  0)
				Else
					ENT->ADICAO := nCodave
				Endif
				ENT->DESCONTO += (cAliasSD1)->D1_VALDESC
				ENT->ICMS     += (cAliasSD1)->D1_VALICM
				ENT->PIS      += Iif(!Empty(nPsVlPisEn), (cAliasSD1)->(FieldGet(nPsVlPisEn)), 0.00)
				ENT->COFINS   += Iif(!Empty(nPsVlCofEn), (cAliasSD1)->(FieldGet(nPsVlCofEn)), 0.00)
				ENT->COMISSAO := 0.00
				ENT->MARGEM   := 0.00
				ENT->TOTAL    += (cAliasSD1)->D1_TOTAL
				ENT->CODISS   := (cAliasSD1)->D1_CODISS
				ENT->FORNEC   := (cAliasSD1)->D1_FORNECE
				ENT->LOJA     := (cAliasSD1)->D1_LOJA
				ENT->TOTALD1  += (cAliasSD1)->D1_TOTAL
				MsUnlock()
				nPos := aScan(aProcessa,{|x| x[1]==(cAliasSD1)->D1_COD})
				If nPos == 0
					Aadd(aProcessa,{(cAliasSD1)->D1_COD,.T.,.F.,"20",.F.})
				Endif
			Endif
		Endif
		(cAliasSD1)->(dbskip())
	Enddo
	#IFDEF TOP
		dbSelectArea(cAliasSD1)
		dbCloseArea()
	#ELSE
		dbSelectArea(cAliasSD1)
		RetIndex(cAliasSd1)
		FErase(cIndSd1+OrdBagExt())
	#ENDIF
	dbSelectArea("SD2")
	SD2->(DbSetOrder(3))
	#IFDEF TOP
		cAliasSD2 := "AliasSD2"
		aStruSD2  := SD2->(dbStruct())
		cQuery := "SELECT "
		cQuery += "SD2.D2_FILIAL,SD2.D2_EMISSAO,SD2.D2_COD,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_TIPO,"
		cQuery += "SD2.D2_QUANT,SD2.D2_PRCVEN,SD2.D2_DESCON,SD2.D2_VALICM,SD2.D2_CF,SD2.D2_TOTAL,SD2.D2_CODISS,SD2.D2_VALBRUT,"
		cQuery += "SD2.D2_LOCAL,SF2.F2_VALBRUT,SB1.B1_PRDORI,SB1.B1_PORCPRL"
		If !Empty(nPsVlPisSa)
			cQuery += "," + cCpVlPisSa
		EndIf
		If !Empty(nPsVlCofSa)
			cQuery += "," + cCpVlCofSa
		EndIf
		cQuery += " FROM "+RetSqlName("SD2")+" SD2 "
		cQuery += "INNER JOIN "+RetSqlName("SF2")+" SF2 ON SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.D_E_L_E_T_ = '' "
		cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD2.D2_COD AND SB1.B1_POSIPI <> '' AND SB1.D_E_L_E_T_ = '' " 
		cQuery += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
		cQuery += "SD2.D2_EMISSAO >= '"+DTOS(dDataIni)+"' AND "
		cQuery += "SD2.D2_EMISSAO <= '"+DTOS(dDataFim)+"' AND "
		cQuery += "SB1.B1_ORIGEM IN ('1','6') AND "
		cQuery += "SD2.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY "+SqlOrder(SD2->(IndexKey()))
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
		For nX := 1 To Len(aStruSD2)
			If ( aStruSD2[nX][2] <> "C" )
				TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
			EndIf
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda a posicao dos campos de PIS e de COFINS na query.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cAliasSD2)
		nPsVlPisSa := (cAliasSD2)->(FieldPos(cCpVlPisSa))
		nPsVlCofSa := (cAliasSD2)->(FieldPos(cCpVlCofSa))
	#ELSE
		cIndSd2    := CriaTrab (NIL, .F.)
		cChave     := IndexKey()
		cFiltroTmp := "D2_FILIAL=='"+xFilial("SD2")+"'"
		cFiltroTmp += " .And. DTOS(SD2->D2_EMISSAO)>='"+DTOS(dDataIni)+"' .AND. DTOS(SD2->D2_EMISSAO)<='"+DTOS(dDataFim)+"' "
		IndRegua (cAliasSd2, cIndSd2, cChave,, cFiltroTmp)
		nRetInd := RetIndex (cAliasSd2)
		DbSetIndex (cIndSd2+OrdBagExt ())
		DbSetOrder (nRetInd+1)
		DbGoTop ()
	#ENDIF
	nItem := 0
	While !(cAliasSD2)->(Eof())
		If !(AllTrim ((cAliasSD2)->D2_CF)$cRevenda)
			(cAliasSD2)->(DbSkip())
			Loop
		EndIf
		//-- Calculo comissao proporcional
		If (cAliasSD2)->F2_VALBRUT > 0
			nComissao := R933Comiss((cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA,(cAliasSD2)->D2_DOC,(cAliasSD2)->D2_SERIE,(cAliasSD2)->F2_VALBRUT,(cAliasSD2)->D2_VALBRUT)
		EndIf
		If (cAliasSD2)->D2_TIPO$"DB"
			dbSelectArea("SA2")
		Else
			dbSelectArea("SA1")
		Endif
		If dbSeek(xFilial()+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
			
				
			cRazao   := IIF(!(cAliasSD2)->D2_TIPO$"DB",SA1->A1_NOME,SA2->A2_NOME)
			cTipo    := IIF(!(cAliasSD2)->D2_TIPO$"DB",SA1->A1_TIPO,SA2->A2_TIPO)
			cVinculo := IIF(!(cAliasSD2)->D2_TIPO$"DB",SA1->A1_VINCULO,SA2->A2_VINCULO)
			If Len(Alltrim ((cAliasSD2)->B1_PRDORI)) > 0
				cProduto := (cAliasSD2)->B1_PRDORI
			Else
				cProduto := (cAliasSD2)->D2_COD
			Endif
			//-- Verifica se eh produzido e se tem componente importado e retorna a media do preco
			If !lDipj
				aComp := R933VerComp(cProduto,dDataIni,dDataFim)
			Else
				Aadd(aComp,.F.)
				Aadd(aComp,0)
				Aadd(aComp,0)
			Endif
			cChave := (cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+cProduto
			If SAI->(dbseek(cChave))
				RecLock("SAI",.F.)
			Else
				RecLock("SAI",.T.)
				SAI->FILIAL  := cFilAnt
				SAI->TIPO    := IIF(aComp[1],"Produzido","Revenda")
				SAI->DTVENDA := (cAliasSD2)->D2_EMISSAO
				SAI->NFISCAL := (cAliasSD2)->D2_DOC
				SAI->SERIE   := (cAliasSD2)->&(SerieNfId("SD2",3,"D2_SERIE"))
				SAI->PRODUTO := cProduto
				Aadd(aCustSai,{(cAliasSD2)->D2_COD,(cAliasSD2)->D2_LOCAL})
			EndIf
			//-- Usar porcentual informado no cad. de produtos. Se nao, considerar parametro MV_TRANSPC
			nPorcTP := IIF(aComp[1],60,IIF(nTransPc>0,nTransPc,20))
			If !Empty((cAliasSD2)->B1_PORCPRL)
				nPorcTP := Val((cAliasSD2)->B1_PORCPRL)
			EndIf
			SAI->DTVENDA    := (cAliasSD2)->D2_EMISSAO
			SAI->DESCCLI    := cRazao
			SAI->QUANTIDADE += (cAliasSD2)->D2_QUANT
			SAI->PRECOUNIT  := (cAliasSD2)->D2_PRCVEN
			SAI->DESCONTO   += (cAliasSD2)->D2_DESCON
			SAI->ICMS       += (cAliasSD2)->D2_VALICM
			SAI->PIS        += Iif(!Empty(nPsVlPisSa), (cAliasSD2)->(FieldGet(nPsVlPisSa)), 0.00)
			SAI->COFINS     += Iif(!Empty(nPsVlCofSa), (cAliasSD2)->(FieldGet(nPsVlCofSa)), 0.00)
			SAI->COMISSAO   := nComissao
			SAI->MARGEM     := ((cAliasSD2)->D2_PRCVEN-(cAliasSD2)->D2_DESCON)*If(Alltrim((cAliasSD2)->D2_CF)$cRevenda,0.2,0.6)
			SAI->TOTAL      += (cAliasSD2)->D2_TOTAL
			SAI->CODISS     := (cAliasSD2)->D2_CODISS
			SAI->CLIENTE    := (cAliasSD2)->D2_CLIENTE
			SAI->LOJA       := (cAliasSD2)->D2_LOJA
			SAI->MEDIA      := aComp[2]
			SAI->PORCEN     := aComp[3]
			SAI->METODO     := Str(nPorcTP,2)
			SAI->QUANTUNI	:= (cAliasSD2)->D2_QUANT
			SAI->TOTUNI		:= (cAliasSD2)->D2_TOTAL
			SAI->IMPOSTOS	:= (cAliasSD2)->D2_VALICM + Iif(!Empty(nPsVlPisSa), (cAliasSD2)->(FieldGet(nPsVlPisSa)), 0.00) + Iif(!Empty(nPsVlCofSa), (cAliasSD2)->(FieldGet(nPsVlCofSa)), 0.00)
			MsUnlock()
			nPos := aScan(aProcessa,{|x| x[1]==cProduto})
			If nPos == 0
				//-- Sem entradas no periodo! Pesquisa saldo inicial fechamento custos/estoque.
				If ( !lDipj .And. !aComp[1] ) .Or. lExtTaf 
					lCustMed := R933CustMed(cProduto, (cAliasSD2)->D2_LOCAL)
				EndIf
				Aadd(aProcessa,{cProduto,lCustMed,.T.,SAI->METODO,aComp[1]})
			Else
				aProcessa[nPos][03] := .T.
				aProcessa[nPos][04] := Str(nPorcTP,2)
				aProcessa[nPos][05] := aComp[1]
			Endif
		Endif
		(cAliasSD2)->(Dbskip())
	Enddo
	#IFDEF TOP
		dbSelectArea(cAliasSD2)
		dbCloseArea()
	#ELSE
		dbSelectArea(cAliasSD2)
		RetIndex (cAliasSd2)
		FErase (cIndSd2+OrdBagExt ())
	#ENDIF
	SM0->(DbSkip())
Enddo
RestArea(aAreaSM0)
cFilAnt := SM0->M0_CODFIL

If !lDipj
	R933LayOut(@aLay)
	//-- Ordena o array por metodo e codigo de produto
	If mv_par04 == 1
		Asort(aProcessa,,,{|x,y|x[1]<y[1]})
	Else
		Asort(aProcessa,,,{|x,y|x[4]+x[1]<y[4]+y[1]})
	EndIf
	//-- Posiciona as tabelas
	dbSelectArea("SAI")
	dbSetOrder(2) //PRODUTO+NFISCAL+SERIE+METODO+FILIAL
	dbSelectArea("ENT")
	dbSetOrder(2) //PRODUTO+NFISCAL+SERIE+FILIAL
	//-- Processa
	SetRegua(Len(aProcessa))
	For nPos := 1 to Len(aProcessa)
		IncRegua()
		If Interrupcao(@lEnd)
			Exit
		EndIf
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente processa o produto que possuir as duas movimentacoes: Entrada e Saida ou se MP Importado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aProcessa[nPos][02] .Or. aProcessa[nPos][05]) .And. aProcessa[nPos][03]
			SB1->(dbsetorder(1))
			SB1->(dbseek(xFilial("SB1")+aProcessa[nPos][01]))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprimindo as entradas do produto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("ENT")
			ENT->(dbSeek(aProcessa[nPos][01]))
			cProduto := ENT->PRODUTO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Zera as variaveis de calculo a cada novo produto a ser processado.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nQuant   := 0
			nPrecoTot:= 0
			nDescIte := 0
			nImpIte  := 0
			nComIte  := 0
			nMarIte  := 0
			nMedEntr := 0
			nNumEntr := 0
			nAjuste  := 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Zera as variaveis de calculo Total por item   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nToQuan  := 0
			nToPrcUn := 0
			nToPrcPr := 0
			nToPrat  := 0
			nToImp   := 0
			nToDesc  := 0
			nToIcms  := 0
			nToPis   := 0
			nToCofi  := 0
			nToCom   := 0
			nToMargLu:= 0
			If aProcessa[nPos][02] //aProcessa[nPos][04]=="20"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cabecalho do estabelecimento e da movimentacao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Mtr933Cab(@nFolha,@nLin,dDataIni,dDataFim,SB1->B1_POSIPI,SB1->B1_DESC,SB1->B1_UM,"E",,SB1->B1_COD)

				While !ENT->(Eof()) .And. cProduto == ENT->PRODUTO
					If Interrupcao(@lEnd)
						Exit
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Cabecalho do estabelecimento e da movimentacao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nLin > 60
						Mtr933Cab(@nFolha,@nLin,dDataIni,dDataFim,SB1->B1_POSIPI,SB1->B1_DESC,SB1->B1_UM,"E",,SB1->B1_COD)
					Endif
					FmtLin({Iif(ENT->DESCFOR != 'Custo Medio',ENT->DTAQUIS, ""),;
					SUBS(ENT->DESCFOR,1,35),;
					STRZERO(VAL(ENT->NFISCAL),10),;
					ENT->SERIE,;
					PADL((TRANSFORM(Iif(ENT->DESCFOR != 'Custo Medio',ENT->QUANTIDADE, 0),X3Picture("D1_QUANT"))),13),;
					TRANSFORM(ENT->PRECOUNIT,"@E 9,999,999.9999"),;
					TRANSFORM(IIf(!lMVEASY, (ENT->TOTALD1-ENT->ADICAO)/ENT->QUANTIDADE, ENT->PRECOUNIT),"@E 9,999,999.9999"),;
					TRANSFORM(IIf(!lMVEASY, Iif(ENT->DESCFOR != 'Custo Medio',(ENT->TOTALD1-ENT->ADICAO), 0),ENT->PRECOUNIT*ENT->QUANTIDADE),"@E 9,999,999.9999"),;
					TRANSFORM(ENT->ADICAO   ,"@E 999,999,999.99"),;
					TRANSFORM(ENT->DESCONTO ,"@E 9,999,999.99"),;
					TRANSFORM(ENT->ICMS     ,"@E 9,999,999.99"),;
					TRANSFORM(ENT->PIS      ,"@E 9,999,999.99"),;
					TRANSFORM(ENT->COFINS   ,"@E 9,999,999.99"),;
					TRANSFORM(ENT->COMISSAO ,"@E 999,999,999.99"),;
					TRANSFORM(ENT->MARGEM   ,"@E 9,999,999.99")},aLay[11],,,@nLin)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente entram no cálculo as notas fiscais com quantidade.                                              ³
					//³As notas fiscais com quantidade zerada são complemento de importação e não devem fazer parte do cálculo.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//Alteração Ch|Origem P11: TTZMWK Ch:TUEBYD 
					//If ENT->QUANTIDADE > 0
						If !lMVEASY 
							nMedEntr += (ENT->TOTALD1 - ENT->IMPORT)
						Else
							nMedEntr += ENT->TOTAL
						EndIf
						nNumEntr += ENT->QUANTIDADE
					//Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Totalizadores por item - Entrada ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nToQuan  += Iif(ENT->DESCFOR != 'Custo Medio',ENT->QUANTIDADE, 0)
					nToPrcUn += ENT->PRECOUNIT
					nToPrcPr += Iif(!lMVEASY, (ENT->TOTALD1-ENT->ADICAO), ENT->PRECOUNIT)
					nToPrat  := IIf(!lMVEASY, Iif(ENT->DESCFOR != 'Custo Medio',nToPrcPr,0), ENT->(PRECOUNIT*QUANTIDADE))
					nToImp   += ENT->ADICAO
					nToDesc  += ENT->DESCONTO
					nToIcms  += ENT->ICMS
					nToPis   += ENT->PIS
					nToCofi  += ENT->COFINS
					nToCom   += ENT->COMISSAO
					nToMargLu+= ENT->MARGEM
					ENT->(dbSkip())
				Enddo
				FmtLin(,aLay[08],,,@nLin)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime total por Item/Entrada ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FmtLin({"Total",;
				PadL(TRANSFORM(nToQuan  , X3Picture("D1_QUANT")),13),;
				(""),;
				(""),;
				TRANSFORM(nToPrat  , "@E 9,999,999.9999"),;
				TRANSFORM(nToImp   , "@E 999,999,999.99"),;
				TRANSFORM(nToDesc  , "@E 9,999,999.99"),;
				TRANSFORM(nToIcms  , "@E 9,999,999.99"),;
				TRANSFORM(nToPis   , "@E 9,999,999.99"),;
				TRANSFORM(nToCofi  , "@E 9,999,999.99"),;
				TRANSFORM(nToCom   , "@E 999,999,999.99"),;
				TRANSFORM(nToMargLu, "@E 9,999,999.99")},aLay[38],,,@nLin)
				FmtLin(,aLay[08],,,@nLin)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprimindo as saidas do produto  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SAI")
			SAI->(dbSeek(aProcessa[nPos][01]))
			cProduto   := SAI->PRODUTO
			cDesc      := SB1->B1_DESC
			lEntrouSai := .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cabecalho do estabelecimento e da movimentacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLin <= 60
				FmtLin(,aLay[05],,,@nLin)
				FmtLin(,aLay[05],,,@nLin)
			Endif
			Mtr933Cab(@nFolha,@nLin,dDataIni,dDataFim,SB1->B1_POSIPI,SB1->B1_DESC,SB1->B1_UM,"S",SAI->METODO,SB1->B1_COD)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Zera as variaveis de calculo Total por item   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nToQuan  := 0
			nToPrcUn := 0
			nToPrat  := 0
			nToImp   := 0
			nToDesc  := 0
			nToIcms  := 0
			nToPis   := 0
			nToCofi  := 0
			nToCom   := 0
			nToMargLu:= 0
			nDocMarg := 0
			nDoc	 := 0
			nBsMargem:= 0
			nTotal	 := 0
			nAjustFin:= 0
			While !SAI->(Eof()) .And. cProduto == SAI->PRODUTO
				If Interrupcao(@lEnd)
					Exit
				EndIf
				Do Case
					Case SAI->METODO=="20"
						nPos1 := 1
					Case SAI->METODO=="30"
						nPos1 := 2
					Case SAI->METODO=="40"
						nPos1 := 3
					Case SAI->METODO=="60"
						nPos1 := 4
					Otherwise
						nPos1 := 1
				EndCase
				//-- Cabecalho do estabelecimento e da movimentacao.
				If nLin > 60
					Mtr933Cab(@nFolha,@nLin,dDataIni,dDataFim,SB1->B1_POSIPI,SB1->B1_DESC,SB1->B1_UM,"S",SAI->METODO,SB1->B1_COD)
				Endif
	
				nDocMarg := SAI->TOTUNI - SAI->IMPOSTOS - Round((SAI->TOTUNI * mv_par05/100),2)
				nDocMarg := Iif(nDocMarg >= 0, nDocMarg, 0)
				nDoc	 := (nDocMarg -(((nDocMarg- (nDesconto+nComissao))*Val(SAI->METODO))/100))/SAI->QUANTUNI 
				nDoc	 := Iif(nDoc >= 0, nDoc, 0)

				FmtLin({SAI->DTVENDA,;
				SUBS(SAI->DESCCLI,1,35),;
				STRZERO(VAL(SAI->NFISCAL),10),;
				SAI->SERIE,;
				PADL(Alltrim(TRANSFORM(SAI->QUANTIDADE,X3Picture("D2_QUANT"))),13),;
				TRANSFORM(SAI->PRECOUNIT,"@E 9,999,999.9999"),;
				TRANSFORM(nDoc,"@E 9,999,999.9999"),;
				TRANSFORM(SAI->(PRECOUNIT*QUANTIDADE),"@E 9,999,999.9999"),;
				TRANSFORM(nToImp,"@E 999,999,999.99"),;
				TRANSFORM(SAI->DESCONTO ,"@E 9,999,999.99"),;
				TRANSFORM(SAI->ICMS     ,"@E 9,999,999.99"),;
				TRANSFORM(SAI->PIS      ,"@E 9,999,999.99"),;
				TRANSFORM(SAI->COFINS   ,"@E 9,999,999.99"),;
				TRANSFORM(SAI->COMISSAO ,"@E 999,999,999.99"),;
				TRANSFORM(nDocMarg*Val(SAI->METODO)/100,"@E 9,999,999.99")},aLay[17],,,@nLin)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Somente entram no cálculo as notas fiscais com quantidade.                                              ³
				//³As notas fiscais com quantidade zerada são complemento de importação e não devem fazer parte do cálculo.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If QUANTIDADE > 0 .And. nDoc > 0
					nQuant    += SAI->QUANTIDADE
					nPrecoTot += SAI->(QUANTIDADE*PRECOUNIT) 
					nDescIte  += SAI->DESCONTO
					nImpIte   += SAI->(ICMS+PIS+COFINS)
					nComIte   += SAI->COMISSAO
					nMarIte   += SAI->MARGEM
					nPerImp   := SAI->PORCEN
					nTotal	  += SAI->TOTAL
					nPartic   := 0
					nMedia    := Round(nPrecoTot / nQuant,4)
					nDesconto := Round(nDescIte  / nQuant,4)
					nImpostos := Round(nImpIte   / nQuant,4)
					nComissao := Round(nComIte   / nQuant,4)
					nSelicMed := Round((nMedia * mv_par05/100),4)
					nBsMargem := nTotal-nImpIte-Round((nTotal * mv_par05/100),4) //Base de Calculo da Margem de Contribuicao.
					nAjustFin := (nPrecoTot	/ nQuant) * (mv_par05/100) ///Ajuste Financeiro
					If nPerImp == 0
										
						// Calculo da margem de lucro
						nMargem  :=  (((nMedia-nImpostos-nSelicMed)*Val(SAI->METODO))/100)

						// calculo do preco-parametro
						If !lMVEASY
							nPreco   := (nBsMargem-(((nBsMargem-(nDescIte+nComIte))*Val(SAI->METODO))/100))/nQuant
							nPreco	 := Iif(nPreco >=0, nPreco, 0)
						Else
							//INCLUSÃO DA REDUÇÃO DE SELIC NA FORMULA APÓS ANALISE EM CONJUNTO COM LUCIANA E GUARNIERI {Eduardo - 14/09/2020}
							nPreco   := nMedia-(nDesconto+nImpostos+nComissao+nMargem+nSelicMed)
						EndIf
						// Valor da margem de divergencia admitida
						nDiver   := nPreco*0.05
					Else
						nNumEntr := 1
						nMedEntr := SAI->MEDIA
						// Aplicacao do percentual de participacao sobre a receita liquida
						nPartic  := (((nMedia-(nDesconto+nImpostos+nComissao))*nPerImp)/100)
						// Calculo da margem de lucro
						nMargem  := ((nPartic*Val(SAI->METODO))/100)
						// calculo do preco-parametro
						nPreco   := nPartic-nMargem
						// Valor da margem de divergencia admitida
						nDiver   := nMedEntr*0.05
					Endif
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Totalizadores por item - saida   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nToQuan  += SAI->QUANTIDADE
				nToPrcUn += SAI->PRECOUNIT
				nToPrat  += SAI->(PRECOUNIT*QUANTIDADE)
				nToImp   += 0
				nToDesc  += SAI->DESCONTO
				nToIcms  += SAI->ICMS
				nToPis   += SAI->PIS
				nToCofi  += SAI->COFINS
				nToCom   += SAI->COMISSAO
				nToMargLu:= nBsMargem*Val(SAI->METODO)/100
				SAI->(dbSkip())
			Enddo
			FmtLin(,aLay[08],,,@nLin)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime total por Item/Saida ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FmtLin({"Total",;
			PadL(TRANSFORM(nToQuan , X3Picture("D2_QUANT")),13),;
			(""),;
			(""),;
			TRANSFORM(nToPrat  , "@E 9,999,999.9999"),;
			TRANSFORM(nToImp   , "@E 999,999,999.99"),;
			TRANSFORM(nToDesc  , "@E 9,999,999.99"),;
			TRANSFORM(nToIcms  , "@E 9,999,999.99"),;
			TRANSFORM(nToPis   , "@E 9,999,999.99"),;
			TRANSFORM(nToCofi  , "@E 9,999,999.99"),;
			TRANSFORM(nToCom   , "@E 999,999,999.99"),;
			TRANSFORM(nToMargLu, "@E 9,999,999.99")},aLay[38],,,@nLin)
			FmtLin(,aLay[08],,,@nLin)
			If (nLin>45)
				Mtr933Cab(@nFolha,@nLin,dDataIni,dDataFim,,,,"R")
			Else
				FmtLin(,aLay[05],,,@nLin)
				FmtLin(,aLay[05],,,@nLin)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o valor do ajuste (quando a media for maior que o PRL)                           ³
			//³ AJUSTE = Media dos Precos Praticados na Entrada - Preco Parametro (PRL)                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nNumEntr > 0 .And. nDoc > 0
				nAjuste := Max(0,(nMedEntr / nNumEntr) - nPreco)
				nTAjust += (nAjuste*nQuant)
				aAdd(aTAjust,{cProduto+" - "+cDesc,nAjuste,nQuant})
			Endif
			FmtLin(,aLay[18],,,@nLin)
			FmtLin(,aLay[19],,,@nLin)
			FmtLin({TRANSFORM(nMedia   ,"@E 9,999,999.9999")},aLay[20],,,@nLin)
			FmtLin({TRANSFORM(nDesconto,"@E 9,999,999.9999")},aLay[21],,,@nLin)
			FmtLin({TRANSFORM(nImpostos,"@E 9,999,999.9999")},aLay[22],,,@nLin)
			FmtLin({TRANSFORM(MV_PAR05,"@E 999.99"),TRANSFORM(nAjustFin,"@E 9,999,999.9999")},aLay[23],,,@nLin)
			FmtLin({TRANSFORM(nComissao,"@E 9,999,999.9999")},aLay[24],,,@nLin)
			FmtLin({TRANSFORM(nMargem  ,"@E 9,999,999.9999")},aLay[25],,,@nLin)
			FmtLin({TRANSFORM((nMedEntr / nNumEntr),"@E 9,999,999.9999")},aLay[26],,,@nLin)
			FmtLin({TRANSFORM(nPerImp  ,"@E 9,999,999.9999")},aLay[27],,,@nLin)
			FmtLin({TRANSFORM(nPreco   ,"@E 9,999,999.9999")},aLay[28][nPos1],,,@nLin)
			FmtLin({TRANSFORM(nAjuste  ,"@E 9,999,999.9999")},aLay[29],,,@nLin)
			FmtLin({TRANSFORM(nAjuste*nQuant,"@E 9,999,999.9999")},aLay[37],,,@nLin)
			FmtLin(,aLay[30],,,@nLin)
			FmtLin(,aLay[31],,,@nLin)
			FmtLin(,aLay[32],,,@nLin)
			FmtLin({TRANSFORM(nPreco,"@E 9,999,999.9999")},aLay[33],,,@nLin)
			FmtLin({TRANSFORM(nPreco,"@E 9,999,999.9999"),TRANSFORM(nDiver,"@E 9,999,999.9999")},aLay[34],,,@nLin)
			FmtLin(,aLay[35],,,@nLin)
			FmtLin(,aLay[05],,,@nLin)
		Endif
	Next nPos
	If (nLin>60)
		Mtr933Cab(@nFolha,@nLin,dDataIni,dDataFim,,,,"R")
	Else
		FmtLin(,aLay[05],,,@nLin)
		FmtLin(,aLay[05],,,@nLin)
	EndIf
	If nTAjust > 0
		Mtr933Cab(@nFolha,@nLin,dDataIni,dDataFim,,,,"R")
		FmtLin(,aLay[39],,,@nLin)
		FmtLin(,aLay[40],,,@nLin)
		FmtLin(,aLay[39],,,@nLin)
		For nXX := 1 To Len(aTAjust)
			If (nLin>45)
				Mtr933Cab(@nFolha,@nLin,dDataIni,dDataFim,,,,"R")
			EndIf
			FmtLin({aTAjust[nXX,1],;
			TRANSFORM(aTAjust[nXX,2],"@E 999,999,999.99"),;
			TRANSFORM(aTAjust[nXX,2]*aTAjust[nXX,3],"@E 999,999,999.99")},aLay[41],,,@nLin)
		Next nXX
		FmtLin(,aLay[38],,,@nLin)
		FmtLin({TRANSFORM(nTAjust,"@E 999,999,999.99")},aLay[42],,,@nLin)
		FmtLin(,aLay[39],,,@nLin)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui arquivos temporarios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("ENT")
	dbCloseArea()
	Ferase (cArq010+GetDBExtension())
	Ferase (cArq010+OrdBagExt())
	dbSelectArea("SAI")
	dbCloseArea()
	Ferase (cArq020+GetDBExtension())
	Ferase (cArq020+OrdBagExt())
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa os valores do Transfer Price para carregar no arquivo ³
	//³temporario criado para DIPJ - Registro R32 e R33.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SAI")
	dbSetOrder(2)
	dbSelectArea("ENT")
	dbSetOrder(2)

	For nPos := 1 to Len(aProcessa)

		aAdd (aTotal, {0,0,0,0,0,0,0,0,0,0,0,0,"",0,0,0,0,0,0,0,0,0,0,0,0,0,0})
		nXX	:=	Len (aTotal)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente processa o produto que possuir as duas movimentacoes: Entrada e Saida³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aProcessa[nPos][02] .Or. aProcessa[nPos][03]

			SB1->(dbsetorder(1))
			If SB1->(dbseek(xFilial("SB1")+aProcessa[nPos][01]))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Imprimindo as entradas do produto³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("ENT")
				ENT->(dbSeek(aProcessa[nPos][01]))
				cProduto := ENT->PRODUTO
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Zera as variaveis de calculo a cada novo produto a ser processado.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nQuant   := 0
				nPrecoTot:= 0
				nDescIte := 0
				nImpIte  := 0
				nComIte  := 0
				nMarIte  := 0
				nMedEntr := 0
				nNumEntr := 0
				nAjuste  := 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Zera as variaveis de calculo Total por item   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nToQuan  := 0
				nToPrcUn := 0
				nToPrat  := 0
				nToImp   := 0
				nToDesc  := 0
				nToIcms  := 0
				nToPis   := 0
				nToCofi  := 0
				nToCom   := 0
				nToMargLu:= 0

				While !ENT->(Eof()) .And. cProduto == ENT->PRODUTO
					If Interrupcao(@lEnd)
						Exit
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente entram no cálculo as notas fiscais com quantidade.                                              ³
					//³As notas fiscais com quantidade zerada são complemento de importação e não devem fazer parte do cálculo.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//Alteração Ch|Origem P11: TTZMWK Ch:TUEBYD 
					//If ENT->QUANTIDADE > 0
						if !lExtTaf
							nMedEntr += ENT->PRECOUNIT
							nNumEntr += 1
						else
							If !lMVEASY 
								nMedEntr += (ENT->TOTALD1 - ENT->IMPORT)
							Else
								nMedEntr += ENT->TOTAL
							EndIf
							nNumEntr += ENT->QUANTIDADE
						endif
					//Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Totalizadores por item - Entrada ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nToQuan  += ENT->QUANTIDADE
					nToPrcUn += ENT->PRECOUNIT
					nToPrat  += ENT->(PRECOUNIT*QUANTIDADE)
					nToImp   += ENT->ADICAO
					nToDesc  += ENT->DESCONTO
					nToIcms  += ENT->ICMS
					nToPis   += ENT->PIS
					nToCofi  += ENT->COFINS
					nToCom   += ENT->COMISSAO
					nToMargLu+= ENT->MARGEM
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Guarda no Array os valores das notas fiscais de entrada³
					//³item a item.                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aTotal[nXX][01] := cProduto
					aTotal[nXX][02] := "E"
					aTotal[nXX][03] := nToQuan
					aTotal[nXX][04] := nToPrcUn
					aTotal[nXX][05] := nToPrat
					aTotal[nXX][06] := nToImp
					aTotal[nXX][07] := nToDesc
					aTotal[nXX][08] := nToIcms
					aTotal[nXX][09] := nToPis
					aTotal[nXX][10] := nToCofi
					aTotal[nXX][11] := nToCom
					aTotal[nXX][12] := nToMargLu
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³Guarda no Array o total dos valores das notas fiscais de entrada.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					nPosProd :=aScan(aTotalProd,{|x| x[1]==Alltrim(cProduto).And. x[2]=="E"})
					If nPosProd ==0
						aAdd (aTotalProd, {})
						nY	:=	Len (aTotalProd)
						aAdd (aTotalProd[nY], Alltrim(cProduto))
						aAdd (aTotalProd[nY], "E")
						aAdd (aTotalProd[nY], nToQuan)
						aAdd (aTotalProd[nY], nToPrcUn)
						aAdd (aTotalProd[nY], nToPrat)
						aAdd (aTotalProd[nY], nToImp)
						aAdd (aTotalProd[nY], nToDesc)
						aAdd (aTotalProd[nY], nToIcms)
						aAdd (aTotalProd[nY], nToPis)
						aAdd (aTotalProd[nY], nToCofi)
						aAdd (aTotalProd[nY], nToCom)
						aAdd (aTotalProd[nY], nToMargLu)
					Else
						aTotalProd[nPosProd][3]  += ENT->QUANTIDADE
						aTotalProd[nPosProd][4]  += ENT->PRECOUNIT
						aTotalProd[nPosProd][5]  += ENT->(PRECOUNIT*QUANTIDADE)
						aTotalProd[nPosProd][6]  += ENT->ADICAO
						aTotalProd[nPosProd][7]  += ENT->DESCONTO
						aTotalProd[nPosProd][8]  += ENT->ICMS
						aTotalProd[nPosProd][9]  += ENT->PIS
						aTotalProd[nPosProd][10] += ENT->COFINS
						aTotalProd[nPosProd][11] += ENT->COMISSAO
						aTotalProd[nPosProd][12] += ENT->MARGEM
					Endif
					ENT->(dbSkip())
				Enddo
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Imprimindo as saidas do produto  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SAI")
				SAI->(dbSeek(aProcessa[nPos][01]))
				cProduto   := SAI->PRODUTO
				lEntrouSai := .T.
				nToQuan    := 0
				nTotal     := 0
				While !SAI->(Eof()) .And. cProduto==SAI->PRODUTO
					If Interrupcao(@lEnd)
						Exit
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente entram no cálculo as notas fiscais com quantidade.                                              ³
					//³As notas fiscais com quantidade zerada são complemento de importação e não devem fazer parte do cálculo.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SAI->QUANTIDADE > 0
						nQuant    += SAI->QUANTIDADE
						nPrecoTot += SAI->(QUANTIDADE*PRECOUNIT)
						nDescIte  += SAI->DESCONTO
						nImpIte   += SAI->(ICMS+PIS+COFINS)
						nComIte   += SAI->COMISSAO
						nMarIte   += SAI->MARGEM
						nMedia    := nPrecoTot/nQuant
						nDesconto := nDescIte/nQuant
						nImpostos := nImpIte/nQuant
						nComissao := nComIte/nQuant
						nMargem   := (((nPrecoTot*20)/100)/nQuant)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Totalizadores por item - saida   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nToQuan   += SAI->QUANTIDADE
						nToPrcUn  += SAI->PRECOUNIT
						nToPrat   += SAI->(PRECOUNIT*QUANTIDADE)
						nToImp    += 0
						nToDesc   += SAI->DESCONTO
						nToIcms   += SAI->ICMS
						nToPis    += SAI->PIS
						nToCofi   += SAI->COFINS
						nToCom    += SAI->COMISSAO
						nToMargLu += SAI->MARGEM
						
						nTotal	   += SAI->TOTAL
						
						if lExtTaf
							If nPerImp == 0
							
								nBsMargem := nTotal-nImpIte-Round((nTotal * nMedSelic/100),2) //Base de Calculo da Margem de Contribuicao.
								
								If !lMVEASY
									nPreco  := (nBsMargem-(((nBsMargem-(nDescIte+nComIte))*Val(SAI->METODO))/100))/nQuant
									nPreco	 := Iif(nPreco >=0, nPreco, 0)
								Else
									nPreco   := nMedia-(nDesconto+nImpostos+nComissao+nMargem)
								endif
								
								nDiver    := nPreco*0.05		
							Else
								nNumEntr := 1
								nMedEntr := SAI->MEDIA
								
								// Aplicacao do percentual de participacao sobre a receita liquida
								nPartic  := (((nMedia-(nDesconto+nImpostos+nComissao))*nPerImp)/100)
								
								// Calculo da margem de lucro
								nMargem  := ((nPartic*Val(SAI->METODO))/100)
								
								// calculo do preco-parametro
								nPreco   := nPartic-nMargem
								
								// Valor da margem de divergencia admitida
								nDiver   := nMedEntr*0.05
							Endif					
						endif
						
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Guarda no Array os valores das notas fiscais de saida  ³
						//³item a item.                                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aTotal[nXX][01] := cProduto
						aTotal[nXX][13] := "S"
						aTotal[nXX][14] := nQuant
						aTotal[nXX][15] := nPrecoTot
						aTotal[nXX][16] := nDescIte
						aTotal[nXX][17] := nImpIte
						aTotal[nXX][18] := nComIte
						aTotal[nXX][19] := nMarIte
						aTotal[nXX][20] := nMedia
						aTotal[nXX][21] := nDesconto
						aTotal[nXX][22] := nImpostos
						aTotal[nXX][23] := nComissao
						aTotal[nXX][24] := nMargem
						aTotal[nXX][25] := nPreco
						aTotal[nXX][26] := nDiver
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³Guarda no Array o total dos valores das notas fiscais de saida .³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					nPosProd :=aScan(aTotalProd,{|x| x[1]==Alltrim(cProduto).And. x[2]=="S"})
					If nPosProd ==0
						aAdd (aTotalProd, {})
						nY	:=	Len (aTotalProd)
						aAdd (aTotalProd[nY], Alltrim(cProduto))
						aAdd (aTotalProd[nY], "S")
						aAdd (aTotalProd[nY], nToQuan)
						aAdd (aTotalProd[nY], nToPrcUn)
						aAdd (aTotalProd[nY], nToPrat)
						aAdd (aTotalProd[nY], nToImp)
						aAdd (aTotalProd[nY], nToDesc)
						aAdd (aTotalProd[nY], nToIcms)
						aAdd (aTotalProd[nY], nToPis)
						aAdd (aTotalProd[nY], nToCofi)
						aAdd (aTotalProd[nY], nToCom)
						aAdd (aTotalProd[nY], nToMargLu)
					Else
						aTotalProd[nPosProd][3]  += SAI->QUANTIDADE
						aTotalProd[nPosProd][4]  += SAI->PRECOUNIT
						aTotalProd[nPosProd][5]  += SAI->(PRECOUNIT*QUANTIDADE)
						aTotalProd[nPosProd][6]  += 0
						aTotalProd[nPosProd][7]  += SAI->DESCONTO
						aTotalProd[nPosProd][8]  += SAI->ICMS
						aTotalProd[nPosProd][9]  += SAI->PIS
						aTotalProd[nPosProd][10] += SAI->COFINS
						aTotalProd[nPosProd][11] += SAI->COMISSAO
						aTotalProd[nPosProd][12] += SAI->MARGEM
					Endif
					SAI->(dbSkip())
				Enddo
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calcula o valor do ajuste                                                                 ³
				//³AJUSTE = Media dos Precos Praticados na Entrada - PRL (quando a media for maior que o PRL)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nNumEntr > 0
					nAjuste := Max(0,(nMedEntr / nNumEntr) - nPreco)
					aTotal[nXX][27] := nAjuste
				Endif
			Endif
		Endif
	Next
Endif
Return(.t.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R995LayOut()³ Autor ³ Eduardo Reira        ³ Data ³10/06/98³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lay-Out do Relatorio Modelo A,B,C ou D                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR995                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R933LayOut(aLay)

aLay[01]		:="###########################################################################          ##################    		####################                                                                      Pagina: ########"
aLay[02]		:="###########################################################################          ################## 		####################"
aLay[03]		:="Periodo de ######## a ########"
aLay[04]		:="Demonstrativo de Preco de Transferencia - Metodo PRL" // ( Preco de Revenda menos Lucro )"
aLay[05]		:=""
aLay[06]		:="Entradas - Aquisicoes"
aLay[07]		:="Produto : ############################## - ############################################################################## - Unidade de Medida : ## - NCM : ##########"
aLay[08]		:="+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLay[09]		:="| Aquisicao|Fornecedor                         |Nt  Fiscal|Ser|   Quantidade|  Prc Unitario| Prc Praticado|Praticado Tot.|Imp.Importacao|   Descontos|        ICMS|         PIS|      COFINS|     Comissoes|Margem Lucro|"
aLay[10]		:="+----------+-----------------------------------+----------+---+-------------+--------------+--------------+--------------+--------------+------------+------------+------------+------------+--------------+------------+"
aLay[11]		:="|##########|###################################|##########|###|#############|##############|##############|##############|##############|############|############|############|############|##############|############|"
aLay[12]		:= {nil,nil}
aLay[12][1]		:="Saidas - Revenda"
aLay[12][2]		:="Saidas - Produzido"
aLay[13]		:="Produto : ############################## - ############################################################################## - Unidade de Medida : ## - NCM : ##########"
aLay[14]		:="+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLay[15]		:="|Dt Venda  |Cliente                            |Nt  Fiscal|Ser|   Quantidade|  Prc Unitario| Prc Parametro|Parametro Tot.|Imp.Importacao|   Descontos|        ICMS|         PIS|      COFINS|     Comissoes|Margem Lucro|"
aLay[16]		:="+----------+-----------------------------------+----------+---+-------------+--------------+--------------+--------------+--------------+------------+------------+------------+------------+--------------+------------+"
aLay[17]		:="|##########|###################################|##########|###|#############|##############|##############|##############|##############|############|############|############|############|##############|############|"
aLay[18]		:=" Preco Parametro"
aLay[19]		:="+-----------------------------------------------------------------------------+"
aLay[20]		:="| Media Aritmetica dos Precos de Venda                       : ############## |"
aLay[21]		:="| Descontos Incondicionais Concedidos                        : ############## |"
aLay[22]		:="| Impostos Incidentes sobre Vendas                           : ############## |"
aLay[23]		:="| Ajuste Financeiro (Taxa Selic: ###### %)                   : ############## |"
aLay[24]		:="| Comissoes e Corretagens                                    : ############## |"
aLay[25]		:="| Margem de Lucro                                            : ############## |"
aLay[26]		:="| Media do Preco Praticado nas Entradas                      : ############## |"
aLay[27]		:="| Percentual de Participacao                                 : ############## |"
aLay[28]		:= {nil,nil,nil,nil}
aLay[28][1]		:="| Preco Parametro (PRL - 20%)                                : ############## |"
aLay[28][2]		:="| Preco Parametro (PRL - 30%)                                : ############## |"
aLay[28][3]		:="| Preco Parametro (PRL - 40%)                                : ############## |"
aLay[28][4]		:="| Preco Parametro (PRL - 60%)                                : ############## |"
aLay[29]		:="| Ajuste                                                     : ############## |"
aLay[30]		:="+-----------------------------------------------------------------------------+"
aLay[31]		:=" Verificacao da Margem de Divergencia"
aLay[32]		:="+-----------------------------------------------------------------------------+"
aLay[33]		:="| Preco Parametro (PRL)                                      : ############## |"
aLay[34]		:="| Margem de divergencia : 5% de ##############               : ############## |"
aLay[35]		:="+-----------------------------------------------------------------------------+"
aLay[36]		:="-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
aLay[37]		:="| Ajuste Total (Ajuste x Quantidade)                         : ############## |"
aLay[38]		:="|#############################################################|#############|##############|##############|##############|##############|############|############|############|############|##############|############|"
aLay[39]		:="+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLay[40]		:="| Produto                                                                                           Ajuste    Ajuste Total                                                                                              |"
aLay[41]		:="| ########################################################################################  ##############  ##############                                                                                              |"
aLay[42]		:="| Ajuste Total (Todos os produtos)                                                                          ##############                                                                                              |"
Return(.t.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Mtr933Cab ³ Autor ³Mary C. Hergert        ³ Data ³18/10/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Apresenta o cabecalho de cada pagina                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³MATR933                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mtr933Cab(nFolha,nLin,dDataIni,dDataFim,cPosIPI,cDesc,cUM,cTipo,cMetodo,cCod)

Local aLay := Array(42)
Local nPos := IIf(cMetodo=="60",2,1)

Default cMetodo := "20"

R933LayOut(@aLay)

// Cabecalho geral do relatorio
If nLin > 60 .Or. cTipo == "R"
	nLin := 0
	@ nLin,000 PSAY aValImp(Limite)
	nLin++
	nFolha ++
	FmtLin({SM0->M0_NOMECOM,Transf(SM0->M0_CGC,"@R 99.999.999/9999-99"),SM0->M0_INSC,StrZero(nFolha,8)},aLay[01],,,@nLin)
	FmtLin({SM0->M0_ENDENT,SM0->M0_BAIRENT,SM0->M0_CIDENT},aLay[02],,,@nLin)
	FmtLin({dDataIni,dDataFim},aLay[03],,,@nLin)
	FmtLin(,aLay[05],,,@nLin)
	FmtLin(,aLay[04],,,@nLin)
	FmtLin(,aLay[36],,,@nLin)
	FmtLin(,aLay[05],,,@nLin)
Endif

If nLin <= 55
	If cTipo == "S"
		// Cabecalho dos movimentos de saida
		FmtLin(,aLay[12][nPos],,,@nLin)
		FmtLin({cCod,cDesc,cUM,cPosIPI},aLay[13],,,@nLin)
		FmtLin(,aLay[14],,,@nLin)
		FmtLin(,aLay[15],,,@nLin)
		FmtLin(,aLay[16],,,@nLin)
	Elseif cTipo == "E"
		// Cabecalho dos movimentos de entrada
		FmtLin(,aLay[06],,,@nLin)
		FmtLin({cCod,cDesc,cUM,cPosIPI},aLay[07],,,@nLin)
		FmtLin(,aLay[08],,,@nLin)
		FmtLin(,aLay[09],,,@nLin)
		FmtLin(,aLay[10],,,@nLin)
	Endif
Else
	nLin := 80
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATR933   ºAutor  ³Microsiga           º Data ³  27/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RA933CriaArq                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DIPJ                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function R933CriaArq()
Local aCampos    := {}
Local cArq010    := ""
Local cArq020    := ""
Local aTrbs      := {}
Local cIndxTemp1 := ""
Local cIndxTemp2 := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arquivo de Entradas - Transfer Price ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCampos,{"PRODUTO"		,"C"	,TamSX3("D1_COD")[1],0})
AADD(aCampos,{"NFISCAL"		,"C"	,TamSX3("F1_DOC")[1],0})
AADD(aCampos,{"SERIE"		,"C"	,003,0})
AADD(aCampos,{"DTAQUIS"		,"D"	,008,0})
AADD(aCampos,{"DESCFOR"		,"C"	,060,0})
AADD(aCampos,{"QUANTIDADE"	,"N",TamSX3("D1_QUANT")[1],TamSX3("D1_QUANT")[2]})
AADD(aCampos,{"PRECOUNIT"	,"N"  ,TamSX3("D1_VUNIT")[1],TamSX3("D1_VUNIT")[2]})  // 	,012,2})
AADD(aCampos,{"ADICAO"		,"N"	,012,2})
AADD(aCampos,{"DESCONTO"	,"N"	,012,2})
AADD(aCampos,{"ICMS"		,"N"	,012,2})
AADD(aCampos,{"PIS"			,"N"	,012,2})
AADD(aCampos,{"COFINS"		,"N"	,012,2})
AADD(aCampos,{"COMISSAO"	,"N"	,012,2})
AADD(aCampos,{"MARGEM"		,"N"	,012,2})
AADD(aCampos,{"TOTAL"		,"N"	,012,2})
AADD(aCampos,{"CODISS"		,"C"	,TamSX3("D1_CODISS")[1],0})
AADD(aCampos,{"FORNEC"		,"C"	,TamSX3("D1_FORNECE")[1],0})
AADD(aCampos,{"LOJA"		,"C"	,TamSX3("D1_LOJA")[1],0})
AADD(aCampos,{"FILIAL"		,"C"	,FWGETTAMFILIAL,0})
AADD(aCampos,{"TIPO"		,"C"	,010,0})
AADD(aCampos,{"TOTALD1"		,"N"	,012,2})
AADD(aCampos,{"IMPORT"		,"N"	,012,2})
cArq010	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cArq010,"ENT",.T.,.F.)
cIndxTemp1:=Substr(CriaTrab(NIL,.F.),1,7)+"1"
cIndxTemp2:=Substr(CriaTrab(NIL,.F.),1,7)+"2"
cChave:="NFISCAL+SERIE+PRODUTO+FILIAL"
IndRegua("ENT",cIndxTemp1,cChave,,,"Gerando Arquivo Transfer Price - Entradas") //"Buscando Nts.Canceladas..."
dbClearIndex()
cChave:="PRODUTO+NFISCAL+SERIE+FILIAL"
IndRegua("ENT",cIndxTemp2,cChave,,,"Gerando Arquivo Transfer Price - Entradas") //"Buscando Nts.Canceladas..."
dbClearIndex()
aAdd(aTrbs,{cArq010,"ENT"})
DbSelectArea("ENT")
dbSetIndex(cIndxTemp1+OrdBagExt())
dbSetIndex(cIndxTemp2+OrdBagExt())
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arquivo de Saidas   - Transfer Price ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos	:=	{}
AADD(aCampos,{"PRODUTO"		,"C"	,TamSX3("D2_COD")[1],0})
AADD(aCampos,{"NFISCAL"		,"C"	,TamSX3("F2_DOC")[1],0})
AADD(aCampos,{"SERIE"		,"C"	,003,0})
AADD(aCampos,{"DTVENDA"		,"D"	,008,0})
AADD(aCampos,{"DESCCLI"		,"C"	,060,0})
AADD(aCampos,{"QUANTIDADE"	,"N"	,TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]})
AADD(aCampos,{"PRECOUNIT"	,"N"	  ,TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2]})  // ,012,2})
AADD(aCampos,{"DESCONTO"	,"N"	,012,2})
AADD(aCampos,{"ICMS"		,"N"	,012,2})
AADD(aCampos,{"PIS"			,"N"	,012,2})
AADD(aCampos,{"COFINS"		,"N"	,012,2})
AADD(aCampos,{"COMISSAO"	,"N"	,012,2})
AADD(aCampos,{"MARGEM"		,"N"	,012,2})
AADD(aCampos,{"TOTAL"		,"N"	,012,2})
AADD(aCampos,{"CODISS"		,"C"	,TamSX3("D2_CODISS")[1],0})
AADD(aCampos,{"CLIENTE"		,"C"	,TamSX3("D2_CLIENTE")[1],0})
AADD(aCampos,{"LOJA"		,"C"	,TamSX3("D2_LOJA")[1],0})
AADD(aCampos,{"MEDIA"		,"N"	,012,2})
AADD(aCampos,{"PORCEN"		,"N"	,012,2})
AADD(aCampos,{"METODO"		,"C"	,002,0})
AADD(aCampos,{"FILIAL"		,"C"	,FWGETTAMFILIAL,0})
AADD(aCampos,{"TIPO"		,"C"	,010,0})
AADD(aCampos,{"QUANTUNI"	,"N"	,012,2})
AADD(aCampos,{"TOTUNI"		,"N"	,012,2})
AADD(aCampos,{"IMPOSTOS"	,"N"	,012,2})
cArq020	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cArq020,"SAI",.T.,.F.)
cIndxTemp1:=Substr(CriaTrab(NIL,.F.),1,7)+"1"
cIndxTemp2:=Substr(CriaTrab(NIL,.F.),1,7)+"2"
cChave:="NFISCAL+SERIE+PRODUTO+METODO+FILIAL"
IndRegua("SAI",cIndxTemp1,cChave,,,"Gerando Arquivo Transfer Price - Saidas") //"Buscando Nts.Canceladas..."
dbClearIndex()
cChave:="PRODUTO+NFISCAL+SERIE+METODO+FILIAL"
IndRegua("SAI",cIndxTemp2,cChave,,,"Gerando Arquivo Transfer Price - Saidas") //"Buscando Nts.Canceladas..."
dbClearIndex()
aAdd(aTrbs,{cArq020,"SAI"})
DbSelectArea("SAI")
dbSetIndex(cIndxTemp1+OrdBagExt())
dbSetIndex(cIndxTemp2+OrdBagExt())
dbSetOrder(1)

Return(aTrbs)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ R933SldIni  º Autor ³Flavio Luiz Vicco   º Data ³ 01/04/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo saldo inicial p/ produtos SEM entradas no periodo. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cProd     => caract => Codigo Produto                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lRet      => logico =>                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R933SldIni(cProd,cLocal,dDataDe,dDataAte)
Local aArea := GetArea()
Local lRet  := .F.
Local cChv  := ""
Local cDoc  := Space(TamSx3("D1_DOC")[1])
Local cSer  := Space(TamSx3("D1_SERIE")[1])

SB9->(dbseek(xFilial("SB9")+cProd+cLocal+DTOS(dDataDe)))
SB9->(dbSkip(-1))
If SB9->(!EOF() .And. B9_FILIAL+B9_COD+B9_LOCAL==xFilial("SB9")+cProd+cLocal)
	lRet := .T.
	cChv := cDoc+cSer+cProd
	If ENT->(dbseek(cChv))
		RecLock("ENT",.F.)
	Else
		RecLock("ENT",.T.)
		ENT->FILIAL  := cFilAnt
		ENT->TIPO    := "Estoque"
		ENT->DTAQUIS := SB9->B9_DATA
		ENT->NFISCAL := ""
		ENT->SERIE   := ""
		ENT->PRODUTO := cProd
	EndIf
	ENT->DESCFOR    := "Saldo inicial"
	ENT->QUANTIDADE := SB9->B9_QINI
	ENT->PRECOUNIT  := (SB9->B9_VINI1/SB9->B9_QINI)
	ENT->ADICAO     := 0
	ENT->DESCONTO   := 0
	ENT->ICMS       := 0
	ENT->PIS        := 0
	ENT->COFINS     := 0
	ENT->COMISSAO   := 0
	ENT->MARGEM     := 0
	ENT->TOTAL      := SB9->B9_VINI1
	ENT->CODISS     := ""
	ENT->FORNEC     := ""
	ENT->LOJA       := ""
	MsUnlock()
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ R933Comiss  º Autor ³Flavio Luiz Vicco   º Data ³ 25/03/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo da comissao proporcional                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCliente  => caract => Codigo cliente                      º±±
±±º          ³ cLoja     => caract => Loja cliente                        º±±
±±º          ³ cDoc      => caract => Nota Fiscal Saida                   º±±
±±º          ³ cSerie    => caract => Serie                               º±±
±±º          ³ nValBrut  => numero => valor total da nota                 º±±
±±º          ³ nValItem  => numero => valor item da nota                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ nComissao => numero => Valor comissao proporcional         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R933Comiss(cCliente,cLoja,cDoc,cSerie,nValBrut,nValItem)
Local aArea     := GetArea()
Local cAliasCom := ""
Local nComissao := 0

If nValBrut > 0 
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			//-- Calculo comissao proporcional
			cAliasCom := GetNextAlias()
			BeginSql Alias cAliasCom
				SELECT SUM(SE3.E3_COMIS) * (%Exp:nValItem% / %Exp:nValBrut%) AS COMISSAO
				FROM %table:SE3% SE3  
				WHERE SE3.E3_FILIAL= %xFilial:SD1%
				AND SE3.E3_CODCLI  = %Exp:cCliente%
				AND SE3.E3_LOJA    = %Exp:cLoja%
				AND SE3.E3_PREFIXO = %Exp:cSerie%
				AND SE3.E3_NUM     = %Exp:cDoc%
				AND SE3.%NotDel%
			EndSql
			If !(cAliasCom)->(EOF())
				nComissao := (cAliasCom)->COMISSAO
			EndIf
			(cAliasCom)->(dbCloseArea())
		EndIf
	#ENDIF
EndIf	
RestArea(aArea)
Return nComissao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ R933VerComp º Autor ³Mauro A. Gonçalves  º Data ³ 23/08/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Custo do insumo importado e percentual de participacao     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cProduto => Codigo produto                                 º±±
±±º          ³ cProduto => Data inicial periodo                           º±±
±±º          ³ cProduto => Data final periodo                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ [1] => Componente importado (.T.)                          º±±
±±º          ³ [2] => Media entrada no periodo                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R933VerComp(cProduto,dDataDe,dDataAte)
Local aArea     := GetArea()
Local nMediaImp := 0
Local nMediaNac := 0
Local cAliasIns := ""

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		//-- Calculo do preco medio dos insumos importados
		cAliasIns := GetNextAlias()
		BeginSql Alias cAliasIns
			SELECT SUM(D1_VUNIT)/COUNT(*) * MAX(G1_QUANT) AS MEDIA
			FROM %table:SD1% SD1
			INNER JOIN %table:SG1% SG1 ON G1_FILIAL = %xFilial:SG1% AND G1_COMP=D1_COD AND G1_COD=%Exp:cProduto% AND SG1.%NotDel%
			INNER JOIN %table:SB1% SB1 ON B1_FILIAL = %xFilial:SB1% AND B1_COD =D1_COD AND B1_ORIGEM IN ('1','6') AND SB1.%NotDel%
			WHERE D1_FILIAL = %xFilial:SD1% AND
			D1_DTDIGIT >= %Exp:Dtos(dDataDe)% AND
			D1_DTDIGIT <= %Exp:Dtos(dDataAte)% AND
			D1_TIPO <> 'D' AND
			D1_QUANT > 0 AND // Notas com quantidade = 0 sao complementos de importacao e nao sao consideradas no calculo
			SD1.%NotDel%
		EndSql
		
		If !(cAliasIns)->(EOF())
			nMediaImp := (cAliasIns)->MEDIA
		EndIf
		(cAliasIns)->(dbCloseArea())
		//-- Calculo do preco medio dos insumos nacionais (caso exista insumos importados)
		If nMediaImp > 0
			cAliasIns := GetNextAlias()
			BeginSql Alias cAliasIns
				SELECT SUM(D1_VUNIT)/COUNT(*) * MAX(G1_QUANT) AS MEDIA
				FROM %table:SD1% SD1
				INNER JOIN %table:SG1% SG1 ON G1_FILIAL = %xFilial:SG1% AND G1_COMP=D1_COD AND G1_COD=%Exp:cProduto% AND SG1.%NotDel%
				INNER JOIN %table:SB1% SB1 ON B1_FILIAL = %xFilial:SB1% AND B1_COD =D1_COD AND NOT B1_ORIGEM IN ('1','6') AND SB1.%NotDel%
				WHERE D1_FILIAL = %xFilial:SD1% AND
				D1_DTDIGIT >= %Exp:Dtos(dDataDe)% AND
				D1_DTDIGIT <= %Exp:Dtos(dDataAte)% AND
				D1_TIPO <> 'D' AND
				D1_QUANT > 0 AND // Notas com quantidade = 0 sao complementos de importacao e nao sao consideradas no calculo
				SD1.%NotDel%
			EndSql
			If !(cAliasIns)->(EOF())
				nMediaNac := (cAliasIns)->MEDIA
			EndIf
			(cAliasIns)->(dbCloseArea())
		EndIf
	EndIf
#ENDIF
RestArea(aArea)
Return {nMediaImp>0,nMediaImp,nMediaImp/(nMediaImp+nMediaNac)*100}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ R933CustMed º Autor ³Beatriz Scarpa      º Data ³ 03/11/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Custo Medio como Preco Praticado						      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aCustMed => Array contendo o produto que possui apenas     º±±
±±º          ³ saidas no período				                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ [1] => Se deve usar o custo medio (.T)                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R933CustMed(cProd, cLocPad)

Local aArea      := GetArea()
Local cAliasCust := ""
Local lRet		 := .F.

Default cProd 	 := ""
Default cLocPad  := ""

#IFDEF TOP
    If (TcSrvType ()<>"AS/400")
		cAliasCust := GetNextAlias()
		BeginSql Alias cAliasCust
			
			COLUMN DTEST AS DATE
			
			SELECT SB9.B9_COD AS PROD, SB9.B9_LOCAL AS LOCPAD, SB9.B9_CM1 AS CUSTO, SB9.B9_DATA AS DTEST
			FROM %table:SB9% SB9
			WHERE SB9.B9_FILIAL = %xFilial:SB9% AND 
			SB9.B9_COD = (%Exp:cProd%) AND
			SB9.B9_DATA = (SELECT MAX(SB9DT.B9_DATA) FROM %table:SB9% SB9DT WHERE SB9DT.B9_COD = (%Exp:cProd%)) AND
			SB9.%NotDel%		
		EndSql    
    EndIf
#ENDIF 

While !(cAliasCust)->(Eof())
    If (cAliasCust)->LOCPAD == cLocPad
    	lRet := .T.
		RecLock("ENT",.T.)
		ENT->FILIAL  	:= cFilAnt
		ENT->TIPO    	:= ""
		ENT->DTAQUIS 	:= (cAliasCust)->DTEST
		ENT->NFISCAL 	:= ""
		ENT->SERIE   	:= ""
		ENT->PRODUTO	:= (cAliasCust)->PROD
		ENT->TOTALD1	:= (cAliasCust)->CUSTO
		ENT->DESCFOR    := "Custo Medio"
		ENT->QUANTIDADE := 1
		ENT->PRECOUNIT  := (cAliasCust)->CUSTO
		ENT->ADICAO     := 0
		ENT->DESCONTO   := 0
		ENT->ICMS       := 0
		ENT->PIS        := 0
		ENT->COFINS     := 0
		ENT->COMISSAO   := 0
		ENT->MARGEM     := 0 
		ENT->IMPORT		:= 0
		ENT->TOTAL      := (cAliasCust)->CUSTO
		ENT->CODISS     := ""
		ENT->FORNEC     := ""
		ENT->LOJA       := ""	  
    EndIf
	MsUnlock()
    (cAliasCust)->(dbSkip())
EndDo

(cAliasCust)->(dbCloseArea())
RestArea(aArea)
Return lRet
