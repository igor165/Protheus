#INCLUDE "FileIO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBXFUNC.CH"
#Include "TopConn.ch"

Static _baDtComp   		:= {|| CtbCacheIs(1) }
Static _baDtInUse  		:= {|| CtbCacheIs(2) }
Static _bCtbAmarra 		:= {|| CtbCacheIs(3) }
Static _bCtbPosic  		:= {|| CtbCacheIs(4) }
Static _baCtbMInUse		:= {|| CtbCacheIs(5) }
Static _baCtbDtInUse	:= {|| CtbCacheIs(6) }
Static _baCtbValidDt	:= {|| CtbCacheIs(7) }
Static _bEntdBloq 		:= {|| CtbCacheIs(8) }
Static _bPerCache 		:= {|| CtbCacheIs(9) }
Static _dFechDom // Variavel para arquivo 623 rep dominicana

Static _aAtivCT1
Static _aAtivCTD
Static _aAtivCTH
Static _aAtivCTT

Static __lCacheIs
Static __lAtivComp

Static _cGetDB := Upper(TcGetDb())
Static _oCtbCache

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBLCUSO  ºAutor  ³Marcello            ºFecha ³ 23/04/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o sistema utiliza o conceito de lancamentos     º±±
±±º          ³complementares.                                             º±±
±±º          ³Retorno:    lRet (L) - .T. usa lancamentos complementares   º±±
±±º          ³                       .F. nao usa                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTB - Lacamentos complementares                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBLCUso()
Local lRet	:= .T.

lRet := IIF(cPaisLoc $ "COL/PER", .T., .F.)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBLCADCT2ºAutor  ³Marcello            ºFecha ³ 23/04/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alimenta o array com os lancamentos contabeis para a        º±±
±±º          ³geracao dos lancamentos complementares.                     º±±
±±º          ³                                                            º±±
±±º          ³Parametros: nRegCT2 (N) - numero do registro do lancamento  º±±
±±º          ³            contabil no arquivo CT2.                        º±±
±±º          ³Retorno:    lRet (L) - .T. operacao feita com sucesso       º±±
±±º          ³                       .F. falha na operacao                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTB - Lancamentos complementares                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBLCAdCT2(nRegCT2,cHist)
Local lRet		:= .F.
Local nRegAnt	:= 0
Local nPos		:= 0

Default nRegCT2	:= 0
Default cHist	:= ""

	If nRegCT2 <> 0
		If Type("__aCT2LC") <> "A"
			__aCT2LC := {}
		Endif
		nRegAnt := CT2->(Recno())
		If nRegAnt <> nRegCT2
			CT2->(DbGoto(nRegCT2))
		Endif
		nPos := Ascan(__aCT2LC,{|alanc| alanc[1] == nRegCT2})
		If nPos == 0
			Aadd(__aCT2LC,{nRegCT2,cHist})
		Else
			__aCT2LC[nPos,2] := cHist
		Endif
		If nRegAnt <> nRegCT2
			CT2->(DbGoto(nRegAnt))
		Endif
		lRet := .T.
	Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBLCDELLCºAutor  ³Marcello            ºFecha ³ 23/04/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Apaga os lancamentos complementares, referentes ao          º±±
±±º          ³lancamento principal na tabela CT2.                         º±±
±±º          ³                                                            º±±
±±º          ³Parametros: nRegCT2 (N) - numero do registro do lancamento  º±±
±±º          ³            contabil no arquivo CT2.                        º±±
±±º          ³            lDelCV3CTK (L) - indica se os registros das     º±±
±±º          ³            tabelas CV3 e CTK tambem devem ser apagados     º±±
±±º          ³Retorno:    lRet (L) - .T. operacao feita com sucesso       º±±
±±º          ³                       .F. falha na operacao                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTB - Lancamentos complementares                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBLCDelLC(nRegCT2,lDelCV3CTK)
Local cChave	:= ""
Local cSequ		:= ""
Local dDtSeq	:= Ctod("//")
Local cFilCT2	:= ""
Local cFilCV3	:= ""
Local cFilCTK	:= ""
Local lRet		:= .F.
Local aArea		:= {}
Local aCT2		:= {}
Local aCV3		:= {}
Local aCTK		:= {}
Local aEnts		:= {}
Local lClVl		:=	.F.
Local lItem		:=	.F.
Local lCusto	:= 	.F.
/**/
Local dData		:= Ctod("//")
Local dDTLP		:= Ctod("//")
Local nValor	:= 0
Local cLote		:= ""
Local cMoeda	:= ""
Local cSbLote	:= ""
Local cDoc		:= ""
Local cDC		:= ""
Local cHP		:= ""
Local cCtasDB	:= ""
Local cCtasCR	:= ""
Local cCCD		:= ""
Local cCCC		:= ""
Local cItemDB	:= ""
Local cItemCR	:= ""
Local cCLVLDB	:= ""
Local cCLVLCR	:= ""
Local cTpSald	:= ""
/***/
Local aTravas 	:= {}
Local lSldBase	:= .T.
Local lSldCT7	:= .T.
Local lSldCT3	:= .T.
Local lSldCT4	:= .T.
Local lSldCTI	:= .T.

Default nRegCT2		:= 0
Default lDelCV3CTK	:= .F.

	If nRegCT2 > 0
		lClVl	:=	CtbMovSaldo("CTH")
		lItem	:=	CtbMovSaldo("CTD")
		lCusto	:= 	CtbMovSaldo("CTT")
		aArea := GetArea()
		If lDelCV3CTK
			DbSelectArea("CV3")
			aCV3 := GetArea()
			cFilCV3 := xFilial("CV3")
			CV3->(DbSetOrder(1))

			DbSelectArea("CTK")
			aCTK := GetArea()
			cFilCTK := xFilial("CTK")
			CTK->(DbSetOrder(1))
		Endif

		DbSelectArea("CT2")
		aCT2 := GetArea()
		cChave := PadR("__CTBLC__" + StrZero(nRegCT2,10),TamSX3("CT2_ORIGEM")[1])
		CT2->(DbSetORder(13))
		cfilCT2 := xFilial("CT2")
		If CT2->(DbSeek(cFilCT2 + cChave))
			While !(CT2->(Eof())) .And. CT2->CT2_FILIAL == cFilCT2 .And. CT2->CT2_ORIGEM == cChave
				RecLock("CT2",.F.)
				If lDelCV3CTK
					cChv := PadR(AllTrim(Str(CT2->(Recno()))),TamSX3("CV3_RECDES")[1])
					cSequ := PadR(AllTrim(CT2->CT2_SEQUEN),TamSX3("CV3_SEQUEN")[1])
					dDTSeq := CV3->CV3_DTSEQ
					If CV3->(DbSeek(cFilCV3 + Dtos(dDtSeq) + cSequ))
						While !(CV3->(Eof())) .And. CV3->CV3_FILIAL == cFilCV3 .And. CV3->CV3_SEQUEN == cSequ .And. CV3->CV3_DTSEQ == dDtSeq
							RecLock("CV3",.F.)
							CV3->(DbDelete())
							CV3->(DbSkip())
						EndDo
					Endif
					cSequ := PadR(AllTrim(CT2->CT2_SEQUEN),TamSX3("CTK_SEQUEN")[1])
					If CTK->(DbSeek(cFilCTK + cSequ))
						While !(CTK->(Eof())) .And. CTK->CTK_FILIAL == cFilCTK .And. CTK->CTK_SEQUEN == cSequ
							RecLock("CTK",.F.)
							CTK->(DbDelete())
							CTK->(DbSkip())
						EndDo
					Endif
				Endif
				DbSelectArea("CT2")
				dData	:= CT2->CT2_DATA
				dDTLP	:= CT2->CT2_DTLP
				cLote	:= CT2->CT2_LOTE
				cMoeda	:= CT2->CT2_MOEDLC
				cSbLote	:= CT2->CT2_SBLOTE
				cDoc	:= CT2->CT2_DOC
				cDC		:= CT2->CT2_DC
				cLinha	:= CT2->CT2_LINHA
				cSeqLan	:= CT2->CT2_SEQLAN
				cHP		:= CT2->CT2_HP
				cCtasDB	:= CT2->CT2_DEBITO
				cCtasCR	:= CT2->CT2_CREDIT
				cCCD	:= CT2->CT2_CCD
				cCCC	:= CT2->CT2_CCC
				cItemDB	:= CT2->CT2_ITEMD
				cItemCR	:= CT2->CT2_ITEMC
				cCLVLDB	:= CT2->CT2_CLVLDB
				cCLVLCR	:= CT2->CT2_CLVLCR
				nValor	:= CT2->CT2_VALOR
				cTpSald	:= CT2->CT2_TPSALD
				aEnts	:= Aclone(CtbOutrEnt(.F.,"CT2"))
				/**/
				aTravas := {cCtasDB,cCtasCR}
				CtbCanGrv(aTravas,@lSldBase,@lSldCT7,@lSldCT3,@lSldCT4,@lSldCTI)
				If cDC <> "4"
					CtbGravSaldo(cLote,cSbLote,cDoc,dData,cDC,cMoeda,cCtasDB,cCtasCR,cCCD,cCCC,cItemDB,cItemCR,cClVlDB,cClVlCR,;
								nValor,cTpSald,5,cCtasDB,cCtasCR,cCCD,cCCC,cItemDB,cItemCR,cClVlDB,cClVlCR,nValor,cDC,cTpSald,cMoeda,;
								lCusto,lItem,lClVL,,lSldBase,.F.,dDTLP,,,,,lSldCT7,lSldCT3,lSldCT4,lSldCTI,,"-",aEnts[1],aEnts[1])
				Endif
				GravaLanc(dData,cLote,cSbLote,cDoc,cLinha,cDC,cMoeda,cHP,cCtasDB,cCtasCR,cCCD,cCCC,cItemDB,cItemCR,CClVlDB,cClVlCR,;
							nValor,"",cTpSald,cSeqLan,5,.T.,{},cEmpAnt,cFilAnt,,,,,,,.F.,"",{},,,,,)
				CT2->(DbSkip())
			EndDo
		Endif
		If lDelCV3CTK
			DbSelectArea("CV3")
			RestArea(aCV3)
			DbSelectArea("CTK")
			RestArea(aCTK)
		Endif
		DbSelectArea("CT2")
		CT2->(RestArea(aCT2))
		RestArea(aArea)
	Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBLCGERLCºAutor  ³Marcello            ºFecha ³ 23/04/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera os lancamentos complementares, atraves de um lancamentoº±±
