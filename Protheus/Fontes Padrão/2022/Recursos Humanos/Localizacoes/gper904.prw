#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "GPER904.CH"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa    � GPER904     �Autor  �Kelly Soares         � Data �  27/10/2011���
������������������������������������������������������������������������������͹��
���Desc.       � Relatorio Oficial de Decima Terceira Remuneracao.             ���
���            �                                                               ���
������������������������������������������������������������������������������͹��
���Uso         � Equador                									   ���
������������������������������������������������������������������������������͹��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                  ���
������������������������������������������������������������������������������͹��
���Programador �Data    �Chamado    �Motivo da Alteracao                       ���
������������������������������������������������������������������������������͹��
���Kelly S.    �27/10/11�TDUJOF     �Ajuste na picture de campos de valor.     ���
���Emerson Camp�22/12/11�TEDYI3     �Ajustes para funcionamento da Query.      ���
���Mohanad Odeh�27/02/12�TENHST     �Inclus�o de obrigatoriedade de            ���
���                     �003651/2012�preenchimento dos par�metros Mes/Ano e    ���
���                     �           �Roteiro                                   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
User Function GPER904()
	Private cCadastro		:= OemToAnsi(STR0001) 	// "Processos de C�lculo"
	Private bDialogInit								//bloco de inicializacao da janela
	Private bBtnCalcule								//bloco do bot�o OK
	Private bSet15			:= { || NIL }
	Private bSet24			:= { || NIL }
	Private oGroup
	Private oLbxSource
	Private oFont
	Private oDlg
	Private aSays			:= {}		// array com as mensagem para visualizacao na caixa de Processamento	
	Private aButtons		:= {}		// botoes da caixa de processamento
	//����������������������������������������������������������������������Ŀ
	//� Variaveis        - para carregar os periodos abertos / fechados	     |
	//������������������������������������������������������������������������
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
	Private cDescCan 		:= "" 	//Busca Descri��o da Canton
	Private cDesParr 		:= "" 	//Busca Descri��o da Parroquia
	Private cEmpresa		:= ""
	Private cRUC			:= ""
	Private cTelef			:= ""
	Private cEnde			:= ""
	Private cCnae			:= ""

	//����������������������������������������������������������������������Ŀ
	//� Variaveis para totalizadores                                         |
	//������������������������������������������������������������������������
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

	Private cQtJu := 0
	Private cQtJuH  := 0
	Private cQtJuM  := 0
	Private cQtJuHE := 0
	Private cQtJuME := 0 
	
	Private cQtDom := 0
	Private cQtDomH  := 0
	Private cQtDomM  := 0
	Private cQtDomHE := 0
	Private cQtDomME := 0 
	
	Private cTotHomBs := 0
	Private cTotMujBs := 0
	Private cTotHomVl := 0
	Private cTotMujVl := 0

	Private nAux	:= 0  
	Private nLin	:= 0810
	Private nCont	:= 1
	Private nContGeral:= 1
	Private nFrente	:= 0
	Private aFuncs	:= {  }
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
	��������������������������������������������������������������Ŀ
	�Restaurar as informacoes do Ultimo Pergunte                   �
	����������������������������������������������������������������*/
	Pergunte("GPER904",.F.)
	
	/*
	��������������������������������������������������������������Ŀ
	�Janela de Processamento do Fechamento                         �
	����������������������������������������������������������������*/
	AADD(aSays, OemToAnsi( STR0002 ) )	// "Este programa efetua a impressao do relatorio Empresarial sobre a D�cima"
	AADD(aSays, OemToAnsi( STR0003 ) )	// "terceira remuneracao, a ser entregue ao MTE - Ministerio do trabalho e  "
	AADD(aSays, OemToAnsi( STR0004 ) )	// "Emprego. Informe os parametros necessarios e em seguida clique em       "
	AADD(aSays, OemToAnsi( STR0005 ) )	// "processar.                                                              "
	AADD(aSays, ""					 )

	AADD(aButtons, { 5,.T., { || Pergunte("GPER904", .T. ) } } )
	AADD(aButtons, { 1,.T., {|| fSetVar() }} )
	AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

	FormBatch( cCadastro, aSays, aButtons )

	If Select(cAliasSRA) > 0
  		(cAliasSRA)->( dbclosearea() )
 	EndIf
