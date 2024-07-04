#INCLUDE "PONA440.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PONA020  ³ Autor ³ Equipe Advanced RH    ³ Data ³05/02/1996³±±
±±³          ³ PONA440  ³ Autor ³ Equipe Advanced RH    ³ Data ³13/01/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastramento de Feriados (novo modelo).                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPON                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Ademar Jr.  ³01/02/11³002358/2011³-PTG-Novo Modelo de Cadastro de Feriados. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PONA440()

//Variaveis para dimensionamento dos objetos em tela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aCols		:= {}
Local aHeader	:= {}
Local aArea		:= GetArea()

Local oDlg
Local oCalend
Local aBotoes     	:= {}   
Local bSet15 := {|| Iif(GPEA440TudoOk(), (nOpcA := 1, oDlg:End()), (nOpcA := 0, oDlg:End()) )}
Local bSet24 := {|| nOpcA := 0, oDlg:End()}
Local bDialogInit	:= { || NIL }
Local nRecno		:= SP3->(Recno())
           
Local bfCopiaFeriado:= {||IF(fProgAtual(),;
							 fChamaTelaCopia(	cFilSP3			,; // Filial do SP3
												oCalend			,; // Objeto Calendario
												lSP3Exclusivo	,; // Indica se o SP3 eh exclusivo
												cAliasTmp1		,; // Alias do temporario para selecao de filiais
												cAliasTmp2		,; // Alias do temporario com dados da filial origem do feriado
												cMark			,; // Marca do MarkBrowse
												aBrowseFields	;  // Campos a serem mostrados no MarkBrowse
											),;		
							Nil;
							);			  		
					   }
Local aSvKeys			:= GetKeys() 
Local aBrowseFields		:= {}    
Local aFilSel			:= {}  
Local cArqInd			:= ''
Local cArqDbf1 			:= ''  
Local cArqDbf2  		:= ''  
Local cAlias			:= 'SP3'  
Local cAliasTmp1		:= 'WRK1'  
Local cAliasTmp2		:= 'WRK2'  
Local cMarca			:= GetMark()
Local cFilSP3 			:= xFilial("SP3")  
Local lSP3Exclusivo		:= FWModeAccess("SP3", 3) == "E"	//!Empty(cFilSP3)

//Opcao padrao para alteracao
Private nOpc	:= 4
Private nOpcA	:= 0
Private aTrocaF3 := {}

Private cMarK			:= GetMark()  
Private cSpaceMarca		:= Space(Len(cMark))

Private aAuxCols := {}
Private aAuxHeader
Private aBkpColsMes := {}

Private lGestaoCorp := fIsCorpManage()	//--Iif( FWSizeFilial() > 2, .T., .F.)	//-Indica se esta configurado como Gestao Corporativa na P11

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define o Bloco de Definicao de Botoes 	   	   			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//-- Somente disponbiliza botao de copia de feriado quando a
//-- tabela de feriado for exclusiva
IF lSP3Exclusivo
	aAdd(;
		aBotoes	,;
		{;
			"BMPCPO"				,;
			bfCopiaFeriado			,;
			OemToAnsi( STR0008 )	,; //"Copia Feriado <F4>..."
			OemToAnsi( STR0009 )	;  //"Copia"
		};
		)
	SetKey(VK_F4,bfCopiaFeriado)
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Cria um Arquivo temporario com as filiais disponiveis		   ³
	³ para o Usuario para posterior replicacao dos feriados		   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	CriaArqFil(cMarca, @aBrowseFields, @cArqDbf1, @cArqInd, cAliasTmp1, @cArqDbf2, cAliasTmp2, cFilSP3)
	
EndIF

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Inicializa __aStaticFeriado                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
RstfFeriado()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .F. } )
aObjSize		:= MsObjSize( aInfoAdvSize, aObjCoords )

aCols := MntCols(@aHeader,cAlias)

If Empty(aCols)
	nOpc  := 3
	aCols := MntCols(nOpc,@aHeader,cAlias)
	nOpc  := 4
EndIf

//-Busca posicao do campos no aHeader
If lGestaoCorp
	nPosFil2	:= GdFieldPos( "P3_GCGRPE", aHeader )
	nPosFil3	:= GdFieldPos( "P3_GCUNEG", aHeader )
EndIf
//nPosFil		:= GdFieldPos( "P3_FILIAL", aHeader )
nPosFil		:= GdFieldPos( "P3_GCFIL", aHeader )

nPosData	:= GdFieldPos( "P3_DATA", aHeader )
nPosDesc	:= GdFieldPos( "P3_DESC", aHeader )
nPosTPEx	:= GdFieldPos( "P3_TPEXT", aHeader )
nPosFixo	:= GdFieldPos( "P3_FIXO", aHeader )
nPosTPEN	:= GdFieldPos( "P3_TPEXTN", aHeader )
nPosMDia	:= GdFieldPos( "P3_MESDIA", aHeader )
nPosTipo	:= GdFieldPos( "P3_TIPO", aHeader )
nPosTCod	:= GdFieldPos( "P3_TIPCOD", aHeader )
nPosRcno	:= GdFieldPos( "P3_REC_WT", aHeader )

//Define tela principal
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0002) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL // "Calendario - Feriados"

//-Apresenta Msg de Observacao
@ aObjSize[1,1]+10,aObjSize[1,2]+175 SAY OemToAnsi(STR0026) COLOR CLR_HRED OF oDlg PIXEL	//-"Observações !"
@ aObjSize[1,1]+17,aObjSize[1,2]+175 SAY OemToAnsi(STR0027) COLOR CLR_HBLUE OF oDlg PIXEL	//-"1. Clique duas vezes no dia desejado para incluir um novo feriado."
@ aObjSize[1,1]+24,aObjSize[1,2]+175 SAY OemToAnsi(STR0034) COLOR CLR_HBLUE OF oDlg PIXEL	//-"2. Movimente-se pelos Meses usando a 'seta simples' existente no topo do calendário."
@ aObjSize[1,1]+31,aObjSize[1,2]+175 SAY OemToAnsi(STR0035) COLOR CLR_HBLUE OF oDlg PIXEL	//-"3. Movimente-se pelos Anos usando a 'seta dupla' existente no topo do calendário."
//??@ aObjSize[1,1]+24,aObjSize[1,2]+175 SAY OemToAnsi(STR0028) COLOR CLR_HBLUE OF oDlg PIXEL	//-"2. Para copiar um feriado, posicione no item desejado e clique no botão de cópia."

//Cria o objeto calendario
oCalend := MsCalend():New(aAdvSize[2]+5,aAdvSize[1],oDlg)

oCalend:dDiaAtu		:= dDataBase
oCalend:bLDblClick	:= {||	Iif(Len(oGetDados:aCols)>0, TrocArray(aAuxHeader,@aCols,oGetDados:aCols,.T.),),; 
							oGetDados:aCols := aAuxCols := CriaLin(oDlg,oCalend,aCols,oGetDados:aCols),;
							oGetDados:oBrowse:nAT := Len(aAuxCols),;
							oGetDados:nAT := Len(aAuxCols);
						}

oCalend:bChangeMes	:= {||	Iif(Len(oGetDados:aCols)>0, TrocArray(aAuxHeader,@aCols,oGetDados:aCols),),; 
							oGetDados:aCols := aAuxCols := CargArray(oDlg,oCalend,aCols,aAuxHeader),;
							myRefresh(oDlg);
						}

//Valida as datas que irao ser vizualizadas na getdados
aAuxCols 	:= CargArray(oDlg,oCalend,aCols,aHeader)
aAuxHeader  := aHeader

//Cria bloco do INIT do Dialog
bDialogInit := {||	EnchoiceBar( oDlg, bSet15, bSet24, NIL, aBotoes ),;
					oDlg:Refresh() ;
				}
oDlg:bSet15 := bSet15
oDlg:bSet24 := bSet24

//Cria get dados ( GD_INSERT+GD_UPDATE+GD_DELETE )
oGetDados := MsNewGetDados():New(	aAdvSize[2]+85,;	// nTop
									aAdvSize[1],;		// nLelft
									aAdvSize[4],;		// nBottom
									aAdvSize[3],;		// nRright
									( GD_UPDATE+GD_DELETE ),;
									"GPEA440LinOk",;
									"GPEA440TudoOk",;
									NIL,;	// cIniCPOS
									NIL,;	// aAlter
									NIL,;	// nfreeze colunas
									NIL,;	// nMax linhas
									NIL,;	// cFieldOK
									NIL,;	// uSuperDel
									.T.,;	// udelOK
									oDlg,;
									aAuxHeader,;
									aAuxCols;
								)
									
ACTIVATE DIALOG oDlg ON INIT Eval ( bDialogInit ) CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava os registros no SP3									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcA = 1
	TrocArray(aAuxHeader,@aCols,oGetDados:aCols)
	fGravaSP3(aAuxHeader,aCols)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para SP3 exclusivo											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lSP3Exclusivo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Elimina Arquivo Temporario e Indice							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !Empty(Select(cAliasTmp1))
		dbSelectArea(cAliasTmp1)
		dbCloseArea()
		Ferase(cArqDbf1+GetDBExtension())
		Ferase(cArqDbf1+OrdBagExt())
	EndIF
	
	If !Empty(Select(cAliasTmp2))
		dbSelectArea(cAliasTmp2)
		dbCloseArea()
		Ferase(cArqDbf2+GetDBExtension())
	EndIF