±±º          ³de intregracao "000".                                       º±±
±±º          ³                                                            º±±
±±º          ³Retorno:    lRet (L) - .T. operacao feita com sucesso       º±±
±±º          ³                       .F. falha na operacao                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTB - Lancamentos complementares                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBLCGerLC(nRegCT2,cHistor)
Local lCTKSXE	:= .F.
Local lAtuCorr	:= .F.
Local lSeqCorr	:= .F.
Local cChave	:= ""
Local cHist		:= ""
Local cSeqCorr	:= ""
Local cCodSeq	:= ""
Local cLinha	:= ""
Local cSeqLan	:= ""
Local cFilCTO	:= ""
Local cFilCT2	:= ""
Local cOutro	:= ""
Local cSequen	:= ""
Local nLenCT2	:= 0
Local nLanc		:= 0
Local nMoedas	:= 0
Local nRegLC	:= 0
Local nOutros 	:= 0
Local aOutros	:= {}
Local aOutAnt	:= {}
Local aMoedas	:= {}
Local aMoedLan	:= {}
Local aCtasDB	:= {}
Local aCtasCR	:= {}
Local aAreaCT2	:= {}
Local aAreaCT1	:= {}
Local aAreaCTO	:= {}
Local aArea		:= {}
/**/
Local lClVl		:=	CtbMovSaldo("CTH")
Local lItem		:=	CtbMovSaldo("CTD")
Local lCusto	:= 	CtbMovSaldo("CTT")
/**/
Local aTravas 	:= {}
Local lSldBase	:= .T.
Local lSldCT7	:= .T.
Local lSldCT3	:= .T.
Local lSldCT4	:= .T.
Local lSldCTI	:= .T.
/**/
Local aValores	:= {}
Local aPeriodos	:= {}
Local dData		:= Ctod("//")
Local dDataAnt	:= Ctod("//")
Local nValor	:= 0
Local cLote		:= ""
Local cLoteAnt	:= ""
Local cSLoteAnt	:= ""
Local cDocAnt	:= ""
Local cSbLote	:= ""
Local cDoc 		:= ""
Local cHP		:= ""
Local cCCD		:= ""
Local cCCC		:= ""
Local cItemDB	:= ""
Local cItemCR	:= ""
Local cCLVLDB	:= ""
Local cCLVLCR	:= ""
Local cTpSald	:= ""
Local cRotina	:= ""
Local cOrigem	:= ""
Local cCriter	:= ""
Local cDocCT2	:= ""
Local cSeqLCT2	:= ""
Local cEmpOri	:= ""
Local cFilOri	:= ""
Local dFechaTx	:= CTOD("  /  /  ")
Local aFchTxMI	:= {}
Local lActFch	:= .F.

