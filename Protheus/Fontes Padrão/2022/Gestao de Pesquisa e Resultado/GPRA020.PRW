#INCLUDE "GPRDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "GPRA020.CH"
#INCLUDE "SHELL.CH"

#DEFINE NOVALINHA 		CHR(13)+CHR(10)
#DEFINE MAXGETDAD 4096

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁGPRA020    ЁAutora Ё Henry Fila           Ё Data Ё 20/10/03 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Cadastro de Questionarios                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё SIGAGPR                                                    Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁAnalista  Ё Data/Bops/Ver ЁManutencao Efetuada                         Ё╠╠
╠╠цддддддддддеддддддддбддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁMarcelo K.Ё09/08/04Ё710   ЁRevisao do fonte:Sintaxe,Documentacao,LogicaЁ╠╠
╠╠Ё          Ё        Ё      Ё                                            Ё╠╠
╠╠Ё          Ё        Ё      Ё                                            Ё╠╠
╠╠юддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function GPRA020(aRotAuto,nOpc)

Private cCadastro := STR0001    	// Cadastro de questionarios

Private aRotina   := MenuDef()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Definicao de variaveis para rotina de inclusao automatica    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private l020Auto := ( aRotAuto <> NIL )

nOpc := IIF(nOpc == NIL, 3, nOpc)

//зддддддддддддддддддддддддд©
//ЁSe for entrada automaticaЁ
//юддддддддддддддддддддддддды
DbSelectArea("SKP")
DbSetOrder(1)
If l020Auto
	MsRotAuto(nOpc,aRotAuto,"SKP")
Else
	mBrowse(6,1,22,75,"SKP")
Endif

Return( .T. )

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFunГЦo    Ё MenuDef  Ё Autor Ё Conrado Q. Gomes      Ё Data Ё 12.12.06 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё DefiniГЦo do aRotina (Menu funcional)                      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё MenuDef()                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё SIGAGPR                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0002,"AXPESQUI"		,0	,1	,0	,.F.	}	,; //Pesquisar
						{STR0003,"Gpr020Man"	,0	,2	,0	,.T.	}	,; //Visualizar
						{STR0004,"Gpr020Man"	,0	,3	,0	,.T.	}	,; //Incluir
						{STR0005,"Gpr020Man"	,0	,4	,0	,.T.	}	,; //Alterar
						{STR0006,"Gpr020Man"	,0	,5	,0	,.T.	}	,;
						{STR0021,"Gpr020Prv"	,0	,4	,0	,.T.	}	,;
						{STR0020,"MsDocument"	,0	,4	,0	,.T.	}	}
Return(aRotina)

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё Gpr020ManЁ Autor Ё Henry Fila            Ё Data Ё 17.02.05 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Manutencao Cadastro de Questionarios                       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Gerenciamento de Pesquisa e resuiltados (GPR)              Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     Ё╠╠
╠╠цддддддддддддддбддддддддддбддддддбдддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё  DATA    Ё BOPS Ё  MOTIVO DA ALTERACAO                 Ё╠╠
╠╠цддддддддддддддеддддддддддеддддддедддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁConrado Q.    |29/01/07  Ё115966|- Montagem do aCols e aHeader atravИs Ё╠╠
╠╠Ё              Ё          Ё      |da rotina FillGetDados.               Ё╠╠
╠╠╨Hanna C.      |30/03/07  |118469ЁAlterado o nome dos Bitmaps definidos Ё╠╠
╠╠╨        	     Ё          |      Ёpela Engenharia para o Protheus 10    Ё╠╠
╠╠юддддддддддддддаддддддддддаддддддадддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function Gpr020Man( cAlias, nReg, nOpc )

Local aPosObj	:= {}			//Dimensionamento da tela
Local aObjects	:= {}			//Dimensionamento da tela
Local aSize		:= MsAdvSize()	//Dimensionamento da tela
Local aRecnoSKR	:= {}
Local aHeaderSKR:= {}			// aHeader
Local aColsSKR	:= {}			// aCols

Local aButtons	:= { {"BMPINCLUIR"  , { || Gpr020Tree(oGetdSKR:aHeader,oGetDSKR:aCols) } , "Estrutura" }	 } 

Local nSaveSx8	:= GetSx8Len()
Local nOpca		:= 0
Local nX		:= 0

Local lProcessa	:= .T.

Local oGetdSKR	:= Nil
Local oDlg		:= Nil

Local cSeek		:= ""			// Seek para montagem do aCols
Local cWhile	:= ""			// While para montagem do aCols

Private aTELA[0][0],aGETS[0]                             

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se e exclusao e consiste a integridade                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

If nOpc == 5
	lProcessa := Gpr020CanDel(SKP->KP_CODQUE)
Endif	

