#include "pmsa204.ch"
#include "protheus.ch"
#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PMSA204  ³Autor  ³ Totvs				  ³ Data ³ 07/05/2009     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Insumos do Projeto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Número da rotina chamada na MBrowse                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PMSA204(nRotina)
Private cCadastro	:= STR0001										//"Insumos"
Private lUsaCCT 	:= GetMV( "MV_PMSCCT" ) == "2"                 // 1=Nao;2=Sim
Private lConfirma 	:= .T.

SaveInter()

// so executa se houver o template aplicadoc com licença, caso 
// contrario mostra uma mensagem de alerta e aborta
ChkTemplate("CCT")

RestInter()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PA204Dialog³ Autor ³ Totvs                 ³ Data ³ 07-05-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao        ³±±
±±³          ³ de Composicoes                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA204Dialog( cProjet, cRevisa, bReCalc )
	Local aNoFields := {"AEM_FILIAL","AEM_PROJET","AEM_REVISA","AEM_INSUMO"}	// Campos que nao serao apresentados no aCols
	Local bCond     := {|| .T.}													// Se bCond .T. executa bAction1, senao executa bAction2
	Local cMarca	:= "X"				// Caractere de marca
	Local lInverte	:= .F.
	Local lOk		:= .F.
	Local oDlg
	Local oProjet
	Local oRevisa
	Local cQuery    := ""
	Local cSeek     := ""
	Local cWhile    := ""
	Local nI		:= 0
	Local nUsado	:= 0
	Local cPesq		:= Space( TamSX3( "AJT_DESCRI" )[1] )
	Local nRadio	:= 1
	Local oPesq
	Local oRadio
	Local lImpExp	:= .T.

	Private oGetD
	Private lRefresh 	:= .T.
	Private aHeader 	:= {}
	Private aCols 		:= {}
	Private aHeaderCM 	:= {}
	Private aColsCM 	:= {}
	Private aRotina 	:= {{"Pesquisar", "AxPesqui", 0, 1},;
	                    	{"Visualizar", "AxVisual", 0, 2},;
		                    {"Incluir", "AxInclui", 0, 3},;
		                    {"Alterar", "AxAltera", 0, 4},;
	    	                {"Excluit", "AxDeleta", 0, 5}}


	If ExistBlock("PMA204IE") // Botoes de importar/exportar
		lImpExp := ExecBlock("PMA204IE",.F.,.F.)
	EndIf

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("AJY")

	PA204AtuBrw( cProjet, cRevisa )

	DEFINE MSDIALOG oDlg TITLE STR0001 From C(264),C(241)  TO C(610), C(774) OF oMainWnd PIXEL

	@ C(000),C(000) TO C(020),C(267) LABEL "" PIXEL OF oDlg

	@ C(005),C(131) MsGet oRevisa Var cRevisa Size C(060),C(009) COLOR CLR_BLACK PIXEL OF oDlg READONLY
	@ C(005),C(024) MsGet oProjet Var cProjet Size C(060),C(009) COLOR CLR_BLACK PIXEL OF oDlg READONLY
	
	@ C(008),C(003) Say STR0002 			Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(008),C(111) Say STR0003 			Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

	@ C(163),C(016) Button STR0005 	Size C(037),C(012) PIXEL OF oDlg ACTION ( PA204Act( 2, cProjet, cRevisa ) ) 	// Visualizar
	@ C(163),C(059) Button STR0006	Size C(037),C(012) PIXEL OF oDlg ACTION ( PA204Act( 4, cProjet, cRevisa  ) ) 	// Alterar
	@ C(163),C(102) Button STR0007	Size C(037),C(012) PIXEL OF oDlg ACTION ( PA204Act( 5, cProjet, cRevisa  ) ) 	// Excluir
	If lImpExp
		@ C(163),C(144) Button STR0004	Size C(037),C(012) PIXEL OF oDlg ACTION ( PA204Imp( cProjet, cRevisa ) ) 	// Importar
		@ C(163),C(186) Button STR0014	Size C(037),C(012) PIXEL OF oDlg ACTION ( PA204Exp( cProjet, cRevisa ) ) 	// Exportar
	EndIf
	@ C(163),C(228) Button STR0008	Size C(037),C(012) PIXEL OF oDlg ACTION ( oDlg:End() )    						// Cancelar

	oGetD	:= MsNewGetDados():New(034, 005, 170, 338, 2,"AlwaysTrue","AlwaysTrue","+AEM_ITEM",{}/*aCpoGet*/,,,"AlwaysTrue","AlwaysTrue","AlwaysTrue",,aHeader,aCols)

	@ C(135),C(002) TO C(160),C(059) LABEL "Indice de Pesquisa" PIXEL OF oDlg //"Indice de Pesquisa"
	@ C(142),C(005) RADIO oRadio Var nRadio Items "Código", "Descricao" 3D Size C(047),C(010) PIXEL OF oDlg //"Código", "Descricao"

	@ C(142),C(064) Say "Pesquisar por" Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg //"Pesquisar por"
	@ C(148),C(064) MsGet oPesq Var cPesq Picture "@!" Size C(160),C(009) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(147),C(228) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION PA204Pesq( nRadio, cPesq )  //"Pesquisar"
	ACTIVATE MSDIALOG oDlg CENTERED

	// Efetua o recalculo dos custos
	aCols := NIL
	PMS200ReCalc()
	Eval( bReCalc )
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)                                                         
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)                                                                

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³PA204Act ³ Autor   ³ Totvs                  ³ Data ³07/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel pela acao dos botoes                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PA204Act( nOpc, cProjet, cRevisa  )
	Local cInsumo		:= ""
	Local nPosInsumo	:= aScan( aHeader, { |x| x[2] == "AJY_INSUMO" } )

	If !Empty( aCols ) .AND. oGetD:nAt >= 1 .AND. nPosInsumo > 0
		cInsumo := aCols[oGetD:nAt][nPosInsumo]
	EndIf

	If !Empty( cInsumo )
		INCLUI := .F.
		ALTERA := .F.
		EXCLUI := .F.
		If nOpc == 4
			ALTERA := .T.
		ElseIf nOpc == 5
			EXCLUI := .T.
		EndIf

		// Localiza o insumo
		DbSelectArea( "AJY" )
		AJY->( DbSetOrder( 1 ) )
		If AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa + cInsumo ) )
			PMA204Mnt( cProjet, cRevisa, cInsumo, nOpc )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o browser³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 5 .OR. nOpc == 4
			PA204AtuBrw( cProjet, cRevisa )
			oGetD:aCols := aCols
			oGetD:oBrowse:Refresh()
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMA204Mnt ºAutor  ³Pedro Pereira Lima  º Data ³  23/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para efetuar inclusão/alteração/exclusão/visualizaçãoº±±
±±º          ³de insumos padrão.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA016                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMA204Mnt( cProjet, cRevisa, cInsumo, nOpcx )
	Local cAliasE 		:= "AJY"
	Local aAlterEnch 	:= {}
	Local nModelo 		:= 3
	Local lF3 			:= .F.
	Local lMemoria 		:= .T.
	Local lColumn 		:= .F.
	Local caTela 		:= ""
	Local lNoFolder 	:= .F.
	Local lProperty 	:= .T.
	Local lLocaliz  	:= .F.
	Local nI
	Local nUsado 		:= 0
	Local aTitles 		:= {STR0009,STR0010} // "Dados Gerais"#"Custo Horário"
	Local aButtons		:= {}  
	Local aCpoGet 		:= {}             
	Local aCampos		:= {}
	Local nMaxLin		:= 99 //Numero maximo de linhas da GetDados
	Local lOk
	Local nOpcG 		:= GD_UPDATE+GD_INSERT+GD_DELETE
	Local nTop			:= 0
	Local nLeft			:= 0
	Local nBottom		:= 0
	Local nRight		:= 0
	Local cMsg			:= ""
	Local aAreaAJY		:= {}
	Local nPosCod		:= 0
	Local nPosQuant		:= 0
	Local nPosUnit		:= 0
	Local nPosCusto		:= 0
	Local nPosTpParc	:= 0
	Local nPosUM		:= 0
	Local nPosDesc		:= 0
	Local nMDO			:= 0
	Local nMateri		:= 0
	Local nManut		:= 0

	Private oGetDados
	Private oDlg
	Private oGetD
	Private oEnch1
	Private oEnch2
	Private oPanel1
	Private oPanel2
	Private aTELA[0][0]
	Private aGETS[0]
	Private lRefresh	:= .T.
	Private aHeaderCM 	:= {}
	Private aColsCM 	:= {}
	Private aSize	   	:= {}
	Private aInfo	 	:= {} // Coluna Inicial, Linha Inicial
	Private aObjects	:= {}
	Private aPosObj	   	:= {}
	Private aCpo1Ench 	:= {}
	Private aCpo2Ench 	:= {}

	If nOpcX == 5 // Exclusao
		lLocaliz := PA204UsaInsumo( cProjet, cRevisa, cInsumo )
		If !lLocaliz
			If MsgYesNo( STR0011 )
				PA204Exc( cProjet, cRevisa, cInsumo, .T. )
			EndIf
		EndIf
		
		Return
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define a dimensao da janela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcX <> 2 .Or. nOpcX <> 5 //Se for visualizacao ou exclusao, restringo a alteracao dos campos da getdados
		aCpoGet := { "AEM_SUBINS", "AEM_TPPARC", "AEM_QUANT" }
	EndIf
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("AEM")
	
	While !Eof() .And. SX3->X3_ARQUIVO == "AEM"
		If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .AND. SX3->X3_CAMPO <> "AEM_INSUMO"
			nUsado++
			AADD( aHeaderCM, {	Trim(X3Titulo()),;
								SX3->X3_CAMPO,;
								SX3->X3_PICTURE,;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								"",;
								SX3->X3_TIPO,;
								"",;
								SX3->X3_CONTEXT })
		EndIf

		DbSkip()
	EndDo
	
	If nOpcX <> 3
		dbSelectArea("AEM")
		AEM->(dbSetOrder(1))
		AEM->(dbSeek( xFilial( "AEM" ) + cProjet + cRevisa + cInsumo ) )
		While AEM->( !Eof() ) .AND. AEM->AEM_FILIAL + AEM->AEM_PROJET + AEM->AEM_REVISA + AEM->AEM_INSUMO == xFilial( "AEM" ) + cProjet + cRevisa + cInsumo
			aADD(aColsCM,Array(Len(aHeaderCM)+1))
			For nI := 1 To Len(aHeaderCM)
				// Campo não é virtual, isto é, existe o campo fisicamente na tabela
				If ( aHeaderCM[nI][10] != "V")
					aColsCM[Len(aColsCM)][aScan(aHeaderCM,{ |x| x[2] == aHeaderCM[nI][2]})] := AEM->&(aHeaderCM[nI][2])
				EndIf
			Next nI
			aColsCM[Len(aColsCM)][Len(aHeaderCM)+1] := .F.

			// Realiza o calculo do custo
			nPosCod		:= aScan( aHeaderCM, { |x| "AEM_SUBINS" == x[2] } )
			nPosQuant	:= aScan( aHeaderCM, { |x| "AEM_QUANT " == x[2] } )
			nPosUnit	:= aScan( aHeaderCM, { |x| "AEM_UNITAR" == x[2] } )
			nPosCusto	:= aScan( aHeaderCM, { |x| "AEM_CSTITE" == x[2] } )
			nPosTpParc	:= aScan( aHeaderCM, { |x| "AEM_TPPARC" == x[2] } )
			nPosUM		:= aScan( aHeaderCM, { |x| "AEM_UM    " == x[2] } )
			nPosDesc	:= aScan( aHeaderCM, { |x| "AEM_DESCRI" == x[2] } )

			If nPosCod > 0
				aAreaAJY	 := AJY->( GetArea() )
	
				DbSelectArea( "AJY" )
				AJY->( DbSetOrder( 1 ) )
				If AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa + aColsCM[ Len( aColsCM ) ][ nPosCod ]  ) )
					aColsCM[ Len( aColsCM ) ][ nPosUnit  ] := AJY->AJY_CUSTD
					aColsCM[ Len( aColsCM ) ][ nPosCusto ] := aColsCM[ Len( aColsCM ) ][ nPosQuant ] * aColsCM[ Len( aColsCM ) ][ nPosUnit ] 
					aColsCM[ Len( aColsCM ) ][ nPosUM    ] := AJY->AJY_UM
					aColsCM[ Len( aColsCM ) ][ nPosDesc  ] := AJY->AJY_DESC
	
					If aColsCM[ Len( aColsCM ) ][ nPosTpParc ] == "H" // Mao de Obra
						nMDO		+= aColsCM[ Len( aColsCM ) ][ nPosCusto ]
	
					ElseIf aColsCM[ Len( aColsCM ) ][ nPosTpParc ] == "M" // Material
						nMateri		+= aColsCM[ Len( aColsCM ) ][ nPosCusto ]
	
					ElseIf aColsCM[ Len( aColsCM ) ][ nPosTpParc ] == "N" // Manutencao