Return()

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �R904ImpB    �Autor  �Alex Sandro Fagundes � Data �  02/09/2010 ���
����������������������������������������������������������������������������͹��
���Desc.     �Monta a folha DTR(B)                                           ���
���          �                                                               ���
����������������������������������������������������������������������������͹��
���Uso       � Sem programa definido										 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function R904ImpB()
	Local nAux	:= 0  
	oFont05	:= TFont():New("Courier New",05,05,,.F.,,,,.T.,.F.)
	oFont06	:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)
	oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
	oFont08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oFont25n:= TFont():New("Courier New",25,25,,.T.,,,,.T.,.F.)     //Negrito// 
	oFont11n:= TFont():New("Courier New",11,11,,.T.,,,,.T.,.F.)     //Negrito//
	oFont17n:= TFont():New("Courier New",17,17,,.T.,,,,.T.,.F.)     //Negrito//
	oFont11	:= TFont():New("Courier New",11,11,,.F.,,,,.T.,.F.) 

	//��������������������������������������������������������������Ŀ
	//� Carregar os periodos abertos (aPerAberto) e/ou fechados	     �
	//� (aPerFechado), de acordo com a competencia de calculo.		 �
	//����������������������������������������������������������������
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
		fFuncs13(cPeriodos,cRoteiro)
	EndIf		


	oPrint:StartPage() 							//Inicia uma nova pagina   
	Limpa()
	While (cAliasSRA)->(!Eof())
		If nDuplex == 1
			ImpDetFS()
		Else 
			ImpDetFN()
		EndIf
			
		(cAliasSRA)->(dbSkip())
	End
		        
	oPrint:EndPage()
	
Return()

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �ImpDetFS    �Autor  �Alex Sandro Fagundes � Data �  02/09/2010 ���
����������������������������������������������������������������������������͹��
���Desc.     �Monta a folha DTR(B)                                           ���
���          �                                                               ���
����������������������������������������������������������������������������͹��
���Uso       � Sem programa definido										 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function ImpDetFS()
	ImpInfFunc(@nLin,@nCont,@nContGeral)
	fTotaliza()
	nLin += 120
	nCont += 1

	If nFrente == 0
		If nCont == 13
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
			//oPrint:StartPage() 							//Inicia uma nova pagina   
			If nCont <= Len(aFuncs)
				oPrint:StartPage() 							//Inicia uma nova pagina   
			EndIf
			nLin  := 0810
			nCont := 1
			nFrente := 0
		EndIf
	EndIf
Return()

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �ImpDetFN    �Autor  �Alex Sandro Fagundes � Data �  02/09/2010 ���
����������������������������������������������������������������������������͹��
���Desc.     �Monta a folha DTR(B)                                           ���
���          �                                                               ���
����������������������������������������������������������������������������͹��
���Uso       � Sem programa definido										 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function ImpDetFN()
	If nFrente == 0
		ImpInfFunc(@nLin,@nCont,@nContGeral)
		fTotaliza()
		nLin += 120
		nCont += 1
		If nCont == 13
			oPrint:EndPage()
			//oPrint:StartPage() 							//Inicia uma nova pagina   
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
		nLin += 120
		nCont += 1
		If nCont == 15
			nLin  := 0810
			nCont := 1
			nFrente := 0
		EndIf
	EndIf
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpInfFunc�Autor  �Alex Sandro Fagundes� Data �  15/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impressao das informacoes do funcionario.                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Gper904 - Chamado na funcao: R904ImpB e R904ImpA           ���
�������������������������������������������������������������������������ͼ��
���Parametros� nLin  - Controle de onde a linha e impressa                ���
���          � nCont - Contador de Funcionario impresso                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpInfFunc(nLin,nCont,nContGeral)
	
	oPrint:say ( nLin, 0001, Transform(nContGeral,"9999"), oFont11 )
	oPrint:say ( nLin, 0130, SubStr(QSRA->NOME,1,28), oFont11 ) 
	oPrint:say ( nLin, 0840, SubStr(QSRA->FUNCAO,1,13), oFont11 ) 
	If QSRA->SEXO == "M"
		oPrint:say ( nLin, 1220, "0", oFont11 )
	Else
		oPrint:say ( nLin, 1345, "1", oFont11 )	
	EndIf
	oPrint:say ( nLin, 1420, Transform(QSRA->TOTDIAS,"99999"), oFont11 ) 
	oPrint:say ( nLin, 1690, Transform(QSRA->TOTBAS,"@E 999,999,999.99"), oFont11 ) 
	oPrint:say ( nLin, 2170, Transform(QSRA->TOTAL,"@E 999,999,999.99"), oFont11 ) 
	
	nContGeral += 1

