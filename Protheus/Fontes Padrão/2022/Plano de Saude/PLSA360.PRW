#Include "plsa360.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"
#Include "FWMVCDef.ch"
#Include "TOPCONN.ch"
#INCLUDE "hat-actions.ch"

Static objCENFUNLGP := CENFUNLGP():New()
/*/{Protheus.doc} PLSA360
Cadastro de Prestadores
Tabelas Atualizadas:
SA2/BAU/BB0/BBF/BC8/BBE/BBC/BLJ
@author Eduardo Motta
@since 28/11/2016
/*/

Function PLSA360()
Local lCent 		:= __SetCentury() // Salva formato ano/data 2 ou 4 digitos
Local nI 			:= 0
Local aColors		:=	{}
Local aLegenUsr             
Local cFiltro		:= ""
Local aLegenda := { ;
	{ "BAU->BAU_CODBLO==Space(03) .Or. BAU->BAU_DATBLO > DDATABASE" ,"BR_VERDE"   ,OemtoAnsi(STR0034)},; //"Rede de Atendimento Ativa"
	{ "BAU->BAU_CODBLO<>Space(03) .AND. BAU->BAU_DATBLO <= DDATABASE" ,"BR_VERMELHO",OemtoAnsi(STR0035)}	} 	//"Rede de Atendimento Bloqueada"
//Local aRotina 		:= MenuDef()

PRIVATE _aRotina 	:= MenuDef()
PRIVATE aRotina		:= {}
PRIVATE cCadastro 	:= FunDesc() //Rede de Atendimento (RDA) - Cadastro STR0097
PRIVATE aHeader     := {}
PRIVATE aCols       := {}
PRIVATE n           := 1
PRIVATE lUsrConf    := .F.
PRIVATE	aCdCores  	:= {}

CarregaCri()

__SetCentury( "on" )   // habilita ano para 4 digitos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para inclusão de nova(s)cores a legenda.			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("PLA360B2") )
	aLegenUsr := ExecBlock("PLA360B2",.F.,.F.)
	If ( ValType(aLegenUsr) == "A" )
		aLegenda := {}
		For nI := 1 To LEN(aLegenUsr)
			aAdd( aLegenda	,{aLegenUsr[nI][03],aLegenUsr[nI][01],aLegenUsr[nI][02]} )
		Next nI
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona as cores da legenda.										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To LEN(aLegenda)
	aAdd( aCdCores	,{aLegenda[nI][02],aLegenda[nI][03]} )
	aAdd( aColors	,{aLegenda[nI][01],aLegenda[nI][02]} )
Next nI

If ExistBlock("PLA360FL")
	cFiltro:= Execblock("PLA360FL",.F.,.F.,cFiltro)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Starta mBrowse...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRotina := aclone(_aRotina)
BAU->(DBSetOrder(2))
BAU->(mBrowse(06,01,22,75,"BAU",,,20,,,aColors,,,,,,,,cFiltro))
__SetCentury(If(lCent,"on","off")) // Retorna formato ano salvo anteriormente 2 ou 4 digitos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA360MNT³ Autor ³ Eduardo Motta         ³ Data ³ 23.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modulo de Manutencao da  Rede Ferefenciada                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PLSA360MNT(cAlias,nReg,nOpc)                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
FOI FEITA ESTA FUNCAO PARA DECLARAR AS PRIVATES DEVIDO AO "TABLE OVERFLOW" DA COMPILACAO. (EDUARDO MOTTA-08/11/2001)
/*/
Function PLSA360MNT(cAlias,nReg,nOpc)

Private oFolder
Private nOpcao   := nOpc
Private lOk      :=.F.
Private aSvAtela := {{},{},{}}
Private aSvAGets := {{},{},{}}
Private aTela    :={}
Private aGets    :={}
Private oEnc01
Private oGet11
Private oGet13
Private oGet14
PRIVATE oGet15
PRIVATE oGet22
PRIVATE oGet23
PRIVATE oGet24
PRIVATE oGet25
PRIVATE oGet26
PRIVATE oGet27
PRIVATE oBrwB25
PRIVATE oBrwB26
PRIVATE oBrwRdAt
PRIVATE aDadRdAt  	:= {}
PRIVATE aTrbRdAt  	:= {}
PRIVATE aVetConf  	:= {}
PRIVATE oSay01
PRIVATE oSayEsp02
PRIVATE cPrePRF   	:= "01"
PRIVATE lProgRR   	:= .T.
Private cCodQuest 	:= ""
Private cProQuest 	:= ""
Private lRetorno  	:= .F.
Private aHeadPer  	:= {}
Private aColsPer  	:= {}
Private aVetPer   	:={}
PRIVATE nQtdEsp   	:= 0
PRIVATE nQtdLinha 	:= 0
PRIVATE aVetBBF   	:= {}
PRIVATE cCodPad 	:= ""
PRIVATE cCodPsa		:= ""
Private oGet28

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

Return ManutRef(cAlias,nReg,nOpc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ManutRef  ³ Autor ³ Eduardo Motta         ³ Data ³ 23.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modulo de Manutencao da  Rede Ferefenciada                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PLSA360MNT(cAlias,nReg,nOpc)                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ManutRef(cAlias,nReg,nOpc)

Local I__f := 0
Local nControl	:= 0, nOk:=0
Local aPages    := {}, aTitles:= {}, aVar:={}
Local oDlg, ni
Local oFont
Local aFolders
Local nOpca     := 0
Local oWnd      := GetWndDefault()
Local oScr05
Local cDesQue
Local cDesProQ
Local nTam
Local oFont01
Local bFilter
Local lLock     := .F.
Local aVetGet11 :={}
Local aVetGet13 :={}
Local aVetGet14 :={}
Local aVetGet15 :={}
Local aVetGet22 :={}
Local aVetGet23 :={}
Local aVetGet24 :={}
Local aVetGet25 :={}
Local aVetGet26 :={}
Local aVetGet27 :={}  //Informacoes ANS
Local aVetGet31 :={}  //Rda x Tab Preço
Local nFolTbP   := 12
Local aTrbB25 	:={}
Local aTrbB26 	:={}
Local aBBFVis 	:={}
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aVetGet28 :={}  //Excecao de Critica
Local lAtuTab   := .T.
Local nOrdBAU   := BAU->(IndexOrd())
LOCAL oGrupo
Local oScroll
Local bCancel  := {|| If(MsgYesNo(__cMsgAban),(nOpca := 0, oDlg:End()),.F.) }
Local aButtons := {}
Local aDifSize:= {,,,,35,3,,}//array com dimenções para correção de telas na versão 12
Local lGrvDatAtu := .F.
Local bCondicao := {}
Local lRet			:= .F.
Local nPercInss	:= 0
Local aBBC			:= {}
Local nX			:= 0
Local lImpFinPos := BBC->(fieldPos("BBC_IMPFIN")) > 0
Local cDtBase		:= ''
Local cDtIni		:= ''

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Integração GRC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

If ! PLSA360Del(nOpc)
	Return
Endif
N := 1
aFolders  := {;
	__cNameBAU,OemtoAnsi(STR0008),OemtoAnsi(STR0009),OemtoAnsi(STR0010),; //"Especialidades"###"Documentos"###"Dependentes"
  OemtoAnsi(STR0011),OemtoAnsi(STR0012),OemtoAnsi(STR0039),OemtoAnsi(STR0040)} //"Debito/Credito"###"Formacao Profissional"###"Informacoes ANS"###"Excecao de Critica"
If PLSALIASEX("B25")
	Aadd(aFolders, "Procedimentos Incompativeis")
	nProcInc := Ascan(aFolders, "Procedimentos Incompativeis")
Endif
If PLSALIASEX("BCF")
	nExcCrit := Ascan(aFolders, OemtoAnsi(STR0040))
Endif

If PLSALIASEX("B29")
	Aadd(aFolders, OemtoAnsi("Tab. Preço"))
	nFolTbP := Ascan(aFolders, OemtoAnsi("Tab. Preço"))
Endif

SetEnch("")
For nI := 1 to Len(aFolders)
	If !Empty(aFolders[nI])
		Aadd(aTitles,OemtoAnsi(aFolders[nI]))
		Aadd(aPages,"HEADER "+Trim(Str(nI,2)))
		nControl++
	EndIf
Next

DEFINE FONT oFont01 NAME "Arial" SIZE 0,-16 BOLD

DbSelectArea("BAU")
If nOpc == K_Incluir   // inclusao
	BB0->(RegToMemory("BB0",.T.))
  Copy "BAU" To Memory Blank
Else
	BB0->(RegToMemory("BB0",.F.))
	BAU->(RegToMemory("BAU",.F.))
	If nOpc == K_Alterar .Or. nOpc == K_Excluir
		If ! BAU->(RecLock("BAU",.F.))
			BAU->(DbSetOrder(nOrdBAU))
			Return
		Else
			lLock := .T.
		Endif
	Endif
EndIf

SETAPILHA()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declara variavel cCadastro para compatibilizar a rotina  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cCadastro 	:= __cNameBAU

aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 20, .t., .f. } )
AAdd( aObjects, { 100, 100, .t., .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
nLinButton	:= aPosObj[2][4]-45
nLinGetDad	:= aPosObj[2][4]-50
nColGetDad	:= aPosObj[2][3]-10

DEFINE MSDIALOG oDlg TITLE FunDesc() FROM aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CABECALHO INFORMATIVO                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPosObj[1][1], aPosObj[1][2] GROUP oGrupo TO aPosObj[1][3], aPosObj[1][4] PIXEL OF oDlg LABEL " "+__cNameBAU+" "  COLOR CLR_HBLUE, CLR_HRED
PLSSAYESP(;
	aPosObj[1][1]+7,;
	aPosObj[1][2]+5,;
	{ || M->BAU_CODIGO+"  -  "+M->BAU_NOME },;
	aPosObj[1][4]-5,;
	aPosObj[1][3]-7,;
	oDlg,;
	AdvFont,;
	CLR_HBLUE,;
	"oSay01")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de todos os folders do dialogo            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Folder principal da tela NIVEL 1
oFolder := TFolder():New(aPosObj[2][1],aPosObj[2][2],aTitles,aPages,oDlg,,,,.T.,.F.,aPosObj[2][3],aPosObj[2][4],)
oFolder:aDialogs[1]:oFont  := oDlg:oFont
oFolder:aDialogs[2]:oFont  := oDlg:oFont

// Declaracao das GETDADOS do Folder Principal NIVEL 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 01 - Enchoice - PLANO DE SAUDE                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}
dbSelectArea("BAU")
oEnc02:= MsMGet():New("BAU" ,nReg ,nOpcao,,,,,{003,003,aPosObj[2][4]-15,aPosObj[2][3]-4},,,,,,oFolder:aDialogs[1],,,.F.,"aSvATela[2]")
aSvATela[2] := aClone(aTela)
aSvAGets[2] := aClone(aGets)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 03 - ESPECIALIDADES                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CargaCols("BBF",aVetGet15,nOpc)

If Val(GetVersao(.F.)) >= 12 //Valida versão 12
	oGet15 := TPLSBrw():New(003,003,aPosObj[2][3] - 4,aPosObj[2][4] - 15,nil  ,oFolder:aDialogs[02],nil,,nil,nil,nil,.T.,nil,.T.,nil,aHeader,aCols,.F.,"BBF",nOpc,aFolders[02],nil,nil,nil,aVetGet15,'PLSBBFVLD','PLSBBFDEL',,,,,,,,,,,aDifSize)
Else
	oGet15 := TPLSBrw():New(003,003,aPosObj[2][3] - 4,aPosObj[2][4] - 15,nil  ,oFolder:aDialogs[02],nil,,nil,nil,nil,.T.,nil,.T.,nil,aHeader,aCols,.F.,"BBF",nOpc,aFolders[02],nil,nil,nil,aVetGet15,'PLSBBFVLD','PLSBBFDEL')
Endif

oGet15:oBrowse:oBrowse:bAdd  		:= { || If(nQtdLinha >= nQtdEsp,(MsgInfo(OemtoAnsi(STR0013) + AllTrim(Str(nQtdEsp,4))+"."),.F.),(oGet15:ADDLINE())) } //"O maximo de especialidades permitidas e "
oGet15:oBrowse:oBrowse:bWhen 		:= { || PLS360ESP(), .T. }
If nOpcao == K_Alterar
	aBBFVis := IIf( Empty(oGet15:oBrowse:oBrowse:oMother:aCols[1,1]), {}, {"BBF_CODESP"} )
Endif

oGet15:oBrowse:oBrowse:bLDblClick 	:= { || oGet15:EditRecord("BBF", nOpcao, STR0087,oGet15:Linha(), oGet15:oBrowse:aCols, oGet15:oBrowse:aHeader, { || .T. },NIL,NIL,NIL,aBBFVis) }//"Especialidades Rede Atend."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 04 - DOCUMENTOS                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CargaCols("BC8",aVetGet11,nOpc)
If Val(GetVersao(.F.)) >= 12 //Valida versão 12
	oGet11 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[03],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BC8",nOpc,aFolders[3],nil,nil,nil,aVetGet11,,,,,,,,,,,,,aDifSize)
Else
	oGet11 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[03],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BC8",nOpc,aFolders[3],nil,nil,nil,aVetGet11)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 05 - DEPENDENTES                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CargaCols("BBE",aVetGet14,nOpc)
if Val(GetVersao(.F.)) >= 12 //Valida versão 12
	oGet14 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[04],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BBE",nOpc,aFolders[4],nil,nil,nil,aVetGet14,,,,,,,,,,,,,aDifSize)
Else
	oGet14 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[04],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BBE",nOpc,aFolders[4],nil,nil,nil,aVetGet14)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 06 - SERVICOS CONTRATADOS                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CargaCols("BBC",aVetGet13,nOpc)
if Val(GetVersao(.F.)) >= 12 //Valida versão 12
	oGet13 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[05],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BBC",nOpc,aFolders[5],nil,nil,nil,aVetGet13,,,,,,,,,,,,,aDifSize)
Else
	oGet13 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[05],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BBC",nOpc,aFolders[5],nil,nil,nil,aVetGet13)
Endif
oGet13:cVldLine := 'PLSXANAFAI( { "BBC_CODSER", "BBC_CNPJ" },"BBC_VLDINI","BBC_VLDFIM",n) .AND. PlsVldBBC(M->BBC_CODSER)'


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 07 - FORMACAO PROFISSIONAL                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CargaCols("BLJ",aVetGet22,nOpc)
if Val(GetVersao(.F.)) >= 12 //Valida versão 12
	oGet22 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[06],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BLJ",nOpc,aFolders[6],nil,nil,nil,aVetGet22,,,,,,,,,,,,,aDifSize)
Else
	oGet22 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[06],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BLJ",nOpc,aFolders[6],nil,nil,nil,aVetGet22)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 08 - INFORMAÇÕES ANS                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CargaCols("BYV",aVetGet27,nOpc)
if Val(GetVersao(.F.)) >= 12 //Valida versão 12
	oGet27 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[07],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BYV",nOpc,aFolders[7],nil,nil,nil,aVetGet27,,,,,,,,,,,,,aDifSize)
Else
	oGet27 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[07],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BYV",nOpc,aFolders[7],nil,nil,nil,aVetGet27)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 09 - Excecao de Critica	                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("BCF")
	CargaCols("BCF",aVetGet28,nOpc,"CHAVE","BCF->BCF_CODOPE==PLSINTPAD() .And. BCF->BCF_TABELA=='BAU'",PLSINTPAD()+'BAU'+BAU->BAU_CODIGO)
	if Val(GetVersao(.F.)) >= 12 //Valida versão 12
		oGet28 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[nExcCrit],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BCF",nOpc,aFolders[nExcCrit],nil,nil,nil,aVetGet28,,,,,,,,,,,,,,aDifSize)
	Else
		oGet28 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[nExcCrit],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BCF",nOpc,aFolders[nExcCrit],nil,nil,nil,aVetGet28)
	Endif
	oGet28:cVldLine := 'Iif(Empty(M->BCF_CODCRI),.F.,.T.)'
Endif

If PLSALIASEX("B25")
	// Cabeçalho
	CargaCols("B25",aTrbB25,nOpc)
	bUpdB26Aux := {||Iif((Len(oBrwB26:aCols) == 1 .and. Empty(oBrwB26:FieldGet("B26_AUXPAD"))),;
		(ObrwB26:FieldPut("B26_AUXPAD", oBrwB25:FieldGet("B25_CODPAD", oBrwB25:Linha()), 1),;
		 ObrwB26:FieldPut("B26_AUXPSA", oBrwB25:FieldGet("B25_CODPSA", oBrwB25:Linha()), 1),;
		 Eval(oBrwB25:bChange)),"")}

	if Val(GetVersao(.F.)) >= 12 //Valida versão 12
		oBrwB25 := TPLSBrw():New(003,003,aPosObj[2][3]-4,((aPosObj[2][4]/2)-20),nil,oFolder:aDialogs[nProcInc],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aHeader,aCols,.F.,"B25",nOpc,aFolders[nProcInc],nil,nil,nil,aTrbB25,nil,"PlsDelB26",nil,bUpdB26Aux,,,,,,,,,aDifSize) //"Procedimentos Incompativeis."
	Else
		oBrwB25 := TPLSBrw():New(003,003,aPosObj[2][3]-4,((aPosObj[2][4]/2)-20),nil,oFolder:aDialogs[nProcInc],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aHeader,aCols,.F.,"B25",nOpc,aFolders[nProcInc],nil,nil,nil,aTrbB25,nil,"PlsDelB26",nil,bUpdB26Aux) //"Procedimentos Incompativeis."
	Endif

	oBrwB25:bLostFocus := {||cCodPad := oBrwB25:FieldGet("B25_CODPAD",oBrwB25:Linha()), cCodPsa := oBrwB25:FieldGet("B25_CODPSA",oBrwB25:Linha())}
	oBrwB25:bChange    := {||Eval(oBrwB25:bLostFocus),oBrwB26:ForceRefresh(oBrwB25)}
	oBrwB25:cVldLine   := 'PLSVLDVIG("B25",,oBrwB25,"B25_VIGINI","B25_VIGFIN",{1,M->B25_CODPSA,"B25_CODPSA"})'
	oBrwB25:bAfterEdit := bUpdB26Aux


	cCodPad := oBrwB25:FieldGet("B25_CODPAD",1)
	cCodPsa := oBrwB25:FieldGet("B25_CODPSA",1)

	// Itens
	CargaCols("B26",aTrbB26,nOpc,"CODRDA")
	bFilter := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("B26_AUXPAD",aHeader)]==cCodPad .And.;
		aCols[nLine,GdFieldPos("B26_AUXPSA",aHeader)]==cCodPsa}
	if Val(GetVersao(.F.)) >= 12 //Valida versão 12
		oBrwB26 := 	TPLSBrw():New((aPosObj[2][4]/2),003,	aPosObj[2][3]-4,aPosObj[2][4],nil  ,oFolder:aDialogs[nProcInc],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"B26",nOpc,aFolders[nProcInc],nil,nil,nil,aTrbB26,nil,nil,bFilter,,,,,,,,,,aDifSize) //"Procedimentos Incompativeis."
	Else
		oBrwB26 := 	TPLSBrw():New((aPosObj[2][4]/2),003,	aPosObj[2][3]-4,aPosObj[2][4],nil  ,oFolder:aDialogs[nProcInc],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"B26",nOpc,aFolders[nProcInc],nil,nil,nil,aTrbB26,nil,nil,bFilter) //"Procedimentos Incompativeis."
	Endif
	oBrwB26:oPai       := oBrwB25
	oBrwB26:aOrigem    := {"B25_CODPAD","B25_CODPSA"}
	oBrwB26:aRelac     := {"B26_AUXPAD","B26_AUXPSA"}
	oBrwB26:cVldLine   := 'PLSVLDVIG("B26",nOpcao,oBrwB26,"B26_VIGINI","B26_VIGFIN",{1,M->B26_CODPSA,"B26_CODPSA"})'
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 12 - Rda x Tab preço							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B29")
	CargaCols("B29",aVetGet31,nOpc)
	if Val(GetVersao(.F.)) >= 12 //Valida versão 12
		oGet31 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[nFolTbP],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"B29",nOpc,aFolders[nFolTbP],nil,nil,nil,aVetGet31,"PlsVldB29()",,,,,,,,,,,,aDifSize)
	Else
		oGet31 := TPLSBrw():New(003,003,aPosObj[2][3]-4,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[nFolTbP],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"B29",nOpc,aFolders[nFolTbP],nil,nil,nil,aVetGet31,"PlsVldB29()")
	Endif
	oGet31:cVldLine   := 'PlsVldB29()'
Endif

If Existblock("PLA360B1")
	aButtons := aClone(Execblock("PLA360B1",.f.,.f.,{aButtons} ))
Endif

If GetNewPar("MV_PLSUNI","0") == "1"
	aAdd(aButtons,{"relacionamento_direita",{|| PLSRAtA400(nOpc)},STR0085,STR0086})//"Redes de atendimento (A400)"###"Rd. Atend." 
EndIf
IF !INCLUI
	aAdd(aButtons,{"Conhecimento",{|| PLS360CONH()},"Banco Conhecimento","Anexos"})
ENDIF

ACTIVATE DIALOG oDlg ON ;
INIT ( EnchoiceBar(oDlg, {|| If( Plsa360TOk(nOpc,@lGrvDatAtu) ,(PlsEndBrw(),nOpca:=1,oDlg:End(),.F.),.f.) },bCancel,.F.,aButtons ))

If nOpca == K_OK .and. Str(nOpc,1) $ "345"  // so entra se tiver confirmado e a opcao no aRotina for inclusao ou alteracao ou exclusao

	BEGIN TRANSACTION

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Homonimos							         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SuperGetMV("MV_PLSHOMO",,.F.) .and. Str(nOpc,1) $ "34"
			lAtuTab := PlsHomoni(M->BAU_NOME,M->BAU_CPFCGC,M->BAU_CONREG,M->BAU_CNES,M->BAU_INSCR,M->BAU_INSCRM,M->BAU_NASFUN,cAlias,M->BAU_MATVID,IIF(nOpc==3,.T.,.F.))
		Endif

		If nOpc == K_Incluir
			BAU->(ConfirmSX8())
		Endif

		GravaRedeRef(nOpc,lLock,nReg,cAlias,lAtuTab)

		If lGrvDatAtu
			BAU->(RecLock("BAU",.F.))
			BAU->BAU_DATATU := dDataBase
			BAU->(MsUnLock())
		EndIf
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
	//³Integração com o GRC³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
	ENDDOC*/

		aBBC := oGet13:aCols
		dbSelectArea("BBC")
		dbSetOrder(1)//BBC_FILIAL + BBC_CODIGO + BBC_CODSER + BBC_PROMED + BBC_STATUS
		
		SET DELETED OFF
		
		If nOpc != 5
			BBC->(dbGoTop())
		EndIf
		
		For nX := 1  To Len(aBBC)
			
			If MsSeek(xFilial("BBC") + BAU->BAU_CODIGO + aBBC[nX][1] + aBBC[nX][12] + aBBC[nX][13]) .AND. aBBC[nX][1] == SUPERGETMV("MV_PLSCIOE", .T., "")
				
				While !BBC->(EOF()) .AND. xFilial("BBC") + BAU->BAU_CODIGO + aBBC[nX][1] + aBBC[nX][12] + aBBC[nX][13] == BBC->BBC_FILIAL + BBC->BBC_CODIGO + BBC->BBC_CODSER + BBC->BBC_PROMED + BBC->BBC_STATUS
					cDtBase := SUBSTR(Dtos(date()),1,6)
					cDtIni	 := SUBSTR(Dtos(BBC->BBC_VLDINI),1,6)
					If lImpFinPos .AND. !BBC->(Deleted()) .AND. BBC->BBC_IMPFIN != "1" /* Não deletado e Não  importado*/ .AND. !(Val(cDtIni) < Val(cDtBase))
					 	
						nPercInss	:= Posicione("SED", 1, xFilial("SED") + M->BAU_NATURE, "ED_PERCINS")
						cTipoCt	:= Posicione("BBB", 1, xFilial("BBB") + BBC->BBC_CODSER, "BBB_TIPOCT")
						
						lRet := F027AIMP( BAU->BAU_CODSA2;							// Fornecedor
											,BAU->BAU_LOJSA2;							// Loja
											,BBC->BBC_VLDINI;							// Data Inicio
											,BBC->BBC_VLDFIM;							// Data Fim
											,BBC->BBC_NOME;							// Tomador
											,Iif(cTipoCt == "3", "2", cTipoCt);	// Tipo
											,BBC->BBC_CNPJ;							// CNPJ
											,BBC->BBC_VALOR;							// VALOR
											,BBC->BBC_VALOR * (nPercInss / 100))	// VALOR INSS Posicione("SA2", 1, xFilial("SA2") + cFornec + cLoja, "A2_NOME")
						
						If lRet
							BBC->(RecLock("BBC",.F.))
							BBC->BBC_IMPFIN := "1"
							BBC->(MsUnLock())
						EndIf
					
					ElseIf lImpFinPos .AND. BBC->(Deleted()) .AND. BBC->BBC_IMPFIN == "1" // Deletado e Importado
						
						SET DELETED ON
						F027ADEL(	BAU->BAU_CODSA2;
									,BAU->BAU_LOJSA2;
									,BBC->BBC_VLDINI;
									,BBC->BBC_VLDFIM;
									,BBC->BBC_CNPJ)
						SET DELETED OFF
						
						BBC->(RecLock("BBC",.F.))
						BBC->BBC_IMPFIN := "2"
						BBC->(MsUnLock())
											
					EndIf
					
					BBC->(dbSkip())
				
				EndDo
				
			EndIf
			
		Next nX
		
		SET DELETED ON
				
		BBC->(dbCloseArea())
		

	END TRANSACTION

	If  ExistBlock("PLSA360FIM")
		ExecBlock("PLSA360FIM",.F.,.F.,{nOpc})
	Endif

