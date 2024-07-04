#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM039CHI.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER039CHI ³ Autor ³ Mayra Camargo            ³ Data ³ 05.10.14   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cálculo de Reliquidación de Chile                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Mayra Camargo ³15/10/15³PCREQ-7944 ³Generación fuente v12.                    ³±±
±±³MCamargo      ³08/09/16³           ³Merge v12.1.13                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function GPEM039CHI()

Local lSetCentury	:= __SetCentury( "on" )	//altero o estado de SetCentury 

Local cFilMat		:= Space(99)
Local cFilDep		:= Space(99)
Local cFilPosto	:= Space(99)
Local cFilCC		:= Space(99)
Local cFilLocPag	:= Space(99)

//Variaveis para montagem da Dialog  
Local oDlg                                         
Local aAdvSize2		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObjCoords2	:= {}
Local aRetcoords		:= {}  

Local aArea		:= GetArea()
Local aPages		:= Array( 02 )
Local aFolders	:= Array( 02 )
Local aObjFolder	:= Array( 02 )
Local aButtons	:= {}    

Local bSet15
Local bSet24
Local bDialogInit

Local oProces
Local oFolders
Local oChkHabGrab
Local oChkHabTrace
Local oRadStatus

Private cProces	:= Space( TamSX3( "RCJ_CODIGO" )[1] )
Private cRoteiro	:= Space( TamSX3( "RY_CALCULO" )[1] )
Private cPeriodo	:= Space( TamSX3( "RCH_PER" )[1] )
Private cNumPag	:= Space( TamSX3( "RCH_NUMPAG" )[1] ) 
Private cProcDesc	:= Space( TamSX3( "RCJ_DESCRI" )[1] )
Private cRotDesc 	:= Space( TamSX3( "RY_DESC" )[1] )
Private lHabGrab	:= .F.  
Private lHabTrace	:= .F.  
Private aFilter	:= {}
Private __aFormulas:= {}
Private oPeriodo	:= RHPERIODO():New()
Private lGrid		:= .F.           

Private nStatus	:= 1
Private dDataIni	:= Ctod("//")
Private dDataFim	:= Ctod("//")
Private nDuracao	:= Space(6)
Private dDataKey	:= CtoD("//") 
Private dDtFimFer	:= CtoD("//") 
Private dDtPagFer	:= CtoD("//")
Private lGpem039Chi	:= .T.

Private lColetiva	:= .T. //indica q eh ferias coletivas no calculo (Gpem022Processa)
Private lColetInd	:= .F. /*indica q eh ferias coletivas no calculo (Gpem022Processa)
						     mas obedece informacoes da programacao individual do funcionario */	
//Variaveis de controle - QTD Minima para calculo com GRID (MV_MINGRID)
Private nRecRCHAux	:= 0
Private nTotCalFunc:= 0
Private nTotCalReg	:= 1
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