Return()
        
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpArrFunc�Autor  �Alex Sandro Fagundes� Data �  15/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impressao das informacoes do funcionario.                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Gper904 - Chamado na funcao: R904ImpB e R904ImpA           ���
�������������������������������������������������������������������������ͼ��
���Parametros� nLin  - Controle de onde a linha e impressa                ���
���          � nCont - Contador de Funcionario impresso                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpArrFunc(nX)

	oPrint:say ( nLin, 0001, aFuncs[nX, 1], oFont11 )
	oPrint:say ( nLin, 0130, AllTrim(aFuncs[nX, 2]), oFont11 ) 
	oPrint:say ( nLin, 0840, aFuncs[nX, 3], oFont11 ) 

	If aFuncs[nX,4] == "0"
		oPrint:say ( nLin, 1220, "0", oFont11 )
	Else
		oPrint:say ( nLin, 1345, "1", oFont11 )	
	EndIf

	oPrint:say ( nLin, 1420, aFuncs[nX, 5], oFont11 ) 
	oPrint:say ( nLin, 1690, aFuncs[nX, 6], oFont11 ) 
	oPrint:say ( nLin, 2170, aFuncs[nX, 7], oFont11 ) 

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AddInfFunc�Autor  �Alex Sandro Fagundes� Data �  15/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Array  Verso B                                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Gper904                                                    ���
�������������������������������������������������������������������������ͼ��
���Parametros� nLin  - Controle de onde a linha e impressa                ���
���          � nCont - Contador de Funcionario impresso                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AddInfFunc(nLin,nCont,nContGeral)
	Local cSexo := ""

	If QSRA->SEXO == "M"
		cSexo := "0"
	Else
		cSexo := "1"
	EndIf

	AADD(aFuncs, {Transform(nContGeral,"9999") , SubStr(QSRA->NOME,1,28) , SubStr(QSRA->FUNCAO,1,13) , cSexo , Transform(QSRA->TOTDIAS,"99999") , Transform(QSRA->TOTBAS,"@E 999,999,999.99") , Transform(QSRA->TOTAL,"@E 999,999,999.99") } )

	nContGeral += 1		

Return()
	

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �CabecEmp    �Autor  �Alex Sandro Fagundes � Data �  17/09/2010 ���
����������������������������������������������������������������������������͹��
���Desc.     �CabecEmp - Carrega informacoes da Empresa                      ���
���          �                                                               ���
����������������������������������������������������������������������������͹��
���Uso       � Sem programa definido										 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function CabecEmp()
	cCodProv 	:= fDescRcc("S021","01",1,2,3,2)		//Busca Codigo da Provincia
	cDesProv 	:= POSICIONE("SX5",1,XFILIAL("SX5")+"12"+cCodProv,"X5_DESCRI")//Busca Codigo da Provincia
	cDescCan 	:= fDescRcc("S021","01",1,2,6,20)  	//Busca Descri��o da Canton
	cDesParr 	:= fDescRcc("S021","01",1,2,26,20)	//Busca Descri��o da Parroquia
	cEmpresa	:= SM0->M0_NOME
	cRUC		:= SM0->M0_CGC
	cTelef		:= SM0->M0_TEL
	cEnde		:= SM0->M0_ENDCOB
	cCnae		:= SM0->M0_CNAE

