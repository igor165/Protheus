#INCLUDE "hspahr98.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#INCLUDE "Report.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR98  บ Autor ณ Saude              บ Data ณ  07/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio orcamento						                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function  HSPAHR98()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Declaracao de Variaveis                                             ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001  //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local imprime        := .T.
Local aOrd 			 := {}
Local nLin           := 80
Local nX			 := 0
Local cPerg		     :="HSPR981"

Private cTitulo       := STR0003 //"Or็amento"
Private Cabec1       := ""
Private Cabec2       := ""
Private Cabec3       := ""
Private Cabec4       := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "HSPAHR98" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := {STR0004 , 1, STR0005, 2, 2, 1, "", 1}   //"Administracao"###"Zebrado"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := ""
Private cString      := ""
Private cRegAteIni := "", cRegateFim := "", cCodPacIni := "", cCodPacFim := "", dDatAteIni := "", dDatAteFim := "", dDatPreIni := "", dDatPreFim := "", cSeqPre := "", nTipoImp:= ""
Private nColStart  := 0070
Private nLenPag    := 2500
Private nColEnd    := nLenPag - 0050
Private cCODIMP := "99"
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
Private cMntApre := ""
Private cSolic	:= ""
Private cOrcam	:=""
Private cGT9RegGer:=""
Private cRgPac	:=""
     
If Pergunte(cPerg, .T.)
	cGT9RegGer := MV_PAR01
	cRgPac     := MV_PAR02
	cOrcam     := MV_PAR03	
Else
	Return(nil)
EndIf


If Empty(cOrcam)
	HS_MsgInf(STR0024, STR0008, STR0009)    //"Informe um Or็amento!"###"Aten็ใo"###"Verifique a sele็ใo"
	Return(Nil)
EndIf 

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2


//**************************************************
/*                    1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */


Cabec1 := STR0006 //"  Qtidade  C๓digo     Descri็ใo                              Vl.Unit            Vl. Desconto       Vl. Total "




RptStatus({|| RotImp(Cabec1,"",cTitulo,nMaxLin)},cTitulo)


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Mario Arizono      บ Data ณ  28/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RotImp(Cabec1,Cabec2,Titulo,nMaxLin)

Local nHeiPag   := 3200
Local nLin      := nHeiPag + 1
Local aObs		:= {}
Local nLinObs 	:= 0
Local cObs		:= ""
Local nObs		:= 0
Local cCondi 	:= ""

Local ntotalunit:= 0
Local ntotalDesc:= 0
Local ntotalGera:= 0
Local cValida	:= ""
Local cResFin   := ""
Local cSql      := ""
Local cScjStat  := ""

Private cCdAns		:=""
Private lCabec     := .T.
Private oFont02		:= TFont():New("Arial", 11, 11, , .F., , , , .T., .F.) // Normal
Private oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
Private oFont03n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
Private oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
Private oFont04n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
Private oFont05		:= TFont():New("Arial", 09, 09, , .T., , , , .T., .F.) // Negrito
Private oFont06		:= TFont():New("Arial", 10, 10, , .F., , , , .T., .F.) // Normal
Private oFont06n	:= TFont():New("Arial", 10, 10, , .T., , , , .T., .F.) // Negrito
Private nLinF  := 260
Private cCodCon     := ""
Private cCodPla_De  := ""
Private cCodPla_Ate := ""
Private cCodLoc_De  := ""
Private cCodLoc_Ate := ""
Private cNrLote     := ""
Private cNumPro     := ""
Private cNrFatu     := ""
Private dDatAte_De  := ""
Private dDatAte_Ate := ""
Private nOrdem      := 0
Private cNrSeqG     := ""

Private oFont1 := TFont():New( "Courier New", 09, 10, , , , , , , .F. )
Private oFont2 := TFont():New( "Courier New", 09, 12, , .T., , , , , .F. )
Private oFont3 := TFont():New( "Courier New", 09, 10, , .T., , , , , .F. )
Private oFont4 := TFont():New( "Courier New", 09, 10, , .T., , , , , .F.,.T. )
Private oFont5 := TFont():New('Courier new', 09,10,,.T.)