Default nRegCT2		:= 0
Default cHistor		:= ""

	If Type("__aCT2LC") <> "A"
		__aCT2LC := {}
	Endif

	If nRegCT2 > 0
		__aCT2LC := {{nRegCT2,cHistor}}
	Endif

	nLenCT2 := Len(__aCT2LC)

	If nLenCT2 > 0
		aArea := GetArea()
		lCTKSXE	:= FindFunction('HASCTKSXE')
		lSeqCorr  := UsaSeqCor()
		If lSeqCorr
			cSeqCorr := space(TamSx3("CT2_NODIA")[1])
			cCodSeq  := CtbRdia()
			lAtuCorr := .T.
		EndIf
		aAreaCT1 := CT1->(GetArea())
		CT1->(DbSetOrder(1))
		aAreaCT2 := CT2->(GetArea())
		cFilCT2 := xFilial("CT2")
		/**/
		aOutros := {}
		aOutros := Aclone(Ct101Outr({}))
		If (nOutros := Ascan(aOutros,{|cpo| AllTrim(cpo) == "CT2_SEQUEN"})) == 0
			Aadd(aOutros,"CT2_SEQUEN")
		Endif
		If (nOutros := Ascan(aOutros,{|cpo| AllTrim(cpo) == "CT2_ORIGEM"})) == 0
			Aadd(aOutros,"CT2_ORIGEM")
		Endif
		If (nOutros := Ascan(aOutros,{|cpo| AllTrim(cpo) == "CT2_LP"})) == 0
			Aadd(aOutros,"CT2_LP")
		Endif
		If (nOutros := Ascan(aOutros,{|cpo| AllTrim(cpo) == "CT2_KEY"})) == 0
			Aadd(aOutros,"CT2_KEY")
		Endif
		If (nOutros := Ascan(aOutros,{|cpo| AllTrim(cpo) == "CT2_MANUAL"})) == 0
			Aadd(aOutros,"CT2_MANUAL")
		Endif

		aOutAnt	:= {}
		For nOutros := 1 To Len(aOutros)
			cOutro := "M->" + aOutros[nOutros]
			If Type(cOutro) <> "U"
				Aadd(aOutAnt,{cOutro,&(cOutro)})
			Endif
		Next

		For nLanc := 1 To nLenCT2
			cHist := __aCT2LC[nLanc,2]
			CT2->(DbGoTo(__aCT2LC[nLanc,1]))
			aCtasDB := {}
			aCtasCR := {}
			If !Empty(CT2->CT2_DEBITO)
				CT1->(DbSeek(xFilial("CT1") + CT2->CT2_DEBITO))
				If CT1->CT1_LCCMPL == "1"
					aCtasDB := {CT1->CT1_CTPART,CT1->CT1_CTCPAR}
				Endif
			Endif
			If !Empty(CT2->CT2_CREDIT)
				CT1->(DbSeek(xFilial("CT1") + CT2->CT2_CREDIT))
				If CT1->CT1_LCCMPL == "1"
					aCtasCR := {CT1->CT1_CTPART,CT1->CT1_CTCPAR}
				Endif
			Endif
			If !Empty(aCtasDB) .Or. !Empty(aCtasCR)
				If Empty(aMoedas)
					aAreaCTO := CTO->(GetArea())
					CTO->(DbSetOrder(1))
					cFilCTO := xFilial("CTO")
					CTO->(DBSeek(cFilCTO))
					While CTO->CTO_FILIAL == cFilCTO .And. !(CTO->(Eof()))
						If (CTO->CTO_BLOQ <> "1")
							Aadd(aMoedas,CTO->CTO_MOEDA)
						Endif
						CTO->(DbSkip())
					Enddo
				Endif
				dData	:= CT2->CT2_DATA
				cLote	:= CT2->CT2_LOTE
				cSbLote	:= CT2->CT2_SBLOTE
				If (dData <> dDataAnt) .Or. (cLote <> cLoteAnt) .Or. (cSbLote <> cSLoteAnt)
					ProxDoc(dData,cLote,cSbLote,@cDoc)
					cDocAnt		:= cDoc
					cLoteAnt	:= cLote
					cSLoteAnt	:= cSbLote
					dDataAnt	:= dData
					lAtuCorr := .T.
					cSeqLan	:= StrZero(0,TamSX3("CT2_SEQLAN")[1])
				Else
					cDoc := cDocAnt
					lAtuCorr := .F.
				Endif
				cHP		:= CT2->CT2_HP
				cCCD	:= CT2->CT2_CCD
				cCCC	:= CT2->CT2_CCC
				cItemDB	:= CT2->CT2_ITEMD
				cItemCR	:= CT2->CT2_ITEMC
				cCLVLDB	:= CT2->CT2_CLVLDB
				cCLVLCR	:= CT2->CT2_CLVLCR
				nValor	:= CT2->CT2_VALOR
				cTpSald	:= CT2->CT2_TPSALD
				cCriter := CT2->CT2_CRCONV
				cRotina	:= "__CTBLC__"
				cOrigem := "__CTBLC__" + StrZero(__aCT2LC[nLanc,1],10)

				For nOutros := 1 To Len(aOutros)
					&("M->"+(aoutros[nOutros])) := &("CT2->"+(aoutros[nOutros]))
				Next

				M->CT2_ORIGEM	:= cOrigem
				M->CT2_LP	 	:= "000"
				M->CT2_MANUAL	:= "2"
				cChave 			:= "CT2->(" + CT2->(IndexKey(1)) + ")"
				M->CT2_KEY		:= &(cChave)
				aEnts := Aclone(CtbOutrEnt(.F.,"CT2"))

				aValores := {}
				For nMoedas := 1 To Len(aMoedas)
					aPeriodos := CtbPeriodos(aMoedas[nMoedas],dData,dData,.F.,.F.)
					If Empty(aPeriodos[1,1])
						Aadd(aValores,0)
					Else
						Aadd(aValores,CTBConv("9",dData,aMoedas[nMoedas],nValor))
						If cPaisLoc == "PER" .And. FindFunction("DtMoeComMI")
							DtMoeComMI(aMoedas[nMoedas], @dFechaTx, @lActFch)
							aValores[nMoedas] := IIf(lActFch, CTBConv("9",dFechaTx,aMoedas[nMoedas],nValor), aValores[nMoedas])
							AAdd(aFchTxMI, {dFechaTx, lActFch})
						EndIf
					Endif
				Next

				/**/
				If Empty(cHist)
					CT2->(DbSetOrder(10))
					cDocCT2  := CT2->CT2_DOC
					cSeqLCT2 := CT2->CT2_SEQLAN
					cEmpOri  := CT2->CT2_EMPORI
					cFilOri  := CT2->CT2_FILORI
					If CT2->(MsSeek(cFilCT2+dtos(dData)+cLote+cSbLote+cDocCT2+cSeqLCT2+cEmpOri+cFilOri+'01'))
						While !(CT2->(Eof())) .And. CT2->CT2_FILIAL == cFilCT2	.And.;
									CT2->CT2_DATA == dData 			.And.;
									CT2->CT2_LOTE == cLote 			.And.;
									CT2->CT2_SBLOTE == cSbLote 		.And.;
									CT2->CT2_DOC == cDocCT2			.And.;
									CT2->CT2_SEQLAN == cSeqLCT2		.And.;
									CT2->CT2_TPSALD	==cTpSald		.And.;
									CT2->CT2_MOEDLC == '01'			.And.;
									CT2->CT2_EMPORI == cEmpOri		.And.;
									CT2->CT2_FILORI	== cFilOri
							cHist += (CT2->CT2_HIST + CHR(13) + CHR(10))
							CT2->(DbSkip())
						EndDo
					Endif
				Endif

				If !Empty(aCtasDB)
					CtbProxLin(dData,cLote,cSbLote,cDoc,@cLinha)
					If !lCTKSXE
						cSequen := GetSx8Num("CTK","CTK_SEQUEN",,1)
					Else
						cSequen := GetSx8Num("_CT")
					EndIf
					M->CT2_SEQUEN := cSequen
					cSeqLan := Soma1(cSeqLan)
					aTravas := {aCtasDB[1],aCtasDB[2]}
					CtbCanGrv(aTravas,@lSldBase,@lSldCT7,@lSldCT3,@lSldCT4,@lSldCTI)
					For nMoedas := 1 To Len(aMoedas)
						aMoedLan := {{aMoedas[nMoedas]," ",aValores[nMoedas],"2",dData,aValores[nMoedas]}}
						If cPaisLoc == "PER" .And. !Empty(aFchTxMI) .And. aFchTxMI[nMoedas][2]
							aMoedLan[1][5] := aFchTxMI[nMoedas][1]
						EndIf
						If aValores[nMoedas] <> 0
							nRegLC := 0
							GravaLanc(dData,cLote,cSbLote,cDoc,cLinha,"3",aMoedas[nMoedas],cHP,aCtasDB[1],aCtasDB[2],cCCD,cCCC,cItemDB,cItemCR,CClVlDB,cClVlCR,;
									aValores[nMoedas],cHist,cTpSald,@cSeqLan,3,.T.,aMoedLan,cEmpAnt,cFilAnt,Val(aMoedas[nMoedas])-1,,,,,cRotina,.F.,"",aOutros,,@nRegLC,@cCodSeq,lSeqCorr,@cSeqCorr,lAtuCorr)
							lAtuCorr := .F.
							If nMoedas == 1
								CTBLCGrCV3(nRegLC,__aCT2LC[nLanc,1])
							Endif
							/**/
							CtbGravSaldo(cLote,cSbLote,cDoc,dData,"3",aMoedas[nMoedas],aCtasDB[1],aCtasDB[2],cCCD,cCCC,cItemDB,cItemCR,cClVlDB,cClVlCR,aValores[nMoedas],;
										cTpSald,5,aCtasDB[1],aCtasDB[2],cCCD,cCCC,cItemDB,cItemCR,cClVlDB,cClVLCR,aValores[nMoedas],"3",cTpSald,aMoedas[nMoedas],lCusto,;
										lItem,lClVL,,.T.,.F.,CT2->CT2_DTLP,,,,,lSldCT7,lSldCT3,lSldCT4,lSldCTI,,"+"/*cOperacao*/,aEnts[1],aEnts[1])
						Endif
					Next
					ConfirmSX8()
				Endif
				If !Empty(aCtasCR)
					CtbProxLin(dData,cLote,cSbLote,cDoc,@cLinha)
					If !lCTKSXE
						cSequen := GetSx8Num("CTK","CTK_SEQUEN",,1)
					Else
						cSequen := GetSx8Num("_CT")
					EndIf
					M->CT2_SEQUEN := cSequen
					cSeqLan := Soma1(cSeqLan)
					aTravas := {aCtasCR[2],aCtasCR[1]}
					CtbCanGrv(aTravas,@lSldBase,@lSldCT7,@lSldCT3,@lSldCT4,@lSldCTI)
					For nMoedas := 1 To Len(aMoedas)
						aMoedLan := {{aMoedas[nMoedas]," ",aValores[nMoedas],"2",dData,aValores[nMoedas]}}
						If cPaisLoc == "PER" .And. !Empty(aFchTxMI) .And. aFchTxMI[nMoedas][2]
							aMoedLan[1][5] := aFchTxMI[nMoedas][1]
						EndIf
						If aValores[nMoedas] <> 0
							nRegLC := 0
							GravaLanc(dData,cLote,cSbLote,cDoc,cLinha,"3",aMoedas[nMoedas],cHP,aCtasCR[2],aCtasCR[1],cCCD,cCCC,cItemDB,cItemCR,CClVlDB,cClVlCR,;
									aValores[nMoedas],cHist,cTpSald,@cSeqLan,3,.T.,aMoedLan,cEmpAnt,cFilAnt,Val(aMoedas[nMoedas])-1,,,,,cRotina,.F.,"",aOutros,,@nRegLC,@cCodSeq,lSeqCorr,@cSeqCorr,lAtuCorr)
							lAtuCorr := .F.
							If nMoedas == 1
								CTBLCGrCV3(nRegLC,__aCT2LC[nLanc,1])
							Endif
							/**/
							CtbGravSaldo(cLote,cSbLote,cDoc,dData,"3",aMoedas[nMoedas],aCtasCR[2],aCtasCR[1],cCCD,cCCC,cItemDB,cItemCR,cClVlDB,cClVlCR,aValores[nMoedas],;
										cTpSald,5,aCtasCR[2],aCtasCR[1],cCCD,cCCC,cItemDB,cItemCR,cClVlDB,cClVLCR,aValores[nMoedas],"3",cTpSald,aMoedas[nMoedas],lCusto,;
										lItem,lClVL,,.T.,.F.,CT2->CT2_DTLP,,,,,lSldCT7,lSldCT3,lSldCT4,lSldCTI,,"+"/*cOperacao*/,aEnts[1],aEnts[1])
						Endif
					Next
					ConfirmSX8()
				Endif
			Endif
		Next
		For nOutros := 1 To Len(aOutAnt)
			cOutro := aOutAnt[nOutros,1]
			&(cOutro) := aOutAnt[nOutros,2]
		Next
		CT2->(RestArea(aAreaCT2))
		CT1->(RestArea(aAreaCT1))
		RestArea(aArea)
	Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBLCGRCV3ºAutor  ³                    ºFecha ³ 05/08/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria os registros na tabela CV3 referentes aos lancamentos  º±±
±±º          ³complementares.                                             º±±
±±º          ³                                                            º±±
±±º          ³Retorno:    lRet (L) - .T. operacao feita com sucesso       º±±
±±º          ³                       .F. falha na operacao                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTB - Lancamentos complementares                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBLCGrCV3(nRegCT2,nRegOri)
Local nCT2		:= 0
Local lRet		:= .F.

