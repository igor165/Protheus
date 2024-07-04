#Include "Protheus.ch"

Static nMemoST1 := 1048575

//-------------------------------------------------------------------
/*/{Protheus.doc} FDeParaTAF        

Esta funcao realiza o DE/PARA dos codigos do Protheus para o TAF

@Param cTipo     -> Tipo do De/Para que sera realizado
 	   aCodigos  -> Codigos a Serem Validados

@Return ( Nil ) 

@author Rodrigo Aguilar
@since  22/03/2013
@version 1.0

/*/                                 
//-------------------------------------------------------------------
Function FDeParaTAF( cTipo, aCodigos )

Local cRet := ""                           

//ÚÄÄÄÄÄÄÄ¿
//³Produto³
//ÀÄÄÄÄÄÄÄÙ
If cTipo == "SB1"
    	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso exista codigo de Servico informado no Protheus o mesmo³
	//³sera cadastrado no TAF com codigo 09 = servico             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( aCodigos[2] )
		cRet := "09"
	Else	
		Do Case 
			Case aCodigos[1] == "AI"
			      cRet := "08"
	        Case aCodigos[1] == "EM"
	        	cRet := "02"
	        Case aCodigos[1] == "MC"
	        	cRet := "07"    
	        Case aCodigos[1] == "ME"
	        	cRet := "00"        		        	    		
	        Case aCodigos[1] == "MP"
	        	cRet := "01"        		        	    		        	
	        Case aCodigos[1] == "OI"
	        	cRet := "10"        		        	    		        	        	
	        Case aCodigos[1] == "PA"
	        	cRet := "04"        		        	    		        	        	        	
	        Case aCodigos[1] == "PI"
	        	cRet := "06"        		        	    		        	        	        	        	
	        Case aCodigos[1] == "PP"
	        	cRet := "03"        		        	    		        	        	        	        	        	
	        Case aCodigos[1] == "SP"
	        	cRet := "05"        		        	    		        	        	        	        	        	        	
		EndCase	
	EndIf
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para os demais tipos de Proutos nao existem os respectivos codigos no TAF, ³
	//³assim todos entram como "99" (Outros)                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( cRet )
		cRet := "99"
	EndIf

ElseIf cTipo $ "SA1_AIF/SA4_AIF"
    
	Do Case

		Case aCodigos[1] $ "A1_COD/A4_COD"
		      cRet := "002"		
		Case aCodigos[1] $ "A1_NOME/A4_NOME" 
		      cRet := "003"		
		Case aCodigos[1] $ "A1_CODPAIS/A4_CODPAIS"
		      cRet := "004"
		Case aCodigos[1] $ "A1_CGC/A4_CGC"		      

			If Len(aCodigos[2]) > 11
		    	cRet := "005"
		    Else
		        cRet := "006"              
			EndIf		      				

		Case aCodigos[1] $ "A1_INSCR/A4_INSEST"
		      cRet := "007"				
		Case aCodigos[1] $ "A1_CODMUN/A4_COD_MUN"
		      cRet := "008"				
		Case aCodigos[1] $ "A1_SUFRAMA/A4_SUFRAMA"
		      cRet := "009"						      
		Case aCodigos[1] $ "A1_END/A4_END"		    		      
		      cRet := "011"				
		Case aCodigos[1] $ "A1_COMPLEM/A4_COMPLEM"
		      cRet := "013"				
		Case aCodigos[1] $ "A1_BAIRRO/A4_BAIRRO"
		      cRet := "015"				
		Case aCodigos[1] $ "A1_EST/A4_EST"
		      cRet := "016"				
		Case aCodigos[1] $ "A1_CEP/A4_CEP"
		      cRet := "017"				
		Case aCodigos[1] $ "A1_DDD/A4_DDD"
		      cRet := "018"				
        Case aCodigos[1] $ "A1_TEL/A4_TEL"
		      cRet := "019"				
		Case aCodigos[1] $ "A1_EMAIL/A4_EMAIL"
		      cRet := "022"				
		Case aCodigos[1] == "A1_FAX"
		      cRet := "021"				
		Case aCodigos[1] == "A1_PESSOA"
		      cRet := "024"				
	EndCase	                     

ElseIf cTipo == "SB1_AIF"

	Do Case
		Case aCodigos[1] == "B1_COD"
		      cRet := "01"		    
		Case aCodigos[1] == "B1_DESC"
		      cRet := "02"			      
		Case aCodigos[1] == "B1_CODBAR"
		      cRet := "03"	
		Case aCodigos[1] == "B1_UM"
		      cRet := "04"	                            
		Case aCodigos[1] == "B1_TIPO"
		      cRet := "05"	
		Case aCodigos[1] == "B1_POSIPI"
		      cRet := "06"	
		Case aCodigos[1] == "B1_EX_NCM"
		      cRet := "07"	
		Case aCodigos[1] == "B1_ORIGEM"
		      cRet := "14"	
		Case aCodigos[1] == "B1_PICM"
		      cRet := "16"	
	EndCase

ElseIf cTipo == "SFT_TIPO"

	Do Case			
		Case aCodigos[1] == "D"
			cRet := "01"
		Case aCodigos[1] == "I"
			cRet := "02"
		Case aCodigos[1] == "P"
			cRet := "03"
		Case aCodigos[1] == "C"
			cRet := "04"
		Case aCodigos[1] == "B"
			cRet := "05"                         
		OtherWise
			cRet := "00" 
	EndCase

