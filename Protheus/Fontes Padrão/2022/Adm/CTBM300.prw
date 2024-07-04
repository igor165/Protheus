#include "ctbm300.ch"
#include "protheus.ch"

Static __lBlind  := IsBlind()
Static __lConOutR	:= FindFunction( "CONOUTR" )
Static _oCtbm3001
Static _oCtbm3002

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ CTBM300  ณAutor  ณ Felipe Aurelio de Meloณ Data ณ 17/11/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Permitir copiar saldos analiticos ou sinteticos de uma     ณฑฑ
ฑฑณ          ณ determinada conta, cc, item ou classe de valor para um     ณฑฑ
ฑฑณ          ณ segundo tipo de saldo informado pelo usuario.              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Contabilidade Gerencial - Movimentacoes                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS/FNC  ณ  Motivo da Alteracao                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Jose Glez  ณ        ณ  MMI-5346 ณNumero de p๓liza debe ser consecutivoณฑฑ
ฑฑณ            ณ        ณ           ณpor mes.                             ณฑฑ
ฑฑณ  Marco A.  ณ28/05/18ณDMINA-2113 ณSe modifica funcion CTM103ProxDoc(), ณฑฑ
ฑฑณ            ณ        ณ           ณpara Numero de Poliza Consecutivo porณฑฑ
ฑฑณ            ณ        ณ           ณmes. (MEX)                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ctbm300(lAuto)

Local nOpca       := 0
Local aSays       := {}
Local aButt       := {}
Local aArea       := GetArea()
Local cPerg       := "CTBM30"
Local cProg       := "CTBM300"

Private cRetSX5SL := ""
Default lAuto     := .F.

//Guarda variaveis dos parametros em memoria
Pergunte(cPerg,.F.)

If IsBlind() .Or. lAuto
   If VldCtbm300(.T.)
		BatchProcess(STR0001,; //"C๓pia de saldos"
						 STR0002 + Chr(13) + Chr(10) +; //"Esta rotina tem como objetivo copiar um conjunto de lan็amentos ou saldos de um"
						 STR0003 + Chr(13) + Chr(10) +; //"tipo de saldo origem para um tipo de saldo destino. ษ possํvel c๓piar tanto os"
						 STR0004 + Chr(13) + Chr(10) +; //"lan็amentos contแbeis como os saldos por conta, centro de custo, item e classe"
						 STR0005 + Chr(13) + Chr(10) ,; //"de valor, de acordo com a informa็ใo dos parโmetros."
						 cProg,{|| ExeCtbm300(.T.) }, { || .F. })
	EndIf
Else
	aAdd(aSays, STR0002 )	// "Esta rotina tem como objetivo copiar um conjunto de lan็amentos ou saldos em um"
	aAdd(aSays, STR0003 )	// "tipo de saldo origem para um tipo de saldo destino. ษ possํvel c๓piar tanto os"
	aAdd(aSays, STR0004 )	// "lan็amentos contแbeis como dos saldos por conta, centro de custo, item e classe"
	aAdd(aSays, STR0005 )	// "de valor, de acordo com a sele็ใo do usuแrio."

	aAdd(aButt, { 5, .T., {|| Pergunte(cPerg,.T.) } } )
	aAdd(aButt, { 1, .T., {|| nOpca:= 1,IIf(VldCtbm300(.F.),FechaBatch(),nOpca:=0)}})
	aAdd(aButt, { 2, .T., {|| FechaBatch() }} )

	FormBatch(STR0001,aSays,aButt,,190) // Copia de saldos

	If nOpca == 1
		FWMsgRun(, {|oSay| ExeCtbm300(.F., oSay) }, STR0112, STR0113) // #"Processando" ##"Processando c๓pia de saldos..."
	EndIf
EndIf

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณExeCtbm300บAutor  ณ Felipe Aurelio de Meloบ Data ณ 17/11/08 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Executa processo de copia de registros                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial - Movimentacoes                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ExeCtbm300(lAuto, oSay)

Local lAnalitico  := MV_PAR07 = 2 // 1=Sintetico / 2=Analitico
Local lTdsMoedas  := MV_PAR11 = 1 // 1=Totas     / 2=Especificar
Local dDataIni    := MV_PAR09     // Data Inicial
Local dDataFim    := MV_PAR10     // Data Final
Local lAtuSld1    := .F.          // Indicar se atualiza saldos apos o exclusao dos lancamentos
Local lAtuSld2    := .F.          // Indicar se atualiza saldos apos o gravacao de lancamentos de saldo
Local lAtuSld3    := .F.          // Indicar se atualiza saldos apos o gravacao de lancamentos de movimentos
Local lConfirma   := .F.          // Indicar se confirma exclusao dos lancamentos
Local cMsg        := ""
Local x           := 0
Local lProcedure  := .F.
Local iX          := 0
Local lRet        := .T.
Local nProx       := 0
Local cArq        := ""
Local aProc       := {}
Local iRet        := 0
Local cExec       := ""
Local cNome       :=""
Local nMaxLinha   := IIf(GetMV("MV_NUMLIN")<1,999,CtbLinMax(GetMv("MV_NUMLIN")))
Local aDatabase	  :={}
Local cTDataBase  := ""
Local cTpSalDest  :=""

Default oSay := Nil

Private aResult   := {}

//Tratamento para caso usuแrio escolha
//metodo de copia = multiplos saldos 
If MV_PAR01 = 2
	MV_PAR02 := 2 //Sele็ใo dos saldos    = Mov. multi saldos
	MV_PAR05 := 1 //Metodo de copia       = Adicionar
	MV_PAR06 := 2 //Tipo de copia simples = Movimentos
	MV_PAR07 := 2 //Movimentos copiados   = Analiticos
	lAnalitico := .T.
EndIf

Do Case
	Case MV_PAR06 == 1  //Tipo de copia simples - saldos
		dDataIni := MV_PAR09
		dDataFim := MV_PAR10
	Case MV_PAR06 == 2  //Tipo de copia simples - movimentos
	    If lAnalitico
	    	dDataIni := MV_PAR09
	    Else
	    	dDataIni := MV_PAR10
	    EndIf
	Case MV_PAR06 == 3  //Tipo de copia simples - ambos
		dDataIni := MV_PAR09
EndCase
/*  O Processo sera executado via procedure nas situacoes abaixo
	1 - Copia simples de Movimentos ( Lancamentos ) com adicao de lancamentos
    2 - Copia de Multiplos Saldos
    3 - Se os cpos relativos a copia de multiplos saldos existir, CT2_CTLSLD, CT2_MLTSLD */

If TcSrvType() != 'AS/400'
	aadd(aDatabase,{"MSSQL" })
	aadd(aDatabase,{"MSSQL7" })
	aadd(aDatabase,{"ORACLE" })
	aadd(aDatabase,{"DB2" })
	aadd(aDatabase,{"SYBASE" })
//	aadd(aDatabase,{"INFORMIX" })
	If Trim(Upper(TcSrvType())) = "ISERIES"
		// Top 4 para AS400, instala procedures = DB2
		aadd(aDatabase,{"DB2/400"})
	EndIf
	cTDataBase = Trim(Upper(TcGetDb()))
	nPos:= Ascan( aDataBase, {|z| z[1] == cTDataBase })
	
	If nPos != 0 .and.;                           // bcos q instalam procedure
	  ((MV_PAR02 = 1 .and. mv_par05 = 1 .and. mv_par06 = 2 );  //copia simples, sem apagar lactos e de movitos, mv_par01=1, mv_par05=1,mv_par06=2
	   .or. mv_par02 = 2)                                       // copia Multiplos saldos   
		lProcedure := .T.
	EndIf
EndIf

If  CtbIsCube()
  lprocedure:= .F.
Endif  

 If lProcedure
	/* Nao tirar o comentario
	2.CTBM300PAI - Copia simples e Multiplos saldos de lancamentos. - aProc[11]
				   NAO FAZ copia pelos saldos das contas                      
		2.1 CTB300CTC    - Atualiza Cabecalho do Lote               - aProc[10]		   
		2.1 CTBM300DOC   - Proxima linha, documento e lote          - aProc[9]
		2.1.CTM300SOMA   - Cria a procedure SOMA1                   - aproc[8]
		2.1.CTBM300STR   - MSSTRZERO especifico                     - aProc[7]
		2.1 CTBM300CT7   - Atualizacao de saldos no CQ0/CQ1         - aProc[6]
		2.2 CTBM300CT3   - Atualizacao de saldos no CQ2/CQ3         - aProc[5]
		2.3 CTBM300CT4   - Atualizacao de saldos no CQ4/CQ5         - aProc[4]
		2.4 CTBM300CTI   - Atualizacao de saldos no CQ6/CQ7         - aProc[3]
	1.CTBM300LDAY - Lastday - Retorna o Ultimo dia do Mes           - aProc[2]
	0.CallXFILIAL - Cria a procedure xfilial                        - aProc[1]
	*/
	/* --------------------------------------------------------------------
		Criacao da Procedure Xfilial         - aProc[1]
	   -------------------------------------------------------------------- */
	nProx:= 1
	cNome := CriaTrab(,.F.)
	cArq := cNome+StrZero(nProx,2)
	AADD( aProc, cArq+"_"+cEmpAnt)           // aProc[1]
	lRet := CallXFILIAL(cArq)

	/* --------------------------------------------------------------------
		Criacao da Procedure LastDay         - aProc[2]
	   -------------------------------------------------------------------- */

	If lRet
		nProx:= nProx+1
		cArq := cNome+StrZero(nProx,2)
		AADD( aProc, cArq+"_"+cEmpAnt)        //aProc[2]
		lRet := CTBM300Lday(cArq, aProc)
	EndIf

	/* --------------------------------------------------------------------
		Criacao da Procedure de atualizacao do CQ7 - aProc[3]
	   -------------------------------------------------------------------- */
	nProx:= nProx + 1
	cNome := CriaTrab(,.F.)
	cArq := cNome+StrZero(nProx,2)
	AADD( aProc, cArq+"_"+cEmpAnt)           // aProc[3]
	lRet := CTBM300CTI(cArq, aProc)
	/* --------------------------------------------------------------------
		Criacao da Procedure de atualizacao do CQ5 - aProc[4]
	   -------------------------------------------------------------------- */
	If lRet
		nProx:= nProx+1
		cArq := cNome+StrZero(nProx,2)
		AADD( aProc, cArq+"_"+cEmpAnt)        //aProc[4]
		lRet := CTBM300CT4(cArq, aProc)
	EndIf
	/* --------------------------------------------------------------------
		Criacao da Procedure de atualizacao do CQ3 - aProc[5]
	   -------------------------------------------------------------------- */
	If lRet
		nProx:= nProx+1
		cArq := cNome+StrZero(nProx,2)
		AADD( aProc, cArq+"_"+cEmpAnt)        //aProc[6]
		lRet := CTBM300CT3(cArq, aProc)
	EndIf
	/* --------------------------------------------------------------------
		Criacao da Procedure de atualizacao do CT7 aProc[6]
	   -------------------------------------------------------------------- */
	If lRet
		nProx:= nProx+1
		cArq := cNome+StrZero(nProx,2)
		AADD( aProc, cArq+"_"+cEmpAnt)        //aProc[6]
		lRet := CTBM300CT7(cArq, aProc)
	EndIf
	/* --------------------------------------------------------------------
		Criacao da Procedure msstrzero para cada database aProc[7]
	   -------------------------------------------------------------------- */
	If lRet
		nProx:= nProx+1
		cArq := cNome+StrZero(nProx,2)
		AADD( aProc, cArq+"_"+cEmpAnt)        //aProc[7]
		lRet := CTBM300STR(cArq)
	EndIf
	/* --------------------------------------------------------------------
		Criacao da Procedure de geracao da proxima linha, doc,lote aProc[8]
	   -------------------------------------------------------------------- */
	If lRet
		nProx:= nProx+1
		cArq := cNome+StrZero(nProx,2)
		AADD( aProc, cArq+"_"+cEmpAnt)        //aProc[8]
		lRet := CTM300SOMA(cArq, aProc[7])
	EndIf	
	/* --------------------------------------------------------------------
		Criacao da Procedure de geracao da proxima linha, doc,lote aProc[9]
			Fara chamada a aProc[8]  e da aProc[7]
	   -------------------------------------------------------------------- */
	If lRet
		nProx:= nProx+1
		cArq := cNome+StrZero(nProx,2)
		AADD( aProc, cArq+"_"+cEmpAnt)        //aProc[9]
		lRet := CTBM300DOC(cArq, aProc)
	EndIf
	/* --------------------------------------------------------------------
		Criacao da Procedure Cabecalho do Movimento  aProc[10]
		Fara chamada a aProc[9]
	   -------------------------------------------------------------------- */
	If lRet
		nProx:= nProx+1
		cArq := cNome+StrZero(nProx,2)
		AADD( aProc, cArq+"_"+cEmpAnt)        //aProc[10]
		lRet := CTBM300CTC(cArq, aProc)
	EndIf 
	/* --------------------------------------------------------------------
		Criacao da Procedure movimentos  aProc[11]
		Fara chamada a aProc[9]
	   -------------------------------------------------------------------- */
	If lRet
		nProx:= nProx+1
		cArq := cNome+StrZero(nProx,2)
		AADD( aProc, cArq+"_"+cEmpAnt)        //aProc[11]
		lRet := CTBM300PAI(cArq, aProc)
	EndIf 

	/* --------------------------------------------------------------------
		Execucao da procedure principal
	   -------------------------------------------------------------------- */
	If lRet
		cTpSalDest := Trim(mv_par04)+"#"
		cTpSalDest := StrTran(cTpSalDest,";", "")
		 MsgRun( STR0081+ STR0082, STR0083, {||aResult := TCSPExec( xProcedures(cArq),;  //"Processando, ""aguarde..", "Copia de Saldos"
						cFilAnt,;                         			// Filial corrente
						Dtos(dDataIni),;                        			// data inicio para o processo
						Dtos(dDataFim),;                        			// Data final para o processo
 						If(lTdsMoedas, "1", "0" ),;       			// '1' tds as moedas serao processadas, '0' moeda especifica
						If(lTdsMoedas,"00",Trim(mv_par12)),; 		//moeda a processar 
						cTpSalDest,;                 			//Tipos de saldos DESTINOS para copia simples
						MV_PAR01,;                       			//1 - Copia Simples , 2 - Multiplos Saldos
						MV_PAR03,;                       			//Tipo de saldo Origem
						MV_PAR13,;                       			//1-Mantem Lote e Sblote do Lancto Origem, 2 - pega do parametro
						MV_PAR16,;                       			//1 - Mantem historico do lancamento, 2 - Pegar historico do CT8 ( @IN_MVPAR17 )
						If(Empty(MV_PAR17), " ", Trim(MV_PAR17)),; //1 - Codigo do historico padrao usado para copia de lanctos CT8_HIST
						If(Empty(MV_PAR14), " ", Trim(MV_PAR14)),; //Lote do parametro
						If(Empty(MV_PAR15), " ", Trim(MV_PAR15)),; //Sblote
						nMaxLinha,;                                 // Nro maximo de linhas
						If( MV_PAR01 = 1, '1','0')) } )                // Se copias simples envio '1'
		If Empty(aResult) .Or. aResult[1] = "0"
			If !__lBlind
				MsgAlert(tcsqlerror(),STR0084)  //"Erro na Copia de Saldos!"
			EndIf
			lRet := .F.	
		EndIf                                                                    									
		
	EndIf
	/* --------------------------------------------------------------------
		EXCLUSAO das procedures criadas para Copia
	   -------------------------------------------------------------------- */
	For iX = 1 to Len(aProc)
		If TCSPExist(aProc[iX])
			cExec := "Drop procedure "+aProc[iX]
			iRet := TcSqlExec(cExec)
			If iRet <> 0
				If !__lBlind
					MsgAlert(STR0100+aProc[iX] +STR0085) //"Erro na exclusao da Procedure: ",". Excluir manualmente no banco"
				EndIf	
			Endif
		EndIf
	Next
EndIf

If !lProcedure
	/* --------------------------------------------------------------------
		Execucao do processo sem as procedures
	   -------------------------------------------------------------------- */
	If MV_PAR05 == 2 .Or. MV_PAR05 == 3  // Metodo copia simples - 2=Sobrepor / 3=Apagar
		lConfirma := MsgYesNo( STR0101, STR0102 )
		If !lConfirma
			Return .T.
		EndIf

		lAtuSld1 := ApagaCtbm300( dDataIni, dDataFim, MV_PAR04, MV_PAR12, lTdsMoedas )
		If !lAtuSld1 .And. !lAuto
			Aviso( STR0006, STR0027, { "Ok" } )		//"Nใo foram encontrados lan็amentos para exclusใo."
		EndIf
	EndIf
		
	If MV_PAR05 != 3
		Do Case
			// Gera lancamentos de saldo ateh a data
			Case MV_PAR06 == 1  //Tipo de copia simples - saldos
				lAtuSld2 := CTM300Proc( lAnalitico, .T., lTdsMoedas, MV_PAR08 )
				If !lAtuSld2 .And. !lAuto
					Aviso( STR0006, STR0028, { "Ok" } )		// "Nใo foram encontrados lan็amentos de saldos at้ a data inicial informada."
				EndIf
	
			// Gera lancamentos analiticos ou sinteticos (saldos) no periodo
			Case MV_PAR06 == 2  //Tipo de copia simples - movimentos
				lAtuSld3 := CTM300Proc( lAnalitico, .F., lTdsMoedas, MV_PAR08 )
				If !lAtuSld3 .And. !lAuto
					Aviso( STR0006, STR0026, { "Ok" } )		// "Nใo foram encontrados movimentos no perํodo informado."
				EndIf
	
			// Gera lancamentos de saldo ateh a data e lancamentos analiticos ou sinteticos (saldos) no periodo
			Case MV_PAR06 == 3  //Tipo de copia simples - ambos
				lAtuSld2 := CTM300Proc( .F., .T., lTdsMoedas, MV_PAR08 )
				lAtuSld3 := CTM300Proc( lAnalitico, .F., lTdsMoedas, MV_PAR08 )
				If !lAtuSld2              	
					cMsg := STR0109 // "Nใo foram encontrados lan็amentos de saldos sinteticos at้ a data inicial informada."
				EndIf
				If !lAtuSld3
					cMsg := STR0024 //"Nใo foram encontrados lan็amentos de saldos ou movimentos no perํodo informado."
				EndIf
				If !Empty(cMsg) .And. !lAuto
					Aviso( STR0006, cMsg, { "Ok" } )
				EndIf
		EndCase
	EndIf
	
	If lAtuSld1 .Or. lAtuSld2 .Or. lAtuSld3
		If !lAuto .And. oSay != Nil
			oSay:SetText(STR0114) // "Executando reprocessamento de saldos para os lan็amentos gerados..."
		EndIf

		If MV_PAR01 = 2
			// Tratamento para caso usuแrio escolha metodo de copia = multiplos saldos
			// Executa o reprocessamento de saldos para os lancamentos gerados
			CTBA190( .T., dDataIni, dDataFim,,,"*", (MV_PAR11 == 2), Iif( (MV_PAR11 == 2), MV_PAR12, "" ), .F. )
		Else
			// Executa o reprocessamento de saldos para os lancamentos gerados
			For x:=1 To Len(MV_PAR04)
				If !(SubStr(MV_PAR04,x,1) $ "|;| |")
					CTBA190( .T., dDataIni, dDataFim,,,SubStr(MV_PAR04,x,1), (MV_PAR11 == 2), Iif( (MV_PAR11 == 2), MV_PAR12, "" ), .F. )
				EndIf
			Next x
		EndIf
	EndIf
EndIf	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณVldCtbm300บAutor  ณ Felipe Aurelio de Meloบ Data ณ 17/11/08 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Valida o preenchimento dos parametros da pergunta cPerg    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial - Movimentacoes                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VldCtbm300(lAuto)

Local x        := 1
Local lRet     := .T.
Local QtdParam := 17

For x:=1 To QtdParam
	lRet := PrmCtbm300(StrZero(x,2))
	If !lRet
		x:=QtdParam
	EndIf
Next x

//Pergunta se confirma configuracoes dos parametros
If lRet .And. !lAuto
	lRet := CtbOk()
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณPrmCtbm300บAutor  ณ Felipe Aurelio de Meloบ Data ณ 17/11/08 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Valida o preenchimento de cada parametro da pergunta cPerg บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial - Movimentacoes                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PrmCtbm300(cNumPar)

Local lRet    := .T.
Local cTexto1 := {}
Local cTexto2 := {}

Do Case
//----------------------------------------------------------
	Case cNumPar == "01"
		If lRet .And. Empty(MV_PAR01)
			ShowHelpDlg(STR0029, {STR0059,STR0076},5,{STR0046,STR0037},5) //"NAOVAZIO"###"O parโmetro 'm้todo de c๓pia' nใo foi"###"preenchido."###"Favor preencher o parโmetro 'm้todo de"###"c๓pia' com uma das op็๕es disponํveis."   
			lRet := .F.
		EndIf
		If lRet .And. MV_PAR01 = 1
			MV_PAR02 := 1
		EndIf
		If lRet .And. MV_PAR01 = 2
			MV_PAR02 := 2
			MV_PAR05 := 1
			MV_PAR06 := 2
			MV_PAR07 := 2
		EndIf

//----------------------------------------------------------
	Case cNumPar == "02"
		If lRet .And. Empty(MV_PAR02)
			ShowHelpDlg(STR0029, {STR0065,STR0076},5,{STR0047,STR0078},5)//"NAOVAZIO"###"O parโmetro 'sele็ใo dos saldos' nใo foi"###"preenchido."###"Favor preencher o parโmetro 'sele็ใo dos"###"saldos' com uma das op็๕es disponํveis."   
			lRet := .F.
		EndIf
		If lRet .And. MV_PAR01 = 1 .And. MV_PAR02 = 2
			cTexto1:= {STR0032,STR0079,STR0033,STR0050} //"A informa็ใo preenchida no parโmetro"###"'sele็ใo dos saldos' nใo ้ compatํvel com"###"a informa็ใo preenchida no parโmetro"###"'m้todo de copia'."
			cTexto2:= {STR0075,STR0035,STR0071,STR0069} //"Por escolher no parโmetro 'm้todo de "###"copia' a op็ใo 'copia simples', no "###"parโmetro 'sele็ใo dos saldos' deverแ"###" optar por 'parโmetros'."
			ShowHelpDlg(STR0030,cTexto1,5,cTexto2,5)//"INCOMPATIVEL"   
			lRet := .F.
		EndIf
		If lRet .And. MV_PAR01 = 2 .And. MV_PAR02 = 1
			cTexto1:= {STR0032,STR0079,STR0033,STR0050} //"A informa็ใo preenchida no parโmetro"###"'sele็ใo dos saldos' nใo ้ compatํvel com"###"a informa็ใo preenchida no parโmetro"###"'m้todo de copia'."
			cTexto2:= {STR0075,STR0036,STR0071,STR0068} //"Por escolher no parโmetro 'm้todo de "###"copia' a op็ใo 'm๚ltiplos saldos', no "###"parโmetro 'sele็ใo dos saldos' deverแ"###"optar por 'movimentos multi saldos'."
			ShowHelpDlg(STR0030,cTexto1,5,cTexto2,5)//"INCOMPATIVEL"  
			lRet := .F.
		EndIf
		
//----------------------------------------------------------
	Case cNumPar == "03"
		If lRet .And. MV_PAR01 = 1 .And. Empty(MV_PAR03)
			ShowHelpDlg(STR0029, {STR0063,STR0076},5,{STR0077,STR0048,STR0070},5) //"NAOVAZIO"###"O parโmetro 'saldo origem' nใo foi","preenchido."###"Quando o parโmetro 'm้todo de c๓pia' estแ"###"marcado como 'c๓pia simples' este"###"parโmetro passa a ser obrigat๓rio."
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "04"
		If lRet .And. MV_PAR01 = 1 .And. Empty(MV_PAR04)
			ShowHelpDlg(STR0029, {STR0064,STR0076},5,{STR0077,STR0048,STR0070},5) //"NAOVAZIO"###"O parโmetro 'saldos destinos' nใo foi"###"preenchido."###"Quando o parโmetro 'm้todo de c๓pia' estแ"###"marcado como 'c๓pia simples' este"###"parโmetro passa a ser obrigat๓rio."   
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "07"
		If lRet .And. MV_PAR07 = 1 .And. MV_PAR16 = 1 
			ShowHelpDlg(STR0029, {STR0053,STR0110},5,{STR0045,STR0111,STR0073,STR0061,STR0041},5) //"NAOVAZIO"###"O parโmetro "###"hist๓rico padrใo nใo pode ser Mante"###"Favor preencher o parโmetro em questใo,"###" com o conteudo de especificar hist๓rico"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'movimentos copiados'"###"esta marcado como 'sint้tico'."   
			lRet := .F.
		EndIf
		If lRet .And. MV_PAR01 = 1 .And. MV_PAR07 = 1 .And. Empty(MV_PAR17)
			ShowHelpDlg(STR0029, {STR0053,STR0034,STR0052},5,{STR0045,STR0073,STR0061,STR0041},5) //"NAOVAZIO"###"O parโmetro "###"'c๓digo de hist๓rico padrใo'"###" nใo foi preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'movimentos copiados'"###"esta marcado como 'sint้tico'."   
			MV_PAR16 := 2
			lRet := .T.
		EndIf
