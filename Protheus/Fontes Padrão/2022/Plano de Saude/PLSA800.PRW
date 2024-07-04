#define  K_NovaVersao  6
#include "PLSMGER.CH"
#include "PLSA800.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"

STATIC _nH
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA800
Manutenção de Planos 

@author  PLS TEAM
@version P12
@since   07.12.00
/*/ 
//------------------------------------------------------------------- 
Function PLSA800
PRIVATE cPLSVersao 	:= "001"
PRIVATE aRotina		:= MenuDef()
PRIVATE aCdCores  	:= {}
PRIVATE aCores    	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cAlias    	:= "BI3"
PRIVATE cCadastro 	:= PLSRetTit(cAlias)
PRIVATE cCodPla   	:= ""
PRIVATE cVerPla   	:= ""
PRIVATE cCodRdA   	:= ""
PRIVATE cCodSeqBEK  	:= ""
PRIVATE cCodSeqB31 	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cFiltro := "BI3->BI3_FILIAL = '"+xFilial("BI3")+"' .And. BI3->BI3_VERSAO = '001'"

aCdCores  	:= {	{ 'BR_LARANJA'	,OemtoAnsi("Ativo com comercialização suspensa")},;
					{ 'BR_VERMELHO'	,OemtoAnsi(STR0008)},;  //"Bloqueado"
					{ 'BR_VERDE'   	,OemtoAnsi(STR0009)} }	//'Ativo'

aCores    	:= {	{ 'BI3_SITANS = "2"',aCdCores[1,1] },;
					{ 'BI3_STATUS = "2"',aCdCores[2,1] },;
					{ 'BI3_STATUS = "1"',aCdCores[3,1] } }

BI3->(DbSetOrder(1))
DbSelectArea("BI3")
SET FILTER TO &cFiltro
BI3->(MsSeek(xFilial("BI3")))
BI3->(mBrowse(006,001,022,075,"BI3" , , , , , Nil    , aCores, , , .T.))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera filtro...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BI3->(DbClearFilter())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA800Mov
Movimentação

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSA800Mov(cAlias,nReg,nOpc)
Local I__f := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle de versoes...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oBotCob
LOCAL cVerEsc
LOCAL cChave
Local cVerBase
Local cVerAnt
Local nLinEsc
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva informacoes...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOrdBI3
LOCAL nRegOld := nReg
LOCAL oBotAd1
LOCAL oBotOp1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Historico de reajuste da franquia...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aButtBHI := {}
LOCAL aButtBHD := {}
LOCAL aButtBHJ := {}
LOCAL aButtBYK := {}
LOCAL aButtBCW := {}
LOCAL aObjects := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros da EnchoiceBar...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL bOK     := {|| nOpca := 1,If(PLSA800OK(nOpc,M->BI3_CODINT+M->BI3_CODIGO).And.PLSA800Exc(M->BI3_CODINT,M->BI3_CODIGO,M->BI3_VERSAO,.T.,nOpc),;
(oDlgFolder:End()),nOpca:=2),If(nOpca==1,oDlgFolder:End(),.F.) }
LOCAL bCancel := {|| If(MsgYesNo(__cMsgAban),(nOpca := 0, oDlgFolder:End()),.F.) }
LOCAL nPosBT3 := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Genericos ou de compatibilizacao...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE bVldGFoc:= { || Eval(oBrwCob:bLostFocus), Eval(oBrwGru:bLostFocus) }
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aSVTela
PRIVATE aSVGets
PRIVATE aHeader := {}
PRIVATE aCols   := {}
PRIVATE n       := 1
PRIVATE nOpcx   := nOpc
PRIVATE nOpca   := 0
PRIVATE oFolder
PRIVATE oDlgFolder
PRIVATE cChvVer
PRIVATE aSTela  := {}
PRIVATE aTrbVer := {}
PRIVATE nRecBIL := 0
PRIVATE oSay01
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Coberturas...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabCob := {}
PRIVATE aDadCob := {}
PRIVATE aTrbCob := {}
PRIVATE oBrwCob
PRIVATE cCodProPsa := ""
PRIVATE cCodProPad := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procedimentos x Co-participacao                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabPCo := {}
PRIVATE aDadPCo := {}
PRIVATE aTrbPCo := {}
PRIVATE oBrwPCo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados do Cobranca de Identificacao de Usuario                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBJB := {}
PRIVATE aDadBJB := {}
PRIVATE aTrbBJB := {}
PRIVATE oBrwBJB
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produtos Vinculados...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabPro := {}
PRIVATE aDadPro := {}
PRIVATE aTrbPro := {}
PRIVATE oBrwPro
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produtos Vinculados...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabPFai := {}
PRIVATE aDadPFai := {}
PRIVATE aTrbPFai := {}
PRIVATE oBrwPFai
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados dos Parametros Pagamento...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabPPg := {}
PRIVATE aDadPPg := {}
PRIVATE aTrbPPg := {}
PRIVATE oBrwPPg
PRIVATE cTipPreSel := ""
PRIVATE cTipClasse := ""
Private cTipPre    := ""
Private cCodMun    := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados dos Parametros Pagamento x Procedimentos...                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabPPP := {}
PRIVATE aDadPPP := {}
PRIVATE aTrbPPP := {}
PRIVATE oBrwPPP
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Situacoes adversas...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabSit := {}
PRIVATE aDadSit := {}
PRIVATE aTrbSit := {}
PRIVATE oBrwSit
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redes de Atendimento...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabRed := {}
PRIVATE aDadRed := {}
PRIVATE aTrbRed := {}
PRIVATE oBrwRed
PRIVATE oChkRed
PRIVATE lChkRed := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Relacionamento com a contabilidade                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabCtb := {}
PRIVATE aDadCtb := {}
PRIVATE aTrbCtb := {}
PRIVATE oBrwCtb

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formas de Cobranca do plano ...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabFor := {}
PRIVATE aDadFor := {}
PRIVATE aTrbFor := {}
PRIVATE oBrwFor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fornecedor parceiro...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabFPa := {}
PRIVATE aDadFPa := {}
PRIVATE aTrbFPa := {}
PRIVATE oBrwFPa
PRIVATE cDesRda := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formas de CObranca da Taxa de Adesao...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabAde := {}
PRIVATE aDadAde := {}
PRIVATE aTrbAde := {}
PRIVATE oBrwAde
PRIVATE nLimTXA := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupo de Coberturas...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabGru := {}
PRIVATE aDadGru := {}
PRIVATE aTrbGru := {}
PRIVATE oBrwGru
PRIVATE cCodGru := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupo de Coberturas x Coparticipacao                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabGCo := {}
PRIVATE aDadGCo := {}
PRIVATE aTrbGCo := {}
PRIVATE oBrwGCo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Co-participacao                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabCoPar := {}
PRIVATE aDadCoPar := {}
PRIVATE aTrbCoPar := {}
PRIVATE oBrwCoPar
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Regras novos depedentes                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBEK := {}
PRIVATE aDadBEK := {}
PRIVATE aTrbBEK := {}
PRIVATE oBrwBEK

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Regras Carencia por tipo de Internacao                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBYK := {}
PRIVATE aDadBYK := {}
PRIVATE aTrbBYK := {}
PRIVATE oBrwBYK
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupo de Carencia                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBAY := {}
PRIVATE aDadBAY := {}
PRIVATE aTrbBAY := {}
PRIVATE oBrwBAY
PRIVATE cGruCarSel := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Classe de Carencia                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBAN := {}
PRIVATE aDadBAN := {}
PRIVATE aTrbBAN := {}
PRIVATE oBrwBAN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupo de Carencia x Classe de Carencia                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBAE := {}
PRIVATE aDadBAE := {}
PRIVATE aTrbBAE := {}
PRIVATE oBrwBAE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Documentos obrigatorios...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBQP := {}
PRIVATE aDadBQP := {}
PRIVATE aTrbBQP := {}
PRIVATE oBrwBQP
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuarios permitidos...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabUsr := {}
PRIVATE aDadUsr := {}
PRIVATE aTrbUsr := {}
PRIVATE oBrwUsr
PRIVATE oChkUsr
PRIVATE lChkUsr := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Detalhamento da Forma de Cobranca ...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabDet  := {}
PRIVATE aDadDet  := {}

PRIVATE aCabTxD  := {}
PRIVATE aDadTxD  := {}

PRIVATE lNewVer  := .F.
PRIVATE aVetsFor := {}
PRIVATE aVetsTxF := {}
PRIVATE aVetsOpc := {}

PRIVATE cUCodGru     := ""
PRIVATE cUCodPad  	:= ""
PRIVATE cUCodPSA  	:= ""
PRIVATE cUOpcCID     := ""
PRIVATE cUOpcEsp     := ""
PRIVATE cUCodGQuan   := ""
PRIVATE cCodPad   	:= ""
PRIVATE cCodPSA   	:= ""
PRIVATE cOpcCID		:= ""
PRIVATE cOpcEsp   	:= ""
PRIVATE cCodGQuan		:= ""

PRIVATE oGetBCU
PRIVATE aCabBCU := {}
PRIVATE aDadBCU := {}
PRIVATE aVetBCU := {}

PRIVATE oGetBCW
PRIVATE aCabBCW := {}
PRIVATE aDadBCW := {}
PRIVATE aVetBCW := {}

PRIVATE oGetBCZ
PRIVATE aCabBCZ := {}
PRIVATE aDadBCZ := {}
PRIVATE aVetBCZ := {}

PRIVATE oGetBGD
PRIVATE aCabBGD := {}
PRIVATE aDadBGD := {}
PRIVATE aVetBGD := {}

PRIVATE oBrwBKJ
PRIVATE aCabBKJ := {}
PRIVATE aDadBKJ := {}
PRIVATE aTrbBKJ := {}

PRIVATE oBrwB60
PRIVATE aCabB60 := {}
PRIVATE aDadB60 := {}
PRIVATE aTrbB60 := {}

PRIVATE oBrwB61
PRIVATE aCabB61 := {}
PRIVATE aDadB61 := {}
PRIVATE aTrbB61 := {}

PRIVATE oBrwB86
PRIVATE aCabB86 := {}
PRIVATE aDadB86 := {}
PRIVATE aTrbB86 := {}

PRIVATE oBrwBY9
PRIVATE aCabBY9 := {}
PRIVATE aDadBY9 := {}
PRIVATE aTrbBY9 := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados PROD. X FATORES MULTIP. REEMB.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabB31 := {}
PRIVATE aDadB31 := {}
PRIVATE aTrbB31 := {}
PRIVATE oBrwB31

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados VIG. PROD. X FAT. MULT. REEMB                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabB32 := {}
PRIVATE aDadB32 := {}
PRIVATE aTrbB32 := {}
PRIVATE oBrwB32
PRIVATE aVETB32 := {}

PRIVATE oBrwBB3
Private oBotPro
Private oBotAde
Private oBotForOpc
Private lNewVersao := nOpc = K_NovaVersao

PRIVATE nAlt 		:= 033
PRIVATE nAlt2 	:= 039
PRIVATE aDifSize	:= {,,,,35,3,,}

PRIVATE lHaAltFor := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Tela ...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aSize := MsAdvSize()
AAdd( aObjects, { 100, 200, .T., .T. } )
AAdd( aObjects, { 200, 100, .T., .T.,.T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T. )
aPosObj[1][2]+=15

//Libera filtros do mBrowse...
BI3->(DbClearFilter())

//Controle de versao do planos...
nOrdBI3 := BI3->(IndexOrd())
cChave  := BI3->(BI3_CODINT+BI3_CODIGO)

If nOpc == K_Incluir
	cPLSVersao := "001"
ElseIf nOpc == K_NovaVersao
	lNewVer := .T.
	BI3->(DbSetOrder(1))
	BI3->(MsSeek(xFilial("BI3")+cChave+"999",.T.))
	BI3->(DbSkip(-1))
	If BI3->BI3_CODINT+BI3->BI3_CODIGO==cChave
  	   cVerBase := BI3->BI3_VERSAO
  	EndIf
    cPLSVersao := StrZero(Val(BI3->BI3_VERSAO)+1,3)
ElseIf nOpc == K_Visualizar .Or. nOpc == K_Alterar .Or. nOpc == K_Excluir
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle de versao do plano. Exibir as versoes existentes...        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cVerEsc := ""
	BI3->(DbSetOrder(1))
	BI3->(MsSeek(xFilial("BI3")+cChave+"001"))
	BI3->(DbSkip())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VERSOES...                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Store Header "BIL" TO aCabVer For .T.
	BIL->(DbSetOrder(1))
	BIL->(DBGoTop())
	If BIL->(MsSeek(xFilial("BIL")+cChave+"001"))
		Store COLS "BIL" TO aDadVer FROM aCabVer VETTRAB aTrbVer While cChave == BIL->(BIL_CODIGO)
	Else

		Help("",1,"PLSA800VE")

		SET FILTER TO &cFiltro
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define dialogo...                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLinEsc := 0
	If Len(aDadVer) > 1
		DEFINE MSDIALOG oDlgFolder TITLE OemtoAnsi(STR0010) FROM aSize[7],0 To aSize[6],aSize[5] PIXEL OF GetWndDefault() //"Versao do Plano"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ TPLSBRW -> VERSOES                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oBrwVer := TPLSBrw():New(035,007,600,200	   ,nil  ,oDlgFolder,nil    , {|| nOpca := 1,cVerEsc := oBrwVer:aCols[oBrwVer:Linha(),oBrwVer:PLRETPOS("BIL_VERSAO")], oDlgFolder:End() } ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabVer,aDadVer,.F.,"BIL",K_Visualizar,"VersÕes do Plano",{{"BIL_DATFIN","=",ctod("")}})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ativa o dialogo...                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		oDlgFolder:LESCCLOSE := .F.

		ACTIVATE MSDIALOG oDlgFolder Center ON INIT EnchoiceBar(oDlgFolder,{|| Iif(A800VLDVER(nOpc) ,(nOpca := 1,nLinEsc := oBrwVer:Linha(),cVerEsc := oBrwVer:aCols[oBrwVer:Linha(),oBrwVer:PLRETPOS("BIL_VERSAO")], oDlgFolder:End()),NIL)},{|| nOpca := 2,oDlgFolder:End()})

		If nLinEsc == Len(aDadVer) .and. nLinEsc > 1
	   	   cVerAnt := aDadVer[nLinEsc-1,PLRETPOS("BIL_VERSAO",aCabVer)]
		EndIf
	Else
		nOpca   := K_OK
		cVerEsc := aDadVer[1,PLRETPOS("BIL_VERSAO",aCabVer)]
		cVerAnt := ""
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ testa se confirmou alguma versao...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpca <> K_OK
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Refaz filtro para mBrowse...                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SET FILTER TO &cFiltro

		Return
	Endif

	BI3->(DbSetOrder(1))
	BI3->(MsSeek(xFilial("BI3")+cChave+cVerEsc))

	nReg := BI3->(Recno())

	BIL->(DbSetOrder(1))
	BIL->(MsSeek(xFilial("BIL")+cChave+cVerEsc))
	nRecBIL := BIL->(Recno())
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para verificar se existem movimentacoes para o produto...³
//| Trata tambe se a versar selecionada podera ser excluida.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == K_Excluir
	If ! PLSA800Exc(BI3->BI3_CODINT,BI3->BI3_CODIGO,BI3->BI3_VERSAO,.T.,nOpc)
		Return
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta M->??? para enchoice...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir
	COPY cAlias To Memory Blank
	nLimTxa := M->BI3_LIMTXA
Else
	COPY cAlias TO MEMORY
	If cVerBase==NIL
   	   cChvVer := BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)
   	Else
   	   cChvVer := BI3->(BI3_CODINT+BI3_CODIGO+cVerBase)
   	EndIf
	lChkRed := IF(M->BI3_ALLRED=="1",.T.,.F.)
	lChkUsr := IF(M->BI3_ALLUSR=="1",.T.,.F.)
	nLimTXA := BI3->BI3_LIMTXA
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERSOES...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == K_Incluir .Or. nOpcx == K_NovaVersao
	Copy "BIL" To Memory BLANK
	M->BIL_VERSAO := cPLSVersao
ElseIf nOpcx <> K_NovaVersao
	Copy "BIL" To Memory
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Store Cols/Header separado por causa do Memory OverBooked           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A800Store(cAlias,nReg,nOpc, cChave, nOrdBI3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aObjects := {}
AAdd( aObjects, { 100, 20, .t., .f. } )
AAdd( aObjects, { 100, 100, .t., .t.,.t. } )
aPosObj := MsObjSize( aInfo, aObjects )

aInfo2 := { 0, 0, aPosObj[2,3], aPosObj[2,4], 3, 3 }
aObjects2 := {}
AAdd( aObjects2, { 100, 1, .t., .f. } )
AAdd( aObjects2, { 100, 100, .t., .t.,.t. } )
aPosObj2 := MsObjSize( aInfo2, aObjects2 )

aInfo3 := { 0, 0, aPosObj2[2,3], aPosObj2[2,4], 3, 3 }
aObjects3 := {}
AAdd( aObjects3, { 100, 80, .t., .t. } )
AAdd( aObjects3, { 100, 80, .t., .t. } )
aPosObj3 := MsObjSize( aInfo3, aObjects3 )

aInfo4 := { 0, 0, aPosObj[2,3], aPosObj[2,4], 3, 3 }
aObjects4 := {}
AAdd( aObjects4, { 100, 1, .t., .f. } )
AAdd( aObjects4, { 100, 100, .t., .t.,.f. } )
aPosObj4 := MsObjSize( aInfo4, aObjects4 )

DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] of oMainWnd Pixel
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Folder...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPosObj[2][1]*0.9,aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlgFolder PIXEL PROMPTS;
	OemtoAnsi(STR0011),;	//"Produto Saude"
	OemtoAnsi(STR0016),;	//"Versoes"
	OemtoAnsi(STR0012),;	//"Cobertura/Carencias"
	OemtoAnsi(STR0013),;	//"Tipo Rede Atendimento"
	OemtoAnsi(STR0014),;	//"Usuarios Permitidos"
	OemtoAnsi(STR0015),;	//"Forma de Cobranca"
	OemtoAnsi(STR0019),;	//"Taxas de Adesao"
	OemtoAnsi(STR0020),;	//"Produtos Relacionados"
	OemtoAnsi(STR0068),;	//"Rede Referenciada"
	OemtoAnsi(STR0025),;	//"Cobranca de Identificacao de Usuario"
	OemtoAnsi(STR0027),;	//"Situacoes Adversas"
	OemtoAnsi(STR0028),;	//"Parametros Contabilizacao"
	OemtoAnsi(STR0029),;	//"Parametros Pagamento Rede Atendimento"
	OemtoAnsi(STR0030),;	//"Documentos Obrigatorios"
	OemtoAnsi(STR0031),;	//"Faixa Desc. X Tip.Lanc"
	OemtoAnsi(STR0069),;	//"Produto x Regiao"
	OemtoAnsi(STR0070),;	//"Fatores de Reembolso"
	OemtoAnsi(STR0083)	//"Desc. Faixa Pagto"

oFolder:bChange    := { |nFolder| Eval(bVldGFoc) }

@ aPosObj2[2][1],aPosObj2[2][2] FOLDER oFldCob SIZE aPosObj2[2][3],aPosObj2[2][4] OF oFolder:aDialogs[3] PIXEL PROMPTS;
	OemtoAnsi(STR0032),;	//"Grupos Determinados"
	OemtoAnsi(STR0033),;	//"Procedimentos"
	OemtoAnsi(STR0035),;	//"Co-participacao"
	OemtoAnsi(STR0036),;	//"Carencia para Novos Depedentes"
	OemtoAnsi(STR0037),;	//"Propriedades por Tipo de Internacao
	OemtoAnsi(STR0038),;	//"Grupo de Carencia"
	OemtoAnsi(STR0039),;	//"Classe de Carencia"
	OemtoAnsi(STR0040),;	//"Tipo de Prestador"
	OemtoAnsi(STR0041)	//"Municipio de Atendimento"

oFldCob:bChange := { |nFolder| Eval(bVldGFoc)}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta mensagem informativa...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nAlt , 006 GROUP oGrupoPla TO 049, 039 PIXEL OF oDlgFolder LABEL OemtoAnsi(STR0042)  COLOR CLR_HBLUE, CLR_HRED //" Codigo "
@ nAlt2, 007 Say oSayPla PROMPT TransForm(M->BI3_CODINT+M->BI3_CODIGO,"@R !.!!!-!!!!") SIZE 037, 010 OF oDlgFolder PIXEL COLOR CLR_HBLUE

@ nAlt , 040 GROUP oGrupoPla TO 049, 160 PIXEL OF oDlgFolder LABEL OemtoAnsi(STR0043)  COLOR CLR_HBLUE, CLR_HRED	//" Descricao do Plano "
@ nAlt2, 044 Say oSayPla PROMPT M->BI3_DESCRI SIZE 100, 010 OF oDlgFolder PIXEL COLOR CLR_HBLUE

@ nAlt , 162 GROUP oGrupoPla TO 049, 245 PIXEL OF oDlgFolder LABEL OemtoAnsi(STR0044)  COLOR CLR_HBLUE, CLR_HRED	//" Versao "
@ nAlt2, 165 Say oSayPla PROMPT M->BIL_VERSAO+" - "+dtoc(M->BIL_DATINI)+" a "+dtoc(M->BIL_DATFIN) SIZE 100, 010 OF oDlgFolder PIXEL COLOR CLR_HBLUE

@ nAlt , 310 GROUP oGrupoPla TO 049, 355 PIXEL OF oDlgFolder LABEL OemtoAnsi(STR0084)  COLOR CLR_HBLUE, CLR_HRED	//" Status "
@ nAlt2, 313 Say oSaySTA PROMPT Eval({ || IF(M->BI3_STATUS=="1","ATIVO","BLOQUEADO") }) SIZE 100, 010 OF oDlgFolder PIXEL COLOR CLR_HBLUE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice BI3 (Planos)...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}
cVar  := "aSTela["+AllTrim(Str(Len(aSTela)+1))+"]"
aadd(aSTela,{})
oEncBI3 := MsMGet():New(cAlias,nReg,nOpc,,,,,{001,001,aPosObj[2][4]*0.9,aPosObj[2][3]},,,,,,oFolder:aDialogs[1],,,.F.,cVar)
aSTela[len(aSTela)] = aClone(aTela)

aSVTela := aClone(aTela)
aSVGets := aClone(aGets)

//Ajuste de compatibilidade de resolucao
aPosObj4[2][3] := aPosObj4[2][3]*0.85

If getScreenRes()[2] < 800
	aPosObj2[2][3] := aPosObj2[2][3]*0.9
	aPosObj3[1][3] := aPosObj3[1][3]*0.9
	aPosObj3[2][1] := aPosObj3[2][1]*0.9
	aPosObj3[2][3] := aPosObj3[2][3]*0.9
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> REDES DE ATENDIMENTO                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwRed := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][2],aPosObj4[2][4],aPosObj4[2][3],nil  ,oFolder:aDialogs[4],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabRed,aDadRed,.F.,"BB6",nOpcx,"Tipos de Rede de Atendimento",nil,nil,nil,,,,,,,,,,,,,,aDifSize)
oBrwRed:aVetTrab := aClone(aTrbRed)
@ aPosObj4[2][3],005 CHECKBOX oChkRed VAR lChkRed PROMPT OemtoAnsi(STR0045) PIXEL SIZE 120, 09 OF oFolder:aDialogs[4] //"Todos os Tipos de Rede de Atendimento"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> CONTABILIDADE                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwCtb := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3], nil  ,oFolder:aDialogs[12],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabCtb,aDadCtb,.F.,"BHT",nOpcx,"Parametros Contabilidade",nil,nil,nil,,,,,,,,,,,,,,aDifSize)
oBrwCtb:aVetTrab := aClone(aTrbCtb)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> FORMA COBRANCA                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwFor := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][2],aPosObj4[2][4],aPosObj4[2][3],nil  ,oFolder:aDialogs[6],nil, nil, nil ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabFor,aDadFor,.F.,"BJ3",nOpcx,"Forma de Cobranca",nil,nil,nil,nil,nil,"PLSM800Del(" + Str(nOpcx, 1) + ",1)",,,,,,,,,,,aDifSize)
oBrwFor:aVetTrab := aClone(aTrbFor)

@ aPosObj4[2][3], 005 BUTTON oBotPro PROMPT STR0057 ACTION {|| PLSA800For(nOpcx,1) } SIZE 45, 11 OF oFolder:aDialogs[6] PIXEL //"Propriedades"
oBotPro:cTOOLTIP := OemtoAnsi(STR0046) //"Propriedades da Forma de Cobranca"

@ aPosObj4[2][3], 055 BUTTON oBotPro PROMPT STR0047 ACTION {|| PL8000HSal() } SIZE 45, 11 OF oFolder:aDialogs[6] PIXEL //"Historicos"
oBotPro:cTOOLTIP := OemtoAnsi(STR0047) //"Historicos"

oBrwFor:bChange  	:= { ||	If(oBrwFor:IsDeleted(oBrwFor:Linha()),oBotPro:Disable(), oBotPro:Enable()) }
oBrwFor:bLostFocus  := { || Eval(oBrwFor:bChange) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> VERSOES                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}
cVar  := "aSTela["+AllTrim(Str(Len(aSTela)+1))+"]"
aadd(aSTela,{})
oEncVer := BIL->(MsMGet():New("BIL",nRecBIL,nOpc,,,,,{005,005,aSize[6]-10,aSize[5]},,,,,,oFolder:aDialogs[2],,,.F.,cVar))
aSTela[len(aSTela)] = aClone(aTela)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> COBERTURAS...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aButEsp := {{OemtoAnsi(STR0082),{||PlVigDifId("BB2",'BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO)+M->(BB2_CODPAD+BB2_CODPSA+BB2_NIVEL)',M->BB2_DIFIDA)},OemtoAnsi(STR0082),OemtoAnsi(STR0082)}} //"Period. Dif. Idade"
oBrwCOB  := TPLSBrw():New(aPosObj3[1,1],aPosObj3[1,2],aPosObj3[1,4],aPosObj3[1,3],nil  ,oFldCob:aDialogs[2],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabCob,aDadCob,.F.,"BB2",nOpcx,"Coberturas",nil,nil,nil,,,,,,aButEsp,,,,,,,,aDifSize)
oBrwCOB:bLostFocus := {|| cCodProPad := oBrwCOB:aCols[oBrwCOB:Linha(),oBrwCOB:PlRetPos("BB2_CODPAD")], cCodProPsa := oBrwCOB:aCols[oBrwCOB:Linha(),oBrwCOB:PlRetPos("BB2_CODPSA")], M->BI3_INFCOB := If(oBrwCob:VerExiData(),"1","0"), lRefresh := .T. }
oBrwCOB:bChange    := {||Eval(oBrwCOB:bLostFocus),oBrwPCo:ForceRefresh(oBrwCOB)}
oBrwCOB:aVetTrab := aClone(aTrbCob)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botao para visualizacao do historico de reajuste da franquia  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtBHD, {"BUDGET",{||PL660HTFRA('2',	"BHD",M->BI3_CODINT,;
													M->BI3_CODIGO,;
													M->BI3_VERSAO)},;
													"Historico de reajuste da franquia","Historico"})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> COBERTURAS X CO-PARTICIPACAO                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter   			:= {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BHD_CODPSA",aHeader)]==cCodProPsa .And. aCols[nLine,GdFieldPos("BHD_CODPAD",aHeader)]==cCodProPad }
oBrwPCo   			:= TPLSBrw():New(aPosObj3[2,1],aPosObj3[2,2],aPosObj3[2,4],aPosObj3[2,3]-20,nil  ,oFldCob:aDialogs[2],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabPCo,aDadPCo,.F.,"BHD",nOpcx,"Procedimentos x Co-participacao",nil,nil,nil,aTrbPCo,'PlsVldBHD',,bFilter,,aButtBHD,,,,,,,,aDifSize)
oBrwPCO:bChange   	:= { || Eval(oBrwCOB:bLostFocus) }
oBrwPCo:oPai       	:= oBrwCOB
oBrwPCo:aOrigem    	:= {"BB2_CODPSA","BB2_CODPAD"}
oBrwPCo:aRelac     	:= {"BHD_CODPSA","BHD_CODPAD"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> USUARIOS PERMITIDOS...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwUsr := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][2],aPosObj4[2][4],aPosObj4[2][3],nil  ,oFolder:aDialogs[5],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabUsr,aDadUsr,.F.,"BT1",nOpcx,"Usuarios Permitidos",nil,nil,nil,,,,,,,,,,,,,,aDifSize)
oBrwUsr:aVetTrab := aClone(aTrbUsr)
@ aPosObj4[2][3],005 CHECKBOX oChkUsr VAR lChkUsr PROMPT OemtoAnsi(STR0051) PIXEL SIZE 80, 09 OF oFolder:aDialogs[5] //"Todos os usuarios permitidos sem limite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> Carencia para novos depedentes                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBEK				:= TPLSBrw():New(aPosObj3[1,1],aPosObj3[1,2],aPosObj3[1,4],aPosObj3[1,3]*1.6,nil  ,oFldCob:aDialogs[4],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBEK,aDadBEK,.F.,"BEK",nOpcx,"Carencias p/ novos depedentes",nil,nil,nil,,,,,,,,,,,,,,aDifSize)
oBrwBEK:bLostFocus 	:= {|| cCodSeqBEK := oBrwBEK:aCols[oBrwBEK:Linha(),PLRETPOS("BEK_SEQUEN",aCabBEK,.T.)]}
oBrwBEK:aVetTrab 	:= aClone(aTrbBEK)
@ (aPosObj3[1,3]*1.7), 005 BUTTON oBotBEK PROMPT STR0039 ACTION {|| PLS800CLCR(nOpcx) } SIZE 55, 11 OF oFldCob:aDialogs[4] PIXEL //"Classe de Carencia"
oBotBEK:cTOOLTIP := OemtoAnsi(STR0039) //"Classe de Carencia"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> Carencia para novos depedentes                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBQP := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3],nil  ,oFolder:aDialogs[14],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBQP,aDadBQP,.F.,"BQP",nOpcx,"Documentos Obrigatorios",nil,nil,nil,,,,,,,,,,,,,,aDifSize)
oBrwBQP:aVetTrab := aClone(aTrbBQP)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botao para visualizacao do historico de reajuste da franquia  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtBYK, {"BUDGET",{||PL660HTFRA('2',	"BYK",M->BI3_CODINT,;
													M->BI3_CODIGO,;
													M->BI3_VERSAO)},;
													"Historico de reajuste da franquia","Historico"})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> Carencia p/ Tipo de Internacao                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBYK:= 	TPLSBrw():New(aPosObj3[1,1],aPosObj3[1,2],aPosObj3[1,4],aPosObj3[1,3]*1.8,nil  ,oFldCob:aDialogs[5],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBYK		,aDadBYK	,.F.,"BYK",nOpcx,"Propriedades por Tipo de Internacao"	,nil,nil,nil,nil,"PlsVldBYK",,nil,,aButtBYK,,,,,,,,aDifSize)
oBrwBYK:bLostFocus := {|| M->BI3_INFCOB := If(oBrwBYK:VerExiData(),"1","0"), lRefresh := .T. }
oBrwBYK:aVetTrab := aClone(aTrbBYK)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> Grupo de Carencia...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBAY:= TPLSBrw():New(aPosObj3[1,1],aPosObj3[1,2],aPosObj3[1,4],aPosObj3[1,3],nil  ,oFldCob:aDialogs[6],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBAY,aDadBAY,.F.,"BAY",nOpcx,"Grupo de Carencia",nil,nil,nil,,,,,,,,,,,,,,aDifSize)
oBrwBAY:bLostFocus := {|| cGruCarSel := oBrwBAY:aCols[oBrwBAY:Linha(),oBrwBAY:PlRetPos("BAY_CODGRU")] }
oBrwBAY:bChange    := {||Eval(oBrwBAY:bLostFocus),oBrwBAE:ForceRefresh(oBrwBAY)}
oBrwBAY:aVetTrab   := aClone(aTrbBAY)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> Classe de Carencia...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBAN:= TPLSBrw():New(aPosObj3[1,1],aPosObj3[1,2],aPosObj3[1,4],aPosObj3[1,3]*1.8,nil  ,oFldCob:aDialogs[7],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBAN,aDadBAN,.F.,"BAN",nOpcx,"Classe de Carencia",nil,nil,nil,,,,,,,,,,,,,,aDifSize)
oBrwBAN:aVetTrab := aClone(aTrbBAN)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> Grupo de Carencia x Classe de Carencia                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter   := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BAE_CODGRU",aHeader)]==cGruCarSel }
oBrwBAE:= TPLSBrw():New(aPosObj3[2,1],aPosObj3[2,2],aPosObj3[2,4],aPosObj3[2,3]-20,nil  ,oFldCob:aDialogs[6],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBAE,aDadBAE,.F.,"BAE",nOpcx,"Classe de Carencia",nil,nil,nil,aTrbBAE,,,bFilter,,,,,,,,,,aDifSize)
oBrwBAE:bChange    := { || Eval(oBrwBAY:bLostFocus) }
oBrwBAE:oPai       := oBrwBAY
oBrwBAE:aOrigem    := {"BAY_CODGRU"}
oBrwBAE:aRelac     := {"BAE_CODGRU"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> Tipo de prestador                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetBCU:= TPLSBrw():New(aPosObj3[1,1],aPosObj3[1,2],aPosObj3[1,4],aPosObj3[1,3],nil  ,oFldCob:aDialogs[8],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBCU,aDadBCU,.F.,"BCU",nOpcx,"Tipo de Prestador",nil,nil,nil,nil,,,,,,,,,,,,,aDifSize)
oGetBCU:bLostFocus := {|| cTipPre := oGetBCU:aCols[oGetBCU:Linha(),oGetBCU:PlRetPos("BCU_TIPPRE")] }
oGetBCU:bChange    := {||Eval(oGetBCU:bLostFocus),oGetBCW:ForceRefresh(oGetBCU)}
oGetBCU:aVetTrab   := aClone(aVetBCU)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botao para visualizacao do historico de reajuste da franquia  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtBCW, {"BUDGET",{||PL660HTFRA('2',"BCW",M->BI3_CODINT,;
														M->BI3_CODIGO,;
														M->BI3_VERSAO)},;
														"Historico de reajuste da franquia","Historico"})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> Tipo de Prestador - Co-participacao                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter   := {|nLine,aCols,aHeader|GdFieldGet("BCW_TIPPRE",nLine,,aHeader,aCols)==cTipPre }
oGetBCW:= TPLSBrw():New(aPosObj3[2,1],aPosObj3[2,2],aPosObj3[2,4],aPosObj3[2,3]-20,nil  ,oFldCob:aDialogs[8],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBCW,aDadBCW,.F.,"BCW",nOpcx,"Tipo de Prestador - Co-Participacao",nil,nil,nil,aVetBCW,'PlsVldBCW',,bFilter,,aButtBCW,,,,,,,,aDifSize)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> Municipios de Atendimento                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetBCZ:= TPLSBrw():New(aPosObj3[1,1],aPosObj3[1,2],aPosObj3[1,4],aPosObj3[1,3],nil  ,oFldCob:aDialogs[9],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBCZ,aDadBCZ,.F.,"BCZ",nOpcx,"Municipios de Atendimento",nil,nil,nil,nil,,,,,,,,,,,,,aDifSize)
oGetBCZ:bLostFocus := {|| cCodMun := oGetBCZ:aCols[oGetBCZ:Linha(),oGetBCZ:PlRetPos("BCZ_CODMUN")] }
oGetBCZ:bChange    := {||Eval(oGetBCZ:bLostFocus),oGetBGD:ForceRefresh(oGetBCZ)}
oGetBCZ:aVetTrab := aClone(aVetBCZ)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> Municipios de Atendimento - Co-participacao              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter   := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BGD_CODMUN",aHeader)]==cCodMun }
oGetBGD:= TPLSBrw():New(aPosObj3[2,1],aPosObj3[2,2],aPosObj3[2,4],aPosObj3[2,3]-20,nil  ,oFldCob:aDialogs[9],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBGD,aDadBGD,.F.,"BGD",nOpcx,"Municipios de Atendimento - Co-Participacao",nil,nil,nil,aVetBGD,'PlsVldBGD',,bFilter,,,,,,,,,,aDifSize)
Eval(oGetBCZ:bChange)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> GRUPO DE COBERTURA...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwGru := TPLSBrw():New(aPosObj3[1,1],aPosObj3[1,2],aPosObj3[1,4],aPosObj3[1,3],nil  ,oFldCob:aDialogs[1],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabGru,aDadGru,.F.,"BRV",nOpcx,"Grupo de Coberturas",nil,nil,nil,,,,,,,,,,,,,,aDifSize)
oBrwGru:bLostFocus := { || M->BI3_INFGCB := If(oBrwGru:VerExiData(),"1","0"),cCodGru := oBrwGru:aCols[oBrwGru:Linha(),oBrwGru:PlRetPos("BRV_CODGRU",aCabGru)] , lRefresh := .T. }
oBrwGru:bChange    := { || cCodGru := oBrwGru:aCols[oBrwGru:Linha(),oBrwGru:PlRetPos("BRV_CODGRU",aCabGru)], oBrwGCo:ForceRefresh(oBrwGru)  }
oBrwGru:aVetTrab := aClone(aTrbGru)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botao para visualizacao do historico de reajuste da franquia  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtBHI, {"BUDGET",{||PL660HTFRA('2',"BHI",M->BI3_CODINT,;
														M->BI3_CODIGO,;
														M->BI3_VERSAO)},;
														"Historico de reajuste da franquia","Historico"})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> GRUPO DE COBERTURA X COPARTICIPACAO                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nInd := 0
bFilter := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BHI_CODGRU",aHeader)] == cCodGru }
oBrwGCo := TPLSBrw():New(aPosObj3[2,1],aPosObj3[2,2],aPosObj3[2,4],aPosObj3[2,3]-20,nil  ,oFldCob:aDialogs[1],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabGCo,aDadGCo,.F.,"BHI",nOpcx,"Grupo de Coberturas x Co-participacao  "+Str(nInd++),nil,nil,nil,aTrbGCo,'PlsVldBHI',nil,bFilter,,aButtBHI,,,,,,,,aDifSize)
oBrwGCo:oPai     := oBrwGru
oBrwGCo:aOrigem  := {"BRV_CODGRU"}
oBrwGCo:aRelac   := {"BHI_CODGRU"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> PRODUTO     X Situacoes Adversas                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwSit := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3], nil  ,oFolder:aDialogs[11], nil , nil , nil ,nil   ,nil, .T.   , nil ,.T.   ,nil   ,aCabSit,aDadSit,.F.,"BGZ",nOpcx,"Situacoes Adversas",nil,nil,nil,,,,,,,,,,,,,,aDifSize)
oBrwSit:aVetTrab := aClone(aTrbSit)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> PRODUTO     X COBRANCA DE IDENTIFICACAO DE USUARIO      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBJB := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3], nil  ,oFolder:aDialogs[10], nil , nil , nil ,nil   ,nil, .T.   , nil ,.T.   ,nil   ,aCabBJB,aDadBJB,.F.,"BJB",nOpcx,"Cobranca de Identificacao de Usuario",nil,nil,nil,,,,,,,,,,,,,,aDifSize)
oBrwBJB:cVldLine := 'PLSXANAFAI( { "BJB_MOTIVO","BJB_TIPUSR","BJB_GRAUPA" },"BJB_EMIDE","BJB_EMIATE",n)'
oBrwBJB:aVetTrab := aClone(aTrbBJB)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botao para visualizacao do historico de reajuste da franquia  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtBHJ, {"BUDGET",{||PL660HTFRA('2',"BHJ",M->BI3_CODINT,;
														M->BI3_CODIGO,;
														M->BI3_VERSAO)},;
														"Historico de reajuste da franquia","Historico"})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> CO-PARTICIPACAO ...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwCoPar := TPLSBrw():New(aPosObj3[1,1],aPosObj3[1,2],aPosObj3[1,4],aPosObj3[1,3]*1.8,nil  ,oFldCob:aDialogs[3]	,nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabCoPar,aDadCoPar	,.F.,"BHJ",nOpcx,"Co-participacao",nil,nil,nil,nil	 ,'PlsVldBHJ',,nil    ,,aButtBHJ,,,,,,,,aDifSize)
oBrwCoPar:aVetTrab := aClone(aTrbCoPar)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> VALORES DE ADESAO...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwAde				:= TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][2],aPosObj4[2][4],aPosObj4[2][3],nil  ,oFolder:aDialogs[7],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabAde,aDadAde,.F.,"BJ9",nOpcx,"Valores de Adesao",nil,nil,nil,nil,nil,"PLSM800Del(" + Str(nOpcx, 1) + ",2)",,,,,,,,,,,aDifSize)
oBrwAde:aVetTrab 	:= aClone(aTrbAde)
oBrwAde:bChange  	:= {|| If(oBrwAde:IsDeleted(oBrwAde:Linha()),oBotAde:Disable(), oBotAde:Enable()) }
oBrwAde:bLostFocus  := {|| Eval(oBrwAde:bChange) }

@ aPosObj4[2][3], 005 BUTTON oBotAde PROMPT STR0057 ACTION {|| PLSA800For(nOpcx,2) } SIZE 45, 11 OF oFolder:aDialogs[7] PIXEL //"Propriedades"
oBotAde:cTOOLTIP := OemtoAnsi(STR0052) //"Propriedades da Forma de Cobranca"

@ aPosObj4[2][3], 055 BUTTON oBotAd1 PROMPT STR0047 ACTION {|| PLSHISFAI("BK1",PlsIntPad()+M->(BI3_CODIGO+BI3_VERSAO),"BK1->(BK1_FILIAL+BK1_CODOPE+BK1_CODPRO+BK1_VERSAO)",1) } SIZE 45, 11 OF oFolder:aDialogs[7] PIXEL //"Historicos"
oBotAd1:cTOOLTIP := OemtoAnsi(STR0047) //"Historicos"

@ aPosObj4[2][3],105 SAY oSay PROMPT OemtoAnsi(STR0053)  SIZE 220,010 OF oFolder:aDialogs[7] PIXEL //"Valor Limite Taxa Adesao :"
@ aPosObj4[2][3],180 MSGET nLimTXA SIZE 050,008 OF oFolder:aDialogs[7] PIXEL PICTURE "@E 999,999,999.99"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> PRODUTOS Vinculados...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 009, aPosObj3[1][4]*0.9 BUTTON oBotForOpc PROMPT STR0057 ACTION {|| 	nPosBT3 := oBrwPro:Linha(),;
														PLSA800For(nOpcx,3),;
														Eval(oBrwPro:bChange),;
														oBrwPRO:oBrowse:oBrowse:SetFocus(),;
														oBrwPRO:SetPos(nPosBT3)} SIZE 45, 11 OF oFolder:aDialogs[8] PIXEL //"Propriedades"
oBotForOpc:cTOOLTIP := OemtoAnsi(STR0046) //"Propriedades da Forma de Cobranca"

@ aPosObj3[2][3]*0.9, 005 BUTTON oBotOp1 PROMPT STR0047 ACTION {|| PLSHISFAI("BK9",(PlsIntPad()+M->(BI3_CODIGO+BI3_VERSAO)+cCodPla+cVerPla),"BK9->(BK9_FILIAL+BK9_CODOPE+BK9_CODPRO+BK9_VERSAO+"+"BK9_CODOPC+BK9_VEROPC)",1) } SIZE 45, 11 OF oFolder:aDialogs[8] PIXEL //"Propriedades"
oBotOp1:cTOOLTIP := OemtoAnsi(STR0047) //"Propriedades da Forma de Cobranca"

oBrwPro 			:= TPLSBrw():New(aPosObj3[1][1],aPosObj3[1][2],aPosObj3[1][4]*0.85,aPosObj3[1][3],nil  ,oFolder:aDialogs[8],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabPro,aDadPro,.F.,"BT3",nOpcx,"Produtos Relacionados",nil,nil,nil,aTrbPro,"PLS800PRO","PLSM800Del(" + Str(nOpcx, 1) + ",3)",,,,,,,,,,,aDifSize)
oBrwPro:bLostFocus 	:= {|| cCodPla := oBrwPro:aCols[oBrwPro:Linha(),oBrwPro:PlRetPos("BT3_CODPLA")] ,cVerPla := oBrwPro:aCols[oBrwPro:Linha(),oBrwPro:PlRetPos("BT3_VERPLA")], Eval(oBrwPFai:bChange)}
oBrwPro:bChange := {|| Eval(oBrwPFai:bChange), Eval(oBrwPro:bLostFocus),oBrwPFai:ForceRefresh(oBrwPro),oBrwFPA:ForceRefresh(oBrwPro)}
cCodPla 		:= GdFieldGet("BT3_CODPLA",1,nil,oBrwPro:aHeader,oBrwPro:aCols)
cVerPla 		:= GdFieldGet("BT3_VERPLA",1,nil,oBrwPro:aHeader,oBrwPro:aCols)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> PRODUTOS Vinculados x Forma de Cobranca                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter  			:= {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BJY_CODOPC",aHeader)] == cCodPla .And. aCols[nLine,GdFieldPos("BJY_VEROPC",aHeader)] == cVerPla }

oBrwPFai 			:= TPLSBrw():New(aPosObj3[2][1],aPosObj3[2][2],aPosObj3[2][4],aPosObj3[2][3]*0.85,nil  ,oFolder:aDialogs[8],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabPFai,aDadPFai,.F.,"BJY",nOpcx,"Produtos Relacionados x Forma de Cobranca",nil,nil,nil,aTrbPFai,nil,"PLSM800Del(" + Str(nOpcx, 1) + ",3)",bFilter,,,,,,,,,,aDifSize)
oBrwPFai:bChange  	:= { ||	(If(oBrwPro:aCols[oBrwPro:Linha(),oBrwPro:PlRetPos("BT3_TIPVIN")]=="0" .And. ! oBrwPro:IsDeleted(oBrwPro:Linha()),oBrwPFai:OBROWSE:OBROWSE:LREADONLY := .F. ,oBrwPFai:OBROWSE:OBROWSE:LREADONLY := .T.),;
							If(oBrwPFai:IsDeleted(oBrwPFai:Linha()) .Or. oBrwPro:aCols[oBrwPro:Linha(),oBrwPro:PlRetPos("BT3_TIPVIN")]=="1",;
							oBotForOpc:Disable(), oBotForOpc:Enable())) }
oBrwPFai:bLostFocus := { || Eval(oBrwPFai:bChange) }
oBrwPFai:oPai     	:= oBrwPro
oBrwPFai:aOrigem  	:= {"BT3_CODPLA","BT3_VERPLA"}
oBrwPFai:aRelac   	:= {"BJY_CODOPC","BJY_VEROPC"}
Eval(oBrwPro:bLostFocus)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> Rede Referenciada  ...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwFPa := TPLSBrw():New(aPosObj3[1][1],aPosObj3[1][2],aPosObj3[1][4],aPosObj3[1][3],nil  ,oFolder:aDialogs[9],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabFPA,aDadFPA,.F.,"BT4",nOpcx,"Rede Referenciada",nil,nil,nil,aTrbFPa,,,,,,,,,,,,,aDifSize)
oBrwFPa:bLostFocus 	:= { || cCodRda := oBrwFPa:aCols[oBrwFPa:Linha(),oBrwFPa:PlRetPos("BT4_CODCRE")],cCodPla := M->BI3_CODIGO,cVerPla := M->BIL_VERSAO }
oBrwFPa:bGotFocus   := {|| cCodRda := oBrwFPa:aCols[oBrwFPa:Linha(),oBrwFPa:PlRetPos("BT4_CODCRE")],cCodPla := M->BI3_CODIGO,cVerPla := M->BIL_VERSAO,oBrwB61:ForceRefresh(oBrwFPa),oBrwB86:ForceRefresh(oBrwFPa)}
oBrwFPa:bChange    	:= { || Eval(oBrwFPa:bLostFocus),oBrwB61:ForceRefresh(oBrwFPa),oBrwB86:ForceRefresh(oBrwFPa) }
// Folder Para complementos da rede referenciada.
@ aPosObj3[2][1],aPosObj3[2][2] FOLDER oFolRRef SIZE aPosObj3[2][4] ,aPosObj3[2][3]OF oFolder:aDialogs[9] PIXEL PROMPTS	OemtoAnsi("Desc Faixa Pagto/RDA"),;
																																			OemtoAnsi("Rede Ref X Co-Part")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desc Faixa Rede Referenciada/ Produto		                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter  				:= {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("B61_CODRDA",aHeader)] == cCodRda ;
										  .And. aCols[nLine,GdFieldPos("B61_VERSAO",aHeader)] == cVerPla ;
										  .And. aCols[nLine,GdFieldPos("B61_CODPLA",aHeader)] == cCodPla ;
										  .And. aCols[nLine,GdFieldPos("B61_DESPLA",aHeader)] == cDesRda }
oBrwB61				:= TPLSBrw():New(5,5,aPosObj3[2][4],aPosObj3[2][3]/3,nil  ,oFolRRef:aDialogs[1], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabB61,aDadB61,.F.,"B61",nOpcx,"Desc Faixa Pagto/RDA",nil,nil,nil,aTrbB61,,,bFilter,,,,,,,,,,aDifSize)
oBrwB61:cVldLine    	:= 'PlsVldDfe("B61",.F.,Nil,oBrwB61)'
oBrwB61:bGotFocus   := {|| oBrwB61:ForceRefresh(oBrwB61)}
oBrwB61:oPai			:= oBrwFPa
oBrwB61:aOrigem    	:= {"BT4_CODCRE","BT4_CODIGO","BT4_VERSAO"}
oBrwB61:aRelac     	:= {"B61_CODRDA","B61_CODPLA","B61_VERSAO"}

bFilter				:= {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("B86_CODRDA",aHeader)] == cCodRda .And. aCols[nLine,GdFieldPos("B86_VERSAO",aHeader)] == cVerPla }
oBrwB86				:= TPLSBrw():New(5,5,aPosObj3[2][4],aPosObj3[2][3]/3,nil  ,oFolRRef:aDialogs[2], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabB86,aDadB86,.F.,"B86",nOpcx,"Rede Ref X Co-Part",nil,nil,nil,aTrbB86,'PlsVldB86' ,,bFilter)
oBrwB86:oPai			:= oBrwFPa
oBrwB86:aOrigem		:= {"BT4_CODIGO","BT4_VERSAO","BT4_CODCRE"}
oBrwB86:aRelac		:= {"B86_CODIGO","B86_VERSAO","B86_CODRDA"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> Parametros Pagamento...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwPPg  				:= TPLSBrw():New(aPosObj3[1][1],aPosObj3[1][2],aPosObj3[1][4],aPosObj3[1][3],nil  ,oFolder:aDialogs[13], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabPPg,aDadPPg,.F.,"BMD",nOpcx,"Parametros Pagamento",nil,nil,nil,aTrbPPg,'PL800BMD()',,,,,,,,,,,,aDifSize)
oBrwPPg:bLostFocus 	:= { || cTipPreSel := oBrwPPg:aCols[oBrwPPg:Linha(),oBrwPPg:PLRETPOS("BMD_TIPPRE")] }
oBrwPPg:bChange    	:= { || Eval(oBrwPPg:bLostFocus),oBrwPPP:ForceRefresh(oBrwPPg) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> Parametros Pagamento X Procedimento...                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter  			:= {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BME_TIPPRE",aHeader)] == cTipPreSel }
oBrwPPP  			:= TPLSBrw():New(aPosObj3[2][1],aPosObj3[2][2],aPosObj3[2][4],aPosObj3[2][3],nil  ,oFolder:aDialogs[13], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabPPP,aDadPPP,.F.,"BME",nOpcx,"Parametros Pagamento  X Procedimentos",nil,nil,nil,aTrbPPP,'PLVldBME()',,bFilter,,,,,,,,,,aDifSize)
oBrwPPP:oPai       	:= oBrwPPg
oBrwPPP:aOrigem    	:= {"BMD_TIPPRE"}
oBrwPPP:aRelac     	:= {"BME_TIPPRE"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> Tip.Lanc X FAIXA DESCONTO								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBKJ := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3],nil  ,oFolder:aDialogs[15],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBKJ,aDadBKJ,.F.,"BKJ",nOpcx,"Faixa Desc. X Tip.Lanc",nil,nil,nil,,,,,,,,,,,,,,aDifSize)
oBrwBKJ:aVetTrab := aClone(aTrbBKJ)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> Produto x Regiao         								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBY9 := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3],nil  ,oFolder:aDialogs[16],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBY9,aDadBY9,.F.,"BY9",nOpcx,"Produto x Região",nil,nil,nil,,,,,,,,,,,,,,aDifSize)
oBrwBY9:aVetTrab := aClone(aTrbBY9)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> PROD. X FATORES MULTIP. REEMB.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwB31					:= TPLSBrw():New(aPosObj3[1][1],aPosObj3[1][2],aPosObj3[1][4],aPosObj3[1][3],nil  ,oFolder:aDialogs[17], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabB31,aDadB31,.F.,"B31",nOpcx,"Produto x Fatores de Reembolso",nil,nil,nil,aTrbB31,,,,,,,,,,,,,aDifSize)
oBrwB31:cVldLine		:= 'PLSVLDGD( {"B31_CLASSE","B31_SEQUEN","B31_INTEXT","B31_TIPATE"} )'
oBrwB31:bLostFocus	:= {|| cCodSeqB31 := oBrwB31:aCols[oBrwB31:Linha(),PLRETPOS("B31_SEQUEN",aCabB31,.T.)], cTipClasse := oBrwB31:aCols[oBrwB31:Linha(),oBrwB31:PLRETPOS("B31_CLASSE")] }
oBrwB31:bChange		:= {|| Eval(oBrwB31:bLostFocus),oBrwB32:ForceRefresh(oBrwB31) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> VIG. PROD. X FAT. MULT. REEMB                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter				:= {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("B32_CLASSE",aHeader)] == cTipClasse .And.	aCols[nLine,GdFieldPos("B32_SEQUEN",aHeader)] == cCodSeqB31  }
oBrwB32				:= TPLSBrw():New(aPosObj3[2][1],aPosObj3[2][2],aPosObj3[2][4],aPosObj3[2][3],nil  ,oFolder:aDialogs[17], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabB32,aDadB32,.F.,"B32",nOpcx,"Perído Prod. x Fat de Reemb",nil,nil,nil,aTrbB32,,,bFilter,,,,,,,,,,aDifSize)
oBrwB32:cVldLine		:= 'PLSXANAFAI( { "B32_CLASSE","B32_SEQUEN" },"B32_ADEINI","B32_ADEFIM",n)'
oBrwB32:oPai			:= oBrwB31
oBrwB32:aOrigem		:= {"B31_SEQUEN","B31_CLASSE"}
oBrwB32:aRelac		:= {"B32_SEQUEN","B32_CLASSE"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desc Fx Evento Pagto		   	                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwB60 				:= TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3],nil  ,oFolder:aDialogs[18],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabB60,aDadB60,.F.,"B60",nOpcx,"Faixa Desc.Pagto",nil,nil,nil,,,,,,,,,,,,,,aDifSize)
oBrwB60 :aVetTrab 	:= aClone(aTrbB60)
oBrwB60 :cVldLine		:= 'PlsVldDfe("B60",.F.,Nil,oBrwB60)'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,bOK,bCancel,.F.,{})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata atualizacao dos dados...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
	GravaProd(nReg,nOpc,_nH)
	If nOpc == K_Excluir .and. !Empty(cVerAnt)
	   BIL->(DbSetOrder(1))
	   BIL->(MsSeek(xFilial()+cChave+cVerAnt))
	   BIL->(RecLock("BIL"))
	   BIL->BIL_DATFIN := CtoD("")
	   BIL->(MsUnlock())
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Refaz filtro para mBrowse...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("BI3")
SET FILTER TO &cFiltro
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no plano selecionado...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir
	BI3->(DbGoTo(nRegOld))
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PLS800PRO
Valida a inclusao do Produto Vinculado

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLS800PRO

If M->BT3_TIPVIN == "0"
	oBrwPFai:OBROWSE:OBROWSE:LREADONLY := .F.
Endif

Return(.T.)
//-------------------------------------------------------------------
/*/{Protheus.doc} A800MOPC
Monta as opcoes (alias) para uma Forma de Cobranca

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Static Function A800MOpc(cCodFor)
aOpcoes := {}
BJ2->(DbSetOrder(1))
If BJ2->(MsSeek(xFilial("BJ2")+cCodFor+"1"))
	While ! BJ2->(Eof()) .And. BJ2->(BJ2_FILIAL+BJ2_CODIGO+BJ2_USO) == xFilial("BJ2")+cCodFor+"1"
		aadd(aOpcoes,{ AllTrim(BJ2->BJ2_DESCRI) , BJ2->BJ2_ALIAS, BJ2->BJ2_TIPO, BJ2->BJ2_BFILT, BJ2->BJ2_EXPF, BJ2->BJ2_APLREJ = "1", BJ2->BJ2_EXPREF })
		BJ2->(DbSkip())
	Enddo
