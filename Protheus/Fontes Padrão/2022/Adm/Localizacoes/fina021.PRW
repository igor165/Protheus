#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINA021.CH"

Static lFWCodFil := .t.

FUNCTION FINA021()
FINA021A()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA021A  º Autor ³ WAGNER MONTENEGRO  º Data ³  05/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro / Configuração de Impostos                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Republica Dominicana                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FINA021A(aRotAuto, nOpcAuto)
PRIVATE cCadastro := STR0001 //"Configuração de Impostos"
PRIVATE aAutoCab 	:= aRotAuto
PRIVATE lF021Auto := ( aRotAuto <> NIL )
PRIVATE aRotina := MenuDef()
Private bFiltraBrw
Private aIndex		:= {}
PRIVATE lDeleta := .F.
PRIVATE cFRMABT := ""
PRIVATE cFRMTIT := ""
cCondicao := "FINA021FIL()" 	//Função de Condição para bFiltraBrw - FRM->FRM_FILIAL==xFilial('FRM') .AND. FRM->FRM_SEQ=="000"
DbSelectArea("FRM")
dbSetOrder(1)
bFiltraBrw := {|| FilBrowse("FRM",@aIndex,@cCondicao)}
Eval( bFiltraBrw )
FRM->(DbGoTop())
If lF021Auto
	DEFAULT nOpcAuto := 3
	MBrowseAuto(nOpcAuto,aAutoCab,"FRM")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6,1,22,75,"FRM")
