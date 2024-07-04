#include "protheus.ch"
#include "dbtree.ch"
#include "tbiconn.ch"
#include "ctbarea.ch"
#include "ctba086.ch"         
// 
// Cadastro de Lan็amento Padrใo
// Copyright (C) 2007, Microsiga
// amarracao

Static __aProcs

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA086   บAutor  ณMicrosiga           บ Data ณ  07/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBA086()
Local nWidth	:= GetScreenRes()[IDX_SCREEN_WIDTH] - 40
Local nHeight	:= GetScreenRes()[IDX_SCREEN_HEIGHT] - 200
Local oDlg 		:= Nil
Local aModules	:= {}
Local i 		:= 0
Local aButtons 	:= {}
Local oSidebar 	:= Nil

// WOP: Declarar estas variแveis como private deixam o c๓digo
//      menos robusto e mais acoplado, al้m de causar
//      problemas nas futuras manuten็๕es do mesmo.
//

// Variaveis utilizadas na contabilizacao do modulo SigaFin
// declarada neste ponto, caso o acesso seja feito via SigaAdv

Debito  	:= ""
Credito 	:= ""
CustoD		:= ""
CustoC		:= ""
ItemD 		:= ""
ItemC 		:= ""
CLVLD		:= ""
CLVLC		:= ""

Conta		:= ""
Custo 		:= ""	
Historico 	:= ""
ITEM		:= ""
CLVL		:= ""

IOF			:= 0


Abatimento  := 0
REGVALOR    := 0
STRLCTPAD 	:= ""		//para contabilizar o historico do cheque
NUMCHEQUE 	:= ""		//para contabilizar o numero do cheque
ORIGCHEQ  	:= ""		//para contabilizar o Origem do cheque
CODFORCP  	:= ""		//para contabilizar o Codigo do Fornecedor da Compensacao
LOJFORCP 	:= ""		//para contabilizar o Loja Fornecedor da Compensacao
cHist190La 	:= ""
Variacao	:= 0
dDataUser	:= MsDate()
VALORMF		:= 0
VALLIQ		:= 0

//Nใo apagar variaveis utilizadas para a contabiliza็ใo na integra็ใo TIN X PROTHEUS
__nTINVCTB	:= 0
__cTINHCTB	:= ""

// Variaveis utilizadas na contabilizacao do modulo SigaAtf

CTABEM		:= ""
DESPDEPR	:= ""
DEPREACUM	:= ""
CORREDEPR	:= ""
CORREBEM	:= ""
Custo 		:= ""	

// Variaveis para contabilizacao Centro de custo, item e classe de valor

CUSTBEMCTB	:= ""
CCCORRCTB	:= ""
CCDESPCTB	:= ""
CCCDESCTB	:= ""
CCCDEPCTB	:= ""

SUBCCONCTB	:= ""
SUBCCORCTB	:= ""
SUBCDESCTB	:= ""
SUBCDEPCTB	:= ""
SUBCCDECTB	:= ""

CLVLCONCTB	:= ""
CLVLCORCTB	:= ""
CLVLDESCTB	:= ""
CLVLDEPCTB	:= ""
CLVLCDECTB	:= ""

// Variaveis para contabilizacao Template de Gestใo de Empreendimentos Imobiliแrios

TPLNUM    	:= ""
TPLDTCM   	:= CTOD("  /  /  ")
TPLBCMP 	:= 0
TPLBCMJ 	:= 0
TPLCMP    	:= 0
TPLCMJ    	:= 0
TPLCMCUS	:= 0
TPLCMRES    := 0

// o objeto oTree pode ser local, contanto que
// os blocos de c๓digos que o usem sejam
// declarados nesta fun็ใo
Private oTree := Nil

// a แrea deve ser private	
Private oArea := FwArea():New(0, 0, nWidth, nHeight, oDlg, 1, STR0001)

//"Cadastro de Lan็amento Padrใo"	                              
// a cria็ใo de variแveis privates ้ necessแria
// para a utiliza็ใo dos objetos jแ existentes

// objetos private para o sidebar
Private aButtonsSidebar := {}

// objetos private para o layout de m๓dulo	
Private oSayModule 	:= Nil
Private Inclui 		:= .F.
Private Altera 		:= .F.
Private Exclui 		:= .F.
Private oEntry 		:= Nil
Private oProcess 	:= Nil
Private oOperation 	:= Nil
Private aClipboard 	:= {} // "แrea de transfer๊ncia"
Private nStatus 	:= STATUS_UNKNOWN   // para evitar o ChgeHandler() no refresh	

Pergunte( 'CTB086', .F. )	

SetKey( VK_F12,{|| Pergunte('CTB086',.T.)})

If mv_par01 == 2
	Ctba080()
	Return
EndIf 
    
If mv_par06 == 1
	Processa( {|| CT52CVI() }, STR0045) //'Verificando vinculos...'
Endif     
    
//carrea os modulos
aModules	:=	GetModules()

// bot๕es do sidebar
aAdd(aButtons, {IMG_SEARCH	, IMG_SEARCH , STR0002, {|| aXpesquiTree(oTree,.F.)}	, STR0003})	// pesquisar
aAdd(aButtons, {IMG_DELETE	, IMG_DELETE , STR0004, {|| DelHandler(oTree)  }   , STR0005})	// excluir
aAdd(aButtons, {IMG_CREATE	, IMG_CREATE , STR0006, {|| AddHandler(oTree)  }	, STR0007})	// incluir
aAdd(aButtons, {IMG_PASTE	, IMG_PASTE	 , STR0008, {|| PasteHandler(oTree)}	, STR0009})	// colar
aAdd(aButtons, {IMG_COPY	, IMG_COPY	 , STR0010, {|| CopyHandler(oTree) }	, STR0011})	// copiar
aAdd(aButtons, {IMG_CUT		, IMG_CUT	 , STR0012, {|| CutHandler(oTree)  }	, STR0013})	// recortar
aAdd(aButtons, {IMG_REFRESH	, IMG_REFRESH, STR0014, {|| RefreshTree(oTree) }	, STR0015})	// atualizar

If oArea != Nil

	oArea:CreateBorder(3)

	SetFont("FW Microsiga")		// altera a fonte

	// sidebar
	oSidebar := CreateSidebar(oArea, aButtons)

	// แrvore Xtree
	oTree := XTree():New(0, 0, 0, 0, oArea:GetPanel(PANEL_SIDEBAR))
	
	// layout Module
	CreateModuleLayout(oArea)

	// layout Process
	oProcess := CtbProcess():New(oArea, oTree)
	
	// layout Operation
	oOperation := CtbOperation():new(oArea, oTree)
	
	// layout Entry
	oEntry := CtbEntry():New(oArea, oTree)		
	
	// layout desconhecido
	CreateUnknownLayout(oArea)

	// preenche info		
	oTree:Align := CONTROL_ALIGN_ALLCLIENT
	oTree:BrClicked	:= {|x, y, z| RightClickHandler(oTree, , x, y, z) }
	oTree:bValid := {|| !Inclui .And. !Altera .And. !Exclui }
	oTree:bWhen  := {|| !Inclui .And. !Altera .And. !Exclui }	

	// preenche o XTree com os m๓dulos
	For i := 1 To Len(aModules)
	
		// adiciona os m๓dulos
		oTree:AddTree(aModules[i][2];
					, aModules[i][3];
					, aModules[i][4];
					, aModules[i][1];
					, {|| ChangeHandler(oTree) };
					, {|x, y, z| RightClickHandler(oTree, , x, y, z) };
					, {|| DblClickHandler(oTree) })
		
		oTree:EndTree()
	Next

	// altera o texto do m๓dulo
	If Len(aModules) > 0
		oSayModule:cCaption := ModuleText(DecodeRecno(aModules[1][1]))
	EndIf
	
	// seleciona o layout correto para exibi็ใo
	oArea:ShowLayout(LAYOUT_MODULE)
				
	// configura as propriedades da แrea
	oArea:Style(oTree)    
	oArea:ActDialog()				
EndIf	

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |GetModulesบAutor  ณAdriano Ueda        บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GetModules()

Local aModules := {}                                                      	

//  aModules:
//	
//  01 - ID (string)
//  02 - Descri็ใo (string)	
//  03 - imagem quando fechado
//  04 - imagem quando aberto

// os c๓digos dos m๓dulos foram obtidos
// atrav้s do menu

// SIGAEST - Estoque
Aadd(aModules, {CodeCargo(04, NODE_TYPE_MODULE), STR0016, "ESTIMG32", "ESTIMG32"})	
                	
// SIGACOM - Compras
Aadd(aModules, {CodeCargo(02, NODE_TYPE_MODULE), STR0017, "COMIMG32", "COMIMG32"})

// SIGAFAT - Faturamento
Aadd(aModules, {CodeCargo(05, NODE_TYPE_MODULE), STR0018, "FATIMG32", "FATIMG32"})	

// SIGAFIN - Financeiro
Aadd(aModules, {CodeCargo(06, NODE_TYPE_MODULE), STR0019, "FINIMG32", "FINIMG32"})

// SIGAATF - Ativo Fixo
Aadd(aModules, {CodeCargo(01, NODE_TYPE_MODULE), STR0020, "ATFIMG32", "ATFIMG32"})

// SIGAFIS - Fiscal
Aadd(aModules, {CodeCargo(09, NODE_TYPE_MODULE), STR0021, "FISIMG32", "FISIMG32"})

// SIGAGPE - Folha de Pagamento
Aadd(aModules, {CodeCargo(07, NODE_TYPE_MODULE), STR0022, "GPEIMG32", "GPEIMG32"})               
                
// SIGATMS - Gestใo de Transportes
Aadd(aModules, {CodeCargo(43, NODE_TYPE_MODULE), STR0044, "TMSIMG32", "TMSIMG32"})

// SIGAPMS - Gestใo de Projetos
Aadd(aModules, {CodeCargo(44, NODE_TYPE_MODULE), STR0023, "PMSIMG32", "PMSIMG32"})

// SIGAGAV - Gestใo Advocaticia
Aadd(aModules, {CodeCargo(65, NODE_TYPE_MODULE), STR0024, "GAVIMG32", "GAVIMG32"})
                
// SIGAGCT - Gestใo de Contratos
Aadd(aModules, {CodeCargo(69, NODE_TYPE_MODULE), STR0025, "GCTIMG32", "GCTIMG32"})

// SIGAPLS - Plano de Saude
Aadd(aModules, {CodeCargo(33, NODE_TYPE_MODULE), STR0142, "PLSIMG32", "PLSIMG32"}) //"Plano de Saude"

// SIGAJUR - Juridico
Aadd(aModules, {CodeCargo(76, NODE_TYPE_MODULE), STR0164, "GAVIMG32", "GAVIMG32"}) //"Jurํdico"

// SIGAPFS - Pr้-Faturamento de Servi็os
Aadd(aModules, {CodeCargo(77, NODE_TYPE_MODULE), STR0177, "GAVIMG32", "GAVIMG32"}) //"Pr้-Faturamento de Servi็os"

// SIGACTB - Contabilidade Gerencial
Aadd(aModules, {CodeCargo(34, NODE_TYPE_MODULE), STR0026, "CTBIMG32", "CTBIMG32"})

// SIGATUR - Turismo
Aadd(aModules, {CodeCargo(89, NODE_TYPE_MODULE), STR0169, "AVIAO", "AVIAO"})	//"Gestใo de Viagens e Turismo"

// ordena por descri็ใo
If mv_par02 == 1
	aModules := Asort(aModules, , , {|x, y| x[2] < y[2]})
Endif

Return aModules

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetProcessบAutor  ณAdriano Ueda        บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetProcesses(nModule)
Local aArea := GetArea()
Local aAreaCVJ := CVJ->(GetArea())  

Local aProcesses := {}
Local cModule := StrZero(nModule, 2)

dbSelectArea("CVJ")
CVJ->(dbSetOrder(2))
CVJ->(MsSeek(xFilial("CVJ") + cModule))

While !CVJ->(Eof()) .And. CVJ->CVJ_FILIAL == xFilial("CVJ") .And. CVJ->CVJ_MODULO == cModule

	Aadd(aProcesses, {CodeCargo(CVJ->(Recno()), NODE_TYPE_PROCESS) , CVJ->CVJ_DESCRI, IMG_COL_PROCESS, IMG_EXP_PROCESS})
	
	CVJ->(dbSkip())	
End

// ordena por descri็ใo
If MV_PAR03 == 1
	aProcesses := Asort(aProcesses, , , {|x, y| x[2] < y[2]})
Endif                       

