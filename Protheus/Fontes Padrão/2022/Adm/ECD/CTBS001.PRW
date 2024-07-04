#INCLUDE "CTBS001.ch"
#INCLUDE "PROTHEUS.CH"                         
#INCLUDE 'DBTREE.CH'
#INCLUDE "ECD.CH"
#include 'fwlibversion.ch'


//AMARRACAO LOGO

Static __lDefTop	:= IfDefTopCTB()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS001   บAutor  ณEquipe CTB          บ Data ณ  02/23/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ctbs001()  
Local oDlg 
Local oWin01			// Painel 1
Local oWin02			// Painel 2
Local oWin03 			// Painel 3
Local oFWLayer 
Local oBarTree
Local oFont
Local oRegCS0
Local oGetCS0

Local aArea			:= GetArea()
Local aHeader		:= {}
Local aCols			:= {} 
Local aScreen 		:= GetScreenRes()
Local aEmp			:= {}
Local aButtTree		:= {}
Local aButtEnt 		:= {}
Local aSize 		:= MsAdvSize(,.F.,400)
Local nColorAnt
Local nX			:= 0

Local bReg_Memory 	:= {|cAlias, lGet_Incl | lGet_Incl := If(lGet_Incl == NIL,  .F., lGet_Incl),dbSelectArea(cAlias),RegToMemory(cAlias,lGet_Incl) } 
Local bAtua_Enchoice:= {|oEnch, cAlias, lGet_Incl |Eval(bReg_Memory,cAlias,lGet_Incl),oEnch:EnchRefreshAll() }
Local bActHide		:= {|| oWin02:Hide(),oWin03:Hide() }
Local bAction		:= {|| If( RefreshForm(),( oWin02:Show(),oWin03:Show(),Eval(bAtua_Enchoice, oGetCS0, "CS0")),NIL)}

//Local bInclRev		:= {|| If( oTree:GetCargo() !='ECF', CTBS010( GetCodEmp(), GetType(), bAddNode), CTBS101(GetCodEmp(),GetType(),bAddNode) ), RefreshForm() }
Local bInclRev		:= {|| CtbS001Mod( oTree, bAddNode) }

Local bExclRev		:= {|| ExcluiEscrit( GetCodRev(),GetCodEmp()) }
Local bImpDiario	:= {|| CTBS040( GetCodEmp(), oTree, bAddNode ) , /*CriaArvCS0(aEmp,oTree,bAction,bActHide,.F.)*/, RefreshForm() }
Local bVerBase		:= {|| If( oTree:GetCargo() != 'ECF',CTBS002(GetCodEmp()),MsgInfo(STR0025))} //"Op็ใo nใo disponํvel para essa obriga็ใo! Realizar verifica็ใo pelo m๓dulo TAF (SIGATAF)."
Local bSair			:= {|| oDlg:End() }
//Local bGerText		:= {|| If( !( oTree:GetCargo() $ 'ECF'),CTBS020(GetCodRev()),CTBS103(GetCodRev()) ) }
Local bGerText      := {|| CtbS001Ger( oTree:GetCargo(), GetCodRev() ) }
Local bVisualiza	:= {|| CTBS030( GetCodRev() ) }
Local bAtuHash		:= {|| CTBS012( GetCodRev(),GetCodEmp()) }
Local bSelecConta	:= {|| CTBS060( GetCodEmp(), GetCodRev())}
Local bNtsExpli 	:= {|| CtbsSel() } 
Local bArqRTF		:= {|| CtbGrvJ800() }
Local lFWCodFil   	:= .T.
Local lGestao		:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa
//Local bValidEscr	:= {|| EcdVldErro(GetCodRev())}
Local bAddNode     	:= {|| oTree:AddItem( STR0014 + CS0->CS0_CODREV + " - " + CS0->CS0_TIPLIV/*cPrompt*/, oTree:GetCargo()+CS0->CS0_CODEMP+CS0->CS0_CODREV/*cCargo*/, "IndicatorCheckBox", "IndicatorCheckBoxOver", 2/*nType*/, bAction, /*bRClick*/, /*bDblClick*/ ) } //"Revisใo - "
Local cLib
//-----------------------------------------------
// Necessario para chamar os cadastros
//----------------------------------------------- 
Private oTree
Private aCampos		:= {'CS2_CODREV','CS2_CODEMP','CS2_CODFIL','CS2_NOMEEM','CS2_CNPJ','CS2_UF','CS2_NOMFIL','CS2_SITESP','CS2_ENTREF'}
Private cCadastro
Private oBarEntid
Private oScr    


//Tratamento para Dados Protegidos
If FindFunction("CTPROTDADO") .And. !CTPROTDADO()
	Return
EndIf

//Tratamento para ver se Binแrio, LIB ou Dbacess estใo atualizados
If GetRPORelease() >= "12.1.023"
	 If !(AMBHELP())
	 	Return
	 EndIf 
EndIf

//Validar se foi executado o Validador do ECD - CTBS480

If GetRPORelease() >= "12.1.033"  .and. !verificaValidacaoEcd() 
   Return
