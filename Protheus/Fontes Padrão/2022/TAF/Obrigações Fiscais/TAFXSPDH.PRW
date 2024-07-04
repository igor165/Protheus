#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TafxSpdH

Realiza a Geracao do Bloco H do Sped Fiscal

@param	aWizard	->	Wizard de geracao do Arquivo
		cFilSel	->	Variavel com as Filiais escolhidas pelo Usuario
		
@return NIL

@author Rodrigo Aguilar
@since 14/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafxSpdH( aWizard, cFilSel, lConv115, cPerfilSPD, cTabSped , cJobAux ) 

Local  cTxtSys	:= 	CriaTrab(,.F.)+".TXT"
Local	cFilBkp	:=	cFilAnt	//Bakup da filial antes do inicio do processamento
Local	nI			:=	0       
Local  nlI        := 0
Local  nTotReg    := 1
Local	lSave		 :=	.F.
Local	aCmps		 :=	DistrCmps( aWizard[5][1] )                    
Local  aFilSel     := Separa( StrTran( cFilSel, "'", "" ), "," )

Local	cStrTxt	:=	''
Local 	aMacro     := {}

Local dDataIni    := aWizard[5][1]
Local dDataFim    := aWizard[5][2]  
Local lGerH001    :=  .F.             

Local lFound := .T.
Local oError := ErrorBlock( { |Obj| Conout( "Mensagem de Erro: " + Chr(10)+ Obj:Description + Chr(10)+ Obj:ErrorStack ) } )