EndIF

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Destroi __aStaticFeriado                                    ³		//?? oGetDados:oBrowse:lFocusOnFirst := .T.	(bLostFocus)
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
RstfFeriado()
RestKeys( aSvKeys , .T. )

RestArea(aArea)
Return( NIL )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fFilFerDia   ³ Autor ³Mauricio MR		   ³ Data ³21/12/06  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Identifica as filiais que possuem feriado no dia atual		 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                  	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Pona440	                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function fFilFerDia(		cAliasTmp1,;	// Alias do arquivo temporario com as filiais para selecao
						        lSP3Exclusivo,;
						        dData,;
						        cTipo,;
						        cTipCod ;
						  )

Local aAliasArea	:= (cAliasTmp1)->(GetArea())  
Local aSP3Area		:= SP3->(GetArea())

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Corre o arquivo Temporario para verificar as filiais que pos-³
³suem feriado para o dia.									  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
dbSelectArea(cAliasTmp1)
 
DbGotop()

While !Eof()
			
	TrataArq(FWGETCODFILIAL, lSP3Exclusivo, cAliasTmp1, Recno(),.T.)
    dbSkip()
    
End While   

DbGotop()

While !Eof()
			
	//-fFeriado( cFil, dDate, cDesc, cTipo, cTipCod )
	IF ( fFeriado( FWGETCODFILIAL, dData, ,cTipo ,cTipCod ) ) 
	  	  TrataArq(FWGETCODFILIAL, lSP3Exclusivo, cAliasTmp1, Recno())
    Endif
    dbSkip()
    
End While         

RestArea(aSP3Area)
RestArea(aAliasArea)

Return (Nil)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³SelecFil     ³ Autor ³Mauricio MR		   ³ Data ³07/03/2005³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Seleciona Filiais											 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                  	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Pona440	                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Static Function fCopiaFeriado(	cAliasOpc		,; //	Alias do temporario para selecao de filiais
								cAliasTit		,; //	Alias do temporario com dados da filial origem do feriado
								cMark			,; //	Marca do MarkBrowse
								aBrowseFields	,; //	Campos a serem mostrados no MarkBrowse	
								cFilSP3			,; //	Filial do SP3
								oCalend			,; // 	Objeto Calendario
								dData			,;
								cTipo			,;
								cTipCod			;
							 )    

Local aSP3Area			:= SP3->(GetArea())							 

Local aSvKeys			:= GetKeys()
Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjCoords		:= {}
Local aObjSize			:= {}
Local aButtons			:= {}  
                                  
Local bSet15 			:= { || NIL }
Local bSet24			:= { || NIL }
Local bInitDlg			:= { || NIL } 
Local bLDblClick		:= { || RhMkMrk( cAliasOpc , .F., .F. , cCpoCtrl, cMark ),oDlg:Refresh() }
Local bAllMark			:= { || RhMkAll( cAliasOpc , .F., .T. , cCpoCtrl, cMark ),oDlg:Refresh() } 
Local bAllUnMark		:= { || RhMkAll( cAliasOpc , .T., .T. , cCpoCtrl, cMark ),oDlg:Refresh() }

Local aTitCpo			:= {}
Local aMsSlt1Coords		:= {}
Local aMsSlt2Coords		:= {}

Local aFilSel			:= {}

Local cAlias 			:= Alias()

Local cCpoCtrl			:= 'MARK'   
Local cMsg				:= ""
Local lInverte			:= .F.   
Local nOpca				:= 1  

Local oDlg
Local oFontRed  
Local oGroup
Local oMsSelect  
Local oMsFilial    

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Inicializa __aStaticFeriado                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
RstfFeriado()

Begin Sequence
    
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Posiciona no Feriado da Filial Corrente		       	   	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	//-fFeriado( cFil, dDate, cDesc, cTipo, cTipCod )
	SP3->( fFeriado( cFilSP3, dData, , cTipo, cTipCod ))
	 
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Define a Tecla de Atalho para Marcar Todos <F9>       	   	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	bMarkAll	:= { || CursorWait() ,;
						Eval(bAllMark),;
						CursorArrow(),;
						SetKey( VK_F6 , bMarkAll );
					}
	aAdd( aButtons ,	{;
							"CHECKED"							,;
	       					bMarkAll							,;
	    					OemToAnsi( STR0022 )				,;			//"Marca Todos...<F6>"
	    					OemToAnsi( STR0023 )				 ;			//"Mc.Todos"
	       				};
		)
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Define a Tecla de Atalho para Desmarcar Todos <F10>   	   	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	bUnMarkAll	:= { || CursorWait() ,;
						Eval(bAllUnMark),;		
						CursorArrow(),;
						SetKey( VK_F7 , bUnMarkAll );
					}
	aAdd( aButtons ,	{;
							"UNCHECKED"							,;
	       					bUnMarkAll							,;
	    					OemToAnsi( STR0024 )				,;		//"Inverte...<F7>"
	    					OemToAnsi( STR0025 )			 	;		//"Inverte"
	       				};
		)
  	  	
   	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define os Blocos para as Teclas <CTRL-O>					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	bSet15 	:= { || GetKeys()											,;
					aFil := {}											,;
					FilSel( cAliasOpc, @aFilSel )						,;
					Iif( !Empty(aFilSel)								,;
						(ReplicaFeriado(aFilSel, dData, cTipo, cTipCod)	,;
						oDlg:End() )									,;
					MsgAlert(OemToAnsi(STR0021))						; //"Nenhuma filial selecionada"
					) 													;
			   }
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define os Blocos para as Teclas <CTRL-X>     	   			   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	bSet24	:= { ||  GetKeys() ,oDlg:End() }
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define o Bloco para o Init do Dialog         	   			   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	bInitDlg := { ||	Eval( oMsSelect:oBrowse:bGotop )	,;
						oMsSelect:oBrowse:Refresh()			,;
						SetKey( VK_F6 	, bMarkAll		) 	,;
						SetKey( VK_F7	, bUnMarkAll	) 	,;
						CalendBar( oDlg , bSet15 , bSet24 , aButtons );
			 	}
	 
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes para o Dialogo Principal				   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aAdvSize	:= MsAdvSize()

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos                               ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	
	aAdd( aObjCoords , { 010 , 010 , .T. , .F. } )	//01
	aAdd( aObjCoords , { 010 , 010 , .T. , .F. } )
	aAdd( aObjCoords , { 010 , 010 , .T. , .F. } )	//03
	aAdd( aObjCoords , { 010 , 010 , .T. , .F. } )
	aAdd( aObjCoords , { 010 , 010 , .T. , .F. } )	//05
	aAdd( aObjCoords , { 010 , 010 , .T. , .F. } )
	aAdd( aObjCoords , { 010 , 020 , .T. , .F. } )	//07
	aAdd( aObjCoords , { 300 , 030 , .T. , .F. } )  //nLargura, nComprimento, lDimensiona Larg, lDimensiona Compr.
	aAdd( aObjCoords , { 010 , 020 , .T. , .F. } )	//09
	aAdd( aObjCoords , { 300 , 100 , .T. , .F. } )
	
	//-Define os blocos da tela
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	aObjSize[8,2]   := 12
	aObjSize[9,2]   := 12 
	
	aMsSlt1Coords	:= { aObjSize[08,3] * 0.756, aObjSize[08,2] * 0.85, aObjSize[08,4] * 0.363, aObjSize[08,4] * 0.725 }
	aMsSlt2Coords	:= { aObjSize[08,4] * 0.383, aObjSize[08,2] * 0.85, aObjSize[08,4] * 0.519, aObjSize[08,4] * 0.725 }
			
	aEval(aBrowseFields,{|acpos| Iif( acpos[1] <> cCpoCtrl, AADD(aTitCpo, acpos ), Nil ) } )
	
	aAdvSize[5]	:= (aAdvSize[5]/100) * 73.9
	aAdvSize[6]	:= (aAdvSize[6]/100) * 103.5
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Dialogo 						                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0002 ) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL OF oMainWnd // "Calendario - Feriados"
	DEFINE FONT oFontRed NAME "Verdana" SIZE 0,-9 BOLD  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informacoes sobre o feriado da filial corrente			     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fShowFer(oDlg,aObjSize[1],aObjSize[2],aObjSize[3],aObjSize[4],aObjSize[5],aObjSize[6],dData,cTipo,cTipCod)
	
	@ aObjSize[8,3] * 0.69,aObjSize[8,2]  * 0.85 SAY OemToAnsi(STR0011) SIZE aObjSize[1,4] * 0.40, aObjSize[1,1] * 0.60 OF oDlg PIXEL FONT oFontRed COLOR CLR_HRED // "COPIAR da filial corrente..."
	@ aObjSize[8,3] * 0.738,aObjSize[8,2] * 0.85 TO aObjSize[8,3] * 0.748,aObjSize[8,4] * 0.725 OF oDlg PIXEL
 	
	oMsFilial := MsSelect():New(;
									cAliasTit		    ,;	//01-Alias do Arquivo com a Filial Corrente
									Nil        			,;	//02-Campo para controle do mark
				 					Nil					,;	//03-Condicao para o Mark
									aTitCpo				,;	//04-Array com os Campos para o Browse - aTitCpo
									.F.					,;	//05-lInverte
									Nil					,;	//06-Conteudo a Ser Gravado no campo de controle do Mark
									aMsSlt1Coords		,;	//07-Coordenadas do Objeto
									Nil					,;  //08-?
									Nil					,;	//09-?	
									oDlg			 	;	//10-Objeto Dialog
							)
	
	@ aObjSize[08,4] * 0.362,aObjSize[08,2] * 0.85 SAY OemToAnsi(STR0012) SIZE aObjSize[1,4] * 0.40, aObjSize[1,1] * 0.60 OF oDlg PIXEL FONT oFontRed COLOR CLR_HRED // "PARA as filiais selecionadas abaixo:"
	@ aObjSize[08,4] * 0.377,aObjSize[08,2] * 0.85 TO aObjSize[08,4] * 0.380,aObjSize[08,4]  * 0.725 OF oDlg PIXEL
	
	(cAliasOpc)->(Dbseek(cFilSP3))
	
   	oMsSelect := MsSelect():New(;
									cAliasOpc		,;	//Alias	do Arquivo de Filtro
									cCpoCtrl        ,;	//Campo para controle do mark
				 					Nil			    ,;	//Condicao para o Mark
									aBrowseFields	,;	//Array com os Campos para o Browse
									.F.				,;	//lInverte
									cMark			,;	//Conteudo a Ser Gravado no campo de controle do Mark
									aMsSlt2Coords	,;	//Coordenadas do Objeto
									NIL				,;  //?
									NIL				,;	//?	
									oDlg			 ;	//Objeto Dialog
							)
	
	oMsSelect:oBrowse:lCanAllMark	:= .T.
	oMsSelect:oBrowse:lHasMark	 	:= .T.  
   	oMsSelect:bMark	 				:= bLDblClick     
	oMsSelect:oBrowse:bAllMark      := bMarkAll 
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( bInitDlg )
	
	RestKeys( aSvKeys , .T. )
	