Endif
Return(aOpcoes)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA800For
Edita uma Forma de Cobranca

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSA800For(nOpcx,nTipo,lTabAnt)
Local I__f := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL cDescri 	:= ""
Local nInd,nCont,nTr,nFields
LOCAL oDlgFor
LOCAL aCampos  	:= {}
LOCAL oEnc
LOCAL cAlias
LOCAL oFld
LOCAL aOpcoes  	:= {}
LOCAL aTitles  	:= {}
LOCAL aVetTemp 	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cOldCad  	:= cCadastro
LOCAL aOldTela 	:= aTela
LOCAL aOldGets 	:= aGets
LOCAL nOldOpc  	:= nOpca
LOCAL nOpca    	:= 0
LOCAL cOldAlias	:= Alias()
LOCAL nI
LOCAL aTiles   	:= {}
LOCAL aPages   	:= {}
LOCAL nControl 	:= 0
LOCAL aSizeAut 	:= MsAdvSize()
LOCAL cMala    	:= Space(01)
LOCAL cVar
LOCAL aOldCols  := aClone(aCols)
LOCAL aOldHeader:= aClone(aHeader)
LOCAL nOld      := n
LOCAL lFiltro
LOCAL bFilter
Local lDelLin	:= .F.
Local aCpoObri	:= {}, lDigitou := .F.
Local nObrig 	:= nOk := 0
Local aButtons 	:= 	{}
Local cChave	:= ""
Local lOlInclui := INCLUI
Local aSize 	:= MsAdvSize()
Local aObjects 	:= {}
Local aInfo 	:= {}
Local aPosObj
LOCAL _aAuxTrb	:= {}

