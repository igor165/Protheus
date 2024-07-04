#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TafxSpdE

Realiza a Geracao do Bloco E do Sped Fiscal

@param	aWizard		->	Wizard de geracao do Arquivo
		cTxtUsu     ->  Caminho / Nome do Arquivo para Geracao
		cFilSel		->	Variavel com as Filiais escolhidas pelo Usuario
		
@return aTotRegE

@author Rodrigo Aguilar
@since 14/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafxSpdE( aWizard, cFilSel, lConv115, cPerfilSPD, cTabSped ,cJobAux ) 

Local 	cTxtSys	:= 	CriaTrab(,.F.)+".TXT"
Local	cFilBkp	:=	cFilAnt	//Bakup da filial antes do inicio do processamento
Local	nI			:=	0
Local	lSave		:=	.F.

Local  dDataIni    := aWizard[1][1]
Local  dDataFim    := aWizard[1][2] 

Local	aCmps		:=	DistrCmps(dDataIni)                    
Local  aFilSel    := Separa( StrTran( cFilSel, "'", "" ), "," )

Local  nTotReg     := 1    
Local  nlI         := 0

Local	cStrTxt	 :=	''
Local 	aMacro      := {}

Local  lGerE001    :=  .F.

Local lFound := .T.
Local oError := ErrorBlock( { |Obj| Conout( "Mensagem de Erro: " + Chr(10)+ Obj:Description ) } )

Private aTotRegE    := {}
Private aInfoGrv := {}

//Deve ser private para geracao dos registros do bloco 0 gerados durante
//o processamento dos movimentos
Private aWizardBc  := aWizard
Private cFilSelBc  := cFilSel
Private cTabSpd    := cTabSped

Default cJobAux := ""

