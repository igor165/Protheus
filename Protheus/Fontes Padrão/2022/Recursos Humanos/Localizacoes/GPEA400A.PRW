#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA1400.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "HEADERGD.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GPEA400A  ³Autor  ³Natie          1 Versao³ Data ³  01/12/03   ³±±
±±³          ³          ³Autor  |Mauricio Taka. 2 Versao³ Data ³  28/06/04   ³±±
±±³          ³          ³Autor  |Natie          3 Versao³ Data ³  20/07/07   ³±±
±±³          ³          ³Autor  |M. Silveira    4 Versao³ Data ³  12/11/18   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Rotina de Cadastro do Calendario exclusiva para Modelo 2.      ³±±
±±³          ³Conversao da rotina GPEA400 da versao 11 Fase 4                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Folha de pagamento modelo 2                                    ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÁÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador³ Data   ³ FNC            ³  Motivo da Alteracao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³A.Rodriguez³04/04/19³                ³Declarar nOpcX1 en GPA400AMAn() y   ³±±
±±³           ³        ³                ³GP400AExcl() para uso en GPEA500->  ³±±
±±³           ³        ³                ³ fValidCriter() > fSeleCriterio()   ³±±
±±³Oscar G.   ³31/01/20³                ³En Fun X_VldDtFim se valida que si  ³±±
±±³           ³        ³                ³exista el campo RCH_DTINI antes de  ³±±
±±³           ³        ³                ³consultar el objeto oGetRCh. (MEX)  ³±±
±±³ Marco A.  ³08/07/20³   DMINA-9448   ³Se modifica la funcion fCarPdRG6()  ³±±
±±³           ³        ³                ³para la correcta carga de Periodos  ³±±
±±³           ³        ³                ³Estandar de forma automatica. (MEX) ³±±
±±³Eduardo Prz³20/08/20³   DMINA-9963   ³Se modifica la funcion X_VldDtIni() ³±±
±±³           ³        ³                ³para permitir el registro de forma  ³±±
±±³           ³        ³                ³consecutiva de periodos. (MEX)      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function  GPEA400A()
	Local aAreaAlias		:= {}
	Local aIndex			:= {}
	Local cFiltra			:= ""
	
	Static lValEnchoice										// utilizado para o controle da Enchoice
	
	Private lModPadrao      := If( MV_MODFOL==NIL, SuperGetMv("MV_MODFOL",NIL,"1")=='1', MV_MODFOL == '1')	// Modelo do SIGAGPE
	Private cAlias_			:= "RCJ"	// RCJ - Cad.Processos 
	Private nRecno			:= 0
	Private aRotina 		:= MenuDef()
	Private bFiltraBrw		:= { || NIL }
	Private cCadastro   	:= OemToAnsi(STR0001)				// "Calendario "
	
	Private aColsRCHSF		:={}                      //vetor acols sem Filtro
	Private aHeaderRCHSF	:={}                                              
	Private	lF3Criter	  	:= .F. 	// variável que verifica se a chamada da consulta do critério foi efetuada a partir do F3 ou não
	Private lGp490 			:= AllTrim(Upper(FunName())) == "GPEA490" // Indica acesso pela rotina GPEA490 (Ger.Per.Padrao)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se as duas tabelas estao com o mesmo modo de compartilhamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(Sx2ChkModo("RCJ", "RCH", .T.))
		Return (.F.)
	EndIf
	
	aAreaAlias	:= (cAlias_)->( GetArea() ) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltra		:= ChkRh( FunName() , cAlias_ , "1" )  						// funName (PEGA o nome da funcao corrente)
	bFiltraBrw 	:= { || FilBrowse( cAlias_ , @aIndex , @cFiltra ) }
	Eval( bFiltraBrw )
	
	MBrowse(NIL, NIL, NIL, NIL, cAlias_, NIL, NIL, NIL, NIL, NIL, NIL)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw(cAlias_, aIndex)
	
	lValEnchoice := NIL
		
	RestArea( aAreaAlias ) 
Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³GPA400AMan³ Autor ³Natie Sugahara    1a V ³ Data ³01/12/2003³
³          ³          ³ Autor ³Mauricio Takakura 2a V ³ Data ³28/06/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Manutencao da Rotina de Cadastro de Calendario              ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³GPA400AMan( cAlias , nReg , nOpcX )							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³cAlias = Alias do arquivo                                   ³
³          ³nReg   = Numero do registro                                 ³
³          ³nOpc   = Numero da opcao selecionada                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPA400A()	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function GPA400AMan( cAlias , nReg , nOpc ) 

// variaveis de controle //
Local aSavePosRch		:= RCH->(GETAREA())
Local nOpcAlt			:= 0.00		// variavel de controle das alteracoes - utilizada para a gravacao
Local nX				:= 0.00		// variavel utilizada em loops
Local nUsado 			:= 0
Local nPosRec			:= 0 

// variaveis para enchoice da tabela RCH //
Local nOpcNewGd			:= IF( nOpc == 2 , 0 , GD_INSERT + GD_UPDATE + GD_DELETE )
Local bSkip  

Local aRCHFields		:= {}		// vetor com os campos da tabela
Local aRCHAltera		:= {}		// vetor com os campos que permitem alteracao
Local aRCHNaoAltera		:= {}		// vetor com os campos que nao podem ser alterados
Local aRCHVirtChoice	:= {}		// vetor com os campos virtuais 
Local aRCHNotFields		:= {}		// vetor com os campos que nao serao visualizados
Local aColsRCHRec		:= {}		// vetor contendo os recnos dos registros 
Local aColsEnChoice 	:= {}		// vetor com as colunas da Enchoice RCH
Local aSvEnchoice		:= {}		// vetor com a copia de aColsEnchoice para verificar se houve alteracoes
Local bRCHDelOk			:= { || Gp400RCHDelOk() } 

// variaveis da janela //
Local bSet15			:= { || NIL }	// Bloco com as validacoes do botao OK
Local bSet24			:= { || NIL }	// Bloco com as validacoes do botao Cancelar
Local bDialogInit		:= { || NIL }	// Inicializacao do Dialog

// variaveis do tipo objetos // 
Local oDlg				:= NIL			// objeto de dialogo 
Local oFont	
Local oGroup

// variaveis para controle de coordenadas da janela //
Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjSize			:= {}
Local aObjCoords		:= {}

// variaveis para aButtons //
Local aButtons			:={}
Local bMontaPeriodo 	:= { || MontaPeriodo(aRCHNotFields, nUsado , nOpc) }
Local bCopiaPeriodo 	:= { || CopyPastePeriodo() }
Local bPesqPeriodo  	:= { || fPesqPer() }

// variaveis privadas da Enchoice da tabela RCH //
Private aEnchoice		:= {}		//vetor com o cabecalho da Enchoice RCH (utilizada por chamadas da tabela SX3)
Private aRCHDados		:= {}		//vetor com campos chaves de RCH - Controle para verificar Validacao (EnchoTudOK)
Private cFilRCH			:= ''		//filial corrente
Private aSvColsRCH		:= {}		//vetor auxiliar da GetDados  
Private oEnchoice		:= NIL		//enchoice
 
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis lModPadrao                                                   ³   
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private cProcesso		:= RCJ->RCJ_CODIGO 
Private cProcDesc		:= RCJ->RCJ_CODIGO	+ " - " + RCJ->RCJ_DESCRI 
Private cRoteiro 		:= SPACE(TamSX3("RCH_ROTEIR")[1]) 			   	//Roteiro de calculo 
Private cRoteiroAnt		:= SPACE(TamSX3("RCH_ROTEIR")[1]) 
Private cDescRoteiro	:= ""
Private cPerSel			:= ""
Private cPdPeriodo		:= "" 
Private cPdPeriodAnt	:= "" 
Private cDescPdPeriodo	:= "" 
Private aRotProc		:= {} 											//Vetor com  o Roteiro por processo
Private aRG6			:= {} 											//Vetor com  os 

Private bChange     	:= {|| NIL}
Private cKeySeek		:= ""											// Chave para o Posicionamento no Alias Filho
Private cQuery			:= ""											// Utilizacao de Query para Selecao de Dados
Private lTemPadrao		:= .F. 	   										// Indica se tem  padrao de calendario no Roteiros por processo 
Private lRotProc		:= .F. 		

Private oRoteiro	
Private oGetRCH			:= NIL 											//GetDados da Tabela RCH 
Private aColsRCH		:= {} 											// Vetor aCols 
Private aHeaderRCH		:= {}
Private nOpcX1			:= nOpc

If nReg > 0
	nRecno := nReg
EndIf


cPdPeriodo				:= SPACE(TamSX3("RCH_PDPERI")[1]) 
cPdPeriodAnt			:= SPACE(TamSX3("RCH_PDPERI")[1]) 
cDescPdPeriodo  		:= SPACE(30) 

If (nOpc <> 2)
	aAdd(aButtons, { "NOTE", { || Eval( bMontaPeriodo )  } ,  OemToAnsi(STR0070) } ) //"Monta P.Padrao" 
End If
		
aAdd(aButtons, { "S4WB005N", { || Eval( bCopiaPeriodo )  } ,  OemToAnsi(STR0077) } ) //"Cópia Período"

aAdd(aButtons, { "PMSPESQ", { || Eval( bPesqPeriodo )  } ,  OemToAnsi(STR0063) } ) //"Pesquisa Periodo "

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define o Bloco para a Inicializacao do Dialog            	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
bDialogInit	:= { ||; 
						CursorWait()							,;							
						EnchoiceBar( oDlg , bSet15 , bSet24 , nil ,aButtons)	,;	
						RstEnchoVlds()							,;
						CursorArrow()							 ;
				   }	

bChange     := {|| 		fVLdRoteiro(),;
						cPdPeriodo:= SPACE(TamSX3("RCH_PDPERI")[1]), ;
						( lRotProc:= fRotProc( )),;
						( fCarPdRG6()	         ),; 
						If( cRoteiro <> cRoteiroAnt,	GP400Montacols(nOpc, cAlias,cProcesso, cRoteiro , cPdPeriodo,@aRCHAltera, @aHeaderRCH, @aColsRCH, nOpc , @aColsRCHRec, @aRCHNotFields, nUsado, nPosRec , nReg,.T. ),.T.), ; 
                   } 