//						nManut		+= aColsCM[ Len( aColsCM ) ][ nPosCusto ]
					EndIf
				EndIf
	
				RestArea( aAreaAJY )
			EndIf

			AEM->(dbSkip())
		EndDo  
	EndIf
	
	// se aCols estiver vazio. Cria a 1a linha vazia
	If Empty(aColsCM)
		AADD(aColsCM,Array(nUsado+1))
		For nI := 1 To nUsado
			aColsCM[1][nI] := CriaVar(aHeaderCM[nI][2])
		Next nI
		aColsCM[1][nUsado+1] := .F.
		aColsCM[1][aScan(aHeaderCM,{ |x| AllTrim(x[2]) == "AEM_ITEM"})] := "01"
	EndIf
	
	aCpo1Ench := {	"AJY_INSUMO",;
					"AJY_DESC",;
					"AJY_TIPO",;
					"AJY_UM",;
					"AJY_SEGUM",;
					"AJY_CONV",;
					"AJY_TIPCON",;
					"AJY_PRODUT",;
					"AJY_RECURS",;
					"AJY_GRUPO",;
					"AJY_BCOMPO",;
					"AJY_DATREF",;
					"AJY_CUSTD",;
					"AJY_CUSTIM" }
					
	aCampos	:= aClone( aCpo1Ench )
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAliasE)
	
	While !Eof() .And. SX3->X3_ARQUIVO == cAliasE
		If	!(SX3->X3_CAMPO $ "AJY_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO) .And.;
		 	aScan(aCpo1Ench,{ |x| x == AllTrim(SX3->X3_CAMPO)}) == 0
			AADD(aCpo2Ench,SX3->X3_CAMPO)
			
			aAdd( aCampos, SX3->X3_CAMPO )
		EndIf
		DbSkip()
	EndDo
	
	aAlter1Ench := aClone(aCpo1Ench)
	aAlter2Ench := aClone(aCpo2Ench)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do tamanho dos objetos                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize		:= MsAdvSize()
	aObjects	:= {}
	AAdd( aObjects, { 100, 100, .T., .T. } ) // 100, 100
	AAdd( aObjects, { 100, 100, .T., .F. } ) // 100, 080
	aInfo		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }                                        
	aPosObj		:= MsObjSize( aInfo, aObjects )
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],aSize[2] TO aSize[6],aSize[5] PIXEL
		oFolder 		:= TFolder():New(,,aTitles,{'',''},oDlg,,,,.T.,.F.,,)
		oFolder:Align	:= CONTROL_ALIGN_ALLCLIENT
	
		oPanel1 := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oFolder:aDialogs[1],NIL,.T.,.F.,NIL,NIL,aPosObj[1,3],aPosObj[1,4],.T.,.F. )
		oPanel1:Align := CONTROL_ALIGN_ALLCLIENT                        
	
		RegToMemory( "AJY", If(nOpcX == 3,.T.,.F.) )
		oEnch1 := MsMGet():New(cAliasE,,nOpcX,/*aCRA*/,/*cLetra*/,;
									 /*cTexto*/,aCpo1Ench,aPosObj[1],aAlter1Ench,nModelo,/*nColMens*/,;
									 /*cMensagem*/,/*cTudoOk*/,oPanel1,lF3,lMemoria,lColumn,caTela,;
									 lNoFolder,lProperty)
	
		oPanel2 := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oFolder:aDialogs[2],NIL,.T.,.F.,NIL,NIL,aPosObj[1,3],aPosObj[1,4],.T.,.F. )
		oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
	
		RegToMemory( "AJY", If(nOpcX == 3,.T.,.F.) )
		oEnch2 := MsMGet():New(cAliasE,,nOpcX,/*aCRA*/,/*cLetra*/,;
									 /*cTexto*/,aCpo2Ench,aPosObj[1],aAlter2Ench,nModelo,/*nColMens*/,;
									 /*cMensagem*/,/*cTudoOk*/,oPanel2,lF3,lMemoria,lColumn,caTela,;
									 lNoFolder,lProperty) 
									 	
		oGetDados := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpcG, "a204GD1LinOk()","AlwaysTrue","+AEM_ITEM",aCpoGet,,,"AlwaysTrue","AlwaysTrue","PMS204Del()",oPanel2,aHeaderCM,aColsCM)

		PA204Brw()
		PA204Gatilho( .T. )

		If M->AJY_TPPARC == "1"
			nMDO	:= IIf( nMDO    == 0, M->AJY_MDO, 		nMDO 	)
			nMATERI	:= IIf( nMATERI == 0, M->AJY_MATERI, 	nMATERI )
			nMANUT	:= IIf( nMANUT  == 0, M->AJY_MANUT, 	nMANUT 	)
		EndIf

		Pma204Recalc( nMDO, nMateri, nManut )

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{||lOk:=PMS204Ok(nOpcX),Iif(lOk,oDlg:End(),.F.)},{||oDlg:End()},,/*@aButtons*/))

	If lOk
		If nOpcX == 4 // Alteracao
			PA204Grv( nOpcX, "AEM", aCampos )
		EndIf
	EndIf
	A204Cancel()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PA204Grv     ³ Autor ³ Totvs             ³ Data ³ 12/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel pela gravacao das inclusoes e alteracoes³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PA204Grv(nOpc,cAlias, aCampos )
	Local nInc     := 1
	Local nOrdSeek := 1
	Local aGrvCps  := {}
	Local cCpoItem := "AEM_ITEM"
	Local cCndSeek := "xFilial('AEM') + M->AJY_PROJET + M->AJY_REVISA + M->AJY_INSUMO" 
	Local aCampos	:= AJY->( DbStruct() )
	Local lNewRec	:= .F.
	
	//Trata campos extras
	aAdd(aGrvCps,{"AEM_FILIAL"   ,"xFilial('AEM')"   })

	//
	DbSelectArea( "AJY" )
	AJY->( DbSetOrder( 1 ) )
	lNewRec := AJY->( !DbSeek( xFilial( "AJY" ) + M->AJY_PROJET + M->AJY_REVISA + M->AJY_INSUMO ) )

	//Gravacao do insumo
	RecLock( "AJY", lNewRec )
	For nInc := 1 To Len( aCampos )
		If AJY->( FieldPos( aCampos[nInc][1] ) ) > 0
			AJY->( &( aCampos[nInc][1] ) ) := M->( &( aCampos[nInc][1] ) )
		EndIf
	Next

	AJY->( MsUnLock() )
	
	//Executa rotina pra tratar gravação das variaveis acima e do MsNewGetDados
	If Upper( M->AJY_GRORGA ) $ "A"
		fGravaGD(oGetDados,cAlias,aGrvCps,nOpc,nOrdSeek,cCndSeek,cCpoItem)
	EndIf
	
	PA204AtuPai( M->AJY_PROJET, M->AJY_REVISA, M->AJY_INSUMO )
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fGravaGD     ³ Autor ³ Totvs             ³ Data ³ 12/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel pela gravacao das inclusoes e alteracoes³±±
±±³          ³ apontadas no MsNewGetDados / tratamento por objeto         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGravaGD()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fGravaGD(oObjct,cAlias,aCposAdd,nTpOper,nOrdSeek,cCndSeek,cCpoItm)

Local x := 1
Local y := 1
Local k := 1
Local nPosQtd 	:= aScan(oObjct:aHeader,{|x|Alltrim(x[2])=="AEM_QUANT"})
Local nPosIns 	:= aScan(oObjct:aHeader,{|x|Alltrim(x[2])=="AEM_SUBINS"})
Local nPosIte 	:= aScan(oObjct:aHeader,{|x|Alltrim(x[2])=="AEM_ITEM"})

Private cCodItem := StrZero(1,Len(CriaVar(cCpoItm)))

