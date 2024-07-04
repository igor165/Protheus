#Include "TMSAF79.CH"
#Include "Protheus.ch"

Static lTMF79Cpo  := ExistBlock("TMF79CPO")	//-- Permite inclusão de novos campos no aCols
Static lTMF79Vld  := ExistBlock("TMF79VLD")	//-- Valida campos de usuário
Static lTMF79Rot  := ExistBlock("TMF79ROT")	//-- Permite a manipulação do vetor de rotas
Static lTMF79PAG  := ExistBlock("TMF79PAG") // Manipulação de aColsPag e exibição de tela de mais de um pagador.
Static aSemFix    := {}
Static aRotas     := {} //-- Vetor com as rotas da viagem
						//-- 1 - Número do contrato do cliente
						//-- 2 - Código do cliente
						//-- 3 - Loja do cliente
						//-- 4 - Vetor com os registros da rota
						//--     1 - Alias
						//--     2 - Recno
						//--     3 - Indica se possui negociação baseada em rateio (1=Sim / 2=Não)
						//--     4 - Indica se possui documento DT6 gerado (1=Sim / 2=Não)
						//--     5 - Indica se o registro possui codigo de negociação e serviço (1=Sim / 2=Não)
						//-- 5 - Tipo de KM
Static aLotes     := {} //-- Vetor com os lotes da viagem
						//--  1 - Número do contrato do cliente
						//--  2 - Vetor com as linhas do lote
						//--      1 - Sequencia que está no aCols
						//--  3 - Vetor com os registros do lote
						//--      1 - Alias
						//--      2 - Recno
						//--      3 - Código da negociação (Se alias for DT5 será de coleta / Se alias for DTC será de transferência/entrega)
						//--      4 - Serviço (Se alias for DT5 será de coleta / Se alias for DTC será de transferência/entrega)
						//--      5 - Documento novo? (1=Sim / 2=Não)
						//--      6 - Recno do DUD
						//--  4 - Indica se o lote é de rateio (1=Sim / 2=Não)
						//--  5 - Base de cálculo de rateio (DTP_BACRAT)
						//--  6 - Critério de cálculo de rateio (DTP_CRIRAT)
						//--  7 - Critério de proporção de rateio (DTP_PRORAT)
						//--  8 - Tabela de frete de rateio (DTP_TABRAT)
						//--  9 - Tipo da tabela de frete de rateio (DTP_TIPRAT)
						//-- 10 - Tabela alternativa de frete de rateio (DTP_TBARAT)
						//-- 11 - Tipo da tabela alternativa de frete de rateio (DTP_TPARAT)
						//-- 12 - Critério de devedor faltante (DTP_CRDVFA)
						//-- 13 - Critério de proporção do valor da coleta (DTP_CRDVDC)
						//-- 14 - Cliente do contrato (DTP_CLIDEV)
						//-- 15 - Loja do contrato (DTP_LOJDEV)
						//-- 16 - Negociação do contrato do cliente
						//-- 17 - Serviço do contrato do cliente
						//-- 18 - Serviço do TMS (1=Coleta / 2=Transferência / 3=Entrega)
						//-- 19 - Número do lote gerado
						//-- 20 - Lote novo? (1=Sim / 2=Não)
Static aInfoEnt   := {} //-- Vetor com as informações dos recnos de entrada
						//-- 1 - Alias
						//-- 2 - Recno
						//-- 3 - Código da Negociação
						//-- 4 - Serviço
						//-- 5 - Sequencia que está no aCols
						//-- 6 - Número do lote
						//-- 7 - Recno do DUD
Static aInfoSai   := {} //-- Vetor com as informações dos recnos de saida - Idem ao aInfoEnt
Static aHeaderWrk := {}
Static aColsWrk   := {}
Static aCpoVld    := {}	//-- Vetor com os campos que serão validados
						//-- 1 - Nome do campo
						//-- 2 - Tipo do campo
						//-- 3 - Tamanho do campo
						//-- 4 - Decimais do campo
						//-- 5 - Posição do campo dentro o aColsWrk
Static aRotOri    := {} //-- Vetor com as rotas originais da viagem
						//-- 1 - Código do cliente devedor
						//-- 2 - Loja do cliente devedor
						//-- 3 - Rota
						//-- 4 - Roteiro
						//-- 5 - Vetor com os pontos de passagem
						//--      1 - Filial de origem da viagem
						//--      2 - Número da viagem
						//--      3 - Código da rota
						//--      4 - Código do roteiro
						//--      5 - Código do cliente devedor
						//--      6 - Loja do cliente devedor
						//--      7 - Quilometragem do trecho
						//--      8 - Número do contrato do devedor
						//--      9 - Sequencia do roteiro
						//--     10 - Código do cliente do ponto de passagem
						//--     11 - Loja do cliente do ponto de passagem
						//--     12 - Sequencia de endereço do ponto de passagem
						//--     13 - Indica se tem rateio no ponto de passagem
						//--     14 - Indica se tem documento gerado no ponto de passagem
						//--     15 - Indica se valoriza o trecho
						//--     16 - Indica o tipo de operação do ponto (Coleta / Entrega / Coleta e Entrega / Ponto de Apoio)
						//--     17 - Data prevista de passagem
						//--     18 - Hora prevista de passagem
						//--     19 - Tipo de quilometragem
						//--     20 - Id Unico da linha 
						//--     21 - Data real de passagem
						//--     22 - Hora real de passagem
						//--     23 - Vetor com os registros dos pontos de passagem
						//--          1 - Alias do registro
						//--          2 - Recno
						

Static cSerTms := ""
Static cPrxSeq := StrZero(0,Len(DUD->DUD_SEQUEN))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF79Cols ³ Autor ³ Valdemar Roberto  ³ Data ³ 23.03.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta aCols de Mais de Um Pagador de Frete                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF79Cols(aExp01,cExp01,cExp02,cExp03,cExp04,cExp05,      ³±±
±±³          ³            cExp06,nExp01)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 := Vetor com os recnos                              ³±±
±±³          ³ cExp01 := Serviço do TMS 1-Coleta                          ³±±
±±³          ³                          2-Transferência                   ³±±
±±³          ³                          3-Entrega                         ³±±
±±³          ³ cExp02 := Serviço do TMS 1-Rodoviário                      ³±±
±±³          ³                          2-Aéreo                           ³±±
±±³          ³                          3-Internacional                   ³±±
±±³          ³ cExp03 := Tipo de Montagem 1-Incremental (a cada docto)    ³±±
±±³          ³                            2-Geral (todos doctos juntos)   ³±±
±±³          ³ cExp04 := Serviço adicional de coleta 1-Sim                ³±±
±±³          ³                                       2-Não                ³±±
±±³          ³ cExp05 := Filial de origem da viagem                       ³±±
±±³          ³ cExp06 := Número da viagem                                 ³±±
±±³          ³ nExp01 := Opção que está sendo usada na viagem             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF79Cols(aRegSel,cSerTMSCol,cTipTra,cTipo,cSerAdi,cFilOri,cViagem,nOpcx)
Local cColEnt    := ""
Local cCodNeg    := ""
Local cDesNeg    := ""
Local cServic    := ""
Local cDesSer    := ""
Local cSequen    := ""
Local cRegAnt    := ""
Local cPtoAnt    := ""
Local cLotNFc    := ""
Local cHorRea    := ""
Local dDatRea    := CToD("")
Local nCntFor1   := 0
Local nCntFor2   := 0
Local nCntFor3   := 0
Local nCntFor4   := 0
Local nLinha     := 0
Local nRegDUD    := 0
Local nCount     := 0
Local lLerCol    := .T.
Local lTemDoc    := .T.
Local lNewReg    := .T.
Local lSemRat    := .T.
Local aVetWrk    := {}
Local aAreas     := {DJJ->(GetArea()),DTW->(GetArea()),DUD->(GetArea()),DJF->(GetArea()),DDP->(GetArea()),DT6->(GetArea()),SX5->(GetArea()),;
					 DTP->(GetArea()),DDB->(GetArea()),SA1->(GetArea()),DF1->(GetArea()),GetArea()}
Local aCpoUsu    := {}
Local aCamposGrd := {"DF1_CLIDEV","DF1_LOJDEV","DF1_NOMDEV","AAM_CONTRT","DDC_CODNEG","DDC_DESNEG","DTC_SERVIC","DTC_DESSER","AAM_TIPFRE",;
					 "DTC_SERTMS","DTC_DESSVT","DTC_TIPTRA","DTC_DESTPT","DDA_TABFRE","DDA_TIPTAB","DDA_TABALT","DDA_TIPALT","DDA_BACRAT",;
					 "DDA_CRIRAT","DDA_DECRIR","DDA_PRORAT","DDA_DEPROR","DDA_ADIDOC","DDA_VALCOL","DDA_TIPOPE","DDA_CRDVFA","DDA_CRDVDC",;
					 "DDA_TIPOKM","DUD_SEQUEN","DTP_LOTNFC"}
Local aCamposVld := {"AAM_CONTRT","DTC_SERTMS","DDA_TABFRE","DDA_TIPTAB","DDA_TABALT","DDA_TIPALT","DDA_BACRAT","DDA_CRIRAT","DDA_DECRIR",;
					 "DDA_PRORAT","DDA_DEPROR","DDA_ADIDOC","DDA_VALCOL","DDA_TIPOPE","DDA_CRDVFA","DDA_CRDVDC","DDA_TIPOKM"}

DEFAULT aRegSel := {}
DEFAULT cSerTMSCol := ""
DEFAULT cTipTra := ""
DEFAULT cTipo   := "2"
DEFAULT cSerAdi := "2"
DEFAULT cFilOri := ""
DEFAULT cViagem := ""
DEFAULT nOpcx   := 3

cSerTms := cSerTMSCol
dbSelectArea("DTC")
dbSelectArea("DT6")

//-- Estas variáveis servem para retornar a descrição do campo por meio da função TMSValField
M->DTC_SERTMS := cSerTMS
M->DTC_TIPTRA := cTipTra

//-- Estas variáveis servem para que o sistema carregue os campos buscanco DDA e DDC
M->DDA_BACRAT := ""
M->DDA_CRIRAT := ""
M->DDA_PRORAT := ""
M->DDA_ADIDOC := 0
M->DDA_VALCOL := ""
M->DDA_TIPOPE := ""
M->DDA_CRDVFA := ""
M->DDA_CRDVDC := ""
M->DDA_TIPOKM := ""

