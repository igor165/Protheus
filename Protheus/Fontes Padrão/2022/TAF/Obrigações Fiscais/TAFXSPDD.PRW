#Include 'Protheus.ch'

Function TafxSpdD( aWizard, cFilSel , lConv115 , cPerfilSPD, cTabSped , cJobAux )
						
Local  cTxtSys	:= 	CriaTrab(,.F.)+".TXT"
Local	cFilBkp	:=	cFilAnt	//Bakup da filial antes do inicio do processamento
Local	aRegD600	:=	{}
Local	aRegD610	:=	{}
Local	aRegD690	:=	{}
Local	nI			:=	0 
Local  nlI        :=  0
Local  nTotReg    :=  1
Local	lSave		:=	.F. 
Local	aCmps		:=	DistrCmps() 
Local	cStrTxt	:=	''
Local  aMacro     := {}   

Local  aFilSel    := Separa( StrTran( cFilSel, "'", "" ), "," )

Local  dDataIni   := aWizard[1][1]
Local  dDataFim   := aWizard[1][2]

Local  cD300Conso := aWizard[6][1] //Verifica se gera o D300 consolidado (0 - Sim ou 1 - Não)

Local lFound := .T.
Local oError := ErrorBlock( { |Obj| Conout( "Mensagem de Erro: " + Chr(10)+ Obj:Description + Chr(10)+ Obj:ErrorStack ) } )       

Private aTotRegD   := {}      
Private lGerD001   := .F.    
Private aInfoGrv   := {}    

//Deve ser private para geracao dos registros do bloco 0 gerados durante
//o processamento dos movimentos
Private aWizardBc  := aWizard
Private cFilSelBc  := cFilSel
Private cTabSpd    := cTabSped       
Private lLayout12  := iif(aWizard[1][5] >= "012", .T. , .F.)  

Default dDataIni	:=	SToD( '20120101' )
Default dDataFim	:=	SToD( '20131231' )
Default aFilSel	:=	{{.T.,cFilAnt}}
Default lConv115	:=	.t.	//Flag de Empresa obrigada ao Convenio 115/03.
Default cJobAux   := ""

//Tratamento para que caso ocorra Erro durante o processamento não estoure na tela
//é exibida uma mensagem tratada do erro para o usuário final
Begin Sequence

	//No caso do Sped Fiscal apenas pode ser gerada uma filial por processamento, sendo assim, antes de iniciar a execução dos blocos
	//eu seto a filial onde ocorrera o processamento
	//cFilAnt := Substr( cFilSelBc, 2, 2 ) 
	
	//Array com as informações a serem geradas na tabela compartilhada
	//Filial + Data Inicio + Data Final + Bloco + Sequencializador
	aInfoGrv := { cFilAnt , DToS( aWizardBc[1,1] ), DToS( aWizardBc[1,2] ), "D", 0 }
	
	//D100,D101,D110,D120,D130,D140,D150,D160,D161,D162,D170,D180,D190,D195,D197
	BlocoD100( dDataIni , dDataFim , cPerfilSPD)
	       
	//D300,D301,D310
	BlocoD300( dDataIni , dDataFim, cD300Conso )
	
	//D350,D355,D360,D365,D370,D390
	BlocoD350( dDataIni , dDataFim , cPerfilSPD )
	
	//D400,D410,D411,D420
	BlocoD400( dDataIni , dDataFim  )
	
	//D500,D510,D530,D590,D600,D610,D690
	BlocoD500( dDataIni , dDataFim , @aRegD600 , @aRegD610 , @aRegD690 , cPerfilSPD, lConv115 )
	
	If !lConv115	
		
		//Foi consolidado para as empresas na chamada anterior, nesta nao preciso processar novamente, soh ler o array gerado.
		BlocoD600(  aRegD600 , aRegD610 , aRegD690, cPerfilSPD  )
	Else
	
		//D695,D696,D697
		BlocoD695( dDataIni, dDataFim, cPerfilSPD  )
	EndIf  
	
	/*----------------------------------------------------------------------
	Caso nao tenha sido gerado o registro D001 ( Pois nao Houve Movimento )
	realizao a sua emissao agora
	-----------------------------------------------------------------------*/	
	If !lGerD001	
		aMacro	:=	{}
		aAdd( aMacro , "1" )
		
		cStrTxt := ""
		LoadString( 'D001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("D001",aTotRegD) 
			               
	EndIf   
	
	For nlI := 1 To Len( aTotRegD )
		nTotReg += aTotRegD[nlI][2]
	Next           
	
	aMacro	:=	{}
	aAdd( aMacro , nTotReg )
	
	Reg990Spd( "D", cTabSped, cFilSel, aWizard )
	 
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
	xTafCtlObr( "2", "D", aWizardBc, cFilSelBc, , "TAFGERCTL", "SPEDFIS" )	
EndIf

Return ( Nil )
//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoD100
Funcao responsavel processar o movimento especifico para montagem dos registros:
 D100,D110,D120,D130,D140,D150,D160,D161,D162,D170,D180,D190,D195,D197 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlocoD100( dDataIni , dDataFim , cPerfilSPD ) 
Local	cQuery		:=	''
Local 	cAliasQry 	:=  GetNextAlias()
Local	aCmps		:=	DistrCmps(lLayout12)
Local	cModelo		:=	''
Local	cChvNF		:=	''
Local	cChvAux		:=	''
Local	cStrTxt		:=	''
Local	cStrTxt2	:=	''
Local	cStrTxt3	:=	''
Local	nRWStrTxt	:=	0
Local	lObs		:=	.F.
Local	aC190		:=	{}
Local	nPosC190	:=	0
Local cChvOld		:= ""
Local cIdOrig		:= "000020" //ID. do Tributo de ICMS Complementar (DIFAL) - UF ORIGEM   
Local cIdDest		:= "000021" //ID. do Tributo de ICMS Complementar (DIFAL) - UF DESTINO
Local cIdFecp		:= "000022" //ID. do Tributo de FECP UF DE DESTINO

Private	lSeek	:=	.F.
Private	aMacro	:=	{}

/*----------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
----------------------------------------------------------*/
C21->( dbSetOrder( 1 ) )
C3Q->( dbSetOrder( 3 ) )
C39->( dbSetOrder( 1 ) )
C09->( dbSetOrder( 3 ) )
C07->( dbSetOrder( 3 ) )
C1H->( dbSetOrder( 5 ) )
C3I->( dbSetOrder( 1 ) )
C3F->( dbSetOrder( 1 ) )
C3A->( dbSetOrder( 1 ) )
C0Q->( dbSetOrder( 4 ) )
C01->( dbSetOrder( 3 ) )
C24->( dbSetOrder( 1 ) )
C2C->( dbSetOrder( 1 ) )
C2D->( dbSetOrder( 1 ) )
C3R->( dbSetOrder( 3 ) )
C35->( dbSetOrder( 1 ) )
C3S->( dbSetOrder( 3 ) )
C0Y->( dbSetOrder( 3 ) )
C14->( dbSetOrder( 3 ) )
C0J->( dbSetOrder( 3 ) )
C1L->( dbSetOrder( 3 ) )

/*----------------------------------------------------------
Query principal do movimento para gerar os registro D100, 
	D110, D120, D130, D140, D150, D160, D161, D162, D170 e D180
----------------------------------------------------------*/ 
cQuery	+=	"SELECT "
cQuery	+=	"D100.C20_FILIAL, "
cQuery	+=	"D100.C20_CHVNF, "
cQuery	+=	"D100.C20_INDOPE, " 
cQuery	+=	"D100.C20_INDEMI, "
cQuery	+=  "C1H.C1H_FILIAL, "	
cQuery	+=	"C1H.C1H_CODPAR, "
cQuery	+=	"C01.C01_CODIGO, " 
cQuery	+=	"C02.C02_CODIGO, "
cQuery	+=	"D100.C20_SERIE, "
cQuery	+=	"D100.C20_SUBSER, " 
cQuery	+=	"D100.C20_NUMDOC, " 
cQuery	+=	"D100.C20_CHVELE, "
cQuery	+=	"D100.C20_DTDOC, "
cQuery	+=	"D100.C20_DTES, "
cQuery	+=	"D100.C20_TPCTE, "
cQuery	+=	"D100.C20_CHVREF, "
cQuery	+=	"D100.C20_VLDOC, "
cQuery	+=	"D100.C20_VLDESC, "
cQuery	+=	"D100.C20_INDFRT, "
cQuery	+=	"D100.C20_INDOPE, "
If TAFColumnPos( "C20_CODORI")
	cQuery	+=	"D100.C20_CODORI, "
Endif
If TAFColumnPos( "C20_CODDES")
	cQuery	+=	"D100.C20_CODDES, "
Endif
cQuery	+=	"C1O.C1O_CODIGO, "
cQuery	+=	"D110.C30_NUMITE, "
cQuery	+=	"D110.C30_CODITE, "
cQuery	+=	"C1L.C1L_FILIAL, "
cQuery	+=	"C1L.C1L_CODIGO, "
cQuery	+=	"D110.C30_TOTAL, "
cQuery	+=	"D110.C30_VLOUTR, "
cQuery	+=	"(SELECT SUM(TRIB.C35_BASE) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='02' AND TRIB.C35_FILIAL=D110.C30_FILIAL AND TRIB.C35_CHVNF=D110.C30_CHVNF AND TRIB.D_E_L_E_T_=' ') BCICMS, "
cQuery	+=	"(SELECT SUM(TRIB.C35_VALOR) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='02' AND TRIB.C35_FILIAL=D110.C30_FILIAL AND TRIB.C35_CHVNF=D110.C30_CHVNF AND TRIB.D_E_L_E_T_=' ') VLICMS, "
cQuery	+=	"(SELECT SUM(TRIB.C35_VLNT) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='02' AND TRIB.C35_FILIAL=D110.C30_FILIAL AND TRIB.C35_CHVNF=D110.C30_CHVNF AND TRIB.D_E_L_E_T_=' ') VLNT, "
cQuery	+=	"(SELECT C09_CODIGO FROM " + RetSqlName( 'C09' ) + " C09 WHERE C09.C09_FILIAL='" + xFilial('C09') + "' AND D140.C3G_UFORIG=C09.C09_ID AND C09.D_E_L_E_T_=' ') D140UFORI, "
cQuery	+=	"(SELECT C07_CODIGO FROM " + RetSqlName( 'C07' ) + " C07 WHERE C07.C07_FILIAL='" + xFilial('C07') + "' AND D140.C3G_CMUNOR=C07.C07_ID AND C07.D_E_L_E_T_=' ') D140MUNORI, "
cQuery	+=	"(SELECT C09_CODIGO FROM " + RetSqlName( 'C09' ) + " C09 WHERE C09.C09_FILIAL='" + xFilial('C09') + "' AND D140.C3G_UFDEST=C09.C09_ID AND C09.D_E_L_E_T_=' ') D140UFDES, "
cQuery	+=	"(SELECT C07_CODIGO FROM " + RetSqlName( 'C07' ) + " C07 WHERE C07.C07_FILIAL='" + xFilial('C07') + "' AND D140.C3G_CMUNDE=C07.C07_ID AND C07.D_E_L_E_T_=' ') D140MUNDES, "
cQuery	+=	"VEICD140.C0Q_TPVEIC, " 
cQuery	+=	"VEICD140.C0Q_CHASSI IDNAV, " 
cQuery	+=	"VEICD140.C0Q_TPNAV, " 
cQuery	+=	"D140.C3G_CPARCO, " 
cQuery	+=	"D140.C3G_VIAGEM, " 
cQuery	+=	"D140.C3G_VLIQFR, "
cQuery	+=	"D140.C3G_VDEPOR, "
cQuery	+=	"D140.C3G_VDESCD, " 
cQuery	+=	"D140.C3G_VOUTRO, " 
cQuery	+=	"D140.C3G_VBRTFR, " 
cQuery	+=	"D140.C3G_VADMM, "
cQuery	+=	"(SELECT C09_CODIGO FROM " + RetSqlName( 'C09' ) + " C09 WHERE C09.C09_FILIAL='" + xFilial('C09') + "' AND D150.C3H_UFORIG=C09.C09_ID AND C09.D_E_L_E_T_=' ') D150UFORI, "
cQuery	+=	"(SELECT C07_CODIGO FROM " + RetSqlName( 'C07' ) + " C07 WHERE C07.C07_FILIAL='" + xFilial('C07') + "' AND D150.C3H_CMUNOR=C07.C07_ID AND C07.D_E_L_E_T_=' ') D150MUNORI, "
cQuery	+=	"(SELECT C09_CODIGO FROM " + RetSqlName( 'C09' ) + " C09 WHERE C09.C09_FILIAL='" + xFilial('C09') + "' AND D150.C3H_UFDEST=C09.C09_ID AND C09.D_E_L_E_T_=' ') D150UFDES, "
cQuery	+=	"(SELECT C07_CODIGO FROM " + RetSqlName( 'C07' ) + " C07 WHERE C07.C07_FILIAL='" + xFilial('C07') + "' AND D150.C3H_CMUNDE=C07.C07_ID AND C07.D_E_L_E_T_=' ') D150MUNDES, "
cQuery	+=	"VEICD150.C0Q_CHASSI IDAEREO, "
cQuery	+=	"D150.C3H_VIAGEM, " 
cQuery	+=	"D150.C3H_INDTAR, " 
cQuery	+=	"D150.C3H_PESOTX, " 
cQuery	+=	"D150.C3H_VTXTER, " 
cQuery	+=	"D150.C3H_VTXRED, " 
cQuery	+=	"D150.C3H_VOUTRO, " 
cQuery	+=	"D150.C3H_VTXAD, "
cQuery  +=  "C0X.C0X_CODIGO "
cQuery	+=	"FROM " + RetSqlName( "C20" ) + " D100 " 
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C01' ) + " C01 ON(C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=D100.C20_CODMOD AND C01.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0X' ) + " C0X ON(C0X.C0X_FILIAL='" + xFilial('C0X') + "' AND C0X.C0X_ID=D100.C20_INDFRT AND C0X.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C02' ) + " C02 ON(C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID=D100.C20_CODSIT AND C02.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1H' ) + " C1H ON(C1H.C1H_FILIAL='" + xFilial('C1H') + "' AND C1H.C1H_ID=D100.C20_CODPAR AND C1H.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1O' ) + " C1O ON(C1O.C1O_FILIAL='" + xFilial('C1O') + "' AND C1O.C1O_ID=D100.C20_CODCTA AND C1O.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C3G' ) + " D140 ON(D140.C3G_FILIAL=D100.C20_FILIAL AND D140.C3G_CHVNF=D100.C20_CHVNF AND D140.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0Q' ) + " VEICD140 ON(VEICD140.C0Q_FILIAL='" + xFilial('C0Q') + "' AND D140.C3G_CODVEI=VEICD140.C0Q_ID AND VEICD140.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C3H' ) + " D150 ON(D150.C3H_FILIAL=D100.C20_FILIAL AND D150.C3H_CHVNF=D100.C20_CHVNF AND D150.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0Q' ) + " VEICD150 ON(VEICD150.C0Q_FILIAL='" + xFilial('C0Q') + "' AND D150.C3H_CODVEI=VEICD150.C0Q_ID AND VEICD150.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C30' ) + " D110 ON(D110.C30_FILIAL=D100.C20_FILIAL AND D110.C30_CHVNF=D100.C20_CHVNF AND D110.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1L' ) + " C1L ON(C1L.C1L_FILIAL='" + xFilial('C1L') + "' AND C1L.C1L_ID=D110.C30_CODITE AND C1L.D_E_L_E_T_=' ') "
cQuery	+=	"WHERE " 	
cQuery	+=	"D100.C20_FILIAL='" + xFilial('C20') + "' AND " 
cQuery += "((D100.C20_INDOPE = '0' AND D100.C20_DTES  >= '" + DTOS(dDataIni) + "' AND D100.C20_DTES <='"  + DTOS(dDataFim) + "') OR "
cQuery += " (D100.C20_INDOPE = '1' AND D100.C20_DTDOC >= '" + DTOS(dDataIni) + "' AND D100.C20_DTDOC <='" + DTOS(dDataFim) + "')) AND "
cQuery	+=	"D100.D_E_L_E_T_=' ' AND " 
cQuery	+=	"(C01.C01_CODIGO='07' OR C01.C01_CODIGO='08' OR C01.C01_CODIGO='8B' OR C01.C01_CODIGO='09' OR C01.C01_CODIGO='10' OR C01.C01_CODIGO='11' OR C01.C01_CODIGO='26' OR C01.C01_CODIGO='27' OR C01.C01_CODIGO='57' OR C01.C01_CODIGO='63' OR C01.C01_CODIGO='67') "
cQuery	+=	" ORDER BY D100.C20_INDOPE, C20_DTDOC, C20_CHVNF " 

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

TcSetField( cAliasQry , "C20_DTDOC" , "D" , 8 , 0 )
TcSetField( cAliasQry , "C20_DTES"  , "D" , 8 , 0 )

//LACO DO DOCUMENTO
While ( cAliasQry )->( !Eof() )
                      
    aC190		:=	{}
    If !lGerD001
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( 'D001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )		
		
		TaFContBlc("D001",aTotRegD) 	
		
		lGerD001 := .T.    
	EndIf

	cTpMov	:=	( cAliasQry )->C20_INDOPE	//0=Entrada;1=Saida;
	cModelo	:=	( cAliasQry )->C01_CODIGO
	cChvNF	:=	( cAliasQry )->C20_CHVNF
	lObs	:=	C2C->( msSeek( xFilial( 'C2C' ) + cChvNF ) ) .And. C3R->( msSeek( xFilial( 'C3R' ) + C2C->C2C_CODOBS ) )

	//GRAVACAO DO CABECALHO
	lSeek	:=	C21->( msSeek( xFilial( 'C21' ) + cChvNF ) ) .And. C3Q->( msSeek( xFilial( 'C3Q' ) + C21->C21_CODINF ) )

	//Tratamento para que os codigos de indicador de frete seja gerado de acordo com o definido pelo 
	//Layout do Sped	
	aMacro	:=	{ "", "", ""}
	aMacro[2]:= (cAliasQry)->C1H_CODPAR
	aMacro[3]:= (cAliasQry)->C20_SUBSER
	
	If TAFColumnPos( "C20_CODORI" )
	
		nAuxCid := POSICIONE("C07",3,xFilial("C07")+(cAliasQry)->C20_CODORI,"C07_CODIGO")    
	    nIdUf   := POSICIONE("C07",3,xFilial("C07")+(cAliasQry)->C20_CODORI,"C07_UF")
	    nAuxEst := POSICIONE("C09",3,xFilial("C09")+nIdUf,"C09_CODUF")
	    
	    nLocOrig := nAuxEst + Substr(nAuxCid,2,5)
	Endif
	    
	If TAFColumnPos( "C20_CODDES")
	    
	    nAuxCid := POSICIONE("C07",3,xFilial("C07")+(cAliasQry)->C20_CODDES,"C07_CODIGO")    
	    nIdUf   := POSICIONE("C07",3,xFilial("C07")+(cAliasQry)->C20_CODDES,"C07_UF")
	    nAuxEst := POSICIONE("C09",3,xFilial("C09")+nIdUf,"C09_CODUF")
	    
	    nLocDest := nAuxEst + Substr(nAuxCid,2,5)
	    
    Endif
     
	If DToS(dDataIni) >= "20120701"
	
		//Por Conta de Terceiros
		If (cAliasQry)->C0X_CODIGO == "0" 
			aAdd( aMacro, "2" )		
		
		//Por Conta do Emitente
		ElseIf (cAliasQry)->C0X_CODIGO == "1"
			aAdd( aMacro, "0" )
		
		//Por Conta do Destinatário
		ElseIf (cAliasQry)->C0X_CODIGO == "2"
			aAdd( aMacro, "1" )
		
		//Sem cobrança de frete
		Else
			aAdd( aMacro, "9" )			
		EndIf						
	
	//Para periodos Anteriores a 01/07/2012 o codigo ja esta correto de acordo com o Layout	
	Else
		aAdd( aMacro, (cAliasQry)->C0X_CODIGO )	
	EndIf
	
	If ( cAliasQry )->C20_CHVNF <> cChvOld
		
		If cModelo = '63' 
			aMacro[1] := ""
			aMacro[2] := ""
			aMacro[3] := ""
		endif
		cChvOld := ( cAliasQry )->C20_CHVNF 
		Conout(cChvOld)
		LoadString( 'D100' , aCmps , @cStrTxt , cAliasQry , lSeek, aMacro )

		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
	
		TaFContBlc("D100",aTotRegD)
	
	else
		Conout("Não gera d100")
	EndIf 	
		
	If nRWStrTxt >= 0
		
		//Tratamento para que as notas ficasis com os modelos abaixo ( Canceladas/Denegadas) nao gerem
		//os registros filhos.
		If ! ( ( cAliasQry )->C02_CODIGO $ ("02|03|04|") ) 
			// ----------------------------------------------- INICIO DOS COMPLEMENTOS POR MODELO DE DOCUMENTO 
			//If cTpMov == '1'	//DOCUMENTOS DE SAIDA
		
				//COMPLEMENTO MODELO 08/8B - Tratamento para gerar o registro D130
				If cModelo $ '08,8B' .And. C3F->( msSeek( xFilial( 'C3F' ) + cChvNF ) )
				
					While C3F->( !Eof() ) .And. xFilial( 'C3F' ) + cChvNF == C3F->( C3F_FILIAL + C3F_CHVNF ) 
						aMacro	:=	{}
						aAdd( aMacro, "C1H->( msSeek( xFilial( 'C1H' ) + C3F->C3F_CPARCO ) )" )
						aAdd( aMacro, "C1H->( msSeek( xFilial( 'C1H' ) + C3F->C3F_CPARRE ) )" )
						aAdd( aMacro, "C09->( msSeek( xFilial( 'C09' ) + C3F->C3F_UFORIG ) ) .And. C07->( msSeek( xFilial( 'C07' ) + C3F->C3F_CMUNOR ) )" )
						aAdd( aMacro, "C09->( msSeek( xFilial( 'C09' ) + C3F->C3F_UFDEST ) ) .And. C07->( msSeek( xFilial( 'C07' ) + C3F->C3F_CMUNDE ) )" )
						aAdd( aMacro, "C09->( msSeek( xFilial( 'C09' ) + C0Q->C0Q_UF ) )" )										
							                             
						If !Empty( C3F->C3F_CODVEI )
							lSeek	:=	C0Q->( msSeek( xFilial( 'C0Q' ) + C3F->C3F_CODVEI ) )
						Else
							lSeek	:=	.F.
						EndIf
			
						LoadString( 'D130' , aCmps , @cStrTxt , cAliasQry , lSeek , aMacro )
						
						TaFContBlc("D130",aTotRegD) 					
							
						C3F->( dbSkip() )
					End
		
				//COMPLEMENTO MODELO 09 - Tratamento para gerar o registro D140			
				ElseIf cModelo $ '09'
					lSeek	:=	C1H->( msSeek( xFilial( 'C1H' ) + ( cAliasQry )->C3G_CPARCO ) )	
			
					LoadString( 'D140' , aCmps , @cStrTxt , cAliasQry , lSeek )
					
					TaFContBlc("D140",aTotRegD) 				
				
				//COMPLEMENTO MODELO 10 - Tratamento para gerar o registro D150		
				ElseIf cModelo $ '10'
					LoadString( 'D150' , aCmps , @cStrTxt , cAliasQry )       
					
					TaFContBlc("D150",aTotRegD) 		
					
				//COMPLEMENTO MODELO 57 - Tratamento para gerar o registro D101
				ElseIf cModelo $ "57|67" 
					dbSelectarea("C2F")
					C2F->(dbSetorder(1))		
					If C2F->( msSeek( xFilial( 'C2F' ) + cChvNF + cIdDest) ) //Posiciono no Tributo de ICMS Complementar (DIFAL) - UF DESTINO 
						aMacro	:=	{}
						aAdd( aMacro, "C2F->(MsSeek(xFilial( 'C2F' )+ '" + cChvNF + cIdFecp + "'))" )
						aAdd( aMacro, "C2F->(MsSeek(xFilial( 'C2F' )+ '" + cChvNF + cIdDest + "'))" )						
						
						LoadString( 'D101' , aCmps , @cStrTxt , "C2F" , , aMacro )	
						TaFContBlc("D101",aTotRegD) 
					Endif					
				EndIf
				
				//COMPLEMENTO MODELO 08,8B,09,10,11,26,27 - Tratamento para gerar os registro D160, D161 e D162
				If cModelo $ '08,8B,09,10,11,26,27' .And. C3A->( msSeek( xFilial( 'C3A' ) + cChvNF ) )
				
					While C3A->( !Eof() ) .And. xFilial( 'C3A' ) + cChvNF == C3A->( C3A_FILIAL + C3A_CHVNF ) 
						aMacro	:=	{}
						aAdd( aMacro, "C1H->( msSeek( xFilial( 'C1H' ) + C3A->C3A_CPARRE ) )" )
						aAdd( aMacro, "C09->( msSeek( xFilial( 'C09' ) + C1H->C1H_UF ) ) .And. C07->( msSeek( xFilial( 'C07' ) + C1H->C1H_CODMUN ) )" )
						aAdd( aMacro, "C1H->( msSeek( xFilial( 'C1H' ) + C3A->C3A_CPARDE ) )" )
						LoadString( 'D160' , aCmps , @cStrTxt , cAliasQry , , aMacro )
						
						TaFContBlc("D160",aTotRegD) 					
						
						//Tratamento para que o registro D161 seja gerado somente quando existir a informação
						If !Empty( C3A->C3A_TPCARG )
						
						   If (cPerfilSPD == "A" .AND. cTpMov == "1")  
							aMacro	:=	{}
							aAdd( aMacro, "C1H->( msSeek( xFilial( 'C1H' ) + C3A->C3A_CPARCO ) )" )
							aAdd( aMacro, "C09->( msSeek( xFilial( 'C09' ) + C1H->C1H_UF ) ) .And. C07->( msSeek( xFilial( 'C07' ) + C1H->C1H_CODMUN ) )" )
							aAdd( aMacro, "C1H->( msSeek( xFilial( 'C1H' ) + C3A->C3A_CPAREN ) )" )
							
							LoadString( 'D161' , aCmps , @cStrTxt , cAliasQry , , aMacro )
							
							TaFContBlc("D161",aTotRegD) 					
						  Endif
						
						EndIf
						
						//cChvAux	:=	C3A->( C3A_CHVNF + C3A_DESPAC + C3A_CPARRE + C3A_CPARDE )      
						//Tratamento, pois o campo C3I_CPARRE e C3I_CPARDE esta com o tamanho 60, e na tabela C3A esta com tamanho 6
						cChvAux	:=	C3A->( C3A_CHVNF + C3A_DESPAC + C3A_CPARRE+Space(60-Len(C3A_CPARRE) )+ C3A_CPARDE+Space(60-Len(C3A_CPARDE) ) )
						If C3I->( msSeek( xFilial( 'C3I' ) + cChvAux ) )						
							While C3I->( !Eof() ) .And. xFilial( 'C3I' ) + cChvAux == C3I->( C3I_FILIAL + C3I_CHVNF + C3I_DESPAC + C3I_CPARRE + C3I_CPARDE )
							
								//Tratamento para que o registro D162 seja gerado somente quando existir a informação
								If !Empty( C3I->C3I_NUMDOC )							
									lSeek	:=	C01->( msSeek( xFilial( 'C01' ) + C3I->C3I_CODMOD ) )
									LoadString( 'D162' , aCmps , @cStrTxt , cAliasQry , lSeek )
		
									TaFContBlc("D162",aTotRegD) 							
								EndIf
								C3I->( dbSkip() )
							End
						EndIf
						C3A->( dbSkip() )
					End
				EndIf
				
				//COMPLEMENTO MODELO 26
				If cModelo $ '26'
				
					//Tratamento para gerar o registro D170 
					If C3F->( msSeek( xFilial( 'C3F' ) + cChvNF ) )
						aMacro	:=	{}
						C07->( dbSetOrder( 3 ) )
						aAdd( aMacro, "C1H->( msSeek( xFilial( 'C1H' ) + C3F->C3F_CPARCO ) )" )
						aAdd( aMacro, "C1H->( msSeek( xFilial( 'C1H' ) + C3F->C3F_CPARRE ) )" )
						aAdd( aMacro, "C09->( msSeek( xFilial( 'C09' ) + C3F->C3F_UFORIG ) ) .And. C07->( msSeek( xFilial( 'C07' ) + C3F->C3F_CMUNOR ) )" )
						aAdd( aMacro, "C09->( msSeek( xFilial( 'C09' ) + C3F->C3F_UFDEST ) ) .And. C07->( msSeek( xFilial( 'C07' ) + C3F->C3F_CMUNDE ) )" )
						aAdd( aMacro, "C09->( msSeek( xFilial( 'C09' ) + C0Q->C0Q_UF ) )" )										
							
						If !Empty( C3F->C3F_CODVEI )
							lSeek	:=	C0Q->( msSeek( xFilial( 'C0Q' ) + C3F->C3F_CODVEI ) )
						Else
							lSeek	:=	.F.
						EndIf
	
						LoadString( 'D170' , aCmps , @cStrTxt , cAliasQry , lSeek , aMacro )
						
						TaFContBlc("D170",aTotRegD) 
							
					
						//Tratamento para gerar o registro D180
						If C24->( msSeek( xFilial( 'C24' ) + cChvNF ) )
							aMacro	:=	{}
							aAdd( aMacro, "C1H->( msSeek( xFilial( 'C1H' ) + C24->C24_PAREMI ) )" )
							aAdd( aMacro, "C09->( msSeek( xFilial( 'C09' ) + C1H->C1H_UF ) ) .And. C07->( msSeek( xFilial( 'C07' ) + C1H->C1H_CODMUN ) )" )
							aAdd( aMacro, "C1H->( msSeek( xFilial( 'C1H' ) + C24->C24_PARTOM ) )" )
						
							lSeek	:=	C01->( msSeek( xFilial( 'C01' ) + C24->C24_CODMOD ) )
		
							LoadString( 'D180' , aCmps , @cStrTxt , cAliasQry , lSeek , aMacro )
							
							TaFContBlc("D180",aTotRegD) 
						
						EndIF						
					EndIf
				EndIf
			//EndIf
			// ----------------------------------------------- FIM DOS COMPLEMENTOS POR MODELO DE DOCUMENTO 
				
			//LACO DO ITEM - Tratamento para gerar o registro D110 e D120
			While ( cAliasQry )->( !Eof() ) .And. ( cAliasQry )->( C20_FILIAL + C20_CHVNF ) == xFilial( 'C20' ) + cChvNF
				cChvIte	:=	cChvNF + ( cAliasQry )->( C30_NUMITE + C30_CODITE )
					
				//COMPLEMENTO MODELO 07 - Tratamento para gerar o registro D110 e D120
				If nRWStrTxt >= 0 .And. cTpMov == '1' .And. cModelo == '07' .And. C39->( msSeek( xFilial( 'C39' ) + cChvIte ) )
					     
					LoadString( 'D110' , aCmps , @cStrTxt2 , cAliasQry )
					
					aInfoGrv[5]++										
					nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt2, .T., @aInfoGrv, 'D100' ) 
					
					TaFContBlc("D110",aTotRegD) 
					
					While C39->( !Eof() ) .And. xFilial( 'C39' ) + cChvIte == C39->( C39_FILIAL + C39_CHVNF + C39_NUMITE + C39_CODITE ) 
						aMacro	:=	{}
						aAdd( aMacro, "C09->( msSeek( xFilial( 'C09' ) + C39->C39_UFORIG ) ) .And. C07->( msSeek( xFilial( 'C07' ) + C39->C39_CMUNOR ) )" )
						aAdd( aMacro, "C09->( msSeek( xFilial( 'C09' ) + C39->C39_UFDEST ) ) .And. C07->( msSeek( xFilial( 'C07' ) + C39->C39_CMUNDE ) )" )
						aAdd( aMacro, "C09->( msSeek( xFilial( 'C09' ) + C0Q->C0Q_UF ) )" )										
						
						If !Empty( C39->C39_CODVEI )
							lSeek	:=	C0Q->( msSeek( xFilial( 'C0Q' ) + C39->C39_CODVEI ) )						
						Else
							lSeek	:=	.F.
						EndIf
					
						LoadString( 'D120' , aCmps , @cStrTxt2 , cAliasQry , lSeek , aMacro )

						aInfoGrv[5]++
						nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt2, .T., @aInfoGrv, 'D100' )
						
						TaFContBlc("D120",aTotRegD) 					
	
						If nRWStrTxt == -1
							Exit				
						EndIf
				
						C39->( dbSkip() )
					End
				EndIf
				
				//TRATAMENTO PARA GERACAO DO REGISTRO D190 - CONSOLIDADO
				If nRWStrTxt >= 0 .And. C35->( msSeek( xFilial( 'C35' ) + cChvIte ) )
	
					While C35->( !Eof() ) .And. C35->( C35_FILIAL + C35_CHVNF + C35_NUMITE + C35_CODITE ) == xFilial( 'C35' ) + cChvIte 
					
						If C3S->( ( msSeek( xFilial( 'C3S' ) + C35->C35_CODTRI ) ) .And. C3S_CODIGO == '02' ) .And. ;
							C30->( msSeek( xFilial( 'C30' )+  C35->C35_CHVNF + C35->C35_NUMITE +C35->C35_CODITE)) .And.;
							C0Y->( msSeek( xFilial( 'C0Y' ) + C30->C30_CFOP ) ) .And.;    
							C03->( msSeek( xFilial( 'C03' ) + C30->C30_ORIGEM ) ) .And.;
							C14->( msSeek( xFilial( 'C14' ) + C35->C35_CST ) ) 
						
					
							nPosC190 := aScan( aC190 , { | aX | aX[ 1 ] + aX[ 2 ] + Str( aX[ 3 ] , 6 , 2 ) == ( C03->C03_CODIGO + C14->C14_CODIGO )  + C0Y->C0Y_CODIGO + Str( C35->C35_ALIQ , 6 , 2 ) } )
							If nPosC190 == 0
								aAdd( aC190, { '' , '' , 0 , 0 , 0 , 0 , 0 , '' } )
								nPosC190	:=	Len( aC190 )
							EndIf
							aC190[ nPosC190 , 1 ]	:=	C03->C03_CODIGO + C14->C14_CODIGO
							aC190[ nPosC190 , 2 ]	:=	C0Y->C0Y_CODIGO
							aC190[ nPosC190 , 3 ]	:=	C35->C35_ALIQ
							aC190[ nPosC190 , 4 ]	+=	C30->C30_VLOPER
							aC190[ nPosC190 , 5 ]	+=	C35->C35_BASE
							aC190[ nPosC190 , 6 ]	+=	C35->C35_VALOR
							aC190[ nPosC190 , 7 ]	+=	C35->C35_REDBC
							aC190[ nPosC190 , 8 ]	:=	Iif( lObs , xGerBlc0( "0460",  Alltrim( C3R->( C3R_CODIGO ) ), cFilSelBc, aWizardBc, cTabSpd ) , '' )
						EndIf
						
						C35->( dbSkip() )
					End
				EndIf
				
				//TRATAMENTO PARA GERACAO DO REGISTRO D195 E D197
				If nRWStrTxt >= 0 .And. lObs
					While C2C->( !Eof() ) .And. xFilial( 'C2C' ) + C2C->C2C_CHVNF == C2C->C2C_FILIAL + cChvNF
					 
						If C3R->( msSeek( xFilial( 'C3R' ) + C2C->C2C_CODOBS ) )
							LoadString( 'D195' , aCmps , @cStrTxt3 , 'C2C' )
							
							TaFContBlc("D195",aTotRegD) 						
							
							If C2D->( msSeek( xFilial( 'C2D' ) + cChvNF + C2C->C2C_CODOBS ) )
							
								While C2D->( !Eof() ) .And.  C2D->( C2D_FILIAL + C2D_CHVNF + C2D_CODOBS ) == xFilial( 'C2D' ) + cChvNF + C2C->C2C_CODOBS 
									
									If C0J->( msSeek( xFilial( 'C0J' ) + C2D->C2D_CODAJ ) )
									
										aMacro	:=	{}
										aAdd( aMacro, "C1L->( MsSeek( xFilial( 'C1L' ) + C2D->C2D_CODITE ) ) .And. !Empty( C1L->C1L_CODIGO )" )
																													
										LoadString( 'D197' , aCmps , @cStrTxt3 , cAliasQry, , aMacro )
										TaFContBlc("D197",aTotRegD) 									
									EndIf
																
									C2D->( dbSkip() )
								End
				
							EndIf
	
						EndIf
	
						C2C->( dbSkip() )
					End
				EndIf
				
				If nRWStrTxt == -1
					Exit
				EndIf
				
				( cAliasQry )->( dbSkip() )
			End

			aInfoGrv[5]++									
			If ( nRWStrTxt := WrtStrTxt(  , @cStrTxt2, .T., @aInfoGrv, 'D100' ) ) >= 0
				
				aInfoGrv[5]++
				nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
			EndIf
			
			If nRWStrTxt >= 0 .And. Len( aC190 ) > 0
				LoadString( 'D190' , aCmps , @cStrTxt , cAliasQry , , , aC190 )
				
				aInfoGrv[5]++													
				nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
				
				TaFContBlc("D190",aTotRegD) 			
	
			EndIf
			
			If nRWStrTxt >= 0
				aInfoGrv[5]++
				nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt3, .T., @aInfoGrv, 'D100' )
			EndIf
		Else
			( cAliasQry )->( dbSkip() )
		EndIf			
	EndIf
	
	If nRWStrTxt == -1
		Exit
	EndIf	
End
( cAliasQry )->( dbCloseArea() )

If nRWStrTxt == -1
	MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoD300
Funcao responsavel processar o movimento especifico para montagem dos registros:
 D300,D301,D310 do EFD Fiscal

