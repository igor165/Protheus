#INCLUDE "plsa092.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "PLSMCCR.CH"  

STATIC oBrwPro		:= NIL
STATIC oBrowUsr		:= NIL
STATIC  oBrwBQV		:= NIL
STATIC oBrwBQZ		:= NIL
STATIC oBrwB4Q		:= NIL
STATIC oBrwCri		:= NIL
STATIC oEncInt		:= NIL
STATIC cPadPro	    := ""
STATIC aMatCom		:= {}
STATIC aDadB43    	:= {}
STATIC aCabB43    	:= {}
STATIC aTrbB43    	:= {}
STATIC aDProAux		:= {}
STATIC aDCriAux		:= {}
STATIC aAutFor  	:= {}
STATIC aCdCores 	:= {;
	{ 'BR_VERDE'   ,STR0001 },; //'Autorizada'
	{ 'BR_AMARELO' ,STR0002 },; //'Autorizada Parcialmente'
	{ 'BR_VERMELHO',STR0003 },; //'Nao Autorizada'
	{ 'BR_MARRON'  ,STR0004 },; //'Aguardando finalizacao do atendimento'
	{ 'BR_AZUL'	   , STR0181}} //"Em analise pela auditoria"  
STATIC __cCodMedGen := GetNewPar("MV_PLMEDPT","")
STATIC __cCodMatGen := GetNewPar("MV_PLMATPT","")
STATIC __cCodTaxGen := GetNewPar("MV_PLTAXPT","")
STATIC __cCodOpmGen := GetNewPar("MV_PLOPMPT","")

#define  bImpGuia 		{|| IF(ExistBlock("PLSA092IMP"),ExecBlock("PLSA092IMP",.F.,.F.),IIf(GetNewPar("MV_PLSTISS","1")=="1" ,PLSR420N(1),PLSR420())) }
#define  bImpGuiaE   	{|| IF(ExistBlock("PL092EVO")  ,ExecBlock("PL092EVO"  ,.F.,.F.),IIf(PLSTISSVER() >= "3" ,PLSR420N(3),PLSR470({"2",.F.}))) }
#define  bAtuDiar       {|| aDiarAp := PLSDIARLIB(),Iif(ValType(oSay10)<>'U',oSay10:Refresh(),Nil),Iif(ValType(oSay11)<>'U',oSay11:Refresh(),Nil ) }
#define  bAtuObj 		{|| AtuObj(__aArrObj) }
#define  K_Imprimir	6
#define  K_VisOnline	14
#define  K_Evolucao  	11 // Ao incluir itens no menu, atentar ao numero da chamada para não aterar os MSMGET
#define __aCdCri187 {"573",STR0130}//"Demanda por requerimento"
#define __aCdCri207 {"09V","Paciente ja esta internado"}
#define __aCdCri230 {"987",STR0212}//"Não foi realizada nenhuma comunicação com a operadora do beneficiário"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA092 ³ Autor ³ Tulio Cesar            ³ Data ³ 02.05.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Internacao                                                 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092()
LOCAL aCores    := { ;
	{ 'BE4_STATUS = "1"',aCdCores[1,1] },;
	{ 'BE4_STATUS = "2"',aCdCores[2,1] },;
	{ 'BE4_STATUS = "3"',aCdCores[3,1] },;
	{ 'BE4_STATUS = "4"',aCdCores[4,1] },;
	{ 'BE4_STATUS = "6"',aCdCores[5,1] }} 
LOCAL aPtoEntrada
Local cFiltro
Local cStrFil
Local lVerPtu40    := IF(AllTrim(GETNEWPAR("MV_PTUVEON","35"))=="40",.T.,.F.)
Local lRn395       := GetNewPar("MV_PLRN395","0") == "1"
local cInteracao
Local  aRotConh     := { {STR0170 , "Pls092Bco('C')", 0, 0}, ; //"Guia"
		                 {STR0171 , "Pls092Bco('I')", 0, 0}} // "Item" 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis LOCAL...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina   := { ;
	{ STR0005,'AxPesqui'  ,  0 , K_Pesquisar		},; //"Pesquisar"
	{ STR0006,'PLSA092Mov',  0 , K_Visualizar	},; //"Visualizar"
	{ STR0007,'PLSA092Mov',  0 , K_Incluir		},; //"Incluir"
	{ STR0079,'NAODISP'   ,  0 , K_Alterar		},; //"Nao Disponivel"
	{ STR0009,'PLSA092Mov',  0 , K_Excluir		},; //"Excluir"
	{ STR0010,'PLSA092Ima',  0 , K_Imprimir		},; //"Imprimir GIH."
	{ STR0106,'PLSA092IEv',  0 , K_Imprimir		},; //"Imprimir Evo."
	{ STR0076,'PLSA92DtIn(.F.)',0,K_Incluir	    },; //"Data Internacao"
	{ 'Rastrear','PLSA092RAS',  0,K_Imprimir    },;
	{ STR0182,'PLSA92DtAlt(.F.)',0,K_Incluir	    }} //"Data Alta" }	 //Rastrear

if GetNewPar("MV_PL790NE","0") == "0" .Or. SuperGetMV("MV_PLSSOOL") == "1" 
	AaDd( aRotina,{ STR0082 ,'PLSA092Mov' , 0 , K_Evolucao } ) //"Prorrogação de Internação
endif

If PLSALIASEX("BOZ")
	AaDd( aRotina,{ STR0141 ,'PLSA092VTM' , 0 , K_Incluir } ) //"Visita Profissional"
	AaDd( aRotina,{ STR0142 ,'PLSA092IVM' , 0 , K_Incluir } ) //"Inserir Visita Profissional"
EndIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arotina com opcao para ptu online										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_PLSSOOL","1") == "1"
	AaDd( aRotina,{ STR0075 ,'PLSA092Mov' , 0 , K_VisOnline } )	//"Auto. On-Line"
	AaDd( aRotina,{ "Insistência" ,'PLSA090Ins("BE4")' , 0 , K_Alterar , 0 , Nil} )	//"Insistência"
EndIf

If PLSALIASEX("BOZ")
	AaDd( aRotina,{ STR0141 ,'PLSA092VTM',  0 , K_Incluir }) //"Visita Profissional"
	AaDd( aRotina,{ STR0142 ,'PLSA092IVM',  0 , 1	})       //"Inserir Visita Profissional"
Endif

//Protocolo de Atendimento
If lRn395      
	AaDd( aRotina,{ STR0176 ,'PL90InfPro("BE4")',  0 , K_Alterar }) //"Informar Protoc."
EndIf

If ExistBlock("PLS092M1")
	aPtoEntrada := ExecBlock("PLS092M1",.F.,.F.)
	AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir } )
Endif

If ExistBlock("PLS092M2")
	aPtoEntrada := ExecBlock("PLS092M2",.F.,.F.)
	AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir } )
Endif

If ExistBlock("PLS092M3")
	aPtoEntrada := ExecBlock("PLS092M3",.F.,.F.)
	AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir } )
Endif

cInteracao := "PLSAINTE('BEJ','04', 'BE4->BE4_CODOPE', 'BE4->BE4_ANOINT', 'BE4->BE4_MESINT' , 'BE4->BE4_NUMINT')"	

AaDd( aRotina,{ STR0161	,cInteracao	, 0 , K_Incluir } )                           //"Interação"
AaDd( aRotina,{ STR0058	,aRotConh		, 0 , 0 } )                           //"Connhecimento"
AaDd( aRotina,{ STR0012	,"Plsa092Leg"	, 0 , 0 } )                           //"Legenda"
AaDd( aRotina,{  'Cancelar Internacao','PLSA92MtCan()',0,K_Incluir	    } ) //"Cancelar Internacao"
PRIVATE cCadastro := STR0013 //"Autorizacao de Internacao"

//TISS 2.2 - Requisitos minimos é a existencia da tabela BRI e a existencia da função PLSRETLDP
If ! ( PLSALIASEX("BRI") .And. FindFunction("PLSRETLDP") )
	Final("Necessário atualizar pacote da TISS 2.2 para se utilizar esta funcionalidade.")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltro := "@BE4_FILIAL = '"+xFilial("BE4")+"' AND BE4_TIPGUI='03' AND D_E_L_E_T_ = ' ' "
If FindFunction("PlsRestOp")
	cStrFil := PlsRestOp("I")   // retorna string com filtro para restricao do operador
	If !Empty(cStrFil)
		cFiltro += " And "+cStrFil
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Area																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("BE4")
BE4->(DbSetOrder(2))

If ExistBlock( "PL092FIL" )
	cFiltro := ExecBlock( "PL092FIL", .F., .F., {cFiltro} )
EndIf

//SET FILTER TO &cFiltro
BE4->(MsSeek(xFilial("BE4")))
BE4->(mBrowse(006,001,022,075,"BE4" , , , , , Nil    , aCores, , , ,nil,,,,cFiltro))
DbSelectArea("BE4")
//SET FILTER TO &cFiltro
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA092Mov ³ Autor ³ Tulio Cesar         ³ Data ³ 02.05.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Movimentacao das internacoes                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 16032005 ³      ³DAHER        ³EXCLUSAO DE EVOLUCAO DE GIH            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA092Mov(cAlias,nReg,nOpc,cBenef,cNumProTMK,cRda)
LOCAL nI
LOCAL nJ
LOCAL I__f := 0
LOCAL nL   := 1
LOCAL cChaveAC9 := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis de uso generico...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg
LOCAL nFor
LOCAL nPos
LOCAL oSay
LOCAL nOpcA      := 0
LOCAL aCampos    := {}
LOCAL aArea		 := {}
LOCAL lInterProt := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Uso na enchoiceBar...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aButtons   := {}
LOCAL aRetorno   := {}
LOCAL aMatCom	 := {}
LOCAL bOK        := {|| nOpca := 1,If(PLSA092VLD(aRetorno,oBrwPro,oBrwCri,oEncInt,nOpc,dDatInt,oBrwBQV,oBrwBQZ,lEvolucao,cMultSen,lNMudFase,aDadB43,aCabB43,aTrbB43,aMatCom,oGetBZC,@cTrolComun),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.),Iif(FindFunction("PLSLIMSTA"),PLSLIMSTA(),NIL) }
LOCAL bCancel    := {|| Iif( !lEvolucao .And. BQV->( FieldPos("BQV_OLNAUD") ) > 0 .And. Type("BE4_COMUNI") == "C" .And. Type("BE4_MSG04") == "C" .And. Type("BE4_NRTROL") == "C" .And. Type("BE4_VIACAR") == "N" .And. M->BE4_COMUNI == "1" .And. GetNewPar("MV_PTGLOBO","1") == "1",;
	If( PLSASOEEXE("BE4",lConf,.F.,,,,,IIF((nOPC <> 2 .And. Type("BE4_CANCEL") == "C" .And. M->BE4_CANCEL <> "1"),PLSCANCCOM(),"")), oDlg:End() , .F. ) , oDlg:End() ),Iif(FindFunction("PLSLIMSTA"),PLSLIMSTA(),NIL) }
LOCAL aPosObj    := {}
LOCAL aObjects   := {}
LOCAL aSize      := {}
LOCAL aInfo      := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados da gravacao dos itens...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cFieldBEA
LOCAL cCodOpe
LOCAL oDlgSay
LOCAL nLinSoma
LOCAL cStatus    := ""
LOCAL cChave
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fonte...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oFontAutor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados dos itens...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aDadPro := {}
LOCAL aCabPro := {}
LOCAL aTrbPro := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados da Evolucao de GIH												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOrdBE4
LOCAL aDadBQV 	:= {}
LOCAL aCabBQV 	:= {}
LOCAL aTrbBQV 	:= {}
LOCAL aDadBQZ   := {}
LOCAL aCabBQZ   := {}
LOCAL aTrbBQZ   := {}
LOCAL aDadB4Q   := {}
LOCAL aCabB4Q   := {}
LOCAL aTrbB4Q   := {}
LOCAL aDadSen	:= {}
LOCAL lDClick	:= .T.
LOCAL dDatAlt	:= BE4->BE4_DTALTA
LOCAL dDatInt	:= BE4->BE4_DATPRO
LOCAL cHorInt	:= BE4->BE4_HORPRO
LOCAL cMultSen  := GetNewPar("MV_PLSMULT","0")
LOCAL nDiasInt 	:= Iif(nOpc==K_Incluir,0,PLSDIASINT())
LOCAL lValidVis := .T.
LOCAL lEmptyProt:= .F.
LOCAL lRn395    := GetNewPar("MV_PLRN395","0") == "1"
LOCAL aDadUsr   := {}
LOCAL aAreaBEA  := {}
LOCAL lRPCProtoc:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados das criticas relacionadas aos eventos...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aDadCri  := {}
LOCAL aCabCri  := {}
LOCAL aTrbCri  := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vetor com dados genericos...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aRetAux  		:= {}
LOCAL lAuditoria 	:= .F.
LOCAL lNMudFase 	:= .F.
LOCAL nOpcao    	:= nOpc
LOCAL aProcAbert	:= {}
LOCAL cCampos		:= ""
LOCAL nPosStatus	:= 0
LOCAL lExibeSenha	:=.T.
LOCAL cTrolComun    := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Privadas																					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aMatCBkp
PRIVATE oSay10
PRIVATE oSay11
PRIVATE lComunica  	:= .T.
PRIVATE lBtnOn     	:= .F.
PRIVATE lConf 		:= .T.
PRIVATE lEvolucao 	:= .F.
PRIVATE lDBrw     	:= .F.
PRIVATE aDiarAp		:= {0,0}
PRIVATE cCadastro   := STR0013 //"Autorizacao de Internacao"
PRIVATE lAudEvo		:= .F.
PRIVATE cNumProto   := Space(20)
PRIVATE oGetBZC     := NIL

Default cBenef := ""
Default cNumProTMK := ""
Default cRda := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Nao retirar este tratamento ate o problema da STATIC ser resolvido
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oBrwPro	:= NIL
oBrwBQV	:= NIL
oBrwBQZ	:= NIL
oBrwCri	:= NIL
oBrwB4Q	:= NIL
oEncInt	:= NIL

aDadB43    := {}
aCabB43    := {}
aTrbB43    := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a tabela BQZ ja existe															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !PLSALIASEX("BQZ")
	 Aviso(	STR0096,; 				//"Atencao"
	 	 	STR0103 + "BQZ",; 		//"Tabela nao existe no SX2 -> "
	 	 	{ STR0099 }, 2 ) 		//"ok"
     Return
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ja foi definido um numero de protocolo no atendimento call center				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cNumProTMK)
	cNumProto := cNumProTMK
EndIf

AjustaHELP()
If BE4->BE4_SITUAC == '2' .And. !(nOpc == 2 .Or. nOpc == 5 .Or. nOpc == 3)
	Help("",1,"PLSA092CAN")
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se e guia solicitada pelo Ptu Online							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Excluir
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for online nao deixa cancelar por aqui								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BE4->( FieldPos("BE4_NRTROL") ) > 0 .and. BE4->( FieldPos("BE4_NRAOPE") ) > 0 .and. !Empty(BE4->BE4_NRTROL) .and. Empty(BE4->BE4_NRAOPE) .And. BE4->BE4_CODEMP <> GetNewPar("MV_PLSGEIN","0050")
		MsgInfo(STR0135) //"Guia On-Line, não e possível fazer este tipo de cancelamento!"
		Return
	EndIf
EndIf

//Se existe complemento pendente nao permite a exclusao                                 
If nOpc == K_Excluir .And. BE4->BE4_COMUNI == "1" 
    
    DbSelectArea("BQV")
    
    BQV->(DbSetOrder(1))//BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
    
    If BQV->( DbSeek( xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) )
    
    	If BQV->BQV_COMUNI == "1" .And. ! Empty(BE4->BE4_NRTROL) 
	        msgAlert(STR0205)//"Não é possível cancelar a Guia, pois existem complementos pendentes"
    	    Return
    	EndIf
    	    
    EndIf
    
EndIf

//Se existe complemento pendente nao permite a exclusao                                 
If nOpc == K_Excluir .And. BE4->BE4_COMUNI == "1" 
    DbSelectArea("BQV")
    DbSetOrder(1)//BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
    If BQV->(DbSeek(xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
    	If BQV->BQV_COMUNI =="1" .And. !Empty(BE4->BE4_NRTROL) 
	        Alert(STR0205)//"Não é possível cancelar a Guia, pois existem complementos pendentes"
    	    Return
    	EndIf    
    EndIf
EndIf

If nOpc == K_Excluir

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao excluir guias que ja tenham data de internacao definida...	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !empty(BE4->BE4_DATPRO) .And. !empty(BE4->BE4_HORPRO) .and. BE4->BE4_COMUNI != "1"
		MsgInfo(STR0160) //"Data de internação informada. Guia não pode ser excluída."
		Return
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guias que estao em analise pela auditoria nao podem ser excluidas  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !PLSA092VL2("BE4")
		Return
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mudar o nOpc da funcao PLSA092Mov para visual (erro Array out Of Bound no DuploClick do Brows  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_VisOnline
	nOpc      := K_Alterar
	lBtnOn	  := .T.
	lNMudFase := lBtnOn
	
	BQV->(DbSetOrder(1))//BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
	If BQV->(DbSeek(xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ))
		While xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) == xFilial("BQV")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) .And. !BQV->(Eof())
			If BQV->BQV_COMUNI == "0"
				lEvolucao := .t.
				Exit
			EndIf
			BQV->(DbSkip())
		EndDo
	EndIf 
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for informar data de internacao,Prorrogacao ou Evolucao da GIH    	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Evolucao
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o protocolo de atendimento foi gerado/informado	 		     ³       
	//³ Nao verifico se nao for guia remote ou guia de intercambio     	     	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRn395 .And. Dtos(BE4->BE4_DATPRO) >= '20160515'
	
		aDadUsr := PLSDADUSR(BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO),"1",.F.,dDataBase)
		
		aAreaBEA := BEA->(GetArea())
		BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
		If BEA->( MsSeek( xFilial("BEA") + BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) ) .And. BEA->BEA_TPGRV <> "1"
	    	lRPCProtoc := .T.
	    EndIf
		RestArea(aAreaBEA)    
		
		If aDadUsr[45] == PlsIntPad() .And. !lRPCProtoc 
			If Empty(BE4->BE4_PROATE) 
				lEmptyProt := .T.
			Else	
				BQV->(DbSetOrder(1))//BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
				If BQV->(DbSeek(xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ))
					While xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) == xFilial("BQV")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) .And. !BQV->(Eof())
						If Empty(BQV->BQV_PROATE)
							lEmptyProt := .T.
							Exit
						EndIf
						BQV->(DbSkip())
					EndDo
				EndIf                
			EndIf 
		EndIf	
	EndIf
		
	If lEmptyProt == .T. 
		Aviso( STR0120,STR0177,{ STR0099 }, 2 ) //"Atencao" //"É necessário informar os protocolos pendentes antes de realizar a evolução do atendimento." //"Ok"
 		Return
 	EndIf	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica se vai poder alterar											³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BE4->BE4_STATUS == "3"
		Aviso( STR0096, STR0100 , {  STR0099  }, 2 ) //"A guia nao foi autorizada."
		Return
	EndIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica se tem data de internacao										³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(dDatInt)
		Aviso(STR0096,STR0097,{ STR0099 },2) //"Atenção"###"Data de internação nao informada!"###"OK"
		Return
	EndIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica se foi dado alta												³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAvsPrg := .F.
	If BAU->(FieldPos("BAU_GRALAU")) > 0

		BAU->(dbSetOrder(1))
		If BAU->(msSeek(xFilial("BAU")+BE4->BE4_CODRDA)) .And. BAU->BAU_GRALAU <> "1" .And. !Empty(dDatAlt)
			lAvsPrg := .T.
		EndIf

	ElseIf !Empty(dDatAlt)
		lAvsPrg := .T.
	EndIf
   
	If lAvsPrg .and. GetNewPar("MV_PLLBALT",.F.) // Parametro que define que mesmo com a data de alta poderá ser feito a inclusão de evolução no periodo.
		lAvsPrg := .F.
	Endif
	

	If lAvsPrg
		Aviso( STR0096, STR0098, { STR0099 }, 2 ) //"Atenção"###"Data da alta já informada, somente disponível para visualização!"###"Ok"
		nOpc    := K_Visualizar
		lDClick := .F.
	Else
		nOpc := K_Alterar
	EndIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ verifica se e online														³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BE4->( FieldPos("BE4_NRTROL") ) > 0 .And. BE4->( FieldPos("BE4_NRAOPE") ) > 0 .And. !Empty(BE4->BE4_NRTROL) .And. BE4->BE4_OPESOL <> PlsIntPad()
		Aviso( STR0096, STR0111, { STR0099 }, 2 ) //"Atenção"###"Guia On-Line, somente disponível para visualização!" ###"Ok"
		nOpc    := K_Visualizar
		lDClick := .F.
	EndIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Evolucao																	³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	lEvolucao := .T.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se ja esta concluido nao deixa acessar														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("BE4_TRACON") == "C" .And. BE4->BE4_COMUNI == "1" .And. !lEvolucao .And. lBtnOn //BE4->BE4_TRACON == "1"
	Aviso( STR0096, ; //"Atencao"
		STR0105,; //"Transacao concluida nao e possivel fazer solicitacao on-line!"
		{ STR0099	 }, 2 )//"Ok"
	Return
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para desabilitar a edicao do brw BEJ Itens								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lBtnOn .Or. lEvolucao .Or. nOpc == K_Visualizar
	lDBrw := .T.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fontes utilizadas somente nesta funcao...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-016 BOLD

If nOpc == K_Excluir .And. PLSVERCCBG(BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG),BE4->BE4_ANOPAG,BE4->BE4_MESPAG,BE4->BE4_SEQPF)
	Aviso(STR0014,STR0015,{ STR0099 },2) //"Guia Cobrada"###"Ja gerada a cobranca de custo operacional/co-participacao portanto nao podera ser excluida"
	Return
Endif

If nOpc == K_Excluir .And. BE4->BE4_FASE == "4"
	Aviso(STR0016,STR0017,{ STR0099 },2)    //"Guia Paga"###"Guia ja paga portanto nao podera ser excluida"
	Return
Endif

If nOpc == K_Excluir

	lAvsAlt := .F. //Aviso de alta

	If BAU->(FieldPos("BAU_GRALAU")) > 0

		BAU->(dbSetOrder(1))
		//Nao tem alta automatica para a RDA, nao deixo excluir com alta preenchida
		If BAU->(msSeek(xFilial("BAU")+BE4->BE4_CODRDA)) .And. BAU->BAU_GRALAU <> "1" .And. !Empty(BE4->BE4_DTALTA)
			lAvsAlt := .T.
		EndIf

	ElseIf !Empty(BE4->BE4_DTALTA)

		lAvsAlt := .T.

	EndIf

	If lAvsAlt
		Aviso(STR0059,STR0060,{ STR0099 },2)    //"Guia Paga"###"Guia ja paga portanto nao podera ser excluida"
		Return
	Endif

EndIf

If nOpc == K_Excluir .And. ExistBlock("PLS092EX") .And. ! ExecBlock("PLS092EX",.F.,.F.)
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados da enchoice...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Abre a tabela															³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("BEL") == 0
		aArea := GetArea()
		DbSelectArea("BEL")
		RestArea(aArea)
	EndIf

	Store Header "BEL" TO aCabCri For .T.
	Store COLS Blank "BEL" TO aDadCri FROM aCabCri

	Copy "BE4" To Memory Blank

	aRetAux := PLSXVLDCAL(dDataBase,PLSINTPAD(),.T.,"","")

	If ! aRetAux[1]
		Return
	Else
		M->BE4_ANOPAG := aRetAux[4]
		M->BE4_MESPAG := aRetAux[5]
	Endif

	If Valtype(cBenef) == "C" .and. !Empty(cBenef)

		SX3->(DbSetOrder(2))
		SX3->(MsSeek("BE4_USUARI"))

		M->BE4_USUARI := cBenef
		If Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .And. Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }"))
			RunTrigger(1)
		Endif

		If ExistTrigger('BE4_USUARI')
			RunTrigger(1,nil,nil,,'BE4_USUARI')
		Endif

	EndIf
	
	If FunName() == "TMKA271" .And. lRn395 .And. !Empty(cNumProto)
 			M->BE4_PROATE := cNumProto
      	EndIf
	
	If  Valtype(cRda) == "C" .and. !Empty(cRda)

	    SX3->(DbSetOrder(2))
	    SX3->(MsSeek("BE4_CODRDA"))

	    M->BE4_CODRDA := cRda
	    If Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .And. Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }"))
		       RunTrigger(1)
		 EndIf
		 
		 If ExistTrigger('BE4_CODRDA')
			RunTrigger(1,nil,nil,,'BE4_CODRDA')
		Endif

	EndIf

	If PLSALIASEXI("B43")
		Store Header "B43" TO aCabB43 For ( alltrim(SX3->X3_CAMPO) $ PRetHeaPac() )
		Store COLS Blank "B43" TO aDadB43 FROM aCabB43
	Endif
Else
	Copy "BE4" To Memory

	If nOpc == K_Visualizar .Or. nOpc == K_Excluir .Or. lEvolucao
		lValidVis := .F.
	Endif

	PLSA090USR(BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO),If(!Empty(BE4->BE4_DATPRO),BE4->BE4_DATPRO,dDataBase),BE4->BE4_HORPRO,"BE4",.F.,;
		.F.,.F.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,lValidVis,Iif(nOpc == K_Incluir,.T.,.F.))

	If nOpc <> K_Visualizar .And. nOpc <> K_Excluir
		PLSA090RDA(BE4->BE4_OPERDA,BE4->BE4_CODRDA,"1",If(!Empty(BE4->BE4_DATPRO),;
			BE4->BE4_DATPRO,dDataBase),BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG),;
			BE4->(BE4_CODLOC+BE4_LOCAL),BE4->BE4_CODESP,"BE4",.F.)
	Endif

 	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Valida calendario pagto...                                               ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetAux := PLS746CAL(BEA->BEA_OPEMOV,BEA->BEA_ANOPAG,BEA->BEA_MESPAG)

	BDS->(DbSetOrder(1))
	If BDS->(MsSeek(xFilial("BDS")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+"3")))
		While ! BDS->(Eof()) .And. BDS->(BDS_FILIAL+BDS_OPEMOV+BDS_ANOAUT+BDS_MESAUT+BDS_NUMAUT+BDS_ORIGEM) == ;
				xFilial("BDS")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+"3")

			aadd(aAutFor,{.F.,BDS->BDS_CODPAD,BDS->BDS_CODPRO,BDS->BDS_OPEMOV,BDS->BDS_ANOAUT,BDS->BDS_MESAUT,;
				BDS->BDS_NUMAUT,BDS->(Recno()),BDS->BDS_OPESIS,BDS->BDS_DATA,BDS->BDS_HORA,,,Iif( BDS->(FieldPos("BDS_SEQUEN")) > 0,BDS->BDS_SEQUEN,"001")})
			BDS->(DbSkip())
		Enddo
	Endif

	If PLSALIASEXI("B43")
		Store Header "B43" TO aCabB43 For ( alltrim(SX3->X3_CAMPO) $ PRetHeaPac() )

		cChave := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)//BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)


		B43->(DbSetOrder(2))
		If !B43->( MsSeek( xFilial("B43")+cChave ) )
			Store COLS "B43" TO aDadB43 FROM aCabB43 VETTRAB aTrbB43 While B43->(B43_FILIAL+B43_OPEMOV+B43_ANOAUT+B43_MESAUT+B43_NUMAUT) == xFilial("B43")+cChave    //xFilial("B43")+cChave == B43->(B43_FILIAL+B43_OPEMOV+B43_ANOAUT+B43_MESAUT+B43_NUMAUT)
		Else
			Store COLS Blank "B43" TO aDadB43 FROM aCabB43
		Endif
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os campos que serao exibidos para o caso de aut. internacao...     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCampos := "BE4_FILIAL,BE4_CODOPE,BE4_DTALTA,BE4_HRALTA,BE4_TIPALT,BE4_DESALT,"
cCampos += "BE4_CIDREA,BE4_DESREA,BE4_TIPPAR,BE4_DSTPAR,BE4_TIPNAS,BE4_DSTNAS,"
cCampos += "BE4_DATPRO,BE4_HORPRO,BE4_DTINCR,BE4_HRINCR,BE4_DTFICR,BE4_HRFICR,"
cCampos += "BE4_PODRFS,BE4_INSIST,BE4_NASVIV,BE4_GRAUPA,BE4_GUIORI,BE4_LIBERA"
cCampos += "BE4_NASMOR,BE4_NASVPR,BE4_OBTPRE,BE4_OBTTAR,BE4_OBTMUL,BE4_NRDCNV,BE4_CIDOBT,BE4_NRDCOB"
cCampos += "BE4_EMGEST,BE4_ABORTO,BE4_TRAGRA,BE4_COMURP,BE4_ATESPA,BE4_COMNAL,BE4_BAIPES,BE4_PARCES,BE4_PATNOR,BE4_TIPFAT,BE4_GUIINT"

If ExistBlock("PLS092CP")
	cCampos += ExecBlock("PLS092CP",.F.,.F.,{cCampos})
Endif

STORE FIELD "BE4" TO aCampos For !(SX3->X3_CAMPO $ cCampos)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os itens da autorizacao de internacao...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BEJ" TO aCabPro For .T.

If nOpc == K_Incluir
	Store COLS Blank "BEJ" TO aDadPro FROM aCabPro
Else

	cChave := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

	BEJ->( DbSetOrder(1) )
	If ! BEJ->( MsSeek( xFilial("BEJ")+cChave ) )
		Store COLS Blank "BEJ" TO aDadPro FROM aCabPro
	Else
		Store COLS "BEJ" TO aDadPro FROM aCabPro VETTRAB aTrbPro While xFilial("BEJ")+cChave == BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT)
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta as criticas relacionadas ao procedimento...                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BEL" TO aCabCri For .T.

If nOpc == K_Incluir
	Store COLS Blank "BEL" TO aDadCri FROM aCabCri
Else

	cChave := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

	BEL->( DbSetOrder(1) )

	If ! BEL->( MsSeek( xFilial("BEL")+cChave ) )
		Store COLS Blank "BEL" TO aDadCri FROM aCabCri
	Else
		Store COLS "BEL" TO aDadCri FROM aCabCri VETTRAB aTrbCri While xFilial("BEL")+cChave == BEL->(BEL_FILIAL+BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT)
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta EVOLUCAO															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Itens																	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Store Header "BQV" TO aCabBQV For .T.

	cChave := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

	BQV->(DbSetOrder(1))
	If !BQV->( MsSeek( xFilial("BQV")+cChave ) )
		Store COLS Blank "BQV" TO aDadBQV FROM aCabBQV
	Else
		Store COLS "BQV" TO aDadBQV FROM aCabBQV VETTRAB aTrbBQV While xFilial("BQV")+cChave == BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT)

	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criticas																 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Store Header "BQZ" TO aCabBQZ For .T.

	cChave := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

	BQZ->( DbSetOrder(1) )
	If !BQZ->( MsSeek( xFilial("BQZ")+cChave ) )
		Store COLS Blank "BQZ" TO aDadBQZ FROM aCabBQZ
	Else
		Store COLS "BQZ" TO aDadBQZ FROM aCabBQZ VETTRAB aTrbBQZ While xFilial("BE4")+cChave == BQZ->(BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT)
	Endif
	
	if PLSALIASEX("B4Q")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		// Guias de prorrogação B4Q															
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		Store Header "B4Q" TO aCabB4Q For .T.
	
		cChave := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
			
		B4Q->(DbSetOrder(4))
		If !B4Q->( MsSeek( xFilial("B4Q")+cChave ) ) //B4Q_FILIAL+B4Q_GUIREF
			Store COLS Blank "B4Q" TO aDadB4Q FROM aCabB4Q
		Else	
			Store COLS "B4Q" TO aDadB4Q FROM aCabB4Q VETTRAB aTrbB4Q While xFilial("B4Q")+cChave == B4Q->(B4Q_FILIAL+B4Q_GUIREF)	
		Endif
		
	endIf
	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Dialog...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
AAdd( aObjects, { 001, Iif(nOpc == K_Incluir,000,026), .T., .F.,.F. } )
AAdd( aObjects, { 001, 000, .T., .T.,.F. } )
AAdd( aObjects, { 001, 100, .T., .F.,.T. } )
AAdd( aObjects, { 001, 025, .T., .F.,.F. } )

aInfo 	:= { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects )

aPosObj[1][2]+=15
aPosObj[2][2]+=15
aPosObj[3][2]+=15
aPosObj[3][3]-=15
aPosObj[1][1]-=02
aPosObj[2][1]-=03
aPosObj[3][1]+=25
aPosObj[2][3]+=25

cCadastro += " - "+AllTrim(aRotina[nOpc,1]) //Ajuste para mostrar a opção correta alem da descrição da tela.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dialog...	                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Enchoice...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEncInt := BE4->(MSMGET():New("BE4",BE4->(Recno()),nOpc,,,,aCampos,aPosObj[2],aCampos,,,,,oDlg,,,.F.,,,If(IsInCallStack("PLSAGHI"),.T.,.F.)))     // no caso .t. o sistema deixa montar uma enchoice em cima de outra
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe say...                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If VerSis() >= 8
	nLinSoma := 15
	oDlgSay  := oDlg
Else
	nLinSoma := 0
	oDlgSay  := oEncInt:oBox
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe Label.                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir .Or. ! Empty(M->BE4_SENHA)
	@ aPosObj[1,1], aPosObj[1,2] GROUP oGrupo TO aPosObj[1,3], aPosObj[1,4] PIXEL OF oDlg LABEL " "+STR0104+" "  COLOR CLR_HBLUE, CLR_HRED //"Informacoes"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe say.                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir
	@ aPosObj[1,1]+6,aPosObj[1,2]+5  Say oSay PROMPT STR0018  SIZE 220,010 OF oDlg PIXEL FONT oFontAutor //"Internado em : "
	@ aPosObj[1,1]+6,aPosObj[1,2]+88 Say oSay PROMPT M->BE4_CODOPE+"."+M->BE4_ANOINT+"."+M->BE4_MESINT+"."+M->BE4_NUMINT  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED FONT oFontAutor
Endif
nPosStatus	:= PLRETPOS("BEJ_STATUS",aCabPro,.F.)
    

If nPosStatus > 0  .and. GetNewPar("MV_PLSTASH",.F.) // Define se exibira a senha para os casos em que não foi liberado nenhum procedimento, caso exista um procedimento liberado a senha sera exibida.
	lExibeSenha	:=.F.
	For nL:=1  to Len(aDadPro)
		If aDadPro[nL, nPosStatus] == "1"
			lExibeSenha	:=.T.
			Exit
		Endif
	Next nL
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe say.                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(M->BE4_SENHA) .AND. lExibeSenha
	@ aPosObj[1,1]+6,aPosObj[1,2]+200  Say oSay PROMPT STR0019  SIZE 220,010 OF oDlg PIXEL FONT oFontAutor //"Senha "
	@ aPosObj[1,1]+6,aPosObj[1,2]+233 Say oSay PROMPT M->BE4_SENHA  SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED FONT oFontAutor
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder 			:= TFolder():New(aPosObj[3,1],aPosObj[3,2],Iif(nOpc==K_Incluir,{STR0020,STR0021},{STR0020,STR0021,STR0082,STR0021,"Guias de prorrogação"}),Iif(nOpc==K_Incluir,{"",""},{"","","","",""}),oDlg,,,,.T.,.F.,aPosObj[3,3],aPosObj[3,4]) //"Eventos"###"Criticas"###"Evolucao"###"Criticas"###"Guias de prorrogação"
oFolder:bChange 	:= {|nFolder| Iif(nOpc<>K_Incluir,Eval( {||oBrwBQV:oBrowse:oBrowse:nAt := nL,PLSA092SEQ(1),oBrwBQV:oBrowse:oBrowse:Refresh(),oBrwBQZ:ForceRefresh(oBrwBQV),P092SEQCRI(1) } ) ,Nil ),oBrwCri:ForceRefresh(oBrwPro),P092SEQCRI(0)}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta itens...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AaDd(aProcAbert,{"BMPVISUAL",{|| P090Pacote("BEJ",aDadB43,aCabB43,aTrbB43)},STR0115,STR0116})//"Itens contidos no pacote","Pacote"

If FindFunction("PLSNEGCOM")
	AaDd(aProcAbert,{"NCO",{|| aMatCom := PLSNEGCOM(M->BEJ_SEQUEN,M->BEJ_CODPAD,M->BEJ_CODPRO,M->BEJ_STATUS,M->BE4_DATPRO,,,,M->BE4_CODRDA,M->BE4_CODESP,M->BE4_CODLOC,M->BE4_USUARI) },STR0125,STR0126}) //"Composição do procedimento" "Negar Comp."
EndIf

oBrwPro 			:= TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[01],nil,Iif(lDBrw .And. lDClick,{|| .F.},NIL),nil,nil,nil,.T.,nil,.T.,nil,aCabPro,aDadPro,.F.,"BEJ",nOpc,STR0022,nil,nil,nil,aTrbPro,Nil,'PlsNDelAt(!lDBrw,0)' ,nil,{|a,b,c| PLSA092COR(a,b,c,0) },aProcAbert,bAtuDiar,{||PLSCANCEL(0),Iif(oBrwPro:nOpcX==K_Incluir .And. FindFunction("PLSLIMSTA"),PLSLIMSTA(M->BEJ_SEQUEN+M->BEJ_CODPAD+M->BEJ_CODPRO),nil) }) //"Eventos da Autorizacao"
oBrwPro:bLostFocus 	:= {|| P092SEQCRI(0),lRefresh := .T. }
oBrwPro:bChange		:= {|| Eval(oBrwPro:bLostFocus), oBrwCri:ForceRefresh(oBrwPro) }
oBrwPro:cVldLine   	:= "PLS092VDC() .And. P092DUPADD('oBrwPro','BEJ')"

