#INCLUDE "GPRDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPRA030.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "SHELL.CH"

#DEFINE MAXGETDAD 4096

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁGPRA030    ЁAutor  Ё Henry Fila           Ё Data Ё 22/02/05 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё CADASTRO DE QUESTOES                                       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё SIGAGPR                     	                              Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁAnalista  Ё Data/Bops/Ver ЁManutencao Efetuada                         Ё╠╠
╠╠цддддддддддеддддддддбддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁMarcelo K.Ё09/08/04Ё710   ЁRevisao do fonte:Sintaxe,Documentacao,LogicaЁ╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function GPRA030(aRotAuto,nOpc)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de Variaveis                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private cCadastro := STR0001		    										// Cadastro de Questoes

Private aRotina   := MenuDef()

Private aMemos    := {{"KG_CODCOMP","KG_COMPLEM"},{"KG_CODOBJ","KG_OBJETIV"}} 	// Array resp. pela gravacao dos campos memo

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Definicao de variaveis para rotina de inclusao automatica    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private l030Auto := (aRotAuto <> NIL)						// Flag de controle para entrada automatica

If (nOpc == NIL) 
	nOpc := 3
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Selecionando Alias de Trabalho                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("SKG")
DbSetOrder(1)
If l030Auto
	MsRotAuto(nOpc,aRotAuto,"SKG")
Else
	mBrowse(6,1,22,75,"SKG")
Endif

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
	Local aRotina := {	{STR0002 ,"AXPESQUI"	,0 ,1	,0	,.F.	}	,;   	// Pesquisar
						{STR0003 ,"Gpra030Man"	,0 ,2	,0	,.T.	}	,;   	// Visualizar
						{STR0004 ,"Gpra030Man"	,0 ,3	,0	,.T.	}	,;   	// Incluir
						{STR0005 ,"Gpra030Man"	,0 ,4	,0	,.T.	}	,;   	// Alterar
						{STR0006 ,"Gpra030Man"	,0 ,5	,0	,.T.	}	,;   	// Excluir
						{STR0065 ,"Gpra030Wiz"	,0 ,3	,0	,.T.	}	,;   	// Wizard
						{STR0066 ,"Gpra030Prv"	,0 ,3	,0	,.T.	}	}   	// Preview de questoes
Return(aRotina)

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё Gpr030ManЁ Autor Ё Henry Fila            Ё Data Ё 17.02.05 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Manutencao Cadastro de Questoes                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Gerenciamento de Pesquisa e resuiltados (GPR)              Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     Ё╠╠
╠╠цддддддддддддддбддддддддддбддддддбдддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё  DATA    Ё BOPS Ё  MOTIVO DA ALTERACAO                 Ё╠╠
╠╠цддддддддддддддеддддддддддеддддддедддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё              Ё          Ё      Ё                                      Ё╠╠
╠╠юддддддддддддддаддддддддддаддддддадддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function GprA030Man( cAlias, nReg, nOpc )

Local aPosObj     := {}						// Array para o MsAdvSize
Local aObjects    := {}						// Array com a posicao dos objetos de tela	
Local aSize	      := MsAdvSize()			// Array com as dimensoes da tela capturadas automaticamente pela funcao MsAdvSize
Local aRecnoSKH   := {}						// Array auxiliar para o SKH
Local aHeaderSKH  := {}						// Array do aHeader (campos) da getdados do SKH
Local aColsSKH    := {}						// Array do aCols (conteudo dos campos) da getdados do SKH
Local aRecnoSKI   := {}						// Array auxiliar para o SKI
Local aHeaderSKI  := {}						// Array do aHeader (campos) da getdados do SKI
Local aColsSKI    := {}						// Array do aCols (conteudo dos campos) da getdados do SKI
Local aButtons    := {}						// Array com os botoes da toolbar superior

Local nSaveSx8    := GetSx8Len()			// Array auxiliar para controle de semaforos
Local nOpca       := 0						// Variavel de controle da escolha do usuario OK ou CANCELA
Local nX          := 0						// Contador auxiliar do FOR/NEXT

Private aTELA[0][0],aGETS[0]                // Array de controle para validacao dos campos de tela da entrada automatica             	

aButtons :=  { { "S4WB011N"   , { || GdSeek(IIF(oFolder:nOption == 1,oGetdSKH,oGetdSKI),STR0067) }, STR0067, STR0068 } } //"Busca avancada"
                                          
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa desta forma para criar uma nova instancia de variaveis private Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 3
	RegToMemory( "SKG",  .T. )
Else
	RegToMemory( "SKG",  .F. )
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
		Endif
	Next nX
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta aHeader e aCols das colunas das alternativas                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Gpr030CSKH( aHeaderSKH, aColsSKH, aRecnoSKH, nOpc )

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta aHeader e aCols das colunas das alternativas                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Gpr030CSKI( aHeaderSKI, aColsSKI, aRecnoSKI, nOpc )

If Type("l030Auto") == "U" .OR. !l030Auto
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Faz o calculo automatico de dimensoes de objetos     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды

	aSize := MsAdvSize()
	AAdd( aObjects, { 100,065,.T.,.T. } )
	AAdd( aObjects, { 100,100,.T.,.T. } )
	aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T. )


	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Definindo Enchoice                                   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		EnChoice(cAlias,nReg,nOpc,,,,,aPosObj[1],, , , , , , ,.T.)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Definindo Titulos da Folder                          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aTitles := {STR0015,STR0016}	// Alternativas, Linhas ou Colunas

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Definindo Painel para Exibicao das Mensagens         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		@ aPosObj[2,1], aPosObj[2,2] MSPANEL oPanel PROMPT "" SIZE aPosObj[2,3],aPosObj[2,4] OF oDlg
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Definindo as Folders                                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{"",""},oDlg,,,,.T.,.F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
		oFolder:bSetOption:={|nAtu| Gp030Fld(nAtu,oFolder:nOption)}

		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Getdados - Alternativas                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		oGetdSKH := MsNewGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-15,aPosObj[2,4]-aPosObj[2,2]-5,IIF(Altera .OR. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE,0),"GP030LOK1()","GP030TOK1()","+KH_CODALT",,,MAXGETDAD,,,,oFolder:aDialogs[1],aHeaderSKH,aColsSKH)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Getdados - Linhas ou Colunas                         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		oGetdSKI := MsNewGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-15,aPosObj[2,4]-aPosObj[2,2]-5,IIF(Altera .OR. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE,0),"GP030LOK2()","GP030TOK2()","+KI_CODCOL",,,MAXGETDAD,,,,oFolder:aDialogs[2],aHeaderSKI,aColsSKI)
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Prepara a apresentacao da tela de acordo com o Tipo de Questao            |
		//Ё Esta funcao tambem e utilizada atraves de Gatilho: KG_TIPOEXI/KG_TIPOQST  |
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cExibe := GPRA030EXI(nOpc)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ativando a Tela                                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA := 1,aColsSKH:=oGetdSKH:aCols,aColsSKI:=oGetdSKI:aCols,If(Gp030Ok(aHeaderSKH,aColsSKH,aHeaderSKI,aColsSKI),If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},{||oDlg:End()},, aButtons )	

	If ( nOpca == 1 )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gravacao da questionario                                                  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		Gpr030Grv(	nOpc		,aRecnoSKI	,aHeaderSKI	,aColsSKI,;
					aRecnoSKH	,aHeaderSKH	,aColsSKH)
		
		While (GetSx8Len() > nSaveSx8 )
			ConfirmSx8()
		End
		
		EvalTrigger()
	Else
		If nOpc <> 2                   
			While (GetSx8Len() > nSaveSx8 )		
				RollBackSx8()	
			End		
		Endif				

	Endif

Endif

DbSelectArea("SKP")

Return( .T. )  


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    ЁGpr030Grv Ё Autor Ё Henry Fila            Ё Data Ё 17/02/2005 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁRotina de Gravacao da Questao                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁGpr030Grv                                                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁExpN1: Opcao da Gravacao sendo:                               Ё╠╠
╠╠Ё          Ё       [3] Inclusao                                           Ё╠╠
╠╠Ё          Ё       [4] Alteracao                                          Ё╠╠
╠╠Ё          Ё       [5] Exclusao                                           Ё╠╠
╠╠Ё          ЁExpA2: Array de registros de alternativas                     Ё╠╠
╠╠Ё          ЁExpA3: aHeader de alternativas                                Ё╠╠
╠╠Ё          ЁExpA4: aCols de Alternativas                                  Ё╠╠
╠╠Ё          ЁExpA5: Array de registros de opcoes                           Ё╠╠
╠╠Ё          ЁExpA6: aHeader de Opcoes                                      Ё╠╠
╠╠Ё          ЁExpA7: aCols de Opcoes                                        Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Gestao de pesquisa e resultado                               Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Atualizacoes sofridas desde a Construcao Inicial.                       Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador  Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁAndre Veiga   Ё19/04/06Ё093232ЁNa alteracao das questoes, nao estava sen-Ё╠╠
╠╠Ё              Ё        Ё      Ёdo tratado corretamente a gravacao do SKH.Ё╠╠
╠╠Ё              Ё        Ё      Ё                                          Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function Gpr030Grv(	nOpc		,aRecnoSKI		,aHeaderSKI		,aColsSKI,;
							aRecnoSKH	,aHeaderSKH		,aColsSKH )                
							
Local aArea     		:= GetArea() 					// Armazena area de trabalho
Local bCampo 			:= {|nCPO| Field(nCPO) } 		// Bloco de codigo para campo usado fieldput
Local cAliasMemo		:= "SKZ" 						// Alias de trabalho dos campos memo
Local nX        		:= 0  							// Variavel de contador Next
Local nCntFor   		:= 0  							// Variavel de contador Next
Local nY        		:= 0  							// Variavel de contador Next
Local nUsado    		:= 0  							// Variavel dimensao de aHeader
Local lTravou   		:= .F.							// Identifica se conseguiu travar o registro
Local cVarMemo			:= space(80)					// Variavel auxiliar para gravar o conteudo dos campos MEMO
Local nOpcMemo			:= 1							// Flag de controle da operacao de inclusao/alteracao/exclusao da funcao MSMM