If lProcessa

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa desta forma para criar uma nova instancia de variaveis private Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nOpc == 3
		RegToMemory( "SKP",  .T. )
	Else
		RegToMemory( "SKP",  .F. )
	Endif 
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa campos memo do cabecalho                                       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Type("aMemos")=="A"
		For nX :=1 To Len(aMemos)
			cMemo := aMemos[nX][2]
			If ExistIni(cMemo)
				&cMemo := InitPad(SX3->X3_RELACAO)
			Else
				&cMemo := ""
			EndIf
		Next nX
	EndIf
	
	//зддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta aHeader e aCols das Regras da PesquisaЁ
	//юддддддддддддддддддддддддддддддддддддддддддддды
	aHeader	:= {}
	aCols	:= {}
	
	If !INCLUI
		cSeek := xFilial("SKR")+SKP->KP_CODQUE
		cWhile:= "SKR->KR_FILIAL+SKR->KR_CODQUE"
	
		FillGetDados(	nOpc			,"SKR"			,1											,cSeek				,;
		   				{|| &cWhile }	,{|| .T. }		,/*aNoFields*/								,/*aYesFields*/		,; 
		   				/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/								,/*lEmpty*/			,;
		   				/*aHeaderAux*/	,/*aColsAux*/	,{|| GPR020AfterCols( "SKR", aRecnoSKR ) }	,/*bBeforeCols*/	)
				   				
	Else
		FillGetDados(	nOpc			,"SKR"		,1				,/*cSeek*/		,;
						/*{||&cWhile}*/	,{|| .T. }	,/*aNoFields*/	,/*aYesFields*/	,; 
						/*lOnlyYes*/	,/*cQuery*/	,/*bMontCols*/	,.T.			)
	EndIf
	
	If Empty( aCols[ 1 ][ GdFieldPos("KR_ITEM") ] )
		aCols[ 1 ][ GdFieldPos("KR_ITEM") ]	 := StrZero( 1, Len( SKR->KR_ITEM ) )
	EndIf

	aHeaderSKR	:= aClone( aHeader )
	aColsSKR	:= aClone( aCols )
	
	If Type("l030Auto") == "U" .OR. !l030Auto
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Faz o calculo automatico de dimensoes de objetos     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
		aSize := MsAdvSize()
		AAdd( aObjects, { 100,065,.T.,.T. } )
		AAdd( aObjects, { 100,100,.T.,.T. } )
		aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects,.T. )
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁA variavel INCLUI И alterada para .T. para que nao haja problemas  Ё 
		//Ёcom relacao a inclusao de um novo item do Questionario.            Ё
		//ЁEste problema foi encontrado pois estava tendo uma nao-conformidadeЁ
		//Ёcom relacao ao Posicione no X3_RELACAO do campo KR_CODGRU.         Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nOpc == 4
			INCLUI := .T.
		Endif
		
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Definindo Enchoice                                   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
			EnChoice(cAlias,nReg,nOpc,,,,,aPosObj[1],, , , , , , ,.T.)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Getdados - Alternativas                              Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oGetdSKR := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],IIF(Altera .OR. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE,0),"Gpr020LOk()","AllwaysTrue()","+KR_ITEM",,,MAXGETDAD,,,,,aHeaderSKR,aColsSKR)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ativando a Tela                                      Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA := 1,aColsSKR:=oGetdSKR:aCols,If(oGetdSKR:TudoOk(),If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},{||oDlg:End()},,aButtons )	
	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁE necessario voltar a variavel INCLUI para .T. se for alteracaoЁ
		//Ёpara a utilizacao de outras funcoes                            Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nOpc == 4
			INCLUI := .F.
		Endif

		If ( nOpca == 1 )
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Gravacao da questionario                                                  Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Gpr020Grv(nOpc-2,aRecnoSKR,aHeaderSKR,aColsSKR)
			While (GetSx8Len() > nSaveSx8 )
				ConfirmSx8()
			EndDo
			EvalTrigger()
		Else
			If nOpc <> 2                   
				While (GetSx8Len() > nSaveSx8 )		
					RollBackSx8()	
				Enddo		
			Endif				
		EndIf
	
	Endif
Endif
	
dbSelectArea("SKP")

Return( .T. )

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    ЁGpr020Grv Ё Autor Ё Henry Fila            Ё Data Ё 17/02/2005 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁRotina de Gravacao do Questionario                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁGpr020Grv                                                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁExpN1: Opcao da Gravacao sendo:                               Ё╠╠
╠╠Ё          Ё       [1] Inclusao                                           Ё╠╠
╠╠Ё          Ё       [2] Alteracao                                          Ё╠╠
╠╠Ё          Ё       [3] Exclusao                                           Ё╠╠
╠╠Ё          ЁExpA2: Array de registros dos itens do questionario           Ё╠╠
╠╠Ё          ЁExpA3: aHeader dos itens do questionario                      Ё╠╠
╠╠Ё          ЁExpA4: aCols dos itens dos quetionarios                       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Gestao de pesquisa e resultado                               Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Atualizacoes sofridas desde a Construcao Inicial.                       Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador  Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё              Ё        Ё      Ё                                          Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function Gpr020Grv(nOpcao,aRecnoSKR,aHeaderSKR,aColsSKR)