//Roberto - Adicionando itens na gride de seleção.
oBrwPro:bAfterAdd	:= {|| PLSADDPCT("BEJ", oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BEJ_CODPRO",oBrwPro:aHeader)], ;
	oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BEJ_PROPCT",oBrwPro:aHeader)], ;
	oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BEJ_QTDSOL",oBrwPro:aHeader)], ;
	oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BEJ_QTDPRO",oBrwPro:aHeader)], ;
	oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BEJ_NIVAUT",oBrwPro:aHeader)], ;
	oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BEJ_NIVCRI",oBrwPro:aHeader)], ;
	oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BEJ_STATUS",oBrwPro:aHeader)], ;
	oBrwPro:acols[oBrwPro:obrowse:nAt][PLRETPOS("BEJ_SEQUEN",oBrwPro:aHeader)], oBrwPro ) }

oBrwPro:lAddLine 	:= !lDBrw

If nOpc <> K_Incluir
	oBrwPro:oBrowse:lUpdate:= .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Criticas                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter         	:= {|nLine,aCols,aHeader| aCols[nLine,PLRETPOS("BEL_SEQUEN",aHeader)] == oBrwPro:FieldGet("BEJ_SEQUEN") }
oBrwCri 			:= TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[02],nil,,nil,nil,nil,.T.,nil,.T.,nil,aCabCri,aDadCri,.F.,"BEL",K_Visualizar,STR0023,nil,nil,nil,aTrbCri,,,bFilter) //"Criticas da Autorizacao"
oBrwCri:oPai    	:= oBrwPro
oBrwCri:aOrigem 	:= {"BEJ_SEQUEN"}
oBrwCri:aRelac  	:= {"BEL_SEQUEN"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Evolucao																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir
	aProcAbert := {}
	AaDd(aProcAbert,{"BMPVISUAL",{|| P090Pacote("BQV",aDadB43,aCabB43,aTrbB43)},STR0115,STR0116})//"Itens contidos no pacote","Pacote"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atencao existe um tratamento para essa opcao de menu logo abaixo		 ³
	//³ se precisar mudar a ordem o tratamento no bBeforeAdd e bBeforeEdit 		 ³
	//³ devem ser alterados														 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("PLSNEGCOM")
		AaDd(aProcAbert,{ "NCO",{|| aMatCom := PLSNEGCOM(M->BQV_SEQUEN,M->BQV_CODPAD,M->BQV_CODPRO,M->BQV_STATUS,M->BE4_DATPRO,oBrwBQV:nOpcX,BE4->(BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)+M->BQV_SEQUEN,,M->BE4_CODRDA,M->BE4_CODESP,M->BE4_CODLOC ) },STR0125,STR0126 } ) //Negar Comp.
	EndIf
	oBrwBQV 			:= TPLSBrw():New(2, 2, aPosObj[3,3]-6, aPosObj[3,4]-15, nil, oFolder:aDialogs[03], nil, Iif( !lEvolucao,{|| .F. },{|| PLSCHKIMP(dDatAlt) } ) ,nil, nil, nil, .T., nil, .T., nil, aCabBQV, aDadBQV, .F., "BQV", nOpc, STR0082, nil, nil, nil, aTrbBQV, ,'PlsNDelAt(lEvolucao,1)', Nil, {|a,b,c| PLSA092COR(a,b,c,1) }, aProcAbert, bAtuDiar, {|| PLSCANCEL(1),Iif(oBrwBQV:nOpcX==K_Incluir .And. FindFunction("PLSLIMSTA"),PLSLIMSTA(M->BQV_SEQUEN+M->BQV_CODPAD+M->BQV_CODPRO),nil) } ) //"Evolução de GIH"
	oBrwBQV:bLostFocus 	:= {|| P092SEQCRI(1), lRefresh := .T. }
	oBrwBQV:bChange    	:= {|| nL := oBrwBQV:Linha(), Eval(oBrwBQV:bLostFocus), oBrwBQZ:ForceRefresh(oBrwBQV) }
	oBrwBQV:cVldLine   	:= "PLVLDBQVLI() .And. P092DUPADD('oBrwBQV','BQV')"
	oBrwBQV:lAddLine 	:= Iif(nOpc <> K_Visualizar,Iif( BE4->( FieldPos("BE4_NRTROL") ) > 0 .And. BE4->( FieldPos("BE4_NRAOPE") ) > 0 .And. !Empty(BE4->BE4_NRTROL) .And. Empty(BE4->BE4_NRAOPE), .F., lEvolucao),.F.)
	oBrwBQV:bBeforeEdit	:= {|| PLSCHMEN(oBrwBQV) }
	oBrwBQV:bBeforeAdd	:= {|| PLSCHMEN(oBrwBQV,1) }
	oBrwBQV:oBrowse:lUpdate:= .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Criticas da Evolucao                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bFilter            	:= {|nLine,aCols,aHeader| aCols[nLine,PLRETPOS("BQZ_SEQUEN",aHeader)] == oBrwBQV:FieldGet("BQV_SEQUEN") }
	oBrwBQZ 			:= TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[04],nil,,nil,nil,nil,.T.,nil,.T.,nil,aCabBQZ,aDadBQZ,.F.,"BQZ",K_Visualizar,STR0083,nil,nil,nil,aTrbBQZ,,,bFilter) //"Criticas da Evolucao"
	oBrwBQZ:oPai    	:= oBrwBQV
	oBrwBQZ:aOrigem 	:= {"BQV_SEQUEN"}
	oBrwBQZ:aRelac  	:= {"BQZ_SEQUEN"}
	
	if PLSALIASEX("B4Q")
		//BROWSE COM AS GUIAS DE PRORROGAÇÃO NOVAS RELACIONADAS
		oBrwB4Q := TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[05],nil,,nil,nil,nil,.T.,nil,.T.,nil,aCabB4Q,aDadB4Q,.F.,"B4Q",K_Visualizar,"Guias de prorrogação",nil,nil,nil,aTrbB4Q) //"Guias de prorrogação"
		oBrwB4Q:oBrowse:lUpdate:= .F.
	endIf
	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informacoes da Internacao/Evolucao										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EVal(bAtuDiar)

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 //BOLD

If nOpc <> K_Incluir
	@ aPosObj[1,1]+17,aPosObj[1,2]+5 	Say oSay   PROMPT STR0092+DTOC(dDatInt)+" - "+Transform(cHorInt, "@R 99:99")  SIZE 150,010 OF oDlg PIXEL FONT oFont //"Internado em : "
	@ aPosObj[1,1]+17,aPosObj[1,2]+120 Say oSay   PROMPT STR0094+AllTrim(Str(nDiasInt)) SIZE 150,010 OF oDlg PIXEL FONT oFont  //"Dias de Internação : "
	@ aPosObj[1,1]+17,aPosObj[1,2]+220 Say oSay10 PROMPT STR0093+AllTrim(Str(aDiarAp[1])) SIZE 150,010 OF oDlg PIXEL FONT oFont //"Diarias Autorizadas : "
	@ aPosObj[1,1]+17,aPosObj[1,2]+300 Say oSay11 PROMPT STR0108+AllTrim(Str(aDiarAp[2])) SIZE 150,010 OF oDlg PIXEL FONT oFont //"Diarias Prorrogadas : "
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLS181BT",,.T.)
	aButtonUsr := ExecBlock("PLS181BT",.F.,.F.)
	If ValType(aButtonUsr) == "A"
		For nI   := 1  To  Len(aButtonUsr)
			Aadd(aButtons,aClone(aButtonUsr[nI]))
		Next nI
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botoes...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSA092Bot(nOpc,"BE4",oEncInt,{ || M->BE4_USUARI },aButtons,oFolder,oDlg,oBrwPro,oBrwCri,lBtnOn,@cTrolComun)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vai desabilitar todos os campos																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lDBrw
	PLS092RONL(.T.,oEncInt)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna a chave da relacionado a auditoria para a exclusao de registros na B72																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if nOpcao == K_Excluir
	dbSelectArea("B53")
	dbSetOrder(3)
	If dbSeek(xFilial("BE4")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)) // B53_SITUAC, B53_NUMGUI, B53_ORIMOV
		cChave := b53->(B53_ALIMOV+B53_RECMOV)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera/Informa protocolo de atendimento - RN 395                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRn395 .And. nOpc == K_Alterar
	If GETNEWPAR("MV_PLSUNI","1") =="1" .And. BE4->BE4_CODEMP == GetNewPar("MV_PLSGEIN","0050")
   		lInterProt := .T.    
 	EndIf 
 	
 	If lInterProt .And. lBtnOn .And. !Empty(BE4->BE4_PROATE)
 		cNumProto := BE4->BE4_PROATE
 	Else	
 		P773AutInc(IIF(lBtnOn,"BE4","BQV"),@cNumProto,iif(!lBtnOn,@oBrwBQV,NIL),lInterProt,.F.,nil,nil,nil,BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO),.T.)  
 	EndIf
Endif

//Nova prorrogação de internação vinculado a nova auditoria
if nOpc <> K_Incluir
	//Para guias de PTU Online com a nova auditoria ativada, a prorrogacao deve ser realizada no modelo antigo
	if GetNewPar("MV_PLSSOOL","0") == "1" .And. BE4->BE4_CODEMP == GetNewPar("MV_PLSGEIN","0050")
		//Antigo, oculta a quinta aba que está relacionada a nova rotina de prorrogação. 
		oFolder:HidePage(5)
	//Nova auditoria, oculta aba de procedimentos de prorrogação da rotina de prorrogação antiga
	elseif GetNewPar("MV_PL790NE","0") == "1" 
		oFolder:HidePage(3)
		oFolder:HidePage(4)
	else
		//Antigo, oculta a quinta aba que está relacionada a nova rotina de prorrogação. 
		oFolder:HidePage(5)
	endif
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa Dialog...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Habilita para inclusão de procedimentos somente se for evolução e o parâmetro da nova auditoria estiver desativado
if nOpcao = K_Evolucao .and. (GetNewPar("MV_PL790NE","0") == "0" .Or. (GetNewPar("MV_PLSSOOL","0") == "1" .And. BE4->BE4_CODEMP == GetNewPar("MV_PLSGEIN","0050")) )
	oFolder:nOption := 3
	oBrwBQV:oBrowse:lUpdate := .T.
Endif
ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnchoiceBar(oDlg,bOK,{||Eval(bCancel)},.F.,aButtons), oEncInt:SetFocus() })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca retorno contido no aRetorno...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
	If Len(aRetorno) >= 8
		cSenha     := aRetorno[1]
		cCodOpe    := aRetorno[2]
		cAnoInt    := aRetorno[3]
		cMesInt    := aRetorno[4]
		cNumInt    := aRetorno[5]
		cStatus    := aRetorno[6]
		lAuditoria := aRetorno[7]
		aDadSen    := aRetorno[8]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Conclui um protocolo			                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
   	   	If lRn395 .And. !Empty(cNumProto)
			P773AutCon(IIF(nOpc == K_Incluir,"BE4","BQV"),cNumProto,cCodOpe+cAnoInt+cMesInt+cNumInt)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe mensagem informativa...                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEvolucao .And. Len(aDadSen) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibe mensagem informativa...                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			A092Final(cSenha,cCodOpe,cAnoInt,cMesInt,cNumInt,If(lEvolucao,1,0),aDadSen,cMultSen)
		Else
			If	nOpc == K_Incluir .And. cStatus == "1"
				A092Final(cSenha,cCodOpe,cAnoInt,cMesInt,cNumInt,0,aDadSen,cMultSen)
			ElseIf nOpc == K_Incluir .And. lAuditoria
				Aviso( 	STR0024,; //"Auditoria"
					STR0025,; //"Esta guia foi gravada e esta sendo analisada pela auditoria."
					{STR0099},2)
			ElseIf lAudEvo
				Aviso(	STR0024,; //"Auditoria"
					STR0162,; //"Existem itens dessa prorrog. a serem analisados pela auditoria."
					{STR0099},2)
			Endif
			If ExistBlock("PLA092AUD") .AND. (lAudEvo .OR. (nOpc == K_Incluir .And. lAuditoria))
				Execblock("PLA092AUD",.F.,.F.,{(cCodOpe+"."+cAnoInt+"."+cMesInt+"."+cNumInt),BE4->BE4_MATRIC,cSenha})
			Endif
		EndIf

		If nOpc == K_Excluir

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui os registros no banco de conhecimento relacionados com a guia excluida //
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÄÄÄÄ¿
			PLSA092EBC(cCodOpe, cAnoInt, cMesInt, cNumInt)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui os registros da B72 relacionados a auditoria  							 //
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÄÄÄÄ¿
			If !EMPTY(cChave)
				PLS92B72(cChave)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui os registros da visita médica												 //
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÄÄÄÄ¿
			If PLSALIASEX("BOZ")	.AND. PLSALIASEX("BRS")
				dbSelectArea("BOZ")
				Begin Transaction
					BOZ->(DbSetOrder(1))
					While dbSeek(xFilial("BOZ")+cCodOpe+cAnoInt+cMesInt+cNumInt)

						BOZ->(RecLock("BOZ",.F.))
						BOZ->(DbDelete())
						BOZ->(MsUnLock())

						dbSelectArea("BRS")
						BRS->(dbSetOrder(1))
						While dbSeek(xFilial("BRS")+BOZ->(BOZ_CODIGO))
							BRS->(RecLock("BRS",.F.))
							BRS->(DbDelete())
							BRS->(MsUnLock())
						EndDo

						dbSelectArea("BOZ")
						BOZ->(DbSetOrder(1))
					EndDo
				End Transaction
			EndIf

			//Verifica se tem Anexos Vinculados e cancela
			B4A->(DbSetOrder(4))//B4A_FILIAL + B4A_GUIREF
			If B4A->( msSeek( xFilial("B4A")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) )
				While ( !B4A->(EOF()) .and. xFilial("B4A")+B4A->(B4A_GUIREF) == xFilial("BE4")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) )
					PLSA09ACAN(.T.,.F.,,,.F.) //lWeb como true para não surgir o pergunte de cancelamento para cada guia encontrada.
					B4A->(DbSkip())
				EndDo
		EndIf

			//Verifica se tem Guias de Prorrogação Vinculadas
			B4Q->(DbSetOrder(4))//B4A_FILIAL + B4A_GUIREF
			If B4Q->( msSeek(xFilial("B4Q")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)) )
				While ( !B4Q->(EOF()) .and. xFilial("B4Q")+B4Q->(B4Q_GUIREF) == xFilial("BE4")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) )
					PLSA09PCAN(.F.,.F.,,,)
					B4Q->(DbSkip())
				EndDo
		EndIf

		EndIf
	Else
		Aviso( 	STR0096,; //"Atenção"
		STR0102,; //"Inconsistencia na operacao on-line"
			{ STR0099 }, 2 )
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa Sets Keys...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET KEY VK_F5  TO
SET KEY VK_F6  TO
SET KEY VK_F7  TO
SET KEY VK_F8  TO
SET KEY VK_F9  TO
SET KEY VK_F10 TO
SET KEY VK_F11 TO
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA092LEG ³ Autor ³ Tulio Cesar         ³ Data ³ 08.01.02 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe a legenda...                                         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092Leg()
Local aLegenda := { { aCdCores[1,1],aCdCores[1,2] },;
                     { aCdCores[2,1],aCdCores[2,2] },;
                     { aCdCores[3,1],aCdCores[3,2] },;
                     { aCdCores[4,1],aCdCores[4,2] },;
                      { aCdCores[5,1],aCdCores[5,2] }}
BrwLegenda(cCadastro,STR0030 ,aLegenda) //"Status"
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA092VL2 ³ Autor ³ Thiago Guilherme    ³ Data ³ 08.02.13 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Verifica se a guia esta em análise antes da exclusão       ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA092VL2(cAlias)

If PLSALIASEX("B53")
	If B53->(FieldPos("B53_NUMERO")) > 0
		DbSelectArea("B53")
		DbSetOrder(3)

		If !EMPTY(cAlias) .AND. cAlias == "BE4"
			If dbSeek(BE4->(BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV))
				If B53->B53_SITUAC == "2"
					Help("",1,"PL800VLD")
					Return .F.
				EndIf
			EndIf
		ElseIf !EMPTY(cAlias) .AND. cAlias == "BEA"
			If dbSeek(BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV))

				If B53->B53_SITUAC == "2"
					Help("",1,"PL800VLD")
					Return .F.
				EndIf
			EndIf

		ElseIf !EMPTY(cAlias) .AND. cAlias == "B45"
			If dbSeek(B45->(B45_FILIAL+B45_OPEMOV+B45_CODLDP+B45_CODPEG+B45_NUMERO+B45_ORIMOV))

				If B53->B53_SITUAC == "2"
					Help("",1,"PL800VLD")
					Return .F.
				EndIf
			EndIf
		EndIf
	EndIf
Endif
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
±±³Funcao    ³ PLSA092EBC  ³ Autor ³ Thiago Guilherme  ³ Data ³ 08.02.13  ³
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
±±³Descricao ³ Exclui registros no banco de conhecimento relacionados com |
±±³          ³ a guia excluida                                            |
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA092EBC(cCodOpe, cAno, cMes, cNum)
LOCAL 	cChaveAC9 := NIL

		AC9->(DbSetOrder(2))//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ, R_E_C_N_O_, D_E_L_E_T_

		cChaveAC9 := xFilial("AC9")+cCodOpe+cAno+cMes+cNum

		while AC9->(  MsSeek( xFilial("AC9") + "BE2" + "  " + cChaveAC9))
		      AC9->(RecLock("AC9"))
		      AC9->(DbDelete())
		      AC9->(MsUnlock())
		Enddo

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA092BT  ³ Autor ³ Tulio Cesar         ³ Data ³ 08.01.02 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe a legenda...                                         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092BT()
Return({ {"RELATORIO",{|| PLSA093Vis() },STR0031} }) //"Visualizar as Prorrogacoes para esta internacao"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA092EDT ³ Autor ³ Tulio Cesar         ³ Data ³ 08.01.02 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Valida se a internacao pode ser editada...                 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092Edt(aPar)
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA092INI³ Autor ³ Tulio Cesar          ³ Data ³ 30.05.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa dados.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PLSA092INI(aPar)
LOCAL cTipoTran := aPar[3]
LOCAL nColSoma	:= 0
LOCAL cTitulo   := STR0018 //"Internacao Numero   "
LOCAL cNumero   := ''
LOCAL cTitulo2	:= ''
LOCAL cSenSol	:= ''
LOCAL aSize 		:= MsAdvSize()
LOCAL oDlgSay		:= Iif(cTipoTran == "1",aPar[5],NIL)
PRIVATE oSay1
PRIVATE oSay2
PRIVATE oSay3
PRIVATE oSay4

If Type("M->BE4_TIPGUI") == "C" .AND. M->BE4_TIPGUI == "05"
	cTitulo := "Guia de Solicitacao Numero"
	cTitulo2:= "Senha"
	nRecBE4 := BE4->(Recno())
	nOrdBE4 := BE4->(IndexOrd())
	BE4->(DbSetOrder(1))
	If BE4->(MsSeek(xFilial("BE4")+M->BE4_GUIINT))
		cNumero := BE4->BE4_CODOPE+"."+BE4->BE4_ANOINT+"."+BE4->BE4_MESINT+"."+BE4->BE4_NUMINT
		cSenSol := BE4->BE4_SENHA
	Endif
	BE4->(DbGoTo(nRecBE4))
	BE4->(DbSetOrder(nOrdBE4))
	
	//Grava o Recno antes de desposicionar ao acionar a consulta padrao
	IIf(Type("__nRecBE4") <> "U" , __nRecBE4 := BE4->(RecNo()),NIL)
	
ElseIf Type("M->BD5_TIPGUI") == "C" .and. M->BD5_TIPGUI == "06"
	cTitulo:= "Honorário Individual Numero  "
Elseif Type("M->BE4_TIPGUI") == "C" .AND. M->BE4_TIPGUI == "03"
	cTitulo2:= "Senha :"
	cNumero := M->BE4_CODOPE+"."+M->BE4_ANOINT+"."+M->BE4_MESINT+"."+M->BE4_NUMINT
	cSenSol := M->BE4_SENHA
Endif

If cTipoTran == "1"
   oBrwBD6:bChange := { || Eval(oBrwBD6:bLostFocus),oBrwBD7:ForceRefresh(oBrwBD6) }
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ GETDADOS -> Parametros Pagamento X Procedimento...                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   oBrwBD7:oPai       := oBrwBD6
   oBrwBD7:aOrigem    := {"BD6_SEQUEN"}
   oBrwBD7:aRelac     := {"BD7_SEQUEN"}
   
   If aSize[4] > 350
		//1280x1024 
		aSize[4] := 323.5
	ElseIf aSize[4] > 350 .And. aSize[4] > 300
		//1440x900
		aSize[4] := 346.5
	ElseIf aSize[4] < 300 .And. aSize[4] > 200
		//1280x800
		aSize[4] := 311.5
	ElseIf aSize[4] < 200
		//800x600
		aSize[4] := 196.5 
	EndIf
	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Exibe say...                                                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !Empty(cNumero)
	   @ 001,aSize[4] - 130 SAY oSay1 PROMPT cTitulo SIZE 220,010 OF oDlgSay PIXEL
	   @ 001,aSize[4] - 60 SAY oSay2 PROMPT cNumero SIZE 220,010 OF oDlgSay PIXEL COLOR CLR_HRED
    Endif
   	If ! Empty(cSenSol)
       @ 001,aSize[4] + 10 SAY oSay3 PROMPT cTitulo2 SIZE 220,010 OF oDlgSay PIXEL
       @ 001,aSize[4] + 30 SAY oSay4 PROMPT cSenSol  SIZE 220,010 OF oDlgSay PIXEL COLOR CLR_HRED
   	Endif
Endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA092SAI³ Autor ³ Tulio Cesar          ³ Data ³ 30.05.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Saida da tela                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PLSA092SAI(aPar)
LOCAL lRet := .T.
LOCAL cTipoGuia := aPar[1]
LOCAL lCanc     := .F.

If Len(aPar) >= 4
   lCanc := aPar[4] == 8 //opcao cancelar
Endif

If ! lCanc
   If M->BE4_TIPINT == "3" .And. ( Empty(M->BE4_TIPPAR) .Or. Empty(M->BE4_TIPNAS) )
      lRet := .F.
      Help("",1,"PLSA092SAI")
   Endif

   If lRet
      If cTipoGuia $ "03#05"
         lRet := PLSVLDDAT(M->BE4_DATPRO,M->BE4_HORPRO,M->BE4_DTALTA,M->BE4_HRALTA)

         If ! lRet
            Aviso( STR0032, STR0033, {  STR0099  }, 2 ) 	 //"Conflito de Datas"###"A Data/Hora de Alta deve ser maior que a Data/Hora de Internacao"
         Endif
      Endif
   Endif
Endif

If lRet
	If cTipoGuia $ "05" .and. Type("oBrwBD6") <> "U" .And. Type("oBrwBD7") <> "U" .and. Type("M->BE4_GUIINT") <> "U" .and. Type("M->BE4_TIPFAT") <> "U"

	    nRecBE4 := BE4->(Recno())
		nOrdBE4 := BE4->(IndexOrd())
		cGuiInt := M->BE4_GUIINT
		cTipFat := M->BE4_TIPFAT
		If cTipFat == 'P' .or. cTipFat == "1"
			BE4->(DbSetOrder(1))
			If BE4->(msSeek(xFilial("BE4")+cGuiInt)) .and.  !Empty(BE4->BE4_DTALTA)
				If MsgYesNo(STR0143)//'Você esta digitando uma GRI com Faturamento Parcial sendo que a solicitação ja encontra-se com data de alta. Deseja continuar mesmo sabendo que a Guia de Solicitação será reaberta? '
					BE4->(RecLock("BE4",.F.))
						BE4->BE4_DTALTA := ctod('')
						BE4->BE4_HRALTA := ''
						BE4->BE4_TIPFAT := ''
						BE4->BE4_TIPALT := ''
					BE4->(MsUnLock())
				Endif
			Endif
	    Endif
	    BE4->(DbSetORder(nOrdBE4))
		BE4->(DbGoto(nRecBE4))
	Endif
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica para nao deixar informar valor apresentado no BD6 e no BD7 ³
	//³ simultaneamente	- Helio 21/12/2006									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If FindFunction("VldVlApr")	.And. Type("oBrwBD6") <> "U" .And. Type("oBrwBD7") <> "U"
			lRet := VldVlApr()
		Else
			Conout(STR0144)//"PLSA720SAI - Por favor atualize o seu fonte PLSMCTMD.PRW"
		Endif
	Endif
Endif

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA092IMA ³ Autor ³ Tulio               ³ Data ³ 04.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao de guias via menu                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA092Ima()

If BE4->BE4_SITUAC == '2'   

	Aviso( STR0163,STR0233,{ STR0099 }, 2 ) //"Não foi possível realizar a operação."   - "Guia de GIH Cancelada. Impressão Indisponível."                                                               
	
	Return
EndIf

Eval(bImpGuia)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA092IEv ³ Autor ³ Alexander           ³ Data ³ 29.11.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Evolucao das Diarias					                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA092IEv()

If BE4->BE4_SITUAC == '2'

	Aviso( STR0163,STR0232,{ STR0099 }, 2 ) //"Não foi possível realizar a operação."   - "Guia de Evolução Cancelada.Impressão Indisponível."

	Return
EndIf

If !ExistBlock("PL092EVO")
	//Posiciona na B4Q para verificar se existe guia de evolução para exibir no Relatorio
	B4Q->(DbSetOrder(4))//B4Q_FILIAL+B4Q_GUIREF
	If !B4Q->(msSeek(xFilial("B4Q")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
		msgAlert(STR0218)//"Não existe Guia de Evolução de Internação para esta Solicitação"
		return
	ElseIf B4Q->B4Q_CANCEL == "1"
		Aviso( STR0106,STR0232,{ STR0099 }, 2 ) //"Imprimir Evol" //"Guia de Evolução Cancelada.Impressão não disponível."//"Ok"
		return
	Endif
EndIf

Eval(bImpGuiaE)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA092TPI ³ Autor ³ Tulio               ³ Data ³ 23.07.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Se a internacao for de Urgencia (parametro) peco a data    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA092TPI()
LOCAL oDlg
LOCAL dDataInt := dDataBase
LOCAL cHoraInt := Subs(StrTran(Time(),":",""),1,4)
LOCAL aButtons := {}
LOCAL nOpca    := 0
LOCAL bOK      := { || IF(!Empty(dDataInt),(nOpca := 1, oDlg:End()),(Help("",1,"PLSA092TPI"))) }
LOCAL bCancel  := { || nOpca := 0, oDlg:End() }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa se o tipo de internacao e urgencia (parametro MV_PLSCDIU)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(M->BE4_TIPADM) $ AllTrim(GetNewPar("MV_PLSCDIU","4,5")) .And. GetNewPar("MV_PLSTDIA","1") == "1"
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Define dialogo...                                                   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   DEFINE MSDIALOG oDlg TITLE STR0034 FROM 009,000 TO 024,070 OF GetWndDefault() //"Informe a Data da Internacao"
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta gets para alimentar a data...                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   @ 025,005 SAY oSay PROMPT STR0035  SIZE 220,010 OF oDlg PIXEL  //"Data da Internacao   "
   @ 024,065 MSGET dDataInt PICTURE "@D" SIZE 040,010 OF oDlg PIXEL
   @ 050,005 SAY oSay PROMPT STR0036  SIZE 220,010 OF oDlg PIXEL  //"Hora da Internacao   "
   @ 048,065 MSGET cHoraInt PICTURE "@R !!:!!" SIZE 040,010 OF oDlg PIXEL
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Ativa o dialogo...                                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Caso seja confirmado atualiza ne enchoice nos respectivos campos    ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If nOpca == K_OK
      M->BE4_DATPRO := dDataInt
      M->BE4_HORPRO := cHoraInt
      lRefresh := .T.
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA092BOT³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta botoes e keys...                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092Bot(nOpc,cAliasEnc,oEncInt,bMatUsr,aButtons,oFolder,oDlg,oBrwPro,oBrwCri,lBtnOn,cTrolComun)

LOCAL lIncBack	:= Inclui
LOCAL bBotao01	:= {|| PLPOSFIN(Eval(bMatUsr),.T.,.T.) }
LOCAL bBotao02	:= {|| PLHISMOV(Eval(bMatUsr)) }
LOCAL bBotao03	:= {|| PLAltCli(Eval(bMatUsr)) }
LOCAL bBotao04	:= {|| BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+M->BE4_USUARI)), If(BA1->(Found()),PLSVLRCOB(,,.T.),Help("",1,"PLSA090USR")) }
LOCAL bBotao05	:= {|| Inclui := .F., BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+M->BE4_USUARI)), If(BA1->(Found()),PLSA260MOV("BA1",BA1->(RECNO()),K_Visualizar),Help("",1,"PLSA090USR")),Inclui := lIncBack }
LOCAL bBotao06	:= {|| BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+M->BE4_USUARI)), If(BA1->(Found()),AxVisual("BA1",BA1->(RECNO()),K_Visualizar),Help("",1,"PLSA090USR")) }
LOCAL bBotao07	:= {|| BA3->(DbSetOrder(1)), BA3->(MsSeek(xFilial("BA3")+Subs(M->BE4_USUARI,1,14))), If(BA3->(Found()),ExeQuest(),Help("",1,"PLSA090QUE")) }
LOCAL bBotao08  := {|| A090Limpa(cAliasEnc,oEncInt,oBrwPro,"BEL",,,.T.),PLS092RONL(.F.,oEncInt)}
LOCAL bBotao09  := {|| PLSMSGCA(Eval(bMatUsr)) }
LOCAL bBotao10  := {|| MSGCOMINT(IIF(Inclui,{},),"2",nOpc,&("M->"+cAliasEnc+"_USUARI"),IIF(Inclui,"","BE4"),BE4->(RecNo()),@oGetBZC) }   
LOCAL bBotao17  	:= {|| PLSA09AMTC(cAliasEnc,oEncInt,oBrwCri,"",oBrwPro,"", BE4->(RECNO()), "BE4", Inclui) }//{|| PLSA092MTC(cAliasEnc,oEncInt,oBrwCri,"",oBrwPro, "", BE4->(RECNO())) }
LOCAL oBotao
LOCAL aPtoEtb1
LOCAL aPtoEtb2
LOCAL cCodCri
LOCAL lRn395    := GetNewPar("MV_PLRN395","0") == "1"   
LOCAL lNovInd   := GETNEWPAR("MV_PLSUNI","0") == "1" .And. PLSALIASEXI("BZC") .And. BZC->(FieldPos("BZC_CHVGUI")) > 0 .And. BZC->(FieldPos("BZC_ALIAS")) > 0 .And.  FindFunction('MSGCOMINT') 
DEFAULT cTrolComun := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir
   AaDd(aButtons,{"S4WB004N",bBotao08,STR0073,STR0074}) //"Limpar Tela - <F5>"###"Limpa"
   SetKey(VK_F5,bBotao08)
Endif

AaDd(aButtons,{"SALARIOS",bBotao01,STR0041,STR0061})  //"Posicao Financeira - <F6>"
SetKey(VK_F6,bBotao01)

AaDd(aButtons,{"RELATORIO",bBotao02,STR0042,STR0062}) //"Historico de Movimentacao - <F7>"
SetKey(VK_F7,bBotao02)

AaDd(aButtons,{"POSCLI",bBotao03,STR0043,STR0063}) //"Alterar Dados do Cliente - <F8>"
SetKey(VK_F8,bBotao03)

AaDd(aButtons,{"PLNPROP",bBotao04,STR0044,STR0064}) //"Composicao de Cobranca - <F9>"
SetKey(VK_F9,bBotao04)

AaDd(aButtons,{"GROUP",bBotao05,STR0045,STR0065}) //"Dados da Familia - <F10>"
SetKey(VK_F10,bBotao05)

AaDd(aButtons,{"RESPONSA",bBotao06,STR0046,STR0066}) //"Dados do Usuario - <F11>"
SetKey(VK_F11,bBotao06)

aAdd(aButtons,{"Negacao",bBotao17,"",STR0157}) //Motivo da negação

AaDd(aButtons,{"S4WB007N",{ || A092INTGER() },STR0047,STR0067}) //"Usuario de Outros Intercambios"

AaDd(aButtons,{"BMPVISUAL",bBotao09,STR0113,STR0114}) //"Grupo de carencia"###"GrupoCa"

If  lNovInd 
	AaDd(aButtons,{"MSGCOMINT",bBotao10,STR0217,STR0217}) //"Msgs PTU"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao Hist Criticas Forcadas											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Visualizar
	aadd(aButtons,{"S4WB010N",{ || PLS090FOR("BE4","BEJ",oBrwPro) },"Hist. Criticas Forçadas","Crit. Forçadas"})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta outros botoes de apoio...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 030,002 BTNBMP oBotao RESOURCE "NOTE" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0048 ACTION PLSRTGCUSR(M->BE4_USUARI) //"Grupos de Cobertura"
@ 065,002 BTNBMP oBotao RESOURCE "RELATORIO" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0049 ACTION Eval(bBotao07) //"Visualizar Entrevista Qualificada do Usuario"
@ 100,002 BTNBMP oBotao RESOURCE "RELATORIO" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0050 ACTION ClasseCarUsr() //"Consultar Classe de Carencia"

nLin := 100
If  FindFunction("PLSC005")
    nLin += 35
    @ nLin,002 BTNBMP oBotao RESOURCE "S4WB016N" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0051 ACTION PLSC005() //"Consultar Cobertura/Carencia"
Endif

If  FindFunction("PL169HIST")
    nLin += 35
    @ nLin,002 BTNBMP oBotao RESOURCE "HISTORIC" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0052 ACTION PL169HIST() //"Historico Transferencia"
Endif

If ExistBlock("PLS092B1")
   aPtoEtb1 := ExecBlock("PLS092B1",.F.,.F.)
   nLin += 35
   @ nLin,002 BTNBMP oBotao RESOURCE aPtoEtb1[1] SIZE 030 ,030 OF oDlg PIXEL MESSAGE aPtoEtb1[2] ACTION Eval(aPtoEtb1[3])
Endif

If ExistBlock("PLS092B2")
   aPtoEtb2 := ExecBlock("PLS092B2",.F.,.F.)
   nLin += 35
   @ nLin,002 BTNBMP oBotao RESOURCE aPtoEtb2[1] SIZE 030 ,030 OF oDlg PIXEL MESSAGE aPtoEtb2[2] ACTION Eval(aPtoEtb2[3])
Endif

If ExistBlock("PLS092B3") .and. nOpc == K_Incluir
   cCodCri := ExecBlock("PLS092B3",.F.,.F.)
   BCT->( DbSetOrder(1) ) 										 //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
   If BCT->( MsSeek( xFilial( 'BCT' )+PLSINTPAD()+cCodCri )  ) // Trocar o 701 pelo codigo da sua critica
	   nLin += 35
	   @ nLin,002 BTNBMP oBotao RESOURCE "AFASTAMENTO" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0053 ACTION PL092CRINE(cCodCri) //"Negar Autorização"
   EndIf
Endif

If Type(cAliasEnc+"_COMUNI") == "C" .And. Type(cAliasEnc+"_MSG04")  == "C" .And.;
   Type(cAliasEnc+"_NRTROL") == "C" .And. Type(cAliasEnc+"_VIACAR") == "N" .And. GetNewPar("MV_PLSSOOL","1") == "1"

	If nOpc == K_Incluir .Or. (lBtnOn .And. !lEvolucao)
		If GetNewPar("MV_PTGLOBO","1") == "1"
			nLin += 35
			@ nLin,002 BTNBMP oBotao RESOURCE "WEB" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0072 ACTION PLSAUTREM(cAliasEnc,"BEJ","BEL",oBrwPro,oBrwCri,nOpc,.T.,.F.,NIL,NIL,@cTrolComun) //"Efetuar conexao autorizador remoto"
		EndIf
		nLin += 35
		@ nLin,002 BTNBMP oBotao RESOURCE "POSCLI" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0133 ACTION PlsUsrPtuA() //"Consulta Dados Beneficiário Online"
		nLin += 35
		@ nLin,002 BTNBMP oBotao RESOURCE "S4WB007N" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0134 ACTION PlsPrePtuA() //"Consulta Dados Prestador Online"

	ElseIf lEvolucao .And. BQV->( FieldPos("BQV_OLNAUD") ) > 0 .And. GetNewPar("MV_PTGLOBO","1") == "1"
		nLin += 35
		@ nLin,002 BTNBMP oBotao RESOURCE "WEB" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0072 ACTION PLSAUTREM(cAliasEnc,"BQV","BQZ",oBrwBQV,oBrwBQZ,nOpc,.F.,.T.,NIL,NIL,@cTrolComun) //"Efetuar conexao autorizador remoto"
	EndIf

EndIf

If SuperGetMv("MV_BIOCONF",,.F.) .AND. SuperGetMv("MV_BIOGIH",,.F.)
	nLin += 35
	@ nLin,002 BTNBMP oBotao RESOURCE "OBJETIVO" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0121 ACTION PL090BIO(cAliasEnc,.F.) //"Biometria"
EndIf

If lRn395 
	If nOpc == K_Visualizar
   		cNumProto := BE4->BE4_PROATE
	EndIf
	nLin += 35
	@ nLin,002 BTNBMP oBotao RESOURCE "USER" SIZE 030 ,030 OF oDlg PIXEL MESSAGE STR0179 ACTION P773AutInc(IIF(nOpc == K_Evolucao,"BQV","BE4"),@cNumProto,iif(nOpc==K_Alterar,oBrwBQV,nil),NIL,.T.,nOpc) //"Protocolo de Atendimento"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA092COR³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Muda a cor do browse de acordo com a autorizacao...        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA092Cor(nLinha,aHeaderEd,aColsEd,nTp)
