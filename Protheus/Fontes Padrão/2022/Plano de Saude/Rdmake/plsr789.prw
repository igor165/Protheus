
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
STATIC oFnt11N 		:= TFont():New("Arial",11,11,,.T., , , , .t., .f.)
STATIC oFnt09C 		:= TFont():New("Arial",9,9,,.f., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("Arial",18,18,,.t., , , , .t., .f.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍ ÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR789   ºAutor  ³Renan Martins   º Data ³  11/2015        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Extrato de utilização                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLSR789(lWeb,aParWeb,cDirPath,cBenefLog)
LOCAL lCent 			:= __SetCentury() // Salva formato ano/data 2 ou 4 digitos
LOCAL lMaisSeisMes	:=.F. 
DEFAULT lWeb			:= .f.
DEFAULT aParWeb			:= {}
DEFAULT cDirPath		:= lower(getMV("MV_RELT"))
DEFAULT cBenefLog	  	:= ""
PRIVATE cTitulo 		:= "Extrato de Utilização dos Beneficiários"
PRIVATE cPerg       	:= "PLR789P"
PRIVATE oReport     	:= nil
PRIVATE cFileName		:= "Extrato_utilizacao"+CriaTrab(NIL,.F.)
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

If lWeb
	IF (!Empty(aParweb:DtDe) .and. !Empty(aParweb:DtAte))
		If Round((aParweb:DtAte - aParweb:DtDe)/30,0) > 6
			//Art. 10. A disponibilização do componente Utilização dos Serviços do PIN-SS terá periodicidade semestral e se dará até o último dia útil do mês de agosto,
			// para as informações referentes ao primeiro semestre, e até o último dia útil do mês de fevereiro, para as informações referentes ao segundo semestre. 
			lMaisSeisMes:=.T.
		Endif
	Endif 
EndIf

If !lMaisSeisMes

	lRet := PLSR789Imp(oReport,lWeb,aParWeb,cBenefLog)
	
	if lRet
		aRet := {cFileName+".pdf",""}
	else
		aRet := {"",""}
	endif
Else
	lRet:=.F.
	aRet := {"","Conforme Art. 10. A disponibilização do componente Utilização dos Serviços do PIN-SS é de periodicidade semestral. Periodo digitado ultrapassa sei meses "}
Endif

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
±±³ Função    ³PLSR789Imp³ Autor ³ Renan Martins          ³ Data ³ 11/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição: ³Extrato de utilização - BD6 e BM1                          ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSR789Imp(oReport,lWeb,aParWeb,cBenefLog,aParW2,lGerPag)
LOCAL nTipo			:= 0
LOCAL nTotRda		:= 0
LOCAL nTotGeral		:= 0
LOCAL nTot			:= 0
LOCAL nTotInt		:= 0
LOCAL nColAux		:= 0
LOCAL nQtd			:= 0
LOCAL cSQL			:= ""
LOCAL cMsg			:= ""
LOCAL lTitulo		:= .f.
LOCAL lConsult  	:= .F.
LOCAL lRet			:= .T.
Local cRDA			:= ""
Local cTipTit		:= AllTrim(GetNewPar("MV_PLCDTIT", "T"))
Private cCodDep		:= ""
Private cBenef		:= ""
Private cCodRda		:= ""
DEFAULT aParW2	   	:= {}
DEFAULT lGerPag		:= .T.
	
If !lWeb
	cDtDescIni	:= mv_par01
	cDtDescFin	:= mv_par02
	cRda		:= mv_par03
	cBenef		:= mv_par04
	cDepend		:= mv_par05
	cDtProIni  	:= mv_par06
	cDtProFin   := mv_par07
ELSE
	BA1->(DbSetOrder(1))
	BA1->(MsSeek(xFilial("BA1")+substr(cBenefLog,1,14)+cTipTit)) //Titular do plano
	cBenef 		:= BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)
	cDtProIni  	:= IIF (!Empty(aParweb:DtDe)  , aParweb:DtDe, "")
	cDtProFin   := IIF (!Empty(aParweb:DtAte) , aParweb:DtAte, "")
	cDtDescIni	:= IIF (!Empty(aParweb:Mes)   , StrTran(aParweb:Mes,"/",""), "")
	cDtDescFin	:= IIF (!Empty(aParweb:Ano)   , StrTran(aParweb:Ano,"/",""), "")
	cDepend		:= IIF (!Empty(aParweb:Matric), aParweb:Matric, "")
	cCodDep 	:= IIF (!Empty(aParweb:Matric), aParweb:Matric, "")
ENDIF	

IF (Empty(cBenef) .OR. Empty(cDtDescIni) .OR. Empty(cDtDescFin) ) 
	If !lWeb
		MsgAlert("É necessário informar obrigatoriamente o Titular e Período de Desconto")
	ENDIF
	Return lRet:= .F.
END

cSql := pQry789R(cDtProIni, cDtProFin, cDtDescIni, cDtDescFin, cBenef, cDepend, cRda)
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

nTotGeral 	:= 0 
nValorPago	:= 0
nValorPrt	:= 0
nValorQtd	:= 0
nTValorQtd	:= 0		
nTValorPrt	:= 0
nTValorpago	:= 0
//Internação
nTotInt		:= 0
nTTotInt	:= 0
nTQtdInt	:= 0
nQtdInt		:= 0
nIntPago	:= 0
nTIntPago	:= 0

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


		cCodDep := cArqTrab->(BD6_OPEUSR + BD6_CODEMP + BD6_MATRIC + BD6_TIPREG + BD6_DIGITO)
		cCodRDA := cArqTrab->(BD6_CODRDA)
		Cab789PGR (oReport,lWeb)

		//Zerar as variáveis parciais de somatória
		lTitulo  	:= .T.
		nValorQtd	:= 0		
		nValorPago	:= 0
		nValorPrt	:= 0
		nValorGlo	:= 0	
		nTotInt		:= 0
		nTotInt  	:= 0
		nQtdInt  	:= 0
		nIntPago	:= 0
		nLi			:= 1
		 
		IF (!Empty(cDepend)) //Localizar o dependente escolhido, quebrando por RDA 
			cCondicao := "!cArqTrab->(Eof()) .AND. cArqTrab->(BD6_CODRDA) == '" + cCodRDA + "' ";
					
		ELSEIF (Empty(cDepend)) //Localizar todos os atendimentos da família, baseado no titular, quebrando por RDA e Dependentes da família
			cCondicao := "!cArqTrab->(Eof()) .And. cArqTrab->(BD6_CODRDA) == '" + cCodRDA + "' "
			cCondicao += ".AND. cArqTrab->(BD6_OPEUSR + BD6_CODEMP + BD6_MATRIC + BD6_TIPREG + BD6_DIGITO) == '" + cCodDep + "'"
		ENDIF	
		
		 While &(cCondicao)
			If nLi > 25
				nLi := 1
				oReport:EndPage()
				oReport:StartPage()
				Cab789PGR (oReport,lWeb)
			EndIf
			nTop += 10
			
			nTValorQtd	:= nTValorQtd  + cArqTrab->(BD6_QTDPRO)		
			nTValorPrt	:= nTValorPrt  + cArqTrab->(BD6_VLRTPF)
			nTValorpago	:= nTValorpago + cArqTrab->(BD6_VLRPAG) 
			IF (cArqTrab->(BD6_TIPGUI) $ "3,03")
				nTTotInt  := nTTotInt  + cArqTrab->(BD6_VLRTPF)
				nTQtdInt  := nTQtdInt  + cArqTrab->(BD6_QTDPRO)
				nTIntPago := nTIntPago + cArqTrab->(BD6_VLRPAG)
			ENDIF	
			
			nTop += _BL

			//Data Proc. 	Tipo Guia	Num Guia	Matricula 				Nome do Beneficiario   				Procedimento	QTD. 	CID		Negado	Motivo
			nColAux := (nLeft/nTweb)
			oReport:Say(nTop/nTweb, nColAux, dtoc((cArqTrab->(BD6_DATPRO))), oFnt10c)

			nColAux += __NTAM1*4.3
			oReport:Say(nTop/nTweb, nColAux, cArqTrab->(BD6_DESPRO), oFnt10c)

			nColAux += __NTAM2*36
			oReport:Say(nTop/nTweb, nColAux, cArqTrab->(BD6_DENREG), oFnt10c)

			nColAux += __NTAM3*1.7
			oReport:Say(nTop/nTweb, nColAux, AllTrim(str(cArqTrab->(BD6_QTDPRO))), oFnt10c)

			nColAux += __NTAM4*1.3  //+0.2
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform(cArqTrab->(BD6_VLRPAG), Moeda))), oFnt10c)

			nColAux += __NTAM5*1.3 //
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform(cArqTrab->(BD6_VLRTPF), Moeda))), oFnt10c)
			
			nColAux += __NTAM6*3.6 //percentual co-participação
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform(cArqTrab->(BD6_PERCOP), Moeda))), oFnt10c)

			nColAux += __NTAM7*10//percentual taxa de administração
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform(cArqTrab->(BD6_PERTAD), Moeda))), oFnt10c)
			
			nLi++

			//TOTALIZADORES 
			nValorQtd	:= nValorQtd  + cArqTrab->(BD6_QTDPRO)		
			nValorPago	:= nValorPago + cArqTrab->(BD6_VLRPAG)
			nValorPrt	:= nValorPrt  + cArqTrab->(BD6_VLRTPF)
			IF (cArqTrab->(BD6_TIPGUI) $ "3, 03")
			   nTotInt  := nTotInt  + cArqTrab->(BD6_VLRTPF)
			   nQtdInt  := nQtdInt  + cArqTrab->(BD6_QTDPRO)
			   nIntPago := nIntPago + cArqTrab->(BD6_VLRPAG)
			ENDIF
			
			cArqTrab->(dbSkip())
		EndDo
		nTop += _BL
		oReport:Line(nTop/nTweb, nLeft/nTweb, nTop/nTweb, nRight/nTweb)
		If nLi > 25
			nLi := 1
			oReport:EndPage()
			oReport:StartPage()
			Cab789PGR (oReport,lWeb)
		EndIf


		nColAux1 := ((nCol0/nTweb) + (__NTAM1*4.3) + (__NTAM2*36))

		//Linha do Credenciado
		nTop += _BL
		cMsg := "Total : "
		oReport:Say(nTop/nTweb, nLeft/nTweb, cMsg, oFnt10c)		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM3*1.7))  , Alltrim(str(nValorQtd)), oFnt10c)
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM4*1.3))  , allTrim(Transform(nValorPago ,Moeda))+Space(1), oFnt10c)	
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM5*1.3))  , allTrim(Transform(nValorPrt ,Moeda))+Space(1), oFnt10c)
		
		nLi++
	    nTop += _BL
		nLi++
	
		//Linha da Internação
		nColAux1 := ((nCol0/nTweb) + (__NTAM1*4.3) + (__NTAM2*36))
		nTop += _BL
		cMsg := "Total da Franquia (Internação): "
		oReport:Say(nTop/nTweb, nLeft/nTweb, cMsg, oFnt10c)		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM3*1.7))  , Alltrim(str(nTQtdInt)), oFnt10c)
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM4*1.3))  , allTrim(Transform(nIntPago ,Moeda))+Space(1), oFnt10c)	
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM5*1.3))  , allTrim(Transform(nTTotInt ,Moeda))+Space(1), oFnt10c)
		
		nLi++
	    nTop += _BL
		nLi++
	
	
	EndDo
	If nTot > 1

		If nLi > 25
			oReport:EndPage()
			oReport:StartPage()
			Cab789PGR (oReport,lWeb)
		EndIf
		
		nTop += (_BL * 4)
		oReport:Line(((nTop)/nTweb)+nLweb, nLeft/nTweb, (nTop/nTweb)+nLweb, nRight/nTweb)	
		
		nColAux1 := ((nCol0/nTweb) + (__NTAM1*4.3) + (__NTAM2*36))
		nTop += (_BL * 3)
		cMsg := "Total Geral: "
		oReport:Say(nTop/nTweb, nLeft/nTweb, cMsg, oFnt11N)		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM3*1.7))  , Alltrim(str(nTValorQtd)), oFnt10c)
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM4*1.3))  , allTrim(Transform(nTValorpago ,Moeda))+Space(1), oFnt10c)	
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM5*1.3))  , allTrim(Transform(nTValorPrt ,Moeda))+Space(1), oFnt10c)
		

		//Linha da Internação
		  nLi++
	      nTop += _BL + _BL
		  nLi++
		nColAux1 := ((nCol0/nTweb) + (__NTAM1*4.3) + (__NTAM2*36))
		nTop += _BL
		cMsg := "Total Geral da Franquia (Internação): "
		oReport:Say(nTop/nTweb, nLeft/nTweb, cMsg, oFnt11N)		
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM3*1.7))  , Alltrim(str(nTQtdInt)), oFnt10c)
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM4*1.3))  , allTrim(Transform(nTIntPago ,Moeda))+Space(1), oFnt10c)	
		oReport:Say(nTop/nTweb, (nColAux1 := nColAux1 + (__NTAM5*1.3))  , allTrim(Transform(nTTotInt  ,Moeda))+Space(1), oFnt10c)
		
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
±±³ Função    ³pQry789R³ Autor ³Renan Martins.     ³ Data ³ 11/20105        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³Query para pegar valores de utilização e co-participação    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function pQry789R(cDtProIni, cDtProFin, cDtDescIni, cDtDescFin, cBenef, cDepend, cRDA)
LOCAL cSQL 	:= ""
LOCAL cAnoI	:= IIF (!Empty(cDtDescIni), right(cDtDescIni,4), "")
LOCAL cAnoF	:= IIF (!Empty(cDtDescFin), right(cDtDescFin,4), "")	
LOCAL cMesI	:= IIF (!Empty(cDtDescIni), left(cDtDescIni,2) , "")
LOCAL cMesF	:= IIF (!Empty(cDtDescFin), left(cDtDescFin,2) , "")	
 