// adiciona o processo "Nใo classificados"
Aadd(aProcesses, {CodeCargo(nModule, NODE_TYPE_PROCESS + NODE_TYPE_UNCLASSIFIED) , STR0027, IMG_COL_PROCESS, IMG_EXP_PROCESS})
		
RestArea(aAreaCVJ)	
RestArea(aArea)

Return aProcesses

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetOperat บAutor  ณAdriano Ueda        บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetOperations(cProcess, cModule)
Local aArea := GetArea()
Local aAreaCVG := CVG->(GetArea())

Local aOperations := {}
Default cModule := ""

dbSelectArea("CVG")
CVG->(dbSetOrder(1))
CVG->(MsSeek(xFilial("CVG") + cProcess))

While !CVG->(Eof()) .And. CVG->CVG_FILIAL == xFilial("CVG") .And. CVG->CVG_PROCES == cProcess
    
	//Se for modulo ativo fixo e processo 110/440/450/490 nao carrega as operacoes abaixo pois sใo do estoque
	If Ctb86Exc( CVG->CVG_PROCES, cModule, CVG->CVG_OPER)
		CVG->( dbSkip() )
		Loop
	EndIf

	Aadd(aOperations, {CodeCargo(CVG->(Recno()), NODE_TYPE_OPERATION) , CVG->CVG_DESCRI, IMG_COL_OPERATION, IMG_EXP_OPERATION})
	
	CVG->(dbSkip())	
End

// ordena por descri็ใo
If MV_PAR04 == 1
	aOperations := Asort(aOperations, , , {|x, y| x[2] < y[2]})
Endif	

RestArea(aAreaCVG)
RestArea(aArea)

Return aOperations


/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetEntriesบAutor  ณAdriano Ueda        บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GetEntries(cProcess, cOperation)
Local aArea 	:= GetArea()
Local aAreaCT5  := CT5->(GetArea())
Local aAreaCVI  := CVI->(GetArea())
Local cDesc		:= ""
Local aEntries 	:= {}
Local cFilCVI	:= xFilial("CVI")
Local cFilCT5	:= xFilial("CT5")

dbSelectArea("CT5")
CT5->(dbSetOrder(1))

// seleciona amarra็๕es
dbSelectArea("CVI")
CVI->(dbSetOrder(3))
CVI->(MsSeek(xFilial("CVI") + cProcess + cOperation))

While !CVI->(Eof()) .And. CVI->CVI_FILIAL == cFilCVI .And. CVI->CVI_PROCESS = cProcess .And. CVI->CVI_OPER == cOperation
	
	// define a descri็ใo padrใo do item a ser inserido
	cDesc := ""

	If CT5->( DbSeek( cFilCT5 + CVI->CVI_LANPAD + CVI->CVI_SEQLAN ) )  	
		cDesc := CT5->CT5_LANPAD + "-" + CT5->CT5_DESC
	Else
		cDesc := STR0028 + " " + CVI->CVI_LANPAD + "-" + CVI->CVI_SEQLAN
	EndIf
	
	Aadd(aEntries,	{ CodeCargo( CVI->(Recno()) , NODE_TYPE_ENTRY ) ;
					, cDesc ;
					, SetEntryImg( 1 , !CT5->(Found()), CT5->CT5_DC, (CT5->CT5_STATUS=="2"));
					, SetEntryImg( 2 , !CT5->(Found()), CT5->CT5_DC, (CT5->CT5_STATUS=="2"));
					, CT5->CT5_DC;
					})

	CVI->( dbSkip() )
End

// ordena por descri็ใo
If MV_PAR05 == 1       
	aEntries := Asort(aEntries, , , {|x, y| x[2] < y[2]})				
ElseIf MV_PAR05 == 2
	aEntries := Asort(aEntries, , , {|x, y| x[5] < y[5]})	
Endif

RestArea(aAreaCVI)
RestArea(aAreaCT5)	
RestArea(aArea)			

Return aEntries

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetUnEntrieบAutor  ณMicrosiga          บ Data ณ  07/03/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDevolve os CT5 nใo classificados, ou seja, os registros do  บฑฑ
ฑฑบ          ณCT5 que jแ existem na base e nใo foram incluํdo atrav้s do  บฑฑ
ฑฑบ          ณnovo cadastro de lan็amento padrใo.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetUnEntries(nModule)
Local aArea := GetArea()
Local aAreaCT5 := CT5->(GetArea())
Local aAreaCVI := CVI->(GetArea())
Local nX,nY	
Local aEntries 	:= {}
Local aLPs		:= GetProcOper(StrZero(nModule,2))	
Local cFilCT5	:= xFilial("CT5")

For nX := 1 To Len(aLPS)
	For nY	:=	1	To Len(aLPS[nX,5])
		dbSelectArea("CT5")
		CT5->( dbSetOrder(1) )
		CT5->( MsSeek( cFilCT5 + aLPS[nX,5,nY] ) )
		
		While !CT5->(Eof()) .And. CT5->CT5_FILIAL == cFilCT5 .And. CT5->CT5_LANPAD == aLPS[nX,5,nY]
			dbSelectArea("CVI")
			CVI->(dbSetOrder(3))

			If ! CVI->(MsSeek(xFilial("CVI") + aLPS[nX,2] +aLPS[nX,3] + CT5->CT5_LANPAD + CT5->CT5_SEQUEN))
      
				Aadd(aEntries,	{ CodeCargo(CT5->(Recno()), NODE_TYPE_UNCLASSIFIED + NODE_TYPE_ENTRY);
								, CT5->CT5_LANPAD + "-" + CT5->CT5_DESC;
								, SetEntryImg( 1 , .F., CT5->CT5_DC, (CT5->CT5_STATUS=="2"));
								, SetEntryImg( 2 , .F., CT5->CT5_DC, (CT5->CT5_STATUS=="2"));
								, CT5->CT5_DC;
								})
			EndIf

			CT5->(DbSkip())
		Enddo	
	Next
Next

RestArea(aAreaCVI)
RestArea(aAreaCT5)	
RestArea(aArea)

Return aEntries

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChgeHandlerบAutor  ณAdriano Ueda       บ Data ณ  XX/XX/XX   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ChangeHandler(oTree)
Local cCargo := oTree:GetCargo()	
Local nType := DecodeType(cCargo)
Local nRecno := 0

// se estiver atualizando, sai da fun็ใo
If nStatus == STATUS_REFRESH
	Return
EndIf
// passo 1: verificar se existem filhos

// passo 2: verificar se estes filhos jแ foram recuperados,
//          caso contrแrio, recuperar da base. se os filhos
//          jแ foram recuperados, entใo nใo adicionแ-los de
//          novo, pois podem ocorrer repeti็๕es

//
// BUGBUG: se um item estiver sendo editado mas algum
//         dos seus campos estiver falhando na digita็ใo, ie,
//         o usuแrio digitou um c๓digo invแlido, ao selecionar
//         um outro item na แrvore causa a execu็ใo da
//         valida็ใo novamente (pois o campo perdeu o foco) e
//         um erro ้ gerado.
//

CursorWait()

Do Case
	
	Case nType == NODE_TYPE_MODULE

		// se os n๓s jแ nใo foram adicionados
		// adicionar os n๓s
		If !HasChildNodes(oTree)
			aItens := GetProcesses(DecodeRecno(cCargo))
			AddItens(oTree, aItens)
		EndIf

		// altera o texto do m๓dulo
		oSayModule:cCaption := ModuleText(DecodeRecno(cCargo))
		
		// desabilita os bot๕es no sidebar
		aButtonsSidebar[IDX_SB_DELETE]:Disable()
		aButtonsSidebar[IDX_SB_COPY]:Disable()
		aButtonsSidebar[IDX_SB_CUT]:Disable()
		aButtonsSidebar[IDX_SB_PASTE]:Disable()
		aButtonsSidebar[IDX_SB_CREATE]:Disable()
		aButtonsSidebar[IDX_SB_REFRESH]:Enable()

		// seleciona o layout correto para exibi็ใo
		oArea:ShowLayout(LAYOUT_MODULE)

	Case nType == NODE_TYPE_PROCESS

		// decodifica o recno a partir do cargo
		nRecno := DecodeRecno(cCargo)
		
		// posiciona no registro do processo
		dbSelectArea("CVJ")
		CVJ->(dbGoto(nRecno))
			
		If !HasChildNodes(oTree)
			aItens := GetOperations(CVJ->CVJ_PROCES, CVJ->CVJ_MODULO)
			AddItens(oTree, aItens)
		EndIf

		// habilita os bot๕es no sidebar
		aButtonsSidebar[IDX_SB_DELETE]:Disable()
		aButtonsSidebar[IDX_SB_COPY]:Disable()
		aButtonsSidebar[IDX_SB_CUT]:Disable()
		aButtonsSidebar[IDX_SB_CREATE]:Disable()
		aButtonsSidebar[IDX_SB_REFRESH]:Enable()

		If Len(aClipboard) > 0
			If aClipboard[Len(aClipboard) - 1] == "CVG"
				aButtonsSidebar[IDX_SB_PASTE]:Enable()
			EndIf
		EndIf
					
		oProcess:Read()

	Case nType == NODE_TYPE_OPERATION

		// decodifica o recno a partir do cargo
		nRecno := DecodeRecno(cCargo)

		// posiciona no registro da opera็ใo
		dbSelectArea("CVG")
		CVG->(dbGoto(nRecno))

		// recupera as opera็๕es filhas
		If !HasChildNodes(oTree)
			aItens := GetEntries(CVG->CVG_PROCES, CVG->CVG_OPER)
			AddItens(oTree, aItens)
		EndIf

		// habilita os bot๕es no sidebar
		aButtonsSidebar[IDX_SB_DELETE]:Disable()
		aButtonsSidebar[IDX_SB_COPY]:Disable()  // copiar
		aButtonsSidebar[IDX_SB_CUT]:Disable()  // recortar
		aButtonsSidebar[IDX_SB_CREATE]:Enable() // incluir
		aButtonsSidebar[IDX_SB_REFRESH]:Enable()			

		If Len(aClipboard) > 0
			If aClipboard[Len(aClipboard) - 1] == "CVI" .Or. aClipboard[Len(aClipboard) - 1] == "CT5"
				aButtonsSidebar[IDX_SB_PASTE]:Enable()
			EndIf
		EndIf
					
		oOperation:Read()
		
	Case nType == NODE_TYPE_ENTRY
		// a แrvore utiliza o recno CVI, por้m,
		// o painel estแ no CT5
		// decodifica o recno a partir do cargo
		nRecno := DecodeRecno(cCargo)

		// posiciona na tabela de relacionamento
		dbSelectArea("CVI")
		CVI->(dbGoto(nRecno))

		// procura o lan็amento padrใo
		dbSelectArea("CT5")
		CT5->(dbSetOrder(1))

		If CT5->(MsSeek(xFilial("CT5") + CVI->CVI_LANPAD + CVI->CVI_SEQLAN))

			// habilita os bot๕es no sidebar
			aButtonsSidebar[IDX_SB_DELETE]:Enable()
			aButtonsSidebar[IDX_SB_COPY]:Enable()
			aButtonsSidebar[IDX_SB_CUT]:Enable()
			aButtonsSidebar[IDX_SB_PASTE]:Disable()
			aButtonsSidebar[IDX_SB_REFRESH]:Disable()				
			aButtonsSidebar[IDX_SB_CREATE]:Enable()				

			oEntry:Read()
		Else
  		oArea:ShowLayout(LAYOUT_UNKNOWN)	
  	EndIf

	Case nType == NODE_TYPE_UNCLASSIFIED + NODE_TYPE_MODULE
		/*

		// recupera as opera็๕es filhas
		If !HasChildNod(oTree)
			aItens := GetUnEntrie()
			AddItens(oTree, aItens)
		EndIf

		oSayModule:cCaption := ModuleText(DecodeRecno(cCargo))
		
		// desabilita os bot๕es no sidebar
		aButtonsSidebar[IDX_SB_DELETE]:Disable()
		aButtonsSidebar[IDX_SB_COPY]:Disable()
		aButtonsSidebar[IDX_SB_CUT]:Disable()
		aButtonsSidebar[IDX_SB_PASTE]:Disable()
		aButtonsSidebar[IDX_SB_CREATE]:Disable()
		
		oArea:ShowLayout(LAYOUT_MODULE)
		
		*/
	
	Case nType == NODE_TYPE_UNCLASSIFIED + NODE_TYPE_PROCESS

		// recupera as opera็๕es filhas
		If !HasChildNodes(oTree)
			aItens := GetUnEntries(DecodeRecno(cCargo))
			AddItens(oTree, aItens)
		EndIf

		oSayModule:cCaption := ModuleText(00)
		
		// desabilita os bot๕es no sidebar
		aButtonsSidebar[IDX_SB_DELETE]:Disable()
		aButtonsSidebar[IDX_SB_COPY]:Disable()
		aButtonsSidebar[IDX_SB_CUT]:Disable()
		aButtonsSidebar[IDX_SB_PASTE]:Disable()
		aButtonsSidebar[IDX_SB_CREATE]:Disable()
		
		oArea:ShowLayout(LAYOUT_MODULE)

	Case nType == NODE_TYPE_UNCLASSIFIED + NODE_TYPE_ENTRY
	
		// decodifica o recno a partir do cargo
		nRecno := DecodeRecno(cCargo)

		// posiciona no lan็amento padrใo
		dbSelectArea("CT5")
		CT5->(dbGoto(nRecno))

		// habilita os bot๕es no sidebar
		aButtonsSidebar[IDX_SB_DELETE]:Enable()
		aButtonsSidebar[IDX_SB_COPY]:Enable()
		aButtonsSidebar[IDX_SB_CUT]:Enable()
		aButtonsSidebar[IDX_SB_PASTE]:Disable()
		aButtonsSidebar[IDX_SB_CREATE]:Disable()
											
		oEntry:Read()		
				
	Otherwise

		// habilita os bot๕es no sidebar
		aButtonsSidebar[2]:Enable()  // exclusใo
		aButtonsSidebar[4]:Enable()  // copiar
		aButtonsSidebar[5]:Enable()  // recortar

		// contador de objetos	
		//oArea:GetCount(oArea:GetPanel(PANEL_UNKNOWN))	
		
		// nใo hแ nada para fazer
  		oArea:ShowLayout(LAYOUT_UNKNOWN)
  		
