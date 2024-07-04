#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "GPER906.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER906  ³ Autor ³ Alex Sandro Fagundes	³ Data ³ 22/09/10	         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emite PLR - Participacao nos Lucros e Resultados - Equador			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER906()                                                	         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico - Equador                                              	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³Chamado    ³Motivo da Alteracao 		                     ³±±
±±³Kelly S.    ³27/10/11³TDUJOF     ³Ajuste na picture de campos de valor.           ³±±
±±³Emerson Camp³21/12/11³TEEDLX     ³Ajustes para funcionamento da Query.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function GPER906()
	Private cCadastro		:= OemToAnsi(STR0001) 	// "Processos de Cálculo"
	Private bDialogInit								//bloco de inicializacao da janela
	Private bBtnCalcule								//bloco do botão OK
	Private bSet15			:= { || NIL }
	Private bSet24			:= { || NIL }
	Private oGroup
	Private oLbxSource
	Private oFont
	Private oDlg
	Private aSays			:= {}		// array com as mensagem para visualizacao na caixa de Processamento	
	Private aButtons		:= {}		// botoes da caixa de processamento
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis        - para carregar os periodos abertos / fechados	     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aPerAberto    := {}
	Private aPerFechado   := {}
	Private nX			  := 0
	Private nTpImpre	  := 0
	Private oBtnDtrA
	Private oBtnDtrBV
	Private cPeriodos		:= ""
	Private cRoteiro		:= ""
	Private cAliasSRA 		:= "QSRA"
	Private cAliasSRJ		:= "QSRJ"
	Private cAliasSRC		:= "QSRC"
	Private cCodProv 		:= ""	//Busca Codigo da Provincia
	Private cDesProv 		:= "" 	//Busca Codigo da Provincia
	Private cDescCan 		:= "" 	//Busca Descrição da Canton
	Private cDesParr 		:= "" 	//Busca Descrição da Parroquia
	Private cEmpresa		:= ""
	Private cRUC			:= ""
	Private cTelef			:= ""
	Private cEnde			:= ""
	Private cCnae			:= ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis para totalizadores                                         |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cQtEmple := 0
	Private cQtEmpH  := 0
	Private cQtEmpM  := 0
	Private cQtEmpHE := 0
	Private cQtEmpME := 0 

	Private cQtOb := 0
	Private cQtObH  := 0
	Private cQtObM  := 0
	Private cQtObHE := 0
	Private cQtObME := 0 

	Private cQtEs := 0
	Private cQtEsH  := 0
	Private cQtEsM  := 0
	Private cQtEsHE := 0
	Private cQtEsME := 0 

	Private cTotHomBs := 0
	Private cTotMujBs := 0
	Private cTotHomVl := 0
	Private cTotMujVl := 0

	Private nAux	:= 0  
	Private nLin	:= 0770
	Private nCont	:= 1
	Private nContGeral:= 1
	Private nFrente	:= 0
	Private aFuncs	:= {  }
	Private cMesIni	:= ""
	Private cMesFim	:= ""
	Private oPrint
	
	oFont05	:= TFont():New("Courier New",05,05,,.F.,,,,.T.,.F.)
	oFont06	:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)
	oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
	oFont08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oFont25n:= TFont():New("Courier New",25,25,,.T.,,,,.T.,.F.)     //Negrito// 
	oFont11n:= TFont():New("Courier New",11,11,,.T.,,,,.T.,.F.)     //Negrito//
	oFont17n:= TFont():New("Courier New",17,17,,.T.,,,,.T.,.F.)     //Negrito//
	oFont11	:= TFont():New("Courier New",11,11,,.F.,,,,.T.,.F.) 

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Restaurar as informacoes do Ultimo Pergunte                   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Pergunte("GPER906",.F.)
	    
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Janela de Processamento do Fechamento                         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	AADD(aSays, OemToAnsi( STR0002 ) )	// "Este programa efetua a impressao do relatorio Empresarial sobre a Décima"
	AADD(aSays, OemToAnsi( STR0003 ) )	// "terceira remuneracao, a ser entregue ao MTE - Ministerio do trabalho e  "
	AADD(aSays, OemToAnsi( STR0004 ) )	// "Emprego. Informe os parametros necessarios e em seguida clique em       "
	AADD(aSays, OemToAnsi( STR0005 ) )	// "processar.                                                              "
	AADD(aSays, ""					 )

	AADD(aButtons, { 5,.T., { || Pergunte("GPER906", .T. ) } } )
	AADD(aButtons, { 1,.T., {|| fSetVar() }} )
	AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

	FormBatch( cCadastro, aSays, aButtons )

	//-Apaga o Alias QSRA
	If Select(cAliasSRA) > 0
  		(cAliasSRA)->( dbclosearea() )
 	EndIf
