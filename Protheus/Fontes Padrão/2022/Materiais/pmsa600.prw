#include "pmsa600.ch"
#include "pmsicons.ch"
#include "protheus.ch"

Static _oPMSA6001
Static _oPMSA6002
Static _aVldPedTar	:= {}
Static _lPergVldP	:= .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA600  ³ Autor ³ Edson Maricate        ³ Data ³ 13/08/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de faturamento de projetos.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA600(nCallOpcx)
PRIVATE cCadastro	:= STR0001

If PMSBLKINT()
	Return Nil
EndIf

If AMIIn(44)
	Pergunte("PMA200",.F.)
	nDlgPln := mv_par01
Endif

PRIVATE aRotina := MenuDef()						
PRIVATE aMemos  := {{"AF8_CODMEM","AF8_OBS"}}
PRIVATE aCores  := PmsAF8Color()
PRIVATE nDlgPln := 1

Set Key VK_F12 To FAtiva()

If AMIIn(44) .And. !PMSBLKINT()
	If nCallOpcx <> Nil
		PMS600Dlg("AF8",AF8->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AF8",,,,,,aCores)
	EndIf
EndIf

Set Key VK_F12 To 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS600Dlg³ Autor ³ Edson Maricate         ³ Data ³ 13-08-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Visualização e Faturamento de Projetos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS600Dlg(cAlias,nReg,nOpcx)

Local l600Visual	:= .F.
Local l600Altera	:= .F.
Local lContinua		:= .T.
Local oTree
Local oDlg
Local aUsButtons	:= {}
Local aButtons		:= {}
Local cArquivo		:= GetNextAlias() 
Local cArquivo2		:= GetNextAlias() 
Local aConfig		:= { 1, PMS_MIN_DATE, PMS_MAX_DATE, Space( TamSX3( "AE8_RECURS" )[1] ) }
Local lOk
Local lFWGetVersao := .T.

Private cRevisa		:= AF8->AF8_REVISA
Private cCmpPLN
Private cArqPLN
Private cPLNVer		:= ""
Private cPLNDescri	:= ""
Private lSenha		:= .F.
Private cPLNSenha	:= ""
Private nFreeze		:= 0
Private nIndent		:= PMS_SHEET_INDENT
Private lUsaAJT		:= AF8ComAJT( AF8->AF8_PROJET )

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case
	Case (aRotina[nOpcx][4] == 2)
		l600Visual := .T.
	Case (aRotina[nOpcx][4] == 4)
		l600Altera	:= .T.
		lOk := .F.
EndCase

If l600Altera
	// verifica o evento de Faturamento do Projeto
	If !PmsVldFase("AF8",AF8->AF8_PROJET,"84")
		lContinua := .F.
	EndIf
EndIf

If lContinua
	If !l600Visual
		MENU oMenu2 POPUP
			MENUITEM STR0007 ACTION PmsPrjInf() //"Informacoes do Projeto..."
			MENUITEM STR0014 ACTION (PMC200Cfg("",0,0),oDlg:End()) //"Configurar Colunas"
			MENUITEM STR0015 ACTION If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) //"Filtrar visualizacao"
		ENDMENU
		MENU oMenu3 POPUP
			MENUITEM STR0008 ACTION PmsDlgAF8Gnt(cRevisa,aConfig,@oDlg,@oTree,cArquivo) //"Grafico de Gantt..."
			MENUITEM STR0009 ACTION PmsDlgAF8Rec(cRevisa,@oTree,cArquivo) //"Grafico de Alocacao dos Recursos..."
			MENUITEM STR0016 ACTION Pms200View(STR0016,{|| PMSC110(AF8->AF8_PROJET,cRevisa,,,@oTree,cArquivo) }) //"Alocacao dos recursos por periodo..."
			MENUITEM STR0017 ACTION PmsDlgAF8Eqp(cRevisa,@oTree,cArquivo)  //"Alocacao de equipes do projeto..."
			MENUITEM STR0018 ACTION Pms200View(STR0018,{||PMSC115(AF8->AF8_PROJET,cRevisa,,cArquivo) })//"Alocacao de equipes por periodo..."
			MENUITEM STR0023 ACTION PMSC100MS(2,,cArquivo) // "Progresso Financeiro Previsto x Realizado"
			MENUITEM STR0024 ACTION PMSC100MS(3,,cArquivo) //"Progresso FÍsico Previsto x Realizado"
			MENUITEM STR0025 ACTION PMS300D2(,.T.,cArquivo) //"Notas Fiscais de Saida" 
		EndMenu
		MENU oMenu POPUP
			MENUITEM STR0003 ACTION PMS200to201(2,@oTree,,cArquivo) //"Visualizar"
		ENDMENU

		If !lFWGetVersao .or. GetVersao(.F.) == "P10"
			aMenu := { 	{STR0010,{||oMenu2:Activate(5,25,oDlg) }},; //"&Ferramentas"
									{STR0011,{||oMenu3:Activate(75,25,oDlg) }},; //"&Consultas"
									{STR0012,{||oMenu:Activate(170,25,oDlg) }}} //"&Estrutura"
		Else
		//Acoes realacionadas
			aMenu := { 	{STR0010,{||oMenu2:Activate(775,23,oDlg) }},; //"&Ferramentas"
									{STR0011,{||oMenu3:Activate(775,23,oDlg) }},; //"&Consultas"
									{STR0012,{||oMenu:Activate(775,23,oDlg) }}} //"&Estrutura"
		Endif			
	Else
		MENU oMenu2 POPUP
			MENUITEM STR0007 ACTION PmsPrjInf() //"Informacoes do Projeto..."
			If nDlgPln == 2
				MENUITEM STR0014 ACTION (PMC200Cfg("",0,0),oDlg:End()) //"Configurar Colunas"
			EndIf
			
			MENUITEM STR0015 ACTION If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) //"Filtrar visualizacao"

			If nDlgPln == 1
				MENUITEM STR0020 ACTION PMSSeekTree(oTree, @cSearch) //"Procurar..."
				MENUITEM STR0021 ACTION PMSSeekNext(oTree, @cSearch) //"Procurar proxima"
			EndIf
			
		ENDMENU
		MENU oMenu3 POPUP
			MENUITEM STR0008 ACTION PmsDlgAF8Gnt(cRevisa,aConfig) //"Grafico de Gantt..."
			MENUITEM STR0013 ACTION PmsDlgAF8Rec(cRevisa) //"Gantt de Alocacao dos Recursos..."
		EndMenu
		MENU oMenu POPUP
			MENUITEM STR0003 ACTION PMS200to201(2,@oTree,,cArquivo) //"Visualizar"
		ENDMENU

		If !lFWGetVersao .or. GetVersao(.F.) == "P10"

			aMenu := { 	{STR0010,{||oMenu2:Activate(5,100,oDlg) }},; //"&Ferramentas"
									{STR0011,{||oMenu3:Activate(75,100,oDlg) }},; //"&Consultas"
									{STR0012,{||oMenu:Activate(150,100,oDlg) }}} //"&Estrutura"
		Else
			//Acoes relacionadas
			aMenu := { 	{STR0010,{||oMenu2:Activate(775,23,oDlg) }},; //"&Ferramentas"
									{STR0011,{||oMenu3:Activate(775,23,oDlg) }},; //"&Consultas"
									{STR0012,{||oMenu:Activate(775,23,oDlg) }}} //"&Estrutura"
		EndIf
	EndIf
	
	aCampos := {{"AF9_TAREFA","AFC_EDT",8,,,.F.,"",},{"AF9_DESCRI","AFC_DESCRI",55,,,.F.,"",150}}
	A200Opn(@aCampos,"\PROFILE\PMSA600")
	Pms600Plan(cCadastro,cRevisa,aCampos,@cArquivo,,nFreeze,@lOk,aMenu,@oDlg,,,aConfig,cArquivo2,nIndent)
	
	If l600Altera .And. lOk
		Pms600PV(cArquivo2)
	EndIf     
	
	_aVldPedTar := {} // limpa array que valida itens sem custo do projeto, após faturamento 

	If _oPMSA6002 <> Nil
		_oPMSA6002:Delete()
		_oPMSA6002 := Nil
	Endif	
 	