Local aArea     := GetArea()                     

Local bCampo 	:= {|nCPO| Field(nCPO) }

Local cAliasMemo

Local nX        := 0
Local nCntFor   := 0
Local nY        := 0
Local nUsado    := Len(aHeaderSKR)

Local lTravou   := .F.

If nOpcao <> 3

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁGrava o questionario                                               Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	For nX := 1 To Len(aColsSKR)

		Begin Transaction

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁGrava o cabecalho do questionario                                  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		
		If nX == 1

			dbSelectArea("SKP")
			dbSetOrder(1)
			If DbSeek(xFilial("SKP")+M->KP_CODQUE)
				RecLock("SKP",.F.)
			Else
				RecLock("SKP",.T.)
			EndIf
			For nCntFor := 1 TO FCount()
				FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor)))
			Next nCntFor     
	
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁGrava os campos Memos Virtuais					 				  Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If Type("aMemos") == "A"
				For nCntFor := 1 to Len(aMemos)
					cVar := aMemos[nCntFor][2]
					cAliasMemo := If(len(aMemos[nCntFor]) == 3,aMemos[nCntFor][3],Nil)
					MSMM(,TamSx3(aMemos[nCntFor][2])[1],,&cVar,1,,,"SKP",aMemos[nCntFor][1],cAliasMemo)
				Next nCntFor
			EndIf
	                        
			SKP->KP_FILIAL := xFilial("SKP")
			MsUnLock()
		Endif		

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁGrava os grupos,subgrupos e questoes do questionario               Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		lTravou := .F.
		If nX <= Len( aRecNoSKR )	 	
			dbSelectArea( "SKR" )
			dbGoto( aRecNoSKR[ nX ] )
			RecLock( "SKR" )
			lTravou := .T.
		EndIf
	
		If !aColsSKR[ nX ][ nUsado + 1 ]
			If !lTravou 
				RecLock("SKR",.T.)			
			EndIf
			For nY := 1 to Len( aHeaderSKR )
				If aHeaderSKR[nY][10] <> "V"
					SKR->( FieldPut( FieldPos(aHeaderSKR[nY][2]),aColsSKR[nX][nY] ) )
				EndIf
			Next nY

			SKR->KR_FILIAL := xFilial( "SKR" )
			SKR->KR_CODQUE := SKP->KP_CODQUE
			
			MsUnLock()                   
			
			lGravou := .T.
		Else                                       
			If lTravou        
				RecLock("SKR")                         
					SKR->(dbDelete())
				MsUnlock()			
			Endif	
		EndIf
		MsUnLock()
		
		End Transaction
		
	Next nX
Else

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁExclui os grupos,subgrupos ou questoes do questionario             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SKR")
	dbSetOrder(1)
	If DbSeek(xFilial("SKR")+SKP->KP_CODQUE)
		While !Eof() .And. SKR->KR_FILIAL == xFilial("SKR") .And.;	
							SKR->KR_CODQUE == M->KP_CODQUE
			RecLock("SKR")
			dbDelete()	
			MsUnlock()	

			SKR->(dbSkip())								
		Enddo	
	Endif	

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁExclui o questionario                                              Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SKP")
	dbSetOrder(1)
	If DbSeek(xFilial("SKP")+M->KP_CODQUE)
		RecLock("SKP",.F.)
		dbDelete()    
		MsUnlock()
	Endif

Endif

RestArea( aArea )

Return( .T. )

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    ЁGpr020CanDel Ё Autor Ё Henry Fila         Ё Data Ё 17/02/2005 Ё╠╠
╠╠цддддддддддедддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁRotina de Verificacao de exclusao do questionario             Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁGpr020CanDel                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁExpC1: Codigo do questionario                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Gestao de pesquisa e resultados                              Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Atualizacoes sofridas desde a Construcao Inicial.                       Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador  Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё              Ё        Ё      Ё                                          Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function Gpr020CanDel(cCodQuest)

Local aArea := Getarea()  //Armazena area de trabalho

Local lRet := .T.

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se existem pesquisas para o questionario                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("SKD")
dbSetOrder(2)
If DbSeek(xFilial("SKD")+cCodQuest)
	lRet := .F.
	Help(" ",1,"NODELETA")
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁRestaura area de trabalho                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RestArea(aArea)

Return( lRet )

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    ЁGpr020VlGrp  Ё Autor Ё Henry Fila         Ё Data Ё 17/02/2005 Ё╠╠
╠╠цддддддддддедддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁRotina de validacao do subgrupo no cadastro de questionarios  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁGpr020VlGrp                                                   Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁNenhuma                                                       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Gestao de pesquisa e resultados                              Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Atualizacoes sofridas desde a Construcao Inicial.                       Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador  Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё              Ё        Ё      Ё                                          Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function Gpr020VlGrp()

Local aArea     := GetArea()  //Armazena area de trabalho
Local lRet      := .T.        //Retorno da funcao                       
Local nPosCod   := aScan(aHeader,{|x| AllTrim(x[2])=="KR_CODGRU"})  //Posicao do grupo no aCols de Questionarios