If nOpc <> 5  // Exclusao

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//| Grava o resumo da Questao porque o campo de QUESTAO e um campo MEMO e nao e possivel visualiza-lo em consultas F3 |
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !Empty( TRIM(M->KG_COMPLEM) )
		M->KG_DESC := Substr(M->KG_COMPLEM,1,80)
	Endif

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁGrava a pesquisa e as regras da pesquisa                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BEGIN TRANSACTION

		DbSelectArea("SKG")
		DbSetOrder(1)
		If DbSeek(xFilial("SKG")+M->KG_CODQST)
			RecLock("SKG",.F.)
		Else
			RecLock("SKG",.T.)
		Endif        
		
		For nCntFor := 1 To FCount()
			FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor)))
		Next nCntFor

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁGrava os campos Memos Virtuais					 				  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("aMemos") == "A"
			For nCntFor := 1 TO Len(aMemos)

				nOpcMemo := 1
				
				cVarMemo := aMemos[nCntFor][2]
				
				If Len(aMemos[nCntFor]) == 3
					cAliasMemo := aMemos[nCntFor][3]
				Else
					cAliasMemo := Nil
				Endif
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//ЁSe o usuario "limpou" o campo MEMO, ele deve ser excluido do SYPЁ
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If Empty(Trim((&cVarMemo)))
					nOpcMemo := 2
				Endif	
					
				MSMM(&("M->"+aMemos[nCntFor][1]),TamSx3(aMemos[nCntFor][2])[1],,&cVarMemo,1,,,"SKG",aMemos[nCntFor][1],cAliasMemo)
				
			Next nCntFor
		Endif

		If !Empty( TRIM(M->KG_COMPLEM) )
			M->KG_DESC := Substr(M->KG_COMPLEM,1,80)
		Endif
                        
		SKG->KG_FILIAL := xFilial("SKG")
		MsUnLock()

		If VAL(M->KG_TIPOQST) <> DISSERTATIVA

			nUsado := Len(aHeaderSKH)
	
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁGrava os itens das questoes   					 				  Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nX := 1 To Len(aColsSKH)
		
				lTravou := .F.
				If nX <= Len(aRecNoSKH)		
					DbSelectArea("SKH")
					dbGoto(aRecNoSKH[nX])
					RecLock("SKH")
					lTravou := .T.
				Endif
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Se a linha nao esta' deletada, grava o item                     Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If ( !aColsSKH[nX][nUsado+1] )
					If !lTravou 
						RecLock("SKH",.T.)			
					Endif
					
					For nY := 1 To Len(aHeaderSKH)
						
						If aHeaderSKH[nY][10] <> "V"
							SKH->(FieldPut(FieldPos(aHeaderSKH[nY][2]),aColsSKH[nX][nY]))
						Endif
						
					Next nY
	
					REPLACE SKH->KH_FILIAL WITH xFilial("SKH")
					REPLACE SKH->KH_CODQST WITH SKG->KG_CODQST
				
					MsUnLock()                   
				
					lGravou := .T.
				Else

					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Se for alteracao, verifica se precisa deletar as informacoes da base Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If nOpc == 4
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verifica se existe a alternativa ja  cadastrada. Se existir, deleta da base. Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If lTravou
							dbDelete()
							MsUnLock()
						Endif
					Endif
					
				Endif
			
			Next nX
		Endif

		If Val(M->KG_TIPOQST) == MULTIPLA .AND. Val(M->KG_TIPEXIB) <> SEQUENCIAL

			nUsado := Len(aHeaderSKI)
	
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁGrava os itens das questoes   					 				  Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nX := 1 To Len(aColsSKI)
		
				lTravou := .F.
				If nX <= Len(aRecNoSKI)		
					DbSelectArea("SKI")
					dbGoto(aRecNoSKI[nX])
					RecLock("SKI")
					lTravou := .T.
				Endif
				
				If ( !aColsSKI[nX][nUsado+1] )
					If !lTravou 
						RecLock("SKI",.T.)			
					Endif
					For nY := 1 To Len(aHeaderSKI)
						If aHeaderSKI[nY][10] <> "V"
							SKI->(FieldPut(FieldPos(aHeaderSKI[nY][2]),aColsSKI[nX][nY]))
						Endif
					Next nY
	
					SKI->KI_FILIAL := xFilial("SKI")
					SKI->KI_CODQST := SKG->KG_CODQST
				
					MsUnLock()                   
				
					lGravou := .T.
				Endif
				MsUnLock()
			
			Next nX
		Endif	

	END TRANSACTION
	
Else
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁExclui as alteranativas                                            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SKH")
	DbSetOrder(1)
	If DbSeek(xFilial("SKH")+SKG->KG_CODQST)
		While !Eof() .AND. SKH->KH_FILIAL == xFilial("SKG") .AND.;	
							SKH->KH_CODQST == SKG->KG_CODQST
			RecLock("SKH")
			dbDelete()	
			MsUnlock()	

			SKH->(DbSkip())								
		End	
	Endif	

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁExclui as opcoes                                                   Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SKI")
	DbSetOrder(1)
	If DbSeek(xFilial("SKI")+SKG->KG_CODQST)
		While !Eof() .AND. SKI->KI_FILIAL == xFilial("SKG") .AND.;	
							SKI->KI_CODQST == SKG->KG_CODQST
			RecLock("SKI")
			dbDelete()	
			MsUnlock()	

			SKI->(DbSkip())								
		End	
	Endif	

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁExclui as questao                                                  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SKG")
	DbSetOrder(1)
	RecLock("SKG")
	dbDelete()	
	MsUnlock()	

Endif

RestArea(aArea)

Return( .T. )


/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁGPRA030EXI ЁAutor  Ё Henry Fila           Ё Data Ё 22/02/05 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Se o tipo de Questao for dissertativa o tipo de exibicao   Ё╠╠
╠╠Ё          Ё so poderА ser o convencional "1"                           Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё GPRA030EXI()                                               Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё GPRA030 - GATILHO                                          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function GPRA030EXI(nRecOpc)

Local cTipo := ""                  					// Tipo da QuestЦo para o Retorno
Local oFont	:= TFont():New( "Arial",15,20,,.T.)		// Fonte da resposta dissertativa

DEFAULT nRecOpc := 0 								// Controle de quando a funcao e chamada pelo gatilho

Do Case

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Unica escolha                                                       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

   Case VAL(M->KG_TIPOQST) == UNICA

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Exibicao sequencial                                                 Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   		cTipo := "1" 		

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Painel da Dissertativa                                              Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		oPanel:Hide()

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Folder                                                              Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   		oFolder:lVisible  := .T.
   		oFolder:lReadOnly := .F.

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё FGetDados das Alternativas                                          Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   		oGetdSKH:Show()
   		oGetdSKH:oBrowse:lReadOnly 	:= .F.
   		oGetdSKH:Refresh()

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Getdados das Linhas ou Colunas das Alternativas                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   		oGetdSKI:Show()
   		oGetdSKI:oBrowse:lReadOnly 	:= .F.
  		oGetdSKI:Refresh()		

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Zerar as variaveis quando esta trabalhando com gatilhos ou inclusao Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If (nRecOpc == 0) .OR. (nRecOpc == 3)

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё A permissao para repeticao de alternativas so serve para as questoes de multipla escolha      Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  		If ValType(M->KG_REPETE) <> "U"
		  		M->KG_REPETE  := SPACE(TamSX3("KG_REPETE")[1])
			Endif	  		

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Limite de seleГЦo so serve para questoes multipla escolha                                     Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ValType(M->KG_LIMSELE) <> "U"
				M->KG_LIMSELE := 0								
			Endif
		
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Se a observacao estiver branco zerar o limite de respostas                                    Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If 	ValType(M->KG_LIMRESP) <> "U" 	.AND.;
				ValType(M->KG_OBSERV) <> "U" 	.AND.;
				Empty(M->KG_OBSERV)
	  			M->KG_LIMRESP := 0
	  		Endif
	  	Endif	
		
   Case VAL(M->KG_TIPOQST) == MULTIPLA	// MULTIPLA ESCOLHA

   		cTipo := M->KG_TIPEXIB 	// Mantenho o selecionado pelo usuario

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Painel da Dissertativa                                                                        Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		oPanel:Hide()

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Folder                                                                                        Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   		oFolder:lVisible  := .T.
   		oFolder:lReadOnly := .F.

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё GetDados das Alternativas                                                                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   		oGetdSKH:Show()
   		oGetdSKH:oBrowse:lReadOnly 	:= .F.
   		oGetdSKH:Refresh()

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Se o Tipo de Exibicao nao for PADRAO desabilitar a Folder Linhas ou Colunas (Sequencial)      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If cTipo == "1" 
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Getdados das Linhas ou Colunas das Alternativas                                               Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   		oGetdSKI:Show()
	   		oGetdSKI:oBrowse:lReadOnly 	:= .F.
	  		oGetdSKI:Refresh()		
    	Else
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Getdados das Linhas ou Colunas das Alternativas                                               Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   		oGetdSKI:Show()
	   		oGetdSKI:oBrowse:lReadOnly 	:= .F.
	  		oGetdSKI:Refresh()		
  		Endif
  		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Zera as variaveis quando esta trabalhando com gatilhos ou inclusao Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nRecOpc == 0 .OR. nRecOpc == 3

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё A permissao para repeticao de alternativas so serve para as questoes de multipla escolha      Ё
			//Ё desde que a mesma nao seja exibidas em colunas, pois neste caso elas ja nao se repetem        Ё			
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ValType(M->KG_REPETE) <> "U"
		  		If Empty(M->KG_REPETE) .AND. VAL(M->KG_TIPEXIB) == DISSERTATIVA
		  			M->KG_REPETE  := CriaVar("KG_REPETE",.F.)
		  		Endif	
			Endif	  		

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁLimite de selecao so serve para questoes multipla escolha exceto para as exibidas em colunas   Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ValType(M->KG_LIMSELE) <> "U"
				If VAL(M->KG_TIPEXIB) == SEQUENCIAL
					M->KG_LIMSELE := M->KG_LIMSELE
				Else
					M->KG_LIMSELE := 0
				Endif	
			Endif

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Se a observacao estiver branco zerar o limite de respostas                                    Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If 	ValType(M->KG_LIMRESP) <> "U" 	.AND.;
				ValType(M->KG_OBSERV) <> "U" 	.AND.;
				Empty(M->KG_OBSERV)
				M->KG_LIMRESP := 0
			Endif
		Endif
		  		
   OtherWise 					// DISSERTATIVA

   		cTipo := "1" 			// EXIBICAO TEM QUE SER CONVENCIONAL


		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Folder                                                                                        Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   		oFolder:lVisible  := .F.
   		oFolder:lReadOnly := .T.

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё GetDados das Alternativas                                                                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   		oGetdSKH:Hide()
   		oGetdSKH:oBrowse:lReadOnly 	:= .T.
   		oGetdSKH:Refresh()

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Getdados das Linhas ou Colunas das Alternativas                                               Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   		oGetdSKI:Hide()
   		oGetdSKI:oBrowse:lReadOnly 	:= .T.
  		oGetdSKI:Refresh()		

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁPainel da Dissertativa                                                                         Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		oPanel:Show()
		@ 2,2 SAY STR0008 FONT oFont COLOR CLR_LIGHTGRAY OF oPanel PIXEL // "QuestЦo do tipo dissertativa" '

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Zera as variaveis quando estou trabalhando com gatilhos ou inclusao Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
  		If nRecOpc == 0 .OR. nRecOpc == 3

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁRepetir Respostas qdo multipla escolha                                                         Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ValType(M->KG_REPETE) <> "U"
		  		M->KG_REPETE  := Space(TamSX3("KG_REPETE")[1])	
			Endif	  		

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁObservacao deve ficar em branco                                                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ValType(M->KG_OBSERV) <> "U"
	  			M->KG_OBSERV  := Space(TamSX3("KG_OBSERV")[1])  
			Endif	  	

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁLimite de Complemento                                                                          Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ValType(M->KG_LIMCOMP) <> "U"
				M->KG_LIMCOMP := 0 								
			Endif

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁLimite de caracteres da resposta deve trazer o default                                         Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ValType(M->KG_LIMRESP) <> "U"
				M->KG_LIMRESP := CriaVar("KG_LIMRESP",.F.) 			
			Endif	  			

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁLimite de seleГЦo de alternativas	                                                          Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ValType(M->KG_LIMSELE) <> "U"
				M->KG_LIMSELE := 0								
			Endif
		Endif

