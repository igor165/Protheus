#Include 'Protheus.ch'

Function TAFXSPD1( aWizard, cFilSel, lConv115, cPerfilSPD, cTabSped, cJobAux )

Local cTxtSys	:= 	CriaTrab(,.F.)+".TXT"
Local cFilBkp	:=	cFilAnt	//Bakup da filial antes do inicio do processamento
Local nI		:=	0     
Local nlI     :=  0
Local lSave	:=	.F.
Local aCmps	:=	DistrCmps()   
Local nTotReg := 1     

Local cStrTxt  := ""        

Local dDataIni := aWizard[1][1]
Local dDataFim := aWizard[1][2]  

Local aMacro   := {}

Local aFilSel := Separa( StrTran( cFilSel, "'", "" ), "," )
Local lFound  := .T.
Local oError  := ErrorBlock( { |Obj| Conout( "Mensagem de Erro: " + Chr(10)+ Obj:Description + Chr(10)+ Obj:ErrorStack ) } )

Private aTotReg1  := {}  
Private lGer1001  :=  .F. 
Private aInfoGrv := {}     

//Deve ser private para geracao dos registros do bloco 0 gerados durante
//o processamento dos movimentos
Private aWizardBc  := aWizard
Private cFilSelBc  := cFilSel
Private cTabSpd    := cTabSped                

Default dDataIni	:=	SToD( '20120101' )
Default dDataFim	:=	SToD( '20131231' )
Default aFilSel	:=	{{.T.,cFilAnt}}
Default cJobAux := ""

//Tratamento para que caso ocorra Erro durante o processamento não estoure na tela
//é exibida uma mensagem tratada do erro para o usuário final
Begin Sequence

	//No caso do Sped Fiscal apenas pode ser gerada uma filial por processamento, sendo assim, antes de iniciar a execução dos blocos
	//eu seto a filial onde ocorrera o processamento
	//cFilAnt := Substr( cFilSelBc, 2, 2 ) 
	
	//Array com as informações a serem geradas na tabela compartilhada
	//Filial + Data Inicio + Data Final + Bloco + Sequencializador
	aInfoGrv := { cFilAnt , DToS( aWizardBc[1,1] ), DToS( aWizardBc[1,2] ), "1", 0 }
	
	If Substr(aWizardBc[4][1],5,1) == "S"
		
		//1100,1105,1110
		Bloco1100( dDataIni , dDataFim ,  aCmps, aWizardBc )
	EndIf
	
	If Substr(aWizardBc[4][2],5,1) == "S"
			
		//1200,1210
		Bloco1200( dDataIni , dDataFim , aCmps, aWizardBc )
	EndIf
	
	If Substr(aWizardBc[4][3],5,1) == "S"
		//1300,1310,1320
		Bloco1300( dDataIni , dDataFim ,  aCmps, aWizardBc )
	    //1350,1360,1370
	    Bloco1350(dDataIni , dDataFim ,  aCmps, aWizardBc )
	EndIf	 
	
	If Substr(aWizardBc[4][4],5,1) == "S"			
		//1390,1391
		Bloco1390( dDataIni , dDataFim ,  aCmps, aWizardBc )
	EndIf
	
	If Substr(aWizardBc[4][5],5,1) == "S"
		//1400
		Bloco1400( dDataIni , dDataFim ,  aCmps, aWizardBc )
	EndIf
	
	If Substr(aWizardBc[4][6],5,1) == "S" .And. Substr(aWizardBc[2][6],1,1) == "0" .And. lConv115
		//1500 e 1510
		Bloco1500( dDataIni , dDataFim ,  aCmps, aWizardBc )                             
	EndIf
	
	If Substr(aWizardBc[4][7],5,1) == "S"
		//1600
		Bloco1600( dDataIni , dDataFim ,  aCmps, aWizardBc )                             
	EndIf
	
	If Substr(aWizardBc[4][8],5,1) == "S"
		//1700 e 1710
		Bloco1700( dDataIni , dDataFim , aCmps, aWizardBc )
	EndIf
	
	If Substr(aWizardBc[4][9],5,1) == "S"
		//1800
		Bloco1800( dDataIni , dDataFim , aCmps, aWizardBc )
	EndIf
	
	//1900, 1910, 1920, 1921, 1922, 1923, 1925 e 1926
	Bloco1900( dDataIni , dDataFim , aCmps, aWizardBc )       
	
	//Caso nao tenha sido gerado o registro 1001 ( Pois nao Houve Movimento )
	//realizao a sua emissao agora	
	If !lGer1001	
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		cStrTxt := ""
		LoadString( '1001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1001",aTotReg1)
	
		aMacro	:=	{}
		aAdd( aMacro , Substr(aWizardBc[4][1],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][2],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][3],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][4],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][5],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][6],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][7],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][8],5,1) )							
		aAdd( aMacro , Substr(aWizardBc[4][9],5,1) )
			
		cStrTxt := ""
		LoadString( '1010' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1010",aTotReg1)		  				  
			             
	EndIf   
	
	For nlI := 1 To Len( aTotReg1 )
		nTotReg += aTotReg1[nlI][2]
	Next           
	
	Reg990Spd( "1", cTabSped, cFilSel, aWizard ) 
	
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
	xTafCtlObr( "2", "1", aWizardBc, cFilSelBc, , "TAFGERCTL", "SPEDFIS" )	
EndIf


Return ( Nil )
//-------------------------------------------------------------------
/*/{Protheus.doc} Bloco1100
Funcao responsavel processar o movimento especifico para montagem dos registros:
 1100,1105,1110 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Bloco1100( dDataIni , dDataFim , aCmps, aWizardBc )
Local 	cAliasQry 	:=  GetNextAlias()
Local	aMacro		:=	{}
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0
Local	cQuery		:=	''

/*----------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
----------------------------------------------------------*/
C4F->( dbSetOrder( 5 ) )
C4G->( dbSetOrder( 1 ) )
C4H->( dbSetOrder( 1 ) )
C0S->( dbSetOrder( 3 ) )
C01->( dbSetOrder( 3 ) )
C1L->( dbSetOrder( 3 ) )
C1H->( dbSetOrder( 5 ) )
C1J->( dbSetOrder( 3 ) )
C08->( dbSetOrder( 3 ) )


cQuery	+=	"SELECT C4F_ID, C4F_INDDOC, C4F_NRODE, C4F_DTDE, C4F_NATEXP,C4F_NRORE, C4F_DTRE, C4F_CHCEMB, C4F_DTCHC, C4F_DTAVB, C4F_TPCHC, C4F_PAIS, C4F_UFEMBQ, C4F_DUFEMB, C4F_LCEMBQ "
cQuery	+=	"FROM " + RetSqlName( 'C4F' ) + " C4F "
cQuery	+=	"WHERE C4F.C4F_FILIAL='" + xFilial('C4F') + "' AND "
cQuery	+=	"C4F.C4F_DTAVB>='" + DToS( dDataIni ) + "' AND "
cQuery	+=	"C4F.C4F_DTAVB<='" + DToS( dDataFim ) + "' AND "
cQuery	+=	"C4F.D_E_L_E_T_=' ' "
cQuery	+=	"ORDER BY " + SqlOrder( C4F->( IndexKey() ) )

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

TcSetField( cAliasQry , "C4F_DTDE" , "D" , 8 , 0 )
TcSetField( cAliasQry , "C4F_DTRE" , "D" , 8 , 0 )
TcSetField( cAliasQry , "C4F_DTCHC" , "D" , 8 , 0 )
TcSetField( cAliasQry , "C4F_DTAVB" , "D" , 8 , 0 )

/*----------------------------------------------------------
Executando laco principal da rotina para gerar o registro 1100
----------------------------------------------------------*/
While !( cAliasQry )->( Eof() )
   
	If !lGer1001
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( '1001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1001",aTotReg1)
		
		aMacro	:=	{}
		aAdd( aMacro , Substr(aWizardBc[4][1],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][2],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][3],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][4],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][5],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][6],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][7],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][8],5,1) )							
		aAdd( aMacro , Substr(aWizardBc[4][9],5,1) )
			
		LoadString( '1010' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1010",aTotReg1)
		
		lGer1001 := .T.		               
    EndIf


	aMacro		:=	{}
	aAdd( aMacro, "C0S->( msSeek( xFilial( 'C0S' ) + '" + ( cAliasQry )->C4F_TPCHC + "' ) )" )
	aAdd( aMacro, "C08->( msSeek( xFilial( 'C08' ) + '" + ( cAliasQry )->C4F_PAIS  + "' ) )" )
	
	LoadString( '1100' , aCmps , @cStrTxt , cAliasQry , , aMacro )
	
	aInfoGrv[5]++
	nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, '1100' )
	
	TaFContBlc("1100",aTotReg1)

	/*----------------------------------------------------------
	Executando laco intermediario da rotina para gerar o registro 1105
	----------------------------------------------------------*/	
	If nRWStrTxt > 0 .And. C4G->( msSeek( xFilial( 'C4G' ) + ( cAliasQry )->C4F_ID ) )
		While !C4G->( Eof() ) .And. C4G->( C4G_FILIAL + C4G_ID ) == xFilial( 'C4G' ) + ( cAliasQry )->C4F_ID
		
			aMacro		:=	{}
			aAdd( aMacro, "C01->( msSeek( xFilial( 'C01' ) + C4G->C4G_CODMOD ) )" )
			aAdd( aMacro, "C1L->( msSeek( xFilial( 'C1L' ) + C4G->C4G_CODITE ) )" )
		
			LoadString( '1105' , aCmps , @cStrTxt , 'C4G' , , aMacro )
			
			aInfoGrv[5]++
			nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, '1100' )          
			
			TaFContBlc("1105",aTotReg1)			

			/*----------------------------------------------------------
			Executando laco final da rotina para gerar o registro 1110
			----------------------------------------------------------*/	
			If nRWStrTxt > 0 .And.;
				C4H->( msSeek( xFilial( 'C4H' ) + C4G->( C4G_ID + C4G_CODMOD + C4G_SERIE + C4G_NUMDOC + DToS( C4G_DTDOC ) + C4G_CODITE ) ) )
				
				While !C4H->( Eof() ) .And. C4H->( C4H_FILIAL+C4H_ID+C4H_CMOD+C4H_SER+C4H_DOC+DTOS(C4H_DT)+C4H_CODITE ) == ;
					xFilial( 'C4H' ) + C4G->( C4G_ID + C4G_CODMOD + C4G_SERIE + C4G_NUMDOC + DToS( C4G_DTDOC ) + C4G_CODITE )
		
					aMacro		:=	{}
					aAdd( aMacro, "C1H->( msSeek( xFilial( 'C1H' ) + C4H->C4H_CODPAR ) )" )
					aAdd( aMacro, "C01->( msSeek( xFilial( 'C01' ) + C4H->C4H_CODMOD ) )" )
					aAdd( aMacro, "C1J->( msSeek( xFilial( 'C1J' ) + C4H->C4H_UNID ) )" )
		
					LoadString( '1110' , aCmps , @cStrTxt , 'C4H' , , aMacro )
					
					aInfoGrv[5]++
					nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, '1100' )  
					
					TaFContBlc("1110",aTotReg1)					
					
					If nRWStrTxt == -1
						Exit				
					EndIf

					C4H->( dbSkip() )
				End
			EndIf
			
			If nRWStrTxt == -1
				Exit				
			EndIf
			
			C4G->( dbSkip() )
		End
	
 	EndIf
 	
	If nRWStrTxt == -1
		Exit				
	EndIf

	( cAliasQry )->( dbSkip() )
End
( cAliasQry )->( dbCloseArea() )

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Bloco1200
Funcao responsavel processar o movimento especifico para montagem dos registros:
 1200,1210 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Bloco1200( dDataIni , dDataFim , aCmps, aWizardBc )