Else

	If nOpc == K_Incluir
		RollBackSX8()
	Endif

EndIf

BAU->(DbSetOrder(nOrdBAU))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Plsa360VlR ³ Autor ³ Eduardo Motta       ³ Data ³ 04.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do campo BAZ_CODRES para liberar ou nao campo do ³±±
±±³          ³ complemento.                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa360VlR(cPropri,cQuest,cCodPer)

BAK->(DbSetOrder(1))
BAK->(MsSeek(xFilial()+cPropri+cQuest+cCodPer+M->BBP_CODRES))
If BAK->BAK_PEDCOM == "1"
	M->BBP_DESCOM := BAK->BAK_DESCOM
Else
	M->BBP_DESCOM := Space(Len(BAK->BAK_DESCOM))
	M->BBP_RESCOM :=  Space(Len(M->BBP_RESCOM))
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Plsa360Ini ³ Autor ³ Eduardo Motta       ³ Data ³ 24.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializador padrao e Init.Browse porque nao caberia o    ³±±
±±³          ³ posicione inteiro no campo X3_INIBRW                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa360Bau(cChave)

Local aArea := sGetArea()
Local cRet

sGetArea(aArea,"BAU")
cRet := Posicione("BAU",1,cChave,"BAU_NOME")
sRestArea(aArea)

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Plsa360Pic ³ Autor ³ Eduardo Motta       ³ Data ³ 05.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a picture do campo BAU_CPFCGC                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa360Pic()
Return PicPes(M->BAU_TIPPE)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Plsa360WhR ³ Autor ³ Eduardo Motta       ³ Data ³ 22.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ When do campo  BBP_RESCOM pois a condicao nao cabe no campo³±±
±±³          ³ X3_WHEN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa360WhR()
Return Empty(M->BBP_DESCOM)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Plsa360TOk ³ Autor ³ Eduardo Motta       ³ Data ³ 08.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a checagem dos campos e pastas obrigatorias            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Plsa360TOk(nOpc)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc - Opcao do aRotina                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa360TOk(nOpc,lGrvDatAtu)

Local lRet     := .T.
Local nFolder  := 0
Local nI       := 0
Local aFoldObr := {}   // colocar neste array as GETDADOS obrigatorias no cadastro, ex: se a getdados oGet02 for obrigatoria especificar no array o elemento 2.
Local oFold
Local oVar

Default lGrvDatAtu := .F.

If M->BAU_CALIMP == '4' .And. Empty(M->BAU_MATFUN)
	MsgInfo(STR0068)//"Ao infomar Forma de Pagto. com (Folha Pagamento) é necessário informar a matrícula do funcionário. Campo: Matr. Func."
	Return .F.
EndIf

BAU->(DbSetOrder(1))
BAU->(MsSeek(xFilial()+M->BAU_CODIGO))
If nOpc == K_Incluir .and. !BAU->(Eof()) // SE FOR INCLUSAO VERIFICA SE O CODIGO JA ESTA GRAVADO NO ARQUIVO E NAO DEIXA CONTINUAR
	Help("",1,"JAGRAVADO")
	oFolder:SetOption(1)
	oFolder:aDialogs[1]:SetFocus()
	Return .F.
EndIf

If _aRotina[nOpc,4] # 3 .and. _aRotina[nOpc,4] # 4  // se a opcao selecionada nao for INCLUSAO ou ALTERACAO nao e' necessario checar os campos obrigatorios.
	Return .T.
EndIf
If !Obrigatorio(aSvAGets[2],aSvATela[2])   // verifica campos obrigatorio do primeiro folder
	lRet    := .F.
	nFolder := 1
	oFold   := oFolder
Else
	For nI := 1 to Len(aFoldObr)  // verifica os FOLDERs obrigatorios no cadastro
		oVar := aFoldObr[nI,1]
		If ValType(oVar) # "O" // se a variavel nao for um objeto foi passado errado no array aFoldObr, verificar o numero e corrigir.
			MsgStop(OemtoAnsi(STR0014)+StrZero(aFoldObr[nI],2)) //"Erro na verificacao de campos obrigatorios do folder "
			Loop
		EndIf
		If ! oVar:TudoOk()
			nFolder := aFoldObr[nI,2]
			oFold   := aFoldObr[nI,3]
			lRet    := .F.
			Exit
		EndIf
	Next
EndIf

If !lRet
	oFold:SetOption(nFolder)
	oFold:aDialogs[nFolder]:SetFocus()
EndIf

If lRet .And. M->BAU_TIPPE == "F"
	nI := 0
	If Empty(M->BAU_SIGLCR)
		lRet := .F.
		nI   := 1
	Endif
	If lRet .And. Empty(M->BAU_ESTCR)
		lRet := .F.
		nI   := 2
	Endif
	If lRet .And. Empty(M->BAU_CONREG)
		lRet := .F.
		nI   := 3
	Endif

	If !lRet
		If nI == 1
			MsgStop(OemtoAnsi(STR0015)) //"Erro na verificacao de campos obrigatorios: Sigla CR"
		Else
			If nI == 2
				MsgStop(OemtoAnsi(STR0016))         //"Erro na verificacao de campos obrigatorios: Estado CR"
			Else
				MsgStop(OemtoAnsi(STR0017))       //"Erro na verificacao de campos obrigatorios: Numero CR"
			Endif
		Endif
	Endif
Endif

If cPaisLoc == "URU" .And. M->BAU_TIPPE == "F"
	If Empty(M->BAU_TIPDOC) .Or. Empty(M->BAU_RG)
		MsgStop("'Tipo Documen' e 'RG/Ced Estr.' obligatorio")
		lRet := .F.
	Endif
Endif

If Empty(M->BAU_CBO) .And. M->BAU_TIPPE == "F"
	Help("",1,"PLSA360CBO")
	lRet:= .F.
Endif

if BAU->(fieldPos("BAU_DTINAT")) > 0 .and. M->BAU_INATIV == "1" .and. Empty(M->BAU_DTINAT)
	MsgStop("Prestador inativo sem data de fim de atendimento(BAU_DTINAT) preenchida")
	lRet:= .F.
endif

If lRet .and. nOpc == K_Alterar .And. GetNewPar("MV_PLSUNI","1") == "1" .And. ;
	MsgYesNo(STR0083+Substr(DtoS(dDataBase),7,2)+"/"+Substr(DtoS(dDataBase),5,2)+"/"+Substr(DtoS(dDataBase),1,4)+STR0084)//"Confirma a data " ### " para envio de alteração de dados cadastrais no PTU A400?"
	lGrvDatAtu    := .T.
EndIf

Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GravaRedeRef³ Autor ³ Eduardo Motta       ³ Data ³ 08.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a gravacao dos dados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GravaRedeRef()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ 08.05.02 ³ xxxx ³ Tulio Cesar ³ Acertos devido a mudanca de conceitos ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaRedeRef(nOpc,lLock,nReg,cAlias,lAtuTab)

Local aChav11
Local aChav13
Local aChav14
Local aChav15
Local aChav22
Local aChav25
Local aChav26
Local aChav27
Local aChav28
Local cVlCod
Local cCodSA2	:= ""
Local cLojSA2	:= ""
Local cCodSRA	:= ""
Local lNovSA2 	:= .T.
Local lNovSRA 	:= .F.
Local aDelBQ1 	:= {}
Local lEspelhar := GetNewPar("MV_PLSCFAU","1") == "1"
Local lEspFun	:= GetNewPar("MV_PLSESRA","0") == "1"
Local aChavB25
Local aChavB26
Local cCodBB0
Local nI		:= 1
Local nCntAux 	:= 1
Local aDadBAU   := {}
Local aAltZ	:= {}
Local aDefaultZ := { "DEFAULT", "DEFAULT", "DEFAULT" }
Local nZ	:= 0
Local cTpArq	:= " "
Local aB84RPS := {}
Local nRPSZ := 0

Default lAtuTab := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Espelhamento BAU X SA2...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o fornecedor ja existe                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BBL->(DbSetOrder(2)) // BBL_FILIAL, BBL_PROGRA, BBL_ALIAS1, BBL_ALIAS2
	If lEspelhar
		If  ! Empty(M->BAU_CODSA2)
			SA2->(DbSetOrder(1))
			lNovSA2 := (SA2->(MsSeek(xFilial("SA2")+M->BAU_CODSA2+M->BAU_LOJSA2)) .And. AllTrim(SA2->A2_CGC) == AllTrim(M->BAU_CPFCGC))
		Else
			SA2->(DBSetOrder(3))
			lNovSA2 := (SA2->(MsSeek(xFilial("SA2")+M->BAU_CPFCGC)))
		Endif
	Else
		lNovSA2 := .T.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve criar fornecedor                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  ! lNovSA2		
		If BBL->(MsSeek(xFilial("BBL")+"PLSA360   "+"BAU"+"SA2"))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Determina codigo e loja do fornecedor                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCodSA2 := GetSA2Cod()
			cCodSa2 := aCodSA2[1]
			cLojSa2 := aCodSA2[2]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso o codigo/loja determinado ja exista,            ³
			//³ exibe mensagem e nao inclui o fornecedor             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SA2->(dbSetOrder(1))
			If  SA2->(MsSeek(xFilial("SA2")+cCodSA2+cLojSA2))
				msgalert(OemtoAnsi(STR0018))   // ??? colocar msg no padrao de help //"O fornecedor nao pode ser criado de forma automatica. Verifique"
			Else
				SA2->(RecLock("SA2",.T.))
				SA2->A2_FILIAL := xFilial("SA2")
				SA2->A2_COD    := cCodSA2
				SA2->A2_LOJA   := cLojSA2
				M->BAU_CODSA2  := cCodSA2
				M->BAU_LOJSA2  := cLojSA2
				PlsSinc("PLSA360","BAU","SA2")
				SA2->(MsUnLock())
			Endif
		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0019)) //"Arquivo de sincronismo entre BAU x SA2 nao esta integro. Verifique!"
			Endif
		Endif
	Endif
	
	If lEspFun
		If Empty(M->BAU_MATFUN) .And. AllTrim(M->BAU_COPCRE) == '1' // Cooperado
			SRA->(DbSetOrder(5)) //RA_FILIAL, RA_CIC
			lNovSRA := !(SRA->(MsSeek(xFilial("SRA")+AllTrim(M->BAU_CPFCGC))) .And. AllTrim(SRA->RA_CIC) == AllTrim(M->BAU_CPFCGC))		
		Else
			lNovSRA := .F.
		Endif

		If lNovSRA 
			If BBL->(MsSeek(xFilial("BBL")+"PLSA360   "+"BAU"+"SRA"))
				cCodSRA	:= staticCall( GPEA265,fProxMat )
				SRA->(RecLock("SRA",.T.))
					SRA->RA_FILIAL := xFilial("SRA") 
					SRA->RA_MAT    := cCodSRA
				PlsSinc("PLSA360","BAU","SRA")
				SRA->(MsUnLock())
				M->BAU_MATFUN  := cCodSRA
				M->BAU_FILFUN  := xFilial("SRA")
			Else	
				If GetNewPar("MV_PLSMSGS","1") == "1"
					MsgAlert(OemtoAnsi("Arquivo de sincronismo entre BAU x SRA nao esta integro. Verifique!")) 
				Endif
			Endif	
		EndIf
	Endif
	
