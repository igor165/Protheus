#INCLUDE "Protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define _LF Chr(13)+Chr(10) // Quebra de linha.
#Define _BL 25
#Define Moeda "@E 999,999,999.99"
#Define IMP_OK 1

STATIC oFnt10C 		:= TFont():New("Arial",10,10,,.f., , , , .t., .f.)
STATIC oFnt10N 		:= TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt09C 		:= TFont():New("Arial",9,9,,.f., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("Arial",18,18,,.t., , , , .t., .f.)
STATIC nDivEsp		:= NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR001   ºAutor  ³Thiago Guilherme   º Data ³  11/2015        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Reembolso Analítico (B45)                                   º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLSR001(lWeb,aDadosWeb,cDirPath)

LOCAL lPerg				:= .F.

DEFAULT lWeb			:= .f.
DEFAULT aDadosWeb			:= {}
DEFAULT cDirPath		:= lower(getMV("MV_RELT"))

PRIVATE cTitulo 		:= "Extrato Financeiro"
PRIVATE cPerg       	:= "PLSEXTFIN"
PRIVATE oReport     	:= nil
PRIVATE cFileName		:= "ExtFinanc"+CriaTrab(NIL,.F.)
PRIVATE nTweb			:= 3
PRIVATE nLweb			:= 10
PRIVATE aRetWeb			:= {}
PRIVATE aRet 			:= {"",""}
PRIVATE nLeft			:= 70
PRIVATE nRight			:=  If(lWeb,2650,2500) 
PRIVATE nCol0  			:= nLeft
PRIVATE nTop			:= 130
PRIVATE nTopInt			:= nTop
PRIVATE nPag			:= 1
PRIVATE nColIni 		:= 065
PRIVATE nAC				:= 0.24
PRIVATE nColMax			:= If(lWeb,3350,3140)
PRIVATE nLinVer			:= If(lWeb,590,608)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Print
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

If !lWeb
	While !lPerg 
		 If !Pergunte(cPerg,.T.)
			Return .F.
		Else
			If MONTH(CTOD("01/"+MV_PAR01)) == 0
				msgAlert("Mês de cobrança inicial maior que 12.")	
				lPerg := .F.
				
			ElseIf MONTH(CTOD("01/"+MV_PAR02)) == 0
				msgAlert("Mês de cobrança final maior que 12.")
				lPerg := .F.
				
			ElseIf YEAR(CTOD("01/"+MV_PAR01)) > YEAR(CTOD("01/"+MV_PAR02)) 
				msgAlert("Ano de cobrança inicial maior que o ano de cobrança final.")
				lPerg := .F.
			Else
				lPerg := .T.
			EndIf
		EndIf
	EndDo
endIf

oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,nil,.f.,.f.,.t.)

oReport:lInJob  	:= lWeb
oReport:lServer 	:= lWeb
oReport:cPathPDF	:= cDirPath

oReport:setDevice(IMP_PDF)
oReport:setResolution(72)
oReport:SetLandscape()
oReport:SetPaperSize(9)
oReport:setMargin(05,05,05,05)

IF !lWeb
	oReport:Setup()   //Tela de configurações
	
	If oReport:nModalResult != IMP_OK
		Return .F.
	EndIf
ENDIF

lRet := PLSR001Imp(oReport,lWeb,aDadosWeb)

if lRet
	aRet := {cFileName+".pdf",""}
else
	aRet := {"",""}
endif

IF (lRet)
	oReport:EndPage()
	oReport:Print()
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Checa se o arquivo PDF esta ponto para visualizacao na web
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if lWeb .AND. lRet
	PLSCHKRP(cDirPath, cFileName+".pdf")
endIf

Return(aRet[1])

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Função    ³PLSR001Imp³ Autor ³ Thiago Guilherme          ³ Data ³ 11/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição: ³Relatório Analítico de reembolso - B45                     ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSR001Imp(oReport,lWeb,aDadosWeb,lGerPag)
LOCAL nTot			:= 0
LOCAL nColAux		:= 0
LOCAL nQtd			:= 0
LOCAL cSQL			:= ""
LOCAL cCodRDA		:= ""
LOCAL cCodGlo   	:= ""
LOCAL cMsg			:= ""
LOCAL lTitulo		:= .f.
LOCAL lRet			:= .T.
LOCAL nSaldoIni		:= 0
LOCAL nQtdReg		:= 0 
LOCAL nValorPag     := 0
LOCAL nTotValpg		:= 0
Local cCodPlaBen    := ""
LOCAL cTpForFat     := ""