DbSelectArea(cAlias)

For x:=1 To Len(oObjct:aCols)
	If oObjct:aCols[x][nPosQtd] == 0 .And. Empty( oObjct:aCols[x][nPosIns] )
		Loop
	EndIf

	If !oObjct:aCols[x,Len(oObjct:aHeader)+1]
		
		DbSelectArea(cAlias)
		DbSetOrder(nOrdSeek)
		
		If nTpOper == 3
			RecLock(cAlias,.T.)
		ElseIf DbSeek(&(cCndSeek)+oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==cCpoItm})])
			RecLock(cAlias,.F.)
		Else
			RecLock(cAlias,.T.)
		EndIf
		
		For y:=1 To Len(oObjct:aHeader)
			&(oObjct:aHeader[y,2]) := oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==AllTrim(oObjct:aHeader[y,2])})]
		Next y
		
		For k:=1 To Len(aCposAdd)
			&(aCposAdd[k,1]) := &(aCposAdd[k,2])
		Next k
		
		cCodItem := Soma1(cCodItem)

		AEM->AEM_PROJET := M->AJY_PROJET
		AEM->AEM_REVISA := M->AJY_REVISA
		AEM->AEM_INSUMO	:= M->AJY_INSUMO

		MsUnLock()
	Else
		DbSelectArea(cAlias)
		DbSetOrder(nOrdSeek)
		If nTpOper != 3
			DbSelectArea( "AEM" )
			AEM->( DbSetOrder( 1 ) )
			If AEM->( DbSeek( xFilial( "AEM" ) + M->AJY_PROJET + M->AJY_REVISA + M->AJY_INSUMO + oObjct:aCols[x][nPosIte] ) )
				RecLock( "AEM" )
				AEM->( DbDelete() )
				MsUnLock()
			EndIf
			
			If !PA204UsaInsumo( M->AJY_PROJET, M->AJY_REVISA, oObjct:aCols[x][nPosIns], .F. )
				PA204Exc( M->AJY_PROJET, M->AJY_REVISA, oObjct:aCols[x][nPosIns], .T. )
			EndIf
		EndIf
	EndIf
