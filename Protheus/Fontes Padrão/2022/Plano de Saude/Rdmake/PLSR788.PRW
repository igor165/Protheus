
#INCLUDE "Protheus.ch" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define _LF Chr(13)+Chr(10) // Quebra de linha.
#Define _BL 25
#Define __NTAM1  10
#Define __NTAM2  10
#Define __NTAM3  20
#Define __NTAM4  25
#Define __NTAM5  38
#Define __NTAM6  15
#Define __NTAM7  5
#Define __NTAM8  9
#Define __NTAM9  7
#Define __NTAM10 30
#Define __NTAM11 8
#Define Moeda "@E 999,999,999.99"

STATIC oFnt10C 		:= TFont():New("Arial",10,10,,.f., , , , .t., .f.)
STATIC oFnt10N 		:= TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt09C 		:= TFont():New("Arial",9,9,,.f., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("Arial",18,18,,.t., , , , .t., .f.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR788   ºAutor  ³Renan Martins   º Data ³  11/2015        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³Reembolso Analítico (B45)                                   º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLSR788(lWeb,aParWeb,cDirPath,cBenefLog)
LOCAL lCent 			:= __SetCentury() 
LOCAL lRet              := .f.
DEFAULT lWeb			:= .f.
DEFAULT aParWeb			:= {}
DEFAULT cDirPath		:= lower(getMV("MV_RELT"))
DEFAULT cBenefLog	  	:= ""
PRIVATE cTitulo 		:= "Relatório Analítico de Reembolso"
PRIVATE cPerg       	:= "PLR788P"
PRIVATE oReport     	:= nil
PRIVATE cFileName		:= "Reembolso_Analitico"+CriaTrab(NIL,.F.)
PRIVATE nTweb			:= 3
PRIVATE nLweb			:= 10
PRIVATE aRetWeb			:= {}
PRIVATE aRet 			:= {"",""}
PRIVATE nLeft			:= 40
PRIVATE nRight			:= 2500
PRIVATE nCol0  			:= nLeft
PRIVATE nTop			:= 130
PRIVATE nTopInt			:= nTop
PRIVATE nPag			:= 1


__SetCentury( "off" )   // habilita ano para 2 digitos
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Print
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !lWeb
	Pergunte(cPerg,.T.)
endIf

oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,nil,.f.,.f.,.t.)

oReport:lInJob  	:= lWeb
oReport:lServer 	:= lWeb
oReport:cPathPDF	:= cDirPath

oReport:setDevice(IMP_PDF)
oReport:setResolution(72)
oReport:SetLandscape()
oReport:SetPaperSize(9)
oReport:setMargin(07,07,07,07)

IF !lWeb
	oReport:Setup()  //Tela de configurações

	If oReport:nModalResult == 2 //Verifica se foi Cancelada a Impressão
		Return{"",""}
	EndIf
ENDIF

lRet := PLSR788Imp(oReport,lWeb,aParWeb,cBenefLog)

if lRet
	aRet := {cFileName+".pdf",""}
else
	aRet := {"",""}
endif

IF (lRet)
	oReport:EndPage()
	oReport:Print()
ENDIF	
//MS_FLUSH()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Checa se o arquivo PDF esta ponto para visualizacao na web 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if lWeb .And. lRet
	PLSCHKRP(cDirPath, cFileName+".pdf")
endIf

__SetCentury(If(lCent,"on","off")) // Retorna formato ano salvo anteriormente 2 ou 4 digitos

Return(aRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Função    ³PLSR788Imp³ Autor ³ Renan Martins          ³ Data ³ 11/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição: ³Relatório Analítico de reembolso - B45                     ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSR788Imp(oReport,lWeb,aParWeb,cBenefLog,aParW2,lGerPag)
LOCAL nValorTab		:= 0
LOCAL nValorApre	:= 0
LOCAL nValorPart	:= 0
LOCAL nValorGlo		:= 0
LOCAL nValorpago	:= 0
LOCAL nValorQtd		:= 0
LOCAL nTValorQtd	:= 0		
LOCAL nTValorTab	:= 0
LOCAL nTValorApre	:= 0
LOCAL nTValorPart	:= 0
LOCAL nTValorGlo	:= 0
LOCAL nTValorpago	:= 0
LOCAL nTot			:= 0
LOCAL nColAux		:= 0
LOCAL nQtd			:= 0
LOCAL cSQL			:= ""
LOCAL cCodRDA		:= ""
LOCAL cCodGlo   	:= ""
LOCAL cMsg			:= ""
LOCAL lTitulo		:= .f.
LOCAL lRet			:= .T.
Local cTipTit		:= AllTrim(GetNewPar("MV_PLCDTIT", "T"))
Private cCodDep		:= ""
Private cBenef		:= ""
DEFAULT cBeneflog	:= ""
DEFAULT aParW2	   	:= {}
DEFAULT lGerPag		:= .T.
	
If !lWeb
	cDtSolIni  	:= mv_par01
	cDtSolFin   := mv_par02
	cDtPagIni	:= mv_par03
	cDtPagFin	:= mv_par04
	cBenef		:= mv_par05
	cDepend		:= mv_par06
ELSE
	BA1->(DbSetOrder(1))
	BA1->(MsSeek(xFilial("BA1")+substr(cBenefLog,1,14)+cTipTit)) //Titular do plano
	cBenef 		:= BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)
	cDtSolIni  	:= IIF (!Empty(aParweb:DtDe), aParweb:DtDe, "")
	cDtSolFin   := IIF (!Empty(aParweb:DtAte), aParweb:DtAte, "")
	cDtPagIni	:= IIF (!Empty(aParweb:DtDeO), aParweb:DtDeO, "")
	cDtPagFin	:= IIF (!Empty(aParweb:DtAteO), aParweb:DtAteO, "")
	cDepend		:= IIF (!Empty(aParweb:Matric), aParweb:Matric, "")
	cCodDep 	:= IIF (!Empty(aParweb:Matric), aParweb:Matric, "")
ENDIF	

IF (Empty(cBenef) )
	If !lWeb
		MsgAlert("É necessário informar obrigatoriamente o Titular!")
	EndIf
   Return lRet:= .F.
END

cSql := pQry788(cDtSolIni, cDtSolFin, cDtPagIni, cDtPagFin, cBenef, cDepend)
PLSQuery(cSQL,"cArqTrab")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata se nao existir registros...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqTrab->(DbGoTop())

cArqTrab->(DBEval( { | | nQtd ++ }))

If !lWeb
	ProcRegua(nQtd)
Endif
cArqTrab->(DbGoTop())

nValorTab	:= 0
nValorApre	:= 0
nValorPart	:= 0
nValorGlo	:= 0
nValorpago	:= 0
nValorQtd	:= 0
nTValorQtd	:= 0		
nTValorTab	:= 0
nTValorApre	:= 0
nTValorPart	:= 0
nTValorGlo	:= 0
nTValorpago	:= 0	
nLi		  	:= 1
lFirst 		:= .T.

If lGerPag
	oReport:StartPage()
Endif

If !cArqTrab->(Eof())

	While !cArqTrab->(Eof())
     	nTot++
        If !lFirst
			oReport:EndPage()
			oReport:StartPage()
        Endif
        lFirst := .F.


		cCodDep := cArqTrab->(B45_MATRIC)
		cCodRDA := cArqTrab->(B45_CODREF)
		BA1->(DbSetOrder(2))
		BA1->(MsSeek(xFilial("BA1")+cCodDep))
		BK6->(DbSetOrder(4))
		BK6->(MsSeek(xFilial("BK6")+cCodRDA))
		Cab974PGR(oReport,lWeb)

		lTitulo  := .T.
		nValorQtd	:= 0		
		nValorTab	:= 0
		nValorApre	:= 0
		nValorPart	:= 0
		nValorGlo	:= 0
		nValorpago	:= 0		
		IF (!Empty(cDepend))
		   cCondicao := "!cArqTrab->(Eof()) .And.cArqTrab->(B45_CODREF) == '" + cCodRDA + "' .AND. cArqTrab->(B45_MATRIC) == '"+ cCodDep + "'"
		ELSE
		   cCondicao := "!cArqTrab->(Eof())  .And. cArqTrab->(B45_CODREF) == '" +cCodRDA + "'"
		ENDIF   
		
		 While &(cCondicao)
			If nLi > 35
				nLi := 1
				oReport:EndPage()
				oReport:StartPage()
				Cab974PGR(oReport,lWeb)
			EndIf
			nTop += 10
			
			nTValorQtd	:= nTValorQtd  + cArqTrab->(B45_QTDPRO)		
			nTValorTab	:= nTValorTab  + cArqTrab->(B45_VLRBPR)
			nTValorApre	:= nTValorApre + cArqTrab->(B45_VLRAPR)
			nTValorPart	:= nTValorPart + cArqTrab->(B45_VLRTPF)
			nTValorGlo	:= nTValorGlo  + cArqTrab->(B45_VLRGLO)
			nTValorpago	:= nTValorpago + cArqTrab->(B45_VLRPAG)		

			nTop += _BL

			//Data Proc. 	Tipo Guia	Num Guia	Matricula 				Nome do Beneficiario   				Procedimento	QTD. 	CID		Negado	Motivo
			nColAux := (nLeft/nTweb)
			oReport:Say(nTop/nTweb, nColAux, dtoc((cArqTrab->(BOW_DTDIGI))), oFnt10c)

			nColAux += __NTAM1*4.3
			oReport:Say(nTop/nTweb, nColAux, SUBSTR(Posicione("BR8",1,xFilial("BR8")+AllTrim( cArqTrab->(B45_CODPAD)+ cArqTrab->(B45_CODPRO) ),"BR8_DESCRI"),1,90), oFnt10c)

			nColAux += __NTAM2*36
			oReport:Say(nTop/nTweb, nColAux, cArqTrab->(B45_DENREG), oFnt10c)

			nColAux += __NTAM3*1.7
			oReport:Say(nTop/nTweb, nColAux, AllTrim(str(cArqTrab->(B45_QTDPRO))), oFnt10c)

			nColAux += __NTAM4*1.2  //
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform(cArqTrab->(B45_VLRBPR), Moeda))), oFnt10c)

			nColAux += __NTAM5*1.3 //
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform(cArqTrab->(B45_VLRAPR), Moeda))), oFnt10c)

			nColAux += __NTAM6*3.3 //
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform(cArqTrab->(B45_VLRTPF), Moeda))), oFnt10c)

			nColAux += __NTAM7*9.7
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform(cArqTrab->(B45_VLRPAG), Moeda))), oFnt10c)

			nColAux += __NTAM8*5.6
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform(cArqTrab->(B45_VLRGLO), Moeda))), oFnt10c)

			nLi++

			//TOTALIZADORES 
			nValorQtd	:= nValorQtd  + cArqTrab->(B45_QTDPRO)		
			nValorTab	:= nValorTab  + cArqTrab->(B45_VLRBPR)
			nValorApre	:= nValorApre + cArqTrab->(B45_VLRAPR)
			nValorPart	:= nValorPart + cArqTrab->(B45_VLRTPF)
			nValorGlo	:= nValorGlo  + cArqTrab->(B45_VLRGLO)
			nValorpago	:= nValorpago + cArqTrab->(B45_VLRPAG)		
			
			cArqTrab->(dbSkip())
		EndDo
		nTop += _BL
		oReport:Line(nTop/nTweb, nLeft/nTweb, nTop/nTweb, nRight/nTweb)
		If nLi > 35
			nLi := 1
			oReport:EndPage()
			oReport:StartPage()
			Cab974PGR(oReport,lWeb)
		EndIf


		nColAux1 := ((nCol0/nTweb) + (__NTAM1*4.3) + (__NTAM2*36))

		nTop += _BL
		cMsg := "Total: "
		oReport:Say(nTop/nTweb, nLeft/nTweb, cMsg, oFnt10c)
		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM3*1.7))  , Alltrim(str(nValorQtd)), oFnt10c)

		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM4*1.2))  , allTrim(Transform(nValorTab ,Moeda))+Space(1), oFnt10c)
		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM5*1.3))  , allTrim(Transform(nValorApre ,Moeda))+Space(1), oFnt10c)
		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM6*3.3))  , allTrim(Transform(nValorPart ,Moeda))+Space(1), oFnt10c)
		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM7*9.7))  , allTrim(Transform(nValorpago ,Moeda))+Space(1), oFnt10c)
		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM8*5.6))  , allTrim(Transform(nValorGlo ,Moeda))+Space(1), oFnt10c)
		
		nLi++
	    nTop += _BL
		nLi++
	
	EndDo
	If nTot > 1

		If nLi > 35
			oReport:EndPage()
			oReport:StartPage()
			Cab974PGR(oReport,lWeb)
		EndIf

		nColAux1 := ((nCol0/nTweb) + (__NTAM1*4.3) + (__NTAM2*36))

		nTop += _BL
		cMsg := "Total Geral: "
		oReport:Say(nTop/nTweb, nLeft/nTweb, cMsg, oFnt10c)
		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM3*1.7))  , Alltrim(str(nTValorQtd)), oFnt10c)

		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM4*1.2))  , allTrim(Transform(nTValorTab ,Moeda))+Space(1), oFnt10c)
		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM5*1.3))  , allTrim(Transform(nTValorApre ,Moeda))+Space(1), oFnt10c)
		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM6*3.3))  , allTrim(Transform(nTValorPart ,Moeda))+Space(1), oFnt10c)
		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM7*9.7))  , allTrim(Transform(nTValorpago ,Moeda))+Space(1), oFnt10c)
		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM8*5.6))  , allTrim(Transform(nTValorGlo ,Moeda))+Space(1), oFnt10c)
		
	Endif
