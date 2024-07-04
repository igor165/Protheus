#INCLUDE "HHWizSFA.ch"
#INCLUDE "protheus.ch"
#INCLUDE "APWIZARD.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HHWIZSFA  ºAutor  ³Rodrigo A. Godinho  º Data ³  01/23/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Wizard de configuracao inicial do SFA.                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SFA                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HHWizSFA()

Local aIniSys		:=	{}
Local aIniServ		:=	{}
Local aTblSrv		:=	{}
Local aIniTbl		:=	{}
Local __PSALIAS		:=	""
Local __PTBLALIAS	:=	""
Local nRec			:=	0
Local ni			:=	1
Local oWizard
Local hObrig		:=	LoadBitmap( GetResources(), "DISABLE" )
Local hOk			:=	LoadBitmap( GetResources(), "LBTIK" )
Local hNo			:=	LoadBitmap( GetResources(), "LBNO" )
Local oLB_Serv
Local nPosTbl		:=	0
Local nPosSrv		:=	0
Local lFim 			:=	.F.
Local oLB_Param
Local aParam		:=	{}
Local aGetParam		:=	Array(4)
Local aParamInfo	:=	Array(4)
Local cAliasAtual	:=	""
Local aAliasAtual	:=	{}     
Local aBtn			:=	Array(5)		
Local oLegenda
Local oBmp
Local aHGRPSRV		:=	{}
Local oGrpDefSrv	:=	{}
Local PALMDIR 		:=	HHGetDir()
Local PTALIAS		:=	""
Local aSx6			:= {}
Local aAllServ		:= {}

dbSelectArea("SX6")
dbSetOrder(1)