ElseIf cTipo == "SFU_GRUPT"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma 1 no codigo do grupo de tensao eletrica ate o codigo ³
	//³11 para ficar de acordo com o Layout TAF. A partir do 12  ³
	//³os codigos equivalem                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCodigos[1] <= "11"
		cRet := StrZero(Val(aCodigos[1]) + 1,2)
	Else
		cRet := aCodigos[1]
	EndIf
	
EndIf                   

Return ( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FCrDirSys        

Esta Funcao realiza a Criacao dos Diretorios na RootPath

@Param aWizard    -> Parametrizacoes da Wizard
 	   cNomeDir   -> Nome da Pasta do System
 	   lJob       -> Indica se foi chamado por Job

@Return ( Nil ) 

@author Rodrigo Aguilar
@since  20/03/2013
@version 1.0

/*/                                 
//-------------------------------------------------------------------
Function FCrDirSys( aWizard, cNomeDir, lJob )

Local nRetDir  := 0

cNomeDir := "\Extrator_TAF"
If !File( cNomeDir )
	nRetDir := MakeDir( cNomeDir )

	If nRetDir != 0
		cNomeDir := ""
		If lJob
			ConOut( "EXTFISXTAF.PRW: " + DToS( Date() ) + "-" + Time() + "-" + OemToAnsi("Não foi possível criar o diretório. Erro: " + cValToChar( FError() )))
		Else
			Help( ,,"CRIADIR",, "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) , 1, 0 )
		EndIf
	EndIf
EndIf

If !Empty( cNomeDir )
	cNomeDir +=  "\" + Alltrim(DToS( aWizard[1][3] ) ) + "_" + Alltrim( DToS( aWizard[1][4] ) )
	If !File( cNomeDir )
		nRetDir := MakeDir( cNomeDir )

		If nRetDir != 0
			cNomeDir := ""
			If lJob
				ConOut( "EXTFISXTAF.PRW: " + DToS( Date() ) + "-" + Time() + "-" + OemToAnsi("Não foi possível criar o diretório. Erro: " + cValToChar( FError() )))
			Else
				Help( ,,"CRIADIR",, "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) , 1, 0 )
			EndIf
		EndIf
	EndIf
EndIf

If !Empty( cNomeDir )
	cNomeDir += "\" + StrTran( Alltrim( cFilAnt ), " ", "")
	If !File( cNomeDir )
		nRetDir := MakeDir( cNomeDir )

		If nRetDir != 0
			cNomeDir := ""
			If lJob
				ConOut( "EXTFISXTAF.PRW: " + DToS( Date() ) + "-" + Time() + "-" + OemToAnsi("Não foi possível criar o diretório. Erro: " + cValToChar( FError() )))
			Else
				Help( ,,"CRIADIR",, "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) , 1, 0 )
			EndIf
		EndIf
	EndIf
EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FConcTxt        

Funcao Generica para aglutinar as Strings e realizar a sua gravacao 
no arquivo TXT

@Param aRegs   -> Array com as Informacoes do Registro que serao gerados
 	   nHdlTxt -> Handle do Arquivo Criado   

@Return ( Nil ) 

@author Rodrigo Aguilar
@since  20/03/2013
@version 1.0

/*/                                 
//-------------------------------------------------------------------
Function FConcTxt( aRegs, nHdlTxt )

Local cDelimit := "|"            
Local cStrTxt  := ""
Local nI 	   := 1
Local nY       := 1     

For nI := 1 To Len( aRegs )
	cStrTxt += cDelimit
	For nY := 1 To Len( aRegs[nI] )
		
		If Valtype( aRegs[nI][nY] ) == "N"
			cStrTxt += Val2Str( aRegs[nI][nY], 16, 2 )
		ElseIf Valtype( aRegs[nI][nY] ) == "D"
			cStrTxt += DToS( aRegs[nI][nY] )
		Else
			cStrTxt += Alltrim( aRegs[nI][nY] )
		EndIf
		
		cStrTxt += cDelimit
	Next nY
	
	If cTpSaida == "1"     //"1-TXT MILE"
		cStrTxt += CRLF
	ElseIf cTpSaida == "2" //"2-Acesso Nativo"
		aAdd( aDadosST1 , cStrTXT )
		cStrTXT := ""
	EndIf

Next nI

If cTpSaida == "1"     //"1-TXT MILE"
	WrtStrTxt( nHdlTxt , @cStrTxt )	 
EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FConcST1        

Funcao que utiliza o array aDadosST1 aglutinado e grava na tabela 
TAFST1, apos a gravacao limpa o array aDadosST1 para o proximo layout

@Return ( Nil ) 

@author Alexandre Lemes
@since  29/05/2014
@version 1.0
/*/                                 
//-------------------------------------------------------------------
Function FConcST1()

Local nLine   := 1
Local cStrTxt := ""
Local cCodPai := IIf( cTpSaida == "2" , STUFF( aDadosST1[1] ,1 ,1 ,"" ) , "" )

If cTpSaida == "2" //"2-Acesso Nativo"
	
	cCodPai := Substr( cCodPai ,1 ,AT( "|",cCodPai)-1 )
	
	For nLine := 1 To Len(aDadosST1)
		
		cStrTxt := aDadosST1[nLine] + CRLF
		TAFST1Grv(AllTrim(cStrTxt),cCodPai,nLine)
		
	Next nLine
	
	aDadosST1 := {}
	
EndIf

Return ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} A117CriaWz        

Realiza a Criacao da Wizard do Extrator do Protheus

@Param	cNomWiz  -> Nome da Wizard 
		cNomeAnt -> Arquivo .CFP que ja possui as configuracoes da Wizard

@Return ( lRet ) -> Indica se foi criada a Wizard em Questao

@author Rodrigo Aguilar
@since  20/03/2013
@version 1.0

/*/                                 
//-------------------------------------------------------------------
Function ExtCriaWz ( cNomWiz, cNomeAnt )	

Local	cTitObj1	:=	""
Local	cTitObj2	:=	""	 

Local	cTamProd 	:=	TamSx3("B1_COD")[1]

Local	aTxtApre	:=	{}
Local	aPaineis	:=	{}
Local	aItens1		:=	{}

Local	lRet		:=	.T.   

Default	cNomeAnt	:= ""

aAdd( aTxtApre, "Parâmetros necessários." )
aAdd( aTxtApre, "" )	                      
aAdd( aTxtApre, "Preencha corretamente as informações solicitadas." )
aAdd( aTxtApre, "Informações necessárias para a Geração do Extrator." )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     PAINEL 0     															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd ( aPaineis, {} )
nPos :=	Len( aPaineis )

aAdd ( aPaineis[nPos], "Preencha corretamente as informações solicitadas." )
aAdd ( aPaineis[nPos], "Parâmetros para Geração" )
aAdd ( aPaineis[nPos], {} )

//--------------------------------------------------------------------------------------------------------------------------------------------------//

cTitObj1 :=	"Diretório do Arquivo Destino";							cTitObj2 :=	"Nome do Arquivo Destino"
aAdd( aPaineis[nPos][3], { 1, cTitObj1, , , , , , } );			aAdd ( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )

cTitObj1 :=	Replicate ( "X", 50 );									cTitObj2 :=	Replicate ( "X", 20 )
aAdd( aPaineis[nPos][3], { 2, , cTitObj1, 1, , , , 50 } );		aAdd ( aPaineis[nPos][3], { 2, , cTitObj2, 1, , , , 20 } )

aAdd( aPaineis[nPos][3], { 0, "", , , , , , } );					aAdd ( aPaineis[nPos][3], { 0, "", , , , , , } )

//--------------------------------------------------------------------------------------------------------------------------------------------------//
cTitObj1	:=	"Data de";								   			cTitObj2	:=	"Data até"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

aAdd (aPaineis[nPos][3], {2,,,3,,,,});							aAdd (aPaineis[nPos][3], {2,,,3,,,,}) 

aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

//--------------------------------------------------------------------------------------------------------------------------------------------------//

cTitObj1 :=	"Seleciona Filiais ?";								    cTitObj2 :=	"Período da Apuração de IPI ?"
aAdd( aPaineis[nPos][3], { 1, cTitObj1, , , , , , } );			aAdd( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )
                                                                  
aItens1	:=	{ "1-Sim", "2-Nao" };									aItens2	:=	{ "0-Mensal", "1-Decendial" }
												
aAdd( aPaineis[nPos][3], { 3, , , , , aItens1 , , } );			aadd( aPaineis[nPos][3], { 3, , , , , aItens2 , , } )

aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

//--------------------------------------------------------------------------------------------------------------------------------------------------//

cTitObj1 :=	"Incidência tributária no período ?";								    						 cTitObj2 :=	"Inicio Obrigação Escrituração Fiscal CIAP ?"
aAdd( aPaineis[nPos][3], { 1, cTitObj1, , , , , , } );													 aAdd( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )
                                                                  
aItens1	:=	{ "1-Regime não-cumulativo", "2-Regime cumulativo", "3-Regimes não-cumulativo e cumulativo" };  aItens2	:=	{ "1-Sim", "2-Não" }
												
aAdd( aPaineis[nPos][3], { 3, , , , , aItens1 , , } );													 aadd( aPaineis[nPos][3], { 3, , , , , aItens2 , , } )

aAdd (aPaineis[nPos][3], { 0,"",,,,,,});																	 aAdd (aPaineis[nPos][3], { 0,"",,,,,,})
//--------------------------------------------------------------------------------------------------------------------------------------------------//

cTitObj1 :=	"Seleciona Layouts ?";								    cTitObj2 :=	"Tipo de Saída?"
aAdd( aPaineis[nPos][3], { 1, cTitObj1, , , , , , } );			aAdd( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )			
                                                                  
aItens1	:=	{ "1-Sim", "2-Nao" };								aItens2	:=	{ "1-TXT MILE", "2-Acesso Nativo" };									
												
aAdd( aPaineis[nPos][3], { 3, , , , , aItens1 , , } );			aAdd( aPaineis[nPos][3], { 3, , , , , aItens2 , , } );			

aAdd (aPaineis[nPos][3], { 0,"",,,,,,});							aAdd (aPaineis[nPos][3], { 0,"",,,,,,})
//--------------------------------------------------------------------------------------------------------------------------------------------------//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     PAINEL 1     															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
aAdd (aPaineis[nPos], "Informações para processamento do Inventário")
aAdd (aPaineis[nPos], {})                                  
//--------------------------------------------------------------------------------------------------------------------------------------------------//
cTitObj1	:=	"Produto Inicial";										   cTitObj2	:=	"Produto Final"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						   aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", cTamProd);								   cTitObj2	:=	Replicate ("X", cTamProd)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,cTamProd});			       aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,cTamProd})
//--------------------------------------------------------------------------------------------------------------------------------------------------//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						   	       aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//--------------------------------------------------------------------------------------------------------------------------------------------------//
cTitObj1	:=	"Armazem Inicial";										   cTitObj2	:=	"Armazem Final"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						   aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", TamSx3("B1_LOCPAD")[1]);				   cTitObj2	:=	Replicate ("X", TamSx3("B1_LOCPAD")[1])
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,TamSx3("B1_LOCPAD")[1]});	   aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,TamSx3("B1_LOCPAD")[1]})
//--------------------------------------------------------------------------------------------------------------------------------------------------//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});								   aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//--------------------------------------------------------------------------------------------------------------------------------------------------//
cTitObj1	:=	"Considera o saldo De/Em poder de Terceiros";       	   cTitObj2    :=  "Considera saldo em processo"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						   aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
//
aItens2	:=	{}
aItens2	:=	{"1-Sim","2-Nao"}
//
aItens1	:=	{}													    
aAdd (aItens1, "1-Sim")                                           	
aAdd (aItens1, "2-Não")											         
aAdd (aItens1, "3-De Terceiros")									
aAdd (aItens1, "4-Em Terceiros")
aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});						aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
//--------------------------------------------------------------------------------------------------------------------------------------------------//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})     
//--------------------------------------------------------------------------------------------------------------------------------------------------//
cTitObj1	:=	"Motivo do Inventário";                            cTitObj2	:=	"Nome arq. Gerado no Reg. Inv. Mod.7"
aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,});		  	    	   aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
//
aItens1	:=	{};													   cTitObj2	:=	Replicate ("X", 8)
aAdd (aItens1, "01-Final do período")                                           	
aAdd (aItens1, "02-Mudança de trib. da mercadoria (ICMS)")
aAdd (aItens1, "03-Solic. da baixa cad., paral. temp. e outras")
aAdd (aItens1, "04-Na alteração de regime de pagamento")
aAdd (aItens1, "05-Por determinação dos fiscos")							
//
aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,8})
//--------------------------------------------------------------------------------------------------------------------------------------------------//
aAdd (aPaineis[nPos][3], {0,"",,,,,,}); 							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//--------------------------------------------------------------------------------------------------------------------------------------------------//