Else
	If !lWeb
         MsgStop("Nenhum dado encontrado para os parametros informados.")
     Endif
     lRet := .F.
Endif

cArqTrab->(DbCloseArea())

Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³pQry788³ Autor ³Renan Martins     ³ Data ³ 11/20105         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³Query para pegar valores reembolso                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function pQry788(cDtSolIni, cDtSolFin, cDtPagIni, cDtPagFin, cBenef, cDepend)
LOCAL cSQL 			:= ""
 
cSql += " SELECT B44_OPEMOV, B44_CODEMP, B44_MATRIC, B44_TIPREG, B44_DIGITO, B44_NOMUSR, B44_DATPAG, B45_MATRIC, B45_CODPAD,"
cSql += " B45_CODPRO,  B45_DENREG, B45_QTDPRO, B45_VLRBPR, B45_VLRAPR, B45_VLRTPF, B45_VLRPAG, B45_VLRGLO, BOW_DTDIGI, B45_CODREF"

cSql += " FROM " + RetSQLName("B45") +  " INNER JOIN "
cSql +=  RetSQLName("B44") + " ON "
cSql +=" B45_FILIAL = B44_FILIAL "
cSql += " AND B45_OPEMOV = B44_OPEMOV "
cSql += " AND B45_ANOAUT = B44_ANOAUT "
cSql += " AND B45_MESAUT = B44_MESAUT "
cSql += " AND B45_NUMAUT = B44_NUMAUT "
cSql += " INNER JOIN "
cSql +=  RetSQLName("BOW") + " ON "
cSql +=" B44_FILIAL = BOW_FILIAL AND B44_PROTOC = BOW_PROTOC"
cSql += " WHERE "
cSql += RetSqlName("B45")+".D_E_L_E_T_ = '' "
cSql += " AND "+RetSqlName("B44")+".D_E_L_E_T_ = '' "
cSql += " AND "+RetSqlName("BOW")+".D_E_L_E_T_ = '' "
cSql += " AND "+RetSqlName("B45")+".B45_FILIAL = '" + xFilial("B45") + "' "
IIF (!Empty(cDtPagIni), cSql += " AND B44_DATRMB >= '" + DTOS(cDtPagIni) + "'", "") 
IIF (!Empty(cDtPagFin), cSql += " AND B44_DATRMB <= '" + DTOS(cDtPagFin) + "'", "")
IIF (!Empty(cDtSolIni), cSql += " AND BOW_DTDIGI >= '" + DTOS(cDtSolIni) + "'", "")
IIF (!Empty(cDtSolFin), cSql += " AND BOW_DTDIGI <= '" + DTOS(cDtSolFin) + "'", "")
cSql += " AND B44_OPEMOV = '" + left(cBenef,4) + "' AND B44_CODEMP = '" + substr(cbenef,5,4) + "' AND B44_MATRIC ='" + substr(cBenef,9,6) + "' "
IIF (!Empty(cDepend),   cSql += " AND B45_MATRIC = '" + Alltrim(cDepend) + "'", " AND B44_TIPREG = '" + substr(cBenef,15,2) + "' AND B44_DIGITO ='" + substr(cBenef,17,1) + "'")

