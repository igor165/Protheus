#INCLUDE "PROTHEUS.CH"
#INCLUDE "CSAA160.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CSAA160     ³ Autor ³Emerson Grassi Rocha ³ Data ³ 29/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relacionamento Competencia x Habilidade                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Uso       ³Generico                                                    ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Programador ³Data      ³BOPS       ³Motivo da Alteracao                ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Cecilia Car.³07/07/2014³TPZVTW     ³Incluido o fonte da 11 para a 12 e ³±±
±±³            ³          ³           ³efetuada a limpeza.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function CSAA160()

Local aArea 	:= GetArea()
Local aAreaRd2	:= RD2->( GetArea() )
Local aAreaRdm	:= RDM->( GetArea() )
Local aAreaRBJ	:= RBJ->( GetArea() )

Private aRotina := MenuDef() 
Private cCadastro   := OemToAnsi( STR0006 ) //"Relacionamento Competencia x Habilidade"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Arquivo Esta Vazio                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ChkVazio("RDM")
	Return( NIL )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a Funcao de Montagem do Browse                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MBrowse( 6 , 1 , 22 , 75 , "RDM" )
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os Dados de Entrada 										   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( aAreaRd2 )
RestArea( aAreaRdm )
RestArea( aAreaRBJ )
RestArea( aArea	   )

Return( NIL )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CSAa160Mnt  ³ Autor ³Emerson Grassi Rocha ³ Data ³ 29/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina Principal                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CSAa160Mnt( cAlias , nReg , nOpc )						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias = Alias do arquivo                                   ³±±
±±³          ³nReg   = Numero do registro                                 ³±±
±±³          ³nOpc   = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Csaa160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAa160Mnt( cAlias , nReg , nOpc )
                    	
Local aArea				:= GetArea()
Local aSvKeys			:= GetKeys()

Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjSize			:= {}
Local aObjCoords		:= {}

Local aRD2Header		:= {}
Local aRBJGdAltera  	:= {}
Local aRBJGdNaoAlt		:= {}
Local aRBJRecnos		:= {}
Local aRBJNotFields		:= {}
Local aRBJVirtGd		:= {}
Local aRBJVisuGd		:= {}
Local aRBJHeader		:= {}
Local aRdmCols			:= {}
Local aRdmRecnos		:= {}
Local aSvCols			:= {}
Local bRBJGdDelOk		:= { || .T. }
Local bSet15			:= { || NIL }
Local bSet24			:= { || NIL }
Local bDialogIni		:= { || NIL }
Local bTreeBuild		:= { || NIL }
Local bRBJGDTudOk		:= { || .F. }
Local bGdGotFocus		:= { || NIL }
Local cFilRDM			:= ""
Local cCodRDM			:= ""
Local cRDMKeySeek		:= ""
Local cTreeLastKey		:= "cTreeLastKey"
Local nOpcAlt			:= 0
Local nRDMRecno			:= 0
Local nRD2Usado			:= 0
Local nRBJUsado			:= 0
Local nLoop				:= 0
Local nLoops			:= 0
Local nOpcNewGd			:= IF( ( ( nOpc == 2 ) .or. ( nOpc == 4 ) ) , 0 , GD_INSERT + GD_UPDATE + GD_DELETE	)
Local nIniColGd			:= 0
Local oDlg				:= NIL
Local oRBJGetDados		:= NIL
Local oTreeHab			:= NIL

Private aRBJCols		:= {}

