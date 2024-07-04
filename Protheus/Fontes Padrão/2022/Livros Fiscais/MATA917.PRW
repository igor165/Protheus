#INCLUDE "MATA917.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE GD_VISUAL	0
#DEFINE GD_INSERT	1
#DEFINE GD_UPDATE	2
#DEFINE GD_DELETE	4
#DEFINE X3_USADO_EMUSO "€€€€€€€€€€€€€€ "
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAJUSTSFT  บAutor  ณGustavo G. Rueda    บ Data ณ  03/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de montagem da tela de manutencao do SF3 e SFT       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MATA917
Local	lRet		:=	.T.
Local	aObjects 	:= {}
Local	aSizeAut	:= MsAdvSize (,.F.,400)
Local	oGetDados
Local	nX			:=	0
Local	nUsadSF3	:=	0
Local	nUsadSFT	:=	0
Local	aInfo		:=	{}
Local	aPosObj		:=	{}
Local	aPosGet		:=	{}
Local	nOpcA		:=	0
Local	cSerie		:=	SF3->F3_SERIE
Local	cNota		:=	SF3->F3_NFISCAL
Local	cCliefor	:=	SF3->F3_CLIEFOR
Local	cLoja		:=	SF3->F3_LOJA
Local	cEntSai		:=	Iif (Left (SF3->F3_CFO, 1)>="5", "S", "E")
Local	oReproc 
Local	cReproc		:=	Iif (SF3->F3_REPROC=="N", "2", "1")
Local	aReproc		:=	{"1=Sim", "2=Nใo"}
Local	aAlterSF3	:=	{"F3_CFO","F3_CODISS","F3_CONTA","F3_OBSERV","F3_LANCAM","F3_NRLIVRO","F3_FORMULA","F3_PDV","F3_DTLANC","F3_DTCANC","F3_ISSST","F3_CREDST","F3_CFOEXT","F3_RECISS","F3_CFPS","F3_NFELETR","F3_EMINFE","F3_HORNFE","F3_CODNFE", "F3_ALIQICM", "F3_ALQIMP1", "F3_ALQIMP2", "F3_ALQIMP3", "F3_ALQIMP4", "F3_ALQIMP5", "F3_ALQIMP6", "F3_ALIQPS3", "F3_ALIQCF3", "F3_ENTRADA"}
Local	aAlterSFT	:=	{}
Local	cNotSer		:=	cNota+" / "+SerieNfId("SF3",2,"F3_SERIE")
Local	cCliForLoj	:=	cCliefor+" / "+cLoja
Local	cTipoNF		:=	Iif (Empty (SF3->F3_TIPO), "N", SF3->F3_TIPO)
Local	cFormul		:=	Iif( SubStr(SF3->F3_CFO,1,1) >= "5" ,"S", Iif( Empty(SF3->F3_FORMUL) , "N" , SF3->F3_FORMUL) )   
Local	cEspecie	:=  Iif (!Empty (SF3->F3_ESPECIE),SF3->F3_ESPECIE, "     ")
Local	aHeadSF3	:=	RetHead ("SF3", .T., {"F3_CFO","F3_CODISS","F3_CONTA","F3_OBSERV","F3_LANCAM","F3_NRLIVRO","F3_FORMULA","F3_PDV","F3_DTLANC","F3_DTCANC","F3_ISSST","F3_CREDST","F3_CFOEXT","F3_RECISS","F3_CFPS","F3_NFELETR","F3_EMINFE","F3_HORNFE","F3_CODNFE", "F3_ALIQICM", "F3_IDENTFT", "F3_ALQIMP1", "F3_ALQIMP2", "F3_ALQIMP3", "F3_ALQIMP4", "F3_ALQIMP5", "F3_ALQIMP6", "F3_ALIQPS3", "F3_ALIQCF3", "F3_ENTRADA"})
Local	aHeadSFT	:=	RetHead ("SFT", .F., {"FT_QUANT","FT_PRCUNIT","FT_TOTAL","FT_POSIPI","FT_FILIAL","FT_ENTRADA","FT_EMISSAO","FT_NFISCAL","FT_SERIE","FT_CLIEFOR","FT_LOJA","FT_ESTADO","FT_CFOP","FT_CODISS","FT_ALIQICM","FT_FORMULA","FT_NRLIVRO","FT_CFOEXT","FT_CFPS","FT_OBSERV","FT_DTCANC","FT_ISSST","FT_PDV","FT_CREDST","FT_RECISS", "FT_TIPOMOV", "FT_CFPS","FT_NFELETR","FT_EMINFE","FT_HORNFE","FT_CODNFE", "FT_ALIQIPI", "FT_TIPO", "FT_ALQIMP1", "FT_ALQIMP2", "FT_ALQIMP3", "FT_ALQIMP4", "FT_ALQIMP5", "FT_ALQIMP6", "FT_ESTOQUE", "FT_DESPIPI", "FT_FORMUL", "FT_ALIQPS3", "FT_ALIQCF3"})
Local	aColsSF3	:=	{}
Local	aColsSFT	:=	{}
Local	oDlg                                                           
Local	aPages		:=	{"HEADER"}
Local	aTitles		:=	{STR0001, STR0002}	//"Manutencao"###"Resumo"
Local	aArq		:=	{}
Local	aHeadLOG	:=	{}
Local	aColsLOG	:=	{}
Local	nAviso		:=	0
Local	dData		:= CtoD(Space(08))
Local   nLinApr		:=	0
Local   lEdit       := .F.