Default nRegCT2 := 0
Default nRegOri := 0

	If nRegCT2 <> 0
		nCT2 := CT2->(Recno())
		If nRegCT2 <> nCT2
			CT2->(dbGoTo(nRegCT2))
		Endif
		RecLock("CV3",.T.)
			CV3->CV3_FILIAL	:= xFilial("CV3")
			CV3->CV3_DTSEQ	:= CT2->CT2_DATA
			CV3->CV3_SEQUEN	:= CT2->CT2_SEQUEN
			CV3->CV3_DC		:= CT2->CT2_DC
			CV3->CV3_LP		:= CT2->CT2_LP
			CV3->CV3_LPSEQ	:= CT2->CT2_LINHA
			CV3->CV3_KEY	:= CT2->CT2_KEY
			CV3->CV3_DEBITO	:= CT2->CT2_DEBITO
			CV3->CV3_CREDIT	:= CT2->CT2_CREDIT
			CV3->CV3_VLR01	:= CT2->CT2_VLR01
			CV3->CV3_VLR02	:= CT2->CT2_VLR02
			CV3->CV3_VLR03	:= CT2->CT2_VLR03
			CV3->CV3_VLR04	:= CT2->CT2_VLR04
			CV3->CV3_VLR05	:= CT2->CT2_VLR05
			CV3->CV3_HIST	:= CT2->CT2_HIST
			CV3->CV3_CCC	:= CT2->CT2_CCC
			CV3->CV3_CCD	:= CT2->CT2_CCD
			CV3->CV3_ITEMC	:= CT2->CT2_ITEMC
			CV3->CV3_ITEMD	:= CT2->CT2_ITEMD
			CV3->CV3_CLVLDB	:= CT2->CT2_CLVLDB
			CV3->CV3_CLVLCR	:= CT2->CT2_CLVLCR
			CV3->CV3_MOEDLC	:= CT2->CT2_MOEDLC
			CV3->CV3_TABORI	:= "CT2"
			CV3->CV3_RECORI	:= Alltrim(Str(nRegOri))
			CV3->CV3_RECDES := Alltrim(Str(nRegCT2))
		CV3->(MsUnlock())
		If nRegCT2 <> nCT2
			CT2->(dbGoTo(nCT2))
		Endif
	Endif
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBGrvHist() ³Autor  ³ José Lucas        ³ Data ³ 13/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Históirco de alterações das Entidades e Grupo de 	  ³±±
±±³          ³ Natureza Contabil.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBGrvHist(cFilTabela,cEntidade,cCodigo,cGrupo,cTipoCampo, ³±±
±±³          ³            cCampo,cValorAnt,cValorNovo,nOpcao)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CTBXFUN						            				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function CTBGrvHist(cFilTabela,cEntidade,cCodigo,cGrupo,cTipoCampo,cCampo,cValorAnt,cValorNovo,nOpc)
LOCAL aArea 	 := GetArea()
LOCAL cHistorico := Space(80)
LOCAL cSequencia := ""
LOCAL cTitulo    := ""
LOCAL lGravaLog  := GetNewpar( "MV_CTBLGET" , .F. )

DEFAULT cGrupo   := Space(TamSX3("CTT_CUSTO")[1])
DEFAULT cCodigo  := Space(TamSX3("CTT_CUSTO")[1])
DEFAULT nOpc	 := 0

	If lGravaLog
		cSequencia := CriaVar("CW8_SEQ")
		SX3->(DbSetOrder(2))
		SX3->(DbSeek(cCampo))
		cTitulo    := X3Titulo()
		cTipoCampo := SX3->X3_TIPO
		SX3->(DbSetOrder(1))

	   	If cTipoCampo == "N"
			cValorAnt  := Str(cValorAnt,TamSX3(cCampo)[1],TamSX3(cCampo)[2])
			cValorNovo := Str(cValorNovo,TamSX3(cCampo)[1],TamSX3(cCampo)[2])
		ElseIf cTipoCampo == "D"
			cValorAnt  := DTOC(cValorAnt)
			cValorNovo := DTOC(cValorNovo)
		ElseIf cTipoCampo == "L"
			cValorAnt  := If(cValorAnt,".T.",".F.")
			cValorNovo := If(cValorNovo,".T.",".F.")
		EndIf

		DbSelectArea("CW8")
		cSequencia := CW8GetSeq(cFilTabela, cEntidade, cCodigo, cGrupo, cCampo)

		CW8->(DbSetOrder(1))
		If ! CW8->(DbSeek(xFilial("CW8")+cFilTabela+cEntidade+cCodigo+cGrupo+cCampo+DTOS(dDataBase)+cSequencia) )
			RecLock("CW8",.T.)
				CW8->CW8_FILIAL := xFilial("CW8")
				CW8->CW8_FILTAB := cFilTabela
				CW8->CW8_TABELA := cEntidade
				CW8->CW8_CODIGO	:= cCodigo
				CW8->CW8_GRUPO  := cGrupo
				CW8->CW8_CAMPO	:= cCampo
				CW8->CW8_SEQ    := cSequencia
				CW8->CW8_TIPCPO := cTipoCampo
				CW8->CW8_TITULO := cTitulo
				CW8->CW8_VALANT := cValorAnt
				CW8->CW8_VALNOV := cValorNovo
				CW8->CW8_DATA   := dDataBase
				CW8->CW8_HORA	:= Substr(Time(),1,5)
		   		CW8->CW8_OPC	:= Str(nOpc,1)
				cHistorico := __CUSERID + " - " + cUserName + " -  " + Dtoc(dDatabase) + " / " + Substr(Time(),1,5)
			                            //" - Inclusao " ### " - Alteracao " ### " - Indefinido" ### - Exclusao
				cHistorico += If(nOpc==3, STR0019 , If(nOpc==4, STR0020 ,If(nOpc==0, STR0021 , STR0022 ) ))
				MSMM(CW8_HISTOR,,,cHistorico,1,,,"CW8","CW8_HISTOR")
			CW8->(MsUnLock())
		EndIf
	EndIf

Restarea(aArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CW8GetSeq() ³Autor  ³ José Lucas         ³ Data ³ 13/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obter a proxima sequencia para gravação.				 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpC:=CW8GetSeq(cFilTabela,cEntidade,cCodigo,cGrupo,cCampo)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CTBXFUN						            				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function CW8GetSeq(cFilTabela,cEntidade,cCodigo,cGrupo,cCampo)
LOCAL aArea      := GetArea()
LOCAL cQuery     := ""
LOCAL cSequencia := "000000"
Local cAlias    := ""

	// Se encontrar algum apostrofo no código 
	If ValType(cCodigo) == "C" .And. At("'", cCodigo) > 0
		cCodigo := ClearAsp(cCodigo)
	Endif

	If Select("QRYCW8") > 0
		QRYCW8->(DbCloseArea())
	EndIf

	cQuery := ""
	cAlias := ""

	cQuery := "SELECT MAX(CW8_SEQ) MAXSEQ FROM "
	cQuery += RetSqlName("CW8") + " CW8 "
	cQuery += " WHERE"
	cQuery += " CW8_FILIAL = '" + xFilial("CW8") + "' "
	cQuery += " AND CW8_FILTAB = '" + cFilTabela + "' "
	cQuery += " AND CW8_TABELA = '" + cEntidade + "' "
	cQuery += " AND CW8_CODIGO = '" + cCodigo + "' "
	cQuery += " AND CW8_GRUPO = '" + cGrupo + "' "
	cQuery += " AND CW8_CAMPO = '" + cCampo + "' "
	cQuery += " AND CW8_DATA = '" + DTOS(dDataBase) + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'QRYCW8', .F., .T.)

	QRYCW8->(DbGoTop())
	IF QRYCW8->(!EOF())
	   cSequencia := QRYCW8->MAXSEQ
	ENDIF

	QRYCW8->(DbCloseArea())

	cSequencia := Soma1(cSequencia)

RestArea(aArea)
Return( cSequencia )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTGERAISRLºAutor  ³Marcos Hirakawa     º Data ³  05/17/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ SELECIONAR REGISTROS DE RETENÇÃO DE IMPOSTO DE RENDA       º±±
±±º          ³ DA TABELA SFE, CAMPO FE_TIPO = "R", Para gerar o arquivo   º±±
±±º          ³ XML.                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ VENEZUELA                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtGeraISRL(dDataIni,dDataFim, aA_002_1_3,lFirst)
LOCAL cArqTmp    := "ISRL"
LOCAL cQuery1    := ""
LOCAL aStrQRY1   :={}
Local cRIFAGENTE := ""
LOCAL cORDPAGO   := ""
LOCAL nORDPAGO   := 0
LOCAL cORDPAGO1  := ""
LOCAL nI         := 1
LOCAL nPERCENT   := 0.00
LOCAL cNFISCAL   := ""
LOCAL cPERIODO   := Alltrim(aA_002_1_3[2][3]) + Alltrim(aA_002_1_3[6][3])  // ANO_MES
LOCAL nCntRec    := 0.00
LOCAL nTotalRec  := mv_par07
LOCAL cNomFile   := ""

Private oTmpTable

DEFAULT lFirst      := .T.