//Tratamento para que caso ocorra Erro durante o processamento não estoure na tela
//é exibida uma mensagem tratada do erro para o usuário final
Begin Sequence

	//No caso do Sped Fiscal apenas pode ser gerada uma filial por processamento, sendo assim, antes de iniciar a execução dos blocos
	//eu seto a filial onde ocorrera o processamento
	//cFilAnt := Substr( cFilSelBc, 2, 2 ) 
	
	//Array com as informações a serem geradas na tabela compartilhada
	//Filial + Data Inicio + Data Final + Bloco + Sequencializador
	aInfoGrv := { cFilAnt , DToS( aWizardBc[1,1] ), DToS( aWizardBc[1,2] ), "E", 0 }
	
	BlocoE( dDataIni , dDataFim , aCmps, @lGerE001 )        
	
	/*----------------------------------------------------------------------
	Caso nao tenha sido gerado o registro E001 ( Pois nao Houve Movimento )
	realizao a sua emissao agora
	-----------------------------------------------------------------------*/	
	If !lGerE001	
		aMacro	:=	{}
		aAdd( aMacro , "1" )
		
		/*----------------------------------------------------------
		Gravacao do registro E001 no arquivo texto
		----------------------------------------------------------*/	
		cStrTxt := ""
		LoadString( 'E001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		               
		//Conta os registros para totalizar no bloco 9
		TaFContBlc("E001",aTotRegE)
		
	EndIf
	
	For nlI := 1 To Len( aTotRegE )
		nTotReg += aTotRegE[nlI][2]
	Next           
	
	aMacro	:=	{}
	aAdd( aMacro , nTotReg )
	
	Reg990Spd( "E", cTabSped, cFilSel, aWizard )	
		       
	//Restauro a Filial salva no inicio do processamento
	cFilAnt	:=	cFilBkp

Recover
	lFound := .F. 
		
End Sequence

//Tratamento para quando ocorrer erros durante o processamento
ErrorBlock( oError )

If !lFound
	//Status 9 - Indico Que ocorreu Erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()
	
Else
	//Status 1 - Indico que o bloco foi encerrado corretamente para processamento Mult Thread
	PutGlbValue( cJobAux , "1" )
	GlbUnlock()

	//Altera o Status da tabela de controle para 2, indicando que o bloco foi processado
	xTafCtlObr( "2", "E", aWizardBc, cFilSelBc, , "TAFGERCTL", "SPEDFIS" )	
EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoE

Monta a Estrutura de Geracao dos Registros referentes ao BLOCO E

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		lGerE001    ->  Informa se ja foi gerado o Registro E001 
		
@return NIL

@author Rodrigo Aguilar
@since 14/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlocoE( dDataIni , dDataFim , aCmps, lGerE001 )

Local 	cAliasQry 	:=  GetNextAlias()
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0
Local	cQuery		:=	''
Local	aMacro		:=	{}
Local	lSeek		:=	.F. 
Local   cSeqReg     := ""

Iif(TAFColumnPos( "C2T_SEQREG" ), cSeqReg := "S", cSeqReg := "N")

/*-----------------------------------------------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK  ( Apuracao do ICMS Proprio )
------------------------------------------------------------------------------------------------*/
C2T->( dbSetOrder( 1 ) )
If cSeqReg == "S"
	C2U->( dbSetOrder( 2 ) )
	C2V->( dbSetOrder( 2 ) )
Else
	C2U->( dbSetOrder( 1 ) )
	C2V->( dbSetOrder( 1 ) )
EndIF
C2X->( dbSetOrder( 1 ) )
C2Z->( dbSetOrder( 1 ) )
C1A->( dbSetOrder( 4 ) )
C0R->( dbSetOrder( 6 ) )
C1G->( dbSetOrder( 3 ) )
C3E->( dbSetOrder( 3 ) )
C1H->( dbSetOrder( 5 ) )
C1L->( dbSetOrder( 3 ) )     
C01->( dbSetOrder( 3 ) )
C6R->( dbSetOrder( 3 ) )

If(TAFAlsInDic("T58"))
	T58->( dbSetOrder( 1 ) )
EndIf

cQuery	:=	"SELECT "              
cQuery	+=		"C2S.R_E_C_N_O_ "	
cQuery	+=	"FROM 
cQuery	+=		RetSqlName( 'C2S' ) + " C2S "
cQuery	+=	"WHERE 
cQuery	+=		"C2S.C2S_FILIAL='" + xFilial('C2S') + "' AND "
cQuery	+=		"C2S.C2S_TIPAPU='0' AND "
cQuery	+=		"C2S.C2S_DTINI>='" + DToS( dDataIni ) + "' AND "
cQuery	+=		"C2S.C2S_DTFIN<='" + DToS( dDataFim ) + "' AND "
cQuery	+=		"C2S.D_E_L_E_T_=' ' "
cQuery	+=	"ORDER BY "
cQuery	+=		"C2S_INDAPU, "
cQuery	+=		"C2S_DTINI, "
cQuery	+=		"C2S_DTFIN "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

If !lGerE001
	If !( cAliasQry )->( Eof() )	
		
	    aMacro	:=	{}
		aAdd( aMacro , "0" )
										
		/*----------------------------------------------------------
		Gravacao do registro E001 no arquivo texto
		----------------------------------------------------------*/	
		LoadString( 'E001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) ) >= 0                
			
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("E001",aTotRegE)
					
			lGerE001 := .T.
		EndIf
			
	EndIf
EndIf

/*-------------------------------------------------------------------------------------------------------
Laco Principal da Rotina para Realizar a Emissao dos Registros ( Apuracao do ICMS Proprio )
--------------------------------------------------------------------------------------------------------*/
While !( cAliasQry )->( Eof() )	
	C2S->( DbGoTo( ( cAliasQry )->R_E_C_N_O_ ) )

	If lGerE001		
		/*----------------------------------------------------------
		Gravacao do registro E100 no arquivo texto
		----------------------------------------------------------*/	
		LoadString( 'E100' , aCmps , @cStrTxt, 'C2S' )
		
		aInfoGrv[5]++
		If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' ) ) >= 0    
		
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("E100",aTotRegE)		    	        

			/*----------------------------------------------------------
			Gravacao do registro E110 no arquivo texto
			----------------------------------------------------------*/	
			LoadString( 'E110' , aCmps , @cStrTxt, 'C2S' )
			
			aInfoGrv[5]++
			If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' ) ) >= 0        	        
			
				//Conta os registros para totalizar no bloco 9
				TaFContBlc("E110",aTotRegE)			
			             
				/*----------------------------------------------------------
				Executando laco para gerar o registro E111
				----------------------------------------------------------*/					
				If C2T->( msSeek( xFilial( 'C2T' ) + C2S->C2S_ID ) )
					While !C2T->( Eof() ) .And. C2T->( C2T_FILIAL + C2T_ID ) == xFilial( 'C2T' ) + C2S->C2S_ID
					
						lSeek	:=	C1A->( msSeek( xFilial( 'C1A' ) + C2T->C2T_CODAJU ) )

						/*----------------------------------------------------------
						Gravacao do registro E111 no arquivo texto
						----------------------------------------------------------*/
						LoadString( 'E111' , aCmps , @cStrTxt , 'C2T' , lSeek )
						
						aInfoGrv[5]++
						nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
						
						//Conta os registros para totalizar no bloco 9
						TaFContBlc("E111",aTotRegE)						
						
						/*----------------------------------------------------------
						Executando laco para gerar o registro E112
						----------------------------------------------------------*/
						If cSeqReg == "S"
							cCondPai   := "C2T->( C2T_ID + C2T_CODAJU + C2T_IDSUBI + C2T_IDTMOT + PadR(C2T_SEQREG,TamSx3('C2T_SEQREG')[1]) )"
							cCondFilho := "C2U->( C2U_FILIAL + C2U_ID + C2U_CODAJU + C2U_IDSUBI + C2U_IDTMOT + STR(C2U_SEQREG) ) == xFilial( 'C2U' ) + C2T->( C2T_ID + C2T_CODAJU + C2T_IDSUBI + C2T_IDTMOT + STR(C2T_SEQREG) )"
						Else
							cCondPai   := "C2T->( C2T_ID + C2T_CODAJU  )"
							cCondFilho := "C2U->( C2U_FILIAL + C2U_ID + C2U_CODAJU ) == xFilial( 'C2U' ) + C2T->( C2T_ID + C2T_CODAJU )"
						EndIF
						
						If nRWStrTxt >= 0 .And. C2U->( msSeek( xFilial( 'C2U' ) + &cCondPai ) )
							While !C2U->( Eof() ) .And. &cCondFilho
							    
							    aMacro	:=	{ "", "", "" }
							    if C0R->( msSeek( xFilial( 'C0R' ) + C2U->C2U_DOCARR ) )
							    	
							    	if C1G->( msSeek( xFilial( 'C1G' ) + C0R->C0R_NRPROC ) )
										
										aMacro[1] :=  C1G->C1G_NUMPRO 
							    		aMacro[2] := C1G->C1G_INDPRO 
							    		aMacro[3] := C1G->C1G_DESCRI 
							    		
							    	elseif C1G->( msSeek( xFilial( 'C1G' ) + C2U->C2U_NRPROC ) )
							    
							    	aMacro[1] := C1G->C1G_NUMPRO
							    	aMacro[2] := C1G->C1G_INDPRO 
							    	aMacro[3] := C1G->C1G_DESCRI 
     					    				
							    	endif
							    
							    Elseif C1G->( msSeek( xFilial( 'C1G' ) + C2U->C2U_NRPROC ) )
							    
							    	aMacro[1] := C1G->C1G_NUMPRO
							    	aMacro[2] := C1G->C1G_INDPRO 
							    	aMacro[3] := C1G->C1G_DESCRI 
							    							    
							    endif							    								    
	
								/*----------------------------------------------------------
								Gravacao do registro E112 no arquivo texto
								----------------------------------------------------------*/								
								LoadString( 'E112' , aCmps , @cStrTxt , 'C0R' , , aMacro )
								
								aInfoGrv[5]++
								nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
								
								//Conta os registros para totalizar no bloco 9
								TaFContBlc("E112",aTotRegE)								
						
								If nRWStrTxt == -1
									Exit
								EndIf
																
								C2U->( dbSkip() )
							End
						EndIf						
						 
						/*----------------------------------------------------------
						Executando laco para gerar o registro E113
						----------------------------------------------------------*/
						If cSeqReg == "S"
							cCondPai   := "C2T->( C2T_ID + C2T_CODAJU + C2T_IDSUBI + C2T_IDTMOT + PadR(C2T_SEQREG,TamSx3('C2T_SEQREG')[1]) )"
							cCondFilho := "C2V->( C2V_FILIAL + C2V_ID + C2V_CODAJU + C2V_IDSUBI + C2V_IDTMOT + STR(C2V_SEQREG) ) == xFilial( 'C2V' ) + C2T->( C2T_ID + C2T_CODAJU + C2T_IDSUBI + C2T_IDTMOT + STR(C2T_SEQREG) )"
						Else
							cCondPai   := "C2T->( C2T_ID + C2T_CODAJU  )"
							cCondFilho := "C2V->( C2V_FILIAL + C2V_ID + C2V_CODAJU ) == xFilial( 'C2V' ) + C2T->( C2T_ID + C2T_CODAJU )"
						EndIf
						
						If nRWStrTxt >= 0 .And. C2V->( msSeek( xFilial( 'C2V' ) + &cCondPai ) )
							While !C2V->( Eof() ) .And. &cCondFilho
							
							    aMacro	:=	{ "", "", "" }
							    C1H->( dbSetOrder( 5 ) )
							    C1L->( dbSetOrder( 3 ) )
							    
								aMacro[1] :=  "C1H->( msSeek( xFilial( 'C1H' ) + C2V->C2V_CODPAR ) )" 
								aMacro[2] :=  "C01->( msSeek( xFilial( 'C01' ) + C2V->C2V_CODMOD ) )" 
								aMacro[3] :=  "C1L->( msSeek( xFilial( 'C1L' ) + C2V->C2V_CODITE ) )" 


								/*----------------------------------------------------------
								Gravacao do registro E113 no arquivo texto
								----------------------------------------------------------*/											
								LoadString( 'E113' , aCmps , @cStrTxt , 'C2V' , , aMacro )
								
								aInfoGrv[5]++
								nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
								
								//Conta os registros para totalizar no bloco 9
								TaFContBlc("E113",aTotRegE)								
						
								If nRWStrTxt == -1
									Exit
								EndIf						
		
								C2V->( dbSkip() )
							End
						EndIf

						If nRWStrTxt == -1
							Exit
						EndIf									
						 
						C2T->( DbSkip() )
					EndDo
				EndIf	 
				
				/*----------------------------------------------------------
				Executando laco para gerar o registro E115
				----------------------------------------------------------*/					
				If nRWStrTxt >= 0 .And. C2X->( msSeek( xFilial( 'C2X' ) + C2S->C2S_ID ) )
					While !C2X->( Eof() ) .And. C2X->( C2X_FILIAL + C2X_ID ) == xFilial( 'C2X' ) + C2S->C2S_ID
					    
					    aMacro	:=	{}
						
						If TAFAlsInDic("T58") 						    
							aAdd( aMacro , "T58->( msSeek( xFilial( 'T58' ) + C2X->C2X_INFADC ) )" )
						else
							aAdd( aMacro , "" )
						endif
						/*----------------------------------------------------------
						Gravacao do registro E115 no arquivo texto
						----------------------------------------------------------*/																	
						LoadString( 'E115' , aCmps , @cStrTxt , 'C2X' , , aMacro )
						
						aInfoGrv[5]++
						nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
						
						//Conta os registros para totalizar no bloco 9
						TaFContBlc("E115",aTotRegE)
														
						If nRWStrTxt  == -1									
							Exit
						EndIf					
					
						C2X->( dbSkip() )
					End
				EndIf
				
				/*----------------------------------------------------------
				Executando laco para gerar o registro E116
				----------------------------------------------------------*/					
				If nRWStrTxt >= 0 .And. C2Z->( msSeek( xFilial( 'C2Z' ) + C2S->C2S_ID ) )
					
					C1G->( dbSetOrder( 3 ) )					
					While !C2Z->( Eof() ) .And. C2Z->( C2Z_FILIAL + C2Z_ID ) == xFilial( 'C2Z' ) + C2S->C2S_ID											
						
						aMacro	:=	{ "", "", "", "", "" }
						if C0R->( msSeek( xFilial( 'C0R' ) + C2Z->C2Z_DOCARR ) )
					
							if C1G->( msSeek( xFilial( 'C1G' ) + C0R->C0R_NRPROC ) )
						    	
						    	aMacro[1] :=  C1G->C1G_NUMPRO 
						    	aMacro[2] :=  C1G->C1G_INDPRO 
						    	aMacro[3] :=  C1G->C1G_DESCRI 				
						    				
						   elseif C1G->( msSeek( xFilial( 'C1G' ) + C2Z->C2Z_NRPROC ) )
						   
                                aMacro[1] :=  C1G->C1G_NUMPRO 
     					    	aMacro[2] :=  C1G->C1G_INDPRO 
					    	    aMacro[3] :=  C1G->C1G_DESCRI
					    	    						   			
						   endif 
						
						elseif C1G->( msSeek( xFilial( 'C1G' ) + C2Z->C2Z_NRPROC ) )
						
					    	aMacro[1] :=  C1G->C1G_NUMPRO 
					    	aMacro[2] :=  C1G->C1G_INDPRO 
					    	aMacro[3] :=  C1G->C1G_DESCRI 						
						
						endif
						  
						aMacro[4] :=  "C3E->( msSeek( xFilial( 'C3E' ) + C0R->C0R_CODOBR ) )" 
						aMacro[5] :=  "C6R->( msSeek( xFilial( 'C6R' ) + C0R->C0R_CODREC ) )" 
					
						LoadString( 'E116' , aCmps , @cStrTxt , 'C0R' , , aMacro )
						
						//Conta os registros para totalizar no bloco 9
						TaFContBlc("E116",aTotRegE)
												
						
						aInfoGrv[5]++
						If( nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' ) ) == -1															
							Exit
						EndIf					
					
						C2Z->( dbSkip() )
					End
				EndIf														
			EndIf						
		EndIf			
	EndIf
 	
	If nRWStrTxt == -1
		Exit
	EndIf
	
	(cAliasQry)->( dbSkip() )	
EndDo          
(cAliasQry)->( DbCloseArea() )

/*------------------------------------------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK  ( Apuracao do ICMS ST )
-------------------------------------------------------------------------------------------*/          
C3K->( DbSetOrder( 1 ) )
C3L->( DbSetOrder( 1 ) )
C3M->( DbSetOrder( 1 ) )
C3N->( DbSetOrder( 1 ) )
C09->( DbSetOrder( 3 ) )

cQuery	:=	"SELECT "     
cQuery	+=		"C3J.R_E_C_N_O_ "
cQuery	+=	"FROM 
cQuery	+=		RetSqlName( 'C3J' ) + " C3J "
cQuery	+=	"WHERE 
cQuery	+=		"C3J.C3J_FILIAL='" + xFilial('C3J') + "' AND "
cQuery	+=		"C3J.C3J_DTINI>='" + DToS( dDataIni ) + "' AND "
cQuery	+=		"C3J.C3J_DTFIN<='" + DToS( dDataFim ) + "' AND "
cQuery	+=		"C3J.D_E_L_E_T_=' ' "
cQuery	+=	"ORDER BY "
cQuery	+=		"C3J_DTINI, "
cQuery	+=		"C3J_DTFIN "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )
 
If !lGerE001
	If !( cAliasQry )->( Eof() )	                    
	
	    aMacro	:=	{}
		aAdd( aMacro , "0" )
										
		/*----------------------------------------------------------
		Gravacao do registro E001 no arquivo texto
		----------------------------------------------------------*/	
		LoadString( 'E001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) ) >= 0                
		
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("E001",aTotRegE)
					
			lGerE001 := .T.
		EndIf	
		
	EndIf
EndIf

/*-------------------------------------------------------------------------------------------------------
Laco Principal da Rotina para Realizar a Emissao dos Registros ( Apuracao do ICMS ST )
--------------------------------------------------------------------------------------------------------*/
While !( cAliasQry )->( Eof() )	
    C3J->( DbGoTo( ( cAliasQry )->R_E_C_N_O_ ) )
    	
	If lGerE001		
	
	    aMacro	:=	{}
		aAdd( aMacro , "C09->( msSeek( xFilial( 'C09' ) + C3J->C3J_UF ) )" )
										
		/*----------------------------------------------------------
		Gravacao do registro E200 no arquivo texto
		----------------------------------------------------------*/	
		LoadString( 'E200' , aCmps , @cStrTxt, 'C3J', , aMacro )
		
		aInfoGrv[5]++
		If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' ) ) >= 0    
		
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("E200",aTotRegE)		
	
			/*----------------------------------------------------------
			Gravacao do registro E210 no arquivo texto
			----------------------------------------------------------*/	
			LoadString( 'E210' , aCmps , @cStrTxt, 'C3J' )
			
			aInfoGrv[5]++
			If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' ) ) >= 0    
			
				//Conta os registros para totalizar no bloco 9
				TaFContBlc("E210",aTotRegE)			
	
				/*----------------------------------------------------------
				Executando laco para gerar o registro E220
				----------------------------------------------------------*/					
				If C3K->( msSeek( xFilial( 'C3K' ) + C3J->C3J_ID ) )
					While !C3K->( Eof() ) .And. C3K->( C3K_FILIAL + C3K_ID ) == xFilial( 'C3K' ) + C3J->C3J_ID
					
						lSeek	:=	C1A->( msSeek( xFilial( 'C1A' ) + C3K->C3K_CODAJU ) )
	
						/*----------------------------------------------------------
						Gravacao do registro E220 no arquivo texto
						----------------------------------------------------------*/
						LoadString( 'E220' , aCmps , @cStrTxt , 'C3K' , lSeek )
						
						aInfoGrv[5]++
						nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
						
						//Conta os registros para totalizar no bloco 9
						TaFContBlc("E220",aTotRegE)						
						
						/*----------------------------------------------------------
						Executando laco para gerar o registro E230
						----------------------------------------------------------*/
						If nRWStrTxt >= 0 .And. C3L->( msSeek( xFilial( 'C3L' ) + C3K->( C3K_ID + C3K_CODAJU ) ) )
							While !C3L->( Eof() ) .And. C3L->( C3L_FILIAL + C3L_ID + C3L_CODAJU ) == xFilial( 'C3L' ) + C3K->( C3K_ID + C3K_CODAJU )
							    
							    aMacro	:=	{ "", "", "" }
							    if C0R->( msSeek( xFilial( 'C0R' ) + C3L->C3L_DOCARR ) )
							    	
							    	if C1G->( msSeek( xFilial( 'C1G' ) + C0R->C0R_NRPROC ) )
							    	
								    	aMacro[1] :=  C1G->C1G_NUMPRO 
								    	aMacro[2] :=  C1G->C1G_INDPRO 
								    	aMacro[3] :=  C1G->C1G_DESCRI 
								    	
								    elseif  C1G->( msSeek( xFilial( 'C1G' ) + C3L->C3L_NRPROC ) )
							    	
								    	aMacro[1] :=  C1G->C1G_NUMPRO 
								    	aMacro[2] :=  C1G->C1G_INDPRO 
								    	aMacro[3] :=  C1G->C1G_DESCRI
								    	 		
							    	endif 
							    
							    elseif  C1G->( msSeek( xFilial( 'C1G' ) + C3L->C3L_NRPROC ) )
							    	
							    	aMacro[1] :=  C1G->C1G_NUMPRO 
							    	aMacro[2] :=  C1G->C1G_INDPRO 
							    	aMacro[3] :=  C1G->C1G_DESCRI 								    
							   
							    endif
							    
								/*----------------------------------------------------------
								Gravacao do registro E230 no arquivo texto
								----------------------------------------------------------*/								
								LoadString( 'E230' , aCmps , @cStrTxt , 'C0R' , , aMacro )
								
								aInfoGrv[5]++
								nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
								
								//Conta os registros para totalizar no bloco 9
								TaFContBlc("E230",aTotRegE)								
						
								If nRWStrTxt == -1
									Exit
								EndIf
		
								C3L->( dbSkip() )
							End
						EndIf											
						
						/*----------------------------------------------------------
						Executando laco para gerar o registro E240
						----------------------------------------------------------*/
						If nRWStrTxt >= 0 .And. C3M->( msSeek( xFilial( 'C3M' ) + C3K->( C3K_ID + C3K_CODAJU ) ) )
							While !C3M->( Eof() ) .And. C3M->( C3M_FILIAL + C3M_ID + C3M_CODAJU ) == xFilial( 'C3M' ) + C3K->( C3K_ID + C3K_CODAJU )
							
							    aMacro	:=	{ "", "", "" }
								aMacro[1] :=  "C1H->( msSeek( xFilial( 'C1H' ) + C3M->C3M_CODPAR ) )" 
								aMacro[2] :=  "C01->( msSeek( xFilial( 'C01' ) + C3M->C3M_CODMOD ) )" 
								aMacro[3] :=  "C1L->( msSeek( xFilial( 'C1L' ) + C3M->C3M_CODITE ) )" 
	
								/*----------------------------------------------------------
								Gravacao do registro E240 no arquivo texto
								----------------------------------------------------------*/											
								LoadString( 'E240' , aCmps , @cStrTxt , 'C3M' , , aMacro )
								
								aInfoGrv[5]++
								nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
								
								//Conta os registros para totalizar no bloco 9
								TaFContBlc("E240",aTotRegE)								
						
								If nRWStrTxt == -1
									Exit
								EndIf						
		
								C3M->( dbSkip() )
							End
						EndIf
	
						If nRWStrTxt == -1
							Exit
						EndIf				
												
						C3K->(DbSkip())					
					EndDo
	            Endif   
	            
				/*----------------------------------------------------------
				Executando laco para gerar o registro E250
				----------------------------------------------------------*/					
				If nRWStrTxt >= 0 .And. C3N->( MsSeek( xFilial( 'C3N' ) + C3J->C3J_ID ) )
					While !C3N->( Eof() ) .And. C3N->( C3N_FILIAL + C3N_ID ) == xFilial( 'C3N' ) + C3J->C3J_ID
						
						aMacro	:=	{ "", "", "", "", "" }
						if C0R->( msSeek( xFilial( 'C0R' ) + C3N->C3N_DOCARR ) )				
						    
						    if C1G->( msSeek( xFilial( 'C1G' ) + C0R->C0R_NRPROC ) )
						    
						    	aMacro[1] :=  C1G->C1G_NUMPRO 
						    	aMacro[2] :=  C1G->C1G_INDPRO 
						    	aMacro[3] :=  C1G->C1G_DESCRI 
						    		
						    elseif C1G->( msSeek( xFilial( 'C1G' ) + alltrim(C3N->C3N_NRPROC)) )
						
						    	aMacro[1] :=  C1G->C1G_NUMPRO 
						    	aMacro[2] :=  C1G->C1G_INDPRO 
						    	aMacro[3] :=  C1G->C1G_DESCRI 	
					    	     							    
						    endif 
						
						elseif C1G->( msSeek( xFilial( 'C1G' ) + alltrim(C3N->C3N_NRPROC) ) )
						
					    	aMacro[1] :=  C1G->C1G_NUMPRO 
					    	aMacro[2] :=  C1G->C1G_INDPRO 
					    	aMacro[3] :=  C1G->C1G_DESCRI 						
						 
						endif
						    
						aMacro[4] :=  "C3E->( msSeek( xFilial( 'C3E' ) + C0R->C0R_CODOBR ) )" 
						aMacro[5] :=  "C6R->( msSeek( xFilial( 'C6R' ) + C0R->C0R_CODREC ) )" 						
					
						/*----------------------------------------------------------
						Gravacao do registro E250 no arquivo texto
						----------------------------------------------------------*/											
						LoadString( 'E250' , aCmps , @cStrTxt , 'C0R' , , aMacro )   
						
						aInfoGrv[5]++
						nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
						
						//Conta os registros para totalizar no bloco 9
						TaFContBlc("E250",aTotRegE)
														
						If nRWStrTxt  == -1									
							Exit
						EndIf																
						C3N->( dbSkip() )
					End
				EndIf							
			EndIf
	    EndIf
    EndIf
    ( cAliasQry )->( DbSkip() ) 
EndDo                 
( cAliasQry )->(DbCloseArea())    

/*---------------------------------------------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK  ( Apuracao de DIFAL/FECP )
----------------------------------------------------------------------------------------------*/  
If TAFAlsInDic("LEF")
	LEF->( DbSetOrder( 1 ) )
	LEG->( DbSetOrder( 1 ) )
	LEH->( DbSetOrder( 1 ) )
	LEI->( DbSetOrder( 1 ) )
	LEQ->( DbSetOrder( 1 ) )
	
	cQuery	:=	"SELECT "              
	cQuery	+=		"LEF.R_E_C_N_O_ "	
	cQuery	+=	"FROM 
	cQuery	+=		RetSqlName( 'LEF' ) + " LEF "
	cQuery	+=	"WHERE 
	cQuery	+=		"LEF.LEF_FILIAL='" + xFilial('LEF') + "' AND "
	cQuery	+=		"LEF.LEF_DTINI>='" + DToS( dDataIni ) + "' AND "
	cQuery	+=		"LEF.LEF_DTFIN<='" + DToS( dDataFim ) + "' AND "
	cQuery	+=		"LEF.D_E_L_E_T_=' ' "
	cQuery	+=	"ORDER BY "
	cQuery	+=		"LEF_UF, "
	cQuery	+=		"LEF_DTINI, "
	cQuery	+=		"LEF_DTFIN "
	
	cQuery	:=	ChangeQuery( cQuery )
	dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )
	
	If !lGerE001
		If !( cAliasQry )->( Eof() )	
			
		    aMacro	:=	{}
			aAdd( aMacro , "0" )
											
			/*----------------------------------------------------------
			Gravacao do registro E001 no arquivo texto
			----------------------------------------------------------*/	
			LoadString( 'E001' , aCmps , @cStrTxt, , , aMacro )
			
			aInfoGrv[5]++
			If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) ) >= 0                
				
				//Conta os registros para totalizar no bloco 9
				TaFContBlc("E001",aTotRegE)
						
				lGerE001 := .T.
			EndIf
				
		EndIf
	EndIf
	
	/*-------------------------------------------------------------------------------------------------------
	Laco Principal da Rotina para Realizar a Emissao dos Registros ( Apuracao de DIFAL/FECP )
	--------------------------------------------------------------------------------------------------------*/
	While !( cAliasQry )->( Eof() )	
		LEF->( DbGoTo( ( cAliasQry )->R_E_C_N_O_ ) )
	
		If lGerE001		
			/*----------------------------------------------------------
			Gravacao do registro E300 no arquivo texto
			----------------------------------------------------------*/	
			aMacro	:=	{}
			aAdd( aMacro , "C09->( msSeek( xFilial( 'C09' ) + LEF->LEF_UF ) )" )
			
			LoadString( 'E300' , aCmps , @cStrTxt, 'LEF', ,aMacro  )
			
			aInfoGrv[5]++
			If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' ) ) >= 0    
			
				//Conta os registros para totalizar no bloco 9
				TaFContBlc("E300",aTotRegE)		    	        
				
				/*----------------------------------------------------------
				Gravacao do registro E310 no arquivo texto
				----------------------------------------------------------*/	
				LoadString( 'E310' , aCmps , @cStrTxt, 'LEF' )
				
				aInfoGrv[5]++
				If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' ) ) >= 0        	        
				
					//Conta os registros para totalizar no bloco 9
					TaFContBlc("E310",aTotRegE)			
				             
					/*----------------------------------------------------------
					Executando laco para gerar o registro E311
					----------------------------------------------------------*/					
					If LEG->( msSeek( xFilial( 'LEG' ) + LEF->LEF_ID ) )
						While !LEG->( Eof() ) .And. LEG->( LEG_FILIAL + LEG_ID ) == xFilial( 'LEG' ) + LEF->LEF_ID
						
							lSeek	:=	C1A->( msSeek( xFilial( 'C1A' ) + LEG->LEG_CODAJU ) )
	
							/*----------------------------------------------------------
							Gravacao do registro E111 no arquivo texto
							----------------------------------------------------------*/
							LoadString( 'E311' , aCmps , @cStrTxt , 'LEG' , lSeek )
							
							aInfoGrv[5]++
							nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
							
							//Conta os registros para totalizar no bloco 9
							TaFContBlc("E311",aTotRegE)						
							
							/*----------------------------------------------------------
							Executando laco para gerar o registro E312
							----------------------------------------------------------*/
							If nRWStrTxt >= 0 .And. LEH->( msSeek( xFilial( 'LEH' ) + LEG->( LEG_ID + LEG_CODAJU ) ) )
								While !LEH->( Eof() ) .And. LEH->( LEH_FILIAL + LEH_ID + LEH_CODAJU ) == xFilial( 'LEH' ) + LEG->( LEG_ID + LEG_CODAJU )
								  
									 aMacro	:=	{ "", "", "" }
								    if C0R->( msSeek( xFilial( 'C0R' ) + LEH->LEH_DOCARR ) )
								    	
								    	if C1G->( msSeek( xFilial( 'C1G' ) + C0R->C0R_NRPROC ) )
											
											aMacro[1] :=  C1G->C1G_NUMPRO 
								    		aMacro[2] :=  C1G->C1G_INDPRO 
								    		aMacro[3] :=  C1G->C1G_DESCRI 
								    		
								    	elseif C1G->( msSeek( xFilial( 'C1G' ) + LEH->LEH_NRPROC ) )
								    
									    	aMacro[1] :=  C1G->C1G_NUMPRO 
									    	aMacro[2] :=  C1G->C1G_INDPRO 
									    	aMacro[3] :=  C1G->C1G_DESCRI
								    	    	
								    	endif
								    
								    elseif C1G->( msSeek( xFilial( 'C1G' ) + LEH->LEH_NRPROC ) )
								    
								    	aMacro[1] :=  C1G->C1G_NUMPRO 
								    	aMacro[2] :=  C1G->C1G_INDPRO 
								    	aMacro[3] :=  C1G->C1G_DESCRI 
								    							    
								    endif						    								    
			
									/*----------------------------------------------------------
									Gravacao do registro E312 no arquivo texto
									----------------------------------------------------------*/								
									LoadString( 'E312' , aCmps , @cStrTxt , 'C0R' , , aMacro )
									
									aInfoGrv[5]++
									nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
									
									//Conta os registros para totalizar no bloco 9
									TaFContBlc("E312",aTotRegE)								
							
									If nRWStrTxt == -1
										Exit
									EndIf
									
									LEH->( dbSkip() )
								
								End
							EndIf						
							 
							/*----------------------------------------------------------
							Executando laco para gerar o registro E313
							----------------------------------------------------------*/
							If nRWStrTxt >= 0 .And. LEQ->( msSeek( xFilial( 'LEQ' ) + LEG->( LEG_ID + LEG_CODAJU ) ) )
								While !LEQ->( Eof() ) .And. LEQ->( LEQ_FILIAL + LEQ_ID + LEQ_CODAJU ) == xFilial( 'LEQ' ) + LEG->( LEG_ID + LEG_CODAJU )
								
								    aMacro	:=	{ "", "", "" }
									aMacro[1] :=  "C1H->( msSeek( xFilial( 'C1H' ) + LEQ->LEQ_CODPAR ) )" 
									aMacro[2] :=  "C01->( msSeek( xFilial( 'C01' ) + LEQ->LEQ_CODMOD ) )" 
									aMacro[3] :=  "C1L->( msSeek( xFilial( 'C1L' ) + LEQ->LEQ_CODITE ) )" 
	
	
									/*----------------------------------------------------------
									Gravacao do registro E113 no arquivo texto
									----------------------------------------------------------*/											
									LoadString( 'E313' , aCmps , @cStrTxt , 'LEQ' , , aMacro )
									
									aInfoGrv[5]++
									nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
									
									//Conta os registros para totalizar no bloco 9
									TaFContBlc("E313",aTotRegE)								
							
									If nRWStrTxt == -1
										Exit
									EndIf						
			
									LEQ->( dbSkip() )
								End
							EndIf
	
							If nRWStrTxt == -1
								Exit
							EndIf									
							 
							LEG->( DbSkip() )
						EndDo
					EndIf	 
					
					/*----------------------------------------------------------
					Executando laco para gerar o registro E316
					----------------------------------------------------------*/					
					If nRWStrTxt >= 0 .And. LEI->( msSeek( xFilial( 'LEI' ) + LEF->LEF_ID ) )
						While !LEI->( Eof() ) .And. LEI->( LEI_FILIAL + LEI_ID ) == xFilial( 'LEI' ) + LEF->LEF_ID
						
							aMacro	:=	{ "", "", "", "", "" }
							if C0R->( msSeek( xFilial( 'C0R' ) + LEI->LEI_DOCARR ) )
						
								if C1G->( msSeek( xFilial( 'C1G' ) + C0R->C0R_NRPROC ) )
							    	
							    	aMacro[1] :=  C1G->C1G_NUMPRO 
							    	aMacro[2] :=  C1G->C1G_INDPRO 
							    	aMacro[3] :=  C1G->C1G_DESCRI 							
							   
							    elseIf C1G->( msSeek( xFilial( 'C1G' ) + alltrim(LEI->LEI_NRPROC) ) )
							
							    	aMacro[1] :=  C1G->C1G_NUMPRO 
							    	aMacro[2] :=  C1G->C1G_INDPRO 
							    	aMacro[3] :=  C1G->C1G_DESCRI 	
						    	    
							   endif
							
							ElseIf C1G->( msSeek( xFilial( 'C1G' ) + LEI->LEI_NRPROC ) )
							
						    	aMacro[1] :=  C1G->C1G_NUMPRO 
						    	aMacro[2] :=  C1G->C1G_INDPRO 
						    	aMacro[3] :=  C1G->C1G_DESCRI 						
							
							endif
							  
							aMacro[4] :=  "C3E->( msSeek( xFilial( 'C3E' ) + C0R->C0R_CODOBR ) )" 
							aMacro[5] :=  "C6R->( msSeek( xFilial( 'C6R' ) + C0R->C0R_CODREC ) )" 
						
							LoadString( 'E316' , aCmps , @cStrTxt , 'C0R' , , aMacro )
							
							//Conta os registros para totalizar no bloco 9
							TaFContBlc("E316",aTotRegE)
													
							
							aInfoGrv[5]++
							nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
							
							//Conta os registros para totalizar no bloco 9
							TaFContBlc("E316",aTotRegE)								
					
							If nRWStrTxt == -1
								Exit
							EndIf	
							
							LEI->( dbSkip() )
						
						End
					EndIf														
				EndIf						
			EndIf			
		EndIf
	 	
		If nRWStrTxt == -1
			Exit
		EndIf
		
		(cAliasQry)->( dbSkip() )	
	EndDo          
	(cAliasQry)->( DbCloseArea() )             
