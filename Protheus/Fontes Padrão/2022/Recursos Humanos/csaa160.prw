#INCLUDE "PROTHEUS.CH"
#INCLUDE "CSAA160.CH"

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯SAA160     � Autor 矱merson Grassi Rocha � Data � 29/12/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 砇elacionamento Competencia x Habilidade                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢� 
北砋so       矴enerico                                                    潮� 
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢� 
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮� 
北媚哪哪哪哪哪穆哪哪哪哪哪履哪哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢� 
北砅rogramador 矰ata      矪OPS       矼otivo da Alteracao                潮� 
北媚哪哪哪哪哪呐哪哪哪哪哪拍哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢� 
北矯ecilia Car.�07/07/2014砊PZVTW     矷ncluido o fonte da 11 para a 12 e 潮�
北�            �          �           砮fetuada a limpeza.                潮�
北滥哪哪哪哪哪牧哪哪哪哪哪聊哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦� 
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�/*/
Function CSAA160()

Local aArea 	:= GetArea()
Local aAreaRd2	:= RD2->( GetArea() )
Local aAreaRdm	:= RDM->( GetArea() )
Local aAreaRBJ	:= RBJ->( GetArea() )

Private aRotina := MenuDef() 
Private cCadastro   := OemToAnsi( STR0006 ) //"Relacionamento Competencia x Habilidade"

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica se o Arquivo Esta Vazio                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If !ChkVazio("RDM")
	Return( NIL )
Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Chama a Funcao de Montagem do Browse                                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
MBrowse( 6 , 1 , 22 , 75 , "RDM" )
	
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Restaura os Dados de Entrada 										   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
RestArea( aAreaRd2 )
RestArea( aAreaRdm )
RestArea( aAreaRBJ )
RestArea( aArea	   )

Return( NIL )

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯SAa160Mnt  � Autor 矱merson Grassi Rocha � Data � 29/12/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 砇otina Principal                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯SAa160Mnt( cAlias , nReg , nOpc )						  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砪Alias = Alias do arquivo                                   潮�
北�          硁Reg   = Numero do registro                                 潮�
北�          硁Opc   = Numero da opcao selecionada                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯saa160                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
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

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Monta a chave para Pesquisa do Tree           			   	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		cFilRDM		:= xFilial( "RDM", RDM->RDM_FILIAL )
		cCodRDM		:= RDM->RDM_CODIGO
		cRDMKeySeek := ( cFilRDM + cCodRDM )
	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Seta a Ordem do Arquivo de Cabecalho de competencias		 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		RDM->( dbSetOrder( RetOrdem( "RDM" , "RDM_FILIAL+RDM_CODIGO" ) ) )
	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Posiciona na Chave Correspontente            				 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		RDM->( dbSeek( cRDMKeySeek , .F. ) )
	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Carrega Informacoes do RDM    							   	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aRdmCols	:= RDM->( GdMontaCols(NIL,NIL,NIL,NIL,NIL,NIL,@aRdmRecnos,"RDM",cRDMKeySeek) )
		nRDMRecno	:= IF( Len( aRdmRecnos ) > 0 , aRdmRecnos[1] , nRDMRecno )

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Seta a Ordem do Arquivo de Detalhes de competencias		   	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		RD2->( dbSetOrder( RetOrdem( "RD2" , "RD2_FILIAL+RD2_CODIGO" ) ) )
		
		For nLoop := 1	To nRD2Usado

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Define as Variaveis de Memoria							   	 �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			Private &( "M->"+aRD2Header[ nLoop , 02 ] ) := GetValType( aRD2Header[ nLoop , 08 ] , aRD2Header[ nLoop , 04 ] )
		Next nLoop

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Seta a Ordem do Arquivo de Valores das Competencias		   	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		RBJ->( dbSetOrder( RetOrdem( "RBJ" , "RBJ_FILIAL+RBJ_CODCOM" ) ) )

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Monta os Dados para a GetDados							   	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Define os Campos nao Alteraveis							   	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aRBJGdNaoAlt := { "RBJ_ITECOM" }
	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Carrega os Campos Editaveis para a GetDados				   	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		For nLoop := 1	To nRBJUsado

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Define as Variaveis de Memoria							   	 �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
                                     

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Define o Bloco para o TudoOk da GetDados do RBJ			   	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		bRBJGDTudOk		:= { || oRBJGetDados:TudoOk() }										//Valida as Informacoes da GetDados RBJ

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Define o Bloco para a Tecla <CTRL-O>						 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Define o Bloco para a Tecla <CTRL-X>     	   				 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		bSet24		:= { || ( nOpcAlt := 0 , RestKeys( aSvKeys , .T. ) , oDlg:End() ) }

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Define o Bloco para a Montagem do Tree                   	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Define o Bloco para o Foco na GetDados                   	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		bGdGotFocus	:= { || Eval( oTreeHab:bGotFocus , ( nOpc == 3 ) ) }

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Define o Bloco para a Inicializacao do Dialog            	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		bDialogIni		:= { ||;
									oRBJGetDados:Hide()								,;
									oTreeHab := Eval( bTreeBuild )					,;
									oRBJGetDados:oBrowse:bGotFocus := bGdGotFocus	,;
									EnchoiceBar( oDlg , bSet15 , bSet24 )			 ;
						   }



		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Monta as Dimensoes para o Dialogo Principal				   	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aAdvSize		:= MsAdvSize()
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
		aAdd( aObjCoords , { 150 , 000 , .F. , .T. } )		//1-DbTree
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )		//2-MsGetDados
		aObjSize := MsObjSize( aInfoAdvSize , aObjCoords,,.T. )

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Monta o Dialogo Principal para Relacionamento.				 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0006 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Monta o Objeto GetDados para o RBJ						   	 �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Se o arquivo estiver Vazio, Inicializa a primeira linha  como�
			//� deletada													 �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Restaura as Teclas de Atalho                				 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	RestKeys( aSvKeys , .T. )
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//砆uando Confirmada a Opcao e Nao for Visualizacao Grava ou   Ex�
	//砪lui as Informacoes do RD3									 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	IF( nOpcAlt == 1 )

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Apenas se nao For Visualizacao              				 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
 		IF ( nOpc != 2 )
		
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Gravando/Incluido ou Excluindo registros.					 �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁  
			CSA160Grava(aRBJCols, aRBJHeader, aRBJRecnos, cFilRDM, cCodRDM, nOpc, aSvCols)

		EndIF  
		
	EndIF

End Sequence

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//砇estaura os Dados de Entrada								   	 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
RestArea( aArea )

Return( nOpcAlt )

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矴dRBJLinOk   � Autor 矱merson Grassi Rocha� Data � 29/12/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矻inha Ok da GetDados.                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矴dRBJLinOk( oBrowse )										  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�								                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯saa160                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function GdRBJLinOk( oBrowse )

Local aCposKey	:= {}
Local lLinOk	:= .T.
Local nx		:= 0

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Evitar que os Inicializadores padroes sejam carregados indevidamente �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
PutFileInEof( "RBJ" )

Begin Sequence

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Se a Linha da GetDados Nao Estiver Deletada				   	 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	IF !( GdDeleted() )
	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Verifica Itens Duplicados na GetDados						 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aCposKey := { "RBJ_ITECOM", "RBJ_HABIL" }
		IF !( lLinOk := GdCheckKey( aCposKey , 4 ) )
			Break
		EndIF
	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Verifica Se o Campos Estao Devidamente Preenchidos		   	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//砈e Houver Alguma Inconsistencia na GetDados, Seta-lhe o Foco  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
IF !( lLinOk )
	oBrowse:SetFocus()
EndIF


Return( lLinOk )

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矴dRBJTudOk   � Autor 矱merson Grassi Rocha� Data � 29/12/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 砊udo Ok da GetDados.                                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矴dRBJLinOk( oBrowse )										  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�								                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯saa160                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function GdRBJTudOk( oBrowse )

Local lTudoOk	:= .T.
Local nSvn		:= oBrowse:nAt
Local nx		:= 0                 

	Begin Sequence
	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Percorre Todas as Linhas para verificar se Esta Tudo OK      �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矴dSuperDel   � Autor 矱merson Grassi Rocha� Data � 29/12/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矼arcar e Desmarcar as Informacoes da GetDados como Deletadas潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   �															  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�								                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯saa160                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矯sa160Grava � Autor 矱merson Grassi Rocha � Data � 29/12/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矴rava os registros referente Competencia x Habilidade       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� 					                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯saa160                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Static Function Csa160Grava(aAuxCols, aAuxHeader, aColsRec, cFil, cCod, nOpc, aSvCols)     

	Local cCampo    := ""
	Local xConteudo := ""
	Local ny		:= 0
	Local nz		:= 0
	Local nPos  	:= GdFieldPos("RBJ_ITECOM",aAuxHeader)
	Local nSize		:= 0

	dbSelectArea("RBJ")    
	dbSetOrder(1)

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Exclusao de Relacionamento Comp x Habil �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If nOpc == 4	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//砎erifica se Pode Efetuar a Delecao dos Registros			   	 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Relacionamento Competencia x Habilidade �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    砇BJChgTree   � Autor 矱merson Grassi Rocha� Data � 29/12/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矯hange do Tree de Competencias.							  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   �															  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�								                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯saa160                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    砇BJTrfaCols  � Autor 矱merson Grassi Rocha� Data � 29/12/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 砊ransfere Informacoes para aRBJCols						  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   �															  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�								                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯saa160                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un噮o    矯SAa160TreeBld� Autor 矱merson Grassi Rocha� Data � 29/12/03潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri噮o 矼onta o Tree de Competencias para Escolha das Habilidades	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   �															  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�								                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矯saa160                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
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

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Define aDbTreeInfo                                      	 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
	
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Define o Bloco para o Change do Tree                     	 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	bTreeChage := { ||RBJChgTree( oTreeHab , oRBJGetDados , aRBJCols )}

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Monta o Tree de Competencias                             	 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	oTreeHab := ApdBldTree(aDbTreeInfo,NIL,NIL,bTreeChage,NIL,.F.,aTreeCoords,NIL,oDlg,.T.,{3,4,5,6,7,8})

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Define o Blogo do bGotFocus que ira Remontar o Tree caso haja�
	//� alteracao na competencia									 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	oTreeHab:bGotFocus := { || .T. }
		
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Deleta as Informacoes do RBJ se alterou a competencia    	 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	IF ( lSuperDel )
		GdSuperDel( oRBJGetDados , .T. , @aRBJCols )
	EndIF	

EndIF

Return( oTreeHab )

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un噮o    砇BJHabilVld	� Autor 矱merson Grassi Rocha� Data � 29/12/03潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri噮o 砎alid do Campo RBJ_HABIL									  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   �															  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�								                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      砎alid do Campo RBJ_HABIL                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
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
谀哪哪哪哪穆哪哪哪哪哪哪哪哪履哪哪履哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪�
矲un噭o    � MenuDef		矨utor�  Luiz Gustavo     � Data �28/12/2006�
媚哪哪哪哪呐哪哪哪哪哪哪哪哪聊哪哪聊哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪�
矰escri噭o 矷sola opcoes de menu para que as opcoes da rotina possam    �
�          硈er lidas pelas bibliotecas Framework da Versao 9.12 .      �
媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
砈intaxe   �< Vide Parametros Formais >									�
媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
� Uso      矯SAA160                                                     �
媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
� Retorno  砤Rotina														�
媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
砅arametros�< Vide Parametros Formais >									�
滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�*/   

Static Function MenuDef()
	/*
	谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	� Define Array contendo as Rotinas a executar do programa      �
	� ----------- Elementos contidos por dimensao ------------     �
	� 1. Nome a aparecer no cabecalho                              �
	� 2. Nome da Rotina associada                                  �
	� 3. Usado pela rotina                                         �
	� 4. Tipo de Transa噭o a ser efetuada                          �
	�    1 - Pesquisa e Posiciona em um Banco de Dados             �
	�    2 - Simplesmente Mostra os Campos                         �
	�    3 - Inclui registros no Bancos de Dados                   �
	�    4 - Altera o registro corrente                            �
	�    5 - Remove o registro corrente do Banco de Dados          �
	�    6 - Copiar                                                �
	滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁*/
 Local aRotina :=   {;
						{ STR0001 , "AxPesqui"	 , 0 , 1,,.F.} ,; //"Pesquisar"
						{ STR0002 , "CSAa160Mnt" , 0 , 2 } ,; //"Visualizar"
						{ STR0004 , "CSAa160Mnt" , 0 , 4 } ,; //"Relacionar"
						{ STR0005 , "CSAa160Mnt" , 0 , 5 }  ; //"Excluir"
					}
Return aRotina