Next x

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PA204Exc     ³ Autor ³ Totvs             ³ Data ³ 12/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel pela exclusao                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PA204Exc( cProjet, cRevisa, cInsumo, lRecursivo )
	Local	aArea		:= GetArea()
	Local	aAreaAJY	:= AJY->(GetArea())

	Default lRecursivo	:= .F.

	DbSelectArea( "AJY" )
	AJY->( DbSetOrder( 1 ) )
	AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa + cInsumo ) )
	While AJY->( !Eof() ) .AND. AJY->AJY_FILIAL + AJY->AJY_PROJET + AJY->AJY_REVISA + AJY->AJY_INSUMO == xFilial( "AJY" ) + cProjet + cRevisa + cInsumo
		RecLock( "AJY" )
		AJY->( DbDelete() )
		AJY->( DbSkip() )
	End

	PA204ExcItem( cProjet, cRevisa, cInsumo, lRecursivo )
	
	RestArea(aAreaAJY)
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PA204ExcItem ³ Autor ³ Totvs             ³ Data ³ 01/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel pela exclusao                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PA204ExcItem( cProjet, cRevisa, cInsumo, lRecursivo )
	Local	aArea		:= GetArea()
	Local	aAreaAEM	:= AEM->(GetArea())

	DbSelectArea( "AEM" )
	AEM->( DbSetOrder( 1 ) )
	AEM->( DbSeek( xFilial( "AEM" ) + cProjet + cRevisa + cInsumo ) )
	While AEM->( !Eof() ) .AND. AEM->AEM_FILIAL + AEM->AEM_PROJET + AEM->AEM_REVISA + AEM->AEM_INSUMO == xFilial( "AEM" ) + cProjet + cRevisa + cInsumo
		cSubIns	:= AEM->AEM_SUBINS

		RecLock( "AEM" )
		AEM->( DbDelete() )
		AEM->( DbSkip() )

		aArea := AEM->( GetArea() )
		If lRecursivo
			If !PA204UsaInsumo( cProjet, cRevisa, cSubIns, .F. )
				PA204Exc( cProjet, cRevisa, cSubIns, lRecursivo )
			EndIf
		EndIf

		RestArea( aArea )
	End
	
	RestArea(aAreaAEM)
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PA204Cpy     ³ Autor ³ Totvs             ³ Data ³ 12/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel copia do cadastro para o insumo         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PA204Cpy()
	Local lProduto	:= .T.
	Local cCodigo	:= ""
	Local cAlias	:= ""
	Local cCampo	:= ""
	Local aStruct	:= {}
	Local lRet		:= .T.
	Local nInc		:= 0
	Local nPos		:= 0

	If M->( FieldPos( "AJY_PRODUT" ) ) > 0
		lProduto	:= !Empty( M->AJY_PRODUT )
		cCodigo		:= IIf( lProduto, M->AJY_PRODUT, M->AJY_RECURS )
		cAlias		:= IIf( lProduto, "SB1", "AE8" )
		aStruct		:= (cAlias)->( DbStruct() )
	EndIf

	If INCLUI .And. !Empty( cCodigo )
		If MsgYesNo( STR0013 )
			// Posiciona para seguranca na copia
			DbSelectArea( cAlias )
			(cAlias)->( DbSetOrder( 1 ) )
			If (cAlias)->( DbSeek( xFilial( cAlias ) + cCodigo ) )
				For nInc := 1 To Len( aStruct )
					cCampo	:= AllTrim( substr( aStruct[nInc][1], 4 ) )
					If AJY->( FieldPos( "AJY_" + cCampo ) ) > 0 .AND. cCampo <> "FILIAL"
						If lProduto
							M->( &( "AJY_" + cCampo ) ) := SB1->( &( "B1_" + cCampo ) )
						Else
							M->( &( "AJY_" + cCampo ) ) := AE8->( &( "AE8_" + cCampo ) )
						EndIf
					EndIf
				Next
			EndIf
		EndIf
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PA204Brw     ³ Autor ³ Totvs             ³ Data ³ 12/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Habilita/Desabilita o browse conforme o campo AJY_GRORGA   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PA204Brw()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O browser deve estar habilitado somente se o conteudo do campo³
	//³AJY_GRORGA for A e tipo de parcela calculada (1)              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetDados:oBrowse:bGotFocus := { || oGetDados:lActive := ( Upper( M->AJY_GRORGA ) == "A" .AND. M->AJY_TPPARC == "1" ) }
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PA204Imp   ºAutor³ Totvs                     º Data ³ 16/04/2009    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descrição ³ Importacao de insumo do cadastro para o projeto                     ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PA204Imp(cAlias,nReg,nOpcx)                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ ExpC1 - Codigo do Projeto                                           º±±
±±º          ³ ExpC2 - Revisao                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Retorno   ³ Nenhum                                                              ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA204Imp( cProjet, cRevisa, cInsumo )
	Local aSize		:= {}
	Local aInfo		:= {}
	Local aPosObj	:= {}
	Local aObjects	:= {}
	Local aTrab		:= {}
	Local aInsumo	:= {}				// Array com os insumos
	Local aCodPrj	:= {}				// Array com os projetos selecionados
	Local aCriticas	:= {}				// Array com os insumos que ja existem
	Local aExport  	:= {}				// Array com os insumos a serem exportados
	Local aFields	:= {}				// Array com a estrutura da tabela para realizar a copia dinamicamente
	Local cMarca	:= "X"				// Caractere de marca
	Local cTrab		:= ""				// Arquivo de trabalho
	Local cIndTemp1 := ""				// Indice para trabalho
	Local cChave	:= ""				// Chave de pesquisa para exportar os insumos
	Local cCampo	:= ""
	Local lExport	:= .F.				// Determina se a exportacao podera ser realizada
	Local lInverte	:= .F.				// Determina se os itens devem apresentar selecionados
	Local lOk		:= .F.
	Local nInc		:= 0
	Local nIncPrj	:= 0
	Local nIncIns	:= 0
	Local nCampo	:= 0
	Local nExport	:= 0
	Local oDlg
	Local oPMSA2041	:= Nil
	Local oPMSA2042 := Nil
	
	Local oPanel
	Local oGet
	Local cProcura
	Local oButton

	Default cInsumo	:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apresenta os insumos disponiveis para exportacao           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aObjects, { 100, 100, .T., .T., .F. } ) 

	aSize	:= MsAdvSize()
	aInfo	:= { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPosObj	:= MsObjSize( aInfo, aObjects, .T. )

	If Empty( cInsumo )
	aTrab		:= {	{ "OK"    	, "C", 1, 							0 },;
						{ "CODIGO"	, "C", TamSX3( "AJZ_INSUMO"	)[1],	0 },;
						{ "DESCR"	, "C", TamSX3( "AJZ_DESC" 	)[1],	0 }}
				
	oPMSA2041 := FWTemporaryTable():New( "TRB" )  
	oPMSA2041:SetFields(aTrab) 
	oPMSA2041:AddIndex("1", {"CODIGO"})

	//------------------
	//Criação da tabela temporaria
	//------------------
	oPMSA2041:Create()

	Processa( { || MontaTRBImp() }, STR0015 ) // "Selecionando insumos para exportacao... Aguarde!"

	DbSelectArea( "TRB" )
	TRB->( DbGoTop() )
		DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6]-100,aSize[5]-100 OF oMainWnd PIXEL

		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,315,25,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP // Somente Interface MDI		                           
		@ 003 , 005 SAY STR0030 FONT oDlg:oFont PIXEL Of oPanel // "Selecione os insumos para importação"

		cProcura := space(TamSX3( "AJY_INSUMO")[1])
		@ 010,010 MSGET oGet VAR cProcura	SIZE 045,010 OF oPanel PIXEL
		oButton := TButton():New(010,060,"Procura",oPanel,{|| TRB->(dbSeek(cProcura)) },40,10,NIL,NIL,.F.,.T.,.T.,NIL,.F.,NIL,NIL,.F.)
	
		aCpos := {	{ "OK"    	, "", "", ""}, ;
					{ "CODIGO"	, "", A093RetDescr( "AJZ_INSUMO"	), "" },;
					{ "DESCR" 	, "", A093RetDescr( "AJZ_DESC" 		), "" } }
	
		oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca, {50,oDlg:nLeft,oDlg:nBottom,oDlg:nRight} )
		oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
		oMark:oBrowse:lCanAllMark	:= .T.
		oMark:oBrowse:bAllMark		:= { || PMA204Inv( cMarca, .T., oMark ) }
	
		ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End() }, { || oDlg:End() } ) ) CENTERED
	
		If lOk
			TRB->( DbGoTop() )
			While TRB->( !Eof() )
				If TRB->OK == "X"
					aAdd( aInsumo, { TRB->CODIGO, TRB->DESCR } )
				EndIf
				
				TRB->( DbSkip() )
			End
		EndIf
		
		If oPMSA2041 <> Nil
			oPMSA2041:Delete()
			oPMSA2041 := Nil
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Consiste se o insumo ja existe.                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty( aInsumo )
			For nIncIns := 1 To Len( aInsumo )
				DbSelectArea( "AJY" )
				AJY->( DbSetOrder( 1 ) )
				If AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa + aInsumo[ nIncIns ][1] ) )
					aAdd( aCriticas, { aInsumo[ nIncIns ][1], aInsumo[ nIncIns ][2], cProjet, cRevisa }  ) // Insumo, Desc CU, Projeto, Desc Prj
				Else
					aAdd( aExport, { cProjet, cRevisa, aInsumo[ nIncIns ][1] }  ) // Projeto, Revisao, Insumo
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Inclui os sub-insumos dos insumos que devem ser copiadas ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PA204IncSub( cProjet, cRevisa, aInsumo[ nIncIns ][1], @aExport, .F. )
				EndIf
			Next
	
			If !Empty( aCriticas )
				Alert( STR0016 + chr(13) + chr(10) + STR0017 )
		
				aTrab		:= {	{ "OK"    	, "C", 1, 							0 },;
									{ "CODIGO"	, "C", TamSX3( "AJY_INSUMO"	)[1],	0 },;
									{ "DESCR"	, "C", TamSX3( "AJY_DESC"	)[1],	0 },;
									{ "PROJET"	, "C", TamSX3( "AJY_PROJET"	)[1],	0 },;
									{ "REVISA"	, "C", TamSX3( "AJY_REVISA"	)[1],	0 } }
						
				oPMSA2042 := FWTemporaryTable():New( "TRB" )  
				oPMSA2042:SetFields(aTrab) 
				oPMSA2042:AddIndex("1", {"CODIGO","PROJET"})
			
				//------------------
				//Criação da tabela temporaria
				//------------------
				oPMSA2042:Create()
			
				For nInc := 1 To Len( aCriticas )
					RecLock( "TRB", .T. ) 
					TRB->CODIGO	:= aCriticas[ nInc ][1]
					TRB->DESCR		:= aCriticas[ nInc ][2]
					TRB->PROJET	:= aCriticas[ nInc ][3]
					TRB->REVISA	:= aCriticas[ nInc ][4]
					MsUnLock()
				Next
	
				DbSelectArea( "TRB" )
				TRB->( DbGoTop() )
	
				DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6]-100,aSize[5]-100 OF oMainWnd PIXEL
			
				aCpos := {	{ "OK"    	, "", "", ""}, ;
							{ "CODIGO"	, "", A093RetDescr( "AJY_INSUMO" ), "" },;
							{ "DESCR"	, "", A093RetDescr( "AJY_DESC"   ), "" },;
							{ "PROJET"	, "", A093RetDescr( "AJY_PROJET" ), "" },;
							{ "REVISA"	, "", A093RetDescr( "AJY_REVISA" ), "" } }
			
				oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca, { 16, 1, 173, 315 } )
				oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
				oMark:oBrowse:lCanAllMark	:= .T.
				oMark:oBrowse:bAllMark		:= { || PMA204Inv( cMarca, .T., oMark ) }
			
				ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End(), .F. }, { || oDlg:End() } ) ) CENTERED

				oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,315,25,.T.,.T. )
				oPanel:Align := CONTROL_ALIGN_TOP // Somente Interface MDI		                           

				cProcura := space(TamSX3( "AEG_COMPUN")[1])
				@ 010,010 MSGET oGet VAR cProcura	SIZE 045,010 OF oPanel PIXEL
				oButton := TButton():New(010,060,"Procura",oPanel,{|| TRB->(dbSeek(cProcura)) },40,10,NIL,NIL,.F.,.T.,.T.,NIL,.F.,NIL,NIL,.F.)
	
				If lOk
					TRB->( DbGoTop() )
					While TRB->( !Eof() )
						If TRB->OK == "X"
							aAdd( aExport, { TRB->PROJET, TRB->REVISA, TRB->CODIGO }  ) // Projeto, Revisao, Insumos
	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Inclui os sub-insumos dos insumos que devem ser copiadas ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							PA204IncSub( TRB->PROJET, TRB->REVISA, TRB->CODIGO, @aExport, .F. )
						EndIf
						
						TRB->( DbSkip() )
					End
				EndIf
			
				If oPMSA2042 <> Nil
					oPMSA2042:Delete()
					oPMSA2042 := Nil
				Endif
			EndIf
		EndIf
	Else
		aAdd( aExport, { cProjet, cRevisa, cInsumo }  ) // Projeto, Revisao, Insumo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inclui os sub-insumos dos insumos que devem ser copiadas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PA204IncSub( cProjet, cRevisa, cInsumo, @aExport, .F. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a exportacao                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( aExport )
		For nInc := 1 To Len( aExport )
			cChave := aExport[nInc][1] + aExport[nInc][2] + aExport[nInc][3]

			Begin Transaction
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exclui as composicoes associadas aos projetos.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "AEM" )
			AEM->( DbSetOrder( 1 ) )
			AEM->( DbSeek( xFilial( "AEM" ) + cChave ) )
			While AEM->( !Eof() ) .AND. AEM->( AEM_FILIAL + AEM_PROJET + AEM_REVISA + AEM_INSUMO ) == xFilial( "AEM" ) + cChave
				RecLock( "AEM" )
				AEM->( DbDelete() )
				AEM->( MsUnLock() )

				AEM->( DbSkip() )
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a copia dos insumos                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			// Estrutura do Insumos
			DbSelectArea( "AEK" )
			AEK->( DbSetOrder( 1 ) )
			AEK->( DbSeek( xFilial( "AEK" ) + aExport[nInc][3] ) )
			While AEK->( !Eof() ) .AND. AEK->( AEK_FILIAL + AEK_INSUMO ) == xFilial( "AEK" ) + aExport[nInc][3]
				If !Empty( AEK->AEK_SUBCOD )
					aFields := AEK->( DbStruct() )
					RecLock( "AEM", .T. )
					For nCampo := 1 To Len( aFields )
						cCampo := "AEM_" + AllTrim( substr( aFields[nCampo][1], 5 ) )
						If AEM->( FieldPos( cCampo ) ) > 0
							AEM->( &(cCampo) ) := AEK->( &(aFields[nCampo][1]) )
						EndIf
					Next
			
					AEM->AEM_FILIAL := xFilial( "AEM" )
					AEM->AEM_PROJET := aExport[nInc][1]
					AEM->AEM_REVISA := aExport[nInc][2]
					AEM->AEM_SUBINS := AEK->AEK_SUBCOD
					AEM->( MsUnLock() )
				EndIf

				AEK->( DbSkip() )
			End

			// Insumos
			DbSelectArea( "AJZ" )
			AJZ->( DbSetOrder( 1 ) )
			If AJZ->( DbSeek( xFilial( "AJZ" ) + aExport[nInc][3] ) )
				DbSelectArea( "AJY" )
				AJY->( DbSetOrder( 1 ) )
				AJY->( DbSeek( xFilial( "AJY" ) + cChave ) )
				While AJY->( !Eof() ) .AND. AJY->( AJY_FILIAL + AJY_PROJET + AJY_REVISA + AJY_INSUMO ) == xFilial( "AJY" ) + cChave
					RecLock( "AJY" )
					AJY->( DbDelete() )
					AJY->( MsUnLock() )
	
					AJY->( DbSkip() )
				End

				aFields := AJZ->( DbStruct() )
				RecLock( "AJY", .T. )
				For nCampo := 1 To Len( aFields )
					cCampo := "AJY_" + AllTrim( substr( aFields[nCampo][1], 5 ) )
					If AJY->( FieldPos( cCampo ) ) > 0
						AJY->( &(cCampo) ) := AJZ->( &(aFields[nCampo][1]) )
					EndIf
				Next
		
				If AJZ->AJZ_GRORGA=='A' .And. AJZ->AJZ_TPPARC $ '1;2'
					AJY->AJY_CUSTD  :=	IIf(AF8->AF8_DEPREC $ "13", AJZ->AJZ_DEPREC, 0) +;
										IIf(AF8->AF8_JUROS  $ "13", AJZ->AJZ_VLJURO, 0) +;
										IIf(AF8->AF8_MDO    $ "13", AJZ->AJZ_MDO   , 0) +;
										IIf(AF8->AF8_MATERI $ "13", AJZ->AJZ_MATERI, 0) +;
										IIf(AF8->AF8_MANUT  $ "13", AJZ->AJZ_MANUT , 0)
					AJY->AJY_CUSTIM :=	IIf(AF8->AF8_DEPREC $ "23", AJZ->AJZ_DEPREC, 0) +;
										IIf(AF8->AF8_JUROS  $ "23", AJZ->AJZ_VLJURO, 0) +;
										IIf(AF8->AF8_MDO    $ "23", AJZ->AJZ_MDO   , 0)
				EndIf
		
				AJY->AJY_FILIAL := xFilial( "AJY" )
				AJY->AJY_PROJET := aExport[nInc][1]
				AJY->AJY_REVISA := aExport[nInc][2]
				AJY->( MsUnLock() )
			EndIf

			End Transaction
		Next

		If Empty( cInsumo )
			PA204AtuBrw( cProjet, cRevisa )
			oGetD:aCols := aCols
			oGetD:oBrowse:Refresh()
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PA204Exp   ºAutor³ Totvs                     º Data ³ 16/04/2009    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Exportacao de insimos do projeto para o cadastro                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PA204Exp(cAlias,nReg,nOpcx)                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ ExpC1 - Apelido do arquivo                                          º±±
±±º          ³ ExpN2 - Número do registro a ser copiado                            º±±
±±º          ³ ExpN3 - Opção do arotina                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA204Exp( cProjet, cRevisa )
	Local aSize		:= {}
	Local aInfo		:= {}
	Local aPosObj	:= {}
	Local aObjects	:= {}
	Local aTrab		:= {}
	Local aInsumo	:= {}				// Array com os insumos selecionados
	Local aCodPrj	:= {}				// Array com os projetos selecionados
	Local aCriticas	:= {}				// Array com os insumos ja existentes
	Local aExport  	:= {}				// Array com os insumos a serem exportados
	Local aFields	:= {}				// Array com a estrutura da tabela para realizar a copia dinamicamente
	Local cMarca	:= "X"				// Caractere de marca
	Local cTrab		:= ""				// Arquivo de trabalho
	Local cIndTemp1 := ""				// Indice para trabalho
	Local cChave	:= ""				// Chave de pesquisa para exportar os insumos
	Local cCampo	:= ""
	Local lExport	:= .F.				// Determina se a exportacao podera ser realizada
	Local lInverte	:= .F.				// Determina se os itens devem apresentar selecionados
	Local lOk		:= .F.
	Local nInc		:= 0
	Local nIncPrj	:= 0
	Local nIncIns	:= 0
	Local nCampo	:= 0
	Local nExport	:= 0
	Local nLin		:= oGetD:nAt
	Local nPos
	Local oDlg
	Local oPMSA2043	:= Nil
	Local oPMSA2044	:= Nil

	Local oPanel
	Local oGet
	Local cProcura
	Local oButton

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apresenta os insumos disponiveis para exportacao           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aObjects, { 100, 100, .T., .T., .F. } ) 

	aSize	:= MsAdvSize()
	aInfo	:= { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPosObj	:= MsObjSize( aInfo, aObjects, .T. )

	aTrab		:= {	{ "OK"    , "C", 1, 							0 },;
						{ "PROJET", "C", TamSX3( "AJY_PROJET"	)[1],	0 },;
						{ "REVISA", "C", TamSX3( "AJY_REVISA"	)[1],	0 },;
						{ "CODIGO", "C", TamSX3( "AJY_INSUMO"	)[1],	0 },;
						{ "DESCR" , "C", TamSX3( "AJY_DESC" 	)[1], 	0 }}
				
	oPMSA2043 := FWTemporaryTable():New( "TRB" )  
	oPMSA2043:SetFields(aTrab) 
	oPMSA2043:AddIndex("1", {"CODIGO"})

	//------------------
	//Criação da tabela temporaria
	//------------------
	oPMSA2043:Create()

	Processa( { || MontaTRB1( cProjet, cRevisa ) }, STR0015 ) // "Selecionando insumos para exportacao... Aguarde!"

	DbSelectArea( "TRB" )
	TRB->( DbGoTop() )
	DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6]-100,aSize[5]-100 OF oMainWnd PIXEL

	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,315,25,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP // Somente Interface MDI		                           
	@ 003 , 005 SAY STR0029 FONT oDlg:oFont PIXEL Of oPanel // "Selecione os insumos para exportação"

	cProcura := space(TamSX3( "AJY_INSUMO")[1])
	@ 010,010 MSGET oGet VAR cProcura	SIZE 045,010 OF oPanel PIXEL
	oButton := TButton():New(010,060,"Procura",oPanel,{|| TRB->(dbSeek(cProcura)) },40,10,NIL,NIL,.F.,.T.,.T.,NIL,.F.,NIL,NIL,.F.)

	aCpos := {	{ "OK"    , "", "", ""}, ;
				{ "PROJET", "", A093RetDescr( "AJY_PROJET"	), "" },;
				{ "REVISA", "", A093RetDescr( "AJY_REVISA"	), "" },;
				{ "CODIGO", "", A093RetDescr( "AJY_INSUMO"	), "" },;
				{ "DESCR" , "", A093RetDescr( "AJY_DESC"	), "" } }

	oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca, {50,oDlg:nLeft,oDlg:nBottom,oDlg:nRight} )
	oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:lCanAllMark	:= .T.
	oMark:oBrowse:bAllMark		:= { || PMA204Inv( cMarca, .T., oMark ) }

	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End() }, { || oDlg:End() } ) ) CENTERED
	
	If lOk
		TRB->( DbGoTop() )
		While TRB->( !Eof() )
			If TRB->OK == "X"
				aAdd( aInsumo, { TRB->CODIGO, TRB->DESCR, TRB->PROJET, TRB->REVISA } ) // Insumo, Descricao, Projeto, Revisa
			EndIf
			
			TRB->( DbSkip() )
		End
	EndIf
	
	If oPMSA2043 <> Nil
		oPMSA2043:Delete()
		oPMSA2043 := Nil
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consiste se o insumo selecionado ja existe no cadastro     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( aInsumo )
		For nIncIns := 1 To Len( aInsumo )
			DbSelectArea( "AJZ" )
			AJZ->( DbSetOrder( 1 ) )
			If AJZ->( DbSeek( xFilial( "AJZ" ) + aInsumo[ nIncIns ][1] ) )
				aAdd( aCriticas, { aInsumo[ nIncIns ][1], aInsumo[ nIncIns ][2], aInsumo[ nIncIns ][3], aInsumo[ nIncIns ][4] }  ) // Insumo, Descricao, Projeto, Revisa
			Else
				aAdd( aExport, { aInsumo[ nIncIns ][1], aInsumo[ nIncIns ][2], aInsumo[ nIncIns ][3], aInsumo[ nIncIns ][4] }  ) // Insumo, Descricao, Projeto, Revisa

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inclui os sub-insumos dos insumos que devem ser copiadas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PA204IncSub( aInsumo[ nIncIns ][3], aInsumo[ nIncIns ][4], aInsumo[ nIncIns ][1], @aExport,, aInsumo[ nIncIns ][2] )
			EndIf
		Next

		If !Empty( aCriticas )
			Alert( STR0016 + chr(13) + chr(10) + STR0017 )
	
			aTrab		:= {	{ "OK"    ,	"C", 1, 							0 },;
								{ "PROJET",	"C", TamSX3( "AJY_PROJET"	)[1],	0 },;
								{ "REVISA",	"C", TamSX3( "AJY_REVISA"	)[1],	0 },;
								{ "CODIGO",	"C", TamSX3( "AJY_INSUMO"	)[1],	0 },;
								{ "DESCR",		"C", TamSX3( "AJY_DESC"		)[1],	0 } }
				
			oPMSA2044 := FWTemporaryTable():New( "TRB" )  
			oPMSA2044:SetFields(aTrab) 
			oPMSA2044:AddIndex("1", {"CODIGO","PROJET","REVISA"})
		
			//------------------
			//Criação da tabela temporaria
			//------------------
			oPMSA2044:Create()
			
			For nInc := 1 To Len( aCriticas )
				RecLock( "TRB", .T. ) 
				TRB->CODIGO	:= aCriticas[nInc][1]
				TRB->DESCR		:= aCriticas[nInc][2]
				TRB->PROJET	:= aCriticas[nInc][3]
				TRB->REVISA	:= aCriticas[nInc][4]
				MsUnLock()
			Next

			DbSelectArea( "TRB" )
			TRB->( DbGoTop() )

			DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6]-100,aSize[5]-100 OF oMainWnd PIXEL
		
			oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,315,25,.T.,.T. )
			oPanel:Align := CONTROL_ALIGN_TOP // Somente Interface MDI		                           

			cProcura := space(TamSX3( "AJY_INSUMO")[1]+TamSX3("AJY_PROJET")[1]+TamSX3("AJY_REVISA")[1])
			@ 010,010 MSGET oGet VAR cProcura	SIZE 045,010 OF oPanel PIXEL
			oButton := TButton():New(010,060,"Procura",oPanel,{|| TRB->(dbSeek(cProcura)) },40,10,NIL,NIL,.F.,.T.,.T.,NIL,.F.,NIL,NIL,.F.)
		
			aCpos := {	{ "OK"    	, "", "", ""}, ;
						{ "PROJET"	, "", A093RetDescr( "AJY_PROJET"	), "" },;
						{ "REVISA"	, "", A093RetDescr( "AJY_REVISA"	), "" },;
						{ "CODIGO"	, "", A093RetDescr( "AJY_INSUMO"	), "" },;
						{ "DESCR"	, "", A093RetDescr( "AJY_DESC"		), "" } }
		
			oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca, { 16, 1, 173, 315 } )
			oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
			oMark:oBrowse:lCanAllMark	:= .T.
			oMark:oBrowse:bAllMark		:= { || PMA204Inv( cMarca, .T., oMark ) }
		
			ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End(), .F. }, { || oDlg:End() } ) ) CENTERED

			If lOk
				TRB->( DbGoTop() )
				While TRB->( !Eof() )
					If TRB->OK == "X"
						aAdd( aExport, { TRB->CODIGO, TRB->DESCR, TRB->PROJET, TRB->REVISA } ) // Insumo, Descricao, Projeto, Revisao

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Inclui os sub-insumos dos insumos que devem ser copiadas ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PA204IncSub( TRB->PROJET, TRB->REVISA, TRB->CODIGO, @aExport,, TRB->DESCR )
					EndIf
					
					TRB->( DbSkip() )
				End
			EndIf
		
			If oPMSA2044 <> Nil
				oPMSA2044:Delete()
				oPMSA2044 := Nil
			Endif
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a exportacao                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( aExport )
		For nInc := 1 To Len( aExport )
			cChave := aExport[nInc][1]

			Begin Transaction

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exclui os insumos.                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "AEK" )
			AEK->( DbSetOrder( 1 ) )
			AEK->( DbSeek( xFilial( "AEK" ) + cChave ) )
			While AEK->( !Eof() ) .AND. AEK->AEK_FILIAL == xFilial( "AEK" ) .AND. AEK->AEK_INSUMO == cChave
				RecLock( "AEK" )
				AEK->( DbDelete() )
				AEK->( MsUnLock() )

				AEK->( DbSkip() )
			End

			DbSelectArea( "AJZ" )
			AJZ->( DbSetOrder( 1 ) )
			AJZ->( DbSeek( xFilial( "AJZ" ) + cChave ) )
			While AJZ->( !Eof() ) .AND. AJZ->AJZ_FILIAL == xFilial( "AJZ" ) .AND. AJZ->AJZ_INSUMO == cChave
				RecLock( "AJZ" )
				AJZ->( DbDelete() )
				AJZ->( MsUnLock() )

				AJZ->( DbSkip() )
			End

			// Insumos
			DbSelectArea( "AJY" )
			AJY->( DbSetOrder( 1 ) )
			If AJY->( DbSeek( xFilial( "AJY" ) + aExport[nInc][3] + aExport[nInc][4] + cChave ) )
				aFields := AJY->( DbStruct() )

				RecLock( "AJZ", .T. )
				For nCampo := 1 To Len( aFields )
					cCampo := "AJZ_" + AllTrim( substr( aFields[nCampo][1], 5 ) )
					If AJZ->( FieldPos( cCampo ) ) > 0
						AJZ->( &(cCampo) ) := AJY->( &(aFields[nCampo][1]) )
					EndIf
				Next
		
				AJZ->AJZ_FILIAL := xFilial( "AJZ" )
				AJZ->( MsUnLock() )
			EndIf
				
			// Estrutura do Insumo
			DbSelectArea( "AEM" )
			AEM->( DbSetOrder( 1 ) )
			AEM->( DbSeek( xFilial( "AEM" ) + aExport[nInc][3] + aExport[nInc][4] + cChave ) )
			While AEM->( !Eof() ) .AND. AEM->( AEM_FILIAL + AEM_PROJET + AEM_REVISA + AEM_INSUMO ) == xFilial( "AEM" ) + aExport[nInc][3] + aExport[nInc][4] + cChave
				aFields := AEM->( DbStruct() )

				RecLock( "AEK", .T. )
				For nCampo := 1 To Len( aFields )
					cCampo := "AEK_" + AllTrim( substr( aFields[nCampo][1], 5 ) )
					If AEK->( FieldPos( cCampo ) ) > 0
						AEK->( &(cCampo) ) := AEM->( &(aFields[nCampo][1]) )
					EndIf
				Next
		
				AEK->AEK_FILIAL := xFilial( "AEK" )
				AEK->AEK_SUBCOD := AEM->AEM_SUBINS
				AEK->( MsUnLock() )

				AEM->( DbSkip() )
			End

			End Transaction
		Next
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³ MontaTRB() ³ Autor ³ Totvs                 ³ Data ³ 05.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Monta arquivo TRB para selecao dos insumos                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaTRB1( cProjet, cRevisa )
	DbSelectArea( "AJY" )
	AJY->( DbSetOrder( 1 ) )
	AJY->( DbGoTop() )
	While AJY->( !Eof() )
		If AJY->AJY_PROJET == cProjet .AND. AJY->AJY_REVISA == cRevisa
			RecLock( "TRB", .T. ) 
			TRB->PROJET	:= AJY->AJY_PROJET
			TRB->REVISA	:= AJY->AJY_REVISA
			TRB->CODIGO	:= AJY->AJY_INSUMO
			TRB->DESCR		:= AJY->AJY_DESC
			MsUnLock()
		EndIf

		AJY->( DbSkip() )
	End
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³ MontaTRB() ³ Autor ³ Totvs                 ³ Data ³ 05.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Monta arquivo TRB para selecao dos insumos                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaTRBImp()
	DbSelectArea( "AJZ" )
	AJZ->( DbSetOrder( 1 ) )
	AJZ->( DbGoTop() )
	While AJZ->( !Eof() )
		RecLock( "TRB", .T. ) 
		TRB->CODIGO	:= AJZ->AJZ_INSUMO
		TRB->DESCR		:= AJZ->AJZ_DESC
		MsUnLock()

		AJZ->( DbSkip() )
	End
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³PA204AtuBrw ³ Autor ³ Totvs                 ³ Data ³ 14.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Atualiza o browser                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PA204AtuBrw( cProjet, cRevisa )
	Local nI		:= 0
	Local nUsado	:= 0

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("AJY")

	While !Eof() .And. SX3->X3_ARQUIVO == "AJY"
		If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .AND. !( SX3->X3_CAMPO $ "AJY_PROJET#AJY_REVISA" )
			nUsado++
			AADD( aHeader, {	Trim(X3Titulo()),;
								SX3->X3_CAMPO,;
								SX3->X3_PICTURE,;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								"",;
								SX3->X3_TIPO,;
								"",;
								"" })
		EndIf
		DbSkip()
	EndDo

	aCols := {}

	dbSelectArea("AJY")
	AJY->(dbSetOrder(1))
	AJY->(dbSeek( xFilial( "AJY" ) + cProjet + cRevisa ) )
	While AJY->( !Eof() ) .AND. AJY->AJY_FILIAL + AJY->AJY_PROJET + AJY->AJY_REVISA == xFilial( "AJY" ) + cProjet + cRevisa
		aADD(aCols,Array(Len(aHeader)+1))
		For nI := 1 To Len(aHeader)
			// Campo não é virtual, isto é, existe o campo fisicamente na tabela
			If ( aHeader[nI][10] != "V")
				aCols[Len(aCols)][aScan(aHeader,{ |x| x[2] == aHeader[nI][2]})] := AJY->&(aHeader[nI][2])
			EndIf
		Next nI
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
		AJY->(dbSkip())
	EndDo  

	// se aCols estiver vazio. Cria a 1a linha vazia
	If Empty(aCols)
		aADD(aCols,Array(Len(aHeader)+1))
		For nI := 1 To Len(aHeader)
			// Campo não é virtual, isto é, existe o campo fisicamente na tabela
			If ( aHeader[nI][10] != "V")
				aCols[1][nI] := CriaVar( aHeader[nI][2] )
			EndIf
		Next nI

		aCols[1][Len(aHeader)+1] := .F.
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³PA204IncSub  ³ Autor ³ Totvs                 ³ Data ³ 18.06.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Inclui no array para exportar as sub-insumos                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PA204IncSub( cProjet, cRevisa, cInsumo, aInsumo, lExporta, cDesc )
	Local aArea	:= {}
	
	Default lExporta := .T.

	If lExporta
		DbSelectArea( "AEM" )
		AEM->( DbSetOrder( 2 ) )
		AEM->( DbSeek( xFilial( "AEM" ) + cProjet + cRevisa + cInsumo ) )
		While AEM->( !Eof() ) .AND. AEM->( AEM_FILIAL + AEM_PROJET + AEM_REVISA + AEM_INSUMO ) == xFilial( "AEM" ) + cProjet + cRevisa + cInsumo
			aArea := AEM->( GetArea() )

			If !Empty( AEM->AEM_SUBINS )
				aAdd( aInsumo, { AEM->AEM_SUBINS, cDesc, cProjet, cRevisa } )
				PA204IncSub( cProjet, cRevisa, AEM->AEM_SUBINS, @aInsumo, lExporta )
			EndIf

			RestArea( aArea )

			AEM->( DbSkip() )
		End
	Else
		DbSelectArea( "AEK" )
		AEK->( DbSetOrder( 1 ) )
		AEK->( DbSeek( xFilial( "AEK" ) + cInsumo ) )
		While AEK->( !Eof() ) .AND. AEK->( AEK_FILIAL + AEK_INSUMO ) == xFilial( "AEK" ) + cInsumo
			aArea := AEK->( GetArea() )
			
			If !Empty( AEK->AEK_SUBCOD )
				aAdd( aInsumo, { cProjet, cRevisa, AEK->AEK_SUBCOD } )
				PA204IncSub( cProjet, cRevisa, AEK->AEK_SUBCOD, @aInsumo, lExporta )
			EndIf

			RestArea( aArea )

			AEK->( DbSkip() )
		End
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³PA204Pesq    ³ Autor ³ Totvs                 ³ Data ³ 01.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Efetua a pesquisa no aCols do MsGetDados e posiciona          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PA204Pesq( nRadio, cPesq )
	Local aAuxCols	:= aClone( aCols )
	Local nSearch	:= 0
	
	If Len( aAuxCols ) > 0
		// Ordena o aCols conforme a opcao do usuario (Radio)
		aAuxCols := aSort( aAuxCols,,, { |x,y| x[nRadio] < y[nRadio]  } )

		// Localiza o item desejado (Edit)
		nSearch := aScan( aAuxCols, { |x| AllTrim( cPesq ) $ AllTrim( x[nRadio] ) } )
		If nSearch > 0
			oGetD:nAt					:= nSearch
			oGetD:oBrowse:nAt			:= nSearch
			oGetD:aCols					:= aClone( aAuxCols )

			oGetD:lChgField				:= .F.
			oGetD:oBrowse:lHitBottom	:= .F.
			
			oGetD:oBrowse:Refresh()
			oGetD:oBrowse:SetFocus()
		EndIf
	EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA204Vld  ºAutor  ³ Totvs              º Data ³  16/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o campo podera ser editado                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA204Vld( cField )
	Local cGrpOrg	:= M->AJY_GRORGA
	Local cTpParc	:= M->AJY_TPPARC
	Local lRecurs	:= !Empty( M->AJY_RECURS )
	Local lRet		:= .F.

	If lRecurs
		//lRet := cGrpOrg $ "A*B" .OR. cTpParc $ "1*2"
		If cGrpOrg == "A" .AND. cTpParc == "3" .AND. cField $ "AJY_CUSTD|AJY_CUSTIM|AJY_MCUSTD|AJY_GRORGA"
			lRet := .T.
		ElseIf cGrpOrg == "A" .AND. cTpParc == "1" .And. !(cField $ "AJY_CUSTD|AJY_CUSTIM")
			lRet := .T.
		EndIf
		
		If cGrpOrg == "B" .AND. cField $ "AJY_CUSTD|AJY_GRORGA"
			lRet := .T.
		EndIf
		
		If cGrpOrg == "A" .And. cTpParc == "2" .And. !(cField $ "AJY_CUSTD|AJY_CUSTIM")
			lRet := .T.
		EndIf		
	Else
		lRet := cField == "AJY_CUSTD"
	EndIf

