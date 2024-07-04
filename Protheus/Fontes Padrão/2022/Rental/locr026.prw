#Include "LOCR026.ch" 
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#Include "RWMAKE.ch"
/*/
{PROTHEUS.DOC} LOCR026.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATÓRIO DE ANÁLISE TÉCNICA RAT
@TYPE    FUNCTION
@AUTHOR  FRANK ZWARG FUGA
@SINCE   03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
// ======================================================================= \\
Function LOCR026()
// ======================================================================= \\

Local   cDESC1      := STR0001 // "RELATÓRIO DE ANÁLISE TÉCNICA "
Local   cDESC2      := ""
Local   cDESC3      := ""
Local   TITULO      := STR0002 // "RELATÓRIO DE ANÁLISE TÉCNICA"
Local   nLin        := 80
Local   CABEC1      := STR0003 // "  PROJETO               CLIENTE                                  OBRA                                     CIDADE                  UF   GESTOR                  RESPONSÁVEL        DT. SOLIC. DT. VISTORIA   STATUS"
Local   CABEC2      := ""	
Local   IMPRIME 

Private aORD        := {STR0004,STR0005,STR0006,STR0007,STR0008} // "PROJETO" ### "CLIENTE" ### "DT. VISTORIA" ### "DT. REALISADO" ### "STATUS"
Private lEND        := .F.
Private lABORTPRINT := .F.
Private lIMITE      := 220
Private TAMANHO     := "G"
Private NOMEPROG    := "LOCR026" 		
Private nTIPO       := 18
Private aReturn     := {"ZEBRADO" , 1 , "ADMINISTRACAO" , 2 , 2 , 1 , "" , 1}
Private nLastKey    := 0
Private cPERG       := "LOCR026" 		
Private CBTXT       := Space(10)
Private CBCONT      := 00
Private CONTFL      := 01
Private M_PAG       := 01
Private WNREL       := "LOCR026" 		
Private cSTRING     := "SA1"

IMPRIME := .T.

dbSelectArea("SA1")
dbSetOrder(1)

Pergunte(cPERG,.F.)

WNREL := SetPrint(cSTRING , NOMEPROG , cPERG , @TITULO , CDESC1 , CDESC2 , CDESC3 , .F. , aORD , .F. , TAMANHO , , .F.) 

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cSTRING)

If nLastKey == 27
	Return
EndIf

nTIPO := Iif(aReturn[4]==1 , 15 , 18) 

RptStatus({|| RUNREPORT(CABEC1 , CABEC2 , TITULO , nLIN)} , TITULO) 

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUN‡„O    ³RUNREPORT º AUTOR ³ AP6 IDE            º DATA ³  01/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRI‡„O ³ FUNCAO AUXILIAR CHAMADA PELA RPTSTATUS. A FUNCAO RPTSTATUS º±±
±±º          ³ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ PROGRAMA PRINCIPAL                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RUNREPORT(CABEC1 , CABEC2 , TITULO , nLIN)

Local nOrdem := aReturn[8]
Local _E     := 0 

_aCOLRAT := {} 

_STATUS  := "" 				// "Todos" 
Do Case
Case MV_PAR11 == 1 			// "Vistoriado" 
	_STATUS := "V"
Case MV_PAR11 == 2 			// "Complementar" 
	_STATUS:= "C"
Case MV_PAR11 == 3 			// "Não Vistoriado" 
	_STATUS:= "N"
Case MV_PAR11 == 4 			// "Revisado" 
	_STATUS:= "R"
EndCase

If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
EndIf   
cQuery     := " SELECT * "                          + CRLF 
cQuery     += " FROM "+RETSQLNAME("FP5")+" FP5  "   + CRLF 
cQuery     += "        INNER JOIN "+RETSQLNAME("FP0")+" FP0 ON FP0_PROJET = FP5_PROJET AND FP0_FILIAL = FP5_FILIAL "                   + CRLF 
cQuery     += "        INNER JOIN "+RETSQLNAME("FP1")+" FP1 ON FP1_PROJET+FP1_OBRA = FP5_PROJET+FP5_OBRA AND FP1_FILIAL = FP5_FILIAL " + CRLF 
cQuery     += " WHERE  FP5.D_E_L_E_T_ = '' AND FP0.D_E_L_E_T_ = '' AND FP1.D_E_L_E_T_ = '' "           + CRLF 
cQuery     += "   AND  " //FP5_COD    <> '' AND "                                                          + CRLF 
cQuery     += "        FP5_PROJET >= '"+     MV_PAR01 +"' AND FP5_PROJET <= '"+     MV_PAR02 +"' AND " + CRLF 
cQuery     += "        FP0_CLI    >= '"+     MV_PAR03 +"' AND FP0_CLI    <= '"+     MV_PAR04 +"' AND " + CRLF 
cQuery     += "        FP5_OBRA   >= '"+     MV_PAR05 +"' AND FP5_OBRA   <= '"+     MV_PAR06 +"' AND " + CRLF 
If !empty(MV_PAR07)
	cQuery += " FP5_DTVIS  >= '"+DtoS(MV_PAR07)+"' AND "
EndIF
If !empty(MV_PAR08)
	cQuery += " FP5_DTVIS  <= '"+DtoS(MV_PAR08)+"' AND " 
EndIF
If !empty(MV_PAR09)
	cQuery += " FP5_DTREAL >= '"+DtoS(MV_PAR09)+"' AND "
EndIF
If !empty(MV_PAR10)
	cQuery += " FP5_DTREAL <= '"+DtoS(MV_PAR10)+"' AND "
EndIF
cQuery     += "        FP1_MUNORI >= '"+     MV_PAR12 +"' AND FP1_MUNORI <= '"+     MV_PAR13 +"' AND " + CRLF 
cQuery     += "        FP1_ESTORI >= '"+     MV_PAR14 +"' AND FP1_ESTORI <= '"+     MV_PAR15 +"' "     + CRLF 
If !Empty(_STATUS)
	cQuery += "   AND  FP5_SITUAC =  '"+_STATUS +"'"                                                   + CRLF 
EndIf

cQuery := ChangeQuery(cQuery) 
TCQUERY cQuery NEW ALIAS "TRB"

dbSelectArea("TRB")
dbGoTop()
SetRegua(RecCount())

While !TRB->(Eof())
	IncRegua()	
   _CGEST := Posicione("SA3",1,xFilial("SA3")+TRB->FP5_GESTOR,"A3_NOME") 			// NOME DO GESTOR
	nLIN  := nLin +1
	aAdd(_aCOLRAT , {TRB->FP5_PROJET , TRB->FP0_CLI , StoD(TRB->FP5_DTVIS) , StoD(TRB->FP5_DTREAL) , ; 
	                 Iif(TRB->FP5_SITUAC == "V",STR0009,Iif(TRB->FP5_SITUAC == "C",STR0010,Iif(TRB->FP5_SITUAC == "N",STR0011,Iif(TRB->FP5_SITUAC == "R",STR0012,"")))),; 	// "VISTORIADO" ### "COMPLEMENTAR" ### "NÃO VISTORIADO" ### "REVISADO"
	                 TRB->FP5_OBRA   , TRB->FP1_NOMORI , TRB->FP1_MUNORI , TRB->FP1_ESTORI , TRB->FP0_CLINOM , _CGEST , TRB->FP5_RESPON})
		
	dbSelectArea("TRB")
	dbSkip()
EndDo

dbSelectArea("TRB")
DBCLOSEAREA()
dbSelectArea("FP5")
                                   
_aCOLRAT := aSort(_aCOLRAT,,,{|X,Y| X[nOrdem] > Y[nOrdem]})

For _E:= 1 To Len(_aCOLRAT)
	If nLin > 65 																// SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 65 LINHAS...
		CABEC(TITULO , CABEC1 , CABEC2 , NOMEPROG , TAMANHO , nTIPO)
		nLIN := 8
	EndIf

	@ nLin,001 PSay _aCOLRAT[_E][ 1] 											// PROJETO
	@ nLin,024 PSay _aCOLRAT[_E][10] 											// CLIENTE
	@ nLin,065 PSay _aCOLRAT[_E][ 7] 											// OBRA
	@ nLin,106 PSay _aCOLRAT[_E][ 8] 											// CIDADE
	@ nLin,131 PSay _aCOLRAT[_E][ 9] 											// ESTADO
	@ nLin,135 PSay SubStr(_aCOLRAT[_E][11],1,20) 								// GESTOR
	@ nLin,160 PSay SubStr(_aCOLRAT[_E][12],1,20) 								// RESPONSÁVEL
	@ nLin,178 PSay _aCOLRAT[_E][ 3] 											// DT. SOL
	@ nLin,190 PSay _aCOLRAT[_E][ 4] 											// DT. VIST.
	@ nLin,203 PSay _aCOLRAT[_E][ 5] 											// STATUS
       
     nLIN := nLIN+1
Next _E 
     
// --> FINALIZA A EXECUCAO DO RELATORIO... 
Set Device To Screen

// --> SE IMPRESSAO EM DISCO, CHAMA O GERENCIADOR DE IMPRESSAO... 
If aReturn[5]==1
	DBCOMMITALL()
	Set Printer To
	OurSpool(WNREL)
EndIf

MS_FLUSH()

Return ()
