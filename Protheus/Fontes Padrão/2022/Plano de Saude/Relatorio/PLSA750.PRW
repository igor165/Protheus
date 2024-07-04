#INCLUDE "plsa750.ch"

#include "FOLDER.CH"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA750 ³ Autor ³ Antonio de Padua Cunha ³ Data ³ 19.09.02 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Aumentos de empresa                                        ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSA750()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA750()

PRIVATE aRotina  := { { STRPL01, 'AxPesqui'   , 0 , K_Pesquisar  },;
					{ STR0001	, 'PLS750Mov' 	, 0 , K_Visualizar 	},; //"Visualizar"
					{ STR0002  	, 'PLS750Mov'  	, 0 , K_Incluir    	},; //"Incluir"
					{ STR0003	, 'PLS750Mov'  	, 0 , K_Alterar    	},; //"Alterar"
					{ STR0004 	, 'PLS750Mov' 	, 0 , K_Excluir    	},; //"Excluir"
					{ STR0005	, "PLSA750LEG"	, 0 , K_Incluir     },; //"Legenda"
					{ STR0006	, "PLS750Rea"	, 0 , K_Incluir     } }  //"A&pl.Reajuste"
					
PRIVATE aCdCores  	:= { 	{ 'BR_VERDE'    ,'Reajuste informado' },;
							{ 'BR_VERMELHO' ,'Reajuste calculado' } }

Private cCadastro 	:= STR0007 //"Reajuste de Empresas"
Private cStatus		:= "1"
Private aCampos		:= {}
             
BWH->(DbSetOrder(1))
BWH->(DbSeek(xFilial("BHW")))
BHW->(mBrowse(06,01,22,75,'BHW',,"BHW->BHW_DIGITA='0'",,,,, 	'xFilial("BHW")+"1"',;
																'xFilial("BHW")+"1"'))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA750A³ Autor ³ Wagner Mobile Costa    ³ Data ³ 25.08.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Simulacao de Reajuste                                      ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSA750A()                                                 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA750A()

PRIVATE aRotina  := { { STRPL01, 'AxPesqui'   , 0 , K_Pesquisar  },;
{ STR0001	, 'PLS750Mov' 	, 0 , K_Visualizar 	},; //"Visualizar"
{ STR0002  	, 'PLS750Mov'  	, 0 , K_Incluir    	},; //"Incluir"
{ STR0003	    , 'PLS750Mov' 	, 0 , K_Alterar    	},; //"Alterar"
{ STR0004 	, 'PLS750Mov' 	, 0 , K_Excluir    	},; //"Excluir"
{ STR0005     , "PLSA750LEG"	, 0 , K_Incluir     },; //"Legenda"
{ STR0006, "PLS750Rea"	, 0 , K_Incluir     },; //"A&pl.Reajuste"
{ STR0008, "PLS750Efe"	, 0 , K_Incluir     } }  //"Efe&t.Reajuste"

PRIVATE aCdCores  	:= { 	{ 'BR_VERDE'    ,'Reajuste informado' },;
                        	{ 'BR_VERMELHO' ,'Reajuste calculado' } }

Private cCadastro 	:= STR0009 //"Simulacao de Reajuste"
Private cStatus		:= "0"
Private aCampos		:= {}
             
BWH->(DbSetOrder(1))
BWH->(DbSeek(xFilial("BHW")))
BHW->(mBrowse(06,01,22,75,'BHW',,"BHW->BHW_DIGITA='0'",,,,, 	'xFilial("BHW")+"0"',;
																'xFilial("BHW")+"0"'))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS750Mov  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 30.07.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Chama funcao para efetuar inclusao/exclusao do reajuste    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS750Mov(cAlias, nReg, nOpc)

LOCAL aButtons := {}     
Aadd(aButtons, {'PROJETPMS',{|| PLSA750Par(nOpc)},STR0010} ) //"Parcelamento do Reajuste"
AAdd(aButtons, {'PROJETPMS',{|| PLSA750FAI(nOpc)},STR0011}) //"Faixas Etarias"

Private aCabBWZ 	:= {}
Private aColsBWZ	:= {}
Private aVetBWZ 	:= {}
Private aCabBTU 	:= {}
Private aColsBTU 	:= {}
Private aVetBTU 	:= {}

Private lReajuste 	:= .T.
Private lAjuste 	:= .F.

__OPC := nOpc

If nOpc <> K_Incluir
	BWZ->(DbSetOrder(1))
	PLSA750Hea("BHW")
	If 	BWZ->(DbSeek(xFilial("BWZ")+BHW->(BHW_STATUS+BHW_CODINT+BHW_CODEMP+BHW_CONEMP+BHW_VERCON+;
		BHW_SUBCON+BHW_VERSUB+BHW_MATRIC+BHW_TIPREG+BHW_DIGITO+BHW_CODPLA+BHW_VERSAO+;
		BHW_ANOMES)))
		
		Store COLS "BWZ" TO aColsBWZ FROM aCabBWZ VETTRAB aVetBWZ;
		While BWZ->(BWZ_FILIAL+BWZ_STATUS+BWZ_CODINT+BWZ_CODEMP+BWZ_CONEMP+BWZ_VERCON+;
		BWZ_SUBCON+BWZ_VERSUB+BWZ_MATRIC+BWZ_TIPREG+BWZ_DIGITO+BWZ_CODPLA+BWZ_VERSAO+;
		BWZ_ANOMES) == xFilial("BWZ")+BHW->(BHW_STATUS+BHW_CODINT+BHW_CODEMP+BHW_CONEMP+BHW_VERCON+;
		BHW_SUBCON+BHW_VERSUB+BHW_MATRIC+BHW_TIPREG+BHW_DIGITO+BHW_CODPLA+BHW_VERSAO+;
		BHW_ANOMES)
	Else
		Store COLS Blank "BWZ" TO aColsBWZ FROM aCabBWZ
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as faixas etarias...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 
	dbSelectarea("BTU")
	BTU->(DbSetOrder(1))
	PLSA750Hea("BTU")
	If 	BTU->(DbSeek(xFilial("BTU")+BHW->(BHW_STATUS+BHW_CODINT+BHW_CODEMP+BHW_CONEMP+BHW_VERCON+;
		BHW_SUBCON+BHW_VERSUB+BHW_MATRIC+BHW_TIPREG+BHW_DIGITO+BHW_CODPLA+BHW_VERSAO+;
		BHW_ANOMES)))
		
		Store COLS "BTU" TO aColsBTU FROM aCabBTU VETTRAB aVetBTU;
		While BTU->(BTU_FILIAL+BTU_STATUS+BTU_CODINT+BTU_CODEMP+BTU_CONEMP+BTU_VERCON+;
		BTU_SUBCON+BTU_VERSUB+BTU_MATRIC+BTU_TIPREG+BTU_DIGITO+BTU_CODPLA+BTU_VERSAO+;
		BTU_ANOMES) == xFilial("BTU")+BHW->(BHW_STATUS+BHW_CODINT+BHW_CODEMP+BHW_CONEMP+BHW_VERCON+;
		BHW_SUBCON+BHW_VERSUB+BHW_MATRIC+BHW_TIPREG+BHW_DIGITO+BHW_CODPLA+BHW_VERSAO+;
		BHW_ANOMES)
	Else
		Store COLS Blank "BTU" TO aColsBTU FROM aCabBTU
	EndIf
Endif
*/
			
If nOpc = K_Incluir
	AxInclui(cAlias,nReg,nOpc,,,,"Pls750TdOk()",, "PLS750GRV",aButtons)
ElseIf nOpc = K_Visualizar
	AxVisual(cAlias,nReg,nOpc,,,,,aButtons)
Else
	RegToMemory(cAlias)
	lReajuste := Pls750Cob(.F.)
	lAjuste := Pls750Cob()
	If nOpc = K_Alterar
		AxAltera(cAlias,nReg,nOpc,,,,,,"PLS750GRV",,aButtons)
	ElseIf nOpc = K_Excluir
		cDelFunc := "PLS750Cob(.F., .T.)"
		AxDeleta(cAlias,nReg,nOpc,"PLS750GRV",,aButtons)
	Endif
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS750TdOk ³ Autor ³ Wagner Mobile Costa ³ Data ³ 30.07.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Efetua inversao do mes para gravacao do campo BHW_ANOMES   ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS750TdOk()

Local lRet := .T.

M->BHW_ANOMES := Right(M->BHW_MESANO, 4) + Left(M->BHW_MESANO, 2)
M->BHW_STATUS := cStatus	

DbSelectArea("BHW")
DbSetOrder(1)
If DbSeek(	xFilial("BHW") + M->BHW_STATUS + M->BHW_CODINT + M->BHW_CODEMP +;
			M->BHW_CONEMP + M->BHW_VERCON + M->BHW_SUBCON + M->BHW_VERSUB +;
			M->BHW_MATRIC + M->BHW_TIPREG + M->BHW_DIGITO + M->BHW_CODPLA + M->BHW_VERSAO + M->BHW_ANOMES)
	Help("", 1, "JAGRAVADO")
	lRet := .F.
Endif

If 	cStatus = "0" .And.;
	DbSeek(	xFilial("BHW") + "1" + M->BHW_CODINT + M->BHW_CODEMP +;
			M->BHW_CONEMP + M->BHW_VERCON + M->BHW_SUBCON + M->BHW_VERSUB +;
			M->BHW_MATRIC + M->BHW_TIPREG + M->BHW_DIGITO + M->BHW_CODPLA + M->BHW_VERSAO + M->BHW_ANOMES)
	Help("", 1, "JAGRAVADO")
	lRet := .F.
Endif

If 	cStatus = "1" .And.;
	DbSeek(	xFilial("BHW") + "0" + M->BHW_CODINT + M->BHW_CODEMP +;
			M->BHW_CONEMP + M->BHW_VERCON + M->BHW_SUBCON + M->BHW_VERSUB +;
			M->BHW_MATRIC + M->BHW_TIPREG + M->BHW_DIGITO + M->BHW_CODPLA + M->BHW_VERSAO + M->BHW_ANOMES)
	Help("", 1, "JAGRAVADO")                             
	lRet := .F.
Endif

If M->BHW_TIPOUS = "1"	// Fisica
	BG9->(DbSetOrder(1))
	BG9->(DbSeek(xFilial("BG9") + M->BHW_CODINT+M->BHW_CODEMP))
	If Empty(BG9->BG9_INDREA) .And. Empty(M->BHW_MATRIC)
		ApMsgAlert(	STR0012+; //"Deve ser informado na empresa o indice padrao para que possa ser efetuado "
					STR0013, STR0014) //"lancamento manual !"###"Atencao"
		lRet := .F.
	Endif
