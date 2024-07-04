#Include "LOCR033.ch" 
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#Include "RWMAKE.ch"

/*/
{PROTHEUS.DOC} LOCR033.PRW
ITUP BUSINESS - TOTVS RENTAL
Relatório de carteira de vendas
@TYPE    FUNCTION
@AUTHOR  FRANK ZWARG FUGA
@SINCE   03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
// ======================================================================= \\
Function LOCR033()
// ======================================================================= \\

// --> DECLARACAO DE VARIAVEIS 
Local   cDESC1      := STR0001 	   												// "ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO "
Local   cDESC2      := STR0002 													// "DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
Local   cDESC3      := "LOCR033"
Local   cPICT       := ""
Local   TITULO      := STR0003 													// "POSIÇÃO DE CARTEIRA DE VENDAS"
Local   nLin        := 80
Local   CABEC1      := STR0004 													// "  CÓDIGO/LOJA      CLIENTE              CIDADE          UF      DDD  TELEFONE   CONTATO                   DT.ÚLTIMA COMPRA    "
Local   CABEC2      := ""
Local   CABEC3      := STR0005 		// " CÓDIGO/LOJA      CLIENTE                       CONTATO                               DDD  TELEFONE           DT.ÚLTIMA COMPRA"
Local   _CABEC4     := STR0006 		// " ENDEREÇO                                       CIDADE                    UF            BAIRRO                               "
//									//            1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//									/  /01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Local   IMPRIME     := .T.
Local   aORD        := {}

Private lEND        := .F.
Private lABORTPRINT := .F.
Private CBTXT       := ""
Private lIMITE      := 132
Private TAMANHO     := "M"
Private NOMEPROG    := "LOCR033" 												// COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
Private nTIPO       := 18
Private aReturn     := { "ZEBRADO", 1, "ADMINISTRACAO", 2, 2, 1, "", 1}
Private NLASTKEY    := 0
Private cPerg       := "LOCR033" 												// "LOCP063"
Private CBCONT      := 00
Private CONTFL      := 01
Private M_PAG       := 01
Private WNREL       := "LOCR033" 												// COLOQUE AQUI O NOME DO ARQUIVO USADO PARA IMPRESSAO EM DISCO
Private cSTRING     := "SA1"

cPICT   := "" 
IMPRIME := .T. 
CBTXT   := Space(10) 

Pergunte(cPerg,.F.)
MV_PAR07 := 2

// --> MONTA A INTERFACE PADRAO COM O USUARIO... 
WNREL := SetPrint(cSTRING , NOMEPROG , cPerg , @TITULO , CDESC1 , CDESC2 , CDESC3 , .T. , aORD , .T. , TAMANHO , , .T.) 

If NLASTKEY == 27
	Return
EndIf

SetDefault(aReturn , cSTRING)

If NLASTKEY == 27
	Return
EndIf

nTIPO := If(aReturn[4]==1 , 15 , 18) 

If MV_PAR07 == 1 									// --> Relatório ?    1=Analitico  /  2=Sintetico
	CABEC1 := CABEC3
	CABEC2 := _CABEC4
EndIf

// --> PROCESSAMENTO. RPTSTATUS MONTA JANELA COM A REGUA DE PROCESSAMENTO.
RptStatus({|| RUNREPORT(CABEC1 , CABEC2 , TITULO , nLin) } , TITULO) 

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUN‡„O    ³RUNREPORT º AUTOR ³M&S CONSULTORIA     º DATA ³  30/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRI‡„O ³ FUNCAO AUXILIAR CHAMADA PELA RPTSTATUS. A FUNCAO RPTSTATUS º±±
±±º          ³ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ PROGRAMA PRINCIPAL                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RUNREPORT(CABEC1 , CABEC2 , TITULO , nLin) 

Local _I

// --> VERIFICA O CANCELAMENTO PELO USUARIO... 
_aColsVen :={}

dbSelectArea("SA3")
dbSetOrder(1)
dbGoTop()

While !Eof()
	If SA3->A3_COD >= MV_PAR01 .And. SA3->A3_COD <= MV_PAR02
		aAdd(_aColsVen , {SA3->A3_COD,SA3->A3_NREDUZ}) 
	EndIf
	dbSkip()
EndDo

/*
If MV_PAR07 == 1 									// --> Relatório ?    1=Analitico  /  2=Sintetico

	SetRegua(Len(_aColsVen))
	For _I:=1 To Len(_aColsVen)
		
		If nLin > 63 .Or. _I == _I 												// SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 63 LINHAS...
			CABEC(TITULO , CABEC1 , CABEC2 , NOMEPROG , TAMANHO , nTIPO)
			nLin := 9
			
			@ nLin,001 PSay STR0007 + _aColsVen[_I,1] + " - " 					// "GESTOR: "
			@ nLin,020 PSay _aColsVen[_I,2]
			nLin := nLin +1
		EndIf
		
		dbSelectArea("SA1") 
		SA1->(dbSetOrder(1)) 
		SA1->(dbGoTop()) 
		While SA1->(!Eof()) 
			If SA1->A1_VEND == _aColsVen[_I,1] .And. ;
			   SA1->A1_COD  >= MV_PAR03 .And. SA1->A1_COD  <= MV_PAR04  .And.  SA1->A1_LOJA >= MV_PAR05 .And. SA1->A1_LOJA <= MV_PAR06 
				If nLin > 63 													// SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 63 LINHAS...
					CABEC(TITULO , CABEC1 , CABEC2 , NOMEPROG , TAMANHO , nTIPO) 
					nLin := 9
					@ nLin,001 PSay STR0007 + _aColsVen[_I,1] + " - " 			// "GESTOR: "
					@ nLin,020 PSay _aColsVen[_I,2]
					nLin := nLin + 1
				EndIf 
				nLin := nLin +1
				@ nLin,001 PSay SA1->A1_COD + " / " 
				@ nLin,010 PSay SA1->A1_LOJA 
				@ nLin,019 PSay SubStr(SA1->A1_NREDUZ,1,30)  
                
				//_CONTA1 := Posicione("AC8" , 3 , xFilial("AC8")+SA1->A1_COD+SA1->A1_LOJA , "AC8_CODCON") 
				//_CONTA2 := Posicione("SU5" , 1 , xFilial("SU5")+_CONTA1                  , "U5_CONTAT" ) 

				//@ nLin,049 PSay SubStr(_CONTA2,1,15)
				
				@ nLin,086 PSay Iif(!Empty(SA1->A1_DDD),StrZero(Val(SA1->A1_DDD),3),Space(3))
				@ nLin,091 PSay StrTran(AllTrim(SA1->A1_TEL),"-","") Picture PESQPICT("SA1","A1_TEL")
				@ nLin,115 PSay SA1->A1_ULTCOM 
				nLin := nLin +1 
				@ nLin,001 PSay SubStr(SA1->A1_END,1,45) 
				@ nLin,049 PSay SubStr(SA1->A1_MUN,1,25) 
				@ nLin,074 PSay SA1->A1_EST 
				@ nLin,088 PSay SA1->A1_BAIRRO 
				nLin := nLin +1 
				@ nLin,001 PSay Replicate("-",LIMITE) 
				nLin := nLin +1 
			EndIf 
			SA1->(dbSkip()) 
			
			If lAbortPrint
				@ nLin,00 PSay STR0008 											// "*** CANCELADO PELO OPERADOR ***"
				Exit
			EndIf
		EndDo
		IncRegua()
	Next 
	
Else 			// If MV_PAR07 == 1 				// --> Relatório ?    1=Analitico  /  2=Sintetico
*/
	
	SetRegua(Len(_aColsVen))
	For _I:=1 To Len(_aColsVen)
		If nLin > 63 .Or. _I == _I 												// SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 63 LINHAS...
			CABEC(TITULO,CABEC1,CABEC2,NOMEPROG,TAMANHO,NTIPO)
			nLin := 8
		EndIf
		
		
		@ nLin, 001 PSay STR0007 + _aColsVen[_I,1] + " - " 						// "GESTOR: "
		@ nLin, 020 PSay _aColsVen[_I,2]
		nLin := nLin +1
		
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1)) 
		SetRegua(RecCount())
		SA1->(dbGoTop()) 
		While !Eof()
			If SA1->A1_VEND == _aColsVen[_I,1] .And. ; 
			   SA1->A1_COD  >= MV_PAR03 .And. SA1->A1_COD  <= MV_PAR04  .And.  SA1->A1_LOJA >= MV_PAR05 .And. SA1->A1_LOJA <= MV_PAR06
				
				If nLin > 63 													// SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 63 LINHAS...
					CABEC(TITULO,CABEC1,CABEC2,NOMEPROG,TAMANHO,NTIPO)
					nLin := 8
					
					@ nLin,001 PSay STR0007 + _aColsVen[_I,1] + " - " 			// "GESTOR: "
					@ nLin,020 PSay _aColsVen[_I,2]
					nLin := nLin +1
				EndIf
				nLin := nLin +1
				@ nLin,002 PSay SA1->A1_COD + " / "
				@ nLin,011 PSay SA1->A1_LOJA
				@ nLin,019 PSay SubStr(SA1->A1_NREDUZ,1,20)
				@ nLin,040 PSay SubStr(SA1->A1_MUN,1,15)
				@ nLin,056 PSay SA1->A1_EST
			 //	@ nLin,065 PSay SA1->A1_DDD
				@ nLin,065 PSay Iif(!Empty(SA1->A1_DDD),StrZero(Val(SA1->A1_DDD),3),Space(3))
				@ nLin,069 PSay StrTran(AllTrim(SA1->A1_TEL),"-","") Picture PESQPICT("SA1","A1_TEL")

				//_CONTA1 := Posicione("AC8" , 3 , xFilial("AC8")+SA1->A1_COD+SA1->A1_LOJA , "AC8_CODCON") 
				//_CONTA2 := Posicione("SU5" , 1 , xFilial("SU5")+_CONTA1                  , "U5_CONTAT" ) 

				//@ nLin,080 PSay SubStr(_CONTA2,1,15)

		//		@ nLin,080 PSay SubStr(SA1->A1_CONTATO,1,30)
				@ nLin,111 PSay DtoC(SA1->A1_ULTCOM)
				
			EndIf

			SA1->(dbSkip()) 
			
			If lAbortPrint
				@ nLin,00 PSay STR0008 											// "*** CANCELADO PELO OPERADOR ***"
				Exit
			EndIf
		EndDo
		IncRegua()
	Next
	
//EndIf

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