EndCase	

CursorArrow()

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRghtClkHdlบAutor  ณAdriano Ueda        บ Data ณ  XX/XX/XX   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RightClickHandler(oTree, oObject1, oObject2, x, y, z)
Local oSidebar := oArea:GetSidebar(SIDEBAR)

Local oMenu := PopupMenu(oTree)
If oMenu <> Nil	
	oMenu:Activate(x - 24, y - 100, oSidebar)
EndIf
Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDblClickHdlบAutor  ณAdriano Ueda       บ Data ณ  XX/XX/XX   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DblClickHandler(oTree)

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHasChildNodบAutor  ณAdriano Ueda       บ Data ณ  XX/XX/XX   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HasChildNodes(oTree)
Return Ascan(oTree:aNodes, {|x| x[1] == oTree:CurrentNodeId}) > 0

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAddItens   บAutor  ณAdriano Ueda       บ Data ณ  XX/XX/XX   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AddItens(oTree, aItens)
Local i := 0

For i := 1 To Len(aItens)
	AddItem(oTree, aItens[i])
Next
Return Nil

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAddItem    บAutor  ณAdriano Ueda       บ Data ณ  XX/XX/XX   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AddItem(oTree, aItem)

oTree:AddItem(aItem[2], aItem[1], aItem[3], aItem[4], 2, ;
              {|| ChangeHandler(oTree) }, ;
              {|| RightClickHandler(oTree) }, ;
              {|| DblClickHandler(oTree) })
Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAddHandler บAutor  ณAdriano Ueda       บ Data ณ  XX/XX/XX   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AddHandler(oTree)
Local nType := DecodeType(oTree:GetCargo())

Do Case

	Case nType == NODE_TYPE_MODULE
		//oProcess:Create()
		
	Case nType == NODE_TYPE_PROCESS
		//oOperation:Create()
		
	Case nType == NODE_TYPE_OPERATION 
		oEntry:Create()
		
	Case nType == NODE_TYPE_ENTRY

		// nใo hแ nada para fazer
		
	Otherwise
		// nใo hแ nada para fazer

EndCase	
Return Nil

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDelHandler บAutor  ณAdriano Ueda       บ Data ณ  XX/XX/XX   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DelHandler(oTree)
Local nType := DecodeType(oTree:GetCargo())

// Apagar todos os n๓s filhos e, somente depois, apagar o item da
// แrvore, pois o objeto XTree jแ exclui os n๓s filhos
// automaticamente.
// Estas opera็๕es devem ser protegidas atrav้s de transa็ใo?
If nType == NODE_TYPE_MODULE	
	// "Nใo ้ possํvel excluir o m๓dulo."
	Alert(STR0029)
Else
	// a chamada de DelNodes() deve ser executada
	// antes da exclusใo do item na แrvore
	IF DelNodes(oTree, oTree:CurrentNodeId)
		oTree:DelItem()
	ENDIF
EndIf

Return Nil

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDelNodes  บAutor  ณAdriano Ueda        บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DelNodes(oTree, cNodeId)
Local aArea := GetArea()
Local aAreaCT5 := CT5->(GetArea())
Local aAreaCVI := CVI->(GetArea())
Local aAreaCVJ := CVJ->(GetArea())
Local aAreaCVG := CVG->(GetArea())
Local cLanPad, cSeqLan

Local i := 0
Local nPos := Ascan(oTree:aNodes, {|x| x[2] == cNodeId})

Local nType := 0
Local nRecno := 0

Local lDel  := .F.
  
//
// Considerar a seguinte situa็ใo: quando a แrvore estแ fechada,
// os n๓s filhos nใo sใo carregados. Assim, o array aNodes nใo possui
// elementos para o n๓ atual.
//
// Neste caso, embora existam registros, estes nใo estใo representados
// na แrvore.
// Deste modo, a exclusใo abaixo falha, pois aNodes estแ vazio.
//

If nPos > 0
	If MsgYesNo(STR0046, STR0047)			 //'Confirma exclusao?'###'Exclusao'
		// deleta os elementos filhos	
		For i := 1 To Len(oTree:aNodes)
			If oTree:aNodes[i][1] == cNodeId
				DelNodes(oTree, oTree:aNodes[i][2])	
			EndIf	
		Next
	
		// deleta o registro da base
		nType := DecodeType(oTree:aCargo[nPos][1])
		nRecno := DecodeRecno(oTree:aCargo[nPos][1])
		
		Do Case
			Case nType == NODE_TYPE_MODULE
				// nใo hแ nada para deleter
	
			Case nType == NODE_TYPE_PROCESS
	
				dbSelectArea("CVJ")
				CVJ->(dbGoto(nRecno))
				
				Reclock("CVJ", .F., .T.)
				dbDelete()
				MsUnlock()
	
			Case nType == NODE_TYPE_OPERATION
			
				dbSelectArea("CVG")
				CVG->(dbGoto(nRecno))
				
				Reclock("CVG", .F., .T.)
				dbDelete()
				MsUnlock()
	
				If APMsgYesNo(STR0046, STR0047)
					lDel := .T. 
				Else	
					lDel := .F. 
				Endif
				
			Case nType == NODE_TYPE_ENTRY
					dbSelectArea("CVI")
					CVI->(dbGoto(nRecno))
					cLanPad := CVI->CVI_LANPAD
					cSeqLan := CVI->CVI_SEQLAN
					// exclui o CT5 tamb้m
					dbSelectArea("CT5")
					CT5->(dbSetOrder(1))
	
					If CT5->(dbSeek(xFilial("CT5") + CVI->CVI_LANPAD + CVI->CVI_SEQLAN))
						If ChkFile("SRV")
	   						If !gpChkPadrao()
				   				Return Nil
						   	EndIf
						EndIf
						CT5->(Reclock("CT5", .F., .T.))
						CT5->(dbDelete())
						CT5->(MsUnlock())
					EndIf
	
					// exclui o relacionamento
					
					dbSelectArea("CVI")
					dbSetOrder(2)
					If dbSeek( xFilial("CVI") + cLanPad + cSeqLan ) 
						While CVI->(! Eof() .And. CVI_FILIAL+CVI_LANPAD+CVI_SEQLAN == xFilial("CVI") + cLanPad + cSeqLan )
							oTree:TreeSeek(CodeCargo(Recno(),NODE_TYPE_ENTRY)	)
							oTree:DelItem()

							CVI->(Reclock("CVI", .F., .T.))
							CVI->(dbDelete())
							CVI->(MsUnlock())
							CVI->(dbSkip())
						EndDo
					EndIf
					dbSelectArea("CVI")
					dbSetOrder(1)
					
			Case nType == NODE_TYPE_ENTRY + NODE_TYPE_UNCLASSIFIED
					dbSelectArea("CT5")
					CT5->(dbGoto(nRecno))
					If !ChkFile("SRV") .Or. gpChkPadrao()
						CT5->(Reclock("CT5", .F., .T.))
						CT5->(dbDelete())
						CT5->(MsUnlock())
					EndIf
			Otherwise
			
				// nใo hแ nada para deletar
	
		EndCase			
	Else
	   	lDel := .F.
	Endif
EndIf	

CVG->(RestArea(aAreaCVG))	
CVJ->(RestArea(aAreaCVJ))
CVI->(RestArea(aAreaCVI))
CT5->(RestArea(aAreaCT5))		
RestArea(aArea)	

Return ( lDel )

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCutHandlerบAutor  ณAdriano Ueda        บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CutHandler(oTree)

Local nType := DecodeType(oTree:GetCargo())
Local nRecno := DecodeRecno(oTree:GetCargo())

//
// Localizar o registro a ser copiado a partir do item selecionado na
// แrvore. Copiar o registro para uma แrea temporแria (nใo ้ possํvel
// acessar, realmente, a แrea de transfer๊ncia atrav้s do Protheus).
// Junto com as informa็๕es copiadas, ้ necessแrio indicar qual o
// tipo de informa็ใo e origem, no caso, qual o alias e o registro
// que foi copiado.
//
Do Case
	Case nType == NODE_TYPE_MODULE
		// nใo ้ possํvel recortar o m๓dulo

	Case nType == NODE_TYPE_PROCESS
		// nใo ้ possํvel recortar o processo

	Case nType == NODE_TYPE_OPERATION
		aClipboard := CopyRec("CVG", nRecno, CLIPBOARD_CUT, oTree:GetCargo()) 

	Case nType == NODE_TYPE_ENTRY 
		// posiciona na tabela de relacionamento
		dbSelectArea("CVI")
		CVI->(dbGoto(nRecno))
		
		// procura o lan็amento padrใo
		dbSelectArea("CT5")
		CT5->(dbSetOrder(1))

		If CT5->(MsSeek(xFilial("CT5") + CVI->CVI_LANPAD + CVI->CVI_SEQLAN))
			aClipboard := CopyRec("CT5", CT5->(Recno()), CLIPBOARD_CUT, oTree:GetCargo())
		EndIf
	
	Case nType == NODE_TYPE_MODULE + NODE_TYPE_UNCLASSIFIED
		// nใo hแ nada para copiar
				
	Case nType == NODE_TYPE_ENTRY + NODE_TYPE_UNCLASSIFIED
		aClipboard := CopyRec("CT5", nRecno, CLIPBOARD_CUT, oTree:GetCargo())
	
	Otherwise
		// nใo hแ nada para deletar

EndCase

// deleta o item
//DelHandler(oTree)	
Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCopyHandlerบAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CopyHandler(oTree)

Local nType := DecodeType(oTree:GetCargo())
Local nRecno := DecodeRecno(oTree:GetCargo())

//
// Localizar o registro a ser copiado a partir do item selecionado na
// แrvore. Copiar o registro para uma แrea temporแria (nใo ้ possํvel
// acessar, realmente, a แrea de transfer๊ncia atrav้s do Protheus).
// Junto com as informa็๕es copiadas, ้ necessแrio indicar qual o
// tipo de informa็ใo e origem, no caso, qual o alias e o registro
// que foi copiado.
//
Do Case
	
	Case nType == NODE_TYPE_MODULE
	
		// nใo hแ nada para copiar

	Case nType == NODE_TYPE_PROCESS

		// nใo hแ nada para copiar

	Case nType == NODE_TYPE_OPERATION
	
		aClipboard := CopyRec("CVG", nRecno, CLIPBOARD_COPY, oTree:GetCargo()) 

	Case nType == NODE_TYPE_ENTRY 

		// posiciona na tabela de relacionamento
		dbSelectArea("CVI")
		CVI->(dbGoto(nRecno))
		
		// procura o lan็amento padrใo
		dbSelectArea("CT5")
		CT5->(dbSetOrder(1))

		If CT5->(MsSeek(xFilial("CT5") + CVI->CVI_LANPAD + ;
		                CVI->CVI_SEQLAN))
		                
			aClipboard := CopyRec("CT5", CT5->(Recno()), ;
			                      CLIPBOARD_COPY, oTree:GetCargo())
		EndIf
	
	Case nType == NODE_TYPE_MODULE + NODE_TYPE_UNCLASSIFIED

		// nใo hแ nada para copiar
				
	Case nType == NODE_TYPE_ENTRY + NODE_TYPE_UNCLASSIFIED
	
		aClipboard := CopyRec("CT5", nRecno, CLIPBOARD_COPY, ;
		                      oTree:GetCargo())
	
	Otherwise
	
		// nใo hแ nada para deletar