End

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Destroi __aStaticFeriado                                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
RstfFeriado()

RestArea(aSP3Area)
Return   

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³RhMkAll      ³ Autor ³Mauricio MR		   ³ Data ³07/03/2005³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Marca/Desmarca todos os elementos do browse   		         ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                  	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³PONA440                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Static Function RhMkAll( 	cAlias		,; // Alias do temporario para selecao das filiais
							lInverte	,; // Se inverte a selecao	
							lTodos		,; // Se inverte todas as selecoes	
							cCpoCtrl	,; // Campo de Selecao
							cMark		;  // Marca da Selecao 
						)   
Local nRecno		:= (cAlias)->(Recno())

(cAlias)->( dbGotop() )

While (cAlias)->( !Eof() )  
	
	RhMkMrk( cAlias , lInverte , lTodos, cCpoCtrl, cMark)
	
	(cAlias)->( dbSkip() )
End While

(cAlias)->( MsGoto( nRecno ) )
        
Return

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³RhMkMrk      ³ Autor ³Mauricio MR		   ³ Data ³07/03/2005³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Marca/Desmarca um elemento do browse   				         ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                  	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³PONA440                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Static Function RhMkMrk( 	cAlias		,; // Alias do temporario para selecao das filiais
							lInverte	,; // Se inverte a selecao	
							lTodos		,; // Se inverte todas as selecoes	
							cCpoCtrl	,; // Campo de Selecao
							cMark		;  // Marca da Selecao 
						) 
Local cTemp

DEFAULT cAlias		:= Alias()

If lTodos
    If lInverte
	   	If IsMark( cCpoCtrl, cMarK) 
		  cTemp:= cSpaceMarca   
		Else
	      cTemp:= cMark
		Endif   
	Else 
		cTemp:=cMark   
	Endif	
Else        
	If IsMark( cCpoCtrl, cMarK, lInverte) 
		cTemp:= If(lInverte, cSpaceMarca, cMark)   
	Else
	   cTemp:= If(lInverte, cMark, cSpaceMarca)   
	Endif   
Endif	    

//-- Alteracao Selecao
(cAlias)->(RecLock(cAlias,.F.))
	&(cAlias+'->'+cCpoCtrl) := cTemp
(cAlias)->(MsUnlock())

Return .T.

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³CriaArqFil   ³ Autor ³Mauricio MR		   ³ Data ³21/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Cria Arquivo de Filiais a serem selecionadas	  	         ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                  	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³PONA440                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Static Function CriaArqFil(	cMarca				,; // Marca da Selecao
							aBrowseFields		,; // Campos que serao mostrados no MarkBrowse
							cArqDbf1			,; // Nome do arquivo Temporario com as Filiais para selecao
							cArqInd				,; // Nome do indice do arquivo Temporario com as Filiais para selecao
							cAliasTmp1			,; // Alias do arquivo Temporario com as Filiais para selecao
							cArqDbf2			,; // Nome do arquivo Temporario com a Filial corrente do feriado
							cAliasTmp2			,; // Alias do arquivo Temporario com a Filial corrente do feriado
							cFilSP3				;  // Filial do SP3
						  )

Local aSM0Area		:= SM0->(GetArea()) 
Local aArea			:= GetArea()
Local aFields		:= 	{} 
Local aTitulosCpos 	:=	{ 	{ "M0_FILIAL"	, "FILIAL" 		} ,;
							{ "M0_NOME"		, "NOME"  		} ,;
							{ "M0_CIDENT"	, "CIDADE"  	} ,;
							{ "M0_ESTENT"	, "ESTADO"  	} ,;
							{ "M0_ENDENT"	, "ENDERECO"  	} ,;
							{ "M0_CEPENT"	, "CEP"	  		} ;
						}	

Local cArq			:= ""		
Local cIndCond
Local cMsg			:= OemToANSI(STR0010) //'Selecionando Registros...'
Local cTitulo                            
Local cDataFile		
Local cExt			:= GetDbExtension()
Local cRotina		:= 'PONA440'  
Local cSpaceMarca	:= 	Space(Len(cMarca))
Local lRet			:= .T.   
Local nLoop		
Local nOriginal		
Local nPosCpo
Local nTotLoop	

If !Empty(Select('WRK1'))
	dbSelectArea('WRK1')
	dbCloseArea()
	Ferase(cArqDBF1+GetDBExtension())
	Ferase(cArqDBF1+OrdBagExt())
Endif

//-- Adiciona Campo de Selecao para o MarkBorwse
AADD(aFields		,{'MARK'	,	'C'		,2	,	0 	})
AADD(aBrowseFields	,{'MARK'	, 	cRotina	, "ok"		}) //OK
aSM0Estruct:= SM0->(DbStruct())

//-- Adiciona Demais Campos do Arquivo Temporario
nTotLoop	:= Len(aSM0Estruct)  

For nLoop:=1 To nTotLoop
	AADD(aFields,{	aSM0Estruct[nLoop,1]    ,;
               		aSM0Estruct[nLoop,2]  	,;
					aSM0Estruct[nLoop,3]  	,;
					aSM0Estruct[nLoop,4]  	,;	  
				  };
	      )  
	      
   IF (nPos:=Ascan(aTitulosCpos, {|cCpo| cCpo[1] ==Alltrim(Upper(aSM0Estruct[nLoop,1] )) 	}) ) > 0
		cTitulo:= aTitulosCpos[nPos,2]		      
   Else     
   		cTitulo:=StrTran(aSM0Estruct[nLoop,1],'SM0_',"") 
   		Loop
   Endif 	 
         
   AADD(aBrowseFields,{	aSM0Estruct[nLoop,1]  , cRotina, cTitulo } )
Next nLoop



IF ( lRet := ( Select( cAliasTmp1 ) > 0.00 ) )
	cIndCond := 'M0_CODFIL'
	cArqInd  := FileNoExt(cArqDBF1)
	IndRegua(cAliasTmp1,cArqInd,cIndCond,,,cMsg ) // Sem mensagem
	nTotLoop	:= Len(aFields)  
	
	//-- Transfere as Filiais da empresa para o array de opcoes               
	dbSelectArea("SM0")
	SM0->(dbSeek(cEmpAnt))

	While SM0->(!Eof() .and. SM0->M0_CODIGO == cEmpAnt )
        
		//-- Se a filial eh valida para o usuario
		If  !( FWGETCODFILIAL $ fValidFil() )
	    	SM0->( dbSkip() )
			Loop
		Endif
        
        If FWGETCODFILIAL == cFilSP3  
           cArq:= cAliasTmp2
        Else
           cArq:= cAliasTmp1
        Endif   
       
    	(cArq)->(Reclock(cArq,.T.) )  
		
		//-- TransferE o registro para o registro com a estrutura alterada
		For nLoop:=1 to nTotLoop               
	
	   	    //-- Trata o campo de 'Selecao' de Filial
	   	    If aFields[nLoop,1] == 'MARK'
		   	   (cArq)->MARK 		:= cSpaceMarca
			Else
				//-- Transfere o conteudo do campo original para o da nova estrutura do arquivo temporario    
				(cArq)->(FieldPut(nLoop, SM0->( &(aFields[nLoop,1]) )) )
			EndIf
					
		Next nLoop    
		
		(cArq)->(MsUnlock())
	    (cArq)->(FkCommit())
		
		dbSelectArea("SM0")
    	SM0->(dbSkip())
	 Enddo   

	(cAliasTmp1)->( dbGotop() )
	(cAliasTmp2)->( dbGotop() )