If Val(substr(SF3->F3_CFO,1,1))>=5
	dData:=SF3->F3_EMISSAO
Else
	dData:=SF3->F3_ENTRADA
Endif

If !FisChkDt(dData)
	Return (.T.)
EndIf

nAviso := Aviso("Atencao",STR0015,{"Sim","Nao"},3)

If nAviso==2 .Or. nAviso==0
	Return (.T.)
EndIf

Private	oGDadSF3
Private	oGDadSFT
Private	oGDadLOG
Private	aCmpsAlt	:=	{}

DbSelectArea ("SFT")
SFT->(DbSetOrder (3))
If !SFT->(MsSeek (xFilial ("SFT")+cEntSai+SF3->(F3_CLIEFOR+F3_LOJA+F3_SERIE+F3_NFISCAL+F3_IDENTFT)))
	xMagHelpFis ("Aten็ใo - Processo interrompido",;
	STR0016,;	//"O Acerto Fiscal Por Item somente ้ permitido para Notas Fiscais que possuam escritura็ใo fiscal por item (tabela SFT) relacionado, ou seja, que tenha vindo de um processo completo, COMPRAS ou FATURAMENTO. Neste caso, nใo foi encontrado tal relacionamento nใo premitindo a execu็ใo da op็ใo solicitada."
	STR0017) //"A tabela de Livros Fiscais por item (SFT) necessita dos itens da Nota Fiscal (Tabela SD1 ou SD2) que neste caso nใo existe, pois esta Nota Fiscal pode ter sido incluํda manualmente atrav้s de acertos fiscais onde nใo serแ possํvel tal manuten็ใo devido somente existir informa็๕es na tabela SF3 (Livros Fiscais)."
	Return (.T.)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriando o array aAlterSFTณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 To Len (aHeadSFT)

	Do Case
		Case AllTrim (aHeadSFT[nX][2])$"FT_PRODUTO/FT_ITEM/FT_IDENTF3/"
			lEdit := .F.
		Case AllTrim (aHeadSFT[nX][2]) $ "FT_CONTA" 
			lEdit := .T.
		OtherWise
			nPos := aScan (aAlterSF3, "F3"+SubStr (AllTrim (aHeadSFT[nX][2]), 3))
			
			If nPos > 0
				lEdit := .F.
			Else
				lEdit := .T.
			EndIf
	EndCase

	If lEdit
		aAdd (aAlterSFT, AllTrim (aHeadSFT[nX][2]))
	EndIf
Next (nX)

nUsadSF3	:=	Len (aHeadSF3)
nUsadSFT	:=	Len (aHeadSFT)
                                                                               	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriacao do TRB de LOGณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oTempLog := CriaTrb (@aArq, @aHeadLOG, @aColsLOG)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta as dimensoes da telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AAdd (aObjects, {100, 040, .T., .F.})
AAdd (aObjects, {100, 020, .T., .T.})
AAdd (aObjects, {100, 040, .T., .T.})

aInfo	:=	{aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3}
aPosObj := MsObjSize (aInfo, aObjects)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciono no acols todos os itens do SF3 e SFT para manutencaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea ("SF3")
SF3->(DbSetOrder (5))
SF3->(MsSeek (xFilial ("SF3")+cSerie+cNota+cCliefor+cLoja))
Do While !SF3->(Eof ()) .And.;
	xFilial ("SF3")+cSerie+cNota+cCliefor+cLoja==xFilial ("SF3")+SF3->(F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA)

	If !(cEntSai==Iif (Left (SF3->F3_CFO, 1)>="5", "S", "E"))
		SF3->( DbSkip() )
		Loop
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณArmazenamento do SF3 no aColsSF3ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd (aColsSF3, Array (nUsadSF3+1))
	For nX := 1 To nUsadSF3
		If (aHeadSF3[nX][10]!="V")
			aColsSF3[Len (aColsSF3)][nX] := SF3->(FieldGet (FieldPos (aHeadSF3[nX][2])))
		Else
			aColsSF3[Len (aColsSF3)][nX] := CriaVar (aHeadSF3[nX][2], .T.)
		EndIf
	Next nX
	aColsSF3[Len (aColsSF3)][nUsadSF3+1] := .F.
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAdiciono no acols todos os itens do SFT para manutencaoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea ("SFT")
	SFT->(DbSetOrder (3))
	SFT->(MsSeek (xFilial ("SFT")+cEntSai+SF3->(F3_CLIEFOR+F3_LOJA+F3_SERIE+F3_NFISCAL+F3_IDENTFT)))
	Do While !SFT->(Eof ()) .And.;
		xFilial ("SFT")+cEntSai+SF3->(F3_CLIEFOR+F3_LOJA+F3_SERIE+F3_NFISCAL+F3_IDENTFT)==xFilial ("SFT")+cEntSai+SFT->(FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL+FT_IDENTF3)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณArmazenamento do SFT no aColsSFTณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
		aAdd (aColsSFT, Array (nUsadSFT+1))
		For nX := 1 To nUsadSFT
			If (aHeadSFT[nX][10]!="V")
				aColsSFT[Len (aColsSFT)][nX] := SFT->(FieldGet (FieldPos (aHeadSFT[nX][2])))
			Else
				aColsSFT[Len (aColsSFT)][nX] := CriaVar (aHeadSFT[nX][2], .T.)
			EndIf
		Next nX
		aColsSFT[Len(aColsSFT)][nUsadSFT+1] := .F.

		SFT->(DbSkip ())
	EndDo
    
	DbSelectArea ("SF3")
	SF3->(DbSkip ())