Return() 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R906ImpB    ºAutor  ³Alex Sandro Fagundes º Data ³  02/09/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a folha DTR(B)                                           º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sem programa definido										 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R906ImpB()
	Local nAux	:= 0  
	oFont05	:= TFont():New("Courier New",05,05,,.F.,,,,.T.,.F.)
	oFont06	:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)
	oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
	oFont08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oFont25n:= TFont():New("Courier New",25,25,,.T.,,,,.T.,.F.)     //Negrito// 
	oFont11n:= TFont():New("Courier New",11,11,,.T.,,,,.T.,.F.)     //Negrito//
	oFont17n:= TFont():New("Courier New",17,17,,.T.,,,,.T.,.F.)     //Negrito//
	oFont11	:= TFont():New("Courier New",11,11,,.F.,,,,.T.,.F.) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregar os periodos abertos (aPerAberto) e/ou fechados	     ³
	//³ (aPerFechado), de acordo com a competencia de calculo.		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fRetPerComp( cMes, cAno, Nil, Nil, Nil, @aPerAberto, @aPerFechado)

	If !(len(aPerAberto) < 1) .OR. !(len(aPerFechado) < 1)
		If !(len(aPerAberto) < 1)
			//busca periodos para formato Query
			cPeriodos   := ""
			For nAux:= 1 to (len(aPerAberto))
				cPeriodos += "'" + aPerAberto[nAux][1] + "'"
				If ( nAux+1 ) <= (len(aPerAberto))
					cPeriodos += ","
				EndIf
			Next nAux
		EndIf			
		If !(len(aPerFechado) < 1)
			//busca periodos para formato Query
			cPeriodos   := "" 
			For nAux:= 1 to (len(aPerFechado))
				cPeriodos += "'" + aPerFechado[nAux][1] + "'"
				If ( nAux+1 ) <= (len(aPerFechado))
					cPeriodos += ","
				EndIf
			Next nAux
		EndIf
		cPeriodos := "%" + cPeriodos + "%"
		fFuncsUtil(cPeriodos,cRoteiro)
	EndIf

	If Select(cAliasSRA) > 0
		oPrint:StartPage() 							//Inicia uma nova pagina   
	
		LimpaP()
		nCont		:= 1
		nContGeral	:= 1
		While (cAliasSRA)->(!Eof())
			If nDuplex == 1
				ImpDetFS()
			Else 
				ImpDetFN()
			EndIf
				
			(cAliasSRA)->(dbSkip())
		End
			        
		oPrint:EndPage()
	Else
		MsgAlert( STR0002 )
	EndIf		
	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpDetFS    ºAutor  ³Alex Sandro Fagundes º Data ³  02/09/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua impressao da linha do funcionario                       º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sem programa definido										 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpDetFS()
	ImpInfFunc(@nLin,@nCont,@nContGeral)
	fTotaliza()
	nLin += 115
	nCont += 1

	If nFrente == 0
		If nCont == 14
			oPrint:EndPage()
			If nCont <= Len(aFuncs)
				oPrint:StartPage() 							//Inicia uma nova pagina   
			EndIf
			nLin  := 0570
			nCont := 1
			nFrente := 1
		EndIf
	Else 
		If nCont == 15
			oPrint:EndPage()
			If nCont <= Len(aFuncs)
				oPrint:StartPage() 							//Inicia uma nova pagina   
			EndIf
			nLin  := 0770
			nCont := 1
			nFrente := 0
		EndIf
	EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpDetFN    ºAutor  ³Alex Sandro Fagundes º Data ³  02/09/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a folha DTR(B)                                           º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sem programa definido										 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpDetFN()
	If nFrente == 0
		ImpInfFunc(@nLin,@nCont,@nContGeral)
		fTotaliza()
		nLin += 115
		nCont += 1
		If nCont == 14
			oPrint:EndPage()
			If nCont <= Len(aFuncs)
				oPrint:StartPage() 							//Inicia uma nova pagina   
			EndIf
			nLin  := 0570
			nCont := 1
			nFrente := 1
		EndIf
	Else      
		AddInfFunc(@nLin,@nCont,@nContGeral)
		fTotaliza()
		nLin += 115
		nCont += 1
		If nCont == 15
			nLin  := 0770
			nCont := 1
			nFrente := 0
		EndIf
	EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpInfFuncºAutor  ³Alex Sandro Fagundesº Data ³  15/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao das informacoes do funcionario.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gper906 - Chamado na funcao: R906ImpB e R906ImpA           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºParametros³ nLin  - Controle de onde a linha e impressa                º±±
