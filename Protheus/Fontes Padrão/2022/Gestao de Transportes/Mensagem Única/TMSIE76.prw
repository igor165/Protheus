#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TMSIE76.CH"
#INCLUDE "XMLXFUN.CH"

Static lAtuReg := .F.
Static aVetDJR := {}
Static aUFs    := {{"RO","11"},{"AC","12"},{"AM","13"},{"RR","14"},{"PA","15"},{"AP","16"},{"TO","17"},{"MA","21"},{"PI","22"},{"CE","23"},;
				   {"RN","24"},{"PB","25"},{"PE","26"},{"AL","27"},{"MG","31"},{"ES","32"},{"RJ","33"},{"SP","35"},{"PR","41"},{"SC","42"},;
				   {"RS","43"},{"MS","50"},{"MT","51"},{"GO","52"},{"DF","53"},{"SE","28"},{"BA","29"},{"EX","99"}}
Static lTMS76XML:= ExistBlock('TMS76XML')

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSIE76  ³ Autor ³ Valdemar Roberto   ³ Data ³ 09/12/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de integracao com o adapter EAI para recebimento de ³±±
±±³          ³ e envio de dados do EDI - Notas Fiscais (DE5)              ³±±
±±³          ³ utilizando o conceito de mensagem unica                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSIE76(cExp01,nExp01,cExp02)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Variavel com conteudo xml para envio/recebimento  ³±±
±±³          ³ nExp01 - Tipo de transacao (Envio/Recebimento)             ³±±
±±³          ³ cExp02 - Tipo de mensagem (Business Type, WhoIs, Etc)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºRetorno   ³ aRet - Array contendo o resultado da execucao e a mensagem º±±
±±º          ³        XML de retorn                                       º±±
±±º          ³ aRet[1] - (Boolean) Indica resultado da execução da função º±±
±±º          ³ aRet[2] - (Caracter) Mensagem XML para envio  s            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSIE76(cXML,nTypeTrans,cTypeMessage)
Local aAreas     := {DJQ->(GetArea()),DT6->(GetArea()),SB1->(GetArea()),SM0->(GetArea()),DUY->(GetArea()),SF3->(GetArea()),;
					 DJR->(GetArea()),SA1->(GetArea()),SFT->(GetArea()),SX5->(GetArea()),DTC->(GetArea()),DT8->(GetArea()),;
					 DT3->(GetArea()),SF2->(GetArea()),GetArea()}
Local aAreaAux   := {}
Local aDT6       := {}
Local aSB1       := {}
Local aSM0       := {}
Local aSF3       := {}
Local aSA1Des    := {}
Local aSA1Rem    := {}
Local aSA1Dev    := {}
Local aSFT       := {}
Local aSF1       := {}
Local aDTC       := {}
Local aDT8       := {}
Local aICMS      := {}
Local aPIS       := {}
Local aCOFINS    := {}
Local aMsgRet    := {}
Local aFilSM0    := {}
Local aRetEnd    := {}
Local lRet       := .T.
Local cXMLRet    := ""
Local cEvent     := "Upsert"	//-- Upsert, Delete
Local cTypeDoc   := TMSAE76Sta("cTypeDoc")
Local cOpeCodN   := SuperGetMV("MV_TMSOPEN",," ")	//-- Código da operação para CTe normal - Integração Datasul
Local cOpeCodC   := SuperGetMV("MV_TMSOPEC",," ")	//-- Código da operação para CTe cortesia - Integração Datasul
Local cOpeCodNF  := SuperGetMV("MV_TMSOPNF",," ")	//-- Código da operação para Nota fiscal - Integração Datasul
Local cCodReg    := SuperGetMV("MV_CODREG",," ")
Local cTextInut  := GetNewPar("MV_TXTINUT","")
Local cQuery     := ""
Local cAliasSFT  := ""
Local cXMLCTe    := ""
Local cMsgRet    := "ElectronicTransportDocument"
Local cCodInt    := ""
Local cTipoPcc   := "PIS','COF','CSL','CF-','PI-','CS-"
Local cTipOpe    := TMSAE76Sta("cTipOpe")
Local cEspecie   := TMSAE76Sta("cEspecie")
Local cIdEnt     := TMSAE76Sta("cIdEnt")
Local cTipEnv    := TMSAE76Sta("cTipEnv")
Local cCodSEF    := TMSAE76Sta("cCodSEF")
Local cAmbiente  := TMSAE76Sta("cAmbiente")
Local cHorEnv    := ""
Local cEntSai    := TMSAE76Sta("cEntSai")
Local cVersaoCTe := TMSAE76Sta("cVersaoCTe")
Local cAviso     := ""
Local cErro      := ""
Local cFilDoc    := ""
Local cDoc       := ""
Local cSerie     := ""
Local cXMLEnvio  := ""
Local cSeekDT8   := ""
Local cSeekDJR   := ""
Local cSeekSFT   := ""
Local cMsgErr    := ""
Local cCGC       := ""
Local cCodOpe    := ""
Local cStatus    := ""
Local cOrigem    := ""
Local cDestino   := ""
Local cFilSis    := ""
Local cTESBase   := ""
Local dDatEnv    := dDataBase
Local lUsaColab  := TMSAE76Sta("lUsaColab")
Local nCntFor1   := 0
Local nPos       := 0
Local nLinha     := 0
Local oMsgCTeRet
Local cCFOPBase  := ""
Local cXMLPE     := ""

Local cCliRem    := ""
Local cLojRem    := ""
Local lCTEAnu    := .F.

lAtuReg := .F.
aVetDJR := {}

If cEspecie == "CTE"

	If lCTEAnu

	/* Quando a operação exigir a necessidade da emissão do CT-e de Anulação no TMS, será preciso efetuar manualmente a 
	entrada desse documento no módulo de Recebimento (Datasul), como se fosse um documento de devolução de cliente, para que 
	possa realizar a movimentação contábil de estorno da receita (CD0309) do CT-e Normal que está sendo anulado.
	Obs: o CT-e de anulação pode ser emitido pelo cliente ou pelo próprio transportador, dependendo se o cliente é ou não 
	contribuinte de ICMS, e se aplica nas ocasiões em que não é permitido cancelar o CT-e. Após emitido o CT-e de anulação, é 
	emitido um CT-e Substituto, que será contabilizado como um CT-e Normal, considerando a mesma grade de contas. */

	//If cEntSai == "E" .And. SD1->D1_TIPO == "D" .And. SD1->D1_FORMUL != "S" 	//-- Nota de entrada para CTe anulação gerado por contribuinte
		//-- Monta vetor aSF1
		SF1->(DbSetOrder(1))
		SF1->(DbSeek(SF3->F3_FILIAL + SF3->F3_NFISCAL + SF3->F3_SERIE))
		Aadd(aSF1,SF1->F1_CHVNFE)
		Aadd(aSF1,SubStr(SF1->F1_CHVNFE,Len(AllTrim(SF1->F1_CHVNFE)) - 8,8))
		Aadd(aSF1,Right(AllTrim(SF1->F1_CHVNFE),1))
		Aadd(aSF1,"Este documento esta vinculado ao documento fiscal numero " + AllTrim(SD1->D1_NFORI) + " serie " + AllTrim(SD1->D1_SERIORI) + ;
				  " da data " + DToC(DT6->DT6_DATEMI) + " chave " + AllTrim(DT6->DT6_CHVCTE)  + " em virtude de " + NoAcentoCte(SF1->F1_MENNOTA))

 		//-- Monta vetor aSFT
		SFT->(DbSetOrder(1))
		SFT->(DbSeek(SF3->F3_FILIAL + cEntSai + SF3->F3_SERIE + SF3->F3_NFISCAL + SF3->F3_CLIEFOR + SF3->F3_LOJA))
		Aadd(aSFT,SFT->FT_BASEICM)
		Aadd(aSFT,SFT->FT_ALIQICM)
		Aadd(aSFT,SFT->FT_VALICM)
		Aadd(aSFT,SFT->FT_CFOP)
		Aadd(aSFT,tabela("13",SFT->FT_CFOP,.f.))

		//-- Monta vetor aDT6
		Aadd(aDT6,DT6->DT6_CHVCTE)
		Aadd(aDT6,DT6->DT6_DATEMI)
		Aadd(aDT6,PadL(DT6->DT6_TIPTRA,2,"0"))
		Aadd(aDT6,"1")
		If ((DT6->DT6_CLIREM = DT6->DT6_CLIDEV) .And. (DT6->DT6_LOJREM = DT6->DT6_LOJDEV))
			aDT6[Len(aDT6)] := "0"
		ElseIf ((DT6->DT6_CLIDES = DT6->DT6_CLIDEV) .And. (DT6->DT6_LOJDES = DT6->DT6_LOJDEV))
			aDT6[Len(aDT6)] := "3"
		ElseIf ((DT6->DT6_CLICON = DT6->DT6_CLICON) .And. (DT6->DT6_LOJCON = DT6->DT6_LOJCON))
			aDT6[Len(aDT6)] := "4"
		ElseIf ((DT6->DT6_CLIDPC = DT6->DT6_CLIDPC) .And. (DT6->DT6_LOJDPC = DT6->DT6_LOJDPC))
			aDT6[Len(aDT6)] := "4"
		EndIf

		//-- Monta vetor aDTC
		DTC->(DbSetOrder(1))
		DTC->(DbSeek(xFilial("DTC") + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE))
		Aadd(aDTC,DTC->DTC_TIPNFC)

		//-- Monta vetor aDT8
		DT8->(DbSetOrder(2))
		DT8->(DbSeek(cSeekDT8 := xFilial("DT8") + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE))
		While DT8->(!Eof()) .And. DT8->(DT8_FILIAL + DT8_FILDOC + DT8_DOC + DT8_SERIE) == cSeekDT8
			If (nLinha := aScan(aDT8,{|x| x[1] == DT8->DT8_CODPAS})) > 0
				aDT8[nLinha,3] += DT8->DT8_VALTOT
			Else
				Aadd(aDT8,{DT8->DT8_CODPAS,;
						   Posicione("DT3",1,xFilial("DT3") + DT8->DT8_CODPAS,"DT3_DESCRI"),;
						   DT8->DT8_VALTOT})
			EndIf
			DT8->(DbSkip())
		EndDo

		//-- Monta vetor aSM0
		Aadd(aSM0,cAmbiente)
		Aadd(aSM0,cVersaoCTe)

		//-- Monta vetor aSA1Dev
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + DT6->DT6_CLIDEV + DT6->DT6_LOJDEV))
		Aadd(aSA1Dev,SA1->A1_COD_MUN)
		Aadd(aSA1Dev,SA1->A1_MUN)
		Aadd(aSA1Dev,SA1->A1_EST)
		Aadd(aSA1Dev,SA1->A1_CGC)
		Aadd(aSA1Dev,SA1->A1_INSCR)
		Aadd(aSA1Dev,SA1->A1_NOME)
		Aadd(aSA1Dev,SA1->A1_NREDUZ)
		Aadd(aSA1Dev,SA1->A1_END)
		Aadd(aSA1Dev,SA1->A1_BAIRRO)
		Aadd(aSA1Dev,SA1->A1_CEP)
		Aadd(aSA1Dev,SA1->A1_TEL)
		
		//-- Monta vetor aSA1Rem
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + DT6->DT6_CLIREM + DT6->DT6_LOJREM))
		Aadd(aSA1Rem,SA1->A1_CGC)
		Aadd(aSA1Rem,SA1->A1_INSCR) 
		Aadd(aSA1Rem,SA1->A1_NOME)
		Aadd(aSA1Rem,SA1->A1_NREDUZ)
		Aadd(aSA1Rem,SA1->A1_DDD)
		Aadd(aSA1Rem,SA1->A1_TEL)
		Aadd(aSA1Rem,SA1->A1_END)
		Aadd(aSA1Rem,SA1->A1_BAIRRO)
		Aadd(aSA1Rem,SA1->A1_EST)
		Aadd(aSA1Rem,SA1->A1_COD_MUN)
		Aadd(aSA1Rem,SA1->A1_CEP)
		Aadd(aSA1Rem,SA1->A1_PAIS)
		Aadd(aSA1Rem,SA1->A1_MUN)

		//-- Monta vetor aSA1Des
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + DT6->DT6_CLIDES + DT6->DT6_LOJDES))
		Aadd(aSA1Des,SA1->A1_CGC)
		Aadd(aSA1Des,SA1->A1_INSCR) 
		Aadd(aSA1Des,SA1->A1_NOME)
		Aadd(aSA1Des,SA1->A1_NREDUZ)
		Aadd(aSA1Des,SA1->A1_DDD)
		Aadd(aSA1Des,SA1->A1_TEL)
		Aadd(aSA1Des,SA1->A1_END)
		Aadd(aSA1Des,SA1->A1_BAIRRO)
		Aadd(aSA1Des,SA1->A1_EST)
		Aadd(aSA1Des,SA1->A1_COD_MUN)
		Aadd(aSA1Des,SA1->A1_CEP)
		Aadd(aSA1Des,SA1->A1_PAIS)
		Aadd(aSA1Des,SA1->A1_CODMUNE)
		Aadd(aSA1Des,SA1->A1_ESTE)
		Aadd(aSA1Des,SA1->A1_CEPE)
		Aadd(aSA1Des,SA1->A1_INSCR)
		Aadd(aSA1Des,SA1->A1_MUNE)
		Aadd(aSA1Des,SA1->A1_ENDENT)
		Aadd(aSA1Des,SA1->A1_BAIRROE)
		Aadd(aSA1Des,SA1->A1_MUN)
		
		//-- Monta vetor aSF3
		Aadd(aSF3,SF3->F3_NFISCAL)
		Aadd(aSF3,SF3->F3_SERIE)
		Aadd(aSF3,SF3->F3_EMINFE)
		Aadd(aSF3,SF3->F3_HORNFE)

		cXMLCTe := MontaXMLAn(aClone(aSM0),aClone(aSA1Dev),aClone(aSA1Des),aClone(aSA1Rem),aClone(aSF3),aClone(aSFT),aClone(aDT6),;
							  aClone(aSF1),aClone(aDTC),aClone(aDT8))
	Else
		lUsaColab := TMSAE76Sta("lUsaColab")
		cIdEnt    := TMSAE76Sta("cIdEnt")
		cCodSEF   := TMSAE76Sta("cCodSEF")
		If ExistFunc("SPEDNFEXML")
			SPEDNFEXML(cIdEnt,SF3->(F3_SERIE+F3_NFISCAL),1,lUsaColab,'57',.F.,.T.,@cXMLCTe, Iif(cCodSEF=="100",.F.,.T.))
		EndIf
		If !Empty(cXMLCTe)
			cXMLCTe := '<cteProc>' +cXMLCTe +  '</cteProc>'
		EndIf
	EndIf

