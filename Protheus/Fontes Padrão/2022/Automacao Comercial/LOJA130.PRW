#INCLUDE "LOJA130.CH"
#INCLUDE "PROTHEUS.CH"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿝elease 11.5 - Controle de Formularios �
//쿛aises:Chile/Colombia - F1CHI 		  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Static lCFolLocR5 	:=	GetRpoRelease ("R5") .AND. ;
						SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
						cPaisLoc$"CHI|COL"

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � LOJA130  � Autor � Marcos R. Andrade     � Data � 23/11/05 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Gera numero de serie para PDV                              낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � SIGALOJA                                                   낢�
굇쳐컴컴컴컴컵컴컴컴쩡컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� DATA     � BOPS 쿛rograd.쿌LTERACAO                                   낢�
굇쳐컴컴컴컴컵컴컴컴탠컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�07/03/07  �120264쿘auro S.쿑eita ordenacao do SL6                      낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/                                                                        
Function LOJA130()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define variaveis locais			   						     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
LOCAL oDlg													// Objeto para montar a tela principal
LOCAL cCadastro := STR0001									// Titulo da janela. "Gera numero de serie automatico para Estacao"
LOCAL nOpca 	:= 0       									// Identifica se pressionou OK ou CANCELAR

Local cPerg		:= "LJA130"									//Pergunte

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿝elease 11.5 - Controle de Formularios �
//쿛aises:Chile/Colombia  - F1CHI 		  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커굇
굇쿑un뇚o    � LJ130Processa� Autor � Marcos R. Andrade  � Data � 23/11/05 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇쿏escri뇚o � Gera numero de serie automatico                             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇� Uso      � SIGALOJA                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
Function LJ130Processa()

Local cFilial	:= xFilial("SLG")	// Filial 
Local cEstacao	:= mv_par01 		// Codigo da Estacao
Local nQtd   	:= mv_par02     	// Quantidade de serie que ira ser reservada para cada estacao                 
Local nI		:= 1   				// Contador utilizado para reservar as series                          
Local cSerie	:= ""				// Verifica se a serie ja foi utilizada antes de reservar

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿣ariaveis referente a criacao do indice.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Local cAliasSLG := ""				// Identifica a tabela para criacao do indice temporario
Local cArqInd   := ""				// Cria um arquivo de trabalho na memoria
Local nIndex  						// Retorna o indice temporario da tabela SLG  
Local cAliasSD2 := ""				// Identifica a tabela para criacao do indice temporario
Local cArqIndD2	:= ""             	// Cria um arquivo de trabalho na memoria
Local cQuery	:= ""      			// Query
Local nIndexD2						// Retorna o indice temporario da tabela SD2  
Local lGrava	:= .F.            	// Verifica se pode fazer a reserva da serie   
Local lOk		:= .T.				// Retorna se a serie foi gerada com sucesso

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿝elease 11.5 - Controle de Formularios �
//쿛aises:Chile/Colombia - F1CHI 		  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿎ria indice temporario na tabela SLG�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cAliasSLG	:= "SLG"
	cArqInd 	:= CriaTrab(NIL,.F.)
	
	IndRegua(cAliasSLG,cArqInd,"LG_FILIAL+LG_SERIE") //"Selecionando Registros ..."
	nIndex := RetIndex("SLG")                                      

	dbSetIndex(cArqInd+OrdBagExT())	//RETORNA A EXTENSAO DO ARQUIVO	
	dbSetOrder(nIndex+1) 			//PEGA O INDICE CRIADO
	
#ENDIF	
          