EndIF	

RestArea(aSM0Area)
RestArea(aArea) 
Return( lRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TrataArq()		³ Autor ³Mauricio MR           ³ Data ³22/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Atualiza o estado de selecao das filiais						 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>										 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>										 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL																 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                	      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³PONA440     													 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/ 
Static Function TrataArq(	cFil			,; // Filial do SM0
							lSP3Exclusivo	,; // Se o SP3 eh excluisivo
							cAliasTmp1		,; // Alias do temporario do arquivo de selecao de filiais
							nRecno			,; // Recno da Filial do SM0
							lDeleta			;  // Indica se a marca deve ser retirada da filial selecionada
						)    
Local cConteudo := ""
Local lFound	:= .F.

DEFAULT lDeleta	:= .F. 

IF lSP3Exclusivo
	cConteudo := IF(lDeleta, cSpaceMarca, cMark)

	If !Empty(nRecno)
	    lFound:= .T.	
	Else
	    lFound:= (cAliasTmp1)->(Dbseek(cFil))
	Endif

	IF lFound
		(cAliasTmp1)->(RecLock(cAliasTmp1,.F.))
		(cAliasTmp1)->MARK := cConteudo
		(cAliasTmp1)->(MsUnlock())
	EndIF
Endif

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fProgAtual()	³ Autor ³Mauricio MR           ³ Data ³22/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Controla recursividade de chamada de funcao via tecla programada ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>										 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>										 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL																 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                	      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³SIGAPON     													 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/ 
Static function fProgAtual()
Local lRet			:= .T.
Local cProcName3	:= Upper( AllTrim( ProcName( 3 ) ) )
Local cProcName5	:= Upper( AllTrim( ProcName( 5 ) ) )

lRet:=( "PONA440" $ ( cProcName3 + cProcName5 ) )

Return (lRet) 

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fChamaTelaCopia() ³ Autor ³Mauricio MR         ³ Data ³22/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Controla a chamada da tela para copia dos dados do feriado		 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>										 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>										 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL																 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                	      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³SIGAPON     													 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/ 
Static Function fChamaTelaCopia(	cFilSP3			,; // Filial do SP3
									oCalend			,; // Objeto Calendario
									lSP3Exclusivo	,; // Indica se o SP3 eh exclusivo
									cAliasTmp1		,; //	Alias do temporario para selecao de filiais
									cAliasTmp2		,; //	Alias do temporario com dados da filial origem do feriado
									cMark			,; //	Marca do MarkBrowse
									aBrowseFields	; //	Campos a serem mostrados no MarkBrowse	
							   ) 
Local lRet		:= 	.F.
Local aSP3Area	:=	SP3->(GetArea())  

Local nMyAT		:= oGetDados:nAT
Local dData		:= oGetDados:aCols[nMyAT,nPosData]
Local cTipo		:= oGetDados:aCols[nMyAT,nPosTipo]
Local cTipCod	:= oGetDados:aCols[nMyAT,nPosTCod]

//-- Se existir feriado na Data (ou no mes/dia para feriados fixos)
IF  SP3->( fFeriado(cFilSP3, dData, , cTipo, cTipCod) )
	//-- Garante o retorno a posicao originial
	SP3->( MsGoto(aSP3Area[3]) )
	//-- Obtem a relacao de Filiais para selecao
    Iif( lSP3Exclusivo, fFilFerDia(cAliasTmp1, , dData, cTipo, cTipCod), NIL )
	//-- Abre um dialogo para escolha e replicacao dos dados do feriado
	fCopiaFeriado(cAliasTmp1, cAliasTmp2, cMark, aBrowseFields, cFilSP3, oCalend, dData, cTipo, cTipCod)   

	lRet	:= .T.
Else
	MsgAlert(OemToAnsi(STR0014))  //"O dia nao eh feriado"
EndIF

//-- Garante o retorno a posicao originial
SP3->(MsGoto(aSP3Area[3]))  

Return (lRet)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fShowFer()		³ Autor ³Mauricio MR           ³ Data ³26/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Mostra as informacoes do feriado da filial corrente.			 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>										 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>										 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL																 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                	      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³SIGAPON     													 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/ 
Static Function fShowFer(		oDlg2	,; // Dialogo que contera a replicacao do feriado
								aObj1	,; // Texto: Dados do Feriado
								aObj2	,; // Texto: Data
								aObj3	,; // Texto: Descricao
								aObj4	,; // Texto: HE normal
								aObj5	,; // Texto: HE noturna
								aObj6	,; // Texto: Feriado Fixo
								dData	,;
								cTipo	,;
								cTipCod	;
						) 

Local aNormal		:= {}
Local aNoturna		:= {}
Local aFixo	 		:= {}

Local cDesc     	:= ""
Local cData			:= ""
Local cTpNormal 	:= ""
Local cTpNoturn 	:= ""
Local cTpFixo   	:= ""   

Local cDescricao
Local cTpExt
Local cTpExtN
Local cFerFix

Local oFont1   
Local oFont2     
Local oGroup

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

DEFINE FONT oFont1 NAME "Verdana" SIZE 0,-10 BOLD
DEFINE FONT oFont2 NAME "Verdana" SIZE 0,-11 BOLD
                                
aNormal  	:= Sx3Box2Arr( "P3_TPEXT"  )
aNoturna	:= Sx3Box2Arr( "P3_TPEXTN" )
aFixo		:= Sx3Box2Arr( "P3_FIXO"   )

cDescricao	:= SP3->P3_DESC  

cTpExt		:= StrTran( aNormal[ Ascan(aNormal,{|x| Substr(x,1,1) == SP3->P3_TPEXT })]	, "=", "-" )
cTpExtN		:= StrTran( aNoturna[ Ascan(aNoturna,{|x|Substr(x,1,1) == SP3->P3_TPEXTN })]	, "=", "-" )
cFerFix		:= StrTran( aFixo[ Ascan(aFixo,{|x| Substr(x,1,1) == SP3->P3_FIXO })]	, "=", "-" )

SetCursor(1)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 015 , 020 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
aObjSize[1,2] := 85
aObjSize[2,2] := 85

@ aObjSize[1,2] * 0.145, aObjSize[1,2] * 0.135 SAY OemToAnsi(STR0013)	SIZE aObjSize[1,4] * 0.40, aObjSize[1,1] * 0.60 OF oDlg2 PIXEL FONT oFont1 // "Dados do feriado:"
@ aObjSize[1,2] * 0.215,aObjSize[1,2] * 0.135 TO aObjSize[1,2]*0.23, aObjSize[1,4]*0.439 OF oDlg2  PIXEL 

@ aObjSize[1,2] * 0.275,aObjSize[1,2] * 0.135 SAY OemToAnsi(STR0003)	SIZE aObjSize[1,4] * 0.30, aObjSize[1,2] * 0.07 OF oDlg2 PIXEL FONT oFont1 // "Data: "
@ aObjSize[1,2] * 0.24,aObjSize[1,2] * 0.58 MSGET Dtoc(dData)			SIZE aObjSize[1,4] * 0.305, aObjSize[1,3] * 0.05 OF oDlg2 PIXEL FONT oFont1 WHEN .F. COLOR  CLR_HRED

@ aObjSize[1,2] * 0.405,aObjSize[1,2] * 0.135 SAY OemToAnsi(STR0004)	SIZE aObjSize[1,4] * 0.30, aObjSize[1,2] * 0.07 OF oDlg2 PIXEL FONT oFont1// "Descri‡„o: "
@ aObjSize[1,2] * 0.37,aObjSize[1,2] * 0.58 MSGET oGet VAR cDescricao	SIZE aObjSize[1,4] * 0.305, aObjSize[1,3] * 0.05 OF oDlg2 PIXEL FONT oFont1 WHEN .F. PICTURE PesqPict("SP3","P3_DESC")

@ aObjSize[1,2] * 0.54,aObjSize[1,2] * 0.135 SAY OemToAnsi(STR0005)		SIZE aObjSize[1,4] * 0.30, aObjSize[1,2] * 0.07 OF oDlg2 PIXEL FONT oFont1 // "Tp.HE.Nor."
@ aObjSize[1,2] * 0.50,aObjSize[1,2] * 0.58 MSGET  oGet VAR cTpExt		SIZE aObjSize[1,4] * 0.305, aObjSize[1,3] * 0.05 OF oDlg2 PIXEL FONT oFont1 WHEN .F.

@ aObjSize[1,2] * 0.675,aObjSize[1,2] * 0.135 SAY OemToAnsi(STR0006)	SIZE aObjSize[1,4] * 0.30, aObjSize[1,2] * 0.07 OF oDlg2 PIXEL FONT oFont1 // "Tp.HE.Noct."
@ aObjSize[1,2] * 0.63,aObjSize[1,2] * 0.58 MSGET  oGet VAR cTpExtN		SIZE aObjSize[1,4] * 0.305, aObjSize[1,3] * 0.05 OF oDlg2 PIXEL FONT oFont1 WHEN .F.

@ aObjSize[1,2] * 0.795,aObjSize[1,2] * 0.135 SAY OemToAnsi(STR0007)	SIZE aObjSize[1,4] * 0.30, aObjSize[1,2] * 0.07 OF oDlg2 PIXEL FONT oFont1 // "Feriado Fixo"
@ aObjSize[1,2] * 0.76,aObjSize[1,2] * 0.58 MSGET  oGet VAR cFerFix		SIZE aObjSize[1,4] * 0.305, aObjSize[1,3] * 0.05 OF oDlg2 PIXEL FONT oFont1  WHEN .F.

dbSelectArea("SP3")

Return (Nil)	

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³CalendBar()		³ Autor ³Mauricio MR           ³ Data ³26/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Monta barra customizada para calendario de feriados.			 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>										 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>										 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL																 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                	      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³SIGAPON     													 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 
Static Function CalendBar( 	oDlg 		,; // Dialogo que contera a barra de botoes
 							bConfirma	,; // Bloco de acao na confirmacao da operacao
 							bCancela	,; // Bloco de acao no cancelamento da operacao
 							aBotoes 	;  // Relacao de botoes adicionais da barra de botoes
 						 )
Local aoBotton
Local nLenaBotoes:= Len(aBotoes)  
Local nX
Local oBar
Local oBtHlp
Local oBtCan     

aoBotton:=Array(nLenaBotoes)            

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON oBtHlp RESOURCE "S4WB016N"  OF oBar GROUP ACTION HelProg()     			TOOLTIP OemToAnsi( STR0015 )	// 'Help de Programa...'
oBtHlp:cTitle:= OemToAnsi(STR0018)	// "Help"

IF bConfirma <> Nil
	DEFINE BUTTON oBtOk RESOURCE "OK"   OF oBar GROUP		ACTION Eval( bConfirma )	TOOLTIP OemToAnsi( STR0019 )	// 'Ok - <Ctrl-O>'
	oDlg:bSet15 	:= oBtOk:bAction
	oBtOk:cTitle	:= OemToAnsi(STR0020)	// "Ok"  
	SetKey( 15 , oDlg:bSet15 )
EndIF

DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar GROUP		ACTION Eval( bCancela )		TOOLTIP OemToAnsi( STR0016 )  	// 'Cancelar - <Ctrl-X>'
oDlg:bSet24 	:= oBtCan:bAction
oBtCan:cTitle	:= OemToAnsi(STR0017)	// "Cancelar"  
SetKey( 24 , oDlg:bSet24 )

//-- Adiciona novos botoes
For nX:=1 to nLenaBotoes 
	DEFINE BUTTON aoBotton[nX] RESOURCE aBotoes[nX,1] OF oBar GROUP	 TOOLTIP OemToAnsi( aBotoes[nX,3] )  			   // Titulo Completo
	aoBotton[nX]:cTitle:= aBotoes[nX,4]  //Titulo Sintetico  
	aoBotton[nX]:bAction:=aBotoes[nX,2]  //Bloco de acao para o botao
Next nX      

Return(Nil)      

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ FilSel      ³ Autor ³Mauricio MR		   ³ Data ³26/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Array FINAL com as filiais Selecionadas			  	 		 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                  	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³PONA440                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Static Function FilSel( cAlias	,; // Alias do Temporario com as Filiais selecionadas
						aFilSel ;  // Array que contera as filiais selecionadas
					  )   
Local aArea	:=GetArea()	 

(cAlias)->( dbGotop() )

//-- Corre Todas as Filials disponiveis
While (cAlias)->( !Eof() )  
	
 	//Se Selecionou nova Filial                     
     If !Empty( (cAlias)->MARK )
		//-- Adiciona a Nova Filial 
	 	AADD(aFilSel, FWGETCODFILIAL )
	 Endif
	(cAlias)->( dbSkip() )
End While      

RestArea(aArea)

Return

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ReplicaFeriado ³ Autor ³Mauricio MR		   ³ Data ³26/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Replica Feriado para as Filiais Selecionadas		   		 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                  	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³PONA440                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Static Function ReplicaFeriado(	aFilSel, dData, cTipo, cTipCod )

Local aArea			:= GetArea()	 
Local aAreaSP3		:= SP3->(GetArea())	
Local aStructSP3	:= SP3->(dbStruct())
Local aCpos			:= {}  
Local lAlera		:= .F.
Local nLenaFilSel	:= Len(aFilSel)
Local nX

CursorWait() 
               
//--Armazena o conteudo dos campos do feriado corrente
Aeval(aStructSP3,{|x,y| SP3->(AADD(aCpos, {x[1],&(x[1])} )) } )

//-- Corre todas as filiais selecionadas e replica o feriado corrente
For nX:=1 to nLenaFilSel         
	
	//-- Se existir o feriado para a filial altera o registro
	//-- caso contrario, inclui o feriado
	//-fFeriado( cFil, dDate, cDesc, cTipo, cTipCod )
	lAltera := !fFeriado( aFilSel[nX], dData, , cTipo, cTipCod )
	
	IF SP3->(RecLock("SP3",lAltera))
       Aeval(aStructSP3, {|x,y| TransfCpos(aFilSel[nX], y, aCpos[y,2]) })
       SP3->(MsUnlock()) 
       SP3->(FkCommit())
    EndIF
 
Next nX          

CursorArrow()
   
Return(Nil) 

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TransfCpos 	   ³ Autor ³Mauricio MR		   ³ Data ³27/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Transfere o conteudo dos campos da filial corrente para as   ³
³          ³de destino.                                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                  	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³PONA440                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Static function TransfCpos(	cFilDestino		,; //Filial destino
							nPosCpo			,; //Posicao do campo a ser transferido 
							uConteudo		;  //Conteudo a ser transferido
						  ) 
//-- Altera o conteudo do campo filial para a filial destino
//-- os demais campos sao transferidos para a filial destino
uConteudo := SP3->( Iif(( 'P3_FILIAL' == Upper(Alltrim(FieldName(nPosCpo) ))), cFilDestino ,uConteudo ))

SP3->(FieldPut(nPosCpo,uConteudo))

Return(Nil)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MntCols		³Autor³Equipe Advanced RH ³ Data ³19/03/2007³
³          ³           		|	  | Igor Franzoi      |      |			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Verifica se existem registros para o dia selecionado 		³
³          ³Calendario de Obrigacoes									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³PONA440                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³lRet														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
³		   ³															³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function MntCols(aHeader,cAlias)

Local aCols := {}
Local cChv	:= xFilial(cAlias)

Local nUso
Local aVir   := {}
Local aVis   := {}
Local aNotFields := {}
Local lNotField  := .F.
Local lEverField := .F.	//.T.
Local lVirField  := .F.	//.T.
Local aRecno 	 := {}

//Campos que "nao" serao visualizados na getdados
If lGestaoCorp
	aAdd(aNotFields, "P3_FILIAL")
Else
	aAdd(aNotFields, "P3_FILIAL")
	aAdd(aNotFields, "P3_GCGRPE")
	aAdd(aNotFields, "P3_GCUNEG")
EndIf

//Colunas e linhas da get dados aHeader/aCols
//Obs: para a funcao GDMontaCols funcionar com parametros de visualizar os campos que 
//deseja-se, o campo na tabela deve estar marcado como USADO
aCols := SP3->(GDMontaCols(;
							@aHeader	,;	//01 -> Array com os Campos do Cabecalho da GetDados
							@nUso		,;	//02 -> Numero de Campos em Uso
							@aVir,;			//03 -> [@]Array com os Campos Virtuais
							@aVis,;			//04 -> [@]Array com os Campos Visuais	
							cAlias,;		//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
							aNotFields,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
							@aRecno,;		//07 -> [@]Array unidimensional contendo os Recnos
							cAlias,;		//08 -> Alias do Arquivo Pai
							cChv,;			//09 -> Chave para o Posicionamento no Alias Filho
							NIL,;			//10 -> Bloco para condicao de Loop While
							NIL,;			//11 -> Bloco para Skip no Loop While
							.T.,;			//12 -> Se Havera o Elemento de Delecao no aCols 
							NIL,;			//13 -> Se cria variaveis Publicas
							NIL,;			//14 -> Se Sera considerado o Inicializador Padrao
							NIL,;			//15 -> Lado para o inicializador padrao
							lEverField,;	//16 -> Opcional, Carregar Todos os Campos
							lVirField,;		//17 -> Opcional, Nao Carregar os Campos Virtuais
							NIL,;			//18 -> Opcional, Utilizacao de Query para Selecao de Dados
							NIL,;			//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
							NIL,;			//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
							NIL,;			//21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
							lNotField,;		//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
							NIL,;			//23 -> Verifica se Deve Checar se o campo eh usado
							NIL,;			//24 -> Verifica se Deve Checar o nivel do usuario
							NIL,;			//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
							NIL,;			//26 -> [@]Array que contera as chaves conforme recnos
							NIL,;			//27 -> [@]Se devera efetuar o Lock dos Registros
							NIL,;			//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
							NIL,;			//29 -> Numero maximo de Locks a ser efetuado
							NIL,;			//30 -> Utiliza Numeracao na GhostCol
							NIL,;			//31 -> Carrega os Campos de Usuario
							nOpc;			//32 -> Numero correspondente a operação a ser executada, exemplo: 3 - inclusao, 4 alteracaão e etc;
						);
					 )         
Return aCols

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ CargArray		³Autor³Equipe Advanced RH ³ Data ³19/03/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Valida o dia. Reconstroi o array que ficara na GetDados		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³PONA440                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aDay = array contendo os dados para a GetDados				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³aColsAll = array contendo aCols Pai (Linhas)				³
³		   ³aCabAll  = array contendo aHeader (Campos)					³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function CargArray(oDlg,oCalend,aColsAll)

Local aGetDCols := {}
Local dDat := oCalend:dDiaAtu

Local nContH                //auxiliar para percorrer aHeader
Local nContC				//auxiliar para percorrer aCols                          

//Faz uma pesquisa em aCols a procura do dia desejado
//para definir um novo aCols com os elementos encontrados
For nContC := 1 To Len(aColsAll)
	
	If aColsAll[nContC,nPosFixo] == "S" .And. Month(aColsAll[nContC,nPosData]) == Month(dDat)
		AADD( aGetDCols, aColsAll[nContC] )
		oCalend:AddRestri(Day(aColsAll[nContC,nPosData]),CLR_HRED,CLR_WHITE)
	
	ElseIf aColsAll[nContC,nPosFixo] <> "S" .And. AnoMes(aColsAll[nContC,nPosData]) == AnoMes(dDat)
		AADD( aGetDCols, aColsAll[nContC] )
		oCalend:AddRestri(Day(aColsAll[nContC,nPosData]),CLR_HRED,CLR_WHITE)
		
	EndIf
Next

//# Faz copia do array do mes
aBkpColsMes := aClone(aGetDCols)

Return aGetDCols

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ TrocArray		³Autor³Equipe Advanced RH ³ Data ³23/03/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Validacao das alteracoes na getdados p/ insercao, alteracao	³
³          ³e exclusao dos dados no array pai (aCols)					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³PONA440                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³.T.															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³aCabAll	 = conteudo de aHeader da GetDados (Campos)			³
³		   ³aCols 	 = array contendo aCols Pai (Todas as Linhas)		³
³		   ³aAuxCols = array contendo aAuxCols (Linhas da GetDados)		³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function TrocArray(aCabAll,aCols,aAuxCols,lSoLinha)

Local nContH				//auxiliar para percorrer aHeader
Local nContC				//auxiliar para percorrer aCols
Local nPos1Aux		:= 0
Local nPosDif		:= 0
Local lMyInc		:= .F.
Local nMyAT			:= oGetDados:nAT	//-oGetDados:oBrowse:nAT

Local lTudoIgual	:= .F.

Default lSoLinha	:= .F.

If !lSoLinha
	
	//Busca e atualiza no aCols (Todos os Feriados) os registros do aAuxCols (oGetDados:aCols)
	While !lTudoIgual
	
		//# fCompArray( aArray1 , aArray2 , nPosDif  )
		If !( lTudoIgual := fCompArray( aBkpColsMes, aAuxCols, @nPosDif ) )
		
			If ValType(aAuxCols[nPosDif,nPosData]) == "D" .And. !Empty(aAuxCols[nPosDif,nPosData]) .And. !Empty(aAuxCols[nPosDif,nPosDesc])	//??-P11
				
				//-Alteracao de linha
				If aAuxCols[nPosDif,nPosRcno] > 0
					
					nPos1Aux := aScan(aCols, { |x| x[nPosRcno] == aAuxCols[nPosDif,nPosRcno] })
					
					//-Atualiza o aCols Geral
					For nContH := 1 to Len(aCabAll)+1
						aCols[ nPos1Aux, nContH ] := aAuxCols[ nPosDif, nContH ]
					Next nContH
				
					//-Atualiza o aBkpColsMes para fazer nova comparacao
					For nContH := 1 to Len(aCabAll)+1
						aBkpColsMes[ nPosDif, nContH ] := aAuxCols[ nPosDif, nContH ]
					Next nContH
				
				//-Inclusao de linha
				Else
					//-Atualiza o aCols Geral
					aAdd(aCols, aAuxCols[nPosDif])
					
					//-Atualiza o aBkpColsMes para fazer nova comparacao
					aAdd(aBkpColsMes, aAuxCols[nPosDif])
					lMyInc := .T.
				EndIf
			EndIf
		EndIf
	EndDo
	
Else
	
	If ValType(aAuxCols[nMyAT,nPosData]) == "D" .And. !Empty(aAuxCols[nMyAT,nPosData]) .And. !Empty(aAuxCols[nMyAT,nPosDesc])	//??-P11
		
		//-Alteracao de linha
		If aAuxCols[nMyAT,nPosRcno] > 0
			
			nPos1Aux := aScan(aCols, { |x| x[nPosRcno] == aAuxCols[nMyAT,nPosRcno] })
			
			//-Atualiza o aCols Geral
			For nContH := 1 to Len(aCabAll)+1
				aCols[ nPos1Aux, nContH ] := aAuxCols[ nMyAT, nContH ]
			Next nContH
		
			//-Atualiza o aBkpColsMes para fazer nova comparacao
			For nContH := 1 to Len(aCabAll)+1
				aBkpColsMes[ nMyAT, nContH ] := aAuxCols[ nMyAT, nContH ]
			Next nContH
		
		//-Inclusao de linha
		Else
			//-Atualiza o aCols Geral
			aAdd(aCols, aAuxCols[nMyAT])
			
			//-Atualiza o aBkpColsMes para fazer nova comparacao
			aAdd(aBkpColsMes, aAuxCols[nMyAT])
			lMyInc := .T.
		EndIf
	EndIf
EndIf

If lMyInc
	If lGestaoCorp
		aSort(aCols,,, { |x,y| x[nPosFil2]+x[nPosFil3]+x[nPosFil]+DTOS(x[nPosData])+x[nPosTipo]+x[nPosTCod] < y[nPosFil2]+y[nPosFil3]+y[nPosFil]+DTOS(y[nPosData])+y[nPosTipo]+y[nPosTCod] })
	Else
		aSort(aCols,,, { |x,y| x[nPosFil]+DTOS(x[nPosData])+x[nPosTipo]+x[nPosTCod] < y[nPosFil]+DTOS(y[nPosData])+y[nPosTipo]+y[nPosTCod] })
	EndIf
EndIf

Return ( .T. )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ CriaLin		³Autor³Equipe Advanced RH ³ Data ³17/01/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Reconstroi o array que ficara na GetDados					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³PONA440                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³ aNewLin = array contendo os dados para a GetDados			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³oCalend   = objeto contendo informacoes diversas			³
³          ³aColsAll  = array contendo aCols Pai						³
³		   ³aGetDCols = array contendo aCols (oGetDados)				³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Static Function CriaLin(oDlg,oCalend,aColsAll,aGetDCols)

Local lYesNo  := .T.
Local nPos    := 0
Local n1Cont  := 0
Local n2Cont  := 0
Local dAtuDia := oCalend:dDiaAtu

Default aGetDCols := {}

If Len(aColsAll) > 0
	
	//-P3_FILIAL+DTOS(P3_DATA)+P3_TIPO+P3_TIPCOD
	nPos := aScan(aGetDCols, { |x| DTOS(x[nPosData]) == DTOS(dAtuDia) })
	
	If nPos == 0
		
		//Pinta o dia de Vermelho
		oCalend:AddRestri(Day(dAtuDia),CLR_HRED,CLR_WHITE)
	
		//Cria nova linha no Array
		aAdd(aGetDCols, Array(Len(aColsAll[01])))
		
	Else
		
		If lYesNo := MsgYesNo(	OemToAnsi(STR0031)+CRLF+;	//-"Ja existe Feriado para esse dia!"
								OemToAnsi(STR0032),;		//-"Deseja incluir um novo Feriado no mesmo dia ?"
								OemToAnsi(STR0029) )		//-"Atenção !!!"
			
			//Cria nova linha no Array
			aAdd(aGetDCols, Array(Len(aColsAll[01])))
			
		EndIf
	EndIf
	
	If lYesNo
		For n1Cont := Len(aGetDCols) to Len(aGetDCols)
			For n2Cont := 1 to Len(aGetDCols[01])
				
				If lGestaoCorp .And. n2Cont = nPosFil2 .And. ValType(aColsAll[01,n2Cont]) == "C"
					aGetDCols[n1Cont,n2Cont] := FwCompany()
					
				ElseIf lGestaoCorp .And. n2Cont = nPosFil3 .And. ValType(aColsAll[01,n2Cont]) == "C"
					aGetDCols[n1Cont,n2Cont] := FwUnitBusiness()
					
				ElseIf n2Cont = nPosFil .And. ValType(aColsAll[01,n2Cont]) == "C"
					aGetDCols[n1Cont,n2Cont] := Iif( lGestaoCorp, SubStr(FwFilial(),1,2), FwFilial() )
					
				ElseIf !( ValType(aColsAll[01,n2Cont]) $ "DNL" )
					aGetDCols[n1Cont,n2Cont] := Space(Len(aColsAll[01,n2Cont]))
					
				ElseIf ValType(aColsAll[01,n2Cont]) == "D"
					aGetDCols[n1Cont,n2Cont] := dAtuDia
					
				ElseIf ValType(aColsAll[01,n2Cont]) == "N"
					aGetDCols[n1Cont,n2Cont] := 0
					
				ElseIf ValType(aColsAll[01,n2Cont]) == "L"
					aGetDCols[n1Cont,n2Cont] := .F.
					
				EndIf
					
				If n2Cont = nPosMDia
					aGetDCols[n1Cont,n2Cont] := MesDia(dAtuDia)
				EndIf
			Next n2Cont
		Next n1Cont
	EndIf
EndIf

Return aGetDCols

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGravaSP3 ºAutor  ³Ademar Fernandes    º Data ³ 22/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava no SP3 os registros existentes no aCols.             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PONA440                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGravaSP3(aCabAll,aColsAll)

Local n1Cont  := 0
Local lFind01 := .F.
Local lFind02 := .F.
Local cMyChv  := ""
Local aMyGrv  := {}

If Len(aColsAll) > 0
	dbSelectArea("SP3")
	If !lGestaoCorp
		dbSetOrder(1)	//-P3_FILIAL+DTOS(P3_DATA)+P3_TIPO+P3_TIPCOD
	Else
		dbSetOrder(3)	//-P3_GCGRPE+P3_GCUNEG+P3_GCFIL+DTOS(P3_DATA)+P3_TIPO+P3_TIPCOD
	EndIf
	
	//dbSeek((xFilial("SP3")+DTOS(aColsAll[n1Cont,nPosData])+aColsAll[n1Cont,nPosTipo]+aColsAll[n1Cont,nPosTCod]), .F.)
	For n1Cont := 1 to Len(aColsAll)
		
		//-(*** Linha nao deletada ***)
		If aColsAll[ n1Cont, Len(aCabAll)+1 ] == .F. .And.;
			!Empty(aColsAll[n1Cont,nPosData]) .And. !Empty(aColsAll[n1Cont,nPosDesc])
			
			//-Alteracao de linha
			If aColsAll[n1Cont,nPosRcno] > 0
			
				dbGoTo(aColsAll[n1Cont,nPosRcno])
				RecLock("SP3",.F.)
				
			//-Inclusao de linha
			Else
				RecLock("SP3",.T.)
				
			EndIf
			
			If lGestaoCorp
				SP3->P3_FILIAL	:= FwxFilial("SP3")
				SP3->P3_GCGRPE	:= aColsAll[n1Cont,nPosFil2]
				SP3->P3_GCUNEG	:= aColsAll[n1Cont,nPosFil3]
			Else
				SP3->P3_FILIAL	:= xFilial("SP3")
			EndIf
			SP3->P3_GCFIL	:= aColsAll[n1Cont,nPosFil]
			
			SP3->P3_DATA	:= aColsAll[n1Cont,nPosData]
			SP3->P3_DESC	:= aColsAll[n1Cont,nPosDesc]
			SP3->P3_TPEXT	:= aColsAll[n1Cont,nPosTPEx]
			SP3->P3_FIXO	:= aColsAll[n1Cont,nPosFixo]
			SP3->P3_TPEXTN	:= aColsAll[n1Cont,nPosTPEN]
			SP3->P3_MESDIA	:= aColsAll[n1Cont,nPosMDia]
			SP3->P3_TIPO	:= aColsAll[n1Cont,nPosTipo]
			SP3->P3_TIPCOD	:= aColsAll[n1Cont,nPosTCod]
			
			MsUnlock("SP3")
			
			aAdd(aMyGrv, {Recno()})
			aSort(aMyGrv,,, { |x,y| x[1] < y[1] })
			
		//-(*** Linha deletada ***)
		Else
			If aColsAll[n1Cont,nPosRcno] > 0
			
				dbGoTo(aColsAll[n1Cont,nPosRcno])
				
				RecLock("SP3",.F.)
				dbDelete()
				MsUnlock("SP3")
			EndIf
		EndIf
	Next n1Cont
	
	If lGestaoCorp
		dbSetOrder(1)	//-P3_FILIAL+DTOS(P3_DATA)+P3_TIPO+P3_TIPCOD
	EndIf
EndIf
Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ TudoOk			³Autor³Equipe Advanced RH ³ Data ³27/04/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Confere a linha digitada									³
³          ³Calendario de Obrigacoes									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³PONA440                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function GPEA440TudoOk( oDados )

Local lTudOk := .T.

Return lTudOk

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ LinOk			³Autor³Equipe Advanced RH ³ Data ³27/04/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Confere a linha digitada									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³PONA440                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function GPEA440LinOk( oDados )

Local lLinOk   := .T.
Local aCpos    := {}
Local aNoEmpty := {}
Local cMyChave := ""
Local nMyPos   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida principais campos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
//- Esta validacao ocorre no IF abaixo ...
//- ==================================

If	Empty( oGetDados:aCols[oGetDados:nAt,nPosData] ) .or.;
	Empty( oGetDados:aCols[oGetDados:nAt,nPosDesc] )
	
	lLinOk := .F.
	MsgAlert( OemToAnsi(STR0030), OemToAnsi(STR0029) )	//-"Deve ser informado no mínimo a Data e Descrição"###"Atenção !!!"
EndIf
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida Chave Unica do arquivo                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	lLinOk
	If lGestaoCorp
		aAdd(aCpos, aHeader[nPosFil2,02])
		aAdd(aCpos, aHeader[nPosFil3,02])
	EndIf
	aAdd(aCpos, aHeader[nPosFil,02])
	aAdd(aCpos, aHeader[nPosData,02])
	aAdd(aCpos, aHeader[nPosTipo,02])
	aAdd(aCpos, aHeader[nPosTCod,02])

	If !lGestaoCorp
		//aAdd(aNoEmpty, aHeader[nPosFil,02])
	EndIf
	aAdd(aNoEmpty, aHeader[nPosData,02])
	aAdd(aNoEmpty, aHeader[nPosDesc,02])

	//ÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³ ExpL1 := GDCheckKey( aCpo , nModelo , aNoEmpty , cMsgAviso , lShowAviso ) ³
	//ÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³ ExpA1 -> Vetor com campos para compor a chave de pesquisa                 ³
	//³ ExpN2 -> Indica o modelo de validacao:                                    ³
	//³   1 - Apenas valida                                                       ³
	//³   2 - Valida e exibe mensagem de erro                                     ³
	//³   3 - Valida e exibe mensagem de erro informando os campos                ³
	//³   4 - Valida e exibe mensagem de erro informando os campos e as linhas    ³
	//³       com duplicidade                                                     ³
	//³ ExpA3 -> Vetor com campos de preenchimento obrigatorio                    ³
	//ÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	If !GdCheckKey( aCpos, 4, aNoEmpty)
		lLinOk := .F.
	EndIf
EndIf			

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ja existe Feriado Generico cadastrado no dia     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	lLinOk
	If lGestaoCorp
		cMyChave := oGetDados:aCols[n,nPosFil2]+oGetDados:aCols[n,nPosFil3]+oGetDados:aCols[n,nPosFil]+DTOS(oGetDados:aCols[n,nPosData])
		
		If Empty( oGetDados:aCols[n,nPosTipo]+oGetDados:aCols[n,nPosTCod] )
			nMyPos := aScan(oGetDados:aCols, ;
							{ |x| x[nPosFil2]+x[nPosFil3]+x[nPosFil]+DTOS(x[nPosData]) == cMyChave })
		Else
			nMyPos := aScan(oGetDados:aCols, ;
							{ |x| x[nPosFil2]+x[nPosFil3]+x[nPosFil]+DTOS(x[nPosData])+x[nPosTipo]+x[nPosTCod] == ;
							cMyChave+SP3->( Space(Len(P3_TIPO))+Space(Len(P3_TIPCOD)) ) })
		EndIf
	Else
		cMyChave := SubStr(oGetDados:aCols[n,nPosFil],1,2)+DTOS(oGetDados:aCols[n,nPosData])
		
		If Empty( oGetDados:aCols[n,nPosTipo]+oGetDados:aCols[n,nPosTCod] )
			nMyPos := aScan(oGetDados:aCols, ;
							{ |x| SubStr(x[nPosFil],1,2)+DTOS(x[nPosData]) == cMyChave })
		Else
			nMyPos := aScan(oGetDados:aCols, ;
							{ |x| SubStr(x[nPosFil],1,2)+DTOS(x[nPosData])+x[nPosTipo]+x[nPosTCod] == ;
								cMyChave+SP3->( Space(Len(P3_TIPO))+Space(Len(P3_TIPCOD)) ) })
		EndIf
	EndIf
	
	If nMyPos > 0 .And. (nMyPos # oGetDados:nAT) .And. (oGetDados:aCols[nMyPos,Len(aHeader)+1] == .F.)	//??-P11
		
		lLinOk := .F.
		MsgAlert(OemToAnsi(STR0031)+CRLF+;	//-"Já existe Feriado para esse dia!"
				 OemToAnsi(STR0033),;		//-"Favor altera-lo antes de incluir um Feriado com Tipo+Código de Área !!!"
				 OemToAnsi(STR0029) )		//-"Atenção !!!"
	EndIf
EndIf

Return lLinOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pona440WhenºAutor ³Ademar Fernandes    º Data ³ 22/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o campo P3_TIPO para habilitar o P3_TIPCOD          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PONA440 -> X3_WHEN do campo P3_TIPO                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pona440When()

Local lRet    := .F.
Local nPosTip := GdFieldPos( "P3_TIPO", aHeader )

If !Empty(aCols[n,nPosTip])
	lRet := .T.

	If aCols[n,nPosTip] == "3"		//-Estabelecimento
		aTrocaF3 := {{"P3_TIPCOD","RCO"}}
		
	ElseIf aCols[n,nPosTip] == "2"	//-Departamento
		aTrocaF3 := {{"P3_TIPCOD","SQB"}}
		
	Else                            //-Centro de Custo (CTT)
		aTrocaF3 := {}
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pona440ValºAutor  ³Ademar Fernandes    º Data ³ 24/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o campo P3_TIPCOD de acordo com o F3 selecionado    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PONA440 -> X3_VALID do campo P3_TIPCOD                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pona440Val(nOpcao)

Local lRet		:= .F.
Local nPos		:= 0
Local nPosTip	:= GdFieldPos( "P3_TIPO"  ,aHeader )

Local aGrpEmp1	:= FWLoadSM0()
Local aGrpEmp2	:= {}
Local aGrpEmp3	:= {}

If lGestaoCorp
	nPosFil2	:= GdFieldPos( "P3_GCGRPE", aHeader )
	nPosFil3	:= GdFieldPos( "P3_GCUNEG", aHeader )
	nPosFil		:= GdFieldPos( "P3_GCFIL" , aHeader )
EndIf
//nPosFil		:= GdFieldPos( "P3_FILIAL", aHeader )
nPosFil		:= GdFieldPos( "P3_GCFIL" , aHeader )

DEFAULT nOpcao := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o campo P3_TIPCOD de acordo com o F3 selecionado      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcao = 1	//-Valida o campo P3_TIPCOD

	If aCols[n,nPosTip] == "3"		//-Estabelecimento
	
		If ExistCpo("RCO",M->P3_TIPCOD)
			lRet := .T.
		EndIf
		
	ElseIf aCols[n,nPosTip] == "2"	//-Departamento
	
		If ExistCpo("SQB",M->P3_TIPCOD)
			lRet := .T.
		EndIf
		
	Else                            //-Centro de Custo (CTT)
		If ExistCpo("CTT",M->P3_TIPCOD)
			lRet := .T.
		EndIf
	
	EndIf

Else	//-Valida os campos que compoe a Filial da G.Corporativa	//-FWFilExist(,M->P3_GCGRPE+M->P3_GCUNEG+M->P3_GCFIL)
	
	aGrpEmp2	:= aClone(aGrpEmp1)
	aGrpEmp3	:= aClone(aGrpEmp2)
	
	//aSort(aGrpEmp1,,, { |x,y| x[1]+x[3]+x[4]+x[5] < y[1]+y[3]+y[4]+y[5] })
	aSort(aGrpEmp2,,, { |x,y| x[1]+x[4]+x[5] < y[1]+y[4]+y[5] })
	aSort(aGrpEmp3,,, { |x,y| x[1]+x[5] < y[1]+y[5] })
	
	nPos := aScan(aGrpEmp1, {|x| x[1] == FwGrpCompany() })
	
	If nOpcao = 21
		If Empty(M->P3_GCGRPE)	//-Empty(aCols[n,nPosFil2])
			lRet := .T.
		Else
			If aScan(aGrpEmp1, {|x| x[1]+x[3] == FwGrpCompany()+Left(M->P3_GCGRPE,Len(aGrpEmp1[nPos,03])) }) > 0
				lRet := .T.
			EndIf
		EndIf
		
	ElseIf nOpcao = 22
		If Empty(M->P3_GCUNEG)	//-Empty(aCols[n,nPosFil3])
			lRet := .T.
		Else
			If aScan(aGrpEmp1, {|x| x[1]+x[3]+x[4] == FwGrpCompany()+aCols[n,nPosFil2]+Left(M->P3_GCUNEG,Len(aGrpEmp1[nPos,04])) }) > 0
				lRet := .T.
			Else
				If aScan(aGrpEmp2, {|x| x[1]+x[4] == FwGrpCompany()+Left(M->P3_GCUNEG,Len(aGrpEmp1[nPos,04])) }) > 0
					lRet := .T.
				EndIf
			EndIf
		EndIf
		
	ElseIf nOpcao = 23
		If Empty(M->P3_GCFIL)	//-Empty(aCols[n,nPosFil])
			lRet := .T.
		Else
			If aScan(aGrpEmp1, {|x| x[1]+x[3]+x[4]+x[5] == FwGrpCompany()+aCols[n,nPosFil2]+aCols[n,nPosFil3]+Left(M->P3_GCFIL,Len(aGrpEmp1[nPos,05])) }) > 0
				lRet := .T.
			Else
				If aScan(aGrpEmp3, {|x| x[1]+x[5] == FwGrpCompany()+Left(M->P3_GCFIL,Len(aGrpEmp1[nPos,05])) }) > 0
					lRet := .T.
				EndIf
			EndIf
		EndIf
		
	EndIf
	
EndIf

Return lRet


//******************************************\\
Static Function myRefresh(oDlg,nMyAT)
Default nMyAT := 1
oGetDados:ForceRefresh()
oGetDados:oBrowse:nAT := nMyAT
oGetDados:oBrowse:Refresh()
oGetDados:nAT := nMyAT
oGetDados:Refresh()
If oDlg <> NIL
	oDlg:Refresh()
EndIf
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F3GrpEmp  ºAutor  ³Ademar Fernandes    º Data ³ 04/02/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Utilizado pra atualizar campo P3_FILIAL existente no aCols º±±
±±º          ³ da GetDados.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Consulta Especifica SXB (SM0EMP)                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Descricao da Consulta:
=====================
XB_TIPO - 1 = SM0
XB_TIPO - 2 = F3GrpEmp()
XB_TIPO - 5 = VAR_IXB
*/
Function F3GrpEmp(nOpcao)

Local nPos     := 0
Local nTamFil2 := 0
Local nTamFil3 := 0
Local nTamFil  := 0
Local aGrpEmp  := FWLoadSM0()
Local cAux1    := ""
Local cAux2    := ""

DEFAULT nOpcao := 1

/*
@param cField        -01-(*)Indica o campo que devera ser retornado ou o retorno sera um array com todos os campos definidos no SXB
@param cGrpEmpr      -02-(*)Indica o grupo de empresas
@param cModeCompany  -03-Indica o tipo de compartilhamento da empresa utilizado pela tabela
@param cModeUnit     -04-Indica o tipo de compartilhamento da unidade de negocio utilizado pela tabela
@param cModeFilial   -05-Indica o tipo de compartilhamento da filial utilizado pela tabela
@param lAutoReturn   -06-Indica se retona o conteudo automaticamente se existir somente um item no array
@param cCompany      -07-Indica a empresa utilizada para retorno da consulta de unidade de negócios e filiais
@param cUnitBusiness -08-Indica a unidade de negócios utilizada para retorno da consulta de filiais

FWPesqSM0(cField,cGrpEmpr,cModeCompany,cModeUnit,cModeFilial,lAutoReturn,cCompany,cUnitBusiness)
*/
If nOpcao = 1 .Or. !lGestaoCorp
	VAR_IXB := FWPesqSM0("COMPANY", FwGrpCompany())	//"M0_CODFIL")

ElseIf nOpcao = 2
	cAux1   := Iif(!Empty(oGetDados:aCols[oGetDados:nAt,nPosFil2]), oGetDados:aCols[oGetDados:nAt,nPosFil2], Nil)	//-FwCompany())
	VAR_IXB := FWPesqSM0("UNITBUSINESS", FwGrpCompany(),,,,, cAux1 )

ElseIf nOpcao = 3
	cAux1   := Iif(!Empty(oGetDados:aCols[oGetDados:nAt,nPosFil2]), oGetDados:aCols[oGetDados:nAt,nPosFil2], FwCompany())
	cAux2   := Iif(!Empty(cAux1) .And. !Empty(oGetDados:aCols[oGetDados:nAt,nPosFil3]), oGetDados:aCols[oGetDados:nAt,nPosFil3], FwUnitBusiness())
	VAR_IXB := FWPesqSM0("FILIAL", FwGrpCompany(),,,,, cAux1, cAux2)
EndIf

If lGestaoCorp
	//??nPos := aScan(aGrpEmp, {|x| x[1]+x[2] == FwGrpCompany()+FwxFilial() })
	nPos := aScan(aGrpEmp, {|x| x[1] == FwGrpCompany() })
	
	nTamFil2 := Len(aGrpEmp[nPos,03])
	nTamFil3 := Len(aGrpEmp[nPos,04])
	nTamFil  := Len(aGrpEmp[nPos,05])
	
	If nOpcao = 1
		oGetDados:aCols[oGetDados:nAt,nPosFil2] := SubStr(VAR_IXB, 1, nTamFil2)
		oGetDados:aCols[oGetDados:nAt,nPosFil3] := Space(nTamFil3)
		oGetDados:aCols[oGetDados:nAt,nPosFil]  := Space(nTamFil)
	ElseIf nOpcao = 2
		oGetDados:aCols[oGetDados:nAt,nPosFil3] := SubStr(VAR_IXB, 1, nTamFil3)
		oGetDados:aCols[oGetDados:nAt,nPosFil]  := Space(nTamFil)
	ElseIf nOpcao = 3
		oGetDados:aCols[oGetDados:nAt,nPosFil]  := SubStr(VAR_IXB, (nTamFil2+nTamFil3+1), nTamFil)
	EndIf
	
Else
	oGetDados:aCols[oGetDados:nAtnPosFil] := VAR_IXB
EndIf

myRefresh(,n)
Return .T.