EndCase

Return( cTipo )


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁGp030Fld  ЁAutor  ЁHenry Fila             Ё Data Ё22.02.2005Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁFuncao de Tratamento dos Folders                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё GPRA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function Gp030Fld(nAtu,nOption)

Local lRet    := .F.		// Retorno da funcao

If nAtu == 2
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁSe a questao for multipla escolha com Coluna ou linha validar                                  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If VAL(M->KG_TIPOQST) == MULTIPLA .AND. VAL(M->KG_TIPEXIB) <> SEQUENCIAL
		lRet :=  oGetdSKH:TudoOk()
	Else
		Help("",1,"GPRA030_07") // As questoes do tipo convencional nao necessitam do preenchimento de linhas ou colunas
		lRet := .F.
	Endif
	
Else
	If nAtu == 1
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁSe a questao for multipla escolha com Coluna ou linha                                          Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If VAL(M->KG_TIPOQST) == MULTIPLA .AND. VAL(M->KG_TIPEXIB) <> SEQUENCIAL
			lRet :=  oGetdSKI:TudoOk()
		Else
			lRet :=  .T.
		Endif
	Else
		lRet := .T.
	Endif
Endif

Return( lRet )

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁGP030LOK1 Ё Autor Ё Henry Fila            Ё Data Ё 22/02/05 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Criar validaГЦo para a cada linha da aCols                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё GP030LOK1()                                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё SIGAGPR               							          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function Gp030LOk1()

Local lRet     := .T.                                                    	// Conteudo de retorno
Local nPosDesc := AScan( aHeader, { |x| Alltrim(x[2])=="KH_DESC"} ) 		// Descricao da Alternativa
Local nPosComp := AScan( aHeader, { |x| Alltrim(x[2])=="KH_POSCOMP"} ) 	// Possui Complemento
Local nTamCols := Len(aCols)  										// Quantidade de Registros - Filha
Local nUsado   := Len(aHeader)                                            	// Cabecalho dos campos

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerificaГУes antes da gravacao dos dados                                                             |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !oGetdSKH:aCols[n][nUsado+1] // Se o registro nЦo estiver deletado

	If VAL(M->KG_TIPOQST) <> DISSERTATIVA

	    If Empty(oGetdSKH:aCols[n][nPosDesc])
  		   Help("",1,"GPRA030_01") // HELP - Para as questoes de unica ou multipla escolha voce devera preencher a alternativa
		   lRet := .F.
		Endif                                                 

	    If oGetdSKH:aCols[n][nPosComp] == "1" // Questao com complemento = 1 - Sim

		   If VAL(M->KG_TIPOQST) == UNICA  .AND. VAL(M->KG_TIPEXIB) == COLUNAS   // UNICA ESCOLHA com exibicao em COLUNAS
  		      Help("",1,"GPRA030_02") // Nas questoes unica escolha exibidas em linhas, nao existe a possibilidade de utilizar complemento na alternativa
		      lRet := .F.
		   Endif
		   
		   If VAL(M->KG_TIPOQST) == MULTIPLA .AND. VAL(M->KG_TIPEXIB) == COLUNAS // MULTIPLA ESCOLHA com exibicao em COLUNAS
  		      Help("",1,"GPRA030_11") // HELP - Nas questУes unica escolha exibidas em colunas, nЦo existe a possibilidade de utilizar complemento na alternativa
		      lRet := .F.
		   Endif		   
		   
		Endif

	Endif
	
Endif

Return( lRet )

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁGp030TOk1 Ё Autor Ё Henry Fila            Ё Data Ё 22/02/05 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Criar validaГЦo para a aCols                               Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё GP030TOK1()                                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё SIGAGPR               							          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function Gp030TOk1()

Local lRet     := .T.                                                    	// Conteudo de retorno
Local nPosDesc := AScan( aHeader, { |x| Alltrim(x[2])=="KH_DESC"} ) 		// Descricao da Alternativa
Local nPosComp := AScan( aHeader, { |x| Alltrim(x[2])=="KH_POSCOMP"} ) 	// Possui Complemento
Local nInd     := 0	         											  	// Indexador de laco For/Next
Local nTamCols := Len(oGetdSKH:aCols)                                      	// Qtde de linas da aCols
Local nUsado   := Len(aHeader)                                            	// CabeГalho dos campos
Local lPosComp := .F.														// Se a alternativa possui complemento

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerificaГУes antes da gravacao dos dados                                                             |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If VAL(M->KG_TIPOQST) <> DISSERTATIVA

	For nInd:=1 To nTamCols
		//зддддддддддддддддддддд©
		//ЁSe a linha for validaЁ
		//юддддддддддддддддддддды    
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁVerifica se o registro esta deletado                                                                 |
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  !oGetdSKH:aCols[nInd][nUsado+1]                                                                     
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁVerifica se a descricao da alternativa ficou em branco                                               |
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If Empty(oGetdSKH:aCols[nInd][nPosDesc])
	  		   Help("",1,"GPRA030_01") // HELP - Para as questoes de unica ou multipla escolha voce devera preencher a alternativa
			   lRet := .F.
			   Exit
			Endif

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁAlternativa com complemento                                                                          |
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		    If oGetdSKH:aCols[nInd][nPosComp] == "1" 
   		       lPosComp:= .T. 
			Endif
		Endif
	Next nInd

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁSe a alternativa possuir complementos efetuar algumas consistencias, veja a descricao do help        |
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lPosComp
	   If M->KG_LIMCOMP == 0
		   Help("",1,"GPRA030_08") // HELP - Defina um valor para o limite de caracteres do complemento da alternativa
		   M->KG_LIMCOMP := CriaVar("KG_LIMCOMP")
		   lRet := .F.

	   ElseIf VAL(M->KG_TIPOQST) == UNICA .AND. VAL(M->KG_TIPEXIB) == DISSERTATIVA
		   Help("",1,"GPRA030_02") // HELP - Nas questoes unica escolha exibidas em linhas, nao existe a possibilidade de utilizar complemento na alternativa
		   lRet := .F.

	   ElseIf VAL(M->KG_TIPOQST) == MULTIPLA .AND. M->KG_TIPEXIB $ "23" // COLUNAS e DISSERTATIVA
		   Help("",1,"GPRA030_12") // HELP - Nas questoes multipla escolha, somente no tipo de exibicao sequencial e possivel utilizar complemento nas alternativas
		   lRet := .F.
	   Endif 

	Else
	   If M->KG_LIMCOMP > 0
		  Help("",1,"GPRA030_10") // HELP - Para alternativas sem complemento voce nao precisa definir limites de caracteres
		  M->KG_LIMCOMP := 0
		  lRet := .F.
	   Endif
	Endif
	
Endif

Return( lRet )

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁGp030LOk2 Ё Autor Ё Henry Fila            Ё Data Ё 22/02/05 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Criar validaГЦo para a cada linha da aCols                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё GP030LOK2()                                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё SIGAGPR               							          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function Gp030LOk2()

Local lRet     := .T.                                                      		// Conteudo de retorno
Local nPosDesc := AScan( aHeader, { |x| Alltrim(x[2])=="KI_DESC"} ) 			// Descricao da opГЦo
Local nUsado   := Len(aHeader)                                            		// CabeГalho dos campos

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se a questao for MULTIPLA ESCOLHA e o Tipo de exibicao for diferente do SEQUENCIALele devera  preencher as linhas ou colunas|
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If VAL(M->KG_TIPOQST) == MULTIPLA .AND. VAL(M->KG_TIPEXIB) <> SEQUENCIAL

	//здддддддддддддддддддддддддддддддддд©
	//ЁSe o Registro nao estiver deletadoЁ
	//юдддддддддддддддддддддддддддддддддды
	If !oGetdSKI:aCols[n][nUsado+1]
		If Empty(oGetdSKI:aCols[n][nPosDesc]) 		// Se a descricao da opГao nЦo ficou em branco
			Help("",1,"GPRA030_03") // HELP - Para as questoes exibidas em linhas e colunas voce deve preencher a descricao 
			lRet := .F.
		Endif
	Endif
