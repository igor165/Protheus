#Include "LOCR022.ch" 
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#Include "RWMAKE.ch"
/*/
{PROTHEUS.DOC} LOCR022.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATORIO DE PROJETOS
@TYPE    FUNCTION
@AUTHOR  FRANK ZWARG FUGA
@SINCE   03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
// ======================================================================= \\

Function LOCR022()
// ======================================================================= \\

// --> DECLARACAO DE VARIAVEIS
Local   cDESC1      := STR0001 													// "ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO "
Local   cDESC2      := STR0002 													// "DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
Local   cDESC3      := STR0003 													// "DISPONIBILIDADE DE FROTA"
Local   TITULO      := STR0004 													// "RELATORIO DE PROJETOS"
Local   cPERG       := "LOCR022" 												// "LOCP024"
Local   CABEC1      := ""
Local   CABEC2      := ""
Local   nLin        := 80
Local   IMPRIME 

Private aORD        := {STR0042,STR0043} 										// "PROJETO" ## "GESTOR"
Private lEND        := .F.
Private lABORTPRINT := .F.
Private lIMITE      := 220
Private TAMANHO     := "G"
Private NOMEPROG    := "LOCR022" 												// COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
Private nTIPO       := 15
Private aReturn     := { "ZEBRADO", 1, "ADMINISTRACAO", 1, 2, 1, "", 1}
Private nLastKey    := 0
Private CBTXT       := Space(10)
Private CBCONT      := 00
Private CONTFL      := 01
Private M_PAG       := 01
Private WNREL       := NOMEPROG 												// COLOQUE AQUI O NOME DO ARQUIVO USADO PARA IMPRESSAO EM DISCO
Private cString     := "FP0"

Private nMVPAR21    := 0 

IMPRIME := .T.

Pergunte(cPerg,.F.)

//nMVPAR21 := MV_PAR21 															// --> 1=LOCACAO (FPA)   /   2=EQUIPAMENTO (FP4) 
nMVPAR21 := 1 																	// --> Forçar sempre 1=LOCACAO, em Set/2021 é o único disponivel para o RENTAL 

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

// --> PROCESSAMENTO. RPTSTATUS MONTA JANELA COM A REGUA DE PROCESSAMENTO.
RptStatus({|| RUNREPORT(CABEC1 , CABEC2 , TITULO , nLin) } , TITULO) 

Return 



// ======================================================================= \\
Static Function RUNREPORT(CABEC1 , CABEC2 , TITULO , nLin) 
// ======================================================================= \\

Local   cCOND    := aReturn[7]
Local   cDescEqp := ""

Private cCodVen  := ""
Private cPROJET  := ""
Private cTipoSe  := cStatus := cPROJ := cOBRA := cSeqTra := "" 
Private cORIGEM  := cDESTIN := _PROJ := _OBRA := ""
Private nVRFRET  := nTotalG := nTotalGui := nTotalT := 0
Private nPERIOD  := 0

If     nMVPAR21 == 1 															// "LOCACAO"      (FPA) 
	TITULO  := STR0016 															// "RELATORIO DE PROJETOS - GRUAS "
	CABEC1  := STR0017 		// " PROJETO       CLIENTE                           TIPO           STATUS   OBRA  DT.INCL.  EQUIPAMENTO (COD FANTASIA)         VLR. LOCAÇÃO   MOB./DESMOB.   MONT./DESM.   INICIO    QTD.  ACESSO    TELESC.       VLR.   "
	CABEC2  := ""
	TAMANHO := "G"
EndIf

// --> GERA VOLUME DE DADOS PARA IMPRESSÃO. 
QRYLOCR22() 

dbSelectArea("TRB") 

// --> SETREGUA -> INDICA QUANTOS REGISTROS SERAO PROCESSADOS PARA A REGUA. 
SetRegua(LastRec()) 
dbGoTop() 

cCodVen := TRB->FP0_VENDED 
cPROJET := TRB->FP0_PROJET 

While !Eof()
	
	IncRegua() 
	
	If !Empty(cCOND) 
		If !&cCOND
			dbSkip()
			Loop
		EndIf
	EndIf
	If MV_PAR11 == 2 															// NAO QUEBRA POR OBRA / VIAGEM
		If _PROJ == TRB->FP0_PROJET
			dbSkip()
			Loop
		EndIf
	EndIf
	
	// --> VERIFICAR EQUIPAMENTO ANTES DA IMPRESSAO
		If TRB->FPA_GRUA   <= MV_PAR18 .And. TRB->FPA_GRUA   >= MV_PAR19 
			dbSkip()
			Loop
		EndIf
	
	// --> VERIFICAR OBRA ANTES DA IMPRESSAO
		If TRB->FPA_OBRA   <= MV_PAR14 .And. TRB->FPA_OBRA   >= MV_PAR15 
			dbSkip()
			Loop
		EndIf
	
	// --> VERIFICA O CANCELAMENTO PELO USUARIO...
	If lAbortPrint
		@ nLin,00 PSay STR0018 													// "*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	
	// --> IMPRESSAO DO CABECALHO DO RELATORIO...
	If nLin > 55 																// SALTO DE PÁGINA. NESTE CASO O FORMULARIO TEM 55 LINHAS...
		CABEC(TITULO , CABEC1 , CABEC2 , NOMEPROG , TAMANHO , nTIPO)
		nLin := 9
		If aReturn[8] == 2 														// --> Ordem: 
			@ nLin, 00 PSay STR0019+TRB->FP0_VENDED+" - "+Posicione("SA3",1,xFilial("SA3")+TRB->FP0_VENDED , "A3_NOME") //"GESTOR: "
			nLin := nLin + 1
		EndIf
	EndIf
	
	// --> REGRAS DE IMPRESSAO
	nRec  := 0
	cPROJ := TRB->FP0_PROJET

	Do Case
	Case TRB->FP0_STATUS == "1"
		cStatus := STR0020 														// "DIGITADO"
	Case TRB->FP0_STATUS == "2"
		cStatus := STR0021 														// "EM APROV"
	Case TRB->FP0_STATUS == "3"
		cStatus := STR0022 														// "APROVADO"
	Case TRB->FP0_STATUS == "4"
		cStatus := STR0023 														// "NÃO APROV"
	Case TRB->FP0_STATUS == "5"
		cStatus := STR0024 														// "FECHADO"
	Case TRB->FP0_STATUS == "6"
		cStatus := STR0025 														// "INDISPON"
	Case TRB->FP0_STATUS == "7"
		cStatus := STR0026 														// "REJEITADO"
	Case TRB->FP0_STATUS == "8"
		cStatus := STR0027 														// "FINALIZADO"
	Case TRB->FP0_STATUS == "A"
		cStatus := STR0028 														// "REVISADO"
	Case TRB->FP0_STATUS == "B"
		cStatus := STR0029 														// "EXCLUÍDO"
	Case TRB->FP0_STATUS == "C"
		cStatus := STR0030 														// "CANCELADO"
	Otherwise
		cStatus := TRB->FP0_STATUS 
	EndCase
	
	cTipoSe := "L"
	
		If aReturn[8] == 2 														// --> Ordem: 
			If cCodVen <> TRB->FP0_VENDED
				QUEBRR22(@nLin)
			EndIf
		EndIf
		@ nLin, 00 PSay TRB->FP0_PROJET
		@ nLin, 15 PSay SubStr(TRB->FP0_CLINOM,1,30)
		If     TRB->FP0_TIPO == "O" 
			@ nLin,050 PSay STR0031 											// "ORIENTATIVA"
		ElseIf TRB->FP0_TIPO == "E"
			@ nLin,050 PSay STR0032 											// "EFETIVA"
		EndIf
		@ nLin,065 PSay cStatus
		@ nLin,075 PSay TRB->FPA_OBRA
		@ nLin,080 PSay SubStr(TRB->FP0_DATINC,7,2)+"/"+SubStr(TRB->FP0_DATINC,5,2)+"/"+SubStr(TRB->FP0_DATINC,3,2)
		cDescEqp := Posicione("ST9" , 1 , xFilial("ST9")+TRB->FPA_GRUA , "T9_CODFA") 
		If !Empty(cDescEqp) 
			@ nLin,090 PSay SubStr(cDescEqp       ,1,30) 
		Else 
			@ nLin,090 PSay SubStr(TRB->FPA_DESGRU,1,30) 
		EndIf 
		
		nTotalGru := (TRB->FPA_PRCUNI * TRB->FPA_QUANT) - (TRB->FPA_VLBRUT*(TRB->FPA_PDESC/100)) + TRB->FPA_ACRESC + TRB->FPA_VRSEGU 

		@ nLin,125 PSay TRB->FPA_GUIMON  + TRB->FPA_GUIDES  Picture "@E 9,999,999.99"
		@ nLin,138 PSay SubStr(TRB->FPA_DTINI ,7,2)+"/"+SubStr(TRB->FPA_DTINI ,5,2)+"/"+SubStr(TRB->FPA_DTINI ,3,2)
		@ nLin,148 PSay TRB->FPA_ACRESC Picture "@E 9,999,999.99"
		@ nLin,162 PSay TRB->FPA_VLBRUT*(TRB->FPA_PDESC/100) Picture "@E 9,999,999.99"
		@ nLin,176 PSay TRB->FPA_VRSEGU Picture "@E 9,999,999.99"
		@ nLin,209 PSay nTotalGru Picture "@E 9,999,999.99"

		
		nTotalG += nTotalGru
		nTotalT += nTotalGru

	
	If MV_PAR10 == 1
		nRec := Recno()
		nLin := nLin+1
		@ nLin, 00 PSay STR0036 												// "FOLLOW UP:"

		// --> POSICIONA NA TABELA FP9 - FOLLOW UP
		dbSelectArea("FP9")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(xFilial()+cPROJ)
		@ nLin, 10 PSay Trim(FP9_FOLLOW)
		
		nLin := nLin+1
		@ nLin, 00 PSay Replicate("-",80)
		
		dbSelectArea("TRB")
		dbGoTo(nRec) 
	EndIf
	
	dbSelectArea("TRB")
	dbSkip()
	nLin := nLin+1
EndDo

If aReturn[8] == 2 																// --> Ordem: 
	nLin := nLin+1
	@ nLin,000 PSay __PRTTHINLINE()
	nLin := nLin+1
	@ nLin,000 PSay __PRTRIGHT(STR0037+Transform(nTotalG , "@E 9,999,999,999,999.99") ) 	// "VALOR TOTAL : "
EndIf
nLin := nLin+1
@ nLin,000 PSay __PRTTHINLINE()
nLin := nLin+1
@ nLin,000 PSay __PRTRIGHT(STR0038+Transform(nTotalT , "@E 999,999,999,999,999.99") ) 		// "TOTAL GERAL : "
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
Static Function QRYLOCR22()
// ======================================================================= \\
// --> FUNCAO PARA MONTAR OS TRANSPORTES E TIPOS DE TANSPORTES

If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea() 
EndIf

	cQuery := " SELECT FP0_PROJET , FP0_TIPOSE , FP0_TIPO   , FP0_STATUS , FP0_DATINC , FP0_HORINC , FP0_DTPARA , FP0_DTENVI , FP0_DTRETO , " + CRLF 
	cQuery += "        FP0_DTVALI , FP0_CLI    , FP0_LOJA   , FP0_CLINOM , FP0_CLIEND , FP0_CLIMUN , FP0_CLIBAI , FP0_CLIEST , FP0_CLICEP , " + CRLF 
	cQuery += "        FP0_CLICON , FP0_CLICGC , FP0_CLIDEP , FP0_CLIEMA , FP0_CLIDDD , FP0_CLITEL , FP0_CLIFAX , FP0_VENDED , FP0_TIPOPR , " + CRLF 
	cQuery += "        FPA_OBRA   , FPA_GRUA   , FPA_DESGRU , FPA_DTINI  , FPA_DTFIM  , FPA_VRMOB  , FPA_VRHOR  , FPA_VRDES  , FPA_MONTAG , " + CRLF 
	cQuery += "        FPA_DESMON , FPA_TELESC , FPA_ANCORA , FPA_GUIMON , FPA_MINDIA , FPA_MINMES , FPA_PREDIA , FPA_SEQGRU , FPA_GUIDES, "  + CRLF 
	cQuery += "        FPA_ACRESC , FPA_PDESC  , FPA_VLBRUT , FPA_VRSEGU , FPA_PRCUNI , FPA_QUANT "
	cQuery += " FROM " + RetSQLName("FP0") + " FP0 "                                                                                          + CRLF 
	cQuery += "        LEFT OUTER JOIN " + RetSQLName("FPA") + " FPA ON FPA_PROJET = FP0_PROJET "
cQuery     += " WHERE  FP0_PROJET BETWEEN '"+     MV_PAR01 +"' AND '"+     MV_PAR02 +"' "                                                     + CRLF 
cQuery     += "   AND  FP0_CLI    BETWEEN '"+     MV_PAR04 +"' AND '"+     MV_PAR05 +"' "                                                     + CRLF 
cQuery     += "   AND  FP0_LOJA   BETWEEN '"+     MV_PAR06 +"' AND '"+     MV_PAR07 +"' "                                                     + CRLF 
cQuery += "   AND  FP0_DATINC BETWEEN '"+DtoS(MV_PAR08)+"' AND '"+DtoS(MV_PAR09)+"' "                                                     + CRLF 
cQuery     += "   AND  FP0_FILIAL BETWEEN '"+     MV_PAR12 +"' AND '"+     MV_PAR13 +"' "                                                     + CRLF 
cQuery     += "   AND  FP0_VENDED BETWEEN '"+     MV_PAR16 +"' AND '"+     MV_PAR17 +"' "                                                     + CRLF 
	cQuery += "   AND  FP0.D_E_L_E_T_ = ' ' AND FPA.D_E_L_E_T_ = ' ' "                                                                        + CRLF 
// --> TIPO PROPOSTA
If     MV_PAR03 == 1 															// ORIENTATIVA
	cQuery += "   AND  FP0_TIPO = 'O' "                                                                                                       + CRLF 
ElseIf MV_PAR03 == 2     														// EFETIVA
	cQuery += "   AND  FP0_TIPO = 'E' "                                                                                                       + CRLF 
EndIf
	cQuery += "   AND  FP0_TIPOSE = 'L' "                                                                                                     + CRLF 
// --> ORDEM DO RELATORIO 
	If aReturn[8] == 1 															// --> Ordem: 
		cQuery += " ORDER BY FP0_PROJET , FPA_SEQGRU "                                                                                        + CRLF 
	Else
		cQuery += " ORDER BY FP0_VENDED "                                                                                                     + CRLF 
	EndIf

cQuery := ChangeQuery(cQUERY) 

TcQuery cQuery NEW ALIAS "TRB"

Return 



// ======================================================================= \\
Function LOCR02201(L1ELEM , lTipoRet)
// ======================================================================= \\

Local cTITULO  := "" 
Local MVPAR
Local MVPARDEF := "" 
Local nPOS , cTabCod 

Private aCAT   := {}

Default lTipoRet := .T.

L1ELEM := Iif(L1ELEM = Nil , .F. , .T.) 

If MV_PAR11==1
	cALIAS := ALIAS() 					 										// SALVA ALIAS ANTERIOR
	
	If lTipoRet
		MVPAR := &(AllTrim(READVAR()))		 									// CARREGA NOME DA VARIAVEL DO GET EM QUESTAO
		MVRET := AllTrim(READVAR())			 									// IGUALA NOME DA VARIAVEL AO NOME VARIAVEL DE RETORNO
	EndIf
	
	cTitulo := STR0039 															// "LOCAIS"
	
	dbSelectArea("FP2")
	dbSetOrder(2)
	If dbSeek(xFilial("FP2"))
		CURSORWAIT()
		While !Eof() .And. FP2->FP2_FILIAL==xFilial("FP2")
			aAdd(aCAT , FP2->FP2_CODIGO + " - " + AllTrim(FP2->FP2_DESCRI))
			MVPARDEF += AllTrim(FP2->FP2_CODIGO)
			dbSkip()
		EndDo
		CURSORARROW()
	Else
		MsgStop(STR0040 , STR0041) 												// "CADASTRO DE LOCAIS NÃO ENCONTRADO !!" ### "GPO - LOCR022.PRW"
		Return(.F.)
	EndIf
	
 //	F_OPCOES(	UVARRET			,;												// 01=VARIAVEL DE RETORNO
 //				cTitulo			,;												// 02=TITULO DA COLUNA COM AS OPCOES
 //				AOPCOES			,;												// 03=OPCOES DE ESCOLHA (ARRAY DE OPCOES)
 //				COPCOES			,;												// 04=STRING DE OPCOES PARA RETORNO
 //				NLIN1			,;												// 05=NAO UTILIZADO
 //				NCOL1			,;												// 06=NAO UTILIZADO
 //				L1ELEM			,;												// 07=SE A SELECAO SERA DE APENAS 1 ELEMENTO POR VEZ
 //				NTAM			,;												// 08=TAMANHO DA CHAVE
 //				NELEMRET		,;												// 09=NO MAXIMO DE ELEMENTOS NA VARIAVEL DE RETORNO
 //				LMULTSELECT		,;												// 10=INCLUI BOTOES PARA SELECAO DE MULTIPLOS ITENS
 //				LCOMBOBOX		,;												// 11=SE AS OPCOES SERAO MONTADAS A PARTIR DE COMBOBOX DE CAMPO ( X3_CBOX )
 //				CCAMPO			,;												// 12=QUAL O CAMPO PARA A MONTAGEM DO AOPCOES
 //				LNOTORDENA		,;												// 13=NAO PERMITE A ORDENACAO
 //				LNOTPESQ		,;												// 14=NAO PERMITE A PESQUISA
 //				LFORCERETARR    ,;												// 15=FORCA O RETORNO COMO ARRAY
 //				CF3				 )												// 16=CONSULTA F3
	
	If lTipoRet
		//         (     1 ,      2  ,   3  ,       4  ,  5 ,  6 ,     7  , 8 ,  9  ,10,11,12,13,14,15,16)
		If F_OPCOES(@MVPAR , cTitulo , aCAT , MVPARDEF , 12 , 49 , L1ELEM , 6 , 100 ,  ,  ,  ,  ,  ,  ,  )  	// CHAMA FUNCAO F_OPCOES
			nTamCod := 6
			cTabCod := ""
			For nPOS:=1 To Len(MVPAR) Step nTamCod
				If SubStr(MVPAR,nPOS,nTamCod) <> Replicate("*",nTamCod)
					If Empty(cTabCod)
						cTabCod += SubStr(MVPAR,nPOS,nTamCod)
					Else
						cTabCod += ","+SubStr(MVPAR,nPOS,nTamCod)
					EndIf
				EndIf
			Next
			&MVRET := cTabCod									 				// DEVOLVE RESULTADO
		EndIf
	EndIf
	
	dbSelectArea(cALIAS) 								 						// RETORNA ALIAS
	
EndIf

Return( If(lTipoRet , .T. , MVPARDEF) )



// ======================================================================= \\
Function LOCR02202(L1ELEM , lTipoRet)
// ======================================================================= \\

Local cTITULO  := ""
Local MVPAR
Local MVPARDEF := ""
Local nPOS , cTabCod

Private aCAT     := {}

Default lTipoRet := .T.

L1ELEM := Iif(L1ELEM = Nil , .F. , .T.) 

If MV_PAR11==1
	cALIAS := ALIAS() 					 										// SALVA ALIAS ANTERIOR
	
	If lTipoRet
		MVPAR := &(AllTrim(READVAR()))		 									// CARREGA NOME DA VARIAVEL DO GET EM QUESTAO
		MVRET := AllTrim(READVAR())			 									// IGUALA NOME DA VARIAVEL AO NOME VARIAVEL DE RETORNO
	EndIf
	
	cTitulo := STR0039 															// "LOCAIS"
	
	dbSelectArea("FP2")
	dbSetOrder(2)
	If dbSeek(xFilial("FP2"))
		CURSORWAIT()
		While !Eof() .And. FP2->FP2_FILIAL==xFilial("FP2")
			aAdd(aCAT , FP2->FP2_CODIGO + " - " + AllTrim(FP2->FP2_DESCRI))
			MVPARDEF += AllTrim(FP2->FP2_CODIGO)
			dbSkip()
		EndDo
		CURSORARROW()
	Else
		MsgStop(STR0040 , STR0041) 												// "CADASTRO DE LOCAIS NÃO ENCONTRADO !!" ### "GPO - LOCR022.PRW" 
		Return(.F.)
	EndIf
	
 //	F_OPCOES(	UVARRET			,;												// 01=VARIAVEL DE RETORNO
 //				cTitulo			,;												// 02=TITULO DA COLUNA COM AS OPCOES
 //				AOPCOES			,;												// 03=OPCOES DE ESCOLHA (ARRAY DE OPCOES)
 //				COPCOES			,;												// 04=STRING DE OPCOES PARA RETORNO
 //				NLIN1			,;												// 05=NAO UTILIZADO
 //				NCOL1			,;												// 06=NAO UTILIZADO
 //				L1ELEM			,;												// 07=SE A SELECAO SERA DE APENAS 1 ELEMENTO POR VEZ
 //				NTAM			,;												// 08=TAMANHO DA CHAVE
 //				NELEMRET		,;												// 09=NO MAXIMO DE ELEMENTOS NA VARIAVEL DE RETORNO
 //				LMULTSELECT		,;												// 10=INCLUI BOTOES PARA SELECAO DE MULTIPLOS ITENS
 //				LCOMBOBOX		,;												// 11=SE AS OPCOES SERAO MONTADAS A PARTIR DE COMBOBOX DE CAMPO ( X3_CBOX )
 //				CCAMPO			,;												// 12=QUAL O CAMPO PARA A MONTAGEM DO AOPCOES
 //				LNOTORDENA		,;												// 13=NAO PERMITE A ORDENACAO
 //				LNOTPESQ		,;												// 14=NAO PERMITE A PESQUISA
 //				LFORCERETARR    ,;												// 15=FORCA O RETORNO COMO ARRAY
 //				CF3				 )												// 16=CONSULTA F3
	
	If lTipoRet
		//         (     1 ,      2  ,   3  ,       4  ,  5 ,  6 ,     7  , 8 ,  9  ,10,11,12,13,14,15,16)
		If F_OPCOES(@MVPAR , cTitulo , aCAT , MVPARDEF , 12 , 49 , L1ELEM , 6 , 100 ,  ,  ,  ,  ,  ,  ,  )  	// CHAMA FUNCAO F_OPCOES
			nTamCod := 6
			cTabCod := ""
			For nPOS:=1 To Len(MVPAR) Step nTamCod
				If SubStr(MVPAR,nPOS,nTamCod)<>Replicate("*",nTamCod)
					If Empty(cTabCod)
						cTabCod += SubStr(MVPAR,nPOS,nTamCod)
					Else
						cTabCod += ","+SubStr(MVPAR,nPOS,nTamCod)
					EndIf
				EndIf
			Next
			&MVRET := cTabCod									 			// DEVOLVE RESULTADO
		EndIf
	EndIf
	
	dbSelectArea(cALIAS) 								 					// RETORNA ALIAS
EndIf

Return( Iif( lTipoRet , .T. , MVPARDEF ) )



// ======================================================================= \\
Static Function VLRACE(cPROJETO , cOBRA , CSEQGRU)
// ======================================================================= \\

Local nValor := 0

/*
dbSelectArea("ZAK")
dbSetOrder(1)
dbGoTop()
MsSeek(xFilial("ZAK") + cPROJETO + cOBRA + CSEQGRU)

While !Eof() .And. ZAK->ZAK_PROJET == cPROJETO .And. ZAK->ZAK_SEQGRU == CSEQGRU
	nValor += ZAK->ZAK_VRDIA
	dbSelectArea("ZAK")
	dbSkip()
EndDo
*/

Return(nValor)



// ======================================================================= \\
Static Function QUEBRR22(nLin , cOP) 
// ======================================================================= \\

nLin := nLin+1
@ nLin,000 PSay __PRTTHINLINE()
nLin := nLin+1
@ nLin,000 PSay __PRTRIGHT(STR0037+Transform(nTotalG , "@E 9,999,999,999,999.99") ) 							// "VALOR TOTAL : "
nLin := nLin+1
@ nLin,000 PSay __PRTTHINLINE()
nLin := nLin+2

If cOP == "V"
	@ nLin, 00 PSay STR0019+TRB->FP0_VENDED+" - "+Posicione("SA3",1,xFilial("SA3")+TRB->FP0_VENDED , "A3_NOME") // "GESTOR: "
	nLin := nLin + 1
	CCODVEN := TRB->FP0_VENDED
Else
	cPROJET := TRB->FP0_PROJET
EndIf

nTotalG := 0

Return nLin