Begin Sequence

	aAdd(aButtons, {'RELATORIO', {|| TelaLog()}, OemToAnsi(STR0001) , OemToAnsi(STR0002)}) //"Consulta Logs de Calculo"##"Logs"

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
	bSet15			:= { || nRecRCHAux := fPosRCHTes(), fGeraFilter( aFilter, cFilMat, cFilDep, cFilPosto, cFilCC, cFilLocPag), If( VldCalculo(), gpem039Proc(), .F. )} 
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
	aAdvSize2		:= MsAdvSize()
	aInfo2AdvSize	:= { aAdvSize2[1] , aAdvSize2[2] , aAdvSize2[3] , aAdvSize2[4] , 5 , 5 }
	aAdd( aObjCoords2 , { 000 , 000 , .T. , .T. } )
	aObj2Size		:= MsObjSize( aInfo2AdvSize , aObjCoords2 )
	
	Define MsDialog oDlg Title OemToAnsi(STR0005) From aAdvSize2[7],000 TO aAdvSize2[6],aAdvSize2[5] OF oMainWnd PIXEL //"Ferias Coletivas"

		oDlg:lEscClose := .F. // Nao permite sair ao se pressionar a tecla ESC.
		
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega o Objeto Folder               					   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		oFolders := TFolder():New(	aObj2Size[1,1]			,;
									aObj2Size[1,2]			,;
									aFolders				,;
									aPages					,;
									oDlg					,;
									NIL						,;
									NIL						,;
									NIL						,;
									.T.						,;
									.F.						,;
									aObj2Size[1,4]			,;
									aObj2Size[1,3]			 ;
								 )

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Dados do folder - Gerais 											       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
       
		aRetcoords := RetCoords(4,9,55,15,2,40,,oFolders:OWND:NTOP)
		       
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

		
		@aRetcoords[5][1]	,aRetcoords[5][2] SAY   OemToAnsi(STR0008) SIZE 060,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Tipo Procedimiento: "
		@aRetcoords[6][1]	,aRetcoords[6][2] MSGET cRoteiro  SIZE 040,007	OF oFolders:aDialogs[ 01 ] PIXEL /*WHEN GpemValDis(lDisable) */PICTURE ;
																	PesqPict("SRY","RY_CALCULO") F3 "SRYNOM" VALID;
																    ( If( Empty(cRoteiro),;
													    			  	(cRotDesc := "", lRet := .T.),;
															    	  	If( lRet := ExistCpo("SRY", cRoteiro),;
															    			  cRotDesc := Posicione("SRY",1,xFilial("SRY")+cRoteiro, "RY_DESC"),;
																    		  "")),;
																    lRet := VldPeriodo(),;
																    lRet ) HASBUTTON 
		
																    
	  	@aRetcoords[7][1]  ,aRetcoords[7][2] SAY   STR0007 SIZE 033,007   OF oFolders:aDialogs[ 01 ] PIXEL	//"Descricao: "																    
		@aRetcoords[8][1]  ,aRetcoords[8][2] MSGET cRotDesc SIZE 140,007  OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.
          
		
		@aRetcoords[9][1]	,aRetcoords[9][2] 	SAY   STR0009 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Periodo: "
		@aRetcoords[10][1]	,aRetcoords[10][2] MSGET cPeriodo SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.


		@aRetcoords[11][1]	,aRetcoords[11][2] SAY   STR0010 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Nro Pagto: "
		@aRetcoords[12][1]	,aRetcoords[12][2] MSGET cNumPag SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.

		@aRetcoords[13][1]	,aRetcoords[13][2] SAY   STR0011 SIZE 040,007  OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Inicio: "
		@aRetcoords[14][1]	,aRetcoords[14][2] MSGET dDataIni SIZE 050,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F. HASBUTTON
		
		@aRetcoords[15][1]	,aRetcoords[15][2] SAY   OemToAnsi(STR0012) SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Fim: "
		@aRetcoords[16][1]	,aRetcoords[16][2] MSGET dDataFim SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F. HASBUTTON
		
		@aRetcoords[25][1]	,aRetcoords[25][2]  SAY  STR0013 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Status: "
        
		oRadStatus			:= TRadMenu():New( aRetcoords[26][1]	,aRetcoords[26][2] , {STR0014,STR0015,STR0016} , NIL , oFolders:aDialogs[ 01 ] , NIL , NIL , NIL , NIL , NIL , NIL , NIL , 115 , 010 , NIL , NIL , NIL , .T. ) //"Ativos"##"Inativos"##"Ambos"
		oRadStatus:bSetGet	:= { |nItem| IF( nItem <> NIL , nStatus := nItem , nStatus ) }
		oRadStatus:SetDisable()
				
		@aRetcoords[27][1]	,aRetcoords[27][2] CHECKBOX oChkHabGrab VAR lHabGrab PROMPT OemToAnsi(STR0017) SIZE 100,08 OF oFolders:aDialogs[ 01 ] PIXEL //"Habilitar Gravacao"
		@aRetcoords[31][1]	,aRetcoords[31][2] CHECKBOX oChkHabTrace VAR lHabTrace PROMPT OemToAnsi(STR0022) SIZE 100,08 OF oFolders:aDialogs[ 01 ] PIXEL //"Habilitar TRACE"
		oChkHabGrab:SetDisable() 

		
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Dados do folder - Filtros 										       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

		@aRetcoords[1][1]	,aRetcoords[1][2] SAY   STR0018 SIZE 045,007   OF oFolders:aDialogs[ 02 ] PIXEL	//"Funcionarios: "
		@aRetcoords[2][1]	,aRetcoords[2][2] MSGET cFilMat   SIZE 200,007 OF oFolders:aDialogs[ 02 ] PIXEL /*WHEN GpemValDis(lDisable)*/ F3 "SRA" HASBUTTON

		@aRetcoords[5][1]	,aRetcoords[5][2] SAY   STR0019 SIZE 045,007   OF oFolders:aDialogs[ 02 ] PIXEL	//"Departamentos: "
		@aRetcoords[6][1]	,aRetcoords[6][2] MSGET cFilDep   SIZE 200,007 OF oFolders:aDialogs[ 02 ] PIXEL /*WHEN /*GpemValDis(lDisable)*/ F3 "SQB" HASBUTTON

		@aRetcoords[9][1]	,aRetcoords[9][2] 	SAY   STR0020 SIZE 045,007 OF oFolders:aDialogs[ 02 ] PIXEL	//"Centro de Custos: "
		@aRetcoords[10][1]	,aRetcoords[10][2] MSGET cFilCC   SIZE 200,007 OF oFolders:aDialogs[ 02 ] PIXEL /*WHEN /*GpemValDis(lDisable)*/ F3 "CTT" HASBUTTON 

		
		@aRetcoords[13][1]	,aRetcoords[13][2] SAY   STR0021 SIZE 045,007    OF oFolders:aDialogs[ 02 ] PIXEL	//"Local de Pagamento: "
		@aRetcoords[14][1]	,aRetcoords[14][2] MSGET cFilLocPag SIZE 200,007 OF oFolders:aDialogs[ 02 ] PIXEL /*WHEN /*GpemValDis(lDisable)*/ F3 "S015" HASBUTTON

				
	ACTIVATE DIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED
                                              	