Endif

Return( lRet )

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁGP030TOK2 Ё Autor Ё Henry Fila            Ё Data Ё 22/02/05 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Criar validacao para a aCols                               Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё GP030TOK2()                                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё SIGAGPR               							          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function Gp030TOk2()

Local lRet     := .T.                                                    	// Conteudo de retorno
Local nPosDesc := AScan( aHeader, { |x| Alltrim(x[2])=="KI_DESC"} ) 		// Descricao da Coluna
Local nTamCols := Len(oGetdSKI:aCols)  										// Quantidade de Registros - Filha
Local nUsado   := Len(aHeader)                                            	// CabeГalho dos campos
Local nInd     := 0															// Contador de laГo	
Local nQtdSKH  := 0															// Qtde de alternativas
Local nQtdSKI  := 0															// Qtde de linhas das alternativas

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se a questao for Multipla Escolha e o Tipo de ExibiГЦo for diferente do convencional ele devera     |
//Ё preencher as linhas ou colunas                                                                      |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If M->KG_TIPOQST == "2" .AND. M->KG_TIPEXIB <> "1"

	For nInd:=1 To nTamCols
		If  !oGetdSKI:aCols[nInd][nUsado+1] 			// Se o Registro nao estiver deletado
			If Empty(oGetdSKI:aCols[nInd][nPosDesc]) 	// Se a descricao da alternativa ficou em branco
			   lRet := .F.
			   Exit
			Endif
		Endif
	Next nInd

	If !lRet
 	    Help("",1,"GPRA030_03") // HELP - Para as questoes exibidas em linhas e colunas voce deve preencher a descricao 	
	Else
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁConta as linhas validas das Alternativas e Linhas                                             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aEval( oGetdSKH:aCols, { |x| nQtdSKH += IIF( !x[Len(x)], 1, 0 ) } )
		aEval( oGetdSKI:aCols, { |x| nQtdSKI += IIF( !x[Len(x)], 1, 0 ) } )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁPara questoes multipla escolha com exibicao em LINHAS e sem PERMISSAO DE REPETICAO DE RESPOSTAЁ
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If (VAL(M->KG_TIPEXIB) == DISSERTATIVA) .AND. (M->KG_REPETE == "2") .AND. (nQtdSKH > nQtdSKI)
		   Help("",1,"GPRA030_13")	// HELP - Para que as respostas nЦo sejam repetidas vocЙ deve cadastrar um numero de linhas igual ou superior ao das alternativas
		   lRet := .F.

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁPara questoes exibidas em colunas alertar qunato ao numero de colunas utilizadas pode atrapalhar o designЁ
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf VAL(M->KG_TIPEXIB) == COLUNAS .AND. nQtdSKI > 5 
		   lRet := MsgYesNo(STR0017) // "Foi ultrapassado o limite de 05 colunas nesta questao, o que podera prejudicar a visualizacao da mesma. Deseja continuar o processo ?"

		Endif 
		
	Endif
	
Endif

Return( lRet )


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁGpra030VldЁ Autor Ё Henry Fila            Ё Data Ё 22/02/05 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Efetua o controle de relacionamento entre o grupo e o      Ё╠╠
╠╠Ё          | subgrupo selecionado para a questao.                       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё GPRA030VLD()                                               Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё GPRA030 - SX3 - SKG                    	                  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function Gpra030Vld()

Local lRet        := .T.					// Retorno da funcao
Local cVar        := Alltrim( ReadVar() )	// Nome do Campo que contem essa validacao
Local cConteudo   := &cVar					// Conteudo digitado pelo usuario

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁSe o usuario alterar o codigo do questionario depois de ter escolhido o grupo ou subgrupoЁ
//Ёlimpo os campos para redigitacao, para garantir a integridade de relacionamento          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Do Case
		
	Case cVar == "M->KG_CODGRP"
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁVerifico se o grupo pertence ao questionario selecionado, caso a digitacao seja efetuada manualmenteЁ
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !Empty(cConteudo)
			DbSelectArea("SKE")
			DbSetOrder(1)
			If !DbSeek(xFilial("SKE")+M->KG_CODGRP)
				lRet := .F.
				Help( "", 1, "REGNOIS")
			Endif
		Else

			//здддддддддддддддддддддддд©
			//ЁApagar o Subgrupo tambemЁ
			//юдддддддддддддддддддддддды
			M->KG_DESCGRP := Space(TamSX3("KG_DESCGRP")[1])
			M->KG_CODSUBG := Space(TamSX3("KG_CODSUBG")[1])
			M->KG_DESCSUB := Space(TamSX3("KG_DESCSUB")[1])
		Endif
		
	Case cVar == "M->KG_CODSUBG"
		
		If !Empty(cConteudo)

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁVerifica se o grupo pertence ao questionario selecionado, caso a digitacao seja efetuada manualmente Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DbSelectArea("SKF")
			DbSetOrder(1)
			If !DbSeek(xFilial("SKF")+M->KG_CODGRP+M->KG_CODSUBG)
				lRet := .F.
				Help( "", 1, "REGNOIS") // HELP - Subgrupo selecionado nao pertence a este questionario e grupo
			Endif
		Else
			M->KG_DESCSUB := Space(TamSX3("KG_DESCSUB")[1])
		Endif
		
	Case cVar == "M->KG_TIPEXIB"

		If ( VAL(M->KG_TIPOQST) == DISSERTATIVA .AND. VAL(cConteudo) <> SEQUENCIAL ) .OR. ; // Dissertativas so podem ser do Tipo Convencional			
 	       ( VAL(M->KG_TIPOQST) == UNICA .AND. VAL(cConteudo) == COLUNAS )        			//  Unica escolha pode ser convencional ou linha
			Help("",1,"GPRA030_06") // HELP - Exibicao invalida para o tipo de questao selecionado
			lRet := .F.
		Endif

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁSe a questao for multipla escolha exibida em linhas                                                  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If	VAL(M->KG_TIPOQST) == MULTIPLA 	.AND.;
			VAL(cConteudo) == DISSERTATIVA 	.AND.;
			ValType(M->KG_REPETE) <> "U"

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁSe estiver em branco traz o valor default como sendo "Sim"                                           Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If Empty(M->KG_REPETE)
				M->KG_REPETE  := CriaVar("KG_REPETE",.F.)
			Else
				M->KG_REPETE  := M->KG_REPETE
			Endif
		Else
	  		If ValType(M->KG_REPETE) <> "U"                               	
		  		M->KG_REPETE  := SPACE(TamSX3("KG_REPETE")[1])
			Endif	  		
		Endif	

	OtherWise
		
		lRet := .T.
		
EndCase

Return( lRet )


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁGp030Ok   ЁAutor  ЁHenry Fila             Ё Data Ё22.02.2005Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁFuncao de validacao da Enchoicebar                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё GPRA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function Gp030Ok(aHeaderSKH,aColsSKH,aHeaderSKI,aColsSKI)

Local lRet 		:= .T.															// Retorno da funcao
Local nI		:= 2															// Variavel do For/Next
Local nPosCod   := AScan(aHeaderSKH, { |x| TRIM(x[2]) == "KH_CODALT" }) 		// Posicao do codigo da Alternativa
Local nPosPont  := AScan(aHeaderSKH, { |x| TRIM(x[2]) == "KH_PONTO" })  		// Posicao da pontuacao
Local nPontos  	:= 0															// Totalizador dos pontos
Local nLenAux	:= 0 															// Contador auxiliar do FOR	

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se as Questoes NAO sao DISSERTATIVAS                                                                Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If VAL(M->KG_TIPOQST) <> DISSERTATIVA 
    lRet := oGetdSKH:TudoOk()
    If lRet .And. VAL(M->KG_TIPOQST) == MULTIPLA .AND. VAL(M->KG_TIPEXIB) <> SEQUENCIAL
		lRet := oGetdSKI:TudoOk()
	Endif
Endif

If lRet .And. ( VAL(M->KG_TIPOQST) == DISSERTATIVA .OR. !Empty(M->KG_OBSERV) ) .AND. M->KG_LIMRESP == 0
	// HELP - Para as questoes dissertativas ou com observacoes defina um valor para o limite de caracteres nas respostas
	Help("",1,"GPRA030_09")
	lRet := .F.
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se existe codigo de alternativa repetidos                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
If lRet
	cSeq 	:= aColsSKH[1][1]
	nLenAux := Len(aColsSKH)
	
	For nI := 2 To nLenAux
	  If (cSeq == aColsSKH[nI][nPosCod])
	     Help("",1,"GPRA030_14") // Para nao deixar que ocorra questoes com codigos repertidos.
	     lRet:=.F.
	     
	     oGetdSKH:nat := nI
	     oGetdSKH:Refresh()
	     Exit
	  Else
	    cSeq := aColsSKH[nI][nPosCod]
	  Endif   
	
	Next nI
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Valida habilitar somente uma alternativa para questoes: "Unica escolha"   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRet
	lRet := GPR030Hab("2")
Endif	

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Valida a pontuacao proporciaonal da questoes                              Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRet .AND. !Empty(M->KG_PONTO)
    nPontos := 0

	nLenAux := Len(aColsSKH)
	For nI := 1 To nLenAux
    	If aColsSKH[nI][nPosPont] > 0
    	
	    	nPontos += aColsSKH[nI][nPosPont]
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Unica escolha tera o valor 100% em uma unica alternativa                  Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If (M->KG_TIPOQST == "1") .AND. (nPontos <> 100)   			//Unica Escolha/ Multipla escolha
			   Exit
			Endif    
		Endif	    
    Next nI

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё O total de pontuacao devera ser 100%                                      Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If (M->KG_TIPOQST $ "12") .AND. (nPontos <> 100)   //Unica Escolha/ Multipla escolha
		// HELP - Para nao deixar que ocorra questoes com codigos repertidos.
		Help("",1,"GPRA030_16") 
        lRet := .F.
	Endif
Endif

Return( lRet )