If lFirst
	If ExistBlock("ESPISRL")
		cArqTmp := ExecBlock("ESPISRL",.F.,.F.,{cArqtmp, dDataIni, dDataFim ,cPERIODO,lFirst})
		Return(cArqTmp)
	EndIf

	dbSelectArea("SM0")
	cRIFAGENTE := Alltrim(M0_CGC)
	cRIFAGENTE := If(Empty(cRIFAGENTE),"00000000000",cRIFAGENTE)

	aadd(aStrQRY1,{ "RIFAGENTE" , "C", 14, 0 })
	aadd(aStrQRY1,{ "EMISSAO"   , "C", 06, 0 })
	aadd(aStrQRY1,{ "RIFSUJEITO", "C", 14, 0 })
	aadd(aStrQRY1,{ "NUMFATURA" , "C", 10, 0 })
	aadd(aStrQRY1,{ "ORDEMPAGO" , "C", 08, 0 })
	aadd(aStrQRY1,{ "CONCEITO"  , "C", 03, 0 })
	aadd(aStrQRY1,{ "VALORBASE" , "C", 17, 0 })
	aadd(aStrQRY1,{ "PERCENT"   , "C", 06, 0 })
	aadd(aStrQRY1,{ "NOMARQ"	, "C", 08, 0 })					// Nome do Arquivo.

	If Select("ISRL") > 0
   		oTmpTable:Delete()
	EndIf
	//Criar a abrir arquivo de trabalho e indice - alias ISRL

	If oTmpTable <> Nil
		oTmpTable:Delete()
	EndIf

	oTmpTable := FWTemporaryTable():New("ISRL")
	oTmpTable:SetFields( aStrQRY1 )
	oTmpTable:AddIndex("T1", {"NOMARQ","EMISSAO","RIFSUJEITO","NUMFATURA","ORDEMPAGO"})
	oTmpTable:Create()

	//Montar query e arquivo de trabalho para receber resultado da Query.
	If Select("TOPISRL") > 0
   		dbSelectArea("TOPISRL")
   		dbCloseArea()
	EndIf

	cQuery1 := "SELECT DISTINCT '" + cRIFAGENTE + "'RIFAGENTE, "
	cQuery1 += "FE_EMISSAO EMISSAO, "
	cQuery1 += "FE_ORDPAGO, "
	cQuery1 += "FE_NFISCAL, "
	cQuery1 += "FE_SERIE, "
	cQuery1 += "FE_VALBASE VALORBASE, "
	cQuery1 += "FE_ALIQ, "
	cQuery1 += "FE_CONCEPT, "
	cQuery1 += "FE_FORNECE, "
	cQuery1 += "FE_LOJA "
	cQuery1 += " FROM " + RetSqlName("SFE") + " SFE"
	cQuery1 += " WHERE SFE.FE_FILIAL = '" + xFilial("SFE") + "'"
	cQuery1 +=   " AND SFE.D_E_L_E_T_ = ' '"
	cQuery1 +=   " AND SFE.FE_TIPO='R'"
	cQuery1 +=   " AND SFE.FE_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQuery1 +=   " ORDER BY SFE.FE_EMISSAO, SFE.FE_NFISCAL, SFE.FE_ORDPAGO"

	cQuery1 := ChangeQuery(cQuery1)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),"TOPISRL",.T.,.T.)

	TCSetField("TOPISRL","EMISSAO","D",8,0)

	TOPISRL->(dbGoTop())
	If (Eof() .or. Bof())
   		Help(" ",1,"F3ICA3",,STR0008,1,0)//Não existe retenções geradas!
   		TOPISRL->(dbCloseArea())		//Fechar o arquivo resultado da Query
   		Return
	EndIf

	TOPISRL->(dbGoTop())
	While ! TOPISRL->(Eof())
   		cNFISCAL := (AllTrim(TOPISRL->FE_SERIE) + AllTrim(TOPISRL->FE_NFISCAL) )

   		If "" == cNFISCAL .or. Empty(cNFISCAL)
    		cNFISCAL:= "0"
   		Else
      		If Len(cNFISCAL) > 10
         		cNFISCAL := RIGHT(cNFISCAL,10)
      		EndIf
   		EndIf

		cORDPAGO1:=  ALLTRIM(TOPISRL->FE_ORDPAGO)
		cORDPAGO := ""

   		If "" == cORDPAGO1 .OR. Empty(cORDPAGO1)
			cORDPAGO := "NA"
		Else
			nORDPAGO := Len(cORDPAGO1)
			For nI := 1 To nORDPAGO
		   		If subs(cORDPAGO1, nI,1) $ "0123456789"
			   		cORDPAGO += subs(cORDPAGO1, nI,1)
		   		Endif
			Next nI
		EndIf

   		nPERCENT := STR(FE_ALIQ,6,2)
   		If SUBS( nPERCENT , 4, 3) == ".00" // 010.00
	   		nPERCENT := STR(FE_ALIQ,3,0)
   		EndIf

		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial("SA2")+TOPISRL->FE_FORNECE+TOPISRL->FE_LOJA))
		dbSelectArea("ISRL")
		RecLock("ISRL", .T.)
			ISRL->RIFAGENTE := ALLTRIM(TOPISRL->RIFAGENTE)
			ISRL->EMISSAO   := cPERIODO // SUBS(TOPISRL->EMISSAO,1,6)
			ISRL->RIFSUJEITO:= SA2->A2_CGC
			ISRL->NUMFATURA := cNFISCAL
			ISRL->ORDEMPAGO := cORDPAGO
			ISRL->CONCEITO  := TOPISRL->FE_CONCEPT
			ISRL->VALORBASE := alltrim(STR(TOPISRL->VALORBASE,17,2))
			ISRL->PERCENT   := ALLTRIM(nPERCENT)
		MsUnLock()

		dbSelectArea("TOPISRL")
		TOPISRL->(dbSkip())
	EndDo

	dbSelectArea("ISRL")
	ISRL->(dbGoTop())

	nCntRec   := 0.00
	nTotalRec := mv_par07
	cNomFile  := cNomArq
	AADD(aNomArq,cNomFile)

	ISRL->(dbSetOrder(0))
	ISRL->(dbGoTop())
	While ISRL->(!Eof())
		nCntRec++
		If nCntRec > nTotalRec
			nCntRec  := 1
			cNomFile := Soma1(cNomFile)
        	AADD(aNomArq,cNomFile)
        	cAliasISRL := "ISRL"
 		EndIf
		RecLock("ISRL",.F.)
			ISRL->NOMARQ := cNomFile
		MsUnLock()
		ISRL->(dbSkip())
	EndDo

	ISRL->(dbSetOrder(1))
	ISRL->(dbGoTop())
EndIf
Return("ISRL")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTCloseArq() ³ Autor ³ José Lucas		          ³ Data ³ 05.05.11	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fecha a area aberta através da função CtGeraISRL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtCloseArq(cAliasISRL,lClose)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Genérico                                                  			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do Alias definido para area de trabalho        		    ³±±
±±³          ³ ExpL1 = Variavel de controle para fechamento da area.       		    ³±±
±±³          ³ ExpC2 = Nome do Arquivo (cNomArq).				        		    ³±±
±±³          ³ ExpL2 = Variavel de controle para apagar o arquivo de trabalho.	    ³±±
±±³          ³         Exemplo: ISRL001.xml										    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function CTCloseArq(cAlias,lClose,cNomArq,lApaga)
Local aSaveArea := GetArea()

DEFAULT lClose    := .F.

	If lClose
		dbSelectArea(cAlias)
		If !Empty(cNomArq) .and. lApaga .and. RecCount() == 0
			dbCloseArea()
			FErase(cNomArq)
		EndIf
	EndIf

RestArea(aSaveArea)
Return

/*/
// ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// ±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
// ±±³Fun‡„o    ³CTBOPRCND ³ Autor ³ MARCOS HIRAKAWA       ³ Data ³ 09.03.10	       ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Descri‡„o ³ REALIZA UMA OPERACAO ENTRE DUAS ENTIDADES DA MESMA VISAO GERENCIAL   ³±±
// ±±³          ³ E RETORNA O RESULTADO SE A CONDICAO FOR VERDADEIRA.                  ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Sintaxe   ³CTBOPRCND(cEntidade1,  cEntidade2,  cOperacao, cCondicao)             ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Retorno   ³ array[1] Saldo Atual (com sinal)                                     ³±±
// ±±³          ³ array[2] Debito na Data                                              ³±±
// ±±³          ³ array[3] Credito na Data                                             ³±±
// ±±³          ³ array[4] Saldo Atual Devedor                                         ³±±
// ±±³          ³ array[5] Saldo Atual Credor                                          ³±±
// ±±³          ³ array[6] Saldo Anterior (com sinal)                                  ³±±
// ±±³          ³ array[7] Saldo Anterior Devedor                                      ³±±
// ±±³          ³ array[8] Saldo Anterior Credor                                       ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³ Uso      ³ dentro do CTGERPLAN:                                          	   ³±±
// ±±³          ³ SALDO=CTBOPRCND("699","799","-",">=0")                        	   ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Parametros³ ExpC1, cEntidade1 = CODIGO DA 1a. ENTIDADE DA VISAO GERENCIAL.       ³±±
// ±±³          ³ ExpC2, cEntidade2 = CODIGO DA 2a. ENTIDADE DA VISAO GERENCIAL.       ³±±
// ±±³          ³ ExpC3, cOperacao   = Sintaxe da operacao:                    		   ³±±
// ±±³          ³                      Soma, subtracao, multiplicacao e divisao 	   ³±±
// ±±³          ³ ExpC4, cCondicao   = Sintaxe da condicao , referente ao resultado    ³±±
// ±±³          ³                      da cOperacao.                                   ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³ exemplo  ³ CTGERPLAN          SALDO=CTBOPRCND(699,799,"-",">=0")                ³±±
// ±±³          ³ CTGERPLAN          SALDO=CTBOPRCND(699,799,"-","<0")                 ³±±
// ±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
// ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
FUNCTION CTBOPRCND(cEntidade1, cEntidade2, cOperacao, cCondicao)
Local aSaldo    := {0,0,0,0,0,0,0,0}
Local aSaldoE01 := {0,0,0,0,0,0,0,0}
Local aSaldoE02 := {0,0,0,0,0,0,0,0}
Local nX        := 0
Local cEnt01  := upper(valtype(cEntidade1))
Local cEnt02  := upper(valtype(cEntidade2))
Local cOperP   := { "-", "+" , "*" , "/" , "%" }
Local lT       := .T.
Local nROper   := 0
Local nLena    := 0

// ATENCAO: VARIAVEIS DE MEMORIA DEVEM SER TIPIFICADAS COMO PRIVATE PARA O FUNCIONAMENTO DA MACRO SUBSTITUICAO.
private cExpressao := ""
private aCTGERPL := {}
PRIVATE NJ := 1
PRIVATE cCond0 := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificacao dos parametros cCondicao!                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCond0 := Test_cond( alltrim(cCondicao), @lT )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificacao dos parametros cOperacao!                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if (! (empty( alltrim(cOperacao) ) )) .and. (! lT)
		if aScan(cOperP , cOperacao, 1) > 0
		   lT := .F.
		endif
	endif

	if lT
		Return aSaldo
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificacao dos parametros cEntidade1 e cEntidade2 para serem caratecteres  !³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if cEnt01 == "N"
		cEnt01 := alltrim(str(cEntidade1,18,0))
	elseif cEnt01 == "C"
		cEnt01 := alltrim(cEntidade1)
	else
		cEnt01 := "" // cEntidade1 // ?
	Endif

	if "" == cEnt01
		Return aSaldo
	endif

	if cEnt02 == "N"
		cEnt02 := alltrim(str(cEntidade2,18,0))
	elseif cEnt02 == "C"
		cEnt02 := alltrim(cEntidade2)
	else
		cEnt02 := "" // cEntidade2 // ?
	Endif

	if "" == cEnt02
		Return aSaldo
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Na FUNCAO GetSldEnt, retornar o array! nTpSaldo = 0 .   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// CARREGA SALDOS DA ENTIDADE 01 cEntidade1 - cEnt01
	IF !Empty(cEnt01)
		aSaldoE01 := GetSldEnt(cEnt01 , /* cCodVis */ , /* cOrdVis*/ , 0 /* nTpSaldo: 0-> Retornar o array */ , /* cArqTmp*/  )
	ENDIF

	// CARREGA SALDOS DA ENTIDADE 02 cEntidade2 - cEnt02
	IF !Empty(cEnt02)
		aSaldoE02 := GetSldEnt(cEnt02 , /* cCodVis */ , /* cOrdVis*/ , 0 /* nTpSaldo: 0-> Retornar o array */ , /* cArqTmp*/  )
	ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REALIZA OPERACAO cOperacao ENTRE SALDOS DAS ENTIDADES 01 E 02³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLena  := Len(aSaldo)
	For nX :=1 to nLena
		nROper := 0
		do case
			case cOperacao == "-"
				nROper := round( aSaldoE01[nX] - aSaldoE02[nX] ,2)
			case cOperacao == "+"
				nROper := round( aSaldoE01[nX] + aSaldoE02[nX] ,2)
			case cOperacao == "*"
				nROper := round( aSaldoE01[nX] * aSaldoE02[nX] ,2)
			case cOperacao == "/"
				if aSaldoE02[nX] <> 0
					nROper := round( aSaldoE01[nX] / aSaldoE02[nX] ,2)
				endif
			case cOperacao == "%"
				if aSaldoE02[nX] <> 0
					nROper := round( aSaldoE01[nX] / aSaldoE02[nX] * 100 ,2)
				endif
		endcase
		aSaldo[nX] := nROper
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZADO VALOR DE RETORNO EM FUNCAO DO ATENDIMENTO DA CONDICAO  cCond0 / cCondicao                          ³
	//³ATENCAO: VARIAVEIS DE MEMORIA DEVEM SER TIPIFICADAS COMO PRIVATE PARA O FUNCIONAMENTO DA MACRO & SUBSTITUICAO.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLena  := Len(aSaldo)
	aCTGERPL:= Aclone(aSaldo)
	NJ := 1
	DO WHILE NJ <= nLena
		cExpressao := "aCTGERPL[NJ] " + cCond0
		aCTGERPL[nJ] := IIF(&cExpressao, (aCTGERPL[nJ]), 0)
		NJ++
	ENDDO