DDA->(DbSetOrder(2)) //-- DDA_FILIAL+DDA_NCONTR+DDA_CODNEG+DDA_SERVIC
DT6->(DbSetOrder(1)) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
DDP->(DbSetOrder(2)) //-- DDP_FILIAL+DDP_NCONTR+DDP_CLIDEV+DDP_LOJDEV+DDP_CODNEG+DDP_SERVIC+DDP_ITEM
DF1->(DbSetOrder(3)) //-- DF1_FILIAL+DF1_FILDOC+DF1_DOC+DF1_SERIE
DUD->(DbSetOrder(1)) //-- DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_VIAGEM
DTW->(DbSetOrder(8)) //-- DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_CODCLI+DTW_LOJCLI+DTW_SEQUEN
DTP->(DbSetOrder(1)) //-- DTP_FILIAL+DTP_LOTNFC

//-- Permite a inclusão de campos no aHeader, e recebe a condição de validação do novo campo
If lTMF79Cpo
	aCpoUsu := ExecBlock("TMF79CPO",.F.,.F.,{1,aCamposGrd})
	If ValType(aCpoUsu) != "A"
		aCpoUsu := {}
	Endif
	For nCntFor1 := 1 To Len(aCpoUsu)
		If ValType(aCpoUsu[nCntFor1]) == "A"
			Aadd(aCamposGrd,aCpoUsu[nCntFor1,1])
			If ValType(aCpoUsu[nCntFor1,2]) == "L" .And. ValType(aCpoUsu[nCntFor1,2])
				Aadd(aCamposVld,aCpoUsu[nCntFor1,1])
			EndIf
		EndIf
	Next nCntFor1
EndIf

If cTipo == "2"
	aHeaderWrk := {}
	aColsWrk   := {}
EndIf

//-- Monta aHeader
If Empty(aHeaderWrk)
	For nCntFor1 := 1 To Len(aCamposGrd)
		Aadd(aHeaderWrk,{GetSx3Cache(aCamposGrd[nCntFor1],"X3_TITULO"),;
			GetSx3Cache(aCamposGrd[nCntFor1],"X3_CAMPO"),;
			GetSx3Cache(aCamposGrd[nCntFor1],"X3_PICTURE"),;
			GetSx3Cache(aCamposGrd[nCntFor1],"X3_TAMANHO"),;
			GetSx3Cache(aCamposGrd[nCntFor1],"X3_DECIMAL"),;
			GetSx3Cache(aCamposGrd[nCntFor1],"X3_VALID"),;
			GetSx3Cache(aCamposGrd[nCntFor1],"X3_USADO"),;
			GetSx3Cache(aCamposGrd[nCntFor1],"X3_TIPO"),;
			GetSx3Cache(aCamposGrd[nCntFor1],"X3_F3"),;
			GetSx3Cache(aCamposGrd[nCntFor1],"X3_CONTEXT"),;
			GetSx3Cache(aCamposGrd[nCntFor1],"X3_CBOX"),;
			GetSx3Cache(aCamposGrd[nCntFor1],"X3_RELACAO"),;
			"TMSF79Whe()"})
		If Ascan(aCamposVld,{|x| AllTrim(Upper(x)) == aCamposGrd[nCntFor1]}) > 0
			Aadd(aCpoVld,{GetSx3Cache(aCamposGrd[nCntFor1],"X3_CAMPO"),;
				GetSx3Cache(aCamposGrd[nCntFor1],"X3_TIPO"),;
				GetSx3Cache(aCamposGrd[nCntFor1],"X3_TAMANHO"),;
				GetSx3Cache(aCamposGrd[nCntFor1],"X3_DECIMAL"),;
				nCntFor1})
		EndIf
	Next nCntFor1
EndIf

If (nOpcx == 4 .OR. nOpcx == 2) .And. !Empty(cFilOri + cViagem)
	DJF->(DbSetOrder(1))
	DJJ->(DbSetOrder(1))
	If DJF->(DbSeek(xFilial("DJF") + cFilOri + cViagem))
		While DJF->(!Eof()) .And. DJF->(DJF_FILIAL + DJF_FILORI + DJF_VIAGEM) == xFilial("DJF") + cFilOri + cViagem
			cRegAnt := DJF->(DJF_CLIDEV + DJF_LOJDEV)
			Aadd(aRotOri,{DJF->DJF_CLIDEV,DJF->DJF_LOJDEV,DJF->DJF_ROTA,DJF->DJF_ROTEIR,{}})
			nCount := 0
			While DJF->(!Eof()) .And. DJF->(DJF_CLIDEV + DJF_LOJDEV) == cRegAnt
				dDatRea := CToD("")
				cHorRea := ""
				If DTW->(DbSeek(xFilial("DTW") + cFilOri + cViagem + DJF->(DJF_CLIENT + DJF_LOJA)))
					dDatRea := DTW->DTW_DATREA
					cHorRea := DTW->DTW_HORREA
				EndIf
				nCount += 1 
				Aadd(aRotOri[Len(aRotOri),5],{DJF->DJF_FILORI,;
												 DJF->DJF_VIAGEM,;
												 DJF->DJF_ROTA,;
												 DJF->DJF_ROTEIR,;
												 DJF->DJF_CLIDEV,;
												 DJF->DJF_LOJDEV,;
												 DJF->DJF_KM,;
												 DJF->DJF_NCONTR,;
												 DJF->DJF_SEQUEN,;
												 DJF->DJF_CLIENT,;
												 DJF->DJF_LOJA,;
												 DJF->DJF_SEQEND,;
												 DJF->DJF_RATEIO,;
												 DJF->DJF_DOCGER,;
												 DJF->DJF_VALTRE,;
												 DJF->DJF_TIPOPE,;
												 DJF->DJF_DATPRE,;
												 DJF->DJF_HORPRE,;
												 DJF->DJF_TIPOKM,;
												 DJF->DJF_IDLIN,;
												 dDatRea,;
												 cHorRea,{}})
				DJJ->(DbSeek(cPtoAnt := xFilial("DJJ") + DJF->(DJF_FILORI + DJF_VIAGEM + DJF_CLIDEV + DJF_LOJDEV + DJF_CLIENT + DJF_LOJA + DJF_SEQEND)))
				While DJJ->(!Eof()) .And. DJJ->(DJJ_FILIAL + DJJ_FILORI + DJJ_VIAGEM + DJJ_CLIDEV + DJJ_LOJDEV + DJJ_CLIENT + DJJ_LOJA + DJJ_SEQEND) == cPtoAnt
					&(DJJ->DJJ_TABELA + "->(DbSetOrder(" + DJJ->DJJ_INDICE + "))")
					If &(DJJ->DJJ_TABELA + "->(DbSeek(DJJ->DJJ_CHAVE))")
						Aadd(aRotOri[Len(aRotOri),5,nCount,23],{DJJ->DJJ_TABELA,&(DJJ->DJJ_TABELA + "->(Recno())")})
					EndIf
					DJJ->(DbSkip())
				EndDo
				DJF->(DbSkip())
			EndDo
		EndDo
	EndIf
EndIf