ElseIf cEspecie == "RPS"
	If !Empty(cTipOpe)
		//-- Monta vetor aDT6
		If cTipOpe == "Cancelamento"
			Aadd(aDT6,SF3->F3_FILIAL)
			Aadd(aDT6,SF3->F3_NFISCAL)
			Aadd(aDT6,SF3->F3_SERIE)
			Aadd(aDT6,SF3->F3_EMISSAO)
			Aadd(aDT6,"0000")
			Aadd(aDT6,"1")
		Else
			DT6->(DbSetOrder(1))
			DT6->(DbSeek(xFilial("DT6") + SF3->F3_FILIAL + SF3->F3_NFISCAL + SF3->F3_SERIE))
			Aadd(aDT6,DT6->DT6_FILDOC)
			Aadd(aDT6,DT6->DT6_DOC)
			Aadd(aDT6,DT6->DT6_SERIE)
			Aadd(aDT6,DT6->DT6_DATEMI)
			Aadd(aDT6,DT6->DT6_HOREMI)
			Aadd(aDT6,"1")
		EndIf

		//-- Monta vetor aSF3
		Aadd(aSF3,SF3->F3_NFELETR)
		Aadd(aSF3,SF3->F3_CODNFE)
		Aadd(aSF3,SF3->F3_EMINFE)
		Aadd(aSF3,SF3->F3_HORNFE)
		Aadd(aSF3,SF3->F3_CODRSEF)
		Aadd(aSF3,SF3->F3_OBSERV)

		//-- Monta vetor aSFT
		SFT->(DbSetOrder(1))
		If SFT->(DbSeek(cSeekSFT := SF3->F3_FILIAL + "S" + SF3->F3_SERIE + SF3->F3_NFISCAL + SF3->F3_CLIEFOR + SF3->F3_LOJA))
			aSFT := Array(27)
			aSFT[01] := SFT->FT_DTCANC
			aSFT[02] := SFT->FT_CODISS
			aSFT[03] := SFT->FT_CSTPIS
			aSFT[04] := SFT->FT_CSTCOF
			aSFT[05] := SFT->FT_ALIQINS
			aSFT[06] := SFT->FT_ALIQPIS
			aSFT[07] := SFT->FT_ALIQCOF
			aSFT[08] := 0
			aSFT[09] := 0
			aSFT[10] := 0
			aSFT[11] := 0
			aSFT[12] := 0
			aSFT[13] := 0
			aSFT[14] := SFT->FT_CSTISS
			aSFT[15] := 0
			aSFT[16] := 0
			aSFT[17] := 0
			aSFT[18] := SFT->FT_RECISS
			aSFT[19] := 0
			aSFT[20] := 0
			aSFT[21] := 0
			aSFT[22] := SFT->FT_ALIQICM
			aSFT[23] := SFT->FT_ALIQIRR
			aSFT[24] := SFT->FT_ALIQCSL
			aSFT[25] := 0
			aSFT[26] := 0
			aSFT[27] := SFT->FT_PRODUTO
			While SFT->(!Eof()) .And. SFT->(FT_FILIAL + FT_TIPOMOV + FT_SERIE + FT_NFISCAL + FT_CLIEFOR + FT_LOJA) == cSeekSFT
				aSFT[08] += SFT->FT_BASEINS
				aSFT[09] += SFT->FT_BASEPIS
				aSFT[10] += SFT->FT_BASECOF
				aSFT[11] += SFT->FT_VALINS
				aSFT[12] += SFT->FT_VALPIS
				aSFT[13] += SFT->FT_VALCOF
				aSFT[15] += SFT->FT_QUANT
				aSFT[16] += SFT->FT_PRCUNIT
				aSFT[17] += SFT->FT_VALCONT
				aSFT[19] += SFT->FT_VALIRR
				aSFT[20] += SFT->FT_VALCSL
				aSFT[21] += SFT->FT_VALICM
				aSFT[25] += SFT->FT_BASEICM
				aSFT[26] += SFT->FT_ICMSRET
				SFT->(DbSkip())
			EndDo
		EndIf
		
		//-- Monta vetor aSM0
		Aadd(aSM0,SM0->M0_INSCM)
		Aadd(aSM0,SM0->M0_CGC)
		Aadd(aSM0,SM0->M0_NOMECOM)
		Aadd(aSM0,SM0->M0_NOME)
		Aadd(aSM0,SM0->M0_CODMUN)
		Aadd(aSM0,SM0->M0_CIDENT)
		Aadd(aSM0,SM0->M0_ESTENT)
		Aadd(aSM0,"")
		Aadd(aSM0,"")
		Aadd(aSM0,SM0->M0_TEL)
		Aadd(aSM0,SuperGetMV("MV_CODREG",," "))
		Aadd(aSM0,"")
		Aadd(aSM0,"")
		Aadd(aSM0,SM0->M0_ENDENT)
		Aadd(aSM0,SM0->M0_COMPENT)
		Aadd(aSM0,SM0->M0_BAIRENT)
		Aadd(aSM0,SM0->M0_CEPENT)
		Aadd(aSM0,SM0->M0_INSC)

		//-- Monta vetor aSA1Dev
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + SF3->(F3_CLIEFOR + F3_LOJA)))
		Aadd(aSA1Dev,SA1->A1_INSCRM)
		Aadd(aSA1Dev,SA1->A1_CGC)
		Aadd(aSA1Dev,SA1->A1_NOME)
		Aadd(aSA1Dev,"")
		Aadd(aSA1Dev,SA1->A1_ENDENT)
		Aadd(aSA1Dev,SA1->A1_END)
		Aadd(aSA1Dev,SA1->A1_COMPLEM)
		Aadd(aSA1Dev,SA1->A1_BAIRRO)
		Aadd(aSA1Dev,SA1->A1_BAIRROE)
		Aadd(aSA1Dev,SA1->A1_COD_MUN)
		Aadd(aSA1Dev,SA1->A1_CODMUNE)
		Aadd(aSA1Dev,"")
		Aadd(aSA1Dev,SA1->A1_IBGE)
		Aadd(aSA1Dev,SA1->A1_EST)
		Aadd(aSA1Dev,SA1->A1_ESTE)
		Aadd(aSA1Dev,SA1->A1_CEP)
		Aadd(aSA1Dev,SA1->A1_CEPE)
		Aadd(aSA1Dev,SA1->A1_EMAIL)
		Aadd(aSA1Dev,SA1->A1_DDD)
		Aadd(aSA1Dev,SA1->A1_TEL)
		Aadd(aSA1Dev,SA1->A1_PAIS)
		Aadd(aSA1Dev,SA1->A1_INSCR) 
		Aadd(aSA1Dev,SA1->A1_MUN)
		Aadd(aSA1Dev,SA1->A1_MUNE)
		Aadd(aSA1Dev,SA1->A1_RECISS)

		//-- Monta vetor aSA1Des
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + SF3->(F3_CLIEFOR + F3_LOJA)))
		Aadd(aSA1Des,SA1->A1_NOME)
		Aadd(aSA1Des,"")
		Aadd(aSA1Des,SA1->A1_ENDENT)
		Aadd(aSA1Des,SA1->A1_END)
		Aadd(aSA1Des,SA1->A1_COMPLEM)
		Aadd(aSA1Des,SA1->A1_BAIRRO)
		Aadd(aSA1Des,SA1->A1_BAIRROE)
		Aadd(aSA1Des,SA1->A1_COD_MUN)
		Aadd(aSA1Des,SA1->A1_CODMUNE)
		Aadd(aSA1Des,"")
		Aadd(aSA1Des,SA1->A1_IBGE)
		Aadd(aSA1Des,SA1->A1_EST)
		Aadd(aSA1Des,SA1->A1_ESTE)
		Aadd(aSA1Des,SA1->A1_CEP)
		Aadd(aSA1Des,SA1->A1_CEPE)
		Aadd(aSA1Des,SA1->A1_EMAIL)
		Aadd(aSA1Des,SA1->A1_DDD)
		Aadd(aSA1Des,SA1->A1_TEL)
		Aadd(aSA1Des,SA1->A1_PAIS)
		Aadd(aSA1Des,SA1->A1_INSCR) 
		Aadd(aSA1Des,SA1->A1_MUN)
		Aadd(aSA1Des,SA1->A1_MUNE)
		Aadd(aSA1Des,SA1->A1_RECISS)

		//-- Monta vetor aSB1
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1") + SFT->FT_PRODUTO))
		Aadd(aSB1,SB1->B1_DESC)
		
		cXMLCTe := MontaXMLNF(aClone(aDT6),aClone(aSF3),aClone(aSFT),aClone(aSM0),aClone(aSA1Dev),aClone(aSA1Des),aClone(aSB1))
	EndIf