EndCase
Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPstHandler บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PasteHandler(oTree)

Local nType := DecodeType(oTree:GetCargo())

If Len(aClipboard) > 0
	Do Case
		
		Case nType == NODE_TYPE_MODULE
		
		Case nType == NODE_TYPE_PROCESS

			oOperation:Paste(aClipboard)
			
		Case nType == NODE_TYPE_OPERATION
		
			oEntry:Paste(aClipboard)
		
		Case nType == NODE_TYPE_ENTRY

		
		Otherwise
		
			// nใo hแ nada para deletar

	EndCase			
EndIf
Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |IsCTBProcesบAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CreateToolbar(cPanelId, aButtons)
Local i := 0

Local aImages := {}
Local aCodeblocks := {}
Local aTips := {}
  
For i := 1 To Len(aButtons)
	Aadd(aImages, aButtons[i][1])
	Aadd(aCodeblocks, aButtons[i][4])
	Aadd(aTips, aButtons[i][5])
Next

oArea:AddButtonBar({aImages, aCodeblocks, aTips})
Return oArea:GetButtonBar(cPanelId)

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |NewSidebar บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o sidebar na แrea oArea. Tamb้m, cria uma barra de    บฑฑ
ฑฑบ          ณ ferramentas com os bot๕es desejados especificados em       บฑฑ
ฑฑบ          ณ aButtons.                                                  บฑฑ
ฑฑบ          ณ Devolve a refer๊ncia para o objeto Sidebar criado.         บฑฑ
ฑฑบ          ณ Restri็ใo: a variแvel aButtonsSidebar deve ser declarado   บฑฑ 
ฑฑบ          ณ como private na fun็ใo chamadora.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CreateSidebar(oArea, aButtons)
Local oSidebar := Nil
//Local aBtSideBar := {}

// adiciona sidebar		
oArea:AddSidebar(35, 1, SIDEBAR)
oSidebar := oArea:GetSidebar(SIDEBAR)

// adiciona janela
oArea:AddWindow(100, CtbGetHeight(100), WND_SIDEBAR, "Sidebar", 1, 1, oSidebar)

// adiciona painel
oArea:AddPanel(100, 100, PANEL_SIDEBAR, CONTROL_ALIGN_ALLCLIENT)
  
// adiciona barra de ferramentas
aButtonsSidebar := CreateToolbar(PANEL_SIDEBAR, aButtons)

// desabilita o botใo de Colar	
aButtonsSidebar[4]:Disable()
Return oSidebar

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |NewModLay  บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria um layout especํfico para mostrar as informa็๕es sobreบฑฑ
ฑฑบ          ณ o m๓dulo selecionado.                                      บฑฑ
ฑฑบ          ณ Devolve a refer๊ncia para o objeto de layout criado.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Restri็ใo: oSayModule deve ser declarado como private na   บฑฑ 
ฑฑบ          ณ fun็ใo chamadora.                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CreateModuleLayout(oArea)
Local oLayout := Nil

// adiciona layout	
oArea:AddLayout(LAYOUT_MODULE)
oLayout := oArea:GetLayout(LAYOUT_MODULE)

// adiciona janela
oArea:AddWindow(100, CtbGetHeight(100), WND_MODULE, "M๓dulo", 2, 3, oLayout)	
               
// adiciona painel
oArea:AddPanel(100, 100, PANEL_MODULE, CONTROL_ALIGN_ALLCLIENT)

// adiciona label
@ 0, 0 Say oSayModule Var "" ;
       Of oarea:GetPanel(PANEL_MODULE) PIXEL HTML 	
oSayModule:Align := CONTROL_ALIGN_ALLCLIENT
Return oLayout

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |NewUnknown บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria um layout contendo uma janela (com o tํtulo de        บฑฑ
ฑฑบ          ณ "Desconhecido") e um painel em branco na แrea oArea.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Devolve a refer๊ncia para o objeto de layout criado.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Restri็๕es: Esta fun็ใo nใo valida a cria็ใo dos objetos,  บฑฑ
ฑฑบ          ณ estando passํvel de erro caso a mesma falhe.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CreateUnknownLayout(oArea)
Local oLayout := Nil

// adiciona layout	
oArea:AddLayout(LAYOUT_UNKNOWN)
oLayout := oArea:GetLayout(LAYOUT_UNKNOWN)

// adiciona janela
oArea:AddWindow(100, CtbGetHeight(100), WND_UNKNOWN, "Desconhecido", 2, 3, oLayout)	

// adiciona painel
oArea:AddPanel(100, 100, PANEL_UNKNOWN, CONTROL_ALIGN_ALLCLIENT)
Return oLayout

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |DecodeType บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Decodifica o cargo cCargo e devolve o tipo de elemento que บฑฑ
ฑฑบ          ณ o mesmo se refere.                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ O cargo deve estar no formato 999999.99, onde os n๚meros   บฑฑ
ฑฑบ          ณ antes do ponto sใo o Recno e os n๚meros depois do ponto    บฑฑ
ฑฑบ          ณ formam o tipo. Exemplo:                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ 12345.67                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Tipo: 67                                                   บฑฑ
ฑฑบ          ณ Recno: 12345                                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Devolve 0 (zero) caso cCargo nใo utilize o formato         บฑฑ
ฑฑบ          ณ especificado acima.                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DecodeType(cCargo)
Local nType := 0

If At( "." , cCargo) > 0
	nType := Val(Substr(cCargo, At(".", cCargo) + 1))
EndIf

Return nType

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |DecodeRecnoบAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Decodifica o cargo cCargo e devolve o tipo de elemento que บฑฑ
ฑฑบ          ณ o mesmo se refere.                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ O cargo deve estar no formato 999999.99, onde os n๚meros   บฑฑ
ฑฑบ          ณ antes do ponto sใo o Recno e os n๚meros depois do ponto    บฑฑ
ฑฑบ          ณ formam o tipo. Exemplo:                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ 12345.67                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Tipo: 67                                                   บฑฑ
ฑฑบ          ณ Recno: 12345                                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Devolve 0 (zero) caso cCargo nใo utilize o formato         บฑฑ
ฑฑบ          ณ especificado acima.                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DecodeRecno(cCargo)
Local nRecno := 0

If At(".", cCargo) > 0
	nRecno := Val(Substr(cCargo, 1, At(".", cCargo) - 1))
EndIf
Return nRecno

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |CodeCargo  บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CodeCargo(nRecno, nType)

Return AllTrim(Str(nRecno)) + "." + AllTrim(Str(nType))

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |ModuleText บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModuleText(nModule)
Local cText := ""