//----------------------------------------------------------
	Case cNumPar == "06"
		If lRet .And. MV_PAR01 = 1 .And. MV_PAR06 = 3 .And.  MV_PAR16 == 2 .And. Empty(MV_PAR17)
			ShowHelpDlg(STR0029, {STR0053,STR0034,STR0052},5,{STR0045,STR0073,STR0061,STR0041},5) //"NAOVAZIO"###"O parโmetro "###"'c๓digo de hist๓rico padrใo'"###" nใo foi preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'movimentos copiados'"###"esta marcado como 'sint้tico'."   
			lRet := .F.
		EndIf
				
//----------------------------------------------------------
	Case cNumPar == "09"
		If lRet .And. Empty(MV_PAR09)
			ShowHelpDlg(STR0029, {STR0055,STR0076},5,{STR0045,STR0074},5) //"NAOVAZIO"###"O parโmetro 'data inicial' nใo foi"###"preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio."   
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "10"
		If lRet .And. Empty(MV_PAR10)
			ShowHelpDlg(STR0029, {STR0054,STR0076},5,{STR0045,STR0074},5) //"NAOVAZIO"###"O parโmetro 'data final' nใo foi","preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio."
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "12"
		If lRet .And. MV_PAR11 = 2 .And. Empty(MV_PAR12)
			ShowHelpDlg(STR0029, {STR0062,STR0076},5,{STR0045,STR0073,STR0060,STR0039},5)//"NAOVAZIO"###"O parโmetro 'qual moeda' nใo foi","preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'moeda' esta marcado como"###"'especificar'."   
			lRet := .F.
		EndIf
		If lRet .And. !Empty(MV_PAR12)
			CTO->(DbSetOrder(1))
			If CTO->(!DbSeek(xFilial("CTO")+MV_PAR12))
				ShowHelpDlg(STR0031, {STR0067},5,{STR0043},5) //"NAOEXISTE"###"O registro escolhido nใo existe."###"Favor escolher um registro existente."
				lRet := .F.
			EndIf
		EndIf

//----------------------------------------------------------
	Case cNumPar == "14"
		If lRet .And. MV_PAR13 = 2 .And. Empty(MV_PAR14)
			ShowHelpDlg(STR0029, {STR0057,STR0052},5,{STR0045,STR0073,STR0058,STR0040},5)//"NAOVAZIO"###"O parโmetro 'lote contแbil'"###"nใo foi preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'lote e sub-lote contแbil'"###"esta marcado como 'especificar'."   
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "15"
		If lRet .And. MV_PAR13 = 2 .And. Empty(MV_PAR15)
			ShowHelpDlg(STR0029, {STR0066,STR0052},5,{STR0045,STR0073,STR0058,STR0040},5)//"NAOVAZIO"###"O parโmetro 'sub-lote contแbil'"###" nใo foi preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'lote e sub-lote contแbil'"###"esta marcado como 'especificar'."   
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "17"
		If lRet .And. MV_PAR16 = 2 .And. Empty(MV_PAR17)
			ShowHelpDlg(STR0029, {STR0053,STR0034,STR0052},5,{STR0045,STR0073,STR0056,STR0040},5)//"NAOVAZIO"###"O parโmetro "###"'c๓digo de hist๓rico padrใo'"###" nใo foi preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'hist๓rico padrใo'"###"esta marcado como 'especificar'."   
			lRet := .F.
		EndIf
		If lRet .And. !Empty(MV_PAR17)
			CT8->(DbSetOrder(1))
			If CT8->(!DbSeek(xFilial("CT8")+MV_PAR17))
				ShowHelpDlg(STR0031, {STR0067},5,{STR0043},5) //"NAOEXISTE"###"O registro escolhido nใo existe."###"Favor escolher um registro existente."
				lRet := .F.
			EndIf
		EndIf
		If lRet .And. MV_PAR01 = 1 .And. MV_PAR07 = 1 .And. Empty(MV_PAR17)
			ShowHelpDlg(STR0029, {STR0053,STR0034,STR0052},5,{STR0045,STR0073,STR0061,STR0041},5)//"NAOVAZIO"###"O parโmetro "###"'c๓digo de hist๓rico padrใo'"###" nใo foi preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'movimentos copiados'"###"esta marcado como 'sint้tico'."   
			MV_PAR16 := 2
			lRet := .F.
		EndIf


//----------------------------------------------------------
EndCase

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออออออออหออออัออออออออปฑฑ
ฑฑบPrograma  ณ ApagaCtbm300 บ Autor ณ Gustavo Henrique      บDataณ28/12/06บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออออออออสออออฯออออออออนฑฑ
ฑฑบDescricao ณ Exclui os lancamnetos da tabela CT2                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPD1 - Data inicial para exclusao dos lancamentos         บฑฑ
ฑฑบ          ณ EXPD2 - Data final para exclusao dos lancamentos           บฑฑ
ฑฑบ          ณ EXPC3 - Tipo de saldo de destino para selecao dos lanctos. บฑฑ
ฑฑบ          ณ EXPC4 - Indica se processa todas as moedas ou especifica   บฑฑ
ฑฑบ          ณ EXPC5 - Moeda informada para selecao dos lancamentos       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ApagaCtbm300( dDataIni, dDataFim, cTpSaldo, cMoeda, lTodas )
         
Local lRet		:= .T.         
                              
Local cArqTrb	:= ""
Local cIndex1	:= ""
Local cIndex2	:= ""

Local aKeyCTF	:= {}
Local aArea		:= GetArea()
Local aAreaCT2	:= CT2->(GetArea())
Local aAreaCTF	:= CTF->(GetArea())
Local aCampos  := {{ "NUMREC", "N", 17, 0 } , { "MOEDLC", "C", 2, 0 }}

If _oCtbm3001 <> Nil
	_oCtbm3001:Delete()
	_oCtbm3001 := Nil
Endif

_oCtbm3001 := FWTemporaryTable():New( "TRB" )  
_oCtbm3001:SetFields(aCampos) 
_oCtbm3001:AddIndex("1", {"MOEDLC"})

//------------------
//Cria็ใo da tabela temporaria
//------------------
_oCtbm3001:Create()  

Processa( { || lRet := SelLancCtbm300( dDataIni, dDataFim, cTpSaldo, cMoeda, lTodas ) },, STR0025 ) //"Selecionando lan็amentos para exclusใo..."
                       
If lRet
	Processa( { || PrcExclCtbm300( lTodas, cMoeda ) },, STR0015 )	//Excluindo lan็amentos no tipo de saldo de destino...
EndIf	

TRB->( dbCloseArea() )

//Deleta a tabela temporaria no banco de dados
If _oCtbm3001 <> Nil
	_oCtbm3001:Delete()
	_oCtbm3001 := Nil
Endif

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณSelLancCtbm300บAutor ณ Gustavo Henrique   บ Data ณ 28/12/06 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Seleciona os numeros de RECNO dos lancamentos contabeis no บฑฑ
ฑฑบ          ณ tipo de saldo de origem, para gravacao posterior no tipo   บฑฑ
ฑฑบ          ณ de saldo de destino selecionado nos parametros.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPD1 - Data inicial do periodo para selecao dos lanctos.  บฑฑ
ฑฑบ          ณ EXPD2 - Data final do periodo para selecao dos lanctos.    บฑฑ
ฑฑบ          ณ EXPC3 - Tipo de saldo de origem para selecao dos lanctos.  บฑฑ
ฑฑบ          ณ EXPC4 - Moeda especifica caso informado "Especifico" no    บฑฑ
ฑฑบ          ณ         parametro "Qual Moeda"                             บฑฑ
ฑฑบ          ณ EXPC5 - Indica se devem ser selecionadas todas as moedas   บฑฑ
ฑฑบ          ณ         ou apenas uma moeda especifica.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SelLancCtbm300( dDataIni, dDataFim, cTpSald, cMoeda, lTodas )
          
Local aArea		:= GetArea()
                      
Local cFilCT2	:= xFilial("CT2")
Local cDataIni	:= DtoS(dDataIni)
Local cDataFim	:= DtoS(dDataFim)
Local cQuery	:= ""

Local nCont		:= 0

Local lGrava	:= .T.
Local lPosMoeda	:= TRB->( FieldPos("MOEDLC") ) > 0
Local lRet

CT2->( dbSetOrder( 1 ) )

cQuery := "SELECT COUNT(R_E_C_N_O_) TOTREC "
cQuery += "  FROM " + RetSqlName("CT2") + " " 
cQuery += " WHERE CT2_FILIAL = '" + cFilCT2 + "' "
cQuery += "   AND CT2_DATA BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "

If Len( Alltrim(cTpSald)) == 1
	cQuery += "   AND CT2_TPSALD = '" + Alltrim( cTpSald ) + "'"
Endif

cQuery += "   AND CT2_CTLSLD <> '0'"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCT2",.T.,.F.)
nCont := TRBCT2->TOTREC
dbCloseArea()
dbSelectArea("CT2")
                          
ProcRegua( nCont )
                                                 
CT2->( MsSeek( cFilCT2 + cDataIni, .T. ) )

Do While CT2->( !EoF() .And. CT2_FILIAL == cFilCT2 .And. DtoS(CT2_DATA) <= cDataFim)
	IncProc()                                                                       

	If CT2_CTLSLD == '0'	
		CT2->( dbSkip() )
		Loop	
	Endif 

	If CT2->CT2_TPSALD $ cTpSald
		If !lTodas   
			If cMoeda == "01"
				lGrava := (CT2->CT2_MOEDLC == cMoeda)
			Else
				lGrava := CT2->( (CT2_MOEDLC == cMoeda .Or. CT2_MOEDLC == "01") )
			EndIf	
		EndIf
		If lGrava
			RecLock( "TRB", .T. )
			TRB->NUMREC := CT2->( Recno() )
			If lPosMoeda
				TRB->MOEDLC := CT2->CT2_MOEDLC
			EndIf	
			TRB->( MsUnlock() )
		EndIf	
	EndIf	

    If MV_PAR18 == 1
		RecLock( "CT2", .F. )
		CT2->CT2_CTLSLD := "0"
		CT2->( MsUnLock() )
    EndIf

	CT2->( dbSkip() )

EndDo
              
TRB->( dbGoTop() )

lRet := TRB->(!EoF())

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหอออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrcExclCtbm300บAutor ณ Gustavo Henrique บData ณ  15/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสอออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processa exclusao dos lancamentos gravados na tabela CT2   บฑฑ
ฑฑบ          ณ a partir do tipo de saldo destino informado nos parametros บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPL1 - Indica se deve processar todas as moedas           บฑฑ
ฑฑบ          ณ EXPC2 - Caso moeda especifica, recebe a moeda informada nosบฑฑ
ฑฑบ          ณ         parametros.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrcExclCtbm300( lTodas, cMoeda )

Local lOutMoeda := .F.

ProcRegua( TRB->(LastRec()) )

// Processa primeiro a exclusao das outras moedas
If lTodas .Or. (!lTodas .And. cMoeda <> "01")
	lOutMoeda := .T.
EndIf

TRB->(dbGoTop())
Do While TRB->(!EoF())

	IncProc()                

	//Se moeda escolhida for diferente de "01" ou se foi selecionada todas as moedas, primeiro excluir as outras moedas e pula quando for moeda "01"
	If lOutMoeda .AND. TRB->MOEDLC == "01" 
		TRB->( dbSkip() )		
	Endif

	CT2->( dbGoTo( TRB->NUMREC ) )
	If __lConOutR
		ConoutR( '1. Posicionou: ' + StrZero( TRB->NUMREC,10 ) + "|" + CT2->(  Strzero(Recno(),10) + "|" + Dtos( CT2_DATA ) + "|" + CT2_LOTE + "|" + CT2_SBLOTE + "|" + CT2_DOC + "|" + CT2_LINHA + "|" + CT2_DC + "|" + CT2_MOEDLC + "|TPSALD " + CT2_TPSALD + "|" + CT2_SEQLAN ) )
	EndIf

	CT2->( GravaLanc(CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_DC,CT2_MOEDLC,CT2_HP,CT2_DEBITO,;
			CT2_CREDIT,CT2_CCD,CT2_CCC,CT2_ITEMD,CT2_ITEMC,CT2_CLVLDB,CT2_CLVLCR,CT2_VALOR,CT2_HIST,;
			CT2_TPSALD,CT2_SEQLAN,5,.F.,,CT2_EMPORI,CT2_FILORI,,,,,,,.F. ) )

	If __lConOutR
		ConoutR( '1. Depois de excluir: ' + StrZero( TRB->NUMREC,10 ) + "|" + CT2->(  Strzero(Recno(),10) + "|" + Dtos( CT2_DATA ) + "|" + CT2_LOTE + "|" + CT2_SBLOTE + "|" + CT2_DOC + "|" + CT2_LINHA + "|" + CT2_DC + "|" + CT2_MOEDLC + "|TPSALD " + CT2_TPSALD + "|" + CT2_SEQLAN ) )
	EndIf

	TRB->( dbSkip() )

	If __lConOutR
		ConoutR( '1. Depois do skip: ' + StrZero( TRB->NUMREC,10 ) + "|" + CT2->( Strzero(Recno(),10) + "|" + Dtos( CT2_DATA ) + "|" + CT2_LOTE + "|" + CT2_SBLOTE + "|" + CT2_DOC + "|" + CT2_LINHA + "|" + CT2_DC + "|" + CT2_MOEDLC + "|TPSALD " + CT2_TPSALD + "|" + CT2_SEQLAN ) )
	EndIf
EndDo
                         
// Processa exclusao da moeda 01 para excluir chave da tabela CTF
If lTodas .Or. ( !lTodas .And. cMoeda <> "01" )
	TRB->( dbGoTop() )
	Do While TRB->(!EoF())
	
		IncProc()                     

		//Somente continua se a moeda for "01"
		If TRB->MOEDLC <> "01" 
			TRB->( dbSkip() )		
		Endif

		CT2->( dbGoTo( TRB->NUMREC ) )  

		If __lConOutR
			ConoutR( '2. Posicionou: ' + CT2->(  StrZero( TRB->NUMREC,10 ) + "|" + Strzero(Recno(),10) + "|" + Dtos( CT2_DATA ) + "|" + CT2_LOTE + "|" + CT2_SBLOTE + "|" + CT2_DOC + "|" + CT2_LINHA + "|" + CT2_DC + "|" + CT2_MOEDLC + "|TPSALD " + CT2_TPSALD + "|" + CT2_SEQLAN ) )
		endIf
		
		CT2->( GravaLanc(CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_DC,CT2_MOEDLC,CT2_HP,CT2_DEBITO,;
				CT2_CREDIT,CT2_CCD,CT2_CCC,CT2_ITEMD,CT2_ITEMC,CT2_CLVLDB,CT2_CLVLCR,CT2_VALOR,CT2_HIST,;
				CT2_TPSALD,CT2_SEQLAN,5,.F.,,CT2_EMPORI,CT2_FILORI,,,,,,,.F. ) )    
				
		If __lConOutR
			ConoutR( '2. Depois de excluir: ' + CT2->(  StrZero( TRB->NUMREC,10 ) + "|" + Strzero(Recno(),10) + "|" + Dtos( CT2_DATA ) + "|" + CT2_LOTE + "|" + CT2_SBLOTE + "|" + CT2_DOC + "|" + CT2_LINHA + "|" + CT2_DC + "|" + CT2_MOEDLC + "|TPSALD " + CT2_TPSALD + "|" + CT2_SEQLAN ) )
		EndIf
		
		TRB->( dbSkip() )  
		
		If __lConOutR
			ConoutR( '2. Depois do skip: ' + CT2->(  StrZero( TRB->NUMREC,10 ) + "|" + Strzero(Recno(),10) + "|" + Dtos( CT2_DATA ) + "|" + CT2_LOTE + "|" + CT2_SBLOTE + "|" + CT2_DOC + "|" + CT2_LINHA + "|" + CT2_DC + "|" + CT2_MOEDLC + "|TPSALD " + CT2_TPSALD + "|" + CT2_SEQLAN ) )
		EndIf
	EndDo
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CTM300Proc บ Autor ณ Gustavo Henrique บ Data ณ  15/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera lancamentos contabeis no tipo de saldo de destino a   บฑฑ
ฑฑบ          ณ partir dos movimentos ou saldos no tipo de saldo de origem บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPL1 - Indica se o processamento eh analitico (de CT2 paraบฑฑ
ฑฑบ          ณ CT2) ou sintetico (de CT7,CQ3,CQ5 ou CQ7) para CT2.        บฑฑ
ฑฑบ          ณ EXPL2 - Indica se deve processar saldo ou movimento.       บฑฑ
ฑฑบ          ณ EXPL3 - Indica se processa todas as moedas ou especifica.  บฑฑ
ฑฑบ          ณ EXPN4 - A partir de que nivel deve compor os lancamentos.  บฑฑ
ฑฑบ          ณ Utilizado apenas para processamento sintetico.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300Proc( lAnalitico, lSaldo, lTodas, nNivel )
                                    
Local aArea		:= GetArea()
Local aAreaCT2	:= CT2->( GetArea() )
Local aAreaCQ1	:= CQ1->( GetArea() )
Local aCtaProc	:= {}
Local aCampos	:= {}                  
Local aStruct	:= {} 
Local aTamVlr	:= TamSX3("CQ1_DEBITO")

Local cArqTrb	:= ""
Local cArqInd1	:= ""
Local cArqInd2	:= ""
Local cMsgProc	:= ""   

Local lClVl		:=	CtbMovSaldo("CTH")
Local lItem		:=	CtbMovSaldo("CTD")
Local lCusto	:= CtbMovSaldo("CTT")
Local lRet		:= .T.

If lAnalitico

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Executa selecao e gravacao dos movimentos analiticos (CT2 para CT2)					  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AAdd( aStruct, { "NUMREC", "N", 17, 0 }  )

	If _oCtbm3002 <> Nil
		_oCtbm3002:Delete()
		_oCtbm3002 := Nil
	Endif
	
	_oCtbm3002 := FWTemporaryTable():New( "TRB" )  
	_oCtbm3002:SetFields(aStruct) 
	_oCtbm3002:AddIndex("1", {"NUMREC"})
				
	//------------------
	//Cria็ใo da tabela temporaria
	//------------------
	_oCtbm3002:Create()


	Processa( { || lRet := CTM300SelLanc( mv_par09, mv_par10, mv_par03, mv_par12, lTodas ) },, STR0020 )
	If lRet
		Processa( { || CTM300GrvLanc( lTodas, mv_par12 ) },, STR0021 )	// "Gravando lan็amentos no tipo de saldo destino..."
	EndIf	
	dbSelectArea( "CT2" )
	TRB->( dbCloseArea() )

	If _oCtbm3002 <> Nil
		_oCtbm3002:Delete()
		_oCtbm3002 := Nil
	Endif

Else	// Sinteticos

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Executa selecao e gravacao dos saldos e/ou movimentos sinteticos (CQ1, CQ3, CQ5, CQ7) ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aCampos := {{"IDENT"    ,"C", 3, 0},;
               {"CONTA"    ,"C",Len(CriaVar("CT1_CONTA")),0},;
               {"CUSTO"    ,"C",Len(CriaVar("CTT_CUSTO")),0},;
               {"ITEM"     ,"C",Len(CriaVar("CTD_ITEM")),0},;
               {"CLVL"     ,"C",Len(CriavAr("CTH_CLVL")),0},;
               {"CREDIT"   ,"N",aTamVlr[1],aTamVlr[2]},;
               {"DEBITO"   ,"N",aTamVlr[1],aTamVlr[2]},;
               {"TPSALDO"  ,"C",1,0},;
               {"MOEDA"    ,"C",2,0}}

	If _oCtbm3002 <> Nil
		_oCtbm3002:Delete()
		_oCtbm3002 := Nil
	Endif
	
	_oCtbm3002 := FWTemporaryTable():New( "TRB" )  
	_oCtbm3002:SetFields(aCampos) 
	_oCtbm3002:AddIndex("1", {"TPSALDO","MOEDA","CONTA","CUSTO","ITEM","CLVL","IDENT"})
	_oCtbm3002:AddIndex("2", {"TPSALDO","MOEDA","IDENT","CONTA","CUSTO","ITEM","CLVL"})
				
	//------------------
	//Cria็ใo da tabela temporaria
	//------------------
	_oCtbm3002:Create()
    
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Gera lancamentos temporarios no tipo de saldo de origem e no nivel selecionado ณ
	//ณ na pergunta "Ate o nivel?". 1=Conta; 2=C.Custo; 3=Item; 4=Classe               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lClVl .And. nNivel == 4
		cMsgProc := STR0011 + RTrim(CtbSayApro("CTH")) + " ..."	// Selecionando saldos por Classe
		Processa( { ||	CTM300SelSint( lSaldo, "CQ7", mv_par09, mv_par10, mv_par12, mv_par03, lCusto, lItem, lClvl, lTodas, nNivel ) },, cMsgProc )
	EndIf
	
	If lItem .And. nNivel >= 3	
		cMsgProc := STR0011 + RTrim(CtbSayApro("CTD")) + " ..."	// Selecionando saldos por Item
		Processa( { || CTM300SelSint( lSaldo, "CQ5", mv_par09, mv_par10, mv_par12, mv_par03, lCusto, lItem, lClvl, lTodas, nNivel ) },, cMsgProc )
	EndIf
	
	If lCusto .And. nNivel >= 2	
		cMsgProc := STR0011 + RTrim(CtbSayApro("CTT")) + " ..." 	// Selecionando saldos por C.Custo ...
		Processa( { || CTM300SelSint( lSaldo, "CQ3", mv_par09, mv_par10, mv_par12, mv_par03, lCusto, lItem, lClvl, lTodas, nNivel ) },, cMsgProc )
	EndIf
	
	cMsgProc := STR0011 + STR0023 + " ..."	// Selecionando saldos por Conta ...
	Processa( { || CTM300SelSint( lSaldo, "CQ1", mv_par09, mv_par10, mv_par12, mv_par03, lCusto, lItem, lClvl, lTodas, nNivel ) },, cMsgProc )	
                     
	TRB->( dbGoTop() )
	lRet := TRB->( !EoF() )
	
	If lRet

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Calcula a data para gravacao dos lancamentos na tabela CT2                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lSaldo
			dDataLanc := mv_par09 - 1	// Dia anterior a data inicial informada 
		Else
			dDataLanc := mv_par10		// Data final do periodo informado
		EndIf		

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Gera lancamentos contabeis no tipo de saldo de destino                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Processa( { || CTM300GrvSint( dDataLanc, mv_par14, mv_par15, mv_par12, mv_par04, mv_par17 ) },, STR0021 )	// Gravando lan็amentos no tipo de saldo destino...	
		
	EndIf	

	dbSelectArea("TRB")
	dbCloseArea()

	If _oCtbm3002 <> Nil
		_oCtbm3002:Delete()
		_oCtbm3002 := Nil
	Endif

	dbSelectArea("CT2")

EndIf

RestArea( aArea )
RestArea( aAreaCT2 )
RestArea( aAreaCQ1 )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณCTBM300SelLancบAutor ณ Gustavo Henrique   บ Data ณ 28/12/06 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Seleciona os numeros de RECNO dos lancamentos contabeis no บฑฑ
ฑฑบ          ณ tipo de saldo de origem, para gravacao posterior no tipo   บฑฑ
ฑฑบ          ณ de saldo de destino selecionado nos parametros.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPD1 - Data inicial do periodo para selecao dos lanctos.  บฑฑ
ฑฑบ          ณ EXPD2 - Data final do periodo para selecao dos lanctos.    บฑฑ
ฑฑบ          ณ EXPC3 - Tipo de saldo de origem para selecao dos lanctos.  บฑฑ
ฑฑบ          ณ EXPC4 - Moeda especifica caso informado "Especifico" no    บฑฑ
ฑฑบ          ณ         parametro "Qual Moeda"                             บฑฑ
ฑฑบ          ณ EXPC5 - Indica se devem ser selecionadas todas as moedas   บฑฑ
ฑฑบ          ณ         ou apenas uma moeda especifica.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300SelLanc( dDataIni, dDataFim, cTpSald, cMoeda, lTodas )
          
Local aArea		:= GetArea()
                      