EndIf

If GetRemoteType(@cLib) <= 1
  DEFINE DIALOG oDlg TITLE STR0038 FROM 040,040 TO 220,930 PIXEL // "ECD/ECF - Central Escritura็ใo"
 
    // Usando o New     
    oTBitmap1 := TBitmap():New(01,01,090,1610,,"banner",.T.,oDlg,;
        {||ShellExecute( "Open", "http://tdn.totvs.com/display/PROT/Contabilidade+Gerencial", "", "C:\", 1 ), oDlg:End()},,.F.,.F.,,,.F.,,.T.,,.F.)
    oTBitmap1:lAutoSize := .T.

    ACTIVATE DIALOG oDlg CENTERED
EndIf

//-----------------------------------------------
// Tratativa para garantir a sele็ใo das filiais
//-----------------------------------------------
If ! GetEmpMarcadas( aEmp )
	Return	.F.
Endif 

//-----------------------------------------------
// Monta o Header 
//-----------------------------------------------
aHeader := CriaHeader()

//-----------------------------------------------
// MONTAGEM DA TELA 
//-----------------------------------------------
DEFINE DIALOG oDlg TITLE STR0011  FROM aSize[7],0 to aSize[6],aSize[5]  PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP) //"Empresas"

//-----------------------------------------------
// Cria instancia do fwlayerณ
//----------------------------------------------- 
oFWLayer := FWLayer():New()

//-----------------------------------------------
// Inicializa componente passa a Dialog criada,o 
//   segundo parametro ้ para cria็ใo de um botao 
//   de fechar utilizado para Dlg sem cabe็alho. 		  
//----------------------------------------------- 
oFWLayer:Init( oDlg, .T. )

//-----------------------------------------------
// Efetua a montagem das colunas das telas
//-----------------------------------------------
oFWLayer:AddCollumn( "Col01", 30, .T. )
oFWLayer:AddCollumn( "Col02", 70, .T. )

//-----------------------------------------------
// Habilita a op็ใo de Split
//-----------------------------------------------
oFWLayer:SetColSplit( "Col01", CONTROL_ALIGN_RIGHT,, {|| .T. } )

//--------------------------------------------------------------------------------------
// Cria windows passando, nome da coluna onde sera criada, nome da window			 	
//   titulo da window, a porcentagem da altura da janela, se esta habilitada para click,	
//   se ้ redimensionada em caso de minimizar outras janelas e a a็ใo no click do split 	
//--------------------------------------------------------------------------------------
oFWLayer:AddWindow( "Col01", "Win01", STR0024, 100, .F., .T., ,,) 			//"Tipo de Escritura็ใo"
oFWLayer:AddWindow( "Col02", "Win02", STR0012, 50 , .F., .T., {|| .T. },,) 	//"Cabe็alho da Revisใo"
oFWLayer:AddWindow( "Col02", "Win03", STR0013, 50 , .F., .T., {|| .T. },,) 	//"Detalhes da Revisใo - SPED"

//-----------------------------------------------
// Painel 1					  
//-----------------------------------------------
oWin01	:= oFWLayer:GetWinPanel('Col01','Win01')
oTree	:= Xtree():New(00,00,oWin01:NCLIENTHEIGHT*.45,oWin01:NCLIENTWIDTH*.50, oWin01)

//-----------------------------------------------
// Cria a arvore (Pai e Filho)
//-----------------------------------------------
CriaArvCS0(aEmp,oTree,bAction,bActHide)

//-----------------------------------------------
//Adiciona as barras dos bot๕es
//-----------------------------------------------
DEFINE BUTTONBAR oBarTree SIZE 10,10 3D BOTTOM OF oWin01
oButtTree		:= thButton():New(01,01, STR0001, oBarTree,  bVerBase,30,20,) 	// Verif Base
oButtTree		:= thButton():New(01,01, STR0003, oBarTree,  bInclRev,25,20,) 	// Incluir
oButtTree		:= thButton():New(01,01, STR0004, oBarTree,  bExclRev,25,20,) 	// Excluir
oButtTree		:= thButton():New(01,01, STR0020, oBarTree,  bImpDiario,30,20,)	// Imp Razao
oButtTree		:= thButton():New(01,01, STR0005, oBarTree,  bSair,25,20,)		// Sair
oButtTree:cTitle := "Sair"

//-----------------------------------------------
// Painel 2					  
//-----------------------------------------------
oWin02 := oFWLayer:getWinPanel('Col02','Win02')

//-----------------------------------------------
// Adiciona os controles do painel 2
//-----------------------------------------------
Eval(bReg_Memory,"CS0",.T.)
oGetCS0 := CtbCreateGet("CS0",2, 2, oWin02) 
If lGestao
 	oGetCS0:SetText('CS0_CODFIL',STR0023)//"Empresa/Unidade/Filial"
EndIf	

oGetCS0:EnchRefreshAll()

//-----------------------------------------------
//Adiciona as barras dos bot๕es
//-----------------------------------------------
DEFINE BUTTONBAR oBarEntid SIZE 10,10 3D BOTTOM OF oWin02

oButtEnt		:= thButton():New(01,01, STR0007, oBarEntid,  bVisualiza,30,20,)	//Visualizar
oButtEnt		:= thButton():New(01,01, STR0009, oBarEntid,  bAtuHash,30,20,)		//Cod. Hash
oButtEnt		:= thButton():New(01,01, STR0021, oBarEntid,  bSelecConta,30,20,)	//Sel. Conta
oButtEnt		:= thButton():New(01,01, STR0032, oBarEntid,  bNtsExpli,50,20,)		//Notas Explicativas
oButtEnt		:= thButton():New(01,01, STR0040, oBarEntid,  bArqRTF,50,20,) 		//Outras Dem. RTF
oButtEnt		:= thButton():New(01,01, STR0006, oBarEntid,  bGerText,60,20,)		//Gerar Arquivo
oButtEnt:Align 	:= CONTROL_ALIGN_RIGHT 
oButtEnt:cTitle	:= STR0041 //Gerar Arq.

//-----------------------------------------------
// Painel 3					  
//-----------------------------------------------
oWin03 := oFWLayer:getWinPanel('Col02','Win03')

//-----------------------------------------------
// Cria a getdados para se apresentado no painel 3
//-----------------------------------------------
oGetD:= MsNewGetDados():New(010,010,050,335,0,,,,{},/*freeze*/,50,/*fieldok*/,/*superdel*/,/*delok*/,oWin03,aHeader,aCols)
oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//-----------------------------------------------
//Esconde os dados dos paineis 2 e 3 ao iniciar
//-----------------------------------------------
oWin02:Hide()
oWin03:Hide()

//-----------------------------------------------
//Fun็ใo utilizada para atualizar o aCols da 
//  GetDados, ao iniciar o FWlayer
//-----------------------------------------------
RefreshForm()

ACTIVATE DIALOG oDlg CENTERED

RestArea( aArea )

Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbCreateGetบAutor  ณEquipe CTB        บ Data ณ  02/24/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbCreateGet(cAlias, nOpcx, nOpcao2, oWindow, lOneColumn)
Local aArea    	:= GetArea()
Local oGet

Private aTELA[0][0]
Private aGETS[0]

Default lOneColumn := .F.

oGet := MsMGet():New(cAlias,(cAlias)->(RecNo()),nOpcx,,,,,{0,0,60,300},,nOpcao2,,,,oWindow) //,,,lOneColumn)
oGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

RestArea( aArea )
Return( oGet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaArvCS0บAutor  ณEquipe CTB          บ Data ณ  02/24/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณCria a arvore (Pai e Filho) do painel 11                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaArvCS0( aEmp, oTree, bAction, bActHide , lCria )
Local aArea    	:= GetArea()
Local aCS0A		:= {}	//ECF
Local aCS0E		:= {}	//ECD
Local aCS0F		:= {}	//FCONT
Local aCS0L		:= {}	//LALUR
Local lFWCodFil := .T.
Local lGestao	:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa
Local lFilEmp   := SuperGetMv("MV_FILTEMP", .F., .F.) //Indica se filtra as revis๕es por empresa/filial - Gestใo Corporativa
Local cEmpFil   := IIF(lGestao, FWCompany()," ") //Codigo da empresa a ser filtrada
Local cFilCod   := ""  //C๓digo da filial a ser filtrada
Local aSM0		:= AdmAbreSM0() //Armazeno o conte๚do do Sigamat
Local nInc      := 0 //Contador a ser utilizado na varredura do Sigamat
Local cFilTree  := "" //Descri็ใo da filial a ser exibida no cabe็alho da แrvore

Local aCS0Aux 	:= {}
Default lCria   := .T. 

oTree:BeginUpdate()
oTree:Reset()

DbSelectArea( "CS0" )
DbGotop()

If lGestao .And. lFilEmp //Se for gestใo corporativa e o parametro MV_FILTEMP igual a .T. 
	For nInc := 1 To Len( aSM0 ) //Percorrer o array aSM0 com as filiais 
		If aSM0[nInc][3] == cEmpFil .And. aSM0[nInc][2] == cFilAnt //Se a empresa e a filial forem iguais a empresa e filial logada
			cFilTree := Alltrim(aSM0[nInc][17]) //Armazeno a descri็ใo da filial
			cFilCod  := Alltrim(aSM0[nInc][2]) //Armazeno o c๓digo da filial
			Exit
		EndIf
	Next
EndIf
 
While CS0->(!Eof())

	aCS0Aux := {CS0->CS0_FILIAL, CS0->CS0_CODREV, CS0->CS0_CODEMP, CS0->CS0_CODFIL, CS0->CS0_UPDATE, CS0->CS0_TIPLIV, CS0->CS0_USER, CS0_REVSUP, CS0_REVCAD , CS0->CS0_ECDREV, lCria }
	
	//------------------------------------------------
	// Registros da ECF
	//------------------------------------------------
	If CS0->CS0_ECDREV == 'ECF'  
		aAdd(aCS0A, aCS0Aux)

	//------------------------------------------------
	// Registros da ECD	
	//------------------------------------------------
	ElseIf CS0->CS0_ECDREV == 'ECD'  
		
		If lGestao .And. lFilEmp //Se for gestใo corporativa e o parametro MV_FILTEMP igual a .T.
			If cFilCod == Alltrim(CS0->CS0_CODFIL) //Se o codigo da filial corrente ้ a mesma da escritura็ใo gerada adiciono na แrvore
				aAdd(aCS0E, aCS0Aux)
			EndIf
		Else
			aAdd(aCS0E, aCS0Aux) //Paramentro MV_FILTEMP igual a .F. alimento a แrvore com o padrใo
		EndIf
	
	//------------------------------------------------
	// Registros do Fcont
	//------------------------------------------------
	ElseIf CS0->CS0_ECDREV == 'FCO'
		aAdd(aCS0F, aCS0Aux)

	//------------------------------------------------
	// Registros do LALUR
	//------------------------------------------------
	ElseIf CS0->CS0_ECDREV == 'LAL'
		aAdd(aCS0L, aCS0Aux)
	Endif
	
	CS0->(dbSkip())

EndDo

If !lFilEmp //MV_FILTEMP igual a .F. executo o padrใo apresentando a empresa no cabe็alho da แrvore
	oTree:AddTree( aEmp[1,4],"IndicatorCheckBox","IndicatorCheckBoxOver",'EMPRESA',bActHide)
Else
	oTree:AddTree( cFilTree,"IndicatorCheckBox","IndicatorCheckBoxOver",'EMPRESA',bActHide) //MV_FILTEMP igual a .T. apresento a descri็ใo da filial logada
EndIf
	//------------------------------------------------
	//O cargo ECD ou FCO deve conter apenas 3 posicoes
	//  pois vai fazer parte do cargo dos nos filhos
	//------------------------------------------------
		
	//ECD
	oTree:AddTree( 'ECD'  ,"IndicatorCheckBox","IndicatorCheckBoxOver",'ECD',bActHide)
	LoadTree( oTree , 'ECD', aCS0E, bAction )
	oTree:EndTree()

	//FCO
	oTree:TreeSeek( 'EMPRESA')
	oTree:AddTree( 'FCONT',"IndicatorCheckBox","IndicatorCheckBoxOver",'FCO',bActHide)
	LoadTree( oTree , 'FCO', aCS0F, bAction )
	oTree:EndTree()

	//ECF
	oTree:TreeSeek( 'EMPRESA')
	oTree:AddTree( 'ECF'  ,"IndicatorCheckBox","IndicatorCheckBoxOver",'ECF',bActHide)
	LoadTree( oTree , 'ECF', aCS0A, bAction )
	oTree:EndTree()
	
	oTree:TreeSeek( 'EMPRESA')
	oTree:AddTree( 'LALUR'  ,"IndicatorCheckBox","IndicatorCheckBoxOver",'LAL',bActHide)
	LoadTree( oTree , 'LAL', aCS0L, bAction )
	oTree:EndTree()

oTree:EndTree()

oTree:EndUpdate()
oTree:Refresh()

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadTree   บAutor  ณEquipe CTB         บ Data ณ  02/24/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณcarrega otree                                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadTree( oTree , cCargo, aCargo, bAction)
Local nY

For nY := 1 To Len(aCargo)
	oTree:TreeSeek(cCargo)
	oTree:AddTree(STR0014 + aCargo[nY][2] + " - " + aCargo[nY][6],; //descricao do node###"Revisใo - "
						"IndicatorCheckBox", ; //bitmap fechado
						"IndicatorCheckBoxOver",; //bitmap aberto
						cCargo+aCargo[nY][3]+aCargo[nY][2] , ;  //cargo (id)
						bAction ; //bAction - bloco de codigo para exibir
					)
	oTree:EndTree()
Next

Return oTree

                                                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRefreshFormบAutor  ณEquipe CTB         บ Data ณ  02/24/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza o aCols da getDados                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RefreshForm()
Local lRet		:= .F.
Local cCargo	:= ""
Local cAlias 	:= ''
Local cQuery 	:= ''
Local cCodFil	:= ''
Local cCodEmp	:= ''

If ValType(oTree:GetCargo()) == 'C'
	cCargo = Substr( oTree:GetCargo(),6,6)
Endif

cCodEmp	:= GetCodEmp()

//Pesquisa a Filial do registro
IF __lDefTop
	cAlias := "TMPREV"
	
	cQuery := "SELECT CS0_FILIAL CODFIL" ;
	        + "  FROM " + RetSqlName("CS0") + " CS0 " ;
	        + "  WHERE CS0.CS0_CODEMP = '" + cCodEmp + "'" ;
	        + "  AND CS0.CS0_CODREV   = '" + cCargo  + "'" ;
	        + "  AND D_E_L_E_T_ <> '*' "
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias)
	
	cCodFil := (cAlias)->CODFIL
	
	DbSelectArea(cAlias)
	(cAlias)->( DbCloseArea())
Endif

DbSelectArea("CS0")
DbSetOrder(1)

If MsSeek( cCodFil + cCargo )
	CriaAcolsCS2( CS0->CS0_CODREV, cCodFil )
	lRet := .T.
EndIf

//Quando ECF alterar a mensagem
If CS0->CS0_ECDREV $ 'ECF|LAL'
	oButtEnt:cTitle	:= STR0039 //"Exporta Dados"
Else
	oButtEnt:cTitle	:= STR0006 //"Gerar Arq."
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaHeaderบAutor  ณEquipe CTB          บ Data ณ  02/24/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o aHeader						                   	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaHeader()
Local 	aArea		:= GetArea()
Local aHeader 	:= {}
Local nIx		:= 0
Local lFWCodFil   	:= FindFunction( "FWCodFil" )
Local lGestao		:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa

DbSelectArea( "SX3" )
DbSetOrder(2)

For nIx := 1 To Len( aCampos )
	If SX3->( MsSeek( aCampos[ nIx ] ) )
		aAdd( aHeader, {AlLTrim( X3Titulo() )	, ;	// 01 - Titulo
		SX3->X3_CAMPO	, ;	// 02 - Campo
		SX3->X3_Picture	, ;	// 03 - Picture
		SX3->X3_TAMANHO	, ;	// 04 - Tamanho
		SX3->X3_DECIMAL	, ;	// 05 - Decimal
		SX3->X3_Valid  	, ;	// 06 - Valid
		SX3->X3_USADO  	, ;	// 07 - Usado
		SX3->X3_TIPO   	, ;	// 08 - Tipo
		SX3->X3_F3		, ;	// 09 - F3
		SX3->X3_CONTEXT	, ;	// 10 - Contexto
		SX3->X3_CBOX	, ; // 11 - ComboBox
		SX3->X3_RELACAO	} )	// 12 - Relacao
			
		If ALLTRIM(aCampos[ nIx ]) == 'CS2_CODFIL'
			aHeader[Len(aHeader)][01] := IIF(lGestao,STR0023,aHeader[Len(aHeader)][01]) // "Empresa/Unidade/Filial"
		EndIf

		
	Endif
Next

RestArea( aArea )

Return aHeader

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaAcolsCS2บAutor  ณEquipe CTB        บ Data ณ  02/25/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria e atualiza o aCols                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaAcolsCS2( cChave, cCodFil  )
Local aArea    		:= GetArea()
Local aStruct	 	:= {}

Local cAliasCS2	    := "CS2"
Local cFilCS2	 	:= ''
Local cCols			:= ""
Local nX			:= 0

Default cChave 		:= ""
Default	cCodFil		:= xFilial("CS2")

cFilCS2	 := cCodFil

If __lDefTop
	cQuery	:= "SELECT * FROM " + RetSQLTab( "CS2" ) ;
			+ "  WHERE CS2_FILIAL = '" + cFilCS2 + "'";
			+ "    AND CS2.CS2_CODREV = '" + cChave + "'" ;
			+ "    AND D_E_L_E_T_ = ''"
   
	cQuery := ChangeQuery(cQuery) 
	
	cAliasCS2 := GetNextAlias()
	
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCS2,.T.,.T.)
	
	aStruct   := CS2->(dbStruct())
	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C"
			TcSetField( cAliasCS2, aStruct[nX][1], aStruct[nX][2], aStruct[nX][3], aStruct[nX][4] )
		EndIf
	Next nX
Else
	DbSelectArea( "CS2" )
	DbSetOrder(1)
	MsSeek( cFilCS2 + cChave ) 
EndIf
 
For nX := 1 To Len( aCampos )
	cCols += cAliasCS2 + "->" + aCampos[nX] + iif( Len( aCampos ) > nX , "," , "" )
Next

aCols := {}

dbSelectArea(cAliasCS2)
DbGoTop()
While (cAliasCS2)->CS2_FILIAL == cFilCS2;
		.And. (cAliasCS2)->CS2_CODREV == cChave;
 		.And. (cAliasCS2)->( !Eof() ) 
 		

	aAdd(aCols,{(cAliasCS2)->CS2_CODREV,;
				(cAliasCS2)->CS2_CODEMP,;
				(cAliasCS2)->CS2_CODFIL,;
				(cAliasCS2)->CS2_NOMEEM,;
				(cAliasCS2)->CS2_CNPJ,;
				(cAliasCS2)->CS2_UF,;
				(cAliasCS2)->CS2_NOMFIL,;
				(cAliasCS2)->CS2_SITESP,;
				(cAliasCS2)->CS2_ENTREF,.F.})

	dbSkip()
EndDo

oGetD:Acols := aCols
oGetD:ForceRefresh()

If __lDefTop
	(cAliasCS2)->( dbCloseArea() )
	dbSelectArea( "CS2" )
EndIf

RestArea( aArea )

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExcluiEscritบAutor  ณMicrosiga         บ Data ณ  04/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclui a escritura็ใo de acordo com a posi็ใo               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExcluiEscrit(cCodRev, cEmp)

Local aArea    	:= GetArea()
Local nx		:= 0
Local cCommand	:= ""
Local aTabelas	:= {"CS0","CS1","CS2","CS3","CS4","CS5","CS6","CS7","CS8","CS9","CSA","CSB","CSC","CSD","CSE","CSF","CSG","CSX","CSY","CSJ", "CSK", "CSL", "CSM", "CSN", "CSO","CSZ", "CSP", "CSR", "CST","CSS"}
Local cTable
Local lDelDb    := SuperGetMV("MV_CTBDLRV",.T.,.F.)//Default Falso

Default cCodRev	:= ""
Default cEmp	:= ""

If !Empty(cCodRev) .And. !Empty(cEmp) .And. MsgNoYes( STR0018 + cCodRev + " ? ", STR0019 ) //"Deseja realizar a exclusใo da revisใo "
	If __lDefTop
		For nX := 1 To	Len(aTabelas)
			If AliasInDic(aTabelas[nX])
				cTable := RetSqlName(aTabelas[nX])
				If !Empty(cTable)
					cChaveUnica := tcInternal(13, Alltrim(cTable))
					if !lDelDb
						If !Empty(cChaveUnica)
							cCommand:= "UPDATE " + cTable + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ ";
									+ "  WHERE " + aTabelas[nX] + "_CODREV = '" + cCodRev + "' ";
									+ "    AND " + aTabelas[nX] + "_FILIAL = '" + xFilial(aTabelas[nX]) + "'"
						else
							cCommand:= "UPDATE " + cTable + " SET D_E_L_E_T_ = '*' ";
									+ "  WHERE " + aTabelas[nX] + "_CODREV = '" + cCodRev + "' ";
									+ "    AND " + aTabelas[nX] + "_FILIAL = '" + xFilial(aTabelas[nX]) + "'"
						End
					else
							cCommand := " DELETE FROM  "+ cTable 
							cCommand += " WHERE "  + aTabelas[nX] + "_FILIAL = '" + xFilial(aTabelas[nX]) + "'"
							cCommand += " AND "+ aTabelas[nX] + "_CODREV = '" + cCodRev + "'"
					endIf		

					If TcSqlExec( cCommand ) <> 0
						UserException( STR0016 + cCodRev + CRLF + STR0017 + aTabelas[nX] + CRLF + TCSqlError() ) //"Erro na exclusใo da revisใo: "
					EndIf
				EndIf
			EndIf
	   	Next
	Else
		For nX := 1 To	Len(aTabelas)
			If AliasInDic(aTabelas[nX])
				DbSelectArea(aTabelas[nX])
				DbSetOrder(1) 
				
				If MsSeek( xFilial(aTabelas[nX]) + Substr( oTree:GetCargo() ,6,6)  )
					RecLock(aTabelas[nX],.F.) 
					DbDelete() 
					MsUnLock() 
				EndIf
			EndIf 
		Next
	EndIf 
	
	//Exclui o item selecionado
	oTree:DelItem() 

	//Atualiza a o objeto a Arvore
	oTree:Refresh()

	MsgInfo( STR0015 ) //"Revisใo excluida com sucesso."
Endif

RestArea(aArea)

Return
      


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS001   บAutor  ณMicrosiga           บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ                       w
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetCodRev()
Local cCargo := ""

If ValType(oTree:GetCargo()) == "C"
	cCargo = Substr( oTree:GetCargo(),6,6)
Endif

Return cCargo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS001   บAutor  ณMicrosiga           บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetCodEmp()  
Local cEmpECD := cEmpAnt
/*
If ValType( oTree:GetCargo() ) == "C"
	cEmpECD := Substr( oTree:GetCargo(), 1, Len( cEmpAnt ) )
EndIf
*/	
Return cEmpECD
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetType บAutor  ณMicrosiga           บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetType()

Return Alltrim( oTree:GetCargo() )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbS001Mod บAutor  ณMicrosiga          บ Data ณ  07/12/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  A็oes do botao Incluir na Central da Escrituracao         บฑฑ
ฑฑบ          ณ                                                            บฑฑ                       w
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbS001Mod( oTree, bAddNode)
If oTree:GetCargo() == 'ECD'
	CTBS010( GetCodEmp(), GetType(), bAddNode)
ElseIf oTree:GetCargo() == 'FCO'
	CTBS010( GetCodEmp(), GetType(), bAddNode)
ElseIf oTree:GetCargo() == 'ECF'
	CTBS101(GetCodEmp(),GetType(),bAddNode)
ElseIf oTree:GetCargo() == 'LAL'
	CTBS301(GetCodEmp(),GetType(),bAddNode)
EndIf

RefreshForm()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbS001Ger บAutor  ณMicrosiga          บ Data ณ  07/12/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  A็oes do botao Gerar Arq/ Exportar Dados                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ                       w
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbS001Ger( cCargo, cCodRev )
Local cModEsc := Left(cCargo, 3)
Local oProcess

If cModEsc $ "ECD|FCO"
		CTBS020( cCodRev )

ElseIf cModEsc $ "ECF"
		CTBS103( cCodRev )

ElseIf cModEsc $ "LAL"

		oProcess:= MsNewProcess():New( {|lEnd| CTBS301GER( cCodRev, oProcess, "TAFST1" ), EcdGetMsg()} )
		oProcess:Activate()

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CtbsSel()
Sele็ใo de Notas Explicativas J100 / J150 / J210

@author Andr้ Brito
@since 05/02/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------

Static Function CtbsSel()

Local oDlg
Local oRadio
Local nRadio
Local nOpca       := 1
Local cReg        := ''
Local cRevCod     := ''
Local lRetDem	  := .F.
Local lLayout7	  := .F.

If CS0_TIPLIV == 'A' .Or. CS0_TIPLIV == 'Z'
	MsgInfo(STR0037) //"Este livro nใo possui registros J100 / J150 / J210"
	Return
EndIf

While nOpca == 1 

	DEFINE MSDIALOG oDlg FROM  94,1 TO 273,293 TITLE OemToAnsi(STR0032) PIXEL // "Notas Explicativas
	
	@ 10,17 Say OemToAnsi(STR0036) SIZE 150,7 OF oDlg PIXEL //"Notas explicativas dos registros:"
	
	@ 27,07 TO 72, 140 OF oDlg  PIXEL
	
	@ 35,10 Radio 	oRadio VAR nRadio;
		ITEMS STR0033,; //J100 - Balan็o Patrimonial
			  STR0034,; //J150 - Demonstra็ใo dos Resultados
			  STR0035;  //J210 - DLPA/DMPL
		3D SIZE 100,10 OF oDlg PIXEL
	
	DEFINE SBUTTON FROM 75,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
	DEFINE SBUTTON FROM 75,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)

	If nOpca == 1
		cRevCod  := CS0->CS0_CODREV //Imprescindivel passar o c๓digo da revisใo para o filtro
		lLayout7 := (AllTrim(CS0->CS0_LEIAUT) >= "7.00") 
		If nRadio == 1
			cReg := "J100" //Registro a ser exibido no CTBA014
			If lRetDem := ExistDem(cReg)
				CTBS014(cReg, cRevCod, lLayout7 )
			End
		ElseIf nRadio == 2
			cReg := "J150" //Registro a ser exibido no CTBA014
			If lRetDem := ExistDem(cReg)
					CTBS014(cReg, cRevCod, lLayout7 )
			End
		ElseIf nRadio == 3			
			cReg := "J210" //Registro a ser exibido no CTBA014
			If lRetDem := ExistDem(cReg)
				CTBS014(cReg, cRevCod, lLayout7 )
			End
		EndIf
	  If !lRetDem
	  	Alert("Nใo encontrado Demonstrativo para Nota Explicativa!")
	  End
	EndIf
	
