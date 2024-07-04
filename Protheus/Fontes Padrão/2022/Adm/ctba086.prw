#include "protheus.ch"
#include "dbtree.ch"
#include "tbiconn.ch"
#include "ctbarea.ch"
#include "ctba086.ch"         
// 
// Cadastro de Lan�amento Padr�o
// Copyright (C) 2007, Microsiga
// amarracao

Static __aProcs

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBA086   �Autor  �Microsiga           � Data �  07/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTBA086()
Local nWidth	:= GetScreenRes()[IDX_SCREEN_WIDTH] - 40
Local nHeight	:= GetScreenRes()[IDX_SCREEN_HEIGHT] - 200
Local oDlg 		:= Nil
Local aModules	:= {}
Local i 		:= 0
Local aButtons 	:= {}
Local oSidebar 	:= Nil

// WOP: Declarar estas vari�veis como private deixam o c�digo
//      menos robusto e mais acoplado, al�m de causar
//      problemas nas futuras manuten��es do mesmo.
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

//N�o apagar variaveis utilizadas para a contabiliza��o na integra��o TIN X PROTHEUS
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

// Variaveis para contabilizacao Template de Gest�o de Empreendimentos Imobili�rios

TPLNUM    	:= ""
TPLDTCM   	:= CTOD("  /  /  ")
TPLBCMP 	:= 0
TPLBCMJ 	:= 0
TPLCMP    	:= 0
TPLCMJ    	:= 0
TPLCMCUS	:= 0
TPLCMRES    := 0

// o objeto oTree pode ser local, contanto que
// os blocos de c�digos que o usem sejam
// declarados nesta fun��o
Private oTree := Nil

// a �rea deve ser private	
Private oArea := FwArea():New(0, 0, nWidth, nHeight, oDlg, 1, STR0001)

//"Cadastro de Lan�amento Padr�o"	                              
// a cria��o de vari�veis privates � necess�ria
// para a utiliza��o dos objetos j� existentes

// objetos private para o sidebar
Private aButtonsSidebar := {}

// objetos private para o layout de m�dulo	
Private oSayModule 	:= Nil
Private Inclui 		:= .F.
Private Altera 		:= .F.
Private Exclui 		:= .F.
Private oEntry 		:= Nil
Private oProcess 	:= Nil
Private oOperation 	:= Nil
Private aClipboard 	:= {} // "�rea de transfer�ncia"
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

// bot�es do sidebar
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

	// �rvore Xtree
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

	// preenche o XTree com os m�dulos
	For i := 1 To Len(aModules)
	
		// adiciona os m�dulos
		oTree:AddTree(aModules[i][2];
					, aModules[i][3];
					, aModules[i][4];
					, aModules[i][1];
					, {|| ChangeHandler(oTree) };
					, {|x, y, z| RightClickHandler(oTree, , x, y, z) };
					, {|| DblClickHandler(oTree) })
		
		oTree:EndTree()
	Next

	// altera o texto do m�dulo
	If Len(aModules) > 0
		oSayModule:cCaption := ModuleText(DecodeRecno(aModules[1][1]))
	EndIf
	
	// seleciona o layout correto para exibi��o
	oArea:ShowLayout(LAYOUT_MODULE)
				
	// configura as propriedades da �rea
	oArea:Style(oTree)    
	oArea:ActDialog()				
EndIf	

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |GetModules�Autor  �Adriano Ueda        � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function GetModules()

Local aModules := {}                                                      	

//  aModules:
//	
//  01 - ID (string)
//  02 - Descri��o (string)	
//  03 - imagem quando fechado
//  04 - imagem quando aberto

// os c�digos dos m�dulos foram obtidos
// atrav�s do menu

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
                
// SIGATMS - Gest�o de Transportes
Aadd(aModules, {CodeCargo(43, NODE_TYPE_MODULE), STR0044, "TMSIMG32", "TMSIMG32"})

// SIGAPMS - Gest�o de Projetos
Aadd(aModules, {CodeCargo(44, NODE_TYPE_MODULE), STR0023, "PMSIMG32", "PMSIMG32"})

// SIGAGAV - Gest�o Advocaticia
Aadd(aModules, {CodeCargo(65, NODE_TYPE_MODULE), STR0024, "GAVIMG32", "GAVIMG32"})
                
// SIGAGCT - Gest�o de Contratos
Aadd(aModules, {CodeCargo(69, NODE_TYPE_MODULE), STR0025, "GCTIMG32", "GCTIMG32"})

// SIGAPLS - Plano de Saude
Aadd(aModules, {CodeCargo(33, NODE_TYPE_MODULE), STR0142, "PLSIMG32", "PLSIMG32"}) //"Plano de Saude"

// SIGAJUR - Juridico
Aadd(aModules, {CodeCargo(76, NODE_TYPE_MODULE), STR0164, "GAVIMG32", "GAVIMG32"}) //"Jur�dico"

// SIGAPFS - Pr�-Faturamento de Servi�os
Aadd(aModules, {CodeCargo(77, NODE_TYPE_MODULE), STR0177, "GAVIMG32", "GAVIMG32"}) //"Pr�-Faturamento de Servi�os"

// SIGACTB - Contabilidade Gerencial
Aadd(aModules, {CodeCargo(34, NODE_TYPE_MODULE), STR0026, "CTBIMG32", "CTBIMG32"})

// SIGATUR - Turismo
Aadd(aModules, {CodeCargo(89, NODE_TYPE_MODULE), STR0169, "AVIAO", "AVIAO"})	//"Gest�o de Viagens e Turismo"

// ordena por descri��o
If mv_par02 == 1
	aModules := Asort(aModules, , , {|x, y| x[2] < y[2]})