/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao   ЁGPR030Hab ЁAutor  ЁMarcos Alves           Ё Data Ё 13/07/04 Ё╠╠
╠╠лдддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╧╠╠
╠╠ЁDesc.    ЁValida habilitar somente uma alternativa para questoes      Ё╠╠
╠╠Ё         Ё"Unica Escolha"                                             Ё╠╠
╠╠цдддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe  Ё GPR030Hab(ExpC1)                                           Ё╠╠
╠╠цдддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametroЁ cExpC1 = Origem da Chamada da rotina, sendo:               Ё╠╠
╠╠Ё         Ё DEFINE SX3	  "1" - X3_VALID => KH_HABILIT. 			 Ё╠╠
╠╠Ё         Ё DEFINE SISTEMA  "2" - GPRA030.PRW - Gp030Ok()              Ё╠╠
╠╠цдддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠╨Retorno  ЁLogico                                                      Ё╠╠
╠╠цдддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠╨Uso      Ё SIGAGPR                                                    Ё╠╠
╠╠хмммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function GPR030Hab(cTipo)

Local lRet		:= .T.    			    											// Variavel de Retorno da funcao
Local nPosHab   := AScan(oGetDSKH:aHeader, { |x| TRIM(x[2]) == "KH_HABILIT" }) 	// Posicao do campo Habilita
Local nHab		:= 0                       							   				// Contador		
Local aColsAux	:= aClone(oGetdSKH:aCols)											// aCols Auxiliar

DEFAULT cTipo	:= SX3

If cTipo == "1"
   If M->KH_HABILIT == "2"
    	Return( lRet )
   Else	
		If aColsAux[n][nPosHab] <> "1"
			nHab ++
		Endif	
   Endif	
Endif      

If 	(VAL(M->KG_TIPOQST) == UNICA .AND. nHab > 1) .OR. ;
	(VAL(M->KG_TIPOQST) == MULTIPLA .AND. !Empty(M->KG_LIMSELE) .AND. nHab > M->KG_LIMSELE) 
	
	Help("",1,"GPRA030_15") // HELP - Valida as alternativa de unica escolha para habilitar apenas uma alternativa.
	lRet:=.F.
Endif

Return( lRet )

