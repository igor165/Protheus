#Include "LOCR018.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RWMAKE.ch"
/*/
{PROTHEUS.DOC} LOCR018.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATORIO DE AUTORIZAÇÃO DE SERVIÇO
@TYPE    FUNCTION
@AUTHOR  FRANK ZWARG FUGA
@SINCE   03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
// ======================================================================= \\
Function LOCR018()
// ======================================================================= \\

// --> DECLARACAO DE VARIAVEIS.
Local   cDESC1      := STR0001 													// "ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO "
Local   cDESC2      := STR0002 													// "DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
Local   cDESC3      := STR0003 													// "AUTORIZAÇÃO DE SERVIÇO"
Local   TITULO      := STR0004 													// "RELATORIO DE AUTORIZAÇÃO DE SERVIÇO"
Local   cPerg       := "LOCR018" 												// "LOCP046"
Local   CABEC1      := ""
Local   CABEC2      := ""
Local   nLin        := 80
Local   IMPRIME 

Private aORD        := {STR0005} //,STR0006,STR0007,STR0008,STR0009} 				// "GESTOR" ### "CLIENTE" ### "PERIODO" ### "OBRA" ### "EQUIPAMENTO" 
Private lEND        := .F.
Private lABORTPRINT := .F.
Private lIMITE      := 220
Private TAMANHO     := "G"
Private NOMEPROG    := "LOCR018" 												// COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
Private nTIPO       := 15
Private aReturn     := {"ZEBRADO" , 1 , "ADMINISTRACAO" , 1 , 2 , 1 , "" , 1} 
Private nLastKey    := 0
Private CBTXT       := Space(10)
Private CBCONT      := 00
Private CONTFL      := 01
Private M_PAG       := 01
Private WNREL       := NOMEPROG 												// COLOQUE AQUI O NOME DO ARQUIVO USADO PARA IMPRESSAO EM DISCO
Private cString     := "FP0"
Private nMVPAR17    := 0 

IMPRIME := .T.

//ValidPerg(cPerg)
Pergunte(cPerg,.F.)

nMVPAR17 := MV_PAR17 															// --> 1=LOCACAO (FPA)   /   2=EQUIPAMENTO (FP4) 
nMVPAR17 := 1 																	// --> Forçar sempre 1=LOCACAO, em Set/2021 é o único disponivel para o RENTAL 

// --> MONTA A INTERFACE PADRAO COM O USUARIO...
WNREL := SetPrint(cString , NOMEPROG , cPerg , @TITULO , cDESC1 , cDESC2 , cDESC3 , .T. , aORD , .T. , TAMANHO , , .T.) 

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn , cString) 

If nLastKey == 27
	Return
EndIf

nTIPO := Iif(aReturn[4]==1 , 15 , 18) 

RptStatus({|| RUNREPORT(CABEC1 , CABEC2 , TITULO , nLin) } , TITULO) 

Return



// ======================================================================= \\
Static Function RUNREPORT(CABEC1 , CABEC2 , TITULO , nLin) 
// ======================================================================= \\

Local   cCOND    := aReturn[7]

Private _cFILIAL := cCodVen := ""
Private cPROJ    := cObra   := CSEQTRA := ""
Private nTotalG  := nTotal  := nTotalT := 0
Private cEQUIPTO := ""


// 						//            1         2         3         4         5         6         7         8         9       100       110       120       130       140       150        16        17        18        19        20        21        22
// 						//  01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
CABEC1 := STR0013  	// "           AS                CLIENTE                         OBRA  DT.INICIO   DT.TERM.    EQUIPAMENTO                VLR.BASE      VLR.MOB.      VLR.DESMOB.   PROX.FAT    ULT.FAT.    SOL.RETIR."
TAMANHO := "G"

QRYLOCR18()

dbSelectArea("TRB")

SetRegua(LastRec())
dbGoTop()

cCodVen   := TRB->FP0_VENDED
cCliente  := TRB->FP0_CLI 
_cPROJECT := ""

cPeriodo := TRB->FPA_DTINI

While !Eof()
	
	INCREGUA()
	
	If !Empty(CCOND)
		If !&CCOND
			dbSkip()
			Loop
		EndIf
	EndIf
	
	If     TRB->FP0_REVISA == "00"
		_cPROJECT := TRB->FP0_PROJET
		If TRB->FP0_STATUS == "A"  												// REVISADO
			dbSelectArea("TRB")
			dbSkip()
			Loop
		EndIf

	ElseIf TRB->FP0_STATUS == "5"
		If SubStr(_cPROJECT,1,11) <> SubStr(TRB->FP0_PROJET,1,11)	
			dbSelectArea("FP0")
			dbSetOrder(1)
			If dbSeek(TRB->FP0_FILIAL+SubStr(TRB->FP0_PROJET,1,11))
				If FP0->FP0_DATINC < MV_PAR13  .Or.  FP0->FP0_DATINC > MV_PAR14
					dbSelectArea("TRB")
					dbSkip()
					Loop
	   			EndIf
			EndIf
		EndIf
		dbSelectArea("TRB")

	Else
		dbSelectArea("TRB")
		dbSkip()
		Loop

	EndIf

	If lAbortPrint
		@ nLin,00 PSay STR0014 													// "*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	
	// --> IMPRESSAO DO CABECALHO DO RELATORIO. . . 
	If nLin > 55 																// SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 55 LINHAS...
		CABEC(TITULO , CABEC1 , CABEC2 , NOMEPROG , TAMANHO , nTIPO)
		nLin := 9
		@ nLin,00 PSay STR0015+TRB->FP0_VENDED+" - "+Posicione("SA3",1,xFilial("SA3")+TRB->FP0_VENDED , "A3_NOME") 		// "GESTOR: "
		nLin ++ 
	EndIf
	
	// REGRAS DE IMPRESSAO
	nRec := 0
	
	If cCodVen  <> TRB->FP0_VENDED
		QUEBRR18(@nLin)
	EndIf

	nTotal := TRB->FPA_VRHOR

	@ nLin,000 PSay TRB->FPA_PROJET  										
	@ nLin,014 PSay TRB->NUM_AS													// --> Campo: "AS"
	@ nLin,034 PSay SubStr(TRB->FP0_CLINOM,1,26) 								// --> Campo: "CLIENTE"

	@ nLin,062 PSay TRB->FPA_OBRA 											// --> Campo: "OBRA"
	@ nLin,067 PSay DtoC(StoD(TRB->FPA_DTINI)) 								// --> Campo: "DT.INICIO"
	@ nLin,079 PSay DtoC(StoD(TRB->FPA_DTFIM)) 								// --> Campo: "DT.TERM."
	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek(xFilial("ST9")+TRB->FPA_GRUA) 								// --> Campo: "EQUIPAMENTO"
		If !Empty(ST9->T9_CODFA) 
			@ nLin,091 PSay ST9->T9_CODFA 									// NOVA IMPRESSAO DO EQUIPAMENTO POR COD FANTASIA
		Else 
			@ nLin,091 PSay SubStr(TRB->FPA_DESGRU,1,25)
		EndIf 
	Else
		@ nLin,091 PSay SubStr(TRB->FPA_DESGRU,1,25)
	EndIf
	@ nLin,126 PSay TRB->FPA_VRHOR  Picture "@E 9,999,999.99" 				// --> Campo: "VLR.BASE"
	@ nLin,145 PSay TRB->FPA_GUIMON Picture "@E 9,999,999.99" 				// --> Campo: Frete ida
	@ nLin,168 PSay TRB->FPA_GUIDES Picture "@E 9,999,999.99" 				// --> Campo: Frete volta
	@ nLin,182 PSay DtoC(StoD(TRB->FPA_DTINI )) 							// --> Campo: "PROX.FAT"
	@ nLin,196 PSay DtoC(StoD(TRB->FPA_ULTFAT)) 							// --> Campo: "ULT.FAT."
	@ nLin,209 PSay DtoC(StoD(TRB->FPA_DTPRRT)) 							// --> Campo: "SOL.RETIR."
	
	nTotalG += nTotal 
	nTotalT += nTotal 
	
	dbSelectArea("TRB")
	dbSkip()
	nLin := nLin+1
EndDo 

nLin := nLin+1
@ nLin,000 PSay __PRTTHINLINE()
nLin := nLin+1
@ nLin,000 PSay __PRTRIGHT(STR0023+Transform(nTotalG , "@E 9,999,999,999,999.99"  ) ) 	// "VALOR TOTAL : "
nLin := nLin+1
@ nLin,000 PSay __PRTTHINLINE()
nLin := nLin+1
@ nLin,000 PSay __PRTRIGHT(STR0024+Transform(nTotalT , "@E 999,999,999,999,999.99") ) 	// "TOTAL GERAL : "
nLin := nLin+1
@ nLin,000 PSay __PRTTHINLINE()
nLin := nLin+1

// --> FINALIZA A EXECUCAO DO RELATORIO...
Set Device To Screen

// --> SE IMPRESSAO EM DISCO, CHAMA O GERENCIADOR DE IMPRESSAO...
If aReturn[5]==1
	DBCOMMITALL()
	Set Printer To
	OurSpool(WNREL)
EndIf

MS_FLUSH()

Return 



// ======================================================================= \\
Static Function QRYLOCR18()
// ======================================================================= \\
// --> FUNCAO PARA MONTAR OS TRANSPORTES E TIPOS DE TANSPORTES

If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
EndIf

cQuery     := " SELECT FP0_PROJET  , FP0_REVISA , FP0_TIPOSE  , FP0_TIPO   , FP0_STATUS , FP0_DATINC , FP0_HORINC , FP0_DTPARA , FP0_DTENVI , "   + CRLF
cQuery     += "        FP0_DTRETO  , FP0_DTVALI , FP0_CLI     , FP0_LOJA   , FP0_CLINOM , FP0_CLIEND , FP0_CLIMUN , FP0_CLIBAI , FP0_CLIEST , "   + CRLF
cQuery     += "        FP0_CLICEP  , FP0_CLICON , FP0_CLICGC  , FP0_CLIDEP , FP0_CLIEMA , FP0_CLIDDD , FP0_CLITEL , FP0_CLIFAX , FP0_VENDED , "   + CRLF
cQuery     += "        FP0_TIPOPR  , FP0_FILIAL , FPA_GUIMON  , FPA_GUIDES , FPA_VRHOR  , FPA_PROJET, "
cQuery 	   += "        FPA_OBRA    , FPA_SEQGRU , FPA_GRUA    , FPA_DESGRU , FPA_DTINI  , FPA_DTFIM  , FPA_VRMOB  , FPA_VRHOR  , FPA_VRDES  , "   + CRLF
cQuery     += "        FPA_MINDIA  , FPA_MINMES , FPA_PREDIA  , FPA_TIPOCA , FPA_DESMON , FPA_TELESC , FPA_ANCORA , FPA_GUIMON , FPA_MONTAG , "   + CRLF
cQuery     += "        FPA_ULTFAT As FPA_ULTFAT , FPA_DTPRRT As FPA_DTPRRT , FPA_AS    As NUM_AS "                                                + CRLF
cQuery     += " FROM   " + RetSQLName("FP0") + " FP0 "
cQuery     += "        LEFT OUTER JOIN " + RetSQLName("FPA") + " FPA ON FPA_PROJET = FP0_PROJET "                                                 + CRLF
cQuery     += " WHERE  FP0_VENDED BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + CRLF
cQuery     += "   AND  FP0_FILIAL BETWEEN '"+MV_PAR15+"' AND '"+MV_PAR16+"' " + CRLF
cQuery     += "   AND  FP0_PROJET BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + CRLF
cQuery     += "   AND  FP0_CLI    BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR07+"' " + CRLF
cQuery     += "   AND  FP0_LOJA   BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR08+"' " + CRLF
cQuery     += "   AND  ((FP0_STATUS IN ('5','A') AND FP0_REVISA = '00' )"     + CRLF
cQuery     += "      OR (FP0_STATUS ='5' AND FP0_REVISA <> '00')) "           + CRLF
cQuery     += "   AND  FP0.D_E_L_E_T_ = ' '  "                                + CRLF
cQuery     += "   AND  FPA_OBRA   BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " + CRLF
cQuery     += "   AND  FPA_GRUA   BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' " + CRLF
cQuery     += "   AND  FPA.D_E_L_E_T_ = ' ' "
cQuery     += "   AND  FPA_DTINI BETWEEN '"+DtoS(MV_PAR13)+"' AND '"+DtoS(MV_PAR14)+"' "
cQuery     += " AND FP0_TIPOSE = 'L' "                                         + CRLF 

cQuery += " ORDER BY FP0_VENDED , FP0_PROJET , FP0_REVISA"                 + CRLF 
 
cQuery := ChangeQuery(cQuery) 

TcQuery cQuery NEW ALIAS "TRB" 

Return 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ QUEBRR18 º AUTOR ³ IT UP BUSINESS     º DATA ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QUEBRR18(nLin)

nLin := nLin+1
@ nLin,000 PSay __PRTTHINLINE()
nLin := nLin+1
@ nLin,000 PSay __PRTRIGHT(STR0023+Transform(nTotalG , "@E 9,999,999,999,999.99") ) 								// "VALOR TOTAL : "
nLin := nLin+1
@ nLin,000 PSay __PRTTHINLINE()
nLin := nLin+2

@ nLin,00     PSay STR0015+TRB->FP0_VENDED+" - "+Posicione("SA3",1,xFilial("SA3")+TRB->FP0_VENDED , "A3_NOME") 	// "GESTOR: "
cCodVen      := TRB->FP0_VENDED

nLin := nLin + 1

nTotalG := 0

Return nLin 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ ValidPerg º AUTOR ³ IT UP BUSINESS     º DATA ³            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPSCIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg(cPerg) 
/*
Local _SALIAS := ALIAS()
Local aRegs   := {}
Local I,J
Local nTF     := Len(cFilAnt) 

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PadR(cPerg,10) 

//         {GRUPO,ORDEM,PERGUNT            ,PERSPA               ,PERENG             ,VARIAVEL,TIP,TAM,DEC,PRESEL,GSC,VALID                                    ,VAR01     ,DEF01,DEFSPA1,DEFENG1,CNT01,VAR02,DEF02,DEFSPA2,DEFENG2,CNT02,VAR03,DEF03,DEFSPA3,DEFENG3,CNT03,VAR04,DEF04,DEFSPA4,DEFENG4,CNT04,VAR05,DEF05,DEFSPA5,DEFENG5,CNT05,F3,PYME,GRPSXG,HELP,PICTURE})
aAdd(aRegs,{cPerg,"01" ,"Gestor de ?"      ,"¿De Administrador ?","From Manager ?"   ,"MV_CH1","C",06 ,0  ,0     ,"G",""                                       ,"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SA3" ,"S","","",""})
aAdd(aRegs,{cPerg,"02" ,"Gestor Ate ?"     ,"¿A Administrador ?" ,"To Manager ?"     ,"MV_CH2","C",06 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR02 >= MV_PAR01)","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SA3" ,"S","","",""})
aAdd(aRegs,{cPerg,"03" ,"Projeto de ?"     ,"¿De Proyecto ?"     ,"From Project ?"   ,"MV_CH3","C",16 ,0  ,0     ,"G",""                                       ,"MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","FP0T","S","","",""})
aAdd(aRegs,{cPerg,"04" ,"Projeto ate ?"    ,"¿A Proyecto ?"      ,"To Project ?"     ,"MV_CH4","C",16 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR04 >= MV_PAR03)","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","FP0T","S","","",""})
aAdd(aRegs,{cPerg,"05" ,"Cliente de ?"     ,"¿De Cliente ?"      ,"From Customer ?"  ,"MV_CH5","C",06 ,0  ,0     ,"G",""                                       ,"MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SA1" ,"S","","",""})
aAdd(aRegs,{cPerg,"06" ,"Loja de ?"        ,"¿De Tienda ?"       ,"From store ?"     ,"MV_CH6","C",02 ,0  ,0     ,"G",""                                       ,"MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPerg,"07" ,"Cliente ate ?"    ,"¿A Cliente ?"       ,"To Customer ?"    ,"MV_CH7","C",06 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR07 >= MV_PAR05)","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SA1" ,"S","","",""})
aAdd(aRegs,{cPerg,"08" ,"Loja ate ?"       ,"¿A Tienda ?"        ,"To store ?"       ,"MV_CH8","C",02 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR08 >= MV_PAR06)","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPerg,"09" ,"Obra de ?"        ,"¿De Obra ?"         ,"From work ?"      ,"MV_CH9","C",03 ,0  ,0     ,"G",""                                       ,"MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPerg,"10" ,"Obra Ate ?"       ,"¿A Obra ?"          ,"To Work ?"        ,"MV_CHA","C",03 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR10 >= MV_PAR09)","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPerg,"11" ,"Equipamento de ?" ,"¿De Equipamiento ?" ,"From Equipment ?" ,"MV_CHB","C",16 ,0  ,0     ,"G",""                                       ,"MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","ST9" ,"S","","",""})
aAdd(aRegs,{cPerg,"12" ,"Equipamento Ate ?","¿A Equipamiento ?"  ,"To Equipment ?"   ,"MV_CHC","C",16 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR12 >= MV_PAR11)","MV_PAR12","","","","","","","","","","","","","","","","","","","","","","","","","ST9" ,"S","","",""})
aAdd(aRegs,{cPerg,"13" ,"Periodo de ?"     ,"¿De Período ?"      ,"From period ?"    ,"MV_CHD","D",08 ,0  ,0     ,"G",""                                       ,"MV_PAR13","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPerg,"14" ,"Periodo ate ?"    ,"¿A Período ?"       ,"To period ?"      ,"MV_CHE","D",08 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR14 >= MV_PAR13)","MV_PAR14","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPerg,"15" ,"Filial de ?"      ,"¿De Sucursal ?"     ,"From Branch ?"    ,"MV_CHF","C",nTF,0  ,0     ,"G",""                                       ,"MV_PAR15","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
aAdd(aRegs,{cPerg,"16" ,"Filial Ate ?"     ,"¿A Sucursal ?"      ,"To Branch ?"      ,"MV_CHG","C",nTF,0  ,0     ,"G","NaoVazio() .And. (MV_PAR16 >= MV_PAR15)","MV_PAR16","","","","","","","","","","","","","","","","","","","","","","","","",""    ,"S","","",""})
//dd(aRegs,{cPerg,"17" ,"Tipo de Servico ?","¿Tipo de servicio ?","Type of Service ?","MV_CHH","N",01 ,0  ,0     ,"C",""                                       ,"MV_PAR17","Locacao","Asignación","Rental","","","Equipamento","Equipamiento","Equipment","","","","","","","","","","","","","","","","","","S","","",""})

For I:=1 To Len(aRegs)
	If SX1->(!dbSeek(cPerg+aRegs[I,2]))
		RecLock("SX1",.T.)
		For J:=1 To fCount() 
			If J <= Len(aRegs[I])
				FIELDPUT(J,aRegs[I,J])
			EndIf
		Next J 
		MsUnLock()
	EndIf
Next I 

dbSelectArea(_SALIAS)
*/
Return
