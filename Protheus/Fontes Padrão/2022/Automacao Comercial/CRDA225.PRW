#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDA225.CH"
#DEFINE MAXGETDAD 	4096                  
Function CRDA225()
                                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o menu da gestao de acervos                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCols
Private aHeader
Private aRotina := MenuDef()
                                                                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabe‡alho da tela de atualiza‡oes                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro	:= STR0006 //"Regras de Pontuação"

mBrowse( 6, 1,22,75,"MA0" )

Return Nil 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MenuDef  ³ Autor ³ Vendas Clientes       ³ Data ³ 13.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CRDA225                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0001	,"AxPesqui"		,0	,1	,0	,.F.}	,;	//"Pesquisar"
						{STR0002	,"Crd225Man"	,0	,2	,0	,.T.}	,;	//"Visualizar"
						{STR0003	,"Crd225Man"	,0	,3	,0	,.T.}	,;	//"Incluir"
						{STR0004	,"Crd225Man"	,0	,4	,0	,.T.}	,;	//"Alterar"
						{STR0005	,"Crd225Man"	,0	,5	,0	,.T.}	}	//"Excluir"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDA225ManºAutor  ³Vendas Clientes     º Data ³  29/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para manutencao no cadastro de campanha              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGACRD                                                     º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data   	 ³Programador |BOPS    ³  Motivo da Alteracao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³05/02/09  ³Fernando    ³115958  ³ Alteração feita  para utilizar       ³±±
±±³          ³            ³        ³Walk Trhu                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd225Man( cAlias, nReg, nOpc )
Local aPosObj		:= {}            
Local aObjects		:= {}             
Local aSize			:= MsAdvSize()
Local aInfo1		:= {}						// Variavel para montagem da tela (Folders)
Local aHeader1		:= {}						// aHeader do folder do vale compras
Local aHeader2		:= {}						// aHeader do folder do Brinde
Local aHeader3		:= {}						// aHeader do folder do Self Liquidate
Local aAuxHeader1	:= {}						// Auxiliar do aHeader do folder do vale compras
Local aAuxHeader2	:= {}						// Auxiliar do aHeader do folder do Brinde
Local aAuxHeader3	:= {}						// Auxiliar do aHeader do folder do Self Liquidate
Local aCols1		:= {}						// aCols do folder do vale compras
Local aCols2		:= {}						// aCols do folder do brinde
Local aCols3		:= {}						// aCols do folder do Self Liquidate
Local aPosObj1		:= {}						// Variavel para montagem da tela (Folders)
Local oDlgCamp									// Objeto da janela de cadastro
Local oEnc										// Objeto da enchoice
Local lConfirma		:= .F.						// Variavel da escolha do usuario (confirma ou cancela) a manutencao
Local lProcessa		:= .T.						// Verifica se pode continuar o processamento
Local nSaveSx8		:= GetSx8Len()				// Controle de semaforo
Local nOpcX			:= 0						// Opcao escolhida
Local aCamposEnc	:= {}						// Relacao dos campos que estao na enchoice para gravacao do
Local aRecno1		:= {}						// Relacao dos campos que estao na enchoice para gravacao do
Local aRecno2		:= {}						// Relacao dos campos que estao na enchoice para gravacao do
Local aRecno3		:= {}						// Relacao dos campos que estao na enchoice para gravacao do
Local nX			:= 0 						// Variavel para utilizacao do FOR
Local nUsado1	 	:= 0						// Controle da qtde de colunas da aColsMAU
Local nUsado2 		:= 0						// Controle da qtde de colunas da aColsMAU
Local nUsado3 		:= 0						// Controle da qtde de colunas da aColsMAU
Local cRot			:= ""
                                          
Private aTELA[0][0]
Private aGETS[0]