LOCAL nPos := If(nTp==0,PLRETPOS("BEJ_IMGSTA",aHeaderEd,.F.),PLRETPOS("BQV_IMGSTA",aHeaderEd,.F.))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Autorizacao																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTp == 0
	If nPos > 0
	   aColsEd[nLinha,nPos] := If(M->BEJ_STATUS=="1","ENABLE","DISABLE")
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Bkp do browse criticas													 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMatCBkp := aClone(oBrwCri:aCols)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Evolucao																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	If nPos > 0
	   aColsEd[nLinha,nPos] := If(M->BQV_STATUS=="1","ENABLE","DISABLE")
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Bkp do browse criticas													 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMatCBkp := aClone(oBrwBQZ:aCols)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA092USR³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida usuario                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092Usr()
LOCAL cOpeUsr := Subs(M->BE4_USUARI,atCodOpe[1],atCodOpe[2])
LOCAL cCodEmp := Subs(M->BE4_USUARI,atCodEmp[1],atCodEmp[2])
LOCAL cMatric := Subs(M->BE4_USUARI,atMatric[1],atMatric[2])
LOCAL cTipReg := Subs(M->BE4_USUARI,atTipReg[1],atTipReg[2])
LOCAL dDatPro := Date()
LOCAL lRet    := .T.

LOCAL cSQL := "SELECT R_E_C_N_O_ AS REG FROM "+RetSQLName("BE4")+" WHERE "
      cSQL += "BE4_FILIAL = '"+xFilial("BE4")+"' AND "
      cSQL += "BE4_OPEUSR = '"+cOpeUsr+"' AND "
      cSQL += "BE4_CODEMP = '"+cCodEmp+"' AND "
      cSQL += "BE4_MATRIC = '"+cMatric+"' AND "
      cSQL += "BE4_TIPREG = '"+cTipReg+"' AND "
      cSQL += " ( BE4_DTALTA = '' OR ( BE4_DATPRO >= '"+dtos(dDatPro)+"' AND BE4_DTALTA <= '"+dtos(dDatPro)+"' ) ) AND "
      cSQL += "D_E_L_E_T_ = ''"

      PLSQuery(cSQL,"PLSA090USR")

      If ! PLSA090USR->(Eof())
         Help("",1,"PLSA092USR")
         lRet := .F.
      Endif

      PLSA090USR->(DbCloseArea())

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA092TPA³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida tipo de atendimento                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092TPA()
LOCAL lRet
LOCAL cCodAux := AllTrim(M->BD7_CODUNM)

cCodAux := cCodAux+Space((3-Len(cCodAux)))

BKC->(DbSetOrder(1))
lRet := BKC->(MsSeek(xFilial("BKC")+cCodAux+BCI->BCI_OPERDA+M->BD7_CODTPA))

If ! lRet
   Help("",1,"PLSA092TPA")
Endif

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA092AUT³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do procedimento...                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092Aut(cSequen,cCodPad,cCodPro,nQtdPro,cTipo,cAliasIte,cAliasCab,cAliasCri,nTp,lChkP,lProtRN395)
LOCAL lRet       := .F.
LOCAL nX		 := 1
LOCAL nOrdBA0    := BA0->(IndexOrd())
LOCAL nRecBA0    := BA0->(Recno())
LOCAL nOrdBR8    := BR8->(IndexOrd())
LOCAL nRecBR8    := BR8->(Recno())
LOCAL nPosCodPad := 0
LOCAL nPosCodPro := 0
LOCAL nPosDesPro := 0
LOCAL cCodProLin := ""
LOCAL cCodTab    := ""
LOCAL cCodExe    := ""
LOCAL cRegAte    := "1"
LOCAL cAliasProc := ""
LOCAL lNegProPac := .F. // SE TROCAR PARA .T. IRIA INIBIR A CRITICA 09L PROCEDIMENTO JA EXISTE NO PACOTE
LOCAL aCompo	 := {}
LOCAL aRet		 := {}
LOCAL aAreaBEA	 := BEA->(GetArea())
LOCAL lUnimeds   := IF(AllTrim(GetNewPar("MV_PLSUNI","1"))=="1",.T.,.F.)
LOCAL lProPTUGen := .F.
LOCAL lLembre    := .F.
LOCAL cCodSequen :=	 M->&( cAliasIte+"_SEQUEN" )
LOCAL nL		 := 0
LOCAL nt		 := 0
LOCAL lFirst	 :=.T.
LOCAL aDadUsr     := {}
LOCAL nLimitePTU  := 0
LOCAL nPosNRTROL  := 0
LOCAL nItensPTU   := 0

LOCAL aBkBrwCrit	 := {}//Array(1,Len(oBrwCri:aHeader[1]))
LOCAL lInterProt  := .F.
LOCAL lPTUOn70    := Alltrim(GetNewPar("MV_PTUVEON","35")) >= "70" 
LOCAL lCritRepet  := .F.

DEFAULT nTp      := 0
DEFAULT lChkP	 := .T.
DEFAULT lProtRN395:= .F.

If GetNewPar("MV_PLRN395","0") == "0"
	lProtRN395 := .F.
EndIf
//-------------------------------------------------------------------------
// Prorrogação de internação
//-------------------------------------------------------------------------
If Funname() == "PLSA09P"
	lRet := PLSA09PAUT(cSequen,cCodPad,cCodPro,nQtdPro,cTipo,lChkP,lProtRN395)
Else 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Evolucao da Internacao				                					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Funname() <> "PLSA094A"

    nPosCodPad:= Ascan(oBrwPro:aHeader,{ |x| x[2] == "BEJ_CODPAD"})
    nPosCodPro:= Ascan(oBrwPro:aHeader,{ |x| x[2] == "BEJ_CODPRO"})
    nPosDesPro:= Ascan(oBrwPro:aHeader,{ |x| x[2] == "BEJ_DESPRO"})
    cCodProLin:= Alltrim(oBrwPro:aCols[oBrwPro:OBROWSE:nAt,nPosCodPro])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratmento para exclusão de criticas de procedimentos anteriores  na digitação³
	//³ OBS: O tratamento do Alias BQV foi removido pq nao e possivel trocar o      ³
	//³ procedimento ja digitado neste Alias. Chamado: TID421 - 2013/12/19          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If cAliasIte =="BEJ"
	    If ValType(oBrwCri) = "O"
	    	nPosSeque := Ascan(oBrwCri:aHeader,{ |x| x[2] == "BEL_SEQUEN"})
	    	nPosSeqCri:= Ascan(oBrwCri:aHeader,{ |x| x[2] == "BEL_SEQCRI"})

	    	For nL:=1 to Len(oBrwCri:oBrowse:ACOLS)
				If oBrwCri:oBrowse:ACOLS[nL,nPosSeque]<> cCodSequen
					Aadd(aBkBrwCrit,oBrwCri:oBrowse:ACOLS[nL])
	    	    Endif

	    	Next nL

	       	If Len(aBkBrwCrit) > 0
		    	oBrwCri:ACOLS	:= Aclone(aBkBrwCrit)
		    ElseIf Len(aBkBrwCrit) == 0 .And. Funname() <> "PLSA092"
		    	aBkBrwCrit	    := Array(1,(Len(oBrwCri:aHeader))+1)
	   	    	For nx:=1 To Len(aBkBrwCrit[1])
		    		If nx=(Len(aBkBrwCrit[1]))
		    			aBkBrwCrit[1,nx]:=.F.
		    		ElseIf nX== nPosSeque
		    				aBkBrwCrit[1, nPosSeque]:="001"
		    		ElseIf nX== nPosSeqCri
							aBkBrwCrit[1,nPosSeqCri]:="001"
		    		Else
			    		aBkBrwCrit[1,nX]:=CriaVar(oBrwCri:aHeader[nx,2],.F.)
		    		Endif
	    		Next nx
	    		oBrwCri:ACOLS	:= aBkBrwCrit
		    Endif
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para verificar no Browse se ha o mesmo procedimento³
		//³para que seja somado o valor para qtde periodicidade.         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lProPTUGen := .f.
		If (BEJ->(readvar()) $ "M->BEJ_CODPRO") .and. Alltrim(M->BEJ_CODPRO) $ allTrim(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen) //Verifica eventos genericos
			lProPTUGen := .T.
		 EndIf

		If ValType(oBrwPro) = "O"
			nPosQtd:= Ascan(oBrwPro:aHeader,{ |x| x[2] == "BEJ_QTDPRO"})
	    	nPosCod:= Ascan(oBrwPro:aHeader,{ |x| x[2] == "BEJ_CODPRO"})
    		nPosSeq:= Ascan(oBrwCri:aHeader,{ |x| x[2] == "BEJ_SEQCRI"})
	    	If 	nPosQtd > 0 .and. nPosCod > 0 .and. (BEJ->(readvar()) $ "M->BEJ_CODPRO")
		    	For nL:=1 to Len(oBrwPro:ACOLS)
		    		If oBrwPro:ACOLS[nL,nPosCod]=cCodPro .AND. !lProPTUGen
		    		    If (nQtdPro+oBrwPro:ACOLS[nL,nPosQtd]) >1
		    			 	Aviso( STR0096, STR0131, { STR0099 }, 2 ) //"Atenção"###"Este procedimento já foi adicionado."###"Ok"
		    				Return(.F.)
		    			Endif
		    		Endif
		    	Next nL
		    Endif
		Endif

	Endif

	If cAliasIte =="BQV"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o protocolo foi informado                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lProtRN395 .And. Type("cNumProto") <> "U" .And. Empty(cNumProto) 
	  		
	  		aDadUsr := PLSGETUSR()
			If lUnimeds .And. aDadUsr[45] <> PlsIntPad()
				lInterProt := .T.
			EndIf	
			
			If lInterProt    
				P773AutInc(cAliasIte,@cNumProto,nil,lInterProt,.F.,nil,nil,nil,aDadUsr[2],.T.)
			Else
				P773AutInc(cAliasIte,@cNumProto,nil,nil,nil,nil,nil,nil,aDadUsr[2],.T.)
			EndIf   
			
			M->BQV_PROATE := cNumProto
			If Empty(cNumProto) .And. !lInterProt  
				lOk := .F.
				Return(.F.)
	  		Endif	
 		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para verificar no Browse se ha o mesmo procedimento³
		//³para que seja somado o valor para qtde periodicidade.         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lProPTUGen := .f.
		If (BQV->(readvar()) $ "M->BQV_CODPRO") .and. Alltrim(M->BQV_CODPRO) $ allTrim(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen) //Verifica eventos genericos
			lProPTUGen := .T.
		 EndIf
		 
		If ValType(oBrwBQV) = "O"
			nPosQtd:= Ascan(oBrwBQV:aHeader,{ |x| x[2] == "BQV_QTDPRO"})
	    	nPosCod:= Ascan(oBrwBQV:aHeader,{ |x| x[2] == "BQV_CODPRO"})
    		nPosSeq:= Ascan(oBrwBQV:aHeader,{ |x| x[2] == "BQV_SEQUEN"})
    		nPosDat:= Ascan(oBrwBQV:aHeader,{ |x| x[2] == "BQV_DATPRO"})
    		nPosHor:= Ascan(oBrwBQV:aHeader,{ |x| x[2] == "BQV_HORPRO"})
	    	If 	nPosQtd > 0 .and. nPosCod > 0 .and. (BQV->(readvar()) $ "M->BQV_CODPRO")
		    	For nL:=1 to Len(oBrwBQV:ACOLS)
		    		If oBrwBQV:ACOLS[nL,nPosCod]=cCodPro  .and. oBrwBQV:ACOLS[nL,nPosDat]== dDatabase  .and. substr(oBrwBQV:ACOLS[nL,nPosHor],1,3) ==Substr(StrTran(time(),":",""),1,3)
		    		    If (nQtdPro+oBrwBQV:ACOLS[nL,nPosQtd]) >1 .and. !lProPTUGen
		    			 	Aviso( STR0096, STR0131, { STR0099 }, 2 ) //"Atenção"###"Este procedimento já foi adicionado."###"Ok"
		    				Return(.F.)
		    			Endif
		    		Endif
		    	Next nL
		    Endif
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se todos obrigatorios foram informados									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(oEncInt) <> 'U'
		If !Obrigatorio(oEncInt:aGets,oEncInt:aTela)
		   Return(.F.)
		Endif
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trata se o solicitante foi digitado da mesma forma quando confirma-se    ³
	//³ a validação do atendimento...											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cAliasCab == 'BE4' .AND. M->BE4_OPESOL == PLSINTPAD() .AND. Empty(M->BE4_REGSOL)
		Help("",1,"PLSA090002")
		Return(.F.)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao informado														     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(M->BE4_CODRDA)
	   Aviso( STR0054, STR0055, {  STR0099  }, 2 ) 	    //"Rede de Atendimento"###"Informe a Rede de Atendimento antes de informar o procedimento."
	   Return(lRet)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao informado														     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(M->BE4_USUARI)
	   Aviso( STR0056, STR0057, {  STR0099  }, 2 ) 	    //"Usuario"###"Informe o Usuario antes de informar o procedimento."
	   Return(lRet)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Pega a tabela correspondente
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If (GetNewPar("MV_PLSDTPG",.F.) .Or. Empty(GetNewPar("MV_PLSTBPD","")))  .And. lChkP

		aRet 	:= PLSCHKPAC(cAliasIte,M->BE4_CODRDA,M->BE4_DTDIGI)
		cPadPro := aRet[1]
		cCodPad := aRet[2]
		M->&( cAliasIte+"_CODPAD" ) := cCodPad
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ PLSRETTAB																    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCodTab := PLSRETTAB(cCodPad,cCodPro,M->BE4_DTDIGI,;
							 M->BE4_OPERDA,M->BE4_CODRDA,M->BE4_CODESP,M->BE4_SUBESP,M->(BE4_CODLOC+BE4_LOCAL),;
							 M->BE4_DTDIGI,,M->BE4_OPERDA,,"1","1")

		If aCodTab[1]
			cCodTab := IiF(!Empty(aCodTab[3]),aCodTab[3],cCodTab)
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ seek																	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BA0->(DbSetOrder(1))
	If BA0->( MsSeek( xFilial("BA0")+M->BE4_OPERDA ) )
		cCodTab := BA0->BA0_CODTAB
		BA0->( DbGoTo(nRecBA0) )
		BA0->( DbSetOrder(nOrdBA0) )
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PLSCOMEVE																 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cAliasIte =="BQV"
		//Devido as mudanças de eventos de procedimentos estipulados pela ANS, 
		//Ha eventos que são bloqueados e outros alterados, portanto na evolução de internação
		//não podemos se basear na data de internação e sim na data de inclusao do procedimento de prorrogação
		aCompo := PLSCOMEVE(cCodTab,cCodPad,cCodPro,M->BE4_OPERDA,M->BQV_DATPRO,"03")
	Else
	    aCompo := PLSCOMEVE(cCodTab,cCodPad,cCodPro,M->BE4_OPERDA,M->BE4_PRVINT,"03")
	Endif	
	If Len(aCompo) == 0
		if !empty(cCodPro)
	   		MsgInfo(STR0037+AllTrim(cCodPro)+STR0038+cCodTab) //"O Procedimento "###" nao possui composicao de pagamento definida na TDE "
		else
		    lRet := .T.
		endif
	Else
	   If BE4->(FieldPos("BE4_CDPFRE")) > 0
	   	  
	   	  If EMPTY(M->BE4_CDPFRE) 
	   	  		
	   	  		BB0->(dbSetOrder(4))
	   	  		If BB0->(MsSeek(xFilial("BB0")+M->BE4_ESTSOL+M->BE4_REGSOL))
	   	  			cCodExe := BB0->BB0_CODIGO
	   	  		Else
	   	  			cCodExe := ""
	   	  		EndIf
	      Else
	    		cCodExe := M->BE4_CDPFRE
	   	  EndIf 
	   Else
	      cCodExe := ""
	   Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Evolucao (Para tratar os item atendimento internação)
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If nTp == 0
			cAliasProc := "BEJ"
	   Endif

	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Se for uma Unimed, verifica se foi lancado um procedimento repetido      ³
	   //³ diferente de Mat/Med/Taxa generica                                       ³
	   //³ Alteracao realizada para atender as regras do Ptu Online                 ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If lUnimeds
	   	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     		//³ Internacao                                                               ³
	        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        If nTp == 0
	            nPosCodPro  := Ascan(oBrwPro:aHeader,{ |x| x[2] == "BEJ_CODPRO"})
  		        nPosDesPro	:= Ascan(oBrwPro:aHeader,{ |x| x[2] == "BEJ_DESPRO"})
  		        cCodProLin	:= Alltrim(oBrwPro:aCols[oBrwPro:OBROWSE:nAt,nPosCodPro])

		        If allTrim(M->BEJ_CODPRO) $ allTrim(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen) //Verifica eventos genericos
			        lProPTUGen := .T.
		     	EndIf

                lCritRepet := .T.
                BR8->(DbSetOrder(1))//BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN
                If BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro)) .And. BR8->BR8_ANEEDI == "1" .And. BR8->BR8_TPPROC == "2"
                	lCritRepet := .F.
                EndIf 

		   		//Verifica se o procedimento ja foi adicionado anteriormente no browse.
				If (oBrwPro:linAddLine .Or. cCodProLin <>  Alltrim(M->BEJ_CODPRO)) .And. !lProPTUGen .And. lCritRepet
			    	For nX := 1 to Len(oBrwPro:aCols)
				    	If Alltrim(oBrwPro:aCols[nX,nPosCodPro]) == Alltrim(M->BEJ_CODPRO)
				    	
					    	Aviso( 	STR0023,; //"Críticas da Autorização"
							STR0131,; //"Este procedimento já foi adicionado."
							{STR0099}, 2 )//OK
				    				
							//Quando o usuario usa a tecla ESC, apos digitar um codigo de procedimento que ja exista a descricao ja esta atualizada, entao preciso retornar a descricao que esta na linha da getDados.
							M->BEJ_DESPRO := oBrwPro:aCols[oBrwPro:oBrowse:nAt,nPosDesPro]
							Return(lRet)
						EndIf
					Next nX
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se alcancou o limite de itens PTU Online				     	 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lPTUOn70
					aDadUsr := PLSGETUSR()
					nLimitePTU := GetNewPar("MV_PLLIPTU",50)
					If aDadUsr[45] <> PlsIntPad()
						For nX := 1 to len(oBrwPro:aCols)
							If !Empty(oBrwPro:aCols[nX][nPosCodPro] )
								nItensPTU ++
							EndIf
						Next
	
						If nItensPTU  >= nLimitePTU .And. oBrwPro:lInAddLine
							MsgInfo(STR0145+Alltrim(Str(nLimitePTU))+STR0146)//"O limite para solicitações PTU Online é de "###" itens."
							Return(.F.)
						EndIf
					EndIf
                EndIf
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   		//³ Evolucao                                                                 ³
	       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    ElseIf nTp == 1 .And. !Empty(M->BE4_NRTROL) .And. !Empty(M->BE4_NRAOPE) .And. M->BE4_COMUNI == "1"
		        nPosCodPro  := Ascan(oBrwBQV:aHeader,{ |x| x[2] == "BQV_CODPRO"})
  		        nPosDesPro	:= Ascan(oBrwBQV:aHeader,{ |x| x[2] == "BQV_DESPRO"})
  		        If BQV->(FieldPos("BQV_NRTROL")) > 0
  		            nPosNrtrol  := Ascan(oBrwBQV:aHeader,{ |x| x[2] == "BQV_NRTROL"})
  		        EndIf

  		        cCodProLin	:= Alltrim(oBrwBQV:aCols[oBrwBQV:OBROWSE:nAt,nPosCodPro])

		        If Alltrim(M->BQV_CODPRO) $ allTrim(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen) //Verifica eventos genericos
			        lProPTUGen := .T.
		     	EndIf
				
				lCritRepet := .T.
                BR8->(DbSetOrder(1))
                If BR8->(MsSeek(xFilial("BR8")+M->BQV_CODPAD+M->BQV_CODPRO)) .And. BR8->BR8_ANEEDI == "1" .And. BR8->BR8_TPPROC == "2"
                	lCritRepet := .F.
                EndIf 

		   		//Verifica se o procedimento ja foi adicionado anteriormente no browse.
				If (oBrwBQV:linAddLine .Or. cCodProLin <>  Alltrim(M->BQV_CODPRO)) .And. !lProPTUGen
			    	For nX := 1 to Len(oBrwBQV:aCols)
				    	If Alltrim(oBrwBQV:aCols[nX,nPosCodPro]) == Alltrim(M->BQV_CODPRO) .And. nPosNrtrol > 0 .And. Empty(oBrwBQV:aCols[nX,nPosNrtrol])
				        	Aviso( 	STR0023,; //"Críticas da Autorização"
							STR0131,; //"Este procedimento já foi adicionado."
							{STR0099}, 2 )//OK
							//Quando o usuario usa a tecla ESC, apos digitar um codigo de procedimento que ja exista a descricao ja esta atualizada, entao preciso retornar a descricao que esta na linha da getDados.
							M->BQV_DESPRO := oBrwBQV:aCols[oBrwBQV:oBrowse:nAt,nPosDesPro]
							Return(lRet)
    					EndIf
					Next nX
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se alcancou o limite de itens PTU Online				     	 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPosNRTROL  := Ascan(oBrwBQV:aHeader,{ |x| x[2] == "BQV_NRTROL"})
				nPosCodPro  := Ascan(oBrwBQV:aHeader,{ |x| x[2] == "BQV_CODPRO"})
				aDadUsr := PLSGETUSR()
				If !lPTUOn70
					nLimitePTU := GetNewPar("MV_PLLIPTU",50)
	
					For nX := 1 to Len(oBrwBQV:aCols)
						If Empty(oBrwBQV:aCols[nX,nPosNRTROL]) .And. !Empty(oBrwBQV:aCols[nX][nPosCodPro] )
							nItensPTU ++
						EndIf
					Next nX
	
					If nItensPTU >= nLimitePTU
						MsgInfo(STR0145+Alltrim(Str(nLimitePTU))+STR0146)//"O limite para solicitações PTU Online é de "###" itens."
						Return(.F.)
					EndIf
				EndIf	
	     	EndIf
	   EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Valida o pacote x procedimento do pacote
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If GetNewPar("MV_PLSDTPG",.F.)
			If cAliasIte == 'BQV'
				lNegProPac := PLSVLDINP("2",cPadPro,oEncInt,oBrwBQV,oBrwBQZ,"BE4","BQV","BQZ")
			Else
				lNegProPac := PLSVLDINP("2",cPadPro,oEncInt,oBrwPro,oBrwCri,"BE4","BEJ","BEL")
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Autorizacao da guia
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		lRet := PLSA090Aut(cSequen,cCodPad,cCodPro,nQtdPro,cTipo,cAliasIte,cAliasCab,cAliasCri,Iif( nTp==0,oBrwPro,oBrwBQV),;
		Iif( nTp==0 , oBrwCri , oBrwBQZ ),cCodExe,.F.,.T.,M->BE4_PADINT,M->BE4_PADCON,nil,;
		M->BE4_GRPINT+M->BE4_TIPINT,nil,If(nTp==0,.F.,.T.),aDadB43,aCabB43,aTrbB43,cRegAte,Iif(nTp == 0,"S","E"),;
		Iif( nTp==0,oBrwPro,oBrwBQV),cAliasProc,.F.,lNegProPac,.T.)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³OK
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lRet
		BR8->( DbSetOrder(1) )
		If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Lembretes                                                 			 	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If BR8->( FieldPos("BR8_LEMBRE") ) > 0 .and. !Empty(BR8->BR8_LEMBRE)
				If lLembre := PLSLEMBRE(.T.,nil,nil,nil,nil,nil,IIF(nTp == 1,.T.,.F.))
					Aviso("Lembrete", Alltrim(BR8->BR8_LEMBRE), {"Ok"})
				Endif
			Endif

			BR8->( DbGoTo(nRecBR8) )
			BR8->( DbSetOrder(nOrdBR8) )
		EndIf
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Evolucao de SADT    				                					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o protocolo foi informado                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lProtRN395 .And. Type("cNumProto") <> "U" .And. Empty(cNumProto)
 
		aDadUsr := PLSGETUSR()
		If lUnimeds .And. aDadUsr[45] <> PlsIntPad()
			lInterProt := .T.
		EndIf	
		
		If lInterProt    
			P773AutInc(cAliasIte,@cNumProto,nil,lInterProt,.F.,nil,nil,nil,Alltrim(aDadUsr[2]),.T.)
		Else
			P773AutInc(cAliasIte,@cNumProto,nil,nil,nil,nil,nil,nil,Alltrim(aDadUsr[2]),.T.)
		EndIf   
		
		M->BQV_PROATE := cNumProto
		If Empty(cNumProto) .And. !lInterProt  
			lOk := .F.
			Return(.F.)
  		Endif	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se todos obrigatorios foram informados									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(oEncInt) <> 'U'
		If !Obrigatorio(oEncInt:aGets,oEncInt:aTela)
		   Return(.F.)
		Endif
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao informado														     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(M->BE1_CODRDA)
	   Aviso( STR0054, STR0055, {  STR0099  }, 2 ) 	    //"Rede de Atendimento"###"Informe a Rede de Atendimento antes de informar o procedimento."
	   Return(lRet)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao informado														     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(M->BE1_USUARI)
	   Aviso( STR0056, STR0057, {  STR0099  }, 2 ) 	    //"Usuario"###"Informe o Usuario antes de informar o procedimento."
	   Return(lRet)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se alcancou o limite de itens PTU Online				     	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosNRTROL  := Ascan(oBrwBQV090:aHeader,{ |x| x[2] == "BQV_NRTROL"})
	nPosCodPro  := Ascan(oBrwBQV090:aHeader,{ |x| x[2] == "BQV_CODPRO"})
	aDadUsr := PLSGETUSR()
	If !lPTUOn70
		nLimitePTU := GetNewPar("MV_PLLIPTU",50)
	
		For nX := 1 to Len(oBrwBQV090:aCols)
			If Empty(oBrwBQV090:aCols[nX,nPosNRTROL]) .And. !Empty(oBrwBQV090:aCols[nX][nPosCodPro] )
				nItensPTU ++
			EndIf
		Next nX
	
		If nItensPTU >= nLimitePTU .And. oBrwBQV090:lInAddLine
			MsgInfo(STR0145+Alltrim(Str(nLimitePTU))+STR0146)//"O limite para solicitações PTU Online é de "###" itens."
			Return(.F.)
		EndIf
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ seek																	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BA0->(DbSetOrder(1))
	If BA0->(MsSeek(xFilial("BA0")+M->BE1_OPERDA))
	   cCodTab := BA0->BA0_CODTAB
	   BA0->(DbGoTo(nRecBA0))
	   BA0->(DbSetOrder(nOrdBA0))
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PLSCOMEVE																 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCompo := PLSCOMEVE(cCodTab,cCodPad,cCodPro,M->BE1_OPERDA,nil,"03")
	If Len(aCompo) == 0
		if !empty(cCodPro)
	   		MsgInfo(STR0037+AllTrim(cCodPro)+STR0038+cCodTab) //"O Procedimento "###" nao possui composicao de pagamento definida na TDE "
		else
		    lRet := .T.
		endif
	Else
		If !Empty(M->BE1_CDPFRE)
			cCodExe := M->BE1_CDPFRE
		Else
			cCodExe := ""
		Endif
		If nTp == 1
	        cAliasProc:="BEJ"
		Endif

		lRet := PLSA090Aut(cSequen,cCodPad,cCodPro,nQtdPro,cTipo,cAliasIte,"BE1",cAliasCri,oBrwBQV090,oBrwBQZ090,cCodExe,.F.,.T.,M->BE1_OPERDA,nil,nil,;
	                      nil,nil,If(nTp==0,.F.,.T.),aDadB43,aCabB43,aTrbB43,cRegAte,Iif(nTp == 0,"S","E"),nil,nil,.F.)
	Endif

Endif

RestArea( aAreaBEA )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A092INTGER³ Autor ³ Tulio Cesar		    ³ Data ³ 00.00.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function A092INTGER()
LOCAL aRetIntEve := PLSA235(.F.,"",.T.)

If aRetIntEve[1]
   M->BE4_USUARI := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)

   PLSA090USR(M->BE4_USUARI,M->BE4_DATPRO,M->BE4_HORPRO,"BE4")
   lRefresh := .T.
Else
   If Len(aRetIntEve) >= 2 .And. Len(aRetIntEve[2]) > 0
   		PLSMOVCRI("2",{},aRetIntEve[2])
   Endif
Endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA092VR2³ Autor ³ Tulio Cesar		    ³ Data ³ 00.00.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PLSA092VR2()
LOCAL lRet    := .T.
LOCAL cCodRda

If M->BE4_OPERDA == PLSINTPAD()
   Return(lRet)
Endif

BA0->(DbSetOrder(1))
If ! BA0->(MsSeek(xFilial("BA0")+M->BE4_OPERDA))
   Help("",1,"REGNOIS")
   lRet := .F.
Endif

If lRet
   cCodRda       := BA0->BA0_CODRDA
   M->BE4_CODRDA := cCodRda

   If ( M->BE4_OPERDA <> PLSINTPAD() ) .And. ( ! Empty(cCodRda) )
      lRet := PLSA090RDA(M->BE4_OPERDA,M->BE4_CODRDA,"1",M->BE4_DATPRO,;
                         M->BE4_USUARI,M->BE4_CODLOC,M->BE4_CODESP,"BE4")

      If lRet
         M->BE4_TIPPRE := BAU->BAU_TIPPRE
         lRefresh := .T.
         oEncInt:Refresh()
      Else
         M->BE4_CODRDA := ""
      Endif
   Endif
Endif

M->BE4_OPERDA := PLSINTPAD()

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA092SEQ³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria Sequencia											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092SEQ(nTp)
LOCAL cRet  := "001"
LOCAL lAtu	:= .F.
LOCAL aTrbProc := {}
LOCAL aCabProc := {}
LOCAL cChave   := ""
LOCAL aAux     := {}
LOCAL nPosSeq  := 0

DEFAULT nTp := 0

if FunName() $ "PLSA09P"
	cRet := PLSA09PSEQ()
ElseIf FunName() $ "PLSA094A/PLSA094B"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se existir objeto na BQV incrementa item     							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type('oBrwBQV090') == "O"
		cRet := PLSINCRE("BQV_SEQUEN",oBrwBQV090)
	Else
		nPosSeq := Ascan(aCabProcSq,{|x| x[2] == "BE2_SEQUEN"})
		cRet := oBrwBE2Seq[len(oBrwBE2Seq)][nPosSeq]
		cRet := StrZero(Val(cRet) + 1,3)
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Autorizacao																 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(oBrwPro) == "O"
		If oBrwPro:aCols[Len(oBrwPro:aCols),Len(oBrwPro:aHeader)+1]
			cRet := Soma1(oBrwPro:FieldGet("BEJ_SEQUEN"))
		Else
			cRet := PLSINCRE("BEJ_SEQUEN",oBrwPro)
		EndIf
	Else
		cRet := PLSINCRE("BEJ_SEQUEN")
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Evolucao																 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTp == 1
		If ValType(oBrwBQV) == "O" .And. ValType(oBrwBQZ) == "O" .And. ValType(oBrwPro) == "O" .And. Type("aCols") == 'U'

			If Val( oBrwPro:FieldGet("BEJ_SEQUEN",Len(oBrwPro:aCols) ) ) >= Val( oBrwBQV:FieldGet("BQV_SEQUEN",Len(oBrwBQV:aCols) ) )
				cRet := Soma1( oBrwPro:FieldGet( "BEJ_SEQUEN",Len(oBrwPro:aCols) ) )
			Else
				cRet := oBrwBQV:FieldGet("BQV_SEQUEN",Len(oBrwBQV:aCols) )
			EndIf

			lAtu := .T.
		ElseIf ValType(oBrwBQV) == "O" .And. ValType(oBrwPro) == "O" .And. Type("aCols") == 'A'

			If oBrwBQV:aCols[Len(oBrwBQV:aCols),Len(oBrwBQV:aHeader)+1]
				cRet := Soma1(oBrwBQV:FieldGet("BQV_SEQUEN"))
			Else
				cRet := PLSINCRE("BQV_SEQUEN",oBrwBQV)
			EndIf

			lAtu := .F.
		Else
			cRet := StrZero( Val(cRet) + Val(PLSINCRE("BQV_SEQUEN")),3)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quantidade de Diarias													 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Atualiza o browse
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lAtu .And. oBrwBQV:FieldGet("BQV_SEQUEN",Len(oBrwBQV:aCols) ) <> cRet
	oBrwBQV:FieldPut("BQV_SEQUEN",cRet,Len(oBrwBQV:aCols) )
	oBrwBQV:Atualiza()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³P092SEQCRI³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria Sequencia											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function P092SEQCRI(nTp)
LOCAL cRet  := "001"
DEFAULT nTp := 0

If FunName() $ "PLSA094A/PLSA094B"
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Autorizacao																 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTp == 0
		If Type('oBrwPro') == "O"
			cRet := oBrwPro:FieldGet("BE2_SEQUEN")
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Evolucao																 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		If Type('oBrwBQV090') == "O"
			cRet := oBrwBQV090:FieldGet("BQV_SEQUEN")
		EndIf
	EndIf

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Autorizacao																 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nTp == 0
		If ValType(oBrwPro) == "O"
			cRet := oBrwPro:FieldGet("BEJ_SEQUEN")
		EndIf
	Elseif nTp == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Evolucao																 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(oBrwBQV) == "O"
			cRet := oBrwBQV:FieldGet("BQV_SEQUEN")
		EndIf

	Elseif nTp == 2
		If BEL->( FieldPos("BEL_SEQCRI") ) > 0
			If ValType(oBrwCri) == "O"
				If !(oBrwCri:aCols[Len(oBrwCri:aCols),Len(oBrwCri:aHeader)+1])
					cRet := PLSINCRE("BEL_SEQCRI",oBrwCri)
				EndIf
			Else
				cRet := PLSINCRE("BEL_SEQCRI")
			Endif
		Endif

	Elseif nTp == 2
		If BQZ->( FieldPos("BQZ_SEQCRI") ) > 0
			If ValType(oBrwCri) == "O"
				If !(oBrwCri:aCols[Len(oBrwCri:aCols),Len(oBrwCri:aHeader)+1])
					cRet := PLSINCRE("BQZ_SEQCRI",oBrwCri)
				EndIf
			Else
				cRet := PLSINCRE("BQZ_SEQCRI")
			Endif
		Endif

	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA092EXE³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica executante										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092EXE()
LOCAL lRet

If Empty(M->BE4_REGEXE)
	Return(.t.)
Endif

If BE4->(FieldPos("BE4_OPEEXE")) > 0
   BB0->(DbSetOrder(4))
   lRet := BB0->(MsSeek(xFilial("BB0")+M->BE4_ESTEXE+M->BE4_REGEXE+M->BE4_SIGLA))

   If lRet
      M->BE4_NOMEXE := BB0->BB0_NOME
      M->BE4_CDPFRE := BB0->BB0_CODIGO
	  If BB0->(FieldPos("BB0_CODBLO")) > 0
	  	  lRet := A090CHEBLO(BB0->BB0_CODIGO,dDataBase)
	  EndIf
   Else
      Help("",1,"REGNOIS")
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA092DTI³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092DTI()
LOCAL nFor

For nFor := 1 To Len(oBrwBD6:aCols)
    If oBrwBD6:FieldPos("BD6_DATPRO") > 0
       oBrwBD6:FieldPut("BD6_DATPRO",M->BE4_DATPRO,nFor)
    Endif
    If oBrwBD6:FieldPos("BD6_HORPRO") > 0
       oBrwBD6:FieldPut("BD6_HORPRO",M->BE4_HORPRO,nFor)
    Endif
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ClasseCarUsr³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 				   											    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ClasseCarUsr()
	PLSVSCLACAR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PL092CRINE ³ Autor ³Alexander       		³ Data ³ 26.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a critica de um procedimento autorizado				  ³±±