Do Case
	// SIGACOM	
	Case nModule == 02
		cText += STR0048 //"<h1>Compras</h1>"

		cText += STR0049 //"<p>O Ambiente de Compras oferece เ equipe de compras de "
		cText += STR0050 //"uma empresa, condi็๕es de acompanhar e controlar as carteiras "
		cText += STR0051 //"de compras, cota็๕es, pedidos de compras e o recebimento de "
		cText += STR0052 //"materiais, permitindo a reposi็ใo dos estoques em tempo hแbil "
		cText += STR0053 //"e apresentando informa็๕es indispensแveis a uma boa negocia็ใo "
		cText += STR0054 //"com seus fornecedores.</p>"

	// SIGAFAT			
	Case nModule == 05
		cText += STR0055 //"<h1>Faturamento</h1>"

		cText += STR0056 //"<p>Faturamento pode ser definido como a receita bruta "
		cText += STR0057 //"decorrente da venda de mercadorias, de mercadorias e "
		cText += STR0058 //"servi็os e de servi็os de qualquer natureza.</p>"

	// SIGAEST		
	Case nModule == 04
		cText += STR0059 //"<h1>Estoque</h1>"

		cText += STR0060 //"<p>O ambiente Estoque/Custos tem por finalidade principal "
		cText += STR0061 //"o controle de materiais movimentados e armazenados pela sua "
		cText += STR0062 //"empresa, al้m do custo incorrido sobre este material.</p>"

	// SIGAATF
	Case nModule == 01
		cText += STR0063 //"<h1>Ativo Fixo</h1>"

		cText += STR0064 //"<p>O objetivo do ambiente Ativo Fixo ้ controlar "
		cText += STR0065 //"o ativo permanente da empresa.</p>"

		cText += STR0066 //"<p>No ativo permanente estใo as aplica็๕es de recursos "
		cText += STR0067 //"feitas pela empresa em carแter permanente, ora representando "
		cText += STR0068 //"bens adquiridos para uso da empresa como veํculos, m๓veis e "
		cText += STR0069 //"utensํlios, etc, ora representando aplica็๕es de recursos na "
		cText += STR0070 //"compra de a็๕es  ou quotas de outras empresas de carแter "
		cText += STR0071 //"permanente, ou ainda, representando aplica็๕es de recursos em "
		cText += STR0072 //"despesas que devem onerar os resultados de vแrios exercํcios.</p>"

	// SIGAFIN
	Case nModule == 06
		cText += STR0073 //"<h1>Financeiro</h1>"
		
		cText += STR0074 //"<p>O ambiente Financeiro atua como uma ferramenta administrativa "
		cText += STR0075 //"que possibilita o acompanhamento dos eventos financeiros e "
		cText += STR0076 //"recursos de uma empresa.</p>"

	// SIGAFIS			
	Case nModule == 09
		cText += STR0077 //"<h1>Fiscal</h1>"
		
		cText += STR0078 //"<p>O ambiente de Livros Fiscais permite emitir os Livros Fiscais "
		cText += STR0079 //"no regime 'Especial' via processamento eletr๔nico de dados, por "
		cText += STR0080 //"meio magn้tico de armazenagem de dados, a partir das Notas Fiscais "
		cText += STR0081 //"de Compra (Entradas) e das Notas Fiscais de Saํda (Saํdas)</p>"

	// SIGAGPE		
	Case nModule == 07
	
		cText += STR0082 //"<h1>Gestใo de Pessoal</h1>"

		cText += STR0083 //"<p>O Ambiente Gestใo de Pessoal faz parte do Protheus, "
		cText += STR0084 //"destinando-se ao controle e automa็ใo das atividades relacionadas "
		cText += STR0085 //"a administra็ใo de pessoal, tais como a folha de pagamento, "
		cText += STR0086 //"tributos incidentes sobre a folha, f้rias, rescisใo contratual e "
		cText += STR0087 //"obriga็๕es anuais.</p>"

	// SIGAGCT			
	Case nModule == 69
		cText += STR0088 //"<h1>Gestใo de Contratos</h1>"
		
		cText += STR0089 //"<p>O ambiente SIGAGCT (Gestใo de Contratos) ger๊ncia os contratos "
		cText += STR0090 //"de compras que a empresa mant้m com seus fornecedores, "
		cText += STR0091 //"possibilitando controlar e acompanhar todos os processos de "
		cText += STR0092 //"contrata็ใo de produtos e/ou servi็os detalhando suas "
		cText += STR0093 //"especifica็๕es.</p>"

	// SIGAPMS
	Case nModule == 44
		cText += STR0094 //"<h1>Gestใo de Projetos</h1>"
		
		cText += STR0104 //"<p>O Ambiente Project Management System (Gestใo de Projetos), do Protheus, "
		cText += STR0105 //"automatiza o gerenciamento de projetos em todas as suas etapas. Do planejamento "
		cText += STR0106 //"เ conclusใo, cada passo do projeto serแ monitorado.</p>"

		cText += STR0107 //"<p>Sejam projetos em pequena ou em grande escala, como organizar uma feira de "
		cText += STR0108 //"com้rcio ou construir uma fแbrica, ou projetos internos, requerem o planejamento "
		cText += STR0109 //"de todas as atividades envolvidas, detalhadamente.</p>"

	// SIGAGAV
	Case nModule == 65
  		cText += STR0095 //"<h1>Gestใo Advocaticia</h1>"

		cText += STR0126 //"<p>Os escrit๓rios de advocacia estใo transformando-se em grandes empresas "
		cText += STR0127 //"prestadoras de servi็os.</p>"

		cText += STR0128 //"<p>A remunera็ใo dos profissionais nใo ้ mais o ponto focal, fazendo do faturamento, "
		cText += STR0129 //"das formas de negocia็ใo com os clientes e da cobran็a os pontos cruciais na "
		cText += STR0130 //"administra็ใo desse segmento.</p>"

		cText += STR0131 //"<p>Como conseqÿ๊ncia, surgiram necessidades tํpicas de grandes empresas, tais como, "
		cText += STR0132 //"agilidade na emissใo de faturas, o comando da situa็ใo financeira e contแbil, "
		cText += STR0133 //"o desempenho de seus colaboradores, bem como a anแlise da produtividade.</p>"

		cText += STR0134 //"<p>Os apontamentos de horas e despesas, despendidas com os assuntos consultivos e "
		cText += STR0135 //"contenciosos, sใo cada vez emlhores gerenciados para que se obtenha o mแximo "
		cText += STR0136 //"de rentabilidade.</p>"

		cText += STR0137 //"<p>Neste cenแrio, um sistema de informa็๕es integrado ้ a solu็ใo responsแvel por "
		cText += STR0138 //"manter um ambiente de colabora็ใo, proporcionar acesso seguro e rแpido aos dados e "
		cText += STR0139 //"melhorar as rela็๕es com os clientes atribuindo maior rapidez e precisใo เs informa็๕es.</p>"

		cText += STR0140 //"<p>Para suprir e atender a tais necessidades, a Microsiga desenvolveu a Solu็ใo Protheus 10 - "
		cText += STR0141 //"Gestใo Advocatํcia, que traz mais confiabilidade e agilidade aos processos de gestใo.</p>"
	
	// Plano de Saude
	Case nModule == 33
		cText += STR0143 //"<h1>Gestใo de Planos de Sa๚de</h1>"

		cText += STR0144 //"<p>O Protheus 10 Gestใo de Planos de Sa๚de foi desenvolvido para os "
		cText += STR0145 //"segmentos de cooperativas m้dicas e odontol๓gicas, autogestใo, medicina "
		cText += STR0146 //"de grupo e seguradoras, atendendo toda เ regulamenta็ใo da Lei 9.656 "
		cText += STR0147 //"e contemplando todas as exig๊ncias da Ag๊ncia Nacional Suplementar (ANS).</p>"

		cText += STR0148 //"<p>Integra็ใo เs demais funcionalidades do Protheus 10, "
		cText += STR0149 //"a solu็ใo Gestใo de Planos de Sa๚de disp๕e de todos os recursos necessแrios "
		cText += STR0150 //"para o perfeito gerenciamento dos processos, tornando mais eficiente e competitiva "
		cText += STR0151 //"a administra็ใo das empresas do setor.</p>"

		cText += STR0152 //"<p>Tendo como caracterํstica um alto poder de parametriza็ใo, a solu็ใo permite grande "
		cText += STR0153 //"flexibilidade para defini็ใo de coberturas, car๊ncias, taxas de pre็os de planos, "
		cText += STR0154 //"formas de cobran็a e regras negociadas com as diversas classes de prestadores, "
		cText += STR0155 //"como m้dicos, clํnicas, hospitais e laborat๓rios, sendo que tais parametriza็๕es "
		cText += STR0156 //"podem ocorrer em diversos nํveis, permitindo tanto a cria็ใo de regras gen้ricas "
		cText += STR0157 //"para toda a empresa quanto regras especํficas (at้ o nํvel de beneficiแrio).</p>"

		cText += STR0158 //"<p>As funcionalidades do Protheus 10 ÿ Gestใo de Planos de Sa๚de t๊m como principais "
		cText += STR0159 //"objetivos prover a empresa com ferramentas para aumentar a produtividade em atividades "
		cText += STR0160 //"operacionais como credenciamento de rede de prestadores, gestใo de vendas e contratos, "
		cText += STR0161 //"processos de atendimento e autoriza็๕es, gerando informa็๕es on-line de todo o hist๓rico "
		cText += STR0162 //"do beneficiแrio, do prestador e dos procedimentos.</p>"
		
	// SIGACTB
	Case nModule == 34
		cText += STR0110 //"<h1>Contabilidade Gerencial</h1>"
		
		cText += STR0111 //"<p>A Contabilidade ้ um instrumento da administra็ใo e, para ser ๚til, "
		cText += STR0112 //"deve adaptar-se เs suas necessidades. A complexidade da tomada de decis๕es "
		cText += STR0113 //"nos neg๓cios da empresa acarretou o uso sistemแtico da contabilidade para "
		cText += STR0114 //"controle e planejamento administrativos. Bem utilizadas, as demonstra็๕es "
		cText += STR0115 //"contแbeis constituem a base mais completa de informa็ใo, uma vez que, por "
		cText += STR0116 //"meio delas, ้ possํvel identificar os pontos fracos da estrutura "
		cText += STR0117 //"econ๔mico-financeira da empresa, proporcionando uma visใo resumida do "
		cText += STR0118 //"resultado dos neg๓cios e da situa็ใo patrimonial e servindo de base para "
		cText += STR0119 //"exercer a a็ใo corretiva de qualquer controle adequado.</p>"
		
		cText += STR0120 //"<p>Esta pasta cont้m os lan็amentos padrใo com c๓digo menor que 500</p>"

	// SIGATMS		
	Case nModule == 43
		cText += STR0121 //"<h1>Gestใo de Transportes</h1>"
		
		cText += STR0122 //"<p>O ambiente SIGATMS (Gestใo de Transportes) controla todos os processos "
		cText += STR0123 //"de um transportador, abrangendo as แreas: operacional, comercial, seguros, "
		cText += STR0124 //"faturamento, logํstica e SAC. Solu็ใo totalmente integrada com a แrea "
		cText += STR0125 //"administrativa (financeiro, fiscal e contแbil)."
		
	// SIGAJURI / SIGAPFS
	Case nModule == 76 .Or. nModule == 77
		cText += STR0165 //"<h1>Jurํdico</h1>"
		
		cText += STR0126 //"<p>Os escrit๓rios de advocacia estใo transformando-se em grandes empresas "
		cText += STR0127 //"prestadoras de servi็os.</p>"

		cText += STR0128 //"<p>A remunera็ใo dos profissionais nใo ้ mais o ponto focal, fazendo do faturamento, "
		cText += STR0129 //"das formas de negocia็ใo com os clientes e da cobran็a os pontos cruciais na "
		cText += STR0130 //"administra็ใo desse segmento.</p>"

		cText += STR0131 //"<p>Como conseqÿ๊ncia, surgiram necessidades tํpicas de grandes empresas, tais como, "
		cText += STR0132 //"agilidade na emissใo de faturas, o comando da situa็ใo financeira e contแbil, "
		cText += STR0133 //"o desempenho de seus colaboradores, bem como a anแlise da produtividade.</p>"

		cText += STR0134 //"<p>Os apontamentos de horas e despesas, despendidas com os assuntos consultivos e "
		cText += STR0135 //"contenciosos, sใo cada vez emlhores gerenciados para que se obtenha o mแximo "
		cText += STR0136 //"de rentabilidade.</p>"

		cText += STR0137 //"<p>Neste cenแrio, um sistema de informa็๕es integrado ้ a solu็ใo responsแvel por "
		cText += STR0138 //"manter um ambiente de colabora็ใo, proporcionar acesso seguro e rแpido aos dados e "
		cText += STR0139 //"melhorar as rela็๕es com os clientes atribuindo maior rapidez e precisใo เs informa็๕es.</p>"

		cText += STR0166 //"<p>O ambiente Juridico atende as exigencias do legislativo do pais, "
		cText += STR0167 //"leva a empresa, cujo o Know-How nใo ้ o Direito, a informatiza็ใo "
		cText += STR0168 //"do judiciแrio, sem depender da consultoria de advocacia tercerizados.</p>"

	Case nModule == 89
		cText += STR0170 //"<h1>Gestใo de Viagens e Turismo</h1>"
		
		cText += STR0171 //"<p>O M๓dulo de Gestใo de Viagens e Turismo foi desenvolvido para permitir "
		cText += STR0172 //"a gestใo integrada de uma ag๊ncia de viagens desde seu processo comercial, "
		cText += STR0173 //"controle dos acordos com clientes e fornecedores, bem como suas metas.  "
		cText += STR0174 //"Importa็ใo e concilia็ใo de fatura, apura็ใo de receita de clientes, "
		cText += STR0175 //"fornecedores e suas metas e o Faturamento de receita e servi็os de "
		cText += STR0176 //"forma integrada com o backoffice do Microsiga Protheus.</p>"		

	// Nใo classificados
	Case nModule == 00
		cText += STR0096 //"<h1>Nใo classificados</h1>"
		
		cText += STR0097 //"<p>Nesta pasta encontram-se os lan็amentos padr๕es que nใo foram "
		cText += STR0098 //"classificados. Para fazer uma classifica็ใo automaticamente, acesse as perguntas "
		cText += STR0099 //"da rotina (tecla de fun็ใo F12), marque a sexta pergunta com SIM, e acesse novamente."
		cText += STR0100 //"A pergunta pode ser desligada depois da classifica็ใo.</p>"
		
	Otherwise
		cText += STR0101 //"<h1>Desconhecido</h1>"
		
EndCase

Return cText

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |CreateGet  บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CreateGet(cAlias, nRecno, nOption, nOption2, oPanel)

Local oGet 		:= Nil
Local oScroll

Private aTela[0][0]
Private aGets[0]

//Monta Scroll
oScroll := TScrollBox():New(oPanel,01,01,640,390)
oScroll:Align := CONTROL_ALIGN_ALLCLIENT

oGet := MsMGet():New(cAlias, nRecno, nOption, , , , , ;
						{12, 0, 640, 390}, , nOption2, , , , ;
						oScroll, , , .F.)

oGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

If oGet == Nil
	MsgStop(STR0030) //"Erro na cria็ใo da MsMGet."
EndIf	

Return oGet


/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |PopUpMenu  บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PopupMenu(oTree)

Local oMenu := Nil
Local cCargo := oTree:GetCargo()	
Local nType := DecodeType(cCargo)

Do Case
	Case nType == NODE_TYPE_MODULE
		// sem menu
					
	Case nType == NODE_TYPE_PROCESS
	
/*			Menu oMenu Popup  
			// "Incluir Opera็ใo"
			MenuItem STR0031 Block {|| oOperation:Create()} Resource  IMG_CREATE
			
			//MenuItem "Colar Opera็ใo" Block {|| oOperation:Paste(aClipboard)} Resource IMG_PASTE
			
			//MenuItem "___________________" Disabled
			
			//MenuItem "Importar Opera็ใo" Block {|| ImportOperation()}
		EndMenu
*/		
	Case nType == NODE_TYPE_OPERATION

		Menu oMenu Popup
			
			//"Editar"
			MenuItem STR0032 Block {|| oOperation:Update()} Resource IMG_UPDATE
			
			//"Excluir" 				
//				MenuItem STR0033 Block {|| DelHandler(oTree)} Resource IMG_DELETE
			
			//MenuItem "___________________" Disabled
			//MenuItem "Recortar" Block {|| CutHandler(oTree)}
			//MenuItem "Copiar" Block {|| CopyHandler(oTree)}
			MenuItem "___________________" Disabled

			//"Incluir Lan็amento"
			MenuItem STR0034  Block {|| oEntry:Create()} Resource IMG_CREATE

			//"Colar Lan็amento"
			MenuItem STR0035 Block {|| oEntry:Paste(aClipboard)} Resource IMG_PASTE
			//MenuItem "Colar Vํnculo" Block {|| oEntry:PasteLink(aClipboard)}
			
			//"Colar Estorno"
			MenuItem STR0036 Block {|| oEntry:PasteReversal(aClipboard)} Resource IMG_PASTE
			MenuItem "___________________" Disabled
			//"Importar Lan็amento"
			MenuItem STR0037 Block {|| oOperation:ReadLPs()} Resource IMG_CREATE
		EndMenu		
	
	Case nType == NODE_TYPE_ENTRY

		Menu oMenu Popup
			//"Editar"
			MenuItem STR0032  Block {|| oEntry:Update()} Resource IMG_UPDATE
			
			//"Excluir"
			MenuItem STR0033 Block {|| DelHandler(oTree)} Resource IMG_DELETE
			MenuItem "___________________" Disabled

			//"Recortar"
			MenuItem STR0038 Block {|| CutHandler(oTree)} Resource IMG_CUT
			
			// "Copiar" 
			MenuItem STR0039 Block {|| CopyHandler(oTree)} Resource IMG_COPY
		EndMenu
		
	Otherwise
	
		// sem menu	

EndCase