DEFAULT nTipo 	:= 1
DEFAULT ltabAnt := .F.

Private cCodFor := ""
Private oPriBro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Codigo e Descricao da Forma atual...                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if nTipo ==1
	aVetTemp := AClone(aVetsFor)
	cCodFor  := oBrwFor:aCols[oBrwFor:Linha(),oBrwFor:PLRETPOS("BJ3_CODFOR")]
	cDescri  := oBrwFor:aCols[oBrwFor:Linha(),oBrwFor:PLRETPOS("BJ3_DESFOR")]
Elseif nTipo ==2
	aVetTemp := AClone(aVetsTxF)
	cCodFor  := oBrwAde:aCols[oBrwAde:Linha(),oBrwAde:PLRETPOS("BJ9_CODFOR")]
	cDescri  := oBrwAde:aCols[oBrwAde:Linha(),oBrwAde:PLRETPOS("BJ9_DESFOR")]
Elseif nTipo ==3
	aVetTemp := AClone(aVetsOpc)
	cCodFor  := oBrwPFai:aCols[oBrwPFai:Linha(),oBrwPFai:PLRETPOS("BJY_CODFOR")]
	cDescri  := oBrwPFai:aCols[oBrwPFai:Linha(),oBrwPFai:PLRETPOS("BJY_DESFOR")]
	cChave	 := cCodPla + cVerPla
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aCols    := {}
PRIVATE aHeader  := {}
PRIVATE n        := 1
PRIVATE aSvaTela := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa preenchimento da linha...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if nTipo == 1
	If ! oBrwFor:LinhaOK()
		Return
	Endif
