
#INCLUDE "SNFCSTPART.CH"
#INCLUDE "PROTHEUS.CH" 

Function SNFCSTPART_Dummy() 

Return


/*-----------------


Definicao de Classe : SnfCstPart 

Descricao  : Verificacao do custo em partes utilizado e se possui Stored Procedure instalada 

Autor : Turibio Miranda
Data  : 09/10/2009


-----------------*/



Class SnfCstPart

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Propriedades                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Data aParameters      As Array      // Parametros 
	Data cVersion         As Character  // Versao 
	Data cProcessId       As Character  // Identificador unico do processo 
	Data cDescription     As Character  // Descricao do processo 
	Data cLongDesc        As Character  // Descricao detalhada do processo 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Construtor                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	
	Method New() Constructor
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ metodos                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	
	Method DefineScript()    // Gerador de script 
	Method Process()         // Processamento 
	
EndClass          


/*----------------- 
 
           
Classe     : SnfCstPart()  
Metodo     : New()

Descricao  : Construtor da classe 
 
Autor : Turibio Miranda 
Data  : 09/10/2009 



------------------*/  


Method New( oSniffer ) Class SnfCstPart 

Self:cVersion      := "001.00" 
Self:cProcessID    := "SNFCSTPART"             

                        
If oSniffer:nIdiom == 1 // Portugues 
	Self:cDescription  := "Verifica Custo em Partes" 
	Self:cLongDesc     := "Efetua a verificacao das regras do custo em partes utilizadas, analisando se existem campos obrigatorios ausentes no ambiente e ainda se utiliza Stored Procedures" 
ElseIf oSniffer:nIdiom == 2 // Espanhol	
	Self:cDescription  := "Verifica Costo en Partes" 
	Self:cLongDesc     := "Efetua a verificacao das regras do custo em partes utilizadas, analisando se existem campos obrigatorios ausentes no ambiente e se utiliza Stored Procedures" 
Else // Ingles 
	Self:cDescription  := "Check Cost in Parts" 
	Self:cLongDesc     := "Efetua a verificacao das regras do custo em partes utilizadas, analisando se existem campos obrigatorios ausentes no ambiente e ainda se utiliza Stored Procedures" 
EndIf
	
Return( Self ) 
                    

/*----------------- 
 
           
Classe     : SnfCstPart()  
Metodo     : DefineScript()

Descricao  : Define o script do processo 
Sintaxe    : ExpO1:DefineScript( ExpO2, ExpL1, ExpL2, @ExpN1 ) 
Parametros : ExpO2, ExpL1, ExpL2, ExpN1                  

			ExpO1 -> Objeto do Processo 

			ExpO2 -> Objeto Sniffer
			ExpL1 -> Indica se e a primeira pagina
			ExpL2 -> Indica se e a ultima pagina
			ExpN1 -> Opcao dos botoes ( por referencia ) 
			
Retorno    : .T. 			
 
Autor      : Turibio Miranda 
Data       : 09/10/2009


------------------*/  


Method DefineScript(  oSniffer, lFirst, lLast, nOption ) Class SnfCstPart 

Local aScript     := {} 

Local cFunction   := "MA330CP"
Local lListCpo	  := .F.

Local nLoop       := 0 
Local nScan       := 0 

Local oDlg
Local oBmp
Local oGetPesq1
Local oGetPesq2
Local oBut1
Local oBut2 
Local oBut3 
Local oBold   
Local oProject 
                                                         
nOption := 0              

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega os parametros ja preenchidos                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

If !Empty( nScan := AScan( oSniffer:aScript, { |x| x[1] == Self:cProcessID } ) ) 
	
	aScript := AClone( oSniffer:aScript[ nScan, 2 ] )
	
	For nLoop := 1 to Len( aScript ) 
	
		Do Case 
		Case aScript[ nLoop, 1 ] == "FUNCTION"
			cFunction   := "MA330CP"
		Case aScript[ nLoop, 1 ] == "LISTCPO" 
			lProject  := ( aScript[ nLoop, 2 ] == "YES" ) 
		EndCase 

	Next nLoop 
	
EndIf 	