Else
	If ! Empty(M->BHW_CODPLA)
		BT6->(DbSetOrder(1))
		BT6->(DbSeek(	xFilial("BT6") + M->BHW_CODINT+M->BHW_CODEMP+M->BHW_CONEMP+M->BHW_VERCON+;
						M->BHW_SUBCON+M->BHW_VERSUB+M->BHW_CODPLA+M->BHW_VERSAO))
		If Empty(BT6->BT6_INDREA)
			ApMsgAlert(	STR0015+; //"Deve ser informado no sub-contratoXProduto o indice padrao para que possa ser efetuado "
						STR0013, STR0014) //"lancamento manual !"###"Atencao"
			lRet := .F.
		Endif
	Else
		If Empty(M->BHW_CONEMP+M->BHW_VERCON) .and. Empty(M->BHW_SUBCON+M->BHW_VERSUB)
			BG9->(DbSetOrder(1))
			BG9->(DbSeek(xFilial("BG9") + M->BHW_CODINT+M->BHW_CODEMP))
			If Empty(BG9->BG9_INDREA)
				ApMsgAlert(	STR0012+; //"Deve ser informado na empresa o indice padrao para que possa ser efetuado "
							STR0013, STR0014) //"lancamento manual !"###"Atencao"
				lRet := .F.
			Endif
		Else
			BQC->(DbSetOrder(1))
			If BQC->(DbSeek(xFilial("BQC") + M->BHW_CODINT+M->BHW_CODEMP+M->BHW_CONEMP+M->BHW_VERCON+M->BHW_SUBCON+M->BHW_VERSUB))
				If Empty(BQC->BQC_INDREA)
					ApMsgAlert(	STR0016+; //"Deve ser informado no sub-contrato o indice padrao para que possa ser efetuado "
								STR0013, STR0014) //"lancamento manual !"###"Atencao"
					lRet := .F.
				Endif
			Endif
		Endif
	Endif
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS750Vld  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 30.07.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Efetua validacao dos campos chaves do reajuste de empresa  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS750Vld()

Local lRet 	:= .T.

// Validacao do preenchimento dos campos que chamam a funcao

If ReadVar() = "M->BHW_CODEMP" .And. ! Empty(M->BHW_CODEMP)
	lRet := BG9->(DbSeek(xFilial("BG9") + M->BHW_CODINT+M->BHW_CODEMP))
	If ! lRet
		Help("",1,"REGNOIS")
	Else
		M->BHW_CONEMP := Space(Len(M->BHW_CONEMP))
		M->BHW_VERCON := Space(Len(M->BHW_VERCON))
		M->BHW_SUBCON := Space(Len(M->BHW_SUBCON))
		M->BHW_VERSUB := Space(Len(M->BHW_VERCON))
		M->BHW_DESCRI := BG9->BG9_DESCRI
		M->BHW_TIPOUS := BG9->BG9_TIPO
		M->BHW_NROUSU := 0
		M->BHW_VALOR := 0
	Endif

ElseIf ReadVar() = "M->BHW_CONEMP" .And. ! Empty(M->BHW_CONEMP)
	lRet := ExistCpo("BT5",M->BHW_CODINT+M->BHW_CODEMP+M->BHW_CONEMP)
	If lRet		// Gatilho o campo
		M->BHW_VERCON := BT5->BT5_VERSAO
		M->BHW_SUBCON := Space(Len(M->BHW_SUBCON))
		M->BHW_VERSUB := Space(Len(M->BHW_VERCON))
		M->BHW_NROUSU := 0
		M->BHW_VALOR := 0
	Endif
ElseIf ReadVar() = "M->BHW_VERCON" .And. ! Empty(M->BHW_VERCON)
	lRet := ExistCpo("BT5",M->BHW_CODINT+M->BHW_CODEMP+M->BHW_CONEMP+M->BHW_VERCON)
ElseIf ReadVar() = "M->BHW_SUBCON" .And. ! Empty(M->BHW_SUBCON)
	lRet := ExistCpo("BQC",M->BHW_CODINT+M->BHW_CODEMP+M->BHW_CONEMP+M->BHW_VERCON+M->BHW_SUBCON)
	If lRet		// Gatilho o campo
		M->BHW_VERSUB := BQC->BQC_VERSUB
	Endif
ElseIf ReadVar() = "M->BHW_VERSUB" .And. ! Empty(M->BHW_VERSUB)
	lRet := ExistCpo("BQC",M->BHW_CODINT+M->BHW_CODEMP+M->BHW_CONEMP+M->BHW_VERCON+M->BHW_SUBCON+M->BHW_VERSUB)
ElseIf ReadVar() = "M->BHW_MATRIC" .And. ! Empty(M->BHW_MATRIC)
	BA3->(DbSetOrder(1))
	lRet := BA3->(DbSeek(xFilial("BA3") + M->BHW_CODINT+M->BHW_CODEMP+M->BHW_MATRIC+M->BHW_CONEMP+M->BHW_VERCON+M->BHW_SUBCON+M->BHW_VERSUB))
	If ! lRet
		Help("",1,"REGNOIS")
	Else
		If Empty(BA3->BA3_INDREA)
			ApMsgAlert(	STR0017+; //"Deve ser informado na familia o indice padrao para que possa ser efetuado "
						STR0013, STR0014) //"lancamento manual !"###"Atencao"
			lRet := .F.
		Else
			M->BHW_CODPLA := BA3->BA3_CODPLA
			M->BHW_VERSAO := BA3->BA3_VERSAO
		Endif
	Endif
ElseIf ReadVar() = "M->BHW_TIPREG" .And. ! Empty(M->BHW_TIPREG)
	BA1->(DbSetOrder(2))
	lRet := BA1->(DbSeek(xFilial("BA1") + M->BHW_CODINT+M->BHW_CODEMP+M->BHW_MATRIC+M->BHW_TIPREG))
	If ! lRet
		Help("",1,"REGNOIS")
	Else
		If Empty(BA1->BA1_INDREA)
			ApMsgAlert(	STR0018+; //"Deve ser informado no usuario o indice padrao para que possa ser efetuado "
						STR0013, STR0014) //"lancamento manual !"###"Atencao"
			lRet := .F.
		Else
			M->BHW_DIGITO := BA1->BA1_DIGITO
		Endif
	Endif
	BA1->(DbSetOrder(1))
ElseIf ReadVar() = "M->BHW_DIGITO" .And. ! Empty(M->BHW_DIGITO)
	BA1->(DbSetOrder(2))
	lRet := BA1->(DbSeek(xFilial("BA1") + M->BHW_CODINT+M->BHW_CODEMP+M->BHW_MATRIC+M->BHW_TIPREG+M->BHW_DIGITO))
	If ! lRet
		Help("",1,"REGNOIS")
	Endif
	BA1->(DbSetOrder(1))
ElseIf ReadVar() = "M->BHW_CODPLA"
	If Empty(M->BHW_CODPLA	)
		M->BHW_VERSAO := Space(Len(M->BHW_VERSAO))
	Else
		lRet := BI3->(DbSeek(xFilial("BI3") + M->BHW_CODINT+M->BHW_CODPLA))
		If ! lRet
			Help("",1,"REGNOIS")
		Else	
			M->BHW_VERSAO := BI3->BI3_VERSAO
		Endif
	Endif
ElseIf ReadVar() = "M->BHW_VERSAO" .And. ! Empty(M->BHW_VERSAO)
	lRet := ExistCpo("BI3",M->BHW_CODINT+M->BHW_CODPLA+M->BHW_VERSAO)
Endif

If lRet .And. 	M->BHW_DIGITA <> "0" .And.;
				! Empty(M->BHW_CODEMP) .And. ! Empty(M->BHW_CONEMP) .And.;
				! Empty(M->BHW_VERCON) .And. ! Empty(M->BHW_SUBCON) .And.;
				! Empty(M->BHW_VERSUB)
	PLS750Usu(	M->BHW_CODINT, M->BHW_CODEMP, M->BHW_CONEMP, M->BHW_VERCON,;
				M->BHW_SUBCON, M->BHW_VERSUB, M->BHW_MATRIC, M->BHW_TIPREG,;
				M->BHW_CODPLA, M->BHW_VERSAO)
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS750Vld  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 30.07.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Efetua validacao dos campos chaves do reajuste de empresa  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS750Usu(	cBHW_CODINT, cBHW_CODEMP, cBHW_CONEMP, cBHW_VERCON,;
					cBHW_SUBCON, cBHW_VERSUB, cBHW_MATRIC, cBHW_TIPREG,;
					cBHW_CODPLA, cBHW_VERSAO)

Local cFiltro 	//Local cDtos 	:= Dtos(LastDay(Ctod("01/" + Trans(M->BHW_MESANO, "@R 99/9999")))), cFiltro
Local cArea 	:= Alias()
Local cAnoAnt 	:= Right(M->BHW_MESANO, 4), cMesAnt := Left(M->BHW_MESANO, 2)

If cMesAnt = "01"
	cMesAnt := "12"
	cAnoAnt := Str(Val(cAnoAnt) - 1, 4)
Else
	cMesAnt := StrZero(Val(cMesAnt) - 1, 2)
Endif

DbSelectArea("BM1")		// Composicao de Cobranca
cFiltro := 	"SELECT COUNT(*) CONTADOR, SUM(BM1_VALOR) VALOR FROM " +;
			RetSqlName("BM1") + " WHERE BM1_FILIAL = '" + xFilial("BM1") + "' AND "+;
			"BM1_CODINT = '" + cBHW_CODINT + "' AND " +;
			"BM1_CODEMP = '" + cBHW_CODEMP + "' AND " +;
			"BM1_CONEMP = '" + cBHW_CONEMP + "' AND " +;
			"BM1_VERCON = '" + cBHW_VERCON + "' AND " +;
			"BM1_SUBCON = '" + cBHW_SUBCON + "' AND " +;
			"BM1_VERSUB = '" + cBHW_VERSUB + "' AND " +;
			"BM1_ANO = '" + cAnoAnt + "' AND BM1_MES = '" + cMesAnt + "' AND " +;
			"BM1_CODTIP = '101' "
If Empty(cBHW_MATRIC) .And. Empty(cBHW_TIPREG) .And. ! Empty(cBHW_CODPLA)
	cFiltro += "AND BM1_CODEVE = '" + cBHW_CODPLA + "' "
Endif			
If ! Empty(cBHW_MATRIC)
	cFiltro += "AND BM1_MATRIC = '" + cBHW_MATRIC + "' "
Endif	
If ! Empty(cBHW_TIPREG)
	cFiltro += "AND BM1_TIPREG = '" + cBHW_TIPREG + "' "
Endif	
cFiltro += 	"AND D_E_L_E_T_ <> '*'"
cFiltro := ChangeQuery(cFiltro)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BM1USU", .F., .T.)
M->BHW_NROUSU := BM1USU->CONTADOR
M->BHW_VALOR := BM1USU->VALOR
BM1USU->( DbCloseArea() )

cFiltro := 	"SELECT COUNT(*) CONTADOR, SUM(BM1_VALOR) VALOR FROM " +;
			RetSqlName("BM1") + " WHERE BM1_FILIAL = '" + xFilial("BM1") + "' AND "+;
			"BM1_CODINT = '" + cBHW_CODINT + "' AND " +;
			"BM1_CODEMP = '" + cBHW_CODEMP + "' AND " +;
			"BM1_CONEMP = '" + cBHW_CONEMP + "' AND " +;
			"BM1_VERCON = '" + cBHW_VERCON + "' AND " +;
			"BM1_SUBCON = '" + cBHW_SUBCON + "' AND " +;
			"BM1_VERSUB = '" + cBHW_VERSUB + "' AND " +;
			"BM1_ANO = '" + cAnoAnt + "' AND BM1_MES = '" + cMesAnt + "' AND " +;
			"BM1_CODTIP IN ('105', '106') "
If Empty(cBHW_MATRIC) .And. Empty(cBHW_TIPREG) .And. ! Empty(cBHW_CODPLA)
	cFiltro += "AND BM1_CODEVE = '" + cBHW_CODPLA + "' "
Endif			
If ! Empty(cBHW_MATRIC)
	cFiltro += "AND BM1_MATRIC = '" + cBHW_MATRIC + "' "