@param	dDataIni		-> 	Data inicial do periodo
		dDataFim		->	Data final do periodo
		cD300Conso 	->  Gerar o registro D300 consolidado? (0 - Sim ou 1 - Não)
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlocoD300( dDataIni , dDataFim, cD300Conso  )
Local	cQuery		:=	''
Local 	cAliasQry 	:=  GetNextAlias()
Local	aCmps		:=	DistrCmps()
Local	cChvNf		:=	''
Local	cQuebra	:=	''
Local	cStrTxt	:=	''
Local	nRWStrTxt	:=	0
Local	aD300		:=	{}
Local   aD301   := 	{}
Local	aD310		:=	{}


/*----------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
----------------------------------------------------------*/
C2I->( dbSetOrder( 1 ) )
C7V->( dbSetOrder( 1 ) )

/*----------------------------------------------------------
Query principal do movimento para gerar os registro D300, D301, D310
----------------------------------------------------------*/ 
            
	cQuery := " SELECT " 
	cQuery += "	C7U.C7U_FILIAL,"
	cQuery += " C7U.C7U_ID,"
	cQuery += "	C7U.C7U_CODMOD,"
	cQuery += "	C7U.C7U_CST, "
	cQuery += "	C7U.C7U_CFOP, "
	cQuery += " C7U.C7U_SER, "
	cQuery += " C7U.C7U_SUB, "
	cQuery += " C7U.C7U_VLOPR,  "
	cQuery += " C7U.C7U_VLDESC, "
	cQuery += " C7U.C7U_VLSERV, "
	cQuery += " C7U.C7U_VLSEG,  "
	cQuery += " C7U.C7U_OUTDES, "
	cQuery += " C7U.C7U_BCICM,  "
	cQuery += " C7U.C7U_VLICMS, "
	cQuery += " C7U.C7U_REDBC,  " 
 	cQuery += " C7U.C7U_DOCINI, "
    cQuery += " C7U.C7U_DOCFIM, "
    cQuery += " C7U.C7U_CODOBS, "
	cQuery += " C7U.C7U_CTA, "
	cQuery += " C7U.C7U_ALIQ, "
	cQuery += " C7U.C7U_DTDOC, "
	cQuery += " C7X.C7X_VLSERV, "
	cQuery += " C7X.C7X_BCICM,  "
	cQuery += " C7X.C7X_VLICMS, "
	cQuery += " C7X.C7X_CODMUN, "
	cQuery += " C09.C09_CODIGO CODUF, "
	cQuery += " C07.C07_CODIGO CODMUN, "
	cQuery += " C14.C14_CODIGO CST_ICMS,"
	cQuery += " C0Y.C0Y_CODIGO CFOP,"    
	cQuery += " C01.C01_CODIGO COD_MOD,"
	cQuery += " C1O.C1O_CODIGO COD_CTA, "
	cQuery += " (SELECT C3R_CODIGO FROM " + RetSqlName( 'C3R' ) + " C3R WHERE C3R.C3R_FILIAL='" + xFilial('C3R') + "' AND C3R.D_E_L_E_T_=' ' AND C3R.C3R_ID= C7U.C7U_CODOBS) COD_OBS,  "
	cQuery += " C7V.C7V_DOCCAN "
	
	cQuery	+=	"FROM " + RetSqlName( 'C7U' ) + " C7U "

	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C7X' ) + " C7X ON(C7X.C7X_FILIAL='" + xFilial('C7X') + "' AND C7X.C7X_ID=C7U.C7U_ID AND C7X.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C7V' ) + " C7V ON(C7V.C7V_FILIAL='" + xFilial('C7V') + "' AND C7V.C7V_ID=C7U.C7U_ID AND C7V.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C14' ) + " C14 ON(C14.C14_FILIAL='" + xFilial('C14') + "' AND C14.C14_ID=C7U.C7U_CST AND C14.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0Y' ) + " C0Y ON(C0Y.C0Y_FILIAL='" + xFilial('C0Y') + "' AND C0Y.C0Y_ID=C7U.C7U_CFOP AND C0Y.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C01' ) + " C01 ON(C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=C7U.C7U_CODMOD AND C01.D_E_L_E_T_=' ')  "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1O' ) + " C1O ON(C1O.C1O_FILIAL= " + Iif( FWModeAccess( "C1O" , 3 ) == "C" , "'" + xFilial( "C1O" ) + "'" , "C7U.C7U_FILIAL" ) + " AND C1O.C1O_ID=C7U.C7U_CTA AND C1O.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C07' ) + " C07 ON(C07.C07_FILIAL='" + xFilial('C07') + "' AND C07.C07_ID=C7X.C7X_CODMUN AND C07.D_E_L_E_T_=' ')
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C09' ) + " C09 ON(C09.C09_FILIAL='" + xFilial('C09') + "' AND C09.C09_ID=C7X.C7X_UF AND C09.D_E_L_E_T_=' ')

	cQuery	+=	"WHERE "
	cQuery	+=	"C7U.C7U_FILIAL='" + xFilial('C7U') + "' AND "
	cQuery	+=	"C7U.D_E_L_E_T_=' ' AND "
	cQuery	+=	"( C01.C01_CODIGO='13' OR C01.C01_CODIGO='14' OR C01.C01_CODIGO='15' OR C01.C01_CODIGO='16' ) AND "
	cQuery	+=	"C7U.C7U_DTMOV>='" + DToS( dDataIni ) + "' AND " 
	cQuery	+=	"C7U.C7U_DTMOV<='" + DToS( dDataFim ) + "' " 

	cQuery	+=	" ORDER BY  "
	cQuery	+=	"C7U.C7U_FILIAL, "
	cQuery	+=	"C01.C01_CODIGO, "
	cQuery	+=	"C7U.C7U_SER, "
	cQuery	+=	"C7U.C7U_SUB, "
	cQuery	+=	"C7U.C7U_DOCINI, "
	cQuery	+=	"C14.C14_CODIGO, "
	cQuery	+=	"C0Y.C0Y_CODIGO, "
	cQuery	+=	"C7U.C7U_ALIQ, "
	cQuery	+=	"C7U.C7U_DTDOC "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )


nTotReg := Contar(cAliasQry,"!Eof()")
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop( ) )    

//Como o D300 é gerado pelo T013 e T904 a variavel irá tratar a geração se é por notal fiscal (T013) ou consolidado (T904), que é escolhido pelo usuario pois depende do ERP (envia as informações para o TAF).
//If (nTotReg > 0) 
If cD300Conso == "0" 
	While ( cAliasQry )->( !Eof() )
	    
		If !lGerD001       
			aMacro	:=	{}
			aAdd( aMacro , "0" )
			
			LoadString( 'D001' , aCmps , @cStrTxt, , , aMacro )
			aInfoGrv[5]++
			WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
			
			TaFContBlc("D001",aTotRegD) 		
		
		 	lGerD001 := .T.
		EndIf

		cChvNf	:=	( cAliasQry )->C7U_ID
		aD300	:=	{}
		aD310	:=	{}
		( cAliasQry )->( aAdd( aD300 , {COD_MOD , C7U_SER , C7U_SUB , C7U_DOCINI , '' , '0'+CST_ICMS , CFOP , C7U_ALIQ , (C7U_DTDOC) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , COD_OBS , COD_CTA } ) )
		( cAliasQry )->( aAdd( aD301 , {C7V_DOCCAN}))
		
		cQuebra	:=	( cAliasQry )->( COD_MOD + C7U_SER + C7U_SUB + CST_ICMS + CFOP + Str( C7U_ALIQ , 6 , 2 ) + Dt2Caract( C7U_DTDOC ) )
		While ( cAliasQry )->( !Eof() ) .And. ;
			( cAliasQry )->( COD_MOD + C7U_SER + C7U_SUB + CST_ICMS + CFOP + Str( C7U_ALIQ , 6 , 2 ) + Dt2Caract( C7U_DTDOC ) ) == cQuebra
			
			aD300[ 1 , 05 ]	:=	( cAliasQry )->C7U_DOCFIM
			aD300[ 1 , 10 ]	+=	( cAliasQry )->C7U_VLOPR
			aD300[ 1 , 11 ]	+=	( cAliasQry )->C7U_VLDESC
			aD300[ 1 , 12 ]	+=	( cAliasQry )->C7U_VLSERV
			aD300[ 1 , 13 ]	+=	( cAliasQry )->C7U_VLSEG
			aD300[ 1 , 14 ]	+=	( cAliasQry )->C7U_OUTDES
			aD300[ 1 , 15 ]	+=	( cAliasQry )->C7U_BCICM
			aD300[ 1 , 16 ]	+=	( cAliasQry )->C7U_VLICMS
			aD300[ 1 , 17 ]	+=	( cAliasQry )->C7U_REDBC

			If( nPosD310 := aScan( aD310 , { | aX | aX[ 1 ] == ( cAliasQry )->( CODUF + CODMUN ) } ) ) == 0
				( cAliasQry )->( aAdd( aD310 , { CODUF + CODMUN , 0 , 0 , 0 } ) )
				nPosD310	:=	Len( aD310 )
			EndIf
			aD310[ nPosD310 , 2 ]	+=	( cAliasQry )->C7X_VLSERV
			aD310[ nPosD310 , 3 ]	+=	( cAliasQry )->C7X_BCICM
			aD310[ nPosD310 , 4 ]	+=	( cAliasQry )->C7X_VLICMS

			( cAliasQry )->( dbSkip() )
		End

		LoadString( 'D300' , aCmps , @cStrTxt , cAliasQry , , , aD300 )
		
		aInfoGrv[5]++
		nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )

		TaFContBlc("D300",aTotRegD) 

		LoadString( 'D301' ,  aCmps , @cStrTxt , cAliasQry , , , aD301 ) 

		aInfoGrv[5]++					
		nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
		TaFContBlc("D301",aTotRegD) 

		aInfoGrv[5]++
	  	If ( nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' ) ) == -1		
	   		Exit
	  	EndIf
	
		LoadString( 'D310' , aCmps , @cStrTxt , cAliasQry , , , aD310 )
		
		aInfoGrv[5]++
		nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
		
		TaFContBlc("D310",aTotRegD) 
		
		If nRWStrTxt == -1
			Exit
		EndIf
	End

	If nRWStrTxt == -1
		MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
	EndIf                                                                                       
	( cAliasQry )->( dbCloseArea() )
Else
         
	cAliasQry 	:=  GetNextAlias()
	cQuery := " "
	cQuery	+=	"SELECT "
	cQuery	+=	"C20.C20_FILIAL, "
	cQuery	+=	"C20.C20_CHVNF, "
	cQuery	+=	"C09.C09_CODIGO CODUF, "
	cQuery	+=	"C07.C07_CODIGO CODMUN, "
	cQuery	+=	"C01.C01_CODIGO COD_MOD, "
	cQuery	+=	"C20.C20_SERIE SER, "
	cQuery	+=	"C20.C20_SUBSER SUB, "
	cQuery	+=	"C20.C20_NUMDOC NUM_DOC, "
	cQuery	+=	"C14.C14_CODIGO CST_ICMS, "
	cQuery	+=	"C0Y.C0Y_CODIGO CFOP, "
	cQuery	+=	"C2F.C2F_ALIQ ALIQ_ICMS, "
	cQuery	+=	"C20.C20_DTDOC, "
	cQuery	+=	"C20.C20_VLDESC VL_DESC, "
	cQuery	+=	"C20.C20_VLSERV VL_SERV, "
	cQuery	+=	"C20.C20_VLRSEG VL_SEG, "
	cQuery	+=	"C20.C20_VLOUDE VL_OUT_DESP, "
	cQuery	+=	"C1O.C1O_CODIGO COD_CTA, "
	cQuery	+=	"SUM(C2F.C2F_VLOPE) VL_OPR, "
	cQuery	+=	"SUM(C2F.C2F_BASE) VL_BC_ICMS, "
	cQuery	+=	"SUM(C2F.C2F_VALOR) VL_ICMS, "
	cQuery	+=	"SUM(C2F.C2F_VLNT) VL_RED_BC, "
	cQuery	+=	"(SELECT C3R_CODIGO FROM " + RetSqlName( 'C3R' ) + " C3R WHERE C3R.C3R_FILIAL='" + xFilial('C3R') + "' AND C3R.D_E_L_E_T_=' ' AND C3R.C3R_ID=(SELECT MAX(C2C.C2C_CODOBS) FROM " + RetSqlName( 'C2C' ) + " C2C WHERE C2C.C2C_FILIAL=C20.C20_FILIAL AND C2C.C2C_CHVNF=C20.C20_CHVNF AND C2C.D_E_L_E_T_=' ')) COD_OBS  "
	
	cQuery	+=	"FROM " + RetSqlName( 'C20' ) + " C20 "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C01' ) + " C01 ON(C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=C20.C20_CODMOD AND C01.D_E_L_E_T_=' ')  "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C02' ) + " C02 ON(C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID=C20.C20_CODSIT AND C02.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C2F' ) + " C2F ON(C2F.C2F_FILIAL=C20.C20_FILIAL AND C2F.C2F_CHVNF=C20.C20_CHVNF AND C2F.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C14' ) + " C14 ON(C14.C14_FILIAL='" + xFilial('C14') + "' AND C14.C14_ID=C2F.C2F_CST AND C14.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0Y' ) + " C0Y ON(C0Y.C0Y_FILIAL='" + xFilial('C0Y') + "' AND C0Y.C0Y_ID=C2F.C2F_CFOP AND C0Y.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1O' ) + " C1O ON(C1O.C1O_FILIAL= " + Iif( FWModeAccess( "C1O" , 3 ) == "C" , "'" + xFilial( "C1O" ) + "'" , "C20.C20_FILIAL" ) + " AND C1O.C1O_ID=C20.C20_CODCTA AND C1O.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1H' ) + " C1H ON(C1H.C1H_FILIAL= " + Iif( FWModeAccess( "C1H" , 3 ) == "C" , "'" + xFilial( "C1H" ) + "'" , "C20.C20_FILIAL" ) + " AND C1H.C1H_ID=C20.C20_CODPAR AND C1H.D_E_L_E_T_=' ')
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C07' ) + " C07 ON(C07.C07_FILIAL='" + xFilial('C09') + "' AND C07.C07_ID=C1H.C1H_CODMUN AND C07.D_E_L_E_T_=' ')
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C09' ) + " C09 ON(C09.C09_FILIAL='" + xFilial('C07') + "' AND C09.C09_ID=C1H.C1H_UF AND C09.D_E_L_E_T_=' ')
	
	cQuery	+=	"WHERE "
	cQuery	+=	"C20.C20_FILIAL='" + xFilial('C20') + "' AND "
	cQuery	+=	"C20.C20_DTDOC>='" + DToS( dDataIni ) + "' AND " 
	cQuery	+=	"C20.C20_DTDOC<='" + DToS( dDataFim ) + "' AND " 
	cQuery	+=	"C20.C20_INDOPE='1' AND "
	cQuery	+=	"C20.D_E_L_E_T_=' ' AND "
	cQuery	+=	"( C01.C01_CODIGO='13' OR C01.C01_CODIGO='14' OR C01.C01_CODIGO='15' OR C01.C01_CODIGO='16' ) "
	
	cQuery	+=	"GROUP BY  "
	cQuery	+=	"C20.C20_FILIAL, "
	cQuery	+=	"C20.C20_CHVNF, "
	cQuery	+=	"C09.C09_CODIGO, "
	cQuery	+=	"C07.C07_CODIGO, "
	cQuery	+=	"C01.C01_CODIGO, "
	cQuery	+=	"C20.C20_SERIE, "
	cQuery	+=	"C20.C20_SUBSER, "
	cQuery	+=	"C20.C20_NUMDOC, "
	cQuery	+=	"C14.C14_CODIGO, "
	cQuery	+=	"C0Y.C0Y_CODIGO, "
	cQuery	+=	"C2F.C2F_ALIQ, "
	cQuery	+=	"C20.C20_DTDOC, "
	cQuery	+=	"C20.C20_VLDESC, "
	cQuery	+=	"C20.C20_VLSERV, "
	cQuery	+=	"C20.C20_VLRSEG, "
	cQuery	+=	"C20.C20_VLOUDE, "
	cQuery	+=	"C1O.C1O_CODIGO "
	
	cQuery	+=	"ORDER BY  "
	cQuery	+=	"C20.C20_FILIAL, "
	cQuery	+=	"C20.C20_CHVNF, "
	cQuery	+=	"C01.C01_CODIGO, "
	cQuery	+=	"C20.C20_SERIE, "
	cQuery	+=	"C20.C20_SUBSER, "
	cQuery	+=	"C20.C20_NUMDOC, "
	cQuery	+=	"C14.C14_CODIGO, "
	cQuery	+=	"C0Y.C0Y_CODIGO, "
	cQuery	+=	"C2F.C2F_ALIQ, "
	cQuery	+=	"C20.C20_DTDOC "
	
	cQuery	:=	ChangeQuery( cQuery )
   	dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )
	
	TcSetField( cAliasQry , "C20_DTDOC" , "D" , 8 , 0 )
	
	//LACO DO DOCUMENTO
	While ( cAliasQry )->( !Eof() )
	    
		If !lGerD001       
			aMacro	:=	{}
			aAdd( aMacro , "0" )
			
			LoadString( 'D001' , aCmps , @cStrTxt, , , aMacro )
			
			aInfoGrv[5]++
			WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
			
			TaFContBlc("D001",aTotRegD) 			
		
		 	lGerD001 := .T.
		EndIf
	
		cChvNf	:=	( cAliasQry )->C20_CHVNF
		aD300	:=	{}
		aD310	:=	{}
		( cAliasQry )->( aAdd( aD300 , { COD_MOD , SER , SUB , NUM_DOC , '' , '0'+CST_ICMS , CFOP , ALIQ_ICMS , C20_DTDOC , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , COD_OBS , COD_CTA } ) )
		
		cQuebra	:=	( cAliasQry )->( COD_MOD + SER + SUB + CST_ICMS + CFOP + Str( ALIQ_ICMS , 6 , 2 ) + DToS( C20_DTDOC ) )
		While ( cAliasQry )->( !Eof() ) .And. ;
			( cAliasQry )->( COD_MOD + SER + SUB + CST_ICMS + CFOP + Str( ALIQ_ICMS , 6 , 2 ) + DToS( C20_DTDOC ) ) == cQuebra
			
			aD300[ 1 , 05 ]	:=	( cAliasQry )->NUM_DOC
			aD300[ 1 , 10 ]	+=	( cAliasQry )->VL_OPR
			aD300[ 1 , 11 ]	+=	( cAliasQry )->VL_DESC
			aD300[ 1 , 12 ]	+=	( cAliasQry )->VL_SERV
			aD300[ 1 , 13 ]	+=	( cAliasQry )->VL_SEG
			aD300[ 1 , 14 ]	+=	( cAliasQry )->VL_OUT_DESP
			aD300[ 1 , 15 ]	+=	( cAliasQry )->VL_BC_ICMS
			aD300[ 1 , 16 ]	+=	( cAliasQry )->VL_ICMS
			aD300[ 1 , 17 ]	+=	( cAliasQry )->VL_RED_BC
			
			If( nPosD310 := aScan( aD310 , { | aX | aX[ 1 ] == ( cAliasQry )->( CODUF + CODMUN ) } ) ) == 0
				( cAliasQry )->( aAdd( aD310 , { CODUF + CODMUN , 0 , 0 , 0 } ) )
				nPosD310	:=	Len( aD310 )
			EndIf
			aD310[ nPosD310 , 2 ]	+=	( cAliasQry )->VL_SERV
			aD310[ nPosD310 , 3 ]	+=	( cAliasQry )->VL_BC_ICMS
			aD310[ nPosD310 , 4 ]	+=	( cAliasQry )->VL_ICMS
	
			( cAliasQry )->( dbSkip() )
		End
	
		LoadString( 'D300' , aCmps , @cStrTxt , cAliasQry , , , aD300 )
		
		aInfoGrv[5]++
		nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
	
		TaFContBlc("D300",aTotRegD) 
		
		If nRWStrTxt >= 0 .And. C2I->(msSeek( xFilial( 'C2I' ) + cChvNf ) )
		
			aD301:= {}
					
			While C2I->( !Eof() ) .And. C2I->( C2I_FILIAL + C2I_CHVNF ) == xFilial( 'C2I' ) + cChvNf
			     
			    aAdd( aD301 , {C2I->C2I_NUMDOC}) 
	   			LoadString( 'D301' ,  aCmps , @cStrTxt , cAliasQry , , , aD301 ) 

				TaFContBlc("D301",aTotRegD) 

				aInfoGrv[5]++
		   		If ( nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' ) ) == -1
		   			Exit
		   		EndIf
			
				C2I->( dbSkip() )
			End
			
		EndIf
	
		LoadString( 'D310' , aCmps , @cStrTxt , cAliasQry , , , aD310 )
		
		aInfoGrv[5]++
		nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
		
		TaFContBlc("D310",aTotRegD) 	
		
		If nRWStrTxt == -1
			Exit
		EndIf
	End
	( cAliasQry )->( dbCloseArea() )
	
	If nRWStrTxt == -1
		MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
	EndIf                                                                                       
	
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoD350
Funcao responsavel processar o movimento especifico para montagem dos registros:
 D350,D355,D360,D365,D370,D390 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlocoD350( dDataIni , dDataFim , cPerfilSPD )
Local	cQuery		:=	''
Local 	cAliasQry 	:=  GetNextAlias()
Local	aCmps		:=	DistrCmps()
Local	cChave		:=	''
Local	cStrTxt	:=	''
Local	nRWStrTxt	:=	0
Local	lSeek		:=	.F.
Local	aD390		:=	{}
Local	nPosD390	:=	0
Local	nBsIss		:=	0	
Local	nAlqIss	:=	0
Local	nVlIss		:=	0
Local	cCodObs	:=	''	  
Local  cOrigem   :=  ''

/*----------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
----------------------------------------------------------*/
C6H->( dbSetOrder( 1 ) )
C6D->( dbSetOrder( 3 ) )
C3S->( dbSetOrder( 3 ) )
C14->( dbSetOrder( 3 ) )
C0Y->( dbSetOrder( 3 ) )
C7F->( dbSetOrder( 1 ) )
C6I->( dbSetOrder( 1 ) )
C6J->( dbSetOrder( 1 ) )
C6K->( dbSetOrder( 1 ) )
C03->( dbSetOrder( 3 ) )


cQuery	+=	"SELECT "
cQuery	+=	"C6F.C6F_FILIAL, "
cQuery	+=	"C6F.C6F_ID, "
cQuery	+=	"C6I.C6I_CMOD, "
cQuery	+=	"C6I.C6I_CODSIT, "
cQuery	+=	"C6I.C6I_NUMDOC, "
cQuery	+=	"C6I.C6I_DTEMIS, "
cQuery	+=	"C6I.C6I_CODOBS, "
cQuery	+=	"C01.C01_CODIGO, "
cQuery	+=	"C0W.C0W_ECFMOD, "
cQuery	+=	"C0W.C0W_ECFFAB, "
cQuery	+=	"C0W.C0W_ECFCX, "
cQuery	+=	"C6G.C6G_DTMOV, "
cQuery	+=	"C6G.C6G_PCREOP, "
cQuery	+=	"C6G.C6G_PCREDZ, "
cQuery	+=	"C6G.C6G_NRCOPF, "
cQuery	+=	"C6G.C6G_VLGRTF, "
cQuery	+=	"C6G.C6G_VLBRU, "
cQuery	+=	"(SELECT SUM(C6K.C6K_VLRTRB) FROM " + RetSqlName( 'C6K' ) + " C6K JOIN " + RetSqlName( "C3S" ) + " C3S ON(C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND C3S.C3S_ID=C6K.C6K_CODTRI AND C3S.D_E_L_E_T_=' ')  WHERE  C6K.C6K_FILIAL=C6G.C6G_FILIAL AND C6K.C6K_ID=C6F.C6F_ID AND C6K.C6K_DTMOV=C6G.C6G_DTMOV AND C3S.C3S_CODIGO='06' AND C6K.D_E_L_E_T_=' ')  VLPIS, "
cQuery	+=	"(SELECT SUM(C6K.C6K_VLRTRB) FROM " + RetSqlName( 'C6K' ) + " C6K JOIN " + RetSqlName( "C3S" ) + " C3S ON(C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND C3S.C3S_ID=C6K.C6K_CODTRI AND C3S.D_E_L_E_T_=' ')  WHERE  C6K.C6K_FILIAL=C6G.C6G_FILIAL AND C6K.C6K_ID=C6F.C6F_ID AND C6K.C6K_DTMOV=C6G.C6G_DTMOV AND C3S.C3S_CODIGO='07' AND C6K.D_E_L_E_T_=' ')  VLCOFINS "
cQuery	+=	"FROM " + RetSqlName( 'C6I' ) + " C6I "
cQuery	+=	"JOIN " + RetSqlName( 'C01' ) + " C01 ON(C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=C6I.C6I_CMOD AND C01.D_E_L_E_T_=' ') "
cQuery	+=	"JOIN " + RetSqlName( 'C6G' ) + " C6G ON(C6G.C6G_FILIAL=C6I.C6I_FILIAL AND C6G.C6G_ID=C6I.C6I_ID AND C6G.C6G_DTMOV=C6I.C6I_DTMOV AND C6G.D_E_L_E_T_=' ' ) "
cQuery	+=	"JOIN " + RetSqlName( 'C6F' ) + " C6F ON(C6F.C6F_FILIAL=C6G.C6G_FILIAL AND C6F.C6F_ID=C6G.C6G_ID AND C6F.D_E_L_E_T_=' ') "
cQuery	+=	"JOIN " + RetSqlName( 'C0W' ) + " C0W ON(C0W.C0W_FILIAL= " + Iif( FWModeAccess( "C0W" , 3 ) == "C" , "'" + xFilial( "C0W" ) + "'" , "C6F.C6F_FILIAL" ) + " AND C0W.C0W_ID=C6F.C6F_CODECF AND C0W.D_E_L_E_T_=' ') "
cQuery	+=	"WHERE "
cQuery	+=	"C6I.C6I_FILIAL='" + xFilial('C6I') + "' AND "
cQuery	+=	"C6I.C6I_DTMOV>='" + DToS( dDataIni ) + "' AND "
cQuery	+=	"C6I.C6I_DTMOV<='" + DToS( dDataFim ) + "' AND "
cQuery	+=	"C6I.D_E_L_E_T_=' ' AND "
cQuery	+=	"(C01.C01_CODIGO='2E' OR C01.C01_CODIGO='13' OR C01.C01_CODIGO='14' OR C01.C01_CODIGO='15' OR C01.C01_CODIGO='16') "
cQuery	+=	"ORDER BY C01_CODIGO, C0W_ECFMOD, C0W_ECFFAB, C0W_ECFCX, C6G_DTMOV "

cQuery	:=	ChangeQuery( cQuery )

dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

TcSetField( cAliasQry , "C6G_DTMOV" , "D" , 8 , 0 )
TcSetField( cAliasQry , "C6I_DTEMIS" , "D" , 8 , 0 )

//LACO DO ECF
While ( cAliasQry )->( !Eof() )

	If !lGerD001       

		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( 'D001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
		
		TaFContBlc("D001",aTotRegD) 		

	 	lGerD001 := .T.
	EndIf
	
	LoadString( 'D350' , aCmps , @cStrTxt , cAliasQry )
	
	aInfoGrv[5]++
	nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
	
	TaFContBlc("D350",aTotRegD) 	
	
	If nRWStrTxt >= 0

		LoadString( 'D355' , aCmps , @cStrTxt , cAliasQry )
		
		aInfoGrv[5]++
		nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
		
		TaFContBlc("D355",aTotRegD) 		
		
		If nRWStrTxt >= 0 .And. ( cAliasQry )->( VLPIS + VLCOFINS ) > 0
			LoadString( 'D360' , aCmps , @cStrTxt , cAliasQry )
			
			aInfoGrv[5]++
			nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
			
			TaFContBlc("D360",aTotRegD) 
				
		EndIf
		
		If nRWStrTxt >= 0 .And. C6H->( msSeek( xFilial( 'C6H' ) + ( cAliasQry )->( C6F_ID + DTOS( C6G_DTMOV ) ) ) )
			While C6H->( !Eof() ) .And.;
				C6H->( C6H_FILIAL + C6H_ID + DTOS( C6H_DTMOV ) ) == xFilial( 'C6H' ) + ( cAliasQry )->( C6F_ID + DTOS( C6G_DTMOV ) )
				
				lSeek	:=	C6D->( msSeek( xFilial( 'C6D' ) + C6H->C6H_CDTOT ) )
				
				LoadString( 'D365' , aCmps , @cStrTxt , cAliasQry , lSeek )
				
				aInfoGrv[5]++
				nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )

				TaFContBlc("D365",aTotRegD) 
				
				IF cPerfilSPD == "A"  
				If nRWStrTxt >= 0 .And. C7F->( msSeek( xFilial( 'C7F' ) + ( cAliasQry )->( C6F_ID + DTOS( C6G_DTMOV ) ) + C6H->C6H_CDTOT ) )
					While C7F->( !Eof() ) .And.;
						C7F->( C7F_FILIAL + C7F_ID + DTOS( C7F_DTMOV ) + C7F_CDTOT ) == xFilial( 'C7F' ) + ( cAliasQry )->( C6F_ID + DTOS( C6G_DTMOV ) ) + C6H->C6H_CDTOT

						aMacro	:=	{}
						aAdd( aMacro, "C09->( msSeek( xFilial( 'C09' ) + C7F->C7F_UF ) ) .And. C07->( msSeek( xFilial( 'C07' ) + C7F->C7F_CODMUN ) )" )
												
						LoadString( 'D370' , aCmps , @cStrTxt , cAliasQry , , aMacro )
						
						aInfoGrv[5]++
						nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
						
						TaFContBlc("D370",aTotRegD) 						
					
						If nRWStrTxt == -1
							Exit
						EndIf
		
						C7F->( dbSkip() )
					End
				EndIf
				Endif
				C6H->( dbSkip() )
			End
		EndIf
		
		aD390	:=	{}
		nBsIss	:=	0	
		nAlqIss	:=	0
		nVlIss	:=	0
		cCodObs	:=	''
			
		//POSICIONANDO CAPA DOCUMENTO			
		If nRWStrTxt >= 0
			cChave	:=	 ( cAliasQry )->C6F_ID
			While ( cAliasQry )->( !Eof() ) .And. ( cAliasQry )->( C6F_FILIAL + C6F_ID ) == xFilial( 'C6F' ) + cChave
					
				//POSICIONANDO ITEM DO DOCUMENTO
				If C6J->( msSeek( xFilial( 'C6J' ) + ( cAliasQry )->( C6F_ID + DTOS( C6G_DTMOV ) + C6I_CMOD + C6I_CODSIT + C6I_NUMDOC + DTOS( C6I_DTEMIS ) ) ) )
					
					While C6J->( !Eof() ) .And.;
						C6J->( C6J_FILIAL + C6J_ID + DTOS( C6J_DTMOV ) + C6J_CMOD + C6J_CODSIT + C6J_NUMDOC + DTOS( C6J_DTEMIS ) ) ==;					
						( cAliasQry )->( xFilial( 'C6J' ) + C6F_ID + DTOS( C6G_DTMOV ) + C6I_CMOD + C6I_CODSIT + C6I_NUMDOC + DTOS( C6I_DTEMIS ) )
						
						cCodObs	:=	C6I->C6I_CODOBS      
						      
						cOrigem := ''
						If (C03-> ( DbSeek ( xFilial("C03") + C6J->C6J_ORIGEM ) )) 
					       cOrigem := C03->C03_CODIGO
						EndIf		
										
						//POSICIONANDO TRIBUTO DO DOCUMENTO
						If C7G->( msSeek( xFilial( 'C7G' ) + C6J->( C6J_ID + DTOS( C6J_DTMOV ))))
							While C7G->( !Eof() ) .And.;
								C7G->( C7G_FILIAL + C7G_ID + DTOS( C7G_DTMOV ) ) ==;
								xFilial( 'C7G' ) + C6J->( C6J_ID + DTOS( C6J_DTMOV ))


								If C14->( msSeek( xFilial( 'C14' ) + C7G->C7G_CSTICM ) ) .And.;
									C0Y->( msSeek( xFilial( 'C0Y' ) + C7G->C7G_CFOP ) )  
									If ( nPosD390 := aScan( aD390 , { | aX | AllTrim(aX[ 1 ]) == cOrigem+Alltrim(C14->C14_CODIGO) .And. AllTrim(aX[ 2 ]) == AllTrim(C0Y->C0Y_CODIGO) .And. aX[ 3 ] == C7G->C7G_ALQICM } ) ) == 0 
										aAdd( aD390 , { cOrigem+C14->C14_CODIGO , C0Y->C0Y_CODIGO , C7G->C7G_ALQICM , C7G->C7G_VLOPR ,;
														C7G->C7G_BCISSQ , C7G->C7G_ALISSQ, C7G->C7G_VLISSQ , C7G->C7G_BCICMS , C7G->C7G_VLICMS, cCodObs } )

										nPosD390	:=	Len( aD390 )
									EndIf
								EndIf
								C7G->( dbSkip() )	
							End							
						EndIf
						C6J->( dbSkip() )					 
					End

				EndIf

				( cAliasQry )->( dbSkip() )
			End
				
			//Atualizando valores de ISS no primeiro item
			If Len( aD390 ) > 0
				aD390[ 1 , 5 ]	+=	nBsIss
				aD390[ 1 , 7 ]	+=	nVlIss	
			EndIf

			LoadString( 'D390' , aCmps , @cStrTxt , cAliasQry , , , aD390 )
			
			aInfoGrv[5]++
			nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )

			TaFContBlc("D390",aTotRegD) 

			If nRWStrTxt == -1
				Exit
			EndIf
		EndIf
	EndIf
	
	If nRWStrTxt == -1
		Exit
	EndIf	
End
( cAliasQry )->( dbCloseArea() )

If nRWStrTxt == -1
	MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoD400
Funcao responsavel processar o movimento especifico para montagem dos registros:
 D400,D410,D411,D420 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlocoD400( dDataIni , dDataFim  )
Local	cQuery		:=	''
Local 	cAliasQry 	:=  GetNextAlias()
Local	aCmps		:=	DistrCmps()
Local	cChave		:=	''
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0
Local	lSeek		:=	.F.
Local	aD410		:=	{}
Local	aD420		:=	{}
Local	nPosD410	:=	0
Local	nPosD420	:=	0
Local	aMacro		:=	{}
Local	cCodMun		:= ''
Local	cMun		:= ''
Local	cUF			:= ''
Local	lC7B		:=	Select( 'C7B' ) > 0
	

/*---------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
----------------------------------------------------------*/
C2I->( dbSetOrder( 1 ) )
C7B->( dbSetOrder( 1 ) )


cQuery	+=	"SELECT "
cQuery	+=	"C20RMD.C20_FILIAL RMD_FILIAL, "
cQuery	+=	"C20RMD.C20_CHVNF RMD_CHVNF, "
cQuery	+=	"C1HRMD.C1H_CODPAR RMD_CODPAR, "
cQuery	+=	"C01RMD.C01_CODIGO RMD_CODMOD, "
cQuery	+=	"C02RMD.C02_CODIGO RMD_CODSIT, "
cQuery	+=	"C20RMD.C20_SERIE RMD_SERIE, "
cQuery	+=	"C20RMD.C20_SUBSER RMD_SUBSER, "
cQuery	+=	"C20RMD.C20_NUMDOC RMD_NUMDOC, "
cQuery	+=	"C20RMD.C20_DTDOC RMD_DTDOC, "
cQuery	+=	"C20RMD.C20_VLDOC RMD_VLDOC, "
cQuery	+=	"C20RMD.C20_VLDESC RMD_VLDESC, "
cQuery	+=	"C20RMD.C20_VLSERV RMD_VLSERV, "
cQuery	+=	"C1ORMD.C1O_CODIGO RMD_CODCTA, "
cQuery	+=	"C20.C20_CHVNF BIL_CHVNF, "
cQuery	+=	"C01.C01_CODIGO BIL_CODMOD, "
cQuery	+=	"C20.C20_SERIE BIL_SERIE, "
cQuery	+=	"C20.C20_SUBSER BIL_SUBSER, "
cQuery	+=	"C20.C20_NUMDOC BIL_NUMDOC, "
cQuery	+=	"C20.C20_DTDOC BIL_DTDOC, "
cQuery	+=	"C20.C20_VLDESC BIL_VLDESC, "
cQuery	+=	"C20.C20_VLSERV BIL_VLSERV, "
cQuery	+=	"C14.C14_CODIGO BIL_CST, "
cQuery	+=	"C0Y.C0Y_CODIGO BIL_CFOP, "
cQuery	+=	"C2F.C2F_ALIQ BIL_ALIQICMS, "
cQuery	+=	"SUM(C30.C30_VLOPER) BIL_VLOPR, "
cQuery	+=	"SUM(C2F.C2F_BASE) BIL_BCICMS, "
cQuery	+=	"SUM(C2F.C2F_VALOR) BIL_VLICMS, "
cQuery	+=	"(SELECT SUM(TRIB.C2F_BASE) FROM " + RetSqlName( 'C2F' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C2F_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='02' AND TRIB.C2F_FILIAL=C20RMD.C20_FILIAL AND TRIB.C2F_CHVNF=C20RMD.C20_CHVNF AND TRIB.D_E_L_E_T_=' ' ) RMD_BCICMS, "
cQuery	+=	"(SELECT SUM(TRIB.C2F_VALOR) FROM " + RetSqlName( 'C2F' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C2F_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='02' AND TRIB.C2F_FILIAL=C20RMD.C20_FILIAL AND TRIB.C2F_CHVNF=C20RMD.C20_CHVNF AND TRIB.D_E_L_E_T_=' ') RMD_VLICMS, "
cQuery	+=	"(SELECT SUM(TRIB.C2F_VALOR) FROM " + RetSqlName( 'C2F' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C2F_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='06' AND TRIB.C2F_FILIAL=C20RMD.C20_FILIAL AND TRIB.C2F_CHVNF=C20RMD.C20_CHVNF AND TRIB.D_E_L_E_T_=' ') RMD_VLPIS, "
cQuery	+=	"(SELECT SUM(TRIB.C2F_VALOR) FROM " + RetSqlName( 'C2F' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C2F_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='07' AND TRIB.C2F_FILIAL=C20RMD.C20_FILIAL AND TRIB.C2F_CHVNF=C20RMD.C20_CHVNF AND TRIB.D_E_L_E_T_=' ') RMD_VLCOFINS "