If nPosCod > 0
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se o subgrupo pertence ao grupo                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SKF")
	dbSetOrder(1)
	If !DbSeek(xFilial("SKF")+aCols[n][nPosCod]+M->KR_CODSGR)
		Help(" ",1,"REGNOIS")	
		lRet := .F.
	Endif	
Endif                                                

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura area de trabalho                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RestArea( aArea )
Return( lRet ) // Retorno um valor logico esperado pela funcao

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    ЁGpr020LOk    Ё Autor Ё Henry Fila         Ё Data Ё 17/02/2005 Ё╠╠
╠╠цддддддддддедддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁRotina de validacao da linha do questionario                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁGpr020LOk                                                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁNenhuma                                                       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Gestao de pesquisa e resultados                              Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Atualizacoes sofridas desde a Construcao Inicial.                       Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador  Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё              Ё        Ё      Ё                                          Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function Gpr020LOk()

Local lRet      := .T. //Variavel de retorno da funcao
Local aArea	    := GetArea() //Armazena a area de trabalho
Local aAreaSKG  := SKG->( GetArea() )

Local cGrupo    := ""
Local cSubGrupo := ""
Local cGrupoNX  := ""
Local cSubGrupoNX := ""

Local nX        := 0         //Contador For
Local nUsado    := 0         //Dimensoes do aHeader
Local nPosGru   := aScan( aHeader,{|x| AllTrim(x[2])=="KR_CODGRU"} ) //Posicao do grupo no acols
Local nPosSGru  := aScan( aHeader,{|x| AllTrim(x[2])=="KR_CODSGR"} ) //Posicao do subgrupo no acols
Local nPosQues  := aScan( aHeader,{|x| AllTrim(x[2])=="KR_CODQST"} ) //Posicao da questЦo no acols

nUsado := Len(aHeader)+1

If Empty(aCols[n][nPosGru]) .And. Empty(aCols[n][nPosSGru]) .And. Empty(aCols[n][nPosQues] )
	lRet := .F.