Return (aCTGERPL)

// /*/
// ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// ±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
// ±±³Fun‡„o    ³CTBVLRCND ³ Autor ³ MARCOS HIRAKAWA       ³ Data ³ 09.03.10	       ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Descri‡„o ³ RETORNA O VALOR DE UMA ENTIDADE EM FUNCAO DO TESTE LOGICO APLICADO   ³±±
// ±±³          ³ AO VALOR DE UMA SEGUNDA ENTIDADE.                                    ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Sintaxe   ³CTBVLRCND(cEntidade1, cCondicao, cEntidade2)                          ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Retorno   ³ array[1] Saldo Atual (com sinal)                                     ³±±
// ±±³          ³ array[2] Debito na Data                                              ³±±
// ±±³          ³ array[3] Credito na Data                                             ³±±
// ±±³          ³ array[4] Saldo Atual Devedor                                         ³±±
// ±±³          ³ array[5] Saldo Atual Credor                                          ³±±
// ±±³          ³ array[6] Saldo Anterior (com sinal)                                  ³±±
// ±±³          ³ array[7] Saldo Anterior Devedor                                      ³±±
// ±±³          ³ array[8] Saldo Anterior Credor                                       ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³ Uso      ³ dentro do CTGERPLAN:                                          	   ³±±
// ±±³          ³ SALDO=CTBVLRCND(801,">=0",828)                               		   ³±±
// ±±³          ³ se o saldo da celula "801" (cEntidade1)  da visao gerencial          ³±±
// ±±³          ³ e' ">=0" (cCondicao) , entao o saldo da celula "828" (cEntidade2)    ³±±
// ±±³          ³ da visao gerencial recebera' o saldo do "801", senao 0 (Zero).       ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Parametros³ ExpC1, cEntidade1 = CODIGO DA 1a. ENTIDADE DA VISAO GERENCIAL.       ³±±
// ±±³          ³ ExpC2, cCondicao  = Sintaxe da condicao.                             ³±±
// ±±³          ³ ExpC3, cEntidade2 = CODIGO DA 2a. ENTIDADE DA VISAO GERENCIAL,       ³±±
// ±±³          ³                      QUE PODERA'RECEBER O VALOR DA 1a. ENTIDADE.     ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³ exemplo  ³ CTGERPLAN          SALDO=CTBVLRCND(801,">=0",828)                    ³±±
// ±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
// ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// /*/
FUNCTION CTBVLRCND(cEntidade1, cCondicao, cEntidade2)
Local aSaldo	 := {0,0,0,0,0,0,0,0}
Local aSaldoE01 := {0,0,0,0,0,0,0,0}
Local aSaldoE02 := {0,0,0,0,0,0,0,0}
Local cEnt01 := upper(valtype(cEntidade1))
Local cEnt02 := upper(valtype(cEntidade2))
Local lT := .T.
Local nLena  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ATENCAO: VARIAVEIS DE MEMORIA DEVEM SER TIPIFICADAS COMO PRIVATE PARA O FUNCIONAMENTO DA MACRO SUBSTITUICAO.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
private cExpressao := ""
private aCTGERVL := {}
PRIVATE NJ:=1
private cCond0 := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificacao dos parametros cCondicao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCond0 :=  Test_cond( alltrim(cCondicao) , @lT )
	if lT
		Return aSaldo
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificacao dos parametros cEntidade1 e cEntidade2 para serem caratecteres!³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if cEnt01 == "N"
		cEnt01 := alltrim(str(cEntidade1,18,0))
	elseif cEnt01 == "C"
		cEnt01 := alltrim(cEntidade1)
	else
		cEnt01 := "" // cEntidade1 // ?
	Endif

	if ( ("" == cEnt01) .OR. (empty(cEnt01)) )
		Return aSaldo
	endif

	if cEnt02 == "N"
		cEnt02 := alltrim(str(cEntidade2,18,0))
	elseif cEnt02 == "C"
		cEnt02 := alltrim(cEntidade2)
	else
		cEnt02 := "" // cEntidade2 // ?
	Endif

	if ( ("" == cEnt02) .OR. (empty(cEnt02)) )
		Return aSaldo
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Na GetSldEnt, retornar o array! nTpSaldo = 0 .   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// CARREGA SALDOS DA ENTIDADE 01 cEntidade1 - cEnt01
	IF !Empty(cEnt01)
		aSaldoE01 := GetSldEnt(cEnt01, /* cCodVis */ , /* cOrdVis*/ , 0 /* nTpSaldo Retornar o array */ , /* cArqTmp*/  )
	ENDIF

	// CARREGA SALDOS DA ENTIDADE 02 cEntidade2 - cEnt02
	IF !Empty(cEnt02)
		aSaldoE02 := GetSldEnt(cEnt02, /* cCodVis */ , /* cOrdVis*/ , 0 /* nTpSaldo Retornar o array */ , /* cArqTmp*/  )
	ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DEFINE O VALOR DO RETORNO EM FUNCAO DA CONDICAO                                                               ³
	//³ ATENCAO: VARIAVEIS DE MEMORIA DEVEM SER TIPIFICADAS COMO PRIVATE PARA O FUNCIONAMENTO DA MACRO SUBSTITUICAO.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLena  := Len(aSaldoE01)
	aCTGERVL:= Aclone(aSaldoE01)
	NJ:=1
	Do while NJ <= nLena
		cExpressao := "aCTGERVL[NJ] " + cCond0
		aCTGERVL[nJ] := IIF(&cExpressao, aSaldoE02[nJ], 0)
		NJ++
	Enddo

Return (aCTGERVL)

// /*/
// ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// ±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
// ±±³Fun‡„o    ³Test_cond ³ Autor ³ MARCOS HIRAKAWA       ³ Data ³ 09.03.10	       ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Descri‡„o ³ Verifica o conteudo e sintaxe da condicao cCond0.                    ³±±
// ±±³          ³ Se for condicao valida, retorna .F. no parametro lT                  ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Sintaxe   ³Test_cond( cCond0, @lT )                                              ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Retorno   ³ cCond2 : Sintaxe da condicao SEM ESPACOS                             ³±±
// ±±³          ³ @lT : .T. se cCond2 e' vazio                                         ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Parametros³ ExpC1, cCond0 = Sintaxe da condicao.                                 ³±±
// ±±³          ³ ExpL2, @lT    = variavel logica para indicar que cCond0 e' vazio.    ³±±
// ±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
// ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// */
Static Function Test_cond( cCond0, lVazio )
local nLena
local nX
local lT1
local cCond1 := ""
local cCond2 := ""

