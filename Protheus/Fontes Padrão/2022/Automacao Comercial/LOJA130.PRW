#INCLUDE "LOJA130.CH"
#INCLUDE "PROTHEUS.CH"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia - F1CHI 		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static lCFolLocR5 	:=	GetRpoRelease ("R5") .AND. ;
						SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
						cPaisLoc$"CHI|COL"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOJA130  ³ Autor ³ Marcos R. Andrade     ³ Data ³ 23/11/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera numero de serie para PDV                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ BOPS ³Prograd.³ALTERACAO                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³07/03/07  ³120264³Mauro S.³Feita ordenacao do SL6                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                        
Function LOJA130()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis locais			   						     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg													// Objeto para montar a tela principal
LOCAL cCadastro := STR0001									// Titulo da janela. "Gera numero de serie automatico para Estacao"
LOCAL nOpca 	:= 0       									// Identifica se pressionou OK ou CANCELAR

Local cPerg		:= "LJA130"									//Pergunte

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia  - F1CHI 		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  lCFolLocR5
	cPerg := "LJA130CHI"
EndIf

dbSelectArea("SL6")
dbSetOrder( 1 ) 

While .T.


	Pergunte(cPerg,.F.)	    
	
	DEFINE MSDIALOG oDlg FROM 100,100 TO 350,510 TITLE cCadastro PIXEL;
	OF oMainWnd

	@ 03,05 TO 100,200 PIXEL
	@ 10,10 Say OemToAnsi(STR0002) SIZE 180,08 OF oDlg PIXEL 	// "Este programa gera numeros de serie para a estacao selecionada"
	@ 20,10 Say OemToAnsi(STR0003) SIZE 180,08 OF oDlg PIXEL	// "que sera utilizado quando o numero do COO for zerado, "
	@ 30,10 Say OemToAnsi(STR0004) SIZE 180,08 OF oDlg PIXEL	// "evitando que o usuario tenha que alterar a serie manualmente."

	DEFINE SBUTTON FROM 107,100 TYPE 5 ACTION (Pergunte(cPerg,.T.)) 	ENABLE OF oDlg
	DEFINE SBUTTON FROM 107,135 TYPE 1 ACTION (nOpca := 1,oDlg:End())  ENABLE OF oDlg
	DEFINE SBUTTON FROM 107,170 TYPE 2 ACTION (nOpca := 2,oDlg:End())  ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
  Exit
End

If nOpcA == 1
	Processa({|lEnd| lj130Processa()})	// Chamada da funcao de calculos
EndIf