Else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se a questao estiver preenchida busca grupo e subgrupo       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SKG->( dbSetOrder( 1 ) )
	If SKG->( DbSeek( xFilial("SKG") + aCols[ n ][ nPosQues ] ) )
		cGrupo := SKG->KG_CODGRP
		cSubGrupo := SKG->KG_CODSUBG
	Else
		cGrupo	 := aCols[n][nPosGru]
		cSubGrupo := aCols[n][nPosSGru]
	Endif
	For nX := 1 to Len( aCols )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se a linha nao esta deletada                        Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !aCols[nX][nUsado] .And. !aCols[n][nUsado] .And. nX <> n
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Se a questao estiver preenchida busca grupo e subgrupo       Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			SKG->( dbSetOrder( 1 ) )
			If SKG->( DbSeek(xFilial("SKG")+aCols[nX][nPosQues]) )
				cGrupoNX    := SKG->KG_CODGRP
				cSubGrupoNX := SKG->KG_CODSUBG
			Else
				cGrupoNX    := aCols[nX][nPosGru]
				cSubGrupoNX := aCols[nX][nPosSGru]
			Endif	
			Do Case 
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё So o grupo esta preenchido (linha posicionada)               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Case !Empty(aCols[n][nPosGru]) .And.  Empty(aCols[n][nPosSGru]) .And. Empty(aCols[n][nPosQues])
					If (cGrupo == cGrupoNX)
						cMensg := STR0022 // "Alguma questЦo deste grupo jА estА sendo utilizada!"
						lRet := .F.
					EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё O grupo e subgrupo estЦo preenchidos (linha posicionada)     Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Case !Empty(aCols[n][nPosGru]) .And. !Empty(aCols[n][nPosSGru]) .And. Empty(aCols[n][nPosQues])
					If !Empty(aCols[nX][nPosGru]) .And.  Empty(aCols[nX][nPosSGru]) .And. Empty(aCols[nX][nPosQues])
						If (cGrupo == cGrupoNX)
							cMensg := STR0022 //"Alguma questЦo deste grupo jА estА sendo utilizada!"
							lRet := .F.
						EndIf
					EndIf
					If lRet .And. (cGrupo == cGrupoNX) .And. (cSubGrupo == cSubGrupoNX)
						cMensg := STR0022 //"Alguma questЦo deste subgrupo jА estА sendo utilizada!"
						lRet := .F.
					EndIf
					If lRet .And. Empty(aCols[nX][nPosGru]) .And.  Empty(aCols[nX][nPosSGru]) .And. !Empty(aCols[nX][nPosQues])
						If (cSubGrupo == cSubGrupoNX)
							cMensg := STR0023 //"O subgrupo desta questЦo jА estА sendo utilizado!"
							lRet := .F.
						EndIf
					EndIf

				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё O grupo e a pergunta estЦo preenchidos (linha posicionada)   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Case !Empty(aCols[n][nPosGru]) .And.  Empty(aCols[n][nPosSGru]) .And. !Empty(aCols[n][nPosQues])
					If !Empty(aCols[nX][nPosGru]) .And.  Empty(aCols[nX][nPosSGru]) .And. Empty(aCols[nX][nPosQues])
						If (cGrupo == cGrupoNX)
							cMensg := STR0024 //"O grupo desta questЦo jА estА sendo utilizado!"
							lRet := .F.
						EndIf
					EndIf
					If lRet .And. (cGrupo == cGrupoNX) .And. (cSubGrupo == cSubGrupoNX) .And. Empty(aCols[nX][nPosQues])
						cMensg := STR0023 //"O subgrupo desta questЦo jА estА sendo utilizado!"
						lRet := .F.
					EndIf
					If lRet .And. !Empty(aCols[nX][nPosQues]) .And. aCols[n][nPosQues] == aCols[nX][nPosQues]
						cMensg := STR0025 //"Esta questЦo jА estА sendo utilizada!"
						lRet := .F.
					EndIf

				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё So a pergunta esta preenchida (linha posicionada)            Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Case Empty(aCols[n][nPosGru]) .And.  Empty(aCols[n][nPosSGru]) .And. !Empty(aCols[n][nPosQues])
					If !Empty(aCols[nX][nPosGru]) .And.  Empty(aCols[nX][nPosSGru]) .And. Empty(aCols[nX][nPosQues])
						If (cGrupo == cGrupoNX)
							cMensg := STR0024 //"O grupo desta questЦo jА estА sendo utilizado!"
							lRet := .F.
						EndIf
					EndIf
					If lRet .And. (cGrupo == cGrupoNX) .And. (cSubGrupo == cSubGrupoNX) .And. Empty(aCols[nX][nPosQues])
						cMensg := STR0023 //"O subgrupo desta questЦo jА estА sendo utilizado!"
						lRet := .F.
					EndIf
					If lRet .And. !Empty(aCols[nX][nPosQues]) .And. aCols[n][nPosQues] == aCols[nX][nPosQues]
						cMensg := STR0025 //"Esta questЦo jА estА sendo utilizada!"
						lRet := .F.
					EndIf
					
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Todos estЦo preenchidos            (linha posicionada)       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Case !Empty(aCols[n][nPosGru]) .And. !Empty(aCols[n][nPosSGru]) .And. !Empty(aCols[n][nPosQues])
					If !Empty(aCols[nX][nPosGru]) .And.  Empty(aCols[nX][nPosSGru]) .And. Empty(aCols[nX][nPosQues])
						If (cGrupo == cGrupoNX)
							cMensg := STR0024 //"O grupo desta questЦo jА estА sendo utilizado!"
							lRet := .F.
						EndIf
					EndIf
					If lRet .And. (cGrupo == cGrupoNX) .And. (cSubGrupo == cSubGrupoNX) .And. Empty(aCols[nX][nPosQues])
						cMensg := STR0023 //"O subgrupo desta questao jА estА sendo utilizado!"
						lRet := .F.
					EndIf
					If lRet .And. !Empty(aCols[nX][nPosQues]) .And. aCols[n][nPosQues] == aCols[nX][nPosQues]
						cMensg := STR0025 //"Esta questЦo jА estА sendo utilizada!"
						lRet := .F.
					EndIf
				OTHERWISE
	    	EndCase	
		Endif
		If !lRet
			HELP("   ",1,"EXIST",,cMensg+STR0026,1) // " Consulte a estrutura do questionАrio!"
			Exit // Sai do For
		EndIf
		
	Next nX
EndIf
                         
RestArea( aAreaSKG )
RestArea( aArea )

Return ( lRet )

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁGpr020Tree ЁAutora Ё Henry Fila           Ё Data Ё 20/10/03 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Monta tree da estrutura do questionario                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё Gpr020Tree()                                               Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё SIGAGPR                                                    Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁAnalista  Ё Data/Bops/Ver ЁManutencao Efetuada                         Ё╠╠
╠╠цддддддддддеддддддддбддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё        Ё      Ё                                            Ё╠╠
╠╠Ё          Ё        Ё      Ё                                            Ё╠╠
╠╠Ё          Ё        Ё      Ё                                            Ё╠╠
╠╠юддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function Gpr020Tree(aHeaderSKR,aColsSKR)

Local aSize     := MsAdvSize( .T. ) //Dimensionamento da tela
Local aPosObj1  := {} //Dimensionamento da tela
Local aObjects  := {} //Dimensionamento da tela          

Local cQuest    := "" //Concatenacao da descricao do questionario
Local cDescGru  := "" //Descricao do grupo

Local nPosGru   := aScan(aHeaderSKR,{|x| AllTrim(x[2])=="KR_CODGRU"}) //Posicao do grupo no acols
Local nPosSGru  := aScan(aHeaderSKR,{|x| AllTrim(x[2])=="KR_CODSGR"}) //Posicao do subgrupo no acols
Local nPosQues  := aScan(aHeaderSKR,{|x| AllTrim(x[2])=="KR_CODQST"}) //Posicao do subgrupo no acols
Local nX        := 0                                                   //Variavel do contador
Local nUsado    := Len(aHeaderSKR)                                     //Controle de dimensoes do browse 

