#Include "TopConn.CH"
#Include "Protheus.ch"
Static objCENFUNLGP := CENFUNLGP():New() 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR921   บ Autor ณ Cesar Valadao      บ Data ณ  01/06/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Programacao do Calculo de Comissoes           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function PLSR921
Local cDesc1		:= "Este programa tem como objetivo imprimir relatorio "
Local cDesc2		:= "de acordo com os parametros informados pelo usuario."
Local cDesc3		:= "Programa็ใo para Cแlculo de Comiss๕es"
Local cPict			:= ""
Local titulo		:= "Programa็ใo para Cแlculo de Comiss๕es"
Local nLin			:= 80
Local Cabec1		:= "Mes/Ano Data       Matricula             Nome                                                 Meta   Real  Seq Meta Qtd De Qtd Ate  % Com   Vlr Com Beneficiario"
Local Cabec2		:= ""
Local imprime		:= .T.
Local aOrd			:= {}
Private lEnd		:= .F.
Private lAbortPrint	:= .F.
Private limite		:= 220
Private tamanho		:= "G"
Private nomeprog	:= "PLSR921"
Private nTipo		:= 18
Private aReturn		:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey	:= 0
Private cbtxt		:= Space(10)
Private cbcont		:= 00
Private CONTFL		:= 01
Private m_pag		:= 01
Private wnrel		:= "PLSR921"
Private cString		:= "BXO"
Private cPerg		:= "PLR921"

//-- LGPD ----------
if !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