Do Case
	Case nOpc == 1 
		cRot       := STR0001      //"Pesquisar"
	Case nOpc == 2
		cRot       := STR0002      // Visualizar
	Case nOpc == 3
		cRot       := STR0003      //"Incluir"
	Case nOpc == 4
		cRot       := STR0004      //"Alterar"
	Case nOpc == 5
		cRot       := STR0005      // Excluir				
EndCase

If nOpc == 5 //exclusao 

	lProcessa := Crd225CanDel()

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forca a abertura dos arquivos                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lProcessa
	dbSelectArea("MA0")   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializacao das variaveis da Enchoice                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory( "MA0", (nOpc==3), (nOpc==3) )
	
	dbSelectArea("SX3")
	dbSetOrder(1)	// X3_ARQUIVO+X3_ORDEM
	dbSeek( "MA0" )
	While !Eof() .AND. SX3->X3_ARQUIVO == "MA0"
		If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
			aAdd( aCamposEnc, SX3->X3_CAMPO )
		EndIf			
		dbSkip()
	End

	aAuxHeader1:= aClone( APBuildHeader( "MAU" ) )
	For nx := 1 to Len( aAuxHeader1 )
		If	Alltrim( aAuxHeader1[nx][2] ) == "MAU_ITEM"	.OR.;
			Alltrim( aAuxHeader1[nx][2] ) == "MAU_PONTOS"	.OR.;
			Alltrim( aAuxHeader1[nx][2] ) == "MAU_VALOR"
			aAdd( aHeader1, aAuxHeader1[nx] )
		EndIf
	Next
	ADHeadRec("MAU",aHeader1)
	nUsado1	:= Len( aHeader1 )
	
	aAuxHeader2:= aClone( APBuildHeader( "MAU" ) )
	For nx := 1 to Len( aAuxHeader2 )
		If	Alltrim( aAuxHeader2[nx][2] ) == "MAU_ITEM"	.OR.;
			Alltrim( aAuxHeader2[nx][2] ) == "MAU_PONTOS"	.OR.;
			Alltrim( aAuxHeader2[nx][2] ) == "MAU_PROD"
			aAdd( aHeader2, aAuxHeader2[nx] )
		EndIf
	Next
	ADHeadRec("MAU",aHeader2,)
	nUsado2	:= Len( aHeader2 )
	
	aAuxHeader3:= aClone( APBuildHeader( "MAU" ) )
	For nx := 1 to Len( aAuxHeader3 )
		If	Alltrim( aAuxHeader3[nx][2] ) == "MAU_ITEM"	.OR.;
			Alltrim( aAuxHeader3[nx][2] ) == "MAU_PONTOS"	.OR.;
			Alltrim( aAuxHeader3[nx][2] ) == "MAU_PROD"	.OR.;
			Alltrim( aAuxHeader3[nx][2] ) == "MAU_PERDES"	.OR.;
			Alltrim( aAuxHeader3[nx][2] ) == "MAU_SEQUEN"
			aAdd( aHeader3, aAuxHeader3[nx] )
		EndIf
	Next
	ADHeadRec("MAU",aHeader3,)
	nUsado3	:= Len( aHeader3 )
	
	dbSelectArea( "MAU" )
	dbSetOrder( 1 )
	
	If !INCLUI
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta aHeader e aCols de alteracao dos Pontos da Campanha³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( "MAU" )
		dbSetOrder( 1 )
	
		dbSeek( xFilial( "MAU" ) + MA0->MA0_CODCAM )
		
			While MAU->MAU_FILIAL == xFilial( "MAU" ) .AND.;
				MAU->MAU_CODCAM == MA0->MA0_CODCAM 

			If MAU->MAU_TIPO == "1"
				AAdd( aCols1, Array( nUsado1 + 1 ) )
				AAdd( aRecno1, MAU->( Recno() ) )
			ElseIf MAU->MAU_TIPO == "2"
				AAdd( aCols2, Array( nUsado2 + 1 ) )
				AAdd( aRecno2, MAU->( Recno() ) )
			Else
				AAdd( aCols3, Array( nUsado3 + 1 ) )
				AAdd( aRecno3, MAU->( Recno() ) )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acrescenta acols de regras³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 To nUsado1
				If MAU->MAU_TIPO == "1"
					If IsHeadRec(aHeader1[nX][2])
						aCols1[Len( aCols1 )][nX]:= MAU->(Recno()) 
		   			Elseif IsHeadAlias(aHeader1[nX][2])
			   			aCols1[Len( aCols1 )][nX]:= "MAU"
					ElseIf ( aHeader1[nX][10] <>  "V" ) .OR. Alltrim( aHeader1[nX][2] ) == "MAU_ITEM"
						aCols1[Len( aCols1 )][nX] := MAU->( FieldGet( FieldPos( aHeader1[nX][2] ) ) )
					Else
						aCols1[Len( aCols1 )][nX] := CriaVar( aHeader1[nX][2], .T. )
					EndIf
					aCols1[Len( aCols1 )][ nUsado1 + 1 ] := .F.
				EndIf
			Next nX

			For nX := 1 To nUsado2
				If MAU->MAU_TIPO == "2"
					If IsHeadRec(aHeader2[nX][2])
						aCols2[Len( aCols2 )][nX]:= MAU->(Recno()) 
		   			Elseif IsHeadAlias(aHeader2[nX][2])
			   			aCols2[Len( aCols2 )][nX]:= "MAU"
					ElseIf ( aHeader2[nX][10] <>  "V" ) .OR. Alltrim( aHeader1[nX][2] ) == "MAU_ITEM"
						aCols2[Len( aCols2 )][nX] := MAU->( FieldGet( FieldPos( aHeader2[nX][2] ) ) )
					Else
						aCols2[Len( aCols2 )][nX] := CriaVar( aHeader2[nX][2], .T. )
					EndIf
					aCols2[Len( aCols2 )][ nUsado2 + 1 ] := .F.
				EndIf
			Next nX

			For nX := 1 To nUsado3
				If MAU->MAU_TIPO == "3"
					If IsHeadRec(aHeader3[nX][2])
						aCols3[Len( aCols3 )][nX]:= MAU->(Recno()) 
		   			Elseif IsHeadAlias(aHeader3[nX][2])
			   			aCols3[Len( aCols3 )][nX]:= "MAU"
					ElseIf ( aHeader3[nX][10] <>  "V" ) .OR. Alltrim( aHeader1[nX][2] ) == "MAU_ITEM"
						aCols3[Len( aCols3 )][nX] := MAU->( FieldGet( FieldPos( aHeader3[nX][2] ) ) )
					Else
						aCols3[Len( aCols3 )][nX] := CriaVar( aHeader3[nX][2], .T. )
					EndIf
					aCols3[Len( aCols3 )][ nUsado3 + 1 ] := .F.
				EndIf
			Next nX

			DbSelectArea( "MAU" )
			DbSkip()
		End
	EndIf		
		
	If Empty( aCols1 )
		AAdd( aCols1, Array( nUsado1 + 1 ) )
	
		For nX := 1 To nUsado1
			If IsHeadRec(aHeader1[nX][2])
				aCols1[Len( aCols1 )][nX]:= 0 
			Elseif IsHeadAlias(aHeader1[nX][2])
				aCols1[Len( aCols1 )][nX]:= "MAU"
			ElseIf AllTrim( aHeader1[nX][2] ) == "MAU_ITEM"
				aCols1[Len( aCols1 )][nX] := StrZero( 1, Len( MAU->MAU_ITEM ) )
			Else
				aCols1[Len( aCols1 )][nX] := CriaVar( aHeader1[nX][2], .T. )
			EndIf
		Next nX
		aCols1[Len( aCols1 )][ nUsado1 + 1 ] := .F.
	EndIf

	If Empty( aCols2 )
		AAdd( aCols2, Array( nUsado2 + 1 ) )
	
		For nX := 1 To nUsado2
			If IsHeadRec(aHeader2[nX][2])
				aCols2[Len( aCols2 )][nX]:= 0  
			Elseif IsHeadAlias(aHeader2[nX][2])
				aCols2[Len( aCols2 )][nX]:= "MAU"

			ElseIf AllTrim( aHeader2[ nX][2] ) == "MAU_ITEM"
				aCols2[Len( aCols2 )][nX] := StrZero( 1, Len( MAU->MAU_ITEM ) )
			Else
				aCols2[Len( aCols2 )][nX] := CriaVar( aHeader2[nX][2], .T. )
			EndIf
		Next nX
		aCols2[Len( aCols2 )][ nUsado2 + 1 ] := .F.
	EndIf

	If Empty( aCols3 )
		AAdd( aCols3, Array( nUsado3 + 1 ) )
	
		For nX := 1 To nUsado3
			If IsHeadRec(aHeader3[nX][2])
				aCols3[Len( aCols3 )][nX]:= 0  
			Elseif IsHeadAlias(aHeader3[nX][2])
				aCols3[Len( aCols3 )][nX]:= "MAU"
			ElseIf AllTrim( aHeader3[ nX][2] ) == "MAU_ITEM"
				aCols3[Len( aCols3 )][nX] := StrZero( 1, Len( MAU->MAU_ITEM ) )
			Else
				aCols3[Len( aCols3 )][nX] := CriaVar( aHeader3[nX][2], .T. )
			EndIf
		Next nX
	
		aCols3[Len( aCols3 )][ nUsado3 + 1 ] := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aHeader e aCols das Regras da Pesquisa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "MAU" )
	DbSetOrder( 1 )
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula as posicoes dos objetos na tela                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize()
	
	AAdd( aObjects, { 100,065,.T.,.T. } )
	AAdd( aObjects, { 100,100,.T.,.T. } )
	
	aInfo 	:= { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a interface com o usuario                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgCamp TITLE STR0006 + " - " + cRot FROM aSize[7],0 TO aSize[6],aSize[5] of oMainWnd PIXEL //"Cadastro de assuntos"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Definindo Enchoice³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			EnChoice( 	cAlias	, nReg	, nOpc	, NIL			,;
						NIL		, NIL	, NIL	, aPosObj[1]	,;
						NIL		, NIL	, NIL	, NIL			,;
						NIL		, NIL	, NIL	, .T. )
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Getdados - Alternativas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			aTitles := {STR0008,STR0009,STR0010}  //"Vale Compras","Brinde","Self Liquidate"
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Definindo as Folders                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{"","",""},oDlgCamp,,,,.T.,.F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
			oFolder:bSetOption:={|nAtu| .T.}

			oGetd1 := MsNewGetDados():New( 	2,;
											2,;
											aPosObj[2,3]-aPosObj[2,1]-15,;
											aPosObj[2,4]-aPosObj[2,2]-5,;
											IF( Altera .OR. Inclui, GD_INSERT + GD_DELETE + GD_UPDATE, 0 ),;
											"AllwaysTrue()"	,;
											"AllwaysTrue()"	,;
											"+MAU_ITEM"		,;
											NIL				,;
											NIL				,;
											MAXGETDAD		,;
											NIL				,;
											NIL				,;
											NIL				,;
											oFolder:aDialogs[1],;
											aHeader1		,;
											aCols1 )
	
			oGetd2 := MsNewGetDados():New( 	2,;
											2,;
											aPosObj[2,3]-aPosObj[2,1]-15,;
											aPosObj[2,4]-aPosObj[2,2]-5,;
											IF( Altera .OR. Inclui, GD_INSERT + GD_DELETE + GD_UPDATE, 0 ),;
											"AllwaysTrue()"	,;
											"AllwaysTrue()"	,;
											"+MAU_ITEM"		,;
											NIL				,;
											NIL				,;
											MAXGETDAD		,;
											NIL				,;
											NIL				,;
											NIL				,;
											oFolder:aDialogs[2],;
											aHeader2		,;
											aCols2 )	

			oGetd3 := MsNewGetDados():New( 	2,;
											2,;
											aPosObj[2,3]-aPosObj[2,1]-15,;
											aPosObj[2,4]-aPosObj[2,2]-5,;
											IF( Altera .OR. Inclui, GD_INSERT + GD_DELETE + GD_UPDATE, 0 ),;
											"AllwaysTrue()"	,;
											"AllwaysTrue()"	,;
											"+MAU_ITEM"		,;
											NIL				,;
											NIL				,;
											MAXGETDAD		,;
											NIL				,;
											NIL				,;
											NIL				,;
											oFolder:aDialogs[3],;
											aHeader3		,;
											aCols3 )	
	
	
	ACTIVATE MSDIALOG oDlgCamp ON INIT (EnchoiceBar(oDlgCamp,{ ||nOpcX := 1, aCols1 := oGetd1:aCols,aCols2 := oGetd2:aCols, aCols3 := oGetd3:aCols,IF( oGetd1:TudoOk() .AND. oGetd2:TudoOk().AND. oGetd3:TudoOk(), IF( !Obrigatorio( aGets, aTela ), nOpcX := 0, oDlgCamp:End() ), nOpcX := 0 ) }, { ||oDlgCamp:End() }  ) )
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se confirmou, faz a gravacao na base de dados                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( nOpcX == 1 )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a funcao de gravacao - PONTOS DA CAMPANHA                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lGravou := Crd225Grv(	nOpc - 2,	aCamposEnc,	aRecno1, aHeader1, aCols1,;
														aRecno2, aHeader2, aCols2,;
														aRecno3, aHeader3, aCols3 )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle do semaforo                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGravou 
			If nOpc == 3
				While (GetSx8Len() > nSaveSx8)
					ConfirmSx8()
				End
			EndIf
		Else
			While (GetSx8Len() > nSaveSx8)
				RollBackSx8()
			End
		EndIf
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle do semaforo                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (GetSx8Len() > nSaveSx8)
			RollBackSx8()
		End
	EndIf
