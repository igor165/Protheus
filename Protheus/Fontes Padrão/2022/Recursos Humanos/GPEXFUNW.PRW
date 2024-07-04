#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEXFUNW.CH"
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPEXFUNW  ³ Autor ³ Equipe Advanced RH    ³ Data ³14/12/1994³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcoes Genericas para Selecao de Opcoes                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador³ Data   ³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marinaldo  ³11/09/03³Melhor³Revisao e otimizacao Todo o Codigo da   fun³±±
±±³           ³        ³      ³cao f_Opcoes() e suas correlatas           ³±±
±±³           ³        ³      ³Redefinicao da Funcao fBoxCombo() que passa³±±
±±³           ³        ³      ³ra a utilizar a Funcao f_Opcoes() para   re³±±
±±³           ³        ³      ³tornar opcoes baseadas no X3_CBOX do campo ³±±
±±³Marinaldo  ³12/09/03³Melhor³Altera da a fMontaCombo para Tratar  funcao³±±
±±³           ³        ³      ³X3_CBOX									  ³±±
±±³Marinaldo  ³16/09/03³Melhor³Armazenar a Descricao em Outro Elemento  pa³±±
±±³           ³        ³      ³ra a correta Ordenacao quando esta nao  con³±±
±±³           ³        ³      ³tiver a chave para selecao da opcao        ³±±
±±³           ³        ³Acerto³Retornar corretamente o conteudo quando ape³±±
±±³           ³        ³      ³nas uma opcao puder ser selecionada        ³±±
±±³Mauricio MR³16/01/06³Melhor³Criacao da funcao fCleanOpc para "Higieni- ³±±
±±³           ³        ³      ³zar" o conteudo de uma variavel antes de   ³±±
±±³           ³        ³      ³substituir o seu conteudo. Pode ser utiliza³±±
±±³           ³        ³      ³da em conjunto com a f_Opcoes, por exemplo.³±±
±±³Natie      ³19/04/07³123995³Retirada do CursorWait da f_opcoes pois    ³±±
±±³           ³        ³      ³ha conflitos com a versao 10               ³±±
±±³Allyson M. ³18/05/10³10775/³Ajuste em f_OpcPsq() p/ corrigir pesquisa  ³±±
±±³           ³        ³ 2010 ³por codigo.								  ³±±
±±³Alex Fag.  ³06/12/10³27931/³Atender a Nova Interface Totvs 11.5  utili-³±±
±±³           ³        ³ 2010 ³zando a funcao MsAdvSize( p/  flexibilidade³±±
±±³           ³        ³      ³da tela de acordo com a resolucao).        ³±±
±±³Tiago Malta³27/05/11³29463/³Criado a função retcoords.                 ³±±
±±³Luis Artuso³07/11/12³028490³Ajuste em f_opcoes para nao exibir opcao em³±±
±±³           ³        ³  2012³branco no listbox.                         ³±±
±±³Gustavo M. ³22/09/14³TQPFB5³Ajuste na dimensão da tela da f_Opcoes.	  ³±±
±±³Gustavo M. ³10/05/16³TVCEMH³Ajuste na dimensão da tela da Pesquisa.	  ³±±
±±³Jonathan G.³13/04/18³DMINA-³Ajuste na dimensão da tela da f_Opcoes,    ³±±
±±³           ³        ³   246³para mostrar pelo menos 10 registros.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³f_Opcoes  ³ Autor ³Marinaldo de Jesus     ³ Data ³11/09/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Selecao de Opcoes                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³<Vide Parametros Formais>								  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³<Vide Parametros Formais>								  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function f_Opcoes(	uVarRet			,;	//Variavel de Retorno
					cTitulo			,;	//Titulo da Coluna com as opcoes
					aOpcoes			,;	//Opcoes de Escolha (Array de Opcoes)
					cOpcoes			,;	//String de Opcoes para Retorno
					nLin1			,;	//Nao Utilizado
					nCol1			,;	//Nao Utilizado
					l1Elem			,;	//Se a Selecao sera de apenas 1 Elemento por vez
					nTam			,;	//Tamanho da Chave
					nElemRet		,;	//No maximo de elementos na variavel de retorno
					lMultSelect		,;	//Inclui Botoes para Selecao de Multiplos Itens
					lComboBox		,;	//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
					cCampo			,;	//Qual o Campo para a Montagem do aOpcoes
					lNotOrdena		,;	//Nao Permite a Ordenacao
					lNotPesq		,;	//Nao Permite a Pesquisa
					lForceRetArr    ,;	//Forca o Retorno Como Array
					cF3				 ;	//Consulta F3
				  )

Local aListBox			:= {}
Local aSvKeys			:= GetKeys()
Local aAdvSize			:= {}
Local aAdv2Size			:= {}
Local aAdv3Size			:= {}
Local aInfoAdvSize		:= {}
Local aInfo2AdvSize		:= {}
Local aInfo3AdvSize		:= {}
Local aObjCoords		:= {}
Local aObj2Coords		:= {}
Local aObj3Coords		:= {}
Local aObjSize			:= {}
Local aObj2Size			:= {}
Local aObj3Size			:= {}
Local aButtons			:= {}
Local aX3Box			:= {}

Local bSvF3				:= SetKey( VK_F3  , NIL )
Local bSetF3			:= { || NIL }
Local bSet15			:= { || NIL }
Local bSet24			:= { || NIL }
Local bSetF4			:= { || NIL }
Local bSetF5			:= { || NIL }
Local bSetF6			:= { || NIL }
Local bCapTrc			:= { || NIL }
Local bDlgInit			:= { || NIL }
Local bOrdena			:= { || NIL }
Local bPesquisa			:= { || NIL }

Local cCodOpc			:= ""
Local cDesOpc			:= ""
Local cCodDes			:= ""
Local cPict				:= "@E 999999"
Local cVarQ				:= ""
Local cReplicate		:= ""
Local cTypeRet			:= ""

Local lExistCod			:= .F.
Local lSepInCod			:= .F.

Local nOpcA				:= 0
Local nFor				:= 0
Local nAuxFor			:= 1
Local nOpcoes			:= 0
Local nListBox			:= 0
Local nElemSel			:= 0
Local nInitDesc			:= 1
Local nTamPlus1			:= 0