Local 	cAliasQry 	:=  GetNextAlias()
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0
Local	cQuery		:=	''
Local   lAchou1210  := .F.

cQuery	+=	"SELECT "
cQuery	+=		"C1A.C1A_CODIGO, C50.C50_SLDCRD, C50.C50_CRDAPR, C50.C50_CRDREC, C50.C50_CRDUTI, C50.C50_SDCRFI, C4Z.C4Z_CODIGO, C51.C51_NRODOC, C51.C51_CRUTIL"
If TAFColumnPos( "C51_CHVELE" )
	cQuery	+= ", C51.C51_CHVELE" 
EndIf
cQuery	+=	"FROM "
cQuery	+=		RetSqlName( 'C50' ) + " C50 "
cQuery	+=		"JOIN " + RetSqlName( 'C1A' ) + " C1A ON(C1A.C1A_FILIAL='" + xFilial('C1A') + "' AND C1A.C1A_ID=C50.C50_CODAJU AND C1A.D_E_L_E_T_=' ') "
cQuery	+=		"LEFT JOIN " + RetSqlName( 'C51' ) + " C51 ON(C51.C51_FILIAL=C50.C50_FILIAL AND C51.C51_ID=C50.C50_ID AND C51.D_E_L_E_T_=' ') "
cQuery	+=		"LEFT JOIN " + RetSqlName( 'C4Z' ) + " C4Z ON(C4Z.C4Z_FILIAL='" + xFilial('C4Z') + "' AND C4Z.C4Z_ID=C51.C51_TPUTIL AND C4Z.D_E_L_E_T_=' ') "
cQuery	+=	"WHERE "
cQuery	+=		"C50.C50_FILIAL='" + xFilial('C50') + "' AND "
cQuery	+=		"C50.C50_PERIOD>='" + DToS( dDataIni ) + "' AND "
cQuery	+=		"C50.C50_PERIOD<='" + DToS( dDataFim ) + "' AND "
cQuery	+=		"C50.D_E_L_E_T_=' ' "
cQuery	+=	"ORDER BY "
cQuery	+=		" C1A_CODIGO "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

/*----------------------------------------------------------
Executando laco principal da rotina para gerar o registro 1200
----------------------------------------------------------*/
While !( cAliasQry )->( Eof() )    

	If !lGer1001
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( '1001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1001",aTotReg1)  
		
		aMacro	:=	{}
		aAdd( aMacro , Substr(aWizardBc[4][1],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][2],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][3],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][4],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][5],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][6],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][7],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][8],5,1) )							
		aAdd( aMacro , Substr(aWizardBc[4][9],5,1) )
			
		LoadString( '1010' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1010",aTotReg1)		  					
		
		lGer1001 := .T.		               
	EndIf
	
	LoadString( '1200' , aCmps , @cStrTxt , cAliasQry )
	
	aInfoGrv[5]++
	nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )
	
	TaFContBlc("1200",aTotReg1)

	/*----------------------------------------------------------
	Executando laco intermediario da rotina para gerar o registro 1210
	----------------------------------------------------------*/	
	If nRWStrTxt > 0
		lAchou1210 := .F.
		cChave	:=	( cAliasQry )->C1A_CODIGO
		While !( cAliasQry )->( Eof() ) .And. ( cAliasQry )->C1A_CODIGO == cChave .And. !Empty(C4Z_CODIGO)
			lAchou1210 := .T.
			LoadString( '1210' , aCmps , @cStrTxt , cAliasQry )
			
			aInfoGrv[5]++
			nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv , "1200")
			
			TaFContBlc("1210",aTotReg1)			
			
			If nRWStrTxt == -1
				Exit				
			EndIf
			
			( cAliasQry )->( dbSkip() )
		End	
 	EndIf
 	
 	If !lAchou1210
 		( cAliasQry )->( dbSkip() )
 	EndIf
 	
	If nRWStrTxt == -1
		Exit
	EndIf
End
( cAliasQry )->( dbCloseArea() )

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Bloco1300
Funcao responsavel processar o movimento especifico para montagem dos registros:
 1300,1310 e 1320 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Bloco1300( dDataIni , dDataFim ,  aCmps, aWizardBc )
Local 	cAliasQry 	:=  GetNextAlias()
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0
Local	cQuery		:=	''
Local	cChave		:=	''
Local	cChave2		:=	''

cQuery	+=	"SELECT "
cQuery	+=		"C1L.C1L_CODIGO, C4N.*, C4O.*, C4P.*, C1L.C1L_FILIAL "
cQuery	+=	"FROM "
cQuery	+=		RetSqlName( 'C4N' ) + " C4N "
cQuery	+=		"LEFT JOIN " + RetSqlName( 'C1L' ) + " C1L ON(C1L.C1L_FILIAL='" + xFilial('C1L') + "' AND C1L.C1L_ID=C4N.C4N_CODITE AND C1L.D_E_L_E_T_=' ') "
cQuery	+=		"LEFT JOIN " + RetSqlName( 'C4O' ) + " C4O ON(C4O.C4O_FILIAL=C4N.C4N_FILIAL AND C4O.C4O_ID=C4N.C4N_ID AND C4O.D_E_L_E_T_=' ') "
cQuery	+=		"LEFT JOIN " + RetSqlName( 'C4P' ) + " C4P ON(C4P.C4P_FILIAL=C4O.C4O_FILIAL AND C4P.C4P_ID=C4O.C4O_ID AND C4P.C4P_NUMTAN=C4O.C4O_NUMTAN AND C4P.D_E_L_E_T_=' ') "
cQuery	+=	"WHERE "
cQuery	+=		"C4N.C4N_FILIAL='" + xFilial('C4N') + "' AND "
cQuery	+=		"C4N.C4N_DTFECH>='" + DToS( dDataIni ) + "' AND "
cQuery	+=		"C4N.C4N_DTFECH<='" + DToS( dDataFim ) + "' AND "
cQuery	+=		"C4N.D_E_L_E_T_=' ' "
cQuery	+=	"ORDER BY "
cQuery	+=		" C1L_CODIGO, C4N_DTFECH "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

TcSetField( cAliasQry , "C4N_DTFECH" , "D" , 8 , 0 )

/*----------------------------------------------------------
Executando laco principal da rotina para gerar o registro 1300
----------------------------------------------------------*/
While !( cAliasQry )->( Eof() )
	

	If !lGer1001
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( '1001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1001",aTotReg1)  
		
		aMacro	:=	{}
		aAdd( aMacro , Substr(aWizardBc[4][1],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][2],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][3],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][4],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][5],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][6],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][7],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][8],5,1) )							
		aAdd( aMacro , Substr(aWizardBc[4][9],5,1) )
			
		LoadString( '1010' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1010",aTotReg1)		  					
		
		lGer1001 := .T.		               
	EndIf
		
	LoadString( '1300' , aCmps , @cStrTxt , cAliasQry )
	
	aInfoGrv[5]++
	nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1300" )
	
	TaFContBlc("1300",aTotReg1)	

	/*----------------------------------------------------------
	Executando laco intermediario da rotina para gerar o registro 1310
	----------------------------------------------------------*/	
	If nRWStrTxt > 0
		cChave	:=	( cAliasQry )->( C1L_CODIGO + DToS( C4N_DTFECH ) + C4O_NUMTAN ) 
		While !( cAliasQry )->( Eof() ) .And. ( cAliasQry )->( C1L_CODIGO + DToS( C4N_DTFECH ) + C4O_NUMTAN ) == cChave

			LoadString( '1310' , aCmps , @cStrTxt , cAliasQry )
			
			aInfoGrv[5]++
			nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1300" )          
			
			TaFContBlc("1310",aTotReg1)			
			
			/*----------------------------------------------------------
			Executando laco intermediario da rotina para gerar o registro 1320
			----------------------------------------------------------*/	
			If nRWStrTxt > 0
				cChave2	:=	( cAliasQry )->( C1L_CODIGO + DToS( C4N_DTFECH ) + C4O_NUMTAN + C4P_NUMBIC ) 
				While !( cAliasQry )->( Eof() ) .And. ( cAliasQry )->( C1L_CODIGO + DToS( C4N_DTFECH ) + C4O_NUMTAN + C4P_NUMBIC ) == cChave2
		
					LoadString( '1320' , aCmps , @cStrTxt , cAliasQry )
					
					aInfoGrv[5]++
					nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1300" )
					
					TaFContBlc("1320",aTotReg1)					
					
					If nRWStrTxt == -1
						Exit				
					EndIf
					
					( cAliasQry )->( dbSkip() )
				End
			EndIf
			
			If nRWStrTxt == -1
				Exit
			EndIf
		End
	
 	EndIf
 	
	If nRWStrTxt == -1
		Exit
	EndIf
End
( cAliasQry )->( dbCloseArea() )

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Bloco1350
Funcao responsavel processar o movimento especifico para montagem dos registros:
 1350,1360 e 1370 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Bloco1350( dDataIni , dDataFim , aCmps, aWizardBc )
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0

/*----------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
----------------------------------------------------------*/
C55->( dbSetOrder( 1 ) )
C56->( dbSetOrder( 1 ) )
C57->( dbSetOrder( 1 ) )
C1L->( dbSetOrder( 3 ) )

/*----------------------------------------------------------
Executando laco principal da rotina para gerar o registro 1350
----------------------------------------------------------*/
C55->( msSeek( xFilial( 'C55' ) ) )
While !C55->( Eof() )

	If !lGer1001
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( '1001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1001",aTotReg1)  
		
		aMacro	:=	{}
		aAdd( aMacro , Substr(aWizardBc[4][1],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][2],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][3],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][4],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][5],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][6],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][7],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][8],5,1) )							
		aAdd( aMacro , Substr(aWizardBc[4][9],5,1) )
			
		LoadString( '1010' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1010",aTotReg1)		  					
		
		lGer1001 := .T.		               
	EndIf
		
	LoadString( '1350' , aCmps , @cStrTxt , 'C55' )
	
	aInfoGrv[5]++
	nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1350" )
	
	TaFContBlc("1350",aTotReg1)	

	/*----------------------------------------------------------
	Executando laco intermediario da rotina para gerar o registro 1360
	----------------------------------------------------------*/	
	If nRWStrTxt > 0
		C56->( msSeek( xFilial( 'C56' ) + C55->C55_ID ) )
		While !C56->( Eof() ) .And. C56->( C56_FILIAL + C56_ID ) == C55->( C55_FILIAL + C55_ID ) 

			LoadString( '1360' , aCmps , @cStrTxt , 'C56' )
			
			aInfoGrv[5]++
			nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1350" )
			
			TaFContBlc("1360",aTotReg1)			
			
			If nRWStrTxt == -1
				Exit
			EndIf

			C56->( dbSkip() )
		End	
 	EndIf
 	
	/*----------------------------------------------------------
	Executando laco intermediario da rotina para gerar o registro 1370
	----------------------------------------------------------*/	
	If nRWStrTxt > 0
		C57->( msSeek( xFilial( 'C57' ) + C55->C55_ID ) )
		While !C57->( Eof() ) .And. C57->( C57_FILIAL + C57_ID ) == C55->( C55_FILIAL + C55_ID ) 
            
			lSeek	:=	C1L->( msSeek( xFilial( 'C1L' ) + C57->C57_CODIGO) )
			
			LoadString( '1370' , aCmps , @cStrTxt , 'C57' , lSeek )
			
			aInfoGrv[5]++
			nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1350" )
			
			TaFContBlc("1370",aTotReg1)			
			
			If nRWStrTxt == -1
				Exit
			EndIf

			C57->( dbSkip() )
		End	
 	EndIf
 	
	If nRWStrTxt == -1
		Exit
	EndIf

	C55->( dbSkip() )
End

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Bloco1390
Funcao responsavel processar o movimento especifico para montagem dos registros:
 1390 e 1391 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Bloco1390( dDataIni , dDataFim ,  aCmps, aWizardBc )
Local 	cAliasQry 	:=  GetNextAlias()
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0
Local	cQuery		:=	''
Local	cChave		:=	''

cQuery	+=	"SELECT "
cQuery	+=		"C6N.* "
cQuery	+=	"FROM "
cQuery	+=		RetSqlName( 'C6N' ) + " C6N "
cQuery	+=	"WHERE "
cQuery	+=		"C6N.C6N_FILIAL='" + xFilial('C6N') + "' AND "
cQuery	+=		"C6N.C6N_PERIOD>='" + DToS( dDataIni ) + "' AND "
cQuery	+=		"C6N.C6N_PERIOD<='" + DToS( dDataFim ) + "' AND "
cQuery	+=		"C6N.D_E_L_E_T_=' ' "
cQuery	+=	"ORDER BY "
cQuery	+=		" C6N_PERIOD, C6N_CODPRO, C6N_DTPRD "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

TcSetField( cAliasQry , "C6N_DTPRD" , "D" , 8 , 0 )

/*----------------------------------------------------------
Executando laco principal da rotina para gerar o registro 1390
----------------------------------------------------------*/
While !( cAliasQry )->( Eof() )

	If !lGer1001
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( '1001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1001",aTotReg1)      
		
		aMacro	:=	{}
		aAdd( aMacro , Substr(aWizardBc[4][1],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][2],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][3],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][4],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][5],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][6],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][7],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][8],5,1) )							
		aAdd( aMacro , Substr(aWizardBc[4][9],5,1) )
			
		LoadString( '1010' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1010",aTotReg1)					
		
		lGer1001 := .T.		               
	EndIf
		
	LoadString( '1390' , aCmps , @cStrTxt , cAliasQry )
	
	aInfoGrv[5]++
	nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )
	
	TaFContBlc("1390",aTotReg1)

	/*----------------------------------------------------------
	Executando laco intermediario da rotina para gerar o registro 1391
	----------------------------------------------------------*/	
	If nRWStrTxt > 0
		cChave	:=	( cAliasQry )->( C6N_FILIAL + C6N_CODPRO )
		While !( cAliasQry )->( Eof() ) .And. ( cAliasQry )->( C6N_FILIAL + C6N_CODPRO ) == cChave

			LoadString( '1391' , aCmps , @cStrTxt , cAliasQry )
			
			aInfoGrv[5]++
			nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )                     
			
			TaFContBlc("1391",aTotReg1)			
			
			If nRWStrTxt == -1
				Exit
			EndIf

			( cAliasQry )->( dbSkip() )
		End	
 	EndIf
 	
	If nRWStrTxt == -1
		Exit
	EndIf 	