Endif           

/*--------------------------------------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK  ( Apuracao de IPI )
---------------------------------------------------------------------------------------*/          
C2O->( DbSetOrder( 1 ) )
C2P->( DbSetOrder( 1 ) )
C0Y->( DbSetOrder( 3 ) )
C15->( DbSetOrder( 3 ) )
C1B->( DbSetOrder( 3 ) )

cQuery	:=	"SELECT "     
cQuery	+=		"C2N.R_E_C_N_O_ "
cQuery	+=	"FROM 
cQuery	+=		RetSqlName( 'C2N' ) + " C2N "
cQuery	+=	"WHERE 
cQuery	+=		"C2N.C2N_FILIAL='" + xFilial('C2N') + "' AND "
cQuery	+=		"C2N.C2N_DTINI>='" + DToS( dDataIni ) + "' AND "
cQuery	+=		"C2N.C2N_DTFIM<='" + DToS( dDataFim ) + "' AND "
cQuery	+=		"C2N.D_E_L_E_T_=' ' "
cQuery	+=	"ORDER BY "
cQuery	+=		"C2N_DTINI, "
cQuery	+=		"C2N_DTFIM "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

If !lGerE001
	If !( cAliasQry )->( Eof() )	

	    aMacro	:=	{}
		aAdd( aMacro , "0" )
										
		/*----------------------------------------------------------
		Gravacao do registro E001 no arquivo texto
		----------------------------------------------------------*/	
		LoadString( 'E001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) ) >= 0                
		
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("E001",aTotRegE)
					
			lGerE001 := .T.	
		EndIf
									
	EndIf
EndIf

/*-------------------------------------------------------------------------------------------------------
Laco Principal da Rotina para Realizar a Emissao dos Registros ( Apuracao de IPI )
--------------------------------------------------------------------------------------------------------*/
While !( cAliasQry )->( Eof() )	
    C2N->( DbGoTo( ( cAliasQry )->R_E_C_N_O_ ) )
    
	If lGerE001
		/*----------------------------------------------------------
		Gravacao do registro E500 no arquivo texto
		----------------------------------------------------------*/	
		LoadString( 'E500' , aCmps , @cStrTxt, 'C2N' )
		
		aInfoGrv[5]++
		If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' ) ) >= 0        
		
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("E500",aTotRegE)		
	
			/*----------------------------------------------------------
			Executando laco para gerar o registro E510
			----------------------------------------------------------*/					
			If C2P->( MsSeek( xFilial( 'C2P' ) + C2N->C2N_ID ) )
				While !C2P->( Eof() ) .And. C2P->( C2P_FILIAL + C2P_ID ) == xFilial( 'C2P' ) + C2N->C2N_ID	
	
				    aMacro	:=	{ "", "" }
					aMacro[1] :=  "C0Y->( msSeek( xFilial( 'C0Y' ) + C2P->C2P_CFOP ) )" 
					aMacro[2] :=  "C15->( msSeek( xFilial( 'C15' ) + C2P->C2P_CSTIPI ) )" 
	
					/*----------------------------------------------------------
					Gravacao do registro E510 no arquivo texto
					----------------------------------------------------------*/											
					LoadString( 'E510' , aCmps , @cStrTxt , 'C2P' , , aMacro )

					
					aInfoGrv[5]++
					nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
					
					//Conta os registros para totalizar no bloco 9
					TaFContBlc("E510",aTotRegE)
													
					If nRWStrTxt  == -1									
						Exit
					EndIf		
										             
					C2P->(DbSkip())
				EndDo			
			EndIf         
		
			/*----------------------------------------------------------
			Gravacao do registro E520 no arquivo texto
			----------------------------------------------------------*/	
			LoadString( 'E520' , aCmps , @cStrTxt, 'C2N' )
			
			aInfoGrv[5]++
			If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' ) ) >= 0        		
						
				//Conta os registros para totalizar no bloco 9
				TaFContBlc("E520",aTotRegE)			
			     
				/*----------------------------------------------------------
				Executando laco para gerar o registro E530
				----------------------------------------------------------*/					
				If C2O->( MsSeek( xFilial( 'C2O' ) + C2N->C2N_ID ) )
					While !C2O->( Eof() ) .And. C2O->( C2O_FILIAL + C2O_ID ) == xFilial( 'C2O' ) + C2N->C2N_ID			
	
					    aMacro	:=	{ "" }
						aMacro[1] :=  "C1B->( msSeek( xFilial( 'C1B' ) + C2O->C2O_CODAJU ) )" 						            
						
						/*----------------------------------------------------------
						Gravacao do registro E530 no arquivo texto
						----------------------------------------------------------*/											
						LoadString( 'E530' , aCmps , @cStrTxt , 'C2O' , , aMacro )
						
						aInfoGrv[5]++
						nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
						
						//Conta os registros para totalizar no bloco 9
						TaFContBlc("E530",aTotRegE)
														
						If nRWStrTxt  == -1									
							Exit
						EndIf										
	                    /*----------------------------------------------------------
	                    Executando laco para gerar o registro E531
						----------------------------------------------------------*/	
						If(aWizardBc[1][5] >= "012")
							If T86->( MsSeek( xFilial( 'T86' ) + C2O->( C2O_ID + C2O_CODAJU ) ) )		
									
			                    While !T86->( Eof() ) .And. Alltrim(T86->( T86_FILIAL + T86_ID + T86_CODAJU )) == Alltrim(xFilial( 'T86' ) + C2O->( C2O_ID + C2O_CODAJU ))	
			                    
			                    	aMacro	  :=	{ "", "", "" }
			                    	
			                    	aMacro[1] := POSICIONE("C1H",5,XFILIAL("C1H")+ T86->T86_CODPAR,"C1H_CODPAR","")
			                    	aMacro[2] := POSICIONE("C01",3,XFILIAL("C01")+ T86->T86_CODMOD,"C01_CODIGO","")
			                    	aMacro[3] := POSICIONE("C1L",3,XFILIAL("C1L")+ T86->T86_CODITE,"C1L_CODIGO","") 
			                    	
			                    	/*----------------------------------------------------------
			                    	Gravacao do registro E531 no arquivo texto
			                    	----------------------------------------------------------*/			
			                    	LoadString( 'E531' , aCmps , @cStrTxt , 'T86' , , aMacro )		
			                    			
			                    	aInfoGrv[5]++
			                    	nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'E100' )
							
			                    	//Conta os registros para totalizar no bloco 9
			                    	TaFContBlc("E531",aTotRegE)
															
									If nRWStrTxt  == -1									
										Exit
									EndIf		
												             
									T86->(DbSkip())		
		                    			
								 Enddo
		                    Endif		                    					
	                    Endif
	                    C2O->( DbSkip() )
					EndDo          
				EndIf
			EndIf		
		EndIf   
	EndIf	    
    ( cAliasQry )->( DbSkip() )