±±º          ³ nCont - Contador de Funcionario impresso                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpInfFunc(nLin,nCont,nContGeral)
	Local nCampo1	:= 0
	Local nCampo2	:= 0	
	Local nCampo3	:= 0
	Local nCampo4	:= 0
	Local nCampo5	:= 0
	Local nCampo6	:= 0
	Local nCampo7	:= 0
	Local nCampo8	:= 0
	
	If nFrente = 0
		nCampo1	:= 130
		nCampo2	:= 840
		If QSRA->SEXO == "M"
			nCampo3	:= 1220
		Else
			nCampo3	:= 1345
		EndIf
		nCampo4	:= 1470
		nCampo5	:= 1690
		nCampo6	:= 1920
		nCampo7	:= 2140
		nCampo8	:= 2370
	Else 
		nCampo1	:= 90
		nCampo2	:= 790
		If QSRA->SEXO == "M"
			nCampo3	:= 1170
		Else
			nCampo3	:= 1315
		EndIf
		nCampo4	:= 1420
		nCampo5	:= 1640
		nCampo6	:= 1870
		nCampo7	:= 2110
		nCampo8	:= 2320
	EndIf

	oPrint:say ( nLin, 0001, Transform(nContGeral,"999"), oFont11 )
	oPrint:say ( nLin, nCampo1, SubStr(QSRA->NOME,1,27), oFont11 ) 
	oPrint:say ( nLin, nCampo2, SubStr(QSRA->FUNCAO,1,13), oFont11 ) 
	If QSRA->SEXO == "M"
		oPrint:say ( nLin, nCampo3, "0", oFont11 )
	Else
		oPrint:say ( nLin, nCampo3, "1", oFont11 )	
	EndIf
	// Tempo trabajado periodo
	oPrint:say ( nLin, nCampo4, Transform(QSRA->TOTDIAS10,"99999"), oFont11 ) 
	// Valor calculado 10%
	oPrint:say ( nLin, nCampo5, Transform(QSRA->TOTAL10,"@E 999,999,999.99"), oFont11 )	
	// No. Cargas familiares
	oPrint:say ( nLin, nCampo6, Transform(QSRA->TOTDIAS5,"99999"), oFont11 )	
	// Valor calculado 5%
	oPrint:say ( nLin, nCampo7, Transform(QSRA->TOTAL5,"@E 999,999,999.99"), oFont11 )	
	// Total 15%	
	oPrint:say ( nLin, nCampo8, Transform(QSRA->TOTAL10+QSRA->TOTAL5,"@E 999,999,999.99"), oFont11 )	
	
	nContGeral += 1

Return()
        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpArrFuncºAutor  ³Alex Sandro Fagundesº Data ³  15/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao das informacoes do funcionario.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gper906 - Chamado na funcao: R906ImpB e R906ImpA           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºParametros³ nLin  - Controle de onde a linha e impressa                º±±
±±º          ³ nCont - Contador de Funcionario impresso                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpArrFunc(nX)
	Local nCampo1	:= 0
	Local nCampo2	:= 0	
	Local nCampo3	:= 0
	Local nCampo4	:= 0
	Local nCampo5	:= 0
	Local nCampo6	:= 0
	Local nCampo7	:= 0
	Local nCampo8	:= 0
	
	If nFrente = 0
		nCampo1	:= 130
		nCampo2	:= 840
		If QSRA->SEXO == "M"
			nCampo3	:= 1220
		Else
			nCampo3	:= 1345
		EndIf
		nCampo4	:= 1470
		nCampo5	:= 1690
		nCampo6	:= 1920
		nCampo7	:= 2140
		nCampo8	:= 2370
	Else 
		nCampo1	:= 90
		nCampo2	:= 790
		If QSRA->SEXO == "M"
			nCampo3	:= 1170
		Else
			nCampo3	:= 1315
		EndIf
		nCampo4	:= 1420
		nCampo5	:= 1640
		nCampo6	:= 1870
		nCampo7	:= 2110
		nCampo8	:= 2320
	EndIf


	oPrint:say ( nLin, 0001, aFuncs[nX, 1], oFont11 )
	oPrint:say ( nLin, nCampo1, AllTrim(aFuncs[nX, 2]), oFont11 ) 
	oPrint:say ( nLin, nCampo2, aFuncs[nX, 3], oFont11 ) 

	If aFuncs[nX,4] == "0"
		oPrint:say ( nLin, nCampo3, "0", oFont11 )
	Else
		oPrint:say ( nLin, nCampo3, "1", oFont11 )	
	EndIf

	// Tempo trabajado periodo
	oPrint:say ( nLin, nCampo4, aFuncs[nX, 5], oFont11 ) 
	// Valor calculado 10%
	oPrint:say ( nLin, nCampo5, aFuncs[nX, 6], oFont11 ) 
	// No. Cargas familiares
	oPrint:say ( nLin, nCampo6, aFuncs[nX, 7], oFont11 )	
	// Valor calculado 5%
	oPrint:say ( nLin, nCampo7, aFuncs[nX, 8], oFont11 )	
	// Total 15%	
	oPrint:say ( nLin, nCampo8, aFuncs[nX, 9], oFont11 )	

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AddInfFuncºAutor  ³Alex Sandro Fagundesº Data ³  15/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Array  Verso B                                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gper906                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºParametros³ nLin  - Controle de onde a linha e impressa                º±±
±±º          ³ nCont - Contador de Funcionario impresso                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AddInfFunc(nLin,nCont,nContGeral)
	Local cSexo := ""

	If QSRA->SEXO == "M"
		cSexo := "0"
	Else
		cSexo := "1"
	EndIf

	AADD(aFuncs, {Transform(nContGeral,"9999"),;
				  SubStr(QSRA->NOME,1,27),;
				  SubStr(QSRA->FUNCAO,1,13),;
				  cSexo,;
				  Transform(QSRA->TOTDIAS10,"99999"),;					// Tempo trabajado periodo
				  Transform(QSRA->TOTAL10,"@E 999,999,999.99"),;				// Valor calculado 10%
				  Transform(QSRA->TOTDIAS5,"99999"),;					// No. cargas familiares
				  Transform(QSRA->TOTAL5,"@E 999,999,999.99"),;					// Valor calculado 5%
				  Transform(QSRA->TOTAL10+QSRA->TOTAL5,"@E 999,999,999.99") } )	// Total 15%

	nContGeral += 1		