±±³			 ³ Usada pelo ponto de entrada (PLS092B3)					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PL092CRINE(cCodCri)

    LOCAL nLinha

	If oBrwPro:aCols[oBrwPro:Linha(),PLRETPOS("BEJ_STATUS",oBrwPro:aHeader)] <> '1' .or.;
	   Empty( oBrwPro:aCols[oBrwPro:Linha(),PLRETPOS("BEJ_CODPRO",oBrwPro:aHeader)] )
	   MsgAlert(STR0122)  //'Ação permitida somente para procedimento AUTORIZADO!'
	   Return
	EndIf

	If !MsgYesNo(STR0123)//'Deseja NEGAR a AUTORIZAÇÃO?'
	   Return
	EndIf

	BCT->( DbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
	BCT->( MsSeek( xFilial( 'BCT' )+PLSINTPAD()+cCodCri )  )// Trocar o 701 pelo codigo da sua critica

	oBrwPro:aCols[oBrwPro:Linha(),PLRETPOS("BEJ_STATUS",oBrwPro:aHeader)] := "0"
	oBrwPro:aCols[oBrwPro:Linha(),PLRETPOS("BEJ_IMGSTA",oBrwPro:aHeader)] := "DISABLE"
	oBrwPro:Consiste()
	nLinha := oBrwPro:Linha()
	oBrwPro:Refresh()
	oBrwPro:SetPos(nLinha)

    oBrwCri:aCols[oBrwCri:Linha(),PLRETPOS("BEL_CODGLO",oBrwCri:aHeader)] := cCodCri
	oBrwCri:aCols[oBrwCri:Linha(),PLRETPOS("BEL_DESGLO",oBrwCri:aHeader)] := BCT->BCT_DESCRI
	oBrwCri:Consiste()
	oBrwCri:ForceRefresh(oBrwPro)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VerSis     ³ Autor ³ Eduardo Motta        | Data ³ 08.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao intermediaria a PLSGETVERSAO para que nao de mensagem³±±
±±³          ³de funcao nao existe caso a PLSGETVERSAO nao esteja compilad³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Static Function VerSis()
Local nVersao := 7
If FindFunction("PLSGETVERSAO")
   nVersao := PlsGetVersao()
EndIf

Return nVersao
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³Pls092Bco³ Autor ³ Henry Fila             ³ Data ³ 18.05.06 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Banco de conhecimento dos itens                            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pls092Bco(cOp)

Local aArea		:= GetArea()
Local aRotBack  	:= aRotina
Local cQuery		:= ""
Local cIndex		:= ""
LOCAL cChaveInt  	:= BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
LOCAL cChaveAC9 	:= BE4->BE4_FILIAL+cChaveInt

Default cOp		:= "I" // C = Anexo vinculado ao cabeçalho  I = Anexo vinculado ao item

aRotina := {{STR0058,'MsDocument',0,3},{"Inclusão Rápida",'PLSDOcs',0,3}} //"Conhecimento"

BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
BEA->( MsSeek( xFilial("BEA") + cChaveInt ) )
DbSelectArea("BE2")

If cOp == "I" // inclusão nos itens
	
	cIndex := CriaTrab(NIL,.F.)
	
	cQuery := "BE2_FILIAL == '" + xFilial("BE2") + "' "
	cQuery += " .And. BE2_OPEMOV == '" + BEA->BEA_OPEMOV + "'"
	cQuery += " .And. BE2_ANOAUT == '" + BEA->BEA_ANOAUT + "'"
	cQuery += " .And. BE2_MESAUT == '" + BEA->BEA_MESAUT + "'"
	cQuery += " .And. BE2_NUMAUT == '" + BEA->BEA_NUMAUT + "'"

	IndRegua("BE2",cIndex,BE2->(IndexKey()),,cQuery)

	If BE2->(!Eof())
		MaWndBrowse(0,0,300,600,STR0027,"BE2",,aRotina,,,,.T.,,,,,,.F.) //"Retorno de Doctos. de Saida"
	EndIf
	
	If PLSALIASEX("B53")
	
		AC9->(DbSetOrder(2))//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ, R_E_C_N_O_, D_E_L_E_T_
	
		If AC9->(dbSeek( xFilial("AC9") + "BE2" +xfilial('BE2')+cChaveAC9))
		    dbSelectArea("B53")
		    If B53->(dbSeek(xFilial("B53")+cChaveInt))
		      	If B53->B53_BANCON != '1'
			      	B53->(Reclock("B53",.F.))
					B53->B53_BANCON := '1'
					B53->(MsUnlock())
				EndIf
			EndIf
		else
				 dbSelectArea("B53")
		    If B53->(dbSeek(xFilial("B53")+cChaveInt))
		      If B53->B53_BANCON != '0'
			      	B53->(Reclock("B53",.F.))
					B53->B53_BANCON := '0'
					B53->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf
	
	RetIndex( "BE2" )
	
	dbClearFilter()
	
	FErase( cIndex+OrdBagExt() )
Else
	MsDocument( "BEA", BEA->( RecNo() ), 2 )
	PLSATUB53(cChaveAC9, cChaveInt)
EndIf

aRotina := aRotBack

RestArea(aArea)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLS092RONL³ Autor ³ Alexander             ³ Data ³ 28.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Coloca os campos da guia com ReadOnly				      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS092RONL(lOp,oObj)
LOCAL nI
LOCAL cCampo
LOCAL cCpoNot := "BE4_MSG01,BE4_MSG02,BE4_MSG03,BE4_NRAOPE,BE4_NRAEMP"

For nI := 1 To Len(oObj:AENTRYCTRLS)
	cCampo := AllTrim(oObj:aEntryctrls[nI]:CREADVAR)
	cCampo := StrTran(cCampo,"M->","")
	If ! ( cCampo $ cCpoNot )
   	   oObj:AENTRYCTRLS[nI]:LREADONLY := lOp
   	Endif
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A92BQV    ºAutor  ³Microsiga           º Data ³  06/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se pode ou nao alteracao na data de internacao    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A92BQV()
LOCAL aArea  := GetArea()
LOCAL nCount := 0

If BQV->(MsSeek(xFilial("BQV")+BE4->BE4_CODOPE+BE4->BE4_ANOINT+BE4->BE4_MESINT+BE4->BE4_NUMINT))
	BQV->(DBEval({|| nCount++},,;
	              {||BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT == xFilial("BQV")+BE4->BE4_CODOPE+BE4->BE4_ANOINT+BE4->BE4_MESINT+BE4->BE4_NUMINT},,,.F.))
EndIf

RestArea(aArea)

Return(nCount==0)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA92DtInºAutor  ³Alexander			 º Data ³  29/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao,Alteracao e Exclusao da Data de Internacao		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA92DtIn(lRpc,dDatIntW,cHorIntW,lPtuOn)

LOCAL oFont         := NIL
LOCAL lMostraSenha 	:= .F.
LOCAL lDataAlt 	 	:= A92BQV()
LOCAL dDatInt	 	:= If(Empty(BE4->BE4_DATPRO),dDataBase,BE4->BE4_DATPRO )
LOCAL cHorInt  	 	:= If(Empty(BE4->BE4_HORPRO),StrTran(Time(),":",""),BE4->BE4_HORPRO)
LOCAL cChave  	 	:= BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)
LOCAL cChaveInt  	:= BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
LOCAL cMatric		:= BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
LOCAL nOrdBD6    	:= BD6->(IndexOrd())
LOCAL nRecBD6	 	:= BD6->(Recno())
LOCAL nOpca      	:= 3
LOCAL aButtons   	:= {}
LOCAL cMsg			:= ""
LOCAL lMVPromo := SuperGetMV("MV_PROSAUD", NIL, .F.)  // Promoção a Saude
LOCAL lMVVEleg := SuperGetMV("MV_VELEGUI", NIL, .F.)  // Promoção a Saude  - verifica elegiveis
LOCAL nRetBlq		:= 0
LOCAL aRetFun		:= {}
LOCAL lBpBlq		:= .F.
LOCAL nAvs			:= 0
LOCAL dDatBloq	:= NIL
LOCAL lPTUOn70      := Alltrim(GetNewPar("MV_PTUVEON","35")) >= "70" 
Local aRet700 		:= {}
DEFAULT lRpc		:= .F.
DEFAULT dDatIntW	:= Date()
DEFAULT cHorIntW    := Left(Time(),5)
DEFAULT lPtuOn      := .F.

//Se foi cancelada
If BE4->BE4_SITUAC == '2'
	If lRpc
		cMsg := STR0164//"A Guia selecionada foi cancelada."
		Return {cMsg,"",""}
	Else
		Help("",1,"PLSA092CAN")
		Return
	EndIf
EndIf

//Se nao foi autorizada
If BE4->BE4_STATUS == "3" .OR. BE4->BE4_STATUS == "6" 
	If !lRpc
		Aviso( STR0096, STR0100 , {  STR0099  }, 2 ) //"A guia nao foi autorizada."
	Else
		cMsg := STR0100 //"A guia nao foi autorizada."
	EndIf
	Return {cMsg,"",""}
EndIf

aRetFun := PLSDADUSR(cMatric,"1",.T.,dDataBase,nil,nil,nil)
If !aRetFun[1]
	BDS->(dbSetOrder(1))
	If lRpc
		cMsg := STR0151
		Return {cMsg,"",""}
	ElseIf BDS->(dbSeek(xFilial("BDS") + cChaveInt)) .And. Empty(BDS->(BDS_CODPAD+BDS_SEQUEN+BDS_CODPRO))
		nAvs:= Aviso(STR0166 ,;//"Usuário Bloqueado"
		STR0167 + CRLF + ;//"Problemas com o contrato do beneficiário no período do atendimento, porém a crítica de bloqueio foi forçada com a seguinte justificativa:"
		STR0168 + AllTrim(BDS->BDS_OBSMOT) + CRLF +;//"Observação: "
		STR0169 + AllTrim(BDS->BDS_OPESIS) + " - " + AllTrim(BDS->BDS_NOMOPE) + CRLF + "Deseja Prosseguir?",;//"Operador: " ## "Deseja Prosseguir?"
		{STR0070,STR0071},3)
		If nAvs == 2
			Return
		Else
			lBpBlq := .T.
		EndIf
	Else
		Aviso( STR0096, STR0151 , {  STR0099  }, 2 ) //"Problemas com o contrato do beneficiario."
		Return {cMsg,"",""}
	EndIf
	
Endif

aRetFun := PLSVLDCON(cMatric,dDataBase,nil,nil,'1',dDataBase,nil,BE4->BE4_CODRDA,nil)
If !aRetFun[1]
	dDatBloq := CtoD(aRetFun[2][3][3])
	BDS->(dbSetOrder(1))
	If lRpc
		If dDatIntW > dDatBloq
			cMsg := STR0151
		Return {cMsg,"",""}
		EndIf
	ElseIf BDS->(dbSeek(xFilial("BDS") + cChaveInt)) .And. Empty(BDS->(BDS_CODPAD+BDS_SEQUEN+BDS_CODPRO))
		nAvs:= Aviso(STR0166 ,;//"Usuário Bloqueado"
		STR0167 + CRLF + ;//"Problemas com o contrato do beneficiário no período do atendimento, porém a crítica de bloqueio foi forçada com a seguinte justificativa:"
		STR0168 + AllTrim(BDS->BDS_OBSMOT) + CRLF +;//"Observação: "
		STR0169 + AllTrim(BDS->BDS_OPESIS) + " - " + AllTrim(BDS->BDS_NOMOPE) + CRLF + "Deseja Prosseguir?",;//"Operador: " ## "Deseja Prosseguir?"
		{STR0070,STR0071},3)
		If nAvs == 2
			Return
		Else
			lBpBlq := .T.
		EndIf
	Else
		Aviso( STR0096, STR0151 , {  STR0099  }, 2 ) //"Problemas com o contrato do beneficiario."
   		//Return {cMsg,"",""}
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao permiti alterar quando for transacao online							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BE4->( FieldPos("BE4_NRTROL") ) > 0 .And. BE4->( FieldPos("BE4_NRAOPE") ) > 0 .And. !Empty(BE4->BE4_NRTROL) .And. Empty(BE4->BE4_NRAOPE) .And. !lPtuOn
	If !lRpc
		Aviso( STR0096, STR0112 , {  STR0099  }, 2 ) //"Guia On-Line, não e possível alterar a data de internação!"
	Else
		cMsg := STR0112
	EndIf
	Return {cMsg,"",""}
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Verifica se o paciente ja esta internado, com excessão se for recem nascido 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If BE4->BE4_ATERNA == '0' 
	if PLSPOSGLO(PLSINTPAD(),__aCdCri207[1],__aCdCri207[2],'','1','')
		If PLSPACINT(cMatric,iif(!lRpc,dDataBase,date()),,,.T.) 
			If !lRpc
				Aviso( STR0096, PLSBCTDESC() , {  STR0099  }, 2 )
			Else
				cMsg := PLSBCTDESC()
			EndIf
			Return {cMsg,"",""}
		EndIf
	endIf
EndIf 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for solicitacao Ptu Online    										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPtuOn
	nOpca := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fontes utilizadas somente nesta funcao...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(BE4->BE4_DTALTA)
	If !lRpc
		Aviso( STR0096, STR0107	 , {  STR0099  }, 2 ) //"Data da alta ja informada."
	Else
		cMsg := STR0107
	EndIf
	Return {cMsg,"",""}
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fontes utilizadas somente nesta funcao...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRpc
	DEFINE FONT oFont NAME "Arial" SIZE 000,-016 BOLD
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Dialog...                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE STR0117 FROM 008.2,003.3 TO 016,055 OF GetWndDefault() //"Alimentar Data de Internação"
	@ 05, 10  Say oSay PROMPT STR0118 	SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE //"Data da Internação"
	@ 18, 10  MSGET oGet VAR dDatInt				SIZE 70,10 OF oDlg FONT oFont PICTURE "@D" WHEN lDataAlt VALID A360CHEBLO(BE4->BE4_CODRDA,dDatInt) PIXEL

	@ 05, 110  Say oSay PROMPT STR0119 SIZE 160,10 	OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE //"Hora da Internação"
	@ 18, 110  MSGET oGet VAR cHorInt 				SIZE 20,10	OF oDlg FONT oFont PICTURE "@R 99:99" WHEN lDataAlt PIXEL
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Botoes																	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bInAl			:= TButton():New(38,20, Iif(Empty(BE4->BE4_DATPRO),'Incluir','Alterar'),,{ || nOpca := 0 , oDlg:End() } , 040, 012 ,,,,.T.)
	bExc 			:= TButton():New(38,80, 'Excluir'	,,{ || nOpca := 1,oDlg:End() } , 040, 012 ,,,,.T.)
	bExc:lReadOnly 	:= .F.

	bFechar := TButton():New(38,140, 'Fechar'	,,{ || nOpca := 2 , oDlg:End() } , 040, 012 ,,,,.T.)
	ACTIVATE MSDIALOG oDlg CENTERED
Else
	If !A360CHEBLO(BE4->BE4_CODRDA,dDatInt,lRpc)
		Return STR0124
	Else
		dDatInt := dDatIntW
		cHorInt := cHorIntW
		nOpca   := 0
	EndIf
EndIf
//Verifica se usuario está bloqueado na data de internacao
If nOpca == 0 .And. PLSPOSGLO(PLSINTPAD(),__aCdCri008[1],__aCdCri008[2],"1"/*cLocalExec*/,/*cAtivo*/,"1"/*cTpLocExec*/)

	lBloq := .F.
	aRetBlq := {}
	aRetBlq := PLSIBBLQ(DTOS(dDataBase),DTOS(dDatInt-GetNewPar("MV_PLDIABL",0)),aRetBlq,SubStr(cMatric,1,14),SubStr(cMatric,15,2),""/*cLocSib*/,""/*cExcAns*/)
	For nRetBlq := 1 TO Len(aRetBlq)
		If Len(aRetBlq[nRetBlq]) > 1 .And. aRetBlq[nRetBlq-1] == "0" .And. DTOS(dDatInt+GetNewPar("MV_PLDIABL",0)) > aRetBlq[nRetBlq,3]
			lBloq := .T.
		Elseif Len(aRetBlq[nRetBlq]) > 1 .And. aRetBlq[nRetBlq-1] == "1".And. DTOS(dDatInt+GetNewPar("MV_PLDIABL",0)) > aRetBlq[nRetBlq,3]
			lBloq := .F.
		EndIf
	Next nRetBlq

	If lBloq .And. !lBpBlq
		If !lRPC
			MsgInfo(STR0150)//"Usuario bloqueado na data de internacao"
		EndIf
		Return {STR0150,"",""}
	EndIf

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca retorno contido no aRetorno...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca < 2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a data e maior que alguma da evolucao						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lDataAlt .And. nOpca == 0
		BQV->( DbSetOrder(1) )//BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT
		If BQV->( MsSeek(xFilial("BQV")+cChaveInt) )
			While !BQV->(Eof())	.And. BQV->(xFilial("BQV")+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == xFilial("BQV")+cChaveInt
				If BQV->( FieldPos("BQV_DATPRO") ) > 0 .And. BQV->BQV_DATPRO < dDatInt
					If !lRpc
						MsgAlert(STR0120) //"Existe evolucao de GIH com data anterior a data informada!"
					Else
						cMsg := STR0120
					EndIf
					Return {cMsg,"",""}
				EndIf
				BQV->( DbSkip() )
			EndDo
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a data ou hora estao em branco								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(DToS(dDatInt)) .Or. Empty(cHorInt)
		If !lRpc
			MsgAlert(STR0132) //"Data e/ou hora em branco!"
		Else
			cMsg := STR0132
		EndIf
		Return {cMsg,"",""}
	EndIf

	//Verifica se paciente está internado na data informada
	If BE4->BE4_ATERNA == '0' 
		if PLSPOSGLO(PLSINTPAD(),__aCdCri207[1],__aCdCri207[2],'','1','')
			If PLSPACINT(cMatric,iif(!lRpc,dDatInt,date()),,,.T.) 
				If !lRpc
					Aviso( STR0096, PLSBCTDESC() , {  STR0099  }, 2 )
				Else
					cMsg := PLSBCTDESC()
				EndIf
				Return {cMsg,"",""}
			EndIf
		endIf
	EndIf 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclusao																 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpca == 1
		dDatInt := Ctod(Space(8))
		cHorInt := ""
		If lDataAlt			
			If !lRpc
				MsgAlert(STR0208) //"Exclusão da Data e Hora da Internação Concluida."
		    Else
				cMsg := STR0208
	EndIf
	    Else
			If !lRpc	
				MsgAlert(STR0209) //"Não é possível excluir a Data da Internação, pois a Guia tem Evolução"
		    Else
				cMsg := STR0209
	        EndIf
		EndIf
	EndIf

	// Alteracao
	If nOpca == 0 
		If lDataAlt	  
			If !Empty(BE4->BE4_DATPRO)	
				cMsg :=  STR0210 //"Alteração Concluida com Sucesso!"
			Else
				cMsg := "Inclusão Concluida com Sucesso."
		   EndIf
		     
			//Se for uma guia de intercambio na Versao 7.0, realizo a comunicacao 007
			If lPTUOn70 .And. BE4->BE4_CODEMP == GetNewPar("MV_PLSGEIN","0050") .And. (!Empty(BE4->BE4_NRTROL) .And. Val(BE4->BE4_NRTROL) != 0)
		  	    aRet700 := PLEnvPT750("I",dDatInt,lRpc) 
			    If aRet700[1]
			    	cMsg := "Comunicação de alta realizada com sucesso."
			    ElseIf !aRet700[1]
			       	If !lRpc
						MsgAlert(aRet700[2])
				    Else
				   		cMsg := aRet700[2]
				    EndIf     
			   		Return {cMsg,"",""}  
			   	Endif	
			EndIf
			
			If !lRpc
				MsgAlert(cMsg) 
		    EndIf
	    Else
			If !lRpc	
				MsgAlert(STR0211) //"Não é possível alterar este registro, pois há uma evolução."
		    Else
				cMsg := STR0211
	        EndIf
		EndIf
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia transacao...                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza a data de internacao										     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BE4->( RecLock("BE4", .F.) )
		BE4->BE4_DATPRO := dDatInt
		BE4->BE4_HORPRO := cHorInt
		If Empty(BE4->BE4_SENHA) .And. nOpca == 0
			BE4->BE4_SENHA := PLSSenAut(dDatInt)
			lMostraSenha   := .T.
		Endif

		//BAU_GRALAU = 1 - Grava data de alta automatica
		If BAU->(FieldPos("BAU_GRALAU")) > 0
			BAU->(dbSetOrder(1))
			If BAU->(msSeek(xFilial("BAU")+BE4->BE4_CODRDA)) .And. BAU->BAU_GRALAU == "1"
				aDiaPrs := PLSDIARLIB()
				//BE4->BE4_DTALTA := dDatInt + aDiaPrs[1] + aDiaPrs[2]
				BE4->BE4_DTALTA := dDatInt + BE4->BE4_DIASIN
				BE4->BE4_HRALTA := Left(StrTran(Time(),":",""),5)
			EndIf
		EndIF
		BE4->( MsUnLock() )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza O BEA														     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
	If BEA->( MsSeek( xFilial("BEA") + cChaveInt ) )
		BEA->( RecLock("BEA", .F.) )
			BEA->BEA_DATPRO := dDatInt
			BEA->BEA_HORPRO := cHorInt
			If lPtuOn .Or. GetNewPar("MV_PLSUNI","1") == "1"  .And.(BEA->BEA_CODEMP == GetNewPar("MV_PLSGEIN","0050").Or. BEA->BEA_TIPPRE == GetNewPar("MV_PLSTPIN","OPE"))
				BEA->BEA_VALSEN := dDatInt+GetNewPar("MV_PLPRZPT",30)
			Else
				BEA->BEA_VALSEN := dDatInt+GetNewPar("MV_PLPRZLB",30)
			EndIf
			If lMostraSenha
				BEA->BEA_SENHA := BE4->BE4_SENHA
				cMsg = ""
			Endif
		BEA->( MsUnLock() )
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra a Senha															 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BEJ->( DbSetOrder(1) ) //BEJ_FILIAL + BEJ_CODOPE + BEJ_ANOINT + BEJ_MESINT + BEJ_NUMINT + BEJ_SEQUEN
		BD6->( DbSetOrder(1) ) //BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
		If BD6->( MsSeek( xFilial("BD6")+cChave ) )
			While BD6->( !EOF() ) .And. cChave == BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)
				If BEJ->( MsSeek( xFilial("BEJ")+BD6->(BD6_CODOPE+BD6_ANOINT+BD6_MESINT+BD6_NUMINT+BD6_SEQUEN) ) )
					BD6->(RecLock("BD6",.F.))
					BD6->BD6_DATPRO := dDatInt
					BD6->BD6_HORPRO := cHorInt
					BD6->(MsUnLock())
				EndIf
				BD6->(DbSkip())
			EndDo
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reposiciona o bd6													  	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BD6->(DbGoTo(nRecBD6))
		BD6->(DbSetOrder(nOrdBD6))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra a Senha															 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	End Transaction
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada após confirma a data de internação e após		             ³
	//³a gravação das tabelas "BE4" e "BEA", utilizado para customizações do usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PLS092INT")
		ExecBlock("PLS092INT",.F.,.F.,{dDatInt,cHorInt,BE4->BE4_SENHA,BE4->BE4_REGINT})
	EndIf

	If lMostraSenha .And. nOpca == 0 .And. !lRpc
		A092Final(BE4->BE4_SENHA,BE4->BE4_CODOPE,BE4->BE4_ANOINT,BE4->BE4_MESINT,BE4->BE4_NUMINT,0,{},"1")
	EndIf
	If lMVPromo .And. FindFunction("PLSPROALE") .AND. nOpca == 0
		BOM->(DbSetOrder(3))
		If (BOM->(MsSeek(xFilial("BOM") + BE4->BE4_MATVID+"1")) .or. BOM->(MsSeek(xFilial("BOM") + BE4->BE4_MATVID+"3")))

			BOA->(DbSetOrder(1))
			IF BOA->(MsSeek(xFilial("BOA") + BOM->BOM_CODPRO))
				If !Empty(BE4->BE4_CID)
					cCid := BE4->BE4_CID
				EndIf

				PLSPROALE("",STR0136 + "  "+ Alltrim(BE4->BE4_NOMUSR)+ "  " + STR0137,dDataBase,Time(),"3",BE4->BE4_MATVID, "0",; //"Pac. " ###  "(entrada na internação)! "
				STR0138 +"  "+ Alltrim(BE4->BE4_NOMUSR)+ "  " +; //	"O Paciente "
				STR0139 + DTOC(dDatInt) + STR0140 +"  "+ Alltrim(BE4->BE4_NOMRDA) + " " + IIF(!Empty(cCid),"CID: " + cCid, ""),; //	" deu entrada na internação em " ### " - Credenciado: "
				"",BOM->BOM_CODPRO,IIF(!Empty(cCid),'0',""),BOM->BOM_CODLOC)

			Endif

		Endif
		If lMVVEleg // VERIFICA ELEGIVEIS NO MOMENTO DA CONFIRMACAO
			PLSELEG(,BE4->BE4_MATVID, , , , , .T., /*cCodCrm*/)
		EndIf
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza transacao...                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return( {cMsg,BEA->BEA_VALSEN,BE4->BE4_SENHA} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA92DtAltºAutor  ³Roberto			 º Data ³  29/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao,Alteracao e Exclusao da Data de Internacao		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA92DtAlt(lRpc,dDatIntW,cHorIntW,lPtuOn)

LOCAL oFont         := NIL
Local oDlg 			:= NIL
Local oGet 		    := NIL
Local oSay			:= NIL

Local nOpca 		:= 2 //Ação padrão Fechar
LOCAL dDatAlt	 	:= If(Empty(BE4->BE4_DTALTA),dDataBase,BE4->BE4_DTALTA )
LOCAL cHorAlt  	 	:= If(Empty(BE4->BE4_HRALTA),"  :  ",BE4->BE4_HRALTA)
Local cTpAlta  	 	:= If(Empty(BE4->BE4_TIPALT),space(2),BE4->BE4_TIPALT)
Local lContinua 	:= .T.
Local lPTUOn70      := Alltrim(GetNewPar("MV_PTUVEON","35")) >= "70" 
Local aRet700 		:= {}
LOCAL cMsg			:= ""

If BE4->BE4_OPESOL <> PlsIntPad() 
	Aviso( STR0096, STR0230 , {  STR0099  }, 2 ) //"Não é possível indicar a Data de Alta de uma solicitação de internação realizada por outra Operadora."
	Return
EndIf

DEFINE FONT oFont NAME "Arial" SIZE 000,-016 BOLD

if empty(BE4->BE4_DATPRO) 
	MsgAlert(STR0186) //"Data de Internação não Preenchida."
else
	DEFINE MSDIALOG oDlg TITLE STR0183 FROM 008.2,003.3 TO 016,055 OF GetWndDefault() //"Alimentar Data de Alta"
	@ 05, 10  Say oSay PROMPT STR0184 	SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE //"Data da Alta"
	@ 18, 10  MSGET oGet VAR dDatAlt				SIZE 70,10 OF oDlg FONT oFont PICTURE "@D" WHEN .T.  PIXEL
	
	@ 05, 090  Say oSay PROMPT STR0185 SIZE 160,10 	OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE //"Hora da Alta"
	@ 18, 090  MSGET oGet VAR cHorAlt 				SIZE 20,10	OF oDlg FONT oFont PICTURE "@R 99:99" WHEN .T. PIXEL
	
	@ 05, 150  Say oSay PROMPT STR0187 SIZE 160,10 	OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE //"Hora da Alta"
	@ 18, 150  MSGET oGet VAR cTpAlta SIZE 20,10	OF oDlg FONT oFont PICTURE "@C" F3 "BTWPLS" Valid(BIY->(ExistCpo("BIY",PLSINTPAD()+cTpAlta,1))) PIXEL
	
	bInAl			:= TButton():New(38,20, Iif(Empty(BE4->BE4_DTALTA),STR0007,STR0008),,{ || nOpca := 0 , oDlg:End() } , 040, 012 ,,,,.T.) //"Incluir" ### 'Alterar' 
	bExc 			:= TButton():New(38,80, STR0009	,,{ || nOpca := 1,oDlg:End() } , 040, 012 ,,,,.T.) //"Excluir"
	bExc:LREADONLY 	:= Empty(BE4->BE4_DTALTA)
	
	bFechar := TButton():New(38,140, STR0225	,,{ || nOpca := 2 , oDlg:End() } , 040, 012 ,,,,.T.) //'Fechar'
	ACTIVATE MSDIALOG oDlg CENTERED
	
	//Busca retorno contido no aRetorno...	
	If nOpca < 2
		If nOpca <> 1
			if empty(dDatAlt) .or. empty(alltrim(cHorAlt)) .or. (empty(alltrim(cTpAlta)))
				MsgAlert(STR0190) //"Informe a Data da Alta, Hora da Alta e Tipo de Alta."
				lContinua := .F.
			endif
			
			if lContinua
				if dDatAlt < BE4->BE4_DATPRO
					MsgAlert(STR0188) //"Data/Hora de Alta menor do que a data/hora de Internação."
					lContinua := .F.
				elseif dDatAlt > Date()
					MsgAlert(STR0189) //"Data/Hora de Alta maior do que a data/hora atual."
					lContinua := .F.
				elseif dDatAlt = BE4->BE4_DATPRO
					if val(StrTran(cHorAlt, ":", "")) < val(SubStr(BE4->BE4_HORPRO, 1, 2) +  SubStr(BE4->BE4_HORPRO, 3, 2)) 
						MsgAlert(STR0188) //"Data/Hora de Alta menor do que a data/hora de Internação."
						lContinua := .F.
					else
						lContinua := .T.
					endif
				endif
			endif
			
			if lContinua .and. dDatAlt = Date()
				if val(StrTran(cHorAlt, ":", "")) > val(SUBSTR(TIME(), 1, 2) + SUBSTR(TIME(), 4, 2)) 
					MsgAlert(STR0189) //"Data/Hora de Alta maior ou igual a data/hora atual."
					lContinua := .F.
				endif
			endif
		else
			lContinua := .T.
		endif
		
		if lContinua
		
			If nOpca == 1
				dDatAlt := Ctod(Space(8))
				cHorAlt := ""
				cTpAlta := Space(2)
			//Se for uma guia de intercambio na Versao 7.0, realizo a comunicacao 007
			ElseIf lPTUOn70 .And. BE4->BE4_CODEMP == GetNewPar("MV_PLSGEIN","0050") .And. (!Empty(BE4->BE4_NRTROL) .And. Val(BE4->BE4_NRTROL) != 0)
		  	    aRet700 := PLEnvPT750("A",dDatAlt,lRpc,AllTrim(cTpAlta)) 
			    If aRet700[1] .And. !lRpc 
			    	Aviso( STR0120,STR0231,{ STR0099 }, 2 ) //"Comunicação de alta realizada com sucesso."
			    ElseIf !aRet700[1]
			       	If !lRpc
						MsgAlert(aRet700[2])
				    Else
				   		cMsg := aRet700[2]
				    EndIf     
			   		Return {cMsg,"",""}  
			   	Endif				
			EndIf
		
			PLSADtAlt(.F.,dDatAlt,cHorAlt, cTpAlta)
			MsgAlert(STR0191)//"Processamento realizado com Sucesso."
		endif

	Endif
endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A092Final ³ Autor ³ Alexander            ³ Data ³ 29.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibir a senha de autorizacao de internacao                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function A092Final(cSenhaPLS,cCodOpe,cAnoInt,cMesInt,cNumInt,nTp,aDadSen,cMultSen)
LOCAL oDlg
LOCAL oSay
LOCAL cTit
LOCAL cText
LOCAL oFontNum
LOCAL oFontAutor
LOCAL oFontTit
LOCAL cRodape
LOCAL cNomUser  := BE4->BE4_OPEUSR+'.'+BE4->BE4_CODEMP+'.'+BE4->BE4_MATRIC+'.'+BE4->BE4_TIPREG+" - "+BE4->BE4_NOMUSR
LOCAL cNomRDA   := TransForm(BE4->BE4_CODRDA,PesqPict("BE4","BE4_CODRDA"))+" - "+BE4->BE4_NOMRDA
DEFAULT cCodOpe := ""
DEFAULT cAnoInt := ""
DEFAULT cMesInt := ""
DEFAULT cNumInt := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Titulo																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTp == 0
   cTit  := STR0084 //"Senha de Autorizacao"
   cText := STR0087 //"Senha"
Else
   cTit  := STR0085 //"Resumo da Evolucao GIH"
   cText := STR0086 //"Senha do procedimento"
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entradada para customização de usuário.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLA092FIM")
   Execblock("PLA092FIM",.F.,.F.,{(cCodOpe+"."+cAnoInt+"."+cMesInt+"."+cNumInt),BE4->BE4_MATRIC,cSenhaPls})
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Se mostra somente um ou plscrigen
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMultSen == "1"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define fontes utilizadas somente nesta funcao...                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE FONT oFontNum 	NAME "Arial" SIZE 000,-016 BOLD
	DEFINE FONT oFontAutor 	NAME "Arial" SIZE 000,-019 BOLD
	DEFINE FONT oFontTit 	NAME "Arial" SIZE 000,-011 BOLD
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra Resumo 															 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE cTit FROM 009,000 TO 024,070 OF GetWndDefault() //"Dados da Evolucao de GIH"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ sButton																	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SButton():New(097, 005, 1, {|| oDlg:End() },,.T.)
	SButton():New(097, 035, 6, bImpGuia,,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Say e Get																 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 007,005 SAY oSay PROMPT STR0088   SIZE 220,010 OF oDlg PIXEL FONT oFontNum //"Internacao Numero   "
	@ 006,095 SAY oSay PROMPT cCodOpe+"."+cAnoInt+"."+cMesInt+"."+cNumInt SIZE 220,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_HRED

	@ 025,005 SAY oSay PROMPT STR0089   SIZE 220,010 OF oDlg PIXEL //"Usuario              "
	@ 025,065 MSGET cNomUser            SIZE 205,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE

	@ 043,005 SAY oSay PROMPT STR0090   SIZE 220,010 OF oDlg PIXEL //"Rede Atendimento     "
	@ 043,065 MSGET cNomRDA             SIZE 205,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE

	If !Empty(cSenhaPls)
		@ 063,005 SAY oSay PROMPT cText  SIZE 220,010 OF oDlg PIXEL
		@ 063,065 MSGET cSenhaPls        SIZE 100,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE
	Endif
	ACTIVATE MSDIALOG oDlg CENTERED
Else
	If nTp == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define fontes utilizadas somente nesta funcao...                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE FONT oFontNum 	NAME "Arial" SIZE 000,-016 BOLD
		DEFINE FONT oFontAutor 	NAME "Arial" SIZE 000,-019 BOLD
		DEFINE FONT oFontTit 	NAME "Arial" SIZE 000,-011 BOLD
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mostra Resumo 															 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlg TITLE cTit FROM 009,000 TO 024,070 OF GetWndDefault()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ sButton																	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SButton():New(097, 005, 1, {|| oDlg:End() },,.T.)
		SButton():New(097, 035, 6, bImpGuia,,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Say e Get																 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 007,005 SAY oSay PROMPT STR0088   SIZE 220,010 OF oDlg PIXEL FONT oFontNum //"Internacao Numero   "
		@ 006,095 SAY oSay PROMPT cCodOpe+"."+cAnoInt+"."+cMesInt+"."+cNumInt SIZE 220,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_HRED

		@ 025,005 SAY oSay PROMPT STR0089   SIZE 220,010 OF oDlg PIXEL //"Usuario              "
		@ 025,065 MSGET cNomUser            SIZE 205,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE

		@ 043,005 SAY oSay PROMPT STR0090   SIZE 220,010 OF oDlg PIXEL //"Rede Atendimento     "
		@ 043,065 MSGET cNomRDA             SIZE 205,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE

		If !Empty(aDadSen)
			@ 063,005 SAY oSay PROMPT cText  SIZE 220,010 OF oDlg PIXEL
			@ 063,065 MSGET aDadSen[1]        SIZE 040,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE
		Endif
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o Rodape															 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cRodape := STR0088+cCodOpe+"."+cAnoInt+"."+cMesInt+"."+cNumInt+Space(10)
		cRodape += STR0089+cNomUser
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe o resultado													     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PLSCRIGEN(aDadSen,{ {STR0091,"@C",250},{STR0087,"@C",40} },cTit,Nil,cRodape)
	EndIF
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ A092BQVGIH ³ Autor ³ Alexander           ³ Data ³ 28.08.06 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Espelha um registro do BQV na guia...                      ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A092BQVGIH(nOpc,cSenhaPls,cCodPad,cCodPro,nQTDPRO,cHRENTR,cSeqAtu,cNivAut,cNivCri,cChvNiv,cLotGui,aMatCom,dDataPro)
LOCAL nForCpo
LOCAL cField
LOCAL aCodTab
LOCAL cOpeInt
LOCAL cTipGrv
LOCAL cTipRda
LOCAL cTipInt
LOCAL cTipUsr
LOCAL cAteAMB
LOCAL cDesLoc
LOCAL cEndLoc
LOCAL cTipGui
LOCAL cCodPla
LOCAL cOpeOri
LOCAL cOpeAut
LOCAL lIntAlt
LOCAL cGrpEmpInt    := GetNewPar("MV_PLSGEIN","0050")
LOCAL cChaveInt 	:= BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)
LOCAL cSequen   	:= "001"
LOCAL nOrdBD6  		:= BD6->(IndexOrd())
LOCAL nRecBD6   	:= BD6->(Recno())
LOCAL aCposPad  	:= BE4->(DbStruct())
DEFAULT cSenhaPls 	:= ''
DEFAULT cNivAut		:= ""
DEFAULT cNivCri     := ""
DEFAULT cChvNiv     := ""
DEFAULT cLotGui		:= ""
DEFAULT aMatCom		:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chave e Sequencia														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

BD6->(DbSetOrder(1))
BD6->(MsSeek(xFilial("BD6")+cChaveInt+Replicate("Z",Len(BD6->BD6_SEQUEN)),.T.))
BD6->(DbSkip(-1))

If BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) <> xFilial("BD6")+cChaveInt
	cSequen := StrZero(1,Len(BD6->BD6_SEQUEN))
Else
	cSequen := SOMA1(BD6->BD6_SEQUEN)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indice																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BQV->( DbSetOrder(1) )//BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
lIntAlt := !BQV->( MsSeek( xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)+cSeqAtu ) )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no BD6														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BD6->( DbSetOrder(1) )//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
If lIntAlt
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza a sequencia													 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cSequen > cSeqAtu
	   cSeqAtu := cSequen
	EndIf
	BD6->( MsSeek(xFilial("BD6")+cChaveInt) )