Else
	Help(" ",1,"NODELETA")
EndIf

Return Nil
          
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Crd225Grv ³ Autor ³ Vendas Clientes       ³ Data ³ 17/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Gravacao da campanha                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Crd225Grv                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Opcao da Gravacao sendo:                               ³±±
±±³          ³       [1] Inclusao                                           ³±±
±±³          ³       [2] Alteracao                                          ³±±
±±³          ³       [3] Exclusao                                           ³±±
±±³          ³ExpA2: Array de registros                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Pesquisa e Resultado                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Mauro S.      ³26/06/07³127549³Tratamento do datatype do MAU_PONTOS      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Crd225Grv(		nOpc,		aCamposEnc,	aRecno1,	aHeader1,;
								aCols1,		aRecno2,	aHeader2, 	aCols2,;
								aRecno3,	aHeader3,	aCols3 )

Local aArea			:= GetArea()						// Faz o backup da area                     
	
Local bCampo 		:= {|nCPO| Field(nCPO) }			// Captura a posicaodo campo
	
Local cAliasMemo	:= ""								// Alias dos memos virtuais
Local cItem     	:= Repl("0",Len(MAU->MAU_ITEM))	// Reserva espaco para o item da campanha

Local nX        	:= 0								// Variavel de looping
Local nCntFor   	:= 0								// Variavel de looping								
Local nY        	:= 0								// Varicale de looping
Local nUsado1		:= Len( aHeader1 )					// Armazena o tamanho do aHeader
Local nUsado2 		:= Len( aHeader2 )					// Armazena o tamanho do aHeader
Local nUsado3		:= Len( aHeader3 )					// Armazena o tamanho do aHeader
Local nFolder		:= 0								// 
Local nPosPonto		:= 0								// Armazena os pontos da campanha