Private aTotRegH  := {}
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
	aInfoGrv := { cFilAnt , DToS( aWizardBc[1,1] ), DToS( aWizardBc[1,2] ), "H", 0 }
	
	BlocoH( dDataIni , dDataFim , aCmps, @lGerH001 )        
	
	/*----------------------------------------------------------------------
	Caso nao tenha sido gerado o registro H001 ( Pois nao Houve Movimento )
	realizao a sua emissao agora
	-----------------------------------------------------------------------*/	
	If !lGerH001	
		
		aMacro	:=	{}
		aAdd( aMacro , "1" )
		
		cStrTxt := ""
		LoadString( 'H001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		//Conta os registros para totalizar no bloco 9
		TaFContBlc("H001",aTotRegH)
			               
	EndIf       
	
	For nlI := 1 To Len( aTotRegH )
		nTotReg += aTotRegH[nlI][2]
	Next           
	
	aMacro	:=	{}
	aAdd( aMacro , nTotReg )
	
	Reg990Spd( "H", cTabSped, cFilSel, aWizard )
		
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
	xTafCtlObr( "2", "H", aWizardBc, cFilSelBc, , "TAFGERCTL", "SPEDFIS" )	
EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoH

Monta a Estrutura de Geracao dos Registros referentes ao BLOCO H

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		lGerH001    ->  Informa se ja foi gerado o Registro H001 
		
@return NIL

@author Rodrigo Aguilar
@since 14/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlocoH( dDataIni , dDataFim ,  aCmps, lGerH001 )

Local 	cAliasQry 	:=  GetNextAlias()
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0
Local	cQuery		:=	''
Local	aMacro		:=	{} 

/*-----------------------------------------------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK  ( Inventario )
------------------------------------------------------------------------------------------------*/
C5B->( dbSetOrder( 1 ) )
C5C->( dbSetOrder( 1 ) )
C5D->( dbSetOrder( 3 ) ) 
C1L->( dbSetOrder( 3 ) )     
C1J->( dbSetOrder( 3 ) )      
C1O->( dbSetOrder( 3 ) )    
C14->( dbSetOrder( 3 ) ) 
C1H->( dbSetOrder( 5 ) )

cQuery	:=	"SELECT "              
cQuery	+=		"C5A.R_E_C_N_O_ "	
cQuery	+=	"FROM 
cQuery	+=		RetSqlName( 'C5A' ) + " C5A "
cQuery	+=	"WHERE 
cQuery	+=		"C5A.C5A_FILIAL='" + xFilial('C5A') + "' AND "
cQuery	+=		"C5A.C5A_DTINV>='" + DToS( dDataIni ) + "' AND "
cQuery	+=		"C5A.C5A_DTINV<='" + DToS( dDataFim ) + "' AND "
cQuery	+=		"C5A.D_E_L_E_T_=' ' "
cQuery	+=	"ORDER BY "
cQuery	+=		"C5A.C5A_DTINV "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

If !lGerH001
	If !( cAliasQry )->( Eof() )	
		
	    aMacro	:=	{}
		aAdd( aMacro , "0" )
										
		LoadString( 'H001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) ) >= 0                
		
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("H001",aTotRegH)
			
			lGerH001 := .T.
		EndIf
			
	EndIf
EndIf

/*-------------------------------------------------------------------------------------------------------
Laco Principal da Rotina para Realizar a Emissao dos Registros ( Inventario )
--------------------------------------------------------------------------------------------------------*/
While !( cAliasQry )->( Eof() )	
	C5A->( DbGoTo( ( cAliasQry )->R_E_C_N_O_ ) )

	If lGerH001

		aMacro	:=	{}
		
		/*-----------------------------------------------------------------------------------		
		O quarto campo do registro H005 somente deve ser gerado a partir de 01/07/2012 de
		acordo com o Layout do Sped.
		-----------------------------------------------------------------------------------*/
		If DToS( dDataIni ) >= "20120701"	  
			aAdd( aMacro , "C5D->( msSeek( xFilial( 'C5D' ) + C5A->C5A_MOTINV ) )" )
		EndIf
								
		/*----------------------------------------------------------
		Gravacao do registro H005 no arquivo texto
		----------------------------------------------------------*/	
		LoadString( 'H005' , aCmps , @cStrTxt, 'C5A', , aMacro )
		
		aInfoGrv[5]++
		If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'H005' + AllTrim(C5A->C5A_ID) ) ) >= 0     	        
		
			//Conta os registros para totalizar no bloco 9
			TaFContBlc("H005",aTotRegH)		
			             
			/*----------------------------------------------------------
			Executando laco para gerar o registro H010
			----------------------------------------------------------*/					
			If C5B->( msSeek( xFilial( 'C5B' ) + C5A->C5A_ID ) )
				While !C5B->( Eof() ) .And. C5B->( C5B_FILIAL + C5B_ID ) == xFilial( 'C5B' ) + C5A->C5A_ID
				
					/*-----------------------------------------------------------------------------------
					Provisorio: 
					necessario para quando o indice eh alterado nas funcoes do bloco 0 -> xGerBlc0
					-----------------------------------------------------------------------------------*/
					C1L->( dbSetOrder( 3 ) )     
					C1J->( dbSetOrder( 3 ) )      
					C1O->( dbSetOrder( 3 ) )    
					C14->( dbSetOrder( 3 ) ) 
					C1H->( dbSetOrder( 5 ) )
					
					aMacro	:=	{}
					aAdd( aMacro , "C1L->( msSeek( xFilial( 'C1L' ) + C5B->C5B_CODITE ) )" )
					aAdd( aMacro , "C1J->( msSeek( xFilial( 'C1J' ) + C5B->C5B_UNID ) )"   )
					aAdd( aMacro , "C1H->( msSeek( xFilial( 'C1H' ) + C5B->C5B_CODPAR ) )" )
					aAdd( aMacro , "C1O->( msSeek( xFilial( 'C1O' ) + C5B->C5B_CODCTA ) )" )
																	
					/*----------------------------------------------------------
					Gravacao do registro H010 no arquivo texto
					----------------------------------------------------------*/
					LoadString( 'H010' , aCmps , @cStrTxt , 'C5B' , , aMacro )
					
					aInfoGrv[5]++
					nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ,'H005' + AllTrim(C5A->C5A_ID) + AllTrim(C1L->C1L_CODIGO) + 'H010')	
					
					/*---------------------------------------------------------
					Conta os registros para totalizar no bloco 9
					---------------------------------------------------------*/
					TaFContBlc("H010",aTotRegH)					

					/*---------------------------------------------------------
					O quarto campo do registro H005 somente deve ser gerado 
					a partir de 01/07/2012 e apenas para os codigos
					de inventario 02,03,04,05 quando o valor for maior do que 
					0 de acordo com o Layout do Sped.
					---------------------------------------------------------*/
					If DToS( dDataIni ) >= "20120701" .And. C5D->( MsSeek( xFilial( 'C5D' ) + C5A->C5A_MOTINV ) ) .And. C5D->C5D_CODIGO $ ( "|02|03|04|05|" ) .And. C5A->C5A_VINV > 0   							                         										
						
						/*----------------------------------------------------------
						Executando laco para gerar o registro H020
						----------------------------------------------------------*/
						If nRWStrTxt >= 0 .And. C5C->( msSeek( xFilial( 'C5C' ) + C5B->( C5B_ID + C5B_CODITE + C5B_UNID + C5B_INDPRO + C5B_CODPAR ) ) )
							While !C5C->( Eof() ) .And. C5C->( C5C_FILIAL + C5C_ID + C5C_CODITE + C5C_UNID + C5C_INDPRO + C5C_CODPAR ) == ;
							                              xFilial( 'C5C' ) + C5B->( C5B_ID + C5B_CODITE + C5B_UNID + C5B_INDPRO + C5B_CODPAR )
							    
							    aMacro	:=	{}
								aAdd( aMacro , "C03->( msSeek( xFilial( 'C03' ) + C5C->C5C_ORIGEM ) ) .And. C14->( msSeek( xFilial( 'C14' ) + C5C->C5C_CSTICM ) ) " )
						
								/*----------------------------------------------------------
								Gravacao do registro H020 no arquivo texto
								----------------------------------------------------------*/								
								LoadString( 'H020' , aCmps , @cStrTxt , 'C5C', , aMacro )
								
								aInfoGrv[5]++
								nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ,'H005' + AllTrim(C5A->C5A_ID) + AllTrim(C1L->C1L_CODIGO) + 'H020')
								
								/*----------------------------------------------------------
								Conta os registros para totalizar no bloco 9
								----------------------------------------------------------*/
								TaFContBlc("H020",aTotRegH)							
						
								If nRWStrTxt == -1
									Exit
								EndIf						
		
								C5C->( dbSkip() )
							EndDo												
						EndIf    
					EndIf								
					C5B->( dbSkip() )
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
Static Function DistrCmps( dDataIni )