Local cFilCT2	:= xFilial("CT2")
Local cDataIni	:= DtoS(dDataIni)
Local cDataFim	:= DtoS(dDataFim)
Local cQuery	:= ""

Local nCont		:= 0

Local lGrava	:= .T.
Local lPosMoeda	:= TRB->( FieldPos("MOEDLC") ) > 0
Local lRetLanc

CT2->( dbSetOrder( 1 ) )

cQuery := "SELECT COUNT(R_E_C_N_O_) TOTREC "
cQuery += "FROM " + RetSqlName("CT2") + " " 
cQuery += "WHERE "
cQuery += "    CT2_FILIAL = '" + cFilCT2 + "' "
cQuery += "AND CT2_DATA BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCT2",.T.,.F.)
nCont := TRBCT2->TOTREC
dbCloseArea()
dbSelectArea("CT2")
                          
ProcRegua( nCont )

CT2->( MsSeek( cFilCT2 + cDataIni, .T. ) )

Do While CT2->( !EoF() .And. CT2_FILIAL == cFilCT2 .And. DtoS(CT2_DATA) <= cDataFim )
	IncProc()
	If CT2->CT2_TPSALD $ cTpSald
		If !lTodas   
			If cMoeda == "01"
				lGrava := (CT2->CT2_MOEDLC == cMoeda)
			Else
				lGrava := CT2->( (CT2_MOEDLC == cMoeda .Or. CT2_MOEDLC == "01") )
			EndIf	
		EndIf
		If lGrava
			RecLock( "TRB", .T. )
			TRB->NUMREC := CT2->( Recno() )
			If lPosMoeda
				TRB->MOEDLC := CT2->CT2_MOEDLC
			EndIf	
			TRB->( MsUnlock() )
		EndIf	
	EndIf	
	CT2->( dbSkip() )
EndDo
              
TRB->( dbGoTop() )

lRetLanc := TRB->(!EoF())

RestArea( aArea )

Return lRetLanc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCTBM300GrvLancบAutor ณ Gustavo Henrique บ Data ณ 28/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Grava lancamentos analiticos a partir dos registros que jahบฑฑ
ฑฑบ          ณ foram gravados em arquivo temporario.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPL1 - Indica se deve processar todas as moedas           บฑฑ
ฑฑบ          ณ EXPC2 - Caso moeda especifica, recebe a moeda informada nosบฑฑ
ฑฑบ          ณ         parametros.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300GrvLanc( lTodas, cMoeda )

Local nX		   := 0
Local nInc		:= 0
Local nCpos		:= CT2->(FCount())
Local CTF_LOCK	:= 0
Local nPosLinha:= 0
Local nPosLote	:= 0
Local nPosSLote:= 0
Local nPosDoc	:= 0
Local nPosTPSal:= 0
Local nPosCtSal:= 0
Local cLote		:= ""
Local cSubLote	:= ""
Local cDoc		:= ""
Local cDocOri	:= ""
Local cLoteOri	:= ""
Local cDataOri	:= ""
Local cTpSldOri:= ""
Local cMtSldOri:= ""
Local lSemValor:= (!lTodas .And. cMoeda <> "01")
Local cHistPadr:= IIf(MV_PAR16=1,"",MV_PAR17)
Local aDadosCT2:= {}
Local aTpSaldos:= {}
Local lMltSaldos:= .F.
Local lFirst := .T.
Local nLinha := 1
Local cLinha := StrZero(nLinha,3)
Local cLinIncl := cLinha
Local dDtLanc:= StoD("")
Local nMaxLinha:= IIf(GetMV("MV_NUMLIN")<1,999,CtbLinMax(GetMv("MV_NUMLIN")))
Local cUltLanc := ""

aDadosCT2 := Array(nCpos)
		
nPosHP     := CT2->( FieldPos( "CT2_HP" ) )
nPosHist   := CT2->( FieldPos( "CT2_HIST" ) )
nPosLinha  := CT2->( FieldPos( "CT2_LINHA" ) )
nPosLote   := CT2->( FieldPos( "CT2_LOTE" ) )
nPosSLote  := CT2->( FieldPos( "CT2_SBLOTE" ) )
nPosDoc    := CT2->( FieldPos( "CT2_DOC" ) )
nPosTPSal  := CT2->( FieldPos( "CT2_TPSALD" ) )
nPosValor  := CT2->( FieldPos( "CT2_VALOR" ) )
nPosCtSal  := CT2->( FieldPos( "CT2_CTLSLD" ) )
nPosRecno  := CT2->( FieldPos( "R_E_C_N_O_" ) )

lMltSaldos := MV_PAR01==2

//DbSelectArea( "CT2" )
//DbGoTop()

DbSelectArea( "TRB" )
ProcRegua( TRB->(LastRec()))
		
TRB->( dbGoTop() )                          
	    
Do While TRB->(!EoF())

	IncProc()                  

	// Volta ao registro de origem 		        
    CT2->( dbGoTo( TRB->NUMREC ) )
    

    If MV_PAR18 == 1 .OR. MV_PAR05 == 2
		RecLock( "CT2", .F. )
		CT2->CT2_CTLSLD := "0"
		CT2->( MsUnLock() )
    EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณse o parametro (Multiplos Tipos de Saldos) for igual a desconsidera   ณ
	//ณentao deve seguir o fluxo normal.                                     ณ
	//ณ                                                                      ณ
	//ณse controla deve copiar para todos os tipos de saldos escolhidos.     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If MV_PAR01 == 1

		cTpSldOri := AllTrim(CT2->CT2_TPSALD) //Variavel criada para comparar com registro a ser criado
		cMtSldOri := AllTrim(StrTran(StrTran(CT2->CT2_MLTSLD,";",""),cTpSldOri,"")) //Variavel criada para tratar um possivel erro

		If (CT2->CT2_CTLSLD == "0" .Or. Empty(CT2->CT2_CTLSLD)) .And. Empty(cMtSldOri)

			// Atualiza o status de copia do lancamento de origem
			RecLock( "CT2", .F. )
			CT2->CT2_CTLSLD := "2"
			CT2->( MsUnLock() )

			If cDataOri+cDocOri+cLoteOri != CT2->(DtoS(CT2_DATA)+CT2_DOC+CT2_LOTE) .Or. nLinha > nMaxLinha
				// Atualiza numeracao de lote, sub-lote e documento
				If MV_PAR13 = 1
					cLote    := CT2->CT2_LOTE
					cSubLote := CT2->CT2_SBLOTE
				Else
					cLote		:= IIf(Empty(cLote)   ,mv_par14,cLote)
					cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
				EndIf
				cDataOri:= DtoS(CT2->CT2_DATA)
				cDocOri := CT2->CT2_DOC
				cLoteOri:= CT2->CT2_LOTE

				cDoc    := CT2->CT2_DOC
				dDtLanc := CT2->CT2_DATA
				lFirst  := .T.
			EndIf

			For nInc := 1 To Len(MV_PAR04)
				If (SubStr(MV_PAR04,nInc,1) $ "|;| |") .Or. SubStr(MV_PAR04,nInc,1) == AllTrim(cTpSldOri)
					Loop
				EndIf
				
				If lFirst .Or. nLinha > nMaxLinha
					CTM300ProxDoc(dDtLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)
					If MV_PAR13 = 1
						cLote    := IIf(Empty(cLote)   ,Soma1(Space(TamSx3("CT2_LOTE")[1]))  ,cLote)    //CT2->CT2_LOTE
						cSubLote := IIf(Empty(cSubLote),Soma1(Space(TamSx3("CT2_SBLOTE")[1])),cSubLote) //CT2->CT2_SBLOTE
					Else
						cLote		:= IIf(Empty(cLote)   ,mv_par14,cLote)
						cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
					EndIf
					lFirst := .F.
					nLinha := 1
					cLinha := StrZero(nLinha,3)
				Else
					If cUltLanc != CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
						nLinha ++
						cLinha := Soma1(cLinIncl)
					EndIf	
				EndIf

				// Copia os campos padrao da tabela de lancamentos contabeis (CT2)
				For nX := 1 To nCpos
					If nX <> nPosTpSal
						aDadosCT2[nX] := CT2->(FieldGet(nX))
					EndIf
				Next nX
				
				aDadosCT2[nPosLote]  := cLote
				aDadosCT2[nPosSLote] := cSubLote
				aDadosCT2[nPosDoc]   := cDoc
				aDadosCT2[nPosTPSal] := SubStr(MV_PAR04,nInc,1)
				aDadosCT2[nPosCtSal] := "2"							// Geracao Off-Line - Controle de Copia
				aDadosCT2[nPosLinha] := cLinha
				
				If !Empty(cHistPadr)
					aDadosCT2[nPosHP]  := cHistPadr
					aDadosCT2[nPosHist] := Posicione("CT8",1,xFilial("CT8")+cHistPadr,"CT8_DESC")
				EndIf
				
				If lSemValor .And. CT2->CT2_MOEDLC == "01"
					aDadosCT2[nPosValor] := 0
				EndIf

	            //deve ser armazenado antes de gravar o registro no CT2 pois se refere ao registro de origem da copia
				cUltLanc := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
								
				// Cria novo registro na tabela CT2 e grava os dados do lancamento de origem
				RecLock( "CT2", .T. )
				For nX := 1 To nCpos
					CT2->( FieldPut( nX, aDadosCT2[nX] ) )
				Next nX
				CT2->( MsUnlock() )
				cLinIncl := CT2->CT2_LINHA
			Next nInc
		EndIf
		
	ElseIf lMltSaldos
		
		aTpSaldos := CTM300GetTpSaldos( CT2->CT2_MLTSLD, ";" )
		cTpSldOri := CT2->CT2_TPSALD //Variavel criada para comparar com registro a ser criado
		cMtSldOri := AllTrim(StrTran(StrTran(CT2->CT2_MLTSLD,";",""),cTpSldOri,"")) //Variavel criada para tratar um possivel erro

		If (CT2->CT2_CTLSLD == "0" .Or. Empty(CT2->CT2_CTLSLD)) .And. !Empty(cMtSldOri)

			// Atualiza o status de copia do lancamento de origem
			RecLock( "CT2", .F. )
			CT2->CT2_CTLSLD := "2"
			CT2->( MsUnLock() )

			If cDataOri+cDocOri+cLoteOri != CT2->(DtoS(CT2_DATA)+CT2_DOC+CT2_LOTE) .Or. nLinha > nMaxLinha
				// Atualiza numeracao de lote, sub-lote e documento
				If MV_PAR13 = 1
					cLote    := CT2->CT2_LOTE
					cSubLote := CT2->CT2_SBLOTE
				Else
					cLote		:= IIf(Empty(cLote)   ,mv_par14,cLote)
					cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
				EndIf
				cDataOri:= DtoS(CT2->CT2_DATA)
				cDocOri := CT2->CT2_DOC
				cLoteOri:= CT2->CT2_LOTE
				
				cDoc    := CT2->CT2_DOC
				dDtLanc := CT2->CT2_DATA
				lFirst  := .T.
			EndIf

			For nInc := 1 To Len( aTpSaldos )
				
				//Nใo cria registro que jแ existe
				If AllTrim(aTpSaldos[nInc]) == AllTrim(cTpSldOri) .Or. Empty(aTpSaldos[nInc])
					Loop
				EndIf

				If lFirst .Or. nLinha > nMaxLinha
					CTM300ProxDoc(dDtLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)
					If MV_PAR13 = 1
						cLote    := IIf(Empty(cLote)   ,Soma1(Space(TamSx3("CT2_LOTE")[1]))  ,cLote)    //CT2->CT2_LOTE
						cSubLote := IIf(Empty(cSubLote),Soma1(Space(TamSx3("CT2_SBLOTE")[1])),cSubLote) //CT2->CT2_SBLOTE
					Else
						cLote		:= IIf(Empty(cLote)   ,mv_par14,cLote)
						cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
					EndIf
					lFirst := .F.
					nLinha := 1
					cLinha := StrZero(nLinha,3)
				Else
					If cUltLanc != CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
						nLinha ++
						cLinha := Soma1(cLinIncl)
					EndIf
				EndIf

				// Copia os campos padrao da tabela de lancamentos contabeis (CT2)           
				For nX := 1 To nCpos         
					If nX <> nPosTpSal            
						aDadosCT2[nX] := CT2->(FieldGet(nX))
					EndIf
				Next nX
				
				aDadosCT2[nPosLote]  := cLote
				aDadosCT2[nPosSLote] := cSubLote
				aDadosCT2[nPosDoc]   := cDoc
				aDadosCT2[nPosTPSal] := aTpSaldos[nInc]				// Tipo de Saldo
				aDadosCT2[nPosCtSal] := "2"							// Geracao Off-Line - Controle de Copia
 				aDadosCT2[nPosLinha] := cLinha

				If !Empty(cHistPadr)
					aDadosCT2[nPosHP]  := cHistPadr
					aDadosCT2[nPosHist] := Posicione("CT8",1,xFilial("CT8")+cHistPadr,"CT8_DESC")
				EndIf

				If lSemValor .And. CT2->CT2_MOEDLC == "01"
					aDadosCT2[nPosValor] := 0
				EndIf

	            //deve ser armazenado antes de gravar o registro no CT2 pois se refere ao registro de origem da copia
				cUltLanc := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)

				// Cria novo registro na tabela CT2 e grava os dados do lancamento de origem
				RecLock( "CT2", .T. )
				For nX := 1 To nCpos
					CT2->( FieldPut( nX, aDadosCT2[nX] ) )
				Next nX
			    CT2->( MsUnlock() )
				cLinIncl := CT2->CT2_LINHA
			Next nInc
		EndIf
	EndIf
         
    TRB->( dbSkip() )
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ CTM300SelSintบ Autor ณ Gustavo Henrique บ Data ณ 20/12/06  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Seleciona registros das tabelas de saldos e grava arquivo  บฑฑ
ฑฑบ          ณ de trabalho quando selecionado na pergunta "Tipo" a opcao  บฑฑ
ฑฑบ          ณ movimentos sinteticos.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPL1 - Indicar se deve processar saldo ateh a data inicialบฑฑ
ฑฑบ          ณ         ou movimento sintetico do periodo.                 บฑฑ
ฑฑบ          ณ EXPC2 - Alias da tabela de saldos (CQ1,CQ3,CQ5,CQ7)        บฑฑ
ฑฑบ          ณ EXPD3 - Data inicial para selecao dos lancamentos de saldo บฑฑ
ฑฑบ          ณ EXPD4 - Data final para selecao dos lancamentos de saldo   บฑฑ
ฑฑบ          ณ EXPC5 - Moeda para selecao e gravacao dos lancamentos      บฑฑ
ฑฑบ          ณ EXPC6 - Tipo de saldo para selecao e gravacao dos lanctos. บฑฑ
ฑฑบ          ณ EXPL7 - Indica se movimenta centro de custo no CTB         บฑฑ
ฑฑบ          ณ EXPL8 - Indica se movimenta item contabil no CTB           บฑฑ
ฑฑบ          ณ EXPL9 - Indica se movimenta classe de valor no CTB         บฑฑ
ฑฑบ          ณ EXPL10- Indica se deve processar todas as moedas           บฑฑ
ฑฑบ          ณ EXPN11- Indica ateh que nivel de entidade do CTB deve      บฑฑ
ฑฑบ          ณ         processar os lancamentos.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300SelSint( lSaldo, cAlias, dDataIni, dDataFim, cMoeda, cTpSaldo, lCusto, lItem, lClVl, lTodas, nNivel )

Local aSldAtu	:= {}
Local aSldIni	:= {}
Local aSldFim	:= {}
Local aDataProc	:= {}

Local nRecno	:= 0
Local nDebTrb	:= 0 
Local nCrdTrb	:= 0
Local nTrbSlD	:= 0
Local nTrbSlC	:= 0
Local nMovCrd	:= 0
Local nMovDeb	:= 0
Local nSaldo	:= 0

Local cKeyAtu	:= ""             
Local cDataFim	:= DtoS(dDataFim)

Local cConta 	:= Space(Len(CriaVar("CT1_CONTA")))
Local cCusto 	:= Space(Len(CriaVar("CTT_CUSTO")))
Local cItem  	:= Space(Len(CriaVar("CTD_ITEM")))
Local cClVl		:= Space(Len(CriavAr("CTH_CLVL")))

Local lTemSaldo	:= .F.

Local dDataAtu	
Local dDataAnt	:= CtoD("  /  /  ")
      
Local bCond		:= { || .T. }
Local cVarAux		:= ""

                                                                                                           
If lTodas
	bCond 	:= { ||	(cAlias)->&(cAlias + "_TPSALD") $ cTpSaldo .And.; 	// Processa apenas tipo de saldo de origem
					dDataAtu >= dDataIni .And.	dDataAtu <= dDataFim }      // Dentro do periodo informado
Else
	bCond 	:= { ||	(cAlias)->&(cAlias + "_TPSALD") $ cTpSaldo .And.; 	// Processa apenas tipo de saldo de origem
					dDataAtu >= dDataIni .And.	dDataAtu <= dDataFim .And.;	// Dentro do periodo informado
					(cAlias)->&(cAlias + "_MOEDA") == cMoeda }  			// Na moeda especifica ou para todas as moedas
EndIf					


cFilAlias := xFilial(cAlias)

(cAlias)->(dbSetOrder(2))
(cAlias)->(MsSeek(cFilAlias,.T.)) //Procuro pela primeira conta a ser zerada

// Calcula numero de dias que serao processados para incremento do gauge
ProcRegua( (cAlias)->(LastRec()) )

Do While (cAlias)->( !Eof() .And. &(cAlias+"_FILIAL") == cFilAlias )

	dDataAtu := (cAlias)->&(cAlias+"_DATA")

	IncProc()
	
	If lTodas
		cMoeda := (cAlias)->&(cAlias + "_MOEDA")
	EndIf	 
	
	// Verifica se atende as condicoes de filtro especificadas nos parametros
	If !Eval( bCond )
		(cAlias)->( dbSkip() )
		Loop
	EndIf

	If cAlias == 'CQ7'
		cChave := CQ7->(CQ7_CONTA+CQ7_CCUSTO+CQ7_ITEM+CQ7_CLVL)
	ElseIf cAlias == 'CQ5'
		cChave := CQ5->(CQ5_CONTA+CQ5_CCUSTO+CQ5_ITEM)
	ElseIf cAlias == 'CQ3'       
		cChave := CQ3->(CQ3_CONTA+CQ3_CCUSTO)
	ElseIf cAlias == 'CQ1'
		cChave := CQ1->CQ1_CONTA
	EndIf

	//--------------------------------------
	// Pula registro caso a chave se repita
	//--------------------------------------
	If cChave+cMoeda+cTpSaldo == cVarAux
		(cAlias)->( DBSkip() )
		Loop
	Else
		cVarAux := cChave+cMoeda+cTpSaldo
	EndIf

	If cAlias == 'CQ7'
		cConta := CQ7->CQ7_CONTA
		cCusto := CQ7->CQ7_CCUSTO
		cItem  := CQ7->CQ7_ITEM
		cClVl  := CQ7->CQ7_CLVL
		If lSaldo
			aSldAtu := SaldoCTI(cConta,cCusto,cItem,cClVL,dDataIni-1,cMoeda,cTpSaldo,'CTBM300',.F.)
		Else
			aSldIni	:= SaldoCTI(cConta,cCusto,cItem,cClVL,dDataIni,cMoeda,cTpSaldo,'CTBM300',.F.)
			aSldFim	:= SaldoCTI(cConta,cCusto,cItem,cClVL,dDataFim,cMoeda,cTpSaldo,'CTBM300',.F.)	
		EndIf	
	ElseIf cAlias == 'CQ5'
		cConta := CQ5->CQ5_CONTA
		cCusto := CQ5->CQ5_CCUSTO
		cItem  := CQ5->CQ5_ITEM
		If lSaldo
			aSldAtu	:= SaldoCT4(cConta,cCusto,cItem,dDataIni-1,cMoeda,cTpSaldo,'CTBM300',.F.)
		Else
			aSldIni	:= SaldoCT4(cConta,cCusto,cItem,dDataIni,cMoeda,cTpSaldo,'CTBM300',.F.)
			aSldFim	:= SaldoCT4(cConta,cCusto,cItem,dDataFim,cMoeda,cTpSaldo,'CTBM300',.F.)	
		EndIf	
	ElseIf cAlias == 'CQ3'
		cConta := CQ3->CQ3_CONTA
		cCusto := CQ3->CQ3_CCUSTO
		If lSaldo
			aSldAtu	:= SaldoCT3(cConta,cCusto,dDataIni-1,cMoeda,cTpSaldo,'CTBM300',.F.)
		Else
			aSldIni	:= SaldoCT3(cConta,cCusto,dDataIni,cMoeda,cTpSaldo,'CTBM300',.F.)	
			aSldFim	:= SaldoCT3(cConta,cCusto,dDataFim,cMoeda,cTpSaldo,'CTBM300',.F.)	
		EndIf	
	ElseIf cAlias == 'CQ1'
		cConta := CQ1->CQ1_CONTA
		If lSaldo
			aSldAtu	:= SaldoCT7(cConta,dDataIni-1,cMoeda,cTpSaldo,'CTBM300',.F.)	
		Else
			aSldIni	:= SaldoCT7(cConta,dDataIni,cMoeda,cTpSaldo,'CTBM300',.F.)	
			aSldFim	:= SaldoCT7(cConta,dDataFim,cMoeda,cTpSaldo,'CTBM300',.F.)	
		EndIf	
	EndIf			
                   
  	If lSaldo
		nSaldo	:= aSldAtu[1]
		lTemSld	:= (nSaldo <> 0)
	Else
		nMovDeb	:= iif( dDataIni == dDataFim , aSldFim[4]  , aSldFim[4] - aSldIni[4] )
		nMovCrd	:= iif( dDataIni == dDataFim , aSldFim[5]  , aSldFim[5] - aSldIni[5] )
		lTemSld	:= (nMovDeb <> 0 .Or. nMovCrd <> 0)
	EndIf	

	If lTemSld	// Se houver saldo
	
		nTrbSlD := 0
		nTrbSlC := 0
	
		TRB->( dbSetOrder(2) )
                               
		If cAlias <> "CQ7"	// Saldos x Classe de Valor
			If cAlias == "CQ5"	// Saldos x Item contabil
				If lClVl .And. nNivel == 4
					cKeyAtu := cTpSaldo+cMoeda+"CQ7"+cConta+cCusto+cItem
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf	
			ElseIf cAlias == "CQ3" 	// Saldos x Centro de Custo
				If lItem .And. nNivel >= 3 
					cKeyAtu := cTpSaldo+cMoeda+"CQ3"+cConta+cCusto
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf
				If lClVl .And. nNivel == 4	                      
					cKeyAtu := cTpSaldo+cMoeda+"CQ7"+cConta+cCusto
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf	
			ElseIf cAlias == "CQ1"	// Saldos x Conta
				If lCusto .And. nNivel >= 2
					cKeyAtu := cTpSaldo+cMoeda+"CQ3"+cConta
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf
				If lItem .And. nNivel >= 3
					cKeyAtu := cTpSaldo+cMoeda+"CQ5"+cConta
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf
				If lClVl .And. nNivel == 4
					cKeyAtu := cTpSaldo+cMoeda+"CQ7"+cConta
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf
			EndIf
		EndIf	
                
		If lSaldo
			nDebTrb := aSldAtu[4] - nTrbSlD
			nCrdTrb := aSldAtu[5] - nTrbSlC
		Else
			nDebTrb := nMovDeb - nTrbSlD
			nCrdTrb := nMovCrd - nTrbSlC
		EndIf	

		If (nDebTrb <> 0 .Or. nCrdTrb <> 0) 
			TRB->(dbSetOrder(1))		
			If ! TRB->(MsSeek(cTpSaldo+cMoeda+cConta+cCusto+cItem+cClvl+cAlias,.F.))
				RecLock("TRB",.T.)
				TRB->TPSALDO	:= cTpSaldo
				TRB->MOEDA		:= cMoeda
				TRB->CONTA		:= cConta
				TRB->CUSTO		:= cCusto
				TRB->ITEM		:= cItem
				TRB->CLVL		:= cClVL
				TRB->IDENT		:= cAlias
				TRB->DEBITO		:= nDebTrb
				TRB->CREDIT		:= nCrdTrb
				TRB->(MsUnlock())
			EndIf
			TRB->(dbSetOrder(2))			
		EndIf	
	EndIf	

	(cAlias)->(dbSkip())