Local oDlg				:= NIL
Local oListbox			:= NIL
Local oElemSel      	:= NIL
Local oElemRet			:= NIL
Local oOpcoes			:= NIL
Local oFontNum			:= NIL
Local oFontTit			:= NIL
Local oBtnMarcTod		:= NIL
Local oBtnDesmTod		:= NIL
Local oBtnInverte		:= NIL
Local oGrpOpc			:= NIL
Local oGrpRet			:= NIL
Local oGrpSel			:= NIL
Local nXBox				:= 0

Local uRet				:= NIL
Local uRetF3			:= NIL

DEFAULT uVarRet			:= &( ReadVar() )
DEFAULT cTitulo			:= OemToAnsi( STR0001 )	//"Escolha Padr”es"
DEFAULT aOpcoes			:= {}
DEFAULT cOpcoes			:= ""
DEFAULT l1Elem			:= .F.
DEFAULT lMultSelect 	:= .T.
DEFAULT lComboBox		:= .F.
DEFAULT cCampo			:= ""
DEFAULT lNotOrdena		:= .F.
DEFAULT lNotPesq		:= .F.
DEFAULT lForceRetArr	:= .F.

Begin Sequence

	uRet				:= uVarRet
	cTypeVarRet			:= ValType( uVarRet )
	cTypeRet			:= IF( lForceRetArr , "A" , ValType( uRet ) )
	lMultSelect 		:= !( l1Elem )

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Coloca o Ponteiro do Cursor em Estado de Espera			   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	//CursorWait()
		IF !( lComboBox )
			DEFAULT nTam	:= 1
			nTamPlus1		:= ( nTam + 1 )
			IF ( ( nOpcoes := Len( aOpcoes ) ) > 0 )
				For nFor := 1 To nOpcoes
				    IF !Empty( cOpcoes )
					    cCodOpc		:= SubStr( cOpcoes , nAuxFor , nTam )
				    	lExistCod	:= .F.
				    	nInitDesc	:= 1
				    	IF !( " <-> "		== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 5 ) ) .and. ;
				    	   !( " <=> "		== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 5 ) ) .and. ;
	  	   			       !( " <-> "		== SubStr( aOpcoes[ nFor ] , nTam      , 5 ) ) .and. ;
				    	   !( " <=> "		== SubStr( aOpcoes[ nFor ] , nTam      , 5 ) )
				    		IF !( "<->"		== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 3 ) ) .and. ;
				    		   !( "<=>"		== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 3 ) ) .and. ;
				    		   !( " - "		== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 3 ) ) .and. ;
				    		   !( " = "		== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 3 ) ) .and. ;
				    		   !( "<->"		== SubStr( aOpcoes[ nFor ] , nTam      , 3 ) ) .and. ;
				    		   !( "<=>"		== SubStr( aOpcoes[ nFor ] , nTam	   , 3 ) ) .and. ;
				    		   !( " - "		== SubStr( aOpcoes[ nFor ] , nTam	   , 3 ) ) .and. ;
				    		   !( " = "		== SubStr( aOpcoes[ nFor ] , nTam	   , 3 ) )
				    			IF !( "-"	== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 1 ) ) .and. ;
				    			   !( "="	== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 1 ) ) .and. ;
				    			   !( "-"	== SubStr( aOpcoes[ nFor ] , nTam	   , 1 ) ) .and. ;
				    			   !( "="	== SubStr( aOpcoes[ nFor ] , nTam      , 1 ) )
				    				nInitDesc	:= 1
				    				lExistCod	:= .F.
				    			Else
			    					nInitDesc	:= nTamPlus1 /* 1 */
				    				lExistCod	:= .T.
				    			EndIF
				    		Else
				    			IF (;
				    					lSepInCod := (;
														( "<->" $ cCodOpc ) .or. ;
				    									( "<=>" $ cCodOpc ) .or. ;
				    									( " - " $ cCodOpc ) .or. ;
				    									( " = " $ cCodOpc )		 ;
				    							   	  );
									)
				    				nInitDesc	:= nTamPlus1
				    			Else
				    				nInitDesc	:= ( nTamPlus1 + 2 ) /* 123 */
				    			EndIF
				    			lExistCod	:= .T.
				    		EndIF
				    	Else
			    			IF (;
			    					lSepInCod := (;
			    									( " <-> " $ cCodOpc ) .or. ;
			    									( " <=> " $ cCodOpc )	   ;
			    							   );
								)
			    				nInitDesc	:= nTamPlus1
			    			Else
				    			nInitDesc	:= ( nTamPlus1 + 4 ) /* 12345 */
				    		EndIF
				    		lExistCod	:= .T.
				    	EndIF
					    cDesOpc		:= SubStr( aOpcoes[ nFor ] , nInitDesc )
					    cCodDes		:= IF( lExistCod , aOpcoes[ nFor ] , cCodOpc + " - " + cDesOpc )
					    aAdd( aListBox , { .F. , cCodDes , cCodOpc , cDesOpc } )
						nAuxFor := ( ( nFor * nTam ) + 1 )
					Else
						aAdd( aListBox , { .F. , aOpcoes[ nFor ] , aOpcoes[ nFor ] , aOpcoes[ nFor ] } )
					EndIF
					IF (;
					   		( cTypeVarRet == "C" );
					   		.and.;
					   		( aListBox[ nFor , 03 ] $ uVarRet );
					   	)
						aListBox[ nFor , 01 ] := .T.
					EndIF
				Next nFor
			Else
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Restaura o Ponteiro do Cursor                  			   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				//CursorArrow()
				//"N„o existem dados para consulta"###"Escolha Padr”es"
				MsgInfo( OemToAnsi( STR0029 ) , IF( Empty( cTitulo ) , OemToAnsi( STR0001 ) , cTitulo ) )
				Break
			EndIF
		Else
			DEFAULT nTam	:= ( TamSx3( cCampo )[1] )
			aListBox := MontaCombo( cCampo , @cTitulo )
			IF ( ( nOpcoes := Len( aListBox ) ) > 0 )
				For nFor := 1 To nOpcoes
			    	IF (;
			    			( cTypeVarRet == "C" );
			    			.and.;
			    			( aListBox[ nFor , 03 ] $ uVarRet );
			    		)
		    	    	aListBox[ nFor , 01 ] := .T.
		    		EndIF
				Next nFor
			Else
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Restaura o Ponteiro do Cursor                  			   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				//CursorArrow()
				//"N„o existem dados para consulta"
				MsgInfo( OemToAnsi( STR0029 ) , IF( Empty( cTitulo ) , OemToAnsi( STR0001 ) , cTitulo ) )
			EndIF
		EndIF

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Inibe exibicao de item vazio.³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		nXBox	:= Ascan( aListBox , {|x| Empty(x[2]) } )
		If ( nXBox	> 0 )

			Do While ( nXBox <= LEN(aListBox) )

				If ( Empty(aListBox[nXBox , 2]) )

					aDel(aListBox , nXBox )
					aSize(aListBox , LEN(aListBox)-1 )

				Else

					nXBox++

				EndIf

			EndDo

		EndIf

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define o DEFAULT do Maximo de Elementos que Podem ser Retorna³
		³ dos														   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		DEFAULT nElemRet := If ( ValType(&( ReadVar() )) <> 'U' , ( Len( &( ReadVar() ) ) / nTam ) , 1 )


		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define os numeros de Elementos que serao Mostrados		   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		nOpcoes		:= Len( aListbox )
		nElemRet    := Min( nElemRet , nOpcoes )
		nElemRet	:= IF( !( lMultSelect ) , 01 , nElemRet )
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Verifica os Elementos ja Selecionados          			   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		aEval( aListBox , { |x| IF( x[1] , ++nElemSel , NIL ) } )

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Restaura o Ponteiro do Cursor                  			   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	//CursorArrow()

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Bloco e Botao para a Ordenacao das Opcoes       	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF !( lNotOrdena )
		bOrdena := { || f_OpcOrd(;
									oListBox	,;
									STR0014		 ; //"Ordenar <F7>..."
								 ),;
					 	SetKey( VK_F7 , bOrdena );
					}
		aAdd(;
				aButtons	,;
								{;
									"SDUORDER"				,;
		   							bOrdena 				,;
		       	   					OemToAnsi( STR0014 )	,;	//"Ordenar <F7>..."
		       	   					OemtoAnsi( STR0030 )	 ;	//"Ordenar"
		           				};
		     )
	EndIF

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Bloco e  Botao para a Pesquisa                   	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF !( lNotPesq )
		bPesquisa := { || f_OpcPsq(;
									oListBox	,;
									STR0015		,; //STR0015 "Pesquisar <F8>..."
									lNotOrdena  ,;
									cF3			,;
									aX3Box		 ;
								 ),;
					 	SetKey( VK_F8 , bPesquisa );
					}
		aAdd(;
				aButtons	,;
								{;
									"PESQUISA"				,;
		   							bPesquisa				,;
		       	   					OemToAnsi( STR0015 )	,;	//"Pesquisar <F8>..."
		       	   					OemToAnsi( STR0031 )	 ;	//"Pesquisar"
		           				};
		     )
	EndIF

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define o Bloco para a CaPexTroca()						   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	bCapTrc := { |cTipo,lMultSelect| ;
										aListBox := CaPexTroca(;
																oListBox:nAt,;
																@aListBox,;
																l1Elem,;
																nOpcoes,;
																nElemRet,;
																@nElemSel,;
																lMultSelect,;
																cTipo;
															),;
										oListBox:nColPos := 1,;
										oListBox:Refresh(),;
										oElemSel:Refresh();
				}

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega as Dimensoes Disponiveis       					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize( .T. , .T. )
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Redimensiona                           					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize[3] := 295
	aAdvSize[5] := 583

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 3 , 3 }
	aAdd( aObjCoords , { 020 , 070 , .T. , .T. , .T.} )
	aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	aAdv2Size := aClone(aObjSize[3])
	aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 3 , 3  }
	aAdd( aObj2Coords , { 000 , 020 , .T. , .F. } )
	aAdd( aObj2Coords , { 000 , 020 , .T. , .F. } )
	aAdd( aObj2Coords , { 000 , 020 , .T. , .F. } )
	aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )

	aAdv3Size := aClone(aObjSize[2])
	aInfo3AdvSize	:= { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 3 , 3  }
	aAdd( aObj3Coords , { 000 , 020 , .T. , .F. } )
	aAdd( aObj3Coords , { 000 , 020 , .T. , .F. } )
	aAdd( aObj3Coords , { 000 , 020 , .T. , .F. } )
	aObj3Size		:= MsObjSize( aInfo3AdvSize , aObj3Coords,,.T. )
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Seta a consulta F3                						   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF !Empty( cCampo )
		IF !Empty( cF3 )
			bSetF3	:= { || fOpcPesqF3( cF3 , cCampo , oListBox ) , SetKey( VK_F3 , bSetF3 ) }
		Else
			aX3Box	:= Sx3Box2Arr( cCampo )
		EndIF
	EndIF

	// ::::: Se cambia tamaño de la pantalla :::::\\
	//tamaño de pantalla y grid
	aAdvSize[6]    := aAdvSize[6] + 140
	aObjSize[1][4] := aObjSize[1][4] + 65

	//Posicion de groupbox
	aObj2Size[1][1] := aObj2Size[1][1] + 40
	aObj2Size[1][3] := aObj2Size[1][3] + 40

	aObj2Size[2][1] := aObj2Size[2][1] + 40
	aObj2Size[2][3] := aObj2Size[2][3] + 40

	aObj2Size[3][1] := aObj2Size[3][1] + 40
	aObj2Size[3][3] := aObj2Size[3][3] + 40

	//posicion de botones
	aObj3Size[1][1] := aObj3Size[3][1] + 90
	aObj3Size[2][1] := aObj3Size[3][1] + 90
	aObj3Size[3][1] := aObj3Size[3][1] + 90
	// ::::: Se cambia tamaño de la pantalla :::::\\

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Disponibiliza Dialog para Selecao 						   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	DEFINE FONT oFontNum NAME "Arial" SIZE 000,-014 BOLD
	DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 BOLD
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0001 ) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL //"Escolha Padr”es"

		@ aObjSize[1][1],aObjSize[1][2] LISTBOX oListBox VAR cVarQ FIELDS HEADER "" , OemToAnsi(cTitulo)  SIZE aObjSize[1][3],aObjSize[1][4];
										ON	DBLCLICK Eval( bCapTrc ) NOSCROLL PIXEL
		oListBox:SetArray( aListBox )
		oListBox:bLine := { || LineLstBox( oListBox , .T. ) }

		IF ( lMultSelect )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define Bloco e o Botao para Marcar Todos    				   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			bSetF4		:= { || Eval( bCapTrc , "M" , lMultSelect ) , SetKey( VK_F4 , bSetF4 ) }
			@ aObj3Size[1][1],aObj3Size[1][2] BUTTON oBtnMarcTod	PROMPT OemToAnsi( STR0002 )		SIZE 75,13.50 OF oDlg	PIXEL ACTION Eval( bSetF4 ) //"Marca Todos - <F4>"

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define Bloco e o Botao para Desmarcar Todos    			   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			bSetF5		:= { || Eval( bCapTrc , "D" , lMultSelect ) , SetKey( VK_F5 , bSetF5 ) }
			@ aObj3Size[2][1],aObj3Size[2][2] BUTTON oBtnDesmTod	PROMPT OemToAnsi( STR0003 )		SIZE 75,13.50 OF oDlg	PIXEL ACTION Eval( bSetF5 ) //"Desmarca Todos - <F5>"

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define Bloco e o Botao para Inversao da Selecao			   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			bSetF6		:= { || Eval( bCapTrc , "I" , lMultSelect ) , SetKey( VK_F6 , bSetF6 ) }
			@ aObj3Size[3][1],aObj3Size[3][2] BUTTON oBtnInverte	PROMPT OemToAnsi( STR0004 ) 	SIZE 75,13.50 OF oDlg	PIXEL ACTION Eval( bSetF6 ) //"Inverte Sele‡„o - <F6>"
		EndIF

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Numero de Elementos para Selecao							   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		@ aObj2Size[1][1],aObj2Size[1][2] GROUP oGrpOpc TO aObj2Size[1][3],aObj2Size[1][4]	OF oDlg LABEL OemtoAnsi(STR0010)	PIXEL	//"Nro. Elementos"
		oGrpOpc:oFont := oFontTit
		@ aObj2Size[1][1]+10,aObj2Size[1][2]+20 SAY oOpcoes		VAR Transform( nOpcoes	, cPict )	OF oDlg		PIXEL	FONT oFontNum

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Maximo de Elementos que poderm Ser Selecionados			   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		@ aObj2Size[2][1],aObj2Size[2][2] GROUP oGrpRet	TO aObj2Size[2][3],aObj2Size[2][4]	OF oDlg LABEL OemtoAnsi(STR0011)   PIXEL	//"M x. Elem. p/ Sele‡„o"
		oGrpRet:oFont := oFontTit
		@ aObj2Size[2][1]+10,aObj2Size[2][2]+20 SAY oElemRet	VAR Transform( nElemRet	, cPict )	OF oDlg		PIXEL	FONT oFontNum

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Numero de Elementos Selecionados                		   	   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		@ aObj2Size[3][1],aObj2Size[3][2] GROUP oGrpSel	TO aObj2Size[3][3],aObj2Size[3][4]	OF oDlg LABEL OemtoAnsi(STR0012)	PIXEL	//"Elem. Selecionados"
		oGrpSel:oFont := oFontTit
		@ aObj2Size[3][1]+10,aObj2Size[3][2]+20	SAY oElemSel		VAR Transform( nElemSel	, cPict )	OF oDlg		PIXEL	FONT oFontNum

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define Bloco para a Tecla <CTRL-O>              		   	   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	  	bSet15 := { || nOpcA := 1 , GetKeys() , SetKey( VK_F3 , NIL ) , oDlg:End() }

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define Bloco para a Tecla <CTRL-X>              		   	   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		bSet24 := { || nOpcA := 0 , GetKeys() , SetKey( VK_F3 , NIL ) , oDlg:End() }

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define Bloco para o Init do Dialog              		   	   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		bDlgInit := { || EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons ),;
						 IF( lMultSelect ,;
						 		(;
						 		 	SetKey( VK_F3 , bSetF3 ),;
						 		 	SetKey( VK_F4 , bSetF4 ),;
						 		 	SetKey( VK_F5 , bSetF5 ),;
						 		 	SetKey( VK_F6 , bSetF6 );
						 		 ),;
						 		NIL;
						 	),;
						 SetKey( VK_F7 , bOrdena ),;
						 SetKey( VK_F8 , bPesquisa );
					}

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( bDlgInit )

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Retorna as Opcoes Selecionadas                  		   	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF ( nOpcA == 1 )
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Coloca o Ponteiro do Cursor em Estado de Espera			   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		//CursorWait()
		    IF ( cTypeRet == "C" )
			    uRet		:= ""
				cReplicate	:= Replicate( "*" , nTam )
			    nListBox := Len( aListBox )
			    For nFor := 1 To nListBox
					IF ( aListBox[ nFor , 01 ] )
						uRet += aListBox[ nFor , 03 ]
			    	ElseIF ( lMultSelect )
			    		uRet += cReplicate
			    	EndIF
			    Next nFor
			ElseIF ( cTypeRet == "A" )
			    uRet	 	:= {}
			    nListBox	:= 0
			    While ( ( nFor := aScan( aListBox , { |x| x[1] } , ++nListBox ) ) > 0 )
			    	nListBox := nFor
					aAdd( uRet , aListBox[ nFor , 03 ] )
			    End While
			EndIF
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Restaura o Ponteiro do Cursor                  			   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		//CursorArrow()
	EndIF

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega Variavel com retorno por Referencia     		   	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	uVarRet := uRet