AjustaSX1()
Pergunte(cPerg, .F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)
RptStatus({|| RunPLSR921(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณRunPLSR921บ Autor ณ Cesar Valadao      บ Data ณ  01/06/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Programacao do Calculo de Comissoes           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunPLSR921(Cabec1,Cabec2,Titulo,nLin)
//Local nOrdem
Local cQuery
Local cChave		:= Space(12)
Local cChave2 		:= Space(70)
Local lFirstCabe 	:= .T.

cQuery := "SELECT BXO.BXO_CODVEN CODVEN, BXO.BXO_MES MES, BXO.BXO_ANO ANO, BXO.BXO_DATA DATA"
cQuery += ", BXO.BXO_CODINT+BXO.BXO_CODEMP+BXO.BXO_MATRIC+BXO.BXO_TIPREG+BXO.BXO_DIGITO MATRICULA"
cQuery += ", BXO.BXO_CODINT+BXO.BXO_CODEMP+BXO.BXO_NUMCON+BXO.BXO_VERCON+BXO.BXO_SUBCON+BXO.BXO_VERSUB CONTRATO"
cQuery += ", BXO.BXO_MATRIC MATRIC"
cQuery += ", BXO.BXO_CODEQU CODEQU"
cQuery += ", BXP.BXP_META META"
cQuery += ", BXP.BXP_REAL REAL"
cQuery += ", BXP.BXP_BENEF BENEF"
cQuery += ", BXO.BXO_SEQBXJ SEQ, BXP.BXP_QTDDE QTDDE, BXP.BXP_QTDATE QTDATE, BXP.BXP_PERCON PERCOM, BXP.BXP_VALCON VALCOM"
cQuery += "   FROM "+RetSQLName("BXO")+" BXO, "+RetSQLName("BXP")+" BXP"
cQuery += "  WHERE BXP.BXP_SEQBXO = BXO.BXO_SEQ"
cQuery += "    AND BXO.BXO_FILIAL='"+xFilial("BXO")+"'"
cQuery += "    AND BXP.BXP_FILIAL='"+xFilial("BXP")+"'"
cQuery += "    AND BXO.BXO_CODVEN BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
cQuery += "    AND BXO.BXO_MES BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
cQuery += "    AND BXO.BXO_ANO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
cQuery += "    AND BXO.D_E_L_E_T_<>'*'"
cQuery += "    AND BXP.D_E_L_E_T_<>'*'"
cQuery += "  ORDER BY CODVEN, CODEQU, ANO, MES, MATRICULA, CONTRATO, DATA"

PLSQuery(cQuery, "TMP")
TCSetField("TMP", "DATA",   "D", 8, 0)
TCSetField("TMP", "META",   "N", 12, 2)
TCSetField("TMP", "REAL",   "N", 12, 2)
TCSetField("TMP", "PERCOM", "N",  8, 2)
TCSetField("TMP", "VALCOM", "N", 12, 2)

While TMP->(!EOF())
	If lAbortPrint
		@ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	
	If nLin > 55
		nLin :=	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin ++ 
	EndIf

	/*
	Vendedor: xxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Equipe  : xxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	Mes/Ano Data     Matricula                         Meta    Real Seq      Qtd De Qtd Ate  % Com   Vlr Com Beneficiario
	xx/xxxx xx/xx/xx xxxx.xxxx.xxxxxx.xx-x          xxx.xxx xxx.xxx xxxxxxxx xxxxxx  xxxxxx xxx,xx xx.xxx,xx xxxxxxxxxxxx
																			xxxxxx  xxxxxx xxx,xx xx.xxx,xx xxxxxxxxxxxx
																			xxxxxx  xxxxxx xxx,xx xx.xxx,xx xxxxxxxxxxxx
	*/                                                                         
	If cChave <> TMP->CODVEN+TMP->CODEQU
		If MV_PAR07==1 .And. !lFirstCabe
			lFirstCabe := .F.
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		EndIf
		nLin += 2
		@ nLin, 000 PSAY "Vendedor : "+TMP->CODVEN+" - "+Posicione("SA3", 1, xFilial("SA3")+TMP->CODVEN, "A3_NOME")
		nLin++
		@ nLin, 000 PSAY "Equipe   : "+TMP->CODEQU+" - "+Posicione("BXL", 1, xFilial("BXL")+TMP->CODEQU, "BXL_DESEQU")
		cChave := TMP->CODVEN+TMP->CODEQU
		nLin++
	EndIf
	If  cChave2 <> TMP->MES+TMP->ANO+TMP->MATRICULA+TMP->CONTRATO
	    @ nLin, 000 PSAY TMP->MES+"/"+TMP->ANO
	    @ nLin, 008 PSAY TMP->DATA PICTURE "@E"
        If  ! empty(TMP->MATRIC)
            cNomUsr := posicione("BA1",2,xFilial("BA1")+TMP->MATRICULA,"BA1_NOMUSR")
		    @ nLin, 019 PSAY TMP->MATRICULA PICTURE "@R 9999.9999.999999.99-9"
  		    @ nLin, 041 PSAY cNomUsr
	    Else                                                      
		    @ nLin, 019 PSAY TMP->CONTRATO  PICTURE "@R XXXX.XXXX.XXXXXXXXXXXX.XXX.XXXXXXXXX.XXX"
	    Endif
	    @ nLin, 092 PSAY TMP->META PICTURE "@E 999999"
	    @ nLin, 099 PSAY TMP->REAL PICTURE "@E 999999"
	    @ nLin, 107 PSAY TMP->SEQ
	    cChave2 := TMP->MES+TMP->ANO+TMP->MATRICULA+TMP->CONTRATO
	EndIf
	@ nLin, 116 PSAY TMP->QTDDE  PICTURE "999999"
	@ nLin, 124 PSAY TMP->QTDATE PICTURE "999999"
	@ nLin, 131 PSAY TMP->PERCOM PICTURE "@E 999.99"
	@ nLin, 138 PSAY TMP->VALCOM PICTURE "@E 99,999.99"
	@ nLin, 148 PSAY X3Combo("BXP_BENEF", TMP->BENEF)
	nLin++
	
	TMP->(dbSkip())
End
TMP->(dbCloseArea())

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ AjustaSX1    ณAutor ณ Cesar Valadao        ณDataณ 01/06/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Ajusta perguntas do SX1                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Iniciliza variaveis                                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRegs	:=	{}
aadd(aRegs,{"PLR921","01","Vendedor de        ?","","","mv_ch1","C",06,0,1,"G","","mv_par01",   "","","","",   "","","","","","","","","","","","","","","","","","","","","SA3","" })
aadd(aRegs,{"PLR921","02","Vendedor Ate       ?","","","mv_ch2","C",06,0,1,"G","","mv_par02",   "","","","",   "","","","","","","","","","","","","","","","","","","","","SA3","" })
aadd(aRegs,{"PLR921","03","Mes de             ?","","","mv_ch3","C",02,0,1,"G","","mv_par03",   "","","","",   "","","","","","","","","","","","","","","","","","","","",""   ,"" })
aadd(aRegs,{"PLR921","04","Mes Ate            ?","","","mv_ch4","C",02,0,1,"G","","mv_par04",   "","","","",   "","","","","","","","","","","","","","","","","","","","",""   ,"" })
aadd(aRegs,{"PLR921","05","Ano de             ?","","","mv_ch5","C",04,0,1,"G","","mv_par05",   "","","","",   "","","","","","","","","","","","","","","","","","","","",""   ,"" })
aadd(aRegs,{"PLR921","06","Ano Ate            ?","","","mv_ch6","C",04,0,1,"G","","mv_par06",   "","","","",   "","","","","","","","","","","","","","","","","","","","",""   ,"" })
aadd(aRegs,{"PLR921","07","Salta Pag Vendedor ?","","","mv_ch6","N",01,0,1,"C","","mv_par07","Sim","","","","Nao","","","","","","","","","","","","","","","","","","","",""   ,"" })
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza SX1                                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PlsVldPerg(aRegs)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fim da funcao                                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Return(NIL)