/* 
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize() 
aInfoAdvSize	:= { aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 5, 5}
aAdd( aObjCoords , { 0, 25 , .T. , .F. } )
aAdd( aObjCoords , { 0,  0 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta o Dialogo Principal                                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD 
DEFINE MSDIALOG oDlg TITLE OemToAnsi( cCadastro ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL 

	@ aObjSize[1,1], aObjSize[1,2] 		GROUP oGroup 	TO aObjSize[1,3], aObjSize[1,4]*0.27 	LABEL OemToAnsi(STR0034) OF oDlg PIXEL			// Processo 
	oGroup:oFont:= oFont 
	
	@ aObjSize[1,1], aObjSize[1,4]*0.275 	GROUP oGroup 	TO aObjSize[1,3], aObjSize[1,4]*0.65 	LABEL OemToAnsi(STR0035) OF oDlg PIXEL   		//"Roteiro" 		
	oGroup:oFont:= oFont 		
	
	@ aObjSize[1,1], aObjSize[1,4]*0.655 	GROUP oGroup 	TO aObjSize[1,3], aObjSize[1,4]*0.88 	LABEL OemToAnsi(STR0036) OF oDlg PIXEL			// "Pad.Periodo" 
	oGroup:oFont:= oFont
	
	@ aObjSize[1,1], aObjSize[1,4]*0.885 	GROUP oGroup 	TO aObjSize[1,3], aObjSize[1,4] 		LABEL OemToAnsi(STR0051) OF oDlg PIXEL			//"Per.Selec" 		
	oGroup:oFont:= oFont 
				
	@ aObjSize[1,1] + 12,	aObjSize[1,2]+5 SAY cProcDesc SIZE 140,10 OF oDlg PIXEL FONT oFont 
   
	@ aObjSize[1,1] + 10,	aObjSize[1,4]*0.29 MSGET oRoteiro VAR cRoteiro F3 "SRY" VALID {|| If(!ExistCpo("SRY", cRoteiro), .F., Gp400TrocaPer(bChange)) } SIZE 20,10 OF oDlg PIXEL PICTURE "@!" HASBUTTON

	@ aObjSize[1,1] + 12,	(aObjSize[1,4]*0.29)+35 SAY cDescRoteiro SIZE 100,10  OF oDlg PIXEL FONT oFont 
			
	@ aObjSize[1,1] + 12,	aObjSize[1,4]*0.67 SAY cPdPeriodo + cDescPdPeriodo SIZE 100,10 OF oDlg PIXEL FONT oFont 

	@ aObjSize[1,1] + 12,	aObjSize[1,4]*0.90 SAY cPerSel SIZE 100,10 OF oDlg PIXEL FONT oFont 

	
GP400MontaCols(nOpc,cAlias, cProcesso, cRoteiro ,cPdPeriodo, @aRCHAltera, @aHeaderRCH, @aColsRCH , nOpc, @aColsRCHRec, @aRCHNotFields ,@nUsado, nPosRec , nReg,.F.)
aSvColsRCh	:= aClone(aColsRCH) 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Cria as Variaveis de Memoria e Carrega os Dados Conforme o ar³
³ quivo														   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cFilRCH := xFilial("RCH")
For nX := 1 To Len(aHeaderRCH) 
	Private &( "M->"+aHeaderRCH[ nX , 02 ] ) := aColsRCH[ 01 , nX ]
Next nx
                
oGetRCH := MsNewGetDados():New( aObjSize[2,1]	,;	// 1nTop
								 aObjSize[2,2]	,;  // 2nLelft
								 aObjSize[2,3]+5,;	// 3nBottom
	                             aObjSize[2,4]	,;	// 4nRright
								 nOpcNewGd      ,;  // 5controle do que podera ser realizado na GetDado - nstyle
								 "GP400ALinOk"	,;	// 6funcao para validar a edicao da linha - ulinhaOK
								 "GP400ATudoOk"	,;	// 7funcao para validar todas os registros da GetDados - uTudoOK
  								 NIL			,;	// 8cIniCPOS
								 aRCHAltera		,;	// 9aAlter
								 0				,; 	// 10nfreeze
								 99999			,;  // 11nMax
								 NIL			,;	// 12cFieldOK
								 NIL			,;	// 13usuperdel
								 bRCHDelOk		,;	// 14udelOK
								 @oDlg			,; 	// 15objeto de dialogo - oWnd
								 @aHeaderRCH    ,;	// 16Vetor com Colunas - AparHeader
								 @aColsRCH 	    , ;	// 17Vetor com Header - AparCols
								 NIL            ,;  // 18
								 "2")			// 19Tela 

nPosRec		:= GdfieldPos("RCH_REC_WT",oGetRCH:aHeader)	

bSet15	:= {|| nOpcAlt:= (IF(nOpc=5,2,1)), IF(oGetRCH:TudoOk(),oDlg:End(),nOpcAlt:=0), fLockRCH( xFilial("RCH"), cProcesso, , cRoteiro, ,.T.)}
bSet24	:= {|| fLockRCH( xFilial("RCH"), cProcesso, , cRoteiro, ,.T.), oDlg:End()} 

ACTIVATE MSDIALOG oDlg ON INIT Eval( bDialogInit ) 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Quando

 Confirmada a Opcao e Nao for Visualizacao Grava        ³
³                                            				   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF nOpcAlt == 1 .and. nOpc!= 2 
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Gravando/Incluido ou Excluindo Informacoes do RCH/RCF/RCG    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	GPA400Grava( 	cAlias,;			//1-Alias pai - RCH
					nOpc,;				//2-Opcao da operacao 
					nReg,;				//3-Registro pai - RCH
					,;					//4-Cols da Enchoice - RCH
					,;					//5-Clone de aEnchoice - RCH
					,;					//6-Campos virtuais da enchoice - RCG 
					,;					//7-Clone de aRCFCols - RCF
					nUsado,;			//8-Qtde de Campos usados - RCH
					aSvColsRCH,;		//9-Clone de ARCGCols - RCH
					aColsRCHRec,;		//10-Vetor com Recnos de RCH
					nPosRec	    ;
				)
EndIF


RESTAREA( aSavePosRch ) 
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Restaura os Dados de Entrada    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Return(nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fPesqPer  ºAutor  ³Microsiga           º Data ³  12/26/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesquisa periodos e posiciona da GetDados                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA400                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function fPesqPer() 
Local cPesqPer 		:= Space(TamSX3("RCH_PER") [1] )
Local cPesqPag		:= Space(TamSx3("RCH_NUMPAG")[1] )
Local nPosPer		:= 0
Local nPosSem		:= 0
Local nSavRec		:= 0 
Local lSeek	 		:= .F. 

Local oDlg 
Local oFont 
Local oGroup
Local oPesqPer 
Local oPesqNPag
Local bSet15 := {|| NIL}
Local bSet24 := {|| NIL}     

// Variaveis para Dimensionar Tela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

If fVldRoteiro()  .and.  ( Type("oGetRCH") == "O" )
	nPosPer		:= GdFieldPos("RCH_PER"   , oGetRCH:aHeader)
	nPosSem		:= GdFieldPos("RCH_NUMPAG", oGetRCH:aHeader)
	If Empty(oGetRCH:aCols[nPosPer,1]) 
		MsgAlert(oEmToansi(STR0065), OemToAnsi( STR0021 ) ) 				//-- "Nao existe periodos a ser pesquisado" 
		Return(nil) 	
	Endif 
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Salva posicao atual                                          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	nSavRec	:= oGetRCH:nAt

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aAdvSize[5] 	:= (aAdvSize[5]/100) * 57.2
	aAdvSize[6] 	:=  (aAdvSize[6]/100) * 32
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 015 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
 
    DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD 
	DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL TITLE OemToAnsi(STR0062) 			//"Pesq.Periodo "
		
		@ aObjSize[1,1]+15, aObjSize[1,2]+10 GROUP oGroup TO aObjSize[1,1]+40, aObjSize[1,2]+80  LABEL OemToAnsi(STR0068) OF oDlg PIXEL		
		oGroup:oFont:= oFont
		@ aObjSize[1,1]+25, aObjSize[1,2]+20 MSGET oPesqPer VAR cPesqPer SIZE 50,10 PIXEL  OF oDlg
				
		@ aObjSize[1,1]+15, aObjSize[1,2]+85 GROUP oGroup TO aObjSize[1,1]+40, aObjSize[1,2]+155 LABEL OemToAnsi(STR0055) OF oDlg PIXEL 	// Num Pagto 
	   	oGroup:oFont:= oFont 
		@ aObjSize[1,1]+25, aObjSize[1,2]+95 MSGET oPesqNPag VAR cPesqPag SIZE 50,10 PIXEL OF oDlg 
				
		bSet15 := { || nOpcA := 1, lSeek := .T., oDlg:End()}
		bSet24 := { || nOpcA := 0 , oDlg:End() }
		
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) 
	
	If lSeek 
		nPosPer		:= GdFieldPos("RCH_PER"   , oGetRCH:aHeader)
		nPosSem		:= GdFieldPos("RCH_NUMPAG", oGetRCH:aHeader) 
		If ( nPos:= Ascan(oGetRCH:aCols, {|x| x[nPosPer] + x[nPosSem] = cPesqPer + cPesqPag }  )  ) > 0 
			oGetRCH:Goto(nPos) 
		Else        
			oGetRCH:nAt 
		Endif      
		oGetRCH:Refresh() 
	Endif 
Endif 

Return Nil 

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³GPA400Grava  ³Autor³Natie Sugahara    1a V³ Data ³18/06/2002³
³          ³             ³Autor³Mauricio Takakura 2a V³ Data ³28/06/2004³
³          ³             ³Autor³Natie Sugahara    3a V³ Data ³01/09/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³GPA400()	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function GPA400Grava(	cAlias,;			//Alias do arquivo principal - RCH
								nOpc,;				//Opcao de Acordo com aRotina
							 	nReg,;				//Numero do Registro do Arquivo Pai ( RCH )
							 	aColsEnChoice,;		//Cols da Enchoice - RCH
							 	aSvEnchoice,;		//Clone do Vetor aEnchoice - para comparacao
							 	aRCHVirtChoice,;	//Campos Virtuais do Arquivo Pai ( RCH )
							 	aRCFSvCols,;		//Clone de aRCFCols - RCF
								nRCFUsado,;			//Qtde de Campos usados - RCF
								aSvCols,;			//Clone de aCols
								aColsRec, ;	   		//Vetor com os Recnos 
								nPosRec	; 				
						   )

// variaveis auxiliares //
Local nChoice			:= 0				//variavel utilizada para for/while
Local nX				:= 0				//utilizado em While/For
Local nY				:= 0				//utilizado em While/For
Local lTravou			:= .F. 
Local aColsRCH 			:= {} 

DEFAULT nOpc			:= 0.00			//opcao do menu selecionado
DEFAULT nReg			:= 0.00			//recno do registro pai
DEFAULT aRCHVirtChoice	:= {}			//campos virtuais da tabela pai - RCH

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Utiliza Modelo Para Grandes Empresas - Tela com  Processos / Roteiros
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
nHeadersRCH	:= Len(oGetRCH:aHeader) 
aColsRCH 	:= aClone(oGetRCH:aCols) 
nCols		:= Len(oGetRCH:aCols) 

/* 
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Se for Inclusao/Alteracao ( nOpc == 3 )	                   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF ( nOpc == 3 ) 
	dbSelectArea("RCH") 
	Begin Transaction  
		For nX := 1 To nCols 
			lTravou:=.F.
			If aColsRCH[nX][nPosRec] > 0 
		    	DBGoto(aColsRCH[nX][nPosRec]) 
				RecLock("RCH", .F.,.T.) 
				lTravou:=.T.  
			Else 
				If !(aColsRCH[nX][Len(aColsRCH[nX])])  
					RecLock("RCH",.T.)  
					lTravou:=.T.  
				EndIf
			Endif
	
			If lTravou
		        //--Verifica se esta deletado 
				If aColsRCH[nX][Len(aColsRCH[nX])] 
					dbDelete()
				Else 
					RCH->RCH_FILIAL := cFilRCH
					RCH->RCH_PROCES := cProcesso
					RCH->RCH_ROTEIR := cRoteiroAnt 
					RCH->RCH_PDPERI := cPdPeriodAnt
				Endif 
					For nY := 1 To nHeadersRCH
					cCampo    := Trim(oGetRCH:aHeader[nY][2]) 
					xConteudo := aColsRCH[nX,nY]
					If cCampo == "RCH_REC_WT" .and. xConteudo = 0 
						nPosRecWt	:= GdfieldPos("RCH_REC_WT" , oGetRCH:aHeader) 
						xConteudo 	:= RCH->(Recno())  
					Else  
						If cCampo == "RCH_MODULO"
							xConteudo := cModulo							
						Else 	 
							xConteudo := aColsRCH[nX,nY] 
						EndIf 
					Endif
					 	 
					&cCampo 	:= xConteudo 
					Next nY
			Endif 	
			RCH->( MsUnlock() )
		Next nX
	End Transaction 
Endif 

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³GPA400INC ³ Autor ³Natie Sugahara         ³ Data ³18/06/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Reinicializa nReg e Posiciona Ponteiro no Final do Arquivo  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³GPA400INC( nReg )											³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³nReg -> Registro Corrente									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPA400()	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function GPA400Inc( nReg ) 

RCH->( dbGoBottom() )
RCH->( dbSkip() )
nReg := 0.00 

Return( NIL ) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fNewAcols ³ Autor ³ Natie Sugahara      	³ Data ³ 01/12/03 |±±
±±³          ³          ³ Autor ³Mauricio Takakura 2a V ³ Data ³28/06/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna Dia da Semana                              		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function  fNewAcols(cTipo		,;		//Tipo do acols 
						aNotFields 		,;		//Campos nao visuais de RCG
						nUsado			,;		//Numero de campos usados - RCG
						dDataIni		,;		//data inicial para cadastro de dias
						dDataFim		,;		//data final para cadastro de dias
						nHrsDia		 	;		//numero de horas          
								)

Local aColsAux		:= {}
Local aRelacaoNew	:= {}

Local cAliasAtu 	:= ""						//alias da tabela
Local nDias 		:= 0						//numero de dias a contabilizar
Local dData			:= CtoD("//") 				//variavel que incluira as datas necessarias
Local aAreaRCF		:= {}						//area de RCF
Local nCnt			:= 0						//variavel de controle - For/While
Local nTam			:= 0 

Local nPosDiaMes	:= 0                                  

Local nPosDesdia	:= 0
Local nPosTipdia	:= 0
Local nPosVTrans	:= 0
Local nPosDifTra	:= 0
Local nPosvRefei	:= 0
Local nPosHrsTra	:= 0
Local nPosHrsDsr	:= 0
Local nPosGhost		:= 0 

Local nPosPer		:= 0 
Local nPosNPag		:= 0
Local nPosPro		:= 0
Local nPosRot		:= 0
Local nPosMes		:= 0
Local nPosAno		:= 0
Local nPosDtIni		:= 0
Local nPosDtFim		:= 0
Local nPosDtPag 	:= 0
Local nPosDtCort 	:= 0
Local nPosPdPeri 	:= 0 
Local nPosMod		:= 0 
Local nPosCrit  	:= 0
Local nPosSequ   	:= 0
Local nPosAli		:= 0
Local nPosRecWt		:= 0
Local nX			:= 0 

Local nPer			:= 0 
Local _aColsRCh   	:= {} 

	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Utiliza Modelo Para Grandes Empresas - Tela com  Processos / Roteiros
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
cAliasAtu 	:= "RCH"									//alias da tabela	
nTam		:= Len(oGetRCH:aHeader)+1
nPosPer		:= GdFieldPos("RCH_PER"    , oGetRCH:aHeader)
nPosNPag	:= GdFieldPos("RCH_NUMPAG" , oGetRCH:aHeader)
nPosMes		:= GdFieldPos("RCH_MES"    , oGetRCH:aHeader)
nPosAno		:= GdFieldPos("RCH_ANO"    , oGetRCH:aHeader)
nPosDtIni	:= GdFieldPos("RCH_DTINI"  , oGetRCH:aHeader)
nPosDtFim	:= GdFieldPos("RCH_DTFIM"  , oGetRCH:aHeader)
nPosDtPag 	:= GdFieldPos("RCH_DTPAGO" , oGetRCH:aHeader) 
nPosDtCort	:= GdFieldPos("RCH_DTCORT" , oGetRCH:aHeader)
nPosMod   	:= GdFieldPos("RCH_MODULO" , oGetRCH:aHeader)
nPosPdPeri 	:= GdFieldPos("RCH_PDPERI" , oGetRCH:aHeader)
nPosCrit  	:= GdFieldPos("RCH_CRITER" , oGetRCH:aHeader)
nPosSequ   	:= GdFieldPos("RCH_SEQUE"  , oGetRCH:aHeader)
nPosGhost	:= GdFieldPos("GHOSTCOL"   , oGetRCH:aHeader)
nPosAli		:= GdfieldPos("RCH_ALI_WT" , oGetRCH:aHeader)
nPosRecWt	:= GdfieldPos("RCH_REC_WT" , oGetRCH:aHeader)
     
nPer		:= Len(aRG6) 
aColsAux	:= Array(nPer, nTam )

aRelacaoNew := GdRmkaCols(	oGetRCH:aHeader, .F.,	.T., .T. )

For nX := 1 to nPer

	nUsado 	:= 0 
	dbSelectArea("SX3")
	dbSetOrder(1)
	SX3->(dbSeek("RCH")) 
	While !Eof() .and. X3_ARQUIVO == cAliasAtu 
		If x3uso(X3_USADO) .and. cNivel >= X3_NIVEL  .and. !aScan(aNotFields,AllTrim(X3_CAMPO)) > 0 
			If 	alltrim(X3_CAMPO) == "RCH_PDPERI" .and. nPosPdPeri > 0 
				aColsAux[nX, nPosPdPeri]	:= aRG6[nX, 1]                                   		//-- Pad.Periodo 
			ElseIf alltrim(X3_CAMPO) == "RCH_PER" .AND. nPosPer > 0
				aColsAux[nX, nPosPer]		:= aRG6[nX, 2]											//-- Ex.: 200701 
			ElseIF alltrim(X3_CAMPO) == "RCH_NUMPAG" .AND. nPosNPag > 0
				aColsAux[nX, nPosNPag]		:= aRG6[nX, 3]                       					//-- No Pagto
			Elseif alltrim(X3_CAMPO) == "RCH_MES"	.AND. nPosMes > 0
				aColsAux[nX, nPosMes]		:= aRG6[nX, 4] 					 						//-- Mes
			Elseif alltrim(X3_CAMPO) == "RCH_ANO" .AND. nPosAno > 0 	
				aColsAux[nX, nPosAno]		:= aRG6[nX, 5]											//-- Ano 		
			Elseif alltrim(X3_CAMPO) == "RCH_DTINI"	 .AND. nPosDtIni > 0 
				aColsAux[nX, nPosDtIni]		:= aRG6[nX, 6]											//-- Dt Inicio Periodo
			Elseif alltrim(X3_CAMPO) == "RCH_DTFIM"	 .AND. nPosDtFim > 0 
				aColsAux[nX, nPosDtFim]		:= aRG6[nX, 7]											//-- Dt Fim  Periodo
			ElseIf 	alltrim(X3_CAMPO) == "RCH_DTPAGO" .AND. nPosDtFim > 0	
				aColsAux[nX, nPosDtPag]		:= aRG6[nX, 8]											//-- Data de pagto
			ElseIf 	alltrim(X3_CAMPO) == "RCH_DTCORT" .AND. nPosDtCort > 0 
				aColsAux[nX, nPosDtCort]	:= aRG6[nX, 9]								  			//-- Data de Corte 
			ElseIf 	alltrim(X3_CAMPO) == "RCH_CRITER" .AND. nPosCrit> 0  
				aColsAux[nX, nPosCrit]		:= aRG6[nX, 10]                                   		//-- Criterio 
			ElseIf 	alltrim(X3_CAMPO) == "RCH_SEQUE" .AND. nPosSequ > 0  
				aColsAux[nX, nPosSequ]		:= aRG6[nX, 11]                                   		//-- Sequencia 
			ElseIf 	alltrim(X3_CAMPO) == "RCH_MODULO" .AND. nPosMod > 0  
				aColsAux[nX, nPosMod]		:= aRG6[nX, 12]                                   		//-- Modulo 
			Else
				nUsado := GdfieldPos(X3_CAMPO , oGetRCH:aHeader)
				If nUsado > 0  
					aColsAux[nX,nUsado] := aRelacaoNew[1,nUsado]
				EndIf
			Endif
			
		Endif
		SX3->(dbSkip())
	EndDo
	If nPosAli > 0
		aColsAux[nX,nPosAli] := cAliasAtu
	EndIf
	If nPosRecWt > 0 
		aColsAux[nX,nPosRecWt] := 0
	EndIf 
 	aColsAux[nX,nPosGhost] 	 := StrZero(0,10)
	aColsAux[nX,nTam       ] := .F.	
Next nX

Return(aClone(aColsAux) ) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fRoteProc ³ Autor ³ Natie Sugahara      	³ Data ³ 04/10/07 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se existe um  roteiro por processo cadastrado 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function  fRotProc( )
Local aArea			:= GetArea() 
Local lTemRotproc 	:= .F. 

aRotProc	:= {}

dbSelectArea("RGA")
If RGA->(dbSeek( xFilial("RGA") + cProcesso + cRoteiro  ) ) 
	aadd( aRotProc, {RGA_FILIAL + RGA_PROCES + RGA_CALCUL,RGA_PDPERI,RGA_DTINIC, RGA_TOLEPG,RGA_TOLECT, RGA_MODULO} ) 
	lTemRotproc	:= .T.
	cPdPeriodo		:= RGA->RGA_PDPERI
	cDescPdPeriodo  := " - " +  fDesc("RG5",RGA->RGA_PDPERI, "RG5_DESCRI") 
	If !Empty(RGA->RGA_PDPERI) .And. !Empty(RG5->RG5_PDPERI)
		lTemPadrao	:= .T. 
	Endif 	
Else 
	cPdPeriodo		:= SPACE(TamSX3("RGA_PDPERI")[1])
	cDescPdPeriodo  := SPACE(30) 
	lTemPadrao		:= .F. 
	lTemRotproc		:= .F.
Endif 

RestArea(aArea) 
Return ( lTemRotproc ) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fCarPdRG6 ³ Autor ³ Natie Sugahara      	³ Data ³ 04/10/07 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega vetor para montar Periodos                   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function  fCarPdRG6() 

Local aArea		:= GetArea()
Local ckey		:= xFilial("RG6")+ cPdPeriodo
Local lRet		:= .F. 

Local nCnt		:= 0 
Local dDtIni	:= ctod("//")
Local nDpagto	:= 0
Local nDCorte	:= 0
Local cModuloRG6:= ""
                              
If Empty(aRotProc)
	RestArea(aArea)
	Return (lRet)
Endif

dDtIni		:= aRotProc[1,3]
nDpagto		:= aRotProc[1,4]
nDCorte		:= aRotProc[1,5]
cModuloRG6	:= aRotProc[1,6]

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carrega vetor para montar Periodos - RG6                     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
dbSelectArea("RG6")
RG6->(DbSetOrder(2))
If RG6->(dbSeek( cKey  ) )  
	aRG6	:= {}
	While RG6->( !Eof() .and. RG6_FILIAL + RG6_PDPERI = cKey )
		nCnt ++	
		dDtFim	:= dDtIni + RG6_DIAPER - 1
		
		aadd(aRG6,{ RG6_PDPERI,;   								//-- 01 Pd periodo
		            STRZERO(year(dDtIni),4) + RG6_CODIGO,;		//-- 02 Codigo periodo 200701 
		            RG6_NUMPAG,; 								//-- 03 Num pagto 
		            RG6_CODIGO,;								//-- 04 Mes 
		            Strzero(Year(dDtIni), 4),; 					//-- 05 Ano 
		            dDtIni,;									//-- 06 Dt Inic 
		            dDtFim,;									//-- 07 Dt fim  
		            (dDtFim + nDPagto),; 						//-- 08 Dt Pagto 
		            (dDtFim + nDCorte),;						//-- 09 Dt corte
					RG6_CRITER,; 								//-- 10 Criterio 
					RG6_SEQUE,; 								//-- 11 Sequencias 
		            cModuloRG6,;								//-- 12 Modulo 
		            RG6_DIAPER,;								//-- 13 Dias Periodo
		            RG6_CODIGO })								//-- 14 Codigo
		            
		            
		dDtIni 	:= ( dDtIni + RG6_DIAPER )
		RG6->(DbSkip() )
	Enddo
	lRet	:= .T. 
Endif 

RestArea(aArea)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³VldDtIni 	³ Autor ³ Natie Sugahara      	³ Data ³ 01/12/03 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica Data inical e compativel com Competencia          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function X_VldDtIni(dDtIni,dDtFim,cMes,cAno) 

Local nPosDtFim	:= 0 
Local nPosDtFech:= 0 
Local nPosPdPeri := 0 

If ( Type("oGetRCH") == "O" ) 

	nPosDtFim	:= GdFieldPos("RCH_DTFIM", oGetRCh:aHeader) 
	nPosDtFech	:= GdFieldPos("RCH_DTFECH",oGetRCh:aHeader) 
	nPosPdPeri 	:= GdFieldPos("RCH_PDPERI",oGetRCh:aHeader) 
	
	if Len(oGetRCh:aCols) > 1
		dDtFim		:= oGetRCh:aCols[oGetRCh:nAt, nPosDTFim] 
	EndIf
	/* 
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Validacao do Campo Data Inicial                                                    |
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If nPosDTFech>0 .and.  !Empty(oGetRCh:aCols[oGetRCh:nAt, nPosDTFech] )
		MsgAlert( OemToAnsi( STR0047 ) , OemToAnsi( STR0021 ) ) 				//--"Este periodo ja foi encerrado e nao sera possivel a manutencao deste campo" 
		Return(.F.)
	Endif 
Endif 

/* 
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Validacao do Campo Data Inicial                                                    |
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !Empty(dDtIni) .And. !Empty(dDtFim)
	If dDtIni > dDtFim 
		Help(" ",1,"DATA2INVAL")    	// A Data de Fim nao pode ser menor do que a Data de Inicio.
		Return(.F.)
	EndIf
EndIf

Return(.T.)

/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³VldDtFim	³ Autor ³ Natie Sugahara      	³ Data ³ 01/12/03 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica Data Fim eh maior que a Dt Inicial e			  ³±±
±±|          ³ se a Data Final eh compativel com  a Competencia           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function X_VldDtFim(dDtIni, dDtFim, cMes, cAno) 
Local cAlias 	:= Alias()
Local nPosDtIni	:= 0
Local nPosDtFech:= 0
Local nPosPdPeri := 0 

	
If ( Type("oGetRCH") == "O" )
	nPosDtIni	:= GdFieldPos("RCH_DTINI", oGetRCh:aHeader) 
	nPosDtFech	:= GdFieldPos("RCH_DTFECH", oGetRCh:aHeader) 
	nPosPdPeri 	:= GdFieldPos("RCH_PDPERI",oGetRCh:aHeader) 
	If nPosDtIni <> 0
		dDtIni		:= oGetRCh:aCols[oGetRCh:nAt, nPosDTIni]
	EndIf
	/* 
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Validacao do Campo Data Final                                                      |
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If nPosDTFech > 0 .and. !Empty(oGetRCh:aCols[oGetRCh:nAt, nPosDTFech] )
		MsgAlert( OemToAnsi( STR0047 ) , OemToAnsi( STR0021 ) ) 				//--"Este periodo ja foi encerrado e nao sera possivel a manutencao deste campo" 
		Return(.F.)
	Endif 	
Endif 

If !Empty(dDtIni) .And. !Empty(dDtFim)
	If dDtFim < dDtIni
		Help(" ",1,"DATA2INVAL")    	// A Data de Fim nao pode ser menor do que a Data de Inicio
		Return(.F.) 
	Endif	
Endif
dbSelectArea( cAlias )

Return(.T.)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡ao    ³ValidEnch     ³Autor³Mauricio T. Takakura ³ Data ³27/07/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡ao ³Validacao da Enchoice               						³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³ValidEnch                                                   ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function ValidEnch(oObject, nOpc) 	// validacao da enchoice
Local cVar	:= ''					// nome das variaveis 
Local nP 	:= 0					// variavel utilizada em while/for

If !lValEnchoice
	If !( lValEnchoice := Obrigatorio( oEnchoice:aGets , oEnchoice:aTela ) ) // obrigatorio - verifica se todos os campos obrigatorios foram preenchidos
		oEnchoice:aEntryCtrls[ 1 ]:SetFocus()
	EndIf

		lValEnchoice := EnchoTudOk(	oEnchoice,;							//Objeto a validar
									NIL,;								//Array com campos a validar
									{"RCH_CRITER", "RCH_SEQUE"},;		//Array com campos que nao serao validados
									.F. )								//Se ira ocultar a Enchoice durante a validacao
	
	// atualizar as variaveis do vetor para comparacao //
	For nP := 1 To Len(aEnchoice)
	    cVar := "M->"+aEnchoice[ nP , 02 ]
		aRCHDados[1,nP] := &cVar			
	Next nLoop
	If lValEnchoice
		oObject:oBrowse:SetFocus()
	EndIf
Else
	// comparar o vetor para checar se foi alterado algum valor para executar a validacao do EnchoTudOK //
	For nP := 1 To Len(aEnchoice)
	    cVar := "M->"+aEnchoice[ nP , 02 ]
		If aRCHDados[1,nP] != &cVar
			lValEnchoice := .F.
		Endif
	Next nLoop
	
	If !lValEnchoice
		ValidEnch(oObject)
	Endif

	If nOpc == 3
		RCH->(dbSeek( cFilRCH + M->RCH_PROCES + M->RCH_PER + M->RCH_NUMPAG + M->RCH_ROTEIR ))	
		If !(lValEnchoice := RCH->(EOF()))
	  		Help("",1,"EXISTCHAV")		// Chave ja Existente 
			oEnchoice:aEntryCtrls[ 1 ]:SetFocus()  		
		EndIf
	EndIf
Endif
Return lValEnchoice

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA400   ºAutor  ³Microsiga           º Data ³  11/21/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controle dos Registros Deletados RCH                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA400                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Gp400RCHDelOk() 

Local cKey 			:= ""
Local lDelOk 		:= .T.		//Controle de Retorno
Local nPosPer		:= GdFieldPos("RCH_PER"    ,oGetRCH:aHeader) 
Local nPosNPag		:= GdFieldPos("RCH_NUMPAG" ,oGetRCH:aHeader) 
Local nPosDtFech 	:= GdFieldPos("RCH_DTFECH" ,oGetRCH:aHeader)
Local nPosRec		:= GdfieldPos("RCH_REC_WT" ,oGetRCH:aHeader)
Local lDelRCH:=.T.

IF(oGetRCH:aCols[ oGetRch:oBrowse:nAt, Len(aHeaderRCHSF)+1]==.T. )  
	lDelRCH:=.F.     //atualiza o sColsRCHSF com deletado
EndIf	

Begin Sequence 
	If !Empty( oGetRCH:aCols[oGetRCH:nAt,nPosDtFech])
		MsgAlert( OemToAnsi( STR0037 ) , OemToAnsi( STR0021 ) ) 				//"Periodo ja possui data de fechamento. Nao sera possivel efetuar a delecao/alteracao" 
		lDelOK:= .F. 
	Else 
	                                       
		/* 
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Verifica se é possivel deletar o periodo                      ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 
		cKey := cProcesso  +  oGetRCH:aCols[oGetRCH:nAt, nPosPer] + oGetRCH:aCols[oGetRCH:nAt, nPosNPag] +cRoteiro 
		                                                         
		// verificar se a tabela nao possui registros relacionados //
		lDelOK  := ChkDelRegs(	'RCH'				,;	// 1-Alias do Arquivo Principal
								oGetRCH:Acols[oGetRCH:nAt,nPosRec],;	// 2-Registro do Arquivo Principal
								3					,;	// 3-Opcao para a AxDeleta
								xFilial( "RCH" )	,;	// 4-Filial do Arquivo principal para Delecao
								cKey				,;	// 5-Chave do Arquivo Principal para Delecao
								NIL 				,;	// 6-Array contendo informacoes dos arquivos a serem pesquisados
								NIL					,;	// 7-Mensagem para MsgYesNo
								NIL					,;	// 8-Titulo do Log de Delecao
								NIL					,;	// 9-Mensagem para o corpo do Log
								.F.				 	,;	// 10-Se executa AxDeleta
								.F.     			,;	// 11-Se deve Mostrar o Log
								NIL					,;	// 12-Array com o Log de Exclusao
								NIL				 	,;	// 13-Array com o Titulo do Log
								NIL					,;	// 14-Bloco para Posicionamento no Arquivo
								NIL					,;	// 15-Bloco para a Condicao While
								NIL					,;	// 16-Bloco para Skip/Loop no While
								.T.					,;	// 17-Verifica os Relacionamentos no SX9
								{"RCI"}	   			,;	// 18-Alias que nao deverao ser Verificados no SX9
								NIL				 	 ;	// 19-Se faz uma checagem soft
							 )
							 
		IF !lDelOK
			MsgAlert( OemToAnsi( STR0039 ) , OemToAnsi( STR0021 ) ) 				//""O periodo nao pode ser excluido. Verifique as tabelas relacionadas. "
			lDelOk 	:= .F. 
		Endif
	Endif 
End Sequence  

 AtualDelColsRCHSF(lDelRCH) 	

Return( lDelOK)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Gp400TrocaPer ºAutor  ³Microsiga           º Data ³  10/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                                º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Gp400TrocaPer(bChange,nOption)

Local lRet := .T.

If (nOption == 2)
	Eval(bChange)
Else
	If fLockRCH( xFilial("RCH"), cProcesso, , cRoteiro, )
		fLockRCH( xFilial("RCH"), cProcesso, , cRoteiroAnt, ,.T.)
		Eval(bChange)
	Else
		cRoteiro := cRoteiroAnt
	EndIf
EndIf

Return (lRet) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp400ALinOk³ Autor ³ Natie                 ³ Data ³ 11/09/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpea400                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp400ALinOk(oBrowse)

Local aCposKey		:= {}												//Vetor com as chaves de busca
Local aCols_Aux		:= oGetRCH:aCols
Local cMsg			:= "" 
Local lLinOk		:= .T.												//Variavel para controle de Retorno
Local nPos			:= 0
Local nHeaders		:= Len(oGetRCH:aHeader)+1 
Local nPosPer		:= GdFieldPos("RCH_PER"    , oGetRCH:aHeader)		// RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG 
Local nPosNPag		:= GdFieldPos("RCH_NUMPAG" , oGetRCH:aHeader)     
Local nPosCrit		:= GdFieldPos("RCH_CRITER" , oGetRCH:aHeader)
Local nPosSeque		:= GdFieldPos("RCH_SEQUE"  , oGetRCH:aHeader)
Local nPosPerSel	:= GdFieldPos("RCH_PERSEL" , oGetRCh:aHeader)

Begin Sequence 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Verifica Itens deletados                        			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !aCols_Aux[ oGetRCH:nAT,nHeaders ] 

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica Se o Campos Estao Devidamente Preenchidos		   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aadd(aCposKey, "RCH_PER")
	aadd(aCposKey, "RCH_DTINI")
	aadd(aCposKey, "RCH_DTFIM")
	aadd(aCposKey, "RCH_DTPAGO")
	aadd(aCposKey, "RCH_DTCORT") 
	aadd(aCposKey, "RCH_MES")
	aadd(aCposKey, "RCH_ANO") 
	
	IF !( lLinOk := GdNoEmpty( aCposKey, oGetRCH:nAT, oGetRCH:aHeader, oGetRCH:aCols,  ) )	
		Break 
	EndIf 
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica Itens Duplicados na GetDados						   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aCposKey := {} 
	aadd(aCposKey, "RCH_PROCES")
	aadd(aCposKey, "RCH_ROTEIR")
	aadd(aCposKey, "RCH_PER")
	aadd(aCposKey, "RCH_NUMPAG") 
	IF !( lLinOk := GdCheckKey( aCposKey , 4 ) )
		Break
	EndIF
	    
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica Se a chave processo+roteiro+periodo+Numpag esta dupl³
	³ icada em com outro modulo                                    ³	
	³ Esta verificacao e necessaria pois na chave unica nao eh pos ³	
	³ sivel colocar o RCH_MODULO (x3_tela=2)por conta do modelo "1"³
	³ O roteiro de calculo eh diferente p/cada modulo, porem nao te³	
	³ mos o cpo roteiro na Tab.de Roteiros o q impossibilita filtra³	
	³ lo no cad. de periodos e possibilita o cadastramento de chave³
	³ duplicada processo+roteiro+periodo + Numpag                  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/     
	    
	IF !( lLinOk := fChkDuplKey( oGetRCH:aCols[oBrowse:nAT,nPosPer] , oGetRCH:aCols[oBrowse:nAT,nPosNPag], @cMsg ) )
		MsgAlert(cMsg + CRLF+ CRLF +  ; 							//-- " Esse período já esta sendo utilizado pelo Módulo xxx. 
		         OemToansi(STR0074), OemToAnsi( STR0021 ) ) 		//-- Consulte Administrador do sistema. 		
		Break
	EndIF 
	
	//Verifica se existe sequencia informada e critério em branco
	If !Empty( oGetRCH:aCols[oBrowse:nAT,nPosSeque] ) .And. Empty( oGetRCH:aCols[oBrowse:nAT,nPosCrit] )                 
		MsgAlert(OemToansi(STR0103),  OemToAnsi( STR0021 ) ) 		//-- Consulte Administrador do sistema. 				
		lLinOk := .F.
		Break
	Endif                                                                                                                  
	
	If lLinOk	
		M->RCH_SEQUE  := ""
		M->RCH_CRITER := ""     
		lF3Criter	  := .F.		
	Endif
Endif

End Sequence 
Return( lLinOk )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fChkDuplKey  ºAutor  ³Microsiga           º Data ³  06/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe chave duplicada em outro modulo             º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function  fChkDuplKey(cCodper, cCodNumPag, cMsg ) 
Local aAreaRCH		:= RCH->(GetArea()) 
Local lRetOk		:= .T. 
Local cAliasRCH		:= "RCH" 
Local cQuery		:= ""
Local cModuloAux	:= ""
Local nCnt	   		:= 0 
Local lFwSPF    	:= FindFunction("FwOnSpFilter")
Local nX			:=  0

Local nPosRecno	:= GdfieldPos("RCH_REC_WT",oGetRCH:aHeader)
                                                                                                      
Local nPosPeriodo	:=	GdfieldPos("RCH_PER"		,	aHeaderRCHSF)
Local nPosPagamento	:=	GdfieldPos("RCH_NUMPAG"	,	aHeaderRCHSF)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe chave duplicada em outro modulo                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP 
	cAliasRCH	:= "QRCH" 
	cQuery := " SELECT RCH.RCH_MODULO, COUNT(*) TOTAL " 
	cQuery += " FROM "+	RetSqlName("RCH")  + " RCH "
	cQuery += " WHERE RCH.RCH_FILIAL = '" + xFilial("RCH")+ "' AND " 
	cQuery += "       RCH.RCH_PROCES = '" + cProcesso     + "' AND " 
	cQuery += "       RCH.RCH_ROTEIR = '" + cRoteiro      + "' AND " 
	cQuery += "       RCH.RCH_PER    = '" + cCodPer       + "' AND " 	
	cQuery += "       RCH.RCH_NUMPAG = '" + cCodNumpag    + "' AND " 	
	cQuery += "       RCH.RCH_MODULO <>'" + cModulo       + "' AND " 
	If TcSrvType() != "AS/400" 
		cQuery += " D_E_L_E_T_ <> '*' "
	Else
		cQuery += " @DELETED@ <> '*' " 
	EndIf
	cQuery += " GROUP BY RCH.RCH_MODULO " 
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasRCH, .F., .T.)
	dbSelectArea(cAliasRCH) 
	nCnt		:= (cAliasRCH)->TOTAL 
	cModuloAux	:= (cAliasRCH)->(RCH_MODULO)
	(cAliasRCH)->(	dbCloseArea())
#ELSE
	cKey	:= ( xFilial(cAliasRCH) + cProcesso + cRoteiro + cCodPer + cCodNumPag )
	(cAliasRCH)->(DbSeek(cKey)) 
	If !eof() .and. (cAliasRCH)->RCH_MODULO <> cModulo 
		cModuloAux	:= (cAliasRCH)->RCH_MODULO 
		nCnt++
	Endif 
#ENDIF  
        
If nCnt > 0 
	cMsg	:= oemToansi(STR0073) + cModuloAux 
	lRetOk	:= .F. 
Endif            

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ esta parte do fonte alterado porque o aColsRCH estava com superfiltro,   ³ 
//³no momento que o usuario alterava qualquer parte do registro o sistema    ³ 
//³não deixava gravar porque entendia que registro estava duplicado,         ³
//³pois por definição o SuperFiltro filtra filial para todos os usuarios     ³
//³execeto o Administrador, foi criado uma função que monta um aColsRCHSF    ³
//³sem superfiltro, para que o usuario consegui-se alterar o registro        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
If lFwSPF //verifica se existe a funcao do superfiltro.
	If (lRetOk .AND. FwOnSpFilter("RCH")  )       //Verifica se tem Superfiltro para RCH
		If Empty(oGetRCH:aCols[ oGetRch:oBrowse:nAt, nPosRecno ]) .And. oGetRCH:aCols[ oGetRch:oBrowse:nAt, Len(aHeaderRCHSF)+1]==.F.
			For nx:=1 to Len(aColsRCHSF)
 				If  (Alltrim(cCodPer) + Alltrim(cCodNumPag) ==  Alltrim(aColsRCHSF[nx,nPosPeriodo])+ Alltrim(aColsRCHSF[nx,nPosPagamento])) 	 
					If aColsRCHSF[nX,Len(aHeaderRCHSF)+1]== .F.
						lRetOk := .F. 
						cMsg   := oemToansi(STR0092)//Registro já gravado 
					EndIf	
   				EndIf
 			Next nx
 		EndIf
	EndIf
Endif
RestArea(aAreaRCH) 
Return(lRetOk) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp400TudOk³ Autor ³ Natie                 ³ Data ³ 11/09/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpea400                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp400ATudoOk(oBrowse)

Local lTudoOk	:= .T.		//variavel para controle de Retorno
Local nX 		:= 0		//variavel while/for
Local lOnePerSelect := .F. //Indica se pelo menos um periodo foi selecionado
Local nPosPerSelect := gdFieldPos("RCH_PERSEL", oGetRch:aHeader)
Local nSavePosition	:= oGetRCH:nAt

For nX := 1 To Len(oGetRCH:aCols)
	If !Empty(GdFieldGet( "RCH_PER" , nX , NIL , oGetRCH:aHeader, oGetRCH:aCols ))
		oGetRCH:nAt := nX
	 	If !(lTudoOk := gp400ALinOk(oBrowse))
			Exit
	 	EndIf
	 	
	 	If (oGetRCH:aCols[ nX, nPosPerSelect] == "1")   
	 		lOnePerSelect := .T.
	 	EndIf
    EndIf
Next nX      

If !lTudoOK
	oGetRCH:Goto( oGetRCH:nAt )	
	Eval( oGetRCH:bChange )
EndIf

If !(lOnePerSelect) .And. oGetRCH:aCols[ oGetRch:oBrowse:nAt, Len(aHeaderRCHSF)+1]==.F.
	msgInfo( OemToAnsi(STR0086) )
	oGetRch:nAt := nSavePosition
	oGetRch:Refresh()
	lTudoOk := .F.
EndIf             

Return(lTudoOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp400Monta³ Autor ³ Natie                 ³ Data ³ 11/09/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta aCols do RCH                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpea400                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function Gp400MontaCols(nOpc,cAlias,cProcesso, cRoteiro, cPdPeriodo, aRCHAltera , aHeaderRCH, aColsRCH   ,nOpc ,aColsRCHRec   , aRCHNotFields , nUsado, nPosRec, nReg, lGrava )  

Local cFilAtu			:= If(nOpc = 4 ,xFilial("RCH") , xFilial("RCJ") )  //- se exclusao, utiliza RCH 
Local nRCHUsado			:= 0 		//Numero de Campos em Uso
Local nX				:= 0
Local nY 				:= 0 
Local nPos				:= 0 
Local nTam				:= 0 
Local nPosPer			:= 0
Local nPosProc			:= 0
Local nPosRoteiro		:= 0
Local nPosDtIni			:= 0
Local nPosPdPeri 		:= 0
Local nPosPerSel		:= 0
Local nPosSem			:= 0

Local lRetOK 			:= .T.   

Local cCampo    		:= ""
Local cQuery 			:= 0 
Local xConteudo 	

Local cKeySeek_	 		:= "" 
Local aCols				:= {} 		//
Local aRCHVirtGd		:= {} 		//03 -> [@]Array com os Campos Virtuais
Local aRCHVisualGd		:= {} 		//04 -> [@]Array com os Campos Visuais
Local bKey				:= {||Nil} 

Default lGrava 			:= .F. 

#IFDEF TOP 

	If TcSrvType() != "AS/400" 
		cQuery := "  RCH_PROCES = '" + cProcesso + "'"  
		cQuery += " AND " 
		cQuery += "  RCH_ROTEIR = '" + cRoteiro  + "'" 
		cQuery += " AND " 
		cQuery += "  RCH_FILIAL = '" + cFilAtu   + "'" 
		cQuery += " AND "                              
		cQuery += "  RCH_MODULO = '" + cModulo   + "'" 
		cQuery += " AND " 
		If nOpc = 4	 											//-- Exclusao
			cQuery += "  RCH_PDPERI = '" + cPdperiodo + "'" 
			cQuery += " AND "   
			cQuery += "  RCH_DTINI >= '" + DtoS(dParDtIni) + "'"
			cQuery += " AND "   			
		Endif 
		cQuery += " D_E_L_E_T_ <> '*' "
	Else
		cQuery := NIL
	EndIf 
#ENDIF 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Pergunta se deve efetuar a gravacao                   	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If lGrava .and. !Empty(oGetRCH:aCols) .and. !fCompArray(oGetRCH:aCols , aSvColsRCH) 
	If (MsgYesNo( OemToAnsi( STR0041 ) ) )	  	//--"Deseja salvar as alteracoes?"
		MsAguarde( { || GPA400Grava( 	cAlias,;//1-Alias pai - RCH
					nOpc,;				//2-Opcao da operacao 
					nReg,;				//3-Registro pai - RCH
					,;					//4-Cols da Enchoice - RCH
					,;					//5-Clone de aEnchoice - RCH
					,;					//6-Campos virtuais da enchoice - RCG 
					,;					//7-Clone de aRCFCols - RCF
					nUsado,;			//8-Qtde de Campos usados - RCH
					aSvColsRCH,;		//9-Clone de ARCGCols - RCH
					aColsRCHRec,;		//10-Vetor com Recnos de RCH
					nPosRec	    ;
				) }, OemToAnsi(STR0024))
	Endif 
Endif 

DbSelectArea( "RCH" )
DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG") ) 

cKeySeek_ 	 	:= ( cFilAtu + cProcesso + cRoteiro )
bKey			:= { |cKey| RCH->(RCH_FILIAL+ RCH_PROCES + RCH_ROTEIR)   == cKeySeek_  } 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta aCols RCH                                          	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdd( aRCHNotFields, "RCH_FILIAL" )

If !(nOpc = 4 ) 
	aAdd( aRCHNotFields, "RCH_PROCES" )
	aAdd( aRCHNotFields, "RCH_ROTEIR" )
Endif 

aColsRCH := RCH->( GdMontaCols(	@aHeaderRCH		,;  //01 -> Array com os Campos do Cabecalho da GetDados
								@nRCHUsado		,;	//02 -> Numero de Campos em Uso
							 	@aRCHVirtGd		,;	//03 -> [@]Array com os Campos Virtuais
							  	@aRCHVisualGd	,;	//04 -> [@]Array com os Campos Visuais
	                          	"RCH"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
							  	aRCHNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
							  	@aColsRCHRec	,;	//07 -> [@]Array unidimensional contendo os Recnos
							  	"RCJ"			,;	//08 -> Alias do Arquivo Pai
							  	cKeySeek_		,;	//09 -> Chave para o Posicionamento no Alias Filho
							    bKey			,;	//10 -> Bloco para condicao de Loop While
							    NIL				,;	//11 -> Bloco para Skip no Loop While
  							    NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
			  				    NIL			  	,;	//13 -> Se cria variaveis Publicas
					  		    NIL				,;	//14 -> Se Sera considerado o Inicializador Padrao
  							    NIL				,;	//15 -> Lado para o inicializador padrao
		  					    NIL				,;	//16 -> Opcional, Carregar Todos os Campos
				  			    NIL 			,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
	  						    cQuery			,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
	  						    .T.				,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
	  						    .F.		        ,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
								.T.             ,;	//21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
								NIL             ,;	// 22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
								NIL             ,;	// 23 -> Verifica se Deve Checar se o campo eh usado
								NIL				,;	// 24 -> Verifica se Deve Checar o nivel do usuario
								.T.				,;	// 25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
								NIL				,;	// 26 -> [@]Array que contera as chaves conforme recnos
								NIL				,;	// 27 -> [@]Se devera efetuar o Lock dos Registros
								NIL				,;	// 28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
						        NIL				,;	// 29 -> Numero maximo de Locks a ser efetuado
								.T.				);	// 30 -> Utiliza Numeracao na GhostCol
						   )						// funcao em PONXFUN.PRX

                                                                                      
aSvColsRCH	:= aClone(aColsRCH)

MontaColsRCHSF(cKeySeek_,bKey,cQuery) //Monta o aCols sem SuperFiltro

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carrega, apenas, os Campos Editaveis            			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aRCHAltera := {} 
For nX := 1	To nRCHUsado 
	IF (;
			( aScan( aRCHVirtGd 		, aHeaderRCH[ nX , 02 ] ) == 0.00 ) .and. ;
	   		( aScan( aRCHVisualGd 		, aHeaderRCH[ nX , 02 ] ) == 0.00 ) .and. ;
	   		( aScan( aRCHNotFields  	, aHeaderRCH[ nX , 02 ] ) == 0.00 ) ;		   		//( aScan( aRCHNaoAltera		, aHeaderRCH[ nX , 02 ] ) == 0.00 ) 	   ;
	  	) 
		aAdd( aRCHAltera , aHeaderRCH[ nX , 02 ] ) 
	EndIF  
Next nX  


/* 
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Se for exclusão, monta acols somente com  os dados seleciona ³
³ dos no parametro                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If nOpc = 4
  
	lRotProc:= fRotProc( )
	fCarPdRG6( )

	nPer		:= Len(aRG6) 
	nTam		:= Len(aHeaderRCH)
	aColsAux	:= Array(nPer, nTam + 1 ) 

	nPosProc	:= GdFieldPos("RCH_PROCES", aHeaderRCH )
	nPosRoteiro := GdFieldPos("RCH_ROTEIR", aHeaderRCH ) 
	nPosDtIni	:= GdFieldPos("RCH_DTINI" , aHeaderRCH ) 
	nPosPdPeri 	:= GdFieldPos("RCH_PDPERI", aHeaderRCH ) 
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica se existe periodo conforme parametrizacao            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	nPos:= Ascan(aColsRCH, {|x,y| x[nPosProc]+ x[nPosRoteiro]+ x[nPosPdPeri]+ dtos(x[nPosDTIni])  = cProcesso + cRoteiro+ cPdPeriodo+ dtos(dParDtIni )} ) 
	If  nPos= 0   //-- Pd Periodo 
		MsgAlert( OemToAnsi(STR0046) , OemToAnsi( STR0021 ) )  			//--"Nao existe periodo a ser excluido. Verificar os dados informados "
		aColsRCH:= {}
		Return (.F.)
	Else 
	    For nX:= Len(aColsRCH) to 1 Step -1
			If(nPos:=Ascan(aRG6, {|x| dtos(x[6]) = dtos(aColsRCH[nX,7] )   } )   ) <= 0 
				ADel(aColsRCH, nX)
				ASize(aColsRCH , Len(aColsRCH ) - 1)							
			Endif 				    
	    Next nX 
	Endif 
Endif   

/* 
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Atualiza                                       			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cRoteiroAnt := cRoteiro
cPdPeriodAnt:= cPdPeriodo

If !(oGetRCH == nil)
	oGetRCH:aCols 	:= aClone(aColsRCH )
	oGetRCH:aHeader	:= aClone(aHeaderRCH)

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Busca o periodo Selecionado                                  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	nPosPerSel	:= GdFieldPos("RCH_PERSEL", oGetRCH:aHeader ) 
	nPosPer   	:= GdFieldPos("RCH_PER"   , oGetRCH:aHeader ) 
	nPosSem		:= GdFieldPos("RCH_NUMPAG", OGetRCH:aHeader )
	
	If (nPos:= Ascan( oGetRCH:aCols , {|x,y| x[nPosPerSel] = '1'  } ) ) > 0
		cPerSeL := oGetRCH:aCols[nPos, nPosPer ] +  " " + oGetRCH:aCols[nPos, nPosSem ]
	Else 
		cPerSeL := SPACE(30) 
	Endif 
	oGetRCH:Refresh(.T.)
	
EndIf

If !Empty(RCH->RCH_ROTEIR)
	cRoteiro := RCH->RCH_ROTEIR 
EndIf

Return (lRetOK)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaPeriodo ºAutor  ³Microsiga           º Data ³  11/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Montagem  dos periodos conforme Padrao de Calendario          º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaPeriodo(aRCHNotFields, nUsado , nOpc) 
Local aCols_Aux		:= {} 											//-- Vetor da nova aCols conforme o periodo/padrao selecionado 
Local aPosSortAll	:= {}									   		//-- array com a posicao do filtro 
Local lTemPeriodo	:= .F.
Local aColsRCH_		:= aClone(oGetRCH:Acols) 
Local cNewPeriodo	:= ""
Local cMsg			:= ""
Local nPosPer		:= GdFieldPos("RCH_PER"    , oGetRCH:aHeader)
Local nPosNPag		:= GdFieldPos("RCH_NUMPAG" , oGetRCH:aHeader)
Local nPosMes		:= GdFieldPos("RCH_MES"    , oGetRCH:aHeader)
Local nPosAno		:= GdFieldPos("RCH_ANO"    , oGetRCH:aHeader)
Local nPosDtIni		:= GdFieldPos("RCH_DTINI"  , oGetRCH:aHeader)
Local nPosDtFim		:= GdFieldPos("RCH_DTFIM"  , oGetRCH:aHeader)
Local nCount		:= 0 
Local dData
Local lProssegue
Local nX			:= 0 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ o periodo so pode ser montado desde que se tenha Processso + Roteiro              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If Empty(cRoteiro) 
	MsgAlert(oEmToansi(STR0071) , OemToAnsi( STR0021 ) ) 				//-- ""Informe o roteiro de calculo"" 
	Return(nil)
Endif 

If !lTemPadrao
   	MsgAlert(oEmToansi(STR0102) , OemToAnsi( STR0021 ) ) 				//-- ""Não existe período padrão cadastrado."" 
	Return(nil)
Endif

/* 
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Periodos nao devem  ser montados :                                                ³
³ - Qdo tem periodo cadastrado para o ano competencia                               ³
³ - Qdo nao for selecionado nenhum padrao                                           ³
³ - Qdo for selecionado um  padrao e nao tem Roteiro x processo , porem  já existe  ³
³   periodo cadastrado para o ano competencia                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If  Empty(cPdPeriodo) .or. ;  
   ( !Empty(cPdPeriodo) .and. !lRotproc ) .OR. nOpc = 2  
	Return Nil 
EndIf 

If lTemPadrao .And. Empty ( aRG6[1,6] )
	MsgAlert(oEmToansi(STR0101) , OemToAnsi( STR0021 ) ) 				//-- Não foi informada a data inicial do período.
	Return(nil)
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta aCols com os dados de acordo com   competencia  e periodo Desejado          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 
If lTemPadrao .and. ; 								    //-- Somente ira montar o periodo se tiver cadastrado um  roteiro por processo 
   (!Empty(aRG6) .and. !EMPTY( aRG6[1,6] )	) 			//-- verifica se data inicial do periodo é valida para montagem                                                                                                                               
     

	If MsgYesNo( OemToAnsi(STR0076) + dtoc(aRotProc[1,3]) + ". " +  OemToAnsi(STR0075)  )	  	//--Data inicial do novo periodo DD/MM/AA . Confirma ? "
		
		MsgRun(OemToAnsi(STR0043) + dtoc(aRotProc[1,3]) ,OemToAnsi(STR0024),{|| RCH->( dbGoBottom() ), RCH->( dbSkip() ), aCols_Aux := fNewAcols("2",aRCHNotFields,@nUsado,,,, )}) 		//" Elaborando periodo com data inicial em   "###"Aguarde" 
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Verifica entre os periodos ja cadastrados se existem periodos³
		³com  intervalos de datas coicidentes                         ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cNewPeriodo		:= dtoc(aCols_Aux[1,nPosDtIni],"DDMMYYYY")  + " - " + dtoc(aCols_Aux[len(aCols_aux),nPosDtFim],"DDMMYYYY")  
	
		If 	fCoincidenceDt( aCols_Aux, aColsRCH_ , @cMsg )
			MsgAlert(cMsg , OemToAnsi( STR0021 ) ) 	
			Return Nil
		Endif 
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Carrega Array a Posicao dos Campos para o "Sort"			  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		aAdd( aPosSortAll	, nPosPer ) 
		aAdd( aPosSortAll	, nPosNPag) 
		aAdd( aPosSortAll	, nPosMes )  
		aAdd( aPosSortAll	, nPosAno ) 
		aAdd( aPosSortAll	, nPosDtIni ) 
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Monta aCols com os dados de acordo com   competencia  e periodo Desejado          ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 
		GdTransfaCols(	@aColsRCH_   	,;	//01 -> Array com a Estrutura do aCols Contendo todos os Dados
						@aCols_Aux 		,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
						oGetRCH:aHeader ,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
						NIL				,;	//04 -> Array com as Posicoes dos Campos para Pesquisa
						NIL				,;	//05 -> Chave para Busca
						aPosSortAll		,;	//06 -> Array com as Posicoes dos Campos para Ordenacao
						NIL				,;	//07 -> Array com as Posicoes dos Campos e Chaves para Pesquisa
						NIL				,;	//08 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
						.F.				,;	//09 -> Se Carrega o Elemento como Deletado na Remontagem do aCols
						.T.				,;	//10 -> Se deve Transferir do aCols para o aColsAll
						.T.				,;	//11 -> Se deve Transferir do aColsAll para o aCols
						.T.				,;	//12 -> Se Existe o Elemento de Delecao no aCols
						.T.				,;	//13 -> Se deve Carregar os Inicializadores padroes
						NIL				,;	//14 -> Lado para o Inicializador padrao
						.F.				 ;	//15 -> Se deve criar variais Publicas
		 			  )	
		 			  
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Deleta registros em branco                                                        ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 
		For nX:= Len(aColsRCH_ ) To 1 Step -1 
			If Empty(aColsRCH_[nX, nPosPer]) 
				ADel(aColsRCH_ , nX)
				ASize(aColsRCH_ , Len(aColsRCH_ ) - 1)
			EndIf
		Next nX
	    
	Endif 

Endif 
If !Empty(aColsRCH_)
	oGetRCH:aCols:=aClone(aColsRCH_) 
EndIf
oGetRCH:oBrowse:nAt
oGetRCH:oBrowse:Refresh()
oGetRCH:Refresh()

Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCoincidenceDtºAutor  ³Microsiga           º Data ³  10/15/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe o perido para ser gerado no RCH             º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function  fCoincidenceDt( aColsNew, aColsAtu, cMsg ) 
Local lRetOk		:= .F. 						// -- Se .T. , então tem  outro periodo com  datas coincidentes 
Local nX			:= 0  
Local nY 			:= 0 
Local nCnt			:= 0 
Local nPosDtIni		:= GdFieldPos("RCH_DTINI"  , oGetRCH:aHeader) 
Local nPosDtFim		:= GdFieldPos("RCH_DTFIM"  , oGetRCH:aHeader) 
Local nPosPer		:= GdFieldPos("RCH_PER"    , oGetRCH:aHeader) 
Local nPosNumpag	:= GdFieldPos("RCH_NUMPAG" , oGetRCH:aHeader) 
Local cCoincident	:= "" 
Local cAliasRCH		:= "RCH"
Local cQuery		:= ""
Local cQryReg		:= ""
Local aStruRCH		:= {}
Local dDataIni 		:= aColsNew[1, nPosDtIni ]
Local dDataFim 		:= aColsNew[Len(aColsNew), nPosDtFim ]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao sera permitido gerar o roteiro padrao se existir um  periodo ja cadas³
//³ trado com  o mesmo intervalo de datas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nY	:= 1 TO Len(aColsNew) 
	For nX:= 1 To Len(aColsAtu)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica existencia de data coincidente         			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF ConflictDate( aColsNew[nY, nPosDtIni ] , aColsNew[nY, nPosDtFim ] , aColsAtu[nX, nPosDtIni ], aColsAtu[nX, nPosDtFim ] ) 
			nCnt++ 
		Endif 
		
	Next nX 
Next nY 

If nCnt > 0 
	cMsg	:= oEmToAnsi( STR0069)  															//-- "Ja existe periodo padrao cadastrado para este intervalo de datas " 
	lRetOk	:= .T. 
Else 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe algum periodo cadastrado com  mesmo codigo do periodo+³
	//³ o numero de pagamento para nao duplicar a chave                          ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
	For nY	:= 1 TO Len(aColsNew)
	
		If (nCnt:= Ascan(aColsAtu,{|X| X[1]+X[2] ==  aColsNew[nY,1]+ aColsNew[nY,2]   }  ) ) > 0 
			cMsg	:= oEmToAnsi(STR0072)+ ": " +CRLF + ;
			           aColsAtu[nCnt,1]+ " " + aColsAtu[nCnt,2]  	//-- Já existe periodo cadastrado com o mesmo codigo e numero de pagamento 
			Return( .T.) 
		Endif 
	Next nY 

Endif 		
Return( lRetOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA400   ºAutor  ³Microsiga           º Data ³  10/19/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do roteiro                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function  fVldRoteiro() 
Local lRet	:= .T.

IF !EMPTY(cRoteiro)
	cDescRoteiro	:= fDesc("SRY", cRoteiro, "RY_DESC") 
	
	If !(EXISTCPO("SRY", cRoteiro ) ) 
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Atualiza                                       			   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cRoteiro	:= SPACE(TamSX3("RCH_ROTEIR")[1]) 
		cRoteiroAnt	:= cRoteiro 
		cPdPeriodo	:= SPACE(TamSX3("RCH_PDPERI")[1]) 
		cPdPeriodAnt:= cPdPeriodo     
		cDescRoteiro	:= SPACE(30) 
	Endif 
Endif 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GP400AExclºAutor  ³Microsiga           º Data ³  11/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa a exclusao de um grupo de periodos conforme um Pd. º±±
±±º          ³ de periodos                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GP400AExcl( cAlias , nReg , nOpc )
Private nOpcX1 := nOpc

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Confirma exclusa do grupo de periodos 					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If nOpc = 4
	
		If (MsgYesNo( OemToAnsi( STR0044 ) ) )	  	//--"Esta rotina efetua a exclusao de um  grupo de periodos padronizados conforme o Processo, Roteiro. Confirma exclusao ? 
			MsAguarde( { || GP400ExecDel( 	"RCH",; //1-Alias pai - RCH
						                     nOpc,;	//2-Opcao da operacao 
						                     nReg;	//3-Registro
					                     );  
					    }, OemToAnsi(STR0024))		// Aguarde 
		Endif 			
	Endif 
	
Return nil 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GP400ExecDel ºAutor  ³Microsiga           º Data ³  11/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function GP400ExecDel( cAlias_, nOpc, nReg )

Local nOpcA			:= 0.00											// variavel de controle utilizada para a gravacao
Local aAreaAlias	:= GetArea() 

Local oDlg
Local oFont
Local oGroup
Local oProcesso 
Local oRoteiro
Local oPdPeriodo
Local odDtIni

// Variaveis para Dimensionar Tela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Private cRoteiro 	:= SPACE(TamSX3("RCH_ROTEIR")[1]) 			   	//Roteiro de calculo 
Private cProcesso	:= SPACE(TamSX3("RCH_PROCES")[1]) 
Private cPdPeriodo	:= SPACE(TamSX3("RCH_PDPERI")[1]) 
Private dParDtIni	:= CTOD("//") 


Begin Sequence
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aAdvSize[5] 	:= (aAdvSize[5]/100) * 57.2
	aAdvSize[6] 	:=  (aAdvSize[6]/100) * 50
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 015 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Parametros a exclusao do periodo                           ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD 
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0045 ) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL	//"Exclusao de periodos padronizados " 
	        
        /*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Parametros para delecao do periodo padronizado             ³
		³                                                            ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		
		@ aObjSize[1,1]+18, aObjSize[1,2]+15.2 SAY OemToAnsi(STR0034) SIZE 146,10 OF oDlg PIXEL FONT oFont//"Processo"
		@ aObjSize[1,1]+15, aObjSize[1,2]+85.2 MSGET oProcesso VAR cProcesso SIZE 050,10 OF oDlg PIXEL  F3 'RCJ' VALID ExistCpo('RCJ') 	PICTURE '@!'	
		
		@ aObjSize[1,1]+33, aObjSize[1,2]+15.2 SAY OemToAnsi(STR0035) SIZE 146,10 OF oDlg PIXEL FONT oFont//"Roteiro "
		@ aObjSize[1,1]+30, aObjSize[1,2]+85.2 MSGET oRoteiro VAR cRoteiro SIZE 050,10 OF oDlg PIXEL F3 'SRY' VALID ( fChkRoteiro() ) PICTURE '@!'
		
		@ aObjSize[1,1]+48, aObjSize[1,2]+15.2 SAY OemToAnsi(STR0036) SIZE 146,10 OF oDlg PIXEL FONT oFont//"Pad Periodo " 		
		@ aObjSize[1,1]+45, aObjSize[1,2]+85.2 MSGET oPdPeriodo VAR cPdPeriodo SIZE 050,10 OF oDlg PIXEL When(.F.) 
		
		@ aObjSize[1,1]+63, aObjSize[1,2]+15.2 SAY OemToAnsi(STR0032) SIZE 146,10 OF oDlg PIXEL FONT oFont//"Dt Inicio "
		@ aObjSize[1,1]+60, aObjSize[1,2]+85.2 MSGET odDtIni VAR dParDtIni SIZE 050,10 OF oDlg PIXEL VALID ( fVlDtExcl()) PICTURE '@!'
		
		oDlg:bSet15 := { ||  nOpcA := 1 , oDlg:End() }
		oDlg:bSet24 := { ||  nOpcA := 2 , oDlg:End() }

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , oDlg:bSet15 , oDlg:bSet24 ) 

	IF nOpcA == 1 .and. nOpc = 4 
		fDispTelaExcl(nOpc, nReg ) 
	Endif 
		
End Sequence

RestArea( aAreaAlias ) 
          
Return NIL 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fChkRoteiro  ºAutor  ³Microsiga           º Data ³  11/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static function fChkRoteiro() 
Local lRet:= .T. 


/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Coloca o Ponteiro do Mouse em Estado de Espera                           ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
CursorWait()

If !Empty(cRoteiro) .and. !ExistCpo('SRY')
	CursorArrow()
	Return(.F.)
Endif

/* 
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Verifica se tem  Padrao nos Roteiros por Proces1so 		   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !fRotProc( ) 
	MsgAlert( OemToAnsi( STR0049 ) , OemToAnsi( STR0021 ) )  			//-- ""A exclusao sera possivel somente para Roteiros por processo que utilizam padrao de periodos" 
	dParDtIni	:= ctod('//')
	cPdPeriodo	:= SPACE(TamSX3("RGA_PDPERI")[1])
	lRet		:= .F. 
Endif

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura o Ponteiro do Mouse 											   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
CursorArrow()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fVlDtExcl    ºAutor  ³Microsiga           º Data ³  11/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do campo Dt Inicial para delecao dos periodos        º±±
±±º          ³padronizados                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static function fVlDtExcl()
Local lRet:= .T. 

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Coloca o Ponteiro do Mouse em Estado de Espera                           ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
CursorWait() 

lRet	:= NaoVazio()

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura o Ponteiro do Mouse 											   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
CursorArrow()
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fDispTelaExclºAutor  ³Microsiga           º Data ³  11/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostra o grupo de periodos a ser deletado                      º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function  fDispTelaExcl( NoPC, nReg) 

// variaveis de controle // 
Local nOpcAlt			:= 0.00		// variavel de controle das alteracoes - utilizada para a gravacao
Local nX				:= 0.00		// variavel utilizada em loops
Local nUsado 			:= 0
Local nPosRec			:= 0 
Local lMontaCols 		:= .T. 

// variaveis para enchoice da tabela RCH // 

Local aColsRCH			:= {} 		// Vetor aCols 
Local aHeaderRCH		:= {} 		//

Local aRCHAltera		:= {}		// vetor com os campos que permitem alteracao
Local aRCHNaoAltera		:= {}		// vetor com os campos que nao podem ser alterados
Local aRCHVirtChoice	:= {}		// vetor com os campos virtuais 
Local aRCHNotFields		:= {}		// vetor com os campos que nao serao visualizados
Local aColsRCHRec		:= {}		// vetor contendo os recnos dos registros 


// variaveis da janela //
Local bSet15		:= { || NIL }		// Bloco com as validacoes do botao OK
Local bSet24		:= { || NIL }		// Bloco com as validacoes do botao Cancelar
Local bDialogInit	:= { || NIL }		// Inicializacao do Dialog

// variaveis do tipo objetos // 
Local oDlg			:= NIL				// objeto de dialogo 
Local oFont	
Local oGroup


// variaveis para controle de coordenadas da janela //
Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjSize			:= {}
Local aObjCoords		:= {}

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis lModPadrao                                                   ³   
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private aRotProc	:= {} 											//Vetor com  o Roteiro por processo
Private aRG6		:= {} 											//Vetor com  os 

Private bChange     := {|| NIL}
Private cKeySeek	:= ""											// Chave para o Posicionamento no Alias Filho
Private cQuery		:= ""											// Utilizacao de Query para Selecao de Dados
Private lTemPadrao	:= .F. 	   										// Indica se tem  padrao de calendario no Roteiros por processo 
Private lRotProc	:= .F. 		

Private oGetRCH		:= NIL 											//GetDados da Tabela RCH 
Private aColsDel	:={}
Private aLog		:={}
Private aLogTitle	:={}
                     
	/* 
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 } 
	aAdd( aObjCoords , { 015 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define o Bloco para a Inicializacao do Dialog            	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	bDialogInit		:= { ||;
							CursorWait()							,;	
							EnchoiceBar( oDlg , bSet15 , bSet24 )	,; 
							RstEnchoVlds()							,;				
							CursorArrow()							 ; 
                         }
                         
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta o Dialogo Principal                                    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	lMontaCols := GP400MontaCols(nOpc,"RCH", cProcesso, cRoteiro ,cPdPeriodo, @aRCHAltera, @aHeaderRCH, @aColsRCH , nOpc, @aColsRCHRec, @aRCHNotFields ,nUsado, nPosRec , nReg, .F. ) 

	If !lMontaCols
	
		Return Nil 	              	
	Endif 
	
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD 	
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0045 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5]- 50 OF oMainWnd PIXEL 

		@ aObjSize[1,1] , 01    	GROUP oGroup 	TO ( aObjSize[2,3]/100 * 12 ), 090  LABEL OemToAnsi(STR0034) OF oDlg PIXEL			 // Processo 
		@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] + 3 ) - aObjSize[1,2] ) / 2 ) )+ 10 , ( aObjSize[1,4]/100*01   ) SAY  cProcesso SIZE 100,10 OF oDlg PIXEL FONT oFont
		oGroup:oFont:= oFont	 
	    
		@ aObjSize[1,1] , 095 		GROUP oGroup 	TO ( aObjSize[2,3]/100 * 12 ), 160  LABEL OemToAnsi(STR0035) OF oDlg PIXEL   		//"Roteiro"
		@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] + 3  ) - aObjSize[1,2] ) / 2 ) )+ 10 , ( aObjSize[1,4]/100*20 )  SAY cRoteiro  	SIZE 040,10 OF oDlg PIXEL FONT oFont
		oGroup:oFont:= oFont	
		
		@ aObjSize[1,1] , 165   	GROUP oGroup 	TO  ( aObjSize[2,3]/100 * 12), 220 LABEL OemToAnsi(STR0036) OF oDlg PIXEL			// "Pad.Periodo" 
		@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] + 3 ) - aObjSize[1,2] ) / 2 ) )+ 10 , ( aObjSize[1,4]/100*35)   SAY cPdPeriodo	SIZE 040,10  OF oDlg PIXEL FONT oFont
		oGroup:oFont:= oFont	
				
		@ aObjSize[1,1] , 225	 	GROUP oGroup 	TO ( aObjSize[2,3]/100 * 12 ), 295  LABEL OemToAnsi(STR0032) OF oDlg PIXEL			//"Dt.Inicial "
		@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] + 3 ) - aObjSize[1,2] ) / 2 ) )+ 10 , ( aObjSize[1,4]/100*48 )  SAY dParDtIni 	SIZE 040,10 OF oDlg PIXEL FONT oFont
		oGroup:oFont:= oFont
		 		
	oGetRCH := MsNewGetDados():New(aObjSize[2,1]+ 7,;	// 1nTop
									 aObjSize[2,2]	,;  // 2nLelft
									 aObjSize[2,3]	,;	// 3nBottom
		                             aObjSize[2,4]	,;	// 4nRright
									 0				,;  // 5controle do que podera ser realizado na GetDado - nstyle
									 .T.			,;	// 6funcao para validar a edicao da linha - ulinhaOK
									 .T.			,;	// 7funcao para validar todas os registros da GetDados - uTudoOK
	  								 NIL			,;	// 8cIniCPOS
									 aRCHAltera		,;	// 9aAlter
									 0				,; 	// 10nfreeze
									 99999			,;  // 11nMax
									 NIL			,;	// 12cFieldOK
									 NIL			,;	// 13usuperdel
									 NIL			,;	// 14udelOK
									 @oDlg			,; 	// 15objeto de dialogo - oWnd
									 @aHeaderRCH    ,;	// 16Vetor com Colunas - AparHeader
									 @aColsRCH 	    ,;	// 17Vetor com Header - AparCols
										            ,;  // 18
										 "2")			// 19Tela 
	nPosRec		:= GdfieldPos("RCH_REC_WT",oGetRCH:aHeader)	

	bSet15	:= {|| nOpcAlt:= 1, IF(oGetRCH:TudoOk(),oDlg:End(),nOpcAlt:=0)}
	bSet24	:= {|| oDlg:End()}

	ACTIVATE MSDIALOG oDlg ON INIT Eval( bDialogInit )
	
	If nOpcAlt == 1 .and. nOpc!= 2 .and. lMontaCols 

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Verifica se é possivel deletar o periodo                      ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If fChkDelet(nOpc)
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Efetua a deleção                                              ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			fDelPeriodo()
		Endif
		If !Empty(aLog) 
			IF ( MsgYesNo( OemToAnsi( STR0099 )  , OemToAnsi( STR0021 ) ) )	 			//"Ocorreram Inconsistencias durante a manutencao do período. Deseja Visualiza-las?"##"Atencao!"
				aAdd( aLogTitle , oemtoansi( STR0100 )) 																							//
				MsAguarde( { || fMakeLog( { aLog }, aLogTitle , NIL , NIL , FunName() , oemtoansi( STR0100 ),"M","P",,.F. ) } , STR0100 ) 		//"Log de Ocorrências - Períodos"
			EndIF		
		Endif 			
	EndIF
Return(nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fChkDelet ºAutor  ³Microsiga           º Data ³  11/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se eh possivel efetuar a exclusao                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fChkDelet(nOpc) 

Local aNotRelac	:= { "RCF" }
Local cKey		:= ""
Local nPosProc	:= GdFieldPos("RCH_PROCES" , oGetRCH:aHeader)   
Local nPosRot	:= GdFieldPos("RCH_ROTEIR" , oGetRCH:aHeader) 
Local nPosPer	:= GdFieldPos("RCH_PER"    , oGetRCH:aHeader) 
Local nPosNPag	:= GdFieldPos("RCH_NUMPAG" , oGetRCH:aHeader) 
Local nPosRec	:= GdfieldPos("RCH_REC_WT" , oGetRCH:aHeader)	
Local nPosStat	:= GdfieldPos("RCH_STATUS" , oGetRCH:aHeader)	
Local nX		:= 0 
Local lRetOK	:= .T.
Local aColsAux	:= oGetRCH:Acols 
Local aArea		:= GetArea()
Local cPerAux	:= "" 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Nao deve possuir:dt.fecha, status, ser pre-selecionado        ³ 
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
dbSelectArea("RCH")
dbSetOrder(1)

For nX := 1 to Len(aColsAux)
	
	Begin Sequence 
	
		cKey := oGetRCH:aCols[nX, nPosproc] +  oGetRCH:aCols[nX, nPosPer] + oGetRCH:aCols[nX, nPosNPag] + oGetRCH:aCols[nX, nPosRot] 
		cPerAux := oGetRCH:aCols[nX, nPosPer]
		
		// verificar se a tabela nao possui registros relacionados //
		lRetOK  := ChkDelRegs(	'RCH'				,;	// 1-Alias do Arquivo Principal
								oGetRCH:Acols[nX,nPosRec],;	// 2-Registro do Arquivo Principal
								nOpc				,;	// 3-Opcao para a AxDeleta
								xFilial( "RCH" )	,;	// 4-Filial do Arquivo principal para Delecao
								cKey				,;	// 5-Chave do Arquivo Principal para Delecao
								NIL 				,;	// 6-Array contendo informacoes dos arquivos a serem pesquisados
								NIL					,;	// 7-Mensagem para MsgYesNo
								NIL					,;	// 8-Titulo do Log de Delecao
								NIL					,;	// 9-Mensagem para o corpo do Log
								.F.				 	,;	// 10-Se executa AxDeleta
								.F.     			,;	// 11-Se deve Mostrar o Log
								NIL					,;	// 12-Array com o Log de Exclusao
								NIL				 	,;	// 13-Array com o Titulo do Log
								NIL					,;	// 14-Bloco para Posicionamento no Arquivo
								NIL					,;	// 15-Bloco para a Condicao While
								NIL					,;	// 16-Bloco para Skip/Loop no While
								.T.					,;	// 17-Verifica os Relacionamentos no SX9
								aNotRelac			,;	// 18-Alias que nao deverao ser Verificados no SX9
								NIL				 	 ;	// 19-Se faz uma checagem soft
							 )

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Se o campo de Status estiver <> de 0-Normal, entao significa ³
		³ que o periodo esta sendo utilizado e portanto nao pode ser   ³	
		³ deletado                                       			   ³		
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		//--- 0=Normal;1=Pre-Fechado;2=Utilizado por outro Usuario;3=Recibos ja foram imp ;4= Em processo de fechamento  
		If !( Empty( oGetRCH :aCols[nX, nPosStat] )  .and. oGetRCH :aCols[nX, nPosStat]<> '0' )    
			If aScan(aLog,cPerAux) == 0
				aAdd(aLog, cPerAux + " - " + OemToAnsi( STR0033 ) )		//carrega o array com os registros que não devem ser deletado.			
			Endif
//			MsgAlert( OemToAnsi( STR0033 ) , OemToAnsi( STR0021 ) ) 		//Nao e possivel efetuar a manutencao deste periodo. Verifique o campo de Status "
			lRetOk 	:= .F. 
		Else		
			If lRetOK
				aAdd(aColsDel,oGetRCH:Acols[nX])//carrega o aCols com os registros que devem ser deletado.
			Else               
				If aScan(aLog,cPerAux) == 0
					aAdd(aLog, cPerAux + " - " + OemToAnsi( STR0039 ) + " (SX9) " )		//carrega o array com os registros que não devem ser deletado.				
				Endif
				//MsgAlert( OemToAnsi( STR0039 ) , OemToAnsi( STR0021 ) ) 		//""O periodo nao pode ser excluido. Verifique as tabelas relacionadas. "
				lRetOk 	:= .F. 
			Endif
		Endif

		IF !lRetOK
			Break
		Endif
		
	End sequence 
	
Next nX

dbSelectArea( 'RCH' )
dbSetOrder( 1 )

RestArea(aArea) 

Return (lRetOK)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fDelPeriodo ºAutor  ³Microsiga           º Data ³  11/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Efetua a exclusao do Periodo conforme o padrao e data       º±±
±±º          ³  inicial selecionada                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fDelPeriodo()

Local aColsRCH	:= (aColsDel)
Local nX		:= 0 
Local nCols		:= Len(aColsDel)
Local nPosRec	:= GdfieldPos("RCH_REC_WT",oGetRCH:aHeader)	

/* 
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Exclusao                                       			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Begin Transaction 
	For nX := 1 To nCols 
		If aColsRCH[nX][nPosRec] > 0 
			RCH->(DBGoto(aColsRCH[nX][nPosRec]) )
			RCH->(RecLock('RCH' , .F.,.T.) )
			RCH->(dbDelete())
			RCH->( MsUnlock() )
		Endif
	Next nX
	
End Transaction 

Return  nil   

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³05/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA390                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   

Static Function MenuDef()

Local aRotina  

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Array contendo as Rotinas a executar do programa      ³
³ ----------- Elementos contidos por dimensao ------------     ³
³ 1. Nome a aparecer no cabecalho                              ³
³ 2. Nome da Rotina associada                                  ³
³ 3. Usado pela rotina                                         ³
³ 4. Tipo de Transa‡„o a ser efetuada                          ³
³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
³    2 - Simplesmente Mostra os Campos                         ³
³    3 - Inclui registros no Bancos de Dados                   ³
³    4 - Altera o registro corrente                            ³
³    5 - Remove o registro corrente do Banco de Dados          ³
³    6 - Copiar                                                ³
³    7 - Legenda                                               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

aRotina := {	{ STR0002 , "PesqBrw"	 , 0 , 1 } ,; 	//"Pesquisar"
				{ STR0003 , "GPA400AMan" , 0 , 2 } ,; 	//"Visualizar"
				{ STR0005 , "GPA400AMan" , 0 , 4 } ,; 	//"Alterar"
				{ STR0006 , "GP400AExcl" , 0 , 5 } ; 	//"Excluir"
			}

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA400   ºAutor  ³Valdeci Lira        º Data ³  05/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Copia um conjunto de registros para outro processo+roteiro  º±±
±±º          ³com base na getDados exibida na tela                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CopyPastePeriodo()  
	Local aArea		:= {}  			//->Area de selecao antes da rotina
	Local aColsAux	:= {}          //->aCols auxiliar usado para filtrar as colunas a copiar
	Local aColsPaste:= {}          //->aCols filtrado a ser copiado
	Local aSays		:= {}          //->Array com as mensagens que serao exibidas na primeira tela
	Local aButtons	:= {}          //->Array com os botoes que serao exibidos na primeira tela
	Local cPerg		:= "GPA400CP"  //->Pergunta que configura parametros para filtragem do aCols
	Local cPerDe	:= ""          //->Periodo inicial para filtragem de dados
	Local cPerAte	:= ""          //->Periodo final para filtragem de dados
	Local cNumPagDe	:= ""          //->Numero de pagamento inicial para filtragem de dados
	Local cNumPagAte:= ""          //->Numero de pagamento final para filtragem de dados
	Local cAnoMesDe	:= ""          //->Ano / mes inicial para filtragem de dados
	Local cAnoMesAte:= ""          //->Ano / mes final para filtragem de dados
	Local cProcDest	:= ""          //->Processo de destino
	Local cRotDest	:= ""          //->Roteiro de destino
	Local cValFil	:= ""          //->Armazena o valor da filial, para montagem da Key de busca em dbSeek
	Local cKey		:= ""          //->Chave para busca de registros para evitar duplicidade na copia
	Local cMsgLog	:= ""          //->String para mensagem de Log
	Local cMsgNaoCopia:= ""        //->String para mensagem de Log
	Local cMsgAux	:= ""          //->String para mensagem de Log
	Local lProcessa	:= .F.         //->Indica se a copia devera ser processada ou nao
	Local nTamAcols	:= 0           //->Armazena o tamanho do aCols a se trabalhar, usado no While
	Local nAux		:= 0           //->Contador auxiliar
	Local nPosFilial:= 0           //->Posicao do campo filial na getDados
	Local nLenPer	:= 0           //->Tamanho do campo cod.periodo
	Local nPosPer	:= 0           //->Posicao do campo cod.periodo na getDados
	Local nLenNumPag:= 0           //->Tamanho do campo numero de pagamento
	Local nPosNumPag:= 0           //->Posicao do campo numero de pagamento na getDados
	Local nLenMes	:= 0           //->Tamanho do campo mes
	Local nPosMes	:= 0           //->Posicao do campo mes na getDados
	Local nLenRoteir:= 0           //->Tamanho do campo Roteiro
	Local nLenProces:= 0           //->Tamanho do campo Processo
		
	
	If Type("oGetRch") != "U"     
		//So entra na rotina se tiver dados a serem copiados
		If !GdNoEmpty( gdObrigat(oGetRch:aHeader, "RCH") , 1 , oGetRch:aHeader , oGetRch:aCols , .F. , NIL , .F. )
			msgInfo( OemToAnsi( STR0084 ))     
			Return
		EndIf  
	Else      
		//Precisa do oGetRch para saber quais dados serao copiados
		msgAlert( OemToAnsi( STR0090 )) 
		Return
	EndIf		
	
	//Mensagens de tela
	AADD(aSays, OemToAnsi( STR0078 ) ) //"Esta rotina tem a finalidade de copiar um conjunto de períodos de um " 
	AADD(aSays, OemToAnsi( STR0079 ) ) //"processo+roteiro para outro processo+roteiro."
	AADD(aSays, OemToAnsi( STR0080 ) ) //"Para realizar a cópia configure os parametros com a finalidade de"
	AADD(aSays, OemToAnsi( STR0081 ) ) //"filtrar os conjunto de dados exibidos na tela de Calendário de Períodos."
	                   
	//Botoes da tela
	AADD(aButtons, { 5,.T., { || Pergunte(cPerg, .T. ) } } )
	AADD(aButtons, { 1,.T.,{|o| lProcessa := .T., If(GpConfOk( OemToAnsi(STR0082), OemToAnsi(STR0083) ),FechaBatch(),lProcessa:=.F.) }} ) //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o" - Em GPEXFUN
	AADD(aButtons, { 2,.T.,{|o| FechaBatch() }}) 
	                
	//Exibicao da tela de processamento
	FormBatch( STR0077 , aSays, aButtons )
	
	If lProcessa
		aColsAux := aClone(oGetRch:aCols)		
		nTamAcols := Len(aColsAux)
        //Se existirem dados a ser copiados, continua
		If ( nTamAcols > 0 )		
			
			//Localiza a posicao e tamanho dos campos 
			nPosFilial	:= gdFieldPos("RCH_FILIAL"	, aHeaderRCH)
			nPosPer		:= gdFieldPos("RCH_PER"		, aHeaderRCH)
			iIf(nPosPer > 0, nLenPer := aHeaderRch[nPosPer, 4], nLenPer := 0)
			nPosNumPag	:= gdFieldPos("RCH_NUMPAG"	, aHeaderRCH)
			iIf(nPosNumPag > 0, nLenNumPag := aHeaderRch[nPosNumPag, 4], nLenNumPag := 0)
			nPosMes		:= gdFieldPos("RCH_MES"		, aHeaderRCH)
			nPosAno		:= gdFieldPos("RCH_ANO"		, aHeaderRCH)                         
			nLenRoteir  := getSx3Cache("RCH_ROTEIR", "X3_TAMANHO")
			nLenProces	:= getSx3Cache("RCH_PROCES", "X3_TAMANHO")
			
			//Carrega o Pergunte
			Pergunte(cPerg, .F.)
			                      
			//Restaura os parametros garantindo que o tamanho seja compativel com o SX3
			cPerDe		:= Substr(MV_PAR01 + Space(nLenPer), 1, nLenPer)
			cPerAte		:= Substr(MV_PAR02 + Space(nLenPer), 1, nLenPer)
			cNumPagDe	:= Substr(MV_PAR03 + Space(nLenNumPag), 1, nLenNumPag)
			cNumPagAte	:= Substr(MV_PAR04 + Space(nLenNumPag), 1, nLenNumPag)
			cAnoMesDe	:= MV_PAR05
			cAnoMesAte	:= MV_PAR06
			cProcDest	:= Substr(MV_PAR07 + Space(nLenProces), 1, nLenProces)
			cRotDest	:= Substr(MV_PAR08 + Space(nLenRoteir), 1, nLenRoteir)
			                                                                                   
			//Verifica se existe os campos essencias para a copia na getDados
			If ( (nPosPer > 0) .AND. (nPosNumPag > 0) .AND. (nPosMes > 0).AND. (nPosAno > 0))		
				nAux := 1
				//Filtra quais colunas devem ser coladas
				While nAux <= nTamAcols
					If EstaEntre(cPerDe,cPerAte, aColsAux[ nAux, nPosPer] ) .AND. ;   
						EstaEntre(cNumPagDe,cNumPagAte, aColsAux[ nAux, nPosNumPag] ) .AND. ;   
						EstaEntre(cAnoMesDe,cAnoMesAte, aColsAux[ nAux, nPosAno] + aColsAux[ nAux, nPosMes]   ) 
						
						//Se estiver validado pelo filtro então sera adicionado em aColsPaste
				    	aAdd(aColsPaste, aColsAux[nAux]) 
					EndIf
					nAux++	
				End While
				
				nAux := 1
				nTamAcols := Len(aColsPaste) 

				//Mensagem de Log
				cMsgLog := OemToAnsi(STR0087)+ AllTrim(Str(nTamAcols)) +CRLF//Num. de reg a copiar:
				cMsgLog += Replicate("-", 50)+ CRLF//Num. de reg a copiar:
								
				//Verifica se ha linhas a Colar
				If (nTamAcols > 0)
					aArea := getArea()
					RCH->(dbSetOrder(retOrder("RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR")))
													
					/*								
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Percorre todos os registros a serem colados, os que nao existirem            ³
					³como chave unica serao adicionados, os que existirem serao adicionados no log³
					³e exibidos no final do processamento para informar o usuario                 ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					*/
					While nAux <= nTamAcols                                
						//Monta a chave para pesquisa em cKey
						iIf( Empty(nPosFilial), cValFil := xFilial("RCH"), cValFil := aColsPaste[nX, nPosFilial] )
						cKey:= cValFil+cProcDest+aColsPaste[nAux, nPosPer]+aColsPaste[nAux, nPosNumPag]+cRotDest
						
						If !(RCH->(dbSeek( cKey )))
							//Grava o periodo com o processo e roteiro de destino
							fGravaPastePer( aHeaderRCH, {aColsPaste[nAux]}, cProcDest, cRotDest)
						Else
							//addlog                                                    
							cMsgNaoCopia += cValFil + Space(2)								
							cMsgNaoCopia += cProcDest + Space(2)								
							cMsgNaoCopia += cRotDest + Space(2)								
							cMsgNaoCopia += aColsPaste[nAux, nPosPer ] + Space(2)
							cMsgNaoCopia += aColsPaste[nAux, nPosNumPag ] + Space(2)
							cMsgNaoCopia += CRLF	
						EndIf
						nAux++
					End While  
				
					restArea( aArea )   
					
					If( !Empty(cMsgNaoCopia) )           
						cMsgAux:= OemToAnsi(STR0089)+CRLF
						cMsgAux+= Replicate("-", 50)+CRLF
						cMsgAux+= OemToAnsi(STR0088)+CRLF
						cMsgAux+= Replicate("-", 50)+CRLF
						cMsgNaoCopia := cMsgAux + cMsgNaoCopia
					EndIf	 
									
					ShowLog( cMsgLog + cMsgNaoCopia  )
				EndIf  
			EndIf
		EndIf
		
		If nTamAcols == 0
			msgInfo(OemToAnsi(STR0091))		
		EndIf
	EndIf
	