Endif

Return aModules

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetProcess�Autor  �Adriano Ueda        � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

// ordena por descri��o
If MV_PAR03 == 1
	aProcesses := Asort(aProcesses, , , {|x, y| x[2] < y[2]})
Endif                       

// adiciona o processo "N�o classificados"
Aadd(aProcesses, {CodeCargo(nModule, NODE_TYPE_PROCESS + NODE_TYPE_UNCLASSIFIED) , STR0027, IMG_COL_PROCESS, IMG_EXP_PROCESS})
		
RestArea(aAreaCVJ)	
RestArea(aArea)

Return aProcesses

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetOperat �Autor  �Adriano Ueda        � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
    
	//Se for modulo ativo fixo e processo 110/440/450/490 nao carrega as operacoes abaixo pois s�o do estoque
	If Ctb86Exc( CVG->CVG_PROCES, cModule, CVG->CVG_OPER)
		CVG->( dbSkip() )
		Loop
	EndIf

	Aadd(aOperations, {CodeCargo(CVG->(Recno()), NODE_TYPE_OPERATION) , CVG->CVG_DESCRI, IMG_COL_OPERATION, IMG_EXP_OPERATION})
	
	CVG->(dbSkip())	
End

// ordena por descri��o
If MV_PAR04 == 1
	aOperations := Asort(aOperations, , , {|x, y| x[2] < y[2]})
Endif	

RestArea(aAreaCVG)
RestArea(aArea)

Return aOperations


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetEntries�Autor  �Adriano Ueda        � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

// seleciona amarra��es
dbSelectArea("CVI")
CVI->(dbSetOrder(3))
CVI->(MsSeek(xFilial("CVI") + cProcess + cOperation))

While !CVI->(Eof()) .And. CVI->CVI_FILIAL == cFilCVI .And. CVI->CVI_PROCESS = cProcess .And. CVI->CVI_OPER == cOperation
	
	// define a descri��o padr�o do item a ser inserido
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

// ordena por descri��o
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetUnEntrie�Autor  �Microsiga          � Data �  07/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Devolve os CT5 n�o classificados, ou seja, os registros do  ���
���          �CT5 que j� existem na base e n�o foram inclu�do atrav�s do  ���
���          �novo cadastro de lan�amento padr�o.                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ChgeHandler�Autor  �Adriano Ueda       � Data �  XX/XX/XX   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ChangeHandler(oTree)
Local cCargo := oTree:GetCargo()	
Local nType := DecodeType(cCargo)
Local nRecno := 0

// se estiver atualizando, sai da fun��o
If nStatus == STATUS_REFRESH
	Return
EndIf
// passo 1: verificar se existem filhos

// passo 2: verificar se estes filhos j� foram recuperados,
//          caso contr�rio, recuperar da base. se os filhos
//          j� foram recuperados, ent�o n�o adicion�-los de
//          novo, pois podem ocorrer repeti��es

//
// BUGBUG: se um item estiver sendo editado mas algum
//         dos seus campos estiver falhando na digita��o, ie,
//         o usu�rio digitou um c�digo inv�lido, ao selecionar
//         um outro item na �rvore causa a execu��o da
//         valida��o novamente (pois o campo perdeu o foco) e
//         um erro � gerado.
//

CursorWait()

Do Case
	
	Case nType == NODE_TYPE_MODULE

		// se os n�s j� n�o foram adicionados
		// adicionar os n�s
		If !HasChildNodes(oTree)
			aItens := GetProcesses(DecodeRecno(cCargo))
			AddItens(oTree, aItens)
		EndIf

		// altera o texto do m�dulo
		oSayModule:cCaption := ModuleText(DecodeRecno(cCargo))
		
		// desabilita os bot�es no sidebar
		aButtonsSidebar[IDX_SB_DELETE]:Disable()
		aButtonsSidebar[IDX_SB_COPY]:Disable()
		aButtonsSidebar[IDX_SB_CUT]:Disable()
		aButtonsSidebar[IDX_SB_PASTE]:Disable()
		aButtonsSidebar[IDX_SB_CREATE]:Disable()
		aButtonsSidebar[IDX_SB_REFRESH]:Enable()

		// seleciona o layout correto para exibi��o
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

		// habilita os bot�es no sidebar
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

		// posiciona no registro da opera��o
		dbSelectArea("CVG")
		CVG->(dbGoto(nRecno))

		// recupera as opera��es filhas
		If !HasChildNodes(oTree)
			aItens := GetEntries(CVG->CVG_PROCES, CVG->CVG_OPER)
			AddItens(oTree, aItens)
		EndIf

		// habilita os bot�es no sidebar
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
		// a �rvore utiliza o recno CVI, por�m,
		// o painel est� no CT5
		// decodifica o recno a partir do cargo
		nRecno := DecodeRecno(cCargo)

		// posiciona na tabela de relacionamento
		dbSelectArea("CVI")
		CVI->(dbGoto(nRecno))

		// procura o lan�amento padr�o
		dbSelectArea("CT5")
		CT5->(dbSetOrder(1))

		If CT5->(MsSeek(xFilial("CT5") + CVI->CVI_LANPAD + CVI->CVI_SEQLAN))

			// habilita os bot�es no sidebar
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

		// recupera as opera��es filhas
		If !HasChildNod(oTree)
			aItens := GetUnEntrie()
			AddItens(oTree, aItens)
		EndIf

		oSayModule:cCaption := ModuleText(DecodeRecno(cCargo))
		
		// desabilita os bot�es no sidebar
		aButtonsSidebar[IDX_SB_DELETE]:Disable()
		aButtonsSidebar[IDX_SB_COPY]:Disable()
		aButtonsSidebar[IDX_SB_CUT]:Disable()
		aButtonsSidebar[IDX_SB_PASTE]:Disable()
		aButtonsSidebar[IDX_SB_CREATE]:Disable()
		
		oArea:ShowLayout(LAYOUT_MODULE)
		
		*/
	
	Case nType == NODE_TYPE_UNCLASSIFIED + NODE_TYPE_PROCESS

		// recupera as opera��es filhas
		If !HasChildNodes(oTree)
			aItens := GetUnEntries(DecodeRecno(cCargo))
			AddItens(oTree, aItens)
		EndIf

		oSayModule:cCaption := ModuleText(00)
		
		// desabilita os bot�es no sidebar
		aButtonsSidebar[IDX_SB_DELETE]:Disable()
		aButtonsSidebar[IDX_SB_COPY]:Disable()
		aButtonsSidebar[IDX_SB_CUT]:Disable()
		aButtonsSidebar[IDX_SB_PASTE]:Disable()
		aButtonsSidebar[IDX_SB_CREATE]:Disable()
		
		oArea:ShowLayout(LAYOUT_MODULE)

	Case nType == NODE_TYPE_UNCLASSIFIED + NODE_TYPE_ENTRY
	
		// decodifica o recno a partir do cargo
		nRecno := DecodeRecno(cCargo)

		// posiciona no lan�amento padr�o
		dbSelectArea("CT5")
		CT5->(dbGoto(nRecno))

		// habilita os bot�es no sidebar
		aButtonsSidebar[IDX_SB_DELETE]:Enable()
		aButtonsSidebar[IDX_SB_COPY]:Enable()
		aButtonsSidebar[IDX_SB_CUT]:Enable()
		aButtonsSidebar[IDX_SB_PASTE]:Disable()
		aButtonsSidebar[IDX_SB_CREATE]:Disable()
											
		oEntry:Read()		
				
	Otherwise

		// habilita os bot�es no sidebar
		aButtonsSidebar[2]:Enable()  // exclus�o
		aButtonsSidebar[4]:Enable()  // copiar
		aButtonsSidebar[5]:Enable()  // recortar

		// contador de objetos	
		//oArea:GetCount(oArea:GetPanel(PANEL_UNKNOWN))	
		
		// n�o h� nada para fazer
  		oArea:ShowLayout(LAYOUT_UNKNOWN)
  		