Return oMenu

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |GetByRecno บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetValByRecno(cAlias, nRecno, cField, xDefValue)
Local aArea      := GetArea()
Local aAreaAlias := (cAlias)->(GetArea())
Local uBuffer    := Nil  // valor a ser devolvido

Default xDefValue := Nil

uBuffer := xDefValue

dbSelectArea(cAlias)
(cAlias)->(dbGoto(nRecno))

If !(cAlias)->(Eof())
	uBuffer := (cAlias)->(FieldGet(FieldPos(cField)))	
EndIf

(cAlias)->(RestArea(aAreaAlias))
RestArea(aArea)
Return uBuffer

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |CopyRec    บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRestri็ใo: as posi็๕es dos campos da tabela destino devem   บฑฑ
ฑฑบ          ณser as mesmas na tabela origem.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CopyRec(cAlias, nRecno, nOperation, cCargo)
Local i := 0
Local aRecord := {}

Local aArea := GetArea()
Local aAreaAlias := (cAlias)->(GetArea())

Default nOperation := CLIPBOARD_COPY	

dbSelectArea(cAlias)
(cAlias)->(dbGoto(nRecno))

// inclui o alias e o recno de origem
For i := 1 To (cAlias)->(FCount())
	Aadd(aRecord, (cAlias)->(FieldGet(i)))
Next

Aadd(aRecord, cCargo)
Aadd(aRecord, nOperation)
Aadd(aRecord, cAlias)
Aadd(aRecord, nRecno)	

(cAlias)->(RestArea(aAreaAlias))
RestArea(aArea)
Return aRecord

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |GetFieldPosบAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRestri็ใo: as posi็๕es dos campos da tabela destino devem   บฑฑ
ฑฑบ          ณser as mesmas na tabela origem.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetFromFieldPos(nFieldPos)

If nFieldPos > 0
	If nFieldPos <= Len(aClipboard)
		Return aClipboard[nFieldPos]
	EndIf
EndIf
Return Nil

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |ImpOperat  บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRestri็ใo: as posi็๕es dos campos da tabela destino devem   บฑฑ
ฑฑบ          ณser as mesmas na tabela origem.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ImportOperation()
Return                                          


/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |SetFont    บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfigura a fonte padrใo utilizada para o cadastro de       บฑฑ
ฑฑบ          ณlan็amento padrใo.                                          บฑฑ
ฑฑบ          ณRecebe o nome da fonte cFontName a ser utilizada.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณDevolve a refer๊ncia para o objeto de fonte criado.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SetFont(cFontName)

Local oFont := Nil

Define Font oFont Name cFontName Size 0, -8

SetDefFont(oFont)

Return oFont

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |RefreshTreeบAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ															  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RefreshTree(oTree,cCargo)
Local aQueue := {}
Local i := 0

Default cCargo := ""

oTree:BeginUpdate()
nStatus := STATUS_REFRESH

EnqueueNodes(oTree, oTree:CurrentNodeId, aQueue)	

For i := 1 To Len(aQueue)
	If oTree:TreeSeek(aQueue[i])
		oTree:DelItem()
	EndIf
Next	

nStatus := STATUS_UNKNOWN

oTree:EndUpdate()
oTree:Refresh()
Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |ListaNodes บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ															  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EnqueueNodes(oTree, cNodeId, aQueue)
Local i := 0
Local nPos := Ascan(oTree:aNodes, {|x| x[2] == cNodeId})


  
//
// Considerar a seguinte situa็ใo: quando a แrvore estแ fechada,
// os n๓s filhos nใo sใo carregados. Assim, o array aNodes nใo possui
// elementos para o n๓ atual.
//
// Neste caso, embora existam registros, estes nใo estใo representados
// na แrvore.
// Deste modo, a exclusใo abaixo falha, pois aNodes estแ vazio.
//

If nPos > 0

	// deleta os elementos filhos	
	For i := 1 To Len(oTree:aNodes)
		If oTree:aNodes[i][1] == cNodeId
			EnqueueNodes(oTree, oTree:aNodes[i][2], aQueue)	
	
			Aadd(aQueue, oTree:aCargo[i][1])
		EndIf	
	Next
EndIf

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |IsValidEntrบAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function IsValidEntry(cProcess, cOperation, cEntry)

Local lIsValid := .F.

Local nProcPos := 0
Local nEntryPos := 0

If __aProcs == Nil
	__aProcs := GetProcOper()
Endif

IF IsGPEProces(cProcess) .Or. IsCTBProces(cProcess)
	// processos de exessใo nใo serใo tratados neste momento
	nProcPos := 0   
	lIsValid := .T.
Else
	// localiza o primeiro processo	
	nProcPos :=	Ascan(__aProcs, {|x| x[2]+x[3] == Upper(AllTrim(cProcess))+Upper(AllTrim(cOperation)) })
EndIf

If nProcPos > 0
	// continua a procura nos processos seguintes,
	// enquanto for o mesmo processo
	While nProcPos <= Len(__aProcs) .And. Upper(AllTrim(__aProcs[nProcPos][2])) == Upper(AllTrim(cProcess))

		// procura pelo lan็amento
		nEntryPos := Ascan(__aProcs[nProcPos][5], {|x| Upper(AllTrim(x)) == Upper(AllTrim(cEntry)) })

		// se encontrado, verifica se ้ necessario
		// validar tamb้m a opera็ใo		  
		If nEntryPos > 0

			// verifica se ้ necessแrio validar a opera็ใo
			If __aProcs[nProcPos][4]
				// validar tamb้m a opera็ใo								
				lIsValid := ( Upper(AllTrim(__aProcs[nProcPos][3])) == Upper(AllTrim(cOperation))  .or. empty(__aProcs[nProcPos][3]) )
			Else
				lIsValid := .T.
		  	EndIf
		  
			Exit
		EndIf
		
		nProcPos++
	End		
EndIf

Return lIsValid

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |SetEntryImgบAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine a imagem do item, dependendo do tipo de lan็amento   บฑฑ
ฑฑบ          ณ(d้bito, cr้dito ou ambos)								  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SetEntryImg(nType, lDesconhecido, cTipo, lInAtivo)
Local cRet	:=	IMG_NO_ENTRY

If lDesconhecido
	cRet	:= IMG_NO_ENTRY
Else
    If lInAtivo
		//Debito
		If cTipo == '1'   
			IF nType == 1
				cRet	:= 	IMG_COL_ENTRY_DEB_PB 
			Else
				cRet	:= 	IMG_EXP_ENTRY_DEB_PB 
			Endif		
		//Credito
		ElseIf cTipo == '2'   
			IF nType == 1
				cRet	:= 	IMG_COL_ENTRY_CRD_PB
			Else
				cRet	:= 	IMG_EXP_ENTRY_CRD_PB 
			Endif		
		//Partida dobrada
		Else
			IF nType == 1
				cRet	:= 	IMG_COL_ENTRY_PART_DOB_PB
			Else
				cRet	:= 	IMG_EXP_ENTRY_PART_DOB_PB
			Endif		
		Endif	
	Else
		//Debito
		If cTipo == '1'   
			IF nType == 1
				cRet	:= 	IMG_COL_ENTRY_DEB 
			Else
				cRet	:= 	IMG_EXP_ENTRY_DEB 
			Endif		
		//Credito
		ElseIf cTipo == '2'   
			IF nType == 1
				cRet	:= 	IMG_COL_ENTRY_CRD
			Else
				cRet	:= 	IMG_EXP_ENTRY_CRD 
			Endif		
		//Partida dobrada
		Else
			IF nType == 1
				cRet	:= 	IMG_COL_ENTRY_PART_DOB
			Else
				cRet	:= 	IMG_EXP_ENTRY_PART_DOB 
			Endif		
		Endif	
	Endif
Endif	

Return cRet

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |aXpesquiTreeบAutor ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta funcao faz a pesquisa dentro do tree				  บฑฑ
ฑฑบ          ณ A pesquisa rแpida faz o seek na tabela e posiciona no tree,บฑฑ
ฑฑบ          ณ  a pesquisa nao rapida mostra uma serie de resultados para บฑฑ
ฑฑบ          ณ o usuario escolher entes de ir para tree.				  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function aXpesquiTree(oTree,lRapida)
Local aParam	:=	{}                 
Local aConfig   := {1}
Aadd(aParam, {3, STR0002, 1, {STR0040, STR0041, STR0042}, 50, , .T.})

If ParamBox(aParam,STR0043,aConfig,,,.F.,90,15) //"Copiar EDT/Tarefa - Opcoes"
	If aConfig[1] == 1
		DbSelectArea('CT5')
		DbSetOrder(2)
		MBRBLIND()
		DbSelectArea('CVI')
		DbSetOrder(2)
		If DbSeek(xFilial()+CT5->CT5_LANPAD+CT5->CT5_SEQUEN)                                                                              
			PosicTree( 1 )
		Endif					
	Else                        
		DbSelectArea('CVG')
		DbSetOrder(1)
		MBRBLIND()
		PosicTree( 2 )
	Endif
Endif            

Return 

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |MBRBLIND   บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MBRBLIND()

AxPesqui()

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |PosicTree  บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PosicTree( nOpcao )
Local aPais:={}
Local lAchou	:=	.F.
Local nNodeType            
Local cCargo
Local nX
//Pesquisa no CT5
If nOpcao == 1 
	cAlias		:=	"CVI"         
	nOrigem		:=	CVI->(Recno())
	nNodeType	:=	NODE_TYPE_ENTRY
ElseIf nOpcao == 2
	cAlias	:=	"CVG"
	nOrigem	:=	CVG->(Recno())
	nNodeType	:=	NODE_TYPE_OPERATION
ElseIf nOpcao == 3
	cAlias	:=	"CVJ"
	nOrigem	:=	CVJ->(Recno())
	nNodeType	:=	NODE_TYPE_PROCESS
Endif

cCargo	:=	CodeCargo((cAlias)->(Recno()),nNodeType)

While !lAchou .And. nNodeType <> -1

	lAchou	:=	oTree:TreeSeek( cCargo )

	If !lAchou    
		Do Case
		Case nNodeType == NODE_TYPE_ENTRY

			cAlias	:=	"CVG"    

			DbSelectArea("CVG")
			DbSetOrder(1)

			IF DbSeek(xFilial()+CVI->CVI_PROCES+CVI->CVI_OPER)
				cCargo 		:=	CodeCargo(CVG->(Recno()),NODE_TYPE_OPERATION)								
				nNodeType	:=	NODE_TYPE_OPERATION	
			Else
				DbSelectArea("CVJ")
				DbSetOrder(1)
				IF DbSeek(xFilial()+CVI->CVI_PROCES)
					cCargo	:=	CodeCargo(Val(CVJ->CVJ_MODULO),	NODE_TYPE_UNCLASSIFIED + NODE_TYPE_MODULE)										
				Endif           
				nNodeType	:=	NODE_TYPE_UNCLASSIFIED + NODE_TYPE_MODULE	
		    Endif

		Case nNodeType == NODE_TYPE_OPERATION  

			cAlias	:=	"CVJ"

			DbSelectArea("CVJ")
			DbSetOrder(1)
			DbSeek(xFilial()+CVG->CVG_PROCES)        

			cCargo	:=	CodeCargo(CVJ->(Recno()),NODE_TYPE_PROCESS)	  
			nNodeType	:=	NODE_TYPE_PROCESS														

		Case nNodeType == NODE_TYPE_PROCESS  
			cCargo		:=	CodeCargo(Val(CVJ->CVJ_MODULO),NODE_TYPE_MODULE)												
			nNodeType	:=	NODE_TYPE_MODULE  

		OtherWise
			nNodeType	:=	-1

		EndCase

		AAdd(aPais,cCargo)
	Endif	
Enddo                   

For nX:= Len( aPais ) TO 1 STEP -1
  	nType 	:= DecodeType(aPais[nX])

	If nType == NODE_TYPE_MODULE
		aItens 	:= GetProcesses(DecodeRecno(aPais[nX]))

	ElseIf nType == NODE_TYPE_PROCESS               
		CVJ->(MsGoTo(DecodeRecno(aPais[nX])))
		aItens 	:= GetOperations(CVJ->CVJ_PROCES, CVJ->CVJ_MODULO)

	ElseIf nType == NODE_TYPE_OPERATION   
		CVG->(MsGoTo(DecodeRecno(aPais[nX])))
		aItens 	:= GetEntries(CVG->CVG_PROCES,CVG->CVG_OPER)

	ElseIf nType == NODE_TYPE_UNCLASSIFIED + NODE_TYPE_MODULE
		aItens	:=	{}	

	Endif		      

	AddItens(oTree, aItens)   

	If nX > 1
		oTree:TreeSeek(aPais[nX-1])
	Endif