ElseIf nOpc == K_Alterar .And. lAtuTab
	SA2->(DbSetOrder(1))
	If SA2->(MsSeek(xFilial("SA2")+M->BAU_CODSA2+M->BAU_LOJSA2)) .And. lEspelhar
		BBL->(DbSetOrder(2))
		If BBL->(MsSeek(xFilial("BBL")+"PLSA360   "+"BAU"+"SA2")) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CPF do SA2 igual ao do BAU espelha dados...          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(SA2->A2_CGC) == AllTrim(M->BAU_CPFCGC)
				SA2->(RecLock("SA2",.F.))
				PlsSinc("PLSA360","BAU","SA2")
				SA2->(MsUnlock())
			Endif
		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0019)) //"Arquivo de sincronismo entre BAU x SA2 nao esta integro. Verifique!"
			Endif
		Endif
	Endif

	If lEspFun .And. SRA->(MsSeek(M->BAU_FILFUN+M->BAU_MATFUN)) 		
		If BBL->(MsSeek(xFilial("BBL")+"PLSA360   "+"BAU"+"SRA"))
			SRA->(RecLock("SRA",.F.))
			PlsSinc("PLSA360","BAU","SRA")
			SRA->(MsUnLock())
		Else	
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi("Arquivo de sincronismo entre BAU x SRA nao esta integro. Verifique!")) 
			Endif
		Endif	
	Endif

Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Espelhamento BAU X BBO...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->BAU_TIPPE == "F" .And. nOpc <> K_Excluir
	If ! Empty(M->BAU_CONREG)

		If  nOpc == K_Incluir .or. empty(M->BAU_CODBB0)
			BB0->(DbSetOrder(4))
			BB0->(MsSeek(xFilial("BB0")+M->BAU_ESTCR+M->BAU_CONREG+M->BAU_SIGLCR))
		Else
			BB0->(DbSetOrder(1))
			BB0->(MsSeek(xFilial("BB0")+M->BAU_CODBB0))
		Endif

		BBL->(DbSetOrder(2))
		If BBL->(MsSeek(xFilial("BBL")+"PLSA360   "+"BAU"+"BB0"))

			BB0->(RecLock("BB0",!BB0->(Found())))
			If ! BB0->(Found())
				cVlCod          := CriaVar("BB0_CODIGO")
				cCodBB0         := If(!Empty(cVlCod),cVlCod,GetSX8Num("BB0","BB0_CODIGO"))
				BB0->BB0_FILIAL := xFilial("BB0")
				BB0->BB0_CODIGO := cCodBB0
				M->BAU_CODBB0   := cCodBB0
				BB0->BB0_VINC := "1"
			Else
				BB0->BB0_VINC := "1"
				M->BAU_CODBB0   :=BB0->BB0_CODIGO

			Endif

			PlsSinc("PLSA360","BAU","BB0")   // SINCRONIZA DADOS DO BAU PARA O BB0
			BB0->BB0_CODOPE := PLSINTPAD()
			BB0->(MsUnlock())
			BB0->(ConfirmSX8())

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Ponto de entrada para permitir atualizar campos no BB0  ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  ExistBlock("PLS360BB0")
				ExecBlock("PLS360BB0",.F.,.F.)
			Endif

		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0020))			 //"Arquivo de sincronismo entre BAU x BB0 nao esta integro. Verifique!"
			Endif
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama integracao com o HAT                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_PLSHAT","0") == "1"  
    Aadd(aDadBAU,{"BAU_CODIGO",M->BAU_CODIGO})       
    Aadd(aDadBAU,{"BAU_CPFCGC",M->BAU_CPFCGC})
    Aadd(aDadBAU,{"BAU_NOME",M->BAU_NOME})
    Aadd(aDadBAU,{"BAU_NREDUZ",M->BAU_NREDUZ})
    Aadd(aDadBAU,{"BAU_TIPPE",M->BAU_TIPPE})
    Aadd(aDadBAU,{"BAU_TIPPRE",M->BAU_TIPPRE})
    Aadd(aDadBAU,{"BAU_EMAIL",M->BAU_EMAIL})
    Aadd(aDadBAU,{"BAU_CNES",M->BAU_CNES})

	PLHAT360(nOpc,M->BAU_CODIGO,aDadBAU)
EndIf
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava folders...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aChav11 := {{"BC8_CODIGO",M->BAU_CODIGO}}
aChav13 := {{"BBC_CODIGO",M->BAU_CODIGO}}
aChav14 := {{"BBE_CODIGO",M->BAU_CODIGO}}
aChav15 := {{"BBF_CODIGO",M->BAU_CODIGO}}
aChav22 := {{"BLJ_CODIGO",M->BAU_CODIGO}}
aChav25 := {{"BIN_CODIGO",M->BAU_CODIGO}}
aChav26 := {{"BIO_CODIGO",M->BAU_CODIGO}}
aChav27 := {{"BYV_CODIGO",M->BAU_CODIGO}}
aChavB25:= {{"B25_CODIGO",M->BAU_CODIGO}}
aChavB26:= {{"B26_CODRDA",M->BAU_CODIGO}}

oGet11:Grava(aChav11)   // FOLDER 11 - DOCUMENTOS
oGet13:Grava(aChav13)   // FOLDER 13 - SERVICOS CONTRATADOS
oGet14:Grava(aChav14)   // FOLDER 14 - DEPENDENTES
oGet15:Grava(aChav15)   // FOLDER 15 - ESPECIALIDADES
oGet22:Grava(aChav22)   // FOLDER 22 - Residencias
oGet27:Grava(aChav27)   // FOLDER 27 - Informacoes ANS

If PLSALIASEX("B29")
	aChavB29:= {{"B29_CODIGO",M->BAU_CODIGO}}
	oGet31:Grava(aChavB29)  // FOLDER 31 - Tab. Preço
Endif

If PLSALIASEX("BCF")
	aChav28 := {}
	AaDd(aChav28,{"BCF_CODOPE" ,PLSINTPAD()})
	AaDd(aChav28,{"BCF_TABELA" ,"BAU"})
	AaDd(aChav28,{"BCF_CHAVE" ,M->BAU_CODIGO})
	oGet28:Grava(aChav28)   // FOLDER 28 - Excecao de Critica
Endif
If PLSALIASEX("B25")
	oBrwB25:Grava(aChavB25)   // FOLDER Procedimentos incompativeis
	oBrwB26:Grava(aChavB26)   // FOLDER Procedimentos incompativeis
Endif

If ValType(oBrwRdAt) <> "U"  // Tratamento específico para o A400
	B7O->(DbSetOrder(2))//B7O_FILIAL+B7O_CODRDA+B7O_NVEXC+B7O_REDEXC
	aChavRdAt := {{"B0G_CODRDA",M->BAU_CODIGO}}

	For nCntAux := 1 To Len(aDadRdAt)
		If  aDadRdAt[nCntAux][Len(aDadRdAt[nCntAux])] // Pego o ultimo registro referente ao D_E_L_E_T_
			
			If B7O->(dbSeek(xFilial('B7O')+BAU->BAU_CODIGO+'03'+ aDadRdAt[nCntAux][1]+StrZero(Val(aDadRdAt[nCntAux][2]),2) ))
				RecLock('B7O', .F.)
					B7O->B7O_FILIAL := xFilial('B7O')
					B7O->B7O_CODRDA := BAU->BAU_CODIGO							
					If B7O->(FieldPos('B7O_DTBLOQ')) > 0
						B7O->B7O_NVEXC  := '03'
						B7O->B7O_DTBLOQ := DATE()
						B7O->B7O_REDEXC := aDadRdAt[nCntAux][1]+StrZero(Val(aDadRdAt[nCntAux][2]),2)     
						B7O->B7O_ENDEXC	:= ""
						B7O->B7O_PLAEXC	:= ""
					EndIf
				B7O->(MsUnlock())
			Else
				RecLock('B7O', .T.)
					B7O->B7O_FILIAL := xFilial('B7O')
					B7O->B7O_CODRDA := BAU->BAU_CODIGO						
					If B7O->(FieldPos('B7O_DTBLOQ')) > 0
						B7O->B7O_NVEXC  := '03'
						B7O->B7O_REDEXC := aDadRdAt[nCntAux][1]+StrZero(Val(aDadRdAt[nCntAux][2]),2) 
						B7O->B7O_ENDEXC	:= ""
						B7O->B7O_PLAEXC	:= ""
						B7O->B7O_DTBLOQ := DATE()
					EndIf
				B7O->(MsUnlock())
			EndIF
		EndIF
	Next
	
	If Ascan(aDadRdAt, {|x| Empty(x[1])}) == 0
		oBrwRdAt:Grava(aChavRdAt,.T.)
	EndIf
	aDadRdAt := {}
EndIf

If nOpc <> K_Excluir .and. PlsAliasExi("BQ1") .and. !Empty(M->BAU_CODBB0)
	BB0->(DbSetOrder(1))
	If BB0->(MsSeek(xFilial("BB0")+M->BAU_CODBB0))
		BQ1->(DbSetORder(1))
		If BQ1->(MsSeek(xFilial("BQ1")+BB0->BB0_CODIGO))
			While !BQ1->(Eof()) .and. xFilial("BQ1")+BB0->BB0_CODIGO == BQ1->(BQ1_FILIAL+BQ1_CODIGO)
				If aScan(oGet15:aCols,{|x| x[oGet15:PlRetPos("BBF_CODESP")] == BQ1->(BQ1_CODINT+BQ1_CODESP) .and. !x[Len(oGet15:aHeader)+1] }) == 0
					aadd(aDelBQ1,BQ1->(Recno()))
				Endif
				BQ1->(DbSkip())
			Enddo
		Endif
		For nI:=1 to Len(aDelBQ1)
			BQ1->(DbGoTo(aDelBQ1[nI]))

			BQ1->(Reclock("BQ1",.F.))
			BQ1->(DbDelete())
			BQ1->(MsUnlock())
		Next
		For nI:=1 to Len(oGet15:aCols)
			BQ1->(DbSetORder(1))
			If !oGet15:aCols[nI][Len(oGet15:aHeader)+1]
				If !BQ1->(MsSeek(xFilial("BQ1")+BB0->BB0_CODIGO+substr(oGet15:aCols[nI][oGet15:PlRetPos("BBF_CODESP")],5,3)  ))
					BQ1->(Reclock("BQ1",.T.))
					BQ1->BQ1_FILIAL := xFilial("BQ1")
					BQ1->BQ1_CODINT := BB0->BB0_CODOPE
					BQ1->BQ1_CODIGO := BB0->BB0_CODIGO
					BQ1->BQ1_CODESP := substr(oGet15:aCols[nI][oGet15:PlRetPos("BBF_CODESP")],5,3)
					BQ1->BQ1_DESCRI := Posicione("BAQ",1,xFilial("BAQ")+oGet15:aCols[nI][oGet15:PlRetPos("BBF_CODESP")],"BAQ_DESCRI")
					BQ1->(MsUnlock())
				Endif
			Endif
		Next
	Endif
Endif

If nOpc == K_Excluir //5
	BAW->(DBSetOrder(1))
	If BAW->(MsSeek(xFilial("BAW")+M->BAU_CODIGO))
		While !BAW->(EOF()) .And. BAW->(BAW_FILIAL+BAW_CODIGO) == xFilial("BAW")+M->BAU_CODIGO
			BAW->(RecLock("BAW",.F.))
			BAW->(DBDelete())
			BAW->(MSUnlock())
			BAW->(DBSkip())
		Enddo
	Endif

	BAX->(DBSetOrder(1))
	If BAX->(MsSeek(xFilial("BAX")+M->BAU_CODIGO))
		While !BAX->(EOF()) .And. BAX->(BAX_FILIAL+BAX_CODIGO) == xFilial("BAX")+M->BAU_CODIGO
			BAX->(RecLock("BAX",.F.))
			BAX->(DBDelete())
			BAX->(MSUnlock())
			BAX->(DBSkip())
		Enddo
	Endif

	BC0->(DBSetOrder(1))
	If BC0->(MsSeek(xFilial("BC0")+M->BAU_CODIGO))
		While !BC0->(EOF()) .And. BC0->(BC0_FILIAL+BC0_CODIGO) == xFilial("BC0")+M->BAU_CODIGO
			BC0->(RecLock("BC0",.F.))
			BC0->(DBDelete())
			BC0->(MSUnlock())
			BC0->(DBSkip())
		Enddo
	Endif

	BB8->(DBSetOrder(1))
	If BB8->(MsSeek(xFilial("BB8")+M->BAU_CODIGO))
		While !BB8->(EOF()) .And. BB8->(BB8_FILIAL+BB8_CODIGO) == xFilial("BB8")+M->BAU_CODIGO
			BB8->(RecLock("BB8",.F.))
			BB8->(DBDelete())
			BB8->(MSUnlock())
			BB8->(DBSkip())
		Enddo
	Endif

	BC1->(DBSetOrder(1))
	If BC1->(MsSeek(xFilial("BC1")+M->BAU_CODIGO))
		While !BC1->(EOF()) .And. BC1->(BC1_FILIAL+BC1_CODIGO) == xFilial("BC1")+M->BAU_CODIGO
			BC1->(RecLock("BC1",.F.))
			BC1->(DBDelete())
			BC1->(MSUnlock())
			BC1->(DBSkip())
		Enddo
	Endif

	BE6->(DBSetOrder(1))
	If BE6->(MsSeek(xFilial("BE6")+M->BAU_CODIGO))
		While !BE6->(EOF()) .And. BE6->(BE6_FILIAL+BE6_CODIGO) == xFilial("BE6")+M->BAU_CODIGO
			BE6->(RecLock("BE6",.F.))
			BE6->(DBDelete())
			BE6->(MSUnlock())
			BE6->(DBSkip())
		Enddo
	Endif

	BBG->(DBSetOrder(1))
	If BBG->(MsSeek(xFilial("BBG")+M->BAU_CODIGO))
		While !BBG->(EOF()) .And. BBG->(BBG_FILIAL+BBG_CODIGO) == xFilial("BBG")+M->BAU_CODIGO
			BBG->(RecLock("BBG",.F.))
			BBG->(DBDelete())
			BBG->(MSUnlock())
			BBG->(DBSkip())
		Enddo
	Endif

	BBI->(DBSetOrder(1))
	If BBI->(MsSeek(xFilial("BBI")+M->BAU_CODIGO))
		While !BBI->(EOF()) .And. BBI->(BBI_FILIAL+BBI_CODIGO) == xFilial("BBI")+M->BAU_CODIGO
			BBI->(RecLock("BBI",.F.))
			BBI->(DBDelete())
			BBI->(MSUnlock())
			BBI->(DBSkip())
		Enddo
	Endif

	BBK->(DBSetOrder(1))
	If BBK->(MsSeek(xFilial("BBK")+M->BAU_CODIGO))
		While !BBK->(EOF()) .And. BBK->(BBK_FILIAL+BBK_CODIGO) == xFilial("BBK")+M->BAU_CODIGO
			BBK->(RecLock("BBK",.F.))
			BBK->(DBDelete())
			BBK->(MSUnlock())
			BBK->(DBSkip())
		Enddo
	Endif

	BBN->(DBSetOrder(1))
	If BBN->(MsSeek(xFilial("BBN")+M->BAU_CODIGO))
		While !BBN->(EOF()) .And. BBN->(BBN_FILIAL+BBN_CODIGO) == xFilial("BBN")+M->BAU_CODIGO
			BBN->(RecLock("BBN",.F.))
			BBN->(DBDelete())
			BBN->(MSUnlock())
			BBN->(DBSkip())
		Enddo
	Endif

	BE9->(DBSetOrder(1))
	If BE9->(MsSeek(xFilial("BE9")+M->BAU_CODIGO))
		While !BE9->(EOF()) .And. BE9->(BE9_FILIAL+BE9_CODIGO) == xFilial("BE9")+M->BAU_CODIGO
			BE9->(RecLock("BE9",.F.))
			BE9->(DBDelete())
			BE9->(MSUnlock())
			BE9->(DBSkip())
		Enddo
	Endif

	BLK->(DBSetOrder(1))
	If BLK->(MsSeek(xFilial("BLK")+M->BAU_CODIGO))
		While !BLK->(EOF()) .And. BLK->(BLK_FILIAL+BLK_CODIGO) == xFilial("BLK")+M->BAU_CODIGO
			BLK->(RecLock("BLK",.F.))
			BLK->(DBDelete())
			BLK->(MSUnlock())
			BLK->(DBSkip())
		Enddo
	Endif

	BLG->(DBSetOrder(1))
	If BLG->(MsSeek(xFilial("BLG")+M->BAU_CODIGO))
		While !BLG->(EOF()) .And. BLG->(BLG_FILIAL+BLG_CODIGO) == xFilial("BLG")+M->BAU_CODIGO
			BLG->(RecLock("BLG",.F.))
			BLG->(DBDelete())
			BLG->(MSUnlock())
			BLG->(DBSkip())
		Enddo
	Endif

	BLH->(DBSetOrder(1))
	If BLH->(MsSeek(xFilial("BLH")+M->BAU_CODIGO))
		While !BLH->(EOF()) .And. BLH->(BLH_FILIAL+BLH_CODIGO) == xFilial("BLH")+M->BAU_CODIGO
			BLH->(RecLock("BLH",.F.))
			BLH->(DBDelete())
			BLH->(MSUnlock())
			BLH->(DBSkip())
		Enddo
	Endif

	BB0->(DBSetOrder(1))
	If BB0->(MsSeek(xFilial("BB0")+M->BAU_CODBB0))
		If PlsAliasExi("BQ1")
			BQ1->(DbSetORder(1))
			If BQ1->(MsSeek(xFilial("BQ1")+BB0->BB0_CODIGO))
				While BQ1->(MsSeek(xFilial("BQ1")+BB0->BB0_CODIGO))
					BQ1->(RecLock("BQ1",.F.))
					BQ1->(DBDelete())
					BQ1->(MSUnlock())
				Enddo
			Endif
		Endif
		BB0->(RecLock("BB0",.F.))
		BB0->(DBDelete())
		BB0->(MSUnlock())
	Endif

	BTS->(DbSetOrder(1))
	If BTS->(DbSeek(xFilial("BTS")+M->BAU_MATVID))
		BTS->(RecLock("BTS",.F.))
		BTS->(DBDelete())
		BTS->(MSUnlock())
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza para gerar RPS                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->BAU_GERRPS == "1"//Gera RPS
		If 	M->BAP_CONRPS == "1"//Considera RPS
			If BAU->(DbSeek(xFilial("BAU")+M->BAU_CODIGO))
				BAU->(RecLock("BAU",.F.))
				BAU->BAU_ENVRPS := "2"//Excluido
				BAU->(MSUnlock())
			EndIf
		EndIf
	EndIf

  // BTS,e SA2
Endif
If nOpc <> K_Incluir
	BAU->(DbGoTo(nReg))
Endif
BAU->(MsUnLock()) // NC detectado pelo Guilherme na Santa Helena. Verificar

If M->BAU_GERRPS == "1"
	If nOpc == K_Incluir
		aAltZ := {"BAU_NOME", "BAU_CPFCGC", "BAU_RECPRO", "BAU_CLAEST", "BAU_DTINCT", "BAU_DTINSE", "BAU_TIPDIS", "BAU_URGEME", "BAU_TIPDIS" }
		aDefaultZ[1] := M->BAU_CPFCGC
	else
		If Alltrim(BAU->BAU_NOME) <> alltrim(M->BAU_NOME)
			aadd(aAltZ, "BAU_NOME")
		EndIf
		
		If BAU->BAU_CPFCGC <> M->BAU_CPFCGC
			aadd(aAltZ, "BAU_CPFCGC")
			If BAU->BAU_ENVRPS <> "3"
				If nOpc == K_Incluir
					aDefaultZ[1] := M->BAU_CPFCGC
				else
					aDefaultZ[1] := BAU->BAU_CPFCGC
				endIf
			EndIf
		endIf
		
		if BAU->BAU_RECPRO <> M->BAU_RECPRO
			aadd(aAltZ, "BAU_RECPRO")
		EndIf
		
		if BAU->BAU_CLAEST <> M->BAU_CLAEST
			aadd(aAltZ, "BAU_CLAEST")
		EndIf
		
		if BAU->BAU_DTINCT <> M->BAU_DTINCT
			aadd(aAltZ, "BAU_DTINCT")
		EndIf
		
		If BAU->BAU_DTINSE <> M->BAU_DTINSE
			aadd(aAltZ, "BAU_DTINSE")
		endIf
		
		If BAU->BAU_TIPDIS <> M->BAU_TIPDIS
			aadd(aAltZ, "BAU_TIPDIS")
		endIf
		
		If BAU->BAU_URGEME <> M->BAU_URGEME
			aadd(aAltZ, "BAU_URGEME")
		endif
		
		if BAU->BAU_TIPDIS <> M->BAU_TIPDIS
			aadd(aAltZ, "BAU_TIPDIS")
		endIf
		
		if BAU->BAU_ANSOPI <> M->BAU_ANSOPI
			aadd(aAltZ, "BAU_ANSOPI")
		endIf

		if BAU->BAU_CONTRA <> M->BAU_CONTRA
			aadd(aAltZ, "BAU_CONTRA")
		endIf		
		
	endIf
EndIf

BAU->(PLUPTENC("BAU",nOpc,.T.))    // FOLDER 03 - PLANO DE SAUDE