Return()

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �R904ImpA    �Autor  �Alex Sandro Fagundes � Data �  02/09/2010 ���
����������������������������������������������������������������������������͹��
���Desc.     �Monta a folha DTR(A)                                           ���
���          �                                                               ���
����������������������������������������������������������������������������͹��
���Uso       � Sem programa definido										 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function R904ImpA()                   

	oFont05	:= TFont():New("Courier New",05,05,,.F.,,,,.T.,.F.)
	oFont06	:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)
	oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
	oFont08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oFont11	:= TFont():New("Courier New",11,11,,.F.,,,,.T.,.F.) 
	oFont25n:= TFont():New("Courier New",25,25,,.T.,,,,.T.,.F.)     //Negrito// 
	oFont11n:= TFont():New("Courier New",11,11,,.T.,,,,.T.,.F.)     //Negrito//
	oFont17n:= TFont():New("Courier New",17,17,,.T.,,,,.T.,.F.)     //Negrito//

		oPrint:StartPage() 							//Inicia uma nova pagina   
		
			oPrint:say ( 0480, 0850, "Janeiro", oFont11n )
			oPrint:say ( 0480, 1470, "Dezembro", oFont11n ) 
			oPrint:say ( 0480, 2130, cAno, oFont11n ) 
			
			CabecEmp()

			//Linha No RUC, Atividade Economica, Provincia, Canton e Parroquia
			oPrint:say ( 0715, 0200, cRUC, oFont11 )
			oPrint:say ( 0715, 0880, cCnae, oFont11 )
			oPrint:say ( 0715, 1320, cDesProv, oFont11 )    // Provincia
			oPrint:say ( 0715, 1900, cDescCan, oFont11 )	// Canton
			oPrint:say ( 0715, 2480, cDesParr, oFont11 )	// Parroquia
                                 
			// Dados da Empresa
			oPrint:say ( 0950, 0540, cEmpresa, oFont11 )
			oPrint:say ( 0940, 2500, cTelef, oFont11 )
                                                           
			//Endere�o da Empresa
			oPrint:say ( 1080, 0300, cEnde, oFont11 )
			
			//Empregados por categorias             
			//Empleados
			oPrint:say ( 1430, 0280, Transform(cQtEmple,"99999"), oFont11 )		// Total
			oPrint:say ( 1430, 0500, Transform(cQtEmpH,"99999"), oFont11 )		// Nacionales - Hombres
			oPrint:say ( 1430, 0720, Transform(cQtEmpM,"99999"), oFont11 )  	// Nacionales - Mujeres
			oPrint:say ( 1430, 0940, Transform(cQtEmpHE,"99999"), oFont11 )		// Extranjeros - Hombres
			oPrint:say ( 1430, 1180, Transform(cQtEmpME,"99999"), oFont11 )		// Extranjeros - Mujeres

			oPrint:say ( 1390, 2300, Transform(cTotHomBs+cTotMujBs,"@E 999,999,999.99"), oFont11 ) // 3-Total ganado 
			
			//Obreros
			oPrint:say ( 1530, 0280, Transform(cQtOb,"99999"), oFont11 )		//Total
			oPrint:say ( 1530, 0500, Transform(cQtObH,"99999"), oFont11 )      	// Nacionales - Hombres
			oPrint:say ( 1530, 0720, Transform(cQtObM,"99999"), oFont11 )		// Nacionales - Mujeres
			oPrint:say ( 1530, 0940, Transform(cQtObHE,"99999"), oFont11 )		// Extranjeros - Hombres
			oPrint:say ( 1530, 1180, Transform(cQtObME,"99999"), oFont11 )     	// Extranjeros - Mujeres

			oPrint:say ( 1490, 2300, Transform(cTotHomBs,"@E 999,999,999.99"), oFont11 )	// Valor total de HOMBRES

			//Aprencices
			oPrint:say ( 1630, 0280, Transform(cQtEs,"99999"), oFont11 )      	//Total
			oPrint:say ( 1630, 0500, Transform(cQtEsH,"99999"), oFont11 )		// Nacionales - Hombres
			oPrint:say ( 1630, 0720, Transform(cQtEsM,"99999"), oFont11 )		// Nacionales - Mujeres
			oPrint:say ( 1630, 0940, Transform(cQtEsHE,"99999"), oFont11 )		// Extranjeros - Hombres
			oPrint:say ( 1630, 1180, Transform(cQtEsME,"99999"), oFont11 )		// Extranjeros - Mujeres

			oPrint:say ( 1600, 2300, Transform(cTotMujBs,"@E 999,999,999.99"), oFont11 )	// Valor total de MUJERES

			//Jubilados
			oPrint:say ( 1730, 0280, Transform(cQtJu,"99999"), oFont11 )      	//Total
			oPrint:say ( 1730, 0500, Transform(cQtJuH,"99999"), oFont11 )		// Nacionales - Hombres
			oPrint:say ( 1730, 0720, Transform(cQtJuM,"99999"), oFont11 )		// Nacionales - Mujeres
			oPrint:say ( 1730, 0940, Transform(cQtJuHE,"99999"), oFont11 )		// Extranjeros - Hombres
			oPrint:say ( 1730, 1180, Transform(cQtJuME,"99999"), oFont11 )		// Extranjeros - Mujeres

			oPrint:say ( 1700, 2300, Transform(cTotHomVl+cTotMujVl,"@E 999,999,999.99"), oFont11 )	// Valor total DecimaTerceira Remuneracion

			//Trabajador servicio domestico
			oPrint:say ( 1830, 0280, Transform(cQtDom,"99999"), oFont11 )     	//Total
			oPrint:say ( 1830, 0500, Transform(cQtDomH,"99999"), oFont11 )		// Nacionales - Hombres
			oPrint:say ( 1830, 0720, Transform(cQtDomM,"99999"), oFont11 )		// Nacionales - Mujeres
			oPrint:say ( 1830, 0940, Transform(cQtDomHE,"99999"), oFont11 )		// Extranjeros - Hombres
			oPrint:say ( 1830, 1180, Transform(cQtDomME,"99999"), oFont11 )		// Extranjeros - Mujeres

			oPrint:say ( 1800, 2300, Transform(cTotHomVl,"@E 999,999,999.99"), oFont11 )	// Total DecimaTerceira HOMBRES

			//Total
			oPrint:say ( 1930, 0280, Transform(cQtEmple+cQtOb+cQtEs+cQtJu+cQtDom,"99999"), oFont11 ) 			// Total dos Totais por categ
			oPrint:say ( 1930, 0500, Transform(cQtEmpH+cQtObH+cQtEsH+cQtJuH+cQtDomH,"99999"), oFont11 )    		// Total dos HOMBRES Nacionales
			oPrint:say ( 1930, 0720, Transform(cQtEmpM+cQtEsM+cQtJuM+cQtDomM,"99999"), oFont11 )				// Total dos MUJERES Nacionales
			oPrint:say ( 1930, 0940, Transform(cQtEmpHE+cQtObHE+cQtEsHE+cQtJuHE+cQtDomHE,"99999"), oFont11 )	// Total dos HOMBRES Extranjeros
			oPrint:say ( 1930, 1180, Transform(cQtEmpME+cQtObME+cQtEsME+cQtJuME+cQtDomME,"99999"), oFont11 )	// Total dos MUJERES Extranjeros

			oPrint:say ( 1900, 2300, Transform(cTotMujVl,"@E 999,999,999.99"), oFont11 )	// Total DecimaTerceira MUJERES
			
		oPrint:EndPage()