End Sequence

IF !( lSetCentury )
	__SetCentury( "off" )
EndIF

Return Nil
   
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³gpem039Proc ³ Autor ³ Mayra Camargo         ³ Data ³08/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Detona el cálculo para cada periodo hijo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER039CHI                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   
   
Static Function gpem039Proc()
	
	Local aPeriodos 	:= {}
	Local nI := 0
	Local cPerAux := cPeriodo
	Local cNPAux  := cNumPag
	Local cRotAux	 := cRoteiro 
	Local nRet	 := 0
	Local cRotRel	:= ""
	
	cRotRel := getRotReliq()	
	
	aPeriodos := getPerchild()

	If len(aPeriodos) > 0
		// Prorrateo de incidencias
	
		Proc2BarGauge({|lEnd| GenRGB(cPerAux,cNPAux,aPeriodos,cRotRel)},,,, .T. , .T. , .F. , .F. )			
		
		// Cálculo de los periodos hijos
		For ni:= 1 to len(aPeriodos)
			cPeriodo := aPeriodos[nI,1]		
			cRoteiro := cRotRel	
			Proc2BarGauge({|lEnd| nRet:= Gpem022Processa()},,,, .T. , .T. , .F. , .F. )	
			
			If nRet < 0
				MsgAlert(STR0025 + STR0024 + cPeriodo) // "Proceso interrumpido.""Error al calcular el periodo " 
				cPeriodo := cPerAux
				cRoterio := cRotAux
				Exit
			EndIf		
		Next
		
		// Cáculo periodo padre.
		cPeriodo := cPerAux		
		cRoteiro := cRotAux
		
		//Si no hubo error alguno en los cálculos de los periodos hijos realizar el siguiente proceso.						
		If !(nRet < 0)						
			// Generación RGB periodo padre.
			Proc2BarGauge({|lEnd| GeneraRGB(cPerAux,aPeriodos,cRotRel)},,,, .T. , .T. , .F. , .F. )			
						
			// Cálculo Periodo Padre			
			Proc2BarGauge({|lEnd| nRet:=Gpem022Processa()},,,, .T. , .T. , .F. , .F. )
			If nRet < 0
				MsgAlert(STR0025 + STR0024 + cPeriodo) // "Proceso interrumpido.""Error al calcular el periodo " 
			Else
				MsgAlert(STR0023)				//"Proceso terminado con exito"
			EndIf	
			
		End If	
	Else	
		MsgAlert(STR0027) // "Periodos hijos no encontrados. Verifique."		
	EndIf 
			