EndCase	

CursorArrow()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RghtClkHdl�Autor  �Adriano Ueda        � Data �  XX/XX/XX   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RightClickHandler(oTree, oObject1, oObject2, x, y, z)
Local oSidebar := oArea:GetSidebar(SIDEBAR)

Local oMenu := PopupMenu(oTree)
If oMenu <> Nil	
	oMenu:Activate(x - 24, y - 100, oSidebar)
EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DblClickHdl�Autor  �Adriano Ueda       � Data �  XX/XX/XX   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DblClickHandler(oTree)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HasChildNod�Autor  �Adriano Ueda       � Data �  XX/XX/XX   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HasChildNodes(oTree)
Return Ascan(oTree:aNodes, {|x| x[1] == oTree:CurrentNodeId}) > 0

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AddItens   �Autor  �Adriano Ueda       � Data �  XX/XX/XX   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AddItens(oTree, aItens)
Local i := 0

For i := 1 To Len(aItens)
	AddItem(oTree, aItens[i])
Next
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AddItem    �Autor  �Adriano Ueda       � Data �  XX/XX/XX   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AddItem(oTree, aItem)

oTree:AddItem(aItem[2], aItem[1], aItem[3], aItem[4], 2, ;
              {|| ChangeHandler(oTree) }, ;
              {|| RightClickHandler(oTree) }, ;
              {|| DblClickHandler(oTree) })
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AddHandler �Autor  �Adriano Ueda       � Data �  XX/XX/XX   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

		// n�o h� nada para fazer
		
	Otherwise
		// n�o h� nada para fazer

EndCase	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DelHandler �Autor  �Adriano Ueda       � Data �  XX/XX/XX   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DelHandler(oTree)
Local nType := DecodeType(oTree:GetCargo())

// Apagar todos os n�s filhos e, somente depois, apagar o item da
// �rvore, pois o objeto XTree j� exclui os n�s filhos
// automaticamente.
// Estas opera��es devem ser protegidas atrav�s de transa��o?
If nType == NODE_TYPE_MODULE	
	// "N�o � poss�vel excluir o m�dulo."
	Alert(STR0029)
Else
	// a chamada de DelNodes() deve ser executada
	// antes da exclus�o do item na �rvore
	IF DelNodes(oTree, oTree:CurrentNodeId)
		oTree:DelItem()
	ENDIF
EndIf

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DelNodes  �Autor  �Adriano Ueda        � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
// Considerar a seguinte situa��o: quando a �rvore est� fechada,
// os n�s filhos n�o s�o carregados. Assim, o array aNodes n�o possui
// elementos para o n� atual.
//
// Neste caso, embora existam registros, estes n�o est�o representados
// na �rvore.
// Deste modo, a exclus�o abaixo falha, pois aNodes est� vazio.
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
				// n�o h� nada para deleter
	
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
					// exclui o CT5 tamb�m
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
			
				// n�o h� nada para deletar
	
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CutHandler�Autor  �Adriano Ueda        � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function CutHandler(oTree)

Local nType := DecodeType(oTree:GetCargo())
Local nRecno := DecodeRecno(oTree:GetCargo())