Local lTravou   	:= .F.  							// Variavel de controle

Local cTipo			:= "C"								// Armazena o tipo do campo MAU_PONTOS
Local aAreaMAU		:= {}								// Backup da area antes de procurar o type do MAU_PONTOS
Local lEntra		:= .F.								// Variavel de controle paraq o MAU_PONTOS do aCols1

aAreaMAU := GetArea()
dbSelectArea("SX3") 
dbSetOrder( 2 )
If dbSeek( "MAU_PONTOS" )
	cTipo := X3_TIPO
EndIf
RestArea( aAreaMAU )

If nOpc <> 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava a pesquisa e as regras da pesquisa                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os dados da Campanha³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("MA0")
		dbSetOrder(1)
		If dbSeek( xFilial( "MA0" ) + M->MA0_CODCAM )
			RecLock( "MA0", .F. )
		Else
			RecLock( "MA0", .T. )
		EndIf
		For nCntFor := 1 To FCount()
			FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor)))
		Next nCntFor
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os campos Memos Virtuais					 				  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("aMemos") == "A"
			For nCntFor := 1 To Len(aMemos)
				cVar := aMemos[nCntFor][2]
				cAliasMemo := If(len(aMemos[nCntFor]) == 3,aMemos[nCntFor][3],Nil)
				MSMM(,TamSx3(aMemos[nCntFor][2])[1],,&cVar,1,,,"SKC",aMemos[nCntFor][1],cAliasMemo)
			Next nCntFor
		EndIf
                        
		MA0->MA0_FILIAL := xFilial( "MA0" )
		MsUnLock()                                    
		    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os dados  do MAU (Pontos da Campanha)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len( aCols1 )
			nPosPonto	:=	aScan(aHeader1,{|x| Alltrim( x[2] ) == "MAU_PONTOS"})

			lTravou := .F.
			If nX <= Len( aRecNo1 )
				DbSelectArea("MAU")
				DbGoTo(aRecNo1[nX])
				RecLock("MAU")
				lTravou := .T.
			EndIf
			
			If ( !aCols1[nX][nUsado1+1] )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica o tipo do MAU_PONTOS e atribui se pode entrar³
				//³ou nao.                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  cTipo =="C"
					If Val( aCols1[nX][nPosPonto] ) > 0 
						lEntra := .T.
					EndIf	
				Else	 
					If aCols1[nX][nPosPonto] > 0
						lEntra :=.T.
					EndIf
				EndIf   
				
				If lEntra		 
					If !lTravou 
						RecLock("MAU",.T.)
					EndIf
					For nY := 1 To Len(aHeader1)
						If aHeader1[nY][10] <> "V"
							MAU->(FieldPut(FieldPos(aHeader1[nY][2]),aCols1[nX][nY]))
						EndIf
					Next nY
					cItem := Soma1( cItem, Len( MAU->MAU_ITEM ) )
					MAU->MAU_FILIAL	:= xFilial( "MAU" )
					MAU->MAU_CODCAM	:= MA0->MA0_CODCAM
					MAU->MAU_ITEM	:= cItem
					MAU->MAU_TIPO	:= "1"
					MsUnLock()                   
						
					lGravou := .T.
				EndIf
			Else	
				If lTravou        
					RecLock("MAU")
						MAU->( DbDelete() )
					MsUnlock()
				EndIf				
			EndIf
			MsUnLock()		
		Next nX

		For nX := 1 To Len( aCols2 )
			nPosPonto	:=	aScan(aHeader2,{|x| Alltrim( x[2] ) == "MAU_PONTOS"})

			lTravou := .F.
			If nX <= Len( aRecNo2 )
				DbSelectArea("MAU")
				DbGoTo(aRecNo2[nX])
				RecLock("MAU")
				lTravou := .T.
			EndIf
			
			If ( !aCols2[nX][nUsado2 + 1] )   
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica o tipo do MAU_PONTOS e atribui se pode entrar³
				//³ou nao.                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    lEntra := .F.
				If  cTipo =="C"
					If Val(aCols2[nX][nPosPonto]) > 0
						lEntra := .T.
					EndIf	
				Else	 
					If aCols2[nX][nPosPonto] > 0
						lEntra :=.T.
					EndIf
				EndIf   
				
				If lEntra		 
					If !lTravou 
						RecLock("MAU",.T.)
					EndIf
					For nY := 1 To Len(aHeader2)
						If aHeader2[nY][10] <> "V"
							MAU->(FieldPut(FieldPos(aHeader2[nY][2]),aCols2[nX][nY]))
						EndIf
					Next nY
					cItem := Soma1( cItem, Len( MAU->MAU_ITEM ) )
					MAU->MAU_FILIAL	:= xFilial( "MAU" )
					MAU->MAU_CODCAM	:= MA0->MA0_CODCAM
					MAU->MAU_ITEM	:= cItem
					MAU->MAU_TIPO	:= "2"
					MsUnLock()                   
						
					lGravou := .T.
				EndIf
			Else	
				If lTravou        
					RecLock("MAU")
						MAU->( DbDelete() )
					MsUnlock()
				EndIf				
			EndIf
			MsUnLock()
		Next nX

		For nX := 1 To Len( aCols3 )
			
			nPosPonto	:=	aScan(aHeader3,{|x| Alltrim( x[2] ) == "MAU_PONTOS"})			
			lTravou := .F.
			If nX <= Len( aRecNo3 )
				DbSelectArea( "MAU" )
				DbGoTo(aRecNo3[nX])
				RecLock( "MAU" )
				lTravou := .T.
			EndIf
			
			If ( !aCols3[nX][nUsado3 + 1] ) 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica o tipo do MAU_PONTOS e atribui se pode entrar³
				//³ou nao.                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    lEntra := .F.
				If  cTipo =="C"
					If Val(aCols3[nX][nPosPonto]) > 0
						lEntra := .T.
					EndIf	
				Else	 
					If aCols3[nX][nPosPonto] > 0
						lEntra :=.T.
					EndIf
				EndIf   
				
				If lEntra		 
					If !lTravou 
						RecLock("MAU",.T.)
					EndIf
					For nY := 1 To Len( aHeader3 )
						If aHeader3[nY][10] <> "V"
							MAU->(FieldPut(FieldPos(aHeader3[nY][2]),aCols3[nX][nY]))
						EndIf
					Next nY
					cItem := Soma1( cItem, Len( MAU->MAU_ITEM ) )
					MAU->MAU_FILIAL	:= xFilial( "MAU" )
					MAU->MAU_CODCAM	:= MA0->MA0_CODCAM
					MAU->MAU_ITEM	:= cItem
					MAU->MAU_TIPO	:= "3"
					MsUnLock()                   
						
					lGravou := .T.
				EndIf
			Else	
				If lTravou        
					RecLock("MAU")
						MAU->( DbDelete() )
					MsUnlock()
				EndIf				
			EndIf
			MsUnLock()
		Next nX
	End Transaction	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deleta MAT (Pontos da Campanha)            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("MAU")
	dbSetOrder(1)
	If dbSeek(xFilial("MAU")+M->MA0_CODCAM)
		RecLock("MAU")
			dbDelete()
		MsUnlock()
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deleta MAS (Campanha)                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("MA0")
	RecLock("MA0")
		dbDelete()
	MsUnlock()    