EndIf

If !Empty(cXMLCTe) .Or. nTypeTrans == TRANS_RECEIVE
	
	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_RESPONSE
			cXMLRet    := cXML
			cAviso     := ""
			cErro      := ""
			oMsgCTeRet := XmlParser(cXMLRet,"_",@cAviso,@cErro)

			If ValType(oMsgCTeRet) == "O" 
				If XmlChildEx(oMsgCTeRet:_TOTVSMESSAGE,"_RESPONSEMESSAGE") != Nil 
			
					//-- Busca status do processamento e mensagens
					If XmlChildEx(oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE,"_PROCESSINGINFORMATION") != Nil .And. ;
					   XmlChildEx(oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION,"_STATUS") != Nil
						cStatus := oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_STATUS:TEXT
						If cStatus == "ERROR"
							If XmlChildEx(oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION,"_LISTOFMESSAGES") != Nil .And. ;
							   XmlChildEx(oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_LISTOFMESSAGES,"_MESSAGE") != Nil
								If ValType("oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_LISTOFMESSAGES:_MESSAGE") != "A"
									cMsgErr := oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_LISTOFMESSAGES:_MESSAGE:TEXT
									Aadd(aMsgRet,cMsgErr)
								Else
									For nCntFor1 := 1 To Len(oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_LISTOFMESSAGES:_MESSAGE)
										cMsgErr := oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_LISTOFMESSAGES:_MESSAGE[nCntFor1]:TEXT
										Aadd(aMsgRet,cMsgErr)
									Next nCntFor1
								EndIf
							EndIf
						Else
							Aadd(aMsgRet,STR0002)	//-- "Registro importado com sucesso"
						EndIf
					EndIf
			
					//-- Busca número do documento e tipo da operação
					If XmlChildEx(oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE,"_RETURNCONTENT") != Nil .And. ;
					   XmlChildEx(oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT,"_LISTOFINTERNALID") != Nil .And. ;
					   XmlChildEx(oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID,"_INTERNALID") != Nil
						If XmlChildEx(oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID:_INTERNALID,"_ORIGIN") != Nil
							cOrigem  := oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID:_INTERNALID:_ORIGIN:TEXT
							cFilSis  := SubStr(cOrigem,1,TamSX3("DT6_FILIAL")[1])
							cFilDoc  := SubStr(cOrigem,TamSX3("DT6_FILIAL")[1] + 1,TamSX3("DT6_FILDOC")[1])
							cDoc     := SubStr(cOrigem,TamSX3("DT6_FILIAL")[1] + TamSX3("DT6_FILDOC")[1] + 1,TamSX3("DT6_DOC")[1])
							cSerie   := SubStr(cOrigem,TamSX3("DT6_FILIAL")[1] + TamSX3("DT6_FILDOC")[1] + TamSX3("DT6_DOC")[1] + 1,TamSX3("DT6_SERIE")[1])
						EndIf
						If XmlChildEx(oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID:_INTERNALID,"_DESTINATION") != Nil
							cDestino := oMsgCTeRet:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID:_INTERNALID:_DESTINATION:TEXT
							nPos := At("|",cDestino)
							If nPos > 0
								cTypeDoc := Left(cDestino,nPos - 1)
								If At("Cancelamento",cTypeDoc) > 0
									SF2->(DbSetOrder(1))
									If SF2->(DbSeek(cFilDoc + cDoc + cSerie))
										DbSetOrder(4)
										If SF3->(DbSeek(xFilial("SF3") + SF2->(F2_CLIENTE + F2_LOJA + F2_DOC + F2_SERIE)))
											If AllTrim(SF3->F3_CODRSEF) == "101"
												cTypeDoc := "Cancelamento"
											ElseIf AllTrim(SF3->F3_CODRSEF) == "102"
												cTypeDoc := "Inutilizacao"
											EndIf
										EndIf
									EndIf
								Else
									cTypeDoc := "Autenticacao"
								EndIf
							EndIf
						EndIf
					EndIf
					
					aAreaAux := {DT6->(GetArea()), GetArea()}
					For nCntFor1 := 1 To Len(aMsgRet)
						//-- Atualiza tabela DJR (Itens do Histórico de Integrações)
						DJR->(DbSetOrder(1))
						If DJR->(DbSeek(cSeekDJR := xFilial("DJR") + "SF3" + "6" + ;
													PadR(cFilDoc + cDoc + cSerie,TamSX3("DJR_CONTEU")[1]) + ;
													PadR(cTypeDoc,TamSX3("DJR_CODOPE")[1])))
							While DJR->(!Eof()) .And. DJR->(DJR_FILIAL + DJR_ALIAS + DJR_INDICE + DJR_CONTEU + DJR_CODOPE) == cSeekDJR
								Reclock("DJR",.F.)
								DJR->DJR_OBSERV := DJR->DJR_OBSERV + " " + aMsgRet[nCntFor1]
								DJR->DJR_STATUS := cStatus
								DJR->(MsUnlock())

								//-- Atualiza o Status da fatura de doctos de Apoio quando retorno "OK"
								If AllTrim(UPPER(cStatus)) == "OK" 
									DT6->(DbSetOrder(1))
									If DT6->(MsSeek(xFilial("DT6")+cFilDoc + cDoc + cSerie )) .And. !Empty(DT6->DT6_NUM)
										DRT->(DbSetOrder(1))
										If DRT->(DbSeek(xFilial('DRT') + DT6->DT6_NUM )) .And. DRT->DRT_STATUS == StrZero(8,Len(DRT->DRT_STATUS))   //Fatura de Apoio nao Integrada
											Reclock("DRT", .F.)
											DRT->DRT_STATUS := StrZero(1,Len(DRT->DRT_STATUS))    //-- Fatura integrada
											DRT->(MsUnlock())
										EndIf
									EndIf
								EndIf
								DJR->(DbSkip())
							EndDo
						EndIf
					Next nCntFor1
					aEval(aAreaAux, {|x| RestArea(x)})
					
				EndIf
			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet := '1.000'
		EndIf
	
	ElseIf nTypeTrans == TRANS_SEND
		cXMLCTe := StrTran(cXMLCTe,"<","&lt;")
		cXMLCTe := StrTran(cXMLCTe,">","&gt;")
	
		cCodInt := xFilial("DT6") + SF3->F3_FILIAL + AllTrim(SF3->F3_NFISCAL) + AllTrim(SF3->F3_SERIE)
	
		//-- Le documento nos livros fiscais
		SFT->(DbSetOrder(1))
		If SFT->(DbSeek(SF3->F3_FILIAL + cEntSai + SF3->F3_SERIE + SF3->F3_NFISCAL + SF3->F3_CLIEFOR + SF3->F3_LOJA))

			cCliRem := SFT->FT_CLIEFOR
			cLojRem := SFT->FT_LOJA

			DT6->(DbSetOrder(1))
			DT6->(DbSeek(xFilial("DT6") + SF3->F3_FILIAL + SF3->F3_NFISCAL + SF3->F3_SERIE))

			cTESBase := ""
			cCFOPBase:= SFT->FT_CFOP
	
			//-- Busca ICMS
			cAliasSFT := GetNextAlias()
			cQuery := "SELECT FT_ALIQICM,SUM(FT_VALICM) FT_VALICM,SUM(FT_BASEICM) FT_BASEICM,F4_BASEICM,F4_SITTRIB,F4_CSTISS,F4_CODIGO "
			cQuery += "  FROM " + RetSqlName("SFT") + " SFT "
			cQuery += "  JOIN " + RetSqlName("SD2") + " SD2 "
			cQuery += "    ON D2_FILIAL  = '" + FwxFilial("SD2") + "' "
			cQuery += "   AND D2_DOC     = FT_NFISCAL "
			cQuery += "   AND D2_SERIE   = FT_SERIE "
			cQuery += "   AND D2_CLIENTE = FT_CLIEFOR "
			cQuery += "   AND D2_LOJA    = FT_LOJA "
			cQuery += "   AND D2_COD     = FT_PRODUTO "
			cQuery += "   AND D2_ITEM    = FT_ITEM "
			cQuery += "   AND SD2.D_E_L_E_T_ = ' ' "
			cQuery += "  JOIN " + RetSqlName("SF4") + " SF4 "
			cQuery += "    ON F4_FILIAL = '" + FwxFilial("SF4") + "' "
			cQuery += "   AND F4_CODIGO = D2_TES "
			cQuery += "   AND SF4.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE FT_FILIAL  = '" + SF3->F3_FILIAL + "' "
			cQuery += "   AND FT_TIPOMOV = 'S' "
			cQuery += "   AND FT_SERIE   = '" + SF3->F3_SERIE + "' "
			cQuery += "   AND FT_NFISCAL = '" + SF3->F3_NFISCAL + "' "