IF(!Empty(cGT9RegGer))
	cCondi += "      GT9_REGGER = '"+cGT9RegGer+"'  AND  "
EndIf

IF(!Empty(cRgPac))
	cCondi += "      GBH_RG = '"+cRgPac+"' AND  "
EndIf



IF(!Empty(cOrcam))
	cCondi+=" 		SCK.CK_NUM = '" +cOrcam+ "'  AND   "
EndIf

cSql += "SELECT"
cSql += " GBH.GBH_CODPAC,GBH.GBH_NOME,SCK.CK_QTDVEN, SCK.CK_PRODUTO,SCK.CK_DESCRI,SCK.CK_PRUNIT,SCK.CK_PRCVEN,SCK.CK_VALOR,SCK.CK_VALDESC,SCJ.CJ_NUM, SCJ.CJ_STATUS, SCJ.CJ_CLIENTE, SCJ.CJ_EMISSAO,SCJ.CJ_VALIDA"
cSql += " FROM " + RetSqlName("SCJ") + " SCJ "
cSql += " JOIN " + RetSqlName("GT9") + " GT9 ON SCJ.CJ_NUM = GT9.GT9_NUMFAT AND GT9.GT9_FILIAL='" + xFilial("GT9") + "' AND GT9.D_E_L_E_T_ <> '*'"
cSql += " JOIN " + RetSQLName("SCK") + " SCK ON SCJ.CJ_NUM = SCK.CK_NUM AND SCK.CK_FILIAL = '" + xFilial("SCK") + "' AND SCK.D_E_L_E_T_ <> '*'"
cSql += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GT9.GT9_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*'"
cSql += " WHERE " + cCondi + "  SCJ.CJ_FILIAL = '" + xFilial("SCJ") + "' AND SCJ.D_E_L_E_T_ <> '*'"
cSql += " ORDER BY SCJ.CJ_NUM"

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "QRYRE1"



DbSelectArea("QRYRE1")
DbGoTop()




If Eof()
	HS_MsgInf(STR0007, STR0008, STR0009)    //"Nenhuma informa็ใo foi encontrada para a sele็ใo!"###"Aten็ใo"###"Verifique a sele็ใo"
	QRYRE1->(DbCloseArea())
	Return(Nil)
EndIf


oPrn:=TMSPrinter():New()
oPrn:Setup()
oPrn:SetPortrait()

 

nEspLin	    :=   50   	             // espa็amento entre linha
nMarSup	    :=  080   	             // margen superior
nCol1 	    :=  015		               // margen da coluna1
nCol2 	    :=  617		               // margen da coluna2
nCol3 	    :=  817		               // margen da coluna3

DbSelectArea("GD4")
GD4->(DbSetOrder(1))
GD4->(DbSeek(xFilial("GD4") + QRYRE1->GBH_CODPAC))

While GD4->(!Eof()) .AND. GD4->GD4_REGGER == QRYRE1->GBH_CODPAC
	if GD4->GD4_IDPADR == "1"
		cConvenio	:= GD4->GD4_CODCON
		cDesConv	:= Posicione("GA9",1,xFilial("GA9") + GD4->GD4_CODCON,"GA9_NOME")
		cCdAns		:= Posicione("GA9",1,xFilial("GA9") + GD4->GD4_CODCON,"GA9_CODOPE")
	EndIf
	GD4->(DbSkip())
End

oPrn:StartPage()
nLin 	  := nMarSup      // Linha inicial
nLin := FS_CabGraf(oPrn, nLenPag, NomeProg, 100, Titulo)

nLin += 80

nLin += nEspLin

cValida := QRYRE1->CJ_VALIDA
oPrn:Say(nLin, 070, STR0010 +  ALLTRIM(QRYRE1->GBH_CODPAC)+" - " +ALLTRIM(QRYRE1->GBH_NOME), oFont3, 100) // //"Paciente: "
oPrn:Say(nLin, 1520, STR0011 + Alltrim(QRYRE1->CJ_NUM), oFont1, 100) // //"Orcamento: "
nLin += nEspLin
DbSelectArea("GFD")
GFD->(DbSetOrder(3))
GFD->(DbSeek(xFilial("GFD") + QRYRE1->GBH_CODPAC))
                                                                                                                  