EndDo

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณ CTM300CalcTRB บ Autor ณ Gustavo Henrique บ Data ณ 26/12/06 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Calcula o saldo total de debito e credito para nas entida_ บฑฑ
ฑฑบ          ณ des de centro de custo, item ou classe de valor.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Indica a entidade que deve ser apurado os debitos  บฑฑ
ฑฑบ          ณ         e creditos (CQ3, CQ5 ou CQ1)                       บฑฑ
ฑฑบ          ณ EXPC2 - Chave de busca dos valores de saldo da entidade.   บฑฑ
ฑฑบ          ณ EXPN3 - Saldo total de debitos para a entidade.            บฑฑ
ฑฑบ          ณ EXPN4 - Saldo total de credito para a entidade.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300CalcTrb( cAlias, cKeyAtu, nTrbSlD, nTrbSlC )
                                                  
Local bCond	

If cAlias == "CQ5"
	bCond := { || cKeyAtu == TPSALDO+MOEDA+IDENT+CONTA+CUSTO+ITEM }
ElseIf cAlias == "CQ3"	
	bCond := { || cKeyAtu == TPSALDO+MOEDA+IDENT+CONTA+CUSTO }        
ElseIf cAlias == "CQ1"
	bCond := { || cKeyAtu == TPSALDO+MOEDA+IDENT+CONTA }
EndIf

TRB->( MsSeek( cKeyAtu, .F. ) )
TRB->( dbEval(	{ || nTrbSlD += DEBITO, nTrbSlC += CREDIT },, bCond ) )

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ CTM300GrvSintบ Autor ณ Gustavo Henrique บ Data ณ  21/12/06 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Grava lancamentos contabeis a partir do arquivo de trabalhoบฑฑ
ฑฑบ          ณ gerado, com os movimentos sinteticos de acordo com os      บฑฑ
ฑฑบ          ณ parametros informados.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPD1 - Data em que serao gravados os lancamentos          บฑฑ
ฑฑบ          ณ EXPC2 - Numero do lote do lancamento                       บฑฑ
ฑฑบ          ณ EXPC3 - Numero do sub-lote do lancamento                   บฑฑ
ฑฑบ          ณ EXPC4 - Codigo da moeda do lancamento                      บฑฑ
ฑฑบ          ณ EXPC5 - Tipo de saldo do lancamento                        บฑฑ
ฑฑบ          ณ EXPC6 - Historico padrao do lancamento                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300GrvSint( dDataLanc, cLote, cSubLote, cMoeda, cTpSaldo, cHP )

Local aArea		:= GetArea()
Local aCols		:= {}
Local lFirst	:= .T.
Local nLinha	:= 1
Local nConta	:= 1
Local cSeqLan	:= ""
Local cLinha	:= ""
Local cLinIncl  := Space(Len(CT2->CT2_LINHA))
Local cTipo		:= ""
Local cDebito	:= ""
Local cCustoDeb	:= ""
Local cItemDeb	:= ""
Local cClVlDeb	:= ""
Local cCredito	:= ""
Local cCustoCrd	:= ""
Local cItemCrd	:= ""
Local cClVlCrd	:= ""
Local cDoc		:= ""
Local nMaxLinha:= IIf(GetMV("MV_NUMLIN")<1,999,CtbLinMax(GetMv("MV_NUMLIN")))
Local CTF_LOCK	:= 0

ProcRegua( TRB->(LastRec()) )

CT2->( dbSetOrder( 1 ) )

CT8->( dbSetOrder( 1 ) )
CT8->( MsSeek( xFilial("CT8") + cHP ) )
cDescHP	:= CT8->CT8_DESC

TRB->( dbSetOrder(1) )
TRB->( dbGoTop() )

Do While TRB->( ! EoF() )
     
	IncProc()

	nSaldo := TRB->(CREDIT-DEBITO)
               
	If nSaldo <> 0

		If lFirst .Or. nLinha > nMaxLinha
			If Empty(mv_par14)
				cLote		:= IIf(Empty(cLote),Soma1(Space(TamSx3("CT2_LOTE")[1])),cLote) //CT2->CT2_LOTE
			Else
				cLote		:= IIf(Empty(cLote),mv_par14,cLote)
			EndIf

			If Empty(mv_par15)
				cSubLote := IIf(Empty(cSubLote),Soma1(Space(TamSx3("CT2_SBLOTE")[1])),cSubLote) //CT2->CT2_SBLOTE
			Else
				cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
			EndIf

			//Gera numero do documento
			CTM300ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)

			lFirst := .F.
			nLinha := 1
			cLinha := StrZero(nLinha,3)
			cSeqLan:= StrZero(nLinha,3)
		Else   
		/*
			nLinha ++
			cLinha := StrZero(nLinha,3)
			cSeqLan:= StrZero(nLinha,3)
		*/			
		EndIf
	
		If nSaldo > 0	
			cTipo		:= "2"		/// LANCAMENTO A CREDITO
			cDebito	:= ""
			cCustoDeb:= ""
			cItemDeb	:= ""
			cClVlDeb	:= ""
	
			cCredito	:= TRB->CONTA
			cCustoCrd	:= TRB->CUSTO
			cItemCrd	:= TRB->ITEM
			cClVlCrd	:= TRB->CLVL			
		Else
			cTipo 		:= "1"		/// LANCAMENTO A DEBITO
			cDebito		:= TRB->CONTA
			cCustoDeb	:= TRB->CUSTO
			cItemDeb	:= TRB->ITEM	
			cClVlDeb	:= TRB->CLVL
	
			cCredito	:= ""
			cCustoCrd	:= ""
			cItemCrd	:= ""
			cClVlCrd	:= ""
		EndIf 
	
		//Grava lancamento na moeda 01
		nSaldo := Abs(nSaldo)
	
		BEGIN TRANSACTION
	
		If TRB->MOEDA == "01"
	
			aCols := { { "01", " ", nSaldo, "2", .F., nSaldo } }
	
			For nConta := 1 To Len(cTpSaldo)
				If !(SubStr(cTpSaldo,nConta,1) $ "|;| |") .And. SubStr(cTpSaldo,nConta,1) != TRB->TPSALDO
					GravaLanc(dDataLanc,cLote,cSubLote,cDoc,cLinha,cTipo,'01',cHP,cDebito,cCredito,;
						  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,nSaldo,cDescHP,;
						  SubStr(cTpSaldo,nConta,1),cSeqLan,3,.F.,aCols,cEmpAnt,cFilAnt,,,,,,,.F.)
					nRecCT2 := CT2->( Recno() )
					cLinIncl := CT2->CT2_LINHA
					If CT2->( MsSeek(xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc+cLinha+SubStr(cTpSaldo,nConta,1)+cEmpAnt+cFilAnt+"01") )
						nLinha ++
						cLinha := Soma1(cLinIncl)
						cSeqLan:= cLinha
					EndIf
					CT2->( dbGoto(nRecCT2) )
				EndIf
			Next nConta
	
		Else	/// Grava Lancamento na moeda 02 com valor zerado na moeda 01

			//aCols := { { "01", " ", 0.00, "2", .F., 0 },{ TRB->MOEDA, "4", nSaldo, "2", .F., nSaldo } }
	
			If Val(TRB->MOEDA) >= 2
				nForaCols	:= Val(TRB->MOEDA)-1
			Else                
				nForaCols	:= 0
			EndIf
			
			aCols := { { "01", " ", 0.00, "2", .F., 0 } }
			For nConta := 1 To Len(cTpSaldo)
				If !(SubStr(cTpSaldo,nConta,1) $ "|;| |") .And. SubStr(cTpSaldo,nConta,1) != TRB->TPSALDO
					GravaLanc(dDatalanc,cLote,cSubLote,cDoc,cLinha,cTipo,'01',cHP,cDebito,cCredito,;
						  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
						  SubStr(cTpSaldo,nConta,1),cSeqLan,3,.F.,aCols,cEmpAnt,cFilAnt,0,,,,,,.F.)
					nRecCT2 := CT2->( Recno() )
					cLinIncl := CT2->CT2_LINHA
					If CT2->( MsSeek(xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc+cLinha+SubStr(cTpSaldo,nConta,1)+cEmpAnt+cFilAnt+"01") )
						nLinha ++
						cLinha := Soma1(cLinIncl)
						cSeqLan:= cLinha
					EndIf
					CT2->( dbGoto(nRecCT2) )
				EndIf
			Next nConta

			aCols := { { TRB->MOEDA, "4", nSaldo, "2", .F., nSaldo } }
			For nConta := 1 To Len(cTpSaldo)
				If !(SubStr(cTpSaldo,nConta,1) $ "|;| |") .And. SubStr(cTpSaldo,nConta,1) != TRB->TPSALDO
					GravaLanc(dDataLanc,cLote,cSubLote,cDoc,cLinha,cTipo,TRB->MOEDA,cHP,cDebito,cCredito,;
						  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
						  SubStr(cTpSaldo,nConta,1),cSeqLan,3,.F.,aCols,cEmpAnt,cFilAnt,nForaCols,,,,,,.F.)
					nRecCT2 := CT2->( Recno() )
					cLinIncl := CT2->CT2_LINHA
					If CT2->( MsSeek(xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc+cLinha+SubStr(cTpSaldo,nConta,1)+cEmpAnt+cFilAnt+cMoeda) )
						nLinha ++
						cLinha := Soma1(cLinIncl)
						cSeqLan:= cLinha
					EndIf
					CT2->( dbGoto(nRecCT2) )
				EndIf
			Next nConta
		EndIf
	
		END TRANSACTION
	
	EndIf

	TRB->( dbSkip() )

EndDo      

RestArea( aArea )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCTBM300ProxDocบAutor ณ Gustavo Henrique บ Data ณ  15/01/07  บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Gera proxima numeracao de documento para gravar no novo    บฑฑ
ฑฑบ          ณ Lancamento. Caso estoure a numeracao de documento,         บฑฑ
ฑฑบ          ณ incrementa numero de lote.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPD1 - Data do lancamento a ser gravado                   บฑฑ
ฑฑบ          ณ EXPC2 - Numero do lote                                     บฑฑ
ฑฑบ          ณ EXPC3 - Numero do sub-lote                                 บฑฑ
ฑฑบ          ณ EXPC4 - Numero do documento                                บฑฑ
ฑฑบ          ณ EXPC5 - Numero do RECNO da tabela de numeracao de doctos.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTM300ProxDoc( dDataLanc, cLote, cSubLote, cDoc, CTF_LOCK )

// Verifica o Numero do Proximo documento contabil                         
Do While !ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Caso o Nง do Doc estourou, incrementa o lote         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cLote := Soma1(cLote)
Enddo

FreeUsedCode()  //libera codigos ainda travados

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTM300GetTบAutor  ณ Totvs              บ Data ณ  13/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ retorna os tipos de saldos em um array.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300GetTpSaldos( cTpSaldos, cSepara )
	Local aReturn 	:= {}
	Local cAux		:= ""
	Local nInc		:= 0
	
	cTpSaldos := AllTrim( cTpSaldos )
	For nInc := 1 To Len( cTpSaldos )
		cAux += substr( cTpSaldos, nInc, 1 )
		If substr( cTpSaldos, nInc, 1 ) == cSepara .OR. nInc == Len( cTpSaldos )
			If aScan( aReturn, StrTran( cAux, cSepara, "" ) ) == 0
				aAdd( aReturn, StrTran( cAux, cSepara, "" ) )
			EndIf

			cAux := ""
		EndIf
	Next
	
Return aReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCTBM300CTI    บAutor ณ TOTVS            บ Data ณ  23/01/09  บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza saldos no CQ7                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Nome da procedure                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBM300CTI(cProc, aProc)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local aCampos   := CQ7->(DbStruct())
Local aCampos2  := CQ6->(DbStruct())
Local cQuery    := ""
Local nPos      := 0
Local cTipo     := ""
Local nPTratRec	:= 0
Local nPosFim   := 0
Local cRecnotext:= ""
Local nPosFim2	:= 0
Local cInsertText:= ""
Local cBufferAux := ""
Local nPos3      := 0
Local iRet       :=0

cQuery:= "Create procedure "+cProc+"_"+cEmpAnt+" ("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ7_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_FILIAL  "+cTipo+CRLF
cQuery+="   @IN_DATA    Char( 08 ),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ7_MOEDA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_MOEDA   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ7_TPSALD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_TPSALD  "+cTipo+CRLF
cQuery+="   @IN_VALOR   float,"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ7_CONTA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CONTA   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ7_CCUSTO" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CUSTO   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ7_ITEM" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_ITEM    "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ7_CLVL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_CLVL    "+cTipo+CRLF
cQuery+="   @IN_DC      Char( 01 )"+CRLF
cQuery+=")"+CRLF
cQuery+="as"+CRLF
/* --------------------------------------------------------------------------------------------------
    Atualiza CQ7
   -------------------------------------------------------------------------------------------------- */
cQuery+="Declare @cAux      Char( 03 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ7_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cFil_CQ7  "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ7_LP" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cLp       "+cTipo+CRLF
cQuery+="Declare @iRecno    integer"+CRLF
cQuery+="Declare @nDebito   Float"+CRLF
cQuery+="Declare @nCredit   Float"+CRLF
cQuery+="Declare @nCont     Integer"+CRLF
cQuery+="Declare @cLastDay  Char(08)"+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "CQ6_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cFil_CQ6  "+cTipo+CRLF
cQuery+= "Declare @cStatus	Char(01)"+CRLF
cQuery+= "Declare @cSldBase	Char(01)"+CRLF

cQuery+=""+CRLF
cQuery+="Begin"+CRLF
   
cQuery+="   Select @cAux = 'CQ7'"+CRLF  
cQuery+= "   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CQ7 OutPut"+CRLF

cQuery+="   select @iRecno   = null"+CRLF
cQuery+="   select @cLp      = 'N'"+CRLF
cQuery+="   select @nDebito  = 0"+CRLF
cQuery+="   select @nCredit  = 0"+CRLF
cQuery+="   select @cStatus  = '1'"+CRLF
cQuery+="   select @cSldBase = 'S'"+CRLF

cQuery+="   Select @iRecno = Min( R_E_C_N_O_)"+CRLF
cQuery+="     From "+RetSqlName("CQ7")+CRLF
cQuery+="    where CQ7_FILIAL = @cFil_CQ7"+CRLF
cQuery+="      and CQ7_CONTA  = @IN_CONTA"+CRLF
cQuery+="      and CQ7_CCUSTO  = @IN_CUSTO"+CRLF
cQuery+="      and CQ7_ITEM   = @IN_ITEM"+CRLF
cQuery+="      and CQ7_CLVL   = @IN_CLVL"+CRLF
cQuery+="      and CQ7_DATA   = @IN_DATA"+CRLF
cQuery+="      and CQ7_MOEDA  = @IN_MOEDA"+CRLF
cQuery+="      and CQ7_TPSALD = @IN_TPSALD"+CRLF
cQuery+="      and CQ7_LP     = 'N'"+CRLF
cQuery+="      and D_E_L_E_T_ = ' '"+CRLF
   
cQuery+="   If @iRecno is null begin"+CRLF
      
cQuery+="      If @IN_DC = 'D' begin"+CRLF
cQuery+="         select @nDebito = Round( @IN_VALOR, 2)"+CRLF
cQuery+="         select @nCredit = 0"+CRLF
cQuery+="      end else begin"+CRLF
cQuery+="         select @nCredit = Round( @IN_VALOR, 2)"+CRLF
cQuery+="         select @nDebito = 0"+CRLF
cQuery+="      End"+CRLF
      /* ---------------------------------------
         insercao na data do lancto
         --------------------------------------- */
cQuery+="      Select @iRecno = IsNull( Max( R_E_C_N_O_), 0 ) from "+RetSqlName("CQ7")+CRLF
cQuery+="      Select @iRecno = @iRecno + 1"+CRLF
cQuery+="      begin tran"+CRLF
cQuery+="      ##TRATARECNO @iRecno\"+CRLF
cQuery+="      insert into "+RetSqlName("CQ7")+" ( CQ7_FILIAL, CQ7_CONTA,  CQ7_CCUSTO,  CQ7_ITEM,   CQ7_CLVL,   CQ7_DATA,   CQ7_MOEDA, CQ7_TPSALD, CQ7_LP,"+CRLF
cQuery+="                           CQ7_DEBITO,  CQ7_CREDIT, CQ7_STATUS, CQ7_SLBASE, R_E_C_N_O_ )"+CRLF
cQuery+="                  Values ( @cFil_CQ7,  @IN_CONTA,  @IN_CUSTO,  @IN_ITEM,   @IN_CLVL,   @IN_DATA,   @IN_MOEDA, @IN_TPSALD, @cLp,"+CRLF
cQuery+="                           @nDebito,    @nCredit, @cStatus, @cSldBase,  @iRecno )"+CRLF
cQuery+="      ##FIMTRATARECNO"+CRLF
cQuery+="      commit tran"+CRLF
cQuery+="   end else begin"+CRLF
      /* ---------------------------------------
         Update na data do lancto
         --------------------------------------- */
cQuery+="      begin tran"+CRLF
cQuery+="      If @IN_DC = 'D' begin"+CRLF
cQuery+="         UpDate "+RetSqlName("CQ7")+CRLF
cQuery+="            Set CQ7_DEBITO = CQ7_DEBITO + Round( @IN_VALOR, 2)"+CRLF
cQuery+="          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery+="      end else begin"+CRLF
cQuery+="         UpDate "+RetSqlName("CQ7")+CRLF
cQuery+="            Set CQ7_CREDIT = CQ7_CREDIT + Round( @IN_VALOR, 2)"+CRLF
cQuery+="          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery+="      end"+CRLF
cQuery+="      commit tran"+CRLF
cQuery+="   End"+CRLF
   /* ----------------------------------------------------------
      Atualizacao de dados de saldo mensal - CQ6
      ---------------------------------------------------------- */
cQuery +=CRLF+"  Exec "+aProc[2]+ " @IN_DATA, @cLastDay OutPut"+CRLF+CRLF
cQuery+="   Select @cAux = 'CQ6'"+CRLF  
cQuery+= "   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CQ6 OutPut"+CRLF

cQuery+="   select @iRecno   = null"+CRLF
cQuery+="   select @cLp      = 'N'"+CRLF
cQuery+="   select @nDebito  = 0"+CRLF
cQuery+="   select @nCredit  = 0"+CRLF
cQuery+="   select @cStatus  = '1'"+CRLF
cQuery+="   select @cSldBase = 'S'"+CRLF

cQuery+="   Select @iRecno = Min( R_E_C_N_O_)"+CRLF
cQuery+="     From "+RetSqlName("CQ6")+CRLF
cQuery+="    where CQ6_FILIAL = @cFil_CQ7"+CRLF
cQuery+="      and CQ6_CONTA  = @IN_CONTA"+CRLF
cQuery+="      and CQ6_CCUSTO  = @IN_CUSTO"+CRLF
cQuery+="      and CQ6_ITEM   = @IN_ITEM"+CRLF
cQuery+="      and CQ6_CLVL   = @IN_CLVL"+CRLF
cQuery+="      and CQ6_DATA   = @cLastDay"+CRLF
cQuery+="      and CQ6_MOEDA  = @IN_MOEDA"+CRLF
cQuery+="      and CQ6_TPSALD = @IN_TPSALD"+CRLF
cQuery+="      and CQ6_LP     = 'N'"+CRLF
cQuery+="      and D_E_L_E_T_ = ' '"+CRLF
   
cQuery+="   If @iRecno is null begin"+CRLF
      
cQuery+="      If @IN_DC = 'D' begin"+CRLF
cQuery+="         select @nDebito = Round( @IN_VALOR, 2)"+CRLF
cQuery+="         select @nCredit = 0"+CRLF
cQuery+="      end else begin"+CRLF
cQuery+="         select @nCredit = Round( @IN_VALOR, 2)"+CRLF
cQuery+="         select @nDebito = 0"+CRLF
cQuery+="      End"+CRLF
      /* ---------------------------------------
         insercao na data do lancto
         --------------------------------------- */
cQuery+="      Select @iRecno = IsNull( Max( R_E_C_N_O_), 0 ) from "+RetSqlName("CQ7")+CRLF
cQuery+="      Select @iRecno = @iRecno + 1"+CRLF
cQuery+="      begin tran"+CRLF
cQuery+="      ##TRATARECNO @iRecno\"+CRLF
cQuery+="      insert into "+RetSqlName("CQ6")+" ( CQ6_FILIAL, CQ6_CONTA,  CQ6_CCUSTO,  CQ6_ITEM,   CQ6_CLVL,   CQ6_DATA,   CQ6_MOEDA, CQ6_TPSALD, CQ6_LP,"+CRLF
cQuery+="                           CQ6_DEBITO,  CQ6_CREDIT, CQ6_STATUS, CQ6_SLBASE, R_E_C_N_O_ )"+CRLF
cQuery+="                  Values ( @cFil_CQ6,  @IN_CONTA,  @IN_CUSTO,  @IN_ITEM,   @IN_CLVL,   @cLastDay,   @IN_MOEDA, @IN_TPSALD, @cLp,"+CRLF
cQuery+="                           @nDebito,    @nCredit, @cStatus, @cSldBase, @iRecno )"+CRLF
cQuery+="      ##FIMTRATARECNO"+CRLF
cQuery+="      commit tran"+CRLF
cQuery+="   end else begin"+CRLF
      /* ---------------------------------------
         Update na data do lancto
         --------------------------------------- */
cQuery+="      begin tran"+CRLF
cQuery+="      If @IN_DC = 'D' begin"+CRLF
cQuery+="         UpDate "+RetSqlName("CQ6")+CRLF
cQuery+="            Set CQ6_DEBITO = CQ6_DEBITO + Round( @IN_VALOR, 2)"+CRLF
cQuery+="          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery+="      end else begin"+CRLF
cQuery+="         UpDate "+RetSqlName("CQ6")+CRLF
cQuery+="            Set CQ6_CREDIT = CQ6_CREDIT + Round( @IN_VALOR, 2)"+CRLF
cQuery+="          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery+="      end"+CRLF
cQuery+="      commit tran"+CRLF
cQuery+="   End"+CRLF

cQuery+="End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If Empty( cQuery )
	MsgAlert(MsPArseError(),STR0086+cProc) //'A query de Atualizacao do CQ7 nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cProc )
		iRet := TcSqlExec(cQuery)
		If iRet <> 0
			If !__lBlind
				MsgAlert(STR0087+cProc)  //"Erro na criacao da procedure de Atualizacao do CQ7 "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCTBM300CT4    บAutor ณ TOTVS            บ Data ณ  23/01/09  บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza saldos no CQ5                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Nome da procedure                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBM300CT4(cProc, aProc)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local aCampos   := CQ5->(DbStruct())
Local aCampos2  := CQ4->(DbStruct())
Local cQuery    := ""
Local nPos      := 0
Local cTipo     := ""
Local nPTratRec	:= 0
Local nPosFim   := 0
Local cRecnotext:= ""
Local nPosFim2	:= 0
Local cInsertText:= ""
Local cBufferAux := ""
Local nPos3      := 0
Local iRet       :=0

cQuery:= "Create procedure "+cProc+"_"+cEmpAnt+" ("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ5_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+= "   @IN_FILIAL  "+cTipo+CRLF
cQuery+= "   @IN_DATA    Char( 08 ),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ5_MOEDA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+= "   @IN_MOEDA   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ5_TPSALD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+= "   @IN_TPSALD  "+cTipo+CRLF
cQuery+= "   @IN_VALOR   float,"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ5_CONTA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+= "   @IN_CONTA   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ5_CCUSTO" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+= "   @IN_CUSTO   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ5_ITEM" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+= "   @IN_ITEM    "+cTipo+CRLF
cQuery+= "   @IN_DC      Char( 01 )"+CRLF
cQuery+= ")
cQuery+= "as"+CRLF
/* --------------------------------------------------------------------------------------------------
    Atualiza CQ1
   -------------------------------------------------------------------------------------------------- */
cQuery+= "Declare @cAux      Char( 03 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ5_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+= "Declare @cFil_CQ5  "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ5_LP" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+= "Declare @cLp       "+cTipo+CRLF
cQuery+= "Declare @iRecno    integer"+CRLF
cQuery+= "Declare @nDebito   Float"+CRLF
cQuery+= "Declare @nCredit   Float"+CRLF
cQuery+= "Declare @nCont     Integer"+CRLF
cQuery+= "Declare @cLastDay  Char(08)"+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "CQ4_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cFil_CQ4  "+cTipo+CRLF
cQuery+= "Declare @cStatus	Char(01)"+CRLF
cQuery+= "Declare @cSldBase	Char(01)"+CRLF
cQuery+= ""+CRLF
cQuery+= "Begin"+CRLF
   
cQuery+= "   Select @cAux = 'CQ5'"+CRLF
cQuery+= "   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CQ5 OutPut"+CRLF

cQuery+= "   select @iRecno  = null"+CRLF
cQuery+= "   select @cLp     = 'N'"+CRLF
cQuery+= "   select @nDebito = 0"+CRLF
cQuery+= "   select @nCredit = 0"+CRLF
cQuery+= "   select @cStatus	= '1'"+CRLF
cQuery+= "   select @cSldBase	= 'S'"+CRLF
   