Next                        
      
If nOpcao == 1
	oTree:TreeSeek(CodeCargo(nOrigem,NODE_TYPE_ENTRY)	)
	oEntry:READ()

ElseIf nOpcao == 2
	oTree:TreeSeek(CodeCargo(nOrigem,NODE_TYPE_OPERATION)	)
	oOperation:READ()

ElseIf nOpcao == 3
	oTree:TreeSeek(CodeCargo(nOrigem,NODE_TYPE_PROCESS)	)
	oProcess:READ()

Endif	

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |CT52CVI    บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CT52CVI()
Local aProcs	:=	GetProcOper()
Local cCond :=	"("              
Local nX,nY :=	1
Local nNew	:=	0
ProcRegua(Len(aProcs))

For nX := 1 To Len(aProcs) 
	IncProc()

	If IsCTBProces(aProcs[nX,2]) 
		cCond	:=	"% BETWEEN '0  ' AND '499' %"	

	ElseIf IsGPEProces(aProcs[nX,2]) 
		cCond	:=	"% BETWEEN 'A  ' AND 'z  ' %"	

	ElseIf IsPLSProces(aProcs[nX,2]) 
		cCond	:=	"% BETWEEN '9A0' AND '9CZ' %"	

	ElseIf IsJURProces(aProcs[nX,2]) 
		cCond	:=	"% BETWEEN '9D0' AND '9DZ' %"	
	
	ElseIf IsPFSProces(aProcs[nX,2]) 
		cCond	:=	"% BETWEEN '940' AND '964' %"

	Else
		cCond	:=	"IN ("                 

		For nY := 1 To Len(aProcs[nX,5])
			cCond	+=	"'"+aProcs[nX,5,nY]+"',"
		Next nY	                                     
		
		cCond	:=	"%"+Substr(cCond,1,Len(cCond)-1)+")"+ "%"	
	Endif
	
	BeginSql alias 'CT5CVI'
		SELECT CT5_LANPAD, CT5_SEQUEN 
		  FROM %TABLE:CT5% CT5
         WHERE CT5_FILIAL = %XFILIAL:CT5% 
           AND CT5_LANPAD %Exp:cCond%
           AND CT5_SEQUEN||CT5_LANPAD NOT IN (
               SELECT CVI_SEQLAN||CVI_LANPAD 
                 FROM %TABLE:CVI% CVI
                WHERE CVI_FILIAL = %XFILIAL:CVI% 
                  AND CVI_PROCES = %Exp:aProcs[nX,2]% 
                  AND CVI_OPER = %Exp:aProcs[nX,3]% 
                  AND CVI.%NOTDEL%	
                  )
           AND CT5.%NOTDEL%	
         ORDER BY CT5_LANPAD,CT5_SEQUEN
	EndSql
		
	DbSelectArea( 'CT5CVI' )
	DbGoTop()

	While !EOF()    
		nNew++
		RecLock('CVI',.T.)

		CVI->CVI_FILIAL	:=	xFilial()
		CVI->CVI_LANPAD	:=	CT5CVI->CT5_LANPAD
		CVI->CVI_SEQLAN	:=	CT5CVI->CT5_SEQUEN
		CVI->CVI_PROCES	:=  aProcs[nX,2]
		CVI->CVI_OPER	:=  aProcs[nX,3]

		MsUnLock()	    

		DbSelectArea('CT5CVI')
		DbSkip()	
	Enddo                          

	DbCloseArea()
Next nX	         

If nNew > 0
	Conout( STR0102 + Str(nNew) + STR0103 ) //'Acertados '###' Vinculos perdidos na tabela de processos'
Endif

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |GetVldLPs  บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna os Lancamentos padroes validos para um processo ou บฑฑ
ฑฑบ          ณ para um processo/operacao.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GetVldLPs(cModulo,cProc,cOper)
Local aProcs	:=	GetProcOper(cModulo,cProc,cOper)
Local nX	:=	1      
Local aRet := {}
Local nY
For nX:=1 To Len(aProcs) 
	For nY:=1 To Len(aProcs[nX,5]) 
		If Ascan(aRet,aProcs[nX,5,nY]) == 0	
			Aadd(aRet,aProcs[nX,5,nY])  
		Endif	
	Next
Next

Return aRet

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |GetProcOperบAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetProcOper(cModulo,cProc,cOper)
Local	aRet	:=	{}
Local	nPos
Local	aAreaCVA
Local	cOperAux:=Iif(cOper == nil, '   ', cOper)


//Estrutura:
//__aProcs[n,1]:Modulo
//__aProcs[n,2]:Processo
//__aProcs[n,3]:Operacao
//__aProcs[n,4]:Se os lancamentos sao exclusivos da operacao
//____aProcs[n,5]:Lancamentos validos
//                                       `