Endif	
If ! Empty(cBHW_TIPREG)
	cFiltro += "AND BM1_TIPREG = '" + cBHW_TIPREG + "' "
Endif	
cFiltro += 	"AND D_E_L_E_T_ <> '*'"
cFiltro := ChangeQuery(cFiltro)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BM1USU", .F., .T.)
M->BHW_VALOR += BM1USU->VALOR
BM1USU->( DbCloseArea() )

If ! Empty(cArea)
	DbSelectArea(cArea)
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA750CD  ³ Autor ³ Tulio Cesar          ³ Data ³ 27.02.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna proximo codigo do aumentos ANS                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA750Cd(cCodInt)
LOCAL nRet    := 0
LOCAL nOrdBHW := BHW->(IndexOrd())


BHW->(DbSetOrder(1))
if BHW->(BOF()) .And. BHW->(EOF())
    nRet := StrZero(1,3)
    Return(nRet)
Endif

BHW->(DbSeek(xFilial("BHW")+cCodInt+Replicate("9",Len(BHW->BHW_CODSEQ)),.T.))
BHW->(DbSkip(-1))

If BHW->(BHW_FILIAL+BHW_CODINT) <> xFilial("BHW")+cCodInt
   nRet := StrZero(1,3)
Else
   nRet := StrZero(Val(BHW->BHW_CODSEQ)+1,3)
Endif

BHW->(DbSetOrder(nOrdBHW))