Local oDlg  //Objeto da janela
Local oTree //Objeto do tree
Local oMenu //Objeto do menu

aObjects := {} 
AAdd( aObjects, { 100, 30,  .t., .f. } )
AAdd( aObjects, { 100, 100 , .t., .t. } )

aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 } 
aPosObj1 := MsObjSize( aInfo, aObjects) 

DEFINE MSDIALOG oDlg FROM aSize[7],000 TO aSize[6],aSize[5] TITLE STR0013 PIXEL //"Estrutura do Questionario"

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Definicao do DbTree.                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DEFINE DBTREE oTree FROM aPosObj1[2,1],aPosObj1[2,2] TO aPosObj1[2,3],aPosObj1[2,4] CARGO OF oDlg           
	

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Exibe definicoes do questionario                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cQuest := STR0014 + M->KP_CODQUE + "-"+M->KP_DESC //"Questionario :"
	@ aPosObj1[1,1]+10,05 Say cQuest of oDlg PIXEL 

	//здддддддддддддддддддддддддддд©
	//ЁVerifica as linhas digitadasЁ
	//юдддддддддддддддддддддддддддды
	For nX := 1 to Len(aColsSKR)		

		If !aColsSKR[ nX ][ nUsado +  1 ]

			Do Case
	
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica se somente o grupo esta preenchido                  Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Case !Empty(aColsSKR[nX][nPosGru]) .And. Empty(aColsSKR[nX][nPosSGru]) .And. Empty(aColsSKR[nX][nPosQues])
	
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Busca o Grupo                                                Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					dbSelectArea("SKE")
					dbSetOrder(1)
					If DbSeek(xFilial("SKE")+aColsSKR[nX][nPosGru])
	
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Armazena a descricao do grupo                                Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						cDescGru := SKE->KE_DESC
	
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Adiciona o grupo no tree                                     Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						cPrompt := Pad(STR0015+aColsSKR[nX][nPosGru]+"-"+cDescGru,120) //"GRUPO :"
						DBADDTREE oTree PROMPT cPrompt RESOURCE "bmpord1","bmpord1" CARGO Pad("GRP",120)
		
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Busca se existe subgrupos                                    Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						dbSelectArea("SKF")
						dbSetOrder(1)
						If DbSeek(xFilial("SKF")+aColsSKR[nX][nPosGru])
							While SKF->(!Eof()) .And. SKF->KF_FILIAL == xFilial("SKF") .And.;
														SKF->KF_CODGRP == aColsSKR[nX][nPosGru]
	
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Adiciona o subgrupo no tree                                  Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								cPrompt := Pad(STR0016+SKF->KF_CODSUBG,120) //"SUBGRUPO :"
								DBADDTREE oTree PROMPT cPrompt RESOURCE "bmpincluir","bmpincluir" CARGO Pad("SGR",120)
	
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Busca a questao                                              Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								dbSelectArea("SKG")
								dbSetOrder(2)
								If DbSeek(xFilial("SKG")+aColsSKR[nX][nPosGru]+SKF->KF_CODSUBG)
									While SKG->(!Eof()) .And. SKG->KG_FILIAL == xFilial("SKG") .And.;
															SKG->KG_CODGRP == aColsSKR[nX][nPosGru] .And.;
															SKG->KG_CODSUBG == SKF->KF_CODSUBG
	
	
										//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
										//Ё Adiciona a questao no tree                                   Ё
										//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
										cCargo    := Pad("QST"+StrZero(SKG->(Recno()),6),120)
										cResource := "note" 
										cPrompt   := Pad(STR0017+SKG->KG_CODQST + " : "+SubStr(SKG->KG_DESC,1,20),120) //"QUESTAO :"
									
										DBADDITEM oTree PROMPT cPrompt RESOURCE cResource CARGO cCargo
						     
										SKG->(dbSkip())
										
									EndDo                                
									
									DBENDTREE oTree							
								Else	                                                 
									cCargo    := Pad(StrZero(SKF->(Recno()),6),120)
									cResource := "excluir"
									cPrompt   := Pad(STR0018,120) //"NAO EXISTEM QUESTOES DISPONIVEIS"
									DBADDITEM oTree PROMPT cPrompt RESOURCE cResource CARGO cCargo
									DBENDTREE oTree								
								Endif		
		
		
								SKF->(dbSkip())						
								
							EndDo	
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Busca questoes de grupos que possuem subgrupos mas as questoes Ё
							//Ё nao estao inforamados os subgrupos                             Ё							
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							dbSelectArea("SKG")
							dbSetOrder(2)
							If DbSeek(xFilial("SKG")+aColsSKR[nX][nPosGru]+Space(Len(SKG->KG_CODSUBG)))
	
								While SKG->(!Eof()) .And. SKG->KG_FILIAL == xFilial("SKG") .And.;
														SKG->KG_CODGRP == aColsSKR[nX][nPosGru] .And.;
														SKG->KG_CODSUBG == Space(Len(SKG->KG_CODSUBG))
									//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё Adiciona a questao no tree                                   Ё
									//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									cCargo    := Pad("QST"+StrZero(SKG->(Recno()),6),120)
									cResource := "note"  
									cPrompt   := Pad(STR0017+SKG->KG_CODQST + " : "+SubStr(SKG->KG_DESC,1,20),120) //"QUESTAO :"
								
									DBADDITEM oTree PROMPT cPrompt RESOURCE cResource CARGO cCargo
									SKG->(dbSkip())
								EndDo                                
								
								DBENDTREE oTree							
								
							Endif
	
							DBENDTREE oTree
						
						Else

							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Se nao achou subgrupos busca diretamente a questao           Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							dbSelectArea("SKG")
							dbSetOrder(2)
							If DbSeek(xFilial("SKG")+aColsSKR[nX][nPosGru])

								While SKG->(!Eof()) .And. SKG->KG_FILIAL == xFilial("SKG") .And.;
														SKG->KG_CODGRP == aColsSKR[nX][nPosGru]

									//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё Adiciona a questao no tree                                   Ё
									//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									cCargo    := Pad("QST"+StrZero(SKG->(Recno()),6),120)
									cResource := "note"  
									cPrompt   := Pad(STR0017+SKG->KG_CODQST + " : "+SubStr(SKG->KG_DESC,1,20),120) //"QUESTAO :"
								
									DBADDITEM oTree PROMPT cPrompt RESOURCE cResource CARGO cCargo

									SKG->(dbSkip())
								EndDo                                
								
								DBENDTREE oTree							
							Else
								cCargo    := Pad(StrZero(SKF->(Recno()),6),120)
								cResource := "excluir"
								cPrompt   := Pad(STR0018,120) //"NAO EXISTEM QUESTOES DISPONIVEIS         
								DBADDITEM oTree PROMPT cPrompt RESOURCE cResource CARGO cCargo
								DBENDTREE oTree								
							Endif
					
							DBENDTREE oTree									
							
						Endif	
						
						
					Endif
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica se grupo e subgrupo estao preenchidos e questao vazia    Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Case !Empty(aColsSKR[nX][nPosGru]) .And. !Empty(aColsSKR[nX][nPosSGru]) .And. Empty(aColsSKR[nX][nPosQues])
	
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Busca se existe subgrupos                                    Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
					dbSelectArea("SKF")
					dbSetOrder(1)
					If DbSeek(xFilial("SKF")+aColsSKR[nX][nPosGru])
	
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Armazena a descricao do grupo                                Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						cDescGru := SKF->KF_DESC
				
						cPrompt := Pad(STR0015+aColsSKR[nX][nPosGru]+ " / "+STR0016+aColsSKR[nX][nPosSGru]+"-"+cDescGru,120) //GRUPO##SUBGRUPO :  
						DBADDTREE oTree PROMPT cPrompt RESOURCE "bmpincluir","bmpincluir" CARGO Pad("SGR",120)
		            			
						dbSelectArea("SKG")
						dbSetOrder(2)
						If DbSeek(xFilial("SKG")+aColsSKR[nX][nPosGru]+aColsSKR[nX][nPosSGru])
							While SKG->(!Eof()) .And. SKG->KG_FILIAL == xFilial("SKG") .And.;
															SKG->KG_CODGRP == aColsSKR[nX][nPosGru] .And.;
															SKG->KG_CODSUBG == aColsSKR[nX][nPosSGru]
		
								cCargo    := Pad("QST"+StrZero(SKG->(Recno()),6),120)
								cResource := "note"
								cPrompt   := Pad("QUESTAO "+SKG->KG_CODQST,120)							
									
								DBADDITEM oTree PROMPT cPrompt RESOURCE cResource CARGO cCargo
								SKG->(dbSkip())
							EndDo                                
									
							DBENDTREE oTree							
						Else
							cCargo    := Pad(StrZero(SKF->(Recno()),6),120)														
							cResource := "excluir"
							cPrompt   := Pad(STR0018,120) //"NAO EXISTEM QUESTOES DISPONIVEIS"
							DBADDITEM oTree PROMPT cPrompt RESOURCE cResource CARGO cCargo								
							DBENDTREE oTree								
						Endif		
		
						DBENDTREE oTree
						
					Endif
					
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica se a questao esta preenchida                        Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Case !Empty(aColsSKR[nX][nPosQues])
				
					dbSelectArea("SKG")
					dbSetOrder(1)
					If DbSeek(xFilial("SKG")+aColsSKR[nX][nPosQues])
	
				 		cCargo    := Pad("QST"+StrZero(SKG->(Recno()),6),120)
						cResource := "note"
						cPrompt   := Pad(STR0017+SKG->KG_CODQST,120) //"QUESTAO :"
							
						DBADDITEM oTree PROMPT cPrompt RESOURCE cResource CARGO cCargo

						DBENDTREE oTree							
					Endif		
	
				            
			EndCase 
		Endif	
    Next        

	MENU oMenu POPUP 
		MENUITEM STR0003 Action Gpr020Menu(oTree,oMenu) //"Visualiza"
	ENDMENU

	oTree:bRClicked  := { |o,x,y| Gpr020MAct( o, x, y, oMenu ) } // Posicao x,y em relaГЦo a Dialog

	
            
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {||oDlg:End()}, {||oDlg:End()}) CENTERED