Elseif nTipo == 2
	If ! oBrwAde:LinhaOK()
		Return
	Endif
Else
	If ! oBrwPFai:LinhaOK()
		Return
	Endif
Endif

BJ1->(MsSeek(xFilial("BJ1") + cCodFor))

// Incrementa vetor de objetos disponiveis na tela.
AAdd( aObjects, { 100, 200, .T., .T. } )
AAdd( aObjects, { 200, 100, .T., .T.,.T. } )

// Define tamanhos de acordo com a resolucao da tela do client
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgFor TITLE OemtoAnsi(STR0056) + " " + cCodFor+" - "+AllTrim(cDescri)+" - "+OemtoAnsi(STR0057) FROM aSize[7],0 To aSize[6],aSize[5] OF oDlgFolder PIXEL  //"Forma de Cobranca "###" - Propriedades"
cMala := Space(01)
@ 10000,2000 GET cMala PICTURE "@!" PIXEL OF oDlgFor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o folder de acordo com a quantidade de objetos...              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aOpcoes := A800MOpc(cCodFor)

SetEnch("")
For nI := 1 to Len(aOpcoes)
	Aadd(aTitles,OemtoAnsi(aOpcoes[nI,1]))
	Aadd(aPages,"HEADER "+Trim(Str(nI,2)))
	nControl++
Next