cTitObj1 :=	"Data de fechamento do estoque";						cTitObj2 :=	""
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )

aAdd (aPaineis[nPos][3], {2,,,3,,,,})

aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], { 0,"",,,,,,})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     PAINEL 2     															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd ( aPaineis, {} )
nPos :=	Len( aPaineis )

aAdd ( aPaineis[nPos], "Preencha corretamente as informações solicitadas." )
aAdd ( aPaineis[nPos], "Informações do SPED" )
aAdd ( aPaineis[nPos], {} )

//--------------------------------------------------------------------------------------------------------------------------------------------------//

cTitObj1 :=	"Cód. da Receita para prestação de serviços";			cTitObj2 :=	"Cód. da Receita para demais operações"
aAdd( aPaineis[nPos][3], { 1, cTitObj1, , , , , , } );			aAdd ( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )

cTitObj1 :=	Replicate ( "X", 6 );									cTitObj2 :=	Replicate ( "X", 6 )
aAdd( aPaineis[nPos][3], { 2, , cTitObj1, 1, , , , 6 } );			aAdd ( aPaineis[nPos][3], { 2, , cTitObj2, 1, , , , 6 } )

aAdd( aPaineis[nPos][3], { 0, "", , , , , , } );					aAdd ( aPaineis[nPos][3], { 0, "", , , , , , } )
//--------------------------------------------------------------------------------------------------------------------------------------------------//

