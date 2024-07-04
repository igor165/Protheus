#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSA001a.ch"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMGER2.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#DEFINE G_REEMBOLSO "04"

STATIC oEnchoice := nil
STATIC oBrwPro	 := nil
STATIC aAutFor   := {}
STATIC lBAU	   	 := .f.
STATIC aDelItens := {} 
STATIC oBrwComp	 := nil
STATIC aTrbComp  := {}
STATIC aDadComp  := {}
STATIC aCabComp  := {}
STATIC __lConfma := .F.
STATIC aLgCores  := {	{ 'BR_VERDE'   ,"Autorizada" },; //'Autorizada'
						{ 'BR_VERMELHO',"Nao autorizada" }} //'Nao Autorizada'

STATIC aAreaBOW := {} 
STATIC aAreaB1N := {}  
STATIC aAreaB44 := {} 
STATIC aAreaB45 := {}  
STATIC aAreaB47 := {}  
STATIC aAreaSE2 := {}  

STATIC objCENFUNLGP := CENFUNLGP():New() 

//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
STATIC lPlsSA2	 		:= ExistBlock('PLS001ASA2')



#define __aCdCri032 {"540",STR0001} //"Erro controlado SIGAPLS."
#define __aCdCri089 {"055",STR0002}   //"A Data/Hora autorizada e diferente da Data/Hora apresentada/cobrada pela operadora destino."
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA001A ³ Autor ³ Everton M. Fernandes	³ Data ³ 20.02.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Reembolso                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA001A(cFiltro) 

LOCAL cFiltroBOW  := cFiltro 
Local aCdCoresAux := {}
Local aCoresAux   := {}
Local nI:=0
Local aAtalMenu   := {}  

//Legendas do protocolo.
PRIVATE aCdCores := { 	{ 'BR_AMARELO'    , STR0149},;	//"Protocolado"
						{ 'BR_AZUL'       , STR0150},;	//"Em analise"
						{ 'BR_BRANCO'     , STR0151},;	//"Deferido"
						{ 'BR_CINZA'      , STR0152},;	//"Indeferido"
						{ 'BR_VIOLETA'    , STR0153},;	//"Em digitação"
						{ 'BR_VERDE'      , STR0154},;	//"Lib. financeiro"
						{ 'BR_MARRON'     , STR0155},;	//"Não lib. financeiro"
						{ 'BR_VERMELHO'   , STR0156},;	//"Glosado"
						{ 'BR_PRETO '     , STR0157},;	//"Auditoria"
						{ 'NGBIOALERTA_01', STR0232},;	//"Solicitação não concluída"
						{ 'BR_PINK'       , STR0233},;	//"Aguardando informação Beneficiária"
						{ 'BR_AZUL_OCEAN' , STR0234},;	//"Aprovado parcialmente"
						{ 'BR_CANCEL'     , STR0235},;	//"Cancelado"
						{ 'BR_LARANJA'    , STR0283} }	//"Reembolso Revertido"

PRIVATE aCores := { { 'BOW_STATUS = "1"', aCdCores[ 1,1]},;//vermelho
					{ 'BOW_STATUS = "2"', aCdCores[ 2,1]},;//azul
					{ 'BOW_STATUS = "3"', aCdCores[ 3,1]},;//amarelo
					{ 'BOW_STATUS = "4"', aCdCores[ 4,1]},;//azul
					{ 'BOW_STATUS = "5"', aCdCores[ 5,1]},;//amarelo
					{ 'BOW_STATUS = "6"', aCdCores[ 6,1]},;//azul
					{ 'BOW_STATUS = "7"', aCdCores[ 7,1]},;//amarelo
					{ 'BOW_STATUS = "8"', aCdCores[ 8,1]},;//amarelo
					{ 'BOW_STATUS = "9"', aCdCores[ 9,1]},;//verde
					{ 'BOW_STATUS = "A"', aCdCores[10,1]},;//Solicitação não concluída
					{ 'BOW_STATUS = "B"', aCdCores[11,1]},;//Aguardando informação Beneficiária
					{ 'BOW_STATUS = "C"', aCdCores[12,1]},;//Aprovado parcialmente
					{ 'BOW_STATUS = "D"', aCdCores[13,1]},;//Cancelado
					{ 'BOW_STATUS = "E"', aCdCores[14,1]} }//Reembolso Revertido

//Define o cabecalho da tela de atualizacoes                               
PRIVATE aRotina :=  If(EMPTY(cFiltro), { 	{ STR0109, 'AxPesqui' , 0 , 1 },; //'Pesquisar'
						{ STR0110, 'PLBOWMOV' , 0 , 2	},; //'Visualizar'
						{ STR0111, 'PLBOWMOV' , 0 , 3	},; //'Incluir'
						{ STR0118, 'PLBOWMOV' , 0 , 4	},; //'Alterar'
						{ STR0112, 'PLBOWMOV' , 0 , 5	},;// 'Excluir'
						{ STR0119, 'PLBOWHIS("BOW",BOW->BOW_PROTOC)' , 0 ,2 	},; //'Historico'
						{ STR0158, 'PL001ALeg'  , 0 , 6	},; //'Legenda'
						{ STR0120, 'TIPRELAT()' , 0 , 2	},; // 'Imp. Protocolo'
						{ STR0251, 'PLGRVBK6("MOA")' , 0 , 2	},;//Verifica rede cadastro
						{ STR0170, 'MsAguarde({||PLSGERAUT(.T.) }, "Aguarde", "Processo em andamento...", .F.)'  , 0 , K_Incluir	},;//"Gerar aut. Reemb." 
						{ STR0253, 'PLBrwRmbCan', 0 , 2},;//"Protocolos Cancelados"
						{ STR0281, 'PLSPREREV', 0 , 2}}, { 	{ STR0110, 'PLBOWMOV' , 0 , 2 }})//"Reverter Reembolso"

PRIVATE cFilter	  := ""
private cTipoSolicitacao	:= ""
private cProtoc 			:= ""
private cNomBen 			:= ""
private cDatPar 			:= ""
private cMotiv 			:= ""
private cItens 			:= ""
private cDtProvPagto 	:= ""
private cValTot 			:= ""
private cStatusAut 		:= ""
private lRever := .F.

PlsLogFil('Abertura do browser do protocolo de reembolso', "TRAVA_TMK_PROREE_" + FunName() + "_"+ RetCodUsr()+".LOG")

If EMPTY(cFiltro)

	PlsLogFil('cFiltro vazio', "TRAVA_TMK_PROREE_" + FunName() + "_"+ RetCodUsr()+".LOG")
	// Ponto de entrada para incluir dois atalhos no outras ações de fora do protocolo de reembolso
	If ExistBlock("PLSKEYPRT")  
		
		PlsLogFil('Acessou ponto de entrada PLSKEYPRT', "TRAVA_TMK_PROREE_" + FunName() + "_"+ RetCodUsr()+".LOG")
		aAtalMenu := ExecBlock("PLSKEYPRT",.F.,.F.,{})
		PlsLogFil('Saiu do ponto de entrada PLSKEYPRT', "TRAVA_TMK_PROREE_" + FunName() + "_"+ RetCodUsr()+".LOG")

		If ValType(aAtalMenu) == "A"

			If LEN(aAtalMenu) > 0
				SetKey(VK_F5,{|| &(aAtalMenu[1]) }) 
			EndIf

			If LEN(aAtalMenu) == 2
				SetKey(VK_F6,{|| &(aAtalMenu[2]) }) 
			EndIf
		EndIf
	EndIf 

	SetKey(VK_F2,{|| PLBOWHIS("BOW",BOW->BOW_PROTOC)}) // Historico do reembolso 
	SetKey(K_ALT_Z,{|| PLGRVBK6("MOA")}) // Verifica cadastro rede 
	SetKey(VK_F4,{|| PLBrwRmbCan()}) // Protocolos cancelados  
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. utilizado para adicionar novas opcoes ao menu           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLBOWBTADD")

	aBtAdd := ExecBlock("PLBOWBTADD",.F.,.F.,{aRotina})
	
	If ValType(aBtAdd) == "A"
		AEval(aBtAdd,{|x| AAdd(aRotina,x)})
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega criticas padroes												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLBOWCarCr()
BCS->(dbSetOrder(1))
If !BCS->(MsSeek(xFilial("BCS")+PLSINTPAD()+"04"))
	Help("",1,"PLBOW012")
	Return
Endif

If ExistBlock("PL001FIL")
	cFiltroBOW := Execblock("PL001FIL", .f., .f.)
Endif

If Valtype(cFiltroBOW) == "U"
	cFiltroBOW := ""
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. utilizado para adicionar novos status                   ³
// Pode se usar a ferramenta U_FSBITMAP do Ernani para descobrir ³
// todos os icones disponiveis usar como imagem                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLREEMDCOR")
	aCdCoresAux := ExecBlock("PLREEMDCOR ",.F.,.F.)
	
	For nI:=1 to len(aCdCoresAux)
		aAdd(aCdCores,{ aCdCoresAux[nI][1], aCdCoresAux[nI][2] })
	Next
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. utilizado para adicionar a relação entre novos status x posição no array  ³
// Importante: O array para adicionar novos status deve iniciar na posição 15      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLREEMACOR")
	
	aCoresAux := ExecBlock("PLREEMACOR",.F.,.F.,{ })
	
	For nI:=1 to len(aCoresAux)
		aAdd(aCores,{ aCoresAux [nI][1], aCoresAux [nI][2] })
	Next
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BOW->(DbSetOrder(1))
BOW->(DbGoTop())

BOW->(mBrowse(006,001,022,075,"BOW",,,,,,aCores,,,,,   ,,,cFiltroBOW))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLBOWMOV ³ Autor ³ Everton M. Fernandes	³ Data ³ 20.02.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Movimentacao do Cadastro de Reembolso                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLBOWMOV(cAlias,nReg,nOpc,cBenef,cCodInte,cCodEmp,cMatric,cTipreg,cDigito,lRevers,cNumProTMK,lSemComp,lAutomato) 
LOCAL aCores    := {{ 'BOW_STATUS = "1"',aLgCores[1,1] },;
					{ 'BOW_STATUS = "2"',aLgCores[2,1] }}
LOCAL aArea 	:= GetArea()
Local I__f 		:= 0
Local nOpca		:= 0
LOCAL oDlg		:= Nil
Local aPosObj	:= {}
Local aObjects	:= {}
Local aSize		:= {}
Local aInfo		:= {}
Local aRetorno	:= {}
Local aColsB1N  := {}
Local aHeadB1N  := {}
local aVtTbB1N	:= {}
LOCAL bOK		:= {|| nOpca := 1, Iif(PBOWVld(oEnchoice,nOpc,@oBrwPro),(PBOWFinal(oEnchoice,nOpc, oBrwPro:aCols, aHeadB1N , oBrwComp:aCols,aCabComp),PLSANXEC(nOpc),oDlg:End()),NIL)} 
LOCAL bCancel	:= {}
LOCAL aValReem	:= {}
LOCAL aButtons	:= {}
LOCAL oFontNum	:= Nil
LOCAL oFontAutor:= Nil
LOCAL oFontTit	:= Nil
LOCAL lValidVis := .T.
LOCAL lDtPagto 	:= GETNEWPAR("MV_PLSDTPG",.F.)
LOCAL bFilPE	:= ""
LOCAL bBakDelete
LOCAL nI
LOCAL nCount
LOCAL nTotItens := 0
LOCAL aRetBtn	:= {}
LOCAL aVetTab:={}
Local cProtoc:=""
local cProtocTempRever := ""
local i
local cPosicao
local cNumTit
local dDatValid
local cSeq
local __cCodigo
local __cNumBDC
local lEna
local lRet 		:= .t.
local cValid 	:= ""
Local lVlrTot 	:= B1N->(FieldPos("B1N_VLRTOT")) > 0 
Local lAbreSem 	:= (nOpc == K_Excluir .OR. nOpc == K_Alterar)
Local nPosArray := 0 
Local cSequen   := ""
Local cMatBenef := ""
Local cCdproced := ""
Local cDescMot  := ""
Local cCodUsr   := RETCODUSR() 
Local lAprovado := .F. 
Local aAtalhos  := {}   
Local nValAux	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Tipo 01                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oSay		:= Nil
PRIVATE cCadastro	:= STR0003  //"Protocolo de reembolso"
DEFAULT cBenef		:=	""
DEFAULT cCodInte	:=	""
DEFAULT cCodEmp		:=	""
DEFAULT cMatric		:=	""
DEFAULT cTipreg		:=	""
DEFAULT cDigito		:=	""
DEFAULT lRevers 	:= .F.
DEFAULT cNumProTMK	:= ""
DEFAULT lSemComp    := .F. 

Private cTlmkReem	:=""
Private cCodTab := GETNEWPAR("MV_PLSTBPD","01")
Private cStatusAnterior := BOW->BOW_STATUS

bCancel := {|| nOpca := 2,oDlg:End(), RollBackSX8()}

If nOpc == K_Alterar
	B44->(dbSetOrder(4))
	If B44->(MsSeek(xFilial("B44") + BOW->BOW_PROTOC))
		if B44->(B44_FILIAL + B44_PROTOC) = xFilial("B44") + BOW->BOW_PROTOC
			MsgAlert( STR0315  ) //"Existe autorização vinculada à este protocolo que impede essa alteração."   
			Return()
		Endif
	Endif
		
endif

If lAbreSem
		
	nHReemb := PLSAbreSem(BOW->(BOW_FILIAL+BOW_PROTOC)+".SMF",.F.)
		
	If nHReemb == 0
		MsgAlert("Autorização de reembolso em processo de geração por outro usuário")
		Return()
	EndIf
EndIf
DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-012 BOLD
aAutFor  := {}
Aadd(aButtons, {"MotGlo",{|| VisMotExc()  },"Mot. Glosa"})
Aadd(aButtons, {"ExcItem",{|| PLSEXITRE()},"Glosar Item"})
Aadd(aButtons, {"Conhec",{|| P001ACONH(nOpc)},"Anexos"}) 
Aadd(aButtons, {"Receitas",{|| PLCONSREC("BOW", oBrwPro)},"Receitas"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. para manipular o array aButtons                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("ABTN001A")
	
	aButtons := aClone( ExecBlock( "ABTN001A",.F.,.F.,{aButtons} ))
	
	If ValType( aButtons ) <> "A"
		MsgStop( STR0243,STR0049 ) //"Retorno do ponto de entrada ABTN001A inválido"##"Atenção"
		Return Nil
	Endif
EndIf

// Ponto de entrada para incluir dois atalhos no outras ações de dentro do protocolo de reembolso
If ExistBlock("PLSKEY01A") 

	aAtalhos := ExecBlock("PLSKEY01A",.F.,.F.,{})
	
	If ValType(aAtalhos) == "A"

		If LEN(aAtalhos) > 0
			SetKey(VK_F11, {|| &(aAtalhos[1]) }) 
		EndIf

		If LEN(aAtalhos) == 2
			SetKey(VK_F12, {|| &(aAtalhos[2]) }) 
		EndIf
	EndIf
EndIf 
 
SetKey(VK_F7   , {|| MsDocument("BOW", BOW->( RecNo() ), 1)})
SetKey(VK_F8   , {|| PLCONSREC("BOW", oBrwPro)}) //Receitas 
SetKey(VK_F9   , {|| PLSEXITRE()}) // Glosar itens 
SetKey(VK_F10  , {|| VisMotExc()}) // Mot. Glosa 

// P.E. Ponto de entrada para adicionar rotinas no aButtons
If ExistBlock("PL001ADBT")

	aRetBtn := ExecBlock("PL001ADBT",.F.,.F.,{aButtons})
		
	If Type("aRetBtn") == "A"
		aButtons := aRetBtn
	Else
	
	 	FWLogMsg('WARN',, 'SIGAPLS', 'PLSA001A', '', '01', STR0247, 0, 0, {})
		
	EndIf
EndIf

if Type("lRever") <> "U"
	lRevers := lRever
endif

B00->(DbSetOrder(1))
BOW->(DbSetOrder(1))

//Verifica se já existe protocolo para o atendimento corrente; se sim, muda a opção para 'alterar' e carrega a tela com o protocolo da B00
if !Empty(cNumProTMK) .and. B00->(DbSeek(xFilial("B00") + cNumProTMK)) .and. BOW->(DbSeek(xFilial("BOW") + cNumProTMK))
	nReg := BOW->(RecNo()) //Captura o recno
	nOpc := 4 //Alteração
endif

If nOpc == K_Excluir
	B44->(dbSetOrder(4))
	If B44->(MsSeek(xFilial("B44") + BOW->BOW_PROTOC))
		if B44->(B44_FILIAL + B44_PROTOC) = xFilial("B44") + BOW->BOW_PROTOC
			MsgAlert( STR0305  ) //"Existe autorização vinculada à este protocolo, não é possível a Exclusão, Necessário excluir a Autorização "   
			Return()
		Endif
	Endif
endif

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aCols e aHeader...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacoes iniciais														 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BAU->(DbSetOrder(1))
	If ! BAU->(MsSeek(xFilial("BAU")+GetMV("MV_PLSRDAG")))
		Help("",1,"PLBOWBOW")
		Return
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enchoice 		                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	if lRevers
		Copy "BOW" TO Memory
		cProtocTempRever := M->BOW_PROTOC
		M->BOW_PROTOC := P773GerPro()
		M->BOW_STATUS := "2"
		M->BOW_DTDIGI := dDataBase
		M->BOW_CDOPER := PswRet(1)[1][1]
		M->BOW_NOMOPE := PswRet(1)[1][2]
		M->BOW_PROORI := cProtocTempRever
	else
		Copy "BOW" TO Memory Blank
	endif
	
	If !Empty(AllTrim(cBenef))
		SX3->(DbSetOrder(2))
		SX3->(MsSeek("BOW_USUARI"))
		M->BOW_USUARI := cBenef

		If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .OR. empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .OR. empty(SX3->X3_VLDUSER))	
			If FunName() == "TMKA271" .And. GetNewPar("MV_PLRN395","0") == "1" .And. !Empty(cNumProTMK)
				M->BOW_PROTOC := cNumProTMK
				
			Else
				M->BOW_PROTOC := P773GerPro()
			EndIf	
			
			RunTrigger(1)			
		Elseif funname() == "TMKA271" //VERIFICAR SE O FUNNAME VEIO DO CALLCENTER E FAZER O DIALOG END
			Return
		Endif
		
		
		If ExistBlock("PL773PE2")
			
			//verificando se é usuário de intercambio
			If  SubStr(M->BOW_USUARI,1,4) != PlsIntPad()
				lInterc := .T.
			Else
				lInterc := .F.
			EndIf 
					
			//execução do ponto de entrada que é possível alterar número de protocolo gerado, caso exista PL773PE2
			
			M->BOW_PROTOC := ExecBlock("PL773PE2",.F.,.F.,{"BOW",M->BOW_PROTOC,.F.,.F.,nOpc,.F.,""})

		EndIf		
		
		
		
		
				
	EndIf
	
	If !Empty(AllTrim(cCodInte))
		M->BOW_OPEUSR := cCodInte
	Endif
	
	If !Empty(AllTrim(cCodEmp))
		M->BOW_CODEMP := cCodEmp
	Endif
	
	
	If !Empty(AllTrim(cMatric))
		M->BOW_MATRIC := cMatric
	Endif
	
	
	If ! Empty(AllTrim(cTipreg))
		M->BOW_TIPREG := cTipreg
	Endif
	
	
	If !Empty(AllTrim(cDigito))
		M->BOW_DIGITO := cDigito
	Endif
	
	If Empty(M->BOW_PROTOC)
		M->BOW_PROTOC := P773GerPro()
		If ExistBlock("PL773PE2")
			
			//verificando se é usuário de intercambio
			
			//execução do ponto de entrada que é possível alterar número de protocolo gerado, caso exista PL773PE2
			
			M->BOW_PROTOC := ExecBlock("PL773PE2",.F.,.F.,{"BOW",M->BOW_PROTOC,.F.,.F.,nOpc,.F.,""})

		EndIf		
		
	EndIf

Else
	
	Copy "BOW" TO Memory
	
	cOpeMov    := BOW->BOW_OPEMOV
	cAnoAut    := BOW->BOW_ANOAUT
	cMesAut    := BOW->BOW_MESAUT
	cNumAut    := BOW->BOW_NUMAUT
	cChave     := BOW->(BOW_OPEUSR+BOW_CODLDP+BOW_CODPEG+BOW_NUMAUT+BOW_ORIMOV)
	cProtoc	   := BOW->BOW_PROTOC
	
	If nOpc <> K_Incluir
		lValidVis := .F.
	Endif
	
	PLSA090USR(BOW->(BOW_OPEUSR+BOW_CODEMP+BOW_MATRIC+BOW_TIPREG+BOW_DIGITO),Date()/*BOW->BOW_DATPRO*/,/*BOW->BOW_HORPRO*/,"BOW",.F.,;
	nil,nil,nil,nil,nil,nil,nil,nil,nil,;
	nil,nil,nil,lValidVis,Iif(nOpc == K_Incluir,.T.,.F.))
	
	If nOpc == K_Incluir

		PLSA090RDA(BOW->BOW_OPERDA,BOW->BOW_CODRDA,"1",/*BOW->BOW_DATPRO*/,;
					BOW->(BOW_OPEUSR+BOW_CODEMP+BOW_MATRIC+BOW_TIPREG),;
					BOW->BOW_LOCATE,BOW->BOW_CODESP,"BOW",.F.)
	Endif
	
	BDS->(DbSetOrder(1))
	If BDS->(MsSeek(xFilial("BDS")+BOW->(BOW_OPEMOV+BOW_ANOAUT+BOW_MESAUT+BOW_NUMAUT+"1")))
	
		While ! BDS->(Eof()) .And. BDS->(BDS_FILIAL+BDS_OPEMOV+BDS_ANOAUT+BDS_MESAUT+BDS_NUMAUT+BDS_ORIGEM) == ;
										xFilial("BDS")+BOW->(BOW_OPEMOV+BOW_ANOAUT+BOW_MESAUT+BOW_NUMAUT+"1")
			
			aadd(aAutFor,{.F.,BDS->BDS_CODPAD,BDS->BDS_CODPRO,BDS->BDS_OPEMOV,BDS->BDS_ANOAUT,BDS->BDS_MESAUT,;
							BDS->BDS_NUMAUT,BDS->(Recno()),BDS->BDS_OPESIS,BDS->BDS_DATA,BDS->BDS_HORA,,,Iif( BDS->(FieldPos("BDS_SEQUEN")) > 0,BDS->BDS_SEQUEN,"BOW")})
							
			BDS->(DbSkip())
		Enddo
	Endif
	
Endif

If PLSALIASEX("B1N")

	Store Header "B1N" to aHeadB1N for .T.
	
	If nOpc == K_Incluir
	
		Store COLS Blank "B1N" TO aColsB1N FROM aHeadB1N
		
		if lRevers
		
			B1N->(dbSetOrder(1))
			If B1N->(MsSeek(xFilial("B1N") + cProtocTempRever/*M->BOW_PROTOC*/))
		
				Store COLS "B1N" TO aColsB1N FROM aHeadB1N VETTRAB aVtTbB1N While B1N->(B1N_FILIAL+B1N_PROTOC) == xFilial("BOW")+cProtocTempRever/*BOW->(BOW_PROTOC)*/
				
				for i := 1 to len(aHeadB1N)
		
					if aHeadB1N[i][2] = "B1N_PROTOC"
						cPosicao := i
					endif
		
				next
				
				for i := 1 to len(aColsB1N)
					aColsB1N[i][cPosicao] := M->BOW_PROTOC
				next
			else
				Store COLS Blank "B1N" TO aColsB1N FROM aHeadB1N
			endIf
			
		endif
		
	else
		
		B1N->(dbSetOrder(1))
		If B1N->(MsSeek(xFilial("B1N")+M->BOW_PROTOC))
			Store COLS "B1N" TO aColsB1N FROM aHeadB1N VETTRAB aVtTbB1N While B1N->(B1N_FILIAL+B1N_PROTOC) == xFilial("BOW")+BOW->(BOW_PROTOC)
		Else
			Store COLS Blank "B1N" TO aColsB1N FROM aHeadB1N
		EndIf
		
	EndIf
	
EndIf

//GetDados - Composicao                                                    
If nOpc == K_Incluir
	DbSelectArea("B7M")
	
	If Len(aCabComp) == 0
		Store Header "B7M" TO aCabComp For .T.
	Endif
	
	store COLS Blank "B7M" TO aDadComp FROM aCabComp
	
	if lRevers
	
		B7M->(DbSetOrder(1))
		B7M->(MsSeek(xFilial("B7M") + cProtocTempRever))
		
		If Len(aCabComp) == 0
			Store Header "B7M" TO aCabComp For .T.
		Endif
		
		STORE COLS "B7M" TO aDadComp FROM aCabComp VETTRAB aTrbComp While B7M->(B7M_FILIAL+B7M_PROTOC)  == xFilial("B7M") + cProtocTempRever
		
		for i := 1 to len(aCabComp)
			if aCabComp[i][2] = "B7M_PROTOC"
				cPosicao := i
			endif
		next
		
		for i := 1 to len(aDadComp)
			aDadComp[i][cPosicao] := M->BOW_PROTOC
		next
		
	endif
Else
	
	B7M->(DbSetOrder(1))
	B7M->(MsSeek(xFilial("B7M")+cProtoc))
	
	If Len(aCabComp) == 0
		Store Header "B7M" TO aCabComp For .T.
	Endif
	
	STORE COLS "B7M" TO aDadComp FROM aCabComp VETTRAB aTrbComp While xFilial("B7M")+cProtoc == B7M->(B7M_FILIAL+B7M_PROTOC)
	
	If Empty(aDadComp)
		B7M->(MsGoto(0))
		Store COLS Blank "B7M" TO aDadComp FROM aCabComp
	EndIf
	
Endif

lRevers := .F.

aSize := MsAdvSize()

AAdd( aObjects, { 001, 000, .T., .F.,.F. } )
AAdd( aObjects, { 001, 000, .T., .T.,.F. } )
AAdd( aObjects, { 001, 000, .T., .T.,.T. } )

aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects )

aPosObj[1][2]+=15
aPosObj[2][2]+=15
aPosObj[3][2]+=15
aPosObj[3][3]-=15

If !lAutomato
	DEFINE MSDIALOG oDlg TITLE STR0004 FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel //"Reembolso"

	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[2],,,,,,oDlg,,,.F.)

EndIf	

nLinSoma := 15
oDlgSay  := oDlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrego o aDadRda da RDA generica										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSDADRDA(M->BOW_OPERDA,M->BOW_CODRDA,"1",dDataBase,Subs(M->BOW_LOCATE,1,3),M->BOW_CODESP)

If ! lAutomato
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Novo Reembolso															 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If PLSALIASEX("B14")
		oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],{"Eventos","Composição"},{""},oDlg,,,,.T.,.F.,aPosObj[3,3],aPosObj[3,4])

		oBrwPro := TPLSBrw():New(2, 2, aPosObj[3, 3]-6, aPosObj[3, 4]-15, nil, oFolder:aDialogs[01], nil, nil, nil, nil, nil, .T., nil, .T., nil, aHeadB1N, aColsB1N, .F., ;
							"B1N", IIf(nOpc = K_Excluir, K_Visualizar, nOpc), "Eventos do Reembolso", nil, nil, nil, aVtTbB1N, ;
							"VldCmpRec() .AND. PLSDTINT() .AND. PLVALDTLI('B1N') .AND. VLDB1N() .AND. " + ;
							"PLCHKDUPRE(,, .F., M->B1N_TIPDOC, M->B1N_PRCNPJ, M->B1N_MATRIC, M->B1N_CODPAD, M->B1N_CODPRO, M->B1N_NUMDOC, DtoS(M->B1N_DATDOC), " + iif(lVlrTot, "STR(M->B1N_VLRTOT)", "STR(M->B1N_VLRAPR)" ) + ", M->B1N_CODREF, DtoS(M->B1N_DATPRO))";
							,"PLS001EXC(1)", nil,, NIL,,, NIL ) //"Eventos da Guia de Honorário Individual"
	
		oBrwPro:bChange 	:= {|| oBrwComp:forceRefresh(oBrwPro), oFolder:Refresh()} 
	
	
		//obriga o usuario a digitar um motivo de exclusa do item do protocolo
		If ! M->BOW_STATUS $ "0,1,2"
			oBrwPro:oBrowse:lDelete := .F.
			oBrwPro:lAddLine        := .F.
			oBrwPro:oBrowse:oBrowse:bDelete := { || MsgAlert(STR0262)} //Não é permitida a exclusão de itens para esse status.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta GetDados...                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	bFilter          := {|nLine,aCols,aHeader| aCols[nLine,PLRETPOS("B7M_SEQUEN",aHeader)] == oBrwPro:FieldGet("B1N_SEQUEN") }
	oBrwComp 		 := TPLSBrw():New(2   ,2   ,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[2],nil    ,          ,nil    ,nil   ,nil, .T.   ,nil  ,.T.    ,nil   ,aCabComp  ,aDadComp,.F.      ,"B7M" ,nOpc,STR0015,nil    ,nil    ,nil ,aTrbComp,        ,"PLS001EXC(2)"       ,bFilter) //"Composição do Procedimento"
	oBrwComp:oPai    := oBrwPro
	oBrwComp:aOrigem := {"B1N_SEQUEN"}
	oBrwComp:aRelac  := {"B7M_SEQUEN"}
	aDadComp 		 := aClone(oBrwComp:aCols)
	oBrwComp:lAddLine:= .F.	
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para manipulação da Dialog                                                      
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("AOPN001A")
		
	
	ExecBlock("AOPN001A",.F.,.F.,{@oBrwPro})
	
EndIf


//Se a tela estiver sendo aberta pela funcionalidade sem composição o sistema não exibe o botão salvar
If !lAutomato
	If lSemComp 
		ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,bOK,{||Eval(bCancel)},.F.,aButtons,,,,,,.F.)})
	Else
		ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,bOK,{||Eval(bCancel)},.F.,aButtons)})
	EndIf
