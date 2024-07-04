
Static objCENFUNLGP := CENFUNLGP():New()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR922   º Autor ³ Cesar Valadao      º Data ³  01/06/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Programacao do Calculo de Comissoes           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPLS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSR922
Local cDesc1		:= "Este programa tem como objetivo imprimir relatorio "
Local cDesc2		:= "de acordo com os parametros informados pelo usuario."
Local cDesc3		:= "Comissões Calculadas"
Local cPict			:= ""
Local titulo		:= "Comissões Calculadas"
Local nLin			:= 80
Local Cabec1		:= "Mes/Ano Data     Pfx Numero    P   Tp  Matricula             Parc Seq Regra  Base Com  % Com   Vlr Com Pagamento     Pfx Numero    P   Fornec Lj Dt Geracao Nome do Usuario"
Local Cabec2		:= ""
Local imprime		:= .T.
Local aOrd			:= {}
Private lEnd		:= .F.
Private lAbortPrint	:= .F.
Private limite		:= 220
Private tamanho		:= "G"
Private nomeprog	:= "PLSR922"
Private nTipo		:= 18
Private aReturn		:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey	:= 0
Private cbtxt		:= Space(10)
Private cbcont		:= 00
Private CONTFL		:= 01
Private m_pag		:= 01
Private wnrel		:= "PLSR922"
Private cString		:= "BXQ"
Private cPerg		:= "PLR922"