//
// Localizar o registro a ser copiado a partir do item selecionado na
// �rvore. Copiar o registro para uma �rea tempor�ria (n�o � poss�vel
// acessar, realmente, a �rea de transfer�ncia atrav�s do Protheus).
// Junto com as informa��es copiadas, � necess�rio indicar qual o
// tipo de informa��o e origem, no caso, qual o alias e o registro
// que foi copiado.
//
Do Case
	Case nType == NODE_TYPE_MODULE
		// n�o � poss�vel recortar o m�dulo

	Case nType == NODE_TYPE_PROCESS
		// n�o � poss�vel recortar o processo

	Case nType == NODE_TYPE_OPERATION
		aClipboard := CopyRec("CVG", nRecno, CLIPBOARD_CUT, oTree:GetCargo()) 

	Case nType == NODE_TYPE_ENTRY 
		// posiciona na tabela de relacionamento
		dbSelectArea("CVI")
		CVI->(dbGoto(nRecno))
		
		// procura o lan�amento padr�o
		dbSelectArea("CT5")
		CT5->(dbSetOrder(1))

		If CT5->(MsSeek(xFilial("CT5") + CVI->CVI_LANPAD + CVI->CVI_SEQLAN))
			aClipboard := CopyRec("CT5", CT5->(Recno()), CLIPBOARD_CUT, oTree:GetCargo())
		EndIf
	
	Case nType == NODE_TYPE_MODULE + NODE_TYPE_UNCLASSIFIED
		// n�o h� nada para copiar
				
	Case nType == NODE_TYPE_ENTRY + NODE_TYPE_UNCLASSIFIED
		aClipboard := CopyRec("CT5", nRecno, CLIPBOARD_CUT, oTree:GetCargo())
	
	Otherwise
		// n�o h� nada para deletar

EndCase

// deleta o item
//DelHandler(oTree)	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CopyHandler�Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CopyHandler(oTree)

Local nType := DecodeType(oTree:GetCargo())
Local nRecno := DecodeRecno(oTree:GetCargo())

//
// Localizar o registro a ser copiado a partir do item selecionado na
// �rvore. Copiar o registro para uma �rea tempor�ria (n�o � poss�vel
// acessar, realmente, a �rea de transfer�ncia atrav�s do Protheus).
// Junto com as informa��es copiadas, � necess�rio indicar qual o
// tipo de informa��o e origem, no caso, qual o alias e o registro
// que foi copiado.
//
Do Case
	
	Case nType == NODE_TYPE_MODULE
	
		// n�o h� nada para copiar

	Case nType == NODE_TYPE_PROCESS

		// n�o h� nada para copiar

	Case nType == NODE_TYPE_OPERATION
	
		aClipboard := CopyRec("CVG", nRecno, CLIPBOARD_COPY, oTree:GetCargo()) 

	Case nType == NODE_TYPE_ENTRY 

		// posiciona na tabela de relacionamento
		dbSelectArea("CVI")
		CVI->(dbGoto(nRecno))
		
		// procura o lan�amento padr�o
		dbSelectArea("CT5")
		CT5->(dbSetOrder(1))

		If CT5->(MsSeek(xFilial("CT5") + CVI->CVI_LANPAD + ;
		                CVI->CVI_SEQLAN))
		                
			aClipboard := CopyRec("CT5", CT5->(Recno()), ;
			                      CLIPBOARD_COPY, oTree:GetCargo())
		EndIf
	
	Case nType == NODE_TYPE_MODULE + NODE_TYPE_UNCLASSIFIED

		// n�o h� nada para copiar
				
	Case nType == NODE_TYPE_ENTRY + NODE_TYPE_UNCLASSIFIED
	
		aClipboard := CopyRec("CT5", nRecno, CLIPBOARD_COPY, ;
		                      oTree:GetCargo())
	
	Otherwise
	
		// n�o h� nada para deletar

EndCase
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PstHandler �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		
			// n�o h� nada para deletar

	EndCase			
EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |IsCTBProces�Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |NewSidebar �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria o sidebar na �rea oArea. Tamb�m, cria uma barra de    ���
���          � ferramentas com os bot�es desejados especificados em       ���
���          � aButtons.                                                  ���
���          � Devolve a refer�ncia para o objeto Sidebar criado.         ���
���          � Restri��o: a vari�vel aButtonsSidebar deve ser declarado   ��� 
���          � como private na fun��o chamadora.                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

// desabilita o bot�o de Colar	
aButtonsSidebar[4]:Disable()
Return oSidebar

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |NewModLay  �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria um layout espec�fico para mostrar as informa��es sobre���
���          � o m�dulo selecionado.                                      ���
���          � Devolve a refer�ncia para o objeto de layout criado.       ���
���          �                                                            ���
���          � Restri��o: oSayModule deve ser declarado como private na   ��� 
���          � fun��o chamadora.                                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CreateModuleLayout(oArea)
Local oLayout := Nil

// adiciona layout	
oArea:AddLayout(LAYOUT_MODULE)
oLayout := oArea:GetLayout(LAYOUT_MODULE)

// adiciona janela
oArea:AddWindow(100, CtbGetHeight(100), WND_MODULE, "M�dulo", 2, 3, oLayout)	
               
// adiciona painel
oArea:AddPanel(100, 100, PANEL_MODULE, CONTROL_ALIGN_ALLCLIENT)

// adiciona label
@ 0, 0 Say oSayModule Var "" ;
       Of oarea:GetPanel(PANEL_MODULE) PIXEL HTML 	