If !(empTy(aAltZ))
	If BAU->BAU_ENVRPS $ " ,0"
		cTpArq := "0"
	elseif BAU->BAU_ENVRPS $ "1,3"
		cTpArq := "1"
		If BAU->BAU_ENVRPS == "1"
			BAU->(RecLock("BAU",.F.))
				BAU->BAU_ENVRPS := "3"
			BAU->(MsUnLock())
		endIf
	endIf
	aB84RPS := buscaB84(BAU->BAU_CODIGO)
	If Len(aB84RPS) > 0
		for nRPSZ := 1 to Len(aB84RPS)
			PLSRPSALT(PLSINTPAD(), BAU->(Recno()), 0, aB84RPS[nRPSZ], aAltZ, cTpArq, aDefaultZ, /*aIncLoc*/, /*ldestroy*/, /*lExclRda*/, .T.)
		next
	else
		PLSRPSALT(PLSINTPAD(), BAU->(Recno()), 0, 0, aAltZ, cTpArq, aDefaultZ)
	endIf
endIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CargaCols   ³ Autor ³ Eduardo Motta       ³ Data ³ 08.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a carga no aCols/aHeader/aVetTrab do alias          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CargaCols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CargaCols(cAlias,aVetTrab,nOpc,cCampo,cMacro,cChave)

LOCAL lSalv 	:= Inclui

DEFAULT cCampo 	:= "CODIGO"
DEFAULT cMacro	:= "1=1"
DEFAULT cChave	:= BAU->BAU_CODIGO

aHeader := {}
aCols   := {}

Store Header cAlias TO aHeader For .T.
If nOpc == K_Incluir
	Inclui 	:= .T.
	n 		:= 1
	Store COLS Blank cAlias TO aCols FROM aHeader