EndIf

RestArea(aArea)    

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CRD225CanDel³ Autor ³Vendas Clientes      ³ Data ³30.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da exclusao da Campanha                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanha de Fidelizacao             					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          

Function Crd225CanDel()

Local lRet 		:= .T.
Local cAliasMAY	:= "MAY" 
Local aArea		:= GetArea()


#IFDEF TOP
	Local cQuery	:= ""
	Local lQuery	:= .F.
#ENDIF	

#IFDEF TOP

    lQuery := .T.

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se tem algum registro na tabela MAY (Cliente X Resgate de Vale Compra)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cAliasMAY := "QRYMAY"
    
    cQuery := "SELECT COUNT(*) QTDMAY "
    cQuery += " FROM "
    cQuery += RetSqlName("MAY")+ " MAY "
    cQuery += " WHERE "
	    
    cQuery += "MAY_FILIAL = '" + xFilial( "MAY" ) +"' AND "
    cQuery += "MAY_CODCAM = '" + MA0->MA0_CODCAM +"' AND "    
    cQuery += "MAY.D_E_L_E_T_ = ' ' "
	    
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasMAY,.F.,.T.)
		
	If (cAliasMAY)->QTDMAY > 0
		lRet := .F.                	
	EndIf
	
	dbCloseArea()
	
	dbSelectArea("MA0")
	