#IFNDEF TOP

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿎ria indice temporario na tabela SD2�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿝elease 11.5 - Controle de Formularios �
//쿛aises:Chile/Colombia - F1CHI 		  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If  lCFolLocR5
	If !Empty(cSerieForm)
		//旼컴컴컴컴컴컴컴컴컴컴커
		//쿑ormulario selecionado�
		//읕컴컴컴컴컴컴컴컴컴컴��		
		If nQtd > 0
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//쿞e a quantidade for maior que zero,   �
			//쿽 formulario selecionado sera ignorado�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸		
			If MsgYesNo (STR0005)//"A s�rie do controle de formulario selecionado nao sera utilizada pois o valor informado no campo quantidade � diferente de zero.Deseja Continuar ?"				
				nI := 1
			Else
				MsgStop (STR0006)//"Processo Cancelado."
				lOk := .F.	
			EndIf
		ElseIf nQtd == 0
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//쿞e a quantidade for igual a zero, o preenchimento               �
			//쿭a estacao e obrigatorio quando houver um formulario selecionado�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��			
			If !Empty( cEstacao ) 		
				nI := 0				
			Else
				MsgStop (STR0007+CHR(10)+STR0006)//"Informe o codigo da estacao quando houver um controle de formul�rio selecionado."#"Processo Cancelado."
				lOk := .F.
			Endif
		Else
			lOk := .F.
		EndIf
	Else     	
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿙ao continuar se a serie do formulario for invalida �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If  nQtd == 0
			MsgStop (STR0008)//"Quantidade Inv�lida"
			lOk:= .F.
		EndIf	
	EndIf
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎aso o mv_par01 for vazio, gera serie automatica para todos os caixas.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Do While SLG->( !Eof()) .And. SLG->LG_FILIAL == xFilial("SLG") .AND. lOk

	cEstacao:= SLG->LG_CODIGO
	cSerie 	:= SLG->LG_SERIE
        

	Do While nI <= nQtd 
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿝elease 11.5 - Controle de Formularios 				   �
		//쿞e nI eh maior que zero indica que a serie nao sera     �
		//퀆inculada ao formulario, logo havera acrescimo na serie.�
		//쿎aso contrario, a serie utilizada sera a do             �
		//쿯ormulario selecionado								   �
		//쿛aises:Chile/Colombia - F1CHI		                   �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If nI > 0
			cSerie := Soma1(cSerie)
		Else
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//쿝elease 11.5 - Controle de Formularios �
			//쿛aises:Chile/Colombia - F1CHI		  �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			If  lCFolLocR5
				cSerie := cSerieForm			
			EndIf
		EndIf

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿣erifica se existe alguma outra estacao utilizando a serie antes de reservar.�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
  		If !LJ130ProcSer( cSerie )
	
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//쿣erifica se existe a serie no SL6 na qual contem as reservas de serie         �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   			dbSelectArea("SL6")
            dbSetOrder( 1 )
            
			If !SL6->( MsSeek( xFilial("SL6")+cSerie) )

				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//쿣erifica se existe a serie no SD2. Caso nao exita, reserva a serie para o pdv �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
						//쿝elease 11.5 - Controle de Formularios 				 � 
						//쿣alidar se os valores dos parametros sao equivalentes �
						//쿪o controle de formularios selecionado                �
						//쿛aises:Chile/Colombia - F1CHI		                 �
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
						aArea := GetArea()
						DbSelectArea ("SFP")
						DbSetOrder(3)         
						If !DbSeek(xFilial("SFP")+MV_PAR04+cSerie+MV_PAR08+MV_PAR06+MV_PAR07+MV_PAR05)
							MsgStop (STR0014)//"Dados do controle de formularios divergentes.Informe a serie novamente atrav�s da tela de pesquisa."
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
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�					
						//쿝elease 11.5 - Controle de Formularios     � 
						//쿒rava os dados do formulario     		  �
						//쿛aises:Chile/Colombia - F1CHI		      �
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
	            	MsgStop (STR0009 + " " + cSerie + ".")//"J� existem documentos emitidos utilizando a s�rie "
	            	lOk:= .F.
	        		Exit	        	    
	            Endif		            
	        Else
	        	If nI == 0
	        		MsgStop (STR0010 + " " + cSerie + " " + STR0011)//"A s�rie "#"j� est� em uso."
	        		lOk:= .F.
	        		Exit	        	    
	        	EndIf
			EndIf			
		Else         
			MsgStop (STR0010 + " " + cSerie + " " + STR0012)//"A s�rie"#" j� est� em uso por outra esta豫o."			
			lOk:= .F.
		Endif		
	End
 	
	If !Empty(mv_par01)
		exit	
	EndIf   
	
	SLG->( dbSkip() )
 	nI := 1
 	
End	

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e nao utiliza controle de formularios   �
//쿮 a quantidade informada for igual a zero�
//쿻ao executa o processo.                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If  !lCFolLocR5 .AND. nQtd == 0
	lOk	:= .F.
EndIf

#IFDEF TOP    

	dbSelectArea("SLG")
	dbCloseArea()
	ChKFile("SLG")

#ELSE

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿏eleta o indice temporario DO SLG�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	dbSelectArea(cAliasSLG)
	dbClearFilter()
	RetIndex("SLG")
	FErase(cArqInd+OrdBagExt())
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿏eleta o indice temporario DO SD2�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커굇
굇쿑un뇚o    � LJ130ProcSer � Autor � Marcos R. Andrade  � Data � 24/11/05 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇쿏escri뇚o � Verifica se existe a serie antes de reservar para estacao   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇� Uso      � SIGALOJA                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
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