Begin Sequence

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a chave para Pesquisa do Tree           			   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFilRDM		:= xFilial( "RDM", RDM->RDM_FILIAL )
		cCodRDM		:= RDM->RDM_CODIGO
		cRDMKeySeek := ( cFilRDM + cCodRDM )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seta a Ordem do Arquivo de Cabecalho de competencias		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RDM->( dbSetOrder( RetOrdem( "RDM" , "RDM_FILIAL+RDM_CODIGO" ) ) )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona na Chave Correspontente            				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RDM->( dbSeek( cRDMKeySeek , .F. ) )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega Informacoes do RDM    							   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRdmCols	:= RDM->( GdMontaCols(NIL,NIL,NIL,NIL,NIL,NIL,@aRdmRecnos,"RDM",cRDMKeySeek) )
		nRDMRecno	:= IF( Len( aRdmRecnos ) > 0 , aRdmRecnos[1] , nRDMRecno )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seta a Ordem do Arquivo de Detalhes de competencias		   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RD2->( dbSetOrder( RetOrdem( "RD2" , "RD2_FILIAL+RD2_CODIGO" ) ) )
		
		For nLoop := 1	To nRD2Usado

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define as Variaveis de Memoria							   	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Private &( "M->"+aRD2Header[ nLoop , 02 ] ) := GetValType( aRD2Header[ nLoop , 08 ] , aRD2Header[ nLoop , 04 ] )
		Next nLoop

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seta a Ordem do Arquivo de Valores das Competencias		   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RBJ->( dbSetOrder( RetOrdem( "RBJ" , "RBJ_FILIAL+RBJ_CODCOM" ) ) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta os Dados para a GetDados							   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aRBJNotFields , "RBJ_FILIAL"  )
		aAdd( aRBJNotFields , "RBJ_CODCOM"	)

		aRBJCols	:= RBJ->(GdMontaCols(	@aRBJHeader,;
											@nRBJUsado,;
											@aRBJVirtGd,;
											@aRBJVisuGd,;
											NIL,;
											aRBJNotFields,;
											@aRBJRecnos,;
											"RBJ",;
											cRDMKeySeek))
											
		aSvCols		:= Aclone( aRBJCols)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define os Campos nao Alteraveis							   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRBJGdNaoAlt := { "RBJ_ITECOM" }
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega os Campos Editaveis para a GetDados				   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nLoop := 1	To nRBJUsado

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define as Variaveis de Memoria							   	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Private &( "M->"+aRBJHeader[ nLoop , 02 ] ) := GetValType( aRBJHeader[ nLoop , 08 ] , aRBJHeader[ nLoop , 04 ] )
			IF (;
					( aScan( aRBJVirtGd		, aRBJHeader[ nLoop , 02 ] ) == 0 ) .and.	;
			   		( aScan( aRBJVisuGd		, aRBJHeader[ nLoop , 02 ] ) == 0 ) .and.	;
			   		( aScan( aRBJNotFields	, aRBJHeader[ nLoop , 02 ] ) == 0 ) .and.	;
			   		( aScan( aRBJGdNaoAlt	, aRBJHeader[ nLoop , 02 ] ) == 0 )			;
			  	)
				aAdd( aRBJGdAltera , aRBJHeader[ nLoop , 02 ] )
			EndIF
		Next nLoop
                                     

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define o Bloco para o TudoOk da GetDados do RBJ			   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bRBJGDTudOk		:= { || oRBJGetDados:TudoOk() }										//Valida as Informacoes da GetDados RBJ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define o Bloco para a Tecla <CTRL-O>						 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bSet15		:= { |cItemAnt|;
								IF(; 
									( nOpc == 3 );
									.and.;	//Relacionar
									( Eval( oTreeHab:bGotFocus, .T. ) , .T. );				//Verifica se Houve Alteracao na competencia
									.and.;
									Eval( bRBJGDTudOk ),;								 	//Valida as Informacoes da GetDados RBJ
									(;
										cItemAnt := SubStr(;
															oTreeHab:GetCargo(),;
															3,;
															GetSx3Cache( "RBJ_ITECOM" , "X3_TAMANHO" );
													   ),; 
										RBJTrfaCols( @aRBJCols , oRBJGetDados , NIL, cItemAnt ),;				//Transfere as Ultimas Informacoes da GetDados Atual para o Array Main do RBJ
										nOpcAlt := 1,;
										RestKeys( aSvKeys , .T. ),;
										oDlg:End();
									),;
								 	IF(;
								 		( nOpc == 3 ) ,;		//Relacionar
								 			( nOpcAlt := 0 ,.F.),;
										( nOpcAlt := IF( nOpc == 2 , 0 , 1 ) ,;
											RestKeys( aSvKeys , .T. ),;
											oDlg:End();
								 		);
								 	  );
							   	  );
						 }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define o Bloco para a Tecla <CTRL-X>     	   				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bSet24		:= { || ( nOpcAlt := 0 , RestKeys( aSvKeys , .T. ) , oDlg:End() ) }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define o Bloco para a Montagem do Tree                   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bTreeBuild := { || ; 
								CSAa160TreeBld(	oDlg					,;
												{aObjSize[1]} 			,;
												oTreeHab				,;
												@cTreeLastKey			,;
												nRDMRecno				,;
												cFilRDM					,;
												cCodRDM					,;
												oRBJGetDados			,;
												aRBJCols				,;
											  );
					 }								  

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define o Bloco para o Foco na GetDados                   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bGdGotFocus	:= { || Eval( oTreeHab:bGotFocus , ( nOpc == 3 ) ) }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define o Bloco para a Inicializacao do Dialog            	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bDialogIni		:= { ||;
									oRBJGetDados:Hide()								,;
									oTreeHab := Eval( bTreeBuild )					,;
									oRBJGetDados:oBrowse:bGotFocus := bGdGotFocus	,;
									EnchoiceBar( oDlg , bSet15 , bSet24 )			 ;
						   }



		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta as Dimensoes para o Dialogo Principal				   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdvSize		:= MsAdvSize()
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
		aAdd( aObjCoords , { 150 , 000 , .F. , .T. } )		//1-DbTree
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )		//2-MsGetDados
		aObjSize := MsObjSize( aInfoAdvSize , aObjCoords,,.T. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Dialogo Principal para Relacionamento.				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0006 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta o Objeto GetDados para o RBJ						   	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oRBJGetDados	:= MsNewGetDados():New(aObjSize[2,1]	,;
													aObjSize[2,2]	,;
													aObjSize[2,3]	,;
													aObjSize[2,4]	,;
													nOpcNewGd		,;
													"GdRBJLinOk"	,;
													"GdRBJTudOk"	,;
													"RBJ_ITECOM"	,;
													aRBJGdAltera	,;
													0				,;
													9999			,;
													NIL				,;
													NIL				,;
													bRBJGdDelOk		,;
													NIL				,;
													aRBJHeader		;
												 )
			oRBJGetDados:oBrowse:lVScroll	:= .T.
			oRBJGetDados:oBrowse:cToolTip	:= OemToAnsi( STR0007 )	//"Habilidades..."

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se o arquivo estiver Vazio, Inicializa a primeira linha  como³
			//³ deletada													 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF Empty( aRBJRecnos )
				nLoops := Len( oRBJGetDados:aCols )
				For nLoop := 1 To nLoops
					GdFieldPut( "GDDELETED" , .T. , nLoop , oRBJGetDados:aHeader , oRBJGetDados:aCols )
				Next nLoop
				nLoops := Len( aRBJCols  )
				For nLoop := 1 To nLoops
					GdFieldPut( "GDDELETED" , .T. , nLoop , oRBJGetDados:aHeader , aRBJCols )
				Next nLoop
			EndIF
            
			//Chama rotina na entrada para carregar acols da 1a pasta
			RBJTrfaCols( @aRBJCols , oRBJGetDados , NIL, NIL )

	ACTIVATE MSDIALOG oDlg ON INIT Eval( bDialogIni ) CENTERED

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura as Teclas de Atalho                				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestKeys( aSvKeys , .T. )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando Confirmada a Opcao e Nao for Visualizacao Grava ou   Ex³
	//³clui as Informacoes do RD3									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF( nOpcAlt == 1 )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apenas se nao For Visualizacao              				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		IF ( nOpc != 2 )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravando/Incluido ou Excluindo registros.					 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			CSA160Grava(aRBJCols, aRBJHeader, aRBJRecnos, cFilRDM, cCodRDM, nOpc, aSvCols)

		EndIF  
		
	EndIF

End Sequence

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura os Dados de Entrada								   	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( aArea )

Return( nOpcAlt )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GdRBJLinOk   ³ Autor ³Emerson Grassi Rocha³ Data ³ 29/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Linha Ok da GetDados.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GdRBJLinOk( oBrowse )										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³								                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Csaa160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GdRBJLinOk( oBrowse )

Local aCposKey	:= {}
Local lLinOk	:= .T.
Local nx		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Evitar que os Inicializadores padroes sejam carregados indevidamente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PutFileInEof( "RBJ" )

Begin Sequence

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a Linha da GetDados Nao Estiver Deletada				   	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !( GdDeleted() )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Itens Duplicados na GetDados						 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCposKey := { "RBJ_ITECOM", "RBJ_HABIL" }
		IF !( lLinOk := GdCheckKey( aCposKey , 4 ) )
			Break
		EndIF
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Se o Campos Estao Devidamente Preenchidos		   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !( lLinOk := GdNoEmpty( aCposKey ) )
	    	Break
		EndIF

	Else	// Se linha tiver deletada
		RBH->( dbSetOrder(3) )
		If RBH->( dbSeek(xFilial("RBH")+RDM->RDM_CODIGO+GdFieldGet("RBJ_ITECOM")+GdFieldGet("RBJ_HABIL") ) ) 
			lLinOk := .F.
			For nx := 1 To Len(aCols)
				If (n != nx) .And.;
					GdFieldGet("RBJ_ITECOM",n) == GdFieldGet("RBJ_ITECOM",nx) .And. ;
					GdFieldGet("RBJ_HABIL",n) == GdFieldGet("RBJ_HABIL",nx) .And. ;
					!( GdDeleted(nx) )

				    lLinOk := .T.
					Exit
				EndIf
			Next nx
            If !lLinOk
				Aviso(STR0008, STR0010, {"Ok"},,STR0009+RBH->RBH_CARGO)	//"Atencao"###"Competencia esta sendo utilizada por Este Cargo."###"Cargo: "
			EndIf
					
		EndIf
		RBH->( dbSetOrder(1) )
		Break
	EndIF
	
End Sequence

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se Houver Alguma Inconsistencia na GetDados, Seta-lhe o Foco  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !( lLinOk )
	oBrowse:SetFocus()
EndIF


Return( lLinOk )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GdRBJTudOk   ³ Autor ³Emerson Grassi Rocha³ Data ³ 29/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tudo Ok da GetDados.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GdRBJLinOk( oBrowse )										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³								                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Csaa160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GdRBJTudOk( oBrowse )

Local lTudoOk	:= .T.
Local nSvn		:= oBrowse:nAt
Local nx		:= 0                 

	Begin Sequence
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Percorre Todas as Linhas para verificar se Esta Tudo OK      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nx := 1 To Len( aCols )
			n := nx
			IF !( lTudoOk := GdRBJLinOk( oBrowse ) )
				oBrowse:Refresh()
				Break
			EndIF
		Next nx
	
		n := nSvn
	
	End Sequence

Return( lTudoOk  )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GdSuperDel   ³ Autor ³Emerson Grassi Rocha³ Data ³ 29/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Marcar e Desmarcar as Informacoes da GetDados como Deletadas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³								                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Csaa160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GdSuperDel( oObjGetDados , lStatusDel , aCols )

Local nDeleted := GdFieldPos( "GDDELETED" , oObjGetDados:aHeader )

DEFAULT lStatusDel := .T.

	aEval( oObjGetDados:aCols , { |x| x[nDeleted] := lStatusDel } )
	IF ( ValType( aCols ) == "A" )
		aEval( aCols , { |x| x[nDeleted] := lStatusDel } )
	EndIF
	oObjGetDados:oBrowse:Refresh()

Return( NIL )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Csa160Grava ³ Autor ³Emerson Grassi Rocha ³ Data ³ 29/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referente Competencia x Habilidade       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Csaa160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Csa160Grava(aAuxCols, aAuxHeader, aColsRec, cFil, cCod, nOpc, aSvCols)     

	Local cCampo    := ""
	Local xConteudo := ""
	Local ny		:= 0
	Local nz		:= 0
	Local nPos  	:= GdFieldPos("RBJ_ITECOM",aAuxHeader)
	Local nSize		:= 0

	dbSelectArea("RBJ")    
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclusao de Relacionamento Comp x Habil ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 4	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se Pode Efetuar a Delecao dos Registros			   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RBH->( dbSetOrder(3) )
		
		If RBH->( dbSeek(xFilial("RBH") + cCod ) )
			Aviso(STR0008, STR0010, {"Ok"},,STR0009+RBH->RBH_CARGO)	//"Atencao"###"Competencia esta sendo utilizada por Este Cargo."###"Cargo: "
		Else
			//Deleta relacionamentos da Competencia
			dbSelectArea("RBJ") 
			dbSetOrder(1)      
			dbSeek(XFilial("RBJ", RBJ->RBJ_FILIAL) + cCod)

			While !Eof() .And. (XFilial("RBJ", RBJ->RBJ_FILIAL) + cCod == RBJ->RBJ_FILIAL + RBJ->RBJ_CODCOM)
				RecLock("RBJ", .F.)
					dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		EndIf
		
		RBH->( dbSetOrder(1) )
		Return .T.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Relacionamento Competencia x Habilidade ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//Eliminar linhas em branco
	While ( ny := Ascan(aAuxCols,{|x| x <> NIL .and. Val( x[nPos] ) == 0 }) ) > 0
		Adel(aAuxCols,ny)
		nSize ++
	End

	Asize(aAuxCols,Len(aAuxCols)-nSize)

	//Ordena Arrays
	ASort(aAuxCols,,,{|x,y| x[1]+x[2] < y[1]+y[2]} )
	ASort(aSvCols ,,,{|x,y| x[1]+x[2] < y[1]+y[2]} )

	//Retorna se nao houve alteracao	
	If ( fCompArray( aAuxCols , aSvCols ) ) 
		Return .T.
	EndIf

	//Deleta relacionamentos da Competencia
	dbSelectArea("RBJ") 
	dbSetOrder(1)      
	dbSeek(XFilial("RBJ",cFil) + cCod)
	While !Eof() .And. (XFilial("RBJ",cFil) + cCod == RBJ->RBJ_FILIAL + RBJ->RBJ_CODCOM)
		RecLock("RBJ", .F.)
			dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	For ny := 1 To Len(aAuxCols)
		
		//--Verifica se Nao esta Deletado no aCols
		If !aAuxCols[ny][Len(aAuxCols[ny])]
			RecLock("RBJ", .T.)			
		Else
			Loop
		EndIf
				
		RBJ->RBJ_FILIAL	:= cFil
		RBJ->RBJ_CODCOM	:= cCod

		For nz := 1 To Len(aAuxHeader)
			If aAuxHeader[nz][10] # "V"
				cCampo    := Trim(aAuxHeader[nz][2])
				xConteudo := aAuxCols[ny][nz]
				&cCampo	:= xConteudo
			EndIf	
		Next nz

		MsUnlock()
	Next ny

	dbSelectArea("RBJ")

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RBJChgTree   ³ Autor ³Emerson Grassi Rocha³ Data ³ 29/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Change do Tree de Competencias.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³								                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Csaa160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RBJChgTree( oTreeHab , oRBJGetDados , aRBJCols )

Local cCargo		:= ""
Local cItemCom		:= ""
Local cItemAnt		:= ""
Local lChgTreeOk	:= .T.
Local nPosItemAnt	:= 0
Local nRBJIteCom	:= GdFieldPos( "RBJ_ITECOM" , oRBJGetDados:aHeader )
Local nRBJDelete	:= GdFieldPos( "GDDELETED" , oRBJGetDados:aHeader )
Local nTamIteCom	:= TamSx3( "RBJ_ITECOM" )[1]
Local nLenaCols		:= 0

cCargo 		:= oTreeHab:GetCargo()
IF !( Left( cCargo , 1 ) == "*" )
	cItemCom		:= SubStr( cCargo , 3 , nTamIteCom )
	M->RD2_ITEM		:= cItemCom
	nPosItemAnt		:= aScan( oRBJGetDados:aCols , { |x| Empty( x[nRBJIteCom] ) } )
	IF ( nPosItemAnt > 0 )
		cItemAnt	:= oRBJGetDados:aCols[ nPosItemAnt , nRBJIteCom ]
		aEval( oRBJGetDados:aCols , { |x|;
											IF(;
											 	Empty( x[ nRBJIteCom ] ) ,;
									 			x[ nRBJDelete ] := .T. ,;
												NIL ;
										 	);
							 		};
		  	)
		nPosItemAnt	:= aScan( oRBJGetDados:aCols , { |x| !Empty( x[nRBJIteCom] ) } )
		IF ( nPosItemAnt > 0 )
			cItemAnt	:= oRBJGetDados:aCols[ nPosItemAnt , nRBJIteCom ]
		EndIF
	Else
		cItemAnt	:= oRBJGetDados:aCols[ 01 , nRBJIteCom ]
	EndIF	
	nLenaCols := Len( oRBJGetDados:aCols )
	IF ( ( oRBJGetDados:nAt > nLenaCols ) .or. ( oRBJGetDados:oBrowse:nAt > nLenaCols ) )
		oRBJGetDados:nAt			:= 1
		oRBJGetDados:oBrowse:nAt	:= 1
	EndIF
	IF ( lChgTreeOk := oRBJGetDados:TudoOk() )
		oRBJGetDados:Show()
		RBJTrfaCols( @aRBJCols , oRBJGetDados , cItemCom , cItemAnt )
		aEval( oRBJGetDados:aCols , { |aColsElem| aColsElem[ nRBJIteCom ] := cItemCom } )
		oRBJGetDados:nAt			:= 1
		oRBJGetDados:oBrowse:nAt	:= 1
		oRBJGetDados:Refresh()
	Else
		oTreeHab:TreeSeek( "+-" + cItemAnt )
		oRBJGetDados:Show()
	EndIF
Else 
	RBJTrfaCols( @aRBJCols , oRBJGetDados , NIL )
	oRBJGetDados:nAt			:= 1
	oRBJGetDados:oBrowse:nAt	:= 1
	oRBJGetDados:Hide()
EndIF

Return( lChgTreeOk )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RBJTrfaCols  ³ Autor ³Emerson Grassi Rocha³ Data ³ 29/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Transfere Informacoes para aRBJCols						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³								                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Csaa160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RBJTrfaCols( aRBJCols , oRBJGetDados , cKeyAtu , cKeyAnt )

Local bColsToAll	:= { | aCols , aHeader , nItem |;
												!Empty( aCols[ nItem , nRbjIteCom ] );
												.and.;
												!Empty( aCols[ nItem , nRbjHabil ] );
					   }

Local bAllToCols	:= { | aColsAll , aHeaderAll , nFindKey |;
												!Empty( aColsAll[ nFindKey , nRbjIteCom ] );
												.and.;
												!Empty( aColsAll[ nFindKey , nRbjHabil ] );
					   }

Local lTransf2All   := !Empty( cKeyAnt )
Local lTransf2Cols  := !Empty( cKeyAtu )

Local nRbjIteCom	:= GdFieldPos( "RBJ_ITECOM" , oRBJGetDados:aHeader )
Local nRbjHabil		:= GdFieldPos( "RBJ_HABIL" , oRBJGetDados:aHeader )

Local aRbjCposSrt
Local aRbjCposPes

DEFAULT cKeyAtu		:= ""
DEFAULT cKeyAnt		:= ""

aRbjCposSrt			:= { nRbjIteCom , nRbjHabil }
aRbjCposPes			:= { { nRbjIteCom , cKeyAnt } }

GdColsExChange(	@aRbjCols,;				//01 -> Array com a Estrutura do aCols Contendo todos os Dados	
				oRBJGetDados:aCols,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
				oRBJGetDados:aHeader,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
				NIL,;					//04 -> Array com as Posicoes dos Campos para Pesquisa
				cKeyAtu,;				//05 -> Chave para Busca no aColsAll para Carga do aCols
				aRbjCposSrt,;			//06 -> Array com as Posicoes dos Campos para Ordenacao
				aRbjCposPes,;			//07 -> Array com as Posicoes dos Campos e Chaves para Pesquisa
				oRBJGetDados:aHeader,;	//08 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
				NIL,;					//09 -> Conteudo do Elemento "Deleted" a ser Carregado na Remontagem dos aCols
				lTransf2All,;			//10 -> Se deve Transferir do aCols para o aColsAll
				lTransf2Cols,;			//11 -> Se deve Transferir do aColsAll para o aCols
				.T.,;					//12 -> Se Existe o Elemento de Delecao no aCols
				.F.,;					//13 -> Se deve Carregar os Inicializadores padroes
				bColsToAll,;			//14 -> Condicao para a Transferencia do aCols para o aColsAll
				bAllToCols;				//15 -> Condicao para a Transferencia do aColsAll para o aCols
			  )

Return( NIL )


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CSAa160TreeBld³ Autor ³Emerson Grassi Rocha³ Data ³ 29/12/03³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o Tree de Competencias para Escolha das Habilidades	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³								                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Csaa160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CSAa160TreeBld(	oDlg			,;
	   							aTreeCoords 	,;
	   							oTreeHab		,;
	   							cTreeLastKey	,;
	   							nRDMRecno		,;
	   							cFilRDM			,;
	   							cCodRDM			,;
	   							oRBJGetDados	,;
	   							aRBJCols		;
							  )

Local aDbTreeInfo		:= {}
Local bTreeChage		:= { || NIL }
Local cKey				:= ( cEmpAnt + cFilAnt + xFilial("RDM")+ RDM->RDM_CODIGO )
Local lRebuildTree		:= .F.
Local lSuperDel			:= .F.

IF ( lRebuildTree := !( cTreeLastKey == cKey ) )
	lSuperDel		:= !( cTreeLastKey == "cTreeLastKey" )
	cTreeLastKey	:= cKey
	RDM->( dbSetOrder( RetOrdem( "RDM" , "RDM_FILIAL+RDM_CODIGO" ) ) ) 	
	IF RDM->( dbSeek( cFilRDM + cCodRDM , .F. ) )
 		nRDMRecno := RDM->( Recno() )
 	EndIF
 	IF ( ValType( oTreeHab ) == "O" )
 		oTreeHab:TreeSeek( "*-" )
 	EndIF	
EndIF

IF ( lRebuildTree )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define aDbTreeInfo                                      	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDbTreeInfo :=	{;
	 			    	{;
	 			    		"RDM"		,;
	 			    		nRDMRecno	,;
	 			    		cFilRDM		,;
	 			    		cCodRDM		,;
	 			    		"RDM_DESC"	 ;
	 			    	},;
	 			    	{;
	 			    		"RD2"		,;
	 			    		"RD2_ITEM"	,;
	 			    		1			,;
	 			    		"RD2_TREE"	,;
	 			    		2			,;
	 			    		"RD2_DESC"	,;
	 			    	};
	 			    }
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o Bloco para o Change do Tree                     	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bTreeChage := { ||RBJChgTree( oTreeHab , oRBJGetDados , aRBJCols )}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Tree de Competencias                             	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTreeHab := ApdBldTree(aDbTreeInfo,NIL,NIL,bTreeChage,NIL,.F.,aTreeCoords,NIL,oDlg,.T.,{3,4,5,6,7,8})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o Blogo do bGotFocus que ira Remontar o Tree caso haja³
	//³ alteracao na competencia									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTreeHab:bGotFocus := { || .T. }
		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta as Informacoes do RBJ se alterou a competencia    	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ( lSuperDel )
		GdSuperDel( oRBJGetDados , .T. , @aRBJCols )
	EndIF	

EndIF

Return( oTreeHab )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RBJHabilVld	³ Autor ³Emerson Grassi Rocha³ Data ³ 29/12/03³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valid do Campo RBJ_HABIL									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³								                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Valid do Campo RBJ_HABIL                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RBJHabilVld()
Local aSaveArea	:= GetArea()
Local cIteCom	:= GdFieldGet("RBJ_ITECOM")
Local cHabil	:= GdFieldGet("RBJ_HABIL")
Local lRet		:= .T. 
	
If !ExistCpo("RBG",M->RBJ_HABIL)
	lRet := .F.			

ElseIf !Empty(M->RBJ_HABIL) 

	dbSelectArea("RBJ")
	dbSetOrder(1)
	If dbSeek(xFilial("RBJ") + RDM->RDM_CODIGO + cIteCom + cHabil)
		Aviso(STR0008, STR0003, {"Ok"}) //"Atencao"###"Habilidade nao pode ser alterada."
		lRet := .F.
	EndIf
EndIf              

RestArea(aSaveArea)
Return( lRet )

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³28/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³CSAA160                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   

Static Function MenuDef()
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
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
 Local aRotina :=   {;
						{ STR0001 , "AxPesqui"	 , 0 , 1,,.F.} ,; //"Pesquisar"
						{ STR0002 , "CSAa160Mnt" , 0 , 2 } ,; //"Visualizar"
						{ STR0004 , "CSAa160Mnt" , 0 , 4 } ,; //"Relacionar"
						{ STR0005 , "CSAa160Mnt" , 0 , 5 }  ; //"Excluir"
					}
Return aRotina