oFld := TFolder():New(30,0,aTitles,aPages,oDlgFor,,,,.T.,.F.,aPosObj[2][3],aPosObj[2][4]+15)
oFld:bChange := {|nFolder| PL260FORREFR(nFolder, 7, aOpcoes) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Objetos...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nI := 1 To Len(aOpcoes)
	cAlias  := aOpcoes[nI,2]
	cTipo   := aOpcoes[nI,3]
	cTit    := aOpcoes[nI,1]
	lFiltro := IF(aOpcoes[nI,4]=="1",.T.,.F.)
	bFilter := AllTrim(aOpcoes[nI,5])

	aHeader := {}
	aCols   := {}
	DbSelectArea(cAlias)

	cBrw := "oBrw"+cAlias

	STORE HEADER cAlias TO aHeader For .T.

	lFlag := .F.
	For nInd := 1 To Len(aVetTemp)
		If aVetTemp[nInd,1] == cCodFor .And. aVetTemp[nInd,2] == cAlias
			lFlag := .T.
			If cTipo == "0" // Enchoice
				aVetTrab := aVetTemp[nInd,4]
				_aAuxTrb := aVetTemp[nInd,5]
				For nCont  := 1 To Len(aVetTrab)
					cDado  := aVetTrab[nCont,1]
					&cDado := aVetTrab[nCont,2]
				Next
			ElseIf cTipo == "1" // GetDados
				aTrab := aVetTemp[nInd,4]
				_aAuxTrb := aVetTemp[nInd,5]
				For nTr := 1 To Len(aTrab)
					if nTipo == 3
						if 	aTrab[nTr,GdFieldPos(cAlias+"_CODOPC",aHeader)] == cCodPla .AND.;
							aTrab[nTr,GdFieldPos(cAlias+"_VEROPC",aHeader)] == cVerPla
							aadd(aCols,AClone(aTrab[nTr]))
						Endif
					Else
						aadd(aCols,AClone(aTrab[nTr]))
					Endif
				Next
			Endif
		Endif
	Next

	If ! lFlag .OR. (cTipo == "1" .And. Len(aCols) <= 0)
		INCLUI := .T.
		If cTipo == "0" // Enchoice
			cAlias := aOpcoes[nI,2]
			COPY cAlias To Memory Blank
		ElseIf cTipo == "1" // GetDados
			STORE COLS Blank cAlias TO aCols FROM aHeader
		Endif
		INCLUI := lOlInclui
	Endif

	If cTipo == "0" // Enchoice
		aTela := {}
		aGets := {}
		cVar  := "aSvaTela["+AllTrim(Str(Len(aSvaTela)+1))+"]"
		aadd(aSvaTela,{})
		&cBrw := MsMGet():New(cAlias,0,nOpcx,,,,,aPosObj[1],,,,,,oFld:aDialogs[nI],,,.F.,cVar)
		aSvaTela[len(aSvaTela)] = aClone(aTela)
	ElseIf cTipo == "1" // GetDados
		lDelLin := aCols[1][Len(aCols[1])]
		aCols[1][Len(aCols[1])] := .F.
		&cBrw := TPLSBrw():New(005,005,aPosObj[2][3]-15,aPosObj[2][4],nil  ,oFld:aDialogs[nI],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,cAlias,nOpcx,cTit,nil,nil,nil,_aAuxTrb,"PL660VldLn('BB3','"+cCodfor+"')",,IF(lFiltro,&bFilter,Nil),,,,,,,,,,aDifSize)
		&cBrw:Cargo := aOpcoes[nI,6]
		If oPriBro = Nil .And. lDelLin .And. N = 1
			oPriBro := &cBrw
		Endif
		&cBrw:aCols[1][Len(aCols[1])] := lDelLin
		&cBrw:Cargo := lTabAnt
		if !lFiltro
			&cBrw:Atualiza()
		endif
	Endif
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLS800FG")
   ExecBlock("PLS800FG",.F.,.F.)
Endif

ACTIVATE MSDIALOG oDlgFor ON INIT   (If(oPriBro <> Nil, (oPriBro:oBrowse:oBrowse:SetFocus(), oPriBro:ForceRefresh(oPriBro)), .T.),;
									EnchoiceBar(oDlgFor,{|| PlsEndBrw(),nOpca := 1,oDlgFor:End()},{|| PlsEndBrw(),nOpca := 2,oDlgFor:End()},,aButtons))

aCols     := aClone(aOldCols)
aHeader   := aClone(aOldHeader)
n         := nOld
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza dados dos vetores...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
	For nI := 1 To Len(aOpcoes)

		cAlias := aOpcoes[nI,2]
		DbSelectArea(cAlias)
		cTipo  := aOpcoes[nI,3]
		cTit   := aOpcoes[nI,1]

		nPos := Ascan(aVetTemp,{|x| x[1]+x[2] == cCodFor+cAlias})
		nTemp := 0
		If nTipo = 3
			If nPos > 0
				if cTipo == "1"
					nTemp := Ascan(aVetTemp,{|x| x[1]+x[2] == cCodFor+cAlias .and. x[6] == cChave })
					if nTemp > 0
						nPos := nTemp
					Else
						nPos := 0
					Endif
				Endif
			Endif
		Endif

		If cTipo == "0" // Enchoice
		ElseIf cTipo == "1" // GetDados
			cBrw     := "oBrw"+cAlias
			aCols    := AClone(&(cBrw):aCols)
			aHeader  := AClone(&(cBrw):aHeader)
			_aAuxtrb := aClone((&(cBrw):aVetTrab))
			lDigitou := .F.

            If Len(aCols) = 1
				aCpoObri := {}
				SX3->(DbSetOrder(2))
				For nInd := 1 To Len(aHeader)
       				If SX3->(MsSeek(AllTrim(aHeader[nInd,2])))
         				If SX3->X3_CONTEXT <> "V"
       		     			If X3Obrigat(SX3->X3_CAMPO) 
				            	aadd(aCpoObri,AllTrim(aHeader[nInd,2]))
		        	    	Endif
				    	Endif
					EndIf
				Next
				For nCont := 1 To Len(aCols)
				    nObrig := nOk := 0
				    For nFields := 1 To Len(aHeader)
			    		If Ascan(aCpoObri, AllTrim(aHeader[nFields][2])) > 0
				    		nObrig ++
			   				If ! Empty(aCols[nCont,nFields])
		    					nOk ++
			    			Endif
			    		Endif
			    	Next
			    	lDigitou := nObrig = nOk
				Next
			Else
				lDigitou := .T.
			Endif

			lFiltro  := IF(aOpcoes[nI,4]=="1",.T.,.F.)
			If lFiltro
				A800EndFil(&(cBrw))
			Endif
		Endif

		If cTipo == "0" // Enchoice
			aCpos   := {}
			aFields := DBSTRUCT()
			For nCont := 1 To Len(aFields)
				cTrab := "M->"+aFields[nCont,1]
				cDado := &cTrab
				aadd(aCpos,{cTrab,cDado})
			Next
			If nPos == 0
				aadd(aVetTemp,{cCodFor,cAlias,cTipo,aCpos,0,"",.F.})
			Else
				aVetTemp[nPos] := {cCodFor,cAlias,cTipo,aCpos,_aAuxTrb,cChave,.F.}
			Endif
		ElseIf cTipo == "1" // GetDados
			If nPos == 0
				aadd(aVetTemp,{cCodFor,cAlias,cTipo,aCols,{},cChave,lDigitou})
			Else
				aVetTemp[nPos] := {cCodFor,cAlias,cTipo,aCols,aVetTemp[nPos][5],cChave,lDigitou}
			Endif
		Endif
	Next
	if nTipo == 1
		// Compara cadastros antes e depois da confirmação da tela para verificar se houve alteração.
		// Essa informação é utilizada para exibir ou não opção de propagação das alterações para
		// Famílias e Subcontratos.
		lHaAltFor := haAltFor(aVetsFor, aVetTemp)
		aVetsFor := AClone(aVetTemp)
	Elseif nTipo == 2
		aVetsTxF := AClone(aVetTemp)
	Else
		aVetsOpc := AClone(aVetTemp)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados gravados...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro := cOldCad
aTela     := aOldTela
aGets     := aOldGets
nOpca     := nOldOpc
DbSelectArea(cOldAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} haAltFor
Compara vetores com informações sobre Forma de Pagamento para verificar
se houve modificações.

@author  Thiago Paris
@version P12
@since   05.08.2020
/*/
//------------------------------------------------------------------- 
Static Function haAltFor(aVetAnt, aVetDep)
Local lRet := .F.
Local nI := 0
Local nJ := 0
Local nK := 0
For nI := 1 To Len(aVetAnt)
	If Len(aVetAnt[nI][4]) != Len(aVetDep[nI][4])
		Return(.T.)
	Else
		For nJ := 1 To Len(aVetAnt[nI][4])
			For nK := 1 To Len(aVetAnt[nI][4][nJ])
				If aVetAnt[nI][4][nJ][nK] != aVetDep[nI][4][nJ][nK]
					Return(.T.)
				EndIf
			Next
		Next
	EndIf
Next
Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA800Dat
Trata a data da versao do produto

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSA800Dat(cCodPla,dData)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOrdBIL := BIL->(IndexOrd())
LOCAL nRecBIL := BIL->(Recno())
LOCAL dUltDat := dData
LOCAL lRet    := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a data informada e maior que a da ultima versao...      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BIL->(DbSetOrder(1))
BIL->(MsSeek(xFilial("BIL")+cCodPla+"999",.T.))
BIL->(DbSkip(-1))

If BIL->(BIL_FILIAL+BIL_CODIGO) == xFilial("BIL")+cCodPla
	dUltDat := BIL->BIL_DATINI
	If dtos(dData) > dtos(dUltDat)
		lRet := .T.
	Endif
Else
	lRet := .T.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados salvos...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BIL->(DbSetOrder(nOrdBIL))
BIL->(DbGoTo(nRecBIL))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe help caso data seja errada...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lRet
	Help("",1,"PLSA800Dat")
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA800Ver
Verifica processo de atualizacao

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSA800Ver(cCodInt,cCodigo,cVersao,nOpcx)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lRet    := .T.
LOCAL nOrdBA3
LOCAL nRecBA3
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Se pode Excluir...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == K_Excluir .Or. nOpcx == K_Alterar
	nOrdBA3 := BA3->(IndexOrd())
	nRecBA3 := BA3->(Recno())

	BA3->(DbSetOrder(2))
	If BA3->(MsSeek(xFilial("BA3")+cCodInt+cCodigo+cVersao))
		If     nOpcx == K_Excluir
			Help("",1,"PLSA800EX")
			lRet := .F.
		ElseIf nOpcx == K_Alterar
			lRet := MsgYesNo(OemtoAnsi(STR0059)) //"Existe(m) Contrato(s) para a versao do plano que voce acabou de alterar. Confirmando a alteracao ela afetara todos os contratos relacionados. Voce confirma a alteracao da versao"
		Endif
	Endif

	BA3->(DbSetOrder(nOrdBA3))
	BA3->(DbGoTo(nRecBA3))
Endif

If lRet .And. Empty(dtos(M->BIL_DATINI))
	Help("",1,"PLSA800EX0")
	lRet := .F.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA800OK
Verifica processo de atualizacao

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSA800OK(nOpc,cChave)
LOCAL lRet    := Eval( { || PLSA800GRU() .And. oBrwFor:TudoOK() .And. PLSA800Ver(M->BI3_CODINT,M->BI3_CODIGO,M->BI3_VERSAO,nOpcx) })
LOCAL nOrdBI3 := BI3->(IndexOrd())
LOCAL lPtoEnt := ExistBlock("PLS800OK")

If lRet .And. lPtoEnt
   lRet := ExecBlock("PLS800OK",.F.,.F.)
Endif

If lRet
	If nOpc == K_Incluir
		lRet := MsgYesNo(OemtoAnsi(STR0060)) //"Confirma a inclusao dos dados do Produto Saude"

		If lRet
			BI3->(DbSetOrder(1))
			If BI3->(MsSeek(xFilial("BI3")+cChave))
				Help("",1,"JAGRAVADO")
				lRet := .F.
			Else
				_nH := PLSAbreSem("PLSA800.SMF")
			Endif
			BI3->(DbSetOrder(nOrdBI3))
		Endif
	Endif
Endif

If lRet
	If M->BI3_STATUS ='2'.and. Empty(M->BI3_DATBLO)
		Help('',1,'DATABLOQ',,STR0081,1,0)
		lRet:=.F.
	Endif
Endif

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA800GRU
Verifica se o produto e termo aditivo ou opcional para ANS

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSA800GRU()
LOCAL lRet    := .F.

If nOpcx == K_Incluir .And. Empty(dtos(M->BIL_DATINI))
	Help("",1,"PLS800GRU")
Else
	BE5->(DBSetOrder(1))
	If BE5->(MsSeek(xFilial("BE5")+M->BI3_GRUPO))
		lRet := Obrigatorio(oEncBI3:aGets,oEncBI3:aTela)
		If BE5->BE5_TIPO == "1" .And. lRet .And. M->BI3_APOSRG == "1"
			// Pesquisa os campos obrigatorios da ANS
			lRet := PLS800CAMP()

			If lRet
				If Empty(M->BI3_SUSEP) .Or. Empty(M->BI3_DTRGPR)
					Help("",1,"PLSA800ANS")
					lRet := .F.
				Endif
			Endif
		Endif
	Endif
Endif

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLS800CAMP
Verifica se os campos que sao obrigatorios da ANS estao Preenchidos

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLS800CAMP()
LOCAL lRet    := .T.

If lRet .And. Empty(M->BI3_CODSEG)
	MsgInfo(OemtoAnsi(STR0061)+Posicione("SX3",2,"BI3_CODSEG","X3_TITULO")+OemtoAnsi(STR0062)) //"O campo " " nao esta preenchido."
	lRet := .F.
Endif

If lRet .And. Empty(M->BI3_MODPAG)
	MsgInfo(OemtoAnsi(STR0061)+Posicione("SX3",2,"BI3_MODPAG","X3_TITULO")+OemtoAnsi(STR0062)) //"O campo " " nao esta preenchido."
	lRet := .F.
Endif

If lRet .And. Empty(M->BI3_APOSRG)
	MsgInfo(OemtoAnsi(STR0061)+Posicione("SX3",2,"BI3_APOSRG","X3_TITULO")+OemtoAnsi(STR0062))
	lRet := .F.
Endif

If lRet .And. Empty(M->BI3_CODACO)
	MsgInfo(OemtoAnsi(STR0061)+Posicione("SX3",2,"BI3_CODACO","X3_TITULO")+OemtoAnsi(STR0062))
	lRet := .F.
Endif

If lRet .And. Empty(M->BI3_ABRANG)
	MsgInfo(OemtoAnsi(STR0061)+Posicione("SX3",2,"BI3_ABRANG","X3_TITULO")+OemtoAnsi(STR0062))
	lRet := .F.
Endif

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA800Agr
Verifica se um produto saude pode ser agregado a outro

@author  PLS TEAM
@version P12
@since   07.12.00
@History 06/09/2019 - Função refeita devida a issue DSAUDE-9243
/*/
//------------------------------------------------------------------- 
Function PLSA800Agr()

Local aAreaBkp := GetArea()
Local lInCall  := IsInCallStack("CONPAD1") // Se a Function for chamada pela consulta padrão - True	
Local lRet

If !lInCall // Function chamada pelo VALID do SX3 - Faz busca
	BI3->(DbSetOrder(1))
	If BI3->(MsSeek(xFilial("BI3")+M->BI3_CODINT+M->BT3_CODPLA))
		M->BT3_VERPLA := BI3->BI3_VERSAO // Preencho a versão 
		BE5->(DbSetOrder(1))
		BE5->(MsSeek(xFilial("BE5")+BI3->BI3_GRUPO))	
	Else
		Help('',1,'PLSA800Agr',,STR0093,1,0) // Produto não encontrado
		lInCall := .T. // Caso não encontre o produto, não mostrar msg nao permitido agregado 
	EndIf	
Else // Function chamada pelo SXB (Consulta padrão) - Faz Filtro
	BE5->(DbSetOrder(1))
	BE5->(MsSeek(xFilial("BE5")+BI3->BI3_GRUPO))	
EndIf

lRet := IF(BE5->BE5_PERAGR=="1" .Or. BE5->BE5_PEROPC=="1",.T.,.F.)

If !lRet .AND. !lInCall
	Help('',1,'PLSA800Agr',,STR0094,1,0) // Produto não permitido ser agregado a outro produto
EndIf

RestArea(aAreabkp) 

Return(lRet) 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA800Leg
Exibe a legenda

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSA800Leg()
Local aLegenda := {}

aLegenda := { 	{ aCdCores[1,1],aCdCores[1,2] },;
					{ aCdCores[2,1],aCdCores[2,2] },;
					{ aCdCores[3,1],aCdCores[3,2] } }

BrwLegenda(cCadastro,"Status",aLegenda)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA800Opc


@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSA800Opc(cGrupo)

LOCAL lRet    := .F.

BE5->(DBSetOrder(1))
If BE5->(MsSeek(xFilial("BE5")+cGrupo))
	If BE5->BE5_PEROPC == "1"
		lRet := .T.
	Else
		If BE5->BE5_PEROPC <> "1"
			lRet := .F.
		Endif
	Endif
Endif

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA800Exc
Trata se pode ser excluido um produto

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSA800Exc(cCodInt,cCodigo,cVersao,lHelp,nOpc)
LOCAL cSQL
Local aArea := GetArea()
DEFAULT lHelp := .T.

If nOpc <> K_Excluir
	Return(.T.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica no se ele esta relacionado a outros produtos (BT3)...      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BT3_CODPLA FROM "+RetSQLName("BT3")+" WHERE "
cSQL += "D_E_L_E_T_ = '' AND "
cSQL += "BT3_FILIAL = '"+xFilial("BT3")+"' AND "
cSQL += "BT3_VERPLA = '"+cVersao+"' AND "
cSQL += "BT3_CODPLA = '"+cCodigo+"'"

PLSQuery(cSQL,"Trb800")

Trb800->(DbGoTop())

If ! Trb800->(Eof())
	If lHelp
		Help("",1,"PLSA800EX1")
	Endif
	Trb800->(DbCloseArea())
	RestArea(aArea)
	Return(.F.)
Else
	Trb800->(DbCloseArea())
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica no se ele esta relacionado a um contrato (BA3)...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BA3_CODPLA FROM "+RetSQLName("BA3")+" WHERE "
cSQL += "D_E_L_E_T_ = '' AND "
cSQL += "BA3_FILIAL = '"+xFilial("BA3")+"' AND "
cSQL += "BA3_VERSAO = '"+cVersao+"' AND "
cSQL += "BA3_CODPLA = '"+cCodigo+"'"

PLSQuery(cSQL,"Trb800")

Trb800->(DbGoTop())

If ! Trb800->(Eof())
	If lHelp
		Help("",1,"PLSA800EX2")
	Endif
	Trb800->(DbCloseArea())
	RestArea(aArea)
	Return(.F.)
Else
	Trb800->(DbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica no se ele esta relacionado a um contrato (BF4)...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BF4_CODPRO FROM "+RetSQLName("BF4")+" WHERE "
cSQL += "D_E_L_E_T_ = '' AND "
cSQL += "BF4_FILIAL = '"+xFilial("BF4")+"' AND "
cSQL += "BF4_VERSAO = '"+cVersao+"' AND "
cSQL += "BF4_CODPRO = '"+cCodigo+"'"

PLSQuery(cSQL,"Trb800")

Trb800->(DbGoTop())

If ! Trb800->(Eof())
	If lHelp
		Help("",1,"PLSA800EX3")
	Endif
	Trb800->(DbCloseArea())
	RestArea(aArea)
	Return(.F.)
Else
	Trb800->(DbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica no se ele esta relacionado a uma familia (BF1)...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BF1_CODPRO FROM "+RetSQLName("BF1")+" WHERE "
cSQL += "D_E_L_E_T_ = '' AND "
cSQL += "BF1_FILIAL = '"+xFilial("BF1")+"' AND "
cSQL += "BF1_VERSAO = '"+cVersao+"' AND "
cSQL += "BF1_CODPRO = '"+cCodigo+"'"

PLSQuery(cSQL,"Trb800")

Trb800->(DbGoTop())

If ! Trb800->(Eof())
	If lHelp
		Help("",1,"PLSA800EX4")
	Endif
	Trb800->(DbCloseArea())
	RestArea(aArea)
	Return(.F.)
Else
	Trb800->(DbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica no se ele esta relacionado a uma empresa (BT6)...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BT6_CODPRO FROM "+RetSQLName("BT6")+" WHERE "
cSQL += "D_E_L_E_T_ = '' AND "
cSQL += "BT6_FILIAL = '"+xFilial("BT6")+"' AND "
cSQL += "BT6_VERSAO = '"+cVersao+"' AND "
cSQL += "BT6_CODPRO = '"+cCodigo+"'"

PLSQuery(cSQL,"Trb800")

Trb800->(DbGoTop())

If ! Trb800->(Eof())
	If lHelp
		Help("",1,"PLSA800EX5")
	Endif
	Trb800->(DbCloseArea())
	RestArea(aArea)
	Return(.F.)
Else
	Trb800->(DbCloseArea())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica no se ele esta relacionado a uma empresa como Opcional...  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BHS_CODPLA FROM "+RetSQLName("BHS")+" WHERE "
cSQL += "D_E_L_E_T_ = '' AND "
cSQL += "BHS_FILIAL = '"+xFilial("BHS")+"' AND "
cSQL += "BHS_VERPLA = '"+cVersao+"' AND "
cSQL += "BHS_CODPLA = '"+cCodigo+"'"

PLSQuery(cSQL,"Trb800")

Trb800->(DbGoTop())

If ! Trb800->(Eof())
	If lHelp
		Help("",1,"PLSA800EX6")
	Endif
	Trb800->(DbCloseArea())
	RestArea(aArea)
	Return(.F.)
Else
	Trb800->(DbCloseArea())
Endif

RestArea(aArea)
Return(.T.)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLS800POpc

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLS800POpc()
Return(PLSA800Opc(M->BI3_GRUPO))

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS8BT3POpc

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLS8BT3POpc()
Return(PLSA800Opc(M->BT3_CODPLA))

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS800Tipo

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLS800Tipo(cCodInt,cPlano,cTipo)

LOCAL 	lRet 	:= .F.
DEFAULT cVersao := ''

BI3->(DBSetOrder(1))
If BI3->(MsSeek(xFilial("BI3")+cCodInt+cPlano))
	If BI3->BI3_TIPO $ cTipo
		lRet := .T.
	Endif
Else
	Help("",1,"RECNO")
Endif

BE5->(DBSetOrder(1))
If BE5->(MsSeek(xFilial("BE5")+BI3->BI3_GRUPO))
	If BE5->BE5_TIPO $ "2,3"
		lRet := .F.
	Endif
Endif

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} A800EndFil

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function A800EndFil(oBrw)

Local nI
Local nLine    := 0
If !oBrw:lFilter
	Return
EndIf

For nI := 1 to Len(oBrw:aItColDel)
	aDel(oBrw:aColsNoFil,oBrw:aItColDel[nI]-nI+1)
	aDel(oBrw:aVetNoFil,oBrw:aItColDel[nI]-nI+1)
Next
aSize(oBrw:aVetNoFil,Len(oBrw:aColsNoFil)-Len(oBrw:aItColDel))
aSize(oBrw:aColsNoFil,Len(oBrw:aColsNoFil)-Len(oBrw:aItColDel))
nLine := Len(oBrw:aColsNoFil)
For nI := 1 to Len(oBrw:aCols)
	aadd(oBrw:aColsNoFil,aClone(oBrw:aCols[nI]))
	aadd(oBrw:aVetNoFil,oBrw:aVetTrab[nI])
Next
nLine         +=  1
aCols         := aClone(oBrw:aColsNoFil)
oBrw:aCols    := aClone(oBrw:aColsNoFil)
oBrw:aVetTrab := aClone(oBrw:aVetNoFil)
n := nLine
oBrw:lFilter    := .F.
oBrw:aColsNoFil := {}
oBrw:aVetNoFil  := {}
oBrw:aItColDel  := {}

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PLVerFai
Funcao que verifica Confiabilidaade da Faixa Etaria

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLVerFai(_cCampoI,_cCampoF,nTipo,_aHeader,_aCols,_aTipo)
Local nI        := 0
Local nJ        := 0
Local cValTipo := ""
Local cTmpTipo := ""
Local dTabVld  := dDataBase
Local nPos	   := 0
Local cVlrI    := ""
Local cVlrF    := ""

cVlrI := &("M->"+_cCampoI)

if nTipo == 1
	cVlrF := &("M->"+_cCampoI)
Else
	cVlrF := &("M->"+_cCampoF)
Endif

if &("M->"+_cCampoI) > &("M->"+_cCampoF)
	Return(.F.)
Endif

cValTipo := ""
For nI:= 1 to Len(_aTipo)
	if TYPE("M->"+_aTipo[nI]) == "C"
		cValTipo += &("M->"+_aTipo[nI])
	Elseif TYPE("M->"+_aTipo[nI]) == "N"
		cValTipo += Str(&("M->"+_aTipo[nI]))
	Endif
Next

For nI := 1 to Len(_aHeader)
	nPos := aScan(_aHeader,{|x| x[2] == SubStr(_aHeader[nI,2],1,4)+"TABVLD"})
Next nI

For nI := 1 to Len(_aCols)
	cTmpIni := _aCols[nI,GdFieldPos(_cCampoI,_aHeader)]
	cTmpFim := _aCols[nI,GdFieldPos(_cCampoF,_aHeader)]
	If nPos > 0
		dTabVld := _aCols[nI,GdFieldPos(_aHeader[nPos,2],_aHeader)]
	EndIf
	cTmpTipo := ""
	For nJ := 1 to Len(_aTipo)
		if ValType(_aCols[nI,GdFieldPos(_aTipo[nJ],_aHeader)]) == "C"
			cTmpTipo += _aCols[nI,GdFieldPos(_aTipo[nJ],_aHeader)]
		Elseif ValType(_aCols[nI,GdFieldPos(_aTipo[nJ],_aHeader)]) == "N"
			cTmpTipo += Str(_aCols[nI,GdFieldPos(_aTipo[nJ],_aHeader)])
		Endif
	Next nJ
	if cVlrI <= cTmpFim .And. cVlrF >= cTmpIni .And. cValTipo == cTmpTipo .And. N <> nI .And. (AllTrim(DToS(dTabVld))=="" .Or. dTabVld >= dDataBase)
		Return(.F.)
	Endif
Next nI
Return(.T.)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA800Whe

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSA800Whe(cTipo)
LOCAL lPode := .F.

//Tabela BHD
If     cTipo == "01" //BHD_PERCOP
	lPode := ( M->BHD_VLRCOP == 0 )
ElseIf cTipo == "02" //BHD_VLRCOP
	lPode := ( M->BHD_PERCOP == 0 .And. M->BHD_VALUS == 0 )
ElseIf cTipo == "03" //BHD_VALUS
	lPode := ( M->BHD_VLRCOP == 0 )
Endif

//Tabela BHI
If     cTipo == "04" //BHI_PERCOP
	lPode := ( M->BHI_VLRCOP == 0 )
ElseIf cTipo == "05" //BHI_VLRCOP
	lPode := ( M->BHI_PERCOP == 0 .And. M->BHI_VALUS == 0 )
ElseIf cTipo == "06" //BHI_VALUS
	lPode := ( M->BHI_VLRCOP == 0 )
Endif

//Tabela BHJ
If     cTipo == "07" //BHJ_PERCOP
	lPode := ( M->BHJ_VLRCOP == 0 )
ElseIf cTipo == "08" //BHJ_VLRCOP
	lPode := ( M->BHJ_PERCOP == 0 .And. M->BHJ_VALUS == 0 )
ElseIf cTipo == "09" //BHJ_VALUS
	lPode := ( M->BHJ_VLRCOP == 0 )
Endif

//Tabela BCW
If     cTipo == "14" //BCW_PERCOP
	lPode := ( M->BCW_VLRCOP == 0 )
ElseIf cTipo == "15" //BCW_VLRCOP
	lPode := ( M->BCW_PERCOP == 0 .And. M->BCW_VALUS == 0 )
ElseIf cTipo == "16" //BCW_VALUS
	lPode := ( M->BCW_VLRCOP == 0 )
Endif

//Tabela BGD
If     cTipo == "17" //BGD_PERCOP
	lPode := ( M->BGD_VLRCOP == 0 )
ElseIf cTipo == "18" //BGD_VLRCOP
	lPode := ( M->BGD_PERCOP == 0 .And. M->BGD_VALUS == 0 )
ElseIf cTipo == "19" //BGD_VALUS
	lPode := ( M->BGD_VLRCOP == 0 )
Endif

Return(lPode)
//-------------------------------------------------------------------
/*/{Protheus.doc} A800Store
Store Cols separado por causa do memory overbooked

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Static Function A800Store(cAlias,nReg,nOpc,cChave, nOrdBI3)
Local I__f := 0
Local nCont
Local cSAlias
Local aSCols
Local aSHeader
Local aSVet
Local cSKey
Local aAlias := {}
Local nI
LOCAL nCnt
LOCAL I
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ REDES DE ATENDIMENTO...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BB6" TO aCabRed For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BB6" TO aDadRed FROM aCabRed
Else
	BB6->(DbSetOrder(1))
	If ! BB6->(MsSeek(xFilial("BB6")+cChvVer))
		Store COLS Blank "BB6" TO aDadRed FROM aCabRed
	Else
		Store COLS "BB6" TO aDadRed FROM aCabRed VETTRAB aTrbRed While xFilial("BB6")+cChvVer == BB6->(BB6_FILIAL+BB6_CODIGO+BB6_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CONTABILIDADE...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BHT" TO aCabCtb For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BHT" TO aDadCtb FROM aCabCtb
Else
	BHT->(DbSetOrder(1))
	If ! BHT->(MsSeek(xFilial("BHT")+cChvVer))
		Store COLS Blank "BHT" TO aDadCtb FROM aCabCtb
	Else
		Store COLS "BHT" TO aDadCtb FROM aCabCtb VETTRAB aTrbCtb While xFilial("BHT")+cChvVer == BHT->(BHT_FILIAL+BHT_CODIGO+BHT_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Coberturas...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BB2" TO aCabCob For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BB2" TO aDadCob FROM aCabCob
Else
	BB2->(DbSetOrder(1))
	If ! BB2->(MsSeek(xFilial("BB2")+cChvVer))
		Store COLS Blank "BB2" TO aDadCob FROM aCabCob
	Else
		Store COLS "BB2" TO aDadCob FROM aCabCob VETTRAB aTrbCob While xFilial("BB2")+cChvVer == BB2->(BB2_FILIAL+BB2_CODIGO+BB2_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Co-participacao por procedimento                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BHD" TO aCabPCo For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BHD" TO aDadPCo FROM aCabPCo
Else
	BHD->(DbSetOrder(1))
	If ! BHD->(MsSeek(xFilial("BHD")+cChvVer))
		Store COLS Blank "BHD" TO aDadPCo FROM aCabPCo
	Else
		Store COLS "BHD" TO aDadPCo FROM aCabPCo VETTRAB aTrbPCo While xFilial("BHD")+cChvVer == BHD->(BHD_FILIAL+BHD_CODIGO+BHD_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Situacoes adversas                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BGZ" TO aCabSit For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BGZ" TO aDadSit FROM aCabSit
Else
	BGZ->(DbSetOrder(1))
	If ! BGZ->(MsSeek(xFilial("BGZ")+cChvVer))
		Store COLS Blank "BGZ" TO aDadSit FROM aCabSit
	Else
		Store COLS "BGZ" TO aDadSit FROM aCabSit VETTRAB aTrbSit While xFilial("BGZ")+cChvVer == BGZ->(BGZ_FILIAL+BGZ_CODINT+BGZ_CODIGO+BGZ_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ COBRANCA DE IDENTIFICACAO DE USUARIOS                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BJB" TO aCabBJB For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BJB" TO aDadBJB FROM aCabBJB
Else
	BJB->(DbSetOrder(1))
	If ! BJB->(MsSeek(xFilial("BJB")+cChvVer))
		Store COLS Blank "BJB" TO aDadBJB FROM aCabBJB
	Else
		Store COLS "BJB" TO aDadBJB FROM aCabBJB VETTRAB aTrbBJB While xFilial("BJB")+cChvVer == BJB->(BJB_FILIAL+BJB_CODINT+BJB_CODIGO+BJB_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuarios permitidos...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BT1" TO aCabUsr For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BT1" TO aDadUsr FROM aCabUsr
Else
	BT1->(DbSetOrder(1))
	If ! BT1->(MsSeek(xFilial("BT1")+cChvVer))
		Store COLS Blank "BT1" TO aDadUsr FROM aCabUsr
	Else
		Store COLS "BT1" TO aDadUsr FROM aCabUsr VETTRAB aTrbUsr While xFilial("BT1")+cChvVer == BT1->(BT1_FILIAL+BT1_CODIGO+BT1_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Regras para novos depedentes...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BEK" TO aCabBEK For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BEK" TO aDadBEK FROM aCabBEK
	cCodSeqBEK := aDadBEK[AScan(aCabBEK,{|x|x[2]=="BEK_SEQUEN"}),1]
Else
	BEK->(DbSetOrder(1))
	If ! BEK->(MsSeek(xFilial("BEK")+cChvVer))
		Store COLS Blank "BEK" TO aDadBEK FROM aCabBEK
		cCodSeqBEK := aDadBEK[AScan(aCabBEK,{|x|x[2]=="BEK_SEQUEN"}),1]
	Else
		Store COLS "BEK" TO aDadBEK FROM aCabBEK VETTRAB aTrbBEK While xFilial("BEK")+cChvVer == BEK->(BEK_FILIAL+BEK_CODIGO+BEK_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Regras para carencia por tipo de Internacao                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BYK" TO aCabBYK For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BYK" TO aDadBYK FROM aCabBYK
Else
	BYK->(DbSetOrder(1))
	If ! BYK->(MsSeek(xFilial("BYK")+cChvVer))
		Store COLS Blank "BYK" TO aDadBYK FROM aCabBYK
	Else
		Store COLS "BYK" TO aDadBYK FROM aCabBYK VETTRAB aTrbBYK While xFilial("BYK")+cChvVer == BYK->(BYK_FILIAL+BYK_CODIGO+BYK_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupo de Carencia...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BAY" TO aCabBAY For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BAY" TO aDadBAY FROM aCabBAY
Else
	BAY->(DbSetOrder(1))
	If ! BAY->(MsSeek(xFilial("BAY")+cChvVer))
		Store COLS Blank "BAY" TO aDadBAY FROM aCabBAY
	Else
		Store COLS "BAY" TO aDadBAY FROM aCabBAY VETTRAB aTrbBAY While xFilial("BAY")+cChvVer == BAY->(BAY_FILIAL+BAY_CODIGO+BAY_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Classe de Carencia...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BAN" TO aCabBAN For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BAN" TO aDadBAN FROM aCabBAN
Else
	BAN->(DbSetOrder(1))
	If ! BAN->(MsSeek(xFilial("BAN")+cChvVer))
		Store COLS Blank "BAN" TO aDadBAN FROM aCabBAN
	Else
		Store COLS "BAN" TO aDadBAN FROM aCabBAN VETTRAB aTrbBAN While xFilial("BAN")+cChvVer == BAN->(BAN_FILIAL+BAN_CODIGO+BAN_VERSAO)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo de Prestador                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BCU" TO aCabBCU For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BCU" TO aDadBCU FROM aCabBCU
Else
	BCU->(DbSetOrder(1))
	If ! BCU->(MsSeek(xFilial("BCU")+cChvVer))
		Store COLS Blank "BCU" TO aDadBCU FROM aCabBCU
	Else
		Store COLS "BCU" TO aDadBCU FROM aCabBCU VETTRAB aVetBCU While xFilial("BCU")+cChvVer == BCU->(BCU_FILIAL+BCU_CODIGO+BCU_VERSAO)
		cTipPre := BCU->BCU_TIPPRE
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo de Prestador - Co-Participacao                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BCW" TO aCabBCW For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BCW" TO aDadBCW FROM aCabBCW
Else
	BCW->(DbSetOrder(1))
	If ! BCW->(MsSeek(xFilial("BCW")+cChvVer))
		Store COLS Blank "BCW" TO aDadBCW FROM aCabBCW
	Else
		Store COLS "BCW" TO aDadBCW FROM aCabBCW VETTRAB aVetBCW While xFilial("BCW")+cChvVer == BCW->(BCW_FILIAL+BCW_CODIGO+BCW_VERSAO)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Municipio Atendimento                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BCZ" TO aCabBCZ For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BCZ" TO aDadBCZ FROM aCabBCZ
Else
	BCZ->(DbSetOrder(1))
	If ! BCZ->(MsSeek(xFilial("BCZ")+cChvVer))
		Store COLS Blank "BCZ" TO aDadBCZ FROM aCabBCZ
	Else
		Store COLS "BCZ" TO aDadBCZ FROM aCabBCZ VETTRAB aVetBCZ While xFilial("BCZ")+cChvVer == BCZ->(BCZ_FILIAL+BCZ_CODIGO+BCZ_VERSAO)
		cCodMun := BCZ->BCZ_CODMUN
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo de Prestador - Co-Participacao                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BGD" TO aCabBGD For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BGD" TO aDadBGD FROM aCabBGD
Else
	BGD->(DbSetOrder(1))
	If ! BGD->(MsSeek(xFilial("BGD")+cChvVer))
		Store COLS Blank "BGD" TO aDadBGD FROM aCabBGD
	Else
		Store COLS "BGD" TO aDadBGD FROM aCabBGD VETTRAB aVetBGD While xFilial("BGD")+cChvVer == BGD->(BGD_FILIAL+BGD_CODIGO+BGD_VERSAO)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupo de Carencia X Classe de Carencia                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BAE" TO aCabBAE For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BAE" TO aDadBAE FROM aCabBAE
Else
	BAE->(DbSetOrder(1))
	If ! BAE->(MsSeek(xFilial("BAE")+cChvVer))
		Store COLS Blank "BAE" TO aDadBAE FROM aCabBAE
	Else
		Store COLS "BAE" TO aDadBAE FROM aCabBAE VETTRAB aTrbBAE While xFilial("BAE")+cChvVer == BAE->(BAE_FILIAL+BAE_CODIGO+BAE_VERSAO)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Documentos obrigatorios...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BQP" TO aCabBQP For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BQP" TO aDadBQP FROM aCabBQP
Else
	BQP->(DbSetOrder(1))
	If ! BQP->(MsSeek(xFilial("BQP")+cChvVer))
		Store COLS Blank "BQP" TO aDadBQP FROM aCabBQP
	Else
		Store COLS "BQP" TO aDadBQP FROM aCabBQP VETTRAB aTrbBQP While xFilial("BQP")+cChvVer == BQP->(BQP_FILIAL+BQP_CODIGO+BQP_VERSAO)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tip.Lanc x Faixa desconto											|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BKJ" TO aCabBKJ For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BKJ" TO aDadBKJ FROM aCabBKJ
Else
	BKJ->(DbSetOrder(1))
	If ! BKJ->(MsSeek(xFilial("BKJ")+cChvVer))
		Store COLS Blank "BKJ" TO aDadBKJ FROM aCabBKJ
	Else
		Store COLS "BKJ" TO aDadBKJ FROM aCabBKJ VETTRAB aTrbBKJ While xFilial("BKJ")+cChvVer == BKJ->(BKJ_FILIAL+BKJ_CODIGO+BKJ_VERSAO)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto x Regiao                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BY9" TO aCabBY9 For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BY9" TO aDadBY9 FROM aCabBY9
Else
	BY9->(DbSetOrder(1))
	If ! BY9->(MsSeek(xFilial("BY9")+cChvVer))
		Store COLS Blank "BY9" TO aDadBY9 FROM aCabBY9
	Else
		Store COLS "BY9" TO aDadBY9 FROM aCabBY9 VETTRAB aTrbBY9 While xFilial("BY9")+cChvVer == BY9->(BY9_FILIAL+BY9_CODIGO+BY9_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produtos Vinculados...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BT3" TO aCabPro For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BT3" TO aDadPro FROM aCabPro
Else
	BT3->(DbSetOrder(1))
	If ! BT3->(MsSeek(xFilial("BT3")+cChvVer))
		Store COLS Blank "BT3" TO aDadPro FROM aCabPro
	Else
		Store COLS "BT3" TO aDadPro FROM aCabPro VETTRAB aTrbPro While xFilial("BT3")+cChvVer == BT3->(BT3_FILIAL+BT3_CODIGO+BT3_VERSAO)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produtos Vinculados x Forma de Cobranca                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BJY" TO aCabPFai For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BJY" TO aDadPFai FROM aCabPFai
Else
	BJY->(DbSetOrder(1))
	If ! BJY->(MsSeek(xFilial("BJY")+cChvVer))
		Store COLS Blank "BJY" TO aDadPFai FROM aCabPFai
	Else
		Store COLS "BJY" TO aDadPFai FROM aCabPFai VETTRAB aTrbPFai While xFilial("BJY")+cChvVer == BJY->(BJY_FILIAL+BJY_CODIGO+BJY_VERSAO)
	Endif
Endif

BI3->(DbGoTo(nReg))
BI3->(DbSetOrder(nOrdBI3))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fornecedor parceiro...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BT4" TO aCabFPa For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BT4" TO aDadFPa FROM aCabFPa
Else
	BT4->(DbSetOrder(1)) //BT4_FILIAL+BT4_CODIGO+BT4_VERSAO+BT4_CODCRE
	If ! BT4->(MsSeek(xFilial("BT4")+cChvVer))
		Store COLS Blank "BT4" TO aDadFPa FROM aCabFPa
		cCodPla := BT4->BT4_CODIGO
		cVerPla := BT4->BT4_VERSAO
		cCodRDa := BT4->BT4_CODCRE
	Else
		Store COLS "BT4" TO aDadFPa FROM aCabFPa VETTRAB aTrbFPa While xFilial("BT4")+cChvVer == BT4->(BT4_FILIAL+BT4_CODIGO+BT4_VERSAO)
		cCodPla := BT4->BT4_CODIGO
		cVerPla := BT4->BT4_VERSAO
		cCodRDa := BT4->BT4_CODCRE
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desc Faixa Evento Produto x Rda                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "B61" TO aCabB61 For .T.
If nOpcx == K_Incluir
	Store COLS Blank "B61" TO aDadB61 FROM aCabB61
Else
	B61->(DbSetOrder(1))
	If ! B61->(MsSeek(xFilial("B61")+cChvVer))
		Store COLS Blank "B61" TO aDadB61 FROM aCabB61
	Else
		Store COLS "B61" TO aDadB61 FROM aCabB61 VETTRAB aTrbB61 While B61->(B61_FILIAL+B61_CODINT+B61_CODPLA+B61_VERSAO) == xFilial("B61")+cChvVer
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desc Faixa Evento Produto x Rda                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "B86" TO aCabB86 For .T.
If nOpcx == K_Incluir
	Store COLS Blank "B86" TO aDadB86 FROM aCabB86
Else
	B86->(DbSetOrder(1))
	If ! B86->(MsSeek(xFilial("B86")+cChvVer))
		Store COLS Blank "B86" TO aDadB86 FROM aCabB86
	Else
		Store COLS "B86" TO aDadB86 FROM aCabB86 VETTRAB aTrbB86 While B86->(B86_FILIAL+B86_CODINT+B86_CODPLA+B86_VERSAO) == xFilial("B86")+cChvVer
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ FORMAS DE Forma DE COBRANCA ...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BJ3" TO aCabFor For SX3->X3_CAMPO == "BJ3_CODFOR" .Or. SX3->X3_CAMPO == "BJ3_DESFOR"
If nOpcx == K_Incluir
	Store COLS Blank "BJ3" TO aDadFor FROM aCabFor
Else
	BJ3->(DbSetOrder(1))
	If ! BJ3->(MsSeek(xFilial("BJ3")+cChvVer))
		Store COLS Blank "BJ3" TO aDadFor FROM aCabFor
	Else
		Store COLS "BJ3" TO aDadFor FROM aCabFor VETTRAB aTrbFor While xFilial("BJ3")+cChvVer == BJ3->(BJ3_FILIAL+BJ3_CODIGO+BJ3_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupo de Cobertura ...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BRV" TO aCabGru For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BRV" TO aDadGru FROM aCabGru
Else
	BRV->(DbSetOrder(1))
	If ! BRV->(MsSeek(xFilial("BRV")+cChvVer))
		Store COLS Blank "BRV" TO aDadGru FROM aCabGru
	Else
		Store COLS "BRV" TO aDadGru FROM aCabGru VETTRAB aTrbGru While xFilial("BRV")+cChvVer == BRV->(BRV_FILIAL+BRV_CODPLA+BRV_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Co-participacao x Grupo de Cobertura                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BHI" TO aCabGCo For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BHI" TO aDadGCo FROM aCabGCo
Else
	BHI->(DbSetOrder(1))
	If ! BHI->(MsSeek(xFilial("BHI")+cChvVer))
		Store COLS Blank "BHI" TO aDadGCo FROM aCabGCo
	Else
		Store COLS "BHI" TO aDadGCo FROM aCabGCo VETTRAB aTrbGCo While xFilial("BHI")+cChvVer == BHI->(BHI_FILIAL+BHI_CODINT+BHI_CODPLA+BHI_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Co-participacao x Grupo de Cobertura                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BHJ" TO aCabCoPar For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BHJ" TO aDadCoPar FROM aCabCoPar
Else
	BHJ->(DbSetOrder(1))
	If ! BHJ->(MsSeek(xFilial("BHJ")+cChvVer))
		Store COLS Blank "BHJ" TO aDadCoPar FROM aCabCoPar
	Else
		Store COLS "BHJ" TO aDadCoPar FROM aCabCoPar VETTRAB aTrbCoPar While xFilial("BHJ")+cChvVer == BHJ->(BHJ_FILIAL+BHJ_CODINT+BHJ_CODPLA+BHJ_VERSAO)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faixa desconto por Pagto											|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "B60" TO aCabB60 For .T.
If nOpcx == K_Incluir
	Store COLS Blank "B60" TO aDadB60 FROM aCabB60
Else
	B60->(DbSetOrder(1))
	If ! B60->(MsSeek(xFilial("B60")+cChvVer))
		Store COLS Blank "B60" TO aDadB60 FROM aCabB60
	Else
		Store COLS "B60" TO aDadB60 FROM aCabB60 VETTRAB aTrbB60 While xFilial("B60")+cChvVer == B60->(B60_FILIAL+B60_CODINT+B60_CODPLA+B60_VERSAO)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle de versao...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_NovaVersao
	M->BI3_VERSAO  := cPLSVersao
	lRefresh       := .T.
	nOpc           := K_Alterar
	nOpcx          := K_Alterar
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle Forma de Cobranca ...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir
	cOldAlias := cAlias
	BJ3->(DbSetOrder(1))
	If BJ3->(MsSeek(xFilial("BJ3")+cChvVer))
		While ! BJ3->(Eof()) .And. BJ3->(BJ3_FILIAL+BJ3_CODIGO+BJ3_VERSAO) == xFilial("BJ3")+cChvVer

			cCodFor  := BJ3->BJ3_CODFOR
			aOpcoes  := A800MOpc(cCodFor)
			aDados   := {}
			aCabec   := {}

			For nI := 1 To Len(aOpcoes)
				aRecTrab := {}
				cAlias   := aOpcoes[nI,2]
				cTipo    := aOpcoes[nI,3]
				cTit     := aOpcoes[nI,1]

				DbSelectArea(cAlias)
				DbSetOrder(1)
				If cTipo = "1" .Or. "_CODFOR" $ IndexKey()
					If lNewVersao//Feita verif.se é uma nova versão,para carregar corretamente as faixas cadastradas na forma de cobr.
						MsSeek(xFilial(cAlias)+cChvVer+cCodFor)
					Else
						MsSeek(xFilial(cAlias)+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)+cCodFor)
					EndIf
				Else
					MsSeek(xFilial(cAlias)+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO))
				Endif

				If Found() .And. cTipo == "0" // Enchoice
					Copy cAlias To Memory
					aCpos   := {}
					aFields := DBSTRUCT()
					For nCont := 1 To Len(aFields)
						cTrab := "M->"+aFields[nCont,1]
						cDado := &cTrab
						if ValType(cDado) == "C"
							if Empty(AllTrim(cDado))
								cDado := Criavar(aFields[nCont,1])
							Endif
						Elseif Empty(cDado)
							cDado := Criavar(aFields[nCont,1])
						Endif
						aadd(aCpos,{cTrab,cDado})
					Next
					aadd(aVetsFor,{cCodFor,cAlias,cTipo,aCpos,Recno()})
				ElseIf cTipo == "1" // GetDados
					_cChave := cAlias+"_FILIAL+"+;
					cAlias+"_CODIGO+"+;
					cAlias+"_VERSAO+"+;
					cAlias+"_CODFOR"
					STORE HEADER cAlias TO aCabec For .T.
					If Found()
						If lNewVersao
							Store COLS cAlias TO aDados FROM aCabec VETTRAB aRecTrab While &_cChave == xFilial("BI3")+cChvVer+cCodFor 
					    Else
					    	Store COLS cAlias TO aDados FROM aCabec VETTRAB aRecTrab While &_cChave == xFilial("BI3")+cChvVer+cCodFor
					    EndIf
					Else
						Store COLS Blank cAlias TO aDados FROM aCabec
					Endif
					aadd(aVetsFor,{cCodFor,cAlias,cTipo,aDados,aRecTrab,""})
				Endif
			Next
			BJ3->(DbSkip())
		Enddo
	Endif
	cAlias := cOldAlias
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle Forma de Cobranca para Taxa de Adesao...                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir
	cOldAlias := cAlias
	BJ9->(DbSetOrder(1))
	If BJ9->(MsSeek(xFilial("BJ9")+cChvVer))
		While ! BJ9->(Eof()) .And. BJ9->(BJ9_FILIAL+BJ9_CODIGO+BJ9_VERSAO) == xFilial("BJ9")+cChvVer

			cCodFor  := BJ9->BJ9_CODFOR
			aOpcoes  := A800MOpc(cCodFor)
			aDados   := {}
			aCabec   := {}

			For nI := 1 To Len(aOpcoes)
				aRecTrab := {}
				cAlias   := aOpcoes[nI,2]
				cTipo    := aOpcoes[nI,3]
				cTit     := aOpcoes[nI,1]

				DbSelectArea(cAlias)
				DbSetOrder(1)
				If cTipo = "1" .Or. "_CODFOR" $ IndexKey()
					If lNewVersao//Feita verif.se é uma nova versão,para carregar corretamente as faixas cadastradas na taxa de adesão
						MsSeek(xFilial(cAlias)+cChvVer+cCodFor)
					Else
						MsSeek(xFilial(cAlias)+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)+cCodFor)
					EndIf
				Else
					MsSeek(xFilial(cAlias)+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO))
				Endif

				If Found() .And. cTipo == "0" // Enchoice
					Copy cAlias To Memory
					aCpos   := {}
					aFields := DBSTRUCT()
					For nCont := 1 To Len(aFields)
						cTrab := "M->"+aFields[nCont,1]
						cDado := &cTrab
						aadd(aCpos,{cTrab,cDado})
					Next
					aadd(aVetsTxF,{cCodFor,cAlias,cTipo,aCpos,Recno()})
				ElseIf cTipo == "1" // GetDados
					_cChave := cAlias+"_FILIAL+"+;
					cAlias+"_CODIGO+"+;
					cAlias+"_VERSAO+"+;
					cAlias+"_CODFOR"
					STORE HEADER cAlias TO aCabec For .T.
					If Found()
						Store COLS cAlias TO aDados FROM aCabec VETTRAB aRecTrab While &_cChave == xFilial("BI3")+cChvVer+cCodFor
					Else
						Store COLS Blank cAlias TO aDados FROM aCabec
					Endif
					aadd(aVetsTxF,{cCodFor,cAlias,cTipo,aDados,aRecTrab,""})
				Endif
			Next
			BJ9->(DbSkip())
		Enddo
	Endif
	cAlias := cOldAlias
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle Forma de Cobranca para Produtos Relacionados...            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir
	cOldAlias := cAlias
	BJY->(DbSetOrder(1))
	If BJY->(MsSeek(xFilial("BJY")+cChvVer))
		While ! BJY->(Eof()) .And. BJY->(BJY_FILIAL+BJY_CODIGO+BJY_VERSAO) == xFilial("BJY")+cChvVer

			cCodFor  := BJY->BJY_CODFOR
			aOpcoes  := A800MOpc(cCodFor)
			aDados   := {}
			aCabec   := {}

			For nI := 1 To Len(aOpcoes)
				aRecTrab := {}
				cAlias   := aOpcoes[nI,2]
				cTipo    := aOpcoes[nI,3]
				cTit     := aOpcoes[nI,1]

				DbSelectArea(cAlias)
				DbSetOrder(1)
				If cTipo = "1" .Or. "_CODFOR" $ IndexKey()
					MsSeek(xFilial(cAlias)+BJY->(BJY_CODIGO+BJY_VERSAO+BJY_CODOPC+BJY_VEROPC)+cCodFor)
				Else
					MsSeek(xFilial(cAlias)+BJY->(BJY_CODIGO+BJY_VERSAO+BJY_CODOPC+BJY_VEROPC))
				Endif

				If Found() .And. cTipo == "0" // Enchoice
					Copy cAlias To Memory
					aCpos   := {}
					aFields := DBSTRUCT()
					For nCont := 1 To Len(aFields)
						cTrab := "M->"+aFields[nCont,1]
						cDado := &cTrab
						aadd(aCpos,{cTrab,cDado})
					Next
					aadd(aVetsOpc,{cCodFor,cAlias,cTipo,aCpos,Recno(),""})
				ElseIf cTipo == "1" // GetDados
					_cChave := cAlias+"_FILIAL+"+;
					cAlias+"_CODIGO+"+;
					cAlias+"_VERSAO+"+;
					cAlias+"_CODOPC+"+;
					cAlias+"_VEROPC+"+;
					cAlias+"_CODFOR"
					STORE HEADER cAlias TO aCabec For .T.
					If Found()
						Store COLS cAlias TO aDados FROM aCabec VETTRAB aRecTrab While &_cChave == xFilial(cAlias)+BJY->(BJY_CODIGO+BJY_VERSAO+BJY_CODOPC+BJY_VEROPC)+cCodFor
					Else
						Store COLS Blank cAlias TO aDados FROM aCabec
					Endif
					
					// Trata a matriz, para alimentar o codigo do produto corretamente.
					For nCnt := 1 To Len(aDados)
						aDados[n][PLRETPOS(cAlias+"_CODOPC",aCabec)] := BJY->BJY_CODOPC
						aDados[n][PLRETPOS(cAlias+"_VEROPC",aCabec)] := BJY->BJY_VEROPC
					Next
					
					aadd(aVetsOpc,{cCodFor,cAlias,cTipo,aDados,aRecTrab,BJY->(BJY_CODOPC+BJY_VEROPC)})
				Endif
			Next
			BJY->(DbSkip())
		Enddo
	Endif
	cAlias := cOldAlias
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Taxas de Adesao...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BJ9" TO aCabAde For SX3->X3_CAMPO == "BJ9_CODFOR" .Or. SX3->X3_CAMPO == "BJ9_DESFOR"
If nOpcx == K_Incluir
	Store COLS Blank "BJ9" TO aDadAde FROM aCabAde
Else
	BJ9->(DbSetOrder(1))
	If ! BJ9->(MsSeek(xFilial("BJ9")+cChvVer))
		Store COLS Blank "BJ9" TO aDadAde FROM aCabAde
	Else
		Store COLS "BJ9" TO aDadAde FROM aCabAde VETTRAB aTrbAde While xFilial("BJ9")+cChvVer == BJ9->(BJ9_FILIAL+BJ9_CODIGO+BJ9_VERSAO)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Pagamento...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BMD" TO aCabPPg For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BMD" TO aDadPPg FROM aCabPPg
Else
	BMD->(DbSetOrder(1))
	If ! BMD->(MsSeek(xFilial("BMD")+cChvVer))
		Store COLS Blank "BMD" TO aDadPPg FROM aCabPPg
	Else
		cTipPreSel := BMD->BMD_TIPPRE
		Store COLS "BMD" TO aDadPPg FROM aCabPPg VETTRAB aTrbPPg While BMD->(BMD_CODIGO+BMD_VERSAO) == cChvVer
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Pagamento x Procedimentos...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BME" TO aCabPPP For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BME" TO aDadPPP FROM aCabPPP
Else
	BME->(DbSetOrder(1))
	If ! BME->(MsSeek(xFilial("BME")+cChvVer))
		Store COLS Blank "BME" TO aDadPPP FROM aCabPPP
	Else
		Store COLS "BME" TO aDadPPP FROM aCabPPP VETTRAB aTrbPPP While BME->(BME_CODIGO+BME_VERSAO) == cChvVer
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PROD. X FATORES MULTIP. REEMB.                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "B31" TO aCabB31 For .T.
If nOpcx == K_Incluir
	Store COLS Blank "B31" TO aDadB31 FROM aCabB31
	cCodSeqB31 := aDadB31[1, AScan(aCabB31,{|x|x[2]=="B31_SEQUEN"})]
Else
	B31->(DbSetOrder(1))
	If ! B31->(MsSeek(xFilial("B31")+cChvVer))
		cCodSeqB31 := B31->B31_SEQUEN
		cTipClasse := B31->B31_CLASSE
		Store COLS Blank "B31" TO aDadB31 FROM aCabB31
	Else
		cCodSeqB31 := B31->B31_SEQUEN
		cTipClasse := B31->B31_CLASSE
		Store COLS "B31" TO aDadB31 FROM aCabB31 VETTRAB aTrbB31 While B31->(B31_FILIAL+B31_CODINT+B31_CODIGO+B31_VERSAO) == xFilial("B31")+cChvVer
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VIG. PROD. X FAT. MULT. REEMB                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "B32" TO aCabB32 For .T.
If nOpcx == K_Incluir
	Store COLS Blank "B32" TO aDadB32 FROM aCabB32
Else
	B32->(DbSetOrder(1))
	If ! B32->(MsSeek(xFilial("B32")+cChvVer))
		Store COLS Blank "B32" TO aDadB32 FROM aCabB32
		aDadB32[1, AScan(aCabB32,{|x|x[2]=="B32_SEQUEN"})] := cCodSeqB31
	Else
		Store COLS "B32" TO aDadB32 FROM aCabB32 VETTRAB aTrbB32 While B32->(B32_FILIAL+B32_CODINT+B32_CODIGO+B32_VERSAO) == xFilial("B31")+cChvVer
	Endif
Endif

If Len(aDadB32) > 0
	For  I:=1 To Len(aDadB32)
		If Empty(aDadB32[I][1])
		   Exit
		EndIf
		aadd(aVetB32,{	aDadB32[I,AScan(aCabB32,{|x|x[2]=="B32_CLASSE"})],; //1
							"B32",;	//2
							NIL,;		//3
							NIL,;		//4
							0,;		//5
							NIL,; 	//6
							NIL,; 	//7
							NIL,; 	//8
							NIL,; 	//9
							NIL,; 	//10
							NIL,; 	//11
							NIL,; 	//12
							!aDadb32[I,LEN(aDadB32[I])]})		//13
	Next
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PLS800CLCR
Monta a getdados da classe de carencia para novos dependentes

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Static Function PLS800CLCR(nOpc)

LOCAL oDlgPc
LOCAL nOpca       := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Classe de carencia para novos dependentes                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBWX := {}
PRIVATE aDadBWX := {}
PRIVATE aTrbBWX := {}
PRIVATE oBrwBWX
PRIVATE lUseBWX := .F.

aSize := MsAdvSize()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Regras para novos depedentes...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BWX" TO aCabBWX For .T.
If nOpcx == K_Incluir
	MsgAlert(OemtoAnsi(STR0065)) //"Esta opcao so esta disponivel para o modo de alteracao!"
	Return(.F.)
Else
	BWX->(DbSetOrder(1))
	If ! BWX->(MsSeek(xFilial("BWX")+cChvVer+cCodSeqBEK))
		Store COLS Blank "BWX" TO aDadBWX FROM aCabBWX
		aDadBWX[1,GDFieldPos("BWX_SEQUEN",aCabBWX)] := cCodSeqBEK 	
	Else
		Store COLS "BWX" TO aDadBWX FROM aCabBWX VETTRAB aTrbBWX While xFilial("BWX")+cChvVer+cCodSeqBEK == BWX->(BWX_FILIAL+BWX_CODINT+BWX_CODPRO+BWX_VERSAO+BWX_SEQUEN)
	Endif                                                        
Endif

DEFINE MSDIALOG oDlgPc TITLE OemtoAnsi(STR0039) FROM 009,000 TO 034,075 OF GetWndDefault() //"Classe de Carencia"
oDlgPc:lEscClose := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBWX:= TPLSBrw():New(030,001,300,190,nil  ,oDlgPc,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBWX ,aDadBWX ,.F. ,"BWX" ,nOpc,"Classe de Carencia",nil,nil,nil,aTrbBWX,nil,nil,,,,,,,,,,,aDifSize) //bFilter
oBrwBWX:bGotFocus := {|| oBrwBWX:Atualiza() }
oBrwBWX:oPai      := oBrwBEK
oBrwBWX:aOrigem   := {"BEK_SEQUEN"}
oBrwBWX:aRelac    := {"BWX_SEQUEN"}

ACTIVATE DIALOG oDlgPc CENTERED ON INIT ( EnchoiceBar(oDlgPc, {|| nOpca:=1,oDlgPc:End()},{|| nOpca:= 0,oDlgPc:End()} ))

If nOpca == 1
	aChave := {}
	aadd(aChave,{"BWX_CODINT",M->BI3_CODINT})
	aadd(aChave,{"BWX_CODPRO",M->BI3_CODIGO})
	aadd(aChave,{"BWX_VERSAO",M->BI3_VERSAO})
	oBrwBWX:nOpc := nOpc
	oBrwBWX:Grava(aChave, .T.)
Endif

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSM800DEL
Marca as propriedades da cobranca ao deletar a forma

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSM800DEL(nOpc, nTipo)
Local nInd
Local nI,nTr
Local cCodFor, cChave, aVetsTmp, aTrab, aOpcoes
Local aSavCols := AClone(aCols), aSavHead := AClone(aHeader)

if nTipo ==1
	cCodFor  := oBrwFor:aCols[oBrwFor:Linha(),oBrwFor:PLRETPOS("BJ3_CODFOR")]
	aVetsTmp := AClone(aVetsFor)
Elseif nTipo ==2
	cCodFor  := oBrwAde:aCols[oBrwAde:Linha(),oBrwAde:PLRETPOS("BJ9_CODFOR")]
	aVetsTmp := AClone(aVetsTxF)
Elseif nTipo ==3
	cCodFor  := oBrwPFai:aCols[oBrwPFai:Linha(),oBrwPFai:PLRETPOS("BJY_CODFOR")]
	aVetsTmp := AClone(aVetsOpc)
Endif

aOpcoes := A800MOpc(cCodFor)

For nI := 1 To Len(aOpcoes)
	cAlias  := aOpcoes[nI,2]
	cTipo   := aOpcoes[nI,3]

	aHeader := {}
	aCols   := {}
	DbSelectArea(cAlias)

	cBrw := "oBrw"+cAlias

	STORE HEADER cAlias TO aHeader For .T.

	For nInd := 1 To Len(aVetsTmp)
		If aVetsTmp[nInd,1] == cCodFor .And. aVetsTmp[nInd,2] == cAlias
			aTrab := aVetsTmp[nInd,4]
			If cTipo == "1" // GetDados
				For nTr := 1 To Len(aTrab)
					if nTipo == 3
						if 	aVetsTmp[nInd,4][nTr][GdFieldPos(cAlias+"_CODOPC",aHeader)] == cCodPla .And.;
							aVetsTmp[nInd,4][nTr][GdFieldPos(cAlias+"_VEROPC",aHeader)] == cVerPla
							aVetsTmp[nInd,4][nTr][Len(aVetsTmp[nInd,4][nTr])] := .T.
						Endif
					Else
						aVetsTmp[nInd,4][nTr][Len(aVetsTmp[nInd,4][nTr])] := .T.
					Endif
				Next
			Endif
		Endif
	Next
Next

if nTipo == 1
	aVetsFor := AClone(aVetsTmp)
	If oBrwFor:IsDeleted(oBrwFor:Linha())
		oBotPro:Disable()
	Else
		oBotPro:Enable()
	Endif
Elseif nTipo == 2
	aVetsTxF := AClone(aVetsTmp)
	If oBrwAde:IsDeleted(oBrwAde:Linha())
		oBotAde:Disable()
	Else
		oBotAde:Enable()
	Endif
Else
	aVetsOpc := AClone(aVetsTmp)
	If oBrwPFai:IsDeleted(oBrwPFai:Linha()) .Or. oBrwPro:aCols[oBrwPro:Linha(),oBrwPro:PlRetPos("BT3_TIPVIN")]=="1"
		oBotForOpc:Disable()
	Else
		oBotForOpc:Enable()
	Endif
Endif

aCols := AClone(aSavCols)
aHeader := AClone(aSavHead)

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} Pls800DRel
Deleta o produto vinculado e as formas de cobranca rel.

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function Pls800DRel

Local nCols := 0

If 	oBrwPro:IsDeleted(oBrwPro:Linha()) .Or.;
	oBrwPro:aCols[oBrwPro:Linha(), oBrwPro:PlRetPos("BT3_TIPVIN")]=="1"
	For nCols := 1 To Len(oBrwPFai:aCols)
		oBrwPFai:oBrowse:oBrowse:nAt := nCols
		oBrwPFai:aCols[oBrwPFai:Linha(), Len(oBrwPFai:aCols[1])] := .T.
		PLSM800Del(nOpcx, 3)
	Next
	oBrwPFai:ForceRefresh(oBrwPFai)
	oBrwPFai:oBrowse:oBrowse:nAt := 1
	oBrwPFai:OBROWSE:OBROWSE:lReadOnly := .T.
Else
	oBrwPFai:OBROWSE:OBROWSE:lReadOnly := .F.
Endif

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSM800NAl
Nao permite alteracao do codigo da cobranca caso ja tenha propriedades

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSM800NAl(cAlias)

Local lEdita := .T., nFor
Local nRecTrab, aVetsTmp, cCodFor

if cAlias = "BJ3"
	aVetsTmp := AClone(aVetsFor)
	cCodFor := M->BJ3_CODFOR
Elseif cAlias = "BJ9"
	aVetsTmp := AClone(aVetsTxF)
	cCodFor := M->BJ9_CODFOR
Elseif cAlias = "BJY"
	aVetsTmp := AClone(aVetsOpc)
	cCodFor := M->BJY_CODFOR
Endif

For nFor := 1 To Len(aVetsTmp)
	If 	aVetsTmp[nFor][1] = cCodFor
		If Len(aVetsTmp[nFor]) > 6 .And. aVetsTmp[nFor][7]
			lEdita := .F.
		Else
			For nRecTrab := 1 To Len(aVetsTmp[nFor][5])
				If aVetsTmp[nFor][5][nRecTrab] > 0
					lEdita := .F.
					Exit
				Endif
			Next
		Endif
		If ! lEdita
			Exit
		Endif
	Endif
Next

Return lEdita
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSM800Ctb
Valida as regras de parametrizacoes contabeis

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSM800Ctb

Local lRet := .T.

If M->BHT_TIPOCO="1"
	M->BHT_TIPPRE := Space(Len(M->BHT_TIPPRE))
Else
	M->BHT_CODOCO:=Space(Len(M->BHT_CODOCO))
	M->BHT_DESOCO:=""
Endif

lRet := PlsVldGd({"BHT_TIPOCO", "BHT_CODOCO", "BHT_TIPPRE"})

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Pl800FilBB3
Filtra a tabela de cobranca do Sub-Contrato.

@author  PLS TEAM
@version P12
@since   12.04.16
/*/
//------------------------------------------------------------------- 
Function Pl800FilBB3(aCols, aHeader, nLine)
/*/
If Type("OBrwBB3") = "U"
	Return .T.
Endif

If oBrwBB3:Cargo	// Indica que esta visualizando tabelas anteriores
	Return aCols[nLine,GdFIELDPOS("BB3_TABVLD",AHEADER)] <> Ctod("")
Else
	//Return aCols[nLine,GdFIELDPOS("BB3_TABVLD",AHEADER)] =  Ctod("")
	Return aCols[nLine,GdFIELDPOS("BB3_TABVLD",AHEADER)] >=  dDataBase  .or. Empty(aCols[nLine,GdFIELDPOS("BB3_TABVLD",AHEADER)])
Endif
/*/
Return(.T.)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLS800NUM
Faz o incremento de um campo em uma GETDADOS

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLS800NUM(_cCampo, _oObj)
Local _nTam    := TamSX3(_cCampo)[1]
Local _cRet    := StrZero(1,_nTam)
Local _nInd    := 1
Local _nPos    := 0
Local _nMaior  := 0
Local _nAux
Local _aAux    := {}

If Type('aCols') == "A"
	If ValType(_oObj) <> "O"
	   _aAux    := aClone(aCols)
	Else
		If Len(_oObj:aCols) == 1 .and. Len(_oObj:aColsNoFil) > 1
			_aAux	:= aClone(_oObj:aColsNoFil)
		Else
		   _aAux	:= aClone(_oObj:aCols)
		Endif
	Endif
   _nPos    := PLRETPOS(_cCampo,nil,.F.)
Endif

If ( _nPos > 0 )
   For _nInd := 1 To Len(_aAux)
       If Len(_aAux[_nInd])< _nPos .or. ValType(_aAux[_nInd,_nPos])#"C"
          Loop
       EndIf
       _nAux := Val(_aAux[_nInd,_nPos])
       If _nAux > _nMaior .And. (Len(_aAux[_nInd])#Len(aHeader)+1 .or. ! _aAux[_nInd,Len(aHeader)+1])
          _nMaior := _nAux
          _cRet   := StrZero((_nMaior+1),_nTam)
       EndIf
   Next
Endif

Return(_cRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA800Gat
Gatilho inteligente que pega dados do folder classe de carencia ou
ou do proprio cadastro de classe de carencia.

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSA800Gat(nTipo)
LOCAL cDado
LOCAL cClaCar    := M->BAE_CLACAR
LOCAL nPosHeader := oBrwBAN:FieldPos("BAN_CLACAR")
LOCAL nPos       := 0

nPos := Ascan( oBrwBAN:aCols , { |x| x[nPosHeader] == cClaCar })

If nPos > 0
   If nTipo == 1
      cDado := oBrwBAN:FieldGet("BAN_QTDCAR",nPos)
   Else
      cDado := oBrwBAN:FieldGet("BAN_UNCAR",nPos)
   Endif
Else
   If nTipo == 1
      cDado := BDL->BDL_CARENC
   Else
      cDado := BDL->BDL_UNCAR
   Endif
Endif

Return(cDado)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLPROXVER
Retorna a ultima versao de um produto

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLPROXVER(cCodInt, cCodPro)
LOCAL cRetorno := Space(TamSx3("BT6_VERSAO")[1])
LOCAL nOrdBI3 := BI3->(IndexOrd())
LOCAL nRecBI3 := BI3->(Recno())

If cCodInt == Nil .and. cCodPro == Nil
	cCodint := M->BQC_CODINT
	cCodPro := M->BT6_CODPRO
Endif

BI3->(DbSetOrder(1))
BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPro+"999",.T.))

BI3->(DbSkip(-1))

If BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO) == xFilial("BI3")+cCodInt + cCodPro
	If BI3->BI3_STATUS <> '2'
		cRetorno := BI3->BI3_VERSAO
	Endif
Endif

If !Empty(cRetorno) .And. !Empty(BI3->BI3_SITANS) .And. BI3->BI3_SITANS <> '1'
	cRetorno := Space(TamSx3("BT6_VERSAO")[1])
Endif

BI3->(DbSetOrder(nOrdBI3))
BI3->(DbGoTo(nRecBI3))

Return(cRetorno)
//-------------------------------------------------------------------
/*/{Protheus.doc} A800VldVer
Valida a selecao da versao para a exclusao

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function A800VldVer(nOpc)
LOCAL i_
LOCAL lRet := .T.

If !Empty( oBrwVer:FieldGet("BIL_DATFIN") ) .and. nOpc == K_Excluir
	For i_ := 1 To Len(oBrwVer:acols)
		If Empty(oBrwVer:FieldGet("BIL_DATFIN", i_))
			MsgInfo("Esta versão está encerrada e existe outra em vigor... Primeiro exclua a versão em vigor!")
			lRet := .F.
			Exit
		Endif
	Next
Endif

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLVldBME
Valid dos campos BME_CODPSA e BME_VIGATE

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLVldBME()
Local cCodProc 	:= ""
Local dVigenc 	:= StoD("")
Local nI

Local lRet     := .T.
Local cDatDe  := ""
Local cDatAte := "" 
Local aChave  := {'01',M->BME_TIPPRE+M->BME_CODPAD+M->BME_CODPSA+M->BME_NIVEL,'BME_TIPPRE+BME_CODPAD+BME_CODPSA+BME_NIVEL'} //BME_TIPPRE+BME_CODPAD+BME_CODPSA+BME_NIVEL                                                                                                                                                                                                    

For nI := 1 to Len(oBrwPPP:aCols)
	cCodProc := oBrwPPP:aCols[nI,GdFieldPos("BME_CODPSA",oBrwPPP:aHeader)]
	cCodTab  := oBrwPPP:aCols[nI,GdFieldPos("BME_CODPAD",oBrwPPP:aHeader)]
	dVigenc	 := oBrwPPP:aCols[nI,GdFieldPos("BME_VIGATE",oBrwPPP:aHeader)]
	dVigde	 := oBrwPPP:aCols[nI,GdFieldPos("BME_VIGDE",oBrwPPP:aHeader)]

	If oBrwPPP:NOPCX == 3 .And. cCodProc == M->BME_CODPSA .And. cCodTab==M->BME_CODPAD .And. ;
	((M->BME_VIGDE >= dVigde .AND. M->BME_VIGDE <= dVigenc) .or. (M->BME_VIGATE >= dVigde .AND. M->BME_VIGATE <= dVigenc))
		Aviso(STR0071,STR0072,{"Ok"},1)
		Return(.F.)
	Endif


Next nI

	cDatDe  := "BME_VIGDE "
	cDatAte := "BME_VIGATE"
	lRet := PLSVLDVIG("BME" ,0   ,oBrwPPP,cDatDe  ,cDatAte  ,aChave)
	
Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLVlSitAn
Funcao de regras para validacao dos campos referentes a Situacao ANS

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLVlSitAn()

If M->BI3_SITANS = "1"
	M->BI3_STATUS	:= "1"
	M->BI3_DATBLO 	:= CtoD("")
Elseif M->BI3_SITANS == "3"
	M->BI3_STATUS	:= "2"
	M->BI3_DATBLO 	:= dDataBase
Else
	Return .T.
Endif

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Static Function MenuDef()
Private aRotina := {	{ STR0001   ,'AxPesqui'        , 0 , K_Pesquisar  , 0, .F.},; //'Pesquisar'
						{ STR0002	,'PLSA800Mov'      , 0 , K_Visualizar , 0, Nil},; //'Visualizar'
						{ STR0003	,'PLSA800Mov'      , 0 , K_Incluir    , 0, Nil},; //'Incluir'
						{ STR0004	,'PLSA800Mov'      , 0 , K_Alterar    , 0, Nil},; //'Alterar'
						{ STR0005	,'PLSA800Mov'      , 0 , K_Excluir    , 0, Nil},; //'Excluir'
						{ STR0006	,'PLSA800Mov'      , 0 , K_NovaVersao , 0, Nil},; //"Nova Versao"
						{ STR0007	,"PLSA800LEG"      , 0 , 0            , 0, .F.} } //"Legenda"	

If GetNewPar("MV_PLSUNI","1") == "1"
	aadd(aRotina, {STR0085 , "PLExRdA400", 0 ,K_Alterar,0,Nil})//"Exceções Rede A400"
EndIf 						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. utilizado para adicionar novas opcoes ao menu           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PL800MNU")
	aBtAdd := ExecBlock("PL800MNU",.F.,.F.,{aRotina})
	If ValType(aBtAdd) == "A"
		AEval(aBtAdd,{|x| AAdd(aRotina,x)})
	EndIf
EndIf
	
Return(aRotina)
//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVldBGD
Funca de validacao das datas de vigencia, chamada no botao de OK da Rotina Produtos / Tipo Prestador.
Tabela - BGS - GrEmpr x TpPres x Co-Part.

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PlsVldBGD()
Local lRet     := .T.
Local cDatDe   := ""
Local cDatAte  := ""
Local aChave   := {}
Local aArea	   := GetArea()

aChave := {'01',M->BGD_CODMUN+M->BGD_CODPAD+M->BGD_CODPRO+M->BGD_TIPO+cValToChar(M->BGD_QTD)+M->BGD_CODTAB+M->BGD_TIPUSR+M->BGD_GRAUPA+M->BGD_FINATE,'BGD_CODMUN+BGD_CODPAD+BGD_CODPRO+BGD_TIPO+BGD_QTD+BGD_CODTAB+BGD_TIPUSR+BGD_GRAUPA+BGD_FINATE'}
cDatDe   := "BGD_VIGINI"
cDatAte  := "BGD_VIGFIN"

lRet := PLSVLDVIG("BGD",0,oGetBGD,cDatDe,cDatAte,aChave)

RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVldBHI
Funca de validacao das datas de vigencia, chamada no botao de OK da Rotina Cobertura / Co-Participacao.
Tabela - BHI - Produto x Grp Cob x Co-Part.

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PlsVldBHI()
Local lRet     := .F.

If ExistBlock("PlsVlBHI")
   lRet := ExecBlock("PlsVlBHI",.F.,.F.,lRet)
Endif

If ! lRet
   If BHI->( FieldPos("BHI_VIGDE") ) > 0 .And. BHI->( FieldPos("BHI_VIGATE") ) > 0
	if ! Empty(M->BHI_VIGATE) .And. M->BHI_VIGDE > M->BHI_VIGATE
		MsgAlert("Vigência final menor que a inicial!")
	else
		lRet := .t.
	endif
   endif
Endif

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVldBHD
Funçao de validacao das datas de vigencia, chamada no botao de OK da Rotina Cobertura / Co-Participacao.
Tabela - BHD - Produtos e Co-Participacao.

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PlsVldBHD()
Local lRet     := .T.
Local cDatDe   := "BHD_VIGDE"
Local cDatAte  := "BHD_VIGATE"
Local aChave   := {}
Local aArea	   := GetArea()

aChave := {'01',M->BHD_CODPAD+M->BHD_CODPSA+M->BHD_TIPO+cValToChar(M->BHD_QTD)+M->BHD_CODTAB+M->BHD_GRPINT+M->BHD_TIPUSR+M->BHD_GRAUPA+M->BHD_FINATE,'BHD_CODPAD+BHD_CODPSA+BHD_TIPO+BHD_QTD+BHD_CODTAB+BHD_GRPINT+BHD_TIPUSR+BHD_GRAUPA+BHD_FINATE'}

lRet := PLSVLDVIG("BHD",0,oBrwPCo,cDatDe,cDatAte,aChave)

RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVldBHJ
Funca de validacao das datas de vigencia, chamada no botao de OK da Rotina Cobertura / Co-Participacao.
Tabela - BHJ - Produtos Co-Participacao.

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PlsVldBHJ()
Local lRet     := .T.
Local cDatDe   := "BHJ_VIGINI"
Local cDatAte  := "BHJ_VIGFIN"
Local aChave   := {}

Local aArea	   := GetArea()

aChave := {'01',M->BHJ_TIPO+cValToChar(M->BHJ_QTD)+M->BHJ_CODTAB+M->BHJ_TIPUSR+M->BHJ_GRAUPA+M->BHJ_FINATE,'BHJ_TIPO+BHJ_QTD+BHJ_CODTAB+BHJ_TIPUSR+BHJ_GRAUPA+BHJ_FINATE'}

lRet := PLSVLDVIG("BHJ",0,oBrwCoPar,cDatDe,cDatAte,aChave)

RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVldBCW
Funca de validacao das datas de vigencia, chamada no botao de OK da Rotina Cobertura / Co-Participacao.
Tabela - BCW - Prod x Cobert x Rda x Co-Part.

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PlsVldBCW()
Local lRet     := .T.
Local cDatDe   := ""
Local cDatAte  := ""
Local aChave   := {}
Local aArea	   := GetArea()

aChave := {'01', M->BCW_TIPPRE+M->BCW_TIPO+cValToChar(M->BCW_QTD)+M->BCW_CODTAB+M->BCW_TIPUSR+M->BCW_GRAUPA+M->BCW_FINATE,'BCW_TIPPRE+BCW_TIPO+BCW_QTD+BCW_CODPAD+BCW_TIPUSR+BCW_GRAUPA+BCW_FINATE'}
cDatDe   := "BCW_VIGINI"
cDatAte  := "BCW_VIGFIN"

lRet := PLSVLDVIG("BCW",0,oGetBCW,cDatDe,cDatAte,aChave)

RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVldBYK
Funca de validacao das datas de vigencia, chamada no botao de OK da Rotina Cobertura / Co-Participacao.
Tabela - BYK - Prod x Cobert x Rda x Co-Part.

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PlsVldBYK()
Local lRet     := .T.
Local cDatDe   := ""
Local cDatAte  := ""
Local aChave   := {}
Local aArea	   := GetArea()

aChave := {'01', M->BYK_GRPINT+M->BYK_TIPINT+cValToChar(M->BYK_QTD)+M->BYK_TIPUSR+M->BYK_GRAUPA+M->BYK_FINATE,'BYK_GRPINT+BYK_TIPINT+BYK_QTD+BYK_TIPUSR+BYK_GRAUPA+BYK_FINATE'}

cDatDe   := "BYK_VIGDE"
cDatAte  := "BYK_VIGATE"

lRet := PLSVLDVIG("BYK",0,oBrwBYK,cDatDe,cDatAte,aChave)

RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSQTDBHJ
Valida a quantidade quando nao existe data de vigencia Informada e nao permite quantidade duplicada.

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSQTDBHJ()
Local lRet := .F.
Local nX   := 0
Local nPosIni := ""
Local nPosFin := ""
Local nQTD    := ""
Local aArea	  := GetArea()
Local nUsado  := Len(oBrwCoPar:aHeader)

nQTD    := Ascan(oBrwCoPar:aHeader,{|x| Alltrim(x[2])=="BHJ_QTD"})
nPosIni := Ascan(oBrwCoPar:aHeader,{|x| Alltrim(x[2])=="BHJ_VIGINI"})
nPosFin := Ascan(oBrwCoPar:aHeader,{|x| Alltrim(x[2])=="BHJ_VIGFIN"})

For nX := 1 To Len(oBrwCoPar:aCols)
	If !oBrwCoPar:aCols[nX][nUsado+1]
		If nX < n
			If M->BHJ_VIGINI == CTOD(" / / ") .And. M->BHJ_VIGFIN == CTOD(" / / ")
				If M->BHJ_QTD == oBrwCoPar:aCols[nX][nQTD] .And. Empty(oBrwCoPar:aCols[nX][nPosIni]) .And. Empty(oBrwCoPar:aCols[nX][nPosFin])
					oBrwCoPar:cVldLine := 'PLSXANAFAI( {"BHJ_TIPO","BHJ_QTD","BHJ_TIPUSR","BHJ_VIGINI","BHJ_VIGFIN"},"BHJ_IDAINI","BHJ_IDAFIN",n)'
					Return lRet := .T.
				Endif
			Endif
		Endif
	Endif
Next nX

RestArea(aArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSQTDBCW
Valida a quantidade quando nao existe data de vigencia Informada e nao permite quantidade duplicada.

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSQTDBCW()
Local lRet := .F.
Local nX   := 0
Local nPosIni := ""
Local nPosFin := ""
Local nQTD    := ""
Local aArea	  := GetArea()
Local nUsado  := Len(oGetBCW:aHeader)

nQTD    := Ascan(oGetBCW:aHeader,{|x| Alltrim(x[2])=="BCW_QTD"})
nPosIni := Ascan(oGetBCW:aHeader,{|x| Alltrim(x[2])=="BCW_VIGINI"})
nPosFin := Ascan(oGetBCW:aHeader,{|x| Alltrim(x[2])=="BCW_VIGFIN"})

For nX := 1 To Len(oGetBCW:aCols)
	If !oGetBCW:aCols[nX][nUsado+1]
		If nX < n
			If M->BCW_VIGINI == CTOD(" / / ") .And. M->BCW_VIGFIN == CTOD(" / / ")
				If M->BCW_QTD == oGetBCW:aCols[nX][nQTD] .And. Empty(oGetBCW:aCols[nX][nPosIni]) .And. Empty(oGetBCW:aCols[nX][nPosFin])
					oGETBCW:cVldLine   := 'PLSXANAFAI( {"BCW_TIPO","BCW_QTD","BCW_TIPUSR","BCW_VIGINI","BCW_VIGFIN"},"BCW_IDAINI","BCW_IDAFIN",n)'
					Return lRet := .T.
				Endif
			Endif
		Endif
	Endif
Next nX

RestArea(aArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSQTDBGD
Valida a quantidade quando nao existe data de vigencia Informada e nao permite quantidade duplicada.

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSQTDBGD()
Local lRet := .F.
Local nX   := 0
Local nPosIni := ""
Local nPosFin := ""
Local nQTD    := ""
Local aArea	  := GetArea()
Local nUsado  := Len(oGetBGD:aHeader)

nQTD    := Ascan(oGetBGD:aHeader,{|x| Alltrim(x[2])=="BGD_QTD"})
nPosIni := Ascan(oGetBGD:aHeader,{|x| Alltrim(x[2])=="BGD_VIGINI"})
nPosFin := Ascan(oGetBGD:aHeader,{|x| Alltrim(x[2])=="BGD_VIGFIN"})

For nX := 1 To Len(oGetBGD:aCols)
	If !oGetBGD:aCols[nX][nUsado+1]
		If nX < n
			If M->BGD_VIGINI == CTOD(" / / ") .And. M->BGD_VIGFIN == CTOD(" / / ")
				If M->BGD_QTD == oGetBGD:aCols[nX][nQTD] .And. Empty(oGetBGD:aCols[nX][nPosIni]) .And. Empty(oGetBGD:aCols[nX][nPosFin])
					oGetBGD:cVldLine:= 'PLSVLDCOL({"BGD_TIPO","BGD_QTD","BGD_VIGINI","BGD_VIGFIN"}) .And. PLSXANAFAI( {"BGD_TIPO","BGD_QTD","BGD_TIPUSR","BGD_VIGINI","BGD_VIGFIN"},"BGD_IDAINI","BGD_IDAFIN",n)'
					Return lRet := .T.
				Endif
			Endif
		Endif
	Endif
Next nX

RestArea(aArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSQTDBHI
Valida a quantidade quando nao existe data de vigencia Informada e nao permite quantidade duplicada.

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PLSQTDBHI()
Local lRet := .F.
Local nX   := 0
Local nPosIni := ""
Local nPosFin := ""
Local nQTD    := ""
Local aArea	  := GetArea()
Local nUsado  := Len(oBrwGCo:aHeader)

nQTD    := Ascan(oBrwGCo:aHeader,{|x| Alltrim(x[2])=="BHI_QTD"})
nPosIni := Ascan(oBrwGCo:aHeader,{|x| Alltrim(x[2])=="BHI_VIGDE"})
nPosFin := Ascan(oBrwGCo:aHeader,{|x| Alltrim(x[2])=="BHI_VIGATE"})

For nX := 1 To Len(oBrwGCo:aCols)
	If !oBrwGCo:aCols[nX][nUsado+1]
		If nX < n
			If M->BHI_VIGDE == CTOD(" / / ") .And. M->BHI_VIGATE == CTOD(" / / ")
				If M->BHI_QTD == oBrwGCo:aCols[nX][nQTD] .And. Empty(oBrwGCo:aCols[nX][nPosIni]) .And. Empty(oBrwGCo:aCols[nX][nPosFin])
					oBrwGCo:cVldLine := 'PLSVLDCOL({"BHI_TIPO","BHI_QTD","BHI_TIPUSR","BHI_VIGDE","BHI_VIGATE"}) .And. PLSXANAFAI( {"BHI_TIPO","BHI_QTD","BHI_TIPUSR","BHI_VIGDE","BHI_VIGATE"},"BHI_IDAINI","BHI_IDAFIN",n)'
					Return lRet := .T.
				Endif
			Endif
		Endif
	Endif
Next nX

RestArea(aArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVldB86

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PlsVldB86()
Local lRet     := .T.
Local cDatDe   := ""
Local cDatAte  := ""
Local aChave   := {}
Local aArea	   := GetArea()

aChave := {'01', M->B86_CODPLA+M->B86_CODTAB+M->B86_FINATE,'B86_CODPLA+B86_CODTAB+B86_FINATE'}
cDatDe   := "B86_VIGDE"
cDatAte  := "B86_VIGATE"

lRet := PLSVLDVIG("B86",0,oBrwB86,cDatDe,cDatAte,aChave,,,,,.F.)

RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PL8000HSal
Apresenta a dialog com informacoes de historicos de reajuste de cobranca de acordo com a forma selecionada

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function PL8000HSal()
LOCAL aArea			:= GetArea()
LOCAL cCodFor		:= oBrwFor:FieldGet("BJ3_CODFOR")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Consiste dados nescessarios...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	Empty(cCodFor)
	MsgAlert("Preencha os dados da Forma de Cobrança antes de continuar")
	Return
Endif

If cCodFor <> "108"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega por faixa etaria...                                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PLSHISFAI("BK8",BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO),"BK8->(BK8_FILIAL+BK8_CODOPE+BK8_CODPRO+BK8_VERSAO)",1)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega por faixa salarial...                                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(aArea)
	PLSHISFAI("BYR",BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO),"BYR->(BYR_FILIAL+BYR_CODOPE+BYR_CODPRO+BYR_VERSAO)",2)
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} B61DesRda

@author  PLS TEAM
@version P12
@since   07.12.00
/*/
//------------------------------------------------------------------- 
Function B61DesRda()
local cNomeRda := ""

If !Inclui
	cNomeRda := Posicione("BAU",1,xFilial("BT4")+cCodRda,"BAU_NOME")
EndIf
                                                      
Return cNomeRda

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRAtA400
Função para tratar excecoes da Rede Referenciada do PTU A400

@author  PLS TEAM
@version P11
@since   01.06.16
/*/
//------------------------------------------------------------------- 
Function PLExRdA400()
Local aCabRdAt 	:= {}
Local cSQL 	   	:= ""
Local nI		:= 0
Local nOpca		:= 0
Local aSize 	:= {}
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local oDlg
Local bCancel 	:= {|| nOpca := 0,If(MsgYesNo(__cMsgAban),(oDlg:End()),.F.) }     
Local bOk       := {|| nOpca := 1,oDlg:End() }
Local aDadRDat  := {}
Local aTrbRdAt  := {}  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis versao                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cVerEsc   := BI3->BI3_VERSAO 
Local aDadVer := {}      
Local aCabVer := {}  
Local aTrbVer := {}   
Local cChave  := BI3->(BI3_CODINT+BI3_CODIGO)   
Local oDlgFolder

Private oBrwRdAt           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe a tabela B3Z                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !PLSALIASEXI("B3Z")
	Aviso(STR0086,STR0087,{STR0075})//"Aviso"###"Para executar esta opção, é necessário criar a tabela B3Z através do compatibilizador UPDPLSZD" ###Ok
    Return
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se tem versoes                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
AAdd( aObjects, { 100, 200, .T., .T. } )
AAdd( aObjects, { 200, 100, .T., .T.,.T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T. )
aPosObj[1][2]+=15

Store Header "BIL" TO aCabVer For .T.
BIL->(DbSetOrder(1))
BIL->(DBGoTop())
If BIL->(MsSeek(xFilial("BIL")+cChave+"001"))
	Store COLS "BIL" TO aDadVer FROM aCabVer VETTRAB aTrbVer While cChave == BIL->(BIL_CODIGO)
Else
	Help("",1,"PLSA800VE")
	Return
Endif       

If Len(aDadVer) > 1
	DEFINE MSDIALOG oDlgFolder TITLE OemtoAnsi(STR0010) FROM aSize[7],0 To aSize[6],aSize[5] PIXEL OF GetWndDefault() //"Versao do Plano"
 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TPLSBRW -> VERSOES                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Val(GetVersao(.F.)) >= 12 //Valida versão 12
		oBrwVer := TPLSBrw():New(035,007,600,200	   ,nil  ,oDlgFolder,nil    , {|| nOpca := 1,cVerEsc := oBrwVer:aCols[oBrwVer:Linha(),oBrwVer:PLRETPOS("BIL_VERSAO")], oDlgFolder:End() } ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabVer,aDadVer,.F.,"BIL",K_Visualizar,"VersÕes do Plano",{{"BIL_DATFIN","=",ctod("")}})
	Else
		oBrwVer := TPLSBrw():New(2 ,2  ,aPosObj[2,3]-15,aPosObj[2,4]-15,nil  ,oDlgFolder,nil    , {|| nOpca := 1,cVerEsc := oBrwVer:aCols[oBrwVer:Linha(),oBrwVer:PLRETPOS("BIL_VERSAO")], oDlgFolder:End() } ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabVer,aDadVer,.F.,"BIL",K_Visualizar,"VersÕes do Plano",{{"BIL_DATFIN","=",ctod("")}})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa o dialogo...                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDlgFolder:lEscClose := .F.

	ACTIVATE MSDIALOG oDlgFolder Center ON INIT EnchoiceBar(oDlgFolder,{|| Iif(A800VLDVER(K_Alterar) ,(nOpca := 1,cVerEsc := oBrwVer:aCols[oBrwVer:Linha(),oBrwVer:PLRETPOS("BIL_VERSAO")], oDlgFolder:End()),NIL)},{|| nOpca := 2,oDlgFolder:End()})

EndIf  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tela para informar RDAs                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}

AAdd( aObjects, { 100, 100, .t., .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )


DEFINE MSDIALOG oDlg TITLE STR0088 From aSize[7],0 to aSize[6]-100, aSize[5]-478 PIXEL //"Exceções da Rede Referenciada para o A400" 	

If Len(aCabRdAt) == 0
	Store Header "B3Z" TO aCabRdAt For .T.
Endif

If Len(aDadRdAt) == 0

    cSQL := " SELECT * FROM "+RetSqlName("B3Z")+" WHERE "
    cSQL += " B3Z_FILIAL = '"+xFilial("B3Z")+"' AND "
    cSQL += " B3Z_CODIGO = '"+BI3->(BI3_CODINT+BI3_CODIGO)+"' AND "   
    cSQL += " B3Z_VERSAO = '"+cVerEsc+"' AND "   
    cSQL += " D_E_L_E_T_ = ' ' "
    cSQL += " ORDER BY B3Z_CODRDA "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"B3ZTMP",.F.,.T.)

    If B3ZTMP->(Eof())
		Store COLS Blank "B3Z" TO aDadRdAt FROM aCabRdAt
	Else
		lB3ZVazio := .F. 
		While !B3ZTMP->(Eof())

			Aadd(aDadRdAt,Array(Len(aCabRdAt)+1))

			B3Z->(MsGoto(B3ZTMP->R_E_C_N_O_))

			For nI := 1 To Len(aCabRdAt)
				If ( aCabRdAt[nI,10] !=  "V" )
					aDadRdAt[Len(aDadRdAt)][nI] := B3ZTMP->(FieldGet(FieldPos(aCabRdAt[nI,2])))
				Else
					aDadRdAt[Len(aDadRdAt)][nI] := CriaVar(aCabRdAt[nI,2],.T.)
				EndIf
			Next nI
			aDadRdAt[Len(aDadRdAt)][Len(aCabRdAt)+1] := .F.

			Aadd(aTrbRdAt, B3ZTMP->R_E_C_N_O_ )

			dbSelectArea("B3ZTMP")
			dbSkip()

		EndDo

	EndIf
	B3ZTMP->(dbCloseArea())
Endif

dbSelectArea("B3Z")

oBrwRdAt := TPLSBrw():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3]-233,aPosObj[1][4]-27,nil,oDlg,nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabRdAt,aDadRdAt,.F.,"B3Z",K_Alterar/*nOpcx*/,"Rede Ref. para A400.",nil,nil,nil,aTrbRdAt,/*"PLSRAtVld()"*/,nil/*delete*/)

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,bOk,bCancel,.F.,{})

If nOpca == 1   
	aDadRdAt := aClone(oBrwRdAt:aCols) 
	aChave := {}
	aadd(aChave,{"B3Z_CODIGO",BI3->(BI3_CODINT+BI3_CODIGO)})
	aadd(aChave,{"B3Z_VERSAO",cVerEsc})
	oBrwRdAt:nOpc := K_Alterar
	oBrwRdAt:Grava(aChave)   
EndIf

Return
             
//-------------------------------------------------------------------
/*/{Protheus.doc} PL800RdaPT
Valid do campo B3Z_CODRDA

@author  PLS TEAM
@version P11
@since   01.06.16
/*/
//------------------------------------------------------------------- 
Function PL800RdaPT()
Local lRet 		:= .T.
Local nX   		:= 0
Local nPosRDA	:= aScan(oBrwRdAt:aHeader,{|x|x[2] == "B3Z_CODRDA"})
Local nPosLoc	:= aScan(oBrwRdAt:aHeader,{|x|x[2] == "B3Z_CODLOC"})
Local nPosGrp	:= aScan(oBrwRdAt:aHeader,{|x|x[2] == "B3Z_CDGRSR"})
For nX := 1 to len(oBrwRdAt:aCols)
	If oBrwRdAt:aCols[nX][nPosRDA] == 	M->B3Z_CODRDA .And. oBrwRdAt:aCols[nX][nPosGrp] == M->B3Z_CDGRSR .And. oBrwRdAt:aCols[nX][nPosLoc] == M->B3Z_CODLOC
		MsgInfo(STR0089+M->B3Z_CODRDA+STR0090) //"A Rede de Atendimento " ### " já foi informada."
		lRet := .F.
		Exit  	     
	EndIf
Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL800BMD
Valida a Data de Vigencia

@author  PLS TEAM
@version P12
@since   01/11/2017
/*/
//------------------------------------------------------------------- 

Function PL800BMD() 

Local lRet     := .T.
Local cDatDe  := ""
Local cDatAte := "" 
Local aChave  := {'01',M->BMD_TIPPRE,'BMD_TIPPRE'} //BMD_FILIAL + BMD_CODIGO + BMD_VERSAO + BMD_TIPPRE                                                                                                               

	cDatDe  := "BMD_VIGDE "
	cDatAte := "BMD_VIGATE"
	lRet := PLSVLDVIG("BMD" ,0   ,oBrwPPg,cDatDe  ,cDatAte  ,aChave)

Return(lRet)  