End

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Bloco1400
Funcao responsavel processar o movimento especifico para montagem dos registros:
 1400 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Bloco1400( dDataIni , dDataFim ,  aCmps, aWizardBc )
Local 	cAliasQry 	:=  GetNextAlias()
Local	cStrTxt	:=	''
Local	nRWStrTxt	:=	0
Local	cQuery		:=	''
Local  a1400 		:= {}
Local  ni			:= 0

cQuery	+=	"SELECT "
cQuery	+=		"C1L.C1L_CODIGO, C07.C07_CODIGO, C4X.C4X_VALOR, C4X.C4X_UF, C09.C09_CODIGO, C1L.C1L_FILIAL, LF0.LF0_CODIGO "
cQuery	+=	"FROM "
cQuery	+=		RetSqlName( 'C4X' ) + " C4X "
cQuery	+=		"JOIN "		+ RetSqlName( 'C1L' ) + " C1L ON(C1L.C1L_FILIAL='" + xFilial('C1L') + "' AND C1L.C1L_ID=C4X.C4X_CODITE	AND C1L.D_E_L_E_T_=' ') "
cQuery	+=		"JOIN " 		+ RetSqlName( 'C07' ) + " C07 ON(C07.C07_FILIAL='" + xFilial('C07') + "' AND C07.C07_ID=C4X.C4X_CODMUN	AND C07.D_E_L_E_T_=' ') "
cQuery	+=		"JOIN " 		+ RetSqlName( 'C09' ) + " C09 ON(C09.C09_FILIAL='" + xFilial('C09') + "' AND C09.C09_ID=C4X.C4X_UF		AND C09.D_E_L_E_T_=' ') "
cQuery	+=		"LEFT JOIN "	+ RetSqlName( 'LF0' ) + " LF0 ON(LF0.LF0_FILIAL='" + xFilial('LF0') + "' AND LF0.LF0_UF=C4X.C4X_UF		AND LF0.LF0_ID=C4X.C4X_CODIPM AND LF0.D_E_L_E_T_=' ') "
cQuery	+=	"WHERE "
cQuery	+=		"C4X.C4X_FILIAL='"  + xFilial('C4X')   + "' AND "
cQuery	+=		"C4X.C4X_PERIOD>='" + DToS( dDataIni ) + "' AND "
cQuery	+=		"C4X.C4X_PERIOD<='" + DToS( dDataFim ) + "' AND "
cQuery	+=		"C4X.D_E_L_E_T_=' ' "
cQuery	+=	"ORDER BY "
cQuery	+=		" C09_CODIGO, C07_CODIGO, LF0_CODIGO "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