/*              
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбддддддддддд©╠╠
╠╠ЁFun┤┘o	 Ёa360SimCndЁ Autor Ё Henry Fila            Ё Data Ё 23.10.03  Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддаддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Rotina para simulacao de condicao de pagamento              Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe	 Ё a360SimCnd()                                                Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                      Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё Generico 										           Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					   Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS Ё	MOTIVO DA ALTERACAO					   Ё╠╠
╠╠цддддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁTatiana       Ё11/11/06Ё110046ЁAlteracao do wizard para validaГЦo do    Ё╠╠ 
╠╠Ё              Ё        Ё      Ёsubgrupo via F3                          Ё╠╠
╠╠ЁConrado Q.    Ё18/06/06Ё127771ЁCorreГЦo na validaГЦo do wizard na validaЁ╠╠ 
╠╠Ё              Ё        Ё      ЁГЦo do subgrupo via F3                   Ё╠╠
╠╠юддддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Function Gpra030Wiz()


Local aArea      := GetArea()  									// Armazena area atual
Local aCombo1    := {STR0020,STR0021,STR0022}               	// Array do combo de opcoes de pesquisa
Local aCombo2    := {STR0023,STR0024,STR0025} 					// Array do combo de opcoes de exibicao das questoes
Local aCombo3    := {STR0026,STR0027}                       	// Array do combo de opcoes de obrigatoriedade da questao 
Local aRecnoSKH  := {}  										// Array de registro de colunas
Local aHeaderSKH := {}  										// Colunas das alterantivas
Local aColsSKH   := {}  										// Itens das alternativas
Local aRecnoSKI  := {}  										// Array de registro de colunas
Local aHeaderSKI := {}  										// Colunas das opcoes 
Local aColsSKI   := {}  										// Itens das Opcoes 

Local cCombo1    := "" 											// Armazena o conteudo do combo de tipo de questoes
Local cCombo2    := "" 											// Armazena o conteudo do combo de metodos de exibicao 
Local cCombo3    := "" 											// Armazena o conteudo de obrigatoriedade da questao 
Local cQuestao   := Space(80) 									// Variavel da descricao da questao
Local cObserv    := Space(Len(SKG->KG_OBSERV)) 					// Observacao do complemento 
Local cSubGrupo  := Space(Len(SKG->KG_CODSUBG)) 				// Subgrupo private para ativacao na consulta e filtro SXB
Local cObjetivo  := Space(80)                                   // Campo MEMO de "Objetivos" do folder "Objetivo"

Local nLimResp   := 999 										// Variavel de limite de resposta de questoes dissertativas
Local nLimCompl  := 99 											// Limite maximo de caracteres do complemento
Local nLimSele   := 99
Local nQtdAlter  := 0 											// Limite de alternativas disponiveis para selecao
Local nOpca      := 0 											// Variavel de confirmacao do wizard
Local nSaveSx8   := GetSx8Len() 								// Controle do SX8
Local nPontuacao := 0

Local oWizard 													// Objeto do wizard 
Local oCombo1 													// Objeto do combo de opcoes de pesquisa
Local oCombo2 													// Objeto do combo de metodos de exibicao     
Local oCombo3 													// Objeto do combo de obrigatoriedade 

Private cGrupo := Space(Len(SKG->KG_CODGRP))						// Variavel com o "Grupo" das questoes (SKE)
           
//здддддддддддддддддддддддддддд©
//ЁAjusta consulta padrЦo SKF3.Ё
//юдддддддддддддддддддддддддддды

RegToMemory( "SKG",  .T. )

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta aHeader e aCols das colunas das alternativas                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Gpr030CSKH( aHeaderSKH, aColsSKH, , IIF(Altera .OR. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE,0) )

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta aHeader e aCols das colunas das alternativas                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Gpr030CSKI( aHeaderSKI, aColsSKI, , IIF(Altera .OR. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE,0) )

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё PANEL 1 - Monta wizard de questoes                                        Ё
//Ё      PANEL ANTERIOR - NENHUM                                              Ё	
//Ё      PROXIMA PANEL  - 2                                                   Ё	
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE WIZARD oWizard TITLE STR0028 HEADER STR0029 ; //Wizard de criacao de questoes###"Modelo de questao"
		MESSAGE STR0030; //Nesta etapa deve-se informar o modelo de questao a ser utilizada em uma determinada pesquisa
		TEXT " "; 
		NEXT {|| .T.} ;
		PANEL NOFIRSTPANEL 

	oWizard:GetPanel(1)

	@ 15,20 SAY STR0031 OF oWizard:GetPanel(1) SIZE 90,8 PIXEL  //Informe o modelo da questao
	@ 25,20 MSCOMBOBOX oCombo1 VAR cCombo1 ITEMS aCombo1 SIZE 100,44  VALID .T. OF oWizard:GetPanel(1) SIZE 60,8 PIXEL

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё PANEL 2 - Monta painel de descricao da questao                            Ё
	//Ё      PANEL ANTERIOR - 1                                                   Ё	
	//Ё      PROXIMA PANEL                                                        Ё	
	//Ё          SE DISSERTATIVA - 8                                              Ё		
	//Ё          SE UNICA OU MULTIPLA ESCOLHA - 3                                 Ё			
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	CREATE PANEL oWizard  HEADER STR0032 ; //"Elaboracao da questao"
		MESSAGE STR0070 + CRLF +;   //"Nesta etapa deve-se elaborar a questao e especificar sua pontuacao."
		        STR0071 + CRLF +;	//"Caso haja alguma pontuacao, deve-se informar a sua distribuicao de pontos nas "
		        STR0072;			//"alternativas, linhas ou colunas."
		BACK {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .F., nLimCompl) ), oWizard:nPanel += 1 , .T. } ;
		NEXT {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .T., nLimCompl) ), oWizard:nPanel -= 1 , .T. } ;
		PANEL

	oWizard:GetPanel(2)

	@ 15,20 SAY STR0034 OF oWizard:GetPanel(2) SIZE 90,8 PIXEL  //"Descreva a questao"
	@ 25,20 GET cQuestao OF oWizard:GetPanel(2)  MEMO SIZE 200,40 When .T. PIXEL

	@ 75,20 SAY STR0069 OF oWizard:GetPanel(2) SIZE 90,8 PIXEL  //"Pontuacao"
	@ 85,20 MSGET nPontuacao  Valid Gpr030Pont(nPontuacao) Picture "@E 999.99" OF oWizard:GetPanel(2)  SIZE 60,10 When .T. PIXEL

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё PANEL 3 - Monta painel de modelos de exibicao da questao                        Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	CREATE PANEL oWizard  HEADER STR0035 MESSAGE STR0036 ;  //"Nesta etapa deve-se configurar o metodo de exibicao das alternativas da questao"
		BACK {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .F., nLimCompl) ), oWizard:nPanel += 1, .T. } ; 
		NEXT {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .T., nLimCompl) ), oWizard:nPanel -= 1, .T. } ;
		PANEL

	oWizard:GetPanel(3)

	@ 15,20 SAY STR0037 OF oWizard:GetPanel(3) SIZE 120,8 PIXEL  //"Informe o metodo de exibicao das alternativas"
	@ 25,20 MSCOMBOBOX oCombo2 VAR cCombo2 ITEMS aCombo2 SIZE 100,44  VALID .T. OF oWizard:GetPanel(3) SIZE 60,8 PIXEL

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё PANEL 4 - Monta painel de modelos de cadastro das alternativas                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	CREATE PANEL oWizard  HEADER STR0038 MESSAGE STR0039 ; 
			BACK {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .F., nLimCompl) ) ,oWizard:nPanel += 1, .T. } ;
			NEXT {|| Gpr030Compl( oGetdSKH:aHeader, oGetdSKH:aCols, @nLimCompl ), oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .T., nLimCompl ) ), oWizard:nPanel -= 1, .T. } ;
			PANEL

	oWizard:GetPanel(4)

	@ 03,02 SAY STR0040 OF oWizard:GetPanel(4) SIZE 120,8 PIXEL  //"Informe as alternativas da questao"
	oGetdSKH := MsNewGetDados():New(10,2,130,280,IIF(Altera .OR. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE,0),"AllwaysTrue()","AllwaysTrue()","+KH_CODALT",,,MAXGETDAD,,,,oWizard:GetPanel(4),aHeaderSKH,aColsSKH)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё PANEL 7 - Monta painel de modelos das linhas ou colunas                   Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	CREATE PANEL oWizard  HEADER STR0041 MESSAGE STR0042 ; //"Linhas ou Colunas"##"Nesta etapa deve-se configurar as linhas ou colunas das alternativas"
		BACK {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .F., nLimCompl) ), oWizard:nPanel += 1, .T. } ;                     
		NEXT {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .T., nLimCompl) ), oWizard:nPanel -= 1, .T. } ;						
		PANEL

	oWizard:GetPanel(5)

	@ 03,02 SAY STR0043 OF oWizard:GetPanel(5) SIZE 120,8 PIXEL  
	oGetdSKI := MsNewGetDados():New(10,2,130,280,IIF(Altera .OR. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE,0),"AllwaysTrue()","AllwaysTrue()","+KI_CODCOL",,,MAXGETDAD,,,,oWizard:GetPanel(5),aHeaderSKI,aColsSKI)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё PANEL 6 - Monta painel de dados complementares da questao                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	CREATE PANEL oWizard  HEADER STR0044 MESSAGE STR0045 ; //"Dados complementares"###"Nesta etapa deve-se informar o complemento da questao caso seja necessario"
		BACK {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .F., nLimCompl) ), oWizard:nPanel += 1, .T.} ;
		NEXT {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .T., nLimCompl) ), oWizard:nPanel -= 1, .T.} ;
		PANEL

	oWizard:GetPanel(6)

	@ 15,20 SAY STR0046 OF oWizard:GetPanel(6) SIZE 90,8 PIXEL  //"Limite de caracteres do complemento"
	@ 25,20 GET nLimCompl OF oWizard:GetPanel(6) Picture "99" SIZE 60,10 When .T. PIXEL


	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё PANEL 7 - Monta painel de Caracteristivas da questao Multipla Escolha     Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	CREATE PANEL oWizard  HEADER STR0047 ;
		MESSAGE STR0048 ; 
		BACK {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .F., nLimCompl) ), oWizard:nPanel += 1, .T.} ;		
		NEXT {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .T., nLimCompl) ), oWizard:nPanel -= 1, .T.} ;
		PANEL

	oWizard:GetPanel(7)

	@ 15,20 SAY STR0049 OF oWizard:GetPanel(7) SIZE 150,8 PIXEL  //"Quantidade de alternativas permitidas"
	@ 25,20 GET nLimSele OF oWizard:GetPanel(7)  SIZE 60,10 When .T. PIXEL

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё PANEL 8 - Monta painel de Limite das repostas dissertativas               Ё 
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	CREATE PANEL oWizard  HEADER STR0050 ;
		MESSAGE STR0051 ; //"Nesta etapa deve-se informar o limite maximo de caracteres de resposta da questao dissertativa"
		BACK {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .F., nLimCompl) ), oWizard:nPanel += 1, .T. } ;
		NEXT {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .T., nLimCompl) ), oWizard:nPanel -= 1, .T. } ;		
		PANEL

	oWizard:GetPanel(8)

	@ 15,20 SAY STR0052 OF oWizard:GetPanel(8) SIZE 90,8 PIXEL  //"Limite da caracteres"
	@ 25,20 MSGET nLimResp OF oWizard:GetPanel(8)  SIZE 60,10 When .T. PIXEL

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё PANEL 9 - Monta painel de Relacionamento com grupos e subgrupos           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	CREATE PANEL oWizard  HEADER STR0053 ; //"Relacionamento Grupo / Subgrupo"
		MESSAGE STR0054 ;  //"Nesta etapa deve-se informar se a questao fara parte de algum grupo e subgrupo de questoes"
		BACK {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .F., nLimCompl) ), oWizard:nPanel += 1, .T. } ;
		NEXT {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .T., nLimCompl) ), oWizard:nPanel -= 1, .T. } ;		
		PANEL

	oWizard:GetPanel(9)

	@ 15,20 SAY STR0055 OF oWizard:GetPanel(9) SIZE 90,8 PIXEL  //"Grupo"
	@ 25,20 MSGET cGrupo F3 "SKE" OF oWizard:GetPanel(9)  SIZE 60,10 When .T. PIXEL

	@ 45,20 SAY STR0056 OF oWizard:GetPanel(9) SIZE 90,8 PIXEL  //"Subgrupo"
	@ 55,20 MSGET cSubGrupo F3 "SKF3" OF oWizard:GetPanel(9)  SIZE 60,10 When .T. PIXEL

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё PANEL 10 - Monta painel de Observacao da questao                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	CREATE PANEL oWizard  HEADER STR0057 ; //"Observacao da questao"
		MESSAGE STR0058 ; //"Nesta etapa deve-se informar a observacao da questao"
		BACK {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .F., nLimCompl) ) ,oWizard:nPanel += 1, .T. } ;
		NEXT {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .T., nLimCompl) ) ,oWizard:nPanel -= 1, .T. } ;
		PANEL

	oWizard:GetPanel( 10 )

	@ 15,20 SAY STR0059 OF oWizard:GetPanel(10) SIZE 90,8 PIXEL  //"Observacao"
	@ 25,20 GET cObserv OF oWizard:GetPanel(10)  MEMO SIZE 200,40 When .T. PIXEL

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё PANEL 11 - Monta painel de Objetivo da questao                            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	CREATE PANEL oWizard  HEADER STR0063 ; //"Objetivo da questao"
		MESSAGE STR0073 + CRLF + ; 	//"Nesta etapa deve-se informar o objetivo da questЦo para esclarecer o entrevistador ou "
		        STR0074;			//"pesquisador sobre a finalidade da questЦo."
		BACK {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .F., nLimCompl) ) ,oWizard:nPanel += 1, .T. } ;
		NEXT {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .T., nLimCompl) ) ,oWizard:nPanel -= 1, .T. } PANEL

	oWizard:GetPanel( 11 )

	@ 15,20 SAY STR0063 OF oWizard:GetPanel(11) SIZE 90,8 PIXEL  //"Questao obrigatoria na pesquisa ?"
	@ 25,20 GET cObjetivo OF oWizard:GetPanel(11)  MEMO SIZE 200,40 When .T. PIXEL


	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё PANEL 12 - Monta painel de Obrigatoriedade da questao                     Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	CREATE PANEL oWizard  HEADER STR0060 ; //"Obrigatoriodade da questao"
		MESSAGE STR0061 ; //"Nesta etapa deve-se informar se a questao sera obrigatoria ou nao"
		BACK {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .F., nLimCompl) ) ,oWizard:nPanel += 1, .T. } ;
		NEXT {|| oWizard:SetPanel( Gpr030WzFlow( cCombo1, cCombo2, oWizard:nPanel, .T., nLimCompl) ) ,oWizard:nPanel -= 1, .T. } ;
		FINISH {|| aColsSKH:=oGetdSKH:aCols, aColsSKI:=oGetdSKI:aCols, If( Gpr030WzVld( cCombo1, cCombo2, cQuestao ) ;
		.AND. Gpr030VldPonto( oGetdSKH:aHeader, oGetdSKH:aCols, nPontuacao, cCombo1 ), nOpca := 1,), nOpca == 1 } PANEL

	oWizard:GetPanel( 12 )

	@ 15,20 SAY STR0062 OF oWizard:GetPanel(12) SIZE 90,8 PIXEL  //"Questao obrigatoria na pesquisa ?"
	@ 25,20 MSCOMBOBOX oCombo3 VAR cCombo3 ITEMS aCombo3 SIZE 100,44  VALID .T. OF oWizard:GetPanel(12) SIZE 40,8 PIXEL

	
ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.}

If nOpca == 1

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa desta forma para criar uma nova instancia de variaveis de memoriaЁ
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	M->KG_TIPOQST := cCombo1
	M->KG_TIPEXIB := cCombo2        
	M->KG_COMPLEM := cQuestao
	M->KG_CODGRP  := cGrupo
	M->KG_CODSUBG := cSubGrupo   
	M->KG_LIMRESP := nLimResp
	M->KG_LIMCOMP := nLimCompl
	M->KG_LIMSELE := nLimSele 
	M->KG_OBSERV  := cObserv
	M->KG_OBRIGAT := cCombo3
	M->KG_OBJETIV := cObjetivo
	M->KG_PONTO   := nPontuacao 
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava a questao                                                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Gpr030Grv(	1			,aRecnoSKI		,aHeaderSKI		,aColsSKI	,;
				aRecnoSKH	,aHeaderSKH		,aColsSKH)	

	While (GetSx8Len() > nSaveSx8 )
		ConfirmSx8()
	End
	EvalTrigger()
Else
	While (GetSx8Len() > nSaveSx8 )		
		RollBackSx8()	
	End		
Endif

RestArea(aArea)

Return( .T. )


/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбддддддддддддддддддддбддддддбддддддддддд©╠╠
╠╠ЁFun┤ao	 ЁGpr030Compl  Ё Autor Ё Cleber Martinez    Ё Data Ё 12.04.05  Ё╠╠
╠╠цддддддддддедддддддддддддадддддддаддддддддддддддддддддаддддддаддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Valida/Ajusta o limite de complemento da questao            Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe	 Ё Grp030Compl()                                               Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpC1 - aHeader		                                       Ё╠╠
╠╠Ё          Ё ExpC2 - aCols                                               Ё╠╠
╠╠Ё          Ё ExpL4 - nLimCompl                                           Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё Generico 										           Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					   Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS Ё	MOTIVO DA ALTERACAO					   Ё╠╠
╠╠цддддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function Gpr030Compl(aHeader,aCols,nLimCompl)

Local nX := 1
Local nPosComp := AScan( aHeader, { |x| Alltrim(x[2])=="KH_POSCOMP"} ) 	// Possui Complemento
Local nUsado := Len(aHeader)
Local lRet := .T.

For nX := 1 To Len(aCols)
	If !aCols[nX][nUsado+1] //Se o registro nao estiver deletado
		If aCols[nX][nPosComp] == "1" // Questao com complemento = 1 - Sim
			If nLimCompl == 0
				nLimCompl := 99
			Endif
			Exit
		Else
			nLimCompl := 0
		Endif
	Endif
Next

Return (lRet)

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбддддддддддддддддддддбддддддбддддддддддд©╠╠
╠╠ЁFun┤ao	 ЁGpr030VldPontЁ Autor Ё Cleber Martinez    Ё Data Ё 12.04.05  Ё╠╠
╠╠цддддддддддедддддддддддддадддддддаддддддддддддддддддддаддддддаддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Valida a soma dos pontos das alternativas                   Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe	 Ё Grp030Compl()                                               Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpC1 - aHeader		                                       Ё╠╠
╠╠Ё          Ё ExpC2 - aCols                                               Ё╠╠
╠╠Ё          Ё Expn3 - nPontuacao                                          Ё╠╠
╠╠Ё          Ё ExpC4 - Tipo da Questao                                     Ё╠╠
╠╠Ё          Ё         1 - Unica escolha                                   Ё╠╠
╠╠Ё          Ё         2 - Multipla escolha                                Ё╠╠
╠╠Ё          Ё         3 - Dissertativa                                    Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё Generico 										           Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					   Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS Ё	MOTIVO DA ALTERACAO					   Ё╠╠
╠╠цддддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Luiz Couto   Ё25.08.05Ё2761  Ё- So faz a contagem de pontos das        Ё╠╠
╠╠Ё              Ё        Ё      Ёalternativas se a questao for do tipo    Ё╠╠
╠╠Ё              Ё        Ё      Ёdiferente de dissertativa.               Ё╠╠
╠╠Ё Luiz Couto   Ё29.08.05Ё2742  Ё- Se a questao for UNICA ESCOLHA, o valorЁ╠╠
╠╠Ё              Ё        Ё      Ёda questao И o maximo, ou seja, nao ha   Ё╠╠
╠╠Ё              Ё        Ё      Ёrateio, logo, a alternativa deve ter     Ё╠╠
╠╠Ё              Ё        Ё      Ёpontuacao de 100.                        Ё╠╠
╠╠Ё Andre Veiga  Ё05.01.06Ё091132Ё- Nao estava considerando a somatoria dosЁ╠╠
╠╠Ё              Ё        Ё      Ёpontos corretamente para questoes de     Ё╠╠
╠╠Ё              Ё        Ё      Ёmultipla escolha.                        Ё╠╠
╠╠Ё              Ё        Ё      Ё                                         Ё╠╠
╠╠юддддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function Gpr030VldPonto( aHeader, aCols, nPontuacao, cTipo )

Local nX 			:= 1
Local nPosPonto		:= AScan( aHeader, { |x| Alltrim( x[2] )=="KH_PONTO" } )
Local nUsado 		:= Len(aHeader)
Local lRet 			:= .T.
Local nSomaPontos 	:= 0

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁSo verifica a pontuacao caso a questao seja diferente de DissertativaЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cTipo <> "3"
	If nPontuacao <> 0
		For nX := 1 To Len( aCols )
			//здддддддддддддддддддддддддддддддддд©
			//ЁSe o registro nao estiver deletadoЁ
			//юдддддддддддддддддддддддддддддддддды
			If !aCols[nX][nUsado + 1]
				//здддддддддддддддддддддддддддддддддддддддддддддддд©
				//ЁTotaliza os pontos distribuidos nas alternativasЁ
				//юдддддддддддддддддддддддддддддддддддддддддддддддды
				nSomaPontos += aCols[nX][nPosPonto]

				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Unica escolha tera o valor 100% em uma unica alternativa                  Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If ( cTipo == "1" ) .And. ( nSomaPontos <> 100 .And. nSomaPontos <> 0  )   //Unica Escolha
				   Exit
				Endif    
			Endif
		Next
	    
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё O total de pontuacao devera ser 100%                                      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ( cTipo $ "12" ) .AND. ( nSomaPontos <> 100 )   //Unica Escolha/ Multipla escolha
			Help( "", 1, "GPRA030_16" ) //A soma total dos pontos das alternativas deve ser igual a 100.
			lRet := .F.
		Endif
	Endif
Endif

Return ( lRet )


/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбддддддддддддддддддддбддддддбддддддддддд©╠╠
╠╠ЁFun┤┘o	 ЁGrp030WzFlow Ё Autor Ё Henry Fila         Ё Data Ё 23.10.03  Ё╠╠
╠╠цддддддддддедддддддддддддадддддддаддддддддддддддддддддаддддддаддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Fluxo de panels do wizard                                   Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe	 Ё Gpr030WzFlow()                                              Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpC1 - Tipo da questao                                     Ё╠╠
╠╠Ё          Ё ExpC2 - Exibicao                                            Ё╠╠
╠╠Ё          Ё ExpL4 - Questao                                             Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё Generico 										           Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					   Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS Ё	MOTIVO DA ALTERACAO					   Ё╠╠
╠╠цддддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function Gpr030WzVld( cTipo, cExibicao, cQuestao )

Local lRet := .T. //Variavel de retorno da funcao

If Empty( cQuestao )
	Help( " ",1 ,"GPR030QST" ) //
	lRet := .F.
Endif	

If lRet
	If cTipo == "1" .AND. cExibicao == "2"
		Help( " ",1 ,"GPR030COL" ) //Questoes de unica escolha somente podem ter o modelo de exibicao Sequencial ou em Linhas
		lRet := .F. 
	Endif
Endif

Return( lRet )

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбддддддддддддддддддддбддддддбддддддддддд©╠╠
╠╠ЁFun┤┘o	 ЁGrp030WzFlow Ё Autor Ё Henry Fila         Ё Data Ё 23.10.03  Ё╠╠
╠╠цддддддддддедддддддддддддадддддддаддддддддддддддддддддаддддддаддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Fluxo de panels do wizard                                   Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe	 Ё Gpr030WzFlow()                                              Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpC1 - Tipo da questao                                     Ё╠╠
╠╠Ё          Ё ExpC2 - Modelo de Exibicao                                  Ё╠╠
╠╠Ё          Ё ExpC3 - Painel atual                                        Ё╠╠
╠╠Ё          Ё ExpL4 - Se opcao escolhida Next ou Back                     Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё Generico 										           Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					   Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS Ё	MOTIVO DA ALTERACAO					   Ё╠╠
╠╠цддддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Luiz Couto   Ё25.08.05Ё2762  Ё- Caso a questao selecionada seja        Ё╠╠
╠╠Ё              Ё        Ё      ЁUNICA ESCOLHA e COLUNAS mostra um help   Ё╠╠
╠╠Ё              Ё        Ё      Ёde exibicao invalida para o tipo de ques-Ё╠╠
╠╠Ё              Ё        Ё      Ёtao selecionado.                         Ё╠╠
╠╠юддддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function Gpr030WzFlow(cTipo,cShowType,nPanel,lNext, nLimCompl)

Local aFlow     := {} //Array do fluxo de panels do wizard

Local nPanelRet := 0  //Retorno da funcao
Local nPosFlow  := 0  //Posicao da operacao realizada

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se a questao selecionada И UNICA ESCOLHA em COLUNAS.   Ё
//ЁSe for, gera um help, pois nЦo И permitido este tipo de escolha.Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cTipo == "1" .AND. cShowType == "2" .AND. nPanel == 3
	Help( "", 1, "GPRA030_06" ) // HELP - Exibicao invalida para o tipo de questao selecionado	
Endif
	
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁEstrutura do array aFlow                                                   Ё
//Ё   [1]-Tipo da questao (Unica escolha/Multipla Escolha/Dissertativa        Ё	
//Ё   [2]-Modelo de exibicao (Sequencial/Coluna/Linha)                        Ё	
//Ё   [3]-Panel atual                                                         Ё	
//Ё   [3]-Panel caso seja selecionado Next                                    Ё	
//Ё   [4]-Panel caso seja selecionado Back                                    Ё	
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFluxo Unica Escolha Sequencial                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AAdd(aFlow,{"1","1",01,02,01})
AAdd(aFlow,{"1","1",02,03,01})
AAdd(aFlow,{"1","1",03,04,02})

If nLimCompl > 0
	AAdd(aFlow,{"1","1",04,06,03})
	AAdd(aFlow,{"1","1",06,09,04})
	AAdd(aFlow,{"1","1",09,10,06})
	AAdd(aFlow,{"1","1",10,11,09})
	AAdd(aFlow,{"1","1",11,12,10})
	AAdd(aFlow,{"1","1",12,12,11})
Else	                           
	AAdd(aFlow,{"1","1",04,09,03})
	AAdd(aFlow,{"1","1",09,10,04})
	AAdd(aFlow,{"1","1",10,11,09})
	AAdd(aFlow,{"1","1",11,12,10})
	AAdd(aFlow,{"1","1",12,12,11})
Endif


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFluxo Unica Escolha Colunas (Tratamento especial pois nao e possivel       Ё
//Ёessa combinacao                                                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AAdd(aFlow,{"1","2",01,02,01})
AAdd(aFlow,{"1","2",02,03,01})
AAdd(aFlow,{"1","2",03,03,02}) //Nao deixa passar para frente pois nao e possivel a combinacao

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFluxo Unica Escolha em Linha                                               Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AAdd(aFlow,{"1","3",01,02,01})
AAdd(aFlow,{"1","3",02,03,01})
AAdd(aFlow,{"1","3",03,04,02})
AAdd(aFlow,{"1","3",04,09,03})
AAdd(aFlow,{"1","3",09,10,04}) 
AAdd(aFlow,{"1","3",10,11,09}) 
AAdd(aFlow,{"1","3",11,12,10})
AAdd(aFlow,{"1","3",12,12,11})

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFluxo Mulplica escolha sequencia                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AAdd(aFlow,{"2","1",01,02,01})
AAdd(aFlow,{"2","1",02,03,01})
AAdd(aFlow,{"2","1",03,04,02})
AAdd(aFlow,{"2","1",04,06,03})
AAdd(aFlow,{"2","1",06,07,04})
AAdd(aFlow,{"2","1",07,09,06})
AAdd(aFlow,{"2","1",09,10,07})
AAdd(aFlow,{"2","1",10,11,09}) 
AAdd(aFlow,{"2","1",11,12,10})
AAdd(aFlow,{"2","1",12,12,11})


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFluxo Mulplica escolha Colunas                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AAdd(aFlow,{"2","2",01,02,01})
AAdd(aFlow,{"2","2",02,03,01})
AAdd(aFlow,{"2","2",03,04,02})
AAdd(aFlow,{"2","2",04,05,03})
AAdd(aFlow,{"2","2",05,09,04})
AAdd(aFlow,{"2","2",09,10,05})
AAdd(aFlow,{"2","2",10,11,09})
AAdd(aFlow,{"2","2",11,12,10})
AAdd(aFlow,{"2","2",12,12,11})


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFluxo Mulplica escolha Linhas                                              Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AAdd(aFlow,{"2","3",01,02,01})
AAdd(aFlow,{"2","3",02,03,01})
AAdd(aFlow,{"2","3",03,04,02})
AAdd(aFlow,{"2","3",04,05,03})
AAdd(aFlow,{"2","3",05,09,04})
AAdd(aFlow,{"2","3",09,10,05})
AAdd(aFlow,{"2","3",10,11,09})
AAdd(aFlow,{"2","3",11,12,10})
AAdd(aFlow,{"2","3",12,12,11})

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFluxo Unica Dissertativa                                                   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AAdd(aFlow,{"3","1",01,02,01})
AAdd(aFlow,{"3","1",02,08,01})
AAdd(aFlow,{"3","1",08,09,02})
AAdd(aFlow,{"3","1",09,11,08})
AAdd(aFlow,{"3","1",11,12,09})
AAdd(aFlow,{"3","1",12,12,11})

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁBusca a posicao dos tipos e exibicoes para buscar folder proximo ou anterior  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nPosFlow := AScan( aFlow, { |x| x[1]==cTipo .AND. x[2] == cShowType .AND. x[3] == nPanel} ) 		// Descricao da Alternativa

If nPosFlow > 0
	nPanelRet := aFlow[nPosFlow][If(lNext,4,5)]
Endif	

Return( nPanelRet )

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбддддддддддддддддддддбддддддбддддддддддд©╠╠
╠╠ЁFun┤┘o	 ЁGrp030Pont   Ё Autor Ё Henry Fila         Ё Data Ё 23.10.03  Ё╠╠
╠╠цддддддддддедддддддддддддадддддддаддддддддддддддддддддаддддддаддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Validacao da variavel de ponto do wizard                    Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe	 Ё Gpr030Pont()                                                Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpN1 - Ponto da questao                                    Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё Generico 										           Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					   Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS Ё	MOTIVO DA ALTERACAO					   Ё╠╠
╠╠цддддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function Gpr030Pont( nPontuacao )

Local nX       := 0                                                         //Variavel contador For
Local nPosPonto:= AScan( oGetdSKH:aHeader, { |x| Alltrim(x[2])=="KH_PONTO"} ) 		// Descricao da Alternativa

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Carrega variavel de memoria para tratamento de alternativas               Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

M->KG_PONTO := nPontuacao

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Caso seja zerada a pontuacao zera a distribuicao entre as alternativas    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( M->KG_PONTO == 0 )

	For nX := 1 To Len( oGetdSKH:aCols )
		oGetdSKH:aCols[nX][nPosPonto] := 0
	Next nX

Endif

Return( .T. )

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбддддддддддд©╠╠
╠╠ЁFun┤┘o	 ЁGrp030CSKHЁ Autor Ё Henry Fila            Ё Data Ё 23.10.03  Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддаддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Para montagem do acols do SKH                               Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe	 Ё Gpr030CSKH()                                                Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                      Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё Generico 										           Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					   Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS Ё	MOTIVO DA ALTERACAO					   Ё╠╠
╠╠цддддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁConrado Q.    |29/01/07Ё115967|- Montagem do aCols e aHeader atravИs    Ё╠╠
╠╠Ё              Ё        Ё      |da rotina FillGetDados.                  Ё╠╠
╠╠юддддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function Gpr030CSKH( aHeaderSKH, aColsSKH, aRecnoSKH, nOpc)

Local cSeek			:= ""			// Seek para montagem do aCols
Local cWhile		:= ""			// While para montagem do aCols
Default aRecnoSKH	:= {}			// Registros selecionados

//зддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta aHeader e aCols das Regras da PesquisaЁ
//юддддддддддддддддддддддддддддддддддддддддддддды
aHeader	:= {}
aCols	:= {}

If !INCLUI
	cSeek := xFilial("SKH")+SKG->KG_CODQST
	cWhile:= "SKH->KH_FILIAL+SKH->KH_CODQST"

	FillGetDados(	nOpc			,"SKH"			,1											,cSeek				,;
	   				{|| &cWhile }	,{|| .T. }		,/*aNoFields*/								,/*aYesFields*/		,; 
	   				/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/								,/*lEmpty*/			,;
	   				/*aHeaderAux*/	,/*aColsAux*/	,{|| GPR030AfterCols( "SKH", aRecnoSKH ) }	,/*bBeforeCols*/	)
			   				