EndDo

DEFINE MSDIALOG oDlg FROM aSizeAut[7], 0 TO aSizeAut[6], aSizeAut[5] TITLE OemToAnsi (STR0003) Of oMainWnd PIXEL	//"Acertos Fiscais"

oFolder := TFolder():New(aPosObj[1,1],aPosObj[1,2],aTitles,aPages,oDlg,,,,.T.,.F.,aSizeAut[3] - 3, aSizeAut[6])
oFolder:bSetOption := {|nDst| FldRefr (nDst, oFolder:nOption, oFolder)}

// Ajuste no posicionamento dos objetos

aPosObj[1,1] -= 30
aPosObj[1,3] -= 30

aPosObj[2,1] -= 30
aPosObj[2,3] -= 100

aPosObj[3,1] -= 100
aPosObj[3,3] -= 60

nLinApr	:=	aPosObj[1,1]
@ nLinApr, aPosObj[1,2] TO aPosObj[1,3], aPosObj[1,4]-10 LABEL '' OF oFolder:aDialogs[1] PIXEL

nLinApr	+=	10
@ nLinApr  ,010 SAY STR0004 OF oFolder:aDialogs[1] PIXEL SIZE 100,09	//"Considerar no reprocessamento ?"
@ nLinApr-2,105 COMBOBOX oReproc VAR cReproc ITEMS aReproc OF oFolder:aDialogs[1] PIXEL SIZE 40, 09

nLinApr	+=	16
@ nLinApr  ,010 SAY STR0005 OF oFolder:aDialogs[1] PIXEL SIZE 40, 09	//"Nota/S้rie"
@ nLinApr-2,041 MSGET cNotSer OF oFolder:aDialogs[1] PIXEL SIZE 47, 09 WHEN .F.

@ nLinApr  ,100 SAY STR0006 OF oFolder:aDialogs[1] PIXEL SIZE 55, 09	//"Cliente/Forn."
@ nLinApr-2,140 MSGET cCliforLoj OF oFolder:aDialogs[1] PIXEL SIZE 40, 09 WHEN .F.

@ nLinApr  ,192 SAY STR0007 OF oFolder:aDialogs[1] PIXEL SIZE 15, 09	//"Tipo"
@ nLinApr-2,207 MSGET cTipoNF OF oFolder:aDialogs[1] PIXEL SIZE 10, 09 WHEN .F.

@ nLinApr,230 SAY STR0008 OF oFolder:aDialogs[1] PIXEL SIZE 70, 09	//"Form. Pr๓prio"
@ nLinApr-2,270 MSGET cFormul OF oFolder:aDialogs[1] PIXEL SIZE 10, 09 WHEN .F.

@ nLinApr,290 SAY STR0009 OF oFolder:aDialogs[1] PIXEL SIZE 20, 09	//"Espษcie"
@ nLinApr-2,315 MSGET cEspecie OF oFolder:aDialogs[1] PIXEL SIZE 10, 09 WHEN .F.

oGDadSF3 := MSNewGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4]-10, GD_UPDATE,'AllwaysTrue()','AllwaysTrue()',,aAlterSF3,,99,'aAddCmp()',,,oFolder:aDialogs[1],aHeadSF3,aColsSF3)
oGDadSFT := MSNewGetDados():New (aPosObj[3,1], aPosObj[3,2], aPosObj[3,3], aPosObj[3,4]-10, GD_UPDATE,'AllwaysTrue()','AllwaysTrue()',,aAlterSFT,,99,'aAddCmp()',,,oFolder:aDialogs[1],aHeadSFT,aColsSFT)