oSayModule:Align := CONTROL_ALIGN_ALLCLIENT
Return oLayout

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |NewUnknown �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria um layout contendo uma janela (com o t�tulo de        ���
���          � "Desconhecido") e um painel em branco na �rea oArea.       ���
���          �                                                            ���
���          � Devolve a refer�ncia para o objeto de layout criado.       ���
���          �                                                            ���
���          � Restri��es: Esta fun��o n�o valida a cria��o dos objetos,  ���
���          � estando pass�vel de erro caso a mesma falhe.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |DecodeType �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     � Decodifica o cargo cCargo e devolve o tipo de elemento que ���
���          � o mesmo se refere.                                         ���
���          �                                                            ���
���          � O cargo deve estar no formato 999999.99, onde os n�meros   ���
���          � antes do ponto s�o o Recno e os n�meros depois do ponto    ���
���          � formam o tipo. Exemplo:                                    ���
���          �                                                            ���
���          � 12345.67                                                   ���
���          �                                                            ���
���          � Tipo: 67                                                   ���
���          � Recno: 12345                                               ���
���          �                                                            ���
���          � Devolve 0 (zero) caso cCargo n�o utilize o formato         ���
���          � especificado acima.                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DecodeType(cCargo)
Local nType := 0

If At( "." , cCargo) > 0
	nType := Val(Substr(cCargo, At(".", cCargo) + 1))
EndIf

Return nType

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |DecodeRecno�Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     � Decodifica o cargo cCargo e devolve o tipo de elemento que ���
���          � o mesmo se refere.                                         ���
���          �                                                            ���
���          � O cargo deve estar no formato 999999.99, onde os n�meros   ���
���          � antes do ponto s�o o Recno e os n�meros depois do ponto    ���
���          � formam o tipo. Exemplo:                                    ���
���          �                                                            ���
���          � 12345.67                                                   ���
���          �                                                            ���
���          � Tipo: 67                                                   ���
���          � Recno: 12345                                               ���
���          �                                                            ���
���          � Devolve 0 (zero) caso cCargo n�o utilize o formato         ���
���          � especificado acima.                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DecodeRecno(cCargo)
Local nRecno := 0

If At(".", cCargo) > 0
	nRecno := Val(Substr(cCargo, 1, At(".", cCargo) - 1))
EndIf
Return nRecno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |CodeCargo  �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CodeCargo(nRecno, nType)

Return AllTrim(Str(nRecno)) + "." + AllTrim(Str(nType))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ModuleText �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModuleText(nModule)
Local cText := ""