Else
	If !BD6->( MsSeek(xFilial("BD6")+cChaveInt+cSeqAtu+cCodPad+cCodPro) )
		BD6->( MsSeek(xFilial("BD6")+cChaveInt) )
 		lIntAlt := .T.
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza variaveis														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cOpeAut := BD6->BD6_CODOPE
cOpeInt := BD6->BD6_OPEINT
cTipGrv := BD6->BD6_TPGRV
cTipRda := BD6->BD6_TIPRDA
cTipInt := BD6->BD6_TIPINT
cTipUsr := BD6->BD6_TIPUSR
cAteAMB := BD6->BD6_ATEAMB
cDesLoc := BD6->BD6_DESLOC
cEndLoc := BD6->BD6_ENDLOC
cTipGui := BD6->BD6_TIPGUI
cCodPla := BD6->BD6_CODPLA
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indice e posiciona no bcl											     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BCL->(DbSetOrder(1))
BCL->(MsSeek(xFilial("BCL")+cOpeAut+cTipGui))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indice e posiciona no br8												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BR8->(DbSetOrder(1))
BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indice e posiciona no bau												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BAU->(DbSetOrder(1))
BAU->(DbSeek(xFilial("BAU")+BE4->BE4_CODRDA))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indice e posiciona no ba3												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA3->(DbSetOrder(1))
BA3->(DbSeek(xFilial("BA3")+BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC)))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indice e posiciona no ba1												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA1->(DbSetOrder(2))
BA1->(DbSeek(xFilial("BA1")+BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG)))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indice e posiciona no bg9												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BG9->(DbSetOrder(1))
BG9->(MsSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))

If BG9->BG9_TIPO == "2"
      BT5->(DbSetOrder(1))
      BT5->(MsSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP)))
      BQC->(DbSetOrder(1))
      BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ plsretab																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCodTab := PLSRETTAB(cCodPad,cCodPro,BE4->BE4_DATPRO,;
                     BE4->BE4_CODOPE,BE4->BE4_CODRDA,BE4->BE4_CODESP,"",BE4->(BE4_CODLOC+BE4_LOCAL),;
                     BD6->BD6_DATPRO,,BD6->BD6_OPEORI,BD6->BD6_CODPLA,"1","1")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa variavel de memoria												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M->BQV_CDNV01 := ""
M->BQV_CDNV02 := ""
M->BQV_CDNV03 := ""
M->BQV_CDNV04 := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui no bd6															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BD6->(RecLock("BD6",lIntAlt))

BD6->BD6_FILIAL := xFilial("BD6")
For nForCpo := 1 To Len(aCposPad)
    cField := StrTran(aCposPad[nForCpo,1],"BE4","BD6")
    If ! ("FILIAL" $ cField)
       If BD6->(FieldPos(cField)) > 0
          &("BD6->"+cField) := &("BE4->"+aCposPad[nForCpo,1])
       Endif
    Endif
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ gatniv																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSGatNiv(cCodPad,cCodPro,"BQV")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ continua a gravacao													     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BD6->BD6_SEQUEN := cSeqAtu
BD6->BD6_CODPAD := cCodPad
BD6->BD6_CODPRO := cCodPro
BD6->BD6_DESPRO := BR8->BR8_DESCRI
BD6->BD6_QTDPRO := nQTDPRO
BD6->BD6_PROCCI := If(BR8->BR8_TIPEVE$"2,3","1","0")
BD6->BD6_OPEINT := cOpeInt
BD6->BD6_TPGRV  := cTipGrv
BD6->BD6_CPFRDA := BAU->BAU_CPFCGC
BD6->BD6_TIPRDA := cTipRda
If Valtype(dDataPro) <> "U"
	BD6->BD6_DATPRO := dDataPro
EndIf
BD6->BD6_HORPRO := cHRENTR
BD6->BD6_CDNV01 := M->BQV_CDNV01
BD6->BD6_CDNV02 := M->BQV_CDNV02
BD6->BD6_CDNV03 := M->BQV_CDNV03
BD6->BD6_CDNV04 := M->BQV_CDNV04
BD6->BD6_NIVEL  := BR8->BR8_NIVEL

If BD6->(FieldPos("BD6_LOTGUI")) > 0
	BD6->BD6_LOTGUI := cLotGui
EndIf

If aCodTab[1]
   BD6->BD6_CODTAB := aCodTab[3]
   BD6->BD6_ALIATB := aCodTab[4]
Endif
BD6->BD6_MODCOB := BA3->BA3_MODPAG
If BQC->(FieldPos("BQC_ENTFIL")) > 0
	BD6->BD6_TIPUSR := If(BG9->BG9_TIPO=="1",BA3->BA3_TIPOUS,IF(BQC->BQC_ENTFIL=="1","3",BA3->BA3_TIPOUS))
Else
	BD6->BD6_TIPUSR := BA3->BA3_TIPOUS
Endif
BD6->BD6_INTERC := If(BA3->BA3_CODEMP==cGrpEmpInt,"1","0")
BD6->BD6_TIPINT := If(BA3->BA3_CODEMP==cGrpEmpInt,BT5->BT5_TIPOIN,"0")
BD6->BD6_OPEORI := BA1->BA1_OPEORI
BD6->BD6_TIPINT := cTipInt
BD6->BD6_TIPUSR := cTipUsr
BD6->BD6_NIVAUT := cNivAut
BD6->BD6_NIVCRI := cNivCri
BD6->BD6_CHVNIV := cChvNiv
BD6->BD6_ATEAMB := cAteAMB
BD6->BD6_DESLOC := cDesLoc
BD6->BD6_ENDLOC := cEndLoc
BD6->BD6_TIPGUI := cTipGui
BD6->BD6_CODPLA := cCodPla
If BD6->(FieldPos("BD6_SENEVO")) > 0
   BD6->BD6_SENEVO  := cSenhaPls
Endif
BD6->BD6_LIBERA := '0'
BD6->(MsUnLock())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui o bd7															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntAlt
   PLS720IBD7("0",BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODTAB,BD6->BD6_CODOPE,BD6->BD6_CODRDA,;
    	         BD6->BD6_REGEXE,BD6->BD6_SIGEXE,BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->BD6_CODLOC,"1",;
   	    	     BD6->BD6_SEQUEN,BCL->BCL_CDORIT,BCL->BCL_TIPGUI,BD6->BD6_DATPRO,,,,,,,,aMatCom)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cSeqAtu)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA092VLD ³ Autor ³ Alexander           ³ Data ³ 01.09.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que confirma uma autorizacao retornando o seu numero³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSA092VLD(aRetorno,oBrwPro,oBrwCri,oEncInt,nOpc,dDatInt,oBrwBQV,oBrwBQZ,lEvolucao,cMultSen,lNMudFase,aDadB43,aCabB43,aTrbB43,aMatCom,oGetBZC,cTrolComun )
LOCAL nH
LOCAL nI
LOCAL aRetFun
LOCAL aCompo
LOCAL nPos
LOCAL nPos2
LOCAL nFor
LOCAL nForH
LOCAL nRecBQV
LOCAL lForcar
LOCAL lForcou
LOCAL aRetAux
LOCAL cOpeOri
LOCAL cSequen
LOCAL cNumInt
LOCAL cNumAut
LOCAL cFieldBE4
LOCAL cExcHeader
LOCAL cMat
LOCAL cChave
LOCAL aColBEJ := {}
LOCAL aHeaBEJ := {}
LOCAL aVtaBEJ := {}
LOCAL nOpca
LOCAL aColBEL := {}
LOCAL aHeaBEL := {}
LOCAL aVtaBEL := {}
LOCAL o790C		 := NIL
LOCAL lGerSen	 := .T.
LOCAL lPartic	 := .F.
LOCAL lUmVld     := .F.
LOCAL cSenhaPls  := ""
LOCAL cCodOpe 	 := PLSINTPAD()
LOCAL aRet		 := {}
LOCAL cStatus    := ""
LOCAL lRet		 := .T.
LOCAL lMostSenha := .F.
LOCAL lOK 		 := .F.
LOCAL lProPri    := .F.
LOCAL nAuditAut  := 0
LOCAL nAuditNeg  := 0
LOCAL nItensAut  := 0
LOCAL nItensNeg  := 0
LOCAL aVetTrabBE2:= {}
LOCAL aAux		 := {}
LOCAL aAuxNew    := {}
LOCAL lNoComuOnl := .F.
LOCAL lAuditoria := .F.
LOCAL lNewReg	 := .F.
LOCAL aArea	     := {}
LOCAL aDadBEA    := {}
LOCAL aDadBE4    := {}
LOCAL aStruBE4   := BE4->(DbStruct())
LOCAL aChaveGen  := {}
LOCAL aChave     := {}
LOCAL aDadSen    := {}
LOCAL aCodProcs  := {}
LOCAL aDadUsr    := PLSGETUSR()
LOCAL nMaiorCH   := 0
LOCAL nIndMaior  := 0
LOCAL cCodTab 	 := ""
LOCAL nOrdBA0 	 := BA0->(IndexOrd())
LOCAL nRecBA0 	 := BA0->(Recno())
LOCAL cSeqCri	 := "001"
LOCAL aResComuni := {}
LOCAL cAvisoRet  := ""
LOCAL nQtdPrc
LOCAL nQtdCri
LOCAL nPr
LOCAL nCr
LOCAL aColsCri	:= {}
LOCAL aRetDesCan := {}
LOCAL lBQVSemCom := .F.
LOCAL lComunPTU  := .T.
LOCAL nResOS     := 0
LOCAL lPTUAutom  := .F.
LOCAL cMsgPTUAut := ""

DEFAULT aDadB43  := {}
DEFAULT aCabB43  := {}
DEFAULT aTrbB43  := {}
DEFAULT aMatCom	 := {}
DEFAULT oGetBZC  := NIL
DEFAULT cTrolComun := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi informado algum procedimento												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(oBrwPro:aCols)
	If !oBrwPro:aCols[nI,Len(oBrwPro:aHeader)+1]
		lUmVld := .T.
		Exit
	EndIf
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe msg se nao for informado																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lUmVld
	Aviso(	STR0096,; 				//"Atencao"
		STR0110,; 				//"Nenhum procedimento informado!"
		{ STR0099 }, 2 ) 		//"ok"
	Return(.F.)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao e preciso validacao para visualizacao								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Visualizar
	aRetorno := {BE4->BE4_SENHA,BE4->BE4_CODOPE,BE4->BE4_ANOINT,BE4->BE4_MESINT,BE4->BE4_NUMINT,"",.F.,{}}
	Return(.T.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi informado pelo menos um item...                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !oBrwPro:TudoOK() .Or. !Obrigatorio(oEncInt:aGets,oEncInt:aTela)
	Return(.F.)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata se o solicitante foi digitado...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->BE4_OPESOL == PLSINTPAD() .And. Empty(M->BE4_REGSOL)
	Help("",1,"PLSA090002")
	Return(.F.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BA0																		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA0->(DbSetOrder(1))
If BA0->(MsSeek(xFilial("BA0")+M->BE4_OPERDA))
	cCodTab := BA0->BA0_CODTAB
	BA0->(DbGoTo(nRecBA0))
	BA0->(DbSetOrder(nOrdBA0))
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata se o solicitante foi digitado...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nFor := 1 To Len(oBrwPro:aCols)
	If oBrwPro:FieldGet("BEJ_STATUS",nFor) == "1" .And. !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]
		aadd(aCodProcs,{oBrwPro:FieldGet("BEJ_SEQUEN",nFor),oBrwPro:FieldGet("BEJ_CODPAD",nFor),;
			oBrwPro:FieldGet("BEJ_CODPRO",nFor),"",0,oBrwPro:FieldGet("BEJ_QTDPRO",nFor),"",""})

		lProPri := (oBrwPro:FieldGet("BEJ_PROPRI",nFor) == "1")

		If !lProPri
			aCompo := PLSCOMEVE(cCodTab,aCodProcs[Len(aCodProcs),2],aCodProcs[Len(aCodProcs),3],M->BE4_OPERDA,M->BE4_PRVINT,"03")
			If Len(aCompo) > 0
				nPos := Ascan(aCompo,{|x| alltrim(x[1]) $ AllTrim(GetNewPar("MV_PLSCCH","HM,CH"))})
				If nPos > 0 .And. aCompo[nPos,3] > nMaiorCH
					nMaiorCH := aCompo[nPos,3]
					nIndMaior:= nFor
				Endif
			Else
				MsgInfo(STR0037+AllTrim(aCodProcs[Len(aCodProcs),3])+STR0038+cCodTab) //"O Procedimento "###" nao possui composicao de pagamento definida na TDE "
			Endif
		Endif
	Endif
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Propri																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lPropri .And. nIndMaior > 0
	oBrwPro:FieldPut("BEJ_PROPRI","1",nIndMaior)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ plsxvldcal																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(M->BE4_PRVINT)
	aRetAux := PLSXVLDCAL(M->BE4_PRVINT,PLSINTPAD(),.F.,"","")
	If ! aRetAux[1]
		Aviso( 	STR0039, ; //"Data de Previsao da Internacao"
			STR0040,; //"Nao existe calendario de pagamento para a data de previsao da internacao informada."
			{  STR0099  }, 2 )
		Return(.F.)
	Else
		M->BE4_ANOPAG := aRetAux[4]
		M->BE4_MESPAG := aRetAux[5]
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao de majoracao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir .And. GetNewPar("MV_PLSMAJ",.F.) .And. BE4->(FieldPos("BE4_TIPMAJ")) > 0
	DbSelectArea("BAU")
	If (Posicione("BAU",1,xFilial("BAU")+M->BE4_CODRDA,"BAU->BAU_TIPPRE") == GetNewPar("MV_PLSTPIN","OPE")) .And. Empty(M->BE4_TIPMAJ)
		Help( ,, 'HELP',,"Para RDA de convenio de reciprocidade o Tipo de Majoração é obrigatório!!", 1, 0)
		Return(.F.)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata se for uma autorizacao de intercambio a comunicacao online...      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEvolucao .And. GetNewPar("MV_PTGLOBO","1") == "1"
	nPos := AScan(oBrwBQV:aHeader,{|x| x[2] == "BQV_NRTROL"})
	For nFor := 1 to len(oBrwBQV:aCols)
		If Empty(oBrwBQV:aCols[nFor][nPos]) .And. !oBrwBQV:aCols[nFor][len(oBrwBQV:aCols[nFor])]
			lNoComuOnl := .T.
	   		Exit
	   	EndIf
	Next
Else
lNoComuOnl := ( Type("BE4->BE4_COMUNI") == "C" .And. M->BE4_COMUNI == "0" ) .And. GetNewPar("MV_PTGLOBO","1") == "1"
EndIf 

If (nOpc == K_Incluir .Or. lEvolucao .Or. lBtnOn) .And. Len(aDadUsr) >= 45 .And. lNoComuOnl
	cOpeOri := aDadUsr[45]
	If cOpeOri <> PLSINTPAD()
		nOrdBA0 := BA0->(IndexOrd())
		nRecBA0 := BA0->(Recno())
		BA0->(DbSetOrder(1))
		If BA0->(MsSeek(xFilial("BA0")+cOpeOri)) .And. BA0->BA0_ONLINE == "1" .And. GetNewPar("MV_PLSSOOL","1") == "1"
			If Aviso(	STR0068, ; //"Operadora Origem On-Line"
					STR0069,; //"Deseja confirmar este atendimento de intercambio eventual, sem efetuar a comunicação com outra operadora?"
					{ STR0070, STR0071}, 2 ) <> 1 //"Sim"###"Nao"
				Return(.F.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancelou a a comunicacao online, devo criticar os eventos                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Else
				If lEvolucao
			  		PLSAUTPTU(__aCdCri230,@oBrwBQV, @oBrwBQZ) 
				Else
					PLSAUTPTU(__aCdCri230,@oBrwPro, @oBrwCri)
			EndIf
			EndIf
		Endif
		BA0->(DbSetOrder(nOrdBA0))
		BA0->(DbGoTo(nRecBA0))
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Comunica PTU Online quando MV_PTGLOBO esta desativado - Internacao       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == K_Incluir .And. Len(aDadUsr) >= 45 .And. Type("M->BE4_COMUNI") == "C" .And. M->BE4_COMUNI == "0" .And. GetNewPar("MV_PTGLOBO","1") <> "1") .Or. ;
		(nOpc == K_Alterar .And. Len(aDadUsr) >= 45 .And. BE4->BE4_COMUNI <> "1" .And. GetNewPar("MV_PTGLOBO","1") <> "1" .And. GetNewPar("MV_PLSUNI","1") == "1")
	cOpeOri := aDadUsr[45]

	nOrdBA0 := BA0->(IndexOrd())
	nRecBA0 := BA0->(Recno())
	BA0->(DbSetOrder(1))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se operadora diferente realiza verifica se realiza solicitacao normal    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cOpeOri <> PLSINTPAD() .And. BA0->(MsSeek(xFilial("BA0")+cOpeOri)) .And. BA0->BA0_ONLINE == "1"
		If GetNewPar("MV_PLSSOOL","1") == "1" .And. MsgYesNo(STR0148)  //"Usuário de Intercâmbio Eventual, deseja realizar comunicação com a Operadora Origem?"
			
			If lEvolucao
				If !PLVerAnPTU(oBrwBQV,"BQV",nOpc,"BE4")//Verifica se ha item de anexo e guia correspondente
					lComunPTU := .F.		
			EndIf
	Else
				If !PLVerAnPTU(oBrwPro,"BEJ",nOpc,"BE4")//Verifica se ha item de anexo e guia correspondente
					lComunPTU := .F.		
				EndIf              
			EndIf
			
			If lComunPTU
				If !PLSAUTREM("BE4","BEJ","BEL",oBrwPro,oBrwCri,nOpc,.T.,.F.,@aResComuni,cAvisoRet,@cTrolComun)
					Return(.F.)
				EndIf  
			Else 
			  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   				//³ Nao realizou a comunicacao online devido a falta da guia de  ³
   				//³ anexo, devo criticar os eventos                              ³
	 			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lEvolucao
			 		PLSAUTPTU(__aCdCri230,@oBrwBQV, @oBrwBQZ)//Adiciona criticas por nao ter realizado a comunicacao Online
		  		Else
					PLSAUTPTU(__aCdCri230,@oBrwPro, @oBrwCri)//Adiciona criticas por nao ter realizado a comunicacao Online
	EndIf
			EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cancelou a a comunicacao online, devo criticar os eventos                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else         
			
			//Solicitacao Vale do Sinos - Se BE4_NRAOPE informado ou Guia de Baixo Risco, nao realiza a comunicacao e autoriza a Guia.
	  		If GetNewPar("MV_PLPTUAB","0") == "1" .And. nOpc == K_Incluir 
	  			If !Empty(M->BE4_NRAOPE) 
	  				lPTUAutom  := .T.
	  				cMsgPTUAut := STR0215  //"Os eventos serão autorizados automaticamente pois o campo 'Nr Aut Oper.' foi preenchido."
	  			ElseIf BR8->( FieldPos("BR8_RISCO") ) > 0 .And. PL90IteRis(oBrwPro) 
			  		lPTUAutom  := .T. 
			  		cMsgPTUAut := STR0216 //"Os eventos serão autorizados automaticamente pois a Guia é de Baixo Risco."
			  	EndIf	
            EndIf
			
			If nOpc == K_Evolucao
				PLSAUTPTU(__aCdCri230,@oBrwBQV090, @oBrwBQZ090)
			Else
				PLSAUTPTU(__aCdCri230,@oBrwPro, @oBrwCri,IIF(lPTUAutom,"2","1"))  
	   			If lPTUAutom
	   		   		Aviso( STR0096,cMsgPTUAut,{ STR0099 }, 2 )
	   		   	EndIf	
			EndIf	
Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se realiza solicitacao de ordem de servico                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf nOpc == K_Incluir .And. cOpeOri == PLSINTPAD()
		DbSelectArea("BAU")
	   	DbSetOrder(1)//BAU_FILIAL+BAU_CODIGO
	   	BAU->(DbSeek(xFilial("BAU")+&("M->BE4_CODRDA")))
	
	   	If BA0->(MsSeek(xFilial("BA0")+BAU->BAU_CODOPE)) .And. BA0->BA0_ONLINE == "1" .And. BAU->BAU_TIPPRE == "OPE"
	       
			nResOS := Aviso( STR0096,STR0149,{ STR0213,STR0214 }, 2 ) //"Atencao" //"RDA selecionada é outra Operadora, deseja realizar transação de Ordem de Serviço/Triangulação ou Solicitação Normal?""Os/Triang.","Sol. Normal"
			If nResOS == 1 .And. !PLSAUTREM("BE4","BEJ","BEL",oBrwPro,oBrwCri,nOpc,.T.,.F.,@aResComuni,cAvisoRet,@cTrolComun)
			 	Return(.F.)
			EndIf
	    EndIf
		BA0->(DbSetOrder(nOrdBA0))
		BA0->(DbGoTo(nRecBA0))
	Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se realiza solicitacao de ordem de servico                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nOpc == K_Incluir .And. GetNewPar("MV_PTGLOBO","1") <> "1"
	DbSelectArea("BAU")
   	DbSetOrder(1)//BAU_FILIAL+BAU_CODIGO
   	BAU->(DbSeek(xFilial("BAU")+&("M->BE4_CODRDA")))

   	If BA0->(MsSeek(xFilial("BA0")+BAU->BAU_CODOPE)) .And. BA0->BA0_ONLINE == "1" .And. BAU->BAU_TIPPRE == "OPE"
       
		nResOS := Aviso( STR0096,STR0149,{ STR0213,STR0214 }, 2 ) //"Atencao" //"RDA selecionada é outra Operadora, deseja realizar transação de Ordem de Serviço/Triangulação ou Solicitação Normal?""Os/Triang.","Sol. Normal"
		If nResOS == 1 .And. !PLSAUTREM("BE4","BEJ","BEL",oBrwPro,oBrwCri,nOpc,.T.,.F.,@aResComuni,cAvisoRet,@cTrolComun)
		 	Return(.F.)
		EndIf
    EndIf
	BA0->(DbSetOrder(nOrdBA0))
	BA0->(DbGoTo(nRecBA0))
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Evolucao e globo ativado mas nao foi realizada comunicacao PTU devido a falta de anexo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_PTGLOBO","1") == "1" .And. lEvolucao .And. Len(aDadUsr) >= 45 .And. Type("M->BE4_COMUNI") == "C" .And. M->BE4_COMUNI == "1" .And. aDadUsr[45] <> PLSINTPAD() .And. !lConf
	BA0->(DbSetOrder(1))
	If BA0->(MsSeek(xFilial("BA0")+aDadUsr[45])) .And. BA0->BA0_ONLINE == "1"  
		nPos := AScan(oBrwBQV:aHeader,{|x| x[2] == "BQV_NRTROL"})    
		For nFor := 1 to len(oBrwBQV:aCols) 
			If Empty(oBrwBQV:aCols[nFor][nPos])     
				lBQVSemCom := .T.
				Exit
			EndIf
		Next     
		If lBQVSemCom  
  	  		PLSAUTPTU(__aCdCri230,@oBrwBQV, @oBrwBQZ)//Adiciona criticas por nao ter realizado a comunicacao Online    
  	  	EndIf	
  	EndIf	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Comunica PTU Online quando MV_PTGLOBO esta desativado - Evolucao         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEvolucao .And. Len(aDadUsr) >= 45 .And. Type("M->BE4_COMUNI") == "C" .And. M->BE4_COMUNI == "1" .And. GetNewPar("MV_PTGLOBO","1") <> "1"
	cOpeOri := aDadUsr[45]

	If cOpeOri <> PLSINTPAD()
		nOrdBA0 := BA0->(IndexOrd())
		nRecBA0 := BA0->(Recno())
		BA0->(DbSetOrder(1))

		If BA0->(MsSeek(xFilial("BA0")+cOpeOri)) .And. BA0->BA0_ONLINE == "1" .And. GetNewPar("MV_PLSSOOL","1") == "1" .And. ;
				MsgYesNo(STR0148)//"Usuário de Intercâmbio Eventual, deseja realizar comunicação com a Operadora Origem?"
		      
		      //Verifica se ha item de anexo e guia correspondente
			If !PLVerAnPTU(oBrwBQV,"BQV",nOpc,"BE4")
				lComunPTU := .F.		
			EndIf              
	
			If lComunPTU  
              If !PLSAUTREM("BE4","BQV","BQZ",oBrwBQV,oBrwBQZ,nOpc,.F.,.T.,@aResComuni,cAvisoRet,@cTrolComun)
          	      Return(.F.)
              EndIf    
			Else   
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Nao realizou a comunicacao online devido a falta da guia de  ³
				//³ anexo, devo criticar os eventos                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
				PLSAUTPTU(__aCdCri230,@oBrwBQV, @oBrwBQZ)//Adiciona criticas por nao ter realizado a comunicacao Online
			EndIf    
		Else 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancelou a a comunicacao online, devo criticar os eventos                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PLSAUTPTU(__aCdCri230,@oBrwBQV, @oBrwBQZ)
		Endif

		BA0->(DbSetOrder(nOrdBA0))
		BA0->(DbGoTo(nRecBA0))
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao ou Alteracao Gravacao da prorrogacao						     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Visualizar .And. lEvolucao
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pega a ordem															 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOrdBE4 := BE4->( IndexOrd() )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no registro correto											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BE4->( DbSetOrder(2) )//BE4_FILIAL + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
	If !BE4->(MsSeek( xFilial("BE4")+M->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) )
		Aviso(STR0096,STR0101,{ STR0099 },2) //"Atenção"###"Cabeçalho da guia nao encontrado!"	###"OK"
		Return(.F.)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia transacao...                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava todos os bd6 e bd7												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 To Len(oBrwBQV:aCols)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Verifica se tem algum procedimento da auditoria participativa
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			If BR8->(FieldPos("BR8_PARTIC"))> 0 .And. !lPartic
				lPartic := Posicione("BR8",1,xFilial("BR8")+oBrwBQV:FieldGet("BQV_CODPAD",nI)+oBrwBQV:FieldGet("BQV_CODPRO",nI),"BR8_PARTIC") == '1'
			EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Checagem dos itens														 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If BQV->( FieldPos("BQV_STATUS") ) > 0 .And. BQV->( FieldPos("BQV_AUDITO") ) > 0  .And. BQV->( FieldPos("BQV_SENHA") ) > 0
				If oBrwBQV:FieldGet("BQV_STATUS",nI) == "1"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se a linha nao esta deletada											 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !oBrwBQV:aCols[nI,Len(oBrwBQV:aHeader)+1] .And. oBrwBQV:FieldGet("BQV_AUDITO",nI) <> "1"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inclui a Senha															 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty( oBrwBQV:FieldGet("BQV_SENHA",nI) )
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Gera a Senha "0" e muilt senhas "1" somente uma senha para todos os procedimento ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If cMultSen == "0"
								cSenhaPls := PLSSenAut(dDatInt)
							ElseIf cMultSen == "1" .And. lGerSen
								cSenhaPls := PLSSenAut(dDatInt)
								lGerSen   := .F.
							EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza a senha																 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							oBrwBQV:FieldPut("BQV_SENHA",cSenhaPls,nI)
							lMostSenha := .T.
						Else
							cSenhaPls := oBrwBQV:FieldGet("BQV_SENHA",nI)
						EndIf
					EndIf
				Else
					oBrwBQV:FieldPut("BQV_SENHA","",nI)
					cSenhaPls := ""
				EndIf
			EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Checagem dos itens														 ³
		//³ Se a linha nao esta deletada											 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !oBrwBQV:aCols[nI,Len(oBrwBQV:aHeader)+1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pega a Sequencia														 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cSequen := oBrwBQV:FieldGet("BQV_SEQUEN",nI)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a gravacao e pega a sequencia										 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If BQV->( FieldPos("BQV_HORPRO") ) > 0
					cSequen := A092BQVGIH(nOpc,cSenhaPls,oBrwBQV:FieldGet("BQV_CODPAD",nI),oBrwBQV:FieldGet("BQV_CODPRO",nI),;
						oBrwBQV:FieldGet("BQV_QTDPRO",nI),oBrwBQV:FieldGet("BQV_HORPRO",nI),cSequen,;
						oBrwBQV:FieldGet("BQV_NIVAUT",nI),oBrwBQV:FieldGet("BQV_NIVCRI",nI),oBrwBQV:FieldGet("BQV_CHVNIV",nI),,aMatCom,oBrwBQV:FieldGet("BQV_DATPRO",nI))
				EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a sequencia esta diferente dos itens no bd6					 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If oBrwBQV:FieldGet("BQV_SEQUEN",nI) <> cSequen
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza a sequencia do BQZ												 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					While Eval( {|| nPos := Ascan( oBrwBQZ:aCols,{|x| x[ PLRETPOS("BQZ_SEQUEN",oBrwBQZ:aHeader) ] == oBrwBQV:FieldGet("BQV_SEQUEN",nI) } ), nPos > 0} )
						oBrwBQZ:FieldPut("BQZ_SEQUEN",cSequen,nPos)
					EndDo
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza a sequencia do BQV												 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oBrwBQV:FieldPut("BQV_SEQUEN",cSequen,nI)
				EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava na matriz o procedimento e a senha								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lMostSenha
					AaDd( aDadSen, { oBrwBQV:FieldGet("BQV_CODPRO",nI)+" - "+oBrwBQV:FieldGet("BQV_DESPRO",nI), cSenhaPls} )
					lMostSenha := .F.
				EndIf
				If !lAuditoria .and. oBrwBQV:FieldGet("BQV_AUDITO",nI) =="1" // Verifica se há algum item para Auditoria
					lAuditoria := oBrwBQV:FieldGet("BQV_AUDITO",nI) =="1"
				Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada - Inclusao                                              ³
			//³ Ponto de entrada para permitir o cliente tratar campos criados e         ³
			//³ atualizar as demais tabelas                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  ExistBlock("PLS181GR")
					ExecBlock("PLS181GR",.F.,.F.,{"I",oBrwBQV})
				Endif
			Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se esta deletado e tem avettrav e pq ja gravou no bd6 e bd7				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If oBrwBQV:aVetTrab[nI] > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pega a sequencia														 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cSequen := oBrwBQV:FieldGet("BQV_SEQUEN",nI)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ordem e verifica se existe no bd6										 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					BD6->( DbSetOrder(1) )//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
					If BD6->( MsSeek( xFilial("BD6")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)+cSequen ) )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ordem e procura os bd7 para excluir										 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						BD7->(DbSetOrder(1))
						While BD7->( MsSeek(xFilial("BD7")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)+cSequen) )
							BD7->(RecLock("BD7",.F.))
							BD7->(DbDelete())
							BD7->(MsUnLock())
						Enddo
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ BD6																		 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						BD6->(RecLock("BD6",.F.))
						BD6->(DbDelete())
						BD6->(MsUnLock())
					Endif
				EndIf
			EndIf
		Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recno antes da gravacao													 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRecBQV := BQV->( Recno() )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Evolucao							   								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aChave := {}
		aadd(aChave,{"BQV_CODOPE",BE4->BE4_CODOPE})
		aadd(aChave,{"BQV_ANOINT",BE4->BE4_ANOPAG})
		aadd(aChave,{"BQV_MESINT",BE4->BE4_MESPAG})
		aadd(aChave,{"BQV_NUMINT",BE4->BE4_NUMINT})
		aadd(aChave,{"BQV_OPEUSR",BE4->BE4_OPEUSR})
		aadd(aChave,{"BQV_CODEMP",BE4->BE4_CODEMP})
		aadd(aChave,{"BQV_MATRIC",BE4->BE4_MATRIC})
		aadd(aChave,{"BQV_TIPREG",BE4->BE4_TIPREG})
		aadd(aChave,{"BQV_DIGITO",BE4->BE4_DIGITO})
		oBrwBQV:Consiste()
		oBrwBQV:Grava(aChave,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Critica da Evolucao												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aChave := {}
		aadd(aChave,{"BQZ_CODOPE",BE4->BE4_CODOPE})
		aadd(aChave,{"BQZ_ANOINT",BE4->BE4_ANOINT})
		aadd(aChave,{"BQZ_MESINT",BE4->BE4_MESINT})
		aadd(aChave,{"BQZ_NUMINT",BE4->BE4_NUMINT})
		oBrwBQZ:nOpc := nOpc
		oBrwBQZ:Consiste()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para que não ocorra n chkunique na tabela BQZ³
	//³pois o campo BQZ_SEQCRI tem que ser incrimental         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If BQZ->( FieldPos("BQZ_SEQCRI") ) > 0
		BQZ->(DbSetOrder(1))
	    If BQZ->(DbSeek(xFilial("BQZ")+BE4->BE4_CODOPE+BE4->BE4_ANOPAG+BE4->BE4_MESPAG+BE4->BE4_NUMINT))
	        While BQZ->(!Eof()) .and. BQZ->(BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT)==(xFilial("BQZ")+BE4->BE4_CODOPE+BE4->BE4_ANOPAG+BE4->BE4_MESPAG+BE4->BE4_NUMINT)
	        	if cSeqCri < BQZ->BQZ_SEQCRI
	        		cSeqCri := BQZ->BQZ_SEQCRI
	        	endif
	        	BQZ->(DbSkip())
	        Enddo
	       	cSeqCri := Soma1(cSeqCri)
	    Endif

		For nI:=1 to Len(oBrwBQZ:Acols)
			oBrwBQZ:FieldPut("BQZ_SEQCRI",cSeqCri,nI)
			oBrwBQZ:FieldPut("BQZ_CODOPE",BE4->BE4_CODOPE,nI)
			cSeqCri := Soma1(cSeqCri)
		next nI
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Ajusta aCols eliminando registros em branco  		     				 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 to len(oBrwBQZ:aCols)
			If Empty(oBrwBQZ:aCols[nI][aScan(oBrwBQZ:aHeader,{|x|x[2] == "BQZ_CODGLO"})]) .And. ;
					Empty(oBrwBQZ:aCols[nI][aScan(oBrwBQZ:aHeader,{|x|x[2] == "BQZ_DESGLO"})]) .And. ;
					Empty(oBrwBQZ:aCols[nI][aScan(oBrwBQZ:aHeader,{|x|x[2] == "BQZ_INFGLO"})])

				oBrwBQZ:aCols[nI][len(oBrwBQZ:aHeader)+1] := .T.
			EndIf
		Next

		oBrwBQZ:Grava(aChave,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao dos itens do pacote na evolucao								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If PLSALIASEXI("B43")
			aChave := {}
			aadd(aChave,{"B43_CODOPE",BE4->BE4_CODOPE})
			aadd(aChave,{"B43_CODLDP",BE4->BE4_CODLDP})
			aadd(aChave,{"B43_CODPEG",BE4->BE4_CODPEG})
			aadd(aChave,{"B43_NUMERO",BE4->BE4_NUMERO})
			aadd(aChave,{"B43_ORIMOV",BE4->BE4_ORIMOV})
			aadd(aChave,{"B43_OPEMOV",BE4->BE4_CODOPE})
			aadd(aChave,{"B43_ANOAUT",BE4->BE4_ANOPAG})
			aadd(aChave,{"B43_MESAUT",BE4->BE4_MESPAG})
			aadd(aChave,{"B43_NUMAUT",BE4->BE4_NUMINT})
			PLUPTCOLS("B43",aDadB43,aCabB43,aTrbB43,nOpc,aChave,.T.)
		Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada - Alteracao                                             ³
	//³ Ponto de entrada para permitir o cliente tratar campos criados e         ³
	//³ atualizar as demais tabelas                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  ExistBlock("PLS181GR")
			ExecBlock("PLS181GR",.F.,.F.,{"A",oBrwBQV})
		Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza qtd diarias													 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BE4->( RecLock("BE4", .F.) )
		aDiaPrs := PLSDIARLIB()
		If BE4->( FieldPos("BE4_DIASIN") ) > 0
			BE4->BE4_DIASIN := M->BE4_DIASIN
		EndIf
		If BE4->( FieldPos("BE4_DIASPR") ) > 0
			BE4->BE4_DIASPR := aDiaPrs[1] + aDiaPrs[2]
		EndIf
		If Type("BE4_PRORRO") <> "U"
			BE4->BE4_PRORRO := M->BE4_PRORRO
		EndIf
		// Atualiza Quantidade de Diarias Solicitadas - TISS
		IF BE4->( FieldPos("BE4_DIASSO") ) > 0
			BE4->BE4_DIASSO := M->BE4_DIASSO
		EndIf

		//BAU_GRALAU = 1 - Grava data de alta automatica
		If BAU->(FieldPos("BAU_GRALAU")) > 0 .And. BAU->BAU_GRALAU == "1"
			BE4->BE4_DTALTA := dDatInt + aDiaPrs[1] + aDiaPrs[2]
			BE4->BE4_HRALTA := Left(StrTran(Time(),":",""),5)
		EndIf

		BE4->( MsUnLock() )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza anexos do PTU se houver                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cTrolComun) .And. GetNewPar("MV_PLSUNI","0") == "1" .And. (nOpc == K_Alterar .Or. nOpc == K_Evolucao) .And. ;
		B4C->( FieldPos("B4C_COMUNI") ) > 0 .and. B4C->( FieldPos("B4C_NRTROL") ) > 0 .and. B4C->( FieldPos("B4C_NRAOPE") ) > 0
	   
		B4A->( DbSetOrder(4) )//B4A_FILIAL + B4A_GUIREF
		If B4A->( msSeek( xFilial("B4A") + BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ) ) 
			BEA->(DbSetOrder(1))//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BEA_DATPRO+BEA_HORPRO
			BEA->(MsSeek(xFilial("BEA")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ))
	    	PLPTUAtAne(oBrwBQV:aHeader,oBrwBQV:aCols,oBrwBQZ:aHeader,oBrwBQZ:aCols,"BQV","BQZ",cTrolComun,BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),nil,nOpc,.F.)
	    EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza transacao...                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	End Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Coloca o be4 no lugar													 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BE4->(DbSetOrder(nOrdBE4))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Verifico se o registro inserido esta em auditoria
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	lNewReg    := nRecBQV <> BQV->( Recno() )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Se alias exisitr e for auditoria e nao veio do ptu-online
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If PLSALIASEXI("B53") .And. FindFunction("PLSA790C") .and. FindFunction("PLSREGIC") .and. lNoComuOnl .And. lNewReg .And. (lAuditoria .Or. lPartic)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o procedimento tem crítica, mas não é de auditoria
		//	as criticas que são enviadas para a tabela de críticas da auditoria
		//	são retiradas.                   												³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQtdPrc := Len(oBrwPro:aCols)
		nQtdCri := LEN(oBrwBQZ:aCols)

		for nPr := 1 To nqtdPrc
			If oBrwPro:aCols[nPr][GdFieldPos("BEJ_AUDITO",oBrwPro:aHeader)] != "0"

				For nCr:= 1 To nQtdCri
					If oBrwBQZ:aCols[nCr][GdFieldPos("BEL_SEQUEN",oBrwBQZ:aHeader)] == oBrwPro:aCols[nPr][GdFieldPos("BEJ_SEQUEN",oBrwPro:aHeader)]

						aadd(aColsCri,oBrwBQZ:aCols[nCr])
					EndIf
				Next
			EndIf
		Next

		o790C := PLSA790C():New()
		o790C:SetAuditoria(lAuditoria,.T.,lEvolucao,.F.,lPartic,aColsCri,oBrwBQZ:aHeader,__aCdCri187[1],BE4->BE4_REGINT,"BQZ",oBrwPro:aCols,oBrwPro:aHeader,"BEJ")
		o790C:Destroy()
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Gravacao ou Altercao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ElseIf nOpc <> K_Visualizar .And. !lEvolucao
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Quando for uma exclusao de intercambio e foi solicitado autorizacao
	//³ online vai entrar na funcao PLSASOEEXE para solicitar a exclusao
	//³ lRet inicia como .T. para que possa seguir o processo nomal caso nao entre
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If nOpc == K_Excluir .And. ( Type("BE4_COMUNI") == "C" .And. Type("BE4_MSG04") == "C" .And. Type("BE4_NRTROL") == "C" .And. Type("BE4_VIACAR") == "N" ) .And. M->BE4_COMUNI == "1"
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Na versao 5.0 do PTU Online, preciso enviar o Motivo do Cancelamento        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		aRetDesCan := PLSCANCCOM() 
    	If Empty(aRetDesCan[1])
    		MsgInfo(STR0204) //"Para a versão 5.0 ou superior do PTU Online, é obrigatório o preenchimento do motivo de cancelamento."
    		Return(.F.)
    	EndIf

		lRet := PLSASOEEXE("BE4",.F.,.F.,,,,aRetDesCan[1])
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Somente se tiver sucesso na comunicacao para os casos online
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Abre semaforo
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Matriz bea
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		aadd(aDadBEA,{"BEA_PACOTE","0"})
		aadd(aDadBEA,{"BEA_ORIMOV","2"})
		aadd(aDadBEA,{"BEA_TIPO","3"})
		If BE4->( FieldPos("BE4_TRACON") ) > 0
			AaDd(aDadBEA,{"BEA_TRACON",M->BE4_TRACON})
		EndIf
		aadd(aDadBEA,{"BEA_SIGEXE",M->BE4_SIGLA})
		aadd(aDadBEA,{"BEA_DESOPE",PLRETOPE()})
		aadd(aDadBEA,{"BEA_USUOPE",PLSRtCdUsr()})
		aadd(aDadBEA,{"BEA_TIPPAC",GetNewPar("MV_PLSTPAA","1")})
		aadd(aDadBEA,{"BEA_CODLOC",BB8->(Posicione("BB8",1,xFilial("BB8")+M->BE4_CODRDA+cCodOpe+M->BE4_CODLOC,"BB8_CODLOC"))})
		aadd(aDadBEA,{"BEA_LOCAL" ,BB8->BB8_LOCAL})
		aadd(aDadBEA,{"BEA_DESLOC",BB8->BB8_DESLOC})
		aadd(aDadBEA,{"BEA_ENDLOC",AllTrim(BB8->BB8_END)+"+"+AllTrim(BB8->BB8_NR_END)+"-"+AllTrim(BB8->BB8_COMEND)+"-"+AllTrim(BB8->BB8_BAIRRO)})
		aadd(aDadBEA,{"BEA_CODESP",M->BE4_CODESP})
		aadd(aDadBEA,{"BEA_DESESP",M->BE4_DESESP})
		aadd(aDadBEA,{"BEA_NOMTIT",aDadUsr[6]})
		aadd(aDadBEA,{"BEA_OPEUSR",Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])})
		aadd(aDadBEA,{"BEA_CODEMP",Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])})
		aadd(aDadBEA,{"BEA_MATRIC",Subs(aDadUsr[2],atMatric[1],atMatric[2])})
		aadd(aDadBEA,{"BEA_TIPREG",Subs(aDadUsr[2],atTipReg[1],atTipReg[2])})
		aadd(aDadBEA,{"BEA_CONEMP",aDadUsr[9]})
		aadd(aDadBEA,{"BEA_VERCON",aDadUsr[39]})
		aadd(aDadBEA,{"BEA_SUBCON",aDadUsr[41]})
		aadd(aDadBEA,{"BEA_VERSUB",aDadUsr[42]})
		aadd(aDadBEA,{"BEA_CPFUSR",BA1->BA1_CPFUSR})
		aadd(aDadBEA,{"BEA_IDUSR",BA1->BA1_DRGUSR})
		aadd(aDadBEA,{"BEA_DATNAS",aDadUsr[26]})
		aadd(aDadBEA,{"BEA_DIGITO",Subs(aDadUsr[2],atDigito[1],atDigito[2])})
		aadd(aDadBEA,{"BEA_OPEINT",cCodOpe})
		aadd(aDadBEA,{"BEA_OPEMOV",cCodOpe})
		aadd(aDadBEA,{"BEA_HORPRO",M->BE4_HORPRO})
		aadd(aDadBEA,{"BEA_ANOPAG",M->BE4_ANOPAG})
		aadd(aDadBEA,{"BEA_MESPAG",M->BE4_MESPAG})
		aadd(aDadBEA,{"BEA_ATEAMB",If(AllTrim(Str(Val(M->BE4_TIPINT)))=="1","1","0")})
		If BE4->(FieldPos("BE4_ATERNA")) > 0
			If !Empty(M->BE4_ATERNA)
				aadd(aDadBEA,{"BEA_ATERNA",M->BE4_ATERNA})
			Else
				aadd(aDadBEA,{"BEA_ATERNA","0"})
			EndIf
		Endif

		If nOpc == K_Incluir .Or. Empty(M->BE4_DATPRO)
			aadd(aDadBEA,{"BEA_DATPRO",dDataBase})
		Else
			aadd(aDadBEA,{"BEA_DATPRO",M->BE4_DATPRO})
		Endif

		If GetNewPar("MV_PLSGRSN","1") == "1"
			aadd(aDadBEA,{"BEA_SENHA",PLSSenAut(M->BE4_DATPRO)})
		Else
			aadd(aDadBEA,{"BEA_SENHA",""})
		Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ajusta outros campos na matriz adadbea									 			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nFor := 1 To Len(aStruBE4)

			cCpoAux := "BEA_"+Subs(aStruBE4[nFor,1],5,10)
			If Type("BEA->"+cCpoAux) <> "U" .And. Type("M->"+aStruBE4[nFor,1]) <> "U"
				If (nPos := Ascan(aDadBEA,{|x| x[1] == cCpoAux})) == 0
					AaDd(aDadBEA,{cCpoAux,&( "M->" + aStruBE4[nFor,1] ) } )
				EndIf
			Endif


			If  Type(aStruBE4[nFor,1]) <> "U"
				If (nPos := Ascan(aDadBE4,{|x| x[1] == aStruBE4[nFor,1]})) == 0 .And. Type("M->"+aStruBE4[nFor,1]) <> "U"
					AaDd(aDadBE4,{aStruBE4[nFor,1],&( "M->" + aStruBE4[nFor,1] ) } )
				EndIf
			Endif
		Next
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Item BE2																 						³
			//³ Tenho que montar um aCols e aHeader como se fosse uma getdados...        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aChaveGen,{"BE2_TPGRV","1"})
		aadd(aChaveGen,{"BE2_LIBESP","0"})
		aadd(aChaveGen,{"BE2_TIPRDA",BAU->BAU_TIPPE})
		aadd(aChaveGen,{"BE2_IDUSR",BA1->BA1_DRGUSR})
		aadd(aChaveGen,{"BE2_DATNAS",BA1->BA1_DATNAS})
		aadd(aChaveGen,{"BE2_CPFRDA",BAU->BAU_CPFCGC})
		aadd(aChaveGen,{"BE2_CID",M->BE4_CID})
		aadd(aChaveGen,{"BE2_HORPRO",M->BE4_HORPRO})
		aadd(aChaveGen,{"BE2_OPERDA",M->BE4_OPERDA})
		aadd(aChaveGen,{"BE2_CODRDA",M->BE4_CODRDA})
		aadd(aChaveGen,{"BE2_CODLOC",M->BE4_CODLOC})
		aadd(aChaveGen,{"BE2_LOCAL",M->BE4_LOCAL})
		aadd(aChaveGen,{"BE2_CODESP",M->BE4_CODESP})
		aadd(aChaveGen,{"BE2_OPEUSR",Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])})
		aadd(aChaveGen,{"BE2_CODEMP",Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])})
		aadd(aChaveGen,{"BE2_MATRIC",Subs(aDadUsr[2],atMatric[1],atMatric[2])})
		aadd(aChaveGen,{"BE2_TIPREG",Subs(aDadUsr[2],atTipReg[1],atTipReg[2])})
		aadd(aChaveGen,{"BE2_CONEMP",aDadUsr[9]})
		aadd(aChaveGen,{"BE2_VERCON",aDadUsr[39]})
		aadd(aChaveGen,{"BE2_SUBCON",aDadUsr[41]})
		aadd(aChaveGen,{"BE2_VERSUB",aDadUsr[42]})
		aadd(aChaveGen,{"BE2_ENDLOC",AllTrim(BB8->BB8_END)+"+"+AllTrim(BB8->BB8_NR_END)+"-"+AllTrim(BB8->BB8_COMEND)+"-"+AllTrim(BB8->BB8_BAIRRO)})
		aadd(aChaveGen,{"BE2_DESLOC",BB8->BB8_DESLOC})
		aadd(aChaveGen,{"BE2_ATEAMB",If(AllTrim(Str(Val(M->BE4_TIPINT)))=="1","1","0")})
		aadd(aChaveGen,{"BE2_MATVID",M->BE4_MATVID})
		aadd(aChaveGen,{"BE2_SIGEXE",M->BE4_SIGLA})
		aadd(aChaveGen,{"BE2_SIGLA",M->BE4_SIGLA})
		aadd(aChaveGen,{"BE2_ESTSOL",M->BE4_ESTSOL})
		aadd(aChaveGen,{"BE2_REGSOL",M->BE4_REGSOL})
		aadd(aChaveGen,{"BE2_NOMSOL",M->BE4_NOMSOL})
		aadd(aChaveGen,{"BE2_DIGITO",Subs(aDadUsr[2],atDigito[1],atDigito[2])})
		aadd(aChaveGen,{"BE2_MATANT",M->BE4_MATANT})
		aadd(aChaveGen,{"BE2_NOMUSR",M->BE4_NOMUSR})

		If nOpc == K_Incluir .Or. nOpc == K_Alterar
			If     ! Empty(M->BE4_PRVINT)
				aadd(aChaveGen,{"BE2_DATPRO",M->BE4_PRVINT})
			ElseIf ! Empty(M->BE4_DATPRO)
				aadd(aChaveGen,{"BE2_DATPRO",M->BE4_DATPRO})
			Else
				aadd(aChaveGen,{"BE2_DATPRO",dDataBase})
			Endif
		Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando o tipo de entrada do paciente for 4 indica que é risco     ³
			//³de vida e a data de internação é informado no momento da inclusão.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nOpc == K_Incluir
			If Alltrim(M->BE4_TIPADM)="4"
				AaDd(aDadBE4,{"BE4_DATPRO",M->BE4_DATPRO} )
				AaDd(aDadBE4,{"BE4_HORPRO",M->BE4_HORPRO} )
			Endif
		Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Gravacao GRV
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		aColBEJ := aClone(oBrwPro:aCols)
		aHeaBEJ := aClone(oBrwPro:aHeader)
		aVtaBEJ := aClone(oBrwPro:aVetTrab)
		nOpca   := oBrwPro:nOpc

		If FindFunction("PLSA790C") .And. PLSALIASEXI("B53")
			nQtdPrc := Len(oBrwPro:aCols)
			nQtdCri := LEN(oBrwCri:aCols)

			for nPr := 1 To nqtdPrc