//			cQuery += "   AND (FT_ALIQICM <> 0 OR FT_VALICM <> 0) "
			cQuery += "   AND SFT.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY FT_ALIQICM,F4_BASEICM,F4_SITTRIB,F4_CSTISS,F4_CODIGO"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSFT,.T.,.T.)
			While (cAliasSFT)->(!Eof())
				If Empty(cTESBase)
					cTESBase := (cAliasSFT)->F4_CODIGO
				EndIf
				If (cAliasSFT)->FT_ALIQICM <> 0 .Or. (cAliasSFT)->FT_VALICM <> 0
					cTESBase := (cAliasSFT)->F4_CODIGO
					Aadd(aICMS,{(cAliasSFT)->FT_BASEICM,(cAliasSFT)->FT_ALIQICM,(cAliasSFT)->F4_BASEICM,(cAliasSFT)->FT_VALICM,;
								Iif(cEspecie == "RPS",(cAliasSFT)->F4_CSTISS,(cAliasSFT)->F4_SITTRIB)})
				EndIf
				(cAliasSFT)->(DbSkip())
			EndDo
			(cAliasSFT)->(DbCloseArea())
	
			//-- Busca PIS
			cAliasSFT := GetNextAlias()
			cQuery := "SELECT FT_ALIQPIS,SUM(FT_VALPIS) FT_VALPIS,SUM(FT_BASEPIS) FT_BASEPIS,F4_BASEPIS,F4_CSTPIS "
			cQuery += "  FROM " + RetSqlName("SFT") + " SFT "
			cQuery += "  JOIN " + RetSqlName("SD2") + " SD2 "
			cQuery += "    ON D2_FILIAL  = '" + FwxFilial("SD2") + "' "
			cQuery += "   AND D2_DOC     = FT_NFISCAL "
			cQuery += "   AND D2_SERIE   = FT_SERIE "
			cQuery += "   AND D2_CLIENTE = FT_CLIEFOR "
			cQuery += "   AND D2_LOJA    = FT_LOJA "
			cQuery += "   AND D2_COD     = FT_PRODUTO "
			cQuery += "   AND D2_ITEM    = FT_ITEM "
			cQuery += "   AND SD2.D_E_L_E_T_ = ' ' "
			cQuery += "  JOIN " + RetSqlName("SF4") + " SF4 "
			cQuery += "    ON F4_FILIAL = '" + FwxFilial("SF4") + "' "
			cQuery += "   AND F4_CODIGO = D2_TES "
			cQuery += "   AND SF4.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE FT_FILIAL  = '" + SF3->F3_FILIAL + "' "
			cQuery += "   AND FT_TIPOMOV = 'S' "
			cQuery += "   AND FT_SERIE   = '" + SF3->F3_SERIE + "' "
			cQuery += "   AND FT_NFISCAL = '" + SF3->F3_NFISCAL + "' "
			cQuery += "   AND (FT_ALIQPIS <> 0 OR FT_VALPIS <> 0) "
			cQuery += "   AND SFT.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY FT_ALIQPIS,F4_BASEPIS,F4_CSTPIS"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSFT,.T.,.T.)
			While (cAliasSFT)->(!Eof())
				Aadd(aPIS,{(cAliasSFT)->FT_BASEPIS,(cAliasSFT)->FT_ALIQPIS,(cAliasSFT)->F4_BASEPIS,(cAliasSFT)->FT_VALPIS,(cAliasSFT)->F4_CSTPIS})
				(cAliasSFT)->(DbSkip())
			EndDo
			(cAliasSFT)->(DbCloseArea())
	
			//-- Busca COFINS
			cAliasSFT := GetNextAlias()
			cQuery := "SELECT FT_ALIQCOF,SUM(FT_VALCOF) FT_VALCOF,SUM(FT_BASECOF) FT_BASECOF,F4_BASECOF,F4_CSTCOF "
			cQuery += "  FROM " + RetSqlName("SFT") + " SFT "
			cQuery += "  JOIN " + RetSqlName("SD2") + " SD2 "
			cQuery += "    ON D2_FILIAL  = '" + FwxFilial("SD2") + "' "
			cQuery += "   AND D2_DOC     = FT_NFISCAL "
			cQuery += "   AND D2_SERIE   = FT_SERIE "
			cQuery += "   AND D2_CLIENTE = FT_CLIEFOR "
			cQuery += "   AND D2_LOJA    = FT_LOJA "
			cQuery += "   AND D2_COD     = FT_PRODUTO "
			cQuery += "   AND D2_ITEM    = FT_ITEM "
			cQuery += "   AND SD2.D_E_L_E_T_ = ' ' "
			cQuery += "  JOIN " + RetSqlName("SF4") + " SF4 "
			cQuery += "    ON F4_FILIAL = '" + FwxFilial("SF4") + "' "
			cQuery += "   AND F4_CODIGO = D2_TES "
			cQuery += "   AND SF4.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE FT_FILIAL  = '" + SF3->F3_FILIAL + "' "
			cQuery += "   AND FT_TIPOMOV = 'S' "
			cQuery += "   AND FT_SERIE   = '" + SF3->F3_SERIE + "' "
			cQuery += "   AND FT_NFISCAL = '" + SF3->F3_NFISCAL + "' "
			cQuery += "   AND (FT_ALIQCOF <> 0 OR FT_VALCOF <> 0) "
			cQuery += "   AND SFT.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY FT_ALIQCOF,F4_BASECOF,F4_CSTCOF"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSFT,.T.,.T.)
			While (cAliasSFT)->(!Eof())
				Aadd(aCOFINS,{(cAliasSFT)->FT_BASECOF,(cAliasSFT)->FT_ALIQCOF,(cAliasSFT)->F4_BASECOF,(cAliasSFT)->FT_VALCOF,(cAliasSFT)->F4_CSTCOF})
				(cAliasSFT)->(DbSkip())
			EndDo
			(cAliasSFT)->(DbCloseArea())

			//-- Rotina incluida no fonte ate que o DTS resolva a questao de codigo de operacao x TES
			//-- Caso exista parametros cadastrados vale o parametro
			//-- Caso contrario vale o novo conceito de enviar TES + (Cortesia ou Normal)
			If !Empty(cOpeCodNF) .And. !Empty(cOpeCodC) .And. !Empty(cOpeCodN) .And. Empty(cTESBase)
				If cEspecie == "RPS"
					cTESBase := cOpeCodNF
				Else
					If DT6->DT6_DOCTMS == "A"
						cTESBase := cOpeCodC
					Else
						cTESBase := cOpeCodN
					EndIf
				EndIf
			Else
				cTESBase := cTESBase + "-" + Iif(DT6->DT6_DOCTMS == "A","C","F")
			EndIf

			cXMLRet :=	'<BusinessEvent>'
			cXMLRet +=		'<Entity>' + cMsgRet + '</Entity>'
			cXMLRet +=		'<Event>' + cEvent + '</Event>'
			cXMLRet +=		'<Identification>'
			cXMLRet +=			'<Key Name="InternalID">' + cCodInt + '</Key>'
			cXMLRet +=		'</Identification>'
			cXMLRet +=	'</BusinessEvent>'
		
			cXMLRet +=	'<BusinessContent>'
			cXMLRet +=		'<TypeDocument>'     + cTypeDoc + '</TypeDocument>'
//			cXMLRet +=		'<OperationCode>'    + Iif(cEspecie == "RPS",cOpeCodNF,Iif(DT6->DT6_DOCTMS == "A",cOpeCodC,cOpeCodN)) + '</OperationCode>'
			cXMLRet +=		'<OperationCode>'    + cTESBase + '</OperationCode>'
			cXMLRet +=		'<CFOP>'    + cCFOPBase + '</CFOP>'
			
			cXMLRet +=		'<ClientCode>'  + cCliRem + '</ClientCode>'
			cXMLRet +=		'<ClientStore>' + cLojRem + '</ClientStore>'

			cXMLRet +=		'<CancellationDate>' + Iif(cCodSEF=="100",DToS(CtoD('')),DToS(SF3->F3_DTCANC)) + '</CancellationDate>' //aqui

			//-- Busca endereços de coleta e entrega
			aRetEnd := TMSIE76End(SF3->F3_FILIAL,SF3->F3_NFISCAL,SF3->F3_SERIE)
			cXMLRet +=		'<DeliveryCustomerCode>' + aRetEnd[2,12] + '</DeliveryCustomerCode>'
	
			//-- Busca impostos nos livros fiscais
			cXMLRet +=		'<ListOfTaxes>'

			If cTipOpe == "Inutilizacao"	
				cXMLRet +=		'<Tax>'
				cXMLRet +=			'<Taxe> </Taxe>
				cXMLRet +=			'<CalculationBasis>0</CalculationBasis>'
				cXMLRet +=			'<Percentage>0</Percentage>'
				cXMLRet +=			'<ReductionBasedPercent>0</ReductionBasedPercent>'
				cXMLRet +=			'<Value>0</Value>'
				cXMLRet +=			'<CodeTaxSituation> </CodeTaxSituation>'
				cXMLRet +=		'</Tax>'
			Else
				//-- Lista ICMS
				For nCntFor1 := 1 To Len(aICMS)
					cXMLRet +=		'<Tax>'
					cXMLRet +=			'<Taxe>' + Iif(cEspecie == "CTE","ICM","ISS") + '</Taxe>
					cXMLRet +=			'<CalculationBasis>' + AllTrim(Str(aICMS[nCntFor1,1])) + '</CalculationBasis>'
					cXMLRet +=			'<Percentage>' + AllTrim(Str(aICMS[nCntFor1,2])) + '</Percentage>'
					cXMLRet +=			'<ReductionBasedPercent>' + AllTrim(Str(aICMS[nCntFor1,3])) + '</ReductionBasedPercent>'
					cXMLRet +=			'<Value>' + AllTrim(Str(aICMS[nCntFor1,4])) + '</Value>'
					cXMLRet +=			'<CodeTaxSituation>' + aICMS[nCntFor1,5] + '</CodeTaxSituation>'
					cXMLRet +=		'</Tax>'
				Next nCntFor1
		
				//-- Lista PIS
				For nCntFor1 := 1 To Len(aPIS)
					cXMLRet +=		'<Tax>'
					cXMLRet +=			'<Taxe>PIS</Taxe>
					cXMLRet +=			'<CalculationBasis>' + AllTrim(Str(aPIS[nCntFor1,1])) + '</CalculationBasis>'
					cXMLRet +=			'<Percentage>' + AllTrim(Str(aPIS[nCntFor1,2])) + '</Percentage>'
					cXMLRet +=			'<ReductionBasedPercent>' + AllTrim(Str(aPIS[nCntFor1,3])) + '</ReductionBasedPercent>'
					cXMLRet +=			'<Value>' + AllTrim(Str(aPIS[nCntFor1,4])) + '</Value>'
					cXMLRet +=			'<CodeTaxSituation>' + aPIS[nCntFor1,5] + '</CodeTaxSituation>'
					cXMLRet +=		'</Tax>'
				Next nCntFor1
		
				//-- Lista COFINS
				For nCntFor1 := 1 To Len(aCOFINS)
					cXMLRet +=		'<Tax>'
					cXMLRet +=			'<Taxe>COFINS</Taxe>
					cXMLRet +=			'<CalculationBasis>' + AllTrim(Str(aCOFINS[nCntFor1,1])) + '</CalculationBasis>'
					cXMLRet +=			'<Percentage>' + AllTrim(Str(aCOFINS[nCntFor1,2])) + '</Percentage>'
					cXMLRet +=			'<ReductionBasedPercent>' + AllTrim(Str(aCOFINS[nCntFor1,3])) + '</ReductionBasedPercent>'
					cXMLRet +=			'<Value>' + AllTrim(Str(aCOFINS[nCntFor1,4])) + '</Value>'
					cXMLRet +=			'<CodeTaxSituation>' + aCOFINS[nCntFor1,5] + '</CodeTaxSituation>'
					cXMLRet +=		'</Tax>'
				Next nCntFor1
	        EndIf
	        
			cXMLRet +=		'</ListOfTaxes>'


			cXMLRet +=		'<XmlDocument>' + cXMLCTe + '</XmlDocument>'
	
			cXMLRet +=	'</BusinessContent>'	

			//--- Ponto de Entrada para inclusão da Tag CustomInformation
			If lTMS76XML
				cXMLPE := ExecBlock("TMS76XML",.F.,.F.,{SF3->F3_FILIAL,SF3->F3_NFISCAL,SF3->F3_SERIE})
				If ValType(cXMLPE) == "C" .And. !Empty(cXMLPE)
					cXMLRet += cXMLPE
				EndIf	
			EndIf
	
		EndIf

		dDatEnv := dDataBase
		cHorEnv := SubStr(Time(),1,2) + ":" + SubStr(Time(),4,2) + ":" + SubStr(Time(),7,2)
		DJR->(DbSetOrder(1))
		If !DJR->(DbSeek(xFilial("DJR") + "SF3" + "6" + PadR(SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE),Len(DJR->DJR_CONTEU)) + PadR(cTipOpe,Len(DJR->DJR_CODOPE)) + DTos(dDatEnv) + cHorEnv))
			Reclock("DJR",.T.)
			DJR->DJR_FILIAL := xFilial("DJR")
			DJR->DJR_ALIAS  := "SF3"
			DJR->DJR_INDICE := "6"
			DJR->DJR_CONTEU := SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE)
			DJR->DJR_CODOPE := cTipOpe
			DJR->DJR_DATENV := dDatEnv
			DJR->DJR_HORENV := cHorEnv
			DJR->DJR_USUENV := __cUserID
			DJR->DJR_TIPENV := cTipEnv
			DJR->DJR_CODSEF := cCodSEF
			DJR->(MsUnlock())
			DJQ->(DbSetOrder(1))
			lAtuReg := .T.
	
			Aadd(aVetDJR,{DJR->DJR_ALIAS,DJR->DJR_INDICE,DJR->DJR_CONTEU,DJR->DJR_CODOPE,DJR->DJR_DATENV,DJR->DJR_HORENV,DJR->DJR_USUENV,DJR->DJR_TIPENV,DJR->DJR_CODSEF})
	
			If !DJQ->(DbSeek(xFilial("DJQ") + "SF3" + "6" + PadR(SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE),Len(DJQ->DJQ_CONTEU))))
				Reclock("DJQ",.T.)
				DJQ->DJQ_FILIAL := xFilial("DJQ")
				DJQ->DJQ_ALIAS  := "SF3"
				DJQ->DJQ_INDICE := "6"
				DJQ->DJQ_CONTEU := SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE)
				DJQ->(MsUnlock())
			EndIf
		EndIf
		
		
	EndIf

