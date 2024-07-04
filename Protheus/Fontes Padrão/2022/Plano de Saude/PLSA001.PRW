#INCLUDE "PLSA001.ch"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMCCR.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"
 
#DEFINE __aCdCri032 {"540",STR0001}	//"Erro controlado SIGAPLS."
#DEFINE __aCdCri089 {"055",STR0002}	//"A Data/Hora autorizada e diferente da Data/Hora apresentada/cobrada pela operadora destino."
#DEFINE K_Recurso   7
   
STATIC oEnchoice
STATIC oBrwPro
STATIC oBrwCri
STATIC oBrwComp
STATIC aTrbCri   := {}
STATIC aDadCri   := {}
STATIC aCabCri   := {}
STATIC aTrbComp  := {}
STATIC aDadComp  := {}
STATIC aCabComp  := {}
STATIC aAutFor   := {}
STATIC aMatComB  := {}
STATIC aMatCriB  := {}
STATIC aCabB45   := {}
STATIC lFirst    := .T.
STATIC lBAU	   	 := .F.
STATIC oSayE
STATIC oSayF
STATIC __lmesg := .F.
STATIC __nValRmb := 0
STATIC __nValGlosa := 0
STATIC __nValabpf  := 0
STATIC __lValora := .F.
STATIC __nVlPg := 0
STATIC __nGlsa := 0
STATIC __VLBPF   := 0
STATIC cNumProto := Space(20)
STATIC nVlrManG	 := 0
STATIC MV_FRQUIA := GETNEWPAR("MV_FRQUIA",.F.)
STATIC __aMark   := {} 
STATIC _lSemComp := .F.
STATIC aAreaBOW := {} 
STATIC aAreaB1N := {}  
STATIC aAreaB44 := {} 
STATIC aAreaB45 := {}  
STATIC aAreaB47 := {}  
STATIC aAreaSE2 := {} 

//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

STATIC objCENFUNLGP := CENFUNLGP():New() 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA001 ³ Autor ³ Daher				  ³ Data ³ 27.02.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Reembolso                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA001

LOCAL oMBrwRmb
LOCAL bTest := {||}
Local cInteracao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina   := {} 
	
PRIVATE cFilter	  := ""
PRIVATE cCadastro := STR0003
PRIVATE oMBrwB44

cInteracao := "PLSAINTE('B45','03', 'B44->B44_OPEMOV' , 'B44->B44_ANOAUT' , 'B44->B44_MESAUT' , 'B44->B44_NUMAUT' )"
									
ADD OPTION aRotina TITLE STR0144 ACTION 'MsAguarde({|| PLBOWAPR(,,oMBrwB44) }, "Aguarde", "Processo em andamento...", .F.) ' OPERATION 2 ACCESS 0 //"Aprovação Reemb." 
ADD OPTION aRotina TITLE STR0110 ACTION 'PL001MOV' OPERATION 2 ACCESS 0 //Visualizar 
ADD OPTION aRotina TITLE STR0112 ACTION 'PL001MOV("B44",RECNO(),4)' OPERATION 2 ACCESS 0 //Excluir
ADD OPTION aRotina TITLE STR0143 ACTION 'PLBOWHIS("B44",B44->B44_PROTOC)'  OPERATION 2 ACCESS 0 //"Hist. Protoc. Reemb."
ADD OPTION aRotina TITLE "Recurso de Glosa" ACTION 'PLSRGLOREE' OPERATION 2 ACCESS 0 //"Recurso de Glosa"
ADD OPTION aRotina TITLE STR0297 ACTION cInteracao OPERATION 2 ACCESS 0 //Interação

If ! ( PLSALIASEX("BRI") .And. FindFunction("PLSRETLDP") )
	Final("Necessário atualizar pacote da TISS 2.2 para se utilizar esta funcionalidade.")
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. utilizado para adicionar novas opcoes ao menu           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PL001BTADD")
	
	aBtAdd := ExecBlock("PL001BTADD",.F.,.F.,{aRotina})


	If ValType(aBtAdd) == "A"
		AEval(aBtAdd,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega criticas padroes												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PL001CarCr()
BCS->(dbSetOrder(1))
If !BCS->(MsSeek(xFilial("BCS")+PLSINTPAD()+"04"))
	Help("",1,"PL001012")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("B44")
B44->(DbSetOrder(1))
B44->(DbGoTop())
If ExistBlock("PLA001FL")
	
	cFilPE := ExecBlock("PLA001FL",.F.,.F.,{})
	
	SET FILTER TO &cFilPE
EndIf

oMBrwB44:= FWMarkBrowse():New()
oMBrwB44:SetAlias("B44")
oMBrwB44:SetMenuDef("PLSA001")
oMBrwB44:AddLegend("B44->B44_STATUS == '1'", "WHITE", STR0298) //"Aguardando parecer"
oMBrwB44:AddLegend("B44->B44_STATUS == '2'", "GREEN", STR0299) //"Aprovado para pagamento"
oMBrwB44:AddLegend("B44->B44_STATUS == '3'", "RED", STR0300) //"Pagamento negado"
oMBrwB44:AddLegend("B44->B44_STATUS == '4'", "YELLOW", STR0234 ) //"Aprovado parcialmente"
oMBrwB44:AddLegend("B44->B44_STATUS == '6'", "BLUE", STR0301) //"Em analise pela auditoria" 
oMBrwB44:SetFieldMark( 'B44_IDMARK' )
oMBrwB44:SetDescription(STR0168)
oMBrwB44:SetValid({||PLSMSGRMB()})
oMBrwB44:SetAllMark({ ||  MsAguarde({|| A001Inverte(oMBrwB44) }, "Aguarde", 'Seleção em andamento...', .F.) }) 
oMBrwB44:SetWalkThru(.F.)
oMBrwB44:SetAmbiente(.F.)
oMBrwB44:ForceQuitButton()
oMBrwB44:SetAfterMark({||PLMARKRMB(oMBrwB44)}) 


oMBrwB44:Activate()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL001MOV ³ Autor ³ Daher					³ Data ³ 29.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Movimentacao do Cadastro de Reembolso                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PL001MOV(cAlias,nReg,nOpc,cBenef,cCodInte,cCodEmp,cMatric,cTipreg,cDigito,dDataRee,cNumProTMK)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local I__f := 0
Local nOpca	     := 0
LOCAL oDlg
Local aPosObj    := {}
Local aObjects   := {}
Local aSize      := {}
Local aInfo      := {}
Local aRetorno	 := {}
LOCAL bOK        := {|| nOpca := 1, MsAguarde({|| If(P001Final(aRetorno,oEnchoice:aGets,oEnchoice:aTela,oBrwPro,oEnchoice,nOpc,oBrwCri),oDlg:End(),nOpca:=2) }, "Aguarde", "Processo em andamento...", .F.),If(nOpca==1,oDlg:End(),.F.) } 
LOCAL bCancel    := { || oDlg:End() }
LOCAL aValReem   := {}
LOCAL aButtons	 := {}
LOCAL oFontNum
LOCAL oFontAutor
LOCAL oFontTit
LOCAL lValidVis := .T.
LOCAL lDtPagto 	:= GETNEWPAR("MV_PLSDTPG",.F.)
LOCAL lOpcProtc	:= .F.
LOCAL nPosSB45  := 0
LOCAL nI		:= 0
LOCAL cChaveDel := B44->(B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI) 
LOCAL cChDelTit := B44->(B44_PREFIX + B44_NUM + B44_PARCEL + B44_TIPO)
LOCAL cFornSE2	:= BOW->BOW_FORNEC 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Tipo 01                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTrbB45  := {}
PRIVATE aColsB45 := {}
PRIVATE oSay
PRIVATE cCadastro:= STR0003  //"Autorização de reembolso"
DEFAULT cBenef		:=	""
DEFAULT cCodInte	:=	""
DEFAULT cCodEmp		:=	""
DEFAULT cMatric		:=	""
DEFAULT cTipreg		:=	""
DEFAULT cDigito		:=	""
DEFAULT cNumProTMK  := ""

Private cTlmkReem	:= ""
PRIVATE B45_MATRIC := B45_SEQB1N := " "	//	Para uso da rotina "P001ValRe"



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se chamado pela rotina de protocolo de reembolso        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAlias == "BOW"
	cAlias := "B44"
	nOpc := 3
	lOpcProtc :=  .T.
EndIf

//--------------------------------------------------------------------------------
//Verifica se ja foi definido um numero de protocolo no atendimento call center
//--------------------------------------------------------------------------------
If !Empty(cNumProTMK) .and. B00->(DbSeek(xFilial("B00") + cNumProTMK))
	cNumProto := cNumProTMK
	
	B44->(DbSetOrder(4))
	if B44->(DbSeek(xFilial("B44")+cNumProTMK))
		nReg := B44->(RecNo()) //Captura o recno
		nOpc := 4 //Alteração
	endif
EndIf

DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-012 BOLD
aAutFor  := {}

If nOpc == 4

	If Existblock("PLSVALEXC")
		If !(Execblock("PLSVALEXC", .F., .F.))
			Return .F.
		endIf
	endIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a guia esta em análise pela auditoria antes da exclusão      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !PLSA092VL2("B45")
		SET KEY VK_F5 TO
		SET KEY VK_F6 TO
		SET KEY VK_F7 TO
		SET KEY VK_F8 TO
		SET KEY VK_F9 TO
		SET KEY VK_F10 TO
		SET KEY VK_F11 TO
		SET KEY VK_F12 TO

		Return .F.
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aCols e aHeader...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacoes iniciais														 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BAU->(DbSetOrder(1))
	If ! BAU->(MsSeek(xFilial("BAU")+GetMV("MV_PLSRDAG")))
		Help("",1,"PL001001")
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Valida calendario pagto...                                               ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aRetAux := PLSXVLDCAL(dDataBase,PLSINTPAD(),.T.,"","",Nil,Nil,IIf(lDtPagto,.T.,Nil)) 
	

	If ! aRetAux[1]
		Return
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enchoice 		                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Copy "B44" TO Memory Blank
	If !Empty(AllTrim(cBenef)) .AND. LEN(cBenef) > 1
		SX3->(DbSetOrder(2))
		SX3->(MsSeek("B44_USUARI"))
		M->B44_USUARI := cBenef
		If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .or. empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .or. empty(SX3->X3_VLDUSER))
			RunTrigger(1)

			If FunName() == "TMKA271" .And. GetNewPar("MV_PLRN395","0") == "1" .And. !Empty(cNumProto)
				
				If ("BOW")->(FieldPos("BOW_PROATE")) == 0 
			 		M->B44_PROATE := cNumProto 
				EndIf	 
				M->B44_PROTOC := cNumProto //Para clientes cujo reembolso não terá protocolo
				
				RunTrigger(1,,,,"B44_PROTOC")
			
			EndIf

		Elseif funname() == "TMKA271" //VERIFICAR SE O FUNNAME VEIO DO CALLCENTER E FAZER O DIALOG END
			//se o valid deu .F. e veio do TMK é pq deu critica com o beneficiario, entao encerro a tela
			Return
		Endif
	EndIf

	If !Empty(AllTrim(cCodInte))
		M->B44_OPEUSR := cCodInte
	Endif

	If !Empty(AllTrim(cCodEmp))
		M->B44_CODEMP := cCodEmp
	Endif


	If !Empty(AllTrim(cMatric))
		M->B44_MATRIC := cMatric
	Endif


	If !Empty(AllTrim(cTipreg))
		M->B44_TIPREG := cTipreg
	Endif


	If !Empty(AllTrim(cDigito))
		M->B44_DIGITO := cDigito
	Endif

	M->B44_MESPAG := aRetAux[5]
	M->B44_ANOPAG := aRetAux[4]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ GetDados - Eventos                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("B45")

	If Len(aCabB45) == 0
		Store Header "B45" TO aCabB45 For .T.
	Endif

	Store COLS Blank "B45" TO aColsB45 FROM aCabB45
	nPosSB45:= PLRETPOS("B45_SEQUEN",aCabB45)

	If nOpc == K_Incluir .AND. aColsB45 [1][nPosSB45] != "001"
		aColsB45 [1][nPosSB45] := PLSINCRE("B45_SEQUEN")
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ GetDados - Criticas                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("B46")

	If Len(aCabCri) == 0
		Store Header "B46" TO aCabCri For .T.
	Endif

	store COLS Blank "B46" TO aDadCri FROM aCabCri
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ GetDados - Composicao                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("B47")

	If Len(aCabComp) == 0
		Store Header "B47" TO aCabComp For .T.
	Endif
	

	store COLS Blank "B47" TO aDadComp FROM aCabComp
    //Alimenta a grid de Eventos de acordo com itens adicionados no protocolo de reembolso.
	If lOpcProtc
		
		BRWB45(@aCabB45,@aColsB45, BOW->BOW_PROTOC) //Eventos
		
	EndIf
Else
	Copy "B44" TO Memory

	cOpeMov    := B44->B44_OPEMOV
	cAnoAut    := B44->B44_ANOAUT
	cMesAut    := B44->B44_MESAUT
	cNumAut    := B44->B44_NUMAUT
	cChave     := B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT)

	If !Empty(B44->B44_NUM) .and. B44->B44_FORPAG == '0' .and. nOpc == 4//EXCLUSAO
		Help("",1,"PL001013")
		return .F.
	Endif

	B45->(DbSetOrder(1))  
	B45->(MsSeek(xFilial("B45")+cChave))

	If Len(aCabB45) == 0
		Store Header "B45" TO aCabB45 For .T.
	Endif

	STORE COLS "B45" TO aColsB45 FROM aCabB45 VETTRAB aTrbB45 While xFilial("B45")+cChave == B45->(B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT)

	B46->(DbSetOrder(1))
	B46->(MsSeek(xFilial("B46")+cChave))

	If Len(aCabCri) == 0
		Store Header "B46" TO aCabCri For .T.
	Endif

	STORE COLS "B46" TO aDadCri FROM aCabCri VETTRAB aTrbCri While xFilial("B46")+cChave == B46->(B46_FILIAL+B46_OPEMOV+B46_ANOAUT+B46_MESAUT+B46_NUMAUT)

	If Empty(aDadCri)
		B46->(MsGoto(0))
		Store COLS Blank "B46" TO aDadCri FROM aCabCri
	EndIf

	B47->(DbSetOrder(1))
	B47->(MsSeek(xFilial("B47")+cChave))

	If Len(aCabComp) == 0
		Store Header "B47" TO aCabComp For .T.
	Endif

	STORE COLS "B47" TO aDadComp FROM aCabComp VETTRAB aTrbComp While xFilial("B47")+cChave == B47->(B47_FILIAL+B47_OPEMOV+B47_ANOAUT+B47_MESAUT+B47_NUMAUT)

	If Empty(aDadComp)
		B47->(MsGoto(0))
		Store COLS Blank "B47" TO aDadComp FROM aCabComp
	EndIf

	If nOpc <> K_Incluir
		lValidVis := .F.
	Endif

	PLSA090USR(B44->(B44_OPEUSR+B44_CODEMP+B44_MATRIC+B44_TIPREG+B44_DIGITO),B44->B44_DATPRO,B44->B44_HORPRO,"B44",.F.,;
		nil,nil,nil,nil,nil,nil,nil,nil,nil,;
		nil,nil,nil,lValidVis,Iif(nOpc == K_Incluir,.T.,.F.))

	If nOpc == K_Incluir
		PLSA090RDA(B44->B44_OPERDA,B44->B44_CODRDA,"1",B44->B44_DATPRO,;
			B44->(B44_OPEUSR+B44_CODEMP+B44_MATRIC+B44_TIPREG),;
			B44->B44_LOCATE,B44->B44_CODESP,"B44",.F.)
	Endif

	BDS->(DbSetOrder(1))
	If BDS->(MsSeek(xFilial("BDS")+B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT+"1")))
		While ! BDS->(Eof()) .And. BDS->(BDS_FILIAL+BDS_OPEMOV+BDS_ANOAUT+BDS_MESAUT+BDS_NUMAUT+BDS_ORIGEM) == ;
				xFilial("BDS")+B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT+"1")

			aadd(aAutFor,{.F.,BDS->BDS_CODPAD,BDS->BDS_CODPRO,BDS->BDS_OPEMOV,BDS->BDS_ANOAUT,BDS->BDS_MESAUT,;
				BDS->BDS_NUMAUT,BDS->(Recno()),BDS->BDS_OPESIS,BDS->BDS_DATA,BDS->BDS_HORA,,,BDS->BDS_SEQUEN})
			BDS->(DbSkip())
		Enddo
	Endif
EndIf

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
objCENFUNLGP:useLogUser()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
AAdd( aObjects, { 001, 020, .T., .F.,.F. } )
AAdd( aObjects, { 001, 000, .T., .T.,.F. } )
AAdd( aObjects, { 001, 100, .T., .F.,.T. } )

aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects )

aPosObj[1][2]+=15
If nOpc <> K_Incluir
	aPosObj[1][3]+=5
Endif
aPosObj[2][2]+=15
aPosObj[3][2]+=15

aPosObj[3][3]-=15

DEFINE MSDIALOG oDlg TITLE STR0004 + " - "+AllTrim(aRotina[nOpc,1]) FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel //"Reembolso"
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[2],,,,,,oDlg,,,.F.,,,If(IsInCallStack("PL09PGREF"),.T.,.F.))

nLinSoma := 15
oDlgSay  := oDlg
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe say...                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ aPosObj[1,1], aPosObj[1,2] GROUP oGrupo TO aPosObj[1,3], aPosObj[1,4] PIXEL OF oDlg LABEL " "+STR0005+" "  COLOR CLR_HBLUE, CLR_HRED  //"Informações"

If nOpc <> K_Incluir
	@ aPosObj[1,1]+6,aPosObj[1,2]+5     Say oSayA PROMPT STR0006  SIZE 220,010 OF oDlg PIXEL   //"Reembolso Número"
	@ aPosObj[1,1]+6,aPosObj[1,2]+70    Say oSayB PROMPT TransForm(M->B44_OPEMOV+M->B44_ANOAUT+M->B44_MESAUT+M->B44_NUMAUT,PesqPict("BE1","BE1_NUMAUT"))  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED

	@ aPosObj[1,1]+14,aPosObj[1,2]+5    Say oSayC PROMPT STR0007  SIZE 220,010 OF oDlg PIXEL  //"Valor Reembolsado:"
	@ aPosObj[1,1]+14,aPosObj[1,2]+70   Say oSayD PROMPT "R$ "+alltrim(TransForm(M->B44_VLRPAG,PesqPict("BD6","BD6_VLRPAG")))  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED

	@ aPosObj[1,1]+14,aPosObj[1,2]+155  Say oSayE PROMPT STR0145  SIZE 220,010 OF oDlg PIXEL  //"Vlr Glosa:"
	@ aPosObj[1,1]+14,aPosObj[1,2]+200  Say oSayF PROMPT "R$ "+alltrim(TransForm(M->B44_VLRGLO,PesqPict("BD6","BD6_VLRGLO")))  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED
	@ aPosObj[1,1]+14,aPosObj[1,2]+300  Say oSayG PROMPT STR0008  SIZE 220,010 OF oDlg PIXEL  //"Vlr.Abat. PF:"
	@ aPosObj[1,1]+14,aPosObj[1,2]+345  Say oSayH PROMPT "R$ "+alltrim(TransForm(M->B44_VLABPF,PesqPict("BD6","BD6_VLRGLO")))  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED
Else

	@ aPosObj[1,1]+8,aPosObj[1,2]+5    Say oSayC PROMPT STR0007  SIZE 220,010 OF oDlg PIXEL   //"Valor Reembolsado:"
	@ aPosObj[1,1]+8,aPosObj[1,2]+70   Say oSayD PROMPT "R$ "+alltrim(TransForm(M->B44_VLRPAG,PesqPict("BD6","BD6_VLRPAG")))  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED

	@ aPosObj[1,1]+8,aPosObj[1,2]+155  Say oSayE PROMPT STR0145  SIZE 220,010 OF oDlg PIXEL  //"Vlr Glosa:"
	@ aPosObj[1,1]+8,aPosObj[1,2]+200  Say oSayF PROMPT "R$ "+alltrim(TransForm(M->B44_VLRGLO,PesqPict("BD6","BD6_VLRGLO")))  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED
	@ aPosObj[1,1]+8,aPosObj[1,2]+300  Say oSayG PROMPT STR0008  SIZE 220,010 OF oDlg PIXEL  //"Vlr.Abat. PF:"
	@ aPosObj[1,1]+8,aPosObj[1,2]+345  Say oSayH PROMPT "R$ "+alltrim(TransForm(M->B44_VLABPF,PesqPict("BD6","BD6_VLRGLO")))  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Folders...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder 		  := TFolder():New(aPosObj[3,1],aPosObj[3,2],{STR0009,STR0010,STR0011},{"","",""},oDlg,,,,.T.,.F.,aPosObj[3,3],aPosObj[3,4])  //"Eventos"###"Composição"###"Criticas"
oFolder:bChange   := {|nFolder| oBrwPro:oBrowse:oBrowse:Refresh(),oBrwComp:ForceRefresh(),oBrwCri:ForceRefresh(),P001SEQCRI()}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (GetNewPar("MV_PLVLRE", .T.)) .and. nOpc <> 2 //Adicionada validação pois o cliente que trabalha com protocolo pode modificar a regra nos pontos de entrada do protocolo de modo diferenciado.
	AaDd(aValReem,{"TK_VERTIT",{|| P001ValRe("B44","B45","B47")},STR0012,STR0013})  //"Valorar procedimento de reembolso <F12>"###"Valorar"
	AaDd(aValReem,{"TK_VERTIT",{|| P001ValRe("B44","B45","B47")},"Busca do Protocolo","Busca do Protocolo"})  //"Valorar procedimento de reembolso <F12>"###"Valorar"

	SetKey(VK_F12,{|| P001ValRe("B44","B45","B47")})
EndIf

oBrwPro 		  := TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[1],nil, nil, nil ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabB45,aColsB45,.F.,"B45",nOpc,STR0014,nil,nil,nil,nil,'P001Vld() .AND. PLSVLDIN() .AND. PLVALDTLI("B45")','P001Del()',nil,{|a,b,c|PL001COR(a,b,c)},aValReem,{|a,b,c,d| PL001ok(a,b,c,d,oBrwPro:oBrowse:nAt)},{|| PL01CANCEL()}  ) //"Procedimentos"
oBrwPro:aVetTrab  := aClone(aTrbB45)
oBrwPro:bChange   := {|| oBrwComp:ForceRefresh(),oBrwCri:ForceRefresh() }
oBrwPro:bGotFocus := {|| oBrwPro:oBrowse:oBrowse:Refresh() }

//Verifica se existe algum procedimento para o reembolso
If (nOpc == K_Visualizar .Or. nOpc == 4/*Excluir*/) .And. ! B45->(DbSeek(xFilial("B45")+B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT))
	Alert(STR0116+Chr(13) + Chr(10)+STR0117)
	//"Atenção: Esse registro não está íntegro, pois não possui procedimentos!"
	//"Avise o administrador do Sistema."
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter          := {|nLine,aCols,aHeader| aCols[nLine,PLRETPOS("B47_SEQUEN",aHeader)] == oBrwPro:FieldGet("B45_SEQUEN") .and. !aCols[nLine][Len(aCols[nLine])] }
oBrwComp 		 := TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,;
								oFolder:aDialogs[2],nil    ,  ,nil,nil   ,;
								nil, .T.   ,nil  ,.T.   ,nil   ,;
								aCabComp,aDadComp,.F.,"B47",K_Visualizar,;
								STR0015,nil,nil,nil,aTrbComp;
								,,,bFilter) //"Composição do Procedimento"
oBrwComp:oPai    := oBrwPro
oBrwComp:aOrigem := {"B45_SEQUEN"}
oBrwComp:aRelac  := {"B47_SEQUEN"}
aMatComB 		 := aClone(oBrwComp:aCols)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter         := {|nLine,aCols,aHeader| aCols[nLine,PLRETPOS("B46_SEQUEN",aHeader)] == oBrwPro:FieldGet("B45_SEQUEN") .and. !aCols[nLine][Len(aCols[nLine])] }
oBrwCri 		:= TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[3],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabCri,aDadCri,.F.,"B46",K_Visualizar,STR0016,nil,nil,nil,aTrbCri,,,bFilter) //"Críticas do Reembolso "
oBrwCri:oPai    := oBrwPro
oBrwCri:aOrigem := {"B45_SEQUEN"}
oBrwCri:aRelac  := {"B46_SEQUEN"}
aMatCriB 		:= aClone(oBrwCri:aCols)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monto os botoes padroes													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FunName() == "TMKA271"
	If cAlias = "B44"
		M->B44_USUARI := cBenef //RECARREGO A MATRÍCULA DO USUÁRIO
	Endif
EndIf

PLSA001Bot(nOpc,"B44",oEnchoice,oBrwPro,"B45",{ || M->B44_USUARI },aButtons,oDlg,oBrwCri,oBrwComp,"B47")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se chamado pela rotina de protocolo de reembolso                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lOpcProtc

	dbSelectArea("BA3")
	BA3->(dbSetOrder(1))

	dbSeek(xFilial("BA3") + BOW->(BOW_OPERDA + BOW_CODEMP + BOW_MATRIC + BOW_CONEMP))

	M->B44_FORPAG := BA3->BA3_TIPPGO
	M->B44_PROTOC := BOW->BOW_PROTOC

	If ("BOW")->(FieldPos("BOW_PROATE")) > 0 
		M->B44_PROATE := BOW->BOW_PROATE 
	Endif	

	if(BOW->(FieldPos("BOW_REGINT")) > 0 ) .AND. (BOW->(FieldPos("BOW_GRPINT")) > 0 )
		M->B44_GRPINT := BOW->BOW_GRPINT
		M->B44_REGINT := BOW->BOW_REGINT
	endIf

	
	RunTrigger(1,,,,"B44_PROTOC")
	

		//Ponto de entrada para manipulacao dos itens do protocolo
	If ExistBlock("PLPROTITEM")
		
		aAreaBOW := BOW->(GetArea())  
		aAreaB1N := B1N->(GetArea()) 
		aAreaB44 := B44->(GetArea()) 
		aAreaB45 := B45->(GetArea()) 
		aAreaB47 := B47->(GetArea()) 
		aAreaSE2 := SE2->(GetArea()) 

		
		aColsB45 := ExecBlock("PLPROTITEM",.F.,.F.,{aColsB45,aCabB45})
		

		RestArea(aAreaBOW) 
		RestArea(aAreaB1N) 
		RestArea(aAreaB44) 
		RestArea(aAreaB45) 
		RestArea(aAreaB47) 
		RestArea(aAreaSE2) 
	Endif

	
	ValReProt(@aColsB45,aCabB45) 
	
	
	If _lSemComp
		
		PLBOWMOV("BOW",Recno(),K_Visualizar,,,,,,,,,.T.)
		

		_lSemComp := .F.
		Return
	EndIf 
		
	If M->B44_VLRPAG == 0 .AND. M->B44_VLRGLO == 0
		MsgStop(STR0286,STR0049) //"A guia que está sendo gerada não possui valor para reembolso, isto pode acontecer com procedimentos que estão sem composição no protocolo, verifique e tente novamente","Atenção" 
	EndIf 

	//Ponto de entrada para manipulacao dos itens após valoração
	If ExistBlock("PLVLPROTIT")
		aAreaBOW := BOW->(GetArea())  
		aAreaB1N := B1N->(GetArea()) 
		aAreaB44 := B44->(GetArea()) 
		aAreaB45 := B45->(GetArea()) 
		aAreaB47 := B47->(GetArea()) 
		aAreaSE2 := SE2->(GetArea()) 

		
		aColsB45 := ExecBlock("PLVLPROTIT",.F.,.F.,{aColsB45,aCabB45})
		

		RestArea(aAreaBOW) 
		RestArea(aAreaB1N) 
		RestArea(aAreaB44) 
		RestArea(aAreaB45) 
		RestArea(aAreaB47) 
		RestArea(aAreaSE2) 
	Endif

	oBrwPro:setArray(aColsB45)

	M->B44_CODDAT := "000"

	aMatComB := aClone(oBrwComp:aCols)
	aMatCriB := aClone(oBrwCri:aCols)
	oBrwPro:Refresh()
	oBrwComp:Refresh()

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrego o aDadRda da RDA generica										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSDADRDA(M->B44_OPERDA,M->B44_CODRDA,"1",dDataBase,Subs(M->B44_LOCATE,1,3),M->B44_CODESP) 

//Função utilizada retorno dos itens derivados de um protocolo
CarObjRmb(oBrwPro) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,bOk,{||Eval(bCancel)},.F.,aButtons)  })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca retorno contido no aRetorno...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK

	cOpeMov := aRetorno[2]
	cAnoAut := aRetorno[3]
	cMesAut := aRetorno[4]
	cNumAut := aRetorno[5]

	If nOpc == K_Incluir

		If B44->B44_STATUS != "3"
   		

		   	// atualiza campo B1N_VLRREE
			AtuCmpB1N(oBrwPro)
			
			// Baixa de quantidade no item da Receita Medica
			PRMBBXREC(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT), BOW->BOW_PROTOC ) 
		Else
			//Altera o Status do Protocolo
			DbSelectArea("BOW")
			BOW->(DbSetOrder(1))

			If BOW->(DbSeek(xFilial("B44")+B44->B44_PROTOC))

				BOW->(RecLock('BOW',.F.))
				BOW->BOW_STATUS:='7' //7==Não enviar financeiro

				If BOW->(FieldPos("BOW_PGMTO")) > 0
					BOW->BOW_PGMTO := STR0199 //"Não Autorizado"
				EndIf

				BOW->( MsUnlock() )

			Endif
			
			// atualiza campo B1N_VLRREE
			AtuCmpB1N(oBrwPro)
			
			PRMBBXREC(B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT), BOW->BOW_PROTOC ) // Baixa de quantidade no item da Receita Medica
			
			//Grava o histórico
			PLGRVBOX(BOW->BOW_PROTOC,BOW->BOW_MATRIC,BOW->BOW_STATUS,BOW->BOW_NUMAUT, /*cNumCC*/, ;
			/*dDtBaix*/, /*cObs*/, BOW->BOW_CODLDP, BOW->BOW_CODPEG, BOW->BOW_ORIMOV,BOW->BOW_NPROCE )
	  EndIf

	    // Conclui um protocolo
  	    If GetNewPar("MV_PLRN395","0") == "1" .And. !Empty(cNumProto)
		  	
	        P773AutCon("B44",cNumProto,cOpeMov+cAnoAut+cMesAut+cNumAut)
			
	    EndIf
   	  A001Final(cOpeMov,cAnoAut,cMesAut,cNumAut,aRetorno[7],aRetorno[8],oBrwPro,aRetorno[9])

		IF Existblock("PL001AFT")
			
			aAreaBOW := BOW->(GetArea())  
			aAreaB1N := B1N->(GetArea()) 
			aAreaB44 := B44->(GetArea()) 
			aAreaB45 := B45->(GetArea()) 
			aAreaB47 := B47->(GetArea()) 
			aAreaSE2 := SE2->(GetArea()) 
			
			
			ExecBlock("PL001AFT", .F. , .F., {BOW->BOW_PROTOC, B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT)})
			

			RestArea(aAreaBOW) 
			RestArea(aAreaB1N) 
			RestArea(aAreaB44) 
			RestArea(aAreaB45) 
			RestArea(aAreaB47) 
			RestArea(aAreaSE2) 
		EndIF  	  

	ElseIf nOpc == 4

		If PLSALIASEXI("B53")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui registro na B53 referente a guia de reembolso excluida            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			B53->( DbSetOrder(1) )//B53_FILIAL + B53_NUMGUI + B53_ORIMOV
			If B53->( MsSeek(xFilial("B53")+B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT)) )
				B53->(RecLock("B53",.F.))
				B53->(DbDelete())
				B53->(MsUnLock())
			EndIf
		EndIf

		// Retorna o saldo do item da receita caso o debito ja tenha ocorrido
		If B44->B44_STATUS $ "1,2,4" 
			
			B1N->(dbSetOrder(2))

			For nI:= 1 To LEN(oBrwPro:aCols)
				If B1N->(MsSeek(xFilial("B1N") + M->B44_PROTOC + oBrwPro:FieldGet("B45_SEQB1N",nI)))

					If !EMPTY(B1N->B1N_CODREC)
						
						B7D->(dbSetorder(3))

						If B7D->(MsSeek(xFilial("B7D") + B1N->(B1N_CODREC + B1N_CODMED)))
							B7D->( RecLock("B7D",.F.))
							B7D->B7D_QTDEXE -= B1N->B1N_QTDMED
							B44->( MsUnLock() )
						EndIf 
					EndIf
				EndIf
			Next
		EndIf
	EndIf

	//Na cemig nem todas as autorizações deletadas estão deletando os registros dependentes 
	If nOpc == 4 //Excluir
		
		//verificação para confirmar que BD6, BD7 e titulo foram excluidos
		BD6->(DbSetOrder(1))
		BD7->(DbSetOrder(1))
		
		If BD6->(MsSeek(xFilial("BD6") + cChaveDel))
			
			While BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO) == ;
				  xFilial("BD6") + cChaveDel
					
				BD6->(RecLock("BD6",.F.))
				BD6->(DbDelete())
				BD6->(MsUnLock())

				BD6->(DbSkip())
			EndDo
		EndIf
	
		If BD7->(MsSeek(xFilial("BD7") + cChaveDel))
			
			While BD7->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO) == ;
			xFilial("BD7") + cChaveDel
			
				BD7->(RecLock("BD7",.F.))
				BD7->(DbDelete())
				BD7->(MsUnLock())
				BD7->(DbSkip())
			EndDo
			
			
		EndIf

		SE2->(dbSetOrder(1)) //E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE
		If SE2->(MsSeek(xFilial("SE2") + cChDelTit + cFornSE2))

			SE2->(RecLock("SE2",.F.))
			SE2->(DbDelete())
			SE2->(MsUnLock())
		EndIf
	EndIf 
Endif

__nValRmb := 0
__nValGlosa := 0
__nValabpf := 0

SET KEY VK_F5 TO
SET KEY VK_F6 TO
SET KEY VK_F7 TO
SET KEY VK_F8 TO
SET KEY VK_F9 TO
SET KEY VK_F10 TO
SET KEY VK_F11 TO
SET KEY VK_F12 TO


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pls001Rel ³ Autor ³ Daher					³ Data ³ 29.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializadores padroes									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA001Rel(cField)

LOCAL uRet

If cField == "B44_CODESP"
	uRet := If(Inclui,Posicione("BAX",1,xFilial("BAX")+GetMV("MV_PLSRDAG")+PLSINTPAD()+SUBS(M->B44_LOCATE,1,3),"BAX_CODESP"),B44->B44_CODESP)
ElseIf cField == "B44_DESESP"
	uRet := If(Inclui,Posicione("BAQ",1,xFilial("BAQ")+PLSINTPAD()+M->B44_CODESP,"BAQ_DESCRI"),B44->B44_DESESP)
Endif

Return uRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pls001Rel ³ Autor ³ Daher					³ Data ³ 29.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ validacoes de campos padrao								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS001VLD(cField)

LOCAL lRet := .T.

If cField == "B44_CODRDA"
	lRet := PLSA090RDA(M->B44_OPERDA,M->B44_CODRDA,"1",M->B44_DATPRO,M->B44_USUARI,"","","B44")
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ P001Final  ³ Autor ³ Daher	            ³ Data ³ 14.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que confirma uma autorizacao retornando o seu numero³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function P001Final(aRetorno,aGets,aTela,oBrwPro,oEncAut,nOpc,oBrwCri) 
LOCAL nI
LOCAL aRetFun
LOCAL nFor
LOCAL lForcou
LOCAL lForcar
LOCAL nCdPrcPos
LOCAL lUmVld := .F.
LOCAL aDadUsr := PLSGETUSR()
LOCAL aChaveGen := {}
LOCAL aDadBEA := {}
LOCAL lRet := .T.
LOCAL lPossuiIt := .F.
LOCAL lConsulta := (PLSISCON(oBrwPro:FieldGet("B45_CODPAD"),oBrwPro:FieldGet("B45_CODPRO")) .And. Len(oBrwPro:aCols) == 1)
LOCAL aCodProcs := {}
LOCAL lGerSenha := .T. //por enquanto o reembolso sempre gera senha
LOCAL lDtPagto := GETNEWPAR("MV_PLSDTPG",.F.)
LOCAL lProtoc := .F.
LOCAL lNeg := .T.
LOCAL nSeqComp := 0 
LOCAL nLenAcols := 0
Local aRetBOW := {}
Local lReembCriaBD5 := .T.
Local cChavGui := ""
Local cChavBD6 := ""
Local nQtdProc := 0 
Local nAcols := 0 
Local nLen := 0 
Local nSequenIte := 0 
Local nPosSeqIte := 0 
Local nPosMatric := 0
Local nPosAbatPf := Ascan(oBrwPro:aHeader,{ |x| x[2] == "B45_ABATPF"})
Local nPosVlrTpf := Ascan(oBrwPro:aHeader,{ |x| x[2] == "B45_VLRTPF"})
Local nPosVlAbPf := Ascan(oBrwPro:aHeader,{ |x| x[2] == "B45_VLABPF"})
		    	
//log criado para monitorar situação de error.log nao reproduzida
PLSLOGBrw(oBrwComp,"obrwComp")
PLSLOGBrw(oBrwCri,"oBrwCri")

//Protege o campo B44_PROTOC do Protocolo de Reembolso
lProtoc := ! Empty(M->B44_PROTOC)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ No reembolso nao existe alteracao															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Alterar

	nOpc := K_Excluir

	SE1->(DbSetOrder(1))
	If SE1->(MsSeek(xFilial("SE1")+B44->(B44_PREFIX+B44_NUM+B44_PARCEL+B44_TIPO)))
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		 //³ Executa funcao que analisa a possibilidade de exclusao de uma guia que teve movimentacao financeiro relacionada...
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		 aRetASE1 := PLSA090AE1(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA)
         //[1] - Contabilizado (.T./.F.)
         //[2] - Movimentado (.T./.F.)
         //[3] - Baixado por cancelamento (.T./.F.)
         //[4] - Ultimo titulo do prefixo (.T./.F.)
         //[5] - Cliente controla sequencia de titulos (.T./.F.)
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ So pode excluir a guia se o titulo nao foi movimentado ou                ³
         //³ se ele foi baixado por 	motivo de cancelamento                        ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  ! ( ! aRetASE1[2] .or. aRetASE1[3] )
			Help("",1,"PL001010")
			Return .f.
		Endif
	Endif
Endif

