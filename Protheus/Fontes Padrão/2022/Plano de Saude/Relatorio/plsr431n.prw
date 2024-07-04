#INCLUDE "plsr431n.ch"
#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLSR431N � Autor � Luciano Aparecido     � Data � 26.03.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Guia Odontol�gica - Solicita��o/Cobran�a                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PLSR431N(aPar)                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLS                                                        ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSR431N(aPar) 

	//��������������������������������������������������������������Ŀ
	//� Define Variaveis                                             �
	//����������������������������������������������������������������
	Local CbCont, Cabec1, Cabec2, Cabec3, wnrel
	Local cDesc1   := ""
	Local aArea	   := GetArea()
	Local nSvRecno := BEA->(Recno())
	Local Titulo	 := " "
	Local lImpGuiNeg := GetNewPar("MV_IGUINE", .F.) //parametro para impress�o de guia em an�lise
	//��������������������������������������������������������������������������Ŀ
	//� Parametros do relatorio (SX1)...                                         �
	//����������������������������������������������������������������������������
	Local nLayout

	Private aReturn  := { "Zebrado", 1,"Administracao", 1, 1, 1, "", 1 }
	Private aLinha	 := { }
	Private nLastKey := 0
	Private cPerg 
	Private aPerg := {}
	
	If aPar[1] == "1"
   		cDesc1   := STR0002 //"Impressao da Guia Odontol�gica - Solicita��o "
   		Titulo	 := STR0003  //"GUIA TRATAMENTO ODONTOL�GICO - SOLICITA��O"
   		If (aPar[1] == "1") .And. ! (BEA->BEA_STATUS $ "1,2,3,4") .and. !lImpGuiNeg 
  			 Help("",1,"PLSR430")
   			Return
		Endif 
		cString  := "BEA" 
	Else
  		cDesc1   := STR0004  //"Impressao da Guia Odontol�gica - Cobran�a "
  		Titulo	 := STR0005 //"GUIA TRATAMENTO ODONTOL�GICO - COBRAN�A"
  		cString  := "BD5"
	Endif    

  	If aPar[1] $"1/2" 
  		cPerg := "PL431N"
  	Else
  		cPerg := "PLR431"
  	Endif
  	
  	//��������������������������������������������������������������������������Ŀ
	//� Ajusta perguntas                                                         �
	//����������������������������������������������������������������������������
	CriaSX1(aPar) //nova pergunta...
	
	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
	//����������������������������������������������������������������
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
	��������������������������������������������������������������Ŀ
	�Restaura Area e Ordem de Entrada                              �
	����������������������������������������������������������������*/
	
	RestArea(aArea)
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � R431NIMP � Autor � Luciano Aparecido     � Data � 26/03/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR431N                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	Local cTipo :='4' //Tratamento Odontol�gico - Verifica se � Guia de Odonto
	Local cOrigem :='1' //Tipo Autoriza��o - Verifica se a Guia foi Autorizada
    Local cVerTISS  := PLSTISSVER() 
    
	If aPar[1] == "1" .Or. BEA->(FieldPos("BEA_GUIIMP")) == 0 //impressao individual
     	If BEA->BEA_TIPO == "4"
     		aAdd(aOdonto, MtaDados(aPar))
        Endif
    Elseif aPar[1] == "2"
    	aAdd(aOdonto, MtaDados(aPar))
	Else //impressao por lote... de acordo com o pergunte
	     //��������������������������������������������������������������������������Ŀ
	     //� Busca dados de parametros...                                             �
	     //����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MtaDados � Autor � Luciano Aparecido     � Data � 26/03/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Grava STATUS da tabela BEA e chama a funcao "PLSGODSO"     ���
���          � que ira retornar o array com os dados a serem impressos.   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � PLSR431N                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MtaDados(aPar,nGuia)
  Local lImpGuiNeg := GetNewPar("MV_IGUINE", .F.) //parametro para impress�o de guia em an�lise

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
		aDados := PLSGODSO() // Funcao que monta o array com os dados da guia Solicita��o Odonto
	ELSE
		aDados := PLSGODCO()// Funcao que monta o array com os dados da guia Cobran�a Odonto
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

If aPar[1] $"1/2" 
	aadd(aRegs,{cPerg,"01","Selecionar Layout Papel:" ,"","","mv_ch1","N", 1,0,0,"C","","mv_par01","Of�cio 2"         	,"","","","","Papel A4"            	,"","","","","Papel Carta"              ,"","","","",""       ,"","","","","","","","",""   ,""})
Else
	aadd(aRegs,{cPerg,"09","Selecionar Layout Papel:" ,"","","mv_ch9","N", 1,0,0,"C","","mv_par09","Of�cio 2"         	,"","","","","Papel A4"            	,"","","","","Papel Carta"              ,"","","","",""       ,"","","","","","","","",""   ,""})
Endif	                                                                                                                                                                   

PlsVldPerg( aRegs )

Return
