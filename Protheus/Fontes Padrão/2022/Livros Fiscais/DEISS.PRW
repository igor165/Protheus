#include 'protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DEISS     ºAutor  ³Microsiga           º Data ³  24/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para processamento do livro fiscal de ISS onde ar-   º±±
±±º          ³ mazenas as informacoes em um arquivo trabalho para poste-  º±±
±±º          ³ riores leituras no .INI                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DEISS(aTrbs, aFilsCalc)
Local lRet		:=	.T.
Local lProcessa	:=	.T.
Local nX		:=	0
Local aStru		:=	{}
Local cArq		:=	""
Local cDbf1		:=	"F3_FILIAL=='"+xFilial ("SF3")+"' .AND. DToS (F3_ENTRADA)>='"+DToS (MV_PAR01)+"' .AND. DToS (F3_ENTRADA)<='"+DToS (MV_PAR02)+"' .AND. F3_TIPO=='S' "
Local cTop1		:=	"F3_FILIAL='"+xFilial ("SF3")+"' AND F3_ENTRADA>='"+DToS (MV_PAR01)+"' AND F3_ENTRADA<='"+DToS (MV_PAR02)+"' AND F3_TIPO='S' "
Local aSF3		:= {"SF3", ""}
Local cFilOrig	:= cFilAnt
Local cRecIss	:= ''

Default aFilsCalc:= { { .T., cFilAnt } }

If Len (aTrbs)>0
	For nX := 1 To Len (aTrbs)
		If File (aTrbs[nX,1]+GetDBExtension ())
			DbSelectArea (aTrbs[nX,2])
			DbCloseArea ()
			Ferase (aTrbs[nX,1]+GetDBExtension ())
			Ferase (aTrbs[nX,1]+OrdBagExt ())
		Endif
	Next (nX)
	lProcessa	:=	.F.
EndIf