return cSql



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Cab974PGR³ Autor ³Renan Martins     ³ Data ³ 11/20105       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³Criar cabeçalho                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Cab974PGR(oReport,lWeb)

oReport:EndPage() //Salta para proxima pagina

nTop		:= 15
nTopInt	:= nTop
nLeft		:= 40

nTop	+= _BL
nTopAux := nTop

aBMP	:= {"lgesqrl.bmp"}

If File("lgesqrl" + FWGrpCompany() + FWCodFil() + ".bmp")
	aBMP := { "lgesqrl" + FWGrpCompany() + FWCodFil() + ".bmp" }
ElseIf File("lgesqrl" + FWGrpCompany() + ".bmp")
	aBMP := { "lgesqrl" + FWGrpCompany() + ".bmp" }
EndIf

oReport:SayBitmap(nTop/nTweb, nLeft/nTweb, aBMP[1], 100, 100)
		
cMsg := cTitulo
nTop += 250
oReport:Say(((nTop)/nTweb)+nLweb, (nLeft + 1000)/nTweb, cMsg, oFnt14N)
cMsg := "Data: "+dToc(dDataBase)
nTop += 35
oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
cMsg := "Hora: "+time()
nTop += 35

If !Empty(cDtPagIni) .AND. !Empty(cDtPagFin)
	oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
	cMsg := "Data do Crédito: "+dtoc(cDtPagIni)+" a "+dtoc(cDtPagFin)+""