oGDadLOG := MSNewGetDados():New (aPosObj[1,1], 5, aPosObj[3,3], aPosObj[3,4]-10, GD_UPDATE,'AllwaysTrue()','AllwaysTrue()',,aAlterSFT,,99,'aAddCmp()',,,oFolder:aDialogs[2], aHeadLOG, aColsLOG)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {||nOpcA := 1, oDlg:End()},{||nOpcA := 0, oDlg:End()})

If nOpcA==1
	GrvSF3SFT (cReproc, cEntSai, cSerie, cNota, cCliefor, cLoja, aAlterSF3, aHeadSF3, aAlterSFT, aHeadSFT)
	AtuBas (cEntSai, cSerie, cNota, cCliefor, cLoja)
	TAFStamp(aHeadSF3, xFilial("SFT"), cEntSai, cSerie, cNota, cCliefor, cLoja, DtoS(dData))
EndIf

CriaTrb (aArq,,,oTempLog)

Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuSF3    บAutor  ณGustavo G. Rueda    บ Data ณ  03/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de atualizacao de campos alterados, atualizo o campo บฑฑ
ฑฑบ          ณ correspondente na tabela SF3 que foi alterado no SFT       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function aAddCmp ()
Local	cCmpVar		:=	SubStr (__READVAR, 4)
Local	aCmpsLOG	:=	Array (5)
Local	nI			:=	0
Local	aColsSF3	:=	aClone (oGDadSF3:aCols)
Local	aColsSFT	:=	aClone (oGDadSFT:aCols)
Local	aHeadSF3	:=	aClone (oGDadSF3:aHeader)
Local	aHeadSFT	:=	aClone (oGDadSFT:aHeader)
Local	nPosSF3		:=	aScan (aHeadSF3, {|aX| cCmpVar==AllTrim (aX[2])})
Local	nPosSFT		:=	aScan (aHeadSFT, {|aX| cCmpVar==AllTrim (aX[2])})


aCmpsLOG[1]	:=	StrZero (n, 4)
aCmpsLOG[2]	:=	cCmpVar
aCmpsLOG[3]	:=	"000"
If (nPosSF3>0)
	aCmpsLOG[4]	:=	Iif (ValType (aColsSF3[n][nPosSF3])=="C", aColsSF3[n][nPosSF3], Transform (aColsSF3[n][nPosSF3], "@E 9,999,999,999,999.99"))
ElseIf (nPosSFT>0)
	aCmpsLOG[4]	:=	Iif (ValType (aColsSFT[n][nPosSFT])=="C", aColsSFT[n][nPosSFT], Transform (aColsSFT[n][nPosSFT], "@E 9,999,999,999,999.99"))
EndIf
aCmpsLOG[5]	:=	Iif (ValType (&(__READVAR))=="C", &(__READVAR), Transform (&(__READVAR), "@E 9,999,999,999,999.99"))

If aScan (aCmpsAlt, {|cCmp| cCmp==cCmpVar})==0
	aAdd (aCmpsAlt, cCmpVar)
EndIf

LOG->(DbSeek (aCmpsLOG[1]+cCmpVar))
Do While !LOG->(Eof ()) .And. aCmpsLOG[1]+cCmpVar==LOG->LOG_ITEM+AllTrim (LOG->LOG_CAMPO)
	aCmpsLOG[3]	:=	LOG->LOG_SEQ
	
	LOG->(DbSkip ())
EndDo
aCmpsLOG[3]	:=	Soma1 (aCmpsLOG[3])

RecLock ("LOG", .T.)
	LOG->LOG_ITEM	:=	aCmpsLOG[1]
	LOG->LOG_CAMPO	:=	aCmpsLOG[2]
	LOG->LOG_SEQ	:=	aCmpsLOG[3]
	LOG->LOG_VLRANT	:=	aCmpsLOG[4]
	LOG->LOG_VLRATU	:=	aCmpsLOG[5]