Else
	DbSelectArea(cAlias)
	DbSetOrder(1)
	If MsSeek(xFilial(cAlias)+cChave)
		Store COLS cAlias TO aCols FROM aHeader VETTRAB aVetTrab While xFilial(cAlias) == &(cAlias+"->"+PrefixoCpo(cAlias)+"_FILIAL") .And. BAU->BAU_CODIGO == AllTrim( &(cAlias+"->"+PrefixoCpo(cAlias)+"_"+cCampo) ) .And. &cMacro
	Else
		n 		:= 1
		Inclui 	:= .T.
		Store COLS Blank cAlias TO aCols FROM aHeader
		Inclui 	:= lSalv
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA360BLO ³ Autor ³ Michele Tatagiba    ³ Data ³ 29.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Bloquear/Desbloquear Rede de Atendimento                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA360Blo(cAlias,nReg,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis usadas na rotina...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local I__f := 0
LOCAL cTitulo := __cNameBAU
LOCAL nOpca   := 0
LOCAL nOrdBAU := BAU->(IndexOrd())
LOCAL nRecBAU := BAU->(Recno())
LOCAL aButtons := {}
LOCAL aPosObj   := {}
LOCAL aObjects  := {}
LOCAL aSize     := {}
LOCAL aInfo     := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel utilizada na validação do bloqueio da operadora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cAcao			:= ""
Local cPLRDAD 		:=  alltrim(GetMv("MV_PLRDAD",,.F.))
LOCAL lUnimeds    	:= IF(AllTrim(GETNEWPAR("MV_PLSUNI","0"))=="1",.T.,.F.)
LOCAL lInfSubst   	:= .F.
LOCAL lSlvInclui  	:= iif(type("inclui")=="l",inclui, .t. ) 
LOCAL lGrvRPS		:= SuperGetMV("MV_PLSRPSE",,.F.)

LOCAL bOK     := {|| nOpca := 1 , If( A360CHKREG(M->BC4_CODCRE+M->BC4_TIPO+DTOS(M->BC4_DATA)+M->BC4_HORA) , oDlgBlo:End(),nOpca:=2 ) , If( nOpca==1,oDlgBlo:End(),.F. ) } 
LOCAL bCancel := {|| oDlgBlo:End() } 

Local lLoteRPS	:= .F.
Local ntpCab	:= 0
Local cTpcab	:= " "

PRIVATE lBloq
PRIVATE oEncBlo
PRIVATE oDlgBlo
PRIVATE nOpcx   := nOpc
PRIVATE cTipo
PRIVATE aGets[0]
PRIVATE aTela[0][0]
PRIVATE cCodCre := BAU->BAU_CODIGO
PRIVATE aCampos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define controle para saber bloqueio/desbloqueio                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lBloq   := !Empty(BAU->BAU_CODBLO)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 100, .t., .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlgBlo TITLE cTitulo FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define entrada de dados padrao...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Copy "BC4" TO Memory Blank
INCLUI := .T. //por conta dos ajustes realizados no bloqueio, houve uma alteração no when dos campos para considerar o inclui
If  FindFunction("A360HISBLO")
	aadd(aButtons,{"HISTORIC",{|| A360HISBLO() },OemtoAnsi(STR0021),OemtoAnsi(STR0036)}) //"Historico de (Des)bloqueio"
Endif

oEncBlo := MSMGet():New("BC4",BC4->(Recno()),K_Incluir,,,,nil,{aPosObj[1][1],aPosObj[1][2],aPosObj[1][4],aPosObj[1][3]},nil,,,,,oDlgBlo,,,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define valores para os campos chave da familia...                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BAU->(DbSetOrder(nOrdBAU))
BAU->(DbGoTo(nRecBAU))

M->BC4_CODCRE := BAU->BAU_CODIGO
M->BC4_NOMCRE := BAU->BAU_NOME
M->BC4_DESBLO := ""
M->BC4_TIPO   := If(lBloq,"1","0")

lRefresh       := .T.

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa dialogo...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgBlo ON INIT Eval({ || EnchoiceBar(oDlgBlo, bOK , bCancel ,.F.,aButtons) })

INCLUI := lSlvInclui //retorno o INCLUI ao que era antes para não dar problema na rotina
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para gravacao caso houve confirmacao de bloqueio         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK

	PLUPTENC("BC4",K_Incluir)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama integracao com o HAT                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetNewPar("MV_PLSHAT","0") == "1"  
		if M->BC4_TIPO == "0" //Bloqueio 
			cCodTra := _healthProviderStatus_desblo
			BNV->(DbSetOrder(2))//BNV_FILIAL+BNV_CODTRA+BNV_ALIAS+BNV_CHAVE
			//Verifico se ja tem desbloqueio nao enviado, se tiver, excluo
			if BNV->(MsSeek(xFilial("BNV")+cCodTra+"BC4"+M->BC4_CODCRE+"1"+Dtos(M->BC4_DATA))) .And. BNV->BNV_STATUS == HAT_PENDENTE_ENVIO
				PLS274GRV( K_Excluir )
			else
				PLHATPedPD(K_Incluir,_healthProviderStatus_blo,'BC4',M->(BC4_CODCRE+BC4_TIPO)+Dtos(M->BC4_DATA)+M->BC4_HORA,nil,2)
			endIf	
		
		elseIf M->BC4_TIPO == "1" //Desbloqueio 
			cCodTra := _healthProviderStatus_blo
			BNV->(DbSetOrder(2))//BNV_FILIAL+BNV_CODTRA+BNV_ALIAS+BNV_CHAVE
			//Verifico se ja tem bloqueio nao enviado, se tiver, excluo
			if BNV->(MsSeek(xFilial("BNV")+cCodTra+"BC4"+M->BC4_CODCRE+"0"+Dtos(M->BC4_DATA))) .And. BNV->BNV_STATUS == HAT_PENDENTE_ENVIO
				PLS274GRV( K_Excluir )
			else
				PLHATPedPD(K_Incluir,_healthProviderStatus_desblo,'BC4',M->(BC4_CODCRE+BC4_TIPO)+Dtos(M->BC4_DATA)+M->BC4_HORA,nil,2)
			endIf		
		endIf
	EndIf
	
    // Tratar indicação de Prestador Substituto	
	If M->BC4_TIPO == "0"
		
		If lUnimeds // Tratar Prestador Substituto PTUA400
			If MsgYesNo( STR0055, STR0056 ) //"Deseja Informar um prestador Substituto para PTUA400 R406?"
				lInfSubst := InfPresSub(.f., M->BC4_DATA)
			EndIf
		else //adicionado para quando o usuário não tiver com o parâmetro MV_PLSUNI == "1"
			If M->BC4_MOTIVO == '0'
				If MsgYesNo( STR0088, STR0056 ) //"Deseja informar um prestador substituto?" #"Prestador Substituto"
					lInfSubst := InfPresSub(.f., M->BC4_DATA)
				endIf
			Else 
				lInfSubst	:= .T.  // lInfSubst recebe .T. pois não é necessário informar um substituto para uma suspensão temporaria
			EndIf
		EndIf
		If !lInfSubst .and. BAU->BAU_TIPPRE <> 'HOS'
			MsgInfo(STR0067)//"Não foi informado um prestador substituto, é necessário informar o Motivo de Exclusão."
			PLSPRESU()
		Endif
	Else
		If !Empty(BAU->BAU_RDASUB)
			BAU->(RecLock("BAU",.F.))
			BAU->BAU_RDASUB := " "
			BAU->(MsUnLock())
		Endif
		If !Empty(BAU->BAU_EXCEDI)
			BAU->(RecLock("BAU",.F.))
			BAU->BAU_EXCEDI := " "
			BAU->(MsUnLock())
		EndIf		
		B7O->(DbSetOrder(1))
		If B7O->(DbSeek(xFilial("B7O")+BAU->BAU_CODIGO))
			While B7O->(B7O_FILIAL+B7O_CODRDA) == xFilial("B7O")+BAU->BAU_CODIGO .And. !B7O->(Eof())
				B7O->(Reclock("B7O",.F.))
				B7O->(DbDelete())
				B7O->(MsUnlock())
        		
				B7O->(DbSkip())
			EndDo
		EndIf		
	Endif
	
	If ! lBloq
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ4¿
		//³Tipo de bloqueio para integração com GRC³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ4Ù

		If Empty(cPLRDAD)
			cAcao := "4"
		Else
			If M->BC4_MOTBLO = cPLRDAD
				cAcao := "5"
			Else
				cAcao := "4"
			EndIf
		Endif

		BAU->(RecLock("BAU",.F.))		
		if M->BC4_MOTSUB == '05'
			BAU->BAU_OBSGUI := M->BC4_OBS
		endif
		//Atualiza para gerar RPS
		If BAU->BAU_GERRPS == "1"//Gera RPS
			If 	BAP->BAP_CONRPS == "1"//Considera RPS
				If lGrvRPS
					If BAU->BAU_ENVRPS $ "1,3"
						BAU->BAU_ENVRPS := "4"//Altera para enviar Exclusão
						lLoteRPS := .T.
					elseif BAU->BAU_ENVRPS $ " ,0"
						BAU->BAU_ENVRPS := "2"//Altera para EXCLUIDO
					EndIf
				Endif
			EndIf
		EndIf

		BAU->BAU_CODBLO := M->BC4_MOTBLO
		BAU->BAU_DATBLO := M->BC4_DATA
		BAU->BAU_AOINT 	:= "N"
		BAU->BAU_ACAO	:= cAcao
			
		BAU->(MsUnLock())
		
		If lLoteRPS
			PLSRPSALT(PLSINTPAD(), BAU->(Recno()), 0, 0, {"BAU_NOME", "BAU_RECPRO", "BAU_CLAEST", "BAU_DTINCT", "BAU_DTINSE", "BAU_TIPDIS", "BAU_URGEME", "BAU_TIPDIS", "BAU_ANSOPI", "BAU_CONTRA" }, "3", { "DEFAULT", "DEFAULT", "DEFAULT" },{},.f.,.t.)
		endIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ4¿
		//³Atualizando Status das operadoras para integração com o GRC³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ4Ù
		DbSelectArea("BAW")
		DbSetOrder(1)
		DbSetFilter({|| BAW_CODIGO = BAU->BAU_CODIGO},"")
		BAW->(DbGoTop())
		While !BAW->(Eof()) .And. BAW_FILIAL = xFilial("BAW")
			BAW->(RecLock("BAW",.F.))
			BAW->BAW_AOINT := "N"
			BAW->BAW_ACAO  := cAcao
			BAW->(MsUnlock())
			BAW->(DbSkip())
		End
		
		// Verifica se é cooperado e possui matricula de funcionario
		If !Empty(BAU->BAU_MATFUN) .And. AllTrim(BAU->BAU_COPCRE) == "1" // Cooperado
			Aviso( "e-Social","Para envio de bloqueio o funcionário " + AllTrim(Posicione("SRA",1,BAU->BAU_FILFUN+BAU->BAU_MATFUN,"RA_NOME")) +  " deve ser bloqueado no Módulo Gestão de Pessoal" ,{ "Ok" }, 2 )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para o bloqueio...                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("PLS360BLQ")
			ExecBlock("PLS360BLQ",.F.,.F.,{nOpc})
		Endif
	Else
		BAU->(RecLock("BAU",.F.))
		BAU->BAU_CODBLO := ""
		BAU->BAU_DATBLO := ctod("")
		BAU->BAU_AOINT 	:= "N"
		BAU->BAU_ACAO	:= "4"
		If BAP->BAP_CONRPS == "1"//Considera RPS
			If BAU->BAU_ENVRPS == "4"
				BAU->BAU_ENVRPS := "1"
				B5B->(DbSetOrder(1))
				For ntpCab := 1 To 4
					If ntpCab > 1
						ctpCab := Alltrim(str(ntpCab - 2))
					endIf
					if PLSRPSCHK("3", PLSINTPAD(), ctpCab)
						//Se tem registro em lote em aberto, deleta o registro
						If B5B->(MsSeek(xfilial("B5B") + PLSINTPAD() + B4K->B4K_NUMLOT + BAU->BAU_CODIGO))
							B5B->(recLock("B5B", .F.))
								B5B->(dbdelete())
							B5B->(MsUnLock())
							//Se depois de deletar o registro, não tiver mais nada no lote, deleta o lote também
							If !(B5B->(MsSeek(xfilial("B5B") + PLSINTPAD() + B4K->B4K_NUMLOT)))
								B4K->(recLock("B4K", .F.))
									B4K->(dbDelete())
								B4K->(MsUnLock())
							EndIf
							EXIT
						endIf
					endIf
				Next
				lLoteRPS := .F.
			elseif lGrvRPS .AND. BAU->BAU_ENVRPS == "2"
				BAU->BAU_ENVRPS := "0"//Altera para não enviado
				lLoteRPS := .T.
			Endif
		Endif
		BAU->(MsUnLock())
		
		If lLoteRPS
			PRPS5ZZZ(BAU->(recno()))
		endIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ4¿
		//³Atualizando Status das operadoras para integração com o GRC³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ4Ù
		DbSelectArea("BAW")
		DbSetOrder(1)
		DbSetFilter({||BAW_CODIGO = BAU->BAU_CODIGO},"")
		BAW->(DbGoTop())
		While !BAW->(Eof()) .And. BAW_FILIAL = xFilial("BAW")
			BAW->(RecLock("BAW",.F.))
			BAW->BAW_AOINT := "N"
			BAW->BAW_ACAO  := "4"
			BAW->(MsUnlock())
			DbSkip()
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para o desbloqueio...                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("PLS360DSBLQ")
			ExecBlock("PLS360DSBLQ",.F.,.F.,{nOpc})
		Endif
	Endif

	BAU->(DbCommitAll())

	BAU->(DbSetOrder(nOrdBAU))
	BAU->(DbGoTo(nRecBAU))

Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLS360VLDT  ³ Autor ³ Michele Tatagiba    ³ Data ³ 29.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a data de desbloqueio do credenciado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS360VLDT()

LOCAL nRecBAU := BAU->(Recno())
LOCAL nOrdBAU := BAU->(IndexOrd())
LOCAL lRet    := .T.

If M->BC4_TIPO == "1"
	If BAU->BAU_DATBLO > M->BC4_DATA
		//A data de bloqueio e menor do que a desbloqueio
		Help("",1,"PLSA360BLD")
		lRet := .F.
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados salvados...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BAU->(DbSetOrder(nOrdBAU))
BAU->(DbGoTo(nRecBAU))

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA360CON  ³ Autor ³ Michele Tatagiba    ³ Data ³ 10.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o CGC/CPF da Rede de Atendimento                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA360CON(nTipo)

LOCAL nRecBAU := BAU->(Recno())
LOCAL nOrdBAU := BAU->(IndexOrd())
LOCAL cCampo
LOCAL cAlias1 := ""
LOCAL cAlias2 := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nTipo == 1 ; a validacao esta no CPF                                          ³
//³ nTipo == 2 ; a validacao esta ou no Numero do CR, Estado CR ou Sigla CR       ³
//³ nTipo == 3 ; a validacao esta ou no Numero2 do CR, Estado2 CR ou Sigla2 CR    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1 .And. ! Empty(M->BAU_CPFCGC)
	SA2->(DBSetOrder(3))
	If SA2->(MsSeek(xFilial("SA2")+M->BAU_CPFCGC))
		cAlias1 := "SA2"
		cAlias2 := "BAU"
	Endif
Endif

If nTipo == 2 .And. ! Empty(M->BAU_ESTCR) .And. ! Empty(M->BAU_SIGLCR) .And. ! Empty(M->BAU_CONREG)
	BB0->(DBSetOrder(4))
	If BB0->(MsSeek(xFilial("BB0")+M->(BAU_ESTCR+BAU_SIGLCR+BAU_CONREG)))
		cAlias1 := "BB0"
		cAlias2 := "BAU"
	Endif
Endif

If nTipo == 3 .And. ! Empty(M->BAU_ESTCR2) .And. ! Empty(M->BAU_SIGCR2) .And. ! Empty(M->BAU_CONRE2)
	BB0->(DBSetOrder(4))
	If BB0->(MsSeek(xFilial("BB0")+M->(BAU_ESTCR2+BAU_SIGCR2+BAU_CONRE2)))
		cAlias1 := "BB0"
		cAlias2 := "BAU"
	Endif
Endif

BBL->(DbSetOrder(2))
BBL->(MsSeek(xFilial()+"PLSA360   "+cAlias1+cAlias2))
While !BBL->(Eof()) .and. "PLSA360   " == BBL->BBL_PROGRA .and. BBL->BBL_ALIAS1 == cAlias1 .and. BBL->BBL_ALIAS2 == cAlias2
	cCampo := BBL->BBL_CAMPO2
	&("M->"+AllTrim(BBL->BBL_CAMPO2)) := &(BBL->BBL_ALIAS1+"->"+AllTrim(BBL->BBL_CAMPO1))
	BBL->(DbSkip())
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados salvados...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BAU->(DbSetOrder(nOrdBAU))
BAU->(DbGoTo(nRecBAU))

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA360   ºAutor  ³Microsiga           º Data ³  03/23/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLS365VUSU(cSenha)

LOCAL aUsers  := AllUsers(.T.)
LOCAL lRet    := .F.
LOCAL cCodUsr := ""
LOCAL cNomUsr := ""

cCodUsr       := aUsers[nPosScan,1,1]
cNomUsr       := aUsers[nPosScan,1,2]
lRet          := .T.

Return({lRet,cCodUsr,cNomUsr})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA360   ºAutor  ³Microsiga           º Data ³  03/23/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLS360ESP()

BAG->(DBSetOrder(1))
If BAG->(MsSeek(xFilial("BAG")+M->BAU_TIPPRE))
   nQtdEsp := BAG->BAG_QTDESP
Endif

Return(M->BAU_TIPPRE)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA360   ºAutor  ³Microsiga           º Data ³  03/23/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSBBFVLD()

LOCAL lRet := .T.

If oGet15:nOpcx == 3
	If nQtdLinha >= nQtdEsp
		MsgInfo(OemtoAnsi(STR0013)+AllTrim(Str(nQtdEsp,4))+".") //"O maximo de especialidades permitidas e "
		lRet := .F.
	Else
		nQtdLinha++
	Endif
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA360   ºAutor  ³Microsiga           º Data ³  03/23/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSBBFDEL()

LOCAL nPosScan := 0
LOCAL nTamCols := 0
LOCAL lRet     := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se pode alterar ou excluir											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !PlsChkAE()
   Return(.F.)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ascan																³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosScan := aScan(aVetBBF,{|x| x[1] == oGet15:aCols[oGet15:Linha(),oGet15:PlRetPos("BBF_CODESP")] })

If oGet15:aCols[oGet15:Linha(),Len(oGet15:aHeader)+1]
	If nPosScan == 0
		nQtdLinha--
		aadd(aVetBBF,{oGet15:aCols[oGet15:Linha(),oGet15:PlRetPos("BBF_CODESP")]})
	Endif
Else
	If nPosScan <> 0
		If nQtdLinha >= nQtdEsp
			MsgInfo(OemtoAnsi(STR0013) + AllTrim(Str(nQtdEsp,4))+".") //"O maximo de especialidades permitidas e "
			oGet15:aCols[oGet15:Linha(),Len(oGet15:aHeader)+1] := .T.
			lRet := .F.
		Else
			nTamCols := Len(aVetBBF)
			aDel(aVetBBF,nPosScan)
			aSize(aVetBBF,nTamCols-1)
			nQtdLinha ++
		Endif
	Endif
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma    ³PLSA360INSS ºAutor  ³Microsiga           º Data ³  12/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.       ³ Faz consistencia no numero do INSS da RDA.                   º±±
±±º            ³                                 		                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    	   ³ AP                             	                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS360INSS()

cDigito := Modulo11(Left(M->BAU_INSS,10))

If cDigito <> Substr(M->BAU_INSS,11,1)
	MsgStop(OemtoAnsi(STR0022)) //"INSS Invalido! Digito verificar incorreto!"
	Return(.F.)
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetSA2Cod ºAutor  ³Geraldo Felix Jr.   º Data ³  27-01-04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Geraldo Felix Junior.                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GetSA2Cod()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca parametros para codigo e loja do fornecedor    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cA2CD := alltrim(GetNewPar("MV_PLSA2CD",""))
cA2LJ := alltrim(GetNewPar("MV_PLSA2LJ",""))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica como determinar codigo e loja do fornecedor ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ! empty(cA2CD)
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Executa sintaxe para codigo e loja do fornecedor conforme ³
    //³ conteudo dos parametros                                   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodFor := &(cA2CD)
	cLojFor := &(cA2LJ)
Else
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Monta codigo e loja conforme SX3 - tamanho e              ³
    //³ inicializador padrao                                      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodFor := CriaVar("A2_COD")
	cLojFor := CriaVar("A2_LOJA")
	nTamCod := posicione("SX3",2,"A2_COD   ","X3_TAMANHO")
	nTamLoj := posicione("SX3",2,"A2_LOJA  ","X3_TAMANHO")
	If  empty(cLojFor)
		cLojFor := strzero(1,nTamLoj)
	Endif
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Caso codigo nao tenha inicializador padrao,               ³
    //³ busca proximo sequencial                                  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  empty(cCodFor)
		SA2->(dbSetorder(1))
		SA2->(dbGobottom())
		SA2->(dbSkip(-1))    // ??? falta tratar compartilhado/exclusivo
		If  SA2->(Eof()) .or. (SA2->(RecCount()) == 0)
			cCodFor := StrZero(1,nTamCod)
		Else
			cCodFor := StrZero(Val(SA2->A2_COD)+1,nTamCod)
		Endif
		While .T.
			If  SA2->(MsSeek(xFilial("SA2")+cCodFor+cLojFor))
				cCodFor := StrZero(Val(cCodFor)+1,nTamCod)
				Loop
			Else
				Exit
			Endif
		Enddo
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da funcao                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return({cCodFor,cLojFor})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA360   ºAutor  ³Microsiga           º Data ³  03/23/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PL360CRM()

Local lRet    := .T.

cSql := "SELECT * FROM " + RetSqlName("BB0") + " "
cSql += "WHERE BB0_FILIAL = '" + xFilial("BB0")  + "' AND "
cSql += "      BB0_ESTADO = '" + M->BAU_ESTCR    + "' AND "
cSql += "      BB0_NUMCR  = '" + M->BAU_CONREG   + "' AND "
cSql += "      BB0_CODSIG = '" + M->BAU_SIGLCR   + "' AND "
If  ! empty(M->BAU_CODBB0)
	cSql += "  BB0_CODIGO <> '" + M->BAU_CODBB0 + "' AND "
Endif
cSql += "      D_E_L_E_T_ = ' ' "
PlsQuery(cSql, "BB0TRB")
If  ! BB0TRB->(EOF())
	cSql := "SELECT * FROM " + RetSqlName("BAU") + " "
	cSql += "WHERE BAU_FILIAL =  '" + xFilial("BAU")     + "' AND "
	cSql += "      BAU_CODBB0 =  '" + BB0TRB->BB0_CODIGO + "' AND "
	cSql += "      BAU_CODBB0 <> '" + M->BAU_CODIGO      + "' AND "
	cSql += "      D_E_L_E_T_ = ' ' "
	PlsQuery(cSql, "BAUTRB")
	If  ! BAUTRB->(EOF())
		msgalert(OemtoAnsi(STR0023)) //"Ja existe um Profissional de Saude com este codigo"
		lRet := .F.
	Endif
	BAUTRB->(DbCloseArea())
Endif
BB0TRB->(DbCloseArea())

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA360Del ³ Autor ³ Thiago Machado Correa ³ Data ³ 22.10.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de exclusao de registro na RDA                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA360Del(nOpc)

LOCAL lRet		:= .T.
LOCAL aChaves 	:= {}

If  nOpc # K_Excluir
	Return .T.
Endif

aadd(aChaves,{"BA0","BA0_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BBJ","BBJ_CRENOV",BAU->BAU_CODIGO})
aadd(aChaves,{"BBQ","BBQ_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BC5","BC5_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BC6","BC6_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BCI","BCI_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BD5","BD5_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BD6","BD6_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BD7","BD7_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BDJ","BDJ_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BDP","BDP_RDADE ",BAU->BAU_CODIGO})
aadd(aChaves,{"BDP","BDP_RDAATE",BAU->BAU_CODIGO})
aadd(aChaves,{"BE2","BE2_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BE4","BE4_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BEA","BEA_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BEF","BEF_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BEH","BEH_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BEI","BEI_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BEM","BEM_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BEQ","BEQ_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BHY","BHY_CODSOL",BAU->BAU_CODIGO})
aadd(aChaves,{"BLY","BLY_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BLZ","BLZ_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BMH","BMH_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BMI","BMI_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BMR","BMR_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BMS","BMS_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BMW","BMW_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BN4","BN4_RDADE ",BAU->BAU_CODIGO})
aadd(aChaves,{"BN4","BN4_RDAATE",BAU->BAU_CODIGO})
aadd(aChaves,{"BQJ","BQJ_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BQK","BQK_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BQM","BQM_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BQN","BQN_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BQO","BQO_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BSZ","BSZ_RDA   ",BAU->BAU_CODIGO})
aadd(aChaves,{"BTV","BTV_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BVX","BVX_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BXE","BXE_CODRDA",BAU->BAU_CODIGO})
aadd(aChaves,{"BYJ","BYJ_RDADE ",BAU->BAU_CODIGO})
aadd(aChaves,{"BYJ","BYJ_RDAATE",BAU->BAU_CODIGO})
aadd(aChaves,{"BYQ","BYQ_RDA   ",BAU->BAU_CODIGO})
aadd(aChaves,{"BCK","BCK_CODIGO",BAU->BAU_CODIGO})
aadd(aChaves,{"BDN","BDN_CODIGO",BAU->BAU_CODIGO})
aadd(aChaves,{"BHU","BHU_CODIGO",BAU->BAU_CODIGO})
aadd(aChaves,{"BIN","BIN_CODIGO",BAU->BAU_CODIGO})
aadd(aChaves,{"BPI","BPI_CODIGO",BAU->BAU_CODIGO})
aadd(aChaves,{"BZA","BZA_CODIGO",BAU->BAU_CODIGO})
aadd(aChaves,{"BZB","BZB_CODIGO",BAU->BAU_CODIGO})
aadd(aChaves,{"BN9","BN9_CODIGO",BAU->BAU_CODIGO})
aadd(aChaves,{"BNG","BNG_CODIGO",BAU->BAU_CODIGO})
aadd(aChaves,{"BNM","BNM_CODIGO",BAU->BAU_CODIGO})
aadd(aChaves,{"BNO","BNO_CODIGO",BAU->BAU_CODIGO})

lRet := PLSCHKDEL(aChaves)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL360LOCCRP ºAutor  ³Geraldo Felix Juniorº Data ³  02/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do campo BB8_CRPLOC...                             º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                       	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL360LOCCRP(oObj)

LOCAL nCnt
LOCAL lRet := .F.
LOCAL nBB8_LOCAL    := oObj:FieldPos("BB8_LOCAL")

For nCnt := 1 To Len(oObj:aCols)
		// Nao pode comparar com o conteudo da propria linha...
	If oObj:aCols[nCnt][nBB8_LOCAL] <> M->BB8_LOCAL
			// Compara conteudo das linhas do acols com o campo digitado...
		If oObj:aCols[nCnt][nBB8_LOCAL] == M->BB8_CRPLOC
			lRet := .T.
			Exit
		Endif
	Endif
Next
If !lRet
	MsgAlert(OemtoAnsi(STR0024)) //"Local de atendimento invalido. Selecione um local de atendimento existente neste browse!"
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL360IPAD ºAutor  ³Geraldo felix juniorº Data ³  12/21/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inidicializadores padroes para campos complexos, 		  º±±
±±º          ³ nao sendo possivel ficar no X3_RELACAO mpo                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL360IPAD(cVar, cTipo)
Local cRet

If cTipo == 'N'
	cRet := 0
Elseif cTipo == 'C'
	cRet := ''
Elseif cTipo == 'D'
	cRet := cTod('')
Elseif cTipo == 'L'
	cRet := .T.
Elseif cTipo == 'M'
	cRet := ''
Endif
If Inclui
	cRet := ""
Else
	If cVar == "BAX_DESESP"
		If Type('oGet03') == 'U'
			cRet := Posicione("BAQ",1,xFilial("BAQ")+BAX->(BAX_CODINT+BAX_CODESP),"BAQ_DESCRI")
		Else
			If !Empty(oGet03:FieldGet("BAX_CODESP",1))
				cRet := Posicione("BAQ",1,xFilial("BAQ")+oGet03:FieldGet("BAX_CODESP",1),"BAQ_DESCRI")
			Else
				cRet := ''
			Endif
		Endif
	Endif
Endif

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA360LEG ³ Autor ³Daher		 		³ Data ³ 21.01.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe a legenda...                                         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA360LEG()

BrwLegenda(cCadastro,"Status" ,aCdCores)

Return

/*/{Protheus.doc} A360CHEBLO
Verifica se o Prestador esta bloqueado na data informada.
@type function
@author Alexander
@since 07/06/05
@version 1.0
@param cCodCre   , caracter , Codigo do prestador
@param dData     , data     , Data da checagem de bloqueio
@param lRpc      , boolean  , Informa se eh oriundo do portal ou rotinas automaticas
@param cHora     , caracter , Hora da checagem de bloqueio (HHMM)
@param lVldBlPor , boolean  , se deve considerar a data de bloqueio do portal
@param aDadProrro, array    , quando for validar uma prorrogação que a internação foi antes do bloqueio 
@return lRet, Retorna Falso se o Prestador esta bloqueado na data/hora informada
/*/
function A360CHEBLO(cCodCre,dData,lRpc,cHora,lVldBlPor,aDadProrro)
	local lRet    	  := .T.
	local lBloq   	  := .F.
	local nQtdDBlo 	  := GetNewPar("MV_PLSDBLO",0) //Indica qtde de dias apos o bloqueio p/ liberar RDA
	local cAliBlo	  := ""
	local cAliDes	:= ""
	local cData 	  := ""
	local aVgDatBlo   := {}
	local i 			:=0
	Local lExisteDesblo := .F.		
	Local cSql := ""
	
	default lRpc 	  := .F.
	default cHora	  := Time()
	default lVldBlPor := .F.
	default aDadProrro := {}
	
	dData += nQtdDBlo
	cData := DTOS(dData)
	
//Caso for informada, a consulta deve considerar a Hora
	if !Empty(cHora)
		cHora := StrTran(cHora,":","")
		cHora := SubStr(cHora,1,4)
	endif

	cAliBlo := GetNextAlias()

	csql := " SELECT BC4_DATA, BC4_HORA, BC4_TIPO, BC4_DTBLQ FROM " + retSqlName("BC4") + " BC4 "
	csql += " WHERE BC4_FILIAL = '" + xfilial("BC4") + "' "
	csql += "	AND BC4_CODCRE  = '" + cCodCre + "' "
	csql += "	AND BC4.D_E_L_E_T_ =  ' ' "
	csql += "	ORDER BY BC4_DATA, BC4_HORA	, BC4_TIPO "
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,csql),cAliBlo,.F.,.T.)
	
	If !(cAliBlo)->(Eof())
		
		While !(cAliBlo)->(Eof())
			
			//separa os registros entre bloqueio e desbloqueio. Caso exista bloqueio sem registro de desbloqueio correspondente,
			//valores padrões são inseridos nas posições correspondente ao desbloqueio. Considerando que a validação 
			//caiu no registro que é só de bloqueio o sistema considera que está bloqueado sem data de desbloqueio utilizadando os
			//valores padrões de desbloqueio que nunca serão atendidas.
			If (cAliBlo)->(BC4_TIPO) == "0"
			
				If Len(aVgDatBlo)> 0
					For i := 1 to Len(aVgDatBlo)
						If Empty(aVgDatBlo[i,1])
							aVgDatBlo[i,1]:= (cAliBlo)->(BC4_DATA) /*Data de desbloqueio*/
							aVgDatBlo[i,2]:= Substr(StrTran((cAliBlo)->(BC4_HORA),":","")+"0",1,4) /*Data de desbloqueio*/
							lExisteDesblo := .T.
							exit
						Endif
					Next i
				Endif
				
				If !lExisteDesblo  
								
					AADD(aVgDatBlo, {(cAliBlo)->(BC4_DATA)    /*data bloqueio*/    , Substr(StrTran((cAliBlo)->(BC4_HORA),":","")+"0",1,4)/*hora bloqueio*/    ,;
						             Space(LEN(DTOS(YEARSUM(dData, 1)))) /*Data desbloqueio*/ , ""               /*hora desbloqueio*/,;
						            (cAliBlo)->(BC4_DTBLQ)   /*Data desbloqueio do portal*/})
				Endif		            
			Else

				If Len(aVgDatBlo)> 0
					For i := 1 to Len(aVgDatBlo)
						If Empty(aVgDatBlo[i,3])
							aVgDatBlo[i,3]:= (cAliBlo)->(BC4_DATA) /*Data de desbloqueio*/
							aVgDatBlo[i,4]:= Substr(StrTran((cAliBlo)->(BC4_HORA),":","")+"0",1,4) /*Data de desbloqueio*/
							lExisteDesblo := .T.
							exit
						Endif
					Next i
				Endif
				
				If !lExisteDesblo
				
					AADD(aVgDatBlo, {''    /*data bloqueio*/    , ''/*hora bloqueio*/    ,;
						             (cAliBlo)->(BC4_DATA) /*Data desbloqueio*/ , Substr(StrTran((cAliBlo)->(BC4_HORA),":","")+"0",1,4)              /*hora desbloqueio*/,;
						            (cAliBlo)->(BC4_DTBLQ)   /*Data desbloqueio do portal*/})
				Endif
			EndIf
			lExisteDesblo:= .F.
			 
			(cAliBlo)->(dbSkip())
		EndDo
	EndIf
	
	
	If Len(aVgDatBlo)> 0 // Apos varrer os itens verifico de ha algum item desbloqueado em branco  
		For i := 1 to Len(aVgDatBlo)
			If Empty(aVgDatBlo[i,3])
				aVgDatBlo[i,3]:= Dtos(YearSum(cTod(Substr(aVgDatBlo[i,1],Len(aVgDatBlo[i,1])-1,2)+"/"+Substr(aVgDatBlo[i,1],Len(aVgDatBlo[i,1])-3,2)+"/"+Substr(aVgDatBlo[i,1],Len(aVgDatBlo[i,1])-8,4)),1)) /*Data de desbloqueio*/
				aVgDatBlo[i,4]:="2359"
			Endif
		Next i
	Endif
	
	
	If !lVldBlPor /* se deve considerar a data de bloqueio do portal.*/
		
		//Se encontrar o range de datas inferior e superior a data que consta no cData, não precisa verificar hora.
		If Ascan(aVgDatBlo,{|x|	cData > Alltrim(x[1]) .AND. ;	//Data de bloqueio
							cData < Alltrim(x[3]) }) > 0	//Data de desbloqueio
			               		
			lBloq := .T.
		
		//Se encontrar o range de datas onde a data de bloqueio é igual a data do cData ou a data do desbloqueio é igual ao cData,
		//verifica a hora para definir se o prestador está bloqueado ou desbloqueado. 
		ElseIf Ascan(aVgDatBlo,{|x|	StoD(cData) >= StoD(Alltrim(x[1])) .AND.	;		//Data de bloqueio
								 Val(cHora) >=  Val(Alltrim(x[2]))		;		//hora de bloqueio
								.AND.  ;
								StoD(cData) <= StoD(Alltrim(x[3])) .AND. 	;		//Data de desbloqueio 
								 Val(cHora) <=  Val(Alltrim(x[4])) }) > 0			//hora de desbloqueio
			
			lBloq := .T.
		EndIf
		
	Else
		
		//Considera a data de desbloqueio do portal, está parte é utilizada para validar o acesso ao portal.
		If Ascan(aVgDatBlo,{|x|	Alltrim(x[1]) < cData .AND. ;		//Data de bloqueio
							Alltrim(x[3]) > cData .AND. ;		//Data de desbloqueio
			         			    Alltrim(x[5]) <  cData}) > 0
			lBloq := .T.
		
		ElseIf Ascan(aVgDatBlo,{|x|	cData >= Alltrim(x[1]) .AND. ;		//Data de bloqueio
								cHora >= Alltrim(x[2]) .AND. ;		//hora de bloqueio
								cData >  Alltrim(x[5])       ;
								.AND.;
								cData <= Alltrim(x[3]) .AND. ;		//Data de desbloqueio 
								cHora <= Alltrim(x[4]) .AND. ;		//hora de desbloqueio
								cData <  Alltrim(x[5])       }) > 0
			
			lBloq := .T.
		EndIf
	EndIf
	// Quando for um prorrogação e o RDA tiver bloqueado, Verifica se foi feita a internação antes do bloqueio
	If Len(aDadProrro) > 0 .And. lBloq
		//Data da internção foi antes do bloqueio e desbloqueio da RDA
		If Ascan(aVgDatBlo,{|x|	aDadProrro[1] < StoD(Alltrim(x[1])) .AND. ;	//Data de bloqueio
								aDadProrro[1] < StoD(Alltrim(x[3])) }) > 0	//Data de desbloqueio			               		
			lBloq := .F. // Não Critica
		
		//Data e hora se a internação foi antes do bloqueio e desbloqueio da RDA
		ElseIf Ascan(aVgDatBlo,{|x|	aDadProrro[1] <= StoD(Alltrim(x[1])) .AND.	;		//Data de bloqueio
									Val(aDadProrro[2]) <=  Val(Alltrim(x[2]))	;	    //hora de bloqueio
									.AND.  ;
									aDadProrro[1] <= StoD(Alltrim(x[3])) .AND. 	;		//Data de desbloqueio 
								 	Val(aDadProrro[2]) <=  Val(Alltrim(x[4])) }) > 0	//hora de desbloqueio			
			lBloq := .F. // Não Critica
		EndIf	
	EndIf
	
	(cAliBlo)->(DbCloseArea())

	if lBloq
		if !lRpc
			MsgAlert(OemtoAnsi(STR0025)) //"Rede de Atendimento bloqueada nesta data"
		endif
		lRet := .F.
	endif