Private cCodDep		:= ""
Private cMatric		:= ""
Private cTipDesp	:= ""
Private cCodPla		:= ""

DEFAULT lGerPag		:= .T.

If lWeb
	cDtSolIni  	:= aDadosWeb[1]
	cDtSolFin   := aDadosWeb[2]
	cMatric		:= aDadosWeb[3]
	cTipDesp	:= aDadosWeb[4]
	cCodPla		:= aDadosWeb[5]
Else
	cDtSolIni  	:= mv_par01
	cDtSolFin   := mv_par02
	cMatric		:= If(EMPTY(mv_par04), mv_par03, mv_par04)
	cTipDesp	:= mv_par05
	cCodPla		:= mv_par06
ENDIF

BA1->(dbSetOrder(2))
BA1->(MsSeek(xFilial("BA1")+cMatric))
cCodPlaBen := BA1->(BA1_CODINT + BA1_CODPLA + BA1_VERSAO)


If Empty(cCodPlaBen)
    BA3->(dbSetOrder(1))
    BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
    cCodPlaBen := BA3->(BA3_CODINT + BA3_CODPLA + BA3_VERSAO)
EndIf

BI3->(dbSetOrder(1))
BI3->(MsSeek(xFilial("BI3")+cCodPlaBen))
cTpForFat := BI3->BI3_FORFAT

cSQL := PQrExtFin(cDtSolIni, cDtSolFin, cMatric, cTipDesp, cCodPla, lWeb,cTpForFat)

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"cArqTrab",.F.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata se nao existir registros...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqTrab->(DbGoTop())

cArqTrab->(DBEval( { | | nQtd ++ }))

If !lWeb
	ProcRegua(nQtd)
Endif

cArqTrab->(DbGoTop())

nLi		  	:= 1
lFirst 		:= .T.

If lGerPag
	oReport:StartPage()
Endif

If !cArqTrab->(Eof())

   Cab974PGR(oReport,lWeb) 

	While !cArqTrab->(Eof())
     	nTot++
        If !lFirst
			   If nLi > 17
					nLi := 1
					oReport:EndPage()
					oReport:StartPage()
					Cab974PGR(oReport,lWeb)
		      EndIf
        Endif
        lFirst := .F.


		lTitulo  := .T.
			nTop += 10

			nTop += _BL

			nColAux := (nCol0/nTweb)
			oReport:Say(nTop/nTweb, nColAux, cArqTrab->BM1_CODTIP, oFnt10c)

			nColAux +=  nDivEsp - 22
			oReport:Say(nTop/nTweb, nColAux, PADR(cArqTrab->BM1_DESTIP,22), oFnt10c) 
			
			
			nColAux +=  nDivEsp + 17
			oReport:Say(nTop/nTweb, nColAux, cArqTrab->BM1_MES + "/" + cArqTrab->BM1_ANO, oFnt10c) //Mes/Ano de cobrança
			
			
			nColAux += nDivEsp 
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform( nSaldoIni, Moeda))), oFnt10c) //Saldo Inicial
			
			
			nColAux += nDivEsp 
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform( cArqTrab->BM1_VALMES, Moeda))), oFnt10c) //Despesa do Mês

			nColAux += nDivEsp  //
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform( cArqTrab->BM1_VALOR, Moeda))), oFnt10c) //Valor cobrado
			
			If !cTpForFat = "3"
                If cArqTrab->E1_VALLIQ < cArqTrab->E1_VALOR//Aqui Robertin
    
			    	BM1->(dbSetOrder(4))
			    	If BM1->(dbSeek(xFilial("BM1") + cArqTrab->(BM1_PREFIX + BM1_NUMTIT)))
			    		While !BM1->(EOF()) .AND. BM1->(BM1_PREFIX + BM1_NUMTIT) == cArqTrab->(BM1_PREFIX + BM1_NUMTIT)
    
			    			nQtdReg++
    
			    			BM1->(dbSkip())
			    		EndDo
    
			    		nValorPag := cArqTrab->E1_VALLIQ / nQtdReg
			    		lLiquid := .F.
			    	EndIf
			    Else
			    	lLiquid := .T.
			    EndIf
            Else
                lLiquid := .T.
            EndIf    
			
			If lLiquid
				nValorPag := cArqTrab->BM1_VALOR
			EndIf
			
			nTotValpg += nValorPag
			
			nColAux += nDivEsp 
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform( nValorPag, Moeda))), oFnt10c) //Valor pago

			nColAux += nDivEsp 
			oReport:Say(nTop/nTweb, nColAux, AllTrim(cValtoChar(transform(cArqTrab->BM1_VALOR - nValorPag, Moeda))), oFnt10c) //Saldo Final
			
			nSaldoIni += cArqTrab->BM1_VALOR - nValorPag
			nLi++

		nTop += _BL
		oReport:Line(nTop/nTweb, nLeft/nTweb - 5, nTop/nTweb, nRight/nTweb - 65)

		cArqTrab->(dbSkip())
	EndDo
	
	nColAux := (nCol0/nTweb) + nDivEsp

	nTop += _BL
	cMsg := "Total Valor Pago  "+ IF(!lWeb, Replicate( ".", 218), Replicate( ".", 160))
	oReport:Say(nTop/nTweb, nLeft/nTweb, cMsg, oFnt10c)

	nColAux += 3* nDivEsp - 8
	oReport:Say(nTop/nTweb, nColAux  , AllTrim(cValtoChar(transform( nTotValpg, Moeda))), oFnt10c)

	nLi++
   	nTop += _BL
	nLi++
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
±±³ Fun‡…o    ³PQrExtFin³ Autor ³Thiago Ribas     ³ Data ³ 11/2015        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³Query de retorno do extrato financeiro                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PQrExtFin(cDtSolIni, cDtSolFin, cMatric, cTipDesp, cCodPla, lWeb, cTpForFat)