cSQL := " SELECT DISTINCT BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_DIGITO, BD6_DENREG, BD6_DESPRO, BD6_QTDPRO, "
cSQL += " BD6_NOMUSR, BD6_VLRTPF, BD6_VLRPAG, BD6_CODRDA, BD6_DATPRO, BD6_PERCOP, BD6_PERTAD, BD6_TIPGUI, BDC_ANOINI, BDC_MESINI, BDC_ANOFIM, BDC_MESFIM, "
cSQL += " BD6_DESPRO "                                      
cSQL += " FROM " + RetSQLName("BD6") 
cSQL += " INNER JOIN " + RetSQLName("BDC") 
cSQL += " ON BDC_FILIAL = '"+xFilial("BDC")+"' AND "
cSQL += " BD6_NUMFAT = BDC_CODOPE || BDC_NUMERO AND "
cSQL += RetSQLName("BDC") + ".D_E_L_E_T_ <> '*'" 
cSQL += " WHERE BD6_FILIAL  = '"+xFilial("BD6")+"' AND "

IF (Empty(cDepend))
	cSQL += " BD6_OPEUSR = '" + left(cBenef,4) + "' AND BD6_CODEMP = '" + substr(cBenef,5,4) + "' AND BD6_MATRIC = '" + substr(cBenef,9,6) + "' AND "