EndIf

AEval(aAreas,{|x,y| RestArea(x)})

Return {lRet,cXMLRet,cMsgRet}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MontaXMLNF ³ Autor ³ Valdemar Roberto ³ Data ³ 02/01/2017  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta XML NFSTe                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MontaXMLNF(aExp01,aExp02,aExp03,aExp04,aExp05,aExp06,      ³±±
±±³Sintaxe   ³            aExp07)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Vetor da DT6                                      ³±±
±±³          ³ aExp02 - Vetor da SF3                                      ³±±
±±³          ³ aExp03 - Vetor da SFT                                      ³±±
±±³          ³ aExp04 - Vetor da SM0                                      ³±±
±±³          ³ aExp05 - Vetor da SA1 do Devedor                           ³±±
±±³          ³ aExp06 - Vetor da SA1 do Destinatario                      ³±±
±±³          ³ aExp07 - Vetor da SB1                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºRetorno   ³ aRet - XML da NFSTe                                        º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSIE76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontaXMLNF(aDT6,aSF3,aSFT,aSM0,aSA1Dev,aSA1Des,aSB1)
Local cXMLNFe := ""

cXMLNFe := '<?xml version="1.0" encoding="UTF-8" ?>'
cXMLNFe += '<procNFSe versao="1.04" tpMsg="retNFSe">'
cXMLNFe += '	<ERP>'
cXMLNFe += '		<RPS versao="2.01" tpMsg="NFSe">'
cXMLNFe += '			<rps id="rps:841000000033" tssversao="2.00">'

cXMLNFe += '				<identificacao>'
cXMLNFe += '					<dthremissao>' + SubStr(DToS(aDT6[4]),1,4) + "-" + SubStr(DToS(aDT6[4]),5,2) + "-" + SubStr(DToS(aDT6[4]),7,2) + "T" + ;
												 SubStr(aDT6[5],1,2) + ":" + SubStr(aDT6[5],3,2) + ":00" + '</dthremissao>'
cXMLNFe += '					<serierps>' + aDT6[3] + '</serierps>'
cXMLNFe += '					<numerorps>' + aDT6[2] + '</numerorps>'
cXMLNFe += '					<tipo>' + aDT6[6] + '</tipo>'
cXMLNFe += '					<situacaorps>' + Iif(Empty(aSFT[1]),"1","2") + '</situacaorps>'
cXMLNFe += '					<tiporecolhe>' + Iif(aSA1Dev[25] == "1","2","1") + '</tiporecolhe>'
cXMLNFe += '					<tipooper>1</tipooper>'
cXMLNFe += '					<competenciarps>' + SubStr(DToS(aDT6[4]),1,4) + "-" + SubStr(DToS(aDT6[4]),5,2) + "-" + SubStr(DToS(aDT6[4]),7,2) + "T" + ;
													SubStr(aDT6[5],1,2) + ":" + SubStr(aDT6[5],3,2) + ":00" + '</competenciarps>'
cXMLNFe += '				</identificacao>'

If aSF3[5] == "101" .Or. aSF3[5] == "102"	//-- Cancelamento ou Inutilização
	cXMLNFe += '				<cancelamento>'
	cXMLNFe += '					<codmotcanc>C999</codmotcanc>'
	cXMLNFe += '					<motcanc>' + aSF3[1] + '</motcanc>'
	cXMLNFe += '				</cancelamento>'
EndIf

cXMLNFe += '				<prestador>'
cXMLNFe += '					<inscmun>' + aSM0[1] + '</inscmun>'
cXMLNFe += '					<cpfcnpj>' + aSM0[2] + '</cpfcnpj>'
cXMLNFe += '					<razao>' + aSM0[3] + '</razao>'
cXMLNFe += '					<fantasia>' + aSM0[4] + '</fantasia>'
cXMLNFe += '					<codmunibge>' + aUFs[aScan(aUFs,{|x| x[1] == aSM0[7]}),2] + aSM0[5] + '</codmunibge>'
cXMLNFe += '					<cidade>' + aSM0[6] + '</cidade>'
cXMLNFe += '					<uf>' + aSM0[7] + '</uf>'
cXMLNFe += '					<email>' + Iif(!Empty(aSM0[8]),aSM0[8],STR0001) + '</email>' //-- "NAO INFORMADO"
cXMLNFe += '					<telefone>' + aSM0[10] + '</telefone>'
cXMLNFe += '					<simpnac>' + Iif(aSM0[11] == "3","2","1") + '</simpnac>'
cXMLNFe += '					<incentcult>' + aSM0[12] + '</incentcult>'
cXMLNFe += '					<numproc>'	+ aSM0[13] + '</numproc>'
cXMLNFe += '					<logradouro>' + FisGetEnd(aSM0[14])[1] + '</logradouro>'
cXMLNFe += '					<numend>' + AllTrim(Str(FisGetEnd(aSM0[14])[2])) + '</numend>'
cXMLNFe += '					<bairro>' + aSM0[16] + '</bairro>'
cXMLNFe += '					<cep>' + aSM0[17] + '</cep>'
cXMLNFe += '				</prestador>'
cXMLNFe += '				<prestacao>'
cXMLNFe += '					<serieprest>' + aDT6[3] + '</serieprest>'
cXMLNFe += '					<logradouro>' + Iif(!Empty(aSA1Des[3]),FisGetEnd(aSA1Des[3])[1],FisGetEnd(aSA1Des[4])[1]) + '</logradouro>'
cXMLNFe += '					<numend>' + Iif(!Empty(aSA1Des[3]),AllTrim(Str(FisGetEnd(aSA1Des[3])[2])),AllTrim(Str(FisGetEnd(aSA1Des[4])[2]))) + '</numend>'
cXMLNFe += '					<codmunibge>' + Iif(!Empty(aSA1Des[3]),aUFs[aScan(aUFs,{|x| x[1] == aSA1Des[13]}),2] + aSA1Des[9],;
																	   aUFs[aScan(aUFs,{|x| x[1] == aSA1Des[12]}),2] + aSA1Des[8]) + '</codmunibge>'
cXMLNFe += '					<municipio>' + Iif(!Empty(aSA1Des[3]),aSA1Des[22],aSA1Des[21]) + '</municipio>'
cXMLNFe += '					<bairro>' + Iif(!Empty(aSA1Des[3]),aSA1Des[7],aSA1Des[6]) + '</bairro>'
cXMLNFe += '					<uf>' + Iif(!Empty(aSA1Des[3]),aSA1Des[13],aSA1Des[12]) + '</uf>'
cXMLNFe += '					<cep>' + Iif(!Empty(aSA1Des[3]),aSA1Des[15],aSA1Des[14]) + '</cep>'
cXMLNFe += '				</prestacao>'
cXMLNFe += '				<tomador>'
cXMLNFe += '					<inscmun>' + aSA1Dev[1] + '</inscmun>'
cXMLNFe += '					<cpfcnpj>' + aSA1Dev[2] + '</cpfcnpj>'
cXMLNFe += '					<razao>' + aSA1Dev[3] + '</razao>'
cXMLNFe += '					<logradouro>' + Iif(!Empty(aSA1Dev[5]),FisGetEnd(aSA1Dev[5])[1],FisGetEnd(aSA1Dev[6])[1]) + '</logradouro>'
cXMLNFe += '					<numend>' + Iif(!Empty(aSA1Dev[5]),AllTrim(Str(FisGetEnd(aSA1Dev[5])[2])),AllTrim(Str(FisGetEnd(aSA1Dev[6])[2]))) + '</numend>'
cXMLNFe += '					<bairro>' + Iif(!Empty(aSA1Dev[5]),aSA1Dev[9],aSA1Dev[8]) + '</bairro>'
cXMLNFe += '					<codmunibge>' + Iif(!Empty(aSA1Dev[5]),aUFs[aScan(aUFs,{|x| x[1] == aSA1Dev[15]}),2] + aSA1Dev[11],;
														   aUFs[aScan(aUFs,{|x| x[1] == aSA1Dev[14]}),2] + aSA1Dev[10]) + '</codmunibge>'
