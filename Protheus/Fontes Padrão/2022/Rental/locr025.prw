#Include "LOCR025.ch" 
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#Include "RWMAKE.ch"
/*/
{PROTHEUS.DOC} LOCR025.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATORIO DE VENDAS
@TYPE    FUNCTION
@AUTHOR  FRANK ZWARG FUGA
@SINCE   03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
// ======================================================================= \\
Function LOCR025()
// ======================================================================= \\

// --> DECLARACAO DE VARIAVEIS
Local   cDESC1      := STR0001 													// "ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
Local   cDESC2      := STR0002 													// "EXIBINDO AS VENDAS POR PERÍODO, POR GESTOR, POR EQUIPAMENTO, POR FILIAL E POR TIPO DE SERVIÇO."
Local   cDESC3      := STR0003  												// "RELATÓRIO DE VENDAS"
Local   TITULO      := STR0004  												// "RELATÓRIO DE VENDAS DE REMOÇÕES"
Local   nLin        := 80
Local   CABEC1      := STR0005 		// "AS                           CLIENTE                                   MUNICIPIO/UF DA OBRA          EQUIPAMENTO   DIA   MÊS  TEMPO  BS CALC      VALOR BASE      MOB/DESMOB     TRANSP/PESO    VALOR SEGURO           TOTAL"
Local   CABEC2      := ""
Local   IMPRIME 

Private aORD        := {}
Private lEND        := .F.
Private lABORTPRINT := .F.
Private lIMITE      := 220
Private TAMANHO     := "G"
Private NOMEPROG    := "LOCR025" 												// COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
Private nTIPO       := 15
Private aReturn     := { STR0006, 1, STR0007, 1, 2, 1, "", 1} //"ZEBRADO"###"ADMINISTRACAO"
Private nLastKey    := 0
Private cPERG       := "LOCR025" 												// "LOCP050"
Private CBTXT       := Space(10)
Private CBCONT      := 00
Private CONTFL      := 01
Private M_PAG       := 01
Private WNREL       := NOMEPROG
Private cSTRING     := "FP0"

Private nMVPAR09    := 0 

IMPRIME := .T. 

//ValidPerg()
Pergunte(cPERG,.F.)

nMVPAR09 := MV_PAR09 															// --> 1=LOCACAO (FPA)   /   2=EQUIPAMENTO (FP4) 
nMVPAR09 := 1 																	// --> Forçar sempre 1=LOCACAO, em Set/2021 é o único disponivel para o RENTAL 

// --> MONTA A INTERFACE PADRAO COM O USUARIO... 
WNREL := SetPrint(cSTRING , NOMEPROG , cPERG , @TITULO , cDESC1 , cDESC2 , cDESC3 , .T. , aORD , .T. , TAMANHO , , .T.) 

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn , cSTRING)

If nLastKey == 27
	Return
EndIf

nTIPO := Iif(aReturn[4]==1 , 15 , 18) 

// --> PROCESSAMENTO. RPTSTATUS MONTA JANELA COM A REGUA DE PROCESSAMENTO.
RptStatus({|| RUNREPORT(CABEC1 , CABEC2 , TITULO , nLin) },TITULO)

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNCAO    ³ RUNREPORT º AUTOR ³ IT UP BUSINESS     º DATA ³ 12/12/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ FUNCAO AUXILIAR CHAMADA PELA RPTSTATUS. A FUNCAO RPTSTATUS º±±
±±º          ³ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RUNREPORT(CABEC1 , CABEC2 , TITULO , nLin) 

QRYLOCR25()

TITULO := AllTrim(TITULO) + STR0008 //" (SERVIÇO DE EQUIPAMENTOS "
TITULO += STR0009 + AllTrim(DtoC(MV_PAR01)) + STR0010 + AllTrim(DtoC(MV_PAR02)) //") - PERÍODO DE "###" A "

// --> SETREGUA -> INDICA QUANTOS REGISTROS SERAO PROCESSADOS PARA A REGUA
dbSelectArea("QRY")
SetRegua(RecCount())
dbGoTop()

_nVLRTOT := 0

While QRY->(!Eof())
	_cGestor := QRY->FP0_VENDED
	_cNomeGs := AllTrim(Posicione("SA3",1,xFilial("SA3")+QRY->FP0_VENDED,"A3_NOME"))
	_nVLRSUB := 0
	
	While QRY->(!Eof())  .And.  QRY->FP0_VENDED == _cGestor 
		If lAbortPrint
			@ nLin,00 PSay STR0011 //"*** CANCELADO PELO OPERADOR ***"
			Exit
		EndIf

		IncRegua()

		If nLin > 60 
	    	nLin := CABEC(TITULO , CABEC1 , CABEC2 , NOMEPROG , TAMANHO , nTIPO) 
			nLin ++         
			@ nLin,000 PSay __PRTTHINLINE()
	   		nLin ++
			//If _nVLRSUB > 0
			//	@ nLin,000 PSay __PRTRIGHT(STR0012 + _cGestor + "-" + _cNomeGs + Transform(_nVLRSUB, "@E 9,999,999,999,999.99")) //"SUB-TOTAL DO GESTOR "
			//EndIF
			@ nLin,000 PSay __PRTLEFT(STR0013 + _cGestor + "-" + _cNomeGs) //"GESTOR: "
			nLin ++     
			@ nLin,000 PSay __PRTTHINLINE()
	   		nLin += 2
	   	EndIf

		//nCALC := LOCA041(QRY->ZZZ_TIPOCA , QRY->ZZZ_VRHOR , QRY->ZZZ_PREDIA , QRY->ZZZ_MINDIA , QRY->ZZZ_MINMES , QRY->ZZZ_QTDIA , QRY->ZZZ_QTMES) 
		//nCALC += QRY->ZZZ_VRMOB + QRY->ZZZ_VRDES + QRY->ZZZ_VRSEGU + QRY->ZZZ_VRPESO 
    
		//nCALCT := 

		@ nLin,000 PSay QRY->FQ5_AS 
		@ nLin,029 PSay QRY->FP0_CLINOM 
		@ nLin,071 PSay QRY->FP1_MUNORI + "/" + QRY->FP1_ESTORI 
		@ nLin,101 PSay QRY->FPA_GRUA
		@ nLin,145 PSay QRY->ZZZ_VLBRUT   Picture "@E 9,999,999.99"
		@ nLin,158 PSay QRY->ZZZ_PDESC    Picture "@E 999,999.99"
		@ nLin,172 PSay QRY->ZZZ_ACRESC   Picture "@E 999,999.99"
		@ nLin,186 PSay QRY->ZZZ_VRHOR    Picture "@E 999,999.99"
		@ nLin,200 PSay QRY->ZZZ_VRMOB + QRY->ZZZ_VRDES  Picture "@E 999,999.99"
		@ nLin,210 PSay QRY->ZZZ_VRSEGU  Picture "@E 999,999.99"
		nLin ++

	   	dbSelectArea("QRY")
	   	dbSkip() 
	EndDo

	// --> IMPRIME O SUB-TOTAL DO GESTOR
	//If !Empty(_nVLRSUB)
		//@ nLin,000 PSay __PRTTHINLINE()
		//nLin ++             
		//@ nLin,000 PSay __PRTRIGHT(STR0018 + _cGestor + "-" + _cNomeGs + Transform(_nVLRSUB, "@E 9,999,999,999,999.99")) //"SUB-TOTAL DO GESTOR "
		//If QRY->(!Eof())
		//	nLin ++             
		//	@ nLin,000 PSay __PRTLEFT(STR0019 + _cGestor + "-" + _cNomeGs) //"GESTOR: "
		//	nLin += 2
		//EndIf			
		//nLin ++
		//@ nLin,000 PSay __PRTTHINLINE()
		//nLin += 2
	//EndIf
	_nVLRSUB := 0

EndDo

// --> IMPRIME O SUB-TOTAL DO GESTOR
/*
If !Empty(_nVLRTOT)
	@ nLin,000 PSay __PRTTHINLINE()
	nLin++
	@ nLin,000 PSay __PRTRIGHT(STR0020 + Transform(_nVLRTOT, "@E 9,999,999,999,999.99")) //"TOTAL GERAL"
	nLin++
	@ nLin,000 PSay __PRTTHINLINE()
EndIf
*/
// --> FINALIZA A EXECUCAO DO RELATORIO... 
Set Device To Screen

