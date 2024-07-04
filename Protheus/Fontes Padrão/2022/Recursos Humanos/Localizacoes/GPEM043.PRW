#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM043.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o      ³ GPEM043  ³ Autor   ³ Erika Kanamori                  ³ Data ³ 13/08/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o   ³ Calculo de Rescisao Coletiva para o Modelo II              		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe     ³ GPEM043()                                                   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Generico                                                    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ FNC            ³  Motivo da Alteracao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo F.   |08/02/12³ARG11.6-RH 	  ³Requisito 001 - Liq Mensual				      ³±±
±±³Marcelo F.   ³12/03/11³ARG11.6_RH      ³ Atualizacao do processo de rescisao do modelo ³±±
±±³             ³        ³REQ005          ³ II para localizacao Argentina.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function GPEM043() 

Local lSetCentury	:= __SetCentury( "on" )	//altero o estado de SetCentury 

Local cFilMat		:= Space(99)
Local cFilDep		:= Space(99)
Local cFilPosto		:= Space(99)
Local cFilCC		:= Space(99)
Local cFilLocPag	:= Space(99)

//Variaveis para montagem da Dialog  
Local oDlg                                         
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aRetcoords    := {}

Local aArea			:= GetArea()
Local aPages		:= Array( 02 )
Local aFolders		:= Array( 02 )
Local aObjFolder	:= Array( 02 )
Local aButtons		:= {}    

Local bSet15
Local bSet24
Local bDialogInit

Local oProces
Local oFolders
Local oChkHabGrab
Local oRadStatus
Local oChkHabTrace  
Local cConsRes      := "S12ARG"
Local nTamDesc      := 25
Local cTabRes		:= "S012"

Local cTpResDesc	:= Space( 50 )

Private cProces		:= Space( TamSX3( "RCJ_CODIGO" )[1] )
Private cRoteiro 	:= Space( TamSX3( "RY_CALCULO" )[1] )
Private cPeriodo	:= Space( TamSX3( "RCH_PER" )[1] )
Private cNumPag		:= Space( TamSX3( "RCH_NUMPAG" )[1] ) 
Private cProcDesc	:= Space( TamSX3( "RCJ_DESCRI" )[1] )
Private cRotDesc 	:= Space( TamSX3( "RY_DESC" )[1] )
Private lHabGrab	:= .F.  
Private aFilter		:= {}
Private __aFormulas	:= {}
Private oPeriodo	:= RHPERIODO():New()
Private lGrid		:= .F.           
Private lHabTrace	:= .F.

Private nStatus		:= 1
Private dDataIni	:= Ctod("//")
Private dDataFim	:= Ctod("//")
Private cTipoRes	:= Space(2)
Private dDataKey	:= CtoD("//") 
Private dDataDem	:= CtoD("//")
Private dDataHom	:= CtoD("//")
Private dDataGer	:= CtoD("//")

Private lColetiva	:= .T. //indica q eh ferias coletivas no calculo (Gpem022Processa)


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao verifica se existe alguma restrição de acesso para o³
//³usuário que impeça a execução da rotina.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !(fValidFun({"SQB","SRJ","RCO",;
				"CTT","RGC","RCE","SR6","SR3",;
				"SR7","SRC","RGB","SRV","SRK",;
				"RCP","RG7"}))
	RestArea(aArea)
	Return
Endif
      
If cPaisLoc == "ARG"
	cConsRes := "S12ARG" 
	cTabRes	 := "S012"
    nTamDesc := 25
ElseIf cPaisLoc == "DOM"
	cConsRes := "S10DOM"
	cTabRes	 := "S010"
    nTamDesc := 30
ElseIf cPaisLoc == "COS"
	cConsRes := "S22COS"
	cTabRes	 := "S022"
    nTamDesc := 40
Endif    	