cQuery	+=	"FROM " 
cQuery	+=	RetSqlName( "C20" ) + " C20 " 
cQuery	+=	"JOIN " + RetSqlName( 'C20' ) + " C20RMD      ON(C20RMD.C20_FILIAL=C20.C20_FILIAL AND C20RMD.C20_CHVNF=C20.C20_IDRMD  AND C20RMD.D_E_L_E_T_=' ') "
cQuery	+=	"JOIN " + RetSqlName( 'C01' ) + " C01RMD      ON(C01RMD.C01_FILIAL='" + xFilial('C01') + "' AND C01RMD.C01_ID=C20RMD.C20_CODMOD AND C01RMD.D_E_L_E_T_=' ') "
cQuery	+=	"JOIN " + RetSqlName( 'C02' ) + " C02RMD      ON(C02RMD.C02_FILIAL='" + xFilial('C02') + "' AND C02RMD.C02_ID=C20RMD.C20_CODSIT AND C02RMD.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1O' ) + " C1ORMD ON(C1ORMD.C1O_FILIAL='" + xFilial('C1O') + "' AND C1ORMD.C1O_ID=C20RMD.C20_CODCTA AND C1ORMD.D_E_L_E_T_=' ') "
cQuery	+=	"JOIN " + RetSqlName( 'C1H' ) + " C1HRMD      ON(C1HRMD.C1H_FILIAL='" + xFilial('C1H') + "' AND C1HRMD.C1H_ID=C20RMD.C20_CODPAR AND C1HRMD.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C30' ) + " C30 ON(C30.C30_FILIAL=C20.C20_FILIAL AND C30.C30_CHVNF=C20.C20_CHVNF AND C30.D_E_L_E_T_=' ') "
cQuery	+=	"JOIN " + RetSqlName( 'C01' ) + " C01         ON(C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=C20.C20_CODMOD   AND C01.D_E_L_E_T_=' ') "
cQuery	+=	"JOIN " + RetSqlName( 'C2F' ) + " C2F         ON(C2F.C2F_FILIAL=C20.C20_FILIAL AND C2F.C2F_CHVNF=C20.C20_CHVNF AND C2F.D_E_L_E_T_=' ') "
cQuery	+=	"JOIN " + RetSqlName( 'C0Y' ) + " C0Y         ON(C0Y.C0Y_FILIAL='" + xFilial('C0Y') + "' AND C0Y.C0Y_ID=C2F.C2F_CFOP     AND C0Y.D_E_L_E_T_=' ') "
cQuery	+=	"JOIN " + RetSqlName( 'C14' ) + " C14         ON(C14.C14_FILIAL='" + xFilial('C14') + "' AND C14.C14_ID=C2F.C2F_CST      AND C14.D_E_L_E_T_=' ') "

cQuery	+=	"WHERE  "
cQuery	+=	"C20.C20_FILIAL='" + xFilial('C20') + "' AND "
cQuery	+=	"C20.C20_DTDOC>='" + DToS( dDataIni ) + "' AND " 
cQuery	+=	"C20.C20_DTDOC<='" + DToS( dDataFim ) + "' AND " 
cQuery	+=	"C20.D_E_L_E_T_=' ' AND "
cQuery	+=	"C20.C20_INDOPE='1' AND "
cQuery	+=	"C20.C20_IDRMD<>' ' AND "
cQuery	+=	"(C01.C01_CODIGO='13' OR C01.C01_CODIGO='14' OR C01.C01_CODIGO='15' OR C01.C01_CODIGO='16') "

cQuery	+=	"GROUP BY "
cQuery	+=	"C20RMD.C20_FILIAL, "
cQuery	+=	"C20RMD.C20_CHVNF, "
cQuery	+=	"C1HRMD.C1H_CODPAR, "
cQuery	+=	"C01RMD.C01_CODIGO, "
cQuery	+=	"C02RMD.C02_CODIGO, "
cQuery	+=	"C20RMD.C20_SERIE, "
cQuery	+=	"C20RMD.C20_SUBSER, "
cQuery	+=	"C20RMD.C20_NUMDOC, "
cQuery	+=	"C20RMD.C20_DTDOC, "
cQuery	+=	"C20RMD.C20_VLDOC, "
cQuery	+=	"C20RMD.C20_VLDESC, "
cQuery	+=	"C20RMD.C20_VLSERV, "
cQuery	+=	"C1ORMD.C1O_CODIGO, "
cQuery	+=	"C20.C20_CHVNF, "
cQuery	+=	"C01.C01_CODIGO, "
cQuery	+=	"C20.C20_SERIE, "
cQuery	+=	"C20.C20_SUBSER, "
cQuery	+=	"C20.C20_NUMDOC, "
cQuery	+=	"C20.C20_DTDOC, "
cQuery	+=	"C20.C20_VLDESC, "
cQuery	+=	"C20.C20_VLSERV, "
cQuery	+=	"C14.C14_CODIGO, "
cQuery	+=	"C0Y.C0Y_CODIGO, "
cQuery	+=	"C2F.C2F_ALIQ "

cQuery	+=	"ORDER BY "
cQuery	+=	"C20RMD.C20_FILIAL, "
cQuery	+=	"C20RMD.C20_CHVNF, "
cQuery	+=	"C20.C20_CHVNF "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

TcSetField( cAliasQry , "RMD_DTDOC" , "D" , 8 , 0 )
TcSetField( cAliasQry , "BIL_DTDOC" , "D" , 8 , 0 )

lC7B		:=	Select( 'C7B' ) > 0

DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop( ) )  

//LACO DO RMD
While ( cAliasQry )->( !Eof() )

	If !lGerD001
	
		aMacro	:=	{}
		aAdd( aMacro , "0" )
		
		LoadString( 'D001' , aCmps , @cStrTxt, , , aMacro )
		
		aInfoGrv[5]++
		WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )
		
		TaFContBlc("D001",aTotRegD)
		
		lGerD001 := .T.
	EndIf
		
	//GRAVACAO DO REGISTRO D400
	LoadString( 'D400' , aCmps , @cStrTxt , cAliasQry )
	
	aInfoGrv[5]++
	nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
	
	TaFContBlc("D400",aTotRegD)
	
	If nRWStrTxt >= 0
	
		//PROCESSAMENTO DO REGISTRO D410, FILHO DO D400
		cChave	:=	( cAliasQry )->( RMD_FILIAL + RMD_CHVNF )
		While ( cAliasQry )->( !Eof() ) .And. ( cAliasQry )->( RMD_FILIAL + RMD_CHVNF ) == cChave
		
			cChvNf	:=	Alltrim((cAliasQry)->BIL_CHVNF)
			aD410	:=	{}
			If ( nPosD410 := ( cAliasQry )->( aScan( aD410 , { | aX | aX[ 1 ] == BIL_CODMOD .And. aX[ 2 ] == BIL_SERIE .And. aX[ 3 ] == BIL_SUBSER .And. aX[ 6 ] == BIL_DTDOC .And. aX[ 7 ] == BIL_CST .And. aX[ 8 ] == BIL_CFOP .And. aX[ 9 ] == BIL_ALIQICMS } ) ) ) == 0
				( cAliasQry )->( aAdd( aD410 , { BIL_CODMOD , BIL_SERIE , BIL_SUBSER , BIL_NUMDOC , '' , BIL_DTDOC , '0'+BIL_CST , BIL_CFOP , BIL_ALIQICMS , 0 , BIL_VLDESC , BIL_VLSERV , 0 , 0 } ) )
				nPosD410	:=	Len( aD410 )
			EndIf
			
			aD410[ nPosD410 , 05 ]	:=	( cAliasQry )->BIL_NUMDOC
			aD410[ nPosD410 , 10 ]	+=	( cAliasQry )->BIL_VLOPR
			aD410[ nPosD410 , 13 ]	+=	( cAliasQry )->BIL_BCICMS
			aD410[ nPosD410 , 14 ]	+=	( cAliasQry )->BIL_VLICMS
			
			//PROCESSO DO REGISTRO D420, FILHO DO D400	
			
			//Setando Indices para Seeks no Processamento
			C09->(DbSetOrder(3))
			C07->(DbSetOrder(4))
			
			//Seek na Tabela de Complemento Documentos Informa
			If C7B->( MsSeek( xFilial( "C7B" ) + cChvNf ) )
				cUF	 := Alltrim(C7B->C7B_UF)
				cMun := Alltrim(C7B->C7B_CODMUN)
			EndIf
			
			//Busca do Código do Municipio
			dbSelectArea("C09")
			C09->(dBSetOrder(3))
			If C09->( MsSeek( xFilial( "C09" ) + cUF ) )
			dbSelectArea("C07")
				C07->(dBSetOrder(4))	
				If C07->( MsSeek( xFilial( "C07" ) + cUF + cMun ) )
					cCodMun := ( Alltrim(C09->C09_CODIGO) + Alltrim(C07->C07_CODIGO) )
				EndIf
			EndIf 	

			If( nPosD420 :=  aScan( aD420 , { | aX | aX[ 1 ] == ( cCodMun ) } )) == 0
				aAdd( aD420 , { cCodMun , 0 , 0 , 0 } ) 
				nPosD420	:=	Len( aD420 )
			EndIf
			
			aD420[ nPosD420 , 2 ]	+=	C7B->C7B_VLSERV
			aD420[ nPosD420 , 3 ]	+=	C7B->C7B_VLBCIC
			aD420[ nPosD420 , 4 ]	+=	C7B->C7B_VLICMS
			
       	//GRAVACAO DO REGISTRO D410, FILHO DO D400
		
			LoadString( 'D410' , aCmps , @cStrTxt , cAliasQry , , , aD410 )
		
			aInfoGrv[5]++
			nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )

			TaFContBlc("D410",aTotRegD)
		
			//GRAVACAO DO REGISTRO D411, FILHO DO D410
			If nRWStrTxt >= 0 .And. C2I->(msSeek( xFilial( 'C2I' ) + cChvNf ) )
			
				aD411 := {}
			
				While C2I->( !Eof() ) .And. C2I->( C2I_FILIAL + C2I_CHVNF ) == xFilial( 'C2I' ) + cChvNf
			     
					LoadString( 'D411' ,  aCmps , @cStrTxt , , , , )
					
					TaFContBlc("D411",aTotRegD)
					
					aInfoGrv[5]++
				
					If ( nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' ) ) == -1
						Exit
					EndIf
			
					C2I->( dbSkip() )
				End
			
			EndIf         
           			
			( cAliasQry )->( dbSkip() )
			
		End

	EndIf

	//GRAVACAO DO REGISTRO D420, FILHO DO D400						
	LoadString( 'D420' , aCmps , @cStrTxt , cAliasQry , , , aD420 )
		
	aInfoGrv[5]++
	nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
		
	TaFContBlc("D420",aTotRegD) 	
		
	If nRWStrTxt == -1
		Exit
	EndIf
		
End

( cAliasQry )->( dbCloseArea() )

If nRWStrTxt == -1
	MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoD500
Funcao responsavel processar o movimento especifico para montagem dos registros:
 D500,D510,D530,D590,D600,D610,D690 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aRegD600	->	Array com os valores acumulados para o registro D600
		aRegD610	->	Array com os valores acumulados para o registro D610
		aRegD690	->	Array com os valores acumulados para o registro D690
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlocoD500( dDataIni , dDataFim ,  aRegD600 , aRegD610 , aRegD690 , cPerfilSPD, lConv115 )
Local	cQuery		:=	''
Local 	cAliasQry 	:=  GetNextAlias()
Local	aCmps		:=	DistrCmps()
Local	cChave		:=	''
Local	cStrTxt		:=	''
Local	nRWStrTxt	:=	0
Local	lSeek		:=	.F.
Local	aD510		:=	{}
Local	aD590		:=	{}
Local	nPosD590	:=	0
Local	aMacro		:=	{}
Local	nX			:=	0
Local	nY			:=	0
Local  lD500 		:= .F.

/*----------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
----------------------------------------------------------*/
C2G->( dbSetOrder( 1 ) )
C21->( dbSetOrder( 1 ) )
C3Q->( dbSetOrder( 3 ) )
C35->( dbSetOrder( 1 ) )
C3S->( dbSetOrder( 3 ) )
C14->( dbSetOrder( 3 ) )

cQuery	+=	"SELECT "
cQuery	+=	"C20.C20_FILIAL, "
cQuery	+=	"C20.C20_CHVNF, "
cQuery	+=	"C20.C20_INDOPE, "
cQuery	+=	"C20.C20_INDEMI, "
cQuery	+=	"C1H.C1H_CODPAR, "
cQuery	+=	"C09.C09_CODIGO, "
cQuery	+=	"C07.C07_CODIGO, "
cQuery	+=	"C01.C01_CODIGO, "
cQuery	+=	"C02.C02_CODIGO, "
cQuery	+=	"C20.C20_SERIE, "
cQuery	+=	"C20.C20_SUBSER, "
cQuery	+=	"C20.C20_NUMDOC, "
cQuery	+=	"C20.C20_DTDOC, "
cQuery	+=	"C20.C20_DTES, "
cQuery	+=	"C20.C20_VLDOC, "
cQuery	+=	"C20.C20_VLDESC, "
cQuery	+=	"C20.C20_VLRDA, "
cQuery	+=	"C20.C20_VLOUDE, "
cQuery	+=	"C1O.C1O_CODIGO, "
cQuery	+=	"C30.C30_NUMITE, "
cQuery	+=	"C30.C30_CODITE, "
cQuery	+=	"C1L.C1L_CODIGO, "
cQuery	+=	"C30.C30_QUANT, "
cQuery	+=	"C30.C30_VLRITE, "
cQuery	+=	"C30.C30_VLOPER, "
cQuery	+=	"C30.C30_VLDESC, "
cQuery	+=	"C0Y.C0Y_CODIGO, "
cQuery	+=	"C1OITEM.C1O_CODIGO IT_CCTA, "
cQuery	+=	"C1J.C1J_CODIGO, "
cQuery	+=	"C0K.C0K_CODIGO, "
cQuery	+=	"C38.C38_INDREC, "
cQuery	+=	"C1HITEM.C1H_CODPAR IT_CODPAR, "
cQuery	+=	"(SELECT SUM(C2F.C2F_BASE) FROM " + RetSqlName( 'C2F' ) + " C2F, " + RetSqlName( "C3S" ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND C2F.C2F_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='02' AND C2F.C2F_FILIAL=C20.C20_FILIAL AND C2F.C2F_CHVNF=C20.C20_CHVNF AND C2F.D_E_L_E_T_=' ' ) BCICMS, "
cQuery	+=	"(SELECT SUM(C2F.C2F_VALOR) FROM " + RetSqlName( 'C2F' ) + " C2F," + RetSqlName( "C3S" ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND C2F.C2F_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='02' AND C2F.C2F_FILIAL=C20.C20_FILIAL AND C2F.C2F_CHVNF=C20.C20_CHVNF AND C2F.D_E_L_E_T_=' ') VLICMS, "
cQuery	+=	"(SELECT SUM(C2F.C2F_VALOR) FROM " + RetSqlName( 'C2F' ) + " C2F," + RetSqlName( "C3S" ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND C2F.C2F_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='06' AND C2F.C2F_FILIAL=C20.C20_FILIAL AND C2F.C2F_CHVNF=C20.C20_CHVNF AND C2F.D_E_L_E_T_=' ') VLPIS, "
cQuery	+=	"(SELECT SUM(C2F.C2F_VALOR) FROM " + RetSqlName( 'C2F' ) + " C2F," + RetSqlName( "C3S" ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND C2F.C2F_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='07' AND C2F.C2F_FILIAL=C20.C20_FILIAL AND C2F.C2F_CHVNF=C20.C20_CHVNF AND C2F.D_E_L_E_T_=' ') VLCOFINS, "
cQuery	+=	"C03.C03_CODIGO, "
cQuery	+=	"C1H.C1H_FILIAL, "
cQuery	+=	"C1L.C1L_FILIAL, "
cQuery	+=	"C1HITEM.C1H_FILIAL IT_FILIAL, "
cQuery	+=	"C1J.C1J_FILIAL, "
cQuery	+=	"C1OITEM.C1O_FILIAL CTA_FILIAL "

cQuery	+=	"FROM " + RetSqlName( 'C20' ) + " C20 "
cQuery	+=	"JOIN " + RetSqlName( 'C01' ) + " C01 ON(C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=C20.C20_CODMOD AND C01.D_E_L_E_T_=' ') "
cQuery	+=	"JOIN " + RetSqlName( 'C02' ) + " C02 ON(C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID=C20.C20_CODSIT AND C02.D_E_L_E_T_=' ') "
cQuery	+=	"JOIN " + RetSqlName( 'C1H' ) + " C1H ON(C1H.C1H_FILIAL='" + xFilial('C1H') + "' AND C1H.C1H_ID=C20.C20_CODPAR AND C1H.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1O' ) + " C1O ON(C1O.C1O_FILIAL='" + xFilial('C1O') + "' AND C1O.C1O_ID=C20.C20_CODCTA AND C1O.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C30' ) + " C30 ON(C30.C30_FILIAL=C20.C20_FILIAL AND C30.C30_CHVNF=C20.C20_CHVNF AND C30.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1J' ) + " C1J ON(C1J.C1J_FILIAL='" + xFilial('C1J') + "' AND C1J.C1J_ID=C30.C30_UM AND C1J.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C38' ) + " C38 ON(C38.C38_FILIAL=C30.C30_FILIAL AND C38.C38_CHVNF=C30.C30_CHVNF AND C38.C38_NUMITE=C30.C30_NUMITE AND C38.C38_CODITE=C30.C30_CODITE AND C38.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1O' ) + " C1OITEM ON(C1OITEM.C1O_FILIAL='" + xFilial('C1O') + "' AND C1OITEM.C1O_ID=C30.C30_CTACTB AND C1OITEM.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1H' ) + " C1HITEM ON(C1HITEM.C1H_FILIAL='" + xFilial('C1H') + "' AND C1HITEM.C1H_ID=C38.C38_CODPAR AND C1HITEM.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0Y' ) + " C0Y ON(C0Y.C0Y_FILIAL='" + xFilial('C0Y') + "' AND C0Y.C0Y_ID=C30.C30_CFOP AND C0Y.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1L' ) + " C1L ON(C1L.C1L_FILIAL='" + xFilial('C1L') + "' AND C1L.C1L_ID=C30.C30_CODITE AND C1L.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C07' ) + " C07 ON(C07.C07_FILIAL='" + xFilial('C09') + "' AND C07.C07_ID=C1H.C1H_CODMUN AND C07.D_E_L_E_T_=' ')
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C09' ) + " C09 ON(C09.C09_FILIAL='" + xFilial('C07') + "' AND C09.C09_ID=C1H.C1H_UF AND C09.D_E_L_E_T_=' ')
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0K' ) + " C0K ON(C0K.C0K_FILIAL='" + xFilial('C0K') + "' AND C0K.C0K_ID=C38.C38_CCLASS AND C0K.D_E_L_E_T_=' ')
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C03' ) + " C03 ON(C03.C03_FILIAL='" + xFilial('C03') + "' AND C03.C03_ID=C30.C30_ORIGEM AND C03.D_E_L_E_T_=' ') "

cQuery	+=	"WHERE "
cQuery	+=	"C20.C20_FILIAL='" + xFilial('C20') + "' AND  "
cQuery +=	"((C20.C20_INDOPE = '0' AND C20.C20_DTES  >= '" + DTOS(dDataIni) + "' AND C20.C20_DTES  <='"  + DTOS(dDataFim) + "') OR "
cQuery +=	" (C20.C20_INDOPE = '1' AND C20.C20_DTDOC >= '" + DTOS(dDataIni) + "' AND C20.C20_DTDOC <='"  + DTOS(dDataFim) + "')) AND "
cQuery	+=	"C20.D_E_L_E_T_=' ' AND  "
cQuery	+=	"(C01.C01_CODIGO='21' OR C01.C01_CODIGO='22') "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

TcSetField( cAliasQry , "C20_DTDOC" , "D" , 8 , 0 )
TcSetField( cAliasQry , "C20_DTES" , "D" , 8 , 0 )

While ( cAliasQry )->( !Eof() )

	cIndOp	:=	( cAliasQry )->C20_INDOPE
	
	If (cIndOp == "1" .And. !lConv115) .Or. cIndOp == "0"
	
		If !lGerD001       
		
			aMacro	:=	{}
			aAdd( aMacro , "0" )
			
			LoadString( 'D001' , aCmps , @cStrTxt, , , aMacro )
			
			aInfoGrv[5]++
			WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv ) 
			
			TaFContBlc("D001",aTotRegD) 	
			
		 	lGerD001 := .T.
		EndIf
			
		cChave	:=	( cAliasQry )->C20_CHVNF		
		aMacro	:=	{}
		aD510	:=	{ { '' , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } }
		aD590	:=	{}
		
		lSeek	:=	C2G->( msSeek( xFilial( 'C2G' ) + cChave ) )
		 
		If (cPerfilSPD $ "A|C" .And. cIndOp $ "0|1")  .Or. (cPerfilSPD == "B" .And. cIndOp=="0" ) 
			
			aAdd( aMacro, "C21->( msSeek( xFilial( 'C21' ) + '" + cChave + "' ) ) .And. C3Q->( msSeek( xFilial( 'C3Q' ) + C21->C21_CODINF ) )" )
	
			//GRAVACAO DO REGISTRO D500
			LoadString( 'D500' , aCmps , @cStrTxt , cAliasQry , lSeek , aMacro )
		
			aInfoGrv[5]++
			nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
		
			TaFContBlc("D500",aTotRegD) 
			
			lD500:= .T.	
			
		EndIf		
		
		//PROCESSANDO CONSOLIDACAO DOS REGISTROS
		If cIndOp == '1' .And. !lConv115
			nPosD600 := ConsD600( cAliasQry , @aRegD600 )
		EndIf
		
		If nRWStrTxt >= 0		
			While ( cAliasQry )->( !Eof() ) .And. ( cAliasQry )->( C20_FILIAL + C20_CHVNF ) == xFilial( 'C20' ) + cChave
	                                                     
				If C35->( msSeek( xFilial( 'C35' ) + cChave + ( cAliasQry )->( C30_NUMITE + C30_CODITE ) ) )
					
					While C35->( !Eof() ) .And. C35->( C35_FILIAL + C35_CHVNF + C35_NUMITE + C35_CODITE ) == xFilial( 'C35' ) + cChave + ( cAliasQry )->( C30_NUMITE + C30_CODITE )
					
						If C3S->( msSeek( xFilial( 'C3S' ) + C35->C35_CODTRI ) )
	
							If C3S->C3S_CODIGO == '02'
								//PROCESSANDO ALGUNS VALORES DE TRIBUTOS PARA O ITEM
								If C14->( msSeek( xFilial( 'C14' ) + C35->C35_CST ) )
									aD510[ 1 , 1 ]	:=	C03_CODIGO+C14->C14_CODIGO
								EndIf
								aD510[ 1 , 2 ]	+=	C35->C35_BASE
								aD510[ 1 , 3 ]	:=	C35->C35_ALIQ
								aD510[ 1 , 4 ]	+=	C35->C35_VALOR
								aD510[ 1 , 5 ]	:=	C35->C35_VLBCUF
								aD510[ 1 , 6 ]	+=	C35->C35_VLUF
								
								//PROCESSANDO VALORES CONSOLIDADOS PARA O D590
								//nPosD590 := ( cAliasQry )->( aScan( aD590 , { | aX | aX[ 1 ] == aD510[ 1 ] .And. aX[ 2 ] == C0Y_CODIGO .And. aX[ 3 ] == aD510[ 3 ] } ) )
								nPosD590 :=  ( cAliasQry )->( aScan( aD590 , { | aX | aX[ 1 ] == aD510[ 1,1 ] .And. aX[ 2 ] == C0Y_CODIGO .And. aX[ 3 ] == aD510[ 1,3 ] } ) )
								If nPosD590 == 0
									( cAliasQry )->( aAdd( aD590 , { aD510[ 1 , 1 ] , ( cAliasQry )->C0Y_CODIGO , aD510[ 1 , 3 ] , 0 , 0 , 0 , 0 , 0 , 0 , '' } ) )
									nPosD590	:=	Len( aD590 )
								EndIf
								
								aD590[ nPosD590 , 04 ]	+=	( cAliasQry )->C30_VLOPER
								aD590[ nPosD590 , 05 ]	+=	C35->C35_BASE
								aD590[ nPosD590 , 06 ]	+=	C35->C35_VALOR
								aD590[ nPosD590 , 07 ]	+=	C35->C35_VLBCUF
								aD590[ nPosD590 , 08 ]	+=	C35->C35_VLUF
								aD590[ nPosD590 , 09 ]	+=	C35->C35_VLNT
								aD590[ nPosD590 , 10 ]	:=	Iif( &( aMacro[ 1 ] ) , xGerBlc0( "0450",  Alltrim( C3Q->( C3Q_CODINF ) ), cFilSelBc, aWizardBc, cTabSpd ) , '' )
								
								aD510[ 1 , 9 ]	+=	C35->C35_VLNT
								
							ElseIf C3S->C3S_CODIGO == '06'
								aD510[ 1 , 7 ]	+=	C35->C35_VALOR
								
							ElseIf C3S->C3S_CODIGO == '07'
								aD510[ 1 , 8 ]	+=	C35->C35_VALOR
							EndIf
						EndIf
						
						C35->( dbSkip() )
	              EndDo
	              
	              If cPerfilSPD=="A" .And. cIndOp=="1" //Perfil A e Nota de Saída
		              //GRAVACAO DO REGISTRO D510
						LoadString( 'D510' , aCmps , @cStrTxt , cAliasQry , , , aD510 )
						
						aInfoGrv[5]++
						nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
						
						TaFContBlc("D510",aTotRegD)
					EndIf 				
	                
					If nRWStrTxt == -1
						Exit
					EndIf
					
					//PROCESSANDO CONSOLIDACAO DOS REGISTROS
					If cPerfilSPD=="B" .And. cIndOp == '1'
						ConsD610( cAliasQry , @aRegD610 , aD510 , nPosD600 )
					EndIf 
	
				EndIf
				( cAliasQry )->( dbSkip() )
			EndDo
			
			// Demetrio 
			If nRWStrTxt >= 0 .And. lSeek .AND. cPerfilSPD=="A" .And. cIndOp=="1" //Perfil A e Nota de Saída
				While C2G->( !Eof() ) .And. C2G->( C2G_FILIAL + C2G_CHVNF ) == xFilial( 'C2G' ) + cChave
					
					//Tratamento para que o registro D530 nao seja gerado em branco quando não existir informação
					If !Empty( C2G->C2G_INDSER )
						//GRAVACAO DO REGISTRO D530
						LoadString( 'D530' , aCmps , @cStrTxt , cAliasQry )
						
						aInfoGrv[5]++
						nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
						
						TaFContBlc("D530",aTotRegD) 
					EndIf						
					C2G->( dbSkip() )
				End
			EndIf
			
			If nRWStrTxt >= 0 .And. ! cPerfilSPD=="B" .And. ! cIndOp=="1" .And. lD500//Perfil B, Nota de Saída e Existe Reg D500
				//GRAVACAO DO REGISTRO D590
				LoadString( 'D590' , aCmps , @cStrTxt , cAliasQry , , , aD590 )
				
				aInfoGrv[5]++
				nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
				
				TaFContBlc("D590",aTotRegD) 			
				
			EndIf
			
			If cPerfilSPD=="B" .And. cIndOp=='1'
				D590TOD690( aD590 , @aRegD690 , nPosD600 )
			EndIf
			
		EndIf
	
		If nRWStrTxt == -1
			Exit
		EndIf
		
	  Endif
	End
	 
( cAliasQry )->( dbCloseArea() )

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ConsD600
Funcao responsavel por consolidar os valores do movimento em um array para gerar depois os respectivos registros

@param	cAliasQry	-> 	Alias da query em processamento
		aRegD600	->	Array a ter os valores consolidados
		
@return nPos		->	Posicao para relacionamento com os registros filhos

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConsD600( cAliasQry , aRegD600 )
Local	nPos	:=	0   
Local   nConsumo:= ""

If ( nPos := ( cAliasQry )->( aScan( aRegD600 , { | aX | aX[ 1 ] == C01_CODIGO .And. aX[ 2 ] == C09_CODIGO+C07_CODIGO .And. aX[ 3 ] == C20_SERIE .And. aX[ 4 ] == C20_SUBSER .And. aX[ 5 ] == C2G->C2G_CCONS .And. aX[ 7 ] == C20_DTDOC } ) ) ) == 0 
 
	C0M-> ( DbSetOrder( 3 ) )
	If (C0M-> ( DbSeek ( xFilial("C0M") + C2G->C2G_CCONS ) )) 
       nConsumo := C0M->C0M_CODIGO
	EndIf


	( cAliasQry )->( aAdd( aRegD600 ,;
		{C01_CODIGO,;
		C09_CODIGO+C07_CODIGO,;
		C20_SERIE,;
		C20_SUBSER,;
		nConsumo,;
		1,;
		C20_DTDOC,;
		C20_VLDOC,;
		C20_VLDESC,;
		C2G->C2G_VLSERV,;
		C2G->C2G_VSERNT,;
		C2G->C2G_VLTERC,;
		C20_VLRDA + C20_VLOUDE,;
		BCICMS,;
		VLICMS,;
		VLPIS,;
		VLCOFINS,;
		C20_INDOPE } ) )
		
		nPos := Len( aRegD600 )
Else
	aRegD600[ nPos , 06 ]	+=	1
 	aRegD600[ nPos , 08 ]	+=	( cAliasQry )->C20_VLDOC
 	aRegD600[ nPos , 09 ]	+=	( cAliasQry )->C20_VLDESC
 	aRegD600[ nPos , 10 ]	+=	C2G->C2G_VLSERV
 	aRegD600[ nPos , 11 ]	+=	C2G->C2G_VSERNT
 	aRegD600[ nPos , 12 ]	+=	C2G->C2G_VLTERC
 	aRegD600[ nPos , 13 ]	+=	( cAliasQry )->( C20_VLRDA + C20_VLOUDE )
 	aRegD600[ nPos , 14 ]	+=	( cAliasQry )->BCICMS
 	aRegD600[ nPos , 15 ]	+=	( cAliasQry )->VLICMS
 	aRegD600[ nPos , 16 ]	+=	( cAliasQry )->VLPIS
 	aRegD600[ nPos , 17 ]	+=	( cAliasQry )->VLCOFINS
EndIf

Return nPos
//-------------------------------------------------------------------
/*/{Protheus.doc} ConsD610
Funcao responsavel por consolidar os valores do movimento em um array para gerar depois os respectivos registros

@param	cAliasQry	-> 	Alias da query em processamento
		aRegD610	->	Array a ter os valores consolidados
		aRegProc	->	Array com valores auxiliares ja obtidos durante o processamento para outros registros
		nPosRelac	->	Posicao do array pai para relacionamento
		
@return nPos		->	Posicao para relacionamento com os registros filhos

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConsD610( cAliasQry , aRegD610 , aRegProc , nPosRelac)
Local	nPos	:=	0

If ( nPos := ( cAliasQry )->( aScan( aRegD610 , { | aX | aX[ 1 ] == nPosRelac .And. aX[ 3 ] == C1L_CODIGO .And. aX[ 8 ] == aRegProc[ 1 , 1 ] .And. aX[ 9 ] == C0Y_CODIGO .And. aX[ 10 ] == aRegProc[ 1 , 3 ] } ) ) ) == 0 
	
	If !Empty( C1J_CODIGO )		
		xGerBlc0( "0190",  Alltrim( Right( Alltrim(C1J_CODIGO), 6 )), cFilSelBc, aWizardBc, cTabSpd )
	EndIf
	
	If !Empty( C1L_CODIGO )		
		xGerBlc0( "0200",  Alltrim( C1L_CODIGO ), cFilSelBc, aWizardBc, cTabSpd, Alltrim( Right( Alltrim(C1J_CODIGO), 6 )) )
	EndIf		
		
	( cAliasQry )->( aAdd( aRegD610 ,;	
		{nPosRelac,;
		C0K_CODIGO,;
		C1L_CODIGO,;
		C30_QUANT,;
		Alltrim( Right( Alltrim(C1J_CODIGO), 6 )),;
		C30_VLRITE,;
		C30_VLDESC,;
		aRegProc[ 1 , 1 ],;
		C0Y_CODIGO,;
		aRegProc[ 1 , 3 ],;
		aRegProc[ 1 , 2 ],;
		aRegProc[ 1 , 4 ],;
		aRegProc[ 1 , 5 ],;
		aRegProc[ 1 , 6 ],;
		aRegProc[ 1 , 9 ],;
		aRegProc[ 1 , 7 ],;
		aRegProc[ 1 , 8 ],;
		IT_CCTA } ) )
		
		nPos := Len( aRegD610 )
Else
	aRegD610[ nPos , 04 ]	+=	( cAliasQry )->C30_QUANT
 	aRegD610[ nPos , 06 ]	+=	( cAliasQry )->C30_VLRITE
 	aRegD610[ nPos , 07 ]	+=	( cAliasQry )->C20_VLDESC
 	aRegD610[ nPos , 11 ]	+=	aRegProc[ 1 , 2 ]
 	aRegD610[ nPos , 12 ]	+=	aRegProc[ 1 , 4 ]
 	aRegD610[ nPos , 13 ]	+=	aRegProc[ 1 , 5 ]
 	aRegD610[ nPos , 14 ]	+=	aRegProc[ 1 , 6 ]
 	aRegD610[ nPos , 15 ]	+=	aRegProc[ 1 , 9 ]
 	aRegD610[ nPos , 16 ]	+=	aRegProc[ 1 , 7 ]
 	aRegD610[ nPos , 17 ]	+=	aRegProc[ 1 , 8 ]
EndIf

Return nPos
//-------------------------------------------------------------------
/*/{Protheus.doc} D590TOD690
Funcao responsavel por consolidar os valores do movimento em um array para gerar depois os respectivos registros.
	Como jah foi montado um array para um outro registro D590, utilizo o mesmo para montar o outro registro D690
	que tem a mesma estrutura, porem para todo o movimento.

@param	aD590	->	Array com as informacoes a sere transportadas
		aD690	->	Array destino das informacoes
		nPosRelac	->	Posicao do array pai para relacionamento
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function D590TOD690( aD590 , aD690 , nPosRelac )
Local	nPos	:=	0
Local	nX		:=	0
Local	nY		:=	0
                     
For nX := 1 To Len( aD590 )

	If ( nPos := aScan(	aD690 , { | aX | aX[ 1 ] == nPosRelac .And. aX[ 2 ] == aD590[ nX , 1 ] .And. aX[ 3 ] == aD590[ nX , 2 ] .And. aX[ 4 ] == aD590[ nX , 3 ] } ) ) == 0
		aAdd( aD690 , {} )
		nPos := Len( aD690 )
		
		aAdd( aD690[ nPos ] , nPosRelac )
		For nY := 1 To Len( aD590[ nX ] )
			aAdd( aD690[ nPos ] , aD590[ nX , nY ] )
		Next nY
	Else
		aD690[ nX , 05 ]	+=	aD590[ nX , 04 ]
		aD690[ nX , 06 ]	+=	aD590[ nX , 05 ]
		aD690[ nX , 07 ]	+=	aD590[ nX , 06 ]
		aD690[ nX , 08 ]	+=	aD590[ nX , 07 ]
		aD690[ nX , 09 ]	+=	aD590[ nX , 08 ]
		aD690[ nX , 10 ]	+=	aD590[ nX , 09 ]
	EndIf	
Next nX

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoD600
Funcao responsavel processar o movimento especifico para montagem dos registros:
 D600,D610,D690 do EFD Fiscal

@param	aRegD600	->	Array com os valores acumulados para o registro D600
		aRegD610	->	Array com os valores acumulados para o registro D610
		aRegD690	->	Array com os valores acumulados para o registro D690
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlocoD600( aRegD600 , aRegD610 , aRegD690, cPerfilSPD  )
Local	aCmps		:=	DistrCmps()
Local	cStrTxt		:=	''
Local	nX			:=	1
Local	nY			:=	1
Local	nRWStrTxt	:=	0
Local	cIndOp	



If Len( aRegD600 ) > 0
	For nX := 1 To Len( aRegD600 )
   
   		cIndOp:= aRegD600[nX][18]
   
   		If cPerfilSPD=="B" .And. cIndOp=="1"
   		
			//GRAVACAO DO REGISTRO D600
			LoadString( 'D600' , aCmps , @cStrTxt , , , , { aRegD600[ nX ] } )
		
			aInfoGrv[5]++
			nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
		
			TaFContBlc("D600",aTotRegD) 		
	
			If nRWStrTxt >= 0
				//GRAVACAO DO REGISTRO D610
				aSort( aRegD610 , , , { | aX , aY | aX[ 1 ] < aY[ 1 ] } )
				For nY := 1 To Len( aRegD610 )
					If aRegD610[ nY , 1 ] == nX
						LoadString( 'D610' , aCmps , @cStrTxt , , , , { aRegD610[ nY ] } , .T. )
					
						aInfoGrv[5]++
						nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
					
						TaFContBlc("D610",aTotRegD) 
								
					EndIf
				Next nY
			EndIf
		
			If nRWStrTxt >= 0
				//GRAVACAO DO REGISTRO D690
				aSort( aRegD690 , , , { | aX , aY | aX[ 1 ] < aY[ 1 ] } )	
				For nY := 1 To Len( aRegD690 )
					If aRegD690[ nY , 1 ] == nX
						LoadString( 'D690' , aCmps , @cStrTxt , , , , { aRegD690[ nY ] } , .T. )	//utilizo o mesmo array do D590, pois as informacoes sao exatamente as mesmas
					
						aInfoGrv[5]++
						nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
					
						TaFContBlc("D690",aTotRegD) 					

					EndIf
				Next nY
			EndIf
			
		EndIf
		
	Next nX