If nOpc == K_Excluir 
	 
	 //Executa funcao que analisa a possibilidade de exclusao de uma guia que teve movimentacao financeiro relacionada..
	DbSelectArea("BOW")
	BOW->(DbSetOrder(1))
	BOW->(DbSeek(xFilial("B44")+B44->B44_PROTOC))
	
	SE2->(dbSetOrder(1)) //E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE
	If SE2->(dbSeek(xFilial("SE2") + B44->(B44_PREFIX + B44_NUM + B44_PARCEL + B44_TIPO)+ BOW->BOW_FORNECE))  //está vindo em branco

		If !EMPTY(SE2->E2_BAIXA) .OR. !(EmpTy(SE2->E2_NUMBOR)) //Se o título foi baixado ou gerado o Borderô, não pode excluir
		
			MsgStop("Não é possível excluir a autorização devido o título estar baixado/em borderô")
			Return .f.
		EndIf
	EndIf
Endif

//Verifica se foi informado algum procedimento												   
nCdPrcPos := Ascan(oBrwPro:aHeader,{ |x| x[2] == "B45_CODPRO"})
For nI := 1 To Len(oBrwPro:aCols)
	If !oBrwPro:aCols[nI,Len(oBrwPro:aHeader)+1] .And. nCdPrcPos # 0 .And. !Empty(oBrwPro:aCols[nI,nCdPrcPos])
		lUmVld := .T.
		Exit
	EndIf
Next

//Exibe msg se nao for informado																   
If !lUmVld .And. nOpc != K_Visualizar .And. nOpc != 4/*Excluir*/
	 Help("",1,"PL001003")
	Return(.F.)
EndIf

//Nao e preciso validacao para visualizacao								 
If nOpc == K_Visualizar
	aRetorno := {.T.,B44->B44_OPEMOV,B44->B44_ANOAUT,B44->B44_MESAUT,B44->B44_NUMAUT,.T.,"","",.F.,""}
	Return(.T.)
Endif

//Caso que pode acontecer da guia com ano e mes em branco...               
If Empty(M->B44_ANOPAG) .Or. Empty(M->B44_MESPAG) 
	Help("",1,"PL001004")//"Ano ou Mes de pagamento em branco. Esta guia nao pode ser gravada."
	Return(.F.)
Endif 

//Verifica a data de Recebimento... 							             
If lDtPagto .And. Empty(M->B44_DATREC)
	Help( ,, 'HELP',,STR0146, 1, 0)//"A data de Recebimento nao deve ficar em branco!"
	Return(.F.)
Endif

//Verifica se foi informado pelo menos um item...                          
If !oBrwPro:TudoOK() .Or. ! Obrigatorio(oEncAut:aGets,oEncAut:aTela)
	Return(.F.)
Endif

//Trata cid obrigatorio de acordo com parametrizacao...                    
If !lConsulta .And. !PLSVLDCID(M->B44_CODRDA,M->B44_CID)
	Return(.F.)
Endif

//Verifica se existem itens ativos na getdados
For nFor := 1 To Len(oBrwPro:aCols)
	If !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]
		lPossuiIt := .T.
		Exit
	EndIf
Next

If !lPossuiIt
	Help(" ",1,"OBRIGAT")
	Return(.F.)
Endif

If  !lConsulta .And. ! ( Obrigatorio(oEncAut:aGets,oEncAut:aTela) .And. oBrwPro:TudoOK() )
	Return(.F.)
Endif

//Validação que verifica se após a valoração, o valor de reembolso está zerado.
If M->B44_VLRPAG == 0 .AND. M->B44_VLRGLO == 0
	MsgStop(STR0286,STR0049) //"A guia que está sendo gerada não possui valor para reembolso, isto pode acontecer com procedimentos que estão em composição no protocolo, verifique e tente novamente" ## Atenção

	Return (.F.)
EndIf 

If ExistBlock("PLS001OK")
	
	aAreaBOW := BOW->(GetArea())  
	aAreaB1N := B1N->(GetArea()) 
	aAreaB44 := B44->(GetArea()) 
	aAreaB45 := B45->(GetArea()) 
	aAreaB47 := B47->(GetArea()) 
	aAreaSE2 := SE2->(GetArea()) 
	
	If !ExecBlock("PLS001OK",.F.,.F., {nOpc})
		Return(.F.)
	Endif

	RestArea(aAreaBOW) 
	RestArea(aAreaB1N) 
	RestArea(aAreaB44) 
	RestArea(aAreaB45) 
	RestArea(aAreaB47) 
	RestArea(aAreaSE2) 
Endif

nLenAcols := Len(oBrwPro:aCols) //31-08 ini
//Analiso procedimentos incompativeis e cids incompativeis...              
For nFor := 1 To nLenAcols

	if oSayD:cCaption == "R$ 0,00"  .AND. Ascan( oBrwPro:acols,{|x| x[1] == "ENABLE" } ) > 0 
		
		If nOpc == K_Incluir

			MsgAlert(STR0303, STR0049) //"Esta guia será negada pois não possui valor para reembolso"
			
			oBrwPro:acols[nFor][GDFieldPos("B45_STATUS", oBrwPro:aHeader)] := "0"
			oBrwPro:acols[nFor][GDFieldPos("B45_VLRPAG", oBrwPro:aHeader)] := 0
		EndIf
	Else

		If oBrwPro:FieldGet("B45_STATUS",nFor) == "1" .And. !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]

			aadd(aCodProcs,{oBrwPro:FieldGet("B45_SEQUEN",nFor),;
				oBrwPro:FieldGet("B45_CODPAD",nFor),;
				oBrwPro:FieldGet("B45_CODPRO",nFor),;
				oBrwPro:FieldGet("B45_PROREL",nFor),;
				oBrwPro:FieldGet("B45_PRPRRL",nFor),;
				oBrwPro:FieldGet("B45_QTDPRO",nFor),;
				"",;
				""})
		Endif

		//verifica se a receita vinculada ao protocolo ainda possui saldo para debitar. 
		If nOpc == K_Incluir
		
			If ! Empty(oBrwPro:FieldGet("B45_SEQB1N",nI)) .and. oBrwPro:FieldGet("B45_STATUS",nI) == "1"
				
				B1N->(DbSetOrder(2))
				If B1N->(MsSeek(xFilial("B1N") + M->B44_PROTOC + oBrwPro:FieldGet("B45_SEQB1N",nI))) .AND. !Empty(B1N->B1N_SEQMED)
					
					B7D->(DbSetOrder(3))
					If B7D->(MsSeek(xFilial("B7D") + B1N->(B1N_CODREC + B1N_CODMED)))
						
						If (B7D->B7D_QTDAUT - B7D->B7D_QTDEXE) < B1N->B1N_QTDMED

							MsgInfo(STR0295 + ALLTRIM(oBrwPro:FieldGet("B45_CODPRO",nI)) + STR0296) //"O medicamento referente a receita vinculada ao procedimento "," não possui saldo suficiente, "exclua o vinculo ou altere para um medicamento com saldo para concluir a autorização de reembolso"
							Return .F.
						EndIf
					EndIf
				EndIf
			EndIF
		EndIf 
	EndIf

	IF oBrwPro:aCols[nFor][nPosAbatPf] = '1'
		oBrwPro:aCols[nFor][nPosVlrTpf] := oBrwPro:aCols[nFor][nPosVlAbPf]
	EndIF

Next //31-08 fim

