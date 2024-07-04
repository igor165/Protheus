#INCLUDE "plsr430n.ch"
#include "PROTHEUS.CH"
/*/

�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLSR430N � Autor � Luciano Aparecido     � Data � 22.03.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Guia de Consulta                                           ���
���          � Guia de Servico Profissional / Servico Auxiliar de Diag-   ���
���          � nostico e Terapia - SP/SADT                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PLSR430N(aPar)                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSR430N(aPar)
	//��������������������������������������������������������������Ŀ
	//� Define Variaveis                                             �
	//����������������������������������������������������������������
	Local CbCont, Cabec1, Cabec2, Cabec3, nPos, wnrel
	Local cTamanho   := "M"
	Local cDesc1     := STR0001 //"Impressao da Guia de Consulta/SADT"
	Local cDesc2     := STR0002 //"de acordo com a configuracao do usuario."
	Local cDesc3     := " "
	Local aArea	     := GetArea()
	Local lGerTXT    := .T.      
	Local nSvRecno   := BEA->(Recno())
	Local cFiltro    := ""
	Local lImpGuiNeg := GetNewPar("MV_IGUINE", .F.) //parametro para impress�o de guia em an�lise
	
	//��������������������������������������������������������������������������Ŀ
	//� Parametros do relatorio (SX1)...                                         �
	//����������������������������������������������������������������������������
	Local nLayout
	
	Private aReturn  := { "Zebrado", 1,"Administracao", 1, 1, 1, "", 1 }
	Private aLinha	 := { }
	Private nLastKey := 0
	Private cTitulo	 := STR0003 //"GUIA DE CONSULTA/SADT"
	Private cPerg    
	Private aPerg := {}
	
	DEFAULT aPar     := {"1",.F.}
	
	If aPar[1] == "1"
		cPerg := "PL430N"
	Else
		cPerg := "PLR430"
	EndIf
	
	//��������������������������������������������������������������������������Ŀ
	//� Ajusta perguntas                                                         �
	//����������������������������������������������������������������������������
	CriaSX1(aPar) //cria pergunta...
	
	lGerTXT := aPar[2] // Imprime Direto sem passar pela tela de configuracao/preview do relatorio
	
	If aPar[1] == "1" .And. ! (BEA->BEA_STATUS $ "1,2,3,4" .Or. (BEA->BEA_STATUS == '6' .And. getNewPar("MV_PLIBAUD",.F.) == .T.)) .and. !lImpGuiNeg
		Help("",1,"PLSR430")
		Return
	EndIf   
	
	If BEA->BEA_LIBERA == "1" .AND. !PLSSALDO("",BEA->(BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT)) .And. GetNewPar("MV_PLIMSAE","0") == "0"
		MsgAlert("Esta guia de solicita��o ja foi executada ou n�o possui saldo, proceda com a impress�o da guia de execu��o.")
		Return
	EndIf
	
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	
	aPerg := {mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par08,mv_par09}
	
	//--Altera o Set Epch para 1910
	nEpoca := SET(5, 1910)
	
	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
	//����������������������������������������������������������������
	CbCont   := 0
	Cabec1   := OemtoAnsi(cTitulo)
	Cabec2   := " "
	Cabec3   := " "
	cString  := "BEA"
	aOrd     := {}
	              
		

	If nLastKey = 27  
	    If FunName()== "PLS090O"
		    cFiltro := PLS090FIL("1")   
		    Set Filter To &cFiltro 
		Else
		    Set Filter To
		EndIf
		Return
	Endif
	
	If lGerTXT
		SetPrintFile(wnRel)
	EndIf
	
	nLayout := 2 
		
	
	RptStatus({|lEnd| R430NImp(@lEnd,cString, aPar, lGerTXT, nLayout, aPerg)}, cTitulo)
	
	//-- Posiciona o ponteiro
	BEA->(dbGoto(nSvRecno))	
	
	/*
	��������������������������������������������������������������Ŀ
	�Restaura Area e Ordem de Entrada                              �
	����������������������������������������������������������������*/
	//--Retornar Set Epoch Padrao
	SET(5, nEpoca)
	RestArea(aArea)
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � R430NIMP � Autor � Luciano Aparecido     � Data � 22/03/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR430N                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function R430NImp(lEnd, cString, aPar, lGerTXT, nLayout, aPerg, lAuto)

	Local cCodOpe
	Local cGrupoDe
	Local cGrupoAte
	Local cContDe
	Local cContAte
	Local cSubDe
	Local cSubAte
	Local nTipo
	Local cSQL      
	Local cTipo :='1,2' //guias de Consulta e SADT 
	Local aConsulta := {}
	Local aSADT     := {}
	Local lIntervalo := GetNewPar("MV_PLSADT1",.F.)// Intervalo de paginas a ser impresso na guia SADT Vs TISS: 2.02.03. 
	DEFAULT aPar    := {"1",.F.}
	Default lAuto	:= .F.
	
	If aPar[1] == "1" .Or. BEA->(FieldPos("BEA_GUIIMP")) == 0 // Impressao Individual
		If BEA->BEA_TIPO == "1"
			aAdd(aConsulta, MtaDados(BEA->BEA_TIPO))
		Else
			aAdd(aSADT, MtaDados(IIf(BEA->BEA_TIPO == "4","2",BEA->BEA_TIPO)))
		EndIf
	Else // Impressao por Lote... de acordo com o pergunte
		//��������������������������������������������������������������������������Ŀ
		//� Busca dados de parametros...                                             �
		//����������������������������������������������������������������������������
		If !lAuto
			Pergunte(cPerg,.F.)
		EndIf
		cCodOpe   := aPerg[1]
		cGrupoDe  := aPerg[2]
		cGrupoAte := aPerg[3]                                                                                        
		cContDe   := aPerg[4]
		cContAte  := aPerg[5]
		cSubDe    := aPerg[6]
		cSubAte   := aPerg[7]
		nTipo     := aPerg[8]
		nLayout   := aPerg[9]
		     
		cSQL := "SELECT R_E_C_N_O_ AS REG FROM " + RetSQLName("BEA")
		cSQL += " WHERE BEA_FILIAL = '" + xFilial("BEA") + "'"
		cSQL += "   AND BEA_OPEMOV = '" + cCodOpe + "'"
		cSQL += "   AND (BEA_CODEMP >= '" + cGrupoDe + "' AND BEA_CODEMP <= '" + cGrupoAte + "')"
		cSQL += "   AND (BEA_CONEMP >= '" + cContDe  + "' AND BEA_CONEMP <= '" + cContAte  + "')"
		cSQL += "   AND (BEA_SUBCON >= '" + cSubDe   + "' AND BEA_SUBCON <= '" + cSubAte   + "')"
		cSQL += "   AND BEA_TIPO in (" + cTipo + ") "
		If nTipo == 1
			cSQL += " AND BEA_AUDITO = '1'"
		ElseIf nTipo == 2
			cSQL += " AND BEA_GUIIMP <> '1'"
		Endif   
		cSQL += " AND D_E_L_E_T_ = ' '"
		     
		PLSQuery(cSQL,"Trb")
		     
		If Trb->(Eof())
			Trb->(dbCloseArea())
			Help("",1,"RECNO")
			Return
		Else   
			Do While ! Trb->(Eof())
				BEA->(dbGoTo(Trb->REG))
				If BEA->BEA_TIPO == "1"
					aAdd(aConsulta, MtaDados(BEA->BEA_TIPO))
				Else
					aAdd(aSADT, MtaDados(BEA->BEA_TIPO))
				EndIf
				Trb->(dbSkip())
			Enddo          
			Trb->(dbCloseArea())
		EndIf                 
	EndIf

	If Len(aConsulta) > 0
		If ExistBlock("PLR430CONS")
			aConsulta:=ExecBlock("PLR430CONS",.F.,.F.,{aConsulta})
		EndIf
			
		If PLSTISSVER() = "3"
			PlsTISSD(aConsulta, lGerTXT, nLayout)
		Else
			PlsTISS1(aConsulta, lGerTXT, nLayout)
		EndIf
  	EndIf
	If Len(aSADT) > 0
		If ExistBlock("PLR430SADT")
			aSADT:=ExecBlock("PLR430SADT",.F.,.F.,{aSADT})
		EndIf
		
		If  PLSTISSVER() >= "3"
			PlsTISSC(aSADT, lGerTXT, nLayout,,,,,,lAuto)
		EndIf 
			
		If  PLSTISSVER() = "2" .and. lIntervalo == .T.
			PlsSadt1(aSADT, lGerTXT, nLayout)
		EndIF
		If  PLSTISSVER() = "2"
			PlsTISS2(aSADT, lGerTXT, nLayout)	
		EndIf
	EndIf
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MtaDados � Autor � Luciano Aparecido     � Data � 22/03/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Grava STATUS da tabela BEA e chama a funcao "PLSGSADT"     ���
���          � que ira retornar o array com os dados a serem impressos.   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR430N                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MtaDados(nGuia)

	Local aDados := {}
	Local lImpGuiNeg := GetNewPar("MV_IGUINE", .F.) //parametro para impress�o de guia em an�lise
	Local aNumAut    := PLSGSADT(nGuia)

	If ((BEA->BEA_STATUS $ "1,2,3,4" .or. lImpGuiNeg) .Or. (BEA->BEA_STATUS == '6' .And. PLIBAUD(@StrTran(StrTran(aNumAut[2],".",""),"-",""))))

		BEA->(RecLock("BEA", .F.))
		If BEA->BEA_STATUS == "4"
			BEA->BEA_STATUS := "1"
		EndIf
	
		If BEA->(FieldPos("BEA_GUIIMP")) > 0
			BEA->BEA_GUIIMP := "1"
		EndIf
	
		BEA->(MsUnLock())
		
		aDados := PLSGSADT(nGuia) // Funcao que monta o array com os dados da guia de CONSULTA ou SP/SADT
		
	EndIf
		
Return aDados

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � CriaSX1   � Autor � Luciano Aparecido    � Data � 22.03.07 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Atualiza SX1                                               ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/

Static Function CriaSX1(aPar)

LOCAL aRegs	 :=	{}

If aPar[1] == "1"
	aadd(aRegs,{cPerg,"01","Selecionar Layout Papel:" ,"","","mv_ch1","N", 1,0,0,"C","","mv_par01","Of�cio 2"         	,"","","","","Papel A4"            	,"","","","","Papel Carta"              ,"","","","",""       ,"","","","","","","","",""   ,""})
Else
	aadd(aRegs,{cPerg,"09","Selecionar Layout Papel:" ,"","","mv_ch9","N", 1,0,0,"C","","mv_par09","Of�cio 2"         	,"","","","","Papel A4"            	,"","","","","Papel Carta"              ,"","","","",""       ,"","","","","","","","",""   ,""})
Endif	                                                                                                                                                                   

PlsVldPerg( aRegs )

Return