#INCLUDE "plsa773.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE 'MSOBJECT.CH'
#INCLUDE "TCBROWSE.CH"
#INCLUDE "RwMake.ch"
#INCLUDE "MsOle.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TOPCONN.CH"

#Define CRLF Chr(13) + Chr(10)
#Define OLECREATELINK  400
#Define OLECLOSELINK   401
#Define OLEOPENFILE    403
#Define OLESAVEASFILE  405
#Define OLECLOSEFILE   406
#Define OLESETPROPERTY 412
#Define OLEWDVISIBLE   "206"
#Define WDFORMATTEXT   "2"
#Define WDFORMATPDF    "17" // Formato PDF

STATIC __aTables := {{"BEA", "Atendimento", 1}, {"B44", "Aut. Reembolso", 1}, {"B4A", "Anexos Clínicos", 1}, {"B4Q", "Prorrogação de internação", 1}}	//	{Alias, Descrição, Indice da Guia}
STATIC __lAutoma := .F.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA773 ³ Autor ³ Totvs.                 ³ Data ³ 03.06.13 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Rotina para controle de Protocolos e confecção da Justifi_ ³±±±
±±³          ³ cativa de Negativa.                                        ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSA773().                                                 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ PLS                                                        ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³          ³      ³             ³                                       ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA773()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define opcoes da rotina...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cAlias	:= "B00"
PRIVATE cFiltro := "@"+cAlias+"_FILIAL = '"+xFilial(cAlias)+"' AND D_E_L_E_T_ = ' '"
PRIVATE aCdCores:= {	;
	{ 'BR_VERDE'	,'Pendente' },; 	//'Pendente'
	{ 'BR_VERMELHO'	,'Encerrado' }}  	//'Encerrado'
PRIVATE aCores 	:= {	;
	{ cAlias+'_STATUS = "1"',aCdCores[1,1] },;	//'Pendente'
	{ cAlias+'_STATUS = "2"',aCdCores[2,1] }} 	//'Encerrado'
PRIVATE aRotina		:= MenuDef()
PRIVATE cCadastro	:= PLSRetTit(cAlias)
Private cChvGui	  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as criticas da rotina...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PL773CarCr()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para WebServices, filtra a rotina                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_PL395WS","0") == "1"  
	
	cPerg := "PL773WEB"
	If Pergunte(cPerg,.T.)
		cUniSol   := mv_par01
		nStatus   := mv_par02
		dDatDe    := mv_par03
		dDatAte   := mv_par04
		nTipPro   := mv_par05
		nCancel   := mv_par06
		
		If !Empty(cUniSol)
			cFiltro += " AND B00_OPESOL = '"+cUniSol+"' "
		EndIf	  
		If cValtoChar(nStatus) $ "1234"
			cFiltro += " AND B00_STATUS = '"+cValtoChar(nStatus)+"' "  
		EndIf  
		If cValtoChar(nTipPro) $ "123"
			cFiltro += " AND B00_TIPPRO = '"+cValtoChar(nTipPro)+"' "  
		EndIf   
		
		If cValtoChar(nCancel) == "1"
			cFiltro += " AND B00_CANCEL <> '0' "  
		ElseIf cValtoChar(nCancel) == "2"
			cFiltro += " AND B00_CANCEL = '1' "  
		EndIf
			 
		If !Empty(dDatDe)
			cFiltro += " AND B00_DTPROT >= '"+ Dtos(dDatDe) +"' "	  
		EndIf
		If !Empty(dDatAte)
			cFiltro += " AND B00_DTPROT <= '"+ Dtos(dDatAte) +"' "	  
		EndIf	
    EndIf     
    
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta mbrowse padrao...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
(cAlias)->(DbSetOrder(1))
DbSelectArea(cAlias)
SET FILTER TO &cFiltro
(cAlias)->(DbSeek(xFilial(cAlias)))
(cAlias)->(mBrowse(006,001,022,075,cAlias,nil,nil,nil,nil,nil,aCores,nil,nil,nil,nil,.F.,nil,nil,""/*cFiltro*/))
(cAlias)->(DbClearFilter())
SET KEY VK_F12 TO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MenuDef  ³ Autor ³ Totvs                 ³ Data ³03/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local lRN395 	:= GetNewPar("MV_PLRN395","0") == "1"
Local lWebRN395 := GetNewPar("MV_PL395WS","0") == "1"  

Private aRotina := {}

Aadd(aRotina,{ OemtoAnsi("Pesquisar")   , 'AxPesqui'          , 0, K_Pesquisar 	, 0, .F.}) //"Pesquisar"
If lWebRN395
	Aadd(aRotina,{ OemtoAnsi("Visualizar")  , 'PL773GETRN'        , 0, K_Visualizar	, 0, Nil}) //"Visualizar"
Else
	Aadd(aRotina,{ OemtoAnsi("Visualizar")  , 'AxVisual'          , 0, K_Visualizar	, 0, Nil}) //"Visualizar"
EndIf 
If lRN395
	Aadd(aRotina,{ OemtoAnsi("Cria nº protocolo") , 'PL773IncPr'        , 0, K_Incluir   	, 0, Nil}) //"Cria nº protocolo"
Else
	Aadd(aRotina,{ OemtoAnsi("Incluir")     , 'PLSA773Inc'        , 0, K_Incluir   	, 0, Nil}) //"Incluir"
EndIf
Aadd(aRotina,{ OemtoAnsi("Alterar")     , 'PLSA773Alt'        , 0, K_Alterar   	, 0, Nil}) //"Alterar"
Aadd(aRotina,{ OemtoAnsi("Negativas Atend."), 'PLSA773Ger'     , 0, K_Visualizar	, 0, Nil}) //"Negativas Atend."
Aadd(aRotina,{ OemtoAnsi("Legenda")     , 'PL773LEG(aCdCores)' , 0, K_Visualizar	, 0, .F.}) //"Legenda"

If lRN395
	Aadd(aRotina,{ OemtoAnsi("Gera PDF")        , 'PLSA773Pro(.F.)', 0, K_Visualizar	, 0, Nil})
	Aadd(aRotina,{ OemtoAnsi("Impressão/E-mail"), 'PLSA773Pro(.T.)', 0, K_Visualizar	, 0, Nil})
	Aadd(aRotina,{ OemtoAnsi("Visualizar Guia") , 'PL773VsGui'     , 0, K_Visualizar	, 0, Nil})
	If lWebRN395  
		Aadd(aRotina,{ OemtoAnsi("Complementar Protocolo") , 'PL773COMWS()' , 0, K_Alterar    	, 0, Nil}) 
		Aadd(aRotina,{ OemtoAnsi("Responder Protocolo")    , 'PL773RESWS()' , 0, K_Alterar    	, 0, Nil}) 
		Aadd(aRotina,{ OemtoAnsi("Cons. Status Protoc.")   , 'PL773STAWS()' , 0, K_Alterar    	, 0, Nil}) 
		Aadd(aRotina,{ OemtoAnsi("Cons. Histórico Protoc."), 'PL773HISWS()' , 0, K_Alterar    	, 0, Nil}) 
	EndIf	
EndIf

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PLSA773Inc ³ Autor ³ Totvs                 ³ Data ³03/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusao de dados.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA773 - Protocolo de Justificativas de Negativa           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA773Inc(cAlias,nReg,nOpc)
Return ( AxInclui(cAlias,nReg,nOpc,,,,"PLA773bOk(nOpc)") )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PLSA773Alt ³ Autor ³ Totvs                 ³ Data ³03/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alteracao de dados.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA773 - Protocolo de Justificativas de Negativa           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA773Alt(cAlias,nReg,nOpc)

Local aButtons := {}

If B00->(B00_STATUS) == "2" .And. GetNewPar("MV_PLRN395","0") != "1"
	MsgInfo(STR0001) //"Não é possível alterar Protocolos Encerrados !!!"
Else

	//Ponto de Entrada para adicionar item no botão outras ações
	If ExistBlock( "PL773BUT" )
		aButtons := ExecBlock("PL773BUT",.F.,.F.,{aButtons})
	EndIf

	nOpc := K_Alterar
	AxAltera(cAlias,nReg,nOpc,,,,,"PLA773bOk(nOpc)",,,aButtons)
EndIf

Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PL773LEG  ³ Autor ³ Totvs                 ³ Data ³03/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe a legenda...                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA773 - Protocolo de Justificativas de Negativa           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL773LEG(aBkCores)

BrwLegenda(cCadastro,STR0002,aBkCores) //"Status"

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLA773bOk ³ Autor ³ Totvs                 ³ Data ³03/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de validacao do botao "Confirmar".                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA773 - Protocolo de Justificativas de Negativa           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLA773bOk(nOpc)

LOCAL aArea 	:= GetArea()
LOCAL lRet		:= .T.
LOCAL cAlias	:= GetNextAlias()
LOCAL cSql		:= ""
LOCAL cMsg 		:= ""
LOCAL cNumProto := ""
LOCAL cEmail	:= ""
LOCAL cNumGuia	:= M->B00_NUMGUI
LOCAL cContato	:= M->B00_CONTAT
LOCAL cDtHrProt := DTOC(M->B00_DTPROT) +" - "+ Transform(M->B00_HRPROT,'@R !!:!!')
LOCAL cStatus	:= IIf(M->B00_STATUS == "1","PENDENTE","ENCERRADO")
LOCAL cAliasGuia := IIf(!EMPTY(M->B00_ALIGUI), M->B00_ALIGUI,"BEA")
LOCAL aGuia		:= PA773Guia(AllTrim(M->B00_NUMGUI), cAliasGuia)
LOCAL cNomBene	:= ""
LOCAL oBot01
LOCAL oDlgFim
LOCAL oSay
LOCAL oFontNum
LOCAL oFontAutor
LOCAL oFontTit
LOCAL cField := ""
LOCAL lRn395 := GetNewPar("MV_PLRN395","0") == "1"

DEFAULT nOpc    := K_Visualizar

If len(aGuia) == 0 
	MsgStop( STR0033,STR0009 )//"Problema !!! Guia não encontrada !!!", "Atenção",
Else
	cNomBene := aGuia[07]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos obrigatorios   													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRn395
	If M->B00_TIPPRO == "1" .And. Empty(M->B00_NUMGUI)
		lRet := .F.
		Aviso( STR0009, 'O campo "Numero Guia" na aba "Guias" é obrigatório.' , {STR0006} ) 	// "Atenção","Problema !!! Negativas não encontradas !!!"
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao do E-mail. 													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. nOpc <> K_Visualizar
	If lRet .AND. EMPTY(M->B00_EMAILD) .AND. M->B00_TPENVI == "2" .AND. nOpc == K_Alterar // Alteracao
		If len(aGuia) > 0 .And. !EMPTY(aGuia[09])
			M->B00_EMAILD := Posicione("BTS",1,xFilial("BTS")+aGuia[09],"BTS_EMAIL")
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a opção for email e estiver vazio o campo de email deve-se criticar. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .AND. EMPTY(M->B00_EMAILD) .AND. M->B00_TPENVI == "2" // Tipo de envio - Email
		lRet := .F.
		Aviso( STR0003, STR0004, {STR0006} ) //"E-mail Inválido", "Para o envio de e-mail deve-se inserir o E-mail do Destinatário corretamente !!!"
	EndIf
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se tiver o campo de email preenchido deve-se validar, independente se   ³
	//³ houver como opcao tipo de envio email ou nao...							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .AND. !EMPTY(cEmail := M->B00_EMAILD)
		If ( nResto := At( "@", cEmail )) > 0 .and. At( "@", Right( cEmail, LEN( cEmail ) - nResto )) == 0
			If ( nResto := At( ".", Right( cEmail, LEN( cEmail ) - nResto ))) > 0
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Else
			lRet := .F.
		Endif
		If !lRet
			Aviso( STR0003, STR0004, {STR0006} ) //"E-mail Inválido", "Para o envio de e-mail deve-se inserir o E-mail do Destinatário corretamente !!!"
		EndIf
	EndIf
EndIf

If lRet .AND. nOpc == K_Incluir
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ja existe no numero de guia apresentado um protocolo vincula_³
	//³ do e mostra os dados para o usuário decidir se deseja realmente gravar   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSql := "SELECT B00_COD, B00_CONTAT, B00_NUMGUI, B00_DTPROT, B00_HRPROT, B00_STATUS " + CRLF
	cSql += ", B00_ALIGUI "
	cSql += "FROM "+ RetSqlName("B00") + " " 												+ CRLF
	cSql += "WHERE D_E_L_E_T_ = ' ' AND B00_FILIAL = '"+ xFilial("B00") + "' " 				+ CRLF
	cSql += "AND B00_STATUS = '1' AND B00_NUMGUI = '" + M->B00_NUMGUI + "' " 				+ CRLF
	cSql += "AND B00_ALIGUI = '" + M->B00_ALIGUI + "' "

	cSql := ChangeQuery(cSql)
	DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,cSql) , cAlias , .F. , .T. )
	(cAlias)->(DBGoTop())
	If (cAlias)->(!Eof())
		cMsg := "Ja existe um Protocolo Pendente vinculado a esta Guia." + chr(13) 	// "Ja existe um Protocolo Pendente vinculado a esta Guia."
		cMsg += "Deseja incluir o protocolo assim mesmo ?" + chr(13) 		   		// "Deseja incluir o protocolo assim mesmo ?"
		cMsg += chr(13)
		cMsg += "Protocolo Anterior.: " + (cAlias)->(B00_COD) 		+ chr(13) 		// "Protocolo Anterior.: "
		cMsg += "Contato Prot. Ante.: " + (cAlias)->(B00_CONTAT) 	+ chr(13)  		// "Contato Prot. Ante.: "
		cMsg += "Num. Guia Anterior.: " + (cAlias)->(B00_NUMGUI) 	+ chr(13)  		// "Num. Guia Anterior.: "
		cMsg += "Data/Hora Anterior.: " + DToC( SToD((cAlias)->(B00_DTPROT)) ) +" - "+ Transform( (cAlias)->(B00_HRPROT),'@R !!:!!' ) + chr(13) // "Data/Hora Anterior.: "
		cMsg += "Status Prot. Anter.: " + IIf((cAlias)->(B00_STATUS) == "1","PENDENTE","ENCERRADO") + chr(13) // "Status Prot. Anter.: "
		cMsg += chr(13)
		lRet := MsgYesNo(OemtoAnsi(cMsg)) //"Ja existe um Protocolo vinculado a esta Guia. Deseja incluir o protocolo assim mesmo ?"
	EndIf
Endif
If lRet .And. nOpc == K_Incluir // Inclusao

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define fontes utilizadas somente nesta funcao...                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE FONT oFontNum   NAME "Arial" SIZE 000,-016 BOLD
	DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-019 BOLD
	DEFINE FONT oFontTit   NAME "Arial" SIZE 000,-011 BOLD

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera o numero do Protocolo e trata a inclusao do numero do protocolo 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	M->B00_COD := cNumProto := GETSX8NUM("B00","B00_COD")

	DEFINE MSDIALOG oDlgFim TITLE STR0005 FROM 009,000 TO 024,070 OF GetWndDefault() //"Dados do Protocolo"

	oBot01 := SButton():New(097, 005, 1, {|| oDlgFim:End() },,.T.)
	oBot01:cToolTip := STR0006 //"Fechar Tela"

	@ 007,005 SAY oSay PROMPT STR0025   SIZE 220,010 OF oDlgFim PIXEL FONT oFontNum //"Número Protocolo.: "
	@ 006,095 SAY oSay PROMPT cNumProto SIZE 220,010 OF oDlgFim PIXEL FONT oFontAutor COLOR CLR_HRED

	@ 025,005 SAY oSay PROMPT STR0026   SIZE 220,010 OF oDlgFim PIXEL	//"Nº Guia Atendimento"
	@ 023,065 MSGET Transform(cNumGuia,'@R !!!!.!!!!.!!-!!!!!!!!') 	SIZE 205,010 OF oDlgFim WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	@ 040,005 SAY oSay PROMPT STR0027   SIZE 220,010 OF oDlgFim PIXEL 		//"Beneficiário"
	@ 038,065 MSGET cNomBene            SIZE 205,010 OF oDlgFim WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	@ 055,005 SAY oSay PROMPT STR0028   SIZE 220,010 OF oDlgFim PIXEL 	   		//"Contato"
	@ 053,065 MSGET cContato            SIZE 205,010 OF oDlgFim WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	@ 070,005 SAY oSay PROMPT STR0029   SIZE 220,010 OF oDlgFim PIXEL  //"Data e Hora Protocolo"
	@ 068,065 MSGET cDtHrProt           SIZE 205,010 OF oDlgFim WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	@ 085,005 SAY oSay PROMPT STR0002   SIZE 220,010 OF oDlgFim PIXEL  //"Status"
	@ 083,065 MSGET cStatus             SIZE 205,010 OF oDlgFim WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	ACTIVATE MSDIALOG oDlgFim CENTERED on init if(Type('oBot01') == "O",oBot01:SetFocus(),Nil)
	B00->( ConfirmSx8() )
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RN 395 altera o cabecalho com o numero do protocolo                  	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. nOpc == K_Alterar .And. lRn395 .And. !Empty(M->B00_NUMGUI)

	cAlias := M->B00_ALIGUI
	If cAlias == "BEA"
		BEA->(DbSetOrder(1))//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
		If BEA->(DbSeek(xFilial("BEA")+M->B00_NUMGUI))
			If Empty(BEA->BEA_PROATE)
				BEA->(RecLock("BEA",.F.))
				BEA->BEA_PROATE := M->B00_COD
				BEA->(MsUnLock())
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a internacao                                            	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BE4->(DbSetOrder(2))//BE4_FILIAL + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
			If BEA->BEA_TIPO == "3" .And. BE4->(DbSeek(xFilial("BE4")+M->B00_NUMGUI)) .And. Empty(BE4->BE4_PROATE)
				BE4->(RecLock("BE4",.F.))
				BE4->BE4_PROATE := M->B00_COD
				BE4->(MsUnLock())
			EndIf
		EndIf

	ElseIf cAlias == "B4A"
		B4A->(DbSetOrder(1))//B4A_FILIAL + B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT + DTOS(B4A_DATPRO) + B4A_HORPRO
		If B4A->(DbSeek(xFilial("B4A")+M->B00_NUMGUI)) .And. Empty(B4A->B4A_PROATE)
			B4A->(RecLock("B4A",.F.))
			B4A->B4A_PROATE := M->B00_COD
			B4A->(MsUnLock())
		EndIf

	ElseIf cAlias == "B44"
		B44->(DbSetOrder(1))//B44_FILIAL+B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT
		If B44->(DbSeek(xFilial("B44")+M->B00_NUMGUI)) .And. Empty(B44->B44_PROATE)
			B44->(RecLock("B44",.F.))
			B44->B44_PROATE := M->B00_COD
			B44->(MsUnLock())
		EndIf

	ElseIf cAlias == "B4Q"
		B4Q->(DbSetOrder(1))//B4Q_FILIAL + B4Q_OPEMOV + B4Q_ANOAUT + B4Q_MESAUT + B4Q_NUMAUT + DTOS(B4Q_DATPRO) + B4Q_HORPRO
		If B4Q->(DbSeek(xFilial("B4Q")+M->B00_NUMGUI)) .And. Empty(B4Q->B4Q_PROATE)
			B4Q->(RecLock("B4Q",.F.))
			B4Q->B4Q_PROATE := M->B00_COD
			B4Q->(MsUnLock())
		EndIf

	EndIf

	cNumProto := M->B00_COD

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe tela com o numero da guia alterada                               	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgFim TITLE STR0005 FROM 009,000 TO 024,070 OF GetWndDefault() //"Dados do Protocolo"

	oBot01 := SButton():New(097, 005, 1, {|| oDlgFim:End() },,.T.)
	oBot01:cToolTip := STR0006 //"Fechar Tela"

	@ 007,005 SAY oSay PROMPT STR0025   SIZE 220,010 OF oDlgFim PIXEL FONT oFontNum //"Número Protocolo.: "
	@ 006,095 SAY oSay PROMPT cNumProto SIZE 220,010 OF oDlgFim PIXEL FONT oFontAutor COLOR CLR_HRED

	@ 025,005 SAY oSay PROMPT STR0026   SIZE 220,010 OF oDlgFim PIXEL	//"Nº Guia Atendimento"
	@ 023,065 MSGET Transform(cNumGuia,'@R !!!!.!!!!.!!-!!!!!!!!') 	SIZE 205,010 OF oDlgFim WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	@ 040,005 SAY oSay PROMPT STR0027   SIZE 220,010 OF oDlgFim PIXEL 		//"Beneficiário"
	@ 038,065 MSGET cNomBene            SIZE 205,010 OF oDlgFim WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	@ 055,005 SAY oSay PROMPT STR0028   SIZE 220,010 OF oDlgFim PIXEL 	   		//"Contato"
	@ 053,065 MSGET cContato            SIZE 205,010 OF oDlgFim WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	@ 070,005 SAY oSay PROMPT STR0029   SIZE 220,010 OF oDlgFim PIXEL  //"Data e Hora Protocolo"
	@ 068,065 MSGET cDtHrProt           SIZE 205,010 OF oDlgFim WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	@ 085,005 SAY oSay PROMPT STR0002   SIZE 220,010 OF oDlgFim PIXEL  //"Status"
	@ 083,065 MSGET cStatus             SIZE 205,010 OF oDlgFim WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	ACTIVATE MSDIALOG oDlgFim CENTERED on init if(Type('oBot01') == "O",oBot01:SetFocus(),Nil)
EndIf
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLA773VAL ³ Autor ³ Totvs                 ³ Data ³03/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação do Número da Guia                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA773 - Protocolo de Justificativas de Negativa           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLA773VAL()

LOCAL lRet := .F.
LOCAL aArea := GetArea()
LOCAL cChave := AllTrim(M->B00_NUMGUI)
LOCAL cAliasCab := ""
LOCAL cAliasCri := ""
LOCAL cMatVida := ""
LOCAL lRN395 := GetNewPar("MV_PLRN395", "0") == "1"
LOCAL nFor := 0
LOCAL cStatAut := "1" 

If EMPTY(cChave)
	M->B00_DTATEN := ""
	M->B00_HRATEN := ""
Else

	If LEN(cChave) < 18 
		MSGSTOP(STR0092,STR0009) //"Número imcompleto, uma guia possui 18 posições."#Atenção
		Return .F.
	EndIf 
	
	//	Localiza Alias da Guia e da Crítica
	FOR nFor := 1 TO LEN(__aTables)
		cAliasCab := __aTables[nFor, 1]	//	Cabeçalho da Guia
		(cAliasCab)->(DBSETORDER(__aTables[nFor, 3]))	//	_FILIAL + _OPEMOV + _ANOAUT + _MESAUT + _NUMAUT
		lRet := (cAliasCab)->(DBSEEK(XFILIAL() + cChave))
		IF lRet
			EXIT
		ENDIF
	NEXT
	
	IF lRet .AND. &(cAliasCab+"->"+cAliasCab+"_AUDITO") == "0"  
		cAliasCri := PLSRELGUI(cAliasCab, 3)	//	Crítica de Procedimento
		(cAliasCri)->(DBSETORDER(1))
		lRet := (cAliasCri)->(DBSEEK(XFILIAL() + cChave))
		IF !lRet
			cAliasCri := PLSRELGUI(cAliasCab, 3, .T.)	//	Crítica de Evolução
			IF !EMPTY(cAliasCri)	//	Só irá pesquisar se existir a Evolução para esse tipo de Guia
				lRet := (cAliasCri)->(DBSEEK(XFILIAL() + cChave))
			ENDIF
			
				B53->(DBSETORDER(1))
				lRet := (B53->(DBSEEK(XFILIAL() + cChave)) .AND. B53->B53_STATUS > "1") //	Auditoria
			
			If cAliasCab == "B44" 
				cStatAut := "2"
			EndIf 
			
			IF !lRet .OR. &(cAliasCab+"->"+cAliasCab+"_STATUS") == cStatAut 
				MSGSTOP(STR0030,STR0009) 	// "Não exsitem Negativas para este Atendimento !!!", "Atenção"
				ENDIF
			ENDIF

	ELSEIF &(cAliasCab+"->"+cAliasCab+"_AUDITO") == "1" 
	
		MSGSTOP(STR0093, STR0009) //"Guia em análise pela auditoria!"#"Atenção"
		lRet := .F.
	ELSE
		lRet := .F.
		MSGSTOP( STR0033,STR0009 ) 			//  "Problema !!! Guia não encontrada !!!", "Atenção",
	ENDIF

	IF lRet .AND. &(cAliasCab+"->"+cAliasCab+"_AUDITO") == "0" 
		M->B00_ALIGUI := cAliasCab
		If cAliasCab == "BEA"
			cMatVida := BEA->BEA_MATVID
		ELSE
			cMatVida := Posicione("BA1", 2, xFilial("BA1")+&(cAliasCab + "->(" + cAliasCab + "_OPEUSR+" + cAliasCab + "_CODEMP+" + cAliasCab + "_MATRIC+" + cAliasCab + "_TIPREG)"), "BA1_MATVID")
		EndIf
		If !EMPTY(cAliasCri) .AND. !(cAliasCri)->(EOF()) .AND. &(cAliasCab+"->"+cAliasCab+"_STATUS") != cStatAut .Or. lRN395 
			M->B00_DTATEN := &(cAliasCab + "->" + cAliasCab + "_DATPRO")

			// Campos de preenchimento automatico somente para a RN 395
			If lRN395
				If GetNewPar("MV_PLSUNI","1") == "1" .And. &(cAliasCab + "->" + cAliasCab + "_CODEMP") == GetNewPar("MV_PLSGEIN","0050")
					M->B00_INTERC := "1"
				EndIf
				M->B00_CONTAT := &(cAliasCab + "->" + cAliasCab + "_NOMUSR")
				If &(cAliasCab + "->" + cAliasCab + "_AUDITO") == "1"
					M->B00_STATE := "4"  //4=Pendente Auditoria
				ElseIf &(cAliasCab + "->" + cAliasCab + "_STATUS") $ "1/4/5"
					M->B00_STATE := "1" //1=Autorizada
				ElseIf &(cAliasCab + "->" + cAliasCab + "_STATUS") == "2"
					M->B00_STATE := "2" //2=Autorizada Parcialmente
				ElseIf &(cAliasCab + "->" + cAliasCab + "_STATUS") == "3"
					M->B00_STATE := "3" //3=Nao Autorizada
				EndIf
				M->B00_MATRIC := &(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP+"+cAliasCab+"_MATRIC+"+cAliasCab+"_TIPREG+"+cAliasCab+"_DIGITO)")
				M->B00_NOMUSR := &(cAliasCab+"->" +cAliasCab+"_NOMUSR")
			EndIf

			If cAliasCab <> "B4A" .AND. cAliasCab <> "B4Q" .AND. !EMPTY(&(cAliasCab + "->" + cAliasCab + "_HORPRO"))
				M->B00_HRATEN := &(cAliasCab + "->" + cAliasCab + "_HORPRO")
			Else
				M->B00_HRATEN := "0000"
			EndIf
		Else 
			B53->(DBSETORDER(1))
			IF B53->(DBSEEK(XFILIAL()+cChave)) .AND. &(cAliasCab+"->"+cAliasCab+"_STATUS") != cStatAut 
				M->B00_DTATEN := B53->B53_DATMOV
				M->B00_HRATEN := B53->B53_HORMOV
			ELSE	//	Se existir um senário ainda não tratado
				lRet := .F.
				MsgStop(STR0030, STR0009) //	"Não exitem Negativas para este Atendimento !!!", "Atenção!"
				RestArea(aArea)
				B00->(DbClearFilter())
			ENDIF
		Endif
	ELSEIF lRet .AND. &(cAliasCab+"->"+cAliasCab+"_AUDITO") == "1" 
	
		MSGSTOP(STR0093, STR0009) //"Guia em análise pela auditoria!"#"Atenção"
		lRet := .F.
	EndIf
	
	If lRet
		If EMPTY(cMatVida) .AND. cAliasCab == "BEA"
			cMatVida := Posicione("BA1",2,xFilial("BA1")+BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG),"BA1_MATVID")
		EndIf
		M->B00_EMAILD := Posicione("BTS",1,xFilial("BTS")+cMatVida,"BTS_EMAIL")
	Else
		M->B00_EMAILD := ""
	EndIf
ENDIF
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PA773Guia ³ Autor ³ Totvs                 ³ Data ³03/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna array com dados da guia...                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA773 - Protocolo de Justificativas de Negativa           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PA773Guia(cGuia, cAliasCab)

LOCAL aRet := {}
LOCAL aAreaBEA := BEA->(GetArea())
LOCAL cAliasCri	:=''
LOCAL lGuiaBEA	:=.F.

DEFAULT cAliasCab := "BEA"

//Se for protocolo de reembolso, o numero da guia deve ser o próprio número do protocolo.
if cAliasCab == "BOW"
	cGuia := B00->B00_COD
endif

(cAliasCab)->(DbSetOrder(1))//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO
If (cAliasCab)->(DbSeek(xFilial(cAliasCab)+cGuia))
	lGuiaBEA:=.T.
	aAdd(aRet,(cAliasCab)->(Recno())) 																	// 01-RECNO
	aAdd(aRet, IIF(cAliasCab == "BOW", cGuia, &(cAliasCab + "->(" + cAliasCab + "_OPEMOV+" + cAliasCab + "_ANOAUT+" + cAliasCab + "_MESAUT+" + cAliasCab + "_NUMAUT)"))) 	// 02-Guia completa
	IF cAliasCab == "B4A"
		aAdd(aRet, POSICIONE("BE2", 1, XFILIAL("BE2")+(cAliasCab)->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT), "BE2_OPERDA + BE2_CODRDA"))
		aAdd(aRet, BEA->BEA_NOMRDA)
	ELSEIF cAliasCab == "B4Q"
		aAdd(aRet, POSICIONE("BE2", 1, XFILIAL("BE2")+(cAliasCab)->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT), "BE2_OPERDA + BE2_CODRDA"))
		aAdd(aRet, B4Q->B4Q_NOMRDA)
	ELSE
		aAdd(aRet,&(cAliasCab + "->(" + cAliasCab + "_OPERDA+" + cAliasCab +"_CODRDA)"))	// 03-RDA
		aAdd(aRet,&(cAliasCab + "->"  + cAliasCab + "_NOMRDA"))	// 04-Nome RDA
	ENDIF
	aAdd(aRet,&(cAliasCab +"->(" + cAliasCab +"_OPEUSR+" + cAliasCab +"_CODEMP+" + cAliasCab +"_MATRIC+" + cAliasCab +"_TIPREG+" + cAliasCab +"_DIGITO)")) 			   		// 05-Matricula
	aAdd(aRet,&(cAliasCab +"->(" + cAliasCab +"_CONEMP+" + cAliasCab +"_VERCON+" + cAliasCab +"_SUBCON+" + cAliasCab +"_VERSUB)"))			 			   		// 06-Contrato e SubContrato
	aAdd(aRet,&(cAliasCab +"->(" + cAliasCab +"_NOMUSR)")) 														   		// 07-Nome Usuario
	If cAliasCab == "BEA"
		cMatVida := BEA->BEA_MATVID
		cCPF     := BEA->BEA_CPFUSR
	Else
		cMatVida := Posicione("BA1",2,xFilial("BA1")+&(cAliasCab + "->(" + cAliasCab + "_OPEUSR+" + cAliasCab + "_CODEMP+" + cAliasCab + "_MATRIC+" + cAliasCab + "_TIPREG)"),"BA1_MATVID")
		cCPF     := Posicione("BA1",2,xFilial("BA1")+&(cAliasCab + "->(" + cAliasCab + "_OPEUSR+" + cAliasCab + "_CODEMP+" + cAliasCab + "_MATRIC+" + cAliasCab + "_TIPREG)"),"BA1_CPFUSR")
	EndIf
	
	//Define o alias de critica - Para protocolo de reembolso será tratado de outra maneira, pois não possui críticas no protocolo de reembolso, e sim motivo de indeferimento
	DO CASE
	CASE cAliasCab == "B44"
		cAliasCri   := "B46"
	CASE cAliasCab == "B44"
		cAliasCri   := "B46"
	CASE cAliasCab == "B4A"
		cAliasCri   := "BEG"
	CASE BEA->BEA_TIPO   == "3"
		IF     BEA->BEA_TIPGUI == "03"	//	Internação
			cAliasCri := "BEL"
		ELSEIF BEA->BEA_TIPGUI == "11"	//	Prorrogação (Evolução)
			cAliasCri := "BQZ"
		ENDIF
	CASE cAliasCab == "B4Q"
		cAliasCri   := "BQZ"
	CASE cAliasCab == "BOW" //Protocolo de reembolso, não possui críticas..
		cAliasCri   := "BOW"
	OTHERWISE
	 	cAliasCri   := "BEG"
	ENDCASE
	
	aAdd(aRet,cCpf)      // 08-CPF Usuario
	aAdd(aRet,cMatVida)  // 09-Matricula da Vida
	aAdd(aRet,cAliasCri) // 10-Alias Critica
	aAdd(aRet,&(cAliasCab + "->" + cAliasCab + "_OPEMOV"))	// 11 - OPEMOV
	IF (cAliasCab == "B4Q")  //Nova Prorrogação
		aAdd(aRet,"11")	// 12 - TIPGUI
	ELSEIF (cAliasCab == "BOW") //Protocolo de reembolso
		aAdd(aRet,"")
	ELSE
		aAdd(aRet,&(cAliasCab + "->" + cAliasCab + "_TIPGUI"))	// 12 - TIPGUI
	ENDIF
	
	IF (cAliasCab == "BOW")
		aAdd(aRet,&(cAliasCab + "->" + cAliasCab + "_DTDIGI"))
	ELSE
	aAdd(aRet,&(cAliasCab + "->" + cAliasCab + "_DATPRO"))	// 13 - DATPRO
	ENDIF	
EndIf


If !lGuiaBEA .And. cAliasCab =="BEA"
	//ESSE ITEM SE FAZ NECESSARIOS DEVIDO NA CONCEPÇÃO DA NOVA PRORROGAÇÃO NAO CRIAVA A BEA
	If B4Q->(DbSeek(xFilial("B4Q")+cGuia))
		cAliasCab:="B4Q"
		aAdd(aRet,(cAliasCab)->(Recno())) 																	// 01-RECNO
		aAdd(aRet, IIF(cAliasCab == "BOW", cGuia, &(cAliasCab + "->(" + cAliasCab + "_OPEMOV+" + cAliasCab + "_ANOAUT+" + cAliasCab + "_MESAUT+" + cAliasCab + "_NUMAUT)"))) 	// 02-Guia completa
		aAdd(aRet, POSICIONE("BE2", 1, XFILIAL("BE2")+(cAliasCab)->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT), "BE2_OPERDA + BE2_CODRDA"))
		aAdd(aRet, B4Q->B4Q_NOMRDA)
		aAdd(aRet,&(cAliasCab +"->(" + cAliasCab +"_OPEUSR+" + cAliasCab +"_CODEMP+" + cAliasCab +"_MATRIC+" + cAliasCab +"_TIPREG+" + cAliasCab +"_DIGITO)")) 			   		// 05-Matricula
		aAdd(aRet,&(cAliasCab +"->(" + cAliasCab +"_CONEMP+" + cAliasCab +"_VERCON+" + cAliasCab +"_SUBCON+" + cAliasCab +"_VERSUB)"))			 			   		// 06-Contrato e SubContrato
		aAdd(aRet,&(cAliasCab +"->(" + cAliasCab +"_NOMUSR)")) 														   		// 07-Nome Usuario
		cMatVida := Posicione("BA1",2,xFilial("BA1")+&(cAliasCab + "->(" + cAliasCab + "_OPEUSR+" + cAliasCab + "_CODEMP+" + cAliasCab + "_MATRIC+" + cAliasCab + "_TIPREG)"),"BA1_MATVID")
		cCPF     := Posicione("BA1",2,xFilial("BA1")+&(cAliasCab + "->(" + cAliasCab + "_OPEUSR+" + cAliasCab + "_CODEMP+" + cAliasCab + "_MATRIC+" + cAliasCab + "_TIPREG)"),"BA1_CPFUSR")
		cAliasCri   := "BQZ"
		
		aAdd(aRet,cCpf)      // 08-CPF Usuario
		aAdd(aRet,cMatVida)  // 09-Matricula da Vida
		aAdd(aRet,cAliasCri) // 10-Alias Critica
		aAdd(aRet,&(cAliasCab + "->" + cAliasCab + "_OPEMOV"))	// 11 - OPEMOV
		aAdd(aRet,"11")	// 12 - TIPGUI
		aAdd(aRet,&(cAliasCab + "->" + cAliasCab + "_DATPRO"))	// 13 - DATPRO
	Endif	
Endif


RestArea(aAreaBEA)

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PLSA773Ger ³ Autor ³ Totvs                 ³ Data ³03/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de geração da Justificativa de Negativa...           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA773 - Protocolo de Justificativas de Negativa           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA773Ger(cAlias,nReg,nOpc,lAuto)

LOCAL aBene := {}
LOCAL aOperadora := {}
LOCAL aNegativas := {}
LOCAL cAliasGuia := IIf(!EMPTY(B00->B00_ALIGUI), AllTrim(B00->B00_ALIGUI),"BEA")
LOCAL aGuia := PA773Guia(AllTrim(B00->B00_NUMGUI), cAliasGuia)
Default lAuto := .F.