Endif
EndFilBrw("FRM",aIndex)
RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ WAGNER MONTENEGRO      ³ Data ³05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Private aRotina := {	 {STR0002,"AxPesqui"	 ,0,1} ,;
			             {STR0003,"FA021Vis",0,2} ,;
			             {STR0004,"FA021Inc",0,3} ,;
			             {STR0005,"FA021Alt",0,4} ,;
			             {STR0006,"FA021Exc"  ,0,5} }
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA021VISº Autor ³ WAGNER MONTENEGRO  º Data ³  05/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ VISUALIZAÇÃO DA CONFIGURAÇÃO DE IMPOSTOS                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Sintaxe   ³ FA021VIS(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ Republica Dominicana                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION FA021Vis( cAlias,nReg,nOpc )
lDeleta:=.F.
FA021Alt( cAlias,nReg,nOpc )
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FA021Inc³ Autor ³ WAGNER MONTENEGRO     ³ Data ³ 05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ INCLUSÃO DE CONFIGURAÇÃO DE IMPOSTOS                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FA021Inc(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ REPUBLICA DOMINICANA                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA021Inc(cAlias,nReg,nOpc)
Local nOpca
Local cTudoOk
Local cTransact := Nil
Local	aSize   := MsAdvSize()
Local	aInfo
Local aObjects
Local aObj
Local oDlg
Local nX
Local bCampo    := {|nCPO| Field(nCPO)}
Local aButtons	:= {}
Local cOk       := ""
Local aFolders	:=	{}
Local aNoFields := {"FRM_FILIAL","FRM_COD","FRM_DSCIMP","FRM_CARTEI","FRM_SIGLA","FRM_TPABT","FRM_TPTIT","FRM_MSBLQL"}
Local aAcho		:= {"FRM_COD","FRM_DSCIMP","FRM_SIGLA","FRM_CARTEI","FRM_TPABT","FRM_TPTIT","FRM_MSBLQL","FRM_RGPARC"}
Local aAlter    := FA021Cpos(aAcho) //Para popular o array da MsGetdados, deve ser passado o array da Enchoice
Local aCpos	    :=	aAcho
Local nSaveSX8  := GetSx8Len()
Private nMsg    :=0
PRIVATE oGetd
PRIVATE aTela[0][0]
PRIVATE aGets[0]

lDeleta	:= .F.
nOpc010 := nOpc
aHeader := {}
aCols   := {}
aObjects := {}
aAdd(aFolders,STR0007)//"Detalhe da Configuração do Imposto"
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100,  60, .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
aObj  := MsObjSize( aInfo, aObjects, .T. )
dbSelectArea("FRM")
dbSetOrder(2)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FillGetDados(nOpc,"FRM",2,,,,aNoFields,,,,,.T.,,,,,)
aCols[1][aScan(aHeader,{|x| Trim(x[2])=="FRM_SEQ"})] := StrZero(1,Len(FRM->FRM_SEQ))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("FRM")
dbSetOrder(2)
For nX := 1 to FCount()
	M->&(Field(nX)):= FieldGet(nX)
	lInit := .F.
	If ExistIni(EVAL(bCampo,nX))
		lInit := .T.
		M->&(EVAL(bCampo,nX)):= InitPad(SX3->X3_RELACAO)
		If ValType(M->&(EVAL(bCampo,nX))) = "C"
			M->&(EVAL(bCampo,nX)):= PADR(M->&(EVAL(bCampo,nX)),SX3->X3_TAMANHO)
		Endif
		If M->&(EVAL(bCampo,nX)) == NIL
			lInit := .F.
		EndIf
	EndIf
	If !lInit
		IF ValType(M->&(EVAL(bCampo,nX))) == "C"
			M->&(EVAL(bCampo,nX)) := SPACE(LEN(M->&(EVAL(bCampo,nX))))
		ElseIf ValType(M->&(EVAL(bCampo,nX))) == "N"
			M->&(EVAL(bCampo,nX)) := 0
		ElseIf ValType(M->&(EVAL(bCampo,nX))) == "D"
			If ! "_DATA" $ Trim(EVAL(bCampo,nX))
				M->&(EVAL(bCampo,nX)) := dDataBase
			Else
				M->&(EVAL(bCampo,nX)) := cTod("  /  /  ")
			Endif
		ElseIf ValType(M->&(EVAL(bCampo,nX))) == "L"
			M->&(EVAL(bCampo,nX)) := .F.
		EndIf
	EndIf
Next nX
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

EnChoice( "FRM", nReg, nOpc, , , ,aAcho , aObj[1],aCpos , 3 )
oFolder := TFolder():New(aObj[2,1]-45,aObj[2,2],aFolders,{},oDlg,,,,.t.,.f.,aObj[2,4],aObj[2,3],)
cOk	:=	"{||nOpcA:=1"
FINA021Cab(nOpc)
oGetd:=MsGetDados():New(0,0,aObj[2,3]-aObj[2,1],aObj[2,4],nOpc,"FINA021LOk","FINA021TOk","+FRM_SEQ",.T.,aAlter,,,,"FINA021FOk",,,,oFolder:aDialogs[1])
oGetd:oBrowse:bGotFocus:={|| FINA021Cab(nOpc)}
cOk	+=	",if(FINA021TOk(,nOpc),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)}"
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,if(FINA021TOk(,nOpc),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons)
If nOpcA == 1
	Begin Transaction
		lGravaOk := FINA021Gra()
		If lGravaOk
			While( GetSx8Len() > nSaveSx8 )
				ConfirmSX8()
			EndDo
			EvalTrigger()
		EndIf
	End Transaction
Endif
Eval( bFiltraBrw )
SED->(DbGoto(nReg))
Return nOpca

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FA021ALT³ Autor ³ WAGNER MONTENEGRO     ³ Data ³ 05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ALTERAÇÃO DE CONFIGURAÇÃO DE IMPOSTOS                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FA021ALT(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ REPUBLICA DOMINICANA                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION FA021Alt(cAlias,nReg,nOpc)
Local cTudoOK := Nil
Local cTransact := Nil
Local lRet := .F.
Local lRetDel	:=.T.
Local nStart	:=	0
Local aSize     := MsAdvSize()
Local aInfo     := {}
Local aObjects  := {}
Local aObj      := {}
Local aNoFields := {"FRM_FILIAL","FRM_COD","FRM_DSCIMP","FRM_CARTEI","FRM_SIGLA","FRM_TPABT","FRM_TPTIT","FRM_MSBLQL"}
Local aAcho		:= {"FRM_COD","FRM_DSCIMP","FRM_SIGLA","FRM_CARTEI","FRM_TPABT","FRM_TPTIT","FRM_MSBLQL","FRM_RGPARC"}
Local aAlter    := FA021Cpos(aAcho) //Para popular o array da MsGetdados, deve ser passado o array da Enchoice
Local aCpos		 := {"FRM_DSCIMP","FRM_CARTEI","FRM_TPABT","FRM_TPTIT","FRM_MSBLQL"}
Local bCampo    := {|nCPO| Field(nCPO)}
Local bCondicao := {|| .T.}
Local cSeek     := ""
Local cWhile    := ""
Local cCampo    := ""
Local lGravaOk  := .T.
Local nX        := 0
Local nOpca
Local nRecFRM   := FRM->(Recno())
Local oDlg
Local aFolders	:=	{}
Local cOk       := ""
Local aButtons	  := {}
Local nPosX		:=	0
Local lDesBloq := .T.
Private cChaveFRM	:=xFilial("FRM")+FRM->FRM_COD+FRM->FRM_CARTEI
PRIVATE oGetd
PRIVATE aTELA[0][0],aGETS[0]
Private nMsg:=0
nOpc010 := nOpc
FRM->(DBCLEARFILTER())
DbSelectArea("FRM")
DbSetOrder(1)
FRM->(DbGoto(nRecFRM))
cFRMABT := FRM->FRM_TPABT
cFRMTIT := FRM->FRM_TPTIT
If SoftLock("FRM") .And. FRM->(LastRec()) <> 0 .And. FRM->FRM_FILIAL == xFilial("FRM")
	aHeader := {}
	aCols	:= {}
	aAdd(aFolders,STR0007)//"Detalhe da Configuração do Imposto"
	cSeek    := cChaveFRM
	cWhile   := "FRM->FRM_FILIAL+FRM->FRM_COD+FRM->FRM_CARTEI"
	bCondicao:= {|| If( FRM->FRM_SEQ<>"000" .and. SoftLock("FRM") , .T. , .F. ) }
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FillGetDados(nOpc,"FRM",1,cSeek,{|| &cWhile },bCondicao,aNoFields,,,,,,,,,,,)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a integridade dos campos de Bancos de Dados    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("FRM")
	For nX := 1 to FCount()
		nPosX := aScan(aAutoCab,{|aX|AllTrim(Eval(bCampo,nX))$aX[1]})
		If nPosX<>0
			M->&(Eval(bCampo,nX)) := aAutoCab[nPosX,2]
		Else
			M->&(Eval(bCampo,nX)) := FieldGet(nX)
		EndIf
	Next nX


	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100,  60, .T., .T. } )
	aInfo := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
	aObj  := MsObjSize( aInfo, aObjects, .T. )

   If nOpc<>4
		If lDeleta
			If FRM->FRM_MSBLQL=="1"
				Help(" ",1,"HELP",STR0008,STR0009,1,0)
				lRetDel:=.F.
			Else
				For nX := 1 to Len(aCols)
					FRM->(DbGoTo(aCols[nx][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_REC_WT"})]))
					If !Fa021ChkDel(FRM->FRM_COD,aCols[nx][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_SEQ"})],1,.T.)
						Help(" ",1,"HELP",STR0010,STR0011,1,0)
					   lRetDel:=.F.
					   Exit
					Endif
				Next
			Endif
		Endif
		If lRetDel
			aNoFields := {"FRM_FILIAL","FRM_COD","FRM_DSCIMP","FRM_CARTEI","FRM_SIGLA","FRM_TPABT","FRM_TPTIT","FRM_MSBLQL","FRM_DESCR","FRM_TPESSO","FRM_ALIQ","FRM_LMTIND","FRM_LMTACM","FRM_TPACM","FRM_FATGER","FRM_NIVEL","FRM_INIVIG","FRM_FIMVIG","FRM_BLOQ","FRM_APLICA","FRM_REGIAO"}
			aAlter    := {}
			aAcho	  := {"FRM_COD","FRM_DSCIMP","FRM_SIGLA","FRM_CARTEI","FRM_TPABT","FRM_TPTIT","FRM_MSBLQL","FRM_RGPARC"}
			aCpos	  := {}

		  	DEFINE MSDIALOG oDlg TITLE STR0012 From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

			EnChoice( "FRM",nReg, 5, , , ,aAcho , aObj[1],aCpos , 3 )
			oFolder := TFolder():New(aObj[2,1]-45,aObj[2,2],aFolders,{},oDlg,,,,.t.,.f.,aObj[2,4],aObj[2,3],)

			cOk	:=	"{||nOpcA:=1"
			FINA021Cab(2)

			oGetd:=MsGetDados():New(0,0,aObj[2,3]-aObj[2,1],aObj[2,4],5,,,"",,,,,,,,,,oFolder:aDialogs[1])
			oGetd:oBrowse:bGotFocus:={|| FINA021Cab(2)}
			cOk	+=	",if(oGetd:TudoOk(),oDlg:End(),nOpcA := 0)}"
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,&(cOk),{||oDlg:End()},,aButtons)
		Else
			If !lDeleta
				aNoFields := {"FRM_FILIAL","FRM_COD","FRM_DSCIMP","FRM_CARTEI","FRM_SIGLA","FRM_TPABT","FRM_TPTIT","FRM_MSBLQL","FRM_DESCR","FRM_TPESSO","FRM_ALIQ","FRM_LMTIND","FRM_LMTACM","FRM_TPACM","FRM_FATGER","FRM_NIVEL","FRM_INIVIG","FRM_FIMVIG","FRM_BLOQ","FRM_APLICA","FRM_REGIAO"}
				aAlter    := {}
		     	aAcho	  := {"FRM_COD","FRM_DSCIMP","FRM_SIGLA","FRM_CARTEI","FRM_TPABT","FRM_TPTIT","FRM_MSBLQL"}
				aCpos	  := {}
				nOpc:=2
			  	DEFINE MSDIALOG oDlg TITLE STR0012 From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

				EnChoice( "FRM",nReg, 2, , , ,aAcho , aObj[1],aCpos , 3 )
				oFolder := TFolder():New(aObj[2,1]-45,aObj[2,2],aFolders,{},oDlg,,,,.t.,.f.,aObj[2,4],aObj[2,3],)

				cOk	:=	"{||nOpcA:=1"
				FINA021Cab(2)

				oGetd:=MsGetDados():New(0,0,aObj[2,3]-aObj[2,1],aObj[2,4],2,,,"",,,,,,,,,,oFolder:aDialogs[1])
				oGetd:oBrowse:bGotFocus:={|| FINA021Cab(2)}
				cOk	+=	",if(oGetd:TudoOk(),oDlg:End(),nOpcA := 0)}"
				ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,&(cOk),{||oDlg:End()},,aButtons)
		 	EndIf
		Endif
	Else
		If FRM->FRM_MSBLQL=="1"
			For nX := 1 to Len(aCols)
				FRM->(DbGoTo(aCols[nx][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_REC_WT"})]))
				If !Fa021ChkDel(FRM->FRM_COD,aCols[nx][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_SEQ"})],1,.T.)
				   lDesBloq:=.F.
				   Exit
				Endif
			Next
         If !lDesbloq
				aNoFields := {"FRM_FILIAL","FRM_COD","FRM_DSCIMP","FRM_CARTEI","FRM_SIGLA","FRM_TPABT","FRM_TPTIT","FRM_MSBLQL","FRM_DESCR","FRM_TPESSO","FRM_ALIQ","FRM_LMTIND","FRM_LMTACM","FRM_TPACM","FRM_FATGER","FRM_NIVEL","FRM_INIVIG","FRM_FIMVIG","FRM_BLOQ","FRM_APLICA","FRM_REGIAO"}
				aAlter    := {}
				aAcho		 := {"FRM_COD","FRM_DSCIMP","FRM_SIGLA","FRM_CARTEI","FRM_TPABT","FRM_TPTIT","FRM_MSBLQL"}
				aCpos		 := {}

				Help(" ",1,"HELP",STR0008,STR0013,1,0)
				nOpc:=2
			  	DEFINE MSDIALOG oDlg TITLE STR0012 From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

				EnChoice( "FRM",nReg, 2, , , ,aAcho , aObj[1],aCpos , 3 )
				oFolder := TFolder():New(aObj[2,1]-45,aObj[2,2],aFolders,{},oDlg,,,,.t.,.f.,aObj[2,4],aObj[2,3],)

				cOk	:=	"{||nOpcA:=1"
				FINA021Cab(2)

				oGetd:=MsGetDados():New(0,0,aObj[2,3]-aObj[2,1],aObj[2,4],2,,,"",,,,,,,,,,oFolder:aDialogs[1])
				oGetd:oBrowse:bGotFocus:={|| FINA021Cab(2)}
				cOk	+=	",if(oGetd:TudoOk(),oDlg:End(),nOpcA := 0)}"
				ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,&(cOk),{||oDlg:End()},,aButtons)
			Else
			  	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

				EnChoice( "FRM",nReg, nOpc, , , ,aAcho , aObj[1],aCpos , 3 )
				oFolder := TFolder():New(aObj[2,1]-45,aObj[2,2],aFolders,{},oDlg,,,,.t.,.f.,aObj[2,4],aObj[2,3],)

				cOk	:=	"{||nOpcA:=1"
				FINA021Cab(nOpc)

				oGetd:=MsGetDados():New(0,0,aObj[2,3]-aObj[2,1],aObj[2,4],nOpc,"FINA021LOk","FINA021TOk","+FRM_SEQ",.T.,aAlter,,,,"FINA021FOk",,,"Fa021ChkDel",oFolder:aDialogs[1])
				oGetd:oBrowse:bGotFocus:={|| FINA021Cab(nOpc)}
				cOk	+=	",if(FINA021TOk(,nOpc),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)}"
				ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,if(FINA021TOk(,nOpc),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons)
			Endif
		Else
		  	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

			EnChoice( "FRM",nReg, nOpc, , , ,aAcho , aObj[1],aCpos , 3 )
			oFolder := TFolder():New(aObj[2,1]-45,aObj[2,2],aFolders,{},oDlg,,,,.t.,.f.,aObj[2,4],aObj[2,3],)

			cOk	:=	"{||nOpcA:=1"
			FINA021Cab(nOpc)

			oGetd:=MsGetDados():New(0,0,aObj[2,3]-aObj[2,1],aObj[2,4],nOpc,"FINA021LOk","FINA021TOk","+FRM_SEQ",.T.,aAlter,,,,"FINA021FOk",,,"Fa021ChkDel",oFolder:aDialogs[1])
			oGetd:oBrowse:bGotFocus:={|| FINA021Cab(nOpc)}
			cOk	+=	",if(FINA021TOk(,nOpc),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)}"
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,if(FINA021TOk(,nOpc),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons)
		Endif
   Endif
	If nOpcA == 1  .and. nOpc <> 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o registro em questao esta sendo usado    ³
		//³por outra estacao                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction
			lGravaOk := FINA021Gra(nRecFRM,nOpc)
			IF lGravaOk
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  Processa Gatilhos                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				EvalTrigger()
			EndIf
		End Transaction
	EndIf
Else
	IF SED->ED_FILIAL <> xFilial("FRM")
		Help(" ",1,"A000FI")
	Endif
Endif
Eval( bFiltraBrw )
FRM->(DbGoto(nReg))
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FA021Exc  ³ Autor ³ WAGNER MONTENEGRO     ³ Data ³ 05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ EXCLUSÃO  DE CONFIGURAÇÃO DE IMPOSTOS                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FA021Exc  (ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ REPUBLICA DOMINICANA                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION FA021Exc(cAlias,nReg,nOpc)
lDeleta := .T.
FA021Alt( cAlias,nReg,nOpc )
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FA021CHKDEL³ Autor ³ WAGNER MONTENEGRO   ³ Data ³ 05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ EXCLUSÃO  DE CONFIGURAÇÃO DE IMPOSTOS                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FA021CHKDEL(ExpC1,ExpC2,ExpN1)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Imposto                                            ³±±
±±³          ³ ExpC2 = Sequencia do Imposto                               ³±±
±±³          ³ ExpN1 = Modo de tratamento da função                       ³±±
±±³          ³     0 = MsGetDados                                         ³±±
±±³          ³   <>0 = Exclusão do Imposto/Sequencias na MBrowse          ³±±
±±³          ³     3 = Tratamento WHEN dos campos FRM_TPABT e FRM_TPTIT   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ REPUBLICA DOMINICANA                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Fa021ChkDel(cImp,cSeq,nModo,lGrav)
Local aAreaFRM	:=	GetArea()
Local cQuery     := ""
Local lRet	:=.T.
Local lImpInc := .F.
Local nPosIVig
Local nPosFVig
Local nPosAliq
Local nPosTPes
Local nPosFGer
Local nPosApli
Local nPosBloq
Local nPosDesc
Local nPosTPAC
Local nPosLMTI
Local nPosLMTA
Local nPosNIVE
Local nPosREGI
Local nPosRecn
Local nX
Default lGrav :=.F.
Default cImp := FRM->FRM_COD
Default nModo:= 0
Default cSeq := If(nModo <> 3 ,aCols[n][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_SEQ"})],"")
If !lGrav
	oGetd:oBrowse:lDisablePaint := .T.
Endif
nMsg++
SX3->(dbSetOrder(2))
If SX3->(DbSeek("FRN_INCIMP")) .AND. X3Uso(SX3->X3_USADO)
	lImpInc:=.T.
Endif
If nModo <> 0
	If !Inclui //Chamado na validação do campo FRM_CARTEI,FRM_TPABT e FRM_TPTIT apenas em alteração
		cQuery := "SELECT COUNT (FRN_CODNAT) NATUREZA"
		cQuery += "	FROM " + RetSqlName("FRN")
		If nModo==3 .and. lImpInc
			cQuery += "	WHERE FRN_IMPOST = '"+cImp+"'"
			cQuery += "	AND D_E_L_E_T_ <> '*'  OR FRN_INCIMP = '"+cImp+"'"
		Else
			If lImpInc
				cQuery += "	WHERE FRN_IMPOST = '"+cImp+"' AND FRN_SEQ = '"+cSeq+"'"
				cQuery += "	AND D_E_L_E_T_ <> '*'  OR FRN_INCIMP = '"+cImp+"' AND FRN_INCSEQ = '"+cSeq+"'"
			Else
				If nModo==3
					cQuery += "	WHERE FRN_IMPOST = '"+cImp+"'"
				Else
					cQuery += "	WHERE FRN_IMPOST = '"+cImp+"' AND FRN_SEQ = '"+cSeq+"'"
				Endif
			Endif
		Endif
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYFRN",.T.,.F.)
		If QRYFRN->NATUREZA > 0
		   lRet := .F.
		Endif
		QRYFRN->(dbCloseArea())
	Endif
Else
	nPosIVig := Ascan(aHeader,{|x| Trim(x[2])=="FRM_INIVIG"})
	nPosFVig	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_FIMVIG"})
	nPosAliq	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_ALIQ"})
	nPosTPes	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_TPESSO"})
	nPosFGer	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_FATGER"})
	nPosApli	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_APLICA"})
	nPosBloq	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_BLOQ"})
	nPosDesc	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_DESCR"})
	nPosTPAC := Ascan(aHeader,{|x| Trim(x[2])=="FRM_TPACM"})
	nPosLMTI	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_LMTIND"})
	nPosLMTA	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_LMTACM"})
	nPosNIVE := Ascan(aHeader,{|x| Trim(x[2])=="FRM_NIVEL"})
	nPosREGI	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_REGIAO"})
	nPosRecn := Ascan(aHeader,{|x| Trim(x[2])=="FRM_REC_WT"})
	If aCols[n][nPosRecn]<>0
		FRM->(DbGoTo(aCols[n][nPosRecn]))
		If FRM->FRM_BLOQ=="1"
		   lRet:=.F.
			Help(" ",1,"HELP",STR0014,STR0015,1,0)
		Else
			cQuery := "SELECT COUNT (FRN_CODNAT) NATUREZA"
			cQuery += "	FROM " + RetSqlName("FRN")
			cQuery += "	WHERE FRN_IMPOST = '"+cImp+"' AND FRN_SEQ = '"+cSeq+"'"
			If lImpInc
				cQuery += "	AND D_E_L_E_T_ <> '*'  OR FRN_INCIMP = '"+cImp+"' AND FRN_INCSEQ = '"+cSeq+"'"
			Endif
  			cQuery += " AND D_E_L_E_T_ <> '*' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYFRN",.T.,.F.)
			If QRYFRN->NATUREZA > 0
			   If Altera
					If nMsg==1
						Help(" ",1,"HELP",STR0010,STR0017,1,0)
					Else
						nMsg := 0
					Endif
			   Endif
			   lRet := .F.
			Endif
			QRYFRN->(dbCloseArea())
		Endif
	Endif
	If lRet .and. aCols[n][Len(aCols[n])]
		For nX := 1 To Len(aCols)
			If !aCols[nX][Len(aCols[n])]
				If aCols[nX][nPosDesc]==aCols[n][nPosDesc] .and.;
					aCols[nX][nPosTPes]==aCols[n][nPosTPES] .and. ;
					aCols[nX][nPosAliq]==aCols[n][nPosALIQ] .and. ;
					aCols[nX][nPosTPAC]==aCols[n][nPosTPAC] .and. ;
					aCols[nX][nPosLMTI]==aCols[n][nPosLMTI] .and. ;
					aCols[nX][nPosLMTA]==aCols[n][nPosLMTA] .and. ;
					aCols[nX][nPosFGER]==aCols[n][nPosFGER] .and. ;
					aCols[nX][nPosNIVE]==aCols[n][nPosNIVE] .and. ;
					aCols[nX][nPosREGI]==aCols[n][nPosREGI] .and. ;
					aCols[nX][nPosIVIG]==aCols[n][nPosIVIG] .and. ;
					aCols[nX][nPosFVIG]==aCols[n][nPosFVIG] .and. ;
					aCols[nX][nPosAPLI]==aCols[n][nPosAPLI] .and. ;
					aCols[nX][nPosBLOQ]<>"1" .and. nX <> n
				    	lRet := .F.
				Endif
			Endif
		Next nX
		If !lRet
			Help(" ",1,"HELP",STR0018,STR0019,1,0)
		Endif
	Endif
Endif
RestArea(aAreaFRM)
If !lGrav
	oGetd:oBrowse:lDisablePaint := .F.
Endif
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FINA010FOk ³ Autor ³ WAGNER MONTENEGRO  ³ Data ³ 05-04-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação de Campos na MSGETDDOS                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FINA021FOk()
Local lRet    := .T.
Local nPosIVig := Ascan(aHeader,{|x| Trim(x[2])=="FRM_INIVIG"})
Local nPosFVig	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_FIMVIG"})
Local nPosAliq	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_ALIQ"})
Local nPosTPes	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_TPESSO"})
Local nPosFGer	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_FATGER"})
Local nPosApli	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_APLICA"})
Local nPosBloq	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_BLOQ"})
Local nPosDesc	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_DESCR"})
Local nPosTPAC := Ascan(aHeader,{|x| Trim(x[2])=="FRM_TPACM"})
Local nPosLMTI	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_LMTIND"})
Local nPosLMTA	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_LMTACM"})
Local nPosNIVE := Ascan(aHeader,{|x| Trim(x[2])=="FRM_NIVEL"})
Local nPosREGI	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_REGIAO"})
Local nPosRecn:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_REC_WT"})
Local nPosVcDuti := Ascan(aHeader,{|x| Trim(x[2])=="FRM_VCDUTI"})  //Utilizado apenas para Costa Rica
Local nPosRgParc := Ascan(aHeader,{|x| Trim(x[2])=="FRM_RGPARC"})  //Utilizado apenas para Costa Rica
Local nPosBsCalc := Ascan(aHeader,{|x| Trim(x[2])=="FRM_BSCALC"})  //Utilizado apenas para Costa Rica
Local cCampo:= ReadVar()
Local nCkVig:=1
Local nX
oGetd:oBrowse:lDisablePaint := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se o ultimo elemento do array e' Logico     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[n][Len(aCols[n])]
	Return .F.
EndIf
If nOpc010==4
	if AllTrim(cCampo) == "M->FRM_BLOQ"
	   If aCols[n][nPosBloq]<>"1" .and. M->FRM_BLOQ=="1"
	   		If !ApMsgYesNo(STR0020+CRLF+STR0021)
	   			M->FRM_BLOQ:="2"
		   		aCols[n][nPosBloq]:="2"
		   	Endif
	   Endif
	Elseif AllTrim(cCampo) <> "M->FRM_DESCR"
	  	lRet := Fa021ChkDel(FRM->FRM_COD,aCols[n][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_SEQ"})],1)
	  	oGetd:oBrowse:lDisablePaint := .T.
	  	If !lRet
	  		Help(" ",1,"HELP",STR0010,STR0022,1,0)
	  	Endif
	  	If lRet
	  		If aCols[n][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_REC_WT"})] <>0
	  			FRM->(DbGoTo(aCols[n][nPosRecn]))
	  			If FRM->FRM_BLOQ=="1"
			  		lRet:=.F.
	  				Help(" ",1,"HELP",STR0014,STR0023,1,0)
	  			Endif
	  		Endif
	  	Endif
	Endif
	If lRet
		If AllTrim(cCampo) == "M->FRM_DESCR"
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If aCols[nX][nPosDesc]==M->FRM_DESCR .and.;
						aCols[nX][nPosTPes]==aCols[n][nPosTPES] .and. ;
						aCols[nX][nPosAliq]==aCols[n][nPosALIQ] .and. ;
						aCols[nX][nPosTPAC]==aCols[n][nPosTPAC] .and. ;
						aCols[nX][nPosLMTI]==aCols[n][nPosLMTI] .and. ;
						aCols[nX][nPosLMTA]==aCols[n][nPosLMTA] .and. ;
						aCols[nX][nPosFGER]==aCols[n][nPosFGER] .and. ;
						aCols[nX][nPosNIVE]==aCols[n][nPosNIVE] .and. ;
						aCols[nX][nPosREGI]==aCols[n][nPosREGI] .and. ;
						aCols[nX][nPosIVIG]==aCols[n][nPosIVIG] .and. ;
						aCols[nX][nPosFVIG]==aCols[n][nPosFVIG] .and. ;
						aCols[nX][nPosAPLI]==aCols[n][nPosAPLI] .and. ;
						aCols[nX][nPosBLOQ]<>"1" .and. nX <> n

				    	lRet := .F.
				  	Endif
				Endif
			Next nX
		Endif
		If AllTrim(cCampo) == "M->FRM_TPESSO"
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If aCols[nX][nPosDesc]==aCols[n][nPosDESC] .AND. ;
						aCols[nX][nPosTPes]==M->FRM_TPESSO .and. ;
						aCols[nX][nPosAliq]==aCols[n][nPosALIQ] .and. ;
						aCols[nX][nPosTPAC]==aCols[n][nPosTPAC] .and. ;
						aCols[nX][nPosLMTI]==aCols[n][nPosLMTI] .and. ;
						aCols[nX][nPosLMTA]==aCols[n][nPosLMTA] .and. ;
						aCols[nX][nPosFGER]==aCols[n][nPosFGER] .and. ;
						aCols[nX][nPosNIVE]==aCols[n][nPosNIVE] .and. ;
						aCols[nX][nPosREGI]==aCols[n][nPosREGI] .and. ;
						aCols[nX][nPosIVIG]==aCols[n][nPosIVIG] .and. ;
						aCols[nX][nPosFVIG]==aCols[n][nPosFVIG] .and. ;
						aCols[nX][nPosAPLI]==aCols[n][nPosAPLI] .and. ;
						aCols[nX][nPosBLOQ]<>"1" .and. nX <> n

				    	lRet := .F.
				  	Endif
				Endif
			Next nX
		Endif
		If AllTrim(cCampo) == "M->FRM_ALIQ"
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If aCols[nX][nPosDesc]==aCols[n][nPosDESC] .AND. ;
						aCols[nX][nPosTPes]==aCols[n][nPosTPES] .and. ;
						aCols[nX][nPosAliq]==M->FRM_ALIQ .and. ;
						aCols[nX][nPosTPAC]==aCols[n][nPosTPAC] .and. ;
						aCols[nX][nPosLMTI]==aCols[n][nPosLMTI] .and. ;
						aCols[nX][nPosLMTA]==aCols[n][nPosLMTA] .and. ;
						aCols[nX][nPosFGER]==aCols[n][nPosFGER] .and. ;
						aCols[nX][nPosNIVE]==aCols[n][nPosNIVE] .and. ;
						aCols[nX][nPosREGI]==aCols[n][nPosREGI] .and. ;
						aCols[nX][nPosIVIG]==aCols[n][nPosIVIG] .and. ;
						aCols[nX][nPosFVIG]==aCols[n][nPosFVIG] .and. ;
						aCols[nX][nPosAPLI]==aCols[n][nPosAPLI] .and. ;
						aCols[nX][nPosBLOQ]<>"1" .and. nX <> n

				    	lRet := .F.
				  	Endif
				Endif
			Next nX
		Endif
		If AllTrim(cCampo) == "M->FRM_TPACM"
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If aCols[nX][nPosDesc]==aCols[n][nPosDESC] .AND. ;
						aCols[nX][nPosTPes]==aCols[n][nPosTPES] .and. ;
						aCols[nX][nPosAliq]==aCols[n][nPosALIQ] .and. ;
						aCols[nX][nPosTPAC]==M->FRM_TPACM .and. ;
						aCols[nX][nPosLMTI]==aCols[n][nPosLMTI] .and. ;
						aCols[nX][nPosLMTA]==aCols[n][nPosLMTA] .and. ;
						aCols[nX][nPosFGER]==aCols[n][nPosFGER] .and. ;
						aCols[nX][nPosNIVE]==aCols[n][nPosNIVE] .and. ;
						aCols[nX][nPosREGI]==aCols[n][nPosREGI] .and. ;
						aCols[nX][nPosIVIG]==aCols[n][nPosIVIG] .and. ;
						aCols[nX][nPosFVIG]==aCols[n][nPosFVIG] .and. ;
						aCols[nX][nPosAPLI]==aCols[n][nPosAPLI] .and. ;
						aCols[nX][nPosBLOQ]<>"1" .and. nX <> n

				    	lRet := .F.
				  	Endif
				Endif
			Next nX
		Endif
		If AllTrim(cCampo) == "M->FRM_LMTIND"
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If aCols[nX][nPosDesc]==aCols[n][nPosDESC] .AND. ;
						aCols[nX][nPosTPes]==aCols[n][nPosTPES] .and. ;
						aCols[nX][nPosAliq]==aCols[n][nPosALIQ] .and. ;
						aCols[nX][nPosTPAC]==aCols[n][nPosTPAC] .and. ;
						aCols[nX][nPosLMTI]==M->FRM_LMTIND .and. ;
						aCols[nX][nPosLMTA]==aCols[n][nPosLMTA] .and. ;
						aCols[nX][nPosFGER]==aCols[n][nPosFGER] .and. ;
						aCols[nX][nPosNIVE]==aCols[n][nPosNIVE] .and. ;
						aCols[nX][nPosREGI]==aCols[n][nPosREGI] .and. ;
						aCols[nX][nPosIVIG]==aCols[n][nPosIVIG] .and. ;
						aCols[nX][nPosFVIG]==aCols[n][nPosFVIG] .and. ;
						aCols[nX][nPosAPLI]==aCols[n][nPosAPLI] .and. ;
						aCols[nX][nPosBLOQ]<>"1" .and. nX <> n

				    	lRet := .F.
				  	Endif
				Endif
			Next nX
		Endif
		If AllTrim(cCampo) == "M->FRM_LMTACM"
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If aCols[nX][nPosDesc]==aCols[n][nPosDESC] .AND. ;
						aCols[nX][nPosTPes]==aCols[n][nPosTPES] .and. ;
						aCols[nX][nPosAliq]==aCols[n][nPosALIQ] .and. ;
						aCols[nX][nPosTPAC]==aCols[n][nPosTPAC] .and. ;
						aCols[nX][nPosLMTI]==aCols[n][nPosLMTI] .and. ;
						aCols[nX][nPosLMTA]==M->FRM_LMTACM .and. ;
						aCols[nX][nPosFGER]==aCols[n][nPosFGER] .and. ;
						aCols[nX][nPosNIVE]==aCols[n][nPosNIVE] .and. ;
						aCols[nX][nPosREGI]==aCols[n][nPosREGI] .and. ;
						aCols[nX][nPosIVIG]==aCols[n][nPosIVIG] .and. ;
						aCols[nX][nPosFVIG]==aCols[n][nPosFVIG] .and. ;
						aCols[nX][nPosAPLI]==aCols[n][nPosAPLI] .and. ;
						aCols[nX][nPosBLOQ]<>"1" .and. nX <> n

				    	lRet := .F.
				  	Endif
				Endif
			Next nX
		Endif
		If AllTrim(cCampo) == "M->FRM_FATGER"
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If aCols[nX][nPosDesc]==aCols[n][nPosDESC] .AND. ;
						aCols[nX][nPosTPes]==aCols[n][nPosTPES] .and. ;
						aCols[nX][nPosAliq]==aCols[n][nPosALIQ] .and. ;
						aCols[nX][nPosTPAC]==aCols[n][nPosTPAC] .and. ;
						aCols[nX][nPosLMTI]==aCols[n][nPosLMTI] .and. ;
						aCols[nX][nPosLMTA]==aCols[n][nPosLMTA] .and. ;
						aCols[nX][nPosFGER]==M->FRM_FATGER .and. ;
						aCols[nX][nPosNIVE]==aCols[n][nPosNIVE] .and. ;
						aCols[nX][nPosREGI]==aCols[n][nPosREGI] .and. ;
						aCols[nX][nPosIVIG]==aCols[n][nPosIVIG] .and. ;
						aCols[nX][nPosFVIG]==aCols[n][nPosFVIG] .and. ;
						aCols[nX][nPosAPLI]==aCols[n][nPosAPLI] .and. ;
						aCols[nX][nPosBLOQ]<>"1" .and. nX <> n

				    	lRet := .F.
				  	Endif
				Endif
			Next nX
		Endif
		If AllTrim(cCampo) == "M->FRM_NIVEL"
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If aCols[nX][nPosDesc]==aCols[n][nPosDESC] .AND. ;
						aCols[nX][nPosTPes]==aCols[n][nPosTPES] .and. ;
						aCols[nX][nPosAliq]==aCols[n][nPosALIQ] .and. ;
						aCols[nX][nPosTPAC]==aCols[n][nPosTPAC] .and. ;
						aCols[nX][nPosLMTI]==aCols[n][nPosLMTI] .and. ;
						aCols[nX][nPosLMTA]==aCols[n][nPosLMTA] .and. ;
						aCols[nX][nPosFGER]==aCols[n][nPosFGER] .and. ;
						aCols[nX][nPosNIVE]==M->FRM_NIVEL .and. ;
						aCols[nX][nPosREGI]==aCols[n][nPosREGI] .and. ;
						aCols[nX][nPosIVIG]==aCols[n][nPosIVIG] .and. ;
						aCols[nX][nPosFVIG]==aCols[n][nPosFVIG] .and. ;
						aCols[nX][nPosAPLI]==aCols[n][nPosAPLI] .and. ;
						aCols[nX][nPosBLOQ]<>"1" .and. nX <> n

				    	lRet := .F.
				  	Endif
				Endif
			Next nX
		Endif
		If AllTrim(cCampo) == "M->FRM_REGIAO"
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If aCols[nX][nPosDesc]==aCols[n][nPosDESC] .AND. ;
						aCols[nX][nPosTPes]==aCols[n][nPosTPES] .and. ;
						aCols[nX][nPosAliq]==aCols[n][nPosALIQ] .and. ;
						aCols[nX][nPosTPAC]==aCols[n][nPosTPAC] .and. ;
						aCols[nX][nPosLMTI]==aCols[n][nPosLMTI] .and. ;
						aCols[nX][nPosLMTA]==aCols[n][nPosLMTA] .and. ;
						aCols[nX][nPosFGER]==aCols[n][nPosFGER] .and. ;
						aCols[nX][nPosNIVE]==aCols[n][nPosNIVE] .and. ;
						aCols[nX][nPosREGI]==M->FRM_REGIAO .and. ;
						aCols[nX][nPosIVIG]==aCols[n][nPosIVIG] .and. ;
						aCols[nX][nPosFVIG]==aCols[n][nPosFVIG] .and. ;
						aCols[nX][nPosAPLI]==aCols[n][nPosAPLI] .and. ;
						aCols[nX][nPosBLOQ]<>"1" .and. nX <> n

				    	lRet := .F.
				  	Endif
				Endif
			Next nX
		Endif
		If AllTrim(cCampo) == "M->FRM_INIVIG"
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If aCols[nX][nPosDesc]==aCols[n][nPosDESC] .AND. ;
						aCols[nX][nPosTPes]==aCols[n][nPosTPES] .and. ;
						aCols[nX][nPosAliq]==aCols[n][nPosALIQ] .and. ;
						aCols[nX][nPosTPAC]==aCols[n][nPosTPAC] .and. ;
						aCols[nX][nPosLMTI]==aCols[n][nPosLMTI] .and. ;
						aCols[nX][nPosLMTA]==aCols[n][nPosLMTA] .and. ;
						aCols[nX][nPosFGER]==aCols[n][nPosFGER] .and. ;
						aCols[nX][nPosNIVE]==aCols[n][nPosNIVE] .and. ;
						aCols[nX][nPosREGI]==aCols[n][nPosREGI] .and. ;
						aCols[nX][nPosIVIG]==M->FRM_INIVIG .and. ;
						aCols[nX][nPosFVIG]==aCols[n][nPosFVIG] .and. ;
						aCols[nX][nPosAPLI]==aCols[n][nPosAPLI] .and. ;
						aCols[nX][nPosBLOQ]<>"1" .and. nX <> n

				    	lRet := .F.
				  	Endif
				Endif
			Next nX
		Endif
		If AllTrim(cCampo) == "M->FRM_FIMVIG"
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If aCols[nX][nPosDesc]==aCols[n][nPosDESC] .AND. ;
						aCols[nX][nPosTPes]==aCols[n][nPosTPES] .and. ;
						aCols[nX][nPosAliq]==aCols[n][nPosALIQ] .and. ;
						aCols[nX][nPosTPAC]==aCols[n][nPosTPAC] .and. ;
						aCols[nX][nPosLMTI]==aCols[n][nPosLMTI] .and. ;
						aCols[nX][nPosLMTA]==aCols[n][nPosLMTA] .and. ;
						aCols[nX][nPosFGER]==aCols[n][nPosFGER] .and. ;
						aCols[nX][nPosNIVE]==aCols[n][nPosNIVE] .and. ;
						aCols[nX][nPosREGI]==aCols[n][nPosREGI] .and. ;
						aCols[nX][nPosIVIG]==aCols[n][nPosIVIG] .and. ;
						aCols[nX][nPosFVIG]==M->FRM_FIMVIG .and. ;
						aCols[nX][nPosAPLI]==aCols[n][nPosAPLI] .and. ;
						aCols[nX][nPosBLOQ]<>"1" .and. nX <> n

				    	lRet := .F.
				  	Endif
				Endif
			Next nX
		Endif
		If AllTrim(cCampo) == "M->FRM_APLICA"
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If aCols[nX][nPosDesc]==aCols[n][nPosDESC] .AND. ;
						aCols[nX][nPosTPes]==aCols[n][nPosTPES] .and. ;
						aCols[nX][nPosAliq]==aCols[n][nPosALIQ] .and. ;
						aCols[nX][nPosTPAC]==aCols[n][nPosTPAC] .and. ;
						aCols[nX][nPosLMTI]==aCols[n][nPosLMTI] .and. ;
						aCols[nX][nPosLMTA]==aCols[n][nPosLMTA] .and. ;
						aCols[nX][nPosFGER]==aCols[n][nPosFGER] .and. ;
						aCols[nX][nPosNIVE]==aCols[n][nPosNIVE] .and. ;
						aCols[nX][nPosREGI]==aCols[n][nPosREGI] .and. ;
						aCols[nX][nPosIVIG]==aCols[n][nPosIVIG] .and. ;
						aCols[nX][nPosFVIG]==aCols[n][nPosFVIG] .and. ;
						aCols[nX][nPosAPLI]==M->FRM_APLICA .and.;
						aCols[nX][nPosBLOQ]<>"1" .and. nX <> n

				    	lRet := .F.
				  	Endif
				Endif
			Next nX
		Endif

		If !lRet
			Help(" ",1,"HELP",STR0018,STR0019,1,0)
		Endif
	Endif
Endif
If lRet
	If AllTrim(cCampo) == "M->FRM_INIVIG"
	  	If !Empty(aCols[n][nPosFVig])
   		If M->FRM_INIVIG > aCols[n][nPosFVig]
   			Help(" ",1,"HELP",STR0024,STR0025,1,0)
   			lRet:=.F.
   		Endif
   	Endif
	Elseif AllTrim(cCampo) == "M->FRM_FIMVIG"
		If Empty(aCols[n][nPosIVig])
	   	Help(" ",1,"HELP",STR0024,STR0026,1,0)
  			lRet:=.F.
		Else
	 		If M->FRM_FIMVIG < aCols[n][nPosIVig]
		   	Help(" ",1,"HELP",STR0024,STR0027,1,0)
	  			lRet:=.F.
	  		Endif
	  	Endif
  	Endif
Endif

//acrescentado por Fernando Radu Muscalu em 26/09/2011
//Os impostos não podem ser retidos na emissao de titulos
If lRet .and. (nOpc010 == 3 .or. nOpc010 == 4)

	//Consistências para os campos da Costa Rica - Rodrigo Gimenes
	If cPaisLoc == "COS"
		If Alltrim(cCampo) == "M->FRM_VCTIPO" .And. nPosVcDuti > 0
			If M->FRM_VCTIPO == "1" // "Para o tipo "Fixo"(1) não é necessário informar se usa contagem por dias úteis ou não;
				//Limpa o conteúdo se estiver preenchido
				aCols[n][nPosVcDuti] := ""
				M->FRM_VCDUTI := ""
			EndIf
	    ElseIf Alltrim(cCampo) == "M->FRM_FATGER"
			If M->FRM_FATGER == "1" .Or. Empty(M->FRM_FATGER) //Os campos FRM_RGPARC e FRM_BSCALC só devem ser preenchidos quando o fato gerador é baixa
				//Limpa o conteúdo se estiver preenchido
				aCols[n][nPosRgParc] := ""
				M->FRM_RGPARC := ""
				aCols[n][nPosBsCalc] := ""
				M->FRM_BSCALC := ""
			Endif
		Endif
	End If
	If Alltrim(cCampo) == "M->FRM_FATGER"
		If cPaisLoc == "DOM"
			If M->FRM_FATGER == "1"
				lRet := .f.
				Help(" ",1,"FINA021FOk",,STR0068,1,0)
			Endif
		Endif
	Endif
Endif



oGetd:oBrowse:lDisablePaint := .F.
Return( lRet )


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FINA010LOk ³ Autor ³ WAGNER MONTENEGRO  ³ Data ³ 05-04-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia nas de linhas da Amarrcao FRN X SED           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FINA021LOk(nModo)
Local lRet    	:= .T.
Local nPosIVig 	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_INIVIG"})
Local nPosFVig	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_FIMVIG"})
Local nPosAliq	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_ALIQ"})
Local nPosTPes	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_TPESSO"})
Local nPosFGer	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_FATGER"})
Local nPosApli	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_APLICA"})
Local nPosBloq	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_BLOQ"})
Local nPosDesc	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_DESCR"})
Local nPosTPAC 	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_TPACM"})
Local nPosLMTI	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_LMTIND"})
Local nPosLMTA	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_LMTACM"})
Local nPosNIVE 	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_NIVEL"})
Local nPosREGI	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_REGIAO"})
Local nPosRecn	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_REC_WT"})
Local nPosVcDia	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_VCDIA"})//Apenas para Costa Rica
Local nPosVcTipo:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_VCTIPO"})//Apenas para Costa Rica
Local nPosVcCont:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_VCCONT"})//Apenas para Costa Rica
Local nPosVcFat := Ascan(aHeader,{|x| Trim(x[2])=="FRM_VCFAT"})//Apenas para Costa Rica
Local nPosVdTvld:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_VCTVLD"})//Apenas para Costa Rica
Local nPosVcDuti:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_VCDUTI"})//Apenas para Costa Rica
//Local nPosRgParc := Ascan(aHeader,{|x| Trim(x[2])=="FRM_RGPARC"})  //Apenas para Costa Rica
//Local nPosBsCalc := Ascan(aHeader,{|x| Trim(x[2])=="FRM_BSCALC"})  //Apenas para Costa Rica


Local cCposInfo	:=""
Local cCposComp	:=""
Local cCposCab	:=""
Local nCkVig	:=0
Local nX
Default nModo 	:= 0

oGetd:oBrowse:lDisablePaint := .T.

If aCols[n][Len(aCols[n])] .and. Len(aCols)=1 .and. nModo==1
	Help(" ",1,"HELP",STR0028,STR0029,1,0)
	lRet:=.F.
EndIf
If lRet
	If Empty(M->FRM_COD) .or. Empty(M->FRM_DSCIMP) .or. Empty(M->FRM_SIGLA) .or. Empty(M->FRM_CARTEI) .and. nModo==1 //Chamada pela FINA021TOk
		SX3->(DbSetOrder(2))
		If Empty(M->FRM_COD)
			If SX3->(DbSeek("FRM_COD"))
				cCposCab:=", "+Rtrim(X3Titulo())
			Endif
		Endif
		If Empty(M->FRM_DESCR)
			If SX3->(DbSeek("FRM_DESCR"))
				cCposCab:=", "+Rtrim(X3Titulo())
			Endif
		Endif
		If Empty(M->FRM_DSCIMP)
			If SX3->(DbSeek("FRM_DSCIMP"))
				cCposCab+=", "+Rtrim(X3Titulo())
			Endif
		Endif
		If Empty(M->FRM_SIGLA)
			If SX3->(DbSeek("FRM_SIGLA"))
				cCposCab+=", "+Rtrim(X3Titulo())
			Endif
		Endif
		If Empty(M->FRM_CARTEI)
			If SX3->(DbSeek("FRM_CARTEI"))
				cCposCab+=", "+Rtrim(X3Titulo())
			Endif
		Endif
		If Empty(M->FRM_TPABT) .and. Empty(M->FRM_TPTIT)
			If SX3->(DbSeek("FRM_TPABT"))
				cCposCab+=", "+Rtrim(X3Titulo())
			Endif
			If SX3->(DbSeek("FRM_TPTIT"))
				cCposCab+="/"+Rtrim(X3Titulo())
			Endif
		Endif
		SX3->(DbSetOrder(1))
		lRet:=.F.
	Endif
	If nPosTPes > 0
		If Empty(aCols[n][nPosTPes])
		   lRet:=.F.
		   cCposInfo+=","+aHeader[aScan(aHeader,{|x| Trim(x[2])=="FRM_TPESSO"})][1]
		Endif
	Endif
	If nPosAliq > 0
		If Empty(aCols[n][nPosAliq])
		   lRet:=.F.
		   cCposInfo+=","+aHeader[aScan(aHeader,{|x| Trim(x[2])=="FRM_ALIQ"})][1]
		Endif
	Endif
	If nPosFGer > 0
		If Empty(aCols[n][nPosFGer])
		   lRet:=.F.
		   cCposInfo+=","+aHeader[aScan(aHeader,{|x| Trim(x[2])=="FRM_FATGER"})][1]
		Endif
	Endif
	If nPosIVig > 0 .and. nPosFVig > 0
		If Empty(aCols[n][nPosIVig])
		   lRet:=.F.
		   cCposInfo+=","+aHeader[aScan(aHeader,{|x| Trim(x[2])=="FRM_INIVIG"})][1]
		Endif
		If Empty(aCols[n][nPosFVig])
		   lRet:=.F.
		   cCposInfo+=","+aHeader[aScan(aHeader,{|x| Trim(x[2])=="FRM_FIMVIG"})][1]
		Endif
		If lRet
    		If aCols[n][nPosFVig] < aCols[n][nPosIVig]
		   	cCposComp:=STR0025
	  			lRet:=.F.
	  		Endif
		Endif
	Endif
	If nPosApli > 0
		If Empty(aCols[n][nPosApli])
		   lRet:=.F.
		   cCposInfo+=","+aHeader[aScan(aHeader,{|x| Trim(x[2])=="FRM_APLICA"})][1]
		Endif
	Endif
	//Consistências para os campos da Costa Ricas - Rodrigo Gimenes
	If cPaisLoc == "COS"
		If nPosVcCont > 0  .And. nPosVcFat > 0 .And. !(Empty(aCols[n][nPosVcCont]))
			If aCols[n][nPosVcCont] == "2" .And. aCols[n][nPosVcFat] == 0
				cCposComp:=STR0069 // "Para contagem mensal, o fator de contagem deve ser maior que zero."
				lRet:=.F.
			EndIf
	    EndIf
	    If  nPosVcTipo > 0 .And. nPosVcDuti > 0
	    	If aCols[n][nPosVcTipo] == "1"
				If aCols[n][nPosVcDuti] != "0" .And. !Empty(Trim(aCols[n][nPosVcDuti]))
					cCposComp:=STR0072 // "A opção de dias úteis só deve ser preenchida quando a opção de tipo de dia for 'Dias'."
					lRet:=.F.
				EndIf
			ElseIf aCols[n][nPosVcTipo] == "2"
				If aCols[n][nPosVcDuti] == "0" .Or. Empty(Trim(aCols[n][nPosVcDuti]))
					cCposComp:=STR0075 // "A opção de dias úteis deve ser preenchida quando a opção de tipo de dia for 'Dias'."
					lRet:=.F.
				EndIf
			EndIf
	    EndIf
	End If

	If !lRet
		If !Empty(cCposComp) .and. !Empty(cCposCab) .and. !Empty(cCposInfo)
			Help(" ",1,"HELP",STR0028,STR0031+If(nModo==0,Substr(cCposInfo,2)+cCposCab,Substr(cCposCab,2)+cCposInfo)+"."+CRLF+cCposComp,1,0)
		Elseif !Empty(cCposComp) .and. !Empty(cCposInfo)
			Help(" ",1,"HELP",STR0028,STR0031+Substr(cCposInfo,2)+"."+CRLF+cCposComp,1,0)
		Elseif !Empty(cCposComp) .and. !Empty(cCposCab)
			Help(" ",1,"HELP",STR0028,STR0031+Substr(cCposCab,2 )+"."+CRLF+cCposComp,1,0)
		Elseif !Empty(cCposCab) .and. !Empty(cCposInfo)
			Help(" ",1,"HELP",STR0028,STR0031+If(nModo==0,Substr(cCposInfo,2)+cCposCab,Substr(cCposCab,2)+cCposInfo)+".",1,0)
		Elseif !Empty(cCposCab)
			Help(" ",1,"HELP",STR0028,STR0031+Substr(cCposCab,2)+".",1,0)
		Elseif !Empty(cCposInfo)
			Help(" ",1,"HELP",STR0028,STR0031+Substr(cCposInfo,2)+".",1,0)
		Else
			Help(" ",1,"HELP",STR0024,cCposComp,1,0)
		Endif
	Endif
	If lRet .and. !aCols[n][Len(aCols[n])]
		For nX := 1 To Len(aCols)
			If !aCols[nX][Len(aCols[nX])]
				If aCols[nX][nPosDesc]==aCols[n][nPosDesc] .and.;
					aCols[nX][nPosTPes]==aCols[n][nPosTPES] .and. ;
					aCols[nX][nPosAliq]==aCols[n][nPosALIQ] .and. ;
					aCols[nX][nPosTPAC]==aCols[n][nPosTPAC] .and. ;
					aCols[nX][nPosLMTI]==aCols[n][nPosLMTI] .and. ;
					aCols[nX][nPosLMTA]==aCols[n][nPosLMTA] .and. ;
					aCols[nX][nPosFGER]==aCols[n][nPosFGER] .and. ;
					aCols[nX][nPosNIVE]==aCols[n][nPosNIVE] .and. ;
					aCols[nX][nPosREGI]==aCols[n][nPosREGI] .and. ;
					aCols[nX][nPosIVIG]==aCols[n][nPosIVIG] .and. ;
					aCols[nX][nPosFVIG]==aCols[n][nPosFVIG] .and. ;
					aCols[nX][nPosAPLI]==aCols[n][nPosAPLI] .and. ;
					aCols[nX][nPosBLOQ]<>"1" .and. nX <> n
				    	lRet := .F.
			  	Endif
			Endif
		Next nX
		If !lRet
			Help(" ",1,"HELP",STR0018,STR0019,1,0)
		Endif
	Endif

EndIf
oGetd:oBrowse:lDisablePaint := .F.
Return( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FINA021TOk ³ Autor ³ WAGNER MONTENEGRO  ³ Data ³ 05-04-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia geral dos itens da Amarracao FRN x SED        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function FINA021TOk(o,nOpc)
Local aAreaFRM	:=	GetArea()
Local cQuery   := ""
Local nx
Local ny
local lRet := .T.
Local nMaxArray
Local nPosAplic := Ascan(aHeader,{|x| Trim(x[2])=="FRM_APLICA"})
Local nPosCpo  	:= 0
Local nTemImp 	:= 0 //Quando existir linhas  de imposto, o tipo de título tem que estar preenchido
Local nTemRet 	:= 0 //Quando existir linhas  de retenção, o tipo de abatimento tem que estar preenchido
Local cAplica 	:= ""


oGetd:oBrowse:lDisablePaint := .T.
nMaxArray := Len(aCols)

If nMaxArray == 1
	If	Empty(aCols[nMaxArray][1])
		lRet := .F.
		Help(" ",1,"AA10SEMREG")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se o ultimo elemento do array esta em branco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	For ny := 1 To Len(aCols)
		If aCols[nY][Len(aCols[nY])]
		    lRet := .T.
		Endif
		cAplica := aCols[nY][nPosAplic]
		If cAplica == "1"
			nTemImp ++
		ElseIf cAplica == "2"
			nTemRet ++
		Endif
	Next ny
	If lRet
		lRet:=FINA021LOk(1)
	Endif
	If lRet
		If Empty(M->FRM_TPABT) .and. Empty(M->FRM_TPTIT)
			Help(" ",1,"HELP",STR0032,STR0033,1,0)
			lRet:=.F.
		ElseIf nTemImp > 0 .And. Empty(M->FRM_TPTIT)
			Help(" ",1,"HELP",STR0032,STR0076+CRLF+CRLF+STR0078,1,0) //"Existem itens com aplicação 'Imposto' e o tipo do título não foi preenchido.""Preencha o campo 'Tipo do Título'"
			lRet:=.F.
		ElseIf nTemRet > 0 .And. Empty(M->FRM_TPABT)
			Help(" ",1,"HELP",STR0032,STR0077+CRLF+CRLF+STR0079,1,0)//"Existem itens com aplicação 'Retenção' e o tipo do abatimento não foi preenchido." "Preencha o campo 'Tipo do Abatimento'"
			lRet:=.F.
		EndIf
	Endif
	If lRet
	  lRet:=FINA021V03(1)
	  oGetd:oBrowse:lDisablePaint := .T.
	Endif

  If lRet
		cQuery := "SELECT COUNT (FRM_COD) NATUREZA"
		cQuery += "	FROM " + RetSqlName("FRM")
		cQuery += "	WHERE FRM_COD <> '"+M->FRM_COD+"'  AND FRM_SIGLA = '"+M->FRM_SIGLA+"' AND FRM_CARTEI = '"+M->FRM_CARTEI+"'"
		cQuery += " AND FRM_MSBLQL <> '1' AND D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYFRM",.T.,.F.)
		If QRYFRM->NATUREZA > 0
		   Help(" ",1,"HELP",STR0034,STR0035,1,0)
			lRet := .F.
		Endif
		QRYFRM->(dbCloseArea())
		If lRet
			cQuery := "SELECT COUNT (FRM_COD) NATUREZA"
			cQuery += "	FROM " + RetSqlName("FRM")
			cQuery += "	WHERE FRM_COD <> '"+M->FRM_COD+"' AND FRM_TPABT = '"+M->FRM_TPABT+"' AND FRM_CARTEI = '"+M->FRM_CARTEI+"'"
			cQuery += " AND FRM_MSBLQL <> '1' AND D_E_L_E_T_ <> '*' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYFRM",.T.,.F.)
			If QRYFRM->NATUREZA > 0
			   Help(" ",1,"HELP",STR0032,STR0036,1,0)
				lRet := .F.
			Endif
			QRYFRM->(dbCloseArea())
		Endif
		RestArea(aAreaFRM)
	Endif
EndIf
oGetd:oBrowse:lDisablePaint := .F.
Return( lRet )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA021Cab  ³ Autor ³ WAGNER MONTENEGRO³ Data ³ 18-03-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consiste Dados da cabecalho FRM                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINA021Cab(nOpc)
Return(.T.)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³F021DelCab| Autor ³ WAGNER MONTENEGRO     ³ Data ³18-03-2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Deleta Dados da cabecalho FRM                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F021DelCab(cCodImp)

Local aAreaFRM	:=	FRM->(GetArea())

FRM->(DbSetOrder(2))
If FRM->(DbSeek(xFilial("FRM")+cCodImp+"000",.T.))
	If FRM->FRM_COD == cCodImp .AND. FRM->FRM_SEQ == "000"
		If Fa021ChkDel(cCodImp,FRM->FRM_SEQ,0,.T.)
			RecLock("FRM",.F.)
			FRM->(DbDelete())
			FRM->(MsUnLock())
		EndIf
	EndIf
EndIf
RestArea(aAreaFRM)
Return()


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FINA021Gra ³ Autor ³ WAGNER MONTENEGRO  ³ Data ³ 05-04-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava todas informacoes nos arquivos FRN E SED             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA021                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINA021Gra(nRecFRM)
LOCAL nX, nMaxArray, bCampo,aAnterior:={}, nCntDel:=0
LOCAL nRegx := 0, cVar
LOCAL ny := 0
LOCAL i  := 0
Local lImpInc :=.F.
Local cFRM_COD
Local cFRM_Dscr
Local cFRM_Cart
Local cFRM_Sigla
Local cFRM_TPABT
Local cFRM_TPTIT
Local cFRM_MSBLQL
Local cFRM_RGPARC
Local lAltOk:=.T.
Local cCodNatur:=""
DEFAULT nRecFRM := 0

SX3->(dbSetOrder(2))
If SX3->(DbSeek("FRN_INCIMP")) .AND. X3Uso(SX3->X3_USADO)
	lImpInc:=.T.
Endif
SX3->(dbSetOrder(1))

bCampo := {|nCPO| Field(nCPO) }

If Altera .or. lDeleta
	FRM->(dbGoto(nRecFRM))
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero de itens           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) == 1
	If aCols[1][1] =="01" .And. Empty(aCols[1][2]) .And.;
			Empty(aCols[1][3]) .And. Empty(aCols[1][4]) .And.;
			Empty(aCols[1][5]) .aND. Empty(aCols[1][6])
		aCols := {}
	EndIf
EndIf

nMaxArray := Len(aCols)
If nMaxArray > 1
	For ny := 1 to Len(aHeader)
		If Empty(aCols[nMaxArray][ny])
			If Trim(aHeader[ny][2]) == "FRM_SEQ" .Or.;
					Trim(aHeader[ny][2]) == "FRM_COD"
				nMaxArray--
				Exit
			EndIf
		Endif
	Next ny

	If nMaxArray <= 0
		Return .F.
	Endif

	For nx=1 to nMaxArray
		If aCols[nx][Len(aCols[nx])]
			nCntDel++
		Endif
	Next nx

	If nCntDel >= nMaxArray
		Return .F.
	Endif
EndIf
cFRM_COD   := If(Inclui,M->FRM_COD,FRM->FRM_COD)
cFRM_Dscr  := If(Altera .or. Inclui,M->FRM_DSCIMP,FRM->FRM_DSCIMP)
cFRM_Cart  := If(Inclui .or. Altera,M->FRM_CARTEI,FRM->FRM_CARTEI)
cFRM_Sigla := If(Inclui,M->FRM_SIGLA,FRM->FRM_SIGLA)
cFRM_TPABT := If(Inclui .or. Altera,M->FRM_TPABT,FRM->FRM_TPABT)
cFRM_TPTIT := If(Inclui .or. Altera,M->FRM_TPTIT,FRM->FRM_TPTIT)
cFRM_MSBLQL:= If(Inclui .or. Altera,M->FRM_MSBLQL,FRM->FRM_MSBLQL)
cFRM_RGPARC:= If(Inclui .or. Altera,M->FRM_RGPARC,FRM->FRM_RGPARC)
dbSelectArea("FRM")
For nx := 1 to nMaxArray
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apenas da append quando o acols nao estiver deletado  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Altera .and. !aCols[nx][Len(aCols[nx])] .or. Inclui .and. !aCols[nx][Len(aCols[nx])]
		If !Empty(aCols[nx][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_SEQ"})])
		   If aCols[nx][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_REC_WT"})] <>0
		   	lAltOk:=Fa021ChkDel(cFRM_COD,aCols[nx][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_SEQ"})],1,.T.)
				If nX==1
					FRM->(DbGoto(nRecFRM))
					RecLock("FRM",.F.)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza dados - FRM                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FRM->FRM_FILIAL := xFilial("FRM")
					FRM->FRM_DSCIMP	:= cFRM_Dscr
					FRM->FRM_CARTEI	:= cFRM_Cart
					FRM->FRM_TPABT	:= cFRM_TPABT
					FRM->FRM_TPTIT	:= cFRM_TPTIT 
					FRM->FRM_MSBLQL	:= cFRM_MSBLQL
					FRM->FRM_RGPARC := cFRM_RGPARC
					MsUnLock()
				Endif
			   FRM->(DbGoTo(aCols[nx][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_REC_WT"})]))
			   RecLock("FRM",.F.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza dados - FRM                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FRM->FRM_FILIAL := xFilial("FRM")
				FRM->FRM_DSCIMP	:= cFRM_Dscr
				FRM->FRM_CARTEI	:= cFRM_Cart
				FRM->FRM_TPABT	:= cFRM_TPABT
				FRM->FRM_TPTIT	:= cFRM_TPTIT
				FRM->FRM_RGPARC := cFRM_RGPARC
				For ny := 1 to Len(aHeader)
					cVar := Trim(aHeader[ny][2])
					If aHeader[ny][10] # "V" .AND. aHeader[nY][2]<>"FRM_FILIAL"
						If lAltok
							Replace &cVar. With aCols[nx][ny]
						Else
							If cVar == "FRM_DESCR"
								Replace &cVar. With aCols[nx][ny]
							Else
								If cVar == "FRM_BLOQ"
									If FRM->FRM_BLOQ <> "1" .and. aCols[nx][ny]=="1" .or. FRM->FRM_BLOQ <> "1" .and. cFRM_MSBLQL=="1"
										Replace &cVar. With aCols[nx][ny]
									   //*************************// Bloquear Naturezas
									   FRN->(DbSetOrder(4))
									   If FRN->(DbSeek(xFilial("FRN")+FRM->FRM_COD+FRM->FRM_SEQ))
									   	cCodNatur:=FRN->FRN_CODNAT
									   	While !FRN->(EOF()) .and. FRN->FRN_FILIAL+FRN->FRN_IMPOST+FRN->FRN_SEQ == xFilial("FRN")+FRM->FRM_COD+FRM->FRM_SEQ
									   		If FRN->FRN_MSBLQL <> "1"
											   	RecLock("FRN",.F.)
										   		FRN->FRN_MSBLQL := "1"
											   	FRN->(MsUnlock())
											   	SED->(DbSetOrder(1))
												   If SED->(DbSeek(xFilial("SED")+cCodNatur))
												   	RecLock("SED",.F.)
												   	SED->ED_MSBLQL := "1"
													   FRN->(MsUnlock())
													Endif
												Endif
												FRN->(DbSkip())
										   Enddo
										Endif
										//*************************// Bloquear Naturezas
										If lImpInc
										   FRN->(DbSetOrder(5))
										   If FRN->(DbSeek(xFilial("FRN")+FRM->FRM_COD+FRM->FRM_SEQ))
										   	cCodNatur:=FRN->FRN_CODNAT
										   	While !FRN->(EOF()) .and. FRN->FRN_FILIAL+FRN->FRN_INCIMP+FRN->FRN_INCSEQ == xFilial("FRN")+FRM->FRM_COD+FRM->FRM_SEQ
										   		If FRN->FRN_MSBLQL <> "1"
												   	RecLock("FRN",.F.)
												   	FRN->FRN_MSBLQL := "1"
												   	FRN->(MsUnlock())
											      	SED->(DbSetOrder(1))
											   		If SED->(DbSeek(xFilial("SED")+cCodNatur))
											   			RecLock("SED",.F.)
											   			SED->ED_MSBLQL := "1"
															FRN->(MsUnlock())
														Endif
											      Endif
											   	FRN->(DbSkip())
											   Enddo
											Endif
										Endif
									Else
										Replace &cVar. With aCols[nx][ny]
									Endif
								Endif
							Endif
						Endif
					Endif
				Next ny
				FRM->FRM_MSBLQL	:= cFRM_MSBLQL
				FRM->(MsUnLock())
		   Else
				If nX==1 .and. Inclui
					RecLock("FRM",.T.)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza dados - FRM                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Replace  FRM_FILIAL     With xFilial("FRM"),;
				     	 	 	FRM_COD        With cFRM_COD,;
				     	 	 	FRM_CARTEI		With cFRM_Cart,;
				     	 	 	FRM_DSCIMP		With cFRM_Dscr,;
			               FRM_SIGLA		With cFRM_SIGLA
					Replace  FRM_TPABT		With cFRM_TPABT
					Replace  FRM_TPTIT		With cFRM_TPTIT
					Replace  FRM_MSBLQL		With cFRM_MSBLQL
					Replace  FRM_RGPARC     With cFRM_RGPARC
					Replace  FRM_SEQ			With "000"
					MsUnLock()
				Endif
				RecLock("FRM",.T.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza dados - FRM                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Replace  FRM_FILIAL     With xFilial("FRM"),;
			     	 	 	FRM_COD        With cFRM_COD,;
			     	 	 	FRM_CARTEI		With cFRM_Cart,;
			     	 	 	FRM_DSCIMP		With cFRM_Dscr,;
		               FRM_SIGLA		With cFRM_SIGLA
				Replace  FRM_TPABT		With cFRM_TPABT
				Replace  FRM_TPTIT		With cFRM_TPTIT
				Replace  FRM_MSBLQL		With cFRM_MSBLQL
				Replace  FRM_RGPARC     With cFRM_RGPARC
				For ny := 1 to Len(aHeader)
					cVar := Trim(aHeader[ny][2])
					If aHeader[ny][10] # "V" .AND. aHeader[nY][2]<>"FRM_FILIAL"
						Replace &cVar. With aCols[nx][ny]
					Endif
				Next ny
				MsUnLock()
			EndIf
		Endif
	Else
		If aCols[nx][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_REC_WT"})] <>0

			//Verifica se existe o cabeçalho e se existir, apaga
			If !(ALTERA .Or. INCLUI)
				F021DelCab(cFRM_COD)
			EndIf

		   If Fa021ChkDel(cFRM_COD,aCols[nx][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_SEQ"})],1,.T.)
				FRM->(DbGoTo(aCols[nx][Ascan(aHeader,{|x|Alltrim(x[2])=="FRM_REC_WT"})]))
				RecLock("FRM",.F.)
				FRM->(DbDelete())
				FRM->(MsUnLock())
			Else
				//**** Se for exclusao total e encontrar lançamentos associados válidos abortara a exclusão.
				If !Altera
					Return .F.
				Endif
			Endif
		Endif
	Endif
Next nx
If lDeleta
EndIf
FRN->(DbSetOrder(1))
dbSelectArea("FRM")
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA021FIL  ³ Autor ³ WAGNER MONTENEGRO³ Data ³ 05-04-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtro da Getdados                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINA021FIL()
Local lRet := .F.
IF FRM->FRM_FILIAL==xFilial('FRM') .AND. FRM->FRM_SEQ=="000"
	lRet:=.T.
Endif
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA021DOk  ³ Autor ³ WAGNER MONTENEGRO³ Data ³ 05-04-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação de Exclusão na getdados                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FINA021DOk()
Local lRet	:=.T.
Local nPosBloq	:= Ascan(aHeader,{|x| Trim(x[2])=="FRM_MSBLQL"})
Local nPosRecn := Ascan(aHeader,{|x| Trim(x[2])=="FRM_REC_WT"})
oGetd:oBrowse:lDisablePaint := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se o ultimo elemento do array e' Logico     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[n][Len(aCols[n])] .and. Len(aCols)>1 .and. n==1
	Help(" ",1,"HELP",STR0037,STR0038,1,0)
	Return(.F.)
EndIf
If aCols[n][nPosRecn]<>0
	FRM->(DbGoTo(aCols[n][nPosRecn]))
	If FRM->FRM_MSBLQL=="1" .and. n <> Len(aCols)
	   lRet:=.F.
		Help(" ",1,"HELP",STR0008,STR0039,1,0)
	Endif
Endif
oGetd:oBrowse:lDisablePaint := .F.
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA021V01  ³ Autor ³ WAGNER MONTENEGRO³ Data ³ 05-04-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação dos Campos FRM_TPABT e FRM_TPTIT                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*///Funcção de validação da Clausula When dos campos FRM_TPABT e FRM_TPTIT
FUNCTION FINA021V01(cCart,cAbt,cTit,nX)
Local lRet := .F.
Local nModo := If(Inclui,3,4)
Default nX := 1
oGetd:oBrowse:lDisablePaint := .T.
If nModo <> 0
   If nModo == 4 .and. nX==0 //Validação do WHEN campo FRM_CARTEI
	   lRet:=Fa021ChkDel(M->FRM_COD,M->FRM_SEQ,3)
	   oGetd:oBrowse:lDisablePaint := .T.
	Else
		If nModo = 3 .and. (Empty(M->FRM_COD) .or. Empty(M->FRM_SIGLA) .or. Empty(M->FRM_CARTEI) .or. Empty(M->FRM_DSCIMP))
		   lRet := .F.
		Else
			If cCart<>"3"
				lRet:=Fa021ChkDel(M->FRM_COD,M->FRM_SEQ,3)
				oGetd:oBrowse:lDisablePaint := .T.
				If lRet
					If !Empty(cAbt) .and. Empty(cTit)
						lRet:=Fa021ChkDel(M->FRM_COD,M->FRM_SEQ,3)
						oGetd:oBrowse:lDisablePaint := .T.
					Endif
					If Empty(cAbt) .and. !Empty(cTit)
						lRet:=Fa021ChkDel(M->FRM_COD,M->FRM_SEQ,3)
						oGetd:oBrowse:lDisablePaint := .T.
					Endif
				Endif
			Else
				lRet:=Fa021ChkDel(M->FRM_COD,M->FRM_SEQ,3)
				oGetd:oBrowse:lDisablePaint := .T.
				If lRet
					If Empty(cAbt) .and. Empty(cTit)
						lRet := .T.
					Elseif !Empty(cAbt) .and. Empty(cTit) .and. nX==2
						lRet := .T.
					Elseif Empty(cAbt) .and. !Empty(cTit) .and. nX==1
						lRet := .T.
					Endif
				Else
					If Empty(cAbt) .and. Empty(cTit)
						lRet := .T.
					Elseif !Empty(cAbt) .and. Empty(cTit) .and. nX==2
						lRet := .T.
					Elseif Empty(cAbt) .and. !Empty(cTit) .and. nX==1
						lRet := .T.
					Endif
				Endif
			Endif
		Endif
	Endif
Endif
oGetd:oBrowse:lDisablePaint := .F.
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA021V02  ³ Autor ³ WAGNER MONTENEGRO³ Data ³ 05-04-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação do tipo de Abatimento                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FINA021V02()
Local lRet
oGetd:oBrowse:lDisablePaint := .T.
lRet:=If(!Empty(M->FRM_TPABT), If( FINA021V03(3), if(Substr(M->FRM_TPABT,3,1)<>'-' ,Eval({||oGetd:oBrowse:lDisablePaint := .T.,Help(" ",1,"HELP",STR0032,STR0040,1,0),.F.}), If(ExistCpo("SX5","05"+M->FRM_TPABT),.T.,.F.) ) ,.F.) ,.T.)
oGetd:oBrowse:lDisablePaint := .F.
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA021V04  ³ Autor ³ WAGNER MONTENEGRO³ Data ³ 05-04-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação do Tipo de Titulo                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FINA021V04()
Local lRet
oGetd:oBrowse:lDisablePaint := .T.
lRet:=If(!Empty(M->FRM_TPTIT), If(FINA021V03(4), if(Substr(M->FRM_TPTIT,3,1)=='-',Eval({||oGetd:oBrowse:lDisablePaint := .T.,Help(" ",1,"HELP",STR0032,STR0041,1,0),.F.}), If(ExistCpo("SX5","05"+M->FRM_TPTIT),.T.,.F.) ) ,.F.) ,.T.)
oGetd:oBrowse:lDisablePaint := .F.
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA021v03  ³ Autor ³ WAGNER MONTENEGRO³ Data ³ 05-04-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação do cabeçalho do Imposto                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FINA021V03(nModo,lShow,cOrg)
Local aAreaFRM:=FRM->(GetArea())
Local lRet := .T.
Local nRecFrm:=FRM->(Recno())
Default cOrg := "F"
Default lShow := .T.
Default nModo := 0 	//			=0 Validação na digitação do Campo FRM_CARTEI+FRM_SIGLA
							//			=1 Validação no FINA021TOk
							//nModo	=3 Validação complementar na digitação do Campo FRM_TPABT
							//			=4 Validação complementar na digitação do Campo FRM_TPTI
oGetd:oBrowse:lDisablePaint := .T.
If nModo <= 1
	FRM->(DbSetOrder(3))
	If M->FRM_CARTEI$"12"
		If FRM->(DbSeek(xFilial("FRM")+M->FRM_SIGLA))
			While !FRM->(EOF()) .and. FRM->FRM_FILIAL==xFilial("FRM") .and. FRM->FRM_SIGLA==M->FRM_SIGLA .and. lRet
				If FRM->FRM_MSBLQL == "2"
				   If FRM->FRM_CARTEI==M->FRM_CARTEI
				   	If Inclui
				   		Help(" ",1,"HELP",STR0042,STR0043+M->FRM_SIGLA+STR0044+M->FRM_CARTEI+If(M->FRM_CARTEI="1",STR0045,STR0046)+STR0047+FRM->FRM_COD+"'.",1,0)
				   		lRet := .F.
				   	Else
					   	If FRM->FRM_COD<>M->FRM_COD
						   	Help(" ",1,"HELP",STR0042,STR0043+M->FRM_SIGLA+STR0044+M->FRM_CARTEI+If(M->FRM_CARTEI="1",STR0045,STR0046)+STR0047+FRM->FRM_COD+"'.",1,0)
								lRet := .F.
							Endif
						Endif
				   Else
				   	If FRM->FRM_CARTEI=="3"
				   		If Inclui
				   			Help(" ",1,"HELP",STR0042,STR0043+M->FRM_SIGLA+STR0048+FRM->FRM_COD+STR0049,1,0)
				   			lRet := .F.
					   	Else
					   		If FRM->FRM_COD<>M->FRM_COD
							   	Help(" ",1,"HELP",STR0042,STR0043+M->FRM_SIGLA+STR0048+FRM->FRM_COD+STR0049,1,0)
									lRet := .F.
								Endif
							Endif
						Endif
	            Endif
				Endif
				FRM->(DbSkip())
			Enddo
		Endif
	Else
		If FRM->(DbSeek(xFilial("FRM")+M->FRM_SIGLA))
			While !FRM->(EOF()) .and. FRM->FRM_FILIAL==xFilial("FRM") .and. FRM->FRM_SIGLA==M->FRM_SIGLA .and. lRet
				If FRM->FRM_MSBLQL == "2"
				   If FRM->FRM_CARTEI==M->FRM_CARTEI
				   	If Inclui
				   		Help(" ",1,"HELP",STR0042,STR0043+M->FRM_SIGLA+STR0044+M->FRM_CARTEI+STR0050+FRM->FRM_COD+"'.",1,0)
				   		lRet := .F.
				   	Else
					   	If FRM->FRM_COD<>M->FRM_COD
						   	Help(" ",1,"HELP",STR0042,STR0043+M->FRM_SIGLA+STR0044+M->FRM_CARTEI+STR0050+FRM->FRM_COD+"'.",1,0)
								lRet := .F.
							Endif
						Endif
				   Else
				   	If FRM->FRM_CARTEI $ "12"
				   		If Inclui
				   			Help(" ",1,"HELP",STR0042,STR0043+M->FRM_SIGLA+STR0048+FRM->FRM_COD+STR0044+FRM->FRM_CARTEI+"'("+If(FRM->FRM_CARTEI=='1',STR0052,STR0053)+STR0054,1,0)
				   			lRet := .F.
					   	Else
					   		If FRM->FRM_COD<>M->FRM_COD
							   	Help(" ",1,"HELP",STR0042,STR0043+M->FRM_SIGLA+STR0048+FRM->FRM_COD+STR0044+FRM->FRM_CARTEI+"'("+If(FRM->FRM_CARTEI=='1',STR0052,STR0053)+STR0054,1,0)
									lRet := .F.
								Endif
							Endif
						Endif
	            Endif
				Endif
				FRM->(DbSkip())
			Enddo
	   Endif
	Endif
Endif
If lRet .and. nModo>=1
	FRM->(DbGoto(nRecFRM))
	lRet:=Fa021ChkDel(M->FRM_COD,M->FRM_SEQ,3)
	oGetd:oBrowse:lDisablePaint := .T.
	If nModo == 1 .and. !lRet
		If FRM->FRM_SIGLA 	== M->FRM_SIGLA .OR.;
			FRM->FRM_CARTEI	== M->FRM_CARTEI .OR.;
			FRM->FRM_TPABT		== M->FRM_TPABT .OR.;
			FRM->FRM_TPTIT		== M->FRM_TPTIT
			If FRM->FRM_MSBLQL <> M->FRM_MSBLQL
				If M->FRM_MSBLQL == "1"
					lRet:= .T.
				Endif
			Else
				lRet:=.T.
			Endif
		Endif
	Else
		If !lRet
			If lShow
				Help(" ",1,"HELP",STR0010,STR0022,1,0)
			Endif
		Endif
	Endif
	If lRet .and. (nModo==1 .or. nModo==3)
		FRM->(DbSetOrder(4))
		If cOrg<>"W"
			If !Empty(M->FRM_TPABT) .and. FRM->(DbSeek(xFilial("FRM")+M->FRM_TPABT+"2"))
				If FRM->FRM_SIGLA <> M->FRM_SIGLA
					If lShow
						Help(" ",1,"HELP",STR0042,STR0056+M->FRM_TPABT+STR0057+FRM->FRM_SIGLA+STR0058,1,0)
						M->FRM_TPABT:=Space(Len(M->FRM_TPABT))
						lRet:=.F.
					Endif
					If cOrg == "W"
						M->FRM_TPABT:=Space(Len(M->FRM_TPABT))
					Endif
				Endif
			Endif
		Else
			If !Empty(M->FRM_TPABT) .and. FRM->(DbSeek(xFilial("FRM")+M->FRM_TPABT+"2"))
				While !FRM->(EOF()) .and. FRM->FRM_FILIAL == xFilial("FRM") .and. FRM->FRM_TPABT == M->FRM_TPABT .and. lRet
					If FRM->FRM_MSBLQL <> "1" .and. FRM->FRM_COD <> M->FRM_COD
						If Altera .and. M->FRM_TPABT == cFRMABT
							lRet := .F.
						Endif
 						If Inclui .AND. FRM->FRM_SIGLA <> M->FRM_SIGLA
  							M->FRM_TPABT:=Space(Len(M->FRM_TPABT))
  						Endif
					Endif
					FRM->(DbSkip())
				Enddo
			Endif
		Endif
		If lRet .and. cOrg <> "W"
			FRM->(DbSetOrder(3))
			If FRM->(DbSeek(xFilial("FRM")+M->FRM_SIGLA))
				While !FRM->(EOF()) .and. FRM->FRM_FILIAL==xFilial("FRM") .and. FRM->FRM_SIGLA==M->FRM_SIGLA .and. lRet
					If FRM->FRM_MSBLQL<>"1"
						If FRM->FRM_TPABT <> M->FRM_TPABT .AND. FRM->FRM_COD <> M->FRM_COD
							If lShow
								Help(" ",1,"HELP",STR0042,STR0043+FRM->FRM_SIGLA+STR0059+FRM->FRM_TPABT+STR0060,1,0)
								M->FRM_TPABT:=Space(Len(M->FRM_TPABT))
								lRet:=.F.
							Endif
							If cOrg == "W"
								M->FRM_TPABT:=Space(Len(M->FRM_TPABT))
							Endif
	               Endif
					Endif
					FRM->(DbSkip())
				Enddo
			Endif
		Else
			FRM->(DbSetOrder(3))
			If Inclui .and. FRM->(DbSeek(xFilial("FRM")+M->FRM_SIGLA))
				While !FRM->(EOF()) .and. FRM->FRM_FILIAL==xFilial("FRM") .and. FRM->FRM_SIGLA==M->FRM_SIGLA .and. lRet
					If FRM->FRM_MSBLQL<>"1"
						If FRM->FRM_COD <> M->FRM_COD
  							M->FRM_TPABT:=FRM->FRM_TPABT
  							M->FRM_TPTIT:=FRM->FRM_TPTIT
  							lRet:=.F.
	               Endif
					Endif
					FRM->(DbSkip())
				Enddo
			Endif
		Endif
	Endif
	If lRet .and. (nModo==1 .or. nModo==4)
		FRM->(DbSetOrder(5))
		If cOrg <> "W"
			If !Empty(M->FRM_TPTIT) .and. FRM->(DbSeek(xFilial("FRM")+M->FRM_TPTIT+"2"))
				If FRM->FRM_SIGLA <> M->FRM_SIGLA
					If lShow
						Help(" ",1,"HELP",STR0042,STR0061+M->FRM_TPTIT+STR0057+FRM->FRM_SIGLA+STR0063,1,0)
						M->FRM_TPTIT:=Space(Len(M->FRM_TPTIT))
						lRet:=.F.
					Endif
					If cOrg == "W"
				  	  	M->FRM_TPTIT:=Space(Len(M->FRM_TPTIT))
					Endif
				Endif
			Endif
		Else
			If !Empty(M->FRM_TPTIT) .and. FRM->(DbSeek(xFilial("FRM")+M->FRM_TPTIT+"2"))
				While !FRM->(EOF()) .and. FRM->FRM_FILIAL == xFilial("FRM") .and. FRM->FRM_TPTIT == M->FRM_TPTIT .and. lRet
					If FRM->FRM_MSBLQL <> "1" .and. FRM->FRM_COD <> M->FRM_COD
						If Altera .and. M->FRM_TPTIT == cFRMTIT
							lRet := .F.
						Endif
						If Inclui .AND. FRM->FRM_SIGLA <> M->FRM_SIGLA
							M->FRM_TPTIT:=Space(Len(M->FRM_TPTIT))
						Endif
					Endif
					FRM->(DbSkip())
				Enddo
			Endif
		Endif
		If lRet .and. cOrg <> "W"
			FRM->(DbSetOrder(3))
			If FRM->(DbSeek(xFilial("FRM")+M->FRM_SIGLA))
				While !FRM->(EOF()) .and. FRM->FRM_FILIAL==xFilial("FRM") .and. FRM->FRM_SIGLA==M->FRM_SIGLA .and. lRet
					If FRM->FRM_MSBLQL<>"1"
						If FRM->FRM_TPTIT <> M->FRM_TPTIT .AND. FRM->FRM_COD <> M->FRM_COD
							If lShow
								Help(" ",1,"HELP",STR0042,STR0043+FRM->FRM_SIGLA+STR0064+FRM->FRM_TPTIT+STR0065,1,0)
								lRet:=.F.
							Endif
							If cOrg == "W"
						  	  	M->FRM_TPTIT:=Space(Len(M->FRM_TPTIT))
							Endif
	               Endif
					Endif
					FRM->(DbSkip())
				Enddo
			Endif
		Else
			FRM->(DbSetOrder(3))
			If Inclui .and. FRM->(DbSeek(xFilial("FRM")+M->FRM_SIGLA))
				While !FRM->(EOF()) .and. FRM->FRM_FILIAL==xFilial("FRM") .and. FRM->FRM_SIGLA==M->FRM_SIGLA .and. lRet
					If FRM->FRM_MSBLQL<>"1"
						If FRM->FRM_COD <> M->FRM_COD
  							M->FRM_TPTIT:=FRM->FRM_TPTIT
  							M->FRM_TPABT:=FRM->FRM_TPABT
  							lRet:=.F.
	               Endif
					Endif
					FRM->(DbSkip())
				Enddo
			Endif
		Endif
	Endif
Endif
FRM->(RestArea(aAreaFRM))
oGetd:oBrowse:lDisablePaint := .F.
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA021FIL  ³ Autor ³ WAGNER MONTENEGRO³ Data ³ 05-04-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação do Bloqueio de Imposto e Naturezas Financeiras   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINA021V05()
Local lRet:=.T.
oGetd:oBrowse:lDisablePaint := .T.
lRet:=ApMsgYesNo(STR0066+CRLF+STR0067)
oGetd:oBrowse:lDisablePaint := .F.
Return(lRet)




/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FA021Cpos ³ Autor ³ RODRIGO GIMENES       ³ Data ³ 03/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CONFIGURAÇÃO DE ARRAY DE CAMPOS                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FA021CPOS(ExpA1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expa1 = Array com os campos do cabeçalho                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA021Cpos(_aAcho)
Local aRet := {}
Local aArea	 := GetArea()
Local cAlias := "FRM"
Local cCampo := ""


DbSelectArea("SX3")
SX3->(DbSetorder(1))
SX3->(DbSeek(cAlias))

Do While !SX3->(EOF()) .And. (X3_ARQUIVO == cAlias)
	cCampo := Trim(SX3->(X3_CAMPO))
	If X3USO(SX3->(X3_USADO)) .And. Ascan(_aAcho,{|x| Trim(x)==cCampo}) == 0
		AADD(aRet,cCampo)
	EndIf
	dbSkip()
Enddo
RestArea(aArea)

Return(aRet)