if !(empty(ALLTRIM(GFD->GFD_RESFIN)))
	cResFin := ALLTRIM(GFD->GFD_RESFIN) + " - " + ALLTRIM(GFD->GFD_NOME)
else
	cResFin := STR0031 //"O mesmo"
endif

oPrn:Say(nLin, 070, STR0012 + cResFin, oFont1, 100) // //"Titular: "
oPrn:Say(nLin, 1520, STR0013+ HS_DTOC(STOD(QRYRE1->CJ_EMISSAO),2), oFont1, 100) // //"Data: "
nLin += nEspLin


oPrn:Say(nLin, 070, STR0014 + AllTrim(cConvenio)+" - "+AllTrim(cDesConv), oFont1, 100) // //"Convenio: "
nLin += nEspLin

DbSelectArea("GCM")
DbSetOrder(1)
DbSeek(xFilial("GCM") + cConvenio)

oPrn:Say(nLin, 070,STR0015+GCM->GCM_CODPLA+" - "+AllTrim(SubStr(GCM->GCM_DESPLA,1,25))    , oFont1, 100) // //"Plano: "

nLin += nEspLin
oPrn:Line(nLin, nColStart, nLin,  nColEnd)
nLin += nEspLin
oPrn:Say(nLin, 050, Cabec1, oFont4, 100)
nLin += nEspLin
oPrn:Line(nLin, nColStart, nLin,  nColEnd)
nLin += nEspLin

QRYRE1->(DbGoTop())
While !QRYRE1->(Eof())
	
	If nLin > 2700
		nLin := nMarSup
		oPrn:EndPage()
		oPrn:StartPage()
		
		nLin := FS_CabGraf(oPrn, nLenPag, NomeProg, 100, Titulo)
		nLin += 80
		
		nLin += nEspLin
		oPrn:Line(nLin,nColStart,nLin,nColEnd)
		oPrn:Say(nLin, 050, Cabec1, oFont4, 100)
		nLin += nEspLin
		oPrn:Line(nLin, nColStart, nLin,  nColEnd)
		nLin += nEspLin
		
	EndIf
	
	
	/*oPrn:Line(nLin-10,0290,2700,0290) // IMPRIME LINHA Vertical
	//  oPrn:Line(nLin-10,0440,2700,0500) // IMPRIME LINHA Vertical
	oPrn:Line(nLin-10,1720,2700,1720) // IMPRIME LINHA Vertical
	oPrn:Line(nLin-10,2000,2700,2000) // IMPRIME LINHA Vertical
	oPrn:Line(nLin-10,2200,2700,2200) // IMPRIME LINHA Vertical  */
	
	oPrn:Say(nLin, 001, PADL(Transform(QRYRE1->CK_QTDVEN,"@E 999"), 11) , oFont1, 100)
	oPrn:Say(nLin, 300, QRYRE1->CK_PRODUTO, oFont1, 100)
	oPrn:Say(nLin, 540, Alltrim(QRYRE1->CK_DESCRI) , oFont1, 100)
	oPrn:Say(nLin, 1320, PADL(Transform(QRYRE1->CK_PRUNIT,"@E 99,999.999"), 11) , oFont1, 100)
	oPrn:Say(nLin, 1700, PADL(Transform(QRYRE1->CK_VALDESC,"@E 99,999.999"), 11) , oFont1, 100)
	oPrn:Say(nLin, 2200, PADL(Transform(QRYRE1->CK_VALOR, "@E 99,999.999"), 11) , oFont1, 100)
	
	nLin += nEspLin
	
	
	ntotalunit+=QRYRE1->CK_PRUNIT
	ntotalDesc+=QRYRE1->CK_VALDESC
	ntotalGera+=QRYRE1->CK_VALOR
	
	cScjStat := QRYRE1->CJ_STATUS
	
	QRYRE1->(DbSkip())
	
End



cObs := FS_OBSORC()
nLinObs	:= MLCOUNT(cObs, , , )

