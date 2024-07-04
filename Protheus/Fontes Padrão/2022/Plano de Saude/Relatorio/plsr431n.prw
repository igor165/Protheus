#INCLUDE "plsr431n.ch"
#include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSR431N ³ Autor ³ Luciano Aparecido     ³ Data ³ 26.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Guia Odontológica - Solicitação/Cobrança                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSR431N(aPar)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLS                                                        ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSR431N(aPar) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local CbCont, Cabec1, Cabec2, Cabec3, wnrel
	Local cDesc1   := ""
	Local aArea	   := GetArea()
	Local nSvRecno := BEA->(Recno())
	Local Titulo	 := " "
	Local lImpGuiNeg := GetNewPar("MV_IGUINE", .F.) //parametro para impressão de guia em análise
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros do relatorio (SX1)...                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nLayout

	Private aReturn  := { "Zebrado", 1,"Administracao", 1, 1, 1, "", 1 }
	Private aLinha	 := { }
	Private nLastKey := 0
	Private cPerg 
	Private aPerg := {}
	
	If aPar[1] == "1"
   		cDesc1   := STR0002 //"Impressao da Guia Odontológica - Solicitação "
   		Titulo	 := STR0003  //"GUIA TRATAMENTO ODONTOLÓGICO - SOLICITAÇÃO"
   		If (aPar[1] == "1") .And. ! (BEA->BEA_STATUS $ "1,2,3,4") .and. !lImpGuiNeg 
  			 Help("",1,"PLSR430")
   			Return
		Endif 
		cString  := "BEA" 
	Else
  		cDesc1   := STR0004  //"Impressao da Guia Odontológica - Cobrança "
  		Titulo	 := STR0005 //"GUIA TRATAMENTO ODONTOLÓGICO - COBRANÇA"
  		cString  := "BD5"
	Endif    

  	If aPar[1] $"1/2" 
  		cPerg := "PL431N"
  	Else
  		cPerg := "PLR431"
  	Endif
  	
  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta perguntas                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CriaSX1(aPar) //nova pergunta...
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CbCont   := 0
	Cabec1   := OemtoAnsi(Titulo)
	Cabec2   := " "
	Cabec3   := " "
	aOrd     := {}
	              
	wnRel := "PLSR431N" // Nome Default do relatorio em Disco
	
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	
	aPerg := {mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par08,mv_par09}
	
	If nLastKey = 27
	    If FunName()== "PLS090O"
		    cFiltro := PLS090FIL("1")   
		    Set Filter To &cFiltro 
		Else
	      	Set Filter To 
	    EndIf  	
		Return
	Endif
	
	If aPar[1] $"1/2" 
  	
		nLayout := 2 
		
	Endif
	
	RptStatus({|lEnd| R431NImp(@lEnd, cString, aPar, nLayout, aPerg)}, Titulo)
	
	If aPar[1] == "1"
   		//-- Posiciona o ponteiro
   		BEA->(dbGoto(nSvRecno))	
	Else
		BD5->(dbGoto(nSvRecno))	
	Endif
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Restaura Area e Ordem de Entrada                              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	
	RestArea(aArea)
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ R431NIMP ³ Autor ³ Luciano Aparecido     ³ Data ³ 26/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSR431N                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R431NImp(lEnd, cString, aPar, nLayout, aPerg)

	LOCAL cCodOpe
	LOCAL cGrupoDe
	LOCAL cGrupoAte
	LOCAL cContDe
	LOCAL cContAte
	LOCAL cSubDe
	LOCAL cSubAte
	LOCAL cSQL
	Local aOdonto :={}  
	Local cTipo :='4' //Tratamento Odontológico - Verifica se é Guia de Odonto
	Local cOrigem :='1' //Tipo Autorização - Verifica se a Guia foi Autorizada
    Local cVerTISS  := PLSTISSVER() 
    
	If aPar[1] == "1" .Or. BEA->(FieldPos("BEA_GUIIMP")) == 0 //impressao individual
     	If BEA->BEA_TIPO == "4"
     		aAdd(aOdonto, MtaDados(aPar))
        Endif
    Elseif aPar[1] == "2"
    	aAdd(aOdonto, MtaDados(aPar))
	Else //impressao por lote... de acordo com o pergunte
	     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	     //³ Busca dados de parametros...                                             ³
	     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	     Pergunte(cPerg,.F.)
	
	     cCodOpe   := aPerg[1]
	     cGrupoDe  := aPerg[2]
	     cGrupoAte := aPerg[3]                                                                                       
	     cContDe   := aPerg[4]
	     cContAte  := aPerg[5]
	     cSubDe    := aPerg[6]
	     cSubAte   := aPerg[7]
	     nTipo     := aPerg[8]
	     nLayout   := aPerg[9]
	     
	     cSQL := "SELECT R_E_C_N_O_ AS REG FROM "+RetSQLName("BEA")+" WHERE "
	     cSQL += "BEA_FILIAL = '"+xFilial("BEA")+"' AND "
	     cSQL += "BEA_OPEMOV = '"+cCodOpe+"' AND "
	     cSQL += "( BEA_CODEMP >= '"+cGrupoDe+"' AND BEA_CODEMP <= '"+cGrupoAte+"' ) AND "
	     cSQL += "( BEA_CONEMP >= '"+cContDe+"' AND BEA_CONEMP <= '"+cContAte+"' ) AND "
	     cSQL += "( BEA_SUBCON >= '"+cSubDe+"' AND BEA_SUBCON <= '"+cSubAte+"' ) AND "
	     cSQL += "  BEA_ORIGEM = '" + cOrigem + "' AND "
	     cSQL += "  BEA_TIPO = '" + cTipo + "' AND "
	      
  	     If nTipo == 1
	        cSQL += "BEA_AUDITO = '1' AND "
	     ElseIf nTipo == 2
	        cSQL += "BEA_GUIIMP <> '1' AND "
	     Endif   
	     
	     cSQL += "D_E_L_E_T_ = ''"
	     
	     PLSQuery(cSQL,"Trb")
	     
	     If Trb->(Eof())
	        Trb->(DbCloseArea())
	        Help("",1,"RECNO")
	       
	        Return
	     Else   
	        While ! Trb->(Eof())
	        
	              BEA->(DbGoTo(Trb->REG))
	              //BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_FASE+BD5_SITUAC                                                                                      
	 				BD5->(dbSetOrder(2))
	              BD5->(MsSeek(xFilial("BD5")+BEA->(BEA_OPEMOV+BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI)))
	              aAdd(aOdonto, MtaDados(aPar,cTipo))
	        
	        Trb->(DbSkip())
	        Enddo          
	        
	        Trb->(DbCloseArea())
	     Endif                 
	Endif  
	
	If aPar[1] == "1" 
		
		If cVerTISS >= "3" .AND. FindFunction("PLSSOLINI")
			PLSSOLINI(aOdonto)
		Else
			PlSTISSA(aOdonto,nLayout)
		EndIf
		
	ElseIf aPar[1] == "2"
		PlSTISS9(aOdonto,nLayout)
	Else
		PlSTISS9(aOdonto,nLayout)
	EndIf
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MtaDados ³ Autor ³ Luciano Aparecido     ³ Data ³ 26/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava STATUS da tabela BEA e chama a funcao "PLSGODSO"     ³±±
±±³          ³ que ira retornar o array com os dados a serem impressos.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLSR431N                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MtaDados(aPar,nGuia)
  Local lImpGuiNeg := GetNewPar("MV_IGUINE", .F.) //parametro para impressão de guia em análise

	If aPar[1] == "1" .And. ((BEA->BEA_STATUS $ "1,2,3,4") .or. !lImpGuiNeg) 
     

		BEA->(RecLock("BEA", .F.))
		If BEA->BEA_STATUS == "4"
			BEA->BEA_STATUS := "1"
		EndIf
	
		If BEA->(FieldPos("BEA_GUIIMP")) > 0
			BEA->BEA_GUIIMP := "1"
		EndIf
	
		BEA->(MsUnLock())
	Endif
				
	If aPar[1] == "1"
		aDados := PLSGODSO() // Funcao que monta o array com os dados da guia Solicitação Odonto
	ELSE
		aDados := PLSGODCO()// Funcao que monta o array com os dados da guia Cobrança Odonto
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

If aPar[1] $"1/2" 
	aadd(aRegs,{cPerg,"01","Selecionar Layout Papel:" ,"","","mv_ch1","N", 1,0,0,"C","","mv_par01","Ofício 2"         	,"","","","","Papel A4"            	,"","","","","Papel Carta"              ,"","","","",""       ,"","","","","","","","",""   ,""})
Else
	aadd(aRegs,{cPerg,"09","Selecionar Layout Papel:" ,"","","mv_ch9","N", 1,0,0,"C","","mv_par09","Ofício 2"         	,"","","","","Papel A4"            	,"","","","","Papel Carta"              ,"","","","",""       ,"","","","","","","","",""   ,""})
Endif	                                                                                                                                                                   

PlsVldPerg( aRegs )

Return