Do Case
	// SIGACOM	
	Case nModule == 02
		cText += STR0048 //"<h1>Compras</h1>"

		cText += STR0049 //"<p>O Ambiente de Compras oferece � equipe de compras de "
		cText += STR0050 //"uma empresa, condi��es de acompanhar e controlar as carteiras "
		cText += STR0051 //"de compras, cota��es, pedidos de compras e o recebimento de "
		cText += STR0052 //"materiais, permitindo a reposi��o dos estoques em tempo h�bil "
		cText += STR0053 //"e apresentando informa��es indispens�veis a uma boa negocia��o "
		cText += STR0054 //"com seus fornecedores.</p>"

	// SIGAFAT			
	Case nModule == 05
		cText += STR0055 //"<h1>Faturamento</h1>"

		cText += STR0056 //"<p>Faturamento pode ser definido como a receita bruta "
		cText += STR0057 //"decorrente da venda de mercadorias, de mercadorias e "
		cText += STR0058 //"servi�os e de servi�os de qualquer natureza.</p>"

	// SIGAEST		
	Case nModule == 04
		cText += STR0059 //"<h1>Estoque</h1>"

		cText += STR0060 //"<p>O ambiente Estoque/Custos tem por finalidade principal "
		cText += STR0061 //"o controle de materiais movimentados e armazenados pela sua "
		cText += STR0062 //"empresa, al�m do custo incorrido sobre este material.</p>"

	// SIGAATF
	Case nModule == 01
		cText += STR0063 //"<h1>Ativo Fixo</h1>"

		cText += STR0064 //"<p>O objetivo do ambiente Ativo Fixo � controlar "
		cText += STR0065 //"o ativo permanente da empresa.</p>"

		cText += STR0066 //"<p>No ativo permanente est�o as aplica��es de recursos "
		cText += STR0067 //"feitas pela empresa em car�ter permanente, ora representando "
		cText += STR0068 //"bens adquiridos para uso da empresa como ve�culos, m�veis e "
		cText += STR0069 //"utens�lios, etc, ora representando aplica��es de recursos na "
		cText += STR0070 //"compra de a��es  ou quotas de outras empresas de car�ter "
		cText += STR0071 //"permanente, ou ainda, representando aplica��es de recursos em "
		cText += STR0072 //"despesas que devem onerar os resultados de v�rios exerc�cios.</p>"

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
		cText += STR0079 //"no regime 'Especial' via processamento eletr�nico de dados, por "
		cText += STR0080 //"meio magn�tico de armazenagem de dados, a partir das Notas Fiscais "
		cText += STR0081 //"de Compra (Entradas) e das Notas Fiscais de Sa�da (Sa�das)</p>"

	// SIGAGPE		
	Case nModule == 07
	
		cText += STR0082 //"<h1>Gest�o de Pessoal</h1>"

		cText += STR0083 //"<p>O Ambiente Gest�o de Pessoal faz parte do Protheus, "
		cText += STR0084 //"destinando-se ao controle e automa��o das atividades relacionadas "
		cText += STR0085 //"a administra��o de pessoal, tais como a folha de pagamento, "
		cText += STR0086 //"tributos incidentes sobre a folha, f�rias, rescis�o contratual e "
		cText += STR0087 //"obriga��es anuais.</p>"

	// SIGAGCT			
	Case nModule == 69
		cText += STR0088 //"<h1>Gest�o de Contratos</h1>"
		
		cText += STR0089 //"<p>O ambiente SIGAGCT (Gest�o de Contratos) ger�ncia os contratos "
		cText += STR0090 //"de compras que a empresa mant�m com seus fornecedores, "
		cText += STR0091 //"possibilitando controlar e acompanhar todos os processos de "
		cText += STR0092 //"contrata��o de produtos e/ou servi�os detalhando suas "
		cText += STR0093 //"especifica��es.</p>"

	// SIGAPMS
	Case nModule == 44
		cText += STR0094 //"<h1>Gest�o de Projetos</h1>"
		
		cText += STR0104 //"<p>O Ambiente Project Management System (Gest�o de Projetos), do Protheus, "
		cText += STR0105 //"automatiza o gerenciamento de projetos em todas as suas etapas. Do planejamento "
		cText += STR0106 //"� conclus�o, cada passo do projeto ser� monitorado.</p>"

		cText += STR0107 //"<p>Sejam projetos em pequena ou em grande escala, como organizar uma feira de "
		cText += STR0108 //"com�rcio ou construir uma f�brica, ou projetos internos, requerem o planejamento "
		cText += STR0109 //"de todas as atividades envolvidas, detalhadamente.</p>"

	// SIGAGAV
	Case nModule == 65
  		cText += STR0095 //"<h1>Gest�o Advocaticia</h1>"

		cText += STR0126 //"<p>Os escrit�rios de advocacia est�o transformando-se em grandes empresas "
		cText += STR0127 //"prestadoras de servi�os.</p>"

		cText += STR0128 //"<p>A remunera��o dos profissionais n�o � mais o ponto focal, fazendo do faturamento, "
		cText += STR0129 //"das formas de negocia��o com os clientes e da cobran�a os pontos cruciais na "
		cText += STR0130 //"administra��o desse segmento.</p>"

		cText += STR0131 //"<p>Como conseq��ncia, surgiram necessidades t�picas de grandes empresas, tais como, "
		cText += STR0132 //"agilidade na emiss�o de faturas, o comando da situa��o financeira e cont�bil, "
		cText += STR0133 //"o desempenho de seus colaboradores, bem como a an�lise da produtividade.</p>"

		cText += STR0134 //"<p>Os apontamentos de horas e despesas, despendidas com os assuntos consultivos e "
		cText += STR0135 //"contenciosos, s�o cada vez emlhores gerenciados para que se obtenha o m�ximo "
		cText += STR0136 //"de rentabilidade.</p>"

		cText += STR0137 //"<p>Neste cen�rio, um sistema de informa��es integrado � a solu��o respons�vel por "
		cText += STR0138 //"manter um ambiente de colabora��o, proporcionar acesso seguro e r�pido aos dados e "
		cText += STR0139 //"melhorar as rela��es com os clientes atribuindo maior rapidez e precis�o �s informa��es.</p>"

		cText += STR0140 //"<p>Para suprir e atender a tais necessidades, a Microsiga desenvolveu a Solu��o Protheus 10 - "
		cText += STR0141 //"Gest�o Advocat�cia, que traz mais confiabilidade e agilidade aos processos de gest�o.</p>"
	
	// Plano de Saude
	Case nModule == 33
		cText += STR0143 //"<h1>Gest�o de Planos de Sa�de</h1>"

		cText += STR0144 //"<p>O Protheus 10 Gest�o de Planos de Sa�de foi desenvolvido para os "
		cText += STR0145 //"segmentos de cooperativas m�dicas e odontol�gicas, autogest�o, medicina "
		cText += STR0146 //"de grupo e seguradoras, atendendo toda � regulamenta��o da Lei 9.656 "
		cText += STR0147 //"e contemplando todas as exig�ncias da Ag�ncia Nacional Suplementar (ANS).</p>"

		cText += STR0148 //"<p>Integra��o �s demais funcionalidades do Protheus 10, "
		cText += STR0149 //"a solu��o Gest�o de Planos de Sa�de disp�e de todos os recursos necess�rios "
		cText += STR0150 //"para o perfeito gerenciamento dos processos, tornando mais eficiente e competitiva "
		cText += STR0151 //"a administra��o das empresas do setor.</p>"

		cText += STR0152 //"<p>Tendo como caracter�stica um alto poder de parametriza��o, a solu��o permite grande "
		cText += STR0153 //"flexibilidade para defini��o de coberturas, car�ncias, taxas de pre�os de planos, "
		cText += STR0154 //"formas de cobran�a e regras negociadas com as diversas classes de prestadores, "
		cText += STR0155 //"como m�dicos, cl�nicas, hospitais e laborat�rios, sendo que tais parametriza��es "
		cText += STR0156 //"podem ocorrer em diversos n�veis, permitindo tanto a cria��o de regras gen�ricas "
		cText += STR0157 //"para toda a empresa quanto regras espec�ficas (at� o n�vel de benefici�rio).</p>"

		cText += STR0158 //"<p>As funcionalidades do Protheus 10 � Gest�o de Planos de Sa�de t�m como principais "
		cText += STR0159 //"objetivos prover a empresa com ferramentas para aumentar a produtividade em atividades "
		cText += STR0160 //"operacionais como credenciamento de rede de prestadores, gest�o de vendas e contratos, "
		cText += STR0161 //"processos de atendimento e autoriza��es, gerando informa��es on-line de todo o hist�rico "
		cText += STR0162 //"do benefici�rio, do prestador e dos procedimentos.</p>"
		
	// SIGACTB
	Case nModule == 34
		cText += STR0110 //"<h1>Contabilidade Gerencial</h1>"
		
		cText += STR0111 //"<p>A Contabilidade � um instrumento da administra��o e, para ser �til, "
		cText += STR0112 //"deve adaptar-se �s suas necessidades. A complexidade da tomada de decis�es "
		cText += STR0113 //"nos neg�cios da empresa acarretou o uso sistem�tico da contabilidade para "
		cText += STR0114 //"controle e planejamento administrativos. Bem utilizadas, as demonstra��es "
		cText += STR0115 //"cont�beis constituem a base mais completa de informa��o, uma vez que, por "
		cText += STR0116 //"meio delas, � poss�vel identificar os pontos fracos da estrutura "
		cText += STR0117 //"econ�mico-financeira da empresa, proporcionando uma vis�o resumida do "
		cText += STR0118 //"resultado dos neg�cios e da situa��o patrimonial e servindo de base para "
		cText += STR0119 //"exercer a a��o corretiva de qualquer controle adequado.</p>"
		
		cText += STR0120 //"<p>Esta pasta cont�m os lan�amentos padr�o com c�digo menor que 500</p>"

	// SIGATMS		
	Case nModule == 43
		cText += STR0121 //"<h1>Gest�o de Transportes</h1>"
		
		cText += STR0122 //"<p>O ambiente SIGATMS (Gest�o de Transportes) controla todos os processos "
		cText += STR0123 //"de um transportador, abrangendo as �reas: operacional, comercial, seguros, "
		cText += STR0124 //"faturamento, log�stica e SAC. Solu��o totalmente integrada com a �rea "
		cText += STR0125 //"administrativa (financeiro, fiscal e cont�bil)."
		
	// SIGAJURI / SIGAPFS
	Case nModule == 76 .Or. nModule == 77
		cText += STR0165 //"<h1>Jur�dico</h1>"
		
		cText += STR0126 //"<p>Os escrit�rios de advocacia est�o transformando-se em grandes empresas "
		cText += STR0127 //"prestadoras de servi�os.</p>"

		cText += STR0128 //"<p>A remunera��o dos profissionais n�o � mais o ponto focal, fazendo do faturamento, "
		cText += STR0129 //"das formas de negocia��o com os clientes e da cobran�a os pontos cruciais na "
		cText += STR0130 //"administra��o desse segmento.</p>"

		cText += STR0131 //"<p>Como conseq��ncia, surgiram necessidades t�picas de grandes empresas, tais como, "
		cText += STR0132 //"agilidade na emiss�o de faturas, o comando da situa��o financeira e cont�bil, "
		cText += STR0133 //"o desempenho de seus colaboradores, bem como a an�lise da produtividade.</p>"

		cText += STR0134 //"<p>Os apontamentos de horas e despesas, despendidas com os assuntos consultivos e "
		cText += STR0135 //"contenciosos, s�o cada vez emlhores gerenciados para que se obtenha o m�ximo "
		cText += STR0136 //"de rentabilidade.</p>"

		cText += STR0137 //"<p>Neste cen�rio, um sistema de informa��es integrado � a solu��o respons�vel por "
		cText += STR0138 //"manter um ambiente de colabora��o, proporcionar acesso seguro e r�pido aos dados e "
		cText += STR0139 //"melhorar as rela��es com os clientes atribuindo maior rapidez e precis�o �s informa��es.</p>"

		cText += STR0166 //"<p>O ambiente Juridico atende as exigencias do legislativo do pais, "
		cText += STR0167 //"leva a empresa, cujo o Know-How n�o � o Direito, a informatiza��o "
		cText += STR0168 //"do judici�rio, sem depender da consultoria de advocacia tercerizados.</p>"

	Case nModule == 89
		cText += STR0170 //"<h1>Gest�o de Viagens e Turismo</h1>"
		
		cText += STR0171 //"<p>O M�dulo de Gest�o de Viagens e Turismo foi desenvolvido para permitir "
		cText += STR0172 //"a gest�o integrada de uma ag�ncia de viagens desde seu processo comercial, "
		cText += STR0173 //"controle dos acordos com clientes e fornecedores, bem como suas metas.  "
		cText += STR0174 //"Importa��o e concilia��o de fatura, apura��o de receita de clientes, "
		cText += STR0175 //"fornecedores e suas metas e o Faturamento de receita e servi�os de "
		cText += STR0176 //"forma integrada com o backoffice do Microsiga Protheus.</p>"		

	// N�o classificados
	Case nModule == 00
		cText += STR0096 //"<h1>N�o classificados</h1>"
		
		cText += STR0097 //"<p>Nesta pasta encontram-se os lan�amentos padr�es que n�o foram "
		cText += STR0098 //"classificados. Para fazer uma classifica��o automaticamente, acesse as perguntas "
		cText += STR0099 //"da rotina (tecla de fun��o F12), marque a sexta pergunta com SIM, e acesse novamente."
		cText += STR0100 //"A pergunta pode ser desligada depois da classifica��o.</p>"
		
	Otherwise
		cText += STR0101 //"<h1>Desconhecido</h1>"
		