__lAutoma	:= lAuto

If !__lAutoma
	If !(MsgYesNo(STR0008+B00->B00_COD)) // "Deseja gerar a Justificativa de Negativa do protocolo: "
		Return (.T.)
	Endif
EndIf

If !EMPTY(aGuia)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Preenche dados do Beneficiário...                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aBene := { aGuia[07],aGuia[08],aGuia[05] }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na Operadora para Dados Cadastrais......                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BA0->(DbSetOrder(1))
	BA0->(DbSeek(xFilial("BA0") + aGuia[11]))
	aOperadora := { BA0->(BA0_NOMINT),BA0->(BA0_CIDADE),BA0->(BA0_EST) }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Preenche dados das Negativas...                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if cAliasGuia == "BOW" //Protocolo de reembolso
		aNegativas := P001AIndef(aGuia)
	else
		aNegativas := P773Negat(aGuia)
	endif

	If ExistBlock( "PLS773DOT" )
		cAliCab := Iif(B00->(FieldPos("B00_ALIGUI")) > 0,B00->B00_ALIGUI,"BEA")
		cChvGui := B00->B00_NUMGUI

		ExecBlock( "PLS773DOT", .F., .F., {cAliCab,cChvGui,aGuia,aNegativas,aBene} )

		Return (.T.)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Emite a Justificativa...                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	If !EMPTY(aNegativas)
		PL773Just(aBene,aOperadora,aNegativas, , , .T.)
	ElseIf cAliasGuia == "BOW"
		Aviso( STR0009, STR0091 , {STR0006} ) // "Atenção", "Não existem negativas para este protocolo de reembolso. Verifique o status e itens do protocolo."		
	Else
		Aviso( STR0009, STR0032 , {STR0006} ) 	// "Atenção", "As Negativas dessa Guia já foram tratadas !!!"
	EndIf
Else
	Aviso( STR0009, STR0033 , {STR0006} ) 			// "Atenção","Problema !!! Guia não encontrada !!!"
EndIf

Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ P773Negat ³ Autor ³ Totvs                 ³ Data ³03/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna array com os procedimentos da guia e suas negativas.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA773 - Protocolo de Justificativas de Negativa           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function P773Negat(aGuia,lRN395)

LOCAL aRet := {}
LOCAL aObs := {}
LOCAL aProced	:= {}
LOCAL aCriticas	:= {}
LOCAL cAlias1	:= GetNextAlias()
LOCAL cAlias2	:= GetNextAlias()
LOCAL cAlias3	:= GetNextAlias()
LOCAL cAliasCri := ""	//	Tabela de Críticas
LOCAL cAliasPro := ""	//	Tabela de Procedimentos
LOCAL cAliasCab := ""	//	Tabela de Cabeçalho da Guia
LOCAL cSql := ""
LOCAL cData := ""
LOCAL dDtGui := ""
LOCAL cCodPro := ""
LOCAL cCampos := ""
LOCAL cCritica := ""
LOCAL cChaveSIX := ""
LOCAL lLacoBQV := .F.
LOCAL nPos := 0
LOCAL lPL773OBS := ExistBlock( "PL773OBS" )

DEFAULT lRN395  := .F.

cAliasCri := aGuia[10]
cAliasPro := PLSRELGUI(cAliasCri, 2)
IF cAliasPro == "BE2"	//	Atendimentos
	BE2->(DBSETORDER(1))
	IF !BE2->(DBSEEK(XFILIAL() + B00->B00_NUMGUI))
		cAliasPro	:= "B4C"	//	Anexos Clínicos
	ENDIF
ENDIF
cAliasCab := PLSRELGUI(cAliasPro, 1)
If cAliasCab == "BEA" .And. ;
	( !(cAliasCab)->(DbSeek(xFilial()+IIF(cAliasCab $ "BOW", B00->B00_COD, B00->B00_NUMGUI))) .Or. BEA->BEA_TIPGUI == "11")
	// esse item se faz necessarios devido na conepção da nova rotina de prorrogação não estava gerando BEA. 
	cAliasCab := "B4Q"
Endif

(cAliasCab)->(DBSEEK(XFILIAL()+IIF(cAliasCab $ "BOW", B00->B00_COD, B00->B00_NUMGUI)))
(cAliasCab)->(DBSETORDER(IIF(cAliasCab $ "BE4", 2, 1)))
(cAliasCab)->(DBSEEK(XFILIAL()+IIF(cAliasCab $ "BOW", B00->B00_COD, B00->B00_NUMGUI)))
dDtGui := (cAliasCab)->(&(cAliasCab + IIF(cAliasCab $ "BOW", "_DTDIGI","_DATPRO")))	//	Data do procedimento
IF EMPTY(dDtGui)
	IF (cAliasCab)->(FIELDPOS(cAliasCab + "_DTDIGI")) > 0	//	Verifica se existe Data da Digitação na Tabela Corrente
		dDtGui := (cAliasCab)->(&(cAliasCab + "_DTDIGI"))	//	Data da Inclusão da Guia
	ELSE
		IF !EMPTY(B00->B00_DTATEN)
			dDtGui := B00->(MIN(B00_DTATEN, B00_DTPROT))	//	Data do Atendimento
		ELSE
			dDtGui := B00->B00_DTPROT
		ENDIF
	ENDIF
ENDIF
aRet := {dDtGui}// Data do atendimento da Guia

BTU->(DbSetOrder(4))//BTU_FILIAL+BTU_CODTAB+BTU_VLRSIS+BTU_ALIAS
BTQ->(DbSetOrder(1))//BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM

WHILE .T.	//	Serve para processar Críticas de Procedimentos e com Prorrogação
	//	Monta Campos do Select e Group By
	cCampos := cAliasPro + "_FILIAL, " + cAliasPro + "_CODPAD, " + cAliasPro + "_CODPRO, "
	cCampos += IIF(cAliasPro <> "B45", cAliasPro + "_DESPRO, ","") + cAliasPro + "_QTDPRO, " + cAliasPro + "_DATPRO, " 
	cCampos += cAliasPro + "_SEQUEN, "

	If lRN395
		cCampos += cAliasPro + "_AUDITO, "
	EndIf
	IF cAliasCri $ "BEL,BQZ"
		cCampos += cAliasCri + "_CODOPE, "
		cCampos += cAliasCri + "_ANOINT, "
		cCampos += cAliasCri + "_MESINT, "
		cCampos += cAliasCri + "_NUMINT, "
	Else
		cCampos += cAliasCri + "_OPEMOV, "
		cCampos += cAliasCri + "_ANOAUT, "
		cCampos += cAliasCri + "_MESAUT, "
		cCampos += cAliasCri + "_NUMAUT, "
	EndIf
	cCampos += cAliasCri + "_SEQUEN "
	cSql := "SELECT " + cCampos + CRLF

	//	Cabeçalho da Guia
	cSql += "FROM " + RetSqlName(cAliasCab) + " " + cAliasCab + " " + CRLF

	//Procedimentos
	cSql += "INNER JOIN " + RetSqlName(cAliasPro) + " " + cAliasPro + " "
	cSql +=    "ON " + cAliasPro + "_FILIAL = '" + XFILIAL(cAliasPro) + "' "
	IF     cAliasPro == "BQV" .And. aGuia[12] == "02"
		cSql += "AND " + cAliasCab + "_OPEMOV = " + cAliasPro + "_CODOPE "
		cSql += "AND " + cAliasCab + "_ANOAUT = " + cAliasPro + "_ANOINT "
		cSql += "AND " + cAliasCab + "_MESAUT = " + cAliasPro + "_MESINT "
		cSql += "AND " + cAliasCab + "_NUMAUT = " + cAliasPro + "_NUMINT "
	ELSEIF cAliasPro $ "BEJ,BQV"
		cSql += "AND " + cAliasCab + IIf(cAliasCab=='BEA' .OR. cAliasCab=='B4Q', "_OPEMOV = ", "_CODOPE = " ) + cAliasPro + "_CODOPE "
		cSql += "AND " + cAliasCab + IIf(cAliasCab=='B4Q', "_ANOAUT = ", "_ANOINT = " ) + cAliasPro + "_ANOINT "
		cSql += "AND " + cAliasCab + IIf(cAliasCab=='B4Q', "_MESAUT = ", "_MESINT = " ) + cAliasPro + "_MESINT "
		cSql += "AND " + cAliasCab + IIf(cAliasCab=='B4Q', "_NUMAUT = ", "_NUMINT = " ) + cAliasPro + "_NUMINT "
	ELSE
		cSql += "AND " + cAliasCab + "_OPEMOV = " + cAliasPro + "_OPEMOV "
		cSql += "AND " + cAliasCab + "_ANOAUT = " + cAliasPro + "_ANOAUT "
		cSql += "AND " + cAliasCab + "_MESAUT = " + cAliasPro + "_MESAUT "
		cSql += "AND " + cAliasCab + "_NUMAUT = " + cAliasPro + "_NUMAUT "
	EndIf
	cSql +=   "AND " + cAliasPro + ".D_E_L_E_T_ = ' ' " + CRLF

	//	Críticas
	cSql += "INNER JOIN " + RetSqlName(cAliasCri) + " " + cAliasCri + " "
	cSql +=    "ON " + cAliasCri + "_FILIAL = '" + XFILIAL(cAliasCri) + "' "
	IF cAliasCri $ "BEL,BQZ"
		cSql += "AND " + cAliasCri + "_CODOPE = " + cAliasPro + "_CODOPE "
		cSql += "AND " + cAliasCri + "_ANOINT = " + cAliasPro + "_ANOINT "
		cSql += "AND " + cAliasCri + "_MESINT = " + cAliasPro + "_MESINT "
		cSql += "AND " + cAliasCri + "_NUMINT = " + cAliasPro + "_NUMINT "
	Else
		cSql += "AND " + cAliasCri + "_OPEMOV = " + cAliasPro + "_OPEMOV "
		cSql += "AND " + cAliasCri + "_ANOAUT = " + cAliasPro + "_ANOAUT "
		cSql += "AND " + cAliasCri + "_MESAUT = " + cAliasPro + "_MESAUT "
		cSql += "AND " + cAliasCri + "_NUMAUT = " + cAliasPro + "_NUMAUT "
	EndIf
	cSql +=   "AND " + cAliasCri + ".D_E_L_E_T_ = ' ' "
	cSql += CRLF
	cSql += "WHERE " + cAliasCab + ".D_E_L_E_T_ = ' ' AND " + cAliasCab + "_FILIAL = '" + xFilial(cAliasCab) + "' "
	cSql +=   "AND " + cAliasPro + "_NIVAUT = ' ' AND " + cAliasPro + "_NIVCRI <> ' ' "
	cSql +=   "AND " + cAliasCri + "_SEQUEN = " + cAliasPro + "_SEQUEN "

	//	Número da Guia
	If cAliasCri $ "BEL,BQZ"
		cSql += "AND " + cAliasPro + "_CODOPE = '" + SubStr(aGuia[02],01,4) + "' "
		cSql += "AND " + cAliasPro + "_ANOINT = '" + SubStr(aGuia[02],05,4) + "' "
		cSql += "AND " + cAliasPro + "_MESINT = '" + SubStr(aGuia[02],09,2) + "' "
		cSql += "AND " + cAliasPro + "_NUMINT = '" + SubStr(aGuia[02],11,8) + "' "
		If lRN395 .And. cAliasCri == "BQZ" //"BQV"
			cSql += " AND " + cAliasPro + "_PROATE = '"+Alltrim(B00->B00_COD)+ "' "
		EndIf
	Else
		cSql += "AND " + cAliasPro + "_OPEMOV = '" + SubStr(aGuia[02],01,4) + "' "
		cSql += "AND " + cAliasPro + "_ANOAUT = '" + SubStr(aGuia[02],05,4) + "' "
		cSql += "AND " + cAliasPro + "_MESAUT = '" + SubStr(aGuia[02],09,2) + "' "
		cSql += "AND " + cAliasPro + "_NUMAUT = '" + SubStr(aGuia[02],11,8) + "' "
	EndIf

	//	Matricula
	IF cAliasPro $ "BEJ,B45,B4C"
		cSql += "AND " + cAliasCab + "_OPEUSR = '" + SubStr(aGuia[05],01,4) + "' "
		cSql += "AND " + cAliasCab + "_CODEMP = '" + SubStr(aGuia[05],05,4) + "' "
		cSql += "AND " + cAliasCab + "_MATRIC = '" + SubStr(aGuia[05],09,6) + "' "
		cSql += "AND " + cAliasCab + "_TIPREG = '" + SubStr(aGuia[05],15,2) + "' "
		cSql += "AND " + cAliasCab + "_DIGITO = '" + SubStr(aGuia[05],17,1) + "' "
	Else
		cSql += "AND " + cAliasPro + "_OPEUSR = '" + SubStr(aGuia[05],01,4) + "' "
		cSql += "AND " + cAliasPro + "_CODEMP = '" + SubStr(aGuia[05],05,4) + "' "
		cSql += "AND " + cAliasPro + "_MATRIC = '" + SubStr(aGuia[05],09,6) + "' "
		cSql += "AND " + cAliasPro + "_TIPREG = '" + SubStr(aGuia[05],15,2) + "' "
		cSql += "AND " + cAliasPro + "_DIGITO = '" + SubStr(aGuia[05],17,1) + "' "
	EndIf

	If lRN395
		cSql += " AND " + iif(lLacoBQV,cAliasPro,cAliasCab) + "_PROATE = '"+Alltrim(B00->B00_COD)+ "' "
	EndIf
	cSql += CRLF
	cSql += "GROUP BY " + cCampos
	If lRN395
		cSql +=  " ORDER BY "+cAliasPro+"_AUDITO DESC "
	EndIf
	cSql := ChangeQuery(cSql)
	DBUseArea( .T., "TOPCONN", TCGENQRY(,,cSql), cAlias1, .F., .T. )
	IF !(cAlias1)->(Eof())
		While !(cAlias1)->( EOF() )
			aProced := {}
			aAdd( aProced,(cAlias1)->(&(cAliasPro + "_CODPAD")) + '-' + (cAlias1)->(&(cAliasPro + "_CODPRO")) )
			cDesPro := posicione("BR8",1,xFilial("BR8")+(cAlias1)->(&(cAliasPro + "_CODPAD+" + cAliasPro + "_CODPRO")),"BR8_DESCRI")
			IF EMPTY(cDesPro)
				cDesPro := (cAlias1)->(&(cAliasPro + "_DESPRO"))
			EndIf
			aAdd( aProced,cDesPro )
			aAdd( aProced,(cAlias1)->(&(cAliasPro + "_QTDPRO")) )

			// Adiciona as criticas em Procedimentos
			cSql := "SELECT " + cAliasCri + "_CODGLO, " + cAliasCri + "_DESGLO, " + cAliasCri + "_INFGLO " + CRLF
			cSql +=   "FROM " + RetSQLName(cAliasCri) + " " + CRLF
			cSql +=  "WHERE " + cAliasCri + "_FILIAL = '"	+ xFilial(cAliasCri)	+"' "
			If cAliasCri $  "BEL,BQZ"
				cSql +=  "AND " + cAliasCri + "_CODOPE = '"	+ (cAlias1)->&(cAliasCri+"_CODOPE") +"' "
				cSql +=  "AND " + cAliasCri + "_ANOINT = '"	+ (cAlias1)->&(cAliasCri+"_ANOINT") +"' "
				cSql +=  "AND " + cAliasCri + "_MESINT = '"	+ (cAlias1)->&(cAliasCri+"_MESINT") +"' "
				cSql +=  "AND " + cAliasCri + "_NUMINT = '"	+ (cAlias1)->&(cAliasCri+"_NUMINT") +"' "
				cSql +=  "AND " + cAliasCri + "_CODGLO <> '025' " 
				cSql +=  "AND " + cAliasCri + "_CODGLO <> ' ' " 
			Else
				cSql +=  "AND " + cAliasCri + "_OPEMOV = '"	+ (cAlias1)->&(cAliasCri+"_OPEMOV") +"' "
				cSql +=  "AND " + cAliasCri + "_ANOAUT = '"	+ (cAlias1)->&(cAliasCri+"_ANOAUT") +"' "
				cSql +=  "AND " + cAliasCri + "_MESAUT = '"	+ (cAlias1)->&(cAliasCri+"_MESAUT") +"' "
				cSql +=  "AND " + cAliasCri + "_NUMAUT = '"	+ (cAlias1)->&(cAliasCri+"_NUMAUT") +"' "
				cSql +=  "AND " + cAliasCri + "_CODGLO <> '025' " 
				cSql +=  "AND " + cAliasCri + "_CODGLO <> ' ' " 
			EndIf

			cSql +=    "AND " + cAliasCri + "_SEQUEN = '"	+ (cAlias1)->&(cAliasCri+"_SEQUEN") +"' "
			cSql +=    "AND D_E_L_E_T_ = ' ' "
			cSql +=  "ORDER BY " + cAliasCri + "_SEQUEN"
			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias2,.F.,.T.)
			aCriticas := {}

			If !(cAlias2)->(Eof())

				While !(cAlias2)->( EOF() )
					
					if BTU->(Dbseek(xFilial("BTU") + "38" +xFilial("BCT")+ (cAlias2)->&(cAliasCri+"_CODGLO"))) .And. ;
					   BTQ->(Dbseek(xFilial("BTQ") + "38" + BTU->BTU_CDTERM))	
					
						AADD(aCriticas, Alltrim(BTQ->BTQ_CDTERM) + " - " + Alltrim(BTQ->BTQ_DESTER))
					else

						cCritica := (cAlias2)->&(cAliasCri+"_INFGLO")
						if Empty(cCritica)
							cCritica := (cAlias2)->&(cAliasCri+"_DESGLO")
						endIf

						//Não considera Crítica em Branco ou que tem somente o Número do Procedimento
						if !(Empty(cCritica) .OR. Alltrim(cCritica) $ aProced[1])
							aAdd( aCriticas,(cAlias2)->&(cAliasCri+"_CODGLO") + " - " + Alltrim(cCritica))
						endIf

					endIf	
		
					(cAlias2)->( DbSkip() )
				EndDo
			EndIf
			(cAlias2)->(DbCloseArea())
			aAdd( aProced, aCriticas )
			If lRN395
				aAdd( aProced, (cAlias1)->(&(cAliasPro + "_AUDITO")) )
			EndIf
			aAdd( aProced,(cAlias1)->(&(cAliasPro + "_SEQUEN")))
			(cAlias1)->(DbSkip())
			If lPL773OBS
				aObs := ExecBlock( "PL773OBS", .F., .F., {aProced} )
				If ValType(aObs) == "A"
					aAdd( aProced,aObs )
				Else
					Help("",1,"PLSA773OBS")
				Endif
			EndIf
			aAdd( aRet,aProced )
			aCriticas := {}
			aProced := {}
		EndDo
	EndIf
	(cAlias1)->(DbCloseArea())
	IF cAliasCri $ "BEL,BEG" .AND. cAliasCab $ "BE4,BEA" 	//	Se tem Crítica de Internação ou Atendimento, verifica se tem também na Prorrogação
		cAliasCri := "BQZ"
		cAliasPro := "BQV"
		lLacoBQV  := .T.
	ELSE	//	Senão sai
		EXIT
	ENDIF
ENDDO

//Retorna para os Alias iniciais
cAliasCri := aGuia[10]
cAliasPro := PLSRELGUI(cAliasCri, 2)
IF cAliasPro == "BE2"	//	Atendimentos
	BE2->(DBSETORDER(1))
	IF !BE2->(DBSEEK(XFILIAL() + B00->B00_NUMGUI))
		cAliasPro	:= "B4C"	//	Anexos Clínicos
	ENDIF
ENDIF
cAliasCab := PLSRELGUI(cAliasPro, 1)
If cAliasCab == "BEA" .AND.  !(cAliasCab)->(DbSeek(xFilial()+IIF(cAliasCab $ "BOW", B00->B00_COD, B00->B00_NUMGUI)))
	// esse item se faz necessarios devido na conepção da nova rotina de prorrogação não estava gerando BEA. 
	cAliasCab := "B4Q"
Endif

B53->(DbSetOrder(1))
B72->(DbSetOrder(1))
(cAliasPro)->(DbSetOrder(1))

IF B53->(DBSEEK(XFILIAL() + aGuia[2])).And. (cAliasPro)->(DBSEEK(XFILIAL() + B53->B53_NUMGUI)) //	Verifica se está na Auditoria

	SIX->(DBSETORDER(1))
	SIX->(DBSEEK(cAliasPro))	//	Indice "1" por Guia
	cChaveSIX := ALLTRIM(SIX->CHAVE)
	WHILE !(cAliasPro)->(EOF()) .AND. XFILIAL(cAliasPro) + B53->B53_NUMGUI $ &(cAliasPro + "->(" + cChaveSIX + ")")

		IF B72->(DBSEEK(XFILIAL() + B53->(B53_ALIMOV + B53_RECMOV)+(cAliasPro)->&(cAliasPro+"_SEQUEN"))) .And. B72->B72_PARECE <> "0"	//	Não Autorizado
			cCodPro := ALLTRIM(B72->(B72_CODPAD + "-" + B72_CODPRO))
			nPos := ASCAN(aRet, {|x| ALLTRIM(x[1]) == ALLTRIM(cCodPro)}, 2)
			IF nPos == 0	//	Não deixa duplicar Procedimento.
				AADD(aProced, cCodPro)
				AADD(aProced, Posicione("BR8", 1, xFilial("BR8") + B72->(B72_CODPAD + B72_CODPRO), "BR8_DESCRI"))
				AADD(aProced, B72->B72_QTDAUT)					
			ENDIF
			
			If nPos>0 .And. !Empty(B72->B72_MOTIVO)
				//Verifico se a critica utilizada tem De-Para TISS cadastrado
				If BTU->(Dbseek(xFilial("BTU") + "38" +xFilial("BCT")+ B72->B72_MOTIVO)) .And. BTQ->(Dbseek(xFilial("BTQ") + "38" + BTU->BTU_CDTERM))

					//Nao incluo criticas repetidas	
					if Ascan(aRet[nPos][4],Alltrim(BTQ->BTQ_CDTERM) + " - " + Alltrim(BTQ->BTQ_DESTER)) == 0 
						AADD(aCriticas, Alltrim(BTQ->BTQ_CDTERM) + " - " + Alltrim(BTQ->BTQ_DESTER))
					endIf	
						
				//Se nao ha De-Para TISS, utilizo o B72_MOTIVO. Nao incluo criticas repetidas
				ElseIf Ascan(aRet[nPos][4],B72->B72_MOTIVO + " - " + Alltrim(Posicione("BCT", 1, xFilial("BCT") + B53->B53_CODOPE + B72->B72_MOTIVO, "BCT_DESCRI"))) == 0
					AADD(aCriticas,B72->B72_MOTIVO + " - " + Alltrim(Posicione("BCT", 1, xFilial("BCT") + B53->B53_CODOPE + B72->B72_MOTIVO, "BCT_DESCRI"))) 
				Endif

			//B72_MOTIVO nao foi preenchido, utilizo o B72_CODGLO. Nao incluo criticas repetidas	
			ElseIf nPos>0 .And. Ascan(aRet[nPos][4],B72->B72_CODGLO + " - " + Alltrim(Posicione("BCT", 1, xFilial("BCT") + B53->B53_CODOPE + B72->B72_CODGLO, "BCT_DESCRI"))) == 0
				AADD(aCriticas,B72->B72_CODGLO + " - " + Alltrim(Posicione("BCT", 1, xFilial("BCT") + B53->B53_CODOPE + B72->B72_CODGLO, "BCT_DESCRI")))
			Endif
						
			//AADD(aCriticas, "(" + B72->B72_MOTIVO + ") " + Posicione("BCT", 1, xFilial("BCT") + B53->B53_CODOPE + B72->B72_MOTIVO, "BCT_DESCRI"))
			if len(aCriticas) > 0 
				IF nPos > 0	//	Inclui Status da Auditoria
					AADD(aRet[nPos, 4], aCriticas[1])
				ELSE
					AADD(aProced, aCriticas )
					If lRN395
						aAdd(aProced, "0")
					EndIf
					AADD(aProced,B72->B72_SEQPRO)
					AADD(aRet, aProced )
				ENDIF
			endIf	
				
			aCriticas := {}
			aProced := {}
			
		else
			cCodPro := ALLTRIM(&(cAliasPro + "->(" + cAliasPro + "_CODPAD " + " + '-' + " + cAliasPro + "_CODPRO)"))
			if ASCAN(aRet, {|x| ALLTRIM(x[1]) == cCodPro}, 2) == 0	//	Não deixa duplicar Procedimento
				IF &(cAliasPro + "->" + cAliasPro + "_STATUS") == "0"	//	Não Autorizada
					AADD(aProced, cCodPro)
					AADD(aProced, Posicione("BR8", 1, xFilial("BR8") + &(cAliasPro + "->(" + cAliasPro + "_CODPAD + " + cAliasPro + "_CODPRO)"), "BR8_DESCRI"))
					AADD(aProced, &(cAliasPro + "->" + cAliasPro + "_QTDPRO"))
					AADD(aCriticas, "Não Autorizado")
					AADD(aProced, aCriticas )
					AADD(aRet, aProced )
					aCriticas := {}
					aProced := {}
				ENDIF

			//Se tem B53 e nao tem B72, o item nao foi auditado ainda
			else
				cSql := "SELECT " + cAliasCri + "_CODGLO, " + cAliasCri + "_DESGLO, " + cAliasCri + "_INFGLO " + CRLF
				cSql +=   "FROM " + RetSQLName(cAliasCri) + " " + CRLF
				cSql +=  "WHERE " + cAliasCri + "_FILIAL = '"	+ xFilial(cAliasCri)	+"' "
				if cAliasCri $  "BEL,BQZ"
					cSql +=  "AND " + cAliasCri + "_CODOPE = '"	+ (cAliasPro)->&(cAliasPro+"_CODOPE") +"' "
					cSql +=  "AND " + cAliasCri + "_ANOINT = '"	+ (cAliasPro)->&(cAliasPro+"_ANOINT") +"' "
					cSql +=  "AND " + cAliasCri + "_MESINT = '"	+ (cAliasPro)->&(cAliasPro+"_MESINT") +"' "
					cSql +=  "AND " + cAliasCri + "_NUMINT = '"	+ (cAliasPro)->&(cAliasPro+"_NUMINT") +"' "
					cSql +=  "AND " + cAliasCri + "_CODGLO = '025' " 
				else
					cSql +=  "AND " + cAliasCri + "_OPEMOV = '"	+ (cAliasPro)->&(cAliasPro+"_OPEMOV") +"' "
					cSql +=  "AND " + cAliasCri + "_ANOAUT = '"	+ (cAliasPro)->&(cAliasPro+"_ANOAUT") +"' "
					cSql +=  "AND " + cAliasCri + "_MESAUT = '"	+ (cAliasPro)->&(cAliasPro+"_MESAUT") +"' "
					cSql +=  "AND " + cAliasCri + "_NUMAUT = '"	+ (cAliasPro)->&(cAliasPro+"_NUMAUT") +"' "
					cSql +=  "AND " + cAliasCri + "_CODGLO = '025' " 

				endIf

				cSql +=    "AND " + cAliasCri + "_SEQUEN = '"	+ (cAliasPro)->&(cAliasPro+"_SEQUEN") +"' "
				cSql +=    "AND D_E_L_E_T_ = ' ' "
				cSql +=  "ORDER BY " + cAliasCri + "_SEQUEN"
				cSql := ChangeQuery(cSql)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias3,.F.,.T.)

				if !(cAlias3)->(Eof())
					cCodPro := (cAliasPro)->&(cAliasPro+"_CODPAD")+"-"+(cAliasPro)->&(cAliasPro+"_CODPRO")
					nPos := ASCAN(aRet, {|x| ALLTRIM(x[1]) == ALLTRIM(cCodPro)}, 2)
					if nPos > 0
						if BTU->(Dbseek(xFilial("BTU") + "38" +xFilial("BCT")+ "025")) .And. BTQ->(Dbseek(xFilial("BTQ") + "38" + BTU->BTU_CDTERM))
							AADD(aCriticas, Alltrim(BTQ->BTQ_CDTERM) + " - " + Alltrim(BTQ->BTQ_DESTER))
						else
							AADD(aCriticas, (cAlias3)->&(cAliasCri+"_CODGLO")+" - "+Alltrim((cAlias3)->&(cAliasCri+"_DESGLO")))
						endIf	
						AADD(aRet[nPos, 4], aCriticas[1])
						aCriticas := {}
					endIf	
				endIf

				(cAlias3)->(DbCloseArea())

			endIf
		endIf
			
		(cAliasPro)->(DBSKIP())
	ENDDO
ENDIF

IF LEN(aRet) == 1
	aRet := {}	//	Se os itens em Auditoria foram Autorizados
ENDIF

If LEN(aRet) >= 2
	
	If LEN(aRet[2][4]) == 0
		aAdd( aRet[2][4],STR0007 ) //"Não encontrado críticas para o procedimento." 
	EndIf 
EndIf

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL773Just º Autor ³ Totvs              º Data ³ 03/06/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Confecção e Impressao das Justificaticas de Negativas      º±±
±±º          ³ Via Microsoft Word                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSA773 - Protocolo de Justificativas de Negativa          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PL773Just(aBene,aOperadora,aNegativas,aAutorizad,lProtRN395,lImpEmail,lAtendTMK)

LOCAL nI := 0
LOCAL lRetMail := .F.
LOCAL lEncerra := .F.
LOCAL lCopy1 := .F.
LOCAL lCopy2 := .F.
LOCAL aProc := {.F.,.F.}
LOCAL cArqAgl := ""
LOCAL cMensag := ""
LOCAL cPathTMP := ""
LOCAL cPathArq := GetNewPar( "MV_PLDIDOT" , "\dot" ) // Define o local de origem dos arquivos de modelo .DOT dentro da pasta system que serão utilizados pelo SIGAPLS.
LOCAL cEmailTo := ""
LOCAL cFile := ""
LOCAL cArqDOC := ""

Default aAutorizad := {}
Default lProtRN395 := .F.
Default lImpEmail  := .F.
Default lAtendTMK  := .F.

Private aWord	:= {}
Private hWord	:= Nil
Private nConDoc	:= 0
Private cArqDot	:= ""
Private cPathEst:= ALLTRIM(GetNewPar( "MV_PLDIRJN", "c:\temp_negativa" )) // Path onde serao gravados os arquivos DOT na estacao de trabalho referentes á Declaracao de Quitação de Débitos.

If Empty(cPathArq)
	cPathArq := GetSrvProfString("StartPath", "")
