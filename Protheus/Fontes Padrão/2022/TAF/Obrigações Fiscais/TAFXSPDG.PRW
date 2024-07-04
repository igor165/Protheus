#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TafxSpdG

Realiza a Geracao do Bloco G do Sped Fiscal

@param	aWizard		->	Wizard de geracao do Arquivo
		cTxtUsu     ->  Caminho / Nome do Arquivo para Geracao
		cFilSel		->	Variavel com as Filiais escolhidas pelo Usuario
		
@return aTotRegG

@author Rodrigo Aguilar
@since 14/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafxSpdG( aWizard, cFilSel, lConv115, cPerfilSPD, cTabSped, cJobAux ) 

Local  cTxtSys	:= 	CriaTrab(,.F.)+".TXT"
Local	cFilBkp	:=	cFilAnt	//Bakup da filial antes do inicio do processamento
Local	nI			:=	0    
Local  nlI       := 0 
Local  nTotReg   := 1
Local	lSave		:=	.F.
Local	aCmps		:=	DistrCmps()                    
Local  aFilSel    := Separa( StrTran( cFilSel, "'", "" ), "," )

Local	cStrTxt	  :=	''
Local 	aMacro      := {}

Local  dDataIni    := aWizard[1][1]
Local  dDataFim    := aWizard[1][2]  
Local  lGerG001    :=  .F.

Local lFound := .T.
Local oError := ErrorBlock( { |Obj| Conout( "Mensagem de Erro: " + Chr(10)+ Obj:Description + Chr(10)+ Obj:ErrorStack ) } )                            