Endif
nTop += 35

If !lWeb
oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
cMsg := "Titular do Plano: "+ Posicione("BA1",2,xFilial("BA1")+ mv_par05,"BA1_NOMUSR")
nTop += 35

oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)

nTop += 35

oReport:Line(((nTop)/nTweb)+nLweb, nLeft/nTweb, (nTop/nTweb)+nLweb, nRight/nTweb)

cMsg := "Dependente: "+ Posicione("BA1",2,xFilial("BA1")+ cCodDep,"BA1_NOMUSR")
nTop += 35

ELSE
oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
cMsg := "Titular do Plano: "+ Posicione("BA1",2,xFilial("BA1")+cBenef ,"BA1_NOMUSR")
nTop += 35

oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)

nTop += 35

oReport:Line(((nTop)/nTweb)+nLweb, nLeft/nTweb, (nTop/nTweb)+nLweb, nRight/nTweb)

cMsg := "Dependente: "+ Posicione("BA1",2,xFilial("BA1")+ cCodDep,"BA1_NOMUSR")
nTop += 35
ENDIF

oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
cMsg := "Prestador: "+BK6->BK6_CGC+" - "+BK6->BK6_NOME+""
nTop += 35

oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
cMsg := "Pagina: "+alltrim(str(nPag))+""
nTop += 35
oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
nTop += _BL
oReport:Line(((nTop)/nTweb)+nLweb, nLeft/nTweb, (nTop/nTweb)+nLweb, nRight/nTweb)
nTop += _BL
nPag++