Pergunte(cPerg, .F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
If nLastKey == 27
	Return
Endif

	aAlias := {"BXQ","SA3","BA1"}
	objCENFUNLGP:setAlias(aAlias)

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)
RptStatus({|| RunPLSR922(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RunPLSR922º Autor ³ Cesar Valadao      º Data ³  01/06/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Programacao do Calculo de Comissoes           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunPLSR922(Cabec1,Cabec2,Titulo,nLin)
//Local nOrdem
Local cQuery
Local cVendedor := "      "
Local lFirstCabe := .T.
Local nTotBASCOM := 0
Local nTotVLRCOM := 0
Local nTotalBAS := 0
Local nTotalVLR := 0

If     mv_par08 == 1
       titulo := alltrim(titulo) + " - Provisao"
ElseIf mv_par08 == 2
       titulo := alltrim(titulo) + " - Pronta para Pagamento"
Else
       titulo := alltrim(titulo) + " - Pagas"
Endif
cQuery := "SELECT BXQ.BXQ_CODVEN CODVEN, BXQ.BXQ_MES MES, BXQ.BXQ_ANO ANO, BXQ.BXQ_DATA DATA, BXQ.BXQ_PREFIX PREFIX, BXQ.BXQ_NUM NUM, BXQ.BXQ_PARC PARC, BXQ.BXQ_TIPO TIPO, BXQ.BXQ_CODINT+BXQ.BXQ_CODEMP+BXQ.BXQ_MATRIC+BXQ.BXQ_TIPREG+BXQ.BXQ_DIGITO MATRICULA, BXQ.BXQ_NUMPAR NUMPAR, BXQ.BXQ_SEQBXO SEQBXO, BXQ.BXQ_BASCOM BASCOM, BXQ.BXQ_PERCOM PERCOM, BXQ.BXQ_VLRCOM VLRCOM, BXQ.BXQ_PAGCOM PAGCOM, BXQ.BXQ_PAGPER PAGPER"
cQuery += ", BXQ.BXQ_E2PREF E2PREF"
cQuery += ", BXQ.BXQ_E2NUM  E2NUM"
cQuery += ", BXQ.BXQ_E2PARC E2PARC"
cQuery += ", BXQ.BXQ_E2FORN E2FORN"
cQuery += ", BXQ.BXQ_E2LOJA E2LOJA"
cQuery += ", BXQ.BXQ_DTGER  DTGER"
cQuery += ", BXQ.BXQ_PAGCOM PAGCOM"
cQuery += ", BXQ.BXQ_REFERE REFERE"
cQuery += "   FROM "+RetSQLName("BXQ")+" BXQ"
cQuery += "  WHERE BXQ.BXQ_FILIAL='"+xFilial("BXQ")+"'"
cQuery += "    AND BXQ.BXQ_CODVEN BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
cQuery += "    AND BXQ.BXQ_MES BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
cQuery += "    AND BXQ.BXQ_ANO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
cQuery += "    AND BXQ.D_E_L_E_T_ = ' '"
cQuery += "  ORDER BY CODVEN, ANO, MES, MATRICULA, DATA"
PLSQuery(cQuery, "TMP")
TCSetField("TMP", "DATA",   "D", 8, 0)
TCSetField("TMP", "BASCOM", "N", 12, 2)
TCSetField("TMP", "PERCOM", "N",  8, 2)
TCSetField("TMP", "VLRCOM", "N", 12, 2)
TCSetField("TMP", "PAGPER", "N",  8, 2)
TCSetField("TMP", "DTGER" ,"D",  8, 0)
BA1->(dbsetOrder(2))
While ! TMP->(EOF())
	If lAbortPrint
		@ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf

    If     mv_par08 == 1
           If  TMP->REFERE <> "1"
	           TMP->(dbSkip())
	           Loop
	       Endif
    ElseIf mv_par08 == 2
           If  TMP->PAGCOM <> TMP->REFERE 
	           TMP->(dbSkip())
	           Loop
	       Endif
    Else
           If  empty(TMP->DTGER)
	           TMP->(dbSkip())
	           Loop
	       Endif
    Endif
         
               

	
	If nLin > 55
		nLin :=	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)    
		nLin ++
	EndIf

/*
Vendedor: xxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Mes/Ano Data     Pfx Numero P Tp Matricula             Parc Seq Regra  Base Com  % Com   Vlr Com Pagamento     Pfx Numero P Fornec Lj Dt Geracao
xx/xxxx xx/xx/xx xxx xxxxxx x xx xxxx.xxxx.xxxxxx.xx-x xxx  xxxxxxxx  xx.xxx,xx xxx,xx xx.xxx,xx xxx%(EMISSAO) xxx xxxxxx x xxxxxx xx xx/xx/xx
xx/xxxx xx/xx/xx xxx xxxxxx x xx xxxx.xxxx.xxxxxx.xx-x xxx  xxxxxxxx  xx.xxx,xx xxx,xx xx.xxx,xx xxx%(BAIXA)   xxx xxxxxx x xxxxxx xx xx/xx/xx
                                                       Total         xxx.xxx,xx       xxx.xxx,xx                          
*/                                                                         
	If cVendedor <> TMP->CODVEN
		If nTotBASCOM<>0 .Or. nTotVLRCOM<>0
			@ nLin, 055 PSAY "Total"
			@ nLin, 075 PSAY nTotBASCOM PICTURE "@E 999,999.99"
			@ nLin, 092 PSAY nTotVLRCOM PICTURE "@E 999,999.99"
			nTotBASCOM := 0
			nTotVLRCOM := 0
		EndIf
		If MV_PAR07==1 .And. !lFirstCabe
			lFirstCabe := .F.
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)			
		EndIf
		nLin += 2
		@ nLin, 000 PSAY "Vendedor: " + objCENFUNLGP:verCamNPR("BXQ_CODVEN",TMP->CODVEN) + " - " +;
						 objCENFUNLGP:verCamNPR("A3_NOME",Posicione("SA3", 1, xFilial("SA3")+TMP->CODVEN, "A3_NOME"))
		cVendedor := TMP->CODVEN
		nLin++
	EndIf

   If  ! empty(TMP->MATRICULA)
       BA1->(dbSeek(xFilial("BA1")+TMP->MATRICULA))
   Endif

	@ nLin, 000 PSAY objCENFUNLGP:verCamNPR("BXQ_MES",TMP->MES)+"/"+objCENFUNLGP:verCamNPR("ANO",TMP->ANO)
	@ nLin, 008 PSAY objCENFUNLGP:verCamNPR("BXQ_DATA",TMP->DATA) PICTURE "@E"
    If  TMP->NUM <> "RATEIO"
   	    @ nLin, 017 PSAY objCENFUNLGP:verCamNPR("BXQ_PREFIX",TMP->PREFIX)
	    @ nLin, 021 PSAY objCENFUNLGP:verCamNPR("BXQ_NUM",TMP->NUM)
	    @ nLin, 031 PSAY objCENFUNLGP:verCamNPR("BXQ_PARC",TMP->PARC)
	    @ nLin, 035 PSAY objCENFUNLGP:verCamNPR("BXQ_TIPO",TMP->TIPO)
	    @ nLin, 039 PSAY objCENFUNLGP:verCamNPR("BXQ_MATRIC",TMP->MATRICULA) PICTURE "@R 9999.9999.999999.99-9"
	    @ nLin, 061 PSAY objCENFUNLGP:verCamNPR("BXQ_NUMPAR",TMP->NUMPAR)
	    @ nLin, 066 PSAY objCENFUNLGP:verCamNPR("BXQ_SEQBXO",TMP->SEQBXO)
	Endif
	@ nLin, 076 PSAY objCENFUNLGP:verCamNPR("BXQ_BASCOM",TMP->BASCOM) PICTURE "@E 99,999.99"
	@ nLin, 086 PSAY objCENFUNLGP:verCamNPR("BXQ_PERCOM",TMP->PERCOM) PICTURE "@E 999.99"
	@ nLin, 093 PSAY objCENFUNLGP:verCamNPR("BXQ_VLRCOM",TMP->VLRCOM) PICTURE "@E 99,999.99"
	@ nLin, 103 PSAY Transform(TMP->PAGPER, "@E 999")+If(TMP->PAGCOM=="1", "%(EMISSAO)", "%(BAIXA)")
	@ nLin, 117 PSAY objCENFUNLGP:verCamNPR("BXQ_E2PREF",TMP->E2PREF)
	@ nLin, 121 PSAY objCENFUNLGP:verCamNPR("BXQ_E2NUM",TMP->E2NUM)
	@ nLin, 131 PSAY objCENFUNLGP:verCamNPR("BXQ_E2PARC",TMP->E2PARC)
	@ nLin, 135 PSAY objCENFUNLGP:verCamNPR("BXQ_E2FORN",TMP->E2FORN)
	@ nLin, 142 PSAY objCENFUNLGP:verCamNPR("BXQ_E2LOJA",TMP->E2LOJA)
	@ nLin, 145 PSAY objCENFUNLGP:verCamNPR("BXQ_DTGER",TMP->DTGER)
    If  TMP->NUM == "RATEIO"
	    @ nLin, 156 PSAY "Rateio Equipe"
    Else
	    @ nLin, 156 PSAY objCENFUNLGP:verCamNPR("BA1_NOMUSR",BA1->BA1_NOMUSR)
	Endif
	nLin++
	nTotBASCOM += TMP->BASCOM		// Total por Vendedor
	nTotVLRCOM += TMP->VLRCOM
	nTotalBAS  += TMP->BASCOM		// Total geral
	nTotalVLR  += TMP->VLRCOM
	TMP->(dbSkip())
End
If nTotBASCOM<>0 .Or. nTotVLRCOM<>0
	@ nLin, 055 PSAY "Total"
	@ nLin, 077 PSAY nTotBASCOM PICTURE "@E 999,999.99"
	@ nLin, 094 PSAY nTotVLRCOM PICTURE "@E 999,999.99"
EndIf
nLin += 2
@ nLin, 055 PSAY "Total geral"
@ nLin, 077 PSAY nTotalBAS PICTURE "@E 999,999.99"
@ nLin, 094 PSAY nTotalVLR PICTURE "@E 999,999.99"
dbCloseArea()

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