/*----------------------------------------------------------
Executando laco principal da rotina para gerar o registro 1400
----------------------------------------------------------*/
While !( cAliasQry )->( Eof() )

	If !lGer1001
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( '1001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1001",aTotReg1)
		
		aMacro	:=	{}
		aAdd( aMacro , Substr(aWizardBc[4][1],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][2],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][3],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][4],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][5],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][6],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][7],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][8],5,1) )							
		aAdd( aMacro , Substr(aWizardBc[4][9],5,1) )
			
		LoadString( '1010' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1010",aTotReg1)		  					
		
		lGer1001 := .T.		               
	EndIf
	
	/* Houve a necessidade de tratar de forma diferenciada o bloco 1400
	   Pois através do extrator e da rotina padrão para dos os blocos os registros nunca serão agrupados
	   Sempre serão gerados detalhadamente.
	   A codificação abaixo agrupa os registros da forma que o sped necessita. Alteração feita em 06/03/2018
	*/					
	If len(a1400) > 0
		If ( nPos := aScan( a1400, { |x| AllTrim( x[3] ) == Alltrim(( cAliasQry )->C09_CODIGO ) + Alltrim(( cAliasQry )->C07_CODIGO) } ) ) > 0
			a1400[Len(a1400)][4] += ( cAliasQry )->C4X_VALOR
		Else
			aAdd( a1400 , {	"1400",;																				// Código Registro
								Alltrim(( cAliasQry )->LF0_CODIGO),; 												// Código DIPAM
								Alltrim(( cAliasQry )->C09_CODIGO ) + Alltrim(( cAliasQry )->C07_CODIGO),;	// Código Município
								( cAliasQry )->C4X_VALOR })															// Valor
		Endif   
	Else
		aAdd( a1400 , {	"1400",;																				// Código Registro
							Alltrim(( cAliasQry )->LF0_CODIGO),; 												// Código DIPAM
							Alltrim(( cAliasQry )->C09_CODIGO ) + Alltrim(( cAliasQry )->C07_CODIGO),;	// Código Município
							( cAliasQry )->C4X_VALOR })															// Valor
	
	Endif	
	( cAliasQry )->( dbSkip() )
Enddo

//Gravação dos dados do Bloco 1400
If Len(a1400) > 0
	For ni:=1 to Len(a1400)
		cStrTxt := "|" + a1400[ni][1] + "|" + a1400[ni][2] + "|" + a1400[ni][3] + "|" + Val2Str( a1400[ni][4] , 16 , 2 )  + "|" 
		aInfoGrv[5]++
		nRWStrTxt	:=	WrtStrTxt(  , cStrTxt, .T., aInfoGrv )
	next	
	
	TaFContBlc("1400",aTotReg1)

Endif

Return     

//-------------------------------------------------------------------
/*/{Protheus.doc} Bloco1500        

Funcao responsavel processar o movimento especifico para montagem dos registros:
 1500 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		
@return NIL

@author Rodrigo Aguilar
@since 17/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Bloco1500( dDataIni , dDataFim , aCmps, aWizardBc )

Local 	cAliasQry 	:=  GetNextAlias()
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0
Local	cQuery		:=	''   
Local   lSeek          

Local	cC20SqlNm	:= RetSqlName("C20")
Local 	cC30SqlNm 	:= RetSqlName("C30")
Local 	cC35SqlNm	:= RetSqlName("C35")
Local   cMvTafUF    := GetNewPar( "MV_TAFUF", "SP" )

C30->(DbSetOrder(1))
C2E->(DbSetOrder(1))   
C21->(DbSetOrder(1))   
C3Q->(DbSetOrder(3))              
C0L->(DbSetOrder(3))  
C0N->(DbSetOrder(3))  
C32->(DbSetOrder(1))
C35->(DbSetOrder(1))
C1L->(DbSetOrder(3))
C14->(DbSetOrder(3))
C3S->(DbSetOrder(1))
C03->(DbSetOrder(3))
C0K->(DbSetOrder(4))
C0Y->(DbSetOrder(3))
C1O->(DbSetOrder(3))
C1H->(DbSetOrder(5))

cQuery := " SELECT  "  

cQuery += " C20_CHVNF,  "
cQuery += " C20_INDEMI, "
cQuery += " C1H_FILIAL, "
cQuery += " C1H_CODPAR, "
cQuery += " C01_CODIGO, "
cQuery += " C02_CODIGO, " 
cQuery += " C20_SERIE,  "
cQuery += " C20_SUBSER, "
cQuery += " C20_NUMDOC, "
cQuery += " C20_DTDOC,  "
cQuery += " C20_DTES,   "
cQuery += " C20_VLDOC,  "
cQuery += " C20_VLDESC, "
cQuery += " C20_VLRDA,  "

cQuery += "		( SELECT 
cQuery += "			SUM( C352.C35_BASE ) 
cQuery += "		  FROM
cQuery += 				cC20SqlNm + " C202 "
cQuery += "		  JOIN  " 
cQuery +=      		cC30SqlNm + " C302 ON ( C302.C30_FILIAL = '" + xFilial("C30") + "' AND C302.C30_CHVNF = C202.C20_CHVNF AND C302.D_E_L_E_T_ = ' ' ) " 
cQuery += "		  JOIN "
cQuery +=  			cC35SqlNm	+ " C352 ON ( C352.C35_FILIAL = '" + xFilial("C35") + "' AND C352.C35_CHVNF = C302.C30_CHVNF AND C352.C35_NUMITE = C302.C30_NUMITE AND " 
cQuery += "							 C352.C35_CODITE = C302.C30_CODITE AND C352.D_E_L_E_T_ = '' ) "	
cQuery += "		  LEFT JOIN "
cQuery += 			RetSqlName("C01") + " C012 ON ( C012.C01_FILIAL = '" + xFilial("C01") + "' AND C012.C01_ID = C202.C20_CODMOD AND C012.D_E_L_E_T_ = '' ) "
cQuery += "		  LEFT JOIN "
cQuery += 			RetSqlName("C1H") + " C1H2 ON ( C1H2.C1H_FILIAL = '" + xFilial("C1H") + "' AND C1H2.C1H_ID = C202.C20_CODPAR AND C1H2.D_E_L_E_T_ = '' ) "
cQuery += "	  	  LEFT JOIN "
cQuery += 			RetSqlName("C09") + " C092 ON ( C012.C01_FILIAL = '" + xFilial("C09") + "' AND C092.C09_ID = C1H2.C1H_UF AND C092.D_E_L_E_T_ = '' ) "
cQuery += "	  	  LEFT JOIN "
cQuery += 			RetSqlName("C3S") + " C3S2 ON ( C3S2.C3S_FILIAL = '" + xFilial("C3S") + "' AND C3S2.C3S_ID = C352.C35_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "
cQuery += "		  LEFT JOIN " 
cQuery += 		 	RetSqlName( 'C02' ) + " C022 ON( C022.C02_FILIAL='" + xFilial('C02') + "' AND C022.C02_ID= C202.C20_CODSIT AND C022.D_E_L_E_T_=' ') "
cQuery += "		  WHERE 
cQuery += "      	((C202.C20_INDOPE = '0' AND C202.C20_DTES BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "') OR "
cQuery += "		 (C202.C20_INDOPE = '1' AND C202.C20_DTDOC BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "')) AND "
cQuery += " 		C202.C20_FILIAL='" + xFilial('C20') + "' AND "
cQuery += " 		C012.C01_CODIGO = '06' AND " 
cQuery += " 		C092.C09_UF <> '" + cMvTafUF + "' AND "
cQuery += " 		C202.C20_INDEMI = '0' AND "
cQuery += " 		C3S2.C3S_CODIGO = '02' AND "
cQuery += " 		C202.D_E_L_E_T_ = '' "     	
cQuery += "		 ) BCICMS,                 

cQuery += "		( SELECT 
cQuery += "			SUM( C352.C35_VALOR ) 
cQuery += "		  FROM
cQuery += 				cC20SqlNm + " C202 "
cQuery += "		  JOIN 
cQuery += 				cC30SqlNm + " C302 ON ( C302.C30_FILIAL = '" + xFilial("C30") + "' AND C302.C30_CHVNF = C202.C20_CHVNF AND C302.D_E_L_E_T_ = ' ' ) " 
cQuery += "		  JOIN " 
cQuery += 				cC35SqlNm + " C352 ON ( C352.C35_FILIAL = '" + xFilial("C35") + "' AND C352.C35_CHVNF = C302.C30_CHVNF AND C352.C35_NUMITE = C302.C30_NUMITE AND " 
cQuery += "							 C352.C35_CODITE = C302.C30_CODITE AND C352.D_E_L_E_T_ = '' )	"
cQuery += "		  LEFT JOIN "
cQuery += 			RetSqlName("C01") + " C012 ON ( C012.C01_FILIAL = '" + xFilial("C01") + "' AND C012.C01_ID = C202.C20_CODMOD AND C012.D_E_L_E_T_ = '' ) "
cQuery += "		  LEFT JOIN "
cQuery += 			RetSqlName("C1H") + " C1H2 ON ( C1H2.C1H_FILIAL = '" + xFilial("C1H") + "' AND C1H2.C1H_ID = C202.C20_CODPAR AND C1H2.D_E_L_E_T_ = '' ) "
cQuery += "	  	  LEFT JOIN "
cQuery += 			RetSqlName("C09") + " C092 ON ( C012.C01_FILIAL = '" + xFilial("C09") + "' AND C092.C09_ID = C1H2.C1H_UF AND C092.D_E_L_E_T_ = '' ) "
cQuery += "	  	  LEFT JOIN "
cQuery += 			RetSqlName("C3S") + " C3S2 ON ( C3S2.C3S_FILIAL = '" + xFilial("C3S") + "' AND C3S2.C3S_ID = C352.C35_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "
cQuery += "		  LEFT JOIN " 
cQuery += 		 	RetSqlName( 'C02' ) + " C022 ON( C022.C02_FILIAL='" + xFilial('C02') + "' AND C022.C02_ID= C202.C20_CODSIT AND C022.D_E_L_E_T_=' ') "
cQuery += "		  WHERE 
cQuery += "      	((C202.C20_INDOPE = '0' AND C202.C20_DTES BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "') OR "
cQuery += "		 (C202.C20_INDOPE = '1' AND C202.C20_DTDOC BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "')) AND "
cQuery += " 		C202.C20_FILIAL='" + xFilial('C20') + "' AND "
cQuery += " 		C012.C01_CODIGO = '06' AND " 
cQuery += " 		C092.C09_UF <> '" + cMvTafUF + "' AND "
cQuery += " 		C202.C20_INDEMI = '0' AND "
cQuery += " 		C3S2.C3S_CODIGO = '02' AND "
cQuery += " 		C202.D_E_L_E_T_ = '' "     	
cQuery += "		 ) VLICMS,                 

cQuery += "		( SELECT 
cQuery += "			SUM( C352.C35_BASE ) 
cQuery += "		  FROM
cQuery += 				cC20SqlNm +  " C202 " 
cQuery += "		  JOIN "
cQuery +=				cC30SqlNm + " C302 ON ( C302.C30_FILIAL = '" + xFilial("C30") + "' AND C302.C30_CHVNF = C202.C20_CHVNF AND C302.D_E_L_E_T_ = ' ' ) "
cQuery += "		  JOIN " 
cQuery +=  			cC35SqlNm + " C352 ON ( C352.C35_FILIAL = '" + xFilial("C35") + "' AND C352.C35_CHVNF = C302.C30_CHVNF AND C352.C35_NUMITE = C302.C30_NUMITE AND " 
cQuery += "							 C352.C35_CODITE = C302.C30_CODITE AND C352.D_E_L_E_T_ = '' )	" 
cQuery += "		  LEFT JOIN "
cQuery += 			RetSqlName("C01") + " C012 ON ( C012.C01_FILIAL = '" + xFilial("C01") + "' AND C012.C01_ID = C202.C20_CODMOD AND C012.D_E_L_E_T_ = '' ) "
cQuery += "		  LEFT JOIN "
cQuery += 			RetSqlName("C1H") + " C1H2 ON ( C1H2.C1H_FILIAL = '" + xFilial("C1H") + "' AND C1H2.C1H_ID = C202.C20_CODPAR AND C1H2.D_E_L_E_T_ = '' ) "
cQuery += "	  	  LEFT JOIN "
cQuery += 			RetSqlName("C09") + " C092 ON ( C012.C01_FILIAL = '" + xFilial("C09") + "' AND C092.C09_ID = C1H2.C1H_UF AND C092.D_E_L_E_T_ = '' ) "
cQuery += "	  	  LEFT JOIN "
cQuery += 			RetSqlName("C3S") + " C3S2 ON ( C3S2.C3S_FILIAL = '" + xFilial("C3S") + "' AND C3S2.C3S_ID = C352.C35_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "
cQuery += "		  LEFT JOIN " 
cQuery += 		 	RetSqlName( 'C02' ) + " C022 ON( C022.C02_FILIAL='" + xFilial('C02') + "' AND C022.C02_ID= C202.C20_CODSIT AND C022.D_E_L_E_T_=' ') "
cQuery += "		  WHERE 
cQuery += "      	((C202.C20_INDOPE = '0' AND C202.C20_DTES BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "') OR "
cQuery += "		 (C202.C20_INDOPE = '1' AND C202.C20_DTDOC BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "')) AND "
cQuery += " 		C202.C20_FILIAL='" + xFilial('C20') + "' AND "
cQuery += " 		C012.C01_CODIGO = '06' AND " 
cQuery += " 		C092.C09_UF <> '" + cMvTafUF + "' AND "
cQuery += " 		C202.C20_INDEMI = '0' AND "
cQuery += " 		C3S2.C3S_CODIGO = '04' AND "
cQuery += " 		C202.D_E_L_E_T_ = '' "     	
cQuery += "		 ) BCICMSST,

cQuery += "		( SELECT 
cQuery += "			SUM( C352.C35_VALOR ) 
cQuery += "		  FROM
cQuery += 				cC20SqlNm + " C202 " 
cQuery += "		  JOIN " 
cQuery += 				cC30SqlNm + " C302 ON ( C302.C30_FILIAL = '" + xFilial("C30") + "' AND C302.C30_CHVNF = C202.C20_CHVNF AND C302.D_E_L_E_T_ = ' ' ) " 
cQuery += "		  JOIN " 
cQuery += 				cC35SqlNm + " C352 ON ( C352.C35_FILIAL = '" + xFilial("C35") + "' AND C352.C35_CHVNF = C302.C30_CHVNF AND C352.C35_NUMITE = C302.C30_NUMITE AND "  
cQuery += "							 C352.C35_CODITE = C302.C30_CODITE AND C352.D_E_L_E_T_ = '' )	" 
cQuery += "		  LEFT JOIN "
cQuery += 			RetSqlName("C01") + " C012 ON ( C012.C01_FILIAL = '" + xFilial("C01") + "' AND C012.C01_ID = C202.C20_CODMOD AND C012.D_E_L_E_T_ = '' ) "
cQuery += "		  LEFT JOIN "
cQuery += 			RetSqlName("C1H") + " C1H2 ON ( C1H2.C1H_FILIAL = '" + xFilial("C1H") + "' AND C1H2.C1H_ID = C202.C20_CODPAR AND C1H2.D_E_L_E_T_ = '' ) "
cQuery += "	  	  LEFT JOIN "
cQuery += 			RetSqlName("C09") + " C092 ON ( C012.C01_FILIAL = '" + xFilial("C09") + "' AND C092.C09_ID = C1H2.C1H_UF AND C092.D_E_L_E_T_ = '' ) "
cQuery += "	  	  LEFT JOIN "
cQuery += 			RetSqlName("C3S") + " C3S2 ON ( C3S2.C3S_FILIAL = '" + xFilial("C3S") + "' AND C3S2.C3S_ID = C352.C35_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "
cQuery += "		  LEFT JOIN " 
cQuery += 		 	RetSqlName( 'C02' ) + " C022 ON( C022.C02_FILIAL='" + xFilial('C02') + "' AND C022.C02_ID= C202.C20_CODSIT AND C022.D_E_L_E_T_=' ') "
cQuery += "		  WHERE 
cQuery += "      	((C202.C20_INDOPE = '0' AND C202.C20_DTES BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "') OR "
cQuery += "		 (C202.C20_INDOPE = '1' AND C202.C20_DTDOC BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "')) AND "
cQuery += " 		C202.C20_FILIAL='" + xFilial('C20') + "' AND "
cQuery += " 		C012.C01_CODIGO = '06' AND " 
cQuery += " 		C092.C09_UF <> '" + cMvTafUF + "' AND "
cQuery += " 		C202.C20_INDEMI = '0' AND "
cQuery += " 		C3S2.C3S_CODIGO = '04' AND "
cQuery += " 		C202.D_E_L_E_T_ = '' "     	
cQuery += "		 ) VLICMSST,

cQuery += "		( SELECT 
cQuery += "			SUM( C352.C35_VALOR ) 
cQuery += "		  FROM
cQuery += 				cC20SqlNm + " C202 "
cQuery += "		  JOIN "
cQuery += 				cC30SqlNm + " C302 ON ( C302.C30_FILIAL = '" + xFilial("C30") + "' AND C302.C30_CHVNF = C202.C20_CHVNF AND C302.D_E_L_E_T_ = ' ' ) " 
cQuery += "		  JOIN " 
cQuery += 				cC35SqlNm + " C352 ON ( C352.C35_FILIAL = '" + xFilial("C35") + "' AND C352.C35_CHVNF = C302.C30_CHVNF AND C352.C35_NUMITE = C302.C30_NUMITE AND " 
cQuery += "							 C352.C35_CODITE = C302.C30_CODITE AND C352.D_E_L_E_T_ = '' )	" 
cQuery += "		  LEFT JOIN "
cQuery += 			RetSqlName("C01") + " C012 ON ( C012.C01_FILIAL = '" + xFilial("C01") + "' AND C012.C01_ID = C202.C20_CODMOD AND C012.D_E_L_E_T_ = '' ) "
cQuery += "		  LEFT JOIN "
cQuery += 			RetSqlName("C1H") + " C1H2 ON ( C1H2.C1H_FILIAL = '" + xFilial("C1H") + "' AND C1H2.C1H_ID = C202.C20_CODPAR AND C1H2.D_E_L_E_T_ = '' ) "
cQuery += "	  	  LEFT JOIN "
cQuery += 			RetSqlName("C09") + " C092 ON ( C012.C01_FILIAL = '" + xFilial("C09") + "' AND C092.C09_ID = C1H2.C1H_UF AND C092.D_E_L_E_T_ = '' ) "
cQuery += "	  	  LEFT JOIN "
cQuery += 			RetSqlName("C3S") + " C3S2 ON ( C3S2.C3S_FILIAL = '" + xFilial("C3S") + "' AND C3S2.C3S_ID = C352.C35_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "
cQuery += "		  LEFT JOIN " 
cQuery += 		 	RetSqlName( 'C02' ) + " C022 ON( C022.C02_FILIAL='" + xFilial('C02') + "' AND C022.C02_ID= C202.C20_CODSIT AND C022.D_E_L_E_T_=' ') "
cQuery += "		  WHERE " 
cQuery += "      	((C202.C20_INDOPE = '0' AND C202.C20_DTES BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "') OR "
cQuery += "		 (C202.C20_INDOPE = '1' AND C202.C20_DTDOC BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "')) AND "
cQuery += " 		C202.C20_FILIAL='" + xFilial('C20') + "' AND "
cQuery += " 		C012.C01_CODIGO = '06' AND " 
cQuery += " 		C092.C09_UF <> '" + cMvTafUF + "' AND "
cQuery += " 		C202.C20_INDEMI = '0' AND "
cQuery += " 		C3S2.C3S_CODIGO = '06' AND "
cQuery += " 		C202.D_E_L_E_T_ = '' "     	
cQuery += "		 ) VLPIS,                    

cQuery += "		( SELECT 
cQuery += "			SUM( C352.C35_VALOR ) 
cQuery += "		  FROM
cQuery += 				cC20SqlNm + " C202 "
cQuery += "		  JOIN "
cQuery += 				cC30SqlNm + " C302 ON ( C302.C30_FILIAL = '" + xFilial("C30") + "' AND C302.C30_CHVNF = C202.C20_CHVNF AND C302.D_E_L_E_T_ = ' ' ) "
cQuery += "		  JOIN "
cQuery += 				cC35SqlNm + " C352 ON ( C352.C35_FILIAL = '" + xFilial("C35") + "' AND C352.C35_CHVNF = C302.C30_CHVNF AND C352.C35_NUMITE = C302.C30_NUMITE AND " 
cQuery += "							 C352.C35_CODITE = C302.C30_CODITE AND C352.D_E_L_E_T_ = '' )	" 
cQuery += "		  LEFT JOIN "
cQuery += 			RetSqlName("C01") + " C012 ON ( C012.C01_FILIAL = '" + xFilial("C01") + "' AND C012.C01_ID = C202.C20_CODMOD AND C012.D_E_L_E_T_ = '' ) "
cQuery += "		  LEFT JOIN "
cQuery += 			RetSqlName("C1H") + " C1H2 ON ( C1H2.C1H_FILIAL = '" + xFilial("C1H") + "' AND C1H2.C1H_ID = C202.C20_CODPAR AND C1H2.D_E_L_E_T_ = '' ) "
cQuery += "	  	  LEFT JOIN "
cQuery += 			RetSqlName("C09") + " C092 ON ( C012.C01_FILIAL = '" + xFilial("C09") + "' AND C092.C09_ID = C1H2.C1H_UF AND C092.D_E_L_E_T_ = '' ) "
cQuery += "	  	  LEFT JOIN "
cQuery += 			RetSqlName("C3S") + " C3S2 ON ( C3S2.C3S_FILIAL = '" + xFilial("C3S") + "' AND C3S2.C3S_ID = C352.C35_CODTRI AND C3S2.D_E_L_E_T_ = '' ) "
cQuery += "		  LEFT JOIN " 
cQuery += 		 	RetSqlName( 'C02' ) + " C022 ON( C022.C02_FILIAL='" + xFilial('C02') + "' AND C022.C02_ID= C202.C20_CODSIT AND C022.D_E_L_E_T_=' ') "
cQuery += "		  WHERE 
cQuery += "      	((C202.C20_INDOPE = '0' AND C202.C20_DTES BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "') OR "
cQuery += "		 (C202.C20_INDOPE = '1' AND C202.C20_DTDOC BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "')) AND "
cQuery += " 		C202.C20_FILIAL='" + xFilial('C20') + "' AND "
cQuery += " 		C012.C01_CODIGO = '06' AND " 
cQuery += " 		C092.C09_UF <> '" + cMvTafUF + "' AND "
cQuery += " 		C202.C20_INDEMI = '0' AND "
cQuery += " 		C3S2.C3S_CODIGO = '07' AND "
cQuery += " 		C202.D_E_L_E_T_ = '' "     	
cQuery += "		 ) VLCOFINS "

cQuery += "	FROM "
cQuery += 		RetSqlName("C20") + " C20 "
cQuery += "	LEFT JOIN "
cQuery += 		RetSqlName("C01") + " C01 ON ( C01.C01_FILIAL = '" + xFilial("C01") + "' AND C01.C01_ID = C20.C20_CODMOD AND C01.D_E_L_E_T_ = '' ) "
cQuery += "	LEFT JOIN "
cQuery += 		RetSqlName("C1H") + " C1H ON ( C1H.C1H_FILIAL = '" + xFilial("C1H") + "' AND C1H.C1H_ID = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = '' ) "
cQuery += "	LEFT JOIN "
cQuery += 		RetSqlName("C09") + " C09 ON ( C09.C09_FILIAL = '" + xFilial("C09") + "' AND C09.C09_ID = C1H.C1H_UF AND C09.D_E_L_E_T_ = '' ) "
cQuery += "LEFT JOIN " 
cQuery += 		 RetSqlName( 'C02' ) + " C02 ON( C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID= C20.C20_CODSIT AND C02.D_E_L_E_T_=' ') "
cQuery += "	WHERE "
cQuery += "   ((C20.C20_INDOPE = '0' AND C20.C20_DTES BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "') OR "
cQuery += "	 (C20.C20_INDOPE = '1' AND C20.C20_DTDOC BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "')) AND "
cQuery += " 	C20.C20_FILIAL='" + xFilial('C20') + "' AND "
cQuery += " 	C01.C01_CODIGO = '06' AND " 
cQuery += " 	C09.C09_UF <> '" + cMvTafUF + "' AND "
cQuery += " 	C20.C20_INDEMI = '0' AND "
cQuery += " 	C20.D_E_L_E_T_ = '' "     	
cQuery += " ORDER BY     	"
cQuery += " 	C20_NUMDOC "  

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

/*----------------------------------------------------------
Executando laco principal da rotina para gerar o registro 1500
----------------------------------------------------------*/
While !( cAliasQry )->( Eof() )

	If !lGer1001
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( '1001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1001",aTotReg1)
		
		aMacro	:=	{}
		aAdd( aMacro , Substr(aWizardBc[4][1],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][2],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][3],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][4],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][5],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][6],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][7],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][8],5,1) )							
		aAdd( aMacro , Substr(aWizardBc[4][9],5,1) )
			
		LoadString( '1010' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1010",aTotReg1)		  					
		
		lGer1001 := .T.		               
   
	EndIf
	
	aMacro	:=	{}
	aAdd( aMacro , "1" ) 
	
	If C21->(MsSeek( xFilial("C21") + ( cAliasQry )->C20_CHVNF ) )
		aAdd( aMacro, "C3Q->(MsSeek( xFilial('C3Q') + C21->C21_CODINF ) )" )			  			
	Else
		aAdd( aMacro , ".F." ) 		
	EndIf
	
	If C2E->(MsSeek( xFilial("C2E") + ( cAliasQry )->C20_CHVNF ) )
		
		lSeek := .T.
		
		C0L->( msSeek( xFilial( 'C0L' ) + C2E->C2E_CODCON  ) )
		C0N->( msSeek( xFilial( 'C0N' ) + C2E->C2E_GRPTEN ) )				
	EndIf                          
	
	LoadString( '1500' , aCmps , @cStrTxt , cAliasQry, lSeek, aMacro )
	
	aInfoGrv[5]++
	nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1500" )

	If nRWStrTxt > 0 .And. C30->( msSeek( xFilial( 'C30' ) + ( cAliasQry )->C20_CHVNF ) )
	   
		TaFContBlc("1500",aTotReg1)	
				
		While !C30->( Eof() ) .And. C30->( C30_FILIAL + C30_CHVNF ) == xFilial( 'C30' ) + ( cAliasQry )->C20_CHVNF
            
			lSeek     := .F. 
			cIdICMS   := "" 
			cIdICMSST := ""
			cIdCofins := ""
			cIdPis    := ""                                                       
			
			If C32->(MsSeek(xFilial("C32") + C30->C30_CHVNF + C30->C30_NUMITE + C30->C30_CODITE ) )
				lSeek := .T.
			EndIf         
						
			aMacro	:=	{}			
			aAdd( aMacro, "C1L->( msSeek( xFilial( 'C1L' ) + C30->C30_CODITE ) )" )			  			
			aAdd( aMacro, "C0K->( msSeek( xFilial( 'C0K' ) + C32->C32_CCLASS ) )" )
			aAdd( aMacro, "C1J->( msSeek( xFilial( 'C1J' ) + C30->C30_UM ) )"     )           
			aAdd( aMacro, "C03->( msSeek( xFilial( 'C03' ) + C30->C30_ORIGEM ) )" )           

            If C3S->( MsSeek( xFilial("C3S") + "02" ) )             
            	cIdICMS := C3S->C3S_ID
				If C35->(MsSeek(xFilial('C35') + C30->C30_CHVNF + C30->C30_NUMITE + C30->C30_CODITE + cIdICMS ) )
					aAdd( aMacro, "C14->( msSeek( xFilial( 'C14' ) + C35->C35_CST ) )" )           
				Else
					aAdd( aMacro, ".F." )           				
				EndIf
			Else
				aAdd( aMacro, ".F." )           
            EndIf             			
			aAdd( aMacro, "C0Y->( msSeek( xFilial( 'C0Y' ) + C30->C30_CFOP ) )" )           			
			
			If !Empty( cIdICMS )
				aAdd( aMacro, "C35->(MsSeek(xFilial('C35') + C30->C30_CHVNF + C30->C30_NUMITE + C30->C30_CODITE + cIdICMS ) )" )
				aAdd( aMacro, "C35->(MsSeek(xFilial('C35') + C30->C30_CHVNF + C30->C30_NUMITE + C30->C30_CODITE + cIdICMS ) )" )
				aAdd( aMacro, "C35->(MsSeek(xFilial('C35') + C30->C30_CHVNF + C30->C30_NUMITE + C30->C30_CODITE + cIdICMS ) )" )
			Else
				aAdd( aMacro, ".F." )           
				aAdd( aMacro, ".F." )           
				aAdd( aMacro, ".F." )           
			EndIf                                                    
			                                                           
            If C3S->( MsSeek( xFilial("C3S") + "04" ) )             			
				cIdICMSST := C3S->C3S_ID
				aAdd( aMacro, "C35->(MsSeek(xFilial('C35') + C30->C30_CHVNF + C30->C30_NUMITE + C30->C30_CODITE + cIdICMSST ) )" )
				aAdd( aMacro, "C35->(MsSeek(xFilial('C35') + C30->C30_CHVNF + C30->C30_NUMITE + C30->C30_CODITE + cIdICMSST ) )" )
				aAdd( aMacro, "C35->(MsSeek(xFilial('C35') + C30->C30_CHVNF + C30->C30_NUMITE + C30->C30_CODITE + cIdICMSST ) )" )            				
			Else
				aAdd( aMacro, ".F." )           
				aAdd( aMacro, ".F." )           
				aAdd( aMacro, ".F." )           
			EndIf
            
			If lSeek
				aAdd( aMacro, "C1H->(MsSeek(xFilial('C1H') + C32->C32_CODPAR ) )" )			
			Else
				aAdd( aMacro, ".F." )           
			EndIf

            If C3S->( MsSeek( xFilial("C3S") + "06" ) )             			                   
            	cIdPis := C3S->C3S_ID
				aAdd( aMacro, "C35->(MsSeek(xFilial('C35') + C30->C30_CHVNF + C30->C30_NUMITE + C30->C30_CODITE + cIdPis ) )" )
			Else
				aAdd( aMacro, ".F." )           			
			EndIf

            If C3S->( MsSeek( xFilial("C3S") + "07" ) )             			
            	cIdCofins := C3S->C3S_ID
				aAdd( aMacro, "C35->(MsSeek(xFilial('C35') + C30->C30_CHVNF + C30->C30_NUMITE + C30->C30_CODITE + cIdCofins ) )" )
			Else
				aAdd( aMacro, ".F." )           			
			EndIf                 
			
			aAdd( aMacro, "C1O->(MsSeek(xFilial('C1O') + C30->C30_CTACTB ) )" )																
			
			LoadString( '1510' , aCmps , @cStrTxt , cAliasQry, lSeek, aMacro )
			
			aInfoGrv[5]++
			nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1500" )			
			           					           			
			If nRWStrTxt == -1
				Exit
			EndIf           
			
			TaFContBlc("1510",aTotReg1)				
			
			C30->(DbSkip())
		Enddo       					
	EndIf	        		
	 		
	( cAliasQry )->( dbSkip() )
End

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Bloco1600
Funcao responsavel processar o movimento especifico para montagem dos registros:
 1600 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Bloco1600( dDataIni , dDataFim , aCmps, aWizardBc )
Local 	cAliasQry 	:=  GetNextAlias()
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0
Local	cQuery		:=	''

cQuery	+=	"SELECT "
cQuery	+=		"C1H.C1H_CODPAR, SUM(C59.C59_TOTCRD) C59CRED , SUM(C59.C59_TOTDEB) C59DEB , C1H.C1H_FILIAL "
cQuery	+=	"FROM "
cQuery	+=		RetSqlName( 'C59' ) + " C59 "
cQuery	+=		"JOIN " + RetSqlName( 'C1H' ) + " C1H ON(C1H.C1H_FILIAL='" + xFilial('C1H') + "' AND C1H.C1H_ID=C59.C59_CODPAR AND C1H.D_E_L_E_T_=' ') "
cQuery	+=	"WHERE "
cQuery	+=		"C59.C59_FILIAL='" + xFilial('C59') + "' AND "
cQuery	+=		"C59.C59_PERIOD>='" + DToS( dDataIni ) + "' AND "
cQuery	+=		"C59.C59_PERIOD<='" + DToS( dDataFim ) + "' AND "
cQuery	+=		"C59.D_E_L_E_T_=' ' "
cQuery	+=		"GROUP BY   C1H.C1H_CODPAR, "
cQuery	+=		"C1H.C1H_FILIAL "
cQuery	+=	"ORDER BY "
cQuery	+=		"C1H_CODPAR "

cQuery	:=	ChangeQuery( cQuery )

dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

/*----------------------------------------------------------
Executando laco principal da rotina para gerar o registro 1600
----------------------------------------------------------*/
While !( cAliasQry )->( Eof() )   

	If !lGer1001
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( '1001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1001",aTotReg1)   
		
		aMacro	:=	{}
		aAdd( aMacro , Substr(aWizardBc[4][1],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][2],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][3],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][4],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][5],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][6],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][7],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][8],5,1) )							
		aAdd( aMacro , Substr(aWizardBc[4][9],5,1) )
			
		LoadString( '1010' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1010",aTotReg1)		  					
		
		lGer1001 := .T.		               
	EndIf
	
	LoadString( '1600' , aCmps , @cStrTxt , cAliasQry )
	
	aInfoGrv[5]++
	nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )
	
	TaFContBlc("1600",aTotReg1)	
 	
	If nRWStrTxt == -1
		Exit
	EndIf
	
	( cAliasQry )->( dbSkip() )