EndIf	 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca retorno contido no aRetorno...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK 
	
	If M->BOW_STATUS == "4"
		lEna := .F.
		
		For nI := 1 To Len(oBrwPro:acols)
			If oBrwPro:acols[nI][GdFieldPos("B1N_IMGSTA",oBrwPro:aheader)] <> "DISABLE"
				lEna := .T.
			endif
		next
		
		If lEna
			if (MsgYesNo(STR0297))//"Se o protocolo for indeferido, todos os itens também serão. Deseja continuar ?"
				B1N->(DbSetOrder(1))
				
				If B1N->(DbSeek(xFilial("B1N") + BOW->BOW_PROTOC))
					While !B1N->(Eof()) .And. B1N->(B1N_FILIAL+B1N_PROTOC) == BOW->(BOW_FILIAL+BOW_PROTOC)
						if B1N->B1N_IMGSTA == "ENABLE "
							
							B1N->(RecLock('B1N',.F.))
							B1N->B1N_IMGSTA := "DISABLE"
							B1N->( MsUnlock() )
						endif
						
						B1N->(DbSkip())
					EndDo
				EndIf
			else
				return
			endif
			
		EndIf
	endif
	
	If PLSALIASEX("B14")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quando o protocolo for excluido, os dados de itens glosados gravados
		//³ na tabela B14 são excluidos
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == K_Excluir
			B14->(dbSetOrder(1))
			If B14->(dbSeek(xFilial("B14")+BOW->BOW_PROTOC)) 
				
				While B14->(B14_FILIAL + B14_CDPROT) == xFilial("B14")+BOW->BOW_PROTOC

					B14->( RecLock("B14",.F.) )
					B14->( dbDelete() )
					B14->( MsUnLock() )

					B14->(DbSkip())	
				EndDo
			EndIf 
		EndIf
		
		For nI := 1 To Len(oBrwPro:acols)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ grava os dados dos itens excluidos                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oBrwPro:acols[nI][GdFieldPos("B1N_IMGSTA",oBrwPro:aheader)] == "DISABLE"

				nPosArray := Ascan(aDelItens,{|x| x[2] + x[3] + x[4] == oBrwPro:acols[nI][GdFieldPos("B1N_CODPRO",oBrwPro:aheader)] +;
																		oBrwPro:acols[nI][GdFieldPos("B1N_MATRIC",oBrwPro:aheader)] +;
																		oBrwPro:acols[nI][GdFieldPos("B1N_SEQUEN",oBrwPro:aheader)] })
		
				If nPosArray > 0
				
					cDescMot  := aDelItens[nPosArray][1]
					cCdproced := aDelItens[nPosArray][2]
					cMatBenef := aDelItens[nPosArray][3]
					cSequen   := aDelItens[nPosArray][4]
				
					/*Necessário fazer essa verificação pois existem inconsistencia de dados por causa 
					do tamanhos do campo de sequencial entre as tabelas do reembolso e da B14.
					esse problema foi ajustado, mas por causa do legado é necessário manter esta alteração.*/
					B14->(dbSetOrder(1))

					If B14->(MsSeek(xFilial("B14") + BOW->BOW_PROTOC + cCdproced + cMatBenef + cSequen))  
						B14->( RecLock("B14",.F.) )
						B14->( dbDelete() )
						B14->( MsUnLock() )
					EndIf

					//Se existir registro relacionado ao item, exclui e grava o novo item
					AtuB14("", BOW->BOW_PROTOC, cCdproced, cMatBenef, cSequen, cDescMot) 
				EndIf
			Else
				
				lAprovado := .T. 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se o item não estiver mais glosado e existir registro na B14			  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				/*Necessário fazer essa verificação pois existem inconsistencia de dados por causa 
				do tamanhos do campo de sequencial entre as tabelas do reembolso e da B14.
				esse problema foi ajustado, mas por causa do legado é necessário manter esta alteração.*/
				B14->(dbSetOrder(1))
				If B14->(MsSeek(xFilial("B14")+BOW->BOW_PROTOC +;
							    oBrwPro:acols[nI][GdFieldPos("B1N_CODPRO",oBrwPro:aheader)] +;
							    oBrwPro:acols[oBrwPro:obrowse:nAt][GdFieldPos("B1N_MATRIC",oBrwPro:aheader)] +;
								oBrwPro:acols[nI][GdFieldPos("B1N_SEQUEN",oBrwPro:aheader)]))
								
					B14->( RecLock("B14",.F.) )
					B14->( dbDelete() )
					B14->( MsUnLock() )
				EndIf 
			EndIf
			
			If !oBrwPro:acols[nI][len(oBrwPro:acols[nI])]
				nTotItens += oBrwPro:acols[nI][GdFieldPos("B1N_VLRTOT",oBrwPro:aheader)]// * oBrwPro:acols[nI][GdFieldPos("B1N_QTDPRO",oBrwPro:aheader)]
			EndIf
		Next 
		
		If BOW->(FieldPos("BOW_VLRREE")) > 0
			//atualiza o valor total apresentado ao incluir novos itens pelo remote.
			BOW->(RecLock('BOW',.F.))
			BOW->BOW_VLRAPR := nTotItens
			
			If M->BOW_STATUS == "1"
				BOW->BOW_VLRREE := 0
			EndIf
			BOW->( MsUnlock() )
		EndIf
	EndIf
	
	If !lAprovado .AND. M->BOW_STATUS == "3" 
		MsgInfo(STR0314, STR0049) //Todos os itens do protocolo foram negados, não será possível gerar a autorização de reembolso # Atenção
		Return
	EndIf 
	
	If nOpc == K_Incluir
		
		ABOWFinal()
	EndIf
	
	if nOpc == K_Incluir .and. !empty(M->BOW_PROORI)
		
		For nI:= 1 To LEN(oBrwPro:aCols)
			dbSelectArea("B1N")
			dbSetorder(2)
			If dbSeek(xFilial("B1N") + M->BOW_PROTOC + oBrwPro:aCols[nI][GdFieldPos("B1N_SEQUEN",oBrwPro:aHeader)])
				If !EMPTY(B1N->B1N_CODREC)
					dbSelectArea("B7D")
					dbSetorder(3)
					
					If dbSeek(xFilial("B7D") + B1N->(B1N_CODREC + B1N_CODMED))
						B7D->( RecLock("B7D",.F.))
						B7D->B7D_QTDEXE := B7D->B7D_QTDEXE - B1N->B1N_QTDMED
						B7D->( MsUnLock() )
					EndIf
				EndIf
			EndIf
		Next
		
		/*Gravando campo para considerar durante o processamento das legislações*/
		if  B44->(FieldPos("B44_REVERT")) <> 0 .and. BD6->(FieldPos("BD6_REVERT")) <> 0
			B44->(dbSetOrder(4))
			If B44->(dbSeek(xFilial("B44")+cProtocTempRever))
				B44->( RecLock("B44",.F.))
				B44->B44_REVERT  := .T.
				B44->( MsUnLock() )
				
				BD6->(DbSetOrder(1))
				
				If BD6->(MsSeek(xFilial("BD6")+B44->(B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI)))
					While !BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == ;
						B44->(B44_FILIAL+B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI)
						
						
						BD6->( RecLock("BD6",.F.))
						BD6->BD6_REVERT  := .T.
						BD6->( MsUnLock() )
						
						BD6->(DbSkip())
					enddo
				endif
				
			endif
		endif
		
		
		BOW->(dbSetOrder(1))
		If BOW->(dbSeek(xFilial("BOW")+cProtocTempRever))
			BOW->( RecLock("BOW",.F.) )
			BOW->BOW_STATUS := "E"
			BOW->BOW_PROCLO := M->BOW_PROTOC
			BOW->( MsUnLock() )
		EndIf
		
		//Gerando Título para compensação
		B44->(dbSetOrder(4))
		If B44->(dbSeek(xFilial("B44")+cProtocTempRever))
			
			SE1->(dbSetOrder(1))
			
			If SE1->(dbSeek(xFilial("SE1")+B44->B44_PREFIX + B44->B44_NUM + B44->B44_PARCELA + B44->B44_TIPO))
				cNumTit  := PLSE1NUM("PLS")
				Copy "SE1" TO MEMORY
				SE1->(RecLock("SE1",.T.))
				
				dDatValid:= DaySum( Date() , GETNEWPAR("MV_PLDIAVC",0))
				
				SE1->E1_FILIAL   := xFilial("SE1")
				SE1->E1_TIPO     := "DP"
				SE1->E1_CLIENTE  := M->E1_CLIENTE
				SE1->E1_LOJA     := M->E1_LOJA
				SE1->E1_NATUREZ  := M->E1_NATUREZ
				SE1->E1_EMISSAO  := Date()
				SE1->E1_EMIS1    := Date()
				SE1->E1_SITUACA  := "A"//M->E1_SITUACA
				SE1->E1_MOEDA    := M->E1_MOEDA
				SE1->E1_OCORREN  := M->E1_OCORREN
				SE1->E1_FLUXO    := M->E1_FLUXO
				SE1->E1_STATUS   := M->E1_STATUS
				SE1->E1_PROJPMS  := M->E1_PROJPMS
				SE1->E1_VENCORI  := dDatValid
				SE1->E1_VENCTO   := dDatValid
				SE1->E1_PREFIXO  := "PLS"
				SE1->E1_NUM      := cNumTit
				
				SE1->E1_VENCREA  := dDatValid
				SE1->E1_VLCRUZ   := M->E1_VLCRUZ
				SE1->E1_IRRF	 := M->E1_IRRF
				SE1->E1_VALOR    := M->E1_VALOR
				SE1->E1_NOMCLI   := M->E1_NOMCLI
				SE1->E1_SALDO    := M->E1_SALDO
				SE1->E1_DECRESC  := M->E1_DECRESC
				SE1->E1_SDDECRE  := M->E1_SDDECRE
				SE1->E1_ACRESC   := M->E1_ACRESC
				SE1->E1_SDACRES  := M->E1_SDACRES
				SE1->E1_VALLIQ   := M->E1_VALLIQ
				SE1->E1_BCOCLI   := M->E1_BCOCLI
				SE1->E1_AGECLI   := M->E1_AGECLI
				SE1->E1_CTACLI   := M->E1_CTACLI
				SE1->E1_NUMBCO   := M->E1_NUMBCO
				SE1->E1_PLNUCOB  := M->E1_PLNUCOB
				SE1->E1_VALJUR   := M->E1_VALJUR
				SE1->E1_PORCJUR  := M->E1_PORCJUR
				SE1->E1_CODINT   := M->E1_CODINT
				SE1->E1_CODEMP   := M->E1_CODEMP
				SE1->E1_MATRIC 	 := M->E1_MATRIC
				SE1->E1_CONEMP   := M->E1_CONEMP
				SE1->E1_VERCON   := M->E1_VERCON
				SE1->E1_SUBCON   := M->E1_SUBCON
				SE1->E1_VERSUB   := M->E1_VERSUB
				SE1->E1_MESBASE  := M->E1_MESBASE
				SE1->E1_ANOBASE  := M->E1_ANOBASE
				SE1->E1_MULTNAT  := M->E1_MULTNAT
				SE1->E1_NUMCON   := M->E1_NUMCON
				SE1->E1_TIPREG   := M->E1_TIPREG
				SE1->E1_ORIGEM   := M->E1_ORIGEM
				SE1->E1_BAIXA    := ctod("  /  /  ")
				SE1->E1_SALDO    := M->E1_VALOR
				SE1->(MsUnLock())

				//Métrica do PLS
				/*Atenção:
				1) Para a métrica funcionar com a classe FwMetrics, a lib deve estar na versão igual ou maior que 20200727;
				2) Além de verificar a versão da Lib, existe o parâmetro "secreto" MV_PHBMETR, que vai ficar ativo como default. Caso ocorra lentidão em 
				algum cliente em produção - visto que até 05/2021, nenhum cliente da base tem os requisitos para rodar a métrica e testar em produção - basta
				citar a criação deste parâmetro (Métrica PLS Ativa? 0 - Não / 1 - Sim) e colocar o valor como "0" (desligado).
				3) No futuro, vamos usar o FwCustomMetrics, mas demanda lib superior e outros requisitos...
				4) As variáveis estão declaradas como estáticas no fonte:*/
				if lHabMetric .and. lLibSupFw .and. lVrsAppSw
					
					FWMetrics():addMetrics(FunName(), {{"totvs-saude-planos-protheus_modelo-pagamento-de-reembolso_total", 1 }} )

				endif
				
			endif
			
			BOW->(dbSetOrder(1))
			If BOW->(dbSeek(xFilial("BOW")+cProtocTempRever))
				BOW->( RecLock("BOW",.F.) )
				BOW->BOW_TITCAN := cNumTit
				BOW->BOW_TIPCAN := "DP"
				BOW->BOW_PRXCAN := "PLS"
				BOW->( MsUnLock() )
			EndIf
			
			
			
			//Criando BBT
			BBT->(dbSetOrder(7))
			
			If BBT->(dbSeek(xFilial("BBT")+B44->B44_PREFIX + B44->B44_NUM + B44->B44_PARCELA + B44->B44_TIPO))
				
				BDC->(dbSetOrder(1))
				If BDC->(dbSeek(xFilial("BDC")+BBT->BBT_NUMCOB))
					
					Copy "BDC" TO MEMORY
					
					DbSelectArea("BDC")
					
					__cNumBDC:=PLSA625Num()
					
					BDC->(RecLock("BDC",.T.))
					
					BDC->BDC_FILIAL := xFilial("BDC")
					BDC->BDC_CODOPE := M->BDC_CODOPE
					BDC->BDC_NUMERO := __cNumBDC
					BDC->BDC_DATGER := dDataBase
					BDC->BDC_USUOPE := PLRETOPE()
					BDC->BDC_HORA   := TIME()
					BDC->BDC_HORAF  := TIME()
					BDC->BDC_ANOINI := subs(dtos(dDataBase),1,4)
					BDC->BDC_MESINI := subs(dtos(dDataBase),5,2)
					BDC->BDC_ANOFIM := subs(dtos(dDataBase),1,4)
					BDC->BDC_MESFIM := subs(dtos(dDataBase),5,2)
					BDC->BDC_DTEMIS := dDataBase
					BDC->BDC_VALOR  := M->BDC_VALOR * -1
					BDC->BDC_MODPAG := M->BDC_MODPAG
					BDC->BDC_REEMB  := M->BDC_REEMB
					BDC->BDC_INTERC := M->BDC_INTERC
					
					BDC->( ConfirmSx8() )
					BDC->(MsUnlock())
				endif
				
				Copy "BBT" TO MEMORY
				
				DbSelectArea("BBT")
				__cCodigo := GetSx8Num("BBT","BBT_CODIGO")
				BBT->( ConfirmSx8() )
				
				BBT->(RecLock("BBT",.T.))
				BBT->BBT_FILIAL := xFilial("BBT")
				BBT->BBT_CODIGO := __cCodigo
				
				BBT->BBT_PREFIX := "PLS"
				BBT->BBT_NUMTIT := cNumTit
				BBT->BBT_TIPTIT := "DP"
				
				BBT->BBT_CODOPE := M->BBT_CODOPE
				BBT->BBT_CODEMP := M->BBT_CODEMP
				BBT->BBT_CONEMP := M->BBT_CONEMP
				BBT->BBT_VERCON := M->BBT_VERCON
				BBT->BBT_SUBCON := M->BBT_SUBCON
				BBT->BBT_VERSUB := M->BBT_VERSUB
				BBT->BBT_MATRIC := M->BBT_MATRIC
				BBT->BBT_TIPREG := M->BBT_TIPREG
				BBT->BBT_NIVEL  := M->BBT_NIVEL
				
				BBT->BBT_CLIFOR := M->BBT_CLIFOR
				BBT->BBT_LOJA   := M->BBT_LOJA
				BBT->BBT_VALOR  := M->BBT_VALOR
				
				BBT->BBT_ANOTIT := subs(dtos(dDataBase),1,4)
				BBT->BBT_MESTIT := subs(dtos(dDataBase),5,2)
				
				BBT->BBT_RECPAG := M->BBT_RECPAG
				
				BBT->BBT_CODPLA := M->BBT_CODPLA
				BBT->BBT_VERSAO := M->BBT_VERSAO
				BBT->BBT_INTERC := M->BBT_INTERC
				BBT->BBT_MODPAG := M->BBT_MODPAG
				BBT->BBT_DATEMI := dDataBase
				BBT->BBT_NUMCOB := BDC->BDC_CODOPE + BDC->BDC_NUMERO
				
				BBT->(MsUnlock())
				
			endif
			
			//Criando BBT
			BM1->(dbSetOrder(4))
			
			If BM1->(dbSeek(xFilial("BBT")+B44->B44_PREFIX + B44->B44_NUM + B44->B44_PARCELA + B44->B44_TIPO))
				
				Copy "BM1" TO MEMORY
				cSeq := PLSA625Cd("BM1_SEQ","BM1",1,"BM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_ANO+BM1_MES+BM1_TIPREG)",;
				M->BM1_CODINT+M->BM1_CODEMP+subs(dtos(dDataBase),1,4)+subs(dtos(dDataBase),5,2)+M->BM1_TIPREG)
				
				
				BM1->(RecLock("BM1",.T.))
				BM1->BM1_FILIAL := xFilial("BM1")
				
				If BM1->(FieldPos("BM1_RECPAG")) > 0
					BM1->BM1_RECPAG := M->BM1_RECPAG
				Endif
				
				BM1->BM1_CODINT := M->BM1_CODINT
				BM1->BM1_CODEMP := M->BM1_CODEMP
				BM1->BM1_MATRIC := M->BM1_MATRIC
				BM1->BM1_TIPREG := M->BM1_TIPREG
				BM1->BM1_DIGITO := M->BM1_DIGITO
				BM1->BM1_NOMUSR := M->BM1_NOMUSR
				BM1->BM1_SEQ    := cSeq
				BM1->BM1_CONEMP := M->BM1_CONEMP
				BM1->BM1_VERCON := M->BM1_VERCON
				BM1->BM1_SUBCON := M->BM1_SUBCON
				BM1->BM1_VERSUB := M->BM1_VERSUB
				BM1->BM1_ANO    := subs(dtos(dDataBase),1,4)
				BM1->BM1_MES    := subs(dtos(dDataBase),5,2)
				BM1->BM1_TIPO   := M->BM1_TIPO
				BM1->BM1_VALOR  := M->BM1_VALOR
				BM1->BM1_CODTIP := M->BM1_CODTIP
				BM1->BM1_DESTIP := M->BM1_DESTIP
				BM1->BM1_CODEVE := M->BM1_CODEVE
				BM1->BM1_DESEVE := M->BM1_DESEVE
				BM1->BM1_ALIAS  := M->BM1_ALIAS
				BM1->BM1_ORIGEM := M->BM1_ORIGEM
				BM1->BM1_BASEIR := M->BM1_BASEIR
				BM1->BM1_MATUSU := M->BM1_MATUSU
				BM1->BM1_PLNUCO := M->BM1_PLNUCO
				BM1->BM1_LTOTAL := M->BM1_LTOTAL
				BM1->BM1_SEXO   := M->BM1_SEXO
				BM1->BM1_GRAUPA := M->BM1_GRAUPA
				BM1->BM1_CODFAI := M->BM1_CODFAI
				BM1->BM1_NIVFAI := M->BM1_NIVFAI
				BM1->BM1_TIPUSU := M->BM1_TIPUSU
				BM1->BM1_CARGO  := M->BM1_CARGO
				BM1->BM1_PREFIX := "PLS"
				BM1->BM1_NUMTIT := cNumTit
				BM1->BM1_TIPTIT := "DP"
				BM1->BM1_NIVCOB := M->BM1_NIVCOB
				BM1->BM1_INTERC := M->BM1_INTERC
				BM1->BM1_NUMPAR := M->BM1_NUMPAR
				BM1->(MsUnLock())
			endif
		endif
	endif
	
	//Status deferido e nao houve alteracao do status pela funcao PlsVldStat
	If (nOpc == K_Alterar) .and. (BOW->BOW_STATUS $ "3,C") .and. (BOW->BOW_STATUS == M->BOW_STATUS)

		//Se status = deferido, verificar permissão do usuário na BX4 para gerar autorização
		//Caso tenha permissão, será apresentada mensagem para gerar ou não a autorização
		BX4->(DbSetOrder(1)) 
		
		cChave := xFilial("BX4") + cCodUsr + PLSINTPAD()
		
		If BX4->(DbSeek(cChave))
			
			If BX4->BX4_APREEM == "1" //1 == Possui permissão; 2 == Não possui permissão
					
				If lAbreSem 
					lAbreSem := .F.
					PLSFechaSem(nHReemb,BOW->(BOW_FILIAL+BOW_PROTOC)+".SMF")//Fecha antes de abrir um novo na GERAUT
				endif
			
				//Abrir tela da autorizacao do protocolo
				MsAguarde({||PLSGERAUT() }, "Aguarde", "Processo em andamento...", .F.) 
			EndIf
		Endif 
	EndIf
Endif

If lAbreSem

	PLSFechaSem(nHReemb,BOW->(BOW_FILIAL+BOW_PROTOC)+".SMF")
EndIf

SET KEY VK_F7  TO 
SET KEY VK_F8  TO 
SET KEY VK_F9  TO 
SET KEY VK_F10 TO 

//Limpa o array dos itens excluidos.
aDelItens := {}
nTotItens := 0
Return

/*/{Protheus.doc} plRelCpm
Relacao do campo

@author  PLS TEAM
@version P11
@since   11/11/2017
/*/
function plRelCpm(cField)
local cCodPad 	:= ''
local cCodPro 	:= ''
local cMatric	:= ''
local cCodMed	:= ''
local cRet		:= ''
local cEstSol 	:= ''
local cRegSol 	:= ''
local cSigla  	:= ''

if ! INCLUI
	
	if cField == 'B1N_DESPRO'
		
		cCodPad := B1N->B1N_CODPAD
		cCodPro := B1N->B1N_CODPRO
		
		if valType(M->B1N_CODPAD) != 'U' .and. valType(M->B1N_CODPRO) != 'U'
			cCodPad := M->B1N_CODPAD
			cCodPro := M->B1N_CODPRO
		endIf
		
		cRet := posicione('BR8',1,xFilial('BR8') + cCodPad + cCodPro,'BR8_DESCRI')
	
		if B1N->(eof())
			B1N->(dbSetOrder(1)) //B1N_FILIAL+B1N_PROTOC+B1N_CODPAD+B1N_CODPRO
			B1N->( msSeek( xFilial("B1N") + M->BOW_PROTOC + cCodPad + cCodPro ) )
		endIf
		
	elseIf cField == 'B1N_NOMEBE'
		
		cMatric := B1N->B1N_MATRIC
		
		if valType(M->B1N_MATRIC) != 'U'
			cMatric := M->B1N_MATRIC
		endIf
		
		cRet := posicione("BA1",2, xFilial("BA1") + cMatric, "BA1_NOMUSR")
		
	elseIf cField == 'B1N_DESMED'

		cCodMed := B1N->B1N_CODMED
		
		if valType(M->B1N_CODMED) != 'U'
			cCodMed := M->B1N_CODMED
		endIf
		
		cRet := Posicione("BR8",3, xFilial("BR8") + cCodMed, "BR8_DESCRI")
	
	elseIf cField == 'B1N_NOMSOL'

		cEstSol := B1N->B1N_ESTSOL
		cRegSol := B1N->B1N_REGSOL
		cSigla  := B1N->B1N_SIGLA
		
		if valType(M->B1N_ESTSOL) != 'U' .and. valType(M->B1N_REGSOL) != 'U' .and. valType(M->B1N_SIGLA) != 'U'
			cEstSol := M->B1N_ESTSOL
			cRegSol := M->B1N_REGSOL
			cSigla  := M->B1N_SIGLA
		endIf

		cRet := posicione("BB0",4,xFilial("BB0")+ cEstSol + cRegSol + cSigla,"BB0_NOME")
	
	endIf
		
endIf

return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlsBOWRel ³ Autor ³ Everton M. Fernandes	³ Data ³ 20.02.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializadores padroes								   	       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSABOWRel(cField)

LOCAL uRet

If cField == "BOW_CODESP"
	uRet := If(Inclui,Posicione("BAX",1,xFilial("BAX")+GetMV("MV_PLSRDAG")+PLSINTPAD()+SUBS(M->BOW_LOCATE,1,3),"BAX_CODESP"),BOW->BOW_CODESP)
Endif

If cField == "BOW_DESESP"
	uRet := If(Inclui,Posicione("BAQ",1,xFilial("BAQ")+PLSINTPAD()+M->BOW_CODESP,"BAQ_DESCRI"),BOW->BOW_DESESP)
Endif

Return uRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlsBOWRel ³ Autor ³ Everton M. Fernandes	³ Data ³ 20.02.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ validacoes de campos padrao								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBOWVLD(cField)

LOCAL lRet := .T.

If cField == "BOW_CODRDA"
	lRet := PLSA090RDA(M->BOW_OPERDA,M->BOW_CODRDA,"1",Date(),M->BOW_USUARI,"","","BOW")
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PBOWVld ³ Autor ³ Everton M. Fernandes	³ Data ³ 20.02.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para validar os dados do protocolo				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PBOWVld(oEncAut,nOpc,oBrwPro) 

LOCAL lRet 		 := .T.
LOCAL lAviso	 := .F.
LOCAL nI		 := 0
Local oEncAutAux := oEncAut
Local cStatAlter := GETNEWPAR("MV_PLSTALT","0,1,2,3,4,B,C,D") // Status que pode alterar 
Local cStatAud   := GETNEWPAR("MV_PLSTAUD","F") // Status que podem mudar para Deferido ou indeferido
Local nI		 := 0
Local nLenAcols  := 0
Local nLenHead   := 0
LOCAL nValTotal  := 0
Local cStatusTemp := ""

//não pode cancelar o reembolso no período de bloqueio contábil
if !(M->BOW_STATUS $ 'D') .OR. PLVLDBLQCO(dDataBase, {"PLS005"}, .T.) //se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VERIFICA CAMPOS OBRIGATÓRIOS   												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (INCLUI .OR. ALTERA) .AND. !( Obrigatorio(oEncAut:aGets,oEncAut:aTela) )
		lRet := .F.
	
	ElseIf !oBrwPro:TudoOK()	//Verifica se os campos obrigatórios dos itens estão preenchidos 
			lRet := .F.
	Endif 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa rotina generica de gravacao...                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If nOpc == K_Excluir
			cOpeProt := PLSINTPAD()
			If !Empty(AllTrim(BOW->BOW_NUMAUT))
				MsgAlert( STR0121 + BOW_OPEUSR+BOW_CODLDP+BOW_CODPEG+BOW_NUMAUT+BOW_ORIMOV) //"Este protocolo está vinculado à guia "
				lRet := .F.
			EndIf
			
		ElseIf nOpc == K_Alterar
			
			//índice para verificação na B44 para cancelamento
			B44->(DbSetorder(1))

			If M->BOW_STATUS == "D"
				if ( BOW->(BOW_STATUS) == "4")
					MsgAlert( STR0254 ) //"Atenção! Guia indeferida, impossível cancelamento"
					lRet := .F.
				//Se encontrar na B44, signifca que já foi aprovado o protocolo e não posso cancelar.	
				elseIf B44->( DbSeek(xFilial("B44")+BOW->(BOW_OPEMOV+BOW_ANOAUT+BOW_MESAUT+BOW_NUMAUT)) )
					MsgAlert( STR0255 ) //"Existe autorização vinculada à este protocolo, não é possível o cancelamento"
					lRet := .F.
				EndIf
			else
				
				//Somente pode alterar o Status de uma dessas opções
				If !(BOW->BOW_STATUS $ cStatAlter)
					Help( ,, 'HELP',," O status selecionado não está configurado no parâmetro MV_PLSTALT. ", 1, 0)
					lRet := .F.
				EndIF
				
				//Permite mudar para "Em analise" apenas se o status anterior for "Protocolado"
				If M->BOW_STATUS == '2'
					If !BOW->BOW_STATUS $ '0,1,2,3,4,B,C'
						Help( ,, 'HELP',," O status selecionado não respeita a ordem de status do processo de reembolso. ", 1, 0)
						lRet := .F.
					EndIf
					//Valida a gravavaçao da observação
					
					If BOW->(FieldPos("BOW_MOTIND")) > 0
						If lRet .AND. BOW->BOW_STATUS $ '4' .AND. EMPTY(M->BOW_MOTIND)
							Help("",1,"PLBOW015")
							lRet:= .F.
						EndIf
					Else
						
						If lRet .AND. BOW->BOW_STATUS $ '3,4' .AND. AllTrim(M->BOW_OBS) == ""
							Help("",1,"PLBOW015")
							lRet:= .F.
						EndIf
					EndIf
				EndIf
				
				//Permite mudar para "Em analise" apenas se o status anterior for "Protocolado"
				If lRet .AND. M->BOW_STATUS $ '3,4,B'
					If !BOW->BOW_STATUS $ '1,2,B' .AND. BOW->BOW_STATUS <> M->BOW_STATUS .AND. !(M->BOW_STATUS == 'B' .AND. BOW->BOW_STATUS == '0') .AND. !(BOW->BOW_STATUS $ cStatAud )
						Help( ,, 'HELP',," O status selecionado não respeita a ordem de status do processo de reembolso. ", 1, 0)
						lRet := .F.
					EndIf				
					//Valida a gravavaçao da observação

					If lRet .AND. M->BOW_STATUS $ '4' .AND. EMPTY(M->BOW_MOTIND)
						Help("",1,"PLBOW015")
						lRet:= .F.
					EndIf					
				EndIf
			EndIf
			
			//Não permite selecionar as demais opções
			If lRet .AND. !M->BOW_STATUS $ cStatAlter   
						  
				Help( ,, 'HELP',,"O status selecionado não está configurado no parâmetro MV_PLSTALT. ", 1, 0)
				lRet := .F.
			EndIf
			
			If lRet .AND. (M->BOW_STATUS = 'A')
				Help( ,, 'HELP',," O status selecionado não respeita a ordem de status do processo de reembolso. ", 1, 0)
				lRet := .F.
			EndIf

			//Não permite mudar para "Auditoria"
			If lRet .AND. (M->BOW_STATUS == '9')
				Help( ,, 'HELP',," O status selecionado não respeita a ordem de status do processo de reembolso. ", 1, 0)
				lRet := .F.
			EndIf			
			//Se o Status for Deferido, só pode alterar o Status se ainda não houver autorização.
			if lRet .AND. M->BOW_STATUS = '3' .And. M->BOW_STATUS <> BOW->BOW_STATUS
				
				B44->(dbSetOrder(4))
				
				If B44->(MsSeek(xFilial("B44") + M->BOW_PROTOC))
					if B44->(B44_FILIAL + B44_PROTOC) = xFilial("B44") + M->BOW_PROTOC
						Help( ,, 'HELP',," O status selecionado não respeita a ordem de status do processo de reembolso. ", 1, 0)
						Return
					endif
				Endif
			endif
			
			If PLSALIASEX("B1N") .AND. lRet
				
				If ! Empty(oBrwPro:FieldGet("B1N_CODPRO",1))
				
					For nI := 1 To Len(oBrwPro:aCols)
					
						If oBrwPro:FieldGet("B1N_USOCON",nI) == "1" .AND. Empty(oBrwPro:FieldGet("B1N_SEQMED",nI))
							
							oBrwPro:FieldPut("B1N_UNICON",  PRetRecMed(M->BOW_USUARI,oBrwPro:FieldGet("B1N_CODPAD",nI), oBrwPro:FieldGet("B1N_CODPRO",nI),.T.) ,nI)
							If EMPTY(oBrwPro:FieldGet("B1N_CODREC",nI)) .OR. EMPTY(oBrwPro:FieldGet("B1N_CODMED",nI)) .OR. EMPTY(oBrwPro:FieldGet("B1N_SEQMED",nI))
								If M->BOW_STATUS $ "2,3,5,6,7"
									Help("",1,"PLBOW017")
									lRet := .F.
									Exit
								EndIf
							EndIf
						EndIf
						If oBrwPro:FieldGet("B1N_CODPRO",nI) ==	oBrwPro:FieldGet("B1N_PROORI",nI) .AND. Empty(oBrwPro:FieldGet("B1N_SEQMED",nI))
							lAviso := .T.
						EndIf
					Next nI
				EndIf

			EndIf
		Endif
	EndIf
	
		cStatusTemp := PlsVldStat(oBrwPro:aCols, M->BOW_STATUS)
		If lRet .AND. cStatusTemp $ '4' .AND. EMPTY(M->BOW_MOTIND)
			Help( ,, 'HELP',,"O status deve ser alterado para 4-Indeferido, e o campo Mot. Indefe.(BOW_MOTIND) deve ser preenchido. ", 1, 0)
			lRet:= .F.
		EndIf
	
	//Verifica o Contas médicas / Processamento de contas, para ver se não existe um correspondente
	if lRet
		lRet := PLSVRCMR(M->BOW_PROTOC,oBrwPro)
	endif
	
	
	nLenAcols  := LEN(oBrwPro:aCols)
	nLenHead   := LEN(oBrwPro:aHeader) + 1
	
	For nI := 1 To nLenAcols
	
		If oBrwPro:aCols[nI][GdFieldPos("B1N_IMGSTA",oBrwPro:aHeader)] != "DISABLE" .AND. !oBrwPro:aCols[nI][nLenHead] 
			nValTotal += oBrwPro:aCols[nI][GdFieldPos("B1N_VLRTOT",oBrwPro:aHeader)] 
		EndIf
	
	Next
	
	If M->BOW_STATUS != "4"

		BA3->(DbSetOrder(1))
		If BA3->(MsSeek(xFilial("BA3") + Left( BOW->BOW_USUARI, 14)))
		
			BI3->(DbSetOrder(1))
			If BI3->(MsSeek(xFilial("BI3")+BA3->(BA3_CODINT + BA3_CODPLA + BA3_VERSAO)))
		
				// ***************** Verifica valor minimo para solicitação de reembolso cadastrado no produto
				If nValTotal < BI3->BI3_VMIRMB // nao atingiu o valor necessário para solicitar o reembolso
					MsgInfo("O valor mínimo de R$ " + Alltrim(Str(BI3->BI3_VMIRMB)) + "  para solicitação de reembolso não foi atingido")
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄvalidações específicasÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para realizara validações específicas e retornar o resultado do processamento
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PLVLD01A")
		
		aAreaBOW := BOW->(GetArea())  
		aAreaB1N := B1N->(GetArea()) 

		lRet := ExecBlock("PLVLD01A",.F.,.F.,{lRet, oEncAutAux, nOpc})
			
		RestArea(aAreaBOW) 
		RestArea(aAreaB1N) 
	EndIf
	
Else
	lRet := .F.
EndIf

if lRet .AND. M->BOW_STATUS == 'D'
	lRet := PLCancReemb(M->BOW_STATUS, oBrwPro) 
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PBOWFinal ³ Autor ³ Everton M. Fernandes	³ Data ³ 20.02.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que confirma uma autorizacao retornando o seu numero³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PBOWFinal(oEncAut,nOpc, aColsIte, aHeadIte  , aColsCopo, aHeadCopo)
LOCAL nI
LOCAL aRetFun
LOCAL nFor

LOCAL aDadUsr   := PLSGETUSR()
LOCAL lRet 		:= .T.

LOCAL aCodProcs := {}
LOCAL lGerSenha := .T. //por enquanto o reembolso sempre gera senha
LOCAL cSenhaPLS	:= ""
LOCAL cCampo		:= ""
LOCAL lDtPagto  := GETNEWPAR("MV_PLSDTPG",.F.)
LOCAL aDadInter := {}
//local cStatusAnterior
local cStatusTemp
Local cStatAlter := GETNEWPAR("MV_PLSTALT","0,1,2,3,4,B,C,D") // Status que podem ser alterados
Local cStatAud   := GETNEWPAR("MV_PLSTAUD","F") // Status que podem mudar para Deferido ou indeferido 

Local aDadosBOW	:= {}
Local aDadosB1N	:= {}
Local lGrvRmbBD5 := GetNewPar("MV_GRMBBD5", .F.)
Local nLenAcols  := LEN(aColsIte) 
Local nHeader1   := LEN(aHeadIte) + 1 
Local cPadInt	 := ""
Local lCopartInternacao := GetNewPar("MV_PLCOINT", .T.)

oBrwComp:ForceRefresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERIFICA CAMPOS OBRIGATÓRIOS   												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (INCLUI .OR. ALTERA) .AND. !( Obrigatorio(oEncAut:aGets,oEncAut:aTela) ) .or.  nOpc == 2 // consulta não pdoe sofrer alteração
	lRet := .F.
Endif