aObs	:= {}


For nObs := 1 To nLinObs
	aADD(aObs,{MEMOLINE(cObs, , nObs, )})
Next nObs

If nLin < 3200 
	nLin := 2760
   //	nLin := 3200
	
	oPrn:Line(nLin, nColStart, nLin,  nColEnd)
	oPrn:Say(nLin, nColEnd-1010, STR0016 , oFont1, 100) // //"   Tot Unit"
	oPrn:Say(nLin, nColEnd-750, STR0017 , oFont1, 100) // //"    Tot Desc"
	oPrn:Say(nLin, nColEnd-390, STR0018 , oFont1, 100) // //"    Tot Pagar"
	nLin += nEspLin
	oPrn:Say(nLin, nColEnd-1060, PADL(Transform(ntotalunit,"@E 99,999.999"), 11) , oFont1, 100)
	oPrn:Say(nLin, nColEnd-750, PADL(Transform(ntotalDesc,"@E 99,999.999"), 11) , oFont1, 100)
	oPrn:Say(nLin, nColEnd-360, PADL(Transform(ntotalGera, "@E 99,999.999"), 11) , oFont1, 100)
	oPrn:Line(nLin, nColStart, nLin,  nColEnd)
	nLin := 2900
	oPrn:Line(nLin, nColStart, nLin,  nColEnd)
	oPrn:Say(nLin, nColStart, STR0019  , oFont3, 100) // //"Condi็oes de Pagamento: "
	oPrn:Say(nLin, nColEnd-920, STR0020 + iIf(!empty(cValida),HS_DTOC(STOD(cValida),2),dToC(STOD(cValida))), oFont3, 100) // //"Vencimento: "
	oPrn:Say(nLin, nColEnd-400, STR0021 + PADL(Transform(ntotalGera, "@E 99,999.999"), 11), oFont3, 100) // //"Valor:"
	nLin += nEspLin
	oPrn:Line(nLin, nColStart, nLin,  nColEnd)
	
Endif
For nObs := 1 To Len(aObs)
	nLin += 0040
	oPrn:Say(nLin, 0100, aObs[nObs,1], oFont1,100)
Next nObs

if cScjStat == "C"
	nLin += 0060
	oPrn:Say(nLin, 0070, "*** " + STR0032 + " ***" , oFont5, 100, CLR_HRED) //"Obs.: Or็amento cancelado"
endif

oPrn:Preview()
oPrn:End()

QRYRE1->(DbCloseArea())

MS_FLUSH()

Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CabGrafบAutor  ณ                    บ Data ณ  28/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressใo de cabe็alho grแfico                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ HS_CABGRAF(oTMSPinter, nLenPag, cNomeFunct, nColTit,      บฑฑ
ฑฑบ          ณ             cTitulo)                                      บฑฑ
ฑฑบ          ณ oTMSPrinter -> Objeto TMSPrinte instanciado.               บฑฑ
ฑฑบ          ณ nLenPag     -> Largura da Pแgina.                          บฑฑ
ฑฑบ          ณ cNomeFunct  -> Nome do programa.                           บฑฑ
ฑฑบ          ณ nColTit     -> Coluna onde o tํtulo do relat๓rio serแ      บฑฑ
ฑฑบ          ณ                impresso.                                   บฑฑ
ฑฑบ          ณ cTitulo     -> Tํtulo do relat๓rio.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_CabGraf(oPrn, nLenPag, cNomeFunc, nColTit, cTitulo)
//Local cEmpLogo   := "system\lgrl" + Lower(Iif( FindFunction("FWGRPCompany"),FWGRPCompany(), SM0->M0_CODIGO )   ) + ".bmp"
Local cEmpLogo   := fLogoEmp()
Local nLin1      := 0050
Local nLinTit    := 0080
Local nLinIni	:=0
Local nLinMax	:=	3200
Local oCabFont2  := TFont():New("Courier New", 11, 09,, .F.,,,,,.F.) //Adendos Cabe็alho

Default nColTit    := 0800

oPrn:Box( nLinIni+300, nColStart, nLinMax, nColEnd)