End Sequence

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura o Estado das Teclas de Atalho          		   	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestKeys( aSvKeys , .T. )
SetKey( VK_F3 , bSvF3 )

Return( ( nOpca == 1 ) )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fOpcPesqF3		³Autor³Marinaldo de Jesus ³ Data ³11/11/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Efetua Pesquisa Via Tecla F3                         		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³f_Opcoes()                                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais 									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fOpcPesqF3( cF3 , cCampo , oListBox )

Local cAlias
Local lConpad1
Local nAt
Local uRetF3

IF FindFunction( "AliasCpo" )
	cAlias := AliasCpo( cCampo )
	IF (;
			!Empty( cAlias );
			.and.;
			( Select( cAlias ) > 0 );
		)
		lConpad1 := ConPad1( NIL , NIL , NIL , cF3 , NIL , NIL , .F. )
		IF( lConpad1 )
			uRetF3	:= ( cAlias )->( FieldGet( FieldPos( cCampo ) ) )
			nAt		:= aScan( oListBox:aArray , { |x| x[3] == uRetF3 } )
			IF ( nAt > 0 )
				oListBox:nAt := nAt
				oListBox:Refresh()
			Else
				MsgInfo( OemToAnsi( STR0026 ) ) //"c¢digo n„o encontrado"
			EndIF
		EndIF
	EndIF
