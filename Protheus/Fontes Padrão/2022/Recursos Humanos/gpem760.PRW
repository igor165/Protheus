#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM760.CH"
#INCLUDE "SCOPECNT.CH"

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³GPEM760   ³ Autor ³Mauricio Takakura             ³ Data ³28/06/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Transferencia e Cancelamento de Calculo   	              	       ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³GPEM760()                             	                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Mexico.                            	                      	       ³
ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Programador ³ Data   ³ Chamado/FNC ³  Motivo da Alteracao                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ 
³Raquel Hager³22/07/14³TPZMHB       ³ Inclusao de fonte na pasta da versao 12. ³
³            ³        ³             ³que ao ser selecionado a opcao 2 e o aCols³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/ 
Function Gpem760()
Local cTitulo 	 	:= OemToAnsi(STR0001)	//"Transferencia/Cancelamento de Calculos"
Local nLin		 	:= 0
Local nCol       	:= 0
Local aListTipos	:= {}
Local aListAcao     := {}
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
	
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}	
Local aObj1Coords 	:= {}
	
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}	
Local aObj2Coords 	:= {}
	
Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}	
Local aObj3Coords 	:= {}
Local aObjSize
Local bSet15
Local bSet24
Local bDialogInit
Local oDlg
Local oFont
Local oPanel
Local oTipo    
Local oAcao          
Local oGrpPerDe
Local oParaGrpPer
Local oGrpFun
Local oGrpVerbas
Local oProcDe
Local oPerDe
Local oDeNumPagto
Local oDeRoteiro
Local oPerPara
Local oParaNumPagto
Local oParaRoteiro             
Local oFilial
Local oFunc

Private oProcPara
Private oGet
Private oCheckBox
Private cProcesso 	:= Space( TamSX3( "RCJ_CODIGO" )[1] )
Private cPeriodo    := Space( TamSX3( "RCH_PER"    )[1] )
Private cRoteiro    := Space( TamSX3( "RCH_ROTEIR" )[1] )
Private cNumPagto   := ""
Private cTipo   	:= " " 
Private cAcao       := " "
Private lInvertSinal:= .T.
Private cProcDe		:= cProcesso
Private cProcPara	:= cProcesso
Private cProcDDe 	:= ""
Private cProcDPara 	:= ""
Private cPerDe 		:= cPeriodo
Private cPerPara 	:= cPeriodo
Private cDeNumPgto	:= Space( TamSX3( "RCH_NUMPAG" )[1] )
Private cParaNumPgto:= Space( TamSX3( "RCH_NUMPAG" )[1] )
Private cDeRoteiro	:= Space( TamSX3( "RCH_ROTEIR" )[1] )
Private cParaRoteiro:= Space( TamSX3( "RCH_ROTEIR" )[1] )
Private cFilFiltro 	:= Space(99)
Private cFunFiltro 	:= Space(99)
Private aHeader     := {}
Private aCols       := {}
Private nUsado      := 0
Private Inclui      := .F.

//Variáveis utilizadas na consulta padrao do campo verba (de e para) da getdados
Private cRoteiroAnt  := ""
Private cPeriodoAnt  := ""
Private cProcessoAnt := ""
Private cNumPagAnt   := ""
Private cCodRoteiro	 := ""
Private cCodPeriodo  := ""
Private cCodProcesso := ""
Private cNumPagamento:= ""
Private aIndexSRV    := {}