If nOpc == K_Alterar .AND. M->BOW_STATUS <> 'B' .and. M->BOW_STATUS <> '4'
	cStatusTemp := PlsVldStat(aColsIte, M->BOW_STATUS)
	
	if cStatusTemp <> M->BOW_STATUS .AND. M->BOW_STATUS $ "3,4,C"
		If (!iif(cStatusTemp = "3", MsgYesNo(STR0259), iif(cStatusTemp = "4", MsgYesNo(STR0260), MsgYesNo(STR0261)))) //"O Protocolo será alterado para o Status Aprovado, Confirma ?"
			lRet := .F.
		endif
	endif
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa rotina generica de gravacao...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava																	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction
	If nOpc == K_Incluir
		//Varre os campos da tabela e preenche com os dados digitados
		dbSelectArea("SX3")
		SX3->(dbSetOrder(1))
		If SX3->(DbSeek('BOW'))
			
			BOW->(RecLock('BOW',.T.))
			
			While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =='BOW'
				
				If SX3->X3_CAMPO == "BOW_FILIAL"
					BOW->BOW_FILIAL := xFilial("BOW")
				ElseIf SX3->X3_CAMPO == "BOW_OPEMOV"
					BOW->BOW_OPEMOV := PLSINTPAD()
				ElseIf SX3->X3_CAMPO == "BOW_EMPMOV"
					BOW->BOW_EMPMOV := cNumEmp
				ElseIf SX3->X3_CAMPO == "BOW_OPEUSR"
					BOW->BOW_OPEUSR := M->BOW_OPEUSR					
				ElseIf X3Uso(SX3->X3_USADO)
					If GetSx3Cache(SX3->X3_CAMPO, "X3_CONTEXT") <> "V"
						&("BOW->"+SX3->X3_CAMPO) := &("M->"+SX3->X3_CAMPO)
					EndIf
				EndIf
				
				SX3->(DbSkip())
			EndDo
			
			//Gera a senha do protocolo
			cSenhaPLS := PLSSenAut(Date())
			BOW->BOW_SENHA := cSenhaPLS

			//Confirma o Num do Protocolo como usado no SXE
			//ConfirmSX8() - Retirado pois o protocolo agora é gerado baseado na funcao P773GerPro()
			
			BOW->( MsUnlock() )
			
			//Gravacao da tabela B00 - Registro de Protocolo de Atendimento
			gerRegB00(BOW->BOW_PROTOC,,'BOW',.T.,.F.,BOW->(BOW_USUARI))
			
			// Conclui um protocolo
	  	    If GetNewPar("MV_PLRN395","0") == "1"
		        P773AutCon("BOW",BOW->BOW_PROTOC,BOW->BOW_PROTOC)
		    EndIf
			
			If PLSALIASEX("B1N")
				For nI := 1 To nLenAcols  
					
					//Verifica se a data de execução do
					//procedimento está dentro do período
					//de uma internação
					aDadInter := PLSREINT(aColsIte[nI][GdFieldPos("B1N_GUIPRI",aHeadIte)],;
					DTOS(aColsIte[nI][GdFieldPos("B1N_DATPRO",aHeadIte)]),;
					aColsIte[nI][GdFieldPos("B1N_MATRIC",aHeadIte)],;
					.F.,;
					.F.)
					
					//Grava os dados da internação, para o cálculo da coparticipação por faixa
					If len(aDadInter) > 0
						aColsIte[nI][GdFieldPos("B1N_GUIPRI",aHeadIte)] := aDadInter[1]
						aColsIte[nI][GdFieldPos("B1N_INTDE" ,aHeadIte)] := aDadInter[2]
						aColsIte[nI][GdFieldPos("B1N_INTATE",aHeadIte)] := aDadInter[3]
					EndIf
					
					//cPadInt := AllTrim( Posicione("BE4", 2, xFilial("BE4")+aColsIte[nI][GdFieldPos("B1N_GUIPRI",aHeadIte)], "BE4_PADINT") )
					
					If !Empty( aColsIte[nI][GdFieldPos("B1N_GUIPRI",aHeadIte)] )					
						BE4->(DbSetOrder(2)) //BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
						If BE4->( MsSeek(xFilial("BE4")+aColsIte[nI][GdFieldPos("B1N_GUIPRI",aHeadIte)]) )
                   			aColsIte[nI][GdFieldPos("B1N_PADINT",aHeadIte)] := AllTrim(BE4->BE4_PADINT)
                   			aColsIte[nI][GdFieldPos("B1N_PADCON",aHeadIte)] := AllTrim(BE4->BE4_PADCON)
                   			aColsIte[nI][GdFieldPos("B1N_GRPINT",aHeadIte)] := AllTrim(BE4->BE4_GRPINT)
                   			aColsIte[nI][GdFieldPos("B1N_TIPINT",aHeadIte)] := AllTrim(BE4->BE4_TIPINT)
                   			aColsIte[nI][GdFieldPos("B1N_REGINT",aHeadIte)] := AllTrim(BE4->BE4_REGINT)		

							If !lCopartInternacao
								aColsIte[nI][GdFieldPos("B1N_ABATPF",aHeadIte)] := "0"
							EndIf
						EndIf
                    EndIf 
                    
					//Gera array de procedimentos que não estão deletados para gravar na BD6
					if !(aColsIte[nI,Len(aHeadIte) + 1])
								
						AaDd(aDadosB1N,{{ "SEQMOV", aColsIte[nI][GdFieldPos("B1N_SEQUEN",aHeadIte)] },;
										{ "CODPRO", aColsIte[nI][GdFieldPos("B1N_CODPRO",aHeadIte)] },;
										{ "CODPAD", aColsIte[nI][GdFieldPos("B1N_CODPAD",aHeadIte)] },;
										{ "QTD"   , aColsIte[nI][GdFieldPos("B1N_QTDPRO",aHeadIte)] },;
										{ "QTDAUT", "" },;
										{ "VLRAPR", aColsIte[nI][GdFieldPos("B1N_VLRAPR",aHeadIte)] },;
										{ "RESAUT", "" },;
										{ "INDCLIEVO","" },;
										{ "DENTE" , "" },;
										{ "FACE"  , "" },;
										{ "HORINI", "" },;
										{ "HORFIM", "" },;
										{ "VIAAC",  "" },;
										{ "TECUT",  "" },;
										{ "REDAC",  "" },;
										{ "ATPPAR", {} },;
										{ "STPROC", "" },;
										{ "SLVPRO", "" },;
										{ "SLVPAD", "" },;
										{ "STPROC", "" },;
										{ "DIAGNO", "" },; 
										{ "DATPRO", "" }})
                                                                                 				
					endif						
			
				Next
				
				PlsGrvIte(nOpc, aColsIte, aHeadIte, aColsCopo, aHeadCopo)
			EndIf
			
			/*
			If !Empty(cPadInt)
				BOW->(RecLock('BOW',.F.))			
					BOW->BOW_PADINT := cPadInt
				BOW->( MsUnlock() )
			EndIf
			*/
			
			//Chama função de gravação do reembolso na BD5, BD6 e BD7.
			aDadosBOW := {{ "TP_CLIENTE", "WEB" },;							//Tipo de Cliente
							{ "TPGRV"		, "2" },;								//Tipo de Gravacao
							{ "TIPOMAT"   , "1" },;								//Matricula Siga
							{ "GERSEN"		, GetNewPar("MV_PLGSENW",.T.) },;	//Gera senha de autorização
							{ "CODLDP"		, PLSRETLDP(4)},;					//LOCAL de Digitacao
							{ "CODRDA"		, BOW->BOW_CODRDA },;				//Rda
							{ "CNES"		, BAU->BAU_CNES },;					//CNES
							{ "CODLOC"		, BOW->BOW_LOCATE },;				//LOCAL de atendimento
							{ "LOCPRO"		, "" },;								//LOCAL de atendimento da Rda do profissional
							{ "RDAPRO"		, BOW->BOW_OPEEXE },;				//Rda do Profissional de Saude
							{ "RDACONS"	, BOW->BOW_SIGLA  },;	  		    //Conselho Profissional de Saude
							{ "RDANUMC"	, BK6->BK6_CONREG },;				//Numero Conselho Profissional de Saude
							{ "RDAUFCO"	, BOW->BOW_ESTEXE },;				//Estado Conselho Profissional de Saude
							{ "OPEMOV"		, PLSINTPAD() },;						//Operadora de movimento
							{ "OPEINT"		, "" },;								//Operadora de movimento Internacao
							{ "USUARIO"	, BOW->BOW_USUARI },;						//Matricula
							{ "ORIGEM"    , "1" },;								//Origem 1=Autorizacao ou 2=Liberacao
							{ "NUMAUT"    , "" },; 								//Numero da Autorizacao
							{ "LVALOR"		, .T. },; 								//indica que o evento sera valorizado
							{ "LRETVPF"	, .T. },; 								//indica que devera ser retornado o valor da participacao financeira
							{ "LREGPAGATO", .T. },; 								//indica se ira checar regra de "pagar o evento no ato"
							{ "INCAUTIE"  , .F. },;								//Se o usuario for de intercambio e nao existir ele inclui
							{ "AUDEMP"  	, .F. },;								//Critica da operadora se manda para auditoria
							{ "RPC"  		, .T. },;								//.F. vem do remote .T web, pos
							{ "HORAPRO"	, SubStr( StrTran( Time(), ":", "" ), 1, 4 ) },; //Hora
							{ "DATPRO"		, BOW->BOW_DTDIGI },;				//Data de digitação
							{ "NUMLIB"		, "" },;								//Numero da liberacao
							{ "CODCBO"		, "" },;								//Cbos
							{ "CODESP"		, BOW->BOW_CODESP },;				//Especialidade
							{ "CIDPRI"		, "" },;             				//Cid Principal
							{ "CID2"		, "" },;								//Cid 2
							{ "CID3"		, "" },;								//Cid 3
							{ "CID4"		, "" },;								//Cid 4
							{ "CID5"		, "" },;								//Cid 5
							{ "OPESOL"		, BOW->BOW_OPESOL },;				//Operadora Solicitante
							{ "CDPFSO"		, "" },;								//Profissional Solicitante
							{ "CDOPEX"		, BOW->BOW_OPEEXE },;				//Operadora Executante
							{ "CDPFEX"		, BOW->BOW_CDPFRE },;       	    //Profissional Executante
							{ "CPFEXE"		, "" },;           	 				//Cpf Executante
							{ "CNESEXE"	, "" },;           					//Cnes Executante
							{ "NOMEXEC"	, BOW->BOW_NOMEXE },;            	//Nome Executante
							{ "NUMIMP"		, "" },;								//Atendimento Laboratorial
							{ "MSG01"    	, "" },; 								//Observacao
							{ "MSG02"    	, "" },;								//Observacao
							{ "MSG03"    	, "" },;								//Mensagem
							{ "NRAOPE"		, "" },;								//Numero autorizacao operadora
							{ "NRAEMP"		, "" },;      						//Numero autorizacao empresa
							{ "VIACAR"    , "" },; 								//Via do Cartao
							{ "DTVALID"   , "" },;     							//Data de Validade
							{ "AREAABR"   , "" },; 								//Abrangencia
							{ "NATJURI"   , "" },;								//Natureza juridica
							{ "TIPO"      , "04" },;								//Tipo de Guia
							{ "NOMUSR"    , "" },; 								//Nome Contido na carteirinha
							{ "TIPSAI"    , "" },; 								//Tipo de Saida
							{ "TIPATE"    , "" },; 								//Tipo de Atendimento
							{ "TIPATO"    , "" },; 								//Tipo de Atendimento Odontologico
							{ "TIPFAT"    , "" },; 								//Tipo de Faturamento
							{ "TIPDOE"    , "" },; 								//Tipo de Doenca
							{ "TMPDOE"    , "" },; 								//Tempo da Doenca
							{ "UNDDOE"    , "" },; 								//Unidade da Doenca
							{ "INDACI"    , "" },; 								//Indicacao de Acidente
							{ "TPEVEN"		, "" },; 								//Grupo de internacao
							{ "TIPINT"    , "" },;								//Tipo de Internacao
							{ "REGINT"   	, "" },;								//Regime da Internacao
							{ "PADINT"   	, BOW->BOW_PADINT },;					//Tipo de Acomodacao
							{ "PADCON"   	, "" },;								//Padrao de Conforto
							{ "CHKREG"    , "" },; 								//Se vai checar regras ou nao
							{ "DATSOL"    , "" },; 								//Carater da solicitacao
							{ "CARSOL"    , "" },; 								//Carater da solicitacao
							{ "INDCLI"    , "" },; 								//Indicacao de Clinica
							{ "TIPCON"    , "" },;								//Nome Contido na carteirinha
							{ "GUIPR"    	, "" },;								//Guia Principal
							{ "VALTOT"    , BOW->BOW_VLRAPR},;					//Valor total da Guia honorario
							{ "INTERN"    , .F. },; 								//Internacao
							{ "EVOLU"    	, .F. },; 								//Evolucao (prorrogacao de internacao)
							{ "QDISOL"    , 0 },;								//Quantidade de Diarias Solicitada
							{ "HORIND"    , .F. } ,;								//Honorario individual
							{ "CGCSOLT"   , "" } ,;								//Cgc Rda Solicitada
							{ "NUMPEG"    , "" } ,;								//Chave do BD6 - Numero da PEG
							{ "AUNMED" 	, {} } ,;								//Unidade / Participacao
							{ "FORBLO"		, .F. },;								//Bloqueio
							{ "RESINT"    , .F. },;
							{ "TIPGUI"   	, "04" },;
							{ "ESPSOL"		, BOW->BOW_CDPFSO } ,;
							{ "ATENRN"		, "0" },; 								//Atendimento RN
							{ "INIFAT"		, "" },;
							{ "PRVQUI"		, "" },;
							{ "PRVOPM"		, "" },;
							{ "FIMFAT"		, "" },;
							{ "DTRLZ"		, "" },;
							{ "DTRLZ2"		, "" },;
							{ "DTRLZ3"		, "" },;
							{ "DTRLZ4"		, "" },;
							{ "DTRLZ5"		, "" },;
							{ "DTRLZ6"		, "" },;
							{ "DTRLZ7"		, "" },;
							{ "DTRLZ8"		, "" },;
							{ "DTRLZ9"		, "" },;
							{ "DTRLZ1"		, "" },;
							{ "LODONTO"   , .F. },;
							{ "TIPOCONFIRM",  ""},;
							{ "OBSGUI"		, "" },;
							{ "ESPEXE"		, "" },;
							{ "PROTOC"		, BOW->BOW_PROTOC },;
							{ "GUIPRE"		, "" }} // Numero 2-Guia Prestador na guia de Consulta via Portal do Prestador.	
					
			If FindFunction("PLGRGUIREE") .AND. lGrvRmbBD5	
			//Após finalização da gravação do reembolso pelo portal (status = 'Protocolado'), grava guia de reembolso nas tabelas BD5, BD6 e BD7.
			PLGRGUIREE(aDadosBOW, aDadosB1N)
			Endif
		EndIf
		
	ElseIf nOpc == K_Excluir
		cOpeProt := PLSINTPAD()
		If AllTrim(BOW->BOW_NUMAUT) == ""
			
			DbSelectArea("BOX")
			BOX->(DbSetOrder(1))
			
			If BOX->(DbSeek(xFilial("BOX") + cOpeProt + BOW->BOW_PROTOC))
				While !BOX->(Eof()) .And. BOX->(BOX_FILIAL+BOX_CODOPE+BOX_PROTOC) == ;
					BOW->(BOW_FILIAL+BOW_OPEMOV+BOW_PROTOC)
					
					BOX->(RecLock('BOX',.F.))
					BOX->(DbDelete())
					BOX->(DbSkip())
					BOX->( MsUnlock() )
				EndDo
			EndIf
			
			BOW->(RecLock('BOW',.F.))
			BOW->(DbDelete())
			BOW->( MsUnlock() )
			
			If PLSALIASEX("B1N")
				PlsGrvIte(nOpc, aColsIte, aHeadIte, aColsCopo, aHeadCopo)
			EndIf
		Else
			MsgAlert( STR0121 + BOW_OPEUSR+BOW_CODLDP+BOW_CODPEG+BOW_NUMAUT+BOW_ORIMOV) //"Este protocolo está vinculado à guia "
			lRet := .F.
		EndIf
		
	ElseIf nOpc == K_Alterar
		
		
		//Permite mudar para "Em analise" apenas se o status anterior for "Protocolado"
		If M->BOW_STATUS == '2'
			If !BOW->BOW_STATUS $ '0,1,2,3,4,B,C'
				Help( ,, 'HELP',," O status selecionado não respeita a ordem de status do processo de reembolso. ", 1, 0)
				lRet := .F.
			EndIf
			//Valida a gravavaçao da observação
			If BOW->(FieldPos("BOW_MOTIND")) > 0
				
				If lRet .AND. BOW->BOW_STATUS $ '4' .AND. EMPTY(M->BOW_MOTIND)
					Help("",1,"PLBOW015")
					lRet:= .F.
				EndIf
			Else
				
				If lRet .AND. BOW->BOW_STATUS $ '3,4' .AND. AllTrim(M->BOW_OBS) == ""
					Help("",1,"PLBOW015")
					lRet:= .F.
				EndIf
			EndIf
		EndIf
		
		//Aplica regras de validacao se status for:
		//3-Deferido, 4-Indeferido, B-Aguardando informação do Beneficiário ou C-Parcialmente aprovado
		If lRet .AND. M->BOW_STATUS $ '3,4,B,C'
			
			//Valida status:
			//Caso todos os itens estejam reprovados/glosados, o status deve ser INDEFERIDO
			//Caso todos os itens estejam aprovados, o status deve ser DEFERIDO
			//Para os casos que existam itens aprovados e reprovados, o status deve ser PARCIALMENTE APROVADO
			If M->BOW_STATUS <> 'B' .and. M->BOW_STATUS <> '4'
				
				if cStatusTemp <> M->BOW_STATUS
					M->BOW_STATUS := cStatusTemp
				endif
			EndIf
			
			If !BOW->BOW_STATUS $ '1,2,B,C' .AND. BOW->BOW_STATUS <> M->BOW_STATUS .AND. !(M->BOW_STATUS == 'B' .AND. BOW->BOW_STATUS == '0'); 
			 	.AND. !(M->BOW_STATUS == 'C' .AND. BOW->BOW_STATUS == '3') .AND. !(BOW->BOW_STATUS $ cStatAud) 
				Help( ,, 'HELP',," O status selecionado não respeita a ordem de status do processo de reembolso. ", 1, 0)
				lRet := .F.
			EndIf
			//Valida a gravavaçao da observação
			If lRet .AND. M->BOW_STATUS $ '4' .AND. EMPTY(M->BOW_MOTIND)
				Help("",1,"PLBOW015")
				lRet:= .F.
			EndIf
		EndIf
		
		//Não permite selecionar as demais opções
		If lRet .AND. !M->BOW_STATUS $ cStatAlter   
			Help( ,, 'HELP',," O status selecionado não está configurado no parâmetro MV_PLSTALT. ", 1, 0)
			lRet := .F.
		EndIf
		
		If lRet .AND. (M->BOW_STATUS = 'A')
			Help( ,, 'HELP',," O status selecionado não respeita a ordem de status do processo de reembolso. ", 1, 0)
			lRet := .F.
		EndIf
		
		//Grava a alteração
		If lRet
			//cStatusAnterior := BOW->BOW_STATUS
			if lRet .AND. M->BOW_STATUS $ 'B,D' .AND. cStatusAnterior<> "D"

				If BOW->BOW_STATUS = "D" 
					
					For nI := 1 To nLenAcols
						
						//Não foi feito o recklock pois a gravação dos itens acontece na função PlsGrvIte
						//utilizando o acols 
						If !aColsIte[nI][nHeader1] .AND. aColsIte[nI][GdFieldPos("B1N_IMGSTA",aHeadIte)] == "ENABLE "
							aColsIte[nI][GdFieldPos("B1N_IMGSTA",aHeadIte)] := "DISABLE"
						EndIf  
					Next 
				EndIf 
			EndIf
			
			dbSelectArea("SX3")
			SX3->(dbSetOrder(1))
			If SX3->(DbSeek('BOW'))
				BOW->(RecLock('BOW',.F.))
				While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =='BOW'
					If X3Uso(SX3->X3_USADO)
						If GetSx3Cache(SX3->X3_CAMPO, "X3_CONTEXT") <> "V" .AND. SX3->X3_CAMPO <> "BOW_MOTPAD" .AND. ; 
						   SX3->X3_CAMPO <> "BOW_DTCANC" .AND. SX3->X3_CAMPO <> "BOW_MOTIND" .AND. SX3->X3_CAMPO <> "BOW_OBS" 						   
							If BOW->(FieldPos(SX3->X3_CAMPO)) > 0 
							&("BOW->"+SX3->X3_CAMPO) := &("M->"+SX3->X3_CAMPO)
							EndIf
						EndIf
					EndIf
					
					SX3->(DbSkip())
				EndDo
				
				If BOW->BOW_STATUS == "D" 
				
					BOW->BOW_DTCANC		:= dDatabase
				Endif
				
				BOW->( MsUnlock() )
			Endif
			
			If BOW->(FieldPos("BOW_MOTIND")) > 0
				BOW->(RecLock('BOW',.F.))
				If M->BOW_STATUS $ "4"
					BOW->BOW_MOTIND := M->BOW_MOTIND

					//Ajustar a guia gerada no BD5 para a situação de Bloqueada, quando indeferida. Caso retorne para outros status
					//a guia irá voltar a ficar como pronta.
					BD5->(DbSetOrder(17))  //Filial + ANOAUT, MESAUT, NUMAUT
					If ( BD5->(DbSeek(xFilial("BD5") + BOW->(BOW_OPEMOV+BOW_ANOAUT+BOW_MESAUT+BOW_NUMAUT))) )
						PLSCNCGCOB( BD5->(RECNO()), "3", GetNewPar("MV_PLSIMBG", "001") )
					EndIf	

				ElseIf !(M->BOW_STATUS $ "B,D")
					BOW->BOW_MOTIND := ""
				EndIf
				
				If M->BOW_STATUS != "B" .and. !(M->BOW_STATUS $ 'B,D')
					BOW->BOW_OBS := M->BOW_OBS
				EndIf
				
				BOW->BOW_STATUS := M->BOW_STATUS
				if (BOW->(FieldPos("BOW_REGINT")) > 0 ) .AND. (BOW->(FieldPos("BOW_GRPINT")) > 0 ) .AND. (BOW->(FieldPos("BOW_DATPAG")) > 0 )
					BOW->BOW_DATPAG := M->BOW_DATPAG
					BOW->BOW_GRPINT := M->BOW_GRPINT
					BOW->BOW_REGINT := M->BOW_REGINT
				endIf
				
				If M->BOW_STATUS == "4"
					BOW->BOW_PGMTO := STR0199 //Não autorizado
				
				ElseIf M->BOW_STATUS == "D" 
					BOW->BOW_PGMTO := "Cancelado"
				
				Else
					BOW->BOW_PGMTO := STR0169 //Em análise
				EndIf 
				
				BOW->BOW_MUNATE := M->BOW_MUNATE
				BOW->BOW_UFATE  := M->BOW_UFATE
				BOW->BOW_TELCON := M->BOW_TELCON
				If BOW->BOW_STATUS == "D"
				
					BOW->BOW_DTCANC		:= dDatabase
				Endif
	
				BOW->( MsUnlock() )

				//Verifico o status anterior. Se era Indeferido e passou para outro, desbloqueio a Guia na BD5
				If ( cStatusAnterior == "4" )   //Indeferido
					BD5->(DbSetOrder(17))  //Filial + ANOAUT, MESAUT, NUMAUT
					If ( BD5->(DbSeek(xFilial("BD5") + BOW->(BOW_OPEMOV+BOW_ANOAUT+BOW_MESAUT+BOW_NUMAUT))) )
						PLSCNCGCOB( STR(BD5->(RECNO())), "1", "" )
					EndIf
				EndIf	


			Else
				BOW->(RecLock('BOW',.F.))
				If M->BOW_STATUS $ "2,3,4,C"
					BOW->BOW_OBS := M->BOW_OBS
				Else
					BOW->BOW_OBS := ""
				EndIf
				
				BOW->BOW_STATUS := M->BOW_STATUS
				BOW->( MsUnlock() )
			EndIf
		EndIf
		
		If PLSALIASEX("B1N")
			
			For nI := 1 To nLenAcols  
				
				//Verifica se a data de execução do
				//procedimento está dentro do período
				//de uma internação
				aDadInter := PLSREINT(aColsIte[nI][GdFieldPos("B1N_GUIPRI",aHeadIte)],;
				DTOS(aColsIte[nI][GdFieldPos("B1N_DATPRO",aHeadIte)]),;
				aColsIte[nI][GdFieldPos("B1N_MATRIC",aHeadIte)],;
				.F.,;
				.F.)
				
				//Grava os dados da internação, para o cálculo da coparticipação por faixa
				If len(aDadInter) > 0
					aColsIte[nI][GdFieldPos("B1N_GUIPRI",aHeadIte)] := aDadInter[1]
					aColsIte[nI][GdFieldPos("B1N_INTDE" ,aHeadIte)] := aDadInter[2]
					aColsIte[nI][GdFieldPos("B1N_INTATE",aHeadIte)] := aDadInter[3]
				EndIf
				
				if !(aColsIte[nI,Len(aHeadIte) + 1])
				
					//cPadInt := AllTrim( Posicione("BE4", 2, xFilial("BE4")+aColsIte[nI][GdFieldPos("B1N_GUIPRI",aHeadIte)], "BE4_PADINT") )
					If !Empty( aColsIte[nI][GdFieldPos("B1N_GUIPRI",aHeadIte)] )					
						BE4->(DbSetOrder(2)) //BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
						If BE4->( MsSeek(xFilial("BE4")+aColsIte[nI][GdFieldPos("B1N_GUIPRI",aHeadIte)]) )
                   			aColsIte[nI][GdFieldPos("B1N_PADINT",aHeadIte)] := AllTrim(BE4->BE4_PADINT)
                   			aColsIte[nI][GdFieldPos("B1N_PADCON",aHeadIte)] := AllTrim(BE4->BE4_PADCON)
                   			aColsIte[nI][GdFieldPos("B1N_GRPINT",aHeadIte)] := AllTrim(BE4->BE4_GRPINT)
                   			aColsIte[nI][GdFieldPos("B1N_TIPINT",aHeadIte)] := AllTrim(BE4->BE4_TIPINT)
                   			aColsIte[nI][GdFieldPos("B1N_REGINT",aHeadIte)] := AllTrim(BE4->BE4_REGINT)	

							If !lCopartInternacao
								aColsIte[nI][GdFieldPos("B1N_ABATPF",aHeadIte)] := "0"
							EndIf   		
						EndIf
                    EndIf 
	                
	            EndIf 
				
			Next
			PlsGrvIte(nOpc, aColsIte, aHeadIte, aColsCopo, aHeadCopo)
		EndIf
	
		/*
		If !Empty(cPadInt)
			BOW->(RecLock('BOW',.F.))			
				BOW->BOW_PADINT := cPadInt
			BOW->( MsUnlock() )
		EndIf
		*/
		
	Endif
	
	//Grava Histórico após Inclusão/Alteração
	If lRet .AND. nOpc <> K_Excluir
		PLGRVBOX(BOW->BOW_PROTOC,BOW->BOW_MATRIC,BOW->BOW_STATUS, /*cNumMov*/, /*cNumCC*/, /*dDtBaix*/, BOW->BOW_OBS, /*cLocate*/, /*cCodPeg*/, /*cOrigem*/,BOW->BOW_NPROCE )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ P.E. utilizado para manipular o último registro da BOW que foi gravado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PLGRVBOW")
		
		aAreaBOW := BOW->(GetArea())  
		aAreaB1N := B1N->(GetArea()) 
		
		ExecBlock("PLGRVBOW",.F.,.F.,{BOW->(Recno())})

		RestArea(aAreaBOW) 
		RestArea(aAreaB1N) 
	Endif
	
	End Transaction
EndIf

if nOpc == K_Alterar .and. cStatusAnterior <> BOW->BOW_STATUS .and. BOW->BOW_STATUS <> '3' .AND. lRet
	PLRMBPRE("BOW","B1N", BOW->BOW_PROTOC, BOW->BOW_STATUS)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve abrir a tela de Cadastro de Rede Não Referenciada                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF (SupergetMV("MV_VRDANRF", .F., .F.)) .AND. lRet
	PLGRVBK6()
ENDIF

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ABOWFinal ³ Autor ³ Everton M. Fernandes	³ Data ³ 20.02.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibir dados da autorizacao/liberacao efetuada             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
static Function ABOWFinal()

LOCAL cNomUser
LOCAL cSIM
LOCAL cNAO
LOCAL cNomRDA
LOCAL oDlg
LOCAL oFontNum
LOCAL oFontAutor
LOCAL oFontTit
LOCAL oSay
LOCAL nItensSIM := 0
LOCAL nItensNAO := 0
LOCAL nVlrPF := 1
LOCAL nColAut
LOCAL oBot01
LOCAL oBot02
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fontes utilizadas somente nesta funcao...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFontNum NAME "Arial" SIZE 000,-016 BOLD
DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-019 BOLD
DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra Resumo da Autorizacao...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
DEFINE MSDIALOG oDlg TITLE STR0053 FROM 009,000 TO 024,070 OF GetWndDefault()  //"Dados do reembolso "

cNomUser := TransForm(M->BOW_USUARI,PesqPict("BOW","BOW_USUARI"))+" - "+M->BOW_NOMUSR

If BOW->(FieldPos("BOW_CODREF")) > 0
	cNomRDA  := TransForm(M->BOW_CODREF,PesqPict("BOW","BOW_CODREF"))+" - "+M->BOW_NOMREF
Else
	cNomRDA  := ""
EndIf
cSIM     := StrZero(nItensSIM,2)
cNAO     := StrZero(nItensNAO,2)


oBot01 := SButton():New(097, 005, 1, {|| oDlg:End() },,.T.)
oBot01:cToolTip := STR0055 //"Fechar Tela"

oBot02 := SButton():New(097, 035, 6, {|| TIPRELAT() },,.T.)
oBot02:cToolTip := STR0122 //"Imprimir"

@ 007,005 SAY oSay PROMPT STR0123  SIZE 220,010 OF oDlg PIXEL FONT oFontNum //"Protocolo Número.:"
@ 006,095 MSGET BOW->BOW_PROTOC                           SIZE 175,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 025,005 SAY oSay PROMPT STR0058  SIZE 220,010 OF oDlg PIXEL //"Usuario              " //"Usuario              "
@ 025,065 MSGET cNomUser                           SIZE 205,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 043,005 SAY oSay PROMPT STR0059  SIZE 220,010 OF oDlg PIXEL //"Rede Atendimento     " //"Rede Atendimento     "
@ 043,065 MSGET cNomRDA                           SIZE 205,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 066,005 SAY oSay PROMPT STR0057  SIZE 220,010 OF oDlg PIXEL //"Senha" //"Senha"
@ 066,065 SAY oSay PROMPT "[ "+BOW->BOW_SENHA+" ]" SIZE 220,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_HRED