End

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Bloco1700
Funcao responsavel processar o movimento especifico para montagem dos registros:
 1700 e 1710 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Bloco1700( dDataIni , dDataFim , aCmps, aWizardBc )
Local 	cAliasQry 	:=  GetNextAlias()
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0
Local	cQuery		:=	''
Local	cChave		:=	''

cQuery	+=	"SELECT "
cQuery	+=		"C6C.C6C_CODIGO, "
cQuery	+=		"C01.C01_CODIGO, "
cQuery	+=		"C6V.C6V_SERDIS, "
cQuery	+=		"C6V.C6V_SSERDI, "
cQuery	+=		"C6V.C6V_NDIINI, "
cQuery	+=		"C6V.C6V_NDIFIN, "
cQuery	+=		"C0T.C0T_NUNAUT, "
cQuery	+=		"C20.C20_NUMDOC, "
cQuery	+=		"C02.C02_CODIGO "
cQuery	+=	"FROM "
cQuery	+=		RetSqlName( 'C0T' ) + " C0T "
cQuery	+=		"JOIN " + RetSqlName( 'C6C' ) + " C6C ON(C6C.C6C_FILIAL='" + xFilial('C6C') + "' AND C6C.C6C_ID=C0T.C0T_CODISP AND C6C.D_E_L_E_T_=' ') "
cQuery	+=		"JOIN " + RetSqlName( 'C6V' ) + " C6V ON(C6V.C6V_FILIAL=C0T.C0T_FILIAL AND C6V.C6V_ID=C0T.C0T_ID AND C6V.D_E_L_E_T_=' ') "
cQuery	+=		"JOIN " + RetSqlName( 'C01' ) + " C01 ON(C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=C6V.C6V_CODMOD AND C01.D_E_L_E_T_=' ') "
cQuery	+=		"LEFT JOIN " + RetSqlName( 'C20' ) + " C20 ON(C20.C20_FILIAL='" + xFilial('C20') + "' AND C20.C20_AIDF=C0T.C0T_ID AND C20.D_E_L_E_T_=' ') "
cQuery	+=		"LEFT JOIN " + RetSqlName( 'C02' ) + " C02 ON(C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID=C20.C20_CODSIT AND C02.D_E_L_E_T_=' ') "
cQuery	+=	"WHERE "
cQuery	+=		"C0T.C0T_FILIAL='" + xFilial('C0T') + "' AND "
cQuery	+=		"C0T.D_E_L_E_T_=' ' AND "
cQuery	+=		"EXISTS( SELECT C20_AIDF FROM " + RetSqlName( 'C20' ) + " C20 WHERE C20.C20_FILIAL='" + xFilial('C20') + "' AND " 
cQuery +=     "((C20.C20_INDOPE = '0' AND C20.C20_DTES BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "') OR "
cQuery +=     " (C20.C20_INDOPE = '1' AND C20.C20_DTDOC BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "')) AND "
cQuery +=     "C20.C20_AIDF=C0T.C0T_ID AND C20.C20_CODMOD=C6V.C6V_CODMOD AND C20.C20_SERIE=C6V.C6V_SERDIS AND C20.C20_SUBSER=C6V.C6V_SSERDI AND C20.C20_NUMDOC>=C6V.C6V_NDIINI AND C20.C20_NUMDOC<=C6V.C6V_NDIFIN AND C20.D_E_L_E_T_=' ') "
cQuery	+=	"ORDER BY "
cQuery	+=		"C6C_CODIGO, "
cQuery	+=		"C01_CODIGO, "
cQuery	+=		"C6V_SERDIS, "
cQuery	+=		"C6V_SSERDI, "
cQuery	+=		"C6V_NDIINI, "
cQuery	+=		"C6V_NDIFIN, "
cQuery	+=		"C0T_NUNAUT, "
cQuery	+=		"C20_NUMDOC "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