EndIf	

Return

Static Function FAtiva()
Pergunte("PMA200",.T.)
nDlgPln := mv_par01
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSPlanAF8³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma planilha para visualizacao do projeto               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTitle : Titulo da janela                                     ³±±
±±³          ³cVersao: Versao do projeto a ser visualizado                  ³±±
±±³          ³aCampos: Array contendo os campos a serem visualizados        ³±±
±±³          ³         [1] : Nome do campo AF9                              ³±±
±±³          ³         [2] : Nome do campo AFC                              ³±±
±±³          ³         [3] : Tamanho do campo ( opcional )                  ³±±
±±³          ³         [4] : Decimal do campo ( opcional )                  ³±±
±±³          ³         [5] : Titulo  do campo ( opcional )                  ³±±
±±³          ³         [6] : Permite edicao ( .T./.F. )                     ³±±
±±³          ³         [7] : Validacao                                      ³±±
±±³          ³cArquivo : Nome do arquivo temporario                         ³±±
±±³          ³aButtons : Botoes auxiliares                                  ³±±
±±³          ³         [1] : Titulo do Botao                                ³±±
±±³          ³         [2] : CodeBlock a ser executado                      ³±±
±±³          ³         [3] : Nome do recurso ( BITMAP )                     ³±±
±±³          ³nFreze   : Congelar colunas do Browse                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms600Plan(	cTitle,cReserv,aCampos,cArquivo,aButtons,nFreze,lConfirma,;
							aMenu,oDlg,cUsrRev,lExcel,aConfig,cArquivo2,nIndent)
Local aAuxRet
Local aBOD
Local aAlter    := {}
Local aExpand   := {}
Local nTop      := oMainWnd:nTop+PMSResV(23)
Local nLeft     := oMainWnd:nLeft+PMSResH(5)
Local nBottom   := oMainWnd:nBottom-PMSResV(60)
Local nRight    := oMainWnd:nRight-PMSResH(10)
Local oMenu	
Local oGd
Local oBrowse
Local oBrowse2
Local oAll      := LoadBitmap( GetResources(), BMP_EXPALL )
Local oCmp      := LoadBitmap( GetResources(), BMP_EXPCMP )
Local oMenos    := LoadBitmap( GetResources(), BMP_SHORTCUTMINUS )
Local oMais     := LoadBitmap( GetResources(), BMP_SHORTCUTPLUS )
Local oVTot
Local oGetTot
Local oPercFat
Local oGetQtde
Local oValFat
Local nTotal    := 0
Local nValTot   := 0
Local nx
Local nQuantFat := 0
Local nQuant    := 0
Local nPercFat  := 0
Local nValFat   := 0
Local cPictQtde := ""
Local cPictAFC  := PesqPict('AFC','AFC_QUANT')
Local cPictAF9  := PesqPict('AF9','AF9_QUANT')
Local nTamanho  := 0

PRIVATE aHandCP     := {}
PRIVATE aHandCR     := {}
PRIVATE aHandCRTE   := {}
PRIVATE aHandCOTP   := {}
PRIVATE aHandFin    := {}
PRIVATE aHandFat    := {}
PRIVATE aHandCOTE   := {}
PRIVATE aStru       := {}
PRIVATE aHeader     := {}
PRIVATE aAuxCps     := aClone(aCampos)
PRIVATE bRefresh    := {|| (PmsAtuPlan(,cArquivo,nNivelMax,cUsrRev,,aExpand,aConfig,,,nIndent),oBrowse:Refresh()) }
PRIVATE bRefreshAll := {|| (PmsAtuPlan(,cArquivo,,cUsrRev,,,aConfig,,,nIndent),oBrowse:Refresh()) }

DEFAULT cUsrRev := AF8->AF8_REVISA
DEFAULT lExcel  := .F.
DEFAULT nIndent := PMS_SHEET_INDENT

SaveInter()

Processa({||PmsPlnField(aCampos)})

RegToMemory("AFA",.T.)
RegToMemory("AFB",.T.)

If ExistBlock("PMSAF802")
	cArquivo := ExecBlock("PMSAF802", .F., .F., {cArquivo})
EndIf

// ExecBlock para inclusao de botoes customizados
If ExistBlock("PMSAF8BD")
	aBOD := ExecBlock("PMSAF8BD",.F.,.F.)
	For nx := 1 to Len(aBOD)
		aAdd(aMenu,{aBOD[nx,1],aBOD[nx,2]})
	Next
EndIf