return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ A360HISBLO ³ Autor ³Alexander	 		³ Data ³ 09.06.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Consulta o historico de bloquei da RDA                     ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A360HISBLO()

Local aCabBC4 := {}
Local aDadBC4 := {}
Local aTrbBC4 := {}
Local nOpca   := 1
Local oBrwBC4
Local oDlg
Local cFil

BC4->(DbSetOrder(1)) //BC4_FILIAL + BC4_CODCRE + DTOS(BC4_DATA) + BC4_HORA
If  BC4->(MsSeek(xFilial("BC4")+M->BC4_CODCRE))
	DEFINE MSDIALOG oDlg TITLE STR0082 FROM 009,010 TO 040,110 OF GetWndDefault()//'Historico (Des)bloqueio'
	Store Header "BC4" TO aCabBC4 For .T. .and. SX3->X3_CAMPO <> "BC4_CODCRE" .and. SX3->X3_CAMPO <> "BC4_NOMCRE"
	Store COLS 	"BC4" TO aDadBC4 From aCabBC4 VETTRAB aTrbBC4 While xFilial("BC4")+M->BC4_CODCRE == BC4->(BC4_FILIAL+BC4_CODCRE)
	oBrwBC4  := TPLSBrw():New(040 ,001 ,400 ,200 ,nil ,oDlg ,nil ,{|| nil } ,nil ,nil  ,nil , .T., nil, .T. , nil ,aCabBC4 ,aDadBC4 ,.F. ,"BC4" ,K_Visualizar,OemtoAnsi(STR0026),nil,nil,nil,aTrbBC4,,,) //"Historico (Des)bloqueio da Rede de Atendimento"
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {|| nOpca := 1,oDlg:End()}, {|| nOpca := 2,oDlg:End()} )
Else
	Aviso( OemtoAnsi(STR0027),OemtoAnsi(STR0028),{ OemtoAnsi(STR0029) }, 2 ) 	                                                                     //"Rede de Atendimento"###"Não existe Historico de (Des)bloqueio para esta Rede de Atendimento."###"Ok"
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ A360CHKDAT ³ Autor ³Alexander	 		³ Data ³ 09.06.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Checa data de (des)bloqueio								  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A360CHKDAT()

Local lRet := .T.

If	M->BC4_DATA < BAU->BAU_DTINCL
	MsgAlert(OemtoAnsi(STR0030)) //"Data menor que a data de inclusäo da RDA!"
	lRet := .F.
ElseIf M->BC4_DATA < BAU->BAU_DATBLO
	MsgAlert(OemtoAnsi(STR0031)) //"Data de (Des)bloqueio INVALIDA!"
	lRet := .F.
EndIf

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A360CHKREG
Checa registro ja cadastrado	

@author    Silvia
@version   12.1.17
@since     19.01.18
/*/
//------------------------------------------------------------------------------------------
Function A360CHKREG(cChave)
local lRet 		:= Eval( { || Obrigatorio(aGets,aTela) })
local lUnimed := GetNewPar("MV_PLSUNI","0") == "1"

If lRet
	BC4->(DbSetOrder(2)) // BC4_FILIAL + BC4_CODCRE + BC4_TIPO + DTOS(BC4_DATA) + BC4_HORA
	If BC4->(DbSeek(xFilial("BC4")+cChave))
		Help("",1,"JAGRAVADO")
		lRet := .F.
	Endif
Endif

if lRet .and. lUnimed
	if M->BC4_TIPO == "0" .and. BAU->BAU_TIPPRE = 'HOS' .and. empty(M->BC4_MOTSUB) 
		MsgAlert("Para tipo de prestador hospital preencher o motivo da substituição.")
		lRet := .F.
	endif

	if M->BC4_TIPO == "0" .and. BAU->BAU_TIPPRE = 'HOS' .and. M->BC4_MOTSUB == '02' .and. empty(M->BC4_OFICIO)
		MsgAlert("Para redimensionamento por interesse da operadora obrigatório o preenchimento do Número do Ofício.")
		lRet := .F.
	endif

	if M->BC4_MOTSUB == '05' .and. empty(M->BC4_OBS)
		MsgAlert("Quando utilizado o motivo 05-Suspensão deve ser informado a observação")
		lRet := .F.
	endif

endif


if lRet .and. M->BC4_TIPO = '1'
	BC4->(DbSetOrder(1)) // BC4_FILIAL+BC4_CODCRE+DTOS(BC4_DATA)+BC4_HORA
	BC4->(DbGotop())
	If BC4->(DbSeek(xFilial("BC4")+ M->BC4_CODCRE ))
		While !BC4->(Eof()) .and.  BC4->(BC4_FILIAL + BC4_CODCRE) == M->BC4_FILIAL + M->BC4_CODCRE 
			If BC4->BC4_TIPO = '0' .and.  BC4->BC4_DATA == M->BC4_DATA .and. BC4->BC4_HORA > M->BC4_HORA
				MsgAlert("Existe um bloqueio com a mesma data, porem com a hora maior que a data de desbloqueio.")
				lRet := .F.
			Endif
			BC4->(DbSkip())
		Enddo	 
	Endif

Endif


Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PlsChkAE   ³ Autor ³Alexander	 		³ Data ³ 07.06.06 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Checa se pode excluir ou alterar							  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PlsChkAE()

LOCAL lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Checa se o indice existe										    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SIX->(DbSetOrder(1))
If !SIX->( MsSeek("BAX3") )
	MsgAlert(OemtoAnsi(STR0038)+"BAX_FILIAL+BAX_CODINT+BAX_CODESP+BAX_CODIGO")
	lRet := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vefifica antes de deletar se ja existe registro na bax				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	BAX->(DbSetOrder(3))
	If BAX->( MsSeek( xFilial('BAX')+oGet15:aCols[oGet15:Linha(),oGet15:PlRetPos("BBF_CODESP")]+BAU->BAU_CODIGO ) )
		MsgAlert(OemtoAnsi(STR0037))
		lRet := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³19/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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

local asubRrot  := { 		{ "Contatos"					,'NwTlContato',0,1 	,0,nil}, ; //contatos
                         	{ "Corpo Clínico"				,'NwTlCpoCl',  0,2	,0,nil},; //Corpo Clínico
							{ "Rede de Atendimento"			,'NwTlRda',  0,3	,0,nil},;
							{ "Procedimentos"					, "PlBrwTela", 0,4,0,nil}}// Rede de Atendimento

Local _aRotina := {	;
	{ OemtoAnsi(STR0001),'AxPesqui'		, 0, K_Pesquisar , 0, .F.},; //"Pesquisar"
	{ OemtoAnsi(STR0002),'PLSA360MNT'	, 0, K_Visualizar, 0, Nil},; //"Visualizar"
	{ OemtoAnsi(STR0003),'PLSA360MNT'	, 0, K_Incluir   , 0, Nil},; //"Incluir"
	{ OemtoAnsi(STR0004),'PLSA360MNT'	, 0, K_Alterar   , 0, Nil},; //"Alterar"
	{ OemtoAnsi(STR0005),'PLSA360MNT'	, 0, K_Excluir   , 0, Nil},; //"Excluir"
	{ OemtoAnsi(STR0006),'PLSA360BLO'	, 0, K_Excluir   , 0, Nil},; //"(Des)Bloquear"
	{ OemtoAnsi(STR0007),'PLSA365MNT', 0, K_Alterar   , 0, Nil},; //"Complemento"
	{ OemtoAnsi(STR0032),'PLSVALPAG' , 0, 0           , 0, Nil},; //"Valor Producao"
	{ OemtoAnsi(STR0033),'PLSA360LEG', 0, 0           , 0, .F.}}//"Legenda"


aadd(_aRotina, {"Contatos CRM"  , "FtContato" , 0, 4})  //"Contatos"
aAdd(_aRotina, {"Contrato/Aditivo", 'PLS360GCON()', 0, 0}) //'Gerar Contrato'
aAdd(_aRotina, {STR0089, 'PLSEXCEUS', 0, 0}) //"Exceção de pagamento U.S"  
aAdd(_aRotina, {STR0090, 'PlsinfSbRDA', 0, 0}) //"Informar Substituto RDA"
aAdd(_aRotina, {"Conhecimento",'PLS360CONH(.T.)', 0, 0})
aAdd(_aRotina, {"Especialidades x Cadastros relacionados",asubRrot		,0,0 ,0,nil}) 	
Return(_aRotina)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Pls360Cgc ³ Autor ³ Henry Fila            ³ Data ³26/09/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca o Cgc ou CPF de acordo com o tipo de pessoa          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pls360Cgc(cTipPes, cCNPJ)

Local lRetorno := .T.

If ReadVar() == "M->BYV_NUMDOC"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o tipo de pessoa                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipPes == "F" .AND. !(Len(AllTrim(cCNPJ))==11)
		Help(" ",1,"CPFINVALID")
		lRetorno := .F.
	ElseIf cTipPes == "J" .AND. !(Len(AllTrim(cCNPJ))==14)
		Help(" ",1,"CGC")
		lRetorno := .F.
	EndIf
ElseIf ReadVar() == "M->BYV_TPDOC"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o tipo de pessoa                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipPes == "F" .And. !Empty(M->BYV_NUMDOC) .And. !(Len(AllTrim(cCNPJ))==11)
		Help(" ",1,"CPFINVALID")
		lRetorno := .F.
	ElseIf cTipPes == "J" .And. !Empty(M->BYV_NUMDOC) .And. !( Len(AllTrim(cCNPJ))==14)
		Help(" ",1,"CGC")
		lRetorno := .F.
	EndIf

Endif

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSRAtA400 ³ Autor ³ Microsiga            ³ Data ³15/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função para tratar a Rede Referenciada do PTU A400         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRAtA400(nOpcx)

Local aCabRdAt 	:= {}
Local cSQL 	   	:= ""
Local nI		:= 0
Local nOpca		:= 0
Local aSize 	:= {}
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local oDlg
Local bCancel 	:= {|| If(MsgYesNo(__cMsgAban),(oDlg:End()),.F.) }

aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 100, .t., .t., .t. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE STR0066 From aSize[7],0 to aSize[6]-100, aSize[5]-478 PIXEL//"Rede de Referenciada para o A400"
If Len(aCabRdAt) == 0
	Store Header "B0G" TO aCabRdAt For .T.
Endif
If Len(aDadRdAt) == 0
	cSQL := "SELECT * FROM "
	cSQL += RetSqlName("B0G")+" WHERE "
	cSQL += "B0G_FILIAL = '"+xFilial("B0G")+"' AND "
	cSQL += "B0G_CODRDA = '"+BAU->BAU_CODIGO+"' AND "
	cSQL += "D_E_L_E_T_ = ' ' "
	cSQL += "ORDER BY B0G_ABRRED, B0G_CODREF "
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"B0GTMP",.F.,.T.)
	If B0GTMP->(Eof())
		Store COLS Blank "B0G" TO aDadRdAt FROM aCabRdAt
	Else
		While !B0GTMP->(Eof())
			Aadd(aDadRdAt,Array(Len(aCabRdAt)+1))
			B0G->(MsGoto(B0GTMP->R_E_C_N_O_))
			For nI := 1 To Len(aCabRdAt)
				If ( aCabRdAt[nI,10] !=  "V" )
					aDadRdAt[Len(aDadRdAt)][nI] := B0GTMP->(FieldGet(FieldPos(aCabRdAt[nI,2])))
				Else
					aDadRdAt[Len(aDadRdAt)][nI] := CriaVar(aCabRdAt[nI,2],.T.)
				EndIf
			Next nI
			aDadRdAt[Len(aDadRdAt)][Len(aCabRdAt)+1] := .F.
			Aadd(aTrbRdAt, B0GTMP->R_E_C_N_O_ )
			dbSelectArea("B0GTMP")
			dbSkip()
		EndDo
	EndIf
	B0GTMP->(dbCloseArea())
Endif
dbSelectArea("B0G")

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

oBrwRdAt := TPLSBrw():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3]-233,aPosObj[1][4]-27,nil,oDlg,nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabRdAt,aDadRdAt,.F.,"B0G",nOpcx,"Rede Ref. para A400.",nil,nil,nil,aTrbRdAt,"PLSRAtVld()",nil/*delete*/)
ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| aDadRdAt := aClone(oBrwRdAt:aCols),PlsEndBrw(),oDlg:End()},bCancel,.F.,{})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA360	³ Autor ³ Microsiga             ³ Data ³27/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da Rede Referenciada para o PTU A400             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRAtVld()

If 	!Empty(M->B0G_CODREF) .And. !Empty(M->B0G_ABRRED) .And. !Empty(M->B0G_DESCRI)
	If ! PLSVLDGD({"B0G_ABRRED","B0G_CODREF"},.F.)
		If Aviso(STR0062,STR0076+M->B0G_ABRRED+StrZero(Val(M->B0G_CODREF),3)+'".'+CHR(10)+CHR(13)+STR0077,{STR0078,STR0079}) <> 1 //'Já existe o registro: "'###'Deseja continuar ? '###"Sim" ###"Não"
			Return .F.
		EndIf
	EndIf
Else
	Aviso(STR0062,STR0075,{STR0029})//"Atenção"##"É necessário preencher todos os campos antes de confirmar."##"Ok"
	Return .F.
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA360   ³ Autor ³ Microsiga             ³ Data ³27/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao WHEN do campo B0G_DESCRI                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRAtWhen()
Local lRet := .F.

If M->B0G_ABRRED <> "NA"
	lRet := .T.
Else
	If M->B0G_CODREF = "001"
		M->B0G_DESCRI := "BASICA"
		lRet := .F.
	ElseIf M->B0G_CODREF = "002"
		M->B0G_DESCRI := "ESPECIAL"
		lRet := .F.
	ElseIf M->B0G_CODREF = "003"
		M->B0G_DESCRI := "MASTER"
		lRet := .F.
	Else
		M->B0G_DESCRI := ""
		lRet := .F.
	EndIf
	M->B0G_DESCRI += Space((TamSX3("B0G_DESCRI")[1])-Len(M->B0G_DESCRI))
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA360   ³ Autor ³ Microsiga             ³ Data ³27/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao VALID do campo B0G_CODREF                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLCodRfVld()
Local lRet := .F.

If M->B0G_ABRRED='NA'
	lRet := ((Val(M->B0G_CODREF)>0 .AND. Val(M->B0G_CODREF)<4 .AND. LEN(ALLTRIM(M->B0G_CODREF))=3) .OR. EMPTY(M->B0G_CODREF))
Else
	lRet := ((Val(M->B0G_CODREF)>0 .AND. LEN(ALLTRIM(M->B0G_CODREF))=3) .OR. EMPTY(M->B0G_CODREF))
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSVLDBY5 ºAutor  ³Darcio R. Sporl     º Data ³  10/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função criada para validar a linha do aCols, para evitar    º±±
±±º          ³duplicidade de registro, no complemento do Cadastro de RDA, º±±
±±º          ³na Aba de Tabela Honorários X RDA.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsVldB25()

Local lRet    := .T.

If ReadVar() == "M->B25_VIGINI"
	If !Empty(M->B25_VIGINI) .and. !Empty(M->B25_VIGFIN) .and. M->B25_VIGINI > M->B25_VIGFIN// Nao permitido.
		MsgStop(STR0073)////"A vigência inicial deve ser menor ou igual a vigência final."
		lRet := .F.
	Endif
Elseif ReadVar() == "M->B25_VIGFIN"
	If !Empty(M->B25_VIGINI) .and. !Empty(M->B25_VIGFIN) .and. M->B25_VIGFIN < M->B25_VIGINI// Nao permitido.
		MsgStop(STR0074)//"A vigência final deve ser maior ou igual a vigência inicial."
		lRet := .F.
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA360   ºAutor  ³Microsiga           º Data ³  09/17/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PlsVldB26()

LOCAL lRet := .T.

If ReadVar() == "M->B26_VIGINI"
	If !Empty(M->B26_VIGINI) .and. !Empty(M->B26_VIGFIN) .and. M->B26_VIGINI > M->B26_VIGFIN// Nao permitido.
		MsgStop(STR0073)//"A vigência inicial deve ser menor ou igual a vigência final."
		lRet := .F.
	Endif
Elseif ReadVar() == "M->B26_VIGFIN"
	If !Empty(M->B26_VIGINI) .and. !Empty(M->B26_VIGFIN) .and. M->B26_VIGFIN < M->B26_VIGINI// Nao permitido.
		MsgStop(STR0074)//"A vigência final deve ser maior ou igual a vigência inicial."
		lRet := .F.
	Endif
Endif
If M->B26_CODPAD == cCodPad .And. M->B26_CODPSA == cCodPsa
	lRet := .F.
   // O codigo do procedimento principal e o mesmo do procedimento que esta sendo digitado
	Help("",1,"PLSA201BJ4")
Else
	PLSGATNIV(M->B26_CODPAD,M->B26_CODPSA,"B26")
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA360   ºAutor  ³Microsiga           º Data ³  07/23/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsDelB26()

Local n
Local lRet := .T.

For n := 1 To Len(oBrwB26:aCols)
	If	oBrwB26:FieldGet("B26_AUXPAD", n) == cCodPad .and.;
		oBrwB26:FieldGet("B26_AUXPSA", n) == cCodPsa .and.;
		!oBrwB26:IsDeleted(n)
		MsgInfo(STR0072)//"Os itens devem ser excluidos antes de excluir o cabeçalho."
		lRet := .F.
		Exit
	Endif
Next

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldB29 ºAutor  ³Totvs		         º Data ³  01/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a linha do acols da Rda x Tab Preco.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsVldB29()

Local lRet     := .T.
Local cDatDe  := ""
Local cDatAte := ""
//Local aChave  := {'01',M->B29_TABPRE,'B29_TABPRE'}
Local nUsado   := Len(aHeader) 
Local nPosTabP := Ascan(aHeader,{|x| Alltrim(x[2])=="B29_TABPRE"})
Local nPosVigF := Ascan(aHeader,{|x| Alltrim(x[2])=="B29_VIGFIN"})
Local nX := 0
Local lVigTab :=  GetMv("MV_PLSTABP",,.F.)
	
cDatDe  := "B29_VIGINI"
cDatAte := "B29_VIGFIN"

If lVigTab
	lRet := PLSVLDVIG("B29",0,oGet31,cDatDe,cDatAte,{})
Else
	For nX := 1 To Len(aCols)
		If !aCols[nX][nUsado+1]
			If nX < n
				If M->B29_TABPRE  == aCols[nX][nPosTabP] .And. Empty(aCols[nX][nPosVigF])
					Aviso(STR0069,STR0070,{STR0029},2)//"Vigencia Final"##"Esta tabela está em uso, informe a vigencia final para utiliza-la novamente!"##"Ok"
					lRet := .F.
					Return .F.
				ElseIf M->B29_TABPRE  == aCols[nX][nPosTabP] .And. !Empty(aCols[nX][nPosVigF]) .And. M->B29_VIGINI <= aCols[nX][nPosVigF]
					Aviso(STR0069,STR0071,{STR0029},2)//"Vigencia Final"##"A Vigencia Inicial deve ser maior do que a Vigencia Final do registro anterior desta tabela!"##"Ok"
					lRet := .F.
					Return .F.
				Endif
			Endif
		Endif
	Next
EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVldBBC
Valilda código de Débito/Crédito informado.
O INSS outras empresas deve ser cadastrado pela rotina FINA027, pois o SIGAFIN irá apurar os impostos.

@author silvia.santanna
@since 06/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function PlsVldBBC(cCodSer)

Local lRet     := .T.

If cCodSer == SUPERGETMV("MV_PLSCIOE", .T., "")
	Aviso("INSS Outras Empresas","O INSS Outras Empresas deve ser cadastrado pela rotina FINA027.",{STR0029},2)//"INSS Outras Empresas"##"A partir desse momento o INSS outras empresas deve ser cadastrado pela rotina FINA027"
	lRet := .F.
EndIf 

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ A360DATPRO ³ Autor ³Totvs 				³ Data ³ 29.06.12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Valida a data de Procedimento							  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A360DATPRO(cCodRda, dDatPro)

Local lRet := .T.

If dDatPro < BAU->BAU_DTINCL
	MsgAlert(OemtoAnsi(STR0030)) //"Data menor que a data de inclusäo da RDA!"
	lRet := .F.
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ PlsIniBC0³ Autor ³ Victor Ferreira       ³ Data ³ 13.09.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Utilizada para tratar inicializador padrao dos campos de   ³±±
±±³          ³ descricao da tabela BC0									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo : Utilizada para indicar o nome do campo que o      ³±±
±±³			 ³			o inicializador ira tratar.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PLSA365  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsIniBC0(cCampo)

Local cDesc :=""
Local nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando qual campo esta sendo inicializado						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCampo == "BC0_DESTAB"
	If !Inclui .AND. !Empty(BC0->BC0_CODTAB)
		BF8->(dbSetOrder(1))//BF8_FILIAL+BF8_CODINT+BF8_CODIGO
		If BF8->(dbSeek(xFilial("BF8")+BC0->(BC0_CODINT+BC0_CODTAB)+"01"))
			cDesc:= BF8->BF8_DESCM
		Else
			cDesc:= ""
		Endif
	Endif
Elseif cCampo == "BC0_DESPAD"
	If !Inclui .Or. !Empty(BC0->BC0_CODPAD)
		BR4->(dbSetOrder(1))//BR4_FILIAL+BR4_CODPAD+BR4_SEGMEN
		If BR4->(dbSeek(xFilial("BR4")+BC0->BC0_CODPAD))
			cDesc:= BR4->BR4_DESCRI
		Else
			cDesc:= ""
		Endif
	Endif
Elseif cCampo == "BC0_DESOPC"
	If !Inclui .And. !Empty(BC0->BC0_CODOPC)
		BR8->(dbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
		If BR8->(dbSeek(xFilial("BR8")+BC0->(BC0_CODPAD+BC0_CODOPC)))
			cDesc:= BR8->BR8_DESCRI
		Else
			cDesc:= ""
		Endif
	Endif
Elseif cCampo == "BC0_DESNIV"
	If !Inclui
		BR4->(dbSetOrder(3))//BR4_FILIAL + BR4_CODPAD + BR4_CODNIV + BR4_DIGVER
		If BR4->(dbSeek(xFilial("BR4")+BC0->(BC0_CODPAD+BC0_NIVEL)))
			cDesc := BR4->BR4_DESC
		Else
			cDesc := ""
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua limpeza no aCols do objeto oGet06(Procedimentos) quando os	³
//³ campos virtuais sao preenchidos automaticamente sem necessidade		³
//³	atraves do inicializador padrao.									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oGet06:ACOLSNOFIL") <> "U"
	For nX := 1 To Len(oGet06:ACOLS)
		If Empty(oGet06:ACOLS[nX,5]) .AND. EMPTY(oGet06:ACOLS[nX][GdFieldPos("BC0_CODOPC",oGet06:AHEADER)])
			oGet06:ACOLS[nX][6 ] := ""
			oGet06:ACOLS[nX][8 ] := ""
			oGet06:ACOLS[nX][10] := ""
			oGet06:ACOLS[nX][12] := ""
		EndIf
	Next 
EndIf

Return (cDesc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³PL360VLD  ³ Autor ³ TOTVS                 ³ Data ³ 03/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao | Funcao generica para validacao de campos e consultas.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ cCont  : Utilizada para indicar o nome do campo/consulta   ³±±
±±³	    	  ³			 que sera tratada.         					      	   ³±±
±±³	    	  ³	cVar   : Conteudo informado no campo                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL360VLD(cCont,cVar)

DEFAULT cVar := ""

If cCont == "BBI_CODPRO"
	DbSetOrder(1)
	If BI3->(DbSeek(xFilial("BI3")+M->BBI_CODINT+cVar))
		M->BBI_DESPRO:= Posicione("BI3",1,xFilial("BI3")+M->BBI_CODINT+cVar,"BI3_DESCRI")
		Return .T.
	Endif
ElseIf cCont == "BBI_VERSAO"
	DbSetOrder(1)
	If BI3->(DbSeek(xFilial("BI3")+M->BBI_CODINT+M->BBI_CODPRO+cVar))
		Return .T.
	Endif
ElseIf cCont == "BSUPLS"
	If FunName() == "PLSA360"
		Return BIL->BIL_CODIGO == PlsIntPad()+M->BBI_CODPRO
	Else
		Return BIL->BIL_CODIGO == BG9->BG9_CODINT+M->BT6_CODPRO .And. Empty(BIL->BIL_DATFIN)
	Endif
Endif

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA360RPS
Abre a tela de cadastro de vinculo plano X Rede
@author David
@since 15/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function PLSA360RPS()

MsgAlert("Rotina descontinuada", "Atenção!")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaCri
Carga de Helps relacionados a rotina
@author victor.silva
@since 07/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarregaCri()

PutHelp("PPLSA360CBO",{STR0045,STR0046,STR0054},{},{},.T.) //"Para Rede de Atendimento Pessoa Física""é obrigatório o preenchimento do campo"'"CBO-S (BAU_CBO)".'
PutHelp("SPLSA360CBO",{STR0047,STR0048,""},{},{},.T.) //"Informe o valor do campo no Folder" '"Registro" para continuar.'
PutHelp("PPLVL360CBO",{STR0049,STR0050,""},{},{},.T.) //"Registro não encontrado na""tabela de domínio."
PutHelp("SPLVL360CBO",{STR0051,STR0052,STR0053},{},{},.T.) //"Informe um valor válido ou realize o" 'cadastro na tabela "B0X - Codigo CBOS"'"na Rotina Cadastro Cbos (PLSA997)."

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSABAUVLD
Validação genérica dos campos da tabela BAU
@author victor.silva
@since 07/04/2015
@version 1.0
@param cCampo, caracter, Campo a ser validado
@return lRet, lógica, Retorno da validação 
/*/
//-------------------------------------------------------------------
Function PLSABAUVLD(cCampo)

Local cValue	:= &(ReadVar())  
Local lRet		:= .T.
Local aArea	:= GetArea()
	
If cCampo == "BAU_CBO"
	B0X->(DbSelectArea(1))
	B0X->(DbSetOrder(1)) //B0X_FILIAL + B0X_CODCBO
	If !Empty(cValue) .And. !(B0X->(MsSeek(xFilial("B0X") + cValue))) 
		Help("",1,"PLVL360CBO")
		lRet := .F.
	Endif
	
	If Empty(M->BAU_CBO) .And. M->BAU_TIPPE == "F"
		Help("",1,"PLSA360CBO")
		lRet:= .F.
	Endif	
Endif
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
Function PLSBBCVLD()

Local lRet := .T.
Local cMesAno :=""

If !empty(&__ReadVar)
	If M->BBC_DEBCRE =="3" .And. __ReadVar =="M->BBC_VLDINI" 			
		cMesAno:= Substr(DToc(&__ReadVar),3)
		M->BBC_VLDINI := CTOD("01" + cMesAno)
	ElseIf M->BBC_DEBCRE =="3" .And. __ReadVar =="M->BBC_VLDFIM"
		M->BBC_VLDFIM := Lastday(&__ReadVar,0)
	ElseIf __ReadVar == "M->BBC_CODSER" 
		M->BBC_VLDINI := CtoD("")
		M->BBC_VLDFIM := CtoD("")
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS360GCON
Envia para a Rotina de gerar contrato, com o número da RDA já preenchido
@author Rodrigo Morgon
@since 13/08/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS360GCON(oModel,cRDA)

Local cCodInt 	:= PLSINTPAD()
Local nOperation 	:= 0
Local nRecno		:= 0
Local oExecView	:= nil

Default cRDA 		:= BAU->BAU_CODIGO	

If Vazio(cRDA)
	MsgAlert(STR0061 /*"É preciso realizar o cadastramento da RDA antes de gerar o contrato!"*/, STR0062 /*"Atenção"*/)
else
	B2G->(DbSelectArea("B2G"))
	B2G->(DbSetOrder(1))
	If B2G->(MsSeek(xFilial("B2G")+cCodInt+cRDA))
		nRecno := B2G->(Recno()) //Se já existe, pegamos o Recno do registro
	else
		//É necessário Gravar o registro na B2G, caso não haja outro do prestador, pois
		//ele gera erro caso o formulário principal não seja alterado e a ideia da rotina
		//é entregar esse pedaço do cadastro já preenchido para o usuário.
		B2G->(RecLock("B2G", .T.))
		B2G->B2G_FILIAL	:= xFilial("B2G")
		B2G->B2G_CODINT	:= cCodInt
		B2G->B2G_RDA		:= cRDA
		B2G->(MsUnlock())
		nRecno := B2G->(Recno())
	EndIf
	
	B2G->(DbGoTo(nRecno)) //Movemos até o registro existente ou recém-criado
	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()
		
	//Esse bloco de comandos abre a tela do cadastro de Geração de contrato		
	oExecView := FWViewExec():New() 		//Criamos o objeto que abre a View
	oExecView:SetTitle(STR0063) 			//Define título da Janela - "Gerar Contrato"
	oExecView:SetSource('PLSA731') 			//Definimos o Model que iremos utilizar, no caso, o Model do fonte PLSA731
	oExecView:SetModal(.F.) 					//View não abre em janela Modal
	oExecView:SetCloseOnOk({|| .T.}) 		//A tela irá fechar ao confirmar o Ok
	oExecView:SetOperation(4) 				//Como sempre haverá um registro, o cadastro abre sempre como alteração
	oExecView:OpenView(.F.)				 	//Abrimos o cadastro
	B2G->(DbCloseArea())
EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSPRESU
Abre a tela de cadastro do Prestador Substituto PTUA400
@author Totvs
@since 22/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PLSPRESU()

Local aArea := BAU->(GetArea())
Local cMot  := Space(2)
Local oDlg  := nil 
Local nOpca :=0

DEFINE MSDIALOG oDlg TITLE STR0056 FROM 000,000 TO 080,300 PIXEL    //"Motivo Exclusão"
@ 001,001 TO 040, 150 OF oDlg PIXEL 
@ 010,010 SAY STR0057 SIZE 55, 07 OF oDlg PIXEL //"Informe motivo:"
@ 010,050 MSGET cMot F3 "CN" SIZE 55, 11 OF oDlg PIXEL VALID ExistCpo('SX5','CN'+cMot)
DEFINE SBUTTON FROM 008, 120 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg 
DEFINE SBUTTON FROM 022, 120 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg 
ACTIVATE MSDIALOG oDlg CENTERED
If nOpca == 1 .And. !Empty(Alltrim(cMot))
	BAU->(DbSetOrder(1))
	BAU->(MsSeek(xFilial("BAU")+M->BC4_CODCRE))
	BAU->(RecLock("BAU",.F.))
	BAU->BAU_EXCEDI := cMot
	BAU->(MsUnLock())
Endif
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³PLVLDSUBED³ Autor ³ TOTVS                 ³ Data ³ 24/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao | Valida preenchimento de RDA substituta                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLVLDSUBED(cRDA, cLocBlq, cLocSub, cTipo)

Local lRet := .T.
Local aAreaBAU := BAU->(GetArea())   
Local nPosCod  := 0
Local nPosBlq	 := 0
Local nPosSub	 := 0

nPosCod := Ascan(oBrwPreSub:aHeader,{|x| x[2] == "B7O_PRESUB"})  
nPosBlq := Ascan(oBrwPreSub:aHeader,{|x| x[2] == "B7O_LABBLO"})  
nPosSub := Ascan(oBrwPreSub:aHeader,{|x| x[2] == "B7O_LABSUS"}) 
  
/*If ( (aScan(oBrwPreSub:aCols,{|x|x[nPosCod] == Alltrim(cRDA)}) > 0)  .And. !PlsinfSbRDA("2") ) 
	MsgInfo(STR0064)//"O prestador informado já foi utilizado"	
	lRet := .F.
EndIf */
If lRet
	BAU->(DbSetOrder(1))
	If Alltrim(cRDA) == Alltrim(M->BC4_CODCRE) .Or. Alltrim(cRDA) == Alltrim(M->B7O_CODRDA)
		MsgInfo(STR0058)//"O Prestador Substituto não pode o mesmo que está sendo Bloqueado"
		lRet := .F.
	Endif   
Endif
If lRet 
	If BAU->(MsSeek(xFilial()+Alltrim(cRDA))) 
		If !Empty(BAU->BAU_DATBLO)
			MsgInfo(STR0059)//"O Prestador Substituto não pode estar Bloqueado"
			lRet := .F.
		Endif
	Else
		MsgInfo(STR0060)//"Codigo Prestador Inválido"
		lRet := .F.
	Endif
Endif    
    
If ( lRet .And. !Empty(cLocBlq) .And. !Empty(cLocSub) )
	If ( (aScan(oBrwPreSub:aCols,{|x|x[nPosCod] == Alltrim(cRDA)}) > 0) .And. (aScan(oBrwPreSub:aCols,{|x|x[nPosBlq] == Alltrim(cLocBlq)}) > 0) ;
		 .And. (aScan(oBrwPreSub:aCols,{|x|x[nPosSub] == Alltrim(cLocSub)}) > 0) )
		 MsgInfo(STR0100) //"O prestador e local de atendimento já foram usados para esta RDA e/ou local bloqueados!"
		 lRet := .F. 
	EndIf
EndIf	

If ( lRet .And. Empty(cLocBlq) .And. !Empty(cLocSub) )
	If ( (aScan(oBrwPreSub:aCols,{|x|x[nPosCod] == Alltrim(cRDA)}) > 0) .And. (aScan(oBrwPreSub:aCols,{|x|x[nPosSub] == Alltrim(cLocSub)}) > 0) )
		 MsgInfo(STR0100) //"O prestador e local de atendimento já foram usados para esta RDA e/ou local bloqueados!"
		 lRet := .F. 
	EndIf
EndIf 

If ( !Empty(cTipo) .And. !Empty(cRDA) .And. !Empty(cLocSub) .And. cTipo == "2" .And. lRet)
	lRet := PLSVLEXCDR (cTipo, cRda,  cLocSub)
EndIf	

RestArea(aAreaBAU)    

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} InfPresSub
Informa prestadores substitutos da rede bloqueada.
@since  22.09.2015
/*/
//-------------------------------------------------------------------
Static Function InfPresSub(lNvSubs, dDtBloq)  

Local nRecBAU     := BAU->(Recno())  
Local bOK         := {|| nOpca := 1, Eval({|| oDlg:End()})}
Local aDadPreSub  := {}    
Local aTrbPreSub  := {} 
Local aChave      := {}            
Local nOpca       := 0     
Local nCont       := 0
Local lInfSubst   := .F.
Local aCabPreSub  := {}
Local oDlgPreSub       
Local nI			:= 1
Local cCodRDA		:= BAU->BAU_CODIGO
Local aProviSub		:= {}
Local nPosLB		:= 0
Local nPosLS		:= 0
Local nPosRed 		:= 0
Local nPosPla		:= 0
Local nPosEnd		:= 0 
Local nPosCod 		:= 0
Local nPosNvl		:= 0	
Local aBkPTot		:= {}
local aRecDel		:= {}
local aRecDelAt	:= {}
Private oBrwPreSub
Private cCdRdaATs	:= BAU->BAU_CODIGO

Default lNvSubs	:= .F.
default dDtBloq := Date()

B7O->(dBSETORDER(1))
B7O->(dbgotop())  //Necessário pois em algumas siutações, o sistema dava a tabela como EOF

//Monta a GetDados de Prestadores substitutos
Store Header "B7O" TO aCabPreSub For .T.

If  ( B7O->(dbSeek(xFilial('B7O') + cCodRDA)) )
	Store COLS "B7O" TO aDadPreSub FROM aCabPreSub While (B7O->(B7O_FILIAL + B7O_CODRDA) == xFilial("B7O") + cCodRDA)
Else 
	Store COLS Blank "B7O" TO aDadPreSub FROM aCabPreSub
//Recupera o código da RDA bloqueada para que seja exibido na tela
	For nI := 1 To Len(aDadPreSub)
			aDadPreSub[nI][1] := cCodRDA
	Next
ENDIF	

DEFINE MSDIALOG oDlgPreSub TITLE STR0065 FROM 009,000 TO 040,180 OF GetWndDefault()//"Prestador substituto"
oDlgPreSub:lEscClose := .F.

//Monta o Browse dos Procedimentos
oBrwPreSub  := TPLSBrw():New(0033,001,710,230,nil  ,oDlgPreSub,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabPreSub ,aDadPreSub ,.F. ,"B7O" ,3,"Prestador substituto" ,,nil,nil,aTrbPreSub,/*'PlsVldBHC'*/)
oBrwPreSub:bBeforAddC  := ({|| PlsBrOB7O(oBrwPreSub, cCodRDA)})
oBrwPreSub:bAfterAdd  := ({|| PlsABROB7O(oBrwPreSub, cCodRDA, dDtBloq )})

//Verifica se algum prestador substituto
nPosCod    	:= aScan(aCabPreSub,{|x|x[2] == "B7O_PRESUB"})
nPosLB     	:= aScan(aCabPreSub,{|x|x[2] == "B7O_LABBLO"})
nPosLS	   	:= aScan(aCabPreSub,{|x|x[2] == "B7O_LABSUS"})	
nPosRed 	:= aScan(aCabPreSub,{|x|x[2] == "B7O_REDEXC"})
nPosPla		:= aScan(aCabPreSub,{|x|x[2] == "B7O_PLAEXC"})
nPosEnd		:= aScan(aCabPreSub,{|x|x[2] == "B7O_ENDEXC"}) 
nPosNvl		:= aScan(aCabPreSub,{|x|AllTrim(x[2]) == "B7O_NVEXC" }) 

//Ajuste temporário até a mudança ser revista
For nI := 1 To Len(oBrwPreSub:aCols)
	If B7O->(dbSeek(xFilial('B7O') + cCodRDA + oBrwPreSub:aCols[nI,nPosNvl] + oBrwPreSub:aCols[nI,nPosCod] + oBrwPreSub:aCols[nI,nPosRed] + oBrwPreSub:aCols[nI,nPosPla] + oBrwPreSub:aCols[nI,nPosEnd] + oBrwPreSub:aCols[nI,nPosLB] + oBrwPreSub:aCols[nI,nPosLS]))   
		aadd(aRecDel, B7O->(recno()))
	endif
Next