Return   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ getPerchild³ Autor ³ Jesus Peñaloza        ³ Data ³08/09/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Obtiene los periodos hijo del calculo de reliquidacion       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEm039CHI                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function getPerchild()

	Local aArea	:= getArea()
	Local aPeriodo:= {}
	Local cQuery	:= ''
	Local cTempF	:= CriaTrab(Nil, .F.)
	Local cRotRel	:= ""
	
	cRotRel := getRotReliq()
	
	cQuery += "SELECT RCH_PER, RCH_MES, RCH_ANO  " 
	cQuery += "FROM "+RetSQLName("RCH")+" "
	cQuery += "WHERE RCH_FILIAL = '"+xFilial("RCH")+"' "
	cQuery += "AND RCH_PROCES = '"+cProces+"' "
	cQuery += "AND RCH_ROTEIR = '"+cRotRel+"' "
	cQuery += "AND RCH_NUMPAG = '"+cNumPag+"' "
	cQuery += "AND RCH_PER <> '"+cPeriodo+"' "
	cQuery += "AND RCH_PERREL = '"+cPeriodo+"' "
	cQuery += "AND D_E_L_E_T_ = '' "
	cQuery += "ORDER BY RCH_PER ASC "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempF,.T.,.T.)
	
	(cTempF)->(dbGoTop())
	While (!(cTempF)->(EOF()))
		aAdd(aPeriodo, {(cTempF)->RCH_PER, (cTempF)->RCH_MES, (cTempF)->RCH_ANO})
		(cTempF)->(dbSkip())
	EndDo
	
	RestArea(aArea)
	
Return aPeriodo