nTop += 40

nColAux := (nCol0/nTweb)
oReport:Say(nTop/nTweb, nColAux, "Data Solic.", oFnt10c)

nColAux += __NTAM1*15
oReport:Say(nTop/nTweb, nColAux, "Serviço", oFnt10c)

nColAux += ((__NTAM2*25))
oReport:Say(nTop/nTweb, nColAux, "Dente", oFnt10c)

nColAux += __NTAM3*1.6
oReport:Say(nTop/nTweb, nColAux, "Quant.", oFnt10c)

nColAux += __NTAM4*1.3
oReport:Say(nTop/nTweb, nColAux, "Valor de", oFnt10c)
nTop += 35
oReport:Say(nTop/nTweb, nColAux, " Tabela ", oFnt10c)
nTop -= 35

nColAux += __NTAM5*1.3
oReport:Say(nTop/nTweb, nColAux, "Valor ", oFnt10c)
nTop += 35
oReport:Say(nTop/nTweb, nColAux, "Apresent", oFnt10c)
nTop -= 35

nColAux += __NTAM6*3.3
oReport:Say(nTop/nTweb, nColAux, "Valor ", oFnt10c)
nTop += 35
oReport:Say(nTop/nTweb, nColAux, "Particip.", oFnt10c)
nTop -= 35

nColAux += __NTAM7*9.8
oReport:Say(nTop/nTweb, nColAux, "Valor ", oFnt10c)
nTop += 35
oReport:Say(nTop/nTweb, nColAux, "Reembolsado", oFnt09c)
nTop -= 35

nColAux += __NTAM8*5.8
oReport:Say(nTop/nTweb, nColAux, "Valor ", oFnt10c)
nTop += 35
oReport:Say(nTop/nTweb, nColAux, "Não Reembol.", oFnt10c)
nTop -= 35

nTop += _BL
nTop += 43
oReport:Line((nTop/nTweb)-nLweb, nLeft/nTweb, (nTop/nTweb)-nLweb, nRight/nTweb)

Return