lRet := XFunWizard( aTxtApre, aPaineis, cNomWiz, cNomeAnt )

Return( lRet )       
           
//-------------------------------------------------------------------
/*/{Protheus.doc} GParMxExt        

Retorna os Parametros SX6 Utilizados no Extrator

Esta funcao foi criada apenas para NAO chamar as funcoes 
GetNewPar() e SuperGetMV a todo momento.                   

A Lista dos parametros utilizados sera armazenada na STATIC
aParSX6 com seu conteudo e conteudo DEFAULT qdo nao existir

@Return ( aAllSX6 ) -> Array com os conteudos dos parametros

@author Rodrigo Aguilar
@since  10/04/2013
@version 1.0

/*/                                 
//-------------------------------------------------------------------
Function GParMxExt()
                  
Local nX		:= 0    
Local aAllSX6	:= {}                                
Local aParam 	:= {  { "MV_ESTADO" , ""     	},;  //01 
					  { "MV_UFRESPD", "GO"   	},;  //02 
					  { "MV_EASY"   , "N"    	},;  //03 
					  { "MV_OPSEMF" , ""     	},;  //04
					  { "MV_COMPFRT", "{}"   	},;  //05 
  					  { "MV_RATPROP", .F.    	},;  //06
  					  { "MV_M996TPR", .F.    	},;  //07
  					  { "MV_STUF"   , ""     	},;  //08
  					  { "MV_STUFS"  , ""	 	},;  //09
					  { "MV_STNIEUF", ""     	},;  //10
					  { "MV_RESF3FT", .F.    	},;  //11
					  { "MV_APUSEP", ""      	},;  //12
					  { "MV_LJSPED", ""      	 },; //13					  
  					  { "MV_CODBCCR", "201#202#203#204#208#301#302#303#304#307#308" },; //14
  					  { "MV_CODBCCC", "301#302#303#304#308" },; //15
  					  { "MV_EXPIND",  "5501/5502/6501/6502" },; //16  
  					  { "MV_SPCBPRH", .F.    	 },; //17
  					  { "MV_SPCBPSE", "" 	  	 },; //18
  					  { "MV_DATCIAP", "" 	  	 },; //19
  					  { "MV_LC102",   ""       	 },; //20
  					  { "MV_CIAPDAC",  "S"    	 },; //21
  					  { "MV_F9ITEM", "F9_ITEMNFE" },;//22
  					  { "MV_F9PROD", ""      	 },; //23
  					  { "MV_F9ESP", ""       	 },; //24
  					  { "MV_F9CHVNF", "" 	  	 },; //25
  					  { "MV_F9CC", "" 		  	 },; //26
  					  { "MV_F9PL", "" 		  	 },; //27
  					  { "MV_F9FRT", "" 	      	 },; //28
  					  { "MV_F9ICMST", "" 	  	 },; //29
  					  { "MV_F9DIF", "" 		  	 },; //30
  					  { "MV_F9SKPNF", .F. 	  	 },; //31
  					  { "MV_F9FUNC","F9_FUNCIT"  },; //32
  					  { "MV_SF9PDES","F9_DESCRI" },; //33
  					  { "MV_F9CTBCC", "2" 		 },; //34
  					  { "MV_F9GENCC", "" 		 },; //35
  					  { "MV_F9GENCT", "" 		 },; //36
  					  { "MV_F9VLLEG", "F9_VLLEG" },; //37
  					  { "MV_RNDCIAP", .T. 		 },; //38
  					  { "MV_DACIAP", "S" 		 },; //39
  					  { "MV_F9CDATF", .F. 		 },; //40
  					  { "MV_APRCOMP", .F. 		 }}  //41