Private aTotRegG  := {}
Private aInfoGrv  := {}

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
	aInfoGrv := { cFilAnt , DToS( aWizardBc[1,1] ), DToS( aWizardBc[1,2] ), "G", 0 }
		
	BlocoG( dDataIni , dDataFim , aCmps, @lGerG001 )        
	
	/*----------------------------------------------------------------------
	Caso nao tenha sido gerado o registro G001 ( Pois nao Houve Movimento )
	realizao a sua emissao agora
	-----------------------------------------------------------------------*/	
	If !lGerG001	
		aMacro	:=	{}
		aAdd( aMacro , "1" )
		
		cStrTxt := ""
		LoadString( 'G001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )                
		
		//Conta os registros para totalizar no bloco 9
		TaFContBlc("G001",aTotRegG)			
	
	EndIf     
	
	For nlI := 1 To Len( aTotRegG )
		nTotReg += aTotRegG[nlI][2]
	Next           
	
	aMacro	:=	{}
	aAdd( aMacro , nTotReg )
	
	Reg990Spd( "G", cTabSped, cFilSel, aWizard ) 
	
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
	xTafCtlObr( "2", "G", aWizardBc, cFilSelBc, , "TAFGERCTL", "SPEDFIS" )	
EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoG

Monta a Estrutura de Geracao dos Registros referentes ao BLOCO G

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		lGerG001    ->  Informa se ja foi gerado o Registro G001 
		
@return NIL

@author Rodrigo Aguilar
@since 14/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlocoG( dDataIni , dDataFim , aCmps, lGerG001 )

Local 	cAliasQry 	:=  GetNextAlias()
Local	cStrTxt	:=	''
Local	nRWStrTxt	:=	0
Local	cQuery		:=	''
Local	aMacro		:=	{}

/*-----------------------------------------------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK  ( CIAP )
------------------------------------------------------------------------------------------------*/
C4S->( dbSetOrder( 1 ) )
C4T->( dbSetOrder( 1 ) )
C4U->( dbSetOrder( 1 ) )
C2L->( dbSetOrder( 3 ) )
C52->( dbSetOrder( 3 ) )
C01->( dbSetOrder( 3 ) )           
C1L->( dbSetOrder( 3 ) )     
C1H->( dbSetOrder( 5 ) )           

cQuery	:=	"SELECT "              
cQuery	+=		"C4R.R_E_C_N_O_ "	
cQuery	+=	"FROM 
cQuery	+=		RetSqlName( 'C4R' ) + " C4R "
cQuery	+=	"WHERE 
cQuery	+=		"C4R.C4R_FILIAL='" + xFilial('C4R') + "' AND "
cQuery	+=		"C4R.C4R_DTINI>='" + DToS( dDataIni ) + "' AND "
cQuery	+=		"C4R.C4R_DTFIN<='" + DToS( dDataFim ) + "' AND "
cQuery	+=		"C4R.D_E_L_E_T_=' ' "
cQuery	+=	"ORDER BY "
cQuery	+=		"C4R_DTINI, "
cQuery	+=		"C4R_DTFIN "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

If !lGerG001
	If !( cAliasQry )->( Eof() )	
		
	    aMacro	:=	{}
		aAdd( aMacro , "0" )
										
		LoadString( 'G001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) ) >= 0                
		
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("G001",aTotRegG)	
			
			lGerG001 := .T.
		EndIf
			
	EndIf
EndIf

/*-------------------------------------------------------------------------------------------------------
Laco Principal da Rotina para Realizar a Emissao dos Registros ( CIAP )
--------------------------------------------------------------------------------------------------------*/
While !( cAliasQry )->( Eof() )	

	C4R->( DbGoTo( ( cAliasQry )->R_E_C_N_O_ ) )

	If lGerG001
			
		/*----------------------------------------------------------
		Gravacao do registro G110 no arquivo texto
		----------------------------------------------------------*/	
		LoadString( 'G110' , aCmps , @cStrTxt, 'C4R' )
		
		aInfoGrv[5]++
		If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv,'G110'	 ) ) >= 0        	        
		
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("G110",aTotRegG)			
			             
			/*----------------------------------------------------------
			Executando laco para gerar o registro G125
			----------------------------------------------------------*/					
			If C4S->( msSeek( xFilial( 'C4S' ) + C4R->C4R_ID ) )
				While !C4S->( Eof() ) .And. C4S->( C4S_FILIAL + C4S_ID ) == xFilial( 'C4S' ) + C4R->C4R_ID
				
				    aMacro	:=	{}
					aAdd( aMacro , "C2L->( msSeek( xFilial( 'C2L' ) + C4S->C4S_INDBEM ) )" )
					aAdd( aMacro , "C52->( msSeek( xFilial( 'C52' ) + C4S->C4S_TPMOV ) )" )
												
					/*----------------------------------------------------------
					Gravacao do registro G125 no arquivo texto
					----------------------------------------------------------*/
					LoadString( 'G125' , aCmps , @cStrTxt , 'C4S' , , aMacro )
					
					aInfoGrv[5]++
					nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv,'G110' )
					
					//Conta os registros para totalizar no bloco 9
					TaFContBlc("G125",aTotRegG)						
					                         										
					/*----------------------------------------------------------
					Executando laco para gerar o registro G126
					----------------------------------------------------------*/
					If nRWStrTxt >= 0 .And. C4T->( msSeek( xFilial( 'C4T' ) + C4S->( C4S_ID + C4S_INDBEM + DToS( C4S_DTMOV ) + C4S_TPMOV ) ) )
						While !C4T->( Eof() ) .And. C4T->( C4T_FILIAL + C4T_ID + C4T_INDBEM + DToS( C4T_DTMOV ) + C4T_TPMOV ) == ;
						                              xFilial( 'C4T' ) + C4S->( C4S_ID + C4S_INDBEM + DToS( C4S_DTMOV ) + C4S_TPMOV )
						    							
							/*----------------------------------------------------------
							Gravacao do registro G126 no arquivo texto
							----------------------------------------------------------*/								
							LoadString( 'G126' , aCmps , @cStrTxt , 'C4T' )
							
							aInfoGrv[5]++
							nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv,'G110' )
							
							//Conta os registros para totalizar no bloco 9
							TaFContBlc("G126",aTotRegG)								
					
							If nRWStrTxt == -1
								Exit
							EndIf						
	
							C4T->( dbSkip() )
						EndDo												
					EndIf    

					/*----------------------------------------------------------
					Executando laco para gerar o registro G130
					----------------------------------------------------------*/										
					If nRWStrTxt >= 0 .And. C4U->( msSeek( xFilial( 'C4U' ) + C4S->( C4S_ID + C4S_INDBEM + DToS( C4S_DTMOV ) + C4S_TPMOV ) ) )
						While !C4U->( Eof() ) .And. C4U->( C4U_FILIAL + C4U_ID + C4U_INDBEM + DToS( C4U_DTMOV ) + C4U_TPMOV ) == ;
													 xFilial( 'C4U' ) + C4S->( C4S_ID + C4S_INDBEM + DToS( C4S_DTMOV ) + C4S_TPMOV )
						    							    
						    aMacro	:=	{}
							aAdd( aMacro , "C1H->( msSeek( xFilial( 'C1H' ) + C4U->C4U_CODPAR ) )" )															
							aAdd( aMacro , "C01->( msSeek( xFilial( 'C01' ) + C4U->C4U_CODMOD ) )" )
							
							/*----------------------------------------------------------
							Gravacao do registro G130 no arquivo texto
							----------------------------------------------------------*/								
							LoadString( 'G130' , aCmps , @cStrTxt , 'C4U', , aMacro )
							
							aInfoGrv[5]++
							nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv,'G110' )
							
							//Conta os registros para totalizar no bloco 9
							TaFContBlc("G130",aTotRegG)									
	
							/*----------------------------------------------------------
							Executando laco para gerar o registro G140
							----------------------------------------------------------*/  																								
							If nRWStrTxt >= 0 .And. C4V->( msSeek( xFilial( 'C4V' ) + C4U->( C4U_ID + C4U_INDBEM + DToS( C4U_DTMOV ) + C4U_TPMOV + C4U_INDEMT + C4U_CODPAR + C4U_CODMOD + C4U_SERIE + C4U_NUMDOC + DTOS(C4U_DTEMIS) ) ) )				
								While !C4V->( Eof() ) .And. C4V->( C4V_FILIAL + C4V_ID + C4V_INDBEM + DToS( C4V_DTMOV ) + C4V_TPMOV + C4V_INDEMT + C4V_CODPAR + C4V_CODMOD + C4V_SERIE + C4V_NUMDOC + DTOS( C4V_DTEMIS ) )  == ;
															 xFilial( 'C4V' ) + C4U->( C4U_ID + C4U_INDBEM + DToS( C4U_DTMOV ) + C4U_TPMOV + C4U_INDEMT + C4U_CODPAR + C4U_CODMOD + C4U_SERIE + C4U_NUMDOC + DTOS( C4U_DTEMIS ) )
															 
								    aMacro	:=	{}
									aAdd( aMacro , "C1L->( msSeek( xFilial( 'C1L' ) + C4V->C4V_CODITE ) )" )																						

									/*----------------------------------------------------------
									Gravacao do registro G140 no arquivo texto
									----------------------------------------------------------*/								
									LoadString( 'G140' , aCmps , @cStrTxt , 'C4V', , aMacro )
									
									aInfoGrv[5]++
									nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv,'G110' )
									
									//Conta os registros para totalizar no bloco 9
									TaFContBlc("G140",aTotRegG)										
							                                								
									If nRWStrTxt == -1
										Exit
									EndIf
									
									C4V->(DbSkip())
								EndDo	  
							EndIf					
								
							C4U->( dbSkip() )
						EndDo												
					EndIf    															
					C4S->( dbSkip() )
				EndDo
			EndIf						
		EndIf    
	EndIf           	
	( cAliasQry )->(DbSkip())