oPrn:Line(0000, nColStart, 0000,  nColEnd)

If File(cEmpLogo)
	oPrn:SayBitmap(nLin1-40, nColStart, cEmpLogo, 0330, 0200)
Else
	oPrn:Say(nLin1, nColStart, SM0->M0_NOMECOM, oCabFont2, 100)
EndIf


oPrn:Say(nLinTit, 900 , AllTrim(SM0->M0_NOMECOM) , oFont03n,,,, 2)
oPrn:Say(nLinTit+50, 900 , AllTrim(SM0->M0_CIDENT) + " " + AllTrim(SM0->M0_ENDENT) + STR0022+ AllTrim(SM0->M0_TEL), oFont03n,,,, 2) //"  FONE: "
//Box Nr.ANS
oPrn:Box(nLin1, nColEnd-410, 0200, 2440)
oPrn:Say(nLin1+12, nColEnd-400, STR0023, oFont04n) //"ANS Nบ  "
oPrn:Say(nLin1+12, nColEnd-200, cCdAns, oFont04n) //"35474-1"


Return 0220


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ FS_OBSORC    ณ Autor ณ                  ณ Data 28/09/2011 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ 									                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_OBSORC()

Local cEnvServ := GetEnvServer()
Local cDirRaiz 	:= Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97()))
Local cNomArq	:= ""
Local cTxtOrc := ""

If SubString (cDirRaiz,Len(cDirRaiz),Len(cDirRaiz)) == "\"
	cNomArq := cDirRaiz + "OBSIMPRORCA.txt"
Else
	cNomArq := cDirRaiz + "\OBSIMPRORCA.txt"
EndIf

cTxtOrc := MemoRead(cNomArq)

Return (cTxtOrc)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ FS_vldR98     ณ Autor ณ Saude            ณ Data 27/12/2011 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Valida os campos do pergunte ("HSPR981")	                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FS_vldR98(cReadVar)

local aArea      := getArea()
local lRet       := .T.

Default cReadVar := readVar()

if cReadVar == "MV_PAR01" .and. !empty(MV_PAR01) //Prontuario
	DbSelectArea("GBH")
	DbSetOrder(1)
	if !DbSeek(xFilial("GBH") + MV_PAR01)
		Hs_MsgInf(STR0028, STR0026, STR0027)//"Prontuแrio nใo encontrado!" ### "Aten็ใo"  ### "Valida็ใo Relat๓rio Or็amento Clํnico"
		lRet := .F.
	endif
elseif cReadVar == "MV_PAR02" .and. !empty(MV_PAR02) //RG
	DbSelectArea("GBH")
	DbSetOrder(4)
	if !DbSeek(xFilial("GBH") + MV_PAR02)
		Hs_MsgInf(STR0029, STR0026, STR0027)//"R.G. nใo encontrado!" ### "Aten็ใo"  ### "Valida็ใo Relat๓rio Or็amento Clํnico"
		lRet := .F.
	endif	
elseif cReadVar == "MV_PAR03" .and. !empty(MV_PAR03) //Orcamento
	DbSelectArea("SCJ")
	DbSetOrder(1)
	if !DbSeek(xFilial("SCJ") + MV_PAR03)
		Hs_MsgInf(STR0030, STR0026, STR0027)//"Or็amento nใo encontrado!" ### "Aten็ใo"  ### "Valida็ใo Relat๓rio Or็amento Clํnico"
		lRet := .F.
	endif
endif

restArea(aArea)
return lRet 



Static Function fLogoEmp(cTipo)
Local cStartPath := GetSrvProfString("Startpath","")
Default cTipo := "1"

//-- Logotipo da Empresa
If cTipo =="1"
  cLogo := cStartPath + "LGRL" + SM0->M0_CODIGO + SM0->M0_CODFIL + ".BMP" // Empresa + Filial
  If !File( cLogo )
    cLogo := cStartPath + "LGRL" + SM0->M0_CODIGO + ".BMP" // Empresa
  endif
Else
  cLogo := cStartPath + "LogoSiga.bmp"
Endif


Return(cLogo)