DEFINE MSDIALOG oDlg TITLE Self:cDescription FROM 0,0 TO 380,420 OF oMainWnd PIXEL 

	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	
	@ 0, -10 BITMAP oBmp RESNAME "SNIFFER SIDE 2" oF oDlg SIZE 55, 1000 NOBORDER WHEN .F. PIXEL
	
	@  03, 54 SAY Self:cDescription FONT oBold PIXEL 
	
	@ 14, 50 TO If( SnfWndMode() == 1, 16, 15 ),400  LABEL ''  OF oDlg PIXEL 
	
	@  40, 54 SAY STR0001	 SIZE 160, 10  PIXEL  // Gerar o script de analise do custo em partes que será
	@  46, 54 SAY STR0002	 SIZE 160, 10  PIXEL  // utilizado no processamento do log das informações.   
	
	@ 60, 54 CHECKBOX oProject VAR lListCpo PROMPT STR0003 SIZE 160,040 OF oDlg PIXEL // Gerar lista de campos conforme as regras de CP?
	 
	If !lFirst 		 
		// Voltar	                                                                                        
		DEFINE SBUTTON oBut1 FROM 169, 111 TYPE 20 ACTION ( nOption := 1, oDlg:End() )  ENABLE of oDlg		 
	EndIf 	
   			
	If lLast    			
		// Concluir 
		DEFINE SBUTTON oBut2 FROM 169, 145 TYPE 01 ACTION ( nOption := 2, oDlg:End() )  ENABLE of oDlg
	Else            
		// Avancar 
		DEFINE SBUTTON oBut2 FROM 169, 145 TYPE 19 ACTION ( nOption := 2, oDlg:End() )  ENABLE of oDlg
	EndIf 		
		         
	// Cancelar 		
	DEFINE SBUTTON oBut3 FROM 169, 179 TYPE 02  ACTION ( nOption := 0, oDlg:End() )  ENABLE of oDlg	
	
ACTIVATE MSDIALOG oDlg CENTERED  

If !Empty( nOption ) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o script do processo                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If !Empty( nScan := AScan( oSniffer:aScript, { |x| x[1] == Self:cProcessID } ) ) 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apaga o script do processo                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		ADel( oSniffer:aScript, nScan ) 			

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ajusta o tamanho do Array                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		ASize( oSniffer:aScript, Len( oSniffer:aScript ) - 1 ) 
		
	EndIf 		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recria o Script                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	aScript := {} 
	                         
	AAdd( aScript, { "FUNCTION"     , cFunction } )
	AAdd( aScript, { "LISTCPO"      , If( lListCpo, "YES", "NO" ) } )  
	
	AAdd( oSniffer:aScript, { Self:cProcessID, AClone( aScript ), Self:cVersion } )  

EndIf 

Return( aScript ) 

  
/*----------------- 
 
           
Classe     : SnfCstPart()  
Metodo     : Process()

Descricao  : Process()
Sintaxe    : Process( ExpO1 )
Parametros : ExpO1 -> Objeto Sniffer 
Retorno    : ExpA1 -> Array parcial de LOG 
 
Autor      : Turibio Miranda 
Data       : 09/10/2009 


------------------*/  


Method Process( oSniffer ) Class SnfCstPart 

Local aBuffer    := {} 
Local aParam     := {} 
Local aRegra	 := {}
Local aPartes	 := {} 
Local aFalta	 := {}
Local aFaltaBd	 := {}
Local aProcs	 := {}
Local aListCpo	 := {}

Local cFunction  := ""
Local cCampo 	 := ""
  
Local lMA330CP   := ExistBlock("MA330CP")
Local lListCpo	 := .F.

Local nLoop      := 0 
Local nScan      := 0 
Local nMaxLen    := 0     
Local nRecnoSX3	 := 0

Local nX         := 0
Local nZ         := 0
Local nY         := 0

#IFDEF TOP
// Verifica a utilizacao de alguma procedures de custo em partes
Local lExistProcCP :=   ExistProc("M330INB2CP") .Or. ;
	                    ExistProc("M330INC2CP") .Or. ;
	                    ExistProc("MA280INB9CP") .Or. ;
	                    ExistProc("MA280INC2CP") .Or. ;
	                    ExistProc("MA330CP")