Return lRet      

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ PMA204Inv  ³ Autor ³ Totvs                 ³ Data ³ 24/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca / Desmarca titulos					  	         		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PMA204Inv( cMarca, lTodos, oMark )
Local nReg := TRB->(Recno())

DEFAULT lTodos  := .T.

DbSelectArea( "TRB" )
If lTodos
	DbGoTop()
EndIf

While !lTodos .Or. !Eof()
	If TRB->OK == cMarca
		RecLock("TRB")
		Replace OK With Space(02)
		TRB->(MsUnlock())
	Else
		RecLock("TRB")
		Replace OK With cMarca
		TRB->(MsUnlock())
	EndIf

	If lTodos
		TRB->(dbSkip())
	Else
		Exit
	Endif
End

DbGoTo( nReg )

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMS016Col ºAutor  ³Pedro Pereira Lima  º Data ³  14/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Preenche os valores de custo total do insumo do insumo no   º±±
±±º          ³aCols da tela de cadastro de insumo.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA016 - Cadastro de Insumos                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS204Col()
Local nQuant   := M->AEM_QUANT//oGetDados:aCols[n][aScan(oGetDados:aHeader,{ |x| x[2] == "AEK_QUANT"})]
Local nValUn   := oGetDados:aCols[n][aScan(oGetDados:aHeader,{ |x| x[2] == "AEM_UNITAR"})]
Local lAtualiza:= Iif(oGetDados:aCols[n][aScan(oGetDados:aHeader,{ |x| x[2] == "AEM_CSTITE"})] <> 0,.T.,.F.)
Local nValRet  := nQuant * nValUn 
Local nPConsum := 0
Local nPCusto  := 0
Local nPDMT    := 0
Local nPValor  := 0
                 