// --> SE IMPRESSAO EM DISCO, CHAMA O GERENCIADOR DE IMPRESSAO... 
If aReturn[5]==1
	dbCommitAll()
	Set Printer To
	OurSpool(WNREL)
EndIf

MS_FLUSH()

Return 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ QRYLOCR25 º AUTOR ³ IT UP BUSINESS     º DATA ³ 12/12/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ GERA INFORMACOES PARA IMPRESSAO                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QRYLOCR25() 

If Select("QRY") > 0
	dbSelectArea("QRY")
	dbCloseArea() 
EndIf 

cQUERY := "SELECT FQ5_SOT, FQ5_AS, FQ5_GUINDA, FQ5_OBRA, "                                                                          + CRLF 
cQUERY += "         FPA_PROJET As ZZZ_PROJET , FPA_AS     As ZZZ_AS     , FPA_TIPOCA As ZZZ_TIPOCA , FPA_VRHOR  As ZZZ_VRHOR  , "                  + CRLF 
cQUERY += "         FPA_PREDIA As ZZZ_PREDIA , FPA_MINDIA As ZZZ_MINDIA , FPA_MINMES As ZZZ_MINMES , 0          As ZZZ_QTDIA  , "                  + CRLF 
cQUERY += "         0          As ZZZ_QTMES  , FPA_TPISS  As ZZZ_TPISS  , FPA_VRISS  As ZZZ_VRISS  , FPA_VRSEGU As ZZZ_VRSEGU , "                  + CRLF 
cQUERY += "         FPA_VRPESO As ZZZ_VRPESO , FPA_GUIMON  As ZZZ_VRMOB  , FPA_GUIDES  As ZZZ_VRDES  , FPA_GRUA, "                                 + CRLF 
cQUERY += "         FPA_VLBRUT As ZZZ_VLBRUT , FPA_PDESC  As ZZZ_PDESC  , FPA_ACRESC  As ZZZ_ACRESC  ,  "                                          + CRLF 
cQUERY += "		    FP0_PROJET , FP0_REVISA , FP0_TIPOSE , FP0_TIPO   , FP0_STATUS , FP0_CLINOM , FP0.FP0_VENDED , "                               + CRLF 
cQUERY += "		    FP1_MUNORI , FP1_ESTORI  "                                                                                                    + CRLF 
cQUERY += "FROM     " + RetSQLName("FQ5") + " FQ5 "                                                                                                + CRLF 
cQUERY += "INNER JOIN " + RetSQLName("FP0") + " FP0 ON  FP0.FP0_PROJET = FQ5.FQ5_SOT	   AND  FP0.FP0_STATUS = '5'             AND " + CRLF 
cQUERY += "                                                            FP0.FP0_TIPOSE = 'L'            AND "                                       + CRLF 
cQUERY += "                                                            FP0.FP0_VENDED BETWEEN '"+     MV_PAR03 +"' AND '"+     MV_PAR04 +"'  AND " + CRLF 
cQUERY += "                                                            FP0.FP0_FILIAL BETWEEN '"+     MV_PAR07 +"' AND '"+     MV_PAR08 +"'  AND " + CRLF 
cQUERY += "                                                            FP0.D_E_L_E_T_ = ' ' "                                                      + CRLF 
cQUERY += "INNER JOIN " + RetSQLName("FPA") + " FPA ON  FPA.FPA_AS     = FQ5.FQ5_AS     AND  FPA.FPA_PROJET = FQ5.FQ5_SOT     AND " + CRLF 
cQUERY += "                                                           (FPA.FPA_DTAS   BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'  OR  " + CRLF 
cQUERY += "                                                            FPA.FPA_DTINI  BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"') AND " + CRLF 
cQUERY += "                                                            FPA.FPA_GRUA   BETWEEN '"+     MV_PAR05 +"' AND '"+     MV_PAR06 +"'  AND " + CRLF 
cQUERY += "                                                            FPA.D_E_L_E_T_ = ' ' "                                                      + CRLF 
cQUERY += "INNER JOIN " + RetSQLName("FP1") + " FP1 ON  FP1.FP1_PROJET = FQ5.FQ5_SOT	   AND  FP1.FP1_OBRA   = FQ5.FQ5_OBRA    AND " + CRLF 
cQUERY += "															   FP1.D_E_L_E_T_ = ' ' "                                                      + CRLF 