cXMLNFe += '					<cidade>' + Iif(!Empty(aSA1Dev[5]),aSA1Dev[24],aSA1Dev[23]) + '</cidade>'
cXMLNFe += '					<uf>' + Iif(!Empty(aSA1Dev[5]),aSA1Dev[15],aSA1Dev[14]) + '</uf>'
cXMLNFe += '					<cep>' + Iif(!Empty(aSA1Dev[5]),aSA1Dev[17],aSA1Dev[16]) + '</cep>'
cXMLNFe += '					<email>' + aSA1Dev[18] + '</email>'
cXMLNFe += '					<ddd>' + aSA1Dev[19] + '</ddd>'
cXMLNFe += '					<telefone>' + aSA1Dev[20] + '</telefone>'
cXMLNFe += '					<codpais>' + aSA1Dev[21] + '</codpais>'
cXMLNFe += '					<nomepais>BRASIL</nomepais>'
cXMLNFe += '					<estrangeiro>2</estrangeiro>'
cXMLNFe += '					<notificatomador>2</notificatomador>'
cXMLNFe += '					<inscest>'	+ aSA1Dev[22] + '</inscest>'
cXMLNFe += '				</tomador>'
cXMLNFe += '				<servicos>'
cXMLNFe += '					<servico>'
cXMLNFe += '						<codigo>' + aSFT[2] + '</codigo>'
cXMLNFe += '						<coditem>' + aSFT[27] + '</coditem>'
cXMLNFe += '						<aliquota>' + Transform(aSFT[22] / 100,"9.9999") + '</aliquota>'
cXMLNFe += '						<codtrib>' + aSFT[14] + '</codtrib>'
cXMLNFe += '						<discr>' + aSB1[1] + '</discr>'
cXMLNFe += '						<quant>' + Transform(aSFT[15],"9999999999") + '</quant>'
cXMLNFe += '						<valunit>' + Transform(aSFT[16],"999999999999.99") + '</valunit>'
cXMLNFe += '						<valtotal>' + Transform(aSFT[17],"999999999999.99") + '</valtotal>'
cXMLNFe += '						<basecalc>' + Transform(aSFT[25],"999999999999.99") + '</basecalc>'
cXMLNFe += '						<basecalcpis>' + Transform(aSFT[9],"999999999999.99") + '</basecalcpis>'
cXMLNFe += '						<basecalccofins>' + Transform(aSFT[10],"999999999999.99") + '</basecalccofins>'
cXMLNFe += '						<issretido>' + Transform(aSFT[26],"999999999999.99") + '</issretido>'
cXMLNFe += '						<valpis>' + Transform(aSFT[12],"999999999999.99") + '</valpis>'
cXMLNFe += '						<valcof>' + Transform(aSFT[13],"999999999999.99") + '</valcof>'
cXMLNFe += '						<valinss>' + Transform(aSFT[11],"999999999999.99") + '</valinss>'
cXMLNFe += '						<valir>' + Transform(aSFT[19],"999999999999.99") + '</valir>'
cXMLNFe += '						<valcsll>' + Transform(aSFT[20],"999999999999.99") + '</valcsll>'
cXMLNFe += '						<valiss>' + Transform(aSFT[21],"999999999999.99") + '</valiss>'
cXMLNFe += '						<valissret>' + Transform(aSFT[26],"999999999999.99") + '</valissret>'
cXMLNFe += '					</servico>'
cXMLNFe += '				</servicos>'
cXMLNFe += '				<valores>'
cXMLNFe += '					<iss>' + Transform(aSFT[21],"999999999999.99") + '</iss>'
cXMLNFe += '					<issret>' + Transform(aSFT[26],"999999999999.99") + '</issret>'
cXMLNFe += '					<pis>' + Transform(aSFT[12],"999999999999.99") + '</pis>'
cXMLNFe += '					<cofins>' + Transform(aSFT[13],"999999999999.99") + '</cofins>'
cXMLNFe += '					<inss>' + Transform(aSFT[11],"999999999999.99") + '</inss>'
cXMLNFe += '					<ir>' + Transform(aSFT[19],"999999999999.99") + '</ir>'
cXMLNFe += '					<csll>' + Transform(aSFT[20],"999999999999.99") + '</csll>'
cXMLNFe += '					<aliqiss>' + Transform(aSFT[22] / 100,"9.9999") + '</aliqiss>'
cXMLNFe += '					<aliqpis>' + Transform(aSFT[6] / 100,"9.9999") + '</aliqpis>'
cXMLNFe += '					<aliqcof>' + Transform(aSFT[7] / 100,"9.9999") + '</aliqcof>'
cXMLNFe += '					<aliqinss>' + Transform(aSFT[5] / 100,"9.9999") + '</aliqinss>'
cXMLNFe += '					<aliqir>' + Transform(aSFT[23] / 100,"9.9999") + '</aliqir>'
cXMLNFe += '					<aliqcsll>' + Transform(aSFT[24] / 100,"9.9999") + '</aliqcsll>'
cXMLNFe += '					<valtotdoc>' + Transform(aSFT[17],"999999999999.99") + '</valtotdoc>'
cXMLNFe += '				</valores>'
cXMLNFe += '				<faturas>'
cXMLNFe += '				</faturas>'
cXMLNFe += '				<pagamentos>'
cXMLNFe += '				</pagamentos>'

cXMLNFe += '			</rps>'
cXMLNFe += '		</RPS>'
cXMLNFe += '		<retNFSe>'
cXMLNFe += '			<nRPS>' + aDT6[2] + '</nRPS>'
cXMLNFe += '			<nSerieRPS>' + aDT6[3] + '</nSerieRPS>'
cXMLNFe += '			<cnpjPrest>' + aSM0[2] + '</cnpjPrest>'
cXMLNFe += '			<nNFSe>' + aSF3[1] + '</nNFSe>'
cXMLNFe += '			<dtEmisNFSe>' + SubStr(DToS(aSF3[3]),1,4) + "-" + SubStr(DToS(aSF3[3]),5,2) + "-" + SubStr(DToS(aSF3[3]),7,2) + "T" + ;
										SubStr(aSF3[4],1,2) + ":" + SubStr(aSF3[4],3,2) + ":00" + '</dtEmisNFSe>'
cXMLNFe += '			<nProt>' + aSF3[2] + '</nProt>'
cXMLNFe += '			<tpRPS>1</tpRPS>'
cXMLNFe += '		</retNFSe>'
cXMLNFe += '	</ERP>'
cXMLNFe += '</procNFSe>'

Return cXMLNFe

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MontaXMLAn ³ Autor ³ Valdemar Roberto ³ Data ³ 01/02/2017  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta XML Anulação                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MontaXMLAn(aExp01,aExp02,aExp03,aExp04,aExp05,aExp06,      ³±±
±±³Sintaxe   ³            aExp07,aExp08,aExp09,aExp10)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Vetor da SM0                                      ³±±
±±³          ³ aExp02 - Vetor da SA1 do Devedor                           ³±±
±±³          ³ aExp03 - Vetor da SA1 do Destinatario                      ³±±
±±³          ³ aExp04 - Vetor da SA1 do Remetente                         ³±±
±±³          ³ aExp05 - Vetor da SF3                                      ³±±
±±³          ³ aExp06 - Vetor da SFT                                      ³±±
±±³          ³ aExp07 - Vetor da DT6                                      ³±±
±±³          ³ aExp08 - Vetor da SF1                                      ³±±
±±³          ³ aExp09 - Vetor da DTC                                      ³±±
±±³          ³ aExp10 - Vetor da DT8                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºRetorno   ³ aRet - XML do Cte de Anulação                              º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSIE76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontaXMLAn(aSM0,aSA1Dev,aSA1Des,aSA1Rem,aSF3,aSFT,aDT6,aSF1,aDTC,aDT8)
Local cXMLAnu  := ""
Local nLinha   := 0
Local nCntFor1 := 0
Local cMVSINAC := SuperGetMv("MV_CODREG")

cXMLAnu := '<?xml version="1.0"?>'
cXMLAnu += '<CTe xmlns="http://www.portalfiscal.inf.br/cte">'
cXMLAnu += '	<infCte versao="2.00" Id="CTe' + aSF1[1] + '">'
cXMLAnu += '		<ide>'
cXMLAnu += '			<cUF>' + aUFs[aScan(aUFs,{|x| x[1] == aSA1Dev[3]}),2] + '</cUF>'
cXMLAnu += '			<cCT>' + aSF1[2] + '</cCT>'
cXMLAnu += '			<CFOP>' + aSFT[4] + '</CFOP>'
cXMLAnu += '			<natOp>' + aSFT[5] + '</natOp>'
cXMLAnu += '			<mod>57</mod>'
cXMLAnu += '			<serie>' + aSF3[2] + '</serie>'
cXMLAnu += '			<nCT>' + aSF3[1] + '</nCT>'
cXMLAnu += '			<dhEmi>' + SubStr(DToS(aSF3[3]),1,4) + "-" + SubStr(DToS(aSF3[3]),5,2) + "-" + SubStr(DToS(aSF3[3]),7,2) + "T" + ;
								   SubStr(aSF3[4],1,2) + ":" + SubStr(aSF3[4],3,2) + ":00" + '</dhEmi>'
cXMLAnu += '			<tpImp>1</tpImp>'
cXMLAnu += '			<tpEmis>1</tpEmis>'
cXMLAnu += '			<cDV>' + aSF1[3] + '</cDV>'
cXMLAnu += '			<tpAmb>' + aSM0[1] + '</tpAmb>'
cXMLAnu += '			<tpCTe>2</tpCTe>'
cXMLAnu += '			<procEmi>0</procEmi>'
cXMLAnu += '			<verProc>' + aSM0[2] + '</verProc>'
cXMLAnu += '			<cMunEnv>' + aUFs[aScan(aUFs,{|x| x[1] == aSA1Dev[3]}),2] + aSA1Dev[1] + '</cMunEnv>'
cXMLAnu += '			<xMunEnv>' + aSA1Dev[2] + '</xMunEnv>'
cXMLAnu += '			<UFEnv>' + aSA1Dev[3] + '</UFEnv>'
cXMLAnu += '			<modal>' + aDT6[3] + '</modal>'
cXMLAnu += '			<tpServ>' + aDTC[1] + '</tpServ>'
cXMLAnu += '			<cMunIni>' + aUFs[aScan(aUFs,{|x| x[1] == aSA1Rem[9]}),2] + aSA1Rem[10] + '</cMunIni>'
cXMLAnu += '			<xMunIni>' + aSA1Rem[13] + '</xMunIni>'
cXMLAnu += '			<UFIni>' + aSA1Rem[9] + '</UFIni>'
cXMLAnu += '			<cMunFim>' + Iif(!Empty(aSA1Des[18]),aUFs[aScan(aUFs,{|x| x[1] == aSA1Des[14]}),2] + aSA1Des[13],;
															 aUFs[aScan(aUFs,{|x| x[1] == aSA1Des[9]}),2] + aSA1Des[10]) + '</cMunFim>'
cXMLAnu += '			<xMunFim>' + Iif(!Empty(aSA1Des[18]),aSA1Des[20],aSA1Des[17]) + '</xMunFim>'
cXMLAnu += '			<UFFim>' + Iif(!Empty(aSA1Des[18]),aSA1Des[9],aSA1Des[14]) + '</UFFim>'
cXMLAnu += '			<retira>0</retira>'
cXMLAnu += '			<xDetRetira>NAO SE APLICA</xDetRetira>'
cXMLAnu += '			<toma03>'
cXMLAnu += '				<toma>' + aDT6[4] + '</toma>'
cXMLAnu += '			</toma03>'
cXMLAnu += '		</ide>'
cXMLAnu += '		<compl>'
cXMLAnu += '			<xObs>' + aSF1[4] + '</xObs>'
cXMLAnu += '		</compl>'
cXMLAnu += '		<emit>'
cXMLAnu += '			<CNPJ>' + aSA1Dev[4] + '</CNPJ>'
cXMLAnu += '			<IE>' + aSA1Dev[5] + '</IE>'
cXMLAnu += '			<xNome>' + aSA1Dev[6] + '</xNome>'
cXMLAnu += '			<xFant>' + aSA1Dev[7] + '</xFant>'
cXMLAnu += '			<enderEmit>'
cXMLAnu += '				<xLgr>' + FisGetEnd(aSA1Dev[8])[1] + '</xLgr>'
cXMLAnu += '				<nro>' + AllTrim(Str(FisGetEnd(aSA1Dev[8])[2])) + '</nro>'
cXMLAnu += '				<xBairro>' + aSA1Dev[9] + '</xBairro>'
cXMLAnu += '				<cMun>' + aUFs[aScan(aUFs,{|x| x[1] == aSA1Dev[3]}),2] + aSA1Dev[1] + '</cMun>'
cXMLAnu += '				<xMun>' + aSA1Dev[2] + '</xMun>'
cXMLAnu += '				<CEP>' + aSA1Dev[10] + '</CEP>'
cXMLAnu += '				<UF>' + aSA1Dev[3] + '</UF>'
cXMLAnu += '				<fone>' + aSA1Dev[11] + '</fone>'
cXMLAnu += '			</enderEmit>'
cXMLAnu += '		</emit>'
cXMLAnu += '		<rem>'
cXMLAnu += '			<CNPJ>' + aSA1Rem[1] + '</CNPJ>'
cXMLAnu += '			<IE>' + aSA1Rem[2] + '</IE>'
cXMLAnu += '			<xNome>' + aSA1Rem[3] + '</xNome>'
cXMLAnu += '			<xFant>' + aSA1Rem[4] + '</xFant>'
cXMLAnu += '			<fone>' + AllTrim(aSA1Rem[5] + aSA1Rem[6]) + '</fone>'
cXMLAnu += '			<enderReme>'
cXMLAnu += '				<xLgr>' + FisGetEnd(aSA1Rem[7])[1] + '</xLgr>'
cXMLAnu += '				<nro>' + AllTrim(Str(FisGetEnd(aSA1Rem[7])[2])) + '</nro>'
cXMLAnu += '				<xBairro>' + aSA1Rem[8] + '</xBairro>'
cXMLAnu += '				<cMun>' + aUFs[aScan(aUFs,{|x| x[1] == aSA1Rem[9]}),2] + aSA1Rem[10] + '</cMun>'
cXMLAnu += '				<xMun>' + aSA1Rem[13] + '</xMun>'
cXMLAnu += '				<CEP>' + aSA1Rem[11] + '</CEP>'
cXMLAnu += '				<UF>' + aSA1Rem[9] + '</UF>'
cXMLAnu += '				<cPais>' + aSA1Rem[12] + '</cPais>'
cXMLAnu += '				<xPais>BRASIL</xPais>'
cXMLAnu += '			</enderReme>'
cXMLAnu += '		</rem>'
cXMLAnu += '		<dest>'
cXMLAnu += '			<CNPJ>' + aSA1Des[1] + '</CNPJ>'
cXMLAnu += '			<IE>' + aSA1Des[2] + '</IE>'
cXMLAnu += '			<xNome>' + aSA1Des[3] + '</xNome>'
cXMLAnu += '			<fone>' + aSA1Des[6] + '</fone>'
cXMLAnu += '			<enderDest>'
cXMLAnu += '				<xLgr>' + Iif(Empty(aSA1Des[18]),FisGetEnd(aSA1Des[7])[1],FisGetEnd(aSA1Des[18])[1]) + '</xLgr>'
cXMLAnu += '				<nro>' + Iif(Empty(aSA1Des[18]),AllTrim(Str(FisGetEnd(aSA1Des[7])[2])),AllTrim(Str(FisGetEnd(aSA1Des[18])[2]))) + '</nro>'
cXMLAnu += '				<xBairro>' + Iif(Empty(aSA1Des[18]),aSA1Des[8],aSA1Des[19]) + '</xBairro>'
cXMLAnu += '				<cMun>' + Iif(!Empty(aSA1Des[18]),aUFs[aScan(aUFs,{|x| x[1] == aSA1Des[14]}),2] + aSA1Des[13],;
															  aUFs[aScan(aUFs,{|x| x[1] == aSA1Des[9]}),2] + aSA1Des[10]) + '</cMun>'