nParcela:= aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "AEM_TPPARC"})
nCstItem:= aScan(aHeader,{|x| AllTrim(x[2]) == "AEM_CSTITE"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula o valor do transporte.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oGetDados:aCols[n][nParcela] == "M"
	If lAtualiza
		M->AJY_MATERI -= oGetDados:aCols[n][nCstItem]	
		M->AJY_MATERI += nValRet
	Else
		M->AJY_MATERI += nValRet
	EndIf
ElseIf oGetDados:aCols[n][nParcela] == "N"
	If lAtualiza
		M->AJY_MANUT -= oGetDados:aCols[n][nCstItem]
		M->AJY_MANUT += nValRet			
	Else 
		M->AJY_MANUT += nValRet	
	EndIf
ElseIf oGetDados:aCols[n][nParcela] == "H"
	If lAtualiza
		M->AJY_MDO -= oGetDados:aCols[n][nCstItem]
		M->AJY_MDO += nValRet		
	Else 
		M->AJY_MDO += nValRet	
	EndIf
EndIf

oEnch2:Refresh()

M->AJY_CUSTD	:= ExecTemplate( 'CCTTrigg',.F.,.F.,{ '', 'AJY_MDO', 'AJY_CUSTD' } )
M->AJY_CUSTIM	:= ExecTemplate( 'CCTTrigg',.F.,.F.,{ '', 'AJY_MDO', 'AJY_CUSTIM' } )

Return .T. //nValRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMS016Del ºAutor  ³Pedro Pereira Lima  º Data ³  06/15/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica as linhas deletadas do aCols e atualiza os campos  º±±
±±º          ³correspondentes aos tipos de parcela na oEnch2.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PMSA016 - PMA016Inc()                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS204Del()
Local cTipoPcl := ""
Local cSinal := Iif(oGetDados:aCols[n][Len(oGetDados:aHeader)+1],"-","+")
cTipoPcl := oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEM_TPPARC"})]

Do case
	case cTipoPcl == "M"   
		If cSinal == "+"
			M->AJY_MATERI -= oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEM_CSTITE"})]
		Else
			M->AJY_MATERI += oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEM_CSTITE"})]
		EndIf		
	case cTipoPcl == "N"
		If cSinal == "+"
			M->AJY_MANUT -= oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEM_CSTITE"})]
		Else
			M->AJY_MANUT += oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEM_CSTITE"})]					
		EndIf
	case cTipoPcl == "H"		         
		If cSinal == "+"
			M->AJY_MDO -= oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEM_CSTITE"})]
		Else
			M->AJY_MDO += oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEM_CSTITE"})]
		EndIf					
EndCase           

ExecTemplate( 'CCTTrigg',.F.,.F.,{ '', 'AJY_MDO', 'AJY_CUSTD' } )
ExecTemplate( 'CCTTrigg',.F.,.F.,{ '', 'AJY_MDO', 'AJY_CUSTIM' } )

oEnch2:Refresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a205GD1LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Linhas da GetDados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LinOk da GetDados 1.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a204GD1LinOk()

Local nPosTipo		:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEM_TPPARC" } )
Local nPosSubCod	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEM_SUBINS" } )
Local nPosQT		:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEM_QUANT"  } )
Local nContItem 	:= 1
Local lRet 			:= .T.

If !aCols[n][Len(aHeader)+1]
	If Empty(aCols[n][nPosTipo])
		Aviso( STR0028, STR0022, { "Ok" } ) // "É necessário selecionar uma parcela!"
		lRet := .F.
	EndIf

	If Empty(aCols[n][nPosSubCod])
		Aviso( STR0028, STR0023, { "Ok" } ) // "É necessário informar um insumo!"
		lRet := .F.
	EndIf

	If lRet .AND. ( Empty(aCols[n][nPosQT]) .OR. aCols[n][nPosQT] == 0 )
		Aviso( STR0028, STR0024, { "Ok" } ) // "É necessário informar uma quantidade!"
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³verifica duplicidade de insumos na composicao Aux.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .AND. Len( aCols ) > 0 .AND. nPosSubCod > 0 .AND. !Empty( aCols[ n ][ nPosSubCod ] )
		For nContItem := 1 To Len( aCols )
			If !aCols[nContItem][Len(aHeader)+1]
				If n <> nContItem .AND. aCols[ n ][ nPosTipo ] + aCols[ n ][ nPosSubCod ] == aCols[ nContItem ][ nPosTipo ] + aCols[ nContItem ][ nPosSubCod ]
					Aviso( STR0028, STR0021, { "Ok" } ) // "Não é permitido duplicidade de insumos no browse!"
					lRet := .F.
            		
					Exit
				EndIf
			EndIf
		Next
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³pma204Recalc³ Autor ³ Totvs               ³ Data ³ 23-07-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Recalcula os campos com base no custos atuais dos insumos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LinOk da GetDados 1.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function pma204Recalc( nMDO, nMateri, nManut )

	// Se for um recurso do grupo A ou B e tipo de parcela 3, obtem o custo standard do recurso.
	If !Empty( M->AJY_RECURS ) .AND. M->AJY_GRORGA $ "A" .AND. M->AJY_TPPARC == "3"
		DbSelectArea( "AE8" )
		AE8->( DbSetOrder( 1 ) )
		If !ALTERA .AND. AE8->( DbSeek( xFilial( "AE8" ) + M->AJY_RECURS ) )
			M->AJY_CUSTD	:= AE8->AE8_VALOR
			M->AJY_CUSTIM	:= AE8->AE8_CUSTIM
		EndIf
	Else
		M->AJY_MDO		:= nMDO + ExecTemplate('CCTTrigg',.F.,.F.,{'','AJY_HORANO','AJY_MDO'})
		M->AJY_MATERI	:= ExecTemplate('CCTTrigg',.F.,.F.,{'','AJY_HORANO','AJY_MATERI'})
		M->AJY_MANUT 	:= ExecTemplate('CCTTrigg',.F.,.F.,{'M','AJY_HORANO','AJY_MANUT'})

		ExecTemplate( 'CCTTrigg',.F.,.F.,{ '', 'AJY_MDO', 'AJY_CUSTD' } )
		ExecTemplate( 'CCTTrigg',.F.,.F.,{ '', 'AJY_MDO', 'AJY_CUSTIM' } )
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³Pma204CpyComp³ Autor ³ Totvs                 ³ Data ³ 04.08.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Realiza a copia de um insumo para o projeto.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Pma204CpyComp( cProjet, cRevisa, cInsumo )
	Local lRet	:= .F.
	
	DbSelectArea( "AJY" )
	AJY->( DbSetOrder( 1 ) )
	If !AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa + cInsumo ) )
		Pa204Imp( cProjet, cRevisa, cInsumo )
	EndIf

	lRet := ExistCpo( 'AJY', cProjet + cRevisa )
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³PA204UsaInsumo³ Autor ³ Totvs                 ³ Data ³ 12/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Verifica se determinado insumo esta sendo usado.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PA204UsaInsumo( cProjet, cRevisa, cInsumo, lExibeMsg )
	Local 	lReturn 	:= .F.
	Local 	cMsg		:=  ""
	Local	aArea		:= GetArea()
	Local	aAreaAJU	:= AJU->(GetArea())
	Local	aAreaAEL	:= AEL->(GetArea())
	Local	aAreaAEM	:= AEM->(GetArea())

	Default lExibeMsg	:= .T.

	// 1. Verificar se o insumo esta sendo usado na composicao auxiliar
	DbSelectArea( "AJU" )
	AJU->( DbSetOrder( 2 ) )
	AJU->( DbSeek( xFilial( "AJU" ) + cProjet + cRevisa ) )
	While AJU->( !Eof() ) .AND. AJU->( AJU_FILIAL + AJU_PROJET + AJU_REVISA ) == xFilial( "AJU" ) + cProjet + cRevisa
		If AJU->AJU_INSUMO == cInsumo
			lReturn 	:= .T.
			cMsg		:= STR0012 //"O insumo nao pode ser excluido pois esta sendo usado em uma composição auxiliar."

			Exit
		EndIf

		AJU->( DbSkip() )
	End

	// 2. Verificar se o insumo esta sendo usado no projeto
	If !lReturn
		DbSelectArea( "AEL" )
		AEL->( DbSetOrder( 2 ) )
		lReturn	:= AEL->( DbSeek( xFilial( "AEL" ) + cProjet + cRevisa + cInsumo ) )
		If lReturn
			cMsg	:= STR0019 //"O insumo nao pode ser excluido pois esta sendo usado no projeto."
		EndIf
	EndIf

	// 3. Verificar se o insumo eh sub-insumo de outro
	If !lReturn
		DbSelectArea( "AEM" )
		AEM->( DbSetOrder( 3 ) )
		If AEM->( DbSeek( xFilial( "AEM" ) + cProjet + cRevisa + cInsumo ) )
			lReturn 	:= .T.
			cMsg		:= STR0020 + AEM->AEM_INSUMO //"O insumo nao pode ser excluido pois faz parte da estrutura do insumo " + AEM->AEM_INSUMO
		EndIf
	EndIf

	//ConOut( cMsg )
	If lExibeMsg .AND. lReturn
		Alert( cMsg )
	EndIf