cQUERY += "WHERE    FQ5.D_E_L_E_T_ = ' ' "                                                                                                         + CRLF 
cQUERY += "ORDER BY FP0.FP0_VENDED , FQ5_SOT , FQ5.FQ5_AS "                                                                                        + CRLF 

cQUERY := ChangeQuery(cQUERY)

TCQUERY cQUERY NEW ALIAS "QRY"

Return 



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUN‡„O    ³ ValidPerg º AUTOR ³ AP5 IDE            º DATA ³ 07/05/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRI‡„O ³ VERIFICA A EXISTENCIA DAS PERGUNTAS CRIANDO-AS CASO SEJA   º±±
±±º          ³ NECESSARIO (CASO NAO EXISTAM).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg() 
/*
Local _SALIAS := ALIAS()
Local aRegs   := {}
Local I , J
Local nTF     := Len(cFilAnt) 

dbSelectArea("SX1")
dbSetOrder(1)
cPERG := PadR(cPERG,10)

//          GRUPO/ORDEM/PERGUNTA                                                   /VARIAVEL /TIP/TAM/DEC/PRESEL/GSC/VALID                                      /VAR01     /DEF01    /DEF01       /DEF01   /CNT01/VAR02        /DEF02        /DEF02         /DEF02      /CNT02/VAR03/DEF03/DEF03/DEF03/CNT03/VAR04/DEF04/DEF04/DEF04/CNT04/VAR05/DEF05/DEF05/DEF05/CNT05/F3   /PYME/SXG/HELP/PICTURE/IDFIL
aAdd(aRegs,{cPerg,"01" ,"Período de ?"     ,"¿De Período ?"      ,"From period ?"    ,"MV_CH1" ,"D",08 ,0  ,0     ,"G",""                                       ,"MV_PAR01",""       ,""          ,""      ,""   ,""           ,""           ,""            ,""         ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""  ,"" ,""  ,""           }) 
aAdd(aRegs,{cPerg,"02" ,"Período até ?"    ,"¿A Período ?"       ,"To Period ?"      ,"MV_CH2" ,"D",08 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR02 >= MV_PAR01)","MV_PAR02",""       ,""          ,""      ,""   ,""           ,""           ,""            ,""         ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""  ,"" ,""  ,""           }) 
aAdd(aRegs,{cPerg,"03" ,"Gestor de ?"      ,"¿De Administrador ?","From Manager ?"   ,"MV_CH3" ,"C",06 ,0  ,0     ,"G",""                                       ,"MV_PAR03",""       ,""          ,""      ,""   ,""           ,""           ,""            ,""         ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"SA3","S" ,"" ,""  ,""     ,""   }) 
aAdd(aRegs,{cPerg,"04" ,"Gestor Até ?"     ,"¿A Administrador ?" ,"To Manager ?"     ,"MV_CH4" ,"C",06 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR04 >= MV_PAR03)","MV_PAR04",""       ,""          ,""      ,""   ,""           ,""           ,""            ,""         ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"SA3","S" ,"" ,""  ,""     ,""   }) 
aAdd(aRegs,{cPerg,"05" ,"Equipamento de ?" ,"¿De Equipamiento ?" ,"From Equipment ?" ,"MV_CH5" ,"C",16 ,0  ,0     ,"G",""                                       ,"MV_PAR05",""       ,""          ,""      ,""   ,""           ,""           ,""            ,""         ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"ST9","S" ,"" ,""  ,""     ,""   }) 
aAdd(aRegs,{cPerg,"06" ,"Equipamento Até ?","¿A Equipamiento ?"  ,"To Equipment ?"   ,"MV_CH6" ,"C",16 ,0  ,0     ,"G","NaoVazio() .And. (MV_PAR06 >= MV_PAR05)","MV_PAR06",""       ,""          ,""      ,""   ,""           ,""           ,""            ,""         ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"ST9","S" ,"" ,""  ,""     ,""   }) 
aAdd(aRegs,{cPerg,"07" ,"Filial de ?"      ,"¿De Sucursal ?"     ,"From Branch ?"    ,"MV_CH7" ,"C",nTF,0  ,0     ,"G",""                                       ,"MV_PAR07",""       ,""          ,""      ,""   ,""           ,""           ,""            ,""         ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"S" ,"" ,""  ,""     ,""   }) 
aAdd(aRegs,{cPerg,"08" ,"Filial Até ?"     ,"¿A Sucursal ?"      ,"To Branch ?"      ,"MV_CH8" ,"C",nTF,0  ,0     ,"G","NaoVazio() .And. (MV_PAR08 >= MV_PAR07)","MV_PAR08",""       ,""          ,""      ,""   ,""           ,""           ,""            ,""         ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"S" ,"" ,""  ,""     ,""   }) 
//dd(aRegs,{cPerg,"09" ,"Tipo de Servico ?","¿Tipo de servicio ?","Type of Service ?","MV_CH9" ,"N",01 ,0  ,0     ,"C",""                                       ,"MV_PAR09","Locacao","Asignación","Rental",""   ,""           ,"Equipamento","Equipamiento","Equipment",""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,"S" ,"" ,""  ,""           }) 

For I:=1 To Len(aRegs)
	If !dbSeek(cPERG+aRegs[I,2])
        RecLock("SX1",.T.)
        For J:=1 To FCount()
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