#ELSE
                                 
	dbSelectArea( "MAY" )
	dbSetOrder( 2 )
		
	If MAY->( dbSeek(xFilial("MAY")+ MA0->MA0_CODCAM ) )
		lRet := .F.
	EndIf              
	
	dbSelectArea("MA0")

                          
#ENDIF

	RestArea( aArea ) 

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDProcCam ºAutor  ³Vendas Clientes       º Data ³ 30/11/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe alguma campanha ativa.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA225                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÑÍÏÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  DATA  ³ BOPS ³Program.³ ALTERACAO                                    º±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±º        ³      ³        ³                                              º±±
±±º        ³      ³        ³                                              º±±
±±º        ³      ³        ³                                              º±±
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRD225ProcCam()
Local lRet 	:= .T.
Local aArea	:= GetArea()
Local cAliasMA0	:= "MA0"

#IFDEF TOP
	Local cQuery	:= ""
	Local lQuery	:= .F.
#ELSE
	Local cIndMA0	:= ""		
	Local cKey		:= ""	
	Local nIndMA0	:= 0
#ENDIF	

#IFDEF TOP

    lQuery := .T.
    
    cAliasMA0 := "QRYMA0"
    
    cQuery := "SELECT COUNT(*) QTDMA0 "
    cQuery += " FROM "
    cQuery += RetSqlName("MA0")+ " MA0 "
    cQuery += " WHERE "
    
    cQuery += "MA0_FILIAL = '" + xFilial( "MA0" ) +"' AND "
    cQuery += "MA0_CODCAM <> '" + M->MA0_CODCAM + "' AND "     
    cQuery += "MA0_STATUS = '1'  AND "    
    cQuery += "MA0.D_E_L_E_T_ = ' ' "
    
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasMA0,.F.,.T.)

	If (cAliasMA0)->QTDMA0 > 0
		lRet := .F.
	EndIf	

	dbCloseArea()
	
	dbSelectArea("MA0")
	
#ELSE
                                 
	dbSelectArea( "MA0" )
	dbSetOrder( 1 )
	cIndMA0 := CriaTrab( NIL, .F.)

	cKey      := "MA0_FILIAL+MA0_STATUS"

	IndRegua( "MA0", cIndMA0, cKey)
	nIndMA0 := RetIndex( "MA0" )
	dbSetIndex( cIndMA0 + OrdBagExT() )
	dbSetOrder( nIndMA0 + 1 )	

    If MA0->( dbSeek(xFilial("MA0")+'1' ) )
    	If MA0->MA0_CODCAM <> M->MA0_CODCAM
    		lRet := .F.		
		EndIf
	EndIf	
 
	dbSelectArea("MA0")
	dbClearFilter()
	RetIndex("MA0")
	Ferase(cIndMA0+OrdBagExt())
	
#ENDIF	
          
If !lRet
	Aviso(STR0006, STR0007, {"Ok"} )  // Para ativar esta campanha será necessário inativar a campanha que esta ativa no momento.
EndIf
RestArea( aArea )

Return lRet