RestArea(aAreaAJU)
RestArea(aAreaAEL)
RestArea(aAreaAEM)
RestArea(aArea)

Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA204Gatilhoº Autor ³ Totvs               º Data ³ 13/08/2009º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para gatilhar os campos do cadastro de insumo com os º±±
±±º          ³ campos identicos ao cadastro de produtos/recursos.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template CCT                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PA204Gatilho( lCarrega )
	Local aStruct	:= {}	
	Local cCodigo	:= ""
	Local cCampo	:= ""
	Local lReturn 	:= .T.
	Local nInc		:= 0
	Local lMsg		:= .T.
	
	Default lCarrega	:= .F.

	If Empty( M->AJY_PRODUT ) .AND. Empty( M->AJY_RECURS )
		Return lReturn
	EndIf

	If INCLUI .And. !lCarrega
		lMsg	:= MsgYesNo( STR0026 )
	EndIf

	If lMsg
		If !Empty( M->AJY_PRODUT )
			cCodigo := M->AJY_PRODUT
			aStruct	:= SB1->( DbStruct() )	

			If INCLUI .And. !lCarrega
				DbSelectArea( "SB1" )
				SB1->( DbSetOrder( 1 ) )
				If SB1->( DbSeek( xFilial( "SB1" ) + cCodigo ) )
					For nInc := 1 To Len( aStruct )
						cCampo := substr( aStruct[nInc][1], 4, 6 )
						If AJY->( FieldPos( "AJY_" + cCampo ) ) > 0
							M->&( "AJY_" + cCampo ) := SB1->&(aStruct[nInc][1])
						EndIf
					Next
				EndIf
			EndIf
		ElseIf !Empty( M->AJY_RECURS )
			cCodigo := M->AJY_RECURS
			aStruct	:= AE8->( DbStruct() )	

			If INCLUI .And. !lCarrega .AND. ( M->AJY_TPPARC == "3" .OR. Empty( M->AJY_TPPARC ) )
				DbSelectArea( "AE8" )
				AE8->( DbSetOrder( 1 ) )
				If AE8->( DbSeek( xFilial( "AE8" ) + cCodigo ) )
					For nInc := 1 To Len( aStruct )
						cCampo := substr( aStruct[nInc][1], 4, 6 )
						If AJY->( FieldPos( "AJY_" + cCampo ) ) > 0
							M->&( "AJY_" + cCampo ) := AE8->&(aStruct[nInc][1])
						EndIf
					Next
	
					M->AJY_DESC := AE8->AE8_DESCRI
				EndIf
			EndIf
		EndIf
		If M->AJY_GRORGA <> 'A'
			M->AJY_TPPARC := ''
		EndIf
	EndIf
Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA204VldCod º Autor ³ Totvs               º Data ³ 31/08/2009º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para validar o codigo do sub-insumo.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template CCT                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PA204VldCod()
	Local aAreaAJY	:= AJY->( GetArea() )
	Local aAreaAEM	:= AEM->( GetArea() )
	Local cCodAEK	:= M->( AJY_PROJET + AJY_REVISA + AEM_SUBINS )
	Local lRet		:= M->AEM_SUBINS <> M->AJY_INSUMO
	
	DbSelectArea( "AEM" )
	AEM->( DbSetOrder( 1 ) )
	If AEM->( DbSeek( xFilial( "AEM" ) + cCodAEK ) )
		lRet := .F.
		MsgAlert( STR0027 )	// "Este insumo contém sub-insumos e não poderá ser incluido na estrutura!"
	EndIf
	
	RestArea( aAreaAJY )
	RestArea( aAreaAEM )
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A204GD1TudOk³ Autor ³ Totvs               ³ Data ³ 31-08-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TudOk da GetDados 1.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A204GD1TudOk()
	Local lRet		:= .T.
	Local nx 		:= 0
	Local nPosSubCod:= 0
	
	Private aHeader	:= oGetDados:aHeader
	Private aCols	:= oGetDados:aCols

	nPosSubCod	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEM_SUBINS" } )
	If nPosSubCod > 0
		For nx := 1 To Len( aCols )
			n := nx

			If !Empty( aCols[nx][nPosSubCod] )
				If !A204GD1LinOk()
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS204Ok³ Autor ³ Totvs                   ³ Data ³ 31/08/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao TudoOk do cadastro de Insumos.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS204Ok(nOpc)
Local lRet		:= .T.
Local aArea 	:= GetArea()
Local aAreaAEM	:= AEM->(GetArea())
Local aAreaAJY	:= AJY->(GetArea())
Local nX