_SetOwnerPrvt( "nOpcNewGd", GD_INSERT + GD_UPDATE + GD_DELETE)

	Begin Sequence
	 	
	 	aAdd( aListTipos, "1=" + OemToAnsi(STR0003) ) 	// 1=Cancelamento de Recibos
	 	aAdd( aListTipos, "2=" + OemToAnsi(STR0004) )	// 2=Transferencia Movimento
	
	 	aAdd( aListAcao, "1=" + OemToAnsi(STR0035) ) 	// "Gerar novo movimento"
	 	aAdd( aListAcao, "2=" + OemToAnsi(STR0036) )	// "Substituir movimento qdo chave existente"
	 	aAdd( aListAcao, "3=" + OemToAnsi(STR0037) )	// "Não gerar movimento qdo chave existente"
	
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Monta as Dimensoes dos Objetos - Possui mais itens atualiza- ³
		³ dos na funcao Gpe290Window                                   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		aAdvSize		:= MsAdvSize()	
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 2 }
		aAdd( aObjCoords , { 000 , 028 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 063 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aAdd( aObjCoords , { 000 , 003 , .T. , .F. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
				
		aAdv1Size    := aClone(aObjSize[1])	
		aInfo1AdvSize    := { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 3 }
		aAdd( aObj1Coords , { 080 , 000 , .T. , .T. } )
		aAdd( aObj1Coords , { 020 , 000 , .T. , .T. } )
		aObj1Size := MsObjSize( aInfo1AdvSize , aObj1Coords, , .T. )
				
		aAdv2Size    := aClone(aObjSize[2])	
		aInfo2AdvSize    := { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 1 , 2 }
		aAdd( aObj2Coords , { 050 , 000 , .T. , .T. } )
		aAdd( aObj2Coords , { 002 , 000 , .F. , .T. } )
		aAdd( aObj2Coords , { 050 , 000 , .T. , .T. } )
		aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords, , .T. )
				
		aAdv3Size    := aClone(aObjSize[4])	
		aInfo3AdvSize    := { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 5 , 5 }
		aAdd( aObj3Coords , { 000 , 000 , .T. , .T.} )
		aObj3Size := MsObjSize( aInfo3AdvSize , aObj3Coords, , .T.)
		
		bSet15			:= { || If( gpm760VldCpos()			,;
									Proc2BarGauge({|lEnd| gpm760Processa()},,,, .T. , .T. , .F. , .F. ),;
									.F.						 ;
								   )						 ;
							} 
		bSet24			:= { || oDlg:End() }
	
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define o Bloco a ser Executado na Inicializacao do Dialog    ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		bDialogInit	:= { || EnchoiceBar( oDlg , bSet15 , bSet24 ) }
		
		DEFINE FONT oFont NAME "Arial" SIZE 000 , -011 BOLD
		DEFINE MSDIALOG oDlg TITLE cTitulo From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5]  OF oMainWnd PIXEL
	
			oPanel:=tPanel():New(0,0,"",oDlg,,,,,,__DlgWidth(oDlg),__DlgWidth(oDlg))
	
			nLin := 5
			nCol := 3
	
			@ aObj1Size[1,1]+5, aObj1Size[1,2] 	SAY OemToAnsi( STR0002 ) SIZE 080,10 OF oPanel PIXEL	//"Tipo de Operacao" 
			@ aObj1Size[1,1]+5, aObj1Size[1,2]+55 	MsComboBox oTipo Var cTipo ITEMS aListTipos SIZE 140,10 OF oPanel PIXEL
			@ aObj1Size[2,1]+5, aObj1Size[2,2]+30 	CheckBox oCheckBox VAR lInvertSinal Prompt OemToAnsi( STR0005 ) SIZE 75,30 OF oPanel PIXEL //"Inverter Sinal" 
			
			//Qdo for cancelamento, o campo processo ficará desabilitado e será o mesmo informado em "Processo De"
			oTipo:bChange := {|| gpm760TipoChange() }
			
			@ aObj1Size[1,1]+18, aObj1Size[1,2] 	SAY OemToAnsi( STR0034 ) SIZE 080,10 OF oPanel PIXEL	//"Acao"
			@ aObj1Size[1,1]+18, aObj1Size[1,2]+55 MsComboBox oAcao Var cAcao ITEMS aListAcao SIZE 140,10 OF oPanel PIXEL
	          
			@ aObj2Size[1,1], aObj2Size[1,2]  	GROUP oGrpPerDe   TO aObj2Size[1,3], aObj2Size[1,4] LABEL OemToAnsi(STR0006) OF oPanel PIXEL	//"Periodo De"
			@ aObj2Size[3,1], aObj2Size[3,2]	GROUP oParaGrpPer TO aObj2Size[3,3], aObj2Size[3,4] LABEL OemToAnsi(STR0007) OF oPanel PIXEL	//"Periodo Para"
			@ aObjSize[3,1], aObjSize[3,2]	    GROUP oGrpFun     TO aObjSize[3,3] , aObjSize[3,4] 	LABEL OemToAnsi(STR0012) OF oPanel PIXEL	//"Funcionários"
			@ aObjSize[4,1], aObjSize[4,2]	    GROUP oGrpVerbas  TO aObjSize[4,3] , aObjSize[4,4] 	LABEL OemToAnsi(STR0015) OF oPanel PIXEL	//"Verbas"
	
			//=========================================================================
			//Processo De
			//=========================================================================
			@aObj2Size[1,1]+7, aObj2Size[1,2]+6 SAY OemToAnsi(STR0008) SIZE 033,007 OF oGrpPerDe PIXEL	//"Processo: "
			@aObj2Size[1,1]+7, aObj2Size[1,2]+50 MSGET oProcDe VAR cProcDe   SIZE 040,007	OF oGrpPerDe PIXEL;
						PICTURE PesqPict("RCJ","RCJ_CODIGO") F3 "RCJ" ;
						VALID gpm760ValidProc() HASBUTTON
						
			@aObj2Size[1,1]+7, aObj2Size[1,2]+90 MSGET cProcDDe SIZE 80,007	OF  oGrpPerDe PIXEL WHEN .F.
	
			//=========================================================================
			//Periodo De
			//=========================================================================
			@aObj2Size[1,1]+20, aObj2Size[1,2]+6 SAY OemToAnsi(STR0009) SIZE 033,007 OF oGrpPerDe PIXEL	//"Periodo: "
			@aObj2Size[1,1]+20, aObj2Size[1,2]+50 MSGET oPerDe VAR cPerDe SIZE 040,007	OF oGrpPerDe PIXEL ;
						PICTURE PesqPict("RCH","RCH_PER") F3 "RCH" ;
						VALID If(!Empty(cPerDe), Gpem020Per(1, cPerDe,, "cPerDe"),.T.) HASBUTTON
			oPerDe:bGotFocus := {|| cProcesso := cProcDe, .T. }
						
			//=========================================================================
			//Nro Pagto De
			//=========================================================================
			@aObj2Size[1,1]+33, aObj2Size[1,2]+6 SAY OemToAnsi(STR0010) SIZE 033,007 OF oGrpPerDe PIXEL	//"Nro. Pagto: "
			@aObj2Size[1,1]+33, aObj2Size[1,2]+50 MSGET oDeNumPagto VAR cDeNumPgto SIZE 040,007	OF oGrpPerDe PIXEL ;
						PICTURE PesqPict("RCH","RCH_NUMPAG") F3 "RCH01" ;
						VALID If(!Empty(cDeNumPgto),ExistCpo( "RCH", cProcDe + cPerDe + cDeNumPgto, 3),.T.) HASBUTTON
			oDeNumPagto:bGotFocus := {|| cProcesso := cProcDe, cPeriodo := cPerDe, .T. }


			//=========================================================================
			//Roteiro De
			//=========================================================================
			@aObj2Size[1,1]+47, aObj2Size[1,2]+6 SAY OemToAnsi(STR0011) SIZE 040,007 OF oGrpPerDe PIXEL	//"Roteiro: "
			@aObj2Size[1,1]+47, aObj2Size[1,2]+50 MSGET oDeRoteiro VAR cDeRoteiro SIZE 040,007	OF oGrpPerDe PIXEL ;
						PICTURE PesqPict("RCH","RCH_ROTEIR") F3 "RCH07" ;
						VALID gpm760RotValid() HASBUTTON
			oDeRoteiro:bGotFocus := {|| cProcesso := cProcDe, cPeriodo := cPerDe, cNumPagto := cDeNumPgto, .T. }

			//=========================================================================
			//Processo Ate
			//=========================================================================
			@ aObj2Size[3,1]+7, aObj2Size[3,2]+6 SAY OemToAnsi(STR0008) SIZE 033,007 OF oParaGrpPer PIXEL	//"Processo: "
			@ aObj2Size[3,1]+7, aObj2Size[3,2]+50 MSGET oProcPara VAR cProcPara   SIZE 040,007	OF oParaGrpPer PIXEL ;
						PICTURE PesqPict("RCJ","RCJ_CODIGO") F3 "RCJ" ;
						VALID gpm760ValidProc() HASBUTTON
					
			@ aObj2Size[3,1]+7, aObj2Size[3,2]+90 MSGET cProcDPara SIZE 80,007 OF  oParaGrpPer PIXEL WHEN .F.

			//=========================================================================
			//Periodo Ate
			//=========================================================================
			@ aObj2Size[3,1]+20, aObj2Size[3,2]+6 SAY OemToAnsi(STR0009) SIZE 033,007 OF oParaGrpPer PIXEL	//"Periodo: "
			@ aObj2Size[3,1]+20, aObj2Size[3,2]+50 MSGET oPerPara VAR cPerPara SIZE 040,007	OF oParaGrpPer PIXEL ;
						PICTURE PesqPict("RCH","RCH_PER") F3 "RCH" ;
						VALID If(!Empty(cPerPara), Gpem020Per(1, cPerPara,, "cPerPara" ), .T.) HASBUTTON
			oPerPara:bGotFocus := {|| cProcesso := cProcPara, .T. }
	
			//=========================================================================
			//Nro Pagto Ate
			//=========================================================================
			@ aObj2Size[3,1]+33, aObj2Size[3,2]+6 SAY OemToAnsi(STR0010) SIZE 033,007 OF oParaGrpPer PIXEL	//"Nro. Pagto: "
			@ aObj2Size[3,1]+33, aObj2Size[3,2]+50 MSGET oParaNumPagto VAR cParaNumPgto SIZE 040,007	OF oParaGrpPer PIXEL ;
						PICTURE PesqPict("RCH","RCH_NUMPAG") F3 "RCH01" ;
						VALID If(!Empty(cParaNumPgto),ExistCpo( "RCH", cProcPara + cPerPara + cParaNumPgto, 3),.T.) HASBUTTON
			oParaNumPagto:bGotFocus := {|| cProcesso := cProcPara, cPeriodo := cPerPara, .T. }
	
			//=========================================================================
			//Roteiro Ate
			//=========================================================================
			@ aObj2Size[3,1]+47, aObj2Size[3,2]+6 SAY OemToAnsi(STR0011) SIZE 040,007 OF oParaGrpPer PIXEL	//"Roteiro: "
			@ aObj2Size[3,1]+47, aObj2Size[3,2]+50 MSGET oParaRoteiro VAR cParaRoteiro SIZE 040,007	OF oParaGrpPer PIXEL ;
						PICTURE PesqPict("RCH","RCH_ROTEIR") F3 "RCH07" ;
						VALID gpm760RotValid() HASBUTTON
			oParaRoteiro:bGotFocus := {|| cProcesso := cProcPara, cPeriodo := cPerPara, cNumPagto := cParaNumPgto, .T. }
	    
			//=========================================================================
			//Filtros
			//=========================================================================
			@ aObjSize[3,1]+7, aObjSize[3,2]+6 SAY OemToAnsi(STR0013)    SIZE 040,007 OF oGrpFun PIXEL	//"Filial: "
			@ aObjSize[3,1]+7, aObjSize[3,2]+46 MSGET oFilial VAR cFilFiltro SIZE 100,007 OF oGrpFun PIXEL PICTURE "@!" F3 "SM0" HASBUTTON
	
			@ aObjSize[3,1]+7, aObjSize[3,4]*0.50 SAY OemToAnsi(STR0014)    SIZE 040,007 OF oGrpFun PIXEL	//"Funcionario: "
			@ aObjSize[3,1]+7, (aObjSize[3,4]*0.50)+40 MSGET oFunc   VAR cFunFiltro SIZE 100,007 OF oGrpFun PIXEL PICTURE "@!" F3 "SRA" HASBUTTON
	
			//=========================================================================
			//Verbas
			//=========================================================================			
			fMontaHeader()
			
			oGet := MsNewGetDados():New(aObj3Size[1,1]+5,;// nTop
										aObj3Size[1,2],;// nLelft
										aObj3Size[1,3],;// nBottom
		        	                    aObj3Size[1,4],;// nRright
										nOpcNewGd,;		// controle do que podera ser realizado na GetDado - nstyle
										"gpm760LinOK",;	// funcao para validar a edicao da linha - ulinhaOK
										"gpm760TudOK",;	// funcao para validar todas os registros da GetDados - uTudoOK
									 	NIL,;			// cIniCPOS
										NIL,;			// aAlter
										0,;				// nfreeze
										99999,;  		// nMax
										NIL,;		 	// cFieldOK
										NIL,;			// usuperdel
										.T.,;			// udelOK
										@oDlg,;        	// objeto de dialogo - oWnd
										@aHeader,;		// Vetor com Colunas - AparHeader
										@aCols;			// Vetor com Header - AparCols
										)
	
		//Na entrada na tela, o tipo de operação sempre vai ser "Cancelamento".
		//Por isso, é necessário executar na entrada da tela a função "gpm760TipoChange", 
		//para desabilitar os campos necessários.
		gpm760TipoChange()
           
		ACTIVATE MSDIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED
	
	End Sequence

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fMontaHeaderºAutor  ³Microsiga           º Data ³  10/07/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montagem  do aheader                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fMontaHeader()
                                                                       
	//Coluna "Verba De"
	Aadd(aHeader, { OemToAnsi(STR0016),; 					//"Verba De" - Título
					"RV_COD",;								//Campo
	                 GetSx3Cache("RV_COD","X3_PICTURE" ),;	//Picture
	                 GetSx3Cache("RV_COD","X3_TAMANHO" ),;	//Tamanho
	                 GetSx3Cache("RV_COD","X3_DECIMAL" ),;	//Decimal
	                 "gpm760PdValid()",;					//Valid
	                 "û",;                                  //Usado
	                 GetSx3Cache("RV_COD","X3_TIPO" ),;		//Tipo
	                 "SRV-RM",;								//F3
	                 "R",;									//Contexto
	                 "",;									//cBox
	                 "",;									//Inicializador Padrao
	                 "gpm760PdWhen()"}) 					//When									

	//Coluna "Descrição Verba De"
	Aadd(aHeader, { OemToAnsi(STR0017),; 					//"Descricao" - Título
					"RV_DESC",;								//Campo
	                 GetSx3Cache("RV_DESC","X3_PICTURE" ),;	//Picture
	                 GetSx3Cache("RV_DESC","X3_TAMANHO" ),;	//Tamanho
	                 GetSx3Cache("RV_DESC","X3_DECIMAL" ),;	//Decimal
	                 "",;									//Valid
	                 "û",;                                  //Usado
	                 GetSx3Cache("RV_DESC","X3_TIPO" ),;	//Tipo
	                 "",;									//F3
	                 "V",;									//Contexto
	                 "",;									//cBox
	                 "",;									//Inicializador Padrao
	                 "",;									//When
	                 "V"})									//Visual

	//Coluna "Verba Para"
	Aadd(aHeader, { OemToAnsi(STR0018),; 					//"Verba De" - Título
					"RV_CODPARA",;							//Campo
	                 GetSx3Cache("RV_COD","X3_PICTURE" ),;	//Picture
	                 GetSx3Cache("RV_COD","X3_TAMANHO" ),;	//Tamanho
	                 GetSx3Cache("RV_COD","X3_DECIMAL" ),;	//Decimal
	                 "gpm760PdValid()",;					//Valid
	                 "û",;                                  //Usado
	                 GetSx3Cache("RV_COD","X3_TIPO" ),;		//Tipo
	                 "SRV-RM",;								//F3
	                 "R",;									//Contexto
	                 "",;									//cBox
	                 "",;									//Inicializador Padrao
	                 "gpm760PdWhen()"})						//When									
	                 
	//Coluna "Descrição Verba Para"
	Aadd(aHeader, { OemToAnsi(STR0017),; 					//"Descricao" - Título
					"RV_DESCPARA",;							//Campo
	                 GetSx3Cache("RV_DESC","X3_PICTURE" ),;	//Picture
	                 GetSx3Cache("RV_DESC","X3_TAMANHO" ),;	//Tamanho
	                 GetSx3Cache("RV_DESC","X3_DECIMAL" ),;	//Decimal
	                 "",;									//Valid
	                 "û",;                                  //Usado
	                 GetSx3Cache("RV_DESC","X3_TIPO" ),;	//Tipo
	                 "",;									//F3
	                 "V",;									//Contexto
	                 "",;									//cBox
	                 "",;									//Inicializador Padrao
	                 "",;									//When
	                 "V"})									//Visual
					 
	nUsado  := 4

Return NIL                         
           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³gpm760PdWhen ºAutor  ³Microsiga          º Data ³  15/07/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alimentar as variaveis privates utilizadas na consulta pa-  º±±
±±º          ³drao dos campos verbas da getdados                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Campos Verbas da getdados                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function gpm760PdWhen()
Local cCampo := ReadVar()
Local lRet   := .T.
	                   
	If Alltrim(Upper(cCampo)) == "M->RV_COD"
		cCodProcesso := cProcDe
		cCodPeriodo  := cPerDe
		cNumPagamento:= cDeNumPgto
		cCodRoteiro	 := cDeRoteiro
		
	ElseIf Alltrim(Upper(cCampo)) == "M->RV_CODPARA"
		cCodProcesso := cProcPara
		cCodPeriodo  := cPerPara
		cNumPagamento:= cParaNumPgto
		cCodRoteiro	 := cParaRoteiro
	EndIf
	                 
	If Empty(cCodProcesso) .or. Empty(cCodPeriodo) .or. Empty(cNumPagamento) .or. Empty(cCodRoteiro)
		Aviso( OemToAnsi(STR0019), OemToAnsi(STR0039), {STR0020} ) // "Atenção"##"Para informar as verbas os campos processo, periodo, número de pagamento e roteiro (de e para) devem ser informados!"##"OK"
		lRet := .F.
	Else
		aIndexSRV := {}
   		MontaF3SRV(.F.,cCodRoteiro,cCodProcesso,@aIndexSRV, .T.)
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³gpm760Filtro ºAutor  ³Microsiga          º Data ³  10/07/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtrar os roteiros conforme processo, periodo e num. pagto º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Consulta Padrao RCH07                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function gpm760Filtro()
Local cFiltro  := ""

	If Type( "cProcesso" ) != "U"
		If !Empty(cProcesso)
			cFiltro	+= " (RCH->RCH_PROCES == '" + cProcesso + "')" 
		EndIf
	EndIf

	If Type( "cPeriodo" ) != "U"
		If !Empty(cPeriodo)
			If !Empty(cFiltro)
				cFiltro	+= " .AND. "
			EndIf
			cFiltro += " (RCH->RCH_PER == '" + cPeriodo + "')"
		EndIf
	EndIf

	If Type( "cNumPagto" ) != "U"
		If !Empty(cNumPagto)
			If !Empty(cFiltro)
				cFiltro	+= " .AND. "
			EndIf
			cFiltro += " (RCH->RCH_NUMPAG == '" + cNumPagto + "')"
		EndIf
	EndIf

	If Type( "cCond" ) != "U"
		If cCond == "1" .OR. cCond == "2" // Periodo aberto ou fechado
			If !Empty(cFiltro)
				cFiltro	+= " .AND. "
			EndIf
			If cCond == "2" // Periodo fechado
				cFiltro := "!"
			EndIf
			cFiltro	+= "EMPTY(RCH->RCH_DTFECH)" 
		EndIf
	EndIf

	cFiltro := "@#" + cFiltro + "@#"

Return ( cFiltro )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³gpm760ValidProc ºAutor  ³Microsiga       º Data ³  10/07/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validar o Processo informado                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM760                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function gpm760ValidProc()
Local lRet   := .T.                    
Local cCampo := ReadVar()          

	If Gpem020VldPrc() .and. Gpm020SetVar()
		If AllTrim(Upper(cCampo)) == "CPROCDE"
			cProcDDe  := RCJ->RCJ_DESCRI
			If cTipo == "1"
				cProcPara  := &( cCampo )
				cProcDPara := RCJ->RCJ_DESCRI
			EndIf
		Else 
			cProcDPara  := RCJ->RCJ_DESCRI
		EndIf
	Else
		lRet := .F.
	EndIf  
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³gpm760TipoChangeºAutor  ³Microsiga       º Data ³  10/07/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializar, habilitar ou desabilitar alguns campos, confor-º±±
±±º          ³me tipo selecionado                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM760 - alteracao do campo Tipo                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function gpm760TipoChange()
	
	If cTipo == "1"                                   
		//Desabilitar campo check
		lInvertSinal:= .T.
		oCheckBox:Disable()
		
		//Desabilitar campo "Processo Para"
		oProcPara:Disable()
		cProcPara  := cProcDe
		cProcDPara := cProcDDe
		
		cPerPara 	:= Space( TamSX3( "RCH_PER" )[1] )
		cParaNumPgto:= Space( TamSX3( "RCH_NUMPAG" )[1] )
		cParaRoteiro:= Space( TamSX3( "RCH_ROTEIR" )[1] )

		//Desabilitar GetDados
		oGet:aCols := GdRmkaCols(aHeader)
		oGet:Disable()
		oGet:Refresh()
	Else
		//Habilitar campos
		oCheckBox:Enable()
		oProcPara:Enable()
		oGet:Enable()   
	EndIf

Return NIL                                                                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³gpm760Processa  ºAutor  ³Microsiga       º Data ³  10/07/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processar o Cancelamento de Recibo ou a Transferencia de mo-º±±
±±º          ³vimentos                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM760                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function gpm760Processa()      
Local cAliasMov    := ""
Local cAliasAux    := ""
Local cAtuFilial   := ""
Local cAtuMatric   := ""
Local cAtuPd       := ""
Local cAtuDtRef    := ""
Local cAtuSeq      := ""
Local cSeq		   := ""
Local cExp         := ""    
Local cFilter      := ""
Local cPrefixo     := ""
Local cTabela      := ""
Local cLactoDiario := ""
Local cIgual       := ""
Local cAnd		   := ""
Local cTimeIni     := Time()
Local cInnerJoin   := ""
Local cChave       := ""
Local cRGBFilter   := ""
Local aFilter      := {}
Local aErros	   := {}
Local aLogs 	   := {}
Local aRecsBarG	   := {}
Local nX           := 0  
Local nTotReg	   := 0
Local nQtdeLanc    := 0
Local nPosPdDe     := GdFieldPos("RV_COD")
Local nPosPdPara   := GdFieldPos("RV_CODPARA")
Local nPos         := 0
Local nSvRecno     := 0
Local nTotPD       := 0  
Local lPrenaCols   := .T.
  
	aCols := oGet:aCols  
	If(cTipo == "2" .and. Empty(aCols[1][1]), lPrenaCols := .F. , lPrenaCols := .T.)  
	
If lPrenaCols
	Begin Sequence	
			
		aAdd(aLogs , OemToAnsi(STR0041)) //"Não foi possivel fazer o Transferencia/Cancelamento de cálculos dos movimentos abaixo, pois o registro já existe no cadastro de incidencias"
		aAdd(aLogs , Space(1))
		aAdd(aLogs , Space(1))
		aAdd(aLogs , OemToAnsi(STR0044)) //"FILIAL   MATRICULA   PROCESSO   PERIODO   N.PAGTO   ROTEIRO   VERBA   DATA REFERENCIA"
		aAdd(aLogs , Replicate("=",Len(STR0044)))
	
		cAliasAux := "QRCH"
		
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Busca informacoes do periodo selecionado                     ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		BeginSql alias cAliasAux
			SELECT RCH_DTFECH 
			FROM %table:RCH% RCH 
			WHERE RCH.RCH_FILIAL = %xfilial:RCH%    AND
				  RCH.RCH_PROCES = %exp:cProcDe%    AND
				  RCH.RCH_PER    = %exp:cPerDe%     AND
				  RCH.RCH_NUMPAG = %exp:cDeNumPgto% AND
				  RCH.RCH_ROTEIR = %exp:cDeRoteiro% AND
				  RCH.%notDel%   
		EndSql       
				
		IF Empty((cAliasAux)->RCH_DTFECH)
			cAliasMov := "SRC"    
		Else
			cAliasMov := "SRD"           
		EndIf                
		(cAliasAux)->( DbCloseArea() )
	
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Geracao da Query com os Registros a serem processados        ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cPrefixo := ( PrefixoCpo( cAliasMov ) + "_" )
		
		//Filtro de Filial e Funcionario
		If !Empty(cFilFiltro)
			aAdd( aFilter, {cAliasMov + "->" + cPrefixo + "FILIAL", cFilFiltro, ""} )	// Filial
		EndIf
		If !Empty(cFunFiltro)
			aAdd( aFilter, {cAliasMov + "->" + cPrefixo + "MAT"   , cFunFiltro, ""} )	// Matricula do Funcionario
		EndIf
	
		cFilter := ""
	
		MakeStrExpr(@aFilter, .T.) 
		cPrefixo := cAliasMov + "." + cPrefixo
		cIgual   := " = "
		cAnd     := " AND "
	
		cFilter += cPrefixo + "PROCES  " + cIgual + " '" + cProcDe    + "'" + cAnd
		cFilter += cPrefixo + "PERIODO " + cIgual + " '" + cPerDe     + "'" + cAnd
		cFilter += cPrefixo + "SEMANA  " + cIgual + " '" + cDeNumPgto + "'" + cAnd
		cFilter += cPrefixo + "ROTEIR  " + cIgual + " '" + cDeRoteiro + "'"
	
		cExp := "("
		For nX := 1 To Len(aFilter)
			If !Empty(aFilter[nX,3])
				If len(cExp) > 1
					cExp += cAnd
				EndIf
			    cExp += aFilter[nX,3]
			EndIf		
		Next nX
		
		cExp := GPEParSQL(cExp) 
		
		cExp += ")"
		If cExp <> "()"
			cFilter += cAnd + cExp
		EndIf   
		                                
		//Filtro das verbas
		cExp := ""
		If cTipo == "2"
			For nX := 1 to Len(aCols)
				If !Empty(aCols[nX,nPosPdDe])
				    cExp += "'" + aCols[nX,nPosPdDe] + "',"
				EndIf		
			Next nX
			If !Empty(cExp)
				cExp := Substr(cExp, 1, len(cExp)-1 )
				cFilter += " AND ( " + cPrefixo + "PD IN (" + cExp + "))"			
			EndIf   
		EndIf
	
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Obtenho o Numero de Registros a serem Processados            ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cTabela    := "%" + RetSqlName(cAliasMov) + " " + cAliasMov + "%"
		cFilter    += cAnd + cAliasMov + ".D_E_L_E_T_ = '' "
		cFilter    := "%" + cFilter + "%"
		cInnerJoin := "%" + cPrefixo + "FILIAL = SRA.RA_FILIAL AND " + cPrefixo + "MAT = SRA.RA_MAT%"
		
		BeginSql alias "QTMP"

			SELECT COUNT(*) TOTREG
			FROM %exp:cTabela%
			WHERE %exp:cFilter%

		EndSql   
		nTotReg := QTMP->( TOTREG )
		
		QTMP->( DbCloseArea() )

		(cAliasMov)->( DbCloseArea() )
		
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Seta o Valor para a Funcao de Incremento                     ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		BarGauge1Set( nTotReg )
	
		dbSelectArea("RGB")
		RGB->( dbSetOrder( RetOrdem("RGB", "RGB_FILIAL + RGB_PROCES + RGB_PERIOD + RGB_SEMANA + RGB_ROTEIR + RGB_MAT + RGB_PD + DTOS(RGB_DTREF) + RGB_SEQ") ))
	
		//Seleção dos dados "DE"	
	
		BeginSql alias cAliasMov
			SELECT *
			FROM %exp:cTabela%
			INNER JOIN %table:SRA% SRA
			ON %exp:cInnerJoin%
			WHERE %exp:cFilter%                     
			AND SRA.%notDel%
		EndSql                  
		cFilter := ".T."  		
		
		cPrefixo := ( PrefixoCpo( cAliasMov ) + "_" )
		( cAliasMov )->( dbGoTop())
		While (cAliasMov)->( !Eof() )
	                            
			IF ( lAbortPrint )
				Break
			EndIF
		                             
			If !&(cFilter)
				(cAliasMov)->( DbSkip() )
				Loop	
			EndIf
			
			cAtuFilial := (cAliasMov)->(&(cPrefixo + "FILIAL"))
			cAtuMatric := (cAliasMov)->(&(cPrefixo + "MAT"))
			cAtuDtRef  := (cAliasMov)->(&(cPrefixo + "DTREF"))			
			cAtuSeq    := (cAliasMov)->(&(cPrefixo + "SEQ"))
			cAtuPd     := (cAliasMov)->(&(cPrefixo + "PD"))
			If cTipo == "2"
				If (nPos := aScan(aCols, {|x| x[nPosPdDe] == cAtuPd})) > 0
					cAtuPd := aCols[nPos, nPosPdPara]
				EndIf
			EndIf
	
			cAliasAux := "SRA"
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Movimenta cursor para movimentacao da barra 				   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			IncPrcG1Time(OemToAnsi(STR0014) + (cAliasMov)->(&(cPrefixo + "MAT")) + "-" + (cAliasAux)->RA_NOME + " / " + OemToAnsi(STR0040) + (cAliasMov)->(&(cPrefixo + "PD")) , nTotReg , cTimeIni , .T. , 1 , 1 , .T. ) //#"Verba: "
			                                                   
			If Len(aErros) > 0         
				//Se cancelamento e por algum motivo não pode incluir a verba anterior, ir para próximo funcionário
				If cTipo == "1" .and. (aScan(aErros, {|x| x[1] == cAtuFilial .and. x[2] == cAtuMatric}) > 0)
					(cAliasMov)->( DbSkip() )
					Loop	
				EndIf
			EndIf
	        
			//Busca informacoes da Verba
	 
			cAliasAux := "QSRV"
			BeginSql Alias cAliasAux
				SELECT SRV.RV_LCTODIA, SRV.RV_QTDLANC
				FROM %table:SRV% SRV 
				WHERE SRV.RV_FILIAL = %xfilial:SRV%    AND
					  SRV.RV_COD     = %exp:cAtuPd%     AND
					  SRV.%notDel%   
			EndSql   
				                       
		    cLactoDiario := (cAliasAux)->RV_LCTODIA
		    nQtdeLanc    := Val((cAliasAux)->RV_QTDLANC)
			(cAliasAux)->( DbCloseArea() )
	
	        If cLactoDiario == "S"
	       		cChave := cAtuFilial + cProcPara + cPerPara + cParaNumPgto + cParaRoteiro + ;
	        	          cAtuMatric + cAtuPd + cAtuDtRef
	        Else
	        	cChave := cAtuFilial + cProcPara + cPerPara + cParaNumPgto + cParaRoteiro + ;
	        	          cAtuMatric + cAtuPd + cAtuDtRef + cAtuSeq
	        EndIf
	        
			RGB->( dbGoTop() )      
			If RGB->( dbSeek(cChave) )
				//Gerar novo movimento
				If cAcao == "1" 
				                            
					//Por ser lançamento diário, não poderá ter mais de um lançamento no mesmo dia da mesma verba
				    If cLactoDiario == "S"           
				    	cChave := cAtuFilial + Space(7) + cAtuMatric + Space(6) + cProcPara + Space(6) +;
							             cPerPara + Space(4) + cParaNumPgto + Space(8) + cParaRoteiro
				    	If cTipo == "1"              
				    		cChave += Space(7) + "---" + Space(5) + "--------"
				    	Else
				    		cChave += Space(7) + cAtuPd + Space(5) + cAtuDtRef
						EndIf
						aAdd(aLogs , cChave)
	
						aAdd(aErros , {cAtuFilial, cAtuMatric} )
						(cAliasMov)->( DbSkip() )
						Loop	
				    Else
					  
						cAliasAux := "QRGB"
						BeginSql Alias cAliasAux
							SELECT COUNT(*) TOTPD
							FROM %table:RGB% RGB
							WHERE RGB.RGB_FILIAL = %exp:cAtuFilial% 	AND 
								  RGB.RGB_PROCES = %exp:cProcPara% 		AND
								  RGB.RGB_PERIOD = %exp:cPerPara% 		AND 
								  RGB.RGB_SEMANA = %exp:cParaNumPgto% 	AND 
								  RGB.RGB_ROTEIR = %exp:cParaRoteiro% 	AND 
								  RGB.RGB_MAT    = %exp:cAtuMatric% 	AND 
								  RGB.RGB_PD     = %exp:cAtuPd% 		AND 
								  RGB.RGB_DTREF  = %exp:cAtuDtRef% 		AND 
					  			  RGB.%notDel%
						EndSql
						nTotPD := (cAliasAux)->TOTPD
						(cAliasAux)->( DbCloseArea() )
						
						If  nTotPD < nQtdeLanc
							cSeq := AllTrim(Str(nTotPD + 1))
							RecLock("RGB", .T.)
						Else
					    	cChave := cAtuFilial + Space(7) + cAtuMatric + Space(6) + cProcPara + Space(6) +;
								             cPerPara + Space(4) + cParaNumPgto + Space(8) + cParaRoteiro
				
					    	If cTipo == "1"              
					    		cChave += Space(7) + "---" + Space(5) + "--------"
					    	Else
					    		cChave += Space(7) + cAtuPd + Space(5) + cAtuDtRef
							EndIf
							aAdd(aLogs , cChave)
			
							aAdd(aErros , {cAtuFilial, cAtuMatric} )
							(cAliasMov)->( DbSkip() )
							Loop	
						EndIf
				    EndIf     
				    
				//Substituir
				ElseIf cAcao == "2"
					RecLock("RGB", .F.)
					cSeq  := RGB->RGB_SEQ
				
				//Não gerar movimento - Gerar Log
				Else     
			    	cChave := cAtuFilial + Space(7) + cAtuMatric + Space(6) + cProcPara + Space(6) +;
						             cPerPara + Space(4) + cParaNumPgto + Space(8) + cParaRoteiro
			    	If cTipo == "1"              
			    		cChave += Space(7) + "---" + Space(5) + "--------"
			    	Else
			    		cChave += Space(7) + cAtuPd + Space(5) + cAtuDtRef
					EndIf
					aAdd(aLogs , cChave)
	
					aAdd(aErros , {cAtuFilial, cAtuMatric} )
					(cAliasMov)->( DbSkip() )
					Loop	
				EndIf
			Else
				RecLock("RGB", .T.)
				cSeq  := (cAliasMov)->(&(cPrefixo + "SEQ"))
			EndIf
	
			RGB->RGB_PROCES := cProcPara
			RGB->RGB_PERIOD := cPerPara
			RGB->RGB_SEMANA := cParaNumPgto
			RGB->RGB_ROTEIR := cParaRoteiro
	    	RGB->RGB_FILIAL := (cAliasMov)->(&(cPrefixo + "FILIAL"))
			RGB->RGB_MAT    := (cAliasMov)->(&(cPrefixo + "MAT"))
			RGB->RGB_TIPO1  := (cAliasMov)->(&(cPrefixo + "TIPO1"))
			RGB->RGB_QTDSEM := (cAliasMov)->(&(cPrefixo + "QTDSEM"))
			IF cPaisLoc <>'BRA'
				RGB->RGB_HORAS  := (cAliasMov)->(&(cPrefixo + "HORAS")) * (If(lInvertSinal, -1, 1))
			ELSE
				RGB->RGB_HORAS  := (cAliasMov)->(&(cPrefixo + "HORAS"))
			ENDIF
			RGB->RGB_VALOR  := (cAliasMov)->(&(cPrefixo + "VALOR")) * (If(lInvertSinal, -1, 1))
			RGB->RGB_DTREF  := STOD((cAliasMov)->(&(cPrefixo + "DTREF")))
			RGB->RGB_CC     := (cAliasMov)->(&(cPrefixo + "CC"))
			RGB->RGB_TIPO2  := (cAliasMov)->(&(cPrefixo + "TIPO2"))
			RGB->RGB_NUMID  := (cAliasMov)->(&(cPrefixo + "NUMID"))
			RGB->RGB_POSTO  := (cAliasMov)->(&(cPrefixo + "POSTO"))
			RGB->RGB_DEPTO  := (cAliasMov)->(&(cPrefixo + "DEPTO"))
	
			RGB->RGB_SEQ    := cSeq
			If cTipo == "1"
				RGB->RGB_PD     := (cAliasMov)->(&(cPrefixo + "PD"))
			Else
				If (nPos := aScan(aCols, {|x| x[nPosPdDe] == (cAliasMov)->(&(cPrefixo + "PD"))})) > 0
					RGB->RGB_PD := aCols[nPos, nPosPdPara]
				EndIf
			EndIf
	
			If (cAliasMov)->( FieldPos(cPrefixo + "PARCELA") ) > 0
				RGB->RGB_PARCEL := (cAliasMov)->(&(cPrefixo + "PARCELA")) //SRD não tem o campo???
			EndIf
	                    
		 	RGB->(MsUnlock())
			
			(cAliasMov)->( DbSkip() )
		EndDo
	
		RGB->(DbCloseArea())
		(cAliasMov)->(DbCloseArea())
	
	End Sequence                   
	                     
		//Finalizado com sucesso!
		If Len(aErros) == 0     
			aLogs := {}
			aAdd(aLogs , OemToAnsi(STR0042) )    // Transferencia/Cancelamento de Calculos encerrado com sucesso!
		EndIf
	
		//"Log de Ocorrencias"
		bMakeLog := { || fMakeLog( { aLogs } ,  { STR0043 } , NIL , .T. , FunName() , NIL , "G" , "L" , NIL , NIL ) } //"Log de Ocorrencias na Transferência/Cancelamento de Cálculos"
		MsAguarde( bMakeLog , OemToAnsi( STR0043 ) ) 
Else 
	Help("",1,"GPEMTRANS") // Para o tipo de Operacao: Transferencia de Movimento e necessario informar quais as verbas devem ser transferidas.
	Return .F.
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³gpm760VldCpos ºAutor³Microsiga           º Data ³  10/07/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validar todos os campos da tela de cancelamento de recibo   º±±
±±º          ³ ou transferencia de movimentos                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM760                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function gpm760VldCpos()
Local lRet := .T.     
                    
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Altera o Estado do Cursor  								   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	CursorWait()

	Begin Sequence
	
		//Tipo de operação
		If Empty(cTipo)
			Aviso( OemToAnsi(STR0019), OemToAnsi(STR0021), {STR0020} ) // "Atenção"##"O tipo de operação deve ser informado!"##"OK"
			lRet := .F. 
		EndIf
		        
		//Processo De
		If lRet
			If Empty(cProcDe)
				Aviso( OemToAnsi(STR0019), OemToAnsi(STR0022), {STR0020} ) // "Atenção"##"O processo 'de' deve ser informado!"##"OK"
				lRet := .F.
			ElseIf !ExistCpo("RCJ", cProcDe)
				lRet := .F.
			EndIf
		EndIf
		             
		//Periodo De
		If lRet
			If Empty(cPerDe)
				Aviso( OemToAnsi(STR0019), OemToAnsi(STR0024), {STR0020} ) // "Atenção"##"O período 'de' deve ser informado!"##"OK"
				lRet := .F.
			ElseIf !ExistCpo("RCH", cProcDe + cPerDe)
				lRet := .F.
			EndIf
		EndIf
		            
		//Numero de pagamento De
		If lRet
			If Empty(cDeNumPgto)
				Aviso( OemToAnsi(STR0019), OemToAnsi(STR0026), {STR0020} ) // "Atenção"##"O numero de pagamento 'de' deve ser informado!"##"OK"
				lRet := .F.
			ElseIf !ExistCpo("RCH", cProcDe + cPerDe + cDeNumPgto)
				lRet := .F.
			EndIf
		EndIf
	                            
		//Roteiro De
		If lRet
			If Empty(cDeRoteiro)
				Aviso( OemToAnsi(STR0019), OemToAnsi(STR0028), {STR0020} ) // "Atenção"##"O roteiro 'de' deve ser informado!"##"OK"
				lRet := .F.
			ElseIf !ExistCpo("RCH", cProcDe + cPerDe + cDeNumPgto + cDeRoteiro)
				lRet := .F.
			EndIf
		EndIf
	                
		//Processo Para
		If lRet
			If Empty(cProcPara)
				Aviso( OemToAnsi(STR0019), OemToAnsi(STR0023), {STR0020} ) // "Atenção"##"O processo 'para' deve ser informado!"##"OK"
				lRet := .F.
			ElseIf !ExistCpo("RCJ", cProcPara)
				lRet := .F.
			EndIf
		EndIf
	                   
		//Periodo Para
		If lRet
			If Empty(cPerPara)
				Aviso( OemToAnsi(STR0019), OemToAnsi(STR0025), {STR0020} ) // "Atenção"##"O período 'para' deve ser informado!"##"OK"
				lRet := .F.
			ElseIf !ExistCpo("RCH", cProcPara + cPerPara)
				lRet := .F.
			EndIf
		EndIf
		              
		//Numero de Pagamento Para
		If lRet
			If Empty(cParaNumPgto)
				Aviso( OemToAnsi(STR0019), OemToAnsi(STR0027), {STR0020} ) // "Atenção"##"O numero de pagamento 'para' deve ser informado!"##"OK"
				lRet := .F.
			ElseIf !ExistCpo("RCH", cProcPara + cPerPara + cParaNumPgto)
				lRet := .F.
			EndIf
		EndIf
		                          
		//Roteiro Para
		If lRet
			If Empty(cParaRoteiro)
				Aviso( OemToAnsi(STR0019), OemToAnsi(STR0029), {STR0020} ) // "Atenção"##"O roteiro 'para' deve ser informado!"##"OK"
				lRet := .F.
			ElseIf !ExistCpo("RCH", cProcPara + cPerPara + cParaNumPgto + cParaRoteiro)
				lRet := .F.
			EndIf
		EndIf
		              
		//Verbas       
		If lRet
			If cTipo == "2" 
				If Empty(oGet:aCols)
					Aviso( OemToAnsi(STR0019), OemToAnsi(STR0030), {STR0020} ) // "Atenção"##"As verbas para transferência de movimentos devem ser informadas!"##"OK"
				    lRet := .F.
				EndIf
			EndIf
		EndIf
		
	End Sequence
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Restaura o Estado do Cursor								   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	CursorArrow()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gpm760LinOK ³ Autor ³Microsiga            ³ Data ³10/07/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM760                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function gpm760LinOK()
Local lLinOk 		:= .T. 
Local nPosPdDe  	:= GdFieldPos("RV_COD")
Local nPosPdPara	:= GdFieldPos("RV_CODPARA")

	aCols := oGet:aCols

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Altera o Estado do Cursor  								   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	CursorWait()
	
	Begin Sequence
	
		If !( GdDeleted() )
			If Empty(aCols[n , nPosPdDe]) 
				Aviso( OemToAnsi(STR0019), OemToAnsi(STR0031), {STR0020} ) // "Atenção"##"A verba 'de' deve ser informada!"##"OK"
				lLinOk := .F.
			ElseIf !ExistCpo("SRV", aCols[n , nPosPdDe])
				lLinOk := .F.
			EndIf
	
			If lLinOk		
				If Empty(aCols[n , nPosPdPara])
					Aviso( OemToAnsi(STR0019), OemToAnsi(STR0032), {STR0020} ) // "Atenção"##"A verba 'para' deve ser informada!"##"OK"
					lLinOk := .F.
				ElseIf !ExistCpo("SRV", aCols[n , nPosPdPara])
					lLinOk := .F.
				EndIf     
			EndIf
		EndIf
	
	End Sequence
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Restaura o Estado do Cursor								   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	CursorArrow()

Return( lLinOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gpm760TudOK ³ Autor ³Microsiga            ³ Data ³11/07/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM760                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function gpm760TudOK()
Local lTudoOk := .T.
Local nLoop

	aCols := oGet:aCols
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Altera o Estado do Cursor  								   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	CursorWait()
	
	Begin Sequence
		         
	    /*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Percorre Todas as Linhas para verificar se Esta Tudo OK      ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		For nLoop := 1 To Len( aCols )
			n := nLoop
	                                                  
			IF !( lTudoOk := gpm760TudOK( ) )
				oGet:oBrowse:Refresh()
				Break
			EndIF
		Next nLoop
	
	End Sequence
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Restaura o Estado do Cursor								   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	CursorArrow()

Return( lTudoOk  )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gpm760RotValid ³ Autor ³Microsiga         ³ Data ³18/07/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o campo Roteiro De e Para                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM760                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function gpm760RotValid()
Local lRet     := .T.
Local cCampo   := ReadVar()
Local cAtuProc := ""
Local cAtuPer  := ""
Local cAtuNPg  := ""
Local cAtuRot  := ""
               
	If AllTrim(Upper(cCampo)) == "CDEROTEIRO"
		cAtuProc := cProcDe
		cAtuPer  := cPerDe
		cAtuNPg  := cDeNumPgto
		cAtuRot  := cDeRoteiro
	Else
		cAtuProc := cProcPara
		cAtuPer  := cPerPara
		cAtuNPg  := cParaNumPgto
		cAtuRot  := cParaRoteiro
	EndIf
		                                                      
	If !Empty(cAtuRot)
		If lRet := ExistCpo("RCH", cAtuProc + cAtuPer + cAtuNPg + cAtuRot, 1)
			If cTipo == "2"
				dbSelectArea("SRM")
				dbSetOrder(RetOrdem("SRM", "RM_FILIAL+RM_PROCES+RM_CALCULO+RM_SEQ"))
	    	  	If !(lRet := dbSeek(xFilial("SRM") + cAtuProc + cAtuRot))
					Aviso( OemToAnsi(STR0019), OemToAnsi(STR0038), {STR0020} ) // "Atenção"##"Não existe procedimento de cálculo para o Processo e Roteiro informado!"##"OK"
	      		EndIf
				SRM->( DbCloseArea() )
	    	EndIf
		EndIf
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gpm760PdValid  ³ Autor ³Microsiga         ³ Data ³18/07/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o campo descricao da Verba                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM760                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function gpm760PdValid()
Local lRet     := .T.
Local cCampo   := ReadVar()
Local nPosDesc := 0
Local cAtuProc := ""
Local cAtuRot  := ""

	aCols := oGet:aCols
	If Alltrim(Upper(cCampo)) == "M->RV_COD"
		nPosDesc := GdFieldPos("RV_DESC")
		cAtuProc := cProcDe
		cAtuRot  := cDeRoteiro
	Else
		nPosDesc := GdFieldPos("RV_DESCPARA")
		cAtuProc := cProcPara
		cAtuRot  := cParaRoteiro
	EndIf                        

	If lRet := ExistCpo("SRM", cAtuProc + cAtuRot + &(cCampo), 3)
 		aCols[n, nPosDesc] := fDesc( "SRV" , &(cCampo) , "RV_DESC" )
	EndIf  
	
Return lRet