Else
	If !(Substr(cPathArq,1,1) == "\" .OR. Substr(cPathArq,1,1) == "/")
		cPathTMP := GetSrvProfString("StartPath", "")
		cPathArq := IIF( Substr(cPathTMP,Len(cPathTMP),1) $ "\/", cPathTMP, cPathTMP+"\" ) + cPathArq
	EndIf
EndIf
cPathArq := IIF( Substr(cPathArq,Len(cPathArq),1) $ "\/", cPathArq, cPathArq+"\" )
If Empty(cPathEst)
	cPathEst := GetTempPath()
EndIf
cPathEst := PLSMUDSIS(cPathEst)

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º	Inicia a Integracao com o Word                                          º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
If lAtendTMK
	cArqDot  := "protocolo_callcenter.dot"
	cArqAgl  := "protocolo_callcenters.dot"
ElseIf lProtRN395
	cArqDot  := "protocolo_atendimento.dot"
	cArqAgl  := "protocolo_atendimentos.dot"
Else
	cArqDot  := "justificativa_negativa.dot"
	cArqAgl  := "justificativa_negativas.dot"
EndIf
//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º	Se nao for alterado via parametro procura o arquivo na pasta "system"   º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
cPathDot := PLSMUDSIS(cPathArq + cArqDot)
cPathAgl := PLSMUDSIS(cPathArq + cArqAgl)

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º	Verifica a Existencia dos Arquivos DOT no StartPath do Protheus         º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
If !File(cPathDot)
	Aviso( STR0009,STR0010 +CRLF+ cPathDot +CRLF+ STR0011,{STR0006} ) //"Atenção" , "O arquivo de Configuração:" , "nao foi encontrado pelo Servidor!!!"
	Return()
EndIf

If !File(cPathAgl)
	Aviso( STR0009,STR0010 +CRLF+ cPathAgl +CRLF+ STR0011,{STR0006} ) //"Atenção" , "O arquivo de Configuração:" , "nao foi encontrado pelo Servidor!!!"
	Return()
EndIf

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º	Verifica Path do Temporário para gravação na Estacao de Trabalho        º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
If Substr(cPathEst,1,1) == "\" .OR. Substr(cPathEst,1,1) == "/"
	cMensag := STR0012 +CRLF+ cPathEst +CRLF+ STR0013 +CRLF+ GetTempPath() //"Não foi validado o diretório temporário da Estação:" , "Os arquivos temporários serão gravados no diretório:"
	Aviso( STR0009 , cMensag , {STR0006} ) // "Atenção"
	cPathEst := PLSMUDSIS(GetTempPath())
EndIf

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º	Verifica Path para Armazenamento na Estacao de Trabalho                 º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
If Substr(cPathEst,len(cPathEst),1) $ "\/"
	cPathEst := Substr(cPathEst,1,len(cPathEst)-1)
EndIf
MontaDir( cPathEst )

//	Se ja existir arquivos no local, serão fechados e apagados para a nova geracao
cFile := PLSMUDSIS(Lower( cPathEst + "\" + cArqDot ))
If File( cFile )
	OLE_CloseFile( cFile )
	OLE_CloseLink( cFile )
	Ferase( cFile )
EndIf
cFile := PLSMUDSIS(Lower( cPathEst + "\" + cArqAgl ))
If File( cFile )
	OLE_CloseFile( cFile )
	OLE_CloseLink( cFile )
	Ferase( cFile )
EndIf
cFile := PLSMUDSIS(Lower( cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".doc" ))
If File( cFile )
	OLE_CloseFile( cFile )
	OLE_CloseLink( cFile )
	Ferase( cFile )
EndIf

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º	Faz a copia dos arquivos do Servidor para o Remote                      º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
If !__lAutoma
	lCopy1 := CpyS2T( cPathDot , cPathEst , .F. )
	lCopy2 := CpyS2T( cPathAgl , cPathEst , .F. )
EndIf

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º	Verifica as Copias                                                      º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
If !__lAutoma .AND. (!lCopy1 .Or. !lCopy2)
	Aviso( STR0014 , STR0015 + CRLF + cPathDot + CRLF + cPathEst , {STR0006} ) //"Processamento Cancelado" , "Houve um problema com a cópia dos arquivos de configuraçao:"
	Return()
EndIf

If !__lAutoma 
	Processa( {|| aProc := GeraWord(aBene,aOperadora,aNegativas,aAutorizad,lProtRN395,lAtendTMK)} , STR0016 , STR0017 , .F. ) //"Iniciando o processamento..." , "Aguarde"
Else
	aProc := GeraWord(aBene,aOperadora,aNegativas,aAutorizad,lProtRN395,lAtendTMK)
EndIf
If aProc[01]

	//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	//º	Fecha os Documentos                                                     º
	//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
	For nI := 1 to nConDoc
		OLE_CloseFile( aWord[nConDoc] )
		OLE_CloseLink( aWord[nConDoc] )
	Next

	//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	//º	Cria Documento Unico para aglutinar os resultados                       º
	//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
	If !__lAutoma
		hWord := OLE_CreateLink()
		OLE_NewFile( hWord , PLSMUDSIS(cPathEst + "\" + cArqAgl) )
		OLE_SetPropertie( hWord, oleWdVisible, .F. )
	
		OLE_SetDocumentVar( hWord, 'nQtArqs'    , nConDoc )
		OLE_SetDocumentVar( hWord, 'nomeArquivo', PLSMUDSIS("\impcarta") )
		OLE_SetDocumentVar( hWord, 'pastaDocs'  , cPathEst )

		OLE_UpdateFields( hWord )
		OLE_SaveAsFile( hWord, PLSMUDSIS(cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".doc"),,, .F., oleWdFormatDocument )

		If lAtendTMK
			OLE_ExecuteMacro( hWord, "JuntaTudoCallCenter" )
		ElseIf lProtRN395
			OLE_ExecuteMacro( hWord, "JuntaTudoProtoc" )
		Else
			OLE_ExecuteMacro( hWord, "JuntaTudo" )
		EndIf

		OLE_SaveAsFile( hWord, PLSMUDSIS(cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".doc"),,, .F., oleWdFormatDocument )
	EndIf
	If !lProtRN395
		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Padrao Protocolo de Negativas pergunta se vai somente gerar PDF         º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		If __lAutoma .OR. MsgYesNo(STR0067) //'Deseja gerar um arquivo PDF?'
			cArqDOC := "justificativa_negativa1"
			aRet := GeraPDF(cPathEst, cArqDOC)
		Else
			lImpEmail := .T.
		EndIf
	ElseIf !lImpEmail
		If lAtendTMK
			cArqDOC := "protocolo_callcenter1"
			aRet := GeraPDF(cPathEst, cArqDOC)
		Else
			cArqDOC := "protocolo_atendimento1"
			aRet := GeraPDF(cPathEst, cArqDOC)
		EndIf
  EndIf
  
  //Alteração claudiol@totvs.com.br
  If lImpEmail
       cArqDOC:= SubStr(cArqAgl,1,Len(cArqAgl)-5)+AllTrim(Str(nConDoc))
  EndIf
  
  IF !EMPTY(cArqDOC)
		//Ponto de Entrada para disponibilizar o caminho e nome do arquivo gerado
		If ExistBlock( "PL773DOC" )
			ExecBlock("PL773DOC",.F.,.F.,{cPathEst, cArqDOC})
		EndIf
	ENDIF
	
	If lImpEmail
		If aProc[02,01]
			//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
			//º	Pergunta se envia a Justificativa por e-mail ou imprime os resultados   º
			//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
			If B00->B00_TPENVI == "2"
				cEmailTo	:= ALLTRIM(Lower(B00->B00_EMAILD))
				If __lAutoma .OR. !EMPTY(cEmailTo) .AND. MsgYesNo(STR0018 + AllTrim(Str(nConDoc)) + "." +CRLF+CRLF+ STR0021 +CRLF+ cEmailTo) // "Total de Justificativas de Negativas Geradas: " , "Deseja enviar a Justificativa para o e-mail: "
					lRetMail := A773Mail(cEmailTo, B00->B00_COD, ;
						SubStr(cArqAgl,1,Len(cArqAgl)-5)+AllTrim(Str(nConDoc)),cPathEst+"\", ;
						cPathArq, aProc[02,02], lProtRN395)
					If lRetMail
						Aviso( STR0009 , STR0022 , {"Ok"} ) // "Atenção" , "E-mail com a Justificativa em anexo enviado com sucesso..."
						lEncerra := .T.
					Else
						Aviso( STR0009 , STR0024 , {STR0006} ) // "Atenção" , "Problemas ao enviar o e-mail ao Usuário. Entre em contato com o administrador."
					EndIf
				Else
					cMensag := ""
					If EMPTY(cEmailTo)
						cMensag += ( STR0009 +CRLF+ STR0023 +CRLF+CRLF ) // "Atenção" , "E-mail não encontrado no cadastro de Protocolos..."
					EndIf
					If !__lAutoma
						If MsgYesNo(cMensag + STR0019) // "Deseja Imprimir o Arquivo ?"
							OLE_PrintFile( hWord , "PART" , 2 , nConDoc + 1 , 1 )
							Aviso( STR0009 , STR0020 , {"Ok"} ) // "Atenção" , "Arquivo enviado para impressao..."
							lEncerra := .T.
						Endif
					Else
						lEncerra := .T.
					EndIf
				EndIf
			Else
				If !__lAutoma
					If MsgYesNo(STR0018 + AllTrim(Str(nConDoc)) +"." +CRLF+ STR0019) // "Total de Justificativas de Negativas Geradas: " , "Deseja Imprimir o Arquivo ?"
						OLE_PrintFile( hWord , "PART" , 2 , nConDoc + 1 , 1 )
						Aviso( STR0009 , STR0020 , {"Ok"} ) // "Atenção" , "Arquivo enviado para impressao..."
						lEncerra := .T.
					EndIf
				Else
					lEncerra := .T.
				Endif
			EndIf
		EndIf
	EndIf
	If !__lAutoma
		OLE_CloseFile( hWord )		// Fecha ultimo arquivo
		OLE_CloseLink( hWord )		// Fecha link com Word
	EndIf
		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Apaga os Arquivos Temporarios                                           º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
	For nI := 1 to nConDoc
		If File( PLSMUDSIS(cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nI)) + ".doc") )
			FErase(PLSMUDSIS(cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nI)) + ".doc") )
		EndIf
	Next

		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Exclui os Arquivos Temporarios apos a utilizacao.                       º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
	If File( Lower( PLSMUDSIS(cPathEst + "\" + cArqDot) ) )
		Ferase(Lower( PLSMUDSIS(cPathEst + "\" + cArqDot) ) )
	EndIf
	If File( Lower( PLSMUDSIS(cPathEst + "\" + cArqAgl) ) )
		Ferase(Lower( PLSMUDSIS(cPathEst + "\" + cArqAgl) ) )
	EndIf

	If lEncerra
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o campo de Status (B00_STATUS) para Encerrado                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		B00->(RecLock("B00",.F.))
		B00->B00_STATUS  := "2"
		B00->B00_DTENCE  := dDataBase
		B00->B00_HRENCE  := StrTran(Time(),":","")
		B00->(MsUnLock())
	EndIf
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GeraWord º Autor ³ Totvs              º Data ³ 03/06/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que gera a pagina a ser impressa atraves do modelo. º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSA773 - Protocolo de Justificativas de Negativa          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraWord(aBene,aOperadora,aNegativas,aAutorizad,lProtRN395,lAtendTMK)

Local aRetGrv	   := {}

Default aAutorizad := {}
Default lProtRN395 := .F.
Default lAtendTMK  := .F.

If lAtendTMK
	CriaDOC()
	ZeraCar(nil,.T.)
	aRetGrv := GravaCar( aBene,aOperadora,nil,nil,.F., .T. )
	If aRetGrv[01]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o campo de Quantidades Geradas (B00_QTDGER)                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		B00->(RecLock("B00",.F.))
		B00->B00_QTDGER := B00->B00_QTDGER + 1
		B00->(MsUnLock())
	EndIf
	OLE_CloseFile( aWord[nConDoc] )
	OLE_CloseLink( aWord[nConDoc] )
ElseIf !EMPTY(aNegativas) .Or. !Empty(aAutorizad)
	If !__lAutoma
		CriaDOC()
		ZeraCar(lProtRN395)
	EndIf
	//Recno - NomeCli - AnoRef - CPFCNPJ - Pessoa - ArrayFinanceiro - ArrayOperadora - AllPaid
	aRetGrv := GravaCar( aBene, aOperadora, aNegativas, aAutorizad, lProtRN395 )
	If aRetGrv[01]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o campo de Quantidades Geradas (B00_QTDGER)                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		B00->(RecLock("B00",.F.))
		B00->B00_QTDGER := B00->B00_QTDGER + 1
		B00->(MsUnLock())
	EndIf
	If !__lAutoma
		OLE_CloseFile( aWord[nConDoc] )
		OLE_CloseLink( aWord[nConDoc] )
	EndIf
EndIf

Return({.T.,aRetGrv})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GravaCar º Autor ³ Totvs              º Data ³ 03/06/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que grava os dados da Consulta na Carta de Justifi_ º±±
±±º          ³ cativa.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSA773 - Protocolo de Justificativas de Negativa          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaCar( aBene,aOperadora,aNegativas,aAutorizad,lProtRN395,lAtendTMK )

LOCAL aDados	:= Array(13)
LOCAL cTelCen	:= GetNewPar( "MV_PLSRTCA" , "" )	// Define o Telefone da Central de Atendimento a ser utilizado na impressão de cartas do SIGAPLS
LOCAL nFor 		:= 0
LOCAL nI		:= 0
LOCAL nLimIni	:= 1
LOCAL nObs		:= 0
LOCAL cProcedim	:= ""
LOCAL cCriticas	:= ""
LOCAL lEstudo   := .F.
LOCAL lNegado   := .F.
LOCAL lPL773OBS := ExistBlock( "PL773OBS" )

Default aAutorizad := {}
Default lProtRN395 := .F.
Default lAtendTMK  := .F.

aDados[01] := IIf( Empty(aOperadora[02])   ,"[Mun. Operadora não infornado]"	,AllTrim(aOperadora[02]) )
aDados[02] := IIf( Empty(aOperadora[03])   ,"[UF. Operadora não infornado]" 	,AllTrim(aOperadora[03]) )
aDados[03] := StrZero(Day(Date()),2) +" de "+ MesExtenso( Month(Date()))  +" de "+  Str(Year(Date()),4)
aDados[04] := IIf( Empty(aBene[01])        ,"[Beneficiário não infornado]"  	,AllTrim(aBene[01]) )
If lProtRN395
	If !Empty(aNegativas)
		aDados[05] := IIf( Empty(aNegativas[01]),"[Dt. de Atendimento não informada]" 	, ;
	   	StrZero(Day(aNegativas[01]),2) +" de "+ MesExtenso( Month(aNegativas[01]))  +" de "+  Str(Year(aNegativas[01]),4))
	ElseIf !Empty(aAutorizad)
		aDados[05] := IIf( Empty(aAutorizad[01]),"[Dt. de Atendimento não informada]" 	, ;
	   	StrZero(Day(aAutorizad[01]),2) +" de "+ MesExtenso( Month(aAutorizad[01]))  +" de "+  Str(Year(aAutorizad[01]),4))
	EndIf
ElseIf lAtendTMK
	aDados[05] := StrZero(Day(B00->B00_DTPROT),2) +" de "+ MesExtenso( Month(B00->B00_DTPROT))  +" de "+  Str(Year(B00->B00_DTPROT),4)
Else
	aDados[05] := IIf( Empty(aNegativas[01])  ,"[Dt. Negativa não infornado]" 	, ;
   	StrZero(Day(aNegativas[01]),2) +" de "+ MesExtenso( Month(aNegativas[01]))  +" de "+  Str(Year(aNegativas[01]),4))
EndIf
aDados[06] := IIf( Empty(aBene[02])         ,"[CPF não infornado]"           	,Transform(AllTrim(aBene[02]), "@R 999.999.999-99") )
aDados[07] := IIf( Empty(aBene[03])         ,"[Matricula não infornado]"     	,Transform(AllTrim(aBene[03]), "@R !!!!.!!!!.!!!!!!-!!-!") )
aDados[08] := IIf( Empty(cTelCen)           ,"0800-000.0000"                         	,AllTrim(cTelCen) )
aDados[09] := IIf( Empty(aOperadora[01])    ,"[Operadora não infornado]"     	,AllTrim(aOperadora[01]) )
aDados[10] := Alltrim(B00->B00_COD)
If lProtRN395 .Or. lAtendTMK
	IIf(!Empty(B00->B00_OBSERV),aDados[11] := "• OBSERVAÇÕES:"+CRLF+CRLF+B00->B00_OBSERV,aDados[11] := "")
Else
	IIf(!Empty(B00->B00_OBSERV),aDados[11] := "Observações: "+Alltrim(B00->B00_OBSERV),aDados[11] := "")
EndIf	
If lAtendTMK
	aDados[12] := B00->B00_OCOTMK
	aDados[13] := B00->B00_SOLTMK
EndIf
If !__lAutoma
	OLE_SetDocumentVar( aWord[nConDoc], "MUNOPE"     ,aDados[01] )
	OLE_SetDocumentVar( aWord[nConDoc], "UFOPE"      ,aDados[02] )
	OLE_SetDocumentVar( aWord[nConDoc], "DATA"       ,aDados[03] )
	OLE_SetDocumentVar( aWord[nConDoc], "NOMEBENE"   ,aDados[04] )
	OLE_SetDocumentVar( aWord[nConDoc], "DTNEGATIVA" ,aDados[05] )
	OLE_SetDocumentVar( aWord[nConDoc], "NUMCPF"     ,aDados[06] )
	OLE_SetDocumentVar( aWord[nConDoc], "MATRICULA"  ,aDados[07] )
	OLE_SetDocumentVar( aWord[nConDoc], "TELCENTRAL" ,aDados[08] )
	OLE_SetDocumentVar( aWord[nConDoc], "NOMEOPE"    ,aDados[09] )
	If lAtendTMK
		OLE_SetDocumentVar( aWord[nConDoc], "NUMPROTOC"  ,aDados[10] )
		OLE_SetDocumentVar( aWord[nConDoc], "OCORRENCIA" ,aDados[12] )
		OLE_SetDocumentVar( aWord[nConDoc], "SOLUCAO"    ,aDados[13] )
	ElseIf lProtRN395
		OLE_SetDocumentVar( aWord[nConDoc], "NUMPROTOC"  ,aDados[10] )
		OLE_SetDocumentVar( aWord[nConDoc], "OBSERVACAO" ,aDados[11] )
	Else
		OLE_SetDocumentVar( aWord[nConDoc], "OBSERVACAO" ,aDados[11] )
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RN 395 nao tem posicoes chumbadas       	                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lProtRN395
	If len(aAutorizad) > 1
 		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procedimentos autorizados                	                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cProcedim := STR0066 + CRLF + CRLF //"• EVENTOS AUTORIZADOS: "
		For nFor := 1+nLimIni To LEN(aAutorizad)
			cProcedim	+= "Qtd: " + STRZERO(aAutorizad[nFor,03],02) +" - "+ AllTrim(aAutorizad[nFor,02]) +"  -  ("+ AllTrim(aAutorizad[nFor,01]) + ")"+CRLF
		Next
		OLE_SetDocumentVar( aWord[nConDoc], "COD_DESC_AUT" , cProcedim)
	EndIf

	If len(aNegativas) > 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procedimentos negados	                	                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cProcedim := ""
		For nFor := 1+nLimIni To LEN(aNegativas)

			If aNegativas[nFor,05] == "1" .And. !lEstudo
				cProcedim += STR0065 + CRLF + CRLF //"• EVENTOS EM ESTUDO/AUDITORIA: "
				lEstudo := .T.
			ElseIf aNegativas[nFor,05] == "0" .And. !lNegado
				If lEstudo
					cProcedim += CRLF
				EndIf
				cProcedim += STR0064 + CRLF + CRLF //"• EVENTOS NEGADOS: "
				lNegado := .T.
			EndIf

			cProcedim	+= "Qtd: " + STRZERO(aNegativas[nFor,03],02) +" - "+ AllTrim(aNegativas[nFor,02]) +"  -  ("+ AllTrim(aNegativas[nFor,01]) + ")"+CRLF
			cCriticas := ""
			For nI := 1 To LEN(aNegativas[nFor,04])
				cCriticas	+= Space(10) + STRZERO(nI,02) + " - " + AllTrim(aNegativas[nFor,04,nI]) + CRLF
				For nObs := 1 To LEN(aNegativas[nFor,04])
					If lPL773OBS .And. Len(aNegativas[nFor]) > 5
						cCriticas += Space(10) + aNegativas[nFor,06,nObs] + CRLF
					EndIf
				Next
			Next
			If !Empty(cCriticas)
				cProcedim += cCriticas
			EndIf
			cProcedim += CRLF
		Next
		OLE_SetDocumentVar( aWord[nConDoc], "COD_DESC_NEG" , cProcedim)
	EndIf
ElseIf !lAtendTMK
	For nFor := 1+nLimIni To LEN(aNegativas)
		If nFor-nLimIni <= 10
			cProcedim	:= "Qtd: " + STRZERO(aNegativas[nFor,03],02) +" - "+ AllTrim(aNegativas[nFor,02]) +"  -  ("+ AllTrim(aNegativas[nFor,01]) + ")"
			cCriticas := ""
			For nI := 1 To LEN(aNegativas[nFor,04])
				cCriticas	+= STRZERO(nI,02) + " - " + AllTrim(aNegativas[nFor,04,nI]) + CRLF
				For nObs := 1 To LEN(aNegativas[nFor,04])
					If lPL773OBS .And. Len(aNegativas[nFor]) > 4
						cCriticas += aNegativas[nFor,05,nObs] + CRLF
					EndIf
				Next
			Next
			If !__lAutoma
				OLE_SetDocumentVar( aWord[nConDoc], "COD_DESC_PROC" + STRZERO(nFor-nLimIni,02), cProcedim)
				OLE_SetDocumentVar( aWord[nConDoc], "DESC_MOTIVO"   + STRZERO(nFor-nLimIni,02), cCriticas)
			EndIf
		EndIf
	Next
EndIf
If !__lAutoma
	OLE_UpdateFields( aWord[nConDoc] )
	OLE_SaveAsFile( aWord[nConDoc] , PLSMUDSIS(cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nConDoc)) + ".doc") ,,, .F. , oleWdFormatDocument )
EndIf
Return({.T.,aDados})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ZeraCar  º Autor ³ Totvs              º Data ³ 03/06/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Zera os controladores para geracao de nova Carta.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSA773 - Protocolo de Justificativas de Negativa          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ZeraCar(lProtRN395,lAtendTMK)

LOCAL nFor := 0

Default lProtRN395 := .F.
Default lAtendTMK  := .F.

OLE_SetDocumentVar( aWord[nConDoc], "MUNOPE"     , "" )
OLE_SetDocumentVar( aWord[nConDoc], "UFOPE"      , "" )
OLE_SetDocumentVar( aWord[nConDoc], "DATA"       , "" )
OLE_SetDocumentVar( aWord[nConDoc], "NOMEBENE"   , "" )
OLE_SetDocumentVar( aWord[nConDoc], "DTNEGATIVA" , "" )
OLE_SetDocumentVar( aWord[nConDoc], "NUMCPF"     , "" )
OLE_SetDocumentVar( aWord[nConDoc], "MATRICULA"  , "" )
OLE_SetDocumentVar( aWord[nConDoc], "TELCENTRAL" , "" )
OLE_SetDocumentVar( aWord[nConDoc], "NOMEOPE"    , "" )
If lAtendTMK
	OLE_SetDocumentVar( aWord[nConDoc], "OCORRENCIA", "" )
	OLE_SetDocumentVar( aWord[nConDoc], "SOLUCAO"   , "" )
ElseIf lProtRN395
	OLE_SetDocumentVar( aWord[nConDoc], "NUMPROTOC"   , "" )
	OLE_SetDocumentVar( aWord[nConDoc], "COD_DESC_AUT", "" )
	OLE_SetDocumentVar( aWord[nConDoc], "COD_DESC_NEG", "" )
	OLE_SetDocumentVar( aWord[nConDoc], "OBSERVACAO", "" )
Else
	OLE_SetDocumentVar( aWord[nConDoc], "OBSERVACAO", "" )
	For nFor := 1 To 10
		OLE_SetDocumentVar( aWord[nConDoc], "COD_DESC_PROC" + STRZERO(nFor,02), "" )
		OLE_SetDocumentVar( aWord[nConDoc], "DESC_MOTIVO"   + STRZERO(nFor,02), "" )
	Next nFor
EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CriaDOC  º Autor ³ Totvs              º Data ³ 03/06/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o novo arquivo para gravacao.                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSA773 - Protocolo de Justificativas de Negativa          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CriaDOC()

aAdd( aWord , 0 )
nConDoc++
aWord[nConDoc] := OLE_CreateLink()

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º	Cria o novo arquivo no Remote                                           º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
OLE_NewFile( aWord[nConDoc] , PLSMUDSIS(cPathEst + "\" + cArqDot) )

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º	Ajusta Propriedades do Arquivo                                          º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
OLE_SetPropertie( aWord[nConDoc] , oleWdVisible , .F. )

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º	Salva o arquivo com o novo nome no Remote                               º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
OLE_SaveAsFile( aWord[nConDoc] , PLSMUDSIS(cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nConDoc)) + ".doc") ,,, .F. , oleWdFormatDocument )

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A773Mail º Autor ³ Totvs              º Data ³ 03/06/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Envia Arquivo por E-mail.                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSA773 - Protocolo de Justificativas de Negativa          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A773Mail(cTo, cProtocolo, cAnexo, cPathRem, cPathSrv, aDados, lProtRN395, cPathServ)

LOCAL cNomeProg := "plsa773"
LOCAL cBody     := GetNewPar("MV_RELBODY" , "Não responda este e-mail. Esta mensagem é automática e não deve ser respondida.") // Determina a mensagem padrão que orá no corpo do e-mail.
LOCAL cSubject  := ""
LOCAL lOkEnvio  := .F.
LOCAL aRet      := {}
LOCAL cSubPasta := PLSMUDSIS("pdf_email\")
LOCAL cWFID     := ""
LOCAL cPathHtml := PLSMUDSIS("\workflow\"+cNomeProg+".htm")
LOCAL nHandle   := 0
LOCAL cHtml     := ""
LOCAL aFiles	  := {}
DEFAULT lProtRN395 := .F.
DEFAULT cPathServ  := ""
DEFAULT hWord := NIL

If !Empty(hWord)
	// Fecha link com Word antes de iniciar um novo link
	OLE_CloseFile( hWord )
	OLE_CloseLink( hWord )	
EndIf

If lProtRN395
	cSubject := STR0058 + cProtocolo //"Protocolo de Atendimento ao Beneficiário - "
Else
	cSubject := STR0034 + cProtocolo //"Justificativa de Negativas de Cobertura - Protocolo: "
EndIf
If MakeDir(PLSMUDSIS("\workflow")) == 3
	Aviso(STR0009, STR0059, {STR0006},2 ) 	//"Não foi possível criar a pastas 'WorkFlow' no Rootpath"
	Return(lOkEnvio)
EndIf

cHtml := ;
	"<html>"  + CHR(13) + ;
	"<body>"  + CHR(13) + ;
		"<h1>"  + cBody + "</h1>" + CHR(13) + ;
	"</body>" + CHR(13) + ;
	"</html>"

//Ponto de Entrada para customização da mensagem do E-Mail de Atendimento/Negativa pelo cliente
If ExistBlock( "PL773MAI" )
	cHtml := ExecBlock( "PL773MAI", .F., .F., {lProtRN395, cHtml, cBody} )
EndIf

IF (nHandle := FCREATE(cPathHtml)) < 0
	Aviso(STR0009,STR0063 + cPathHtml, {STR0006},2 ) //"Erro criando arquivo "
ELSE
	FWrite(nHandle, cHtml)
	FClose(nHandle)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transforma o DOC em PDF e salva copia no server...						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !__lAutoma .AND. !lProtRN395
		aRet := PA773PDF(cPathRem,cPathSrv,cSubPasta,cAnexo,cProtocolo)
	Else
	   aRet := {.T.,cPathServ}
	EndIf
	If aRet[01]
		aadd(aFiles, aRet[02])
		__cFrom := ""
		lOkEnvio := SetMail(cTo,cSubject,cHtml,aFiles,.F.,.F.,.F.,.F.,"",.F.)

		If !__lAutoma .AND. ! lOkEnvio
			GET MAIL ERROR cErrorMsg
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cNomeProg + STR0061 + cErrorMsg , 0, 0, {}) //": Erro na tentativa de enviar email: "
		EndIf
	Else
		If !__lAutoma
			Aviso( STR0009, STR0060 + CRLF + aRet[02], {STR0006} ) //"Erro ao copiar o arquivo PDF para o servidor no caminho: "
		EndIf
	EndIf
ENDIF

Return (lOkEnvio)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PA773PDF º Autor ³ Totvs              º Data ³ 03/06/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Transforma o DOC em PDF.                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSA773 - Protocolo de Justificativas de Negativa          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PA773PDF(cPathLocal,cPathSrv,cSubPasta,cArquivo,cProtocolo)

LOCAL lRet		:= .T.
LOCAL hWinWord  := nil
LOCAL cDocument := cPathLocal 	+ cArquivo 	+ ".doc"
LOCAL cArqPDF	:= Substr(cArquivo,1,LEN(cArquivo)-1) + "_" + cProtocolo + ".pdf"
LOCAL cPDFLocal := cPathLocal 	+ cSubPasta	+ cArqPDF
LOCAL cPDFSrv 	:= ""

lRet := MontaDir( cPathLocal+cSubPasta )
If !lRet
	cPDFLocal := cPathLocal + cArqPDF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esse exemplo é exclusivo para ambiente Windows...						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(GetRemoteType() == 1) .and. !(isPlugin())
	Aviso( STR0009, STR0035, {STR0006} ) //"Exclusivo para ambiente Windows"
	Return ({.F.,cPDFSrv})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o documento existe...										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !File(cDocument)
	Aviso( STR0009, STR0036 + CRLF + cDocument, {STR0006} ) //"Documento não encontrado no caminho: "
	Return ({.F.,cPDFSrv})
EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria objeto OLE para conversar com WinWord...							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	hWinWord := (execInClient(OLECREATELINK, {"TMSOLEWORD97"}))[1]
	If !(Val(hWinWord) == 0)
		Aviso( STR0009, STR0037, {STR0006} ) //"Falha ao criar o objeto OLE para conversar com WinWord"
		Return ({.F.,cPDFSrv})
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o documento (doc ou docx)...										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ExecInClient(OLEOPENFILE, { hWinWord, cDocument, "0", "", "" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva o documento como PDF...											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ExecInClient(OLESAVEASFILE, { hWinWord, cPDFLocal, "", "", "0", WDFORMATPDF } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha conexão com objeto OLE...		  									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ExecInClient( OLECLOSEFILE, { hWinWord } )
hWord := execInClient( OLECLOSELINK, { hWinWord, 1 } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia o PDF para o Server para assim enviar em anexo por email...		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := MontaDir( cPathSrv+cSubPasta )
If lRet
	cPDFSrv:= cPathSrv+cSubPasta
Else
	cPDFSrv:= cPathSrv
EndIf

lRet := CpyT2S( cPDFLocal, cPDFSrv, .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga o arquivo PDF do Remote...										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File( Lower( cPDFLocal ) )
	Ferase( Lower(cPDFLocal) )
EndIf

Return ({lRet,cPDFSrv+cArqPDF})

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PL773CarCr ³ Autor ³ TOTVS    		      | Data ³ 05/05/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega as criticas    									  				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PL773CarCr()

PutHelp("PPLSA773OBS",{STR0038,STR0041,""},{},{},.T.) //"Retorno do ponto de entrada PL773OBS" "inválido"
PutHelp("SPLSA773OBS",{STR0039,STR0040,""},{},{},.T.)//"Verifique como deve ser o retorno" "na documentação disponível no TDN."

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSCPADGU2 ³ Autor ³ Bruno Iserhardt    ³ Data ³ 15.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de itens das tabelas de dominio TISS    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCPADGU2()

LOCAL lRet := .T.

cChvGui := PLSCPADGUI()
lRet := !Empty(cChvGui)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSCPADGUI ³ Autor ³ Bruno Iserhardt    ³ Data ³ 15.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de itens das tabelas de dominio TISS    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCPADGUI()

	Static objCENFUNLGP := CENFUNLGP():New()

LOCAL cChave     := Space(100) //IIF (!Empty(cCodVinc), cCodVinc, Space(100))
LOCAL oDlgPesTis
LOCAL oTipoPes
LOCAL nOpca      := 0
LOCAL aBrowUsr   := {}
LOCAL aVetPad    := { {"","","","",""} }
LOCAL oBrowUsr
LOCAL bRefresh   := { || If(!Empty(cChave),PLSPESGUI(AllTrim(cChave),Subs(cTipoPes,1,1),cTipoGuia,lChkChk,aBrowUsr,aVetPad,oBrowUsr),.T.), If( Empty(aBrowUsr[1,2]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     := "{|| Eval(bRefresh) }"
LOCAL bOK        := { ||  IIF(!Empty(cChave),(nLin := oBrowUsr:nAt, nOpca := 1,oDlgPesTis:End()),Help("",1,"PLSMCON")) }
LOCAL bCanc      := { || nOpca := 3,oDlgPesTis:End() }
LOCAL nReg
LOCAL oGetChave
LOCAL aTipoPes   := {}
LOCAL nOrdem     := 1
LOCAL cTipoPes   := ""
LOCAL cTipoGuia   := ""
LOCAL oChkChk
LOCAL lChkChk    := .F.
LOCAL nLin       := 1
LOCAL aButtons 	 := {}
LOCAL cSQL
LOCAL cRet       := ''
Public cAliasCab := ""

aBrowUsr := aClone(aVetPad)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Itens do combo do tipo de pesquisa...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTipoPes  := {"1 - Numero da Guia", "2 - Nome do Usuário", "3 - Matrícula"} //Código Terminologia || Decrição Item Terminologia
aTipoGuia := {"Todas", "BEA - Atendimento", "B44 - Aut. Reembolso", "B4A - Anexos Clínicos", "B4Q - Prorrogação de internação"}
DbSelectArea("B44")
DbSelectArea("B4A")
DbSelectArea("BEA")
DbSelectArea("B4Q")

If GetNewPar("MV_PLRN395","0") == "1" .And. GetNewPar("MV_PLSUNI","1") == "1"
	Aadd(aTipoPes,"4 - Nº Trans. Online")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesTis TITLE "Pesquisa de Guias" FROM 009,000 TO 280,780 OF GetWndDefault() PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Browse...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nAltv12 := 20	//	Ajuste para Versão 12
oBrowUsr := TcBrowse():New( 040 + nAltv12, 008, 378, 075,,,, oDlgPesTis,,,,,,,,,,,, .F.,, .T.,, .F., )

//Tipo de Guia
oBrowUsr:AddColumn(TcColumn():New("Tipo de Guia",   nil,nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowUsr:ACOLUMNS[1]:BDATA   := { || aBrowUsr[oBrowUsr:nAt,1] }

//Número Guia
oBrowUsr:AddColumn(TcColumn():New("Número Guia",    nil,nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowUsr:ACOLUMNS[2]:BDATA   := { || aBrowUsr[oBrowUsr:nAt,2] }

//Data da Guia
oBrowUsr:AddColumn(TcColumn():New("Data da Guia",   nil,nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowUsr:ACOLUMNS[3]:BDATA   := { || aBrowUsr[oBrowUsr:nAt,3] }

//Nome do Usuário
oBrowUsr:AddColumn(TcColumn():New("Nome do Usuário",nil,nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowUsr:ACOLUMNS[4]:BDATA   := { || aBrowUsr[oBrowUsr:nAt,4] }

//Matric Usuário
oBrowUsr:AddColumn(TcColumn():New("Matric Usuário", nil,nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowUsr:ACOLUMNS[5]:BDATA   := { || aBrowUsr[oBrowUsr:nAt,5] }

@ 010 + nAltv12 ,008 SAY oSay PROMPT "Tipo de Pesquisa"	SIZE 090,010 OF oDlgPesTis PIXEL //
@ 020 + nAltv12 ,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPesTis PIXEL COLOR CLR_HBLUE
@ 010 + nAltv12 ,103 SAY oSay PROMPT "Tipo de Guia"	SIZE 090,010 OF oDlgPesTis PIXEL //
@ 020 + nAltv12 ,103 COMBOBOX oTipoGuia Var cTipoGuia ITEMS aTipoGuia SIZE 090,010 OF oDlgPesTis PIXEL COLOR CLR_HBLUE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 010 + nAltv12 ,203 SAY oSay PROMPT "Chave de Pesquisa" SIZE 090,010 OF oDlgPesTis PIXEL //
oGetChave := TGet():New(020 + nAltv12 ,203,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesTis,140,008 ,"",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {.F., ;
					cAliasCab+ "_OPEMOV+" +  cAliasCab+ "_ANOAUT+" +  cAliasCab+ "_MESAUT+" +  cAliasCab+ "_NUMAUT", ;
					cAliasCab+ "_DATPRO", ;
					cAliasCab+ "_NOMUSR", ;
					cAliasCab+ "_OPEUSR+" +  cAliasCab+ "_CODEMP+" +  cAliasCab+ "_MATRIC+" +  cAliasCab+ "_TIPREG" }
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oBrowUsr:aObfuscatedCols := aBls
	endif

oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:BLDBLCLICK := bOK
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesTis ON INIT Eval({ || EnChoiceBar(oDlgPesTis,bOK,bCanc,.F.,aButtons), EVAL(bRefresh), oGetChave:SetFocus() })

//se o usuário selecionou algum registro
If nOpca == K_OK
	//verifica se o registro não está em branco
	If !Empty(aBrowUsr[nLin,2])
   	//atribui o código do item da terminologia a variável de retorno
		cRet := aBrowUsr[nLin,2]
		cRet := StrTran(cRet,"-","")
		cRet := StrTran(cRet,".","")
		M->B00_ALIGUI := LEFT(aTipoGuia[ASCAN(aTipoGuia, {|x| ALLTRIM(UPPER(aBrowUsr[nLin,1])) $ UPPER(x)})], 3)
	Endif
Endif

If ValType(cChvGui) <> 'U'
	cChvGui := cRet
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da Funcao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESGUI ³ Autor ³ Bruno Iserhardt    ³ Data ³ 15.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa detalhes das terminologias TISS na base de dados ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESGUI(cChave,cTipoPes,cTipoGuia,lChkChk,aBrowUsr,aVetPad,oBrowUsr)

Local aArea := GetArea()
LOCAL cSQL := ""
LOCAL cWhere := ""
LOCAL cOrder := ""
LOCAL cSqlPesq := ""
LOCAL cCampo := ""
LOCAL aTables := {}
LOCAL nX := 0
LOCAL lRn395 := GetNewPar("MV_PLRN395","0") == "1"
Public cAliasCab := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se pesquisa por Num. de Trans Online, somente pelo BEA                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipoPes == "4"
	If !cTipoGuia $ "Todas/BEA"
		Aviso( STR0075, STR0076, { "OK" }, 2 )//"Busca não permitida"##"Pesquisa por 'Número de Transação Online' disponível somente para o alias BEA=Atendimento."
		Return(.F.)
	EndIf
	aTables := {{"BEA", "Atendimento"}}
ElseIf cTipoGuia == "Todas"
	aTables := __aTables
Else
	aTables := { {subStr(cTipoGuia,1,3), subStr(cTipoGuia,7,Len(cTipoGuia))} }
EndIf
cChave := Alltrim(cChave)
If ( '"' $ cChave .Or. "'" $ cChave )
	Aviso( STR0073, STR0074, { "OK" }, 2 ) //"Caracter Inválido"##"Existem caracteres inválidos em sua busca"
	Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa resultado...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBrowUsr := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua busca...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aTables)
	cAliasCab := aTables[nX, 1]
	cSql := " SELECT '" + aTables[nX][2] + "' TIPOGUIA "
	cSql += ", " + cAliasCab + "_FILIAL FILIAL "
	cSql += ", " + cAliasCab + "_OPEMOV OPEMOV "
	cSql += ", " + cAliasCab + "_ANOAUT ANOAUT "
	cSql += ", " + cAliasCab + "_MESAUT MESAUT "
	cSql += ", " + cAliasCab + "_NUMAUT NUMAUT "
	If cAliasCab $ "B4A, B4Q"
		cSql += ", ' ' HORPRO "
	ELSE
		cSql += ", " + cAliasCab + "_HORPRO HORPRO "
	ENDIF
	cSql += ", " + cAliasCab + "_DATPRO DATPRO "
	cSql += ", " + cAliasCab + "_OPEUSR OPEUSR "
	cSql += ", " + cAliasCab + "_CODEMP CODEMP "
	cSql += ", " + cAliasCab + "_MATRIC MATRIC "
	cSql += ", " + cAliasCab + "_TIPREG TIPREG "
	cSql += ", " + cAliasCab + "_NOMUSR NOMUSR "
	cSql += " FROM " + RetSqlName(cAliasCab)
	cWhere := " WHERE " + cAliasCab + "_FILIAL = '" + xFilial(cAliasCab) + "' "
	cWhere +=  " 	AND " + RetSqlName(cAliasCab) + ".D_E_L_E_T_ = ' ' "
	If lRn395
   	cWhere +=  " AND " + cAliasCab + "_PROATE = '  ' "
	Else
		IF cAliasCab = "B44"
			cWhere += " AND B44_STATUS > '2' "	//	2=Autorizada
		ELSE
			cWhere += " AND " + cAliasCab + "_STATUS > '1' "	//	1=Autorizada
		ENDIF
  EndIf
	//cTipoPes:
	//1 - Numero da Guia : BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT
	//2 - Nome do Usuário: BEA_FILIAL+BEA_NOMUSR+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO
	//3 - Matrícula      : BEA_FILIAL+BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO
	If (cTipoPes == '1')	//	Guia
		cCampo := cAliasCab + "_OPEMOV || " + cAliasCab + "_ANOAUT || " + cAliasCab + "_MESAUT || " + cAliasCab + "_NUMAUT"
		cWhere += " 	AND " + cCampo +" LIKE '" + cChave + "%' "
	ElseIf (cTipoPes == '2')	//	Usuário
		cWhere += " 	AND " + cAliasCab + "_NOMUSR LIKE '%" + cChave + "%' "
	ElseIf (cTipoPes == '3')	//	Matricula
		cCampo := cAliasCab + "_OPEMOV || " + cAliasCab + "_CODEMP || " + cAliasCab + "_MATRIC || "  + cAliasCab + "_TIPREG || " + cAliasCab + "_DIGITO "
		cWhere += " 	AND " + cCampo +" like '" + cChave + "%' "
	ElseIf (cTipoPes == '4' .AND. cAliasCab <> "B4Q")	//	Num. Trans. Online
		cWhere += " 	AND " + cAliasCab + "_NRTROL LIKE '%" + Alltrim(cChave) + "%' "
	ENDIF
	cSqlPesq += cSql + cWhere+ iif(nX != len(aTables)," UNION "," ")
Next
cOrder := " ORDER BY FILIAL "
If     (cTipoPes == '1')
	cOrder += ", OPEMOV "
	cOrder += ", ANOAUT "
	cOrder += ", MESAUT "
	cOrder += ", NUMAUT "
	cOrder += ", DATPRO "
	cOrder += ", HORPRO "
	cOrder += ", NOMUSR "
ElseIf (cTipoPes == '2')
	cOrder += ", NOMUSR "
	cOrder += ", ANOAUT "
	cOrder += ", MESAUT "
	cOrder += ", NUMAUT "
	cOrder += ", DATPRO "
	cOrder += ", HORPRO "
ElseIf (cTipoPes == '3')
	cOrder += ", OPEUSR "
	cOrder += ", CODEMP "
	cOrder += ", MATRIC "
	cOrder += ", TIPREG "
	cOrder += ", ANOAUT "
	cOrder += ", MESAUT "
	cOrder += ", NUMAUT "
	cOrder += ", DATPRO "
	cOrder += ", HORPRO "
EndIf
cSqlPesq += cOrder

//Aspas incluidas para permitir nomear a coluna no oracle
cSqlPesq := ChangeQuery(cSqlPesq)
PLSQuery(cSqlPesq,"TrbPes")
TcSetField("TrbPes","DATPRO" ,"D", TamSx3("BE4_DATPRO")[1], TamSx3("BE4_DATPRO")[2] )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Popula a grid de pesquisa...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TrbPes->(DbGoTop())
While ! TrbPes->(Eof())
	TrbPes->(aadd(aBrowUsr, { ;
		TIPOGUIA, ;
		OPEMOV + "-" + ANOAUT + "." + MESAUT + "." + NUMAUT, ;
		DATPRO, ;
		NOMUSR, ;
		OPEUSR + "." + CODEMP + "." + MATRIC + "-" + TIPREG } ))
	TrbPes->(DbSkip())
Enddo
TrbPes->(DbCloseArea())
RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa resultado da pesquisa...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aBrowUsr) == 0
 	aBrowUsr := aClone(aVetPad)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowUsr:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
                  // uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
                  // Exemplo:
                  // 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
                  // (via seta para cima ou clique na primeira linha)
                  // 2a. Pesquisa: "AV" - Ocorria o erro
oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:Refresh()
oBrowUsr:SetFocus()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/{Protheus.doc} GeraPDF
Converse arquivo word em pdf.
@author  Lucas Nonato
@version P11
@since   11/01/2016
/*/
Static Function GeraPDF(cPathLocal,cArquivo)

LOCAL lRet := .T.
LOCAL hWinWord := nil
LOCAL cDocument := ""
LOCAL cArqPDF := Substr(cArquivo,1,LEN(cArquivo)-1) + "_" + B00->B00_COD + "_" + dtos(date())+ SUBSTR(Time(), 1, 2) + SUBSTR(Time(), 4, 2) + ".pdf"
LOCAL cPDFLocal := ""
LOCAL cPDFSrv := ""
Local oPrint
Local cShellExec := ""

// Fecha link com Word antes de iniciar um novo link
OLE_CloseFile( hWord )
OLE_CloseLink( hWord )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta caminhos                                 						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(cPathLocal,len(cPathLocal),1) $ "\/"
	cDocument := PLSMUDSIS(cPathLocal + cArquivo + ".doc")
	cPDFLocal := PLSMUDSIS(cPathLocal + cArqPDF)
Else
	cDocument := PLSMUDSIS(cPathLocal +'\'+ cArquivo 	+ ".doc")
	cPDFLocal := PLSMUDSIS(cPathLocal +'\'+ cArqPDF)
EndIf

lRet := MontaDir( cPathLocal )
If !lRet
	cPDFLocal := cPathLocal + cArqPDF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esse exemplo é exclusivo para ambiente Windows...						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(GetRemoteType() == 1) .and. !(isPlugin())
	Aviso( STR0009, STR0035, {STR0006} ) //"Exclusivo para ambiente Windows"
	Return ({.F.,cPDFSrv})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o documento existe...										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !File(cDocument)
	Aviso( STR0009, STR0036 + CRLF + cDocument, {STR0006} ) //"Documento não encontrado no caminho: "
	Return ({.F.,cPDFSrv})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria objeto OLE para conversar com WinWord...							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
hWinWord := (execInClient(OLECREATELINK, {"TMSOLEWORD97"}))[1]
If !(Val(hWinWord) == 0)
	Aviso( STR0009, STR0037, {STR0006} ) //"Falha ao criar o objeto OLE para conversar com WinWord"
	Return ({.F.,cPDFSrv})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o documento (doc ou docx)...										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ExecInClient(OLEOPENFILE, { hWinWord, cDocument, "0", "", "" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva o documento como PDF...											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ExecInClient(OLESAVEASFILE, { hWinWord, cPDFLocal, "", "", "0", WDFORMATPDF } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha conexão com objeto OLE...		  									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ExecInClient( OLECLOSEFILE, { hWinWord } )
hWord := execInClient( OLECLOSELINK, { hWinWord, 1 } )
lRet := MontaDir( cPathLocal )
cPDFSrv:= cPathLocal

If Substr(cPDFSrv,len(cPDFSrv),1) $ "\/"
	cShellExec := PLSMUDSIS(cPDFSrv+cArqPDF)
Else
	cShellExec := PLSMUDSIS(cPDFSrv+'\'+cArqPDF)
EndIf
If !__lAutoma
	shellExecute("Open", cShellExec, " /k dir", PLSMUDSIS("c:\"), 1 )
EndIf
Return ({lRet,cShellExec})


//-------------------------------------------------------------------
/*/{Protheus.doc} P773AutInc
Chama tela de inclusao de protocolos. A rotina pode ser chamada do
botao lateral das rotinas de Atendimento (somente visualizacao/alteracao),
chamadas de Usuario e Procedimentos (inclusao de protocolo) e pelo modulo
Call Center (inclusao de protocolo)

@author  PLS TEAM
@version P11
@since   28.03.16
/*/
//-------------------------------------------------------------------
Function P773AutInc(cAlias,cNumProto,oObj,lInterc,lChamBotao,nOpc,lChamTMK,lOkAlt,cMatric,lMsg,lCancPlano)

Local bCancel
Local oFontTit
Local oDlg
Local nFor
Local cNumPrTemp   := cNumProto
Local nOpca        := 0
Local lWebSerUni   := GetNewPar("MV_PL395WS","0") == "1"  

Default oObj       := nil
Default lInterc    := .F.
Default lChamBotao := .F. //Chamada pelo botao das rotinas de Atendimento
Default nOpc       := K_Alterar
Default lChamTMK   := .F. //Chamada pelo campo "Ocorrencia" do modulo Call Center
Default lOkAlt     := .F.
Default cMatric    := ""
Default lMsg       := .F.
Default lCancPlano := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe mensagem informando se exibe mensagem de usuario de intercambio/local ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMsg .And. GetNewPar("MV_PL395MS","1") == "1" .And. !lWebSerUni  
	If lInterc
		Aviso( STR0054, STR0077 , {STR0078} )//"Protocolo de Atendimento" ##"Foi informado um beneficiário de intercâmbio, informe o protocolo da Operadora Origem.""Ok"
	Else
		Aviso( STR0054, STR0079 , {STR0078} ) //"Protocolo de Atendimento" ## "É necessário gerar/informar um número de protocolo para o atendimento." ## Ok
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para gerar automaticamente o Protocolo sem exibicao da tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PL773PE2")
	cNumProto := ExecBlock("PL773PE2",.F.,.F.,{cAlias,cNumProto,lInterc,lChamBotao,nOpc,lChamTMK,cMatric})

	If cAlias $ "BE1/BEA/BE4/B01/B4A/B44/B4Q"
		&("M->"+cAlias+"_PROATE") := cNumProto
	EndIf

	If !Empty(cNumProto) .And. ValType(oObj) <> 'U'
		nPosProtoc := Ascan(oObj:aHeader ,{|x|x[2] == "BQV_PROATE"})
		If nPosProtoc > 0
			For nFor := 1 to len(oObj:aCols)
				If Empty(oObj:aCols[nFor][nPosProtoc])
					oObj:aCols[nFor][nPosProtoc] := cNumProto
				EndIf
			Next
		EndIf
		oObj:Refresh()
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se atendimento de intercambio e WebService ativado				         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
ElseIf lWebSerUni .And. lInterc .And. Empty(cNumProto)
	PL773WEBRN(@cNumProto,cMatric,lChamTMK,cAlias)	
	
	If cAlias == "SUC"
	    M->UC_PROTANS := cNumProto
	ElseIf cAlias $ "BE1/BEA/BE4/B01/B4A/B44"		
		&("M->"+cAlias+"_PROATE") := cNumProto 
	EndIf    
	
	If !Empty(cNumProto) .And. ValType(oObj) <> 'U'
		nPosProtoc := Ascan(oObj:aHeader ,{|x|x[2] == "BQV_PROATE"})  
		If nPosProtoc > 0
			For nFor := 1 to len(oObj:aCols) 
				If Empty(oObj:aCols[nFor][nPosProtoc])    
					oObj:aCols[nFor][nPosProtoc] := cNumProto
				EndIf
			Next		
		EndIf  
		oObj:Refresh()
	EndIf		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processo normal sem WebService                   				         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011

	DEFINE MSDIALOG oDlg TITLE STR0054 FROM 008.0,010.3 TO 014,050 //"Protocolo de Atendimento"

	@ 010,015 SAY oSay PROMPT STR0055  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Protocolo"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada Cancelamento de Plano           						         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	If lCancPlano 
		@ 010,050 MSGET cNumProto SIZE 080,006 OF oDlg F3 "B00CAN" Picture "@!" PIXEL FONT oFontTit COLOR CLR_BLACK 
		@ 030,082 BUTTON STR0057  SIZE 36,13 PIXEL ACTION {||nOpca := 2,gerRegB00(@cNumProto,@oDlg,nil,nil,lChamTMK,cMatric,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,lCancPlano)} //"Gerar Protoc."
		@ 030,120 BUTTON STR0056  SIZE 36,13 PIXEL ACTION {||nOpca := 1,confProtoc("L",@cNumProto,@oDlg,cAlias,nil,nil,nil,lChamTMK,cMatric,lCancPlano)} //"Confirmar" 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do modulo Call Center           						         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	ElseIf lChamTMK   
		If lInterc      
			@ 010,050 MSGET cNumProto SIZE 080,006 OF oDlg  Picture "@!" PIXEL FONT oFontTit COLOR CLR_BLACK      
			@ 030,082 BUTTON STR0053  SIZE 36,13 PIXEL ACTION {||nOpca := 2,oDlg:End() }//"Cancelar"	
			@ 030,120 BUTTON STR0056  SIZE 36,13 PIXEL ACTION {||nOpca := 1,confProtoc("I",@cNumProto,@oDlg,cAlias,nil,nil,@lOkAlt,lChamTMK,cMatric,lCancPlano)} //"Confirmar"
		Else	
			@ 010,050 MSGET cNumProto SIZE 080,006 OF oDlg F3 "B00TMK" Picture "@!" PIXEL FONT oFontTit COLOR CLR_BLACK 
			@ 030,082 BUTTON STR0057  SIZE 36,13 PIXEL ACTION {||nOpca := 2,gerRegB00(@cNumProto,@oDlg,cAlias,nil,lChamTMK,cMatric,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,lCancPlano)} //"Gerar Protoc."
			@ 030,120 BUTTON STR0056  SIZE 36,13 PIXEL ACTION {||nOpca := 1,confProtoc("L",@cNumProto,@oDlg,cAlias,nil,nil,nil,lChamTMK,cMatric,lCancPlano)} //"Confirmar" 
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do botao na lateral das rotinas de Atendimento                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf lChamBotao
		@ 010,050 MSGET cNumPrTemp SIZE 080,006 OF oDlg Picture "@!" PIXEL FONT oFontTit COLOR CLR_BLACK
		@ 030,120 BUTTON STR0053  SIZE 36,13 PIXEL ACTION {||nOpca := 2,oDlg:End() } //"Cancelar"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada dos campos de usuario/procedimento nas rotinas de Atendimento    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		If lInterc
			@ 010,050 MSGET cNumProto SIZE 080,006 OF oDlg  Picture "@!" PIXEL FONT oFontTit COLOR CLR_BLACK
			@ 030,082 BUTTON STR0053  SIZE 36,13 PIXEL ACTION {||nOpca := 2,oDlg:End() }//"Cancelar"
			@ 030,120 BUTTON STR0056  SIZE 36,13 PIXEL ACTION {||nOpca := 1,confProtoc("I",@cNumProto,@oDlg,cAlias,nil,nil,@lOkAlt,nil,cMatric) }//"Confirmar"
		Else
			@ 010,050 MSGET cNumProto SIZE 080,006 OF oDlg F3 "B00PLS" Picture "@!" PIXEL FONT oFontTit COLOR CLR_BLACK
			@ 030,082 BUTTON STR0057  SIZE 36,13 PIXEL ACTION {||nOpca := 2,gerRegB00(@cNumProto,@oDlg,cAlias,nil,nil,cMatric) }//"Gerar Protoc."
			@ 030,120 BUTTON STR0056  SIZE 36,13 PIXEL ACTION {||nOpca := 1,confProtoc("L",@cNumProto,@oDlg,cAlias,nil,nil,@lOkAlt,nil,cMatric) } //"Confirmar"
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa dialogo....                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1 .And. !Empty(cNumProto) .And. ValType(oObj) <> 'U'
		nPosProtoc := Ascan(oObj:aHeader ,{|x|x[2] == "BQV_PROATE"})
		If nPosProtoc > 0
			For nFor := 1 to len(oObj:aCols)
				If Empty(oObj:aCols[nFor][nPosProtoc])
					oObj:aCols[nFor][nPosProtoc] := cNumProto
				EndIf
			Next
		EndIf
		oObj:Refresh()
	EndIf
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} gerRegB00
Gera o numero de protocolo de atendimento e registra o sequencial na B3S

@author  PLS TEAM
@version P11
@since   28.03.16
/*/
//-------------------------------------------------------------------
Function gerRegB00(cNumProto,oDlg,cAlias,lIncRot,lChamTMK,cMatric,lWebRN395,cTipManif,cTipCateg,cTipSent,;
						   cIdResp,cOpeSol,cNumTraPre,cMsgLivre,cIDUsuario,cNumProAnt,cNrtrol,cNumTraOri,cOpeDes,lWeb,lCancPlano,cNumeroGui)
Local lOk         := .T.
Default cNumProto := ""
Default lIncRot   := .F.
Default lChamTMK  := .F.
Default cMatric   := ""
Default lWebRN395 := .F.
Default cTipManif := ""
Default cTipCateg := ""
Default cTipSent  := ""
Default cIdResp   := ""
Default cOpeSol   := PlsIntPad()
Default cNumTraPre:= ""
Default cMsgLivre := ""
Default cIDUsuario:= ""
Default cNumProAnt:= ""
Default cNrtrol   := ""
Default cNumTraOri:= ""
Default cOpeDes   := ""
Default oDlg      := nil
Default lWeb      := .F.
Default lCancPlano:= .F.
Default cNumeroGui:= ""

B00->(DbSetOrder(1))
If !Empty(cNumProto) .And. B00->(DbSeek(xFilial("B00")+cNumProto))
	lOk  := .F.
		
	If !lWebRN395 .And. !lWeb .And. !(cAlias $ "BOW,B44")
		Aviso( STR0009, STR0052 , {STR0006} ) 	// "Atenção","Problema !!! "Já foi gerado protocolo para este atendimento." !!!"
	EndIf
EndIf

If lOk
	If !lWebRN395 .And. Empty(cNumProto)
		cNumProto := P773GerPro()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registra protocolo de atendimento local/call center						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	B00->(RecLock("B00",.T.))
	B00->B00_FILIAL  := xFilial("B00")
	B00->B00_COD     := cNumProto
	B00->B00_STATUS  := "1"
	B00->B00_DTPROT  := dDataBase
	B00->B00_HRPROT  := StrTran(Time(),":","")
	B00->B00_TPENVI  := "1"
	IIF(lWebRN395,B00->B00_INTERC := "1",B00->B00_INTERC := "0")
	If B00->(FieldPos("B00_OPESOL ")) > 0
   		B00->B00_OPESOL := cOpeSol
   		B00->B00_TRAPRE := cNumTraPre
		B00->B00_CANCEL := "0"
		B00->B00_TRAORI := cNumTraOri
		B00->B00_OPEDES := cOpeDes
   	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca nome do Beneficiario/Contato/Email           						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	If !Empty(cMatric) .And. BA1->(DbSeek(xFilial("BA1")+cMatric))
		B00->B00_MATRIC := cMatric
		B00->B00_NOMUSR := BA1->BA1_NOMUSR
		B00->B00_CONTAT := BA1->BA1_NOMUSR
		If !Empty(BA1->BA1_EMAIL)
			B00->B00_TPENVI  := "2"
			B00->B00_EMAILD  := BA1->BA1_EMAIL
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos WebService                                						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lWebRN395 .And. B00->(FieldPos("B00_MANIF")) > 0
		B00->B00_MANIF  := cTipManif
		B00->B00_CATEG  := cTipCateg
		B00->B00_SENTIM := cTipSent
		B00->B00_STAINT := cIdResp
		B00->B00_MSGINT := cMsgLivre
		B00->B00_USUSOL := cIDUsuario
		B00->B00_PROANT := cNumProAnt
		B00->B00_NRTROL := cNrtrol
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos especificos atendimento call center      						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lChamTMK
		B00->B00_TIPPRO  := "2"
	ElseIf lCancPlano
		B00->B00_TIPPRO  := "4"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos especificos atendimento presencial local  						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		B00->B00_TIPPRO  := "1"
		If cAlias $ "B4A/B44/BOW"
			B00->B00_ALIGUI  := cAlias
		Else
			B00->B00_ALIGUI  := "BEA"
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza variavel geral com o numero do protocolo  						³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lIncRot
			If cAlias $ "BE1/BEA/BE4/B01/B4A/B44"
				&("M->"+cAlias+"_PROATE") := cNumProto
			EndIf
			If !lWebRN395	.And. !lWeb
		  		oDlg:Refresh()
		  	Endif
		EndIf

	EndIf
	B00->B00_NUMGUI  := cNumeroGui
	B00->(MsUnLock())
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} confProtoc
Confirma a acao da tela de inclusao de protocolo padrao

@author  PLS TEAM
@version P11
@since   28.03.16
/*/
//-------------------------------------------------------------------
Static Function confProtoc(cAcao,cNumProto,oDlg,cAlias,cNumPrTemp,nOpc,lOkAlt,lChamTMK,cMatric,lCancPlano)
Local lOk        := .T.
Local lGeraB00   := .T.
Local cCriticas  := ""
Local aAreaB00   := {}
Local lInfProtoc := IsInCallStack("PL90InfPro")
Local lPosBA1    := .F.

Default cNumPrTemp := ""
Default lOkAlt     := .F.
Default lChamTMK   := .F.
Default cMatric    := ""
Default lCancPlano := .F.

If Empty(cNumProto)
	cCriticas += STR0051 + Chr(13) //"- Protocolo vazio"
	lOk := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando registro local, verifica se o registro B00 foi criado               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAcao == "L"
	If B00->(DbSeek(xFilial("B00")+cNumProto))
		BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
		If BA0->(DbSeek(xFilial("BA0")+PlsIntPad())) .And. !Empty(BA0->BA0_SUSEP) .And. Alltrim(BA0->BA0_SUSEP) <> Substr(B00->B00_COD,1,6)
			cCriticas += STR0080 //"O protocolo informado foi vinculado a outra Operadora de Saúde."
			lOk := .F.
		ElseIf !Empty(B00->B00_NUMGUI) .Or. !Empty(B00->B00_CODATE)
			cCriticas += STR0081 //"O protocolo informado já foi utilizado em outra guia/atendimento."
			lOk := .F.
		ElseIf lChamTMK .And. B00->B00_TIPPRO == "1"
			cCriticas += STR0082  //"O protocolo informado é do tipo de atendimento Guia PLS."
			lOk := .F.
		ElseIf !lChamTMK .And. B00->B00_TIPPRO == "2"
			cCriticas += STR0083  //"O protocolo informado é do tipo de atendimento Call Center."
			lOk := .F.
		ElseIf !Empty(cMatric) .And. !Empty(B00->B00_MATRIC) .And. Alltrim(cMatric) <> B00->B00_MATRIC
			cCriticas += STR0084 //"O protocolo selecionado está vinculado com outro beneficiário."
			lOk := .F.
		EndIf
	Else
		cCriticas := STR0085 //"O protocolo informado não foi encontrado."
		lOk := .F.
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para intercambio devo checar regras de digitacao do protocolo              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAcao == "I"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica REGANS da Operadora                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cMatric)
		aRetDadUsr := PLSDADUSR(cMatric,"1",.T.,dDataBase)
		If !Empty(aRetDadUsr[45]) .And. aRetDadUsr[45] <> PlsIntPad()
			BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
			If BA0->(DbSeek(xFilial("BA0")+aRetDadUsr[45])) .And. !Empty(BA0->BA0_SUSEP) .And. (Substr(cNumProto,1,6) <>  Alltrim(BA0->BA0_SUSEP) )
				cCriticas += STR0086 + Chr(13) //"O registro ANS informado é diferente do cadastro da Operadora."
				lOk := .F.
			EndIf
		EndIf
	EndIf

	If Substr(cNumProto,7,4) <> Substr(Dtos(Date()),1,4) .And. !lInfProtoc
		cCriticas += STR0050 + Chr(13) //"- Ano incorreto"
		lOk := .F.
	EndIf

	If Substr(cNumProto,11,2) <> Substr(Dtos(Date()),5,2) .And. !lInfProtoc
		cCriticas += STR0049 + Chr(13) //"- Mês incorreto"
		lOk := .F.
	EndIf

	If Substr(cNumProto,13,2) <> Substr(Dtos(Date()),7,2) .And. !lInfProtoc
		cCriticas += STR0048 + Chr(13) //"- Dia incorreto"
		lOk := .F.
	EndIf

	If Substr(cMatric,5,4) == GetNewPar("MV_PLSGEIN",'') .And.  Substr(cNumProto,15,1) <> "9"
		cCriticas += STR0047 + Chr(13) //'- Identificador de intercâmbio "9" inválido'
		lOk := .F.
	EndIf

	aAreaB00 := B00->(GetArea())
	B00->(DbSetOrder(1))//B00_FILIAL+B00_COD+B00_NUMGUI
	If B00->(DbSeek(xFilial("B00")+cNumProto))
		If Empty(B00->B00_NUMGUI) .And. Empty(B00->B00_CODATE)
			If !Empty(cMatric) .And. !Empty(B00->B00_MATRIC) .And. Alltrim(cMatric) <> B00->B00_MATRIC
				cCriticas += STR0087 //"O protocolo selecionado está vinculado com outro beneficiário."
				lOk := .F.
			EndIf
			lGeraB00 := .F.
		Else
			cCriticas := STR0046 //"O número de protocolo informado já foi registrado em outro atendimento."
			lOk := .F.
		EndIf
	EndIf
	RestArea(aAreaB00)
EndIf

If lOk .And. cAcao == "I" .And. lGeraB00
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca nome do Beneficiario/Contato/Email           						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	If !Empty(cMatric) .And. BA1->(DbSeek(xFilial("BA1")+cMatric))
		lPosBA1 := .T.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registra atendimento de intercambio   									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	B00->(RecLock("B00",.T.))
	B00->B00_FILIAL  := xFilial("B00")
	B00->B00_COD     := cNumProto
	B00->B00_STATUS  := "1"
	B00->B00_DTPROT  := dDataBase
	B00->B00_HRPROT  := StrTran(Time(),":","")
	B00->B00_TPENVI  := "1"
	B00->B00_INTERC  := "1"
  If lChamTMK
  	B00->B00_TIPPRO  := "2"
  ElseIf lCancPlano
  		B00->B00_TIPPRO  := "4"
  Else
  	B00->B00_DTATEN  := dDataBase
		B00->B00_HRATEN  := StrTran(Time(),":","")
  	B00->B00_TIPPRO  := "1"
  	If cAlias $ "B4A/B44/B4Q"
			B00->B00_ALIGUI  := cAlias
  		Else
	 		B00->B00_ALIGUI  := "BEA"
 		EndIf
  EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos da BA1 posicionada                       						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPosBA1
		B00->B00_MATRIC := cMatric
		B00->B00_NOMUSR := BA1->BA1_NOMUSR
		B00->B00_CONTAT := BA1->BA1_NOMUSR
		If !Empty(BA1->BA1_EMAIL)
			B00->B00_TPENVI  := "2"
			B00->B00_EMAILD  := BA1->BA1_EMAIL
		EndIf
	EndIf
	B00->(MsUnLock())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conclui                              								    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOk
	lOkAlt := lOk
	If cAlias == "SUC"
		M->UC_PROTANS := cNumProto
	ElseIf cAlias $ "BE1/BEA/BE4/B01/B4A/B44/B4Q"
		&("M->"+cAlias+"_PROATE") := cNumProto
	EndIf
	oDlg:End()
Else
	MsgInfo(STR0045+Chr(13)+cCriticas) //"O protocolo informado é inválido: "
	If cAcao <> "B"
		cNumProto := Space(20)
	EndIf
	oDlg:Refresh()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} P773TmkCon
Conclui um protocolo ao finalizar o atendimento no Call Center.
Complementa o registro B00 com informacoes do atendimento realizado.
@author  PLS TEAM
@version P11
@since   28.03.16
/*/
//-------------------------------------------------------------------
Function P773TmkCon()

Local cEmail     := ""
Local cNomCont   := ""
Local cMatric    := ""
Local cOcorr     := ""
Local cSoluc     := ""
Local cFieldOcor := ""
Local cFieldSolu := ""
Local aFieldOcor := {}
Local aFieldSolu := {}
Local nX         := 0
Local nY 		 := 0
Local nPosField  := 0
Local lOk        := .F.

If IsInCallStack("TK271CallCenter") .And. !Empty(M->UC_PROTANS)
	AC8->(DbSetOrder(1))//AC8_FILIAL+AC8_CODCON+AC8_ENTIDA+AC8_FILENT+AC8_CODENT
	If AC8->(DbSeek(xFilial("AC8")+M->UC_CODCONT)) .And. AC8->AC8_ENTIDA == "BA1"
		BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		If BA1->(DbSeek(xFilial("BA1")+AC8->AC8_CODENT))
			cNumProto  := M->UC_PROTANS
			cCodAteTMK := M->UC_CODIGO
			cNomCont   := BA1->BA1_NOMUSR
			cMatric    := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
			lOk        := .T.
			If Empty(BA1->BA1_EMAIL)
				cEmail := Posicione("BTS",1,xFilial("BTS")+BA1->BA1_MATVID,"BTS_EMAIL")
			Else
				cEmail := BA1->BA1_EMAIL
			EndIf
		EndIf
	EndIf
EndIf

If lOk .And. B00->(DbSeek(xFilial("B00")+cNumProto))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega campos para preencher a Ocorrencia                           	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFieldOcor := GetNewPar("MV_PL395OC","")

	If !Empty(cFieldOcor)
		aFieldOcor := StrTokArr(cFieldOcor,";")
	EndIf

	For nX := 1 to len(aFieldOcor)
		If Substr(aFieldOcor[nX],1,2) == "UC" .And. !Empty(&("M->"+aFieldOcor[nX]))
			cOcorr += &("M->"+aFieldOcor[nX])+Chr(13)+Chr(10)
		EndIf

		If Substr(aFieldOcor[nX],1,2) == "UD"
			nPosField := aScan(aHeader,{|x|Alltrim(x[2])== Alltrim(aFieldOcor[nX])})
			If nPosField > 0
				For nY := 1 to len(aCols)
					If !Empty(aCols[nY,nPosField])
						cOcorr += aCols[nY,nPosField]+Chr(13)+Chr(10)
					EndIf
				Next
			EndIf
		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega campos para preencher a Solucao                               	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFieldSolu  := GetNewPar("MV_PL395SO","")
	If !Empty(cFieldSolu)
		aFieldSolu := StrTokArr(cFieldSolu,";")
	EndIf

	For nX := 1 to len(aFieldSolu)
		If Substr(aFieldSolu[nX],1,2) == "UC" .And. !Empty(&("M->"+aFieldSolu[nX]))
			cSoluc += &("M->"+aFieldSolu[nX])+Chr(13)+Chr(10)
		EndIf

		If Substr(aFieldSolu[nX],1,2) == "UD"
			nPosField := aScan(aHeader,{|x|Alltrim(x[2])== Alltrim(aFieldSolu[nX])})
			If nPosField > 0
				For nY := 1 to len(aCols)
					If !Empty(aCols[nY,nPosField])
						cSoluc += aCols[nY,nPosField]+Chr(13)+Chr(10)
					EndIf
				Next
			EndIf
		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera registro B00                    								    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	B00->(RecLock("B00",.F.))
	B00->B00_CODATE := cCodAteTMK
	B00->B00_CONTAT := cNomCont
	B00->B00_NOMUSR := cNomCont
	B00->B00_MATRIC := cMatric
	If !Empty(cEmail)
		B00->B00_TPENVI := "2"
		B00->B00_EMAILD := cEmail
	EndIf

	If !Empty(cOcorr)
		B00->B00_OCOTMK := cOcorr
	Endif

	If !Empty(cSoluc)
		B00->B00_SOLTMK := cSoluc
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para o usuario alterar as informacoes gravadas 		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBLock("PL773PE01")
		ExecBlock("PL773PE01",.F.,.F.,{cCodAteTMK,M->UC_PROTANS,B00->(Recno()) })
	EndIf

	B00->(MsUnLock())
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} P773AutCon
Conclui um protocolo ao finalizar o atendimento. Complementa o registro
B00 com informacoes do atendimento realizado.
@author  PLS TEAM
@version P11
@since   28.03.16
/*/
//-------------------------------------------------------------------
Function P773AutCon(cAlias,cNumProto,cGuia)

Local lFindGui  := .F.
Local cNomCont  := ""
Local aAreaCab  := GetArea()
Local cChaveUsu := ""
Local cEmail    := ""
Local cStatus   := "0"
Local nQtdAut   := 0
Local nQtdNeg   := 0
Local lAltB00   := .F.

If cAlias $ "BEA/BE1/B01"
	aAreaCab := BEA->(GetArea())
	BEA->(DbSetOrder(1))//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
	If BEA->(DbSeek(xFilial("BEA")+cGuia))
		lFindGui  := .T.
		cNomCont  := BEA->BEA_NOMUSR
		cChaveUsu := BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)
	EndIf

	If BEA->BEA_AUDITO == "1"
		cStatus := "4"  //4=Pendente Auditoria
	ElseIf BEA->BEA_STATUS $ "1/4/5"
		cStatus := "1" //1=Autorizada
	ElseIf BEA->BEA_STATUS == "2"
		cStatus := "2" //2=Autorizada Parcialmente
	ElseIf BEA->BEA_STATUS == "3"
		cStatus := "3" //3=Nao Autorizada
	EndIf

ElseIf cAlias == "B4A"
	aAreaCab := B4A->(GetArea())
	B4A->(DbSetOrder(1))//B4A_FILIAL + B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT + DTOS(B4A_DATPRO) + B4A_HORPRO
	If B4A->(DbSeek(xFilial("B4A")+cGuia))
		lFindGui  := .T.
		cNomCont  := B4A->B4A_NOMUSR
		cChaveUsu := B4A->(B4A_OPEUSR+B4A_CODEMP+B4A_MATRIC+B4A_TIPREG+B4A_DIGITO)
	EndIf

	If B4A->B4A_AUDITO == "1"
		cStatus := "4"  //4=Pendente Auditoria
	ElseIf B4A->B4A_STATUS $ "1/4/5"
		cStatus := "1" //1=Autorizada
	ElseIf B4A->B4A_STATUS == "2"
		cStatus := "2" //2=Autorizada Parcialmente
	ElseIf B4A->B4A_STATUS == "3"
		cStatus := "3" //3=Nao Autorizada
	EndIf

ElseIf cAlias == "B44"
	aAreaCab := B44->(GetArea())
	B44->(DbSetOrder(1))//B44_FILIAL+B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT
	If B44->(DbSeek(xFilial("B44")+cGuia))
		lFindGui  := .T.
		cNomCont  := B44->B44_NOMUSR
		cChaveUsu := B44->(B44_OPEUSR+B44_CODEMP+B44_MATRIC+B44_TIPREG+B44_DIGITO)
	EndIf

	If B44->B44_AUDITO == "1"
		cStatus := "4"  //4=Pendente Auditoria
	ElseIf B44->B44_STATUS $ "1/4/5"
		cStatus := "1" //1=Autorizada
	ElseIf B44->B44_STATUS == "2"
		cStatus := "2" //2=Autorizada Parcialmente
	ElseIf B44->B44_STATUS == "3"
		cStatus := "3" //3=Nao Autorizada
	EndIf

ElseIf cAlias == "BE4"
	aAreaCab := BE4->(GetArea())
	BE4->(DbSetOrder(2))//BE4_FILIAL + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
	If BE4->(DbSeek(xFilial("BE4")+cGuia))
		lFindGui  := .T.
		cNomCont  := BE4->BE4_NOMUSR
		cChaveUsu := BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
	EndIf

	If BE4->BE4_AUDITO == "1"
		cStatus := "4"  //4=Pendente Auditoria
	ElseIf BE4->BE4_STATUS $ "1/4/5"
		cStatus := "1" //1=Autorizada
	ElseIf BE4->BE4_STATUS == "2"
		cStatus := "2" //2=Autorizada Parcialmente
	ElseIf BE4->BE4_STATUS == "3"
		cStatus := "3" //3=Nao Autorizada
	EndIf

ElseIf cAlias == "B4Q"
	aAreaCab := B4Q->(GetArea())
	B4Q->(DbSetOrder(1))//B4Q_FILIAL + B4Q_OPEMOV + B4Q_ANOAUT + B4Q_MESAUT + B4Q_NUMAUT + DTOS(B4Q_DATPRO) + B4Q_HORPRO
	If B4Q->(DbSeek(xFilial("B4Q")+cGuia))
		lFindGui  := .T.
		cNomCont  := B4Q->B4Q_NOMUSR
		cChaveUsu := B4Q->(B4Q_OPEUSR+B4Q_CODEMP+B4Q_MATRIC+B4Q_TIPREG+B4Q_DIGITO)
	EndIf

	If B4Q->B4Q_AUDITO == "1"
		cStatus := "4"  //4=Pendente Auditoria
	ElseIf B4Q->B4Q_STATUS $ "1/4/5"
		cStatus := "1" //1=Autorizada
	ElseIf B4Q->B4Q_STATUS == "2"
		cStatus := "2" //2=Autorizada Parcialmente
	ElseIf B4Q->B4Q_STATUS == "3"
		cStatus := "3" //3=Nao Autorizada
	EndIf

ElseIf cAlias == "BQV"
	aAreaCab := BEA->(GetArea())
	BEA->(DbSetOrder(1))//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
	If BEA->(DbSeek(xFilial("BEA")+cGuia))
		lFindGui  := .T.
		cNomCont  := BEA->BEA_NOMUSR
		cChaveUsu := BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)
	EndIf
	BQV->(DbSetOrder(1))//BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT_BQV_SEQUEN
	If BQV->(DbSeek(xFilial("BQV")+cGuia))
		cStatus := "1"
		While xFilial("BQV")+cGuia == xFilial("BQV")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) .And. !BQV->(Eof())
			If Alltrim(BQV->BQV_PROATE) == Alltrim(cNumProto)
				If BQV->BQV_STATUS == "1"
					nQtdAut ++
				ElseIf BQV->BQV_STATUS == "0"
					nQtdNeg ++
				EndIf
			Endif

			If BQV->BQV_AUDITO == "1" .And. Alltrim(BQV->BQV_PROATE) == Alltrim(cNumProto)
				cStatus := "4" //4=Pendente Auditoria
				Exit
			EndIf
			BQV->(DbSkip())
		EndDo
		If cStatus <> "4"
			If nQtdAut > 0 .And. nQtdNeg > 0
				cStatus := "2" //2=Autorizada Parcialmente
			ElseIf nQtdAut > 0 .And. nQtdNeg == 0
				cStatus := "1" //1=Autorizada
			ElseIf nQtdAut == 0 .And. nQtdNeg > 0
				cStatus := "3" //3=Nao Autorizada
			EndIf
		EndIf
	EndIf
	
ElseIf cAlias == "BOW"
	aAreaCab := BOW->(GetArea())
	BOW->(DbSetOrder(1))//BOW_FILIAL+BOW_PROTOC
	If BOW->(DbSeek(xFilial("BOW")+cGuia))
		lFindGui  := .T.
		cNomCont  := BOW->BOW_NOMUSR
		cChaveUsu := BOW->(BOW_OPEUSR+BOW_CODEMP+BOW_MATRIC+BOW_TIPREG+BOW_DIGITO)
	EndIf
									
	If BOW->BOW_STATUS $ "3,6" //Deferido
		cStatus := "1"  //1=Autorizado
	ElseIf BOW->BOW_STATUS $ "C" //Aprovado Parcialmente
		cStatus := "2" //1=Autorizada Parcialmente
	ElseIf BOW->BOW_STATUS $ "4,D,8" //Indeferido
		cStatus := "3" //2=Não autorizada
	ElseIf BOW->BOW_STATUS $ "9"
		cStatus := "4"
	Else
		cStatus := "0"
	EndIf
	                                    
EndIf

BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
If BA1->(DbSeek(xFilial("BA1")+cChaveUsu))
	If Empty (BA1->BA1_EMAIL)
   	cEmail := Posicione("BTS",1,xFilial("BTS")+BA1->BA1_MATVID,"BTS_EMAIL")
	Else
		cEmail := BA1->BA1_EMAIL
	EndIf
EndIf

B00->(DbSetOrder(1))//B00_FILIAL+B00_COD+B00_NUMGUI
If lFindGui .And. B00->(DbSeek(xFilial("B00")+cNumProto))
	B00->(RecLock("B00",.F.))
	B00->B00_NUMGUI := cGuia
	B00->B00_CONTAT := cNomCont
	B00->B00_NOMUSR := cNomCont
	B00->B00_MATRIC := cChaveUsu
	B00->B00_DTATEN := dDataBase
	B00->B00_HRATEN := StrTran(Time(),":","")
	If !Empty(cEmail)
		B00->B00_TPENVI := "2"
		B00->B00_EMAILD := cEmail
	EndIf
	B00->B00_STATE  := cStatus
	If cAlias $ "B4A/B44/BOW"
		B00->B00_ALIGUI  := cAlias
	Else
		B00->B00_ALIGUI  := "BEA"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o protocolo selecionado e do TMK, altero para registro hibrido '3-Atend PLS e TMK' ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If B00->B00_TIPPRO == "2"
		B00->B00_TIPPRO := "3"
	EndIf
	B00->(MsUnLock())
	lAltB00 := .T.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para alteracao dos dados gravados                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PL773PE3")
	ExecBlock("PL773PE3",.F.,.F.,{cAlias,cNumProto,cGuia,lAltB00})
EndIf

RestArea(aAreaCab)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} P773GerPro
Funcao para geracao do numero sequencial do protocolo

@author  PLS TEAM
@version P11
@since   28.03.16
/*/
//-------------------------------------------------------------------
Function P773GerPro(cNum)
Local _nH := ""

BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
BA0->(DbSeek(xFilial("BA0")+PlsIntPad()))

B3S->(DbSetOrder(1))//B3S_FILIAL+B3S_SUSEP+B3S_ANO+B3S_MES+B3S_DIA+B3S_CODIGO

_nH := PL773SMF()

If B3S->(DbSeek(xFilial("B3S")+BA0->BA0_SUSEP+Dtos(Date())))
	B3S->(RecLock("B3S",.F.))
		B3S->B3S_CODIGO := Soma1(B3S->B3S_CODIGO)
	B3S->(MsUnLock())
Else
	B3S->(RecLock("B3S",.T.))
		B3S->B3S_FILIAL := xFilial("B3S")
		B3S->B3S_SUSEP  := BA0->BA0_SUSEP
		B3S->B3S_ANO    := Substr(Dtos(Date()),1,4)
		B3S->B3S_MES    := Substr(Dtos(Date()),5,2)
		B3S->B3S_DIA    := Substr(Dtos(Date()),7,2)
		B3S->B3S_CODIGO := "000001"
	B3S->(MsUnLock())
EndIf

PLSFechaSem(_nH,"PLSA773.SMF")

cNum := B3S->(B3S_SUSEP+B3S_ANO+B3S_MES+B3S_DIA+B3S_CODIGO)

Return(cNum)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL773SMF
Semaforo de controle da numeracao de protocolo
@author  PLS TEAM
@version P11
@since   07.04.16
/*/
//-------------------------------------------------------------------
Static Function PL773SMF()

Local _nH := ''

_nH := PLSAbreSem("PLSA773.SMF")

Return(_nH)

//-------------------------------------------------------------------
/*/{Protheus.doc} P773Autor
Retorna array com os procedimentos da guia autorizados

@author  PLS TEAM
@version P11
@since   07.04.16
/*/
//-------------------------------------------------------------------
Function P773Autor(aGuia)

LOCAL aRet := {}
LOCAL aObs := {}
LOCAL aProced	:= {}
LOCAL cAlias1	:= GetNextAlias()
LOCAL cAlias2	:= GetNextAlias()
LOCAL cAliasCri := ""	//	Tabela de Críticas
LOCAL cAliasPro := ""	//	Tabela de Procedimentos
LOCAL cAliasCab := ""	//	Tabela de Cabeçalho da Guia
LOCAL cSql := ""
LOCAL cData := ""
LOCAL cCodPro := ""
LOCAL cCampos := ""
LOCAL cChaveSIX := ""
LOCAL lLacoBQV  := .F.
LOCAL lPL773OBS := ExistBlock( "PL773OBS" )

cAliasCri := aGuia[10]
cAliasPro := PLSRELGUI(cAliasCri, 2)
IF cAliasPro == "BE2"	//	Atendimentos
	BE2->(DBSETORDER(1))
	IF !BE2->(DBSEEK(XFILIAL() + B00->B00_NUMGUI))
		cAliasPro	:= "B4C"	//	Anexos Clínicos
	ENDIF
ENDIF
cAliasCab := PLSRELGUI(cAliasPro, 1)
AADD(aRet, aGuia[13]) // Data do atendimento da Guia   -- AADD(aRet, (cAliasCab)->(&(cAliasCab + "_DATPRO")))

While .T.

	//	Monta Campos do Select e Group By
	cCampos := cAliasPro + "_FILIAL, " + cAliasPro + "_CODPAD, " + cAliasPro + "_CODPRO, " + ;
		IIF(cAliasPro <> "B45" .AND. (cAliasPro)->(FIELDPOS(cAliasPro + "_DESPRO")) > 0, cAliasPro + "_DESPRO, ", "") + ;
		cAliasPro + "_QTDPRO, " + cAliasPro + "_DATPRO, " + cAliasPro + "_AUDITO, "

	IF cAliasCri $ "BEL,BQZ"
		cCampos += cAliasPro + "_CODOPE, "
		cCampos += cAliasPro + "_ANOINT, "
		cCampos += cAliasPro + "_MESINT, "
		cCampos += cAliasPro + "_NUMINT, "
	Else
		cCampos += cAliasPro + "_OPEMOV, "
		cCampos += cAliasPro + "_ANOAUT, "
		cCampos += cAliasPro + "_MESAUT, "
		cCampos += cAliasPro + "_NUMAUT, "
	EndIf
	cCampos += cAliasPro + "_SEQUEN "
	cSql := "SELECT " + cCampos + CRLF

	//	Cabeçalho da Guia
	cSql += "FROM " + RetSqlName(cAliasCab) + " " + cAliasCab + " " + CRLF

	//Procedimentos
	cSql += "INNER JOIN " + RetSqlName(cAliasPro) + " " + cAliasPro + " "
	cSql +=    "ON " + cAliasPro + "_FILIAL = '" + XFILIAL(cAliasPro) + "' "

	IF cAliasPro == "BQV" .And. aGuia[12] == "02"
		cSql += "AND " + cAliasCab + "_OPEMOV = " + cAliasPro + "_CODOPE "
		cSql += "AND " + cAliasCab + "_ANOAUT = " + cAliasPro + "_ANOINT "
		cSql += "AND " + cAliasCab + "_MESAUT = " + cAliasPro + "_MESINT "
		cSql += "AND " + cAliasCab + "_NUMAUT = " + cAliasPro + "_NUMINT "

	ELSEIF cAliasPro $ "BEJ,BQV"
		cSql += "AND " + cAliasCab + IIf(cAliasCab=='BEA' .OR. cAliasCab=='B4Q', "_OPEMOV = ", "_CODOPE = " ) + cAliasPro + "_CODOPE "
		cSql += "AND " + cAliasCab + IIf(cAliasCab=='B4Q', "_ANOAUT = ", "_ANOINT = " ) + cAliasPro + "_ANOINT "
		cSql += "AND " + cAliasCab + IIf(cAliasCab=='B4Q', "_MESAUT = ", "_MESINT = " ) + cAliasPro + "_MESINT "
		cSql += "AND " + cAliasCab + IIf(cAliasCab=='B4Q', "_NUMAUT = ", "_NUMINT = " ) + cAliasPro + "_NUMINT "
	ELSE
		cSql += "AND " + cAliasCab + "_OPEMOV = " + cAliasPro + "_OPEMOV "
		cSql += "AND " + cAliasCab + "_ANOAUT = " + cAliasPro + "_ANOAUT "
		cSql += "AND " + cAliasCab + "_MESAUT = " + cAliasPro + "_MESAUT "
		cSql += "AND " + cAliasCab + "_NUMAUT = " + cAliasPro + "_NUMAUT "
	EndIf
	cSql +=   "AND " + cAliasPro + ".D_E_L_E_T_ = ' ' " + CRLF
	cSql +=   "AND " + cAliasPro + "." + cAliasPro + "_STATUS = '1' "


	//	Número da Guia
	If cAliasCri $ "BEL,BQZ"
		cSql += "AND " + cAliasPro + "_CODOPE = '" + Substr(aGuia[02],01,4) + "' "
		cSql += "AND " + cAliasPro + "_ANOINT = '" + Substr(aGuia[02],05,4) + "' "
		cSql += "AND " + cAliasPro + "_MESINT = '" + Substr(aGuia[02],09,2) + "' "
		cSql += "AND " + cAliasPro + "_NUMINT = '" + Substr(aGuia[02],11,8) + "' "
		If cAliasCri == "BQZ"
			cSql += " AND " + cAliasPro + "_PROATE = '"+Alltrim(B00->B00_COD)+ "' "
		EndIf
	Else
		cSql += "AND " + cAliasPro + "_OPEMOV = '" + Substr(aGuia[02],01,4) + "' "
		cSql += "AND " + cAliasPro + "_ANOAUT = '" + Substr(aGuia[02],05,4) + "' "
		cSql += "AND " + cAliasPro + "_MESAUT = '" + Substr(aGuia[02],09,2) + "' "
		cSql += "AND " + cAliasPro + "_NUMAUT = '" + Substr(aGuia[02],11,8) + "' "
	EndIf

	//	Matricula
	IF cAliasPro $ "BEJ,B45,B4C"
		cSql += "AND " + cAliasCab + "_OPEUSR = '" + Substr(aGuia[05],01,4) + "' "
		cSql += "AND " + cAliasCab + "_CODEMP = '" + Substr(aGuia[05],05,4) + "' "
		cSql += "AND " + cAliasCab + "_MATRIC = '" + Substr(aGuia[05],09,6) + "' "
		cSql += "AND " + cAliasCab + "_TIPREG = '" + Substr(aGuia[05],15,2) + "' "
		cSql += "AND " + cAliasCab + "_DIGITO = '" + Substr(aGuia[05],17,1) + "' "
	Else
		cSql += "AND " + cAliasPro + "_OPEUSR = '" + Substr(aGuia[05],01,4) + "' "
		cSql += "AND " + cAliasPro + "_CODEMP = '" + Substr(aGuia[05],05,4) + "' "
		cSql += "AND " + cAliasPro + "_MATRIC = '" + Substr(aGuia[05],09,6) + "' "
		cSql += "AND " + cAliasPro + "_TIPREG = '" + Substr(aGuia[05],15,2) + "' "
		cSql += "AND " + cAliasPro + "_DIGITO = '" + Substr(aGuia[05],17,1) + "' "
	EndIf

	cSql += " AND " + iif(lLacoBQV,cAliasPro,cAliasCab) + "_PROATE = '"+Alltrim(B00->B00_COD)+ "' "
	cSql += CRLF
	cSql += " GROUP BY " + cCampos
	cSql += " ORDER BY "+cAliasPro+"_AUDITO DESC "
	cSql := ChangeQuery(cSql)
	DBUseArea( .T., "TOPCONN", TCGENQRY(,,cSql), cAlias1, .F., .T. )
	IF !(cAlias1)->(Eof())
		While !(cAlias1)->( EOF() )
			aProced := {}
			aAdd( aProced,(cAlias1)->(&(cAliasPro + "_CODPAD")) + '-' + (cAlias1)->(&(cAliasPro + "_CODPRO")) )
			cDesPro := posicione("BR8",1,xFilial("BR8")+(cAlias1)->(&(cAliasPro + "_CODPAD+" + cAliasPro + "_CODPRO")),"BR8_DESCRI")
			IF EMPTY(cDesPro)
				cDesPro := (cAlias1)->(&(cAliasPro + "_DESPRO"))
			EndIf
			aAdd( aProced,cDesPro )
			aAdd( aProced,(cAlias1)->(&(cAliasPro + "_QTDPRO")) )
			If lPL773OBS
				aObs := ExecBlock( "PL773OBS", .F., .F., {aProced} )
				If ValType(aObs) == "A"
					aAdd( aProced,aObs )
				Else
					Help("",1,"PLSA773OBS")
				Endif
			EndIf
			(cAlias1)->(DbSkip())
			aAdd( aRet,aProced )
			aProced := {}
		EndDo
	EndIf
	(cAlias1)->(DbCloseArea())
	IF cAliasCab == "BEA" .And. cAliasCri == "BQZ" .Or. cAliasCab $ "B44/B4A"
		Exit
	ElseIF cAliasCri $ "BEL/BEG"	//	Se for Crítica de Internação irá verificar se tem na prorrogação
		cAliasCri := "BQZ"
		cAliasPro := "BQV"
		lLacoBQV  := .T.
	ELSE	//	Senão sai
		Exit
	ENDIF
ENDDO

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA773Pro
Processa a impressao do protocolo no formato da RN 395
@author  PLS TEAM
@version P11
@since   07.04.16
/*/
//-------------------------------------------------------------------
Function PLSA773Pro(lImpEmail, cEmail)//cAlias,nReg,nOpc,

LOCAL aBene := {}
LOCAL aOperadora := {}
LOCAL aNegativas := {}
LOCAL aAutorizad := {}
LOCAL cAliasGuia := ""
LOCAL aGuia      := ""
LOCAL cMsg       := ""
LOCAL cOper      := ""
LOCAL lAtendTMK  := .F.
Default cEmail   := "" // para possibilitar enviar o relatorio para outro email e permitindo tbm ser mais de um

If B00->(FieldPos("B00_TIPPRO")) > 0 .And. B00->B00_TIPPRO == "2"
	lAtendTMK  := .T.
	aBene := PA773AtTMK()
	cOper := PlsIntPad()
	If Empty(aBene)
		cMsg  := STR0071//"Não foi encontrado atendimento correspondente no Call Center."
	EndIf
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se pode gerar o protocolo de atendimento                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasGuia := IIf(B00->(FieldPos("B00_ALIGUI")) > 0 .AND. !EMPTY(B00->B00_ALIGUI), AllTrim(B00->B00_ALIGUI),"BEA")
	aGuia  := PA773Guia(AllTrim(B00->B00_NUMGUI), cAliasGuia)
	IF LEN(aGuia) <> 0
		aBene := { aGuia[07],aGuia[08],aGuia[05] }
		cOper := aGuia[11]
		If Empty(B00->B00_NUMGUI) .and. cAliasGuia <> "BOW"
			cMsg  := STR0044 //"Não foi atrelada uma guia ao protocolo."
		ElseIf EMPTY(aGuia)
			cMsg  := STR0033 //Guia não encontrada
		EndIf
	ENDIF
EndIf
If (LEN(aGuia) <> 0 .Or. lAtendTMK).AND. Empty(cMsg)
	If MsgYesNo(STR0043+B00->B00_COD) //"Deseja gerar o relatório do protocolo selecionado: "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona na Operadora para Dados Cadastrais...                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("BA0")
		BA0->(DbSetOrder(1))
		BA0->(DbSeek(xFilial("BA0") + cOper))
		aOperadora := { BA0->(BA0_NOMINT),BA0->(BA0_CIDADE),BA0->(BA0_EST) }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Preenche dados das Guia de Atendimento                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lAtendTMK
			if cAliasGuia == "BOW" //Se for protocolo reembolso, busca apenas os procedimentos que foram indeferidos.
				aNegativas := P001AIndef(aGuia)
			else
				aNegativas := P773Negat(aGuia,.T.)
				aAutorizad := P773Autor(aGuia)
			endif
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Emite a Justificativa...                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 	If Empty(aNegativas) .And. Empty(aAutorizad) .And. !lAtendTMK
			If cAliasGuia == "BOW"
				Aviso( STR0009, STR0091 , {STR0006} ) 	// "Atenção", "Não existem negativas para este protocolo de reembolso. Verifique o status e itens do protocolo."
			Else
				Aviso( STR0009, STR0042 , {STR0006} ) 	// "Atenção","Problema !!! "Não foram encontrados eventos na guia selecionada." !!!"
			EndIf
		Else
			PL773RNRel(aBene,aOperadora,aNegativas,aAutorizad,lImpEmail,lAtendTMK, cEmail)
		EndIf
	EndIf

ElseIf !Empty(cMsg)
	Aviso( STR0009, cMsg , {STR0006} ) 			// "Atenção","Problema !!! Mensagem !!!" "Fechar Tela"
ElseIf LEN(aGuia) == 0
	Aviso( STR0009, STR0033 , {STR0006} ) 			// "Atenção","Problema !!! Guia não encontrada !!!" "Fechar Tela"
EndIf


Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL773VsGui
Visualiza a guia selecionada
@author  PLS TEAM
@version P11
@since   07.04.16
/*/
//-------------------------------------------------------------------
Function PL773VsGui()

Local lFind := .F.

BEA->(DbSetOrder(__aTables[1, 3]))//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BEA_DATPRO+BEA_HORPRO
B44->(DbSetOrder(__aTables[2, 3]))//B44_FILIAL+B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT
B4A->(DbSetOrder(__aTables[3, 3]))//B4A_FILIAL+B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT

If B00->B00_TIPPRO <> "2"
	Do Case
	Case B00->B00_ALIGUI == "B4A"
		If B4A->(DbSeek(xFilial("B4A")+B00->B00_NUMGUI))
			PLS09AMov("B4A",B4A->(Recno()),K_Visualizar)
			lFind := .T.
		EndIf
	Case B00->B00_ALIGUI == "B4Q"
		If B4Q->(DbSeek(xFilial("B4Q")+B00->B00_NUMGUI))
			PLS09PMov("B4Q",B4Q->(Recno()),K_Visualizar)
			lFind := .T.
		EndIf
	Case B00->B00_ALIGUI == "B44"
		If B44->(DbSeek(xFilial("B44")+B00->B00_NUMGUI))
			PL001Mov("B44",B44->(Recno()),K_Visualizar)
			lFind := .T.
		EndIf
	Case B00->B00_ALIGUI == "BEA" .And. BEA->(DbSeek(xFilial("BEA")+B00->B00_NUMGUI))
		If BEA->BEA_TIPO == "4"
			PLS090OMov("BEA",BEA->(Recno()),K_Visualizar)
			lFind := .T.
		ElseIf BEA->BEA_TIPO == "3"
			BE4->(DbSetOrder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
			If BE4->(DbSeek(xFilial("BE4")+B00->B00_NUMGUI))
				PLSA092Mov("BE4",BE4->(Recno()),K_Visualizar)
				lFind := .T.
			EndIf
		Else
			PLSA090Mov("BEA",BEA->(Recno()),K_Visualizar)
			lFind := .T.
		EndIf	
	Case B00->B00_ALIGUI == "BOW"
		If BOW->(DbSeek(xFilial("BOW")+B00->B00_COD))
			PLBOWMOV("BOW",BOW->(Recno()),K_Visualizar)
			lFind := .T.
		EndIf
	EndCase
	
	If !lFind
		Aviso( STR0009, STR0033 , {STR0006} )// "Atenção","Problema !!! Guia não encontrada !!!"
	EndIf
Else
	Aviso( STR0009, STR0070 , {STR0006} )// "Atenção","Problema !!! "Não é possível apresentar a guia em protocolos de atendimento telefônico." !!!"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL773IncPr
Visualiza a guia selecionada
@author  PLS TEAM
@version P11
@since   15.04.16
/*/
//-------------------------------------------------------------------
Function PL773IncPr()

Local cNumProto := ""

If MsgYesNo(STR0068)//"Confirma a criação de um protocolo para ser adicionado o atendimento posteriormente?"
	gerRegB00(@cNumProto,nil,"BEA",.T.)
	Aviso( STR0009, STR0069+ cNumProto, {STR0006} ) 			// "Atenção","Problema !!! "Criado o protocolo: "!!!" "Fechar Tela"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PA773AtTMK
Carrega dados do usuario que foi atendido no Call Center para geracao
do relatorio/arquivo PDF
@author  PLS TEAM
@version P11
@since   15.04.16
/*/
//-------------------------------------------------------------------
Static Function PA773AtTMK()

Local aRet := {}

SUC->(DbSetOrder(1))//UC_FILIAL+UC_CODIGO

//Posiciona Atendimento no Call Center
If SUC->(DbSeek(xFilial("SUC")+B00->B00_CODATE))

	//Posiciona no contato utilizado
	AC8->(DbSetOrder(1))//AC8_FILIAL+AC8_CODCON+AC8_ENTIDA+AC8_FILENT+AC8_CODENT
	If AC8->(DbSeek(xFilial("AC8")+SUC->UC_CODCONT+"BA1"))

		//Posiciona no usuario PLS
		BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		If BA1->(DbSeek(xFilial("BA1")+AC8->AC8_CODENT))
			aRet := {Alltrim(BA1->BA1_NOMUSR),;
				BA1->BA1_CPFUSR,;
				AC8->AC8_CODENT}
		EndIf
	EndIf
EndIf

Return(aRet)



/*/{Protheus.doc} PLS773CONTAT
Gatilho para os campos CONTATO e E-MAIL
@author  Mario A. Cavenaghi
@version P12
@since   27-04-2016
/*/
FUNCTION PLS773CONTAT()

LOCAL aMatric := {"_OPEUSR", "_CODEMP", "_MATRIC", "_TIPREG", "_DIGITO"}	//	Campos para compor a Matricula
LOCAL cAliGui := IIF(!EMPTY(M->B00_ALIGUI), M->B00_ALIGUI, "BEA")
LOCAL cContat := cMatric := ""
LOCAL nFor    := 0

IF !EMPTY(M->B00_NUMGUI) .AND. (cAliGui)->(DBSEEK(XFILIAL() + M->B00_NUMGUI))
	cContat := &(cAliGui + "->" + cAliGui + "_NOMUSR")	//	Nome do Usuário
	cMatric := cAliGui + "->("
	FOR nFor := 1 TO LEN(aMatric)	//	Monta a String da Chave de pesquisar da Matricula
		cMatric += cAliGui + aMatric[nFor] + IIF(nFor < LEN(aMatric), " + ", ")")
	NEXT
	cMatric := &(cMatric)
	BA1->(DBSETORDER(2))
	IF BA1->(DBSEEK(XFILIAL() + cMatric))
		BTS->(DBSETORDER(1))
		IF BTS->(DBSEEK(XFILIAL() + BA1->BA1_MATVID))	//	Essa pesquisa é necessária pq nem todas as tabelas tem MATVID
			M->B00_EMAILD := BTS->BTS_EMAIL	//	Retorna o e-mail do cadastro para o campo
		ENDIF
	ENDIF
ENDIF

RETURN(cContat)


//-------------------------------------------------------------------
/*/{Protheus.doc} PL773RNRel

Imprime relatório da RN 395

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PL773RNRel(aBene,aOperadora,aNegativas,aAutorizad,lImpEmail,lAtendTMK, cEmail)

Local aDados    := {}
Local aRet      := {}
Local cTelCen	:= GetNewPar( "MV_PLSRTCA" , "" )	// Define o Telefone da Central de Atendimento a ser utilizado na impressão de cartas do SIGAPLS
Local cPathServ	:= GetNewPar( "MV_PLDIDOT" , "\dot" )
Local cSubPasta := PLSMUDSIS("pdf_email\")
Local cEmailTo	:= ALLTRIM(Lower(B00->B00_EMAILD))
Local lRetMail  := .F.
Local lRet      := .T.
Default cEmail := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama funcao com o corpo do relatorio								        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistBlock("PLRel395")
	Aviso( STR0009, STR0088 , {STR0078} ) 			// "Atenção" ## "Não foi encontrado o arquivo de modelo de relatório. Contate o administrador do sistema."
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dados do relatorio                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDados	:= Array(13) //Se criar mais itens no array, adicionar aqui o tamanho da estruttura
aDados[01] := IIf( Empty(aOperadora[02])     ,"[Mun. Operadora não infornado]"	,AllTrim(aOperadora[02]) )
aDados[02] := IIf( Empty(aOperadora[03])     ,"[UF. Operadora não infornado]" 	,AllTrim(aOperadora[03]) )
aDados[03] := StrZero(Day(Date()),2) +" de "+ MesExtenso( Month(Date()))  +" de "+  Str(Year(Date()),4)
aDados[04] := IIf( Empty(aBene[01])          ,"[Beneficiário não infornado]"  	,AllTrim(aBene[01]) )

If lAtendTMK
	aDados[05] := StrZero(Day(B00->B00_DTPROT),2) +"/"+ AllTrim(Str(Month(B00->B00_DTPROT)))  +"/"+  Str(Year(B00->B00_DTPROT),4)
Else
	If !Empty(aNegativas)
		aDados[05] := IIf( Empty(aNegativas[01])     ,"[Dt. de Atendimento não informada]" 	, ;
	   		StrZero(Day(aNegativas[01]),2) +"/"+ AllTrim(Str(Month(aNegativas[01])))  +"/"+  Str(Year(aNegativas[01]),4))
	ElseIf !Empty(aAutorizad)
		aDados[05] := IIf( Empty(aAutorizad[01])     ,"[Dt. de Atendimento não informada]" 	, ;
	   		StrZero(Day(aAutorizad[01]),2) +"/"+ AllTrim(Str(Month(aAutorizad[01])))  +"/"+  Str(Year(aAutorizad[01]),4))
	EndIf
EndIf

aDados[06] := IIf( Empty(aBene[02])          ,"[CPF não infornado]"           	,Transform(AllTrim(aBene[02]), "@R 999.999.999-99") )
aDados[07] := IIf( Empty(aBene[03])          ,"[Matricula não infornado]"     	,Transform(AllTrim(aBene[03]), "@R !!!!.!!!!.!!!!!!-!!-!") )
aDados[08] := IIf( Empty(cTelCen)            ,"0800-000.0000"                 	,AllTrim(cTelCen) )
aDados[09] := IIf( Empty(aOperadora[01])     ,"[Operadora não infornado]"     	,AllTrim(aOperadora[01]) )
aDados[10] := Alltrim(B00->B00_COD)
IIf(!Empty(B00->B00_OBSERV),aDados[11] := Alltrim(B00->B00_OBSERV),aDados[11] := "")
If lAtendTMK
	aDados[12] := B00->B00_OCOTMK
	aDados[13] := B00->B00_SOLTMK
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama funcao com o corpo do relatorio								        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := ExecBlock( "PLRel395", .F., .F., {aDados,aAutorizad,aNegativas,lAtendTMK,lImpEmail,cEmail} )
lRet := aRet[1]

If lImpEmail .And. lRet
	aRet2 := PLSMUDSIS(aRet[2])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o campo de Quantidades Geradas e Status                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	B00->(RecLock("B00",.F.))
	B00->B00_QTDGER := B00->B00_QTDGER + 1
	If B00->B00_STATUS <> "2"
		B00->B00_STATUS  := "2"
		B00->B00_DTENCE  := dDataBase
		B00->B00_HRENCE  := StrTran(Time(),":","")
	EndIf
	B00->(MsUnLock())

	If B00->B00_TPENVI == "2" .or. !Empty(cEmail)

		If !(Substr(cPathServ,len(cPathServ),1) == "\" .Or. Substr(cPathServ,len(cPathServ),1) == "/")
			cPathServ += "\"
		EndIF
		cPathServ  := PLSMUDSIS(cPathServ+cSubPasta)
		
		if(!Empty(cEmail))
			cEmailTo := cEmail
		else
			cEmailTo := ALLTRIM(Lower(B00->B00_EMAILD))
		endIf

		lRet := CpyT2S( aRet[2]+aRet[3], cPathServ, .F. )

		If lRet .And. !Empty(cEmailTo) .And. MsgYesNo(STR0089 +CRLF+ cEmailTo) //"Deseja enviar o protocolo de atendimento para o email: "
			lRetMail := A773Mail(cEmailTo, ;
			B00->B00_COD, ;
			nil,;
			nil, ;
			nil, ;
			nil,;
			.T.,;
			cPathServ+aRet[3])

			If lRetMail
				Aviso( STR0009 , STR0090 , {STR0078} ) // "Atenção" ,  "E-mail com Protocolo de Atendimento Enviado com sucesso."
				lEncerra := .T.
			Else
				Aviso( STR0009 , STR0024 , {STR0006} ) // "Atenção" , "Problemas ao enviar o e-mail ao Usuário. Entre em contato com o administrador."
			EndIf
		Else
			If Empty(cEmailTo)
				Aviso( STR0009 , STR0023 , {STR0078} )
			EndIf
		EndIf

	EndIf
EndIf

Return(nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} P773CPCon
Conclui um protocolo ao finalizar uma solicitacao de cancelamento de plano presencial
Complementa o registro B00 com informacoes do atendimento realizado.

@author  PLS TEAM
@version P11
@since   28.03.16
/*/
//------------------------------------------------------------------- 
Function P773CPCon(cNumProto,cCodigo,cOrigem,cStatus,cObserv,cEmail)
Default cEmail := ""   

If B00->(DbSeek(xFilial("B00")+cNumProto)) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera registro B00                    								    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	B00->(RecLock("B00",.F.))
	B00->B00_SOLCAN := cCodigo    
	B00->B00_ORICAN := cOrigem  
	B00->B00_STACAN := cStatus
	B00->B00_OBSCAN := cObserv
	B00->B00_TIPPRO := "4"   
	If !Empty(cEmail)
		B00->B00_EMAILD := cEmail
		B00->B00_TPENVI := "2"
	EndIf
	B00->(MsUnLock()) 
EndIf
	 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL773WEBRN
Carrega dados para solicitar o protocolo de atendimento  

@author  PLS TEAM
@version P11
@since   15.04.16
/*/
//-------------------------------------------------------------------   
Function PL773WEBRN(cNumProto,cMatric,lChamTMK,cAlias,cNumTraInt,lWeb,aDados,aAuto)
Local aDadUsr := {}         
LOCAL bOK     := {|| IIF(VldWebRN(.F.,cTelefone,cDDD,lChamTMK,cCombManif,cCombCateg,cMsgLivre),(nOpca := 1, oDlgRNWeb:End()),nOpca := 0) } 
LOCAL bCancel := {|| IIF(VldWebRN(.T.),(nOpca := 0, oDlgRNWeb:End()),nOpca := 0) }  //:= {|| nOpca := 0, oDlg:End() }  
LOCAL oFontTit	:= nil
LOCAL oListBox	:= nil
LOCAL nOpca     := 0     
Local aRet      := {}    
Local aIteSent  := {}  
Local aIteManif := {} 
Local aIteCateg := {}
Local cCombSent := ""
Local cCombManif:= ""
Local cCombCateg:= ""
Local nLabel    := 005
Local nGet      := 060       
Local nLin      := 050
Local lRetCom   := .F.           
Local nX        := 0
Local cMsgCri   := ""
Local cIdUsuResp   := GetNewPar( "MV_PLRESRN" , "" )   
Local nSize     := 0
Local lCheck1   := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Solicitar Protocolo de Atendimento                                   	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCodUniOri := "" //Código da Unimed Origem do envio do arquivo
Local cCodUniDes := "" //Código da Unimed Destino para envio do arquivo 
Local cNumRegAns := "" //Número de Registro da ANS da Unimed Destino
Local cNumTraPre := "" //ID da Manifestação (Número de Transação da Prestadora)
Local dDatGer    := "" //Data de geração da manifestação
Local cIDUsuario := "" //Usuário que solicitou a manifestação
Local cCodUniBen := "" //Código da Unimed
Local cIDBenef   := "" //Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
Local cNome      := "" //Nome do Beneficiário
Local cCPF       := "" //Código do CPF
Local cDDD       := Space(4) //Número do DDD
Local cTelefone  := Space(9) //Número do telefone
Local cEmail     := "" //Endereço de email
Local cTipManif  := "" //Tipo de Manifestação
Local cTipCateg  := "" //Categoria da Manifestação
Local cTipSent   := "" //Sentimento do Cliente
Local cIDResp    := "" //Indica o status da manifestação
Local cNumProAnt := Space(20) //Protocolo de Atendimento Anterior
Local cMsgLivre  := "" //Mensagem livre da manifestação
Local lGPURest   := GetNewPar("MV_PGPURES","0") == "1"

Default lChamTMK   := .F.     
Default cAlias     := "BEA"
Default lChamTMK   := .F.
Default cNumTraInt := ""       
Default lWeb       := .F.
Default aDados     := {}
Default aAuto      := {.F.,""}

aDadUsr := PLSDADUSR(cMatric,"1",.F.,dDataBase)

If !aDadUsr[1]      
	Aviso("Atenção","Problemas ao carregar dados do beneficiário, entre em contato com o administrador do sistema.",{"Ok"})
	Return
EndIf 

DbSelectArea("BA0")
BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BA0") + aDadUsr[45]))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis gerais                                                    	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodUniOri := PlsIntPad()
cCodUniDes := aDadUsr[45]
cNumRegAns := "" //Unimed do Brasil pediu para nao enviar este dado
cNumTraPre := ""
dDatGer    := dDataBase
cIDUsuario := cUserName 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informacoes do BA1                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA1->(DbSetOrder(2))////BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO    
If BA1->(DbSeek(xFilial("BA1")+cMatric))  

	cCodUniBen := Substr(aDadUsr[3],1,4) //Código da Unimed
	cIDBenef   := Substr(aDadUsr[3],5,13) //Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
	cNome      := Alltrim(BA1->BA1_NOMUSR)
	cCPF       := Alltrim(BA1->BA1_CPFUSR)
	cDDD       := Padr(cValToChar(BA1->BA1_DDD),2)
	cTelefone  := Padr(aDadUsr[79],9)
	cEmail     := Alltrim(BA1->BA1_EMAIL)
	cIDResp    := "" //Indica o status da manifestação
EndIf      
If lWeb 
	cDDD		:= aDados[1]
	cTelefone	:= aDados[2]
	cNumProAnt	:= aDados[3]
	cCombSent	:= aDados[4]
	cMsgLivre	:= aDados[5]
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define opcoes                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	aIteSent  := {'','1-Calmo','2-Desconfiado','3-Nervoso','4-Satisfeito'} 
	If lGPURest
		aIteManif := {'','1-Elogio','2-Reclamação','3-Denúncia','4-Sugestão','5-Dúvida','6-Solicitação','7-Correção reportada','8-Solicitação recebida pelo WhatsApp'} 
		aIteCateg := {'','01-Médicos Cooperados',"02-Hospitais/Clínicas Credenciadas","03-Hospitais/ Clínicas Unimed","04-Operadora Unimed","",; // Manifestação: 1,2,3,4
						 '05-Coberturas','06-Carência','07-Fatura','22-Guias pendentes fora do Prazo de resposta','23-Pedido de Autorização',"",; // Manifestação: 5
						 '08-Alterações Cadastrais','09-Estorno','10-Posição de Pagamento','11-IRPF','12-Parcerias/Doações','13-2ª via de boleto','14-Envio de Cartão',; // Manifestação: 6
						 '15-Documentos','16-Guia Médico','17-Pedido de Autorização','24-Extrato de utilização','41-Cancelamento','42-Indisponibilidade de Rede',"",; // Manifestação: 6		
						 '18-Telefone Incorreto', '19-Endereço Incorreto','20-Especialidade/Serviço Incorreto','21-Prestador não atende o plano',"",; // Manifestação: 7
						 '25-Cartão Digital','26-Guia Médico','27-Demonstrativos de IR','28-Autorizações','29-Informações do Plano','30-Segunda Via de Boleto','31-Reembolso','32-Unimed Mais Próxima','33-Consulta e Extrato de Coparticipação','34-Extrato de Utilização','35-Solicitação de Autorização','36-Consulta de Protocolo','37-2ª Via de Cartão','38-Atualizac?ão Cadastral','39-Débito em Conta','40-Histórico de Boletos','41-Cancelamento',""} // Manifestação: 8
	Else
		aIteManif := {'','1-Elogio','2-Reclamação','3-Denúncia','4-Sugestão','5-Dúvida','6-Solicitação'} 
		aIteCateg := {'','01-Médicos Cooperados',"02-Hospitais/Clínicas Credenciadas","03-Hospitais/ Clínicas Unimed","04-Operadora","",;
						'05-Coberturas','06-Carência','07-Fatura','','08-Cancelamento de Plano','09-Compra de Plano','10-Alterações Cadastrais',;
						'11-Estorno','12-Posição de Pagamento','13-IRPF','14-Parcerias/Doações','15-2ª via de boleto','16-Envio de Cartão',;
						'17-Documentos','18-Guia Médico','19-Procedimento Médico'}
	EndIf

	IIf(lChamTMK,nSize:=036.4,nSize:=032.4)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define dialogo...                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 
	DEFINE MSDIALOG oDlgRNWeb TITLE "Solicitar Protocolo de Atendimento - Benef. Intercâmbio" FROM 008.0,010.3 TO nSize,65
											   
	   @ 035,nLabel SAY oSay PROMPT "Solicitar protocolo de atendimento para beneficiário de intercâmbio"  SIZE 330,010 OF oDlgRNWeb PIXEL  COLOR CLR_RED
	                                                           	
	   @ nLin,nLabel SAY oSay PROMPT "DDD"  SIZE 060,010 OF oDlgRNWeb PIXEL COLOR CLR_RED
	   @ nLin,nGet   MSGET cDDD SIZE 015,006 OF oDlgRNWeb PIXEL FONT oFontTit COLOR CLR_BLACK 
	   
	   nLin := nLin+15
	   @ nLin,nLabel SAY oSay PROMPT "Telefone" SIZE 060,010 OF oDlgRNWeb PIXEL COLOR CLR_RED
	   @ nLin,nGet   MSGET cTelefone SIZE 080,006 PICTURE "@R !!!!!!!!!" OF oDlgRNWeb PIXEL FONT oFontTit COLOR CLR_BLACK 
	   
	   nLin := nLin+15
	   @ nLin,nLabel SAY oSay PROMPT "Protocolo Anterior"  SIZE 060,010 OF oDlgRNWeb PIXEL COLOR CLR_RED
	   @ nLin,nGet   MSGET cNumProAnt SIZE 080,006 F3 "B00ANT" VALID PlsProWebA(cNumProAnt,aDadUsr[2]) OF oDlgRNWeb PIXEL FONT oFontTit COLOR CLR_BLACK 
	   
	   If lChamTMK
		   nLin := nLin+15   
		   @ nLin,nLabel SAY oSay PROMPT "Tipo Manifestação"  SIZE 080,010 OF oDlgRNWeb PIXEL COLOR CLR_RED
		   cCombManif := aIteManif[1]
		   oCombo1    := TComboBox():New(nLin,nGet,{|U|if(PCount()>0,cCombManif:=U,cCombManif)},;
		                aIteManif,080,010,oDlgRNWeb,,;
		                ,,,,.T.,,,,,,,,,'cCombManif')  
		                
		   nLin := nLin+15   
		   @ nLin,nLabel SAY oSay PROMPT "Tipo Categoria"  SIZE 080,010 OF oDlgRNWeb PIXEL COLOR CLR_RED
		   cCombCateg := aIteCateg[1]
		   oCombo2   := TComboBox():New(nLin,nGet,{|U|if(PCount()>0,cCombCateg:=U,cCombCateg)},;
		                aIteCateg,080,010,oDlgRNWeb,,,;
		                {||AltCatComb(@cCombManif,@cCombCateg)},,,.T.,,,,,,,,,'cCombCateg')             
	   EndIf
	   
	   nLin := nLin+15   
	   @ nLin,nLabel SAY oSay PROMPT "Sentimento"  SIZE 080,010 OF oDlgRNWeb PIXEL COLOR CLR_RED
	   cCombSent := aIteSent[1]
	   oCombo3   := TComboBox():New(nLin,nGet,{|U|if(PCount()>0,cCombSent:=U,cCombSent)},;
	                aIteSent,080,010,oDlgRNWeb,,/*{||Alert('Mudou item da combo')}*/;
	                ,,,,.T.,,,,,,,,,'cCombSent')
	   
	   nLin := nLin+15
	   @ nLin,nLabel SAY oSay PROMPT "Resolvido Solicitante"  SIZE 080,010 OF oDlgRNWeb PIXEL COLOR CLR_RED                 
	   oCheck1 := TCheckBox():New(nLin+1,nGet,'',,oDlgRNWeb,10,10,,,,,,,,.T.,,,)
	   oCheck1:bSetGet := {|| lCheck1 }
	   oCheck1:bLClicked := {|| lCheck1:=!lCheck1 }
	   oCheck1:bWhen := {|| .T. }
	    
	   nLin := nLin+15
	   @ nLin,nLabel SAY oSay PROMPT "Mensagem Livre"  SIZE 080,010 OF oDlgRNWeb PIXEL COLOR CLR_RED
	   @ nLin-1,nGet   GET oMsg VAR cMsgLivre MEMO SIZE 150,050 PIXEL OF oDlgRNWeb          
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa dialogo....                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlgRNWeb CENTERED ON INIT Eval( { || EnChoiceBar(oDlgRNWeb,bOK,bCancel,.F.) } )
EndIf
If nOpca > 0 .Or. lWeb
    
	If !lChamTMK
		cTipManif  := "6"
		If lGPURest
  			cTipCateg  := "15"
		Else
			cTipCateg  := "19"
		EndIf
	Else
		cTipManif  := Substr(cCombManif,1,1)
  		cTipCateg  := cValtoChar(Val(Substr(cCombCateg,1,2)))   
	EndIf   
	
	If !lWeb .And. lCheck1
		cIDResp := "3"
	EndIf
	cTipSent   := Substr(cCombSent,1,1)
	cNumTraPre := PLB4JRegTr(cCodUniOri,cCodUniDes,"001") //StrZero( Val( B00->(GetSx8Num("B00","B00_TRAPRE") ) ),10)
	B00->(ConfirmSX8())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama WebService de Solicitacao de Protocolo                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lWeb
		aRet := PLSolProRN(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,dDatGer,;
							cIdUsuResp,cCodUniBen,cIDBenef,cNome,cCPF,cDDD,Alltrim(cTelefone),;
							cEmail,cTipManif,cTipCateg,cTipSent,cIDResp,cNumTraInt,cNumProAnt,cMsgLivre,aAuto)
	Else
		
		MsAguarde( {|| aRet := PLSolProRN(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,dDatGer,;
							cIDUsuario,cCodUniBen,cIDBenef,cNome,cCPF,cDDD,Alltrim(cTelefone),;
							cEmail,cTipManif,cTipCateg,cTipSent,cIDResp,cNumTraInt,cNumProAnt,cMsgLivre) }, 'Comunicando' , 'Aguarde', .F.)
	Endif 
								 
    If aRet[1]    
		cNumProto := aRet[3]
		cIdResp   := aRet[4]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava registro de protocolo na tabela B00                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		gerRegB00(cNumProto,nil,cAlias,.F.,lChamTMK,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),.T.,;
					   cTipManif,cTipCateg,cTipSent,cIdResp,cCodUniOri,cNumTraPre,cMsgLivre,cIDUsuario,cNumProAnt,cNumTraInt,nil,cCodUniDes)     

    	lRetCom   := .T.
	    		    	
  		If lChamTMK
  			M->UC_OBS := cMsgLivre 
  		EndIf
    Endif    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe resposta		                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lWeb 
		Return aRet
	Else
		If aRet[1]
			Aviso("Protocolo de Atendimento","Protocolo gerado: "+cNumProto,{"Ok"})
		Else
			cMsgCri := "Não foi possível gerar o protocolo. Críticas:"+Chr(10)+Chr(10)
	 		For nX := 1 to len(aRet[2])
	   	   		cMsgCri += Alltrim(aRet[2][nX][1])+"-"+Alltrim(aRet[2][nX][2])+Chr(10)
			Next   
			cMsgCri += Chr(10)+"Deseja solicitar o protocolo novamente?"
			If 	MsgYesNo(cMsgCri) 
				PL773WEBRN(@cNumProto,cMatric,lChamTMK,cAlias,cNumTraInt,lWeb,aDados)
			EndIf
		EndIf
	EndIf
EndIf
	
Return  

//-------------------------------------------------------------------
/*/{Protheus.doc} PL773WEBRN
Carrega dados para   

@author  PLS TEAM
@version P11
@since   15.04.16
/*/
//-------------------------------------------------------------------
Static Function VldWebRN(lCancel,cTelefone,cDDD,lChamTMK,cCombManif,cCombCateg,cMsgLivre)   
Local lRet := .T.    
Local cTitErro := ""
Local cMsgErro := ""
Default lCancel   := .F.
Default cTelefone := Space(9)
Default cDDD      := Space(4)
Default lChamTMK  := .F.
Default cMsgLivre := ""

If lCancel
	If !MsgYesNo("Não será realizada a solicitação de Protocolo para a Operadora Origem, deseja continuar?")
		lRet := .F.
	Endif
Else
	If Empty(cTelefone) .Or. Empty(cDDD)
		cTitErro := "Protocolo de Atendimento"
		cMsgErro := "É necessário informar o Telefone e DDD do beneficiário."
		lRet := .F.
	Endif
	If Empty(cMsgLivre)
		cTitErro := "Protocolo de Atendimento"
		cMsgErro := "É necessário informar uma Mensagem."
		lRet := .F.
	EndIf     
	If !Empty(cDDD) .And. Val(cDDD) < 11
		cTitErro := "Protocolo de Atendimento"
		cMsgErro := "O DDD informado é inválido."
		lRet := .F.	
	EndIf
	If !Empty(cMsgLivre) .And. len(Alltrim(cMsgLivre)) < 3
		cTitErro := "Protocolo de Atendimento"
		cMsgErro := "A mensagem dever ter pelo menos 3 caracteres."
		lRet := .F.
	EndIf
Endif

If lChamTMK .And. lRet
	lRet := AltCatComb(cCombManif,cCombCateg)
EndIf

If !lRet .And. !lCancel
	Aviso(cTitErro,cMsgErro,{"Ok"})
EndIf

Return lRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} AltCatComb
Valida preenchinento dos combos da solicitcao de protocolo via WebService   

@author  PLS TEAM
@version P11
@since   15.04.16
/*/
//-------------------------------------------------------------------
Static Function AltCatComb(cCombManif,cCombCateg)
Local lRet := .T.
Local cTitErro := ""
Local cMsgErro := ""

Do Case                                                	
	Case Empty( Substr(cCombManif,1,1) ) .And. !Empty(cCombCateg) 
   		cTitErro   := "Tipo de Manifestação inválido"
		cMsgErro   := "O campo 'Tipo Manifestação' é obrigatório"
   	   	lRet := .F.
   	   		
    Case Substr(cCombManif,1,1) $ "1/2/3/4" .And. !Empty(cCombCateg) .And. !Substr(cCombCateg,1,2) $ "01/02/03/04" 
 		cTitErro := "Categoria da Manifestação inválida"
		cMsgErro := "Quando selecionado o Tipo Manifestação '"+Alltrim(cCombManif)+"' o Tipo Categoria selecionado deve ser 01, 02, 03 ou 04."
  		lRet := .F.  
	    
	Case Substr(cCombManif,1,1) == "5" .And. !Empty(cCombCateg) .And. !Substr(cCombCateg,1,2) $ "05/06/07/22/23" 
 		cTitErro := "Categoria da Manifestação inválida"
		cMsgErro := "Quando selecionado o Tipo Manifestação '"+Alltrim(cCombManif)+"' o Tipo Categoria selecionado deve ser 05, 06, 07, 22 ou 23." 	
  		lRet := .F.  
   		
	Case Substr(cCombManif,1,1) == "6" .And. !Empty(cCombCateg) .And. !Substr(cCombCateg,1,2) $ "08/09/10/11/12/13/14/15/16/17/24/41/42" 
 		cTitErro := "Categoria da Manifestação inválida"
		cMsgErro := "Quando selecionado o Tipo Manifestação '"+Alltrim(cCombManif)+"' o Tipo Categoria selecionado deve ser 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 24, 41 ou 42."
		lRet := .F. 

	Case Substr(cCombManif,1,1) == "7" .And. !Empty(cCombCateg) .And. !Substr(cCombCateg,1,2) $ "18/19/20/21" 
		cTitErro := "Categoria da Manifestação inválida"
		cMsgErro := "Quando selecionado o Tipo Manifestação '"+Alltrim(cCombManif)+"' o Tipo Categoria selecionado deve ser 18, 19, 20 ou 21."
		lRet := .F. 

	Case Substr(cCombManif,1,1) == "8" .And. !Empty(cCombCateg) .And. !Substr(cCombCateg,1,2) $ "25/26/27/28/29/30/31/32/33/34/35/36/37/38/39/40/41" 
		cTitErro := "Categoria da Manifestação inválida"
		cMsgErro := "Quando selecionado o Tipo Manifestação '"+Alltrim(cCombManif)+"' o Tipo Categoria selecionado deve ser 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40 ou 41"
		lRet := .F. 
EndCase

If !lRet
	Aviso(cTitErro,cMsgErro,{"Ok"}) 
Endif

Return lRet        

Return                 

                                                 
//-------------------------------------------------------------------
/*/{Protheus.doc} PLCtManBox

Retorna CBOX do campo B00_CATEG
@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PLCtManBox()
Local cRet := ""

cRet := "1=Médicos Cooperados;2=Hospitais/Clínicas Credenciadas;3=Hospitais/ Clínicas Unimed;4=Operadora;5=Coberturas;6=Carências;7=Fatura"
cRet += "8=Cancelamento de Plano;9=Compra de Plano;10=Alterações Cadastrais;11=Estorno;12=Posição de Pagamento;13=IRPF"
cRet += "14=Parcerias/Doações;15=2ª via de boleto;16=Envio de Cartão;17=Documentos;18=Guia Médico;19=Procedimento Médico"

Return cRet
        

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsProWebA

Valida digitacao do Protocolo Anterior
@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PlsProWebA(cNumProAnt,cMatric)
Local lRet := .F.  
Local aArea := B00->(GetArea())

B00->(DbSetOrder(1))
If Empty(cNumProAnt) .Or. (B00->(DbSeek(xFilial("B00")+cNumProAnt)) .And. cMatric == B00->B00_MATRIC )
	lRet := .T.	
Else
	Aviso("Pesquisa de protocolos", "O protocolo digitado é inválido", {"Ok"} )
Endif
RestArea(aArea)

Return lRet    
    

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsProWebA

Monta tela de visualizacao com GetDados 
@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PL773GETRN()     
LOCAL bOK		:= {|| nOpca := 1,oDlg:End(),oDlg:End(),.F.}
LOCAL bCancel	:= {|| oDlg:End()}
LOCAL nLarg 	:= 0
LOCAL nTop   	:= 0
LOCAL nLeft 	:= 0
LOCAL nBottom	:= 0

LOCAL cTexto    := ""

LOCAL aB4ICols  := {}
LOCAL aB4IHeader:= {}
LOCAL aPosObj	:= {}
LOCAL aObjects	:= {}
LOCAL aSize		:= {}
LOCAL aPGet		:= {}
LOCAL aInfo		:= {}   
LOCAL aButtons  := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aCols e aHeader...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "B4I"  TO aB4IHeader For .T.

dbSelectArea( "B4I" )
dbSetOrder(1)              
B4I->(DbSeek(xFilial("B4I")+B00->B00_COD))
Store COLS "B4I" TO aB4ICols FROM aB4IHeader While B4I->B4I_PROTOC == B00->B00_COD
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta tamanho dos objetos.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
AAdd( aObjects, { 010, 150, .T., .F. } )
AAdd( aObjects, { 010, 100, .T., .T. } )

aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects )

//aadd(aButtons,{"",{||"RELATORIO", PL773RESWS(@oGet)},"","Responder Protocolo"})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE "Protocolo de Atendimento" FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
dbSelectArea("B00")
dbSetOrder(1)
dbSeek(xFilial("B00")+B00->B00_COD)

RegToMemory("B00",.F.)

Enchoice( "B00", , 2, , , , , aPosObj[1], {}, , , , "AlwaysTrue()", oDlg)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta a posiçao e tamanho do Get                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLarg	:= aPosObj[2,4]*0.8
nTop 	:= aPosObj[2,1]
nLeft 	:= aPosObj[2,2]
nBottom	:= aPosObj[2,3]

//oGet := MSNewGetDados():New(nTop, nLeft, nBottom, nLarg, GD_INSERT, "AlwaysTrue()", "AlwaysTrue()", "" , {}, 0, 99, "AlwaysTrue()", "AlwaysTrue()", "AlwaysTrue()", oDlg, aB4IHeader, aB4ICols, , "" )
oGet := MSNewGetDados():New(nTop, nLeft, nBottom, nLarg,  , , , , {}, 0, 99, , , , oDlg, aB4IHeader, aB4ICols, , )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta a posiçao e tamanho do MEMO                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLeft += nLarg
nLarg := aPosObj[2,4] * 0.19
nBottom *= 0.80
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a variável do Memo                                    		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTexto := B4I->B4I_MENSAG
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o Memo						                                 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nTop, nLeft Get oMemo Var cTexto Memo When .F. Size nLarg, nBottom Of oDlg Pixel
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta a função para alterar dinâmicamente o Memo                    		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet:bChange  := {||PLB4IMEM(@cTexto, oMemo, oGet)}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons)  })
   
Return

    
//-------------------------------------------------------------------
/*/{Protheus.doc} PLB4IMEM

Exibe as observacoes no memo 
@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Static Function PLB4IMEM(cTexto, oObj, oGet)
LOCAL nPosObs := GDFieldPos("B4I_MENSAG",oGet:aHeader)

If ValType(oObj) <> 'U'
	cTexto:= oGet:aCols[oGet:nAt][nPosObs]     
	oObj:Refresh()
EndIf

Return Nil

 
//-------------------------------------------------------------------
/*/{Protheus.doc} PL773RESWS

Rotina para responder um protocolo pendente
@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PL773RESWS(aAuto)
Local aRet      := {}
LOCAL bOK       := {|| nOpca := 1, IIf(ValidResProt(cTipoSolic, cDevClient),oDlgResp:End(), .F.) } 
LOCAL bCancel	:= {|| oDlgResp:End()}  
LOCAL oFontTit	:= nil
LOCAL oListBox	:= nil
LOCAL nX        := 0
LOCAL nOpca     := 0     
Local nLabel    := 005
Local nGet      := 060       
Local nLin      := 035    
Local cMsgLivre := ""
Local cCombStat := ""
Local cMsg      := ""
Local cAlias    := ""
Local aIteStat  := {}     
Local lRetCom   := .F.
Local lNoClient := .F.
Local aDevolucao := {" ", "1-Sim", "2-Não"}
Local cDevClient := " "
Local cTipoSolic := ""
Local aNoClient := {}

Default aAuto   := {.F.,""}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
If B00->B00_INTERC == "1" .And. B00->B00_OPESOL <> PlsIntPad() .And. !B00->B00_STAINT $ "3/4" .And. (Empty(B00->B00_ALIGUI) .Or. aAuto[1])

	If B00->(FieldPos("B00_TPSOLI"))
		If !Empty(B00->B00_TPSOLI)
			lNoClient := .T.
			cTipoSolic := B00->B00_TPSOLI
		EndIf
	EndIf

	If lNoClient
		aIteStat := {'2-Em andamento','3-Finalizado'}
	Else
		aIteStat := {'1-Pendente','2-Em andamento','3-Finalizado','4-Cancelado'}
	EndIf
	
	if aAuto[1]
		nOpca := 1  
		If lNoClient
			cCombStat := "3"
			cDevClient := "1"
		Else
			cCombStat := "1"
		EndIf		
	else
		DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011

		If lNoClient
			DEFINE MSDIALOG oDlgResp TITLE "Responder Protocolo de Atendimento - Não Cliente" FROM 008.0,010.3 TO 034.4,65
		Else 
			DEFINE MSDIALOG oDlgResp TITLE "Responder Protocolo de Atendimento - Benef. Intercâmbio" FROM 008.0,010.3 TO 034.4,65
		EndIf
												
		@ 010,nLabel SAY oSay PROMPT "Responder Protocolo de Atendimento pendente"  SIZE 330,010 OF oDlgResp PIXEL  COLOR CLR_RED
		
		@ nLin,nLabel SAY oSay PROMPT "Status"  SIZE 080,010 OF oDlgResp PIXEL COLOR CLR_RED
		cCombStat := aIteStat[1]
		oCombo    := TComboBox():New(nLin,nGet,{|U|if(PCount()>0,cCombStat :=U,cCombStat)},;
					aIteStat,080,020,oDlgResp,,,,,,.T.,,,,,,,,,'cCombStat')            
		
																	
		nLin := nLin+20
		@ nLin,nLabel SAY oSay PROMPT "Mensagem Livre"  SIZE 080,010 OF oDlgResp PIXEL COLOR CLR_RED
		@ nLin,nGet   GET oMsg VAR cMsgLivre MEMO SIZE 150,050 PIXEL OF oDlgResp  

		If lNoClient
			nLin := nLin+55
			@ nLin,nLabel SAY oSay PROMPT "Tornou-se Cliente?" SIZE 080,010 OF oDlgResp PIXEL COLOR CLR_RED
			cDevClient := aDevolucao[1]
			oComboDev := TComboBox():New(nLin, nGet,{|U| if(PCount() > 0 ,cDevClient := U, cDevClient)},;
						aDevolucao, 080, 020, oDlgResp,,,,,, .T.,,,,,,,,, "cDevClient")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ativa dialogo....                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ACTIVATE MSDIALOG oDlgResp CENTERED ON INIT Eval( { || EnChoiceBar(oDlgResp,bOK,bCancel,.F.) } )
	endIf

	If nOpca == 1  
		
		BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
		BA0->(DbSeek(xFilial("BA0")+B00->B00_OPESOL))      
		cNumTraPre := PLB4JRegTr(PlsIntPad(),B00->B00_OPESOL,"005")
		
		lRetB4I := GerRegB4I(B00->B00_COD,Substr(cCombStat,1,1),cMsgLivre,cUserName,dDataBase,,Substr(cDevClient,1,1))
		
		If lRetB4I 
			B00->(RecLock("B00",.F.)) 
			B00->B00_STAINT  := Substr(cCombStat,1,1)  
			B00->(MsUnLock())
		EndIf	

		If lNoClient
			aAdd(aNoClient, B00->B00_TPSOLI)
			aAdd(aNoClient, B00->B00_CPFCLI)
			aAdd(aNoClient, B00->B00_CNPJCL)
			aAdd(aNoClient, B00->B00_EMAILD)
			aAdd(aNoClient, Substr(cDevClient,1,1))
		EndIf
		
		If aAuto[1]
			PLResAteRN(PlsIntPad(),B00->B00_OPESOL,"",cNumTraPre,dDataBase,cUserName,Substr(B00->B00_MATRIC,1,4),;
					   Substr(B00->B00_MATRIC,5,13),B00->B00_COD,Substr(cCombStat,1,1),IIF(!Empty(B00->B00_NRTROL),;
					   Alltrim(B00->B00_NRTROL),"0"),cMsgLivre,aAuto,aNoClient)

		Else
			While !lRetCom 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chama WebService de Solicitacao de Protocolo                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MsAguarde( {|| aRet := PLResAteRN(PlsIntPad(),B00->B00_OPESOL,"",cNumTraPre,dDataBase,cUserName,Substr(B00->B00_MATRIC,1,4),;
							Substr(B00->B00_MATRIC,5,13),B00->B00_COD,Substr(cCombStat,1,1),IIF(!Empty(B00->B00_NRTROL),Alltrim(B00->B00_NRTROL),"0"),cMsgLivre,,aNoClient) }, 'Comunicando' , "Aguarde", .F.) //"Aguarde..."
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exibe resposta		                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aRet[1]
					Aviso("Protocolo de Atendimento","Protocolo respondido com sucesso",{"Ok"}) 
					lRetCom := .T.
				Else
					cMsgCri := "Não foi possível responder o protocolo. Críticas:"+Chr(10)+Chr(10)
					For nX := 1 to len(aRet[2])
						cMsgCri += Alltrim(aRet[2][nX][1])+"-"+Alltrim(aRet[2][nX][2])+Chr(10)
					Next   
					cMsgCri += Chr(10)+"Deseja responder o protocolo novamente?"
					If 	!MsgYesNo(cMsgCri) 
						lRetCom := .T.
					EndIf
				EndIf
			EndDo	
		EndIf
	EndIf
Else     
	If  B00->B00_INTERC <> "1" 
		cMsg := "O atendimento selecionado não é de intercâmbio."   
	ElseIf B00->B00_OPESOL == PlsIntPad()  	
		cMsg := "A operadora solicitante do atendimento deve ser diferente da operadora padrão do Operador de sistema."  
	ElseIf B00->B00_STAINT $ "3/4"     	
		cMsg := "O atendimento selecionado já foi finalizado ou cancelado."   
	ElseIf !Empty(B00->B00_ALIGUI)
		cMsg := "Protocolos de guias de atendimento devem ser respondidos na Auditoria de Conta."  
	EndIf
		
	Aviso("Responder Protocolo",cMsg,{"Ok"})
EndIf 

Return   

//-------------------------------------------------------------------
/*/{Protheus.doc} PL773STAWS

Rotina para consultar o status de um protocolo
@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PL773STAWS(aAuto)
Local cMsg      := "" 
Local cTpManif  := "" 
Local cTpCateg  := "" 
Local cTpSentim := ""     
Local nX      := 0
Local aRetWeb := {} 
Local aDados  := {}
Default aAuto := {.F.,""}

If B00->B00_INTERC == "1" .And. B00->B00_OPESOL == PlsIntPad()
	If aAuto[1] .Or. MsgYesNo("Confirma o Consulta ao Protocolo "+B00->B00_COD+" ?") 
	
		aDadUsr := PLSDADUSR(B00->B00_MATRIC,"1",.F.,dDataBase)       
		BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
		BA0->(DbSeek(xFilial("BA0")+aDadUsr[45]))      
		
		if aAuto[1]
			aRetWeb := PLConStaRN(PlsIntPad(),aDadUsr[45],"",B00->B00_TRAPRE,dDataBase,;
											  cUserName,Substr(aDadUsr[3],1,4),Substr(aDadUsr[3],5,13) ,B00->B00_COD,aAuto)
		else
			MsAguarde( {|| aRetWeb := PLConStaRN(PlsIntPad(),aDadUsr[45],"",B00->B00_TRAPRE,dDataBase,;
											  cUserName,Substr(aDadUsr[3],1,4),Substr(aDadUsr[3],5,13) ,B00->B00_COD) }, 'Comunicando' , "Aguarde", .F.) //"Aguarde..."
		endIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe resposta		                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		If aRetWeb[1]    
			B00->(RecLock("B00",.F.))
			B00->B00_STAINT  := aRetWeb[7]
			If aRetWeb[7] == "4"
				B00->B00_CANCEL := "1"
			EndIf
			B00->(MsUnLock())	  

			Aadd( aDados,{ "Número Protocolo",aRetWeb[3] } ) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Status                                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do Case
				Case aRetWeb[7] == "1"
		   			Aadd( aDados,{ "Status","1-Pendente" } ) 
		   		
		   		Case aRetWeb[7] == "2"
		   			Aadd( aDados,{ "Status","2-Em andamento" } ) 
		   		
		   		Case aRetWeb[7] == "3"
		   			Aadd( aDados,{ "Status","3-Finalizado" } ) 
		  			
		  			Case aRetWeb[7] == "4"
		   			Aadd( aDados,{ "Status","4-Cancelado" } ) 
		   	EndCase   
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tipo de Manifestacao                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    Do Case
				Case aRetWeb[4] == "1"
		   			cTpManif := "1-Elogio"
		   		Case aRetWeb[4] == "2"
		   			cTpManif := "2-Reclamação"
		   		Case aRetWeb[4] == "3"
					cTpManif := "3-Denúncia"
				Case aRetWeb[4] == "4"
		   			cTpManif := "4-Sugestão" 
				Case aRetWeb[4] == "5"
		   			cTpManif := "5-Dúvida"
				Case aRetWeb[4] == "6"
		   			cTpManif := "6-Solicitação"		
		   	EndCase   	 
		   	Aadd( aDados,{ "Tipo de Manifestacao",cTpManif } )   
		  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tipo de Categoria                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
			Do Case
				Case aRetWeb[5] == "1"
		   			cTpCateg := "1-Médicos Cooperados"
	   			Case aRetWeb[5] == "2"
		   			cTpCateg := "2-Hospitais/Clínicas Credenciadas"
				Case aRetWeb[5] == "3"
		   			cTpCateg := "3-Hospitais/ Clínicas Unimed"
				Case aRetWeb[5] == "4"
					cTpCateg := "4-Operadora"
				Case aRetWeb[5] == "5"
		  			cTpCateg := "5-Coberturas"
		   		Case aRetWeb[5] == "6"
		   			cTpCateg := "6-Carência"
		   		Case aRetWeb[5] == "7"
		   			cTpCateg := "7-Fatura" 
				Case aRetWeb[5] == "8"
		   			cTpCateg := "8-Cancelamento de Plano"	 
		  		Case aRetWeb[5] == "9"
		  			cTpCateg := "9-Compra de Plano"		
		  		Case aRetWeb[5] == "10"
		   			cTpCateg := "10-Alterações Cadastrais"			
		   		Case aRetWeb[5] == "11"
		   			cTpCateg := "11-Estorno" 
		   		Case aRetWeb[5] == "12"
		   			cTpCateg := "12-Posição de Pagamento"				
		   		Case aRetWeb[5] == "13"
		   			cTpCateg := "13-IRPF"	 
		   		Case aRetWeb[5] == "14"
		   			cTpCateg := "14-Parcerias/Doações"		
		   		Case aRetWeb[5] == "15"
		   			cTpCateg := "15-2ª via de boleto"	
		   		Case aRetWeb[5] == "16"
		   			cTpCateg := "16-Envio de Cartão"
		   		Case aRetWeb[5] == "17"
		   			cTpCateg := "17-Documentos"  
		   		Case aRetWeb[5] == "18"
		   			cTpCateg := "18-Guia Médico"	
		   		Case aRetWeb[5] == "19"
		   			cTpCateg := "19-Procedimento Médico"		
		   	EndCase		  
	       	Aadd( aDados,{ "Tipo de Categoria",cTpCateg } )    
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tipo de Sentimento                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			Do Case
				Case aRetWeb[6] == "1"
		   			cTpSentim := "1-Calmo"
				Case aRetWeb[6] == "2"
					cTpSentim := "2-Desconfiado"
			 	Case aRetWeb[6] == "3"
			 		cTpSentim := "3-Nervoso		
				Case aRetWeb[6] == "4"
			   		cTpSentim := "4-Satisfeito"                                          
			EndCase
			Aadd( aDados,{ "Tipo de Sentimento",cTpSentim } )   
			   	
        	Aadd( aDados,{ "","" } )
			Aadd( aDados,{ "","" } )     
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Array Dados Mensagem Pedido                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			Aadd( aDados,{ "---- Dados Mensagem Pedido ----","" } )  
			For nX := 1 to len(aRetWeb[8])
   
				Aadd( aDados,{ "Usuario",aRetWeb[8][nX][1] } )     
				Aadd( aDados,{ "Data Envio Mensagem",aRetWeb[8][nX][2] } )
				Aadd( aDados,{ "Data Resposta Mensagem",aRetWeb[8][nX][3] } )
				Aadd( aDados,{ "Mensagem Livre",aRetWeb[8][nX][4] } )
	
				Aadd( aDados,{ "","" } )
			Next           
   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Array Dados Mensagem Resposta                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			Aadd( aDados,{ "---- Dados Mensagem Resposta ---- ","" } )  
			For nX := 1 to len(aRetWeb[9])
		  		Aadd( aDados,{ "Usuario",aRetWeb[9][nX][1] } )     
				Aadd( aDados,{ "Data Envio Mensagem",aRetWeb[9][nX][2] } )
				Aadd( aDados,{ "Data Resposta Mensagem",aRetWeb[9][nX][3] } )
				Aadd( aDados,{ "Mensagem Livre",aRetWeb[9][nX][4] } )
	
				Aadd( aDados,{ "","" } )
			Next           
			if !aAuto[1]
				PLSCRIGEN(aDados,{ {"Campo","@C",90} , {"Conteúdo","@C",80 } },"Resumo da Comunicação")
			endIf
		Else
			cMsg   := "Não foi possível solicitar consultar o Status do Protocolo. Críticas:"+Chr(10)+Chr(10)
			For nX := 1 to len(aRetWeb[2])
				cMsg += Alltrim(aRetWeb[2][nX][1])+"-"+Alltrim(aRetWeb[2][nX][2])+Chr(10)
		  	Next
			if !aAuto[1]  
		    	MsgInfo(cMsg)
			endIf
		EndIf
	
	EndIf
Else 
	If  B00->B00_INTERC <> "1" 
		cMsg := "O atendimento selecionado não é de intercâmbio."  
	ElseIf B00->B00_OPESOL <> PlsIntPad()  	
		cMsg := "A operadora solicitante do atendimento deve ser igual a operadora padrão do Operador de sistema."  
	EndIf

	if !aAuto[1]
		Aviso("Responder Protocolo",cMsg,{"Ok"})
	endIf

EndIf
	
Return
   

//-------------------------------------------------------------------
/*/{Protheus.doc} PL773HISWS 

Rotina para consultar o historico de um protocolo
@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PL773HISWS(aAuto) 
Local aDadUsr   := {}         
LOCAL bOK       := {|| IIF(!Empty(cMatAnt),(nOpca := 1, oDlgHist:End()),(Aviso("Consulta Histórico Protocolo","É necessário informar o beneficiário.",{"Ok"}),nOpca := 0) ) }
LOCAL bCancel	:= {|| oDlgHist:End()}  
LOCAL oFontTit	:= nil
LOCAL nOpca     := 0     
Local nLabel    := 005
Local nGet      := 060       
Local nLin      := 040    
Local cMatric   := Space(17)
Local cMatAnt   := Space(17)
Local cNome     := Space(50)
Local dDatSol   := Stod(Space(8))
Local dDatResp  := Stod(Space(8))
Local cNumProto := Space(20)      
Local cData     := ""         
Local cTpManif  := ""
Local cTpCateg  := ""
Local cTpSentim := ""

Local nX        := 0
Local cMsg      := ""
Local aDados    := {}          
Local aRetWeb   := {}
Default aAuto   := {.F., "", "",CToD(" / / "), CToD(" / / ")}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
if aAuto[1]
	nOpca   := 1
	cMatric := aAuto[3]
	dDatSol := aAuto[4]
	dDatResp := aAuto[5]
else
	DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 
	DEFINE MSDIALOG oDlgHist TITLE "Consultar Histórico de Protocolo" FROM 008.0,010.3 TO 034.4,65
											
	@ 010,nLabel SAY oSay PROMPT "Consultar Histórico de Protocolo"  SIZE 330,010 OF oDlgHist PIXEL  COLOR CLR_RED
	
	@ nLin,nLabel SAY oSay PROMPT "Matrícula" SIZE 060,010 OF oDlgHist PIXEL COLOR CLR_RED
	@ nLin,nGet   MSGET cMatric SIZE 080,006  OF oDlgHist F3 "BY2PLS" VALID VldMatHis(@oDlgHist,cMatric,@cMatAnt,@cNome) PIXEL FONT oFontTit COLOR CLR_BLACK 

	nLin := nLin+15
	@ nLin,nLabel SAY oSay PROMPT "Matrícula Cartão" SIZE 060,010 OF oDlgHist PIXEL COLOR CLR_RED
	@ nLin,nGet   MSGET cMatAnt SIZE 080,006  OF oDlgHist  PIXEL FONT oFontTit COLOR CLR_BLACK WHEN .F.

	nLin := nLin+15
	@ nLin,nLabel SAY oSay PROMPT "Nome Beneficiário" SIZE 060,010 OF oDlgHist PIXEL COLOR CLR_RED
	@ nLin,nGet   MSGET cNome SIZE 100,006  OF oDlgHist  PIXEL FONT oFontTit COLOR CLR_BLACK WHEN .F.
																	
	nLin := nLin+15
	@ nLin,nLabel SAY oSay PROMPT "Protocolo"  SIZE 060,010 OF oDlgHist PIXEL COLOR CLR_RED
	@ nLin,nGet   MSGET cNumProto SIZE 080,006 F3 "B00ANT" VALID PlsProWebA(cNumProto,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)) OF oDlgHist PIXEL FONT oFontTit COLOR CLR_BLACK

	nLin := nLin+15    
	@ nLin,nLabel SAY oSay PROMPT "Data Solicitação"  SIZE 080,010 OF oDlgHist PIXEL COLOR CLR_RED
	@ nLin,nGet   MSGET dDatSol SIZE 050,010 PIXEL OF oDlgHist    

	nLin := nLin+15
	@ nLin,nLabel SAY oSay PROMPT "Data Resposta"  SIZE 080,010 OF oDlgHist PIXEL COLOR CLR_RED
	@ nLin,nGet   MSGET dDatResp SIZE 050,010 PIXEL OF oDlgHist    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa dialogo....                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlgHist CENTERED ON INIT Eval( { || EnChoiceBar(oDlgHist,bOK,bCancel,.F.) } )
endIf

If nOpca == 1  
	aDadUsr := PLSDADUSR(cMatric,"1",.F.,dDataBase)       
	BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	BA0->(DbSeek(xFilial("BA0")+aDadUsr[45]))      

	if aAuto[1]
		aRetWeb := PLConHisRN(PlsIntPad(),aDadUsr[45],"",B00->B00_TRAPRE,dDatabase,;
										  cUserName,Substr(aDadUsr[3],1,4),Substr(aDadUsr[3],5,13) ,cNumProto,dDatSol,dDatResp,aAuto)
	else		
		MsAguarde( {|| aRetWeb := PLConHisRN(PlsIntPad(),aDadUsr[45],"",B00->B00_TRAPRE,dDatabase,;
										  cUserName,Substr(aDadUsr[3],1,4),Substr(aDadUsr[3],5,13) ,cNumProto,dDatSol,dDatResp) }, 'Comunicando' , "Aguarde", .F.) //"Aguarde..."
	endIf

	If aRetWeb[1]  
		If len(aRetWeb[3]) == 0 
			Aadd( aDados,{ "Não foram encontrado dados para a sua pesquisa","" } )
		EndIf
		
		For nX := 1 to len(aRetWeb[3])
			/*
		 	[1] -> numeroProtocolo
	 		[2] -> dataGeracao
	  		[3] -> idUsuario
			[4] -> numeroTransacaoIntercambioPrestadora
			[5] -> numeroTransacaoOrigemBeneficiario
			[6] -> idResposta 
			[7] -> tipoManifestacao 
			[8] -> tipoCategoria      
			[9] -> tipoSentimento
			*/    
			cData := Substr(aRetWeb[3][nX][2] ,7,2) +"/"+Substr(aRetWeb[3][nX][2],5,2)+"/"+Substr(aRetWeb[3][nX][2],1,4)
			Aadd( aDados,{ "Número Protocolo",aRetWeb[3][nX][1] } ) 
			Aadd( aDados,{ "Data Geração",    cData } )
			Aadd( aDados,{ "ID do usuário",   aRetWeb[3][nX][3] } )
			Aadd( aDados,{ "Num. Trans. Intercambio Prestadora", aRetWeb[3][nX][4] } )
			Aadd( aDados,{ "Num. Trans. Origem Beneficiario"   , aRetWeb[3][nX][5] } )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Status                                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do Case
				Case aRetWeb[3][nX][6] == "1"
		   			Aadd( aDados,{ "Status","1-Pendente" } ) 
		   		
		   		Case aRetWeb[3][nX][6] == "2"
		   			Aadd( aDados,{ "Status","2-Em andamento" } ) 
		   		
		   		Case aRetWeb[3][nX][6] == "3"
		   			Aadd( aDados,{ "Status","3-Finalizado" } ) 
	   			
	   			Case aRetWeb[3][nX][6] == "4"
		   			Aadd( aDados,{ "Status","4-Cancelado" } ) 
		   	EndCase   
	    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tipo de Manifestacao                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    Do Case
				Case aRetWeb[3][nX][7] == "1"
		   			cTpManif := "1-Elogio"
		   		Case aRetWeb[3][nX][7] == "2"
		   			cTpManif := "2-Reclamação"
		   		Case aRetWeb[3][nX][7] == "3"
					cTpManif := "3-Denúncia"
	   			Case aRetWeb[3][nX][7] == "4"
		   			cTpManif := "4-Sugestão" 
	   			Case aRetWeb[3][nX][7] == "5"
		   			cTpManif := "5-Dúvida"
	   			Case aRetWeb[3][nX][7] == "6"
		   			cTpManif := "6-Solicitação"		
		   	EndCase   	 
		   	Aadd( aDados,{ "Tipo de Manifestacao",cTpManif } )   
		  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tipo de Categoria                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
			Do Case
				Case aRetWeb[3][nX][8] == "1"
		   			cTpCateg := "1-Médicos Cooperados"
   				Case aRetWeb[3][nX][8] == "2"
		   			cTpCateg := "2-Hospitais/Clínicas Credenciadas"
	   			Case aRetWeb[3][nX][8] == "3"
		   			cTpCateg := "3-Hospitais/ Clínicas Unimed"
	   			Case aRetWeb[3][nX][8] == "4"
		   			cTpCateg := "4-Operadora"
	   			Case aRetWeb[3][nX][8] == "5"
		   			cTpCateg := "5-Coberturas"
		   		Case aRetWeb[3][nX][8] == "6"
		   			cTpCateg := "6-Carência"
		   		Case aRetWeb[3][nX][8] == "7"
		   			cTpCateg := "7-Fatura" 
	   			Case aRetWeb[3][nX][8] == "8"
		   			cTpCateg := "8-Cancelamento de Plano"	 
		   		Case aRetWeb[3][nX][8] == "9"
		   			cTpCateg := "9-Compra de Plano"		
		   		Case aRetWeb[3][nX][8] == "10"
		   			cTpCateg := "10-Alterações Cadastrais"			
		   		Case aRetWeb[3][nX][8] == "11"
		   			cTpCateg := "11-Estorno" 
		   		Case aRetWeb[3][nX][8] == "12"
		   			cTpCateg := "12-Posição de Pagamento"				
		   		Case aRetWeb[3][nX][8] == "13"
		   			cTpCateg := "13-IRPF"	 
		   		Case aRetWeb[3][nX][8] == "14"
		   			cTpCateg := "14-Parcerias/Doações"		
		   		Case aRetWeb[3][nX][8] == "15"
		   			cTpCateg := "15-2ª via de boleto"	
		   		Case aRetWeb[3][nX][8] == "16"
		   			cTpCateg := "16-Envio de Cartão"
		   		Case aRetWeb[3][nX][8] == "17"
		   			cTpCateg := "17-Documentos"  
		   		Case aRetWeb[3][nX][8] == "18"
		   			cTpCateg := "18-Guia Médico"	
		   		Case aRetWeb[3][nX][8] == "19"
		   			cTpCateg := "19-Procedimento Médico"		
		   	EndCase		  
          	Aadd( aDados,{ "Tipo de Categoria",cTpCateg } )    
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tipo de Sentimento                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	   		Do Case
				Case aRetWeb[3][nX][8] == "1"
		   			cTpSentim := "1-Calmo"
		   		Case aRetWeb[3][nX][8] == "2"
		   			cTpSentim := "2-Desconfiado"
		   		Case aRetWeb[3][nX][8] == "3"
		   			cTpSentim := "3-Nervoso		
				Case aRetWeb[3][nX][8] == "4"
		   			cTpSentim := "4-Satisfeito"                                          
            EndCase
		   	Aadd( aDados,{ "Tipo de Sentimento",cTpSentim } )   		   	
		   	
			//Aadd( aDados,{ Replicate("-",50),Replicate("-",100) } )
			Aadd( aDados,{ "","" } )
			Aadd( aDados,{ "","" } )
		Next   
		if !aAuto[1]
			PLSCRIGEN(aDados,{ {"Campo","@C",90} , {"Conteúdo","@C",80 } },"Resumo da Comunicação")
		endIf
	Else
		cMsg   := "Não foi possível solicitar consultar o Status do Protocolo. Críticas:"+Chr(10)+Chr(10)
		For nX := 1 to len(aRetWeb[2])
			cMsg += Alltrim(aRetWeb[2][nX][1])+"-"+Alltrim(aRetWeb[2][nX][2])+Chr(10)
	  	Next   
	    if !aAuto[1]
			MsgInfo(cMsg)
		endIf
	EndIf	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLB4JRegTr

Registra uma transacao WebService RN395
@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------                                                                                              
Function PLB4JRegTr(cOpeSol,cOpeDes,cCodTra)
Local cCod    := ""   
Local cDesTra := ""
Default cOpeSol := PlsIntPad()
Default cOpeDes := ""
Default cCodTra := ""
Do Case
	Case cCodTra == "001"
		cDesTra := "solicitarProtocoloWS"
	
	Case cCodTra == "003
		cDesTra := "complementoProtocoloWS"
	
	Case cCodTra == "005"
		cDesTra := "respostaAtendimentoWS"
	
	Case cCodTra == "006"
		cDesTra := "consultaStatusProtocoloWS"	
	
	Case cCodTra == "008"
	   	cDesTra := "consultaHistoricoWS"	
	
	Case cCodTra == "010"
		cDesTra := "cancelamentoWS"
EndCase

cCod := StrZero( Val( B4J->(GetSx8Num("B4J","B4J_CODIGO") ) ),10)
                                                                  
B4J->(RecLock("B4J",.T.))
B4J->B4J_CODIGO := cCod
B4J->B4J_TIPTRA := cCodTra   
B4J->B4J_DESTRA := cDesTra   
B4J->B4J_OPESOL := cOpeSol         
B4J->B4J_OPEDES := cOpeDes
B4J->B4J_DATA   := dDataBase
B4J->B4J_HORA   := Substr(Time(),1,2)+Substr(Time(),4,2)
B4J->(MsUnLock())	  

B4J->(ConfirmSX8())

Return (cCod)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL773HISWS 

Rotina para consultar o historico de um protocolo
@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Static Function VldMatHis(oDlg,cMatric,cMatAnt,cNome)
Local lRet := .F.

BA1->(DbSetOrder(2))
If BA1->(DbSeek(xFilial("BA1")+cMatric))  
	If GetNewPar("MV_PLSGEIN","0050") == BA1->BA1_CODEMP
		cMatAnt := BA1->BA1_MATANT
		cNome   := BA1->BA1_NOMUSR
		lRet := .T.
		oDlg:Refresh()    
	Else
		Aviso("Consulta Histórico Protocolo","O Beneficiário selecionado não é de intercâmbio.",{"Ok"})
	EndIf	
Else
	Aviso("Consulta Histórico Protocolo","Beneficiário não encontrado",{"Ok"})
EndIf

Return lRet         


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSolProWB

Recebimento de uma solicitacao de protocolo atraves do WebService solicProtocRN395

@author  PLS TEAM
@version P11
@since   15.04.16       

Parametros:
cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo 
cNumRegAns --> Número de Registro da ANS da Unimed Destino
cNumTraPre --> ID da Manifestação (Número de Transação da Prestadora)
cDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cCodUniBen --> Código da Unimed
cIDBenef   --> Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
cNome      --> Nome do Beneficiário
cCPF       --> Código do CPF
cDDD       --> Número do DDD
cTelefone  --> Número do telefone
cEmail     --> Endereço de email
cTipManif  --> Tipo de Manifestação
cTipCateg  --> Categoria da Manifestação
cTipSent   --> Sentimento do Cliente
cIDResp    --> Indica o status da manifestação
cNrTrolOri --> NUMERO TRANSACAO INTERCAMBIO
cNumProAnt --> Protocolo de Atendimento Anterior
cMsgLivre  --> Mensagem livre da manifestação
/*/
//-------------------------------------------------------------------   
Function PLSolProWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,dDatGer,cIDUsuario,cMatric,cNome,cCPF,cDDD,cTelefone,;
					cEmail,cTipManif,cTipCateg,cTipSent,cIDResp,cNrTrolOri,cNumProAnt,cMsgLivre,aAuto) 

Local cIdUsuResp := GetNewPar( "MV_PLRESRN" , "" )
Local cNumProto  := P773GerPro()      
Local cHash      := ""   
Local cIdErro    := ""
Local cMsgErro   := ""
Local cAlias     := ""    
Local cMsgLivRes := ""    
Local cDataGer   := ""  
Local nX         := 0   
Local lChamTMK   := .F. 
Local lBenefOk   := .F.  
Local lFindBenef := .F.
Local aRet       := {}     
Local aThreads   := {}
Local lGPURest   := GetNewPar("MV_PGPURES","0") == "1"

Default cIdResp  := ""
Default cNumRegAns := ""
Default aAuto    := {.F.,""}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atraves do Tipo de Manifestacao e Categoria defino se e atendimento normal ou Call Center ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipManif  == "6" .And. cTipCateg  == "19"
	cAlias := "BEA"
Else
	lChamTMK  := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a matricula do beneficiario e valida                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(cMatric,1,4) == PlsIntPad() 
	BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	If BA1->(DbSeek(xFilial("BA1")+cMatric))  
		lFindBenef := .T.
	EndIf	
Else
	BA1->(DbSetOrder(5)) //BA1_FILIAL+BA1_MATANT+BA1_TIPANT
    If BA1->(DbSeek(xFilial("BA1")+cMatric)) .And.  BA1->BA1_OPEDES == Substr(cMatric,1,4)  
    	lFindBenef := .T.
	EndIf	
EndIf

If lFindBenef
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o beneficiario esta bloqueado                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(BA1->BA1_DATBLO) .Or. BA1->BA1_DATBLO <= dDatGer  
		lBenefOk := .T.
		
		If Empty(cIDResp)  		
			cIDResp := "1" 
		EndIf
		gerRegB00(cNumProto,nil,cAlias,.F.,lChamTMK,cMatric,.T.,cTipManif,cTipCateg,cTipSent,;
				   cIdResp,cCodUniOri,cNumTraPre,cMsgLivre,cIDUsuario,cNumProAnt,cNrTrolOri,NIL,PlsIntPad())      

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o numero de transacao de intercambio ja foi informado, ja altera o protocolo B00       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cNrTrolOri)		   
			PLAtProRNW(cNumProto,cNrTrolOri,cCodUniOri)		   
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se a Unimed responsavel e diferente da minha, devo realizar o encaminhamento              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If BA1->BA1_OPEDES <> PlsIntPad() .Or. aAuto[1]

			if aAuto[1]

				PLRENCATWB(cEmpAnt,cFilAnt,aThreads,BA1->BA1_OPEDES,cNumTraPre,dDataBase,Substr(cMatric,1,4),Substr(cMatric,5,13),;
					cNome,cCPF,cDDD,cTelefone,cEmail,cTipManif,cTipCateg,cTipSent,cNrTrolOri,B00->B00_COD,cNumProAnt,cMsgLivre,aAuto)  

			else
				StartJob("PLRENCATWB",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,BA1->BA1_OPEDES,cNumTraPre,dDataBase,Substr(cMatric,1,4),Substr(cMatric,5,13),;
					cNome,cCPF,cDDD,cTelefone,cEmail,cTipManif,cTipCateg,cTipSent,cNrTrolOri,B00->B00_COD,cNumProAnt,cMsgLivre)    
			
			endIf
			B00->(RecLock("B00",.F.)) 
			B00->B00_TRAENC  := "1"           
			B00->(MsUnLock())
		EndIf		
	Else
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica codigo e mensagem de erro                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		cIdErro := "3" //Indica beneficiario inativo
		cMsgErro  := "Erro: Codigo do beneficiario inativo."
	EndIf	
Else
	cIdErro   := "1" //Indica beneficiario inexistente  
	cMsgErro  := "Erro: Codigo do beneficiario inexistente."
Endif   

If Empty(cNumRegAns)					                 
	BA0->(DbSetOrder(1))
	BA0->(DbSeek(xFilial("BA0")+cCodUniDes))	
	cNumRegAns := Alltrim(BA0->BA0_SUSEP) 
EndIf	
cDataGer := Substr(Dtos(dDataBase),1,4)+"-"+Substr(Dtos(dDataBase),5,2)+"-"+Substr(Dtos(dDataBase),7,2)+IIf(lGPURest," ","T")+Time()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis de retorno e calcula Hash                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					   
aRet := {Iif(lBenefOk,"002","011"),;              //codigoTransacao
 		"UNIMED",;            //tipoCliente
 		cValToChar(Val(cCodUniOri)),;          //codigoUnimedOrigem
 		cValToChar(Val(cCodUniDes)),;          //codigoUnimedDestino
 		cNumRegAns}//numeroRegistroANS
 		
If lBenefOk
	Aadd(aRet,cNumTraPre)          //numeroTransacaoPrestadora
 	Aadd(aRet,cDataGer)            //dataGeracao
 	Aadd(aRet,cIdUsuResp)          //idUsuario
	Aadd(aRet,cValtoChar(Val(Substr(cMatric,1,4))) ) //identificacaoBeneficiario - codigoUnimed
 	Aadd(aRet,Substr(cMatric,5,13))//identificacaoBeneficiario - codigoIdentificacao 
	Aadd(aRet,cNumProto)            //numeroProtocolo
 	Aadd(aRet,IIf(Empty(cIdResp),"1",cIdResp)) //idResposta
 	Aadd(aRet,cMsgLivRes)           //mensagemLivre
 	Aadd(aRet,"1")                  //origemResposta         
 	Aadd(aRet,GetNewPar("MV_R395LAY","001")) //numeroVersaoProtocolo
Else
	Aadd(aRet,cNumTraPre)       //numeroTransacao
	Aadd(aRet,cIdErro)          //codigoErro  
	Aadd(aRet,cMsgErro)         //mensagemErro
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o valor do hash                                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
For nX := 1 to len(aRet)
	cHash := montaHash(cHash,aRet[nX])
Next 

cHash := Lower( MD5(cHash,2) )  

Return({aRet,cHash,cIdErro})




//-------------------------------------------------------------------
/*/{Protheus.doc} PLComProWB
Monta chamada do WebService complementoProtocoloWS - RN 395

@author  PLS TEAM
@version P11
@since   15.04.16       

Parametros:    

cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo 
cNumRegAns --> Número de Registro da ANS da Unimed Destino   
cNumTraPre --> Transacao de controle Unimed Origem
cDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cMatric    --> Matricula no beneficiario
cNumProtoc --> Numero do Protocolo gerado    
cNrTrolOri --> Numero da transacao de intercambio gerada
/*/
//------------------------------------------------------------------- 
Function PLComProWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraOpe,dDataGer,cIDUsuario,cMatric,cNumProtoc,cNrTrolOri)

Local cIdUsuResp := GetNewPar( "MV_PLRESRN" , "" )    
Local cHash      := ""  
Local cManifest  := "1"  
Local cIdErro    := ""
Local cMsgErro   := ""
Local cDataGer   := ""     
Local cMsg       := ""
Local nX         := 0
Local aRet       := {}  
Local aThreads	 := {}   
Local lAtuStatus := .F.
Local lBenefOk   := .F.
Local lGPURest   := GetNewPar("MV_PGPURES","0") == "1"

Default cIDUsuario := ""
Default cNrTrolOri := ""    

cNrTrolOri := Strzero(Val(cNrTrolOri),10)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a matricula do beneficiario e valida                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
If BA1->(DbSeek(xFilial("BA1")+cMatric)) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o beneficiario esta bloqueado                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(BA1->BA1_DATBLO) .Or. BA1->BA1_DATBLO <= dDatGer  
  		
  		lBenefOk := .T.
		B00->(DbSetOrder(1))	//B00_FILIAL + B00_COD
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura protocolo informado na tabela B00                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If B00->(DbSeek(xFilial("B00")+Alltrim(cNumProtoc) )) .And. !B00->B00_STAINT $ "3/4"   
			lAtuStatus := .T.
		EndIf
		
		If !PLAtProRNW(cNumProtoc,cNrTrolOri,cCodUniOri) 
			cManifest  := "2"
		EndIf	      
		
		If cManifest == "1" .And. B00->B00_STAINT == "3" 
			Do Case
				Case B00->B00_STATE == "1"
					cMsg := "Solicitação autorizada"
				Case B00->B00_STATE == "2"	
					cMsg := "Solicitação autorizada parcialmente."
				Case 	B00->B00_STATE == "3"	
					cMsg := "Solicitação negada."
			EndCase
		    
			If lAtuStatus
				GerRegB4I(B00->B00_COD,"3",cMsg,cIdUsuResp,dDataBase)
			EndIf	
			StartJob("PLRAUTRNWB",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,cIdUsuResp,B00->(Recno()),"3",cMsg)   
		
		EndIf 
	Else  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica codigo e mensagem de erro                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		cIdErro := "3" //Indica beneficiario inativo
		cMsgErro  := "Erro: Codigo do beneficiario inativo."
	EndIf	
Else
	cIdErro   := "1" //Indica beneficiario inexistente  
	cMsgErro  := "Erro: Codigo do beneficiario inexistente."
Endif   
	                 
BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BA0")+cCodUniDes))	  

cDataGer := Substr(Dtos(dDataBase),1,4)+"-"+Substr(Dtos(dDataBase),5,2)+"-"+Substr(Dtos(dDataBase),7,2)+IIf(lGPURest," ","T")+Time()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis de retorno e calcula Hash                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					   
aRet := {Iif(lBenefOk,"004","011"),;              //codigoTransacao
 		"UNIMED",;            //tipoCliente
 		cValtoChar(Val(cCodUniOri)),;          //codigoUnimedOrigemMensagem
 		cValtoChar(Val(cCodUniDes)),;          //codigoUnimedDestinoMensagem
 		Alltrim(BA0->BA0_SUSEP)}//numeroRegistroANS 

If lBenefOk
	Aadd(aRet,cNumTraOpe)           //numeroTransacaoPrestadora
 	Aadd(aRet,cDataGer)             //dataGeracao
 	Aadd(aRet,cIdUsuResp)           //idUsuario
 	Aadd(aRet,cValToChar(Val(Substr(cMatric,1,4))))  //identificacaoBeneficirio - codigoUnimed
 	Aadd(aRet,Substr(cMatric,5,13)) //identificacaoBeneficirio - codigoIdentificacao   
 	Aadd(aRet,cManifest)             //tipoIdentificador
 	Aadd(aRet,"1")                   //origemResposta
 	Aadd(aRet,GetNewPar("MV_R395LAY","001"))//numeroVersaoProtocolo
Else
	Aadd(aRet,cNumTraOpe)       //numeroTransacao
	Aadd(aRet,cIdErro)          //codigoErro  
	Aadd(aRet,cMsgErro)         //mensagemErro
EndIf 		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula Hash                                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
For nX := 1 to len(aRet)
	cHash := montaHash(cHash,aRet[nX])
Next 

cHash := Lower( MD5(cHash,2) )

Return({aRet,cHash,cIdErro})     



//-------------------------------------------------------------------
/*/{Protheus.doc} PLConStaWB
Monta chamada do WebService ConsultaStatusProtocoloWS - RN 395

@author  PLS TEAM
@version P11
@since   15.04.16       

Parametros:    

cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo 
cNumRegAns --> Número de Registro da ANS da Unimed Destino   
cNumTraOpe --> Transacao de controle Unimed Origem
cDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cCodUniBen --> Código da Unimed
cIDBenef   --> Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
cNumProtoc --> Numero do Protocolo gerado    
cNrTrol    --> Numero da transacao de intercambio gerada
	
/*/
//-------------------------------------------------------------------   
Function PLConStaWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraOpe,dDataGer,cIDUsuario,cMatric,cNumProtoc)     

Local cIdUsuResp := GetNewPar( "MV_PLRESRN" , "" )   
Local cIdResp    := ""  
Local cNrTrol    := ""
Local cNumTraPre := ""
Local cChaveBQV  := ""
Local cHash      := ""  
Local cNomeBenef := ""
Local cTpManif   := ""
Local cTpCateg   := ""
Local cTpSentim  := ""
Local cDataGer   := "" 
Local cIdErro    := ""
Local cMsgErro   := ""
Local nX         := 0
Local nY         := 0
Local nZ         := 0
Local aRet       := {}     
Local aIdeMsgPed := {}
Local aIdeMsgRes := {} 
Local lBenefOk   := .F.
Local lFindBenef := .F.
Local cDataSol   := ""
Local cHrSol	 := ""
Local lGPURest   := GetNewPar("MV_PGPURES","0") == "1"

Default cIDUsuario := ""           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a matricula do beneficiario e valida                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(cMatric,1,4) == PlsIntPad() 
	BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	If BA1->(DbSeek(xFilial("BA1")+cMatric))  
		lFindBenef := .T.
	EndIf	
Else
	BA1->(DbSetOrder(5)) //BA1_FILIAL+BA1_MATANT+BA1_TIPANT
    If BA1->(DbSeek(xFilial("BA1")+cMatric))
    	lFindBenef := .T.
	EndIf	
EndIf

If lFindBenef
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o beneficiario esta bloqueado                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(BA1->BA1_DATBLO) .Or. BA1->BA1_DATBLO <= dDatGer  
		B00->(DbSetOrder(1))//B00_FILIAL+B00_COD
		If B00->(DbSeek(xFilial("B00")+cNumProtoc))
		    lBenefOk := .T.
			cNomeBenef  :=  Alltrim(BA1->BA1_NOMUSR)
			cDataSol    := Substr(Dtos(B00->B00_DTPROT),1,4)+"-"+Substr(Dtos(B00->B00_DTPROT),5,2)+"-"+Substr(Dtos(B00->B00_DTPROT),7,2)+IIf(lGPURest," ","T")+Substr(B00->B00_HRPROT,1,2)+":"+Substr(B00->B00_HRPROT,3,2)+":00"
			cIdResp     := B00->B00_STAINT  
			cNumTraPre  := B00->B00_TRAPRE      
			cTpManif    := B00->B00_MANIF
		    cTpCateg    := B00->B00_CATEG
		    cTpSentim   := B00->B00_SENTIM
			cNrTrol     := B00->B00_NRTROL
			cHrSol		:= B00->B00_HRPROT

		    Aadd(aIdeMsgPed,{Alltrim(B00->B00_USUSOL),;
		                     Substr(Dtos(B00->B00_DTPROT),1,4)+"-"+Substr(Dtos(B00->B00_DTPROT),5,2)+"-"+Substr(Dtos(B00->B00_DTPROT),7,2)+IIf(lGPURest," ","T")+Substr(B00->B00_HRPROT,1,2) + ":" + Substr(B00->B00_HRPROT,3,2) + ":00",;
		                     Substr(Dtos(B00->B00_DTPROT),1,4)+"-"+Substr(Dtos(B00->B00_DTPROT),5,2)+"-"+Substr(Dtos(B00->B00_DTPROT),7,2)+IIf(lGPURest," ","T")+Time(),;
		                     Alltrim(B00->B00_MSGINT)})
							  
		                  
			B4I->(DbSetOrder(1))//B4I_FILIAL+B4I_PROTOC+B4I_SEQUEN
			If B4I->(DbSeek(xFilial("B4I")+B00->B00_COD)) 
				While B4I->B4I_PROTOC == B00->B00_COD  .And. !B4I->(Eof())
					Aadd(aIdeMsgRes,{IiF(!Empty(B4I->B4I_USUMAN),Alltrim(B4I->B4I_USUMAN),cIdUsuResp),;
									 Substr(Dtos(B4I->B4I_DATRES),1,4)+"-"+Substr(Dtos(B4I->B4I_DATRES),5,2)+"-"+Substr(Dtos(B4I->B4I_DATRES),7,2)+IIf(lGPURest," ","T")+Time(),;
									 Substr(Dtos(B4I->B4I_DATRES),1,4)+"-"+Substr(Dtos(B4I->B4I_DATRES),5,2)+"-"+Substr(Dtos(B4I->B4I_DATRES),7,2)+IIf(lGPURest," ","T")+Time(),;
									 Alltrim(B4I->B4I_MENSAG),Substr(B4I->B4I_HORRES,1,2) + ":" + Substr(B4I->B4I_HORRES,3,2) + ":00" }) 
					B4I->(DbSkip())
			    EndDo  
			    
			EndIf
		Else
			cIdErro := "4" //Indica beneficiario inativo
	  		cMsgErro  := "Erro: Protocolo informado nao existe."
		EndIf             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica codigo e mensagem de erro                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Else		
		cIdErro := "3" //Indica beneficiario inativo
		cMsgErro  := "Erro: Codigo do beneficiario inativo."
	EndIf	
Else
	cIdErro   := "1" //Indica beneficiario inexistente  
	cMsgErro  := "Erro: Codigo do beneficiario inexistente."
Endif    

BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BA0")+cCodUniDes))   

cDataGer := Substr(Dtos(dDataBase),1,4)+"-"+Substr(Dtos(dDataBase),5,2)+"-"+Substr(Dtos(dDataBase),7,2)+IIf(lGPURest," ","T")+Time()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis de retorno e calcula Hash                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					   
aRet := {Iif(lBenefOk,"007","011"),; //codigoTransacao
 		"UNIMED",;               //tipoCliente
 		cValToChar(Val(cCodUniOri)),;             //codigoUnimedOrigemMensagem
 		cValToChar(Val(cCodUniDes)),;             //codigoUnimedDestinoMensagem
 		Alltrim(BA0->BA0_SUSEP)} //numeroRegistroANS       

If lBenefOk
	Aadd(aRet,cDataSol)             //dataSolicitacaoProtocolo
	Aadd(aRet,cNumTraOpe)           //numeroTransacaoPrestadora
	Aadd(aRet,cDataGer)             //dataGeracao
	Aadd(aRet,cNumProtoc)           //numeroProtocolo  
	Aadd(aRet,cTpManif)			    //identificacaoManifestacao - tipoManifestacao
	Aadd(aRet,cTpCateg)             //identificacaoManifestacao - tipoCategoria
	Aadd(aRet,cTpSentim)        	//identificacaoManifestacao - tipoSentimento  
	Aadd(aRet,cNomeBenef)           //nomeBeneficiario
	Aadd(aRet,cValToChar(Val(Substr(cMatric,1,4))) )  //identificacaoBeneficiario - codigoUnimed
	Aadd(aRet,Substr(cMatric,5,13)) //identificacaoBeneficiario - codigoIdentificacao
	Aadd(aRet,cValToChar(Val(cNumTraPre)))           //numeroTransacaoIntercambioPrestadora
	Aadd(aRet,IIf(Empty(cNrTrol),"0",cValToChar(Val(Alltrim(cNrTrol)))))//numeroTransacaoOrigemBeneficiario
	Aadd(aRet,cIdResp)              //idResposta
	Aadd(aRet,GetNewPar("MV_R395LAY","001"))//numeroVersaoProtocolo
	Aadd(aRet,aIdeMsgPed)           //Array com a tag identificacaoMensagemPedidoManifestacao
	Aadd(aRet,aIdeMsgRes)	       	//Array com a tag identificacaoMensagemRespostaManifestacao
	Aadd(aRet,"1")				   	//origemResposta
	
Else
	Aadd(aRet,cNumTraOpe)       //numeroTransacao
	Aadd(aRet,cIdErro)          //codigoErro  
	Aadd(aRet,cMsgErro)         //mensagemErro
EndIf 		 		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula Hash                                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
For nX := 1 to len(aRet)
	if ValType(aRet[nX]) == "A"
		for nY := 1 to len(aRet[nX])
			for nZ := 1 to len(aRet[nX,nY])
				cHash := montaHash(cHash,aRet[nX,nY,nZ])
			next
		next
	else 
		cHash := montaHash(cHash,aRet[nX])
	endIf		
Next 
cHash := Lower( MD5(cHash,2) )

Return({aRet,cHash,cIdErro})     



//-------------------------------------------------------------------
/*/{Protheus.doc} PLCanAteWB
Monta chamada do WebService cancelamentoWB - RN 395

@author  PLS TEAM
@version P11
@since   15.04.16       

Parametros:    

cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo 
cNumRegAns --> Número de Registro da ANS da Unimed Destino   
cNumTraPre --> Transacao de controle Unimed Origem
dDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cCodUniBen --> Código da Unimed
cIDBenef   --> Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
cNumProto  --> Numero do Protocolo gerado    
cMotivo    --> Motivo do Cancelamento 
cTime      --> Horario da geração da manifestação

/*/
//-------------------------------------------------------------------   
Function PLCanAteWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraOpe,dDatGer,cIDUsuario,cMatric,cNumProto,cMotivo,cTime)    
	Local cIdUsuResp := GetNewPar( "MV_PLRESRN" , "" )
	Local cManifest  := "1"
	Local cHash      := ""    
	Local cIdErro    := ""
	Local cMsgErro   := ""
	Local cDataGer   := ""
	Local nX         := 0
	Local aRet       := {}     
	Local lFindProt  := .F.
	Local lBenefOk   := .F.
	Local lFindBenef := .F.
	Local lGPURest := GetNewPar("MV_PGPURES","0") == "1"

	Default cIDUsuario := ""
	Default cNumProto  := ""    
	Default cMotivo    := ""  
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a matricula do beneficiario e valida                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Substr(cMatric,1,4) == PlsIntPad() 
		BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		If BA1->(DbSeek(xFilial("BA1")+cMatric))  
			lFindBenef := .T.
		EndIf	
	Else
		BA1->(DbSetOrder(5)) //BA1_FILIAL+BA1_MATANT+BA1_TIPANT
		If BA1->(DbSeek(xFilial("BA1")+cMatric))
			lFindBenef := .T.
		EndIf	
	EndIf

	If lFindBenef
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o beneficiario esta bloqueado                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(BA1->BA1_DATBLO) .Or. BA1->BA1_DATBLO <= dDatGer 
			lBenefOk := .T. 
			B00->(DbSetOrder(1))
			If B00->(DbSeek(xFilial("B00")+cNumProto))  
				While B00->B00_COD == cNumProto .And. !B00->(Eof())
					If B00->B00_OPESOL == cCodUniOri
						lFindProt := .T.
						Exit
					EndIf
					B00->(DbSkip())
				EndDo
			EndIf
			
			If lFindProt
				If B00->B00_CANCEL <> "1"
					lRetB4I := GerRegB4I(cNumProto,"4",cMotivo,cIDUsuario,dDatGer,cTime)
					If lRetB4I
						B00->(RecLock("B00",.F.)) 
						B00->B00_STAINT  := "4"
						B00->B00_CANCEL  := "1"           
						B00->(MsUnLock())
						If lGPURest
							cManifest := "4"
						EndIf
					EndIf           
				EndIf	
			Else
				cManifest  := "2"
			EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Indica codigo e mensagem de erro                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		Else		
			cIdErro  := "3" //Indica beneficiario inativo
			cMsgErro := "Erro: Codigo do beneficiario inativo."
		EndIf	
	Else
		cIdErro   := "1" //Indica beneficiario inexistente  
		cMsgErro  := "Erro: Codigo do beneficiario inexistente."
	Endif    		
						
	BA0->(DbSetOrder(1))
	BA0->(DbSeek(xFilial("BA0")+cCodUniDes))		  

	cDataGer := Substr(Dtos(dDataBase),1,4)+"-"+Substr(Dtos(dDataBase),5,2)+"-"+Substr(Dtos(dDataBase),7,2)+IIf(lGPURest," ","T")+Time()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define variaveis de retorno e calcula Hash                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					   
	aRet := {Iif(lBenefOk,"004","011"),; //CODIGOTRANSACAO
			"UNIMED",;            //TIPOCLIENTE
			cValToChar(Val(cCodUniOri)),;          //CODIGO UNIMED ORIGEM
			cValToChar(Val(cCodUniDes)),;          //CODIGO UNIMED DESTINO     
			Alltrim(BA0->BA0_SUSEP)}//NUMERO REGISTRO ANS

	If lBenefOk 		
		Aadd(aRet,cNumTraOpe)          //NUMEROTRANSACAOPRESTADORA
		Aadd(aRet,cDataGer)           //DATA GERACAO 
		Aadd(aRet,cIdUsuResp)          //ID USUARIO
		Aadd(aRet,cValToChar(Val(Substr(cMatric,1,4)))) //CODIGO UNIMED
		Aadd(aRet,Substr(cMatric,5,13))//IDENTIFICACAO BENEFICIARIO    
		Aadd(aRet,cManifest)            //TIPO IDENTIFICADOR 
		Aadd(aRet,"1")                 //ORIGEM RESPOSTA   
		Aadd(aRet,GetNewPar("MV_R395LAY","001"))//NUMERO VERSAO PROTOCOLO
	Else
		Aadd(aRet,cNumTraOpe)       //numeroTransacao
		Aadd(aRet,cIdErro)          //codigoErro  
		Aadd(aRet,cMsgErro)         //mensagemErro
	EndIf 		 		 		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula Hash                                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	For nX := 1 to len(aRet)
		cHash := montaHash(cHash,aRet[nX])
	Next 
	cHash := Lower( MD5(cHash,2) )

Return({aRet,cHash,cIdErro})     



//-------------------------------------------------------------------
/*/{Protheus.doc} montaHash

Monta Hash
@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------                                                                                              
Static Function montaHash(cHash,xConteudo)
Local nX := 0
Local nY := 0
   
If ValType(xConteudo) == "D"
	cHash += Substr(Dtos(xConteudo),1,4)+"-"+Substr(Dtos(xConteudo),5,2)+"-"+Substr(Dtos(xConteudo),7,2)

ElseIf ValType(xConteudo) == "A"
	If len(xConteudo) > 0 .And. ValType(xConteudo[1]) == "A"
		For nX := 1 to len(xConteudo)   
			For nY := 1 to len(xConteudo[nX])
				If ValType(xConteudo[nX][nY]) == "D"
					cHash += Substr(Dtos(xConteudo[nX][nY]),1,4)+"-"+Substr(Dtos(xConteudo[nX][nY]),5,2)+"-"+Substr(Dtos(xConteudo[nX][nY]),7,2)
			    Else
					cHash += xConteudo[nX][nY] 
				EndIf	 
			Next	
		Next
    Else
    	For nX := 1 to len(xConteudo) 
			If ValType(xConteudo[nX]) == "D"
				cHash += Substr(Dtos(xConteudo[nX]),1,4)+"-"+Substr(Dtos(xConteudo[nX]),5,2)+"-"+Substr(Dtos(xConteudo[nX]),7,2)
		    Else
				cHash += xConteudo[nX] 
			EndIf	
   		Next
    EndIf    

ElseIf ValType(xConteudo) <> "U"
	cHash += xConteudo
EndIf	 

Return(cHash)   
 


//-------------------------------------------------------------------
/*/{Protheus.doc} AtuProtRNW

Atualiza protocolo e guias ao receber uma transacao do WebService RN 395
@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------                                                                                              
Function PLAtProRNW(cNumProtoc,cNrTrolOri,cCodUniOri,lPTUOnCall) 
Local lRet := .T.
Local nQtdAut := 0
Local nQtdNeg := 0
Local cStatus := ""      
Local cNumGui := ""
Default lPTUOnCall := .F.
				 		   
BEA->(DbSetOrder(22))	//BEA_FILIAL + BEA_NRTROL   
B00->(DbSetOrder(1))	//B00_FILIAL + B00_COD
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procura protocolo informado na tabela B00                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If B00->(DbSeek(xFilial("B00")+Alltrim(cNumProtoc) ))   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura guia com o NRTROL informado                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If BEA->(DbSeek(xFilial("BEA")+Alltrim(cNrTrolOri)+Space(TamSx3("BEA_NRTROL")[1]-len(Alltrim(cNrTrolOri)))+cCodUniOri)) .And. (Empty(BEA->BEA_PROATE) .Or. (lPTUOnCall .And. BEA->BEA_PROATE == cNumProtoc) )
		If !lPTUOnCall
			BEA->(RecLock("BEA",.F.))
			BEA->BEA_PROATE  := cNumProtoc
			BEA->(MsUnLock())	  
		EndIf
		
	    If BEA->BEA_AUDITO == "1"
    		cStatus := "4"  //4=Pendente Auditoria
        ElseIf BEA->BEA_STATUS $ "1/4/5"
 	   		cStatus := "1" //1=Autorizada 	
    	ElseIf BEA->BEA_STATUS == "2"
    		cStatus := "2" //2=Autorizada Parcialmente
	    ElseIf BEA->BEA_STATUS == "3" 
	    	cStatus := "3" //3=Nao Autorizada	 
	    EndIf
		
		If BEA->BEA_TIPGUI == "03" .And. !lPTUOnCall
			BE4->(DbSetOrder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
			If BE4->(DbSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT))) .And. Empty(BE4->BE4_PROATE) 
				BE4->(RecLock("BE4",.F.))
	 			BE4->BE4_PROATE  := cNumProtoc
	   			BE4->(MsUnLock())	  
			EndIf
		EndIf
		cNumGui := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
		dDatAte := BEA->BEA_DATPRO  
		cHorAte := BEA->BEA_HORPRO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura guia com o NRTROL informado na Evolucao BQV                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		BQV->(DbSetOrder(5))//BQV_FILIAL+BQV_NRTROL     
		If BQV->(DbSeek(xFilial("BQV")+Alltrim(cNrTrolOri)))
		    BEA->(DbSetOrder(1))//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BEA_DATPRO+BEA_HORPRO
			While BQV->(BQV_FILIAL+BQV_NRTROL) == xFilial("BQV")+cNrTrolOri+Space(TamSx3("BQV_NRTROL")[1]-len(Alltrim(cNrTrolOri))) .And. !BQV->(Eof())
				If BEA->(DbSeek(xFilial("BEA")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT))) .And. BEA->BEA_OPESOL == cCodUniOri
	            	If !lPTUOnCall
		            	BQV->(RecLock("BQV",.F.))
		 		 		BQV->BQV_PROATE  := cNumProtoc
		   		  		BQV->(MsUnLock())	  
	   		  		EndIf
	   		  		
	   		  		cNumGui := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
					dDatAte := BEA->BEA_DATPRO  
					cHorAte := BEA->BEA_HORPRO  
					
					If BQV->BQV_STATUS == "1"
						nQtdAut ++
					ElseIf BQV->BQV_STATUS == "0" 
				 		nQtdNeg ++
				 	EndIf	  
				 	If BQV->BQV_AUDITO == "1"
						cStatus := "4" //4=Pendente Auditoria
					EndIf   
				EndIf            
				
				BQV->(DbSkip())
			EndDo
			If cStatus <> "4"
				If nQtdAut > 0 .And. nQtdNeg > 0
					cStatus := "2" //2=Autorizada Parcialmente
				ElseIf nQtdAut > 0 .And. nQtdNeg == 0	
					cStatus := "1" //1=Autorizada
				ElseIf nQtdAut == 0 .And. nQtdNeg > 0	
			  		cStatus := "3" //3=Nao Autorizada
				EndIf	
			EndIf
		EndIf
	EndIf   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se achou guia com o protocolo nao preenchido atualiza                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If !Empty(cNumGui)
		B00->(RecLock("B00",.F.))
		B00->B00_NUMGUI  := cNumGui   
		B00->B00_STATE   := cStatus    
		B00->B00_DTATEN  := BEA->BEA_DATPRO
		B00->B00_HRATEN  := BEA->BEA_HORPRO    
		B00->B00_NRTROL  := cNrTrolOri  
		B00->B00_ALIGUI  := 'BEA'  
		If cStatus <> "4" .And. B00->B00_STAINT <> "4"
			B00->B00_STAINT := "3"	      
			B00->B00_DATRES := dDataBase
			B00->B00_HORRES := StrTran(Time(),":","") 
		EndIf 
		B00->(MsUnLock())	
	EndIf	
Else
	lRet := .F.
EndIf      

Return lRet      
                     
                 
        
//-------------------------------------------------------------------
/*/{Protheus.doc} PLConHisWB
Monta chamada do WebService ConsultaStatusProtocolo - RN 395

@author  PLS TEAM
@version P11
@since   15.04.16       

Parametros:    

cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo 
cNumRegAns --> Número de Registro da ANS da Unimed Destino   
cNumTraPre --> Transacao de controle Unimed Origem
dDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cMatric    --> Código da Matricula
cNumProto  --> Numero do Protocolo gerado    
cNrTrol    --> Numero da transacao de intercambio gerada
/*/
//-------------------------------------------------------------------   
Function PLConHisWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,dDatGer,cIDUsuario,cMatric,cNumProto,dDatSol,dDatResp) 
	Local cIdUsuResp := GetNewPar( "MV_PLRESRN" , "" ) 
	Local cHash      := ""     
	Local cIdErro    := ""
	Local cMsgErro   := "" 
	Local cSql       := "" 
	Local cHrResp	 := ""
	Local cHrSol	 := "" 
	Local lBenefOk   := .F.
	Local aRet       := {}     
	Local aResp      := {}
	Local nX         := 0
	Local nY         := 0
	Local nZ         := 0
	Local cNumTraOpe := ""
	Local lGPURest := GetNewPar("MV_PGPURES","0") == "1"

	Default cIDUsuario := ""       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a matricula do beneficiario e valida                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	If BA1->(DbSeek(xFilial("BA1")+cMatric)) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o beneficiario esta bloqueado                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(BA1->BA1_DATBLO) .Or. BA1->BA1_DATBLO <= dDatGer     
			
			cSql := " SELECT * FROM "+RetSqlName("B00")+" WHERE B00_FILIAL = '"+xFilial("B00")+"'" 
			
			If !Empty(cNumProto)
				cSql += " AND B00_COD = '"+cNumProto+"' " 
			EndIf 
			
			cSql += " AND B00_MATRIC = '"+cMatric+"' "
			cSql += " AND B00_OPESOL = '"+cCodUniOri+"' "  
			If !Empty(dDatSol) 
				cSql += " AND B00_DTPROT >= '"+SubStr(dDatSol,1,8)+"' " 
			EndIf 
			
			If !Empty(dDatResp)
				cSql += " AND B00_DATRES <= '"+SubStr(dDatResp,1,8)+"' "
			EndIf     
			cSql += " AND B00_STAINT <> ' ' " 
			cSql += " AND D_E_L_E_T_ = ' ' " 
						
			DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,cSql) , "TMP" , .F. , .T. )

			If TMP->(!Eof())
				lBenefOk := .T.
				While TMP->(!Eof())    
					Aadd(aResp,{cNumTraPre,;          //numeroTransacaoPrestadora
								Substr(TMP->B00_DTPROT,1,4)+"-"+Substr(TMP->B00_DTPROT,5,2)+"-"+Substr(TMP->B00_DTPROT,7,2)+IIf(lGPURest," ","T")+Time(),;   //dataGeracao
								cIdUsuResp,;          //idUsuario
								TMP->B00_COD,;        //numeroProtocolo
								TMP->B00_MANIF,;      //identificacaoManifestacao - tipoManifestacao
								TMP->B00_CATEG,;      //identificacaoManifestacao - tipoCategoria
								TMP->B00_SENTIM,;     //identificacaoManifestacao - tipoSentimento
								Alltrim(TMP->B00_NOMUSR),;     //nomeBenef
								cValToChar(Val(TMP->B00_TRAPRE)),;     //numeroTransacaoIntercambioPrestadora
								IIF(!Empty(TMP->B00_NRTROL),cValToChar(Val(TMP->B00_NRTROL)),"0"),;//numeroTransacaoOrigemBeneficiario       
								cValToChar(Val(Substr(cMatric,1,4))),; //identificacaoBeneficiario - codigoUnimed
								Substr(cMatric,5,13),;//identificacaoBeneficiario - codigoIdentificacao
								TMP->B00_STAINT})     //idResposta
					TMP->(DbSkip())
				EndDo 
			Else
				cIdErro := "4" 
				cMsgErro := "Erro: Protocolo informado não existe."
			EndIf
			TMP->(DbCloseArea()) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Indica codigo e mensagem de erro                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		Else		
			cIdErro := "3" //Indica beneficiario inativo
			cMsgErro  := "Erro: Codigo do beneficiario inativo."
		EndIf	
	Else
		cIdErro   := "1" //Indica beneficiario inexistente  
		cMsgErro  := "Erro: Codigo do beneficiario inexistente."
	Endif    		   

	BA0->(DbSetOrder(1))
	BA0->(DbSeek(xFilial("BA0")+cCodUniDes))  

	cDataGer := Substr(dTos(dDataBase),1,4)+"-"+Substr(dTos(dDataBase),5,2)+"-"+Substr(dTos(dDataBase),7,2)
	If !Empty(dDatSol)
		cHrSol	 := Substr(dDatSol,10,8)
		dDatSol  := Substr(dDatSol,1,4)+"-"+Substr(dDatSol,5,2)+"-"+Substr(dDatSol,7,2)+IIf(lGPURest," ","T")+cHrSol
		
	EndIf
	If !Empty(dDatResp)	
		cHrResp	 := Substr(dDatResp,10,8)
		dDatResp := Substr(dDatResp,1,4)+"-"+Substr(dDatResp,5,2)+"-"+Substr(dDatResp,7,2)+IIf(lGPURest," ","T")+cHrResp
		
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define variaveis de retorno e calcula Hash                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					   
	aRet := {Iif(lBenefOk,"008","011"),; //codigoTransacao
			"UNIMED",;              //tipoCliente
			cValToChar(Val(cCodUniOri)),;            //codigoUnimedOrigemMensagem
			cValToChar(Val(cCodUniDes)),;            //codigoUnimedDestinoMensagem  
			Alltrim(BA0->BA0_SUSEP)}//numeroRegistroANS  
			
	If lBenefOk
		Aadd(aRet,dDatSol)   //dataInicioPeriodo
		Aadd(aRet,dDatResp)  //dataFimPeriodo
		Aadd(aRet,aResp)     //Array com a tag respostaConsultaHistorico
		Aadd(aRet,"1")		 //origemResposta
	Else
		Aadd(aRet,cNumTraOpe)       //numeroTransacao
		Aadd(aRet,cIdErro)          //codigoErro  
		Aadd(aRet,cMsgErro)         //mensagemErro
	EndIf  		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula Hash                                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	For nX := 1 to len(aRet)
		if ValType(aRet[nX]) == "A"
			for nY := 1 to len(aRet[nX])
				for nZ := 1 to len(aRet[nX,nY])
					cHash := montaHash(cHash,aRet[nX,nY,nZ])
				next
			next
		else
			cHash := montaHash(cHash,aRet[nX])
		endIf		
	Next 
	cHash := Lower( MD5(cHash,2) )

Return({aRet,cHash,cIdErro})  
                


//-------------------------------------------------------------------
/*/{Protheus.doc} PLResAteWB
Monta chamada do WebService responder Atendimento - RN 395

@author  PLS TEAM
@version P11
@since   15.04.16       

Parametros:    

cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo 
cNumRegAns --> Número de Registro da ANS da Unimed Destino   
cNumTraPre --> Transacao de controle Unimed Origem
dDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cCodUniBen --> Código da Unimed
cIDBenef   --> Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
cNumProto  --> Numero do Protocolo gerado    
cIdResposta --> Id de Resposta 
cNrTrol     --> Numero da transacao de intercambio
cMsgLivre   --> Mensagem Livre
/*/
//-------------------------------------------------------------------   
Function PLResAteWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraOpe,dDatGer,cIDUsuario,cMatric,cNumProto,cIdResposta,cNrTrol,aMsg,cTime)

Local cIdUsuResp   := GetNewPar( "MV_PLRESRN" , "" )   
Local cManifest    := "1" 
Local cHash        := ""  
Local cIdErro      := ""
Local cMsgErro     := ""
Local nX           := 0
Local lRetB4I      := .F.
Local lFindProt    := .F.
Local lBenefOk     := .F.
Local lFindBenef   := .F.     
Local lFindB4I     := .F.
Local aRet         := {}     
Local aThreads     := {}
Local lGPURest     := GetNewPar("MV_PGPURES","0") == "1"

Default cIDUsuario := ""           
Default aMsg       := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a matricula do beneficiario e valida                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(cMatric,1,4) == PlsIntPad() 
	BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	If BA1->(DbSeek(xFilial("BA1")+cMatric))  
		lFindBenef := .T.
	EndIf	
Else
	BA1->(DbSetOrder(5)) //BA1_FILIAL+BA1_MATANT+BA1_TIPANT
    If BA1->(DbSeek(xFilial("BA1")+cMatric)) // .And.  BA1->BA1_OPEDES == Substr(cMatric,1,4)  
    	lFindBenef := .T.
	EndIf	
EndIf

If lFindBenef
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o beneficiario esta bloqueado                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(BA1->BA1_DATBLO) .Or. BA1->BA1_DATBLO <= dDatGer  

		lBenefOk := .T.
		B00->(DbSetOrder(1))
		If B00->(DbSeek(xFilial("B00")+cNumProto))  
			While B00->B00_COD == cNumProto .And. !B00->(Eof())
				If B00->B00_OPESOL == PlsIntPad() .And. Empty(B00->B00_TRAENC) //Minha operadora e solicitante
					lFindProt := .T.
					Exit
				EndIf   
				If B00->B00_TRAENC == "1" //Operadora origem no processo de encaminhamento
					lFindProt := .T.
					Exit
				EndIf   
				
				B00->(DbSkip())
			EndDo
		EndIf
		
		If lFindProt  
			B00->(DbSeek(xFilial("B00")+cNumProto)) 
		    If B00->B00_CANCEL <> "1" .And. !B00->B00_STAINT $ "3/4"
		    	
		    	B4I->(DbSetOrder(1))//B4I_FILIAL+B4I_PROTOC+B4I_SEQUEN		    	
		    	For nX := 1 to len(aMsg) 
		    		lFindB4I := .F.
		    		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se ja foi registrada a mensagem na tabela B4I                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    		If B4I->(DbSeek(xFilial("B4I")+cNumProto))   
		    			While B4I->B4I_PROTOC == cNumProto .And. !B4I->(Eof())
		    				If Alltrim(B4I->B4I_MENSAG) == Alltrim(aMsg[nX]) 
		    					lFindB4I := .T.
		    				EndIf
		    				B4I->(DbSkip())	
		    			EndDo
		    		EndIf      
		    		 
		    		If !lFindB4I
						lRetB4I := GerRegB4I(cNumProto,cIdResposta,aMsg[nX],cIDUsuario,dDatGer,cTime)  
					EndIf	
				Next      
				
				If lRetB4I .Or. cIdResposta == "3"		
					B00->(RecLock("B00",.F.)) 
					B00->B00_STAINT  := cIdResposta
			   		B00->(MsUnLock())
				EndIf  
			EndIf	   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Como Operadora Origem, preciso encaminhar a transacao para a Solicitante                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If B00->B00_TRAENC == "1" 
				StartJob("PLRENCREWB",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,B00->B00_OPESOL,cNumTraOpe,;
				                      dDatGer,cIDUsuario,Substr(cMatric,1,4),Substr(cMatric,5,13),B00->B00_COD,cIdResposta,cNrTrol,cMsgLivre) 
			EndIf

		Else
			cManifest  := "2"
		EndIf	 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica codigo e mensagem de erro                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		cIdErro := "3" //Indica beneficiario inativo
		cMsgErro  := "Erro: Codigo do beneficiario inativo."
	EndIf	
Else
	cIdErro   := "1" //Indica beneficiario inexistente  
	cMsgErro  := "Erro: Codigo do beneficiario inexistente."
Endif   
	                 
BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BA0")+cCodUniDes))  

cDataGer := Substr(Dtos(dDataBase),1,4)+"-"+Substr(Dtos(dDataBase),5,2)+"-"+Substr(Dtos(dDataBase),7,2)+IIf(lGPURest," ","T")+Time()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis de retorno e calcula Hash                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					   
aRet := {Iif(lBenefOk,"004","011"),; //codigoTransacao
 		"UNIMED",;            //tipoCliente
 		cValToChar(Val(cCodUniOri)),;          //codigoUnimedOrigemMensagem
 		cValToChar(Val(cCodUniDes)),;          //codigoUnimedDestinoMensagem
 		Alltrim(BA0->BA0_SUSEP)}//numeroRegistroANS 
 		
If lBenefOk
	Aadd(aRet,cNumTraOpe)           //numeroTransacaoPrestadora
 	Aadd(aRet,cDataGer)             //dataGeracao
 	Aadd(aRet,cIdUsuResp)           //idUsuario
 	Aadd(aRet,cValToChar(Val(Substr(cMatric,1,4))) )  //identificacaoBeneficirio - codigoUnimed
 	Aadd(aRet,Substr(cMatric,5,13)) //identificacaoBeneficirio - codigoIdentificacao   
 	Aadd(aRet,cManifest)             //tipoIdentificador
 	Aadd(aRet,"1")                   //origemResposta
 	Aadd(aRet,GetNewPar("MV_R395LAY","001"))//numeroVersaoProtocolo
Else
	Aadd(aRet,cNumTraOpe)       //numeroTransacao
	Aadd(aRet,cIdErro)          //codigoErro  
	Aadd(aRet,cMsgErro)         //mensagemErro
EndIf  		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula Hash                                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
For nX := 1 to len(aRet)
	cHash := montaHash(cHash,aRet[nX])
Next 
cHash := Lower( MD5(cHash,2) )

Return({aRet,cHash,cIdErro})    
                           


//-------------------------------------------------------------------
/*/{Protheus.doc} GerRegB4I

Gera registro na tabela B4I
@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------     
Static Function GerRegB4I(cNumProtoc,cStatus,cMsgLivre,cUsuManif,dDatReg,cTime,cIdDevolucao)

	Local cSql := ""
	Local lRet := .F.
	Default cUsuManif := ""
	Default dDatReg := dDataBase
	Default cTime := StrTran(Time(),":","") 
	Default cIdDevolucao := "" 

	cSql := " SELECT MAX(B4I_SEQUEN) SEQUEN FROM "+RetSqlName("B4I")
	cSql += " WHERE B4I_FILIAL = '"+xFilial("B4I")+"' AND B4I_PROTOC = '"+cNumProtoc+"'"  
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)	    
			
	DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,cSql) , "TMP" , .F. , .T. )
	DBSelectArea("TMP")
	TMP->(DBGoTop())
	If TMP->(!Eof())
		B4I->(RecLock("B4I",.T.)) 
		B4I->B4I_FILIAL  := xFilial("B4I")        
		B4I->B4I_SEQUEN  := Soma1(TMP->SEQUEN)
		B4I->B4I_PROTOC  := cNumProtoc
		B4I->B4I_MENSAG  := cMsgLivre
		B4I->B4I_STATUS  := cStatus     
		B4I->B4I_DATRES  := dDatReg   
		B4I->B4I_HORRES  := StrTran(Time(),":","")  
		B4I->B4I_USUMAN  := cUsuManif 
		If B4I->(FieldPos("B4I_DEVCLI"))
			B4I->B4I_DEVCLI := cIdDevolucao
		EndIf
		B4I->(MsUnLock())  
		lRet := .T.         
	EndIf
	TMP->(DbCloseArea())  

Return lRet
            


//-------------------------------------------------------------------
/*/{Protheus.doc} PLRAUTRNWB

Gera registro na tabela B4I
@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------     
Function PLRAUTRNWB(cEmp,cFil,aThreads,cUsuario,nRecB00,cIdResposta,cMsgLivre)
Local cCodTraPro := ""
Local aRet       := {}
Default aThreads    := {}
Default cMsgLivre   := ""
Default cIdResposta := ""

RpcSetType(3)
RpcSetEnv(cEmp,cFil,,,'PLS')       

B00->(DbGoTo(nRecB00))

BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
BA0->(DbSeek(xFilial("BA0")+B00->B00_OPESOL))      
  
cCodTraPro := PLB4JRegTr(PlsIntPad(),B00->B00_OPESOL,"005")    

aRet :=  PLResAteRN(PlsIntPad(),B00->B00_OPESOL,"",cCodTraPro,dDatabase,cUsuario,;
        Substr(B00->B00_MATRIC,1,4),Substr(B00->B00_MATRIC,5,13),B00->B00_COD,cIdResposta,Alltrim(B00->B00_NRTROL),cMsgLivre)

Return     



//-------------------------------------------------------------------
/*/{Protheus.doc} PLEncExeWB

Recebimento de uma solicitacao de protocolo atraves do WebService solicProtocRN395

@author  PLS TEAM
@version P11
@since   15.04.16       

Parametros:
cCodUniOri --> Código da Unimed Origem do envio do arquivo
cCodUniDes --> Código da Unimed Destino para envio do arquivo 
cNumRegAns --> Número de Registro da ANS da Unimed Destino
cNumTraIni --> Numero Transação Inicial da Transação Solicitar Protocolo
cNumTraOri --> Numero de Controle da Transação da Unimed Origem
cDatGer    --> Data de geração da manifestação
cIDUsuario --> Usuário que solicitou a manifestação
cCodUniBen --> Código da Unimed
cIDBenef   --> Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte (CD_UNI).
cNome      --> Nome do Beneficiário
cCPF       --> Código do CPF
cDDD       --> Número do DDD
cTelefone  --> Número do telefone
cEmail     --> Endereço de email
cTipManif  --> Tipo de Manifestação
cTipCateg  --> Categoria da Manifestação
cTipSent   --> Sentimento do Cliente
cIDResp    --> Indica o status da manifestação
cNrTrolOri --> NUMERO TRANSACAO INTERCAMBIO
cNumProAnt --> Protocolo de Atendimento Anterior
cMsgLivre  --> Mensagem livre da manifestação

/*/
//-------------------------------------------------------------------   
Function PLEncExeWB(cCodUniOri,cCodUniDes,cNumRegAns,cNumTraIni,cNumTraOri,dDatGer,cIDUsuario,cMatric,cNome,cCPF,cDDD,cTelefone,;
					cEmail,cTipManif,cTipCateg,cTipSent,cNrTrolOri,cNumProto,cNumProAnt,cMsgLivre) 

Local cIdUsuResp := GetNewPar( "MV_PLRESRN" , "" )
Local cHash      := ""   
Local cIdErro    := ""
Local cMsgErro   := ""
Local cAlias     := ""    
Local cDataGer   := ""  
Local cManifest  := "1"
Local nX         := 0   
Local lChamTMK   := .F. 
Local lBenefOk   := .F.  
Local lFindBenef := .F.
Local aRet       := {}     
Local lGPURest     := GetNewPar("MV_PGPURES","0") == "1"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atraves do Tipo de Manifestacao e Categoria defino se e atendimento normal ou Call Center ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipManif  == "6" .And. cTipCateg  == "19"
	cAlias := "BEA"
Else
	lChamTMK  := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a matricula do beneficiario e valida                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(cMatric,1,4) == PlsIntPad() 
	BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	If BA1->(DbSeek(xFilial("BA1")+cMatric))  
		lFindBenef := .T.
	EndIf	
Else
	BA1->(DbSetOrder(5)) //BA1_FILIAL+BA1_MATANT+BA1_TIPANT
    If BA1->(DbSeek(xFilial("BA1")+cMatric)) .And.  BA1->BA1_OPEDES == Substr(cMatric,1,4)  
    	lFindBenef := .T.
	EndIf	
EndIf

If lFindBenef
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o beneficiario esta bloqueado                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(BA1->BA1_DATBLO) .Or. BA1->BA1_DATBLO <= dDatGer  
		lBenefOk := .T.

		gerRegB00(cNumProto,nil,cAlias,.F.,lChamTMK,cMatric,.T.,cTipManif,cTipCateg,cTipSent,;
				   "1",cCodUniOri,cNumTraIni,cMsgLivre,cIDUsuario,cNumProAnt,cNrTrolOri,cNumTraOri)      
        
   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o numero de transacao de intercambio ja foi informado, ja altera o protocolo B00       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cNrTrolOri)		   
			If !PLAtProRNW(cNumProto,cNrTrolOri,cCodUniOri)		   
				cManifest := "2"
			EndIf
		EndIf           
		B00->(RecLock("B00",.F.)) 
		B00->B00_TRAENC  := "2"
		B00->(MsUnLock())
	Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Indica codigo e mensagem de erro                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		cIdErro := "3" //Indica beneficiario inativo
		cMsgErro  := "Erro: Codigo do beneficiario inativo."
	EndIf	
Else
	cIdErro   := "1" //Indica beneficiario inexistente  
	cMsgErro  := "Erro: Codigo do beneficiario inexistente."
Endif   
					                 
BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BA0")+cCodUniDes))		  

cDataGer := Substr(Dtos(dDataBase),1,4)+"-"+Substr(Dtos(dDataBase),5,2)+"-"+Substr(Dtos(dDataBase),7,2)+IIf(lGPURest," ","T")+Time()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis de retorno e calcula Hash                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					   
aRet := {IIf(lBenefOk,"004","011"),;  //CODIGOTRANSACAO
 		"UNIMED",;            //TIPOCLIENTE
 		cValToChar(Val(cCodUniOri)),;          //CODIGO UNIMED ORIGEM
 		cValToChar(Val(cCodUniDes)),;          //CODIGO UNIMED DESTINO     
 		Alltrim(BA0->BA0_SUSEP)}//NUMERO REGISTRO ANS

If lBenefOk 		
	Aadd(aRet,cNumTraOri)          //NUMEROTRANSACAOPRESTADORA
	Aadd(aRet,cDataGer)            //DATA GERACAO 
	Aadd(aRet,cIdUsuResp)          //ID USUARIO
	Aadd(aRet,cValToChar(Val(Substr(cMatric,1,4)))) //CODIGO UNIMED
	Aadd(aRet,Substr(cMatric,5,13))//IDENTIFICACAO BENEFICIARIO    
	Aadd(aRet,cManifest)            //TIPO IDENTIFICADOR 
	Aadd(aRet,"1")                 //ORIGEM RESPOSTA   
	Aadd(aRet,GetNewPar("MV_R395LAY","001"))//NUMERO VERSAO PROTOCOLO
Else
	Aadd(aRet,cNumTraOpe)       //numeroTransacao
	Aadd(aRet,cIdErro)          //codigoErro  
	Aadd(aRet,cMsgErro)         //mensagemErro
EndIf 	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o valor do hash                                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
For nX := 1 to len(aRet)
	cHash := montaHash(cHash,aRet[nX])
Next 

cHash := Lower( MD5(cHash,2) )  

Return({aRet,cHash,cIdErro})              



//-------------------------------------------------------------------
/*/{Protheus.doc} PLRENCATWB

Encaminha transacao solicitaProtocolo para a Unimed Repasse   

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------     
Function PLRENCATWB(cEmp,cFil,aThreads,cOpeDes,cNumTraIni,dDataBase,cCodUniBen,cIDBenef,;
					cNome,cCPF,cDDD,cTelefone,cEmail,cTipManif,cTipCateg,cTipSent,cNumTraInt,cCodProtoc,cNumProAnt,cMsgLivre,aAuto)

Local cIdUsuResp := ""
Local cCodTraPro := "" 
Local aRet       := {}
Default aThreads    := {}
Default cNumProAnt  := ""
Default cMsgLivre   := ""
Default aAuto       := {.F.,""}

if !aAuto[1]
	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,,'PLS')  
endIf

cIdUsuResp := GetNewPar( "MV_PLRESRN" , "" )     


BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
BA0->(DbSeek(xFilial("BA0")+cOpeDes))      
  
cCodTraPro := PLB4JRegTr(PlsIntPad(),cOpeDes,"012")    

			
aRet := PLEncExeRN(PlsIntPad(),cOpeDes,"",cNumTraIni,cCodTraPro,dDataBase,cIdUsuResp,cCodUniBen,cIDBenef,;
					cNome,cCPF,cDDD,cTelefone,cEmail,cTipManif,cTipCateg,cTipSent,cNumTraInt,cCodProtoc,cNumProAnt,cMsgLivre,aAuto)
										

Return     


//-------------------------------------------------------------------
/*/{Protheus.doc} PLRENCREWB

Encaminha transacao respostaAtendimento para a Unimed Solicitante

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------     
Function PLRENCREWB(cEmp,cFil,aThreads,cOpeDes,cNumTraOri,dDatGer,cIDUsuario,cCodUniBen,cIDBenef,cNumProto,cIdResposta,cNrTrol,cMsgLivre)

Local cCodTraPro := "" 
Local aRet       := {}
Default aThreads    := {}
Default cNumProto   := ""
Default cMsgLivre   := ""

RpcSetType(3)
RpcSetEnv(cEmp,cFil,,,'PLS')  

BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
BA0->(DbSeek(xFilial("BA0")+cOpeDes))      
  
cCodTraPro := PLB4JRegTr(PlsIntPad(),cOpeDes,"003")    

aRet := PLResAteRN(PlsIntPad(),cOpeDes,"",cNumTraOri,dDatGer,cIDUsuario,cCodUniBen,cIDBenef,cNumProto,cIdResposta,cNrTrol,cMsgLivre)

Return        
                                                                        


//-------------------------------------------------------------------
/*/{Protheus.doc} PL773COMWS

Complementa um protocolo

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------   
Function PL773COMWS()     
Local nX := 0    
Local aRetWeb := {}   
Local aDadUsr := {}
Local lRetCom := .F.  
Local cMsgCri := ""

If B00->B00_INTERC == "1" .And. B00->B00_OPESOL == PlsIntPad() .And. !Empty(B00->B00_NRTROL) .And. ;
   B00->B00_TIPPRO == "1" .And. B00->B00_CANCEL <> "1"

	cCodTraPro := PLB4JRegTr(PlsIntPad(),B00->B00_OPEDES,"003")	
	aDadUsr    := PLSDADUSR(B00->B00_MATRIC,"1",.F.,dDataBase)

	While !lRetCom
		MsAguarde( {|| aRetWeb := PLComProRN(PlsIntPad(),B00->B00_OPEDES,"",cCodTraPro,dDatabase,;
										  cUserName,Substr(aDadUsr[3],1,4),Substr(aDadUsr[3],5,13) ,B00->B00_COD, B00->B00_NRTROL,,B00->B00_MSGINT) })
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe resposta		                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRetWeb[1]
			Aviso("Comunic. Complementar Protocolo","Comunicação 'Complementar Protocolo' concluída com sucesso.",{"Ok"})
			lRetCom := .T. 
		Else
			cMsgCri := "Não foi possível complementar o protocolo. Críticas:"+Chr(10)+Chr(10)
			For nX := 1 to len(aRetWeb[2])
		   		cMsgCri += Alltrim(aRetWeb[2][nX][1])+"-"+Alltrim(aRetWeb[2][nX][2])+Chr(10)
	  		Next   
	  			cMsgCri += Chr(10)+"Deseja complementar o protocolo novamente?"
	  		If !MsgYesNo(cMsgCri) 
	  			lRetCom := .T.
	  		EndIf
		EndIf
	EndDo
Else
	If  B00->B00_INTERC <> "1" 
		cMsg := "O atendimento selecionado não é de intercâmbio."   
	ElseIf B00->B00_OPESOL <> PlsIntPad()  	
		cMsg := "A operadora solicitante do atendimento deve ser igual a operadora padrão do Operador de sistema."  
	ElseIf Empty(B00->B00_NRTROL)
		cMsg := "O atendimento está sem o número de transação intercâmbio informado."   
	ElseIf B00->B00_TIPPRO <> "1"
		cMsg := "O atendimento selecionado deve ser do tipo Guias."   
	ElseIf B00->B00_CANCEL == "1"
	    cMsg := "O protocolo já está cancelado."  
	EndIf     
	Aviso("Responder Protocolo",cMsg,{"Ok"})

EndIf
	
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PLVldProtInt
Valida o número do protocolo informado

@author  Lucas Nonato
@version P11
@since   09/08/2016
/*/
//------------------------------------------------------------------- 

Function PLVldProtInt(cMatric, cNumProto)
Local aRetDadUsr 	:= {}
Local cCriticas	:= ""
Local lOk
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ WebService nao valida pois e carregado automaticamente da liberacao        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_PL395WS","0") == "1"  
	lOk := .T.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica REGANS da Operadora                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cMatric) 
	  		aRetDadUsr := PLSDADUSR(cMatric,"1",.T.,dDataBase)  
		If !Empty(aRetDadUsr[45]) .And. aRetDadUsr[45] <> PlsIntPad() 
	   		BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT  
	   		If BA0->(DbSeek(xFilial("BA0")+aRetDadUsr[45])) .And. !Empty(BA0->BA0_SUSEP) .And. (Substr(cNumProto,1,6) <>  Alltrim(BA0->BA0_SUSEP) ) 
	   			cCriticas += STR0086 + Chr(13) //"O registro ANS informado ?diferente do cadastro da Operadora." 
	   			lOk := .F.
	   		EndIf
	   	EndIf	 
	EndIf
	
	If Substr(cNumProto,7,4) <> Substr(Dtos(Date()),1,4) 
		cCriticas += STR0050 + Chr(13) //"- Ano incorreto" 
	 	lOk := .F.
	EndIf
	
	If Substr(cNumProto,11,2) <> Substr(Dtos(Date()),5,2) 
		cCriticas += STR0049 + Chr(13) //"- Mes incorreto" 
		lOk := .F.
	EndIf
		
	If Substr(cNumProto,13,2) <> Substr(Dtos(Date()),7,2)
		cCriticas += STR0048 + Chr(13) //"- Dia incorreto" 
		lOk := .F.
	EndIf
	
	If Substr(cMatric,5,4) == GetNewPar("MV_PLSGEIN",'') .And.  Substr(cNumProto,15,1) <> "9"
		cCriticas += STR0047 + Chr(13) //'- Identificador de intercambio "9" invalido'   
		lOk := .F.
	EndIf
	
	aAreaB00 := B00->(GetArea())
	B00->(DbSetOrder(1))//B00_FILIAL+B00_COD+B00_NUMGUI 
	If B00->(DbSeek(xFilial("B00")+cNumProto)) 
		If Empty(B00->B00_NUMGUI) .And. Empty(B00->B00_CODATE)
			If !Empty(cMatric) .And. !Empty(B00->B00_MATRIC) .And. Alltrim(cMatric) <> B00->B00_MATRIC
				cCriticas += STR0087 //"O protocolo selecionado esta vinculado com outro beneficiario."
				lOk := .F.
			EndIf
			lGeraB00 := .F.
		Else
			cCriticas := STR0046 //"O numero de protocolo informado j?foi registrado em outro atendimento."
    		lOk := .F.
		EndIf
	EndIf	
	RestArea(aAreaB00)
EndIf



Return {lOk,cCriticas}


//-------------------------------------------------------------------
/*/{Protheus.doc} PLRENCATWB

Job para complementar a guia na chamada do portal

@author  PLS TEAM
@version P11
@since   12/09/16
/*/
//-------------------------------------------------------------------     
Function PLRCOMPRWB(cEmp,cFil,aThreads,nRecB00)

Local cIdUsuResp := ""
Local cNumTraOri := "" 
Local aRet       := {}
Default aThreads    := {}

RpcSetType(3)
RpcSetEnv(cEmp,cFil,,,'PLS')  

cIdUsuResp := GetNewPar( "MV_PLRESRN" , "" )     

B00->(DbGoto(nRecB00))

BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
BA0->(DbSeek(xFilial("BA0")+B00->B00_OPEDES))      
  
cCodTraPro := PLB4JRegTr(PlsIntPad(),B00->B00_OPEDES,"003")	
aDadUsr    := PLSDADUSR(B00->B00_MATRIC,"1",.F.,dDataBase)


aRet := PLComProRN(PlsIntPad(),B00->B00_OPEDES,"",cCodTraPro,dDatabase,;
										  cIdUsuResp,Substr(aDadUsr[3],1,4),Substr(aDadUsr[3],5,13) ,Alltrim(B00->B00_COD), Alltrim(B00->B00_NRTROL),,B00->B00_MSGINT)
										

Return  


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidResProt
Validação para a Resposta de Protoclo para não cliente

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 29/07/2021
/*/
//-------------------------------------------------------------------  
Static Function ValidResProt(cTipoSolic, cDevClient)

	Local lValid := .T.

	Default cTipoSolic := ""
	Default cDevClient := ""

	If !Empty(cTipoSolic) // Protocolo Não Cliente
		If cTipoSolic == "3" .And. Empty(cDevClient)
			MsgInfo(STR0094, STR0095) // "Quando o Tipo de Solicitante for igual a 3 - Não Cliente, deverá ser informado se tornou-se cliente."; "Obrigatório" 
			lValid := .F.
		EndIf
	EndIf 

Return lValid