EndCase

Return cText

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |CreateGet  �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	MsgStop(STR0030) //"Erro na cria��o da MsMGet."
EndIf	

Return oGet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |PopUpMenu  �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
			// "Incluir Opera��o"
			MenuItem STR0031 Block {|| oOperation:Create()} Resource  IMG_CREATE
			
			//MenuItem "Colar Opera��o" Block {|| oOperation:Paste(aClipboard)} Resource IMG_PASTE
			
			//MenuItem "___________________" Disabled
			
			//MenuItem "Importar Opera��o" Block {|| ImportOperation()}
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

			//"Incluir Lan�amento"
			MenuItem STR0034  Block {|| oEntry:Create()} Resource IMG_CREATE

			//"Colar Lan�amento"
			MenuItem STR0035 Block {|| oEntry:Paste(aClipboard)} Resource IMG_PASTE
			//MenuItem "Colar V�nculo" Block {|| oEntry:PasteLink(aClipboard)}
			
			//"Colar Estorno"
			MenuItem STR0036 Block {|| oEntry:PasteReversal(aClipboard)} Resource IMG_PASTE
			MenuItem "___________________" Disabled
			//"Importar Lan�amento"
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |GetByRecno �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |CopyRec    �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �Restri��o: as posi��es dos campos da tabela destino devem   ���
���          �ser as mesmas na tabela origem.                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |GetFieldPos�Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �Restri��o: as posi��es dos campos da tabela destino devem   ���
���          �ser as mesmas na tabela origem.                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GetFromFieldPos(nFieldPos)