//-- Monta a Cols
If !Empty(cSerTMS)

	For nCntFor1 := 1 To Len(aRegSel)

		//-- Define o tipo de viagem, se deve considerar DTC ou DT5 e se já possui documento gerado
		cLotNFc := ""
		nRegDUD := 0
		cColEnt := cSerTMS
		If cSerTMS == "1" //-- Coleta
			lLerCol := .T.
			&("DT5->(DbGoTo(" + StrZero(aRegSel[nCntFor1,2],10) + "))")
			lTemDoc := .F.
			cCodNeg := DT5->DT5_CODNEG
			cServic := DT5->DT5_SERVIC
			If DUD->(DbSeek(xFilial("DUD") + DT5->(DT5_FILORI + DT5_NUMSOL) + "COL" + cFilOri + cViagem))
				cLotNFc := DUD->DUD_LOTE
				nRegDUD := DUD->(RecNo())
			EndIf
		Else //If cSerTMS == "3" .And. cSerAdi == "1" //-- Entrega com Serviço Adicional
			lLerCol := aRegSel[nCntFor1,1] == "DT5"
			&(Iif(lLerCol,"DT5","DTC") + "->(DbGoTo(" + StrZero(aRegSel[nCntFor1,2],10) + "))")
			If !lLerCol
				lTemDoc := DT6->( DbSeek(xFilial("DT6") + DTC->(DTC_FILDOC + DTC_DOC + DTC_SERIE)) ) .And. DTC->DTC_SERIE != "PED"
				cCodNeg := DTC->DTC_CODNEG
				cServic := DTC->DTC_SERVIC
				cLotNFc := DTC->DTC_LOTNFC
			Else
				lTemDoc := .F.
				If DT5->DT5_STATUS $ "34"
					cColEnt := "3"
				Else
					cColEnt := "1"
				EndIF
				If DF1->(DbSeek(xFilial("DF1") + DT5->(DT5_FILORI + DT5_NUMSOL) + "COL"))
					cCodNeg := DF1->DF1_CODNEG
					cServic := Iif(cColEnt == "1",DF1->DF1_SRVCOL,DF1->DF1_SERVIC)
				Else
					cCodNeg := DT5->DT5_CODNEG
					cServic := Iif(cColEnt == "1",DT5->DT5_SERVIC,DT5->DT5_SRVENT)
				EndIf
				If DUD->(DbSeek(xFilial("DUD") + DT5->(DT5_FILORI + DT5_NUMSOL) + "COL" + cFilOri + cViagem))
					cLotNFc := DUD->DUD_LOTE
					nRegDUD := DUD->(RecNo())
				EndIf
			EndIf
		EndIf

		M->DTC_SERTMS := cColEnt

		cDesNeg := Posicione("DDB",1,xFilial("DDB") + cCodNeg,"DDB_DESCRI")
		cDesSer := Tabela("L4",cServic,.F.)

		//-- Le as condiçoes contratuais do documento
		DDA->(DbSeek(xFilial("DDA") + Iif(lLerCol,DT5->(DT5_NCONTR + DT5_CODNEG + DT5_SERVIC),DTC->(DTC_NCONTR + DTC_CODNEG + DTC_SERVIC))))

		//-- Define se usa DDA e DDC
		TMSF79Sobe(Iif(lLerCol,DT5->DT5_NCONTR,DTC->DTC_NCONTR),;
				   Iif(lLerCol,DT5->DT5_CODNEG,DTC->DTC_CODNEG),;
				   Iif(lLerCol,DT5->DT5_SERVIC,DTC->DTC_SERVIC))

		//-- Se não possuir documento gerado inclui no aCols
		If !lTemDoc .And. (cColEnt == "3" .Or. (cColEnt == "1" .And. !Empty(cServic)))

			//-- Se já tiver nota fiscal digitada pega os dados do lote
			If !lLerCol
				If DTP->(DbSeek(xFilial("DTP") + DTC->DTC_LOTNFC))
					M->DDA_BACRAT := DTP->DTP_BACRAT
					M->DDA_CRIRAT := DTP->DTP_CRIRAT
					M->DDA_PRORAT := DTP->DTP_PRORAT
					M->DDA_CRDVFA := DTP->DTP_CRDVFA
					M->DDA_CRDVDC := DTP->DTP_CRDVDC
					If Empty(M->DDA_TIPOKM)
						M->DDA_TIPOKM := "1"
					EndIf
				EndIf
			EndIf

			lSemRat := .F. //--	M->DDA_BACRAT == "1" .Or. Empty(M->DDA_BACRAT)
			
			//-- Monta vetor de trabalho
			aVetWrk := {Iif(lSemRat,Space(TamSX3("DT5_CLIDEV")[1]),Iif(lLerCol,DT5->DT5_CLIDEV,DTC->DTC_CLICAL)),;
						Iif(lSemRat,Space(TamSX3("DT5_LOJDEV")[1]),Iif(lLerCol,DT5->DT5_LOJDEV,DTC->DTC_LOJCAL)),;
						Iif(lSemRat,Upper(STR0015)                ,Posicione("SA1",1,xFilial("SA1") + Iif(lLerCol,DT5->(DT5_CLIDEV + DT5_LOJDEV),DTC->(DTC_CLICAL + DTC_LOJCAL)),"A1_NOME")),;
						Iif(lSemRat,Space(TamSX3("DT5_NCONTR")[1]),Iif(lLerCol,DT5->DT5_NCONTR,DTC->DTC_NCONTR)),;
						Iif(lSemRat,Space(TamSX3("DT5_CODNEG")[1]),cCodNeg),;
						Iif(lSemRat,Space(TamSX3("DDB_DESCRI")[1]),cDesNeg),;
						Iif(lSemRat,Space(TamSX3("DT5_SERVIC")[1]),cServic),;
						Iif(lSemRat,Space(TamSX3("DC5_DESSER")[1]),cDesSer),;
						Iif(lLerCol,DT5->DT5_TIPFRE,DTC->DTC_TIPFRE),;
						cColEnt,;
						TMSValField("M->DTC_SERTMS",.F.),;
						cTipTra,;
						TMSValField("M->DTC_TIPTRA",.F.),;
						Iif(lLerCol,DDA->DDA_TABFRE,DTP->DTP_TABRAT),;
						Iif(lLerCol,DDA->DDA_TIPTAB,DTP->DTP_TIPRAT),;
						Iif(lLerCol,DDA->DDA_TABALT,DTP->DTP_TBARAT),;
						Iif(lLerCol,DDA->DDA_TIPALT,DTP->DTP_TPARAT),;
						M->DDA_BACRAT,;
						M->DDA_CRIRAT,;
						TMSValField("M->DDA_CRIRAT",.F.),;
						M->DDA_PRORAT,;
						TMSValField("M->DDA_PRORAT",.F.),;
						M->DDA_ADIDOC,;
						M->DDA_VALCOL,;
						M->DDA_TIPOPE,;
						M->DDA_CRDVFA,;
						M->DDA_CRDVDC,;
						M->DDA_TIPOKM,;
						"",;
						cLotNFc}

			//-- Permite a inclusão de campos no aCols
			If lTMF79Cpo
				aCpoUsu := ExecBlock("TMF79CPO",.F.,.F.,{2,aVetWrk})
				If ValType(aCpoUsu) == "A"
					aVetWrk := AClone(aCpoUsu)
				Endif
			EndIf
	
			Aadd(aVetWrk,.F.)

			If M->DDA_PRORAT == "A" .And. !DDP->(DbSeek(xFilial("DDP") + aVetWrk[4] + aVetWrk[1] + aVetWrk[2] + aVetWrk[5] + aVetWrk[7]))
				AAdd(aSemFix,{ STR0001 + aVetWrk[1] + "/" + aVetWrk[2] + STR0002 + aVetWrk[4] + ;  
                             STR0003 + aVetWrk[5] + ; 
                             STR0004 + aVetWrk[7] + ".","00",""}) //"O cliente: " ### ", do contrato: "###", não possui percentual de rateio fixo configurado para a negociação: "###" e serviço: " 
			EndIf
	
			//-- Avalia entrada de nova linha e montagem do vetor aInfoEnt		
			If TMSF79Aval(1,Aclone(aVetWrk),,,@cSequen,.T.)
				cPrxSeq := Soma1(cPrxSeq)
				cSequen := cPrxSeq
				aVetWrk[Len(aVetWrk) - 2] := cSequen
				Aadd(aColsWrk,Aclone(aVetWrk))
			EndIf
			Aadd(aInfoEnt,{aRegSel[nCntFor1,1],aRegSel[nCntFor1,2],aVetWrk[5],aVetWrk[7],cSequen,cLotNFc,nRegDUD})
		EndIf
		
		//-- Montagem do vetor aRotas - Quando existir documento o registro também entra no vetor
		If Len(aRotOri) > 0 
			Begin Sequence
			lNewReg := .T.
			For nCntFor2 := 1 To Len(aRotOri)
				For nCntFor3 := 1 To Len(aRotOri[nCntFor2,5])
					For nCntFor4 := 1 To Len(aRotOri[nCntFor2,5,nCntFor3,23])
						If Len(aRotOri[nCntFor2,5,nCntFor3,23]) > 0
							If aRotOri[nCntFor2,5,nCntFor3,23,nCntFor4,1] == aRegSel[nCntFor1,1] .And. aRotOri[nCntFor2,5,nCntFor3,23,nCntFor4,2] == aRegSel[nCntFor1,2]
								lNewReg := .F.
								Break
							EndIf
						EndIf
					Next nCntFor4
				Next nCntFor3
			Next nCntFor2
			
			End Sequence
		EndIf
		
		If lNewReg
			If (nLinha := Ascan(aRotas,{|x| x[1] == Iif(lLerCol,DT5->DT5_NCONTR,DTC->DTC_NCONTR)})) > 0
				Aadd(aRotas[nLinha,4],{aRegSel[nCntFor1,1],aRegSel[nCntFor1,2],Iif(M->DDA_BACRAT == "1","2","1"),;
										Iif(lTemDoc,"1","2"),Iif(Empty(cCodNeg) .Or. Empty(cServic),"2","1")})
			Else
				Aadd(aRotas,{Iif(lLerCol,DT5->DT5_NCONTR,DTC->DTC_NCONTR),;
							 Iif(lLerCol,DT5->DT5_CLIDEV,DTC->DTC_CLICAL),;
							 Iif(lLerCol,DT5->DT5_LOJDEV,DTC->DTC_LOJCAL),;
							 {{aRegSel[nCntFor1,1],aRegSel[nCntFor1,2],Iif(M->DDA_BACRAT == "1","2","1"),;
							 Iif(lTemDoc,"1","2"),Iif(Empty(cCodNeg) .Or. Empty(cServic),"2","1")}},M->DDA_TIPOKM})
			EndIf
			
			// Adiciona a nova posição no array de alteração caso a mesma não exista
			If Len(aRotOri) > 0
			 	If aScan(aRotOri,{ |x|  x[1] == Iif(lLerCol,DT5->DT5_CLIDEV,DTC->DTC_CLICAL) .AND. x[2] == Iif(lLerCol,DT5->DT5_LOJDEV,DTC->DTC_LOJCAL)  } ) <= 0
					AADD(aRotOri,{Iif(lLerCol,DT5->DT5_CLIDEV,DTC->DTC_CLICAL),Iif(lLerCol,DT5->DT5_LOJDEV,DTC->DTC_LOJCAL),"","",{}})
				EndIf
			EndIf
			
		EndIf
		
    Next nCntFor1

EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return {Aclone(aHeaderWrk),Aclone(aColsWrk)}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF79Tela ³ Autor ³ Valdemar Roberto  ³ Data ³ 11.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe tela de pagadores de frete                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF79Tela(aExp01,aExp02,lExp01,lExp02,cExp01,nExp01)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 := aHeader                                          ³±±
±±³          ³ aExp02 := aCols                                            ³±±
±±³          ³ lExp01 := Indica se irá exibir tela                        ³±±
±±³          ³ cExp01 := Filial de origem da viagem                       ³±±
±±³          ³ cExp02 := Número da viagem                                 ³±±
±±³          ³ nExp01 := Opção que está sendo usada na viagem             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Retorno   ³ aRet :=                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF79Tela(aHeaderPag,aColsPag,lTela,cFilOri,cViagem,nOpcx,cSerTms,cSrvAdc)
Local aRet     := Array(6)
Local aInfo    := {}
Local aPosObj  := {}
Local aObjects := {}
Local aSize    := MsAdvSize(.T.)
Local aButtons := {}
Local aAlter   := {}
Local aAreas   := {GetArea()}
Local aRotUsu  := {}
Local cNegSai  := ""
Local cSrvSai  := ""
Local cLotSai  := ""
Local nOpca    := 0
Local nCntFor1 := 0
Local nCntFor2 := 0
Local nLinAtu  := 0
Local lPagPe   := .F.

Local cQuery    := ""
Local cAliasDUD := ""
Local lAltServ  := .T.
Local nCntFor3  := 0
Local aNotasLot := {}
Local aMsgErr   := {}

Local cFunction	:= "TMSAF79"

Private Inclui  := .F.
Private oDlgPag
Private oGetPag
Private lIsTMSF79 := .T.

DEFAULT lTela   := .T. 
DEFAULT cFilOri := ""
DEFAULT cViagem := ""
DEFAULT nOpcx   := 3
DEFAULT cSerTms := ""
DEFAULT cSrvAdc := ""

If lTela
	
	If  (Len(aColsPag) > 1 .AND. ( cSerTms == "1" .OR.( cSerTms == "3" .AND.( IsInCallStack("TMSAF76") .OR. cSrvAdc == "1" ) ) ) )
		lTela := .T.		
	Else
		lTela := .F.
	EndIf
EndIf

//-- Permite exibir tela mesmo sem necessidade somente na inclusão
If lTMF79PAG
	lPagPe := ExecBlock("TMF79PAG",.F.,.F.,{aRetPag})
	If ValType(lPagPe) == "L"
		lTela := lPagPe
	Endif
EndIf

//-- Analisa necessidade de exibição da tela na alteração da viagem
If lTela .And. nOpcx == 4 .And. !Empty(cFilOri + cViagem)

	//-- Analise da necessidade de criação de novo lote por entrar negociações diferentes das já existentes e carrega lotes já existentes
	cAliasDUD := GetNextAlias()
	cQuery := "SELECT COUNT(*) QTDLOT "
	cQuery += "  FROM (SELECT COUNT(DUD_LOTE) QTDE_LOTE "
	cQuery += "          FROM " + RetSqlName("DUD") + " DUD "
	cQuery += "         WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery += "           AND DUD_FILORI = '" + cFilOri + "' "
	cQuery += "           AND DUD_VIAGEM = '" + cViagem + "' "
	cQuery += "           AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += "         GROUP BY DUD_LOTE) " + cAliasDUD
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.T.,.T.)

	lTela := Len(aColsPag) > (cAliasDUD)->QTDLOT
	
	(cAliasDUD)->(DbCloseArea())
	RestArea(aAreas[Len(aAreas)])