//					esse item foi retirado devido ter criticas E devemos que preencher o folder de criticas mesmo sem prencher  BEJ_AUDITO
//					If oBrwPro:aCols[nPr][GdFieldPos("BEJ_AUDITO",oBrwPro:aHeader)] != "0"

				For nCr:= 1 To nQtdCri
					If oBrwCri:aCols[nCr][GdFieldPos("BEL_SEQUEN",oBrwCri:aHeader)] == oBrwPro:aCols[nPr][GdFieldPos("BEJ_SEQUEN",oBrwPro:aHeader)]

						aadd(aColBEL,oBrwCri:aCols[nCr])
					EndIf
				Next
//					EndIf
			Next
		Else

			aColBEL := aClone(oBrwCri:aCols)
		EndIf

		aHeaBEL := aClone(oBrwCri:aHeader)
		aVtaBEL := aClone(oBrwCri:aVetTrab)

		oBrwPro:= nil
		oBrwCri:= nil

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Gravacao GRV
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			aRet := PLSA090Grv( aColBEJ,aHeaBEJ,aDadBEA,nOpca,aVtaBEJ,aChaveGen,M->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO),;
									If(!Empty(M->BE4_DATPRO),M->BE4_DATPRO,dDataBase),M->BE4_HORPRO,M->BE4_MATUSA,M->BE4_ANOPAG,M->BE4_MESPAG,;
									GetNewPar("MV_PLSTPGI","03"),.T.,aColBEL,aHeaBEL,aVtaBEL,,nil,Iif(GetNewPar("MV_PLSDTPG",.F.),GetNewPar("MV_PLSLLIB","9999"),""),;
									,,"BE4",,,lNMudFase,"BEJ","BEL",.F.,.F.,aDadBE4,nil,NIL,aDadB43,aCabB43,aTrbB43,,,,,,,,,,,,,,,,,,aMatCom,;
									,,,,,,,,,,,,,,,,M->BE4_NRTROL,M->BE4_NRAOPE,,,,,,,,,,oGetBZC,cTrolComun)
									 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Fecha Semaforo
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe log do PTU quando globo de comunicacao esta desativado             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_PTGLOBO","1") <> "1"
	If !Empty(cAvisoRet)
		Aviso( STR0096, cAvisoRet , { STR0099 }, 2 )
	EndIf
	If len(aResComuni) > 0
		BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		If BA1->(DbSeek(xFilial("BA1")+M->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)))
			PTUResCom(aResComuni[1],aResComuni[2],aResComuni[3],aResComuni[4],aResComuni[5],aResComuni[6],aResComuni[7],aResComuni[8],BA1->(Recno()),.T.)
		EndIf
	EndIf