Default lVazio := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retirar espacos do cCondicao e concatenar caratere por caractere.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if (! ( empty( cCond0 ) )) .and. ( "" <> cCond0 )
		nLena := len( cCond0 )
		for nX := 1 to nLena
			cCond1 :=  upper(alltrim(subs(cCond0,nX,1)))
			lT1:= .F.
			if (!empty ( cCond1) ) .and. ( cCond1 <> " " )
				if cCond1 $ "<>=!#.()"
					lT1:= .T.
				elseif cCond1 $ "0123456789"
					lT1:= .T.
				elseif cCond1 $ "|.AND.|.OR.|"
					lT1:= .T.
				else
					lT1:= .F.
				endif
			endif
			cCond2 += iif( lT1 , cCond1, "")
		Next nX
		lVazio := .F.
	endif

return ( cCond2 )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBValidAt ³ Autor ³ WAGNER MONTENEGRO     ³ Data ³ 28.04.10³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida as Atividades Complementares                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBValidAt(cDBCR,nRotina)             					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aAtivCT1,aAtivCTD,aAtivCTH,aAtivCTT         				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Debito ou Credito "DB" / "CR"                      ³±±
±±³          ³ ExpC2 = 1 ou 2 (1=Chamada por CTBA101)                     ³±±
±±³          ³                (2=Chamada por CTBA105)                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ANALISTA          * ALTERAÇÕES                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Danilo Dias    * Incluido Parâmetros:                                  ³±±
±± 			      *    cConta  = Número da Conta Contábil (CT1)           ³±±
±± 			      *    cCusto  = Número da Centro de Custo (CTT)          ³±±
±± 			      *    cItem   = Número do Item Contábil (CTD)            ³±±
±± 			      *    cClasse = Número da Classe de Valor (CTH)          ³±±
±± 			      * Tratamento para validar se existe Atividade ativada   ³±±
±± 			      * e obrigatória sem preenchimento no lançamento.        ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function CTBValidAT( cDBCR, nRotina, cConta, cCusto, cItem, cClasse )
Local cAliasCT2 := If( nRotina == 1, "M->", "TMP->" ) //SE ROTINA 1=CTBA101 2=CTBA105
Local lRet      := .T.
Local cEntidade := ""
Local cAlias    := ""
Local aGenerico := {}

//Controle de Loop
Local ni
Local nj
Local nf

	aSaveArea:= GetArea()

	If __lAtivComp == NIL
		// Carrega os campos de atividade complementar do SX3
		CtbLoadAcAt(cAliasCT2,cDBCR)
	EndIf

	//RESETA ARRAY RECEBIDO DAS ROTINAS E PREENCHE COM O CACHE JÁ CARREGADO
	If _aAtivCT1 == Nil
		aAtivCT1 := {}
	Else
		aAtivCT1 := Nil
		aAtivCT1 := {}

		For nI := 1 To Len( _aAtivCT1 )
			If cDBCR $ _aAtivCT1[ nI , 3 ] 
				aAdd( aAtivCT1 , {_aAtivCT1[ nI,1] , _aAtivCT1[nI,2],_aAtivCT1[nI,3]})
			EndIf
		Next nI
	EndIf

	If _aAtivCTT == Nil
		aAtivCTT := {}
	Else
		aAtivCTT := Nil
		aAtivCTT := {}

		For nI := 1 To Len( _aAtivCTT )
			If cDBCR $ _aAtivCTT[ nI , 1 ] 
				aAdd( aAtivCTT , {_aAtivCTT[nI ,1],_aAtivCTT[nI ,2],_aAtivCTT[nI ,3]})
			EndIf
		Next nI
	EndIf

	If _aAtivCTD == Nil
		aAtivCTD := {}
	Else
		aAtivCTD := Nil
		aAtivCTD := {}

		For nI := 1 To Len( _aAtivCTD )
			If cDBCR $ _aAtivCTD[ nI , 1 ]
				aAdd( aAtivCTD , {_aAtivCTD[nI,2],_aAtivCTD[nI,2],_aAtivCTD[nI,3]} )
			EndIf
		Next nI
	EndIf

	If _aAtivCTH == Nil
		aAtivCTH := {}
	Else
		aAtivCTH := Nil
		aAtivCTH := {}

		For nI := 1 To Len( _aAtivCTH )
			If cDBCR $ _aAtivCTH[ nI , 1 ]
				aAdd( aAtivCTH , {_aAtivCTH[ nI,1],_aAtivCTH[ nI,2],_aAtivCTH[ nI,3]}) 
			EndIf
		Next nI
	EndIf

	//Valida preenchimento de informações complementares obrigatórias
	If ( lRet )
        For nj := 1 to 4
            If ( nj == 1 )
                cAlias    := "CT1"
                cEntidade := cConta
                aGenerico := AClone( aAtivCT1 )
            ElseIf ( nj == 2 )
                cAlias    := "CTD"
                cEntidade := cItem
                aGenerico := AClone( aAtivCTD )
            ElseIf ( nj == 3 )
                cAlias    := "CTH"
                cEntidade := cClasse
                aGenerico := AClone( aAtivCTH )
            ElseIf ( nj == 4 )
                cAlias    := "CTT"
                cEntidade := cCusto
                aGenerico := AClone( aAtivCTT )
            Else
                cEntidade := ""
                aGenerico := {}
                nf        := 0
            EndIf

            If ( lRet ) .And. ( !Empty( cEntidade ) )
                (cAlias)->(dbSetOrder(1))
                If ( cAlias )->( MsSeek( xFilial(cAlias) + cEntidade ) )
                    For nI := 1 to Len(aGenerico)
                        If ( &(aGenerico[nI][1]) == '1') 
                            If ( Empty( &(aGenerico[nI][3]) ) )
                                Help( " ", 1, "P" + aGenerico[nI][3] )
                                lRet := .F.
                                Exit
                            EndIf
                        EndIf
                    Next
                EndIf
            EndIf
        Next
	EndIf