EndIf

//-- Mapa do vetor aRet
//-- 1 - Opção de saída do usuário
//-- 2 - Vetor com informações de entrada
//-- 3 - Vetor com informações de saída
//-- 4 - Vetor com os lotes a serem criados
//-- 5 - Vetor com as rotas a serem criadas
//-- 6 - Vetor com as rotas originais da viagem

//-- Estas variáveis servem para que o sistema carregue os campos buscanco DDA e DDC
M->DDA_BACRAT := ""
M->DDA_CRIRAT := ""
M->DDA_PRORAT := ""
M->DDA_ADIDOC := 0
M->DDA_VALCOL := ""
M->DDA_TIPOPE := ""
M->DDA_CRDVFA := ""
M->DDA_CRDVDC := ""
M->DDA_TIPOKM := ""

//-- Define campos alteráveis
Aadd(aAlter,"DDC_CODNEG")
Aadd(aAlter,"DTC_SERVIC")

aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],1,1}
AAdd(aObjects,{100,100,.T.,.T.})
aPosObj := MsObjSize(aInfo,aObjects,.T.)

If lTela
	DEFINE MSDIALOG oDlgPag TITLE STR0005 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL // "Pagadores de Frete" 
	
		oGetPag := MsNewGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],GD_UPDATE,"AllWaysTrue","AllWaysTrue",,aAlter,,Len(aColsPag),,,,oDlgPag,aHeaderPag,aColsPag)

	Activate MsDialog oDlgPag ON INIT EnchoiceBar(oDlgPag,{|| nOpca := 1,aColsPag := oGetPag:aCols,Iif(TMSF79Aval(2,,Aclone(aHeaderPag),Aclone(aColsPag),,.T.),oDlgPag:End(),nOpca := 0)},{|| nOpcA := 0,oDlgPag:End()},,aButtons)
	
	IIf(ExistFunc( 'FwPdLogUser' ), FwPdLogUser(cFunction),)

Else
	lRet := TMSF79Aval(2,,Aclone(aHeaderPag),Aclone(aColsPag),,.T.)
	If lRet
		nOpca := 1
	Else
		nOpca := 3
	EndIf
EndIf

//-- Indica no vetor de retorno da função qual foi a opção de saída do usuário
//-- Quando exibir tela poderá ser 1-Confirma ou 2-Cancela
//-- Quando não exibir tela poderá ser 1-Informações validadas ou 3-Informações não validadas
aRet[1] := nOpca

If nOpca == 1
	//-- Retira documentos do lote em embarques parciais
	If IsInCallStack("TMSAF76") .And. cSerTms $ "23"
		TMSF79Ret(@aColsPag)
	EndIf

	//-- Monta vetor com informações de saída e vetor dos lotes
	For nCntFor1 := 1 To Len(aInfoEnt)
		nLinAtu := Ascan(aColsPag,{|x| x[29] == aInfoEnt[nCntFor1,5]})
		cNegSai := aColsPag[nLinAtu,5]
		cSrvSai := aColsPag[nLinAtu,7]
		cLotSai := aColsPag[nLinAtu,30]
		Aadd(aInfoSai,{aInfoEnt[nCntFor1,1],aInfoEnt[nCntFor1,2],cNegSai,cSrvSai,aInfoEnt[nCntFor1,5],cLotSai,aInfoEnt[nCntFor1,7]})

		For nCntFor2 := 1 To Len(aLotes)
			If Ascan(aLotes[nCntFor2,2],{|x| x == aInfoEnt[nCntFor1,5]}) > 0
				Aadd(aLotes[nCntFor2,3],{aInfoEnt[nCntFor1,1],aInfoEnt[nCntFor1,2],cNegSai,cSrvSai,Iif(Empty(aInfoSai[nCntFor1,6]),"1","2"),;
										 aInfoEnt[nCntFor1,7]})
				If !Empty(aInfoSai[nCntFor1,6])
					aLotes[nCntFor2,19] := aInfoSai[nCntFor1,6]
					aLotes[nCntFor2,20] := "2"
				EndIf
			EndIf

			aNotasLot := {}
			For nCntFor3 := 1 To Len(aLotes[nCntFor2,3])
				If aLotes[nCntFor2,3,nCntFor3,1] == "DTC"
					&("DTC->(DbGoTo(" + StrZero(aLotes[nCntFor2,3,nCntFor3,2],10) + "))")
					If Ascan(aNotasLot,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == DTC->(DTC_CLIREM + DTC_LOJREM + DTC_NUMNFC + DTC_SERNFC + DTC_CODPRO)}) > 0
						AAdd(aMsgErr,{STR0028,"00",""})	//-- "Nota fiscal já existe no lote. O processo será interrompido."
					Else
						Aadd(aNotasLot,{DTC->DTC_CLIREM,DTC->DTC_LOJREM,DTC->DTC_NUMNFC,DTC->DTC_SERNFC,DTC->DTC_CODPRO})
					EndIf
				EndIf
			Next nCntFor3
		Next nCntFor2
	Next nCntFor1

	If !Empty(aMsgErr)
		TmsMsgErr(aMsgErr)
		aRet[1] := 3
		aRet[2] := aInfoEnt
		aRet[3] := {}
		aRet[4] := {}
		aRet[5] := {}
		aRet[6] := {}
	Else
		//-- Atualiza codneg, servic, e lotnfc
		TMSF79Atu(aInfoEnt,aInfoSai,@lAltServ)
		
		//-- Monta o vetor de retorno
		aRet[2] := aInfoEnt
		aRet[3] := aInfoSai
		aRet[4] := aLotes
		aRet[5] := aRotas
		aRet[6] := aRotOri
	EndIf
Else
	//-- Monta o vetor de retorno
	aRet[2] := aInfoEnt
	aRet[3] := {}
	aRet[4] := {}
	aRet[5] := {}
	aRet[6] := {}
EndIf

//-- Permite a manipulação do vetor de rotas
If lTMF79Rot
	aRotUsu := ExecBlock("TMF79ROT",.F.,.F.,{Aclone(aRotas)})
	If ValType(aRotUsu) == "A"
		aRotas := AClone(aRotUsu)
	Endif
EndIf

aRotOri    := {}
aRotas     := {}
aInfoEnt   := {}
aInfoSai   := {}
aHeaderWrk := {}
aColsWrk   := {}
aCpoVld    := {}
aSemFix    := {}
cSerTMS    := ""
cPrxSeq    := StrZero(0,Len(DUD->DUD_SEQUEN))

AEval(aAreas,{|x,y| RestArea(x) })

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF79Aval ³ Autor ³ Valdemar Roberto  ³ Data ³ 24.03.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Avalia se já existe negociação igual                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF79Aval(nExp01,aExp01,aExp02,aExp03,nExp02,lExp01)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 := Ação da função                                   ³±±
±±³          ³           1 - Valida a inserção de nova linha              ³±±
±±³          ³           2 - Valida as negociações do vetor               ³±±
±±³          ³ aExp01 := Vetor com a linha que será inserida              ³±±
±±³          ³ aExp02 := Vetor aHeader                                    ³±±
±±³          ³ aExp03 := Vetor aCols                                      ³±±
±±³          ³ nExp02 := Linha do aCols em que o agendamento está         ³±±
±±³          ³ lExp01 := Indica se irá exibir help                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet := Variável lógica                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF79Aval(nAcao,aVetWrk,aHeaderVld,aColsVld,cSequen,lExbHlp)
Local lRet      := .T.
Local lPrimeira := .T.
Local lRatFix   := .T.
Local lSemRat   := .T.
Local nCntFor1  := 0
Local nCntFor2  := 0
Local cLinVld   := ""
Local cLinCols  := ""
Local cCampo    := ""
Local cCliAnt   := ""
Local cTipoKm   := ""
Local cCtcAnt   := ""

DEFAULT nAcao      := 0
DEFAULT aVetWrk    := {}
DEFAULT aHeaderVld := {}
DEFAULT aColsVld   := {}
DEFAULT lExbHlp    := .T.

If nAcao == 1 //-- Valida a inserção de nova linha
	//-- Verifica se a nova linha não é com base em rateio
	lSemRat := aVetWrk[18] == "1" .Or. Empty(aVetWrk[18])

	//-- Monta string com a linha que está sendo carregada
	For nCntFor1 := 1 To Len(aCpoVld)
		If !lSemRat .Or. (lSemRat .And. !aCpoVld[nCntFor1,1] $ "AAM_CONTRT:DTC_SERTMS:DDA_BACRAT")
			cCampo := ""
			If aCpoVld[nCntFor1,2] == "C"
				cCampo := aVetWrk[aCpoVld[nCntFor1,5]]
			ElseIf aCpoVld[nCntFor1,2] == "N"
				cCampo := StrZero(aVetWrk[aCpoVld[nCntFor1,5]],aCpoVld[nCntFor1,3],aCpoVld[nCntFor1,4])
			ElseIf aCpoVld[nCntFor1,2] == "D"
				cCampo := DToS(aVetWrk[aCpoVld[nCntFor1,5]])
			EndIf
			cLinVld += cCampo
		EndIf
	Next nCntFor1

	//-- Monta string com as linhas do aCols
	For nCntFor1 := 1 To Len(aColsWrk)
		cLinCols := ""
		For nCntFor2 := 1 To Len(aCpoVld)
			//-- Verifica se a linha do aCols não é com base em rateio
			lSemRat := aColsWrk[nCntFor1,18] == "1" .Or. Empty(aColsWrk[nCntFor1,18])
			If !lSemRat .Or. (lSemRat .And. !aCpoVld[nCntFor2,1] $ "AAM_CONTRT:DTC_SERTMS:DDA_BACRAT")
				cCampo := ""
				If aCpoVld[nCntFor2,2] == "C"
					cCampo := aColsWrk[nCntFor1,aCpoVld[nCntFor2,5]]
				ElseIf aCpoVld[nCntFor2,2] == "N"
					cCampo := StrZero(aColsWrk[nCntFor1,aCpoVld[nCntFor2,5]],aCpoVld[nCntFor2,3],aCpoVld[nCntFor2,4])
				ElseIf aCpoVld[nCntFor2,2] == "D"
					cCampo := DToS(aColsWrk[nCntFor1,aCpoVld[nCntFor2,5]])
				EndIf
				cLinCols += cCampo
			EndIf
		Next nCntFor2
		
		//-- Valida Linha
		If cLinVld == cLinCols
			cSequen := StrZero(nCntFor1,Len(DUD->DUD_SEQUEN))
			lRet    := .F.
			Exit
		EndIf
	Next nCntFor1
