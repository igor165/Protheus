#INCLUDE "plsr430n.ch"
#include "PROTHEUS.CH"
/*/

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSR430N ³ Autor ³ Luciano Aparecido     ³ Data ³ 22.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Guia de Consulta                                           ³±±
±±³          ³ Guia de Servico Profissional / Servico Auxiliar de Diag-   ³±±
±±³          ³ nostico e Terapia - SP/SADT                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSR430N(aPar)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSR430N(aPar)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local CbCont, Cabec1, Cabec2, Cabec3, nPos, wnrel
	Local cTamanho   := "M"
	Local cDesc1     := STR0001 //"Impressao da Guia de Consulta/SADT"
	Local cDesc2     := STR0002 //"de acordo com a configuracao do usuario."
	Local cDesc3     := " "
	Local aArea	     := GetArea()
	Local lGerTXT    := .T.      
	Local nSvRecno   := BEA->(Recno())
	Local cFiltro    := ""
	Local lImpGuiNeg := GetNewPar("MV_IGUINE", .F.) //parametro para impressão de guia em análise
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros do relatorio (SX1)...                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta perguntas                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CriaSX1(aPar) //cria pergunta...
	
	lGerTXT := aPar[2] // Imprime Direto sem passar pela tela de configuracao/preview do relatorio
	
	If aPar[1] == "1" .And. ! (BEA->BEA_STATUS $ "1,2,3,4" .Or. (BEA->BEA_STATUS == '6' .And. getNewPar("MV_PLIBAUD",.F.) == .T.)) .and. !lImpGuiNeg
		Help("",1,"PLSR430")
		Return
	EndIf   
	
	If BEA->BEA_LIBERA == "1" .AND. !PLSSALDO("",BEA->(BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT)) .And. GetNewPar("MV_PLIMSAE","0") == "0"
		MsgAlert("Esta guia de solicitação ja foi executada ou não possui saldo, proceda com a impressão da guia de execução.")
		Return
	EndIf
	
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	
	aPerg := {mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par08,mv_par09}
	
	//--Altera o Set Epch para 1910
	nEpoca := SET(5, 1910)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Restaura Area e Ordem de Entrada                              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	//--Retornar Set Epoch Padrao
	SET(5, nEpoca)
	RestArea(aArea)
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ R430NIMP ³ Autor ³ Luciano Aparecido     ³ Data ³ 22/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSR430N                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca dados de parametros...                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MtaDados ³ Autor ³ Luciano Aparecido     ³ Data ³ 22/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava STATUS da tabela BEA e chama a funcao "PLSGSADT"     ³±±
±±³          ³ que ira retornar o array com os dados a serem impressos.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSR430N                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MtaDados(nGuia)

	Local aDados := {}
	Local lImpGuiNeg := GetNewPar("MV_IGUINE", .F.) //parametro para impressão de guia em análise
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ CriaSX1   ³ Autor ³ Luciano Aparecido    ³ Data ³ 22.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Atualiza SX1                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function CriaSX1(aPar)

LOCAL aRegs	 :=	{}

If aPar[1] == "1"
	aadd(aRegs,{cPerg,"01","Selecionar Layout Papel:" ,"","","mv_ch1","N", 1,0,0,"C","","mv_par01","Ofício 2"         	,"","","","","Papel A4"            	,"","","","","Papel Carta"              ,"","","","",""       ,"","","","","","","","",""   ,""})
Else
	aadd(aRegs,{cPerg,"09","Selecionar Layout Papel:" ,"","","mv_ch9","N", 1,0,0,"C","","mv_par09","Ofício 2"         	,"","","","","Papel A4"            	,"","","","","Papel Carta"              ,"","","","",""       ,"","","","","","","","",""   ,""})
Endif	                                                                                                                                                                   

PlsVldPerg( aRegs )

Return