ACTIVATE DIALOG oDlgPreSub CENTERED ON INIT ( EnchoiceBar(oDlgPreSub, {|| nOpca:=1,oDlgPreSub:End()},{|| nOpca:= 0,oDlgPreSub:End()} ))

If nOpca == 1
	
	BAU->(DbGoTo(nRecBAU)) //posiciona no registro da RDA que está sendo bloqueada, para que possamos informar o código da mesma no array de gravação.
	
	//Garante que todas as posições estarão com o código da RDA bloqueada
	For nCont := 1 To Len(oBrwPreSub:aCols)
		oBrwPreSub:aCols[nCont][1] := BAU->BAU_CODIGO
	Next
	
	aCabPreSub := aClone(oBrwPreSub:aHeader)
	aDadPreSub := aClone(oBrwPreSub:aCols)
	
	For nCont := 1 to len(aDadPreSub)
		If !Empty(aDadPreSub[nCont][nPosCod]) .And. !aDadPreSub[nCont][len(aCabPreSub)+1]
			lInfSubst := .T.
			Exit
		Endif
	Next
		
	//Inicio da Transacao...
	Begin Transaction
   
   		aBkpTot := aClone(oBrwPreSub:aCols)
   		
   		B7O->(DbSetOrder(1))  //B7O_FILIAL, B7O_CODRDA, B7O_NVEXC, B7O_PRESUB, B7O_REDEXC, B7O_PLAEXC, B7O_ENDEXC, B7O_LABBLO, B7O_LABSUS
   		   		
   		For nI := 1 To len(aBkpTot)   			
   			
   			If B7O->(dbSeek(xFilial('B7O') + cCodRDA + aBkpTot[nI,nPosNvl] + aBkpTot[nI,nPosCod] + aBkpTot[nI,nPosRed] + aBkpTot[nI,nPosPla] + aBkpTot[nI,nPosEnd] + aBkpTot[nI,nPosLB] + aBkpTot[nI,nPosLS]))   
   				oBrwPreSub:aVetTrab := {B7O->(RECNO())}
					 aadd(aRecDelAt, B7O->(recno()))
   			Else
   				oBrwPreSub:aVetTrab := {0}  //Vetrab é usado para localizar o registro, se for edição. Se for inclusão, passa como 0. 
   			Endif
   				
			aChave := {}
			aadd(aChave,{"B7O_FILIAL",xFilial("B7O")})
			aadd(aChave,{"B7O_CODRDA",BAU->BAU_CODIGO})
				
			oBrwPreSub:aCols := {}
			aAdd(oBrwPreSub:aCols, aBkpTot[nI])
			oBrwPreSub:nOpc := K_Alterar
			oBrwPreSub:Grava(aChave)
		Next	
	
	//Fim da Transacao...
	End Transaction

	//Analiso quais registro deletar após alteração, devido ao seek da B7O dar negativo por qualquer alteração.
	for nI := 1 to len(aRecDel)
		if (aScan(aRecDelAt,{|x| (x) == aRecDel[nI]}) == 0)
			B7O->(dbgoto(aRecDel[nI]))
			B7O->(reclock("B7O", .f.))
				B7O->(DbDelete())
			B7O->(MsUnlock())
		endif
	next 

	//Gravo o campo antigo para versoes inferiores a 6.3
	If lInfSubst
		BAU->(RecLock("BAU",.F.))
		BAU->BAU_RDASUB := aDadPreSub[nCont][nPosCod]
		BAU->(MsUnLock())
  		
		B7O->(RecLock("B7O",.F.))
		B7O->B7O_FILIAL := xFilial('B7O')
		//B7O->B7O_NVEXC := '01'
   		If B7O->(FieldPos('B7O_DTBLOQ')) > 0 .and. empty(B7O->B7O_DTBLOQ) 
   			B7O->B7O_DTBLOQ := DATE()
   		EndIf
		B7O->(MsUnLock())
	EndIf
EndIf
BAU->(DbGoTo(nRecBAU)) //Adicionado para que o registro a ser bloqueado não "se perca". Acontecia em alguma situações, dele bloquear o substituto sem isso.

Return(lInfSubst)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS360CONH
Gerencia anexos do banco de conhecimento da RDA
@author: Mario Augusto Cavenaghi
@since : 09-05-2016
/*/
//-------------------------------------------------------------------
Function PLS360CONH(lBcoCon)

LOCAL aArea := getArea()
local nI	:= 0
default lBcoCon := .F.
Private aRotina := aClone(_aRotina)

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

If ! lBcoCon
	MsDocument("BAU", BAU->(RecNo()), IIF(ALTERA, 4, 2))
Else
	MsDocument("BAU", BAU->(RecNo()), 4)
EndIf
RestArea(aArea)

If ! lBcoCon
	for nI := 1 to len(aRotina)
		aRotina[nI] := aSize(aRotina[nI], 0)
	next
	aSize(aRotina,0)
EndIf

Return() 


//-------------------------------------------------------------------
/*/{Protheus.doc} PA360Valida
Valida campo de nacionalidade BAU_NACION
@author: José Luís Camatta
@since : 20.09.16
/*/
//-------------------------------------------------------------------
Function PA360Valida()

Local lRet 	:= .F.
Local aNacio:= {}

aNacio := FWGetSX5('34')
lRet := aScan(aNacio,{|x| AllTrim(x[4]) == AllTrim(UPPER(M->BAU_NACION))}) > 0 

If !lRet .And. !Empty(M->BAU_NACION) 
	MsgAlert( OemtoAnsi( "Informe uma nacionalidade valida!" ) )
	M->BAU_NACION := ""
EndIf	

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsinfSbRDA
Informar substituto na RDA
@author: Renan Martins
@since : 10/2016
/*/
//-------------------------------------------------------------------
Function PlsinfSbRDA(cTipo)
Local lEstSus		:= .F.
Local lInfSubst	:= .F.
Local cSql 		:= ""
Local aArea		:= BC4->(GetArea())
Local aAreaB8		:= BB8->(GetArea())
Local cCodRDA		:= Iif (cTipo == '2', cCdRdaATs, BAU->BAU_CODIGO)
Local cCodOpe		:= PlsIntPad() //BAU->BAU_CODOPE
Local cAliasl		:= RetSqlName("BB8")
Local lAllRda		:= .T.
Local cTipo 		:= Iif(cTipo <> '2', '1', '2') 
Local aMNen		:= {}
local dDtBloq		:= ctod("")

//Query para verificar se o Prestador possui histórico de bloqueio
cSQL := "SELECT MAX(R_E_C_N_O_) RECNO "
cSQL += " FROM " + RetSqlName("BC4")
cSQL += " WHERE BC4_FILIAL = '" + xFilial("BC4") + "'"
cSQL += " AND   BC4_CODCRE = '" + cCodRDA + "' "
cSQL += " AND   D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
TcQuery cSql New Alias "BC4BLO"

If BC4BLO->(EOF())
	aMNen := {STR0091} //MsgAlert (STR0091)  //"A RDA não esta bloqueada!"
	lEstSus := .T.
ELSE
	BC4->(DbGoTo(BC4BLO->RECNO))
	IF (BC4->BC4_TIPO <> '0')  //É desbloqueio
		aMNen := {STR0091, STR0092} //MsgAlert(STR0091 + CRLF + STR0092)  //"A RDA não esta bloqueada!" # "Não é possível definir um substituto"
		lEstSus := .T.
	ElseIF ( BC4->BC4_MOTIVO <> '0')  //Bloqueio do tipo Suspensão
		aMNen := {STR0093, STR0092} //MsgAlert(STR0093 + CRLF + STR0092)  //"A RDA está com bloqueio do tipo Suspensão!"#
		lEstSus := .T.		
	ENDIF	
ENDIF

dDtBloq := BC4->BC4_DATA
lAllRda := IIf (cTipo == '2' .And. !lEstSus, .F., .T.)  

//Se a RDA não está bloqueada, vamos verificar os locais de atendimento estão bloquados
If lEstSus
	//Query para verificar se os locais de atendimento estão bloqueados
	cSql := " SELECT BB8_CODIGO, BB8_CODLOC, BB8_LOCAL, BB8_DESLOC, BB8_DATBLO "
	cSql += " FROM " + cAliasl
	cSql += " WHERE BB8_FILIAL = '" + xFilial("BB8") + "' AND BB8_CODIGO = '" + cCodRDA + "' "
	cSql += " AND   BB8_CODINT = '" + cCodOpe + "' AND BB8_DATBLO <> '' " 
	cSql += " AND   " + cAliasl + ".D_E_L_E_T_ = ' ' "
	
	cSql := ChangeQuery(cSql)
	TcQuery cSql New Alias "BB8BLOQ"
	
	If !( BB8BLOQ->(EOF()) )  //Significa que temos locais bloqueados
		lAllRda := IIf (cTipo == '2' .And. lEstSus, .T., .F.) 
		aMNen := {}
		lEstSus := .F.  //Setamos false, para habilitar a escolha de prestadores substitutos 
		dDtBloq := stod(BB8BLOQ->BB8_DATBLO)
	EndIf
	BB8BLOQ->(dbCloseArea())
EndIf	

If !Empty(aMNen)
	MsgAlert(aMNen[1] + CRLF + aMNen[2])
EndIf

BC4BLO->(dbCloseArea())
RestArea(aArea)		//Devolvo BC4 a situação original
RestArea(aAreaB8)		//Devolvo BC4 a situação original	

IF !lEstSus .And. cTipo == '1'  //Significa que temos realmente um bloqueio ativo
	If MsgYesNo( STR0088, STR0065 ) //"Deseja informar um prestador substituto?" #"Prestador Substituto"
		//-------------------------------------------------------------------
		//  LGPD
		//-------------------------------------------------------------------
		objCENFUNLGP:useLogUser()
		lInfSubst := InfPresSub(.T., dDtBloq)
	endIf
ENDIF

Return (lAllRDA)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsABROB7O
Atualizar grid após inserção do registro
@author: Renan Martins
@since : 10/2016
/*/
//-------------------------------------------------------------------
Function PlsABROB7O(oObjGrid, cCodRDA, dDtaBlo)
Local nPosCod := Ascan(oObjGrid:aHeader,{|x| x[2] == "B7O_PRESUB"})  
Local nPosSub := Ascan(oObjGrid:aHeader,{|x| x[2] == "B7O_LABSUS"})  
Local nPosData := Ascan(oObjGrid:aHeader,{|x| x[2] == "B7O_DTBLOQ"})  
default dDtaBlo := date()

oObjGrid:acols[oObjGrid:obrowse:nAt,1] := cCodRDA
oObjGrid:acols[oObjGrid:obrowse:nAt,nPosData] := dDtaBlo 

If ( (aScan(oObjGrid:acols,{|x|x[nPosCod] == oObjGrid:acols[(oObjGrid:oBrowse:nAt),nPosCod]}) <> (oObjGrid:oBrowse:nAt))  .And. (aScan(oObjGrid:acols,{|x|x[nPosSub] == oObjGrid:acols[(oObjGrid:oBrowse:nAt),nPosSub]}) <> (oObjGrid:oBrowse:nAt)) ) 
	MsgInfo(STR0064)//"O prestador informado já foi utilizado"	
	aDel(oObjGrid:acols, (oObjGrid:oBrowse:nAt))
	aSize(oObjGrid:acols, Len(oObjGrid:acols)-1)
EndIf

oObjGrid:Refresh()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsBrOB7O
Atualizar aCols antes de passar para o browse ao dar duplo clique - EditRecord(PLSGRV)
@author: Renan Martins
@since : 07/2017
/*/
//-------------------------------------------------------------------
Function PlsBrOB7O(oObjGrid, cCodRDA) 
oObjGrid:oBrowse:acols[Len(oObjGrid:oBrowse:acols),1] := cCodRDA
oObjGrid:oBrowse:ForceRefresh()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVLBLAT
Valida edição (X3_When) do campo de locais de atendimento bloqueados. Se toda a RDA está bloqueada, a edição fica bloqueada. Se apenas locais, fica habilitado.
@author: Renan Martins
@since : 07/2017
/*/
//-------------------------------------------------------------------
Function PLSVLBLAT()
local lRet := .F.

lRet := PlsinfSbRDA('2')
	
return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVLEXCDR
Função que valida se o campo estava preenchido com data de bloqueio antes da alteração e se existem RDAs substitutas atreladas, podendo o usuário excluir estas substituições
Código da RDA / Cód. Local de Atendimento / Endereço / Número
@author: Renan Martins
@since : 07/2017
/*/
//-------------------------------------------------------------------
Function PLVLExDbRDA (cCodRDA, cCodLoc, cEnde, cNumEnd)
Local cSql := ""
	
cSql := " SELECT B7O_PRESUB FROM " + retSqlname("B7O") 
cSql += " WHERE B7O_FILIAL = '" + xFilial("B7O") + "' "
cSql += "   AND B7O_CODRDA = '" + cCodRDA + "' "

if B7O->(fieldPos('B7O_LABBLO')) > 0		
	cSql += "   AND B7O_LABBLO = '" + cCodLoc + "' "
endIf
	
cSql += "   AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"B7OVerBlo",.f.,.t.)

If !( B7OVerBlo->(EOF()) )

	If msgYesNo( STR0097 + CRLF + cCodLoc + " - " + cEnde + " - " + cNumEnd + CRLF + STR0098 ) //"Existe(m) prestador(es) substituto(s) definido(s) para o seguinte Local de Atendimento: " / "Como a data de bloqueio foi apagada, deseja excluir estes locais substitutos?"                                                                                                                                                                                                                                                                                                                                                                                                                         
	
		cSql := " UPDATE " + retSqlname("B7O") + " SET D_E_L_E_T_ = '*' "
		cSql += "  WHERE B7O_FILIAL = '" + xFilial("B7O") + "' "
		cSql += "    AND B7O_CODRDA = '" + cCodRDA + "' "
		
		if B7O->(fieldPos('B7O_LABBLO')) > 0		
			cSql += "    AND B7O_LABBLO = '" + cCodLoc + "' "	
		endIf
		
		cSql := msParse( cSql,alltrim( TcGetDB() ) )
		
		TCSqlExec(cSql)
	
		msgAlert(STR0099) //"RDA's substitutas foram excluídas com sucesso!"
		
	EndIf
	
EndIf

B7OVerBlo->(DbCloseArea())

Return	
	
	
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVLEXCDR
Função que valida locais bloqueados/não bloqueados
Código da RDA / Cód. Local de Atendimento / Endereço / Número
@author: Renan Martins
@since : 07/2017
/*/
//-------------------------------------------------------------------
Function PLSVLEXCDR (cTipo, cCodRda, cCodLoc)
Local aArea 	:= BB8->(GetArea())
Local lRet 	:= .F.
Local cCodInt	:= PlsIntPad()
Default cTipo := "1"

BB8->( DbSetOrder(1) )  //BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL
BB8->(DbGoTop())

If cTipo == "1"
	If ( BB8->(dbSeek(xFilial("BB8")+ cCodRda + cCodInt + cCodLoc)) )
		If !Empty(BB8->BB8_DATBLO)
			lRet := .T.
			M->B7O_DESLAB := BB8->BB8_DESLOC
		Else
			MsgInfo(STR0101)  //"Local de Atendimento não bloqueado!"
			M->B7O_DESLAB := ""
		EndIf
	Else
		MsgInfo(STR0102)  //"Local de Atendimento não existe na RDA informada!"
	Endif
Else
	If  ( BB8->(dbSeek(xFilial("BB8")+ cCodRda + cCodInt + cCodLoc)) )
		If !Empty(BB8->BB8_DATBLO)
			MsgInfo(STR0103)  //"Local de Atendimento bloqueado. Informe outro local."
			M->B7O_DESLAP := ""
		Else
			lRet := .T.
			M->B7O_DESLAP := BB8->BB8_DESLOC
		EndIf
	Else
		MsgInfo(STR0102)  //"Local de Atendimento não existe na RDA informada!"
	EndIf
EndIf 	

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PA360Valida
Valida campo de matricula do funcionario BAU_MATFUN.
Para geração da SEFIP preciso que tanto o funcionário quando a RDA possuam o mesmo CPF.
@author Lucas Nonato
@since  17/11/2017
/*/
//-------------------------------------------------------------------
Function P360ValFun()

Local lRet 	:= .T.

SRA->(dbSetOrder(1))
If !Empty(M->BAU_MATFUN) .And. SRA->(MsSeek(SRA->RA_FILIAL + M->BAU_MATFUN)) .And. AllTrim(M->BAU_CPFCGC) == SRA->RA_CIC
	lRet 	:= .T.
ElseIf !Empty(M->BAU_MATFUN)
	MsgInfo("CPF do prestador diferente do funcionario!")
	lRet:= .F. 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSMOTSUB
Combo Box do campo BC4_MOTSUB.

@author Lucas Nonato
@since  18/05/2018
/*/
//-------------------------------------------------------------------                                                                                                                                                
function PLSMOTSUB()   

return "01=Substituição;02=Redimensionamento por interesse da operadora;03=Redimensionamento por interesse exclusivo do prestador;04=Redimensionamento por encerramento das atividades hospitalares;05=Suspensão"


//-------------------------------------------------------------------
/*/{Protheus.doc} buscaB84
Busca B84
@author 
@since  
/*/
//------------------------------------------------------------------- 
function buscaB84(cCodRDA)

Local cSql := ""
Local aret := {}

cSql += " Select R_E_C_N_O_ RECB84 From " + RetsqlName("B84")
cSql += " Where B84_FILIAL = '" + xfilial("B84") + "' AND "
cSql += " B84_CODIGO = '" + cCodRDA + "' AND "
cSql += " D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"BUSB84",.F.,.T.)

while !( BUSB84->(EoF()))
	aadd(aRet, BUSB84->RECB84)
	BUSB84->(Dbskip())
EndDo
BUSB84->(dbclosearea())

return aret

/*//-------------------------------------------------------------------
{Protheus.doc} NwTlCpoCl
Executa a chamada da nova tela Especialidades x Cadastros relacionados - Corpo Clinico
@since    04/2020
@Thiago Rodrigues
//-------------------------------------------------------------------*/
function NwTlCpoCl()
local aButtons 	:= {{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,"Confirmar"},{.t.,'Cancelar'},{.t.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.f.,nil}}	
FwMsgRun( , {|| FWExecView("Corpo Clínico",'PLSA365BC1', 4,,,,,aButtons )}, ,'Carregando as informações...')
return

/*//-------------------------------------------------------------------
{Protheus.doc} NwTlContato
Executa a chamada da nova tela Planos
@since    06/2020
@Thiago Rodrigues
//-------------------------------------------------------------------*/
function NwTlContato()
local aButtons 	:= {{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,"Confirmar"},{.t.,'Cancelar'},{.t.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.f.,nil}}	
FwMsgRun( , {|| FWExecView("Contatos",'PLSA365BBG', 4,,,,,aButtons )}, ,'Carregando as informações...')
return

/*//-------------------------------------------------------------------
{Protheus.doc} NwTlRda
Executa a chamada da nova tela Rede de atendimentos
@since    06/2020
@Thiago Rodrigues
//-------------------------------------------------------------------*/
function NwTlRda()
local aButtons 	:= {{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,"Confirmar"},{.t.,'Cancelar'},{.t.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.f.,nil}}	
FwMsgRun( , {|| FWExecView("Rda",'PLSA365BBK', 4,,,,,aButtons )}, ,'Carregando as informações...')
return


function PlBrwTela()
local aButtons 	:= {{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,"Confirmar"},{.t.,'Cancelar'},{.t.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.f.,nil}}	
FwMsgRun( , {|| FWExecView("Rda",'PLSRDAREFC', 1,,,,,aButtons )}, ,'Carregando as informações...')
return