MsUnLock ()
Return (.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetHead   บAutor  ณGustavo G. Rueda    บ Data ณ  03/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de montagem do header de campos para a tela de       บฑฑ
ฑฑบ          ณ manutencao                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetHead (cAls, lCons, aCmps)
Local	aHeader	:=	{}
Local	aSX3Util 	:= FwSX3Util():GetAllFields(cAls,.F.)
Local	aSX3Fields	:= {}
Local	nX := 0

For nX := 1 To Len(aSX3Util)

	aAdd(aSX3Fields,{aSX3Util[nX],;
		GetSx3Cache(aSX3Util[nX],"X3_TIPO"),;
		GetSx3Cache(aSX3Util[nX],"X3_TAMANHO"),;
		GetSx3Cache(aSX3Util[nX],"X3_DECIMAL"),;
		GetSx3Cache(aSX3Util[nX],"X3_ORDEM")})

Next nX

aSort(aSX3Fields,,,{ |x, y| x[5] < y[5] })

For nX := 1 To Len(aSX3Fields)

	If X3USO (GetSx3Cache(aSX3Fields[nX][1],"X3_USADO")) .And.;
		cNivel>=GetSx3Cache(aSX3Fields[nX][1],"X3_NIVEL") .And.;
		((lCons .And. aScan (aCmps, {|cCmp| cCmp==AllTrim (aSX3Fields[nX][1])})>0) .Or. (!lCons .And. aScan (aCmps, {|cCmp| cCmp==AllTrim (aSX3Fields[nX][1])})==0))
		
		aAdd (aHeader, {AllTrim (FWX3Titulo(aSX3Fields[nX][1])),;
			aSX3Fields[nX][1],;
			X3Picture(aSX3Fields[nX][1]),;
			GetSx3Cache(aSX3Fields[nX][1],"X3_TAMANHO"),;
			GetSx3Cache(aSX3Fields[nX][1],"X3_DECIMAL"),;
			".T.",;
			X3USO(GetSx3Cache(aSX3Fields[nX][1],"X3_USADO")),;
			GetSx3Cache(aSX3Fields[nX][1],"X3_TIPO"),;
			GetSx3Cache(aSX3Fields[nX][1],"X3_F3"),;
			GetSx3Cache(aSX3Fields[nX][1],"X3_CONTEXT")})

	EndIf
Next nX


Return (aHeader)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrvSF3SFT บAutor  ณGustavo G. Rueda    บ Data ณ  03/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de gravacao das tabelas SFT e SF3 ao confirmar a     บฑฑ
ฑฑบ          ณ rotina.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvSF3SFT (cReproc, cEntSai, cSerie, cNota, cCliefor, cLoja, aAlterSF3, aHeadSF3, aAlterSFT, aHeadSFT)
Local	lRet		:=	.T.
Local	nPosId		:=	0
Local	nX			:=	0
Local	nI			:=	0
Local	nPos		:=	0
Local	aDePara		:=	{}
Local	aColsSF3	:=	aClone (oGDadSF3:aCols)
Local	aColsSFT	:=	aClone (oGDadSFT:aCols)
Local	aIdZerou	:=	{}
Local	nPosProd	:=	0
Local	nPosItem	:=	0
Local	nPosOutIcm	:= aScan(aCmpsAlt, {|x| x=="FT_OUTRICM"})
Local	nPosOutRet	:= aScan(aCmpsAlt, {|x| x=="FT_OUTRRET"})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArray 'depara' de campos que nao coincidam entre as tabelas SFT e SF3.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd (aDePara,{"F3_CFO", "FT_CFOP"})
aAdd (aDePara, {"F3_OUTRICM", "FT_OUTRRET"})
// Os campos FT_OUTRICM e FT_OUTRRET devem sem replicados juntos, pois ambos compoem o valor do campo F3_OUTRICM
If nPosOutIcm > 0 .And. nPosOutRet == 0
	aAdd(aCmpsAlt, "FT_OUTRRET")
EndIf
If nPosOutIcm == 0 .And. nPosOutRet > 0
	aAdd(aCmpsAlt, "FT_OUTRICM")
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณReplicando SF3 para os SFTs correspondentesณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPosId	:=	aScan (aHeadSF3, {|aX| "F3_IDENTFT"$aX[2]})
If nPosId>0
	Begin Transaction 
	For nX := 1 To Len (aColsSF3)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualizando o SF3 com os dados nele digitados para atualizar a tabela SFT (logo abaixo)ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea ("SF3")
		SF3->(DbSetOrder (5))
		If SF3->(DbSeek (xFilial ("SF3")+cSerie+cNota+cCliefor+cLoja+aColsSF3[nX][nPosId]))

			RecLock ("SF3", .F.)
			For nI := 1 To Len (aHeadSF3)
				cCmpSF3	:=	AllTrim (aHeadSF3[nI][2])
				If aScan (aAlterSF3, {|cCmp| cCmp==cCmpSF3})>0 .And. aScan (aCmpsAlt, {|cCmp| cCmp==cCmpSF3})>0
					SF3->(FieldPut (FieldPos (cCmpSF3), aColsSF3[nX][nI]))
				EndIf
			Next (nI)
			SF3->F3_REPROC	:=	Iif (cReproc=="1", "S", "N")
			MsUnLock ()
			SF3->(FkCommit ())

		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualizacao da tabela SFT de acordo com as informacoes digitadas na tabela SF3ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea ("SFT")
		SFT->(DbSetOrder (3))
		If SFT->(DbSeek (xFilial ("SFT")+cEntSai+cCliefor+cLoja+cSerie+cNota+aColsSF3[nX][nPosId]))

			Do While !SFT->(Eof ()) .And.;
				SFT->(xFilial ()+FT_TIPOMOV+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL+FT_IDENTF3)==;
				xFilial ("SFT")+cEntSai+cCliefor+cLoja+cSerie+cNota+aColsSF3[nX][nPosId]
	
				RecLock ("SFT", .F.)
				For nI := 1 To Len (aHeadSF3)
					cCmpSF3	:=	AllTrim (aHeadSF3[nI][2])
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerifico se o campo em processamento para o aHeader foi digitado  (aCmpsAlt)ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If aScan (aAlterSF3, {|cCmp| cCmp==cCmpSF3})>0 .And. aScan (aCmpsAlt, {|cCmp| cCmp==cCmpSF3})>0
						nPos	:=	aScan (aDePara, {|aX| aX[1]==cCmpSF3})
						If nPos>0
							cCmpSFT	:=	aDePara[nPos][2]
						Else
							cCmpSFT	:=	"FT_"+SubStr (cCmpSF3, 4)
						EndIf
						If SFT->(FieldPos (cCmpSFT))>0
							SFT->(FieldPut (FieldPos (cCmpSFT), aColsSF3[nX][nI]))
						EndIf
					EndIf
				Next (nI)
				MsUnLock ()
				SFT->(FkCommit ())
				
				SFT->(DbSkip ())
			EndDo

		EndIf
	Next (nX)
	End Transaction
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณReplicando SFT para os SF3  correspondentesณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPosId		:=	aScan (aHeadSFT, {|aX| "FT_IDENTF3"$aX[2]})
If nPosId>0

	nPosProd	:=	aScan (aHeadSFT, {|aX| "FT_PRODUTO"$aX[2]})
	nPosItem	:=	aScan (aHeadSFT, {|aX| "FT_ITEM"$aX[2]})
	
	Begin Transaction
	For nX := 1 To Len (aColsSFT)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGravando as informacoes digitadas no aColsSFT para a tabela SFTณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea ("SFT")
		SFT->(DbSetOrder (1))
		If SFT->(DbSeek (xFilial ("SFT")+cEntSai+cSerie+cNota+cCliefor+cLoja+aColsSFT[nX][nPosItem]+aColsSFT[nX][nPosProd]))
			RecLock ("SFT", .F.)
			For nI := 1 To Len (aHeadSFT)
				cCmpSFT	:=	AllTrim (aHeadSFT[nI][2])
				If aScan (aAlterSFT, {|cCmp| cCmp==cCmpSFT})>0 .And. aScan (aCmpsAlt, {|cCmp| cCmp==cCmpSFT})>0
					SFT->(FieldPut (FieldPos (cCmpSFT), aColsSFT[nX][nI]))
				EndIf
			Next (nI)
			MsUnLock ()
			SFT->(FkCommit ())
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualizando a tabela SF3 de acordo com as informacoes digitadas na tabela SFTณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea ("SF3")
		SF3->(DbSetOrder (5))
		If SF3->(DbSeek (xFilial ("SF3")+cSerie+cNota+cCliefor+cLoja+aColsSFT[nX][nPosId]))
			RecLock ("SF3", .F.)
			For nI := 1 To Len (aHeadSFT)
				cCmpSFT	:=	AllTrim (aHeadSFT[nI][2])
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerifico se o campo em processamento para o aHeader foi digitado  (aCmpsAlt)ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If aScan (aAlterSFT, {|cCmp| cCmp==cCmpSFT})>0 .And. aScan (aCmpsAlt, {|cCmp| cCmp==cCmpSFT})>0
					nPos	:=	aScan (aDePara, {|aX| aX[2]==cCmpSFT})
					If nPos>0
						cCmpSF3	:=	aDePara[nPos][1]
					Else
						cCmpSF3	:=	"F3_"+SubStr (cCmpSFT, 4)
					EndIf
					
					If SF3->(FieldPos (cCmpSF3))>0
						If aScan (aIdZerou, aColsSFT[nX][nPosId]+cCmpSF3)==0
							aAdd (aIdZerou, aColsSFT[nX][nPosId]+cCmpSF3)
	
							If ValType (SF3->&(cCmpSF3))=="N"
								SF3->(FieldPut (FieldPos (cCmpSF3), 0))
							ElseIf ValType (SF3->&(cCmpSF3))=="D"
								SF3->(FieldPut (FieldPos (cCmpSF3), CToD ("  /  /  ")))
							Else
								SF3->(FieldPut (FieldPos (cCmpSF3), ""))
							EndIf
						EndIf
					
						If ValType (SF3->&(cCmpSF3))=="N"
							SF3->&(cCmpSF3)		+=	aColsSFT[nX][nI]
						Else
							SF3->(FieldPut (FieldPos (cCmpSF3), aColsSFT[nX][nI]))
						EndIf
					EndIf
				EndIf
			Next (nI)
			SF3->F3_REPROC	:=	Iif (cReproc=="1", "S", "N")
			MsUnLock ()
			SF3->(FkCommit ())
		EndIf
	Next (nX)
	End Transaction
EndIf
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaTrb   บAutor  ณGustavo G. Rueda    บ Data ณ  03/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de criacao do TRB, Header e acols para o temporario  บฑฑ
ฑฑบ          ณ que contera um resumo dos campos alterados. (LOG)          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaTrb (aArq, aHeadLOG, aColsLOG, oTempLog)
Local	aCmps		:=	{}
Local	nI			:=	0
Local	nUsadLOG	:=	0
Local	lProcessa	:=	.T.

Default oTempLog 	:= NIL

If Valtype(oTempLog) == "O"
	oTempLog:Delete()
	lProcessa	:=	.F.
EndIf

If lProcessa
	aHeadLOG	:=	{}

	aCmps:=   { {"LOG_ITEM"		,"C", 04,0},; 
	            {"LOG_CAMPO"    ,"C", 20,0},;
	            {"LOG_SEQ"  	,"C", 03,0},; 	
	            {"LOG_VLRANT"	,"C", 60,0},;
	            {"LOG_VLRATU"   ,"C", 60,0}}
	
	aAdd (aHeadLOG, {STR0010, 		"LOG_ITEM", 	"@!",	04, 	0, 	".T.", 	X3_USADO_EMUSO, 	"C", 	"", 	"R"})	//"Item"
	aAdd (aHeadLOG, {STR0011, 		"LOG_CAMPO", 	"@!",	20, 	0, 	".T.", 	X3_USADO_EMUSO, 	"C", 	"", 	"R"})	//"Campo"
	aAdd (aHeadLOG, {STR0012, 		"LOG_SEQ", 		"@!",	03, 	0, 	".T.", 	X3_USADO_EMUSO, 	"C", 	"", 	"R"})	//"Seq."
	aAdd (aHeadLOG, {STR0013,		"LOG_VLRANT", 	"@!", 	60, 	0, 	".T.", 	X3_USADO_EMUSO, 	"C", 	"", 	"R"})	//"Vlr Anterior"
	aAdd (aHeadLOG, {STR0014,		"LOG_VLRATU", 	"@!", 	60, 	0, 	".T.", 	X3_USADO_EMUSO, 	"C", 	"", 	"R"})	//"Vlr Atual"
	nUsadLOG	:=	Len (aHeadLOG)

	aAdd (aColsLOG, Array (nUsadLOG+1))
	For nI := 1 To nUsadLOG
		aColsLOG[Len (aColsLOG)][nI] := ""
	Next nI
	aColsLOG[Len(aColsLOG)][nUsadLOG+1] := .F.
	                      	
	oTempLog	:= FWTemporaryTable():New( "LOG" )
	oTempLog:SetFields( aCmps )
	oTempLog:AddIndex("01", {"LOG_ITEM","LOG_CAMPO","LOG_SEQ"} )
	oTempLog:Create()
	DbSelectArea("LOG")

EndIf
Return oTempLog
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFldRefr   บAutor  ณMicrosiga           บ Data ณ  03/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizacao do folder de resumo ao seleciona-lo.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FldRefr (nFldDst, nFldAtu, oFolder, aCodeBlock)
Local	aColsLOG	:=	aClone (oGDadLOG:aCols)
Local	aHeadLOG	:=	aClone (oGDadLOG:aHeader)
Local	nUsadLOG	:=	Len (aHeadLOG)

DEFAULT nFldDst := IIf(oFolder<>Nil,oFolder:nOption,1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza os objetos do folder de destino                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (nFldDst==2)
    If !LOG->(Eof())
		aColsLOG	:=	{}	
		LOG->(DbGoTop ())
		Do While !LOG->(Eof ())
			aAdd (aColsLOG, Array (nUsadLOG+1))
			aColsLOG[Len (aColsLOG)][1] := LOG->LOG_ITEM
			aColsLOG[Len (aColsLOG)][2] := LOG->LOG_CAMPO
			aColsLOG[Len (aColsLOG)][3] := LOG->LOG_SEQ
			aColsLOG[Len (aColsLOG)][4] := LOG->LOG_VLRANT
			aColsLOG[Len (aColsLOG)][5] := LOG->LOG_VLRATU
			aColsLOG[Len(aColsLOG)][nUsadLOG+1] := .F.
		
			LOG->(DbSkip ())
		EndDo
	Endif	
	oGDadLOG:SetArray (aColsLOG)
	oGDadLOG:Refresh()
EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuBas    บAutor  ณMicrosiga           บ Data ณ  03/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizacao da Data de Entrada (F3_ENTRADA/FT_ENTRADA) e CFOPบฑฑ
ฑฑบ          ณ (F3_CFO/FT_CFOP) na origem (NFE/NFS)                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuBas (cEntSai, cSerie, cNota, cCliefor, cLoja)

Local aArea := GetArea()
Local cSeek := cNota+cSerie+cCliefor+cLoja
     
Begin Transaction
If cEntSai=="S"
	DbSelectArea ("SD2")
	SD2->(DbSetOrder (3))
	If SD2->(DbSeek (xFilial ("SD2")+cSeek))
		Do While !SD2->(Eof ()) .And.;
			SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)==xFilial("SD2")+cSeek
		
			DbSelectArea ("SFT")
			SFT->(DbSetOrder (1))
			If (SFT->(DbSeek (xFilial ("SFT")+cEntSai+cSerie+cNota+cCliefor+cLoja+SD2->(PadR(D2_ITEM,TamSx3("FT_ITEM")[1])+D2_COD))))
				RecLock ("SD2", .F.)
				SD2->D2_CF := SFT->FT_CFOP
				MsUnlock()
				SD2->(FkCommit ())
			Endif
			
			SD2->(DbSkip ())
		Enddo
	Endif
Else
	DbSelectArea ("SF1")
	SF1->(DbSetOrder (1))
	If SF1->(DbSeek (xFilial ("SF1")+cSeek))

		DbSelectArea ("SFT")
		SFT->(DbSetOrder (1))
		If (SFT->(DbSeek (xFilial ("SFT")+cEntSai+cSerie+cNota+cCliefor+cLoja)))
			Do While !SF1->(Eof ()) .And.;
				SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)==xFilial("SF1")+cSeek
				
				RecLock("SF1",.F.)
				SF1->F1_DTDIGIT := SFT->FT_ENTRADA
				MsUnlock()
				SF1->(FkCommit ())
				
				SF1->(DbSkip ())
			EndDo
		EndIf
	Endif

	DbSelectArea ("SD1")
	SD1->(DbSetOrder (1))
	If SD1->(DbSeek (xFilial ("SD1")+cSeek))
		Do While !SD1->(Eof ()) .And.;
			SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)==xFilial("SD1")+cSeek
		
			DbSelectArea ("SFT")
			SFT->(DbSetOrder (1))
			If (SFT->(DbSeek (xFilial ("SFT")+cEntSai+cSerie+cNota+cCliefor+cLoja+SD1->(D1_ITEM+D1_COD))))
				RecLock ("SD1", .F.)
				SD1->D1_CF 		:=	SFT->FT_CFOP
				SD1->D1_DTDIGIT	:=	SFT->FT_ENTRADA
				MsUnlock()
				SD1->(FkCommit ())
			Endif
			
			SD1->(DbSkip ())
		Enddo
	Endif