LOCAL cSQL 	  := ""
LOCAL cAnoMesIn := IF(!lWeb,AnoMes(CTOD("01/"+cDtSolIni)),AnoMes(cDtSolIni))
LOCAL cAnoMesFi := IF(!lWeb,AnoMes(CTOD("01/"+cDtSolFin)),AnoMes(cDtSolFin))

cSql += " SELECT  BM1_CODTIP,BM1_DESTIP,BM1_MES, BM1_ANO, BM1_VALMES, BM1_VALOR, BM1_PREFIX, BM1_NUMTIT

If !cTpForFat  = "3"
    cSql += ", E1_VALOR, E1_VALLIQ, E1_SALDO 
EndIf

cSql += " FROM " + RetSQLName("BM1")
If !cTpForFat  = "3"
    cSql += " INNER JOIN " + RetSQLName("SE1")
    cSql += " ON BM1_NUMTIT = E1_NUM AND E1_BAIXA <> ''"  
EndIf

cSql += " WHERE  BM1_CODINT || BM1_CODEMP || BM1_MATRIC || BM1_TIPREG || BM1_DIGITO = '" + cMatric + "' "
cSql += "AND BM1_ANO || BM1_MES >= '" + cAnoMesIn + "' AND BM1_ANO || BM1_MES <= '" + cAnoMesFi + "' "

If !EMPTY(cTipDesp)
	cSql += "AND BM1_CODTIP = '" + cTipDesp + "' "
EndIf

If !EMPTY(cCodPla)
	cSql += "AND BM1_CODEVE = '" + cCodPla + "' "
EndIf

cSql += " AND "+RetSqlName("BM1")+".D_E_L_E_T_ = '' "

If !cTpForFat  = "3"
    cSql += " AND " +RetSqlName("SE1")+".D_E_L_E_T_ = ''"
EndIf

return cSql

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Cab974PGR³ Autor ³Thiago Guilherme     ³ Data ³ 11/20105       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³Criar cabeçalho                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Cab974PGR(oReport,lWeb,nLi)


LOCAL cCodint := PlsIntPad()
LOCAL cTitular := ""

nTop		:= 15
nTopInt	:= nTop
nLeft		:= 25

nTop		+= _BL
nTopAux 	:= nTop

aBMP	:= {"lgesqrl.bmp"}

If File("lgesqrl" + FWGrpCompany() + FWCodFil() + ".bmp")
	aBMP := { "lgesqrl" + FWGrpCompany() + FWCodFil() + ".bmp" }
ElseIf File("lgesqrl" + FWGrpCompany() + ".bmp")
	aBMP := { "lgesqrl" + FWGrpCompany() + ".bmp" }
EndIf

oReport:SayBitmap(nTop/nTweb, nLeft/nTweb, aBMP[1], 100, 100)
oReport:Box(nLeft,(nColIni + 0000)*nAC,nLinVer,(nColIni + nColMax)*nAC)