//Executa rotina generica de gravacao...                                   
If lRet
	
	//Grava																	 
	aRetBOW := VerAutGer(M->B44_PROTOC) //Verifica se já foi gerada guia para o protocolo do reembolso.
	
	lReembCriaBD5 := (len(aRetBOW) = 0)
	
	aRetorno := PLSA090Grv(	oBrwPro:aCols,;
							oBrwPro:aHeader,;
							aDadBEA,;
							nOpc,;
							oBrwPro:aVetTrab,;
							aChaveGen,;
							M->B44_USUARI,;
							M->B44_DATPRO,;
							M->B44_HORPRO,;
							M->B44_MATUSA,;
							M->B44_ANOPAG,;
							M->B44_MESPAG,;
							'04',;
							.F.,;
							oBrwCri:aCols,;
							oBrwCri:aHeader,;
							oBrwCri:aVetTrab,;
							Nil,;
							"1",;
							IIf(nOpc==K_Incluir,GetNewPar("MV_PLSPREM","9000"),B44->B44_CODLDP),;
							Nil,;
							"",;
							"B44",;
							Nil,Nil,NIL,;
							"B45",;
							"B46",;
							Nil,Nil,NIL,;
							lGerSenha,;
							.F.,;
							nil,NIL,nil,nil,nil,;
							oBrwComp,;
							"B44",.t.,,;
							oEnchoice,/*lIncNeg*/,/*cNFSS*/,/*lSolicit*/,/*cTpGrv*/,/*aColsDF*/,/*aHeaderDF*/,/*aVetDF*/,/*aDaSenPro*/,/*lGuiHoRe*/,/*aMatBd6*/,;
					 		/*aMatCom*/,/*lResInt*/,/*cAliasCmp*/,/*lOdontoWeb*/,/*cNumLib*/,/*cArqImp*/,/*lEvoSadt*/,/*cSituac*/,;
							IIF(M->B44_FORPAG == "0",.F.,  lProtoc),;
							/*aPartic*/,/*aColsB4B*/,;
							/*aHeaderB4B*/,/*aVetB4B*/,/*cNumLibOd*/,/*lRecGlo*/,/*lPTUOnSol*/,/*cObsEvo*/,/*nNrSeqTR*/,/*cSenhaOpe*/,/*cOpeSolPTU*/,iif(!lReembCriaBD5, aRetBOW[5], "")/*cNewAut*/,;
							/*lPtuOnline*/,/*aCampCust*/,/*dValSen*/,/*lSUS*/,/*aArraySUS*/, lReembCriaBD5)//80

		//após a geração da autorização de reembolso o saldo é alterado na liberação SADT
		If B45->(FieldPos("B45_SEQBE2")) > 0  
			nAcols := Len(oBrwPro:aCols)
			
			For nQtdProc := 1 To nAcols

				If nOpc == K_Incluir .AND. !EMPTY(oBrwPro:FieldGet("B45_NUMLIB",nQtdProc)) .AND. oBrwPro:FieldGet("B45_STATUS",nQtdProc) == "1"
					PLSAtuLib(oBrwPro:FieldGet("B45_NUMLIB",nQtdProc),oBrwPro:FieldGet("B45_SEQBE2",nQtdProc),oBrwPro:FieldGet("B45_CODPAD",nQtdProc),; 
							  oBrwPro:FieldGet("B45_CODPRO",nQtdProc),oBrwPro:FieldGet("B45_QTDPRO",nQtdProc),NIL,.F.,.F.) 
				EndIf
			Next
		EndIf     

		if !lReembCriaBD5 .and. nOpc <> K_Excluir //Se não gera Guia tem que atualizar os vinculos. 

			cChavGui := aRetorno[2] + aRetorno[3] + aRetorno[4] + aRetorno[5]

			B44->(DbSetOrder(1))
			If B44->(MsSeek(xFilial("B44")+cChavGui))
				
				While ! B44->(Eof()) .And. xFilial("B44")+cChavGui == B44->(B44_FILIAL+B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT)

					B44->(RecLock("B44",.F.))
						B44->B44_CODLDP := aRetBOW[13]
						B44->B44_CODPEG := aRetBOW[14]
						B44->B44_NUMGUI := aRetBOW[15]						
						B44->B44_ORIMOV := aRetBOW[16]
						
						B44->B44_OPEMOV := aRetBOW[2]
						B44->B44_MESAUT := aRetBOW[4] 
						B44->B44_ANOAUT := aRetBOW[3]
						B44->B44_NUMAUT := aRetBOW[5]
			        B44->(MsUnLock())
			        
			        cChavBD6 :=  B44->(B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI)
			        
			        B44->(DbSkip())
			    Enddo
			Endif				    	
			
			BD5->(DbSetOrder(1))
			
			If BD5->(MsSeek(xFilial("BD5") + cChavBD6))			
				While BD5->( BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO) == xFilial("BD5") + cChavBD6  .AND. !BD5->(EoF())
					BD5->( RecLock("BD5",.F.) )
						BD5->BD5_FASE := "4" //Alterando Para Faturada
			        BD5->( MsUnLock() )
				BD5->(DbSkip())
				enddo
			endif
			
			B45->(DbSetOrder(1))
			If B45->(MsSeek(xFilial("B45")+cChavGui))
				
				cChavBD6 += "5" //Origem movto Offline
						
			    BD6->(DbSetOrder(1))		        		
			    If BD6->(MsSeek(xFilial("BD6") + cChavBD6))	
			    		
			    	While BD6->( BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6") + cChavBD6  .AND. !BD6->(EoF())		//Para cada procedimento
			    		
			    		BD6->( RecLock("BD6",.F.) )
			    			BD6->BD6_STATUS := "0" //Alterando Status para Não Autorizado. Abaixo os itens aprovados terão seu status alterado para autorizado.
			    			BD6->BD6_FASE 	:= "4" //Alterando Para Faturada
			        	BD6->( MsUnLock() )
			        
			        	If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO)))
							
							While !BD7->(Eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO) == ;
													  BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO)
								
								BD7->(RecLock('BD7',.f.))
								BD7->BD7_FASE := '4'
								BD7->( MsUnlock() )
							BD7->(DbSkip())
							EndDo
							
						EndIf
			        	
			        BD6->(DbSkip())
			        enddo
			    endif			
			
				While ! B45->(Eof()) .And. xFilial("B45")+cChavGui == B45->(B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT)
		        	
					B45->(RecLock("B45",.F.))
						B45->B45_CODLDP := aRetBOW[13]
						B45->B45_CODPEG := aRetBOW[14]
						B45->B45_NUMERO := aRetBOW[15]						
						B45->B45_ORIMOV := aRetBOW[16]
						
						B45->B45_OPEMOV := aRetBOW[2]
						B45->B45_MESAUT := aRetBOW[4] 
						B45->B45_ANOAUT := aRetBOW[3]
						B45->B45_NUMAUT := aRetBOW[5]						
						
			        B45->(MsUnLock())
		
			        //Atualiza Status da BD6. FASE/SITUACAO
					cChavBD6 :=  B45->(B45_OPEMOV+B45_CODLDP+B45_CODPEG+B45_NUMERO+"5" /*Origem Movto Classes*/+alltrim(B45_SEQB1N))
					
		        	BD6->(DbSetOrder(1))
		        		
		        	If BD6->(MsSeek(xFilial("BD6") + cChavBD6))			
		        		While BD6->( BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) == xFilial("BD6") + cChavBD6  .AND. !BD6->(EoF())		//Para cada procedimento
		        			BD6->( RecLock("BD6",.F.) )
		        				BD6->BD6_STATUS := B45->B45_STATUS
		        				BD6->BD6_NIVAUT := B45->B45_NIVAUT
		        				BD6->BD6_NIVCRI := B45->B45_NIVCRI
		        			BD6->( MsUnLock() )
		        			
		        			BD6->(DbSkip())
		        		enddo
		        	endif
		        	
			        B45->(DbSkip())
			    Enddo
			Endif
			
			B47->(DbSetOrder(1))
			If B47->(MsSeek(xFilial("B47")+cChavGui))
				While ! B47->(Eof()) .And. xFilial("B47")+cChavGui == B47->(B47_FILIAL+B47_OPEMOV+B47_ANOAUT+B47_MESAUT+B47_NUMAUT)
				
					B47->(RecLock("B47",.F.))
						B47->B47_CODOPE := aRetBOW[2]
						B47->B47_CODLDP := aRetBOW[13]
						B47->B47_CODPEG := aRetBOW[14]
						B47->B47_NUMERO := aRetBOW[15]
						B47->B47_ORIMOV := aRetBOW[16]
						
						B47->B47_OPEMOV := aRetBOW[2]
						B47->B47_MESAUT := aRetBOW[4] 
						B47->B47_ANOAUT := aRetBOW[3]
						B47->B47_NUMAUT := aRetBOW[5]
					B47->(MsUnLock())
					
					B47->(DbSkip())
				Enddo
			Endif

			If Len(aRetBOW ) >= 15
				cChavBD6 := aRetBOW[2] + aRetBOW[13] + aRetBow[14] + aRetBOW[15] //M->(B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI) //+ "3"
				
				BD6->(DbSetOrder(1))
				BD7->(DbSetOrder(1))
					
			    If BD6->(MsSeek(xFilial("BD6") + cChavBD6))	
			    	
			    	aAcols := AClone(oBrwComp:acols)
			    		
			    	While BD6->( BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == xFilial("BD6") + cChavBD6  .AND. !BD6->(EoF())		//Para cada procedimento
			    		
			    		//busca por sequencial pois podem existir eventos com o mesmo código
			        	If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
							
							While !BD7->(Eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
													  BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
								
								//localiza o sequencial do primeiro item do BD7 que nem sempre está em ordem
								nSeqComp := Ascan( oBrwComp:acols,{|x| x[1] == BD7->BD7_SEQUEN } )
								
								//confirma se a posição do acols corresponde ao sequencial da BD7 posicionada
								If oBrwComp:acols[nSeqComp][GDFieldPos("B47_SEQUEN", oBrwComp:aHeader)] == BD7->BD7_SEQUEN
									
									BD7->(RecLock('BD7',.F.))
									
									BD7->BD7_LIBERA := "0"
									BD7->BD7_BLOPAG := "0"
									BD7->BD7_DTANAL := M->B44_DTDIGI
									BD7->BD7_PROTOC := M->B44_PROTOC
									BD7->BD7_LOCATE := M->B44_LOCATE
									BD7->BD7_NOMRDA := M->B44_NOMRDA
									BD7->BD7_CONEMP := M->B44_CONEMP
									BD7->BD7_VERCON := M->B44_VERCON
									If empty(BD7->BD7_DTDIGI)
										BD7->BD7_DTDIGI := IIF(empTy(M->B44_DTDIGI), Date(), M->B44_DTDIGI)
									EndIf
									BD7->BD7_DTCTBF := IIF( empTy(BD7->BD7_LAPRO), BD7->BD7_DTDIGI, Date())

									If oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)] == 0
										BD7->BD7_VLRPAG := oBrwComp:acols[nSeqComp][GDFieldPos("B47_VLRPAG", oBrwComp:aHeader)]
										BD7->BD7_VLRAPR := oBrwComp:acols[nSeqComp][GDFieldPos("B47_VLRAPR", oBrwComp:aHeader)]
										BD7->BD7_VLRMAN := oBrwComp:acols[nSeqComp][GDFieldPos("B47_VLRMAN", oBrwComp:aHeader)]
										BD7->BD7_VLRGLO := oBrwComp:acols[nSeqComp][GDFieldPos("B47_VLRGLO", oBrwComp:aHeader)]
										BD7->BD7_VLRBPR := oBrwComp:acols[nSeqComp][GDFieldPos("B47_VLRBPR", oBrwComp:aHeader)]
										BD7->BD7_VLRTPF := oBrwComp:acols[nSeqComp][GDFieldPos("B47_VLRTPF", oBrwComp:aHeader)]
									Else
										BD7->BD7_VLRPAG := oBrwPro:acols[nI][GDFieldPos("B45_VLRPAG", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
										BD7->BD7_VLRAPR := oBrwPro:acols[nI][GDFieldPos("B45_VLRAPR", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
										BD7->BD7_VLRMAN := oBrwPro:acols[nI][GDFieldPos("B45_VLRMAN", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
										BD7->BD7_VLRGLO := oBrwPro:acols[nI][GDFieldPos("B45_VLRGLO", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
										BD7->BD7_VLRBPR := oBrwPro:acols[nI][GDFieldPos("B45_VLRBPR", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
										BD7->BD7_VLRTPF := oBrwPro:acols[nI][GDFieldPos("B45_VLRTPF", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
										BD7->BD7_VLRBPF := oBrwPro:acols[nI][GDFieldPos("B45_VLRBPF", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
									EndIf

									BD7->BD7_ALIAUS := oBrwComp:acols[nSeqComp][GDFieldPos("B47_ALIAUS", oBrwComp:aHeader)]	
									BD7->BD7_PERCEN := oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
									BD7->BD7_COEFUT := oBrwComp:acols[nSeqComp][GDFieldPos("B47_COEFUT", oBrwComp:aHeader)]
									BD7->BD7_TIPCOE := oBrwComp:acols[nSeqComp][GDFieldPos("B47_TIPCOE", oBrwComp:aHeader)]
									BD7->BD7_PERAC  := oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERAC" , oBrwComp:aHeader)]
									BD7->BD7_CHAC   := oBrwComp:acols[nSeqComp][GDFieldPos("B47_CHAC"  , oBrwComp:aHeader)]
									BD7->BD7_REFTDE := oBrwComp:acols[nSeqComp][GDFieldPos("B47_REFTDE", oBrwComp:aHeader)]
									BD7->BD7_FATMUL := oBrwComp:acols[nSeqComp][GDFieldPos("B47_FATMUL", oBrwComp:aHeader)]
									BD7->BD7_UNITDE := oBrwComp:acols[nSeqComp][GDFieldPos("B47_UNITDE", oBrwComp:aHeader)]
									BD7->BD7_UTHRES := oBrwComp:acols[nSeqComp][GDFieldPos("B47_UTHRES", oBrwComp:aHeader)] 
									BD7->BD7_COEFPF := oBrwComp:acols[nSeqComp][GDFieldPos("B47_COEFPF", oBrwComp:aHeader)]
									
									BD7->( MsUnlock() )
								EndIf
								
								//deleta a posição salva para não confundir a busca dos proximos eventos
								ADEL (oBrwComp:acols, nSeqComp)
								
								//deleta posição nula do array
								ASIZE(oBrwComp:acols, LEN(oBrwComp:acols) - 1)
							
								BD7->(DbSkip())
							EndDo
						EndIf
			        	nI++
			        BD6->(DbSkip())
			        enddo
			    endif
			EndIf	
		
		//necessário gravar BD7 no reembolso pois o BD7 do reembolso não é gravado corretamente no PLSA750FUN
		//e se alterasse a função para o reembolso poderia comprometer todo o sistema, pois não é uma alteração simples
		ElseIf nOpc == K_Incluir 
		
			cChavBD6 :=  B44->(B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI)
			
			BD6->(DbSetOrder(1))
			BD7->(DbSetOrder(1))
				
		    If BD6->(MsSeek(xFilial("BD6") + cChavBD6))	
		    	
		    	aAcols     := AClone(oBrwComp:acols)
		    	nPosSeqIte := GDFieldPos("B45_SEQUEN", oBrwPro:aHeader) 
				nPosMatric := GDFieldPos("B45_MATRIC", oBrwPro:aHeader)
		    	
				While BD6->( BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == xFilial("BD6") + cChavBD6  .AND. !BD6->(EoF())		//Para cada procedimento
		    		
		    		//busca por sequencial pois podem existir eventos com o mesmo código
		        	If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
						
						While !BD7->(Eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
												  BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
							
							//localiza o sequencial do primeiro item do BD7 que nem sempre está em ordem
							nSeqComp := Ascan( oBrwComp:acols,{|x| x[1] == BD7->BD7_SEQUEN } )
							
							//confirma se a posição do acols corresponde ao sequencial da BD7 posicionada
							If oBrwComp:acols[nSeqComp][GDFieldPos("B47_SEQUEN", oBrwComp:aHeader)] == BD7->BD7_SEQUEN
								
								BD7->(RecLock('BD7',.F.))
								
								BD7->BD7_LIBERA := "0"
								BD7->BD7_BLOPAG := "0"
								BD7->BD7_DTANAL := M->B44_DTDIGI
								BD7->BD7_PROTOC := M->B44_PROTOC
								BD7->BD7_LOCATE := M->B44_LOCATE
								BD7->BD7_NOMRDA := M->B44_NOMRDA
								BD7->BD7_CONEMP := M->B44_CONEMP
								BD7->BD7_VERCON := M->B44_VERCON
								If empty(BD7->BD7_DTDIGI)
									BD7->BD7_DTDIGI := IIF(empTy(M->B44_DTDIGI), Date(), M->B44_DTDIGI)
								EndIf
								BD7->BD7_DTCTBF := IIF( empTy(BD7->BD7_LAPRO), BD7->BD7_DTDIGI, Date())

								If oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)] == 0
									BD7->BD7_VLRPAG := oBrwComp:acols[nSeqComp][GDFieldPos("B47_VLRPAG", oBrwComp:aHeader)]
									BD7->BD7_VLRAPR := oBrwComp:acols[nSeqComp][GDFieldPos("B47_VLRAPR", oBrwComp:aHeader)]
									BD7->BD7_VLRMAN := oBrwComp:acols[nSeqComp][GDFieldPos("B47_VLRMAN", oBrwComp:aHeader)]
									BD7->BD7_VLRGLO := oBrwComp:acols[nSeqComp][GDFieldPos("B47_VLRGLO", oBrwComp:aHeader)]
									BD7->BD7_VLRBPR := oBrwComp:acols[nSeqComp][GDFieldPos("B47_VLRBPR", oBrwComp:aHeader)]
									BD7->BD7_VLRTPF := oBrwComp:acols[nSeqComp][GDFieldPos("B47_VLRTPF", oBrwComp:aHeader)]
								Else
									BD7->BD7_VLRPAG := oBrwPro:acols[nI][GDFieldPos("B45_VLRPAG", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
									BD7->BD7_VLRAPR := oBrwPro:acols[nI][GDFieldPos("B45_VLRAPR", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
									BD7->BD7_VLRMAN := oBrwPro:acols[nI][GDFieldPos("B45_VLRMAN", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
									BD7->BD7_VLRGLO := oBrwPro:acols[nI][GDFieldPos("B45_VLRGLO", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
									BD7->BD7_VLRBPR := oBrwPro:acols[nI][GDFieldPos("B45_VLRBPR", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
									BD7->BD7_VLRTPF := oBrwPro:acols[nI][GDFieldPos("B45_VLRTPF", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]														
									BD7->BD7_VLRBPF := oBrwPro:acols[nI][GDFieldPos("B45_VLRBPF", oBrwPro:aHeader)] /100 * oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
								EndIf

								
								BD7->BD7_ALIAUS := oBrwComp:acols[nSeqComp][GDFieldPos("B47_ALIAUS", oBrwComp:aHeader)]	
								BD7->BD7_PERCEN := oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERCEN", oBrwComp:aHeader)]
								BD7->BD7_COEFUT := oBrwComp:acols[nSeqComp][GDFieldPos("B47_COEFUT", oBrwComp:aHeader)]
								BD7->BD7_TIPCOE := oBrwComp:acols[nSeqComp][GDFieldPos("B47_TIPCOE", oBrwComp:aHeader)]
								BD7->BD7_PERAC  := oBrwComp:acols[nSeqComp][GDFieldPos("B47_PERAC" , oBrwComp:aHeader)]
								BD7->BD7_CHAC   := oBrwComp:acols[nSeqComp][GDFieldPos("B47_CHAC"  , oBrwComp:aHeader)]
								BD7->BD7_REFTDE := oBrwComp:acols[nSeqComp][GDFieldPos("B47_REFTDE", oBrwComp:aHeader)]
								BD7->BD7_FATMUL := oBrwComp:acols[nSeqComp][GDFieldPos("B47_FATMUL", oBrwComp:aHeader)]
								BD7->BD7_UNITDE := oBrwComp:acols[nSeqComp][GDFieldPos("B47_UNITDE", oBrwComp:aHeader)]
								BD7->BD7_UTHRES := oBrwComp:acols[nSeqComp][GDFieldPos("B47_UTHRES", oBrwComp:aHeader)] 
								BD7->BD7_COEFPF := oBrwComp:acols[nSeqComp][GDFieldPos("B47_COEFPF", oBrwComp:aHeader)]
								
								BD7->( MsUnlock() )
							EndIf
							
							//deleta a posição salva para não confundir a busca dos proximos eventos
							ADEL (oBrwComp:acols, nSeqComp)
							
							//deleta posição nula do array
							ASIZE(oBrwComp:acols, LEN(oBrwComp:acols) - 1)
						
							BD7->(DbSkip())
						EndDo
					EndIf
		        	nI++

					nSequenIte := Ascan( oBrwPro:acols,{|x| x[nPosSeqIte] == BD6->BD6_SEQUEN } )

					BD6->(RecLock('BD6',.F.))
					BD6->BD6_TIPREG = substr(oBrwPro:acols[nSequenIte][nPosMatric],15,2)
					BD6->BD6_DIGITO = substr(oBrwPro:acols[nSequenIte][nPosMatric],17,1)
					BD6->( MsUnlock() ) 

		        BD6->(DbSkip())
		        enddo
		    endif
		Endif	 
EndIf

Return(lRet)

//------------------------------------------------------------------- 
/*/{Protheus.doc} VerAutGer
Verifica se já foi gerada guia para o protocolo do reembolso
@since 29/01/2018
@version P12
/*/
//-------------------------------------------------------------------
function VerAutGer(cProtoc)

	Local aRet := {}
	Local cChaveGui := ""
	
	if !empty(cProtoc)
	
		BOW->(DbSetOrder(1))
		
		If (BOW->(MsSeek(xFilial("BOW")+cProtoc))) .and. !empty(BOW->BOW_NUMAUT)
			aRet := {.T., BOW->BOW_OPEMOV, BOW->BOW_ANOAUT, BOW->BOW_MESAUT, BOW->BOW_NUMAUT, , , , M->B44_AUDITO = "1",,,, BOW->BOW_CODLDP, BOW->BOW_CODPEG, BOW->BOW_NUMGUI, BOW->BOW_ORIMOV}
		endif	
	endif

return aRet


/*/

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³P001SEQCRI³ Autor ³ Daher		            ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria Sequencia											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function P001SEQCRI()

LOCAL cRet := "001"

If ValType(oBrwPro) == "O"
   cRet := oBrwPro:FieldGet("B45_SEQUEN")
EndIf

Return(cRet)
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
Function PLSA001SEQ()

LOCAL cRet := ""

If ValType(oBrwPro) == "O"
  cRet := PLSINCRE("B45_SEQUEN",oBrwPro)
Else
  cRet := PLSINCRE("B45_SEQUEN")
Endif

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pl001REn  ³ Autor ³ Daher		            ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria Sequencia											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pl001REn()

Return oEnchoice

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pl001ROp  ³ Autor ³ Daher		            ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria Sequencia											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pl001ROp()

Return oBrwPro

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pl001RCr  ³ Autor ³ Daher		            ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria Sequencia											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pl001RCr()

Return oBrwCri

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pl001RCr  ³ Autor ³ Daher		            ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria Sequencia											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pl001AuF()

Return aAutFor

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA010AUT³ Autor ³ Daher		            ³ Data ³ 13.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do procedimento de reembolso                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA001Aut(cSequen,cCodPad,cCodPro,nQtdPro,cTipo,cAliasIte,cAliasCab,;
		cAliasCri,oBrwPro,oBrwCri,cCodExe,lChkPag,lPerFor,cPadInt,;
		cPadCon,cGrpInt,cAliasComp,lNProPac)
//cTipo
// "1" Default - Atualiza os M->BE2
// "2"         - Atualiza o oBroPro direto (geralmente executado via autorizacao consulta)

LOCAL nPos		:= 0
LOCAL nPos2		:= 0
LOCAL nPosAcu	:= 0
LOCAL nFor		:= 0
LOCAL nLin		:= 0
LOCAL cSQL		:= ""
LOCAL dDatPro	:= ctod('')
LOCAL aCliente	:= {}
LOCAL aValor	:= {}
LOCAL cOpeOri	:= ""
LOCAL cRegAte	:= ""
LOCAL nRecBR8 	  := 0
LOCAL nOrdBR8 	  := 0
LOCAL lRet        := .T.
LOCAL aRet        := {}
LOCAL aRetFun 	  := {}
LOCAL aHisCri     := {}
LOCAL aRetB43	  := {}
LOCAL aOldCodCri  := {}
LOCAL aAuxRetPro  := {}
LOCAL lForcou     := .F.
LOCAL lAuditoria  := .F.
LOCAL cCodGloAud  := __aCdCri051[1]
LOCAL lAto        := .F.
LOCAL aDadUsr     := {}
LOCAL aDadRDA     := {}
LOCAL cRDAEDI	  := ""
LOCAL cProRel     := ""
LOCAL nPrPrRl     := 0
LOCAL lLibEsp     := .F.
LOCAL cAteRNA     := "0"
LOCAL nInd		  := 0
LOCAL nI		  := 0
LOCAL lUnimeds    := IF(AllTrim(GETNEWPAR("MV_PLSUNI","1"))=="1",.T.,.F.)
LOCAL cRetGui     := ""
LOCAL cSomInt     := ""
LOCAL lFlag       := .F.
LOCAL cTipPreGui  := ""
LOCAL nOrdBA0     := BA0->(IndexOrd())
LOCAL nRecBA0     := BA0->(Recno())
LOCAL cChavLib    := ""
LOCAL cFilBEA 	  := ""
LOCAL cStrFil	  := ""
LOCAL cCodMot 	  := ""
LOCAL cObsMot 	  := ""
LOCAL cRegInt	  := ""
LOCAL cNivAlPro	  := "0"	//Procedimento
LOCAL cNivAlOpe	  := "0"	//Operador
LOCAL cNivAlCri	  := "0"	//Critica
LOCAL cNivAlCriA  := "0"	//Critica auxiliar
LOCAL lCriAdm	  := .F.	//Critica Administrativa
LOCAL lCriAud	  := .F.	//Critica Auditoria
LOCAL nCont		  := 0
LOCAL aRetElegi   := {}
LOCAL aAlerta     := {}
LOCAL lPteCriRe   := ExistBlock("PLSCRIRMB")    
LOCAL aRetCriRee  := {} 
LOCAL aVldBloq    := {} 
LOCAL nABlq       := 0 

DEFAULT cTipo     := "1"
DEFAULT cAliasIte := "B45"
DEFAULT cAliasCab := "B44"
DEFAULT cAliasCri := "B46"
DEFAULT cCodExe   := ""
DEFAULT lChkPag   := .T.
DEFAULT lPerFor   := .T.
DEFAULT cAliasComp:= "B47"

IF !EMPTY(M->B44_PROTOC) .AND. !EMPTY(M->B45_SEQB1N)

	//se a autorização é derivada de um protocolo
	//o sistema busca o beneficiário vinculado ao item selecionado.
			B1N->(dbSetOrder(2))
			B1N->(dbSeek(xFilial("B1N") + M->B44_PROTOC + M->B45_SEQB1N))
	aDadUsr := IIF(cAliasCab == "B44", PLSDADUSR(B1N->B1N_MATRIC,'1',.F.,dDatabase,,,"NAO_VALIDAR_CARTAO"),PLSGETUSR())
Else
	aDadUsr := PLSGETUSR()
EndIf

aDadRDA := PLSDADRDA(M->B44_OPERDA,M->B44_CODRDA,"1",dDataBase,Subs(M->B44_LOCATE,1,3),"")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se todos obrigatorios foram informados									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Obrigatorio(oEnchoice:aGets,oEnchoice:aTela)
	Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao informado															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(&("M->"+cAliasCab+"_USUARI")) .or. Len(aDadUsr) == 0
	Help("",1,"PL001006")
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao informado															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(&("M->"+cAliasCab+"_CODRDA")) .or. Len(aDadRDA) == 0 ;
	.or. !aDadRDA[1] //Posição que indica que o cadastro da rda está criticado
	Help("",1,"PL001007")
	Return(.F.)
Endif

If ValType(aDadRDA) == "A" .And. Len(aDadRDA) > 0 .And. aDadRda[23] == "1" .And. Empty(&("M->"+cAliasCab+"_REGEXE"))
	Help("",1,"PLSA090EXE")
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tabela Padrao															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BR8->(DbSetOrder(1))
BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))

If ValType(aDadUsr) == "A" .And. Len(aDadUsr) > 1 .And. aDadUsr[1] == .F.
	Help("",1,"PL001017")
	Return(.F.)
EndIf
cOpeOri 	:= aDadUsr[45]
cProRel    	:= &("M->"+cAliasIte+"_PROREL")
nPrPrRl    	:= &("M->"+cAliasIte+"_PRPRRL")
cSequen    	:= &("M->"+cAliasIte+"_SEQUEN")
cTipPreGui 	:= &("M->"+cAliasCab+"_TIPPRE")
dDatPro    	:= &("M->"+cAliasIte+"_DATPRO")



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se preencheu o grupo de internação eu sei que eh internação				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ! Empty( &("M->"+cAliasCab+"_GRPINT") )
	cRegAte := "1"
Else
	cRegAte := "2"
Endif

cRegInt := IIF(&(cAliasCab)->(FieldPos(cAliasCab+"_REGINT")) > 0,&("M->"+cAliasCab+"_REGINT"),"")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Por algum motivo o n esta mudando o valor quando e feito alteracao	     ³
//³ Alexande 11/08/2005													     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
n := oBrwPro:oBrowse:nAt

If ! empty(M->B44_PROTOC)

	If ! empty(B1N->B1N_NUMLIB)
		M->B45_NUMLIB := B1N->B1N_NUMLIB
	EndIf
	
EndIf

If ! EMPTY(M->B45_NUMLIB)

	//Seleciona chave e indice de acordo com a existência do campo B45_SEQBE2
	If B45->(FieldPos("B45_SEQBE2")) > 0 
				
		nIndice := 1
		cChvB45 := xFilial("BE2") + M->(B45_NUMLIB + B45_SEQBE2)	
	Else
		nIndice := 6
		cChvB45 := xFilial("BE2") + M->(B45_NUMLIB + B45_CODPAD + B45_CODPRO)
	EndIf 
				
	BE2->(dbSetOrder(nIndice)) 
	If BE2->(dbSeek(cChvB45 )) 

		If BE2->BE2_SALDO < M->B45_QTDPRO
			MsgInfo(STR0277 + CVALTOCHAR(BE2->BE2_SALDO) + STR0278) //"Quantidade digitada maior que saldo disponível (saldo: "|| ")" 
			Return .F.
		EndIf

		aRet := {.T.,1,BE2->BE2_NIVAUT,BE2->BE2_CHVNIV}
		lRet := .T.
	Else

		MsgInfo(STR0279)
		Return .F.
	EndIf
Else

	aRetFun := PLSAUTP(	dDatPro,;
						&("M->"+cAliasCab+"_HORPRO"),;
						cCodPad,;
						cCodPro,;
						nQtdPro,;
						aDadUsr,;
						0,;
						aDadRDA,;
						"1",;
						.T.,;
						&("M->"+cAliasCab+"_CID"),;
						.T.,;
						"1",;
						.T.,;
						&("M->"+cAliasCab+"_OPESOL"),;
						&("M->"+cAliasCab+"_CDPFSO"),;
						&("M->"+cAliasCab+"_ANOPAG"),;
						&("M->"+cAliasCab+"_MESPAG"),;
						cPadInt,;
						cPadCon,;
						cRegAte,;
						.T.,;
						cCodExe,;
						cProRel,;
						nPrPrRl,;
						nil,;
						nil,;
						nil,;
						nil,;
						nil,;
						cSequen,;
						nil,;
						.F.,; 
						"1",;
						nil,;
						NIL,;
						NIL,;
						cTipPreGui,;
						cGrpInt,;
						nil,nil,nil,nil,nil,nil,nil,nil,;
						.T.,;
						nil,;
						.F.,; 
						nil,nil,nil,nil,nil,nil,;
						.T.,;
						,nil,nil,;
						cRegInt,;
						nil,;
						lNProPac,;
						lBAU,;
						nil,nil,nil,nil,nil,nil,nil,nil,nil,;
						'04')
	
	aRet := aClone(aRetFun)

	aVldBloq := PLSA090USR(M->B45_MATRIC,M->B45_DATPRO,,"B44",.F.,.T.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.F.,.T.)	
	
	If !aVldBloq[1] .AND. !aRet[1]
		
		For nABlq := 1 To LEN(aVldBloq[2])
		
			AADD( aRet[2], aVldBloq[2][nABlq]  )
		Next
	
	ElseIf !aVldBloq[1] .AND. aRet[1]
		aRet := {.F., aVldBloq[2], "", M->B45_MATRIC }
	EndIf 
	
	//Ponto de entrada PLSCRIRMB 
	If lPteCriRe 
		  
		aAreaBOW := BOW->(GetArea())  
		aAreaB1N := B1N->(GetArea()) 
		aAreaB44 := B44->(GetArea()) 
		aAreaB45 := B45->(GetArea()) 
		aAreaB47 := B47->(GetArea()) 
		aAreaSE2 := SE2->(GetArea()) 
		
		aRetCriRee := ExecBlock("PLSCRIRMB",.F.,.F.,{aRet[1],aRet[2]})
		
		RestArea(aAreaBOW) 
		RestArea(aAreaB1N) 
		RestArea(aAreaB44) 
		RestArea(aAreaB45) 
		RestArea(aAreaB47) 
		RestArea(aAreaSE2) 
		
		aRet[1]    := aRetCriRee[1]
		aRet[2]    := IIF(aRetCriRee[1], "1", aRetCriRee[2])
	Endif
	
	lRet := aRet[1] 
endIf


//Limpa o browse caso troque o procedimento								 
For nFor := 1 To Len(oBrwCri:aCols)
	If oBrwCri:FieldGet(cAliasCri+"_SEQUEN",nFor) == cSequen .And. !Empty(oBrwCri:FieldGet(cAliasCri+"_DESGLO",nFor))
		oBrwCri:FieldPut(cAliasCri+"_SEQUEN","",nFor)
		oBrwCri:FieldPut(cAliasCri+"_CODGLO","",nFor)
		oBrwCri:FieldPut(cAliasCri+"_DESGLO","",nFor)
	EndIf
Next

If !(UPPER(AllTrim(FUNNAME())) == "PLSA001A")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa o browse caso troque o procedimento								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nFor := 1 To Len(oBrwComp:aCols)
		If oBrwComp:FieldGet(cAliasComp+"_SEQUEN",nFor) == cSequen
			oBrwComp:aCols[nFor][Len(oBrwComp:aCols[nFor])] := .T. //marco como deletado
		EndIf
	Next
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Paga as criticas														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lRet

	//Separa o que é critica negativa do que é alerta
	PLSALERTA(@aHisCri,@aRet,@aAlerta)

	lAuditoria	:= Ascan( aHisCri,{|x| x[1] == cCodGloAud } ) > 0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifico se a critica dele colocar o procedimento em auditoria			³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAuditoria .And. Len(aHisCri) > 0
		BCT->( DbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
		If BCT->( MsSeek( xFilial("BCT")+PlsIntPad()+aHisCri[1,1] ) )
			lAuditoria := Iif(BCT->BCT_AUDITO == "1",.T.,.F.)
		EndIf
	EndIf

	if lAuditoria
     //³B1O_CODPRO+B1O_TPGUIA+B1O_IDADE+B1O_QTDPRO

		/*Reembolso*/
		if PLSVLDEX(cCodPro+PLSRetAut()[1],aDadUsr[26],nQtdPro)
			lAuditoria := .F.
			aRet[1] := .T.
			aRet[2] := {}
			aRet[3] := "B1O"
			aHisCri := {}
		endif
	endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao seja autorizada analiso o campo que trata se e permitido forcar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPerFor .And. ! lRet
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ 1o Regra. somente se todos as criticas podem forcar e que entra na regra de forcar ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BR8->BR8_PERFOR <> "1"
		BCT->(DbSetOrder(1))
		For nFor := 1 To Len(aRet[2])
			If aRet[2][nFor][1] <> cCodGloAud
				If ! Empty(aRet[2][nFor][1])
					If BCT->(MsSeek(xFilial("BCT")+PlsIntPad()+aRet[2][nFor][1])) .And. BCT->BCT_PERFOR == "1"
						lFlag := .T.
					Else
						lFlag := .F.
						Exit
					Endif
				Endif
			Endif
		Next
	Else
		lFlag := .T.
	EndIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Se existe pelo menos uma critica que pode forcar entra nessa regra de forcar³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFlag

		lForcou := PLSMOVCRI("1",{cCodPad,cCodPro,BR8->BR8_DESCRI,cSequen},aHisCri,.T.)

		If lForcou

			aRet[1]	:= .T.
			lRet	 	:= .T.

			If FindFunction("PLLimpCCri") .And. aDadUsr[1] .And. Len(aDadUsr) >= 38
		     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		     //³ pega o aCodCri
		     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				aOldCodCri  := PLLimpCCri(.F.)
		     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		     //³ precisa disso pq antes a funcao nao retornava nada, e se o cliente receber o 090 sem o XAUT vai sar erro
		     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				If aOldCodCri == nil
					aOldCodCri  := {}
				Endif
		     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		     //³ limpa o a codCri
		     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				PLLimpCCri(.T.)
		     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		     //³ rodo para pegar o nivel de cobertura, vou precisar para calcular a co participacao
		     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				aAuxRetPro  := PLSAUTPDIR(aDadUsr[37],aDadUsr[38],cCodPad,cCodPro,aDadUsr,dDatPro,&("M->"+cAliasCab+"_HORPRO"),nil,nil,.F.,nil,nQtdPro,nil,nil,nil,;
					"","",aDadUsr[11],aDadUsr[12],.T.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
					{.F.,.F.,.F.,.F.,.T.,.T.,.T.,.F.,.F.,.F.,.F.})
		     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		     //³ limpa o a codCri
		     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				PLLimpCCri(.F.,.T.,aOldCodCri)

				If aAuxRetPro[1] .And. Len(aAuxRetPro) >= 4 .And. Len(aRet) >= 4
					aRet[3] := aAuxRetPro[3]
					aRet[4] := aAuxRetPro[4]
				EndIf
			EndIf

			lAuditoria := .F.

			If Len(aAutFor) >= 14
				nPos := Ascan(aAutFor,{|x| x[14]+x[2]+x[3] == cSequen+cCodPad+cCodPro})
			Else
				nPos := Ascan(aAutFor,{|x| x[2]+x[3] == cCodPad+cCodPro})
			EndIf

			If nPos == 0
				cCodMot := RetCodMot(cCodPad,cCodPro,aHisCri)[1]
				cObsMot := RetCodMot(cCodPad,cCodPro,aHisCri)[2]
				AaDd(aAutFor,{.T.,cCodPad,cCodPro,"","","","",0,BCS->(RetCodUsr()),Date(),Time(),cCodMot,cObsMot,cSequen})
			Endif
		Else
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Alimento as criticas...                                                  ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PLSA090ACR(aDadCri,aCabCri,aTrbCri,aHisCri,oBrwCri,cSequen,cAliasCri,oBrwPro)
		EndIf

	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ a partir do retorno monta dados da autorizacao...                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
&("M->"+cAliasIte+"_STATUS") := If(aRet[1],"1","0")
&("M->"+cAliasIte+"_NIVAUT") := If(aRet[1],aRet[3],Space(03))
&("M->"+cAliasIte+"_CHVNIV") := If(Len(aRet)>=4 .And. ValType(aRet[4]) == "C",aRet[4],Space(60))
&("M->"+cAliasIte+"_DESPRO") := BR8->BR8_DESCRI
&("M->"+cAliasIte+"_NIVCRI") := If(!aRet[1],aRet[3],Space(03))
&("M->"+cAliasIte+"_NIVEL")  := BR8->BR8_NIVEL
&("M->"+cAliasIte+"_AUDITO") := If(lAuditoria,"1","0")
&("M->"+cAliasIte+"_DNIVAU") := ""
&("M->"+cAliasIte+"_DNIVCR") := ""
&("M->"+cAliasIte+"_FORCAD") := If(lForcou,"1","0")
&("M->"+cAliasIte+"_VALORI") := "0"

If !Empty(&("M->"+cAliasIte+"_NIVAUT"))
	&("M->"+cAliasIte+"_DNIVAU") := PLSRETNCRI(&("M->"+cAliasIte+"_NIVAUT"), &("M->"+cAliasIte+"_CHVNIV"),&("M->"+cAliasIte+"_NIVCRI"))
Endif
If !Empty(&("M->"+cAliasIte+"_NIVCRI"))
	&("M->"+cAliasIte+"_DNIVCR") := PLSRETNCRI(&("M->"+cAliasIte+"_NIVAUT"), &("M->"+cAliasIte+"_CHVNIV"),&("M->"+cAliasIte+"_NIVCRI"))
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se existir critica exibe dialogo...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ! lRet .And. ! lPerFor ) .Or. ( ! lRet .And. ! lFLag .And. Len(aHisCri)>0 )
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta aHisCri...                                                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   PLSMOVCRI("1", {cCodPad, cCodPro, BR8->BR8_DESCRI, cSequen}, aHisCri,,,, !EMPTY(M->B44_PROTOC))

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Alimento as criticas...                                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  PLSA090ACR(aDadCri,aCabCri,aTrbCri,aHisCri,oBrwCri,cSequen,cAliasCri,oBrwPro)
EndIf

//Exibe os alertas do procedimento
If Len(aAlerta) > 0

   If MsgYesNo(STR0283) //"Existem alertas para o procedimento selecionado, deseja visualizar?"

     PLSMOVCRI("4",{cCodPad,cCodPro,BR8->BR8_DESCRI,cSequen},aAlerta,.F.)
   EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Find																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CursorArrow()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA001BOT³ Autor ³ Daher		            ³ Data ³ 13.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta botoes e keys...                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA001Bot(nOpc,cAliasEnc,oEncAut,oBrwPro,cAliasPro,bMatUsr,aButtons,oDlg,oBrwCri,oGet01,cGet01)

LOCAL lAnt
LOCAL bBotao01   := {|| A001Limpa(cAliasEnc,oEncAut,oBrwPro,cAliasEnc,,,.T.,"B46",oGet01,cGet01)}
LOCAL bBotao02   := {|| PLPOSFIN(Eval(bMatUsr),.T.,.T.) }
LOCAL bBotao03   := {|| PLHISMOV(Eval(bMatUsr)) }
LOCAL bBotao04   := {|| PLAltCli(Eval(bMatUsr)) }
LOCAL bBotao06   := {|| lAnt := Inclui,Inclui := .F., BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+&("M->"+cAliasEnc+"_USUARI"))), If(BA1->(Found()),PLSA260MOV("BA1",BA1->(RECNO()),K_Visualizar),Help("",1,"PLSA090USR")), Inclui := lAnt}
LOCAL bBotao07   := {|| BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+&("M->"+cAliasEnc+"_USUARI"))), If(BA1->(Found()),PLSBENEF("BA1",BA1->(RECNO()),K_Visualizar),Help("",1,"PLSA090USR")) }
LOCAL bBotao08   := {|| PLSA090ACO(cAliasEnc,oEncAut,oBrwCri,oBrwPro) }
LOCAL bBotao10   := {|| BA3->(DbSetOrder(1)), BA3->(MsSeek(xFilial("BA3")+Subs(&("M->"+cAliasEnc+"_USUARI"),1,14))), If(BA3->(Found()),ExeQuest(),Help("",1,"PLSA090QUE")) }
LOCAL bBotao11   := {|| PLSMSGCA(Eval(bMatUsr)) }
LOCAL aDadRda    := PLSGETRDA()
LOCAL aPTBot	 := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.}
LOCAL oBotao
LOCAL aPtoEntrB1
LOCAL aPtoEntrB2
LOCAL cCodCri

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir
	aadd(aButtons,{"S4WB004N",bBotao01,STR0017,STR0018}) //"Limpar Tela - <F5>"###"Limpa" //"Limpar Tela - <F5>"###"Limpa"
	SetKey(VK_F5,bBotao01)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para desabilitar BOTOES PARA um grupo de operadores	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLSBUTOP")
	aPTBot := ExecBlock("PLSBUTOP",.F.,.F.,{"PLSA001"})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botoes																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aPTBot[1]
	aadd(aButtons,{"SALARIOS",bBotao02,STR0019,STR0020})  //"Posicao Financeira - <F6>"###"Financ" //"Posicao Financeira - <F6>"###"Financ"
	SetKey(VK_F6,bBotao02)
EndIf

If aPTBot[2]
	aadd(aButtons,{"RELATORIO",bBotao03,STR0021,STR0022}) //"Historico de Movimentacao - <F7>"###"Historico" //"Historico de Movimentacao - <F7>"###"Historico"
	SetKey(VK_F7,bBotao03)
EndIf

If aPTBot[5]
	aadd(aButtons,{"POSCLI",bBotao04,STR0023,STR0024}) //"Alterar Dados do Cliente - <F8>"###"Cliente" //"Alterar Dados do Cliente - <F8>"###"Cliente"
	SetKey(VK_F8,bBotao04)
EndIf

If aPTBot[4]
	aadd(aButtons,{"GROUP",bBotao06,STR0025,STR0026}) //"Dados da Familia - <F10>"###"Familia" //"Dados da Familia - <F10>"###"Familia"
	SetKey(VK_F10,bBotao06)
EndIf

If aPTBot[6]
	aadd(aButtons,{"RESPONSA",bBotao07,STR0027,STR0028}) //"Dados da vida do beneficiario - <F11>"###"Benef." //"Dados da vida do beneficiario - <F11>"###"Benef."
	SetKey(VK_F11,bBotao07)
EndIf

If aPTBot[7]
	aadd(aButtons,{"VERNOTA",bBotao11,STR0029,STR0030}) //"Grupo de carencia"###"GrupoCa" //"Grupo de carencia"###"GrupoCa"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao Hist Criticas Forcadas											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Visualizar
	aadd(aButtons,{"S4WB010N",{ || PLS090FOR("B44","B45",oBrwPro) },"Hist. Criticas Forçadas","Crit. Forçadas"})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta outros botoes de apoio...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 030,002 BTNBMP oBotao RESOURCE "NOTE" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0031 ACTION PLSRTGCUSR(&("M->"+cAliasEnc+"_USUARI")) //"Grupos de Cobertura" //"Grupos de Cobertura"
@ 065,002 BTNBMP oBotao RESOURCE "ANALITICO" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0032 ACTION Eval(bBotao10) //"Visualizar entrevista qualificada do usuario" //"Visualizar entrevista qualificada do usuario"
@ 100,002 BTNBMP oBotao RESOURCE "PMSRELA" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0033 ACTION PLSCONRDA() //"Pesquisar rede de atendimento por parametros" //"Pesquisar rede de atendimento por parametros"
nLin := 100
If  FindFunction("PLSC005")
	nLin += 35
	@ nLin,002 BTNBMP oBotao RESOURCE "S4WB016N" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0034 ACTION Eval( {||  BA1->(DbSetOrder(2)),; //"Consultar Cobertura/Carencia"
	BA1->(MsSeek(xFilial("BA1")+Eval(bMatUsr))),;
		PLSC005()} ) //"Consultar Cobertura/Carencia"
Endif
If  FindFunction("PL169HIST")
	nLin += 35
	@ nLin,002 BTNBMP oBotao RESOURCE "HISTORIC" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0035 ACTION PL169HIST() //"Historico Transferencia" //"Historico Transferencia"
Endif

If GetNewPar("MV_PLRN395","0") == "1"
	If nOpc == K_Visualizar
   		cNumProto := B44->B44_PROATE
	EndIf
	nLin += 35
	@ nLin,002 BTNBMP oBotao RESOURCE "USER" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0280 ACTION P773AutInc("B44",@cNumProto,NIL,NIL,.T.,nOpc) //"Protocolo de Atendimento"
EndIf
If ExistBlock("PLS001B1")
	aPtoEntrB1 := ExecBlock("PLS001B1",.F.,.F.)
	nLin += 35
	@ nLin,002 BTNBMP oBotao RESOURCE aPtoEntrB1[1] SIZE 030 ,030 OF oDlg PIXEL MESSAGE aPtoEntrB1[2] ACTION Eval(aPtoEntrB1[3])
Endif

If ExistBlock("PLS001B2")
	aPtoEntrB2 := ExecBlock("PLS001B2",.F.,.F.)
	nLin += 35
	@ nLin,002 BTNBMP oBotao RESOURCE aPtoEntrB2[1] SIZE 030 ,030 OF oDlg PIXEL MESSAGE aPtoEntrB2[2] ACTION Eval(aPtoEntrB2[3])
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³P001ValRe ³ Autor ³ Daher		            ³ Data ³ 13.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valoriza o reembolso										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function P001ValRe(cAliCab,cAliPro,cAliCom,lProtoc,lAutomato)
LOCAL cCodInt    := &("M->"+cAliCab+"_OPEUSR")
LOCAL cCodRDA    := &("M->"+cAliCab+"_CODRDA")
LOCAL cCodEsp    := &("M->"+cAliCab+"_CODESP")
LOCAL dDatPro    := &("M->"+cAliPro+"_DATPRO")
LOCAL cHorPro    := &("M->"+cAliPro+"_HORPRO")
LOCAL cNivel   	 := &("M->"+cAliPro+"_NIVAUT")
LOCAL cChvNiv	 := &("M->"+cAliPro+"_CHVNIV")
LOCAL cTipPreFor := &("M->"+cAliCab+"_TIPPRE")
LOCAL cCodPad    := &("M->"+cAliPro+"_CODPAD")
LOCAL cCodPro    := &("M->"+cAliPro+"_CODPRO")
LOCAL nQtd       := &("M->"+cAliPro+"_QTDPRO")
LOCAL nQtdPro	 := &("M->"+cAliPro+"_QTDPRO")
LOCAL nPerVia    := &("M->"+cAliPro+"_PERVIA")
LOCAL cPadInt    := &("M->"+cAliPro+"_PADINT") 
LOCAL cPadCon    := &("M->"+cAliPro+"_PADCON")

LOCAL cRegAte    := If(!Empty(&("M->"+cAliPro+"_GRPINT")),"1","2")
LOCAL cGrpInt    := If(Type(cAliPro+"_TIPINT") <> "U",&("M->"+cAliPro+"_GRPINT")+&("M->"+cAliPro+"_TIPINT"),'')
LOCAL cRegInt    := If(Type(cAliPro+"_REGINT") <> "U",&("M->"+cAliPro+"_REGINT"),"")

LOCAL dDatCir    := &("M->"+cAliPro+"_DATPRO")
LOCAL cHorCir    := &("M->"+cAliPro+"_HORPRO")
LOCAL cMesPag	 := &("M->"+cAliCab+"_MESPAG")
LOCAL cAnoPag    := &("M->"+cAliCab+"_ANOPAG")
LOCAL cCid		 := &("M->"+cAliCab+"_CID")
LOCAL cProRel    := &("M->"+cAliPro+"_PROREL")
LOCAL nPrPrRl    := &("M->"+cAliPro+"_PRPRRL")
LOCAL cOpeRda    := &("M->"+cAliCab+"_OPERDA")
LOCAL cSequen    := &("M->"+cAliPro+"_SEQUEN")
LOCAL lCirurgico := If(&("M->"+cAliPro+"_PROCCI")=="0",.F.,.T.)
LOCAL cRegExe    := &("M->"+cAliCab+"_REGEXE")
LOCAL cEstExe    := &("M->"+cAliCab+"_ESTEXE")
LOCAL cCdPfRe    := &("M->"+cAliCab+"_CDPFRE")
LOCAL cCodLoc    := &("M->"+cAliCab+"_LOCATE")
LOCAL cUFAte     := If(Type(cAliCab+"_UFATE") <> "U",&("M->"+cAliCab+"_UFATE"),"")
LOCAL cMunAte    := If(Type(cAliCab+"_MUNATE") <> "U",&("M->"+cAliCab+"_MUNATE"),"")
LOCAL nVlrApr    := &("M->"+cAliPro+"_VLRAPR")
LOCAL lAneste    := If(Type(cAliCab+"_REEANE") <> "U",If(&("M->"+cAliCab+"_REEANE")== "1",.T.,.F.),.F.)
LOCAL aValor     := {}
LOCAL aCalCop	 := {}
LOCAL aCri		 := {}
LOCAL aDadUsr    := PLSGETUSR()
LOCAL aDadRDA	 := PLSGETRDA()
LOCAL nVlrTot    := 0
LOCAL nPercHEsp  := 0
LOCAL nInd       := 0
LOCAL cCodTab    := ""
LOCAL cAliasTab  := ""
LOCAL aVetTab    := {}
LOCAL aRdas		 := {}
LOCAL aRet		 := {}
LOCAL aRetPto	 := {}
LOCAL cFinAte    := If(Type(cAliCab+"_TIPPAC") <> "U",&("M->"+cAliCab+"_TIPPAC"),"")
LOCAL nFator	 := 0
LOCAL aUnd		 := {}
LOCAL lElgBnIte  := .T.
LOCAL nCri := 0
LOCAL nVLRTPF    := 0
Local cCrit:=""
Local aRetId33 := {}
Local nLenCri    := 0 
Local nI		 := 0 
Local lRetorno   := .T. 
Local nPoComp   := 0 
Local nValorGLo := 0

Default lAutomato  := .F. 
DEFAULT lProtoc := .F.

STATIC aCriProt   := {}
STATIC nProc	  := 0

//Contagem necessária para exibir corretamente a crítica 531 referente a configura~]ao da tabelam de reembolso na operadora.
If lProtoc
	nProc += 1
EndIf

If PLSALIASEX("B1N")
	If EMPTY(M->B45_EST) .OR. EMPTY(M->B45_CODMUN)
        If !lAutomato
		    Help("",1,"PL001014")
        EndIF
		Return
	Else
		cUFAte     := M->B45_EST
		cMunAte    := M->B45_CODMUN
	EndIf
	__lValora := .T.
	__nVlPg   := M->B45_VLRPAG
	__nGlsa   := M->B45_VLRGLO
	__VLBPF   := M->B44_VLABPF
EndIf
If cAliPro == "B45"

	IF FUNNAME() == "PLSA001A" .OR. !Empty(M->B44_PROTOC)	//	Se a Autorização de Reembolso foi chamada na inclusão do Protocolo, todos os gatilhos serão executados
		SX3->(DBSETORDER(1))
		SX3->(DBSEEK("B45"))
		WHILE !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == "B45"
			IF SX3->X3_TRIGGER == "S"
				__ReadVar := "M->" + SX3->X3_CAMPO
				__ReadVar := &(__ReadVar)
				IF ! EMPTY(__ReadVar)
					RunTrigger(1,,,, SX3->X3_CAMPO)
				ENDIF
			ENDIF
			SX3->(DBSKIP())
		ENDDO
		__ReadVar := ""
	ENDIF

	IF !EMPTY(M->B45_MATRIC)
			// Valora o procedimento a partir do beneficiário do item
		aDadUsr := PLSDADUSR(M->B45_MATRIC, "1", .T., dDatabase)
	ELSE
			//na verificação de elegibilidade é necessário que a matrícula
			//do beneficiário esteja configurada no item.
		Help("", 1 ,"PL001016")
		RETURN
	ENDIF
EndIf
If Empty(cCodPro) 
    If !lAutomato
	    Help("",1,"PL001009")
    EndIF
	Return
Endif
If Empty(cTipPreFor)
	BAU->(DbSetOrder(1))
	BAU->(MsSeek(xFilial("BAU")+cCodRDA))
	cTipPreFor := BAU->BAU_TIPPRE
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca a tabela de pagamento para este prestador...                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(aDadUsr) == "A" .And. Len(aDadUsr) > 1 .And. aDadUsr[1] == .F.
	Return(.F.)
Else	
	aVetTab := PLSRETTAB(cCodPad,cCodPro,dDatPro,cCodInt,cCodRDA,cCodEsp,"",;
		cCodLoc,dDatPro,"1",aDadUsr[45],aDadUsr[11],;
		nil,"2",aDadUsr,cTipPreFor,nil,nil,.T.,cUFAte,cMunAte)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se houve algum erro na pesquisa de Tabela de Honorario      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! aVetTab[1]
	aadd(aCri,{"","",aVetTab[1],aVetTab[2],"",aVetTab[5],cCodPad,cCodPro,cSequen})
Else
	cCodTab   := aVetTab[3]
	cAliasTab := aVetTab[4]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busco os registros b47 jah no acols									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRdas := PLS720IBD7(nil,nil,cCodPad,cCodPro,cCodTab,cOpeRda,cCodRDA,cRegExe,;
		nil,cEstExe,cCdPfRe,cCodEsp,cCodLoc,"4",cSequen,"1","04",;
		dDatPro,nil,nil,nil,oBrwComp,,,,,,,,,,,,,,,lAneste)

	//Valorar considerando grau de participação
	If !EMPTY(M->B45_GRAUPA)
		BD4->(dbSetOrder(1))
		If BD4->(dbSeek(xFilial("BD4") + cOpeRda + cCodTab + cCodPad + cCodPro))
			While BD4->(BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + BD4_CODPRO) == xFilial("BD4") + cOpeRda + cCodTab + cCodPad + cCodPro
				If BD4->BD4_CODTPA == M->B45_GRAUPA
					AADD(aUnd, aRdas[aScan(aRdas,{|x| x[1] == BD4->BD4_CODIGO})])
				EndIf
				BD4->(DbSkip())
			EndDo
		EndIf
	EndIf
//
If Empty(cPadInt)
  cPadInt := &("M->"+cAliCab+"_PADINT") 
Endif  
If Empty(cPadCon)
   cPadCon:= &("M->"+cAliCab+"_PADCON")
Endif
If  ! Empty( &("M->"+cAliCab+"_GRPINT") )
	cRegAte := "1"
Else
	cRegAte := "2"
Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo o valor do evento											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aValor := PLSCALCEVE(cCodPad,cCodPro,cMesPag,cAnoPag,cCodInt,cCodRDA,cCodEsp,"",;
						cCodLoc,nQtd,dDatPro,aDadUsr[48],cPadInt,cRegAte,nVlrApr,aDadUsr,cPadCon,;
						nil,cCodTab,cAliasTab,nil,nil,cHorPro,IIf(EMPTY(aUnd),aRdas,aUnd),nil,cProRel,nPrPrRl,;
						nil,.T.,dDatCir,cHorCir,nil,'04',.F.,0,nil,nil,;
						lCirurgico,nPerVia,nil,nil,nQtdPro,,,,,,,cRegInt,cFinAte,,cUFAte,cMunAte,,,,,lAneste)

	nValBase := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busco as criticas da valorizacao								     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nInd := 1 To Len(aValor[1])
		If ! Empty(aValor[1][nInd][4])
			If cCrit <> aValor[1][nInd][6]
			AaDd( aCri,{aValor[1][nInd][6],aValor[1][nInd][1],aValor[1][nInd][4],"","","",cCodPad,cCodPro,cSequen} )
		Endif
		cCrit:=aValor[1][nInd][6]
		Endif
	Next

	aAux := aClone( aValor[1] )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravo os valores da composicao do procedimento					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PLSBD701")
		
		aAreaBOW := BOW->(GetArea())  
		aAreaB1N := B1N->(GetArea()) 
		aAreaB44 := B44->(GetArea()) 
		aAreaB45 := B45->(GetArea()) 
		aAreaB47 := B47->(GetArea()) 
		aAreaSE2 := SE2->(GetArea()) 

		aRetPto := Execblock("PLSBD701",.F.,.F.,{aAux,aValor,aRdas,aCri,aVetTab,cCodPad,cCodPro,cMesPag,cAnoPag,aDadUsr,aDadRDA,dDatPro})
		
		RestArea(aAreaBOW) 
		RestArea(aAreaB1N) 
		RestArea(aAreaB44) 
		RestArea(aAreaB45) 
		RestArea(aAreaB47) 
		RestArea(aAreaSE2) 

		aAux 	:= aClone(aRetPto[1])
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Verifica se tem Fator de Reembolso
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	nFator := CalcFat(aDadUsr[11],aDadUsr[12],cCodPad,cCodPro,aDadUsr[37])

	//Valorar considerando grau de participação
	If !EMPTY(M->B45_GRAUPA)
		BD4->(dbSetOrder(1))
		If BD4->(dbSeek(xFilial("BD4") + cOpeRda + cCodTab + cCodPad + cCodPro))
			aUnd := {}
			While BD4->(BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + BD4_CODPRO) == xFilial("BD4") + cOpeRda + cCodTab + cCodPad + cCodPro
				If BD4->BD4_CODTPA == M->B45_GRAUPA
					AADD(aUnd, aAux[aScan(aRdas,{|x| x[1] == BD4->BD4_CODIGO})])
				EndIf
				BD4->(DbSkip())
			EndDo
		EndIf
	EndIf
	aRet := PLSA001BD7(IIf(EMPTY(aUnd),aAux,aUnd),"2",aValor[5],aCri,nFator,lAneste,lAutomato)
	nPercHEsp := aValor[5]

	//nVAlCalcCop --> Esse item foi retirado pois enviamos somente paramentros e nos retorna o valor ou a porcentagem 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Valor da coparticipacao
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	aCalCop := PLSCALCCOP(	cCodPad,cCodPro,cMesPag,cAnoPag,cCodRDA,cCodEsp,"",Subs(cCodLoc,1,3),nQtdPro,;
							dDatPro,.F.,"2",0,cGrpInt,aDadUsr,cPadInt,cPadCon,nil,cRegAte,/*nVAlCalcCop*/,.T.,.F.,cHorPro,aRdas,;
							cOpeRda,cTipPreFor,cProRel,nPrPrRl,{},cNivel,cChvNiv,nil,nil,cCid,nil,"04",,,,,,,,,,,,,,,,,cRegInt,cFinAte,aValor,,,,,,,lAneste)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Totalizo no cabeçalho do procedimento e da autorização				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	&("M->"+cAliPro+"_CODTAB") := cCodTab
	&("M->"+cAliPro+"_ALIATB") := cAliasTab
	&("M->"+cAliPro+"_PERHES") := nPercHEsp
	&("M->"+cAliPro+"_VALORI") := '1'
	M->B45_CODTAB := cCodTab
	M->B45_ALIATB := cAliasTab
	If M->B45_STATUS == "0"
		&("M->"+cAliPro+"_VLRPAG") := 0
		&("M->"+cAliPro+"_VLABPF") := 0
		&("M->"+cAliPro+"_VLRGLO") := IIF(M->B45_CONSVL == "1", aRet[2][4], aRet[2][5]) 
		&("M->"+cAliPro+"_VLRMAN") := 0
	Else
		&("M->"+cAliPro+"_VLRPAG") := aRet[2][1]
		&("M->"+cAliPro+"_VLRMAN") := MIN(aRet[2, 2], aRet[2 ,1])
		&("M->"+cAliPro+"_VLRGLO") := aRet[2][3]
	Endif
	If (cAliPro)->( FieldPos(cAliPro+"_VLRBPR")) > 0 .AND. M->B45_STATUS != "0"
		&("M->"+cAliPro+"_VLRBPR") := aRet[2][5]
		If (cAliPro)->( FieldPos(cAliPro+"_FATOR")) > 0
			&("M->"+cAliPro+"_FATOR") := nFator
		Endif
		If Len(aCri) == 0 .And. aCalCop[1]
			&("M->"+cAliPro+"_VLRBPF") := M->B45_VLRPAG  // se o percentual de participação for zero os demais tb serão zerados
			&("M->"+cAliPro+"_PERCPF") := aCalCop[5]
			&("M->"+cAliPro+"_VLRTPF") := If(M->B45_CONSVL == '1' .And. aCalCop[5] > 0, aRet[2][1], If(aCalCop[5] == 0, iif(aCalCop[9]>0,aCalCop[9],0), aCalCop[6]))////corrigir
			If (cAliPro)->( FieldPos(cAliPro+"_ALIAPF")) > 0
				&("M->"+cAliPro+"_ALIAPF") := aCalCop[15]
			Endif
			nVLRTPF := &("M->"+cAliPro+"_VLRTPF")
			If aCalCop[5] > 0 .And. aCalCop[6] > 0  
				nVLRTPF := (M->B45_VLRTPF * M->B45_PERCPF)/100
			ElseIf aCalCop[6] > 0 .and. aCalCop[9] == 0 
				nVLRTPF :=  If(aCalCop[5]=0,0,M->B45_VLRTPF) // se o percentual de participação for zero os demais tb serão zerados
			ElseIf aCalCop[5] > 0 
				nVLRTPF := (aRet[2][1] * M->B45_PERCPF)/100
			ElseIf aCalCop[9] > 0 
				nVLRTPF := aCalCop[9]
			EndIf
			IF aCalCop[19] > 0	//	Aplicar Franquia
				nVLRTPF := MIN(nVLRTPF, aCalCop[19])
			ENDIF
			&("M->"+cAliPro+"_VLRTPF") := nVLRTPF
			
			If MV_FRQUIA 
			
				PLID33Set(.F., &("M->"+cAliPro+"_VLRMAN"))
				aRetId33 := PLSID33(&("M->"+cAliPro+"_GUIPRI"), &("M->"+cAliPro+"_MATRIC"), Nil, &("M->"+cAliPro+"_VLRMAN"), .T.)
				
				If aRetId33[1] 
					If aRetId33[2] .AND. !aRetId33[3]
						nVLRTPF := 0
						&("M->"+cAliPro+"_PERCPF") := 0
						&("M->"+cAliPro+"_VLRTPF") := 0
						&("M->"+cAliPro+"_ALIAPF") := "BRT"					
					EndIf
				EndIf
				PLID33Set(.F., nil, nVLRTPF)
			EndIf 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Analise se Abate ou nao a co-participacao no Reembolso				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M->B45_ABATPF == '1' .And.  ( !MV_FRQUIA .OR. Empty(M->B45_GUIPRI) ) 
				If aCalCop[5] > 0 .And. aCalCop[6] > 0 
					&("M->"+cAliPro+"_VLRPAG") := aRet[2][1] - nVLRTPF
					If (cAliPro)->( FieldPos(cAliPro+"_VLABPF")) > 0
						&("M->"+cAliPro+"_VLABPF") := nVLRTPF //&("M->"+cAliPro+"_VLRTPF")
					Endif
				ElseIf aCalCop[6] > 0
					&("M->"+cAliPro+"_VLRPAG") := aRet[2][1] - nVLRTPF //M->B45_VLRTPF
					If (cAliPro)->( FieldPos(cAliPro+"_VLABPF")) > 0
						&("M->"+cAliPro+"_VLABPF") := &("M->"+cAliPro+"_VLRTPF")
					Endif
				ElseIf aCalCop[5] > 0 .or. aCalCop[9] > 0
	
					&("M->"+cAliPro+"_VLRPAG") := aRet[2][1] - nVLRTPF //(aRet[2][1] * M->B45_PERCPF) / 100 Alterado devido o valor já ser acertado no if ali de cima
					If (cAliPro)->( FieldPos(cAliPro+"_VLABPF")) > 0
						&("M->"+cAliPro+"_VLABPF") := &("M->"+cAliPro+"_VLRTPF")
						P001Vld(lAutomato) 
					Endif      
				EndIf
			ElseIf M->B45_CONSVL <> '1'
				If (cAliPro)->( FieldPos(cAliPro+"_VLABPF")) > 0	
					&("M->"+cAliPro+"_VLABPF") := 0
				Endif
				P001Vld(lAutomato) 
			EndIf

			If !lProtoc .AND. MV_FRQUIA 
				PLID33Set(.T.)
			EndIf
		EndIf
	Endif
EndIf
If Len(aCri) > 0
	
	If lAutomato
		Return .F.//Retorno pois houve critica na valoração
	EndIf
	
	if lProtoc

		//A exibição da crítica 531 possui um tratamento diferenciado quando a
		//geração da autorização de reembolso é chamada do protocolo de reembolso
		If aCri[1][6] == "531"
			AADD(aCriProt, aCri[1])
		Else

			//Alimenta grid de criticas com as criticas do array aCri
			//Altera a imagem que ilustra se o procedimento foi criticado ou nao:
			//Verde = OK
			//Vermelho = Possui critica.
			M->B45_IMGSTA := "DISABLE"
			M->B45_STATUS := "0"

			for nCri := 1 to Len(aCri)
				nPosSeqCri := aScan(oBrwCri:aCols,{ |x| x[1] == aCri[nCri][9]})
				if (nPosSeqCri <> 0 .And. !Empty(oBrwCri:aCols[nPosSeqCri][2])) .Or. (nPosSeqCri == 0)
					oBrwCri:AddBlank()
					nPosSeqCri := Len(oBrwCri:aCols)
				EndIf
				oBrwCri:SetPos(nPosSeqCri)
				oBrwCri:FieldPut("B46_SEQUEN",aCri[nCri][9])
				oBrwCri:FieldPut("B46_CODGLO",aCri[nCri][1])
				oBrwCri:FieldPut("B46_DESGLO",aCri[nCri][3])
				oBrwCri:FieldPut("B46_UNIMED",aCri[nCri][2])
			next
			oBrwCri:Atualiza()
			oBrwCri:ForceRefresh()
		EndIf
	Else
		PLSCRI001(aCri,"1","","B44",STR0036)//"Criticas da valorização."
	EndIf
Else
	If Type("oEncPLS") = "O" .and. !lAutomato
		oEncPLS:Refresh()
	EndIf
	if lProtoc .and. !lAutomato
		oSayD:Refresh()
		oSayF:Refresh()
		oSayH:Refresh()
	ElseIf !lAutomato
		Msginfo(STR0037)//"Valoração concluida com sucesso."

		If EMPTY(M->B45_CODPRO) .AND. !EMPTY(M->B44_PROTOC)
			M->B45_CODPRO := B1N->B1N_CODPRO
		EndIf
	EndIf
EndIf

//Caso todos os procedimentos tenham sido valorados, onde pelo menos um deles
// possui a crítica 531, o sistema não permitirá continuar com o reembolso até
//ajustar a tabela de reembolso na operadora para o procedimento selecionado
If !lAutomato
    If LEN(oBrwPro:aCols) == nProc .AND. LEN(aCriProt) > 0
    
    	MsgAlert("STR0302")//"Um ou mais procedimentos não possuem composição, os procedimentos sem composição estão identificados com a legenda azul (Sem composição) no protocolo de reembolso
    
    	nLenCri := LEN(aCriProt) 
    
    	B1N->(DbSetOrder(2))
    
    	For nI := 1 To nLenCri
    
    		B1N->(MsSeek(xFilial("B1N") + BOW->BOW_PROTOC + aCriProt[nI][9]))
    
    		If B1N->B1N_IMGSTA != "BR_AZUL"
    
    			B1N->(RecLock("B1N",.F.))
    			B1N->B1N_IMGSTA = "BR_AZUL"
    			B1N->(MsUnlock())
    		EndIf
    
    	Next 
    
    	_lSemComp := .T.
    
    	lRetorno := .F. 
    	aCriProt := {}
    	nProc := 0

    ElseIf LEN(oBrwPro:aCols) == nProc
    	//zera o contador de procedimentos valorados
    	nProc := 0
    EndIf
		
	If M->B45_STATUS == "0" .AND. !lProtoc
			
		nPoPro   := Ascan( oBrwComp:acols,{|x| x[1] == M->B45_SEQUEN } )
		nLeComp  := LEN(oBrwComp:acols) 
		nPo47Seq := GDFieldPos("B47_SEQUEN", oBrwComp:aHeader)
		nPo47Glo := GDFieldPos("B47_VLRGLO", oBrwComp:aHeader)
		nPo47Pag := GDFieldPos("B47_VLRPAG", oBrwComp:aHeader)
		nPo45Seq := GDFieldPos("B45_SEQUEN", oBrwPro:aHeader )

		For nPoComp := nPoPro To nLeComp
			
			If oBrwComp:acols[nPoComp][nPo47Seq] == M->B45_SEQUEN

				oBrwComp:acols[nPoComp][nPo47Glo] := oBrwComp:acols[nPoComp][nPo47Pag] 
				oBrwComp:acols[nPoComp][nPo47Pag] := 0

				If M->B45_CONSVL == "0" 
					nValorGLo += oBrwComp:acols[nPoComp][GDFieldPos("B47_VLRBPR", oBrwComp:aHeader)] 
				Elseif M->B45_CONSVL == "1" 
					nValorGLo += oBrwComp:acols[nPoComp][GDFieldPos("B47_VLRAPR", oBrwComp:aHeader)] 
				EndIf
			Else
				EXIT
			EndIf
		Next

		M->B45_VLRGLO := nValorGLo

		oBrwComp:ForceRefresh()
	EndIf 
EndIf

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PL001COR	³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Muda a cor do browse de acordo com a autorizacao...        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL001Cor(nLinha,aHeaderEd,aColsEd)

LOCAL nPos := PLRETPOS("B45_IMGSTA",aHeaderEd,.F.)

If nPos > 0
   aColsEd[nLinha,nPos] := If(M->B45_STATUS=="1","ENABLE","DISABLE")
Endif
aMatCriB := aClone(oBrwCri:aCols)
aMatComB := aClone(oBrwComp:aCols)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSCRI001  ³ Autor ³ Daher	          ³ Data ³ 22.10.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe dialogo com criticas de mudanca de fase              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Rotina de movimentacao 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCRI001(aCritica,cTipo,cNivel,cAliasPri,cTitulo,lProtReem)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg
LOCAL oGrupoCab
LOCAL oGrupoCri
LOCAL oCritica
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL nInd
LOCAL nAux

DEFAULT cTipo  := "1"
DEFAULT lProtReem := .F.
DEFAULT cTitulo := STR0011 //"Criticas"

DEFINE MSDIALOG oDlg TITLE cTitulo FROM ndLinIni,ndColIni TO ndLinFin+5,ndColFin OF GetWndDefault()

If cTipo == "1" .AND. !lProtReem
	@ 030,005 GROUP oGrupoCab TO 065,350 OF oDlg LABEL STR0038  COLOR CLR_HBLUE, CLR_HRED PIXEL       //" Dados da Guia " //" Dados da Autorização"

	@ 035,010 SAY oSay PROMPT STR0039   SIZE 220,010 OF oDlg PIXEL  //"Usuario     " //"Usuario     "
	@ 035,045 SAY oSay PROMPT &("M->"+cAliasPri+"_NOMUSR") SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE

	@ 045,010 SAY oSay PROMPT STR0040   SIZE 220,010 OF oDlg PIXEL  //"Prestador   " //"Prestador   "
	@ 045,045 SAY oSay PROMPT &("M->"+cAliasPri+"_NOMRDA") SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE

	@ 055,010 SAY oSay PROMPT STR0041   SIZE 220,010 OF oDlg PIXEL  //"Data Evento " //"Data Evento "
	@ 055,045 SAY oSay PROMPT &("M->"+cAliasPri+"_DATPRO") SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE

	@ 035,205 SAY oSay PROMPT STR0042   SIZE 220,010 OF oDlg PIXEL  //"Solicitante " //"Solicitante "
	@ 035,240 SAY oSay PROMPT &("M->"+cAliasPri+"_NOMSOL") SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE

	@ 055,205 SAY oSay PROMPT "CID         "   SIZE 220,010 OF oDlg PIXEL  //"CID         "
	@ 055,220 SAY oSay PROMPT &("M->"+cAliasPri+"_CID")     SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE

Endif

//tratamento adequado para exibir a crítica 531 quando uma autorização de reembolso
//for gerada diretamente de um protocolo
If !lProtReem

	@ 070,005 GROUP oGrupoCri TO 195,350 OF oDlg LABEL STR0043  COLOR CLR_HBLUE, CLR_HRED PIXEL        //" Criticas "

	oCritica := TcBrowse():New( 080, 012, 330, 110,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

	oCritica:AddColumn(TcColumn():New(STR0044,{ || aCritica[oCritica:nAt,7]+"-"+aCritica[oCritica:nAt,8] },; //"Procedimento"
		"@C",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))

	oCritica:AddColumn(TcColumn():New(STR0045,{ || aCritica[oCritica:nAt,2] },; //"Unidade"
		"@C",nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))

	oCritica:AddColumn(TcColumn():New(STR0046,{ || aCritica[oCritica:nAt,1] },; //"Codigo"
		"@C",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

	oCritica:AddColumn(TcColumn():New(STR0047,{ || aCritica[oCritica:nAt,3] },;  //"Critica"
		"@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))
Else

	@ 045,007 GROUP oGrupoCri TO 195,350 OF oDlg LABEL STR0043  COLOR CLR_HBLUE, CLR_HRED PIXEL       //" Criticas "

	oCritica := TcBrowse():New( 045, 012, 330, 145,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

	oCritica:AddColumn(TcColumn():New(STR0044,{ || aCritica[oCritica:nAt,7]+"-"+aCritica[oCritica:nAt,8] },; //"Procedimento"
		"@C",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))

	oCritica:AddColumn(TcColumn():New(STR0047,{ || aCritica[oCritica:nAt,6] },; //"Critica"
		"@C",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
EndIf

oCritica:AddColumn(TcColumn():New(STR0048,{ || aCritica[oCritica:nAt,4] },;  //"Descricao"
	"@C",nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))

oCritica:SetArray(aCritica)

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{},,,,,,.F.)

Return(nOpca)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL01CANCEL³ Autor ³ Daher			    ³ Data ³ 16.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Se cancelar na EditRecord retorna para o original		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PL01CANCEL()

oBrwCri:aCols := aClone(aMatCriB)
oBrwCri:oBrowse:oBrowse:nAt := Len(aMatCriB)
oBrwComp:aCols := aClone(aMatComB)
oBrwComp:oBrowse:oBrowse:nAt := Len(aMatComB)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina																	 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Pl001ok	 ³ Autor ³ Daher     		    ³ Data ³ 16.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ depois do ok na editrecord								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Pl001ok(a,b,c,d,nAt)

Local nI         := 0
Local nColAut    := 0
Local nColVlrPag := 0
Local nColVlrGlo := 0 
Local nLenB45    := 0 //04/06 ini
Local nLenB47    := 0
Local nB45STATUS := 0
Local nB45SEQUEN := 0
Local nB45VLRGLO := 0
Local nB47VLRGLO := 0
Local nB45       := 0
Local nB47		 := 0
Local nB47Pos    := 0 

If __lValora

	If __nVlPg != M->B45_VLRPAG

		If __nValRmb > 0
			__nValRmb -= __nVlPg
		EndIf

		__nValRmb += If(M->B45_STATUS == "1", M->B45_VLRPAG, 0)

		nColAut := PLRETPOS("B45_IMGSTA",oBrwPro:aHeader)
		nColVlrPag := PLRETPOS("B45_VLRPAG",oBrwPro:aHeader)
		__nValRmb := 0
		for nI := 1 to len(oBrwPro:aCols)
			If AllTrim(oBrwPro:aCols[nI][nColAut])=="ENABLE"
				__nValRmb += oBrwPro:aCols[nI][nColVlrPag]
			EndIf
		next nI
		
		oSayD:cCaption := "R$ " + ALLTRIM(TransForm(__nValRmb,PesqPict("BD6","BD6_VLRPAG")))
		oSayH:Refresh()
	EndIf

	If __nGlsa != M->B45_VLRGLO

		If __nValGlosa > 0
			__nValGlosa -= __nGlsa
		EndIf

		__nValGlosa += M->B45_VLRGLO
		
		nColVlrGlo := PLRETPOS("B45_VLRGLO",oBrwPro:aHeader)
		__nValGlosa := 0
		for nI := 1 to len(oBrwPro:aCols)
			__nValGlosa += oBrwPro:aCols[nI][nColVlrGlo]
		next nI
		
		oSayF:cCaption := "R$ " + ALLTRIM(TransForm(__nValGlosa,PesqPict("BD6","BD6_VLRPAG")))
		oSayH:Refresh()
	EndIf
EndIf
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Não permiti alterar os campos da guia		 						     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !GETNEWPAR("MV_PLREEDT",.F.)      // Parametro define se os campos da tabela B44 serão editaveis apos incluir procedimentos.
	PLS090RONL(.T.,oEnchoice)
Endif
__lValora := .F.

//Atualiza o valor de glosa da b45 de itens negados para calcular o valor total corretamente
nLenB45    := LEN(oBrwPro:aCols) 
nLenB47    := LEN(oBrwComp:acols)
nB45STATUS := GDFieldPos("B45_STATUS", oBrwPro:aHeader)
nB45SEQUEN := GDFieldPos("B45_SEQUEN", oBrwPro:aHeader)
nB45VLRGLO := GDFieldPos("B45_VLRGLO", oBrwPro:aHeader)
nB47VLRGLO := GDFieldPos("B47_VLRGLO", oBrwComp:aHeader)
nB47SEQUEN := GDFieldPos("B47_SEQUEN", oBrwComp:aHeader)

//varre a B45
For nB45 := 1 To nLenB45 

	//Calcula apenas os eventos negados		
	If oBrwPro:aCols[nB45][nB45STATUS] == "0"
		
		//posiciona na primeira posição da composição encontrada referente ao procededimento
		nB47Pos   := Ascan( oBrwComp:acols,{|x| x[nB47SEQUEN] == oBrwPro:aCols[nB45][nB45SEQUEN] } )
		oBrwPro:aCols[nB45][nB45VLRGLO] := 0
		
		// Esse tratamento se dá devido que há casos no reembolso que temos itens glosado e esses não carrega as composições do procedimentto - ValReProt
		If nB47Pos > 0
			//varre a B47 referente ao procedimento posicionado
			for nB47 := nB47Pos To nLenB47

				If oBrwComp:acols[nB47][nB47SEQUEN] == oBrwPro:aCols[nB45][nB45SEQUEN]

					oBrwPro:aCols[nB45][nB45VLRGLO] += oBrwComp:acols[nB47][nB47VLRGLO]
				Else
					EXIT
				EndIf
			Next
		Endif
	EndIf
Next

oBrwPro:Refresh() 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A001LIMPA³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa todos os campos da Enchoice e GetDados e Atualiza.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A001Limpa(cAlias,oEnchoice,oBrowse,cAliasGetd,lItens,lUsr,lPerg,cAliCri,oGet01,cGet01)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cField
LOCAL cCpoUsr   := cAlias+"_USUARI,"+cAlias+"_MATANT,"+cAlias+"_NOMUSR,"+cAlias+"_TIPUSR"
DEFAULT lItens  := .T.
DEFAULT lUsr    := .T.
DEFAULT lPerg   := .F.
DEFAULT cAliCri := "BEG"
DEFAULT oGet01  := nil
DEFAULT cGet01  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para escolha do usuario se limpa a guia ou somente os eventos e criticas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPerg
	If  Aviso(	STR0049, STR0050,{ "Sim", "Não"}, 2 ) == 1 //"Atenção"###"Deseja limpar os campos do FOLDER GUIA/OUTROS?"###"Sim"###"Nao" //"Atenção"###"Deseja limpar os campos dos folderes Guia/Outros?"
		lPerg := .F.
	Else
		lPerg := .T.
	EndIf
EndIf
If !lPerg
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Em todos os campo da enchoice zera conteudo...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX3->(DbSetOrder(1))
	IF SX3->(MsSeek(cAlias))
		While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias

			cField := AllTrim(SX3->X3_CAMPO)

			If ! (cField $ cAlias+"_ANOPAG,"+cAlias+"_MESPAG")
				If     cField $ cCpoUsr
					If lUsr
						M->&(cField) := CriaVar(cField)
					Endif
				Else
					M->&(cField) := CriaVar(cField)
				Endif
			Endif

			SX3->(DbSkip())
		Enddo
	Endif
EndIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa itens...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lItens .and. !lPerg
	A001Clr(cAliCri,oBrwCri)
	A001Clr(cAliasGetd,oBrowse)
	If !Empty(cGet01)
		A001Clr(cGet01,oGet01)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Enchoice...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRefresh := .T.
oEnchoice:oBox:Refresh()
oEnchoice:oBox:SetFocus()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ A001Clr      ³ Autor ³ Daher				³ Data ³ 26.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Limpa itens da autorizacao/liberacao                       ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A001Clr(cAlias,oBrowse)

Store COLS Blank cAlias TO oBrowse:aCols FROM oBrowse:aHeader
oBrowse:SetPos(1)
oBrowse:Atualiza()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ExeQuest   ³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ExeQuest()

Local nX
Local cSql 		:= ""
Local cChave 	:= ""
Local bOk 		:= {|| SetBAX(), PLSA530Mov("BXA",BXA->(Recno()),2,.F.,BA3->(Recno()))}
Local aCampos	:= {}
Local aBls		:= {}
Local cAlias 	:= ""

Private oBrwBXA
Private aRecBXA := {}

cAlias := GetNextAlias()
cSql := " SELECT * FROM " + RetSqlName("BXA")
cSql += " WHERE BXA_USUARI = '" + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) + "'"
cSql += " AND D_E_L_E_T_ = ' '"
cSql += " ORDER BY BXA_DATA"

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW Alias &(cAlias)

TcSetField(cAlias,"BXA_DATA","D")

If (cAlias)->(Eof())
	(cAlias)->(DbCloseArea())
	Help("",1,"PLSA090QUE")
	Return
Endif

// Cria Vetor com os resultados da query
While (cAlias)->(!Eof())
	cChave := xFilial("BAM")+(cAlias)->(BXA_PROQUE+BXA_CODQUE)

	aListAux := {(cAlias)->BXA_DATA, (cAlias)->BXA_NUMERO, (cAlias)->BXA_CODQUE, AllTrim(Posicione("BAM", 1, cChave, "BAM_DESCRI"))}
	aadd(aRecBXA, aListAux)

	(cAlias)->(DbSkip())
Enddo

DEFINE MSDIALOG oDlg FROM 0,0 TO 320,640 PIXEL TITLE "Entrevista Qualificada do Usuário"

// Cria objeto de fonte que sera usado na Browse
Define Font oFont Name 'Courier New' Size 0, -12

// Cria Browse
oBrwBXA := TCBrowse():New( 30 , 01, 320,140 ,,;
	{"Data","Número","Questionário","Descrição"},{50,50,50,50},;
	oDlg,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,,, )

// Aponta o vetor com as informacoes da query
oBrwBXA:SetArray(aRecBXA)

// Monta a linha a ser exibina no Browse
oBrwBXA:bLine := {||{ aRecBXA[oBrwBXA:nAt,01],;
	aRecBXA[oBrwBXA:nAt,02],;
	aRecBXA[oBrwBXA:nAt,03],;
	aRecBXA[oBrwBXA:nAt,04]}}

//-- LGPD --------
if objCENFUNLGP:isLGPDAt()
	aCampos := {"BXA_DATA","BXA_NUMERO","BXA_CODQUE","BAM_DESCRI" }
	aBls := objCENFUNLGP:getTcBrw(aCampos)
	oBrwBXA:aObfuscatedCols := aBls
endif
//----------------

// Evento de DuploClick
oBrwBXA:bLDblClick := bOk

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnChoiceBar(oDlg,bOK,{ || oDlg:End() },.F.)

(cAlias)->(DbCloseArea())

Return

Static Function SetBAX()

BXA->(DbSetOrder(1))//BXA_FILIAL+BXA_NUMERO
BXA->(DbSeek(xFilial("BXA")+aRecBXA[oBrwBXA:nAt,2]))

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A001Final ³ Autor ³ Daher				³ Data ³ 20.04.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibir dados da autorizacao/liberacao efetuada             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
static Function A001Final(cOpeMov,cAnoAut,cMesAut,cNumAut,cCodOpeG,cTipoGuia,oBrwPro,lAuditoria)

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fontes utilizadas somente nesta funcao...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFontNum NAME "Arial" SIZE 000,-016 BOLD
DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-019 BOLD
DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 BOLD

If lAuditoria
	Aviso( STR0051, ; //"Auditoria" //"Auditoria"
	STR0052,; //"Esta guia foi gravada e esta sendo analisada pela auditoria." //"Esta guia foi gravada e esta sendo analisada pela auditoria."
	{ "Ok" }, 2 )
	Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra Resumo da Autorizacao...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0053 FROM 009,000 TO 024,070 OF GetWndDefault()  //"Dados do reembolso "

nColAut := PLRETPOS("B45_IMGSTA",oBrwPro:aHeader)
aEval(oBrwPro:aCols,{ |aVet|  IF(!aVet[Len(oBrwPro:aHeader)+1],If(AllTrim(aVet[nColAut])=="ENABLE",nItensSIM++,nItensNAO++),nil) })

cNomUser := TransForm(M->B44_USUARI,PesqPict("BE1","BE1_USUARI"))+" - "+M->B44_NOMUSR
cNomRDA  := TransForm(M->B44_CODRDA,PesqPict("BE1","BE1_CODRDA"))+" - "+M->B44_NOMRDA
cSIM     := StrZero(nItensSIM,2)
cNAO     := StrZero(nItensNAO,2)

If nVlrPF > 0
	@ 063,151 SAY oSay PROMPT STR0054 SIZE 220,010 OF oDlg PIXEL //"Valor do Reembolso       R$" //"Valor do Reembolso       R$"
	@ 063,230 SAY oSay PROMPT NoRound(M->B44_VLRPAG,2) PICTURE PLPMONEY_P   SIZE 030,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE
EndIf

oBot01 := SButton():New(097, 005, 1, {|| oDlg:End() },,.T.)
oBot01:cToolTip := STR0055 //"Fechar Tela"

@ 007,005 SAY oSay PROMPT STR0004+" "+STR0056  SIZE 220,010 OF oDlg PIXEL FONT oFontNum //" Numero   " //"Reembolso"###" Numero   "
@ 006,095 SAY oSay PROMPT cOpeMov+"."+cAnoAut+"."+cMesAut+"."+cNumAut SIZE 220,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_HRED

If nItensSIM > 0 .And. ! Empty(M->B44_SENHA)
	@ 005,230 SAY oSay PROMPT STR0057  SIZE 220,010 OF oDlg PIXEL //"Senha" //"Senha"
	@ 013,214 SAY oSay PROMPT "[ "+M->B44_SENHA+" ]" SIZE 220,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_HRED
Endif

@ 025,005 SAY oSay PROMPT STR0058  SIZE 220,010 OF oDlg PIXEL //"Usuario              " //"Usuario              "
@ 025,065 MSGET cNomUser                           SIZE 205,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 043,005 SAY oSay PROMPT STR0059  SIZE 220,010 OF oDlg PIXEL //"Rede Atendimento     " //"Rede Atendimento     "
@ 043,065 MSGET cNomRDA                           SIZE 205,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 061,005 SAY oSay PROMPT STR0060  SIZE 220,010 OF oDlg PIXEL //"Itens "###"Autorizado"###"Liberado" //"Itens reembolsados"
@ 061,065 MSGET cSIM                               SIZE 004,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 079,005 SAY oSay PROMPT STR0061  SIZE 220,010 OF oDlg PIXEL  //"Itens NAO "###"Autorizado"###"Liberado" //"Itens não reembolsados"
@ 079,065 MSGET cNAO                               SIZE 004,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

ACTIVATE MSDIALOG oDlg CENTERED

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA001BD7³ Autor ³ Daher		            ³ Data ³ 13.02.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava os valores do reembolso						      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA001BD7(aAux,cLocalExec,nPercHEsp,aCri,nFator,lAneste,lAutomato)

LOCAL nAux       := 0
LOCAL nInd       := 0
LOCAL nI         := 1
LOCAL cKeyAux    := ""
LOCAL lRet       := .T.
LOCAL nDesconto  := 0
LOCAL nAcrescimo := 0
LOCAL nQtdCH     := 0
LOCAL lFlag      := .F.
LOCAL nUltimo  := 0
LOCAL nPercen  := 0
LOCAL nVlrPag  := 0  //Valor p/ Pagamento (nVlrMan-nVlrGlo)
LOCAL nVlrApr  := M->B45_VLRAPR  //Valor apresentado
LOCAL nVlrCon  := 0  //Valor contratado
LOCAL nVlrMan  := 0  //Valor Base p/ Pagamento
LOCAL nVlrGlo  := 0  //Valor da glosa
LOCAL nTTVlrPag := 0  //Valor p/ Pagamento (nVlrMan-nVlrGlo)
LOCAL nTTVlrCon := 0  //Valor contratado
LOCAL nTTVlrMan := 0  //Valor Base p/ Pagamento
LOCAL nTTVlrGlo := 0  //Valor Base p/ Pagamento
LOCAL nVlrPagPro:= 0
LOCAL nVlrManPro:= 0
LOCAL nVlrGloPro:= 0
LOCAL nVlrBprPro:= 0
LOCAL nVlrPagGui:= 0
LOCAL nVlrManGui:= 0
LOCAL nVlrGloGui:= 0
LOCAL nVlrBprGui:= 0
LOCAL cMatrUsr  := M->B44_USUARI
LOCAL dDatPro   := M->B45_DATPRO
LOCAL cHorPro   := M->B45_HORPRO
LOCAL cNomUsr   := M->B44_NOMUSR
LOCAL cMatAnt   := M->B44_MATANT
LOCAL cSequen 	:= M->B45_SEQUEN
LOCAL cCodPad   := M->B45_CODPAD
LOCAL cCodPro	:= M->B45_CODPRO
LOCAL nQtdPro	:= M->B45_QTDPRO
LOCAL nPosSeq   := 0
LOCAL nPosUnm   := 0
LOCAL nPosPer   := 0
LOCAL nPosPag   := 0
LOCAL nPosGlo	:= 0
LOCAL nPosMan	:= 0
LOCAL nPosBpr	:= 0
LOCAL nPosCoe	:= 0
LOCAL nPosItEv	:= 0
LOCAL nGrauPar	:= 0
LOCAL nPosSB45  := 0
LOCAL nPosTB45	:= 0
LOCAL cCodRDA 	:= ""
LOCAL cCodLoc 	:= ""
LOCAL cCodEsp 	:= ""
LOCAL cCdPfPr 	:= ""
LOCAL nPos      := 0
LOCAL nVlrTot   := 0
LOCAL aRetUnd
LOCAL nForUnd
LOCAL nVlrTotApr:= 0
LOCAL nVlrPagLiq:= 0
LOCAL nVlrDopTmp:= 0
LOCAL nVlrTxPg  := 0
LOCAL lExit		:= .F.
LOCAL nSlvMan   := 0
LOCAL nSlvPag   := 0
LOCAL nSlvGlo   := 0
LOCAL aBloq     := {}
LOCAL cCodUnd
LOCAL lFoundBD7
LOCAL nSomaPerc := 0
LOCAL nTotGlo   := 0
LOCAL nTotPag   := 0
LOCAL nTotMan   := 0
LOCAL lPagAlgum := .F.
LOCAL aUnid     := {}
LOCAL cSQL      := ""
LOCAL cTipoCon  := ""
LOCAL cMvPLSCAUX  := GetNewPar("MV_PLSCAUX","AUX")
LOCAL cMv_PLSCPA  := GetNewPar("MV_PLSCPA","PA")
LOCAL cMv_PLSCRCC := GetNewPar("MV_PLSCRCC","RCC")
LOCAL cMv_PLSDIFA := GetNewPar("MV_PLSDIFA",0.02)

DEFAULT nFator	:= 0
DEFAULT lAneste := .F.

If !lAutomato
	nPosSeq  := PLRETPOS("B47_SEQUEN",oBrwComp:aHeader)
	nPosUnm  := PLRETPOS("B47_CODUNM",oBrwComp:aHeader)
	nPosPer  := PLRETPOS("B47_PERCEN",oBrwComp:aHeader)
	nPosPag  := PLRETPOS("B47_VLRPAG",oBrwComp:aHeader)
	nPosGlo	 := PLRETPOS("B47_VLRGLO",oBrwComp:aHeader)
	nPosMan	 := PLRETPOS("B47_VLRMAN",oBrwComp:aHeader)
	nPosBpr	 := PLRETPOS("B47_VLRBPR",oBrwComp:aHeader)
	nPosCoe	 := PLRETPOS("B47_COEFUT",oBrwComp:aHeader)
	nPosItEv := PLRETPOS("B47_NLANC",oBrwComp:aHeader)
	nGrauPar := PLRETPOS("B47_CODTPA",oBrwComp:aHeader)
	nPosSB45 := PLRETPOS("B45_SEQUEN",oBrwPro:aHeader)
	nPosTB45 := PLRETPOS("B45_STATUS",oBrwPro:aHeader)
Else
	//Posiciono a tabela para utilização posterior
	B47->(DbSetOrder(1))
	B47->(MsSeek(xFilial("B47")+M->B45_OPEMOV + M->B45_ANOAUT + M->B45_MESAUT + M->B45_NUMAUT + M->B45_SEQUEN))
	
    nPosSeq   := 0
    nPosUnm   := 0
    nPosPer   := 0
    nPosPag   := 0
    nPosGlo	  := 0
    nPosMan	  := 0
    nPosBpr	  := 0
    nPosCoe	  := 0
    nPosItEv  := 0
    nGrauPar  := 0
    nPosSB45  := 0
    nPosTB45  := 0

EndIF

For nInd := 1 To Len(aAux)
	If AllTrim(aAux[nInd,1]) $ AllTrim(PLSCHMP())
		nQtdCH += aAux[nInd,9]
	Endif
Next

If !lAutomato
    For nI:=1 to Len(oBrwComp:aCols)
    	If oBrwComp:aCols[nI][nPosSeq] == cSequen .and. !oBrwComp:IsDeleted(nI)
    		oBrwComp:FieldPut("B47_VLRPAG",0 ,nI)
    		oBrwComp:FieldPut("B47_VLRMAN",0 ,nI)
    		oBrwComp:FieldPut("B47_VLRBPR",0 ,nI)
    		oBrwComp:FieldPut("B47_VLRGLO",0 ,nI)
    		oBrwComp:FieldPut("B47_PERCEN",0 ,nI)
    		oBrwComp:FieldPut("B47_DESCRI","",nI)
    	Endif
    Next
EndIf

// RDS    08/12/2010
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coleta informacoes para Busca do BD7 de origem, para utilizacao no reembolso³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->B44_NUMLIB)

	//Procuro a Liberação
	cSQL := "SELECT "+RetSQLName("BD7")+".BD7_CODUNM, "
	cSQL += +RetSQLName("BD7")+".BD7_MOTBLO "
	cSQL += "FROM "+RetSQLName("BE2")+", "+RetSQLName("BD7")+" "
	cSQL += "WHERE BE2_FILIAL = '"+xFilial("BE2")+"' AND "
	cSQL += "BE2_OPEMOV = '"+Substr(M->B44_NUMLIB,01,4)+"' AND "
	cSQL += "BE2_ANOAUT = '"+Substr(M->B44_NUMLIB,05,4)+"' AND "
	cSQL += "BE2_MESAUT = '"+Substr(M->B44_NUMLIB,09,2)+"' AND "
	cSQL += "BE2_NUMAUT = '"+Substr(M->B44_NUMLIB,11,8)+"' AND "
	cSQL += RetSQLName("BE2")+".D_E_L_E_T_ = ' ' AND "
	cSQL += "BE2_FILIAL = BD7_FILIAL AND "
	cSQL += "BE2_OPEMOV = BD7_CODOPE AND "
	cSQL += "BE2_CODLDP = BD7_CODLDP AND "
	cSQL += "BE2_CODPEG = BD7_CODPEG AND "
	cSQL += "BE2_NUMERO = BD7_NUMERO AND "
	cSQL += "BE2_CODPAD = BD7_CODPAD AND "
	cSQL += "BE2_CODPRO = BD7_CODPRO AND "
	cSQL += "BD7_BLOPAG = '1' AND "
	cSQL += "BD7_MOTBLO = '09F' AND "  // Codigo da Critica da Glosa.
	cSQL += RetSQLName("BD7")+".D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"BD7NEG",.F.,.T.)

	Do While BD7NEG->(!Eof())
		If !(BD7NEG->BD7_CODUNM $ cTipoCon)
			cTipoCon += BD7NEG->BD7_CODUNM + ", "
		Endif
		BD7NEG->(DbSkip())
	EndDo
	BD7NEG->(DbCloseArea())
EndIf

For nAux := 1 To Len(aAux)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	//³Verifca Informacoes para ignorar composicao Reemb   ³
 	//³Caso localize composicao na string, ignora  RDS     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(M->B44_NUMLIB) .AND. !Empty(cTipoCon)
		If !(aAux[nAux,1] $ cTipoCon)
			Loop
		EndIf
	EndIf

	If Len(aAux[nAux,5]) == 0 //Houve alguma falha na valorizacao deste subitem

		cCodUnd   := aAux[nAux,1]
        If !lAutomato
		    lFoundBD7 := (nPos := aScan(oBrwComp:aCols,{|x| x[nPosSeq]+x[nPosUnm] == cSequen+cCodUnd .and. !x[Len(x)] .and. aScan(aUnid,cSequen+cCodUnd+cKeyAux) == 0 })) > 0
        Else   
            lFoundBD7 := .T.
        EndIF

		If ! lFoundBD7
			aRetUnd := PLSA720UND(cCodUnd)
			For nForUnd := 1 To Len(aRetUnd)
				cCodUnd   := aRetUnd[nForUnd]
              //lFoundBD7 := (nPos := aScan(oBrwComp:aCols,{|x| x[nPosSeq]+x[nPosUnm] == cSequen+cCodUnd+cKeyAux .and. !x[Len(x)] .and. aScan(aUnid,cSequen+cCodUnd+cKeyAux) == 0 })) > 0
				lFoundBD7 := (nPos := aScan(oBrwComp:aCols,{|x| x[nPosSeq]+x[nPosUnm]+IIf(Empty(cKeyAux),"",x[nPosItEv]) == cSequen+cCodUnd+cKeyAux .and. !x[Len(x)] .and. aScan(aUnid,cSequen+cCodUnd+cKeyAux) == 0 })) > 0
				If lFoundBD7
					Exit
				Endif
			Next
		Endif

		If lFoundBD7
			aadd(aUnid,cSequen+cCodUnd+cKeyAux)
			If !lAutomato
				oBrwComp:FieldPut("B47_DESCRI",aAux[nAux,4],nPos)
			EndIf
		Endif
	Endif

	For nInd := 1 To Len(aAux[nAux,5])

		cKeyAux := IF(aAux[nAux,1]==cMvPLSCAUX,aAux[nAux,15],"")
		cCodUnd := aAux[nAux,1]        
        If !lAutomato
        	lFoundBD7 := (nPos := aScan(oBrwComp:aCols,{|x| x[nPosSeq]+x[nPosUnm]+IIf(Empty(cKeyAux),"",x[nPosItEv]) == cSequen+cCodUnd+cKeyAux  .and. !x[Len(x)] .and. aScan(aUnid,cSequen+cCodUnd+cKeyAux) == 0 })) > 0
		Else
			lFoundBD7 := .T.
		EndIf
		If ! lFoundBD7
			aRetUnd := PLSA720UND(cCodUnd)
			For nForUnd := 1 To Len(aRetUnd)
				cCodUnd   := aRetUnd[nForUnd]               
                If !lAutomato
                	lFoundBD7 := (nPos := aScan(oBrwComp:aCols,{|x| x[nPosSeq]+x[nPosUnm]+IIf(Empty(cKeyAux),"",x[nPosItEv]) == cSequen+cCodUnd+cKeyAux .and. !x[Len(x)] .and. aScan(aUnid,cSequen+cCodUnd+cKeyAux) == 0})) > 0
				Else
					lFoundBD7 := .T.
				EndIf
				If lFoundBD7
					Exit
				Endif
			Next
		Endif

		If lFoundBD7
			aadd(aUnid,cSequen+cCodUnd+cKeyAux)
			cCodRDA := M->B44_CODRDA
			cCodLoc := subs(M->B44_LOCATE,1,3)
			cCodEsp := M->B44_CODESP
			cCdPfPr := M->B44_CDPFRE
           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           //³ Define valores default para os parametros...                        ³
           //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aAux[nAux,4])

				nVlrPag := aAux[nAux,5,nInd,4]
				nVlrCon := aAux[nAux,5,nInd,4]
				nVlrGlo := 0
				nVlrMan := aAux[nAux,5,nInd,4]

				If nFator > 0
				
					If nVlrApr > nVlrCon .And. !lAneste
						nVlrPag := nVlrCon * nFator
					Else
						nVlrPag := (nVlrApr * nQtdPro) * nFator
					Endif

					nVlrMan := nVlrPag
				EndIf

              //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
              //³ Verifica se tem percentual de desconto p/ este corpo clinico...     ³
              //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BC1->(DbSetOrder(1))
				IF BC1->(MsSeek(xFilial("BC1")+cCodRDA+cCodLoc+cCodEsp+cCdPfPr)) .And. BC1->BC1_PERDES > 0

					If !Empty(BC1->BC1_DATBLO) .And. BC1->BC1_DATBLO <= dDatPro
						Loop
					Else
						nDesconto := BC1->BC1_PERDES
						nVlrPag   := round( ( nVlrPag * nDesconto ) / 100, 3)
						nVlrMan   := nVlrPag
						nVlrCon   := nVlrPag
					EndIf
				Else
					nDesconto := 0
				Endif
              //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
              //³ Verifica se tem percentual de acrescimo p/ este corpo clinico...    ³
              //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BC1->(DbSetOrder(1))
				IF BC1->(MsSeek(xFilial("BC1")+cCodRDA+cCodLoc+cCodEsp+cCdPfPr)) .And. BC1->BC1_PERACR > 0
					nAcrescimo := BC1->BC1_PERACR
					nVlrPag    := nVlrPag + round( ( ( nVlrPag * nAcrescimo ) / 100), 3)
					nVlrMan    := nVlrPag
					nVlrCon    := nVlrPag
				Else
					nAcrescimo := 0
				Endif
				
				If !lAutomato
					oBrwComp:FieldPut("B47_VLRPAG",nVlrPag,nPos)
					oBrwComp:FieldPut("B47_VLRMAN",nVlrMan,nPos)
					oBrwComp:FieldPut("B47_VLRBPR",nVlrCon,nPos)
					oBrwComp:FieldPut("B47_VLRGLO",nVlrGlo,nPos)

					If     AllTrim(oBrwComp:aCols[nPos][nPosUnm]) $ cMv_PLSCPA
						oBrwComp:FieldPut("B47_COEFUT",aAux[nAux,5,nInd,3],nPos)
					ElseIf AllTrim(oBrwComp:aCols[nPos][nPosUnm]) $ cMvPLSCAUX
						oBrwComp:FieldPut("B47_COEFUT",aAux[nAux,5,nInd,1],nPos)
					Else
						oBrwComp:FieldPut("B47_COEFUT",aAux[nAux,5,nInd,3],nPos)
					EndIf
					oBrwComp:FieldPut("B47_TIPCOE",aAux[nAux,5,nInd,7],nPos)
					oBrwComp:FieldPut("B47_ALIAUS",aAux[nAux,5,nInd,2],nPos)
					oBrwComp:FieldPut("B47_DALIUS",PLSRETNCRI(aAux[nAux,5,nInd,2],"",""),nPos)
					oBrwComp:FieldPut("B47_CODPAD",M->B45_CODPAD,nPos)
					oBrwComp:FieldPut("B47_CODPRO",B1N->B1N_CODPRO,nPos) 
					oBrwComp:FieldPut("B47_PERHES",nPercHEsp,nPos)
					oBrwComp:FieldPut("B47_DSCCLI",nDesconto,nPos)
					oBrwComp:FieldPut("B47_ACCCLI",nAcrescimo,nPos)
					oBrwComp:FieldPut("B47_FATMUL",aAux[nAux,5,nInd,6],nPos)
              //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
              //³ participacao da unidade										      ³
              //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(aAux[nAux]) >= 15
						oBrwComp:FieldPut("B47_CODTPA",aAux[nAux,15],nPos)
					EndIf

					If     AllTrim(oBrwComp:aCols[nPos][nPosUnm]) $ cMvPLSCAUX
						oBrwComp:FieldPut("B47_REFTDE",oBrwComp:aCols[nPos][nPosCoe]/100*(nQtdCH),nPos)
					ElseIf AllTrim(oBrwComp:aCols[nPos][nPosUnm]) $ cMv_PLSCRCC
						oBrwComp:FieldPut("B47_REFTDE",aAux[nAux,9],nPos)
					ElseIf AllTrim(oBrwComp:aCols[nPos][nPosUnm]) $ cMv_PLSCPA
						oBrwComp:FieldPut("B47_REFTDE",aAux[nAux,5,nInd,1],nPos)
					Endif

					If Len(aAux[nAux,5,nInd]) >= 11
						oBrwComp:FieldPut("B47_UTHRES",aAux[nAux,5,nInd,11],nPos)
					Endif
				EndIf

				If !lAutomato
					nVlrTot   += oBrwComp:aCols[nPos][nPosPag]
				EndIf
				
				nTTVlrPag += nVlrPag
				nTTVlrCon += nVlrCon
				nTTVlrMan += nVlrMan
				nTTVlrGlo += nVlrGlo
				
			Endif
		Endif
	Next
Next

//Valor Real Contratado
nVlrRCon    := nTTVlrCon
If !lAutomato
	For nI:=1 to Len(oBrwComp:aCols)
		If oBrwComp:aCols[nI][nPosSeq] == cSequen .and. !oBrwComp:IsDeleted(nI)
			nPercen := round((oBrwComp:aCols[nI][nPosPag])*100/nVlrTot,2)
			oBrwComp:FieldPut("B47_PERCEN",nPercen,nI)
			nSomaPerc += nPercen
			lPagAlgum := .T.
			nUltimo   := nI
		Endif
	Next
Else
	For nI:=1 to 1
		nPercen := 100
		nSomaPerc += nPercen
		lPagAlgum := .T.
		nUltimo   := nI
	Next

EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Minha margem de erro eh no maximo 1 porcento, mais que isso eh erro |
//³ controlado															 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nSomaPerc > 99 .and. nSomaPerc < 100
	If !lAutomato
		oBrwComp:FieldPut("B47_PERCEN",oBrwComp:aCols[nUltimo][nPosPer]+(100-nSomaPerc),nUltimo)
	EndIF
	nSomaperc += (100-nSomaPerc)
Elseif nSomaPerc > 100 .and. nSomaPerc < 101
	If !lAutomato
		oBrwComp:FieldPut("B47_PERCEN",oBrwComp:aCols[nUltimo][nPosPer]-(nSomaPerc-100),nUltimo)
	EndIF
	nSomaperc -= (nSomaPerc-100)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata o valor apresentado no subitem...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->B45_VLRAPR >= 0

	nVlrApr := B1N->B1N_VLRTOT 
	nVlrCon := nTTVlrCon
	nVlrPag := nTTVlrPag
	nVlrMan := nTTVlrMan
	nVlrGlo := 0
	lExit := .F.
	lAprMai := .F.
	
    If ExistBlock("P001VLAP") 
		
		aAreaBOW := BOW->(GetArea())  
		aAreaB1N := B1N->(GetArea()) 
		aAreaB44 := B44->(GetArea()) 
		aAreaB45 := B45->(GetArea()) 
		aAreaB47 := B47->(GetArea()) 
		aAreaSE2 := SE2->(GetArea()) 
		
		aRetVlAp   	:= ExecBlock("P001VLAP",.F.,.F.,{nVlrApr,nVlrCon,nVlrMan,nVlrGlo,oBrwPro:aCols,oBrwPro:aHeader,B1N->B1N_SEQUEN})
		nVlrApr 	:= aRetVlAp[1]
		nVlrCon 	:= aRetVlAp[2]
		nVlrMan 	:= aRetVlAp[3]
		nVlrGlo 	:= aRetVlAp[4]
			
		RestArea(aAreaBOW) 
		RestArea(aAreaB1N) 
		RestArea(aAreaB44) 
		RestArea(aAreaB45) 
		RestArea(aAreaB47) 
		RestArea(aAreaSE2) 
	EndIf
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Se o sistema bloqueou todas as unidades o valor contratado fica 0   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  nVlrCon == 0 .and. nVlrApr <> 0
		nVlrMan := nVlrApr
		nVlrPag := 0
		nVlrGlo := round(nVlrApr,3)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Se o valor apresentado ja eh igual ao que estou pagando			   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf nVlrApr == nVlrCon .and. nVlrApr == nVlrPag
		lExit := .T.

	ElseIf nVlrApr < nVlrCon
		If nFator > 0
			nVlrApr := nVlrAPr * nFator
		Endif

		nVlrMan := nVlrApr
		nVlrPag := nVlrApr
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Se o valor apresentado for maior q/ o contratado gloso a diferenca..³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf (nVlrApr > nVlrCon)
	
		If lAneste
			nVlrGlo := 0
			If nFator > 0
				nVlrCon := nVlrCon * nFator
			Endif
			nVlrMan := nVlrApr
			nVlrPag := nVlrApr
		Else
			nVlrGlo := Round(nVlrApr,3) - Round(nVlrCon,3)
			If nFator > 0
				nVlrCon := nVlrCon * nFator
			Endif
			nVlrMan := nVlrCon
			nVlrPag := nVlrCon
		EndIF
		lAprMai := .T.
	Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Le todos os BD7 de novo atualizando o valor de acordo com o apresen.³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotGlo := 0
	nUltimo := 0
	nTotPag := 0
	nTotMan := 0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   //³ Tratamento do valor apresentado
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !lExit
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	   //³ Considera o valor apresentado como valor para pagamento sem glosa
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If nVlrApr > nVlrCon .And. M->B45_CONSVL == '1' 
			
			If nFator > 0
				nVlrApr := nVlrApr * nFator
			Endif
			
			nVlrMan := nVlrApr
			nVlrPag := nVlrApr
			nVlrGlo := 0
			lAprMai := .T.
		EndIf
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	   //³ Procedimento
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !lAutomato
		For nI:=1 to Len(oBrwComp:aCols)
			If oBrwComp:aCols[nI][nPosSeq] == cSequen .and. !oBrwComp:IsDeleted(nI)

				nSlvMan := oBrwComp:aCols[nI][nPosMan]
				oBrwComp:FieldPut("B47_VLRMAN",noround((nVlrMan*oBrwComp:aCols[nI][nPosPer])/100,2),nI)
				If abs(nSlvMan - oBrwComp:aCols[nI][nPosMan]) > 0 .and. abs(nSlvMan - oBrwComp:aCols[nI][nPosMan]) <= GetNewPar("MV_PLSDIFA",0.02) .and. lAprMai
					oBrwComp:FieldPut("B47_VLRMAN",nSlvMan,nI)
				Endif

				nSlvPag := oBrwComp:aCols[nI][nPosPag]
				oBrwComp:FieldPut("B47_VLRPAG",noround((nVlrPag*oBrwComp:aCols[nI][nPosPer])/100,3),nI)
				If abs(nSlvPag - oBrwComp:aCols[nI][nPosPag]) > 0 .and. abs(nSlvPag - oBrwComp:aCols[nI][nPosPag]) <= GetNewPar("MV_PLSDIFA",0.02) .and. lAprMai
					oBrwComp:FieldPut("B47_VLRPAG",nSlvPag,nI)
				Endif

				nSlvPag := oBrwComp:aCols[nI][nPosBpr]
				oBrwComp:FieldPut("B47_VLRBPR",noround((nVlrCon*oBrwComp:aCols[nI][nPosPer])/100,11),nI)
				oBrwComp:FieldPut("B47_VLRAPR",noround((nVlrApr*oBrwComp:aCols[nI][nPosPer])/100,11),nI)

				nSlvGlo := oBrwComp:aCols[nI][nPosGlo]
				oBrwComp:FieldPut("B47_VLRGLO",noround((nVlrGlo*oBrwComp:aCols[nI][nPosPer])/100,2),nI)

					 // Se o valor apresentado for maior que o contratado e a composição não deriva de grau de participação
				If lAprMai .AND. EMPTY(oBrwComp:aCols[nI][nGrauPar])
					oBrwComp:FieldPut("B47_VLRGLO",oBrwComp:aCols[nI][nPosMan]-oBrwComp:aCols[nI][nPosPag],nI)
				Endif

				nTotGlo   += oBrwComp:aCols[nI][nPosGlo]
				nTotPag   += oBrwComp:aCols[nI][nPosPag]
				nTotMan   += oBrwComp:aCols[nI][nPosMan]

				nTTVlrGlo += oBrwComp:aCols[nI][nPosGlo]
				nUltimo   := nI
			Endif
		Next
	Else
			nSlvMan   := B47->B47_VLRMAN
			nSlvPag   := B47->B47_VLRPAG
			nSlvGlo   := 0
			nTotGlo   += 0
			nTotPag   += B47->B47_VLRPAG
			nTotMan   += B47->B47_VLRPAG
			nTTVlrGlo += 0
			nUltimo   := 1

		EndIF
	Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Tratamento de erros de arredondamento							   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTotGlo/nVlrGlo <> 1  .and. nTotGlo/nVlrGlo <> 1 .and. nUltimo <> 0
		If nTotGlo > nVlrGlo
			If !lAutomato
				oBrwComp:FieldPut("B47_VLRGLO",oBrwComp:aCols[nUltimo][nPosGlo]-(nTotGlo - nVlrGlo),nUltimo)
			EndIF
			nTTVlrGlo		-= (nTotGlo - nVlrGlo)
			nTotGlo		    -= (nTotGlo - nVlrGlo)
		Else
			If !lAutomato
				oBrwComp:FieldPut("B47_VLRGLO",oBrwComp:aCols[nUltimo][nPosGlo]+(nVlrGlo - nTotGlo),nUltimo)
			EndIF
			nTTVlrGlo		+= (nVlrGlo - nTotGlo)
			nTotGlo		    += (nVlrGlo - nTotGlo)
		Endif
	Elseif nTotGlo == 0 .and. nVlrGlo > 0 .and. nUltimo <> 0 .and. lAprMai
		If !lAutomato 
			oBrwComp:FieldPut("B47_VLRGLO",oBrwComp:aCols[nUltimo][nPosGlo]+(nVlrGlo - nTotGlo),nUltimo)
		EndIF
		nTTVlrGlo		+= (nVlrGlo - nTotGlo)
		nTotGlo		    += (nVlrGlo - nTotGlo)
	Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Tratamento de erros de arredondamento											³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTotPag/nVlrPag <> 1 .and. nTotPag/nVlrPag <> 1 .and. nUltimo <> 0
		If nTotPag > nVlrPag
			If !lAutomato
				oBrwComp:FieldPut("B47_VLRPAG",oBrwComp:aCols[nUltimo][nPosPag]-(nTotPag - nVlrPag),nUltimo)
			EndIF

			nTotPag		-= (nTotPag - nVlrPag)
		Else
			If !lAutomato
				oBrwComp:FieldPut("B47_VLRPAG",oBrwComp:aCols[nUltimo][nPosPag]+(nVlrPag - nTotPag),nUltimo)
			EndIf
			nTotPag		+= (nVlrPag - nTotPag)
		Endif
	Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Tratamento de erros de arredondamento							   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTotMan/nVlrMan <> 1 .and. nTotMan/nVlrMan <> 1 .and. nUltimo <> 0
		If nTotMan > nVlrMan
			If !lAutomato
				oBrwComp:FieldPut("B47_VLRMAN",oBrwComp:aCols[nUltimo][nPosMan]-(nTotMan - nVlrMan),nUltimo)
			EndIF
			nTotMan     -= (nTotMan - nVlrMan)
		Else
			If !lAutomato
				oBrwComp:FieldPut("B47_VLRMAN",oBrwComp:aCols[nUltimo][nPosMan]+(nVlrMan - nTotMan),nUltimo)
			EndIF
			nTotMan     += (nVlrMan - nTotMan)
		Endif
	Endif

Endif

If lPagAlgum .And. round(nsomaperc,2) <> 100 .And. Len(aAux) > 0 .and. nSomaperc > 0//teve valor a cobrar mais % nao somou 100%
	PLSPOSGLO(PLSINTPAD(),__aCdCri032[1],__aCdCri032[2],cLocalExec)
	aadd(aCri,{__aCdCri032[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro,cSequen})
	aadd(aCri,{""   ,STR0062                 ,str(nSomaPerc,17,4),"","",cCodPad,cCodPro,cSequen}) //"Soma dos percentuais nos subitens para este evento OU nao foi possivel Valorar o pagamento"
	lFlag := .T.
Endif

If !lAutomato
	For nI := 1 to Len(oBrwComp:aCols)

		nJ := aScan(oBrwPro:aCols,{|x| x[nPosSB45] == oBrwComp:aCols[nI][nPosSeq]})
		If !oBrwComp:IsDeleted(nI)
			If oBrwComp:aCols[nI][nPosSeq] == cSequen
				nVlrPagPro += oBrwComp:aCols[nI][nPosPag]
				nVlrManPro += oBrwComp:aCols[nI][nPosMan]
				nVlrGloPro += oBrwComp:aCols[nI][nPosGlo]
				nVlrBprPro += oBrwComp:aCols[nI][nPosBpr]
			Endif
			If (oBrwComp:aCols[nI][nPosSeq] == cSequen .and. M->B45_STATUS == '1') .or. ;
					(nJ > 0 .and. oBrwPro:aCols[nJ][nPosTB45] == '1' .and. M->B45_SEQUEN <> oBrwPro:aCols[nJ][nPosSB45])
				nVlrPagGui += oBrwComp:aCols[nI][nPosPag]
				nVlrManGui += oBrwComp:aCols[nI][nPosMan]
				nVlrGloGui += oBrwComp:aCols[nI][nPosGlo]
				nVlrBprGui += oBrwComp:aCols[nI][nPosBpr]
			Endif
		Endif
	Next
Else	
	nVlrPagPro += B47->B47_VLRPAG
	nVlrManPro += B47->B47_VLRMAN
	nVlrGloPro += B47->B47_VLRGLO
	nVlrBprPro += B47->B47_VLRBPR
	
	If M->B45_STATUS == '1'
		nVlrPagGui := B47->B47_VLRPAG
    	nVlrManGui := B47->B47_VLRMAN
    	nVlrGloGui := B47->B47_VLRGLO
    	nVlrBprGui := B47->B47_VLRBPR
	EndIF


EndIF

nVlrManG:=nVlrManGui
If !lAutomato
	oBrwComp:Atualiza()
Endif

If lFlag
	lRet := .F. //Houve pelo menos 1 critica...
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para o tratamento do valor da quia e dos procedimentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLS001VLRS")
	
	aAreaBOW := BOW->(GetArea())  
	aAreaB1N := B1N->(GetArea()) 
	aAreaB44 := B44->(GetArea()) 
	aAreaB45 := B45->(GetArea()) 
	aAreaB47 := B47->(GetArea()) 
	aAreaSE2 := SE2->(GetArea()) 

	aRet := Execblock("PLS001VLRS",.F.,.F.,{lRet,{nVlrPagPro,nVlrManPro,nVlrGloPro,nVlrBprPro},{nVlrPagGui,nVlrManGui,nVlrGloGui,nVlrBprGui},cCodPro,cCodPad,cMatrUsr,cCodRDA,cCodEsp,aCri})
	If ValType(aRet[1])="L"
		lRet		:=aRet[1]
	Endif

	RestArea(aAreaBOW) 
	RestArea(aAreaB1N) 
	RestArea(aAreaB44) 
	RestArea(aAreaB45) 
	RestArea(aAreaB47) 
	RestArea(aAreaSE2) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Total do procedimento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(aRet[2])="A"
		nVlrPagPro	:=aRet[2,1]
		nVlrManPro	:=aRet[2,2]
		nVlrGloPro	:=aRet[2,3]
		nVlrBprPro  :=aRet[2,4]
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Total da Guia		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(aRet[3])="A"
		nVlrPagGui	:=aRet[3,1]
		nVlrManGui	:=aRet[3,2]
		nVlrGloGui	:=aRet[3,3]
		nVlrBprGui	:=aRet[3,4]
	Endif

Endif

Return({lRet,;
	{nVlrPagPro,nVlrManPro,nVlrGloPro,nVlrBprPro,nVlrRCon},;//total do procedimento
	{nVlrPagGui,nVlrManGui,nVlrGloGui,nVlrBprGui,0}})//total da guia

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³P001Vld   ³ Autor ³ Daher		            ³ Data ³ 13.02.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da tela de procedimentos					      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function P001Vld(lAutomato)

LOCAL lRet 		 := .T.
LOCAL nPosPag    := 0
LOCAL nPosGlo	 := 0
LOCAL nPosMan	 := 0
LOCAL nPosBpr	 := 0
LOCAL nPosBPF	 := 0
LOCAL nPosSB45   := 0
Local nPosStat 	 := 0
Local nPosVapr 	 := 0
Local nFor       := 0
Local nVlrPagPro := 0
Local nVlrManPro := 0
Local nVlrGloPro := 0
Local nVlrBprPro := 0
Local nVlrBpFPro := 0
LOCAL lConsideraRegraDeValor := .T.
Local lValoracao:=(GetNewPar("MV_PLVLRE", .T.))
Default lAutomato := .F.

If !lAutomato
    nPosPag  := PLRETPOS("B45_VLRPAG",oBrwPro:aHeader)
    nPosGlo	 := PLRETPOS("B45_VLRGLO",oBrwPro:aHeader)
    nPosMan	 := PLRETPOS("B45_VLRMAN",oBrwPro:aHeader)
    nPosBpr	 := PLRETPOS("B45_VLRBPR",oBrwPro:aHeader)
    nPosBPF	 := PLRETPOS("B45_VLABPF",oBrwPro:aHeader)
    nPosSB45 := PLRETPOS("B45_SEQUEN",oBrwPro:aHeader)
    nPosStat := PLRETPOS("B45_IMGSTA",oBrwPro:aHeader)
    nPosVapr := PLRETPOS("B45_VLRAPR",oBrwPro:aHeader)
Else
    nPosPag  := 0
    nPosGlo	 := 0
    nPosMan	 := 0
    nPosBpr	 := 0
    nPosBPF	 := 0
    nPosSB45 := 0
    nPosStat := 0
    nPosVapr := 0

EndIF

//Obriga a preencher o campo dente/Região e face se o procedimento for odontológico.
	If Posicione("BR8",1,xFilial("BR8") + M->B45_CODPAD + M->B45_CODPRO, "BR8_ODONTO") == "1"

		If EMPTY(M->B45_DENREG) .OR. (EMPTY(M->B45_FADENT) .And. BR8->BR8_CONFAC <> "0")
            If !lAutomato
			    Help("",1,"PL001015")
            EndIF
			lRet := .F.
		EndIf
	EndIf

If M->B45_VALORI <> '1' .AND. lRet .and.  lValoracao
	If !lAutomato
        Help("",1,"PL001008")
    EndIF
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se ja estiver valorizado, verifica regra especifica de validacao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If ExistBlock("PLSVL002")
		
		aAreaBOW := BOW->(GetArea())  
		aAreaB1N := B1N->(GetArea()) 
		aAreaB44 := B44->(GetArea()) 
		aAreaB45 := B45->(GetArea()) 
		aAreaB47 := B47->(GetArea()) 
		aAreaSE2 := SE2->(GetArea()) 
		
		lConsideraRegraDeValor := Execblock("PLSVL002",.F.,.F.,{lRet})

		RestArea(aAreaBOW) 
		RestArea(aAreaB1N) 
		RestArea(aAreaB44) 
		RestArea(aAreaB45) 
		RestArea(aAreaB47) 
		RestArea(aAreaSE2) 
	Endif
EndIf

IF lRet .And. lConsideraRegraDeValor .and. M->B45_VLRPAG <= 0 .AND. M->B45_STATUS == "1" .and.  lValoracao
	If !lAutomato
        Help( ,, 'HELP',,"O valor de Pagamento deve ser maior que zero!", 1, 0)
    EndIF
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se ja estiver valorizado, verifica regra especifica de validacao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If ExistBlock("PLSVL001")

		aAreaBOW := BOW->(GetArea())  
		aAreaB1N := B1N->(GetArea()) 
		aAreaB44 := B44->(GetArea()) 
		aAreaB45 := B45->(GetArea()) 
		aAreaB47 := B47->(GetArea()) 
		aAreaSE2 := SE2->(GetArea()) 
		
		lRet := Execblock("PLSVL001",.F.,.F.,{lRet})

		RestArea(aAreaBOW) 
		RestArea(aAreaB1N) 
		RestArea(aAreaB44) 
		RestArea(aAreaB45) 
		RestArea(aAreaB47) 
		RestArea(aAreaSE2) 
	Endif
EndIf

cSequen := M->B45_SEQUEN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza Dados Cabeçalho.										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .and. !lAutomato
	For nFor := 1 To Len(oBrwPro:aCols)
		If !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]
			If oBrwPro:aCols[nFor,nPosSB45] == cSequen
				nVlrPagPro += M->B45_VLRPAG
				nVlrManPro += M->B45_VLRMAN
				nVlrGloPro += IIF( M->B45_STATUS == "1", M->B45_VLRGLO, M->B45_VLRAPR)
				nVlrBprPro += M->B45_VLRBPR
				nVlrBpFPro += M->B45_VLABPF
	  		Else
				nVlrPagPro += oBrwPro:aCols[nFor][nPosPag]
				nVlrManPro += oBrwPro:aCols[nFor][nPosMan]
				If oBrwPro:aCols[nFor][nPosStat] == "DISABLE"
					oBrwPro:aCols[nFor][nPosGlo] := oBrwPro:aCols[nFor][nPosVapr]
				EndIf
				nVlrGloPro += oBrwPro:aCols[nFor][nPosGlo]
				nVlrBprPro += oBrwPro:aCols[nFor][nPosBpr]
				nVlrBpFPro += oBrwPro:aCols[nFor][nPosBPF]
			Endif
		Endif
	Next nFor

	M->B44_VLRPAG := nVlrPagPro

	M->B44_VLRMAN := nVlrManPro
	M->B44_VLRGLO := nVlrGloPro
	M->B44_VLRBPR := nVlrBprPro
	M->B44_VLABPF := nVlrBpFPro
Else
    nVlrPagPro += M->B45_VLRPAG
	nVlrManPro += M->B45_VLRMAN
	nVlrGloPro += IIF( M->B45_IMGSTA <> "DISABLE", M->B45_VLRGLO, M->B45_VLRAPR)
	nVlrBprPro += M->B45_VLRBPR
	nVlrBpFPro += M->B45_VLABPF
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Atualiza browse
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !lAutomato
    oBrwPro:Atualiza()
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³P001Cli   ³ Autor ³ Daher		            ³ Data ³ 13.02.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega o cliente										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±     `
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function P001Cli()

LOCAL aCliente := PLSAVERNIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,IF(BA3->BA3_TIPOUS=="1","F","J"),;
	BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,nil,BA1->BA1_TIPREG,.F.)

If aCliente[1,1] <> "ZZZZZZ"
	M->B44_CODCLI := aCliente[1][1]
	M->B44_LOJA   := aCliente[1][2]
	M->B44_NOMCLI := aCliente[1][3]
	M->B44_USUARI := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSGRVREM  ³ Autor ³ Daher				³ Data ³ 18.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria o titulo do reembolso								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSGRVREM(cPrefixo,cNumero,cCliFor,cLoja,cTipTit,dVencto,cCodInt,cCodEmp,cMatric,nOpc,;
		nValor,cConEmp,cVerCon,cSubCon,cVerSub,cTipReg,cNat,aBanco,cAno,cMes,cDescri,;
		cOrigem,cCodEve,cRecPag,cReemb,cNumDC)

LOCAL __cCodigo    := ""
LOCAL __cNumBDC    := ""
LOCAL cSeq	         := ""
LOCAL aCliente     := {}
LOCAL cChave
LOCAL cNumCob
Local aVetCri   	:= {}
LOCAL aRecBDF  	:= {}
LOCAL lRet			:= .T.

DEFAULT cAno    	:=subs(dtos(dDataBase),1,4)
DEFAULT cMes   	:=subs(dtos(dDataBase),5,2)
DEFAULT nValor	:= 0
DEFAULT aBanco   	:= {} // {Cod,Agencia,Numero Conta}
DEFAULT cDescri	:= STR0063 	//"REEMBOLSO GERADO NO ATO"
DEFAULT cOrigem  	:= 'PLSA001'
DEFAULT cCodEve 	:= "108"		//reembolso livre escolha
DEFAULT cRecPag	:= "1"
DEFAULT cReemb	:= "1"
DEFAULT cNumDC	:= ""

If nOpc == K_Incluir
	SA1->(DbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1")+cCliFor+cLoja))
	BA1->(DbSetOrder(2))
	BA1->(MsSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg))
	BA3->(DbSetOrder(1))
	BA3->(MsSeek(xFilial("BA3")+cCodInt+cCodEmp+cMatric))
	BFQ->(DbSetOrder(1))
	BFQ->(MsSeek(xFilial("BFQ")+cCodInt+cCodEve))

	cVerCon := BA1->BA1_VERCON
	aCliente := PLS770NIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,;
		BA3->BA3_MATRIC,If(BA3->BA3_TIPOUS=="1","F","J"),;
		BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,;
		BA3->BA3_VERSUB,1)

	If cRecPag == "1" // Receber
		DbSelectArea("BDC")
		__cNumBDC:=PLSA625Num()
		BDC->(RecLock("BDC",.T.))
		BDC->BDC_FILIAL := xFilial("BDC")
		BDC->BDC_CODOPE := cCodInt
		BDC->BDC_NUMERO := __cNumBDC
		BDC->BDC_DATGER := dDataBase
		BDC->BDC_USUOPE := PLRETOPE()
		BDC->BDC_HORA   := TIME()
		BDC->BDC_HORAF  := TIME()
		BDC->BDC_ANOINI := cAno
		BDC->BDC_MESINI := cMes
		BDC->BDC_ANOFIM := cAno
		BDC->BDC_MESFIM := cMes
		BDC->BDC_DTEMIS := dDataBase
		BDC->BDC_VALOR  := nValor
		BDC->BDC_MODPAG := BA3->BA3_MODPAG
		BDC->BDC_REEMB  := cReemb
		BDC->BDC_INTERC := "0"

		BDC->( ConfirmSx8() )
		BDC->(MsUnlock())

	Endif

	// Grava o arquivo BBT, complemento do SE1 com informacoes do Plano de Saude.
	DbSelectArea("BBT")
	__cCodigo := GetSx8Num("BBT","BBT_CODIGO")
	BBT->( ConfirmSx8() )

	BBT->(RecLock("BBT",.T.))
	BBT->BBT_FILIAL := xFilial("BBT")
	BBT->BBT_CODIGO := __cCodigo
	BBT->BBT_CODOPE := cCodInt
	BBT->BBT_CODEMP := cCodEmp
	BBT->BBT_CONEMP := cConEmp
	BBT->BBT_VERCON := cVerCon
	BBT->BBT_SUBCON := cSubCon
	BBT->BBT_VERSUB := cVerSub
	BBT->BBT_MATRIC := cMatric
	BBT->BBT_TIPREG := cTipReg
	If Len(aCliente) > 0
		BBT->BBT_NIVEL  := aCliente[1][18]
	Endif
	BBT->BBT_CLIFOR := cCliFor
	BBT->BBT_LOJA   := cLoja
	BBT->BBT_VALOR  := nValor

	BBT->BBT_ANOTIT := cAno
	BBT->BBT_MESTIT := cMes

	BBT->BBT_PREFIX := cPrefixo
	BBT->BBT_NUMTIT := cNumero
	BBT->BBT_TIPTIT := cTipTit
	BBT->BBT_RECPAG := cRecPag

	If !Empty(BA1->BA1_CODPLA)
		BBT->BBT_CODPLA := BA1->BA1_CODPLA
		BBT->BBT_VERSAO := BA1->BA1_VERSAO
	Else
		BBT->BBT_CODPLA := BA3->BA3_CODPLA
		BBT->BBT_VERSAO := BA3->BA3_VERSAO
	Endif
	BBT->BBT_INTERC := '0'
	BBT->BBT_MODPAG := BA3->BA3_MODPAG
	If cRecPag == "1" // Receber
		BBT->BBT_NUMCOB := cCodInt+__cNumBDC
	Else
		BBT->BBT_NUMCOB := cPrefixo+cNumero
	Endif

	BBT->(MsUnlock())

	If cRecPag == "1" // Receber
		// Grava o titulo a receber...
		SE1->(RecLock("SE1",.T.))
		SE1->E1_FILIAL   := xFilial("SE1")
		SE1->E1_TIPO     := cTipTit
		SE1->E1_CLIENTE  := cCliFor
		SE1->E1_LOJA     := cLoja
		If !Empty(SA1->A1_NATUREZ)
			SE1->E1_NATUREZ  := SA1->A1_NATUREZ
		Else
			SE1->E1_NATUREZ  := cNat
		Endif
		SE1->E1_EMISSAO  := dDataBase
		SE1->E1_EMIS1    := dDataBase
		SE1->E1_SITUACA  := "0"
		SE1->E1_MOEDA    := 1
		SE1->E1_OCORREN  := "01"
		SE1->E1_FLUXO    := "S"
		SE1->E1_STATUS   := "A"
		SE1->E1_PROJPMS  := "2"
		SE1->E1_VENCORI  := dVencto
		SE1->E1_VENCTO   := IIF(dVencto<dDataBase, dDataBase, dVencto)
		SE1->E1_PREFIXO  := cPrefixo
		SE1->E1_NUM      := cNumero
		SE1->E1_VENCREA  := DataValida(SE1->E1_VENCTO)
		SE1->E1_VLCRUZ   := nValor
		SE1->E1_IRRF	    := 0
		SE1->E1_VALOR    := nValor
		SE1->E1_NOMCLI   := SA1->A1_NOME
		SE1->E1_SALDO    := SE1->E1_VALOR
		SE1->E1_DECRESC  := 0
		SE1->E1_SDDECRE  := 0
		SE1->E1_ACRESC   := 0
		SE1->E1_SDACRES  := 0
		SE1->E1_VALLIQ   := 0
		If Len(aBanco) > 0
			SE1->E1_BCOCLI   := aBanco[1]
			SE1->E1_AGECLI   := aBanco[2]
			SE1->E1_CTACLI   := aBanco[3]
		Endif
		SE1->E1_NUMBCO   := ""
		SE1->E1_PLNUCOB  := ""
		SE1->E1_VALJUR   := 0
		SE1->E1_PORCJUR  := 0
		SE1->E1_CODINT   := cCodInt
		SE1->E1_CODEMP   	:= cCodEmp
		SE1->E1_MATRIC 	:= cMatric
		SE1->E1_CONEMP   := cConEmp
		SE1->E1_VERCON   := cVerCon
		SE1->E1_SUBCON   := cSubCon
		SE1->E1_VERSUB   := cVerSub
		SE1->E1_MESBASE  := cMes
		SE1->E1_ANOBASE  := cAno
		SE1->E1_MULTNAT  := "2"
		SE1->E1_NUMCON   := BA3->BA3_NUMCON
		SE1->E1_TIPREG   := BA1->BA1_TIPREG
		SE1->E1_ORIGEM   := cOrigem
		SE1->(MsUnLock())

		If ExistBlock("PLSGE001")
			
			aAreaBOW := BOW->(GetArea())  
			aAreaB1N := B1N->(GetArea()) 
			aAreaB44 := B44->(GetArea()) 
			aAreaB45 := B45->(GetArea()) 
			aAreaB47 := B47->(GetArea()) 
			aAreaSE2 := SE2->(GetArea()) 
			
			Execblock("PLSGE001",.F.,.F.,{})

			RestArea(aAreaBOW) 
			RestArea(aAreaB1N) 
			RestArea(aAreaB44) 
			RestArea(aAreaB45) 
			RestArea(aAreaB47) 
			RestArea(aAreaSE2) 
		Endif
	Else
		aCampos :={{"E2_FILIAL"    	,xFilial("SE2")     	,NIL},;
			{"E2_PREFIXO"			,cPrefixo           	,Nil},;
			{"E2_NUM"				,cNumero            	,Nil},;
			{"E2_PARCELA"			,Space(Len(SE2->E2_PARCELA))           ,Nil},;
			{"E2_TIPO"				,cTipTit            	,Nil},;
			{"E2_FORNECE"			,cCliFor           	,Nil},;
			{"E2_LOJA"				,cLoja              	,Nil},;
			{"E2_NOMFOR"    		,posicione("SA2",1,xFilial("SA2")+cCliFor+cLoja,"A2_NREDUZ"),Nil},;
			{"E2_EMISSAO"			,dDataBase          	,NIL},;
			{"E2_EMIS1"     		,dDataBase          	,NIL},;
			{"E2_VENCTO"			,dVencto            	,NIL},;
			{"E2_VENCREA"   		,DataValida(IIF(dVencto<dDataBase, dDataBase, dVencto))	,NIL},;
			{"E2_VENCORI"   		,dVencto            	,NIL},;
			{"E2_MOEDA"     		,01                	 ,NIL},;
			{"E2_VALOR"			,nValor				,Nil},;
			{"E2_VLCRUZ"			,nValor            	,Nil},;
			{"E2_SALDO"			,nValor            	,Nil},;
			{"E2_DECRESC"   		,0		            	,NIL},;
			{"E2_ACRESC"    		,0		            	,NIL},;
			{"E2_PLLOTE"    		,cMes+cNumDC    		,NIL},;
			{"E2_PLOPELT"   		,cAno	            	,NIL},;
			{"E2_CODRDA"    		,""                 	,NIL},;
			{"E2_ANOBASE"   		,cAno	            	,NIL},;
			{"E2_MESBASE"   		,cMes	            	,NIL},;
			{"E2_NATUREZ" 		,cNat					,NIL},;
			{"E2_DESDOBR" 		,"N"					,NIL},;
			{"E2_DIRF" 			,"2"					,NIL},;
			{"E2_HIST" 			,cDescri				,NIL},;
			{"E2_ORIGEM"			,"PLSA756"				,NIL}}
		lMsErroAuto := .F.
		MsExecAuto({ | a,b | Fina050(a,b) }, aCampos, 3)

		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			lRet := .F.
		Endif

	Endif

	If lRet
		
		cSeq := PLSA625Cd("BM1_SEQ","BM1",1,"BM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_ANO+BM1_MES+BM1_TIPREG)",;
			cCodInt+cCodEmp+cMatric+cAno+cMes+cTipReg)

		BM1->(RecLock("BM1",.T.))
		BM1->BM1_FILIAL := xFilial("BM1")

		If BM1->(FieldPos("BM1_RECPAG")) > 0
			BM1->BM1_RECPAG := cRecPag
		endif

		BM1->BM1_CODINT := cCodInt
		BM1->BM1_CODEMP := cCodEmp
		BM1->BM1_MATRIC := BA3->BA3_MATRIC
		BM1->BM1_TIPREG := cTipReg
		BM1->BM1_DIGITO := BA1->BA1_DIGITO
		BM1->BM1_NOMUSR := PLNOMUSR(BM1->BM1_CODINT+BM1->BM1_CODEMP+BM1->BM1_MATRIC+BM1->BM1_TIPREG)
		BM1->BM1_SEQ    := cSeq
		BM1->BM1_CONEMP := BA1->BA1_CONEMP
		BM1->BM1_VERCON := BA1->BA1_VERCON
		BM1->BM1_SUBCON := BA1->BA1_SUBCON
		BM1->BM1_VERSUB := BA1->BA1_VERSUB
		BM1->BM1_ANO    := IIF(Type("M->B44_ANOPAG")<>"U",M->B44_ANOPAG,cAno)
		BM1->BM1_MES    := IIF(Type("M->B44_MESPAG")<>"U",M->B44_MESPAG,cMes)
		BM1->BM1_TIPO   := BFQ->BFQ_DEBCRE
		BM1->BM1_VALOR  := nValor
		BM1->BM1_CODTIP := BFQ->(BFQ_PROPRI+BFQ_CODLAN)
		BM1->BM1_DESTIP := BFQ->BFQ_DESCRI
		BM1->BM1_CODEVE := ""
		BM1->BM1_DESEVE := ""
		BM1->BM1_ALIAS  := ""
		BM1->BM1_ORIGEM := ""
		BM1->BM1_BASEIR := 0
		BM1->BM1_MATUSU := BM1->BM1_CODINT+BM1->BM1_CODEMP+BM1->BM1_MATRIC+BM1->BM1_TIPREG
		BM1->BM1_PLNUCO := ""
		BM1->BM1_LTOTAL := "1"
		BM1->BM1_SEXO   := BA1->BA1_SEXO
		BM1->BM1_GRAUPA := BA1->BA1_GRAUPA
		BM1->BM1_CODFAI := ""
		BM1->BM1_NIVFAI := ""
		BM1->BM1_TIPUSU := BA3->BA3_TIPOUS
		BM1->BM1_CARGO  := cDescri
		BM1->BM1_PREFIX := cPrefixo
		BM1->BM1_NUMTIT := cNumero
		BM1->BM1_TIPTIT := cTipTit
		If Len(aCliente) > 0
			BM1->BM1_NIVCOB := aCliente[1][18]
		Endif
		BM1->BM1_INTERC := "0"
		BM1->BM1_NUMPAR := "001"
		BM1->(MsUnLock())

		cNumCob  :=BDC->BDC_NUMERO
		PLSA625Cri(cNumCob,nValor,aVetCri,cCodInt,cCodEmp,cConEmp,cVerCon,cSubCon,;
			cVerSub,cMatric,cTipReg,aCliente[1][18],cAno,cMes,.F.,NIL,aRecBDF,;
			cChave, NIL)

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
	Endif
Endif

Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ P001Del	  ³ Autor ³ Daher				³ Data ³ 18.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a delecao das linhas								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function P001Del()

LOCAL nI         := 1
LOCAL nVlrPagPro := 0
LOCAL nVlrManPro := 0
LOCAL nVlrGloPro := 0
LOCAL nVlrBprPro := 0
LOCAL nVlrVabpf  := 0
LOCAL cAliCab	 := "B44"
LOCAL cAliPro	 := "B45"
LOCAL nPosPag    := PLRETPOS(cAliPro+"_VLRPAG",oBrwPro:aHeader)
LOCAL nPosGlo	 := PLRETPOS(cAliPro+"_VLRGLO",oBrwPro:aHeader)
LOCAL nPosMan	 := PLRETPOS(cAliPro+"_VLRMAN",oBrwPro:aHeader)
LOCAL nPosBpr	 := PLRETPOS(cAliPro+"_VLRBPR",oBrwPro:aHeader)
LOCAL nPosSeq	 := PLRETPOS(cAliPro+"_SEQUEN",oBrwPro:aHeader)
LOCAL nPosVabpf	 := PLRETPOS(cAliPro+"_VLABPF",oBrwPro:aHeader)
LOCAL nRecBrw	 := oBrwPro:oBrowse:nAt
LOCAL cSequen	 := oBrwPro:FieldGet(cAliPro+"_SEQUEN",nRecBrw)

/*Vou deixar atualizar o cabecalho todas as vezes. Acontece de qdo lanca duas guias iguais na sequencia a partir da segunda nao atualiza
If !lFirst
	lFirst := .T.
    Return .t.
Endif*/

For nI:=1 to Len(obrwpro:aCols)
	If alltrim(oBrwPro:aCols[nI][nPosSeq]) == alltrim(cSequen)
		nVlrPagPro += obrwpro:aCols[nI][nPosPag]
		nVlrManPro += obrwpro:aCols[nI][nPosMan]
		nVlrGloPro += obrwpro:aCols[nI][nPosGlo]
		nVlrBprPro += obrwpro:aCols[nI][nPosBpr]
		nVlrVabpf  += obrwpro:aCols[nI][nPosVabpf]
	Endif
Next

If !oBrwPro:IsDeleted(nRecBrw)
	&("M->"+cAliCab+"_VLRPAG") -= nVlrPagPro
	&("M->"+cAliCab+"_VLRMAN") -= nVlrManPro
	&("M->"+cAliCab+"_VLRGLO") -= nVlrGloPro
	&("M->"+cAliCab+"_VLRBPR") -= nVlrBprPro
	&("M->"+cAliCab+"_VLABPF") -= nVlrVabpf

	__nValRmb   -= nVlrPagPro
	__nValGlosa -= nVlrGloPro
	__nValabpf  -= nVlrVabpf
Else
	&("M->"+cAliCab+"_VLRPAG") += nVlrPagPro
	&("M->"+cAliCab+"_VLRMAN") += nVlrManPro
	&("M->"+cAliCab+"_VLRGLO") += nVlrGloPro
	&("M->"+cAliCab+"_VLRBPR") += nVlrBprPro
	&("M->"+cAliCab+"_VLABPF") += nVlrVabpf

	__nValRmb   += nVlrPagPro
	__nValGlosa += nVlrGloPro
	__nValabpf  += nVlrVabpf
Endif

oSayC:Refresh()
oSayD:Refresh()
oSayE:Refresh()
oSayF:Refresh()
oSayG:Refresh()
oSayH:Refresh()

oBrwPro:setpos(nRecBrw)
lFirst := .F.

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PL001CarCr ³ Autor ³ Daher		        | Data ³ 08.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega as criticas    									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PL001CarCr()
					//------------------------------///------------------------------//
CheckHLP("PPL001001",,,) //"Não será possível acessar a rotina de reembolso."
CheckHLP("SPL001001",,,) //"Não foi possível localizar a rede de atendimento genérica cadastrada."

CheckHLP("PPL001003",,,) //"Não será possível a confirmação da autorização de reembolso."
CheckHLP("SPL001003",,,) //"Não foi informado nenhum código de procedimento para ser reembolsado."

CheckHLP("PPL001004",,,) //"Não será possível a confirmação da autorização de reembolso."
CheckHLP("SPL001004",,,) //"Ano ou Mês de pagamento não informados."

CheckHLP("PPL001005",,,) //"Não será possível a confirmação da autorização de reembolso."
CheckHLP("SPL001005",,,) //"O prestador solicitante deve ser informado."

CheckHLP("PPL001006",,,) //"Não será possível a digitação de procedimentos."
CheckHLP("SPL001006",,,) //"Não foi informado nenhum usuário a ser reembolsado."

CheckHLP("PPL001007",,,) //"Não será possível a digitação de procedimentos."
CheckHLP("SPL001007",,,) //"Não foi informada nenhuma rede de atendimento para a guia."

CheckHLP("PPL001008",,,) //"Não será possível a confirmação do procedimento."
CheckHLP("SPL001008",,,) //"A (re)valorização do procedimento se faz necessária."

CheckHLP("PPL001009",,,) //"Não será possível efetuar a valorização."
CheckHLP("SPL001009",,,) //"Nenhum código de procedimento foi informado."

CheckHLP("PPL001010",,,) //"Não será possivel efetuar a exclusão do reembolso."
CheckHLP("SPL001010",,,) //"A respectiva nota de crédito já sofreu baixa. Deve cancelar a baixa para se conseguir excluir a guia."

CheckHLP("PPL001011",,,) //"Não será possível a digitação do procedimento."
CheckHLP("SPL001011",,,) //"Para este procedimento existe parametrização para não permitir a autorizaçao de reembolso."

CheckHLP("PPL001012",,,) //"Falha no acesso a rotina."
CheckHLP("SPL001012",,,) //"Não foi possível localizar o layout de reembolso no cadastro de layout de guias."

CheckHLP("PPL001013",,,) //"Não será possível a exclusão."
CheckHLP("SPL001013",,,) //"A guia encontra-se faturada. Para exclusão deve-se excluir o lote de cobrança."

CheckHLP("PPL001014",,,) //"Estado e município não foram selecionados."
CheckHLP("SPL001014",,,) //"Clique no folder valorização e preencha os campos Estado e Cd Municipio."

CheckHLP("PPL001015",,,) //"Não será possível efetuar a inclusão do procedimento."
CheckHLP("SPL001015",,,) //"Para procedimentos odontológicos é necessário preencher os campos Dente/Região e face."

CheckHLP("PPL001016",,,) //"Não será possível a confirmação do procedimento."
CheckHLP("SPL001016",,,) //"Preencha o campo Matric. Ben. (B45_MATRIC) no folder Outros. "

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA001Fld ³ Autor ³ Daher		        | Data ³ 08.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Campos da tabela B45 equivalentes ao BD6					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLSA001Fld()

LOCAL cCampos := ""

aEval(aCabB45,{ |aVet| cCampos+= aVet[2]+"," })

Return cCampos

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSAB44LIB ³ Autor ³ Totvs                | Data ³ 29.11.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³VALIDA NUM DA LIBERACAO E PROCEDIMENTOS 		 		      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLSAB44LIB(cNumLib,cCodPad,cCodPro)
LOCAL lRet     		:= .T.
LOCAL aArea 		:= GetArea()
LOCAL cSQL    	 	:= ""
Default cCodPad     := ""
Default cCodPro     := ""
Default cNumLib  	:= ""

If !Empty(cNumLib)
	If !Empty(cCodPro)// Verifica Procedimento
		cSQL := "SELECT "+RetSQLName("BE2")+".R_E_C_N_O_ REC "
		cSQL += "FROM "+RetSQLName("BE2")+", "+RetSQLName("BD7")+" "
		cSQL += "WHERE BE2_FILIAL = '"+xFilial("BE2")+"' AND "
		cSQL += "BE2_OPEMOV = '"+Substr(cNumLib,01,4)+"' AND "
		cSQL += "BE2_ANOAUT = '"+Substr(cNumLib,05,4)+"' AND "
		cSQL += "BE2_MESAUT = '"+Substr(cNumLib,09,2)+"' AND "
		cSQL += "BE2_NUMAUT = '"+Substr(cNumLib,11,8)+"' AND "
		cSQL += "BE2_CODPAD = '"+cCodPad+"' AND "
		cSQL += "BE2_CODPRO = '"+cCodPro+"' AND "
		cSQL += RetSQLName("BE2")+".D_E_L_E_T_ = ' ' AND "
		cSQL += "BE2_FILIAL = BD7_FILIAL AND "
		cSQL += "BE2_OPEMOV = BD7_CODOPE AND "
		cSQL += "BE2_CODLDP = BD7_CODLDP AND "
		cSQL += "BE2_CODPEG = BD7_CODPEG AND "
		cSQL += "BE2_NUMERO = BD7_NUMERO AND "
		cSQL += "BE2_CODPAD = BD7_CODPAD AND "
		cSQL += "BE2_CODPRO = BD7_CODPRO AND "
		cSQL += "BD7_BLOPAG = '1' AND "
		cSQL += "BD7_MOTBLO = '09F' AND "  // Codigo da Critica da Glosa.

		cSQL += RetSQLName("BD7")+".D_E_L_E_T_ = ' ' "

		cSQL := ChangeQuery(cSQL)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"QRYNEG",.F.,.T.)

		If QRYNEG->(Eof())
		   MsgAlert("O procedimento nao tem Grau de participação negado na Liberação para ser Reembolsado!")
		   lRet := .F.
		Endif

		QRYNEG->(DbCloseArea())

	Else // Verifica Liberação

		cSQL := "SELECT "+RetSQLName("BE2")+".R_E_C_N_O_ REC "
		cSQL += "FROM "+RetSQLName("BE2")+", "+RetSQLName("BD7")+" "
		cSQL += "WHERE BE2_FILIAL = '"+xFilial("BE2")+"' AND "
		cSQL += "BE2_OPEMOV = '"+Substr(cNumLib,01,4)+"' AND "
		cSQL += "BE2_ANOAUT = '"+Substr(cNumLib,05,4)+"' AND "
		cSQL += "BE2_MESAUT = '"+Substr(cNumLib,09,2)+"' AND "
		cSQL += "BE2_NUMAUT = '"+Substr(cNumLib,11,8)+"' AND "
		cSQL += RetSQLName("BE2")+".D_E_L_E_T_ = ' ' AND "
		cSQL += "BE2_FILIAL = BD7_FILIAL AND "
		cSQL += "BE2_OPEMOV = BD7_CODOPE AND "
		cSQL += "BE2_CODLDP = BD7_CODLDP AND "
		cSQL += "BE2_CODPEG = BD7_CODPEG AND "
		cSQL += "BE2_NUMERO = BD7_NUMERO AND "
		cSQL += "BE2_CODPAD = BD7_CODPAD AND "
		cSQL += "BE2_CODPRO = BD7_CODPRO AND "
		cSQL += "BD7_BLOPAG = '1' AND "
		cSQL += "BD7_MOTBLO = '09F' AND "  // Codigo da Critica da Glosa.
		cSQL += RetSQLName("BD7")+".D_E_L_E_T_ = ' ' "

		cSQL := ChangeQuery(cSQL)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"QRYNEG",.F.,.T.)

		If QRYNEG->(Eof())
		   MsgAlert("Não existem procedimentos com Grau de participação negado na Liberação para ser Reembolsado!")
		   lRet := .F.
		Endif

		QRYNEG->(DbCloseArea())
	Endif
Endif

RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcoes   ³ PLSVDRNR											          ³±±
±±³Objetivo  ³ Valida a Rede Nao Referenciada							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVRNR()
LOCAL aDadRDA := {}
LOCAL aArea   := GetArea()

lBAU    := .F.  // Inicializa Variavel Statica.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Se foi informado a rede nao referenciada
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(M->B44_CODREF)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Rede nao referenciada
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	BK6->(dbSetOrder(3) )//BK6_FILIAL, BK6_CODIGO
	If BK6->( MsSeek(xFilial("BK6")+M->B44_CODREF) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Rda referente a Rede nao referenciada
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		BAU->(dbSetOrder(8) )//BAU_FILIAL, BAU_CODBK6
		If BAU->( MsSeek(xFilial("BAU")+BK6->BK6_CODIGO) )
			lBAU := .T.
		Else
			If BK6->(Fieldpos("BK6_CODBAU")) >0 .And. !Empty(BK6->BK6_CODBAU)
				BAU->(dbSetOrder(1) )
				If BAU->( MsSeek(xFilial("BAU")+BK6->BK6_CODBAU) )
					lBAU := .T.
				Endif
			Endif
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
	M->B44_CODRDA := BAU->BAU_CODIGO
	M->B44_NOMRDA := BAU->BAU_NOME
	M->B44_TIPPRE := BAU->BAU_TIPPRE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Profissional relacionado a rda
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	BB0->( DbSetOrder(1) ) //BB0_FILIAL + BB0_CODIGO
	BB0->( MsSeek( xFilial("BB0")+BAU->BAU_CODBB0 ) )

	If BB0->(Found())
		M->B44_REGEXE := BB0->BB0_NUMCR
		M->B44_NOMEXE := BB0->BB0_NOME
		M->B44_CDPFRE := BB0->BB0_CODIGO
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ DadRda
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	PLSDADRDA(M->B44_OPERDA,M->B44_CODRDA,"1",dDataBase,Subs(M->B44_LOCATE,1,3),"")

	aDadRDA := PLSGETRDA()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Atualiza M
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	M->B44_CODESP := aDadRDA[15]
	M->B44_DESESP := aDadRDA[17]
	M->B44_LOCATE := aDadRDA[18]
	M->B44_CODLOC := aDadRDA[12]
	M->B44_DESLOC := aDadRDA[19]
	M->B44_ENDLOC := aDadRDA[20]
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
±±³Funcao    ³PLSA001ESP³ Autor ³ Daher					³ Data ³ 29.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valid Especialidade										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA001ESP()

LOCAL lRet:=.T.

BAQ->(dbSetOrder(1))
If BAQ->(MsSeek(xFilial("BAQ")+PLSINTPAD()+M->B44_CODESP))
	M->B44_DESESP:=BAQ->BAQ_DESCRI
Else
	lRet:= .F.
	Help("",1,"REGNOIS")
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CalcFat	³ Autor ³ TOTVS					³ Data ³ 16.04.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se existe fator de reembolso   					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CalcFat(cCodPla,cVersao,cCodPad,cCodPro,cCodOpe)

LOCAL cSQL 		:= ""
LOCAL nFator	:= 0
DEFAULT cCOdPla := ""
DEFAULT cVersao := ""
DEFAULT cCodPad := ""
DEFAULT cCodPro := ""
DEFAULT cCodOpe := ""

cSQL := "SELECT "
cSQL += "	B32_FATOR "
cSQL += "	FROM "
cSQL += 		RetSQLName("B32")
cSQL += "			INNER JOIN "+RetSQLName("BR8")+" ON "
cSQL += "				BR8_FILIAL = '"+xFilial("BR8")+"' AND "
cSQL += "				BR8_CODPAD = '"+cCodPad+"' AND "
cSQL += "				BR8_CODPSA = '"+cCodPro+"' AND "
If( BR8->(FieldPos("BR8_FATOR"))) > 0
	cSQL += "				BR8_FATOR  IN ('1',' ') AND "
Endif
cSQL += 				RetSQLName("BR8")+".D_E_L_E_T_ = ' ' "
cSQL += "			INNER JOIN "+RetSQLName("B31")+" ON "
cSQL += "				B31_FILIAL = '"+xFilial("B31")+"' AND "
cSQL += "				B31_CODINT = '"+cCodOpe+"' AND "
cSQL += "				B31_CODIGO = '"+cCodPla+"' AND "
cSQL += "				B31_VERSAO = '"+cVersao+"' AND "
cSQL += "				B31_ATIVO  = '1' AND "
cSQL += "				B31_CLASSE = BR8_CLASSE AND "
cSQL +=  				RetSQLName("B31")+".D_E_L_E_T_ = ' ' "
cSQL += "		WHERE "
cSQL += "			B32_FILIAL = '"+xFilial("B32")+"' AND "
cSQL += "			B32_CODINT = '"+cCodOpe+"' AND "
cSQL += "			B32_CODIGO = '"+cCodPla+"' AND "
cSQL += "			B32_VERSAO = '"+cVersao+"' AND "
cSQL += "			(B32_ADEINI = ' ' OR B32_ADEINI <= '"+DtoS(dDataBase)+"') AND "
cSQL += "			(B32_ADEFIM = ' ' OR B32_ADEFIM >= '"+DtoS(dDataBase)+"') AND "
cSQL += "			B32_CLASSE = BR8_CLASSE AND "
cSQL +=  			RetSQLName("B32")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"B32TRB",.F.,.T.)

TCSETFIELD("B32TRB","B32_FATOR","N",17,2)

If !B32TRB->(Eof())
	nFator := B32TRB->B32_FATOR/100
EndIf
B32TRB->(dbCloseArea())

Return nFator


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA001   ºAutor  ³Microsiga           º Data ³  06/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSLOGBrw(oBrowse,cBrowse)

LOCAL aCols    := aClone(oBrowse:aCols)
LOCAL aHeader  := aClone(oBrowse:aHeader)
LOCAL aTrb     := aClone(oBrowse:aVetTrab)
LOCAL nInd
LOCAL nLenHead := Len(aHeader)
LOCAL cCampos  := ""
LOCAL bLogaUsr := { || PLSLOGFIL("Usuário Logado "+BCS->(RetCodUsr())+" Horário "+time()+" Data "+dtoc(Date()),"PLSBRW.LOG") }

If Len(aCols) > 0 .And. Len(aCols[1])-1 <> nLenHead
	PLSLOGFIL("Inicio LOG PLSBRW.LOG aHeader X aCols ["+cBrowse+"]","PLSBRW.LOG")
	eval(bLogaUsr)
	For nInd := 1 To nLenHead
		cCampos += aHeader[nInd,2]+","
	Next
	PLSLOGFIL("Campos do aHeader "+cCampos,"PLSBRW.LOG")
	PLSLOGFIL("Número de campos do aHeader "+AllTrim(Str(nLenHead)),"PLSBRW.LOG")
	PLSLOGFIL("número de campo do aCols (considerando logico)"+AllTrim(Str(Len(aCols[1]))),"PLSBRW.LOG")
	PLSLOGFIL("FIM    LOG PLSBRW.LOG aHeader X aCols ["+cBrowse+"]","PLSBRW.LOG")
Endif

If Len(aCols) > 0 .And. Len(aCols) <> Len(aTrb)
	PLSLOGFIL("Inicio LOG PLSBRW.LOG aCols X aTrb    ["+cBrowse+"]","PLSBRW.LOG")
	eval(bLogaUsr)
	PLSLOGFIL("Tamanho incompativel do aCols em relação ao aTrb","PLSBRW.LOG")
	PLSLOGFIL("Número de linhas do aCols "+Alltrim(Str(Len(aCols))),"PLSBRW.LOG")
	PLSLOGFIL("Número de linhas do aTrb "+Alltrim(Str(Len(aTrb))),"PLSBRW.LOG")
	PLSLOGFIL("Fim    LOG PLSBRW.LOG aCols X aTrb    ["+cBrowse+"]","PLSBRW.LOG")
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA001   ºAutor  ³Microsiga           º Data ³  06/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSRGLOREE()

LOCAL nVlrGlo := 0
LOCAL cSql := ""
Local oSize 		:= Nil
Local oDlgRec		:= Nil
Local oGetBDX		:= Nil
Local oPes01		:= Nil
Local oScroll		:= Nil
Local oPanel		:= Nil
Local oGTecla		:= Nil
Local oGLeg	   		:= Nil
Local cTitulo		:= ""
Local bOK			:= {|| nOpca := 1,oDlgRec:End() }
Local bCancel		:= {|| oDlgRec:End()}
Local bDblCliIte	:= {|| PLSA001ANR(aTrbB45[oGetB45:Linha()],@oGetB45,.F.,.F.,B44->(Recno()))} // Envia o numero do registro do BD6
Local nOpca 		:= 0
Local dDatInt		:= ""
Local aCampos 		:= {}
Local aButtons		:= {}
Local aCabB45	:= {}
Local aDadB45		:= {}
Local aTrbB45		:= {}

//Variáveis de tamanho
Local nLinIni 	:= 0
Local nLinEnd 	:= 0
Local nColIni 	:= 0
Local nColEnd 	:= 0
Local nPosSit		:= 0
Local nPosImg		:= 0
Local nI			:= 0

// Painel cabecalho
LOCAL oGuia
LOCAL cGuia
LOCAL oMatricula
LOCAL cMatricula
LOCAL oSolic
LOCAL cSolic
LOCAL oSenha
LOCAL cSenha
LOCAL oIdade
LOCAL cIdade
LOCAL oRDA
LOCAL cRDA
LOCAL oDataEve
LOCAL dDataEve
LOCAL oSexo
LOCAL cSexo
LOCAL oCID
LOCAL cCID
LOCAL oDataInt
LOCAL dDataInt
LOCAL oPlano
LOCAL cPlano
LOCAL cChave := ""
LOCAL lRet := .T.
LOCAL nCnt := 0

oSize := FwDefSize():New()
oSize:AddObject( "BD5" ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "LEG" ,  100, 15, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "BD6" ,  100, 55, .T., .T. ) // Totalmente dimensionavel
oSize:lProp 	:= .T. // Proporcional
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
oSize:Process() 	   // Dispara os calculos

	BOW->(dbSetorder(01))
	If BOW->(dbSeek(xFilial("BOW")+B44->B44_PROTOC))
		If !(BOW->BOW_STATUS $ "6,7")
			MsgAlert(STR0163)//O protocolo so estara disponivel para recurso apos ser liberado ou negado para o financeiro.

			Return(.F.)
		Endif
	Endif

//Monta aCols e aHeader da BD6
B45->(dbSetorder(1))
If B45->( dbSeek(xFilial("B45")+B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT)) )
	cCampos :=	"B45_IMGSTA,B45_SITRGR,B45_SEQUEN,B45_CODPAD,B45_CODPRO,B45_DESPRO,B45_QTDPRO,B45_VLRPAG,B45_VLRMAN,B45_VLRAPR,B45_VLRGLO"
	Store Header "B45" TO aCabB45 For ( alltrim(SX3->X3_CAMPO) $ cCampos )

	Store COLS "B45" TO aDadB45 FROM aCabB45 VETTRAB aTrbB45 While B45->(B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT) ==;
		xFilial("B45")+B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT) For B45->(B45_VLRGLO) > 0
Else
	MsgAlert("Não foi encontrado nenhum evento para esta guia. ")
	Return(.f.)
Endif

If Len(aDadB45) == 0
	MsgAlert("Esta guia de reembolso não possui nenhum evento glosado.")
	Return(.f.)
Endif

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

For nCnt := 1 to Len(aDadB45)
	nPosSit := GDFieldPos("B45_SITRGR", aCabB45)
	nPosImg := GDFieldPos("B45_IMGSTA", aCabB45)
	If aDadB45[nCnt][nPosSit] == "0"
		aDadB45[nCnt][nPosImg] := "BR_BRANCO"

	Elseif aDadB45[nCnt][nPosSit] == "1"
		aDadB45[nCnt][nPosImg] := "BR_AMARELO"

	Elseif aDadB45[nCnt][nPosSit] == "2"
		aDadB45[nCnt][nPosImg] := "BR_LARANJA"

	Elseif aDadB45[nCnt][nPosSit] == "3"
		aDadB45[nCnt][nPosImg] := "BR_VERDE"

	Elseif aDadB45[nCnt][nPosSit] == "1"
		aDadB45[nCnt][nPosImg] := "BR_VERMELHO"

	Elseif Empty(aDadB45[nCnt][nPosSit])
		aDadB45[nCnt][nPosImg] := "BR_BRANCO"

	Endif
Next

cTitulo:="Recurso de Glosa de reembolso"
DEFINE MSDIALOG oDlgRec TITLE cTitulo FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] of oMainWnd Pixel

nLinIni := oSize:GetDimension("BD5","LININI")
nColIni := oSize:GetDimension("BD5","COLINI")
nLinEnd := oSize:GetDimension("BD5","LINEND")
nColEnd := oSize:GetDimension("BD5","COLEND")

oScroll := TScrollBox():Create( oDlgRec, nLinIni, nColIni, nLinEnd, nColEnd , .T., .T., .T.)
oPanel  := TPanel():New( 1, 1, "", oScroll, , .F., , , , 530, 110, .F., .F. )

@ 005,005 SAY "Número da Guia" SIZE 100,010 PIXEL OF oPanel //Matrícula
cGuia := B44->(B44_OPEUSR+B44_CODPEG+B44_CODLDP+B44_NUMGUI)

@ 012,005 MSGET oGuia VAR cGuia PICTURE "@!" WHEN .F. SIZE 080,010 PIXEL OF oPanel

cMatricula := B44->(B44_OPEUSR+B44_CODEMP+B44_MATRIC+B44_TIPREG)+"-"+B44->B44_NOMUSR
@ 005,100 SAY "Matrícula" SIZE 100,010 PIXEL OF oPanel //Usuário
@ 012,100 MSGET oMatricula VAR cMatricula  PICTURE "@!" WHEN .F. SIZE 200,010 PIXEL OF oPanel

@ 005,315 SAY "Prestador" SIZE 100,010 PIXEL OF oPanel
cSolic := B44->B44_CODRDA+"-"+B44->B44_NOMRDA
@ 012,315 MSGET oSolic VAR cSolic PICTURE "@!" WHEN .F. SIZE 200,010 PIXEL OF oPanel

nLinIni := oSize:GetDimension("LEG","LININI")
nColIni := oSize:GetDimension("LEG","COLINI")
nLinEnd := oSize:GetDimension("LEG","LINEND")
nColEnd := oSize:GetDimension("LEG","COLEND")

oGTecla := TGroup():New(nLinIni,nColIni,nLinEnd,nColEnd/2.1,"Teclas de Atalho"	, , , ,.T.) //"Teclas de Atalho"
@ nLinIni + 10,nColIni + 10  SAY "F5 - Incluir Recurso de Glosa" 	SIZE 070,020 PIXEL OF oGTecla //"F5 - Incluir Regurso de Glosa"
@ nLinIni + 10,nColIni + 110 SAY "F6 - Analisar Recurso" 			SIZE 060,020 PIXEL OF oGTecla //"F6 - Analisar Recuso"
@ nLinIni + 20,nColIni + 10  SAY "F7 - Visualizar Histórico" 		SIZE 100,020 PIXEL OF oGTecla //"F7 - Visualizar Histórico"

nColIni := nColEnd/1.9
oGLeg := TGroup():New(nLinIni,nColIni,nLinEnd,nColEnd,"Legenda"			, , , ,.T.) // //"Legenda"

@ nLinIni + 10,nColIni + 10 BitMap NAME "BR_BRANCO" SIZE 8, 8 NOBORDER Of  oGLeg PIXEL
@ nLinIni + 10,nColIni + 20 Say "Sem recurso de Glosa" Of  oGLeg PIXEL // "Liberado"

@ nLinIni + 10,nColIni + 80 BitMap NAME "BR_AMARELO" SIZE 8, 8 NOBORDER Of  oGLeg PIXEL
@ nLinIni + 10,nColIni + 90 Say "Recurso Protocolado" Of oGLeg PIXEL // "Liberado"

@ nLinIni + 10,nColIni + 150 BitMap NAME "BR_LARANJA" SIZE 8, 8 NOBORDER Of  oGLeg PIXEL
@ nLinIni + 10,nColIni + 160 Say "Recurso em análise" Of  oGLeg PIXEL // "Liberado"

@ nLinIni + 20,nColIni + 10 BitMap NAME "BR_VERDE" SIZE 8, 8 NOBORDER Of  oGLeg PIXEL
@ nLinIni + 20,nColIni + 20 Say "Recurso Autorizado" Of  oGLeg PIXEL // "Liberado"

@ nLinIni + 20,nColIni + 80 BitMap NAME "BR_VERMELHO" SIZE 8, 8 NOBORDER Of  oGLeg PIXEL
@ nLinIni + 20,nColIni + 90 Say "Recurso Negado" Of  oGLeg PIXEL // "Liberado"

nLinIni := oSize:GetDimension("BD6","LININI")
nColIni := oSize:GetDimension("BD6","COLINI")
nLinEnd := oSize:GetDimension("BD6","LINEND")
nColEnd := oSize:GetDimension("BD6","COLEND")

//Cria a getdados
oGetB45 := TPLSBrw():New(nLinIni,nColIni,nColEnd,nLinEnd,nil,oDlgRec,nil,bDblCliIte,nil,nil,nil,.T.,nil,.T.,nil,aCabB45,aDadB45,.F.,"B45",K_Alterar,"Recurso de Glosa",nil,nil,nil,aTrbB45,nil,nil,nil,nil) //"Analise de Contas"
oGetB45:lAddLine := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura Keys...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F7 ,{||A001HRG(aTrbB45[oGetB45:Linha()] )})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgRec ON INIT Eval({ || EnchoiceBar(oDlgRec,bOk,bCancel,.F.,aButtons) }) CENTERED
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca retorno contido no aRetorno...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET KEY VK_F5 TO
SET KEY VK_F6 TO
SET KEY VK_F7 TO
SET KEY VK_F8 TO
SET KEY VK_F9 TO
SET KEY VK_F10 TO
SET KEY VK_F11 TO
SET KEY VK_F12 TO

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA498ANR³ Autor ³ Everton M. Fernandes	³ Data ³ 06.03.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravação da Guia do Recurso de Glosa                      	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSA001ANR(nRegB45,oGetB45,lParecer,lOpcaoIncluir,nRegB44)

Local lRet 			:= .F.
Local lAlt			:= .F.
Local oDlgRec		:= Nil
Local oBtnBanco		:= Nil
Local oBtnFechar	:= Nil
Local oBtnSalvar	:= Nil
Local oData			:= Nil
Local oSay1			:= Nil
Local oSay2			:= Nil
Local oSayData		:= Nil
Local oUsuario		:= Nil
Local oObs			:= Nil
Local oSay3			:= Nil
Local oSay4			:= Nil
Local oSay5			:= Nil
Local oSay6			:= Nil
Local oSay7			:= Nil
Local oSay8			:= Nil
Local oDente		:= Nil
Local oFace			:= Nil
Local oParecer		:= Nil
Local oProc			:= Nil
Local oDtPar		:= Nil
Local oDtAn			:= Nil
Local oBtnAnexa 	:= Nil
Local cProc			:= ""
Local cParecer 		:= "0"
Local cChave
Local dData 		:= Date()
Local dDtPar 		:= StoD("")
Local dDtAn 		:= StoD("")
Local cObs 			:= ""
Local aRet			:= {}
Local cUsuario 		:= __cUserId + " - " + cUserName
Local bSalva		:= {||aRet := PLS001RECG(nRegB45,dData,cObs, __cUserId,cParecer,dDtAn,dDtPar,nVlrAct,oGetB45),oDlgRec:End()}
Local lRefresh		:=.F.
LOCAL oVlrGlo
LOCAL nVlrGlo := 0
LOCAL nVlrApr := 0
LOCAL oVlrApr := 0
LOCAL nVlrPag := 0
LOCAL oVlrPag := 0
LOCAL oVlrAct
LOCAL nVlrAct := 0

Default nRegB45 	:= 0
Default lParecer	:= .F.

// Protecao primaria.
If nRegB45 == 0
	// Mensagem de alerta
	Return(.f.)
Endif

// Posiciona o BD6
B45->(dbGoto(nRegB45))

// Protecao redundante.
If B45->(Eof())
	MsgStop("Erro de inconsistencia na tabela de eventos do reembolso (B45)")
	Return(.F.)
Endif

//Guarda a chave para pesquisa no bco de conhecimento
cChave 	:= B45->(B45_OPEMOV+B45_CODLDP+B45_CODPEG+B45_NUMERO+B45_ORIMOV+B45_SEQUEN+B45_CODPAD+B45_CODPRO+B45_SEQRCR)
cStatus := B45->B45_SITRGR
nVlrApr	:= B45->B45_VLRAPR
nVlrGlo := B45->B45_VLRGLO
nVlrPag	:= B45->B45_VLRPAG

nVlrAct	:= 0
If lOpcaoIncluir .and. (val(cStatus)>0)
	Help("",1,"PPL498RCG")
	return(.f.)
Endif

//Valida o status para decidir a operaçao a realizar.
If cStatus $ " ,0,4" //Sem Recurso

	//---------------------------------------
	// Monta a Dialog para incluir um recurso
	//---------------------------------------
	cTitulo:="Incluir recurso de glosa"  //Recurso de Glosa

	DEFINE MSDIALOG oDlgRec TITLE cTitulo FROM 0,0 TO 295,400 of oMainWnd Pixel

	@ 008, 009 SAY oSayData PROMPT "Data da solicitação" SIZE 053, 007 OF oDlgRec PIXEL
	@ 016, 009 MSGET oData VAR dData SIZE 057, 010 OF oDlgRec VALID !Empty(dData) PICTURE "@D" PIXEL
		                                                                  `
	@ 009, 100 SAY oSay1 PROMPT "Usuário da solicitação" SIZE 090, 007 OF oDlgRec PIXEL
	@ 016, 100 MSGET oUsuario VAR cUsuario SIZE 090, 010 OF oDlgRec WHEN .F. PICTURE "@D" PIXEL

	@ 037, 009 SAY oSay2 PROMPT "Observações" SIZE 033, 007 OF oDlgRec PIXEL
	@ 048, 009 GET oObs VAR cObs OF oDlgRec MULTILINE SIZE 185, 078 HSCROLL PIXEL

	@ 130, 064 BUTTON oBtnAnexa  PROMPT "Anexar arquivo" 		SIZE 055, 012 OF oDlgRec ACTION PLSDOcs("B45", B45->( Recno() ) ,3) PIXEL
	@ 130, 123 BUTTON oBtnSalvar PROMPT "Salvar"            	SIZE 037, 012 OF oDlgRec ACTION eval(bSalva) PIXEL
	@ 130, 164 BUTTON oBtnFechar PROMPT "Fechar"                SIZE 037, 012 OF oDlgRec ACTION oDlgRec:End() PIXEL

	ACTIVATE MSDIALOG oDlgRec CENTER

ElseIf  cStatus $ "1,2,3"

	//Inicia as variáveis
	DbSelectArea("BVO")
	BVO->(DbSetOrder(3))
	If BVO->(DbSeek(xFilial("BVO")+B45->(B45_OPEMOV+B45_CODLDP+B45_CODPEG+B45_NUMERO+B45_ORIMOV+B45_SEQUEN+B45_CODPAD+B45_CODPRO+B45_SEQRCR)) )
		dData	:= BVO->BVO_DATA
		cObs	:= BVO->BVO_OBS
		dDtAn	:= BVO->BVO_DTAN
		dDtPar	:= BVO->BVO_DTPAR
		nVlrAct := BVO->BVO_VLRACT

		If BVO->BVO_STATUS =="3"
			cParecer := "1"
		ElseIf BVO->BVO_STATUS =="4"
			cParecer := "2"
		Else
			cParecer := "0"
		EndIf
	EndIf

	DbSelectArea("BR8")
	BR8->(DbSetOrder(1))
	If BR8->(DbSeek(xFilial("BR8")+PlsIntPad()+B45->(B45_CODPAD+B45->B45_CODPRO) ) )
		cProc := BR8->(BR8_CODPAD+BR8_CODPSA) + " - " + BR8->(BR8_DESCRI)
	Else
		cProc := B45->(B45_CODPAD+B45->B45_CODPRO)
	EndIf

	//Verifica se deve iniciar a análise e
	//Se os campos podem ser alterados.
	If cStatus $ "1" .AND. MsgYesNo( "Iniciar Analise do Recurso?", "Recurso de Glosa" ) //"Iniciar Analisa do Recurso?" ## "Recurso de Glosa"
		lAlt := .T.
		dDtAn := Date()
	ElseIf cStatus $ "2"
		lAlt := .T.
	Else
		lAlt := .F.
	EndIf

	//Define a Dialog
	DEFINE MSDIALOG oDlgRec TITLE "Recurso de Glosa" FROM 000, 000  TO 450, 630 PIXEL

	@ 007, 005 SAY oSay4 PROMPT "Proc. da Guia:" SIZE 038, 007 OF oDlgRec PIXEL
	@ 017, 005 MSGET oProc VAR cProc SIZE 082, 010 OF oDlgRec WHEN .F. PICTURE "@!" PIXEL

	@ 007, 100 SAY oSayData PROMPT "Dt Solicitação" SIZE 053, 007 OF oDlgRec PIXEL
	@ 017, 100 MSGET oData VAR dData SIZE 050, 010 OF oDlgRec WHEN .F. PICTURE "@D" PIXEL

	@ 007, 205 SAY oSay5 PROMPT "Dt Análise" SIZE 053, 007 OF oDlgRec PIXEL
	@ 017, 205 MSGET oDtAn VAR dDtAn SIZE 050, 010 OF oDlgRec WHEN .F. PICTURE "@D" PIXEL

	@ 040, 005 SAY oSay8 PROMPT "Valor Apresentado:" SIZE 50, 007 OF oDlgRec PIXEL
	@ 050, 005 MSGET oVlrApr VAR nVlrApr SIZE 082, 010 OF oDlgRec WHEN .F. PICTURE  X3Picture("B45_VLRMAN") PIXEL

	@ 040, 100 SAY oSay8 PROMPT "Valor Glosado:" SIZE 50, 007 OF oDlgRec PIXEL
	@ 050, 100 MSGET oVlrGlo VAR nVlrGlo SIZE 80, 010 OF oDlgRec WHEN .F. PICTURE X3Picture("B45_VLRGLO")  PIXEL

	@ 040, 205 SAY oSay8 PROMPT "Valor do Reembolso:" SIZE 50, 007 OF oDlgRec PIXEL
	@ 050, 205 MSGET oVlrPag VAR nVlrPag SIZE 80, 010 OF oDlgRec WHEN .F. PICTURE  X3Picture("B45_VLRMAN") PIXEL

	@ 070, 005 SAY oSay3 PROMPT "Parecer" SIZE 025, 007 OF oDlgRec PIXEL
	@ 080, 005 MSCOMBOBOX oParecer VAR cParecer ITEMS {"0=Sem Parecer","1=Autorizado","2=Negado"} SIZE 080, 010 OF oDlgRec ;
										WHEN !(BVO->BVO_STATUS $ "3,4") .AND. lAlt ON CHANGE Iif(cParecer == '0', dDtPar := Stod(""),dDtPar :=Date()) PIXEL

	@ 070, 100 SAY oSay7 PROMPT "Data do Parecer" SIZE 053, 007 OF oDlgRec PIXEL
	@ 080, 100 MSGET oDtPar VAR dDtPar SIZE 050, 010 OF oDlgRec WHEN lAlt PICTURE "@D" PIXEL

	@ 070, 205 SAY oSay8 PROMPT "Valor Acatado:" SIZE 50, 007 OF oDlgRec PIXEL
	@ 080, 205 MSGET oVlrAct VAR nVlrAct SIZE 060, 010 OF oDlgRec WHEN (cParecer=="1" .and. cStatus <> '3') PICTURE X3Picture("B45_VLRMAN") VALID VldGlosa(nVlrGlo,nVlrAct) PIXEL

	@ 095, 006 SAY oSay2 PROMPT "Observações" SIZE 033, 007 OF oDlgRec PIXEL
	@ 105, 004 GET oObs VAR cObs OF oDlgRec MULTILINE SIZE 280, 070 HSCROLL WHEN lAlt PIXEL

	If cStatus <> '3'
		If lAlt
			@ 180, 072 BUTTON oBtnAnexa PROMPT "Anexar arquivo" 	SIZE 064, 012 OF oDlgRec ACTION PLSDOcs("B45", B45->( Recno() ) ,3) PIXEL
		EndIf
	Endif

	@ 180, Iif(cStatus <> '3',142,180) BUTTON oBtnAnexa PROMPT "Guias Geradas" 			SIZE 064, 012 OF oDlgRec ACTION A001HRG(nRegB45,nRegB44 ) PIXEL

	@ 180, 250 BUTTON oBtnFechar PROMPT "Fechar" SIZE 035, 012 OF oDlgRec ACTION oDlgRec:End() PIXEL

	ACTIVATE MSDIALOG oDlgRec CENTERED

Endif

If Len(aRet) > 0
	If aRet[1]
		//Atualiza a varivel de controle do Status
		cStatus := B45->B45_SITRGR
		lRefresh := .T.
	Else
		MsgAlert(aRet[2]) //aRet[2] ==> cCritica
	EndIf

	lRet := aRet[1]
EndIf

//Atualiza o grid e altera as cores das legendas.
If lRefresh
	oGetB45:FieldPut("B45_SITRGR",cStatus,oGetB45:Linha())
	A01TUGRID(@oGetB45, @oGetB45:aCols, oGetB45:aHeader)
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA001   ºAutor  ³Microsiga           º Data ³  06/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP
             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldGlosa(nVlrGlo, nVlrAct)

lRet := .T.
If nVlrAct > nVlrGlo
	MsgAlert("O valor do recurso não pode ser maior que o valor glosado.")
	lRet := .F.
Elseif nVlrAct < 0
 	MsgAlert("O valor do recurso não pode ser menor ou igual a ZERO.")
	lRet := .F.
Endif

Return (lRet)

/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSAGRVREC³ Autor ³ Everton M. Fernandes	³ Data ³ 06.03.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravação do Recurso de Glosa                           	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLS001RECG(nRegB45,dData,cObs,__cUserId,cParecer,dDtAn,dDtPar,nVlrAct,oGetB45)

Local cSeq			:= "000"
Local lRet			:= .T.
LOCAL cCritica	:= ""
LOCAL nQtd			:= 0
Local nMax			:= 0
Local aRetGui		:= {}
Local I__f := 0
LOCAL nCnt := 0
LOCAL aColsB45		:= {}
LOCAL aCabB45 		:= {}
LOCAL aTrbB45 		:= {}
LOCAL nOpc			:= 3 // Sempre será operacao 3, inclusão.
LOCAL nI			:= 0
LOCAL nPsGuiOri		:= 0
LOCAL cCodOpe 		:= ""
LOCAL cCodLdp 		:= ""
LOCAL cCodPeg 		:= ""
LOCAL cNumero 		:= ""
LOCAL cOriMov 		:= ""
LOCAL cSeqPro 		:= ""
LOCAL cCodPad 		:= ""
LOCAL cCodPro 		:= ""
LOCAL cSeqRec 		:= ""

// Altera os dados referente aos novos valores.
LOCAL nPsVlrPag 	:= ""
LOCAL nPsVlrBpr 	:= ""
LOCAL nPsVlrApr 	:= ""
LOCAL nPsVlrMan 	:= ""
LOCAL nPsVlrGlo 	:= ""
LOCAL nPsVlrPPF 	:= ""
LOCAL nPsVlrTPF 	:= ""
LOCAL nPsVlrBPF 	:= ""

DEFAULT nRegB45		:= 0
DEFAULT dData		:= cTod("")
DEFAULT cObs		:= ""
DEFAULT __cUserId	:= ""
DEFAULT cParecer	:= ""
DEFAULT dDtAn		:= cTod("")
DEFAULT dDtPar		:= cTod("")
DEFAULT nVlrAct		:= 0
DEFAULT oGetB45		:= NIL

If oGetB45 == NIL
	Return()
Endif

If nRegB45 == 0
	Return(.F.)
Else
	B45->(dbGoto(nRegB45))
Endif

cCodOpe := B45->B45_OPEMOV
cCodLdp := B45->B45_CODLDP
cCodPeg := B45->B45_CODPEG
cNumero := B45->B45_NUMERO
cOriMov := B45->B45_ORIMOV
cSeqPro := B45->B45_SEQUEN
cCodPad := B45->B45_CODPAD
cCodPro := B45->B45_CODPRO
cSeqRec := B45->B45_SEQRCR

DbSelectArea("BVO")
BVO->(DbSetOrder(5))
If !BVO->(DbSeek(xFilial("BVO")+cCodOpe+cCodLdp+cCodPeg+cNumero+cOriMov+cSeqPro+cCodPad+cCodPro+cSeqRec))
	cStatus := "1"
	cSeqRec	:= "001"

	A01ATUBVO(.T.,cCodOpe,cCodLdp,cCodPeg,cNumero,cOriMov,cCodPad,cCodPro,cSeqPro,;
		cSeqRec,dData,dDtAn,dDtPar,cObs,cStatus,nVlrAct)
Else
	If cStatus $ "4,0, " //Sem Recurso

		//Seleciona a sequencia
		While !BVO->(EOF()) .AND. BVO->(BVO_FILIAL+BVO_CODOPE+BVO_CODLDP+BVO_CODPEG+BVO_NUMERO+BVO_ORIMOV+BVO_SEQUEN+BVO_CODPAD+BVO_CODPRO) ==;
				xFilial("BVO")+cCodOpe+cCodLdp+cCodPeg+cNumero+cOriMov+cSeqPro+cCodPad+cCodPro

			If BVO->BVO_STATUS == "1"
				cCritica := "Este evento já possui um recurso protocolado aguardando analise."

			Elseif BVO->BVO_STATUS == "2"
				cCritica := "Este evento já possui um recurso sendo analisado."

			Elseif BVO->BVO_STATUS == "3"
				cCritica := "Este evento já foi autorizado."

			Elseif BVO->BVO_STATUS == "4"
				nQtd ++ // Registra a quantidade de recursos negados.

			Endif

			//Verifica se existem outros recursos em aberto.
			If !Empty(cCritica)
				lRet := .F.
				Exit
			EndIf

			BVO->(DbSkip())
		EndDo

		If lRet
			DbSelectArea("BA0")
			BA0->(DbSetOrder(1))
			If BA0->( DbSeek(xFilial("BA0")+ PlsIntPad() ) )
				nMax := BA0->BA0_MAXRG
			EndIf
			If nMax == 0 .OR. nQtd > nMax // TODO: Comparar com a quantidade maxima de tentativas permitidas, conforme especificacao
				cCritica := "Para este evendo não cabe mais recurso" // Melhorar mensagem.
				lRet := .F.

			Else
				cSeq := Soma1(cSeqRec)
				cStatus := "1"
				lInclui := .T.
			EndIf
		EndIf

	Elseif cStatus $ "1,2"

		cSeq := cSeqRec
	 	//Permite gravar e altera o status.
		lRet := .T.
		lInclui := .F.

		//Analisa o parecer
		If cParecer == '0' //Sem Parecer
			cStatus := "2"
			BVO->(RecLock("BVO", .F.))
			BVO->BVO_OBS 	:= cObs
			BVO->BVO_DTPAR  := dDtPar
			BVO->BVO_DTAN	:= dDtAn
			BVO->(MsUnlock())

			// Atualiza o recurso e deixa ele em analise.
			A01ATUBVO(.T.,cCodOpe,cCodLdp,cCodPeg,cNumero,cOriMov,cCodPad,cCodPro,cSeqPro,;
				cSeqRec,dData,dDtAn,dDtPar,cObs,cStatus,0)

		ElseIf cParecer ==	'1' //Autorizado

		    /*****************
		    Inicia o processo de criação de uma nova guia daqui pra frente.
		    *****************/

			// Copia os dados da guia atual porque a nova guia será praticamente um clone dela.
			Copy "B44" TO Memory

			// Os campos abaixo são resetados porque deverão ser atualizados com
			// o conteudo da nova guia que será gerada.
			M->B44_ANOAUT := ""
			M->B44_MESAUT := ""
			M->B44_NUMAUT := ""
			M->B44_CODLDP := ""
			M->B44_NUMGUI := ""
			M->B44_DATPAG := CTOD("")
			M->B44_CODPEG := ""
			M->B44_CHVSE1 := ""
			M->B44_CODRDA := GetMV("MV_PLSRDAG")
			M->B44_NOMRDA := Posicione("BAU",1,xFilial("BAU")+M->B44_CODRDA,"BAU_NOME")
			M->B44_GUIORI := cCodOpe+cCodLdp+cCodPeg+cNumero+cOriMov+cSeqPro

			// Redefine os valores
			M->B44_VLRBPR := nVlrAct
			M->B44_VLRGLO := 0
			M->B44_VLRMAN := nVlrAct

			M->B44_VLRAPR := nVlrAct

			M->B44_VLABPF := nVlrAct
			M->B44_VLRPAG := nVlrAct

			M->B44_PREFIX 	:= ""
			M->B44_NUM 		:= ""
			M->B44_PARCEL 	:= ""
			M->B44_TIPO 	:= ""
			M->B44_DATRMB	:= ""
			// Define o aHeader e aCols dos eventos.
			Store Header "B45" TO aCabB45 For .T.

			// Considerar apenas o registro ja posicionado.
			cChave := B45->(B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT)
			STORE COLS "B45" TO aColsB45 FROM aCabB45 VETTRAB aTrbB45 While cChave == B45->(B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT)

			If Len(aColsB45) == 0
				MsgAlert("Problema ao montar a matriz de eventos")
				Return(.F.)
			Endif

			B45->(dbGoto(nRegB45))

   			// Altera os dados referente aos novos valores.
			nPsVlrPag := PLRETPOS("B45_VLRPAG",aCabB45)
			nPsVlrBpr := PLRETPOS("B45_VLRBPR",aCabB45)
			nPsVlrApr := PLRETPOS("B45_VLRAPR",aCabB45)
			nPsVlrMan := PLRETPOS("B45_VLRMAN",aCabB45)
			nPsVlrGlo := PLRETPOS("B45_VLRGLO",aCabB45)
			nPsVlrPPF := PLRETPOS("B45_PERCPF",aCabB45)
			nPsVlrTPF := PLRETPOS("B45_VLRTPF",aCabB45)
			nPsVlrBPF := PLRETPOS("B45_VLRBPF",aCabB45)
			nPsGuiOri := PLRETPOS("B45_GUIORI",aCabB45)

			aColsB45[Len(aColsB45)][nPsVlrPag] := nVlrAct
			aColsB45[Len(aColsB45)][nPsVlrBpr] := nVlrAct
			aColsB45[Len(aColsB45)][nPsVlrApr] := nVlrAct
			aColsB45[Len(aColsB45)][nPsVlrMan] := nVlrAct
			aColsB45[Len(aColsB45)][nPsVlrGlo] := 0

			aColsB45[Len(aColsB45)][nPsVlrPPF] := 0
			aColsB45[Len(aColsB45)][nPsVlrTPF] := 0
			aColsB45[Len(aColsB45)][nPsVlrBPF] := 0

			aColsB45[Len(aColsB45)][nPsGuiOri] := cCodOpe+cCodLdp+cCodPeg+cNumero+cOriMov+cSeqPro

			// Define o aHeader e aCols da composição dos eventos.
			Store Header "B47" TO aCabComp For .T.
			nTotal := 0

			B47->(DbSetOrder(1))
			If B47->(MsSeek(xFilial("B47")+B45->(B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT+B45_SEQUEN)))

				STORE COLS "B47" TO aDadComp FROM aCabComp VETTRAB aTrbComp ;
					While B47->(B47_FILIAL+B47_OPEMOV+B47_ANOAUT+B47_MESAUT+B47_NUMAUT+B47_SEQUEN) ==;
					xFilial("B47")+B45->(B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT+B45_SEQUEN)

				For nCnt := 1 To Len(aDadComp)
					nPsPercen := PLRETPOS("B47_PERCEN",aCabComp)
					nPsVlrPag := PLRETPOS("B47_VLRPAG",aCabComp)
					nPsVlrBpr := PLRETPOS("B47_VLRBPR",aCabComp)
					nPsVlrApr := PLRETPOS("B47_VLRAPR",aCabComp)
					nPsVlrMan := PLRETPOS("B47_VLRMAN",aCabComp)
					nPsVlrGlo := PLRETPOS("B47_VLRGLO",aCabComp)

					nVlrAply := round((nVlrAct*aDadComp[nCnt][nPsPercen])/100,3)
					aDadComp[nCnt][nPsVlrPag] := nVlrAply
					aDadComp[nCnt][nPsVlrApr] := aDadComp[nCnt][nPsVlrPag]
					aDadComp[nCnt][nPsVlrMan] := aDadComp[nCnt][nPsVlrPag]
					aDadComp[nCnt][nPsVlrBpr] := aDadComp[nCnt][nPsVlrPag]

					aDadComp[nCnt][nPsVlrGlo] := 0 // A guia resultante não deve herdar o valor da glosa.

					nTotal += nVlrAply
				Next
			Endif

			If nTotal <> nVlrAct
				MsgStop("Divergencia de valor")
				Return()
			Endif

			//³ Carrego o aDadRda da RDA generica										 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PLSDADRDA(M->B44_OPERDA,M->B44_CODRDA,"1",dDataBase,Subs(M->B44_LOCATE,1,3),M->B44_CODESP)
			aRetorno := PLSA090Grv(aColsB45,;
				aCabB45,;
				{},;
				nOpc,;
				aTrbB45,;
				{},;
				M->B44_USUARI,;
				M->B44_DATPRO,;
				M->B44_HORPRO,;
				M->B44_MATUSA,;
				M->B44_ANOPAG,;
				M->B44_MESPAG,;
				'04',;
				.F.,;
				{},;
				{},;
				{},;
				Nil,;
				"1",;
				IIF(nOpc==K_Incluir,GetNewPar("MV_PLSPREM","9000"),B44->B44_CODLDP),;
				Nil,;
				"",;
				"B44",;
				Nil,Nil,NIL,;
				"B45",;
				"B46",;
				Nil,Nil,NIL,;
				.F.,; // Guia de recurso de glosa de reembolso não gera senha.
				.F.,;
				nil,NIL,nil,nil,nil,;
		                /*oBrwComp*/,;
		                "B44",.T.,,;
		                /*oEnchoice*/,/*lIncNeg*/,/*cNFSS*/,/*lSolicit*/,/*cTpGrv*/,/*aColsDF*/,/*aHeaderDF*/,/*aVetDF*/,/*aDaSenPro*/,/*lGuiHoRe*/,/*aMatBd6*/,;
	                  		/*aMatCom*/,/*lResInt*/,/*cAliasCmp*/,/*lOdontoWeb*/,/*cNumLib*/,/*cArqImp*/,/*lEvoSadt*/,/*cSituac*/,;
                   		/*lProtoc*/)

      		B45->(dbGoto(nRegB45))
			If aRetorno[1]
				// Grava o codigo da guia original.
					If !BD5->(Eof())
						BD5->(RecLock("BD5", .F.))
							BD5->BD5_GUIORI := B45->(B45_OPEMOV+B45_CODLDP+B45_CODPEG+B45_NUMERO+B45_ORIMOV+B45_SEQUEN)
						BD5->(MsUnlock())
					Endif

				For nCnt := 1 to Len(aDadComp)
					B47->(RecLock("B47", .T.))
						For nI := 1 To Len(aCabComp)
							cCampo := "B47->"+aCabComp[nI][2]

							If B47->(FieldPos(aCabComp[nI][2])) > 0
								&cCampo := aDadComp[nCnt][nI]
							Endif
						Next

						B47->B47_OPEMOV := B44->B44_OPEMOV
						B47->B47_CODLDP := B44->B44_CODLDP
						B47->B47_ANOAUT := B44->B44_ANOAUT
						B47->B47_MESAUT := B44->B44_MESAUT
						B47->B47_CODPEG := B44->B44_CODPEG
						B47->B47_NUMERO := B44->B44_NUMGUI
						B47->B47_NUMAUT := B44->B44_NUMAUT
						B47->B47_FILIAL := xFilial("B47")
					B47->(MsUnlock())

				Next

				//Guarda o status aprovado
				cStatus := "3"
				A01ATUBVO(.F.,cCodOpe,cCodLdp,cCodPeg,cNumero,cOriMov,cCodPad,;
						  cCodPro,cSeqPro,cSeqRec,dData,dDtAn,dDtPar,cObs,cStatus,nVlrAct)
			Endif

		ElseIf cParecer ==	'2'//Negado
			cStatus := "4"

		EndIf

	Endif
Endif

Return {lRet,cCritica,BVO->BVO_RECURS}

Static Function A01ATUBVO(lInclui,cCodOpe,cCodLdp,cCodPeg,cNumero,cOriMov,cCodPad,;
						  cCodPro,cSeqPro,cSeqRec,dData,dDtAn,dDtPar,cObs,cStatus,nVlrAct)

Begin Transaction
	//Grava os dados do recurso de glosa
	BVO->(RecLock("BVO",lInclui))

	If lInclui
		BVO->BVO_FILIAL := xFilial("BVO")
	Endif

	BVO->BVO_CODOPE	:= cCodOpe
	BVO->BVO_CODLDP	:= cCodLdp
	BVO->BVO_CODPEG	:= cCodPeg
	BVO->BVO_NUMERO	:= cNumero
	BVO->BVO_ORIMOV	:= cOriMov
	BVO->BVO_TIPGUI	:= "04"
	BVO->BVO_CODRDA	:= B44->B44_CODRDA
	BVO->BVO_CODLOC	:= B44->B44_CODLOC
	BVO->BVO_CODESP := B44->B44_CODESP
	BVO->BVO_CODPAD	:= cCodPad
	BVO->BVO_CODPRO	:= cCodPro
	BVO->BVO_SEQUEN	:= cSeqPro
	BVO->BVO_QTDPRO	:= B45->B45_QTDPRO
	BVO->BVO_DATPRO	:= B45->B45_DATPRO
	BVO->BVO_VLRGLO	:= B45->B45_VLRGLO
	BVO->BVO_VLRPAG	:= B45->B45_VLRPAG

	If lInclui
		BVO->BVO_RECURS	:= GetSXENum("BVO","BVO_RECURS")
		BVO->(ConfirmSX8())
	Else
		BVO->BVO_VLRACT += nVlrAct
	EndIf

	BVO->BVO_SEQRGR	:= cSeqRec
	BVO->BVO_DATA  	:= dData
	BVO->BVO_DTAN  	:= dDtAn
	BVO->BVO_DTPAR  := dDtPar
	BVO->BVO_STATUS	:= cStatus
	BVO->BVO_OBS	:= cObs

	BVO->(MsUnlock())

	/*********************************

	Atualiza os registros envolvidos

	*********************************/
	DbSelectArea("BD6")
	BD6->(DbSetOrder(1))
	If BD6->(DbSeek(xFilial("BD6")+cCodOpe+cCodLdp+cCodPeg+cNumero+cOriMov+cSeqPro+cCodPad+cCodPro))
		BD6->(RecLock("BD6",.F.))
		BD6->BD6_SITRGR	:= cStatus
		BD6->BD6_SEQRCR	:= "TESTE" //cSeqRec
		BD6->(MsUnlock())
	EndIf

	If !B45->(Eof())
		B45->(RecLock("B45",.F.))
		B45->B45_SITRGR	:= cStatus
		B45->B45_SEQRCR	:= cSeqRec

		B45->B45_VLRGLO -= nVlrAct
		B45->(MsUnlock())
	Endif

End Transaction

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA001   ºAutor  ³Microsiga           º Data ³  06/14/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A001HRG(nRegB45, nRegB44)

LOCAL aArea := GetArea("B45")
LOCAL cSql := ""
LOCAL aDad := {}
LOCAL aCab := {}
LOCAL cPrefix := ""
LOCAL cNumero := ""
LOCAL cParcel := ""
LOCAL cTipo   := ""
LOCAL oGrupoCab
Local aCampos	:= {}
Local aBls		:= {}

If B45->(Recno()) <> nRegB45
	B45->(dbGoto(nRegB45))
Endif

If B45->(Eof())
	MsgAlert("Problema de base")
Endif

cSql := "Select * from "+RetSqlName("BD5")+" where BD5_FILIAL = '"+xFilial("BD5")+"' "
cSql += "AND BD5_GUIORI = '"+B45->(B45_OPEMOV+B45_CODLDP+B45_CODPEG+B45_NUMERO+B45_ORIMOV+B45_SEQUEN)+"' "
cSql += "AND D_E_L_E_T_ = ' ' "
PlsQuery(cSql, "TRB")

B44->(dbSetorder(01))

While!TRB->(Eof())
If B44->( dbSeek(xFilial("B44")+TRB->(BD5_OPEMOV+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT)) )
	cPrefix := B44->B44_PREFIX
	cNumero := B44->B44_NUM
	cParcel := B44->B44_PARCEL
	cTipo   := B44->B44_TIPO
Else
	cPrefix := ""
	cNumero := ""
	cParcel := ""
	cTipo   := ""
Endif

Aadd(aDad, {TRB->BD5_CODLDP, TRB->BD5_CODPEG, TRB->BD5_NUMERO, TRB->BD5_DATPRO, TRB->BD5_VLRPAG,cPrefix,cNumero,cParcel,cTipo} )

TRB->(dbSkip())
Enddo

TRB->(dbClosearea())
DEFINE MSDIALOG oDlg TITLE "Guias Geradas" FROM 00, 00 TO 450, 850 PIXEL OF GetWndDefault()

@ 030,005 GROUP oGrupoCab TO 065,415 OF oDlg LABEL "Dados da guia"   COLOR CLR_HBLUE, CLR_HRED PIXEL

@ 045,010 SAY oSay PROMPT "Guia"   SIZE 220,010 OF oDlg PIXEL
@ 045,025 SAY oSay PROMPT  B45->(B45_OPEMOV+B45_CODLDP+B45_CODPEG+B45_NUMERO) SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE

@ 045,200 SAY oSay PROMPT "Procedimento"   SIZE 220,010 OF oDlg PIXEL
@ 045,245 SAY oSay PROMPT  B45->(B45_CODPAD+"-"+B45_CODPRO) SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE

@ 070,005 GROUP oGrupoCri TO 195,415 OF oDlg LABEL STR0043  COLOR CLR_HBLUE, CLR_HRED PIXEL

oDad := TcBrowse():New( 085, 010, 400, 110,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
oDad:AddColumn(TcColumn():New("Local Digit.",{ || aDad[oDad:nAt, 1] },"@C",nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil))
oDad:AddColumn(TcColumn():New("Código Peg"  ,{ || aDad[oDad:nAt, 2] },"@C",nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil))
oDad:AddColumn(TcColumn():New("Num. Guia"   ,{ || aDad[oDad:nAt, 3] },"@C",nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))
oDad:AddColumn(TcColumn():New("Criada Em"   ,{ || aDad[oDad:nAt, 4] },"@C",nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil))
oDad:AddColumn(TcColumn():New("Valor Reemb" ,{ || Transform(aDad[oDad:nAt, 5],PLPMONEY_M) },nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
oDad:AddColumn(TcColumn():New("Prefixo "	,{ || aDad[oDad:nAt, 6] },"@C",nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
oDad:AddColumn(TcColumn():New("Titulo" 		,{ || aDad[oDad:nAt, 7] },"@C",nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
oDad:AddColumn(TcColumn():New("Parcela" 	,{ || aDad[oDad:nAt, 8] },"@C",nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
oDad:AddColumn(TcColumn():New("Tipo" 		,{ || aDad[oDad:nAt, 9] },"@C",nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))

oDad:SetArray(aDad)

//-- LGPD --------
if objCENFUNLGP:isLGPDAt()
	aCampos := {"BD5_CODLDP","BD5_CODPEG","BD5_NUMERO","BD5_DATPRO","BD5_VLRPAG","B44_PREFIX","B44_NUM", "B44_PARCEL", "B44_TIPO" }
	aBls := objCENFUNLGP:getTcBrw(aCampos)
	oDad:aObfuscatedCols := aBls
endif
//----------------

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,{||oDlg:End()},{|| oDlg:End()},.F.,{})

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSATUGRID³ Autor ³ Everton M. Fernandes	³ Data ³ 06.03.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza o grid da BD6				                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A01TUGRID(oGetB45, aDadB45, aCabB45)

Local lRet 		:= .T.
Local nPosSit 	:= 0
Local nPosImg 	:= 0
local nCnt 		:= 0
Default aDadB45 := {}

For nCnt := 1 to Len(aDadB45)
	nPosSit := GDFieldPos("B45_SITRGR", aCabB45)
	nPosImg := GDFieldPos("B45_IMGSTA", aCabB45)
	If aDadB45[nCnt][nPosSit] == "0"
		aDadB45[nCnt][nPosImg] := "BR_BRANCO"

	Elseif aDadB45[nCnt][nPosSit] == "1"
		aDadB45[nCnt][nPosImg] := "BR_AMARELO"

	Elseif aDadB45[nCnt][nPosSit] == "2"
		aDadB45[nCnt][nPosImg] := "BR_LARANJA"

	Elseif aDadB45[nCnt][nPosSit] == "3"
		aDadB45[nCnt][nPosImg] := "BR_VERDE"

	Elseif aDadB45[nCnt][nPosSit] == "1"
		aDadB45[nCnt][nPosImg] := "BR_VERMELHO"

	Elseif Empty(aDadB45[nCnt][nPosSit])
		aDadB45[nCnt][nPosImg] := "BR_BRANCO"

	Endif
Next

If ValType(oGetB45) <> 'U'
	oGetB45:ForceRefresh()
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VLDPRFSD³ Autor ³ Thiago Ribas	³ Data ³ 06.08.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida campo B45_CRM da autorição de reembolso            	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VLDPRFSD()

LOCAL lRet

BB0->(DbSetOrder(7))
lRet := BB0->(MsSeek(xFilial("BB0")+M->B45_CRM))
If !lRet
	Help("",1,"REGNOIS")
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ItmRecExc³ Autor ³ Thiago Guilherme       ³ Data ³ 06.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os itens de receita excluidos		       	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ItmRecExc()

LOCAL cSQL
LOCAL oBrowUsr
LOCAL oDlg
LOCAL bOK      	:= { || nOpca := 1, oDlg:End() }
LOCAL bCancel  	:= { || nOpca := 0, oDlg:End() }
Local aObjects	:= {}
Local aPosObj   := {}
LOCAL aColsB7D := {}
Local aCampos	:= {}
Local aBls		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecuina os registros excluidos da tabela						     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT * FROM " + RetSQLName("B7D")
cSQL += " WHERE B7D_BENEFI = '" + BOW->BOW_USUARI + "'"
cSQL += " AND " + RetSQLName("B7D")+".D_E_L_E_T_ = '*'"
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TmpB7D",.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Popula o array com os dados retornados da query					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !TmpB7D->(EOF())
	Aadd(aColsB7D, {TmpB7D->B7D_CODPAD,;
		TmpB7D->B7D_CODMED,;
		TmpB7D->B7D_BENEFI,;
		TmpB7D->B7D_DTVINI,;
		TmpB7D->B7D_DTFVAL,;
		TmpB7D->B7D_QTDAUT,;
		TmpB7D->B7D_QTDEXE,;
		TmpB7D->B7D_OBS})

		TmpB7D->(dbSkip())
EndDo
TmpB7D->(dbCloseArea())

If LEN(aColsB7D) > 0

	DEFINE MSDIALOG oDlg TITLE "Receitas Excluidas" FROM 030,020 TO 050,150 OF GetWndDefault()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ cria as colunas e insere os dados correspondete a cada coluna     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrowUsr := TcBrowse():New( 003 , 003, 510, 130,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

	oBrowUsr:bLDblClick := {||VisuExc(oBrowUsr)}

	oBrowUsr:AddColumn(TcColumn():New("Cod. Pad.",nil,;
		nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowUsr:ACOLUMNS[1]:BDATA     := { || aColsB7D[oBrowUsr:nAt,1] }

	oBrowUsr:AddColumn(TcColumn():New("Cod. Pro.",nil,;
		nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowUsr:ACOLUMNS[2]:BDATA     := { || aColsB7D[oBrowUsr:nAt,2] }

	oBrowUsr:AddColumn(TcColumn():New("Matric.",nil,;
		nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowUsr:ACOLUMNS[3]:BDATA     := { || aColsB7D[oBrowUsr:nAt,3] }

	oBrowUsr:AddColumn(TcColumn():New("Data Ini. Val.",nil,;
		nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowUsr:ACOLUMNS[4]:BDATA     := { || STOD(aColsB7D[oBrowUsr:nAt,4]) }

	oBrowUsr:AddColumn(TcColumn():New("Data Fin. Val.",nil,;
		nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowUsr:ACOLUMNS[5]:BDATA     := { || STOD(aColsB7D[oBrowUsr:nAt,5]) }

	oBrowUsr:AddColumn(TcColumn():New("Qtd. Autorizada",nil,;
		nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowUsr:ACOLUMNS[6]:BDATA     := { || aColsB7D[oBrowUsr:nAt,6] }

	oBrowUsr:AddColumn(TcColumn():New("Qtd. Realizada",nil,;
		nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowUsr:ACOLUMNS[7]:BDATA     := { || aColsB7D[oBrowUsr:nAt,7] }

	oBrowUsr:AddColumn(TcColumn():New("Mot. Exclusão",nil,;
		nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowUsr:ACOLUMNS[8]:BDATA     := { || aColsB7D[oBrowUsr:nAt,8] }

	oBrowUsr:SetArray(aColsB7D)

	//-- LGPD --------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {"B7D_CODPAD","B7D_CODMED","B7D_BENEFI","B7D_DTVINI","B7D_DTFVAL","B7D_QTDAUT","B7D_QTDEXE", "B7D_OBS" }
		aBls := objCENFUNLGP:getTcBrw(aCampos)
		oBrowUsr:aObfuscatedCols := aBls
	endif
	//----------------

	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) CENTER

Else
	Alert(STR0167)

EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VisuExc³ Autor ³ Thiago Guilherme       ³ Data ³ 06.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ retorna o motivos da exclusao do intem do reembolso	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VisuExc(oObj)

LOCAL oDlg
LOCAL cMotivo
LOCAL oMemo
LOCAL bCancel  := { || nOpca := 0, oDlg:End() }
LOCAL bOK      := { || nOpca := 1, oDlg:End() }

If !EMPTY(oObj:Aarray[oObj:nAt][8])
	DEFINE MSDIALOG oDlg TITLE STR0166 FROM 009,000 TO 019,050 OF GetWndDefault()

	@ 005,005 Get oMemo VAR oObj:Aarray[oObj:nAt][8] Memo SIZE 190,053 OF oDlg PIXEL NO BORDER
	oMemo:lReadOnly := .T.

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Ativa o dialogo...                                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.)

EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSMSGRMB³ Autor ³ Thiago Guilherme       ³ Data ³ 06.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ retorna a mensagem de multi-selecao para aprovacao
de reembolso.															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function PLSMSGRMB()

If !__lmesg
	msgAlert(STR0165)
	__lmesg := .T.
EndIf

return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuCmp ºAutor  ³ TOTVS              º Data ³ 26/11/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpa os campos odontológicos quando o campo B45_CODPRO é
			  alterado        											  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
function AtuCmp()

If Readvar() == "M->B45_CODPRO"
	M->B45_DENREG := Space(TamSx3("B45_DENREG")[1])
	M->B45_DESREG := Space(TamSx3("B45_DESREG")[1])
	M->B45_FADENT := Space(TamSx3("B45_FADENT")[1])
	M->B45_FACDES := Space(TamSx3("B45_FACDES")[1])

	If !EMPTY(M->B44_PROTOC)
		M->B45_NOMSOL := Posicione("BB0",4,xFilial("BB0")+B1N->B1N_ESTSOL+B1N->B1N_REGSOL+B1N->B1N_SIGLA,"BB0_NOME")
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AlterWhen ºAutor  ³ TOTVS              º Data ³ 26/11/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera a propriedade x3_when dos campos odontologicos
da autorização de reembolso se um procedimento odontologico for selecionadoº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
function AlterWhen()

LOCAL cOdonto:= Posicione("BR8",1,xFilial("BR8") + M->B45_CODPAD + M->B45_CODPRO, "BR8_ODONTO")

If cOdonto == "1"
	Return .T.
Else
	Return .F.
EndIf

Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValGRAUPA ºAutor  ³ Thiago Ribas       º Data ³ 07/05/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o grau de participação de acordo com o procedimentoº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ValGRAUPA(cGrau)

LOCAL cSQL := ""
LOCAL nQuant := ""

If EMPTY(M->B45_CODPRO)
	Help("",1,"PL001100")
	Return .F.
EndIf

cSQL := "SELECT BWT_DESCRI, BWT_CODPAR, BD4_CODPRO," + RetSQLNAME("BWT") + ".R_E_C_N_O_ AS RECNO FROM " + RetSQLNAME("BWT")
cSQL += " INNER JOIN " + RetSQLNAME("BD4")
cSQL += " ON BWT_CODPAR = BD4_CODTPA "
cSQL += "WHERE BD4_CODPRO = '" + M->B45_CODPRO + "' AND "
cSQL += "BWT_CODPAR = '" + cGrau + "' AND "
cSQL += RetSQLNAME("BWT") + ".D_E_L_E_T_ = '' AND " + RetSQLNAME("BD4") + ".D_E_L_E_T_ = '' "
cSQL += "GROUP BY BWT_DESCRI, BWT_CODPAR, BD4_CODPRO, " + RetSQLNAME("BWT") + ".R_E_C_N_O_"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ executa a query
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'''
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPes",.F.,.T.)

Count To nQuant

TrbPes->( DbCloseArea() )

If nQuant > 0

	Return .T.
Else
	Help( ,, STR0049,,STR0228, 1, 0)
	Return .F.
EndIf

Return

/*±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LmpCmpB45   ºAutor  ³Thiago Guilherme   º Data ³  28/05/15º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Limpa campos
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION LmpCmpB45()

M->B45_REGSOL := Space(TamSx3("B45_REGSOL")[1])
M->B45_NOMSOL := Space(TamSx3("B45_NOMSOL")[1])
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRWB45    ºAutor  ³Rodrigo Morgon      º Data ³  16/09/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona no array aColsB45 as informacoes dos itens da B1N º±±
±±º          ³ de acordo com o protocolo alterado na rotina PLSA001A      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BRWB45(aCab45,aColsB45,nProtocolo)

LOCAL aArea
LOCAL aBlank     :=  {}
LOCAL nPosLegend :=	PLRETPOS("B45_IMGSTA",aCab45)
LOCAL nPosSeque  :=	PLRETPOS("B45_SEQUEN",aCab45)
LOCAL nPosCodPro :=	PLRETPOS("B45_CODPRO",aCab45)
LOCAL nPosDesPro :=	PLRETPOS("B45_DESPRO",aCab45)
LOCAL nPosQtdPro :=	PLRETPOS("B45_QTDPRO",aCab45)
LOCAL nPosCodPad :=	PLRETPOS("B45_CODPAD",aCab45)
LOCAL nPosDatPro :=	PLRETPOS("B45_DATPRO",aCab45)
LOCAL nPosVlrApr :=	PLRETPOS("B45_VLRAPR",aCab45)
LOCAL nPosNF     :=	PLRETPOS("B45_NF"    ,aCab45)
LOCAL nPosEstado :=	PLRETPOS("B45_EST"   ,aCab45)
LOCAL nPosCodMun :=	PLRETPOS("B45_CODMUN",aCab45)
LOCAL nPosHorPro :=	PLRETPOS("B45_HORPRO",aCab45)
LOCAL nPosStatus :=	PLRETPOS("B45_STATUS",aCab45)
LOCAL nPosCodRef :=	PLRETPOS("B45_CODREF",aCab45)
LOCAL nPosSeqB1n :=	PLRETPOS("B45_SEQB1N",aCab45)
LOCAL nPosMatric :=	PLRETPOS("B45_MATRIC",aCab45)
LOCAL nPosNomeBe :=	PLRETPOS("B45_NOMEBE",aCab45)
Local nPosValori :=	PLRETPOS("B45_VALORI",aCab45)
Local nPosNivaut :=	PLRETPOS("B45_NIVAUT",aCab45)
Local nPosChvniv :=	PLRETPOS("B45_CHVNIV",aCab45)
Local nPosDnvaut :=	PLRETPOS("B45_DNIVAU",aCab45)
Local nPosIntde  :=	PLRETPOS("B45_INTDE" ,aCab45)
Local nPosIntate :=	PLRETPOS("B45_INTATE",aCab45)
Local nPosGuipri :=	PLRETPOS("B45_GUIPRI",aCab45)
Local nPosVia    := PLRETPOS("B45_VIA"	 ,aCab45) 
Local nPosPerVi  := PLRETPOS("B45_PERVIA",aCab45) 
Local nPosNLib   := PLRETPOS("B45_NUMLIB",aCab45) 
Local nPosSigla  := PLRETPOS("B45_SIGLA" ,aCab45) 
Local nPosEstSo  := PLRETPOS("B45_ESTSOL",aCab45) 
Local nPosRegSo  := PLRETPOS("B45_REGSOL",aCab45) 
Local nPosNomSo  := PLRETPOS("B45_NOMSOL",aCab45) 
Local nPosNomRf  := PLRETPOS("B45_NOMREF",aCab45) 
Local nPosSqBe2  := PLRETPOS("B45_SEQBE2",aCab45)
Local nPosPadInt := PLRETPOS("B45_PADINT",aCab45)
Local nPosPadCon := PLRETPOS("B45_PADCON",aCab45)
Local nPosGrpInt := PLRETPOS("B45_GRPINT",aCab45)
Local nPosTipInt := PLRETPOS("B45_TIPINT",aCab45)
Local nPosRegInt := PLRETPOS("B45_REGINT",aCab45)
LOCAL nPosABATPF := PLRETPOS("B45_ABATPF",aCab45) 
LOCAL nProcCi	 := PLRETPOS("B45_PROCCI",aCab45) 
LOCAL nIndB45    := 1
LOCAL nPosBn1Pad := B1N->(FieldPos("B1N_PADINT"))
LOCAL nPosBn1Con := B1N->(FieldPos("B1N_PADCON"))
LOCAL nPosBn1Grp := B1N->(FieldPos("B1N_GRPINT"))
LOCAL nPosBn1Tip := B1N->(FieldPos("B1N_TIPINT"))
LOCAL nPosBn1Reg := B1N->(FieldPos("B1N_REGINT"))

//Define data e hora na abertura
M->B44_HORPRO := StrTran(Time(),":","")
M->B44_DATPRO := dDataBase

If PLSALIASEX("B1N")
	aArea 		:= GetArea("B1N")

	B1N->(dbSetOrder(2))	//	Por sequência
	B1N->(MsSeek(xFilial("B1N")+nProtocolo))

	While !B1N->(Eof()) .and. (B1N->B1N_PROTOC == nProtocolo)
		if nIndB45 > 1
			Store COLS Blank "B45" TO aBlank FROM aCabB45
			aAdd(aColsB45, aBlank[1]) 	//Adiciona novo indice ao array com elementos vazios
		EndIf

		aColsB45[nIndB45][nPosLegend] := B1N->B1N_IMGSTA
		aColsB45[nIndB45][nPosStatus] := IIF(AllTrim(B1N->B1N_IMGSTA) == "ENABLE","1","0")
		aColsB45[nIndB45][nPosSeque]  := B1N->B1N_SEQUEN
		aColsB45[nIndB45][nPosCodPro] := B1N->B1N_CODPRO
		aColsB45[nIndB45][nPosDesPro] := POSICIONE('BR8',1,XFILIAL('BR8')+B1N->B1N_CODPAD+B1N->B1N_CODPRO,'BR8_DESCRI')
		aColsB45[nIndB45][nPosQtdPro] := B1N->B1N_QTDPRO
		aColsB45[nIndB45][nPosCodPad] := B1N->B1N_CODPAD
		aColsB45[nIndB45][nPosDatPro] := B1N->B1N_DATPRO
		aColsB45[nIndB45][nPosVlrApr] := B1N->B1N_VLRAPR
		aColsB45[nIndB45][nPosNF]     := B1N->B1N_NUMDOC
		aColsB45[nIndB45][nPosEstado] := B1N->B1N_EST
		aColsB45[nIndB45][nPosCodMun] := B1N->B1N_CODMUN
		aColsB45[nIndB45][nPosHorPro] := M->B44_HORPRO
		aColsB45[nIndB45][nPosCodRef] := B1N->B1N_CODREF
		aColsB45[nIndB45][nPosSeqB1n] := M->B45_SEQB1N := B1N->B1N_SEQUEN	//	Para uso na rotina "P001ValRe"
		aColsB45[nIndB45][nPosMatric] := M->B45_MATRIC := B1N->B1N_MATRIC	//	Para uso na rotina "P001ValRe"
		aColsB45[nIndB45][nPosNomeBe] := Posicione("BA1",2,xFilial("BA1")+B1N->B1N_MATRIC,"BA1_NOMUSR")
		acolsB45[nIndB45][nPosValori] := "1"
 		aColsB45[nIndB45][nPosIntde]  := B1N->B1N_INTDE
 		aColsB45[nIndB45][nPosIntate] := B1N->B1N_INTATE
 		aColsB45[nIndB45][nPosGuipri] := B1N->B1N_GUIPRI
		aColsB45[nIndB45][nPosNLib]   := B1N->B1N_NUMLIB 

		If nPosBn1Pad > 0
			aColsB45[nIndB45][nPosPadInt] := B1N->B1N_PADINT
		Endif

		If nPosBn1Con > 0 
			aColsB45[nIndB45][nPosPadCon] := B1N->B1N_PADCON
		Endif 

		If nPosBn1Grp > 0 
			aColsB45[nIndB45][nPosGrpInt] := B1N->B1N_GRPINT
		Endif 

		If nPosBn1Tip > 0
			aColsB45[nIndB45][nPosTipInt] := B1N->B1N_TIPINT
		Endif 

		If nPosBn1Reg > 0 
			aColsB45[nIndB45][nPosRegInt] := B1N->B1N_REGINT
		Endif
		
		//Inclusão do sequencial da liberação vinculada ao item do protocolo
		If B45->(FieldPos("B45_SEQBE2")) > 0
			aColsB45[nIndB45][nPosSqBe2] := B1N->B1N_SEQBE2
		EndIf 

		If B1N->(FieldPos("B1N_ABATPF")) > 0 
			aColsB45[nIndB45][nPosABATPF] := B1N->B1N_ABATPF
		EndIf

		aColsB45[nIndB45][nPosSigla]  := B1N->B1N_SIGLA 
		aColsB45[nIndB45][nPosEstSo]  := B1N->B1N_ESTSOL 
		aColsB45[nIndB45][nPosRegSo]  := B1N->B1N_REGSOL 
		aColsB45[nIndB45][nPosNomSo]  := Posicione("BB0",4,xFilial("BB0") + B1N->(B1N_ESTSOL + B1N_REGSOL + B1N_SIGLA),"BB0_NOME")
		aColsB45[nIndB45][nPosNomRf]  := Posicione("BK6",4,xFilial("BK6") + ALLTRIM(B1N->B1N_CODREF),"BK6_NOME") 
		
 		If B1N->(FieldPos("B1N_VIA")) > 0 
	 		aColsB45[nIndB45][nPosVia]   := B1N->B1N_VIA
	 		aColsB45[nIndB45][nPosPerVi] := Posicione("BGR",1,xFilial("BGR")+PLSINTPAD()+B1N->B1N_VIA,"BGR_PERC")
 		EndIf 

		if !Empty(B1N->B1N_GUIPRI)
			aColsB45[nIndB45][nPosDatPro] := B1N->B1N_DATPRO
		Endif

		If nProcCi > 0
			aColsB45[nIndB45][nProcCi]  := Iif((POSICIONE('BR8',1,XFILIAL('BR8')+B1N->B1N_CODPAD+B1N->B1N_CODPRO,'BR8_TIPEVE') $ "2,3"), "1","0") 
		EndIf

		B1N->(dbSkip()) 			//Avanca para proximo registro
		nIndB45++ 					//Incrementa o contador
	Enddo

	RestArea(aArea)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValReProt ºAutor  ³Rodrigo Morgon      º Data ³  24/09/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona no array aColsB47 as informacoes de composicao    º±±
±±º          ³ dos itens (B7M) do protocolo alterado na rotina PLSA001A   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ValReProt(aColsB45,aCabB45)
LOCAL nX := 0
LOCAL nY := 0
LOCAL aMemDados := {}
LOCAL nPosCampo := 0
LOCAL nPosIMGSTA :=	PLRETPOS("B45_IMGSTA",aCabB45)
LOCAL nPosVLRAPR :=	PLRETPOS("B45_VLRAPR",aCabB45)
LOCAL nPosVLRPAG :=	PLRETPOS("B45_VLRPAG",aCabB45)
LOCAL nPosVALAPT :=	PLRETPOS("B45_VALAPT",aCabB45)
LOCAL nPosVLRGLO :=	PLRETPOS("B45_VLRGLO",aCabB45)
LOCAL nPosVLRMAN :=	PLRETPOS("B45_VLRMAN",aCabB45)
LOCAL nPosVLRBPF :=	PLRETPOS("B45_VLRBPF",aCabB45)
LOCAL nPosBLRTPF :=	PLRETPOS("B45_VLRTPF",aCabB45)
LOCAL nPosVLABPF :=	PLRETPOS("B45_VLABPF",aCabB45)
Local nPosNivaut :=	PLRETPOS("B45_NIVAUT",aCabB45)
Local nPosChvniv :=	PLRETPOS("B45_CHVNIV",aCabB45)
Local nPosCOdPro :=	PLRETPOS("B45_CODPRO",aCabB45)
Local nPosNivcri :=	PLRETPOS("B45_NIVCRI",aCabB45)
local nPosNivel  :=	PLRETPOS("B45_NIVEL" ,aCabB45)
Local nPosDnivau :=	PLRETPOS("B45_DNIVAU",aCabB45)
Local nPosDnivcr :=	PLRETPOS("B45_DNIVCR",aCabB45)
Local nPosEst    :=	PLRETPOS("B45_EST"   ,aCabB45)
local nPosCodmun :=	PLRETPOS("B45_CODMUN",aCabB45)
Local nPosvlrbpr :=	PLRETPOS("B45_VLRBPR",aCabB45)
Local nPosCodtab :=	PLRETPOS("B45_CODTAB",aCabB45)
Local nposAliatb :=	PLRETPOS("B45_ALIATB",aCabB45)
Local nPosAudito :=	PLRETPOS("B45_AUDITO",aCabB45)
Local nPosStatus :=	PLRETPOS("B45_STATUS",aCabB45)
Local nPosAbatpf :=	PLRETPOS("B45_ABATPF",aCabB45)
Local nPosPercpf :=	PLRETPOS("B45_PERCPF",aCabB45)
Local nPosAliapf :=	PLRETPOS("B45_ALIAPF",aCabB45)
Local nPosQtd	 :=	PLRETPOS("B45_QTDPRO",aCabB45)

Local lRet 		 := .T.
Local nPosComp   := 0 
Local nPosPro    := 0
Local nLenComp   := 0
Local nPos47Seq  := 0
Local nPos47Glo  := 0
Local nPos47Pag  := 0
Local nPos45Seq  := 0 
Local nValApr    := 0

SX3->(DbSetOrder(1))
SX3->(MsSeek("B45"))

	//Dados para a memoria
while SX3->(X3_ARQUIVO) == "B45" .AND. !(SX3->(EoF()))
	Aadd(aMemDados, SX3->(X3_CAMPO))
	SX3->(Dbskip())
EndDo

	//Zera os valores dos totalizadores "say"
nValRmb 	:= 0
nValGlosa 	:= 0
nValabpf  	:= 0

for nY := 1 to Len(aColsB45)
	If aColsB45[nY][nPosIMGSTA] <> "DISABLE"
		for nX := 1 to Len(aMemDados) // Faz a busca de cada coluna de variavel de memoria no cabecalho de B45
			nPosCampo := PLRETPOS(aMemDados[nX],aCabB45) //Localiza a posNROicao do campo procurado no array aCabB45
			If ( nPosCampo > 0 )
			&("M->" + aMemDados[nX]) := aColsB45[nY][nPosCampo]
			EndIf
		next
		
		//Posicionamos o objeto na linha do aCols pro PLSA090PRO
		oBrwPro:oBrowse:nAt := nY
		
		M->B45_VLRPAG := 0
		M->B45_VLRGLO := 0
		M->B44_VLABPF := 0

		M->B45_EST    := aColsB45[nY][nPosEst]
		M->B45_CODMUN := aColsB45[nY][nPosCodmun]
		
		If B1N->(FieldPos("B1N_SEQBE2")) == 0 
			aColsB45[nY][nPosAbatpf] := M->B45_ABATPF
		EndIf

		M->B45_CODPRO := aColsB45[nY][nPosCOdPro]

		RunTrigger(1,,,,"B45_CODPRO")
		PLSA090PRO()
		
		//Realiza alteração para ícone verde (habilitado) ou vermelho (desabilitado) nos itens da autorização
		//Primeira aba "Eventos"
		lRet := P001ValRe("B44","B45","B47",.T.) 

		If !EmpTy(M->B45_ABATPF)
			aColsB45[nY][nPosPercpf]	:=	M->B45_PERCPF
		EndIf

		aColsB45[nY][nPosIMGSTA]	:=	M->B45_STATUS
		aColsB45[nY][nPosVLRAPR]	:=	M->B45_VLRAPR
		aColsB45[nY][nPosVLRPAG]	:=	M->B45_VLRPAG
		aColsB45[nY][nPosVALAPT]	:=	M->B45_VALAPT
		
		If M->B45_STATUS = "0"
			aColsB45[nY][nPosVLRGLO]	:=	M->B45_QTDPRO * M->B45_VLRAPR
		Else
			aColsB45[nY][nPosVLRGLO]	:=	M->B45_VLRGLO
		EndIf
		
		aColsB45[nY][nPosVLRMAN]	:=	M->B45_VLRMAN
		aColsB45[nY][nPosVLRBPF]	:=	M->B45_VLRBPF
		aColsB45[nY][nPosBLRTPF]	:=	M->B45_VLRTPF
		aColsB45[nY][nPosVLABPF]	:=	M->B45_VLABPF
		acolsB45[nY][nPosNivaut] := M->B45_NIVAUT
		acolsB45[nY][nPosChvniv] := M->B45_CHVNIV
		aColsB45[nY][nPosNivcri] := M->B45_NIVCRI
		aColsB45[nY][nPosNivel]  := M->B45_NIVEL
		aColsB45[nY][nPosCodtab] := M->B45_CODTAB
		aColsB45[nY][nPosAliatb] := M->B45_ALIATB
		aColsB45[nY][nPosAudito] := M->B45_AUDITO

		IF (UPPER(AllTrim(FUNNAME())) == "PLSA001A")
			acolsB45[nY][nPosStatus] := M->B45_STATUS
		Endif
		If M->B45_ABATPF == "1"
			aColsB45[nY][nPosAliapf] := M->B45_ALIAPF
		EndIf

		If !Empty(acolsB45[nY][nPosNivaut])
			M->B45_DNIVAU := PLSRETNCRI(M->B45_NIVAUT, M->B45_CHVNIV,M->B45_NIVCRI)
		Endif
		If !Empty(aColsB45[nY][nPosNivcri])
			M->B45_DNIVCR := PLSRETNCRI(M->B45_NIVAUT, M->B45_CHVNIV,M->B45_NIVCRI)
		Endif

		aColsB45[nY][nPosDnivau] := M->B45_DNIVAU
		aColsB45[ny][nPosDnivcr] := M->B45_DNIVCR

		//Verificação para não cair em type mismatch em algumas situações..
		aColsb45[nY][nPosvlrbpr] := IIf( Valtype(M->B45_VLRBPR) <> "N", 0, M->B45_VLRBPR)
		M->B45_VLRBPR	:= aColsb45[nY][nPosvlrbpr]

		M->B45_VALORI := "1" //o procedimento já está valorado, somente para marcar o campo em memória e passar a validação

		IF (UPPER(AllTrim(FUNNAME())) == "PLSA001A")
			PL001Cor(nY,aCabB45,aColsB45)
		Endif
		
		//Se o campo B45_VLRPAG estiver zerado, significa que a valoração para
		//o procedimento corrente não funcionou, desta forma a validação é desconsiderada
		//e a crítica será exibida.
		If M->B45_VLRPAG > 0 .OR. M->B45_VLRGLO > 0
			P001Vld()
		Else
			lRet := .F.
		EndIf

		nValRmb += If(M->B45_STATUS == "1", M->B45_VLRPAG, 0)
		oSayD:cCaption := "R$ " + ALLTRIM(TransForm(nValRmb,PesqPict("BD6","BD6_VLRPAG")))

		If M->B45_STATUS == "0"
			nValGlosa += M->B45_QTDPRO * M->B45_VLRAPR
		Else

			nValGlosa += M->B45_VLRGLO
		EndIf

		oSayF:cCaption := "R$ " + ALLTRIM(TransForm(nValGlosa,PesqPict("BD6","BD6_VLRPAG")))

		nValabpf += If(M->B45_STATUS == "1", M->B44_VLABPF, 0)
		oSayH:cCaption := "R$ " + ALLTRIM(TransForm(nValabpf,PesqPict("BD6","BD6_VLRPAG")))
	Else
		aColsB45[nY][nPosVLRGLO]	:=	aColsB45[nY][nPosVLRAPR] * aColsB45[nY][nPosQtd	]
		nValGlosa += aColsB45[nY][nPosVLRGLO]
		oSayF:cCaption := "R$ " + ALLTRIM(TransForm(nValGlosa,PesqPict("BD6","BD6_VLRPAG")))	
	Endif

	//Caso o evento esteja negado a composição é alterada, foi codificado desta forma pois mexer no que já existe da valorização
	//pode causar um efeito colateral
	If aColsB45[nY][GDFieldPos("B45_STATUS",aCabB45)] == "0" 
		nPos47Seq := GDFieldPos("B47_SEQUEN", oBrwComp:aHeader)
		nPosPro   := Ascan( oBrwComp:acols,{|x| x[nPos47Seq] == aColsB45[nY][GDFieldPos("B45_SEQUEN",aCabB45)] } )
		nLenComp  := LEN(oBrwComp:acols) 
		nPos47Glo := GDFieldPos("B47_VLRGLO", oBrwComp:aHeader)
		nPos47Pag := GDFieldPos("B47_VLRPAG", oBrwComp:aHeader)
		nPos45Seq := GDFieldPos("B45_SEQUEN", oBrwPro:aHeader )
		nValApr   := 0
		
		If nPosPro > 0
			For nPosComp := nPosPro To nLenComp
				If oBrwComp:acols[nPosComp][nPos47Seq] == aColsB45[nY][nPos45Seq]
	
					oBrwComp:acols[nPosComp][nPos47Glo] := oBrwComp:acols[nPosComp][nPos47Pag] 
					oBrwComp:acols[nPosComp][nPos47Pag] := 0
	
					nValApr += oBrwComp:acols[nPosComp][GDFieldPos("B47_VLRBPR",oBrwComp:aHeader)]
				Else
					EXIT
				EndIf
			Next
		Endif
		aColsb45[nY][nPosvlrbpr] := nValApr
	EndIf 
next

oBrwPro:oBrowse:nAt := 1

If MV_FRQUIA 
	PLID33Set(.T.)
EndIf 

M->B44_VLRPAG	:= nValRmb
M->B44_VLRGLO	:= nValGlosa

M->B44_VLABPF	:= nValabpf
M->B44_VLRMAN	:= nVlrManG

oSayC:Refresh()
oSayD:Refresh()
oSayE:Refresh()
oSayF:Refresh()
oSayG:Refresh()
oSayH:Refresh()

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PRMBBXREC³ Autor ³               ³ Data ³ 13.09.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Status Parcial no Protocolo para Autorização Parcialmente Negada³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function P001Status(cChave, cProtoc)

LOCAL aArea 	:= getArea()
LOCAL lAtuBow :=  .F.

Default cProtoc:=""
Default cChave:=""

If !EMPTY(cProtoc)
	B45->(dbSetorder(1))
	If B45->( dbSeek(xFilial("B45")+cChave ) )
		While !B45->(Eof()) .AND. B45->(B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT) == xFilial("B45") +  cChave
			B1N->(DbSetOrder(2))  
			If B1N->(MsSeek(xFilial("B1N") + cProtoc + B45->B45_SEQB1N )) 
				IF B1N->B1N_IMGSTA=="ENABLE "
					IF B45->B45_STATUS == '0'
						RecLock("B1N",.F.)
						B1N->B1N_IMGSTAE := "DISABLE"  
						MsUnlock()
						
						AtuB14(cChave, cProtoc, B45->B45_CODPRO, B45->B45_MATRIC, B45->B45_SEQB1N) 
						lAtuBow := .T.
						
					Endif
				Endif
			EndIF
			B45->(DbSkip())
		EndDo
	EndIf
EndIf

IF lAtuBow
	BOW->(dbSetOrder(1))
	If BOW->(dbSeek(xFilial("BOW")+cProtoc))
		BOW->( RecLock("BOW",.F.) )
		BOW->BOW_STATUS= "C"
		BOW->( MsUnLock() )

		PLRMBPRE("B44","B45", BOW->BOW_PROTOC, "C")
	EndIf

	B44->( RecLock("B44",.F.) )
	B44->B44_STATUS := "4"
	B44->( MsUnLock() )
Endif
RestArea(aArea)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLAtuB14³ Autor ³               ³ Data ³ 13.09.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualização Tabela Consulta Prtotocol Parcialmente Negada³  ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ATUB14(cChave, cProtoc, cProced, cMatric, cSeqB1N, cMotivo) 
DEFAULT cMotivo := ""
DEFAULT cProced := ""
DEFAULT cProtoc := ""
DEFAULT cMatric := ""
DEFAULT cSeqB1N := ""
DEFAULT cChave  := ""

If empty(cMotivo)
	
	BCT->(DbSetOrder(1)) //BCT_FILIAL, BCT_CODOPE, BCT_PROPRI, BCT_CODGLO
	B14->(DbSetOrder(1))
	
	if ! B14->(MsSeek(xFilial("B14") + cProtoc + cProced + cMatric + cSeqB1N))
	
		B46->(DbSetOrder(1))//B46_FILIAL, B46_OPEMOV, B46_ANOAUT, B46_MESAUT, B46_NUMAUT, B46_SEQUEN
		if B46->(MsSeek(xFilial("B46") + cChave))
			
			While !B46->(Eof()) .AND. B46->(B46_FILIAL + B46_OPEMOV + B46_ANOAUT + B46_MESAUT + B46_NUMAUT) == xFilial("B46") +  cChave
			
				If ! empty(B46->B46_CODGLO)
				
					IF BCT->(MsSeek(xFilial("BCT") + B46->(B46_OPEMOV + B46_CODGLO)))
				
						//Motivo configurado na BCT para o reembolso
						If ! empty(BCT->BCT_DESREE)
							
							cMotivo := BCT->BCT_DESREE
							
						//Motivo padrão
						else
							cMotivo := BCT->BCT_DESCRI
						endIf
						
						exit
						
					endIf
					
				endIf
			
			B46->(DbSkip())
			EndDo
			
		EndIf
		
	EndIf
	
EndIf

if ! B14->( MsSeek(xFilial("B14") + cProtoc + cProced + cMatric + cSeqB1N) )			
	
	B14->(RecLock("B14",.T.))  
		B14->B14_FILIAL	  := xFilial("B14")
		B14->B14_SEQUEN	  := cSeqB1N
		B14->B14_MATRIC	  := cMatric
		B14->B14_CDPROT	  := cProtoc
		B14->B14_CODUSR	  := PLSRtCdUsr()
		B14->B14_NOMUSR	  := usrRetName(PLSRtCdUsr())
		B14->B14_DATA	  := DdataBase
		B14->B14_CODPRO	  := cProced
		B14->B14_DESPRO	  := ALLTRIM(Posicione("BR8",3,xFilial("BR8")+cProtoc,"BR8_DESCRI"))
		B14->B14_MOTIVO	  := cMotivo
	B14->(MsUnLock())
	
endIf	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSB45PR   ³ Autor ³Thiago Ribas³ Data ³ 20.02.13 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Validação do número da liberação                           ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDLIB(cAlias,lMsg)  

LOCAL   lRet 	 := .T.
LOCAL   cSQL 	 := ""
LOCAL   nQtdReg  := 0
LOCAL   aHeader  := {}
LOCAL   aDados   := {}
LOCAL 	aSize    := {}
LOCAL 	aObjects := {}   
LOCAL 	aInfo 	 := {}
LOCAL 	aPosObj  := {}
LOCAL 	nLarg 	 := {}
LOCAL 	nTop 	 := {}
LOCAL 	nLeft 	 := {}
LOCAL 	nBottom	 := {}
LOCAL 	oGetGrid := NIL
LOCAL   nOpca    := 0
LOCAL   bOK	     := {|| nOpca := 1,oDialog:End()  }
LOCAL   bCancel  := {|| oDialog:End()}
LOCAL   oDialog  := NIL
DEFAULT lMsg := .T.

//Pode ser chamada pelo protocolo e pela autorização de reembolso
If ! empty(&("M->"+cAlias+"_CODPRO")) .AND. !EMPTY(&("M->"+cAlias+"_NUMLIB"))
	
	BEA->(DbSetOrder(1)) //BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO
	If BEA->(MsSeek(xFilial("BEA") + &("M->"+cAlias+"_NUMLIB")) .AND. BEA->BEA_LIBERA == "1")
		
		If  BEA->(BEA_OPEUSR + BEA_CODEMP + BEA_MATRIC + BEA_TIPREG + BEA_DIGITO) == &("M->"+cAlias+"_MATRIC")

			cSQL := "SELECT BE2_SEQUEN,BE2_CODPAD, BE2_CODPRO, BE2_SALDO FROM " + RetSQLNAME("BE2")
			cSQL += " WHERE BE2_OPEMOV = '" + Substr( &("M->"+cAlias+"_NUMLIB") ,01,4) + "' AND "
			cSQL += "BE2_ANOAUT = '" + Substr( &("M->"+cAlias+"_NUMLIB") ,05,4) + "' AND "
			cSQL += "BE2_MESAUT = '" + Substr( &("M->"+cAlias+"_NUMLIB") ,09,2) + "' AND "
			cSQL += "BE2_NUMAUT = '" + Substr( &("M->"+cAlias+"_NUMLIB") ,11,8) + "' AND "
			cSQL += "BE2_CODPAD = '" + &("M->"+cAlias+"_CODPAD") + "' AND "
			cSQL += "BE2_CODPRO = '" + &("M->"+cAlias+"_CODPRO") + "' AND "
			cSQL += "BE2_SALDO  > 0  AND BE2_STATUS = '1' AND "
			cSQL += RetSQLName("BE2")+".D_E_L_E_T_ = ' ' "

			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbLibera",.F.,.T.)

			/*conta a quantidade de registos, se houver dois procedimentos iguais
			com saldo o sistema exibe uma tela que pede para o usuário identificar
			o procedimento correspondente na liberação*/
			Count To nQtdReg

			If nQtdReg > 1 .AND. B1N->(FieldPos("B1N_SEQBE2")) > 0
				
				MsgInfo(STR0294,STR0049) //"A liberação SADT possui procedimentos duplicados, selecione o procedimento que será vinculado ao item do reembolso"|| Atenção

				TrbLibera->(dbGoTop())
				
				While !TrbLibera->(EOF())
					AADD(aDados, {TrbLibera->BE2_SEQUEN, TrbLibera->BE2_CODPAD, TrbLibera->BE2_CODPRO, TrbLibera->BE2_SALDO,.F.})
					TrbLibera->(dbSkip())
				EndDo
				
				aAdd(aHeader,{"Sequencial" 		 , "BE2_SEQUEN", "", 3 , 0, , ,"C", ,"R", , , ,"V", , ,.T.})
				aAdd(aHeader,{"Cod. Tab. Padrão" , "BE2_CODPAD", "", 2 , 0, , ,"C", ,"R", , , ,"V", , ,.T.})
				aAdd(aHeader,{"Cod. Procedimento", "BE2_CODPRO", "", 16, 0, , ,"C", ,"R", , , ,"V", , ,.T.})
				aAdd(aHeader,{"Saldo Disponível" , "BE2_SALDO" , "", 5 , 0, , ,"C", ,"R", , , ,"V", , ,.T.})
				
				aSize := MsAdvSize()
				AAdd( aObjects, { 010, 050, .T., .F. } )
				AAdd( aObjects, { 010, 100, .T., .T. } )
				
				aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
				aPosObj := MsObjSize( aInfo, aObjects )
				
				nLarg 		:= aPosObj[1,4]*0.5 + 5
				nTop 		:= aPosObj[1,1] - 4
				nLeft 		:= aPosObj[1,2] - 4
				nBottom	    := aPosObj[1,3]* 1.77 
				
				DEFINE MSDIALOG oDialog TITLE "Procedimentos repetidos da guia " + &("M->"+cAlias+"_NUMLIB") FROM aSize[7],0 To aSize[4],aSize[3] OF GetWndDefault() Pixel
				DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
				
				oGetGrid := oGet := MSNewGetDados():New(nTop, nLeft, nBottom, nLarg, /*[nStyle]*/, "AlwaysTrue()", "AlwaysTrue()", "" , {}, 0, 9999, "AlwaysTrue()", "AlwaysTrue()", "AlwaysTrue()", oDialog, aHeader, aDados, , "" )
					
				ACTIVATE MSDIALOG oDialog ON INIT Eval({ || EnchoiceBar(oDialog,bOK,bCancel,.F.)  })

				If nOpca == 1

					BE2->(dbSetOrder(1))
					If BE2->(MsSeek( xFilial("BE2") + &("M->"+cAlias+"_NUMLIB") + oGetGrid:aCols[oGetGrid:nAt][1]))
						
						If BE2->BE2_CODPAD ==  &("M->"+cAlias+"_CODPAD") .AND. BE2->BE2_CODPRO ==  &("M->"+cAlias+"_CODPRO") .AND.;
							BE2->BE2_SALDO < &("M->"+cAlias+"_QTDPRO")
							
							If lMsg
								MsgInfo(STR0277 + CVALTOCHAR(BE2->BE2_SALDO) + STR0278) //"Quantidade digitada maior que saldo disponível (saldo: "|| ")"
							EndIf
							
							lRet:=  .F.
						EndIf
					EndIf 
				Else
					lRet:=  .F.
				EndIf

				If lRet
					M->B1N_SEQBE2 := oGetGrid:aCols[oGetGrid:nAt][1]
				EndIf
			Else
				
				BE2->(dbSetOrder(6))

				If nQtdReg == 1 .AND. B1N->(FieldPos("B1N_SEQBE2")) > 0
					
					TrbLibera->(dbGoTop())

					If TrbLibera->BE2_SALDO < &("M->"+cAlias+"_QTDPRO")
						
						If lMsg
							MsgInfo(STR0277 + CVALTOCHAR(TrbLibera->BE2_SALDO) + STR0278) //"Quantidade digitada maior que saldo disponível (saldo: "|| ")"
						EndIf
						lRet:=  .F.
					ELse
						M->B1N_SEQBE2 := TrbLibera->BE2_SEQUEN
					EndIf
				
				ElseIf  BE2->(MsSeek( xFilial("BE2") + &("M->"+cAlias+"_NUMLIB") + &("M->"+cAlias+"_CODPAD") + &("M->"+cAlias+"_CODPRO")))
					
					If BE2->BE2_SALDO < &("M->"+cAlias+"_QTDPRO")
						
						If lMsg
							MsgInfo(STR0277 + CVALTOCHAR(BE2->BE2_SALDO) + STR0278) //"Quantidade digitada maior que saldo disponível (saldo: "|| ")"
						EndIf
						lRet:=  .F.
					EndIf
				Else
					If lMsg
						MsgInfo(STR0292) //"O procedimento selecionado não corresponde a esta liberação"
					EndIf
					lRet := .F.
				EndIf
			EndIf
			
			TrbLibera->(DbCloseArea())
		Else
			If lMsg
				MsgInfo(STR0293) //"Esta liberação SADT não corresponde ao beneficiário selecionado"
			EndIf
			lRet:=  .F.
		EndIf
	Else
		If lMsg
			MsgInfo(STR0290) //"Guia Não encontrada"
		EndIf
		lRet := .F.
	EndIf
EndIf

Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PL001STAT
Retorna o conteúdo de uma variável STATIC qualquer do fonte PLSA001
@author	Oscar Zanin
@since		15/03/2016
@version	P12
/*/
//---------------------------------------------------------------------------------------
Function PL001STAT(cVariavel)
Return &(cVariavel)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSDTINT³ Autor ³ Giuvany Silva    ³ Data ³ 24-03-16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Validação das Datas de Internação e de Alta		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDIN()

Local lRet := .T.

If !EMPTY(M->B45_DATPRO) .AND. !EMPTY(M->B45_INTATE)
	If M->B45_DATPRO > M->B45_INTATE .OR. M->B45_DATPRO < M->B45_INTDE
		Alert("Data do Procedimento informado é Inválida para Guia Principal de Internação selecionada")
		lRet := .F.
	Endif
Endif

Return(lRet)
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSStReemb
Função para ajustar o Status da autrização de reembolso no PLSA090
@author	Oscar Zanin
@since		18/10/2016
@version	P12
/*/
//---------------------------------------------------------------------------------------
function PLSStReemb(cStatusOri, cModo)
Local cRet := cStatusOri //Sempre atribuímos o status que o PLSA090 ia deixar
Local csql	:=""
Default cModo := "1"

//Esse aqui é pra sempre deixar a autorização como pendente liberação
If cModo == "1"//If EmpTy(cStatPro) //Se não preencheu a STATIC, não veio do protocolo
	If cStatusOri == "2" //.AND. cStatPro == "C" //Se teve glosa no protocolo direto, mas a guia ainda ia ser autorizada, mudamos pra parcialmente autorizada
		cRet := "1" 
	EndIf
EndIf

//Esse aqui é pra ver se tem item não autorizado junto dos autorizados. Estamos posicionados na B44.
If cModo == "2"
	cSql := " Select B45_STATUS from " + RetSqlName("B45") + " where B45_CODLDP = '" + B44->B44_CODLDP + "' " //17-01 ini
	cSql += " AND B45_CODPEG = '" + B44->B44_CODPEG + "' AND B45_NUMERO = '" + B44->B44_NUMGUI + "' "
	cSql += " AND B45_STATUS = '0' AND D_E_L_E_T_ = ' ' " //17-01 fim
	
	cSQL := ChangeQuery(cSQL)
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"PLSStReemb",.F.,.T.)

	If !(PLSStReemb->(Eof()))
		cRet :="4"
	EndIf	
	
	PLSStReemb->(DbCloseArea())
		
EndIf

return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A001Inverte
Função para marcar e desmarcar todos da MarkBrowse

@author    Lucas Nonato
@version   V12
@since     26/01/2017
/*/
//------------------------------------------------------------------------------------------
Function A001Inverte() 
Local nReg 	 := B44->(Recno())

//Verifica a existencia do indice 7
If !TCCanOpen(RetSqlName("B44"), RetSqlName("B44") + "7")

	B44->( dbgotop() )

	While !B44->(Eof())
		// Marca ou desmarca. Este metodo respeita o controle de semaphoro.
		oMBrwB44:MarkRec()

		B44->(dbSkip())
	Enddo
Else

	//Seleciona apenas as guias com o status pendente de aprovação.
	B44->(DbSetOrder(7))
	B44->(MsSeek(xFilial("B44") + "1"))

	While !B44->(Eof()) .AND. B44->B44_STATUS == "1"
		// Marca ou desmarca. Este metodo respeita o controle de semaphoro.
		oMBrwB44:MarkRec()

		B44->(dbSkip())
	Enddo
EndIf

B44->(dbGoto(nReg))
oMBrwB44:oBrowse:Refresh(.t.)

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} P001CDEL
Função para deletar composição

@author    Francisco Edcarlo
@version   V12
@since     30/03/2017
/*/
//------------------------------------------------------------------------------------------
Function P001CDEL()
Local lRet := .T.
Local nFor 	 := 1
LOCAL nVlrPagPro := 0
LOCAL nVlrManPro := 0
LOCAL nVlrGloPro := 0
LOCAL nVlrBprPro := 0
LOCAL nVlrVabpf  := 0
LOCAL cAliCab	 := "B44"
LOCAL cAliPro	 := "B45"
LOCAL cAliCom	 := "B47"
LOCAL nPosPag    := PLRETPOS(cAliCom+"_VLRPAG",oBrwComp:aHeader)
LOCAL nPosGlo	 := PLRETPOS(cAliCom+"_VLRGLO",oBrwComp:aHeader)
LOCAL nPosMan	 := PLRETPOS(cAliCom+"_VLRMAN",oBrwComp:aHeader)
LOCAL nPosBpr	 := PLRETPOS(cAliCom+"_VLRBPR",oBrwComp:aHeader)
LOCAL nPosPer	 := PLRETPOS(cAliCom+"_PERCEN",oBrwComp:aHeader)
LOCAL nPosApf	 := PLRETPOS(cAliCom+"_VLRBFP",oBrwComp:aHeader)
LOCAL nRecBrw	 := oBrwComp:oBrowse:nAt

LOCAL nPosPagP    := PLRETPOS(cAliPro+"_VLRPAG",oBrwPro:aHeader)
LOCAL nPosGloP	 := PLRETPOS(cAliPro+"_VLRGLO",oBrwPro:aHeader)
LOCAL nPosManP	 := PLRETPOS(cAliPro+"_VLRMAN",oBrwPro:aHeader)
LOCAL nPosBprP	 := PLRETPOS(cAliPro+"_VLRBPR",oBrwPro:aHeader)
LOCAL nPosApfP	 := PLRETPOS(cAliPro+"_VLABPF",oBrwPro:aHeader)
LOCAL nPosTpfP	 := PLRETPOS(cAliPro+"_VLRTPF",oBrwPro:aHeader)
LOCAL nRecBrwP	 := oBrwPro:oBrowse:nAt

//For nFor :=1 to Len(oBrwComp:aCols)
		nVlrPagPro += oBrwComp:aCols[nRecBrw][nPosPag]
		nVlrManPro += oBrwComp:aCols[nRecBrw][nPosMan]
		nVlrGloPro += oBrwComp:aCols[nRecBrw][nPosGlo]
		nVlrBprPro += oBrwComp:aCols[nRecBrw][nPosBpr]
		nVlrVabpf  += ROUND(oBrwPro:aCols[nRecBrwP][nPosTpfP] * oBrwComp:aCols[nRecBrw][nPosPer] / 100, 2)
		
//Next

If !oBrwComp:IsDeleted(nRecBrw)
	if (oBrwPro:aCols[nRecBrwP][nPosPagP] - (nVlrPagPro - nVlrVabpf) > 0)
		aColsB45[nRecBrwP][nPosPagP] -= (nVlrPagPro - nVlrVabpf)
		aColsB45[nRecBrwP][nPosManP] -= nVlrManPro
		//aColsB45[nRecBrwP][nPosGloP] -= nVlrGloPro
		aColsB45[nRecBrwP][nPosBprP] -= nVlrBprPro
		aColsB45[nRecBrwP][nPosApfP] -= nVlrVabpf
		
		oBrwPro:aCols[nRecBrwP][nPosPagP] -= (nVlrPagPro - nVlrVabpf)
		oBrwPro:aCols[nRecBrwP][nPosManP] -= nVlrManPro
		//oBrwPro:aCols[nRecBrwP][nPosGloP] -= nVlrGloPro
		oBrwPro:aCols[nRecBrwP][nPosBprP] -= nVlrBprPro
		oBrwPro:aCols[nRecBrwP][nPosApfP] -= nVlrVabpf
		
		&("M->"+cAliCab+"_VLRPAG") -= (nVlrPagPro - nVlrVabpf)
		&("M->"+cAliCab+"_VLRMAN") -= nVlrManPro
		//&("M->"+cAliCab+"_VLRGLO") -= nVlrGloPro
		&("M->"+cAliCab+"_VLRBPR") -= nVlrBprPro
		&("M->"+cAliCab+"_VLABPF") -= nVlrVabpf
	
		__nValRmb   -= nVlrPagPro
		__nValGlosa -= nVlrGloPro
		__nValabpf  -= nVlrVabpf
	else
		MsgAlert("Não é permitido excluir todas as composições do evento! ")
		lRet := .F.
	Endif
Else
	aColsB45[nRecBrwP][nPosPagP] += (nVlrPagPro - nVlrVabpf)
	aColsB45[nRecBrwP][nPosManP] += nVlrManPro
	//aColsB45[nRecBrwP][nPosGloP] += nVlrGloPro
	aColsB45[nRecBrwP][nPosBprP] += nVlrBprPro
	aColsB45[nRecBrwP][nPosApfP] += nVlrVabpf

	oBrwPro:aCols[nRecBrwP][nPosPagP] += (nVlrPagPro - nVlrVabpf)
	oBrwPro:aCols[nRecBrwP][nPosManP] += nVlrManPro
	//oBrwPro:aCols[nRecBrwP][nPosGloP] += nVlrGloPro
	oBrwPro:aCols[nRecBrwP][nPosBprP] += nVlrBprPro
	oBrwPro:aCols[nRecBrwP][nPosApfP] += nVlrVabpf
	
	&("M->"+cAliCab+"_VLRPAG") += (nVlrPagPro - nVlrVabpf)
	&("M->"+cAliCab+"_VLRMAN") += nVlrManPro
	//&("M->"+cAliCab+"_VLRGLO") += nVlrGloPro
	&("M->"+cAliCab+"_VLRBPR") += nVlrBprPro
	&("M->"+cAliCab+"_VLABPF") += nVlrVabpf

	__nValRmb   += nVlrPagPro
	__nValGlosa += nVlrGloPro
	__nValabpf  += nVlrVabpf  
Endif


oSayC:Refresh()
oSayD:Refresh()
oSayE:Refresh()
oSayF:Refresh()
oSayG:Refresh()
oSayH:Refresh()

oBrwComp:setpos(nRecBrw)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA001BB0³ Autor ³ Daher		            ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca BB0   											      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLA001BB0(cBusca)

	Local cRetorno := ""
	
	BB0->( DbSetOrder(4) ) //BB0_FILIAL + BB0_CODIGO
	BB0->( MsSeek( xFilial("BB0") + cBusca ) )

	If BB0->(Found())
		if(cBusca == BB0->BB0_ESTADO + BB0->BB0_NUMCR + BB0->BB0_CODSIG)
			cRetorno := BB0->BB0_NOME
		endif 
	endif

Return(cRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLAADDZBrw
Função para manipular o oBrwPro Static desse fonte. Precisa dela pra situações que
alteram o acolsb45 em um PE e precisa equalizar no objeto
@author Oscar Zanin
@since 29/01/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLAADDZBrw(anovoItem)

aadd(oBrwPro:aCols, anovoItem)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLMARKRMB
Armazena o recno de todas as guias selecionadas
@author Thiago Ribas
@since 03/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLMARKRMB(obj)

LOCAL nScan := 0

If obj:IsMark(obj:Mark()) 
	
	If B44->B44_STATUS == "1" 
		AADD(__aMark,{B44->(RECNO()),B44->B44_FORPAG == "1"}) 
	Else
		obj:MarkRec() 
	EndIf
Else
	nScan := Ascan(__aMark,{ |x| x[1] == B44->(RECNO())})
	
	//deleta o registro desmarcado
	If nScan > 0
		//Deleta os dados da posição
		ADEL(__aMark, nScan)
		
		//Deleta a posição do array que ficou vazio após o ADEL
		ASIZE(__aMark, LEN(__aMark) - 1)	
	EndIf
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLRETMARK
Retorna o aray com as guias selecionadas para o PLSA001A, pois o array
é statico e foi criado dentro da função principal
@author Thiago Ribas
@since 03/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLRETMARK()
Return __aMark