/*----------------------------------------------------------
Executando laco principal da rotina para gerar o registro 1700
----------------------------------------------------------*/
While !( cAliasQry )->( Eof() )  

	If !lGer1001
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( '1001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1001",aTotReg1)    
		
		aMacro	:=	{}
		aAdd( aMacro , Substr(aWizardBc[4][1],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][2],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][3],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][4],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][5],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][6],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][7],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][8],5,1) )							
		aAdd( aMacro , Substr(aWizardBc[4][9],5,1) )
			
		LoadString( '1010' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1010",aTotReg1)		  					
		
		lGer1001 := .T.		               
	EndIf
	
	LoadString( '1700' , aCmps , @cStrTxt , cAliasQry )
	
	aInfoGrv[5]++
	nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )     
	
	TaFContBlc("1700",aTotReg1)	
	
	/*----------------------------------------------------------
	Executando laco intermediario da rotina para gerar o registro 1710
	----------------------------------------------------------*/	
	If nRWStrTxt > 0
		cChave	:=	( cAliasQry )->( C6C_CODIGO + C01_CODIGO + C6V_SERDIS + C6V_SSERDI + C6V_NDIINI + C6V_NDIFIN + C0T_NUNAUT )
		While !( cAliasQry )->( Eof() ) .And. ;
			( cAliasQry )->( C6C_CODIGO + C01_CODIGO + C6V_SERDIS + C6V_SSERDI + C6V_NDIINI + C6V_NDIFIN + C0T_NUNAUT ) == cChave
                                                                                                                                   
			If C02_CODIGO == '02' .Or. C02_CODIGO == '05'	//CANCELADO OU INUTILIZADO
				LoadString( '1710' , aCmps , @cStrTxt , cAliasQry )
				
				aInfoGrv[5]++
				If ( nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) ) == -1
				
					TaFContBlc("1710",aTotReg1)
					
					Exit
				EndIf 
			EndIf

			( cAliasQry )->( dbSkip() )
		End	
 	EndIf
 	
	If nRWStrTxt == -1
		Exit
	EndIf 
End

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Bloco1800
Funcao responsavel processar o movimento especifico para montagem dos registros:
 1800 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Bloco1800( dDataIni , dDataFim ,  aCmps, aWizardBc )
Local 	cAliasQry 	:=  GetNextAlias()
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0
Local	cQuery		:=	''

cQuery	+=	"SELECT "
cQuery	+=		" * "
cQuery	+=	"FROM "
cQuery	+=		RetSqlName( 'C5H' ) + " C5H "
cQuery	+=	"WHERE "
cQuery	+=		"C5H.C5H_FILIAL='" + xFilial('C5H') + "' AND "
cQuery	+=		"C5H.C5H_PERIOD>='" + DToS( dDataIni ) + "' AND "
cQuery	+=		"C5H.C5H_PERIOD<='" + DToS( dDataFim ) + "' AND "
cQuery	+=		"C5H.D_E_L_E_T_=' ' "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

/*----------------------------------------------------------
Executando laco principal da rotina para gerar o registro 1800
----------------------------------------------------------*/
While !( cAliasQry )->( Eof() )     

	If !lGer1001
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( '1001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1001",aTotReg1) 
		
		aMacro	:=	{}
		aAdd( aMacro , Substr(aWizardBc[4][1],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][2],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][3],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][4],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][5],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][6],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][7],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][8],5,1) )							
		aAdd( aMacro , Substr(aWizardBc[4][9],5,1) )
			
		LoadString( '1010' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1010",aTotReg1)		  					
		
		lGer1001 := .T.		               
	EndIf
	
	LoadString( '1800' , aCmps , @cStrTxt , cAliasQry )
	
	aInfoGrv[5]++
	nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )
	
	TaFContBlc("1800",aTotReg1)	
 	
	If nRWStrTxt == -1
		Exit
	EndIf
	
	( cAliasQry )->( dbSkip() )