EndDo                                         
( cAliasQry )->(DbCloseArea())               
    	
Return ( Nil )                        

//-------------------------------------------------------------------
/*/{Protheus.doc} DistrCmps

Funcao responsavel por definir um depara do layout do fisco para a tabela do TAF,
os campos armazenados no array serao utilizados na gravacao como macro execucao

@return aRet - Array com os campos por registros

@author Rodrigo Aguilar
@since 14/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DistrCmps(dDataIni)

Local	aRet	:=	{}
Local	nI		:=	1
Default dDataIni := Ctod("  /  /    ")

//ESTRUTURA DO REGISTRO E001
nI	:=	1
aAdd( aRet , { 'E001' , Array( 01 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }

//ESTRUTURA DO REGISTRO E100
nI	:=	1
aAdd( aRet , { 'E100' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C2S_DTINI ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C2S_DTFIN ) }

//ESTRUTURA DO REGISTRO E110
nI	:=	1
aAdd( aRet , { 'E110' , Array( 14 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_TOTDEB , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_AJUDEB , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_TAJUDB , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_ESTCRE , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_TOTCRE , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_AJUCRE , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_TAJUCR , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_ESTDEB , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_CREANT , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_SDOAPU , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_TOTDED , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_TOTREC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_CRESEG , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_DEBESP , 16 , 2 ) }

//ESTRUTURA DO REGISTRO E111
nI	:=	1
aAdd( aRet , { 'E111' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( lSeek , C1A->C1A_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2T_AJUCOM }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2T_VLRAJU , 16 , 2 ) }

//ESTRUTURA DO REGISTRO E112
nI	:=	1
aAdd( aRet , { 'E112' , Array( 05 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C0R->C0R_NUMDA }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| StrTran(C0R->C0R_DESDOC, CRLF, " ") }

//ESTRUTURA DO REGISTRO E113
nI	:=	1
aAdd( aRet , { 'E113' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , xGerBlc0( "0150",  C1H->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 2 ] ) , C01->C01_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2V_SERDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2V_SUBSER }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2V_NRODOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C2V_DTDOC ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 3 ] ) , xGerBlc0( "0200",  Alltrim( C1L->( C1L_CODIGO ) ), cFilSelBc, aWizardBc, cTabSpd ), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2V_VLRAJU , 16 , 2 ) }

If TAFColumnPos("C2V_CHVELE")
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2V_CHVELE }
EndIf
//ESTRUTURA DO REGISTRO E115
nI	:=	1
aAdd( aRet , { 'E115' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , T58->T58_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2X_VLRINF , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2X_DSCCOM }

//ESTRUTURA DO REGISTRO E116
nI	:=	1
aAdd( aRet , { 'E116' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 4 ] ) , C3E->C3E_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C0R->C0R_VLDA , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C0R->C0R_DTVCT ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 5 ] ) , C6R->C6R_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| StrTran(C0R->C0R_DESDOC, CRLF, " ") }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C0R->C0R_PERIOD }

//ESTRUTURA DO REGISTRO E200
nI	:=	1
aAdd( aRet , { 'E200' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , C09->C09_UF , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C3J_DTINI ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C3J_DTFIN ) }

//ESTRUTURA DO REGISTRO E210
nI	:=	1
aAdd( aRet , { 'E210' , Array( 14 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C3J_INDMOV }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3J_CREANT , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3J_VLRDEV , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3J_VLRRES , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3J_OUTCRD , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3J_AJUCRD , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3J_VLRRET , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3J_OUTDEB , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3J_AJUDEB , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3J_SDODEV , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3J_TOTDED , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3J_VLRREC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3J_CRDTRA , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3J_DEBESP , 16 , 2 ) }

//ESTRUTURA DO REGISTRO E220
nI	:=	1
aAdd( aRet , { 'E220' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( lSeek , C1A->C1A_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C3K_AJUCOM }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3K_VLRAJU , 16 , 2 ) }

//ESTRUTURA DO REGISTRO E230
nI	:=	1
aAdd( aRet , { 'E230' , Array( 05 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C0R->C0R_NUMDA }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| StrTran(C0R->C0R_DESDOC, CRLF, " ") }

//ESTRUTURA DO REGISTRO E240
nI	:=	1
aAdd( aRet , { 'E240' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , xGerBlc0( "0150",  C1H->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 2 ] ) , C01->C01_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C3M_SERDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C3M_SUBSER }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C3M_NRODOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C3M_DTDOC ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 3 ] ) , xGerBlc0( "0200",  Alltrim( C1L->( C1L_CODIGO ) ), cFilSelBc, aWizardBc, cTabSpd ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C3M_VLRAJU , 16 , 2 ) }
If TAFColumnPos( "C3M_CHVELE" )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C3M_CHVELE }
EndIf

//ESTRUTURA DO REGISTRO E250
nI	:=	1
aAdd( aRet , { 'E250' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 4 ] ) , C3E->C3E_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C0R_VLDA , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C0R_DTVCT ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 5 ] ) , C6R->C6R_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| StrTran(C0R_DESDOC, CRLF, " ") }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C0R_PERIOD }

//ESTRUTURA DO REGISTRO E300
nI	:=	1
aAdd( aRet , { 'E300' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , C09->C09_UF , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( LEF_DTINI ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( LEF_DTFIN ) }

//ESTRUTURA DO REGISTRO E310
nI	:=	1
If Dtos(dDataIni) >= "20170101" 
	aAdd( aRet , { 'E310' , Array( 21 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| IIF(LEF_TOTDEB > 0 .Or. LEF_TODEBF > 0 .Or. LEF_TOTCDI > 0 .Or. LEF_TOTCDF > 0,'1','0')    }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_SLDCRD , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_TOTDEB , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_OUTDEB + LEF_ESTCDI , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_TOTCDI , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_OUTCDI + LEF_ESTDDI , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_SLDDIF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_DEDDIF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_VLREC  , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_SLDSEG , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_DEBESD , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_SLDCRF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_TODEBF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_OUTDFC + LEF_ESTCFC , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_TOTCDF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_OUTCFC + LEF_ESTDFC , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_SLDDAF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_DEDFCP , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_VLRECF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_SLDCTF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_DEBESF , 16 , 2 ) }
Else
	aAdd( aRet , { 'E310' , Array( 13 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| IIF(LEF_TOTDEB > 0 .Or. LEF_TODEBF > 0 .Or. LEF_TOTCDI > 0 .Or. LEF_TOTCDF > 0,'1','0')    }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_SLDCRD + LEF_SLDCRF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_TOTDEB , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_OUTDEB + LEF_ESTCDI , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_TODEBF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_TOTCDI , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_TOTCDF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_OUTCDI + LEF_ESTDDI , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_SLDDIF + LEF_SLDDAF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_DEDDIF + LEF_DEDFCP , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_VLREC  + LEF_VLRECF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_SLDSEG + LEF_SLDCTF , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEF_DEBESD + LEF_DEBESF , 16 , 2 ) }
Endif

//ESTRUTURA DO REGISTRO E311
nI	:=	1
aAdd( aRet , { 'E311' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( lSeek , C1A->C1A_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEG_DCOMPL }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEG_VLRAJU , 16 , 2 ) }

//ESTRUTURA DO REGISTRO E312
nI	:=	1
aAdd( aRet , { 'E312' , Array( 05 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C0R->C0R_NUMDA }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| StrTran(C0R->C0R_DESDOC, CRLF, " ") }

//ESTRUTURA DO REGISTRO E313
nI	:=	1
aAdd( aRet , { 'E313' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , xGerBlc0( "0150",  C1H->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 2 ] ) , C01->C01_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEQ_SERDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEQ_SUBSER }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEQ_NRODOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEQ_CHVELE }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( LEQ_DTDOC ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 3 ] ) , xGerBlc0( "0200",  Alltrim( C1L->( C1L_CODIGO ) ), cFilSelBc, aWizardBc, cTabSpd ), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( LEQ_VLRAJU , 16 , 2 ) }

//ESTRUTURA DO REGISTRO E316
nI	:=	1
aAdd( aRet , { 'E316' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 4 ] ) , C3E->C3E_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C0R->C0R_VLDA , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C0R->C0R_DTVCT ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 5 ] ) , C6R->C6R_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| StrTran(C0R->C0R_DESDOC, CRLF, " ") }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C0R->C0R_PERIOD }

//ESTRUTURA DO REGISTRO E500
nI	:=	1
aAdd( aRet , { 'E500' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2N_INDAPU }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C2N_DTINI ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C2N_DTFIM ) }

//ESTRUTURA DO REGISTRO E510
nI	:=	1
aAdd( aRet , { 'E510' , Array( 05 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , C0Y->C0Y_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 2 ] ) , C15->C15_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2P_VLCONT , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2P_VLBC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2P_VLIPI , 16 , 2 ) }

//ESTRUTURA DO REGISTRO E520
nI	:=	1
aAdd( aRet , { 'E520' , Array( 07 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2N_VSDANT , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2N_VDEB , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2N_VCRED , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2N_VODEB , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2N_VOCRED , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2N_VSCRED , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2N_VSDEV , 16 , 2 ) }

//ESTRUTURA DO REGISTRO E530
nI	:=	1
aAdd( aRet , { 'E530' , Array( 06 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2O_INDAJU }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2O_VLAJU , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , C1B->C1B_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2O_INDDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2O_NUMDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2O_DESCRI }

//ESTRUTURA DO REGISTRO E531
nI	:=	1
aAdd( aRet , { 'E531' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , xGerBlc0( "0150",  C1H->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[2]  }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T86_SERDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T86_SUBSER }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T86_NUMDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( T86_DTDOC ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 3 ] ) , xGerBlc0( "0200",  Alltrim( C1L->( C1L_CODIGO ) ), cFilSelBc, aWizardBc, cTabSpd ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( T86_VLRAJU , 16 , 2 ) } 
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T86_CHVELE }
//ESTRUTURA DO REGISTRO E990
nI	:=	1
aAdd( aRet , { 'E990' , Array( 1 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( aMacro[ 1 ], 16, 0 ) }

Return ( aRet )