Return( .T. )

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁGpr020MenuЁ Autor Ё Henry Fila            Ё Data Ё28/02/2005Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Funcao de visualizacao da questao                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё Gpr020Menu( ExpO1, ExpO2 )                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   Ё Logico                                                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpO1 -> Objeto Tree                                       Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao Efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
                              
Function Gpr020Menu( oTree )                               

Local aAreaSKG  := SKG->(GetArea()) //Armazena area de trabalho
Local aArea     := GetArea()        //Armazena area de trabalho

Local cCargo    := oTree:GetCargo() //Busca referencial do tree
Local cCadBkp   := cCadastro        //Armazena string do cadastro
Local nRecnoSKG := Val(Substr(cCargo,4,6))  //Registro da tabela de questoes do tree
Local lIncluiBk := INCLUI

cCadastro := STR0019 //Cadastro de questoes

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Visualiza a questao                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

dbSelectArea("SKG")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no registro                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SKG->(MsGoto(nRecnoSKG))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza variavel inclui                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
INCLUI  := .F.

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Vizualiza a questao                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Gpra030Man("SKG",nRecnoSKG,2)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura variavel inclui                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Inclui     := lIncluiBK
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura string do cCadastro                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCadastro := cCadBkp

RestArea(aAreaSKG)
RestArea(aArea)