cXMLAnu += '				<xMun>' + Iif(Empty(aSA1Des[18]),aSA1Des[20],aSA1Des[17]) + '</xMun>'
cXMLAnu += '				<CEP>' + Iif(Empty(aSA1Des[18]),aSA1Des[11],aSA1Des[15]) + '</CEP>'
cXMLAnu += '				<UF>' + Iif(Empty(aSA1Des[18]),aSA1Des[9],aSA1Des[14]) + '</UF>'
cXMLAnu += '				<cPais>' + aSA1Des[12] + '</cPais>'
cXMLAnu += '				<xPais>BRASIL</xPais>'
cXMLAnu += '			</enderDest>'
cXMLAnu += '		</dest>'
cXMLAnu += '		<vPrest>'
If (nLinha := aScan(aDT8,{|x| x[1] == "TF"})) > 0
	cXMLAnu += '			<vTPrest>' + AllTrim(Str(aDT8[nLinha,3])) + '</vTPrest>'
	cXMLAnu += '			<vRec>' + AllTrim(Str(aDT8[nLinha,3])) + '</vRec>'
EndIf
For nCntFor1 := 1 To Len(aDT8)
	If aDT8[nCntFor1,1] != "TF"
		cXMLAnu += '			<Comp>'
		cXMLAnu += '				<xNome>' + aDT8[nCntFor1,2] + '</xNome>'
		cXMLAnu += '				<vComp>' + AllTrim(Str(aDT8[nCntFor1,3])) + '</vComp>'
		cXMLAnu += '			</Comp>'
	EndIf
Next nCntFor1
cXMLAnu += '		</vPrest>'
cXMLAnu += '		<imp>'
cXMLAnu += '			<ICMS>'
cXMLAnu += '				<ICMS00>'
cXMLAnu += '					<CST>00</CST>'
cXMLAnu += '					<vBC>' + AllTrim(Str(aSFT[1])) + '</vBC>'
cXMLAnu += '					<pICMS>' + AllTrim(Str(aSFT[2])) + '</pICMS>'
cXMLAnu += '					<vICMS>' + AllTrim(Str(aSFT[3])) + '</vICMS>'
cXMLAnu += '				</ICMS00>'
cXMLAnu += '			</ICMS>'
cXMLAnu += '		</imp>'
cXMLAnu += '		<infCteAnu>'
cXMLAnu += '			<chCte>' + aDT6[1] + '</chCte>'
cXMLAnu += '			<dEmi>' + SubStr(DToS(aDT6[2]),1,4) + "-" + SubStr(DToS(aDT6[2]),5,2) + "-" + SubStr(DToS(aDT6[2]),7,2) + '</dEmi>'
cXMLAnu += '		</infCteAnu>'
cXMLAnu += '	</infCte>'
/*cXMLAnu += '	<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">'
cXMLAnu += '		<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">'
cXMLAnu += '			<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
cXMLAnu += '			<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>'
cXMLAnu += '			<Reference URI="#CTe' + aSF1[1] + '">'
cXMLAnu += '				<Transforms>'
cXMLAnu += '					<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>'
cXMLAnu += '					<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
cXMLAnu += '				</Transforms>'
cXMLAnu += '				<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>'
cXMLAnu += '				<DigestValue>ZqZAU+k0l776o6ORwIHvBBasRJ0=</DigestValue>'
cXMLAnu += '			</Reference>'
cXMLAnu += '		</SignedInfo>'
cXMLAnu += '		<SignatureValue>TsGDVtkv3gdnXC5MS7hRGci7hR9BS2OpaeN1CmoR7xeujeBh9XSbUCzCpfXCt1S3+cXij9fn7QgV6Ztf2qsxRllByc0EALNhsrJ7Rv2Cb/FYEkOPqBBhlfyPGJvWqCf0XLH3ElmjGb/BIJs6naOzQkFx3LYYMiQ2XBHk0XBqmdB4OS3JIehvMr1KnewxpFl2bBhNppDhh2LH0ixVIJYqjodS089pPo6ik/0qoJQpQESDPqBiG9FxxvnkdMyxHKG1f2FziISFrpFQ/xXNZeynRb13oL/UcKwGxIBczDBNGtVYd9zUfdNjh2z0EwqgT3bTasCoQGzsWOj4iwkwV//bEw==</SignatureValue>'
cXMLAnu += '		<KeyInfo>'
cXMLAnu += '			<X509Data>'
cXMLAnu += '				<X509Certificate>MIIITDCCBjSgAwIBAgIQQVAyFf1mzU8jHf/wwx/nWTANBgkqhkiG9w0BAQsFADB4MQswCQYDVQQGEwJCUjETMBEGA1UEChMKSUNQLUJyYXNpbDE2MDQGA1UECxMtU2VjcmV0YXJpYSBkYSBSZWNlaXRhIEZlZGVyYWwgZG8gQnJhc2lsIC0gUkZCMRwwGgYDVQQDExNBQyBDZXJ0aXNpZ24gUkZCIEc0MB4XDTE2MDkwMjAwMDAwMFoXDTE3MDkwMTIzNTk1OVowgeUxCzAJBgNVBAYTAkJSMRMwEQYDVQQKFApJQ1AtQnJhc2lsMQswCQYDVQQIEwJNRzEPMA0GA1UEBxQGTEFWUkFTMTYwNAYDVQQLFC1TZWNyZXRhcmlhIGRhIFJlY2VpdGEgRmVkZXJhbCBkbyBCcmFzaWwgLSBSRkIxFjAUBgNVBAsUDVJGQiBlLUNOUEogQTExIjAgBgNVBAsUGUF1dGVudGljYWRvIHBvciBBUiBOSUFMUEExLzAtBgNVBAMTJkVYUFJFU1NPIE5FUE9NVUNFTk8gUyBBOjE5MzY4OTI3MDAwMTA3MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmOlXj4F6Tx4vi3ljqpw6LQeJJO03ILDWkZum36PBdQq9Re7jg6Rnvg7SPEoon4P3VijF019QaXHAuz/xSyTLKLAlYyAMki1vY19xfxlcqxrYlOsVARDfJbWccVM3BxySHyr3XlqdlM6UFoWhe1O4UgyhQWSodZqhNetQDSWauCAdKbjCzx13WZ0Q32hbS6ct9N5FV+kXrdtGi3IER5HXkFHdydLh6gSmqZ1+tW2t2JwUOpxfrngEhoroX8O91rt7ZZ98/WhUkyEq27JOaWdbDjYatwtTow+2PmlQp23ObRrMz4DpfUwy+fxud0F/MhGwvxfgYDO3pdJl7LDyq3o/wQIDAQABo4IDYjCCA14wgccGA1UdEQSBvzCBvKA9BgVgTAEDBKA0BDIyNjAzMTk2ODU4MzMxMzQ0NjM0MDAwMDAwMDAwMDAwMDAwMDBNRzM3NDQzMDdTU1BNR6AhBgVgTAEDAqAYBBZBR05BTERPIERFIFNPVVpBIEZJTEhPoBkGBWBMAQMDoBAEDjE5MzY4OTI3MDAwMTA3oBcGBWBMAQMHoA4EDDAwMDAwMDAwMDAwMIEkdHJpYnV0YXJpb0BleHByZXNzb25lcG9tdWNlbm8uY29tLmJyMAkGA1UdEwQCMAAwHwYDVR0jBBgwFoAULpHq1m3lslmC3DiFKXY0FlY80D4wDgYDVR0PAQH/BAQDAgXgMH8GA1UdIAR4MHYwdAYGYEwBAgEMMGowaAYIKwYBBQUHAgEWXGh0dHA6Ly9pY3AtYnJhc2lsLmNlcnRpc2lnbi5jb20uYnIvcmVwb3NpdG9yaW8vZHBjL0FDX0NlcnRpc2lnbl9SRkIvRFBDX0FDX0NlcnRpc2lnbl9SRkIucGRmMIIBFgYDVR0fBIIBDTCCAQkwV6BVoFOGUWh0dHA6Ly9pY3AtYnJhc2lsLmNlcnRpc2lnbi5jb20uYnIvcmVwb3NpdG9yaW8vbGNyL0FDQ2VydGlzaWduUkZCRzQvTGF0ZXN0Q1JMLmNybDBWoFSgUoZQaHR0cDovL2ljcC1icmFzaWwub3V0cmFsY3IuY29tLmJyL3JlcG9zaXRvcmlvL2xjci9BQ0NlcnRpc2lnblJGQkc0L0xhdGVzdENSTC5jcmwwVqBUoFKGUGh0dHA6Ly9yZXBvc2l0b3Jpby5pY3BicmFzaWwuZ292LmJyL2xjci9DZXJ0aXNpZ24vQUNDZXJ0aXNpZ25SRkJHNC9MYXRlc3RDUkwuY3JsMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDBDCBmwYIKwYBBQUHAQEEgY4wgYswXwYIKwYBBQUHMAKGU2h0dHA6Ly9pY3AtYnJhc2lsLmNlcnRpc2lnbi5jb20uYnIvcmVwb3NpdG9yaW8vY2VydGlmaWNhZG9zL0FDX0NlcnRpc2lnbl9SRkJfRzQucDdjMCgGCCsGAQUFBzABhhxodHRwOi8vb2NzcC5jZXJ0aXNpZ24uY29tLmJyMA0GCSqGSIb3DQEBCwUAA4ICAQCTwV8gh1r9lKJAj4waHUM/cMClaQfPJz6vJ+lJujgCDh8/f43T6ASQDySFEjdCFH85mlZuGfbpvNXxvz/puqw8Oqoc4i6b2C3FeVZAAdK27jLfiPz999lXviCQcR9HJDPWG/Fzix9wesSDh0K4GuBsKaOgxXwP+XhbD2+fh1jpKr26cnbDXMs4PF3+fQ9JruxX7L6gYmdGMZvtIo26HEZnjYUhgya01UGk7uPexjmo3ob1TzRVlQIFm1J7a4O/es20wBXCHq7bLyYDBteQrD0gsFdzXu4ygK+fcRG+hb9mOV/qUG50Sz378uL2x95sLkxWWdeKJ8PuMnOOzsceGbCEb95HRagqT1DFnFv/ayPqPKSpPnexKgUij9JkbDtyit9qA7LQPTv2Yt4wmR4X+Sk4PL4aAid3/4wNtC7xfURFQ2vaDNjoqT81Qd/FUq7M3r3luKfdWUNHdpcYV2rFB/A66KfIBH7LqGy7RrTZv0jSU5K4FqPpux/8LehXVp7hVMBiMf7mqmazYvRufUMSWVTtIEwlJTQlX/vn+w375grQop/YNI7utt4S2pdwzFtiK3gPZ6h1vOry1hQW2jpJKg4qfzfpJxZ87/HvlM/JiaSnAQNw9/3mAxnOAgxpP6t070Kb3+qSLHvxpm7OJgEnHRS5oYiaJPCSO7I301F4XJkhEA==</X509Certificate>'
cXMLAnu += '			</X509Data>'
cXMLAnu += '		</KeyInfo>'
cXMLAnu += '	</Signature>'*/
cXMLAnu += '</CTe>'