Endif
BEA->(DBSETORDER(1))
IF BEA->(DBSEEK(XFILIAL("BEA")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
	IF BEA->BEA_STATUS <> BE4->BE4_STATUS
		RECLOCK("BEA")
		BEA->BEA_STATUS := BE4->BE4_STATUS
		MSUNLOCK()
	ENDIF
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetorno := {Iif(!lEvolucao,BE4->BE4_SENHA,cSenhaPls),BE4->BE4_CODOPE,BE4->BE4_ANOINT,BE4->BE4_MESINT,BE4->BE4_NUMINT,Iif(Len(aRet)>=10,aRet[10],""),Iif(Len(aRet)>=9,aRet[9],.F.),Iif(!lEvolucao, AaDd( aDadSen, { BE4->BE4_SENHA}),aDadSen)} //aRet[9] == lAutidoria aRet[10] == cStatus
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS092VDC ³ Autor ³ Alexander			³ Data ³ 01.09.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida linha	do brw itens								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PLS092VDC()
LOCAL lRet := .T.

//Não permiti alterar os campos da guia
PLS092RONL(.T.,oEncInt)

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSDIARLIB ³ Autor ³ Alexander Santos    ³ Data ³ 29.11.06 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Diarias Autorizadas										  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSDIARLIB()
LOCAL nI
LOCAL nDAut   := 0
LOCAL nDSol   := 0
LOCAL nDPro   := 0
LOCAL lUmIte  := .F.


BR8->( DbSetOrder(1) )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera variavies															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDiarAp	:= {0,0}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Internacao																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(oBrwPro) <> 'U'
	For nI := 1 To Len(oBrwPro:aCols)
		If !oBrwPro:aCols[nI,Len(oBrwPro:aHeader)+1] .And. oBrwPro:aCols[nI,PLRETPOS("BEJ_STATUS",oBrwPro:aHeader)] == '1' .And. BR8->( MsSeek( xFilial("BR8")+oBrwPro:aCols[nI,PLRETPOS("BEJ_CODPAD",oBrwPro:aHeader)]+oBrwPro:aCols[nI,PLRETPOS("BEJ_CODPRO",oBrwPro:aHeader)]) )
			If BR8->BR8_TPPROC == "4"
				nDAut += oBrwPro:aCols[nI,PLRETPOS("BEJ_QTDPRO",oBrwPro:aHeader)]
				nDSol += oBrwPro:aCols[nI,PLRETPOS("BEJ_QTDSOL",oBrwPro:aHeader)]
			Endif
		Endif
	Next
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Evolucao																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(oBrwBQV) <> 'U'
	For nI := 1 To Len(oBrwBQV:aCols)
		If BQV->( FieldPos("BQV_STATUS") ) > 0
			If !oBrwBQV:aCols[nI,Len(oBrwBQV:aHeader)+1] .And. oBrwBQV:aCols[nI,PLRETPOS("BQV_STATUS",oBrwBQV:aHeader)] == '1' .And. BR8->( MsSeek( xFilial("BR8")+oBrwBQV:aCols[nI,PLRETPOS("BQV_CODPAD",oBrwBQV:aHeader)]+oBrwBQV:aCols[nI,PLRETPOS("BQV_CODPRO",oBrwBQV:aHeader)]) )
				If BR8->BR8_TPPROC == "4"
					nDPro += oBrwBQV:aCols[nI,PLRETPOS("BQV_QTDPRO",oBrwBQV:aHeader)]
				Endif
			Endif
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se tem pelo menos um 1 item										 		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !oBrwBQV:aCols[nI,Len(oBrwBQV:aHeader)+1] .And. !Empty(oBrwBQV:aCols[nI,PLRETPOS("BQV_CODPRO",oBrwBQV:aHeader)])
		   lUmIte := .T.
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Nova prorrogação de internação																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(oBrwB4Q) <> 'U'
	For nI := 1 To Len(oBrwB4Q:aCols)
		If !oBrwB4Q:aCols[nI,Len(oBrwB4Q:aHeader)+1] .And. (oBrwB4Q:aCols[nI,PLRETPOS("B4Q_STATUS",oBrwB4Q:aHeader)] == '1' .OR. oBrwB4Q:aCols[nI,PLRETPOS("B4Q_STATUS",oBrwB4Q:aHeader)] == '2') .And. oBrwB4Q:aCols[nI,PLRETPOS("B4Q_QTDADA",oBrwB4Q:aHeader)] > 0 
			nDPro += oBrwB4Q:aCols[nI,PLRETPOS("B4Q_QTDADA",oBrwB4Q:aHeader)] 
			lUmIte := .T.
		Endif
	Next
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza campos	QTD DIARIAS AUTORIZADAS									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("BE4_DIASIN") <> "U"
   M->BE4_DIASIN := nDAut
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza campos	QTD DIARIAS SOLICITADAS - TISS									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("BE4_DIASSO") <> "U"
   M->BE4_DIASSO := nDSol
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza campos	QTD DIARIAS EVOLUCAO									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("BE4_DIASPR") <> "U"
   M->BE4_DIASPR := nDPro
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se existe algum procedimento na evolucao(prorrogacao					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("BE4_PRORRO") <> "U" .And. lUmIte
   M->BE4_PRORRO := "1"
Else
   M->BE4_PRORRO := "0"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza obj principal													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(oEncInt) <> 'U' 	.And. ValType(oEncInt:OBOX) <> 'U'//Na hora da internacao eu nao tenho a tela
	oEncInt:Refresh()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return( {nDAut,nDPro, nDSol} )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSDIASINT ³ Autor ³ Alexander			³ Data ³ 29.11.06 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Dias Internados...                                         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSDIASINT()
LOCAL nDatRet := 0

If !Empty(BE4->BE4_DATPRO)
	If Empty(BE4->BE4_DTALTA)
	   nDatRet := dDataBase - BE4->BE4_DATPRO
	Else
		If BE4->BE4_DTALTA <=dDataBase
	  		nDatRet := BE4->BE4_DTALTA - BE4->BE4_DATPRO
	  	Else
	  		nDatRet := dDataBase - BE4->BE4_DATPRO
	  	Endif
	Endif
	If nDatRet == 0
	   nDatRet := 1
	ElseIf nDatRet < 1
	   nDatRet := 0
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nDatRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PlsNDelAt ³ Autor ³ Alexander		    ³ Data ³ 16.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Nao deixa deletar ou atualiza amatrix de qtd de diarias	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PlsNDelAt(ln)
LOCAL cChave := M->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)
LOCAL cCodTran  := ""
LOCAL nPosTran  := 0
LOCAL nI        := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se ja comunicacao ja realizada, nao permite realizar a delecao					 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lConf
    MsgInfo(STR0147)//"Comunicação já realizada, não é possível realizar esta ação."
    Return .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se ja comunicou nao deixa deletar												 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(oBrwBQV) <> 'U'
	
	cChave += oBrwBQV:FieldGet("BQV_SEQUEN")+oBrwBQV:FieldGet("BQV_CODPAD")+oBrwBQV:FieldGet("BQV_CODPRO")
	
	//Verifica se o procedimento ja esta no contas medicas	
	BD6->( DbSetOrder(1) ) //BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
	If BD6->( MsSeek( xFilial("BD6")+cChave ) )

		// Se foi realizada pelo remote, nao foi importada, item da evolucao nao foi impresso, nao foi contabilizado
		If BD6->BD6_TPGRV == "1" .And. Empty(BE4->BE4_ARQIMP) .And. Empty(oBrwBQV:FieldGet("BQV_SEQIMP")) .And. !PLCHKCTB('D',BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN))

	        //³ Se comunicao online, verifica itens ja marcados para exclusao					 |
	 		If BE4->BE4_COMUNI == "1" .And. BQV->( FieldPos("BQV_NRTROL") ) > 0

	 		    nPosTran := aScan(oBrwBQV:aHeader,{|x| alltrim(x[2]) == "BQV_NRTROL"})

	            For nI := 1 to len(oBrwBQV:aCols)
	 		        If oBrwBQV:aCols[nI][len(oBrwBQV:aHeader)+1]
	 		            cCodTran := oBrwBQV:aCols[nI][nPosTran]
	 		            Exit
	 		        EndIf
	 		    Next

	 		    If Empty(cCodTran) .Or. cCodTran == oBrwBQV:FieldGet("BQV_NRTROL")
	 		        Return .T.
	 		    Else
	 		        MsgInfo(STR0203) //"Registro com transação diferente de um registro já marcado para exclusão (Nr. Tr. OnLine)"
	 		        Return .F.
	 		    EndIf
	 		Else
	 		    Return .T.
	 		EndIf
	    Else
	 		Return .F.
	 	EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for .T. atualiza diarias na delecao .f. nao deixa deletar					 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ln
   Eval(bAtuDiar)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina																	 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return ln
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLVLDBQVLI³ Autor ³ Alexander		    ³ Data ³ 16.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida linha												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/
Function PLVLDBQVLI()
LOCAL lRet := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida linha se data															 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  BQV->( FieldPos("BQV_DATPRO") ) > 0 .And. M->BQV_DATPRO < BE4->BE4_DATPRO .and. GetNewPar("MV_PLLBALT",.F.)
	Aviso(STR0096,STR0109,{ STR0099 },2) //"Atenção"###"Data da evolucao anterior a data de internacao!"###"OK"
	lRet := .F.
EndIf

If lEvolucao .and. GetNewPar("MV_PLLBALT",.F.) // Parametro que define que mesmo com a data de alta poderá ser feito a inclusão de evolução no periodo.
	If  BQV->( FieldPos("BQV_DATPRO") ) > 0 .And.  (M->BQV_DATPRO <  BE4->BE4_DATPRO/*dt interna*/ .Or.   M->BQV_DATPRO > BE4->BE4_DTALTA/*dt. alta*/)
		 Aviso(STR0096,STR0173,{ STR0099 },2) //"Atenção"###"Data da evolucao fora do período de internação e alta!"!"###"OK"  
		lRet := .F.
	EndIf
Endif


//Tratamento para que o sistema verifique se na evolução o sistema não deixa alterar procedimento que ja foram auditados
 If GetNewPar("MV_PL790NE","0") == "1" // Utiliza nova auditoria 
	B53->(DbGotop())
	If B53->(DbSeek(xFilial("B53")+BE4->(BE4_OPERDA+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
		If B72->(DbSeek(xFilial("B72")+"BE4"+B53->B53_RECMOV+M->BQV_SEQUEN))
			While B72->(!Eof()) .and. B72->(B72_FILIAL+B72_ALIMOV+B72_RECMOV+B72_SEQPRO)==(xFilial("B72")+"BE4"+B53->B53_RECMOV+M->BQV_SEQUEN)
				If B72->B72_CODPRO == M->BQV_CODPRO
					Aviso(STR0096,STR0174,{ STR0099 },2) //"Atenção"###"Esse item já foi auditado, não poderá ser alterado!""###"OK"
					lRet:=.F.
				Endif
				B72->(DbSkip())
			Enddo
		Endif
	Endif
Endif


Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSCHKIMP ³ Autor ³ Alexander		    ³ Data ³ 16.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ CHECA SE O PROCEDIMENTO JA FOI IMPRESSO					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PLSCHKIMP(dDatAlt)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ja imprimiu															 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( BQV->( FieldPos("BQV_SEQIMP") ) > 0 .And. BQV->( FieldPos("BQV_COMUNI") ) > 0 ) .And.;
   ( !Empty(oBrwBQV:FieldGet("BQV_SEQIMP")) .Or. !Empty(dDatAlt) .Or. oBrwBQV:FieldGet("BQV_COMUNI") == "1" .Or.;
   /*!Empty(oBrwBQV:FieldGet("BQV_SENHA")) .Or.*/ ( BE4->( FieldPos("BE4_NRTROL") ) > 0 .And.;
    BE4->( FieldPos("BE4_NRAOPE") ) > 0 .And. !Empty(BE4->BE4_NRTROL) .And. Empty(BE4->BE4_NRAOPE) ) ) .And.;
   ( BAU->(FieldPos("BAU_GRALAU")) <= 0 .Or. (BAU->BAU_GRALAU <> "1" .Or.(lEvolucao .And. !Empty(oBrwBQV:FieldGet("BQV_CODPRO") )) ))
	
	If lEvolucao .and. GetNewPar("MV_PLLBALT",.T.) // Parametro que define que mesmo com a data de alta poderá ser feito a inclusão de evolução no periodo.
		oBrwBQV:EditRecord("BQV",K_Alterar, STR0082, oBrwBQV:Linha(), oBrwBQV:oBrowse:aCols, oBrwBQV:oBrowse:aHeader,oBrwBQV:bAfterEdit,oBrwBQV:bMultaCols,oBrwBQV:bAftCancel )
		//oBrwBQV:cVldLine   	:= "PLVLDBQVLI() .And. P092DUPADD('oBrwBQV','BQV')"
	Else 
   		oBrwBQV:EditRecord("BQV",K_Visualizar, STR0082, oBrwBQV:Linha(), oBrwBQV:oBrowse:aCols, oBrwBQV:oBrowse:aHeader,oBrwBQV:bAfterEdit,oBrwBQV:bMultaCols,oBrwBQV:bAftCancel )
	Endif
Else
   oBrwBQV:EditRecord("BQV",K_Alterar, STR0082, oBrwBQV:Linha(), oBrwBQV:oBrowse:aCols, oBrwBQV:oBrowse:aHeader,oBrwBQV:bAfterEdit,oBrwBQV:bMultaCols,oBrwBQV:bAftCancel )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina																	 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bAtuDiar)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina																	 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSCANCEL ³ Autor ³ Alexander		    ³ Data ³ 16.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Se cancelar na EditRecord retorna para o original		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function PLSCANCEL(nTp)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se cancelado retorna original													 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(aMatCBkp) <> 'U'
	If nTp == 0
		oBrwCri:aCols := aClone(aMatCBkp)
		oBrwCri:oBrowse:oBrowse:nAt := Len(aMatCBkp)
	Else
		oBrwBQZ:aCols := aClone(aMatCBkp)
		oBrwBQZ:oBrowse:oBrowse:nAt := Len(aMatCBkp)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina																	 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSCHMEN     ³ Autor ³Alexander				³Data  ³ 09/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta menu do evolucao de gh								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSCHMEN(oObj,nTp)
DEFAULT nTp := 0

If Len(oObj:ABUTESP) >=2 .And. Len(oObj:ABUTESP[2]) >= 4

	If Empty( oObj:FieldGet("BQV_CODPRO") ) .Or. nTp == 1
		oObj:ABUTESP[2,4] := STR0126 //Negar Comp.
	Else
		oObj:ABUTESP[2,4] := STR0127 //"Composição"
	EndIf

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Funcao															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA092VTM ³ Autor ³ Thiago Guilherme   ³ Data ³ 20.02.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visita Profissional           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092VTM()
Local aObjects	:= {}
Local aPosObj   := {}
LOCAL aButtons := {}
LOCAL cSQL :=NIL
LOCAL aColsQtd := {}
LOCAL aColsBE4 := {}
LOCAL aHeaderBE4:= {}
LOCAL aVetTrab := {}
LOCAL nInd
LOCAL aGuia := {}
LOCAL nRegInt := NIL
LOCAL aValLin := {}

If BE4->BE4_SITUAC == '2'
	Help("",1,"PLSA092CAN")
	Return
EndIf

If PLSALIASEX("BOZ") .AND. PLSALIASEX("BRS")

	Private cPerg := PADR("VSM001", Len(SX1->X1_GRUPO))

	If Pergunte(cPerg,.T.)
		If Empty(mv_par01)
			ALERT("O preenchimento do campo DIAS DE INTERNAÇÃO, é obrigatório.")
			Return
		ElseIf Empty(mv_par02)
			ALERT("O preenchimento do campo A PARTIR DE, é obrigatório.")
			Return
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Opcao acoes relacionadas				                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aButtons,{"",{||"RELATORIO", PLSRVTM(aColsBE4)},"","Imprimir a Lista"})
		If(PLSALIASEX("BOZ"),aadd(aButtons,{"",{||"GIH", PLSGIH(aColsBE4[oBrowUsr:nAt,5])},"","Listar Visitas da GHI"}),)
		aadd(aButtons,{"",{|| PLSA092AVM(aColsBE4[oBrowUsr:nAt,5]) },"Agendar Visita"})
		aadd(aButtons,{"",{||"FILTRO", oDlg:End(), PLSA092VTM()} ,"","Novo Filtro"})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Criacao Header/GetDados				                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize := MsAdvSize()
		AAdd( aObjects, { 100, 0, .T., .T. } )
		AAdd( aObjects, { 100, 40, .T., .T. } )

		aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 1, 1 }
		aPosObj := MsObjSize( aInfo, aObjects,.T. )


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Selecao da informacoes de acordo com os parâmetro                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(mv_par08) .AND. mv_par08 == 2
			nRegInt := 1
		ElseIf !Empty(mv_par08) .AND. mv_par08 == 3
			nRegInt := 2
		ElseIf !Empty(mv_par08) .AND. mv_par08 == 4
			nRegInt := 3
		EndIf

		CSQL := "SELECT "+RETSQLNAME("BE4")+".R_E_C_N_O_ REGISTRO FROM "+RETSQLNAME("BE4")

		If !Empty(MV_PAR10)
			cSQL += ","+RetSQLName("BB8")
		Endif

		// Controle de filial.
		cSQL += " WHERE BE4_FILIAL = '"+xFilial("BE4")+"' "

		 // Controi os relacionamentos.
		 If !Empty(MV_PAR10)
			cSQL += " AND BB8_FILIAL = '"+xFilial("BB8")+"' "
			cSQL += " AND BB8_CODIGO = BE4_CODRDA "
			cSQL += " AND BB8_CODLOC = BE4_CODLOC "
		Endif

		// Constroi os filtros.
		cSQL += "AND BE4_SITUAC = '1' "
		cSQL += " AND BE4_DATPRO >= '" + DTOS(mv_par02) + "'"
		If !Empty(mv_par03)
			cSQL += " AND BE4_CODRDA = '" + AllTrim(mv_par03)+"' "
		Endif

		If !Empty(mv_par04)
			cSQL += " AND BE4_CODESP = '" + alltrim(mv_par04)+"' "
		Endif

		If !Empty(mv_par05)
			cSQL += " AND BE4_TIPADM = '" + ALLTRIM(mv_par05)+"' "
		Endif

		If !Empty(mv_par06)
			cSQL += " AND BE4_GRPINT = '" + AllTrim(mv_par06)+"' "
		Endif

		If !Empty(mv_par07)
			cSQL += " AND BE4_TIPINT = '" + alltrim(mv_par07)+"' "
		Endif

		If !Empty(nRegInt)
			cSQL += " AND BE4_REGINT = '" + AllTrim(str(nRegInt))+"' "
		Endif

		If !Empty(mv_par09)
			cSQL += " AND BE4_ESTSOL = '" + AllTrim(mv_par09)+"'"
		Endif

		If !Empty(MV_PAR10)
			cSQL += " AND BB8_CODMUN = '" +MV_PAR10+"'"
		Endif

		// Filtra os deletados.
		cSQL += " AND "+RetSQLName("BE4")+".D_E_L_E_T_ <> '*' "
		If !Empty(MV_PAR10)
			cSQL += " AND "+RetSQLName("BB8")+".D_E_L_E_T_ <> '*' ""
		Endif

		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBBE4",.F.,.T.)

		If TRBBE4->(EOF())
			Help("",1,"PL316V")
			TRBBE4->(dbCloseArea())
			Return
		EndIf

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5]  of oMainWnd PIXEL

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Popula o ACOLS												                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aColsBE4 := {}
		BOZ->(DBSETORDER(1))
		While !TRBBE4->(EOF())
			BE4->(dbGoto(TRBBE4->REGISTRO))

			If BE4->(Eof())
				TRBBE4->(dbSkip())
				Loop
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Qtde. Eventos												                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSQL2 := "SELECT COUNT(BD6_QTDPRO) QUANTIDADE FROM " + RetSQLName("BD6")
			cSQL2 += " WHERE BD6_FILIAL = '"+xFilial("BD6")+"' "
			cSQL2 += " AND BD6_CODOPE = '"+BE4->BE4_CODOPE+"' "
			cSQL2 += " AND BD6_ANOINT = '"+BE4->BE4_ANOINT+"' "
			cSQL2 += " AND BD6_MESINT = '"+BE4->BE4_MESINT+"' "
			cSQL2 += " AND BD6_NUMERO = '"+BE4->BE4_NUMINT+"' "
			cSQL2 += " AND D_E_L_E_T_ = ' ' "
			cSQL2 := ChangeQuery(cSQL2)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL2),"TRBBD6",.F.,.T.)

			nQtdEve := TRBBD6->QUANTIDADE
			TRBBD6->(dbCloseArea())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Qtde. Visitas												                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSQL3 := "SELECT COUNT(BOZ_FILIAL) QUANTIDADE FROM " + RetSQLName("BOZ")
			CSQL3 += " WHERE BOZ_FILIAL = '"+xFilial("BOZ")+"' "
			cSQL3 += " AND BOZ_CODOPE = '"+BE4->BE4_CODOPE+"' "
			cSQL3 += " AND BOZ_ANOINT = '"+BE4->BE4_ANOINT+"' "
			cSQL3 += " AND BOZ_MESINT = '"+BE4->BE4_MESINT+"' "
			cSQL3 += " AND BOZ_NUMINT = '"+BE4->BE4_NUMINT+"' "
			cSQL3 += " AND D_E_L_E_T_ = ' ' "

			cSQL2 := ChangeQuery(cSQL3)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL3),"TRBBOZ",.F.,.T.)

			nQtdVisit := TRBBOZ->QUANTIDADE
			TRBBOZ->(dbCloseArea())

			// Calcula dias de internacao.
			nDiasInt := DateDiffDay( DATE() , BE4->BE4_DATPRO)

			// Verifica se atende ao filtro.
			If nDiasInt >= Val(MV_PAR01)
				Aadd(aColsBE4, {BE4->(BE4_CODOPE+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO),;	// Matricula
								BE4->BE4_NOMUSR,; // nome do usuario
								BE4->BE4_CODRDA,;
								BE4->BE4_NOMRDA,;
								BE4->BE4_CODOPE+BE4->BE4_ANOINT+BE4->BE4_MESINT+BE4->BE4_NUMINT,; // Numero da guia
								BE4->BE4_SENHA,;
								BE4->BE4_DATPRO,;
								nDiasInt,;
								BE4->BE4_HORPRO,;
								nQtdEve,;
								nQtdVisit,;
								BE4->(Recno())})
			Endif
			TRBBE4->(dbSkip())
		EndDo

		If Len(aColsBE4) > 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Criacao do Grid				                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSize := MsAdvSize()
			AAdd( aObjects, { 100, 000, .T., .T. } )
			AAdd( aObjects, { 100, 000, .T., .T. } )

			aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 1, 1 }
			aPosObj := MsObjSize( aInfo, aObjects,.T. )
			oBrowUsr := TcBrowse():New( aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3] - 30,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

			oBrowUsr:AddColumn(TcColumn():New("Matricula",nil,;
		         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
			         oBrowUsr:ACOLUMNS[1]:BDATA     := { || aColsBE4[oBrowUsr:nAt,1] }

			oBrowUsr:AddColumn(TcColumn():New("Beneficiário",nil,;
			         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
			         oBrowUsr:ACOLUMNS[2]:BDATA     := { || aColsBE4[oBrowUsr:nAt,2] }

			oBrowUsr:AddColumn(TcColumn():New("Cod. RDA",nil,;
			         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
			         oBrowUsr:ACOLUMNS[3]:BDATA     := { || aColsBE4[oBrowUsr:nAt,3] }

			oBrowUsr:AddColumn(TcColumn():New("Nome RDA",nil,;
			         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
			         oBrowUsr:ACOLUMNS[4]:BDATA     := { || aColsBE4[oBrowUsr:nAt,4] }

			oBrowUsr:AddColumn(TcColumn():New("Num. Guia",nil,;
			         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
			         oBrowUsr:ACOLUMNS[5]:BDATA     := { || aColsBE4[oBrowUsr:nAt,5] }

			oBrowUsr:AddColumn(TcColumn():New("Senha",nil,;
			         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
			         oBrowUsr:ACOLUMNS[6]:BDATA     := { || aColsBE4[oBrowUsr:nAt,6] }

			oBrowUsr:AddColumn(TcColumn():New("Dat. Int",nil,;
			         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
			         oBrowUsr:ACOLUMNS[7]:BDATA     := { || dToc(aColsBE4[oBrowUsr:nAt,7]) }

			oBrowUsr:AddColumn(TcColumn():New("Dias Int",nil,;
			         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
			         oBrowUsr:ACOLUMNS[8]:BDATA     := { || Transform(aColsBE4[oBrowUsr:nAt,8],"@ 9999") }

			oBrowUsr:AddColumn(TcColumn():New("Hora Int",nil,;
			         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
			         oBrowUsr:ACOLUMNS[9]:BDATA     := { || Transform(aColsBE4[oBrowUsr:nAt,9],"@R !!:!!") }

			oBrowUsr:AddColumn(TcColumn():New("Qtd Eventos",nil,;
			         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
			         oBrowUsr:ACOLUMNS[10]:BDATA     := { || Transform(aColsBE4[oBrowUsr:nAt,10],"@ 9999") }

			oBrowUsr:AddColumn(TcColumn():New("Qtd Visitas",nil,;
			         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
			         oBrowUsr:ACOLUMNS[11]:BDATA     := { || Transform(aColsBE4[oBrowUsr:nAt,11],"@ 9999") }

	         oBrowUsr:SetArray(aColsBE4)

		Endif

		TRBBE4->(dbCloseArea())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define dialogo...                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},.F.,aButtons) CENTERED

	Else
		Return
	EndIf
Else
		Help("",1,"PL317V")
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSGIH  ³ Autor ³ Thiago Ribas         ³ Data ³ 08.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe historico de visítas                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSGIH(cNumGui)
LOCAL aHeader
LOCAL aCols
LOCAL aVetTrab
LOCAL cHora
LOCAL nCont

If (B53->B53_ROTGEN == "1")
	Alert (STR0193)//"Opção não disponível para Rotina Genérica"
	Return
EndIf

If PLSALIASEX("BOZ")

		Store HEADER "BOZ" to aHeader For AllTrim(SX3->X3_CAMPO) $ "BOZ_CODM/BOZ_NOMEDI/BOZ_DATPRE/BOZ_HRPREV/BOZ_OBSERV"

		DbSelectArea("BOZ")
		DbSetOrder(1)

		If ! BOZ->(DbSeek(xFilial("BOZ")+cNumGui))
		   Store COLS Blank "BOZ" TO aCols FROM aHeader
		Else
		   Store COLS "BOZ" TO aCols FROM aHeader VETTRAB aVetTrab ;
		   While xFilial("BOZ")+BOZ->(BOZ_CODOPE+BOZ_ANOINT+BOZ_MESINT+BOZ_NUMINT) == xFilial("BOZ")+cNumGui
		Endif

		If !EMPTY(aCols)

			For nCont := 1 To Len(aCols)

				If !EMPTY(aCols[nCont][GdFieldPos("BOZ_HRPREV",aHeader)])

					cHora := aCols[nCont][GdFieldPos("BOZ_HRPREV",aHeader)] 
					cHora := Iif(":"  $ AllTrim(cHora),cHora,TRANSFORM(cHora,"@R !!:!!"))
					aCols[nCont][GdFieldPos("BOZ_HRPREV",aHeader)] := cHora
				EndIf
			Next

			PLSHGIH(aCols,aHeader, "Lista de Visitas da GIH", .T. )
		else
			Help("",1,"PL318V")
		EndIf
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSHGIH  ³ Autor ³ Thiago Ribas         ³ Data ³ 08.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe historico de visítas                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSHGIH(aDados,aCabec,cTitulo,lRel,cRodape,nFreeze,;
 				   aButtons, bLDblClick,cRdmake,cTpRel,nTmRel,;
 				   bBlickUser,aArrayAux,lAmbAtv,;
 				   cLin1,cLin2,cCol1,cCol2,cHoriz,;
 				   aCores,aCdCores,aLegenda,oFont,lResize,aTipoCab)
LOCAL oDlg
LOCAL nOpca      := 0
LOCAL bOK        := { || nOpca := 1, nLinSel := oCritica:nAt, oDlg:End() }
LOCAL bCancel    := { || nOpca := 0, oDlg:End() }
LOCAL nFor
LOCAL oCritica
LOCAL nLinSel
LOCAL lRoda      := .F.
LOCAL lBotoesPad
LOCAL abt :={}

DEFAULT lRel     := .T.
DEFAULT cRodape  := ""
DEFAULT nFreeze  := 0
DEFAULT aButtons := {}
DEFAULT bLDblClick := bOk
DEFAULT cRdmake    := ""
DEFAULT cTpRel     := "M"
DEFAULT nTmRel     := 132
DEFAULT bBlickUser := { || }
DEFAULT aArrayAux  := {}
DEFAULT lAmbAtv    := .T.  // indica se ja existe um ambiente ativo
                           // no PLSXUPT, por exemplo, ainda nao existe ambiente inicalizado e da erro no ExistBlock
                           // porque algumas variaveis de ambiente nao foram inicializadas
DEFAULT cLin1 := 008.0
DEFAULT cLin2 := 036.4
DEFAULT cCol1 := 010.3
DEFAULT cCol2 := 100.3
DEFAULT cHoriz:= 345
DEFAULT aCores   := {}
DEFAULT aCdCores := {}
DEFAULT aLegenda := { "Legenda", "Status" }
DEFAULT lResize  := .F.
DEFAULT aTipoCab := {}

If oFont == NIL
	Define FONT oFont NAME "Courier New" Size 0,-10 BOLD
Endif

lBotoesPad := Len(aButtons) > 0 .Or. Len(aCdCores) > 0

If  lAmbAtv .and. ! empty(cRdmake) .and. ExistBlock(cRdmake)
    Aadd(aBt, {"RELATORIO",{ || ExecBlock(cRdmake,.F.,.F.,{aDados,aCabec,cTitulo,cTpRel,nTmRel}) },"Imprimir"} )
Else
    If lAmbAtv .and. ExistBlock("PLSCRIGB")
       Aadd(aBt, {"RELATORIO",{ || ExecBlock("PLSCRIGB",.F.,.F.,{aDados,aCabec,cTitulo,cTpRel,nTmRel}) },"Imprimir"} )
    Else
       If lRel
          Aadd(aBt, {"RELATORIO",{ || ImpCriGen(aDados,aCabec,cTitulo,cTpRel,nTmRel) },"Imprimir"} )
       Endif
    Endif
Endif

If Len(aCdCores) > 0
	aAdd(aBt,{"RELATORIO",{||BrwLegenda(aLegenda[1], aLegenda[2] ,aCdCores)},"Legenda","Legenda"})
EndIf

lRoda := !Empty(cRodaPe)
If Len(aDados) == 0
   Help("",1,"PLSCRIGEN")
   Return
Endif

If ! lRel .And. ! lBotoesPad
   aButtons := {}
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize    := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .t., .t.,.t. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T. )

If lResize
	cLin1 := aSize[7]
	cCol1 := 0
	cLin2 := aSize[6]
	cCol2 := aSize[5]

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM cLin1,cCol1 TO cLin2,cCol2 of oMainWnd pixel
Else
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM cLin1,cCol1 TO cLin2,cCol2
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o browse...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lResize
	oCritica := TcBrowse():New( 022, 005, aPosObj[1][3], aPosObj[1][4]*0.97,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
Else
	oCritica := TcBrowse():New( aPosObj[1,1], aPosObj[1,2], cHoriz, IF(lRoda,160,170),,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
Endif
oCritica:bLDblClick := { || Eval(bBlickUser,oCritica,aArrayAux), bLDblClick }
oCritica:oFont := IIf(oFont == Nil, oCritica:oFont, oFont)

If nFreeze <> 0
	oCritica:nFreeze := nFreeze
Endif

If Len(aCores) > 0
    bBlock := '{ || '
	For nFor := 1 To Len(aCores)
	   bBlock += 'IIf(' + aCores[nFor, 1] + ',LoadBitMap( GetResources(), "' + aCores[nFor, 2] + '" ),'
	Next nFor
	bBlock += Replicate(')',Len(aCores)) + ' }'
	bBlock := &bBlock
	oCritica:AddColumn(TcColumn():New("",bBlock,;
                  "@!",nil,nil,nil,15,.T.,.T.,nil,nil,nil,.T.,nil))
EndIf


For nFor := 1 To Len(aCabec)

     bBlock := "{ || aDados[oCritica:nAt, "+Str(nFor,4)+"] }"
     bBlock := &bBlock
     oCritica:AddColumn(TcColumn():New(aCabec[nFor,1],bBlock,;
                    aDados[1],nil,nil,nil,aCabec[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))

Next
oCritica:SetArray(aDados)

If lRoda
   @ 189,005 SAY oSay PROMPT cRodape  SIZE 400,010 OF oDlg PIXEL
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa dialogo....                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel) }, .F., abt ) Center

If  lAmbAtv
    DbSelectArea("BA0")
Endif

Return({(nOpca==1),nLinSel})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA092IVM ³ Autor ³ Thiago Guilherme   ³ Data ³ 20.02.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inserir Visita Profissional    								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092IVM()

Local I__f		:= 0
Local oDlg
Local oEnc
Local oGet
Local nOpca			:= 0
Local aHeader		:= {}
Local aCols			:= {}
LOCAL aTeste		:= {}
Local aHeaderBRS	:= {}
Local aColsBRS		:= {}
LOCAL cFolder       := ""
Local aVetTrab		:= {}
LOCAL aVetProc   	:= {}
Local aPosObj   	:= {}
Local aObjects		:= {}
Local aSize     	:= {}
Local aInfo     	:= {}
LOCAL nLeft 		:= 0
LOCAL nLarg 		:= 0
LOCAL nBottom 		:= 0
LOCAL cChave 		:= NIL
LOCAL nPosiVis  	:= NIL
LOCAL nPosiProc 	:= NIL
LOCAL cCodBOZ 		:= NIL
LOCAL nFld
LOCAL bOK        	:= {|| nTipo := __OFldBRS:NOPTION,oDlg:End() }
LOCAL bCancel    	:= {|| oDlg:End() }
LOCAL aObFolder  	:= {}
LOCAL aPosOb		:= {}
LOCAL aButtons 		:= {}
LOCAl aCamposEnc	:= {}
LOCAL oEncCla
LOCAL oBRS
LOCAL oFld
LOCAL nI			:= 0
LOCAl aObject 		:= {}
LOCAL aInf          := {}
LOCAL aPosObject	:= {}
LOCAL aAdvSize 		:= {}
LOCAL aInfoAdvSize 	:= {}
LOCAL aObjCoords 	:= {}
LOCAL aObjSize 		:= {}
LOCAL aTitles 		:= {"Procedimento", "Material Medicamento", "Alugueis/Taxas", "Diárias", "Ortese/Prótese", "Gáses", "Exames", "Terapias"}
LOCAL nLinAnt 		:= 0
LOCAL aChave  		:= {}
LOCAL cAcomod			:= ""
LOCAL aHeaderBQR
LOCAL aColsBQR
LOCAL aVetBQR
LOCAL aVetBA3
LOCAL aHeaderBA3
LOCAL aColsBA3
LOCAL cCodPla			:= ""
LOCAL bDbl
LOCAL cEspec

// Privates
PRIVATE cCodVisit 	:= ""
PRIVATE oGetGrid1
PRIVATE oGetGrid2
PRIVATE oGetGrid3
PRIVATE oGetGrid4
PRIVATE oGetGrid5
PRIVATE oGetGrid6
PRIVATE oGetGrid7
PRIVATE oGetGrid8
PRIVATE __OFldBRS
PRIVATE oBrwBOZ
PRIVATE __aArrObj := {}

If BE4->BE4_SITUAC == '2'
	Help("",1,"PLSA092CAN")
	Return
EndIf

If !PLSALIASEX("BOZ") .OR. !PLSALIASEX("BRS")
	Help("",1,"PL317V")
	Return
EndIf

If EMPTY(BE4->BE4_DATPRO)
	Help("",1,"PLVSM1")
	Return
EndIf

If BE4->BE4_SITUAC == "2"
	Help("",1,"PLVSM3")
	Return
EndIf

// Botão.
aadd(aButtons,{"",{||"Excluir", EXCVISITA(oBrwBOZ:acols[oBrwBOZ:obrowse:nat][6],BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),oBrwBOZ)},"","Excluir Visita"})

//Descrição do plano
DbSelectArea("BA3")
DbSetOrder(1)

If BA3->(DbSeek(xFilial("BE4")+BE4->(BE4_CODOPE+BE4_CODEMP+BE4_MATRIC+BE4_CONEMP+BE4_VERCON+BE4_SUBCON+BE4_VERSUB)))
	DbSelectArea("BI3")
	cCodPla := BI3->(Posicione("BI3",1,xFilial("BI3")+BE4->BE4_CODOPE+BA3->BA3_CODPLA,"BI3_DESCRI"))
EndIf

DbSelectArea("BAQ")
cEspec := BAQ->(Posicione("BAQ",1,xFilial("BAQ")+BE4->BE4_CODOPE+BE4->BE4_CODESP,"BAQ_DESCRI"))

aSize := MsAdvSize()
AAdd( aObject, { 100, 100, .T., .T. } )
AAdd( aObject, { 100, 100, .T., .T. } )
AAdd( aObject, { 100, 100, .T., .T. } )

aInf := { aSize[1],aSize[2],aSize[3],aSize[4], 1, 1 }
aPosObject := MsObjSize( aInf, aObject,.T. )

// Display map
aSizeFd =  MsAdvSize()
AAdd( aObFolder, { 50, 50, .T., .T. } )
AAdd( aObFolder, { 50, 50, .T., .T., .T. } )
AAdd( aObFolder, { 50, 50, .T., .T. } )
aInfoFd := { aSizeFd[ 1 ], aSizeFd[ 2 ], aSizeFd[ 3 ], aSizeFd[ 4 ], 1, 1 }
aPosOb := MsObjSize( aInfoFd, aObFolder )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 10,0 To 600, 1100 of oMainWnd PIXEL

@ 005,005 SAY "Matrícula" SIZE 100,010 PIXEL OF oDlg //Matrícula
@ 015,005 MSGET oPes01 VAR BE4->(BE4_CODOPE+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO) PICTURE "@!" WHEN .F. SIZE 080,010 PIXEL OF oDlg

@ 005,100 SAY "Usuário" SIZE 100,010 PIXEL OF oDlg //Usuário
@ 015,100 MSGET oPes01 VAR BE4->BE4_NOMUSR PICTURE "@!" WHEN .F. SIZE 200,010 PIXEL OF oDlg

@ 005,315 SAY "Cd.Cred/Coop" SIZE 100,010 PIXEL OF oDlg //Cd. Cred/Coop
@ 015,315 MSGET oPes01 VAR BE4->BE4_CODRDA PICTURE "@!" WHEN .F. SIZE 040,010 PIXEL OF oDlg

@ 005,372 SAY "Nm.Cred/Coop" SIZE 100,010 PIXEL OF oDlg //Nome RDA
@ 015,372 MSGET oPes01 VAR BE4->BE4_NOMRDA PICTURE "@!" WHEN .F. SIZE 150,010 PIXEL OF oDlg

@ 035,005 SAY "Cd.Espec" SIZE 100,010 PIXEL OF oDlg //Cd. Espec
@ 045,005 MSGET oPes01 VAR BE4->BE4_CODESP PICTURE "@!" WHEN .F. SIZE 020,010 PIXEL OF oDlg

@ 035,100 SAY "Desc. Espec" SIZE 100,010 PIXEL OF oDlg //Desc. Espec
@ 045,100 MSGET oPes01 VAR cEspec PICTURE "@!" WHEN .F. SIZE 200,010 PIXEL OF oDlg

@ 035,315 SAY "C.R. Solc" SIZE 100,010 PIXEL OF oDlg //C.R. Solc
@ 045,315 MSGET oPes01 VAR BE4->BE4_REGSOL PICTURE "@!" WHEN .F. SIZE 040,010 PIXEL OF oDlg

@ 035,372 SAY "Solicitante" SIZE 100,010 PIXEL OF oDlg //Solicitante
@ 045,372 MSGET oPes01 VAR BE4->BE4_NOMSOL PICTURE "@!" WHEN .F. SIZE 150,010 PIXEL OF oDlg

@ 065,005 SAY "Senha" SIZE 100,010 PIXEL OF oDlg //Senha
@ 075,005 MSGET oPes01 VAR BE4->BE4_SENHA PICTURE "@!" WHEN .F. SIZE 080,010 PIXEL OF oDlg

@ 065,100 SAY "Número Autorização" SIZE 100,010 PIXEL OF oDlg //Número Autorização
@ 075,100 MSGET oPes01 VAR BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) PICTURE "@!" WHEN .F. SIZE 80,010 PIXEL OF oDlg

@ 065,195 SAY "CID Principal" SIZE 100,010 PIXEL OF oDlg //CID Principal
@ 075,195 MSGET oPes01 VAR BE4->BE4_CID PICTURE "@!" WHEN .F. SIZE 30,010 PIXEL OF oDlg

@ 065,240 SAY "Qtde. Diarias" SIZE 100,010 PIXEL OF oDlg //Qtde. Diarias
@ 075,240 MSGET oPes01 VAR BE4->BE4_DIASIN PICTURE "@!" WHEN .F. SIZE 30,010 PIXEL OF oDlg

@ 065,283 SAY "Recém-Nascido" SIZE 100,010 PIXEL OF oDlg //Rescem-Nascido
@ 075,283 MSGET oPes01 VAR If(DateDiffDay( DATE() , BE4->BE4_DATNAS ) > 28, "Não", "Sim") PICTURE "@!" WHEN .F. SIZE 30,010 PIXEL OF oDlg

@ 065,330 SAY "Acomodação" SIZE 100,010 PIXEL OF oDlg //AcomodaÇão
@ 075,330 MSGET oPes01 VAR IF(BE4->BE4_PADINT == "01", "APARTAMENTO", "ENFERMARIA")  PICTURE "@!" WHEN .F. SIZE 50,010 PIXEL OF oDlg

@ 065,388 SAY "Data Intern." SIZE 100,010 PIXEL OF oDlg //"Data Intern."
@ 075,388 MSGET oPes01 VAR DTOC(BE4->BE4_DATPRO) PICTURE "@!" WHEN .F. SIZE 38,010 PIXEL OF oDlg

@ 065,437 SAY "Plano" SIZE 100,010 PIXEL OF oDlg //"Plano"
@ 075,437 MSGET oPes01 VAR cCodPla PICTURE "@!" WHEN .F. SIZE 85,010 PIXEL OF oDlg

// Folder de eventos
__OFldBRS   := TFolder():New(182,05,aTitles,{""},oDlg,,,,.T.,.F.,540 ,108 )
__OFldBRS:bChange := { |nFolder| Eval(oBrwBOZ:bGotFocus)}

// Constroi grid PAI.
Store Header "BOZ" to aHeader For .T.
DbSelectArea("BOZ")
DbSetOrder(1)
If BOZ->(DbSeek(xFilial("BOZ")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
	cCodVisit := BOZ->BOZ_CODIGO
	Store COLS "BOZ" TO aCols FROM aHeader VETTRAB aVetTrab While xFilial("BOZ")+BOZ->(BOZ_CODOPE+BOZ_ANOINT+BOZ_MESINT+BOZ_NUMINT) == xFilial("BOZ")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
Else
	Store COLS Blank "BOZ" TO aCols FROM aHeader
Endif

oBrwBOZ := TPLSBrw():New(095,005,545,180,.T.  ,oDlg,nil    ,{|| PLSA092VLB(1, "") }  ,.T.    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BOZ",K_Alterar,"Itens",nil,nil,nil,aVetTrab)
oBrwBOZ:bGotFocus 	:= { || cCodVisit := oBrwBOZ:aCols[oBrwBOZ:Linha(),oBrwBOZ:PLRETPOS("BOZ_CODIGO")], ChangeBOZ()}
oBrwBOZ:bLostFocus 	:= { || Eval(oBrwBOZ:bGotFocus)}
oBrwBOZ:bChange    	:= { || Eval(oBrwBOZ:bGotFocus),__OFldBRS:SetOption(1), PLSA092OBS(oGetGrid1:acols[oGetGrid1:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo1)}
oBrwBOZ:oBrowse:bDelOk := {|| }
// Constroi Grid de Procedimentos.
Store Header "BRS" to aHeaderBRS For .T.
DbSelectArea("BRS")
DbSetOrder(1)
If BRS->(DbSeek(xFilial("BRS")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
	Store COLS "BRS" TO aColsBRS FROM aHeaderBRS VETTRAB aVetProc ;
	While xFilial("BRS")+BRS->(BRS_CODINT+BRS_ANOINT+BRS_MESINT+BRS_NUMINT) ==  xFilial("BE4")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
Else
	Store COLS Blank "BRS" TO aColsBRS FROM aHeaderBRS
Endif
bFilter  := {|nLine,aCols,aHeader| aCols[nLine,GdFieldPos("BRS_CODIGO",aHeader)] == cCodVisit .AND.;
			 aCols[nLine,GdFieldPos("BRS_FLDR",aHeader)] == STRZERO(__OFldBRS:nOption,1)}
oGetGrid1 := TPLSBrw():New(002,002,395,85,.F.  ,__OFldBRS:aDialogs[1],nil ,{|| PLSA092VLB(2,__OFldBRS:nOption,aColsBRS) },.T.    ,nil, .T.   ,nil  ,nil ,.T.    ,nil,aHeaderBRS,aColsBRS,.F.,"BRS",K_Alterar,"Procedimentos",nil,nil,nil,aVetProc,,,bFilter,)
oGetGrid1:oPai    	:= oBrwBOZ
oGetGrid1:aOrigem 	:= {"BOZ_CODIGO"}
oGetGrid1:aRelac  	:= {"BRS_CODIGO"}
oGetGrid1:bChange		:= {||PLSA092OBS(oGetGrid1:acols[oGetGrid1:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo1)}
oGetGrid1:bGotFocus 	:= {|| PLSA092VLB(3,__OFldBRS:nOption) }
oGetGrid1:bAfterAdd	:= {||PLSA092OBS(oGetGrid1:acols[oGetGrid1:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo1)}
oGetGrid1:oBrowse:bDelOk := {|| }
cTexto 				:= if(!EMPTY(oGetGrid1:aCols[oGetGrid1:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)]),oGetGrid1:aCols[oGetGrid1:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],"Sem descrição")
@ 1, 397 Get oMemo1 Var cTexto Memo When .F. Size 140, 85 Of __OFldBRS:aDialogs[1] Pixel

oGetGrid2 := TPLSBrw():New(002,002,395,85,.T.  ,__OFldBRS:aDialogs[2],nil,{|| PLSA092VLB(2,__OFldBRS:nOption,aColsBRS)  },.T.    ,nil, .T.   ,nil  ,nil ,.T.    ,nil,aHeaderBRS,aColsBRS,.F.,"BRS",K_Alterar,"Itens",nil,nil,nil,aVetProc,,,bFilter,)
oGetGrid2:oPai    	 := oBrwBOZ
oGetGrid2:aOrigem 	 := {"BOZ_CODIGO"}
oGetGrid2:aRelac  	 := {"BRS_CODIGO"}
oGetGrid2:bChange		 := {||PLSA092OBS(oGetGrid2:acols[oGetGrid2:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo2)}
oGetGrid2:bGotFocus 	 := {|| PLSA092VLB(3,__OFldBRS:nOption) }
oGetGrid2:bAfterAdd	 := {||PLSA092OBS(oGetGrid2:acols[oGetGrid2:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo2)}
oGetGrid2:oBrowse:bDelOk := {|| }
cTexto 				 := if(!EMPTY(oGetGrid2:aCols[oGetGrid2:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)]),oGetGrid2:aCols[oGetGrid2:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],"Sem descrição")
@ 1, 397 Get oMemo2 Var cTexto Memo When .F. Size 140, 85 Of __OFldBRS:aDialogs[2] Pixel

oGetGrid3 := TPLSBrw():New(002,002,395,85,.T.  ,__OFldBRS:aDialogs[3],nil,{||PLSA092VLB(2,__OFldBRS:nOption,aColsBRS,aColsBRS)  },.T.    ,nil, .T.   ,nil  ,nil ,.T.    ,nil,aHeaderBRS,aColsBRS,.F.,"BRS",K_Alterar,"Itens",nil,nil,nil,aVetProc,,,bFilter,)
oGetGrid3:oPai    	:= oBrwBOZ
oGetGrid3:aOrigem 	:= {"BOZ_CODIGO"}
oGetGrid3:aRelac  	:= {"BRS_CODIGO"}
oGetGrid3:bChange		:= {||PLSA092OBS(oGetGrid3:acols[oGetGrid3:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo3)}
oGetGrid3:bGotFocus 	:= {|| PLSA092VLB(3,__OFldBRS:nOption,,aColsBRS) }
oGetGrid3:bAfterAdd	:= {||PLSA092OBS(oGetGrid3:acols[oGetGrid3:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo3)}
oGetGrid3:oBrowse:bDelOk := {|| }
cTexto 				:= if(!EMPTY(oGetGrid3:aCols[oGetGrid3:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)]),oGetGrid3:aCols[oGetGrid3:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],"Sem descrição")
@ 1, 397 Get oMemo3 Var cTexto Memo When .F. Size 140, 85 Of __OFldBRS:aDialogs[3] Pixel

oGetGrid4 := TPLSBrw():New(002,002,395,85,.T.  ,__OFldBRS:aDialogs[4],nil,{|| PLSA092VLB(2,__OFldBRS:nOption,aColsBRS)  },.T.    ,nil, .T.   ,nil  ,nil ,.T.    ,nil,aHeaderBRS,aColsBRS,.F.,"BRS",K_Alterar,"Itens",nil,nil,nil,aVetProc,,,bFilter,)
oGetGrid4:oPai    	:= oBrwBOZ
oGetGrid4:aOrigem 	:= {"BOZ_CODIGO"}
oGetGrid4:aRelac  	:= {"BRS_CODIGO"}
oGetGrid4:bChange		:= {||PLSA092OBS(oGetGrid4:acols[oGetGrid4:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo4)}
oGetGrid4:bAfterAdd	:= {||PLSA092OBS(oGetGrid4:acols[oGetGrid4:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo4)}
oGetGrid4:oBrowse:bDelOk := {|| }
cTexto 				:= if(!EMPTY(oGetGrid4:aCols[oGetGrid4:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)]),oGetGrid4:aCols[oGetGrid4:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],"Sem descrição")
@ 1, 397 Get oMemo4 Var cTexto Memo When .F. Size 140, 85 Of __OFldBRS:aDialogs[4] Pixel

oGetGrid5 := TPLSBrw():New(002,002,395,85,.T.  ,__OFldBRS:aDialogs[5],nil,{|| PLSA092VLB(2,__OFldBRS:nOption,aColsBRS)  },.T.    ,nil, .T.   ,nil  ,nil ,.T.    ,nil,aHeaderBRS,aColsBRS,.F.,"BRS",K_Alterar,"Itens",nil,nil,nil,aVetProc,,,bFilter,)
oGetGrid5:oPai    	:= oBrwBOZ
oGetGrid5:aOrigem 	:= {"BOZ_CODIGO"}
oGetGrid5:aRelac  	:= {"BRS_CODIGO"}
oGetGrid5:bChange		:= {||PLSA092OBS(oGetGrid5:acols[oGetGrid5:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo5)}
oGetGrid5:bGotFocus 	:= {|| PLSA092VLB(3,__OFldBRS:nOption) }
oGetGrid5:bAfterAdd	:= {||PLSA092OBS(oGetGrid5:acols[oGetGrid5:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo5)}
oGetGrid5:oBrowse:bDelOk := {|| }
cTexto 				:= if(!EMPTY(oGetGrid5:aCols[oGetGrid5:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)]),oGetGrid5:aCols[oGetGrid5:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],"Sem descrição")
@ 1, 397 Get oMemo5 Var cTexto Memo When .F. Size 140, 85 Of __OFldBRS:aDialogs[5] Pixel

oGetGrid6 := TPLSBrw():New(002,002,395,85,.T.  ,__OFldBRS:aDialogs[6],nil,{|| PLSA092VLB(2,__OFldBRS:nOption,aColsBRS)  },.T.    ,nil, .T.   ,nil  ,nil ,.T.    ,nil,aHeaderBRS,aColsBRS,.F.,"BRS",K_Alterar,"Itens",nil,nil,nil,aVetProc,,,bFilter,)
oGetGrid6:oPai    	:= oBrwBOZ
oGetGrid6:aOrigem 	:= {"BOZ_CODIGO"}
oGetGrid6:aRelac  	:= {"BRS_CODIGO"}
oGetGrid6:bChange		:= {||PLSA092OBS(oGetGrid6:acols[oGetGrid6:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo6)}
oGetGrid6:bGotFocus 	:= {|| PLSA092VLB(3,__OFldBRS:nOption) }
oGetGrid6:bAfterAdd	:= {||PLSA092OBS(oGetGrid6:acols[oGetGrid6:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo6)}
oGetGrid6:oBrowse:bDelOk := {|| }
cTexto 				:= if(!EMPTY(oGetGrid6:aCols[oGetGrid6:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)]),oGetGrid6:aCols[oGetGrid6:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],"Sem descrição")
@ 1, 397 Get oMemo6 Var cTexto Memo When .F. Size 140, 85 Of __OFldBRS:aDialogs[6] Pixel

oGetGrid7 := TPLSBrw():New(002,002,395,85,.T.  ,__OFldBRS:aDialogs[7],nil, {|| PLSA092VLB(2,__OFldBRS:nOption,aColsBRS)  },.T.    ,nil, .T.   ,nil  ,nil ,.T.    ,nil,aHeaderBRS,aColsBRS,.F.,"BRS",K_Alterar,"Itens",nil,nil,nil,aVetProc,,,bFilter,)
oGetGrid7:oPai    	:= oBrwBOZ
oGetGrid7:aOrigem 	:= {"BOZ_CODIGO"}
oGetGrid7:aRelac  	:= {"BRS_CODIGO"}
oGetGrid7:bChange		:= {||PLSA092OBS(oGetGrid7:acols[oGetGrid7:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo7)}
oGetGrid7:bGotFocus 	:= {|| PLSA092VLB(3,__OFldBRS:nOption) }
oGetGrid7:bAfterAdd	:= {||PLSA092OBS(oGetGrid7:acols[oGetGrid7:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo7)}
oGetGrid7:oBrowse:bDelOk := {|| }
cTexto 				:= if(!EMPTY(oGetGrid7:aCols[oGetGrid7:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)]),oGetGrid7:aCols[oGetGrid7:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],"Sem descrição")
@ 1, 397 Get oMemo7 Var cTexto Memo When .F. Size 140, 85 Of __OFldBRS:aDialogs[7] Pixel

oGetGrid8 := TPLSBrw():New(002,002,395,85,.T.  ,__OFldBRS:aDialogs[8],nil,{|| PLSA092VLB(2,__OFldBRS:nOption,aColsBRS)  },.T.    ,nil, .T.   ,nil  ,nil ,.T.    ,nil,aHeaderBRS,aColsBRS,.F.,"BRS",K_Alterar,"Itens",nil,nil,nil,aVetProc,,,bFilter,)
oGetGrid8:oPai    	:= oBrwBOZ
oGetGrid8:aOrigem 	:= {"BOZ_CODIGO"}
oGetGrid8:aRelac  	:= {"BRS_CODIGO"}
oGetGrid8:bChange		:= {||PLSA092OBS(oGetGrid8:acols[oGetGrid8:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo8)}
oGetGrid8:bGotFocus 	:= {|| PLSA092VLB(3,__OFldBRS:nOption) }
oGetGrid8:bAfterAdd  := {||PLSA092OBS(oGetGrid8:acols[oGetGrid8:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],oMemo8)}
oGetGrid8:oBrowse:bDelOk := {|| }
cTexto 				:=	if(!EMPTY(oGetGrid8:aCols[oGetGrid8:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)]),oGetGrid8:aCols[oGetGrid8:obrowse:nAt][GdFieldPos("BRS_OBSERV",aHeaderBRS)],"Sem descrição")
@ 1, 397 Get oMemo8 Var cTexto Memo When .F. Size 140, 85 Of __OFldBRS:aDialogs[8] Pixel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder Default                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg ,{|| nOpca := 1, oDlg:End(),.F.}, {|| oDlg:End()},.F.,aButtons) Centered

If  nOpca == K_OK

	If !EMPTY(oBrwBOZ:aCols[1][1])
		Begin Transaction

			aChave := {}
			aadd(aChave,{"BOZ_MESINT" ,BE4->BE4_MESINT})
			aadd(aChave,{"BOZ_ANOINT",BE4->BE4_ANOINT})
			aadd(aChave,{"BOZ_NUMINT",BE4->BE4_NUMINT})
			aadd(aChave,{"BOZ_CODOPE",BE4->BE4_CODOPE})
			oBrwBOZ:Grava(aChave)

			aChave := {}
			aadd(aChave,{"BRS_MESINT" ,BE4->BE4_MESINT})
			aadd(aChave,{"BRS_ANOINT",BE4->BE4_ANOINT})
			aadd(aChave,{"BRS_NUMINT",BE4->BE4_NUMINT})
			aadd(aChave,{"BRS_CODINT",BE4->BE4_CODOPE})
			oGetGrid1:Grava(aChave)

			aChave := {}
			aadd(aChave,{"BRS_MESINT" ,BE4->BE4_MESINT})
			aadd(aChave,{"BRS_ANOINT",BE4->BE4_ANOINT})
			aadd(aChave,{"BRS_NUMINT",BE4->BE4_NUMINT})
			aadd(aChave,{"BRS_CODINT",BE4->BE4_CODOPE})
			oGetGrid2:Grava(aChave)

			aChave := {}
			aadd(aChave,{"BRS_MESINT" ,BE4->BE4_MESINT})
			aadd(aChave,{"BRS_ANOINT",BE4->BE4_ANOINT})
			aadd(aChave,{"BRS_NUMINT",BE4->BE4_NUMINT})
			aadd(aChave,{"BRS_CODINT",BE4->BE4_CODOPE})
			oGetGrid3:Grava(aChave)

			aChave := {}
			aadd(aChave,{"BRS_MESINT" ,BE4->BE4_MESINT})
			aadd(aChave,{"BRS_ANOINT",BE4->BE4_ANOINT})
			aadd(aChave,{"BRS_NUMINT",BE4->BE4_NUMINT})
			aadd(aChave,{"BRS_CODINT",BE4->BE4_CODOPE})
			oGetGrid4:Grava(aChave)

			aChave := {}
			aadd(aChave,{"BRS_MESINT" ,BE4->BE4_MESINT})
			aadd(aChave,{"BRS_ANOINT",BE4->BE4_ANOINT})
			aadd(aChave,{"BRS_NUMINT",BE4->BE4_NUMINT})
			aadd(aChave,{"BRS_CODINT",BE4->BE4_CODOPE})
			oGetGrid5:Grava(aChave)

			aChave := {}
			aadd(aChave,{"BRS_MESINT" ,BE4->BE4_MESINT})
			aadd(aChave,{"BRS_ANOINT",BE4->BE4_ANOINT})
			aadd(aChave,{"BRS_NUMINT",BE4->BE4_NUMINT})
			aadd(aChave,{"BRS_CODINT",BE4->BE4_CODOPE})
			oGetGrid6:Grava(aChave)

			aChave := {}
			aadd(aChave,{"BRS_MESINT" ,BE4->BE4_MESINT})
			aadd(aChave,{"BRS_ANOINT",BE4->BE4_ANOINT})
			aadd(aChave,{"BRS_NUMINT",BE4->BE4_NUMINT})
			aadd(aChave,{"BRS_CODINT",BE4->BE4_CODOPE})
			oGetGrid7:Grava(aChave)

			aChave := {}
			aadd(aChave,{"BRS_MESINT" ,BE4->BE4_MESINT})
			aadd(aChave,{"BRS_ANOINT",BE4->BE4_ANOINT})
			aadd(aChave,{"BRS_NUMINT",BE4->BE4_NUMINT})
			aadd(aChave,{"BRS_CODINT",BE4->BE4_CODOPE})
			oGetGrid8:Grava(aChave)

		End Transaction
	 Else
	 	Help("",1,"PLVSM2")
	 EndIf

	If ExistBlock("PLBVSTM")
		ExecBlock("PLBVSTM",.F.,.F.,{cChave, M->BOZ_CODIGO, K_incluir })
	EndIf
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AtuObj ³ Autor ³ Thiago Guilherme 	³ Data ³ 25.02.2013   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza objeto					  	            				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßß
/*/
Static Function AtuObj()
	__aArrObj := {oGetGrid1,oGetGrid2,oGetGrid3,oGetGrid4,oGetGrid5,oGetGrid6,oGetGrid7,oGetGrid8}
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLBRSRLC ³ Autor ³ Thiago Guilherme 	    ³ Data ³25.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza estado do objeto da BRS 				              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLBRSRLC(nTipo)
LOCAL cRet := ""
LOCAL oObj

// Atualiza o estado dos objetos do array.
Eval(bAtuObj)

// Obtem o objeto correspondente ao folder posicionado.
oObj := __aArrObj[__OFldBRS:nOption]

If nTipo == 1 // Campo Sequencia
	// Incrementa o campo sequencia.
	cRet := PlsIncre("BRS_SEQUEN",oObj)

Elseif nTipo == 2 // Campo Folder ou Tipo
	cRet := Alltrim(Str(__OFldBRS:nOption))

Elseif nRet == 3 // Campo Codigo do grid Pai.
//	cRet := PlsIncre("BOZ_CODIGO",oBrwBOZ)

Endif

// Retorna a sequencia.
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ChangeBOZ ³ Autor ³ Thiago Guilherme 	³ Data ³ 25.02.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza visita médica			  					³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ChangeBOZ()
	oGetGrid1:ForceRefresh(oBrwBOZ)
	oGetGrid2:ForceRefresh(oBrwBOZ)
	oGetGrid3:ForceRefresh(oBrwBOZ)
	oGetGrid4:ForceRefresh(oBrwBOZ)
	oGetGrid5:ForceRefresh(oBrwBOZ)
	oGetGrid6:ForceRefresh(oBrwBOZ)
	oGetGrid7:ForceRefresh(oBrwBOZ)
	oGetGrid8:ForceRefresh(oBrwBOZ)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ EXCVISITA ³ Autor ³ Thiago Guilherme 	³ Data ³ 25.02.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui visita médica			  					³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function EXCVISITA(cCodigo,cGuia,oGetEx)

LOCAL aVetTrab
LOCAL aColsEx
LOCAL aHeaderEx

	Begin Transaction
		dbSelectArea("BRS")
		BRS->(DbSetOrder(2))

		If !dbSeek(xFilial("BRS")+BE4->BE4_CODOPE+cCodigo)

				dbSelectArea("BOZ")
				BOZ->(DbSetOrder(2))
				While dbSeek(xFilial("BOZ")+cCodigo)
					BOZ->(RecLock("BOZ",.F.))
						BOZ->(DbDelete())
					BOZ->(MsUnLock())
				EndDo

				Store Header "BOZ" to aHeaderEx For .T.

				DbSelectArea("BOZ")
				DbSetOrder(1)

				If ! BOZ->(DbSeek(xFilial("BOZ")+cGuia))
		 		  	 Store COLS Blank "BOZ" TO aColsEx FROM aHeaderEx
				Else
			   		 Store COLS "BOZ" TO aColsEx FROM aHeaderEx VETTRAB aVetTrab ;
			  		 While xFilial("BOZ")+BOZ->(BOZ_CODOPE+BOZ_ANOINT+BOZ_MESINT+BOZ_NUMINT) == xFilial("BOZ")+cGuia
				Endif

				oGetEx:aCols := aColsEx
				oGetEx:Refresh()

				If ExistBlock("PLBVSTM")
					 	ExecBlock("PLBVSTM",.F.,.F.,{cGuia, cCodigo, K_Excluir })
				EndIf
		Else
				Help("",1,"PL319V")
		EndIf
	End Transaction
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA092AVM ³ Autor ³ Thiago Guilherme 	³ Data ³ 25.02.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Agendar visita médica			  							    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092AVM(cChave)

Local I__f		:= 0
Local oDlg
Local oEnc
Local oGetBOZ
Local nOpca		:= 0
Local aHeaderAvm:= {}
Local aColsAvm	:= {}
Local aVetTrab	:= {}
Local aPosObj   := {}
Local aObjects	:= {}
Local aSize     := {}
Local aInfo     := {}
LOCAL nLeft := 0
LOCAL nLarg := 0
LOCAL nBottom := 0
LOCAL aChave	:= {}
LOCAL cTexto
LOCAL aBbt		:={}
LOCAL bOK        := {|| nTipo := oFolder:NOPTION,oDlg:End() }
LOCAL bCancel    := {|| oDlg:End() }
LOCAL cQtdNasc   := Space(2)
LOCAL aObFolder  := {}
LOCAL oFolder
LOCAL aPosOb

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao excluir visita médica																		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Copy "BOZ" To Memory Blank
Store Header "BOZ" to aHeaderAvm For .T.

DbSelectArea("BOZ")
DbSetOrder(1)

If ! BOZ->(DbSeek(xFilial("BOZ")+cChave))
   Store COLS Blank "BOZ" TO aColsAvm FROM aHeaderAvm
Else
   Store COLS "BOZ" TO aColsAvm FROM aHeaderAvm VETTRAB aVetTrab ;
   While BOZ->(xFilial("BOZ")+BOZ_CODOPE+BOZ_ANOINT+BOZ_MESINT+BOZ_NUMINT) == xFilial("BOZ")+cChave
Endif

Copy "BOZ" TO Memory Blank
M->BOZ_CODOPE := SUBSTR(cChave, 1, 4)
M->BOZ_ANOINT := SUBSTR(cChave, 5, 4)
M->BOZ_MESINT := SUBSTR(cChave, 9, 2)
M->BOZ_NUMINT := SUBSTR(cChave, 11)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo MEMO															     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aSize := MsAdvSize()
AAdd( aObjects, { 100, 25, .T., .T. } )
AAdd( aObjects, { 100, 40, .T., .T. } )
AAdd( aObjects, { 100, 33, .T., .T. } )

aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 1, 1 }
aPosObj := MsObjSize( aInfo, aObjects,.T. )

oGet := MSNewGetDados():New(aPosObj[1,2], nLeft, nBottom, nLarg, , "AlwaysTrue()", "AlwaysTrue()", "" , {}, 0, 9999, "AlwaysTrue()", "AlwaysTrue()", "AlwaysTrue()", , aHeaderAvm, aColsAvm, , "" )

nBottom	:= aPosObj[2,3]
nLeft = aPosObj[3,3]
nLarg := aPosObj[3,3] * 0.52
nBottom *= 0.190

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Panel/GRID																		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aPosObj[1,1],aPosObj[1,2]-1 To 500, 900 of oMainWnd PIXEL

@ aPosObj[1,1],005 SAY "Visitas Anteriores" SIZE 100,010 PIXEL OF oDlg //Visitas Anteriores

oGetBOZ := TPLSBrw():New(aPosObj[1,1]+9,005,aPosObj[3,3]+80,aPosObj[2,1]-10,nil  ,oDlg,nil    , {|| } ,nil    ,nil   ,nil, .F.   ,nil  ,.F.   ,nil   ,aHeaderAvm,aColsAvm,.F.,"BOZ",0,STR0005,nil,nil,nil,aVetTrab,,,,)
oGetBOZ:Obrowse:Disable()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Panel/Campos																  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 115,005 SAY "Nova Visita Profissional para a guia "+M->BOZ_CODOPE+"."+M->BOZ_ANOINT+"."+M->BOZ_NUMINT SIZE 400,010 PIXEL OF oDlg
oEnchoice := MSMGET():New("BOZ",1,3,,,,,{122,02,230,450},,,,,,oDlg,,,.F.)



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IF(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela),Eval({|| oDlg:End()}) ,(nOpca:=0,.F.))},{|| (nOpca:=1,.F.),oDlg:End()}) CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nOpca == 0
	M->BOZ_CODIGO	:= PADL(GetSXENum("BOZ","BOZ_CODIGO"), 6, "000001")
	PLUPTENC("BOZ",3)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. utilizado para adicionar novas opcoes ao menu           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLBVSTM")
	ExecBlock("PLBVSTM",.F.,.F.,{cChave, M->BOZ_CODIGO, 3 })
EndIf
RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA092OBS ³ Autor ³ Everton M. Fernandes	³ Data ³ 29.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe as observações no memo   							    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA092OBS(Obs,oMemo)
	cTexto := if(!EMPTY(Obs),Obs,"Sem descrição")
	oMemo:Refresh()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA092VLB ³ Autor ³ Thiago Guilherme	³ Data ³ 29.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Altera o estado do GRID para ser visualizado ou alterado   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA092VLB(nGrid, nFldr, aCols)
LOCAL oGrd
LOCAL nI
LOCAL nPersist

	If nGrid == 1
		If oBrwBOZ:aVetTrab[oBrwBOZ:oBrowse:nAt] !=0
			/* Alteração do tipo do campo MEMO para caracter, pois mesmo no estado visualizar é possível alterar o campo. No estado alterar
			o tipo é alterado para M*/
			oBrwBOZ:oBrowse:aHeader[5][8] := "C"
		   oBrwBOZ:EditRecord("BOZ",K_Visualizar, STR0202, oBrwBOZ:Linha(), oBrwBOZ:oBrowse:aCols, oBrwBOZ:oBrowse:aHeader,oBrwBOZ:bAfterEdit,oBrwBOZ:bMultaCols,oBrwBOZ:bAftCancel ) //"Visita Profissional"
		Else
			oBrwBOZ:oBrowse:aHeader[5][8] := "M"
		   oBrwBOZ:EditRecord("BOZ",K_Alterar, STR0202, oBrwBOZ:Linha(), oBrwBOZ:oBrowse:aCols, oBrwBOZ:oBrowse:aHeader,oBrwBOZ:bAfterEdit,oBrwBOZ:bMultaCols,oBrwBOZ:bAftCancel ) //"Visita Profissional"
		EndIf
	ElseIf nGrid == 2
		oGrd := &("oGetGrid"+CVALTOCHAR(nFldr))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe eventos relacionados a visita gravados o banco   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCols != NIL
				For nI := 1  To  Len(aCols)
					If aCols[nI][GdFieldPos("BRS_CODIGO",oGrd:oBrowse:aHeader)] == oBrwBOZ:aCols[oBrwBOZ:oBrowse:nAt][GdFieldPos("BOZ_CODIGO",oBrwBOZ:oBrowse:aHeader)];
						.AND. oGrd:AvetTrab[oGrd:oBrowse:nAt] != 0
						nPersist := 1
						EXIT
					EndIf
				Next nI
		EndIf

		If nPersist != 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se é uma nova linha para permitir alteracao			     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oBrwBOZ:aVetTrab[oBrwBOZ:oBrowse:nAt] !=0 .AND. oGrd:aVetTrab[oGrd:oBrowse:nAt] != 0
				oGrd:oBrowse:aHeader[GdFieldPos("BRS_OBSERV",oGrd:oBrowse:aHeader)][8] := "C"
				oGrd:lAddLine := .F.
                oGrd:EditRecord("BRS",K_Visualizar, STR0202, oGrd:Linha(), oGrd:oBrowse:aCols, oGrd:oBrowse:aHeader,oGrd:bAfterEdit,oGrd:bMultaCols,oGrd:bAftCancel ) //"Visita Profissional"
                
				oGrd := &("oGetGrid"+CVALTOCHAR(nFldr))
				oGrd:lAddLine := .F.
			Else
				oGrd:oBrowse:aHeader[GdFieldPos("BRS_OBSERV",oGrd:oBrowse:aHeader)][8] := "M"
				oGrd:EditRecord("BRS",K_Alterar,    STR0202, oGrd:Linha(), oGrd:oBrowse:aCols, oGrd:oBrowse:aHeader,oGrd:bAfterEdit,oGrd:bMultaCols,oGrd:bAftCancel )//"Visita Profissional"

				oGrd := &("oGetGrid"+CVALTOCHAR(nFldr))
				oGrd:lAddLine := .T.
			EndIf
		Else
				oGrd:oBrowse:aHeader[GdFieldPos("BRS_OBSERV",oGrd:oBrowse:aHeader)][8] := "C"
				oGrd:lAddLine := .F.
				oGrd:EditRecord("BRS",K_Visualizar, STR0202, oGrd:Linha(), oGrd:oBrowse:aCols, oGrd:oBrowse:aHeader,oGrd:bAfterEdit,oGrd:bMultaCols,oGrd:bAftCancel )  //"Visita Profissional"

				oGrd := &("oGetGrid"+CVALTOCHAR(nFldr))
				oGrd:lAddLine := .F.
		EndIf
	EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA92PRVI   ºAutor  ³Microsiga           º Data ³  04/03/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valid do Campo BE4_PRVINT para não permitir data de Previsao   º±±
±±º          ³ de internação menor que a data Base                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSA92PRVI()
LOCAL lret:=	.T.
If M->BE4_PRVINT < M->BE4_DTDIGI
	MsgStop("A data de previsão de internação deve ser maior ou igual a data de digitação da guia na aba sistema")
	lret:=.F.
Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checa Historico de (Des)bloqueio										 ³
	//³                      													 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  FindFunction("A360CHEBLO")
	lRet := A360CHEBLO(M->BE4_CODRDA,M->BE4_PRVINT)
Endif

Return(lret)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA92DTDG
 
@author  Karine Riquena Limp
@version P12
@since   20.07.17
/*/
//-------------------------------------------------------------------
Function PLSA92DTDG()
LOCAL lret:=	.T.

If !empty(M->BE4_PRVINT) .and. M->BE4_DTDIGI > M->BE4_PRVINT  
	MsgStop("A data de previsão de internação informada é maior que a data de digitação informada agora, altere a previsão de internação!")
	lret:=.F.
Endif

Return(lret)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA092RAS ³ Autor ³ Daher		        ³ Data ³ 27.05.13 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Rastrear autorizacoes a partir de uma liberacao            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA092RAS()
LOCAL cSQL
LOCAL cChave     := BE4->BE4_CODOPE+BE4->BE4_CODLDP+BE4->BE4_CODPEG+BE4->BE4_NUMERO
LOCAL cChaveSol  := BE4->BE4_CODOPE+BE4->BE4_ANOINT+BE4->BE4_MESINT+BE4->BE4_NUMINT
LOCAL aDados     := {}
LOCAL aCores	 := {}
LOCAL aCdCores	 := {}
LOCAL aArea      := GetArea()
LOCAL aCabec
LOCAL cTransNum  := "@R !!!!.!!!!.!!-!!!!!!!!"
LOCAL cTransGui  := "@R !!!!.!!!!.!!!!!!!!.!!!!!!!!"
LOCAL cTitulo    := "Guias geradas a partir da solicitacao número " +TransForm(cChaveSol,cTransNum)
LOCAL cStrFil    := ""
LOCAL cFiltro	 := ""
aCabec := {{"Numero da Guia",cTransGui,070},; //"Numero da Guia"
          	{'Data',"@D",40},;
          	{"Hora","@R !!:!!",020},; //"Hora"
          	{"RDA","@!",030},;
          	{'Nome RDA',"@!",150},;
          	{'Vlr Pagt.',"@!",50},;
          	{'Vlr Co-Part.',"@!",50,;
          	{'Tp. Guia',"@!",15}}}

If SIX->(MsSeek("BD5C"))
	BD5->(DbSetORder(12))
	cSQL := " SELECT '' AUT, BD5_DATPRO, BD5_HORPRO, "
	cSQL += " BD5_CODRDA, BD5_NOMRDA, BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO CTAMED, BD5_TIPGUI, BD5_VLRTPF,BD5_VLRPAG FROM "+BD5->(RetSQLName("BD5"))+" WHERE "
	cSQL += " BD5_FILIAL = '"+xFilial("BD5")+"' AND "
	cSQL += " (BD5_GUIINT = '"+cChave+"' ) AND "
	cSQL += " D_E_L_E_T_ = ' ' ORDER BY R_E_C_N_O_ "
	PLSQuery(cSQL,"TrbBD5")
	While ! TrbBD5->(Eof())
		If aScan(aDados,{|x| x[1] == TrbBD5->CTAMED }) == 0
			aadd(aDados,{TrbBD5->CTAMED,;
						TrbBD5->BD5_DATPRO,;
						TrbBD5->BD5_HORPRO,;
						TrbBD5->BD5_CODRDA,;
						TrbBD5->BD5_NOMRDA,;
						TRANSFORM(TrbBD5->BD5_VLRPAG,PLPMONEY_M),;
						TRANSFORM(TrbBD5->BD5_VLRTPF,PLPMONEY_M),;
						TrbBD5->BD5_TIPGUI})
		Endif
		TrbBD5->(DbSkip())
	Enddo
	TrbBD5->(DbCloseArea())
Endif


	cSQL := " SELECT '' AUT, BE4_DATPRO, BE4_HORPRO, "
	cSQL += " BE4_CODRDA, BE4_NOMRDA, BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO CTAMED, BE4_TIPGUI , BE4_VLRTPF, BE4_VLRPAG FROM "+BE4->(RetSQLName("BE4"))+" WHERE "
	cSQL += " BE4_FILIAL = '"+xFilial("BE4")+"' AND "
	cSQL += " (BE4_GUIINT = '"+cChave+"' ) AND "
	cSQL += " D_E_L_E_T_ = ' ' ORDER BY R_E_C_N_O_ "
	PLSQuery(cSQL,"TrbBE4")
	While ! TrbBE4->(Eof())
		If aScan(aDados,{|x| x[1] == TrbBE4->CTAMED }) == 0
			aadd(aDados,{TrbBE4->CTAMED,;
						TrbBE4->BE4_DATPRO,;
						TrbBE4->BE4_HORPRO,;
						TrbBE4->BE4_CODRDA,;
						TrbBE4->BE4_NOMRDA,;
						TRANSFORM(TrbBE4->BE4_VLRPAG,PLPMONEY_M),;
						TRANSFORM(TrbBE4->BE4_VLRTPF,PLPMONEY_M),;
						TrbBE4->BE4_TIPGUI})
		Endif
		TrbBE4->(DbSkip())
	Enddo
	TrbBE4->(DbCloseArea())

aCdCores  	:= { 	{ 'BR_VERMELHO'    	,OemtoAnsi('GUIA DE CONSULTA')},;
					{ 'BR_AZUL' 		,OemtoAnsi('GUIA DE SERVICOS')},;
					{ 'BR_LARANJA' 		,OemtoAnsi('GUIA DE SOL. INTERNACAO')},;
					{ 'BR_PRETO' 		,OemtoAnsi('GUIA DE REEMBOLSO')},;
					{ 'BR_VERDE' 		,OemtoAnsi('GUIA DE RES. INTERNACAO')},;
					{ 'BR_PINK' 		,OemtoAnsi('GUIA DE HOR. INDIVIDUAL')}}

aCores   := {	{ 'aDados[oCritica:nAt, 8] == "01"'	,aCdCores[1,1] },;
				{ 'aDados[oCritica:nAt, 8] == "02"'	,aCdCores[2,1] },;
				{ 'aDados[oCritica:nAt, 8] == "03"'	,aCdCores[3,1] },;
				{ 'aDados[oCritica:nAt, 8] == "04"'	,aCdCores[4,1] },;
				{ 'aDados[oCritica:nAt, 8] == "05"'	,aCdCores[5,1] },;
				{ 'aDados[oCritica:nAt, 8] == "06"'	,aCdCores[6,1] }}

bBloCli := {|x| pAbrGuia(x,aDados)}

//Abrir uma area para evitar erro de area já sendo usado em outro processamento
DbSelectArea("BEA")

If Len(aDados) >= 0
   PLSCRIGEN(aDados,aCabec,cTitulo,nil,nil,nil,nil,nil,nil,nil,nil,bBloCli,nil,nil,nil,nil,nil,nil,nil,aCores,aCdCores,nil,nil,nil,nil,nil)
Else
   Help("",1,"REGNOIS")
Endif

DbSelectArea("BEA")
DbSetOrder(1)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ pAbrGuia   ³ Autor ³ Daher		        ³ Data ³ 27.05.13 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Abre a guia selecionada                                    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function pAbrGuia(x,aDados)
LOCAL nRecBD5 := BD5->(Recno())
LOCAL nOrdBD5 := BD5->(IndexOrd())
LOCAL nRecBE4 := BE4->(Recno())
LOCAL nOrdBE4 := BE4->(IndexOrd())

If aDados[x:nAt,8] $ "01,02,04,06"
     BD5->(DbSetOrder(1))
     BD5->(MsSeek(xFilial('BD5')+aDados[x:nAt,1]))
	 PLVISGUI('BD5',BD5->(Recno()),K_Visualizar)
Elseif aDados[x:nAt,8] $ "03,05"
     BE4->(DbSetOrder(1))
     BE4->(MsSeek(xFilial('BE4')+aDados[x:nAt,1]))
     PLVISGUI('BE4',BE4->(Recno()),K_Visualizar)
Endif

BD5->(DbGoTo(nRecBD5))
BD5->(DbSetORder(nOrdBD5))
BE4->(DbGoTo(nRecBE4))
BE4->(DbSetORder(nOrdBE4))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS92B72   ³ Autor ³ Thiago Guilherme    ³ Data ³ 30.07.13 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exclui registros relacionados a auditoria                  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS92B72(cChave)

If PLSALIASEX("B72")
	dbSelectArea("B72")
	dbSetOrder(1)

	If dbSeek(xFilial("B72")+cChave)
		While !B72->(EOF()) .AND.  B72->(B72_ALIMOV+B72_RECMOV) == cChave
			B72->(RecLock("B72",.F.))
			B72->(DbDelete())
			B72->(MsUnLock())

			B72->(dbSkip())
		EndDo
	EndIf
EndIf
Return

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ P092DUPADD ³ Autor ³ Microsiga           ³ Data ³ 30.01.15 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Verifica se o procedimento generico possui mesma descrição ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
/*/
Function P092DUPADD(cBrw,cAliIte,cTipo)
	LOCAL lRet 			:= .T.
	LOCAL nX 				:= 0
	LOCAL nLenBrw			:= 0
	LOCAL cDesForPro		:= ""
	LOCAL cMsgGener         := ""
	PRIVATE nForDes		:= 0
	PRIVATE nDesPosPro	:= 0
	DEFAULT cTipo			:= "1"
	DEFAULT cBrw			:= "oBrwPro"
	DEFAULT cAliIte		:= PLSRetAut(cTipo)[3]

nDesPosPro	:= ascan(&(cBrw+":aHeader"),{ |x| x[2] == cAliIte+"_DESPRO"})
nLenBrw		:= len(&(cBrw+":aCols"))
	
if allTrim( M->&(cAliIte+"_CODPRO") ) $ allTrim(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen) 

	if nDesPosPro > 0
	
		for nX := 1 to nLenBrw
			
			nForDes 	:= nX
			cDesForPro	:= allTrim(&(cBrw+":aCols[nForDes,nDesPosPro]"))
			
			if allTrim(M->&(cAliIte+"_DESPRO")) == cDesForPro 
				Aviso( 	STR0021,STR0131,{STR0099}, 2 ) //"Criticas" ### "Este procedimento já foi adicionado."
				lRet := .F.
			endIf
			
		next nX
	endIf

	//verifica se é codigo generico e nao deixa passar sem informar a descricao e valor
	If M->&(cAliIte+"_VLRAPR") == 0 
	    cMsgGener += STR0194 //'Valor'
    EndIf
	
	If Empty(M->&(cAliIte+"_DESPRO")) 
 		cMsgGener += (Iif(!Empty(cMsgGener),"/","")+STR0195) //'Descrição'
    EndIf
	
	If &( cAliIte+"->( FieldPos('"+cAliIte+"_REGANV') )" ) > 0 .And. empty(M->&(cAliIte+"_REGANV")) .And. ;
	   	allTrim( M->&(cAliIte+"_CODPRO") ) $ allTrim(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodOpmGen)    
	   		cMsgGener += (Iif(!Empty(cMsgGener),"/","")+STR0196) //'Código ANVISA'
	EndIf
	
	If &( cAliIte+"->( FieldPos('"+cAliIte+"_REFFED') )" ) > 0 .And. empty(M->&(cAliIte+"_REFFED")) .And. ;
	   	allTrim( M->&(cAliIte+"_CODPRO") ) $ allTrim(__cCodMatGen+"-"+__cCodOpmGen) 
	   		cMsgGener += (Iif(!Empty(cMsgGener),"/","")+STR0197) //'Referência do Fabricante'
    EndIf
	
	If !Empty(cMsgGener)
		Aviso( STR0198,STR0199+cMsgGener, { STR0099 }, 2 ) //'Evento genérico!' ### 'Necessário informar o(s) campo(s): '
		lRet := .f.
	EndIf
else                                                	
	//verifica se é codigo generico e nao deixa passar sem informar a descricao e valor
	if AllTrim(GetNewPar("MV_PLSUNI","1")) == "1" .And. M->&(cAliIte+"_VLRAPR") == 0 .And. &( cAliIte+"->( FieldPos('"+cAliIte+"_PACOTE') )" ) > 0 .And. M->&(cAliIte+"_PACOTE") == "1" 
	    Aviso( STR0200,STR0201, { STR0099 }, 2 ) //'Pacote!' ### 'Necessário informar a descrição e o valor do evento'
		lRet := .f.
	endIf			
endIf

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ AjustaHELP ³ Autor ³ Microsiga           ³ Data ³ 01.09.15 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaHELP()

PutHelp("PPLSA092CAN",{STR0163,STR0164,""},{},{},.F.) //"Não foi possível realizar a operação." "A Guia selecionada foi cancelada."
PutHelp("SPLSA092CAN",{STR0165,"",""},{},{},.F.) //"Selecione outra Guia"

Return

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSAUTPTU
Nega a guia se não foi feita comunicação com PTU

@author	Microsiga
@since	17.07.17
@version P11
/*/
//---------------------------------------------------------------------------------------
Function PLSAUTPTU(cCritica,oBrw,oBrwCri,cOpcao)
LOCAL cCodCri := ""
LOCAL cDesCri := ""
LOCAL nSequen := 0
LOCAL nI := 0
LOCAL nPos := 0
LOCAL lAdd := .F.
DEFAULT cCritica := "__aCdCri230"
DEFAULT oBrw := Nil
DEFAULT oBrwCri := Nil
DEFAULT cOpcao  := "1"

Do Case
	//Nega todos os itens
	Case cOpcao  == "1"
		If PLSPOSGLO(PLSINTPAD(),cCritica[1],cCritica[2])
			cCodCri := cCritica[1]
			cDesCri := PLSBCTDESC()
		
			For nI := 1 To Len(oBrw:aCols)
		
				nPos := AScan(oBrw:aHeader,{|x| x[2] == oBrw:cAlias + "_NRTROL"})
				If Empty(oBrw:aCols[nI][nPos])
					//Pega a sequencia do item no aCols de itens
					nPos       := AScan(oBrw:aHeader,{|x| x[2] == oBrw:cAlias + "_SEQUEN"}) 
					nSequen    := oBrw:aCols[nI][nPos]     
				    //Verifica se o item ja foi adicionado no aCols de criticas
					nPos       := AScan(oBrwCri:aHeader,{|x| x[2] == oBrwCri:cAlias + "_SEQUEN"}) 
					nPosCodGlo := AScan(oBrwCri:aHeader,{|x| x[2] == oBrwCri:cAlias + "_CODGLO"}) 
					If AScan(oBrwCri:aCols,{|x| x[nPos] == nSequen .And. Alltrim(x[nPosCodGlo]) == Alltrim(cCodCri)}) == 0
						lAdd := .T.
					EndIf
				EndIf
		
				If lAdd
					oBrwCri:AddBlank()												
					
					oBrw:FieldPut(oBrw:cAlias + "_STATUS","0",nI)
					oBrw:FieldPut(oBrw:cAlias + "_IMGSTA","DISABLE",nI)
					oBrw:FieldPut(oBrw:cAlias + "_AUDITO","0",nI)
					
					nSequen := oBrw:aCols[nI,PLRETPOS(oBrw:cAlias + "_SEQUEN",oBrw:aHeader)]
					oBrwCri:FieldPut(oBrwCri:cAlias + "_SEQUEN",nSequen,Len(oBrwCri:aCols))
					oBrwCri:FieldPut(oBrwCri:cAlias + "_CODGLO",cCodCri,Len(oBrwCri:aCols))
					oBrwCri:FieldPut(oBrwCri:cAlias + "_DESGLO",cDesCri,Len(oBrwCri:aCols))
				EndIf	
			Next
		EndIf
    
    //Autoriza todos os itens
    Case cOpcao  == "2"
    	For nI := 1 To Len(oBrw:aCols)    
   			oBrw:FieldPut(oBrw:cAlias + "_STATUS","1",nI)
			oBrw:FieldPut(oBrw:cAlias + "_IMGSTA","ENABLE",nI)
			oBrw:FieldPut(oBrw:cAlias + "_AUDITO","0",nI)  
			
			nPos := AScan(oBrw:aHeader,{|x| x[2] == oBrw:cAlias + "_STATUS"})
			If oBrw:aCols[nI][nPos] == "1"
				nPos := AScan(oBrw:aHeader,{|x| x[2] == oBrw:cAlias + "_NIVAUT"}) 
				oBrw:aCols[nI][nPos] := "OLN"
				nPos := AScan(oBrw:aHeader,{|x| x[2] == oBrw:cAlias + "_NIVCRI"})      
				oBrw:aCols[nI][nPos] := ""
			EndIf	
    	Next
    	
    	For nI := 1 to len(oBrwCri:aCols)
    		oBrwCri:aCols[nI][len(oBrwCri:aCols[nI])] := .T.
    	Next
EndCase

Return        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA92MtCanºAutor  ³Roberto			 º Data ³  29/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza o cancelamento de uma sol. internação remote       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA92MtCan()

LOCAL oFont     := NIL
Local oDlg      := NIL
Local oGet      := NIL
Local oSay		:= NIL
Local cMotCan   := space(250)
Local cRetCan	:= ""
Local cNumGuia  := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

Local nOpca 		:= 2 //Ação padrão Fechar

Local lContinua 	:= .T.

//Verifica se guia já está faturada
if BE4->BE4_FASE == "4"
	MsgAlert(STR0219)//"Guia já faturada, não é permitido realizar o cancelamento."
	Return
endif

//Verifica se possui data de internação
if !Empty(BE4->BE4_DATPRO)
	MsgAlert(STR0220)//"Não será possível cancelar esta guia pois a data de internação já foi informada."
	Return
endif

if !MsgYesNo(STR0221)//"Serão cancelados os anexos clínicos e guias de prorrogação vinculados à esta guia. Deseja prosseguir?"
    Return
endif

DEFINE FONT oFont NAME "Arial" SIZE 000,-016 BOLD

	DEFINE MSDIALOG oDlg TITLE STR0222 FROM 008.2,003.3 TO 016,055 OF GetWndDefault() //"Informar motivo de cancelamento"
	@ 05, 10  Say oSay PROMPT STR0223 SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE //"Motivo de Cancelamento"
	@ 18, 10  MSGET oGet VAR cMotCan SIZE 190,10 OF oDlg FONT oFont PICTURE "@C" WHEN .T.  PIXEL

	bInAl		:= TButton():New(38,70, STR0224,,{ || nOpca := 0 , oDlg:End() } , 060, 012 ,,,,.T.) //'Cancelar Internação'
	bFechar	:= TButton():New(38,140, STR0225	,,{ || nOpca := 2 , oDlg:End() } , 040, 012 ,,,,.T.) //'Fechar'
	ACTIVATE MSDIALOG oDlg CENTERED

	if nOpca = 0
		BEA->(DbSetOrder(1))//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO
	 
		if BEA->( MsSeek(xFilial("BEA")+ cNumGuia ) )
	
			cRetCan := PLSA090CAN(.F.,cMotCan)
			
			//Se o cancelamento foi realizado, verificamos se existem prorrogações vinculadas			
			if empty(cRetCan)
                //Posiciona novamente no registro que foi selecionado para o cancelamento
                BE4->(DbSetOrder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
                BE4->(MsSeek(xFilial("BE4")+cNumGuia))
			
				B4Q->(DbSetOrder(4))//B4Q_FILIAL+B4Q_GUIREF
				if B4Q->(msSeek(xFilial("B4Q")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
					while (!B4Q->(EOF()) .and. ;
					       xFilial("B4Q")+B4Q->(B4Q_GUIREF) == xFilial("BE4")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT))
						
						//Realizamos o cancelamento de prorrogação se alguma ainda estiver ativa.	
						if B4Q->B4Q_CANCEL != "1"
                            PLSA09PCAN(.F.,.F.,,,,.T.)
			            endif
						
						B4Q->(DbSkip())
					enddo
				endif
			endif
		endif
	endif
Return
 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLEnvPT750
Envia uma transacao PTU 00750 - Data Internacao/Alta

@author  PLS TEAM
@version P11
@since   15/09/2017
/*/
//-------------------------------------------------------------------  
Function PLEnvPT750(cTpEvento,dData,lWeb,cMotAlt)
LOCAL aDados        := {}
LOCAL aGrvTraPTU    := {}
LOCAL cMsgXsdErr    := ""
LOCAL aRetOln       := {}
LOCAL lRet          := .F.
DEFAULT lWeb 		:= .F.
DEFAULT cMotAlt     := ""

PlsPtuPut("CD_TRANS","00750",aDados)
PlsPtuPut("CD_UNI_ORI",PlsIntPad(),aDados)
PlsPtuPut("CD_UNI_DES",Substr(BE4->BE4_MATANT,1,4),aDados)
PlsPtuPut("NR_IDENT_O",Strzero(Val(BE4->BE4_NRTROL),10),aDados)

PlsPtuPut("CD_UNI"  ,Substr(BE4->BE4_MATANT,1,4),aDados)
PlsPtuPut("ID_BENEF",Substr(BE4->BE4_MATANT,5,13),aDados)
PlsPtuPut("NR_VIA_CAR",cValtoChar(BE4->BE4_VIACAR),aDados)
PlsPtuPut("ID_RN"    ,IIF(BE4->BE4_ATERNA=="1","S","N"),aDados)
PlsPtuPut("DT_EVENTO",DtoS(dData),aDados)
PlsPtuPut("TP_EVENTO",cTpEvento,aDados)      
BQR->(DbSetOrder(1))//BQR_FILIAL+BQR_GRPINT+BQR_TIPINT 
If cTpEvento == "I"
	If BQR->(MsSeek(xFilial("BQR")+BE4->(BE4_GRPINT+BE4_TIPINT)))
		PlsPtuPut("TP_INTERN",BQR->BQR_CODEDI,aDados)  
	EndIf
Else  
	BTU->(DbSetOrder(4))//BTU_FILIAL+BTU_CODTAB+BTU_VLRSIS+BTU_ALIAS
	If BTU->(MsSeek(xFilial("BTU")+"39"+xFilial("BIY")+cMotAlt)) 
    	PlsPtuPut("MT_ENCERR",AllTrim(BTU->BTU_CDTERM),aDados)
	EndIf
	//PlsPtuPut("MT_ENCERR",AllTrim(PLSVARVINC('39',,cMotAlt) ),aDados)	
EndIf

aGrvTraPTU := {AllTrim(BE4->BE4_NRTROL),PlsPtuGet("CD_TRANS",aDados),PlsIntPad(),PlsPtuGet("CD_UNI_DES",aDados), Alltrim(BE4->BE4_NOMUSR)}
If lWeb
	aRetOln := PlsPtuOln(aDados,nil,AllTrim(BE4->BE4_NRTROL)+"."+Subs(PLSINTPAD(),2,3),,lWeb,aGrvTraPTU,,,@cMsgXsdErr ) 
Else
	MsAguarde( {|| aRetOln := PlsPtuOln(aDados,nil,AllTrim(BE4->BE4_NRTROL)+"."+Subs(PLSINTPAD(),2,3),,lWeb,aGrvTraPTU,,,@cMsgXsdErr ) }, STR0226 , STR0227, .F.) //'Comunicando' ### "Aguarde"
EndIf

//Verifica se houve retorno 00210/00310 (falha na transacao)
If Len(aRetOln) > 0 .And. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00310"
	BCT->(DbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2
 	If BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+PlsPtuGet("CD_MENS_EX",aRetOln[1])))
   		cMsgXsdErr := BCT->(BCT_PROPRI+BCT_CODGLO)+" - "+BCT->BCT_DESCRI
  	ElseIf PlsPtuGet("CD_MENS_EX",aRetOln[1]) == "4003"
  	    PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
		cMsgXsdErr := __aCdCri065[1]+" - "+PLSBCTDESC()//"Time out.Operadora fora do Ar."
   	Else
   		cMsgXsdErr := "codigoMensagemExcecao: "+PlsPtuGet("CD_MENS_EX",aRetOln[1])//"Entre em contato com o administrador do sistema."
   	EndIf    
ElseIf Len(aRetOln) > 0	   	
	//Verifica se foi enviada a transacao correta na resposta       			
	If PlsPtuGet("CD_TRANS ",aRetOln[1]) <> "00309"
		cMsgXsdErr := STR0228 //"Transação de resposta diferente de 00309"
	
	//Recebeu o 00309 mas ocorreu erro de guia				 						    
	ElseIf PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "2" .And. Len(aRetOln[2]) == 0
		cMsgXsdErr := STR0229 //"Guia Inexistente"
	
	//Transacao concluida com sucesso
	ElseIf PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "1" .And. Len(aRetOln[2]) == 0
		lRet := .T.
	EndIf
EndIf

Return {lRet,cMsgXsdErr}