cQuery+= "   Select @iRecno = Min( R_E_C_N_O_)"+CRLF
cQuery+= "     From "+RetSqlName("CQ5")+CRLF
cQuery+= "    where CQ5_FILIAL = @cFil_CQ5"+CRLF
cQuery+= "      and CQ5_CONTA  = @IN_CONTA"+CRLF
cQuery+= "      and CQ5_CCUSTO  = @IN_CUSTO"+CRLF
cQuery+= "      and CQ5_ITEM   = @IN_ITEM"+CRLF
cQuery+= "      and CQ5_DATA   = @IN_DATA"+CRLF
cQuery+= "      and CQ5_MOEDA  = @IN_MOEDA"+CRLF
cQuery+= "      and CQ5_TPSALD = @IN_TPSALD"+CRLF
cQuery+= "      and CQ5_LP     = 'N'"+CRLF
cQuery+= "      and D_E_L_E_T_ = ' '"+CRLF
   
cQuery+= "   If @iRecno is null begin"+CRLF
      
cQuery+= "      If @IN_DC = 'D' begin"+CRLF
cQuery+= "         select @nDebito = Round( @IN_VALOR, 2)"+CRLF
cQuery+= "         select @nCredit = 0"+CRLF
cQuery+= "      end else begin"+CRLF
cQuery+= "         select @nCredit = Round( @IN_VALOR, 2)"+CRLF
cQuery+= "         select @nDebito = 0"+CRLF
cQuery+= "      End"+CRLF
      /* ---------------------------------------
         isercao na data do lancto
         --------------------------------------- */
cQuery+= "      Select @iRecno = IsNull( Max( R_E_C_N_O_), 0 ) from "+RetSqlName("CQ5")+CRLF
cQuery+= "      Select @iRecno = @iRecno + 1"+CRLF
cQuery+= "      begin tran"+CRLF
cQuery+= "      ##TRATARECNO @iRecno\"+CRLF
cQuery+= "      insert into "+RetSqlName("CQ5")+" ( CQ5_FILIAL, CQ5_CONTA,  CQ5_CCUSTO,  CQ5_ITEM, CQ5_DATA,   CQ5_MOEDA, CQ5_TPSALD, CQ5_LP, CQ5_DEBITO,"+CRLF
cQuery+= "                           CQ5_CREDIT, CQ5_STATUS, CQ5_SLBASE, R_E_C_N_O_ )"+CRLF
cQuery+= "                  Values ( @cFil_CQ5,  @IN_CONTA,  @IN_CUSTO,  @IN_ITEM, @IN_DATA,   @IN_MOEDA, @IN_TPSALD, @cLp,   @nDebito,"+CRLF
cQuery+= "                           @nCredit, @cStatus, @cSldBase,  @iRecno )"+CRLF
cQuery+= "      ##FIMTRATARECNO"+CRLF
cQuery+= "      commit tran"+CRLF
cQuery+= "   end else begin"+CRLF
      /* ---------------------------------------
         Update na data do lancto
         --------------------------------------- */
cQuery+= "      begin tran"+CRLF
cQuery+= "      If @IN_DC = 'D' begin"+CRLF
cQuery+= "         UpDate "+REtSqlName("CQ5")+CRLF
cQuery+= "            Set CQ5_DEBITO = CQ5_DEBITO + Round( @IN_VALOR, 2)"+CRLF
cQuery+= "          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery+= "      end else begin"+CRLF
cQuery+= "         UpDate "+RetSqlName("CQ5")+CRLF
cQuery+= "            Set CQ5_CREDIT = CQ5_CREDIT + Round( @IN_VALOR, 2)"+CRLF
cQuery+= "          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery+= "      end"+CRLF
cQuery+= "      commit tran"+CRLF
cQuery+= "   End"+CRLF
   /* ----------------------------------------------------------
      Atualizacao de dados dos saldo do Mes
      ---------------------------------------------------------- */
cQuery +=CRLF+"  Exec "+aProc[2]+ " @IN_DATA, @cLastDay OutPut"+CRLF+CRLF
      
cQuery+= "   Select @cAux = 'CQ4'"+CRLF
cQuery+= "   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CQ4 OutPut"+CRLF

cQuery+= "   select @iRecno  = null"+CRLF
cQuery+= "   select @cLp     = 'N'"+CRLF
cQuery+= "   select @nDebito = 0"+CRLF
cQuery+= "   select @nCredit = 0"+CRLF
cQuery+= "   select @cStatus  = '1'"+CRLF
cQuery+= "   select @cSldBase = 'S'"+CRLF
   
cQuery+= "   Select @iRecno = Min( R_E_C_N_O_)"+CRLF
cQuery+= "     From "+RetSqlName("CQ4")+CRLF
cQuery+= "    where CQ4_FILIAL = @cFil_CQ5"+CRLF
cQuery+= "      and CQ4_CONTA  = @IN_CONTA"+CRLF
cQuery+= "      and CQ4_CCUSTO  = @IN_CUSTO"+CRLF
cQuery+= "      and CQ4_ITEM   = @IN_ITEM"+CRLF
cQuery+= "      and CQ4_DATA   = @cLastDay"+CRLF
cQuery+= "      and CQ4_MOEDA  = @IN_MOEDA"+CRLF
cQuery+= "      and CQ4_TPSALD = @IN_TPSALD"+CRLF
cQuery+= "      and CQ4_LP     = 'N'"+CRLF
cQuery+= "      and D_E_L_E_T_ = ' '"+CRLF
   
cQuery+= "   If @iRecno is null begin"+CRLF
      
cQuery+= "      If @IN_DC = 'D' begin"+CRLF
cQuery+= "         select @nDebito = Round( @IN_VALOR, 2)"+CRLF
cQuery+= "         select @nCredit = 0"+CRLF
cQuery+= "      end else begin"+CRLF
cQuery+= "         select @nCredit = Round( @IN_VALOR, 2)"+CRLF
cQuery+= "         select @nDebito = 0"+CRLF
cQuery+= "      End"+CRLF
      /* ---------------------------------------
         isercao na data do lancto
         --------------------------------------- */
cQuery+= "      Select @iRecno = IsNull( Max( R_E_C_N_O_), 0 ) from "+RetSqlName("CQ4")+CRLF
cQuery+= "      Select @iRecno = @iRecno + 1"+CRLF
cQuery+= "      begin tran"+CRLF
cQuery+= "      ##TRATARECNO @iRecno\"+CRLF
cQuery+= "      insert into "+RetSqlName("CQ4")+" ( CQ4_FILIAL, CQ4_CONTA,  CQ4_CCUSTO,  CQ4_ITEM, CQ4_DATA,  CQ4_MOEDA, CQ4_TPSALD, CQ4_LP, CQ4_DEBITO,"+CRLF
cQuery+= "                           CQ4_CREDIT, CQ4_STATUS, CQ4_SLBASE, R_E_C_N_O_ )"+CRLF
cQuery+= "                  Values ( @cFil_CQ4,  @IN_CONTA,  @IN_CUSTO,  @IN_ITEM, @cLastDay,   @IN_MOEDA, @IN_TPSALD, @cLp,   @nDebito,"+CRLF
cQuery+= "                           @nCredit, @cStatus, @cSldBase, @iRecno )"+CRLF
cQuery+= "      ##FIMTRATARECNO"+CRLF
cQuery+= "      commit tran"+CRLF
cQuery+= "   end else begin"+CRLF
      /* ---------------------------------------
         Update na data do lancto
         --------------------------------------- */
cQuery+= "      begin tran"+CRLF
cQuery+= "      If @IN_DC = 'D' begin"+CRLF
cQuery+= "         UpDate "+REtSqlName("CQ4")+CRLF
cQuery+= "            Set CQ4_DEBITO = CQ4_DEBITO + Round( @IN_VALOR, 2)"+CRLF
cQuery+= "          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery+= "      end else begin"+CRLF
cQuery+= "         UpDate "+RetSqlName("CQ4")+CRLF
cQuery+= "            Set CQ4_CREDIT = CQ4_CREDIT + Round( @IN_VALOR, 2)"+CRLF
cQuery+= "          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery+= "      end"+CRLF
cQuery+= "      commit tran"+CRLF
cQuery+= "   End"+CRLF

cQuery+= "End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0088+cProc)  //"A query de Atualizacao do CQ5 nao passou pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProc )
		iRet := TcSqlExec(cQuery)
		If iRet <> 0
			If !__lBlind
				MsgAlert(STR0089+cProc)  //"Erro na criacao da procedure de Atualizacao do CQ5 "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCTBM300CT3    บAutor ณ TOTVS            บ Data ณ  23/01/09  บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza saldos no CQ3                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Nome da procedure                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBM300CT3(cProc, aProc)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local aCampos   := CQ3->(DbStruct())
Local aCampos2  := CQ2->(DbStruct())
Local cQuery    := ""
Local nPos      := 0
Local cTipo     := ""
Local nPTratRec	:= 0
Local nPosFim   := 0
Local cRecnotext:= ""
Local nPosFim2	:= 0
Local cInsertText:= ""
Local cBufferAux := ""
Local nPos3      := 0
Local iRet       := 0

cQuery := "Create procedure "+cProc+"_"+cEmpAnt+" ("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ3_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+= "   @IN_FILIAL  "+cTipo+CRLF
cQuery+= "   @IN_DATA    Char( 08 ),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ3_MOEDA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+= "   @IN_MOEDA   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ3_TPSALD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+= "   @IN_TPSALD  "+cTipo+CRLF
cQuery+= "   @IN_VALOR   float,"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ3_CONTA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+= "   @IN_CONTA   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ3_CCUSTO" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+= "   @IN_CUSTO   "+cTipo+CRLF
cQuery+= "   @IN_DC      Char( 01 )"+CRLF
cQuery+= ")"+CRLF
cQuery+= "as"+CRLF
/* --------------------------------------------------------------------------------------------------
    Atualiza CQ3
   -------------------------------------------------------------------------------------------------- */
cQuery+= "Declare @cAux      Char( 03 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ3_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+= "Declare @cFil_CQ3  "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ3_LP" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+= "Declare @cLp       "+cTipo+CRLF
cQuery+= "Declare @iRecno    integer"+CRLF
cQuery+= "Declare @nDebito   Float"+CRLF
cQuery+= "Declare @nCredit   Float"+CRLF
cQuery+= "Declare @nCont     Integer"+CRLF
cQuery+= "Declare @cLastDay  Char(08)"+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "CQ2_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+= "Declare @cFil_CQ2  "+cTipo+CRLF
cQuery+= "Declare @cStatus	Char(01)"+CRLF
cQuery+= "Declare @cSldBase	Char(01)"+CRLF
cQuery+= ""+CRLF

cQuery+= "Begin"+CRLF
      
cQuery+= "   Select @cAux = 'CQ3'"+CRLF
cQuery+= "   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CQ3 OutPut"+CRLF
cQuery+= "   select @iRecno  = null"+CRLF
cQuery+= "   select @cLp     = 'N'"+CRLF
cQuery+= "   select @nDebito = 0"+CRLF
cQuery+= "   select @nCredit = 0"+CRLF
cQuery+= "   select @cStatus	= '1'"+CRLF
cQuery+= "   select @cSldBase	= 'S'"+CRLF
   
cQuery+= "   Select @iRecno = Min( R_E_C_N_O_)"+CRLF
cQuery+= "     From "+RetSqlName("CQ3")+CRLF
cQuery+= "    where CQ3_FILIAL = @cFil_CQ3"+CRLF
cQuery+= "      and CQ3_CONTA  = @IN_CONTA"+CRLF
cQuery+= "      and CQ3_CCUSTO  = @IN_CUSTO"+CRLF
cQuery+= "      and CQ3_DATA   = @IN_DATA"+CRLF
cQuery+= "      and CQ3_MOEDA  = @IN_MOEDA"+CRLF
cQuery+= "      and CQ3_TPSALD = @IN_TPSALD"+CRLF
cQuery+= "      and CQ3_LP     = 'N'"+CRLF
cQuery+= "      and D_E_L_E_T_ = ' '"+CRLF
   
cQuery+= "   If @iRecno is null begin"+CRLF
     
cQuery+= "      If @IN_DC = 'D' begin"+CRLF
cQuery+= "         select @nDebito = Round( @IN_VALOR, 2)"+CRLF
cQuery+= "         select @nCredit = 0"+CRLF
cQuery+= "      end else begin"+CRLF
cQuery+= "         select @nCredit = Round( @IN_VALOR, 2)"+CRLF
cQuery+= "         select @nDebito = 0"+CRLF
cQuery+= "      End"+CRLF
      /* ---------------------------------------
         isercao na data do lancto
         --------------------------------------- */
cQuery+= "      Select @iRecno = IsNull( Max( R_E_C_N_O_), 0 ) from "+RetSqlName("CQ3")+CRLF
cQuery+= "      Select @iRecno = @iRecno + 1"+CRLF
cQuery+= "      begin tran"+CRLF
cQuery+= "      ##TRATARECNO @iRecno\"+CRLF
cQuery+= "      insert into "+RetSqlName("CQ3")+" ( CQ3_FILIAL, CQ3_CONTA,  CQ3_CCUSTO,  CQ3_DATA,   CQ3_MOEDA, CQ3_TPSALD, CQ3_LP, CQ3_DEBITO, "+CRLF
cQuery+= "                           CQ3_CREDIT, CQ3_STATUS, CQ3_SLBASE, R_E_C_N_O_ )"+CRLF
cQuery+= "                  Values ( @cFil_CQ3,  @IN_CONTA,  @IN_CUSTO,  @IN_DATA,   @IN_MOEDA, @IN_TPSALD, @cLp,   @nDebito,  "+CRLF
cQuery+= "                           @nCredit, @cStatus, @cSldBase, @iRecno )"+CRLF
cQuery+= "      ##FIMTRATARECNO"+CRLF
cQuery+= "      commit tran"+CRLF
cQuery+= "   end else begin"+CRLF
      /* ---------------------------------------
         Update na data do lancto
         --------------------------------------- */
cQuery+= "      begin tran"+CRLF
cQuery+= "      If @IN_DC = 'D' begin"+CRLF
cQuery+= "         UpDate "+RetSqlName("CQ3")+CRLF
cQuery+= "            Set CQ3_DEBITO = CQ3_DEBITO + Round( @IN_VALOR, 2)"+CRLF
cQuery+= "          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery+= "      end else begin"+CRLF
cQuery+= "         UpDate "+RetSqlName("CQ3")+CRLF
cQuery+= "            Set CQ3_CREDIT = CQ3_CREDIT + Round( @IN_VALOR, 2)"+CRLF
cQuery+= "          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery+= "      end"+CRLF
cQuery+= "      commit tran"+CRLF
cQuery+= "   End"+CRLF
      /* ---------------------------------------
         Lancamentos no Saldo Mensal CQ2
         --------------------------------------- */
cQuery +=CRLF+"  Exec "+aProc[2]+ " @IN_DATA, @cLastDay OutPut"+CRLF+CRLF

cQuery+= "   Select @cAux = 'CQ2'"+CRLF
cQuery+= "   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CQ2 OutPut"+CRLF
cQuery+= "   select @iRecno   = null"+CRLF
cQuery+= "   select @cLp      = 'N'"+CRLF
cQuery+= "   select @nDebito  = 0"+CRLF
cQuery+= "   select @nCredit  = 0"+CRLF
cQuery+= "   select @cStatus  = '1'"+CRLF
cQuery+= "   select @cSldBase = 'S'"+CRLF

cQuery+= "   Select @iRecno = Min( R_E_C_N_O_)"+CRLF
cQuery+= "     From "+RetSqlName("CQ2")+CRLF
cQuery+= "    where CQ2_FILIAL = @cFil_CQ2"+CRLF
cQuery+= "      and CQ2_CONTA  = @IN_CONTA"+CRLF
cQuery+= "      and CQ2_CCUSTO  = @IN_CUSTO"+CRLF
cQuery+= "      and CQ2_DATA   = @cLastDay"+CRLF
cQuery+= "      and CQ2_MOEDA  = @IN_MOEDA"+CRLF
cQuery+= "      and CQ2_TPSALD = @IN_TPSALD"+CRLF
cQuery+= "      and CQ2_LP     = 'N'"+CRLF
cQuery+= "      and D_E_L_E_T_ = ' '"+CRLF
   
cQuery+= "   If @iRecno is null begin"+CRLF
     
cQuery+= "      If @IN_DC = 'D' begin"+CRLF
cQuery+= "         select @nDebito = Round( @IN_VALOR, 2)"+CRLF
cQuery+= "         select @nCredit = 0"+CRLF
cQuery+= "      end else begin"+CRLF
cQuery+= "         select @nCredit = Round( @IN_VALOR, 2)"+CRLF
cQuery+= "         select @nDebito = 0"+CRLF
cQuery+= "      End"+CRLF
      /* ---------------------------------------
         isercao na data do lancto
         --------------------------------------- */
cQuery+= "      Select @iRecno = IsNull( Max( R_E_C_N_O_), 0 ) from "+RetSqlName("CQ2")+CRLF
cQuery+= "      Select @iRecno = @iRecno + 1"+CRLF
cQuery+= "      begin tran"+CRLF
cQuery+= "      ##TRATARECNO @iRecno\"+CRLF
cQuery+= "      insert into "+RetSqlName("CQ2")+" ( CQ2_FILIAL, CQ2_CONTA,  CQ2_CCUSTO,  CQ2_DATA,   CQ2_MOEDA, CQ2_TPSALD, CQ2_LP, CQ2_DEBITO, "+CRLF
cQuery+= "                           CQ2_CREDIT, CQ2_STATUS, CQ2_SLBASE, R_E_C_N_O_ )"+CRLF
cQuery+= "                  Values ( @cFil_CQ2,  @IN_CONTA,  @IN_CUSTO,  @cLastDay,   @IN_MOEDA, @IN_TPSALD, @cLp,   @nDebito,  "+CRLF
cQuery+= "                           @nCredit, @cStatus, @cSldBase, @iRecno )"+CRLF
cQuery+= "      ##FIMTRATARECNO"+CRLF
cQuery+= "      commit tran"+CRLF
cQuery+= "   end else begin"+CRLF
      /* ---------------------------------------
         Update na data do lancto
         --------------------------------------- */
cQuery+= "      begin tran"+CRLF
cQuery+= "      If @IN_DC = 'D' begin"+CRLF
cQuery+= "         UpDate "+RetSqlName("CQ2")+CRLF
cQuery+= "            Set CQ2_DEBITO = CQ2_DEBITO + Round( @IN_VALOR, 2)"+CRLF
cQuery+= "          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery+= "      end else begin"+CRLF
cQuery+= "         UpDate "+RetSqlName("CQ2")+CRLF
cQuery+= "            Set CQ2_CREDIT = CQ2_CREDIT + Round( @IN_VALOR, 2)"+CRLF
cQuery+= "          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery+= "      end"+CRLF
cQuery+= "      commit tran"+CRLF
cQuery+= "   End"+CRLF

cQuery+= "End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0090+cProc)  //"A query de Atualizacao do CQ3 nao passou pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProc )
		iRet := TcSqlExec(cQuery)
		If iRet <> 0
			If !__lBlind
				MsgAlert(STR0091+cProc)  //"Erro na criacao da procedure de Atualizacao do CQ3 "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCTBM300CT7    บAutor ณ TOTVS            บ Data ณ  23/01/09  บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza saldos no CT7                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Nome da procedure                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBM300CT7(cProc, aProc)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local aCampos   := CQ1->(DbStruct())
Local aCampos2  := CQ0->(DbStruct())
Local cQuery    := ""
Local nPos      := 0
Local cTipo     := ""
Local nPTratRec	:= 0
Local nPosFim   := 0
Local cRecnotext:= ""
Local nPosFim2	:= 0
Local cInsertText:= ""
Local cBufferAux := ""
Local nPos3      := 0
Local iRet       := 0

cQuery := "Create procedure "+cProc+"_"+cEmpAnt+" ("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ1_FILIAL" })
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_FILIAL  "+cTipo+CRLF
cQuery += "   @IN_DATA    Char( 08 ),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ1_MOEDA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_MOEDA   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ1_TPSALD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_TPSALD  "+cTipo+CRLF
cQuery += "   @IN_VALOR   float,"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ1_CONTA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_CONTA   "+cTipo+CRLF
cQuery += "   @IN_DC      Char( 01 )"+CRLF
cQuery += ")"+CRLF
cQuery += "as"+CRLF
/* --------------------------------------------------------------------------------------------------
    Atualiza CQ1
   -------------------------------------------------------------------------------------------------- */
cQuery += "Declare @cAux      Char( 03 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ1_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cFil_CQ1  "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CQ1_LP" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cLp       "+cTipo+CRLF
cQuery += "Declare @iRecno    integer"+CRLF
cQuery += "Declare @nDebito   Float"+CRLF
cQuery += "Declare @nCredit   Float"+CRLF
cQuery += "Declare @nCont      Integer"+CRLF
cQuery += "Declare @cLastDay  Char(08)"+CRLF
nPos := Ascan( aCampos2, {|x| Alltrim(x[1]) == "CQ0_FILIAL" } )
cTipo :=  " Char( "+StrZero(aCampos2[nPos][3],3)+" )"
cQuery += "Declare @cFil_CQ0  "+cTipo+CRLF
cQuery += "Declare @cStatus  Char(01)"+CRLF
cQuery += "Declare @cSldBase Char(01)"+CRLF

cQuery +=  ""+CRLF

cQuery += "Begin"+CRLF

cQuery += "   Select @cAux = 'CQ1'"+CRLF
cQuery += "   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CQ1 OutPut"+CRLF
cQuery += "   select @iRecno   = null"+CRLF
cQuery += "   select @cLp      = 'N'"+CRLF
cQuery += "   select @nDebito  = 0"+CRLF
cQuery += "   select @nCredit  = 0"+CRLF
cQuery += "   select @cStatus  = '1'"+CRLF
cQuery += "   select @cSldBase = 'S'"+CRLF
 
cQuery += "   Select @iRecno =  Min( R_E_C_N_O_)"+CRLF
cQuery += "     From "+RetSqlName("CQ1")+CRLF
cQuery += "    where CQ1_FILIAL = @cFil_CQ1"+CRLF
cQuery += "      and CQ1_CONTA  = @IN_CONTA"+CRLF
cQuery += "      and CQ1_DATA   = @IN_DATA"+CRLF
cQuery += "      and CQ1_MOEDA  = @IN_MOEDA"+CRLF
cQuery += "      and CQ1_TPSALD = @IN_TPSALD"+CRLF
cQuery += "      and CQ1_LP     = 'N'"+CRLF
cQuery += "      and D_E_L_E_T_ = ' '"+CRLF
   
cQuery += "   If @iRecno is null begin"+CRLF
cQuery += "      If @IN_DC = 'D' begin"+CRLF
cQuery += "         select @nDebito = Round( @IN_VALOR, 2)"+CRLF
cQuery += "         select @nCredit = 0"+CRLF
cQuery += "      end else begin"+CRLF
cQuery += "         select @nCredit = Round( @IN_VALOR, 2)"+CRLF
cQuery += "         select @nDebito = 0"+CRLF
cQuery += "      End"+CRLF   
      /* ---------------------------------------
         insercao na data do lancto
         --------------------------------------- */
cQuery += "      Select @iRecno = IsNull( Max( R_E_C_N_O_), 0 ) from "+RetSqlName("CQ1")+CRLF
cQuery += "      Select @iRecno = @iRecno + 1"+CRLF
cQuery += "      begin tran"+CRLF
cQuery += "      ##TRATARECNO @iRecno\"+CRLF
cQuery += "      insert into "+RetSqlName("CQ1")+" ( CQ1_FILIAL, CQ1_CONTA,  CQ1_DATA,   CQ1_MOEDA, CQ1_TPSALD, CQ1_LP, CQ1_DEBITO, "+CRLF
cQuery += "                           CQ1_CREDIT, CQ1_STATUS, CQ1_SLBASE, R_E_C_N_O_ )"+CRLF
cQuery += "                  Values ( @cFil_CQ1,  @IN_CONTA,  @IN_DATA,   @IN_MOEDA, @IN_TPSALD, @cLp,   @nDebito,"+CRLF
cQuery += "                           @nCredit, @cStatus, @cSldBase, @iRecno )"+CRLF
cQuery += "      ##FIMTRATARECNO"+CRLF
cQuery += "      commit tran"+CRLF
cQuery += "   end else begin"+CRLF
      /* ---------------------------------------
         Update na data do lancto
         --------------------------------------- */