EndIF

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³CaPexTroca	    ³Autor³Marinaldo de Jesus ³ Data ³11/09/2003³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Efetua a Troca da Selecao no ListBox da f_Opcoes()   		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³f_Opcoes()                                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Array (Listbox) Com a(s) opcao(oes) Selecionadas			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais 									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function CaPexTroca(	nAt			,;	//Indice do ListBox de f_Opcoes()
							aArray		,;	//Array do ListBox de f_Opcoes()
							l1Elem		,;	//Se Selecao apenas de 1 elemento
							nOpcoes		,;	//Numero de Elementos disponiveis para Selecao
							nElemRet	,;	//Numero de Elementos que podem ser Retornados
							nElemSel	,;	//Numero de Elementos Selecionados
							lMultSelect	,;	//Se Trata Multipla Selecao
							cTipo		 ;	//Tipo da Multipla Selecao "M"arca Todos; "D"esmarca Todos; "I"nverte Selecao
						   )

Local nOpcao		:= 0

DEFAULT nAt			:= 1
DEFAULT aArray		:= {}
DEFAULT l1Elem		:= .F.
DEFAULT nOpcoes		:= 0
DEFAULT nElemRet	:= 0
DEFAULT nElemSel	:= 0
DEFAULT lMultSelect := .F.
DEFAULT cTipo		:= "I"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Coloca o Ponteiro do Cursor em Estado de Espera			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
CursorWait()
	IF !Empty( aArray )
		IF !( l1Elem )
			IF !( lMultSelect )
				aArray[nAt,1] := !aArray[nAt,1]
				IF !( aArray[nAt,1] )
					--nElemSel
				Else
					++nElemSel
				EndIF
			ElseIF ( lMultSelect )
				IF ( cTipo == "M" )
					nElemSel := 0
					aEval( aArray , { |x,y| aArray[y,1] := IF( ( y <= nElemRet ) , ( ++nElemSel , .T. ) , .F. ) } )
				ElseIF ( cTipo == "D" )
					aEval( aArray , { |x,y| aArray[y,1] := .F. , --nElemSel } )
				ElseIF ( cTipo == "I" )
					nElemSel := 0
					aEval( aArray , { |x,y| IF( aArray[y,1] , aArray[y,1] := .F. , IF( ( ( ++nElemSel ) <= nElemRet ) , aArray[y,1] := .T. , NIL ) ) } )
					nElemSel := Min( nElemSel , nElemRet )
				EndIF
			EndIF
		Else
			For nOpcao := 1 To nOpcoes
				IF ( nOpcao == nAt )
					aArray[ nOpcao , 1 ]	:= .T.
				Else
					aArray[ nOpcao , 1 ]	:= .F.
				EndIF
			Next nOpcao
			nElemSel := 01
		EndIF
	EndIF
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura o Ponteiro do Cursor                  			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
CursorArrow()