Return

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �fFuncs13    �Autor  �Alex Sandro Fagundes � Data �  02/09/2010 ���
����������������������������������������������������������������������������͹��
���Desc.     �Conta os funcionarios por categoria ocupacional. Nacionais.    ���
���          �                                                               ���
����������������������������������������������������������������������������͹��
���Uso       � Sem programa definido										 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function fFuncs13(cPeriodos,cRoteiro)
	Local cPDVALOR		:= ""
	Local cPDBASE		:= ""
	Local nReg			:= 0	
	Local cRotQuery 	:= ""
	Local cFiltro		:= ""
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

	If !Empty(AllTrim(mv_par01))
		cFiltro	:= RANGESX1("RA_FILIAL",mv_par01)
		cFiltro	:= "%"+cFiltro+"%"
	Else
		cFiltro	:= "% 1 = 1 %" // Atribui��o necess�ria para criar uma express�o booleana verdadeira a ser usada na query
	EndIf

	cPDVALOR := FGETCODFOL( "0024" )
	cPDBASE  := FGETCODFOL( "0896" ) 

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
					SUM(DIAS) TOTDIAS, SUM(DTREZE) TOTAL, SUM(BASE) TOTBAS
			FROM
				(SELECT	RA_FILIAL FILIAL, RA_MAT MATRICULA, RA_NOME NOME, RA_CATFUNC CATEGORIA, RA_SEXO SEXO, 
						RA_CODPAIS PAIS, RJ_DESC FUNCAO, RC_PERIODO PERIODO, RC_HORAS DIAS, RC_VALOR DTREZE, 0 BASE
				FROM  %table:SRA% SRA	
				INNER JOIN %table:SRC% SRC
				ON SRA.RA_FILIAL = SRC.RC_FILIAL AND SRA.RA_MAT = SRC.RC_MAT
				INNER JOIN %table:SRJ% SRJ 
				ON SRA.RA_CODFUNC = SRJ.RJ_FUNCAO
				WHERE 	%exp:cFiltro% AND
						SRC.RC_PERIODO IN (%exp:Upper(cPeriodos)%) AND
						SRC.RC_ROTEIR  IN (%exp:Upper(cRotQuery)%) AND
						SRC.RC_PD = %exp:Upper(cPDVALOR)% AND
						SRA.%notDel% AND SRC.%notDel%
				UNION
				SELECT 	RA_FILIAL, RA_MAT, RA_NOME, RA_CATFUNC, RA_SEXO, RA_CODPAIS, RJ_DESC FUNCAO, 
						RC_PERIODO, RC_HORAS DIAS, 0 DTREZE, RC_VALOR BASE
				FROM  %table:SRA% SRA	
				INNER JOIN %table:SRC% SRC
				ON 		SRA.RA_FILIAL = SRC.RC_FILIAL AND SRA.RA_MAT = SRC.RC_MAT
				INNER JOIN %table:SRJ% SRJ 
				ON 		SRA.RA_CODFUNC = SRJ.RJ_FUNCAO
				WHERE 	%exp:cFiltro% AND
						SRC.RC_PERIODO IN (%exp:Upper(cPeriodos)%) AND
						SRC.RC_ROTEIR  IN (%exp:Upper(cRotQuery)%) AND
						SRC.RC_PD = %exp:Upper(cPDBASE)% AND
						SRA.%notDel% AND SRC.%notDel%) tView 
			GROUP BY FILIAL,MATRICULA,NOME,SEXO, PAIS, FUNCAO, PERIODO, CATEGORIA
		EndSql
	ElseIf !(len(aPerFechado) < 1)
		BeginSql alias cAliasSRA
			SELECT	FILIAL, MATRICULA, NOME, SEXO, PAIS, FUNCAO, PERIODO, CATEGORIA,
					SUM(DIAS) TOTDIAS, SUM(DTREZE) TOTAL, SUM(BASE) TOTBAS
			FROM
				(SELECT	RA_FILIAL FILIAL, RA_MAT MATRICULA, RA_NOME NOME, RA_CATFUNC CATEGORIA, RA_SEXO SEXO, 
						RA_CODPAIS PAIS, RJ_DESC FUNCAO, RD_PERIODO PERIODO, RD_HORAS DIAS, RD_VALOR DTREZE, 0 BASE
				FROM  %table:SRA% SRA	
				INNER JOIN %table:SRD% SRD
				ON SRA.RA_FILIAL = SRD.RD_FILIAL AND SRA.RA_MAT = SRD.RD_MAT
				INNER JOIN %table:SRJ% SRJ 
				ON SRA.RA_CODFUNC = SRJ.RJ_FUNCAO
				WHERE 	%exp:cFiltro% AND
						SRD.RD_PERIODO IN (%exp:Upper(cPeriodos)%) AND
						SRD.RD_ROTEIR  IN (%exp:Upper(cRotQuery)%) AND
						SRD.RD_PD = %exp:Upper(cPDVALOR)% AND
						SRA.%notDel% AND SRD.%notDel%
				UNION
				
				SELECT 	RA_FILIAL, RA_MAT, RA_NOME, RA_CATFUNC, RA_SEXO, RA_CODPAIS, RJ_DESC FUNCAO, 
						RD_PERIODO, RD_HORAS DIAS, 0 DTREZE, RD_VALOR BASE
				FROM  %table:SRA% SRA	
				INNER JOIN %table:SRD% SRD
				ON 		SRA.RA_FILIAL = SRD.RD_FILIAL AND SRA.RA_MAT = SRD.RD_MAT
				INNER JOIN %table:SRJ% SRJ 
				ON 		SRA.RA_CODFUNC = SRJ.RJ_FUNCAO
				WHERE 	%exp:cFiltro% AND
						SRD.RD_PERIODO IN (%exp:Upper(cPeriodos)%) AND
						SRD.RD_ROTEIR  IN (%exp:Upper(cRotQuery)%) AND
						SRD.RD_PD = %exp:Upper(cPDBASE)% AND
						SRA.%notDel% AND SRD.%notDel%) tView 
			GROUP BY FILIAL,MATRICULA,NOME,SEXO, PAIS, FUNCAO, PERIODO, CATEGORIA
		EndSql
	EndIf	