Return (Nil)       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA400   ºAutor  ³Valdeci Lira        º Data ³  05/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe mensagem de log                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ShowLog(cMemo)

Local oDlg    
Local oGroup
Local oMemo
Local oFont
Local oPanel
LOCAL oBar1
LOCAL oBtn_OK
Local nOpca  := 0 
Local bSet15 := {|| NIL}
Local bSet24 := {|| NIL}     

// Variaveis para Dimensionar Tela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Default cMemo := ""

Begin Sequence
     
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aAdvSize[5] 	:= (aAdvSize[5]/100) * 57.2
	aAdvSize[6] 	:=  (aAdvSize[6]/100) * 57
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 015 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
	DEFINE FONT oFont NAME "Courier New" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0085) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL //"Consulta Log de COPIA DE PERIODOS"
	                      
		//Barra de Ferramentas
		oPanel:= TPanel():New(	 0,;
								 0,;
								 NIL,;
								 oDlg,;
								 ,;
								 ,;
								 ,;
								 ,;
								 ,;
								 200,;
								 15,;
								 .F.,;
								 .F.;
								 )
	         
		@ aObjSize[1,3]*0.75, aObjSize[1,4]*0.014 GET oMemo VAR cMemo MEMO SIZE aObjSize[1,4]*0.55, aObjSize[1,4]*0.19 FONT oFont HSCROLL CENTERED DESIGN NO VSCROLL OF oDlg PIXEL WHEN ( .T. )
		oMemo:lReadOnly := .T.
	    
	    bSet15 := { || nOpcA := 1 , oDlg:End()}
		bSet24 := { || nOpcA := 0 , oDlg:End() }
         	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) 