// Verifica se utiliza a procedure Pai (Recalculo do Custo Médio)
Local lExistProc   :=	IF (ExistProc("MAT004").And. lExistProcCP,.T.,.F.)
#ELSE
Local lExistProc:= .F.
#ENDIF                    
// Array com os campos que precisam ser criados para calculo do custo
Local aCampos      :={	{"B2_CP"  ,"B2_CM1"    ,"SB2","CP.Unit.","Custo em Partes Unitario"	},;
						{"B2_CPF" ,"B2_VFIM1"  ,"SB2","CP.Final","Custo em Partes Final"	},;
						{"B6_CP"  ,"B6_CUSTO1" ,"SB6","CP.Valor","Custo em Partes"			},;
						{"B9_CP"  ,"B9_VINI1"  ,"SB9","CP.Valor","Custo em Partes"			},;
						{"B9_CPM" ,"B2_CM1"    ,"SB9","CP.Unit.","Custo em Partes Unitario"	},;
						{"C2_CPF" ,"C2_VFIM1"  ,"SC2","CP.Final","Custo em Partes Final"	},;
						{"C2_CPI" ,"C2_VINI1"  ,"SC2","CP.Inic.","Custo em Partes Inicial"	},;
						{"C2_API" ,"C2_APRINI1","SC2","CP.AprIn","Apropriacao Inicial CP"	},;
						{"C2_APF" ,"C2_APRFIM1","SC2","CP.AprFm","Apropriacao Final CP"		},;
						{"D1_CP"  ,"D1_CUSTO"  ,"SD1","CP.Valor","Custo em Partes"			},;
						{"D2_CP"  ,"D2_CUSTO1" ,"SD2","CP.Valor","Custo em Partes"			},;
						{"D3_CP"  ,"D3_CUSTO1" ,"SD3","CP.Valor","Custo em Partes"			} }
    
            