Return()

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �fTotaliza   �Autor  �Alex Sandro Fagundes � Data �  15/09/2010 ���
����������������������������������������������������������������������������͹��
���Desc.     �Efetua todas as totalizacoes                                   ���
���          �                                                               ���
����������������������������������������������������������������������������͹��
���Uso       � Sem programa definido										 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function fTotaliza()

	//Empleados Mensalistas
	If !(QSRA->CATEGORIA $ 'HE2O')
		cQtEmple += 1
		If (QSRA->SEXO = 'M' .AND. QSRA->PAIS = '009')
			cQtEmpH += 1
			cTotHomBs += QSRA->TOTBAS
			cTotHomVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS = '009')
			cQtEmpM += 1
			cTotMujBs += QSRA->TOTBAS
			cTotMujVl += QSRA->TOTAL   
		ElseIf (QSRA->SEXO = 'M' .and. QSRA->PAIS <> '009')
			cQtEmpHE += 1
			cTotHomBs += QSRA->TOTBAS
			cTotHomVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS <> '009')
			cQtEmpME += 1
			cTotMujBs += QSRA->TOTBAS
			cTotMujVl += QSRA->TOTAL
		EndIf
	EndIf

	//Empleados Obrero/Horistas
	If QSRA->CATEGORIA $ 'H'
		cQtOb += 1
		If (QSRA->SEXO = 'M' .and. QSRA->PAIS = '009')
			cQtObH += 1
			cTotHomBs += QSRA->TOTBAS
			cTotHomVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS = '009')
			cQtObM += 1
			cTotMujBs += QSRA->TOTBAS
			cTotMujVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'M' .and. QSRA->PAIS <> '009')
			cQtObHE += 1
			cTotHomBs += QSRA->TOTBAS
			cTotHomVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS <> '009')
			cQtObME += 1
			cTotMujBs += QSRA->TOTBAS
			cTotMujVl += QSRA->TOTAL
		EndIf
	EndIf

	//Empleados Aprendices/Estagiarios
	If QSRA->CATEGORIA $ 'E'
		cQtEs += 1
		If (QSRA->SEXO = 'M' .and. QSRA->PAIS = '009')
			cQtEsH += 1
			cTotHomBs += QSRA->TOTBAS
			cTotHomVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS = '009')
			cQtEsM += 1
			cTotMujBs += QSRA->TOTBAS
			cTotMujVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'M' .and. QSRA->PAIS <> '009')
			cQtEsHE += 1
			cTotHomBs += QSRA->TOTBAS
			cTotHomVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS <> '009')
			cQtEsME += 1
			cTotMujBs += QSRA->TOTBAS
			cTotMujVl += QSRA->TOTAL
		EndIf
	EndIf
                                                       
	//Empleados Jubilados/Aposentados
	If QSRA->CATEGORIA $ '2'
		cQtJu += 1
		If (QSRA->SEXO = 'M' .and. QSRA->PAIS = '009')
			cQtJuH += 1
			cTotHomBs += QSRA->TOTBAS
			cTotHomVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS = '009')
			cQtJuM += 1
			cTotMujBs += QSRA->TOTBAS
			cTotMujVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'M' .and. QSRA->PAIS <> '009')
			cQtJuHE += 1
			cTotHomBs += QSRA->TOTBAS
			cTotHomVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS <> '009')
			cQtJuME += 1
			cTotMujBs += QSRA->TOTBAS
			cTotMujVl += QSRA->TOTAL
		EndIf
	EndIf

	//Empleados Domestico
	If QSRA->CATEGORIA $ 'O'
		cQtDom += 1
		If (QSRA->SEXO = 'M' .and. QSRA->PAIS = '009')
			cQtDomH += 1
			cTotHomBs += QSRA->TOTBAS
			cTotHomVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS = '009')
			cQtDomM += 1
			cTotMujBs += QSRA->TOTBAS
			cTotMujVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'M' .and. QSRA->PAIS <> '009')
			cQtDomHE += 1
			cTotHomBs += QSRA->TOTBAS
			cTotHomVl += QSRA->TOTAL
		ElseIf (QSRA->SEXO = 'F' .and. QSRA->PAIS <> '009')
			cQtDomME += 1
			cTotMujBs += QSRA->TOTBAS
			cTotMujVl += QSRA->TOTAL
		EndIf
	EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Limpa     � Autor � Alex Sandro Fagundes  � Data �13/09/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta dialogo para selecao com botoes Duplex SIM           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function Limpa()
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
	cQtJu 		:= 0
	cQtJuH 		:= 0
	cQtJuM 		:= 0
	cQtJuHE 	:= 0
	cQtJuME 	:= 0
	cQtDom 		:= 0
	cQtDomH 	:= 0
	cQtDomM 	:= 0
	cQtDomHE 	:= 0
	cQtDomME 	:= 0
	nLin		:= 0810
	nCont		:= 1
	nContGeral	:= 1
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fSetVar  � Autor � Emerson Campos        � Data �02/01/2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao intermediaria para setar as variaveis, com os       ���
���          � valores oriundos dos MV_PAR                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function fSetVar()
	cMes		:= Substr(mv_par02,1,2)
	cAno    	:= Substr(mv_par02,3,4)
	cRoteiro	:= Alltrim(mv_par03)
   	nDuplex		:= mv_par04

   	If Empty(AllTrim(cMes)) .OR. Empty(AllTrim(cAno)) .OR. Empty(AllTrim(cRoteiro))
		MsgAlert(OemToAnsi(STR0014)) // "Os par�metros M�s/Ano e Roteiro s�o de preenchimento obrigat�rio!"
		Return Nil
   	EndIf

	If nDuplex == 1
		fDuplexS()
	Else
		fDuplexN()
	EndIf
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fDuplexS � Autor � Alex Sandro Fagundes  � Data �13/09/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta dialogo para selecao com botoes Duplex SIM           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function fDuplexS()
	Local oDlg
	Local oBtnNewFil
	Local oBtnAltFil
	Local oBtnFastFil
	Local oBtnEnd
	Local oBtnDtrB
	Local bDialogInit							//bloco de inicializacao da janela
	Local bDtrB									//bloco para o DTR(B)
	Local bDtrA									//bloco para o DTR(A)

	nLin		:= 0810

	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 010.2,023.3 TO 021.4,50.3 OF GetWndDefault() STYLE DS_MODALFRAME

		oDlg:lEscClose := .F. // Nao permite sair ao se pressionar a tecla ESC.

		/*/
		��������������������������������������������������������������������������Ŀ
		� Descricao da Janela                                                      �
		���������������������������������������������������������������������������� */
		@ 10,11 TO 70,100 OF oDlg PIXEL
		       
		Limpa()
		
		bDtrA 		:= { || ImpDtrA() }
		bDtrB 		:= { || ImpDtrB() }

		oBtnDtrB	:= TButton():New( 15 , 35 , "&"+"DTR(B)",NIL,bDtrB 	, 040 , 012 , NIL , NIL , NIL , .T. )	// DTR(B)
		oBtnDtrA	:= TButton():New( 35 , 35 , "&"+"DTR(A)",NIL,bDtrA 	, 040 , 012 , NIL , NIL , NIL , .T. )	// DTR(A)
		oBtnEnd		:= TButton():New( 55 , 35 , "&"+"Sair",NIL,{ || oDlg:End() }	, 040 , 012 , NIL , NIL , NIL , .T. )	// "Sair"

		oBtnDtrA:Disable()

	ACTIVATE DIALOG oDlg CENTERED