End Sequence	
Return( NIL )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA400   ºAutor  ³Valdeci Lira        º Data ³  05/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Com base em dois valores verifica se o terceiro valor esta º±±
±±º          ³entre os dois primeiros                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EstaEntre(xVal1,xVal2,cCampo)
	Local lRet
	
	If ValType(cCampo) = "U"
		cCampo := &(ReadVar())
	EndIf        
	
   	lRet := (xVal1<=cCampo).AND.(cCampo<=xVal2)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA400   ºAutor  ³Valdeci Lira        º Data ³  05/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cola (Grava) os registros copiados na rotina CopyPaste     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGravaPastePer(aHeaderRef, aColsRef, cProcDest, cRotDest)
	Local nX	:= 0 
	Local nY	:= 0
	Local nCols	:= Len(aHeaderRef)
	Local nRows	:= Len(aColsRef)
	Local xConteudo	

	dbSelectArea("RCH")     
	dbSetOrder(1)
	RCH->( RecLock("RCH",.T.) )  
	
	RCH->RCH_FILIAL:= XFILIAL("RCH")
	RCH->RCH_PROCES:= cProcDest
	RCH->RCH_ROTEIR:= cRotDest		
	RCH->RCH_MODULO:= cModulo     
	
	//Grava todas as linhas e colunas	
	For nY := 1 To nRows
		For nX := 1 To nCols
			cCampo    := Trim(aHeaderRef[nX][2]) 
			xConteudo := aColsRef[nY,nX]			

			If cCampo == "RCH_MODULO" .OR. cCampo == "RCH_REC_WT" .OR. cCampo =="RCH_ALI_WT" .OR. cCampo == "GHOSTCOL"
				loop							
			Else 	 
				xConteudo := aColsRef[nY,nX] 
			EndIf                     
			
			//Atribui os valores a RCH						 	 
			RCH->&cCampo := xConteudo 
		Next nX 
	Next nY	      
	
	RCH->( MsUnlock() )
Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaColsRCHSF  ³ Autor ³ Reginaldo G.R. ³ Data ³ 16.09.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria um aColsRCHSF Sem SuperFiltro                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA400                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaColsRCHSF(cKeySeek_,bKey,cQuery) 