If !Empty( nScan := AScan( oSniffer:aScript, { |x| x[1] == Self:cProcessID } ) ) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera os parametros                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParam := AClone( oSniffer:aScript[ nScan, 2 ] ) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa as variaveis                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLoop := 1 to Len( aParam ) 
	
		Do Case
		Case aParam[ nLoop, 1 ] == "FUNCTION" 
			cFunction := aParam[ nLoop, 2 ]		
		Case aParam[ nLoop, 1 ] == "LISTCPO" 
			lLISTCPO  := ( aParam[ nLoop, 2 ] == "YES" ) 
		EndCase
		
	Next nLoop 	 
              
	aBuffer := {}                                                               
		
	AAdd( aBuffer, STR0004 + DTOC( Date() ) ) 	   // Data             :  
	AAdd( aBuffer, "" ) 
		
	AAdd( aBuffer, STR0005 + DTOC( dDatabase ) )  // Database         :
	AAdd( aBuffer, STR0006 + Time() )             // Hora             :
	AAdd( aBuffer, "" ) 
	AAdd( aBuffer, STR0007 + If( lListCpo  , STR0009, STR0010 )) //  #Listar Campos CP :   #SIM #NAO
	AAdd( aBuffer, STR0008 + If( lExistProc, STR0009, STR0010 )) //  #Stored Procedures:   #SIM #NAO
	AAdd( aBuffer, "" ) 
				 
	If lMA330CP
   			aPartes:= ExecBlock("MA330CP",.F.,.F.)
			If Valtype (aPartes) # "A"
				aPartes:= {}
			EndIf 
	
		If !lExistProc    				//Verifica se não utiliza Stored Procedures
			 If Len(aPartes) > 0       //Verifica se o retorno do ponto de entrada possui regras de Custo em Partes
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica os campos obrigatórios para as regras utilizadas            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nY:=1 to Len(aCampos)
				
					For nX := 1 to Len(aPartes)+1
					
						dbSelectArea("SX3")
						dbSetOrder(2)
						dbSeek(aCampos[nY,2])
						nRecnoSX3 := Recno()
						
						For nZ := 1 to 5
						
							Aadd(aListCpo,{aCampos[nY,1]+StrZero(nX,2)+StrZero(nZ,2)})
					   
  							If !SX3->(MsSeek(aCampos[nY,1]+StrZero(nX,2)+StrZero(nZ,2)))
								//-- Posiciona no Registro
								dbGoto(nRecnoSX3)	
								Aadd(aFalta,{aCampos[nY,1]+StrZero(nX,2)+StrZero(nZ,2)})	//Campo no SX3
							EndIf   
							
							If 	(Alltrim(aCampos[nY,3]))->(FieldPos(aCampos[nY,1]+StrZero(nX,2)+StrZero(nZ,2))) <= 0
								Aadd(aFaltabd,{aCampos[nY,1]+StrZero(nX,2)+StrZero(nZ,2)})	//Campo no Banco
							EndIf
							
						Next nZ	
						
					Next nX
					
				Next nY  
				
			 EndIf 
			 
		EndIf
		 			 
	EndIf
	
	If lExistProc		
		Do Case  //Verifica se todas as procedures estão compiladas
			Case !ExistProc("M330INB2CP")
				AADD(aProcs,"M330INB2CP")		     
			Case !ExistProc("M330INC2CP") 
				AADD(aProcs,"M330INC2CP")	     
			Case !ExistProc("MA280INB9CP")
				AADD(aProcs,"MA280INB9CP")		     
			Case !ExistProc("MA280INC2CP")
				AADD(aProcs,"MA280INC2CP")		     
			Case !ExistProc("MA330CP")
				AADD(aProcs,"MA330CP")	
			EndCase
	EndIf				

			If !lExistProc 
				If lMA330CP
				    If Len(aPartes) > 0   
				    
							AAdd( aBuffer,  Alltrim(STR(Len(aPartes)+1)) +" "+ STR0011)								
							For nX:= 1 to Len(aPartes)
								AAdd( aBuffer, STR0012 + Alltrim(STR(nX))+": "+ aPartes[nX])
							Next nX 
							AAdd( aBuffer, STR0012 + Alltrim(STR(Len(aPartes)+1))+ STR0013)
							AAdd( aBuffer,  "")							
							
						If Len(aFalta) > 0
						
							AAdd( aBuffer,  STR0014 + STR0019 + STR0020) // #"Campos necessários para o Custo em Partes #ausentes #no dicionário: "
							For nX:= 1 to Len(aFalta)
								AAdd( aBuffer, aFalta[nX][1])
							Next nX 
							AAdd( aBuffer,  "") 
						
						EndIf
						
						If Len(aFaltaBd) > 0
						
							AAdd( aBuffer, STR0014 +  STR0019 + STR0021) // #"Campos necessários para o Custo em Partes #ausentes #na tabela: "
							For nX:= 1 to Len(aFaltaBd)
								AAdd( aBuffer, aFaltaBd[nX][1])
							Next nX 
							AAdd( aBuffer,  "") 
						
						EndIf

						If Len(aFalta) <= 0 .And. Len(aFaltaBd) <= 0
							AAdd( aBuffer,  STR0014 + STR0018)	// #Campos necessários para o Custo em Partes #OK
						EndIf
						
					Else
						
						AAdd( aBuffer,  STR0015 )	// #Nao existem regras de Custo em Partes no retorno do ponto de entrada MA330CP
						
					EndIf      
           	 	
           	 	Else
	    
    		   		AAdd( aBuffer, STR0016 + " MA330CP " + STR0017) // #Ponto de entrada MA330CP #não encontrado no repositório"
	       		
		        EndIf
	       

			Else
			
				AAdd( aBuffer, STR0022) // #Stored Procedures Instaladas: (Ponto de entrada MA330CP será
				AAdd( aBuffer, STR0023) // #desconsiderado, sendo executado diretamente da Stored Procedure)
				AAdd( aBuffer,  "") 
				For nX:= 1 to Len(aProcs)
					AAdd( aBuffer, "Procedure: "+ aProcs[nX]+ " não encontrada")
				Next nX 				
				AAdd( aBuffer,  "") 				 											
				
			EndIf
	    		
		If lListCpo 
		
			If lMA330CP .And. Len(aPartes) > 0

			    If !lExistProc
			    
					AAdd( aBuffer, "")
					AAdd( aBuffer, STR0024)	  //#Lista de Campos obritarórios para as regras de Custo em Partes existentes:
					AAdd( aBuffer, "")
					For nX:= 1 to Len(aListCpo)
						AAdd( aBuffer, aListCpo[nX][1])
					Next nX
					AAdd( aBuffer, "")				 

				Else	
				
					AAdd( aBuffer, STR0025)		//#Não é possível analisar Regras de Custo em Partes quando utiliza Stored Procedures
				
				EndIf
				
			Else
			
				AAdd( aBuffer, STR0026) //#Ponto de entrada não compilado ou sem regras definidas
				
			EndIf
       
        EndIf

EndIf

Return( aBuffer ) 