EndDo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExistRegist()
Verifica se a tabela possui Notas Explicativas J100 / J150 / J210

@author Totvs S.A.
@since 
@version P12.1.23
/*/
//-------------------------------------------------------------------

Static Function ExistDem(cRegistro)

Local aArea    	:= GetArea()
Local cAliasCSX	:= ""    
Local lRet			:= .F.
Local cCodRev		:= ""
Local cQuery		:= ""
Local cTipo 		:= ""

Default cRegistro	:= ""

cCodRev:=GetCodRev()

Do Case
	Case cRegistro=="J100"
		cTipo := "'1'"
	Case cRegistro=="J150"
		cTipo := "'2'"
	Case cRegistro == "J210"
		cTipo := "'3','4'"
EndCase


If __lDefTop

	cQuery	:= " SELECT "
	cQuery	+= " 	COUNT(CSD_REGIST) CONTADOR "
	cQuery	+= " 	FROM " 
	cQuery	+= 			RetSQLTab("CSD")
	cQuery	+= " 		WHERE "
	cQuery	+= " 			CSD_FILIAL = '" + xFilial("CSD") + "' AND "
	cQuery	+= " 			CSD_CODREV = '" + cCodRev				 + "' AND "
	cQuery	+= "      CSD_TPDEM IN (" + cTipo + ") AND "
	cQuery	+= " 			D_E_L_E_T_ = ' ' "
	   
	cQuery := ChangeQuery(cQuery) 	
	
	cAliasCSX := GetNextAlias()		
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCSX,.T.,.T.)

EndIf
 
dbSelectArea(cAliasCSX)
DbGoTop()

If (cAliasCSX)->CONTADOR > 0
	lRet := .T.
EndIf

(cAliasCSX)->( dbCloseArea() )

RestArea( aArea )

Return lRet

/*/{Protheus.doc} AMBHELP
Tratamento para ver se Binแrio, LIB ou Dbacess estใo atualizados
@type  Function
@author totvs
@since 08/05/2020
@version 12.1.25
@return
/*/
Static Function AMBHELP()
Local oBtnLink 
Local cMsg	:= ""
Local lRet := .T.

//Bin
//Bin - bases 23 e 25
If GetSrvVersion() < '17.3.0.17'
    cMsg += '<b>' + STR0044 + '</b><br>' // Binario desatualizado
    cMsg += ' Build: ' + GetBuild() + '<br>' //AppServer Build  
    cMsg += ' VersionId: ' + GetSrvVersion() + '<br><br>' //Appserver version
EndIf

//Bin 19 base27
If   GetRPORelease() >= "12.1.027" .And.    GetSrvVersion() < '19.3.0.2'
    cMsg += '<b>' + STR0044 + '</b><br>' // Binario desatualizado
    cMsg += ' Build: ' + GetBuild() + '<br>' //AppServer Build  
    cMsg += ' VersionId: ' + GetSrvVersion() + '<br><br>' //Appserver version
EndIf

//DBAccess
If Findfunction("TcVersion") .And.  TcVersion() < '19.2.1.0'
	cMsg += ' <b>' + STR0045 + '</b><br>' // DBAccess estแ desatualizado
	cMsg += ' Build: ' + TCGetBuild() + '<br>' //DBAccess Build
	cMsg += ' VersionId: ' + TcVersion() + '<br><br>' //DBAccess API Build
EndIf

//LIB
If FwLibVersion() < '20200504'
	If FwLibVersion() < '20200214'
		cMsg += ' <b>' + STR0046 + '</b><br>' // LIB desatualizada
		cMsg += ' Build: ' + FwLibVersion() + '<br><br>'//LIB Build
	Else
		If !(FindFunction('FwTechFinVersion') .and. FwTechFinVersion() >= '1.2.2')
			cMsg += ' <b>' + STR0046 + '</b><br>' // LIB desatualizada
			cMsg += ' Build: ' + FwLibVersion() + '<br><br>'//LIB Build
		EndIf
	Endif		
EndIf

If !Empty(cMsg)
	DEFINE DIALOG oDlg TITLE STR0043 FROM 180,180 TO 450,600 PIXEL // "Ambiente Desatualizado"
   
	// Cria fonte para ser usada no TSay
	oFont := TFont():New('Courier new',,-18,.T.)
   
	lHtml := .T.
	oSay := TSay():New(01,01,{||cMsg},oDlg,,oFont,,,,.T.,,,400,300,,,,,,lHtml)

	oBtnLink := TButton():New( 110, 5, STR0047, oDlg,, 150 ,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnLink:SetCSS("QPushButton {text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 0px;Text-align:left;font-size:16px}")
	oBtnLink:bLClicked := {|| ShellExecute("open", "https://suporte.totvs.com/portal/p/10098/download#000006/","","",3) }
	
	ACTIVATE DIALOG oDlg CENTERED

	lRet:= MsgNoYes(STR0042,STR0043) // Existem componentes desatualizados, isso pode impactar na gera็ใo correta do ECF/ECD, deseja prosseguir mesmo assim ? / //"Ambiente Desatualizado"

EndIf

Return lRet
/*/{Protheus.doc} verificaValidacaoEcd
Verifica se foi executado o validador ECD - CTBS480
@type  Function
@author wilton.santos
@since 20/06/2022
@version 12.1.2210
@return
/*/
Static Function	verificaValidacaoEcd()
Local lRet          := .T.
Local dUltValid     := SuperGetMV("MV_ULTVECD",.T.,dDataBase)
Local nDias         := dDataBase - dUltValid 
Local cMsg          := ""

IF nDias > 0
   if nDias >= 30	
	  cMsg := "<b> " + STR0049 + " </b><br>"	    //Nใo identificamos o uso do validador ECD/ECF
   	  cMsg += "<b> " + STR0050 + " </b><br><br>"	//nos ๚ltimos 30 dias.
   	  cMsg += "<b> " + STR0051 + " </b><br>"		//Para gerar revisใo ECD/ECF execute          	
      cMsg += "<b> " + STR0052 + " </b><br>"		//o validador ECD/ECF(CTBS480).
   endIf
elseif nDias <= -30  //caso usuแrio altere manualmente o parโmetro para uma data futura.
	cMsg := "<b> " + STR0053 + " </b><br>" //Identificamos a utiliza็ใo do validador ECD/ECF
	cMsg += "<b> " + STR0054 + " </b><br><br>"	//em perํodo maior que 30 dias.
	cMsg += "<b> " + STR0055 + " </b><br>"	//Necessแrio execu็ใo do validador ECD/ECF
EndIf

If !Empty(cMsg)
	DEFINE DIALOG oDlg TITLE STR0026 FROM 180,180 TO 450,600 PIXEL // "ATENวรO"
   
	// Cria fonte para ser usada no TSay
	oFont := TFont():New('Courier new',,-15,.T.)
   
	lHtml := .T.
	oSay := TSay():New(01,01,{||cMsg},oDlg,,oFont,,,,.T.,,,400,300,,,,,,lHtml)

	oBtnLink := TButton():New( 110, 5, STR0048 , oDlg,, 150 ,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnLink:SetCSS("QPushButton {text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 0px;Text-align:left;font-size:16px}")
	oBtnLink:bLClicked := {|| ShellExecute("open", "https://tdn.totvs.com/x/Rk6nJw","","",3) }
	
	ACTIVATE DIALOG oDlg CENTERED

	lRet := .F.

EndIf

Return lRet			