ELSE
	cSQL += " BD6_OPEUSR = '" + left(cDepend,4) + "' AND BD6_CODEMP = '" + substr(cDepend,5,4) + "' AND BD6_MATRIC = '" + substr(cDepend,9,6) + "' "
	cSQL += " AND BD6_TIPREG = '" + substr(cDepend,15,2) + "' AND BD6_DIGITO = '" + substr(cDepend,17,1) + "' AND "  
ENDIF

IIF (!Empty(cRDA), cSQL +=  "BD6_CODRDA = '" + cRDA + "' AND ", "")
IIF(!Empty(cAnoI) .And. !Empty(cMesI), cSQL += " BDC_ANOINI || BDC_MESINI >= '"+ cAnoI + cMesI + "' AND ", "")  
IIF(!Empty(cAnoF) .And. !Empty(cMesF), cSQL += " BDC_ANOFIM || BDC_MESFIM <= '"+ cAnoF + cMesF + "' AND ", "") 
cSQL += RetSQLName("BD6") + ".D_E_L_E_T_ <> '*'" 
 	
cSQL += " ORDER BY BD6_CODRDA, BD6_TIPREG, BD6_DIGITO, BD6_DATPRO"   

return cSql


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Função   ³Cab789PGR ³ Autor ³Renan Martins     ³ Data ³ 11/20105       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³Criar cabeçalho                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Cab789PGR (oReport,lWeb)

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