For nx := 1 to Len(aCampos)
	dbSelectArea("SX3")
	dbSetOrder(2)
	If MsSeek(aCampos[nx][1])
		If aCampos[nx,1] == "AF9_TAREFA" .AND. TamSX3("AF9_TAREFA")[1] < TamSX3("AF9_PROJET")[1]
			nTamanho := TamSX3("AF9_PROJET")[1]
		Else
			nTamanho := X3_TAMANHO
		EndIf
		aAdd(aHeader,{If(Empty(aCampos[nx][5]),X3TITULO(),aCampos[nx][5]),"X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)-1),X3_PICTURE,If(aCampos[nx][3]!=Nil,aCampos[nx][3],X3_TAMANHO),If(aCampos[nx][4]!=Nil,aCampos[nx][4],X3_DECIMAL),aCampos[nx][7]+"('"+aCampos[nx][1]+"','"+aCampos[nx][2]+"','"+cArquivo+"')",X3_USADO,X3_TIPO,cArquivo,X3_CONTEXT})
		aAdd(aStru,{"X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)),X3_TIPO,nTamanho,X3_DECIMAL})
		If aCampos[nx][6]
			aAdd(aAlter,"X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)))
		EndIf		
	ElseIf Substr(aCampos[nx][1],1,1) == "$"
		aAdd(aStru,aClone(&(Substr(aCampos[nx][1],2,Len(aCampos[nx][1])-1)+"(1)")))
	ElseIf Substr(aCampos[nx][1],1,1) == "%"
//%123456789012%C%99%2%12345678901234567890123456789012345%123456789012345678901234567890123456789012345678901234567890
		aAdd(aStru,{"FORM"+StrZero(nx,2,0),Substr(aCampos[nx][1],15,1),Val(Substr(aCampos[nx][1],17,2)),Val(Substr(aCampos[nx][1],20,2))})
	EndIf
Next
aAdd(aStru,{"CTRLNIV","C",1,0})
aAdd(aStru,{"L_I_XO","C",1,0})
aAdd(aStru,{"ALIAS","C",3,0})
aAdd(aStru,{"RECNO","N",14,0})
aAdd(aStru,{"FLAG","L",1,0})

If _oPMSA6001 <> Nil
	_oPMSA6001:Delete()
	_oPMSA6001 := Nil
Endif

_oPMSA6001 := FWTemporaryTable():New( cArquivo )  
_oPMSA6001:SetFields(aStru) 
_oPMSA6001:AddIndex("1", {"RECNO"})

DbSetOrder(0) // Mantem ordem natural

//------------------
//Criação da tabela temporaria
//------------------
_oPMSA6001:Create()	

DbSetOrder(0) // Mantem ordem natural

aStru := {}
aAdd(aStru,{"DESCRI","C",50,0})
aAdd(aStru,{"ALIAS","C",3,0})
aAdd(aStru,{"RECNO","N",14,0})
aAdd(aStru,{"VALOR","N",14,2})

If _oPMSA6002 <> Nil
	_oPMSA6002:Delete()
	_oPMSA6002 := Nil
Endif

_oPMSA6002 := FWTemporaryTable():New( cArquivo2 )  
_oPMSA6002:SetFields(aStru) 
_oPMSA6002:AddIndex("1", {"RECNO"})

//------------------
//Criação da tabela temporaria
//------------------
_oPMSA6002:Create()	
	
nNivelMax := PmsAtuPlan(cRevisa,cArquivo,If(AF8->AF8_NMAX>0,AF8->AF8_NMAX,1),cUsrRev,,aExpand,,,,nIndent)	

DEFINE FONT oFont NAME "Arial" SIZE 0, -10 
DEFINE MSDIALOG oDlg TITLE cTitle OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight 
oDlg:lMaximized := .T.
oDlg:CoorsUpdate()
oDlg:nBottom := nBottom
oDlg:nHeight := nBottom
oDlg:nClientHeight := nBottom

nCol := 1
For nx := 1 to Len(aMenu)
	TButton():New( 02, nCol,aMenu[nx][1],oDlg,aMenu[nx][2],38,12, , , ,.T.)
	nCol += 39
Next

If lConfirma<>Nil
	@ 02,nCol BUTTON STR0004 SIZE 38,12 ACTION (lConfirma:=.T.,oDlg:End()) OF oDlg PIXEL //"Confirma"
	nCol += 39
EndIf

@ 02,nCol BUTTON STR0026 SIZE 38,12 ACTION oDlg:End() OF oDlg PIXEL // "Sair"

dbSelectArea(cArquivo)
dbGotop()
nAlias	:= Select()
oBrowse := TcBrowse():New( 16 ,0 ,nRight/2 ,(nBottom/2)-PMSResH(145) ,,,,oDlg, ,,,,{|| PmsPlnExp(cArquivo,aExpand,@nNivelMax),(PmsAtuPlan(,cArquivo,nNivelMax,cUsrRev,,aExpand,aConfig,,,nIndent),oBrowse:Refresh()) },,oFont,,,,, .F.,cArquivo, .T.,, .F., , ,.f. )
oBrowse:AddColumn( TCColumn():New( "",{ || If((cArquivo)->CTRLNIV=="-",oMenos,If((cArquivo)->CTRLNIV=="+",oMais,If((cArquivo)->CTRLNIV=="*",oAll,If((cArquivo)->CTRLNIV=="!",oCmp,Nil) )))},,,,"RIGHT" , PMSResH(6), .T., .F.,,,, .T., ))
oBrowse:AddColumn( TCColumn():New( "",{ || PmsRetRes((cArquivo)->ALIAS,(cArquivo)->RECNO ) },,,, "LEFT", PMSResH(15), .T., .F.,,,, .T., ))
oBrowse:bChange := {|| Pms600Change(cArquivo,@nTotal,@nQuant) , nPercFat:=0, nQuantFat:=0, nValFat:=0, oGetTot:Refresh(), oPercFat:Refresh(), oGetQtde:Refresh(), oValFat:Refresh() }

For nx := 1 to Len(aCampos)
	If Substr(aCampos[nx][1],1,1)=="$"
		aAuxRet := &(Substr(aCampos[nx][1],2,Len(aCampos[nx][1])-1)+"(2)")
		oBrowse:AddColumn( TCColumn():New( aAuxRet[1], FieldWBlock( aAuxRet[2] , nAlias ),AllTrim(aAuxRet[3]),,, if(aAuxRet[5]=="N","RIGHT","LEFT"), If(aCampos[nx][8]!=Nil,aCampos[nx][8],If(aAuxRet[4]>Len(aAuxRet[1]),(aAuxRet[4]*3),(LEN(aAuxRet[1])*3))), .F., .F.,,,, .F., ) )
	ElseIf Substr(aCampos[nx][1],1,1)=="%"
//%123456789012%C%99%2%12345678901234567890123456789012345%123456789012345678901234567890123456789012345678901234567890
		oBrowse:AddColumn( TCColumn():New( Trim(Substr(aCampos[nx][1],2,12)), FieldWBlock( "FORM"+StrZero(nx,2,0) , nAlias ) ,Substr(aCampos[nx][1],22,35),,, if(Substr(aCampos[nx][1],15,1)=="N","RIGHT","LEFT"), If(Val(Substr(aCampos[nx][1],17,2))>Len(AllTrim(Substr(aCampos[nx][1],2,12))),(Val(Substr(aCampos[nx][1],17,2))*3),(Len(AllTrim(Substr(aCampos[nx][1],2,12)))*3)), .F., .F.,,,, .F., ) )
	Else
		dbSelectArea("SX3")
		dbSetOrder(2)
		If MsSeek(aCampos[nx][1])
			oBrowse:AddColumn( TCColumn():New( Trim(x3titulo()), FieldWBlock( "X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)), nAlias ),AllTrim(X3_PICTURE),,, if(X3_TIPO=="N","RIGHT","LEFT"), If(aCampos[nx][8]!=Nil,aCampos[nx][8],If(X3_TAMANHO>Len(X3_TITULO),(X3_TAMANHO*3),(LEN(X3_TITULO)*3))), .F., .F.,,,, .F., ) )
		EndIf
	EndIf
Next
oBrowse:AddColumn( TCColumn():New( "",{|| " " },,,, "LEFT", PMSResH(5), .T., .F.,,,, .T., ))
dbSelectArea(cArquivo)
oBrowse:Refresh()

//a picture da quantidade sera definaida por quem tiver o maior numero de casas decimais entre a EDT e Tarefa
If (Len(cPictAFC)-Rat('.',cPictAFC)) > (Len(cPictAF9)-Rat('.',cPictAF9))
	cPictQtde := cPictAFC
Else
	cPictQtde := cPictAF9
EndIf

@ (nBottom/2)-PMSResV(105) ,PMSResH(8)   SAY STR0027 PIXEL SIZE PMSResH(65),PmsResV(9) //"Vlr. Total de Venda" 
@ (nBottom/2)-PMSResV(105) ,PMSResH(68)  MSGET oGetTot VAR nTotal Picture "@E 999,999,999.99" When .F. PIXEL SIZE PMSResH(65),PmsResV(9) HASBUTTON

nPercFat := 0
@ (nBottom/2)-PMSResV(90)  ,PMSResH(8)   SAY STR0028 PIXEL SIZE PMSResH(65),PmsResV(9) //"% Faturar"
@ (nBottom/2)-PMSResV(90)  ,PMSResH(68)  MSGET oPercFat VAR nPercFat Picture "@E 999.99 %" Valid Positivo(nPercFat) .And. If(.T.,((nValFat := nTotal*nPercFat/100),(nQuantfat:=nPercFat*nQuant/100 ),(oValFat:SETFOCUS())),Nil) PIXEL SIZE PMSResH(65),PmsResV(9) HASBUTTON

nQuantFat := 0
@ (nBottom/2)-PMSResV(75)  ,PMSResH(8)   SAY STR0029 PIXEL SIZE PMSResH(65),PmsResV(9) //"Quantidade Faturar"
@ (nBottom/2)-PMSResV(75)  ,PMSResH(68)  MSGET oGetQtde VAR nQuantFat Picture cPictQtde Valid Positivo(nQuantFat) .And. If(.T.,(nValFat := nQuantFat/nQuant*nTotal),Nil) PIXEL SIZE PMSResH(65),PmsResV(9) HASBUTTON

nValFat := 0
@ (nBottom/2)-PMSResV(60)  ,PMSResH(8)   SAY STR0030 PIXEL SIZE PMSResH(65),PmsResV(9)  //"Vlr. Faturar"
@ (nBottom/2)-PMSResV(60)  ,PMSResH(68)  MSGET oValFat VAR nValFat Picture "@E 999,999,999.99" Valid Positivo(nValFat) .And. If(.T.,(nPercFat := nValFat/nTotal*100),Nil) PIXEL SIZE PMSResH(65),PmsResV(9) HASBUTTON

@ (nBottom/2)-PMSResV(30)  ,PMSResH(8)   SAY STR0031 PIXEL SIZE PMSResH(65),PmsResV(09) //"Vlr. Total a Faturar"
@ (nBottom/2)-PMSResV(30)  ,PMSResH(68)  MSGET oVTot VAR nValTot Picture "@E 999,999,999.99" When .F. PIXEL SIZE PMSResH(65),9 HASBUTTON

@ (nBottom/2)-PMSResV(90) ,PMSResH(135) BUTTON STR0032 SIZE PMSResH(45),PmsResV(12) ACTION Pms600AddFat(cArquivo2,cArquivo,oBrowse2,oVTot,nPercFat,nValFat,@nValTot) OF oDlg PIXEL When (cArquivo)->ALIAS=="AF9" .Or. (cArquivo)->ALIAS=="AFC" //"Adicionar >>"
@ (nBottom/2)-PMSResV(76) ,PMSResH(135) BUTTON STR0033 SIZE PMSResH(45),PmsResV(12) ACTION Pms600DelFat(cArquivo2,cArquivo,nValFat,oBrowse2,@nValTot,oVTot) OF oDlg PIXEL When !Empty((cArquivo2)->ALIAS) //"<< Remover"

dbSelectArea(cArquivo2)
nAlias	:= Select()
oBrowse2 := TcBrowse():New( (nBottom/2)-PMSResV(120) ,PMSResH(180) ,(nRight/2)-PMSResH(180) ,PMSResH(105) ,,,,oDlg ,,,,,{|| Nil },,oFont,,,,, .F.,cArquivo2, .T.,, .T., , ,.T. )
//oBrowse2 := TcBrowse():New( (nBottom/2)-PMSResV(120) ,PMSResH(180) ,(nRight/2)-PMSResH(180) ,(nBottom/2)-PMSResV(230) ,,,,oDlg ,,,,,{|| Nil },,oFont,,,,, .F.,cArquivo2, .T.,, .T., , ,.T. )
oBrowse2:AddColumn( TCColumn():New( "",{ || PmsRetRes((cArquivo2)->ALIAS,(cArquivo2)->RECNO ) },,,, "LEFT", PMSResH(15), .T., .F.,,,, .T., ))
oBrowse2:AddColumn( TCColumn():New( STR0022 , FieldWBlock( "DESCRI", nAlias ),"@!",,, "LEFT", PMSResH(155), .F., .F.,,,, .F., ) ) //"Faturar"
oBrowse2:AddColumn( TCColumn():New( STR0034 , FieldWBlock( "VALOR", nAlias ),"@E 999,999,999,999.99",,, "LEFT", PMSResH(40), .F., .F.,,,, .F., ) ) //"Valor"

If nFreze <> Nil
	oBrowse:nFreeze	:=	nFreze
Endif                                                                               

ACTIVATE MSDIALOG oDlg

dbSelectArea(cArquivo)
dbCloseArea()

If _oPMSA6001 <> Nil
	_oPMSA6001:Delete()
	_oPMSA6001 := Nil
Endif

Return lConfirma

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms600Change³ Autor ³ Daniel Tadashi Batori ³ Data ³ 10.04.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³funcao executada no bloco oBrowse:bChange                       ³±±
±±³          ³todos os parametros devem ser passados por referencia pois sao  ³±±
±±³          ³utilizados nos valores de faturamento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cArquivo : arquivo com o item selecionado(EDT/Tarefa)           ³±±
±±³          ³nTotal : Valor total de Venda                                   ³±±
±±³          ³nQuant : Quantidade Faturar                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms600Change(cArquivo,nTotal,nQuant)
Local nVal

If (cArquivo)->ALIAS=="AFC"
	AFC->( DbGoto( (cArquivo)->RECNO ) )
	nQuant := AFC->AFC_QUANT
ElseIf (cArquivo)->ALIAS=="AF9"
	AF9->( DbGoto( (cArquivo)->RECNO ) )
	nQuant := AF9->AF9_QUANT
EndIf

nTotal := 0
CalcValFat(@nTotal,(cArquivo)->ALIAS)

If ExistBlock("PMSA600F") .And. (cArquivo)->ALIAS$"AFC|AF9"
	nVal := ExecBlock("PMSA600F", .F., .F., {(cArquivo)->ALIAS,(cArquivo)->RECNO})
	If ValType(nVal)!="N"
		Aviso(STR0005,STR0040,{"Ok"}) //"Atencao!"   'O retorno do Ponto de Entrada "PMSA600F" está incorreto. Favor verificar.'
	Else
		nTotal := nVal
	EndIf
EndIf				

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CalcValFat  ³ Autor ³ Daniel Tadashi Batori ³ Data ³ 19.07.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³funcao que calcula o valor a ser faturado                       ³±±
±±³          ³As tabelas AFC e AF9 deverao estar posicionados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nTotal : Valor total de Venda                                   ³±±
±±³          ³cAlias : Quantidade Faturar                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcValFat(nTotal,cAlias)
Local cFilAF9  := xFilial("AF9")
Local cFilAFC  := xFilial("AFC")
Local cProjeto := ""
Local	cRevisao := ""
Local	cEDT     := ""
Local aAreaAFC	:= AFC->(GetArea())

If cAlias=="AF9"
	If AF9->AF9_FATURA=="1"
		nTotal += AF9->AF9_TOTAL
	EndIf
ElseIf cAlias=="AFC"

	AF9->(DbSetOrder(2)) //AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI+AF9_ORDEM
	If AF9->(DbSeek(cFilAF9+AFC->(AFC_PROJET+AFC_REVISA+AFC_EDT)))
		While cFilAF9+AFC->(AFC_PROJET+AFC_REVISA+AFC_EDT) == AF9->(AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI)
			CalcValFat(@nTotal,"AF9")
			AF9->(DbSkip())
		EndDo
	EndIf
		
	cProjeto := AFC->AFC_PROJET
	cRevisao := AFC->AFC_REVISA
	cEDT     := AFC->AFC_EDT
	AFC->(DbSetOrder(2)) //AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI+AFC_ORDEM
	If AFC->(DbSeek(cFilAFC+cProjeto+cRevisao+cEDT))
		While cFilAFC+cProjeto+cRevisao+cEDT == AFC->(AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI)
			CalcValFat(@nTotal,"AFC")
			AFC->(DbSkip())
		EndDo
	EndIf

EndIf
RestArea(aAreaAFC)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms600AddFat³ Autor ³                       ³ Data ³ 19.07.2007    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona a EDT ou Tarefa no arquivo temporario que serah           ³±±
±±³          ³utilizado para criar um pedido                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cArquivo2: arquivo com os itens que serao faturados(EDT ou Tarefa) ³±±
±±³          ³cArquivo : arquivo com o item selecionado(EDT ou Tarefa)           ³±±
±±³          ³oBrowse2                                                           ³±±
±±³          ³oVTot    : objeto MSGET do "Vlr. Total a Faturar"                  ³±±
±±³          ³nPercFat : "% Faturar"                                             ³±±
±±³          ³nValFat  : "Vlr. Faturar"                                          ³±±
±±³          ³nValTot  : "Vlr. Total a Faturar"                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms600AddFat(cArquivo2,cArquivo,oBrowse2,oVTot,nPercFat,nValFat,nValTot)

Local lPosProj	:= .T.
Local lGrava 	:= .T.
Local nPos 		:= 0
Local cEdtPos   := ""
_lPergVldP 		:= .T. //Seta para perguntar controle itens sem custo

DbSelectArea(cArquivo2)
LOCATE FOR 	(cArquivo2)->ALIAS == (cArquivo)->ALIAS .And. 	(cArquivo2)->RECNO == (cArquivo)->RECNO

If !Found()
	
	If (cArquivo)->ALIAS == "AFC"
		AFC->(MsGoto((cArquivo)->RECNO))
		cEdtPos   := AFC->AFC_EDT
		lPosProj := Upper(AllTrim((cEdtPos))) == Upper(AllTrim((AFC->AFC_EDT)))
		If Pms600VldItPed(AFC->AFC_PROJET, AFC->AFC_REVISA,,.T.,AFC->AFC_EDT,IIF(lPosProj,"","AFC"))     
			AddEDTFat(AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_EDT, cArquivo2, nPercFat)
		EndIf
	
	ElseIf (cArquivo)->ALIAS == "AF9"

		AF9->(DbGoto((cArquivo)->RECNO))
		If AF9->AF9_FATURA = "1" .And. Pms600VldItPed(AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA, .F., AF9->AF9_EDTPAI,"AF9")
			
			nPos := aScan(_aVldPedTar, {|x| x[1] == AF9->AF9_PROJET .And. x[2] == AF9->AF9_REVISA .And. x[3] == AF9->AF9_TAREFA .And. x[4] == AF9->AF9_EDTPAI })  

			If nValFat == 0 .And. nPos > 0 .And. _aVldPedTar[nPos][5] == 1
				lGrava := .F.
			EndIf

			If lGrava
				RecLock(cArquivo2,.T.)
				(cArquivo2)->DESCRI := AF9->AF9_TAREFA + " - " + AF9->AF9_DESCRI
				(cArquivo2)->ALIAS  := (cArquivo)->ALIAS
				(cArquivo2)->RECNO  := (cArquivo)->RECNO
				(cArquivo2)->VALOR  := nValFat
				MsUnlock()
			EndIf
			
		EndIf

	EndIf
	  
	(cArquivo2)->(DbGotop())
	nValTot	:= 0
	While (cArquivo2)->(!Eof())
		nValTot += (cArquivo2)->VALOR
		(cArquivo2)->(DbSkip())
	End
	(cArquivo2)->(DbGotop())
	oVTot:Refresh()
	oBrowse2:Refresh()  
  
Else
	Aviso(STR0005,STR0035,{STR0036},2) //"Atencao!"###"Este item ja foi incluido na lista para faturamento. Verifique o item selecionado."###"Fechar"
EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms600VldItPed³ Autor ³ SQUAD CRM/ FAT      ³ Data ³ 06.02.2020    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida itens sem custo das tarefas e EDT no botão Adicionar        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cProjet: projeto                                                   ³±±
±±³          ³cReview: revisão                                                   ³±±
±±³          ³cTask:   tarefa                                                    ³±±
±±³          ³lAddAll: .T. para EDT, seta _lPergVldP 1 vez                       ³±±
±±³          ³cEDT: EDT                                                          ³±±
±±³          ³cAliasPos: recebe Alias de EDT ou tarefa (AFC/AF9)                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms600VldItPed(cProjet, cReview, cTask, lAddAll, cEDT, cAliasPos)

Local lRet 			:= .T.
Local cAliasTmp	    := ""
Local cMessagem		:= ""
Local cQuery		:= ""	
Local nCusto 		:= 0
Local aArea			:= {}

Default cProjet 	:= ""
Default cReview		:= ""
Default cTask		:= ""
Default nRecno		:= 0
Default lAddAll		:= .F.
Default nOpc 		:= 0

If !Empty(cProjet) .And. !Empty(cReview)
	cAliasTmp	    := GetNextAlias()
	aArea			:= GetArea()

	cQuery := "SELECT AFA.AFA_PROJET, AFA.AFA_REVISA, AFA.AFA_TAREFA, AF9.AF9_EDTPAI, AFA.AFA_CUSTD  "
	cQuery += " FROM 	  " + RetSqlName("AFA") + " AFA "
	cQuery += " INNER JOIN " + RetSqlName("AF9") + " AF9 " 
	cQuery += " ON 	AFA.AFA_FILIAL = AF9.AF9_FILIAL " 
	cQuery += " AND AFA.AFA_PROJET = AF9.AF9_PROJET "
	cQuery += " AND AFA.AFA_REVISA = AF9.AF9_REVISA "
	cQuery += " AND AFA.AFA_TAREFA = AF9.AF9_TAREFA "
	cQuery += " INNER JOIN " +RetSqlName("AFC")+ " AFC "
	cQuery += " ON AF9.AF9_FILIAL = AFC.AFC_FILIAL "
	cQuery += " AND AF9.AF9_PROJET = AFC.AFC_PROJET "
	cQuery += " AND AF9.AF9_REVISA = AFC.AFC_REVISA "
	cQuery += " AND AF9.AF9_EDTPAI = AFC_EDT"
	cQuery += " WHERE AFA.AFA_FILIAL = '" + xFilial("AFA") +  "' " 
	cQuery += " AND AFA.AFA_PROJET = '" + cProjet 	+ "' "
	cQuery += " AND AFA.AFA_REVISA = '" + cReview	+ "' "

	If cAliasPos == "AFC"
		cQuery += " AND AF9.AF9_EDTPAI = '" + cEDT + "' "
	ElseIf cAliasPos == "AF9"
		cQuery += " AND AF9.AF9_EDTPAI = '" + cEDT + "' "
		cQuery += " AND AFA.AFA_TAREFA = '" + cTask + "' "
	EndIf
	
	cQuery += " AND AF9.AF9_FATURA = '1' "
	cQuery += " AND AFA.D_E_L_E_T_ = ' '  "
	cQuery += " AND AF9.D_E_L_E_T_ = ' '  " 
	cQuery += " GROUP BY AFA.AFA_PROJET, AFA.AFA_REVISA, AFA.AFA_TAREFA, AF9.AF9_EDTPAI, AFA.AFA_CUSTD "

	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .F., .T.)

	Do While (cAliasTmp)->(!Eof())
		If (cAliasTmp)->AFA_CUSTD == 0 
			If lAddAll
				cMessagem := STR0041 //"Existe uma ou mais tarefas com itens sem valor de custo."
			Else
				cMessagem := STR0042 //"Essa tarefa possui itens sem valor de custo."
			EndIf
			
			If _lPergVldP
				nOpc := Aviso(STR0005,cMessagem+Chr(10)+STR0043,{STR0045,STR0044,STR0046},2) //"Deseja manter esses itens?",{"Não","Sim","Cancelar"} 
				If lAddAll 
					_lPergVldP := .F.
				EndIf
			EndIf

			nPos := aScan(_aVldPedTar, {|x| x[1] == (cAliasTmp)->AFA_PROJET .And. x[2] == (cAliasTmp)->AFA_REVISA .And. x[3] == (cAliasTmp)->AFA_TAREFA .And. x[4] == (cAliasTmp)->AF9_EDTPAI })  

			If nOpc == 1 .Or. nOpc == 2
				If nPos > 0
					_aVldPedTar[nPos][5] := nOpc
				Else
					aAdd(_aVldPedTar,{(cAliasTmp)->AFA_PROJET,(cAliasTmp)->AFA_REVISA,(cAliasTmp)->AFA_TAREFA,(cAliasTmp)->AF9_EDTPAI,nOpc})
				EndIf
			Else
				lRet := .F. 
			EndIf

		Else
			nCusto += (cAliasTmp)->AFA_CUSTD
		Endif

		(cAliasTmp)->(DBSkip())
	EndDo
	(cAliasTmp)->(dbCloseArea())  
	RestArea(aArea) 
	aSize(aArea,0) 
EndIf 

Return lRet  


Static Function Pms600DelFat(cArquivo2,cArquivo,nValFat,oBrowse2,nValTot,oVTot)
	Local nPos 		:= 0
	Local nLenTask	:= TAMSX3("AF9_TAREFA")[1]

	dbSelectArea(cArquivo2)

	nPos := aScan(_aVldPedTar, {|x| x[3] == SubStr((cArquivo2)->DESCRI,1,nLenTask) })
	If nPos > 0
		aDel(_aVldPedTar,nPos)
		aSize(_aVldPedTar,Len(_aVldPedTar)-1)  
	EndIf 

	RecLock(cArquivo2,.F.,.T.)
	dbDelete()
	MsUnlock()
	dbGotop()
	nValTot	:= 0
	While !Eof()
		nValTot += VALOR
		dbsKip()	
	End
	dbGotop() 
	oVTot:Refresh()
	oBrowse2:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PMS600PV ³ Autor ³ Edson Maricate        ³ Data ³14.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do Pedido de Venda por medicao do projeto          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Arquivo temporario contendo as informacoes de       ³±±
±±³          ³ Medicoes.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Pms600PV(cArquivo2,cTes)

Local aColsC6    := {}
Local aHeadC6    := {}
Local aPedCob    := {}
Local aArea      := GetArea()
Local aDadosCfo  := {} 
Local nDecVend	  := TamSX3("C6_QTDVEN")[2]
Local nz
Local bCampo     := {|nCPO| Field(nCPO) }           
Local nTamDescri := TamSX3("C6_DESCRI")[1]
Local cFilOld   := cFilAnt
Local cVend     := ""
Local cCampo    := ""
Local cItSC6    := StrZero(0,Len(SC6->C6_ITEM))
Local nTotCust  := 0
Local lValContr := .T.
Local nX        := 0
Local nY        := 0
Local nMaxFor   := 0
Local nMaxVend  := Fa440CntVen() 
Local nUsado    := 0
Local aArrayFat := {}
Local aRotCopy  := {}
Local nQtdeFat  := 0
Local nDecPrcven := TamSX3("C6_PRCVEN")[2]
Local nDecValor  := TamSX3("C6_VALOR")[2]
Local nValorTotal := 0
Local aMemosBkp	:= {}
Local nPosVdIt	 := 0
Local cMvPmsCust := GetMV("MV_PMSCUST")
Local lPMSA600AF := ExistBlock("PMSA600AF")
Local lPMA600COL := ExistBlock("PMA600COL")

Default cTes    := ""

Private aheadGrade := {}
Private aColsGrade := {}
Private aheader    := {}
Private acols      := {}
Private n          := 1

Pergunte("MTA410",.F.)

// monta aHeader do SC6
aHeadC6 := {}
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SC6",.T.)
While ( !Eof() .And. SX3->X3_ARQUIVO == "SC6" )
	If ( X3Uso(SX3->X3_USADO) .And.;
			!Trim(SX3->X3_CAMPO)=="C6_NUM" .And.;
			Trim(SX3->X3_CAMPO) != "C6_QTDEMP" .And.;
			Trim(SX3->X3_CAMPO) != "C6_QTDENT" .And.;
			cNivel >= SX3->X3_NIVEL ) 

		Aadd(aHeadC6,{ Trim(SX3->X3_TITULO),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT })
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo

dbSelectArea("SA1")
dbSetOrder(1)
MsSeek(xFilial("SA1")+AF8->AF8_CLIENT+AF8->AF8_LOJA)

// cria as variaveis do Pedido de Venda
dbSelectArea("SC5")
nMaxFor := FCount()
For nX := 1 To nMaxFor
	M->&(EVAL(bCampo,nX)) := CriaVar(FieldName(nX),.T.)
Next nX
M->C5_TIPO    := "N"  
M->C5_CLIENTE := AF8->AF8_CLIENT
M->C5_LOJACLI := AF8->AF8_LOJA
M->C5_LOJAENT := AF8->AF8_LOJA

If AF8->(ColumnPos("AF8_CNO"))>0
	M->C5_CNO := AF8->AF8_CNO
EndIf

// atualiza as informacoes padroes a partir do Cliente
a410Cli("C5_CLIENTE",M->C5_CLIENTE,.F.)
a410Loja("C5_LOJACLI",M->C5_LOJACLI,.F.)
M->C5_TIPOCLI := SA1->A1_TIPO

// preenche o Acols do Pedido de Venda
nUsado := Len(aHeadC6)

dbSelectArea(cArquivo2)
dbGotop()
While !Eof()
	If (cArquivo2)->ALIAS == "AF9"
		AF9->(MsGoto((cArquivo2)->RECNO))
		If !Empty(AF9->AF9_PRODFA)
			aAdd(aArrayFat,{AF9->AF9_PROJET,AF9->AF9_TAREFA,AF9->AF9_PRODFA,NoRound(AF9->AF9_QUANT*(cArquivo2)->VALOR/AF9->AF9_TOTAL,nDecVend),(cArquivo2)->VALOR/NoRound(AF9->AF9_QUANT*(cArquivo2)->VALOR/AF9->AF9_TOTAL,nDecVend),(cArquivo2)->VALOR,{}})
		Else
			nTotCust := 0 
			nIniArray := Len(aArrayFat)

			If !lUsaAJT
				dbSelectArea("AFA")
				AFA->(dbSetOrder(1))
				AFA->(MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA))
				nPosVdIt := aScan(_aVldPedTar, {|x| x[1] == AFA->AFA_PROJET .And. x[2] == AFA->AFA_REVISA .And. x[3] == AFA->AFA_TAREFA })  

				While !Eof() .And. AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA==;
									xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
					aCusto := {}
					PmsCOTPAFA(AFA->(RecNo()), PMS_MAX_DATE,,@aCusto)  

					If aCusto[1] <> 0 .Or. _aVldPedTar[nPosVdIt][5] == 2   //Considera itens com custo zerado

						If cMvPmsCust == "1" .And. AF9->AF9_TOTAL > 0 //Indica se utiliza o custo pela quantidade total ou unitaria
							nQtdeFat := NoRound(AFA->AFA_QUANT*(cArquivo2)->VALOR/AF9->AF9_TOTAL,nDecVend)
						ElseIf cMvPmsCust <> "1" .And. AF9->AF9_TOTAL > 0
							nQtdeFat := NoRound((AFA->AFA_QUANT*AF9->AF9_QUANT)*(cArquivo2)->VALOR/AF9->AF9_TOTAL,nDecVend)
						ElseIf cMvPmsCust =="1" .And. AF9->AF9_TOTAL <= 0//tarefas só com itens sem custo
							nQtdeFat := NoRound(AFA->AFA_QUANT,nDecVend)
						Else
							nQtdeFat := NoRound((AFA->AFA_QUANT*AF9->AF9_QUANT),nDecVend)	
						EndIf

						nTotCust += aCusto[1]
						aAdd(aArrayFat,{AF9->AF9_PROJET,AF9->AF9_TAREFA,Iif(!Empty(AFA->AFA_PRODFA),AFA->AFA_PRODFA,AFA->AFA_PRODUTO),nQtdeFat,0,aCusto[1],{}})

						If lPMSA600AF
							aArrayFat[(Len(aArrayFat))][7] := ExecBlock("PMSA600AF",.F.,.F.,{"AFA"})
						EndIf	
					EndIf
					AFA->(dbSkip())
				End
			Else
				DbSelectArea( "AEL" )
				AEL->( DbSetOrder( 1 ) )
				AEL->( DbSeek( xFilial( "AEL" ) + AF9->( AF9_PROJET + AF9_REVISA + AF9_TAREFA ) ) )
				While AEL->( !Eof() ) .AND. AEL->( xFilial( "AEL" ) + AEL_PROJET + AEL_REVISA + AEL_TAREFA ) == AF9->( AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_TAREFA )
					aCusto := {}

					PmsCOTPAEL( AEL->AEL_PROJET, AEL->AEL_REVISA, AEL->AEL_TAREFA, AEL->AEL_ITEM, PMS_MAX_DATE, @aCusto,,,, AEL->( RecNo() ) )	
					If cMvPmsCust == "1" //Indica se utiliza o custo pela quantidade total ou unitaria
						nQtdeFat := NoRound(AEL->AEL_QUANT*(cArquivo2)->VALOR/AF9->AF9_TOTAL,nDecVend)
					Else
						nQtdeFat := NoRound((AEL->AEL_QUANT*AF9->AF9_QUANT)*(cArquivo2)->VALOR/AF9->AF9_TOTAL,nDecVend)
					EndIf
					nTotCust += aCusto[1]
					aAdd(aArrayFat,{AF9->AF9_PROJET,AF9->AF9_TAREFA,Iif(!Empty(AFA->AFA_PRODFA),AFA->AFA_PRODFA,AFA->AFA_PRODUTO),nQtdeFat,0,aCusto[1],{}})

					If lPMSA600AF
						aArrayFat[(Len(aArrayFat))][7] := ExecBlock("PMSA600AF",.F.,.F.,{"AFA"})
					EndIf	

					AEL->( DbSkip() )
				End
			EndIf

			dbSelectArea("AFB")
			dbSetOrder(1)
			MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			While !Eof() .And. AFB->AFB_FILIAL+AFB->AFB_PROJET+AFB->AFB_REVISA+AFB->AFB_TAREFA==;
								xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
				aCusto := {}
				PmsCOTPAFB(AFB->(RecNo()),PMS_MAX_DATE,,@aCusto)
				If !Empty(AFB->AFB_PRODFA)
					nTotCust += aCusto[1]
					aAdd(aArrayFat,{AF9->AF9_PROJET,AF9->AF9_TAREFA,AFB->AFB_PRODFA,NoRound(1*(cArquivo2)->VALOR/AF9->AF9_TOTAL,nDecVend),0,aCusto[1],{}})

					If lPMSA600AF
						aArrayFat[Len(aArrayFat)][7] := ExecBlock("PMSA600AF",.F.,.F.,{"AFB"})
					EndIf							

				EndIf
				dbSkip()
			End
			If nTotCust > 0
				For nx := nIniArray+1 to Len(aArrayFat)
					nValorTotal       := Round(aArrayFat[nx][6]/nTotCust*(cArquivo2)->VALOR, nDecValor)
					aArrayFat[nx][5] := Round(nValorTotal/aArrayFat[nx][4],nDecPrcven)
					aArrayFat[nx][6] := Round(aArrayFat[nx][5]*aArrayFat[nx][4],nDecValor)
					
				Next
			EndIf
		EndIf

	EndIf
	dbSelectArea(cArquivo2)
	dbSkip()
End

For nz := 1 to Len(aArrayFat)
	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial()+aArrayFat[nz][3]))
		
	aadd(aColsC6,Array(nUsado+1))
	nY := Len(aColsC6)		
	aColsC6[nY,nUsado+1] := .F.
	
	For nX := 1 To nUsado
		Do Case
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_ITEM" )
			cItSC6 := Soma1(cItSC6)
			aColsC6[nY,nX] := cItSC6
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_PRODUTO" )
			aColsC6[nY,nX] := aArrayFat[nz][3]
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_UM" )
			aColsC6[nY,nX] := SB1->B1_UM
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_QTDVEN" )
			aColsC6[nY,nX] := aArrayFat[nz][4]
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_PRCVEN" )
			aColsC6[nY,nX] := aArrayFat[nz][5]
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_VALOR" )
			aColsC6[nY,nX] := aArrayFat[nz][6]
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_TES" ) .And. !Empty(RetFldProd(SB1->B1_COD,"B1_TS"))
			If !Empty(RetFldProd(SB1->B1_COD,"B1_TS"))
				aColsC6[nY,nX] := RetFldProd(SB1->B1_COD,"B1_TS")
			EndIf
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_CF" )
		
			// define o CFO
			aDadosCFO := {}
			Aadd(aDadosCfo,{"OPERNF"  ,"S"})
			Aadd(aDadosCfo,{"TPCLIFOR",SA1->A1_TIPO})
			Aadd(aDadosCfo,{"UFDEST"  ,SA1->A1_EST})
			Aadd(aDadosCfo,{"INSCR"   ,SA1->A1_INSCR})
			Aadd(aDadosCfo,{"CONTR"	  ,SA1->A1_CONTRIB})
			
			aColsC6[nY,nX] := MaFisCfo(,SF4->F4_CF,aDadosCfo)
			
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_SEGUM" )
			aColsC6[nY,nX] := SB1->B1_SEGUM
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_LOCAL" )
			aColsC6[nY,nX] := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_ENTREG" )
			aColsC6[nY,nX] := dDataBase
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_DESCRI" )
			aColsC6[nY,nX] := Padr(SB1->B1_DESC,nTamDescri)
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_PROJPMS" )
			aColsC6[nY,nX] := aArrayFat[nz][1]
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_TASKPMS" )
			aColsC6[nY,nX] := aArrayFat[nz][2]						
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_PRUNIT" )
			aColsC6[nY,nX] :=  aArrayFat[nz][5]
		Case ( AllTrim(aHeadC6[nX,2]) == "C6_QTDLIB" )
			//verifica se eh para sugerir a quantidade liberada
			aColsC6[nY,nX] := if( mv_par01 == 1, aArrayFat[nz][4], 0 )
		OtherWise
			aColsC6[nY,nX] := CriaVar(aHeadC6[nX,2],.T.)
		EndCase
		
	Next nX

	If lPMA600COL
		aColsC6[nY] := ExecBlock("PMA600COL",.F.,.F.,{aColsC6[nY],aHeadC6,aArrayFat[nZ]})
	EndIf

Next nz

// grava o Pedido de Venda
If !Empty(aColsC6)
	Begin Transaction
		aCols   := aColsC6
		aHeader := aHeadC6
		For nX := 1 To Len(aCols)
			MatGrdMont(nX)
		Next nX
		
		If ExistBlock("PMSA600PV")
			ExecBlock("PMSA600PV", .F., .F.)
		EndIf				

		// variaveis Utilizadas pela Funcao a410Inclui
		PRIVATE ALTERA := .F.
		PRIVATE INCLUI := .T.
		PRIVATE cCadastro := STR0019 //"Pedido de Venda"

		aRotCopy := aClone(aRotina)

		aRotina := {{"", "" , 0 , 1},;   
					{"", "" , 0 , 2},;   
					{"", "" , 0 , 3},;	 
					{"", "" , 0 , 4, 2},;
					{"", "" , 0 , 5, 1}}
		aMemosBkp := aClone(aMemos)
		aMemos := {}
		SC5->(a410Inclui(Alias(),Recno(),3,.T.,,,,,,,"C6_PROJPMS|C6_EDTPMS|C6_TASKPMS|C6_VALOR|C6_PRCUNIT"))
		
		aMemos := aClone(aMemosBkp)
		aRotina := aClone(aRotCopy)
	End Transaction
	cFilAnt := cFilOld
EndIf

// restaura a integridade da rotina
cFilAnt := cFilOld
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AddEDTFat³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o valor da EDT a faturar                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProject : projeto da EDT a ser calculado                  ³±±
±±³          ³ cRevisa : revisao da EDT a ser calculado                   ³±±
±±³          ³ cEDT : EDT a ser calculado                                 ³±±
±±³          ³ cDestFile : arquivo temporario que sera utilizado para     ³±±
±±³          ³             guardar os valores a faturar                   ³±±
±±³          ³ nPercFat : percentual a ser faturado                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AddEDTFat(cProject, cRevisa, cEDT, cDestFile, nPercFat)

Local nPos		:= 0
Local lGrava	:= .F.
Local nVlrTotal := 0
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())

DbSelectArea("AF9")
AF9->(dbSetOrder(2)) //AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_EDTPAI + AF9_ORDEM
AF9->(MsSeek(xFilial("AF9") + cProject + cRevisa + cEDT))

While !AF9->(Eof()) .And. AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI ==;
						xFilial("AF9") + cProject + cRevisa + cEDT
		
		If TarefaInc(cDestFile, "AF9", AF9->(Recno()))
			Aviso(STR0037, STR0038 +  AllTrim(AF9->AF9_TAREFA) + ; //"Tarefa ja existe"##"Não foi possível incluir a tarefa "
					" - " + AllTrim(AF9->AF9_DESCRI) + ". " +;
					STR0039, {"OK"})  //"A tarefa já foi inclusa para o faturamento."
		ElseIf AF9->AF9_FATURA=="1" //faturavel 
			
			nVlrTotal := (AF9->AF9_TOTAL * (nPercFat / 100))

			nPos := aScan(_aVldPedTar, {|x| x[1] == AF9->AF9_PROJET .And. x[2] == AF9->AF9_REVISA .And. x[3] == AF9->AF9_TAREFA .And. x[4] == AF9->AF9_EDTPAI })  

			If nVlrTotal == 0 .And. nPos > 0 .And. _aVldPedTar[nPos][5] == 1
				lGrava := .F.
				aDel(_aVldPedTar,nPos)
				aSize(_aVldPedTar,Len(_aVldPedTar)-1)
			Else
				lGrava := .T.   
			EndIf
			
			If lGrava
				RecLock(cDestFile, .T.)
				(cDestFile)->DESCRI := AF9->AF9_TAREFA + " - " + AF9->AF9_DESCRI
				(cDestFile)->ALIAS  := "AF9"
				(cDestFile)->RECNO  := AF9->(Recno())
				(cDestFile)->VALOR  := nVlrTotal // valor a faturar
				MsUnlock()  
			EndIf		
		EndIf
	
	AF9->(dbSkip())  
EndDo

dbSelectArea("AFC")
AFC->(dbSetOrder(2))
AFC->(MsSeek(xFilial("AFC") + cProject + cRevisa + cEDT)) //AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_EDTPAI + AF9_ORDEM

While !AFC->(Eof()) .And. AFC->AFC_FILIAL + AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDTPAI ==;
						xFilial("AFC") + cProject + cRevisa + cEDT

	AddEDTFat(AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_EDT, cDestFile, nPercFat)

	AFC->(dbSkip())	                          
End

RestArea(aAreaAF9)	  
RestArea(aAreaAFC)
Return .T.


Static Function TarefaInc(cDestFile, cAlias, cRecno)
	Local aArea := (cDestFile)->(GetArea())
	Local lRet  := .F.

	dbSelectArea(cDestFile)
	Locate For (cDestFile)->ALIAS == cAlias .And. (cDestFile)->RECNO == cRecno
	
	lRet := (cDestFile)->(Found())
	
	RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
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
Local aRotina 	:= {	{ STR0002, "AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
							{ STR0022, "PMS600Dlg" , 0 , 4},; //"Faturar"
							{ STR0006, "PMS200Leg" , 0 , 6, ,.F.}}   //"Legenda"

If AMIIn(44)
	// adiciona botoes do usuario na EnchoiceBar
	If ExistBlock( "PM600ROT" )
		If ValType( aUsRotina := ExecBlock( "PM600ROT", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMS600VSldºAutor  ³Wilker Valladares   º Data ³  29/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica o saldo das tarefas relacionadas a EDT passada    º±±
±±º          ³ como parametro                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Codigo do Projeto                                  º±±
±±º          ³ ExpC2 - Codigo da EDT                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA600 / MATA410                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS600VSld( cProjeto, cEDT )
Local aArea    := GetArea()          
Local cRevAtu  := Posicione("AF8",1,xFilial("AF8")+cProjeto,"AF8_REVISA") // revisao atual
Local nValor   := 0     

if !Empty(cProjeto) .and. !Empty(cEDT)
	cProjeto := Padr(cProjeto, TamSX3("AF8_PROJET")[1] )
	cEDT  	:= Padr(cEDT, TamSX3("AF9_EDTPAI")[1] )
	
	AF9->( dbsetorder(2) )
	if AF9->( dbseek( xFilial("AF9") + cProjeto + cRevAtu + cEDT ) )
		While ! AF9->( Eof() ) .AND. AF9->(AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI) == xFilial("AF9")+cProjeto+cRevAtu+cEDT
			nValor := nValor + AF9->AF9_TOTAL
			AF9->( dbskip() )
		End
	endif
endif                       

RestArea(aArea)
Return nValor

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PMSResH ³ Autores ³                        ³ Data ³27/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PMSResH(nTam)
Local aRes  :=	GetScreenRes()
Local nHRes	:=	0	// Resolucao horizontal do monitor
	
	// se houver retorno e houve valor no elemento 1
	nHRes := iIf( Len(aRes)>1 .and. aRes[1]>0 ,aRes[1], 800 )
	
	If nHRes <= 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.625 // 0.8
	ElseIf (nHRes >640 .and. nHRes <= 800)	// Resolucao 800x600
		nTam *= 0.78125 //1
	ElseIf (nHRes >800 .and. nHRes <= 1024)	// // Resolucao 1024x768 
		nTam *= 1 // 1.28
	Else	// Acima
		nTam *= 1.25
	EndIf
	
Return Int(nTam)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PMSResV ³ Autores ³                        ³ Data ³27/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao vertical do Monitor do Usuario.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PMSResV(nTam)
Local aRes  :=	GetScreenRes()
Local nVRes	:=	0	// Resolucao vertical do monitor
	
	// se houver retorno e houve valor no elemento 1
	nVRes := iIf( Len(aRes)>1 .and. aRes[2]>0 ,aRes[2], 600 )
	
	If nVRes <= 480	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.625 // 0.8
	ElseIf (nVRes >480 .and. nVRes <= 600)	// Resolucao 800x600
		nTam *= 0.78125 //1
	ElseIf (nVRes >600 .and. nVRes <= 768)	// // Resolucao 1024x768 
		nTam *= 1
	Else // acima
		nTam *= 1.333333
	EndIf
	
	// tratamento para tema "TEMAP10"
	If "P10" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "TEMAP10") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
	
Return Int(nTam)