Return(nRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA750MES ³ Autor ³ Tulio Cesar          ³ Data ³ 04.07.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o mes/ano passado como parametro + 12 meses...        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA750Mes(cAnoMes)
LOCAL cAno := Subs(cAnoMes,1,4)
LOCAL cMes := Subs(cAnoMes,5,2)
LOCAL nInd
LOCAL cAnoRes := cAno
LOCAL cMesRes := cMes
          
For nInd := 1 To 11
    If cMesRes == "12"
       cAnoRes := StrZero(Val(cAnoRes)+1,4)
       cMesRes := "01"
    Else
       cMesRes := StrZero(Val(cMesRes)+1,2)
    Endif      
Next

Return(cAnoRes+cMesRes)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA750LEG ³ Autor ³ Wagner Mobile Costa ³ Data ³ 30.07.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe a legenda...                                         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA750Leg()

Local aLegenda := { 	{ aCdCores[1,1],aCdCores[1,2] },;
                     	{ aCdCores[2,1],aCdCores[2,2] } }

BrwLegenda(cCadastro,STR0019 ,aLegenda) //"Status"

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS750Cob  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 05.08.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Verifica se ja foram cobrados e ja foi efetuada baixa      ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS750Cob(lChkBaixa, lMsg)

Local lRet := .T., cArea := Alias(), cFiltro := ""

DEFAULT lChkBaixa := .T.
DEFAULT lMsg      := .F.

cFiltro := 	"SELECT * FROM " + RetSqlName("BM1") + " "+;
			"WHERE BM1_FILIAL = '" + xFilial("BM1") + "' AND "+;
			"BM1_CODINT = '" + M->BHW_CODINT + "' AND " +;
			"BM1_CODEMP = '" + M->BHW_CODEMP + "' AND " +;
			"BM1_CONEMP = '" + M->BHW_CONEMP + "' AND " +;
			"BM1_VERCON = '" + M->BHW_VERCON + "' AND " +;
			"BM1_SUBCON = '" + M->BHW_SUBCON + "' AND " +;
			"BM1_VERSUB = '" + M->BHW_VERSUB + "' AND "
If ! Empty(M->BHW_MATRIC)
	cFiltro += "BM1_MATRIC = '" + M->BHW_MATRIC + "' AND "
Endif	
If ! Empty(M->BHW_TIPREG)
	cFiltro += "BM1_TIPREG = '" + M->BHW_TIPREG + "' AND "
Endif	
cFiltro += 	"BM1_ANO + BM1_MES = '" + M->BHW_ANOMES + "' AND " +;
			"BM1_CODTIP = '106' AND D_E_L_E_T_ = ' '"
cFiltro := ChangeQuery(cFiltro)
			
dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BM1QRY", .F., .T.)
If ! Empty(BM1_CODINT + BM1_CODEMP)
	If lChkBaixa
		lRet := .F.

		SE1->(DbSetOrder(14))
		While ! BM1QRY->(Eof())
			If SE1->(DbSeek(	xFilial("SE1") + BM1QRY->BM1_CODINT +;
								BM1QRY->BM1_CODEMP + BM1QRY->BM1_MATRIC +;
								M->BHW_ANOMES)) .And. SE1->E1_SALDO = 0
				lRet := .T.
				Exit
			Endif
			BM1QRY->(DbSkip())
		EndDo
	Else
		lRet := .F.
	Endif
ElseIf lChkBaixa
	lRet := .F.
Endif
BM1QRY->(DbCloseArea())

If lMsg .And. ! lRet
	ApMsgAlert(	STR0020 +; //"Nao sera possivel a exclusao do reajuste pois ja foi utilizada na "
				STR0021, STR0014) //"composicao da cobranca !"###"Atencao"
Endif

If ! Empty(cArea)
	DbSelectArea(cArea)
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS750Rea  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 05.08.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Executa calculo de reajuste a partir do indice definido    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS750Rea

LOCAL cFiltro, nMin, nMax, nCont, cChave, cAlias := Alias()
LOCAL nPerPad 	:= BHW->BHW_PERPAD

If Pergunte("PLS750", .T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // Mes Base Reajuste                                ³
//³ mv_par02 // Ano Base                                         ³
//³ mv_par03 // Operadora de                                     ³
//³ mv_par04 // Operadora ate                                    ³
//³ mv_par05 // Empresa de                                       ³
//³ mv_par06 // Empresa ate                                      ³
//³ mv_par07 // Contrato de                                      ³
//³ mv_par08 // Contrato ate                                     ³
//³ mv_par09 // Sub-Contrato de                                  ³
//³ mv_par10 // Sub-Contrato ate                                 ³
//³ mv_par11 // Matricula de                                     ³
//³ mv_par12 // Matricula ate                                    ³
//³ mv_par13 // Produto de                                       ³
//³ mv_par14 // Produto ate                                      ³
//³ mv_par15 // Pessoa juridica/fisica/ambas                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cFiltro := 	"SELECT MIN(R_E_C_N_O_) MINRECNO, " +;
				"MAX(R_E_C_N_O_) MAXRECNO FROM " + RetSqlName("BHW") + " " +;
				"WHERE BHW_FILIAL = '" + xFilial("BHW") + "' AND "+;
				"BHW_STATUS = '" + cStatus + "' AND " +;
				"BHW_CODINT >= '" + mv_par03 + "' AND " +;
				"BHW_CODINT >= '" + mv_par04 + "' AND " +;
				"BHW_CODEMP >= '" + mv_par05 + "' AND " +;
				"BHW_CODEMP <= '" + mv_par06 + "' AND " +;
				"BHW_CONEMP >= '" + mv_par07 + "' AND " +;
				"BHW_CONEMP <= '" + mv_par08 + "' AND " +;
				"BHW_SUBCON >= '" + mv_par09 + "' AND " +;
				"BHW_SUBCON <= '" + mv_par10 + "' AND " +;
				"BHW_MATRIC >= '" + mv_par11 + "' AND " +;
				"BHW_MATRIC <= '" + mv_par12 + "' AND " +;
				"BHW_CODPLA >= '" + mv_par13 + "' AND " +;
				"BHW_CODPLA <= '" + mv_par14 + "' AND " +;
				"BHW_ANOMES = '" + mv_par02 + mv_par01 + "' AND BHW_DIGITA = '0'"

	If mv_par15 = 1		// Fisica
		cFiltro += 	" AND BHW_TIPOUS = '1' AND D_E_L_E_T_ = ' '"
	ElseIf mv_par15 = 2		// Juridica
		cFiltro += 	" AND BHW_TIPOUS = '2' AND D_E_L_E_T_ = ' '"
	Endif
	cFiltro := ChangeQuery(cFiltro)
		
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BHWQRY", .F., .T.)
	nMin := BHWQRY->MINRECNO
	nMax := BHWQRY->MAXRECNO
	BHWQRY->( DbCloseArea() )

	// Deleto os registros existentes
	cFiltro := 	"DELETE FROM " + RetSqlName("BHW") + " " +;
				"WHERE BHW_FILIAL = '" + xFilial("BHW") + "' AND "+;
				"BHW_STATUS = '" + cStatus + "' AND " +;
				"BHW_CODINT >= '" + mv_par03 + "' AND " +;
				"BHW_CODINT <= '" + mv_par04 + "' AND " +;
				"BHW_CODEMP >= '" + mv_par05 + "' AND " +;
				"BHW_CODEMP <= '" + mv_par06 + "' AND " +;
				"BHW_CONEMP >= '" + mv_par07 + "' AND " +;
				"BHW_CONEMP <= '" + mv_par08 + "' AND " +;
				"BHW_SUBCON >= '" + mv_par09 + "' AND " +;
				"BHW_SUBCON <= '" + mv_par10 + "' AND " +;
				"BHW_MATRIC >= '" + mv_par11 + "' AND " +;
				"BHW_MATRIC <= '" + mv_par12 + "' AND " +;
				"BHW_CODPLA >= '" + mv_par13 + "' AND " +;
				"BHW_CODPLA <= '" + mv_par14 + "' AND " +;
				"BHW_ANOMES = '" + mv_par02 + mv_par01 + "' AND BHW_DIGITA = '0'"

	If mv_par15 = 1		// Fisica
		cFiltro += 	" AND BHW_TIPOUS = '1' AND D_E_L_E_T_ = ' '"
	ElseIf mv_par15 = 2		// Juridica
		cFiltro += 	" AND BHW_TIPOUS = '2' AND D_E_L_E_T_ = ' '"
	Endif
	ProcRegua(0)
		
	For nCont := nMin To nMax STEP 1024
		cChave := "AND R_E_C_N_O_>="+Str(nCont,10,0)+" AND R_E_C_N_O_<="+Str(nCont+1023,10,0)+""
		TcSqlExec(cFiltro+cChave)
		IncProc(STR0022) //"Deletando reajustes existentes por sub-contrato ..."
	Next nCont

	If mv_par15 = 2 .Or. mv_par15 = 3	// Juridica ou Ambos

		cFiltro := 	"SELECT COUNT(*) CONTADOR FROM " + RetSqlName("BT6") + " BT6 "+;
					"WHERE BT6_FILIAL = '" + xFilial("BT6") + "' AND "+;
					"BT6_CODINT >= '" + mv_par03 + "' AND " +;
					"BT6_CODINT <= '" + mv_par04 + "' AND " +;
					"BT6_CODIGO >= '" + mv_par05 + "' AND " +;
					"BT6_CODIGO <= '" + mv_par05 + "' AND " +;
					"BT6_NUMCON >= '" + mv_par07 + "' AND " +;
					"BT6_NUMCON <= '" + mv_par08 + "' AND " +;
					"BT6_SUBCON >= '" + mv_par09 + "' AND " +;
					"BT6_SUBCON <= '" + mv_par10 + "' AND " +;
					"BT6_CODPRO >= '" + mv_par13 + "' AND " +;
					"BT6_CODPRO <= '" + mv_par14 + "' AND " +;
					"BT6_MESREA = '" + mv_par01 + "' AND BT6_INDREA <> ' ' AND " +;
					"D_E_L_E_T_ = ' ' AND NOT EXISTS(" +;
					"SELECT R_E_C_N_O_ FROM " + RetSqlName("BHW") + " WHERE " +;
					"BHW_FILIAL = '" + xFilial("BHW") + "' AND "+;
					"BHW_STATUS = '" + cStatus + "' AND " +;
					"BHW_CODINT = BT6.BT6_CODINT AND " +;
					"BHW_CODEMP = BT6.BT6_CODIGO AND " +;
					"BHW_CONEMP = BT6.BT6_NUMCON AND " +;
					"BHW_VERCON = BT6.BT6_VERCON AND " +;
					"BHW_SUBCON = BT6.BT6_SUBCON AND " +;
					"BHW_VERSUB = BT6.BT6_VERSUB AND " +;
					"BHW_CODPLA = BT6.BT6_CODPRO AND " +;
					"BHW_VERSAO = BT6.BT6_VERSAO AND " +;
					"BHW_ANOMES = '" + mv_par02 + mv_par01 + "' AND D_E_L_E_T_ = ' ')"
			
		cFiltro := ChangeQuery(cFiltro)
			
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BT6QRY", .F., .T.)
		ProcRegua(CONTADOR)
		BT6QRY->( DbCloseArea() )

		cFiltro := 	"SELECT * FROM " + RetSqlName("BT6") + " BT6 " +;
					"WHERE BT6_FILIAL = '" + xFilial("BT6") + "' AND "+;
					"BT6_CODINT >= '" + mv_par03 + "' AND " +;
					"BT6_CODINT <= '" + mv_par04 + "' AND " +;
					"BT6_CODIGO >= '" + mv_par05 + "' AND " +;
					"BT6_CODIGO <= '" + mv_par05 + "' AND " +;
					"BT6_NUMCON >= '" + mv_par07 + "' AND " +;
					"BT6_NUMCON <= '" + mv_par08 + "' AND " +;
					"BT6_SUBCON >= '" + mv_par09 + "' AND " +;
					"BT6_SUBCON <= '" + mv_par10 + "' AND " +;
					"BT6_CODPRO >= '" + mv_par13 + "' AND " +;
					"BT6_CODPRO <= '" + mv_par14 + "' AND " +;
					"BT6_MESREA = '" + mv_par01 + "' AND BT6_INDREA <> ' ' AND " +;
					"D_E_L_E_T_ = ' ' AND NOT EXISTS(" +;
					"SELECT R_E_C_N_O_ FROM " + RetSqlName("BHW") + " WHERE " +;
					"BHW_FILIAL = '" + xFilial("BHW") + "' AND "+;
					"BHW_STATUS = '" + cStatus + "' AND " +;
					"BHW_CODINT = BT6.BT6_CODINT AND " +;
					"BHW_CODEMP = BT6.BT6_CODIGO AND " +;
					"BHW_CONEMP = BT6.BT6_NUMCON AND " +;
					"BHW_VERCON = BT6.BT6_VERCON AND " +;
					"BHW_SUBCON = BT6.BT6_SUBCON AND " +;
					"BHW_VERSUB = BT6.BT6_VERSUB AND " +;
					"BHW_CODPLA = BT6.BT6_CODPRO AND " +;
					"BHW_VERSAO = BT6.BT6_VERSAO AND " +;
					"BHW_ANOMES = '" + mv_par02 + mv_par01 + "' AND D_E_L_E_T_ = ' ')"
			
		cFiltro := ChangeQuery(cFiltro)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BT6QRY", .F., .T.)
	
		// Reajuste dos produtos amarrados ao sub-contrato
		While ! BT6QRY->(Eof())
 			
 			If !Empty(BT6QRY->BT6_INDREA)
 				If BT6QRY->BT6_MESREA <> amv_par01
 					BT6QRY->( dbSkip() )
 					Loop
 				Endif
			Endif
 				
			Pls750AplR(	BT6QRY->BT6_CODINT, BT6QRY->BT6_CODIGO,;
						BT6QRY->BT6_NUMCON, BT6QRY->BT6_VERCON, BT6QRY->BT6_SUBCON,;
						BT6QRY->BT6_VERSUB, "", "", "", BT6QRY->BT6_CODPRO,;
						BT6QRY->BT6_VERSAO, BT6QRY->BT6_INDREA, BT6QRY->BT6_MESREA, "2",,nPerPad)
						
			BT9->( dbSetOrder(01) )              
			// Acho a forma de cobranca do sub-contrato
			If BT9->( dbSeek(xFilial("BT9")+BT6QRY->BT6_CODINT+BT6QRY->BT6_CODIGO+BT6QRY->BT6_NUMCON+;
											 BT6QRY->BT6_VERCON+BT6QRY->BT6_SUBCON+BT6QRY->BT6_VERSUB+;
											 BT6QRY->BT6_CODPRO+BT6QRY->BT6_VERSAO) )
            	If BT9->BT9_CODFOR == '101' // Faixas etarias...
            		
            		cFiltro := "SELECT * FROM "+RetSqlName("BTN")+" WHERE BTN_FILIAL = '"+xFilial("BTN")+"' AND "+;
            		"BTN_CODIGO = '"+BT6QRY->BT6_CODINT+BT6QRY->BT6_CODIGO+"' AND " +;
            		"BTN_NUMCON = '"+BT6QRY->BT6_NUMCON+"' AND BTN_VERCON = '"+BT6QRY->BT6_VERCON+"' AND " +;
            		"BTN_SUBCON = '"+BT6QRY->BT6_SUBCON+"' AND BTN_VERSUB = '"+BT6QRY->BT6_VERSUB+"' AND " +;
            		"BTN_CODPRO = '"+BT6QRY->BT6_CODPRO+"' AND BTN_VERPRO = '"+BT6QRY->BT6_VERSAO+"' AND " +;
            		"BTN_TABVLD = '' AND D_E_L_E_T_ = ' ' "
					cFiltro := ChangeQuery(cFiltro)
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BTNQRY", .F., .T.)

					While ! BTNQRY->( Eof() ) 
						
							// Calcula a quantidade de usuarios...
						nQtdUsr :=  PLS750IduSR(BT6QRY->BT6_CODINT,BT6QRY->BT6_CODIGO,BTNQRY->BTN_NUMCON,;
						BTNQRY->BTN_VERCON,BTNQRY->BTN_SUBCON,BTNQRY->BTN_VERSUB,BTNQRY->BTN_IDAINI,;
						BTNQRY->BTN_IDAFIN)
						
						dbSelectArea("BTU")
						BTU->( RecLock("BTU", .T.) )     
							BTU->BTU_FILIAL := xFilial("BTU")
							BTU->BTU_CODINT := Left(BTNQRY->BTN_CODIGO,4)
							BTU->BTU_ANOMES := mv_par02 + mv_par01
							BTU->BTU_CODEMP := Right(BTNQRY->BTN_CODIGO,4)
							BTU->BTU_CONEMP := BTNQRY->BTN_NUMCON
							BTU->BTU_VERCON := BTNQRY->BTN_VERCON
							BTU->BTU_SUBCON := BTNQRY->BTN_SUBCON
							BTU->BTU_VERSUB := BTNQRY->BTN_VERSUB
							BTU->BTU_CODPLA := BTNQRY->BTN_CODPRO
							BTU->BTU_VERSAO := BTNQRY->BTN_VERPRO
							BTU->BTU_CODFAI := BTNQRY->BTN_CODFOR
							BTU->BTU_TIPUSR := BTNQRY->BTN_TIPUSR
							BTU->BTU_GRAUPA := BTNQRY->BTN_GRAUPA
							BTU->BTU_SEXO   := BTNQRY->BTN_SEXO
							BTU->BTU_IDAINI := BTNQRY->BTN_IDAINI
							BTU->BTU_IDAFIN := BTNQRY->BTN_IDAFIN
							BTU->BTU_VALOR1 := BTNQRY->BTN_VALFAI
							BTU->BTU_NROUSU := nQtdUsr
							BTU->BTU_VALOR2 := (BTU->BTU_VALOR1+((BTNQRY->BTN_VALFAI*BHW->BHW_PERPAD)/100))
							BTU->BTU_VALOR3 := (BTU->BTU_VALOR2*BTU->BTU_NROUSU)
							BTU->BTU_STATUS := '0'
						BTU->( MsUnlock() )
						BTNQRY->( dbSkip() )
					Enddo
					BTNQRY->( dbCloseArea() ) 
				Elseif BT9->BT9_CODFOR == '105'
					BWD->( dbSetorder(01) )          
					cBT9Int := Left(BT9->BT9_CODIGO,4)
					cBT9Emp := Right(BT9->BT9_CODIGO,4)
					                   
					// Calcula a quantidade de usuarios...
					nQtdUsr :=  PLS750IduSR(BT6QRY->BT6_CODINT,BT6QRY->BT6_CODIGO,BT6QRY->BT6_NUMCON,;
					BT6QRY->BT6_VERCON,BT6QRY->BT6_SUBCON,BT6QRY->BT6_VERSUB)
					
					If BWD->( dbSeek(xFilial("BWD")+BT9->BT9_CODIGO+BT9->BT9_NUMCON+BT9->BT9_VERCON+;
													 BT9->BT9_SUBCON+BT9->BT9_VERSUB+BT9->BT9_CODPRO+;
													 BT9->BT9_VERSAO+BT9->BT9_CODFOR) )
						                        													 
						While !BWD->( Eof() ) .and. BWD->BWD_CODIGO+BWD->BWD_NUMCON+BWD->BWD_VERCON+;
													 BWD->BWD_SUBCON+BWD->BWD_VERSUB+BWD->BWD_CODPRO+;
													 BWD->BWD_VERPRO+BWD->BWD_CODFOR ==;
													 BT9->BT9_CODIGO+BT9->BT9_NUMCON+BT9->BT9_VERCON+;
													 BT9->BT9_SUBCON+BT9->BT9_VERSUB+BT9->BT9_CODPRO+;
													 BT9->BT9_VERSAO+BT9->BT9_CODFOR
							dbSelectArea("BTU")
							BTU->( RecLock("BTU", .T.) )     
								BTU->BTU_FILIAL := xFilial("BTU")
								BTU->BTU_CODINT := cBT9Int
								BTU->BTU_ANOMES := mv_par02 + mv_par01
								BTU->BTU_CODEMP := cBT9Emp
								BTU->BTU_CONEMP := BT9->BT9_NUMCON
								BTU->BTU_VERCON := BT9->BT9_VERCON
								BTU->BTU_SUBCON := BT9->BT9_SUBCON
								BTU->BTU_VERSUB := BT9->BT9_VERSUB
								BTU->BTU_CODPLA := BT9->BT9_CODPRO
								BTU->BTU_VERSAO := BT9->BT9_VERSAO
								BTU->BTU_CODFAI := BT9->BT9_CODFOR
								BTU->BTU_VALOR1 := BWD->BWD_VALOR 
								BTU->BTU_NROUSU := nQtdUsr   
								BTU->BTU_VALOR2 := (BTU->BTU_VALOR1+((BWD->BWD_VALOR*BHW->BHW_PERPAD)/100))
								BTU->BTU_VALOR3 := (BTU->BTU_VALOR2*BTU->BTU_NROUSU)
								BTU->BTU_STATUS := '0'
							BTU->( MsUnlock() )
           					BWD->( dbSkip() )
						Enddo
					Endif
				Endif																						 	
			Endif
			BT6QRY->(DbSkip())
		EndDo  
		BT6QRY->(DbCloseArea())
	Endif
	
	// Reajuste das empresas (Pessoa Fisica)
	If mv_par15 = 1 .Or. mv_par15 = 3	// Fisica ou Ambos
		cFiltro := 	"SELECT COUNT(*) CONTADOR FROM " + RetSqlName("BG9") + " BG9 "+;
					"WHERE BG9_FILIAL = '" + xFilial("BG9") + "' AND "+;
					"BG9_CODINT >= '" + mv_par03 + "' AND " +;
					"BG9_CODINT <= '" + mv_par04 + "' AND " +;
					"BG9_CODIGO >= '" + mv_par05 + "' AND " +;
					"BG9_CODIGO <= '" + mv_par06 + "' AND BG9_TIPO = '1' AND " +;
					"BG9_MESREA = '" + mv_par01 + "' AND BG9_INDREA <> ' ' AND " +;
					"D_E_L_E_T_ = ' ' AND NOT EXISTS(" +;
					"SELECT R_E_C_N_O_ FROM " + RetSqlName("BHW") + " WHERE " +;
					"BHW_FILIAL = '" + xFilial("BHW") + "' AND "+;
					"BHW_STATUS = '" + cStatus + "' AND " +;
					"BHW_CODINT = BG9.BG9_CODINT AND " +;
					"BHW_CODEMP = BG9.BG9_CODIGO AND " +;
					"BHW_CONEMP = ' ' AND " +;
					"BHW_VERCON = ' ' AND " +;
					"BHW_SUBCON = ' ' AND " +;
					"BHW_VERSUB = ' ' AND " +;
					"BHW_ANOMES = '" + mv_par02 + mv_par01 + "' AND D_E_L_E_T_ = ' ')"
		cFiltro := ChangeQuery(cFiltro)
				
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BG9QRY", .F., .T.)
		ProcRegua(CONTADOR)
		BG9QRY->( DbCloseArea() )
	
		cFiltro := 	"SELECT * FROM " + RetSqlName("BG9") + " BG9 " +;
					"WHERE BG9_FILIAL = '" + xFilial("BG9") + "' AND "+;
					"BG9_CODINT >= '" + mv_par03 + "' AND " +;
					"BG9_CODINT <= '" + mv_par04 + "' AND " +;
					"BG9_CODIGO >= '" + mv_par05 + "' AND " +;
					"BG9_CODIGO <= '" + mv_par06 + "' AND BG9_TIPO = '1' AND " +;
					"BG9_MESREA = '" + mv_par01 + "' AND BG9_INDREA <> ' ' AND " +;
					"D_E_L_E_T_ = ' ' AND NOT EXISTS(" +;
					"SELECT R_E_C_N_O_ FROM " + RetSqlName("BHW") + " WHERE " +;
					"BHW_FILIAL = '" + xFilial("BHW") + "' AND "+;
					"BHW_STATUS = '" + cStatus + "' AND " +;
					"BHW_CODINT = BG9.BG9_CODINT AND " +;
					"BHW_CODEMP = BG9.BG9_CODIGO AND " +;
					"BHW_CONEMP = ' ' AND BHW_VERCON = ' ' AND " +;
					"BHW_SUBCON = ' ' AND BHW_VERSUB = ' ' AND " +;
					"BHW_ANOMES = '" + mv_par02 + mv_par01 + "' AND D_E_L_E_T_ = ' ') " +;
					"ORDER BY BG9_FILIAL, BG9_CODINT, BG9_CODIGO"
					
		cFiltro := ChangeQuery(cFiltro)
		
		BT5->(DbSetOrder(1))
			
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BG9QRY", .F., .T.)
		While ! BG9QRY->(Eof())
			Pls750AplR(	BG9QRY->BG9_CODINT, BG9QRY->BG9_CODIGO,;
						"", "", "", "", "", "", "", "", "", BG9QRY->BG9_INDREA,;
						BG9QRY->BG9_MESREA, BG9QRY->BG9_TIPO,,nPerPad)
			BG9QRY->(DbSkip())
		EndDo
		BG9QRY->(DbCloseArea())
	
		// Reajuste das Familias (Pessoa Fisica)
		cFiltro := 	"SELECT COUNT(*) CONTADOR FROM " + RetSqlName("BA3") + " BA3 "+;
					"WHERE BA3_FILIAL = '" + xFilial("BA3") + "' AND "+;
					"BA3_CODINT >= '" + mv_par03 + "' AND " +;
					"BA3_CODINT <= '" + mv_par04 + "' AND " +;
					"BA3_CODEMP >= '" + mv_par05 + "' AND " +;
					"BA3_CODEMP <= '" + mv_par06 + "' AND " +;
					"BA3_NUMCON >= '" + mv_par07 + "' AND " +;
					"BA3_NUMCON <= '" + mv_par08 + "' AND " +;
					"BA3_SUBCON >= '" + mv_par09 + "' AND " +;
					"BA3_SUBCON <= '" + mv_par10 + "' AND " +;
					"BA3_MATRIC >= '" + Left(mv_par11, Len(BA3->BA3_MATRIC)) + "' AND " +;
					"BA3_MATRIC <= '" + Left(mv_par12, Len(BA3->BA3_MATRIC)) + "' AND " +;
					"BA3_TIPOUS = '1' AND " +;
					"BA3_MESREA = '" + mv_par01 + "' AND BA3_INDREA <> ' ' AND " +;
					"D_E_L_E_T_ = ' ' AND NOT EXISTS(" +;
					"SELECT R_E_C_N_O_ FROM " + RetSqlName("BHW") + " WHERE " +;
					"BHW_FILIAL = '" + xFilial("BHW") + "' AND "+;
					"BHW_STATUS = '" + cStatus + "' AND " +;
					"BHW_CODINT = BA3.BA3_CODINT AND " +;
					"BHW_CODEMP = BA3.BA3_CODEMP AND " +;
					"BHW_CONEMP = BA3.BA3_CONEMP AND " +;
					"BHW_SUBCON = BA3.BA3_SUBCON AND " +;
					"BHW_VERSUB = BA3.BA3_VERSUB AND " +;
					"BHW_MATRIC = BA3.BA3_MATRIC AND " +;
					"BHW_ANOMES = '" + mv_par02 + mv_par01 + "' AND D_E_L_E_T_ = ' ')"
		cFiltro := ChangeQuery(cFiltro)
				
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BA3QRY", .F., .T.)
		ProcRegua(CONTADOR)
		BA3QRY->( DbCloseArea() )
	
		cFiltro := 	"SELECT * FROM " + RetSqlName("BA3") + " BA3 " +;
					"WHERE BA3_FILIAL = '" + xFilial("BA3") + "' AND "+;
					"BA3_CODINT >= '" + mv_par03 + "' AND " +;
					"BA3_CODINT <= '" + mv_par04 + "' AND " +;
					"BA3_CODEMP >= '" + mv_par05 + "' AND " +;
					"BA3_CODEMP <= '" + mv_par06 + "' AND " +;
					"BA3_NUMCON >= '" + mv_par07 + "' AND " +;
					"BA3_NUMCON <= '" + mv_par08 + "' AND " +;
					"BA3_SUBCON >= '" + mv_par09 + "' AND " +;
					"BA3_SUBCON <= '" + mv_par10 + "' AND " +;
					"BA3_MATRIC >= '" + Left(mv_par11, Len(BA3->BA3_MATRIC)) + "' AND " +;
					"BA3_MATRIC <= '" + Left(mv_par12, Len(BA3->BA3_MATRIC)) + "' AND " +;
					"BA3_TIPOUS = '1' AND " +;
					"BA3_MESREA = '" + mv_par01 + "' AND BA3_INDREA <> ' ' AND " +;
					"D_E_L_E_T_ = ' ' AND NOT EXISTS(" +;
					"SELECT R_E_C_N_O_ FROM " + RetSqlName("BHW") + " WHERE " +;
					"BHW_FILIAL = '" + xFilial("BHW") + "' AND "+;
					"BHW_STATUS = '" + cStatus + "' AND " +;
					"BHW_CODINT = BA3.BA3_CODINT AND " +;
					"BHW_CODEMP = BA3.BA3_CODEMP AND " +;
					"BHW_CONEMP = BA3.BA3_CONEMP AND " +;
					"BHW_SUBCON = BA3.BA3_SUBCON AND " +;
					"BHW_VERSUB = BA3.BA3_VERSUB AND " +;
					"BHW_MATRIC = BA3.BA3_MATRIC AND " +;
					"BHW_ANOMES = '" + mv_par02 + mv_par01 + "' AND D_E_L_E_T_ = ' ')" +;
					"ORDER BY BA3_FILIAL, BA3_CODINT, BA3_CODEMP, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB"
					
		cFiltro := ChangeQuery(cFiltro)
			
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BA3QRY", .F., .T.)
		While ! BA3QRY->(Eof())
			BA3->(DbGoTo(BA3QRY->R_E_C_N_O_))
			Pls750AplR(	BA3QRY->BA3_CODINT, BA3QRY->BA3_CODEMP,;
						BA3QRY->BA3_CONEMP, BA3QRY->BA3_VERCON, BA3QRY->BA3_SUBCON,;
						BA3QRY->BA3_VERSUB, BA3QRY->BA3_MATRIC, "", "",;
						BA3QRY->BA3_CODPLA, BA3->BA3_VERSAO, BA3QRY->BA3_INDREA,;
						BA3QRY->BA3_MESREA, BA3QRY->BA3_TIPOUS,,nPerPad)
	
			BA3QRY->(DbSkip())
		EndDo
		BA3QRY->(DbCloseArea())
	Endif

// Reajuste dos Usuarios (Pessoa Juridica ou Fisica)
/*
	cFiltro := 	"SELECT COUNT(*) CONTADOR FROM " + RetSqlName("BA1") + " BA1 "+;
				"WHERE BA1_FILIAL = '" + xFilial("BA1") + "' AND "+;
				"BA1_CODINT >= '" + mv_par03 + "' AND " +;
				"BA1_CODINT <= '" + mv_par04 + "' AND " +;
				"BA1_CODEMP >= '" + mv_par05 + "' AND " +;
				"BA1_CODEMP <= '" + mv_par06 + "' AND " +;
				"BA1_MATRIC >= '" + Left(mv_par11, Len(BA1->BA1_MATRIC)) + "' AND " +;
				"BA1_MATRIC <= '" + Left(mv_par12, Len(BA1->BA1_MATRIC)) + "' AND " +;
				"BA1_TIPREG >= '" + Right(mv_par11, Len(BA1->BA1_TIPREG)) + "' AND " +;
				"BA1_TIPREG <= '" + Right(mv_par12, Len(BA1->BA1_TIPREG)) + "' AND " +;
				"BA1_NUMCON = ' ' AND BA1_SUBCON = ' ' AND " +;
				"BA1_MESREA = '" + mv_par01 + "' AND BA1_INDREA <> ' ' AND " +;
				"D_E_L_E_T_ = ' ' AND NOT EXISTS(" +;
				"SELECT R_E_C_N_O_ FROM " + RetSqlName("BHW") + " WHERE " +;
				"BHW_FILIAL = '" + xFilial("BHW") + "' AND "+;
				"BHW_STATUS = '" + cStatus + "' AND " +;
				"BHW_CODINT = BA1.BA1_CODINT AND " +;
				"BHW_CODEMP = BA1.BA1_CODEMP AND " +;
				"BHW_CONEMP = BA1.BA1_CONEMP AND " +;
				"BHW_SUBCON = BA1.BA1_SUBCON AND " +;
				"BHW_VERSUB = BA1.BA1_VERSUB AND " +;
				"BHW_MATRIC = BA1.BA1_MATRIC AND " +;
				"BHW_TIPREG = BA1.BA1_TIPREG AND " +;
				"BHW_DIGITO = BA1.BA1_DIGITO AND " +;
				"BHW_ANOMES = '" + mv_par02 + mv_par01 + "' AND D_E_L_E_T_ = ' ')"
	cFiltro := ChangeQuery(cFiltro)
			
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BA1QRY", .F., .T.)
	ProcRegua(CONTADOR)
	DbCloseArea()

	cFiltro := 	"SELECT * FROM " + RetSqlName("BA1") + " BA1, " + RetSqlName("BA3") + " BA3 " +;
				"WHERE BA1_FILIAL = '" + xFilial("BA1") + "' AND "+;
				"BA1_CODINT >= '" + mv_par03 + "' AND " +;
				"BA1_CODINT <= '" + mv_par04 + "' AND " +;
				"BA1_CODEMP >= '" + mv_par05 + "' AND " +;
				"BA1_CODEMP <= '" + mv_par06 + "' AND " +;
				"BA1_MATRIC >= '" + Left(mv_par11, Len(BA1->BA1_MATRIC)) + "' AND " +;
				"BA1_MATRIC <= '" + Left(mv_par12, Len(BA1->BA1_MATRIC)) + "' AND " +;
				"BA1_TIPREG >= '" + Right(mv_par11, Len(BA1->BA1_TIPREG)) + "' AND " +;
				"BA1_TIPREG <= '" + Right(mv_par12, Len(BA1->BA1_TIPREG)) + "' AND " +;
				"BA1_NUMCON = ' ' AND BA1_SUBCON = ' ' AND " +;
				"BA1_MESREA = '" + mv_par01 + "' AND BA1_INDREA <> ' ' AND " +;
				"BA1.D_E_L_E_T_ = ' ' AND "+;
				"BA3_FILIAL = '" + xFilial("BA3") + "' AND "+;
				"BA3_CODINT = BA1.BA1_CODINT AND " +;
				"BA3_CODEMP = BA1.BA1_CODEMP AND " +;
				"BA3_MATRIC = BA1.BA1_MATRIC AND " +;
				"BA3_CONEMP = ' ' AND BA3_SUBCON = ' 'AND BA3.D_E_L_E_T_ = ' ' AND "+;
				"NOT EXISTS(" +;
				"SELECT R_E_C_N_O_ FROM " + RetSqlName("BHW") + " WHERE " +;
				"BHW_FILIAL = '" + xFilial("BHW") + "' AND "+;
				"BHW_STATUS = '" + cStatus + "' AND " +;
				"BHW_CODINT = BA1.BA1_CODINT AND " +;
				"BHW_CODEMP = BA1.BA1_CODEMP AND " +;
				"BHW_CONEMP = BA1.BA1_CONEMP AND " +;
				"BHW_SUBCON = BA1.BA1_SUBCON AND " +;
				"BHW_VERSUB = BA1.BA1_VERSUB AND " +;
				"BHW_MATRIC = BA1.BA1_MATRIC AND " +;
				"BHW_TIPREG = BA1.BA1_TIPREG AND " +;
				"BHW_DIGITO = BA1.BA1_DIGITO AND " +;
				"BHW_ANOMES = '" + mv_par02 + mv_par01 + "' AND D_E_L_E_T_ = ' ')" +;
				"ORDER BY BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB"
				
	cFiltro := ChangeQuery(cFiltro)
		
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BA1QRY", .F., .T.)
	While ! BA1QRY->(Eof())
		Pls750AplR(	BA1QRY->BA1_CODINT, BA1QRY->BA1_CODEMP,;
					BA1QRY->BA1_CONEMP, BA1QRY->BA1_VERCON, BA1QRY->BA1_SUBCON,;
					BA1QRY->BA1_VERSUB, BA1QRY->BA1_MATRIC, BA1QRY->BA1_TIPREG,;
					BA1QRY->BA1_DIGITO, BA1QRY->BA3_CODPLA, BA1QRY->BA3_VERSAO,;
					BA1QRY->BA1_INDREA, BA1QRY->BA1_MESREA, "1",,nPerPad)

		BA1QRY->(DbSkip())
	EndDo
	BA1QRY->(DbCloseArea())
*/
	If ! Empty(cAlias)
		DbSelectArea(cAlias)
	Endif
Endif

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS750Efe  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 25.08.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Efetiva a simulacao de reajuste em calculo a partir selecao³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS750Efe

Local cFiltro
LOCAL nMin
LOCAL nMax
LOCAL nCont
LOCAL cChave
LOCAL cAlias 	:= Alias()
LOCAL nCnt 		:= 0
LOCAL _nValRea
LOCAL i 	  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros verificar Pls750Rea()   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Pergunte("PLS750", .T.)
	cFiltro := 	"SELECT MIN(R_E_C_N_O_) MINRECNO, " +;
				"MAX(R_E_C_N_O_) MAXRECNO FROM " + RetSqlName("BHW") + " " +;
				"WHERE BHW_FILIAL = '" + xFilial("BHW") + "' AND "+;
				"BHW_CODINT >= '" + mv_par03 + "' AND " +;
				"BHW_CODINT >= '" + mv_par04 + "' AND " +;
				"BHW_CODEMP >= '" + mv_par05 + "' AND " +;
				"BHW_CODEMP <= '" + mv_par06 + "' AND " +;
				"BHW_CONEMP >= '" + mv_par07 + "' AND " +;
				"BHW_CONEMP <= '" + mv_par08 + "' AND " +;
				"BHW_SUBCON >= '" + mv_par09 + "' AND " +;
				"BHW_SUBCON <= '" + mv_par10 + "' AND " +;
				"BHW_MATRIC >= '" + mv_par11 + "' AND " +;
				"BHW_MATRIC <= '" + mv_par12 + "' AND " +;
				"BHW_CODPLA >= '" + mv_par13 + "' AND " +;
				"BHW_CODPLA <= '" + mv_par14 + "' AND " +;
				"BHW_ANOMES = '" + mv_par02 + mv_par01 + "' AND BHW_DIGITA = '0' AND " +;
				"BHW_STATUS = '0' AND D_E_L_E_T_ = ' '"
	cFiltro := ChangeQuery(cFiltro)
		
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BHWQRY", .F., .T.)
	nMin := BHWQRY->MINRECNO
	nMax := BHWQRY->MAXRECNO
	BHWQRY->( DbCloseArea() )

	cFiltro := 	"SELECT * FROM "+RetSqlName("BHW")+" " +;
				"WHERE BHW_FILIAL = '" + xFilial("BHW") + "' AND "+;
				"BHW_CODINT >= '" + mv_par03 + "' AND " +;
				"BHW_CODINT >= '" + mv_par04 + "' AND " +;
				"BHW_CODEMP >= '" + mv_par05 + "' AND " +;
				"BHW_CODEMP <= '" + mv_par06 + "' AND " +;
				"BHW_CONEMP >= '" + mv_par07 + "' AND " +;
				"BHW_CONEMP <= '" + mv_par08 + "' AND " +;
				"BHW_SUBCON >= '" + mv_par09 + "' AND " +;
				"BHW_SUBCON <= '" + mv_par10 + "' AND " +;
				"BHW_MATRIC >= '" + mv_par11 + "' AND " +;
				"BHW_MATRIC <= '" + mv_par12 + "' AND " +;
				"BHW_CODPLA >= '" + mv_par13 + "' AND " +;
				"BHW_CODPLA <= '" + mv_par14 + "' AND " +;
				"BHW_ANOMES = '" + mv_par02 + mv_par01 + "' AND BHW_DIGITA = '0' AND " +;
				"BHW_STATUS = '0' AND D_E_L_E_T_ = ' '"

	PlsQuery(cFiltro,"TRBBHW")
	
	TRBBHW->( dbGotop() ) 
	While !TRBBHW->( Eof() )
		If TRBBHW->BHW_TIPOUS == "2"
			BT9->( dbSetOrder(01) )              
			// Acho a forma de cobranca do sub-contrato
			If BT9->( dbSeek(xFilial("BT9")+TRBBHW->BHW_CODINT+TRBBHW->BHW_CODEMP+TRBBHW->BHW_CONEMP+;
											 TRBBHW->BHW_VERCON+TRBBHW->BHW_SUBCON+TRBBHW->BHW_VERSUB+;
											 TRBBHW->BHW_CODPLA+TRBBHW->BHW_VERSAO) )
											 
		       	If BT9->BT9_CODFOR == '101' // Faixas etarias...
            		cFiltro := "SELECT *, R_E_C_N_O_ AS RECNO FROM "+RetSqlName("BTN")+" WHERE BTN_FILIAL = '"+xFilial("BTN")+"' AND "+;
            		"BTN_CODIGO = '"+TRBBHW->BHW_CODINT+TRBBHW->BHW_CODEMP+"' AND " +;
            		"BTN_NUMCON = '"+TRBBHW->BHW_CONEMP+"' AND BTN_VERCON = '"+TRBBHW->BHW_VERCON+"' AND " +;
            		"BTN_SUBCON = '"+TRBBHW->BHW_SUBCON+"' AND BTN_VERSUB = '"+TRBBHW->BHW_VERSUB+"' AND " +;
            		"BTN_CODPRO = '"+TRBBHW->BHW_CODPLA+"' AND BTN_VERPRO = '"+TRBBHW->BHW_VERSAO+"' AND " +;
            		"BTN_CODFOR = '"+BT9->BT9_CODFOR+"' AND BTN_TABVLD = '' AND D_E_L_E_T_ = ' ' "
            		PlsQuery(cFiltro, "TRBBTN")       
            		   
            		TRBBTN->( dbGotop() )
           			// Primeiro reajusta as faixas do contrato...
           			While !TRBBTN->( Eof() )
           				BTN->( dbGoto(TRBBTN->RECNO) )
           				If !BTN->( Eof() )
           					BTN->( Reclock("BTN",.F.) )
           						BTN->BTN_TABVLD := Date()
           					BTN->( MsUnlock() )
           				Endif
           				                                    
           				BTN->( Reclock("BTN", .T.) )
            				For nCnt := 1 To BTN->(fCount())
								If Alltrim( BTN->(Field(nCnt)) ) == "BTN_TABVLD"
    	        					BTN->( FieldPut(nCnt,cTod('')) )
    	        					
    	        				Elseif Alltrim( BTN->(Field(nCnt)) ) == "BTN_VALFAI"
    	        				    _nValRea := TRBBTN->(FieldGet(nCnt))
    	        					BTN->( Fieldput(nCnt, (_nValRea+((_nValRea*TRBBHW->BHW_PERPAD)/100))) )
    	        					
								Elseif Alltrim( BTN->(Field(nCnt)) ) == "BTN_PERREJ"
									BTN->( FieldPut(nCnt, Date()) )
									
								Elseif Alltrim( BTN->(Field(nCnt)) ) == "BTN_PERREJ"
									BTN->( FieldPut(nCnt,((_nValRea*TRBBHW->BHW_PERPAD)/100)) )
								
								Else
    	        					BTN->( FieldPut(nCnt, TRBBTN->(FieldGet(nCnt))) )	
    	        				Endif
   	        				Next    
   	        			BTN->( MsUnlock() )
   	        			TRBBTN->( dbSkip() )
   	        		Enddo
            	    TRBBTN->( dbCloseArea() )
            	    
            	    // Agora reajusta no nivel da Familia...
					cFiltro := "SELECT * FROM "+RetSqlName("BA3")+" WHERE BA3_FILIAL = '"+xFilial("BA3")+"' "
					cFiltro += "AND BA3_CODINT = '"+TRBBHW->BHW_CODINT+"' "
					cFiltro += "AND BA3_CODEMP = '"+TRBBHW->BHW_CODEMP+"' "
					cFiltro += "AND BA3_CONEMP = '"+TRBBHW->BHW_CONEMP+"' "
					cFiltro += "AND BA3_VERCON = '"+TRBBHW->BHW_VERCON+"' "
					cFiltro += "AND BA3_SUBCON = '"+TRBBHW->BHW_SUBCON+"' "
					cFiltro += "AND BA3_VERSUB = '"+TRBBHW->BHW_VERSUB+"' "
					If !Empty(TRBBHW->BHW_MATRIC)
						cFiltro += "AND BA3_MATRIC = '"+TRBBHW->BHW_MATRIC+"' "
					Endif
					cFiltro += "AND D_E_L_E_T_ = '' "
					PlsQuery(cFiltro,"TRBBA3")   
					              
					While !TRBBA3->( Eof() )
						BJK->( dbSetorder(01) )	   
						If BJK->( dbSeek(xFilial("BJK")+TRBBA3->BA3_CODINT+TRBBA3->BA3_CODEMP+TRBBA3->BA3_MATRIC) )
					
							cFiltro := "SELECT *, R_E_C_N_O_ AS RECNO FROM "+RetSqlName("BBU")+" WHERE BBU_FILIAL = '"+xFilial("BBU")+"' "
							cFiltro += "AND BBU_CODOPE = '"+BJK->BJK_CODOPE+"' "
							cFiltro += "AND BBU_CODEMP = '"+BJK->BJK_CODEMP+"' "
							cFiltro += "AND BBU_MATRIC = '"+BJK->BJK_MATRIC+"' "
							cFiltro += "AND BBU_CODFOR = '"+BJK->BJK_CODFOR+"' "
							cFiltro += "AND D_E_L_E_T_ = ' ' "
							PlsQuery(cFiltro, "TRBBBU")
					               
							While !TRBBBU->( Eof() ) 
								BBU->( dbGoto(TRBBBU->RECNO) )
								BBU->( RecLock("BBU",.F.) )
									BBU->BBU_TABVLD := Date()
								BBU->( MsUnlock() )
								
								BBU->( RecLock("BBU", .T.) )
									For i := 1 To BBU->( fCount() )  
										If Alltrim( BTN->(Field(i)) ) == "BBU_TABVLD"
    			        					BBU->( FieldPut(i,cTod('')) )
    			        					
    	    		    				Elseif Alltrim( BBU->(Field(i)) ) == "BBU_VALFAI"
    	        						    _nValRea := TRBBBU->(FieldGet(i))
    	        							BBU->( Fieldput(i, (_nValRea+((_nValRea*TRBBHW->BHW_PERPAD)/100))) )
    	        							
										Elseif Alltrim( BBU->(Field(i)) ) == "BBU_PERREJ"
											BBU->( FieldPut(i, Date()) )
											
										Elseif Alltrim( BBU->(Field(i)) ) == "BBU_PERREJ"
											BBU->( FieldPut(i,((_nValRea*TRBBHW->BHW_PERPAD)/100)) )
										
										Else
    	        							BBU->( FieldPut(i, TRBBBU->(FieldGet(i))) )	
    	        							
    	        						Endif
    	    						Next
    	    					BBU->( msUnlock() )
    	    					TRBBBU->( dbSkip() )
							Enddo
							TRBBBU->( dbClosearea() )
					    Else
					    	// gera critica
					    Endif
					    TRBBA3->( dbSkip() )
					Enddo
					TRBBA3->( dbCloseArea() )
				Elseif BT9->BT9_CODFOR == '105'
					BWD->( dbSetorder(01) )
					If BWD->( dbSeek(xFilial("BWD")+BT9->BT9_CODIGO+BT9->BT9_NUMCON+BT9->BT9_VERCON+;
													 BT9->BT9_SUBCON+BT9->BT9_VERSUB+BT9->BT9_CODPRO+;
													 BT9->BT9_VERSAO+BT9->BT9_CODFOR) )
													 
						While !BWD->( Eof() ) .and. BWD->BWD_CODIGO+BWD->BWD_NUMCON+BWD->BWD_VERCON+;
													 BWD->BWD_SUBCON+BWD->BWD_VERSUB+BWD->BWD_CODPRO+;
													 BWD->BWD_VERPRO+BWD->BWD_CODFOR ==;
													 BT9->BT9_CODIGO+BT9->BT9_NUMCON+BT9->BT9_VERCON+;
													 BT9->BT9_SUBCON+BT9->BT9_VERSUB+BT9->BT9_CODPRO+;
													 BT9->BT9_VERSAO+BT9->BT9_CODFOR	 
	 						BWD->( Reclock("BWD",.F.) )						 
		       				    BWD->BWD_VALOR := (BWD->BWD_VALOR+(BWD->BWD_VALOR*TRBBHW->BHW_PERPAD)/100)
							BWD->( MsUnlock() )
							
           					BWD->( dbSkip() )
						Enddo
					Endif
				Endif
            Endif					
	    Endif
		TRBBHW->( dbSkip() )                                                                          
		
	Enddo
    
    // Fecha area de trabalho!
	TRBBHW->( dbclosearea() )
	
	cFiltro := 	"UPDATE " + RetSqlName("BWZ") + " SET BWZ_STATUS = '1' " +;
				"WHERE BWZ_FILIAL = '" + xFilial("BWZ") + "' AND "+;
				"BWZ_CODINT >= '" + mv_par03 + "' AND " +;
				"BWZ_CODINT >= '" + mv_par04 + "' AND " +;
				"BWZ_CODEMP >= '" + mv_par05 + "' AND " +;
				"BWZ_CODEMP <= '" + mv_par06 + "' AND " +;
				"BWZ_CONEMP >= '" + mv_par07 + "' AND " +;
				"BWZ_CONEMP <= '" + mv_par08 + "' AND " +;
				"BWZ_SUBCON >= '" + mv_par09 + "' AND " +;
				"BWZ_SUBCON <= '" + mv_par10 + "' AND " +;
				"BWZ_MATRIC >= '" + mv_par11 + "' AND " +;
				"BWZ_MATRIC <= '" + mv_par12 + "' AND " +;
				"BWZ_CODPLA >= '" + mv_par13 + "' AND " +;
				"BWZ_CODPLA <= '" + mv_par14 + "' AND " +;
				"BWZ_ANOMES = '" + mv_par02 + mv_par01 + "' AND BWZ_DIGITA = '0' AND " +;
				"BWZ_STATUS = '0' AND D_E_L_E_T_ = ' '"
	ProcRegua(0)
	
	For nCont := nMin To nMax STEP 1024
		cChave := "AND R_E_C_N_O_>="+Str(nCont,10,0)+" AND R_E_C_N_O_<="+Str(nCont+1023,10,0)+""
		TcSqlExec(cFiltro+cChave)
		IncProc(STR0023) //"Efetivando simulacao de reajuste selecionadas ..."
	Next nCont

	If ! Empty(cAlias)
		DbSelectArea(cAlias)
	Endif
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ Pls750AplR ³ Autor ³ Wagner Mobile Costa ³ Data ³ 05.09.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Aplica o reajuste automatico de acordo com o tipo reajuste ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pls750AplR(cCodInt, cCodEmp, cNumCon, cVerCon, cSubCon, cVerSub, cMatric,;
					cTipReg, cDigito, cProduto, cVerPla, cIndRea, cMesRea, cTipoUs, lFaixas,nPerPad)

Local cAnoAnt 	:= mv_par02, cMesAnt := cMesRea
Local cDtosRea := cDtosAtu :=""

If cMesRea = "01"
	cMesAnt := "12"
	cAnoAnt := Str(Val(mv_par02) - 1, 4)
Else
	cMesAnt := StrZero(Val(cMesRea) - 1, 2)
Endif

cDtosRea := Dtos(LastDay(Ctod("01/" + cMesAnt + "/" + cAnoAnt)))
If Left(Dtos(dDataBase), 6) = mv_par02 + cMesRea
	cDtosAtu := Dtos(dDataBase)
Else
	cDtosAtu := Dtos(LastDay(Ctod("01/" + cMesRea + "/" + mv_par02)))
Endif

M->BHW_MESANO := mv_par01 + mv_par02
M->BHW_NROUSU := 0
M->BHW_VALOR  := 0
PLS750Usu(	cCodInt, cCodEmp, cNumCon, cVerCon, cSubCon, cVerSub, cMatric, cTipReg,;
			cProduto, cVerPla)

// Indices por data
If ! AAE->(DbSeek(xFilial("AAE") + cIndRea + cDtosAtu))
	AAE->(DbSeek(xFilial("AAE") + cIndRea + cDtosRea, .T.))
Endif
					
If 	AAE->AAE_FILIAL = xFilial("AAE") .And. AAE->AAE_CODIND = cIndRea
	RecLock("BHW", .T.)
	BHW->BHW_FILIAL := xFilial("BHW")
	BHW->BHW_CODINT := cCodInt
	BHW->BHW_CODEMP := cCodEmp
	BHW->BHW_CONEMP := cNumCon
	BHW->BHW_VERCON := cVerCon
	BHW->BHW_SUBCON := cSubCon
	BHW->BHW_VERSUB := cVerSub
	BHW->BHW_CODPLA := cProduto
	BHW->BHW_VERSAO := cVerPla
	BHW->BHW_MATRIC := cMatric
	BHW->BHW_TIPREG := cTipReg
	BHW->BHW_DIGITO := cDigito
	BHW->BHW_TIPOUS := cTipoUs
	BHW->BHW_PERPAD := nPerPad  //AAE->AAE_INDICE
	BHW->BHW_ANOMES := mv_par02 + mv_par01
	BHW->BHW_NROUSU := M->BHW_NROUSU
	BHW->BHW_VALOR  := M->BHW_VALOR
	BHW->BHW_DIGITA := "0"		// Calculado
	BHW->BHW_STATUS := cStatus	// Tipo de Calculo - Simulacao/Reajuste
	BHW->(MsUnLock())	 
	If cStatus = "1" .And. ! Empty(cMatric) // Reajuste da familia
		RecLock("BA3", .T.)
		BA3->BA3_ULREA := mv_par02 + mv_par01	// Marca efetuada para facilitar
		BA3->(MsUnLock())	 					// Cobranca
	Endif                                       
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA750Par ³ Autor ³ Wagner Mobile Costa ³ Data ³ 16.09.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Abre tela demonstrando parcelamento do reajuste            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA750Par(nOpc)

Local oParcelado, nOpcA := 0

If M->BHW_PARREA < 2
	Return .T.
Endif

If Len(aColsBWZ) = 0
	PLSA750Hea("BHW")
	Store COLS Blank "BWZ" TO aColsBWZ FROM aCabBWZ
Endif

DEFINE MSDIALOG oParcelado TITLE STR0010 FROM 000,000 TO 180,395 OF oMainWnd PIXEL //"Parcelamento do Reajuste"

oGetBWZ := TPLSBrw():New(005,007,190,70,nil  ,oParcelado,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBWZ  ,aColsBWZ,.F.      ,"BWZ" ,nOpc,STR0010,nil,nil,nil,nil) //"Parcelamento do Reajuste"
oGetBWZ:aCampos := AClone(aCampos)

oSBtn2 := SBUTTON():Create(oParcelado)
oSBtn2:cName := "oSBtn2"
oSBtn2:cCaption := "oSBtn2"
oSBtn2:nLeft := 8
oSBtn2:nTop := 145
oSBtn2:nWidth := 52
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.

oSBtn2:bAction := { || If(Pl750POk(), (nOpcA := 1,oParcelado:End()), nOpcA := 0) }
oSBtn2:nType := 1		// Ok

oSBtn3 := SBUTTON():Create(oParcelado)
oSBtn3:cName := "oSBtn3"
oSBtn3:cCaption := "oSBtn3"
oSBtn3:nLeft := 330
oSBtn3:nTop := 145
oSBtn3:nWidth := 52
oSBtn3:nHeight := 22
oSBtn3:lShowHint := .F.
oSBtn3:lReadOnly := .F.
oSBtn3:Align := 0
oSBtn3:lVisibleControl := .T.
oSBtn3:bAction := { || nOpcA := 0,oParcelado:End() }
oSBtn3:nType := 2

ACTIVATE MSDIALOG oParcelado CENTERED

If nOpcA = 1
	aCabBWZ := AClone(oGetBWZ:aHeader)
	aColsBWZ := AClone(oGetBWZ:aCols)
Endif

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA750Fai ³ Autor ³Geraldo Felix Junior ³ Data ³ 30.01.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Abre tela demonstrando as Faixas etarias reajustadas...    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA750Fai()
LOCAL oFaixas
LOCAL oGetBTU

If Len(aColsBTU) = 0
	PLSA750Hea("BTU")
	Store COLS Blank "BTU" TO aColsBTU FROM aCabBTU
Endif

DEFINE MSDIALOG oFaixas TITLE STR0011 FROM 000,000 TO 180,395 OF oMainWnd PIXEL //"Faixas Etarias"

oGetBTU := TPLSBrw():New(005,007,190,70,nil  ,oFaixas,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBTU  ,aColsBTU,.F.      ,"BTU" ,2,STR0011,nil,nil,nil,nil) //"Faixas Etarias"

oSBtn2 := SBUTTON():Create(oFaixas)
oSBtn2:cName := "oSBtn2"
oSBtn2:cCaption := "oSBtn2"
oSBtn2:nLeft := 8
oSBtn2:nTop := 145
oSBtn2:nWidth := 52
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.

oSBtn2:bAction := { ||(nOpcA := 1,oFaixas:End()) }
oSBtn2:nType := 1		// Ok

oSBtn3 := SBUTTON():Create(oFaixas)
oSBtn3:cName := "oSBtn3"
oSBtn3:cCaption := "oSBtn3"
oSBtn3:nLeft := 330
oSBtn3:nTop := 145
oSBtn3:nWidth := 52
oSBtn3:nHeight := 22
oSBtn3:lShowHint := .F.
oSBtn3:lReadOnly := .F.
oSBtn3:Align := 0
oSBtn3:lVisibleControl := .T.
oSBtn3:bAction := { || nOpcA := 0,oFaixas:End() }
oSBtn3:nType := 2

ACTIVATE MSDIALOG oFaixas CENTERED

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS750Ger  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 16.09.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Carrega parcelamento do reajuste no Array                  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS750Ger

Local nCols
Local nPERREJ
Local nPERPAD
Local cAnoRea := Right(M->BHW_MESANO, 4), cMesRea := Left(M->BHW_MESANO, 2)

If M->BHW_PARREA < 2
	For nCols := 1 To Len(aColsBWZ)
		aColsBWZ[nCols][Len(aColsBWZ[nCols])] := .T.		// Marco como deletado
	Next

	Return .T.
Endif

If Len(aColsBWZ) = 0
	PLSA750Hea("BHW")
	Store COLS Blank "BWZ" TO aColsBWZ FROM aCabBWZ
Endif

nPERREJ := Ascan(aCabBWZ, {|x| AllTrim(x[2]) = "BWZ_PERREJ" })
nPERPAD := Ascan(aCabBWZ, {|x| AllTrim(x[2]) = "BWZ_PERPAD" })

For nCols := 1 To Len(aColsBWZ)
	aColsBWZ[nCols][Len(aColsBWZ[nCols])] := .T.		// Marco como deletado
Next

For nCols := 1 To M->BHW_PARREA
	If nCols > Len(aColsBWZ)
		Aadd(aColsBWZ, AClone(aColsBWZ[1]))
	Endif
	aColsBWZ[nCols][nPerREJ] := cAnoRea + cMesRea
	aColsBWZ[nCols][nPerPad] := M->BHW_PERPAD / M->BHW_PARREA
	aColsBWZ[nCols][Len(aColsBWZ[nCols])] := .F.		// Marco como deletado

	If cMesRea = "12"
		cMesRea := "01"
		cAnoRea := Str(Val(cAnoRea) + 1, 4)
	Else
		cMesRea := StrZero(Val(cMesRea) + 1, 2)
	Endif
Next

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS750Grv  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 16.09.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Grava dados da tabela auxiliar BWZ                         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS750Grv

If cStatus = "1" .And. ! Empty(M->BHW_MATRIC) 	// Reajuste da familia
	BA3->(DbSetOrder(1))						// Marca efetuada para facilitar Cobranca
	If BA3->(DbSeek(xFilial("BA3") + M->BHW_CODINT + M->BHW_CODEMP + M->BHW_MATRIC +;
					M->BHW_CONEMP + M->BHW_VERCON + M->BHW_SUBCON + M->BHW_VERSUB))
		BA3->(RecLock("BA3"))
		BA3->BA3_ULREA := M->BHW_ANOMES
		BA3->(MsUnLock())
	Endif
Endif                                       	

PLUPTCOLS("BWZ",aColsBWZ,aCabBWZ,aVETBWZ,__OPC,;
{ 	{ "BWZ_STATUS", M->BHW_STATUS }, { "BWZ_CODINT", M->BHW_CODINT },;
	{ "BWZ_CODEMP", M->BHW_CODEMP }, { "BWZ_CONEMP", M->BHW_CONEMP },;
	{ "BWZ_VERCON", M->BHW_VERCON }, { "BWZ_SUBCON", M->BHW_SUBCON },;
	{ "BWZ_VERSUB", M->BHW_VERSUB }, { "BWZ_MATRIC", M->BHW_MATRIC },;
	{ "BWZ_TIPREG", M->BHW_TIPREG }, { "BWZ_DIGITO", M->BHW_DIGITO },;
	{ "BWZ_CODPLA", M->BHW_CODPLA }, { "BWZ_VERSAO", M->BHW_VERSAO },;
	{ "BWZ_ANOMES", M->BHW_ANOMES } },.T.)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA750Hea ³ Autor ³ Wagner Mobile Costa ³ Data ³ 16.09.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Carrega aHeader com coluna a mais o do reajuste            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA750Hea(cAlias)

Local nHeader
                                     
If cAlias == "BZW"
	Store Header "BWZ" TO aCabBWZ For .T.
	For nHeader := 1 To Len(aCabBWZ)
		Aadd(aCampos, aCabBWZ[nHeader][2])
	Next
	Aadd(aCABBWZ, AClone(aCABBWZ[1]))	// Coluna para melhorar visualizacao do browse
	aCabBWZ[Len(aCabBWZ)][1] := ""
	aCabBWZ[Len(aCabBWZ)][2] := "BWZ_FILIAL"
	aCabBWZ[Len(aCabBWZ)][3] := ""
	aCabBWZ[Len(aCabBWZ)][4] := 0
	aCabBWZ[Len(aCabBWZ)][10] := "V"
Else
	Store Header "BTU" TO aCabBWZ For .T.
Endif


Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ Pl750POk   ³ Autor ³ Wagner Mobile Costa ³ Data ³ 16.09.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Verifica se o total de reajuste informado eh igual ao base ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pl750POk

Local lRet := .T., nPer := nCols := 0
Local nPERPAD := Ascan(aCabBWZ, {|x| AllTrim(x[2]) = "BWZ_PERPAD" })
Local nCols

For nCols := 1 To Len(oGetBWZ:aCols)
	If ! oGETBWZ:IsDeleted(nCols)
		nPer += oGETBWZ:aCols[nCols][nPerPAD]
	Endif
Next

If nPer <> M->BHW_PERPAD
	ApMsgAlert(STR0024, STR0014) //"O total do parcelamento deve ter o mesmo valor da base para reajuste !"###"Atencao"
	lRet := .F.
Endif

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA750   ºAutor  ³Microsiga           º Data ³  01/29/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLS750IduSR(cCodInt,cCodigo,cNumCon,cVerCon,cSubCon,cVerSub,nIdaIni,nIdaFin)
LOCAL cFiltro                   
LOCAL nValRet 	:= 0        
DEFAULT nIdaIni := 0
DEFAULT nIdaFin := 999

cFiltro := 	"Select Count(*) AS QUANT FROM "+RetSqlName("BA1")+" WHERE BA1_FILIAL = '"+xFilial("BA1")+"' AND " +;
"BA1_CODINT = '"+cCodInt+"' AND BA1_CODEMP = '"+cCodigo+"' AND BA1_CONEMP = '"+cNumCon+"' AND " +;
"BA1_VERCON = '"+cVerCon+"' AND BA1_SUBCON = '"+cSubCon+"' AND BA1_VERSUB = '"+cVerSub+"' AND " +;
"DATEDIFF(year, BA1_DATNAS, '"+mv_par02 + mv_par01 + "01"+"') >= "+Alltrim(Str(nIdaIni))+" AND " +;
"DATEDIFF(year, BA1_DATNAS, '"+mv_par02 + mv_par01 + "01"+"') <= "+Alltrim(Str(nIdaFin))+" AND " +;
"D_E_L_E_T_ = ' '"

If AllTrim(TCGetDB()) == "ORACLE"
   cFiltro := StrTran(cFiltro,"DATEDIFF(year,","U_DATEDIFF(")
Endif   
	
PLSQuery(cFiltro,"QTDUSR")
nValRet :=  QTDUSR->QUANT           	

QTDUSR->( dbCloseArea() )

Return(nValRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL750IND  ºAutor  ³Geraldo Felix Jr.   º Data ³  02/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho para obter o percentual do reajuste baseado no     º±±
±±º          ³campo indice de reajuste no grupo/contrato/sub contrato/fam.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL750IND(cAlias, cChave,nOrdem)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declara variaveis... Salva area de trabalho anterior...      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aArea 	:= Getarea()
LOCAL cSql		:= ''   
LOCAL cCpoInd   := cAlias+"->"+cAlias+"_INDREA"   // Monta campo com o indice do reajuste...
LOCAL nRet		:= 0                                             

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona a origem do indice de reajuste...                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectarea(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o indice atual...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSql := "SELECT * FROM AAE010 WHERE AAE_DATA IN (SELECT max(AAE_DATA) "+;
        "FROM AAE010 WHERE AAE_CODIND = '"+&cCpoInd+"')"
PLSQUERY(cSql,"TRBIND")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara a variavel para retornar                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRet := TRBIND->AAE_INDICE         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha o arquivo de trabalho...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRBIND->( dbCloseArea() )
                                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ restaura a area...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)
                                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna indice do reajuste...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nRet)