Local	aRet	:=	{}
Local	nI		:=	1


//ESTRUTURA DO REGISTRO H001
nI	:=	1
aAdd( aRet , { 'H001' , Array( 01 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }

//ESTRUTURA DO REGISTRO H005
nI	:=	1

//Tratamento para que o 4 campo do registro H005 seja gerado apenas
//a partir de 01/07/2012 ( De acordo com o Layout do Sped Fiscal )
If DToS( dDataIni ) >= "20120701"
	aAdd( aRet , { 'H005' , Array( 03 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C5A_DTINV ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5A_VINV , 16 , 2 ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , C5D->C5D_CODIGO , '' ) }
Else
	aAdd( aRet , { 'H005' , Array( 02 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C5A_DTINV ) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5A_VINV , 16 , 2 ) }
EndIf

//ESTRUTURA DO REGISTRO H010
nI	:=	1
aAdd( aRet , { 'H010' , Array( 10 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , xGerBlc0( "0200",  Alltrim( C1L->( C1L_CODIGO ) ), cFilSelBc, aWizardBc, cTabSpd ), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 2 ] ) , xGerBlc0( "0190", Alltrim( Right( Alltrim( C1J->( C1J_CODIGO) ), 6 )), cFilSelBc, aWizardBc, cTabSpd ), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5B_QTD , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5B_VUNIT , 16 , 6 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5B_VITEM , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C5B_INDPRO  }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 3 ] ) , xGerBlc0( "0150",  C1H->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd ), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C5B_TXTCOM  }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 4 ] ) , xGerBlc0( "0500",  Alltrim( C1O->( C1O_CODIGO ) ), cFilSelBc, aWizardBc, cTabSpd), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5B_VITEIR , 16 , 2 ) }

//ESTRUTURA DO REGISTRO H020
nI	:=	1
aAdd( aRet , { 'H020' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] )  , Alltrim( C03->C03_CODIGO ) + Alltrim( C14->C14_CODIGO ), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5C_BCICMS , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5C_VICMS , 16 , 2 ) }

//ESTRUTURA DO REGISTRO H990
nI	:=	1
aAdd( aRet , { 'H990' , Array( 1 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( aMacro[ 1 ], 16, 0 ) }

Return ( aRet )