Return()
	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CabecEmp    ºAutor  ³Alex Sandro Fagundes º Data ³  17/09/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CabecEmp - Carrega informacoes da Empresa                      º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sem programa definido										 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CabecEmp()
	cCodProv 	:= fDescRcc("S021","01",1,2,3,2)		//Busca Codigo da Provincia
	cDesProv 	:= POSICIONE("SX5",1,XFILIAL("SX5")+"12"+cCodProv,"X5_DESCRI")//Busca Codigo da Provincia
	cDescCan 	:= fDescRcc("S021","01",1,2,6,20)  	//Busca Descrição da Canton
	cDesParr 	:= fDescRcc("S021","01",1,2,26,20)	//Busca Descrição da Parroquia
	cEmpresa	:= SM0->M0_NOME
	cRUC		:= SM0->M0_CGC
	cTelef		:= SM0->M0_TEL
	cEnde		:= SM0->M0_ENDCOB
	cCnae		:= SM0->M0_CNAE

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R906ImpA    ºAutor  ³Alex Sandro Fagundes º Data ³  02/09/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a folha DTR(A)                                           º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sem programa definido										 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R906ImpA()                   
                                             
	cMesIni := "Enero"
	
	If (year(SRA->RA_ADMISSA)) == Val(cAno)
		cMesIni	:= MesExtenso( Month( SRA->RA_ADMISSA ) )
	EndIf

	cMesFim	:= "Diciembre"
	If (year(SRA->RA_DEMISSA)) == Val(cAno)
		cMesFim	:= MesExtenso( Month( SRA->RA_DEMISSA ) )
	EndIf

	oFont05	:= TFont():New("Courier New",05,05,,.F.,,,,.T.,.F.)
	oFont06	:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)
	oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
	oFont08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oFont11	:= TFont():New("Courier New",11,11,,.F.,,,,.T.,.F.) 
	oFont25n:= TFont():New("Courier New",25,25,,.T.,,,,.T.,.F.)     //Negrito// 
	oFont11n:= TFont():New("Courier New",11,11,,.T.,,,,.T.,.F.)     //Negrito//
	oFont17n:= TFont():New("Courier New",17,17,,.T.,,,,.T.,.F.)     //Negrito//

		oPrint:StartPage() 							//Inicia uma nova pagina   
		
			oPrint:say ( 0450, 0850, cMesIni, oFont11n )
			oPrint:say ( 0450, 1470, cMesFim, oFont11n ) 
			oPrint:say ( 0450, 2130, cAno, oFont11n ) 
			
			CabecEmp()

			//Linha No RUC, Atividade Economica, Provincia, Canton e Parroquia
			oPrint:say ( 0690, 0200, cRUC, oFont11 )
			oPrint:say ( 0690, 0880, cCnae, oFont11 )
			oPrint:say ( 0690, 1320, cDesProv, oFont11 )    // Provincia
			oPrint:say ( 0690, 1900, cDescCan, oFont11 )	// Canton
			oPrint:say ( 0690, 2480, cDesParr, oFont11 )	// Parroquia
                                 
			// Dados da Empresa
			oPrint:say ( 1000, 0550, cEmpresa, oFont11 )
			oPrint:say ( 1000, 2500, cTelef, oFont11 )
                                                           
			//Endereço da Empresa
			oPrint:say ( 1130, 0280, cEnde, oFont11 )
			
			//Empregados por categorias             
			//Empleados
			oPrint:say ( 1582, 0280, Transform(cQtEmple,"99999"), oFont11 )		// Total
			oPrint:say ( 1582, 0500, Transform(cQtEmpH,"99999"), oFont11 )		// Nacionales - Hombres
			oPrint:say ( 1582, 0720, Transform(cQtEmpM,"99999"), oFont11 )  	// Nacionales - Mujeres
			oPrint:say ( 1582, 0940, Transform(cQtEmpHE,"99999"), oFont11 )		// Extranjeros - Hombres
			oPrint:say ( 1582, 1180, Transform(cQtEmpME,"99999"), oFont11 )		// Extranjeros - Mujeres

			//Obreros
			oPrint:say ( 1682, 0280, Transform(cQtOb,"99999"), oFont11 )		//Total
			oPrint:say ( 1682, 0500, Transform(cQtObH,"99999"), oFont11 )      	// Nacionales - Hombres
			oPrint:say ( 1682, 0720, Transform(cQtObM,"99999"), oFont11 )		// Nacionales - Mujeres
			oPrint:say ( 1682, 0940, Transform(cQtObHE,"99999"), oFont11 )		// Extranjeros - Hombres
			oPrint:say ( 1682, 1180, Transform(cQtObME,"99999"), oFont11 )     	// Extranjeros - Mujeres

			//Aprencices
			oPrint:say ( 1782, 0280, Transform(cQtEs,"99999"), oFont11 )      	//Total
			oPrint:say ( 1782, 0500, Transform(cQtEsH,"99999"), oFont11 )		// Nacionales - Hombres
			oPrint:say ( 1782, 0720, Transform(cQtEsM,"99999"), oFont11 )		// Nacionales - Mujeres
			oPrint:say ( 1782, 0940, Transform(cQtEsHE,"99999"), oFont11 )		// Extranjeros - Hombres
			oPrint:say ( 1782, 1180, Transform(cQtEsME,"99999"), oFont11 )		// Extranjeros - Mujeres

			//Total
			oPrint:say ( 1882, 0280, Transform(cQtEmple+cQtOb+cQtEs,"99999"), oFont11 )		// Total dos Totais por categ
			oPrint:say ( 1882, 0500, Transform(cQtEmpH+cQtObH+cQtEsH,"99999"), oFont11 )    // Total dos HOMBRES Nacionales
			oPrint:say ( 1882, 0720, Transform(cQtEmpM+cQtEsM,"99999"), oFont11 )			// Total dos MUJERES Nacionales
			oPrint:say ( 1882, 0940, Transform(cQtEmpHE+cQtObHE+cQtEsHE,"99999"), oFont11 )	// Total dos HOMBRES Extranjeros
			oPrint:say ( 1882, 1180, Transform(cQtEmpME+cQtObME+cQtEsME,"99999"), oFont11 )	// Total dos MUJERES Extranjeros

			oPrint:say ( 1545, 2350, Transform(cTotMujVl,"@E 999,999,999.99"), oFont11 )		// 3. Utilidad de 01/01 a 31/12
			oPrint:say ( 1645, 2350, Transform(cTotMujVl,"@E 999,999,999.99"), oFont11 )		// 4.-Utilidad distribuida (15%)
			oPrint:say ( 1745, 2350, Transform(cTotHomVl,"@E 999,999,999.99"), oFont11 )		// HOMBRES
			oPrint:say ( 1845, 2350, Transform(cTotMujVl,"@E 999,999,999.99"), oFont11 )		// MUJERES
			
		oPrint:EndPage()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fFuncsUtil  ºAutor  ³Alex Sandro Fagundes º Data ³  02/09/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Conta os funcionarios por categoria ocupacional. Nacionais.    º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sem programa definido										 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fFuncsUtil(cPeriodos,cRoteiro)
	Local cV10		:= ""
	Local cV5		:= ""
	Local nReg		:= 0	
	Local cRotQuery := ""
	
	If !Empty(cRoteiro)
		For nReg:=1 to Len(cRoteiro) Step 3
			If Subs(cRoteiro,nReg,3) <> '***'
				cRotQuery += "'"+Subs(cRoteiro,nReg,3)+"', "
			EndIf
		Next nReg		
		cRotQuery	:= "%" + Subs(cRotQuery,1,Len(cRotQuery)-2) + "%"
	Else
		cRotQuery	:= "%''%"
    EndIf

	If !Empty(mv_par01)  		
		cFiltro	:= RANGESX1("RA_FILIAL",mv_par01)		
		cFiltro	:= "%"+cFiltro+"%"
	EndIf
	
	cV10	:= "'" + FGETCODFOL( "0881" ) + "'"	// 10%
	cV10 	:= "%" + cV10 + "%"
	cV5		:= "'" + FGETCODFOL( "1201" ) + "'"	// 5%
	cV5 	:= "%" + cV5 + "%"
	
	SRA->( dbCloseArea() ) //Fecha o SRA para uso da Query
	SRC->( dbCloseArea() ) //Fecha o SRC para uso da Query
	SRD->( dbCloseArea() ) //Fecha o SRC para uso da Query

	If Select(cAliasSRA) > 0
  		(cAliasSRA)->( dbclosearea() )
 	EndIf

	If !(len(aPerAberto) < 1)
		//montagem da query 
		BeginSql alias cAliasSRA
			SELECT	FILIAL, MATRICULA, NOME, SEXO, PAIS, FUNCAO, PERIODO, CATEGORIA,
					SUM(DIAS10) TOTDIAS10, SUM(DIAS5) TOTDIAS5, SUM(VRB10) TOTAL10, SUM(VRB5) TOTAL5
			FROM
				(SELECT	RA_FILIAL FILIAL, RA_MAT MATRICULA, RA_NOME NOME, RA_CATFUNC CATEGORIA, RA_SEXO SEXO, 
						RA_CODPAIS PAIS, RJ_DESC FUNCAO, RC_PERIODO PERIODO, RC_HORAS DIAS10, 0 DIAS5, RC_VALOR VRB10, 0 VRB5
				FROM  %table:SRA% SRA	
				INNER JOIN %table:SRC% SRC
				ON SRA.RA_FILIAL = SRC.RC_FILIAL AND SRA.RA_MAT = SRC.RC_MAT
				INNER JOIN %table:SRJ% SRJ 
				ON SRA.RA_CODFUNC = SRJ.RJ_FUNCAO
				WHERE 	%exp:cFiltro% AND
						SRC.RC_PERIODO IN (%exp:Upper(cPeriodos)%) AND
						SRC.RC_ROTEIR  IN (%exp:Upper(cRotQuery)%) AND
						SRC.RC_PD 	   =  %exp:Upper(cV10)% AND
						SRA.%notDel% AND SRC.%notDel%                      
						
						
			UNION
				SELECT	RA_FILIAL FILIAL, RA_MAT MATRICULA, RA_NOME NOME, RA_CATFUNC CATEGORIA, 
						RA_SEXO SEXO, RA_CODPAIS PAIS, RJ_DESC FUNCAO, RC_PERIODO PERIODO, 
						0 DIAS10, RC_HORAS DIAS5, 0 VRB10, RC_VALOR VRB5
				FROM  %table:SRA% SRA 
				INNER JOIN  %table:SRC% SRC ON SRA.RA_FILIAL = SRC.RC_FILIAL AND SRA.RA_MAT = SRC.RC_MAT 
				INNER JOIN  %table:SRJ% SRJ ON SRA.RA_CODFUNC = SRJ.RJ_FUNCAO 
				WHERE	%exp:cFiltro% AND
						SRC.RC_PERIODO IN (%exp:Upper(cPeriodos)%) AND 
						SRC.RC_ROTEIR IN (%exp:Upper(cRotQuery)%) AND 
						SRC.RC_PD 	  =  %exp:Upper(cV5)% AND 
						SRA.D_E_L_E_T_= ' ' AND SRC.D_E_L_E_T_= ' '						
				) tView 
			GROUP BY FILIAL,MATRICULA,NOME,SEXO, PAIS, FUNCAO, PERIODO, CATEGORIA
		EndSql
	ElseIf !(len(aPerFechado) < 1)
		BeginSql alias cAliasSRA
			SELECT	FILIAL, MATRICULA, NOME, SEXO, PAIS, FUNCAO, PERIODO, CATEGORIA,
					SUM(DIAS10) TOTDIAS10, SUM(DIAS5) TOTDIAS5, SUM(VRB10) TOTAL10, SUM(VRB5) TOTAL5
			FROM
				(SELECT	RA_FILIAL FILIAL, RA_MAT MATRICULA, RA_NOME NOME, RA_CATFUNC CATEGORIA, RA_SEXO SEXO, 
						RA_CODPAIS PAIS, RJ_DESC FUNCAO, RD_PERIODO PERIODO, RD_HORAS DIAS10, 0 DIAS5, RD_VALOR VRB10, 0 VRB5
				FROM  %table:SRA% SRA	
				INNER JOIN %table:SRD% SRD
				ON SRA.RA_FILIAL = SRD.RD_FILIAL AND SRA.RA_MAT = SRD.RD_MAT
				INNER JOIN %table:SRJ% SRJ 
				ON SRA.RA_CODFUNC = SRJ.RJ_FUNCAO
				WHERE 	%exp:cFiltro% AND
						SRD.RD_PERIODO IN (%exp:Upper(cPeriodos)%) AND
						SRD.RD_ROTEIR  IN (%exp:Upper(cRotQuery)%) AND
						SRD.RD_PD 	   =  %exp:Upper(cV10)% AND
						SRA.%notDel% AND SRD.%notDel%
			UNION
				SELECT	RA_FILIAL FILIAL, RA_MAT MATRICULA, RA_NOME NOME, RA_CATFUNC CATEGORIA, 
						RA_SEXO SEXO, RA_CODPAIS PAIS, RJ_DESC FUNCAO, RD_PERIODO PERIODO, 
						0 DIAS10, RD_HORAS DIAS5, 0 VRB10, RD_VALOR VRB5
				FROM  %table:SRA% SRA 
				INNER JOIN  %table:SRD% SRD ON SRA.RA_FILIAL = SRD.RD_FILIAL AND SRA.RA_MAT = SRD.RD_MAT 
				INNER JOIN  %table:SRJ% SRJ ON SRA.RA_CODFUNC = SRJ.RJ_FUNCAO 
				WHERE	%exp:cFiltro% AND
						SRD.RD_PERIODO IN (%exp:Upper(cPeriodos)%) AND 
						SRD.RD_ROTEIR IN (%exp:Upper(cRotQuery)%) AND 
						SRD.RD_PD 	  =  %exp:Upper(cV5)% AND 
						SRA.D_E_L_E_T_= ' ' AND SRD.D_E_L_E_T_= ' '						
				) tView 
			GROUP BY FILIAL,MATRICULA,NOME,SEXO, PAIS, FUNCAO, PERIODO, CATEGORIA
		EndSql
	EndIf	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fTotaliza   ºAutor  ³Alex Sandro Fagundes º Data ³  15/09/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua todas as totalizacoes                                   º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sem programa definido										 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fTotaliza()

	//Empleados Mensalistas
	If !(QSRA->CATEGORIA $ 'HE2O')
		cQtEmple += 1
		If (QSRA->SEXO = 'M' .AND. QSRA->PAIS = '009')
			cQtEmpH += 1
			cTotHomVl += QSRA->TOTAL10+QSRA->TOTAL5
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS = '009')
			cQtEmpM += 1
			cTotMujVl += QSRA->TOTAL10+QSRA->TOTAL5
		ElseIf (QSRA->SEXO = 'M' .and. QSRA->PAIS <> '009')
			cQtEmpHE += 1
			cTotHomVl += QSRA->TOTAL10+QSRA->TOTAL5
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS <> '009')
			cQtEmpME += 1
			cTotMujVl += QSRA->TOTAL10+QSRA->TOTAL5
		EndIf
	EndIf

	//Empleados Obrero/Horistas
	If QSRA->CATEGORIA $ 'H'
		cQtOb += 1
		If (QSRA->SEXO = 'M' .and. QSRA->PAIS = '009')
			cQtObH += 1
			cTotHomVl += QSRA->TOTAL10+QSRA->TOTAL5
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS = '009')
			cQtObM += 1
			cTotMujVl += QSRA->TOTAL10+QSRA->TOTAL5
		ElseIf (QSRA->SEXO = 'M' .and. QSRA->PAIS <> '009')
			cQtObHE += 1
			cTotHomVl += QSRA->TOTAL10+QSRA->TOTAL5
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS <> '009')
			cQtObME += 1
			cTotMujVl += QSRA->TOTAL10+QSRA->TOTAL5
		EndIf
	EndIf

	//Empleados Aprendices/Estagiarios
	If QSRA->CATEGORIA $ 'E'
		cQtEs += 1
		If (QSRA->SEXO = 'M' .and. QSRA->PAIS = '009')
			cQtEsH += 1
			cTotHomVl += QSRA->TOTAL10+QSRA->TOTAL5
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS = '009')
			cQtEsM += 1
			cTotMujVl += QSRA->TOTAL10+QSRA->TOTAL5
		ElseIf (QSRA->SEXO = 'M' .and. QSRA->PAIS <> '009')
			cQtEsHE += 1
			cTotHomVl += QSRA->TOTAL10+QSRA->TOTAL5
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS <> '009')
			cQtEsME += 1
			cTotMujVl += QSRA->TOTAL10+QSRA->TOTAL5
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LimpaP    ³ Autor ³ Alex Sandro Fagundes  ³ Data ³13/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta dialogo para selecao com botoes Duplex SIM           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function LimpaP()
	cQtEmple 	:= 0
	cQtEmpH	 	:= 0
	cTotHomBs 	:= 0
	cTotHomVl	:= 0
	cQtEmpM		:= 0
	cTotMujBs	:= 0
	cTotMujVl	:= 0
	cQtEmpHE	:= 0
	cQtEmpME 	:= 0
	cQtOb 		:= 0
	cQtObH 		:= 0
	cQtObM 		:= 0
	cQtObHE 	:= 0
	cQtObME 	:= 0
	cQtEs 		:= 0
	cQtEsH 		:= 0
	cQtEsM 		:= 0
	cQtEsHE 	:= 0
	cQtEsME 	:= 0
	nLin  		:= 0770	
	nCont		:= 1
	nContGeral	:= 1
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fSetVar  ³ Autor ³ Emerson Campos        ³ Data ³03/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao intermediaria para setar as variaveis, com os       ³±±
±±³          ³ valores oriundos dos MV_PAR                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fSetVar()    
	cMes		:= Substr(mv_par02,1,2)
	cAno    	:= Substr(mv_par02,3,4)
	cRoteiro	:= Alltrim(mv_par03)
	
	nDuplex		:= mv_par04
   		 
	If nDuplex == 1
		fDuplexSP()
	Else 
		fDuplexNP()
	EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fDuplexSP ³ Autor ³ Alex Sandro Fagundes  ³ Data ³13/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta dialogo para selecao com botoes Duplex SIM           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fDuplexSP()
	Local oDlg
	Local oBtnNewFil
	Local oBtnAltFil
	Local oBtnFastFil
	Local oBtnEnd
	Local oBtnDtrB
	Local bDialogInit							//bloco de inicializacao da janela
	Local bDtrB									//bloco para o DTR(B)
	Local bDtrA									//bloco para o DTR(A)	

	nLin		:= 0770

	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 010.2,023.3 TO 021.4,50.3 OF GetWndDefault() STYLE DS_MODALFRAME

		oDlg:lEscClose := .F. // Nao permite sair ao se pressionar a tecla ESC.

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Descricao da Janela                                                      ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
		@ 10,11 TO 70,100 OF oDlg PIXEL
		       
		LimpaP()
		
		bDtrA 		:= { || ImpDtrAP() }
		bDtrB 		:= { || ImpDtrBP() }

		oBtnDtrB	:= TButton():New( 15 , 35 , "&"+"UT(B)",NIL,bDtrB 	, 040 , 012 , NIL , NIL , NIL , .T. )	// DTR(B)
		oBtnDtrA	:= TButton():New( 35 , 35 , "&"+"UT(A)",NIL,bDtrA 	, 040 , 012 , NIL , NIL , NIL , .T. )	// DTR(A)
		oBtnEnd		:= TButton():New( 55 , 35 , "&"+"Sair",NIL,{ || oDlg:End() }	, 040 , 012 , NIL , NIL , NIL , .T. )	// "Sair"

		oBtnDtrA:Disable()

	ACTIVATE DIALOG oDlg CENTERED
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fDuplexNP ³ Autor ³ Alex Sandro Fagundes  ³ Data ³13/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta dialogo para selecao com botoes Duplex SIM           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fDuplexNP()
	Local oDlg
	Local oBtnNewFil
	Local oBtnAltFil
	Local oBtnFastFil
	Local oBtnEnd
	Local oBtnDtrBF
	Local bDialogInit							//bloco de inicializacao da janela
	Local bDtrBF								//bloco para o DTR(B) Frente
	Local bDtrBV								//bloco para o DTR(B) Verso
	Local bDtrA									//bloco para o DTR(A)	

	nLin		:= 0770

	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 010.2,023.3 TO 023.4,50.3 OF GetWndDefault() STYLE DS_MODALFRAME

		oDlg:lEscClose := .F. // Nao permite sair ao se pressionar a tecla ESC.

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Descricao da Janela                                                      ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
		@ 05,11 TO 95,100 OF oDlg PIXEL
		                            
		LimpaP()
		
		bDtrBF 		:= { || ImpDtrBP() }
		bDtrBV		:= { || ImpDtrBVP() }
		bDtrA 		:= { || ImpDtrAP() }

		oBtnDtrBF	:= TButton():New( 15 , 27 , "&"+STR0009	,NIL,bDtrBF 	, 050 , 012 , NIL , NIL , NIL , .T. )	// DTR(B) - Frente
		oBtnDtrBV	:= TButton():New( 35 , 27 , "&"+STR0010 ,NIL,bDtrBV 	, 050 , 012 , NIL , NIL , NIL , .T. )		// DTR(B) - Verso
		oBtnDtrA	:= TButton():New( 55 , 27 , "&"+"UT(A)"			,NIL,bDtrA 	, 050 , 012 , NIL , NIL , NIL , .T. )				// DTR(A)
		oBtnEnd		:= TButton():New( 75 , 27 , "&"+STR0008 ,NIL,{ || oDlg:End() }	, 050 , 012 , NIL , NIL , NIL , .T. )	// "Sair"

		oBtnDtrBV:Disable()
		oBtnDtrA:Disable()
	
	ACTIVATE DIALOG oDlg CENTERED