cQuery += "      begin tran"+CRLF
cQuery += "      If @IN_DC = 'D' begin"+CRLF
cQuery += "         UpDate "+RetSqlName("CQ1")+CRLF
cQuery += "            Set CQ1_DEBITO = CQ1_DEBITO + Round( @IN_VALOR, 2)"+CRLF
cQuery += "          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery += "      end else begin"+CRLF
cQuery += "         UpDate "+RetSqlName("CQ1")+CRLF
cQuery += "            Set CQ1_CREDIT = CQ1_CREDIT + Round( @IN_VALOR, 2)"+CRLF
cQuery += "          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery += "      end"+CRLF
cQuery += "      commit tran"+CRLF
cQuery += "   End"+CRLF
cQuery += "   commit tran"+CRLF

      /* ---------------------------------------
         Atualiza o saldo Menasl CQ0
         --------------------------------------- */
cQuery +=CRLF+"  Exec "+aProc[2]+ " @IN_DATA, @cLastDay OutPut"+CRLF+CRLF

cQuery += "   Select @cAux = 'CQ0'"+CRLF
cQuery += "   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CQ0 OutPut"+CRLF
cQuery += "   select @iRecno   = null"+CRLF
cQuery += "   select @cLp      = 'N'"+CRLF
cQuery += "   select @nDebito  = 0"+CRLF
cQuery += "   select @nCredit  = 0"+CRLF
cQuery += "   select @cStatus  = '1'"+CRLF
cQuery += "   select @cSldBase = 'S'"+CRLF
   
cQuery += "   Select @iRecno =  Min( R_E_C_N_O_)"+CRLF
cQuery += "     From "+RetSqlName("CQ0")+CRLF
cQuery += "    where CQ0_FILIAL = @cFil_CQ1"+CRLF
cQuery += "      and CQ0_CONTA  = @IN_CONTA"+CRLF
cQuery += "      and CQ0_DATA   = @cLastDay"+CRLF
cQuery += "      and CQ0_MOEDA  = @IN_MOEDA"+CRLF
cQuery += "      and CQ0_TPSALD = @IN_TPSALD"+CRLF
cQuery += "      and CQ0_LP     = 'N'"+CRLF
cQuery += "      and D_E_L_E_T_ = ' '"+CRLF
   
cQuery += "   If @iRecno is null begin"+CRLF
cQuery += "      If @IN_DC = 'D' begin"+CRLF
cQuery += "         select @nDebito = Round( @IN_VALOR, 2)"+CRLF
cQuery += "         select @nCredit = 0"+CRLF
cQuery += "      end else begin"+CRLF
cQuery += "         select @nCredit = Round( @IN_VALOR, 2)"+CRLF
cQuery += "         select @nDebito = 0"+CRLF
cQuery += "      End"+CRLF   
      /* ---------------------------------------
         insercao na data do lancto
         --------------------------------------- */
cQuery += "      Select @iRecno = IsNull( Max( R_E_C_N_O_), 0 ) from "+RetSqlName("CQ0")+CRLF
cQuery += "      Select @iRecno = @iRecno + 1"+CRLF
cQuery += "      begin tran"+CRLF
cQuery += "      ##TRATARECNO @iRecno\"+CRLF
cQuery += "      insert into "+RetSqlName("CQ0")+" ( CQ0_FILIAL, CQ0_CONTA,  CQ0_DATA,   CQ0_MOEDA, CQ0_TPSALD, CQ0_LP, CQ0_DEBITO, "+CRLF
cQuery += "                           CQ0_CREDIT, CQ0_STATUS, CQ0_SLBASE, R_E_C_N_O_ )"+CRLF
cQuery += "                  Values ( @cFil_CQ1,  @IN_CONTA,  @cLastDay,   @IN_MOEDA, @IN_TPSALD, @cLp,   @nDebito,"+CRLF
cQuery += "                           @nCredit, @cStatus, @cSldBase, @iRecno )"+CRLF
cQuery += "      ##FIMTRATARECNO"+CRLF
cQuery += "      commit tran"+CRLF
cQuery += "   end else begin"+CRLF
      /* ---------------------------------------
         Update na data do lancto
         --------------------------------------- */
cQuery += "      begin tran"+CRLF
cQuery += "      If @IN_DC = 'D' begin"+CRLF
cQuery += "         UpDate "+RetSqlName("CQ0")+CRLF
cQuery += "            Set CQ0_DEBITO = CQ0_DEBITO + Round( @IN_VALOR, 2)"+CRLF
cQuery += "          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery += "      end else begin"+CRLF
cQuery += "         UpDate "+RetSqlName("CQ0")+CRLF
cQuery += "            Set CQ0_CREDIT = CQ0_CREDIT + Round( @IN_VALOR, 2)"+CRLF
cQuery += "          Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery += "      end"+CRLF
cQuery += "      commit tran"+CRLF
cQuery += "   End"+CRLF
cQuery += "   commit tran"+CRLF

cQuery += "End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0092+cProc)  //"A query de Atualizacao do CQ1 nao passou pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProc )
		iRet := TcSqlExec(cQuery)
		If iRet <> 0
			If !__lBlind
				MsgAlert(STR0093+cProc)  //"Erro na criacao da procedure de Atualizacao do CQ1 "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCTBM300STR    บAutor ณ TOTVS            บ Data ณ  23/01/09  บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Gera msstrzero paracada banco                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Nome da procedure                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBM300STR(cProc)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local cQuery    := ""

cQuery:=ProcSTRZERO(cProc)
cQuery:=CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(STR0094+cProc)   //"Erro na query strzero pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProc )
		iRet := TcSqlExec(cQuery)
		If iRet <> 0
			If !__lBlind
				MsgAlert(STR0095+cProc)  //"Erro na criacao da procedure StrZero "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCTBM300DOC    บAutor ณ TOTVS            บ Data ณ  23/01/09  บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Gera proxima linha, doc e lote                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Nome da procedure                                  บฑฑ
ฑฑบ          ณ EXPA1 - Array aProc[7] com o nome da procedure StrZero     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBM300DOC(cProc, aProc)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local aCampos   := CT2->(DbStruct())
Local cQuery    := ""
Local nPos      := 0
Local cTipo     := ""
Local cMaxLinha := ""

cQuery := "Create procedure "+cProc+"_"+cEmpAnt+" ("+CRLF
cQuery += "   @IN_MAXLINHA integer,"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_LOTE     "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_SBLOTE   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_DOC      "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LINHA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_LINHA    "+cTipo+CRLF    
cMaxLinha := "'"+Replicate('z', aCampos[nPos][3])+"'"
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ) "
cQuery += "   @OUT_LOTE    "+cTipo+" OutPut,"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "   @OUT_SBLOTE  "+cTipo+" OutPut,"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "   @OUT_DOC     "+cTipo+" OutPut,"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LINHA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "   @OUT_LINHA   "+cTipo+" OutPut"+CRLF  


cQuery += ")"+CRLF
cQuery += "as"+CRLF

/* -----------------------------------------------------------------------------------
   Retorna a proxima linha e Lote, Sublote e documento se necessario
   ----------------------------------------------------------------------------------- */
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LINHA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cLinha    "+cTipo+CRLF
cQuery += "Declare @cLinhaIn  "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cLote     "+cTipo+CRLF
cQuery += "Declare @cLoteIn   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cSbLote   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cDoc      "+cTipo+CRLF
cQuery += "Declare @cDocIn    "+cTipo+CRLF
cQuery += "Declare @iLinha    integer"+CRLF  
cQuery += "Declare @iMaxLinha integer"+CRLF
cQuery += "Declare @iTamLinha integer"+CRLF


cQuery += "begin"+CRLF
cQuery += "   select @iMaxLinha = @IN_MAXLINHA"+CRLF
cQuery += "   select @iTamLinha = Len( @IN_LINHA)"+CRLF
cQuery += "   select @cLote     = @IN_LOTE"+CRLF
cQuery += "   select @cSbLote   = @IN_SBLOTE"+CRLF
cQuery += "   select @cDoc      = @IN_DOC"+CRLF
cQuery += "   select @cLinha    = @IN_LINHA "+CRLF

cQuery += "   select @cLinhaIn  = @cLinha"+CRLF
cQuery += "   select @cLoteIn   = @cLote"+CRLF
cQuery += "   select @cDocIn    = @cDoc"+CRLF
   
cQuery += "   If @cLinha = "+cMaxLinha +" begin"+CRLF
cQuery += "      select @iLinha  = 0"+CRLF
cQuery += "      exec "+aProc[7]+" @iLinha, @iTamLinha, @cLinha OutPut"+CRLF  //msstzero
      
cQuery += "      If @cDoc > 'zzzzzz' begin"+CRLF
cQuery += "         select @cDoc = '000000'"+CRLF
cQuery += "         select @cLoteIn = @cLote"+CRLF
cQuery += "         exec "+aProc[8]+" @cLoteIn, '1', @cLote OutPut"+CRLF   // mssoma1
cQuery += "      end else begin"+CRLF
cQuery += "         select @cDocIn = @cDoc"+CRLF
cQuery += "         exec "+aProc[8]+" @cDocIn, '1', @cDoc OutPut"+CRLF
cQuery += "      End"+CRLF
cQuery += "   end else begin"+CRLF
cQuery += "      select @cLinhaIn = @cLinha"+CRLF
cQuery += "      Exec "+aProc[8]+" @cLinhaIn, '1', @cLinha OutPut"+CRLF     
cQuery += "   End"+CRLF 
cQuery += "   select @OUT_LINHA  = @cLinha"+CRLF   
cQuery += "   select @OUT_LOTE   = @cLote"+CRLF
cQuery += "   select @OUT_SBLOTE = @cSbLote"+CRLF
cQuery += "   select @OUT_DOC    = @cDoc"+CRLF
   
cQuery += "End"+CRLF

cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0096+cProc)  //"A query de geracao da Proxima linha, lote, doc nao passou pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProc )
		iRet := TcSqlExec(cQuery)
		If iRet <> 0
			If !__lBlind
				MsgAlert(STR0097+cProc)  //"Erro na criacao da procedure Proxima linha, lote, doc "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCTBM300PAI    บAutor ณ TOTVS            บ Data ณ  23/01/09  บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Copia dos tipos de saldos selecionados                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cProc - Nome da procedure                                  บฑฑ
ฑฑบ          ณ aProc - Array com todas as procedures criadas              บฑฑ
ฑฑบ          ณ         Faz chamada a aProc[8] - CTBM300DOC                บฑฑ
ฑฑบ          ณ         Faz chamada a aProc[6] - CTBM300CQ1                บฑฑ
ฑฑบ          ณ         Faz chamada a aProc[5] - CTBM300CT3                บฑฑ
ฑฑบ          ณ         Faz chamada a aProc[4] - CTBM300CT4                บฑฑ
ฑฑบ          ณ         Faz chamada a aProc[3] - CTBM300CTI                บฑฑ
ฑฑบ          ณ         Faz chamada a aProc[2] - CallxFILIAL               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBM300PAI(cProc, aProc)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local aCampos   := CT2->(DbStruct())
Local cQuery    := ""
Local cDeclare  := ""
Local cSelect   := ""
Local cFetch    := ""
Local nPos      := 0
Local cTipo     := ""
Local nPTratRec	:= 0
Local nPos3      := 0
Local iRet       := 0
Local iX         := 0
Local iY         := 0

cQuery := "Create procedure "+cProc+"_"+cEmpAnt+" ("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_FILIAL    "+cTipo+CRLF
cQuery += "   @IN_DATAINI   Char( 08 ),"+CRLF
cQuery += "   @IN_DATAFIM   Char( 08 ),"+CRLF
cQuery += "   @IN_LTDSMOEDA Char( 01 ),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MOEDLC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_MOEDA     "+cTipo+CRLF
cQuery += "   @IN_TPSDEST   Varchar( 20 ),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_TPSALD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_LCOPIA    integer,"+CRLF
cQuery += "   @IN_TPSORIG   "+cTipo+CRLF
cQuery += "   @IN_LLOTE     integer,"+CRLF
cQuery += "   @IN_LHIST     integer,"+CRLF
cQuery += "   @IN_CODHIST   Char( 003),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_LOTE      "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_SBLOTE    "+cTipo+CRLF
cQuery += "   @IN_MAXLINHA  Integer,"+CRLF
cQuery += "   @IN_LTPSALD   Char( 01 ), "+CRLF
cQuery += "   @OUT_RESULT   Char( 01 ) OutPut"+CRLF
cQuery += ")"+CRLF
cQuery += "as"+CRLF
/* ------------------------------------------------------------------------------------
    Fonte Microsiga - <s>  CTBM300.PRW </s>
    Descricao       - <d>  Copia de Lancamentos </d>
    Entrada         - <ri> @IN_FILIAL     - Filial do processamento
                           @IN_DATAINI    - Data Inicial
                           @IN_DATAFIM    - Data Final
                           @IN_LTDSMOEDA  - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA      - Moeda escolhida
                           @IN_TPSDEST    - Saldos Destinos no formato '12345'
                           @IN_LCOPIA     - 1 - Copia Simples , 2 - Multiplos Saldos
                           @IN_TPSORIG    - Tipo de saldo origem a ser copiado copia simples
                           @IN_LLOTE      - 1 - Mantem Lote e Sblote do Lancto Origem, 2 - pega do parametro
                           @IN_LHIST      - 1 - Mantem historico do lancamento, 2 - Pegar historico do CT8 ( @IN_CODHIST )
                           @IN_CODHIST    - 1 - Codigo do historico padrao usado para copia de lanctos
                           @IN_LOTE       - Lote a ser usado caso mv_par13 =2
                           @IN_SBLOTE     - SbLote a ser usado caso mv_par13 =2
                           @IN_MAXLINHA   - nro maximo da linha
                           @IN_LTPSALD    - 1 = pegar do parametro, 0 = pegar  do CT2_MLTSLD /ri>
   Saida           - <o>   @OUT_RESULT    - Indica o termino OK da procedure </ro>
    Data        :     19/01/2009
   
    1.CTBM300PAI- Copia simples e Multiplos saldos de lancamentos. NAO FAZ copia pelos saldos das contas
      2.1 CTBM300CT7   - Atualizacao de saldos no CQ1
      2.2 CTBM300CT3   - Atualizacao de saldos no CQ3
      2.3 CTBM300CT4   - Atualizacao de saldos no CQ5
      2.4 CTBM300CTI   - Atualizacao de saldos no CTI
      
   Obs:Copia os lanctos do tipo origem para os tipos destinos informado parametro
                   ou multiplosaldos , leio no CT2_MLSTSD de cada lancto origem
                 - somente qdo Sobrepor ou Apagar Lancamentos
   -------------------------------------------------------------------------------------- */
cQuery += "Declare @cAux        Char( 03 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cFil_CT8    "+cTipo+CRLF
cQuery += "Declare @cFil_CT2    "+cTipo+CRLF
/* ----------------------------------------------------
	Monta as variaveis de acordo com a estrutura do CT2
   ----------------------------------------------------*/
For iX =1 to Len( aCampos )
	If Trim(aCampos[ix][1]) = "R_E_C_N_O_" 
		Loop
	Endif
    If aCampos[ix][2] = "C"
		cTipo := " Char("+StrZero(aCampos[ix][3],3)+")"
		cDeclare += "Declare  @c"
    ElseIf aCampos[ix][2] = "N"
        If aCampos[ix][4] = 0
			cTipo := " Integer"
			cDeclare += "Declare  @i"
        Else
			cTipo := " float"
			cDeclare += "Declare  @n"
		EndIf
	ElseIf aCampos[ix][2] = "D"
		cTipo := " Char(08)"
		cDeclare += "Declare  @c"
	EndIf
	cDeclare += Trim(aCampos[ix][1])+cTipo+ CRLF
Next
cQuery += cDeclare+CRLF
/* ------------------------------------------ 
	Variaveis auxiliares
   ------------------------------------------ */
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cLoteIn     "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cSbLoteIn   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cDocIn      "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LINHA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cLinhaIn    "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SEQLAN" } )    
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cSeqLan    "+cTipo+CRLF        
cQuery += "Declare @cCT2_SEQLANOUT    "+cTipo+CRLF        
cQuery += "Declare @cMltSldAux  VarChar( 20 )"+CRLF
cQuery += "Declare @cChar       VarChar( 01 )"+CRLF
cQuery += "Declare @iX          Integer"+CRLF
cQuery += "Declare @iRecnoCT2   Integer"+CRLF
cQuery += "Declare @iRecnoAux   Integer"+CRLF  
cQuery += "Declare @iRecno      Integer"+CRLF
cQuery += "Declare @iRecnoDel   Integer"+CRLF
cQuery += "Declare @iCommit     Integer"+CRLF
cQuery += "Declare @cDc         Char( 01 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MOEDLC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cMoedaAnt   "+cTipo+CRLF
cQuery += "Declare @nValorAnt   Float"+CRLF
cQuery += "Declare @lPrim       Char( 01 )"+CRLF
cQuery += "Declare @lProx       Char( 01 )"+CRLF
cQuery += "Declare @nCont       Integer"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_TPSALD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cTpSald     "+cTipo+CRLF
cQuery += "Declare @nTamHist    integer"+CRLF
cQuery += ""+CRLF

cQuery += "Begin"+CRLF

cQuery += "   Select @OUT_RESULT = '0'"+CRLF
cQuery +="    Select @nTamHist   = "+STR(TamSx3("CT2_HIST")[1])+CRLF
cQuery += "   Select @cAux = 'CT2'"+CRLF
cQuery += "   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CT2 OutPut"+CRLF
cQuery += "   Select @cAux = 'CT8'"+CRLF
cQuery += "   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CT8 OutPut"+CRLF
cQuery += "   Select @iRecnoCT2 = 0"+CRLF
cQuery += "   select @cLoteIn   = @IN_LOTE"+CRLF
cQuery += "   select @cSbLoteIn = @IN_SBLOTE"+CRLF
cQuery += "   Select @cDocIn    = ''"+CRLF
cQuery += "   Select @cLinhaIn  = ''"+CRLF                
cQuery += "   select @cMoedaAnt = ''"+CRLF
cQuery += "   select @lPrim     = '1'"+CRLF
cQuery += "   select @nValorAnt = 0"+CRLF
cQuery += "   select @cTpSald   = ''"+CRLF
cQuery += "	  Select @cCT2_SEQLANOUT = ''"+CRLF           
cQuery += "   select @iCommit = 0" + CRLF
cQuery += "   select @iRecnoDel = 0"+ CRLF

cQuery += "   "+CRLF

IF MV_PAR05 == 2 .AND. MV_PAR01 == 1 // SOMENTE QUANDO FOR COPIA SIMPLES
	/* -------------------------------------------------------------------------------
	   Select do cursor
	   ------------------------------------------------------------------------------- */
	cQuery += "   Declare CUR_MOVDEL insensitive cursor for"+CRLF
	cQuery += "   SELECT R_E_C_N_O_ "+CRLF
	cQuery += "     FROM "+RetSqlName("CT2")+" A,"+CRLF
	cQuery += "          ("+CRLF
	cQuery += "          SELECT DISTINCT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC"+CRLF
	cQuery += "            FROM "+RetSqlName("CT2")+CRLF
	cQuery += "            WHERE CT2_FILIAL = @CFIL_CT2"+CRLF
	cQuery += "             AND CT2_DATA BETWEEN @IN_DATAINI AND @IN_DATAFIM"+CRLF
	cQuery += "             AND ( (CT2_TPSALD = @IN_TPSORIG AND @IN_LTPSALD = '1'  AND CT2_MLTSLD = ' ') OR ( @IN_LTPSALD = '0' AND CT2_MLTSLD != ' '))"+CRLF
	cQuery += "             AND ( (@IN_LTDSMOEDA = '0' AND CT2_MOEDLC = @IN_MOEDA) OR @IN_LTDSMOEDA = '1' )"+CRLF
   //	cQuery += "             AND (  CT2_CTLSLD !=  '2')"+CRLF
	cQuery += "             AND D_E_L_E_T_ = ' '"+CRLF     
	cQuery += "          ) B"+CRLF
	cQuery += "    WHERE A.CT2_FILIAL = @CFIL_CT2"+CRLF
	cQuery += "      AND A.CT2_DATA = B.CT2_DATA "+CRLF
	cQuery += "      AND A.CT2_LOTE = B.CT2_LOTE"+CRLF
	cQuery += "      AND A.CT2_SBLOTE = B.CT2_SBLOTE"+CRLF
	cQuery += "      AND A.CT2_DOC = B.CT2_DOC"+CRLF
	cQuery += "      AND A.CT2_TPSALD = @IN_TPSDEST"+CRLF
	cQuery += "      AND ((@IN_LTDSMOEDA = '0' AND A.CT2_MOEDLC = @IN_MOEDA) OR @IN_LTDSMOEDA = '1' )"+CRLF
	cQuery += "      AND D_E_L_E_T_ = ' '"+CRLF     
	cQuery += "   "+CRLF
	cQuery += "    For read only"+CRLF
	cQuery += "   "+CRLF
	cQuery += "   Open CUR_MOVDEL"+CRLF
	cQuery += "   "+CRLF
	cQuery += "   Fetch CUR_MOVDEL into @iRecnoDel"+ CRLF
	cQuery += "   "+CRLF
	cQuery += "   While ( @@Fetch_Status = 0) begin"+CRLF
	cQuery += "      "+CRLF
	cQuery += "      If @iCommit = 1 begin"+CRLF
	cQuery += "         begin Transaction"+CRLF 
	cQuery += "         Select @iCommit = @iCommit"+CRLF 
	cQuery += "      End"+CRLF
	cQuery += "      "+CRLF
	cQuery += "      DELETE FROM "+RetSqlName("CT2")+ " WHERE R_E_C_N_O_ = @iRecnoDel" + CRLF
	cQuery += "      "+CRLF
	cQuery += "      Select @iCommit = @iCommit + 1"+CRLF
	cQuery += "      "+CRLF
	cQuery += "		 Fetch CUR_MOVDEL into @iRecnoDel" + CRLF
	cQuery += "      "+CRLF
	cQuery += "      If @iCommit >= 10000 begin"+CRLF
	cQuery += "         Commit Transaction "+CRLF
	cQuery += "         Select @iCommit = 1"+CRLF
	cQuery += "      End"+CRLF
	cQuery += "      "+CRLF
	cQuery += "   End" + CRLF
	cQuery += "   "+CRLF
	
	cQuery += "   If @iCommit > 0 begin"+CRLF
	cQuery += "      Commit Transaction"+CRLF
	cQuery += "      Select @iCommit = 1"+CRLF
	cQuery += "   End"+CRLF
	cQuery += "   "+CRLF
	cQuery += "	  Close CUR_MOVDEL" + CRLF
	cQuery += "	  Deallocate CUR_MOVDEL" + CRLF
	cQuery += "   "+CRLF
Endif

cQuery += "   "+CRLF
cQuery += "   Declare CUR_MOVTO insensitive cursor for"+CRLF
cSelect := "   Select "
For iX =1 to Len( aCampos )
	If Trim(aCampos[ix][1]) = "R_E_C_D_E_L_" 
		Loop
	Endif
	If iY >= 10
		iY := 0
		cSelect +=CRLF
		cSelect += "          "
	EndIf
	cSelect += Trim(aCampos[ix][1])+", "
	iY += 1
Next

/* -------------------------------------------------------------------------------
   Select do cursor
   ------------------------------------------------------------------------------- */
cSelect := cSelect + " R_E_C_N_O_ "+CRLF
/*
   Select CT2_FILIAL, CT2_DATA,   CT2_LOTE,   CT2_SBLOTE, CT2_DOC,    CT2_LINHA,  CT2_MOEDLC, CT2_DC,
          CT2_DEBITO, CT2_CREDIT, CT2_DCD,    CT2_DCC,    CT2_VALOR,  CT2_MOEDAS, CT2_HP,     CT2_HIST,
          CT2_CCD,    CT2_CCC,    CT2_ITEMD,  CT2_ITEMC,  CT2_CLVLDB, CT2_CLVLCR, CT2_ATIVDE, CT2_ATIVCR,
          CT2_EMPORI, CT2_FILORI, CT2_INTERC, CT2_IDENTC, CT2_TPSALD, CT2_SEQUEN, CT2_MANUAL, CT2_ORIGEM,
          CT2_ROTINA, CT2_AGLUT,  CT2_LP,     CT2_SEQHIS, CT2_SEQLAN, CT2_DTVENC, CT2_SLBASE, CT2_DTLP,
          CT2_DATATX, CT2_TAXA,   CT2_VLR01,  CT2_VLR02,  CT2_VLR03,  CT2_VLR04,  CT2_VLR05,  CT2_CRCONV,
          CT2_CRITER, CT2_KEY,    CT2_SEGOFI, CT2_DTCV3,  CT2_SEQIDX, CT2_MLTSLD, CT2_CTLSLD, R_E_C_N_O_ */