Begin Sequence

	aAdd(aButtons, {'RELATORIO', {|| TelaLog()}, OemToAnsi(STR0001), OemToAnsi(STR0002)}) //"Consulta Logs de Calculo"##"Logs"

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define o Conteudo do aPages								   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aPages[ 01 ] := OemToAnsi( "&" + STR0003 )	//"Gerais"
	aPages[ 02 ] := OemToAnsi( "&" + STR0004 )	//"Faixas"

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define o Conteudo do aFolders								   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aFolders[ 01 ] := OemToAnsi( "&" + STR0003 ) //"Gerais"
	aFolders[ 02 ] := OemToAnsi( "&" + STR0004 ) //"Faixas"
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define os Elementos para o Array do Objeto Folder        	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aObjFolder[ 01 ]	:= Array( 01 , 04 )
	aObjFolder[ 02 ]	:= Array( 02 , 04 )
	
	// Em GRID havera uma Barra de processamento da LIB //
	bSet15			:= { || fGeraFilter( aFilter, cFilMat, cFilDep, cFilPosto, cFilCC, cFilLocPag), If( VldCalculo(), CalResCol(), .F. )} 
	bSet24			:= { || oDlg:End() }

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define o Bloco para a Inicializacao do Dialog            	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	bDialogInit		:= { ||;
								CursorWait()													,;
								oProces:SetFocus()												,;
								EnchoiceBar( oDlg , bSet15 , bSet24, NIL , aButtons )			,;
								CursorArrow()												 	 ;
					   }
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
	Define MsDialog oDlg Title OemToAnsi(STR0005) From aAdvSize[7],000 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL //"Rescisao Coletiva"

		oDlg:lEscClose := .F. // Nao permite sair ao se pressionar a tecla ESC.
		
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega o Objeto Folder               					   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		oFolders := TFolder():New(	aObjSize[1,1]			,;
									aObjSize[1,2]			,;
									aFolders				,;
									aPages					,;
									oDlg					,;
									NIL						,;
									NIL						,;
									NIL						,;
									.T.						,;
									.F.						,;
									aObjSize[1,4]			,;
									aObjSize[1,3]			 ;
								 )

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Dados do folder - Gerais 											       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
       
		aRetcoords := RetCoords(4,11,55,15,2,40,,oFolders:OWND:NTOP)
		       
		//
		@aRetcoords[1][1]	,aRetcoords[1][2] SAY   STR0006 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Processo: "
	  	@aRetcoords[2][1]	,aRetcoords[2][2] MSGET oProces VAR cProces   SIZE 040,007	OF oFolders:aDialogs[ 01 ] PIXEL /*WHEN GpemValDis(lDisable) */PICTURE ;
									   							   PesqPict("RCJ","RCJ_CODIGO") F3 "RCJ" VALID;
																    ( If( Empty(cProces),;
													    			  	(cProcDesc := "", lRet := .T.),;
															    	  	If( lRet := ExistCpo("RCJ", cProces),;
															    			  cProcDesc := Posicione("RCJ",1,xFilial("RCJ")+cProces, "RCJ_DESCRI"),;
																    		  "")),;
																    lRet := VldPeriodo(),;
																    lRet ) HASBUTTON  
																    
																    
		@aRetcoords[3][1]	,aRetcoords[3][2] SAY   STR0007 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Descricao: "																    
	  	@aRetcoords[4][1]	,aRetcoords[4][2] MSGET cProcDesc SIZE 140,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.

		
		@aRetcoords[5][1]	,aRetcoords[5][2] SAY   STR0008 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Tipo Folha: "
		@aRetcoords[6][1]	,aRetcoords[6][2] MSGET cRoteiro  SIZE 040,007	OF oFolders:aDialogs[ 01 ] PIXEL /*WHEN GpemValDis(lDisable) */PICTURE ;
																	PesqPict("SRY","RY_CALCULO") F3 "SRY" VALID;
																    ( If( Empty(cRoteiro),;
													    			  	(cRotDesc := "", lRet := .T.),;
															    	  	If( lRet := ExistCpo("SRY", cRoteiro),;
															    			  cRotDesc := Posicione("SRY",1,xFilial("SRY")+cRoteiro, "RY_DESC"),;
																    		  "")),;
																    lRet := VldPeriodo(),;
																    lRet ) HASBUTTON  
																    
	  	@aRetcoords[7][1]  ,aRetcoords[7][2] SAY   STR0007 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Descricao: "																    
		@aRetcoords[8][1]  ,aRetcoords[8][2] MSGET cRotDesc SIZE 140,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.
          
		
		@aRetcoords[9][1]	,aRetcoords[9][2] SAY   STR0009 SIZE 033,007   OF oFolders:aDialogs[ 01 ] PIXEL	//"Periodo: "
		@aRetcoords[10][1]	,aRetcoords[10][2] MSGET cPeriodo SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.


		@aRetcoords[11][1]	,aRetcoords[11][2] SAY   STR0010 SIZE 038,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Nro Pagto: "
		@aRetcoords[12][1]	,aRetcoords[12][2] MSGET cNumPag SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.

		@aRetcoords[13][1]	,aRetcoords[13][2] SAY   STR0011 SIZE 038,007  OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Inicio: "
		@aRetcoords[14][1]	,aRetcoords[14][2] MSGET dDataIni SIZE 050,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F. HASBUTTON
		
		@aRetcoords[15][1]	,aRetcoords[15][2] SAY   STR0012 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Fim: "
		@aRetcoords[16][1]	,aRetcoords[16][2] MSGET dDataFim SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F. HASBUTTON

													
		@aRetcoords[17][1]	,aRetcoords[17][2] SAY   STR0013 SIZE 040,007  OF oFolders:aDialogs[ 01 ] PIXEL	//"Tipo Rescisao: "
		@aRetcoords[18][1]	,aRetcoords[18][2] MSGET cTipoRes SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL F3 cConsRes VALID ;
																	(Iif( Empty(cTipoRes),cTpResDesc := "", ( cTpResDesc:= fDescRCC(cTabRes,SRG->RG_TIPORES,1,2,3,nTamDesc), lRet := .T.))) HASBUTTON
		@aRetcoords[19][1]	,aRetcoords[19][2] SAY   STR0007 SIZE 033,007    OF oFolders:aDialogs[ 01 ] PIXEL	//"Descrição: "
		@aRetcoords[20][1]	,aRetcoords[20][2] MSGET cTpResDesc SIZE 140,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F. //PICTURE 
		
		@aRetcoords[21][1]	,aRetcoords[21][2] SAY   STR0014 SIZE 040,007  OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Rescisao: "
		@aRetcoords[22][1]	,aRetcoords[22][2] MSGET dDataDem SIZE 050,007 OF oFolders:aDialogs[ 01 ] PIXEL HASBUTTON /*WHEN .F. HASBUTTON ;
												VALID (fDataferM2( dDataKey, nDuracao, "dDtFimFer"))                    */
												
		@aRetcoords[23][1]	,aRetcoords[23][2] SAY   STR0015 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Pgto: "
		@aRetcoords[24][1]	,aRetcoords[24][2] MSGET dDataKey SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL /*WHEN .T. */HASBUTTON
		
		@aRetcoords[25][1]	,aRetcoords[25][2] SAY   STR0016 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Geração: "
		@aRetcoords[26][1]	,aRetcoords[26][2] MSGET dDataGer SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL /*WHEN .T. */HASBUTTON
		
		@aRetcoords[27][1]	,aRetcoords[27][2] SAY   STR0017 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Homolog: "
		@aRetcoords[28][1]	,aRetcoords[28][2] MSGET dDataHom SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL /*WHEN .T. */HASBUTTON
		
		@aRetcoords[29][1]	,aRetcoords[29][2]  SAY   STR0018 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Status: "
        
		oRadStatus			:= TRadMenu():New( aRetcoords[30][1]	,aRetcoords[30][2] , {STR0019,STR0020,STR0021} , NIL , oFolders:aDialogs[ 01 ] , NIL , NIL , NIL , NIL , NIL , NIL , NIL , 115 , 010 , NIL , NIL , NIL , .T. ) //"Ativos"##"Inativos"##"Ambos"
		oRadStatus:bSetGet	:= { |nItem| IF( nItem <> NIL , nStatus := nItem , nStatus ) }
		//If lDisable // Nao permitir alteracao
			oRadStatus:SetDisable()
		//EndIf
				
		@aRetcoords[31][1]	,aRetcoords[31][2] CHECKBOX oChkHabGrab  VAR lHabGrab PROMPT OemToAnsi(STR0022) SIZE 100,08 OF oFolders:aDialogs[ 01 ] PIXEL //"Habilitar Gravacao"
		@aRetcoords[35][1]	,aRetcoords[35][2] CHECKBOX oChkHabTrace VAR lHabTrace PROMPT OemToAnsi( STR0029 ) SIZE 100,08 OF oFolders:aDialogs[ 01 ] PIXEL //"Habilitar TRACE"
		
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Dados do folder - Filtros 										       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

		@aRetcoords[1][1]	,aRetcoords[1][2] SAY   STR0023 SIZE 045,007 OF oFolders:aDialogs[ 02 ] PIXEL	//"Funcionarios: "
		@aRetcoords[2][1]	,aRetcoords[2][2] MSGET cFilMat   SIZE 200,007 OF oFolders:aDialogs[ 02 ] PIXEL /*WHEN GpemValDis(lDisable)*/ F3 "SRA" HASBUTTON

		@aRetcoords[5][1]	,aRetcoords[5][2] SAY   STR0024 SIZE 045,007 OF oFolders:aDialogs[ 02 ] PIXEL	//"Departamentos: "
		@aRetcoords[6][1]	,aRetcoords[6][2] MSGET cFilDep   SIZE 200,007 OF oFolders:aDialogs[ 02 ] PIXEL /*WHEN /*GpemValDis(lDisable)*/ F3 "SQB" HASBUTTON

		@aRetcoords[9][1]	,aRetcoords[9][2] SAY   STR0025 SIZE 045,007 OF oFolders:aDialogs[ 02 ] PIXEL	//"Centro de Custos: "
		@aRetcoords[10][1]	,aRetcoords[10][2] MSGET cFilCC   SIZE 200,007 OF oFolders:aDialogs[ 02 ] PIXEL /*WHEN /*GpemValDis(lDisable)*/ F3 "CTT" HASBUTTON 

		@aRetcoords[13][1]	,aRetcoords[13][2] SAY   STR0026 SIZE 045,007 OF oFolders:aDialogs[ 02 ] PIXEL	//"Local de Pagamento: "
		@aRetcoords[14][1]	,aRetcoords[14][2] MSGET cFilLocPag SIZE 200,007 OF oFolders:aDialogs[ 02 ] PIXEL /*WHEN /*GpemValDis(lDisable)*/ F3 "S015" HASBUTTON
		
		If ( FunName() == "GPEM040" )
			If ExistBlock( "GPM040CAL" )	
				ExecBlock("GPM040CAL")
			EndIf
		EndIf
				
	ACTIVATE DIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED
                                              	