Return()
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ImpDtrAP  ³ Autor ³ Alex Sandro Fagundes  ³ Data ³14/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta dialogo para selecao com botoes Duplex NAO           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ImpDtrAP()
	oPrint := TMSPrinter():New( "MTE - Ministerio de trabajo y empleo" )
	oPrint:SetLandscape()	//Imprimir Somente Paisagem
	oPrint:StartPage() 		//Inicia uma nova pagina

	R906ImpA()

	oPrint:EndPage()	
    oPrint:Preview()		//Visualiza impressao grafica antes de imprimir
Return()
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ImpDtrBP  ³ Autor ³ Alex Sandro Fagundes  ³ Data ³14/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta dialogo para selecao com botoes Duplex NAO           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ImpDtrBP()
	LimpaP()

	oPrint := TMSPrinter():New( "MTE - Ministerio de trabajo y empleo" )
	oPrint:SetLandscape()	//Imprimir Somente Paisagem
	oPrint:StartPage() 		//Inicia uma nova pagina

	R906ImpB()

	oPrint:EndPage()	
    oPrint:Preview()		//Visualiza impressao grafica antes de imprimir

	If nDuplex == 1
		oBtnDtrA:Enable()
	Else 
		oBtnDtrBV:Enable()
	EndIf
	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ImpDtrBVP ³ Autor ³ Alex Sandro Fagundes  ³ Data ³14/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta dialogo para selecao com botoes Duplex NAO           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ImpDtrBVP()
	oPrint := TMSPrinter():New( "MTE - Ministerio de trabajo y empleo" )
	oPrint:SetLandscape()	//Imprimir Somente Paisagem
	oPrint:StartPage() 		//Inicia uma nova pagina

	R906ImpBV()

	oPrint:EndPage()	
    oPrint:Preview()		//Visualiza impressao grafica antes de imprimir

	oBtnDtrA:Enable()
Return()     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R906ImpBV ³ Autor ³ Alex Sandro Fagundes  ³ Data ³17/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao do DTR(B) Verso - Impressora Duplex NÃO          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function R906ImpBV()
	Local nX := 0
	nCont := 1
			
	oPrint:StartPage() 							//Inicia uma nova pagina   

	While (cAliasSRA)->(!Eof())
		If nDuplex == 1
			ImpDetFS()
		Else 
			ImpDetFN()
		EndIf
			
		(cAliasSRA)->(dbSkip())
	End 
	
	nCont := 1
	nLin  := 0570
				
	For nX:=1 To Len(aFuncs)
		ImpArrFunc(nX)

		nLin += 115
		nCont += 1

		If nCont == 15
			oPrint:EndPage()
			If nX < Len(aFuncs)
				oPrint:StartPage() 							//Inicia uma nova pagina   
			EndIf
			nLin  := 0570
			nCont := 1
			nFrente := 0
		EndIf
	Next nX                           

Return()