cQuery += cSelect+CRLF
cQuery += "     From "+RetSqlName("CT2")+CRLF
cQuery += "    Where CT2_FILIAL = @cFil_CT2"+CRLF
cQuery += "      and CT2_DATA between @IN_DATAINI and @IN_DATAFIM"+CRLF
cQuery += "      and ( (CT2_TPSALD = @IN_TPSORIG AND @IN_LTPSALD = '1'  AND CT2_MLTSLD = ' ') OR ( @IN_LTPSALD = '0' AND CT2_MLTSLD != ' '))"+CRLF
cQuery += "      and ( (@IN_LTDSMOEDA = '0' and CT2_MOEDLC = @IN_MOEDA) or @IN_LTDSMOEDA = '1' )"+CRLF
cQuery += "      and (  CT2_CTLSLD !=  '2')"+CRLF
cQuery += "      and D_E_L_E_T_ = ' '"+CRLF     
//cQuery += "    ORDER BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_TPSALD,CT2_EMPORI,CT2_FILORI,CT2_MOEDLC"+CRLF     
cQuery += "    For read only"+CRLF
cQuery += "   Open CUR_MOVTO"+CRLF
/* -------------------------------------------------------------------------------
   Fetch
   ------------------------------------------------------------------------------- */
cFetch := "   Fetch CUR_MOVTO into "
iY := 0
For iX =1 to Len( aCampos )
	If iY >= 10
		iY := 0
		cFetch +=CRLF                     			
				
		cFetch +="                        "
	EndIf
    If aCampos[ix][2] = "C"
		cFetch += "@c"+Trim(aCampos[iX][1])+", "
    ElseIf aCampos[ix][2] = "N"
        If aCampos[ix][4] = 0
			cFetch += "@i"+Trim(aCampos[iX][1])+", "
        Else
			cFetch += "@n"+Trim(aCampos[iX][1])+", "
		EndIf
	ElseIf aCampos[ix][2] = "D"
		cFetch += "@c"+Trim(aCampos[iX][1])+", "
	EndIf
	iY += 1
Next
cFetch := cFetch + "@iRecno"+CRLF
/*
   Fetch CUR_MOVTO into @cCT2_FILIAL, @cCT2_DATA,   @cCT2_LOTE,   @cCT2_SBLOTE, @cCT2_DOC,    @cCT2_LINHA,  @cCT2_MOEDLC, @cCT2_DC,
                        @cCT2_DEBITO, @cCT2_CREDIT, @cCT2_DCD,    @cCT2_DCC,    @nCT2_VALOR,  @cCT2_MOEDAS, @cCT2_HP,     @cCT2_HIST,
                        @cCT2_CCD,    @cCT2_CCC,    @cCT2_ITEMD,  @cCT2_ITEMC,  @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_ATIVDE, @cCT2_ATIVCR,
                        @cCT2_EMPORI, @cCT2_FILORI, @cCT2_INTERC, @cCT2_IDENTC, @cCT2_TPSALD, @cCT2_SEQUEN, @cCT2_MANUAL, @cCT2_ORIGEM,
                        @cCT2_ROTINA, @cCT2_AGLUT,  @cCT2_LP,     @cCT2_SEQHIS, @cCT2_SEQLAN, @cCT2_DTVENC, @cCT2_SLBASE, @cCT2_DTLP,
                        @cCT2_DATATX, @nCT2_TAXA,   @nCT2_VLR01,  @nCT2_VLR02,  @nCT2_VLR03,  @nCT2_VLR04,  @nCT2_VLR05,  @cCT2_CRCONV,
                        @cCT2_CRITER, @cCT2_KEY,    @cCT2_SEGOFI, @cCT2_DTCV3,  @cCT2_SEQIDX, @cCT2_MLTSLD, @cCT2_CTLSLD, @iRecno*/
cQuery += cFetch
cQuery += "   While @@fetch_status = 0 begin"+CRLF
      /* ---------------------------------------------------------------------
         @IN_LHIST =  1 Mantem historico do lancamento
                        2 Pegar historico do CT8 ( @IN_CODHIST )
         --------------------------------------------------------------------- */
cQuery += "      If @IN_LHIST = 2 begin"+CRLF
cQuery += "         Select @cCT2_HIST = Substring( CT8_DESC, 1, @nTamHist)"+CRLF
cQuery += "           From "+RetSqlName("CT8")+CRLF
cQuery += "          Where CT8_FILIAL = @cFil_CT8"+CRLF
cQuery += "            and CT8_HIST   = @IN_CODHIST"+CRLF
cQuery += "            and D_E_L_E_T_ = ' '"+CRLF
cQuery += "      End"+CRLF
      
cQuery += "      select @cMltSldAux = ''"+CRLF
cQuery += "      If @IN_LCOPIA = 2 begin"+CRLF
cQuery += "      	select @iX = 1"+CRLF
cQuery += "	        While @iX <= Len( @cCT2_MLTSLD ) begin"+CRLF
cQuery += " 	       Select @cChar = ''"+CRLF
cQuery += "     	   select @cChar = SubString( @cCT2_MLTSLD, @iX, 1 )"+CRLF
cQuery += "            If @cChar in ( ';',',', '/','|', ' ') or @cChar = @cCT2_TPSALD  begin"+CRLF
cQuery += "			      Select @cChar = ''"+CRLF
cQuery += "            End"+CRLF
cQuery += "            select @cMltSldAux = @cMltSldAux || @cChar"+CRLF
cQuery += "            select @iX = @iX + 1"+CRLF
cQuery += "         End"+CRLF
cQuery += "      End else begin"+CRLF
      /* ---------------------------------------------------------------------
         MV_PAR01 = 1 - COPIA SIMPLES pega os tipo de saldos do @IN_TPSDEST
                    2 - MULTIPLOS SALDOS pega do proprio cpo CT2_MLTSLD
         --------------------------------------------------------------------- */
cQuery += "         If ( @cCT2_CTLSLD = ' ' or @cCT2_CTLSLD = '0') and @cCT2_MLTSLD = ' ' begin"+CRLF
cQuery += "            select @cMltSldAux = @IN_TPSDEST"+CRLF
cQuery += "         end"+CRLF
cQuery += "      End"+CRLF
      /* ---------------------------------------------------------------------
         Qdo muda a chave a linha recebe outrovalor
         --------------------------------------------------------------------- */      
cQuery += "      If @IN_LLOTE = 2 begin"+CRLF
cQuery += "         If @lPrim = '1' begin"+CRLF
cQuery += "            select @cCT2_LOTE   = @IN_LOTE"+CRLF
cQuery += "            select @cCT2_SBLOTE = @IN_SBLOTE"+CRLF
cQuery += "            select @lPrim       = '0'"+CRLF
cQuery += "         end else begin"+CRLF
cQuery += "            select @cCT2_LOTE   = @cLoteIn"+CRLF
cQuery += "            select @cCT2_SBLOTE = @cSbLoteIn"+CRLF
cQuery += "         end"+CRLF
cQuery += "      end"+CRLF

cQuery += "   " + CRLF
cQuery += "    SELECT @cSeqLan =  MAX(CT2_SEQLAN)"+CRLF
cQuery += "     From "+RetSqlName("CT2")+CRLF
cQuery += "    Where CT2_FILIAL = @cCT2_FILIAL"+CRLF
cQuery += "      and CT2_DATA = @cCT2_DATA"+CRLF
cQuery += "      and CT2_LOTE = @cCT2_LOTE"+CRLF
cQuery += "      and CT2_SBLOTE = @cCT2_SBLOTE"+CRLF
cQuery += "      and CT2_DOC = @cCT2_DOC"+CRLF
cQuery += "      and D_E_L_E_T_ = ' '"+CRLF
cQuery += "   " + CRLF

      /* ---------------------------------------------------------------------
         Inicio da geracao do CT2
         --------------------------------------------------------------------- */      
cQuery += "      select @iX = 1"+CRLF
cQuery += "      select @iRecnoCT2 = null"+CRLF
cQuery += "      select @cChar = Substring( @cMltSldAux, @iX, 1 )"+CRLF
cQuery += "      While @iX <= Len( @cMltSldAux )  and @cChar != '#' begin"+CRLF
cQuery += "         If @cChar != @cCT2_TPSALD begin"+CRLF
cQuery += "            select @cLoteIn   = @cCT2_LOTE"+CRLF
cQuery += "            select @cSbLoteIn = @cCT2_SBLOTE"+CRLF
cQuery += "            Select @cDocIn    = @cCT2_DOC"+CRLF
cQuery += "            Select @cLinhaIn  = @cCT2_LINHA"+CRLF   
//cQuery += "            Select @cSeqLan   = @cCT2_SEQLAN"+CRLF                 
cQuery += "  	       If @cCT2_DC <> '4' begin"+CRLF
cQuery += "			       Select @cCT2_SEQLANOUT = @cSeqLan"+CRLF           
//cQuery += "			   End else begin " +CRLF   
cQuery += "      	       Exec "+aProc[8]+" @cSeqLan, '1', @cCT2_SEQLANOUT OutPut"+CRLF     
cQuery += "			   End" +CRLF   
  
      /* ---------------------------------------------------------------------
         Gerar proxima linha, proximo documento e proximo lote
         --------------------------------------------------------------------- */
cQuery += "            Exec "+aProc[9]+" @IN_MAXLINHA, @cLoteIn, @cSbLoteIn, @cDocIn, @cLinhaIn, @cCT2_LOTE OutPut, @cCT2_SBLOTE OutPut, @cCT2_DOC OutPut, @cCT2_LINHA OutPut "+CRLF
            /* ---------------------------------------------------------------------
               Verifica se o lote, sblote, documento, linha ja existe
               --------------------------------------------------------------------- */
cQuery += "            select @lProx = '1'"+CRLF
cQuery += "            While @lProx = '1' begin"+CRLF
cQuery += "               Select @iRecnoAux = Min(R_E_C_N_O_)"+CRLF
cQuery += "                 From "+RetSqlName("CT2")+CRLF
cQuery += "                Where CT2_FILIAL = @cCT2_FILIAL"+CRLF
cQuery += "                  and CT2_DATA   = @cCT2_DATA"+CRLF
cQuery += "                  and CT2_LOTE   = @cCT2_LOTE"+CRLF
cQuery += "                  and CT2_SBLOTE = @cCT2_SBLOTE"+CRLF
cQuery += "                  and CT2_DOC    = @cCT2_DOC"+CRLF
cQuery += "                  and CT2_LINHA  = @cCT2_LINHA"+CRLF  
cQuery += "                  and CT2_EMPORI = @cCT2_EMPORI"+CRLF
cQuery += "                  and CT2_FILORI = @cCT2_FILORI"+CRLF
cQuery += "                  and CT2_MOEDLC = @cCT2_MOEDLC"+CRLF
cQuery += "                  and CT2_SEQIDX = @cCT2_SEQIDX"+CRLF
cQuery += "                  and D_E_L_E_T_ = ' '"+CRLF
               
cQuery += "               If @iRecnoAux is null begin"+CRLF
cQuery += "                  select @lProx = '0'"+CRLF
cQuery += "               End else begin"+CRLF
cQuery += "                  select @cLoteIn   = @cCT2_LOTE"+CRLF
cQuery += "                  select @cSbLoteIn = @cCT2_SBLOTE"+CRLF
cQuery += "                  Select @cDocIn    = @cCT2_DOC"+CRLF
cQuery += "                  Select @cLinhaIn  = @cCT2_LINHA"+CRLF                       
//cQuery += "                  Select @cSeqLan   = @cCT2_SEQLAN"+CRLF   
cQuery += "  	             If @cCT2_DC <> '4' begin"+CRLF
cQuery += "			            Select @cCT2_SEQLANOUT = @cSeqLan"+CRLF           
//cQuery += "			         End else begin " +CRLF   
cQuery += "      		        Exec "+aProc[8]+" @cSeqLan, '1', @cCT2_SEQLANOUT OutPut"+CRLF     
cQuery += "			         End" +CRLF   
cQuery += "                  Exec  "+aProc[9]+" @IN_MAXLINHA, @cLoteIn, @cSbLoteIn, @cDocIn, @cLinhaIn, @cCT2_LOTE OutPut, @cCT2_SBLOTE OutPut, @cCT2_DOC OutPut, @cCT2_LINHA OutPut"+CRLF   
cQuery += "               end"+CRLF
cQuery += "            End"+CRLF

cQuery += "            select @cCT2_CTLSLD = '2'"+CRLF

cQuery += "            select @cTpSald   =  @cChar"+CRLF
cQuery += "            select @iRecnoCT2 = IsNull(Max( R_E_C_N_O_), 0 ) From "+RetSqlName("CT2")+CRLF
cQuery += "            select @iRecnoCT2 = @iRecnoCT2 + 1"+CRLF
cQuery += "            Begin tran"+CRLF
cQuery += "            ##TRATARECNO @iRecnoCT2\"+CRLF
cSelect := StrTran(cSelect,"   Select ","")
cQuery += "            Insert into "+RetSqlName("CT2")+" ("+cSelect+" )"+CRLF
							 /*CT2_FILIAL, CT2_DATA,   CT2_LOTE,   CT2_SBLOTE, CT2_DOC,    CT2_LINHA,  CT2_MOEDLC, CT2_DC,
                               CT2_DEBITO, CT2_CREDIT, CT2_DCD,    CT2_DCC,    CT2_VALOR,  CT2_MOEDAS, CT2_HP,     CT2_HIST,
                               CT2_CCD,    CT2_CCC,    CT2_ITEMD,  CT2_ITEMC,  CT2_CLVLDB, CT2_CLVLCR, CT2_ATIVDE, CT2_ATIVCR,
                               CT2_EMPORI, CT2_FILORI, CT2_INTERC, CT2_IDENTC, CT2_TPSALD, CT2_SEQUEN, CT2_MANUAL, CT2_ORIGEM,
                               CT2_ROTINA, CT2_AGLUT,  CT2_LP,     CT2_SEQHIS, CT2_SEQLAN, CT2_DTVENC, CT2_SLBASE, CT2_DTLP,
                               CT2_DATATX, CT2_TAXA,   CT2_VLR01,  CT2_VLR02,  CT2_VLR03,  CT2_VLR04,  CT2_VLR05,  CT2_CRCONV,
                               CT2_CRITER, CT2_KEY,    CT2_SEGOFI, CT2_DTCV3,  CT2_SEQIDX, CT2_MLTSLD, CT2_CTLSLD, R_E_C_N_O_ */
cFetch := StrTran( cFetch, "   Fetch CUR_MOVTO into ","" )
cFetch := StrTran( cFetch, "@cCT2_TPSALD","@cTpSald" )
cFetch := StrTran( cFetch, "@iRecno","@iRecnoCT2" )
cQuery += "                        Values( "+ StrTran( cFetch, "@cCT2_SEQLAN","@cCT2_SEQLANOUT" )+" )"+CRLF     
							 /*@cCT2_FILIAL, @cCT2_DATA,   @cCT2_LOTE,   @cCT2_SBLOTE, @cCT2_DOC,    @cCT2_LINHA,  @cCT2_MOEDLC, @cCT2_DC,
                               @cCT2_DEBITO, @cCT2_CREDIT, @cCT2_DCD,    @cCT2_DCC,    @nCT2_VALOR,  @cCT2_MOEDAS, @cCT2_HP,     @cCT2_HIST,
                               @cCT2_CCD,    @cCT2_CCC,    @cCT2_ITEMD,  @cCT2_ITEMC,  @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_ATIVDE, @cCT2_ATIVCR,
                               @cCT2_EMPORI, @cCT2_FILORI, @cCT2_INTERC, @cCT2_IDENTC, @cChar,       @cCT2_SEQUEN, @cCT2_MANUAL, @cCT2_ORIGEM,
                               @cCT2_ROTINA, @cCT2_AGLUT,  @cCT2_LP,     @cCT2_SEQHIS, @cCT2_SEQLAN, @cCT2_DTVENC, @cCT2_SLBASE, @cCT2_DTLP,
                               @cCT2_DATATX, @nCT2_TAXA,   @nCT2_VLR01,  @nCT2_VLR02,  @nCT2_VLR03,  @nCT2_VLR04,  @nCT2_VLR05,  @cCT2_CRCONV,
                               @cCT2_CRITER, @cCT2_KEY,    @cCT2_SEGOFI, @cCT2_DTCV3,  @cCT2_SEQIDX, @cCT2_MLTSLD, @cCT2_CTLSLD, @iRecnoCT2*/
cQuery += "            ##FIMTRATARECNO"+CRLF
cQuery += "            Commit Tran"+CRLF
            /* -----------------------------------------------------------------------
               Se moeda especifica e esta nao e '01', gravo lancto zerado na moeda '01
               ------------------------------------------------------------------------ */
cQuery += "            If @IN_LTDSMOEDA = '0' and @cCT2_MOEDLC != '01' begin"+CRLF
cQuery += "               select @cMoedaAnt = @cCT2_MOEDLC"+CRLF
cQuery += "               select @nValorAnt = @nCT2_VALOR"+CRLF
cQuery += "               select @cCT2_MOEDLC = '01'"+CRLF
cQuery += "               select @nCT2_VALOR = 0"+CRLF
cQuery += "               select @cCT2_CTLSLD = '2'"+CRLF
cQuery += "               select @iRecnoCT2 = IsNull(Max( R_E_C_N_O_), 0 ) From "+RetSqlName("CT2")+CRLF
cQuery += "               select @iRecnoCT2 = @iRecnoCT2 + 1"+CRLF
cQuery += "               Begin tran"+CRLF
cQuery += "               ##TRATARECNO @iRecnoCT2\"+CRLF
cQuery += "               Insert into "+RetSqlName("CT2")+" ("+cSelect+" )"+CRLF
								/*CT2_FILIAL, CT2_DATA,   CT2_LOTE,   CT2_SBLOTE, CT2_DOC,    CT2_LINHA,  CT2_MOEDLC, CT2_DC,
                                  CT2_DEBITO, CT2_CREDIT, CT2_DCD,    CT2_DCC,    CT2_VALOR,  CT2_MOEDAS, CT2_HP,     CT2_HIST,
                                  CT2_CCD,    CT2_CCC,    CT2_ITEMD,  CT2_ITEMC,  CT2_CLVLDB, CT2_CLVLCR, CT2_ATIVDE, CT2_ATIVCR,
                                  CT2_EMPORI, CT2_FILORI, CT2_INTERC, CT2_IDENTC, CT2_TPSALD, CT2_SEQUEN, CT2_MANUAL, CT2_ORIGEM,
                                  CT2_ROTINA, CT2_AGLUT,  CT2_LP,     CT2_SEQHIS, CT2_SEQLAN, CT2_DTVENC, CT2_SLBASE, CT2_DTLP,
                                  CT2_DATATX, CT2_TAXA,   CT2_VLR01,  CT2_VLR02,  CT2_VLR03,  CT2_VLR04,  CT2_VLR05,  CT2_CRCONV,
                                  CT2_CRITER, CT2_KEY,    CT2_SEGOFI, CT2_DTCV3,  CT2_SEQIDX, CT2_MLTSLD, CT2_CTLSLD, R_E_C_N_O_ */
cQuery += "                           Values( "+StrTran( cFetch, "@cCT2_SEQLAN","@cCT2_SEQLANOUT" )+" )"+CRLF 
								/*@cCT2_FILIAL, @cCT2_DATA,   @cCT2_LOTE,   @cCT2_SBLOTE, @cCT2_DOC,    @cCT2_LINHA,  @cCT2_MOEDLC, @cCT2_DC,
                                  @cCT2_DEBITO, @cCT2_CREDIT, @cCT2_DCD,    @cCT2_DCC,    @nCT2_VALOR,  @cCT2_MOEDAS, @cCT2_HP,     @cCT2_HIST,
                                  @cCT2_CCD,    @cCT2_CCC,    @cCT2_ITEMD,  @cCT2_ITEMC,  @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_ATIVDE, @cCT2_ATIVCR,
                                  @cCT2_EMPORI, @cCT2_FILORI, @cCT2_INTERC, @cCT2_IDENTC, @cChar,       @cCT2_SEQUEN, @cCT2_MANUAL, @cCT2_ORIGEM,
                                  @cCT2_ROTINA, @cCT2_AGLUT,  @cCT2_LP,     @cCT2_SEQHIS, @cCT2_SEQLAN, @cCT2_DTVENC, @cCT2_SLBASE, @cCT2_DTLP,
                                  @cCT2_DATATX, @nCT2_TAXA,   @nCT2_VLR01,  @nCT2_VLR02,  @nCT2_VLR03,  @nCT2_VLR04,  @nCT2_VLR05,  @cCT2_CRCONV,
                                  @cCT2_CRITER, @cCT2_KEY,    @cCT2_SEGOFI, @cCT2_DTCV3,  @cCT2_SEQIDX, @cCT2_MLTSLD, @cCT2_CTLSLD, @iRecnoCT2 */
cQuery += "               ##FIMTRATARECNO"+CRLF
cQuery += "               Commit Tran"+CRLF
cQuery += "               select @cCT2_MOEDLC = @cMoedaAnt"+CRLF
cQuery += "               select @nCT2_VALOR  = Round(@nValorAnt, 2)"+CRLF
cQuery += "            End"+CRLF

           /* ---------------------------------------------------------------------
               Atualizar Cabecalho do Movimento gerado
               --------------------------------------------------------------------- */

cQuery += "             If @cDc <> '4' begin"+CRLF
cQuery += " 	            Exec "+aProc[10]+ " @cCT2_FILIAL , @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_MOEDLC,  @cChar,  @nCT2_VALOR, @cCT2_DC"+CRLF
cQuery += " 	            If @cCT2_DEBITO != ' ' begin"+CRLF
cQuery += " 	               Select @cDc = 'D'"+CRLF
cQuery += " 	               Exec "+aProc[6]+ " @IN_FILIAL, @cCT2_DATA, @cCT2_MOEDLC, @cChar, @nCT2_VALOR, @cCT2_DEBITO, @cDc"+CRLF
cQuery += " 	            End"+CRLF
cQuery += " 	            If @cCT2_CCD != ' ' begin"+CRLF
cQuery += " 	               Select @cDc = 'D'"+CRLF
cQuery += " 	               Exec "+aProc[5]+ " @IN_FILIAL, @cCT2_DATA, @cCT2_MOEDLC, @cChar, @nCT2_VALOR, @cCT2_DEBITO, @cCT2_CCD, @cDc"+CRLF
cQuery += " 	            End"+CRLF
cQuery += " 	            If @cCT2_ITEMD != ' ' begin"+CRLF
cQuery += " 	               Select @cDc = 'D'"+CRLF
cQuery += " 	               Exec "+aProc[4]+ " @IN_FILIAL, @cCT2_DATA, @cCT2_MOEDLC, @cChar, @nCT2_VALOR, @cCT2_DEBITO, @cCT2_CCD, @cCT2_ITEMD, @cDc"+CRLF
cQuery += " 	            End"+CRLF
cQuery += " 	            If @cCT2_CLVLDB != ' ' begin"+CRLF
cQuery += " 	               Select @cDc = 'D'"+CRLF
cQuery += " 	               Exec "+aProc[3]+ " @IN_FILIAL, @cCT2_DATA, @cCT2_MOEDLC, @cChar, @nCT2_VALOR, @cCT2_DEBITO, @cCT2_CCD, @cCT2_ITEMD, @cCT2_CLVLDB, @cDc"+CRLF
cQuery += " 	            End"+CRLF
cQuery += " 	            If @cCT2_CREDIT != ' ' begin"+CRLF
cQuery += " 	               Select @cDc = 'C'"+CRLF
cQuery += " 	               Exec "+aProc[6]+ " @IN_FILIAL, @cCT2_DATA, @cCT2_MOEDLC, @cChar, @nCT2_VALOR, @cCT2_CREDIT, @cDc"+CRLF
cQuery += " 	            End"+CRLF
cQuery += " 	            If @cCT2_CCC != ' ' begin"+CRLF
cQuery += " 	               Select @cDc = 'C'"+CRLF
cQuery += " 	               Exec "+aProc[5]+ " @IN_FILIAL, @cCT2_DATA, @cCT2_MOEDLC, @cChar, @nCT2_VALOR, @cCT2_CREDIT, @cCT2_CCC, @cDc"+CRLF
cQuery += " 	            End"+CRLF
cQuery += " 	            If @cCT2_ITEMC != ' ' begin"+CRLF
cQuery += " 	               Select @cDc = 'C'"+CRLF
cQuery += " 	               Exec "+aProc[4]+ " @IN_FILIAL, @cCT2_DATA, @cCT2_MOEDLC, @cChar, @nCT2_VALOR, @cCT2_CREDIT, @cCT2_CCC, @cCT2_ITEMC, @cDc"+CRLF
cQuery += " 	            End"+CRLF
cQuery += " 	            If @cCT2_CLVLCR != ' ' begin"+CRLF
cQuery += " 	               Select @cDc = 'C'"+CRLF
cQuery += " 	               Exec "+aProc[3]+ " @IN_FILIAL, @cCT2_DATA, @cCT2_MOEDLC, @cChar, @nCT2_VALOR, @cCT2_CREDIT, @cCT2_CCC, @cCT2_ITEMC, @cCT2_CLVLCR, @cDc"+CRLF
cQuery += " 	            End"+CRLF
cQuery += "         	End"+CRLF
cQuery += "         End"+CRLF
cQuery += "         select @iX = @iX + 1"+CRLF
cQuery += "         select @cChar = Substring( @cMltSldAux, @iX, 1 )"+CRLF
cQuery += "      End"+CRLF
      /* ---------------------------------------------------------------------
         Marca o lancamento como copiado
         --------------------------------------------------------------------- */