For nX := 1 to Len( aParam )
	aAdd( aAllSX6 , GetNewPar( ( aParam[ nX, 1 ] ), aParam[ nX, 2 ] ) )
Next nX

Return ( aAllSX6 )        

//-------------------------------------------------------------------
/*/{Protheus.doc} GAIMxExt()        

Retorna os ALIAS existentes no dicionario SX3      
        
Esta funcao foi criada apenas para NAO chamar a funcao     
ALIASINDIC() a todo momento. Chamando ao entrar no MATXFIS 

Os Alias sao verificados atraves do retorno da funcao que  
alimenta a STATIC aAliIndic                                

@Return ( xRet ) -> Array com os conteudos do AliasIndic

@author Rodrigo Aguilar
@since  10/04/2013
@version 1.0

/*/                                 
//-------------------------------------------------------------------
Function GAIMxExt()      

Local nX := 0
Local xRet  := {}         
Local aAI_  := { "CDV", "CF2", "CF9" , "CF6", "CF8" }		

For nX := 1 to Len( aAI_ )
	aAdd( xRet, AliasIndic( aAI_[nX] ) )
Next nX

Return ( xRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GFPMxExt()        

Retorna se os campos existem no dicionario SX3            
 
Esta funcao foi criada apenas para NAO chamar a funcao     
FieldPos() a todo momento. Chamando ao entrar no MATXFIS   

Os Campos sao verificados atraves do retorno da funcao que 
alimenta a STATIC aFieldPos                                

@Return ( aRet ) -> Array com os conteudos do FieldPos

@author Rodrigo Aguilar
@since  10/04/2013
@version 1.0

/*/                                 
//-------------------------------------------------------------------
Function GFPMxExt()  
                                             
Local nX     := 0    
Local nPos   := 0
Local aAlias := {}
Local aRet 	 := {}
Local aFPCpo := { { "CDT", "CDT_SITEXT" },;  //01  
                  { "CDT", "CDT_DTAREC" },;   //02  
                  { "SF1", "F1_TPCTE"   },;   //03  
                  { "SA1", "A1_SIMPNAC" },;   //04  
                  { "SA2", "A2_SIMPNAC" },;   //05  
                  { "SA1", "A1_REGPB"   },;   //06  
                  { "SA2", "A2_REGPB"   },;   //07  
                  { "CDT", "CDT_INDFRT" },;   //08  
                  { "SFT", "FT_CHVNFE"  },;   //09  
                  { "CD3", "CD3_VOL115" },;   //10  
                  { "CD3", "CD3_CHV115" },;   //11  
                  { "CD5", "CD5_ACDRAW" },;   //12  
                  { "CD5", "CD5_DTPPIS" },;   //13  
                  { "CD5", "CD5_DTPCOF" },;   //14  
                  { "CD5", "CD5_LOCAL"  },;   //15  
                  { "SFU", "FU_GRUPT"   },;   //16  
                  { "SFU", "FU_TIPLIGA" },;   //17  
                  { "SFU", "FU_VLFORN"  },;   //18  
                  { "DT3", "DT3_TIPCMP" },;   //19  
                  { "SFT", "FT_INDNTFR" },;   //20  
                  { "SFT", "FT_DESCICM" },;   //21  
                  { "SFT", "FT_DESCZFR" },;	   //22  
                  { "DUL", "DUL_CODCLI" },;	   //23  
                  { "SFX", "FX_TPASSIN" },;	   //24  
                  { "SF9", "F9_TIPO"    },;   //25  
                  { "SF9", "F9_CODBAIX" },;   //26  
                  { "SFT", "FT_PAUTIPI" },;   //27  
                  { "SFT", "FT_PAUTIPI" },;   //28  
                  { "SFU", "FU_CLASSIF" },;   //29  
                  { "CF6", "CF6_CNPJ"   },;   //30  
                  { "CDL", "CDL_ITEMNF" },;   //31  
                  { "CDL", "CDL_DOCORI" },;   //32  
                  { "CDL", "CDL_SERORI" },;   //33  
                  { "CDL", "CDL_NFEXP"  },;   //34  
                  { "CDL", "CDL_SEREXP" },;   //35  
                  { "CDL", "CDL_ESPEXP" },;   //36  
                  { "CDL", "CDL_EMIEXP" },;   //37  
                  { "CDL", "CDL_CHVEXP" },;   //38  
                  { "CDL", "CDL_QTDEXP" },;   //39  
                  { "CDL", "CDL_FORNEC" },;   //40  
                  { "CDL", "CDL_LOJFOR" },;   //41  
                  { "SF4", "F4_VLAGREG" },;   //42  
                  { "SFT", "FT_PAUTPIS" },;   //43  
                  { "SFT", "FT_PAUTCOF" },;   //44  
                  { "SFT", "FT_MALQCOF" },;   //45  
                  { "SFT", "FT_MVALCOF" },;   //46  
                  { "SFT", "FT_TNATREC" },;   //47  
                  { "SFT", "FT_CNATREC" },;   //48  
                  { "SFT", "FT_GRUPONC" },;   //49  
                  { "SFT", "FT_DTFIMNT" },;   //50  
                  { "SB1", "B1_TNATREC" },;   //51  
                  { "SB1", "B1_CNATREC" },;   //52  
                  { "SB1", "B1_GRPNATR" },;   //53  
                  { "SB1", "B1_DTFIMNT" },;   //54  
                  { "SF4", "F4_TNATREC" },;   //55  
                  { "SF4", "F4_CNATREC" },;   //56  
                  { "SF4", "F4_GRPNATR" },;   //57  
                  { "SF4", "F4_DTFIMNT" },;   //58  
                  { "SFT", "FT_CSTPIS"  },;   //59  
                  { "SFT", "FT_CSTCOF"  },;   //60  
                  { "SF9", "F9_QTDPARC" },;   //61  
                  { "SF9", "F9_SLDPARC" },;   //62 
                  { "SFT", "FT_DESPICM" },;   //63  
                  { "SFA", "FA_TOTSAI"  },;   //64  
                  { "SFA", "FA_TOTTRIB" },;   //65  
                  { "SF9", "F9_PARCRED" } }   //66  

For nX := 1 to Len( aFPCpo )
	
	nPos := aScan( aAlias , {|x| x[1] == aFPCpo[nX,01] } ) 
	
	If nPos == 0   
		aAdd( aAlias , { aFPCpo[nX,01] , AliasIndic( aFPCpo[nX,01] ) } )
		nPos := Len( aAlias )
    EndIf         
    
	aAdd(aRet , IIf( aAlias[ nPos, 02 ] .And. ( aFPCpo[ nX, 01 ])->( FieldPos( aFPCpo[ nX, 02] ) ) > 0 , .T. , .F. ) )
	
Next nX

Return ( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafPartic       

Esta Funcao retorna as informacoes do participante

@Param cAlias -> Alias da Tabela ja Posicionada
 	          
@Return ( Nil ) 

@author Rodrigo Aguilar
@since  12/04/2013
@version 1.0

/*/                                 
//-------------------------------------------------------------------                  
Function TafPartic( cAlias, cAliasQry ) 

Local aRet    := Array( 07 )       
Local cAlS    := SubStr( cAlias, 2, 2 )
Local cTpPart := Iif( cAlias == "SA1", "C", Iif( cAlias == "SA2", "F", "T" ) )

Default cAliasQry := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando nao eh passado o Alias da Query assumimos que o Alias³
//³ja esta posicionado                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( cAliasQry )
	cAliasQry := cAlias
EndIf

aRet[1] := cTpPart + (cAliasQry)->&( cAlS + "_COD" ) 								 //Codigo
aRet[2] := (cAliasQry)->&( cAlS + "_EST"     )  	 								//Estado
aRet[3] := (cAliasQry)->&( cAlS + "_COD_MUN" )	  	 								//Codigo do Municipio

If Len( AllTrim( (cAliasQry)->&( cAlS + "_CGC") ) ) >= 14
	aRet[4] :=  SPEDConType(SPEDVldIE((cAliasQry)->&( cAlS + "_CGC"),,.F.))		//CNPJ
Else
	aRet[4] := "" 																	//CNPJ
EndIf
		
If cAlias <> "SA4" 																	//Transportador
	aRet[5] := (cAliasQry)->&( cAlS + "_PAIS"   )	  								//Pais
EndIf 

If Len(AllTrim((cAliasQry)->&( cAlS + "_CGC" ) ) ) < 14
	aRet[6] := SPEDConType(SPEDVldIE((cAliasQry)->&( cAlS + "_CGC"),,.F.))	   	//CPF
Else
	aRet[6] := ""																	//CPF
EndIf         

aRet[7] := (cAliasQry)->&( cAlS + "_NOME" ) 										//Nome
                                               
Return ( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafBrut        

Retorna o Total da Receita Bruta Mensal ( Similar a Funcao RecBrut do 
Sped Pis Cofins )

@Param dDataDe  -> Data Inicial do Processamento  
       dDataAte	-> Data Final do Processamento 
       nTotF    -> Variavel a ser somado o valor da Receita Bruta Mensal

@Return ( Nil ) 

@author Rodrigo Aguilar
@since  23/05/2013
@version 1.0

/*/                                 
//-------------------------------------------------------------------
Function TafBrut( dDataDe, dDataAte, nTotF )

Local cAliasCF8 := "CF8"

Local lExpF100	:=	.F.
Local lNatF100	:=	.F.

Local aNatRecBr	 :=	&(GetNewPar( "MV_RECBNAT","{}" ) )
Local lMVESTTELE := GetNewPar( "MV_ESTTELE", .F. )

Local nPosF100 := 0

Local aF100Aux := {} 
Local aParFil  := {} 
Local aRecTele := {}  

aF100Aux := FinSpdF100( Month( dDataDe ), Year( dDataDe ) )
	
For nPosF100 := 1 to Len( aF100Aux )
	
	lExpF100	:=	.F.
	lNatF100	:=	.F.
	
	If Len(aF100Aux[nPosF100]) > 25
		
		IF aF100Aux[nPosF100][22] $ "X"
			lExpF100 :=	.T.	
		EndIF
	    
	    If aScan(aNatRecBr, {|x| x == Alltrim(aF100Aux[nPosF100][26])}) > 0
	    	lNatF100 :=	.T.
	    Endif
	
	Elseif Len(aF100Aux[nPosF100]) > 21 
		
		IF aF100Aux[nPosF100][22]$"X"
			lExpF100	:=	.T.	
		EndIF
	EndIf
	
	If !lNatF100
		If lExpF100			
			nTotF += aF100Aux[nPosF100][2]					
		ElseIf aF100Aux[nPosF100][3] $ "04#06#07#08#09#49#99" .And. aF100Aux[nPosF100][15] <> "SE2"      
			nTotF += aF100Aux[nPosF100][2]		
		ElseIf aF100Aux[nPosF100][3] $ "01#02#03#05" .And. aF100Aux[nPosF100][15] <> "SE2"					
			nTotF += aF100Aux[nPosF100][2]			
		EndIF
	Endif

Next nCont

If AliasIndic( "CF8" )

	aAdd( aParFil, DTOS( dDataDe ) )
	aAdd( aParFil, DTOS( dDataAte ) )
	
	If SPEDFFiltro( 1, "CF8", @cAliasCF8, aParFil )
	
		Do While (cAliasCF8)->( !Eof() ) 			
		
			If Alltrim( (cAliasCF8)->CF8_INDOPE ) $ "1/2"
				nTotF += (cAliasCF8)->CF8_VLOPER
			EndIf
		
			(cAliasCF8)->( DbSkip() )			
		EndDo
	Endif
Endif		
	
IF lMVESTTELE

	aRecTele := TeleComFut( dDataDe, dDataAte,,,,,,,,,,,,.F., "", .T.) 	
	
	If Len( aRecTele ) > 0
		nTotF += aRecTele[1] + aRecTele[2] + aRecTele[3] + aRecTele[4]
	EndIF                                                      
	
EndIF

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FGerPerTAF        

Realiza a Busca do Periodo Solicitado nos Parametros De / Ate

@Param dDataD  -> Data Inicial 
	   dDataAt -> Data Final

@Return ( Nil ) 

@author Rodrigo Aguilar
@since  23/05/2013
@version 1.0

/*/                                 
//-------------------------------------------------------------------
Function FGerPerTAF( dDataD, dDataAt )

Local dDataDe  := LastDay( dDataD )
Local dDataAte := LastDay( dDataAt )
Local aRet    := {}

While dDataDe <> dDataAte
	Aadd( aRet, dDataDe ) 
	
	dDataDe := LastDay( LastDay( dDataDe ) + 1 )
EndDo                     

Aadd( aRet, dDataDe ) 

Return ( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} Desc2Cod        

Função que retorna o codigo de municipio atraves da descrição

@Param cDescMun    -> Descrição do municipio
 
@Return ( Nil ) 

@author Fabio V Santana
@since  02/05/2013
@version 1.0

/*/                                 
//-------------------------------------------------------------------
Function Desc2Cod(cDescMun)

Local cCodMun := ""

cDesMun := UPPER(cDescMun)

DbSelectArea("CC2")
CC2->(DbSetOrder(2))
CC2->(dbGoTop())    

If CC2->( MsSeek( xFilial( "CC2" ) + cDescMun ) )	    
	cCodMun := CC2->CC2_CODMUN
EndIf

Return ( cCodMun )     
//-------------------------------------------------------------------
/*/{Protheus.doc} RetLayTAF        

Funcao para retornar array com os Layouts TAF de acordo com tipo

@Param cTipo ->	1 - Retornar array com layouts de registros mensais
				2 - Retornar array com layouts de registros mensais,
				    quinzenais e decendiais
				3 - Retornar ambos
 
@Return aRet -> Array com os layouts de acordo com tipo selecionado
				por parametro

@author Felipe C. Seolin
@since  24/07/2013
@version 1.0

/*/                                 
//-------------------------------------------------------------------
Function RetLayTAF( cTipo )

Local aRet := {}
Local nI   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Todos os Layouts TAF que representam registros apenas gerados decendialmente, quinzenalmente e/ou mensalmente³
//³1 - Mensal                                                                                                   ³
//³2 - Outros                                                                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLayout := {	{"T001AH","1"},;
				{"T004","1"},;
				{"T030","1"},;
				{"T031","1"},;
				{"T032","1"},;
				{"T034","1"},;
				{"T035","1"},;
				{"T037","1"},;
				{"T050","1"},;
				{"T065","1"},;
				{"T067","1"},;
				{"T072","1"},;
				{"T073","1"},;
				{"T079","1"},;
				{"T082","1"},;
				{"T083","1"},;
				{"T020","2"},;
				{"T021","2"},;
				{"T022","2"}}

If cTipo $ "1|2"
	For nI := 1 to Len(aLayout)
		If aLayout[nI,2] == cTipo
			aAdd(aRet,aLayout[nI,1])
		EndIf
	Next nI
Else
	For nI := 1 to Len(aLayout)
		aAdd(aRet,aLayout[nI,1])
	Next nI
EndIf

Return( aRet )


/*/{Protheus.doc} TAFST1Grv
@author telso.carneiro
@since 09/05/2014
@version 1.0
@param cStrTxt, character, (Texto para Gravar)
@return ${return}, ${return_description}
/*/
Function TAFST1Grv(cStrTxt,cCodPai,nLine)
Local aWrtST1	:= {} 
Local cStrKey	:= ""
Local lPai	:= .F.
Local aCampos:= {}

cStrTxt := STUFF(cStrTxt, 1, 1, "") // Retira o "|" inicial
cStrTxt := STUFF(cStrTxt, AT(CRLF,cStrTxt), 2, "") 	

aWrtST1 := StrToKArr(cStrTxt,"|")
cStrKey := Upper(AllTrim(aWrtST1[1])) // Obtem a Chave para Comparação

lPai := (cStrKey == cCodPai)

If lPai
	RecLock("TAFST1",.T.)
	TAFST1->TAFFIL	:= cFilAnt
	TAFST1->TAFTPREG 	:= cStrKey //Grava o campo Chave
	TAFST1->TAFCODMSG	:= "1"
	TAFST1->TAFSEQ   	:= "001" // Grava a sequencia do Registro
	TAFST1->TAFKEY 	:= DtoS(dDatabase)+StrTran(Time(),":","")+cCodPai+cStrKey+cValtoChar(nLine) // Grava o campo Chave
	TAFST1->TAFSTATUS	:= "1" // Grava TAFSTATUS como pronto para Leitura
	TAFST1->TAFIDTHRD	:= " " // TAFIDTHRD sempre "branco" aqui.
	TAFST1->TAFMSG	:= cStrTxt
	MsUnlock()
Else
	cStrTxt := CRLF+'|'+cStrTxt
	If Len(TAFST1->TAFMSG) >= nMemoST1		
		Aadd(aCampos,{"TAFSEQ",SOMA1(TAFST1->TAFSEQ)})
		Aadd(aCampos,{"TAFMSG",cStrTxt})
		xCopyReg("TAFST1",aCampos) //copia registro
	Else
		RecLock("TAFST1",.F.)
		TAFST1->TAFMSG := TAFST1->TAFMSG+cStrTxt
		MsUnlock()
	EndIf
EndIf


Return(Nil)


/*/{Protheus.doc} xCopyReg
(long_description)
@author telso.carneiro
@since 12/05/2014
@version 1.0
@param aCampos, array, (Descrição do parâmetro)
@return ${return}, ${return_description}

/*/
Static Function xCopyReg(cCpAlias,aCampos)

Local nx
Local aRegistro := {}
Local nPosicao  := 0

// Le as informacoes do registro corrente
DbSelectArea(cCpAlias)
For nx:=1 to FCount()
	AAdd(aRegistro,FieldGet(nx))
Next nx
// Efetua a gravacao do novo registro
RecLock(cCpAlias,.T.)
For nx := 1 TO FCount()
	FieldPut(nx,aRegistro[nx])
Next nx
// Altera o conteudo dos campos passados como referencia
For nx := 1 to Len(aCampos)
	nPosicao:=FieldPos(aCampos[nx][1])
	If nPosicao > 0
		FieldPut(nPosicao,aCampos[nx][2])
	EndIf
Next nx
MsUnlock()

Return