If lProcessa
	//-- TRP para Registros Prestados
	aAdd (aStru, {"RP_CHAVE",	"C",	060,	0})
	aAdd (aStru, {"RP_CNPJP",	"C",	014,	0})
	aAdd (aStru, {"RP_SERIE",	"C",	TamSx3("F3_SERIE")[1],	0})
	aAdd (aStru, {"RP_INSCR",	"N",	009,	0})
	aAdd (aStru, {"RP_ANOMES",	"C",	006,	0})
	aAdd (aStru, {"RP_CODATIV",	"C",	006,	0})
	aAdd (aStru, {"RP_DEMISS",	"C",	002,	0})
	aAdd (aStru, {"RP_NFINICI",	"N",	009,	0})
	aAdd (aStru, {"RP_NFFINAL",	"N",	009,	0})
	aAdd (aStru, {"RP_TPLANC",	"C",	025,	0})
	aAdd (aStru, {"RP_VLNF",	"N",	014,	2})
	aAdd (aStru, {"RP_ALIQISS",	"N",	005,	2})
	aAdd (aStru, {"RP_VLISS",	"N",	014,	2})
	aAdd (aStru, {"RP_MUNINCI",	"C",	007,	0})
	aAdd (aStru, {"RP_MUNREAL",	"C",	007,	0})
	aAdd (aStru, {"RP_PAIS",	"C",	004,	0})
	aAdd (aStru, {"RP_EXIGIB",	"C",	001,	0})
	aAdd (aStru, {"RP_SIMPNAC",	"C",	001,	0})
	aAdd (aStru, {"RP_ISSRET",	"C",	001,	0})
	aAdd (aStru, {"RP_REGIME",	"C",	001,	0})
	aAdd (aStru, {"RP_RAZAO",	"C",	100,	0})
	aAdd (aStru, {"RP_VLDESC",	"N",	014,	2})
	aAdd (aStru, {"RP_CNPJT",	"C",	014,	0})
	aAdd (aStru, {"RP_SDOC",	"C",	005,	0})

	cArq	:=	CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"TRP")
	IndRegua("TRP",cArq,"RP_CHAVE")

	//-- TRC para Registros Tomados
	aAdd (aStru, {"RC_CHAVE",	"C",	060,	0})
	aAdd (aStru, {"RC_INSCR",	"N",	009,	0})
	aAdd (aStru, {"RC_ANOMES",	"C",	006,	0})
	aAdd (aStru, {"RC_CODATIV",	"C",	006,	0})
	aAdd (aStru, {"RC_DEMISS",	"C",	002,	0})
	aAdd (aStru, {"RC_NFINICI",	"N",	009,	0})
	aAdd (aStru, {"RC_NFFINAL",	"N",	009,	0})
	aAdd (aStru, {"RC_SERIE",	"C",	TamSx3("F3_SERIE")[1],	0})
	aAdd (aStru, {"RC_TPLANC",	"C",	025,	0})
	aAdd (aStru, {"RC_VLNF",	"N",	014,	2})
	aAdd (aStru, {"RC_ALIQISS",	"N",	005,	2})
	aAdd (aStru, {"RC_VLISS",	"N",	014,	2})
	aAdd (aStru, {"RC_CNPJT",	"C",	014,	0})
	aAdd (aStru, {"RC_MUNINCI",	"C",	007,	0})
	aAdd (aStru, {"RC_MUNREAL",	"C",	007,	0})
	aAdd (aStru, {"RC_PAIS",	"C",	004,	0})
	aAdd (aStru, {"RC_EXIGIB",	"C",	001,	0})
	aAdd (aStru, {"RC_SIMPNAC",	"C",	001,	0})
	aAdd (aStru, {"RC_ISSRET",	"C",	001,	0})
	aAdd (aStru, {"RC_REGIME",	"C",	001,	0})
	aAdd (aStru, {"RC_RAZAO",	"C",	100,	0})
	aAdd (aStru, {"RC_VLDESC",	"N",	014,	2})
	aAdd (aStru, {"RC_CNPJP",	"C",	014,	0})
	aAdd (aStru, {"RC_SDOC",	"C",	005,	0})

	cArq	:=	CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"TRC")
	IndRegua("TRC",cArq,"RC_CHAVE") 

	//-- Processamento para alimentar os TRs criados acima
	DbSelectArea ("SF3")
	SF3->(DbSetOrder (1))
	FsQuery (aSF3, 1, cTop1, cDbf1, SF3->(IndexKey ()),,,,,,,IIf(lAglFil,aFilsCalc,NIL))
	SF3->(DbGoTop ())
	Do While !SF3->(Eof ())
		cFilAnt := IIf(Empty(SF3->F3_FILIAL),cFilAnt,SF3->F3_FILIAL)
		If Left (SF3->F3_CFO, 1)>="5"
			SA1->(DbSetOrder (1))
			If SA1->(DbSeek (xFilial ("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))

				SD2->(DbSetOrder(3))
				SD2->(MsSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
				SF4->(DbSetOrder(1))
				SF4->(MsSeek(xFilial("SF4")+SD2->D2_TES))

				If !Empty (SF3->F3_RECISS)
					cRecIss		:=	Iif (SF3->F3_RECISS$"1S", "S", "N")
				Else
					cRecIss		:=	Iif (SA1->A1_RECISS$"1S", "S", "N")
				EndIf

				If !TRP->(DbSeek (xFilial ("SF3")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
					RecLock ("TRP", .T.)
					TRP->RP_CHAVE	:=	xFilial ("SF3")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
					TRP->RP_ANOMES	:=	StrZero(Year(SF3->F3_EMISSAO),4)+StrZero(Month(SF3->F3_EMISSAO),2)
					TRP->RP_CODATIV	:=	SF3->F3_CODISS
					TRP->RP_DEMISS	:=	StrZero(Day(SF3->F3_EMISSAO),2)
					TRP->RP_NFINICI	:=	Val(SF3->F3_NFISCAL)
					TRP->RP_NFFINAL	:=	Val(SF3->F3_NFISCAL)
					TRP->RP_SERIE	:=	Left(Alltrim(SF3->F3_SERIE),5)
					TRP->RP_TPLANC	:=	Iif(!Empty(SF3->F3_DTCANC).Or."CANCEL"$SF3->F3_OBSERV,"C","N")
					TRP->RP_VLNF	:=	SF3->F3_VALCONT
					TRP->RP_ALIQISS	:=	SF3->F3_ALIQICM
					TRP->RP_VLISS	:=	Iif(SF3->F3_TIPO=='S',SF3->F3_VALICM,0)
					TRP->RP_MUNINCI	:=	SM0->M0_CODMUN
					TRP->RP_MUNREAL	:=	IiF(SA1->A1_EST$"EX",Replicate("9",7),UfCodIBGE(SA1->A1_EST)+SA2->A2_COD_MUN)
					TRP->RP_PAIS	:=	IiF(SA1->A1_EST$"EX",SubStr(SA1->A1_CODPAIS,2,4),"")
					TRP->RP_EXIGIB	:=	Iif(SF4->F4_ISS$"1/S","1",(Iif(SF4->F4_LFISS$"I/O" .And. SF4->F4_CSTISS$"06","3",(Iif(SF4->F4_LFISS$"I/O" .And. SF4->F4_CSTISS$"07","2",Iif(Substr(SF4->F4_CF,1,1)$"7","4","5"))))))
					TRP->RP_SIMPNAC	:=	Iif(Empty(SA1->A1_SIMPNAC),"2",SA1->A1_SIMPNAC)
					TRP->RP_ISSRET	:=	Iif(cRecIss=="S","1","2")
					TRP->RP_REGIME	:=	Iif(SA1->A1_TPJ=="1","1",Iif(SA1->A1_TPJ=="2","6",Iif(SA1->A1_TPJ=="3","5","")))
					TRP->RP_CNPJT	:=	SA1->A1_CGC
					TRP->RP_RAZAO	:=	AllTrim (SA1->A1_NOME)
					TRP->RP_CNPJP	:=	SM0->M0_CGC
					TRP->RP_SDOC	:=	Left(Alltrim(SerieNfId("SF3",2,"F3_SERIE")),5)
					MsUnLock()
				EndIf
			EndIf
		Else
			DbSelectArea ("SA2")
				SA2->(DbSetOrder (1))
			If SA2->(DbSeek (xFilial ("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA))

				SD1->(DbSetOrder(1))
				SD1->(MsSeek(xFilial("SD1")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
				SF4->(DbSetOrder(1))
				SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))

				If !Empty (SF3->F3_RECISS)
					cRecIss		:=	Iif (SF3->F3_RECISS$"2N", "S", "N")
				Else
					cRecIss		:=	Iif (SA2->A2_RECISS$"2N", "S", "N")
				EndIf

				If !TRC->(DbSeek (xFilial ("SF3")+ SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
					RecLock ("TRC", .T.)
					TRC->RC_CHAVE	:=	xFilial ("SF3")+ SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
					TRC->RC_ANOMES	:=	StrZero(Year(SF3->F3_EMISSAO),4)+StrZero(Month(SF3->F3_EMISSAO),2)
					TRC->RC_CODATIV	:=	SF3->F3_CODISS
					TRC->RC_DEMISS	:=	StrZero(Day(SF3->F3_EMISSAO),2)
					TRC->RC_NFINICI	:=	Val(SF3->F3_NFISCAL)
					TRC->RC_NFFINAL	:=	Val(SF3->F3_NFISCAL)
					TRC->RC_SERIE	:=	Left(Alltrim(SF3->F3_SERIE),5)
					TRC->RC_TPLANC	:=	Iif(!Empty(SF3->F3_DTCANC).Or."CANCEL"$SF3->F3_OBSERV,"C","N")
					TRC->RC_VLNF	:=	SF3->F3_VALCONT
					TRC->RC_ALIQISS	:=	SF3->F3_ALIQICM
					TRC->RC_VLISS	:=	Iif(SF3->F3_TIPO=='S',SF3->F3_VALICM,0)
					TRC->RC_CNPJP	:=	SA2->A2_CGC
					TRC->RC_MUNINCI	:=	Iif(SA2->A2_EST$"EX",Replicate("9",7),UfCodIBGE(SA2->A2_EST)+SA2->A2_COD_MUN)
					TRC->RC_MUNREAL	:=	SM0->M0_CODMUN
					TRC->RC_PAIS	:=	""
					TRC->RC_EXIGIB	:=	Iif(SF4->F4_ISS$"1/S","1",(Iif(SF4->F4_LFISS$"I/O" .And. SF4->F4_CSTISS$"06","3",(Iif(SF4->F4_LFISS$"I/O" .And. SF4->F4_CSTISS$"07","2",Iif(Substr(SF4->F4_CF,1,1)$"7","4","5"))))))
					TRC->RC_SIMPNAC	:=	Iif(Empty(SA2->A2_SIMPNAC),"2",SA2->A2_SIMPNAC)
					TRC->RC_ISSRET	:=	Iif(cRecIss=="S","1","2")
					TRC->RC_REGIME	:=	Iif(SA2->A2_TPJ=="1","1",Iif(SA2->A2_TPJ=="2","6",Iif(SA2->A2_TPJ=="3","5",Iif(SA2->A2_TPJ=="4","4",""))))
					TRC->RC_RAZAO	:=	AllTrim (SA2->A2_NOME)
					TRC->RC_CNPJT	:=	SM0->M0_CGC
					TRC->RC_SDOC	:=	Left(Alltrim(SerieNfId("SF3",2,"F3_SERIE")),5)
					MsUnLock()
				EndIf
			EndIf
		EndIf

		SF3->(DbSkip ())
	EndDo
	FsQuery (aSF3, 2)
	cFilAnt := cFilOrig
EndIf

Return (lRet)