Return( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ130Processa³ Autor ³ Marcos R. Andrade  ³ Data ³ 23/11/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera numero de serie automatico                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ130Processa()

Local cFilial	:= xFilial("SLG")	// Filial 
Local cEstacao	:= mv_par01 		// Codigo da Estacao
Local nQtd   	:= mv_par02     	// Quantidade de serie que ira ser reservada para cada estacao                 
Local nI		:= 1   				// Contador utilizado para reservar as series                          
Local cSerie	:= ""				// Verifica se a serie ja foi utilizada antes de reservar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis referente a criacao do indice.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cAliasSLG := ""				// Identifica a tabela para criacao do indice temporario
Local cArqInd   := ""				// Cria um arquivo de trabalho na memoria
Local nIndex  						// Retorna o indice temporario da tabela SLG  
Local cAliasSD2 := ""				// Identifica a tabela para criacao do indice temporario
Local cArqIndD2	:= ""             	// Cria um arquivo de trabalho na memoria
Local cQuery	:= ""      			// Query
Local nIndexD2						// Retorna o indice temporario da tabela SD2  
Local lGrava	:= .F.            	// Verifica se pode fazer a reserva da serie   
Local lOk		:= .T.				// Retorna se a serie foi gerada com sucesso

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia - F1CHI 		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cSerieForm:= ""   	       	//Serie do formulario selecionado 
Local aArea		:={}	    		//Area
If  lCFolLocR5
	cSerieForm	:= mv_par03		
EndIf

dbSelectArea("SLG")
dbSetOrder(1)
   
ProcRegua(RecCount())

#IFDEF TOP

	cQuery := "SELECT * "
	cQuery += "FROM " + RetSqlName("SLG") + " "
	cQuery += "WHERE D_E_L_E_T_ = '' AND "
	cQuery += "LG_FILIAL = '" + xFilial("SLG") + "' "
	
	If !Empty( cEstacao )
		cQuery += " AND LG_CODIGO = '" + cEstacao + "' "
	EndIf	
	
	cQuery += " ORDER BY LG_FILIAL,LG_SERIE "
    
	cQuery := ChangeQuery(cQuery)

	dbSelectArea("SLG")
	dbCloseArea()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SLG', .T., .T.)
	dbSelectArea("SLG")

#ELSE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria indice temporario na tabela SLG³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasSLG	:= "SLG"
	cArqInd 	:= CriaTrab(NIL,.F.)
	
	IndRegua(cAliasSLG,cArqInd,"LG_FILIAL+LG_SERIE") //"Selecionando Registros ..."
	nIndex := RetIndex("SLG")                                      

	dbSetIndex(cArqInd+OrdBagExT())	//RETORNA A EXTENSAO DO ARQUIVO	
	dbSetOrder(nIndex+1) 			//PEGA O INDICE CRIADO
	
#ENDIF	
          
#IFNDEF TOP

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria indice temporario na tabela SD2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD2")
	cAliasSD2	:= "SD2"
	cArqIndD2 	:= CriaTrab(NIL,.F.)
	
	IndRegua(cAliasSD2,cArqIndD2,"D2_FILIAL+D2_SERIE") 
	nIndexD2 := RetIndex("SD2")
	
	dbSetIndex(cArqIndD2+OrdBagExT()) 	//RETORNA A EXTENSAO DO ARQUIVO
	dbSetOrder(nIndexD2+1) 				//PEGA O INDICE CRIADO

	DbSelectArea("SLG")
	dbSetOrder( 1 )
	
	If !Empty( cEstacao )
		MsSeek( cFilial +  cEstacao )
	EndIF

#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia - F1CHI 		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  lCFolLocR5
	If !Empty(cSerieForm)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Formulario selecionado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If nQtd > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a quantidade for maior que zero,   ³
			//³o formulario selecionado sera ignorado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If MsgYesNo (STR0005)//"A série do controle de formulario selecionado nao sera utilizada pois o valor informado no campo quantidade é diferente de zero.Deseja Continuar ?"				
				nI := 1
			Else
				MsgStop (STR0006)//"Processo Cancelado."
				lOk := .F.	
			EndIf
		ElseIf nQtd == 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a quantidade for igual a zero, o preenchimento               ³
			//³da estacao e obrigatorio quando houver um formulario selecionado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If !Empty( cEstacao ) 		
				nI := 0				
			Else
				MsgStop (STR0007+CHR(10)+STR0006)//"Informe o codigo da estacao quando houver um controle de formulário selecionado."#"Processo Cancelado."
				lOk := .F.
			Endif
		Else
			lOk := .F.
		EndIf
	Else     	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao continuar se a serie do formulario for invalida ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  nQtd == 0
			MsgStop (STR0008)//"Quantidade Inválida"
			lOk:= .F.
		EndIf	
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o mv_par01 for vazio, gera serie automatica para todos os caixas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While SLG->( !Eof()) .And. SLG->LG_FILIAL == xFilial("SLG") .AND. lOk

	cEstacao:= SLG->LG_CODIGO
	cSerie 	:= SLG->LG_SERIE
        

	Do While nI <= nQtd 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Release 11.5 - Controle de Formularios 				   ³
		//³Se nI eh maior que zero indica que a serie nao sera     ³
		//³vinculada ao formulario, logo havera acrescimo na serie.³
		//³Caso contrario, a serie utilizada sera a do             ³
		//³formulario selecionado								   ³
		//³Paises:Chile/Colombia - F1CHI		                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nI > 0
			cSerie := Soma1(cSerie)
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Controle de Formularios ³
			//³Paises:Chile/Colombia - F1CHI		  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  lCFolLocR5
				cSerie := cSerieForm			
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe alguma outra estacao utilizando a serie antes de reservar.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  		If !LJ130ProcSer( cSerie )
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se existe a serie no SL6 na qual contem as reservas de serie         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   			dbSelectArea("SL6")
            dbSetOrder( 1 )
            
			If !SL6->( MsSeek( xFilial("SL6")+cSerie) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se existe a serie no SD2. Caso nao exita, reserva a serie para o pdv ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	            #IFDEF TOP

	            	cQuery := "SELECT D2_SERIE "
	            	cQuery += "FROM " + RetSqlName("SD2") + " "
					cQuery += "WHERE D_E_L_E_T_ = '' AND "
					cQuery += "D2_FILIAL = '" + xFilial("SD2") + "' AND "
					cQuery += "D2_SERIE = '" + cSerie + "' "
				
					cQuery := ChangeQuery(cQuery)
				
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SD22', .T., .T.)
					dbSelectArea("SD22")
					
					lGrava := Eof()
					
					dbCloseArea()
		   			dbSelectArea("SL6")
		
	            #ELSE

					lGrava := !SD2->( MsSeek( xFilial("SD2")+cSerie) )

	            #ENDiF
	            dbSelectArea("SD2") 
	
				If lGrava			
					If  lCFolLocR5 .AND. nQtd == 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Release 11.5 - Controle de Formularios 				 ³ 
						//³Validar se os valores dos parametros sao equivalentes ³
						//³ao controle de formularios selecionado                ³
						//³Paises:Chile/Colombia - F1CHI		                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aArea := GetArea()
						DbSelectArea ("SFP")
						DbSetOrder(3)         
						If !DbSeek(xFilial("SFP")+MV_PAR04+cSerie+MV_PAR08+MV_PAR06+MV_PAR07+MV_PAR05)
							MsgStop (STR0014)//"Dados do controle de formularios divergentes.Informe a serie novamente através da tela de pesquisa."
	            			lOk:= .F.
	        				Exit
						EndIf
						RestArea (aArea)								
					EndIf				
				
					RecLock("SL6", .T.)
						REPLACE L6_FILIAL 	WITH xFilial("SL6")
						SerieNfId("SL6",1,"L6_SERIE",dDataBase,LjEspecieNF(), cSerie)
						REPLACE L6_ESTACAO	WITH cEstacao
						REPLACE L6_STATUS	WITH '1'
						REPLACE L6_SITUA	WITH '0'						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿					
						//³Release 11.5 - Controle de Formularios     ³ 
						//³Grava os dados do formulario     		  ³
						//³Paises:Chile/Colombia - F1CHI		      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lCFolLocR5 .AND. nQtd == 0         
							REPLACE L6_FILFO	WITH MV_PAR04									
							REPLACE L6_ESPFO	WITH MV_PAR05
							REPLACE L6_NRINIFO	WITH MV_PAR06
							REPLACE L6_NRFIMFO	WITH MV_PAR07    
							REPLACE L6_CAIFO	WITH MV_PAR08													
						EndIf
						
					MsUnlock()
				   	nI++	
	            Else
	            	MsgStop (STR0009 + " " + cSerie + ".")//"Já existem documentos emitidos utilizando a série "
	            	lOk:= .F.
	        		Exit	        	    
	            Endif		            
	        Else
	        	If nI == 0
	        		MsgStop (STR0010 + " " + cSerie + " " + STR0011)//"A série "#"já está em uso."
	        		lOk:= .F.
	        		Exit	        	    
	        	EndIf
			EndIf			
		Else         
			MsgStop (STR0010 + " " + cSerie + " " + STR0012)//"A série"#" já está em uso por outra estação."			
			lOk:= .F.
		Endif		
	End
 	
	If !Empty(mv_par01)
		exit	
	EndIf   
	
	SLG->( dbSkip() )
 	nI := 1
 	
End	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao utiliza controle de formularios   ³
//³e a quantidade informada for igual a zero³
//³nao executa o processo.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  !lCFolLocR5 .AND. nQtd == 0
	lOk	:= .F.
EndIf

#IFDEF TOP    

	dbSelectArea("SLG")
	dbCloseArea()
	ChKFile("SLG")

#ELSE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deleta o indice temporario DO SLG³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasSLG)
	dbClearFilter()
	RetIndex("SLG")
	FErase(cArqInd+OrdBagExt())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deleta o indice temporario DO SD2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasSLG)
	dbClearFilter()
	RetIndex("SLG")
	FErase(cArqInd+OrdBagExt())
	

#ENDIF
If lOk
	MsgInfo (STR0013)//"Processo realizado com sucesso."
EndIf

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ130ProcSer ³ Autor ³ Marcos R. Andrade  ³ Data ³ 24/11/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existe a serie antes de reservar para estacao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function LJ130ProcSer( cSerie ) 

Local lRet		:= .F.        				// Retorna .T. para reservar a serie e .F. para nao reservar a serie
Local aArea		:= SLG->( GetArea()  )   	// Salva a area
Local cQuery 	:= ""                   	// Query utilizada para selecionar a serie

#IFDEF TOP
	
	cQuery := "SELECT * " 
	cQuery += "FROM " + RetSqlName("SLG") + " "
	cQuery += "WHERE D_E_L_E_T_ = '' AND "
	cQuery += "LG_FILIAL = '" + xFilial("SLG") + "' AND LG_SERIE = '" + cSerie + "'"
    
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SLG2', .T., .T.)
	dbSelectArea("SLG2")
	
	lRet := !Eof()
                      
	dbCloseArea()

#ELSE

	dbSelectArea("SLG")
	
	If SLG->( MsSeek( xFilial("SLG")+cSerie) )
	   	lRet	:= .T.
	EndIf             
	
#ENDIF
	
RestArea( aArea )

Return lRet