IF ( nElemSel > nElemRet )
	aArray[nAt,1] := .F.
	nElemSel := nElemRet
	MsgInfo(;
				OemToAnsi( STR0013 ) ,;	//"Excedeu o n£mero de elementos permitidos para sele‡„o"
				OemToAnsi( STR0005 )  ;	//"Aten‡„o"
		    )
ElseIF ( nElemSel < 0 )
	nElemSel := 0
EndIF

Return( aArray )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³f_OpcOrd	    ³Autor³Marinaldo de Jesus ³ Data ³11/09/2003³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Ordenar as Opcoes em f_Opcoes                        		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³f_Opcoes()                                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais 									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function f_OpcOrd( oListBox , cTitulo )

Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}

Local bSort			:= { || NIL }

Local lbSet15		:= .F.

Local nOpcRad		:= 1

Local oFont			:= NIL
Local oDlg			:= NIL
Local oGroup		:= NIL
Local oRadio		:= NIL

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize( .T. , .T. )
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Redimensiona                           					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize[3] -= 25
aAdvSize[4] -= 45
aAdvSize[5] -= 50
aAdvSize[7] += 50
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define o Bloco para a Teclas <CTRL-O>   ( Button OK da Enchoi³
³ ceBar )													   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
bSet15 := { ||	(;
					lbSet15 := .T. ,;
					GetKeys(),;
					oDlg:End();
				  );
			}

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define o  Bloco  para a Teclas <CTRL-X> ( Button Cancel da En³
³ choiceBar )												   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
bSet24 := { || GetKeys() , oDlg:End() }

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Monta Dialogo para a selecao do Periodo 					  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL

	@ aObjSize[1,1] , aObjSize[1,2] GROUP oGroup TO aObjSize[1,3]+20,aObjSize[1,4] LABEL OemToAnsi(STR0016) OF oDlg PIXEL	//"Ordenacao"
	oGroup:oFont:= oFont

	@ ( aObjSize[1,1] + 010 ) , ( aObjSize[1,2]+005 )	SAY OemToAnsi(STR0017)	SIZE 300,10 OF oDlg PIXEL FONT oFont		//"Efetuar a Ordena‡„o por:"
	@ ( aObjSize[1,1] + 010 ) , ( aObjSize[1,2]+100 )	RADIO oRadio VAR nOpcRad	ITEMS 	OemToAnsi(STR0018),;			//"c¢digo"
																	 						OemToAnsi(STR0019),;			//"descri‡„o"
																	 						OemToAnsi(STR0020),;			//"¡tem selecionado e c¢digo"
																	 						OemToAnsi(STR0021),;			//"¡tem selecionado e descri‡„o"
																	 						OemToAnsi(STR0022),;			//"¡tem n„o selecionado e c¢digo"
																	 						OemToAnsi(STR0023);				//"¡tem n„o selecionado e descri‡„o"
																						SIZE 115,010 OF oDlg PIXEL
	oRadio:oFont := oFont

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

IF ( lbSet15 )
	Do Case
		Case ( nOpcRad == 1 )
			bSort := { |x,y| x[3] < y[3] }
		Case ( nOpcRad == 2 )
			bSort := { |x,y| x[4] < y[4] }
		Case ( nOpcRad == 3 )
			bSort := { |x,y| ( IF( x[1] , "A" , "Z" ) + x[3] ) < ( IF( y[1] , "A" , "Z" ) + y[3] ) }
		Case ( nOpcRad == 4 )
			bSort := { |x,y| ( IF( x[1] , "A" , "Z" ) + x[4] ) < ( IF( y[1] , "A" , "Z" ) + y[4] ) }
		Case ( nOpcRad == 5 )
			bSort := { |x,y| ( IF( !x[1] , "A" , "Z" ) + x[3] ) < ( IF( !y[1] , "A" , "Z" ) + y[3] ) }
		Case ( nOpcRad == 6 )
			bSort := { |x,y| ( IF( !x[1] , "A" , "Z" ) + x[4] ) < ( IF( !y[1] , "A" , "Z" ) + y[4] ) }
	End Case
	aSort( oListBox:aArray , NIL , NIL , bSort )
	oListBox:nAt := 1
	oListBox:Refresh()