//Obtiene ry calculo donde ry_calculo=T
Static Function getRotReliq()

	Local aArea 	:= getArea()
	Local cRet  	:= "" 
	Local cQuery	:= ''
	Local cTempF	:= CriaTrab(Nil, .F.)
	
	cQuery += "SELECT RY_CALCULO "
	cQuery += "FROM "+RetSQLName("SRY")+" "
	cQuery += "WHERE RY_FILIAL = '"+xFilial("SRY")+"' "
	cQuery += "AND RY_TIPO = 'T' "
	cQuery += "AND D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempF,.T.,.T.)
	
	(cTempF)->(dbGoTop())
	While (!(cTempF)->(EOF()))
		cRet := (cTempF)-> RY_CALCULO
		(cTempF)->(dbSkip())
	EndDo
	
	RestArea(aArea)
	
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GenRGB    ºAutor  ³Mayra Camargo       º Data ³  08/09/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Genera los registros en la RGB para los periodos hijos      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ MkNewSRFCol(cFilSRA,cMat,cPdSRF,dDateIni                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cPer        = Periodo                                      º±±
±±º          ³ cNP         = Número de Pago                      	  	  º±±
±±º          ³ aPErHijos   = Array con periodos hijos                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM039CHI()                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GenRGB(cPer,cNP,aPerHijos,cRotRel)
	Local aArea		:= getArea()
	Local cFields	:= ""
	Local cAliasRGB	:= GetNextAlias()
	Local cFilRGB	:= xFilial( "RGB", xFilial("SRA")) 
	Local cFilSRV	:= xFilial( "SRV", xFilial("SRA")) 
	Local cFilSRA	:= xFilial("SRA")
	Local cFiltro	:= "% '1' %"
	Local nValor	:= 0
	Local nI		:= 0
	Local cTimeIni	:= Time()
	Local nTotReg		:= 0
	Local nX			:= 0
	Local cExp		:= ""
	Local nPerReliq	:= 0 //Número de periodos a reliquidar
	Local lReliq		:= .T.
	Local nPos		:= 0
	Local cPerAdm		:= ""
	Local dPerAdm		:= CTOD(" / / ")
	Local dPerIni		:= CTOD(" / / ")
	Local dPerFim		:= CTOD(" / / ")
	
	MakeStrExp(@aFilter)

	cExp := "("
	For nX := 1 To Len(aFilter)
		If !Empty(aFilter[nX,3])
			If len(cExp) > 1
				cExp += " and "
			EndIf
		    cExp += aFilter[nX,3]
		EndIf		
	Next nX
	cExp += ")"
	cFields:= "RGB.* "
	
	If cExp <> "()"
		cExp := "% and " +cExp+"%"
	Else
		cExp := "%%"
	EndIF
	
	// Obtiene los registros de la RGB para el proceso, periodo, número de pago del padre.
	
	BeginSql alias cAliasRGB
		SELECT RGB.*, SRA.RA_PERADM,SRA.RA_PAGADM //%exp:cFields%
		FROM %Table:SRA% SRA	 INNER JOIN %Table:RGB% RGB ON SRA.RA_MAT=RGB_MAT 
								 INNER JOIN %Table:SRV% SRV ON RGB.RGB_PD=SRV.RV_COD
		WHERE RGB.RGB_FILIAL= %exp:cFilRGB%
		  AND SRA.RA_FILIAL= %exp:cFilSRA%
		  AND SRV.RV_FILIAL= %exp:cFilSRV%
		  AND RGB.RGB_PROCES= %exp:cProces%		  
		  AND RGB.RGB_ROTEIR= %exp:cRoteiro%
		  AND RGB.RGB_PERIOD= %exp:cPer%
		  AND RGB.RGB_SEMANA= %exp:cNP%
		  AND SRV.RV_RELIQ= %exp:cFiltro% 
		  AND SRA.RA_SITFOLH <> 'D' %exp:cExp%
		  AND RGB.%notDel%  
		  AND SRV.%notDel%		
		  AND SRA.%notDel% 
		ORDER BY RGB.RGB_MAT,RGB.RGB_PD
	EndSql
	
	Count to nTotReg
	(cAliasRGB)->(dbGoTop())			
	While (cAliasRGB)->(!Eof())
		
		//Calcular el número de periodos a reliquidar comparando la fecha de ingreso con el inicio y fin de los periodos hijos
		cPerAdm := (cAliasRGB)-> RA_PERADM
		dPerAdm := STOD(cPerAdm+"01") 
		dPerIni := STOD(aPerhijos[1,1]+"01")
		dPerFim := STOD(aPerhijos[len(aPerhijos),1]+"01")
		
		
		If  dPerIni >= dPerAdm
			nPos := 1
			nPerReliq := len(aPerhijos)
			lReliq := .T.
		Else
			If dPerAdm > dPerFim // Si el periodo de admisión es mayor al periodo mayor hijo, entonces no reliquida
				lReliq := .F.
			Else
				nPos:= aScan(aPerHijos, { |x,y| x[1] == cPerAdm	} )	
				nPerReliq := iif(len(aPerHijos)<>nPos, len(aPerHijos)-nPos,1) 
				lReliq := .T.		
			EndIf
		EndIF
		
		If lReliq
			For nI := nPos to len(aPerHijos)
				IncPrcG1Time(STR0026 + aPerHijos[nI,1] , nTotReg , cTimeIni , .T. , 1 , 1 , .T. ) //"GENERANDO REGISTROS EN RGB PARA PERIODO ->"
				dbSelectArea("RGB")
				RGB->(dbSetOrder(5)) // RGB_FILIAL+RGB_PROCES+RGB_PERIOD+RGB_SEMANA+RGB_ROTEIR+RGB_MAT+RGB_PD+RGB_SEQ       
				//Si ya existe un registro lo borramos
				If (RGB->(dbSeek(xFilial("RGB",xfilial("SRA"))+ cProces + aPerHijos[nI,1] + cNP + cRotRel + (cAliasRGB)-> RGB_MAT + (cAliasRGB)-> RGB_PD  )))
					IF  (RGB->RGB_TIPO2  == 'X')
						RecLock("RGB",.F.)
							RGB->(dbDelete())
						RGB->(msUnlock())
					EndIf		
				EndIF 
				nValor := (cAliasRGB)-> RGB_VALOR/nPerReliq
				//Generamos el registro
				RecLock("RGB",.T.)
					RGB->RGB_FILIAL	:= XFILIAL("RGB",XFILIAL("SRA"))
					RGB->RGB_PROCES	:= cProces
					RGB->RGB_PERIOD	:= aPerHijos[nI,1]
					RGB->RGB_SEMANA	:= cNP
					RGB->RGB_ROTEIR	:= cRotRel//cRoteiro
					RGB->RGB_MAT	:= (cAliasRGB)-> RGB_MAT
					RGB->RGB_PD		:= (cAliasRGB)-> RGB_PD
					RGB->RGB_HORAS	:= (cAliasRGB)-> RGB_HORAS
					RGB->RGB_VALOR	:= nValor		
					RGB->RGB_TIPO2  := 'X'				
				RGB->(msUnlock())		
					
			Next
		EndIF				
		(cAliasRGB)->(DbSkip())
					
	EndDo
	
	(cAliasRGB)->( DbCloseArea() )	
	RestArea(aArea)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeneraRGB ºAutor  ³Mayra Camargo       º Data ³  08/09/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Generar en la RGB a partir de los cálculos de los hijos     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ GeneraRGB(cFilSRA,cMat,cPdSRF,dDateIni                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cPerPAdre   = Periodo PAdre                                º±±
±±º          ³                       	  	                              º±±
±±º          ³ aPerHijos   = Array con periodos hijos                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM039CHI()                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeneraRGB(cPerPadre,aPerHijos,cRotRel)
	
	Local aArea		:= getArea()
	Local cFields	:= ""
	Local cAliasSRC	:= getNextAlias()
	Local cFilSRC	:= xFilial( "SRC", xFilial("SRA"))
	Local cFilSRV	:= xFilial( "SRV", xFilial("SRA")) 
	Local cFilSRA	:= xFilial("SRA") 
	Local nI		:= 0
	Local cTimeIni	:= Time()
	Local nTotReg	:= 0
	Local cExpPer	:= ""
	Local nX		:= 0
	Local cExp		:= 0
	Local nProHrs	:= 0
	Local cRelq		:= "% '1' %"
	Local cEmpl		:= ""
	
	DEFAULT aPerHijos := {}
	Default cPerPadre := ""
	Default cRotRel   := ""
	
	MakeStrExp(@aFilter)

	cExp := "("
	For nX := 1 To Len(aFilter)
		If !Empty(aFilter[nX,3])
			If len(cExp) > 1
				cExp += " and "
			EndIf
		    cExp += aFilter[nX,3]
		EndIf		
	Next nX
	cExp += ")"
	
	If cExp <> "()"
		cExp := "% and " +cExp+"%"
	Else
		cExp := "%%"
	EndIF
	
	
	cFields	:= "RGB.* "
	cExpPer	:= "% "
	
	If len(aPerHijos) > 0
		cExpPer+= "("
		
		For ni:=1 to len(aPerHijos)
			cExpPer += "'" + aPerHijos[nI,1] + "'"
		
			If nI < len(aPerHijos)
				cExpPer += ","
			Else 
				cExpPer+= ")%"
			End If
		Next
			
	End IF
	
	// Obtiene los registros de la RGB para el proceso, periodo, número de pago del padre.	
	BeginSql alias cAliasSRC
		SELECT  	SRA.RA_MAT,SRA.RA_CC,SRA.RA_CODFUNC,SRA.RA_POSTO,SRA.RA_DEPTO,SRA.RA_ITEM,SRA.RA_CLVL,SRC.RC_FILIAL,
					SRC.RC_PD,SRC.RC_ENTIDAD,SUM(SRC.RC_VALOR)AS RC_VALOR,SUM(RC_HORAS) AS RC_HORAS  //%exp:cFields%
		FROM %Table:SRA% SRA INNER JOIN %Table:SRC% SRC ON SRA.RA_MAT=SRC.RC_MAT
		INNER JOIN %Table:SRV% SRV ON SRV.RV_COD=SRC.RC_PD
		WHERE SRC.RC_FILIAL= %exp:cFilSRC%
		  AND SRA.RA_FILIAL= %exp:cFilSRA%
		  AND SRV.RV_FILIAL= %exp:cFilSRV%
		  AND SRC.RC_PROCES= %exp:cProces%		  
		  AND SRC.RC_ROTEIR= %exp:cRotRel%
		  AND SRC.RC_PERIODO IN %exp:cExpPer%
		  AND SRC.RC_SEMANA= %exp:cNumPag% 
		  AND SRV.RV_RELIQ <> %exp:cRelq% 
		  AND SRC.%notDel%
		  AND SRV.%notDel% 
		  AND SRA.%notDel% %exp:cExp%
		GROUP BY SRA.RA_MAT, SRA.RA_CC, SRA.RA_CODFUNC, SRA.RA_DEPTO, SRA.RA_ITEM,SRA.RA_POSTO,SRA.RA_DEPTO,SRA.RA_ITEM,SRA.RA_CLVL,SRC.RC_FILIAL,SRC.RC_PD,SRC.RC_ENTIDAD		
		ORDER BY  SRC.RC_FILIAL,SRA.RA_MAT, SRC.RC_PD 
	EndSql
	
	Count to nTotReg
	(cAliasSRC)->(dbGoTop())		
	While (cAliasSRC)->(!Eof())
		IncPrcG1Time(STR0026 + cPerPadre, nTotReg , cTimeIni , .T. , 1 , 1 , .T. ) //"GENERANDO REGISTROS EN RGB PARA PERIODO ->"
		//borramos todos los registros de RGB 
		If cEmpl <>  (cAliasSRC)->RA_MAT //Entrar una sola vez para el empleado y borrar todas sus incidencias marcadas con X
			DelRGB(xFilial("RGB"),cProces , cPerPadre , cNumPag , cRoteiro , (cAliasSRC)->RA_MAT)
			cEmpl :=  (cAliasSRC)->RA_MAT
		EndIf
		nProHrs := (cAliasSRC)-> RC_HORAS / nTotReg
		// Insertar registro nuevo en RGB para el periodo padre.
		RecLock("RGB",.T.)
			RGB->RGB_FILIAL	:= (cAliasSRC)-> RC_FILIAL
			RGB->RGB_PROCES	:= cProces
			RGB->RGB_PERIOD	:= cPerPadre
			RGB->RGB_SEMANA	:= cNumPag
			RGB->RGB_ROTEIR	:= cRoteiro
			RGB->RGB_MAT	:= (cAliasSRC)-> RA_MAT
			RGB->RGB_PD		:= (cAliasSRC)-> RC_PD
			RGB->RGB_TIPO1	:= 'V'
			RGB->RGB_QTDSEM	:= 0
			RGB->RGB_HORAS	:= nProHrs
			RGB->RGB_VALOR	:= (cAliasSRC)-> RC_VALOR
			RGB->RGB_DTREF	:= dDataFim
			RGB->RGB_CC		:= (cAliasSRC)-> RA_CC
			RGB->RGB_PARCEL	:= 0
			RGB->RGB_CODFUN	:= (cAliasSRC)-> RA_CODFUNC
			RGB->RGB_POSTO	:= (cAliasSRC)-> RA_POSTO
			RGB->RGB_DEPTO	:= (cAliasSRC)-> RA_DEPTO
			RGB->RGB_DUM	:= 0
			RGB->RGB_DDOIS	:= 0
			RGB->RGB_DTRES	:= 0
			RGB->RGB_DQUATR	:= 0
			RGB->RGB_DCINCO	:= 0
			RGB->RGB_DSEIS	:= 0
			RGB->RGB_DSETE	:= 0
			RGB->RGB_ENTIDA	:= (cAliasSRC)-> RC_ENTIDAD 									     
			RGB->RGB_ITEM	:= (cAliasSRC)-> RA_ITEM
			RGB->RGB_CLVL	:= (cAliasSRC)-> RA_CLVL
			RGB->RGB_TIPO2  := 'X'								
		RGB->(msUnlock())		
		(cAliasSRC)->(dbSkip())
	EndDo
	
	(cAliasSRC)->(dbCloseArea())
	RestArea(aArea)
Return



/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	³Posiciona o RCH³ Autor ³Igor Franzoi	    ³Data³07/05/2010³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Posiciona o RCH depois dos parametros escolhidos			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³GPEM022														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³nRecno - Recno do RCH selecionado							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ 															³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fPosRCHTes()

Local nRecno := 0
Local cAlias := "RCH"

	DbSelectArea( cAlias )	// Cadastro de Periodos
	(cAlias)->( DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" ) ) )
	(cAlias)->( DbSeek( xFilial("RCH") + cProces + cPeriodo + cNumPag + cRoteiro, .F. ) )
	nRecno := (cAlias)->(Recno())

Return nRecno

/*/

*/
/*/{Protheus.doc}DELRGB
Elimina registro de RGB
@type function
@author mayra.camargo
@since 17/03/2020
@version 1.0
@param cFilRGB, character, (Filial RGB)
@param cProc, character, (Proceso)
@param cPer, character, (Periodo)
@param cPag, character, (Número de Pago)
@param cRot, character, (Tipo de Nómina)
@param cMat, character, (Matrícula del empleado)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DelRGB(cFilRGB,cProc,cPer,cPag,cRot,cMat)

	Local aArea 	:= getArea()
	Local cAliasRGB	:= getNextAlias()
	
	Default cFilRGB := xFilial("RGB")
	Default cProc   := ""
	Default cPer	:= ""
	Default cPag	:= ""
	Default cRot 	:= ""
	Default	cMat	:= ""
	 
	BeginSql alias cAliasRGB
		SELECT RGB.R_E_C_N_O_ AS NUM
		FROM %Table:RGB% RGB	 
		WHERE RGB.RGB_FILIAL= %exp:cFilRGB%
		  AND RGB.RGB_PROCES= %exp:cProc%		  
		  AND RGB.RGB_ROTEIR= %exp:cRot%
		  AND RGB.RGB_PERIOD= %exp:cPer%
		  AND RGB.RGB_SEMANA= %exp:cPag%
		  AND RGB.RGB_MAT= %exp:cMat% 
		  AND RGB.RGB_TIPO2= 'X'
		  AND RGB.%notDel%  
	EndSql
	
	dbSelectArea("RGB")
	(cAliasRGB)->(dbGoTop())			
	While (cAliasRGB)->(!Eof())
		If (cAliasRGB)->NUM > 0
		    RGB->(DBGOTO((cAliasRGB)->NUM))
			If (RGB->(!Eof()))
				If ( RGB->RGB_TIPO2  == 'X')	
					RecLock("RGB",.F.)
						RGB->(dbDelete())
					RGB->(msUnlock())	
				EndIF	
			EndIF 
		EndIf
		(cAliasRGB)->(DbSkip())					
	EndDo
	(cAliasRGB)->(DbCloseArea() )	
	RestArea(aArea) 
Return