Return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fDuplexN � Autor � Alex Sandro Fagundes  � Data �13/09/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta dialogo para selecao com botoes Duplex SIM           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function fDuplexN()
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
   
	nLin		:= 0810

	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 010.2,023.3 TO 023.4,50.3 OF GetWndDefault() STYLE DS_MODALFRAME

		oDlg:lEscClose := .F. // Nao permite sair ao se pressionar a tecla ESC.

		/*/
		��������������������������������������������������������������������������Ŀ
		� Descricao da Janela                                                      �
		���������������������������������������������������������������������������� */
		@ 05,11 TO 95,100 OF oDlg PIXEL
		                            
		Limpa()
		
		bDtrBF 		:= { || ImpDtrB() }
		bDtrBV		:= { || ImpDtrBV() }
		bDtrA 		:= { || ImpDtrA() }

		oBtnDtrBF	:= TButton():New( 15 , 27 , "&"+STR0010	,NIL,bDtrBF 	, 050 , 012 , NIL , NIL , NIL , .T. )	// DTR(B) - Frente
		oBtnDtrBV	:= TButton():New( 35 , 27 , "&"+STR0011 ,NIL,bDtrBV 	, 050 , 012 , NIL , NIL , NIL , .T. )		// DTR(B) - Verso
		oBtnDtrA	:= TButton():New( 55 , 27 , "&"+"DTR(A)"			,NIL,bDtrA 	, 050 , 012 , NIL , NIL , NIL , .T. )				// DTR(A)
		oBtnEnd		:= TButton():New( 75 , 27 , "&"+STR0009 ,NIL,{ || oDlg:End() }	, 050 , 012 , NIL , NIL , NIL , .T. )	// "Sair"

		oBtnDtrBV:Disable()
		oBtnDtrA:Disable()
	
	ACTIVATE DIALOG oDlg CENTERED
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ImpDtrA   � Autor � Alex Sandro Fagundes  � Data �14/09/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta dialogo para selecao com botoes Duplex NAO           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function ImpDtrA()
	oPrint := TMSPrinter():New( "MTE - Ministerio de trabajo y empleo" )
	oPrint:SetLandscape()	//Imprimir Somente Paisagem
	oPrint:StartPage() 		//Inicia uma nova pagina

	R904ImpA()

	oPrint:EndPage()	
    oPrint:Preview()		//Visualiza impressao grafica antes de imprimir
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ImpDtrB   � Autor � Alex Sandro Fagundes  � Data �14/09/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta dialogo para selecao com botoes Duplex NAO           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function ImpDtrB()
	Limpa()

	oPrint := TMSPrinter():New( "MTE - Ministerio de trabajo y empleo" )
	oPrint:SetLandscape()	//Imprimir Somente Paisagem
	oPrint:StartPage() 		//Inicia uma nova pagina

	R904ImpB()

	oPrint:EndPage()
    oPrint:Preview()		//Visualiza impressao grafica antes de imprimir

	If nDuplex == 1
		oBtnDtrA:Enable()
	Else
		oBtnDtrBV:Enable()
	EndIf

Return()


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ImpDtrBV  � Autor � Alex Sandro Fagundes  � Data �14/09/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta dialogo para selecao com botoes Duplex NAO           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function ImpDtrBV()
	oPrint := TMSPrinter():New( "MTE - Ministerio de trabajo y empleo" )
	oPrint:SetLandscape()	//Imprimir Somente Paisagem
	oPrint:StartPage() 		//Inicia uma nova pagina

	R904ImpBV()

	oPrint:EndPage()	
    oPrint:Preview()		//Visualiza impressao grafica antes de imprimir

	oBtnDtrA:Enable()
Return()     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R904ImpBV � Autor � Alex Sandro Fagundes  � Data �17/09/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do DTR(B) Verso - Impressora Duplex N�O          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function R904ImpBV()
	Local nX := 0
	
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

		nLin += 120
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