End

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Bloco1900
Funcao responsavel processar o movimento especifico para montagem dos registros:
 1900, 1910, 1920, 1921, 1922, 1923, 1925 e 1926 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Bloco1900( dDataIni , dDataFim ,  aCmps, aWizardBc )
Local 	cAliasQry 	:=  GetNextAlias()
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0
Local	cQuery		:=	''
Local	aMacro		:=	{}
Local	lSeek		:=	.F.

/*----------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
----------------------------------------------------------*/
C2T->( dbSetOrder( 1 ) )
C2U->( dbSetOrder( 1 ) )
C2V->( dbSetOrder( 1 ) )
C2X->( dbSetOrder( 1 ) )
C2Z->( dbSetOrder( 1 ) )
C1A->( dbSetOrder( 4 ) )
C0R->( dbSetOrder( 6 ) )
C1G->( dbSetOrder( 3 ) )
C3E->( dbSetOrder( 3 ) )
C1H->( dbSetOrder( 5 ) )
C1L->( dbSetOrder( 3 ) )

If(TAFAlsInDic("T58"))
	T58->( dbSetOrder( 1 ) )
EndIf

cQuery	+=	"SELECT "
cQuery	+=		"C2S.C2S_INDAPU, "
cQuery	+=		"C2S.C2S_DTINI, "
cQuery	+=		"C2S.C2S_DTFIN, "
cQuery	+=		"C2S.R_E_C_N_O_ "	//UTILIZO RECNO DEVIDO AO CAMPO MEMO DA TABELA
cQuery	+=	"FROM 
cQuery	+=		RetSqlName( 'C2S' ) + " C2S "
cQuery	+=	"WHERE 
cQuery	+=		"C2S.C2S_FILIAL='" + xFilial('C2S') + "' AND "
cQuery	+=		"C2S.C2S_TIPAPU='1' AND "
cQuery	+=		"C2S.C2S_DTINI>='" + DToS( dDataIni ) + "' AND "
cQuery	+=		"C2S.C2S_DTFIN<='" + DToS( dDataFim ) + "' AND "
cQuery	+=		"C2S.D_E_L_E_T_=' ' "
cQuery	+=	"ORDER BY "
cQuery	+=		"C2S_INDAPU, "
cQuery	+=		"C2S_DTINI, "
cQuery	+=		"C2S_DTFIN "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

/*----------------------------------------------------------
Executando laco principal da rotina para gerar o registro 1900
----------------------------------------------------------*/
While !( cAliasQry )->( Eof() )
	C2S->( dbGoTo( ( cAliasQry )->R_E_C_N_O_ ) )   
	
	If !lGer1001
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( '1001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1001",aTotReg1)   
		
		aMacro	:=	{}
		aAdd( aMacro , Substr(aWizardBc[4][1],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][2],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][3],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][4],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][5],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][6],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][7],5,1) )
		aAdd( aMacro , Substr(aWizardBc[4][8],5,1) )							
		aAdd( aMacro , Substr(aWizardBc[4][9],5,1) )
			
		LoadString( '1010' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("1010",aTotReg1)		  					
		
		lGer1001 := .T.		               
	EndIf	


	/*----------------------------------------------------------
	Gravacao do registro 1900 no arquivo texto
	----------------------------------------------------------*/	
	LoadString( '1900' , aCmps , @cStrTxt , 'C2S' )
	
	aInfoGrv[5]++
	If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) ) >= 0
	
		TaFContBlc("1900",aTotReg1)	

		/*----------------------------------------------------------
		Gravacao do registro 1910 no arquivo texto
		----------------------------------------------------------*/			
		LoadString( '1910' , aCmps , @cStrTxt , 'C2S' )
		
		aInfoGrv[5]++
		If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv,  "1900" ) ) >= 0
		
			TaFContBlc("1910",aTotReg1)		
	                            
			/*----------------------------------------------------------
			Gravacao do registro 1920 no arquivo texto
			----------------------------------------------------------*/	
			LoadString( '1920' , aCmps , @cStrTxt , 'C2S' )
			
			aInfoGrv[5]++
			If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1900" ) ) >= 0 
			
				TaFContBlc("1920",aTotReg1)		

				/*----------------------------------------------------------
				Executando laco para gerar o registro 1921
				----------------------------------------------------------*/					
				If C2T->( msSeek( xFilial( 'C2T' ) + C2S->C2S_ID ) )
					While !C2T->( Eof() ) .And. C2T->( C2T_FILIAL + C2T_ID ) == xFilial( 'C2T' ) + C2S->C2S_ID
					
						lSeek	:=	C1A->( msSeek( xFilial( 'C1A' ) + C2T->C2T_CODAJU ) )

						/*----------------------------------------------------------
						Gravacao do registro 1921 no arquivo texto
						----------------------------------------------------------*/
						LoadString( '1921' , aCmps , @cStrTxt , 'C2T' , lSeek )
						
						aInfoGrv[5]++
						nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1900" )
						
						TaFContBlc("1921",aTotReg1)						
                                
						/*----------------------------------------------------------
						Executando laco para gerar o registro 1922
						----------------------------------------------------------*/
						If nRWStrTxt >= 0 .And. C2U->( msSeek( xFilial( 'C2U' ) + C2T->( C2T_ID + C2T_CODAJU ) ) )
							While !C2U->( Eof() ) .And. C2U->( C2U_FILIAL + C2U_ID + C2U_CODAJU ) == xFilial( 'C2U' ) + C2T->( C2T_ID + C2T_CODAJU )
							    
							    aMacro	:=	{ "", "", "" }
							    if C0R->( msSeek( xFilial( 'C0R' ) + C2U->C2U_DOCARR ) )
							    	
							    	if C1G->( msSeek( xFilial( 'C1G' ) + C0R->C0R_NRPROC ) )
										
										aMacro[1] :=  C1G->C1G_NUMPRO 
							    		aMacro[2] := C1G->C1G_INDPRO 
							    		aMacro[3] := C1G->C1G_DESCRI 
							    		
							    	endif
							    
							    Elseif C1G->( msSeek( xFilial( 'C1G' ) + C2U->C2U_NRPROC ) )
							    
							    	aMacro[1] := C1G->C1G_NUMPRO
							    	aMacro[2] := C1G->C1G_INDPRO 
							    	aMacro[3] := C1G->C1G_DESCRI 
							    							    
							    endif							    								    
							
								LoadString( '1922' , aCmps , @cStrTxt , 'C0R' , , aMacro )
								
								aInfoGrv[5]++
								nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1900" )
								
								TaFContBlc("1922",aTotReg1)								
						
								If nRWStrTxt == -1
									Exit
								EndIf						
		
								C2U->( dbSkip() )
							End
						EndIf						
						 
						/*----------------------------------------------------------
						Executando laco para gerar o registro 1923
						----------------------------------------------------------*/
						If nRWStrTxt >= 0 .And. C2V->( msSeek( xFilial( 'C2V' ) + C2T->( C2T_ID + C2T_CODAJU ) ) )
							While !C2V->( Eof() ) .And. C2V->( C2V_FILIAL + C2V_ID + C2V_CODAJU ) == xFilial( 'C2V' ) + C2T->( C2T_ID + C2T_CODAJU )
							
							    aMacro	:=	{}
								aAdd( aMacro , "C1H->( msSeek( xFilial( 'C1H' ) + C2V->C2V_CODPAR ) )" )
								aAdd( aMacro , "C01->( msSeek( xFilial( 'C01' ) + C2V->C2V_CODMOD ) )" )
								aAdd( aMacro , "C1L->( msSeek( xFilial( 'C1L' ) + C2V->C2V_CODITE ) )" )
							
								LoadString( '1923' , aCmps , @cStrTxt , 'C2V' , , aMacro )
								
								aInfoGrv[5]++
								nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1900" )
								
								TaFContBlc("1923",aTotReg1)								
						
								If nRWStrTxt == -1
									Exit
								EndIf						
		
								C2V->( dbSkip() )
							End
						EndIf

						If nRWStrTxt == -1
							Exit
						EndIf						

						C2T->( dbSkip() )
					End
				EndIf
				
				/*----------------------------------------------------------
				Executando laco para gerar o registro 1925
				----------------------------------------------------------*/					
				If nRWStrTxt >= 0 .And. C2X->( msSeek( xFilial( 'C2X' ) + C2S->C2S_ID ) )
					While !C2X->( Eof() ) .And. C2X->( C2X_FILIAL + C2X_ID ) == xFilial( 'C2X' ) + C2S->C2S_ID
					
						aMacro	:=	{}

						If TAFAlsInDic("T58") 						    
							aAdd( aMacro , "T58->( msSeek( xFilial( 'T58' ) + C2X->C2X_INFADC ) )" )
						else
							aAdd( aMacro , "" )
						endif
																						
						LoadString( '1925' , aCmps , @cStrTxt , 'C2X' , , aMacro )
						
						aInfoGrv[5]++
						If( nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1900" ) ) == -1
							Exit
						EndIf					          
						
						TaFContBlc("1925",aTotReg1)						
					
						C2X->( dbSkip() )
					End
				EndIf
				
				/*----------------------------------------------------------
				Executando laco para gerar o registro 1926
				----------------------------------------------------------*/					
				If nRWStrTxt >= 0 .And. C2Z->( msSeek( xFilial( 'C2Z' ) + C2S->C2S_ID ) )
					While !C2Z->( Eof() ) .And. C2Z->( C2Z_FILIAL + C2Z_ID ) == xFilial( 'C2Z' ) + C2S->C2S_ID
					
						aMacro	:=	{ "", "", "", "", "" }
						if C0R->( msSeek( xFilial( 'C0R' ) + C2Z->C2Z_DOCARR ) )
					
							if C1G->( msSeek( xFilial( 'C1G' ) + C0R->C0R_NRPROC ) )
						    	
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
																			
						LoadString( '1926' , aCmps , @cStrTxt , 'C0R' , , aMacro )
						
						aInfoGrv[5]++
						If( nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "1900" ) ) == -1							
							Exit
						EndIf					
						
						TaFContBlc("1926",aTotReg1)

						C2Z->( dbSkip() )
					End
				EndIf
			EndIf
		EndIf
	EndIf
 	
	If nRWStrTxt == -1
		Exit
	EndIf
	
	( cAliasQry )->( dbSkip() )
End

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} DistrCmps
Funcao responsavel por definir um depara do layout do fisco para a tabela do TAF,
	os campos armazenados no array serao utilizados na gravacao como macro execucao

@return aRet - Array com os campos por registros

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DistrCmps
Local	aRet	:=	{}
Local	nI		:=	1

//ESTRUTURA DO REGISTRO 1001
nI	:=	1
aAdd( aRet , { '1001' , Array( 01 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }

//ESTRUTURA DO REGISTRO 1010
nI	:=	1
aAdd( aRet , { '1010' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 4 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 5 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 6 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 7 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 8 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 9 ] }

//ESTRUTURA DO REGISTRO 1100
nI	:=	1
aAdd( aRet , { '1100' , Array( 11 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4F_INDDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4F_NRODE }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C4F_DTDE ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4F_NATEXP }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4F_NRORE }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C4F_DTRE ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4F_CHCEMB }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C4F_DTCHC ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C4F_DTAVB ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &(aMacro[ 1 ]) , C0S->C0S_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &(aMacro[ 2 ]) , C08->C08_PAISSX , '' ) }

//ESTRUTURA DO REGISTRO 1105
nI	:=	1
aAdd( aRet , { '1105' , Array( 06 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &(aMacro[ 1 ]) , C01->C01_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4G_SERIE }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4G_NUMDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4G_CHVNFE }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C4G_DTDOC ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &(aMacro[ 2 ]) , xGerBlc0( "0200",  Alltrim( C1L->(C1L_CODIGO) ), cFilSelBc, aWizardBc, cTabSpd) , '' ) }
			