Else
	FillGetDados(	nOpc			,"SKH"		,1				,/*cSeek*/		,;
					/*{||&cWhile}*/	,{|| .T. }	,/*aNoFields*/	,/*aYesFields*/	,; 
					/*lOnlyYes*/	,/*cQuery*/	,/*bMontCols*/	,.T.			)
EndIf

If Empty( aCols[ 1 ][ GdFieldPos("KH_CODALT") ] )
	aCols[ 1 ][ GdFieldPos("KH_CODALT") ]	 := StrZero(1,Len(SKH->KH_CODALT))
EndIf

aHeaderSKH	:= aClone( aHeader )
aColsSKH	:= aClone( aCols )

Return( .T. )

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбддддддддддд©╠╠
╠╠ЁFun┤┘o	 ЁGrp030CSKIЁ Autor Ё Henry Fila            Ё Data Ё 23.10.03  Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддаддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Para montagem do acols do SKI                               Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe	 Ё Gpr030CSKI()                                                Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                      Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё Generico 										           Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					   Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS Ё	MOTIVO DA ALTERACAO					   Ё╠╠
╠╠цддддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁConrado Q.    |29/01/07Ё115967|- Montagem do aCols e aHeader atravИs    Ё╠╠
╠╠Ё              Ё        Ё      |da rotina FillGetDados.                  Ё╠╠
╠╠юддддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function Gpr030CSKI( aHeaderSKI, aColsSKI, aRecnoSKI, nOpc)