Local nRCHUsadoSF			:= 0 
Local aRCHVirtGdSF			:= {} 
Local aRCHVisualGdSF		:= {} 

	If FindFunction("FwOnSpFilter") //verifica se existe a funcao do superfiltro.
   		If (FwOnSpFilter("RCH")  )	//verifica se existe filtro para "RCH"
   	       		
   	       		 SPFilterOff( { "RCH" } )  //Desativa o SUPERFILTRO   
 
	   						aColsRCHSF := RCH->( GdMontaCols(	@aHeaderRCHSF	,;  //01 -> Array com os Campos do Cabecalho da GetDados
																@nRCHUsadoSF	,;	//02 -> Numero de Campos em Uso
															 	@aRCHVirtGdSF	,;	//03 -> [@]Array com os Campos Virtuais
															  	@aRCHVisualGdSF	,;	//04 -> [@]Array com os Campos Visuais
												              	"RCH"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
			  												   	NIL				,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader aRCHNotFields 
			  													NIL				,;	//07 -> [@]Array unidimensional contendo os Recnos 	@aColsRCHRec
															  "RCJ"				,;	//08 -> Alias do Arquivo Pai
			 												 	cKeySeek_		,;	//09 -> Chave para o Posicionamento no Alias Filho
			   													bKey			,;	//10 -> Bloco para condicao de Loop While
			   													NIL				,;	//11 -> Bloco para Skip no Loop While
			   													NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
								 			  				    NIL			  	,;	//13 -> Se cria variaveis Publicas
	  		   													NIL				,;	//14 -> Se Sera considerado o Inicializador Padrao
			  													NIL				,;	//15 -> Lado para o inicializador padrao
			 													NIL				,;	//16 -> Opcional, Carregar Todos os Campos
  			  													NIL 			,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
			    												cQuery			,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
			    												.T.				,;	//19 -> Opcional, Se deve Executar bKeySF  ( Apenas Quando TOP )
			    												.F.		        ,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																.T.             ,;	//21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
																NIL             ,;	//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																NIL             ,;	//23 -> Verifica se Deve Checar se o campo eh usado
																NIL				,;	//24 -> Verifica se Deve Checar o nivel do usuario
																.T.				,;	//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																NIL				,;	//26 -> [@]Array que contera as chaves conforme recnos
																NIL				,;	//27 -> [@]Se devera efetuar o Lock dos Registros
																NIL				,;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
		        												NIL				,;	//29 -> Numero maximo de Locks a ser efetuado
																.T.				);	//30 -> Utiliza Numeracao na GhostCol
		  														 )						// funcao em PONXFUN.PRX
					SPFilterOff( { "RCH" }, .F. )  //Reativa SUPERFILTRO
	
	    EndIf
	EndIf
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AtualDelColsRCHSF ³ Autor ³Reginaldo G.R.³ Data ³ 23.09.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o  aColsRCHSF com deletado.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA400                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AtualDelColsRCHSF(lDelRCH) 
    Local nPos:=0
	Local nPosRecno	:= GdfieldPos("RCH_REC_WT",oGetRCH:aHeader)	
	Local nPosRec   			:= GdfieldPos("RCH_REC_WT"	,	aHeaderRCHSF)
	Local nx:=0

	If !Empty(oGetRCH:aCols[ oGetRch:oBrowse:nAt, nPosRecno ])
		nPos := Ascan( aColsRCHSF, { |x| x[nPosRec]  == oGetRCH:aCols[ oGetRch:oBrowse:nAt, nPosRecno ] } )   
		If nPos > 0  
			aFill(aColsRCHSF[nPos],lDelRCH,Len(aHeaderRCHSF)+1)
		EndIF              
	EndIf
Return