//Cria diretorio do palm
MakeDir(PALMDIR)
MakeDir(PALMDIR+ "\Logs\")

//Cria a Tabela HHTIME
PTALIAS   := HHOpenTime()
// Reabre a Tabela HHTIME
(PTALIAS)->(dbCloseArea())
HHOpenTime()

//Cria/Abre as tabelas de servicos e tabelas
__PSALIAS	:=	POpenSrv()
__PTBLALIAS	:=	POpenTbl()

//Ajusta arquivo de Help de acordo com os helps criados para o fonte
AjustaHelp()
//Cria os parametros necessarios ao SFA caso os mesmos nao estejam criado 
//Abre/Cria o arquivo de relacionamento GRUPO/SERVICO
POpenGrp()
aGRPSRV := HGS->(GetArea())
// Cria e Abre arquivos HHS
POpenSys()

MsgRun(STR0135,,{ || SFAllServ(@aAllServ)}) //"Carregando serviços do sistema"
MsgRun(STR0136,,{ || SFAllPar(0,@aParam)}) //"Carregando parametros do sistema"

// Grava Sistemas Iniciais
dbSelectArea("HHS")
dbSetOrder(1)
nRec :=HHS->(RecCount())
If nRec < 3
	aIniSys	:= aClone(aAllServ[1])
EndIf

// Grava Servicos Iniciais
aIniServ	:= aClone(aAllServ[2])
aTblSrv		:= aClone(aAllServ[3])

For ni := 1 to Len(aIniServ)
	If aIniServ[ni, 9]
		aIniServ[ni, 8] := (__PSALIAS)->(dbSeek(aIniServ[ni, 1]))
	EndIf
Next

dbSelectArea(__PTBLALIAS)
dbSetOrder(1)
nRecTbl := (__PTBLALIAS)->(RecCount())
aIniTbl := aClone(aAllServ[4])

If !VrfTblSFA(aInitbl)
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do Wizard.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Panel Inicial³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTxtWizIni := STR0042+CRLF //"Esta rotina tem como finalidade auxilia-lo na configuração inicial "
cTxtWizIni += STR0043//"dos Processos de Retaguarda do SFAxProtheus. " 

DEFINE WIZARD oWizard TITLE STR0041 HEADER "" ; //"Assistente de Configuração do SFA"
		MESSAGE ""; 							 
	   	TEXT cTxtWizIni; 
	   	NEXT   {|| aBtn[01]:lVisibleControl := .T.,aBtn[02]:lVisibleControl := .T.,.T.}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Panel dos Serviços³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTxtWizSrv := STR0045 //"Selecione os Serviços a serem instalados ou desmarque os Serviços já instalados para exclui-los."
CREATE PANEL oWizard  ;
	HEADER STR0044;  //"Configuração Inicial dos Serviços"
	MESSAGE cTxtWizSrv	; 
	BACK {|| aBtn[01]:lVisibleControl := .F.,aBtn[02]:lVisibleControl := .F.,.T.} ;
	NEXT {|| aBtn[01]:lVisibleControl := .F.,aBtn[02]:lVisibleControl := .F.,aBtn[03]:lVisibleControl := .T.,.T.} ;
	PANEL
	
	@ 000, 000 LISTBOX oLB_Serv VAR "" FIELDS HEADER "",STR0046 SIZE 140,137 OF oWizard:GetPanel(2) PIXEL; //"Serviços"
	ON DBLCLICK (Iif(aIniServ[oLB_Serv:nAt,9],aIniServ[oLB_Serv:nAt,8] := !aIniServ[oLB_Serv:nAt,8],Help(" ",1,"HHWIZSFA01")),oLB_Serv:Refresh())
	oLB_Serv:SetArray(aIniServ)
	oLB_Serv:bLine:= { || { Iif( aIniServ[oLB_Serv:nAt,8],Iif( aIniServ[oLB_Serv:nAt,9], hOk , hObrig ), hNo ),aIniServ[oLB_Serv:nAt,2]}} 
 	@ 185,024  BUTTON aBtn[01] PROMPT STR0047	SIZE 45,13 PIXEL ACTION(MarcaTodos(@aIniServ),oLB_Serv:Refresh()) //"Marca Todos"
	@ 185,074  BUTTON aBtn[02] PROMPT STR0048	SIZE 45,13  PIXEL ACTION(Inv_Selecao(@aIniServ),oLB_Serv:Refresh()) //"Inverter Seleção"
    aBtn[01]:lVisibleControl := .F.
    aBtn[02]:lVisibleControl := .F.
    @ 000, 147 GROUP oLegenda TO 60, 285 PROMPT STR0049 OF oWizard:GetPanel(2) PIXEL //"Legenda"
    @ 010, 160 BITMAP oBmp RESNAME "DISABLE" OF oWizard:GetPanel(2) SIZE 010, 010 NOBORDER WHEN .F. PIXEL 
    @ 010, 175 SAY STR0050 	OF oWizard:GetPanel(2) PIXEL //"Serviços Obrigatórios"
    @ 025, 160 BITMAP oBmp RESNAME "LBTIK"   OF oWizard:GetPanel(2) SIZE 010, 010 NOBORDER WHEN .F. PIXEL 
	@ 025, 175 SAY STR0051 OF oWizard:GetPanel(2) PIXEL //"Serviços Opcionais selecionados"
    @ 040, 160 BITMAP oBmp RESNAME "LBNO"   OF oWizard:GetPanel(2) SIZE 010, 010 NOBORDER WHEN .F. PIXEL 
	@ 040, 175 SAY STR0052 OF oWizard:GetPanel(2) PIXEL //"Serviços Opcionais não selecionados"
	@ 070, 147 GROUP oGrpDefSrv TO 130, 285 PROMPT STR0123 OF oWizard:GetPanel(2) PIXEL //"Definicão de Serviço"
	@ 076, 151 SAY STR0124 	OF oWizard:GetPanel(2) PIXEL //"Serviço - Processo de atualização (importação ou "  
	@ 083, 151 SAY STR0125 	OF oWizard:GetPanel(2) PIXEL //"exportação) das informações das Tabelas do SFA e"
	@ 090, 151 SAY STR0126 	OF oWizard:GetPanel(2) PIXEL //"suas respectivas tabelas equivalentes no Protheus."
	@ 097, 151 SAY STR0127 	OF oWizard:GetPanel(2) PIXEL //	'Ex.: O serviço "Pedido de Venda" atualiza as'
	@ 104, 151 SAY STR0128 	OF oWizard:GetPanel(2) PIXEL // "tabelas de cabeçalhos de Pedidos de Venda e"
	@ 111, 151 SAY STR0129 	OF oWizard:GetPanel(2) PIXEL //"Itens de Pedidos de Venda com as informações"
	@ 118, 151 SAY STR0130 	OF oWizard:GetPanel(2) PIXEL //"da suas tabelas equivalentes no Protheus."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Panel dos Parâmetros³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard  ;
	HEADER STR0053;  //"Configuração Inicial dos Parâmetros"
	MESSAGE STR0054; //"Configure os parâmetros do Sistema que são utilizados pelo SFA."
	BACK {|| aBtn[01]:lVisibleControl := .T.,aBtn[02]:lVisibleControl := .T.,aBtn[03]:lVisibleControl := .F.,aBtn[04]:lVisibleControl := .F.,aBtn[05]:lVisibleControl := .F.,aGetParam[003]:bWhen:={||.F.},.T.} ;
	FINISH {|| lFIM := .T.}; 
	PANEL

	@ 000,000 LISTBOX oLB_Param FIELDS HEADER STR0055 PIXEL SIZE 140,137 OF oWizard:GetPanel(3); //"Parâmetros"
	ON DBLCLICK ()
	oLB_Param:SetArray(aParam)
	oLB_Param:bChange := {|| View_SX6(aParam[oLB_Param:nAT][1],@aGetParam,@aParamInfo,aParam),aBtn[04]:lVisibleControl := .F.,aBtn[05]:lVisibleControl := .F.,aGetParam[003]:bWhen:={||.F.},aGetParam[003]:SetFocus(),oLB_Param:Refresh()}
    oLB_Param:bLine   := {|| {aParam[oLB_Param:nAT][1]}}
    @ 185,074  BUTTON aBtn[03] PROMPT STR0056	SIZE 45,13 PIXEL ACTION( aGetParam[003]:bWhen:={||.T.},aBtn[04]:lVisibleControl := .T.,aBtn[05]:lVisibleControl:=.T.) //"Editar"
    aBtn[03]:lVisibleControl := .F.
    @ 120,170  BUTTON aBtn[04] PROMPT STR0057 SIZE 45,13 OF oWizard:GetPanel(3) PIXEL ACTION(Altera_SX6(aParam[oLB_Param:nAT][1],aParamInfo[003],aParamInfo,@aSx6,@aParam),aBtn[04]:lVisibleControl := .F.,aBtn[05]:lVisibleControl := .F.,aGetParam[003]:bWhen:={||.F.},aGetParam[003]:SetFocus()) //"Confirmar"
    aBtn[04]:lVisibleControl := .F.
    @ 120,220  BUTTON aBtn[05] PROMPT STR0058 SIZE 45,13 OF oWizard:GetPanel(3) PIXEL ACTION(View_SX6(aParam[oLB_Param:nAT][1],@aGetParam,@aParamInfo,aParam),aBtn[04]:lVisibleControl := .F.,aBtn[05]:lVisibleControl := .F.,aGetParam[003]:bWhen:={||.F.},aGetParam[003]:SetFocus()) //"Cancelar"
    aBtn[05]:lVisibleControl := .F.
    
    @ 005,150 SAY STR0059 	OF oWizard:GetPanel(3) PIXEL //"Parâmetro"
    @ 012,150 GET aGetParam[001] VAR aParamInfo[001] PIXEL SIZE 40,10 OF oWizard:GetPanel(3) WHEN .F.  
 //   aGetParam[001]:lVisibleControl := .F.
    @ 030,150 SAY STR0060 	OF oWizard:GetPanel(3) PIXEL //"Tipo"
    @ 037,150 GET aGetParam[002] VAR aParamInfo[002] PIXEL SIZE 10,10 OF oWizard:GetPanel(3) WHEN .F.
 //   aGetParam[002]:lVisibleControl := .F.
    @ 055,150 SAY STR0061 	OF oWizard:GetPanel(3) PIXEL //"Conteúdo"
    @ 062,150 GET aGetParam[003] VAR aParamInfo[003] PIXEL SIZE 130,10 OF oWizard:GetPanel(3) When .F.
 //   aGetParam[003]:lVisibleControl := .F.
    @ 080,150 SAY STR0131 	OF oWizard:GetPanel(3) PIXEL //"Descrição"
    @ 087,150 GET aGetParam[004] VAR aParamInfo[004] PIXEL SIZE 130,028 OF oWizard:GetPanel(3) MULTILINE TEXT When .F.
 //   aGetParam[004]:lVisibleControl := .F.

ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravação das configurações selecionadas no Wizard.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFim
	//Grava parametros que nao existiam no SX6
	For ni := 1 to len(aParam)
		If !(SX6->(dbSeek(xFilial("SX6")+aParam[ni][1])))
			aAdd(aSx6,{xFilial("SX6"),aParam[ni][1],aParam[ni][4],Memoline(aParam[ni][2],50,1),Memoline(aParam[ni][2],50,1),;
				Memoline(aParam[ni][2],50,1),Memoline(aParam[ni][2],50,2),Memoline(aParam[ni][2],50,2),;
				Memoline(aParam[ni][2],50,2),Memoline(aParam[ni][2],50,3),Memoline(aParam[ni][2],50,3),;
				Memoline(aParam[ni][2],50,3),aParam[ni][3],aParam[ni][3],aParam[ni][3],"S"})
		EndIf
	Next
	If len(aSx6) > 0
		MsgRun(STR0141,,{ || SFAAtuSX6(aSx6)}) // "Criando parametros..."
	EndIf
	If AliasIndic("HCF") .And. AliasIndic("HX5")
		MsgRun(STR0140,,{ || XEXPHCF()}) //"Atualizando tabela espelho"
	EndIf
	//Grava informacoes sobre o Sistema SFA
	If Len(aIniSys) > 0
		dbSelectArea("HHS")
		HHS->(dbSetOrder(1))
		For ni := 1 to len(aIniSys)
			If !HHS->(dbSeek(aIniSys[ni, 1]))
				RecLock("HHS", .T.)
				HHS->HHS_COD   := aIniSys[ni, 1]
				HHS->HHS_DESCR := aIniSys[ni, 2]
				HHS->HHS_TAB   := aIniSys[ni, 3]
				HHS->(MsUnLock())
			EndIf
		Next
	EndIf
	//Grava e remove os servicos conforme os mesmos foram selecionados(ou nao) atraves do wizard
	If Len(aIniServ) > 0
		dbSelectArea(__PSALIAS)
		(__PSALIAS)->(dbSetOrder(1))
		dbSelectArea("HGS")
		HGS->(dbSetOrder(2)) 
		For ni := 1 To Len(aIniServ)
			//Gravo todos os serviços na tabela de servicos
			If !(__PSALIAS)->(dbSeek(aIniServ[ni, 1])) // .And. aIniServ[ni, 8]
				RecLock(__PSALIAS, .T.)	
				(__PSALIAS)->HHR_COD    := aIniServ[ni, 1]
				(__PSALIAS)->HHR_DESCR  := aIniServ[ni, 2]
				(__PSALIAS)->HHR_FUNCAO := aIniServ[ni, 3]
				(__PSALIAS)->HHR_ALIAS  := aIniServ[ni, 4]
				(__PSALIAS)->HHR_ARQ    := aIniServ[ni, 5]
				(__PSALIAS)->HHR_TIPO   := aIniServ[ni, 6]
				(__PSALIAS)->HHR_EXEC   := aIniServ[ni, 7]
				(__PSALIAS)->(MsUnLock()) 
			EndIf
			If (__PSALIAS)->(dbSeek(aIniServ[ni, 1]))
			  	Begin Transaction
					If !aIniServ[ni, 8] //Se nao foi selecionado, apago de todos os grupos relacionados
						//Apaga os registros de relacionamento com os grupos
						If HGS->(dbSeek(aIniServ[ni,1]))
							While !HGS->(EOF()) .And. HGS->HGS_SRV == aIniServ[ni,1]
								RecLock("HGS", .F.)
								HGS->(dbDelete())
								HGS->(MsUnLock())
								HGS->(dbSkip())
							End
						EndIf
						//Apaga o registro do servico
						//RecLock(__PSALIAS, .F.)
						//(__PSALIAS)->(dbDelete())
						//(__PSALIAS)->(MsUnLock())
					EndIf
				End Transaction
			EndIf
		Next
	EndIf
	//Grava as tabelas no arquivo de Tabelas do SFA
	If Len(aIniTbl) > 0
		dbSelectArea(__PTBLALIAS)
		(__PTBLALIAS)->(dbSetOrder(1))
		For ni := 1 To Len(aIniTbl)
			If !(__PTBLALIAS)->(dbSeek(aIniTbl[ni,1]))
				RecLock(__PTBLALIAS, .T.)
				(__PTBLALIAS)->HHT_COD    := aIniTbl[ni,1]
				(__PTBLALIAS)->HHT_DESCR  := aIniTbl[ni,2]
				(__PTBLALIAS)->HHT_ALIAS  := aIniTbl[ni,3]
				(__PTBLALIAS)->HHT_GEN    := aIniTbl[ni,4]
				(__PTBLALIAS)->HHT_TOHOST := aIniTbl[ni,5]
				(__PTBLALIAS)->HHT_FLDFIL := aIniTbl[ni,6]
				(__PTBLALIAS)->HHT_SHARE  := ""
				(__PTBLALIAS)->HHT_VER    := aIniTbl[ni,7]
				(__PTBLALIAS)->HHT_FILEMP := aIniTbl[ni,8]
				(__PTBLALIAS)->(MsUnLock())
			EndIf
		Next
	EndIf
	//Grava os registros de relacionamentos Tabelas/Servicos 
	If Len(aTblSrv) > 0
		dbSelectArea("HST")
		HST->(dbSetOrder(1))
		For ni := 1 To Len(aTblSrv)
			If (__PSALIAS)->(dbSeek(aTblSrv[ni,1])) .And. (__PTBLALIAS)->(dbSeek(aTblSrv[ni,2]))
				If !(HST->(dbSeek(aTblSrv[ni,1]+aTblSrv[ni,2])))
					RecLock("HST", .T.)
					HST->HST_CODSRV := aTblSrv[ni,1]
					HST->HST_CODTBL := aTblSrv[ni,2]
					HST->(MsUnLock())
				EndIf
			EndIf 
		Next
	EndIf
EndIf

HGS->(RestArea(aGRPSRV))
(__PSALIAS)->(dbCloseArea())
(__PTBLALIAS)->(dbCloseArea())
HST->(dbCloseArea()) 

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³MarcaTodosºAutor  ³Rodrigo A. Godinho  º Data ³  10/24/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Marca todas as linhas de um listbox.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Wizard do SFA                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MarcaTodos(aTabelas)
Local nX	:=	0
	for nX:=1 to Len(aTabelas)
		If aTabelas[nX][9]
			aTabelas[nX][8] := .T.
		EndIf
	Next
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Inv_SelecaoºAutor ³Rodrigo A. Godinho  º Data ³  22/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inverter a selecao das linhas de um listbox.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Wizard do SFA                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Inv_Selecao(aTabelas)
Local nX	:=	0
	for nX:=1 to Len(aTabelas)
		If aTabelas[nX][9]
			aTabelas[nX][8] := !aTabelas[nX][8]
		EndIf
	Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³AjustaHelpºAutor  ³Rodrigo A. Godinho  º Data ³  22/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta arquivo de help de acordo com novos helps do Wizard  º±±
±±º          ³de configuracao do SFA.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Wizard do SFA                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaHelp()
Local aHelpPor	:=	{} 
Local aHelpEng	:=	{}
Local aHelpEsp	:=	{}
Local aSoluPor	:=	{} 
Local aSoluEng	:=	{}
Local aSoluEsp	:=	{}

//Problemas
aHelpPor := {STR0062,STR0063} //"Este é um serviço obrigatório e não pode "###"ser excluido."
aHelpEng := {STR0062,STR0063} //"Este é um serviço obrigatório e não pode "###"ser excluido."
aHelpEsp := {STR0062,STR0063} //"Este é um serviço obrigatório e não pode "###"ser excluido."

//Soluções
aSoluPor := {STR0064,STR0065,STR0066} //"Só é possível excluir os serviços "###"opcionais.  Tente desmarcar  um "###"serviço que seja opcional."
aSoluEng := {STR0064,STR0065,STR0066} //"Só é possível excluir os serviços "###"opcionais.  Tente desmarcar  um "###"serviço que seja opcional."
aSoluEsp := {STR0064,STR0065,STR0066} //"Só é possível excluir os serviços "###"opcionais.  Tente desmarcar  um "###"serviço que seja opcional."

PutHelp("PHHWIZSFA01",aHelpPor,aHelpEng,aHelpEsp,.F.)
PutHelp("SHHWIZSFA01",aSoluPor,aSoluEng,aSoluEsp,.T.)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³View_SX6  ºAutor  ³Rodrigo A. Godinho  º Data ³  22/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza conteudo dos TextBOx's do painel de configuracao   º±±
±±º          ³de parametros do Wizard do SFA.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Wizard do SFA                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function View_SX6(cParam,aGet,aInfo,aParam)
Local aAliasSX6	:=	SX6->(GetArea())
Local ni		:=	0

If SX6->(dbSeek(xFilial("SX6")+cParam))
	aInfo[001] := SX6->X6_VAR
	aInfo[002] := SX6->X6_TIPO
	aInfo[003] := SX6->X6_CONTEUD
	aInfo[004] := Iif(!Empty(SX6->X6_DESCRIC),SX6->X6_DESCRIC,"")
	aInfo[004] += Iif(!Empty(SX6->X6_DESC1),SX6->X6_DESC1,"")
	aInfo[004] += Iif(!Empty(SX6->X6_DESC2),SX6->X6_DESC2,"")
Else
	If (nPos := aScan(aParam,{|x| cParam $ x[1]})) > 0
		aInfo[001] := aParam[nPos][1]
		aInfo[002] := aParam[nPos][4]
		aInfo[003] := aParam[nPos][3]+Space(len(SX6->X6_CONTEUD)-len(aParam[nPos][3]))
		aInfo[004] := aParam[nPos][2]
	Else
		aInfo[001] := ""
		aInfo[002] := ""
		aInfo[003] := ""
		aInfo[004] := ""
	EndIf
EndIf
For ni := 1 to Len(aGet)
	aGet[ni]:Refresh()
next
SX6->(RestArea(aAliasSX6))
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Altera_SX6ºAutor  ³Rodrigo A. Godinho  º Data ³  22/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera o conteudo do paramentro de acordo com o valor       º±±
±±º          ³digitado no painel de configuracoes de parametros           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Wizard do SFA                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Altera_SX6(cParam,cConteudo,aParamInfo,aSx6,aParam)
Local aAliasSX6	:=	SX6->(GetArea())

If SX6->(dbSeek(xFilial("SX6")+cParam))
	RecLock("SX6",.F.)
	SX6->X6_CONTEUD := cConteudo
	dbCommit()
	MsUnLock()
Else
	//Adiciona parametro para atualizacao no SX6
	aAdd(aSx6,{xFilial("SX6"),cParam,aParamInfo[2],SubStr(aParamInfo[4],1,50),SubStr(aParamInfo[4],1,50),;
			  SubStr(aParamInfo[4],1,50),SubStr(aParamInfo[4],51,50),SubStr(aParamInfo[4],51,50),;
			  SubStr(aParamInfo[4],51,50),SubStr(aParamInfo[4],101,50),SubStr(aParamInfo[4],101,50),;
			  SubStr(aParamInfo[4],101,50),cConteudo,cConteudo,cConteudo,"S"})
			  
	//Altera valor no array de display
	If (nPos := aScan(aParam,{|x| cParam $ x[1]})) > 0
		aParam[nPos][3] := cConteudo
	EndIf
	
EndIf
SX6->(RestArea(aAliasSX6))
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao ³  VrfTblSFA  ºAutor  ³Liber De Esteban    º Data ³  17/01/07   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³Verifica existencia de tabelas no dicionario                   º±±
±±ºDesc.  ³Ajusta modo de compartilhamento                                º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    ³ SFA                                                           º±±
±±ÈÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/			
Function VrfTblSFA(aInitbl)

Local aAreaSX2	:= SX2->(GetArea())
Local ni		:= 0
Local cModoSG	:= ""

For ni := 1 to len(aInitbl)
	If !(AliasIndic(aInitbl[ni][3])) .And. !(aInitbl[ni][3] $ "ADVTBL/ADVIND/ADVCOL")
		cMsg := STR0137 + Alltrim(aInitbl[ni][3]) + STR0138 + Chr(13) + Chr(10) //"Tabela "###" não encontrada no SX2"
		cMsg += STR0139 + Alltrim(aInitbl[ni][2]) //"Cadastre esse arquivo no dicionario para utilizar o serviço de "
		MsgAlert(cMsg)
		If aInitbl[ni][3] $ "HM0/HA3/HC5/HC6"
			Return .F.
		EndIf
	ElseIf len(aINiTbl[ni]) == 9  .And. !Empty(aINiTbl[ni,3]) .And. !Empty(aINiTbl[ni,9])
		If SX2->(dbSeek(aINiTbl[ni,9]))//Posiciona na tabela do SIGA
			cModoSG := SX2->X2_MODO//Guarda o modo de compartilhamento da tabela do SIGA
			If SX2->(dbSeek(aINiTbl[ni,3]))//Posiciona na tabela espelho do SFA
				If SX2->X2_MODO!=cModoSG
					RecLock("SX2",.F.)
					SX2->X2_MODO := cModoSG
					MSUnlock()
				EndIf
			EndIf
		EndIf		
	EndIf
Next

SX2->(RestArea(aAreaSX2))

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SFAAtuSX6 ³ Autor ³Liber De Esteban       ³ Data ³17/01/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SX6                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao dos parametros do SFA no SX6                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SFAAtuSX6(aSX6)

Local aEstrut:= {}
Local i      := 0
Local j      := 0

//Estrutura da tabela SX6			
aEstrut:= { "X6_FIL","X6_VAR","X6_TIPO","X6_DESCRIC","X6_DSCSPA","X6_DSCENG","X6_DESC1","X6_DSCSPA1","X6_DSCENG1",;
	"X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI"}

For i:= 1 To Len(aSX6)
	If !Empty(aSX6[i][2])
		If !(SX6->(dbSeek(aSX6[i,1]+aSX6[i,2])))
			RecLock("SX6",.T.)
			For j:=1 To Len(aSX6[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX6[i,j])
				EndIf
			Next j
			dbCommit()
			MsUnLock()
		EndIf
	EndIf
Next i

Return