EndIf

If nRWStrTxt == -1
	MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
EndIf

Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoD695
Funcao responsavel processar o movimento especifico para montagem dos registros:
 D695,D696,D697 do EFD Fiscal

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlocoD695( dDataIni , dDataFim  )
Local	cQuery		:=	''
Local 	cAliasQry 	:=  GetNextAlias()
Local	aCmps		:=	DistrCmps()
Local	cChave		:=	''
Local	cChave2		:=	''
Local	cStrTxt		:=	''
Local	cStrTxt2	:=	''
Local	cCodObs		:=	''
Local	nRWStrTxt	:=	0
Local	nPos		:=	0
Local	aRegD695	:=	{}
Local	aRegD696	:=	{}
Local	aRegD697	:=	{}

/*----------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
----------------------------------------------------------*/

cQuery += " SELECT "
cQuery += " C77.C77_ID, "
cQuery += " C01.C01_CODIGO, "
cQuery += " C77.C77_DTMOV , "
cQuery += " C77.C77_CODMOD, "
cQuery += " C77.C77_NSER  , "
cQuery += " C77.C77_NORDIN, "
cQuery += " C77.C77_NORDFI, "
cQuery += " C77.C77_DTDOCI, "
cQuery += " C77.C77_DTDOCF, "
cQuery += " C77.C77_NODCFI, "
cQuery += " C77.C77_CHVDIG, "
cQuery += " C78.C78_CSTICM, "
cQuery += " C78.C78_CFOP,   "
cQuery += " C14.C14_CODIGO, "
cQuery += " C0Y.C0Y_CODIGO, "
cQuery += " C78.C78_ALQICM, "
cQuery += " C78.C78_VLOPR , "
cQuery += " C78.C78_VLBCIC, "
cQuery += " C78.C78_VLICMS, "
cQuery += " C78.C78_VLBIUF, "
cQuery += " C78.C78_VLICUF, "
cQuery += " C78.C78_VLRDBC, "
cQuery += " C78.C78_CODOBS, "
cQuery += " C79.C79_CSTICM, "
cQuery += " C79.C79_CFOP  , "
cQuery += " C79.C79_ALQICM, "
cQuery += " C79.C79_UF    , "
cQuery += " C79.C79_VLBCIC, "
cQuery += " C79.C79_VLSTIC, "
cQuery += " C09.C09_UF,  "
cQuery += " C03.C03_CODIGO  "

cQuery	+=	"FROM " + RetSqlName( 'C77' ) + " C77 "
                                                                                                                                                       
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C78' ) + " C78 ON(C78.C78_FILIAL='" + xFilial('C78') + "' AND C78.C78_ID = C77.C77_ID AND C78.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C79' ) + " C79 ON(C79.C79_FILIAL='" + xFilial('C79') + "' AND C79.C79_ID = C78.C78_ID AND C79.C79_CSTICM = C78.C78_CSTICM AND C79.C79_CFOP = C78.C78_CFOP AND C79.C79_ALQICM = C78.C78_ALQICM AND C79.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C01' ) + " C01 ON(C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID = C77.C77_CODMOD AND C01.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C09' ) + " C09 ON(C09.C09_FILIAL='" + xFilial('C09') + "' AND C09.C09_ID=C79.C79_UF AND C09.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0Y' ) + " C0Y ON(C0Y.C0Y_FILIAL='" + xFilial('C0Y') + "' AND C0Y.C0Y_ID=C78.C78_CFOP AND C0Y.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C14' ) + " C14 ON(C14.C14_FILIAL='" + xFilial('C14') + "' AND C14.C14_ID=C78.C78_CSTICM AND C14.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C03' ) + " C03 ON(C03.C03_FILIAL='" + xFilial('C03') + "' AND C03.C03_ID=C78.C78_ORIMER AND C03.D_E_L_E_T_=' ') "

cQuery	+=	"WHERE "
cQuery	+=	"C77.C77_FILIAL='" + xFilial('C77') + "' AND "  
cQuery	+=	"C77.C77_DTMOV>='" + DToS( dDataIni ) + "' AND " 
cQuery	+=	"C77.C77_DTMOV<='" + DToS( dDataFim ) + "' AND " 
cQuery	+=	"C77.D_E_L_E_T_=' ' AND "
cQuery	+=	"(C01.C01_CODIGO='21' OR C01.C01_CODIGO='22')"
	
cQuery	+=	" ORDER BY 2, 3 , 7 , 8 , 9 "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

nTotReg := Contar(cAliasQry,"!Eof()")
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop( ) )    

If (nTotReg > 0)

	C2C->( dbSetOrder( 2 ) )
	C3R->( dbSetOrder( 3 ) )

	While ( cAliasQry )->( !Eof() )
	
		If !lGerD001       
			aMacro	:=	{}
			aAdd( aMacro , "0" )
			
			LoadString( 'D001' , aCmps , @cStrTxt, , , aMacro )
			
			aInfoGrv[5]++
			WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )      
			
			TaFContBlc("D001",aTotRegD) 		
	
		 	lGerD001 := .T.
		EndIf
	
		aRegD695:=	{}
		cChave	:=	( cAliasQry )->( C01_CODIGO + C77_NSER )	
			
		//Array para geracao do registro D695
		( cAliasQry )->( aAdd( aRegD695 , { C01_CODIGO , C77_NSER , C77_NORDIN , C77_NORDFI , C77_DTDOCI , C77_DTDOCF , C77_NODCFI , C77_CHVDIG } ) )
	
		While ( cAliasQry )->( !Eof() ) .And.;
			( cAliasQry )->( C01_CODIGO + C77_NSER ) == cChave
	
			aRegD696:=	{}
			aRegD697:=	{}
			cChave2	:=	( cAliasQry )->( C14_CODIGO + C0Y_CODIGO + Str( C78_ALQICM, 6 , 2 ) )	
			While ( cAliasQry )->( !Eof() ) .And.;
				( cAliasQry )->( C01_CODIGO + C77_NSER ) == cChave .And. ;
				( cAliasQry )->( C14_CODIGO + C0Y_CODIGO + Str( C78_ALQICM, 6 , 2 ) ) == cChave2
				
				cCodObs	:=	''
				If C2C->( msSeek( xFilial( 'C2C' ) + ( cAliasQry )->C78_CODOBS ) ) .And. C3R->( msSeek( xFilial( 'C3R' ) + C2C->C2C_CODOBS ) )
					cCodObs	:=	C3R->( C3R_CODIGO )
				EndIf
				
				//Array para geracao do registro D696
				If ( nPos := ( cAliasQry )->( aScan( aRegD696 , { | aX | aX[ 1 ] == C03_CODIGO+C14_CODIGO .And. aX[ 2 ] == C0Y_CODIGO .And. aX[ 3 ] == C78_ALQICM } ) ) ) == 0 
					
					If !Empty( cCodObs )
						xGerBlc0( "0460",  Alltrim( cCodObs ), cFilSelBc, aWizardBc, cTabSpd )
					EndIf
					
					( cAliasQry )->( aAdd( aRegD696 , {C03_CODIGO+C14_CODIGO,;
														C0Y_CODIGO,;
														C78_ALQICM,;
														C78_VLOPR,;
														C78_VLBCIC,;
												   		C78_VLICMS,;
														C78_VLBIUF,;
														C78_VLICUF,;
														C78_VLRDBC,;
														cCodObs } ) )
			
					nPos := Len( aRegD696 )
				EndIf
	
				//Array para geracao do registro D697
				If ( nPos := ( cAliasQry )->( aScan( aRegD697 , { | aX | aX[ 1 ] == C09_UF } ) ) ) == 0 
					( cAliasQry )->( aAdd( aRegD697 , { C09_UF,;
														C79_VLBCIC,;
														C79_VLSTIC} ) )
			
					nPos := Len( aRegD697 )
				EndIf

				( cAliasQry )->( dbSkip() )
			End

		End
		
		//Se sai do laco principal, devo gravar o registro e seus filhos
		//Gravação do registro D695
		LoadString( 'D695' , aCmps , @cStrTxt2 , cAliasQry , , , aRegD695 )
		
		aInfoGrv[5]++
		If ( nRWStrTxt := WrtStrTxt(  , @cStrTxt2, .T., @aInfoGrv, 'D100' ) ) >= 0
		
			TaFContBlc("D695",aTotRegD)  
			
			aInfoGrv[5]++
			nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
		EndIf	
		
		//Gravação do registro D696	
		LoadString( 'D696' , aCmps , @cStrTxt , cAliasQry , , , aRegD696 )
		
		aInfoGrv[5]++
		nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
				
		TaFContBlc("D696",aTotRegD) 
		
		//Gravação do registro D697					
		LoadString( 'D697' , aCmps , @cStrTxt , cAliasQry , , , aRegD697 )		
				
		aInfoGrv[5]++
		nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )		
				
		TaFContBlc("D697",aTotRegD) 
		
		If nRWStrTxt == -1
			Exit
		EndIf
	End
Else
	cAliasQry 	:=  GetNextAlias()
	C2C->( dbSetOrder( 1 ) )
	C3R->( dbSetOrder( 3 ) )
	
	cQuery	:=	"SELECT "
	cQuery	+=	"C20.C20_CHVNF, "
	cQuery	+=	"C01.C01_CODIGO, "
	cQuery	+=	"C20.C20_SERIE, "
	cQuery	+=	"C09.C09_UF, "
	cQuery	+=	"C20.C20_MESTRE, "
	cQuery	+=	"C20.C20_CHVCOD, "
	cQuery	+=	"C14.C14_CODIGO, "
	cQuery	+=	"C0Y.C0Y_CODIGO, "
	cQuery	+=	"C35.C35_ALIQ, "
	cQuery	+=	"C20.C20_NUMDOC, "
	cQuery	+=	"C20.C20_DTDOC, "
	cQuery	+=	"SUM(C30.C30_TOTAL) VL_OPR, "
	cQuery	+=	"SUM(C35.C35_BASE) BC_ICMS, "
	cQuery	+=	"SUM(C35.C35_VALOR) VL_ICMS, "
	cQuery	+=	"SUM(C35.C35_VLBCUF) BC_ICMSUF, "
	cQuery	+=	"SUM(C35.C35_VLUF) VL_ICMSUF, "
	cQuery	+=	"SUM(C35.C35_VLNT) VL_NT, "
	cQuery	+=	"C03.C03_CODIGO "
	
	cQuery	+=	"FROM " + RetSqlName( 'C20' ) + " C20 "
	cQuery	+=	"JOIN " + RetSqlName( 'C01' ) + " C01 ON(C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=C20.C20_CODMOD AND C01.D_E_L_E_T_=' ') "
	cQuery	+=	"JOIN " + RetSqlName( 'C1H' ) + " C1H ON(C1H.C1H_FILIAL='" + xFilial('C1H') + "' AND C1H.C1H_ID=C20.C20_CODPAR AND C1H.D_E_L_E_T_=' ') "
	cQuery	+=	"JOIN " + RetSqlName( 'C09' ) + " C09 ON(C09.C09_FILIAL='" + xFilial('C09') + "' AND C09.C09_ID=C1H.C1H_UF AND C09.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C30' ) + " C30 ON(C30.C30_FILIAL=C20.C20_FILIAL AND C30.C30_CHVNF=C20.C20_CHVNF AND C30.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0Y' ) + " C0Y ON(C0Y.C0Y_FILIAL='" + xFilial('C0Y') + "' AND C0Y.C0Y_ID=C30.C30_CFOP AND C0Y.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C35' ) + " C35 ON(C35.C35_FILIAL=C30.C30_FILIAL AND C35.C35_CHVNF=C30.C30_CHVNF AND C35.C35_NUMITE=C30.C30_NUMITE AND C35.C35_CODITE=C30.C30_CODITE AND C35.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C14' ) + " C14 ON(C14.C14_FILIAL='" + xFilial('C14') + "' AND C14.C14_ID=C35.C35_CST AND C14.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C3S' ) + " C3S ON(C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND C3S.C3S_ID=C35.C35_CODTRI AND C3S.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( 'C03' ) + " C03 ON(C03.C03_FILIAL='" + xFilial('C03') + "' AND C03.C03_ID=C30.C30_ORIGEM AND C03.D_E_L_E_T_=' ') "
	
	cQuery	+=	"WHERE "
	cQuery	+=	"C20.C20_FILIAL='" + xFilial('C20') + "' AND "
	cQuery	+=	"C20.C20_DTDOC>='" + DToS( dDataIni ) + "' AND " 
	cQuery	+=	"C20.C20_DTDOC<='" + DToS( dDataFim ) + "' AND " 
	cQuery	+=	"C20.D_E_L_E_T_=' ' AND "
	cQuery	+=	"C20.C20_INDOPE='1' AND "
	cQuery	+=	"(C01.C01_CODIGO='21' OR C01.C01_CODIGO='22') AND "
	cQuery	+=	"C3S.C3S_CODIGO='02' "
	
	cQuery	+=	"GROUP BY "
	cQuery	+=	"C20.C20_CHVNF, "
	cQuery	+=	"C01.C01_CODIGO, "
	cQuery	+=	"C20.C20_SERIE, "
	cQuery	+=	"C09.C09_UF, "
	cQuery	+=	"C20.C20_MESTRE, "
	cQuery	+=	"C20.C20_CHVCOD, "
	cQuery	+=	"C14.C14_CODIGO, "
	cQuery	+=	"C0Y.C0Y_CODIGO, "
	cQuery	+=	"C35.C35_ALIQ, "
	cQuery	+=	"C20.C20_NUMDOC, "
	cQuery	+=	"C20.C20_DTDOC, "
	cQuery	+=	"C03.C03_CODIGO "
	
	cQuery	+=	"ORDER BY 2, 3 , 7 , 8 , 9 "
	
	cQuery	:=	ChangeQuery( cQuery )
	dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )
	
	TcSetField( cAliasQry , "C20_DTDOC" , "D" , 8 , 0 )
	
	While ( cAliasQry )->( !Eof() )
	
		If !lGerD001       
			aMacro	:=	{}
			aAdd( aMacro , "0" )
			
			LoadString( 'D001' , aCmps , @cStrTxt, , , aMacro )
			
			aInfoGrv[5]++
			WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )      
			
			TaFContBlc("D001",aTotRegD) 		
	
		 	lGerD001 := .T.
		EndIf
	
		aRegD695:=	{}
		cChave	:=	( cAliasQry )->( C01_CODIGO + C20_SERIE )	
			
		//Array para geracao do registro D695
		( cAliasQry )->( aAdd( aRegD695 , { C01_CODIGO , C20_SERIE , C20_NUMDOC , C20_NUMDOC , C20_DTDOC , C20_DTDOC , C20_MESTRE , C20_CHVCOD } ) )
		
		While ( cAliasQry )->( !Eof() ) .And.;
			( cAliasQry )->( C01_CODIGO + C20_SERIE ) == cChave
	
			aRegD696:=	{}
			aRegD697:=	{}
			cChave2	:=	( cAliasQry )->( C14_CODIGO + C0Y_CODIGO + Str( C35_ALIQ, 6 , 2 ) )	
			While ( cAliasQry )->( !Eof() ) .And.;
				( cAliasQry )->( C01_CODIGO + C20_SERIE ) == cChave .And. ;
				( cAliasQry )->( C14_CODIGO + C0Y_CODIGO + Str( C35_ALIQ, 6 , 2 ) ) == cChave2
				
				cCodObs	:=	''
				If C2C->( msSeek( xFilial( 'C2C' ) + ( cAliasQry )->C20_CHVNF ) ) .And. C3R->( msSeek( xFilial( 'C3R' ) + C2C->C2C_CODOBS ) )
					cCodObs	:=	C3R->( C3R_CODIGO )
				EndIf
				
				//Atualizando Documento Final e Data Final do D695
				If Val( ( cAliasQry )->C20_NUMDOC ) > Val( aRegD695[ 1 , 4 ] )
					aRegD695[ 1 , 4 ]	:=	( cAliasQry )->C20_NUMDOC
					aRegD695[ 1 , 6 ]	:=	( cAliasQry )->C20_DTDOC
				
				ElseIf Val( ( cAliasQry )->C20_NUMDOC ) < Val( aRegD695[ 1 , 3 ] )
					aRegD695[ 1 , 3 ]	:=	( cAliasQry )->C20_NUMDOC
					aRegD695[ 1 , 5 ]	:=	( cAliasQry )->C20_DTDOC
					
				EndIf				
	
				//Array para geracao do registro D696
				If ( nPos := ( cAliasQry )->( aScan( aRegD696 , { | aX | aX[ 1 ] == C03_CODIGO+C14_CODIGO .And. aX[ 2 ] == C0Y_CODIGO .And. aX[ 3 ] == C35_ALIQ } ) ) ) == 0 
					
					If !Empty( cCodObs )
						xGerBlc0( "0460",  Alltrim( cCodObs ), cFilSelBc, aWizardBc, cTabSpd )
					EndIf
					
					( cAliasQry )->( aAdd( aRegD696 , {C03_CODIGO+C14_CODIGO,;
														C0Y_CODIGO,;
														C35_ALIQ,;
														0,;
														0,;
														0,;
														0,;
														0,;
														0,;
														cCodObs } ) )
			
					nPos := Len( aRegD696 )
				EndIf
				aRegD696[ nPos , 04 ]	+=	( cAliasQry )->VL_OPR
				aRegD696[ nPos , 05 ]	+=	( cAliasQry )->BC_ICMS
				aRegD696[ nPos , 06 ]	+=	( cAliasQry )->VL_ICMS
				aRegD696[ nPos , 07 ]	+=	( cAliasQry )->BC_ICMSUF
				aRegD696[ nPos , 08 ]	+=	( cAliasQry )->VL_ICMSUF
				aRegD696[ nPos , 09 ]	+=	( cAliasQry )->VL_NT
								
				//Array para geracao do registro D697
				If ( nPos := ( cAliasQry )->( aScan( aRegD697 , { | aX | aX[ 1 ] == C09_UF } ) ) ) == 0 
					( cAliasQry )->( aAdd( aRegD697 , { C09_UF,;
														0,;
														0 } ) )
			
					nPos := Len( aRegD697 )
				EndIf
				
				aRegD697[ nPos , 02 ]	+=	( cAliasQry )->BC_ICMSUF
				aRegD697[ nPos , 03 ]	+=	( cAliasQry )->VL_ICMSUF		
				
				( cAliasQry )->( dbSkip() )
			End		
		
		End
		
		//Se sai do laco principal, devo gravar o registro e seus filhos
		//Gravação do registro D695
		LoadString( 'D695' , aCmps , @cStrTxt2 , cAliasQry , , , aRegD695 )
		
		aInfoGrv[5]++
		If ( nRWStrTxt := WrtStrTxt(  , @cStrTxt2, .T., @aInfoGrv, 'D100' ) ) >= 0
		
			TaFContBlc("D695",aTotRegD)  
			
			aInfoGrv[5]++
			nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
		EndIf	
		
		//Gravação do registro D696	
		LoadString( 'D696' , aCmps , @cStrTxt , cAliasQry , , , aRegD696 )
		
		aInfoGrv[5]++
		nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )
				
		TaFContBlc("D696",aTotRegD) 
		
		//Gravação do registro D697					
		LoadString( 'D697' , aCmps , @cStrTxt , cAliasQry , , , aRegD697 )		
				
		aInfoGrv[5]++
		nRWStrTxt := WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, 'D100' )		
				
		TaFContBlc("D697",aTotRegD) 
		
		
		If nRWStrTxt == -1
			Exit
		EndIf
		
	End
EndIf
	( cAliasQry )->( dbCloseArea() )

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
Static Function DistrCmps(lLayout12)
Local	aRet	:=	{}  