//ESTRUTURA DO REGISTRO 1110
nI	:=	1
aAdd( aRet , { '1110' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &(aMacro[ 1 ]) , xGerBlc0( "0150",  C1H->(C1H_CODPAR), cFilSelBc, aWizardBc, cTabSpd ), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &(aMacro[ 2 ]) , C01->C01_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4H_SERIE }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4H_NUMDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C4H_DTDOC ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4H_CHVNFE }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4H_NRMEMO }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4H_QTD , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &(aMacro[ 3 ]) , xGerBlc0( "0190",  C1J->(C1J_CODIGO), cFilSelBc, aWizardBc, cTabSpd ) , '' ) }

//ESTRUTURA DO REGISTRO 1200
nI	:=	1
aAdd( aRet , { '1200' , Array( 06 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C1A_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C50_SLDCRD , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C50_CRDAPR , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C50_CRDREC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C50_CRDUTI , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C50_SDCRFI , 16 , 2 ) }

//ESTRUTURA DO REGISTRO 1210
nI	:=	1
aAdd( aRet , { '1210' , Array( 04 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4Z_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C51_NRODOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C51_CRUTIL , 16 , 2 ) }
If TAFColumnPos( "C51_CHVELE" )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C51_CHVELE }
EndIf

//ESTRUTURA DO REGISTRO 1300
nI	:=	1
aAdd( aRet , { '1300' , Array( 10 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| xGerBlc0( "0200",  Alltrim( C1L_CODIGO ), cFilSelBc, aWizardBc, cTabSpd ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C4N_DTFECH ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4N_ESTQAB , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4N_VOLENT , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4N_VOLDIS , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4N_VOLSAI , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4N_ESTQES , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4N_VAJPER , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4N_VAJGAN , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4N_FECHFI , 16 , 3 ) }

//ESTRUTURA DO REGISTRO 1310
nI	:=	1
aAdd( aRet , { '1310' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4O_NUMTAN }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4O_ESTQAB , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4O_VOLENT , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4O_VOLDIS , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4O_VOLSAI , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4O_ESTQES , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4O_VAJPER , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4O_VAJGAN , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4O_FECHFI , 16 , 3 ) }

//ESTRUTURA DO REGISTRO 1320
nI	:=	1
aAdd( aRet , { '1320' , Array( 10 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4P_NUMBIC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4P_NUMINT }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4P_MOTINT }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4P_NOMINT }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4P_CNPJ }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C4P_CPF }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4P_VFECHA , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4P_VABERT , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4P_VOLAFE , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4P_VOLVEN , 16 , 3 ) }

//ESTRUTURA DO REGISTRO 1350
nI	:=	1
aAdd( aRet , { '1350' , Array( 04 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C55_SERIE }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C55_FABRIC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C55_MODELO }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C55_TPMEDI }

//ESTRUTURA DO REGISTRO 1360
nI	:=	1
aAdd( aRet , { '1360' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C56_NMLACR }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C56_DTAPLI ) }

//ESTRUTURA DO REGISTRO 1370
nI	:=	1
aAdd( aRet , { '1370' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C57_NMBICO }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( lSeek , xGerBlc0( "0200",  Alltrim( C1L->C1L_CODIGO ), cFilSelBc, aWizardBc, cTabSpd ), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C57_NMTANQ }

//ESTRUTURA DO REGISTRO 1390
nI	:=	1
aAdd( aRet , { '1390' , Array( 01 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C6N_CODPRO }

//ESTRUTURA DO REGISTRO 1391
nI	:=	1
aAdd( aRet , { '1391' , Array( 16 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C6N_DTPRD ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_QTDCES , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_ESTINI , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_QTDPRO , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_EALCAN , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_OUTENT , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_PERDA , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_CONSUM , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_SDTRAN , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_SAIDAS , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_ESTFIN , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_EINMEL , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_PRDMEL , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_MELUTL , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C6N_PRDALC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C6N_OBSERV }

//ESTRUTURA DO REGISTRO 1400
nI	:=	1
aAdd( aRet , { '1400' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( Empty(LF0_CODIGO), xGerBlc0( "0200",  Alltrim( C1L_CODIGO ), cFilSelBc, aWizardBc, cTabSpd ), ALLTRIM(LF0_CODIGO) ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C09_CODIGO + C07_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C4X_VALOR , 16 , 2 ) }

//ESTRUTURA DO REGISTRO 1500
nI	:=	1
aAdd( aRet , { '1500' , Array( 26 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C20_INDEMI }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| xGerBlc0( "0150",  C1H_CODPAR, cFilSelBc, aWizardBc, cTabSpd ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C01_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C02_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C20_SERIE  }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C20_SUBSER }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( lSeek , C0L->C0L_CODIGO , "" ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C20_NUMDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C20_DTDOC ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C20_DTES ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C20_VLDOC, 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C20_VLDESC, 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( Iif( lSeek , C2E->C2E_VLFORN, 0 ), 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( Iif( lSeek , C2E->C2E_VSERNT, 0 ), 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( Iif( lSeek , C2E->C2E_VLTERC, 0 ), 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C20_VLRDA, 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( BCICMS, 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( VLICMS, 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( BCICMSST, 16, 2  ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( VLICMSST, 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &(aMacro[2]) , xGerBlc0( "0450",  Alltrim( C3Q->( C3Q_CODINF ) ), cFilSelBc, aWizardBc, cTabSpd ), "" ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( VLPIS, 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( VLCOFINS, 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( lSeek , C2E->C2E_TPLIG, "" ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( lSeek , C0N->C0N_CODIGO, "" ) } 

//ESTRUTURA DO REGISTRO 1510
nI	:=	1
aAdd( aRet , { '1510' , Array( 20 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C30->C30_NUMITE }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , xGerBlc0( "0200",  Alltrim( C1L->(C1L_CODIGO) ), cFilSelBc, aWizardBc, cTabSpd ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif ( lSeek, Iif( &( aMacro[ 2 ] ) , C0K->C0K_CODIGO , '' ), "" ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C30->C30_QUANT, 16, 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 3 ] ) , xGerBlc0( "0190",  C1J->(C1J_CODIGO), cFilSelBc, aWizardBc, cTabSpd ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C30->C30_VLRITE, 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C30->C30_VLDESC, 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 4 ] ) , C03->C03_CODIGO , '' ) + Iif( &( aMacro[ 5 ] ) , C14->C14_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 6 ] ) , C0Y->C0Y_CODIGO , '' ) } 
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( Iif( &( aMacro[ 7 ] ) , C35->C35_BASE , 0 ), 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( Iif( &( aMacro[ 8 ] ) , C35->C35_ALIQ , 0 ), 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( Iif( &( aMacro[ 9 ] ) , C35->C35_VALOR , 0 ), 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( Iif( &( aMacro[ 10 ] ) , C35->C35_BASE , 0 ), 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( Iif( &( aMacro[ 11 ] ) , C35->C35_ALIQ , 0 ), 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( Iif( &( aMacro[ 12 ] ) , C35->C35_VALOR , 0 ), 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif ( lSeek, C32->C32_INDREC , "" ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 13 ] ) , xGerBlc0( "0150",  C1H->(C1H_CODPAR), cFilSelBc, aWizardBc, cTabSpd ) , "" )  }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( Iif( &( aMacro[ 14 ] ) , C35->C35_VALOR , 0 ), 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( Iif( &( aMacro[ 15 ] ) , C35->C35_VALOR , 0 ), 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 16 ] ) , xGerBlc0( "0500",  Alltrim( C1O->(C1O_CODIGO) ), cFilSelBc, aWizardBc, cTabSpd), "" )  }

//ESTRUTURA DO REGISTRO 1600
nI	:=	1
aAdd( aRet , { '1600' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| xGerBlc0( "0150",  C1H_CODPAR, cFilSelBc, aWizardBc, cTabSpd ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C59CRED , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C59DEB , 16 , 2 ) }

//ESTRUTURA DO REGISTRO 1700
nI	:=	1
aAdd( aRet , { '1700' , Array( 07 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C6C_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C01_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C6V_SERDIS }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C6V_SSERDI }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C6V_NDIINI }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C6V_NDIFIN }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C0T_NUNAUT }

//ESTRUTURA DO REGISTRO 1710
nI	:=	1
aAdd( aRet , { '1710' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C20_NUMDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C20_NUMDOC }

//ESTRUTURA DO REGISTRO 1800
nI	:=	1
aAdd( aRet , { '1800' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5H_VCARGA , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5H_VLPASS , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5H_VLFATU , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5H_INDRAT , 16 , 6 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5H_VICANT , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5H_VBCICM , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5H_VICMAP , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5H_VBICAP , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C5H_VDIFER , 16 , 2 ) }

//ESTRUTURA DO REGISTRO 1900
nI	:=	1
aAdd( aRet , { '1900' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2S_INDAPU }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2S_DSCCOM }

//ESTRUTURA DO REGISTRO 1910
nI	:=	1
aAdd( aRet , { '1910' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C2S_DTINI ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C2S_DTFIN ) }

//ESTRUTURA DO REGISTRO 1920
nI	:=	1
aAdd( aRet , { '1920' , Array( 12 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_TOTDEB , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_TAJUDB , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_ESTCRE , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_TOTCRE , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_TAJUCR , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_ESTDEB , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_CREANT , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_SDOAPU , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_TOTDED , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_TOTREC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_CRESEG , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2S_DEBESP , 16 , 2 ) }

//ESTRUTURA DO REGISTRO 1921
nI	:=	1
aAdd( aRet , { '1921' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( lSeek , C1A->C1A_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2T_AJUCOM }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2T_VLRAJU , 16 , 2 ) }

//ESTRUTURA DO REGISTRO 1922
nI	:=	1
aAdd( aRet , { '1922' , Array( 05 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C0R->C0R_NUMDA }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| StrTran(C0R->C0R_DESDOC, CRLF, " ") }

//ESTRUTURA DO REGISTRO 1923
nI	:=	1
aAdd( aRet , { '1923' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , xGerBlc0( "0150",  C1H->C1H_CODPAR, cFilSelBc, aWizardBc, cTabSpd ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 2 ] ) , C01->C01_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2V_SERDOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2V_SUBSER }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2V_NRODOC }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C2V_DTDOC ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 2 ] ) , xGerBlc0( "0200",  Alltrim( Posicione( "C1L", 3, xFilial("C1L") + C2V->C2V_CODITE, "C1L_CODIGO" ) ), cFilSelBc, aWizardBc, cTabSpd ), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2V_VLRAJU , 16 , 2 ) }
If TAFColumnPos( "C2V_CHVELE" )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2V_CHVELE }
EndIf

//ESTRUTURA DO REGISTRO 1925
nI	:=	1
aAdd( aRet , { '1925' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 1 ] ) , T58->T58_CODIGO , '' )}
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C2X_VLRINF , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C2X_DSCCOM }

//ESTRUTURA DO REGISTRO 1926
nI	:=	1
aAdd( aRet , { '1926' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 4 ] ) , C3E->C3E_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( C0R->C0R_VLDA , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract( C0R->C0R_DTVCT ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Iif( &( aMacro[ 5 ] ) , C6R->C6R_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| StrTran(C0R->C0R_DESDOC, CRLF, " ") }
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| C0R->C0R_PERIOD }

//ESTRUTURA DO REGISTRO 1990
nI	:=	1
aAdd( aRet , { '1990' , Array( 1 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( aMacro[ 1 ], 16, 0 ) }

Return ( aRet ) 