If nFieldPos > 0
	If nFieldPos <= Len(aClipboard)
		Return aClipboard[nFieldPos]
	EndIf
EndIf
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ImpOperat  �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �Restri��o: as posi��es dos campos da tabela destino devem   ���
���          �ser as mesmas na tabela origem.                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ImportOperation()
Return                                          


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |SetFont    �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �Configura a fonte padr�o utilizada para o cadastro de       ���
���          �lan�amento padr�o.                                          ���
���          �Recebe o nome da fonte cFontName a ser utilizada.           ���
���          �                                                            ���
���          �Devolve a refer�ncia para o objeto de fonte criado.         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SetFont(cFontName)

Local oFont := Nil

Define Font oFont Name cFontName Size 0, -8

SetDefFont(oFont)

Return oFont

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |RefreshTree�Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �															  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ListaNodes �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �															  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EnqueueNodes(oTree, cNodeId, aQueue)
Local i := 0
Local nPos := Ascan(oTree:aNodes, {|x| x[2] == cNodeId})


  
//
// Considerar a seguinte situa��o: quando a �rvore est� fechada,
// os n�s filhos n�o s�o carregados. Assim, o array aNodes n�o possui
// elementos para o n� atual.
//
// Neste caso, embora existam registros, estes n�o est�o representados
// na �rvore.
// Deste modo, a exclus�o abaixo falha, pois aNodes est� vazio.
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |IsValidEntr�Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function IsValidEntry(cProcess, cOperation, cEntry)

Local lIsValid := .F.

Local nProcPos := 0
Local nEntryPos := 0

If __aProcs == Nil
	__aProcs := GetProcOper()
Endif

IF IsGPEProces(cProcess) .Or. IsCTBProces(cProcess)
	// processos de exess�o n�o ser�o tratados neste momento
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

		// procura pelo lan�amento
		nEntryPos := Ascan(__aProcs[nProcPos][5], {|x| Upper(AllTrim(x)) == Upper(AllTrim(cEntry)) })

		// se encontrado, verifica se � necessario
		// validar tamb�m a opera��o		  
		If nEntryPos > 0

			// verifica se � necess�rio validar a opera��o
			If __aProcs[nProcPos][4]
				// validar tamb�m a opera��o								
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |SetEntryImg�Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a imagem do item, dependendo do tipo de lan�amento   ���
���          �(d�bito, cr�dito ou ambos)								  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |aXpesquiTree�Autor �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     � Esta funcao faz a pesquisa dentro do tree				  ���
���          � A pesquisa r�pida faz o seek na tabela e posiciona no tree,���
���          �  a pesquisa nao rapida mostra uma serie de resultados para ���
���          � o usuario escolher entes de ir para tree.				  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |MBRBLIND   �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MBRBLIND()

AxPesqui()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |PosicTree  �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |CT52CVI    �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |GetVldLPs  �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna os Lancamentos padroes validos para um processo ou ���
���          � para um processo/operacao.                                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |GetProcOper�Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	AADD(__aProcs,{"01", "040","005",.T.,{"820","823"}})//C�lculo de deprecia��o: rateio de despesas
	AADD(__aProcs,{"01", "040","010",.T.,{"825","828"}})//Estorno do c�lculo da deprecia��o: rateio de despesas
	AADD(__aProcs,{"01", "050","005",.T.,{"827"}})
	AADD(__aProcs,{"01", "050","010",.T.,{"845"}})
	AADD(__aProcs,{"01", "050","015",.T.,{"846"}})
	AADD(__aProcs,{"01", "050","020",.T.,{"847"}})
	AADD(__aProcs,{"01", "050","025",.T.,{"848"}})
	AADD(__aProcs,{"01", "060","005",.T.,{"80E","8A6","8A7"}})//Ativo Fixo - Reavalia��o
	AADD(__aProcs,{"01", "060","010",.T.,{"80F","8A8","8A9"}})//Ativos Fixos - Estorno de Reavalia��o 
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
	AADD(__aProcs,{"06", "200","040",.T.,{"559"}}) //feito no changeset anterior, subido novamente pois cabe�alhos comentados mudaram o encode.
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
	//LP's reservados para PFS - 940 At� 949 e 956 At� 964
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |IsPLSProces�Autor  �Renato Ferreira Campos �Data� 10/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function IsPLSProces(cProc)

Return (cProc=="9A0")

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |IsJurProces�Autor  �Renato Ferreira Campos �Data� 07/08/13  ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function IsJURProces(cProc)

Return (cProc=="9D0")

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |IsPFSProces�Autor  �Jorge Martins          �Data� 22/08/18  ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function IsPFSProces(cProc)

Return (cProc=="940")

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |IsGPEProces�Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function IsGPEProces(cProc)

Return (cProc=="700")

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |IsCTBProces�Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function IsCTBProces(cProc)

Return (cProc=="750")

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |CtbGetHght �Autor  �Adriano Ueda       � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CtbGetHeight(nHeight)
Local nFinalHeight := nHeight

// verifica se est� utilizando o modo MDI
// e calcula uma pequena diferen�a no tamanho,
// para n�o cortar a visualiza��o dos bot�es
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