If __aProcs == Nil
	__aProcs	:=	{}
	
	// SIGAATF	
	AADD(__aProcs,{"01", "010","005",.T.,{"801","802","803","804"}})
	AADD(__aProcs,{"01", "010","010",.T.,{"805","806","807","808"}})
	AADD(__aProcs,{"01", "020","005",.T.,{"821"}})
	AADD(__aProcs,{"01", "020","010",.T.,{"822"}})
	AADD(__aProcs,{"01", "030","005",.T.,{"810","811","812","813"}})
	AADD(__aProcs,{"01", "030","010",.T.,{"814","815","816","817"}})
	AADD(__aProcs,{"01", "040","005",.T.,{"820","823"}})//Cแlculo de deprecia็ใo: rateio de despesas
	AADD(__aProcs,{"01", "040","010",.T.,{"825","828"}})//Estorno do cแlculo da deprecia็ใo: rateio de despesas
	AADD(__aProcs,{"01", "050","005",.T.,{"827"}})
	AADD(__aProcs,{"01", "050","010",.T.,{"845"}})
	AADD(__aProcs,{"01", "050","015",.T.,{"846"}})
	AADD(__aProcs,{"01", "050","020",.T.,{"847"}})
	AADD(__aProcs,{"01", "050","025",.T.,{"848"}})
	AADD(__aProcs,{"01", "060","005",.T.,{"80E","8A6","8A7"}})//Ativo Fixo - Reavalia็ใo
	AADD(__aProcs,{"01", "060","010",.T.,{"80F","8A8","8A9"}})//Ativos Fixos - Estorno de Reavalia็ใo 
	AADD(__aProcs,{"01", "070","005",.T.,{"830","831","832"}})
	AADD(__aProcs,{"01", "080","005",.T.,{"835","836"}})
	AADD(__aProcs,{"01", "110","110",.T.,{"870","871","872","873","874","875","876","877","878","879","87A","87B"}})
	AADD(__aProcs,{"01", "440","440",.T.,{"866"}})
	AADD(__aProcs,{"01", "450","450",.T.,{"860","861","862","863","864","865","867","868"}})
	AADD(__aProcs,{"01", "490","490",.T.,{"881","882","883","884"}})

	// SIGAEST
	AADD(__aProcs,{"04", "100","005",.T.,{"668"}})
	AADD(__aProcs,{"04", "100","005",.T.,{"67B"}})
	AADD(__aProcs,{"04", "100","010",.T.,{"669"}})
	AADD(__aProcs,{"04", "100","015",.T.,{"679"}})
	AADD(__aProcs,{"04", "100","020",.T.,{"676"}})
	AADD(__aProcs,{"04", "110","005",.T.,{"666"}})
	AADD(__aProcs,{"04", "110","005",.T.,{"67A"}})
	AADD(__aProcs,{"04", "110","010",.T.,{"667"}})
	AADD(__aProcs,{"04", "110","015",.T.,{"680"}})
	AADD(__aProcs,{"04", "110","020",.T.,{"674"}})
	AADD(__aProcs,{"04", "120","005",.T.,{"670","672"}})
	AADD(__aProcs,{"04", "130","005",.F.,{'682','681','641','669','667','668','67B','666','67A','679','680','678','676','674'}})
	
	// SIGAFIS
	If cPaisLoc<>"RUS"
		AADD(__aProcs,{"09", "150","005",.T.,{"606","710","720","750","605","755", "757", "758", "759", "760", "765", "767", "6A7", "6B7", "770"}})
		AADD(__aProcs,{"09", "150","010",.T.,{"608","711","721","751","611","756", "761", "762", "763", "764", "766", "768", "6A8", "6B8", "771"}})
	Else
		AADD(__aProcs,{"09", "150","005",.T.,{"606","710","720","750","605","755", "757", "758", "759", "760", "765", "767", "6A7", "6B7","6AE","6AG","6AI"}})
		AADD(__aProcs,{"09", "150","010",.T.,{"608","711","721","751","611","756", "761", "762", "763", "764", "766", "768", "6A8", "6B8","6AF","6AH","6AJ"}})
	EndIf
	
	// SIGAFIN
	AADD(__aProcs,{"06", "200","001",.T.,{"500","501","504","506"}})
	AADD(__aProcs,{"06", "200","010",.T.,{"503"}})
	AADD(__aProcs,{"06", "200","015",.T.,{"505","502","507","529"}})
	AADD(__aProcs,{"06", "200","020",.T.,{"547","548","549","550","551","552","553","556"}})
	AADD(__aProcs,{"06", "200","025",.T.,{"554"}})
	AADD(__aProcs,{"06", "200","030",.T.,{"595"}})
	AADD(__aProcs,{"06", "200","035",.T.,{"592"}})
	AADD(__aProcs,{"06", "200","040",.T.,{"596"}})
	AADD(__aProcs,{"06", "200","045",.T.,{"588"}})
	AADD(__aProcs,{"06", "200","050",.T.,{"5BN","5BO","5BP","5BQ","5BR","5B5","5BT","5BU","5BV","5BX","5BW","5BY","5BZ","5C1","5C2","5C3","575"}})
	AADD(__aProcs,{"06", "200","055",.T.,{"571"}})
	AADD(__aProcs,{"06", "200","060",.T.,{"520","521","522","523","524","525","526","528","536"}})
	AADD(__aProcs,{"06", "200","065",.T.,{"527"}})
	AADD(__aProcs,{"06", "200","070",.T.,{"540","541","542","543","544","545","546","54G","54H","555"}})
	AADD(__aProcs,{"06", "200","075",.T.,{"598"}})
	AADD(__aProcs,{"06", "200","080",.T.,{"51A"}})	
	AADD(__aProcs,{"06", "200","040",.T.,{"559"}}) //feito no changeset anterior, subido novamente pois cabe็alhos comentados mudaram o encode.
	AADD(__aProcs,{"06", "250","005",.T.,{"580"}})
	AADD(__aProcs,{"06", "250","010",.T.,{"582","585"}})
	AADD(__aProcs,{"06", "250","015",.T.,{"584","586"}})
	AADD(__aProcs,{"06", "250","020",.T.,{"581"}})
	AADD(__aProcs,{"06", "300","001",.T.,{"510","511","513","508","577"}})
	AADD(__aProcs,{"06", "300","005",.T.,{"533"}})
	AADD(__aProcs,{"06", "300","010",.T.,{"509","512","514","515","578"}})
	AADD(__aProcs,{"06", "300","015",.T.,{"587"}})
	AADD(__aProcs,{"06", "300","020",.T.,{"593"}})
	AADD(__aProcs,{"06", "300","025",.T.,{"590","566","567","569"}})
	AADD(__aProcs,{"06", "300","030",.T.,{"568","591"}})
	AADD(__aProcs,{"06", "300","035",.T.,{"597"}})
	AADD(__aProcs,{"06", "300","040",.T.,{"589"}})
	AADD(__aProcs,{"06", "300","045",.T.,{"5B9","5BA","5BB","5BC","5BD","5BE","5BF","5BG","5BH","5BI","5BJ","5BK","5BL","5BM","570"}})
	AADD(__aProcs,{"06", "300","050",.T.,{"571"}})
	AADD(__aProcs,{"06", "300","055",.T.,{"530","532","537"}})
	AADD(__aProcs,{"06", "300","060",.T.,{"531"}})
	AADD(__aProcs,{"06", "300","065",.T.,{"599"}})
	AADD(__aProcs,{"06", "330","005",.T.,{"594"}})
	AADD(__aProcs,{"06", "350","005",.T.,{"516","562","5C8"}})
	AADD(__aProcs,{"06", "350","010",.T.,{"557","564","5C9"}})
	AADD(__aProcs,{"06", "350","015",.T.,{"563","517"}})
	AADD(__aProcs,{"06", "350","020",.T.,{"558","565"}})
	AADD(__aProcs,{"06", "350","025",.T.,{"560","561"}})
	AADD(__aProcs,{"06", "370","005",.T.,{"572"}})
	AADD(__aProcs,{"06", "370","010",.T.,{"579"}})
	AADD(__aProcs,{"06", "370","010",.T.,{"57E"}})
	AADD(__aProcs,{"06", "370","015",.T.,{"573"}})
	AADD(__aProcs,{"06", "380","005",.T.,{"599"}})
	AADD(__aProcs,{"06", "380","010",.T.,{"59B"}})
	AADD(__aProcs,{"06", "390","005",.T.,{"598"}})
	AADD(__aProcs,{"06", "390","010",.T.,{"59A"}})

	// SIGACOM
	AADD(__aProcs,{"02", "400","005",.T.,{"652"}})
	AADD(__aProcs,{"02", "400","010",.T.,{"657"}})
	AADD(__aProcs,{"02", "410","005",.F.,{"650","651","660","681","682","950","901","903"}})
	AADD(__aProcs,{"02", "410","010",.F.,{"640","641","642","681","682","950","901","903"}})
	AADD(__aProcs,{"02", "410","015",.F.,{"955","655","656","665","902","904"}})
	// Cabec
	AADD(__aProcs,{"02", "410","020",.T.,{"683"}})
	AADD(__aProcs,{"02", "410","025",.T.,{"684","685"}})	
	AADD(__aProcs,{"02", "410","030",.T.,{"686"}})		
	AADD(__aProcs,{"02", "410","035",.T.,{"687"}})
	AADD(__aProcs,{"02", "410","040",.T.,{"688","689"}})	
	AADD(__aProcs,{"02", "410","045",.T.,{"690"}})	 
	//Itens
	AADD(__aProcs,{"02", "410","050",.T.,{"691"}})
	AADD(__aProcs,{"02", "410","055",.T.,{"692","693"}})	
	AADD(__aProcs,{"02", "410","060",.T.,{"694"}})		
	AADD(__aProcs,{"02", "410","065",.T.,{"695"}})
	AADD(__aProcs,{"02", "410","070",.T.,{"696","697"}})	
	AADD(__aProcs,{"02", "410","075",.T.,{"698"}})		
	
	// SIGAFAT
	AADD(__aProcs,{"05", "430","005",.T.,{"612","621"}})
	AADD(__aProcs,{"05", "430","010",.T.,{"632","636"}})

	AADD(__aProcs,{"05", "440","005",.F.,{"610","613","614","620","678"}})
	AADD(__aProcs,{"05", "440","010",.F.,{"630","633","635"}}) 
	//Cabec
	AADD(__aProcs,{"05", "440","015",.T.,{"68A"}})	
	AADD(__aProcs,{"05", "440","020",.T.,{"68B","68C"}})
	AADD(__aProcs,{"05", "440","025",.T.,{"68D"}})
	AADD(__aProcs,{"05", "440","030",.T.,{"68E"}})
	AADD(__aProcs,{"05", "440","035",.T.,{"68F","68G"}})
	AADD(__aProcs,{"05", "440","040",.T.,{"68H"}})  
	//Itens 
	AADD(__aProcs,{"05", "440","045",.T.,{"68I"}})	
	AADD(__aProcs,{"05", "440","050",.T.,{"68J","68K"}})
	AADD(__aProcs,{"05", "440","055",.T.,{"68L"}})
	AADD(__aProcs,{"05", "440","060",.T.,{"68M"}})
	AADD(__aProcs,{"05", "440","065",.T.,{"68N","68O"}})
	AADD(__aProcs,{"05", "440","070",.T.,{"68P"}})	

	// SIGAGCT
	AADD(__aProcs,{"69", "500","005",.T.,{"690"}})
	AADD(__aProcs,{"69", "500","010",.T.,{"691"}})
	AADD(__aProcs,{"69", "500","015",.T.,{"692"}})	
	AADD(__aProcs,{"69", "510","005",.T.,{"693", "69P", "69Q", "69R", "69S"}})
	AADD(__aProcs,{"69", "510","010",.T.,{"694"}})
	AADD(__aProcs,{"69", "520","005",.T.,{"695"}})
	AADD(__aProcs,{"69", "510","015",.T.,{"69G"}})
	AADD(__aProcs,{"69", "510","020",.T.,{"69H"}})
	AADD(__aProcs,{"69", "510","025",.T.,{"69I"}})	
	AADD(__aProcs,{"69", "520","025",.T.,{"69K"}})
	AADD(__aProcs,{"69", "520","025",.T.,{"69L"}})
	AADD(__aProcs,{"69", "520","025",.T.,{"69M"}})
	AADD(__aProcs,{"69", "520","025",.T.,{"69N"}})
	AADD(__aProcs,{"69", "520","025",.T.,{"69O"}})	
	

	// SIGAGPE
	AADD(__aProcs,{"07", "700","005",.T.,{}}) //Todos os alpha

	// SIGAPLS
	AADD(__aProcs,{"33", "9A0","005",.T.,{}})// Todos que iniciam com 9A, 9B e 9C
	// SIGACTB
	AADD(__aProcs,{"34", "750","005",.T.,{}}) //Todos os menores a 500

	// SIGAGAV
	AADD(__aProcs,{"65", "800","005",.T.,{"970","971","972","973"}})
	AADD(__aProcs,{"65", "800","010",.T.,{"974","976","977"}})
	AADD(__aProcs,{"65", "810","005",.T.,{"980","981"}})
	AADD(__aProcs,{"65", "810","010",.T.,{"984","985"}})
  
	// SIGATMS
	AADD(__aProcs,{"43", "490","005",.T.,{"901","903"}})
	AADD(__aProcs,{"43", "490","010",.T.,{"902","904"}})
	
	// SIGAJURI
	AADD(__aProcs,{"76","9D0","005",.T.,{"9D0"}})
	AADD(__aProcs,{"76","9D0","010",.T.,{"9D1"}})
	AADD(__aProcs,{"76","9D0","015",.T.,{"9D2"}})

	// SIGAPFS
	//LP's reservados para PFS - 940 At้ 949 e 956 At้ 964
	AADD(__aProcs,{"77","940","005",.T.,{"940"}})
	AADD(__aProcs,{"77","940","010",.T.,{"941"}})
	AADD(__aProcs,{"77","940","015",.T.,{"942"}})
	AADD(__aProcs,{"77","940","020",.T.,{"943"}})
	AADD(__aProcs,{"77","940","025",.T.,{"944"}})
	AADD(__aProcs,{"77","940","030",.T.,{"945"}})
	AADD(__aProcs,{"77","940","035",.T.,{"946"}})
	AADD(__aProcs,{"77","940","040",.T.,{"947"}})
	AADD(__aProcs,{"77","940","045",.T.,{"948"}})
	AADD(__aProcs,{"77","940","050",.T.,{"949"}})
	AADD(__aProcs,{"77","940","055",.T.,{"956"}})
	AADD(__aProcs,{"77","940","060",.T.,{"957"}})

	// SIGATUR
	AADD(__aProcs,{"89","T00","005",.T.,{"T00"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T01"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T02"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T03"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T04"}})	
	AADD(__aProcs,{"89","T00","005",.T.,{"T05"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T06"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T07"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T08"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T09"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T10"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T11"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T12"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T13"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T14"}})
	AADD(__aProcs,{"89","T00","005",.T.,{"T15"}})		
	
	AADD(__aProcs,{"89","T40","005",.T.,{"T40"}})
	AADD(__aProcs,{"89","T40","005",.T.,{"T41"}})
	AADD(__aProcs,{"89","T40","005",.T.,{"T42"}})
	AADD(__aProcs,{"89","T40","005",.T.,{"T43"}})
	AADD(__aProcs,{"89","T40","010",.T.,{"T44"}})
	AADD(__aProcs,{"89","T40","010",.T.,{"T45"}})
	
	// CVA
	DbSelectArea( 'CVA' )
	aAreaCVA := CVA->(GetArea())
	CVA->(DbSetOrder(1))
	CVA->(DbGoTop())
	CVA->(DbSeek(xFilial('CVA')))
	While CVA->CVA_FILIAL==xFilial('CVA') .and. !CVA->(EOF())
		nPos := Ascan(__aProcs,{|x| x[1]+x[2]+x[3] == CVA->CVA_MODULO+CVA->CVA_PROCES+cOperAux })
		If nPos == 0
			AADD(__aProcs,{CVA->CVA_MODULO, CVA->CVA_PROCES, '   ', .F., {CVA->CVA_CODIGO}})
		Else
			If Ascan(__aProcs[nPos,5], {|x| x == CVA->CVA_CODIGO }) == 0
				AADD(__aProcs[nPos,5], CVA->CVA_CODIGO)
			EndIf
		EndIf
		CVA->(DbSkip())
	Enddo                          
	CVA->(RestArea(aAreaCVA))

	//Fazer o aSort para garantizar que estao ordenados.
	aSort(__aProcs,,,{|x,y| x[1]+x[2]+x[3]<y[1]+y[2]+y[3]})
Endif                                                   

//Se foi solicitado o proceso, so retornar os lancamentos do proceso
If cProc <> Nil .And. cModulo <> Nil
	nPos	:=	Ascan(__aProcs,{|x| x[1]+x[2] == cModulo+cProc })
	If nPos > 0
		While nPos < Len(__aProcs) .And. __aProcs[nPos][1]+__aProcs[nPos][2] == cModulo+cProc
			//Se foi solicitada uma operacao em especial, so retornar esta operacao, 
			//e se estes lancamentos nao sao exclusivos da operacao adiciona-os ao retorno
			If  cOper <> Nil
				If __aProcs[nPos][3] == cOper .or. empty(__aProcs[nPos][3])
					AAdd(aRet,aClone(__aProcs[nPos]))		
				Endif
			Else
				AAdd(aRet,aClone(__aProcs[nPos]))
			Endif
			nPos++
		Enddo
	Endif
ElseIf cModulo <> Nil
	nPos	:=	Ascan(__aProcs,{|x| x[1]== cModulo })
	If nPos > 0
		While nPos < Len(__aProcs) .And. __aProcs[nPos][1] == cModulo
			AAdd(aRet,aClone(__aProcs[nPos]))
			nPos++
		Enddo
	Endif
Else
	aRet	:=	aClone(__aProcs)
Endif      

Return aRet


/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออออหออออัอออออออออออปฑฑ
ฑฑบPrograma  |IsPLSProcesบAutor  ณRenato Ferreira Campos บDataณ 10/06/11  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออออสออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IsPLSProces(cProc)

Return (cProc=="9A0")

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออออหออออัอออออออออออปฑฑ
ฑฑบPrograma  |IsJurProcesบAutor  ณRenato Ferreira Campos บDataณ 07/08/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออออสออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IsJURProces(cProc)

Return (cProc=="9D0")

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออออหออออัอออออออออออปฑฑ
ฑฑบPrograma  |IsPFSProcesบAutor  ณJorge Martins          บDataณ 22/08/18  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออออสออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IsPFSProces(cProc)

Return (cProc=="940")

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |IsGPEProcesบAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IsGPEProces(cProc)

Return (cProc=="700")

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |IsCTBProcesบAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IsCTBProces(cProc)

Return (cProc=="750")

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |CtbGetHght บAutor  ณAdriano Ueda       บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtbGetHeight(nHeight)
Local nFinalHeight := nHeight

// verifica se estแ utilizando o modo MDI
// e calcula uma pequena diferen็a no tamanho,
// para nใo cortar a visualiza็ใo dos bot๕es
If SetMdiChild()
	nFinalHeight := nHeight - 5
EndIf 

Return nFinalHeight


/*/{Protheus.doc} Ctb86Exc
	
Ctb86Exc - Funcao utilizada para verificar alguns processos do ativo que nao se enquadram nas operacoes 
para montagem da arvore de processos corretamente

@type  Function
@author Controladoria
@version
@param 
@return lRet 
/*/

Function Ctb86Exc( cProcess, cModule, cOperation)
Local lRet := .F.  //normalmente retorna falso para nao pular os registros da tabela CVG

//condicoes para nao inserir no modulo ativo fixo algumas operacoes que sao de estoque ou faturamento e vice versa
//operacoes 110 / 440 /450 / 490 sao EXCLUSIVO do ativo fixo portanto em outros modulos nao carregar estas operacoes
If     cProcess == '110' .And. If(cModule == '01', cOperation <> '110', cOperation=='110')
	lRet := .T.
ElseIf cProcess == '440' .And. If(cModule == '01', cOperation <> '440', cOperation=='440')
	lRet := .T.	
ElseIf cProcess == '490' .And. If(cModule == '01', cOperation <> '490', cOperation=='490')
	lRet := .T.	
EndIf

Return(lRet)