ACTIVATE MSDIALOG oDlg CENTERED

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PBOWCli   ³ Autor ³ Everton M. Fernandes	³ Data ³ 20.02.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega o cliente										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±     `
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PBOWCli()

LOCAL aCliente := PLSAVERNIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,IF(BA3->BA3_TIPOUS=="1","F","J"),;
BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,nil,BA1->BA1_TIPREG,.F.)

If aCliente[1,1] <> "ZZZZZZ"
	M->BOW_CODCLI := aCliente[1][1]
	M->BOW_LOJA   := aCliente[1][2]
	M->BOW_NOMCLI := aCliente[1][3]
Endif

Return .t.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLBOWCarCr ³ Autor ³ Everton M. Fernandes	³ Data ³ 20.02.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega as criticas    									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLBOWCarCr()
//------------------------------///------------------------------//

CheckHLP("PPLBOWBOW",,,) //"Não será possível acessar a  rotina de reembolso."
CheckHLP("SPLBOWBOW",,,) //"Não foi possível localizar a rede de atendimento genéricacadastrada."

CheckHLP("PPLBOW003",,,) //"Não será possível a confirmaçãoda autorização de reembolso."
CheckHLP("SPLBOW003",,,) //"Não foi informado nenhum código de procedimento para serreembolsado."

CheckHLP("PPLBOW004",,,) //"Não será possível a confirmaçãoda autorização de reembolso."
CheckHLP("SPLBOW004",,,) //"Ano ou Mês de pagamento não informados."

CheckHLP("PPLBOW005",,,) //"Não será possível a confirmaçãoda autorização de reembolso."
CheckHLP("SPLBOW005",,,) //"O prestador solicitante deve serinformado."

CheckHLP("PPLBOW006",,,) //"Não será possível a digitação de procedimentos."
CheckHLP("SPLBOW006",,,) //"Não foi informado nenhum  usuário a ser reembolsado."

CheckHLP("PPLBOW007",,,) //"Não será possível a digitação de procedimentos."
CheckHLP("SPLBOW007",,,) //"Não foi informada nenhuma  rede de atendimento para a guia."

CheckHLP("PPLBOW008",,,) //"Não será possível a confirmaçãodo procedimento."
CheckHLP("SPLBOW008",,,) //"A (re)valorização do procedimento  se faz necessária."

CheckHLP("PPLBOW009",,,) //"Não será possível efetuar a  valorização."
CheckHLP("SPLBOW009",,,) //"Nenhum código de procedimento  foi informado."

CheckHLP("PPLBOW010",,,) //"Não será possivel efetuar a  exclusão do reembolso."
CheckHLP("SPLBOW010",,,) //"A respectiva nota de crédito já sofreu baixa. Deve cancelar abaixa para se conseguir excluir a guia."

CheckHLP("PPLBOW011",,,) //"Não será possível a digitação do procedimento."
CheckHLP("SPLBOW011",,,) //"Para este procedimento existe parametrização para nãopermitir a autorizaçao dereembolso."

CheckHLP("PPLBOW012",,,) //"Falha no acesso a rotina."
CheckHLP("SPLBOW012",,,) //"Não foi possível localizar o  layout de reembolso nocadastro de layout de guias."

CheckHLP("PPLBOW013",,,) //"Não será possível a exclusão."
CheckHLP("SPLBOW013",,,) //"A guia encontra-se faturada.Para exclusão deve-se excluiro lote de cobrança."

CheckHLP("PPLBOW014",,,) //"Não será possível alterar o   status."
CheckHLP("SPLBOW014",,,) //"O status 1=Protocolado somente poderá ser alterado para   o status 2=Em análise."

CheckHLP("PPLBOW015",,,) //"Não será possível alterar o status."
CheckHLP("SPLBOW015",,,)

CheckHLP("PPLBOW016",,,) //"Não será possível alterar o status."
CheckHLP("SPLBOW016",,,) //"O status selecionado não respeita a ordem de status  do processo de reembolso.     "

CheckHLP("PPLBOW017",,,) //"Não será possível a confirmaçãodo procedimento."
CheckHLP("SPLBOW017",,,) //"Existem medicamentos de uso continuo sem receita cadastrada"

CheckHLP("PPLB1N001",,,) //"Este item não foi glosado."
CheckHLP("SPLB1N001",,,) //"Não existe motivo de glosa. "

CheckHLP("PPLB1N002",,,)//"Não será possível visualizar o motivo de glosa."
CheckHLP("SPLB1N002",,,) //"Clique em confirmar para salvar a alteração."

CheckHLP("PPLB44RMB",,,) //"Nenhuma guia foi selecionada."
CheckHLP("SPLB44RMB",,,) //"Selecione uma ou mais guia(s)."

CheckHLP("PPLB1NRMB",,,) //"Preencha o restante dos campos"
CheckHLP("SPLB1NRMB",,,) //"Os campos Sigla C.R, UF Solic. e Solicitante devem ser preenchidos."


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcoes   ³ PLSBOWNR							    				           ³±±
±±³Objetivo  ³ Valida a Rede Nao Referenciada									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBOWNR(lB45)
LOCAL aDadRDA := {}
LOCAL aArea   := GetArea()
DEFAULT lB45  := .F.
lBAU    := .F.  // Inicializa Variavel Statica.

If !lB45
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Se foi informado a rede nao referenciada
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If BOW->(FieldPos("BOW_CODREF")) > 0
		If !Empty(M->BOW_CODREF)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Rede nao referenciada
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			BK6->(dbSetOrder(3) )//BK6_FILIAL, BK6_CODIGO
			If BK6->( MsSeek(xFilial("BK6")+M->BOW_CODREF) )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³ Rda referente a Rede nao referenciada
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				BAU->(dbSetOrder(8) )//BAU_FILIAL, BAU_CODBK6
				If BAU->( MsSeek(xFilial("BAU")+BK6->BK6_CODIGO) )
					lBAU := .T.
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³ Se achou a rda e o estado e crm esta preenchido
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				If !lBAU .And. !Empty(BK6->BK6_CONREG) .And. !Empty(BK6->BK6_ESTCR)
					BAU->(dbSetOrder(3) )//BAU_FILIAL, BAU_ESTCR, BAU_CONREG, BAU_SIGLCR
					If BAU->( MsSeek(xFilial("BAU")+BK6->(BK6_ESTCR+BK6_CONREG)) )
						lBAU := .T.
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³ Se tem vida
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				If !lBAU .And. !Empty(BK6->BK6_MATVID)
					BAU->(dbSetOrder(9) )//BAU_FILIAL,BAU_MATVID
					If BAU->( MsSeek(xFilial("BAU")+BK6->BK6_MATVID) )
						lBAU := .T.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Se nao encontrar procuro RDA generica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !lBAU
		BAU->(dbSetOrder(1) )//BAU_FILIAL,BAU_CODIGO
		If BAU->( MsSeek(xFilial("BAU")+GetNewPar("MV_PLSRDAG","999999")) )
			lBAU := .T.
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Alimenta M
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lBAU
		M->BOW_CODRDA := BAU->BAU_CODIGO
		M->BOW_NOMRDA := BAU->BAU_NOME
		M->BOW_TIPPRE := BAU->BAU_TIPPRE
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Profissional relacionado a rda
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		BB0->( DbSetOrder(1) ) //BB0_FILIAL + BB0_CODIGO
		BB0->( MsSeek( xFilial("BB0")+BAU->BAU_CODBB0 ) )
		
		If BB0->(Found())
			M->BOW_REGEXE := BB0->BB0_NUMCR
			M->BOW_NOMEXE := BB0->BB0_NOME
			M->BOW_CDPFRE := BB0->BB0_CODIGO
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ DadRda
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		PLSDADRDA(M->BOW_OPERDA,M->BOW_CODRDA,"1",dDataBase,Subs(M->BOW_LOCATE,1,3),"")
		
		aDadRDA := PLSGETRDA()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Atualiza M
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		if len(aDadRDA) >=15
			M->BOW_CODESP := aDadRDA[15]
			M->BOW_DESESP := aDadRDA[17]
			M->BOW_LOCATE := aDadRDA[18]
			M->BOW_ENDLOC := aDadRDA[20]
		EndIf
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Se foi informado a rede nao referenciada
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If B45->(FieldPos("B45_CODREF")) > 0
		If !Empty(M->B45_CODREF)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Rede nao referenciada
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			BK6->(dbSetOrder(3) )//BK6_FILIAL, BK6_CODIGO
			If !BK6->( MsSeek(xFilial("BK6")+M->B45_CODREF) )
				Return .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSABOWESP³ Autor ³ Everton M. Fernandes	³ Data ³ 20.02.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valid Especialidade										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSABOWESP()
LOCAL lRet:=.T.

BAQ->(dbSetOrder(1))
If BAQ->(MsSeek(xFilial("BAQ")+PLSINTPAD()+M->BOW_CODESP))
	M->BOW_DESESP:=BAQ->BAQ_DESCRI
Else
	lRet:= .F.
	Help("",1,"REGNOIS")
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLVDPROT ³ Autor ³ Everton M. Fernandes	³ Data ³ 20.02.13³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o Protocolo digitado na Autorizaçao de Reembolso    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLVDPROT(cProt)
Local lRet := .T.
Local lInterProt := .F.

DbSelectArea("BOW")
BOW->(DbSetOrder(1))

lRet := BOW->(DbSeek(xFilial("BOW")+cProt))

If lRet
	If BOW->BOW_STATUS <> '3'
		MsgAlert(STR0135) //"O status do protocolo deve estar como Deferido!"
		lRet := .F.
	EndIf
Else
	MsgAlert(STR0136)//"Registro não encontrado!"
EndIf

If lRet .And. GetNewPar("MV_PLRN395","0") == "1" .And. Empty(cProt)
	
	cProt := Space(20)
	If GetNewPar("MV_PLSUNI","1") == "1" .And. BOW->BOW_CODEMP == GetNewPar("MV_PLSGEIN","0050")
		P773AutInc("B44",@cProt,nil,.T.,.F.,nil,nil,nil,nil,.T.)
		lInterProt := .T.
	Else
		P773AutInc("B44",@cProt,nil,nil,nil,nil,nil,nil,nil,.T.)
	EndIf
	
	If Empty(cProt) .And. !lInterProt
		lRet := .F.
	Endif
EndIf

If lRet
	//Função que carrega o aDadUsr
	lRet := PLSA090USR(BOW->BOW_USUARI,dDataBase,'', 'BOW' )
EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLGRVBOX ³ Autor ³ Everton M. Fernandes	³ Data ³ 20.02.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava o Histórico do protocolo								    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLGRVBOX(cProtoc,cMatric,cStatus, cNumMov, cNumCC, dDtBaix, cObs, cLocate, cCodPeg, cOrigem, cNProce, lPortal)

Local lRet 	:= .T.
Local cOpe		:= PLSINTPAD()
Local cSeq		:= "000"
Local cCodUsr := __cUserId
Local cNomUsr	:= cUserName

DEFAULT cProtoc := ""
DEFAULT cMatric := ""
DEFAULT cStatus := ""
DEFAULT cNumMov := ""
DEFAULT cNumCC 	:= ""
DEFAULT cLocate := ""
DEFAULT cCodPeg := ""
DEFAULT cOrigem := ""
DEFAULT cNProce	:= ""
DEFAULT lPortal := .F.

//Inicia a transação

Begin Transaction
If PLSALIASEXI("BOX")
	
	//Descobre o número do último registro deste protocolo
	DbSelectArea("BOX")
	BOX->(DbSetOrder(1))
	//Gera o próximo código sequencial
	If BOX->(DbSeek(xFilial("BOX")+cOpe+cProtoc))
		While !BOX->(Eof()) .AND. BOX->(BOX_FILIAL+BOX_CODOPE+BOX_PROTOC)==xFilial("BOX")+cOpe+cProtoc
			cSeq := Soma1(BOX->BOX_SEQUEN)
			BOX->(DbSkip())
		EndDo
	Else
		cSeq := "001"
	EndIf    	
	
	If lPortal .AND. cStatus == "A"
		
		//Inicia a gravação
		BOX->(RecLock('BOX',.T.))
		BOX->BOX_FILIAL := xFilial("BOX")
		BOX->BOX_CODOPE	:= cOpe
		BOX->BOX_PROTOC	:= cProtoc
		BOX->BOX_MATRIC	:= cMatric
		BOX->BOX_SEQUEN	:= cSeq
		BOX->BOX_DATA	:= Date()
		BOX->BOX_HORA	:= Time()
		BOX->BOX_STATUS	:= cStatus
		BOX->BOX_PORTAL := "1" //Sim
		BOX->BOX_NOMUSR := "BENEFICIÁRIO"
		BOX->( MsUnlock() )
	Else
		
		//Retorna dados do usuário logado
		cCodUsr := __cUserId
		cNomUsr	:= cUserName
		
		//Inicia a gravação
		BOX->(RecLock('BOX',.T.))
		
		BOX->BOX_FILIAL := xFilial("BOX")
		BOX->BOX_CODOPE	:= cOpe
		BOX->BOX_PROTOC	:= cProtoc
		BOX->BOX_MATRIC	:= cMatric
		BOX->BOX_SEQUEN	:= cSeq
		BOX->BOX_DATA	:= Date()
		BOX->BOX_HORA	:= Time()
		
		BOX->BOX_STATUS	:= cStatus
		BOX->BOX_CODUSR	:= cCodUsr
		BOX->BOX_NOMUSR	:= IIF(lPortal, "BENEFICIÁRIO",cNomUsr)
		
		BOX->BOX_LOCATE := cLocate
		BOX->BOX_NUMMOV	:= cNumMov
		BOX->BOX_CODPEG := cCodPeg
		BOX->BOX_ORIMOV := cOrigem
		
		BOX->BOX_NUMNCC	:= cNumCC
		BOX->BOX_OBS		:= cObs
		If ValType(dDtBaix) <> 'U'
			BOX->BOX_DTBAIX	:= dDtBaix
		EndIf
		BOX->BOX_NPROCE		:= cNProce
		BOX->BOX_PORTAL 	:= IIF(lPortal, "1","0") //1=Sim; 0=Não
		
		BOX->( MsUnlock() )
	EndIf
Else
	MsgAlert("A tabela BOX não existe. Execute o UPDPLSB0!")
EndIf
End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para ser chamado após a gravação							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLGRVBOX")
		
	aAreaBOW := BOW->(GetArea())  
	aAreaB1N := B1N->(GetArea()) 

	ExecBlock("PLGRVBOX",.F.,.F.,{BOX->(Recno())})
		
	RestArea(aAreaBOW) 
	RestArea(aAreaB1N) 
Endif


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLBOWHIS ³ Autor ³ Everton M. Fernandes	³ Data ³ 29.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe o Histórico do protocolo								    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLBOWHIS(cAlias,cProtoc,cCodOpe)
LOCAL nOpca		:= 0
LOCAL nLarg		:= 0
LOCAL nLeft		:= 0
LOCAL nTop			:= 0
LOCAL nBottom		:= 0
LOCAL oMemo
LOCAL cTexto	:= ""

LOCAL oDlg
LOCAL oFontAutor
LOCAL oGet

LOCAL aPosObj		:= {}
LOCAL aObjects	:= {}
LOCAL aSize		:= {}
LOCAL aInfo		:= {}
LOCAL aButton		:= {}
LOCAL aBOXHeader	:= {}
LOCAL aBOXCols	:= {}
LOCAL bOK			:= {|| nOpca := 1,oDlg:End(),oDlg:End(),.F.  }
LOCAL bCancel		:= {|| oDlg:End()}

PRIVATE oSay
PRIVATE cCadastro:= STR0003  //"Autorização de reembolso"

//Desativa o atalho de teclado para não permitir abrir a rotina varias vezes enquanto ela esta aberta
SET KEY VK_F2 TO //16-02

DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-012 BOLD

DEFAULT cCodOpe := PLSINTPAD()

If !PLSALIASEXI("BOX")
	MsgAlert("A tabela BOX não existe. Execute o UPDPLSB0!")
	Return
EndIf

If Empty(Alltrim(cProtoc))
	If Pergunte("PLSBOX", .T.)
		cCodOpe := MV_PAR01
		cProtoc := MV_PAR02
	EndIf
EndIf

If !Empty(Alltrim(cProtoc))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aCols e aHeader...                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Store Header "BOX"  TO aBOXHeader For .T.
	
	dbSelectArea( "BOX" )
	dbSetOrder(1)
	If dbSeek( xFilial( "BOX" ) + cCodOpe + cProtoc )

		//-------------------------------------------------------------------
		//  LGPD
		//-------------------------------------------------------------------
		objCENFUNLGP:useLogUser()
		
		Store COLS "BOX" TO aBOXCols FROM aBOXHeader While BOX->( BOX_FILIAL + BOX_CODOPE + BOX_PROTOC ) == xFilial( "BOX" ) + cCodOpe + cProtoc
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ajusta tamanho dos objetos.                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize := MsAdvSize()
		AAdd( aObjects, { 010, 050, .T., .F. } )
		AAdd( aObjects, { 010, 100, .T., .T. } )
		
		aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
		aPosObj := MsObjSize( aInfo, aObjects )
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define Dialogo...                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlg TITLE STR0004 FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel //"Reembolso"
		DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Enchoice...                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		dbSelectArea("BOW")
		dbSetOrder(1)
		If DbSeek(xFilial("BOW")+cProtoc)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Ajusta a posiçao e tamanho do Get
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			nLarg 	:= aPosObj[2,4] * 0.8
			nTop 	:= aPosObj[2,1]
			nLeft 	:= aPosObj[2,2]
			nBottom	:= aPosObj[2,3]

			// Cria Fonte para visualização
			oFont1	:= TFont():New("Arial",,-12,,.T.)
		
			oSay1:= TSay():New(03,01,{||GetSx3Cache("BOW_PROTOC","X3_TITULO")},oDlg,,oFont1)
			oGet1:= TGet():New(50,08,{ | u | BOW->BOW_PROTOC }, oDlg, 100, 010,,,,,,,,.T.,,,{|| .T.},,,,.T.,,,"BOW->BOW_PROTOC" )


			oSay2:= TSay():New(03,25,{||GetSx3Cache("BOW_NOMCLI","X3_TITULO")},oDlg,,oFont1)
			oGet2:= TGet():New(50,200,{ | u | BOW->BOW_NOMCLI }, oDlg, 250, 010,,,,,,,,.T.,,,{|| .T.},,,,.T.,,,"BOW->BOW_NOMCLI" )

			oSay3:= TSay():New(03,60,{||GetSx3Cache("BOW_MATRIC","X3_TITULO")},oDlg,,oFont1)
			oGet3:= TGet():New(50,480,{ | u | BOW->BOW_MATRIC }, oDlg, 50, 010,,,,,,,,.T.,,,{|| .T.},,,,.T.,,,"BOW->BOW_MATRIC" )

			oSay4:= TSay():New(03,85,{||GetSx3Cache("BOW_DTDIGI","X3_TITULO")},oDlg,,oFont1)
			oGet4:= TGet():New(50,680,{ | u | BOW->BOW_DTDIGI }, oDlg, 50, 010,,,,,,,,.T.,,,{|| .T.},,,,.T.,,,"BOW->BOW_DTDIGI",,,,.T. )





			oGet := MSNewGetDados():New(nTop, nLeft, nBottom, nLarg, /*[nStyle]*/, "AlwaysTrue()", "AlwaysTrue()", "" , {}, 0, 9999, "AlwaysTrue()", "AlwaysTrue()", "AlwaysTrue()", oDlg, aBOXHeader, aBOXCols, , "" )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Ajusta a posiçao e tamanho do MEMO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			nLeft += nLarg
			nLarg := aPosObj[2,4] * 0.19
			nBottom *= 0.80
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Inicializa a variável do Memo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			cTexto := BOX->BOX_OBS
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Cria o Memo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			@ nTop, nLeft Get oMemo Var cTexto Memo When .F. Size nLarg, nBottom Of oDlg Pixel
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Seta a função para alterar dinâmicamente o Memo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			oGet:bChange  := {||PLBOWCNG(@cTexto, oMemo, oGet)}
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ativa o Dialogo...                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,bOK,bCancel,.F.,aButton)  })
	Else
		MsgAlert("Protocolo não encontrado!")
	EndIf
EndIf

//Ativa o atalho novamente
SetKey(VK_F2,{|| PLBOWHIS("BOW",BOW->BOW_PROTOC)}) // Historico do reembolso 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLBOWCNG ³ Autor ³ Everton M. Fernandes	³ Data ³ 29.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe as observações no memo   							    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLBOWCNG(cTexto, oObj, oGet)
LOCAL nPosObs := GDFieldPos("BOX_OBS",oGet:aHeader)

If ValType(oObj) <> 'U'
	cTexto:= oGet:aCols[oGet:nAt][nPosObs]
	oObj:Refresh()
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLBOWAPR ³ Autor ³ Everton M. Fernandes	³ Data ³ 29.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprovaçao do Protocolo de Reembolso                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLBOWAPR(aMatriz, lRecurso, oObj, aAuto)
local nTam      := 0
Local dAprov	:= Date()
Local dVenc		:= Date()
Local aArea   	:= GetArea()
Local aRegs		:= {}
Local aRetMF	:= {}
Local cPerg		:= ""
Local cChave	:= ""
Local cProtoc	:= ""
Local nAprov	:= 0
Local aColsB45 	:= {}
Local aCabB45	:= {}
Local aTrbB45	:= {}
Local cNat 		:= ""
Local cTipTit 	:= ""
Local cPrefixo	:= ""
Local cNumTit 	:= ""
Local cAuxPrefi	:= ""
Local cAuxTit 	:= ""
Local cCodCli 	:= ""
Local cLoja   	:= ""
Local cCodInt 	:= ""
Local cCodEmp 	:= ""
Local cMatric 	:= ""
Local cTipReg 	:= ""
Local cConEmp 	:= ""
Local cVerCon 	:= ""
Local cSubCon 	:= ""
Local cVerSub 	:= ""
Local cNCC		:= ""
Local nVlrPag 	:= 0
Local dVencto 	:= Date()
Local aBanco	:= {}
LOCAL lRecursoGlosa := .F.
LOCAL lRetorno		:= .T.
LOCAL aDadAut		:= {}
LOCAL lAlt			:= .F.
LOCAL naut			:= 0
LOCAL lAut			:= .F.
LOCAL cTipo       	:= GetNewPar("MV_PLSNCRE","FT")
LOCAL cCodForn		:= ""
LOCAL cSql			:= ""
LOCAL lTitB44		:= .F.
LOCAL aMarkB44		:= {}
LOCAL nI			:= 1
Local aPergs 		:= {}
Local aRet 			:= {}
Local cChvRee		:= ""
Local cCodUsr       := RETCODUSR()
Local lPlsaPrre     := ExistBlock("PLSAPRRE")
Local lPls001Cli 	:= ExistBlock("PLS001CLI")
Local lPls002For 	:= ExistBlock("PLS002FOR")
Local lP001AFim		:= ExistBlock("P001AFIM")
LOCAL dDataRmb      := dDataBase  
LOCAL cSQLRMB       := ""   
LOCAL lDtPagto		:= GETNEWPAR("MV_PLSDTPG",.F.) 
LOCAL aMarkB44      := {}  
LOCAL lBnfBloq      := .F. 
LOCAL lNotb		    := BA3->(FieldPos("BA3_NOTB")) > 0
LOCAL nLenMark      := 0 
LOCAL aAuxMark      :={}	
Local dDtBlqCtb	:= dDataBase
Local aRotAuto		:= {}
Local oDadosFornecedor := Nil
Local lReembCliente := GetNewPar("MV_PLRECLI", .F.) // Autorização do protocolo somente para o cliente vinculado ao protocolo
Local lFatura := .F.
Local cDigitAgen := ""
Local cDigitConta := ""

Default aMatriz := {}
Default lRecurso := .F.
Default oObj := NIL
Default aAuto := {.F., {}}

Private lMsErroAuto		:= .F.

If !aAuto[1]
 	aMarkB44 := PLRETMARK()
Else
	aMarkB44 := aAuto[2]
EndIf

//Nenhuma guia foi selecionada
If EMPTY(aMarkB44) 
	Aviso(STR0049,"Nenhuma guia foi selecionada para aprovação.",{"OK"}, 1 ) //"Nenhuma guia foi selecionada para aprovação."
Return

// Verifica se pelo menos uma das guias é de pagamento no ato para a manipulação do pergunte
ElseIf Ascan(aMarkB44,{ |x| x[2] == .T.})   
	lTitB44 := .T.
EndIf

aadd(/*01*/ aPergs,{ 2,STR0188	/*"Parecer de Aprovação"*/,,{ "1=Lib. financeiro","2=Nao lib. financeiro" },100,/*'.T.'*/,.T. } ) 
aAdd( aPergs ,{1,STR0189 /*"Data do parecer"*/,dDataRmb,"99/99/9999",'If(MV_PAR01 == "1", NaoVazio(), )',,'.T.',60,.F.})

If ExistBlock("PL001ADTV")  

	dData := ExecBlock("PL001ADTV",.F.,.F.,{})
	
	If !EMPTY(dData) .AND. ValType(dData) == "D"
		aAdd( aPergs ,{1,STR0190 /*"Data de vencimento"*/,dData,"99/99/9999",'If(MV_PAR01 == "1", NaoVazio() .AND. MV_PAR03 >= Date(), )',,'.T.',60,.F.})
	Else
		aAdd( aPergs ,{1,STR0190 /*"Data de vencimento"*/,dDataBase,"99/99/9999",'If(MV_PAR01 == "1", NaoVazio() .AND. MV_PAR03 >= Date(), )',,'.T.',60,.F.})
	EndIf
Else
	
	If lTitB44 
	
		cSQLRMB := "SELECT B1k_DATPRE FROM " + RetSQLName("B1K")
		cSQLRMB += " WHERE B1K_CODINT = '" + PlsIntPad() + "' "
		cSQLRMB += " AND B1K_DATINI <= '" + DTOS(dDataBase) + "' AND B1K_DATFIN >= '" + DTOS(dDataBase) + "' "
		cSQLRMB += " AND " + RetSQLName("B1K")+".D_E_L_E_T_ = ' ' "
	
		cSQLRMB := ChangeQuery(cSQLRMB)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQLRMB),"TrbCldPag",.F.,.T.)
		
		If !TrbCldPag->(EOF())
			
			dDataRmb := STOD(TrbCldPag->B1k_DATPRE)
		EndIf	
		
		TrbCldPag->(DbCloseArea())
		
		aAdd( aPergs ,{1,STR0190 /*"Data de vencimento"*/,dDataRmb,"99/99/9999",'If(MV_PAR01 == "1", NaoVazio() .AND. MV_PAR03 >= Date(), )',,'.T.',60,.F.})
	EndIf
EndIf 

If !aAuto[1]
	If ParamBox(aPergs ,"",@aRet,,,.T.,256,129,,,.F.,.F.) 	
		nAprov := Val(aRet[1])
		dAprov := aRet[2]
		
		If LEN(aRet) >= 3 
			dVenc  := aRet[3]
		EndIf 
	Else
		Return(.F.)
	Endif
Else	
	nAprov := 1
EndIf

If Existblock("PLSDBLCTB")
	dDtBlqCtb := Execblock("PLSDBLCTB", .F., .F.)
	
	If Valtype(dDtBlqCtb) <> "D"
		dDtBlqCtb := dDataBase
	endIf
	
endIf

//se for aprovação e a data base nao estiver no bloqueio contabil ou se for indeferimento e a data nao estiver no periodo contabil
//faço assim pois são processos de bloqueio contabil com periodos que podem ser diferentes
//esse if deve ficar aqui e não dentro do FOR, preciso checar o bloqueio contabil 1 vez e não para cada autorização
If (nAprov == 1 .and. PLVLDBLQCO(dDtBlqCtb, {"PLS008"}, .T.)) .or. (nAprov == 2 .and. PLVLDBLQCO(dDtBlqCtb, {"PLS010"}, .T.))
	
	aAuxMark := aClone(aMarkB44) 
	nLenMark := LEN(aAuxMark) 
    /*Observação: o Amark é um array de ponteiro, ao executar o método MarkRec
    a posição que foi utilizada do array é deletada diminuindo o tamanho do array
    até chegar a zero, por isso o for é utilizado como loop, e esse trecho de
    código está dessa forma B44->(DbGoTo(aMarkB44[1][1])), pois após deletar a posição
    as posições restantes são reorganizadas, ou seja, a segunda posição irá ocupar a primeira e depois deletada.*/
    //Percorre todos os itens marcados no browse de autorização.
	FOR nI := 1 to nLenMark 
	
    	lAut := .F.
    	
    	//Posiciona na B44 de acordo com itens selcionados na browse de autorização
    	B44->(DbGoTo(aAuxMark[nI][1]))
    	
    	//Posiciona na B45 de acordo com B44 selecionada
    	B45->(DbSetOrder(1))
    	B45->(MsSeek(xFilial("B45") + B44->B44_OPEMOV + B44->B44_ANOAUT + B44->B44_MESAUT + B44->B44_NUMAUT))
    					
    	//Se a guia de origem estiver preenchida significa que se trata de uma guia de recurso de glosa de reembolso.
    	If B45->(FieldPos("B45_GUIORI")) > 0
    		lRecursoGlosa := (!Empty(B45->B45_GUIORI))
    	Else
    		lRecursoGlosa := .F.
    	Endif

    	//Protege o campo B44_PROTOC
    	cProtoc := AllTrim(B44->B44_PROTOC)
    	
    	//Posiciona na BA1 de acordo com a autorização que está sendo verificada
    	BA1->(DbSetOrder(2))
    	BA1->(MsSeek(xFilial("BA1") + B44->(B44_OPEUSR + B44_CODEMP + B44_MATRIC + B44_TIPREG + B44_DIGITO)))  
    	
		//Grava o motivo do reembolso indeferido
		If nAprov == 2
			If !PLSMTPROT()
				Return
			EndIf
		Else
			BOW->(DbSetOrder(1))
			If !BOW->(DbSeek(xFilial("BOW")+cProtoc))
                BOW->( RecLock("BOW",.F.) )
                BOW->BOW_MOTIND := ""
                BOW->( MsUnLock() )
            EndIf
		EndIf
		
    	//Verifica para qual fornecedor vai ser pago o reembolso
		lForVld  := .F.
		lFoundSA2:= .F.
		cCodInt  := B44->B44_OPEUSR
		cCodEmp  := B44->B44_CODEMP
		cMatric  := B44->B44_MATRIC
		cBanco   := B44->B44_NROBCO //Numero Banco
		cAgencia := B44->B44_NROAGE //Numero Agencia
		cConta   := B44->B44_NROCTA //Numero Conta  			
		cCodCli  := B44->B44_CODCLI
	    cLoja    := B44->B44_LOJA  
		lFatura  := B44->B44_FORPAG == "0"                                	
		
		If  B44->(FieldPos("B44_NRODAG")) > 0 .And. B44->(FieldPos("B44_NRODTO")) > 0 
			cDigitAgen := B44->B44_NRODAG //Digito Conta
			cDigitConta := B44->B44_NRODTO //Digito Conta
		endIf

		//Armazenar Referencia Arquivo BA1 ...
		nOrdBa1O  := BA1->(IndexOrd())
		nRecBa1O  := BA1->(Recno())
 
		//Setar Ordem Arquivo SA2 - Cadastro Fornecedores (SA2) ...
		SA2->(DbSetOrder(3))

		// Geração do Reembolso no Contas a Pagar
		If GetNewPar("MV_PLRESE1", "1") == "0" .And. !lFatura
		
			If lReembCliente .Or. !ChckClientFamilia(cCodCli, cLoja, cCodInt, cCodEmp, cMatric)

				If lReembCliente
					SA1->(DbSetOrder(1))
					If SA1->(MsSeek(xFilial("SA1")+cCodCli+cLoja))
						oDadosFornecedor := GetDadosFornecedor("SA1")	

						If !Empty(oDadosFornecedor["A2_CGC"])
							lFoundSA2 := SA2->(MsSeek(xFilial("SA2")+oDadosFornecedor["A2_CGC"])) 
						else
							SA2->(DbSetOrder(2))
							lFoundSA2 := SA2->(MsSeek(xFilial("SA2")+ Alltrim(oDadosFornecedor["A2_NOME"])))
						Endif
					Else
						aAdd(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")), "", STR0319, B44->B44_PROTOC, STR0320}) // "Cliente vinculado ao protocolo não encontrado na base de dados." ; "Não Gerado"
    					Loop
					EndIf
				Else
					SA1->(DbSetOrder(1))
					oDadosFornecedor := GetDadosFornecedor("SA1")

					If !Empty(oDadosFornecedor["A2_CGC"] )
						lFoundSA2 := SA2->(MsSeek(xFilial("SA2")+oDadosFornecedor["A2_CGC"])) 
					else
						SA2->(DbSetOrder(2))
						lFoundSA2 := SA2->(MsSeek(xFilial("SA2")+ Alltrim(oDadosFornecedor["A2_NOME"])))
					Endif

					If lHabMetric .And. lLibSupFw .And. lVrsAppSw
						FWMetrics():addMetrics(FunName(), {{"totvs-saude-planos-protheus_pagamento-reembolso-cliente-externo-familia-total", 1}})
					Endif
				EndIf

			Else
				//Forcar Buscar Registro Beneficiario Titular ...
				/*O objetivo do trecho abaixo é identificar um beneficiário valido para se tornar um Fornecedor. As opcoes sao:
					Titular Ativo
					Responsavel da Familia (BA1_RESFAM = '1')        
				*/
				If BA1->(FieldPos("BA1_RESFAM")) > 0
					BA1->(DbSetOrder(2))
					
					If BA1->(MsSeek(xFilial("BA1") + cCodInt + cCodEmp + cMatric))
						While !BA1->(Eof()) .And. cCodInt + cCodEmp + cMatric == BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC )
							
							lBnfBloq := PlChHiBlo("BCA",dDataBase,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG) 
							
							//Mesmo estiver bloqueado a data do reembolso estiver no periodo e o  
							//responsavel não precisa ser o titular muitas vezes o titular encontra-se em obito 
							//temos que gerar o reembolso se chegou aqui é pq gerou o protocolo antes de ser bloqueado
							
							If (!lBnfBloq .And. AllTrim(BA1->BA1_TIPUSU) $ GetNewPar("MV_PLCDTIT", "T")) .Or.  BA1->BA1_RESFAM == '1'
								lForVld := .T. 
								exit
							EndIf
							
							BA1->(DbSkip())	
						EndDo 
					EndIf
				
					//reposicionei o beneficiário aqui porque o DBSKIP acima estava colocando um usuario que nem é da familia, isto é,
					//no ultimo dbskip onde ele sai do while pq não tem mais a chave (cCodInt + cCodEmp + cMatric == BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC ))
					if !lForVld
						BA1->(DbGoTo(nRecBa1O))
					endIf
						
					If lForVld .And. !Empty(BA1->BA1_CPFUSR)			
						
						SA2->(DbSetOrder(3)) 		
						lFoundSA2 :=  SA2->(DbSeek(xFilial("SA2")+BA1->BA1_CPFUSR))  //1a Vez .F. e na 2a Vez .T.			
					ElseIf Empty(BA1->BA1_CPFUSR) 
						
						//MsgAlert( ALLTRIM(BA1->BA1_NOMUSR) + STR0304,STR0004) //" não possui CPF cadastrado. "##Atenção
						AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ"), ALLTRIM(BA1->BA1_NOMUSR) + STR0304,STR0004, B44->B44_PROTOC,"Não Gerado"})
						Loop
					ElseIf !lForVld				
						
						//MsgAlert(STR0303+" Usuario : "+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)+" "+ALLTRIM(BA1->BA1_NOMUSR) ,STR0004) //"Para geração do título de pagamento de reembolso, é necessario que o titular esteja ativo ou algum beneficiário esteja configurado como responsável pela família (BA1_RESFAM = 1)."
						AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ"),Alltrim( STR0303)+" Usuario : "+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)+" "+ALLTRIM(BA1->BA1_NOMUSR) , B44->B44_PROTOC,"Não Gerado"})
						Loop
					EndIf
				Else

					//Forcar Buscar Registro Beneficiario Titular ...
					BA1->(DbSetOrder(1))
					BA1->(MsSeek(xFilial("BA1") + cCodInt + cCodEmp + cMatric + GetNewPar("MV_PLCDTIT", "T")))
					
					//Setar Ordem Arquivo SA2 - Cadastro Fornecedores (SA2) ...
					SA2->(DbSetOrder(3))
				
					//Verifico Se Eh Beneficiario Titular ...
					If AllTrim(BA1->BA1_TIPUSU) $ GetNewPar("MV_PLCDTIT","T") // Titular ????
						lFoundSA2 := (!Empty(BA1->BA1_CPFUSR) .And. SA2->(DbSeek(xFilial("SA2")+BA1->BA1_CPFUSR)))  //1a Vez .F. e na 2a Vez .T.
					Else //Se Nao Eh Titular
						lFoundSA2 := .T. //Para nao acessar Area Criacao Cadastro SA2.
					EndIf		
				EndIf

				oDadosFornecedor := GetDadosFornecedor("BA1")

				If lHabMetric .And. lLibSupFw .And. lVrsAppSw
					FWMetrics():addMetrics(FunName(), {{"totvs-saude-planos-protheus_pagamento-reembolso-cliente-interno-familia-total", 1}})

					If ChckClientFamilia(cCodCli, cLoja, cCodInt, cCodEmp, cMatric, oDadosFornecedor["A2_CGC"])
						FWMetrics():addMetrics(FunName(), {{"totvs-saude-planos-protheus_pagamento-reembolso-cliente-igual-beneficiario-total", 1}})
					EndIf
				Endif

			EndIf

			If lPls002For
	    									
				aAreaBOW := BOW->(GetArea())  
				aAreaB1N := B1N->(GetArea()) 
				aAreaB44 := B44->(GetArea()) 
				aAreaB45 := B45->(GetArea()) 
				aAreaB47 := B47->(GetArea()) 
				aAreaSE2 := SE2->(GetArea()) 
				
				If lFoundSA2
					cCodForn := SA2->A2_COD
					cLoja    := SA2->A2_LOJA
				EndIf

				aRetPto  := ExecBlock("PLS002FOR",.F.,.F.,{cCodForn,cLoja,cNat,cPrefixo,cNumTit,cTipo,dVencto,cCodInt,cCodEmp,cMatric})
					
				RestArea(aAreaBOW) 
				RestArea(aAreaB1N) 
				RestArea(aAreaB44)
				RestArea(aAreaB45) 
				RestArea(aAreaB47) 
				RestArea(aAreaSE2) 

				cCodForn := aRetPto[1]
				cLoja    := aRetPto[2]
				cNat     := aRetPto[3]
				cPrefixo := aRetPto[4]
				cNumTit  := aRetPto[5]
				cTipo    := aRetPto[6]
				dVencto  := aRetPto[7]

				//Seta Ordem correta no arquivo SA2 - Cadastro Fornecedores (SA2)
				SA2->(DbSetOrder(1))
				lFoundSA2:=SA2->(Dbseek(xfilial('SA2')+cCodForn+cLoja))

			EndIf

			//busco o banco caso nao tenha sido informado ainda
			If !(lFoundSA2)
					
				If Empty(cBanco) .or. Empty(cAgencia) .or. Empty(cConta)
					BA3->(DbSetORder(1))
					BA3->(MsSeek(xFilial("BA3") + BA1->BA1_CODINT  + BA1->BA1_CODEMP + BA1->BA1_CONEMP + BA1->BA1_VERCON + BA1->BA1_SUBCON + BA1->BA1_VERSUB))// duas vezes BA1->BA1_CODEMP
					
					cBanco   := BA3->BA3_BCOCLI
					cAgencia := BA3->BA3_AGECLI							
					cConta   := BA3->BA3_CTACLI
					
					If BA3->(FieldPos("BA3_DTACLI")) > 0 .And. BA3->(FieldPos("BA3_DTCCLI")) > 0 
						cDigitAgen := BA3->BA3_DTACLI
						cDigitConta := BA3->BA3_DTCCLI		
					EndIf
				EndIf

				aRotAuto := {}
			
				Aadd(aRotAuto, {"A2_FILIAL", xFilial("SA2"), Nil})
				Aadd(aRotAuto, {"A2_COD", GetSX8Num("SA2", "A2_COD"), Nil})
				Aadd(aRotAuto, {"A2_LOJA", "01", Nil})
				Aadd(aRotAuto, {"A2_NOME", oDadosFornecedor["A2_NOME"], Nil})
				Aadd(aRotAuto, {"A2_NREDUZ", oDadosFornecedor["A2_NREDUZ"], Nil})	
				Aadd(aRotAuto, {"A2_END", oDadosFornecedor["A2_END"], Nil})	
				Aadd(aRotAuto, {"A2_BAIRRO", oDadosFornecedor["A2_BAIRRO"], Nil})	
				Aadd(aRotAuto, {"A2_EST",oDadosFornecedor["A2_EST"], Nil})	
				Aadd(aRotAuto, {"A2_MUN", oDadosFornecedor["A2_MUN"], Nil})	
				AAdd(aRotAuto, {"A2_CEP", oDadosFornecedor["A2_CEP"], Nil})
				Aadd(aRotAuto, {"A2_TIPO", "F", Nil})	
				Aadd(aRotAuto, {"A2_CGC", oDadosFornecedor["A2_CGC"], Nil})	
				AAdd(aRotAuto, {"A2_DDD", oDadosFornecedor["A2_DDD"], Nil})
				Aadd(aRotAuto, {"A2_TEL", oDadosFornecedor["A2_TEL"], Nil})	
				Aadd(aRotAuto, {"A2_EMAIL", oDadosFornecedor["A2_EMAIL"], Nil})
				Aadd(aRotAuto, {"A2_BANCO", cBanco, Nil})
				Aadd(aRotAuto, {"A2_AGENCIA",cAgencia, Nil})
				Aadd(aRotAuto, {"A2_DVAGE",cDigitAgen, Nil})
				Aadd(aRotAuto, {"A2_NUMCON", cConta, Nil})
				Aadd(aRotAuto, {"A2_DVCTA", cDigitConta, Nil})
				Aadd(aRotAuto, {"A2_INDRUR", "0", Nil})
				Aadd(aRotAuto, {"A2_COD_MUN", oDadosFornecedor["A2_COD_MUN"], Nil})


				// P.E. utilizado para adicionar novos campos ao array da execauto.
				If lPlsSA2
					aBtAdd := ExecBlock("PLS001ASA2",.F.,.F.,{aRotAuto})
					
					If ValType(aBtAdd) == "A"
						aRotAuto:=	aBtAdd
					EndIf
				EndIf 

				MSExecAuto({|x,y| MATA020(x,y)}, aRotAuto, 3)	
				If lMSErroAuto
					MostraErro()
					DbSelectArea("SA2")
					RollBackSx8()
					Return({.F.})
				Else
					SA2->(ConfirmSX8())
					lFoundSA2 := .T.	
				Endif
			EndIf
		
			//Atualizo Variaveis do Fornecedor ...
			cCodForn := SA2->A2_COD
			cLoja := SA2->A2_LOJA

			FreeObj(oDadosFornecedor)
            oDadosFornecedor := Nil

		EndIf

        //Valida permissão do usuário para realizar aprovação do reembolso
    	BX4->(DbSetOrder(1))
    	If BX4->(DbSeek(xFilial("BX4") + cCodUsr + PLSINTPAD()))
    		If BX4->BX4_APREEM <> "1" //1==Sim
    			//AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),SA2->A2_NREDUZ, "Não Gerado", B44->B44_PROTOC,"Não Gerado"})
    			AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ"), STR0140, B44->B44_PROTOC,"Não Gerado"})
    			Loop
    		Endif
    	Endif
	
    	//Não permite aprovar guias negadas já na criação.
    	If B44->B44_STATUS == "3"
    		AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ"),  "Não existe procedimentos autorizados nesta guia.", B44->B44_PROTOC,"Não Gerado"})
    		Loop
    	EndIf
    	
    	//Verifica auditoria do reembolso
    	If B44->B44_AUDITO == "1"
    		AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),SA2->A2_NREDUZ, "Esta guia está em análise pela auditoria.", B44->B44_PROTOC,"Não Gerado"})
    		Loop
    	EndIf
    	
    	//Verifica se a guia possui protocolo de reembolso
    	If Empty(cProtoc)
    		AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),SA2->A2_NREDUZ, "Esta guia não utilizou um protocolo de reembolso!", B44->B44_PROTOC,"Não Gerado"})
    		//MsgAlert("Esta guia não utilizou um protocolo de reembolso!")
    		Loop
    	Endif
    	
    	//Posiciona no protocolo
    	BOW->(DbSetOrder(1))
    	If !BOW->(DbSeek(xFilial("BOW")+cProtoc))
    		AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),SA2->A2_NREDUZ, "O protocolo desta guia não é válido.", B44->B44_PROTOC,"Não Gerado"})
    		Loop
    	Endif
    			
    	If Empty(dVenc) .AND. nAprov == 1 .AND. B44->B44_FORPAG == "1"
           //MsgAlert(STR0137 + STR0148)//'Digite a data de Vencimento !' ## Ela não pode estar vazia ou ser retroativa!
            AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),SA2->A2_NREDUZ, STR0137 + STR0148, B44->B44_PROTOC,"Não Gerado"})
            Loop
    	Elseif Empty(dAprov) .AND. nAprov == 1 .AND. B44->B44_FORPAG == "1"
            //MsgAlert(STR0138)//'Digite a data de Aprovação !'
            AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),SA2->A2_NREDUZ, STR0138, B44->B44_PROTOC,"Não Gerado"})
            Loop
    	Elseif dVenc < dDataBase .AND. nAprov == 1 .AND. B44->B44_FORPAG == "1"
            //MsgAlert('A data de vencimento não pode ser anterior a data base do sistema.')
            AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),SA2->A2_NREDUZ,'A data de vencimento não pode ser anterior a data base do sistema.', B44->B44_PROTOC,"Não Gerado"})
            Loop
    	Endif

	    	B44->(DbSetOrder(4))
	    	// Esse item se faz necessario devido ao itens que são gerados reembolso e no meio da rotina caia
	    	//o sistema, e nao mudava status e o sistema gerava em duplicidade
	    	If B44->(MsSeek(xFilial("B44")+BOW->BOW_PROTOC))

				If  nAprov == 1 .AND. (BOW->BOW_STATUS $ "5,7") .AND. B44->B44_FORPAG <> '0'
					// Se a forma de pagamento for no ato
					//Gera a NCC
					lAprova := .T.
					
					If lPlsaPrre									
						aAreaBOW := BOW->(GetArea())  
						aAreaB1N := B1N->(GetArea()) 
						aAreaB44 := B44->(GetArea()) 
						aAreaB45 := B45->(GetArea()) 
						aAreaB47 := B47->(GetArea()) 
						aAreaSE2 := SE2->(GetArea()) 

						lAprova := ExecBlock("PLSAPRRE",.F.,.F.,{cProtoc,dAprov,dVenc})
									
						RestArea(aAreaBOW) 
						RestArea(aAreaB1N) 
						RestArea(aAreaB44) 
						RestArea(aAreaB45) 
						RestArea(aAreaB47) 
						RestArea(aAreaSE2) 
					Endif

					//gerar contas a receber
					If GetNewPar("MV_PLRESE1","1") == "1" .and. lAprova
						cAuxPrefi := GetNewPar("MV_PLSPFRE",'"RLE"')
						cAuxPrefi := Eval({|| &cAuxPrefi })
						cAuxTit  := PLSE1NUM(cAuxPrefi)
					EndIf
				Endif

	    		Begin Transaction
	    		//Aprovação
	    		If nAprov == 1
	    					
	    				naut++
	    				
	    				If (BOW->BOW_STATUS $ "5,7")
	    				
	    					If B44->B44_FORPAG == '0'
	    				
	    						lAut := .T.
	    						// Se a forma de pagamento for a faturar
	    						DbSelectArea("BOW")
	    						BOW->(DbSetOrder(1))
	    						BOW->(DbSeek(xFilial("B44")+B44->B44_PROTOC))
	    					
	    						BOW->(RecLock('BOW',.F.))
	    						BOW->BOW_STATUS:='6' //7==Não enviar financeiro
	    					
    							BOW->BOW_PGMTO:= STR0195 //"Credito na Fatura"
	    					
	    						BOW->( MsUnlock() )
	    					
	    						PLRMBPRE("B44","B45", BOW->BOW_PROTOC, "6")
	    					
	    						cNCC := STR0195 //"A FATURAR"
								
								B44->(RecLock('B44',.F.)) 
								B44->B44_STATUS	:= '2'
								B44->B44_DATRMB := dDataRmb
								B44->( MsUnlock() ) 
							
	    						//Grava os dados no array, que é necessário para ser visualizado apos execução da rotina de aprovação.
	    						AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),;
	    								posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ"), cNCC, B44->B44_PROTOC,,"Gerado"})
	    					
    							P001Status(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT), BOW->BOW_PROTOC)
	    								
	    						//Grava o histórico
	    						PLGRVBOX(BOW->BOW_PROTOC,BOW->BOW_MATRIC,BOW->BOW_STATUS,BOW->BOW_NUMAUT, /*cNumCC*/, /*dDtBaix*/, /*cObs*/, ;
	    								BOW->BOW_CODLDP, BOW->BOW_CODPEG, BOW->BOW_ORIMOV,BOW->BOW_NPROCE )
	    					Else
	    					
	    						//gerar contas a receber
	    						If GetNewPar("MV_PLRESE1","1") == "1" .and. lAprova
	    								
	    							cNat     := GetNewPar("MV_PLSNTRE",'"PLS"')
	    							cNat     := Eval({|| &cNat })
	    							cTipTit  := GetNewPar("MV_PLSNCRE","NCC")
	    							cPrefixo := cAuxPrefi
	    							cNumTit  := cAuxTit
	    						
	    							dVencto  := dVenc
	    							cCodCli  := B44->B44_CODCLI
	    							cLoja    := B44->B44_LOJA
	    							nVlrPag  := B44->B44_VLRPAG
	    							cCodInt  := B44->B44_OPEUSR
	    							cCodEmp  := B44->B44_CODEMP
	    							cMatric  := B44->B44_MATRIC
	    							cTipReg  := B44->B44_TIPREG
	    							cConEmp  := B44->B44_CONEMP
	    							cVerCon  := B44->B44_VERCON
	    							cSubCon  := B44->B44_SUBCON
	    							cVerSub  := B44->B44_VERSUB
	    						
	    							If lPls001Cli

										aAreaBOW := BOW->(GetArea())  
										aAreaB1N := B1N->(GetArea()) 
										aAreaB44 := B44->(GetArea()) 
										aAreaB45 := B45->(GetArea()) 
										aAreaB47 := B47->(GetArea()) 
										aAreaSE2 := SE2->(GetArea()) 

	    								aRetPto := ExecBlock("PLS001CLI",.F.,.F.,{cCodCli,cLoja,cNat,cPrefixo,cNumTit,cTipTit,dVencto})
											
										RestArea(aAreaBOW) 
										RestArea(aAreaB1N) 
										RestArea(aAreaB44) 
										RestArea(aAreaB45) 
										RestArea(aAreaB47) 
										RestArea(aAreaSE2) 

	    								cCodCli := aRetPto[1]
	    								cLoja   := aRetPto[2]
	    								cNat    := aRetPto[3]
	    								cPrefixo:= aRetPto[4]
	    								cNumTit := aRetPto[5]
	    								cTipTit := aRetPto[6]
	    								dVencto := dVenc
	    										
	    							EndIf
	    						
									aAdd(aBanco,B44->B44_NROBCO) //Numero Banco
									aAdd(aBanco,B44->B44_NROAGE) //Numero Agencia
									aAdd(aBanco,B44->B44_NROCTA) //Numero Conta
	    						
	    							PLSGRVREM(cPrefixo,cNumTit,cCodCli,cLoja,cTipTit,dVencto,cCodInt,;
	    										cCodEmp,cMatric,3,nVlrPag,cConEmp,cVerCon,cSubCon,;
	    										cVerSub,cTipReg,cNat,aBanco)
	    						
	    							//Atualiza os dados dos títulos no protocolo
	    							B44->(RecLock('B44',.F.))
	    							B44->B44_PREFIX	:= cPrefixo
	    							B44->B44_NUM   	:= cNumTit
	    							B44->B44_TIPO  	:= cTipTit
	    							B44->B44_PARCEL	:= ''
	    							B44->B44_STATUS	:= '2'
										
	    							If !EMPTY(dVenc) 
										B44->B44_DATRMB:= dVenc
									EndIf 
									
	    							B44->( MsUnlock() )
	    
	    						//gerar contas a pagar
	    						ElseIf GetNewPar("MV_PLRESE1","1") == "0" .and. lAprova//ARRUMA SA2 TBM
	    						
	    							cNat     := GetNewPar("MV_PLSNTRE",'"PLS"')
	    							cNat     := Eval({|| &cNat })
	    							cTipo    := GetNewPar("MV_PLSNCRE","NCC")
	    							cPrefixo := GetNewPar("MV_PLSPFRE",'"RLE"')
	    							cPrefixo := Eval({|| &cPrefixo })
	    							cNumTit  := PLSREMSE2(cPrefixo)
	    							dVencto  := dVenc
	    							cCodCli  := B44->B44_CODCLI
	    							cLoja    := B44->B44_LOJA
	    							cCodInt  := B44->B44_OPEUSR
	    							cCodEmp  := B44->B44_CODEMP
	    							cMatric  := B44->B44_MATRIC
	    							cMesAut  := B44->B44_MESAUT
	    							cNumAut  := B44->B44_NUMAUT
	    							cAnoAut  := B44->B44_ANOAUT	    							
									cBanco   := B44->B44_NROBCO //Numero Banco
									cAgencia := B44->B44_NROAGE //Numero Agencia			
									cConta   := B44->B44_NROCTA //Numero Conta									  
	    							nVlrPag  := B44->B44_VLRPAG

									If B44->(FieldPos("B44_NRODAG")) > 0 .And. B44->(FieldPos("B44_NRODTO")) > 0 
										cDigitAgen := B44->B44_NRODAG //Digito Agencia
	    								cDigitConta := B44->B44_NRODTO //Digito Conta  
									Endif
	    								    							
	    							aCampos :={	{"E2_FILIAL"    ,xFilial("SE2")     ,NIL},;
												{"E2_PREFIXO"	,cPrefixo           ,Nil},;
												{"E2_NUM"		,cNumTit            ,Nil},;
												{"E2_PARCELA"	,Space(Len(SE2->E2_PARCELA))           ,Nil},;
												{"E2_TIPO"		,cTipo              ,Nil},;
												{"E2_FORNECE"	,cCodForn           ,Nil},;
												{"E2_LOJA"		,cLoja              ,Nil},;
												{"E2_NOMFOR"    ,posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ"),Nil},;
												{"E2_EMISSAO"	,dDataBase          ,NIL},;
												{"E2_EMIS1"     ,dDataBase          ,NIL},;
												{"E2_VENCTO"	,dVencto            ,NIL},;
												{"E2_VENCREA"   ,DataValida(dVencto),NIL},;
												{"E2_VENCORI"   ,dVencto            ,NIL},;
												{"E2_MOEDA"     ,01                 ,NIL},;
												{"E2_VALOR"		,nVlrPag			,Nil},;
												{"E2_VLCRUZ"	,nVlrPag            ,Nil},;
												{"E2_SALDO"		,nVlrPag            ,Nil},;
												{"E2_DECRESC"   ,0		            ,NIL},;
												{"E2_ACRESC"    ,0		            ,NIL},;
												{"E2_PLLOTE"    ,cMesAut+cNumAut    ,NIL},;
												{"E2_PLOPELT"   ,cAnoAut            ,NIL},;
												{"E2_CODRDA"    ,""                 ,NIL},;
												{"E2_ANOBASE"   ,cAnoAut            ,NIL},;
												{"E2_MESBASE"   ,cMesAut            ,NIL},;
												{"E2_NATUREZ" 	,cNat				,NIL},;
												{"E2_DESDOBR" 	,"N"				,NIL},;
												{"E2_DIRF" 		,"2"				,NIL},;
												{"E2_HIST" 		,"PAGTO. REEMBOLSO"	,NIL},;
												{"E2_ORIGEM"	,"PLSA090"			,NIL},;
												{"E2_FORBCO" 	,cBanco				,NIL},;
												{"E2_FORAGE" 	,cAgencia			,NIL},;
												{"E2_FAGEDV" 	,cDigitAgen			,NIL},;
												{"E2_FORCTA" 	,cConta				,NIL},;
												{"E2_FCTADV" 	,cDigitConta		,NIL} }

	    						
	    							lMsErroAuto := .F.
	    							MsExecAuto({ | a,b | Fina050(a,b) }, aCampos, 3)
									
	    							If lMsErroAuto
	    								DisarmTransaction()
	    								MostraErro()
	    								lRetorno := .F.
	    							Else
	    								B44->(RecLock('B44',.F.))
	    								B44->B44_PREFIX:= cPrefixo
	    								B44->B44_NUM   := cNumTit
	    								B44->B44_TIPO  := cTipo
	    								B44->B44_PARCEL:= ''
	    								B44->B44_STATUS:= PLSStReemb('2', '2')
	    								B44->B44_DTLBFN:= Date()
									
	    								If !EMPTY(dVenc) 
											B44->B44_DATRMB:= dVenc
										EndIf 
	    								
	    								B44->( MsUnlock() )
	    							
										nTam     := len(allTrim(cPrefixo))
										cPrefixo := allTrim(cPrefixo) + space( tamSX3("E2_PREFIXO")[1] - nTam )

										nTam     := len(allTrim(cNumTit))
										cNumTit  := allTrim(cNumTit) + space( tamSX3("E2_NUM")[1] - nTam )

										nTam     := len(allTrim(cTipo))
										cTipo    := allTrim(cTipo) + space( tamSX3("E2_TIPO")[1] - nTam )

										nTam     := len(allTrim(cCodForn))
										cCodForn := allTrim(cCodForn) + space( tamSX3("E2_FORNECE")[1] - nTam )

										nTam     := len(allTrim(cLoja))
										cLoja    := allTrim(cLoja) + space( tamSX3("E2_LOJA")[1] - nTam )

										BD7->(DbSetOrder(1))//BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC
										If BD7->( msSeek( xFilial("BD7") + B44->(B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI) ) )
		
											while !BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO) == xFilial("BD7") + B44->(B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI)
												
												BD7->(RecLock('BD7',.f.))
													BD7->BD7_CHKSE2 := xFilial("SE2") + '|' + cPrefixo + '|' + cNumTit + '|' + SE2->E2_PARCELA + '|' + cTipo + '|' + cCodForn + '|' + cLoja 
													BD7->BD7_OPELOT := SE2->E2_PLOPELT 
													BD7->BD7_NUMLOT := SE2->E2_PLLOTE 
												BD7->( MsUnlock() )
												
												BD7->(dbSkip())
											endDo    										
										endIf
	    										
	    								If lP001AFim
	    									
											aAreaBOW := BOW->(GetArea())  
											aAreaB1N := B1N->(GetArea()) 
											aAreaB44 := B44->(GetArea()) 
											aAreaB45 := B45->(GetArea()) 
											aAreaB47 := B47->(GetArea()) 
											aAreaSE2 := SE2->(GetArea()) 

											execBlock("P001AFIM",.F.,.F.,{B44->B44_PROTOC})

											RestArea(aAreaBOW) 
											RestArea(aAreaB1N) 
											RestArea(aAreaB44) 
											RestArea(aAreaB45) 
											RestArea(aAreaB47) 
											RestArea(aAreaSE2) 
	    								endIf
	    
	    								lRetorno := .T.
	    							endif
	    						EndIf
	    						
	    						If lRetorno .AND. GetNewPar("MV_PLRESE1","1") # "0,1" .AND. lAprova
	    							// Se estiver gerando o titulo de recurso de glosa, não pode atualiza o numero do titulo no protocolo de reembolso.
	    							// O numero do titulo ficará disponivel no cabecalho da guia de recurso de glosa, tabela B44.
	    							If !lRecursoGlosa
	    								//Atualiza os dados dos títulos no protocolo
	    						        BOW->(DbSetOrder(1))
	    						        BOW->(DbSeek(xFilial("B44")+B44->B44_PROTOC))
	    								BOW->(RecLock('BOW',.F.))
	    								BOW->BOW_PREFIX	:= cPrefixo
	    								BOW->BOW_NUM  	:= cNumTit
	    								BOW->BOW_TIPO  	:= cTipo
										BOW->BOW_VLRREE := B44->B44_VLRPAG 	    								
										BOW->BOW_FORNEC	:= cCodForn
	    								BOW->BOW_STATUS:='6' //6==Enviar financeiro
	    								BOW->BOW_PGMTO:= DTOC(dVenc)
	    								BOW->( MsUnlock() )
	    							Endif
	    							
	    							//Muda fase da GUIA para FATURADA
	    							BD5->(DbSetOrder(1))
	    							If BD5->(MsSeek(xFilial("BD5")+B44->(B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI))) //06-04
	    								BD5->(RecLock('BD5',.F.))
	    								BD5->BD5_FASE := '4'
	    								BD5->( MsUnlock() )
	    								
	    								BD6->(DbSetOrder(1))
	    								BD7->(DbSetOrder(11))
	    								If BD6->(MsSeek(xFilial("BD6")+B44->(B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI)))
	    									While !BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == ;
	    										B44->(B44_FILIAL+B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI) //06-04
	    										
	    										BD6->(RecLock('BD6',.F.))
	    										BD6->BD6_FASE := '4'
	    										BD6->( MsUnlock() )
	    										
	    										If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO)))
	    											While !BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO) == ;
	    												BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO)
	    												
	    												BD7->(RecLock('BD7',.F.))
	    												BD7->BD7_FASE := '4'
	    												BD7->( MsUnlock() )
	    											BD7->(DbSkip())
	    											EndDo
	    										EndIf
	    										
	    									BD6->(DbSkip())
	    									EndDo
	    								EndIf
	    							EndIf
	    				    		
	    							//prepara para envio de email 
	    							If lNotb
	    								BA3->(DbSetOrder(1))
	    								BA3->(MsSeek(xFilial("BA3") + B44->B44_OPEUSR + B44->B44_CODEMP + B44->B44_MATRIC ))
	    								If BA3->BA3_NOTB != "0"//0=Nao e 1=Sim 
	    									PLRMBPRE("B44","B45", BOW->BOW_PROTOC, "6")
	    								EndIf
	    							Else
	    								PLRMBPRE("B44","B45", BOW->BOW_PROTOC, "6")
	    							EndIf		
	    								
	    							//Grava o histórico
	    							cNCC := cPrefixo+cNumTit+cTipTit
	    							P001Status(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT), BOW->BOW_PROTOC)
	    							
	    							AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),;
	    									posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ"), cNCC, B44->B44_PROTOC,"Gerado"})
	    							
	    							PLGRVBOX(BOW->BOW_PROTOC,BOW->BOW_MATRIC,BOW->BOW_STATUS, BOW->BOW_NUMAUT, cNCC,;
	    							dVencto, '', BOW->BOW_CODLDP, BOW->BOW_CODPEG, BOW->BOW_ORIMOV,BOW->BOW_NPROCE )
	    							
	    						EndIf
	    					EndIf
	    				Else
	    					
							If BOW->BOW_STATUS == "6" 

								B44->(RecLock('B44',.F.)) 
								B44->B44_STATUS:= "2"
								B44->( MsUnlock() )
							EndIf  

							cNCC := B44->B44_PREFIX + B44->B44_NUM + B44->B44_TIPO
	    					//Grava os dados no array, que é necessário para ser visualizado apos execução da rotina de aprovação.
	    					AADD(aDadAut, {TransForm(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT),PesqPict("BE1","BE1_NUMAUT")),;
	    						posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ"), cNCC, B44->B44_PROTOC,"Gerado"})
	    					
	    				Endif
	    						
	    		ElseIf nAprov == 2
	    			//Altera o Status do Protocolo
	    			BOW->(DbSetOrder(1))
	    			BOW->(DbSeek(xFilial("B44")+B44->B44_PROTOC))
	    
					BOW->(RecLock('BOW',.F.))
	    			BOW->BOW_STATUS:='7' //7==Não enviar financeiro
	    			BOW->BOW_PGMTO := STR0199 //"Não Autorizado"
	    			BOW->( MsUnlock() )
	    			
	    			B1N->(DbSetOrder(2)) 
	    			B45->(DbSetOrder(1))
	    			 
	    			//Se a não for aprovada, deve negar todos os procedimentos na autorização e no protocolo
	    			If B45->(DbSeek(xFilial("B45") + B44->(B44_OPEMOV + B44_ANOAUT + B44_MESAUT + B44_NUMAUT)))
	    				
	    				While  B45->(B45_OPEMOV + B45_ANOAUT + B45_MESAUT + B45_NUMAUT) == B44->(B44_OPEMOV + B44_ANOAUT + B44_MESAUT + B44_NUMAUT)
	    					
	    					If B45->B45_STATUS == "1"
	    					
				    			B45->(RecLock('B45',.F.))
				    			B45->B45_STATUS := "0"
				    			B45->B45_VLRPAG := 0
				    			//B45->B45_VLRGLO := 0
				    			B45->( MsUnlock() )
				    			
				    			If B1N->(DbSeek(xFilial("B1N") + B44->B44_PROTOC + B45->B45_SEQUEN))
				    			
				    				B1N->(RecLock('B1N',.F.))
					    			B1N->B1N_IMGSTA := "DISABLE"
					    			B1N->( MsUnlock() )
				    			EndIf 
			    			EndIf
			    			
			    			B45->(DbSkip())
	    				EndDo
	    			EndIf 
	    			
	    			PLRMBPRE("B44","B45", BOW->BOW_PROTOC, "7")
	    			
	   				PRMBBXREC(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT), BOW->BOW_PROTOC,.T. ) // Baixa de quantidade no item da Receita Medica 
	    			
	    			//Grava o histórico
	    			PLGRVBOX(BOW->BOW_PROTOC,BOW->BOW_MATRIC,BOW->BOW_STATUS,BOW->BOW_NUMAUT, /*cNumCC*/, /*dDtBaix*/, /*cObs*/, ;
	    					 BOW->BOW_CODLDP, BOW->BOW_CODPEG, BOW->BOW_ORIMOV,BOW->BOW_NPROCE )
	    			
	    			//Atualiza os dados do status
	    			B44->(RecLock('B44',.F.))
	    			B44->B44_STATUS:= '3'
	    			B44->( MsUnlock() )
	    		EndIf
	    
	    		//Altera status do protocolo de acordo com a autorização. 
	    		If B44->B44_STATUS = "1"
	    			
	    			BOW->( RecLock("BOW",.F.) )
	    			BOW->BOW_STATUS := "5"
	    			BOW->( MsUnLock() )
	    			
	    		ElseIf B44->B44_STATUS = "2"
	    			
	    			BOW->( RecLock("BOW",.F.) )
	    			BOW->BOW_STATUS := "6"
	    			BOW->( MsUnLock() )
	    			
	    		ElseIf B44->B44_STATUS = "4"
	    			
	    			BOW->( RecLock("BOW",.F.) )
	    			BOW->BOW_STATUS := "C"
	    			BOW->( MsUnLock() )
	    			
	    		Endif 
	    		End Transaction
			EndIf
		
		
		If !aAuto[1]
			oObj:MarkRec()
		EndIf

    next nI
EndIf

If !aAuto[1]
	//Se mais de uma autorização foi aprovada, mostra tela com todas as aprovações.
	If LEN(aDadAut) > 0	
		objCENFUNLGP:useLogUser()	
		AutReemb(aDadAut)	
	ElseIf nAut == 1
		MsgAlert(STR0197) //"Esta Guia ja está faturada ou com título gerado."				
	ElseIf nAut > 1
		MsgAlert(STR0198) //"Todas as Guias selecionadas estão faturadas ou com título gerado."
	EndIf
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ APROVFIN   ³ Autor ³ Everton M. Fernandes³ Data ³ 20.04.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibir dados da autorizacao/liberacao efetuada             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function APROVFIN(cNomUser, cNCC, cDescri)

LOCAL oDlg
LOCAL oFontNum
LOCAL oFontAutor
LOCAL oFontTit
LOCAL oSay

LOCAL oBot01

DEFAULT cDescri := STR0053 //"Dados do reembolso "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fontes utilizadas somente nesta funcao...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFontNum NAME "Arial" SIZE 000,-016 BOLD
DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-019 BOLD
DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra Resumo da Autorizacao...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cDescri FROM 009,000 TO 018,060 OF GetWndDefault()

oBot01 := SButton():New(048, 005, 1, {|| oDlg:End() },,.T.)
oBot01:cToolTip := STR0055 //"Fechar Tela"

@ 007,005 SAY oSay PROMPT STR0058  SIZE 220,010 OF oDlg PIXEL //"Usuario
@ 006,045 MSGET cNomUser           SIZE 185,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 027,005 SAY oSay PROMPT STR0142 SIZE 220,010 OF oDlg PIXEL //"Título Gerado"
@ 027,045 MSGET cNCC              SIZE 185,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

ACTIVATE MSDIALOG oDlg CENTERED

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PL001ALeg  ³ Autor ³Everton M. Fernandes.³ Data ³ 20.02.13 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe a legenda...                                         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL001ALeg()


BrwLegenda(STR0160,STR0161 ,aCdCores) //"Protocolo de Reembolso"###"Status"


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSB45NF   ³ Autor ³Everton M. Fernandes.³ Data ³ 20.02.13 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Valida o numero da NF digitado                             ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSB45NF()
Local lRet 	:= .T.

DbSelectArea("B45")
B45->(DbSetOrder(3))
If B45->(FieldPos("B45_NF"))>0
	
	If !Empty(M->B45_NF)
		//Valida banco
		lRet := B45->(DbSeek(xFilial("B45") + M->B45_CPFCGC + M->B45_NF))
	Else
		lRet := .T.
	EndIf
	
	If lRet
		MsgAlert(STR0162)//"Já existe uma NF cadastrada com este número e CNPJ"
	EndIf
EndIf

Return !lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSB44PR   ³ Autor ³Everton M. Fernandes.³ Data ³ 20.02.13 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Valida o numero da NF digitado                             ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSB44PR()
Local lRet 	:= .T.

If B44->(FieldPos("B44_PROTOC")) > 0
	lRet := Vazio(M->B44_PROTOC) .or. funname() == "TMKA271"
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA001SEQ³ Autor ³ Daher		            ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria Sequencia											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS001ASEQ()

LOCAL cRet
If ValType(oBrwPro) == "O"
	cRet := PLSINCRE("B1N_SEQUEN",oBrwPro)
Else
	cRet := PLSINCRE("B1N_SEQUEN")
Endif

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlsGrvIte³ Autor ³ Thiago		            ³ Data ³ 13.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PlsGrvIte(nOpc, aColsIte, aHeadIte, aColsCompo, aHeadCompo)
Local aArea 	:= getArea()
Local aDadBD6		:= {}
Local nFor		:= 0
Local lAchou	:= .F.
Local lCodTrocado   := .F.
LOCAL nLen		:= Len(aColsIte)
LOCAL nHeader := Len(aHeadIte)
LOCAL nAcols	:= 0
LOCAL nLenComp		:= Len(aColsCompo)
LOCAL nHeadComp := Len(aHeadCompo)
Local cProtoc:=""
Local nB7MCodI	:=0
Local nB7MLanc	:=0

Local nB1NPAD 	:= 0
Local nB1NPRO 	:= 0
Local nB1NQTD 	:= 0
Local nB1NVLAP 	:= 0
Local nB1NSIGL 	:= 0
Local nB1NESTS 	:= 0
Local nB1NREGS 	:= 0
Local nB1NDTPR 	 := 0
Local nB1NDESPR := 0
Local aDadAllInc := {}
Local aDadAllExc := {}
Local aDadAllAlt := {}
Local lPlGrvBin  := ExistBlock("PLGRVBIN")

//Pegar valores do código do procedimento / tabela / valor e outros para atualizar BD6
nB1NPAD 	:= aScan(aHeadIte, {| aVet | AllTrim(aVet[2]) == "B1N_CODPAD"})
nB1NPRO 	:= aScan(aHeadIte, {| aVet | AllTrim(aVet[2]) == "B1N_CODPRO"})
nB1NQTD 	:= aScan(aHeadIte, {| aVet | AllTrim(aVet[2]) == "B1N_QTDPRO"})
nB1NVLAP 	:= aScan(aHeadIte, {| aVet | AllTrim(aVet[2]) == "B1N_VLRAPR"})
nB1NSIGL 	:= aScan(aHeadIte, {| aVet | AllTrim(aVet[2]) == "B1N_SIGLA"})
nB1NESTS 	:= aScan(aHeadIte, {| aVet | AllTrim(aVet[2]) == "B1N_ESTSOL"})
nB1NREGS 	:= aScan(aHeadIte, {| aVet | AllTrim(aVet[2]) == "B1N_REGSOL"})
nB1NDTPR 	:= aScan(aHeadIte, {| aVet | AllTrim(aVet[2]) == "B1N_DATPRO"})

nB1NDESPR 	:= aScan(aHeadIte, {| aVet | AllTrim(aVet[2]) == "B1N_DESPRO"})

nB1NItem   := aScan(aHeadIte, {| aVet | AllTrim(aVet[2]) == "B1N_SEQUEN"})
nB7MItem   := aScan(aHeadCompo, {| aVet | AllTrim(aVet[2]) == "B7M_SEQUEN"})
nB7MCodI   := aScan(aHeadCompo, {| aVet | AllTrim(aVet[2]) == "B7M_CODUNM"})
nB7MLanc   := aScan(aHeadCompo, {| aVet | AllTrim(aVet[2]) == "B7M_NLANC"})

For nFor :=1 To nLen

	lCodTrocado := .F.
	B1N->(DbSetOrder(2))
	lAchou := B1N->(MsSeek(xFilial("B1N") + M->BOW_PROTOC + aColsIte[nFor, nB1NItem] ))
	If aColsIte[nFor, nHeader +1 ]== .T.  .OR. nOpc == K_Excluir // Se a linha esta deletada na get e achou o kra no banco
		If lAchou .And. (nOpc == K_Alterar  .OR. nOpc == K_Excluir)
			RecLock("B1N", .F., .F. )
			DbDelete()
			MsUnlock()
			WriteSx2("B1N")

			BD5->(DbSetOrder(17))  //Filial + ANOAUT, MESAUT, NUMAUT
			If ( BD5->(DbSeek(xFilial("BD5") + BOW->(BOW_OPEMOV+BOW_ANOAUT+BOW_MESAUT+BOW_NUMAUT))) )
				aDadBD6 := {} //Zerando array
				//Incluir na Matriz os campos para atualização na BD6
				aAdd(aDadBD6, {"BD6_CODPRO", aColsIte[nFor, nB1NPRO]})
				aAdd(aDadBD6, {"BD6_CODPAD", aColsIte[nFor, nB1NPAD]})
				aAdd(aDadAllExc, aDadBD6) //Adicionando operação e array com campos (Aqui será inclusão e Alteração)
			endif
		EndIf
	Else

		//Se achou a posição mas o código do procedimento esta diferente, excluí e incluí novamente (Houve troca de procedimento).
		if lAchou = .T. .and. (alltrim(B1N->B1N_CODPAD) <> alltrim(aColsIte[nFor, nB1NPAD]) .or. ; 
		                       alltrim(B1N->B1N_CODPRO) <> alltrim(aColsIte[nFor, nB1NPRO])) 
			//Incluir na Matriz os campos para atualização na BD6
			aAdd(aDadBD6, {"BD6_CODPRO", /*aColsIte[nFor, nB1NPRO]*/B1N->B1N_CODPRO})
			aAdd(aDadBD6, {"BD6_CODPAD", /*aColsIte[nFor, nB1NPAD]*/B1N->B1N_CODPAD})
			aAdd(aDadAllExc, aDadBD6) //Adicionando operação e array com campos (Aqui será inclusão e Alteração)
			lCodTrocado := .T.				
		endif	
		
		If !EMPTY(M->BOW_MUNATE)
			For nAcols := 1 To nLen
				aColsIte[nAcols][GdFieldPos("B1N_EST",aHeadIte)] 	 := M->BOW_UFATE
				aColsIte[nAcols][GdFieldPos("B1N_CODMUN",aHeadIte)] := M->BOW_MUNATE
				aColsIte[nAcols][GdFieldPos("B1N_DESMUN",aHeadIte)] := M->BOW_DESMUN
			Next
		EndIf
		
		RecLock("B1N", !lAchou )
		HS_GRVCPO("B1N", aColsIte, aHeadIte, nFor)
		B1N->B1N_FILIAL := xFilial("B1N")
		B1N->B1N_PROTOC := M->BOW_PROTOC
		cProtoc:=B1N->B1N_PROTOC
		MsUnlock()
		
				//Alterar BD6 com os novos valores
		BD5->(DbSetOrder(17))  //Filial + ANOAUT, MESAUT, NUMAUT
		If ( BD5->(DbSeek(xFilial("BD5") + BOW->(BOW_OPEMOV+BOW_ANOAUT+BOW_MESAUT+BOW_NUMAUT))) )
		
			aDadBD6 := {} //Zerando array
			//Incluir na Matriz os campos para atualização na BD6
			aAdd(aDadBD6, {"BD6_CODPRO", aColsIte[nFor, nB1NPRO]})
			aAdd(aDadBD6, {"BD6_CODPAD", aColsIte[nFor, nB1NPAD]})
			aAdd(aDadBD6, {"BD6_DATPRO", aColsIte[nFor, nB1NDTPR]})
			aAdd(aDadBD6, {"BD6_QTDSOL", aColsIte[nFor, nB1NQTD]})
			aAdd(aDadBD6, {"BD6_QTDPRO", aColsIte[nFor, nB1NQTD]})
			aAdd(aDadBD6, {"BD6_VLRAPR", aColsIte[nFor, nB1NVLAP]})
			aAdd(aDadBD6, {"BD6_SIGEXE", aColsIte[nFor, nB1NSIGL]})
			aAdd(aDadBD6, {"BD6_ESTEXE", aColsIte[nFor, nB1NESTS]})
			aAdd(aDadBD6, {"BD6_REGEXE", aColsIte[nFor, nB1NREGS]})
			aAdd(aDadBD6, {"BD6_SEQUEN", aColsIte[nFor, nB1NItem]})
			aAdd(aDadBD6, {"BD6_DESPRO", aColsIte[nFor, nB1NDESPR]})
			
			if lAchou .and. lCodTrocado = .F.
				aAdd(aDadAllAlt , aDadBD6)
			else
				aAdd(aDadAllInc , aDadBD6)
			endif
			
			//aAdd(aDadAll, {iif(lAchou, "A", "I"), aDadBD6}) //Adicionando operação e array com campos (Aqui será inclusão e Alteração)
			
		EndIf			
		
		//Ponto de Entrada para poossibilitar customizações na gravação dos itens
		//do Protocolo de Reembolso.
		If lPlGrvBin
						
			aAreaBOW := BOW->(GetArea())  
			aAreaB1N := B1N->(GetArea()) 

			ExecBlock("PLGRVBIN",.F.,.F.,{BIN->(Recno())})
						
			RestArea(aAreaBOW) 
			RestArea(aAreaB1N) 
		Endif
		
	EndIf
Next
For nFor :=1 To nLenComp
	B7M->(DbSetOrder(1))
	lAchou := B7M->(MsSeek(xFilial("B7M") + M->BOW_PROTOC + aColsCompo[nFor, nB7MItem]+ aColsCompo[nFor, nB7MCodI]+ aColsCompo[nFor, nB7MLanc] ))
	If aColsCompo[nFor, nHeadComp +1 ]== .T.  .OR. nOpc == K_Excluir // Se a linha esta deletada na get e achou o kra no banco
		If lAchou .And. (nOpc == K_Alterar  .OR. nOpc == K_Excluir)
			RecLock("B7M", .F., .F. )
			DbDelete()
			MsUnlock()
			WriteSx2("B7M")
		EndIf
	Else
		
		RecLock("B7M", !lAchou )
		HS_GRVCPO("B7M", aColsCompo, aHeadCompo, nFor)
		B7M->B7M_FILIAL := xFilial("B7M")
		B7M->B7M_PROTOC := cProtoc
		MsUnlock()
		
	EndIf
Next

AtuBD6Alt(aDadAllInc, aDadAllExc, aDadAllAlt)

RestArea(aArea)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AtuBD6Alt³ Autor ³ Roberto Arruda         ³ Data ³ 24.12.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Verifica se é inclusão ou alteração.    	  			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

function AtuBD6Alt(aDadAllInc, aDadAllExc, aDadAllAlt)

	Local objGuia	 := nil
	Local oObjVOGuia := nil
	Local aObjProcedimentos := nil
	
	Local aItens	 := {}
	Local aRetGui	 := {}
	Local nFor
	
	Local cSeqMov
	Local cCodPro
	Local cCodPad
	Local cQtd
	Local cQtdAut 	  	 
	Local cVlrApr
	
	objGuia := CO_Guia():New()
	
	//Array de Inclusões
	if Len(aDadAllInc)> 0
	
		for nFor := 1 to Len(aDadAllInc)
		
			cSeqMov := PLSRETDAD( aDadAllInc[nFor],"BD6_SEQUEN","" )
			cCodPro := PLSRETDAD( aDadAllInc[nFor],"BD6_CODPRO","" )
			cCodPad := PLSRETDAD( aDadAllInc[nFor],"BD6_CODPAD","" )
			cQtd 	:= PLSRETDAD( aDadAllInc[nFor],"BD6_QTDSOL","" )
			cQtdAut := PLSRETDAD( aDadAllInc[nFor],"BD6_QTDPRO","" )
			cVlrApr := PLSRETDAD( aDadAllInc[nFor],"BD6_VLRAPR","" )
			
			aadd( aItens, {{ "SEQMOV", cSeqMov },;
			 			   { "CODPRO", cCodPro },;
						   { "CODPAD", cCodPad },;
						   { "QTD"   , cQtd },;
						   { "QTDAUT", cQtdAut },;
						   { "VLRAPR", cVlrApr },;
						   { "RESAUT", "" },;
						   { "INDCLIEVO","" },;
						   { "DENTE" , "" },;
						   { "FACE"  , "" },;
						   { "HORINI", "" },;
						   { "HORFIM", "" },;
						   { "VIAAC",  "" },;
						   { "TECUT",  "" },;
						   { "REDAC",  "" },;
						   { "ATPPAR", {} },;
						   { "STPROC", "" } ,;
						   { "SLVPRO", "" } ,;
						   { "SLVPAD", "" } ,;
						   { "STPROC", "" } ,;
						   { "DIAGNO", "" },; 
						   { "DATPRO", "" } } )			
			
		next
		
		oObjVOGuia := objGuia:loadGuiaRecno(BD5->(Recno()), .F., .F.)
		aObjProcedimentos:= objGuia:getLstProcedimentos(oObjVOGuia:getDadBenef():getMatric(), aItens, oObjVOGuia)
		
		aRetGui := objGuia:incIteGuia(oObjVOGuia, aObjProcedimentos, .F.)
		freeObj(oObjVOGuia)
		//lSaveOk := aRetGui[1]
	endif
	
	//Array de Exclusões
	if Len(aDadAllExc)> 0
		for nFor := 1 to Len(aDadAllExc)
		
			cCodPro := PLSRETDAD( aDadAllExc[nFor],"BD6_CODPRO","" )
			cCodPad := PLSRETDAD( aDadAllExc[nFor],"BD6_CODPAD","" )
			
			objGuia:excIteGuia(cCodPad,cCodPro, STR(BD5->(Recno())))
		next
		
	endif	
	
	//Array de Exclusões
	if Len(aDadAllAlt)> 0
		for nFor := 1 to Len(aDadAllAlt)
		
			//Utilizo o AltGuia para atualizar os dados da BD6 com os novos valores, caso seja trocado tabela ou procedimento. Se não fizer isso, vai constar no
			//array o novo valor, enquanto que está gravado na BD6 o antigo, não possibilitando encontrar o registro.
			//objGuia:altGuia({},aDadAllAlt[nFor], STR(BD5->(Recno())))
			
			//Aqui atualizo os campos e gero a nova participação do procedimento escolhido, deletando as antigas.
			objGuia:altItem(aDadAllAlt[nFor], STR(BD5->(Recno())))
		next
		
	endif	
	
	freeObj(objGuia)
	oObjGui 		  := nil
	oObjVOGuia 		  := nil
	aObjProcedimentos := nil
return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlVldB1N³ Autor ³ Tabosa	               ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Validação dos campos da tabela de itens do protocolo	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlVldB1N()
Local cCpo    := ReadVar()
Local lRet 	:= .T.
Local aRetInt	:={}

If "B1N_CODPAD" $ cCpo
	
	If (lRet := Vazio() .OR. BR4->(ExistCpo('BR4',M->B1N_CODPAD,1)))
		cCodTab := &(cCpo)
	EndIf
	
ElseIf "B1N_CODPRO" $ cCpo
	
	If (lRet := Vazio() .OR. BR8->(ExistCpo('BR8',M->B1N_CODPAD+M->B1N_CODPRO,1)))
		M->B1N_DESPRO := ALLTRIM(Posicione("BR8",1,xFilial("BR8")+M->B1N_CODPAD+M->B1N_CODPRO,"BR8_DESCRI"))
	Endif
	
EndIf

oBrwPro:aCols[oBrwPro:oBrowse:nAt][GDFieldPos('B1N_IMGSTA', oBrwPro:aHeader)] := 'ENABLE'  

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³P001AEXCG³ Autor ³ Tabosa	               ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Excluir protocolo e itens Generico    						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function P001AEXCG(cProtoc)
Local aArea 	:= getArea()
Local cOpeProt := PLSINTPAD()

BOW->(DbSetOrder(1))
If BOW->(MsSeek(xFilial("BOW") + cProtoc ))
	If AllTrim(BOW->BOW_NUMAUT) == ""
		
		// *#% Exclui Historico %#*
		DbSelectArea("BOX")
		BOX->(DbSetOrder(1))
		
		If BOX->(DbSeek(xFilial("BOX") + cOpeProt + BOW->BOW_PROTOC))
			While !BOX->(Eof()) .And. BOX->(BOX_FILIAL+BOX_CODOPE+BOX_PROTOC) == ;
				BOW->(BOW_FILIAL+BOW_OPEMOV+BOW_PROTOC)
				BOX->(RecLock('BOX',.F.))
				BOX->(DbDelete())
				BOX->(DbSkip())
				BOX->( MsUnlock() )
			EndDo
		EndIf
		// *#% Exclui itens Reemb Benef %#*
		DbSelectArea("B1N")
		B1N->(DbSetOrder(1))
		
		If B1N->(DbSeek(xFilial("B1N") + BOW->BOW_PROTOC))
			While !B1N->(Eof()) .And. B1N->(B1N_FILIAL+B1N_PROTOC) == ;
				BOW->(BOW_FILIAL+BOW_PROTOC)
				B1N->(RecLock('B1N',.F.))
				B1N->(DbDelete())
				B1N->(DbSkip())
				B1N->( MsUnlock() )
			EndDo
		EndIf
		
		DbSelectArea("B7M")
		B7M->(DbSetOrder(1))
		
		If B7M->(DbSeek(xFilial("B7M") + BOW->BOW_PROTOC))
			While !B7M->(Eof()) .And. B7M->(B7M_FILIAL+B7M_PROTOC) == ;
				BOW->(BOW_FILIAL+BOW_PROTOC)
				B7M->(RecLock('B7M',.F.))
				B7M->(DbDelete())
				B7M->(DbSkip())
				B7M->( MsUnlock() )
			EndDo
		EndIf
		
		BOW->(RecLock('BOW',.F.))
		BOW->(DbDelete())
		BOW->( MsUnlock() )
	EndIf
EndIf
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PRetRecMed³ Autor ³ Tabosa	               ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o sequencial ou a unidade da receita medica cadastrada
valida   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PRetRecMed(cBenef, cCodPad, cCodPro)
LOCAL cSeqRec := ""
LOCAL aArea 	:= getArea()

B7D->(DbSetOrder(2))
If B7D->(MsSeek(xFilial("B7D") +cBenef+cCodPad+cCodPro ))
	While !B7D->(Eof()) .AND. B7D->(B7D_FILIAL+B7D_BENEFI+B7D_CODPAD+B7D_CODMED) == xFilial("B7D")+cBenef+ cCodPad+ cCodPro
		
		Return(B7D->B7D_UNICON)
		B7D->(DbSkip())
	EndDo
EndIf
RestArea(aArea)
Return(cSeqRec)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PRMBBXREC³ Autor ³ Tabosa	              ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Baixa na quantidade autorizada da receita medica           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PRMBBXREC(cChave, cProtoc, lRetSaldo) 
LOCAL aArea 	:= getArea()
LOCAL nQtdG	:= 0

DEFAULT lRetSaldo := .F.

If !EMPTY(cProtoc)
	
	B45->(dbSetorder(1))
	If B45->( dbSeek(xFilial("B45")+cChave ) )
	
		While !B45->(Eof()) .AND. B45->(B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT) == xFilial("B45") +  cChave
	
			If !Empty(B45->B45_SEQB1N) .AND. B45->B45_STATUS == "1"
	
				B1N->(DbSetOrder(2))
				If B1N->(MsSeek(xFilial("B1N") + cProtoc+B45->B45_SEQB1N)) .AND. !Empty(B1N->B1N_SEQMED)
	
					nQtdG := B1N->B1N_QTDMED
					B7D->(DbSetOrder(3))
	
					If B7D->(MsSeek(xFilial("B7D") + B1N->( B1N_CODREC + B1N_CODMED )))
						
						RecLock("B7D",.F.)
						
						If lRetSaldo
							B7D->B7D_QTDEXE -= B1N->B1N_QTDMED
						Else
							B7D->B7D_QTDEXE += nQtdG
						EndIf
						
						MsUnlock()
					EndIf
				EndIf
			EndIF

			B45->(DbSkip())
		EndDo
	EndIf
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSGERAUT³ Autor ³ Thiago Guilherme       ³ Data ³ 06.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria guia de autorizacao de reembolso a partir da guia de
protocolo de reembolso									        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSGERAUT(lVerAut) 

local aDataRee := {}
local dDtPag
local lEntrou := .F.
local cSemProtoc := ""
local cChave     := ""

DEFAULT lVerAut := .F.

BX4->(DbSetOrder(1)) 
cChave := xFilial("BX4") + RETCODUSR() + PLSINTPAD()

If BX4->(DbSeek(cChave))
	
	If BX4->BX4_APREEM == "0" .OR. EMPTY(BX4->BX4_APREEM) //1 == Possui permissão; 0 == Não possui permissão 
		
		If lVerAut
		
			MsgAlert(STR0316, STR0049) //"O seu usuário não possui permissão para gerar a autorização de reembolso","Atenção" 
		EndIf

		return
	Endif
Endif 

cSemProtoc := BOW->(BOW_FILIAL+BOW_PROTOC)

nHReemb   := PLSAbreSem(cSemProtoc+".SMF",.F.)
If nHReemb == 0
      MsgAlert("Autorização de reembolso em processo de geração por outro usuário")
      Return()
EndIf

If BOW->BOW_STATUS $ "3,C"
	B44->(DbSetOrder(4))	
	// Esse item se faz necessario devido ao itens que são gerados reembolso e no meio da rotina caia 
	//o sistema, e nao mudava status e o sistema gerava em duplicidade
	If B44->(MsSeek(xFilial("B44")+BOW->BOW_PROTOC)) 
		If B44->B44_STATUS = "1"
		
			BOW->( RecLock("BOW",.F.) )
			BOW->BOW_STATUS := "5"
			BOW->( MsUnLock() )	
		
		ElseIf B44->B44_STATUS = "2"
		
			BOW->( RecLock("BOW",.F.) )
			BOW->BOW_STATUS := "6"
			BOW->( MsUnLock() )	
		ElseIf B44->B44_STATUS = "3"
		
			BOW->( RecLock("BOW",.F.) )
			BOW->BOW_STATUS := "7"
			BOW->( MsUnLock() )		
		ElseIf B44->B44_STATUS = "4"
		
			BOW->( RecLock("BOW",.F.) )
			BOW->BOW_STATUS := "C"
			BOW->( MsUnLock() )			
		
		Endif
	Else
		If PLSVRCMR(BOW->BOW_PROTOC) 
				
			PL001MOV("BOW",Recno(),9,,,,,,,)
			
			// ATUALIZAR O CODIGO DA PEG ESSE ITE, FOI ADICIONADO AQUI DEVIDO QUE A ATUALZIAÇÃO DO BOW A B44 NÃO FOI ATUALIZADA COM O CODIGO DA PEG
			BOW->( RecLock("BOW",.F.) )
			BOW->BOW_CODPEG	:= B44->B44_CODPEG
			BOW->BOW_NUMAUT	:= B44->B44_NUMAUT
			BOW->( MsUnLock() )			
			
			lEntrou := .T.
		EndIf 
	Endif	
ElseIf  BOW->BOW_STATUS == "5" 
	
	BOW->( RecLock("BOW",.F.) )
	BOW->BOW_CODPEG	:= B44->B44_CODPEG
	BOW->BOW_NUMAUT	:= B44->B44_NUMAUT
	BOW->BOW_NUMGUI	:= B44->B44_NUMGUI
	BOW->BOW_CODLDP	:= B44->B44_CODLDP
	BOW->BOW_PREFIX := B44->B44_PREFIX
	BOW->BOW_NUM    := B44->B44_NUM
	BOW->BOW_PARCEL := B44->B44_PARCEL
	BOW->BOW_TIPO   := B44->B44_TIPO
	BOW->( MsUnLock() )	
EndIf 

PLSFechaSem(nHReemb,cSemProtoc+".SMF")

Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSEXITRE³ Autor ³ Thiago Guilherme       ³ Data ³ 06.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ So permite exclusao do item depois de confirmação	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function  PLSEXITRE(lRetArray)
LOCAL oDlg
LOCAL cMotivo 		:= Space(TamSX3("B14_MOTIVO")[1])
LOCAL cMsg 			:= STR0202//"O motivo deve conter mais de 5 caracteres."
LOCAL aButtons 		:= {}
LOCAL nOpca    		:= 0
LOCAL bOK      		:= { || IF(!Empty(cMotivo) .AND. LEN(cMotivo) > 5 ,(nOpca := 1, oDlg:End()),(alert(cMsg))) }
LOCAL bCancel  		:= { || nOpca := 0, oDlg:End() }
LOCAL lMarkGlosa	:= GetNewPar("MV_PLMKGLO",.F.) // Caso Ativado irá exibir a tela de glosa de todos os itens do reembolso
LOCAL lNaoPrimeiro 	:= .F.
LOCAL lDelBusca		:= .F.
LOCAL lDelBusca2	:= .F.
LOCAL nN 			:= 1
LOCAL nAtBkp 		:= 1
LOCAL aretMrkBr		:= {}
LOCAL aaltMrk 		:= {}
LOCAL aDelAux		:= {}
DEFAULT lRetArray := .F.

//Desativa o atalho de teclado para não permitir abrir a rotina varias vezes enquanto ela esta aberta
SET KEY VK_F9 TO //16-02

If  M->BOW_STATUS $ "0,1,2"
	If lRetArray
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define dialogo...                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlg TITLE STR0204 FROM 009,000 TO 018,100 OF GetWndDefault() //"Digite o motivo da rejeição do procedimento"
			
		@ 036,005 Get cMotivo SIZE 380,15 OF oDlg PIXEL 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ativa o dialogo...                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso seja confirmado atualiza ne enchoice nos respectivos campos    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpca == K_OK
			aDelItens := {}
			AADD(aDelItens, {cMotivo,.T.} )
			
		Else
			Return .F.
		Endif
	Else
		If oBrwPro:acols[oBrwPro:obrowse:nAt][1] != "DISABLE"
			If !lMarkGlosa // Tela de glosa antiga
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Define dialogo...                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				DEFINE MSDIALOG oDlg TITLE STR0204 FROM 009,000 TO 018,100 OF GetWndDefault() //"Digite o motivo da rejeição do procedimento"
				
				@ 036,005 Get cMotivo SIZE 380,15 OF oDlg PIXEL 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ativa o dialogo...                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons)
			Else
			
				If !(emptY(aDelItens))
					lNaoPrimeiro := .T.
					If MsgYesNo("Há glosas não confirmadas anteriores, prosseguir irá desfazer as mesmas, deseja prosseguir?")
						aDelAux	  := aClone(aDelItens)
						aDelItens := {}
					else
						return .T.
					endIf
				endIf

				aretMrkBr := Tela001GLI()			

				nOpca   := aretMrkBr[1]
				aaltMrk := aclone(aretMrkBr[2])

			Endif	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso seja confirmado atualiza ne enchoice nos respectivos campos    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpca == K_OK
				If !lMarkGlosa // Tela de glosa antiga
			
					AADD(aDelItens, {cMotivo,oBrwPro:acols[oBrwPro:obrowse:nAt][GdFieldPos("B1N_CODPRO",oBrwPro:aHeader)],; 
											oBrwPro:acols[oBrwPro:obrowse:nAt][GdFieldPos("B1N_MATRIC",oBrwPro:aHeader)],;
											oBrwPro:acols[oBrwPro:obrowse:nAt][GdFieldPos("B1N_SEQUEN",oBrwPro:aHeader)];
									}) 

					oBrwPro:acols[oBrwPro:obrowse:nAt][1] 	:= "DISABLE"
				Else

					nAtBkp := oBrwPro:obrowse:nAt

					For nN := 1 To Len(aaltMrk)
						AADD(aDelItens, {aaltMrk[nN][4],aaltMrk[nN][1],;
														aaltMrk[nN][2],;
														aaltMrk[nN][3] })
					next

					For nN := 1 To Len(oBrwPro:acols)
					
						lDelBusca	:= Iif(Len(aDelItens) > 0, Ascan(aDelItens,{|x| x[2] + x[3] + x[4] == oBrwPro:acols[nN][GdFieldPos("B1N_CODPRO",oBrwPro:aheader)] + oBrwPro:acols[nN][GdFieldPos("B1N_MATRIC",oBrwPro:aheader)] + oBrwPro:acols[nN][GdFieldPos("B1N_SEQUEN",oBrwPro:aheader)] }) > 0, .F.)
						lDelBusca2	:= Iif(Len(aDelAux) > 0, Ascan(aDelAux,{|x| x[2] + x[3] + x[4] == oBrwPro:acols[nN][GdFieldPos("B1N_CODPRO",oBrwPro:aheader)] + oBrwPro:acols[nN][GdFieldPos("B1N_MATRIC",oBrwPro:aheader)] + oBrwPro:acols[nN][GdFieldPos("B1N_SEQUEN",oBrwPro:aheader)] }) > 0, .F.)
						If lNaoPrimeiro .And. (lDelBusca .Or. lDelBusca2) //volta todos os procedimentos que foram alterados no momento da alteração da tela
							
							oBrwPro:acols[nN][1] 	:= "ENABLE"
						endIf

						If Ascan(aDelItens,{|x| x[2] + x[3] + x[4] == oBrwPro:acols[nN][GdFieldPos("B1N_CODPRO",oBrwPro:aheader)] +;
																			oBrwPro:acols[nN][GdFieldPos("B1N_MATRIC",oBrwPro:aheader)] +;
																			oBrwPro:acols[nN][GdFieldPos("B1N_SEQUEN",oBrwPro:aheader)] }) > 0

							oBrwPro:acols[nN][1] 	:= "DISABLE"

						endIf
					Next

				Endif

				oBrwPro:Refresh()

			EndIf
		Else
			If !lMarkGlosa // Tela de glosa antiga
				oBrwPro:acols[oBrwPro:obrowse:nAt][1] 	:= "ENABLE"
				oBrwPro:Refresh()
			Else
				If MsgYesNo("Deseja desfazer todas as glosas? Caso escolha [Não], somente a glosa do item posicionado será retirada")
					For nN := 1 To Len(oBrwPro:acols)
						oBrwPro:acols[nN][1] 	:= "ENABLE"
					next
					oBrwPro:Refresh()
				Else
					oBrwPro:acols[oBrwPro:obrowse:nAt][1] 	:= "ENABLE"
					oBrwPro:Refresh()
				EndIf
			Endif	
		Endif
	EndIf
	
	If lRetArray
		Return aDelItens
	EndIf
Else
	MsgAlert(STR0311,STR0049) //"O status do protocolo não permite glosar o item."##Atenção
EndIf

//reativa a tecla de atalho
SetKey(VK_F9,  {|| PLSEXITRE()}) // Glosar itens 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VisMotExc³ Autor ³ Thiago Guilherme       ³ Data ³ 06.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ retorna o motivos da exclusao do item do reembolso	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VisMotExc()

LOCAL oDlg
LOCAL cMotivo
LOCAL oMemo
LOCAL bCancel  := { || nOpca := 0, oDlg:End() }
LOCAL bOK      := { || nOpca := 1, oDlg:End() }
LOCAL cCodPro  := oBrwPro:acols[oBrwPro:obrowse:nAt][GdFieldPos("B1N_CODPRO",oBrwPro:aheader)]
LOCAL cMatric  := oBrwPro:acols[oBrwPro:obrowse:nAt][GdFieldPos("B1N_MATRIC",oBrwPro:aheader)]
LOCAL cSquen   := oBrwPro:acols[oBrwPro:obrowse:nAt][GdFieldPos("B1N_SEQUEN",oBrwPro:aheader)]
LOCAL cObs     := "" 

//Desativa o atalho de teclado para não permitir abrir a rotina varias vezes enquanto ela esta aberta
SET KEY VK_F10 TO //16-02

If oBrwPro:acols[oBrwPro:obrowse:nAt][1] == "DISABLE"

	B14->(dbSetOrder(1)) 
	
	If B14->(MsSeek(xFilial("B14") + BOW->BOW_PROTOC + cCodPro + cMatric + cSquen)) 
		cObs := B14->B14_MOTIVO

	ElseIf B14->(MsSeek(xFilial("B14") + BOW->BOW_PROTOC + cCodPro)) 
		cObs := B14->B14_MOTIVO
	Else
		Help("",1,"PLB1N002")
		RETURN
	EndIf

	DEFINE MSDIALOG oDlg TITLE STR0205 FROM 009,000 TO 025,055 OF GetWndDefault() //"Motivo de Glosa"
	
	@ 035,005 Get oMemo VAR cObs Memo SIZE 190,053 OF oDlg PIXEL NO BORDER
	oMemo:lReadOnly := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa o dialogo...                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.)
ELse
	Help("",1,"PLB1N001")
EndIf

//reativa a tecla de atalho
SetKey(VK_F10, {|| VisMotExc()}) // Mot. Glosa  

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSMTPROT³ Autor ³ Thiago Guilherme       ³ Data ³ 06.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Motivo de reembolso reprovado					               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSMTPROT()
LOCAL oDlg
LOCAL cMotivo
LOCAL oMemo
LOCAL cMsg := STR0202//"O motivo deve conter mais de 5 caracteres."
LOCAL aButtons := {}
LOCAL nOpca    := 0
LOCAL bOK      := { || IF(!Empty(cMotivo) .AND. LEN(cMotivo) > 5 ,(nOpca := 1, oDlg:End()),(alert(cMsg))) }
LOCAL bCancel  := { || nOpca := 0, oDlg:End() }
LOCAL cSequen
Local aSizeDlg := {}
Local nVersao := Val(GetVersao(.F.))

If (nVersao >= 12)
	aadd(aSizeDlg, 022) //Linha Final Dialog
	aadd(aSizeDlg, 035) //Linha Inicial Memo
Else
	aadd(aSizeDlg, 019) //Linha Final Dialog
	aadd(aSizeDlg, 005) //Linha Inicial Memo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0206 FROM 009,000 TO aSizeDlg[1],050 OF GetWndDefault() //"Digite o motivo"

@ aSizeDlg[2],005 Get oMemo VAR cMotivo Memo SIZE 190,050 OF oDlg PIXEL NO BORDER
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso seja confirmado atualiza ne enchoice nos respectivos campos    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
	
	If LEN(cMotivo) > 5
		
		BOW->( RecLock("BOW",.F.) )
		BOW->BOW_MOTIND := cMotivo
		BOW->( MsUnLock() )
	Else
		Return .F.
	EndIf
Else
	Return .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSTIPDOC³ Autor ³ Thiago Guilherme       ³ Data ³ 06.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ retorna o Tipo de documento para o reembolso	               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSTIPDOC()

LOCAL cDescTipo := ""

dbSelectArea("BBS")

BBS->( dbGoTop())

While BBS->( EOF())
	cDescTipo := BBS->BBS_DESCRI + ";"
EndDo

Return cDescTipo

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AutReemb³ Autor ³ Thiago Guilherme       ³ Data ³ 06.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os dados das autorizações		       	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AutReemb(aDadAut)

LOCAL oBrowUsr
LOCAL oDlg
LOCAL bOK      	:= { || nOpca := 1, oDlg:End() }
LOCAL bCancel  	:= { || nOpca := 0, oDlg:End() }
LOCAL aButtons	:={}
Local aCampos	:= {}
Local aBls		:= {}


If LEN(aDadAut) > 0
	
	DEFINE MSDIALOG oDlg TITLE STR0207 FROM 010,020 TO 050,130 OF GetWndDefault() //"Reembolsos Aprovados"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ cria as colunas e insere os dados correspondete a cada coluna     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrowUsr := TcBrowse():New( 033 , 003, 430, 270,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	
	oBrowUsr:AddColumn(TcColumn():New(STR0208,nil,; //"Número Autorização"
	nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowUsr:ACOLUMNS[1]:BDATA     := { || aDadAut[oBrowUsr:nAt,1] }
	
	oBrowUsr:AddColumn(TcColumn():New(STR0209,nil,; //"Usuário"
	nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowUsr:ACOLUMNS[2]:BDATA     := { || aDadAut[oBrowUsr:nAt,2] }
	
	oBrowUsr:AddColumn(TcColumn():New(STR0210,nil,; //"Título / Fatura"
	nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowUsr:ACOLUMNS[3]:BDATA     := { || aDadAut[oBrowUsr:nAt,3] }
	
	oBrowUsr:AddColumn(TcColumn():New(STR0211,nil,; //"Protoc. Vinculado"
	nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowUsr:ACOLUMNS[4]:BDATA     := { || aDadAut[oBrowUsr:nAt,4] }
	
	oBrowUsr:AddColumn(TcColumn():New("Status",nil,; //"Status"
	nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowUsr:ACOLUMNS[5]:BDATA     := { || aDadAut[oBrowUsr:nAt,5] }
	
	oBrowUsr:SetArray(aDadAut)
	aadd(aButtons,{"Gerar Relatório",{ || GExpExcel(aDadAut)  },"Gerar Relatório","Gerar Relatório"}) 
	
	//-- LGPD --------
	if objCENFUNLGP:isLGPDAt()
		aCampos :={"B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT","A2_NREDUZ",.F.,"B44_PROTOC",.F.}//== Número Autorização" , "Usuário" , "Título / Fatura" , "Protoc. Vinculado" , "Status"
		aBls := objCENFUNLGP:getTcBrw(aCampos)
		oBrowUsr:aObfuscatedCols := aBls
	endif
	//----------------

	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons) CENTER
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AtuCmpB1N³ Autor ³ Thiago Guilherme       ³ Data ³ 06.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza campo B1N_VLRREE de acordo com a valoração da guia
de autorização de reembolso												³±±.
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AtuCmpB1N(oGrid, lExc)

LOCAL nI
LOCAL nVlrTotReem := 0
DEFAULT lExc := .F.

BOW->(dbSetOrder(1))
B1N->(dbSetOrder(2))
For nI := 1 To LEN(oGrid:aCols)	   		
	If B1N->(DbSeek(xFilial("B1N") + M->B44_PROTOC + oGrid:aCols[nI][GdFieldPos("B45_SEQB1N",oGrid:aHeader)]))
		
		B1N->(RecLock('B1N',.F.))
			
			If !lExc
				B1N->B1N_VLRREE := oGrid:aCols[nI][GdFieldPos("B45_VLRPAG",oGrid:aHeader)]
				B1N->B1N_IMGSTA := oGrid:aCols[nI][GdFieldPos("B45_IMGSTA",oGrid:aHeader)]
			Else
				
				B1N->B1N_VLRREE := 0
				
				B14->(DbSetOrder(1)) 
				//manter o DBSEEK pois é necessário que o banco seja consultado toda vez que executar esta função
				If B1N->B1N_IMGSTA == "DISABLE" .AND. !B14->(DbSeek(xFilial("B14") + B1N->(B1N_PROTOC + B1N_CODPRO + B1N_MATRIC + B1N_SEQUEN))) 
				
					B1N->B1N_IMGSTA := "ENABLE"
				EndIf
			EndIf
		
		B1N->( MsUnlock() )

		nVlrTotReem+= B1N->B1N_VLRREE
		
	EndIf
Next

// Atualizando o valor do reembolso no cabeçalho.

If BOW->(DbSeek(xFilial("BOW") + M->B44_PROTOC))
	BOW->(RecLock('BOW',.F.))
	BOW->BOW_VLRREE := nVlrTotReem
	BOW->(MsUnLock())

EndIf


Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtCmpoB1N ºAutor  ³ TOTVS              º Data ³ 01/06/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpa os campos de receita quando o campo B1N_USOCON é
alterado        											  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
function AtCmpoB1N()

Local lRet := .T.

If Readvar() == "M->B1N_USOCON" .OR. Readvar() == "M->B1N_MATRIC"

	M->B1N_CODREC := Space(TamSx3("B1N_CODREC")[1])
	M->B1N_CODMED := Space(TamSx3("B1N_CODMED")[1])
	M->B1N_SEQMED := Space(TamSx3("B1N_SEQMED")[1])
	M->B1N_DESMED := Space(TamSx3("B1N_DESMED")[1])
	M->B1N_QTDMED := 0

	//limpa o campo da liberação caso a matrícula seja alterada para 29-09 
	//outro beneficiário 
	If ! empty(M->B1N_NUMLIB) .AND. !PLSVLDLIB("B1N",.F.)
		M->B1N_NUMLIB := Space(TamSx3("B1N_NUMLIB")[1])
	EndIf
	
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldCmpRec ºAutor  ³ TOTVS              º Data ³ 01/06/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida os campos referente a receita quando o medicamento
for de uso contínuo										  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
function VldCmpRec()

LOCAL lRet := .T.

//referente a receita quando o medicamento for de uso contínuo.
If M->B1N_USOCON == "1"
	
	If EMPTY(M->B1N_CODREC)
		MsgAlert(STR0229)
		lRet := .F.
		
	ElseIf EMPTY(M->B1N_CODMED)
		MsgAlert(STR0230)
		lRet := .F.
		
	ElseIf EMPTY(M->B1N_QTDMED)
		MsgAlert(STR0231)
		lRet := .F.
	EndIf
EndIf

If ValType(oFolder) <> "U"
	oFolder:SetOption(1)
	oFolder:Refresh()
Endif	

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldQtdMed ºAutor  ³ TOTVS              º Data ³ 01/06/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se a quantidade digitada no protocolo é maior do que
a quantidade disponível no medicamento na receita						  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
function VldQtdMed()

LOCAL lRet := .T.
LOCAL nqtdApr := Posicione("B7D",3,xFilial("B7D")+M->(B1N_CODREC+B1N_CODMED),"B7D_QTDAUT")
LOCAL nqtdUtl := Posicione("B7D",3,xFilial("B7D")+M->(B1N_CODREC+B1N_CODMED),"B7D_QTDEXE")
LOCAL nResult := nqtdApr - nqtdUtl

if nqtdApr <> 0 //Fazendo alteração para permitir que sejam informados N Quantidades quanda quantidade aprovada for igual a 0.
	If M->B1N_QTDMED > nResult .OR. M->B1N_QTDMED == 0 
		
		MsgInfo(STR0313,STR0049) //A quantidade digita é maior que o saldo disponível na receita,Atenção 
		lRet := .F.
	EndIf 
endif

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLStatusBox  ºAutor  ³TOTVS           º Data ³  14/09/15   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLStatusBox()
Local cStatusBox := STR0236 // "0=Solicitado (Portal);1=Protocolado;2=Em analise;3=Deferido;4=Indeferido;5=Em digitacao;6=Lib. financeiro;7=Nao lib. financeiro;8=Glosado;9=Auditoria;A=Solicitação não concluída;B=Aguardando informação do Beneficiário;C=Aprovado Parcialmente;D=Cancelado;E=Reembolso Revertido"
If ExistBlock("PL001STA")
	cStatusBox := Execblock("PL001STA", .F., .F., {cStatusBox})
Endif
Return(cStatusBox)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GatCampo ºAutor  ³ TOTVS              º Data ³ 01/06/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega campo B1N_CODREC de acordo com o codigo do medicamento º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
function GatCampo()

If !EMPTY(M->B1N_CODMED)

	M->B1N_CODREC := B7D->B7D_CODREC
Else
	M->B1N_CODREC := ""
EndIf 

M->B1N_QTDMED := 0 

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLRMBPRE ºAutor  ³ Roberto Vanderlei  º Data ³ 14/09/2015  	     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRotina para preparação dos dados para envio do e-mail na alterção STATUS ÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
function PLRMBPRE(cAlias,cAliasIte, cProtocolo, cStatusID, cStatusDesc)

local cChave := ""
local linha
local aCampos := {}
local aItens  := {}
local nVlrPagPro := 0
local cMotItem := ""
local nIndice
local linha
default cStatusDesc = ""

if cAlias <> 'BOW'
	BOW->(dbSetOrder(1))
	BOW->(dbSeek(xFilial("BOW")+cProtocolo))
endif

if cAlias = 'BOW'
	for linha = 1 to len(aCores)
		if &("BOW->" + aCores[linha][1])
			nIndice := linha
			cStatusDesc := aCdCores[nIndice][2]
		endif
	next
else
	if cStatusID = '7'
		cStatusDesc := "Não lib. financeiro"
	else
		if cStatusID = '6'
			cStatusDesc := "Lib. financeiro"
		endif
	endif
endif

B14->(dbSetOrder(1))

if cAliasIte = 'B1N'
	
	B1N->(dbSetOrder(1))
	
	If B1N->(MsSeek(xFilial("B1N")+BOW->BOW_PROTOC))
		While !B1N->(Eof())
			
			if B1N->B1N_FILIAL + B1N->B1N_PROTOC = xFilial("BOW") + BOW->BOW_PROTOC
				
				If B14->(dbSeek(xFilial("B14")+BOW->BOW_PROTOC+B1N->B1N_CODPRO))
					cMotItem := alltrim(B14->B14_MOTIVO)
				endif
				
				aadd(aItens, {Posicione("BR8",1,xFilial("BR8")+B1N->(B1N_CODPAD+B1N_CODPRO),"BR8_DESCRI"), iif(cStatusID <> "C", iif(cStatusID = "7", "Reprovado", iif(cStatusID = "6", "Aprovado", cStatusDesc)), iif(AllTrim(B1N->B1N_IMGSTA) = "ENABLE", "Aprovado", iif(AllTrim(B1N->B1N_IMGSTA) = "DISABLE", "Reprovado", "Em análise"))), .F., .F., iif(cMotItem = NIL, "", cMotItem)})
				
				cMotItem := ""
			endif
			
			B1N->(DbSkip())
		EndDo
	endif
	
else
	B45->(dbSetOrder(1))
	If B45->(MsSeek(xFilial("B45")+ B44->B44_OPEMOV+ B44->B44_ANOAUT+ B44->B44_MESAUT+ B44->B44_NUMAUT))
		While !B45->(Eof())
			
			if B44->(B44_FILIAL + B44_OPEMOV+ B44_ANOAUT+ B44_MESAUT+ B44_NUMAUT) = B45->(B45_FILIAL + B45_OPEMOV+ B45_ANOAUT+ B45_MESAUT+ B45_NUMAUT)
				if B45->B45_STATUS = "1"
					nVlrPagPro += B45->B45_VLRPAG
				endif
				
				If B14->(dbSeek(xFilial("B14")+BOW->BOW_PROTOC+B45->B45_CODPRO))
					cMotItem := alltrim(B14->B14_MOTIVO)
				endif
				
				aadd(aItens, {Posicione("BR8",1,xFilial("BR8")+B45->(B45_CODPAD+B45_CODPRO),"BR8_DESCRI"), iif(AllTrim(B45->B45_STATUS) = "1", "Autorizada", "Nao Autorizada"), .F., .F., cMotItem})
				
				cMotItem := ""
			endif
			
			B45->(DbSkip())
		EndDo
	EndIf
endif

aadd(aCampos, {"cProtoc", BOW->BOW_PROTOC})
aadd(aCampos, {"cTipoSolicitacao", "Reembolso"})
aadd(aCampos, {"cNomBen", capital(POSICIONE("BA1",2,XFILIAL("BA1")+BOW->(BOW_OPEUSR+BOW_CODEMP+BOW_MATRIC+BOW_TIPREG+BOW_DIGITO),"BA1_NOMUSR")) }) //    BOW->BOW_NOMUSR})
aadd(aCampos, {"cDtProvPagto", iif(alltrim(STRTRAN(DTOC(B44->B44_DATPAG),"/","")) = "", "", Alltrim(B44->B44_DATPAG))})
aadd(aCampos, {"cValTot", iif(nVlrPagPro = 0, "", nVlrPagPro)})
aadd(aCampos, {"cMotiv", BOW->BOW_MOTIND})//Motivo da Capa do Protocolo
aadd(aCampos, {"cDatPar", DATE()})
aadd(aCampos, {"cStatusAut", cStatusDesc/*aCdCores[nIndice][2]*/ /*BOW->BOW_STATUS"3"*/})

PLRMBMAIL(aCampos, aItens, alltrim(BA1->BA1_EMAIL), "PLSA001A", iif(cStatusID = "7", "4", iif(cStatusID = "6", "3", cStatusID)))
return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLRMBMAIL ºAutor  ³ Roberto Vanderlei  º Data ³ 14/09/2015  	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRotina Genérica para enviar e-mail ao atualizar o status das solicitações. º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
function PLRMBMAIL(aCampos, aItens, cEmail, cRotina, cStatusId)
/*
aItens
- 1º Descrição de Procedimento.
- 2º Status do Procedimento.
- 3º Indica se o Procedimento é SUS.
- 4º Indica se é farmácia popular.
- 5º Motivo.

*/
 
local cCodSin
local cDescProc
local cStProc
local lAoSus
local lAoFp
local cMotivo
local linha
local i


for i := 1 to len(aCampos)
	&(aCampos[i][1]) := aCampos[i][2]
next



if cTipoSolicitacao = "Reembolso"
	cItens := "<table class='titulo'><tr><td colspan= '" + iif(cStatusId = "C", "3", "2")+"' align= 'center'><b>Itens Solicitados</b></td></tr>
	cItens	+= "<tr class='cabecalho'><td align= 'center'><b>Procedimento</b></td><td align= 'center'><b>Situação</b></td>" + iif(cStatusId = "C", "<td align= 'center'><b>Motivo</b></td></tr>", "</tr>")
else
	cItens := "<table class='titulo'><tr><td colspan= '5' align= 'center'><b>Itens Solicitados</b></td></tr>
	cItens	+= "<tr class='cabecalho'><td align= 'center'><b>Procedimento</b></td><td align= 'center'><b>Situação</b></td><td align= 'center'><b>SUS</b></td><td align= 'center'><b>Farmácia Popular</b></td><td align= 'center'><b>Motivo</b></td></tr>"
endif

for linha := 1 to len(aItens) //Quantidade de Linhas
	
	cDescProc := aItens[linha][1]
	cStProc   := aItens[linha][2]
	lAoSus	   := aItens[linha][3]
	lAoFp	   := aItens[linha][4]
	cMotivo   := aItens[linha][5]
	
	if mod(linha, 2) = 0
		cItens	+= "<tr class= 'linhaPar'>"
	else
		cItens	+= "<tr class='linhaImp'>"
	endif
	
	if cTipoSolicitacao = "Reembolso"
		cItens	+= "<td align= 'center'>" + cDescProc + "</td><td align= 'center'>"+ cStProc + iif(cStatusId = "C", "</td><td align= 'center'>" + cMotivo + "</td></tr>", "</td></tr>")
	else
		cItens	+= "<td align= 'center'>" + cDescProc + "</td><td align= 'center'>"+ cStProc + "</td><td align= 'center'>" + iif(lAoSus, "  Sim  ", "  Não  ") + "</td><td align= 'center'>" + iif(lAoFp, "  Sim  ", "  Não  ") + "</td><td align= 'center'>" + cMotivo + "</td></tr>"
	endif
	//cItens	+= "Procedimento: " +  Space(nMaiorCod - len(cCodProc)) + " - " + cDescProc + Space(nMaiorDesc - len(cDescProc)) + " - " +  cStProc + Space(nMaiorStatus - len(cStProc)) + " - " + iif(lAoSus, "SUS", "   ") + " - " + iif(lAoFp, "Farmácia Popular", "                ") + " - " + cMotivo
Next linha
cItens	+= "</table>"



BOJ->(DbSelectArea("BOJ"))
BOJ->(DbSetOrder(3))
BOJ->(MsSeek(xFilial("BOJ") + cRotina + (Space(TamSx3("BOJ_ROTINA")[1] - len(cRotina)))  + "1." + cStatusId))

cCodSin := BOJ->BOJ_CODSIN

PLSinaliza(cCodSin,nil,nil, alltrim(cEmail), "Sol. Reembolso","",,,,, .F.,"",,,,.F.)


Return

/*±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LmpCmpB1n   ºAutor  ³Thiago Guilherme   º Data ³  28/05/15º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Limpa campos
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION LmpCmpB1n()

M->B1N_REGSOL := Space(TamSx3("B1N_REGSOL")[1])
M->B1N_NOMSOL := Space(TamSx3("B1N_NOMSOL")[1])
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSVLDSTAT ³ Autor ³ Rodrigo Morgon      ³ Data ³ 15.09.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida status informado pelo operador, considerando os     ³±±
±±³          ³ itens disponiveis na grid de eventos                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function PlsVldStat(aColsIte, cStatus)

Local nLen		:= Len(aColsIte)
Local nFor		:= 0
Local nQtdOK	:= 0
Local nQtdNG 	:= 0

DEFAULT cStatus := ""

For nFor := 1 To nLen
	IIF(allTrim(aColsIte[nFor, 1]) == "ENABLE" .OR. allTrim(aColsIte[nFor, 1]) == "BR_AZUL" , nQtdOk++, nQtdNG++)
Next

If nQtdOK == nLen
	//Todos autorizados, status 3: DEFERIDO
	cStatus := "3"
ElseIf nQtdNG == nLen
	//Todos negados/glosados, status 4: INDEFERIDO
	cStatus := "4"
Else
	//Alguns liberados e outros nao, status C: PARCIALMENTE APROVADO
	cStatus := "C"
EndIf

Return cStatus

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ PLGRVBK6 ³ Autor ³ Renan Martins			³ Data ³ 21.09.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava na BK6 as RDAs não referenciadas					    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLGRVBK6(MenOA)
Local aArea := GetArea()
Local nX 				:= 0
Local nPos 			:= 0
Local aHeadBK6		:= {}
Local nI 				:= 0
Local nU 				:= 0
Local aIndAux			:= {} //StrToArray( cCmpsInd , '+' ) // Pega o indice e separa os campos
Local aIndUso			:=	{} // aqui irão os campos do indice + a expressao macro para pegar o dado no grid
Local cVarInd			:= "" //Conteudo do indice apos a execucao da macro
Local lAchou			:= .F.
Local cAliUso			:= "BK6"
Local aCampos			:= {}
Local aCpo 			:= {}
Local cTitulo 		:= STR0247
LOCAL cSQL 			:= ""
LOCAL aRDANR			:= {}
LOCAL cCmpObg			:= ""
LOCAL nBK6Cnpj		:= 0
LOCAL nBK6Nome		:= 0
LOCAL nBK6Dtnas		:= 0
LOCAL nAltDiag 		:= 540 // Altura da Dialog
LOCAL nLargDiag 	:= 700 // Largura da Dialog
LOCAL cCpoID 		:= "" //Campo principal de identificaçao dos registros editados (normalmente o mesmo do filtro)
LOCAL cFiltro 		:= "BK6_CODIGO < '0'" // Filtro da tabela, EXATAMENTE PARA NÃO EXIBIR NADA DA BK6
LOCAL nOpcGD		:= /*GD_INSERT+*/GD_UPDATE //+ GD_DELETE // Permissoes no GRID
LOCAL cFunPosOK		:= "" // Funçao para execuçao ao clicar em OK e antes de gravar
LOCAL aButAR		:= {} // Botoes no açoes relacionadas
LOCAL aCampos		:= {} // Campos que serao exibidos
LOCAL lCpoSequen	:= .T. // Se houver campo sequencial confirma a utilizaçao do sequencial
LOCAL cCpoExb		:= ""
LOCAL lOnlyShow		:= .F. // Campos que serao exibidos no grid
LOCAL cOrder  		:= "" //Ordenação pelos Campos
LOCAL lLimpaValid	:= .F.

Private oDlg2			:= Nil
Private oGDPri		:= Nil
Private aColsGen 		:= {}
Private nCGen 		:= 0
Private nOpca 		:= 0

Default MenOA			:= ""

//Desativa o atalho de teclado para não permitir abrir a rotina varias vezes enquanto ela esta aberta
SET KEY K_ALT_Z TO 

//Monto a estrutura, baseado no HS_BDados
HS_BDados(cAliUso, @aHeadBK6, @aColsGen,@nU, 1,, cFiltro,,,cCpoExb,,,,,,.T.,/*aLeg*/,,,,, /*aCpo*/,/*adminaJoin*/,,cOrder)


//SELECT para pegar os dados da B1N e comparar com os existentes na BK6, para montar um array
cSQL := " SELECT DISTINCT B1N_CODREF, B1N_PRCNPJ, B1N_PRNOME FROM " + RetSQLName("B1N")
cSQL += " WHERE B1N_FILIAL = '" + xFilial("B1N") +"' "
cSql += " AND B1N_PRCNPJ NOT IN "
cSql += " (SELECT BK6_CGC FROM " + RetSQLName("BK6") + " BK6 WHERE BK6.D_E_L_E_T_ <> '*')"
cSQL += " AND B1N_PRCNPJ <> '' "

//Se a chamada da função não for via menu, isto é, for executada ao fim do "Salvar" do protocolo, buscar apenas a rede não referencia deste item.
IF (MenOA <> "MOA")
	cSQL += " AND B1N_PROTOC = '" + BOW->BOW_PROTOC + "' "
ENDIF

cSQL += " AND D_E_L_E_T_ <> '*'"

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"DADB1N",.F.,.T.)
IF DADB1N->(EOF())
	IF (MenOA == "MOA")
		Alert(STR0252)
	ENDIF
	DADB1N->(DbCloseArea())

	SetKey(K_ALT_Z,{|| PLGRVBK6("MOA")}) // Verifica cadastro rede  
	Return
ELSE
	While !DADB1N->(Eof())
		aAdd(aRDANR, {DADB1N->B1N_PRCNPJ, DADB1N->B1N_PRNOME})
		DADB1N->(DbSkip())
	EndDo
ENDIF
DADB1N->(DbCloseArea())


//Verifico em quais posições estão CGC, Nome e Data de Nascimento no Header
nBK6Cnpj 	:= aScan(aHeadBK6, {|x|AllTrim(x[2]) == "BK6_CGC"})
nBK6Nome 	:= aScan(aHeadBK6, {|x|AllTrim(x[2]) == "BK6_NOME"})
nBK6DtNas	:= aScan(aHeadBK6, {|x|AllTrim(x[2]) == "BK6_DATNAS"})
nBK6Filial	:= aScan(aHeadBK6, {|x|AllTrim(x[2]) == "BK6_FILIAL"})

//Travar o campo filial para edição  no grid
IF (nBK6Filial > 0)
	aHeadBK6[nBK6Filial][14] := "V"
ENDIF

For nX := 1 To Len(aIndAux)
	If 	"_FILIAL" $ Alltrim(aIndAux[nX])
		Loop
	ElseIf 	Alltrim(aIndAux[nX]) == Alltrim(cCpoID) // Se for o campo passado dentro do indice joga a variavel do dado pra ser executada macro
		AADD(aIndUso, { aIndAux[nX] , "xDadoId" } )
	Else // Caso contrario jogo a macro da posição no aCols encontrada
		nPos := Ascan(aHeadBK6,{|x| AllTrim(x[2])==aIndAux[nX]})
		If nPos == 0
			Exit
		EndIf
		AADD(aIndUso, { aIndAux[nX] , "aColsGen[nCGen," + Alltrim(Str(nPos)) + "]" } )
	EndIf
	
Next nX


DEFINE MSDIALOG oDlgGen TITLE cTitulo From 000, 000 To 480, 650 Of oMainWnd Pixel   //000 000 400 600

oGDPri  := MsNewGetDados():New(035, 005, 230, 320,nOpcGD,,,,,,,,,, oDlg2, aHeadBK6, aColsGen)    // 000 000 300 500

For nI := 1 TO Len(aRDANR)
	oGDPri:AddLine(.F., .F.)
	oGDPri:lNewLine := .F.
	oGDPri:aCols[nI, nBK6Nome] 	:= aRDANR[nI][2]//nome da aArrayB1N
	oGDPri:aCols[nI, nBK6Cnpj] 	:= aRDANR[nI][1]//cnpj
	oGDPri:aCols[nI, nBK6DtNas]	:= STOD("  /  /    ")//limpar data do nascimento
	oGdPri:aCols[nI, nBK6Filial]:= xFilial("BK6") //Filial
	oGDPri:oBrowse:Refresh()
Next
aSize(oGDPri:aCols, Len(oGDPri:aCols) - 1)
//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()
ACTIVATE MSDIALOG oDlgGen CENTERED ON INIT EnchoiceBar(oDlgGen,{ || nOpca := 1, oDlgGen:End() },{|| nOpca := 0, oDlgGen:End()})

If nOpca == 1 .AND. !lOnlyShow
	//Pergunta ao usuário se deseja mesmo Gravar na BK6
	IF !( MSGYESNO(STR0248) ) //Deseja mesmo gravar estes dados na tabela de Rede Não Referenciada?
		
		SetKey(K_ALT_Z,{|| PLGRVBK6("MOA")}) // Verifica cadastro rede  
		Return
	ENDIF
	
	//Verifico se algum campo obrigatório não foi preenchido e exibo mensagem
	FOR nI := 1 TO Len(oGDPri:aCols)
		FOR nX := 1 TO Len(oGDPri:aCols[nI])-1
			IF ( Empty(oGDPri:aCols[nI, nX]) .AND. aHeadBK6[nX,17] )
				IIF ( (AT(aHeadBK6[nX,2],cCmpObg) == 0), cCmpObg+= aHeadBK6[nX,2], "")
			ENDIF
		NEXT
	NEXT
	
	IF Empty(cCmpObg)
		PLUPTCOLS("BK6",oGDPri:aCols,aHeadBK6,{},3,{})
		PLSATREFB1N(oGDPri:aCols, aHeadBK6)
	ELSE
		MsgAlert(STR0249 + cCmpObg + STR0250) //#O(s) campo(s):   #não foram preenchidos e são obrigatórios!
	ENDIF
	
ENDIF

//Reativa a tecla de atalho
SetKey(K_ALT_Z,{|| PLGRVBK6("MOA")}) // Verifica cadastro rede  

Return ()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ PLSATREFB1N ³ Autor ³ Renan Martins   	³ Data ³ 21.09.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza a B1N_CODREF após a atualização da rede		    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSATREFB1N(oGrid, aHeadC)
Local nBK6CGC := 0
Local nBK6COD := 0
Local nI		:= 0
Local nBK6NOM	:= 0

B1N->(DbSelectArea("B1N"))
B1N->(DbSetOrder(5))

nBK6CGC 	:= aScan(aHeadC, {|x|AllTrim(x[2]) == "BK6_CGC"})
nBK6COD	:= aScan(aHeadC, {|x|AllTrim(x[2]) == "BK6_CODIGO"})
nBK6NOM	:= aScan(aHeadC, {|x|AllTrim(x[2]) == "BK6_NOME"})

FOR nI := 1 TO Len (oGrid)
	IF ( B1N->(MsSeek(xFilial("B1N")+oGrid[nI, nBk6CGC])) )
		While ( !B1N->(EOF()) .AND. B1N->B1N_PRCNPJ == oGrid[nI, nBk6CGC])
			B1N->(RecLock("B1N", .F.))
			//B1N->B1N_CODREF := oGrid[nI, nBK6COD]
			B1N->B1N_NOMREF := oGrid[nI, nBK6NOM]
			B1N->(MsUnlock())
			B1N->(DbSkip())
		Enddo
	ENDIF
NEXT
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA001AGAT³ Autor ³            ³ Data ³ 28.09.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gatilho do campo B1N_CODPRO                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA001AGAT(cProt,cCodPad,cCodPro ,cCodInt ,cCodRDA ,cCodEsp ,cTipPreFor,cRegExe ,cEstExe ,cCdPfRe ,cCodLoc ,cUFAte ,cMunAte,nQtdPro ,dDatPro ,lWeb)
	LOCAL cAliCab:="BOW"
	LOCAL cAliPro:="B1N"
	LOCAL cAliCom :="B7M"
	LOCAL cAlias    := cAliCab
	LOCAL cSequen    := &("M->"+cAliPro+"_SEQUEN")
	LOCAL cCodTab:= ""
	LOCAL cSigExe:= ""
	LOCAL nFor
	LOCAL nI
	LOCAL aDadUsr := PLSGETUSR()
	LOCAL cCodSeq := &("M->"+cAliPro+"_SEQUEN")
	LOCAL nPos	  := 0
	LOCAL nSize	  := 0
	LOCAL nInd	  := 0
	LOCAL lHonor  := .F.
	LOCAL aPartic := {}
	LOCAL cGraPa  := ""
	LOCAL aArea 	:= GetArea()

	Default lWeb		:= .F.

	If Type("M->"+cAliPro+"QTDPRO") <> "U"
		If M->B1N_QTDPRO>0
			nQtdPro := M->B1N_QTDPRO
		Endif
	Endif

	If Empty(cMunAte)
		If !lWeb
			cMunAte	:= IIf(Type(cAliCab+"_MUNATE") <> "U",&("M->"+cAliCab+"_MUNATE"),"")
		else
			cMunAte	:= IIF(Type("BOW->BOW_MUNATE") == "C", BOW->BOW_MUNATE, "")
		EndIf
	Endif

	If !lWeb
		
		cCodInt    := iif (Empty(cCodInt), &("M->"+cAliCab+"_OPEUSR"),cCodInt)
		cCodRDA    := iif (Empty(cCodRDA), &("M->"+cAliCab+"_CODRDA"),cCodRDA)
		cCodEsp    := iif (Empty(cCodEsp), &("M->"+cAliCab+"_CODESP"),cCodEsp)
		cTipPreFor := iif (Empty(cTipPreFor), &("M->"+cAliCab+"_TIPPRE"),cTipPreFor)
		cRegExe    := iif (Empty(cRegExe), &("M->"+cAliCab+"_REGEXE"),cRegExe)
		cEstExe    := iif (Empty(cEstExe),&("M->"+cAliCab+"_ESTEXE"),cEstExe)
		cCdPfRe    := iif (Empty(cCdPfRe) ,&("M->"+cAliCab+"_CDPFRE"),cCdPfRe)
		cCodLoc    := iif (Empty(cCodLoc) ,&("M->"+cAliCab+"_LOCATE"),cCodLoc)
		cUFAte     := iif (Empty(cUFAte), If(Type(cAliCab+"_UFATE") <> "U",&("M->"+cAliCab+"_UFATE"),""),cUFAte)
		dDatPro    := iif (empty(dDatPro),&("M->"+cAliPro+"_DATDOC"),dDatPro)
		cCodPad    := iif (Empty(cCodPad) ,&("M->"+cAliPro+"_CODPAD"),cCodPad)
		cCodPro    := iif(Empty(cCodPro),&("M->"+cAliPro+"_CODPRO"),cCodPro)
		nQtdPro	 := iif (Empty(nQtdPro),&("M->"+cAliPro+"_QTDPRO"),nQtdPro)
		cSequen    := &("M->"+cAliPro+"_SEQUEN")
		
		If Type("M->"+cAlias+"_REGEXE") <> "U"
			cRegExe:= &("M->"+cAlias+"_REGEXE")
		Endif
		
		If Type("M->"+cAlias+"_SIGLA") <> "U"
			cSigExe:= &("M->"+cAlias+"_SIGLA")
		Endif
		
		If Type("M->"+cAlias+"_ESTEXE") <> "U"
			cEstExe:= &("M->"+cAlias+"_ESTEXE")
		Endif
		
		If Type("M->"+cAlias+"_CDPFRE") <> "U"
			cCdPfRe:= &("M->"+cAlias+"_CDPFRE")
		Endif
		
		If Type("M->"+cAlias+"_DTDIGI") <> "U"
			dDatPro := &("M->"+cAlias+"_DTDIGI")
		Endif
	else
		cCodInt    := iif (Empty(cCodInt), BOW->BOW_OPEUSR, cCodInt)
		cCodRDA    := iif (Empty(cCodRDA), BOW->BOW_CODRDA, cCodRDA)
		cCodEsp    := iif (Empty(cCodEsp), BOW->BOW_CODESP, cCodEsp)
		cTipPreFor := iif (Empty(cTipPreFor), BOW->BOW_TIPPRE, cTipPreFor)
		cRegExe    := iif (Empty(cRegExe), BOW->BOW_REGEXE, cRegExe)
		cEstExe    := iif (Empty(cEstExe), BOW->BOW_ESTEXE, cEstExe)
		cCdPfRe    := iif (Empty(cCdPfRe), BOW->BOW_CDPFRE, cCdPfRe)
		cCodLoc    := iif (Empty(cCodLoc), BOW->BOW_LOCATE, cCodLoc)
		cUFAte     := iif (Empty(cUFAte),  BOW->BOW_UFATE, cUFAte)
		dDatPro    := iif (empty(dDatPro), B1N->B1N_DATDOC, dDatPro)
		cCodPad    := iif (Empty(cCodPad), B1N->B1N_CODPAD, cCodPad)
		cCodPro    := iif(Empty(cCodPro), B1N->B1N_CODPRO, cCodPro)
		nQtdPro	   := iif (Empty(nQtdPro), B1N->B1N_QTDPRO, nQtdPro)
		cSequen    := B1N->B1N_SEQUEN
		
		If Type("BOW->BOW_REGEXE") <> "U"
			cRegExe:= BOW->BOW_REGEXE
		Endif
		
		If Type("BOW->BOW_SIGLA") <> "U"
			cSigExe:= BOW->BOW_SIGLA
		Endif
		
		If Type("BOW->BOW_ESTEXE") <> "U"
			cEstExe:= BOW->BOW_ESTEXE
		Endif
		
		If Type("BOW->BOW_CDPFRE") <> "U"
			cCdPfRe:= BOW->BOW_CDPFRE
		Endif
		
		If Type("BOW->BOW_DTDIGI") <> "U"
			dDatPro := BOW->BOW_DTDIGI
		Endif
	EndIf

	If Len(aDadUsr) = 0 .and. Type("M->"+cAlias+"_USUARI") <> "U"
		aRetFun := PLSDADUSR(&("M->"+cAlias+"_USUARI"),"1",.T.,dDatPro,nil,nil,nil)

		If !lWeb .and. !aRetFun[1] 
			PLSMOVCRI("2",{},aRetFun[2])
			Return(.F.)
		Endif

	EndIF

	
	aVetTab 	:= PLSRETTAB(cCodPad,cCodPro,dDatPro,cCodInt,cCodRDA,cCodEsp,"",;
	cCodLoc,dDatPro,"1",aDadUsr[45],aDadUsr[11],;
	nil,"2",aDadUsr,cTipPreFor,nil,nil,.T.,cUFAte,cMunAte,nil,nil,nil,lweb)

	If aVetTab[1]
		cCodTab	:= aVetTab[3]
		aCompo		:= PLSCOMEVE(cCodTab,cCodPad,cCodPro,cCodInt,dDatPro,,,,,,,,,)
	else
		If !lWeb
			Msgalert(STR0293) //"Não foi encontrada a composição do procedimento na Tabela de reembolso da Operadora"
		EndIf
		Return(.F.)
	Endif

	If Len(aCompo) > 0
		If lWeb
			PlsGrvBM7(cProt,aCompo,cCodPad,cCodPro)
		Else
			PLS720IBD7(nil,nil,cCodPad,cCodPro,cCodTab,PLSINTPAD(),cCodRDA,cRegExe,;
			nil,cEstExe,cCdPfRe,cCodEsp,cCodLoc,"4",cSequen,"1","04",;
			dDatPro,nil,aCompo,nil,iif(lweb,Nil,oBrwComp),NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,.T.,lWeb)
			If ValType(oBrwComp) <> "U"
				oBrwComp:ForceRefresh(oBrwPro)
				oBrwComp:lAddLine        := .F.	
				oFolder:Refresh()
				
						
			Endif
		Endif
	EndIf

	RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlsGrvBM7³ Autor ³            ³ Data ³ 28.09.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄdocÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava Composição vinda do Portal                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PlsGrvBM7(cProt,AreCom,cCodPad,cCodPro)
	LOCAL aArea 	:= GetArea()
	LOCAL nI 		:= 0
	LOCAL cSeq		:= B1N->B1N_SEQUEN
	LOCAL cNomRef

	B7M->(DbSetOrder(1)) //B7M_FILIAL+B7M_PROTOC+B7M_SEQUEN+B7M_CODUNM+B7M_NLANC
	For nI:= 1 to Len(AreCom)
		
		cLanc := IF(AreCom[nI,1]==GetNewPar("MV_PLSCAUX","AUX"),StrZero(AreCom[nI,3],2),"")
		lInclui := !B7M->(MsSeek(xFilial("B7M")+cProt+cSeq+AreCom[nI,1]+cLanc )) 
		
		B7M->(RecLock("B7M", lInclui))
			B7M->B7M_FILIAL	:= xFilial("B7M")
			B7M->B7M_SEQUEN	:= cSeq
			B7M->B7M_PROTOC	:= cProt
			B7M->B7M_CODPAD	:= cCodPad
			B7M->B7M_CODPRO	:= cCodPro
			B7M->B7M_UNITDE	:= AreCom[nI,7]
			B7M->B7M_REFTDE	:= AreCom[nI,3]
			B7M->B7M_CODUNM	:=	AreCom[nI,1]
			B7M->B7M_NLANC	:= cLanc
			BR8->(DbSetOrder(1))
			BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))
			B7M->B7M_PROCCI	:= If(BR8->BR8_TIPEVE $"2,3","1","0")
		B7M->(MsUnlock())
	Next nI
	RestArea(aArea)
Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} P001ACONH
Funcao para exibir os documentos do protocolo
@author Rogério Tabosa
@since 02/11/2015
@version P12
/*/
//-------------------------------------------------------------------

Function P001ACONH(nOpc) 
Local 	aBkCols	
Local   aBkRotina := iif(type("aRotina") <> "U", aRotina, {})
Local cChave := ""
LOCAL lDownload := GetNewPar("MV_PLPDWN", .F.)
PRIVATE CCADASTRO := STR0258 //"Conhecimento Protocolo de Reembolso"
PRIVATE aRotina := aClone(aBkRotina)
DEFAULT nOpc := 1

//Desativa o atalho de teclado para não permitir abrir a rotina varias vezes enquanto ela esta aberta
SET KEY VK_F7 TO //16-02

if FunName() == "TMKA271"
	
	aBkCols	:= aClone(aCols)
	aRotina := {{'Conhecimento','MsDocument',0,3},{"Inclusão Rápida",'PLSDOcs',0,3}} //"Conhecimento"

else
		aRotina := {{'Conhecimento','MsDocument',0,3},{"Inclusão Rápida",'PLSDOcs',0,3}} //"Conhecimento"
	//aRotina := { 'NOTE','MsDocument',0,3},{"Inclusão Rápida",'Ft340ExeObj()',0,3}} //"Conhecimento" Ft340ExeObj() 	 //"Abre objeto"
endif

n := 1

BOW->(DbSetOrder(1))
If BOW->(MsSeek(xFilial("BOW") + M->BOW_PROTOC))
	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()
	MaWndBrowse(0       ,0,300     ,60      ,cCadastro,"BOW",,aRotina,,"'"+xFilial('BOW')+M->BOW_PROTOC  +"'","'"+xFilial('BOW')+M->BOW_PROTOC  +"'",.F.,,,{{STR0258,1}},xFilial('BOW')+M->BOW_PROTOC) //"Conhecimento Protocolo de Reembolso"
	  
	//VERIFICAR OBJETOS ACB E ENVIAR PARA PASTA DE DOWNLOAD DE ANEXO PORTAL
	If lDownload
		cChave := xFilial("BOW")+BOW->(BOW_OPEUSR+BOW_PROTOC)
		PLCPDWREE(cChave)
	EndIf
	
Else
	MsgAlert( STR0301 , STR0049 )//"Opção não disponível na inclusão. Na inclusão, ao finalizar o cadastro será apresentada a opção de cadastrar anexos"  , "Atenção"
EndIf

aRotina := aClone(aBkRotina)

//Reativa a tecla de atalho
SetKey(VK_F7,  {|| P001ACONH(nOpc)}) //Anexos 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLCPDWREE
Copia os arquivos recem adicionados no protocolo de reembolso para a pasta de download do portal
@author Francisco Edcarlo
@since 20/04/2017
@version P12
/*/
//-------------------------------------------------------------------
Function PLCPDWREE(cChave) 
Local cDirDocs := ""
Local cDir := getWebDir()
Local cDownload := SuperGetMV("MV_RELT")

Default cChave := ""

If !Empty(cChave)
	AC9->(DbSetOrder(2))//AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
	ACB->(DbSetOrder(1))//ACB_FILIAL+ACB_CODOBJ
	If (AC9->(MsSeek(xFilial("AC9")+"BOW"+xFilial("BOW")+cChave)))
		While !AC9->(Eof()) .AND. AC9->(AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT) = xFilial("AC9")+"BOW"+xFilial("BOW")+cChave
			If ACB->(MsSeek(xFilial("ACB")+AC9->AC9_CODOBJ))
				If !File(PLSMUDSIS(cDownload +"\"+ ACB->ACB_OBJETO))
				
					If FindFunction( "MsMultDir" ) .And. MsMultDir()
						cDirDocs := MsRetPath( ACB->ACB_OBJETO )
					Else
						cDirDocs := MsDocPath()
					Endif
					
					Processa( { || __COPYFILE( PLSMUDSIS(cDirDocs + "\" + ACB->ACB_OBJETO), PLSMUDSIS(cDownload + "\" + ACB->ACB_OBJETO) ),lRet := File( PLSMUDSIS(cDownload + "\" + ACB->ACB_OBJETO) ) }, "Transferindo objeto","Aguarde...",.F.)
					
				EndIf
			EndIf
			AC9->(DbSkip())
		EndDo
	EndIf
EndIf

Return

/*/{Protheus.doc} PLSVLPRLB
valida se o evento e valido na pre-autorizacao
@type function
@author PLSTEAM
@since 20.04.00
@version 1.0
/*/
function PLSVLPRLB()
local lRet := .t.

if B1N->(fieldPos("B1N_NUMLIB")) > 0
	
	if ! empty(M->B1N_NUMLIB)
		
		BE2->(dbSetOrder(6))
		If BE2->(dbSeek(xFilial ("BE2") + M->B1N_NUMLIB + M->B1N_CODPAD + M->B1N_CODPRO))
			
			If BE2->BE2_SALDO < M->B1N_QTDPRO
				MsgInfo(STR0277 + CVALTOCHAR(BE2->BE2_SALDO) + STR0278)
				lRet := .F.
			EndIf
		Else
			
			MsgInfo(STR0279)
			lRet := .F.
		EndIf
	EndIf
endIf

return(lRet)

/*/{Protheus.doc} PLSPREREV
Realiza a Validação se pode reverter.
@author Roberto Arruda
@since 05/02/2016
@version P12
/*/
Function PLSPREREV()
Local lTituloBaixado := .F.
Local cTipoTit := GetNewPar("MV_PLRESE1","1") 
Local cAliasFin	:= ""
If cTipoTit == "0" //a busca será no título a pagar
	cAliasFin	:= "SE2"
Else
	cAliasFin	:= "SE1"
EndIf	

If FieldPos("BOW_TIPCAN") > 0
	If (MsgYesNo(STR0280)) //"Atenção. Este protocolo já foi autorizado e pago, tem certeza que deseja prosseguir com a reversão do processo?"
		B44->(DbSetOrder(4))
		If B44->(DbSeek(xFilial ("B44") + BOW->BOW_PROTOC))
			(cAliasFin)->(DbSetOrder(1))
			If (cAliasFin)->(DbSeek(xFilial(cAliasFin) + B44->B44_PREFIX + B44->B44_NUM + B44->B44_PARCEL + B44->B44_TIPO))
				If cAliasFin == "SE1"
					lTituloBaixado := SE1->E1_SALDO == 0
				Else
					lTituloBaixado := SE2->E2_SALDO == 0
				EndIf
			EndIf
		EndIf
		
		If (BOW->BOW_STATUS = '6' .And. Empty(BOW->BOW_PROCLO) .And. lTituloBaixado) //Verificando se o protocolo pode ser revertido.
			PLSSENSUP()
		Else
			MsgInfo(STR0282 + '-' + BOW->BOW_STATUS)
		EndIf
	EndIf
Else
	MsgInfo("É necessário a atualização do sistema para a expedição mais recente.") //É necessário a atualização do sistema para a expedição mais recente.
EndIf

Return

/*±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSSENSUP   ºAutor  ³Roberto Arruda   º   Data ³  05/02/16º	 ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ	¹±±
±±ºDesc.     ³ Tela para informar a senha do supervisor.					 ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

function PLSSENSUP()

LOCAL oSay         := NIL
LOCAL oDlg		  := NIL
LOCAL cSenhaAc   	:= Space(15)
LOCAL bOK     := {|| Iif(!Empty(cSenhaAc) .And. PLSGETSSUP(cSenhaAC), PLSREVREE(), /*MsgStop(STR0285)*/ MsgStop(STR0285)), oDlg:End()}//"Senha inválida."
local cUsuSup := PswRet( 1 )[1][11]
local cTitulo := 'Senha do supervisor ' + cUsuSup
LOCAL bCancel    	:= {|| nOpca := 0,oDlg:End() }

DEFINE MSDIALOG oDlg TITLE STR0284 FROM 009,000 TO 018,050 //019,050// 050,100  //FROM 005.0,07.3 TO 06.4,8.3

@ 040,005  SAY 	oSay PROMPT STR0286  	SIZE 190,050 			OF oDlg PIXEL 	COLOR CLR_RED //"Autoriza a reversão deste protocolo de reembolso ?"
@ 038,060 MSGET cSenhaAc    		SIZE 035,006 			OF oDlg PIXEL 	PASSWORD

ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.F.) } )
return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSGETSSUP ³ Autor ³ Roberto Arruda        ³ Data ³ 08.02.16³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSGETSSUP(cSenDigit)

local aUsuSup := StrTokArr(PswRet( 1 )[1][11], '|')


Return(iif(len(aUsuSup) > 0, BSProtheus(/*PLSRtCdUsr()*/aUsuSup[1],cSenDigit), .F.))

Static Function BSProtheus(cIdUser,cSenDigit)

LOCAL lRet := .F.

If ExistBlock("PLBSPROT")
	lRet := Execblock("PLBSPROT",.F.,.F.,{cIdUser,cSenDigit})
Else
	PswOrder(1)
	If PswSeek(cIdUser)
		lRet := PswName(cSenDigit)
	endif
Endif

Return( lRet )


/*±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSREVREE   ºAutor  ³Roberto Arruda   º   Data ³  05/02/16º	 ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ	¹±±
±±ºDesc.     ³ Realiza a reversão do reembolso.								 ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßißßßßßßßßßßßßßßßßßßßßßß*/

function PLSREVREE()
lRever := .T.
INCLUI := .T.
PLBOWMOV("BOW",Recno(),K_Incluir)
return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS001ADPG
Tela para que o usuário informe a data de pagamento (B44_DATPAG)
@author Oscar Zanin
@since 05/03/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLS001ADPG()

LOCAL oFont
LOCAL oDlg
Local dData		:= StoD("  /  /    ")
LOCAL nOpca		:= 0
Local aRetorno 	:= {}
Local lStatus		:= .F.

//Define a Fonte do Objeto
DEFINE FONT oFont NAME "Arial" SIZE 000,-012 BOLD

//Cria a Dialog para interação do usuário
DEFINE MSDIALOG oDlg TITLE STR0288 /*"Informe a data de pagamento"*/ FROM 008.2,003.3 TO 020,055 OF GetWndDefault()

//Campo Login
@ 20,61 Say oSay PROMPT STR0289 /*"Para Prosseguir a geração, "*/ SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
@ 30,60 Say oSay PROMPT STR0290 /*"Informe a data de pagamento"*/ SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
@ 43,65 MSGET oGet1 VAR dData SIZE 070,10 OF oDlg FONT oFont PIXEL

//Botão Confirmar
TButton():New(65,080, STR0291 /*'Confirmar'*/,,{|| Iif( PLS001VPRI(dData, @lStatus) /*pré-validação e definição se houve interação com o botão confirmar*/, Eval( {|| nOpca:=1,oDlg:End() } ),Eval( {|| PLS001CONF(dData) /*Gera alertas, caso encontre divergências no preenchimento*/,.F.} ) ) },040,012,,,,.T.)

//Ativa a Dialog
ACTIVATE MSDIALOG oDlg CENTERED

//Grava retorno
AAdd(aRetorno, dData)
AAdd(aRetorno, lStatus)

Return(aRetorno)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS001VPRI
Validação Geral
@author Oscar Zanin
@since 05/03/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLS001VPRI(dData, lStatus)

Local lRet := .F.

If (!Empty(dData))
	
	lRet := .T.
	
EndIf

lStatus := lRet

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS001CONF
Alerta ao usuário
@author Oscar Zanin
@since 05/03/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLS001CONF(dData)

Local lErro := .T.

If Empty(dData) //Verifica se foi informada a data
	
	MsgInfo(STR0292) //"Data não informada!"
	lErro := .F.
	
EndIf

Return (lErro)

/*/{Protheus.doc} PLB1NPROC
Funcao para validar se o procedimento tem composição na tabela de reembolso
da operadora
@author Oscar Zanin
@since 08/03/2016
@version P12
/*/
Function PLB1NPROC()
Local lRet 	    := .F.
Local cCodInt   := PLSINTPAD()
Local cTabRee   := ""
Local cCodPad   := M->B1N_CODPAD
Local cCodPro   := M->B1N_CODPRO
Local aRet      := {}
Local lVaBA0B7T := GETNEWPAR("MV_BA0B7T",.T.) 

If EMPTY(M->BOW_USUARI)
	MsgAlert("Para inclusão de item é necessário o preenchimento do campo Beneficiário no protocolo!") 
	RETURN(lRet)
Endif

BA0->(DbSetOrder(1))
If BA0->(MsSeek(xFilial("BA0")+cCodInt))
	cTabRee := BA0->BA0_TBRFRE
EndIF

//Parâmetro para que atenda a CEMIG caso verdadeiro e falso pra outros clientes que precisam 
//que os níveis sejão respeitados dentro do PLSRETTAB
If lVaBA0B7T
	If !(EmpTy(cTabRee))
		BD4->(DbSetOrder(1))
		IF BD4->(MsSeek(xFilial("BD4")+cCodInt+cTabRee+cCodPad+cCodPro))
			lRet := .T.
			PLSA001AGAT(,,,,,,,,,,,M->B1N_EST,M->B1N_CODMUN) 
		EndIf
	EndIf

	If !lRet .and. PlsAliasExi("B7T")
		B7T->(DbSetOrder(1))
		If B7T->(DbSeek(xFilial("B7T")+cCodInt))
			while B7T->B7T_CODINT == cCodInt
				If !Empty(B7T->B7T_TABREE)
					
					IF BD4->(MsSeek(xFilial("BD4") + cCodInt + B7T->B7T_TABREE + cCodPad + cCodPro))
						lRet := .T.
						PLSA001AGAT(,,,,,,,,,,,M->B1N_EST,M->B1N_CODMUN) 
						Exit //Encontrou na primeira tabela, sai do while
					EndIf
				EndIf
				
				B7T->(DbSkip())
			enddo
		EndIf
	EndIf
Else
	lRet := .T.
	PLSA001AGAT(,,,,,,,,,,,M->B1N_EST,M->B1N_CODMUN)	
EndIf 

If !lRet
	MsgAlert(STR0293) //"Não foi encontrada a composição do procedimento na Tabela de reembolso da Operadora"
else
	IF ValType(oBrwComp) <> "U"
		oBrwComp:ForceRefresh()
	Endif
EndIF

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLBLOQREEM
Função para validar se a data do procedimento indicado no reembolso é superior ou não a data de bloqueio do usuario.
@author Lucas Nonato
@since 10/03/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLBLOQREEM(cMatric, dDtDoc )
Local lRet    := .T.
Local cSQL	  :=""
Local aRetInt :={}
Local aCriti  :={}
Local cFunNa  := funName()
Local lVldBlq := GETNEWPAR("MV_PLSRBLQ",.T.)
DEFAULT cMatric := ''

//Se o beneficiário indicado não for da família, já retorno crítica
//limita a escolha do usuário em uma correta.
If cFunNa == "PLSA001A"	
	If Left(Alltrim(cMatric), 14) != Left(Alltrim(M->BOW_USUARI), 14)
		MsgStop("Beneficiário não pertence à mesma família do Titular do reembolso!")
		Return .F.
	EndIf
EndIf

aRetInt := PLSA090USR(cMatric,dDtDoc,'','B1N',.T.,.F.,,,,,,,,,,,,,,,,,,,lVldBlq) 

If Valtype(aRetInt) != "L" 
	If ! (aRetInt[1]) .OR. ( len(aRetInt) > 6 .AND. aRetInt[7] == 'Paciente encontra-se Bloqueado')//Colocado esta validação, pois a critica de paciente encontra-se bloqueado altera o retorno do array aRetInt[1]
		
		lRet := .F.
		
		IF len(aRetInt[2]) > 0 .And. cFunNa == "PLSA001A"
			PLSMOVCRI("2",{},aRetInt[2])
			lRet := aRetInt[1]
		Endif	

	Endif
EndIf
return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSREINT ³ 						     ³ Data ³ 06.01.2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna as internação dentro do período de data passado por³±±
±±³parâmetro							                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSREINT(cNumint, cDatExec, cMatric, lTodasInt, lCampo, cAlias)

LOCAL cWhr     := ""
LOCAL cSQL     := ""
LOCAL aInterna := {}
LOCAL oDlg     := NIL
LOCAL aObjects := {}
LOCAL aInfo    := {}
LOCAL aPosObj  := {}
LOCAL oGetGrid := NIL
LOCAL bOK	   := {|| nOpca := 1,oDlg:End()  }
LOCAL bCancel  := {|| oDlg:End()}
LOCAL aButton  := {}
LOCAL nOpca	   := 0
LOCAL aHeadB1N := {}

DEFAULT lCampo    := .F.
DEFAULT lTodasInt := .F.

//variável statica utilizada na função PLEXECCPO
__lConfma := .T.

//Esta função está sendo chamada no confirmar da tela ou em um campo.
//no caso do confirmar, o sistema não irá retornar um array com mais de uma posição
//pois nos campos de número da internação sempre gravará a internação mais antiga e
//caso ja esteja preenchido o campo, não é mais necessário execeutar a query novamente.

// o parâmetro lCampo foi criado para o caso dos campos, cada vez que o usuário preencher o
//campo de data de execução, o sistema terá que atualizar o campo do número da internação,
//destá forma mesmo com o cNumint deverá executar a query e retornar os dados atualizados.
//dos campos de memória.

If EMPTY(cNumint) .OR. lCampo
	
	If AllTrim( TCGetDB() ) == "ORACLE"  .OR. AllTrim( TCGetDB() ) == "POSTGRES" 
		cSQL := " SELECT BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT, BE4_DATPRO, BE4_DTALTA FROM " + RetSQLName("BE4")
		cWhr := " WHERE BE4_FILIAL= '" + xFilial("BE4") + "' AND  (BE4_CODOPE||BE4_CODEMP||BE4_MATRIC||BE4_TIPREG||BE4_DIGITO) = '" + cMatric + "' "
		cWhr += " AND BE4_DATPRO <> '' AND BE4_DATPRO <= '" + cDatExec + "' AND BE4_DTALTA = ' ' AND D_E_L_E_T_ = ''"
		cWhr += " OR BE4_FILIAL= '" + xFilial("BE4") + "' AND  (BE4_CODOPE||BE4_CODEMP||BE4_MATRIC||BE4_TIPREG||BE4_DIGITO) = '" + cMatric + "'
		cWhr += " AND BE4_GUIINT = '' AND BE4_DATPRO <> '' AND BE4_DATPRO <= '" + cDatExec + "' AND BE4_DTALTA >= '" + cDatExec + "'  AND D_E_L_E_T_ = ''"  //
		cWhr += " ORDER BY BE4_DATPRO"
	Else
		cSQL := " SELECT BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT, BE4_DATPRO, BE4_DTALTA FROM " + RetSQLName("BE4")
		cWhr := " WHERE BE4_FILIAL= '" + xFilial("BE4") + "' AND  (BE4_CODOPE + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG + BE4_DIGITO) = '" + cMatric + "' "
		cWhr += " AND BE4_DATPRO <> '' AND BE4_DATPRO <= '" + cDatExec + "' AND BE4_DTALTA = ' ' AND D_E_L_E_T_ = ''"
		cWhr += " OR BE4_FILIAL= '" + xFilial("BE4") + "' AND  (BE4_CODOPE + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG + BE4_DIGITO) = '" + cMatric + "'
		cWhr += " AND BE4_GUIINT = '' AND BE4_DATPRO <> '' AND BE4_DATPRO <= '" + cDatExec + "' AND BE4_DTALTA >= '" + cDatExec + "' AND D_E_L_E_T_ = ''" //
		cWhr += " ORDER BY BE4_DATPRO"
	Endif
	
	cSQL := ChangeQuery(cSQL + cWhr)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"BE4Query",.F.,.T.)
	
	BE4Query->(dbGoTop())
	
	If !lCampo
		If lTodasInt
			
			WHILE !BE4Query->(EOF())
				AADD(aInterna, {BE4Query->(BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT),;
				STOD(BE4Query->(BE4_DATPRO)),;
				STOD(BE4Query->(BE4_DTALTA))})
				BE4Query->(dbSkip())
			EndDo
		Else
			If !BE4Query->(EOF())
				aInterna := {BE4Query->(BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT),;
				STOD(BE4Query->(BE4_DATPRO)),;
				STOD(BE4Query->(BE4_DTALTA))}
			EndIf
		EndIf
	Else
		
		count To nQuant
		BE4Query->(dbGoTop())
		
		If nQuant == 1
			&("M->"+cAlias+"_GUIPRI") := BE4Query->(BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT)
			&("M->"+cAlias+"_INTDE")  := STOD(BE4Query->(BE4_DATPRO))
			&("M->"+cAlias+"_INTATE") := STOD(BE4Query->(BE4_DTALTA))
			
		ElseIf nQuant > 1
			
			//para os casos onde exista mais de uma internação no período informado na data de execução
			//o usuário poderá selecionar a internação correspondente.
			
			BE4Query->(DbGoTop())
			
			WHILE !BE4Query->(EOF())
				AADD(aInterna, {BE4Query->(BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT),;
				STOD(BE4Query->(BE4_DATPRO)),;
				STOD(BE4Query->(BE4_DTALTA)),;
				.F.})
				
				BE4Query->(dbSkip())
			EndDo
			
			//Store Header "B1N" TO aHeadB1N For ( AllTrim(SX3->X3_CAMPO) $ "B1N_GUIPRI,B1N_INTDE,B1N_INTATE" )
			aAdd(aHeadB1N,{"Num. Internacao", "B1N_GUIPRI", "", 18, 0, , ,"C", ,"R", , , ,"V", , ,.T.})
			aAdd(aHeadB1N,{"Dt Intern De", "B1N_INTDE ", "", 8, 0, , ,"D", ,"R", , , ,"V", , ,.T.})
			aAdd(aHeadB1N,{"Dt Inter Ate", "B1N_INTATE ", "", 8, 0, , ,"D", ,"R", , , ,"V", , ,.T.})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ajusta tamanho dos objetos.                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSize := MsAdvSize()
			AAdd( aObjects, { 010, 050, .T., .F. } )
			AAdd( aObjects, { 010, 100, .T., .T. } )
			
			aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
			aPosObj := MsObjSize( aInfo, aObjects )
			
			nLarg 		:= aPosObj[1,4]*0.5 + 5
			nTop 		:= aPosObj[1,1] - 4
			nLeft 		:= aPosObj[1,2] - 4
			nBottom	    := aPosObj[1,3]*2.2
			
			DEFINE MSDIALOG oDlg TITLE "Internações em aberto" FROM aSize[7],0 To aSize[4],aSize[3] OF GetWndDefault() Pixel
			DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
			
			oGetGrid := MSNewGetDados():New(nTop, nLeft, nBottom, nLarg, /*[nStyle]*/, "AlwaysTrue()", "AlwaysTrue()", "" , {}, 0, 9999, "AlwaysTrue()", "AlwaysTrue()", "AlwaysTrue()", oDlg, aHeadB1N, aInterna, , "" )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ativa o Dialogo...                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,bOK,bCancel,.F.,aButton)  })
			
			If nOpca == K_OK
				&("M->"+cAlias+"_GUIPRI") := oGetGrid:acols[oGetGrid:nat][1]
				&("M->"+cAlias+"_INTDE")  := oGetGrid:acols[oGetGrid:nat][2]
				&("M->"+cAlias+"_INTATE") := oGetGrid:acols[oGetGrid:nat][3]
			EndIf
			
		Else
			&("M->"+cAlias+"_GUIPRI") := Space(TamSx3(cAlias+"_GUIPRI")[1])
			&("M->"+cAlias+"_INTDE")  := STOD(Space(TamSx3(cAlias+"_INTDE" )[1]))
			&("M->"+cAlias+"_INTATE") := STOD(Space(TamSx3(cAlias+"_INTATE")[1]))
		EndIf
	EndIf
	
	BE4Query->(dbCloseArea())
EndIf

//variável statica utilizada na função PLEXECCPO
__lConfma :=  .F.

Return If(lCampo, .T., aInterna)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLEXECCPO ³ 						     ³ Data ³ 06.01.2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função utilizada no valid do campo para executar a função  ±±³
±±³PLSREINT pois o tamanho do valid não comporta o tamanho da função	  ±±³
±±³junto com os parâmetros.		    	 								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLEXECCPO(cAlias)

LOCAL cNumInter  := &("M->"+cAlias+"_GUIPRI")
LOCAL cDatExec   := DTOS(&("M->"+cAlias+"_DATPRO"))
LOCAL cMatric	 := &("M->"+cAlias+"_MATRIC")

If EMPTY(cMatric)
	MsgAlert(STR0294) //"Para que o sistema possa identificar internações no período da data de execução preencha a matrícula do beneficiário."
EndIf

If !EMPTY(cDatExec) .AND. !EMPTY(cMatric)
	
	/*a variável static é necessária para o caso do usuário clicar em confirmar
	após selecionar a data de execução, quando clica em confirmar a tela executa duas
	vezes a função PLEXECCPO criando dois objetos de grid e quando seleciona um registro
	no grid e clica em confirmar a tela não é fechada, com o lconfirma a função é executada
	uma vez.*/
	If !__lConfma
		PLSREINT(cNumInter, cDatExec, cMatric,, .T., cAlias)
	EndIf
EndIf

Return .T.




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSDTINT³ Autor ³ 		               ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Validação das Datas de Internação e de Alta		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function PLSDTINT()
Local lRet := .T.

If !EMPTY(M->B1N_DATPRO) .AND. !EMPTY(M->B1N_INTATE)
	If M->B1N_DATPRO > M->B1N_INTATE .OR. M->B1N_DATPRO<M->B1N_INTDE
		Alert("Data do Procedimento informado é Inválida para Guia Principal de Internação selecionada.")
		lRet := .F.
	Endif
	
Endif

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLVALDTLI ³ 						     ³ Data ³ 12.04.2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função utilizada para validar a data limite para solicitar ³±±
um reembolso		    	 								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLVALDTLI(cAlias)

LOCAL dDatExec   := &("M->"+cAlias+"_DATPRO")
LOCAL cMatric	 := &("M->"+cAlias+"_MATRIC")
LOCAL nDiasTlr   := 0
LOCAL lRet		 := .T.
LOCAL dDtDigi    := IIF(cAlias == "B1N",M->BOW_DTDIGI,M->B44_DTDIGI) // Se Alias = B1N, Dt. Digitação é BOW_DTDIGI
																	 // Se Alias = B45, Dt. Digitação é B44_DTDIGI
If !EMPTY(cMatric) .AND. !EMPTY(dDatExec)
	
	// ****** NUMERO DE DIAS DE TOLERANCIA A PARTIR DA DATA DO DOCUMENTO PARA SOLIC.
	BA3->(DbSetOrder(1))
	BA3->(MsSeek(xFilial("BA3")+SubStr(cMatric,1,14)))
	
	BI3->( DbSetOrder(1) )//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
	BI3->(MsSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
	
	nDiasTlr := BI3->BI3_MXDRMB
	
	If nDiasTlr > 0
		
		If dDatExec < (dDtDigi - nDiasTlr)  //
			
			msgAlert(STR0295, STR0004) //"O documento já atingiu a data limite para solicitação do reembolso."##Reembolso
			lRet := .F.
		EndIf
	EndIf
	
	If dDatExec > dDataBase
		
		msgAlert(STR0296, STR0004) //"Data de execução superior a data de hoje."## Reembolso
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDB1N
Funcao para validação de campos
@author Mário A. Cavenaghi
@since 01-08-2016
@version P12
/*/
//-------------------------------------------------------------------
FUNCTION VLDB1N

LOCAL lRet := .T.

IF BBS->BBS_OBRIGA == "1" .AND. EMPTY(M->B1N_NUMDOC)
	lRet := .F.
	SX3->(DBSETORDER(2))
	SX3->(DBSEEK("B1N_NUMDOC"))
	MSGALERT(STR0130 + ": " + X3TITULO())
ELSEIF BBS->BBS_OBRIGA <> "1" 
	M->B1N_NUMDOC := SPACE(LEN(M->B1N_NUMDOC))
ENDIF

RETURN(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSANXEC
Abre uma pergunta se o usuário deseja incluir o anexo na inclusão do  cadastro de Protocolo
@author Saude
@since 02/08/2016
@version P12
/*/
//-------------------------------------------------------------------
Static function PLSANXEC(nOpc)
Local lRet := .T.

If BOW->BOW_STATUS =="1" .and. nOpc == K_Incluir 
	If MsgYesno("Deseja Anexar os arquivos agora?")//Deseja Anexar os arquivos agora?
	P001ACONH()
EndIf
Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVLDTP 
Rotina para validação do tipo de documento no protocolo de reembolso.
 Função executa no X3_WHEN do campo B1N_NUMDOC
@author Saude
@since 08/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLVLDTP()

LOCAL lRet :=.T.           
                                                       
BBS->(DbsetOrder(2))                          
If BBS->(MsSeek(xFilial("BBS") + M->B1N_TIPDOC))
   
   If BBS->BBS_OBRIGA != "1"
      
	  M->B1N_NUMDOC := Space(Len(B1N->B1N_NUMDOC))      
      lRet:=.F.      
   EndIf
EndIf                                                                      

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} P001AIndef 
Retorna array com procedimentos indeferidos do protocolo de reembolso selecionado para emissão de protocolo de negativa

@author Rodrigo Morgon
@since 20/10/2016
@version P12
/*/
//-------------------------------------------------------------------
Function P001AIndef(aDadosProt)

local aProcIndef	:= {}

local aRet 	:= {}
local aObs 	:= {}
local aProced	:= {}
local dDtGui 	:= ""
Local lPl773Obs := ExistBlock("PL773OBS")

DEFAULT aDadosProt := {}

BOW->(DbSetOrder(1))
if BOW->(DbSeek(xFilial("BOW")+B00->B00_COD)) .and. BOW->BOW_STATUS $ "4,C"
	
	dDtGui := BOW->BOW_DTDIGI
	
	if Empty(BOW->BOW_DTDIGI)
		if !Empty(B00->B00_DTATEN)
			dDtGui := B00->(MIN(B00_DTATEN, B00_DTPROT))	//	Data do Atendimento
		else
			dDtGui := B00->B00_DTPROT
		endif
	endif

	aRet := {dDtGui} //Data do atendimento do protocolo

	//Buscar todos os procedimentos que foram indeferidos no protocolo
	B1N->(DbSetOrder(1))
	if B1N->(DbSeek(xFilial("B1N")+BOW->BOW_PROTOC))
		While B1N->B1N_PROTOC == BOW->BOW_PROTOC .and. !B1N->(EoF())
		
			//Só adiciona procedimentos indeferidos
			if AllTrim(B1N->B1N_IMGSTA) == 'DISABLE'
				aProced := {}
				aAdd(aProced,B1N->B1N_CODPAD + ' - ' + B1N->B1N_CODPRO)
				aAdd(aProced,posicione("BR8",1,xFilial("BR8")+B1N->B1N_CODPAD + B1N->B1N_CODPRO,"BR8_DESCRI"))
				aAdd(aProced,B1N->B1N_QTDPRO)
				aAdd(aProced,{BOW->BOW_MOTIND}) //Criticas - vazio
				aAdd(aProced,"0")			
				
				//Adiciona observação do ponto de entrada
				If lPl773Obs
					aObs := ExecBlock( "PL773OBS", .F., .F., {aProced} )
					If ValType(aObs) == "A"
						aAdd( aProced,aObs )
					Else
						Help("",1,"PLSA773OBS")
					Endif
				EndIf	
						
				AADD(aRet, aProced)
			endif
			
			B1N->(DbSkip())
		EndDo
	endif
endif

Return(aRet)

/*/{Protheus.doc} PL001ABRW
//Funcao criada para retornar o oBrwPro para ser usada em outras funcoes
@author romulo.ferrari
@since 08/12/2016
@version undefined
/*/
Function PL001ABRW() 
Return (oBrwPro)

/*/{Protheus.doc} GExpExcel
//Gera um arquivo com todas as autorizações de retorno da aprovação de reembolso
/*/
Function GExpExcel(aDadAut) 

Local oFWMsExcel
Local cFile    := cGetFile('Arquivo *|*.*|Arquivo XML|*.XML','Retorna Diretorio',0,'C:\',.T.,GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
Local cArquivo := 'AprovaReemb_' + StrTran( DTOC(DDATABASE), "/", "-" ) + ".XML" 
Local nX       := 0
Local nLenDado := Len(aDadAut)	
     
oFWMsExcel := FWMSExcel():New()
oFWMsExcel:AddworkSheet("Aba 1") 
oFWMsExcel:AddTable("Aba 1","Relatório de Conferencia")
oFWMsExcel:AddColumn("Aba 1","Relatório de Conferencia","Numero de Autorização",1,1) 
oFWMsExcel:AddColumn("Aba 1","Relatório de Conferencia","Usuário",2,2) 
oFWMsExcel:AddColumn("Aba 1","Relatório de Conferencia","Título/Fatura",3,3) 
oFWMsExcel:AddColumn("Aba 1","Relatório de Conferencia","Protoc. Vinculado",1,1)
oFWMsExcel:AddColumn("Aba 1","Relatório de Conferencia","Status",1,1)

//Adicionando as linhas        
For nX:= 1 To nLenDado			
	oFWMsExcel:AddRow("Aba 1","Relatório de Conferencia",{aDadAut[nX,1],aDadAut[nX,2],aDadAut[nX,3],aDadAut[nX,4],aDadAut[nX,5]})
Next        
     
//Ativando o arquivo e gerando o xml
oFWMsExcel:Activate()
oFWMsExcel:GetXMLFile(Alltrim(cFile + cArquivo))

if !Empty(cFile)
	MsgAlert("Arquivo Gerado com sucesso!" + CHR(10)+ CHR(13) + cFile + cArquivo)
Endif         
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLCHKDUBRW
Validação de duplicidade dos itens na tela
@author Karine Riquena Limp
@since 28/03/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLCHKDUBRW( cTipDoc, cCpfCnpj, cMatric, cCodPad, cCodPro, cNumDoc, cDatDoc, cVlrApr, cCodRef, cDatExc)
local lRet  := .T.
Local nCont := 0
Local lDocObr := .T.
Local lVlrTot    := B1N->(FieldPos("B1N_VLRTOT")) > 0 
Local nPosTipDoc := oBrwPro:PLRETPOS("B1N_TIPDOC")
Local nPosCnpj   := oBrwPro:PLRETPOS("B1N_PRCNPJ")
Local nPosMatric := oBrwPro:PLRETPOS("B1N_MATRIC")
Local nPosCodPad := oBrwPro:PLRETPOS("B1N_CODPAD")
Local nPosCodPro := oBrwPro:PLRETPOS("B1N_CODPRO")
Local nPosNumDoc := oBrwPro:PLRETPOS("B1N_NUMDOC")
Local nPosDatDoc := oBrwPro:PLRETPOS("B1N_DATDOC")
Local nPosCodRef := oBrwPro:PLRETPOS("B1N_CODREF")
Local nPosDatExc := oBrwPro:PLRETPOS("B1N_DATPRO")

Local nPosVlrApr := iif(lVlrTot, oBrwPro:PLRETPOS("B1N_VLRTOT"), oBrwPro:PLRETPOS("B1N_VLRAPR"))
Local cChave := ""
Local cComp  := ""
Local nLenCols := len(oBrwPro:aCols)

Default cCodRef := ""
Default cDatExc := ""

BBS->(DbSetOrder(2))
If BBS->(DbSeek(xFilial("BBS")+cTipDoc))
	lDocObr := BBS->BBS_OBRIGA == "1"
EndIf

cChave := Alltrim(cTipDoc) + Alltrim(cMatric) + Alltrim(cCodPad) + Alltrim(cCodPro) + Alltrim(cDatDoc) + Alltrim(cCodRef)

if lDocObr
	cChave += Alltrim(cNumDoc)
else
	cChave += Alltrim(cVlrApr)
endIf

if !Empty(cDatExc)
	cChave += Alltrim(cDatExc)
endIf

	
For nCont := 1 To nLenCols
	If ((inclui .and. oBrwPro:LINADDLINE)  .OR. (oBrwPro:oBrowse:nAt <> nCont))	
	
		cComp := Alltrim(oBrwPro:aCols[nCont,nPosTipDoc])
		cComp += Alltrim(oBrwPro:aCols[nCont,nPosMatric])
		cComp += Alltrim(oBrwPro:aCols[nCont,nPosCodPad])
		cComp += Alltrim(oBrwPro:aCols[nCont,nPosCodPro])
		cComp += dToS(oBrwPro:aCols[nCont,nPosDatDoc])
		cComp += Alltrim(oBrwPro:aCols[nCont,nPosCodRef])		
		
		if lDocObr
			cComp += Alltrim(oBrwPro:aCols[nCont,nPosNumDoc])
		else 
			cComp += Alltrim(str(oBrwPro:aCols[nCont,nPosVlrApr]))
		endIf

		if !Empty(cDatExc)
			cComp +=  dToS(oBrwPro:aCols[nCont,nPosDatExc])
		EndIF

		If cComp == cChave .and. (Alltrim(oBrwPro:aCols[nCont,nPosCnpj]) == Alltrim(cCpfCnpj) .OR. (!empty(cCodRef) .and. Alltrim(oBrwPro:aCols[nCont,nPosCodRef]) == alltrim(cCodRef)))
			lRet := .F. 
			Exit
		EndIf
		
	endIf
Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS001EXC
Validação na exclusão da linha
@author Fábio Siqueira dos Santos
@since 04/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Function PLS001EXC(nOpc)

Local lDelOpc	 := .F.
Local nPosProtoc := oBrwPro:PLRETPOS("B1N_PROTOC")
Local nPosCodPad := oBrwPro:PLRETPOS("B1N_CODPAD")
Local nPosCodPro := oBrwPro:PLRETPOS("B1N_CODPRO")
Local nPosSequen := oBrwPro:PLRETPOS("B1N_SEQUEN")
Local nPProtoB7M := oBrwComp:PLRETPOS("B7M_PROTOC")
Local nPCodPaB7M := oBrwComp:PLRETPOS("B7M_CODPAD")
Local nPCodPrB7M := oBrwComp:PLRETPOS("B7M_CODPRO")
Local nPSequeB7M := oBrwComp:PLRETPOS("B7M_SEQUEN")
Local nCont		 := 0
Local lRet		 := .T.
Local nAcols     := 0 
Local nComp		 := 0 

If nOpc == 1 //Eventos
	If !oBrwPro:aCols[oBrwPro:obrowse:nAt,Len(oBrwPro:aHeader)+1]
		lDelOpc := .T.
	Else
		lDelOpc := .F.
	EndIf
	
	For nCont := 1 To Len(oBrwComp:aCols)     
		If oBrwComp:aCols[nCont,nPProtoB7M] == oBrwPro:aCols[oBrwPro:obrowse:nAt,nPosProtoc] .And.;
		   oBrwComp:aCols[nCont,nPCodPaB7M] == oBrwPro:aCols[oBrwPro:obrowse:nAt,nPosCodPad] .And.;
		   oBrwComp:aCols[nCont,nPCodPrB7M] == oBrwPro:aCols[oBrwPro:obrowse:nAt,nPosCodPro] .And.;
		   oBrwComp:aCols[nCont,nPSequeB7M] == oBrwPro:aCols[oBrwPro:obrowse:nAt,nPosSequen]
	
				oBrwComp:aCols[nCont,Len(oBrwComp:aCols[nCont])] := lDelOpc
				oBrwComp:ForceRefresh()
		EndIf
	Next

Else//Composição
	
	If oBrwComp:aCols[oBrwComp:obrowse:nAt,Len(oBrwComp:aHeader)+1]	

		For nCont := 1 To Len(oBrwPro:aCols)     

			If oBrwComp:aCols[oBrwComp:obrowse:nAt,nPProtoB7M] == oBrwPro:aCols[nCont,nPosProtoc] .And.;
			   oBrwComp:aCols[oBrwComp:obrowse:nAt,nPCodPaB7M] == oBrwPro:aCols[nCont,nPosCodPad] .And.;
			   oBrwComp:aCols[oBrwComp:obrowse:nAt,nPCodPrB7M] == oBrwPro:aCols[nCont,nPosCodPro] .And.; 
			   oBrwComp:aCols[oBrwComp:obrowse:nAt,nPSequeB7M] == oBrwPro:aCols[nCont,nPosSequen] .And.;
			   oBrwPro:aCols[nCont,Len(oBrwPro:aHeader)+1] 
		
					MsgInfo(STR0306,STR0049)//"Não será possível manter a composição, pois o procedimento está excluído!"#"Atenção"
					lRet := .F.
					EXIT 

			ElseIf oBrwComp:aCols[oBrwComp:obrowse:nAt,nPProtoB7M] == oBrwPro:aCols[nCont,nPosProtoc]  .And.;
				   (oBrwComp:aCols[oBrwComp:obrowse:nAt,nPCodPaB7M] == oBrwPro:aCols[nCont,nPosCodPad] .And.; 
				   oBrwComp:aCols[oBrwComp:obrowse:nAt,nPCodPrB7M] != oBrwPro:aCols[nCont,nPosCodPro]  .Or. ;
				   oBrwComp:aCols[oBrwComp:obrowse:nAt,nPCodPaB7M] != oBrwPro:aCols[nCont,nPosCodPad]  .And.; 
				   oBrwComp:aCols[oBrwComp:obrowse:nAt,nPCodPrB7M] != oBrwPro:aCols[nCont,nPosCodPro]) .And.;
				   oBrwComp:aCols[oBrwComp:obrowse:nAt,nPSequeB7M] == oBrwPro:aCols[nCont,nPosSequen]

						MsgInfo(STR0310,STR0049)//"Não será possível manter a composição pois o procedimento foi alterado"#"Atenção"
						lRet := .F.
						EXIT 
			EndIf
		Next	
	Else

		FOR nAcols := 1 To LEN(oBrwComp:aCols) 

			If !oBrwComp:aCols[nAcols][LEN(oBrwComp:aheader) + 1]
				If nComp++ == 2
					EXIT
				EndIf
			EndIf
		NEXT

		If nComp == 1

			MsgInfo(STR0309,STR0049) //"O procedimento necessita de uma composição para que possa ser valorado" ## Atenção
			lRet := .F. 
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PPilhaProc
Retorna a pilha de chamada de um processamento X
@author Rogério Tabosa
@since 05/07/2017
@version P12
/*/
//-------------------------------------------------------------------

Function PPilhaProc(nLinhas, cArquivo)	

Local nFunPilha := 1
Local lFile := .F.
Local cStrRet := ""
    
Default nLinhas := 0    //deixando 0 vai imprimir toda a pilha
Default cArquivo := ""  // nome do arquivo

lFile := !Empty(cArquivo)

if lFile   
    PlsLogFil('---------------------------------------------------------------', cArquivo)
    PlsLogFil('FunName: ' + FunName(), cArquivo)
else
    cStrRet += 'FunName: '  + FunName() + Chr(10) + Chr(13)
endif

//Enquanto houver procname que não estão em branco
While !Empty(ProcName(nFunPilha))

	If lFile
	    //Escrevendo o número do procname e a descrição
		PlsLogFil('ProcName > '   + StrZero(nFunPilha, 6) + ' - ' + ProcName(nFunPilha), cArquivo)
	Else
		cStrRet += 'ProcName > '  + StrZero(nFunPilha, 6) + ' - ' + ProcName(nFunPilha)+Chr(10)+Chr(13)
	EndIf
	
	nFunPilha++
	
	If nLinhas > 0
		If nFunPilha > nLinhas
			Exit
		EndIf
	EndIf
EndDo

Return cStrRet


//Cria o MarkBrowse da glosa de item
Function Mark001GLI(oDlg)
Local aStru		:= {}
Local cArqTrab	:= ""
Local cQuery	:= ""
Local ogloIte   := nil
Local cRealName := ""
Local cMarca    := GetMark()
Local lInverte	:=.F.

B1N->(dbsetOrder(1))

cSql := " Select B1N_CODPAD CODPAD, B1N_CODPRO CODPRO, ' ' OKN, B1N_VLRAPR VLRAPR, B1N_SEQUEN SEQUEN, B1N_MATRIC MATRIC, ' ' DESPRO , ' ' MOTIVO "
 
cSql += " from " + retSqlName("B1N") + " B1N "
cSql += " Where "
cSql += " B1N_FILIAL = '" + xfilial("B1N") + "' AND "
cSql += " B1N_PROTOC = '" + M->BOW_PROTOC + "' AND "
cSql += " B1N_IMGSTA <> 'DISABLE' AND "
cSql += " B1N.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cSql)


Aadd(aStru, {"OKN"   ,'C',2,0})
Aadd(aStru, {"SEQUEN",'C', GetSx3Cache( "B1N_SEQUEN", "X3_TAMANHO"), GetSx3Cache( "B1N_SEQUEN", "X3_DECIMAL")})
Aadd(aStru, {"CODPAD",'C', GetSx3Cache( "B1N_CODPAD", "X3_TAMANHO"), GetSx3Cache( "B1N_CODPAD", "X3_DECIMAL")})
Aadd(aStru, {"CODPRO",'C', GetSx3Cache( "B1N_CODPRO", "X3_TAMANHO"), GetSx3Cache( "B1N_CODPRO", "X3_DECIMAL")})
Aadd(aStru, {"DESPRO",'C', GetSx3Cache( "B1N_DESPRO", "X3_TAMANHO"), GetSx3Cache( "B1N_DESPRO", "X3_DECIMAL")})
Aadd(aStru, {"VLRAPR",'N', GetSx3Cache( "B1N_VLRAPR", "X3_TAMANHO"), GetSx3Cache( "B1N_VLRAPR", "X3_DECIMAL")})
Aadd(aStru, {"MOTIVO",'C', GetSx3Cache( "B14_MOTIVO", "X3_TAMANHO"), GetSx3Cache( "B14_MOTIVO", "X3_DECIMAL")})
Aadd(aStru, {"MATRIC",'C', GetSx3Cache( "B1N_MATRIC", "X3_TAMANHO"), GetSx3Cache( "B1N_MATRIC", "X3_DECIMAL")})


If ogloIte <> Nil
	ogloIte:Delete()
	ogloIte := Nil
Endif

cArqTrab := GetNextAlias()

ogloIte := FWTemporaryTable():New( cArqTrab )
ogloIte:SetFields(aStru)
ogloIte:AddIndex("1", {"SEQUEN","CODPAD","CODPRO"})

//------------------
//Criação da tabela temporaria
//------------------
ogloIte:Create()

cRealName := ogloIte:GetRealName() 

Processa({||SqlToTrb(cQuery, aStru, cArqTrab)})

//Criando as colunas do MsSelect semelhante ao FWTemporaryTable
aCamp	:= {}
AADD(aCamp,{"OKN"			,,"  "			,"@!"					})
AADD(aCamp,{"SEQUEN"		,,GetSx3Cache( "B1N_SEQUEN", "X3_TITULO")	,GetSx3Cache( "B1N_SEQUEN", "X3_PICTURE")	}) 
AADD(aCamp,{"CODPAD"		,,GetSx3Cache( "B1N_CODPAD", "X3_TITULO")	,GetSx3Cache( "B1N_CODPAD", "X3_PICTURE")	}) 
AADD(aCamp,{"CODPRO"		,,GetSx3Cache( "B1N_CODPRO", "X3_TITULO")	,GetSx3Cache( "B1N_CODPRO", "X3_PICTURE")	}) 
AADD(aCamp,{"DESPRO"		,,GetSx3Cache( "B1N_DESPRO", "X3_TITULO")	,GetSx3Cache( "B1N_DESPRO", "X3_PICTURE")	}) 
AADD(aCamp,{"VLRAPR"		,,GetSx3Cache( "B1N_VLRAPR", "X3_TITULO")	,GetSx3Cache( "B1N_VLRAPR", "X3_PICTURE")	}) 
AADD(aCamp,{"MOTIVO"		,,GetSx3Cache( "B14_MOTIVO", "X3_TITULO")	,GetSx3Cache( "B14_MOTIVO", "X3_PICTURE")	}) 

(cArqTrab)->(DbGoTop())

//Buscando a descrição não foi colocado na query devido a BR8 ser muito grande e ter baixa performance
While ! (cArqTrab)->(Eof())

	RecLock(cArqTrab, .F.)
	(cArqTrab)->DESPRO := Alltrim(POSICIONE('BR8',1,XFILIAL('BR8')+ (cArqTrab)->CODPAD + (cArqTrab)->CODPRO,'BR8_DESCRI'))
	MsUnlock()

	(cArqTrab)->(DbSkip())	
Enddo
(cArqTrab)->(DbGoTop())



oMark 		:=   MsSelect():New(cArqTrab,"OKN"  ,'  ',aCamp  ,@lInverte,@cMarca,{55,1,150,370})
oMark:bMark :=   { || Pls001Mark(cArqTrab,oMark,@cMarca,@lInverte,oDlg)}
oMark:oBrowse:lhasMark = .T.
oMark:oBrowse:lCanAllmark := .F.
oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

return cRealName


//Monta tela de glosa de item
Function Tela001GLI()

Local aCoors := FWGetDialogSize( oMainWnd )
Local oPanelUp	:= NIL
Local oFWLayer	:= NIL
Local oPanelDown	:= NIL
Local oDialog		:= NIL
Local cMotivo := Space(TamSX3("B14_MOTIVO")[1])
Local aAlterados := {}
LOCAL bOK      := { || GLI001Val(@aAlterados,@oDialog) }
LOCAL bCancel  := { || nOpca := 0, oDialog:End() }
Local aButtons := {}
Local aRet := {}

Private cMarkAli	:= ""

DEFINE MsDialog oDialog Title 'Glosar itens do protocolo' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

// Cria o conteiner onde serão colocados os browses
oFWLayer := FWLayer():New()
oFWLayer:Init( oDialog, .F., .T. )

// Define Painel Superior
oFWLayer:AddLine( 'UP', 70, .F. )
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )

// Painel Inferior

oFWLayer:AddLine( 'DOWN', 30, .F. )
oFWLayer:AddCollumn( 'TUDO' , 100, .T., 'DOWN' )
oPanelDown := oFWLayer:GetColPanel( 'TUDO', 'DOWN' ) 

cMarkAli := Mark001GLI(oPanelUp)


nOpca := 1

Activate MsDialog oDialog Center ON INIT EnchoiceBar(oDialog,bOK,bCancel,.F.,aButtons)

aRet := {nOpca, aAlterados}

Return aRet

//Validação da glosa de itens
function GLI001Val(aAlterados,oDialog)

Local cSql := ""

cSql += " Select * from " + cMarkAli
cSql += " Where"
cSql += " OKN <> ' ' "
	
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"VALBRW",.F.,.T.)

If !(VALBRW->(EoF()))
	While !(VALBRW->(EoF()))
		aadd(aAlterados, {VALBRW->CODPRO, VALBRW->MATRIC, VALBRW->SEQUEN,VALBRW->MOTIVO})
		VALBRW->(dbskip())
	endDo
else
	MsgAlert("selecione o(s) item(ns) a serem glosados")
	lRet := .F.
endIf

VALBRW->(dbclosearea())

oDialog:End()

return


/*{Protheus.doc} MarkChk
Marcacao de um registro
@author Robson Nayland
@since 26/03/2021
@version 1.0
*/
Static Function Pls001Mark(cAliasMrk,oMark,cMarca,lInverte,oDlg )
Local nOpca := 0
Local cRetorno := Space(200)
Default oDialog := Nil
Default oSay := Nil

If IsMark("OKN",cMarca,lInverte)

	DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011

	DEFINE MSDIALOG oDialog TITLE "TOTVS" FROM 008.0,010.3 TO 014,050

	@ 005,010 SAY oSay PROMPT "Informe o Motivo:"  SIZE 080,010 OF oDialog PIXEL COLOR CLR_RED
	@ 015,010 MSGET cRetorno SIZE 130,006 OF oDialog Picture "@!" PIXEL FONT oFontTit COLOR CLR_BLACK
	@ 030,082 BUTTON "OK"  SIZE 36,13 PIXEL ACTION {||nOpca := 2,oDialog:End() }
	@ 030,120 BUTTON "Cancelar" SIZE 36,13 PIXEL ACTION {||nOpca := 1,oDialog:End() }

	ACTIVATE MSDIALOG oDialog CENTERED

	IF nOpca == 2
		RecLock(cAliasMrk, .F.)
		(cAliasMrk)->OKN 	:= cMarca
		(cAliasMrk)->MOTIVO := cRetorno
		MsUnlock()
	Else	
		RecLock(cAliasMrk, .F.)
		(cAliasMrk)->OKN 	:= '  '
		(cAliasMrk)->MOTIVO := ' '
		MsUnlock()
	EndIf
Else

	RecLock(cAliasMrk, .F.)
	(cAliasMrk)->OKN 	:= '  '
	(cAliasMrk)->MOTIVO := ' '
	MsUnlock()

Endif

oDlg:Refresh()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ChckClientFamilia
Verifica se o cliente informado pertente a familia

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 28/01/2022
/*/
//------------------------------------------------------------------- 
Static Function ChckClientFamilia(cCodigo, cLoja, cOperadora, cEmpresa, cMatricula, cCPFBeneficiario)

	Local lCheck := .T.
	Local cCPFCliente := ""
	Local cQuery := ""
	Local cAliasTemp := ""

	Default cCPFBeneficiario := ""

	SA1->(DbSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1")+cCodigo+cLoja))

		cCPFCliente := Alltrim(SA1->A1_CGC)

		cQuery := " SELECT BA1_CPFUSR "
		cQUery += " FROM "+RetSqlName("BA1")+" BA1 "
		cQuery += " WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"' "	
		cQuery += "   AND BA1.BA1_CODINT = '"+cOperadora+"' "
		cQuery += "   AND BA1.BA1_CODEMP = '"+cEmpresa+"' "
		cQuery += "   AND BA1.BA1_MATRIC = '"+cMatricula+"' "

		If !Empty(cCPFBeneficiario)
			cQuery += " AND BA1.BA1_CPFUSR = '"+Alltrim(cCPFBeneficiario)+"' "
		Else
			cQuery += " AND BA1.BA1_CPFUSR = '"+cCPFCliente+"' "
		EndIf

		cQuery += " AND (BA1.BA1_DATBLO = '' OR BA1.BA1_DATBLO > '"+DToS(dDataBase)+"') "
		cQuery += " AND BA1.D_E_L_E_T_ = ' ' "

		cAliasTemp := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTemp, .T., .F.)

		If !(cAliasTemp)->(Eof())

			lCheck := IIf(!Empty(cCPFBeneficiario) .And. cCPFBeneficiario <> cCPFCliente, .F., .T.)	

		Else
			lCheck := .F.
		EndIf

		(cAliasTemp)->(DbCloseArea())
	EndIf

Return lCheck

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDadosFornecedor
Retorna os dados para ser utilizado no cadastro de
Fornecedor (SA2)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 28/01/2022
@Obs Obrigatorio que a Tabela informada esteja posicionada
/*/
//------------------------------------------------------------------- 
Static Function GetDadosFornecedor(cTabela)

	Local oDadosFornecedor := JsonObject():New()

	Do Case 
		Case cTabela == "SA1"

			oDadosFornecedor["A2_NOME"] := Substr(SA1->A1_NOME, 1, TamSx3("A2_NOME")[1])
			oDadosFornecedor["A2_NREDUZ"] := Substr(SA1->A1_NREDUZ, 1, TamSx3("A2_NREDUZ")[1])
			oDadosFornecedor["A2_END"] := Substr(SA1->A1_END, 1, TamSx3("A2_END")[1])
			oDadosFornecedor["A2_BAIRRO"] := Substr(SA1->A1_BAIRRO, 1, TamSx3("A2_BAIRRO")[1])
			oDadosFornecedor["A2_EST"] := Substr(SA1->A1_EST, 1, TamSx3("A2_EST")[1])
			oDadosFornecedor["A2_MUN"] := Substr(SA1->A1_MUN, 1, TamSx3("A2_MUN")[1])
			oDadosFornecedor["A2_CEP"] := Substr(SA1->A1_CEP, 1, TamSx3("A2_CEP")[1])
			oDadosFornecedor["A2_CGC"] := Substr(SA1->A1_CGC, 1, TamSx3("A2_CGC")[1])
			oDadosFornecedor["A2_DDD"] := Substr(SA1->A1_DDD, 1, TamSx3("A2_DDD")[1])
			oDadosFornecedor["A2_TEL"] := Substr(SA1->A1_TEL, 1, TamSx3("A2_TEL")[1])
			oDadosFornecedor["A2_EMAIL"] := Substr(SA1->A1_EMAIL, 1, TamSx3("A2_EMAIL")[1])
			oDadosFornecedor["A2_COD_MUN"] := Substr(SA1->A1_COD_MUN, 1, TamSx3("A2_COD_MUN")[1])
		
		Case cTabela == "BA1"

			oDadosFornecedor["A2_NOME"] := Substr(BA1->BA1_NOMUSR, 1, TamSx3("A2_NOME")[1])
			oDadosFornecedor["A2_NREDUZ"] := Substr(BA1->BA1_NOMUSR, 1, TamSx3("A2_NREDUZ")[1])
			oDadosFornecedor["A2_END"] := Substr(BA1->BA1_ENDERE, 1, TamSx3("A2_END")[1])
			oDadosFornecedor["A2_BAIRRO"] := Substr(BA1->BA1_BAIRRO, 1, TamSx3("A2_BAIRRO")[1])
			oDadosFornecedor["A2_EST"] := Substr(BA1->BA1_ESTADO, 1, TamSx3("A2_EST")[1])
			oDadosFornecedor["A2_MUN"] := Substr(BA1->BA1_MUNICI, 1, TamSx3("A2_MUN")[1])
			oDadosFornecedor["A2_CEP"] := Substr(BA1->BA1_CEPUSR, 1, TamSx3("A2_CEP")[1])
			oDadosFornecedor["A2_CGC"] := Substr(BA1->BA1_CPFUSR, 1, TamSx3("A2_CGC")[1])
			oDadosFornecedor["A2_DDD"] := Substr(BA1->BA1_DDD, 1, TamSx3("A2_DDD")[1])
			oDadosFornecedor["A2_TEL"] := Substr(BA1->BA1_TELEFO, 1, TamSx3("A2_TEL")[1])
			oDadosFornecedor["A2_EMAIL"] := Substr(BA1->BA1_EMAIL, 1, TamSx3("A2_EMAIL")[1])
			oDadosFornecedor["A2_COD_MUN"] := Substr(BA1->BA1_CODMUN, 3, TamSx3("A2_COD_MUN")[1])
	EndCase

Return oDadosFornecedor