Return cXMLAnu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSIE76Sta ³ Autor ³ Valdemar Roberto ³ Data ³ 02/02/2017  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna variáveis estaticas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSIE76Sta(cExp01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Variável que será retornada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSIE76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSIE76Sta(cNomVar)
Local cRet := ""

DEFAULT cNomVar := ""

If !Empty(cNomVar)
	cRet := &(cNomVar)
EndIf

Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSIE76Grv ³ Autor ³ Leandro Paulino ³ Data ³ 13/03/2017  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava tabelas DJR e DJR 		                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSIE76Sta(cExp01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Variável que será retornada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSIE76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSIE76Grv(cAlias,cIndice,cConteudo,cCodOpe,dDatEnv,cHorEnv,cTipEnv,cCodSef)

DEFAULT cAlias		:= ''
DEFAULT cIndice 	:= ''
DEFAULT cConteudo	:= ''
DEFAULT cCodOpe		:= ''
DEFAULT dDatEnv		:= dDataBase
DEFAULT cHorEnv		:= cHorEnv := SubStr(Time(),1,2) + ":" + SubStr(Time(),4,2) + ":" + SubStr(Time(),7,2)
DEFAULT cTipEnv		:= '1'
DEFAULT cCodSef		:= ''

DJR->(DbSetOrder(1))
If !DJR->(DbSeek(xFilial("DJR") + cAlias + cIndice + PadR(cConteudo,Len(DJR->DJR_CONTEU)) + PadR(cCodOpe,Len(DJR->DJR_CODOPE)) + DTos(dDatEnv) + cHorEnv))
	Reclock("DJR",.T.)
	DJR->DJR_FILIAL := xFilial("DJR")
	DJR->DJR_ALIAS  := cAlias
	DJR->DJR_INDICE := cIndice
	DJR->DJR_CONTEU := cConteudo
	DJR->DJR_CODOPE := cCodOpe
	DJR->DJR_DATENV := dDatEnv
	DJR->DJR_HORENV := cHorEnv
	DJR->DJR_USUENV := __cUserID
	DJR->DJR_TIPENV := cTipEnv
	DJR->DJR_CODSEF := cCodSEF
	DJR->(MsUnlock())
	DJQ->(DbSetOrder(1))
	lAtuReg := .T.

	Aadd(aVetDJR,{DJR->DJR_ALIAS,DJR->DJR_INDICE,DJR->DJR_CONTEU,DJR->DJR_CODOPE,DJR->DJR_DATENV,DJR->DJR_HORENV,DJR->DJR_USUENV,DJR->DJR_TIPENV,DJR->DJR_CODSEF})
     
     DJQ->(DbSetOrder(1)) //| DJQ_FILIAL+DJQ_ALIAS+DJQ_INDICE+DJQ_CONTEU
     //If !DJQ->(DbSeek(xFilial("DJQ") + "SF3" + "6" + PadR(SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE),Len(DJQ->DJQ_CONTEU))))
     If !DJQ->(DbSeek(xFilial("DJQ") + cAlias + cIndice + PadR(cConteudo, Len(DJQ->DJQ_CONTEU)))) 
          Reclock("DJQ",.T.)
          DJQ->DJQ_FILIAL := xFilial("DJQ")
          DJQ->DJQ_ALIAS  := cAlias
          DJQ->DJQ_INDICE := cIndice
          DJQ->DJQ_CONTEU := cConteudo
          DJQ->(MsUnlock())
     EndIf

 EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSIE76End ³ Autor ³ Valdemar Roberto ³ Data ³ 18/04/2017  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca endereços de coleta/entrega                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSIE76End(cExp01,cExp02,cExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Filial de Origem do Documento                     ³±±
±±³          ³ cExp02 - Número do Documento                               ³±±
±±³          ³ cExp03 - Série do Documento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºRetorno   ³ aRet - Vetor com os dados dos endereços de coleta/entrega  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSIE76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSIE76End(cFilDoc,cDoc,cSerie)
Local aRet   := {}
Local aAreas := {DUE->(GetArea()),DUL->(GetArea()),DT5->(GetArea()),DTC->(GetArea()),SA1->(GetArea()),GetArea()}

//-- Inicializa Vetor de Retorno
Aadd(aRet,{" "," "," "," "," "," "," "," "," "," "," "," "})
Aadd(aRet,{" "," "," "," "," "," "," "," "," "," "," "," "})

DTC->(DbSetOrder(3))
If DTC->(DbSeek(xFilial("DTC") + cFilDoc + cDoc + cSerie))
	//-- Define Endereço de Coleta
	SA1->(DbSetOrder(1))
	DT5->(DbSetOrder(1))
	DUE->(DbSetOrder(1))
	DUL->(DbSetOrder(3))
	If DTC->DTC_SELORI == "1"	//-- Transportadora
		aRet[1,01] := "1"
		aRet[1,02] := SM0->M0_NOME
		aRet[1,03] := SM0->M0_ENDENT
		aRet[1,04] := SM0->M0_COMPENT
		aRet[1,05] := SM0->M0_BAIRENT
		aRet[1,06] := SM0->M0_CIDENT
		aRet[1,07] := SM0->M0_ESTENT
		aRet[1,08] := SM0->M0_CEPENT
		aRet[1,09] := SM0->M0_CODMUN
		aRet[1,10] := SM0->M0_CGC
		aRet[1,11] := SM0->M0_INSC
		aRet[1,12] := " "
	ElseIf DTC->DTC_SELORI == "2"	//-- Cliente Remetente
		If SA1->(DbSeek(xFilial("SA1") + DTC->DTC_CLIREM + DTC->DTC_LOJREM))
			aRet[1,01] := "2"
			aRet[1,02] := SA1->A1_NOME
			aRet[1,03] := SA1->A1_END
			aRet[1,04] := " "
			aRet[1,05] := SA1->A1_BAIRRO
			aRet[1,06] := SA1->A1_MUN
			aRet[1,07] := SA1->A1_EST
			aRet[1,08] := SA1->A1_CEP
			aRet[1,09] := SA1->A1_COD_MUN
			aRet[1,10] := SA1->A1_CGC
			aRet[1,11] := SA1->A1_INSCR
			aRet[1,12] := " "
		EndIf
	Else	//-- Local de Coleta
		If DT5->(DbSeek(xFilial("DT5") + DTC->DTC_FILCFS + DTC->DTC_NUMSOL))
			If DUE->(DbSeek(xFilial("DUE") + DT5->DT5_CODSOL))
				If Empty(DT5->DT5_SEQEND)	//-- Não Possui Sequencia de Endereço
					aRet[1,01] := "3"
					aRet[1,02] := DUE->DUE_NOME
					aRet[1,03] := DUE->DUE_END
					aRet[1,04] := " "
					aRet[1,05] := DUE->DUE_BAIRRO
					aRet[1,06] := DUE->DUE_MUN
					aRet[1,07] := DUE->DUE_EST
					aRet[1,08] := DUE->DUE_CEP
					aRet[1,09] := DUE->DUE_CODMUN
					aRet[1,10] := DUE->DUE_CGC
					aRet[1,11] := DUE->DUE_INSCR
					aRet[1,12] := " "
				Else	//-- Não Possui Sequencia de Endereço
					aRet[1,01] := "3"
					aRet[1,02] := DUE->DUE_NOME
					aRet[1,03] := DUL->DUL_END
					aRet[1,04] := " "
					aRet[1,05] := DUL->DUL_BAIRRO
					aRet[1,06] := DUL->DUL_MUN
					aRet[1,07] := DUL->DUL_EST
					aRet[1,08] := DUL->DUL_CEP
					aRet[1,09] := DUL->DUL_CODMUN
					aRet[1,10] := DUL->DUL_CGC
					aRet[1,11] := DUL->DUL_INSCR
					aRet[1,12] := DT5->DT5_SEQEND
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Define endereço de entrega
	DUL->(DbSetOrder(2))
	If SA1->(DbSeek(xFilial("SA1") + DTC->DTC_CLIDES + DTC->DTC_LOJDES))
		If Empty(DTC->DTC_SQEDES)	//-- Não Possui Endereço de Entrega na Nota Fiscal
			aRet[2,01] := "2"
			aRet[2,02] := SA1->A1_NOME
			aRet[2,03] := SA1->A1_END
			aRet[2,04] := " "
			aRet[2,05] := SA1->A1_BAIRRO
			aRet[2,06] := SA1->A1_MUN
			aRet[2,07] := SA1->A1_EST
			aRet[2,08] := SA1->A1_CEP
			aRet[2,09] := SA1->A1_COD_MUN
			aRet[2,10] := SA1->A1_CGC
			aRet[2,11] := SA1->A1_INSCR
			aRet[2,12] := " "
		Else	//-- Possui Endereço de Entrega na Nota Fiscal
			If DUL->(DbSeek(xFilial("DUL") + DTC->(DTC_CLIDES + DTC_LOJDES + DTC_SQEDES))) .And. Empty(DUL->DUL_CODRED+DUL->DUL_LOJRED)
				aRet[2,01] := "3"
				aRet[2,02] := SA1->A1_NOME
				aRet[2,03] := DUL->DUL_END
				aRet[2,04] := " "
				aRet[2,05] := DUL->DUL_BAIRRO
				aRet[2,06] := DUL->DUL_MUN
				aRet[2,07] := DUL->DUL_EST
				aRet[2,08] := DUL->DUL_CEP
				aRet[2,09] := DUL->DUL_CODMUN
				aRet[2,10] := DUL->DUL_CGC
				aRet[2,11] := DUL->DUL_INSCR
				aRet[2,12] := DTC->DTC_SQEDES
			EndIf
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x)})

Return Aclone(aRet)