cMsg := cTitulo
nTop += 80
oReport:Say(((nTop)/nTweb)+nLweb, (nLeft + 900)/nTweb, cMsg, oFnt14N)

nTop  += 130
nLeft := 70

//If !Empty(cDtPagIni) .AND. !Empty(cDtPagFin)
	//oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
	cMsg := "Data do relatório: " + DTOC(dDatabase)
	//cMsg := "Data do Crédito: "+dtoc("cDtPagIni")+" a "+dtoc("cDtPagFin")+""
//Endif
nTop += 45


oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)

cMsg := "Mês/Ano de cobrança de: " + dtoc(cDtSolIni) + " Até: " + dtoc(cDtSolFin)
nTop += 35

oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
nTop += 35

oReport:Line(((nTop)/nTweb)+nLweb, nLeft/nTweb - 5, (nTop/nTweb)+nLweb, nRight/nTweb - 65)

If(!lWeb)
	cMsg := "Beneficiário(a) titular: " + ALLTRIM(Posicione("BA1",2,xFilial("BA1") + IIF(!Empty(mv_par03), cMatric, mv_par03),"BA1_NOMUSR"))
	nTop += 35
	oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
	
	cMsg := "Dependente: " + ALLTRIM(Posicione("BA1",2,xFilial("BA1")+cMatric,"BA1_NOMUSR"))
	nTop += 35
	oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
Else
      
       cTitular := SUBSTR(cMatric,15,2)
    If cTitular == "00" 
	   	cMsg := "Beneficiário(a) titular: " + ALLTRIM(Posicione("BA1",2,xFilial("BA1") + cMatric ,"BA1_NOMUSR"))
		nTop += 35
		oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
	Else
		cMsg := "Dependente: " + ALLTRIM(Posicione("BA1",2,xFilial("BA1")+cMatric,"BA1_NOMUSR"))
		nTop += 35
		oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)
	EndIf	
EndIf
/*
cMsg := "Tipo de despesa: " + IIF(!Empty(cTipDesp),ALLTRIM(Posicione("BFQ",1,xFilial("BFQ") + cCodint + cTipDesp,"BFQ_DESCRI")),"")
nTop += 35
oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)

cMsg := "Plano: " + IIF(!Empty(cCodPla),ALLTRIM(Posicione("BI3",1,xFilial("BI3") + cCodint + cCodPla,"BI3_DESCRI")),"")
nTop += 35
oReport:Say(((nTop)/nTweb)+nLweb,nLeft/nTweb, cMsg, oFnt10N)
*/

nTop += _BL
oReport:Line(((nTop)/nTweb)+nLweb, nLeft/nTweb - 5, (nTop/nTweb)+nLweb, nRight/nTweb - 65)
nTop += _BL
nPag++

nTop += 40

nColAux  := (nCol0/nTweb)
oReport:Say(nTop/nTweb, nColAux, "Cod. Despesa", oFnt10c)

//Espassamento entre colunas.
nColAux += (nRight/nTweb - 65  - nTop/nTweb)  / 8
nDivEsp := nColAux

oReport:Say(nTop/nTweb, nColAux, "Tipo Despesa", oFnt10c)

nColAux += nDivEsp + 7 
oReport:Say(nTop/nTweb, nColAux, "Mês/ano Cobrança", oFnt10c)

nColAux += nDivEsp
oReport:Say(nTop/nTweb, nColAux, "Saldo Inicial(R$)", oFnt10c)

nColAux += nDivEsp
oReport:Say(nTop/nTweb, nColAux, "Despesa Mês(R$)", oFnt10c)

nColAux += nDivEsp
oReport:Say(nTop/nTweb, nColAux, "Valor Cobrado(R$)", oFnt10c)

nColAux += nDivEsp
oReport:Say(nTop/nTweb, nColAux, "Valor Pago(R$)", oFnt10c)

nColAux += nDivEsp
oReport:Say(nTop/nTweb, nColAux, " Saldo Final(R$)", oFnt10c)
nTop -= 35

nTop += _BL
nTop += 43

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³PLFiltro³ Autor ³Thiago Guilherme     ³ Data ³ 11/20105      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³faz o filtro utilizando a consulta padrão existente BFQPLS  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function PLFiltro()

	If BFQ->(FieldPos("BFQ_EXTFIN")) > 0
		Return BFQ->BFQ_EXTFIN == "1"
	Else
		Return .T.
	EndIf
Return 