EndDo
(cAliasQry)->( DbCloseArea() )
    	
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
Static Function DistrCmps

Local	aRet	:=	{}
Local	nI		:=	1

//ESTRUTURA DO REGISTRO G001
nI	:=	1
aAdd( aRet , { 'G001' , Array( 01 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }

//ESTRUTURA DO REGISTRO G110
nI	:=	1
aAdd( aRet , { 'G110' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C4R_DTINI ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C4R_DTFIN ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4R_SLDINI , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4R_SOMPAR , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4R_VLTREX , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4R_VLTOTS , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4R_INDPVL , 16 , 8 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4R_VLICAP , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4R_VLOCRD , 16 , 2 ) }

//ESTRUTURA DO REGISTRO G125
nI	:=	1
aAdd( aRet , { 'G125' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , xGerBlc0( "0300",  Alltrim( C2L->( C2L_CODBEM ) ), cFilSelBc, aWizardBc, cTabSpd ), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C4S_DTMOV ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 2 ] ) , C52->C52_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4S_VLICPR , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4S_VLICST , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4S_VLICFR , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4S_VLICDA , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( Val(C4S_NUMPAR) = 0, '', C4S_NUMPAR ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4S_VLPRPS , 16 , 2 ) }

//ESTRUTURA DO REGISTRO G126
nI	:=	1
aAdd( aRet , { 'G126' , Array( 08 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C4T_DINIPR ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C4T_DFINPR ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4T_NUMPAR }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4T_VLPRIC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4T_VLSTRB , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4T_VLTOT , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4T_IDPTVL , 16 , 8 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4T_VLOTCR , 16 , 2 ) }

//ESTRUTURA DO REGISTRO G130
nI	:=	1
aAdd( aRet , { 'G130' , Array( 07 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4U_INDEMT }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , xGerBlc0( "0150",  C1H->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 2 ] ) , C01->C01_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4U_SERIE  }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4U_NUMDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4U_CHVNFE }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C4U_DTEMIS ) }

//ESTRUTURA DO REGISTRO G140
nI	:=	1
aAdd( aRet , { 'G140' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4V_NUMITE }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , xGerBlc0( "0200",  Alltrim( C1L->( C1L_CODIGO ) ), cFilSelBc, aWizardBc, cTabSpd ), '' ) }

//ESTRUTURA DO REGISTRO G990
nI	:=	1
aAdd( aRet , { 'G990' , Array( 1 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( aMacro[ 1 ], 16, 0 ) }

Return ( aRet )