If !Empty(cDtDescIni) .AND. !Empty(cDtDescFin)
	oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
	cMsg := "Período de Desconto: "+ Transform(cDtDescIni, "@R 99/9999")+" a "+ Transform(cDtDescFin, "@R 99/9999")
Endif
nTop += 35

oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
cMsg := "Titular do Plano: "+ Posicione("BA1",2,xFilial("BA1")+ cBenef,"BA1_NOMUSR")
nTop += 35

oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)

nTop += 35

oReport:Line(((nTop)/nTweb)+nLweb, nLeft/nTweb, (nTop/nTweb)+nLweb, nRight/nTweb)

cMsg := "Dependente: "+ Posicione("BA1",2,xFilial("BA1")+ cCodDep,"BA1_NOMUSR")
nTop += 35

oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
cMsg := "Prestador: "+Posicione("BAU",1,xFilial("BAU")+ cCodRDA,"BAU_NOME")
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
oReport:Say(nTop/nTweb, nColAux, "Data Atend.", oFnt10c)

nColAux += __NTAM1*15
oReport:Say(nTop/nTweb, nColAux, "Serviço", oFnt10c)

nColAux += ((__NTAM2*25))
oReport:Say(nTop/nTweb, nColAux, "Dente", oFnt10c)

nColAux += __NTAM3*1.6
oReport:Say(nTop/nTweb, nColAux, "Quant.", oFnt10c)

nColAux += __NTAM4*1.5
oReport:Say(nTop/nTweb, nColAux, "Valor ", oFnt10c)
nTop += 35
oReport:Say(nTop/nTweb, nColAux, " Pago ", oFnt10c)
nTop -= 35

nColAux += __NTAM5*1.3
oReport:Say(nTop/nTweb, nColAux, "Valor ", oFnt10c)
nTop += 35
oReport:Say(nTop/nTweb, nColAux, "Particip.", oFnt10c)
nTop -= 35

nColAux += __NTAM6*3.4
oReport:Say(nTop/nTweb, nColAux, "% Co-Parti- ", oFnt10c)
nTop += 35
oReport:Say(nTop/nTweb, nColAux, "pação", oFnt10c)
nTop -= 35

nColAux += __NTAM7*10
oReport:Say(nTop/nTweb, nColAux, "% Taxa de ", oFnt10c)
nTop += 35
oReport:Say(nTop/nTweb, nColAux, "Administ.", oFnt09c)
nTop -= 35

nTop += _BL
nTop += 43
oReport:Line((nTop/nTweb)-nLweb, nLeft/nTweb, (nTop/nTweb)-nLweb, nRight/nTweb)

Return