ElseIf nAcao == 2 //-- Valida as negociações do vetor
	//-- Verifica se alguma linha tem rateio por % fixo
	lRatFix := Ascan(aColsVld,{|x| x[21] == "A"}) > 0

	//-- Verifica se existe algum cliente (loja) que está na viagem, mas não está configurado na tabela de percentual fixo (DDP), quando o critério
	//-- de rateio for do tipo "A"
	If !Empty(aSemFix)
		If lExbHlp
			TmsMsgErr(aSemFix)
		EndIf
		lRet := .F.
	EndIf

	If lRet
		If Ascan(aColsVld,{|x| Empty(x[5]) .And. x[10] != "1"}) > 0 .Or. Ascan(aColsVld,{|x| Empty(x[7]) .And. x[10] != "1"}) > 0
			If lExbHlp
				MsgAlert(STR0006 ,STR0007) //"Existem registros com a negociação e/ou serviço em branco."###"Atenção"
			EndIf
			lRet := .F.
		EndIf
	EndIf

	Begin Sequence
		
	If lRet
		aColsVld := ASort(aColsVld,,,{|x,y| x[4] + x[10] + x[14] + x[15] + x[16] + x[17] + x[18] + x[19] + x[21] + StrZero(x[23],aCpoVld[13,3],aCpoVld[13,4]) + x[24] + x[25] + x[26] + x[27] + x[30] < ;
											y[4] + y[10] + y[14] + y[15] + y[16] + y[17] + y[18] + y[19] + y[21] + StrZero(y[23],aCpoVld[13,3],aCpoVld[13,4]) + y[24] + y[25] + y[26] + y[27] + y[30]})
	
		aLotes   := {}
		
		nCntFor1 := 1
		While nCntFor1 <= Len(aColsVld)
			cTipoKm := aColsVld[nCntFor1,28]
			cCtcAnt := aColsVld[nCntFor1,4]

			While nCntFor1 <= Len(aColsVld) .And. cCtcAnt == aColsVld[nCntFor1,4]

				cCliAnt := aColsVld[nCntFor1,4] + aColsVld[nCntFor1,10]  + aColsVld[nCntFor1,14] + aColsVld[nCntFor1,15] + aColsVld[nCntFor1,16] + ;
						   aColsVld[nCntFor1,17] + aColsVld[nCntFor1,18] + aColsVld[nCntFor1,19] + aColsVld[nCntFor1,21] + ;
						   StrZero(aColsVld[nCntFor1,23],aCpoVld[13,3],aCpoVld[13,4]) + ;
						   aColsVld[nCntFor1,24] + aColsVld[nCntFor1,25] + aColsVld[nCntFor1,26] + aColsVld[nCntFor1,27] + aColsVld[nCntFor1,30]
		
				//-- Verifica se a linha posicionada do aCols não é com base em rateio
				lSemRat := aColsVld[nCntFor1,18] == "1" .Or. Empty(aColsVld[nCntFor1,18])
					
				Aadd(aLotes,{aColsVld[nCntFor1,4],;
							{aColsVld[nCntFor1,29]},;
							{},;
							Iif(aColsVld[nCntFor1,18] == "1","2","1"),;
							aColsVld[nCntFor1,18],;
							aColsVld[nCntFor1,19],;
							aColsVld[nCntFor1,21],;
							aColsVld[nCntFor1,14],;
							aColsVld[nCntFor1,15],;
							aColsVld[nCntFor1,16],;
							aColsVld[nCntFor1,17],;
							aColsVld[nCntFor1,26],;
							aColsVld[nCntFor1,27],;
							aColsVld[nCntFor1,01],;
							aColsVld[nCntFor1,02],;
							aColsVld[nCntFor1,05],;
							aColsVld[nCntFor1,07],;
							aColsVld[nCntFor1,10],;
							"",;
							"1"})
		
				cLinVld   := ""
				lPrimeira := .T.
				
				//-- Monta string com a linha posicionada do aCols
				For nCntFor2 := 1 To Len(aCpoVld)
					If aCpoVld[nCntFor2,1] != "DTP_LOTNFC"
						If lRatFix .Or. (!lRatFix .And. ((!lSemRat .AND. !(aCpoVld[nCntFor2,1] $ "AAM_CONTRT:DTC_SERTMS") ).Or. (lSemRat .And. aCpoVld[nCntFor2,1] $ "AAM_CONTRT:DTC_SERTMS:DDA_BACRAT")))
							cCampo := ""
							If aCpoVld[nCntFor2,2] == "C"
								cCampo := aColsVld[nCntFor1,aCpoVld[nCntFor2,5]]
							ElseIf aCpoVld[nCntFor2,2] == "N"
								cCampo := StrZero(aColsVld[nCntFor1,aCpoVld[nCntFor2,5]],aCpoVld[nCntFor2,3],aCpoVld[nCntFor2,4])
							ElseIf aCpoVld[nCntFor2,2] == "D"
								cCampo := DToS(aColsVld[nCntFor1,aCpoVld[nCntFor2,5]])
							EndIf
							cLinVld += cCampo
						EndIf
					EndIf
				Next nCntFor2
		
				While nCntFor1 <= Len(aColsVld) .And. cCliAnt == aColsVld[nCntFor1,4] + aColsVld[nCntFor1,10] + aColsVld[nCntFor1,14] + aColsVld[nCntFor1,15] + aColsVld[nCntFor1,16] + ;
																  aColsVld[nCntFor1,17] + aColsVld[nCntFor1,18] + aColsVld[nCntFor1,19] + aColsVld[nCntFor1,21] + ;
																  StrZero(aColsVld[nCntFor1,23],aCpoVld[13,3],aCpoVld[13,4]) + ;
																  aColsVld[nCntFor1,24] + aColsVld[nCntFor1,25] + aColsVld[nCntFor1,26] + aColsVld[nCntFor1,27] + aColsVld[nCntFor1,30]
		
					//-- Valida Linha
					If aColsVld[nCntFor1,28] != cTipoKm
						If lExbHlp
							MsgAlert(STR0008 ,STR0007) //"Existem tipos de km diferentes para o mesmo cliente."###"Atenção"
						EndIf
						lRet := .F.
						Break
					EndIf
	
					//-- Verifica se a proxima linha do aCols não é com base em rateio
					lSemRat := aColsVld[nCntFor1,18] == "1" .Or. Empty(aColsVld[nCntFor1,18])
		
					If lPrimeira
						lPrimeira := .F.
					Else
						Aadd(aLotes[Len(aLotes),2],aColsVld[nCntFor1,29])
		
						cLinCols := ""
		
						//-- Monta string com as proximas linhas do aCols para o mesmo contrato
						For nCntFor2 := 1 To Len(aCpoVld)
							If aCpoVld[nCntFor2,1] != "DTP_LOTNFC"
								If lRatFix .Or. (!lRatFix .And. ((!lSemRat .AND. !(aCpoVld[nCntFor2,1] $ "AAM_CONTRT:DTC_SERTMS") ).Or. (lSemRat .And. aCpoVld[nCntFor2,1] $ "AAM_CONTRT:DTC_SERTMS:DDA_BACRAT")))
									cCampo := ""
									If aCpoVld[nCntFor2,2] == "C"
										cCampo := aColsVld[nCntFor1,aCpoVld[nCntFor2,5]]
									ElseIf aCpoVld[nCntFor2,2] == "N"
										cCampo := StrZero(aColsWrk[nCntFor1,aCpoVld[nCntFor2,5]],aCpoVld[nCntFor2,3],aCpoVld[nCntFor2,4])
									ElseIf aCpoVld[nCntFor2,2] == "D"
										cCampo := DToS(aColsWrk[nCntFor1,aCpoVld[nCntFor2,5]])
									EndIf
									cLinCols += cCampo
								EndIf
							EndIf
						Next nCntFor2
			
						//-- Valida Linha
						If cLinVld != cLinCols
							If lExbHlp
								MsgAlert(STR0009,STR0007) // "Existem negociações diferentes."###"Atenção"
							EndIf
							lRet := .F.
							Break
						EndIf
					EndIf
		            
					nCntFor1 ++
				EndDo

			EndDo

		EndDo

	EndIf
	
	End Sequence
	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF79Sobe ³ Autor ³ Valdemar Roberto  ³ Data ³ 13.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca campos nas tabelas DDA, DDC                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF79Sobe(cExp01,cExp02,cExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 := Contrato do cliente                              ³±±
±±³          ³ aExp02 := Codigo da negociação                             ³±±
±±³          ³ aExp03 := Serviço de negociação                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TMSF79Sobe(cNContr,cCodNeg,cServic)

M->DDA_BACRAT := TmsSobServ("BACRAT",.T.,.T.,cNContr,cCodNeg,cServic,"1")
M->DDA_CRIRAT := TmsSobServ("CRIRAT",.T.,.T.,cNContr,cCodNeg,cServic,"1")
M->DDA_PRORAT := TmsSobServ("PRORAT",.T.,.T.,cNContr,cCodNeg,cServic,"1")
M->DDA_ADIDOC := TmsSobServ("ADIDOC",.T.,.T.,cNContr,cCodNeg,cServic,0)
M->DDA_VALCOL := TmsSobServ("VALCOL",.T.,.T.,cNContr,cCodNeg,cServic,"0")
M->DDA_TIPOPE := TmsSobServ("TIPOPE",.T.,.T.,cNContr,cCodNeg,cServic,"0")
M->DDA_CRDVFA := TmsSobServ("CRDVFA",.T.,.T.,cNContr,cCodNeg,cServic,"0")
M->DDA_CRDVDC := TmsSobServ("CRDVDC",.T.,.T.,cNContr,cCodNeg,cServic,"0")

M->DDA_TIPOKM := TmsSobServ("TIPOKM",.T.,.T.,cNContr,cCodNeg,cServic,"0",,.F.)

If Empty(M->DDA_TIPOKM)
	M->DDA_TIPOKM := "1"
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF79VCpo ³ Autor ³ Valdemar Roberto  ³ Data ³ 19.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida os campos da tela                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF79VCpo(cExp01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 := Campo                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF79VCpo(cCampo)
Local lRet    := .T.
Local cNContr := ""
Local cCodNeg := ""
Local cServic := ""
Local aAreas  := {DDA->(GetArea()),GetArea()}

Default cCampo := ReadVar()

DDA->(DbSetOrder(2)) //-- DDA_FILIAL+DDA_NCONTR+DDA_CODNEG+DDA_SERVIC

If !Empty(&(cCampo))
	If cCampo == "M->DDC_CODNEG"
		cNContr := GdFieldGet("AAM_CONTRT",n)
		cCodNeg := M->DDC_CODNEG
		cServic := GdFieldGet("DTC_SERVIC",n)
		DDB->(DbSetOrder(1))
		If !DDB->(DbSeek(xFilial("DDB") + cCodNeg))
			 MsgAlert(STR0010,STR0007) //-- "Negociação não localizada no contrato do cliente."###"Atenção"
			 lRet := .F.
		Else
		     DDA->(DbSetOrder(2))
		     If !DDA->(DbSeek(xFilial("DDA") + cNContr + cCodNeg))
			    MsgAlert(STR0010,STR0007) //-- "Negociação não localizada no contrato do cliente."###"Atenção"
			    lRet := .F.
		     EndIf
		 EndIf

	    GDFieldPut('DTC_SERVIC',CriaVar('DTC_SERVIC',.F.),n) // Limpa o campo Servico para que seja redigitado.
        GDFieldPut('DTC_DESSER',CriaVar('DTC_DESSER',.F.),n)

	ElseIf cCampo == "M->DTC_SERVIC"
		cNContr := GdFieldGet("AAM_CONTRT",n)
		cCodNeg := GdFieldGet("DDC_CODNEG",n)
		cServic := M->DTC_SERVIC
		DDA->(DbSetOrder(2))
		If !DDA->(DbSeek(xFilial("DDA") + cNContr + cCodNeg + cServic))
			MsgAlert(STR0012,STR0007) //-- "Serviço não localizado no contrato do cliente."###"Atenção"
			lRet := .F.
		EndIf

	EndIf

	If lRet
		TMSF79Sobe(cNContr,cCodNeg,cServic)
	
		GdFieldPut("DDA_TABFRE",DDA->DDA_TABFRE,n)
		GdFieldPut("DDA_TIPTAB",DDA->DDA_TIPTAB,n)
		GdFieldPut("DDA_TABALT",DDA->DDA_TABALT,n)
		GdFieldPut("DDA_TIPALT",DDA->DDA_TIPALT,n)
		GdFieldPut("DDA_BACRAT",M->DDA_BACRAT,n)
		GdFieldPut("DDA_CRIRAT",M->DDA_CRIRAT,n)
		GdFieldPut("DDA_DECRIR",TMSValField("M->DDA_CRIRAT",.F.),n)
		GdFieldPut("DDA_PRORAT",M->DDA_PRORAT,n)
		GdFieldPut("DDA_DEPROR",TMSValField("M->DDA_PRORAT",.F.),n)
		GdFieldPut("DDA_ADIDOC",M->DDA_ADIDOC,n)
		GdFieldPut("DDA_VALCOL",M->DDA_VALCOL,n)
		GdFieldPut("DDA_TIPOPE",M->DDA_TIPOPE,n)
		GdFieldPut("DDA_CRDVFA",M->DDA_CRDVFA,n)
		GdFieldPut("DDA_CRDVDC",M->DDA_CRDVDC,n)
		GdFieldPut("DDA_TIPOKM",M->DDA_TIPOKM,n)
	EndIf
EndIf

If lRet .And. lTMF79Vld
	lRet := ExecBlock("TMF79VLD",.F.,.F.,{cCampo})
	If ValType(lRet) != "L"
		lRet := .T.
	Endif
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF79Srv  ³ Autor ³ Valdemar Roberto  ³ Data ³ 19.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o F3 do serviço                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF79Srv()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF79Srv()

Local aItContrat := {}

TMSPesqServ("DTC",GdFieldGet("DF1_CLIDEV",n),GdFieldGet("DF1_LOJDEV",n),,,@aItContrat,,GdFieldGet("AAM_TIPFRE",n),,,.F.,;
				  GdFieldGet("DDA_TABFRE",n),GdFieldGet("DDA_TIPTAB",n),,.F.,,,,,,,,,,GdFieldGet("DDC_CODNEG",n))

Return Aclone(aItContrat)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF79Lot  ³ Autor ³ Valdemar Roberto  ³ Data ³ 10.05.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Criação dos lotes a partir do definido na rotina de        ³±±
±±³          ³ pagadores de frete                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF79Lot(aExp01,cExp01,cExp02,lExp01,cExp03)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 := Vetor com os lotes a serem abertos               ³±±
±±³          ³ cExp01 := Filial origem da viagem                          ³±±
±±³          ³ cExp02 := Viagem                                           ³±±
±±³          ³ lExp01 := Indica se exibe help                             ³±±
±±³          ³ cExp03 := Serviço do TMS do lote que será gerado           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF79Lot(aLotes,cFilOri,cViagem,lExbHlp,cSerTMS)
Local nCntFor1 := 0
Local nCntFor2 := 0
Local aCab     := {}
Local aAreas   := {DTP->(GetArea()),DUD->(GetArea()),DT5->(GetArea()),DTC->(GetArea()),DTQ->(GetArea()),GetArea()}
Local aDadRot  := {}
Local aMsgErr  := {}
Local lTMSCTe  := SuperGetMv("MV_TMSCTE",.F.,.F.)
Local lRet     := .T.
Local cNumLot  := ""
Local cMsgRet  := ""
Local cOrioRat := ""
Local cCalRat  := ""
Local nKm      := 0
Local cRota    := ""
Local cRoteiro := ""
Local lContinua := .T.
Private lMsErroAuto := .F.

Default aLotes  := {}
Default cFilOri := ""
Default cViagem := ""
Default lExbHlp := .T.
Default cSerTMS := ""

//-- Mapa do vetor com os dados complementares das rotas da viagem (aDadRot)
//-- 1 - Código da rota
//-- 2 - Código do roteiro
//-- 3 - Contrato do cliente
//-- 4 - Código do cliente
//-- 5 - Loja do cliente
//-- 6 - Região de origem do roteiro
//-- 7 - Região de cálculo do roteiro
//-- 8 - KM do roteiro

If !Empty(cFilOri) .And. !Empty(cViagem)

	DTQ->(DbSetOrder(1))
	If DTQ->(DbSeek(xFilial("DTQ") + cViagem))

		For nCntFor1 := 1 To Len(aLotes)
			
			lContinua := .T.
			
			If Empty(cSerTMS) .Or. aLotes[nCntFor1,18] == cSerTMS

				If F11RotRote(DTQ->DTQ_ROTA) // Verifica se a rota é de roteiro
					aDadRot := TMF10RtVge(cFilOri,cViagem,aLotes[nCntFor1,1],,)

					If Empty(aDadRot)
						AAdd(aMsgErr,{STR0013,"00",""}) //"Falha na localização dos dados do Roteiro."
						lContinua := .F.
					Else
						cOrioRat := aDadRot[1,6]
						cCalRat  := aDadRot[1,7]
						nKm      := aDadRot[1,8]
						cRota    := aDadRot[1,1]
						cRoteiro := aDadRot[1,2]
					EndIf
				Else
					cOrioRat := Posicione("DA8",1,FwxFilial("DA8")+DTQ->DTQ_ROTA,"DA8_CDRORI")
					cCalRat  := TMSRetRegD(cSerTMS,cFilOri,cViagem)
					nKm      := 0
					cRota    := DTQ->DTQ_ROTA
					cRoteiro := ""
				EndIf

				If lContinua
					If aLotes[nCntFor1,20] == "1"
				
						lMsErroAuto := .F.
						aCab        := {}
			
						//-- Cria lote			
						If aLotes[nCntFor1,18] == "1"	//-- Em lotes de coleta as quantidades já são definidas na tela de pagadores
							Aadd(aCab,{"DTP_QTDLOT",Len(aLotes[nCntFor1,3]),Nil})
							Aadd(aCab,{"DTP_QTDDIG",Len(aLotes[nCntFor1,3]),Nil})
							Aadd(aCab,{"DTP_TIPLOT","5",Nil})	//-- Lote de Coleta
						Else	//-- Em lotes que não são de coleta as quantidades são definidas na digitação da nota fiscal
							Aadd(aCab,{"DTP_QTDLOT",Val(Replicate('9',TamSX3("DTP_QTDLOT")[1])),Nil})
							Aadd(aCab,{"DTP_QTDDIG",0,Nil})
						EndIf
						Aadd(aCab,{"DTP_STATUS","1",Nil})	//-- Em aberto
						Aadd(aCab,{"DTP_VIAGEM",DTQ->DTQ_VIAGEM,Nil})
						If lTMSCTe .And. aLotes[nCntFor1,18] != "1"
							Aadd(aCab,{"DTP_TIPLOT","3",Nil})	//-- Lote Eletronico
						EndIf
						Aadd(aCab,{"DTP_RATEIO",aLotes[nCntFor1,4],Nil})
						Aadd(aCab,{"DTP_BACRAT",aLotes[nCntFor1,5],Nil})
						Aadd(aCab,{"DTP_CRIRAT",aLotes[nCntFor1,6],Nil})
						Aadd(aCab,{"DTP_PRORAT",aLotes[nCntFor1,7],Nil})
						Aadd(aCab,{"DTP_ORIRAT",cOrioRat ,Nil})
						Aadd(aCab,{"DTP_CALRAT",cCalRat  ,Nil})
						Aadd(aCab,{"DTP_TABRAT",aLotes[nCntFor1,8],Nil})
						Aadd(aCab,{"DTP_TIPRAT",aLotes[nCntFor1,9],Nil})
						Aadd(aCab,{"DTP_TBARAT",aLotes[nCntFor1,10],Nil})
						Aadd(aCab,{"DTP_TPARAT",aLotes[nCntFor1,11],Nil})
						Aadd(aCab,{"DTP_CRDVFA",Iif(Empty(aLotes[nCntFor1,12]),"0",aLotes[nCntFor1,12]),Nil})
						Aadd(aCab,{"DTP_CRDVDC",Iif(Empty(aLotes[nCntFor1,13]),"0",aLotes[nCntFor1,13]),Nil})
						Aadd(aCab,{"DTP_NCONTR",aLotes[nCntFor1,1],Nil})
						Aadd(aCab,{"DTP_KM"    ,nKm      ,Nil})
						Aadd(aCab,{"DTP_ROTA"  ,cRota    ,Nil})
						Aadd(aCab,{"DTP_ROTEIR",cRoteiro ,Nil})
						Aadd(aCab,{"DTP_CODNEG",aLotes[nCntFor1,16],Nil})
		 				Aadd(aCab,{"DTP_SERVIC",aLotes[nCntFor1,17],Nil})
									
						MsExecAuto({|x,y| cNumLot := TmsA170(x,y)},aCab,3)
				
						If lMsErroAuto
							MostraErro()
							cNumLot := Space(TamSX3("DTP_LOTNFC")[1])
						EndIf
		
						aLotes[nCntFor1,19] := cNumLot
							
						//-- Grava o lote nos registros
						If Empty(cNumLot)
							AAdd(aMsgErr,{ STR0014 + Iif(Empty(aLotes[nCntFor1,14]),STR0015, STR0016 + ;  
											aLotes[nCntFor1,14] + "/" + aLotes[nCntFor1,15] + STR0017 + aLotes[nCntFor1,16] + STR0018 + ; 
											aLotes[nCntFor1,17] + "."),"00",""}) //"Não foi possível criar o lote "###"sem rateio."###"para o cliente: "###", negociação: "###", serviço: "
						Else

							//-- Libera Registro Caso Receba Em 'Lock'
							DbSelectArea("DUD")
							If DUD->(IsLocked())
								DUD->(MsUnlock())
							EndIf
		
							//-- Limpa Lote Na Tabela DUD Para Regravação (Conforme Inclusão/Exclusão De Documentos na Alteração da Viagem)
							cMsgRet := TMSF79Dud( cNumLot )
							
							//-- Gera Msg Erro Caso Exista
							If !Empty(cMsgRet)
								AAdd(aMsgErr,{ cMsgRet ,"00",""})
							EndIf

							For nCntFor2 := 1 To Len(aLotes[nCntFor1,3])

								//-- Atualiza documentos
								&(aLotes[nCntFor1,3,nCntFor2,1] + "->(DbGoTo(" + StrZero(aLotes[nCntFor1,3,nCntFor2,2],10) + "))")
								RecLock(aLotes[nCntFor1,3,nCntFor2,1],.F.)
								If aLotes[nCntFor1,3,nCntFor2,1] == 'DT5'
									&(aLotes[nCntFor1,3,nCntFor2,1] + "->" + aLotes[nCntFor1,3,nCntFor2,1] + "_LOTE") := cNumLot
								Else
									&(aLotes[nCntFor1,3,nCntFor2,1] + "->" + aLotes[nCntFor1,3,nCntFor2,1] + "_LOTNFC") := cNumLot
								EndIf	
								&(aLotes[nCntFor1,3,nCntFor2,1] + "->" + "(MsUnlock())")

								//-- Atualiza o número do lote na DUD
								If aLotes[nCntFor1,3,nCntFor2,6] > 0
									&("DUD->(DbGoTo(" + StrZero(aLotes[nCntFor1,3,nCntFor2,6],10) + "))")
									RecLock("DUD",.F.)
									DUD->DUD_LOTE := cNumLot
									DUD->(MsUnlock())
								EndIf	
								
								//-- Atualiza a quantidade do lote quando tiver nota fiscal já digitada
/*								If aLotes[nCntFor1,3,nCntFor2,1] == "DTC"
									RecLock("DTP",.F.)
									DTP->DTP_QTDDIG ++
									DTP->(MsUnlock())
								EndIf*/
							Next nCntFor2
						EndIf
				
					Else
						//-- EAlberti -> Se Documentos Foram Incluídos Na Alteração Da Viagem, Atualiza o Numero Do Lote No DUD
						If IsInCallStack('TmsA144Grv') .Or. IsInCallStack('Tmsa310Lot')

							cNumLot := aLotes[nCntFor1,19]
							
							//-- Libera Registro Caso Receba Em 'Lock'
							DbSelectArea("DUD")
							If DUD->(IsLocked())
								DUD->(MsUnlock())
							EndIf
		
							//-- Limpa Lote Na Tabela DUD Para Regravação (Conforme Inclusão/Exclusão De Documentos na Alteração da Viagem)
							cMsgRet := TMSF79Dud( cNumLot )
							
							//-- Gera Msg Erro Caso Exista
							If !Empty(cMsgRet)
								AAdd(aMsgErr,{ cMsgRet ,"00",""})
							EndIf	
		
							//-- Atualiza o número do lote na DUD
							For nCntFor2 := 1 To Len(aLotes[nCntFor1,3])
								
								If aLotes[nCntFor1,3,nCntFor2,6] > 0
									//-- Reposiciona Na DUD
									&("DUD->(DbGoTo(" + StrZero(aLotes[nCntFor1,3,nCntFor2,6],10) + "))")
			
									RecLock("DUD",.F.)
									DUD->DUD_LOTE := cNumLot
									DUD->(MsUnlock())
								EndIf
		
							Next nCntFor2
						EndIf
							
						//-- Atualiza a quantidade do lote quando for alteração de viagem de coleta
						DTP->(DbSetOrder(1))
						If DTP->(DbSeek(xFilial("DTP") + aLotes[nCntFor1, 19]))
							RecLock("DTP",.F.)
							DTP->DTP_QTDLOT := Len(aLotes[nCntFor1, 3])
							DTP->DTP_QTDDIG := Len(aLotes[nCntFor1, 3])
							DTP->DTP_VIAGEM := cViagem
							DTP->DTP_ROTA   := cRota
							DTP->DTP_ROTEIR	:= cRoteiro
							If aLotes[nCntFor1, 6] == 'A'   //Criterio de Rateio Origem/Destino Viagem
								DTP->DTP_ORIRAT := cOrioRat
								DTP->DTP_CALRAT := cCalRat
								DTP->DTP_KM     := nKm
							EndIf	
							DTP->(MsUnlock())
						EndIf
					EndIf			

				EndIf

			EndIf
	
		Next nCntFor1
    
	Else
		AAdd(aMsgErr,{STR0019 + cViagem + ".","00",""}) //"Não foi possível encontrar a viagem "
	EndIf

Else
	AAdd(aMsgErr,{STR0020,"00",""}) //"A viagem não foi informada."
EndIf

If !Empty(aMsgErr)
	If lExbHlp
		TmsMsgErr(aMsgErr)
	EndIf
	lRet := .F.
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF79Whe  ³ Autor ³ Valdemar Roberto  ³ Data ³ 27.05.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define a condição de digitação dos campos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF79Whe(cExp01)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 := Campo                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF79Whe(cCampo)
Local lRet := .T.

DEFAULT cCampo := ReadVar()

If Type("oGetPag") == "O"
	If cCampo $ "M->DDC_CODNEG"
		If oGetPag:aCols[oGetPag:oBrowse:nAt,10] == "3" //- Trava a Edição do Campo quando registro se referênciar a uma entrega.
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ TMSF79Nota ³ Autor ³ Valdemar Roberto  ³ Data ³ 03.06.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Chama digitação da nota fiscal do cliente                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF79Nota(aExp01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 := Vetor com as lotes criados                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF79Nota(aLotCol)
Local nCntFor1 := 0
Local nCntFor2 := 0
Local aAreas   := {DTP->(GetArea()),DTC->(GetArea()),DF1->(GetArea()),DC5->(GetArea()),DDB->(GetArea()),SA1->(GetArea()),DT5->(GetArea()),GetArea()}
Local cQuery 	 := ""
Local cAlsDD9  := ""

DEFAULT aLotCol := {}

If !Empty(aLotCol)
	DF1->(DbSetOrder(3))
	For nCntFor1 := 1 To Len(aLotCol)
		If Ascan(aLotCol[nCntFor1,3],{|x| x[1] == "DT5"}) > 0 .And. aLotCol[nCntFor1,18] != "1"
			MsgAlert(STR0021 + AllTrim(Posicione("SA1",1,xFilial("SA1") + aLotCol[nCntFor1,14] + aLotCol[nCntFor1,15],"A1_NOME")) + ; 
					 STR0017 + AllTrim(Posicione("DDB",1,xFilial("DDB") + aLotCol[nCntFor1,16],"DDB_DESCRI")) + ; 
					 STR0018 + AllTrim(Tabela("L4",aLotCol[nCntFor1,17],.F.)) + STR0022, STR0007) //"Existem notas do cliente "###", negociação: "###", serviço: "###" que ainda não foram digitadas."###"Atenção"
			For nCntFor2 := 1 To Len(aLotCol[nCntFor1,3])
				If aLotCol[nCntFor1,3,nCntFor2,1] == "DT5"
					DT5->(DbGoTo(aLotCol[nCntFor1,3,nCntFor2,2]))
					If DF1->(DbSeek(xFilial("DF1") + DT5->(DT5_FILORI + DT5_NUMSOL) + "COL"))
						aPanAgeTms    := Array(9)

						aPanAgeTms[1] := "DTC"
						aPanAgeTms[2] := 0
						aPanAgeTms[3] := 3
						aPanAgeTms[4] := DF1->DF1_NUMAGE
						aPanAgeTms[5] := DF1->DF1_ITEAGE
						aPanAgeTms[6] := "TMSA050Mnt"
						aPanAgeTms[7] := aLotCol[nCntFor1,19]
						aPanAgeTms[8] := aLotCol[nCntFor1,16]
		 				aPanAgeTms[9] := aLotCol[nCntFor1,17]

						Inclui := .T.
						
						TMSA050()

						DTC->(DbSetOrder(8))
						If DTC->(DbSeek(xFilial("DTC") + DF1->(DF1_FILDOC + DF1_DOC)))
							
							// Altera a Programação 
							If IsInCallStack("TMSA146")
								cAlsDD9 := GetNextAlias()
								
								// Busca o Item da Programação referente ao documento 
								cQuery := " SELECT MAX(R_E_C_N_O_) RECNO                  "
								cQuery += " FROM " + RetSqlname('DD9') + " DD9 			  "
								cQuery += " WHERE DD9_FILIAL = '"+ FwxFilial("DD9") + " ' "
								cQuery += " 	  AND DD9_FILDOC = '"+ DF1->DF1_FILDOC +"'  "
								cQuery += " 	  AND DD9_DOC = '"+ DF1->DF1_DOC +"'    	  "
								cQuery += " 	  AND DD9_SERIE = 'COL'        				  "
								cQuery += " 	  AND DD9_CLIREM = '"+ DF1->DF1_CLIREM  +"' "
								cQuery += " 	  AND DD9_LOJREM = '"+ DF1->DF1_LOJREM   +"'"
								cQuery += " 	  AND D_E_L_E_T_ = ' '         				  "
								
								cQuery := ChangeQuery(cQuery)
								
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsDD9)
								If (cAlsDD9)->(!Eof())
									dbSelectArea("DD9")
									DD9->( dbGoTo((cAlsDD9)->RECNO) )
									
									// Ajusta os dados da nota digitada 
									RecLock('DD9',.F.)
									DD9->DD9_FILDOC := CriaVar('DD9_FILDOC',.F.)	
									DD9->DD9_DOC 	  := CriaVar('DD9_DOC',.F.)
									DD9->DD9_SERIE  := CriaVar('DD9_SERIE',.F.)
									DD9->DD9_NUMNFC := DTC->DTC_NUMNFC
									DD9->DD9_SERNFC := DTC->DTC_SERNFC
									DD9->DD9_CODPRO := DTC->DTC_CODPRO
									MsUnlock()	
								EndIf
							EndIf
							
							MsgAlert(STR0023,STR0007)	//"Nota inserida com sucesso."###"Atenção"
						Else //-- não confirmou a nota.
							MsgAlert(STR0024,STR0007)//"Nota não foi inserida."###"Atenção"
						EndIf
                    Else
						MsgAlert(STR0025+ DT5->DT5_FILORI + "/" + DT5->DT5_NUMSOL + STR0026,STR0007) //"A solicitação de coleta "###" não possui agendamento vinculado." ###"Atenção"
					EndIf
				EndIf
			Next nCntFor2
		EndIf
		//-- Atualiza a quantidade de notas do lote
		If !Empty(aLotCol[nCntFor1,19])
			DTP->(DbSetOrder(1))
			If DTP->(DbSeek(xFilial("DTP") + aLotCol[nCntFor1,19]))
				RecLock("DTP",.F.)
				DTP->DTP_QTDLOT := DTP->DTP_QTDDIG
				If DTP->DTP_STATUS != "4"
					DTP->DTP_STATUS := StrZero(2,Len(DTP->DTP_STATUS))
				EndIf
				DTP->(MsUnlock())
			EndIf
		EndIf
	Next nCntFor1
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ TMSF79Atu  ³ Autor ³ Valdemar Roberto  ³ Data ³ 06.09.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Atualiza negociação e serviço                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF79Atu(aExp01,aExp02)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 := Vetor com informações de entrada dos registros   ³±±
±±³          ³ aExp02 := Vetor com informações de saida dos registros     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF79Atu(aInfoEnt,aInfoSai,lAltServ)
Local nCntFor1 := 0
Local aAreas   := {DTP->(GetArea()),DT5->(GetArea()),DTC->(GetArea()),DF1->(GetArea()),GetArea()}

DEFAULT aInfoEnt := {}
DEFAULT aInfoSai := {}
DEFAULT lAltServ := .F.

DTP->(DbSetOrder(1))

For nCntFor1 := 1 To Len(aInfoEnt)

	If (aInfoEnt[nCntFor1,3] != aInfoSai[nCntFor1,3] .Or. aInfoEnt[nCntFor1,4] != aInfoSai[nCntFor1,4] .Or. aInfoEnt[nCntFor1,6] != aInfoSai[nCntFor1,6])
		&(aInfoSai[nCntFor1,1] + "->(DbGoTo(" + StrZero(aInfoSai[nCntFor1,2],10) + "))")
		RecLock(aInfoSai[nCntFor1,1],.F.)
		&(aInfoSai[nCntFor1,1] + "->" + aInfoSai[nCntFor1,1] + "_CODNEG") := aInfoSai[nCntFor1,3]
		&(aInfoSai[nCntFor1,1] + "->" + aInfoSai[nCntFor1,1] + "_SERVIC") := aInfoSai[nCntFor1,4]
		If aInfoSai[nCntFor1,1] == 'DT5'
			&(aInfoSai[nCntFor1,1] + "->" + aInfoSai[nCntFor1,1] + "_LOTE") := aInfoSai[nCntFor1,6]
		Else
			&(aInfoSai[nCntFor1,1] + "->" + aInfoSai[nCntFor1,1] + "_LOTNFC") := aInfoSai[nCntFor1,6]
		EndIf	
		&(aInfoSai[nCntFor1,1] + "->" + "(MsUnlock())")
		If aInfoEnt[nCntFor1,6] != aInfoSai[nCntFor1,6]
			//-- Aumenta um na quantidade do novo lote
			If DTP->(DbSeek(xFilial("DTP") + aInfoSai[nCntFor1,6]))
				RecLock("DTP",.F.)
				DTP->DTP_QTDLOT += 1
				DTP->DTP_QTDDIG += 1
				DTP->(MsUnlock())
			EndIf
			//-- Diminui um na quantidade do lote anterior
			If DTP->(DbSeek(xFilial("DTP") + aInfoEnt[nCntFor1,6]))
				RecLock("DTP",.F.)
				If DTP->DTP_QTDLOT - 1 == 0
					DTP->(DbDelete())
				Else
					DTP->DTP_QTDLOT -= 1
					DTP->DTP_QTDDIG -= 1
				EndIf
				DTP->(MsUnlock())
			EndIf
		EndIf
		If aInfoSai[nCntFor1,1] == "DT5"
			DF1->(DbSetOrder(3))
			If DF1->(DbSeek(xFilial("DF1") + DT5->(DT5_FILORI + DT5_NUMSOL) + "COL"))
				RecLock("DF1",.F.)
				DF1->DF1_CODNEG := aInfoSai[nCntFor1,3]
				DF1->DF1_SRVCOL := aInfoSai[nCntFor1,4]
				DF1->(MsUnlock())
			EndIf
		EndIf
		lAltServ := .T.
	EndIf

Next nCntFor1

AEval(aAreas,{|x,y| RestArea(x) })

Return

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSF79Dud
Limpa Lote Informado Na Tabela DUD ( Movimentos Da Viagem )
@author Eduardo Alberti
@version Versao P12
@since Oct/2016
@return cMsgRet (Mensagem Erro Caso Ocorra)
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function TMSF79Dud( cNumLot )

	Local aArea 	:= GetArea()
	Local aArDUD  := DUD->(GetArea())
	Local cQuery	:= ""
	Local nCodRet	:= 0
	Local cMsgRet := ""

	cQuery := " UPDATE " + RetSqlName("DUD")
	cQuery += " SET		DUD_LOTE 		=  '" + Space(TamSX3("DUD_LOTE")[1]) + "'"
	cQuery += " WHERE 	DUD_FILIAL 	=  '" + FWxFilial("DUD") + "' "
	cQuery += " AND 		DUD_FILORI    =  '" + cFilAnt + "' "
	cQuery += " AND		DUD_LOTE		=  '" + cNumLot + "' "
	cQuery += " AND		D_E_L_E_T_    =  ' ' "
	
	//-- Executa Script
	nCodRet:= TcSqlExec( cQuery )

	//-- Inclui Log De Erro
	If nCodRet < 0
		cMsgRet := ProcName() + Space(1) + TcSqlError()
	EndIf

	RestArea(aArDUD)
	RestArea(aArea)
	
Return( cMsgRet )		

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ TMSF79Ret  ³ Autor ³ Valdemar Roberto  ³ Data ³ 28.07.2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Retira documentos do lote em embarques parciais            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF79Ret()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF79Ret(aColsPag)
Local nCntFor1  := 0
Local nQtdRet   := 0
Local nLinha    := 0
Local cQuery    := ""
Local cAliasDTC := ""
Local cLotAnt   := ""
Local aAreas    := {DTP->(GetArea()),GetArea()}
Local aVetCols  := Aclone(aColsPag)
Local lCont     := .T.

aVetCols := ASort(aVetCols,,,{|x,y| x[30] < y[30]})

DTP->(DbSetOrder(1))

For nCntFor1 := 1 To Len(aVetCols)
	If !Empty(aVetCols[nCntFor1,30])
		If aVetCols[nCntFor1,30] != cLotAnt
			cLotAnt := aVetCols[nCntFor1,30]
			If DTP->(DbSeek(xFilial("DTP") + aVetCols[nCntFor1,30]))
				cAliasDTC := GetNextAlias()
				cQuery := " SELECT COUNT(DTC_LOTNFC) QTDNFC "
				cQuery += "   FROM " + RetSqlName("DTC") + " DTC "
		
				cQuery += "   JOIN " + RetSqlName("DF1") + " DF1 "
				cQuery += "     ON DF1_FILIAL = '" + xFilial("DF1") + "' "
				cQuery += "    AND DF1_FILDOC = DTC_FILCFS "
				cQuery += "    AND DF1_DOC    = DTC_NUMSOL "
				cQuery += "    AND DF1_SERIE  = 'COL' "
				cQuery += "    AND DF1_MRKPAN = '" + cNumThread + "' "
				cQuery += "    AND DF1.D_E_L_E_T_ = ' ' "
		
				cQuery += "  WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
				cQuery += "    AND DTC_LOTNFC = '" + aVetCols[nCntFor1,30] + "' "
				cQuery += "    AND DTC.D_E_L_E_T_ = ' ' "
		
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasDTC,.F.,.T.)
				
				lCont := ((cAliasDTC)->QTDNFC != DTP->DTP_QTDDIG)
		
				(cAliasDTC)->(DbCloseArea())
		
				If lCont
					nQtdRet := 0
					cAliasDTC := GetNextAlias()
					cQuery := " SELECT DTC.R_E_C_N_O_ REGDTC "
					cQuery += "   FROM " + RetSqlName("DTC") + " DTC "
			
					cQuery += "   JOIN " + RetSqlName("DF1") + " DF1 "
					cQuery += "     ON DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "    AND DF1_FILDOC = DTC_FILCFS "
					cQuery += "    AND DF1_DOC    = DTC_NUMSOL "
					cQuery += "    AND DF1_SERIE  = 'COL' "
					cQuery += "    AND DF1_MRKPAN = '" + cNumThread + "' "
					cQuery += "    AND DF1.D_E_L_E_T_ = ' ' "
			
					cQuery += "  WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "    AND DTC_LOTNFC = '" + aVetCols[nCntFor1,30] + "' "
					cQuery += "    AND DTC.D_E_L_E_T_ = ' ' "
			
					cQuery := ChangeQuery(cQuery)
					DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasDTC,.F.,.T.)
					
					While (cAliasDTC)->(!Eof())
						//-- Limpa o lote no registro
						DTC->(DbGoto((cAliasDTC)->REGDTC))
						RecLock("DTC",.F.)
						DTC->DTC_LOTNFC := Space(Len(DTC->DTC_LOTNFC))
						DTC->(MsUnlock())
						//-- Limpa o lote no vetor aInfoEnt
						While (nLinha := Ascan(aInfoEnt,{|x| x[6] == aVetCols[nCntFor1,30]})) > 0
							aInfoEnt[nLinha,6] := Space(Len(DTC->DTC_LOTNFC))
						EndDo
						//-- Limpa o lote no vetor aColsPag
						While (nLinha := Ascan(aColsPag,{|x| x[30] == aVetCols[nCntFor1,30]})) > 0
							aColsPag[nLinha,30] := Space(Len(DTC->DTC_LOTNFC))
						EndDo
						//-- Acumula quantidade total
						nQtdRet ++
						(cAliasDTC)->(DbSkip())
					EndDo
			
					(cAliasDTC)->(DbCloseArea())
			
					//-- Diminui a quantidade de notas retiradas do lote
					If nQtdRet > 0
						RecLock("DTP",.F.)
						If DTP->DTP_QTDLOT - nQtdRet == 0
							DTP->(DbDelete())
						Else
							DTP->DTP_QTDLOT -= nQtdRet
							DTP->DTP_QTDDIG -= nQtdRet
						EndIf
						DTP->(MsUnlock())
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Next nCntFor1

aEval(aAreas,{|x| RestArea(x) })

Return