//ESTRUTURA DO REGISTRO D001
nI	:=	1
aAdd( aRet , { 'D001' , Array( 01 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }

//ESTRUTURA DO REGISTRO D100
if (lLayout12)
	 
	If TAFColumnPos( "C20_CODORI" )	
		If TAFColumnPos( "C20_CODDES" )
			aAdd( aRet , { 'D100' , Array( 24 ) } )
			aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C20_INDOPE }
			aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| C20_INDEMI }
			aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", xGerBlc0( "0150",  aMacro[2], cFilSelBc, aWizardBc, cTabSpd ) ) } 
			aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| C01_CODIGO }
			aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| C02_CODIGO }
			aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Iif( C01_CODIGO == "57", StrZero( val( C20_SERIE),3)	, C20_SERIE)   }
			aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| aMacro[3] }
			aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| C20_NUMDOC }
			aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| C20_CHVELE }
			aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Dt2Caract( C20_DTDOC ) ) }
			aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Dt2Caract( C20_DTES  ) ) }
			aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", C20_TPCTE )}
			aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", C20_CHVREF )}
			aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( C20_VLDOC , 16 , 2 ) )}
			aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( C20_VLDESC , 16 , 2 ) )}
			aTail( aRet[ Len( aRet ) ] ) [ 16 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", aMacro[ 1 ] ) }   
			aTail( aRet[ Len( aRet ) ] ) [ 17 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( C20_VLDOC , 16 , 2 ) )}
			aTail( aRet[ Len( aRet ) ] ) [ 18 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( BCICMS , 16 , 2 ) )}
			aTail( aRet[ Len( aRet ) ] ) [ 19 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( VLICMS , 16 , 2 ) )}
			aTail( aRet[ Len( aRet ) ] ) [ 20 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( VLNT , 16 , 2 ) )}
			aTail( aRet[ Len( aRet ) ] ) [ 21 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", IIF( lSeek , xGerBlc0( "0450",  Alltrim( C3Q->( C3Q_CODINF ) ), cFilSelBc, aWizardBc, cTabSpd ) , "" ) )}
			aTail( aRet[ Len( aRet ) ] ) [ 22 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", xGerBlc0( "0500",  Alltrim( C1O_CODIGO ), cFilSelBc, aWizardBc, cTabSpd) )}
			aTail( aRet[ Len( aRet ) ] ) [ 23 ] := {|| nLocOrig }
			aTail( aRet[ Len( aRet ) ] ) [ 24 ] := {|| nLocDest }
			Endif
	Endif
else
	aAdd( aRet , { 'D100' , Array( 22 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C20_INDOPE }
	aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| C20_INDEMI }
	aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", xGerBlc0( "0150",  aMacro[2], cFilSelBc, aWizardBc, cTabSpd ) ) } 
	aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| C01_CODIGO }
	aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| C02_CODIGO }
	aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Iif( C01_CODIGO == "57", StrZero( val( C20_SERIE),3)	, C20_SERIE)   }
	aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| aMacro[3] }
	aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| C20_NUMDOC }
	aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| C20_CHVELE }
	aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Dt2Caract( C20_DTDOC ) ) }
	aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Dt2Caract( C20_DTES  ) ) }
	aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", C20_TPCTE )}
	aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", C20_CHVREF )}
	aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( C20_VLDOC , 16 , 2 ) )}
	aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( C20_VLDESC , 16 , 2 ) )}
	aTail( aRet[ Len( aRet ) ] ) [ 16 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", aMacro[ 1 ] ) }   
	aTail( aRet[ Len( aRet ) ] ) [ 17 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( C20_VLDOC , 16 , 2 ) )}
	aTail( aRet[ Len( aRet ) ] ) [ 18 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( BCICMS , 16 , 2 ) )}
	aTail( aRet[ Len( aRet ) ] ) [ 19 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( VLICMS , 16 , 2 ) )}
	aTail( aRet[ Len( aRet ) ] ) [ 20 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( VLNT , 16 , 2 ) )}
	aTail( aRet[ Len( aRet ) ] ) [ 21 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", IIF( lSeek , xGerBlc0( "0450",  Alltrim( C3Q->( C3Q_CODINF ) ), cFilSelBc, aWizardBc, cTabSpd ) , "" ) )}
	aTail( aRet[ Len( aRet ) ] ) [ 22 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", xGerBlc0( "0500",  Alltrim( C1O_CODIGO ), cFilSelBc, aWizardBc, cTabSpd) )}
EndIf
//ESTRUTURA DO REGISTRO D101
aAdd( aRet , { 'D101' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| Iif( &( aMacro[ 1 ] ) , Val2Str( C2F_VALOR, 16, 2 ) , 0 ) }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Iif( &( aMacro[ 2 ] ) , Val2Str( C2F_VALOR, 16, 2 ) , 0 ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( C2F_VALOR, 16, 2 ) }
//ESTRUTURA DO REGISTRO D110
aAdd( aRet , { 'D110' , Array( 04 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| PADR(C30_NUMITE,3,"0") }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| xGerBlc0( "0200",  Alltrim( C1L_CODIGO ), cFilSelBc, aWizardBc, cTabSpd ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( C30_TOTAL , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( C30_VLOUTR , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D120
aAdd( aRet , { 'D120' , Array( 04 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| IIF( &(aMacro[ 1 ]) , C09->C09_CODIGO + C07->C07_CODIGO , "" ) }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| IIF( &(aMacro[ 2 ]) , C09->C09_CODIGO + C07->C07_CODIGO , "" ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| IIF( lSeek , C0Q->C0Q_PLACA , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| IIF( lSeek , IIF( &(aMacro[ 3 ]) , C09->C09_UF , "" ) , '' ) }
//aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| IIF( lSeek , C0Q->C0Q_UF , '' ) }

//ESTRUTURA DO REGISTRO D130
aAdd( aRet , { 'D130' , Array( 13 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| IIF( &(aMacro[ 1 ]) , xGerBlc0( "0150",  C1H->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd ), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| IIF( &(aMacro[ 2 ]) , xGerBlc0( "0150",  C1H->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd ), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| C3F->C3F_INDRED }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| IIF( &(aMacro[ 3 ]) , C09->C09_CODIGO + C07->C07_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| IIF( &(aMacro[ 4 ]) , C09->C09_CODIGO + C07->C07_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| IIF( lSeek , C0Q->C0Q_PLACA , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( C3F->C3F_VLIQFR , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( C3F->C3F_VSECAT , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( C3F->C3F_VDESP , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Val2Str( C3F->C3F_VPEDAG , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Val2Str( C3F->C3F_VOUTRO , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Val2Str( C3F->C3F_VTOTFR , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| IIF( lSeek , IIF( &(aMacro[ 5 ]) , C09->C09_UF , "" ) , '' ) }
//aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| IIF( lSeek , C0Q->C0Q_UF , '' ) }                              

//ESTRUTURA DO REGISTRO D140
aAdd( aRet , { 'D140' , Array( 13 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| IIF( lSeek , xGerBlc0( "0150",  C1H->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| D140UFORI+D140MUNORI }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| D140UFDES+D140MUNDES }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| C0Q_TPVEIC }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| IDNAV }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| C0Q_TPNAV }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| C3G_VIAGEM }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( C3G_VLIQFR , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( C3G_VDEPOR , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Val2Str( C3G_VDESCD , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Val2Str( C3G_VOUTRO , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Val2Str( C3G_VBRTFR , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Val2Str( C3G_VADMM , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D150
aAdd( aRet , { 'D150' , Array( 10 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| D150UFORI+D150MUNORI }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| D150UFDES+D150MUNDES }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| IDAEREO }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| C3H_VIAGEM }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| C3H_INDTAR }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( C3H_PESOTX , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( C3H_VTXTER , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( C3H_VTXRED , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( C3H_VOUTRO , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Val2Str( C3H_VTXAD , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D160
aAdd( aRet , { 'D160' , Array( 07 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C3A->C3A_DESPAC }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| IIF( &(aMacro[ 1 ]) , Iif( Empty( C1H->C1H_CNPJ ) , C1H->C1H_CPF , C1H->C1H_CNPJ ) , "" ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| IIF( &(aMacro[ 1 ]) , C1H->C1H_IE , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| IIF( &(aMacro[ 2 ]) , C09->C09_CODIGO + C07->C07_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| IIF( &(aMacro[ 3 ]) , Iif( Empty( C1H->C1H_CNPJ ) , C1H->C1H_CPF , C1H->C1H_CNPJ ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| IIF( &(aMacro[ 3 ]) , C1H->C1H_IE , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| IIF( &(aMacro[ 2 ]) , C09->C09_CODIGO + C07->C07_CODIGO , '' ) }

//ESTRUTURA DO REGISTRO D161
aAdd( aRet , { 'D161' , Array( 07 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C3A->C3A_TPCARG }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| IIF( &(aMacro[ 1 ]) , Iif( Empty( C1H->C1H_CNPJ ) , C1H->C1H_CPF , C1H->C1H_CNPJ ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| IIF( &(aMacro[ 1 ]) , C1H->C1H_IE , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| IIF( &(aMacro[ 2 ]) , C09->C09_CODIGO + C07->C07_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| IIF( &(aMacro[ 3 ]) , Iif( Empty( C1H->C1H_CNPJ ) , C1H->C1H_CPF , C1H->C1H_CNPJ ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| IIF( &(aMacro[ 3 ]) , C1H->C1H_IE , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| IIF( &(aMacro[ 2 ]) , C09->C09_CODIGO + C07->C07_CODIGO , '' ) }

//ESTRUTURA DO REGISTRO D162
aAdd( aRet , { 'D162' , Array( 09 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| IIF( lSeek , C01->C01_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| C3I->C3I_SERIE }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| C3I->C3I_NUMDOC }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Dt2Caract( C3I->C3I_DTDOC ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( C3I->C3I_VLDOC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( C3I->C3I_VLMERC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( C3I->C3I_QTDVOL , 16 , 0 ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( C3I->C3I_PESBRT , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( C3I->C3I_PESLIQ , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D170
aAdd( aRet , { 'D170' , Array( 13 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| IIF( &(aMacro[ 1 ]) , xGerBlc0( "0150",  C1H->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| IIF( &(aMacro[ 2 ]) , xGerBlc0( "0150",  C1H->( C1H_CODPAR ), cFilSelBc, aWizardBc, cTabSpd ), '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| IIF( &(aMacro[ 3 ]) , C09->C09_CODIGO + C07->C07_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| IIF( &(aMacro[ 4 ]) , C09->C09_CODIGO + C07->C07_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| IIF( lSeek , C0Q->C0Q_RNTC , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| C3F->C3F_INDNAT }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( C3F->C3F_VLIQFR , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( C3F->C3F_VGRIS , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( C3F->C3F_VPEDAG , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Val2Str( C3F->C3F_VOUTRO , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Val2Str( C3F->C3F_VTOTFR , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| IIF( lSeek , C0Q->C0Q_PLACA , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| IIF( lSeek , IIF( &(aMacro[ 5 ]) , C09->C09_UF , "" ) , '' ) }
//aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| IIF( lSeek , C0Q->C0Q_UF , '' ) }

//ESTRUTURA DO REGISTRO D180
aAdd( aRet , { 'D180' , Array( 16 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C24->C24_NUMSEQ }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| C24->C24_INDEMI }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| IIF( &(aMacro[ 1 ]) , AllTrim( C1H->C1H_CNPJ ) + AllTrim( C1H->C1H_CPF ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| IIF( &(aMacro[ 2 ]) , C09->C09_UF , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| IIF( &(aMacro[ 1 ]) , C1H->C1H_IE , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| IIF( &(aMacro[ 2 ]) , C09->C09_CODIGO + C07->C07_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| IIF( &(aMacro[ 3 ]) , AllTrim( C1H->C1H_CNPJ ) + AllTrim( C1H->C1H_CPF ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| IIF( &(aMacro[ 2 ]) , C09->C09_UF , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| IIF( &(aMacro[ 1 ]) , C1H->C1H_IE , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| IIF( &(aMacro[ 2 ]) , C09->C09_CODIGO + C07->C07_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| IIF( lSeek , C01_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| C24->C24_SERIE }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| C24->C24_SUBSER }
aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| C24->C24_NUMDOC }
aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| Dt2Caract( C24->C24_DTDOC ) }
aTail( aRet[ Len( aRet ) ] ) [ 16 ] := {|| Val2Str( C24->C24_VALOR , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D190
aAdd( aRet , { 'D190' , Array( 08 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ nX , 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( aRegProc[ nX , 3 ] , 5 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( aRegProc[ nX , 4 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ nX , 5 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ nX , 6 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( aRegProc[ nX , 7 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| aRegProc[ nX , 8 ] }

//ESTRUTURA DO REGISTRO D195
aAdd( aRet , { 'D195' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| xGerBlc0( "0460",  Alltrim( C3R->( C3R_CODIGO ) ), cFilSelBc, aWizardBc, cTabSpd ) }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| C2C_DESCRI }

//ESTRUTURA DO REGISTRO D197
aAdd( aRet , { 'D197' , Array( 07 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C0J->C0J_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| C2D->C2D_DESCRI }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| IIF( &(aMacro[ 1 ]) , xGerBlc0( "0200",  Alltrim( C1L->( C1L_CODIGO ) ), cFilSelBc, aWizardBc, cTabSpd ), "" ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( C2D->C2D_BSICM , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( C2D->C2D_ALQICM , 5 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( C2D->C2D_VLICM , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( C2D->C2D_VLOUTR , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D300
aAdd( aRet , { 'D300' , Array( 19 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ nX , 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| aRegProc[ nX , 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| aRegProc[ nX , 4 ] }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| aRegProc[ nX , 5 ] }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| aRegProc[ nX , 6 ] }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| aRegProc[ nX , 7 ] }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( aRegProc[ nX , 8 ] , 6 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Dt2Caract( aRegProc[ nX , 9 ] ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Val2Str( aRegProc[ nX , 10 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Val2Str( aRegProc[ nX , 11 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Val2Str( aRegProc[ nX , 12 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Val2Str( aRegProc[ nX , 13 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| Val2Str( aRegProc[ nX , 14 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| Val2Str( aRegProc[ nX , 15 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 16 ] := {|| Val2Str( aRegProc[ nX , 16 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 17 ] := {|| Val2Str( aRegProc[ nX , 17 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 18 ] := {|| aRegProc[ nX , 18 ] }
aTail( aRet[ Len( aRet ) ] ) [ 19 ] := {|| aRegProc[ nX , 19 ] }

//ESTRUTURA DO REGISTRO D301
aAdd( aRet , { 'D301' , Array( 01 ) } )                     
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 1 ] }

//ESTRUTURA DO REGISTRO D310
aAdd( aRet , { 'D310' , Array( 04 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( aRegProc[ nX , 2 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( aRegProc[ nX , 3 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( aRegProc[ nX , 4 ] , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D350
aAdd( aRet , { 'D350' , Array( 04 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C01_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| C0W_ECFMOD }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| C0W_ECFFAB }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| C0W_ECFCX }

//ESTRUTURA DO REGISTRO D355
aAdd( aRet , { 'D355' , Array( 06 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| Dt2Caract( C6G_DTMOV ) }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| C6G_PCREOP }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| C6G_PCREDZ }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| C6G_NRCOPF }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( C6G_VLGRTF , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( C6G_VLBRU , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D360
aAdd( aRet , { 'D360' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| Val2Str( VLPIS , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( VLCOFINS , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D365
aAdd( aRet , { 'D365' , Array( 04 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C6D->( C6D_CODIGO ) }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( C6H->C6H_VLRTOT , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| C6H->C6H_NRTOT }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| C6H->C6H_DESST }

//ESTRUTURA DO REGISTRO D370
aAdd( aRet , { 'D370' , Array( 05 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| IIF( &(aMacro[ 1 ]) , C09->C09_CODIGO + C07->C07_CODIGO , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( C7F->C7F_VLSERV , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( C7F->C7F_QTDBIL , 16 , 0 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( C7F->C7F_VBCICM , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( C7F->C7F_VLICMS , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D390
aAdd( aRet , { 'D390' , Array( 10 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ nX , 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( aRegProc[ nX , 3 ] , 6 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( aRegProc[ nX , 4 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ nX , 5 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ nX , 6 ] , 6 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( aRegProc[ nX , 7 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( aRegProc[ nX , 8 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( aRegProc[ nX , 9 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| aRegProc[ nX , 10 ] }

//ESTRUTURA DO REGISTRO D400
aAdd( aRet , { 'D400' , Array( 15 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| RMD_CODPAR }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| "18" }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| RMD_CODSIT }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| RMD_SERIE }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| RMD_SUBSER }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| RMD_NUMDOC }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Dt2Caract( RMD_DTDOC ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( RMD_VLDOC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( RMD_VLDESC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Val2Str( RMD_VLSERV , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Val2Str( RMD_BCICMS , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Val2Str( RMD_VLICMS , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Val2Str( RMD_VLPIS , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| Val2Str( RMD_VLCOFINS , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| RMD_CODCTA }

//ESTRUTURA DO REGISTRO D410
aAdd( aRet , { 'D410' , Array( 14 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ nX , 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| aRegProc[ nX , 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| aRegProc[ nX , 4 ] }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| aRegProc[ nX , 5 ] }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Dt2Caract( aRegProc[ nX , 6 ] ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| aRegProc[ nX , 7 ] }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| aRegProc[ nX , 8 ] }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( aRegProc[ nX , 09 ] , 06 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Val2Str( aRegProc[ nX , 10 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Val2Str( aRegProc[ nX , 11 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Val2Str( aRegProc[ nX , 12 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Val2Str( aRegProc[ nX , 13 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| Val2Str( aRegProc[ nX , 14 ] , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D411
aAdd( aRet , { 'D411' , Array( 01 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C2I->C2I_NUMDOC }

//ESTRUTURA DO REGISTRO D420
aAdd( aRet , { 'D420' , Array( 04 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( aRegProc[ nX , 2 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( aRegProc[ nX , 3 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( aRegProc[ nX , 4 ] , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D500
aAdd( aRet , { 'D500' , Array( 23 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C20_INDOPE }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| C20_INDEMI }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", xGerBlc0( "0150",  C1H_CODPAR, cFilSelBc, aWizardBc, cTabSpd ) ) } 
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| C01_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| C02_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| C20_SERIE }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", C20_SUBSER ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| C20_NUMDOC }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Dt2Caract( C20_DTDOC ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", Dt2Caract( C20_DTES ) ) }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", Val2Str( C20_VLDOC , 16 , 2 ) ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", Val2Str( C20_VLDESC , 16 , 2 ) ) }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", Val2Str( Iif( lSeek , C2G->C2G_VLSERV , 0 ) , 16 , 2 ) )}
aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", Val2Str( Iif( lSeek , C2G->C2G_VSERNT , 0 ) , 16 , 2 ) )}
aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", Val2Str( Iif( lSeek , C2G->C2G_VLTERC , 0 ) , 16 , 2 ) )}
aTail( aRet[ Len( aRet ) ] ) [ 16 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", Val2Str( C20_VLRDA + C20_VLOUDE , 16 , 2 ) )}
aTail( aRet[ Len( aRet ) ] ) [ 17 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", Val2Str( BCICMS , 16 , 2 ) )}
aTail( aRet[ Len( aRet ) ] ) [ 18 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", Val2Str( VLICMS , 16 , 2 ) )}
aTail( aRet[ Len( aRet ) ] ) [ 19 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", Iif( &( aMacro[ 1 ] ) , xGerBlc0( "0450",  Alltrim( C3Q->( C3Q_CODINF ) ), cFilSelBc, aWizardBc, cTabSpd ) , '' ) )}
aTail( aRet[ Len( aRet ) ] ) [ 20 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", Val2Str( VLPIS , 16 , 2 ) )}
aTail( aRet[ Len( aRet ) ] ) [ 21 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", Val2Str( VLCOFINS , 16 , 2 ) )}
aTail( aRet[ Len( aRet ) ] ) [ 22 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", xGerBlc0( "0500",  Alltrim( C1O_CODIGO ), cFilSelBc, aWizardBc, cTabSpd) )}
aTail( aRet[ Len( aRet ) ] ) [ 23 ] := {|| Iif( C02_CODIGO $ ("02|03|"), "", Iif( lSeek , C2G->C2G_TPASSI , '' ) )}

//ESTRUTURA DO REGISTRO D510
aAdd( aRet , { 'D510' , Array( 19 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C30_NUMITE }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| xGerBlc0( "0200",  Alltrim( C1L_CODIGO ), cFilSelBc, aWizardBc, cTabSpd, Right( Alltrim(C1J_CODIGO), 6 ) ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| C0K_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( C30_QUANT , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| xGerBlc0( "0190",  Alltrim( Right( Alltrim(C1J_CODIGO), 6 )), cFilSelBc, aWizardBc, cTabSpd )}
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str(C30_VLRITE , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str(C30_VLDESC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| aRegProc[ nX , 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| C0Y_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Val2Str( aRegProc[ nX , 2 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Val2Str( aRegProc[ nX , 3 ] , 6 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Val2Str( aRegProc[ nX , 4 ] , 16 , 2 )}
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Val2Str( aRegProc[ nX , 5 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| Val2Str( aRegProc[ nX , 6 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| C38_INDREC }
aTail( aRet[ Len( aRet ) ] ) [ 16 ] := {|| IT_CODPAR }
aTail( aRet[ Len( aRet ) ] ) [ 17 ] := {|| Val2Str( aRegProc[ nX , 7 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 18 ] := {|| Val2Str( aRegProc[ nX , 8 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 19 ] := {|| IT_CCTA }

//ESTRUTURA DO REGISTRO D530
aAdd( aRet , { 'D530' , Array( 06 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C2G->C2G_INDSER }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Dt2Caract( C2G->C2G_DTINI ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Dt2Caract( C2G->C2G_DTFIM ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| C2G->C2G_PERFIS }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| C2G->C2G_CODARE }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| C2G->C2G_TERMIN }

//ESTRUTURA DO REGISTRO D590
aAdd( aRet , { 'D590' , Array( 10 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ nX , 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( aRegProc[ nX , 03 ] , 06 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( aRegProc[ nX , 04 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ nX , 05 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ nX , 06 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( aRegProc[ nX , 07 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( aRegProc[ nX , 08 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( aRegProc[ nX , 09 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| aRegProc[ nX , 10 ] }

//ESTRUTURA DO REGISTRO D600
aAdd( aRet , { 'D600' , Array( 17 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ nX , 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| aRegProc[ nX , 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| aRegProc[ nX , 4 ] }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| aRegProc[ nX , 5 ] }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ nX , 6 ] , 16 , 0 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Dt2Caract( aRegProc[ nX , 7 ] ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( aRegProc[ nX , 8 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( aRegProc[ nX , 9 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Val2Str( aRegProc[ nX , 10 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Val2Str( aRegProc[ nX , 11 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Val2Str( aRegProc[ nX , 12 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Val2Str( aRegProc[ nX , 13 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| Val2Str( aRegProc[ nX , 14 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| Val2Str( aRegProc[ nX , 15 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 16 ] := {|| Val2Str( aRegProc[ nX , 16 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 17 ] := {|| Val2Str( aRegProc[ nX , 17 ] , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D610
aAdd( aRet , { 'D610' , Array( 17 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ nX , 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( aRegProc[ nX , 4 ] , 16 , 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| aRegProc[ nX , 5 ] }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ nX , 6 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ nX , 7 ] , 16 , 0 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| aRegProc[ nX , 8 ] }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| aRegProc[ nX , 9 ] }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( aRegProc[ nX , 10 ] , 06 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Val2Str( aRegProc[ nX , 11 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Val2Str( aRegProc[ nX , 12 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Val2Str( aRegProc[ nX , 13 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Val2Str( aRegProc[ nX , 14 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| Val2Str( aRegProc[ nX , 15 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| Val2Str( aRegProc[ nX , 16 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 16 ] := {|| Val2Str( aRegProc[ nX , 17 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 17 ] := {|| aRegProc[ nX , 18 ] }

//ESTRUTURA DO REGISTRO D690 - UTILIZA O MESMO ARRAY, AS MESMAS INFORMACOES
aAdd( aRet , { 'D690' , Array( 10 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 02 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ nX , 03 ] }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( aRegProc[ nX , 04 ] , 06 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( aRegProc[ nX , 05 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ nX , 06 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ nX , 07 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( aRegProc[ nX , 08 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( aRegProc[ nX , 09 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( aRegProc[ nX , 10 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| aRegProc[ nX , 11 ] }


//ESTRUTURA DO REGISTRO D695 - UTILIZA O MESMO ARRAY, AS MESMAS INFORMACOES
aAdd( aRet , { 'D695' , Array( 08 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 01 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ nX , 02 ] }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| aRegProc[ nX , 03 ] }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| aRegProc[ nX , 04 ] }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Dt2Caract( aRegProc[ nX , 05 ] ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Dt2Caract( aRegProc[ nX , 06 ] ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| aRegProc[ nX , 07 ] }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| aRegProc[ nX , 08 ] }

//ESTRUTURA DO REGISTRO D696 - UTILIZA O MESMO ARRAY, AS MESMAS INFORMACOES
aAdd( aRet , { 'D696' , Array( 10 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 01 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ nX , 02 ] }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( aRegProc[ nX , 03 ] , 06 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( aRegProc[ nX , 04 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ nX , 05 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ nX , 06 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( aRegProc[ nX , 07 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( aRegProc[ nX , 08 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( aRegProc[ nX , 09 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| aRegProc[ nX , 10 ] }

//ESTRUTURA DO REGISTRO D697 - UTILIZA O MESMO ARRAY, AS MESMAS INFORMACOES
aAdd( aRet , { 'D697' , Array( 03 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nX , 01 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( aRegProc[ nX , 02 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( aRegProc[ nX , 03 ] , 16 , 2 ) }

//ESTRUTURA DO REGISTRO D990
nI	:=	1
aAdd( aRet , { 'D990' , Array( 1 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( aMacro[ 1 ], 16, 0 ) }

Return ( aRet )  

//====================================================================================================================================================================

//====================================================================================================================================================================

//====================================================================================================================================================================
//																    SPED CONTRIBUICOES
//====================================================================================================================================================================

//====================================================================================================================================================================

//====================================================================================================================================================================

//-------------------------------------------------------------------
/*{Protheus.doc} 

@author Rodrigo Aguilar
@since	22/02/2013
@version 1.0

*/
//-------------------------------------------------------------------

Function BlocoDPC( nHdlTxt , aWizard, aFilSel, lGerBlocI )

Local	cFilBkp		:= cFilAnt	 

Local	nI			:= 0 
Local   lGerD010    := .F.
Local   cFilCnpj    := ''    
Local   dDataIni    := ''
Local   dDataFim    := ''
    
Private lGerD001    := .F. 
Private	lSeek		:= .F.   

Private	aMacro		:= {}                    

Default nHdlTxt     := 0
Default	aWizard 	:= {}
Default	aFilSel		:= { { xFilial(), ""} }
Default lGerBlocI := .F.

/*------------------------------------------------------------
Tratamento para quando nao for passado a Wizard por parametro
-------------------------------------------------------------*/
If Len( aWizard ) <= 0
	dDataIni   := SToD( '20120101' )
	dDataFim   := SToD( '20131231' )
Else
	dDataIni := aWizard[1][1]
	dDataFim := aWizard[1][2]       
EndIf

If !lGerBlocI
	For nI := 1 To Len( aFilSel )       
	
		cFilAnt := aFilSel[nI][1]      
		cFilCNPJ := aFilSel[nI][2]       
	
		/*---------------------
		D100, D101, D105, D111
		----------------------*/
		BlcD100PC( dDataIni , dDataFim , nHdlTxt, @lGerD010, cFilCnpj )
	
		/*---------------------
		D200, D201, D205, D209
		----------------------*/
		BlcD200PC( dDataIni , dDataFim , nHdlTxt, @lGerD010, cFilCnpj  )
	
		/*--------
		D300, D309	
		---------*/
		BlcD300PC( dDataIni , dDataFim , nHdlTxt, @lGerD010, cFilCnpj  )		
	
		/*--------
		D300, D359	
		---------*/
		BlcD350PC( dDataIni , dDataFim , nHdlTxt, @lGerD010, cFilCnpj  )		
	
		/*---------------------
		D500, D501, D505, D509	
		---------------------*/
		BlcD500PC( dDataIni , dDataFim , nHdlTxt, @lGerD010, cFilCnpj  )		
	
		/*---------------------
		D600, D601, D605, D609
		---------------------*/
		BlcD600PC( dDataIni , dDataFim , nHdlTxt, @lGerD010, cFilCnpj  )		
				
	Next nI
EndIf
	
If !lGerD001

	aCmps := DistCmpPC()
	cStrTxt := ""
	
	aMacro	:=	{}
	aAdd( aMacro , "1" )
	
	LoadString( 'D001' , aCmps , @cStrTxt, , , aMacro )
	WrtStrTxt( nHdlTxt , @cStrTxt )      
	
	TaFContBlc("D001",aTotRegD)
				
EndIf               

/*--
D990
---*/                 
BlcD990PC( nHdlTxt )

/*---------------------------------------------------
Restauro a Filial salva no inicio do processamento   
----------------------------------------------------*/
cFilAnt	:=	cFilBkp

Return ( aTotRegD )             

//-------------------------------------------------------------------
/*/{Protheus.doc} BlcD010PC
Funcao responsavel processar o movimento especifico para montagem dos registros:
D010

@param	cFilCpnj	-> 	CNPJ 
		
@return NIL

@author Rodrigo Aguilar
@since 21/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlcD010PC( cFilCnpj, nHdlTxt )    

Local cStrTxt := ''    

Local aCmps := DistCmpPC() 

Local aD010 := {}

Default := ""

If !lGerD001       
	aMacro	:=	{}
	aAdd( aMacro , "0" )
	
	LoadString( 'D001' , aCmps , @cStrTxt, , , aMacro )
	WrtStrTxt( nHdlTxt , @cStrTxt )      
	
	TaFContBlc("D001",aTotRegD) 		

 	lGerD001 := .T.
EndIf

Aadd( aD010, { cFilCnpj } )

/*--------------
Gravacao do D010 
---------------*/		
LoadString( 'D010' , aCmps , @cStrTxt , , , , aD010 )
nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	

If nRWStrTxt == -1
	MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
Else 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Conta os registros para totalizar no bloco 9³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TaFContBlc("D010",aTotRegD) 
	
EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} BlcD100PC
Funcao responsavel processar o movimento especifico para montagem dos registros:
D100, D101, D105, D111

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		nHdlTxt		->	Handle do arquivo aberto para gravacao     
		lGerD010    ->  Indica se Foi gerado o Registro D010      
		cFilCnpj    ->  Cnpj para geracao do Registro D010
		
		
@return NIL

@author Rodrigo Aguilar
@since 19/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlcD100PC( dDataIni , dDataFim , nHdlTxt, lGerD010, cFilCnpj )

Local	cQuery		:=	''         
Local   cCdTrib     :=  ''
Local   cCodCst     :=  ''

Local	cChvNF		:=	''
Local	cChvAux		:=	''   


Local	cStrTxt		:=	''
Local	cStrTxt2	:=	''
Local	cStrTxt3	:=	''

Local 	cAliasQry 	:=  GetNextAlias()
Local	aCmps		:=	DistCmpPC()

Local	nRWStrTxt	:=	0 
Local	nPos    	:=	0              

Local	aD101		:=	{}
Local	aD105		:=	{}

/*-------------------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
--------------------------------------------------------------------*/
C35->( dbSetOrder( 1 ) )
C3S->( dbSetOrder( 1 ) )
C6W->( dbSetOrder( 1 ) )
C17->( dbSetOrder( 3 ) )
C1G->( dbSetOrder( 3 ) )

/*-----------------------------
Query principal do movimento 
------------------------------*/ 
cQuery	+=	"SELECT "
cQuery	+=	" D100.C20_FILIAL, "
cQuery	+=	" D100.C20_CHVNF, "
cQuery	+=	" D100.C20_INDOPE, " 
cQuery	+=	" D100.C20_INDEMI, " 
cQuery	+=	" D100.C20_SERIE, "
cQuery	+=	" D100.C20_SUBSER, " 
cQuery	+=	" D100.C20_NUMDOC, " 
cQuery	+=	" D100.C20_CHVELE, "
cQuery	+=	" D100.C20_DTDOC, "
cQuery	+=	" D100.C20_DTES, "
cQuery	+=	" D100.C20_TPCTE, "
cQuery	+=	" D100.C20_CHVREF, "
cQuery	+=	" D100.C20_VLDOC, "
cQuery	+=	" D100.C20_VLSERV, "
cQuery	+=	" D100.C20_VLDESC, "
cQuery	+=	" D100.C20_INDFRT, "
cQuery	+=	" D100.C20_INDOPE, "
cQuery	+=	" D101.C30_TOTAL, "  
cQuery	+=	" D101.C30_NUMITE, "  
cQuery	+=	" D101.C30_CODITE, "  
cQuery	+=	" C1O.C1O_CODIGO, "
cQuery	+=	" C01.C01_CODIGO, " 
cQuery	+=	" C02.C02_CODIGO, "
cQuery	+=	" C1H.C1H_FILIAL, "  
cQuery	+=	" C1H.C1H_CODPAR, "
cQuery	+=	" C3P.C3P_CODIGO, "
cQuery	+=	" C11.C11_CODIGO, "
cQuery	+=	" ( SELECT SUM( TRIB.C35_BASE  ) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL = '" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' '  AND C3S.C3S_CODIGO='02'  AND TRIB.C35_FILIAL = D101.C30_FILIAL AND TRIB.C35_CHVNF = D101.C30_CHVNF AND TRIB.D_E_L_E_T_ = ' ' ) BCICMS, "
cQuery	+=	" ( SELECT SUM( TRIB.C35_VALOR ) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL = '" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='02'  AND TRIB.C35_FILIAL = D101.C30_FILIAL AND TRIB.C35_CHVNF = D101.C30_CHVNF AND TRIB.D_E_L_E_T_= ' '  ) VLICMS, "
cQuery	+=	" ( SELECT SUM( TRIB.C35_VLNT  ) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL = '" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' '  AND C3S.C3S_CODIGO='02'  AND TRIB.C35_FILIAL = D101.C30_FILIAL AND TRIB.C35_CHVNF = D101.C30_CHVNF AND TRIB.D_E_L_E_T_ = ' ' ) VLNT,    "  
cQuery  +=  " C0X.C0X_CODIGO, "
cQuery	+=	" C1O.C1O_FILIAL "
cQuery	+=	"FROM " + RetSqlName( 'C20' ) + " D100 " 
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C01' ) + " C01  ON( C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=D100.C20_CODMOD AND C01.D_E_L_E_T_ = ' ' ) "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0X' ) + " C0X ON(C0X.C0X_FILIAL='" + xFilial('C0X') + "' AND C0X.C0X_ID=D100.C20_INDFRT AND C0X.D_E_L_E_T_=' ') "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C02' ) + " C02  ON( C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID=D100.C20_CODSIT AND C02.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C1H' ) + " C1H  ON( C1H.C1H_FILIAL='" + xFilial('C1H') + "' AND C1H.C1H_ID=D100.C20_CODPAR AND C1H.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C1O' ) + " C1O  ON( C1O.C1O_FILIAL='" + xFilial('C1O') + "' AND C1O.C1O_ID=D100.C20_CODCTA AND C1O.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C3P' ) + " C3P  ON( C3P.C3P_FILIAL='" + xFilial('C3P') + "' AND C3P.C3P_ID=D100.C20_NATFRT AND C3P.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C30' ) + " D101 ON( D101.C30_FILIAL = D100.C20_FILIAL AND D101.C30_CHVNF = D100.C20_CHVNF AND D101.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C11' ) + " C11  ON( C11.C11_FILIAL = '" + xFilial('C11') + "' AND C11.C11_ID = D101.C30_NATBCC AND C11.D_E_L_E_T_ = ' ' ) "
cQuery	+=	"WHERE " 	
cQuery	+=	" D100.C20_FILIAL ='" + xFilial('C20') + "' AND " 
cQuery	+=	" D100.C20_DTES >='" + DToS( dDataIni ) + "' AND " 
cQuery	+=	" D100.C20_DTES <='" + DToS( dDataFim ) + "' AND " 
cQuery	+=	" D100.C20_INDOPE = '0' AND " 
cQuery	+=	" D100.D_E_L_E_T_=' ' AND " 
cQuery	+=	" ( C01.C01_CODIGO='07' OR C01.C01_CODIGO='08' OR C01.C01_CODIGO='8B' OR C01.C01_CODIGO='09' OR C01.C01_CODIGO='10' OR C01.C01_CODIGO='11' OR C01.C01_CODIGO='26' OR C01.C01_CODIGO='27' OR C01.C01_CODIGO='57' ) "
cQuery	+=	" ORDER BY C20_CHVNF " 



cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

TcSetField( cAliasQry , "C20_DTDOC" , "D" , 8 , 0 )
TcSetField( cAliasQry , "C20_DTES"  , "D" , 8 , 0 )  

/*-----------------
While do Documento
------------------*/
While (cAliasQry)->( !Eof() )

	/*------------------------------------
	Validacao e geracao do Registro D010
	-------------------------------------*/
	If !lGerD010
		BlcD010PC( cFilCnpj, nHdlTxt )      
		
		lGerD010 := .T.
    EndIf
    
	cChvNF	:=	( cAliasQry )->C20_CHVNF
	lObs	:=	C2C->( msSeek( xFilial( 'C2C' ) + cChvNF ) ) .And. C3R->( msSeek( xFilial( 'C3R' ) + C2C->C2C_CODOBS ) )

	/*--------------
	Gravacao do D100 
	---------------*/
	lSeek	:=	C21->( MsSeek( xFilial( 'C21' ) + cChvNF ) ) .And. C3Q->( MsSeek( xFilial( 'C3Q' ) + C21->C21_CODINF ) )
	
	//Tratamento para que os codigos de indicador de frete seja gerado de acordo com o definido pelo 
	//Layout do Sped	
	aMacro	:=	{}
	If DToS(dDataIni) >= "20120701"
	
		//Por Conta de Terceiros
		If (cAliasQry)->C0X_CODIGO == "0" 
			aAdd( aMacro, "2" )		
		
		//Por Conta do Emitente
		ElseIf (cAliasQry)->C0X_CODIGO == "1"
			aAdd( aMacro, "0" )
		
		//Por Conta do Destinatário
		ElseIf (cAliasQry)->C0X_CODIGO == "2"
			aAdd( aMacro, "1" )
		
		//Sem cobrança de frete
		Else
			aAdd( aMacro, "9" )			
		EndIf						
	
	//Para periodos Anteriores a 01/07/2012 o codigo ja esta correto de acordo com o Layout	
	Else
		aAdd( aMacro, (cAliasQry)->C0X_CODIGO )	
	EndIf
		
	LoadString( 'D100' , aCmps , @cStrTxt , cAliasQry , lSeek, aMacro )
	nRWStrTxt	:=	WrtStrTxt( nHdlTxt, @cStrTxt )
	
	cChvNF := (cAliasQry)->C20_CHVNF
			
	If nRWStrTxt >= 0  
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conta os registros para totalizar no bloco 9³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TaFContBlc("D100",aTotRegD) 
		
		//Tratamento para que as notas ficasis com os modelos abaixo ( Canceladas/Denegadas) nao gerem
		//os registros filhos.
		If ! ( ( cAliasQry )->C02_CODIGO $ ("02|03|04|") )
			
			/*-------------------------
			Laco da Nota Fiscal
			--------------------------*/  			
			While (cAliasQry)->( !Eof() ) .And. cChvNF == (cAliasQry)->C20_CHVNF   
			
				/*-----------------------------------------------------------------------------------------------------------------------------
				Para a geracao dos Registros do Bloco D nao foi usado While na tabela C35 ( Tributos ) pois por definicao Fiscal um 
				item de uma NF NUNCA podera ter duas referencias com o mesmo imposto ( na tabela C35 ), caso isso ocorra o EFD ira considerar 
				a primeira informacao encontrada para a geracao dos registros			
				-------------------------------------------------------------------------------------------------------------------------------*/		
	
				/*-------------------------
				Busco Codigo do Tributo PIS
				--------------------------*/        
				cCdTrib := ""
				If C3S->( MsSeek( xFilial("C3S") + "06" ) )
			        cCdTrib := C3S->C3S_ID
		        EndIf
		        
				/*--------------------------------------------------
				Busca Informacoes de Tributos de Pis na Tabela C35
				---------------------------------------------------*/        
		        lSeek := C35->( MsSeek( xFilial("C35") + cChvNF + (cAliasQry)->( C30_NUMITE + C30_CODITE + cCdTrib ) ) )
		        
		        If lSeek
			        
			        cCodCst := Iif( C17->( MsSeek( xFilial("C17") + C35->C35_CST ) ), C17->C17_CODIGO, "" )
			        
			        If ( nPos := ( cAliasQry )->( aScan( aD101 , { | aX | aX[ 3 ] == cCodCst .And. aX[ 4 ] == C11_CODIGO .And. aX[ 6 ] == C35->C35_ALIQ } ) ) ) == 0 		
						                					
						Aadd( aD101, { (cAliasQry)->C3P_CODIGO,;
				 	                    0,;
							 	        cCodCst,;
							 	        (cAliasQry)->C11_CODIGO,;
							 	        0 ,;
							 	        C35->C35_ALIQ ,;
							 	        0,;
							 	        (cAliasQry)->C1O_CODIGO } )           
						
						nPos := Len( aD101 )
							 	        
					EndIf
					aD101[ nPos, 2 ] +=	(cAliasQry)->C30_TOTAL
					aD101[ nPos, 5 ] += C35->C35_BASE				
					aD101[ nPos, 7 ] += C35->C35_VALOR
				EndIf   
				
				/*-----------------------------
				Busco Codigo do Tributo Cofins
				------------------------------*/        
				cCdTrib := ""
				If C3S->( MsSeek( xFilial("C3S") + "07" ) )
			        cCdTrib := C3S->C3S_ID
		        EndIf
		        
				/*--------------------------------------------------
				Busca Informacoes de Tributos de Cofins na Tabela C35
				---------------------------------------------------*/        
		        lSeek := C35->( MsSeek( xFilial("C35") + cChvNF + (cAliasQry)->( C30_NUMITE + C30_CODITE + cCdTrib ) ) )
		        
		        If lSeek       
		        
		        	cCodCst := Iif( C17->( MsSeek( xFilial("C17") + C35->C35_CST ) ), C17->C17_CODIGO, "" )
		        	
			        If ( nPos := ( cAliasQry )->( aScan( aD105 , { | aX | aX[ 3 ] == cCodCst .And. aX[ 4 ] == C11_CODIGO .And. aX[ 6 ] == C35->C35_ALIQ } ) ) ) == 0 		
						                
						
						Aadd( aD105, { (cAliasQry)->C3P_CODIGO,;
				 	                    0,;
							 	        cCodCst,;
							 	        (cAliasQry)->C11_CODIGO,;
							 	        0 ,;
							 	        C35->C35_ALIQ ,;
							 	        0,;
							 	        (cAliasQry)->C1O_CODIGO } )           
						
						nPos := Len( aD105 )
							 	        
					EndIf
					aD105[ nPos, 2 ] +=	(cAliasQry)->C30_TOTAL
					aD105[ nPos, 5 ] += C35->C35_BASE				
					aD105[ nPos, 7 ] += C35->C35_VALOR
				EndIf			
			   
				(cAliasQry)->(DbSkip())                                        					
			EndDo                                                               
	
			/*------------------------------------------		
			Verifica se Existem Valores a serem gerados		
			-------------------------------------------*/				
			If Len( aD101 ) > 0					
				
				/*--------------
				Gravacao do D101 
				---------------*/		
				LoadString( 'D101' , aCmps , @cStrTxt , cAliasQry , , , aD101 )
				nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )							
				
				If nRWStrTxt == -1
					Exit				
				Else
					/*---------------------------------------------------------------
					Realizo a totalizao dos registros para o Bloco 9 e Registro D990
					----------------------------------------------------------------*/		
					If Len( aTotRegD ) <= 0 .Or. ( nlY := aScan( aTotRegD, { |x| x[1] == "D101" } ) ) <= 0
						Aadd( aTotRegD,  { "D101", 0 }  )
						nlY := Len( aTotRegD )
					EndIf                      	
					aTotRegD[nlY][2] +=  Len( aD101 )				
				EndIf			
				
			EndIf
	
			/*------------------------------------------		
			Verifica se Existem Valores a serem gerados		
			-------------------------------------------*/				
			If Len( aD105 ) > 0					
			
				/*--------------
				Gravacao do D105 
				---------------*/		
				LoadString( 'D105' , aCmps , @cStrTxt , cAliasQry , , , aD105 )
				nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )							
				
				If nRWStrTxt == -1
					Exit				
				Else
					/*---------------------------------------------------------------
					Realizo a totalizao dos registros para o Bloco 9 e Registro D990
					----------------------------------------------------------------*/		
					If Len( aTotRegD ) <= 0 .Or. ( nlY := aScan( aTotRegD, { |x| x[1] == "D105" } ) ) <= 0
						Aadd( aTotRegD,  { "D105", 0 }  )
						nlY := Len( aTotRegD )
					EndIf                      	
					aTotRegD[nlY][2] +=  Len( aD105 )					
				EndIf			
			
			EndIf				
		
			If C6W->( MsSeek( xFilial("C6W") + cChvNF ) )                                           
				While C6W->(!Eof()) .And. C6W->C6W_CHVNF  == cChvNF		
					If C1G->(MsSeek( xFilial("C1G") + C6W->C6W_NUMERO ) )

						//Para os codigos 0 e 2 nao devem ser gerados os registros de processo referenciado
						//no sped contribuicoes
						If AllTrim( C1G->C1G_INDPRO ) $ ("1|3|9")									 			 			 		 					
							/*--------------
							Gravacao do D111 
							---------------*/		
							LoadString( 'D111' , aCmps , @cStrTxt , cAliasQry )
							nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )									
								
							If nRWStrTxt == -1
								Exit				
							Else
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Conta os registros para totalizar no bloco 9³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								TaFContBlc("D111",aTotRegD) 
							EndIf			                                  
						EndIf     									
					EndIf
					
					C6W->(DbSkip())
				EndDo   
				
				If nRWStrTxt == -1
					Exit				
				EndIf			                                       					
			EndIf
		Else
			(cAliasQry)->(DbSkip())
		EndIf
	EndIf        
	
	/*------------------------------------------------------
	Zerando Totalizadores para geracao do Proximo Registro
	-------------------------------------------------------*/		
	aD101 := {}                                                    
	aD105 := {}                                                    	
EndDo                                                              

If nRWStrTxt == -1
	MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
EndIf

Return ( Nil ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} BlcD200PC
Funcao responsavel processar o movimento especifico para montagem dos registros:
D200, D201, D205, D209

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		nHdlTxt		->	Handle do arquivo aberto para gravacao           
		lGerD010    ->  Indica se Foi gerado o Registro D010      
		cFilCnpj    ->  Cnpj para geracao do Registro D010		
		
@return NIL

@author Rodrigo Aguilar
@since 19/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlcD200PC( dDataIni , dDataFim , nHdlTxt, lGerD010, cFilCnpj  )

Local	cQuery		:= ''         
Local   cCdTrib     := ''
Local   cCodCst     :=  ''

Local	cChvNF		:=	''
Local	cChvAux		:=	''   

Local	cStrTxt		:=	''
Local	cStrTxt2	:=	''
Local	cStrTxt3	:=	''

Local 	cAliasQry 	:=  GetNextAlias()
Local	aCmps		:=	DistCmpPC()

Local	nRWStrTxt	:=	0 
Local	nPos    	:=	0
Local   nPosD200    :=  0   

Local   lFirstNF    := .T.           

Local	aD200		:= {} 
Local   aD201 		:= {} 
Local   aD205 		:= {} 
Local   aD209       := {}

/*-------------------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
--------------------------------------------------------------------*/
C35->( dbSetOrder( 1 ) )
C3S->( dbSetOrder( 1 ) )
C6W->( dbSetOrder( 1 ) )
C17->( dbSetOrder( 3 ) )
C1G->( dbSetOrder( 3 ) )

/*-----------------------------
Query principal do movimento 
------------------------------*/ 
cQuery	+=	"SELECT "
cQuery	+=	" D200.C20_CHVNF, "
cQuery	+=	" D200.C20_NUMDOC, "
cQuery	+=	" D200.C20_SERIE, "
cQuery	+=	" D200.C20_SUBSER, " 
cQuery	+=	" D200.C20_VLDOC, "
cQuery	+=	" D200.C20_VLDESC, "
cQuery	+=	" D200.C20_DTDOC, "
cQuery	+=	" D201.C30_NUMITE, " 
cQuery	+=	" D201.C30_CODITE, " 
cQuery	+=	" D201.C30_TOTAL, "   
cQuery	+=	" C1O.C1O_CODIGO, "
cQuery	+=	" C01.C01_CODIGO, " 
cQuery	+=	" C02.C02_CODIGO, "
cQuery	+=	" C1H.C1H_FILIAL, "  
cQuery	+=	" C1H.C1H_CODPAR, "
cQuery	+=	" C0Y.C0Y_CODIGO  "
cQuery	+=	"FROM " + RetSqlName( 'C20' ) + " D200 " 
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C01' ) + " C01  ON( C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=D200.C20_CODMOD AND C01.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C02' ) + " C02  ON( C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID=D200.C20_CODSIT AND C02.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C1H' ) + " C1H  ON( C1H.C1H_FILIAL='" + xFilial('C1H') + "' AND C1H.C1H_ID=D200.C20_CODPAR AND C1H.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C1O' ) + " C1O  ON( C1O.C1O_FILIAL='" + xFilial('C1O') + "' AND C1O.C1O_ID=D200.C20_CODCTA AND C1O.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C30' ) + " D201 ON( D201.C30_FILIAL = D200.C20_FILIAL AND D201.C30_CHVNF = D200.C20_CHVNF AND D201.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C0Y' ) + " C0Y  ON( C0Y.C0Y_FILIAL = '" + xFilial('C0Y') + "' AND C0Y.C0Y_ID = D201.C30_CFOP AND C0Y.D_E_L_E_T_ = ' ' ) "
cQuery	+=	"WHERE " 	
cQuery	+=	" D200.C20_FILIAL ='" + xFilial('C20') + "' AND " 
cQuery	+=	" D200.C20_DTDOC >='" + DToS( dDataIni ) + "' AND " 
cQuery	+=	" D200.C20_DTDOC <='" + DToS( dDataFim ) + "' AND " 
cQuery	+=	" D200.C20_INDOPE = '1' AND " 
cQuery  +=	" C02.C02_CODIGO NOT IN ('02','03','04','05') AND "
cQuery	+=	" D200.D_E_L_E_T_=' ' AND " 
cQuery	+=	" ( C01.C01_CODIGO='07' OR C01.C01_CODIGO='08' OR C01.C01_CODIGO='8B' OR C01.C01_CODIGO='09' OR C01.C01_CODIGO='10' OR C01.C01_CODIGO='11' OR C01.C01_CODIGO='26' OR C01.C01_CODIGO='27' OR C01.C01_CODIGO='57' ) "
cQuery	+=	" ORDER BY C01_CODIGO, C02_CODIGO, C20_SERIE, C20_SUBSER, C0Y_CODIGO, C20_DTDOC, C20_CHVNF "

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

While (cAliasQry)->( !Eof() )     

	/*------------------------------------
	Validacao e geracao do Registro D010
	-------------------------------------*/
	If !lGerD010
		BlcD010PC( cFilCnpj, nHdlTxt )      
		
		lGerD010 := .T.
    EndIf                      

	/*------------------------------
	Atualizo a Chave do registro
	-------------------------------*/	
	cChvNF  := ""
	cChvAux := (cAliasQry)->( C01_CODIGO + C02_CODIGO + C20_SERIE + C20_SUBSER + C0Y_CODIGO + C20_DTDOC )

	/*-----------------------------------------
	Alimento Array de Geracao do Registro D200
	------------------------------------------*/							
	(cAliasQry)-> ( Aadd( aD200, { C01_CODIGO,;
 	                				C02_CODIGO,;
		 	        				C20_SERIE,;
		 	        				C20_SUBSER,;
		 	        				C20_NUMDOC ,;
		 	        				C20_NUMDOC ,;
		 	        				C0Y_CODIGO,;
		 	        				C20_DTDOC,;
		 	        				0,;
		 	        				0 } ) )                   
	
	nPosD200 := Len( aD200 )
		 	        		
	/*--------------------
	Laco Do Registro D200 
	----------------------*/
	While (cAliasQry)->( !Eof() ) .And. cChvAux == (cAliasQry)->( C01_CODIGO + C02_CODIGO + C20_SERIE + C20_SUBSER + C0Y_CODIGO + C20_DTDOC )

		/*----------------------------------------------------------------------
		Manipulo a Variavel com a Chave da NF, para evitar Seeks desnecessarios
		no momento de gerar o registro D209
		-----------------------------------------------------------------------*/		        
        If cChvNF <> (cAliasQry)->C20_CHVNF
	       	cChvNF   := (cAliasQry)->C20_CHVNF	       	
	       	lFirstNF := .T.

			/*-----------------------------------------------------------------
			Atualizo os valores da Nota Fiscal e Desconto para a  NF encontrada
			------------------------------------------------------------------*/        					
			aD200[ nPosD200, 9 ]  += C20_VLDOC                      
			aD200[ nPosD200, 10 ] += C20_VLDESC		
		EndIf     
		
		
		/*-------------------------------------------------------------
		Neste Momento Busca a Nota Fiscal Inicial e Final do Registro
		--------------------------------------------------------------*/        
        If (cAliasQry)->C20_NUMDOC < aD200[ nPosD200, 5 ]
	        aD200[ nPosD200, 5 ] := (cAliasQry)->C20_NUMDOC
        EndIf
        
        If (cAliasQry)->C20_NUMDOC > aD200[ nPosD200, 6 ]
	        aD200[ nPosD200, 6 ]  := (cAliasQry)->C20_NUMDOC
        EndIf                                       
        
		/*-------------------------
		Busco Codigo do Tributo PIS
		--------------------------*/        
		cCdTrib := ""
		If C3S->( MsSeek( xFilial("C3S") + "06" ) )
	        cCdTrib := C3S->C3S_ID
        EndIf
        
		/*--------------------------------------------------
		Busca Informacoes de Tributos de Pis na Tabela C35
		---------------------------------------------------*/        
        lSeek := C35->( MsSeek( xFilial("C35") + cChvNF + (cAliasQry)->( C30_NUMITE + C30_CODITE + cCdTrib ) ) )

		If lSeek	         
		
			cCodCst := Iif( C17->( MsSeek( xFilial("C17") + C35->C35_CST ) ), C17->C17_CODIGO, "" )
				    			
			/*-------------------------------------------------
			Neste Momento Aglutino os Valores do Registro D201
			---------------------------------------------------*/                
		    If ( nPos := ( cAliasQry )->( aScan( aD201 , { | aX | aX[ 1 ] == cCodCst .And. aX[ 4 ] == C35->C35_ALIQ .And. aX[ 6 ] == C1O_CODIGO } ) ) ) == 0 		
	
					/*-----------------------------------------
					Alimento Array de Geracao do Registro D201
					------------------------------------------*/							
					Aadd( aD201, { cCodCst,;
									0,;
									0,;
									C35->C35_ALIQ,;                                                                                             									
									0,;
									C1O_CODIGO } )                                                                                              
									
					nPos := Len( aD201 )									
			EndIf				       
			
			aD201[ nPos, 2 ] += (cAliasQry)->C30_TOTAL
			aD201[ nPos, 3 ] +=  C35->C35_BASE
			aD201[ nPos, 5 ] +=  C35->C35_VALOR
			
		EndIf        
		
		/*-----------------------------
		Busco Codigo do Tributo Cofins
		------------------------------*/        
		cCdTrib := ""
		If C3S->( MsSeek( xFilial("C3S") + "07" ) )
	        cCdTrib := C3S->C3S_ID
        EndIf
        
		/*--------------------------------------------------
		Busca Informacoes de Tributos de Cofins na Tabela C35
		---------------------------------------------------*/        
        lSeek := C35->( MsSeek( xFilial("C35") + cChvNF + (cAliasQry)->( C30_NUMITE + C30_CODITE + cCdTrib ) ) )

		If lSeek	         
		
			cCodCst := Iif( C17->( MsSeek( xFilial("C17") + C35->C35_CST ) ), C17->C17_CODIGO, "" )
				    			
			/*-------------------------------------------------
			Neste Momento Aglutino os Valores do Registro D205
			---------------------------------------------------*/                
		    If ( nPos := ( cAliasQry )->( aScan( aD205 , { | aX | aX[ 1 ] == cCodCst .And. aX[ 4 ] == C35->C35_ALIQ .And. aX[ 6 ] == C1O_CODIGO } ) ) ) == 0 		
	
					/*-----------------------------------------
					Alimento Array de Geracao do Registro D205
					------------------------------------------*/							
					Aadd( aD205, { cCodCst,;
									0,;
									0,;
									C35->C35_ALIQ,;                                                                                             									
									0,;
									C1O_CODIGO } )                                                                                              
									
					nPos := Len( aD205 )									
			EndIf				       
			
			aD205[ nPos, 2 ] += (cAliasQry)->C30_TOTAL
			aD205[ nPos, 3 ] +=  C35->C35_BASE
			aD205[ nPos, 5 ] +=  C35->C35_VALOR
			
		EndIf   

		/*-------------------------------------------------
		Neste Momento Aglutino os Valores do Registro D209
		---------------------------------------------------*/                		
		If lFirstNF    
		
			lFirstNF := .F.
			
			If C6W->( MsSeek( xFilial("C6W") + cChvNF ) )                                           
				While C6W->(!Eof()) .And. C6W->C6W_CHVNF  == cChvNF		
					If C1G->(MsSeek( xFilial("C1G") + C6W->C6W_NUMERO ) )
					
						//Para os codigos 0 e 2 nao devem ser gerados os registros de processo referenciado
						//no sped contribuicoes
						If AllTrim( C1G->C1G_INDPRO ) $ ("1|3|9")					
						    If ( nPos := ( cAliasQry )->( aScan( aD209 , { | aX | aX[ 1 ] == C1G->C1G_NUMPRO .And. aX[ 2 ] == C1G->C1G_INDPRO } ) ) ) == 0 				
					
								/*-----------------------------------------
								Alimento Array de Geracao do Registro D209
								------------------------------------------*/							
								Aadd( aD209, { C1G->C1G_NUMPRO,;
												C1G->C1G_INDPRO } )
					
							EndIf				
						EndIf
					EndIf                   
					C6W->(DbSkip())   			
				EndDo				
			EndIf                   
		EndIf
		
		(cAliasQry)->(DbSkip())		
	EndDo         
							 			 			 		 								      			
	/*--------------
	Gravacao do D200 
	---------------*/
	LoadString( 'D200' , aCmps , @cStrTxt , , , , aD200 )
	nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	
		
	If	nRWStrTxt > 0                              
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conta os registros para totalizar no bloco 9³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TaFContBlc("D200",aTotRegD) 
	    
		If Len(aD201)>0
			/*--------------
			Gravacao do D201 
			---------------*/
			LoadString( 'D201' , aCmps , @cStrTxt , , , , aD201 )
			nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	
		
			If nRWStrTxt == -1
				Exit    
			Else
				/*---------------------------------------------------------------
				Realizo a totalizao dos registros para o Bloco 9 e Registro D990
				----------------------------------------------------------------*/		
				If Len( aTotRegD ) <= 0 .Or. ( nlY := aScan( aTotRegD, { |x| x[1] == "D201" } ) ) <= 0
					Aadd( aTotRegD,  { "D201", 0 }  )
					nlY := Len( aTotRegD )
				EndIf                      	
				aTotRegD[nlY][2] +=  Len( aD201 )				
			EndIf        
		EndIf
		
		If Len( aD205 ) > 0
			/*--------------
			Gravacao do D205 
			---------------*/
			LoadString( 'D205' , aCmps , @cStrTxt , , , , aD205 )
			nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	
		
			If nRWStrTxt == -1
				Exit
			Else
				/*---------------------------------------------------------------
				Realizo a totalizao dos registros para o Bloco 9 e Registro D990
				----------------------------------------------------------------*/		
				If Len( aTotRegD ) <= 0 .Or. ( nlY := aScan( aTotRegD, { |x| x[1] == "D205" } ) ) <= 0
					Aadd( aTotRegD,  { "D205", 0 }  )
					nlY := Len( aTotRegD )
				EndIf                      	
				aTotRegD[nlY][2] +=  Len( aD205 )				
			EndIf        
		EndIf				

		If Len( aD209 ) > 0
			/*--------------
			Gravacao do D209 
			---------------*/
			LoadString( 'D209' , aCmps , @cStrTxt , , , , aD209 )
			nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	
		
			If nRWStrTxt == -1
				Exit
			Else
				/*---------------------------------------------------------------
				Realizo a totalizao dos registros para o Bloco 9 e Registro D990
				----------------------------------------------------------------*/		
				If Len( aTotRegD ) <= 0 .Or. ( nlY := aScan( aTotRegD, { |x| x[1] == "D209" } ) ) <= 0
					Aadd( aTotRegD,  { "D209", 0 }  )
					nlY := Len( aTotRegD )
				EndIf                      	
				aTotRegD[nlY][2] +=  Len( aD209 )				
			EndIf        
		EndIf										
	EndIf                      
    
	/*----------------------------------
	Zerando Arrays para Proximo Registro 
	-----------------------------------*/
	aD200 := {}
	aD201 := {}
	aD205 := {}
	aD209 := {}
	
EndDo                     

If nRWStrTxt == -1
	MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
EndIf
		
Return ( Nil )    

//-------------------------------------------------------------------
/*/{Protheus.doc} BlcD300PC
Funcao responsavel processar o movimento especifico para montagem dos registros:
D300, D309

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		nHdlTxt	->	Handle do arquivo aberto para gravacao          
		lGerD010   ->  Indica se Foi gerado o Registro D010      
		cFilCnpj   ->  Cnpj para geracao do Registro D010		
		
@return NIL

@author Rodrigo Aguilar
@since 19/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlcD300PC( dDataIni , dDataFim , nHdlTxt, lGerD010, cFilCnpj  )		                         	
	
Local	cQuery		:= ''         
Local	cQueryCons	:= ''  
Local   cCdTrib     := ''
Local   cCodCst     :=  ''

Local	cChvNF		:=	''
Local	cChvAux		:=	''   

Local	cStrTxt		:=	''
Local	cStrTxt2	:=	''
Local	cStrTxt3	:=	''

Local 	cAliasQry 	:=  GetNextAlias() 
Local 	cAliasQryC 	:=  GetNextAlias() 
Local	aCmps		:=	DistCmpPC()

Local	nRWStrTxt	:=	0 
Local	nPosD300   	:=	0
Local   nPos        :=  0

Local   lFirstNF    := .T.           

Local	aD300		:= {}      
Local   aD309       := {}

/*-------------------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
--------------------------------------------------------------------*/
C6W->( dbSetOrder( 1 ) )
C1G->( dbSetOrder( 3 ) )      
C0Y->( dbSetOrder( 3 ) ) 
C3S->( dbSetOrder( 1 ) )     
C2F->( dbSetOrder( 1 ) )     
C17->( dbSetOrder( 3 ) )   
                                      

/*---------------------------
Query pelo consolidado
------------------------------*/

cQueryCons	+=	"SELECT "
cQueryCons	+=	" C01.C01_CODIGO,  "
cQueryCons	+=	" D300.C7Z_NSER, "
cQueryCons	+=	" D300.C7Z_NSSER,  "
cQueryCons	+=	" D300.C7Z_NDCINI, " 
cQueryCons	+=	" D300.C7Z_NDCFIM, " 
cQueryCons	+=	" C0Y.C0Y_CODIGO, " 
cQueryCons	+=	" D300.C7Z_DTREF, " 
cQueryCons	+=	" D300.C7Z_VLDOC,  "
cQueryCons	+=	" D300.C7Z_VLDESC, "
cQueryCons	+=	" C17P.C17_CODIGO CSTPIS,  "                           	
cQueryCons	+=	" D300.C7Z_VLBCPI, " 
cQueryCons	+=	" D300.C7Z_ALQPIS, " 
cQueryCons	+=	" D300.C7Z_VLPIS, " 
cQueryCons	+=	" C17C.C17_CODIGO CSTCOFINS, " 
cQueryCons	+=	" D300.C7Z_VLBCCF, " 
cQueryCons	+=	" D300.C7Z_ALQCFS, " 
cQueryCons	+=	" D300.C7Z_VLCOFI, " 
cQueryCons	+=	" C1O.C1O_CODIGO, "                                                                                                                
cQueryCons	+=	" C1O.C1O_FILIAL, "                                                                                                                
cQueryCons	+=	" D309.C70_IDPRO "                                                                                                                                                                                                                              
cQueryCons	+=	" FROM " + RetSqlName( 'C7Z' ) + " D300 "                                                                                           
cQueryCons	+=	" LEFT JOIN " + RetSqlName( 'C70' ) + " D309  ON ( D309.C70_FILIAL = '" + xFilial('C70') + "' AND D309.C70_ID=D300.C7Z_ID AND D309.D_E_L_E_T_ = ' ' ) "
cQueryCons	+=	" LEFT JOIN " + RetSqlName( 'C01' ) + " C01   ON ( C01.C01_FILIAL = '" + xFilial('C01') + "' AND C01.C01_ID=D300.C7Z_IDMOD AND C01.D_E_L_E_T_ = ' ' ) "
cQueryCons	+=	" LEFT JOIN " + RetSqlName( 'C1O' ) + " C1O   ON ( C1O.C1O_FILIAL = '" + xFilial('C1O') + "' AND C1O.C1O_ID=D300.C7Z_CTA AND C1O.D_E_L_E_T_ = ' ' ) "
cQueryCons  +=  " LEFT JOIN " + RetSqlName( 'C17' ) + " C17P  ON ( C17P.C17_FILIAL = '" + xFilial("C17") + "' AND C17P.C17_ID = D300.C7Z_CSTPIS AND C17P.D_E_L_E_T_ = '' ) "
cQueryCons  +=  " LEFT JOIN " + RetSqlName( 'C17' ) + " C17C  ON ( C17C.C17_FILIAL = '" + xFilial("C17") + "' AND C17C.C17_ID = D300.C7Z_CSTCFS AND C17C.D_E_L_E_T_ = '' ) "
cQueryCons  +=  " LEFT JOIN " + RetSqlName( 'C0Y' ) + " C0Y   ON ( C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' AND C0Y.C0Y_ID = D300.C7Z_CFOP AND C0Y.D_E_L_E_T_ = '' ) "
cQueryCons	+=	"WHERE " 	
cQueryCons	+=	" D300.C7Z_FILIAL ='" + xFilial('C7Z') + "' AND " 
cQueryCons	+=	" D300.C7Z_DTMOV >='" + DToS( dDataIni ) + "' AND " 
cQueryCons	+=	" D300.C7Z_DTMOV <='" + DToS( dDataFim ) + "' AND " 
cQueryCons	+=	" D300.D_E_L_E_T_=' ' AND " 
cQueryCons	+=	" ( C01.C01_CODIGO = '13' OR C01.C01_CODIGO = '14' OR C01.C01_CODIGO = '15' OR C01.C01_CODIGO  = '16' OR C01.C01_CODIGO  = '18' ) "
cQueryCons	+=	" ORDER BY "
cQueryCons  +=  "	C7Z_IDMOD, C7Z_NSER, C7Z_NSSER, C7Z_DTREF "


cQueryCons	:=	ChangeQuery( cQueryCons )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQueryCons ) , cAliasQryC )


nTotReg := Contar(cAliasQryC,"!Eof()")
DbSelectArea( cAliasQryC )
( cAliasQryC )->( DbGoTop( ) )   

If (nTotReg > 0)


	/*-----------------
	While do Documento
	------------------*/
	While (cAliasQryC)->( !Eof() ) 
	
		/*------------------------------------
		Validacao e geracao do Registro D010
		-------------------------------------*/
		If !lGerD010
			BlcD010PC( cFilCnpj, nHdlTxt )      
			
			lGerD010 := .T.
	    EndIf   
	
			
		( cAliasQryC )->( aAdd( aD300, {	C01_CODIGO,;
											C7Z_NSER,;
											C7Z_NSSER,;
											C7Z_NDCINI,;
											C7Z_NDCFIM,;
											C0Y_CODIGO,;
											C7Z_DTREF,;
											C7Z_VLDOC,;
											C7Z_VLDESC,;
									   		CSTPIS,;
											C7Z_VLBCPI,;
											C7Z_ALQPIS,;
											C7Z_VLPIS,;
									   		CSTCOFINS,;
											C7Z_VLBCCF,;
											C7Z_ALQCFS,;
											C7Z_VLCOFI,;
											C1O_CODIGO } ) )    
        
		nPosD300 := Len( aD300 )
                            

		/*----------------------------------------------------------
		Gravo array com dados do registro filho D359, gravando
		a identificacao do PAI na primeira posicao para nao se
		perder a referencia no momento da impressao das informacoes
		-----------------------------------------------------------*/								                      
		If C1G->(MsSeek( xFilial("C1G") + (cAliasQryC)->C70_IDPRO) ) .AND. (C01_CODIGO != '18') // PARA MODELO 18 Nao gera registro D309
		    If ( nPos := ( cAliasQryC )->( aScan( aD309 , { | aX | aX[ 2 ] == C1G->C1G_NUMPRO .And. aX[ 3 ] == C1G->C1G_INDPRO } ) ) ) == 0 				
	    	
				//Para os codigos 0 e 2 nao devem ser gerados os registros de processo referenciado
				//no sped contribuicoes
				If AllTrim( C1G->C1G_INDPRO ) $ ("1|3|9")	    	
			    	/*-----------------------------------------
					Alimento Array de Geracao do Registro D309
					------------------------------------------*/			 			
						Aadd( aD309, {  nPosD300,;
										C1G->C1G_NUMPRO,;
										C1G->C1G_INDPRO } )
				EndIf
			EndIf				
		EndIf                   
 
		(cAliasQryC)->(DbSkip())  
		
		For nPosD300 := 1 To Len( aD300	)
			LoadString( 'D300' , aCmps , @cStrTxt , , , , aD300[ nPosD300 ] , , .T. )
			nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	

			/*--------------
			Gravacao do D309 
			---------------*/		
			If	nRWStrTxt > 0 
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Conta os registros para totalizar no bloco 9³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TaFContBlc("D300",aTotRegD) 				
							
				If Len( aD309 ) > 0				
					For nPos := 1 To Len( aD309 )				
						If aD309[ nPos, 1 ] == nPosD300
							LoadString( 'D309' , aCmps , @cStrTxt , , , , aD309[nPos], , .T. )
							nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	
						
							If nRWStrTxt == -1
								Exit
							Else
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Conta os registros para totalizar no bloco 9³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								TaFContBlc("D309",aTotRegD) 					
							EndIf        
						EndIf
					Next
				EndIf												
			EndIf  	           

		Next																	    
        
		/*----------------------------------
		Zerando Arrays para Proximo Registro 
		-----------------------------------*/
		aD300 := {}
		aD309 := {}	
	EndDo


Else        
	
	cAliasQry 	:=  GetNextAlias()
	/*-----------------------------
	Query principal do movimento 
	------------------------------*/      
	cQuery	+=	"SELECT "
	cQuery	+=	" D300.C20_FILIAL, "
	cQuery	+=	" D300.C20_CHVNF,  "
	cQuery	+=	" D300.C20_NUMDOC, "
	cQuery	+=	" D300.C20_SERIE,  "
	cQuery	+=	" D300.C20_SUBSER, " 
	cQuery	+=	" D300.C20_VLDOC,  "
	cQuery	+=	" D300.C20_VLDESC, "
	cQuery	+=	" D300.C20_DTDOC,  "                           	
	cQuery	+=	" C1O.C1O_CODIGO,  "
	cQuery	+=	" C1O.C1O_FILIAL,  "
	cQuery	+=	" C01.C01_CODIGO  "                                                                                                               
	cQuery	+=	"FROM " + RetSqlName( 'C20' ) + " D300 "                                                                                           
	cQuery	+=	" LEFT JOIN " + RetSqlName( 'C01' ) + " C01  ON( C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=D300.C20_CODMOD AND C01.D_E_L_E_T_ = ' ' ) "
	cQuery	+=	" LEFT JOIN " + RetSqlName( 'C02' ) + " C02  ON( C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID=D300.C20_CODSIT AND C02.D_E_L_E_T_ = ' ' ) "
	cQuery	+=	" LEFT JOIN " + RetSqlName( 'C1O' ) + " C1O  ON( C1O.C1O_FILIAL='" + xFilial('C1O') + "' AND C1O.C1O_ID=D300.C20_CODCTA AND C1O.D_E_L_E_T_ = ' ' ) "
	cQuery	+=	"WHERE " 	
	cQuery	+=	" D300.C20_FILIAL ='" + xFilial('C20') + "' AND " 
	cQuery +=	" ((D300.C20_INDOPE = '0' AND D300.C20_DTES  >= '" + DTOS(dDataIni) + "' AND D300.C20_DTES  <='"  + DTOS(dDataFim) + "') OR "
	cQuery +=	"  (D300.C20_INDOPE = '1' AND D300.C20_DTDOC >= '" + DTOS(dDataIni) + "' AND D300.C20_DTDOC <='" + DTOS(dDataFim) + "')) AND "
	cQuery	+=	" C02.C02_CODIGO <> '02' AND " 
	cQuery	+=	" D300.D_E_L_E_T_=' ' AND " 
	cQuery	+=	" ( C01.C01_CODIGO = '13' OR C01.C01_CODIGO = '14' OR C01.C01_CODIGO = '15' OR C01.C01_CODIGO = '16' OR C01.C01_CODIGO = '18' ) "
	cQuery	+=	" ORDER BY "
	cQuery  +=  "	C01_CODIGO, C20_SERIE, C20_SUBSER, C20_DTDOC, C20_CHVNF  "
	
	cQuery	:=	ChangeQuery( cQuery )
	dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )
	                      
	
	/*-----------------
	While do Documento
	------------------*/
	While (cAliasQry)->( !Eof() ) 
	
		/*------------------------------------
		Validacao e geracao do Registro D010
		-------------------------------------*/
		If !lGerD010
			BlcD010PC( cFilCnpj, nHdlTxt )      
			
			lGerD010 := .T.
	    EndIf
	    
		cChvAux := ( cAliasQry )->( C01_CODIGO + C20_SERIE + C20_SUBSER + C20_DTDOC )
		    
		While (cAliasQry)->( !Eof() ) .And. cChvAux == ( cAliasQry )->( C01_CODIGO + C20_SERIE + C20_SUBSER + C20_DTDOC )
	      	
			/*----------------------------
			Atualiza Chave da Nota Fiscal 
			-----------------------------*/	 	
			cChvNF	:= (cAliasQry)->C20_CHVNF
		      				
			/*------------------------------------------------
			Zerando as Variaveis para inicio do Processamento
			-------------------------------------------------*/			  
			nCstPis    := ""
			nCstCof    := ""
			cCfop      := ""
			
			nAlqPrdPis := 0
			nAlqPrdCof := 0
	
			nVlrBCPis  := 0		
			nVlrBCCof  := 0
			
			nVlTrbPis  := 0		
			nVlTrbCof  := 0		
			
			If C2F->( MsSeek( xFilial("C2F") + cChvNF )) 
				While C2F->(!Eof()) .And. (cAliasQry)->C20_FILIAL + (cAliasQry)->C20_CHVNF == C2F->( C2F_FILIAL + C2F_CHVNF)	
					
					/*------------------------------------------------
					Buscando Informacoes de PIS do Periodo
					-------------------------------------------------*/			  										
					If C3S->( MsSeek( xFilial("C3S") + "06" ) )

						If C3S->C3S_ID == C2F->C2F_CODTRI   
						 
							nCstPis  := ""
							cCfop    := ""
								
						    If C17->( MsSeek( xFilial("C17") + C2F->C2F_CST ) )
								nCstPis  := C17->C17_CODIGO
							EndIf    
		
						    If C0Y->( MsSeek( xFilial("C0Y") + C2F->C2F_CFOP ) )
								cCfop  := C0Y->C0Y_CODIGO
							EndIf    										                   
							
							nAlqPrdPis  := C2F->C2F_ALIQ				
							nVlrBCPis   := C2F->C2F_BASE
							nVlTrbPis   := C2F->C2F_VALOR					
							                
							If ( nPosD300 := ( cAliasQry )->( aScan( aD300 , { | aX | aX[ 1 ] == C01_CODIGO .And. aX[ 2 ] == C20_SERIE .And. ;
							                                                           aX[ 3 ] == C20_SUBSER .And. aX[ 6 ] == cCfop .And. ;
							                                                           aX[ 7 ] == C20_DTDOC .And. aX[10] == nCstPis .And. ;
							                                                           aX[12] ==  nAlqPrdPis .And. ;
							                                                           aX[18] == C1O_CODIGO } ) ) ) == 0 					
												
		                         
		
								( cAliasQry )->( aAdd( aD300, {	C01_CODIGO,;
																	C20_SERIE,;
																	C20_SUBSER,;
																	C20_NUMDOC,;
																	C20_NUMDOC,;
																	cCfop,;
																	C20_DTDOC,;
																	C20_VLDOC,;
																	C20_VLDESC,;
																	nCstPis,;
																	0,;
																	nAlqPrdPis,;
																	0,;
																	"",;
																	0,;
																	0,;
																	0,;
																	C1O_CODIGO } ) ) 
																	
								nPosD300 := Len( aD300 )	
							Else
								aD300[ nPosD300, 10 ] := nCstPis
					       	aD300[ nPosD300, 12 ] := nAlqPrdPis 							
							EndIf 
							
							If  ( cAliasQry )->C20_NUMDOC <= aD300[ nPosD300, 04 ]             
								aD300[ nPosD300, 04 ]  :=   ( cAliasQry )->C20_NUMDOC         		
							EndIf
					
					
							If  ( cAliasQry )->C20_NUMDOC <= aD300[ nPosD300, 05 ]             
								aD300[ nPosD300, 05 ]  :=  ( cAliasQry )->C20_NUMDOC         		
							EndIf
					        		
							aD300[ nPosD300, 11 ] += nVlrBCPis
							aD300[ nPosD300, 13 ] += nVlTrbPis					           					
						EndIf                           
					EndIf
					
					
					/*------------------------------------------------
					Buscando Informacoes de COFINS do Periodo
					-------------------------------------------------*/			  										
					If C3S->( MsSeek( xFilial("C3S") + "07" ) )
			 			If C3S->C3S_ID == C2F->C2F_CODTRI 
			                                                                            
							nCstCof  := ""
							cCfop    := ""
											
						    If C17->( MsSeek( xFilial("C17") + C2F->C2F_CST ) )
								nCstCof  := C17->C17_CODIGO
							EndIf    
		
						    If C0Y->( MsSeek( xFilial("C0Y") + C2F->C2F_CFOP ) )
								cCfop  := C0Y->C0Y_CODIGO
							EndIf    										                   
							
							nAlqPrdCof  := C2F->C2F_ALIQ				
							nVlrBCCof   := C2F->C2F_BASE
							nVlTrbCof   := C2F->C2F_VALOR					
							                
							If ( nPosD300 := ( cAliasQry )->( aScan( aD300 , { | aX | aX[ 1 ] == C01_CODIGO .And. ;
																				   aX[2] == C20_SERIE .And. ;
							                                                       aX[3] == C20_SUBSER .And. ;
							                                                       aX[6] == cCfop .And. ;
						                                                           aX[7] == C20_DTDOC .And. ;
						                                                           (aX[14] == nCstCof .OR. aX[14]=="")  .And. ;
						                                                           (aX[16] == If(nAlqPrdCof > 0,nAlqPrdCof,"") .OR. aX[16]==0) .And. ;
						                                                           aX[18] == C1O_CODIGO } ) ) ) == 0 																
		
								( cAliasQry )->( aAdd( aD300, {	C01_CODIGO,;
																	C20_SERIE,;
																	C20_SUBSER,;
																	C20_NUMDOC,;
																	C20_NUMDOC,;
																	cCfop,;
																	C20_DTDOC,;
																	C20_VLDOC,;
																	C20_VLDESC ,;
																	"",;
																	0,;
																	0,;
																	0,;
																	nCstCof,;
																	0,;
																	If(nAlqPrdCof > 0,nAlqPrdCof,""),;
																	0,;
																	C1O_CODIGO } ) )		  
																	
								nPosD300 := Len( aD300 )																									
		                 	ELse 
		                		aD300[ nPosD300, 14 ] := nCstCof					
								aD300[ nPosD300, 16 ] := nAlqPrdCof	  
							EndIf 
							
							If  ( cAliasQry )->C20_NUMDOC <= aD300[ nPosD300, 04 ]             
								aD300[ nPosD300, 04 ]  :=   ( cAliasQry )->C20_NUMDOC         		
							EndIf
					
					
							If  ( cAliasQry )->C20_NUMDOC <= aD300[ nPosD300, 05 ]             
								aD300[ nPosD300, 05 ]  :=  ( cAliasQry )->C20_NUMDOC         		
							EndIf
					        		
							aD300[ nPosD300, 15 ] += nVlrBCCof
							aD300[ nPosD300, 17 ] += nVlTrbCof					
							           					
						EndIf                           
					EndIf     		
					
					C2F->(DbSkip())
				EndDo      
			EndIf

			( cAliasQry )->(DbSkip())
		EndDo
		
	EndDo        
	
	/*--------------
	Gravacao do D300 
	---------------*/	
	For nPosD300 := 1 To Len( aD300	)
		LoadString( 'D300' , aCmps , @cStrTxt , , , , aD300[ nPosD300 ] , , .T. )
		nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conta os registros para totalizar no bloco 9³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TaFContBlc("D300",aTotRegD) 	
	Next
		
	If nRWStrTxt == -1
		MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
	EndIf	
EndIf

Return ( Nil )
                         
//-------------------------------------------------------------------
/*/{Protheus.doc} BlcD350PC
Funcao responsavel processar o movimento especifico para montagem dos registros:
D350, D359

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		nHdlTxt		->	Handle do arquivo aberto para gravacao  
		lGerD010    ->  Indica se Foi gerado o Registro D010      
		cFilCnpj    ->  Cnpj para geracao do Registro D010		
		
@return NIL

@author Rodrigo Aguilar
@since 20/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlcD350PC( dDataIni , dDataFim , nHdlTxt, lGerD010, cFilCnpj )

Local	cQuery		:= ''         
Local   cCdTrib     := ''
Local   cCodCst     :=  ''

Local	cChvNF		:=	''
Local	cChvAux		:=	''   

Local	cStrTxt		:=	''
Local	cStrTxt2	:=	''
Local	cStrTxt3	:=	''
                               
Local 	cAliasQryC	:=  GetNextAlias()
Local 	cAliasQry 	:=  GetNextAlias()
Local	aCmps		:=	DistCmpPC()

Local	nRWStrTxt	:=	0  
Local   nPos        :=  0
Local	nPosD350   	:=	0     

Local 	nVlGrTf     :=  0
Local	nVlBru      :=  0  

Local	nCstPis    := ""
Local	nAlqPrdPis := 0
Local	nAlqQtdPis := 0
				
Local	nCstCof    := ""
Local	nAlqPrdCof := 0
Local	nAlqQtdCof := 0 

Local	nVlrBCPis  := 0
Local	nQtdBCPis  := 0
Local	nVlTrbPis  := 0
		
Local	nVlrBCCof  := 0
Local	nQtdBCCof  := 0
Local	nVlTrbCof  := 0		

Local   lSeekPis    := .F.           
Local   lSeekCof    := .F.           

Local	aD350		:= {}      
Local   aD359       := {}

/*-------------------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
--------------------------------------------------------------------*/
C6L->( dbSetOrder( 1 ) )
C6G->( dbSetOrder( 1 ) )
C6K->( dbSetOrder( 1 ) )
C1G->( dbSetOrder( 3 ) )      
C3S->( dbSetOrder( 1 ) )   
C17->( dbSetOrder( 3 ) )   


/*-----------------------------
Query do consolidado
------------------------------*/ 
cQueryCons := " SELECT "
cQueryCons += "	 	C01.C01_CODIGO, "
cQueryCons += "	 	D350.C71_ECFMOD, "
cQueryCons += "	 	D350.C71_ECFFAB, "
cQueryCons += "	 	D350.C71_DTDOC,  "
cQueryCons += "	 	D350.C71_CRO, "
cQueryCons += "	 	D350.C71_CRZ, "
cQueryCons += "	 	D350.C71_COOFIN, "
cQueryCons += "	 	D350.C71_GTFIN, "
cQueryCons += "	 	D350.C71_VLBRT, "
cQueryCons += "	    C17P.C17_CODIGO CSTPIS,  "   
cQueryCons += "	 	D350.C71_BCPIS, "
cQueryCons += "	 	D350.C71_ALQPIS, "
cQueryCons += "	 	D350.C71_QTDBCP, "
cQueryCons += "	 	D350.C71_QTDPIS, "
cQueryCons += "	 	D350.C71_VLPIS, "
cQueryCons += "	 	C17C.C17_CODIGO CSTCOFINS, "
cQueryCons += "	 	D350.C71_BCCOF, "
cQueryCons += "	 	D350.C71_ALQCOF, "
cQueryCons += "	 	D350.C71_QTDBCC, "
cQueryCons += "	 	D350.C71_QTDCOF, "
cQueryCons += "	 	D350.C71_VLCOF, "
cQueryCons += "	 	C1O.C1O_CODIGO, "
cQueryCons += "	 	D359.C72_NUMPRO "
cQueryCons += " FROM       "
cQueryCons += 		RetSqlName("C71") + " D350 "
cQueryCons += " LEFT JOIN " + RetSqlName("C72") + " D359 ON ( D350.C71_FILIAL = D359.C72_FILIAL  AND D350.C71_ID = D359.C72_ID AND D359.D_E_L_E_T_ = ' ' ) "
cQueryCons += " LEFT JOIN " + RetSqlName( 'C01' ) + " C01   ON ( C01.C01_FILIAL = '" + xFilial('C01') + "' AND C01.C01_ID=D350.C71_CODMOD AND C01.D_E_L_E_T_ = ' ' ) "
cQueryCons += " LEFT JOIN " + RetSqlName( 'C1O' ) + " C1O   ON ( C1O.C1O_FILIAL = '" + xFilial('C1O') + "' AND C1O.C1O_ID=D350.C71_CTA AND C1O.D_E_L_E_T_ = ' ' ) "
cQueryCons += " LEFT JOIN " + RetSqlName( 'C17' ) + " C17P  ON ( C17P.C17_FILIAL = '" + xFilial("C17") + "' AND C17P.C17_ID = D350.C71_CSTPIS AND C17P.D_E_L_E_T_ = '' ) "
cQueryCons += " LEFT JOIN " + RetSqlName( 'C17' ) + " C17C  ON ( C17C.C17_FILIAL = '" + xFilial("C17") + "' AND C17C.C17_ID = D350.C71_CSTCOF AND C17C.D_E_L_E_T_ = '' ) "
cQueryCons += " WHERE "
cQueryCons += "	 	C01.C01_CODIGO = '2E' OR C01.C01_CODIGO = '13' OR C01.C01_CODIGO = '14' OR C01.C01_CODIGO = '15' OR C01.C01_CODIGO = '16' AND"
cQueryCons += "	 	D350.C71_DTMOV >= '" + DToS( dDataIni ) + "' AND D350.C71_DTMOV <= '" + DToS( dDataFim ) + "' AND "
cQueryCons += " 	D350.C71_FILIAL ='" + xFilial("C71") + "' AND " 
cQueryCons += "		D350.D_E_L_E_T_ = '' " 
cQueryCons += " ORDER BY          "
cQueryCons += "	 	D350.C71_DTMOV, "
cQueryCons += " 	D350.C71_ID "


cQueryCons	:=	ChangeQuery( cQueryCons )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQueryCons ) , cAliasQryC )
  

nTotReg := Contar(cAliasQryC,"!Eof()")
DbSelectArea( cAliasQryC )
( cAliasQryC )->( DbGoTop( ) )    

If (nTotReg > 0)         

	/*-----------------
	While do Documento
	------------------*/
	While (cAliasQryC)->( !Eof() ) 
	
		/*------------------------------------
		Validacao e geracao do Registro D010
		-------------------------------------*/
		If !lGerD010
			BlcD010PC( cFilCnpj, nHdlTxt )      
			
			lGerD010 := .T.
	    EndIf
	    
    	/*-----------------------------------------
		Alimento Array de Geracao do Registro D350
		------------------------------------------*/							
		(cAliasQryC)->( Aadd( aD350, { C01_CODIGO,;
			 	        			   C71_ECFMOD,;
			 	        			   C71_ECFFAB,;
			 	        			   C71_DTDOC,;
			 	        			   C71_CRO,;
			 	        			   C71_CRZ,;
									   C71_COOFIN,;
									   C71_GTFIN,;		 	        			   	
			 	        			   C71_VLBRT,; 
			 	        			   CSTPIS,;
			 	        			   C71_BCPIS,;
			 	        			   C71_ALQPIS,;
			 	        			   If (C71_QTDBCP>0,C71_QTDBCP,""),;
			 	        			   If (C71_QTDPIS>0,C71_QTDPIS,""),;			 	        			   
			 	        			   C71_VLPIS,;
			 	        			   CSTCOFINS,;
			 	        			   C71_BCCOF,;
			 	        			   C71_ALQCOF,;
			 	        			   If (C71_QTDBCC>0,C71_QTDBCC,""),;
			 	        			   If (C71_QTDCOF>0,C71_QTDCOF,""),;			 	        			   
			 	        			   C71_VLCOF,;
			 	        			   C1O_CODIGO } ) )    
		
		nPosD350 := Len( aD350 )
                            

		/*----------------------------------------------------------
		Gravo array com dados do registro filho D359, gravando
		a identificacao do PAI na primeira posicao para nao se
		perder a referencia no momento da impressao das informacoes
		-----------------------------------------------------------*/								                      
		If C1G->(MsSeek( xFilial("C1G") + (cAliasQryC)->C72_NUMPRO) )
		    If ( nPos := ( cAliasQryC )->( aScan( aD359 , { | aX | aX[ 2 ] == C1G->C1G_NUMPRO .And. aX[ 3 ] == C1G->C1G_INDPRO } ) ) ) == 0 				
	    	
				//Para os codigos 0 e 2 nao devem ser gerados os registros de processo referenciado
				//no sped contribuicoes
				If AllTrim( C1G->C1G_INDPRO ) $ ("1|3|9")
							    	
			    	/*-----------------------------------------
					Alimento Array de Geracao do Registro D359
					------------------------------------------*/			 			
						Aadd( aD359, {  nPosD350,;
										C1G->C1G_NUMPRO,;
										C1G->C1G_INDPRO } )
				EndIf
	
			EndIf				
		EndIf                   
		                
		(cAliasQryC)->(DbSkip()) 
		
		/*--------------
		Gravacao do D350 
		---------------*/	   
		For nPosD350 := 1 To Len( aD350	)
			LoadString( 'D350' , aCmps , @cStrTxt , , , , aD350[ nPosD350 ] , , .T. )
			nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	

			/*--------------
			Gravacao do D359 
			---------------*/		
			If	nRWStrTxt > 0 
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Conta os registros para totalizar no bloco 9³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TaFContBlc("D350",aTotRegD) 
							
				If Len( aD359 ) > 0				
					For nPos := 1 To Len( aD359 )				
						If aD359[ nPos, 1 ] == nPosD350
							LoadString( 'D359' , aCmps , @cStrTxt , , , , aD359[nPos], , .T. )
							nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	
						
							If nRWStrTxt == -1
								Exit
							Else
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Conta os registros para totalizar no bloco 9³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								TaFContBlc("D359",aTotRegD) 					
							EndIf        
						EndIf
					Next
				EndIf												
			EndIf  	           
		Next		

		/*----------------------------------
		Zerando Arrays para Proximo Registro 
		-----------------------------------*/
		aD350 := {}
		aD359 := {}				 	        					 	        						 	        				
	EndDo
Else
	/*-----------------------------
	Query principal do movimento 
	------------------------------*/ 
	cQuery := " SELECT "
	cQuery += "	 	C6F.C6F_ID, "
	cQuery += "	 	C01.C01_CODIGO, "
	cQuery += "	 	C0W.C0W_ECFMOD, "
	cQuery += "	 	C0W.C0W_ECFFAB, "
	cQuery += "	 	C6G.C6G_DTMOV,  "
	cQuery += "	 	C6G.C6G_PCREOP, "
	cQuery += "	 	C6G.C6G_PCREDZ, "
	cQuery += "	 	C6G.C6G_NRCOPF, "
	cQuery += "	 	C6G.C6G_VLGRTF, "
	cQuery += "	 	C6G.C6G_VLBRU, "
	cQuery += "	 	C1O.C1O_CODIGO,  "   
	cQuery += "	 	C6J.C6J_ID, "
	cQuery += "	 	C6J.C6J_DTMOV, "
	cQuery += "	 	C6J.C6J_CMOD, "
	cQuery += "	 	C6J.C6J_CODSIT, "
	cQuery += "	 	C6J.C6J_NUMDOC, "
	cQuery += "	 	C6J.C6J_DTEMIS,"
	cQuery += "	 	C6J.C6J_IT "
	cQuery += " FROM       "
	cQuery += 		RetSqlName("C6F") + " C6F "
	cQuery += " LEFT JOIN " + RetSqlName("C6G") + " C6G ON ( C6G.C6G_FILIAL = C6F.C6F_FILIAL  AND C6G.C6G_ID = C6F.C6F_ID AND C6G.D_E_L_E_T_ = ' ' ) "
	cQuery += " LEFT JOIN " + RetSqlName("C6I") + " C6I ON ( C6I.C6I_FILIAL = C6F.C6F_FILIAL AND C6I.C6I_ID = C6F.C6F_ID AND C6I.C6I_DTMOV = C6G.C6G_DTMOV AND C6I.D_E_L_E_T_ = '' )"
	cQuery += " LEFT JOIN " + RetSqlName("C6J") + " C6J ON ( C6J.C6J_FILIAL = C6F.C6F_FILIAL AND C6J.C6J_ID = C6F.C6F_ID AND C6J.C6J_DTMOV = C6G.C6G_DTMOV AND C6J.C6J_CMOD = C6I.C6I_CMOD AND C6J.C6J_CODSIT = C6I.C6I_CODSIT AND C6J.C6J_NUMDOC = C6I.C6I_NUMDOC AND C6J.C6J_DTEMIS = C6I.C6I_DTEMIS AND C6J.D_E_L_E_T_ = '')"
	cQuery += " LEFT JOIN " + RetSqlName("C01") + " C01 ON ( C01.C01_FILIAL = '" + xFilial("C01") + "' AND C01.C01_ID = C6I.C6I_CMOD AND C01.D_E_L_E_T_ = '' )"
	cQuery += " LEFT JOIN " + RetSqlName("C0W") + " C0W ON ( C0W.C0W_FILIAL = '" + xFilial("C0W") + "' AND C0W.C0W_ID = C6F.C6F_CODECF AND C0W.D_E_L_E_T_ = '' )"
	cQuery += " LEFT JOIN " + RetSqlName("C1O") + " C1O ON ( C1O.C1O_FILIAL = '" + xFilial("C1O") + "' AND C1O.C1O_ID = C6J.C6J_CCONT AND C1O.D_E_L_E_T_ = '' )"
	cQuery += " WHERE "
	cQuery += "	 	C01.C01_CODIGO = '2E' OR C01.C01_CODIGO = '13' OR C01.C01_CODIGO = '14' OR C01.C01_CODIGO = '15' OR C01.C01_CODIGO = '16' AND"
	cQuery += "	 	C6G.C6G_DTMOV >= '" + DToS( dDataIni ) + "' AND C6G.C6G_DTMOV <= '" + DToS( dDataFim ) + "' AND "
	cQuery += " 	C6F.C6F_FILIAL ='" + xFilial("C6F") + "' AND " 
	cQuery += "		C6F.D_E_L_E_T_ = '' " 
	cQuery += " ORDER BY          "
	cQuery += "	 	C6G.C6G_DTMOV, "
	cQuery += " 	C6F.C6F_ID "
	
	cQuery	:=	ChangeQuery( cQuery )
	dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )
	
	/*-----------------
	While do Documento
	------------------*/
	While (cAliasQry)->( !Eof() )  
	
		/*------------------------------------
		Validacao e geracao do Registro D010
		-------------------------------------*/
		If !lGerD010
			BlcD010PC( cFilCnpj, nHdlTxt )      
			
			lGerD010 := .T.
	    EndIf
	    
		/*-------------------------------
		Chave de Geracao do Registro D350
		--------------------------------*/      
		cChvAux := (cAliasQry)->( C6G_DTMOV )  	
		cChvNF  := ""
		          
	    nVlgRtf := (cAliasQry)->C6G_VLGRTF
	    nVlBru  := (cAliasQry)->C6G_VLBRU	
			        
		/*-----------------
		While da Reducao Z
		------------------*/					
		While (cAliasQry)->( !Eof() )  .And. cChvAux == (cAliasQry)->( C6G_DTMOV )  	
			
			/*------------------------------------------------
			Zerando as Variaveis para inicio do Processamento
			-------------------------------------------------*/			  
			nCstPis    := ""
			nAlqPrdPis := 0
			nAlqQtdPis := 0
					
			nCstCof    := ""
			nAlqPrdCof := 0
			nAlqQtdCof := 0 
	
			nVlrBCPis  := 0
			nQtdBCPis  := 0
			nVlTrbPis  := 0
			
			nVlrBCCof  := 0
			nQtdBCCof  := 0
			nVlTrbCof  := 0		
			
			/*------------------------------------------------
			Buscando Informacoes de PIS do Periodo
			-------------------------------------------------*/			  										
			If C3S->( MsSeek( xFilial("C3S") + "06" ) )
				If C6K->( MsSeek( xFilial("C6K") +  (cAliasQry)->( C6J_ID + C6J_DTMOV + C6J_CMOD + C6J_CODSIT + C6J_NUMDOC + C6J_DTEMIS + C6J_IT + C3S->C3S_ID ) ) )				        
									
				    If C17->( MsSeek( xFilial("C17") + C6K->C6K_CST ) )
						nCstPis  := C17->C17_CODIGO
					EndIf
		
					nAlqPrdPis  := C6K->C6K_ALQPRD
					nAlqQtdPis  := C6K->C6K_ALQQTD 
					
					nVlrBCPis   := C6K->C6K_VLRBC
					nQtdBCPis   := C6K->C6K_QTDBC
					nVlTrbPis   := C6K->C6K_VLRTRB
		
				EndIf                           
			EndIf
		    
			/*------------------------------------------------
			Buscando Informacoes de COFINS do Periodo
			-------------------------------------------------*/			  											
			If C3S->( MsSeek( xFilial("C3S") + "07" ) )
				If C6K->( MsSeek( xFilial("C6K") +  (cAliasQry)->( C6J_ID + C6J_DTMOV + C6J_CMOD + C6J_CODSIT + C6J_NUMDOC + C6J_DTEMIS + C6J_IT + C3S->C3S_ID ) ) )		
				   			           		
				    If C17->( MsSeek( xFilial("C17") + C6K->C6K_CST ) )
						nCstCof  := C17->C17_CODIGO
					EndIf
		
					nAlqPrdCof := C6K->C6K_ALQPRD
					nAlqQtdCof := C6K->C6K_ALQQTD
					
					nVlrBCCof  := C6K->C6K_VLRBC
					nQtdBCCof  := C6K->C6K_QTDBC
					nVlTrbCof  := C6K->C6K_VLRTRB				
		
				EndIf                           
			EndIf		 
	
			/*--------------------------------------------------------
			Apos ter as informacoes de Chave do Registro realizo aScan
			para aglutinar os valores de acordo com a chave do D350
			--------------------------------------------------------*/			  															
			If (cAliasQry)->( nPosD350 := aScan( aD350, { |aX| aX[1] == C01_CODIGO .And. ;
															aX[2]  == C0W_ECFMOD .And. ;
															aX[3] == C0W_ECFFAB .And. ;
															aX[4] == C6G_DTMOV  .And. ;
															aX[5]  == C6G_PCREOP .And. ;
															aX[6] ==  C6G_PCREDZ .And. ;
															aX[7] == C6G_NRCOPF .And. ;
															aX[10] == nCstPis .And.;
															aX[12] == If(nAlqPrdPis > 0,nAlqPrdPis,"") .And. ;
															aX[14] == If(nAlqQtdPis > 0,nAlqQtdPis,"") .And. ;
															aX[16] == nCstCof .And. ;
															aX[18] == If(nAlqPrdCof > 0,nAlqPrdCof,"") .And. ;
															aX[20] == If(nAlqQtdCof > 0,nAlqQtdCof,"") .And. ;
															aX[22] == C1O_CODIGO } ) ) == 0
			
				/*-----------------------------------------
				Alimento Array de Geracao do Registro D350
				------------------------------------------*/							
				(cAliasQry)->( Aadd( aD350, { C01_CODIGO,;
					 	        			   C0W_ECFMOD,;
					 	        			   C0W_ECFFAB,;
					 	        			   C6G_DTMOV,;
					 	        			   C6G_PCREOP,;
					 	        			   C6G_PCREDZ,;
											   C6G_NRCOPF,;
											   nVlgRtf,;		 	        			   	
					 	        			   nVlBru,; 
					 	        			   nCstPis,;
					 	        			   0,;
					 	        			   If(nAlqPrdPis > 0,nAlqPrdPis,""),;
					 	        			   0,;                                
					 	        			   If(nAlqQtdPis > 0,nAlqQtdPis,""),;					 	        			   
					 	        			   0,;
					 	        			   nCstCof,;
					 	        			   0,;
					 	        			   If(nAlqPrdCof > 0,nAlqPrdCof,""),;
					 	        			   0,;
					 	        			   If(nAlqQtdCof > 0,nAlqQtdCof,""),;
					 	        			   0,;
					 	        			   C1O_CODIGO } ) )                   
					 	        					 	        						 	        				
				nPosD350 := Len( aD350 )
		    EndIf    
	        
			/*-----------------------------------------
			Atualizando Valores de PIS
			------------------------------------------*/							  
			aD350[ nPosD350, 11 ] += nVlrBCPis
			If nQtdBCPis > 0
				aD350[ nPosD350, 13 ] += nQtdBCPis
			EndIf
			
			aD350[ nPosD350, 15 ] += nVlTrbPis
	
			/*-----------------------------------------
			Atualizando Valores de COFINS
			------------------------------------------*/							  
			aD350[ nPosD350, 17 ] += nVlrBCCof

            If nQtdBCCof > 0
				aD350[ nPosD350, 19 ] += nQtdBCCof
            EndIf
			aD350[ nPosD350, 21	] += nVlTrbCof
			
			If cChvNF <> (cAliasQry)->C6F_ID
	            
				/*---------------------------------------------
				Atualizo Chave com ECF que esta sendo processada
				----------------------------------------------*/					
				cChvNF := (cAliasQry)->C6F_ID 
				
				/*----------------------------------------------------------
				Gravo array com dados do registro filho D359, gravando
				a identificacao do PAI na primeira posicao para nao se
				perder a referencia no momento da impressao das informacoes
				-----------------------------------------------------------*/								                      
				If C6L->( MsSeek( xFilial("C6L") + cChvNF ) )                                           
	 				While C6L->(!Eof()) .And. C6L->C6L_ID  == cChvNF		
						If C1G->(MsSeek( xFilial("C1G") + C6L->C6L_IDPROC ) )
						    If ( nPos := ( cAliasQry )->( aScan( aD359 , { | aX | aX[ 2 ] == C1G->C1G_NUMPRO .And. aX[ 3 ] == C1G->C1G_INDPRO } ) ) ) == 0 				
					
								Aadd( aD359, {  nPosD350,;
												C1G->C1G_NUMPRO,;
												C1G->C1G_INDPRO } )
					
							EndIf				
						EndIf                   
						C6L->(DbSkip())   			
					EndDo				
				EndIf   												
			EndIf
				      
			(cAliasQry)->(DbSkip())	
		EndDo       
		    
		/*--------------
		Gravacao do D350 
		---------------*/	
		For nPosD350 := 1 To Len( aD350 )                                  
		
			LoadString( 'D350' , aCmps , @cStrTxt , , , , aD350[ nPosD350 ] , , .T. )
			nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )
	
			/*--------------
			Gravacao do D359 
			---------------*/		
			If	nRWStrTxt > 0 
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Conta os registros para totalizar no bloco 9³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TaFContBlc("D350",aTotRegD) 
							
				If Len( aD359 ) > 0				
					For nPos := 1 To Len( aD359 )				
						If aD359[ nPos, 1 ] == nPosD350
							LoadString( 'D359' , aCmps , @cStrTxt , , , , aD359[nPos], , .T. )
							nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	
						
							If nRWStrTxt == -1
								Exit
							Else
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Conta os registros para totalizar no bloco 9³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								TaFContBlc("D359",aTotRegD) 					
							EndIf        
						EndIf
					Next
				EndIf												
			EndIf  
			                    
		Next
		    
		/*----------------------------------
		Zerando Arrays para Proximo Registro 
		-----------------------------------*/
		aD350 := {}
		aD359 := {}	
		
	EndDo
EndIf	         
If nRWStrTxt == -1
	MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
EndIf	

Return ( Nil )    

//-------------------------------------------------------------------
/*/{Protheus.doc} BlcD500PC
Funcao responsavel processar o movimento especifico para montagem dos registros:
D500, D501, D505, D509

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		nHdlTxt		->	Handle do arquivo aberto para gravacao 
		lGerD010    ->  Indica se Foi gerado o Registro D010      
		cFilCnpj    ->  Cnpj para geracao do Registro D010		
		
@return NIL

@author Rodrigo Aguilar
@since 21/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlcD500PC( dDataIni , dDataFim , nHdlTxt, lGerD010, cFilCnpj  )	

Local	cQuery		:=	''         
Local   cCdTrib     :=  ''
Local   cCodCst     :=  ''

Local	cChvNF		:=	''
Local	cChvAux		:=	''   


Local	cStrTxt		:=	''
Local	cStrTxt2	:=	''
Local	cStrTxt3	:=	''

Local 	cAliasQry 	:=  GetNextAlias()
Local	aCmps		:=	DistCmpPC()

Local	nRWStrTxt	:=	0 
Local	nPos    	:=	0              

Local	aD501		:=	{}
Local	aD505		:=	{}

/*-------------------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
--------------------------------------------------------------------*/
C3S->( dbSetOrder( 1 ) )
C2G->( dbSetOrder( 1 ) )   
C35->( dbSetOrder( 1 ) )
C6W->( dbSetOrder( 1 ) )
C17->( dbSetOrder( 3 ) )   
C1G->( dbSetOrder( 3 ) )

/*-----------------------------
Query principal do movimento 
------------------------------*/ 
cQuery	+=	"SELECT "
cQuery	+=	" D100.C20_CHVNF, "
cQuery	+=	" D100.C20_INDOPE, " 
cQuery	+=	" D100.C20_INDEMI, " 
cQuery	+=	" D100.C20_SERIE, "
cQuery	+=	" D100.C20_SUBSER, " 
cQuery	+=	" D100.C20_NUMDOC, " 
cQuery	+=	" D100.C20_DTDOC, "
cQuery	+=	" D100.C20_DTES, "
cQuery	+=	" D100.C20_VLDOC, "
cQuery	+=	" D100.C20_VLDESC, "
cQuery	+=	" D100.C20_VLRDA, " 
cQuery  +=  " D100.C20_VLOUDE,
cQuery	+=	" C01.C01_CODIGO, " 
cQuery	+=	" C02.C02_CODIGO, "
cQuery	+=	" C1H.C1H_FILIAL, "  
cQuery	+=	" C1H.C1H_CODPAR, "   
cQuery  +=  " D101.C30_NUMITE, " 
cQuery  +=  " D101.C30_CODITE, "
cQuery  +=  " D101.C30_TOTAL, "
cQuery  +=  " C11.C11_CODIGO, "
cQuery  +=  " C1O.C1O_CODIGO, "
cQuery	+=	" ( SELECT SUM( TRIB.C35_BASE  ) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL = '" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' '  AND C3S.C3S_CODIGO='02'  AND TRIB.C35_FILIAL = D101.C30_FILIAL AND TRIB.C35_CHVNF = D101.C30_CHVNF AND TRIB.D_E_L_E_T_ = ' ' ) BCICMS, "
cQuery	+=	" ( SELECT SUM( TRIB.C35_VALOR ) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL = '" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='02'  AND TRIB.C35_FILIAL = D101.C30_FILIAL AND TRIB.C35_CHVNF = D101.C30_CHVNF AND TRIB.D_E_L_E_T_= ' '  ) VLICMS, "
cQuery	+=	" ( SELECT SUM( TRIB.C35_VALOR ) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL = '" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='06'  AND TRIB.C35_FILIAL = D101.C30_FILIAL AND TRIB.C35_CHVNF = D101.C30_CHVNF AND TRIB.D_E_L_E_T_= ' '  ) VLPIS, "
cQuery	+=	" ( SELECT SUM( TRIB.C35_VALOR ) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL = '" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='07'  AND TRIB.C35_FILIAL = D101.C30_FILIAL AND TRIB.C35_CHVNF = D101.C30_CHVNF AND TRIB.D_E_L_E_T_= ' '  ) VLCOF "
cQuery	+=	"FROM " + RetSqlName( 'C20' ) + " D100 " 
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C01' ) + " C01  ON( C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=D100.C20_CODMOD AND C01.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C02' ) + " C02  ON( C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID=D100.C20_CODSIT AND C02.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C1H' ) + " C1H  ON( C1H.C1H_FILIAL='" + xFilial('C1H') + "' AND C1H.C1H_ID=D100.C20_CODPAR AND C1H.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C30' ) + " D101 ON( D101.C30_FILIAL = D100.C20_FILIAL AND D101.C30_CHVNF = D100.C20_CHVNF AND D101.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C1O' ) + " C1O  ON( C1O.C1O_FILIAL='" + xFilial('C1O') + "' AND C1O.C1O_ID=D101.C30_CTACTB AND C1O.D_E_L_E_T_ = ' ' ) "
cQuery	+=	" LEFT JOIN " + RetSqlName( 'C11' ) + " C11  ON( C11.C11_FILIAL = '" + xFilial('C11') + "' AND C11.C11_ID = D101.C30_NATBCC AND C11.D_E_L_E_T_ = ' ' ) "
cQuery	+=	"WHERE " 	
cQuery	+=	" D100.C20_FILIAL ='" + xFilial('C20') + "' AND " 
cQuery	+=	" D100.C20_DTES >='" + DToS( dDataIni ) + "' AND " 
cQuery	+=	" D100.C20_DTES <='" + DToS( dDataFim ) + "' AND " 
cQuery	+=	" D100.C20_INDOPE = '0' AND " 
cQuery	+=	" D100.D_E_L_E_T_=' ' AND " 
cQuery	+=	" ( C01.C01_CODIGO='21' OR C01.C01_CODIGO='22' ) "
cQuery	+=	" ORDER BY C20_CHVNF " 

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )

/*-----------------
While do Documento
------------------*/
While (cAliasQry)->( !Eof() )         

	/*------------------------------------
	Validacao e geracao do Registro D010
	-------------------------------------*/
	If !lGerD010
		BlcD010PC( cFilCnpj, nHdlTxt )      
		
		lGerD010 := .T.
    EndIf
    
	cChvNF	:=	( cAliasQry )->C20_CHVNF
	
	aMacro := {}
	aAdd( aMacro, "C21->( msSeek( xFilial( 'C21' ) + '" + cChvNF + "' ) ) .And. C3Q->( msSeek( xFilial( 'C3Q' ) + C21->C21_CODINF ) )" )
	
	/*--------------
	Gravacao do D500 
	---------------*/
	lSeek := C2G->( MsSeek( xFilial( 'C2G' ) + cChvNF ) ) 
	LoadString( 'D500' , aCmps , @cStrTxt , cAliasQry , lSeek , aMacro )
	nRWStrTxt := WrtStrTxt( nHdlTxt , @cStrTxt )
				
	If nRWStrTxt >= 0  	      
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conta os registros para totalizar no bloco 9³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TaFContBlc("D500",aTotRegD) 	

		/*-------------------------
		Laco da Nota Fiscal
		--------------------------*/  			
		While (cAliasQry)->( !Eof() ) .And. cChvNF == (cAliasQry)->C20_CHVNF   
		
			/*-----------------------------------------------------------------------------------------------------------------------------
			Para a geracao dos Registros do Bloco D nao foi usado While na tabela C35 ( Tributos ) pois por definicao Fiscal um 
			item de uma NF NUNCA podera ter duas referencias com o mesmo imposto ( na tabela C35 ), caso isso ocorra o EFD ira considerar 
			a primeira informacao encontrada para a geracao dos registros			
			-------------------------------------------------------------------------------------------------------------------------------*/		

			/*-------------------------
			Busco Codigo do Tributo PIS
			--------------------------*/        
			cCdTrib := ""
			If C3S->( MsSeek( xFilial("C3S") + "06" ) )
		        cCdTrib := C3S->C3S_ID
	        EndIf
	        
			/*--------------------------------------------------
			Busca Informacoes de Tributos de Pis na Tabela C35
			---------------------------------------------------*/        
	        lSeek := C35->( MsSeek( xFilial("C35") + cChvNF + (cAliasQry)->( C30_NUMITE + C30_CODITE + cCdTrib ) ) )
	        
	        If lSeek
		        
		        cCodCst := Iif( C17->( MsSeek( xFilial("C17") + C35->C35_CST ) ), C17->C17_CODIGO, "" )
		        
		        If ( nPos := ( cAliasQry )->( aScan( aD501 , { | aX | aX[ 3 ] == cCodCst .And. aX[ 4 ] == C11_CODIGO .And. aX[ 6 ] == C35->C35_ALIQ } ) ) ) == 0 		
					                					
					Aadd( aD501, { cCodCst,;
			 	                    0,;
						 	        (cAliasQry)->C11_CODIGO,;
						 	        0 ,;
						 	        C35->C35_ALIQ ,;
						 	        0,;
						 	        (cAliasQry)->C1O_CODIGO } )           
					
					nPos := Len( aD501 )
						 	        
				EndIf
				aD501[ nPos, 2 ] +=	(cAliasQry)->C30_TOTAL
				aD501[ nPos, 4 ] += C35->C35_BASE				
				aD501[ nPos, 6 ] += C35->C35_VALOR
			EndIf   
			
			/*-------------------------
			Busco Codigo do Tributo COFINS
			--------------------------*/        
			cCdTrib := ""
			If C3S->( MsSeek( xFilial("C3S") + "07" ) )
		        cCdTrib := C3S->C3S_ID
	        EndIf
	        
			/*--------------------------------------------------
			Busca Informacoes de Tributos de Pis na Tabela C35
			---------------------------------------------------*/        
	        lSeek := C35->( MsSeek( xFilial("C35") + cChvNF + (cAliasQry)->( C30_NUMITE + C30_CODITE + cCdTrib ) ) )
	        
	        If lSeek
		        
		        cCodCst := Iif( C17->( MsSeek( xFilial("C17") + C35->C35_CST ) ), C17->C17_CODIGO, "" )
		        
		        If ( nPos := ( cAliasQry )->( aScan( aD505 , { | aX | aX[ 3 ] == cCodCst .And. aX[ 4 ] == C11_CODIGO .And. aX[ 6 ] == C35->C35_ALIQ } ) ) ) == 0 		
					                					
					Aadd( aD505, { cCodCst,;
			 	                    0,;
						 	        (cAliasQry)->C11_CODIGO,;
						 	        0 ,;
						 	        C35->C35_ALIQ ,;
						 	        0,;
						 	        (cAliasQry)->C1O_CODIGO } )           
					
					nPos := Len( aD505 )
						 	        
				EndIf
				aD505[ nPos, 2 ] +=	(cAliasQry)->C30_TOTAL
				aD505[ nPos, 4 ] += C35->C35_BASE				
				aD505[ nPos, 6 ] += C35->C35_VALOR
			EndIf   
		   
			(cAliasQry)->(DbSkip())                                        					
		EndDo                                                               

		/*------------------------------------------		
		Verifica se Existem Valores a serem gerados		
		-------------------------------------------*/				
		If Len( aD501 ) > 0					
			
			/*--------------
			Gravacao do D501 
			---------------*/		
			LoadString( 'D501' , aCmps , @cStrTxt , cAliasQry , , , aD501 )
			nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )							
			
			If nRWStrTxt == -1
				Exit				
			Else
				/*---------------------------------------------------------------
				Realizo a totalizao dos registros para o Bloco 9 e Registro D990
				----------------------------------------------------------------*/		
				If Len( aTotRegD ) <= 0 .Or. ( nlY := aScan( aTotRegD, { |x| x[1] == "D501" } ) ) <= 0
					Aadd( aTotRegD,  { "D501", 0 }  )
					nlY := Len( aTotRegD )
				EndIf                      	
				aTotRegD[nlY][2] +=  Len( aD501 )			
			EndIf			
			
		EndIf

		/*------------------------------------------		
		Verifica se Existem Valores a serem gerados		
		-------------------------------------------*/				
		If Len( aD505 ) > 0					
		
			/*--------------
			Gravacao do D505 
			---------------*/		
			LoadString( 'D505' , aCmps , @cStrTxt , cAliasQry , , , aD505 )
			nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )							
			
			If nRWStrTxt == -1
				Exit				
			Else
				/*---------------------------------------------------------------
				Realizo a totalizao dos registros para o Bloco 9 e Registro D990
				----------------------------------------------------------------*/		
				If Len( aTotRegD ) <= 0 .Or. ( nlY := aScan( aTotRegD, { |x| x[1] == "D505" } ) ) <= 0
					Aadd( aTotRegD,  { "D505", 0 }  )
					nlY := Len( aTotRegD )
				EndIf                      	
				aTotRegD[nlY][2] +=  Len( aD505 )			
			EndIf			
		
		EndIf				
	EndIf        
	
	If C6W->( MsSeek( xFilial("C6W") + cChvNF ) )                                           
		While C6W->(!Eof()) .And. C6W->C6W_CHVNF  == cChvNF		
			If C1G->(MsSeek( xFilial("C1G") + C6W->C6W_NUMERO ) )
			 			 			 		 					
				//Para os codigos 0 e 2 nao devem ser gerados os registros de processo referenciado
				//no sped contribuicoes
				If AllTrim( C1G->C1G_INDPRO ) $ ("1|3|9")
					/*--------------
					Gravacao do D509 
					---------------*/		
					LoadString( 'D509' , aCmps , @cStrTxt , cAliasQry )
					nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )									
						
					If nRWStrTxt == -1
						Exit				
					Else
						//Conta os registros para totalizar no bloco 9
						TaFContBlc("D509",aTotRegD) 			
					EndIf			                           
				EndIf            									
			EndIf
			
			C6W->(DbSkip())
		EndDo   
		
		If nRWStrTxt == -1
			Exit				
		EndIf			                                       					
	EndIf

	/*------------------------------------------------------
	Zerando Totalizadores para geracao do Proximo Registro
	-------------------------------------------------------*/		
	aD501 := {}                                                    
	aD505 := {}                                                    	
	
EndDo                                                              

If nRWStrTxt == -1
	MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
EndIf

Return ( Nil )      

//-------------------------------------------------------------------
/*/{Protheus.doc} BlcD600PC
Funcao responsavel processar o movimento especifico para montagem dos registros:
D600, D601, D605, D609

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		nHdlTxt		->	Handle do arquivo aberto para gravacao
		lGerD010    ->  Indica se Foi gerado o Registro D010      
		cFilCnpj    ->  Cnpj para geracao do Registro D010		
		
@return NIL

@author Rodrigo Aguilar
@since 22/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlcD600PC( dDataIni , dDataFim , nHdlTxt, lGerD010, cFilCnpj  )		

Local	cQuery		:=	''    
Local   cQueryCons  :=  ''   
Local   cCdTrib     :=  ''
Local   cCodCst     :=  ''  
Local   cCodRec     :=  '' 
Local 	cCodClass 	:=  ''		        

Local	cChvNF		:=	''
Local	cChvAux		:=	''   

Local	cStrTxt		:=	''
Local	cStrTxt2	:=	''
Local	cStrTxt3	:=	''

Local 	cAliasQry 	:=  GetNextAlias()
Local 	cAliasQryC 	:=  GetNextAlias()
Local	aCmps		:=	DistCmpPC()

Local	nRWStrTxt	:=	0 
Local	nPos    	:=	0  
Local   nPosD600    :=  0

Local   lSeekC35    := .F.            

Local	aD600		:=	{}
Local	aD601		:=	{}
Local	aD605		:=	{}
Local	aD609		:=	{}

/*-------------------------------------------------------------------
Definindo ordem das tabelas a serem posicionadas atraves do MSSEEK
--------------------------------------------------------------------*/
C38->( dbSetOrder( 1 ) )  
C2G->( dbSetOrder( 1 ) )   
C10->( dbSetOrder( 3 ) )   
C0K->( dbSetOrder( 4 ) )   
C6W->( dbSetOrder( 1 ) )
C1G->( dbSetOrder( 3 ) )

/*-----------------------------
Query consolidado 
------------------------------*/ 
cQueryCons	:=	"SELECT "
cQueryCons	+=	" C01.C01_CODIGO, "
cQueryCons	+=	" C09.C09_CODIGO, "
cQueryCons	+=	" C07.C07_CODIGO, "
cQueryCons	+=	" D600.C73_SER, "
cQueryCons	+=	" D600.C73_SUB, " 
cQueryCons	+=	" D600.C73_INDREC, "
cQueryCons	+=	" D600.C73_QTCONS, "
cQueryCons	+=	" D600.C73_DTDINI, "
cQueryCons	+=	" D600.C73_DTDFIM, " 
cQueryCons  +=  " D600.C73_VLDOC, "
cQueryCons	+=	" D600.C73_VLDESC, "     
cQueryCons	+=	" D600.C73_VLSERV, "     
cQueryCons	+=	" D600.C73_VSRVNT, "     
cQueryCons  +=  " D600.C73_VLTERC, " 
cQueryCons  +=  " D600.C73_VLDA, "
cQueryCons  +=  " D600.C73_BCICM, "
cQueryCons  +=  " D600.C73_VLICMS, "
cQueryCons  +=  " D600.C73_VLPIS, "
cQueryCons  +=  " D600.C73_VLCOFI, "    
cQueryCons  +=  " C0KP.C0K_CODIGO CCLASSP, "    
cQueryCons  +=  " D601.C74_VLRITE, "    
cQueryCons  +=  " D601.C74_VLDESC, "    
cQueryCons  +=  " C17P.C17_CODIGO CSTPIS, "    
cQueryCons  +=  " D601.C74_BCPIS, "    
cQueryCons  +=  " D601.C74_ALQPIS, "    
cQueryCons  +=  " D601.C74_VLPIS, "    
cQueryCons  +=  " C1OP.C1O_CODIGO CTAPIS, "    
cQueryCons  +=  " C0KC.C0K_CODIGO CCLASSC, "    
cQueryCons  +=  " D605.C75_VLRITE, "    
cQueryCons  +=  " D605.C75_VLDESC, "    
cQueryCons  +=  " C17C.C17_CODIGO CSTCOF, "    
cQueryCons  +=  " D605.C75_BCCOF, "    
cQueryCons  +=  " D605.C75_ALQCOF, "    
cQueryCons  +=  " D605.C75_VLCOF, "    
cQueryCons  +=  " C1OC.C1O_CODIGO CTACOF, "    
cQueryCons  +=  " D609.C76_NUMPRO "    

cQueryCons	+=	"FROM " + RetSqlName( 'C73' ) + " D600 " 
cQueryCons	+=	" LEFT JOIN " + RetSqlName( 'C74' ) + " D601 ON( D601.C74_FILIAL = D600.C73_FILIAL AND D601.C74_ID = D600.C73_ID AND D601.D_E_L_E_T_ = ' ' ) "
cQueryCons	+=	" LEFT JOIN " + RetSqlName( 'C75' ) + " D605 ON( D605.C75_FILIAL = D600.C73_FILIAL AND D605.C75_ID = D600.C73_ID AND D605.D_E_L_E_T_ = ' ' ) "
cQueryCons	+=	" LEFT JOIN " + RetSqlName( 'C76' ) + " D609 ON( D609.C76_FILIAL = D600.C73_FILIAL AND D609.C76_ID = D600.C73_ID AND D609.D_E_L_E_T_ = ' ' ) "
cQueryCons  +=  " LEFT JOIN " + RetSqlName( 'C01' ) + " C01  ON ( C01.C01_FILIAL = '" + xFilial('C01') + "' AND C01.C01_ID = D600.C73_CODMOD AND C01.D_E_L_E_T_ = ' ' ) "

cQueryCons  += " LEFT JOIN " + RetSqlName( 'C1O' ) + " C1OP  ON ( C1OP.C1O_FILIAL = '" + xFilial('C1O') + "' AND C1OP.C1O_ID = D601.C74_CTA AND C1OP.D_E_L_E_T_ = ' ' ) "
cQueryCons  += " LEFT JOIN " + RetSqlName( 'C17' ) + " C17P  ON ( C17P.C17_FILIAL = '" + xFilial("C17") + "' AND C17P.C17_ID = D601.C74_CSTPIS AND C17P.D_E_L_E_T_ = '' ) "
cQueryCons  += " LEFT JOIN " + RetSqlName( 'C0K' ) + " C0KP  ON ( C0KP.C0K_FILIAL = '" + xFilial("C0K") + "' AND C0KP.C0K_ID = D601.C74_CCLASS AND C0KP.D_E_L_E_T_ = '' ) "
cQueryCons  += " LEFT JOIN " + RetSqlName( 'C1O' ) + " C1OC  ON ( C1OC.C1O_FILIAL = '" + xFilial('C1O') + "' AND C1OC.C1O_ID = D605.C75_CTA AND C1OC.D_E_L_E_T_ = ' ' ) "
cQueryCons  += " LEFT JOIN " + RetSqlName( 'C17' ) + " C17C  ON ( C17C.C17_FILIAL = '" + xFilial("C17") + "' AND C17C.C17_ID = D605.C75_CSTCOF AND C17C.D_E_L_E_T_ = '' ) "
cQueryCons  += " LEFT JOIN " + RetSqlName( 'C0K' ) + " C0KC  ON ( C0KC.C0K_FILIAL = '" + xFilial("C0K") + "' AND C0KC.C0K_ID = D605.C75_CCLASS AND C0KC.D_E_L_E_T_ = '' ) "

cQueryCons	+=	" LEFT JOIN " + RetSqlName( 'C07' ) + " C07 ON( C07.C07_FILIAL ='" + xFilial('C09') + "' AND C07.C07_ID = D600.C73_CODMUN AND C07.D_E_L_E_T_= ' ')
cQueryCons	+=	" LEFT JOIN " + RetSqlName( 'C09' ) + " C09 ON( C09.C09_FILIAL ='" + xFilial('C07') + "' AND C09.C09_ID = D600.C73_UF AND C09.D_E_L_E_T_= ' ')

cQueryCons	+=	"WHERE " 	

cQueryCons	+=	" D600.C73_FILIAL ='" + xFilial('C73') + "' AND " 
cQueryCons	+=	" D600.C73_DTMOV >='" + DToS( dDataIni ) + "' AND " 
cQueryCons	+=	" D600.C73_DTMOV <='" + DToS( dDataFim ) + "' AND " 
cQueryCons	+=	" D600.D_E_L_E_T_=' ' AND " 
cQueryCons	+=	" ( C01.C01_CODIGO='21' OR C01.C01_CODIGO='22' ) "
cQueryCons	+=	" ORDER BY "
cQueryCons  +=  "	D600.C73_CODMOD, D600.C73_UF, D600.C73_CODMUN, D600.C73_SER, D600.C73_SUB "

cQueryCons	:=	ChangeQuery( cQueryCons )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQueryCons ) , cAliasQryC )
  
nTotReg := Contar(cAliasQryC,"!Eof()")
DbSelectArea( cAliasQryC )
( cAliasQryC )->( DbGoTop( ) )    

If (nTotReg > 0)
	/*-----------------
	While do Documento
	------------------*/
	While (cAliasQryC)->( !Eof() ) 
	
		/*------------------------------------
		Validacao e geracao do Registro D010
		-------------------------------------*/
		If !lGerD010
			BlcD010PC( cFilCnpj, nHdlTxt )      
			
			lGerD010 := .T.
	    EndIf   
	    
	  	/*-----------------------------------------
		Alimento Array de Geracao do Registro D600
		------------------------------------------*/
		( cAliasQryC )->( aAdd( aD600, {	C01_CODIGO,;
											C09_CODIGO + C07_CODIGO,;
											C73_SER,;
											C73_SUB,;
											C73_INDREC,;
											C73_QTCONS,;
											C73_DTDINI,;
											C73_DTDFIM,;
											C73_VLDOC,;
											C73_VLDESC,; 
											C73_VLSERV,;
											C73_VSRVNT,;
											C73_VLTERC,;
											C73_VLDA,;
											C73_BCICM,;
											C73_VLICMS,;
											C73_VLPIS,;
											C73_VLCOFI } ) )
	          
		nPosD600 := Len( aD600 )   
       
    	/*-----------------------------------------
		Alimento Array de Geracao do Registro D601
		------------------------------------------*/
		
		If !Empty( CCLASSP )
			Aadd( aD601, { nPosD600,;
							CCLASSP,;
	 	                    C74_VLRITE,;    
	 	                    C74_VLDESC,;
	  						CSTPIS,;
				 	        C74_BCPIS,;
				 	        C74_ALQPIS ,;
				 	        C74_VLPIS,;
				 	        CTAPIS } ) 		
       EndIf
       
    	/*-----------------------------------------
		Alimento Array de Geracao do Registro D605
		------------------------------------------*/
		If !Empty( CCLASSC )
			Aadd( aD605, { nPosD600,;
							CCLASSC,;
		 	                C75_VLRITE,;    
		 	                C75_VLDESC,;
		  					CSTCOF,;
				 	        C75_BCCOF,;
				 	        C75_ALQCOF ,;
				 	        C75_VLCOF,;
				 	        CTACOF} )
		EndIf

		/*----------------------------------------------------------
		Gravo array com dados do registro filho D609, gravando
		a identificacao do PAI na primeira posicao para nao se
		perder a referencia no momento da impressao das informacoes
		-----------------------------------------------------------*/								                      
		If C1G->(MsSeek( xFilial("C1G") + ( cAliasQryC )->C76_NUMPRO) )
		    If ( nPos := ( cAliasQryC )->( aScan( aD609 , { | aX | aX[ 2 ] == C1G->C1G_NUMPRO .And. aX[ 3 ] == C1G->C1G_INDPRO } ) ) ) == 0 				
	    	
				//Para os codigos 0 e 2 nao devem ser gerados os registros de processo referenciado
				//no sped contribuicoes
				If AllTrim( C1G->C1G_INDPRO ) $ ("1|3|9")	    	
			    	/*-----------------------------------------
					Alimento Array de Geracao do Registro D609
					------------------------------------------*/			 			
						Aadd( aD609, {  nPosD600,;
										C1G->C1G_NUMPRO,;
										C1G->C1G_INDPRO } )
				EndIf
	
			EndIf				
		EndIf                
						
		(cAliasQryC)->(DbSkip())    

		/*--------------
		Gravacao do D600 
		---------------*/	
		For nPosD600  := 1 To Len( aD600 )                                  
		
			LoadString( 'D600' , aCmps , @cStrTxt , cAliasQryC , lSeek , aMacro, aD600[nPosD600],,.T. )
			nRWStrTxt := WrtStrTxt( nHdlTxt , @cStrTxt )
			
			If	nRWStrTxt > 0  
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Conta os registros para totalizar no bloco 9³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TaFContBlc("D600",aTotRegD) 				
			
				/*------------------------------------------		
				Gravacao do Registro D601
				-------------------------------------------*/				
				If Len( aD601 ) > 0					
					
					For nPos := 1 To Len( aD601 )				
					
						/*--------------
						Gravacao do D601 
						---------------*/		
						LoadString( 'D601' , aCmps , @cStrTxt , , , , aD601[nPos], , .T. )
						nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	
						
						If nRWStrTxt == -1
							Exit				
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Conta os registros para totalizar no bloco 9³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TaFContBlc("D601",aTotRegD) 		
						EndIf						
					Next
				EndIf 
				
				/*------------------------------------------		
				Gravacao do Registro D605
				-------------------------------------------*/				
				If Len( aD605 ) > 0					
					
					For nPos := 1 To Len( aD605 )				
					
						/*--------------
						Gravacao do D605 
						---------------*/		
						LoadString( 'D605' , aCmps , @cStrTxt , , , , aD605[nPos], , .T. )
						nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	
						
						If nRWStrTxt == -1
							Exit				
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Conta os registros para totalizar no bloco 9³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TaFContBlc("D605",aTotRegD) 			
						EndIf						
					Next
				EndIf	
				
				/*------------------------------------------		
				Gravacao do Registro D609
				-------------------------------------------*/				
				If Len( aD609 ) > 0					
					
					For nPos := 1 To Len( aD609 )				
					
						/*--------------
						Gravacao do D609 
						---------------*/		
						LoadString( 'D609' , aCmps , @cStrTxt , , , , aD609[nPos], , .T. )
						nRWStrTxt	:=	WrtStrTxt( nHdlTxt , @cStrTxt )	
						
						If nRWStrTxt == -1
							Exit				
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Conta os registros para totalizar no bloco 9³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TaFContBlc("D609",aTotRegD) 		
						EndIf						
					Next
				EndIf				
					  
									       						
			EndIf  
					                    
		Next
					
		aD600 := {}   
		aD601 := {}                                                 
		aD605 := {}                                                 
		aD609 := {}  		
	EndDo
Else
	/*-----------------------------
	Query principal do movimento 
	------------------------------*/ 
	cQuery	:=	"SELECT "
	cQuery	+=	" D100.C20_CHVNF, "
	cQuery	+=	" D100.C20_SERIE, "
	cQuery	+=	" D100.C20_SUBSER, " 
	cQuery	+=	" D100.C20_DTDOC, "
	cQuery	+=	" D100.C20_VLDOC, "
	cQuery	+=	" D100.C20_VLDESC, "
	cQuery	+=	" D100.C20_VLRDA, " 
	cQuery  +=  " D100.C20_VLOUDE,
	cQuery	+=	" C01.C01_CODIGO, "  
	cQuery  +=  " D101.C30_NUMITE, " 
	cQuery  +=  " D101.C30_CODITE, "
	cQuery  +=  " D101.C30_TOTAL, "
	cQuery  +=  " D101.C30_VLDESC, "
	cQuery  +=  " C1O.C1O_CODIGO, "
	cQuery  +=  " C09.C09_CODIGO, "
	cQuery  +=  " C07.C07_CODIGO, "
	cQuery	+=	" ( SELECT SUM( TRIB.C35_BASE  ) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL = '" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' '  AND C3S.C3S_CODIGO='02'  AND TRIB.C35_FILIAL = D101.C30_FILIAL AND TRIB.C35_CHVNF = D101.C30_CHVNF AND TRIB.C35_NUMITE = D101.C30_NUMITE AND TRIB.C35_CODITE = D101.C30_CODITE AND TRIB.D_E_L_E_T_ = ' ' ) BCICMS, "              
	cQuery	+=	" ( SELECT SUM( TRIB.C35_VALOR ) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL = '" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='02'  AND TRIB.C35_FILIAL = D101.C30_FILIAL AND TRIB.C35_CHVNF = D101.C30_CHVNF AND TRIB.C35_NUMITE = D101.C30_NUMITE AND TRIB.C35_CODITE = D101.C30_CODITE AND TRIB.D_E_L_E_T_= ' '  ) VLICMS, "
	cQuery	+=	" ( SELECT SUM( TRIB.C35_VALOR ) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL = '" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='06'  AND TRIB.C35_FILIAL = D101.C30_FILIAL AND TRIB.C35_CHVNF = D101.C30_CHVNF AND TRIB.C35_NUMITE = D101.C30_NUMITE AND TRIB.C35_CODITE = D101.C30_CODITE AND TRIB.D_E_L_E_T_= ' '  ) VLPIS, "
	cQuery	+=	" ( SELECT SUM( TRIB.C35_VALOR ) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL = '" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='07'  AND TRIB.C35_FILIAL = D101.C30_FILIAL AND TRIB.C35_CHVNF = D101.C30_CHVNF AND TRIB.C35_NUMITE = D101.C30_NUMITE AND TRIB.C35_CODITE = D101.C30_CODITE AND TRIB.D_E_L_E_T_= ' '  ) VLCOF "
	cQuery	+=	"FROM " + RetSqlName( 'C20' ) + " D100 " 
	cQuery	+=	" LEFT JOIN " + RetSqlName( 'C01' ) + " C01  ON( C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=D100.C20_CODMOD AND C01.D_E_L_E_T_ = ' ' ) "
	cQuery	+=	" LEFT JOIN " + RetSqlName( 'C02' ) + " C02  ON( C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID=D100.C20_CODSIT AND C02.D_E_L_E_T_ = ' ' ) "
	cQuery	+=	" LEFT JOIN " + RetSqlName( 'C1O' ) + " C1O  ON( C1O.C1O_FILIAL='" + xFilial('C1O') + "' AND C1O.C1O_ID=D100.C20_CODCTA AND C1O.D_E_L_E_T_ = ' ' ) "
	cQuery	+=	" LEFT JOIN " + RetSqlName( 'C1H' ) + " C1H  ON( C1H.C1H_FILIAL='" + xFilial('C1H') + "' AND C1H.C1H_ID=D100.C20_CODPAR AND C1H.D_E_L_E_T_ = ' ' ) "    
	cQuery	+=	" LEFT JOIN " + RetSqlName( 'C07' ) + " C07 ON( C07.C07_FILIAL ='" + xFilial('C09') + "' AND C07.C07_ID = C1H.C1H_CODMUN AND C07.D_E_L_E_T_= ' ')
	cQuery	+=	" LEFT JOIN " + RetSqlName( 'C09' ) + " C09 ON( C09.C09_FILIAL ='" + xFilial('C07') + "' AND C09.C09_ID = C1H.C1H_UF AND C09.D_E_L_E_T_= ' ')
	cQuery	+=	" LEFT JOIN " + RetSqlName( 'C30' ) + " D101 ON( D101.C30_FILIAL = D100.C20_FILIAL AND D101.C30_CHVNF = D100.C20_CHVNF AND D101.D_E_L_E_T_ = ' ' ) "
	cQuery	+=	"WHERE " 	
	cQuery	+=	" D100.C20_FILIAL ='" + xFilial('C20') + "' AND " 
	cQuery	+=	" D100.C20_DTDOC >='" + DToS( dDataIni ) + "' AND " 
	cQuery	+=	" D100.C20_DTDOC <='" + DToS( dDataFim ) + "' AND " 
	cQuery	+=	" D100.C20_INDOPE = '1' AND " 
	cQuery	+=	" D100.D_E_L_E_T_=' ' AND " 
	cQuery	+=	" ( C01.C01_CODIGO='21' OR C01.C01_CODIGO='22' ) "
	cQuery	+=	" ORDER BY "
	cQuery  +=  "	C01_CODIGO, C09_CODIGO, C07_CODIGO, C20_SERIE, C20_SUBSER, C20_CHVNF "
	
	cQuery	:=	ChangeQuery( cQuery )
	dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry )
	
	/*-----------------
	While do Documento
	------------------*/
	While (cAliasQry)->( !Eof() )  
	
		/*------------------------------------
		Validacao e geracao do Registro D010
		-------------------------------------*/
		If !lGerD010
			BlcD010PC( cFilCnpj, nHdlTxt )      
			
			lGerD010 := .T.
	    EndIf
	    
		cChvAux := ( cAliasQry )->( C01_CODIGO + C09_CODIGO + C07_CODIGO + C20_SERIE + C20_SUBSER )
		
		While (cAliasQry)->( !Eof() ) .And. cChvAux == ( cAliasQry )->( C01_CODIGO + C09_CODIGO + C07_CODIGO + C20_SERIE + C20_SUBSER )
		
			/*----------------------------
			Atualiza Chave da Nota Fiscal 
			-----------------------------*/	 	
			cChvNF	:=	( cAliasQry )->C20_CHVNF        	
			
			cCodRec := ""		
			If ( lSeek :=  C2G->( MsSeek( xFilial( 'C2G' ) + cChvNF ) ) )
				If C10->( MsSeek(xFilial("C10") + C2G->C2G_INDREC ) ) 
					cCodRec := C10->C10_CODIGO
				EndIf
			EndIf 				 	
		    		
			If ( nPosD600 := ( cAliasQry )->( aScan( aD600 , { | aX | aX[ 1 ] == C01_CODIGO .And. aX[ 2 ] == C09_CODIGO+C07_CODIGO .And. ;
			                                                           aX[ 3 ] == C20_SERIE .And. aX[ 4 ] == C20_SUBSER .And. ;
			                                                           aX[ 5 ] == cCodRec } ) ) ) == 0 
				( cAliasQry )->( aAdd( aD600, {	C01_CODIGO,;
													C09_CODIGO + C07_CODIGO,;
													C20_SERIE,;
													C20_SUBSER,;
													cCodRec,;
													0,;
													C20_DTDOC,;
													C20_DTDOC,;
													0,;
													0,;
													0,;
													0,;
													0,;
													0,;
													0,;
													0,;
													0,;
													0 } ) )
					
					nPosD600 := Len( aD600 )
			EndIf                                 
			
			/*------------------------------------------
			Atualizando a Quantidade de NFs no Registro
			-------------------------------------------*/		
			aD600[ nPosD600 , 06 ]	+=	1                    
	
			/*------------------------------------------------
			Atualizando a Data Inicial do Registro Consolidado
			-------------------------------------------------*/				
			If ( cAliasQry )->C20_DTDOC < aD600[ nPosD600 , 07 ]
				aD600[ nPosD600 , 07 ] := ( cAliasQry )->C20_DTDOC
			EndIf
	
			/*------------------------------------------------
			Atualizando a Data Final do Registro Consolidado
			-------------------------------------------------*/				
			If ( cAliasQry )->C20_DTDOC > aD600[ nPosD600 , 08 ]
				aD600[ nPosD600 , 08 ] := ( cAliasQry )->C20_DTDOC
			EndIf 
			
			/*--------------------------------------
			Atualizando Valores do Documento Fiscal
			---------------------------------------*/						
		 	aD600[ nPosD600 , 09 ]	+=	( cAliasQry )->C20_VLDOC
		 	aD600[ nPosD600 , 10 ]	+=	( cAliasQry )->C20_VLDESC
		 	aD600[ nPosD600 , 14 ]	+=	( cAliasQry )->( C20_VLRDA + C20_VLOUDE )    		                                                                        
	        
			/*---------------------------------------------------
			Atualizando os valores de complemeto da Nota Fiscal
			----------------------------------------------------*/						
			If lSeek
			 	aD600[ nPosD600 , 11 ]	+=	C2G->C2G_VLSERV
			 	aD600[ nPosD600 , 12 ]	+=	C2G->C2G_VSERNT
			 	aD600[ nPosD600 , 13 ]	+=	C2G->C2G_VLTERC
			EndIf							 
					   
			/*---------------------------------------------------
			Atualizando os valores dos Itens da Nota Fiscal
			----------------------------------------------------*/																	
			While (cAliasQry)->( !Eof() ) .And. cChvNF	 == ( cAliasQry )->C20_CHVNF        
				
			 	aD600[ nPosD600 , 15 ]	+=	( cAliasQry )->BCICMS
			 	aD600[ nPosD600 , 16 ]	+=	( cAliasQry )->VLICMS
			 	aD600[ nPosD600 , 17 ]	+=	( cAliasQry )->VLPIS
			 	aD600[ nPosD600 , 18 ]	+=	( cAliasQry )->VLCOF		
			 	
				/*-------------------------
				Busco Codigo do Tributo PIS
				--------------------------*/        
				cCdTrib := ""
				If C3S->( MsSeek( xFilial("C3S") + "06" ) )
			        cCdTrib := C3S->C3S_ID
		        EndIf
		        
				/*--------------------------------------------------
				Busca Informacoes de Tributos de Pis na Tabela C35
				---------------------------------------------------*/        
		        lSeekC35 := C35->( MsSeek( xFilial("C35") + cChvNF + (cAliasQry)->( C30_NUMITE + C30_CODITE + cCdTrib ) ) )
		        
		       If lSeekC35
			        
			        cCodCst   := Iif( C17->( MsSeek( xFilial("C17") + C35->C35_CST ) ), C17->C17_CODIGO, "" )
	
					 cCodClass := ""		        
			        If C38->( MsSeek( xFilial("C38") + cChvNF + (cAliasQry)->( C30_NUMITE + C30_CODITE ) ) )
			        	If C0K->(MsSeek( xFilial("C0K") + C38->C38_CCLASS ) ) 
					        cCodClass := C0K->C0K_CODIGO
						EndIf                          
					 EndIf
			        
			        If !Empty( cCodClass )
				        If ( nPos := ( cAliasQry )->( aScan( aD601 , { | aX | aX[ 1 ] == cCodClass .And. aX[ 4 ] == cCodCst .And. ;
				        														aX[ 6 ] == C35->C35_ALIQ .And. x[8] == (cAliasQry)->C1O_CODIGO } ) ) ) == 0 		
							                					
							Aadd( aD601, { nPosD600,;
											cCodClass,;
					 	                    0,;    
					 	                    0,;
		  									cCodCst,;
								 	        0,;
								 	        C35->C35_ALIQ ,;
								 	        0,;
								 	        (cAliasQry)->C1O_CODIGO } )           
							
							nPos := Len( aD601 )
								 	        
						 EndIf
						 aD601[ nPos, 3 ] +=	(cAliasQry)->C30_TOTAL
						 aD601[ nPos, 4 ] += (cAliasQry)->C30_VLDESC
						 aD601[ nPos, 6 ] += C35->C35_BASE
						 aD601[ nPos, 8 ] += C35->C35_VALOR
					 EndIf
				EndIf   		 	
				
				/*-------------------------
				Busco Codigo do Tributo COFINS
				--------------------------*/        
				cCdTrib := ""
				If C3S->( MsSeek( xFilial("C3S") + "07" ) )
			        cCdTrib := C3S->C3S_ID
		        EndIf
		        
				/*--------------------------------------------------
				Busca Informacoes de Tributos de Pis na Tabela C35
				---------------------------------------------------*/        
		        lSeekC35 := C35->( MsSeek( xFilial("C35") + cChvNF + (cAliasQry)->( C30_NUMITE + C30_CODITE + cCdTrib ) ) )
		        
		        If lSeekC35
			        
			       cCodCst   := Iif( C17->( MsSeek( xFilial("C17") + C35->C35_CST ) ), C17->C17_CODIGO, "" )
	
					cCodClass := ""		        
			       If C38->( MsSeek( xFilial("C38") + cChvNF + (cAliasQry)->( C30_NUMITE + C30_CODITE ) ) )
			       	If C0K->(MsSeek( xFilial("C0K") + C38->C38_CCLASS ) ) 
					        cCodClass := C0K->C0K_CODIGO
						EndIf                          
					EndIf
			       
			       If !Empty( cCodClass ) 
				       If ( nPos := ( cAliasQry )->( aScan( aD605 , { | aX | aX[ 1 ] == cCodClass .And. aX[ 4 ] == cCodCst .And. ;
				        														aX[ 6 ] == C35->C35_ALIQ .And. x[8] == (cAliasQry)->C1O_CODIGO } ) ) ) == 0 		
							                					
							Aadd( aD605, { nPosD600,;
											cCodClass,;
					 	                    0,;    
					 	                    0,;
		  									cCodCst,;
								 	        0,;
								 	        C35->C35_ALIQ ,;
								 	        0,;
								 	        (cAliasQry)->C1O_CODIGO } )           
							
							nPos := Len( aD605 )
								 	        
						EndIf
						aD605[ nPos, 3 ] +=	(cAliasQry)->C30_TOTAL
						aD605[ nPos, 4 ] += (cAliasQry)->C30_VLDESC
						aD605[ nPos, 6 ] += C35->C35_BASE
						aD605[ nPos, 8 ] += C35->C35_VALOR
					EndIf
				EndIf   	 
				
				/*-----------------------
				Geracao do Registro D609
				------------------------*/								                      
				If C6W->( MsSeek( xFilial("C6W") + cChvNF ) )                                           
	 				While C6W->(!Eof()) .And. C6W->C6W_CHVNF  == cChvNF		
						If C1G->(MsSeek( xFilial("C1G") + C6W->C6W_NUMERO ) )
						    If ( nPos := ( cAliasQry )->( aScan( aD609 , { | aX | aX[ 2 ] == C1G->C1G_NUMPRO .And. aX[ 3 ] == C1G->C1G_INDPRO } ) ) ) == 0 				
					
								Aadd( aD609, {  nPosD600,;
												C1G->C1G_NUMPRO,;
												C1G->C1G_INDPRO } )
					
							EndIf				
						EndIf                   
						C6W->(DbSkip())   			
					EndDo				
				EndIf   				 	
			 	
	    		(cAliasQry)->(DbSkip())
		    EndDo                        	    
		EndDo
	
	
		/*--------------
		Gravacao do D600 
		---------------*/	
		For nPosD600  := 1 To Len( aD600 )                                  
		
			LoadString( 'D600' , aCmps , @cStrTxt , cAliasQry , lSeek , aMacro, aD600[nPosD600],,.T. )
			nRWStrTxt := WrtStrTxt( nHdlTxt, @cStrTxt )
			
			If	nRWStrTxt > 0  
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Conta os registros para totalizar no bloco 9³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TaFContBlc("D600",aTotRegD) 					
			
				/*------------------------------------------		
				Gravacao do Registro D601
				-------------------------------------------*/				
				If Len( aD601 ) > 0					
					
					For nPos := 1 To Len( aD601 )				
					
						/*--------------
						Gravacao do D601 
						---------------*/		
						LoadString( 'D601' , aCmps , @cStrTxt , , , , aD601[nPos], , .T. )
						nRWStrTxt	:=	WrtStrTxt( nHdlTxt, @cStrTxt )	
						
						If nRWStrTxt == -1
							Exit				
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Conta os registros para totalizar no bloco 9³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TaFContBlc("D601",aTotRegD) 		
						EndIf						
					Next
				EndIf 
				
				/*------------------------------------------		
				Gravacao do Registro D605
				-------------------------------------------*/				
				If Len( aD605 ) > 0					
					
					For nPos := 1 To Len( aD605 )				
					
						/*--------------
						Gravacao do D605 
						---------------*/		
						LoadString( 'D605' , aCmps , @cStrTxt , , , , aD605[nPos], , .T. )
						nRWStrTxt	:=	WrtStrTxt( nHdlTxt, @cStrTxt )	
						
						If nRWStrTxt == -1
							Exit				
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Conta os registros para totalizar no bloco 9³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TaFContBlc("D605",aTotRegD) 			
						EndIf						
					Next
				EndIf	
				
				/*------------------------------------------		
				Gravacao do Registro D609
				-------------------------------------------*/				
				If Len( aD609 ) > 0					
					
					For nPos := 1 To Len( aD609 )				
					
						/*--------------
						Gravacao do D609 
						---------------*/		
						LoadString( 'D609' , aCmps , @cStrTxt , , , , aD609[nPos], , .T. )
						nRWStrTxt	:=	WrtStrTxt( nHdlTxt, @cStrTxt )	
						
						If nRWStrTxt == -1
							Exit				
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Conta os registros para totalizar no bloco 9³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TaFContBlc("D609",aTotRegD) 			
						EndIf						
					Next
				EndIf				
					  
									       						
			EndIf  
					                    
		Next
					
		aD600 := {}   
		aD601 := {}                                                 
		aD605 := {}                                                 
		aD609 := {}                                                 
			
	EndDo                                                              
EndIf
	
If nRWStrTxt == -1
	MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
EndIf

Return ( Nil )     

//-------------------------------------------------------------------
/*/{Protheus.doc} BlcD990PC
Funcao responsavel processar o movimento especifico para montagem dos registros:
D990

@param	nHdlTxt	-> 	Handle para Gravacao
		
@return NIL

@author Rodrigo Aguilar
@since 22/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlcD990PC( nHdlTxt )    

Local cStrTxt := ''

Local nly       := 0  
Local nTotReg   := 0
Local nRWStrTxt := 0

Local aMacro := {}    

Local aCmps	:= DistCmpPC() 

/*----------------------------------------
Acrescenta 1 ao contador do registro D990
------------------------------------------*/	 
If Len( aTotRegD ) <= 0 .Or. ( nlY := aScan( aTotRegD, { |x| x[1] == "D990" } ) ) <= 0
	Aadd( aTotRegD,  { "D990", 0 }  )
	nlY := Len( aTotRegD )
EndIf                      	
aTotRegD[nlY][2] +=  1	  
 
For nlY := 1 To Len( aTotRegD )
	nTotReg += aTotRegD[nlY][2]
Next          
 
/*----------------------------------------------------------
Gravacao do registro D990 no arquivo texto
----------------------------------------------------------*/	

aMacro	:=	{}
aAdd( aMacro , nTotReg )

LoadString( 'D990' , aCmps , @cStrTxt, , , aMacro )
nRWStrTxt := WrtStrTxt( nHdlTxt , @cStrTxt ) 

If nRWStrTxt == -1
	MsgStop( 'Erro na gravação do arquivo texto. Processamento será abortado. (FERROR: ' + AllTrim( Str( FError() ) ) + ')' )
EndIf

Return ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} DistCmpPC
Funcao responsavel por definir um depara do layout do fisco para a tabela do TAF,
	os campos armazenados no array serao utilizados na gravacao como macro execucao

@return aRet - Array com os campos por registros

@author Rodrigo Aguilar
@since 19/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DistCmpPC

Local	aRet	:=	{}  

//ESTRUTURA DO REGISTRO D001
nI	:=	1
aAdd( aRet , { 'D001' , Array( 01 ) } )
aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }

//Estrutura do Registro D010
aAdd( aRet , { 'D010' , Array( 01 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nx, 1 ] }

//Estrutura do Registro D100
aAdd( aRet , { 'D100' , Array( 22 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C20_INDOPE } 
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| C20_INDEMI }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", C1H_CODPAR )}
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| C01_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| C02_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| C20_SERIE  }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| C20_SUBSER }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| C20_NUMDOC }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| C20_CHVELE }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Dt2Caract( C20_DTDOC) )}
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Dt2Caract( C20_DTES ) )}
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", C20_TPCTE )}
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", C20_CHVREF )}
aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( C20_VLDOC , 16 , 2 ) )}
aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( C20_VLDESC , 16 , 2 ) )}
aTail( aRet[ Len( aRet ) ] ) [ 16 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", aMacro[ 1 ] )}
aTail( aRet[ Len( aRet ) ] ) [ 17 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( C20_VLDOC , 16 , 2 ) )}
aTail( aRet[ Len( aRet ) ] ) [ 18 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( BCICMS , 16 , 2 ) )}
aTail( aRet[ Len( aRet ) ] ) [ 19 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( VLICMS , 16 , 2 ) )}
aTail( aRet[ Len( aRet ) ] ) [ 20 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", Val2Str( VLNT , 16 , 2 )) }
aTail( aRet[ Len( aRet ) ] ) [ 21 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", IIF( lSeek , C3Q->( C3Q_CODINF ) , "" )) }
aTail( aRet[ Len( aRet ) ] ) [ 22 ] := {|| Iif( C02_CODIGO $ ("02|03|04|"), "", C1O_CODIGO )}

//Estrutura do Registro D101
aAdd( aRet , { 'D101' , Array( 08 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nx, 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( aRegProc[ nx, 2 ], 16, 2 ) } 
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| aRegProc[ nx, 3 ] } 
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| aRegProc[ nx, 4 ] } 
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ nx, 5 ], 16, 2 ) } 
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ nx, 6 ], 08, 4 ) } 
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( aRegProc[ nx, 7 ], 16, 2 ) } 
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| aRegProc[ nx, 8 ] } 

//Estrutura do Registro D105
aAdd( aRet , { 'D105' , Array( 08 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nx, 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( aRegProc[ nx, 2 ], 16, 2 ) } 
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| aRegProc[ nx, 3 ] } 
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| aRegProc[ nx, 4 ] } 
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ nx, 5 ], 16, 2 ) } 
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ nx, 6 ], 08, 4 ) } 
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( aRegProc[ nx, 7 ], 16, 2 ) } 
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| aRegProc[ nx, 8 ] } 

//Estrutura do Registro D111
aAdd( aRet , { 'D111' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C1G->C1G_NUMPRO }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| C1G->C1G_INDPRO } 

//Estrutura do Registro D200
aAdd( aRet , { 'D200' , Array( 10 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nx, 1 ]  }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ nx, 2 ]  }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| aRegProc[ nx, 3 ]  }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| aRegProc[ nx, 4 ]  }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| aRegProc[ nx, 5 ]  }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| aRegProc[ nx, 6 ]  }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| aRegProc[ nx, 7 ]  }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Dt2Caract( aRegProc[ nx, 8 ] )  }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( aRegProc[ nx, 9 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Val2Str( aRegProc[ nx, 10 ], 16, 2 ) }

//Estrutura do Registro D201
aAdd( aRet , { 'D201' , Array( 06 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nx, 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( aRegProc[ nx, 2 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( aRegProc[ nx, 3 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( aRegProc[ nx, 4 ], 8 , 4 ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ nx, 5 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| aRegProc[ nx, 6 ]  }

//Estrutura do Registro D205
aAdd( aRet , { 'D205' , Array( 06 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nx, 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( aRegProc[ nx, 2 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( aRegProc[ nx, 3 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( aRegProc[ nx, 4 ], 8 , 4 ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ nx, 5 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| aRegProc[ nx, 6 ]  }

//Estrutura do Registro D209
aAdd( aRet , { 'D209' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nx, 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ nx, 2 ] } 

//Estrutura do Registro D300
aAdd( aRet , { 'D300' , Array( 18 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| aRegProc[ 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| aRegProc[ 4 ] }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| aRegProc[ 5 ] }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| aRegProc[ 6 ] }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Dt2Caract( aRegProc[ 7 ] ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( aRegProc[ 8 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( aRegProc[ 9 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| aRegProc[ 10 ] }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Val2Str( aRegProc[ 11 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Val2Str( aRegProc[ 12 ], 08, 4 ) }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Val2Str( aRegProc[ 13 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| aRegProc[ 14 ] }
aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| Val2Str( aRegProc[ 15 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 16 ] := {|| Val2Str( aRegProc[ 16 ], 08, 4 ) }
aTail( aRet[ Len( aRet ) ] ) [ 17 ] := {|| Val2Str( aRegProc[ 17 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 18 ] := {|| aRegProc[ 18 ] }

//Estrutura do Registro D309
aAdd( aRet , { 'D309' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ 3 ] } 

//Estrutura do Registro D350
aAdd( aRet , { 'D350' , Array( 22 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| aRegProc[ 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Dt2Caract( aRegProc[ 4 ] ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ 5 ], 3, 0 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ 6 ], 6, 0 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| aRegProc[ 7 ] }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Val2Str( aRegProc[ 8 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( aRegProc[ 9 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| aRegProc[ 10 ] }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Val2Str( aRegProc[ 11 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Val2Str( aRegProc[ 12 ], 08, 4 ) }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Val2Str( aRegProc[ 13 ], 16, 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| Val2Str( aRegProc[ 14 ], 16, 4 ) }
aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| Val2Str( aRegProc[ 15 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 16 ] := {|| aRegProc[ 16 ] }
aTail( aRet[ Len( aRet ) ] ) [ 17 ] := {|| Val2Str( aRegProc[ 17 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 18 ] := {|| Val2Str( aRegProc[ 18 ], 16, 4 ) }
aTail( aRet[ Len( aRet ) ] ) [ 19 ] := {|| Val2Str( aRegProc[ 19 ], 16, 3 ) }
aTail( aRet[ Len( aRet ) ] ) [ 20 ] := {|| Val2Str( aRegProc[ 20 ], 16, 4 ) }
aTail( aRet[ Len( aRet ) ] ) [ 21 ] := {|| Val2Str( aRegProc[ 21 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 22 ] := {|| aRegProc[ 22 ] }

//Estrutura do Registro D359
aAdd( aRet , { 'D359' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ 3 ] }   

//Estrutura do Registro D500
aAdd( aRet , { 'D500' , Array( 21 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C20_INDOPE }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| C20_INDEMI }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| C1H_CODPAR }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| C01_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| C02_CODIGO }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| C20_SERIE }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| C20_SUBSER }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| C20_NUMDOC }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Dt2Caract( C20_DTDOC ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Dt2Caract( C20_DTES ) }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Val2Str( C20_VLDOC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Val2Str( C20_VLDESC , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Val2Str( Iif( lSeek , C2G->C2G_VLSERV , 0 ) , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| Val2Str( Iif( lSeek , C2G->C2G_VSERNT , 0 ) , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| Val2Str( Iif( lSeek , C2G->C2G_VLTERC , 0 ) , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 16 ] := {|| Val2Str( C20_VLRDA + C20_VLOUDE , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 17 ] := {|| Val2Str( BCICMS , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 18 ] := {|| Val2Str( VLICMS , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 19 ] := {|| Iif( &( aMacro[ 1 ] ) , C3Q->( C3Q_CODINF ) , '' ) }
aTail( aRet[ Len( aRet ) ] ) [ 20 ] := {|| Val2Str( VLPIS , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 21 ] := {|| Val2Str( VLCOF , 16 , 2 ) }

//Estrutura do Registro D501
aAdd( aRet , { 'D501' , Array( 07 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nx, 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( aRegProc[ nx, 2 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| aRegProc[ nx, 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( aRegProc[ nx, 4 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ nx, 5 ], 08, 4 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ nx, 6 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| aRegProc[ nx, 7 ] }

//Estrutura do Registro D505
aAdd( aRet , { 'D505' , Array( 07 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ nx, 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( aRegProc[ nx, 2 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| aRegProc[ nx, 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| Val2Str( aRegProc[ nx, 4 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ nx, 5 ], 08, 4 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ nx, 6 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| aRegProc[ nx, 7 ] }

//Estrutura do Registro D509
aAdd( aRet , { 'D509' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| C1G->C1G_NUMPRO }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| C1G->C1G_INDPRO } 

//Estrutura do Registro D600
aAdd( aRet , { 'D600' , Array( 18 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ 1 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| aRegProc[ 3 ] }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| aRegProc[ 4 ] }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ 5 ] , 01 , 0 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ 6 ] , 16 , 0 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Dt2Caract( aRegProc[ 7 ] ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| Dt2Caract( aRegProc[ 8 ] ) }
aTail( aRet[ Len( aRet ) ] ) [ 09 ] := {|| Val2Str( aRegProc[ 9 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 10 ] := {|| Val2Str( aRegProc[ 10 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 11 ] := {|| Val2Str( aRegProc[ 11 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 12 ] := {|| Val2Str( aRegProc[ 12 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 13 ] := {|| Val2Str( aRegProc[ 13 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 14 ] := {|| Val2Str( aRegProc[ 14 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 15 ] := {|| Val2Str( aRegProc[ 15 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 16 ] := {|| Val2Str( aRegProc[ 16 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 17 ] := {|| Val2Str( aRegProc[ 17 ] , 16 , 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 18 ] := {|| Val2Str( aRegProc[ 18 ] , 16 , 2 ) } 

//Estrutura do Registro D601
aAdd( aRet , { 'D601' , Array( 08 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( aRegProc[ 3 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( aRegProc[ 4 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| aRegProc[ 5 ] }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ 6 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ 7 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( aRegProc[ 8 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| aRegProc[ 9 ] }

//Estrutura do Registro D605
aAdd( aRet , { 'D605' , Array( 08 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| Val2Str( aRegProc[ 3 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 03 ] := {|| Val2Str( aRegProc[ 4 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 04 ] := {|| aRegProc[ 5 ] }
aTail( aRet[ Len( aRet ) ] ) [ 05 ] := {|| Val2Str( aRegProc[ 6 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 06 ] := {|| Val2Str( aRegProc[ 7 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 07 ] := {|| Val2Str( aRegProc[ 8 ], 16, 2 ) }
aTail( aRet[ Len( aRet ) ] ) [ 08 ] := {|| aRegProc[ 9 ] }

//Estrutura do Registro D609
aAdd( aRet , { 'D609' , Array( 02 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| aRegProc[ 2 ] }
aTail( aRet[ Len( aRet ) ] ) [ 02 ] := {|| aRegProc[ 3 ] }   

//Estrutura do Registro D990
aAdd( aRet , { 'D990' , Array( 1 ) } )
aTail( aRet[ Len( aRet ) ] ) [ 01 ] := {|| Val2Str( aMacro[ 1 ], 16, 0 ) }


Return ( aRet )


/*/{Protheus.doc} LoadString
Funcao responsavel por carregar as informacoes em uma string jah no formato de gravacao do arquivo
	de saida baseado no array de depara definido na funcao "DistCmpPC"

@param	cReg	->	Registro a ser gravadao conforme estrutura do array
		aCmps	->  Array com os campos de gravacao conforme registro
		cString -> 	Variavel que receberah a string montada
		cAliasQry-> Alias principal dos campos defnidos no 'aCmps'	
		lSeek	->	Variavel para tratamento interno na MACRO casa haja necessidade de se verificar um SEEK qualquer
		aMacro	->	Array com linhas de macro execucao para ser executado na gravacao dos campos antes do input dos valores
		aRegProc->  Array com as informacoes a serem processada, caso nao esteja em campos direto da tabela. Ex: Registros Consolidados
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadString( cReg , aCmps , cString , cAliasQry , lSeek , aMacro , aRegProc , lFirstPos, lRegUnic )

Local	nlX		:=	0
Local	nX			:=	1
Local	nY			:=	0
Local	cAlias		:=	''
Local	cDelimit	:=	'|'

Default	cString	 :=	''
Default	lSeek	 :=	.T.
Default	aMacro	 :=	{}
Default	aRegProc :=	Nil 
Default lRegUnic := .F. 

If ( nlX := aScan( aCmps , {| aX | aX[ 1 ] == cReg } ) ) > 0
	If ValType( aRegProc ) # 'U'
		If Len( aRegProc ) > 0
			
			If !lRegUnic
				For nX := 1 To Len( aRegProc )
					cString	+=	cDelimit + aCmps[ nlX , 1 ] + cDelimit
					For nY := 1 To Len( aCmps[ nlX , 2 ] )
						
						If Empty( cAliasQry )
							cString	+=	AllTrim( Eval( aCmps[ nlX , 2 , nY ] ) )
						Else
							cString	+=	AllTrim( ( cAliasQry )->( Eval( aCmps[ nlX , 2 , nY ] ) ) )
						EndIf
			
						cString	+=	cDelimit
					Next nY
					cString	+=	CRLF
				Next nX						
			Else
				cString	+=	cDelimit + aCmps[ nlX , 1 ] + cDelimit
				For nY := 1 To Len( aCmps[ nlX , 2 ] )
					
					If Empty( cAliasQry )
						cString	+=	AllTrim( Eval( aCmps[ nlX , 2 , nY ] ) )
					Else
						cString	+=	AllTrim( ( cAliasQry )->( Eval( aCmps[ nlX , 2 , nY ] ) ) )
					EndIf
		
					cString	+=	cDelimit
				Next nY
				cString	+=	CRLF			
			EndIf
		EndIf
	Else
		cString	+=	cDelimit + aCmps[ nlX , 1 ] + cDelimit
		For nX := 1 To Len( aCmps[ nlX , 2 ] )
	
			If Empty( cAliasQry )
				cString	+=	AllTrim( Eval( aCmps[ nlX , 2 , nX ] ) )
			Else
				cString	+=	AllTrim( ( cAliasQry )->( Eval( aCmps[ nlX , 2 , nX ] ) ) )
			EndIf
			
			cString	+=	cDelimit
		Next nX
		cString	+=	CRLF
	EndIf
EndIf

Return ( Nil )