cQuery += "      begin tran"+CRLF
cQuery += "      Update "+RetSqlName("CT2")+CRLF
cQuery += "         Set CT2_CTLSLD = '2'"+CRLF
cQuery += "       where R_E_C_N_O_ = @iRecno"+CRLF
cQuery += "      Commit tran"+CRLF
      /* ---------------------------------------------------------------------
         Guardo a chave anterior
         --------------------------------------------------------------------- */
cQuery += "      select @cLoteIn   = @cCT2_LOTE"+CRLF
cQuery += "      select @cSbLoteIn = @cCT2_SBLOTE"+CRLF
cQuery += "      select @cDocIn    = @cCT2_DOC"+CRLF
cQuery += "      select @cLinhaIn  = @cCT2_LINHA"+CRLF
cFetch := StrTran( cFetch, "@cChar", "@cCT2_TPSALD") 
cFetch := StrTran( cFetch, "@iRecnoCT2" ,"@iRecno")
cFetch := "   Fetch CUR_MOVTO into "+cFetch
cQuery += cFetch
/*      Fetch CUR_MOVTO into @cCT2_FILIAL, @cCT2_DATA,   @cCT2_LOTE,   @cCT2_SBLOTE, @cCT2_DOC,    @cCT2_LINHA,  @cCT2_MOEDLC, @cCT2_DC,
                           @cCT2_DEBITO, @cCT2_CREDIT, @cCT2_DCD,    @cCT2_DCC,    @nCT2_VALOR,  @cCT2_MOEDAS, @cCT2_HP,     @cCT2_HIST,
                           @cCT2_CCD,    @cCT2_CCC,    @cCT2_ITEMD,  @cCT2_ITEMC,  @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_ATIVDE, @cCT2_ATIVCR,
                           @cCT2_EMPORI, @cCT2_FILORI, @cCT2_INTERC, @cCT2_IDENTC, @cCT2_TPSALD, @cCT2_SEQUEN, @cCT2_MANUAL, @cCT2_ORIGEM,
                           @cCT2_ROTINA, @cCT2_AGLUT,  @cCT2_LP,     @cCT2_SEQHIS, @cCT2_SEQLAN, @cCT2_DTVENC, @cCT2_SLBASE, @cCT2_DTLP,
                           @cCT2_DATATX, @nCT2_TAXA,   @nCT2_VLR01,  @nCT2_VLR02,  @nCT2_VLR03,  @nCT2_VLR04,  @nCT2_VLR05,  @cCT2_CRCONV,
                           @cCT2_CRITER, @cCT2_KEY,    @cCT2_SEGOFI, @cCT2_DTCV3,  @cCT2_SEQIDX, @cCT2_MLTSLD, @cCT2_CTLSLD, @iRecno*/
cQuery += "   End"+CRLF
cQuery += "   close CUR_MOVTO"+CRLF
cQuery += "   deallocate CUR_MOVTO"+CRLF
   
cQuery += "   Select @OUT_RESULT = '1'"+CRLF
cQuery += "End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0098+cProc)  //"A query de COPIA nao passou pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProc )
		iRet := TcSqlExec(cQuery)
		If iRet <> 0
			If !__lBlind
				MsgAlert(STR0099+cProc)  //"Erro na criacao da procedure de COPIA "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return(lRet)

/* --------------------------------------------------------------------
Funcao xFilial para uso dentro do corpo das procedures dinamicas do PCO
Recebe como parametro as strings das variaveis da procedure a serem
utilizadas : Alias, Filial atual ou default, e filial de retorno
Retorna o corpo da xfilial a ser executado.
OBSERVACAO : PARA USO DA FUNCAO, DEVE SER DECLARADA A VARIAVEL @NCONT NO INICIO DA PROCEDURE
OUTRA OBSERVACAO : Deu erro no AS400 , nao sabemos por que. Reclama de passagem de valores null como parametro.
Nao achamos onde era, e trocamos pela query direta. Funciona, sem erro, e torna esse programa 
totalmente independente da aplicacao de procedures do padrao.
-------------------------------------------------------------------- */
STATIC Function CallXFilial(cArq)
Local aSaveArea := GetArea()
Local cProc   := cArq+"_"+cEmpAnt
Local cQuery  := ""
Local lRet    := .T.
Local aCampos := CT2->(DbStruct())
Local nPos    := 0
Local cTipo   := ""

cQuery :="Create procedure "+cProc+CRLF
cQuery +="( "+CRLF
cQuery +="  @IN_ALIAS        Char(03),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery +="  @IN_FILIALCOR    "+cTipo+","+CRLF
cQuery +="  @OUT_FILIAL      "+cTipo+" OutPut"+CRLF
cQuery +=")"+CRLF
cQuery +="as"+CRLF

/* -------------------------------------------------------------------
    Versใo      -  <v> Gen้rica </v>
    Assinatura  -  <a> 010 </a>
    Descricao   -  <d> Retorno o modo de acesso da tabela em questao </d>

    Entrada     -  <ri> @IN_ALIAS        - Tabela a ser verificada
                        @IN_FILIALCOR    - Filial corrente </ri>

    Saida       -  <ro> @OUT_FILIAL      - retorna a filial a ser utilizada </ro>
                   <o> brancos para modo compartilhado @IN_FILIALCOR para modo exclusivo </o>

    Responsavel :  <r> Alice Yaeko </r>
    Data        :  <dt> 14/12/10 </dt>
   
   X2_CHAVE X2_MODO X2_MODOUN X2_MODOEMP X2_TAMFIL X2_TAMUN X2_TAMEMP
   -------- ------- --------- ---------- --------- -------- ---------
   CT2      E       E         E          3.0       3.0        2.0       
      X2_CHAVE   - Tabela
      X2_MODO    - Comparti/o da Filial, 'E' exclusivo e 'C' compartilhado
      X2_MODOUN  - Comparti/o da Unidade de Neg๓cio, 'E' exclusivo e 'C' compartilhado
      X2_MODOEMP - Comparti/o da Empresa, 'E' exclusivo e 'C' compartilhado
      X2_TAMFIL  - Tamanho da Filial
      X2_TAMUN   - Tamanho da Unidade de Negocio
      X2_TAMEMP  - tamanho da Empresa
   
   Existe hierarquia no compartilhamento das entidades filial, uni// de negocio e empresa.
   Se a Empresa for compartilhada as demais entidades DEVEM ser compartilhadas
   Compartilhamentos e tamanhos possํveis
   compartilhaemnto         tamanho ( zero ou nao zero)
   EMP UNI FIL             EMP UNI FIL
   --- --- ---             --- --- ---
    C   C   C               0   0   X   -- 1 - somente filial
    E   C   C               0   X   X   -- 2 - filial e unidade de negocio
    E   E   C               X   0   X   -- 3 - empresa e filial
    E   E   E               X   X   X   -- 4 - empresa, unidade de negocio e filial
------------------------------------------------------------------- */
cQuery +="Declare @cModo    Char( 01 )"+CRLF
cQuery +="Declare @cModoUn  Char( 01 )"+CRLF
cQuery +="Declare @cModoEmp Char( 01 )"+CRLF
cQuery +="Declare @iTamFil  Integer"+CRLF
cQuery +="Declare @iTamUn   Integer"+CRLF
cQuery +="Declare @iTamEmp  Integer"+CRLF

cQuery +="begin"+CRLF
  
cQuery +="  Select @OUT_FILIAL = ' '"+CRLF
cQuery +="  Select @cModo = ' ', @cModoUn = ' ', @cModoEmp = ' '"+CRLF
cQuery +="  Select @iTamFil = 0, @iTamUn = 0, @iTamEmp = 0"+CRLF
  
cQuery +="  Select @cModo = X2_MODO,   @cModoUn = X2_MODOUN, @cModoEmp = X2_MODOEMP,"+CRLF
cQuery +="         @iTamFil = X2_TAMFIL, @iTamUn = X2_TAMUN, @iTamEmp = X2_TAMEMP"+CRLF
cQuery +="    From SX2"+cEmpAnt+"0"+CRLF
cQuery +="   Where X2_CHAVE = @IN_ALIAS"+CRLF
cQuery +="     and D_E_L_E_T_ = ' '"+CRLF
  
  /*   SITUACAO -> 1 somente FILIAL */
cQuery +="  If ( @iTamEmp + @iTamUn + @iTamFil ) = 2 begin"+CRLF   //  -- so tem filial tam 2 sem gestao
cQuery +="    If @cModo = 'C' select @OUT_FILIAL = '  '"+CRLF
cQuery +="    else select @OUT_FILIAL = @IN_FILIALCOR"+CRLF
cQuery +="  end else begin"+CRLF
    /*  SITUACAO -> 2 UNIDADE DE NEGOCIO e FILIAL  */
cQuery +="    If @iTamEmp = 0 begin"+CRLF
cQuery +="      If @cModoUn = 'E' begin"+CRLF
cQuery +="        If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamUn + 1, @iTamFil )"+CRLF
cQuery +="        else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)"+CRLF
cQuery +="      end"+CRLF
cQuery +="    end else begin"+CRLF
      /* SITUACAO -> 4 EMPRESA, UNIDADE DE NEGOCIO e FILIAL */
cQuery +="      If @iTamUn > 0 begin"+CRLF
cQuery +="        If @cModoEmp = 'E' begin"+CRLF
cQuery +="          If @cModoUn = 'E' begin"+CRLF
cQuery +="            If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamEmp+@iTamUn + 1, @iTamFil )"+CRLF
cQuery +="            else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)"+CRLF
cQuery +="          end else begin"+CRLF
cQuery +="            select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery +="          end"+CRLF
cQuery +="        end"+CRLF
cQuery +="      end else begin"+CRLF
        /*  SITUACAO -> 3 EMPRESA e FILIAL */
cQuery +="        If @cModoEmp = 'E' begin"+CRLF
cQuery +="          If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring( @IN_FILIALCOR, @iTamEmp+1, @iTamFil )"+CRLF
cQuery +="          else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery +="        end"+CRLF
cQuery +="      end"+CRLF
cQuery +="    end"+CRLF
cQuery +="  end"+CRLF
cQuery +="end"+CRLF

cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0103+cProc) //'A query da filial nใo passou pelo Parse'
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0104 +cProc)  //"Erro na cria็ใo da procedure da filial: 
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCTM300SOMA    บAutor ณ TOTVS            บ Data ณ  23/01/09  บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Gera mssoma1 para banco respectivo                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Nome da procedure                                  บฑฑ
ฑฑบ          ณ EXPC2 - MsstrZero criado previamente                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTM300SOMA(cProc, cStrZero)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local cQuery    := ""

cQuery:= cProcSOMA1(cProc, cStrZero)
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(STR0094+cProc)   //"Erro na query strzero pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProc )
		iRet := TcSqlExec(cQuery)
		If iRet <> 0
			If !__lBlind
				MsgAlert(STR0095+cProc)  //"Erro na criacao da procedure StrZero "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return(lRet)
            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA105   บAutor  ณMicrosiga           บ Data ณ  08/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbLinMax(nMv_NumLin)
Local nRet := 0

If nMv_NumLin >= 35658  //limite estabelecido em razao do tamanho campo CT2_LINHA  = 3 e utilizar a funcao Soma1() para incremento
	nRet := 35658
Else
	nRet := nMv_NumLin
EndIf

Return(nRet)   

Function CTBM300LDAY(cProc, aProc)
Local cQuery    := ""
Local nPTratRec	:= 0
Local iRet       := 0
Local lRet := .T.

cQuery := "Create procedure "+cProc+"_"+cEmpAnt+" ("+CRLF //LASTDAY
cQuery += "   @IN_DATA  Char( 08 ),"+CRLF
cQuery += "   @OUT_DATA Char( 08 ) OutPut "+CRLF
cQuery += "    )"+CRLF
cQuery += " as"+CRLF
/* -------------------------------------------------------------------
    Versใo      -  <v> Gen้rica </v>
    Assinatura  -  <a> 001 </a>
    Descricao   -  <d> Retorna o ultimo dia do m๊s </d>
      
    Entrada     -  <ri> @IN_DATA         - Data qualquer </ri>

    Saida       -  <ro> @OUT_DATA        - Retorno - Ultimo dia da data qualquer  </ro>
                   <o>  </o>

    Responsavel :  <r> Alice Y Yamamoto </r>
    Data        :  <dt> 14/05/10 </dt>
------------------------------------------------------------------- */

cQuery += " Declare @cData    VarChar( 08 )"+CRLF
cQuery += " Declare @iAno     Float"+CRLF
cQuery += " Declare @iResto   Float"+CRLF
cQuery += " Declare @iPos     Integer"+CRLF
cQuery += " Declare @cResto   VarChar( 10 )"+CRLF

cQuery += " begin"+CRLF
cQuery += "    Select @OUT_DATA = ' '"+CRLF
cQuery += "    Select @cData  = Substring( @IN_DATA, 5, 2 )"+CRLF //Mes
cQuery += "    select @iAno   = 0"+CRLF
cQuery += "    select @iResto = 0"+CRLF
cQuery += "    Select @iPos   = 0"+CRLF
cQuery += "    select @cResto = ''"+CRLF
   
   /* --------------------------------------------------------------
      Ultimo dia do periodo para atualizacao do AKS
      -------------------------------------------------------------- */
cQuery += "    If @cData IN ( '01', '03', '05', '07', '08','10','12' ) begin"+CRLF
cQuery += "      select @cData = Substring( @IN_DATA, 1, 6 )||'31'"+CRLF
cQuery += "    end else begin"+CRLF
cQuery += "       If @cData = '02' begin"+CRLF
cQuery += "          Select @iAno = Convert( float, Substring(@IN_DATA, 1,4) )"+CRLF
cQuery += "          Select @iResto = @iAno/4"+CRLF
cQuery += "          Select @cResto = Convert( varchar( 10 ), @iResto )"+CRLF
         /* --------------------------------------------------------------
            nao existe '.' no @cResto , o nro ้ inteiro, divisivel por 4
            O ano deve ser m๚ltiplo de 100, ou seja, divisํvel por 400
            -------------------------------------------------------------- */
cQuery += "          Select @iPos   = Charindex( '.', @cResto )"+CRLF
cQuery += "          If @iPos = 0 begin"+CRLF
cQuery += "             select @cData = Substring( @IN_DATA, 1, 6 )||'29'"+CRLF
cQuery += "             If @iAno in ( 2100, 2200, 2300, 2500 ) begin   -- ANOS NAO DIVISอVEIS POR 400"+CRLF
cQuery += "                select @cData = Substring( @IN_DATA, 1, 6 )||'28'"+CRLF
cQuery += "             End"+CRLF
cQuery += "          end else begin"+CRLF
cQuery += "             select @cData = Substring( @IN_DATA, 1, 6 )||'28'"+CRLF
cQuery += "          end"+CRLF
cQuery += "       end else begin"+CRLF
cQuery += "          select @cData = Substring( @IN_DATA, 1, 6 )||'30'"+CRLF
cQuery += "       End"+CRLF
cQuery += "    End"+CRLF
cQuery += "    Select @OUT_DATA = @cData"+CRLF
cQuery += " End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0105+cProc) //"A query de Cแlculo da data final do perํodo nใo passou pelo Parse " 
	lRet := .F.
Else
	If !TCSPExist( cProc )
		iRet := TcSqlExec(cQuery)
		If iRet <> 0
			If !__lBlind
				MsgAlert(STR0106+cProc) 
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
                                           
Return(lRet)                               

Function CTBM300CTC(cProc, aProc)
Local cQuery    := ""
Local nPTratRec	:= 0
Local iRet       := 0
Local lRet := .T.
Local aCampos := CTC->(dbStruct())

cQuery += "Create procedure "+cProc+"_"+cEmpAnt+" ("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CTC_FILIAL" } )
cTipo :=  " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_FILIAL  "+cTipo+CRLF
cQuery += "   @IN_CT2_DATA     Char(8),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CTC_LOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_CT2_LOTE  "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CTC_SBLOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_CT2_SBLOTE  "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CTC_DOC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_CT2_DOC   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CTC_MOEDA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_CT2_MOEDLC "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CTC_TPSALD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery += "   @IN_TPSALDO     "+cTipo+CRLF
cQuery += "   @IN_CT2_VALOR   Float,"+CRLF
cQuery += "   @IN_CT2_DC Char(01)"+CRLF
cQuery += ")"+CRLF
cQuery += " as "+CRLF

cQuery+="Declare @cAux      Char( 03 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CTC_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cFilial_CTC  "+cTipo+CRLF
cQuery+="Declare @iRecno    integer"+CRLF
cQuery+="Declare @iRecnoNew integer"+CRLF
cQuery+="Declare @nCTC_DEBITO   Float"+CRLF
cQuery+="Declare @nCTC_CREDIT   Float"+CRLF
cQuery+="Declare @nCTC_DEBITOX   Float"+CRLF
cQuery+="Declare @nCTC_CREDITX   Float"+CRLF
cQuery+="Declare @nCTC_DIGX  Float"+CRLF
cQuery+="Declare @nCTC_DIG  Float"+CRLF
cQuery+="Declare @cMVSOMA Char(01)"+CRLF

cQuery+=""+CRLF
cQuery+="Begin"+CRLF
cQuery+="  select @cMVSOMA = '"+Str(GetMV("MV_SOMA"),1,0)+"'"+CRLF
cQuery+= "   exec "+aProc[1]+" 'CTC', @IN_FILIAL, @cFilial_CTC OutPut"+CRLF

cQuery+=" Select @iRecno = IsNull( MIN(R_E_C_N_O_),0 )"+CRLF
cQuery+="  From "+RetSqlName("CTC")+CRLF
cQuery+="  Where CTC_FILIAL = @cFilial_CTC"+CRLF
cQuery+="  and CTC_DATA   = @IN_CT2_DATA"+CRLF
cQuery+="  and CTC_LOTE   = @IN_CT2_LOTE"+CRLF
cQuery+="  and CTC_SBLOTE = @IN_CT2_SBLOTE"+CRLF
cQuery+="  and CTC_DOC    = @IN_CT2_DOC"+CRLF
cQuery+="  and CTC_MOEDA  = @IN_CT2_MOEDLC"+CRLF
cQuery+="  and CTC_TPSALD = @IN_TPSALDO"+CRLF
cQuery+="  and D_E_L_E_T_ = ' '"+CRLF
      
cQuery+=" If @iRecno = 0 begin"+CRLF
         /* --------------------------------------------------------------------------
            Recupera o R_E_C_N_O_ para ser gravado
            -------------------------------------------------------------------------- */
cQuery+="  select @iRecnoNew = Max(R_E_C_N_O_) FROM "+RetSqlName("CTC")+CRLF
cQuery+="  select @iRecnoNew = @iRecnoNew + 1"+CRLF
cQuery+="  if (@iRecnoNew is null or @iRecnoNew = 0) select @iRecnoNew = 1"+CRLF

cQuery+="  select @nCTC_DEBITOX = 0"+CRLF                
cQuery+="  select @nCTC_CREDITX = 0"+CRLF
cQuery+="  select @nCTC_DIGX = 0"+CRLF
         
cQuery+="  if @IN_CT2_DC IN ('1','3') begin"+CRLF
cQuery+="     select @nCTC_DEBITOX = Round(@IN_CT2_VALOR, 2)"+CRLF
cQuery+="  end"+CRLF
cQuery+="  if @IN_CT2_DC IN ('2','3') begin"+CRLF
cQuery+="     select @nCTC_CREDITX = Round(@IN_CT2_VALOR, 2)"+CRLF
cQuery+="  end"+CRLF
cQuery+=" If @IN_CT2_DC = '3' begin"
cQuery+="   If @cMVSOMA = '1' Select @nCTC_DIGX = Round(@IN_CT2_VALOR, 2)"+CRLF
cQuery+="   else Select @nCTC_DIGX = Round(( 2 * @IN_CT2_VALOR ), 2)"+CRLF
cQuery+=" end else Select @nCTC_DIGX = Round(@IN_CT2_VALOR, 2)"+CRLF
         
cQuery+=" end else begin"+CRLF
         
cQuery+=" Select @nCTC_DIG = CTC_DIG, @nCTC_DEBITO = CTC_DEBITO, @nCTC_CREDIT = CTC_CREDIT"+CRLF
cQuery+="   From "+RetSqlName("CTC")+CRLF
cQuery+=" Where R_E_C_N_O_ = @iRecno "+CRLF
         
cQuery+=" if @IN_CT2_DC = '1' begin"+CRLF
cQuery+="   select @nCTC_DEBITOX = Round(@nCTC_DEBITO + @IN_CT2_VALOR, 2)"+CRLF
cQuery+="   select @nCTC_CREDITX = Round(@nCTC_CREDIT, 2)"+CRLF
cQuery+=" end"+CRLF
cQuery+=" if @IN_CT2_DC ='2' begin"+CRLF
cQuery+="    select @nCTC_CREDITX = Round(@nCTC_CREDIT + @IN_CT2_VALOR, 2)"+CRLF
cQuery+="    select @nCTC_DEBITOX = Round(@nCTC_DEBITO, 2)"+CRLF
cQuery+=" end"+CRLF
cQuery+=" If @IN_CT2_DC = '3' begin"+CRLF
cQuery+="    select @nCTC_DEBITOX = Round(@nCTC_DEBITO + @IN_CT2_VALOR, 2)"+CRLF
cQuery+="    select @nCTC_CREDITX = Round(@nCTC_CREDIT + @IN_CT2_VALOR, 2)"+CRLF
            
cQuery+="    If @cMVSOMA = '1' select @nCTC_DIGX = Round((@nCTC_DIG + @IN_CT2_VALOR), 2)"+CRLF
cQuery+="    else select @nCTC_DIGX  = Round(@nCTC_DIG + ( 2 * @IN_CT2_VALOR ), 2)"+CRLF
cQuery+=" end else select @nCTC_DIGX = Round(@nCTC_DIG + @IN_CT2_VALOR, 2)"+CRLF
         
cQuery+="end"+CRLF
      /*---------------------------------------------------------------
        Insercao / Atualizacao CTC
      --------------------------------------------------------------- */
cQuery+="If @iRecno = 0 begin"+CRLF
cQuery+="##TRATARECNO @iRecnoNew\ "+CRLF
cQuery+=" Begin Tran"+CRLF

cQuery+=" Insert into  "+RetSqlName("CTC") +"( CTC_FILIAL, CTC_MOEDA,  CTC_TPSALD,  CTC_DATA,   CTC_LOTE,  CTC_SBLOTE, CTC_DOC,   CTC_STATUS, CTC_DEBITO,  CTC_CREDIT, CTC_DIG,   R_E_C_N_O_ )"+CRLF
cQuery+="                               values( @cFilial_CTC, @IN_CT2_MOEDLC, @IN_TPSALDO,   @IN_CT2_DATA,  @IN_CT2_LOTE, @IN_CT2_SBLOTE,  @IN_CT2_DOC,   '1',          @nCTC_DEBITOX, @nCTC_CREDITX, @nCTC_DIGX, @iRecnoNew  )" +CRLF

cQuery+=" Commit Tran"+CRLF
cQuery+=" ##FIMTRATARECNO"+CRLF
cQuery+="end else begin"+CRLF
cQuery+=" Begin Tran"+CRLF
cQuery+="Update "+RetSqlName("CTC")+CRLF
cQuery+="    Set CTC_DEBITO = @nCTC_DEBITOX, CTC_CREDIT = @nCTC_CREDITX, CTC_DIG = @nCTC_DIGX"+CRLF
cQuery+="  Where R_E_C_N_O_ = @iRecno"+CRLF
cQuery+="  Commit Tran"+CRLF
cQuery+=" End"+CRLF
cQuery+="End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If Empty( cQuery )
	MsgAlert(MsParseError(),STR0107 +cProc) //"A query de Grava็ใo do Cabe็alho do Lan็amento nใo passou pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProc )
		iRet := TcSqlExec(cQuery)
		If iRet <> 0
			If !__lBlind
				MsgAlert(STR0108+cProc) // "Erro na Cria็ใo da de Grava็ใo do Cabe็alho do Lan็amento " 
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
                                           
Return(lRet)                               
//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna os parametros no schedule.

@return aReturn			Array com os parametros

@author  TOTVS
@since   07/04/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "CTBM30",;		//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            STR0001}				//Titulo - Copia de saldos

Return aParam