If nOpc <> 5
	For nX := 1 to len(aCpo1Ench)
		If X3Obrigat(aCpo1Ench[nX]) .And. Empty(M->&(aCpo1Ench[nX]))
			lRet:=.F.
		EndIf
	Next nX
	
	For nX := 1 to len(aCpo2Ench)
		If X3Obrigat(aCpo2Ench[nX]) .And. Empty(M->&(aCpo2Ench[nX]))
			lRet:=.F.
		EndIf
	Next nX

	If !lRet
		MsgAlert(STR0031)
	EndIf
EndIf

If lRet
	lRet := A204GD1TudOk()
EndIf

RestArea(aAreaAJY)
RestArea(aAreaAEM)
RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PA204AtuPai  ³ Autor ³ Marcelo Akama     ³ Data ³ 01/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza indices e custos dos insumos pais                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PA204AtuPai( cProjet, cRevisa, cCodIns )
	Local aArea		:= GetArea()
	Local aAreaAEM	:= AEM->( GetArea() )
	Local aAreaAJY	:= AJY->( GetArea() )
	Local aAreaAux
	Local aAreaAux2
	Local lMDO
	Local lMateri
	Local lManut
	Local nMDO
	Local nMateri
	Local nManut
	Local nCusto
	Local cInsumo
	
	DbSelectArea( "AJY" )
	AJY->( DbSetOrder( 1 ) )
	DbSelectArea( "AEM" )
	AEM->( DbSetOrder( 3 ) )
	AEM->( DbSeek( xFilial( "AEM" ) + cProjet + cRevisa + cCodIns ) )
	Do While !AEM->(Eof()) .And. AEM->(AEM_FILIAL+AEM_PROJET+AEM_REVISA+AEM_SUBINS)==xFilial( "AEM" ) + cProjet + cRevisa + cCodIns
		If AJY->( DbSeek(xFilial( "AJY" ) + cProjet + cRevisa + AEM->AEM_INSUMO) )
			aAreaAux := AEM->( GetArea() )
			aAreaAux2:= AJY->( GetArea() )
			lMDO     := .F.
			lMateri  := .F.
			lManut   := .F.
			nMDO     := 0
			nMateri  := AJY->AJY_POTENC*AJY->AJY_VALCOM*AJY->AJY_COMBUS
			nManut   := ((AJY->AJY_AQUISI - AJY->AJY_RESIDU) * AJY->AJY_COEFMA) / (AJY->AJY_VIDAUT * AJY->AJY_HORANO)
			cInsumo  := AJY->AJY_INSUMO
			AEM->( DbSetOrder( 1 ) )
			AEM->( DbSeek( xFilial( "AEM" ) + cProjet + cRevisa + cInsumo ) )
			Do While !AEM->(Eof()) .And. AEM->(AEM_FILIAL+AEM_PROJET+AEM_REVISA+AEM_INSUMO)==xFilial( "AEM" ) + cProjet + cRevisa + cInsumo
				If AJY->( DbSeek(xFilial( "AJY" ) + cProjet + cRevisa + AEM->AEM_SUBINS) )
					nCusto := AJY->AJY_CUSTD * AEM->AEM_QUANT
					Do Case
						Case AEM->AEM_TPPARC='H'
							nMDO    += nCusto
							lMDO    := .T.
						Case AEM->AEM_TPPARC='M'
							nMateri += nCusto
							lMateri := .T.
						Case AEM->AEM_TPPARC='N'
							nManut  += nCusto
							lManut  := .T.
					EndCase
					RecLock("AEM", .F.)
					AEM->AEM_UNITAR := AJY->AJY_CUSTD
					AEM->AEM_CSTITE := nCusto
					MsUnlock()
				EndIf
				AEM->(dbSkip())
			EndDo
			RestArea( aAreaAux2 )

			RecLock("AJY", .F.)
			If lMDO
				AJY->AJY_MDO    := nMDO
			EndIf
			If lMateri
				AJY->AJY_MATERI := nMateri
			EndIf
			If lManut
				AJY->AJY_MANUT  := nManut
			EndIf
			If AJY->AJY_GRORGA=='A' .And. AJY->AJY_TPPARC $ '1;2'
 				AJY->AJY_CUSTD  :=	IIf(AF8->AF8_DEPREC $ "13", AJY->AJY_DEPREC, 0) +;
									IIf(AF8->AF8_JUROS  $ "13", AJY->AJY_VLJURO, 0) +;
									IIf(AF8->AF8_MDO    $ "13", AJY->AJY_MDO   , 0) +;
									IIf(AF8->AF8_MATERI $ "13", AJY->AJY_MATERI, 0) +;
									IIf(AF8->AF8_MANUT  $ "13", AJY->AJY_MANUT , 0)
				AJY->AJY_CUSTIM :=	IIf(AF8->AF8_DEPREC $ "23", AJY->AJY_DEPREC, 0) +;
									IIf(AF8->AF8_JUROS  $ "23", AJY->AJY_VLJURO, 0) +;
									IIf(AF8->AF8_MDO    $ "23", AJY->AJY_MDO   , 0)
			EndIf
			MsUnlock()
			
			RestArea( aAreaAux )
		EndIf
		AEM->(dbSkip())
	EndDo
	
	RestArea( aAreaAJY )
	RestArea( aAreaAEM )
	RestArea( aArea )
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A204Cancel³ Autor ³ Marcelo Akama         ³ Data ³ 21/10/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui subinsumos incluidos.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA204.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A204Cancel()

Local aAreaAJY	:= AJY->( GetArea() )
Local cProjet   := AF8->AF8_PROJET
Local cRevisa   := AF8->AF8_REVISA

Begin Transaction

	DbSelectArea( "AJY" )
	AJY->( DbSetOrder( 1 ) )
	AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa ) )
	Do While AJY->( AJY_FILIAL+AJY_PROJET+AJY_REVISA ) == xFilial( "AJY" ) + cProjet + cRevisa

		If !PA204UsaInsumo( cProjet, cRevisa, AJY->AJY_INSUMO, .F. )
			PA204Exc( cProjet, cRevisa, AJY->AJY_INSUMO, .T. )
			AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa ) )
		EndIf

		AJY->(dbSkip())
	EndDo
		
End Transaction

RestArea( aAreaAJY )

Return