Return( .T. )



/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁGpr020MActЁ Autor Ё Henry Fila            Ё Data Ё28/02/2005Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Funcao de chamada do menu                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё Gpr020MAct( ExpO1, ExpN1, ExpN2, ExpO2 )                   Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   Ё Logico                                                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpO1 -> Objeto Tree / ExpN1 -> Dimensao X                 Ё╠╠
╠╠Ё          Ё ExpN2 -> Dimensao Y  / ExpO2 -> Objeto Menu                Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao Efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
                              
Function Gpr020MAct( oTree, nX, nY, oMenu )                               
                  
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Desabilita todos os itens do menu                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AEval( oMenu:aItems, { |x| x:Disable() } ) 

cCargo := oTree:GetCargo() 

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Habilita as opcoes de acordo com a entidade do tree          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Left( cCargo, 3 ) == "GRP"
	oMenu:aItems[1]:disable()  
ElseIf Left( cCargo, 3 ) == "SGR"
	oMenu:aItems[1]:disable()  
ElseIf Left( cCargo, 3 ) == "QST"
	oMenu:aItems[1]:enable()  
EndIf 

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o Menu PopUp                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oMenu:Activate( nX, nY, oTree )

Return( .T. )


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁGpr030Prv  ЁAutora Ё Henry Fila           Ё Data Ё 20/10/03 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Preview do questionario                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё Gpr030Prv()                                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё SIGAGPR                                                    Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁAnalista  Ё Data/Bops/Ver ЁManutencao Efetuada                         Ё╠╠
╠╠цддддддддддеддддддддбддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё09/08/04Ё710   Ё                                            Ё╠╠
╠╠Ё          Ё        Ё      Ё                                            Ё╠╠
╠╠Ё          Ё        Ё      Ё                                            Ё╠╠
╠╠юддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function Gpr020Prv()

Local cParam := ""

cParam += fPesq2URL( "000000"+SKP->KP_CODQUE+"000000000000000000211" )
ShellExecute("open",GetSrvProfString("UrlGpr","")+"w_pgpr010.apw?cID="+cParam, "","",SW_SHOW)

Return( .T. )


function regra()

Return( .T. )

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддддддбдддддддбдддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFunГЦo    ЁGPR020AfterCols Ё Autor Ё Conrado Q.      Ё Data Ё 29/01/2007 Ё╠╠
╠╠цддддддддддеддддддддддддддддадддддддадддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescriГЦo ЁRotina executada durante a montagem do aCols                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁGPR020AfterCols( ExpC1, ExpA2 )                               Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁExpC1: Alias da tabela utilizada no FillGetDados              Ё╠╠
╠╠Ё          ЁExpA2: Array de registros utilizados                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Pesquisa e Resultado                                         Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Atualizacoes sofridas desde a Construcao Inicial.                       Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador  Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё              Ё        Ё      Ё                                          Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function GPR020AfterCols( cAlias, aRecnoArray )
	If ( Alias() == cAlias )
		aAdd( aRecnoArray, (cAlias)->( Recno() ) )
	EndIf
Return( .T. )