EndIF

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura as Teclas de Atalho                     	  		  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestKeys( aSvKeys , .T. )

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³f_OpcPsq	    ³Autor³Marinaldo de Jesus ³ Data ³11/09/2003³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Pesquisar as Opcoes em f_Opcoes                      		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³f_Opcoes()                                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais 									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function f_OpcPsq( oListBox , cTitulo , lNotOrdena , cF3 , aX3Box )

Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}
Local aCloneArr		:= {}

Local bSort			:= { || NIL }
Local bAscan		:= { || NIL }
Local bSvF3			:= SetKey( VK_F3  , NIL )

Local cCodigo		:= Space( 20 )
Local cDescri		:= Space( 60 )
Local cMsg			:= ""

Local lbSet15		:= .F.

Local nOpcRad		:= 1
Local nAt			:= 0

Local oFont			:= NIL
Local oDlg			:= NIL
Local oGroup		:= NIL
Local oRadio		:= NIL
Local oCodigo		:= NIL

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize( .T. , .T. )
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Redimensiona                           					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize[3] -= 25
aAdvSize[4] -= 50
aAdvSize[5] -= 50
aAdvSize[6] -= 50
aAdvSize[7] += 50
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 030 , .T. , .f. } )
aAdd( aObjCoords , { 000 , 015 , .T. , .f. } )
aAdd( aObjCoords , { 000 , 015 , .T. , .f. } )
aAdd( aObjCoords , { 000 , 001 , .T. , .f. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define o Bloco para a Teclas <CTRL-O>   ( Button OK da Enchoi³
³ ceBar )													   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
bSet15 := { ||	(;
					lbSet15 := .T. ,;
					GetKeys(),;
					oDlg:End();
				  );
			}

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define o  Bloco  para a Teclas <CTRL-X> ( Button Cancel da En³
³ choiceBar )												   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
bSet24 := { || GetKeys() , oDlg:End() }

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Monta Dialogo para a selecao do Periodo 					  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) From aAdvSize[7],0 TO aAdvSize[6]+80,aAdvSize[5] OF GetWndDefault() PIXEL

	@ aObjSize[1,1],aObjSize[1,2] GROUP oGroup TO aObjSize[4,3],aObjSize[4,4] LABEL OemToAnsi(STR0024) OF oDlg PIXEL							//"Pesquisa"
	oGroup:oFont:= oFont

	@ ( aObjSize[1,1] + 010 ) , ( aObjSize[1,2]+005 )	SAY OemToAnsi(STR0025)	SIZE 300,10 OF oDlg PIXEL FONT oFont							//"Efetuar Pesquisa por:"
	@ ( aObjSize[1,1] + 010 ) , ( aObjSize[1,2]+100 )	RADIO oRadio VAR nOpcRad	ITEMS 	OemToAnsi(STR0018),;								//"c¢digo"
																	 						OemToAnsi(STR0019) ;								//"descri‡„o"
																						SIZE 115,010 OF oDlg PIXEL
	oRadio:cToolTip := OemToAnsi( STR0028 )	//"Ap¢s selecionar pressione a tecla <TAB> para habilitar a digita‡„o"
	oRadio:oFont	:= oFont

	@ aObjSize[2,1] , aObjSize[2,2]+005 SAY OemToAnsi(STR0018+":")					SIZE 100,10 OF oDlg PIXEL FONT oFont						//"c¢digo"
	IF Empty( aX3Box )
		@ aObjSize[2,1] , aObjSize[2,2]+70 MSGET oCodigo VAR cCodigo					SIZE 100,10 OF oDlg PIXEL FONT oFont WHEN ( nOpcRad == 1 )
		IF !Empty( cF3 )
			oCodigo:cF3 := cF3
		EndIF
	Else
		@ aObjSize[2,1] , aObjSize[2,2]+100 COMBOBOX oCodigo VAR cCodigo ITEMS aX3Box	SIZE 100,10 OF oDlg PIXEL FONT oFont WHEN ( nOpcRad == 1 )
	EndIF

	@ aObjSize[3,1] , aObjSize[3,2]+005	SAY OemToAnsi(STR0019+":")	SIZE 100,10 OF oDlg PIXEL FONT oFont						//"descri‡„o"
	@ aObjSize[3,1] , aObjSize[3,2]+70	MSGET oCodigo VAR cDescri	SIZE 190,10 OF oDlg PIXEL FONT oFont WHEN ( nOpcRad == 2 )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

IF ( lbSet15 )
	Do Case
		Case ( nOpcRad == 1 )
			bSort	:= { |x,y| x[3] < y[3] }
			bAscan	:= { |x,y| Upper( AllTrim( cCodigo ) ) $ SubStr( Upper( AllTrim( x[3] ) ) , 1 , Len( AllTrim( cCodigo ) ) ) }
			cMsg	:= STR0026	//"c¢digo n„o encontrado"
		Case ( nOpcRad == 2 )
			bSort := { |x,y| x[4] < y[4] }
			bAscan	:= { |x,y| Upper( AllTrim( cDescri ) ) $ SubStr( Upper( AllTrim( x[4] ) ) , 1 , Len( AllTrim( cDescri ) ) ) }
			cMsg	:= STR0027	//"descri‡„o n„o encontrada"
	End Case
	aCloneArr := aClone( oListBox:aArray )
	IF !( lNotOrdena )
		aSort( oListBox:aArray , NIL , NIL , bSort )
	EndIF
	IF ( ( ( nAt := aScan( oListBox:aArray , bAscan ) ) ) > 0 )
		oListBox:nAt := nAt
		oListBox:Refresh()
	Else
		MsgInfo( OemToAnsi( cMsg ) , cTitulo )
		oListBox:aArray := aClone( aCloneArr )
		oListBox:Refresh()
	EndIF
EndIF

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura as Teclas de Atalho                     	  		  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestKeys( aSvKeys , .T. )
SetKey( VK_F3 , bSvF3 )

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fBoxSX5	³ Autor ³ Emerson Grassi Rocha  ³ Data ³22/05/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Selecionar Tabela com Base no SX5							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fBoxSX5() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTab	: Tabela SX5.										  ³±±
±±³			 ³ nTam	: Numero de Caracteres da Opcao.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fBoxSX5(cTab,nTam)

Local aBox		:= {}

Local cTitulo	:= ""
Local cFilSX5	:= xFilial( "SX5" )

Local MvPar		:= &(Alltrim(ReadVar()))
Local MvParDef	:= ""
Local MvRet		:= Alltrim(ReadVar())

IF SX5->( dbSeek( cFilSX5 + Padl( cTab , 4 , "0" ) ) )
   cTitulo := SX5->( Alltrim( Left( X5Descri() , 20 ) ) )
EndIF

IF SX5->( dbSeek( cFilSX5 + cTab ) )
	While SX5->( !Eof() .and. X5_TABELA == cTab )
		aAdd( aBox , Left( SX5->X5_CHAVE , 1 ) + " - " + Alltrim( SX5->( X5Descri() ) ) )
		MvParDef += Left( SX5->X5_CHAVE , 1 )
		SX5->( dbSkip() )
	Enddo
Else
	Aviso(OemToAnsi(STR0005), STR0006+cTab+STR0007, {"OK"}) //"Atencao"#"Tabela "#" nao existe no SX5"
EndIF

IF f_Opcoes(@MvPar,cTitulo,@aBox,MvParDef,15,80,,nTam)
	&( MvRet ) := mvpar
EndIF

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fBoxCombo³Autor³Emerson Grassi Rocha Ver. I ³Data³22/05/2002³±±
±±³       	 ³         ³     ³Marinaldo de Jesu    Ver. II³Data³11/09/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Selecionar Tabela com Base no X3_COMBO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³<Vide Parametros Formais>									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³<Vide Parametros Formais>									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Generico 												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fBoxCombo( cCampo		,;	//Campo para retorno do X3_CBOX
					nTam		,;	//Tamanho das opcoes do X3_CBOX
					cTitulo		,;	//Titulo da Coluna com as opcoes
					l1Elem		,;	//No. elementos
					nElemRet	,;	//No maximo de elementos na variavel de retorno
					lMultSelect	,;	//Inclui Botoes para Selecao de Multiplos Itens
					lNotOrdena	,;	//Nao Permite a Ordenacao
					lNotPesq	 ;	//Nao Permite a Pesquisa
				  )

Local cReadVar		:= ReadVar()
Local cOpcRet		:= &( cReadVar )

DEFAULT nTam		:= ( TamSx3( cCampo )[1] )
DEFAULT l1Elem		:= .F.
DEFAULT nElemRet    := ( Len( cOpcRet ) / nTam )
DEFAULT lMultSelect	:= .T.
DEFAULT lNotOrdena	:= .F.
DEFAULT lNotPesq	:= .F.

IF f_Opcoes(	@cOpcRet	,;	//Variavel de Retorno
				cTitulo		,;	//Titulo da Coluna com as opcoes
				NIL			,;	//Opcoes de Escolha (Array de Opcoes)
				NIL			,;	//String de Opcoes para Retorno
				NIL			,;	//Linha - Superior Esquerdo  ( Parametro Reservado, sera redefinido na funcao )
				NIL			,;	//Coluna - Superior Esquerdo ( Parametro Reservado, sera redefinido na funcao )
				l1Elem		,;	//Se a Selecao sera de apenas 1 Elemento por vez
				nTam		,;	//Tamanho da Chave
				nElemRet	,;	//No maximo de elementos na variavel de retorno
				lMultSelect	,;	//Inclui Botoes para Selecao de Multiplos Itens
				.T.			,;	//Se aOpcoes Sera Montada a Partir de compo Box de Campo
				cCampo		,;	//Qual o Campo para a Montagem do aOpcoes
				lNotOrdena	,;	//Nao Permite a Ordenacao
				lNotPesq	 ;	//Nao Permite a Pesquisa
			  )
	&( cReadVar ) := cOpcRet
EndIF

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MontaCombo³Autor³Emerson Grassi Rocha 1a.Ver³Data³23/05/2002³±±
±±³          ³          ³Autor³Marinaldo de Jesus   2a.Ver³Data³01/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna array com ComboBox                   			  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Codigo + Descricao do Elemento do ComboBox           ³±±
±±³			 ³ExpA2: Codigo do Elemento do ComboBox                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Campo do SX3                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function MontaCombo( cCampo , cTitulo )

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->( GetArea() )
Local aListBox	:= {}
Local aSx3Info	:= PosAlias( "SX3" , cCampo , NIL , { "X3Titulo()" , "X3cBox()" , "X3_TAMANHO" } , 2 , .F. )

Local nLoop
Local nLoops

IF !Empty( aSx3Info )
	cTitulo := aSx3Info[1]
	aX3cBox	:= RetSx3Box( aSx3Info[2] , NIL , NIL , aSx3Info[3] )
	nLoops  := Len( aX3cBox )
	For nLoop := 1 To nLoops
		aAdd( aListBox , { .F. , aX3cBox[ nLoop , 1 ] , aX3cBox[ nLoop , 2 ] , aX3cBox[ nLoop , 3 ] } )
	Next nLoop
EndIF

RestArea( aAreaSX3 )
RestArea( aArea )

Return( aListBox )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³fCleanOpc	³ Autor ³ Mauricio MR           ³ Data ³16/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³"Higieniza" o conteudo de uma variavel do F_OPCOES.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fCleanOpc(nTamCpo, cConteudo, aOpcoes)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTamCpo	: Tamanho do campo das opcoes (via TamSX3)		  ³±±
±±³			 ³ cConteudo: Conteudo da Variavel do campo.				  ³±±
±±³			 ³ aOpcoes  : Opcoes de conteudo do campo.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Referencia³ GPEA040  												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fCleanOpc(nTamCpo, cConteudo, aOpcoes)
Local aConteudo	:= {}
Local nTamField
Local nX

Local nTamOpc	:= Len( aOpcoes[1] )

//-- Reve o tamanho da variavel do Campo
nTamField:=	Min(nTamCpo, Len(aOpcoes) * 2 )

//-- "Higieniza" o conteudo do campo
cConteudo:= StrTran(cConteudo,"-","")
cConteudo:= StrTran(cConteudo,"*","")

//-- Converte a variavel em Array
For nX:=1 To Len(cConteudo)
	AADD(aConteudo,Substr(cConteudo,nX,nTamOpc) )
Next nX

//-- Verifica as opcoes escolhidas e substitui as nao escolhidas por "*-"
cConteudo := ""
For nX:=1 To Len(aOpcoes)
	If !Empty(Ascan( aConteudo, {|x| aOpcoes[nX] == X } ) )
		cConteudo	+= aOpcoes[nX]+"-"
	Else
	    cConteudo	+= "**"
	Endif
Next nX

Return ( Nil )



/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³InGpexFunwExec³Autor ³Marinaldo de Jesus   ³ Data ³24/08/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Executar Funcoes Dentro de GPEXFUNW                          ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³InGpexFunwExec( cExecIn , aFormParam )						 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³uRet                                                 	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico 													 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function InGpexFunwExec( cExecIn , aFormParam )

Local uRet

DEFAULT cExecIn		:= ""
DEFAULT aFormParam	:= {}

IF !Empty( cExecIn )
	cExecIn	:= BldcExecInFun( cExecIn , aFormParam )
	uRet	:= &( cExecIn )
EndIF

Return( uRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETCOORDS ºAutor  ³Tiago Malta         º Data ³  19/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para gerar coordenadas de objetos virtuais.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nQtdObj   = Quantidade de Objetos por linha                 º±±
±±º          ³nQtdLin   = Quantidade de linhas                            º±±
±±º          ³nEspcoObj = Espaço entre os objetos                         º±±
±±º          ³uEspcoLin = Espaço entre os linhas                          º±±
±±º          ³nColunas  = Quantidade de Colunas na tela                   º±±
±±º          ³uEspcoCol = Espaço entre as Colunas                         º±±
±±º          ³lAlinHor  = Alinhamento Horizontal                          º±±
±±º          ³nLinha    = posição da linha inicial                        º±±
±±º          ³aAdvSize  = Array com as posições personalizadas            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function RetCoords(nQtdObj,nQtdLin,nEspcoObj,uEspcoLin,nColunas,uEspcoCol,lAlinHor,nLinha,aAdvSize)

Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aRet          := {}
Local i
Local ix
Local nSpace        := 0
Local nAuxCol       := 2
Local nCol          := 1

Default lAlinHor := .T.
Default nQtdObj  := 0
Default nQtdLin  := 0
Default nLinha   := 0
Default nColunas := 1
Default nEspcoObj:= 0
Default uEspcoLin:= 10
Default uEspcoCol:= 10
Default aAdvSize := MsAdvSize()

  	IF nLinha > 0
    	aInfoAdvSize	:= { aAdvSize[1] , nLinha , aAdvSize[3] , aAdvSize[4] ,nEspcoObj,0,10,0}
    ELSE
	    aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] ,nEspcoObj,0,10,10}
	ENDIF

   	For i:=1 To nQtdObj

    	IF nColunas > 1
			IF VALTYPE(uEspcoCol) == "N"
				IF uEspcoCol > 0
					IF i == nAuxCol
						aAdd( aObjCoords , {  uEspcoCol,100 , .F. , .T. } )
						nAuxCol += 2
					ELSE
						aAdd( aObjCoords , {  00,100 , .F. , .T. } )
					Endif
				ENDIF
			ELSEIF VALTYPE(uEspcoCol) == "A"
				IF Len(uEspcoCol) > 0 .and. nCol <= Len(uEspcoCol)
					IF i == nAuxCol
						aAdd( aObjCoords , {  uEspcoCol[nCol]   ,100 , .F. , .T. } )
						nAuxCol += 2
						nCol    += 1
					ELSE
						aAdd( aObjCoords , {  00,100 , .F. , .T. } )
					Endif
				ENDIF
			ENDIF
		ELSE
			aAdd( aObjCoords , {  00,100 , .F. , .T. } )
		ENDIF

	Next i

	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords , .T. , lAlinHor )

  	For i:=1 to nQtdLin
		For ix:=1 to nQtdObj
			aAdd( aRet, { aObjSize[ix][1] + nSpace , aObjSize[ix][2] , aObjSize[ix][3], aObjSize[ix][4] })
		Next ix
		IF VALTYPE(uEspcoLin) == "N"
			nSpace +=uEspcoLin
		ELSEIF VALTYPE(uEspcoLin) == "A"
			nSpace += iif( i > Len(uEspcoLin) , 0 , uEspcoLin[i] )
		ENDIF
	Next i