//atribui nil pois precisa recarregar o array quando for partida dobrada
__lAtivComp := Nil
_aAtivCT1 := Nil
RestArea(aSaveArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbCache  ºAutor  ³Microsiga           º Data ³  06/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbCache(nCache)
Local lRet := .F.
Local cKeyCTB := cFilAnt+cValtoChar(nCache)

If _oCtbCache == nil 
	_oCtbCache := JsonObject():New()
EndIf 
If _oCtbCache[cKeyCTB] == nil 
	lRet := CtbCacheIs(nCache)
	_oCtbCache[cKeyCTB] := lRet 
Else 
	lRet := _oCtbCache[cKeyCTB]
EndIf 
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbCacheIsºAutor  ³Microsiga           º Data ³  06/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbCacheIs(nCache)
	If __lCacheIs == Nil
		__lCacheIs := ( GetNewPar( "MV_CTBCACH" , "1" ) == "1" )   //"0"=Nao Trabalha com Cache "1"=Trabalha com Cache
	EndIf
Return(__lCacheIs)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbLoadAcAtºAutor  ³Microsiga          º Data ³  11/26/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega os campos dinamicos de atividade complementar      º±±
±±º          ³ configurados no lançamento padrão.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbLoadAcAt(cAliasCT2,cDBCR)
Local aArea
Local aAreaSX3

	If __lAtivComp == NIL
		aArea       := GetArea()
		aAreaSX3    := SX3->( GetArea() )
		__lAtivComp := .T.

		DbSelectArea("SX3")
		DbSetOrder(2)
		If _aAtivCT1 == NIL
			_aAtivCT1 := {}
			If DbSeek("CT1_ACAT01")
				While SX3->(! Eof() .And. Substr(SX3->X3_CAMPO,1,8)=="CT1_ACAT")
					If  SX3->X3_ARQUIVO = "CT1"  .and. Val(Substr(SX3->X3_CAMPO, 9, 2)) >= 1 .and. X3USO( SX3->X3_USADO )
						AADD(_aAtivCT1, {"CT1->CT1_AT"	+ Substr(SX3->X3_CAMPO, 9, 2) + "OB";
						,"CT1->CT1_ACAT"+ Substr(SX3->X3_CAMPO, 9, 2),cAliasCT2 + "CT2_AT" + Substr(SX3->X3_CAMPO, 9, 2) + cDBCR})
					EndIf
					SX3->(DbSkip())
				EndDo
			EndIf
		EndIf

		If _aAtivCTT == NIL
			_aAtivCTT := {}
			If DbSeek("CTT_ACAT01")
				While Substr(SX3->X3_CAMPO,1,8)=="CTT_ACAT"
					If SX3->X3_ARQUIVO = "CTT" .and. Val(Substr(SX3->X3_CAMPO, 9, 2)) >= 1 .and. X3USO( SX3->X3_USADO )
						AADD(_aAtivCTT,	{"CTT->CTT_AT"   + Substr(SX3->X3_CAMPO, 9, 2) + "OB";
						,"CTT->CTT_ACAT" + Substr(SX3->X3_CAMPO, 9, 2),cAliasCT2 + "CT2_AT" + Substr(SX3->X3_CAMPO, 9, 2) + cDBCR})
					EndIf
					SX3->(DbSkip())
				EndDo
			EndIf
		EndIf

		If _aAtivCTD == NIL
			_aAtivCTD := {}
			If DbSeek("CTD_ACAT01")
				While SX3->( !Eof() .And.Substr(SX3->X3_CAMPO,1,8) == "CTD_ACAT")
					If SX3->X3_ARQUIVO = "CTD" .and. Val(Substr(SX3->X3_CAMPO, 9, 2)) >= 1 .and. X3USO( SX3->X3_USADO )
						AADD(_aAtivCTD,	{"CTD->CTD_AT"	+ Substr(SX3->X3_CAMPO, 9, 2) + "OB";
						,"CTD->CTD_ACAT"+ Substr(SX3->X3_CAMPO, 9, 2),cAliasCT2 + "CT2_AT" + Substr(SX3->X3_CAMPO, 9, 2) + cDBCR})
					EndIf
					SX3->(DbSkip())
				EndDo
			EndIf
		EndIf

		If _aAtivCTH == NIL
			_aAtivCTH := {}
			If DbSeek("CTH_ACAT01")
				While SX3->( !Eof() .And. Substr(SX3->X3_CAMPO,1,8)=="CTH_ACAT" )
					If SX3->X3_ARQUIVO = "CTH" .and. Val(Substr(SX3->X3_CAMPO, 9, 2)) >= 1 .and.  X3USO( SX3->X3_USADO )
						AADD(_aAtivCTH,	{"CTH->CTH_AT"   + Substr(SX3->X3_CAMPO, 9, 2) + "OB";
						,"CTH->CTH_ACAT" + Substr(SX3->X3_CAMPO, 9, 2),cAliasCT2 + "CT2_AT" + Substr(SX3->X3_CAMPO, 9, 2) + cDBCR})
					EndIf
					SX3->(DbSkip())
				EndDo
			EndIf
		EndIf

		RestArea(aAreaSX3)
		RestArea(aArea)
	EndIf

Return


Function SldAntCVX(dDataIni,dDataFin,cMoeda,cTpSaldo,cEntCont,cConta,cCusto,cItem,cCLVL,c5Ent)
Local aTamSaldo  := TamSX3("CVX_SLDDEB")
Local cQryPerAn2 := ""
Local aSldAntCVx := {0,0,0}
Local aAreaCvx   := GetArea()

	If Select("SLDANT2") > 0
		SLDANT2->(dbCloseArea())
	Endif

	cQryPerAn2 := "SELECT SUM(CVX_SLDDEB) CVX_SLDDEB,SUM(CVX_SLDCRD) CVX_SLDCRD"
	cQryPerAn2 += " FROM " + RetSqlName("CVX") + " CVX"
	cQryPerAn2 += " WHERE "
	cQryPerAn2 += "	CVX_FILIAL = '"+xFilial("CVX")+"' "
	cQryPerAn2 += "  AND CVX_DATA < '"+DTOS(dDataIni)+"' "
	cQryPerAn2 += " AND CVX_NIV01 = '" + cConta + "' "

	If "2" $ cEntCont .and. !Empty(cCusto)
		cQryPerAn2 += " AND CVX_NIV02 = '" + cCusto + "' "
	EndIf	        ADMIN
	If "3" $ cEntCont .and. !Empty(cItem)
		cQryPerAn2 += " AND CVX_NIV03 = '" + cItem + "' "
	EndIf
	If "4" $ cEntCont .and. !Empty(cCLVL)
		cQryPerAn2 += " AND CVX_NIV04 = '" + cCLVL + "' "
	EndIf
	If "5" $ cEntCont .and. !Empty(c5Ent)
		cQryPerAn2 += " AND CVX_NIV05 = '" + c5Ent + "' "
	EndIf
	If cPaisLoc="COL" .and. "5" $ cEntCont
		cQryPerAn2 += " AND CVX_NIV05 <> '' "
	EndIf

	cQryPerAn2 += " AND CVX_MOEDA = '" + cMoeda + "' "
	cQryPerAn2 += " AND CVX_TPSALD = '" + cTpSaldo + "' "
	cQryPerAn2 += " AND D_E_L_E_T_ = ' ' "

	cQryPerAn2 := ChangeQuery(cQryPerAn2)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryPerAn2),"SLDANT2",.T.,.F.)

	TcSetField("SLDANT2","CVX_SLDDEB"  ,"N",aTamSaldo[1],aTamSaldo[2])
	TcSetField("SLDANT2","CVX_SLDCRD"  ,"N",aTamSaldo[1],aTamSaldo[2])

	DbSelectArea("SLDANT2")
    SLDANT2->(DbGoTop())
	    If  SLDANT2->(!EOF())
	    	aSldAntCVx[1]:= SLDANT2->CVX_SLDDEB
	    	aSldAntCVx[2]:= SLDANT2->CVX_SLDCRD
	    	aSldAntCVx[3]:= SLDANT2->CVX_SLDDEB-SLDANT2->CVX_SLDCRD
		EndIf
	SLDANT2->(DbCloseArea())

	RestArea(aAreaCvx)
Return aSldAntCVx

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SeekCte    ºAutor  ³Microsiga          º Data ³  11/26/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcion para buscar los clientes en base a la entidad      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function SeekCte(cCliente, cLoja, cNumDoc)
	
	Local lRet		:= .T.
	Local cQryCte	:= ""
	Local cFilSA1	:= xFilial("SA1")
	
	Default cCliente	:= ""
	Default cLoja		:= ""

	cQryCte := "SELECT A1_NOMEPRI, A1_NOMEPES, A1_NOMEMAT, A1_NOMEPAT, A1_NOME, A1_END, A1_COD_MUN, A1_EST, A1_PAIS, "
	cQryCte += "A1_TIPDOC, A1_PFISICA, A1_CGC, A1_EMAIL "
	cQryCte += "FROM " + RetSqlName("SA1") + " SA1 "
	cQryCte += "WHERE A1_FILIAL = '" + cFilSA1 + "' "
	cQryCte += "AND A1_COD = '" + cCliente + "' "
	cQryCte += "AND A1_LOJA = '" + cLoja + "' "
	cQryCte += "AND D_E_L_E_T_ = ' '"
	cQryCte := ChangeQuery(cQryCte)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCte),"QryCte",.T.,.F.)
	
	If QryCte->(EOF())
		lRet := .F.
	Else
		If AllTrim(QryCte->A1_TIPDOC) == "31"
			cNumDoc := QryCte->A1_CGC
		Else
			cNumDoc := QryCte->A1_PFISICA
		Endif
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SeekPro    ºAutor  ³Microsiga          º Data ³  11/26/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcion para buscar los proveedores en base a la entidad   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function SeekPro(cEntidad)
Local lRet    := .T.
Local cQryPro := ""

	cQryPro := "SELECT A2_NOMEPRI,A2_NOMEPES,A2_NOMEMAT,A2_NOMEPAT ,A2_NOME,A2_END,A2_COD_MUN, "
	cQryPro += "A2_EST,A2_PAIS,A2_TIPDOC,A2_PFISICA,A2_CGC,A2_EMAIL FROM "
	cQryPro += RetSqlName("SA2") + " SA2 "
	cQryPro += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' "
	cQryPro += "  AND A2_PFISICA = '" + cEntidad + "' "
	cQryPro += "  AND D_E_L_E_T_ = ' ' "
	cQryPro := ChangeQuery(cQryPro)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryPro),"QryPro",.T.,.F.)
	IF QryPro->(EOF())
	   lRet:= .f.
	ENDIF

Return lRet
/*{Protheus.doc} GerInfFMT
Redirecionada para a pasta do MI 
Master/Adm/Localizações

@author TOTVS

@version P12
@since 08/07/2019
*/
Function GerInfFMT(cPlanoRef,dDataIni,dDataFin,cMoeda,nLimite,nColunas,cEntCont,cTipDoc,cDocumen,cDocEst,cCodDoc,aLimSec,lFirst)
Return _GerInfFMT(@cPlanoRef,@dDataIni,@dDataFin,@cMoeda,@nLimite,@nColunas,@cEntCont,@cTipDoc,@cDocumen,@cDocEst,@cCodDoc,aLimSec,@lFirst)
/*{Protheus.doc} EncInfFMT
Redirecionada para a pasta do MI 
Master/Adm/Localizações

@author TOTVS

@version P12
@since 08/07/2019
*/
Function EncInfFMT(cPlanoRef,cParam,cConteudo,lClose)
Return _EncInfFMT(@cPlanoRef,@cParam,@cConteudo,@lClose)

/*{Protheus.doc} CtbMod22Pt
Redirecionada para a pasta do MI 
Master/Adm/Localizações
CtxMod22Pt

@author TOTVS

@version P12
@since 25/02/2021
*/
function CtbMod22Pt(aParam, aVisao, cAliasQ12, cAlias396, cAlias397)
	//Direcionamento para CTBXMI CtxMod22Pt. 
return CtxMod22Pt(aParam, aVisao, cAliasQ12, cAlias396, cAlias397)

/*/{Protheus.doc} ClearAsp
	Função que troca o apostrofo de código para o codigo de caractere ASC para ser usado em querys
	@type   Function
	@author totvs
	@since 14/04/2021
	@version 12.
	@param param: cCodigoCA, param_type: caractere, param_descr: Codigo a ser tratado
	@return return: cCodigoCA, return_type: caractere, return_description: Código tratado
/*/
Function ClearAsp(cCodigoCA)

	// Efetuado tratamento para conteudo de campo contendo aspas simples em banco oracle/Postgres.
	If !_cGetDB $ "ORACLE|POSTGRES"
		cCodigoCA := Strtran(cCodigoCA,"'","'+CHAR(39)+'")
	Else
		cCodigoCA := OrclAspChr(cCodigoCA)
	Endif

Return cCodigoCA