Endif
End Transaction
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuTAFSt  บAutor  ณMicrosiga           บ Data ณ  18/07/22   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizacao de todos os S_T_A_M_P_ da chave na SFT,         บฑฑ
ฑฑบ          ณpara integrar a ultima foto do fiscal no sigataf            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function TAFStamp(aHeadSF3, cFil, cEntSai, cSerie, cNota, cCliefor, cLoja, cData)

Local aArea 	 := GetArea()
Local nPosEnt 	 := 0
Local nX 		 := 0
Local cDtAtu     := ''
Local cUpdate    := ''
Local aColsSF3 	 := {}

Default aHeadSF3 := {}
Default cFil	 := ''
Default cEntSai  := ''
Default cSerie 	 := ''
Default cNota 	 := ''
Default cCliefor := ''
Default cLoja	 := ''
Default cData	 := ''

if Ascan(TCStruct(RetSqlName("SFT")),{|x|x[1]=='S_T_A_M_P_'}) > 0 //Verifica se possui S_T_A_M_P_ na SFT para integrar no SIGATAF.

	aColsSF3 := aClone(oGDadSF3:aCols)

	//Tratamento para obter a ultima data informada na grid
	nPosEnt := ascan(aHeadSF3,{|x|x[2]=="F3_ENTRADA"})
	For nX := 1 To Len(aColsSF3)
		cDtAtu := DtoS(aColsSF3[nX][nPosEnt])
	next nX

	//Obtem o ultimo conteudo da data carregada no acerto, verificado que ateh o momento so atualiza com a data de acerto o primeiro item da SFT.
	//Caso ocorra tratamento para atualizar todos os itens da SFT com a data de acerto, o programa ja estara preparado para atualizar corretamente.
	if cDtAtu <> cData
		cData := cDtAtu
	endif

	//Atualiza com o mesmo conteudo apenas para realizar o trigger de banco no stamp para todos os itens chave posicionada.
	cUpdate := "UPDATE " + RetSqlName( "SFT" ) + " SET D_E_L_E_T_ = ' ' "
	cUpdate += "WHERE FT_FILIAL = '" + cFil + "' AND FT_TIPOMOV = '" + cEntSai + "' AND FT_SERIE = '" + cSerie + "' "
	cUpdate += "AND FT_NFISCAL = '" + cNota + "' AND FT_CLIEFOR = '" + cCliefor + "' AND FT_LOJA = '" + cLoja + "' "
	if cEntSai == 'S'
		cUpdate += "AND FT_EMISSAO = '" + cData + "' "
	else
		cUpdate += "AND FT_ENTRADA = '" + cData + "' "
	endif
	cUpdate += "AND D_E_L_E_T_ = ' ' "
	TcSqlExec( cUpdate )
endif

RestArea(aArea)

Return Nil