Local cSeek			:= ""			// Seek para montagem do aCols
Local cWhile		:= ""			// While para montagem do aCols
Default aRecnoSKI	:= {}			// Registros selecionados

//зддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta aHeader e aCols das Regras da PesquisaЁ
//юддддддддддддддддддддддддддддддддддддддддддддды
aHeader	:= {}
aCols	:= {}

If !INCLUI
	cSeek := xFilial("SKI")+SKG->KG_CODQST
	cWhile:= "SKI->KI_FILIAL+SKI->KI_CODQST"

	FillGetDados(	nOpc			,"SKI"			,1											,cSeek				,;
	   				{|| &cWhile }	,{|| .T. }		,/*aNoFields*/								,/*aYesFields*/		,; 
	   				/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/								,/*lEmpty*/			,;
	   				/*aHeaderAux*/	,/*aColsAux*/	,{|| GPR030AfterCols( "SKI", aRecnoSKI ) }	,/*bBeforeCols*/	)
			   				
Else
	FillGetDados(	nOpc			,"SKI"		,1				,/*cSeek*/		,;
					/*{||&cWhile}*/	,{|| .T. }	,/*aNoFields*/	,/*aYesFields*/	,; 
					/*lOnlyYes*/	,/*cQuery*/	,/*bMontCols*/	,.T.			)
EndIf

If Empty( aCols[ 1 ][ GdFieldPos("KI_CODCOL") ] )
	aCols[ 1 ][ GdFieldPos("KI_CODCOL") ]	 := StrZero(1,Len(SKI->KI_CODCOL))
EndIf

aHeaderSKI	:= aClone( aHeader )
aColsSKI	:= aClone( aCols )

Return( .T. )

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁGpr030Prv  ЁAutora Ё Henry Fila           Ё Data Ё 20/10/03 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Preview da questao                                         Ё╠╠
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
Function Gpra030Prv()

Local cParam := ""

cParam += fPesq2URL( "000000000000000000000000"+SKG->KG_CODQST+"511" )
ShellExecute("open",GetSrvProfString("UrlGpr","")+"w_pgpr010.apw?cID="+cParam, "","",SW_SHOW)

Return( .T. )

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддддддбдддддддбдддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFunГЦo    ЁGPR030AfterCols Ё Autor Ё Conrado Q.      Ё Data Ё 29/01/2007 Ё╠╠
╠╠цддддддддддеддддддддддддддддадддддддадддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescriГЦo ЁRotina executada durante a montagem do aCols                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁGPR030AfterCols( ExpC1, ExpA2 )                               Ё╠╠
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
Static Function GPR030AfterCols( cAlias, aRecnoArray )
	If ( Alias() == cAlias )
		aAdd( aRecnoArray, (cAlias)->( Recno() ) )
	EndIf
Return( .T. )

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁGP030VldOp╨Autor  ЁVendas CRM          ╨ Data Ё  31/07/08   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁValida a configuracao dos campos KG_FORMULA, KG_VALOR e     ╨╠╠
╠╠╨          ЁKG_FATOR.                                                   ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁSIGAGPR                                                     ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function GP030VldOp()

Local aArea		:= GetArea()
Local lRet		:= .T.
Local cVar		:= AllTrim(ReadVar())
Local cFormula	:= Space(TamSX3("KG_FORMUL")[1])

Do Case
	Case (cVar == "M->KG_FORMUL") .AND. !Empty(M->KG_FORMUL)
		
		M->KG_VALOR	:= 0
		M->KG_FATOR	:= 0 
		
	Case (cVar == "M->KG_VALOR" ) 
	
		If (M->KG_VALOR > 0)
			M->KG_FORMUL:= cFormula
			M->KG_FATOR	:= 0
		ElseIf (M->KG_VALOR < 0)
			lRet := .F.
		EndIf
		
	Case (cVar == "M->KG_FATOR" )
		If (M->KG_FATOR > 0)
			M->KG_FORMUL:= cFormula
			M->KG_VALOR	:= 0
		ElseIf (M->KG_FATOR < 0)
			lRet := .F.
		EndIf
EndCase

RestArea(aArea)

Return lRet