End Sequence

IF !( lSetCentury )
	__SetCentury( "off" )
EndIF

lColetiva:= .F.

Return Nil
   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CalResCol   ³ Autor ³ Erika Kanamori        ³ Data ³ 28/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Aciona o calculo de rescisao coletiva                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CalResCol()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Static Function CalResCol()
Local lRet:= .T. 

Proc2BarGauge({|lEnd| Gpem022Processa()},,,, .T. , .T. , .F. , .F. )

Return(lRet)
   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fValResCol  ³ Autor ³ Erika Kanamori        ³ Data ³ 15/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se pode calcular rescisao coletiva para o funcionario. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fValResCol()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fValResCol()                        

Local lRet		:= .T.

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Verifica se jah nao tem rescisao calculada no periodo selecionado.	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
dbSelectArea("SRG")
dbSetOrder(RetOrder("SRG", "RG_FILIAL+RG_MAT"))
If (SRG->(dbSeek(xFilial("SRG") + SRA->RA_MAT))) 
	aAdd(aNCalcCol, {SRA->RA_MAT, SRA->RA_NOME} )
	lRet:= .F.
Endif  

//verifica se o funcionario tem periodo aquisitivo? 
//CargaFerias(@aPerFerias, dDataKey)
 //verifica se o funcionario esta afastado?
 
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fCriaCabRes ³ Autor ³ Erika Kanamori        ³ Data ³ 15/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria cabecalho de rescisao									³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fCriaCabRes()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fCriaCabRes()