RETURN(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fTpContra ³ Autor ³ Equipe Maria		    ³ Data ³ 02/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Selecionar Tipo de Contrato 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fTpContra()											 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fTpContra1(l1Elem,lForca)
Local cTitulo:=""
Local MvPar
Local MvParDef:=""

Private aCat:={}
Default	lForca	:= .F.
l1Elem := If (l1Elem = Nil , .F. , .T.)

cAlias := Alias() 					 // Salva Alias Anterior
MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

If lForca // SE PERMITIR SELECIONAR MAIS DE UM ELEMENTO, NAO APRESENTAR A OPCAO DE "AMBOS"
	aCat:={"1 - "+STR0032,"2 - " +STR0033,"3 - " + STR0034}  //"Indeterminado"###"Determinado###"Intermitente"
	MvParDef:="123"
else
	aCat:={"1 - "+STR0032,"2 - " +STR0033,"3 - " +STR0035}  //"Indeterminado"###"Determinado"###"Ambos"
	MvParDef:="123"
EndIf

cTitulo :=STR0036  //"Prazo Tipo Contrato"

IF f_Opcoes(@MvPar,cTitulo,aCat      ,MvParDef,12,49,Iif(lForca,!lForca,l1Elem),Iif(lForca,1,nil),Iif(lForca,3,nil))  // Chama funcao f_Opcoes
	&MvRet := If(Empty(mvpar), "123", mvpar)              // Devolve Resultado
EndIF
dbSelectArea(cAlias) 								 // Retorna Alias
Return( .T. )

/*{Protheus.doc} fChkInterm
Checa se dicionario foi atualizado para o contrato intermitente
@author Flavio Correa
@since 10/10/2017
@version P11 R8
*/
Function fChkInterm()
Local lRet := .F.

If FindFunction("fTpContra1")
	DbSelectArea("SX1")
	DbSetOrder(1)
	DbSelectArea("SRC")
	If SX1->( DbSeek("GPR060    " + "07") ) .And. SRC->( ColumnPos("RC_CONVOC") ) > 0
		If "FTPCONTRA1" $ Alltrim(Upper(SX1->X1_VALID))
			lRet := .T.
		EndIf
	EndIf
EndIf

Return lRet