Local nAux		:= 0
Local nDFerVen	:= 0                     
Local nDFerAVe	:= 0 
Local nDFerPag	:= 0
Local aPerFerias:= {}

CargaFerias(@aPerFerias, dDataKey)

If !(len(aPerFerias) < 1) 
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega dias de ferias vencidas e proporcionais e desconta dias pagos.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/        
   	Aeval(aPerFerias,{|x| (nDFerVen += x[5], nDFerAVe += x[4], nDFerPag += x[7])})

	If nDFerVen > nDFerPag
		nDFerVen:= nDFerVen - nDFerPag
	Else
		nDFerVen:= 0
		nDFerPag:= nDFerPag - nDFerVen
		nDFerAVe:= Max(nDFerAVe - nDFerPag, 0)
	Endif 
Endif
		
dbSelectArea("SRG")
RecLock( "SRG" , .T. )
	RG_FILIAL	:= SRA->RA_FILIAL
	RG_MAT		:= SRA->RA_MAT	  
	RG_TIPORES	:= cTipoRes
	RG_DATADEM	:= dDataDem	
	RG_DATAHOM	:= dDataHom
	RG_DTGERAR	:= dDataGer	
	RG_DTPAGO   := dDataKey
	RG_DFERVEN	:= nDFerVen
	RG_DFERPRO	:= nDFerAVe
	RG_PROCES	:= SRA->RA_PROCES   
	RG_ROTEIR	:= cRoteiro
	RG_PERIODO	:= cPeriodo
	RG_SEMANA	:= cNumPag
	RG_EFETIVA	:= "2"
	//RG_SALMES
SRG->(MsUnlock())

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef     ³ Autor ³ Erika Kanamori        ³ Data ³ 13/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Menu Funcional                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MenuDef()                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/ 
Static Function MenuDef()
                                                                               	
	Local aRotina := {} 
	Local cRotSal := 'GPEM043()' 
	If cPaisLoc == "MEX"
		cRotSal := 'GPEM040B()' 
	EndIf
	ADD OPTION aRotina Title OemToAnsi(STR0027) Action cRotSal OPERATION 6 ACCESS 0  // "Rescisão Coletiva"
	ADD OPTION aRotina Title OemToAnsi(STR0028)	Action 'GPER140()' OPERATION 7 ACCESS 0  // "Impressao"
	
Return aRotina
    


