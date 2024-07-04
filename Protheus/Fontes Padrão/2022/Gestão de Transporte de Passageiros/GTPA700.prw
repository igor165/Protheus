#include 'protheus.ch'
#include 'parmtype.ch' 
#include 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "GTPA700.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWTABLEATTACH.CH"

#Define VISAO_1   	STR0001 // 'Caixa Aberto'
#Define VISAO_2   	STR0002 // 'Caixa Fechado'
#Define VISAO_3		STR0003 // 'Caixa Reaberto'

Static _cUsrPanel := ''
Static aWidgets   := {} 
Static oBrowse
Static oWorkarea  := Nil
Static oDlgRot 
Static oMBrowse
Static oWidget
Static oView
Static oModel
Static nValorSld  := 0
Static aDelFch    := {}
Static aIncFch    := {}
Static aDFFch     := {}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA700()
Workarea da tesouraria
 
@sample	GTPA700()
 
@return	oBrowse 
 
@author	Fernando Amorim(Cafu)
@since		21/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA700()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("G6T")
oBrowse:SetAttach(.T.)
oBrowse:SetDescription(STR0004) //"Caixa-Tesouraria" 
oBrowse:AddLegend("G6T_STATUS=='1'", "GREEN", STR0005) 	//"Aberto" 
oBrowse:AddLegend("G6T_STATUS=='3'", "YELLOW", STR0006)	//"Reaberto" 
oBrowse:AddLegend("G6T_STATUS=='2'", "RED", STR0007) 	//"Fechado" 

oBrowse:SetFilterDefault ( 'G6T_FILIAL == "' + xFilial('G6T') + '"')

oTableAtt := TableAttDef()

oBrowse:DisableDetails()
If !(IsBlind())
	oBrowse:Activate()
EndIf
Return oBrowse

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com opções do menu
 
@author	Fernando Amorim(Cafu)
@since		26/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0061 ACTION "GTPA700MNT()" OPERATION 1 ACCESS 0 // Manutenção

Return aRotina


//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as visões e gráficos padrão para a Oportunidade de Venda.

@sample		TableAttDef()

@param		Nenhum

@return		ExpA - Array de Objetos com as Visoes.

@author		Cristiane Nishizaka
@since		28/04/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oTableAtt		:= FWTableAtt():New()
Local oDlgAbert		:= Nil 
Local oDlgRAber		:= Nil 
Local oDlgFecha		:= Nil 

oTableAtt:SetAlias("G6T")

oDlgAbert := FWDSView():New()
oDlgAbert:SetName(STR0001) // "Caixa Aberto"
oDlgAbert:SetID("CaixaA") 
oDlgAbert:SetOrder(1) // 
oDlgAbert:SetCollumns({"G6T_CODIGO","G6T_DTOPEN","G6T_DTCLOS","G6T_AGENCI","G6T_DESCRI"})
oDlgAbert:SetPublic(.T.)
oDlgAbert:SetLegend(.T.)
oDlgAbert:AddFilterRelation( "G6T", "G6T_FILIAL", "G6T_CODIGO" )
oDlgAbert:AddFilter(STR0001, "G6T_STATUS== '1' .AND. Empty(G6T_USERRE) ") //"Caixas Abertos"
oTableAtt:AddView(oDlgAbert)

oDlgRAber := FWDSView():New()
oDlgRAber:SetName(STR0003) // "Caixa Reaberto"
oDlgRAber:SetID("CaixaR") 
oDlgRAber:SetOrder(1) // 
oDlgRAber:SetCollumns({"G6T_CODIGO","G6T_DTOPEN","G6T_DTCLOS","G6T_AGENCI","G6T_DESCRI"})
oDlgRAber:SetPublic(.T.)
oDlgRAber:SetLegend(.T.)

oDlgRAber:AddFilterRelation( "G6T", "G6T_FILIAL", "G6T_CODIGO" )
oDlgRAber:AddFilter(STR0003, "G6T_STATUS== '3' .AND. !Empty(G6T_USERRE) ") //"Caixas ReAbertos"
oTableAtt:AddView(oDlgRAber)

oDlgFecha := FWDSView():New()
oDlgFecha:SetName(STR0002) // "Caixa Fechado"
oDlgFecha:SetID("CaixaF") 
oDlgFecha:SetOrder(1) // 
oDlgFecha:SetCollumns({"G6T_CODIGO","G6T_DTOPEN","G6T_DTCLOS","G6T_AGENCI","G6T_DESCRI"})
oDlgFecha:SetPublic(.T.)
oDlgFecha:SetLegend(.T.)

oDlgFecha:AddFilterRelation( "G6T", "G6T_FILIAL", "G6T_CODIGO" )
oDlgFecha:AddFilter(STR0002, "G6T_STATUS== '2'  ") //"Caixas Fechado"
oTableAtt:AddView(oDlgFecha)

Return(oTableAtt)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA700

Nova area de trabalho do GTP - Tesouraria

@sample		GTPA700()

@return		Nenhum

@author		Fernando Amorim(Cafu)
@since			26/10/2017
@version		P12
/*/
//------------------------------------------------------------------------------
Function GTP700AMB()

Local	 lContinua  := .T.

Private INCLUI     := .T.
Private la061Auto  := .F.
Private aAutoCab   := {}
Private aAutoItens := {}
Private cCadastro  := STR0012 + ' - ' + UsrRetName(RetCodUsr()) //"Tesouraria" + Nome do Usuario Logado
Private cMark      := ""  
Private aRotina    := {}
Private aRotAuto   := Nil
Private cCadBkp    := cCadastro

SetStyle( 5 )
lContinua := CHKFILE("G6T")
//-----------------------------
// Carrega Área de  Trabalho
//-----------------------------
If lContinua
    FWMsgRun(/*oComponent*/, { ||  GTP700Rot() }, STR0013, STR0014)	 // "Aguarde", //"Carregando Área de Trabalho..."
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTP700Rot

Monta a área de trabalho

@sample		GTP700Rot( )
					
@return		Nenhum

@author		Fernando Amorim(Cafu)
@since			26/10/2017
@version		P12
/*/
//------------------------------------------------------------------------------
Function GTP700Rot( oDlgRot , aControle, lRecria, cCodNewPanel )

Local cMenuItem  := Nil
Local oMenu      := Nil
Local oMenuItem  := Nil
Local aSize      := FWGetDialogSize( oMainWnd )
Local aWidgets 	 := {}
Local lCriaMenu	 := .T.
Local bWDestroy	 := {|| AEval(aWidgets,{|x| x:Destroy() } ) } 
Local nTamanho	 := 0

Default oDlgRot      := Nil
Default aControle    := {}
Default lRecria      := .F.
Default cCodNewPanel := ""
Default cCadastro    := STR0012 + ' - ' + UsrRetName(RetCodUsr()) // Tesouraria

If ValType( oDlgRot ) == "O"
	Eval(bWDestroy)
	cCadastro := cCadBkp 	
	oDlgRot:End()
EndIf

//-------------------------------------------------------------
// Carrega variável estática na criação de um novo painel
//-------------------------------------------------------------
If !Empty(cCodNewPanel)
	_cUsrPanel := cCodNewPanel
EndIf

oDlgRot := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4],  STR0012, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // "Tesouraria   

oWorkarea := FWUIWorkArea():New( oDlgRot )
oWorkarea:SetMenuWidth( 200 )

oMenu := FWMenu():New()
oMenu:Init()

//---------------------
// Monta menu padrão
//---------------------
If lCriaMenu

    //------------------------------------------------------------------------------------------------------
    //  MENU Operacional 
    //------------------------------------------------------------------------------------------------------
    cMenuItem := oMenu:AddFolder(STR0015, "A") // "Caixa"
    oMenuItem := oMenu:GetItem( cMenuItem )

    oMenuItem:AddContent( STR0016	, "E", { || GTPOpenCx(oWorkarea) } )		// "+ Abrir Caixa" 
    oMenuItem:AddContent( STR0017	, "E", { || GTPCloseCx(oWorkarea) } )		// "+ Fechar Caixa" 
    oMenuItem:AddContent( STR0018	, "E", { || GTPReOpCx(oWorkarea) } )		// "+ Reabrir Caixa"    

    //------------------------------------------------------------------------------------------------------
    //  MENU PLANEJAMENTO 
    //------------------------------------------------------------------------------------------------------
    cMenuItem := oMenu:AddFolder(STR0019, "A") // "Lançamentos"
    oMenuItem := oMenu:GetItem( cMenuItem )

    oMenuItem:AddContent( STR0020, "E", { || SetOpcMenu(1)} )   // "+ Notas Fiscais de entrada"
    oMenuItem:AddContent( STR0021, "E", { || SetOpcMenu(2)} )	// "+ Depositos/Titulos"	
    oMenuItem:AddContent( STR0022, "E", { || SetOpcMenu(3)} )	// "+ Taxas Avulsas"	
	oMenuItem:AddContent( STR0052, "E", { || SetOpcMenu(4)} )	// "+ Taxas"	
    oMenuItem:AddContent( STR0062, "E", { || SetOpcMenu(5)} )	// "+ Vendas Cartão"						
    oMenuItem:AddContent( STR0063, "E", { || SetOpcMenu(6)} )	// "+ Vendas Canceladas no Cartão"		
    oMenuItem:AddContent( STR0064, "E", { || SetOpcMenu(7)} )	// "+ Receitas"  					
    oMenuItem:AddContent( STR0065, "E", { || SetOpcMenu(8)} )	// "+ Despesas"
	oMenuItem:AddContent( STR0139, "E", { || SetOpcMenu(10)} )	// "+ Depósito de Terceiros"
	oMenuItem:AddContent( STR0119, "E", { || SetOpcMenu(9)} )	// "+ Conta corrente"  						
    
    //------------------------------------------------------------------------------------------------------
    //  Financeiro
    //------------------------------------------------------------------------------------------------------
    cMenuItem := oMenu:AddFolder(STR0066, "A") // "Financeiro"
    oMenuItem := oMenu:GetItem( cMenuItem )

    oMenuItem:AddContent( STR0067  , "E", { || GTPA700G() } ) //  "+ Gerar Título de Taxa"
	oMenuItem:AddContent( "+ Bloqueio Financeiro"  , "E", { || GTPA700O() } ) //  "+ Bloqueio Financeiro"

	//------------------------------------------------------------------------------------------------------
    //  Consulta 
    //------------------------------------------------------------------------------------------------------
    cMenuItem := oMenu:AddFolder(STR0131, "A") // "Consulta"
    oMenuItem := oMenu:GetItem(cMenuItem)

	oMenuItem:AddContent(STR0132, "E", {|| GTPA700F()}) // "+ Saldos da cota corrente"

    //------------------------------------------------------------------------------------------------------
    //  Relatório 
    //------------------------------------------------------------------------------------------------------
    cMenuItem := oMenu:AddFolder(STR0053, "A") // "Relatório"
    oMenuItem := oMenu:GetItem( cMenuItem )

    oMenuItem:AddContent( STR0054, "E", { || GTPR700A() } ) //  "+ Lançamento de Notas Fiscais"
    oMenuItem:AddContent( STR0055, "E", { || GTPR700B() } ) //  "+ Lançamento de Depósitos"
    oMenuItem:AddContent( STR0056, "E", { || GTPR421B() } ) //  "+ Lançamento de Valores Adicionais"
    oMenuItem:AddContent( STR0057, "E", { || GTPR115A() } ) //  "+ Lançamento de Bilhetes"
    oMenuItem:AddContent( STR0068, "E", { || GTPR700X() } ) //  "+ Fichas de Remessa X Caixa"

	If __cUserId == '000364'
		oMenuItem:AddContent( "Gera nota de bilhetes", "E", { || GTPJ001()} )						
	Endif
    
EndIf

oWorkarea:SetMenu( oMenu )
//Verifica o tamanho da resolução
IIF(aSize[3] < 837.32, nTamanho := 837.32, nTamanho := aSize[3])	

oWorkarea:CreateHorizontalBox( "LINE01", nTamanho, .T. )
oWorkarea:SetBoxCols( "LINE01", { "WDGT01" } )

oWorkarea:Activate()

	AADD(aWidgets, CA700WDG01(  oWorkarea:GetPanel( "WDGT01" ), "G6T", "GTPA700", MODE_BROWSE )	)		// funcao que monta a GRID OPORTUNIDADES

GA700WGTRefresh() 

oDlgRot:lEscClose := .F.	
oDlgRot:Activate( , , , , , , EnchoiceBar( oDlgRot, {|| }, { || oDlgRot:End()}, , {}, , , , , .F., .F. ) ) //ativa a janela criando uma enchoicebar , GC300Destroy() 

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} GA290WGTRefresh

Função que faz o refresh do WidGets

@sample 	GA700WGTRefresh()

@param		Nenhum

@return   	Nenhum

@author	Fernando Amorim(Cafu)
@since		26/10/2017
@version	P12.1.7
/*/
//------------------------------------------------------------------------------
Function GA700WGTRefresh() 
 
Local nX 			:= 0
Local cClassName	:= ""

For nX := 1 To Len(aWidGets)
	cClassName := GetClassName(aWidGets[nX]) 
	If cClassName == "FWTABLEATTACHWIDGET"
		oMBrowse := aWidGets[nX]:GetBrowse()
		If oMBrowse <> Nil
			oMBrowse:ExecuteFilter()
		EndIf
	Endif
Next nX
 
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPOpenCx
	Abertura do Caixa
@author	Fernando Amorim(Cafu)
@since		20/10/2017
@version	P12
/*/
//-------------------------------------------------------------------
function GTPOpenCx(oWorkarea)

Local aParamBox		:= {}
Local aPergRet		:= {}
Local cAge700       := ""

	If len(oMBrowse:OFWFILTER:AFILTER) > 0
		
		 If aScan(oMBrowse:OFWFILTER:AFILTER,{|x| x[1] == VISAO_1}) > 0
			aAdd(aParamBox, {1, STR0023,  Space(6)	 , "@!" ,, "GI6",, 50, .F.} )	// Pergunta 01 : Agencia
			If ParamBox(aParamBox, STR0024, aPergRet) // "Informe a Agência"
				cAge700 := MV_PAR01
				GI6->(DbSetorder(1))
				If !Empty(cAge700) .AND. GI6->(DbSeek(xFilial("GI6")+ cAge700 ))
					FwMsgRun(,{|| GtAbreCx(cAge700) },,STR0025 ) // "Aguarde abrindo Caixa..."
					oWidget :Refresh(.T.)
					oMBrowse:Refresh(.T.)
				    oMBrowse:OFWFILTER:AFILTER[1][1]
				Else
				 	FwAlertHelp(STR0023, STR0026) // "Agência", // "Informe uma Agência válida"
				EndIf
			Endif
		Else
		 	FwAlertHelp(STR0027, STR0028) // "Abrir", // "Para abrir um caixa altere para visão de 'Caixa Aberto'"
		
		Endif
	Else
		 FwAlertHelp(STR0027, STR0028) // "Abrir", // "Para abrir um caixa altere para visão de 'Caixa Aberto'"
	
	Endif
return

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPCloseCx
	Fechamento do Caixa
@author	Fernando Amorim(Cafu)
@since		20/10/2017
@version	P12
/*/
//-------------------------------------------------------------------
function GTPCloseCx(oWorkarea,oDlgRot)
Local cAge700 := ""
Local lRet := .T.

If AliasInDic("H65")
	H65->(DBSETORDER(2))
	If H65->(DBSEEK(XFILIAL("H65") + G6T->G6T_AGENCI + '1'))
		FwAlertHelp("Opção inválida para agência bloqueada. Efetue o desbloqueio da agência.", "Agência com bloqueio")
		lRet     := .F.
	EndIf
EndIf

If lRet
	If len(oMBrowse:OFWFILTER:AFILTER) > 0
			
		If aScan(oMBrowse:OFWFILTER:AFILTER,{|x| x[1] == VISAO_1}) > 0 .OR. aScan(oMBrowse:OFWFILTER:AFILTER,{|x| x[1] == VISAO_3}) > 0
			cAge700 := G6T->G6T_AGENCI
			FwMsgRun(,{|| GtFechaCx(cAge700) },,STR0029) // "Aguarde o fechamento do caixa." 
			oWidget :Refresh(.T.)
			oMBrowse:Refresh(.T.)
		Else
			FwAlertHelp(STR0030, STR0031) // "Fechar", // "Para fechar um caixa altere para visão de 'Caixa Aberto'"
		Endif
	Else
		FwAlertHelp(STR0030, STR0031) // "Fechar", // "Para fechar um caixa altere para visão de 'Caixa Aberto'"
			
	Endif
Endif
return

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPReOpCx
	Fechamento do Caixa
@author	Fernando Amorim(Cafu)
@since		23/10/2017
@version	P12
/*/
//------------------------------------------------------------------
Function GTPReOpCx(oWorkarea)
	
Local aParamBox		:= {}
Local cAge700       := ""
	If len(oMBrowse:OFWFILTER:AFILTER) > 0
		
		If aScan(oMBrowse:OFWFILTER:AFILTER,{|x| x[1] == VISAO_2}) > 0
			aAdd(aParamBox, {1,STR0023		,  Space(6)	 , "@!" ,, "GI6",, 50, .F.} )	// Pergunta 01 : Agencia
			cAge700 := G6T->G6T_AGENCI
			FwMsgRun(,{|| GtReAbreCx() },,STR0058) // "Aguarde o fechamento do caixa."  
			oWidget :Refresh(.T.)
			oMBrowse:Refresh(.T.)
		Else
		 	FwAlertHelp(STR0032, STR0033) // "Reabrir", // "Para reabrir um caixa altere para visão de 'Caixa Fechado'"
		Endif
	Else
	 	FwAlertHelp(STR0032, STR0033) // "Reabrir", // "Para reabrir um caixa altere para visão de 'Caixa Fechado'"
	Endif
return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author	Fernando Amorim(Cafu)
@since		20/10/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruG6T  	:= FWFormStruct(1,"G6T") // CAIXA]
Local oStruG6X		:= FWFormStruct(1,"G6X") // FICHAS]

Local bCommit		:= {|oModel| GA700Commit(oModel)}
Local cLoadFilter	:= "" 

oModel	:= MPFormModel():New("GTPA700",/*bPreValidMdl*/,/* bPosVldbPosValidMdl*/,/*bCommit*/, /*bCancel*/ )

oStruG6T:SetProperty('G6T_CODIGO' , MODEL_FIELD_INIT, {||GTPXENUM('G6T','G6T_CODIGO',,3)})

oModel:SetDescription(STR0034) //"Abertura e Fechamento de Caixa"  
oModel:AddFields('FIELDG6T',,oStruG6T)
oModel:AddGrid("GRIDG6X", "FIELDG6T",oStruG6X,/*bPre*/,/*bPos*/,,/*bPos*/,/*bLoadGrid*/)

oModel:SetRelation('GRIDG6X',{{'G6X_FILIAL','xFilial("G6T")'},{'G6X_AGENCI','G6T_AGENCI'}},G6X->(IndexKey(1)))

cLoadFilter	:= "G6X_STATUS IN ('3','4')"

If G6T->G6T_STATUS = '2'
	cLoadFilter	+= " and ( G6X_CODCX = '" + G6T->G6T_CODIGO + "')" 
Else
	cLoadFilter	+= " and ( G6X_CODCX = '" + G6T->G6T_CODIGO + "'" + " OR G6X_CODCX = '')" 
Endif

oModel:GetModel("GRIDG6X"):SetLoadFilter(, cLoadFilter)
					
oModel:GetModel('GRIDG6X'):SetOptional( .T. )
oModel:SetCommit(bCommit)
oModel:SetPrimaryKey({"G6T_FILIAL","G6T_DTOPEN","G6T_AGENCI"})
oModel:GetModel('FIELDG6T'):SetDescription(STR0034) // "Abertura e Fechamento de Caixa" 
oStruG6X:SetProperty( 'G6X_FLAGCX',MODEL_FIELD_VALID,{|oMdl,cField,cNewValue,cOldValue|VldFlagCx(oMdl,cField,cNewValue,cOldValue) } )
oStruG6X:SetProperty('G6X_FECHCX' , MODEL_FIELD_WHEN, {|| FwFldGet('G6T_STATUS') == '3' .And. FwFldGet('G6X_FLAGCX') == .T.})
oStruG6X:SetProperty( 'G6X_FECHCX',MODEL_FIELD_VALID,{|oMdl,cField,cNewValue,cOldValue|VldFlagCx(oMdl,cField,cNewValue,cOldValue) } )
oStruG6X:SetProperty('G6X_FLAGCX' , MODEL_FIELD_WHEN, {|| FwFldGet('G6T_STATUS') $  '1|3' .And. FwFldGet('G6X_FECHCX') == .F.})

oStruG6X:AddTrigger("G6X_FLAGCX"	, "G6X_FLAGCX"	,{ || .T. }, { |oMdlG6X| TrigFlagCx(oMdlG6X) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author	Fernando Amorim(Cafu)
@since		24/10/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := ModelDef()
Local oStruG6T := FWFormStruct(2, 'G6T')
Local oStruG6X := FWFormStruct(2, 'G6X',{ |x| AllTrim(x)+"|" $ "G6X_FLAGCX|G6X_FECHCX|G6X_NUMFCH|G6X_DTREME|G6X_VLRREI|G6X_VLRDES|G6X_VLRLIQ|G6X_DTINI|G6X_DTFIN|G6X_RECCX|G6X_DESCX|G6X_SLDCX|G6X_TPSLCX|G6X_TITCX|G6X_DEPOSI|G6X_TITPRO|"})

oStruG6X:SetProperty("G6X_FLAGCX", MVC_VIEW_ORDEM, '01')
oStruG6X:SetProperty("G6X_FECHCX", MVC_VIEW_ORDEM, '02')
oStruG6X:SetProperty("G6X_NUMFCH", MVC_VIEW_ORDEM, '03')
oStruG6X:SetProperty("G6X_DTREME", MVC_VIEW_ORDEM, '04')
oStruG6X:SetProperty("G6X_VLRREI", MVC_VIEW_ORDEM, '05')
oStruG6X:SetProperty("G6X_VLRDES", MVC_VIEW_ORDEM, '06')
oStruG6X:SetProperty("G6X_VLRLIQ", MVC_VIEW_ORDEM, '07')
oStruG6X:SetProperty("G6X_DTINI",  MVC_VIEW_ORDEM, '08')
oStruG6X:SetProperty("G6X_DTFIN",  MVC_VIEW_ORDEM, '09')
oStruG6X:SetProperty("G6X_RECCX",  MVC_VIEW_ORDEM, '10')
oStruG6X:SetProperty("G6X_DESCX",  MVC_VIEW_ORDEM, '11')
oStruG6X:SetProperty("G6X_SLDCX",  MVC_VIEW_ORDEM, '12')
oStruG6X:SetProperty("G6X_TPSLCX", MVC_VIEW_ORDEM, '13')
oStruG6X:SetProperty("G6X_TITCX",  MVC_VIEW_ORDEM, '14')

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEWG6T', oStruG6T, 'FIELDG6T') 
oView:AddGrid('VIEWG6X' ,oStruG6X,'GRIDG6X')

oView:CreateHorizontalBox('CABEC', 55)
oView:CreateHorizontalBox('GRID', 45)

oView:SetOwnerView('VIEWG6T','CABEC')
oView:SetOwnerView('VIEWG6X','GRID')

oView:EnableTitleView("VIEWG6T")
oView:EnableTitleView("VIEWG6X")

oStruG6T:SetProperty( '*', MVC_VIEW_CANCHANGE, .F.)
oStruG6X:SetProperty( '*', MVC_VIEW_CANCHANGE, .F.)
oStruG6X:SetProperty( 'G6X_FLAGCX', MVC_VIEW_CANCHANGE, .T.)
oStruG6X:SetProperty( 'G6X_FECHCX', MVC_VIEW_CANCHANGE, .T.)

oView:SetNoDeleteLine('VIEWG6X')
oView:SetNoInsertLine('VIEWG6X')

oView:AddUserButton( "Fech.Caixa" , "FILTRO"	, {|oView| TP700RMkAll(oView) } ) 

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} TP700RMkAll
	Marca ou desmarca todos os registros da grid
@sample 	TP700RMkAll(oView)
@since		07/07/2017       
@version	P12
/*/
//------------------------------------------------------------------------------
Function TP700RMkAll(oView)

Local lRet 		    := .T.
Local oModel 	    := FWModelActive()
Local oGridPara		:= oModel:GetModel('GRIDG6X')
Local nI		    := oGridPara:GetLine()

oGridPara:GoLine( nI )
If oGridPara:GetValue("G6X_FECHCX")
	oGridPara:SetValue("G6X_FECHCX", .F.)
Else
	oGridPara:SetValue("G6X_FECHCX", .T.)
EndIf

Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} GtAbreCx
	abre o caixa
	
@author Fernando Amorim(Cafu)
@since		23/10/2017       
@version	P12
/*/
//------------------------------------------------------------------------------

Function GtAbreCx(cAge700)

Local lRet  		:= .T.
Local oModelG6T 	:= FWLOADModel('GTPA700')
Local oMdlG6T
Local cMsgRet		:= ' '
Local cAliasCxOp	:= GetNextAlias()
Local nSaldoAnt	:= 0
Local cCodG6T		:= ''

oModelG6T:SetOperation(MODEL_OPERATION_INSERT)
oModelG6T:Activate()

oMdlG6T	 	:= oModelG6T:GetModel( 'FIELDG6T' ) 

G6T->(DbSetOrder(1))
If !G6T->(DbSeek(xFilial('G6T') + DTOS(dDataBase) + cAge700))
	
	BeginSQL Alias cAliasCxOp
	
		SELECT  G6T_DTOPEN,G6T_DTCLOS
		FROM %Table:G6T% G6T
		WHERE G6T_FILIAL = %xFilial:G6T%
			AND G6T_DTCLOS = ' '
			AND G6T_AGENCI = %Exp:cAGe700%
			AND %NotDel%
		
	EndSQL
		
	IF (cAliasCxOp)->(EOF())
	
		nSaldoAnt :=  0 //GetSaldAnt(DDATABASE)
	
		lRet := oMdlG6T:SetValue( "G6T_FILIAL"	, xFilial("G6T") ) .And. ;
				oMdlG6T:SetValue( "G6T_DTOPEN"	, DDATABASE	) .And. ;
				oMdlG6T:SetValue( "G6T_AGENCI"	, cAge700	) .And. ;
				oMdlG6T:SetValue( "G6T_CODIGO"	, GTPXENUM('G6T','G6T_CODIGO',3)) .And. ;
				oMdlG6T:SetValue( "G6T_SALDO"	, nSaldoAnt ) .And. ;
				oMdlG6T:SetValue( "G6T_STATUS"	, '1').And. ;				
				oMdlG6T:SetValue( "G6T_USEROP"	, Substr(cUsuario,7,15)	) .And. ;
				oMdlG6T:SetValue( "G6T_HROPEN"	,substr(TIME(),1,2)+substr(TIME(),4,2)	) 
				
		If lRet

			cCodG6T := oMdlG6T:GetValue("G6T_CODIGO")
			
		Endif		
				
		If ( lRet .And. oModelG6T:VldData() )
			oModelG6T:CommitData()
		EndIf
		
		If lRet
			CONFIRMSX8()
			cMsgRet	:= STR0035 // "Abertura do caixa efetuada com sucesso"
			Aviso(STR0036, cMsgRet, {'OK'}, 2) // "Abre Caixa", //Abertura do caixa efetuada com sucesso
		Else
			cMsgRet	:= STR0037 // "Houve erro na abertura do caixa, contate o TI"
			Aviso(STR0036, cMsgRet, {'OK'}, 2) // "Abre Caixa", "Houve erro na abertura do caixa, contate o TI"
		Endif
	Else
		lRet := .F.
		cMsgRet	:= STR0038 // "Há caixa de dias anteriores ainda em aberto, feche-os antes de abrir para essa data"
		Aviso(STR0036, cMsgRet, {'OK'}, 2) // "Abre Caixa", "Há caixa de dias anteriores ainda em aberto, feche-os antes de abrir para essa data"
	Endif
	
	(cAliasCxOp)->(dbCloseArea())

Else
	lRet := .F.
	cMsgRet	:= STR0039 // "O caixa para este dia já foi aberto"
	Aviso(STR0036, cMsgRet, {'OK'}, 2) // "Abre Caixa",  //O caixa para este dia está aberto
	
Endif
If Valtype(oModelG6T) = "O"
	oModelG6T:DeActivate()
	oModelG6T:Destroy()
	oModelG6T:= nil
EndIf	

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GtFechaCx
	fecha o caixa
	
@author Fernando Amorim(Cafu)
@since		23/10/2017       
@version	P12
/*/
//------------------------------------------------------------------------------

Function GtFechaCx(cAge700)

Local lRet  		:= .T.
Local oModelG6T 	:= FWLOADModel('GTPA700')
Local oMdlG6T
Local cMsgRet		:= ' '
Local cMsgTit		:= STR0069 + CRLF //' e foram gerados os títulos '
Local aTotaisCx		:= {}

oModelG6T:SetOperation(MODEL_OPERATION_UPDATE)
oModelG6T:Activate()

oMdlG6T	 	:= oModelG6T:GetModel( 'FIELDG6T' ) 

If VldAceite(G6T->G6T_CODIGO)

	Begin Transaction
	// Processamento
	
	lRet := GTPPROCF(@cMsgTit)
	
	If !lRet
		DelGZK()
		cMsgRet	:= STR0042  + CRLF + cMsgTit
		Aviso(STR0041, cMsgRet, {'OK'}, 2) // "Fecha Caixa", //Houve erro no Fechamento do caixa, contate o TI
		lRet := MsgYesNo(STR0059)//"Não há ou não foi possivel processsar os lançamentos. Deseja fechar o caixa mesmo sem os lançamentos serem processados?"	

		If !lRet
			oModelG6T:SetErrorMessage(oModelG6T:GETID(),'',oModelG6T:GETID(),'',"GTFECHACX","FECHA CAIXA",cMsgRet)
		Endif
	
	Endif
	// fim do processamento
	
	If lRet 
	
		aTotaisCx := GetTotCx()
		
		lRet :=	oMdlG6T:SetValue( "G6T_DTCLOS"	, DDATABASE	) .And. ;
				oMdlG6T:SetValue( "G6T_STATUS"	, '2').And. ;	
				oMdlG6T:SetValue( "G6T_DEBITO"	, aTotaisCx[1][2]).And. ;	
				oMdlG6T:SetValue( "G6T_CREDIT"	, aTotaisCx[1][1]).And. ;
				oMdlG6T:SetValue( "G6T_SALDO"	, aTotaisCx[1][3] ).And. ;				
				oMdlG6T:SetValue( "G6T_USERFE"	, Substr(cUsuario,7,15)	) .And. ;
				oMdlG6T:SetValue( "G6T_HRCLOS"	,substr(TIME(),1,2)+substr(TIME(),4,2)	) 
						
						
		If ( lRet .And. oModelG6T:VldData() )
			oModelG6T:CommitData()
		EndIf
		
		If lRet
			cMsgRet	:= STR0040  + CRLF + cMsgTit// "Fechamento do caixa efetuado com sucesso"
			Aviso(STR0041, cMsgRet, {'OK'}, 2) // "Fecha Caixa",  // Fechamento do caixa efetuado com sucesso
		Else
			cMsgRet	:= STR0042 // "Houve erro no Fechamento do caixa, contate o TI"
			Aviso(STR0041, cMsgRet, {'OK'}, 2) // "Fecha Caixa", //Houve erro no Fechamento do caixa, contate o TI
			oModelG6T:SetErrorMessage(oModelG6T:GETID(),'',oModelG6T:GETID(),'',"GTFECHACX","FECHA CAIXA",cMsgRet)
			DisarmTransaction()
		Endif
		
	EndIf
	
	If Valtype(oModelG6T) = "O"
		oModelG6T:DeActivate()
		oModelG6T:Destroy()
		oModelG6T:= nil
	EndIf
		
	End Transaction 	

Else

	lRet := .F.
	FwAlertHelp(STR0116, STR0117) //"Conferência", "Caixa não pode ser fechado, foram encontrados movimentos sem conferência."

Endif

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GtReAbreCx
	Reabre o caixa
	
@author Fernando Amorim(Cafu)
@since		23/10/2017       
@version	P12
/*/
//------------------------------------------------------------------------------

Function GtReAbreCx()

Local lRet  		:= .T.

Local oModelG6T 	:= FWLOADModel('GTPA700')
Local oMdlG6T
Local cMsgRet		:= ' '
Local dDataFin		:= SuperGetMv("MV_DATAFIN")
Local cStsTit		:= ""
	
	cStsTit := RetStsGer(G6T->G6T_CODIGO) // Retorna o status da geração de títulos
	
	If cStsTit == '1'
	
		cMsgRet	:= STR0070 // "Títulos de fechamento sendo gerados no momento. Caixa não pode ser reaberto"
		Aviso(STR0045, cMsgRet, {'OK'}, 2) // "Reabrir Caixa", //"Títulos de fechamento sendo gerados no momento. Caixa não pode ser reaberto"
		
		Return .T.
	
	Endif 

oModelG6T:SetOperation(MODEL_OPERATION_UPDATE)
oModelG6T:Activate()

oMdlG6T	 	:= oModelG6T:GetModel( 'FIELDG6T' ) 

// Processamento

	IF  G6T->G6T_DTCLOS >= dDataFin
		
		If lRet
			lRet := oMdlG6T:SetValue("G6T_DTCLOS"  , CtoD("  /  /  ")) .And.;
					oMdlG6T:SetValue("G6T_USERFE"  , "") .And.;
					oMdlG6T:SetValue("G6T_HRCLOS"  , "") .And.;
					oMdlG6T:SetValue("G6T_CHAVE"   , "") .And. ;
					oMdlG6T:SetValue("G6T_DEBITO"  , 0) .And. ;
					oMdlG6T:SetValue("G6T_CREDIT" , 0) .And. ;
					oMdlG6T:SetValue("G6T_SALDO"   , 0) .And. ;
					oMdlG6T:SetValue("G6T_STATUS"  , "3") .And. ;
					oMdlG6T:SetValue( "G6T_USERRE"	, Substr(cUsuario,7,15)	) .And. ;
					oMdlG6T:SetValue( "G6T_HRRABR"	,substr(TIME(),1,2)+substr(TIME(),4,2)	) 
					
							
			If ( lRet .And. oModelG6T:VldData() )
				oModelG6T:CommitData()
			EndIf
		
		EndIf
			
		If lRet
			cMsgRet	:= STR0044 // "Reabertura do caixa efetuado com sucesso"
			Aviso(STR0045, cMsgRet, {'OK'}, 2) // "Reabrir Caixa", //Fechamento do caixa efetuado com sucesso
		Else
			cMsgRet	:= STR0046 // "Houve erro na Reabertura do caixa, contate o TI"
			Aviso(STR0045, cMsgRet, {'OK'}, 2) // "Reabrir Caixa", //Houve erro no Fechamento do caixa, contate o TI
			oModelG6T:SetErrorMessage(oModelG6T:GETID(),'',oModelG6T:GETID(),'',"GTREABRECX","REABRIR CAIXA",cMsgRet)
		Endif
	Else
		cMsgRet	:=  STR0071 //"Só é permitido Reabrir um caixa da agencia em que tenha sido fechado depois do fechamento financeiro(MV_DATAFIN), contate o TI"
		Aviso(STR0045, cMsgRet, {'OK'}, 2) // "Reabrir Caixa", //Houve erro no Fechamento do caixa, contate o TI
	Endif
	
If Valtype(oModelG6T) = "O"
	oModelG6T:DeActivate()
	oModelG6T:Destroy()
	oModelG6T:= nil
EndIf	

Return(lRet)




//-------------------------------------------------------------------


//---------------------------------------------------------------------------
/*/{Protheus.doc} CA700WDG01

Monta a GRID do alias 

@sample	CA290WDG03( oPanel, cAliasEnt, cFonte, cType )

@param		oPanel 		- Objeto onde será montada a GRID
			cAliasEnt	- Entidade para qual sera montada a grid
			cFonte  	- Nome do Fonte para busca das VISOES e GRAFICOS
			cFiltro	- Filtro do CRM

@return	ExpO - Panel 

@author	Thiago Tavares
@since		16/04/2014
@version	P12
/*/
//---------------------------------------------------------------------------
Static Function CA700WDG01( oPanel, cAliasEnt, cFonte, cType )
 
Local oTableAttach  
Local aVisions     := {}
Local aCharts      := {}

oWidget      := FWTableAttachWidget():New()
oTableAttach := FWGetAttSrc( cFonte )
oMBrowse     := oWidget:GetBrowse()

oMBrowse:AddLegend("G6T_STSTIT=='0'", "BR_BRANCO",   STR0072)//Titulos não gerados
oMBrowse:AddLegend("G6T_STSTIT=='1'", "BR_AMARELO",  STR0073)//Gerando titulos
oMBrowse:AddLegend("G6T_STSTIT=='2'", "BR_VERDE",    STR0074)//Titulos gerados
oMBrowse:AddLegend("G6T_STSTIT=='3'", "BR_VERMELHO", STR0075)//Erro na geração dos titulos
oMBrowse:AddLegend("G6T_STSTIT=='4'", "BR_AZUL",     STR0076)//Cancelando titulos
oMBrowse:AddLegend("G6T_STSTIT=='5'", "BR_LARANJA",  STR0077)//"Titulos cancelados"
oMBrowse:AddLegend("G6T_STSTIT=='6'", "BR_CINZA",    STR0078)//"Erro ao cancelar títulos"

If oTableAttach <> nil

	oMBrowse:SetMenuDef( cFonte )      
    oMBrowse:SetFilterDefault ( 'G6T_FILIAL == "' + xFilial('G6T') + '"')
	aVisions := oTableAttach:aViews 
	aCharts  := oTableAttach:aCharts	
	
	oWidget:setVisions( aVisions )
	oWidget:setCharts( aCharts )
	oWidget:setAlias( cAliasEnt )	
	oWidget:setVisionDefault( aVisions[1] )
	oWidget:setDisplayMode( cType )	
	oWidget:setOwner( oPanel )
	oWidget:setOpenChart( .T. )
	oWidget:Activate()	
	
EndIf

Return oPanel

//---------------------------------------------------------------------------
/*/{Protheus.doc} GTP700GVisao

Pega a visão vigente

@return	cVisao 

@author	Fernando Amorim(cafu)
@since		30/10/2017
@version	P12
/*/
//---------------------------------------------------------------------------
Function GTP700GVisao()

Local cVisao := ''
Local lVisao := .F.

lVisao := aScan(oMBrowse:OFWFILTER:AFILTER,{|x| x[1] == VISAO_1}) > 0

If lVisao 
	cVisao :=  VISAO_1	
Endif

If !lVisao
	lVisao := aScan(oMBrowse:OFWFILTER:AFILTER,{|x| x[1] == VISAO_2}) > 0
	
	If lVisao  
		cVisao :=  VISAO_2
	Endif
EndIf

If !lVisao
	lVisao :=  aScan(oMBrowse:OFWFILTER:AFILTER,{|x| x[1] == VISAO_3 }) > 0
	
	If lVisao 
		cVisao :=  VISAO_3	
	Endif
EndIf

If Empty(cVisao)
	FwAlertHelp(STR0049,STR0050) // "Visão", "Somente as visões  'Caixa Aberto', 'Caixa Reaberto' e  'Caixa Fechado', permitem  utilizar as rotinas de lançamentos. " 
Endif
Return cVisao

//---------------------------------------------------------------------------
/*/{Protheus.doc} GTPPROCF()

Processa os lançamento pra gerar o faturamento e financeiro

@return	lRet 

@author	Fernando Amorim(cafu)
@since		07/11/2017
@version	P12
/*/
//---------------------------------------------------------------------------
Function GTPPROCF(cMsgTit)

Local lRet	:= .T.
Local cAliasQry1 	:= GetNextAlias()
Local cAliasQry2 	:= GetNextAlias()
Local cAliasQry3 	:= GetNextAlias()
Local cAliasQry4 	:= GetNextAlias()
Local cAliasQry5 	:= GetNextAlias()
Local cAliasQry6	:= GetNextAlias()
Local cAliasQry7	:= GetNextAlias()
Local cAliasGZK		:= GetNextAlias() 
Local cTitChave     := ""
Local aArray		:= {}
Local cParc			:= '1'
Local cNum			:= ''
Local cNatTit		:= ''
Local aBaixa		:= {}
Local cBancoBx		:= ''
Local nRecFch		:= 0
Local nDesFch		:= 0
Local nVlReqRej		:= 0
Local aTitSE1 		:= {}
Local cFilAtu		:= cFilAnt
Local aDadosG6X 	:= {}
Local cPath     	:= GetSrvProfString("Rootpath","")
Local cFile     	:= ""
Local nVlRec		:= 0
Local cPrefixo   	:= "PRV" 
Local cTipo      	:= "TF "
Local lGT700BXT		:= ExistBlock("GT700BXT")
Local cCampos		:= ""
Local cTipoDep		:= ""

Private lMsErroAuto := .F.

nValorSld := 0

If G6X->(FieldPos('G6X_TITPRO')) > 0 
	cCampos :=  ' ,G6X_TITPRO ' 
Endif

If G6X->(FieldPos('G6X_DEPOSI')) > 0 
	cCampos +=  ' ,G6X_DEPOSI ' 
Endif

cCampos := "%"+cCampos+"%"

Begin Transaction

BeginSQL Alias cAliasQry1
		
	SELECT 	G6X_FILIAL,
			G6X_AGENCI,
			G6X_NUMFCH,
			G6X_VLRLIQ,
			G59_RECBIL,
			G59_RECTAX, 
			G6X.R_E_C_N_O_ AS RECG6X
			%Exp:cCampos%
	FROM %Table:G6X% G6X 
	INNER JOIN %Table:G59% G59 ON
		G6X.G6X_FILIAL = G59.G59_FILIAL AND
		G6X.G6X_AGENCI = G59.G59_AGENCI AND
		G6X.G6X_NUMFCH = G59.G59_NUMFCH AND
		G59.%NotDel%
	WHERE G6X_FILIAL = %xFilial:G6X%
		AND G6X.G6X_CODCX = %Exp:G6T->G6T_CODIGO%
		AND G6X.G6X_FLAGCX = 'T'
		AND G6X.G6X_FECHCX = 'F'
		AND G6X.G6X_STATUS = '3'
		AND G6X.G6X_TITCX = ' '
		AND G6X.G6X_AGENCI = %Exp:G6T->G6T_AGENCI%
		AND G6X.%NotDel%
		
EndSQL

If (cAliasQry1)->(!Eof())

	While (cAliasQry1)->(!Eof())

		cTipoDep := ""

		If G6X->(FieldPos('G6X_DEPOSI')) > 0 
			cTipoDep := (cAliasQry1)->G6X_DEPOSI
		Endif
	
		G6X->(DbGoTo((cAliasQry1)->RECG6X ))
		
		nRecFch := 0 
		nDesFch := 0
		nVlRec  := 0
		
		BeginSQL Alias cAliasQry2
				
			SELECT  SUM(G6Y_VALOR) as VLDES
			FROM %Table:G6Y% G6Y
			WHERE 
			G6Y_FILIAL = %xFilial:G6T%
			AND G6Y_NUMFCH = %Exp:(cAliasQry1)->G6X_NUMFCH%
			AND (G6Y_TPLANC IN ('1','5','6') OR (G6Y_TPLANC IN ('2','9') AND G6Y_STSDEP = '1') OR (G6Y_ACERTO = 'T' AND G6Y_TPLANC NOT IN ('3','8')))
			AND G6Y_CODIGO = %Exp:G6T->G6T_CODIGO%
			AND G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
			AND %NotDel%
			
		EndSQL
					
		If GQW->(FieldPos('GQW_CONFER')) > 0 .And. GQW->(FieldPos('GQW_NUMFCH')) > 0

			BeginSql Alias cAliasQry7

				SELECT COALESCE(SUM(GQW.GQW_TOTAL), 0) AS TOT_REJ
				FROM %Table:GQW% GQW
				WHERE GQW.GQW_FILIAL = %xFilial:GQW%
				AND GQW.GQW_CODAGE = %Exp:G6T->G6T_AGENCI%
				AND GQW.GQW_NUMFCH =  %Exp:(cAliasQry1)->G6X_NUMFCH%
				AND GQW.GQW_CONFCH = '3'
				AND GQW.%NotDel%

			EndSql

			nVlReqRej := (cAliasQry7)->TOT_REJ	

			(cAliasQry7)->(dbCloseArea())

		Endif	

		If (cAliasQry2)->(!Eof())
			nDesFch := (cAliasQry2)->VLDES - nVlReqRej			
		Endif

		If Select(cAliasQry2) > 0
			(cAliasQry2)->(dbCloseArea())
		Endif
		
		BeginSQL Alias cAliasQry5
				
			SELECT  SUM(G6Y_VALOR) as VLREC
			FROM %Table:G6Y% G6Y
			WHERE 
			G6Y_FILIAL = %xFilial:G6Y%
			AND G6Y_NUMFCH = %Exp:(cAliasQry1)->G6X_NUMFCH%
			AND G6Y_TPLANC = '8' 
			AND G6Y_STSDEP = '1' 
			AND G6Y_CODIGO = %Exp:G6T->G6T_CODIGO%
			AND G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
			AND %NotDel%
			
		EndSQL

		If (cAliasQry5)->(!Eof())
			nVlRec := (cAliasQry5)->VLREC			
		Endif
		
		If Select(cAliasQry5) > 0
			(cAliasQry5)->(dbCloseArea())
		Endif

		nRecFch := (cAliasQry1)->G59_RECBIL + (cAliasQry1)->G59_RECTAX + nVlRec
		
		BeginSQL Alias cAliasQry4
				
			SELECT  *
			FROM %Table:G6Y% G6Y
			WHERE 
			G6Y.G6Y_FILIAL = %xFilial:G6Y%
			AND G6Y_NUMFCH = %Exp:(cAliasQry1)->G6X_NUMFCH%
			AND (G6Y_TPLANC = '7' AND G6Y_AGRUPA = 'T')
			AND G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
			AND %NotDel%
			Order By G6Y_BILHET	
			
		EndSQL
		
		If (cAliasQry4)->(!Eof())
			SE1->(DbSetOrder(2))
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+Alltrim((cAliasQry4)->G6Y_CODADM)))
			While (cAliasQry4)->(!Eof())
				If !EMPTY((cAliasQry4)->G6Y_CHVTX )
					If SE1->(DbSeek(xFilial("SE1")+ PADR((cAliasQry4)->G6Y_CODADM,TAMSX3("E1_CLIENTE")[1])  + SA1->A1_LOJA + 'TEF' + Alltrim((cAliasQry4)->G6Y_CHVTX) )) 
						While !SE1->(Eof()) .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
							 SE1->E1_CLIENTE == PADR((cAliasQry4)->G6Y_CODADM,TAMSX3("E1_CLIENTE")[1]) .And.  SE1->E1_LOJA == SA1->A1_LOJA .And.;
							SE1->E1_PREFIXO == 'TEF' .And. SE1->E1_NUM	==   Alltrim((cAliasQry4)->G6Y_CHVTX)
							
							If SE1->E1_SALDO  == SE1->E1_VALOR
									aTitSE1 := {}
									aTitSE1 := {	{ "E1_PREFIXO"	, SE1->E1_PREFIXO		, Nil },; //Prefixo 
						 				{ "E1_NUM"		, SE1->E1_NUM  					    , Nil },; //Numero
								 		{ "E1_PARCELA"	, SE1->E1_PARCELA				    , Nil },; //Parcela
										{ "E1_TIPO"		, SE1->E1_TIPO					    , Nil },; //Tipo
						 				{ "E1_NATUREZ"	, SE1->E1_NATUREZ			        , Nil },; //Natureza
						 				{ "E1_CLIENTE"	, SE1->E1_CLIENTE				    , Nil },; //Cliente
						 				{ "E1_LOJA"		, SE1->E1_LOJA			 		    , Nil },; //Loja
						 				{ "E1_EMISSAO"	, SE1->E1_EMISSAO		         	, Nil },; //Data Emissão
						 				{ "E1_VENCTO"	, SE1->E1_VENCTO				    , Nil },; //Data Vencimento
						 				{ "E1_VENCREA"	, SE1->E1_VENCREA				    , Nil },; //Data Vencimento Real
						 				{ "E1_VALOR"	, SE1->E1_VALOR				        , Nil },; //Valor
						 				{ "E1_SALDO"	, SE1->E1_SALDO					    , Nil },; //Saldo
						 				{ "E1_HIST"		, SE1->E1_HIST						, Nil },; //HIstórico
						 				{ "E1_ORIGEM"	, "GTPA700"							, Nil }}  //Origem
						 					
									 MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 5)  // Exclui o título
									 
									 If lMsErroAuto
										lRet := .F.
										cMsgTit := MostraErro(cPath,cFile) + CRLF										
										Exit
										DisarmTransaction()
									 Else
										lRet := .T.
										
									 EndIf
							
							Endif
							SE1->(DbSkip ())
						End
					
					Endif
				Endif
				(cAliasQry4)->(dbSkip())
			End
		Endif
		
		If Select(cAliasQry4) > 0
			(cAliasQry4)->(dbCloseArea())
		Endif
				
		nValorSld := nRecFch - nDesFch
		
		If G6X->(FieldPos('G6X_TITPRO')) > 0 .And. (cAliasQry1)->G6X_TITPRO == '2' // Se titulo provisorio da ficha estiver configurado como 'Não' executa o processo sem baixas e criação de títulos

			lRet := PrcFechSld(nRecFch, nDesFch, (cAliasQry1)->G6X_VLRLIQ, G6T->G6T_CODIGO, G6T->G6T_AGENCI, (cAliasQry1)->G6X_NUMFCH)

			If lRet
				cMsgTit := ''
				
				If Round(nValorSld,2) <> 0
					cMsgTit := I18n(STR0137 + AllTrim(Transform(nValorSld,"@E 999,999,999,999.99")) + STR0138) //' Diferença de ', ' lançada no conta corrente da agência'
				Endif
			Else
				DisarmTransaction()
			Endif

		Else

			If  cTipoDep == '3' // Se pagamento for boleto

				lRet := VldBxBoleto(G6T->G6T_CODIGO, G6T->G6T_AGENCI, (cAliasQry1)->G6X_NUMFCH, @cMsgTit)

			Endif

			If lRet 
				If round(nValorSld,2) > 0
				
					GI6->(DbSetOrder(1))
					GI6->(DbSeek(xFilial("GI6")+ G6T->G6T_AGENCI))
					If !Empty(GI6->GI6_FILRES)
						cFilAnt := GI6->GI6_FILRES
					Endif
					If !Empty(GI6->GI6_FORNEC) .AND. !Empty(GI6->GI6_LOJA) .AND. !Empty(GI6->GI6_BANCO) .AND. !Empty(GI6->GI6_AGENCI) .AND. !Empty(GI6->GI6_CONTA)
					
						BeginSQL Alias cAliasQry3
								
							SELECT  *
							FROM %Table:SE2% SE2
							WHERE E2_FILIAL = %xFilial:SE2%
							AND E2_FORNECE = %Exp:GI6->GI6_FORNEC%
							AND E2_LOJA = %Exp:GI6->GI6_LOJA%
							AND E2_SALDO > 0
							AND %NotDel%
										
						EndSQL
								
						If (cAliasQry3)->(!Eof())
							FWExecView(STR0060,"VIEWDEF.GTPA700H",MODEL_OPERATION_INSERT,,,,50)//"Titulos a pagar" 
						Endif
						If Select(cAliasQry3) > 0
							(cAliasQry3)->(dbCloseArea())
						Endif
						
						BeginSQL Alias cAliasGZK
							
							SELECT *
							FROM %Table:GZK% GZK
							WHERE GZK_FILIAL = %xFilial:GZK%
							AND GZK_CAIXA = %Exp:G6T->G6T_CODIGO%
							AND GZK_AGENCI = %Exp:G6T->G6T_AGENCI%
							AND GZK_FICHA = %Exp:(cAliasQry1)->G6X_NUMFCH%
							AND %NotDel%
										
						EndSQL
			
						(cAliasGZK)->(DbGoTop())
						
						cBancoBx	:= GTPGetRules('BANCOBX')
						
						While (cAliasGZK)->(!Eof() .AND. lRet .AND. round(nValorSld,2) > 0 )

							aBaixa := { {"E2_PREFIXO"   ,(cAliasGZK)->GZK_PREFIX 	,Nil},;
										{"E2_NUM"       ,(cAliasGZK)->GZK_NUMTIT 	,Nil},;
										{"E2_PARCELA"   ,(cAliasGZK)->GZK_PARCEL 	,Nil},;
										{"E2_TIPO"      ,(cAliasGZK)->GZK_TIPO		,Nil},;
										{"E2_FORNECE"   ,(cAliasGZK)->GZK_FORNEC 	,Nil},;
										{"E2_LOJA"      ,(cAliasGZK)->GZK_LOJA 		,Nil},;
										{"E2_FILIAL"    ,xFilial("SE2") 			,Nil},;
										{"AUTBANCO"     ,GI6->GI6_BANCO 		    ,Nil},;
										{"AUTAGENCIA"   ,GI6->GI6_AGENCI    		,Nil},;
										{"AUTCONTA"     ,GI6->GI6_CONTA    			,Nil},;									
										{"AUTMOTBX"     ,"NOR"      				,Nil},;
										{"AUTDTBAIXA"   ,dDatabase  				,Nil},;
										{"AUTDTCREDITO" ,dDatabase  				,Nil},;
										{"AUTHIST"      ,STR0124 + G6T->G6T_CODIGO 	,Nil},; // "Compensa no fechamento do cx: "
										{"AUTVLRPG"     ,If((cAliasGZK)->GZK_VALOR < nValorSld,(cAliasGZK)->GZK_VALOR,nValorSld) 	,Nil },;
										{"AUTVLRME"     ,If((cAliasGZK)->GZK_VALOR < nValorSld,(cAliasGZK)->GZK_VALOR,nValorSld)  	,Nil }}  
									
							lMsErroAuto := .F.
					
							MSExecAuto({|x,y| fina080(x,y)},aBaixa,3) // Baixa
							
							If lMsErroAuto
							
								lRet := .F.	
								cMsgTit := MostraErro(cPath,cFile) + CRLF			
								
								DisarmTransaction()
								Break
								Exit
								
							Else

								lRet := .T.
								nValorSld := nValorSld - (cAliasGZK)->GZK_VALOR
								GZK->(DbGoTo((cAliasGZK)->R_E_C_N_O_ ))
								GZK->(RecLock("GZK",.F.))
								GZK->GZK_FILSE5	:= FK2->FK2_FILIAL
								GZK->GZK_SEQ	:= FK2->FK2_SEQ
								GZK->GZK_IDORIG	:= FK2->FK2_IDFK2
								GZK->(MsUnlock())
							Endif
						
							(cAliasGZK)->(DbSkip())
						End
						If Select(cAliasGZK) > 0
							(cAliasGZK)->(dbCloseArea())
						Endif
					
					EndIf
					If round(nValorSld,2) < 0
						nValorSld := 0
					Endif
				Endif
				If  round(nValorSld,2) > 0  
					If lRet
						// gera titulo no contas a receber
						aArray 	:= {}
						cParc	:= StrZero(1,TamSx3('E1_PARCELA')[1])
						
						cNum := GtpTitNum('SE1', 'FCH', cParc, 'TF')
						
						cNatTit	:= GTPGetRules('NATUREC')
						cTitChave   := xFilial("SE1")+PadR("FCH",TamSx3('E1_PREFIXO')[1])+cNum+PadR(cParc,TamSx3('E1_PARCELA')[1])+PadR("TF",TamSx3('E1_TIPO')[1])
						
						If !Empty(GI6->GI6_CLIENT) .AND.  !Empty(GI6->GI6_LJCLI)
							aAdd( aArray,	{ "E1_PREFIXO"	, "FCH" 			, NIL } )
							aAdd( aArray,	{ "E1_NUM" 		, cNum				, NIL } )
							aAdd( aArray,	{ "E1_TIPO" 	, "TF" 				, NIL } )
							aAdd( aArray,	{ "E1_NATUREZ"	, cNatTit 			, NIL } )
							aAdd( aArray,	{ "E1_CLIENTE" 	, GI6->GI6_CLIENT	, NIL } )
							aAdd( aArray,	{ "E1_LOJA"		, GI6->GI6_LJCLI	, NIL } )
							aAdd( aArray, 	{ "E1_PARCELA" 	, cParc 			, NIL } )
							aAdd( aArray,	{ "E1_EMISSAO"	, dDataBase			, NIL } )
							aAdd( aArray,	{ "E1_VENCTO"	, dDataBase			, NIL } )
							aAdd( aArray,	{ "E1_VENCREA"	, dDataBase			, NIL } )
							aAdd( aArray,	{ "E1_VALOR" 	, nValorSld			, NIL } )
							aAdd( aArray,	{ "E1_HIST"		, G6T->G6T_CODIGO+G6T->G6T_AGENCI+(cAliasQry1)->G6X_NUMFCH	, NIL } )
							aAdd( aArray,	{ "E1_ORIGEM"	, 'GTPA700A' 		, NIL } )
						
							MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 3) // 3-Inclusao,4-Alteração,5-Exclusão
						
							If lMsErroAuto
								lRet := .F.
								cMsgTit := MostraErro(cPath,cFile) + CRLF
								DisarmTransaction()
							Else
								cFilAnt := cFilAtu
								cMsgTit	+= I18n(' a receber de numero: #1 com o valor de: #2'+CRLF,{SE1->E1_NUM,SE1->E1_VALOR})
								aDadosG6X := {}
								aAdd( aDadosG6X,	{ "G6X_RECCX"  , nRecFch	} )
								aAdd( aDadosG6X,	{ "G6X_DESCX"  , nDesFch	} )
								aAdd( aDadosG6X,	{ "G6X_SLDCX"  , ( nRecFch - nDesFch ) } )
								aAdd( aDadosG6X,	{ "G6X_TPSLCX" , "CR"	} )
								aAdd( aDadosG6X,	{ "G6X_STATUS" , "4"	} )
								aAdd( aDadosG6X,	{ "G6X_TITCX"  , cTitChave	} )
								aAdd( aDadosG6X,	{ "G6X_FECHCX"  , .T.	} )
								aAdd( aDadosG6X,	{ "G6X_DTCAIX"  , DDATABASE	} )
								DbSelectArea("G6X")
								G6X->(DbGoTo((cAliasQry1)->RECG6X ))
								
								lRet := AtuG6X(aDadosG6X)

								If !(lRet)
									cMsgTit := STR0079  + CRLF//"Erro ao gravar o status na ficha de remessa"
									DisarmTransaction()
								Endif	 
								
								cTitChave := xFilial("SE1")+PadR("FCH",TamSx3('E1_PREFIXO')[1])+cNum+PadR(cParc,TamSx3('E1_PARCELA')[1])+PadR("TF",TamSx3('E1_TIPO')[1])
						
							Endif
						Else
							lRet := .F.
							cMsgTit := STR0080  + CRLF//"Não foi informado o cliente no cadastro de Agencia "
							DisarmTransaction()
						Endif
					Endif
					cFilAnt := cFilAtu
				ElseIf round(nValorSld,2) < 0
				
					// gera titulo no contas a pagar
					aArray := {}
					cParc	:= StrZero(1,TamSx3('E2_PARCELA')[1])
					
					cNum := GtpTitNum('SE2', 'FCH', cParc, 'TF')
					
					cNatTit	:= GTPGetRules('NATUPAG')
					
					GI6->(DbSetOrder(1))
					GI6->(DbSeek(xFilial("GI6")+ G6T->G6T_AGENCI))
					If !Empty(GI6->GI6_FILRES)
						cFilAnt := GI6->GI6_FILRES
					Endif
					cTitChave := xFilial("SE2")+PadR("FCH",TamSx3('E2_PREFIXO')[1])+cNum+PadR(cParc,TamSx3('E2_PARCELA')[1])+PadR("TF",TamSx3('E2_TIPO')[1]);
								+PadR(GI6->GI6_FORNEC,TamSx3('GI6_FORNEC')[1])+PadR(GI6->GI6_LOJA,TamSx3('GI6_LOJA')[1])
					
					If !Empty(GI6->GI6_FORNEC) .AND.  !Empty(GI6->GI6_LOJA)
						aAdd( aArray,	{ "E2_PREFIXO" 	, 'FCH'				, NIL 	} )
						aAdd( aArray,	{ "E2_NUM" 		, cNum 				, NIL 	} )
						aAdd( aArray,	{ "E2_TIPO" 	, "TF" 				, NIL 	} )
						aAdd( aArray,	{ "E2_PARCELA" 	, cParc				, NIL 	} )
						aAdd( aArray,	{ "E2_NATUREZ" 	, cNatTit			, NIL 	} )
						aAdd( aArray,	{"E2_FORNECE"	, GI6->GI6_FORNEC	, Nil 	} )
						aAdd( aArray,	{"E2_LOJA"   	, GI6->GI6_LOJA  	, Nil 	} )
						aAdd( aArray,	{"E2_EMISSAO"	, dDataBase			, Nil 	} )
						aAdd( aArray,	{"E2_VENCTO" 	, dDataBase			, NIL 	} )
						aAdd( aArray, 	{"E2_VENCREA" 	, dDataBase			, NIL 	} )
						aAdd( aArray,	{"E2_MOEDA" 	, 1					, NIL 	} )
						aAdd( aArray,	{"E2_VALOR" 	, (nValorSld * -1)			, NIL 	} )
						aAdd( aArray,	{"E2_HIST"		, G6T->G6T_CODIGO+G6T->G6T_AGENCI+(cAliasQry1)->G6X_NUMFCH	, NIL } )
						aAdd( aArray,	{"E2_ORIGEM" 	, 'GTPA700A'		, NIL 	} )
					
						MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)
						
						If lMsErroAuto
							lRet := .F.
							cMsgTit := MostraErro(cPath,cFile) + CRLF
							DisarmTransaction()
						Else
							cFilAnt := cFilAtu
							cMsgTit	+= I18n(' a pagar de numero: #1 com o valor de: #2'+CRLF,{SE2->E2_NUM,SE2->E2_VALOR})
							aDadosG6X := {}
							
							aAdd( aDadosG6X,	{ "G6X_RECCX"  , nRecFch	} )
							aAdd( aDadosG6X,	{ "G6X_DESCX"  , nDesFch	} )
							aAdd( aDadosG6X,	{ "G6X_SLDCX"  , ( nRecFch - nDesFch )* -1 } )
							aAdd( aDadosG6X,	{ "G6X_TPSLCX" , "CP"	} )
							aAdd( aDadosG6X,	{ "G6X_STATUS" , "4"	} )
							aAdd( aDadosG6X,	{ "G6X_TITCX"  , cTitChave	} )
							aAdd( aDadosG6X,	{ "G6X_FECHCX"  , .T.	} )
							aAdd( aDadosG6X,	{ "G6X_DTCAIX"  , DDATABASE	} )
							DbSelectArea("G6X")
							G6X->(DbGoTo((cAliasQry1)->RECG6X ))
							
							lRet := AtuG6X(aDadosG6X)
							
							If !(lRet)
								cMsgTit := STR0079  + CRLF//"Erro ao gravar o status na ficha de remessa"
								DisarmTransaction()
							Endif	
						Endif
					Else
						lRet := .F.
						cMsgTit := STR0118  + CRLF//"Não foi informado o fornecedor no cadastro de Agencia "
						DisarmTransaction()
					Endif
					
					cFilAnt := cFilAtu
				Else
					cFilAnt := cFilAtu
					cMsgTit	:= 	STR0081 + CRLF//'Não houve diferença entre receitas e despesas e o valor da ficha foi conferido com sucesso'
					aDadosG6X := {}
					
					aAdd( aDadosG6X,	{ "G6X_RECCX"  , nRecFch	} )
					aAdd( aDadosG6X,	{ "G6X_DESCX"  , nDesFch	} )
					aAdd( aDadosG6X,	{ "G6X_SLDCX"  , ( nRecFch - nDesFch ) } )
					aAdd( aDadosG6X,	{ "G6X_STATUS" , "4"	} )
					aAdd( aDadosG6X,	{ "G6X_FECHCX"  , .T.	} )
					aAdd( aDadosG6X,	{ "G6X_DTCAIX"  , DDATABASE	} )
					DbSelectArea("G6X")
					G6X->(DbGoTo((cAliasQry1)->RECG6X ))

					lRet :=  AtuG6X(aDadosG6X)

					If !(lRet)
						cMsgTit := STR0079  + CRLF//"Erro ao gravar o status na ficha de remessa"
						DisarmTransaction()
					Endif	
		
				Endif
			EndIf
		
			If lRet .And. cTipoDep != '3' //Realizar a baixa do provisório apenas se o pagamento não for por boleto
				// Baixa do titulo provisório das fichas ou geração de um novo deletando o outro conforme aceite no lançamento de depositos.
				
				BeginSQL Alias cAliasQry6
						
					SELECT G6Y_VALOR,G6Y_DATA, G6Y_BANCO,G6Y_AGEBCO,G6Y_CTABCO,G6Y_CHVTIT,G6Y_STSDEP,G6Y_IDDEPO,G6Y.R_E_C_N_O_ AS RECNOG6Y
					FROM %Table:G6Y% G6Y
					WHERE 
					G6Y_FILIAL = %xFilial:G6Y%
					AND G6Y_NUMFCH = %Exp:(cAliasQry1)->G6X_NUMFCH%
					AND G6Y_TPLANC = '2' 				
					AND G6Y_VALOR > 0
					AND G6Y_CODIGO = %Exp:G6T->G6T_CODIGO%
					AND G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
					AND %NotDel%
					//Order By G6Y_TPLANC	
					//AND G6Y_STSDEP = '1' 
				EndSQL
				
				While (cAliasQry6)->(!Eof() .AND. lRet)
					If (cAliasQry6)->G6Y_STSDEP = '1' 
						lMsErroAuto := .F.
						DbSelectArea("SE1")
						SE1->(DbSetOrder(1))
						If !Empty((cAliasQry6)->G6Y_CHVTIT) .AND. SE1->(DbSeek((cAliasQry6)->G6Y_CHVTIT+GI6->GI6_CLIENT+GI6->GI6_LJCLI));
						.AND. SE1->E1_VALOR == (cAliasQry6)->G6Y_VALOR .AND. dDataBase == STOD((cAliasQry6)->G6Y_DATA ) .AND. Empty(SE1->E1_BAIXA)
							G6Y->(DbGoTo((cAliasQry6)->RECNOG6Y ))
							aArray 	:= {}	
							aArray 	 := {{"E1_FILIAL"  , SE1->E1_FILIAL       	,Nil    },;
										{"E1_PREFIXO"  , SE1->E1_PREFIXO       	,Nil    },;
										{"E1_NUM"      , SE1->E1_NUM          		,Nil    },;
										{"E1_TIPO"     ,SE1->E1_tiPO            	,Nil    },;
										{"AUTMOTBX"    ,"NOR"                  		,Nil    },;
										{"AUTBANCO"    ,(cAliasQry6)->G6Y_BANCO     ,Nil    },;
										{"AUTAGENCIA"  ,(cAliasQry6)->G6Y_AGEBCO    ,Nil    },;
										{"AUTCONTA"    ,(cAliasQry6)->G6Y_CTABCO    ,Nil    },;
										{"AUTDTBAIXA"  ,DataValida(STOD((cAliasQry6)->G6Y_DATA ) ) 		,Nil    },;
										{"AUTDTCREDITO",DataValida(STOD((cAliasQry6)->G6Y_DATA ))   	,Nil    },;
										{"AUTHIST"     ,STR0125	+ (cAliasQry1)->G6X_NUMFCH	,Nil    },; // "Bx tit. no fechamento da ficha: "
										{"AUTJUROS"    ,0                      	,Nil,.T.},;
										{"AUTVALREC"   ,(cAliasQry6)->G6Y_VALOR    	,Nil    }}
										
										
						MSExecAuto({|x,y| FINA070(x,y)},aArray,3) // Exclui a baixa do título
										
							If lMsErroAuto
								lRet := .F.
								cMsgTit := MostraErro(cPath,cFile) + CRLF
								DisarmTransaction()
							Else
							
								If lGT700BXT
								
									ExecBlock("GT700BXT",.F.,.F.)
								
								Endif
							
								lRet := .T.	
							Endif
								
						Else	
						
							SE1->(DbSetOrder(1))
							If !Empty((cAliasQry6)->G6Y_CHVTIT) .AND. SE1->(DbSeek((cAliasQry6)->G6Y_CHVTIT+GI6->GI6_CLIENT+GI6->GI6_LJCLI));
							.AND. Empty(SE1->E1_BAIXA)
								cFilAnt := SE1->E1_FILORIG	
								aArray 	:= {}	
								aArray := {		{ "E1_FILIAL"	, SE1->E1_FILIAL		            , Nil },; //Prefixo
												{ "E1_PREFIXO"	, SE1->E1_PREFIXO		            , Nil },; //Prefixo 
												{ "E1_NUM"		, SE1->E1_NUM  					    , Nil },; //Numero
												{ "E1_PARCELA"	, SE1->E1_PARCELA				    , Nil },; //Parcela
												{ "E1_TIPO"		, SE1->E1_TIPO					    , Nil },; //Tipo
												{ "E1_NATUREZ"	, SE1->E1_NATUREZ			        , Nil },; //Natureza
												{ "E1_CLIENTE"	, SE1->E1_CLIENTE				    , Nil },; //Cliente
												{ "E1_LOJA"		, SE1->E1_LOJA			 		    , Nil },; //Loja
												{ "E1_EMISSAO"	, SE1->E1_EMISSAO		         	, Nil },; //Data Emissão
												{ "E1_VENCTO"	, SE1->E1_VENCTO				    , Nil },; //Data Vencimento
												{ "E1_VENCREA"	, SE1->E1_VENCREA				    , Nil },; //Data Vencimento Real
												{ "E1_VALOR"	, SE1->E1_VALOR				        , Nil },; //Valor
												{ "E1_SALDO"	, SE1->E1_SALDO					    , Nil },; //Saldo
												{ "E1_HIST"		, SE1->E1_HIST						, Nil },; //HIstórico
												{ "E1_ORIGEM"	, "GTPA700"						, Nil }}  //Origem
													
								MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 5)  // Exclui o título
								
								If lMsErroAuto
									lRet := .F.
									cMsgTit := MostraErro(cPath,cFile) + CRLF
									cFilAnt := cFilAtu										
									DisarmTransaction()
								Else
									lRet := .T.
									
								EndIf
							Else
								lRet:= .T.					
							EndIf
						
							If lRet	
							
								aArray 	:= {}
								cParc	:= StrZero(1,TamSx3('E1_PARCELA')[1])
								cNatTit	:= GPA281PAR("NATUREZA")
								If !Empty(GI6->GI6_CLIENT) .AND.  !Empty(GI6->GI6_LJCLI)
									If !Empty(GI6->GI6_FILRES)
										cFilAnt := GI6->GI6_FILRES
									Endif

									cNum := GtpTitNum('SE1', cPrefixo, cParc, cTipo)								
									
								cTitChave   := xFilial("SE1")+PadR(cPrefixo,TamSx3('E1_PREFIXO')[1])+cNum+PadR(cParc,TamSx3('E1_PARCELA')[1])+PadR(cTipo,TamSx3('E1_TIPO')[1])
								
								aArray :={{ "E1_PREFIXO"	, cPrefixo		   , Nil },; //Prefixo 
											{ "E1_NUM"		, cNum		   		, Nil },; //Numero
											{ "E1_PARCELA"	, cParc 		   , Nil },; //Parcela
											{ "E1_TIPO"		, cTipo			   , Nil },; //Tipo
											{ "E1_NATUREZ"	, cNatTit		   , Nil },; //Natureza
											{ "E1_CLIENTE"	, GI6->GI6_CLIENT	, Nil },; //Cliente
											{ "E1_LOJA"		, GI6->GI6_LJCLI 	, Nil },; //Loja
											{ "E1_EMISSAO"	, STOD((cAliasQry6)->G6Y_DATA )	   , Nil },; //Data Emissão
											{ "E1_VENCTO"	, STOD((cAliasQry6)->G6Y_DATA )		   , Nil },; //Data Vencimento
											{ "E1_VENCREA"	, DataValida(STOD((cAliasQry6)->G6Y_DATA ))	   , Nil },; //Data Vencimento Real
											{ "E1_VALOR"	, (cAliasQry6)->G6Y_VALOR		   , Nil },; //Valor
											{ "E1_SALDO"	, (cAliasQry6)->G6Y_VALOR		   , Nil },; //Saldo
											{ "E1_HIST"		, G6X->G6X_AGENCI+G6X->G6X_NUMFCH , Nil },; //HIstórico
											{ "E1_ORIGEM"	, "GTPA700"		   , Nil }}  //Origem
							
								
									MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 3) // 3-Inclusao,4-Alteração,5-Exclusão
								
									If lMsErroAuto
										lRet := .F.
										cMsgTit := MostraErro(cPath,cFile) + CRLF
										cFilAnt := cFilAtu
										DisarmTransaction()
									Else
										SE1->(DbSetOrder(1))
										If SE1->(DbSeek(cTitChave))
											G6Y->(DbGoTo((cAliasQry6)->RECNOG6Y ))
											aArray 	:= {}	
											aArray 	 := {	{"E1_FILIAL"   , SE1->E1_FILIAL       	,Nil    },;
															{"E1_PREFIXO"  , SE1->E1_PREFIXO       	,Nil    },;
															{"E1_NUM"      , SE1->E1_NUM          		,Nil    },;
															{"E1_TIPO"     ,SE1->E1_tiPO            	,Nil    },;
															{"AUTMOTBX"    ,"NOR"                  		,Nil    },;
															{"AUTBANCO"    ,(cAliasQry6)->G6Y_BANCO     ,Nil    },;
															{"AUTAGENCIA"  ,(cAliasQry6)->G6Y_AGEBCO    ,Nil    },;
															{"AUTCONTA"    ,(cAliasQry6)->G6Y_CTABCO    ,Nil    },;
															{"AUTDTBAIXA"  ,DataValida(STOD((cAliasQry6)->G6Y_DATA ) )             		,Nil    },;
															{"AUTDTCREDITO",DataValida(STOD((cAliasQry6)->G6Y_DATA ))   	,Nil    },;
															{"AUTHIST"     ,STR0125	+ G6X->G6X_NUMFCH	,Nil    },; // "Bx tit. no fechamento da Ficha: "
															{"AUTJUROS"    ,0                      	,Nil,.T.},;
															{"AUTVALREC"   ,(cAliasQry6)->G6Y_VALOR    	,Nil    }}
														
														
										MSExecAuto({|x,y| FINA070(x,y)},aArray,3)
														
											If lMsErroAuto
												lRet := .F.
												cMsgTit := MostraErro(cPath,cFile) + CRLF
												DisarmTransaction()
											Else
												lRet := .T.
												
												If lGT700BXT
								
													ExecBlock("GT700BXT",.F.,.F.)
								
												Endif
												
												cFilAnt := cFilAtu
												CONFIRMSX8()

												DbSelectArea("G6Y")
												G6Y->(DbGoTo((cAliasQry6)->RECNOG6Y ))
												
												RecLock("G6Y", .F.)
												
													G6Y->G6Y_CHVTIT := cTitChave
												
												G6Y->(MsUnlock())
												
											Endif
										Else
											lRet := .F.
											cMsgTit := STR0083 + cTitChave  + CRLF//"Não encontrado título do depósito da ficha de remessa."
											DisarmTransaction()				
											
										EndIf	
												
									Endif
								Else
									lRet := .F.
									cMsgTit := STR0080  + CRLF//"Não foi informado o cliente no cadastro de Agencia "
									DisarmTransaction()
								Endif
								
				
							Endif
							
						Endif
					Else
						SE1->(DbSetOrder(1))
						If !Empty((cAliasQry6)->G6Y_CHVTIT) .AND. SE1->(DbSeek((cAliasQry6)->G6Y_CHVTIT+GI6->GI6_CLIENT+GI6->GI6_LJCLI)) .AND. Empty(SE1->E1_BAIXA)
								cFilAnt := SE1->E1_FILORIG	
								aArray 	:= {}	
								aArray := {		{ "E1_FILIAL"		, SE1->E1_FILIAL		            , Nil },; //Prefixo
												{ "E1_PREFIXO"		, SE1->E1_PREFIXO		            , Nil },; //Prefixo 
												{ "E1_NUM"		, SE1->E1_NUM  					    , Nil },; //Numero
												{ "E1_PARCELA"	, SE1->E1_PARCELA				    , Nil },; //Parcela
												{ "E1_TIPO"		, SE1->E1_TIPO					    , Nil },; //Tipo
												{ "E1_NATUREZ"	, SE1->E1_NATUREZ			        , Nil },; //Natureza
												{ "E1_CLIENTE"	, SE1->E1_CLIENTE				    , Nil },; //Cliente
												{ "E1_LOJA"		, SE1->E1_LOJA			 		    , Nil },; //Loja
												{ "E1_EMISSAO"	, SE1->E1_EMISSAO		         	, Nil },; //Data Emissão
												{ "E1_VENCTO"	, SE1->E1_VENCTO				    , Nil },; //Data Vencimento
												{ "E1_VENCREA"	, SE1->E1_VENCREA				    , Nil },; //Data Vencimento Real
												{ "E1_VALOR"	, SE1->E1_VALOR				        , Nil },; //Valor
												{ "E1_SALDO"	, SE1->E1_SALDO					    , Nil },; //Saldo
												{ "E1_HIST"		, SE1->E1_HIST						, Nil },; //HIstórico
												{ "E1_ORIGEM"	, "GTPA700"						, Nil }}  //Origem
													
								MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 5)  // Exclui o título
								
								If lMsErroAuto
									lRet := .F.
									cMsgTit := MostraErro(cPath,cFile) + CRLF
									cFilAnt := cFilAtu										
									DisarmTransaction()
								Else
									lRet := .T.
									
								EndIf
							Else
								lRet:= .T.					
							EndIf			    
					Endif 
					(cAliasQry6)->(dbSkip())  	
				End      		
			Endif
		Endif

		If lRet 
			lRet := GerTitTerc((cAliasQry1)->G6X_AGENCI, (cAliasQry1)->G6X_NUMFCH)

			If !(lRet)
				cFilAnt := cFilAtu										
				DisarmTransaction()
			Endif

		Endif 

	    If Select(cAliasQry6) > 0
			(cAliasQry6)->(dbCloseArea())
		Endif 
	    
		(cAliasQry1)->(dbSkip())
	End
Else
	lRet := .F.
	cMsgTit := STR0084 + CRLF//"Não encontrado fichas para o fechamento, contate o TI para verificar o status da ficha na tesouraria."
	DisarmTransaction()
Endif

cFilAnt := cFilAtu

End Transaction

cFilAnt := cFilAtu

/*If lRet
// gera os titulos de POS e titulos de Despesas e receitas
	StartJob("JOB700FE",GetEnvServer(),.F.,cEmpAnt,cFilAnt,G6T->G6T_CODIGO,G6T->G6T_AGENCI)	
Endif*/

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} T700HCalc()

Função responsável pela calculo da ficha de remessa
 
@sample	T700HCalc()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		01/11/2017
@version	P12
/*/
Function T700HCalc(oModel)

Local nTotSald	:= nValorSld 

Return nTotSald


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G700GetObj(nTp)
 
@sample	
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		01/11/2017
@version	P12
/*/
Function G700GetObj(nTp)
Local oBj	:= Nil
If nTp == 1
	oBj	:= oWidget
Else
	oBj	:= oMBrowse
Endif
Return oBj

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPPROCREAB()

Função responsável pela Reabertura.
 
@sample	GTPPROCREAB()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		01/11/2017
@version	P12
/*/

Function GTPPROCREAB(oGridG6X,cMsgTit)
Local cAliasG6Y := GetNextAlias()
Local cAliasPOS := GetNextAlias()
Local cTitChave := oGridG6X:GetValue('G6X_TITCX')
Local cTpSlCx	:= oGridG6X:GetValue('G6X_TPSLCX')
Local cAgencia	:= oGridG6X:GetValue('G6X_AGENCI')
Local cNumFch	:= oGridG6X:GetValue('G6X_NUMFCH')
Local cCodCx	:= G6T->G6T_CODIGO
Local aTitSE2   := {}
Local aTitSE1   := {}
Local aDadosG6X	:= {}
Local lRet      := .T.
Local cPath     := GetSrvProfString("Rootpath","")
Local cFile     := ""
Local cFilAtual	:= cFilAnt
Local cFilAge	:= Posicione('GI6',1,xFilial("GI6")+ G6T->G6T_AGENCI,"GI6_FILRES")
Local nContPos	:= 0
Local lBanco	:= (Trim(TcGetDb()) == 'POSTGRES') .or. (Trim(TcGetDb()) == 'ORACLE')
Local cExp		:= "%%"

If lBanco
	cExp := "%SE1.E1_FILIAL || SE1.E1_PREFIXO || SE1.E1_NUM || SE1.E1_PARCELA || SE1.E1_TIPO || SE1.E1_CLIENTE || SE1.E1_LOJA = G6Y_CHVTIT%"
Else
	cExp := "%SE1.E1_FILIAL + SE1.E1_PREFIXO + SE1.E1_NUM + SE1.E1_PARCELA + SE1.E1_TIPO + SE1.E1_CLIENTE + SE1.E1_LOJA = G6Y_CHVTIT%"
EndIf

Private lMsErroAuto := .F.

	GI6->(DbSetOrder(1))
	GI6->(DbSeek(xFilial("GI6")+ G6T->G6T_AGENCI))
	
	BeginSQL Alias cAliasPOS
			
		SELECT Count(G6Y.R_E_C_N_O_) AS CONTPOS
		FROM %Table:G6Y% G6Y
		INNER JOIN %Table:G6X% G6X 
			ON G6X.G6X_FILIAL = G6Y.G6Y_FILIAL
		   	AND G6X.G6X_AGENCI = G6Y.G6Y_CODAGE
		   	AND G6X.G6X_CODCX = G6Y.G6Y_CODIGO
		   	AND G6X.G6X_STATUS = '3'
		   	AND G6X.%NotDel%
		INNER JOIN %Table:SE1% SE1 ON 
		   %Exp:cExp%
		   AND SE1.E1_CLIENTE = %Exp:GI6->GI6_CLIENT%  
		   AND SE1.E1_LOJA = %Exp:GI6->GI6_LJCLI%  		   
		   AND SE1.E1_SALDO <> SE1.E1_VALOR
		   AND SE1.%NotDel%  
		WHERE 
		   G6Y_FILIAL = %xFilial:G6Y%
		   AND G6Y_TPLANC = '6' 
		   AND G6Y_TPVEND = 'P'
		   AND G6Y_CHVTIT <> ' ' 
		   AND G6Y.G6Y_CODIGO = %Exp:G6T->G6T_CODIGO%
		   AND G6Y.G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
		   AND G6Y.%NotDel%
		
	EndSQL
	
	nContPos	:= (cAliasPOS)->CONTPOS
	
	If Select(cAliasPOS) > 0
		(cAliasPOS)->(dbCloseArea())
	Endif 
	
	If nContPos > 0
		cMsgTit := STR0085 + oGridG6X:GetValue('G6X_NUMFCH') + STR0086//"Há titulos de Pos baixado para essa ficha:"#" Cancele a baixa do titulo de Pos primeiro."
		Return .F.
	Endif
	
	
	Begin Transaction  

		If G6X->(FieldPos('G6X_TITPRO')) > 0 .And. oGridG6X:GetValue('G6X_TITPRO') == '2' 

			If !(PrcReabSld(cCodCx, cAgencia, cNumFch, @cMsgTit))
				lRet := .F.
				DisarmTransaction()
			Endif

		Else

			//-------------------------------------------------------------------//
			// Verifica se há lançamentos no Contas a Pagar para Estornar (SE2)  //
			//-------------------------------------------------------------------//
			cFilAnt	:= cFilAge
			
			//Função responsavel pelo estorno da baixa no momento da reabertura da ficha
			If !EstBaixaGZK(oGridG6X:GetValue('G6X_AGENCI'),G6T->G6T_CODIGO,oGridG6X:GetValue('G6X_NUMFCH'),@cMsgTit)
				lRet := .F.
				DisarmTransaction()
				Break
			Endif
			
				
			If Alltrim(cTpSlCx) =='CR' .And. !Empty(cTitChave)
				//-------------------------------------------------------------------//
				// Verifica se há lançamentos no Contas a Receber para Excluir (SE1) //
				// pois neste caso, o Saldo é positivo. Implica que a agência tem    //
				// saldo a Receber.                                                  //
				//-------------------------------------------------------------------//
				If lRet
					lMsErroAuto := .F.
						
					DbSelectArea("SE1")
					SE1->(DbSetOrder(1))
					If SE1->(DbSeek(cTitChave))
						cFilAnt := SE1->E1_FILORIG	
						aTitSE1 := {	{ "E1_FILIAL"	, SE1->E1_FILIAL		            , Nil },; //Prefixo
										{ "E1_PREFIXO"	, SE1->E1_PREFIXO		            , Nil },; //Prefixo 
										{ "E1_NUM"		, SE1->E1_NUM  					    , Nil },; //Numero
										{ "E1_PARCELA"	, SE1->E1_PARCELA				    , Nil },; //Parcela
										{ "E1_TIPO"		, SE1->E1_TIPO					    , Nil },; //Tipo
										{ "E1_NATUREZ"	, SE1->E1_NATUREZ			        , Nil },; //Natureza
										{ "E1_CLIENTE"	, SE1->E1_CLIENTE				    , Nil },; //Cliente
										{ "E1_LOJA"		, SE1->E1_LOJA			 		    , Nil },; //Loja
										{ "E1_EMISSAO"	, SE1->E1_EMISSAO		         	, Nil },; //Data Emissão
										{ "E1_VENCTO"	, SE1->E1_VENCTO				    , Nil },; //Data Vencimento
										{ "E1_VENCREA"	, SE1->E1_VENCREA				    , Nil },; //Data Vencimento Real
										{ "E1_VALOR"	, SE1->E1_VALOR				        , Nil },; //Valor
										{ "E1_SALDO"	, SE1->E1_SALDO					    , Nil },; //Saldo
										{ "E1_HIST"		, SE1->E1_HIST						, Nil },; //HIstórico
										{ "E1_ORIGEM"	, "GTPA700"						, Nil }}  //Origem
											
						MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 5)  // Exclui o título
						
						If lMsErroAuto
							lRet := .F.
							cMsgTit := MostraErro(cPath,cFile) + CRLF	
							DisarmTransaction()
						Else
							lRet := .T.
							CONFIRMSX8()
						EndIf
						
						cFilAnt := cFilAtual									
						
					Else
						lRet:= .F.
						cMsgTit := STR0087  + CRLF//"Título não encontrado no contas a receber"
						DisarmTransaction()
					EndIf
						
				EndIf
			ElseIf Alltrim(cTpSlCx) =='CP' .And. !Empty(cTitChave)
				
				//-------------------------------------------------------------------//
				// Verifica se há lançamentos no Contas a Pagar para Excluir (SE2)   //
				// pois neste caso, o Saldo é negativo. Implica que a agência tem    //
				// saldo a Pagar.                                                  //
				//-------------------------------------------------------------------//
				lMsErroAuto := .F.
							
				DbSelectArea("SE2")
				SE2->(DbSetOrder(1))
				If SE2->(DbSeek(cTitChave)) 
					cfilAnt:= SE2->E2_FILORIG	
					aTitSE2 := {	{ "E2_FILIAL"	, SE2->E2_FILIAL			        , Nil },; //Prefixo
									{ "E2_PREFIXO"	, SE2->E2_PREFIXO		            , Nil },; //Prefixo 
									{ "E2_NUM"		, SE2->E2_NUM  					    , Nil },; //Numero
									{ "E2_PARCELA"	, SE2->E2_PARCELA				    , Nil },; //Parcela
									{ "E2_TIPO"		, SE2->E2_TIPO					    , Nil },; //Tipo
									{ "E2_NATUREZ"	, SE2->E2_NATUREZ			        , Nil },; //Natureza
									{ "E2_FORNECE"	, SE2->E2_FORNECE				    , Nil },; //Cliente
									{ "E2_LOJA"		, SE2->E2_LOJA			 		    , Nil },; //Loja
									{ "E2_EMISSAO"	, SE2->E2_EMISSAO		         	, Nil },; //Data Emissão
									{ "E2_VENCTO"	, SE2->E2_VENCTO				    , Nil },; //Data Vencimento
									{ "E2_VENCREA"	, SE2->E2_VENCREA				    , Nil },; //Data Vencimento Real
									{ "E2_VALOR"	, SE2->E2_VALOR				        , Nil },; //Valor
									{ "E2_SALDO"	, SE2->E2_SALDO					    , Nil },; //Saldo
									{ "E2_HIST"		, SE2->E2_HIST						, Nil },; //HIstórico
									{ "E2_ORIGEM"	, "GTPA700A"							, Nil }}  //Origem
									
					MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aTitSE2,, 5) // Exclui o título
								
					If lMsErroAuto
						lRet := .F.
						cMsgTit := MostraErro(cPath,cFile) + CRLF	
						DisarmTransaction()
					Else
						lRet := .T.
						CONFIRMSX8()
					EndIf
					
					cFilAnt := cFilAtual									
					
				Else
					lRet:= .F.
					cMsgTit := STR0088  + CRLF//"Título não encontrado no contas a pagar"
					DisarmTransaction()
				
				EndIf
			EndIf
				
			If lRet 
				G6X->(DbSetOrder(3))
				If G6X->(DbSeek(xFilial("G6X")+G6T->G6T_AGENCI+oGridG6X:GetValue('G6X_NUMFCH')))
					//TODO
					// Deleta o titulo da ficha 
					lMsErroAuto := .F.
					
					If (G6X->(FieldPos('G6X_DEPOSI')) > 0 .And. G6X->G6X_DEPOSI != '3') .Or. G6X->(FieldPos('G6X_DEPOSI')) == 0

						lRet := A421GerTitRec() // Regrava o título PRV original gerado pela ficha de remessa
						
						cTitChave := G6X->G6X_NUMTIT
					
						BeginSQL Alias cAliasG6Y
					
							SELECT G6Y_CODAGE, G6Y_NUMFCH,G6Y_VALOR,G6Y_DATA G6Y_BANCO,G6Y_AGEBCO,
							G6Y_CTABCO,G6Y_CHVTIT,G6Y_STSDEP, G6Y.R_E_C_N_O_ AS RECNOG6Y
							FROM %Table:G6Y% G6Y
							WHERE 
							G6Y_FILIAL = %xFilial:G6Y%
							AND G6Y_NUMFCH = %Exp:G6X->G6X_NUMFCH%
							AND G6Y_TPLANC = '2' 
							//AND G6Y_STSDEP = '1' 
							AND G6Y_CODIGO = %Exp:G6T->G6T_CODIGO%
							AND G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
							AND %NotDel%
							
						EndSQL
						
						While (cAliasG6Y)->(!Eof() .AND. lRet)
											
							If (cAliasG6Y)->G6Y_STSDEP == '1'
								
								SE1->(DbSetOrder(1))
								If SE1->(DbSeek((cAliasG6Y)->G6Y_CHVTIT+GI6->GI6_CLIENT+GI6->GI6_LJCLI))
									If !Empty(SE1->E1_BAIXA)
										cFilAnt := 	SE1->E1_FILORIG
										aTitSE1	:= {{"E1_FILIAL"	, SE1->E1_FILIAL 		,Nil},;
													{"E1_PREFIXO"	, SE1->E1_PREFIXO 		,Nil},;
													{"E1_NUM"		, SE1->E1_NUM       	,Nil},;
													{"E1_PARCELA"	, SE1->E1_PARCELA  		,Nil},;
													{"E1_TIPO"	    , SE1->E1_TIPO     		,Nil},;
													{"E1_CLIENTE"   , SE1->E1_CLIENTE      	,Nil},;
													{"E1_LOJA"		, SE1->E1_LOJA			,Nil},;
													{"AUTHIST"	    , STR0126 + G6X->G6X_NUMFCH ,Nil}} // "Reabertura da ficha: "
							
										MSExecAuto({|x,y| Fina070(x,y)},aTitSE1,6) // Exclui a baixa do título
															
																
										If lMsErroAuto
											lRet := .F.
											cMsgTit := MostraErro(cPath,cFile) + CRLF										
											DisarmTransaction()
										Else
											
											lMsErroAuto := .F.
								
											SE1->(DbSetOrder(1))
											If SE1->(DbSeek((cAliasG6Y)->G6Y_CHVTIT+GI6->GI6_CLIENT+GI6->GI6_LJCLI))
												cFilAnt := SE1->E1_FILORIG	
												aTitSE1	:= {}
												aTitSE1 := {	{ "E1_FILIAL"	, SE1->E1_FILIAL		            , Nil },; //Prefixo
																{ "E1_PREFIXO"	, SE1->E1_PREFIXO		            , Nil },; //Prefixo 
																{ "E1_NUM"		, SE1->E1_NUM  					    , Nil },; //Numero
																{ "E1_PARCELA"	, SE1->E1_PARCELA				    , Nil },; //Parcela
																{ "E1_TIPO"		, SE1->E1_TIPO					    , Nil },; //Tipo
																{ "E1_NATUREZ"	, SE1->E1_NATUREZ			        , Nil },; //Natureza
																{ "E1_CLIENTE"	, SE1->E1_CLIENTE				    , Nil },; //Cliente
																{ "E1_LOJA"		, SE1->E1_LOJA			 		    , Nil },; //Loja
																{ "E1_EMISSAO"	, SE1->E1_EMISSAO		         	, Nil },; //Data Emissão
																{ "E1_VENCTO"	, SE1->E1_VENCTO				    , Nil },; //Data Vencimento
																{ "E1_VENCREA"	, SE1->E1_VENCREA				    , Nil },; //Data Vencimento Real
																{ "E1_VALOR"	, SE1->E1_VALOR				        , Nil },; //Valor
																{ "E1_SALDO"	, SE1->E1_SALDO					    , Nil },; //Saldo
																{ "E1_HIST"		, SE1->E1_HIST						, Nil },; //HIstórico
																{ "E1_ORIGEM"	, "GTPA700"						, Nil }}  //Origem
																	
												MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 5)  // Exclui o título
												
												If lMsErroAuto
													lRet := .F.
													cMsgTit := MostraErro(cPath,cFile) + CRLF	
													DisarmTransaction()
												Else
													lRet := .T.
													CONFIRMSX8()
												EndIf
												
												cFilAnt := cFilAtual									
												
											Else
												lRet:= .F.
												cMsgTit := STR0089  + CRLF//"Título provisório não encontrado no contas a receber"
												DisarmTransaction()
											EndIf
																			
											If lRet
												cFilAnt := cFilAtual
			
												DbSelectArea("G6Y")
												G6Y->(DbGoTo((cAliasG6Y)->RECNOG6Y ))
												
												RecLock("G6Y", .F.)
														
													G6Y->G6Y_CHVTIT := cTitChave
														
												G6Y->(MsUnlock())
												
											Endif	
											
										EndIf
										
										cFilAnt := cFilAtual
										
									Else
										lRet := .T.
									Endif
									
									cFilAnt := cFilAtual
									
								Else
									lRet:= .F.
									cMsgTit := STR0087  + CRLF//"Título não encontrado no contas a receber"
									DisarmTransaction()
								EndIf
								
							Else
							
								DbSelectArea("G6Y")
								G6Y->(DbGoTo((cAliasG6Y)->RECNOG6Y ))
												
								RecLock("G6Y", .F.)
														
									G6Y->G6Y_CHVTIT := cTitChave
														
									G6Y->(MsUnlock())
							
							Endif

							(cAliasG6Y)->(DbSkip())
						End
						
						If Select(cAliasG6Y) > 0
							(cAliasG6Y)->(dbCloseArea())
						Endif
												
					Endif

					If lRet	
						cFilAnt := 	cFilAtual
						// Atualiza o status G6X 
						aDadosG6X := {}
						aAdd( aDadosG6X,	{ "G6X_RECCX"  , 0	} )
						aAdd( aDadosG6X,	{ "G6X_DESCX"  , 0	} )
						aAdd( aDadosG6X,	{ "G6X_SLDCX"  , 0 } )
						aAdd( aDadosG6X,	{ "G6X_TPSLCX" , "  "	} )
						aAdd( aDadosG6X,	{ "G6X_STATUS" , "3"	} )
						aAdd( aDadosG6X,	{ "G6X_TITCX"  , '  '	} )
						aAdd( aDadosG6X,	{ "G6X_FECHCX"  , .F.	} )
						aAdd( aDadosG6X,	{ "G6X_DTCAIX"  , CTOD('  /  /  ')	} )
						
						lRet := AtuG6X(aDadosG6X)

						If !(lRet)
							cMsgTit := STR0079 + CRLF//"Erro ao gravar o status na ficha de remessa"
							DisarmTransaction()
						Endif

					Endif

				Else
					lRet := .F.
					cMsgTit := STR0079  + CRLF//"Erro ao gravar o status na ficha de remessa"
					DisarmTransaction()								 	
				Endif

			Endif	
			
			cFilAnt := cFilAtual
		
		Endif

		If lRet

			lRet := EstTitTerc(cAgencia, cNumFch)

			If !(lRet)
				DisarmTransaction()
			Endif

		Endif

	End Transaction
	
	/*If lRet
	// cancela os titulos de POS e titulos de Despesas e receitas
		StartJob("JOB700RE",GetEnvServer(),.F.,cEmpAnt,cFilAnt,G6T->G6T_CODIGO,G6T->G6T_AGENCI)	
	Endif */	
	
	cFilAnt := cFilAtual
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} DelGZK()

Função responsável pela calculo da ficha de remessa
 
@sample	DelGZK()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		02/12/2017
@version	P12
/*/

Static Function DelGZK()

Local oModelGZK	:= FWLOADModel('GTPA700H')
Local oMdlTIT
Local lRet := .T.

oModelGZK:SetOperation(MODEL_OPERATION_DELETE)
oModelGZK:Activate()
oMdlTIT	:= oModelGZK:GetModel("TITDETAIL")

GZK->(DbSetOrder(1))
 
If GZK->( DbSeek(xFilial("GZK") + G6T->G6T_CODIGO  ) )
	if oModelGZK:IsActive() 
		If oModelGZK:VldData()
			lRet :=  oModelGZK:CommitData()
		Else
			JurShowErro( oModelGZK:GetErrorMessage() )
			DisarmTransaction()
			lRet := .F.
		EndIf
	
	EndIf   	
	
EndIf
Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTotCx()

Retorna os totais  do período de fechamento.
 
@sample	GetNumFch()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		02/03/2018
@version	P12
/*/

Static Function GetTotCx()

Local cAliasCx := GetNextAlias()
Local aTotCx 	:= {}

BeginSQL Alias cAliasCx
				
	SELECT SUM(G6X_RECCX) RECEITAS ,  SUM(G6X_DESCX) DESPESAS,  SUM(G6X_SLDCX) SALDO
	FROM %Table:G6X% G6X
	WHERE G6X_FILIAL = %xFilial:G6X%
	AND G6X_CODCX = %Exp:G6T->G6T_CODIGO%
	AND %NotDel%
				
EndSQL
		
(cAliasCx)->(DbGoTop())

If (cAliasCx)->(!Eof())
	AADD(aTotCx, {(cAliasCx)->RECEITAS,(cAliasCx)->DESPESAS,(cAliasCx)->SALDO })
	(cAliasCx)->(DbSkip())
EndIf

(cAliasCx)->(dbCloseArea())

Return aTotCx

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuG6X(aDadosG6X)

Atualiza dados do caixa na ficha de remessa
 
@sample	AtuG6X(aDadosG6X)
 
@return	lógico
 
@author	SIGAGTP 
@since		
@version	P12
/*/
Function AtuG6X(aDadosG6X)
Local lRet			:= .T.
Local nI			:= 0

If RecLock("G6X", .F.)
	
	For nI := 1 to Len(aDadosG6X)
	
	  	G6X->&(aDadosG6X[nI][1]) := aDadosG6X[nI][2]
	
	Next nI
	
	G6X->(MsUnlock())
Else

	lRet := .F.

Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldPos700(oMdl)
Verifica se pode executar a reabertura da ficha.

 
@sample	GTPA700()
 
@return	
 
@author	SIGAGTP | Fernando Amorim (Cafu)
@since		31/03/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function DelFFch(oMdl)
			
Local oGridG6X  := oMdl:GetModel("GRIDG6X")
Local lRet     	:= .T.
Local nI		:= 0
Local cVCaixa	:= GTP700GVisao()
Local cMsgTit	:= ""
Local lCxReab	:= .F.
Local cMsgRet	:= ''

	If Alltrim(cVCaixa) == 'Caixa Reaberto' .AND. !FwIsInCallStack("GTFECHACX")
		For nI := 1 to Len(aDFFch) 
			oGridG6X:GoLine(aDFFch[nI])
			If  !oGridG6X:GetValue("G6X_FECHCX") .AND. oGridG6X:GetValue("G6X_FLAGCX") .AND. lRet
						
				FwMsgRun(,{|| lRet := GTPPROCREAB(oGridG6X,@cMsgTit) },,STR0090 ) //"Aguarde a Reabertura da ficha."
				lCxReab := .T. 
				If !lRet
					oGridG6X:LoadValue("G6X_FECHCX",.T.)
				Endif
			Else
				IF !(oGridG6X:GetValue("G6X_FECHCX") .AND. oGridG6X:GetValue("G6X_FLAGCX"))
					FwMsgRun(,{|| lRet := GTPPROCREAB(oGridG6X,@cMsgTit) },,STR0090 ) //"Aguarde a Reabertura da ficha."
					lCxReab := .T.
				ELSE
					If !lCxReab
						lRet :=  .T.
					Endif
				ENDIF
			EndIf
		
		Next nY
		//TODO
		If lCxReab
			If lRet	
				cMsgRet	:=  STR0091//"Reabertura das fichas efetuadas com sucesso"
				Aviso(STR0092, cMsgRet, {STR0093}, 2)	//"Reabre Caixa"#"Ok"
				aDFFch := {}	
			Else
			//TODO
				lRet := .F.
				cMsgRet	:= STR0094 + CRLF + cMsgTit//"Houve erro na Reabertura da ficha, contate o TI"
				Aviso(STR0041, cMsgRet, {'OK'}, 2) // "Fecha Caixa", //Houve erro no Fechamento do caixa, contate o TI
				oMdl:getmodel():SetErrorMessage(oMdl:getmodel():getid(),'',oMdl:getmodel():getid(),'',"VLDPOS700",STR0095,cMsgRet)//"REABERTURA FICHA"
			Endif
		Endif
	Else
		lRet := .T.
	EndIf
	
Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldFlagCx(oMdlG6X, cField, cNewValue, cOldValue)
 
 Realiza validações na seleção das fichas de remessa do caixa
 
@sample	GTPA700()
 
@return	Lógico
 
@author	SIGAGTP 
@since		
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function VldFlagCx(oMdlG6X, cField, cNewValue, cOldValue)
Local lRet       := .T.
Local cCodCx     := oMdlG6X:GetValue('G6X_CODCX')
Local cFicha     := oMdlG6X:GetValue('G6X_NUMFCH')
Local cAliasG6Y  := GetNextAlias()
Local cStatus    := oMdlG6X:GetValue('G6X_STATUS')
Local nPos       := 0

	If cField == "G6X_FLAGCX"
	
		If !cNewValue
		
				If ValType(aDelFch) <> "A"
					aDelFch := {}
				Endif
				
				BeginSql Alias cAliasG6Y
				
					SELECT G6Y.G6Y_CODIGO 
					FROM %Table:G6Y% G6Y
					WHERE
					G6Y.G6Y_FILIAL = %xFilial:G6Y%
					AND G6Y.%NotDel%
					AND G6Y.G6Y_CODIGO = %Exp:cCodCx%
				
				EndSql
	 
	 			If (cAliasG6Y)->(ScopeCount()) > 0 
	 			
	 				If MsgYesNo(STR0096)//"Existem lançamentos de tesouraria para esta ficha. Prosseguir com a reabertura irá excluir estes lançamentos. Deseja continuar ?"
	 			
	 					Aadd(aDelFch, cFicha)
	 					
	 					nPos := aScan(aIncFch, cFicha)
	 					
	 					If nPos > 0
	 					
	 						aDel(aIncFch, nPos)
	 						aSize(aIncFch, Len(aIncFch)-1)
	 					
	 					Endif
	 					
	 				Else
	 					lRet := .F.
	 					oMdlG6X:getmodel():SetErrorMessage(oMdlG6X:getmodel():getid(),'',oMdlG6X:getmodel():getid(),'',STR0097,STR0098,STR0099)//"Ficha Caixa"#"Lançamentos do caixa."#"Não serão apagados os lançamentos."
	 				Endif
	 				 			
	 			Endif
	 
		Else
		
			nPos := aScan(aDelFch, cFicha)
			
			If nPos > 0
			
				aDel(aDelFch, nPos)
				aSize(aDelFch, Len(aDelFch)-1)
					
			Endif	
			
			nPos := aScan(aIncFch, cFicha)
			
			If nPos == 0

				If G6X->(FieldPos('G6X_TITPRO')) > 0  
					lRet := VldTpFicha(oMdlG6X)
				Endif

				If lRet
					If ValType(aIncFch) <> "A"
						aIncFch := {}
					Endif
					Aadd(aIncFch, cFicha)
				Else
					oMdlG6X:getmodel():SetErrorMessage(oMdlG6X:getmodel():getid(),'',oMdlG6X:getmodel():getid(),'',STR0097,"VldFlagCx.","Caixa não pode conter fichas com diferentes tipos de ficha")//"Ficha Caixa"#
				Endif
				
			Endif
			
		Endif
		
	ElseIf cField == "G6X_FECHCX"
		
		If cStatus == '3'
			lRet := .F.
			oMdlG6X:getmodel():SetErrorMessage(oMdlG6X:getmodel():getid(),'',oMdlG6X:getmodel():getid(),'',STR0097,"VldFlagCx.",STR0100)//"Ficha Caixa"#"Esta ação apenas pode ser realizada pela rotina de Fechamento de Caixa."
		Endif

		If lRet 
			If !cNewValue
		 		If	MsgYesNo(STR0101)//"Este procedimento irá reabrir a ficha. Deseja continuar ?"
		 			Aadd(aDFFch, oMdlG6X:GetLine())
		 		Else
		 			lRet := .F.
		 			oMdlG6X:getmodel():SetErrorMessage(oMdlG6X:getmodel():getid(),'',oMdlG6X:getmodel():getid(),'',STR0097,STR0102,STR0103)//"Ficha Caixa"#"Reabertura."#"Não será reaberta a ficha."
		 		Endif
		 	Endif
	 	Endif
	Endif
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA700Commit(oModel)
 
Commit do modelo
 
@sample	GTPA700()
 
@return	Lógico
 
@author	SIGAGTP 
@since		
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA700Commit(oModel)
Local lRet 		:= .T.

	If ValType(aDelFch) <> "A"
		aDelFch := {}
	Endif
	
	If ValType(aIncFch) <> "A"
		aIncFch := {}
	Endif
	
	Begin Transaction

		If Len(aDelFch) > 0
		
			lRet := G700TitPrv(oModel)
		
			If lRet
				lRet := DelLancFch(oModel)
			Endif
			
		Endif
			
		If lRet
		
			lRet := FwFormCommit(oModel)
			
			If lRet .And. Len(aIncFch) > 0
				
				FWMsgRun(, { ||  G700LoadMov() }, STR0013, STR0112)	// "Aguarde",  "Carregando movimentos..."
				
				GTPDestroy(aIncFch)

			
			Endif
			
		Else
		
			DisarmTransaction()
			lRet := .F.
			BREAK
			
		Endif 
		
		If lRet .and. Len(aDFFch) > 0
			lRet := DelFFch( oModel )
		EndIf
		
	End Transaction

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} DelLancFch(oModel)
 
Exclui o movimento de fichas retiradas do caixa
 
@sample	GTPA700()
 
@return	Lógico
 
@author	SIGAGTP 
@since		
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function DelLancFch(oModel)
Local lRet 		:= .T.
Local nX			:= 0
Local nI			:= 0
Local cCodG6T 	:= oModel:GetModel("FIELDG6T"):GetValue("G6T_CODIGO")
Local oMdl700X
Local oMdlG6Y
Local cFicha		:= ''
Local aFilterG6Y	:= {}

	oMdl700X := FwLoadModel("GTPA700X")
	
	dbSelectArea("G6Y")
	G6Y->(DbSetOrder(5))
	If ValType(aDelFch) <> "A"
		aDelFch := {}
	Endif
	For nI := 1 To Len(aDelFch)
	
		cFicha := aDelFch[nI]
		
		If G6Y->(dbSeek(xFilial("G6Y")+cCodG6T+aDelFch[nI]))
			
			oMdl700X:SetOperation(MODEL_OPERATION_DELETE)
			aFilterG6Y:= {}
			aAdd(aFilterG6Y,{ 'G6Y_CODIGO', "'"+PADR(cCodG6T,TAMSX3("G6Y_CODIGO")[1])+"'" })
			aAdd(aFilterG6Y,{ 'G6Y_NUMFCH', "'"+PADR(aDelFch[nI],TAMSX3("G6Y_NUMFCH")[1])+"'" })
			oMdlG6Y	:= oMdl700X:GetModel("G6YDETAIL")
			oMdlG6Y:SetLoadFilter(aFilterG6Y )
			oMdl700X:Activate()
			
			For nX := 0 To oMdlG6Y:Length()
			
				FwFormCommit(oMdl700X)
			
			Next nX	
					
			FwFormCommit(oModel)
			
		Endif
		
		oMdl700X:DeActivate()
	
	Next nI
	
	oMdl700X:Destroy()
	GTPDestroy(aDelFch)
		
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA700MNT()
 
Chamada da View de manutenção do caixa.
 
@sample	GTPA700()
 
@return	
 
@author	SIGAGTP 
@since		
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA700MNT()
Local nOpc	:= 0

	If G6T->G6T_STATUS $ '1|3'
		nOpc := 4 // Alterar
	Else
		nOpc := 4 // Visualizar
	Endif
	
	FWExecView(STR0104,"VIEWDEF.GTPA700", nOpc,,{|| .T.}) // "Manutenção"
	
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TrigFlagCx(oMdlG6X)
Gatilho para atualizar o código do caixa na ficha de remessa
 
@sample	GTPA700()
 
@return	
 
@author	SIGAGTP | Flavio Martins
@since		12/09/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function TrigFlagCx(oMdlG6X)
Local bFlagCx	:= oMdlG6X:GetValue('G6X_FLAGCX')

	If bFlagCx
		oMdlG6X:SetValue("G6X_CODCX", G6T->G6T_CODIGO)	
	Else
		oMdlG6X:SetValue("G6X_CODCX", '')	
	Endif

Return 

/*/{Protheus.doc} EstBaixaGZK
Função responsavel pelo estorno da baixa no momento da reabertura da ficha
@type function
@author jacomo.fernandes
@since 01/10/2018
@version 1.0
@param cAgencia, character, Código da Agencia 
@param cCaixa, character, Código do Caixa
@param cNumFch, character, Número da Ficha
@param cMsgTit, character, Variavel passada por referencia para retorno de erro
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function EstBaixaGZK(cAgencia,cCaixa,cNumFch,cMsgTit)
Local lRet		:= .T.
Local cAliasGZK := GetNextAlias()
Local nOpbaixa	:= 0
Local cNatTit	:= GTPGetRules('NATUPAG')
Local cChave	:= ""
Local aTitSE2	:= {}
Local cPath     := GetSrvProfString("Rootpath","")
Local cFile     := ""

Private aBaixaSE5	:= {} //Necessário para a função Sel080Baixa
	
	//Busca todas as compensações realizadas para um determinado Caixa x Ficha de remessa 
	BeginSQL Alias cAliasGZK
		SELECT
			GZK.R_E_C_N_O_ AS GZKRECNO
		FROM %Table:GZK% GZK 
		WHERE 
			GZK.GZK_FILIAL		= %xFilial:GZK%
			AND GZK.GZK_AGENCI	= %Exp:cAgencia% 		
			AND GZK.GZK_CAIXA	= %Exp:cCaixa%		            
			AND GZK.GZK_FICHA	= %Exp:cNumFch% 
			AND GZK.%NotDel%
		ORDER BY GZK_FILIAL,GZK_CAIXA,GZK_FICHA
	EndSQL
	
	//Para cada compensação, é realizado o extorno da baixa
	While (cAliasGZK)->(!Eof())
		
		GZK->(DbGoTo((cAliasGZK)->GZKRECNO)) //Posiciona na compensação para iniciar o processo do cancelamento da baixa
		
		aBaixaSE5	:= {} //Varial Private utilizada na rotina Sel080Baixa
		
		//Função responsavel para o preenchimento da varial aBaixaSE5
		//Essa função busca todas as baixas "em aberto", é necessário para buscar exatamente qual baixa do titulo devemos estornar 
		Sel080Baixa("VL /BA /CP /",GZK->GZK_PREFIX,GZK->GZK_NUMTIT,GZK->GZK_PARCEL,GZK->GZK_TIPO,0,0,GZK->GZK_FORNEC,GZK->GZK_LOJA,.F.,.F.,.F.,0,.F.,.T.)
		
		aSort(aBaixaSE5,,, {|x,y| x[9] < y[9] } ) //Ordena por sequencia
		
		//Procura em qual posição da baixa se encontra a compensação para estorna-la
		nOpbaixa := aScan(aBaixaSE5, {|x|;
										x[01] == GZK->GZK_PREFIX		;    //Prefixo           
										.and. x[02] == GZK->GZK_NUMTIT	;    //Numero            
										.and. x[03] == GZK->GZK_PARCEL	;    //Parcela           
										.and. x[04] == GZK->GZK_TIPO	;    //Tipo              
										.and. x[05] == GZK->GZK_FORNEC	;    //Cliente/Fornec    
										.and. x[06] == GZK->GZK_LOJA	;    //Loja              
										.and. x[09] == GZK->GZK_SEQ		;    //Sequencia         
									})

		If nOpbaixa > 0 //Caso maior que 0, inicia o processo de cancelamento da baixa e informa qual a baixa irá estornar
			cChave := GZK->GZK_PREFIX+GZK->GZK_NUMTIT+GZK->GZK_PARCEL+GZK->GZK_TIPO+GZK->GZK_FORNEC+GZK->GZK_LOJA
				
			DbSelectArea("SE2")
			SE2->(DbSetOrder(1))
					
			If !Empty(cNatTit) .And. SE2->(DbSeek(xFilial("SE2")+cChave))
				aTitSE2 := {} 		
				aAdd(aTitSE2,{ "E2_PREFIXO"	, GZK->GZK_PREFIX		    , Nil }) //Prefixo 
				aAdd(aTitSE2,{ "E2_NUM"		, GZK->GZK_NUMTIT		    , Nil }) //Numero
				aAdd(aTitSE2,{ "E2_PARCELA"	, GZK->GZK_PARCEL		    , Nil }) //Parcela
				aAdd(aTitSE2,{ "E2_TIPO"	, GZK->GZK_TIPO			    , Nil }) //Tipo
				aAdd(aTitSE2,{ "E2_NATUREZ"	, cNatTit			        , Nil }) //Natureza
				aAdd(aTitSE2,{ "E2_FORNECE"	, GZK->GZK_FORNEC		    , Nil }) //Cliente
				aAdd(aTitSE2,{ "E2_LOJA"	, GZK->GZK_LOJA 		    , Nil }) //Loja
				aAdd(aTitSE2,{ "E2_VALOR"	, GZK->GZK_VALOR	        , Nil }) //Valor
				aAdd(aTitSE2,{ "E2_SALDO"	, GZK->GZK_VALOR		    , Nil }) //Saldo
				aAdd(aTitSE2,{ "E2_ORIGEM"	, "GTPA700A"				, Nil }) //Origem
				
				MSExecAuto({|x,y,z| fina080(x,y,,z)} , aTitSE2 , 6, nOpbaixa) // Exclui a baixa do título
					
				If !lMsErroAuto
					CONFIRMSX8()
					
					//Realiza a deleção da GZK desse registro
					GZK->(RecLock("GZK",.F.))
					GZK->(DbDelete())
					GZK->(MsUnLock())				
				Else
					lRet := .F.
					cMsgTit := MostraErro(cPath,cFile) + CRLF
					Exit	
				Endif
			
			Endif
		Else
			lRet	:= .F.	
			cMsgTit := STR0105 + CRLF//"Não foi possivel encontrar o titulo compensado:"
			cMsgTit += I18n("Prefixo: #1, Número: #2, Parcela: #3, Tipo: #4, Sequencia: #5",{GZK->GZK_PREFIX,GZK->GZK_NUMTIT,GZK->GZK_PARCEL,GZK->GZK_TIPO,GZK->GZK_SEQ},1,0)+ CRLF
			Exit
		Endif	
		(cAliasGZK)->(DbSkip())
	End
	
	(cAliasGZK)->(DbCloseArea())
	
	GTPDestroy(aBaixaSE5)	
	
Return lRet

/*/{Protheus.doc} JOB700FE
Função responsavel para fazer o job e chamar a rotina para gravar os titulos de POS e receitas e despesas
@type function
@author Fernando Amorim(cafu)
@since 27/11/2018
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function JOB700FE(cEmpX,cFilX,cCaixa,cAgenci)

//Seta job para nao consumir licensas
RpcSetType(3)
RpcClearEnv()
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilX,,,'GTP',,)

G6T->(DbSetOrder(3))
G6T->( DbSeek(xFilial("G6T") + cCaixa  ) )


GTPA700L(.T., 1, cCaixa)

GTPA700M(.T. ,1 ,cCaixa)

Return


/*/{Protheus.doc} JOB700RE
Função responsavel para fazer o job e chamar a rotina para cancelar  os titulos de POS e receitas e despesas
@type function
@author Fernando Amorim(cafu)
@since 27/11/2018
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function JOB700RE(cEmpX,cFilX,cCaixa,cAgenci)

//Seta job para nao consumir licensas
RpcSetType(3)
RpcClearEnv()
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilX,,,'GTP',,)

//Realiza o processamento
G6T->(DbSetOrder(3))
G6T->( DbSeek(xFilial("G6T") + cCaixa  ) )

GTPA700L(.T.,2, cCaixa)

GTPA700M(.T.,2, cCaixa)

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} RetStsGer

@type Static Function
@author 
@since 03/07/2019
@version 1.0
@param cCaixa, character, (Descrição do parâmetro)
@return cStsTit, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function RetStsGer(cCaixa)
Local cStsTit := ''
Local cAliasG6T	:= GetNextAlias()

	BeginSQL Alias cAliasG6T
	
		SELECT  G6T_STSTIT 
		FROM %Table:G6T%
		WHERE G6T_FILIAL = %xFilial:G6T%
		AND G6T_CODIGO = %Exp:cCaixa%
		AND %NotDel%
		
	EndSQL

	If !(cAliasG6T)->(Eof())
	
		cStsTit := (cAliasG6T)->G6T_STSTIT
	
	Endif

	(cAliasG6T)->(dbCloseArea())

Return cStsTit


//------------------------------------------------------------------------------
/*/{Protheus.doc} VldAceite

@type Static Function
@author Flavio Martins
@since 29/07/2019
@version 1.0
@param cCaixa, character, (Descrição do parâmetro)
@return lRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldAceite(cCaixa)
Local lRet 		:= .T.
Local cAliasG6Y	:= GetNextAlias()
Local oGtpLog 	:= GtpLog():New(STR0127) // "Validação do fechamento do Caixa"

	BeginSql Alias cAliasG6Y
	
		SELECT 
            G6Y.G6Y_TPLANC, 
            G6Y.G6Y_CODIGO,
            Count(G6Y_TPLANC) as QTD

		FROM %Table:G6Y% G6Y
		    INNER JOIN %Table:G6T% G6T ON 
                G6T.G6T_FILIAL = G6Y.G6Y_FILIAL
                AND G6T.G6T_CODIGO = G6Y.G6Y_CODIGO
                AND G6T.%NotDel%
		WHERE 
            G6Y.G6Y_FILIAL = %xFilial:G6Y%
            AND G6Y.G6Y_CODIGO = %Exp:cCaixa%
            AND G6Y.G6Y_TPLANC IN ('2','8','9','A')
            AND G6Y.G6Y_STSDEP = ''
            AND G6Y.%NotDel%
        Group By G6Y.G6Y_TPLANC,G6Y.G6Y_CODIGO
	
	EndSql
	
	While (cAliasG6Y)->(!Eof())
	
		If (cAliasG6Y)->G6Y_TPLANC == '2'
		
			oGtpLog:SetText(I18n(STR0120, {(cAliasG6Y)->QTD}) )//"Encontrado #1 depósitos sem conferência"
			 
		ElseIf  (cAliasG6Y)->G6Y_TPLANC == '8'
			
			oGtpLog:SetText(I18n(STR0121, {(cAliasG6Y)->QTD}))  // "Encontrado #1 receitas sem conferência"

		ElseIf  (cAliasG6Y)->G6Y_TPLANC == '9'
			
			oGtpLog:SetText(I18n(STR0122, {(cAliasG6Y)->QTD}))  // "Encontrado #1 despesas sem conferência"
			
		ElseIf  (cAliasG6Y)->G6Y_TPLANC == 'A'
			
			oGtpLog:SetText(I18n(STR0140, {(cAliasG6Y)->QTD}))  // "Encontrado #1 depósitos de terceiros sem conferência"
			
		Endif
		
		(cAliasG6Y)->(dbSkip())
	
	End
	
	If oGtpLog:HasInfo() 
	
		lRet := .F.
		
		oGtpLog:ShowLog()
	
	Endif
	
	(cAliasG6Y)->(dbCloseArea())
	
	oGtpLog:Destroy()

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} G700LoadMov

@type Static Function
@author Flavio Martins
@since 29/07/2019
@version 1.0
@param 
@return lRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function G700LoadMov()
Local lRet := .T.

	GTPA700B()	// Carrega Depósitos
	GTPA700C() 	// Carrega Taxas Avulsas
	GTPA700D() 	// Carrega Taxas do Bilhete
	GTPA700E() 	// Carrega Vendas com Cartões
	GTPA700JA() // Carrega Receitas
	GTPA700JB() // Carrega Despes
	GTPA700N() 	// Carrega Depósitos de Terceiros

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} G700TitPrv

@type Static Function
@author Flavio Martins
@since 02/10/2019
@version 1.0
@param oModel, oModel, (Descrição do parâmetro)
@return lRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function G700TitPrv(oModel)
Local lRet 		:= .T.
Local oMdlG6T	:= oModel:GetModel('FIELDG6T')
Local oGridG6X	:= oModel:GetModel('GRIDG6X')
Local cCodG6T	:= oMdlG6T:GetValue('G6T_CODIGO')
Local cAliasG6Y	:= GetNextAlias()
Local nX		:= 0
Local cFicha	:= ""
Local aTitSE1	:= {}
Local cFilAtu	:= cFilAnt
Local cTitPro	:= ''

Private lMsErroAuto := .F.

	If G6X->(FieldPos('G6X_TITPRO')) > 0
		cTitPro := oGridG6X:GetValue('G6X_TITPRO')
	Endif

	For nX := 1 to Len(aDelFch)

		cFicha := AllTrim(aDelFch[nX])
		
		If oGridG6X:SeekLine({{'G6X_NUMFCH', cFicha}},.F.,.T.) .And. cTitPro != '2'

			BeginSql Alias cAliasG6Y
			
				SELECT G6Y_CODAGE, G6Y_CHVTIT FROM %Table:G6Y% G6Y
				WHERE
				G6Y.G6Y_FILIAL =  %xFilial:G6Y%
				AND G6Y.G6Y_CODIGO = %Exp:cCodG6T%
				AND G6Y.G6Y_NUMFCH = %Exp:cFicha%
				AND G6Y.G6Y_TPLANC ='2'
				AND G6Y.%NotDel%
				
			EndSql
			
			While (cAliasG6Y)->(!Eof())
			
				SE1->(dbSetOrder(1))
				
				If SE1->(dbSeek((cAliasG6Y)->G6Y_CHVTIT))
				
					If !Empty(SE1->E1_BAIXA)
		
						cFilAnt := 	SE1->E1_FILORIG
						aTitSE1	:= {{"E1_FILIAL"	, SE1->E1_FILIAL 		,Nil},;
						{"E1_PREFIXO"	, SE1->E1_PREFIXO 		,Nil},;
						{"E1_NUM"		, SE1->E1_NUM       	,Nil},;
						{"E1_PARCELA"	, SE1->E1_PARCELA  		,Nil},;
						{"E1_TIPO"	    , SE1->E1_TIPO     		,Nil},;
						{"E1_CLIENTE"   , SE1->E1_CLIENTE      	,Nil},;
						{"E1_LOJA"		, SE1->E1_LOJA			,Nil},;
						{"AUTHIST"	    , STR0123 + G6X->G6X_NUMFCH ,Nil}} // "Reabertura da ficha: "
							
						MSExecAuto({|x,y| Fina070(x,y)},aTitSE1,6) // Exclui a baixa do título
															
						If lMsErroAuto
							lRet := .F.
							MostraErro()
							Exit
						Else
						
							SE1->(dbSetOrder(1))
				
							If SE1->(dbSeek((cAliasG6Y)->G6Y_CHVTIT))

								MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 5)  // Exclui o título
									
								If lMsErroAuto
									lRet := .F.
									MostraErro()
									Exit
								Endif
								
							Endif
							
						Endif
			
					Endif
					
				Endif
			
				(cAliasG6Y)->(dbSkip())
			
			End
			
			(cAliasG6Y)->(dbCloseArea())
		
		Endif
		
	Next
	
	cFilAnt := cFilAtu

Return lRet

Static Function VldTpFicha(oMdlG6X)
Local lRet		:= .T.
Local nX   		:= 0
Local cTitPro	:= ''	
Local nReg		:= 0

	If  G6X->(FieldPos('G6X_TITPRO')) > 0
		cTitPro := oMdlG6X:GetValue('G6X_TITPRO')
 	Endif

	nReg := oMdlG6X:GetLine()

	For nX := 1 To oMdlG6X:Length()
		
			oMdlG6X:GoLine(nX)
			
			If oMdlG6X:GetValue('G6X_FLAGCX') .And. cTitPro != oMdlG6X:GetValue('G6X_TITPRO')
				lRet := .F.
				Exit
			Endif

	Next

	oMdlG6X:GoLine(nReg)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PrcFechSld(nVlRec, nVlDesp, cCodCx, cAgencia, cNumFch)
Executa fechamento do caixa para agencias configurados sem geracao do título provisório
@type Static Function
@author Flavio Martins
@since 10/07/2020
@version 1.0
@return lRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function PrcFechSld(nVlRec, nVlDesp, nVlTit, cCodCx, cAgencia, cNumFch)
Local lRet		:= .T.
Local oMdl501 	:= FwLoadModel('GTPA501')
Local oMdlGQN	:= oMdl501:GetModel('GQNMASTER')
Local oGridGZ3	:= oMdl501:GetModel('GRIDGZ3')
Local aDadosG6X := {}
Local nSaldo    := 0
Local aRegGZ3	:= {}
Local nX		:= 0

nSaldo := (nVlRec - nVlDesp)

If Round(nSaldo, 2) <> 0

	aRegGZ3 := RetDifArrec(cAgencia, cNumFch)

	oMdl501:SetOperation(MODEL_OPERATION_INSERT)
	oMdl501:Activate()

	oMdlGQN:SetValue('GQN_FILIAL', xFilial('G6T'))
	oMdlGQN:SetValue('GQN_DATA'  , dDataBase)
	oMdlGQN:SetValue('GQN_CDCAIX', cCodCx)
	oMdlGQN:SetValue('GQN_NUMFCH', cNumFch)
	oMdlGQN:SetValue('GQN_AGENCI', cAgencia)
	oMdlGQN:SetValue('GQN_TPDIFE', IIF(nSaldo > 0, '1','2'))
	oMdlGQN:SetValue('GQN_VLDIFE', IIF(nSaldo < 0, nSaldo*(-1), nSaldo))

	For nX := 1 To Len(aRegGZ3)

		If (!Empty(FwFldget('GZ3_CODIGO')))   
			oGridGZ3:AddLine()
		Endif

		oGridGZ3:SetValue('GZ3_CODIGO', oMdlGQN:GetValue('GQN_CODIGO'))
		oGridGZ3:SetValue('GZ3_SEQITM', StrZero(nX,4))
		oGridGZ3:SetValue('GZ3_TPITEM', aRegGZ3[nX][1])
		oGridGZ3:SetValue('GZ3_VALOR',  aRegGZ3[nX][2])
	Next

	If oMdl501:VldData()
		oMdl501:CommitData()
		oMdl501:DeActivate()
	Else
		lRet := .F.
	Endif

	If lRet

		aAdd( aDadosG6X, {"G6X_RECCX"  , nVlRec})
		aAdd( aDadosG6X, {"G6X_DESCX"  , nVlDesp})
		aAdd( aDadosG6X, {"G6X_SLDCX"  , nSaldo })
		aAdd( aDadosG6X, {"G6X_TPSLCX" , IIF(nSaldo > 0, "CR", "CP")})
		aAdd( aDadosG6X, {"G6X_STATUS" , "4"	})
		aAdd( aDadosG6X, {"G6X_FECHCX" , .T.})
		aAdd( aDadosG6X, {"G6X_DTCAIX" , dDataBase})

		dbSelectArea("G6X")
		G6X->(dbSetOrder(3))

		If G6X->(dbSeek(xFilial('G6X')+cAgencia+cNumFch))
			lRet := AtuG6X(aDadosG6X)
		Endif

	Endif

Else
	aAdd( aDadosG6X, { "G6X_RECCX"  , nVlRec})
	aAdd( aDadosG6X, { "G6X_DESCX"  , nVlDesp})
	aAdd( aDadosG6X, { "G6X_SLDCX"  , nSaldo})
	aAdd( aDadosG6X, { "G6X_STATUS" , "4"	})
	aAdd( aDadosG6X, { "G6X_FECHCX" , .T.	})
	aAdd( aDadosG6X, { "G6X_DTCAIX" , dDataBase})

	dbSelectArea("G6X")
	G6X->(dbSetOrder(3))

	If G6X->(dbSeek(xFilial('G6X')+cAgencia+cNumFch))
		lRet := AtuG6X(aDadosG6X)
	Endif

Endif

oMdl501:Destroy()

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} RetDifArrec(cAgencia, cNumFch)
Retorna array com os diferenças apontadas na arrecadação
@type Static Function
@author Flavio Martins
@since 28/07/2020
@version 1.0
@return aDados, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function RetDifArrec(cAgencia, cNumFch)
Local cAliasGIC := GetNextAlias()
Local cAliasG57 := GetNextAlias()
Local cAliasPos := GetNextAlias()
Local cAliasGZG := GetNextAlias()
Local cAliasGQW := GetNextAlias()
Local aDados   	:= {}
Local nVlrBil	:= 0
Local nVlrPos	:= 0
Local nVlrRec	:= 0
Local nVlrDsp	:= 0
Local nVlrReq	:= 0
Local nVlrTax	:= 0

BeginSql Alias cAliasGIC

	SELECT GIC_VALTOT
	FROM %Table:GIC% GIC
	WHERE GIC_FILIAL = %xFilial:GIC%
  	  AND GIC_AGENCI = %Exp:cAgencia%
	  AND GIC_NUMFCH = %Exp:cNumFch%
	  AND GIC_CONFER = '3'
	  AND GIC.%NotDel%

EndSql

While (cAliasGIC)->(!Eof())

	nVlrBil += (cAliasGIC)->GIC_VALTOT
	(cAliasGIC)->(dbSkip())

End

BeginSql Alias cAliasG57

	SELECT G57_VALOR
	FROM %Table:G57% G57
	WHERE G57_FILIAL = %xFilial:G57%
	  AND G57_AGENCI = %Exp:cAgencia%
	  AND G57_NUMFCH = %Exp:cNumFch%
	  AND G57_CONFER = '3'
	  AND G57.%NotDel%

EndSql

While (cAliasG57)->(!Eof())

	nVlrTax += (cAliasG57)->G57_VALOR
	(cAliasG57)->(dbSkip())

End

If GQM->(FieldPos('GQM_VLACER')) > 0

	BeginSql Alias cAliasPos

		SELECT GQM.GQM_VALOR,
			   GQM.GQM_VLACER	
		FROM %Table:GQL% GQL
		INNER JOIN %Table:GQM% GQM ON GQM.GQM_FILIAL = GQL.GQL_FILIAL
		AND GQM.GQM_CODGQL = GQL.GQL_CODIGO
		AND GQM.%NotDel%
		WHERE GQL.GQL_FILIAL = %xFilial:GQL%
		AND GQL.GQL_CODAGE = %Exp:cAgencia%
		AND GQL.GQL_NUMFCH = %Exp:cNumFch%
		AND (GQM.GQM_CONFER = '3' 
			OR (GQM.GQM_CONFER = '2' AND GQM.GQM_VLACER > 0))
		AND GQL.%NotDel%

	EndSql

Endif

While (cAliasPos)->(!Eof())

	nVlrPos += (cAliasPos)->GQM_VALOR - (cAliasPos)->GQM_VLACER
	(cAliasPos)->(dbSkip())

End

If GZG->(FieldPos('GZG_VLACER')) > 0

	BeginSql Alias cAliasGZG

		SELECT GZG_TIPO, 
			GZG_VALOR,
			GZG_VLACER
		FROM %Table:GZG% GZG
		INNER JOIN %Table:GZC% GZC ON GZC.GZC_FILIAL = %xFilial:GZC%
		AND GZC.GZC_CODIGO = GZG.GZG_COD
		AND GZC.%NotDel%
		WHERE GZG_FILIAL = %xFilial:GZG%
		AND GZG_AGENCI = %Exp:cAgencia%
		AND GZG_NUMFCH = %Exp:cNumFch%
		AND (GZG_CONFER = '3'
			OR (GZG.GZG_CONFER = '2' AND GZG.GZG_VLACER > 0))
		AND GZG.%NotDel%

	EndSql

	While (cAliasGZG)->(!Eof())

		If (cAliasGZG)->GZG_TIPO == '1'
			nVlrRec += (cAliasGZG)->GZG_VALOR - (cAliasGZG)->GZG_VLACER 
		Else
			nVlrDsp += (cAliasGZG)->GZG_VALOR - (cAliasGZG)->GZG_VLACER 
		Endif

		(cAliasGZG)->(dbSkip())

	End

Endif

BeginSql Alias cAliasGQW
	
	SELECT GQW_TOTAL
	FROM %Table:GQW% GQW
	WHERE GQW_FILIAL = %xFilial:GQW%
	  AND GQW_CODAGE =  %Exp:cAgencia%
	  AND GQW_NUMFCH =  %Exp:cNumFch%
	  AND GQW_CONFCH = '3'
	  AND GQW.%NotDel%

EndSql

While (cAliasGQW)->(!Eof())

	nVlrReq += (cAliasGQW)->GQW_TOTAL

	(cAliasGQW)->(dbSkip())

End

If nVlrbil > 0
	aAdd(aDados, {'1', nVlrBil})
Endif

If nVlrTax > 0
	aAdd(aDados, {'2', nVlrTax})
Endif

If nVlrPos > 0
	aAdd(aDados, {'4', nVlrPos})
Endif

If nVlrRec > 0
	aAdd(aDados, {'5', nVlrRec})
Endif

If nVlrDsp > 0
	aAdd(aDados, {'6', nVlrDsp})
Endif

If nVlrReq > 0
	aAdd(aDados, {'7', nVlrReq})
Endif

(cAliasGIC)->(dbCloseArea())
(cAliasG57)->(dbCloseArea())
(cAliasPos)->(dbCloseArea())
(cAliasGZG)->(dbCloseArea())
(cAliasGQW)->(dbCloseArea())

Return aDados

//------------------------------------------------------------------------------
/*/{Protheus.doc} PrcReabSld(cCodCx, cAgencia, cNumFch, cMsgTit)
Executa a reabertua do caixa para agencias configuradas sem geracao do título provisório
@type Static Function
@author Flavio Martins
@since 11/07/2020
@version 1.0
@return lRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function PrcReabSld(cCodCx, cAgencia, cNumFch, cMsgTit)
Local lRet  	:= .T.
Local oMdl501	:= FwLoadModel('GTPA501')
Local aDadosG6X := {}

GQN->(dbSetOrder(3))

If  GQN->(dbSeek(xFilial('GQN')+cCodCx+cAgencia+cNumFch))

	If !(Empty(GQN->GQN_FCHDES))
		cMsgTit := 'Saldo da ficha ' + cNumFch + ' já foi compensado na ficha ' + GQN->GQN_FCHDES
		lRet    := .F.
	Else

		oMdl501:SetOperation(MODEL_OPERATION_DELETE)
		oMdl501:Activate()

		If oMdl501:VldData()
			oMdl501:CommitData()
			oMdl501:DeActivate()
		Else
			lRet := .F.
		Endif

	Endif

Endif

If lRet

	aAdd( aDadosG6X, {"G6X_RECCX"  , 0})
	aAdd( aDadosG6X, {"G6X_DESCX"  , 0})
	aAdd( aDadosG6X, {"G6X_SLDCX"  , 0})
	aAdd( aDadosG6X, {"G6X_TPSLCX" , " "})
	aAdd( aDadosG6X, {"G6X_STATUS" , "3"})
	aAdd( aDadosG6X, {"G6X_FECHCX" , .F.})
	aAdd( aDadosG6X, {"G6X_DTCAIX" , CTOD('  /  /  ')})

	dbSelectArea("G6X")
	G6X->(dbSetOrder(3))

	If G6X->(dbSeek(xFilial('G6X')+cAgencia+cNumFch))
		lRet := AtuG6X(aDadosG6X)
	Endif

Endif

oMdl501:Destroy()

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldBxBoleto(cCodCx, cAgencia, cNumFch, cMsgTit)
Valida se o titulo vinculado ao boleto da ficha de remessa foi baixado
@type Static Function
@author Flavio Martins
@since 11/07/2020
@version 1.0
@return lRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldBxBoleto(cCodCx, cAgencia, cNumFch, cMsgTit)
Local lRet 		:= .T.
Local cAliasG6Y := GetNextAlias()

BeginSql Alias cAliasG6Y

	SELECT G6Y.G6Y_CHVTIT
	FROM %Table:G6Y% G6Y
	WHERE G6Y.G6Y_FILIAL = %xFilial:G6Y%
	AND G6Y.G6Y_CODIGO = %Exp:cCodCx%
	AND G6Y.G6Y_CODAGE = %Exp:cAgencia%
	AND G6Y.G6Y_NUMFCH = %Exp:cNumFch%
	AND G6Y.G6Y_TPLANC = '2'
	AND G6Y.%NotDel%	

EndSql

If AllTrim((cAliasG6Y)->G6Y_CHVTIT) > ''

	SE1->(dbSetOrder(1))

	If SE1->(dbSeek((cAliasG6Y)->G6Y_CHVTIT)) 

		If SE1->E1_SALDO > 0
			cMsgTit := STR0128 // "Título vinculados a boletos precisam estar baixados antes do fechamento do caixa"
			lRet	:= .F.
		Endif

	Else
		cMsgTit := STR0129 // "Título do boleto não encontrado no Financeiro"
		lRet 	:= .F.
	Endif

Else
	cMsgTit := STR0130 // "Chave do título provisório vazia ou inválida"
	lRet 	:= .F.
Endif

(cAliasG6Y)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetOpcMenu(nOpc)
Executa a view conforme selecionado no menu
@type Static Function
@author Flavio Martins
@since 16/07/2020
@version 1.0
@return Nil, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetOpcMenu(nOpc)
Local nOperation := VldOpenMenu(nOpc)

If nOperation > 0

	Do Case             
		Case nOpc = 1
			GTPA700A(nOperation) // Notas Fiscais de entrada	           
		Case nOpc = 2
			GTPA700B(nOperation) // Depositos/Titulos		           
		Case nOpc = 3
			GTPA700C(nOperation) // Taxas Avulsas
		Case nOpc = 4
			GTPA700D(nOperation) // Taxas
		Case nOpc = 5
			GTPA700E(nOperation) // Vendas Cartao
		Case nOpc = 6
			GTPA700I(nOperation) // Vendas Canceladas no Cartão	
		Case nOpc = 7
			GTPA700JA(nOperation) // Receitas	
		Case nOpc = 8
			GTPA700JB(nOperation) // Despesas	
		Case nOpc = 9
			GTPA501(G6T->G6T_AGENCI) // Conta Corrente	
		Case nOpc = 10
			GTPA700N(nOperation) // Depósito de Terceiros
	EndCase

Endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldOpenMenu(nOpc)
Valida modo de abertura das opções de menu
@type Static Function
@author Flavio Martins
@since 16/07/2020
@version 1.0
@return nOperation, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldOpenMenu(nOpc)
Local cAliasQry 	:= GetNextAlias()
Local cAliasQry1	:= GetNextAlias()
Local nOperation	:= 1
Local aNewFlds 	    := {'G6X_TITPRO', 'G6X_DEPOSI'}
Local lNewFlds  	:= GTPxVldDic('G6X', aNewFlds, .F., .T.)
Local cFldsG6X		:= ''

If !Empty(G6T->G6T_CODIGO)

	If  G6T->G6T_STATUS $ '1|3' // Caixa Aberto ou Reaberto

		If lNewFlds
			cFldsG6X := ' ,G6X_TITPRO,G6X_DEPOSI '	
		Endif

		cFldsG6X := '%' + cFldsG6X + '%'

		BeginSQL Alias cAliasQry
			
			SELECT  G6X_FILIAL,G6X_NUMFCH,G6X_DTINI,G6X_DTFIN
			%Exp:cFldsG6X%
			FROM %Table:G6X% G6X
			WHERE G6X_FILIAL = %xFilial:G6X%
			AND G6X_STATUS IN ('3','4')
			AND G6X_CODCX  = %Exp:G6T->G6T_CODIGO%
			AND G6X_AGENCI  = %Exp:G6T->G6T_AGENCI%
			AND G6X_FLAGCX = 'T'
			AND G6X.G6X_FECHCX = 'F'
			AND %NotDel%
				
		EndSql

		If (cAliasQry)->(!Eof())

			nOperation := 4

			If nOpc == 2 .And. lNewFlds .And.;
			 ((cAliasQry)->G6X_TITPRO == '2' .Or. (cAliasQry)->G6X_DEPOSI == '3') // Não utiliza titulo provisório ou é pagto. por boleto
				nOperation := 1 // Não permite alteração no depósito para processo sem titulo provisório ou pagamento por boleto
			Endif

		Else
			BeginSQL Alias cAliasQry1
			
				SELECT  G6X_FILIAL,G6X_NUMFCH,G6X_DTINI,G6X_DTFIN
				FROM %Table:G6X% G6X
				WHERE G6X_FILIAL = %xFilial:G6X%
				AND G6X_STATUS IN ('3','4')
				AND G6X_CODCX  = %Exp:G6T->G6T_CODIGO%
				AND G6X_AGENCI  = %Exp:G6T->G6T_AGENCI%
				AND G6X_FLAGCX = 'T'
				AND G6X.G6X_FECHCX = 'T'
				AND %NotDel%
					
			EndSQL
			
			If (cAliasQry1)->(!Eof())
				nOperation := 1	// Abre em modo VIEW
				FwAlertHelp(STR0133, STR0134) // "Ficha de Remessa" // "O sistema irá abrir em modo Visualização, pois não há fichas abertas para esse caixa, entre em manutenção e reabra as fichas."
			Else
				nOperation := 0
				FwAlertHelp(STR0133, STR0135) // "Ficha de Remessa" // "Não há ficha de remessa pendentes ou marcada em manutenção de ficha "
			Endif

		Endif

		If Select(cAliasQry) > 0
			(cAliasQry)->(dbCloseArea())
		Endif

		If Select(cAliasQry1) > 0
			(cAliasQry1)->(dbCloseArea())
		Endif

	Endif
		
Else
	FwAlertHelp(STR0016, STR0136) // "Abrir Caixa", "Não há caixa aberto"
	Return nOperation
EndIf

Return nOperation

//------------------------------------------------------------------------------
/*/{Protheus.doc} GerTitTerc(cAgencia, cNumFch)
Função que gera e baixa o título para os depósitos de terceiros
@type Static Function
@author Flavio Martins
@since 14/02/2022
@version 1.0
@return lRet Lógico
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GerTitTerc(cAgencia, cNumFch)
Local lRet 		:= .T.
Local cAliasG6Y	:= GetNextAlias()
Local aTitulo 	:= {}
Local aBaixa	:= {}
Local cParcela 	:= StrZero(1,TamSx3('E1_PARCELA')[1])
Local cNumero	:= ''
Local cNatureza := GTPGetRules('NATUREC')
Local cPrefixo  := GTPGetRules('PREFDEPTER')
Local cChave 	:= ''
Local cMsgErro	:= ''
Local cPath		:= ''
Local cFile		:= ''

BeginSql Alias cAliasG6Y
	
	SELECT  G6Y_VALOR, 
			G6Y_BANCO,
			G6Y_AGEBCO,
			G6Y_CTABCO,
			G6Y_DATA,
			G6Y_NUMFCH,
			R_E_C_N_O_ AS RECNO
	FROM %Table:G6Y% G6Y
	WHERE G6Y_FILIAL = %xFilial:G6Y%
	  AND G6Y_CODAGE = %Exp:cAgencia%
	  AND G6Y_NUMFCH = %Exp:cNumFch%
	  AND G6Y_TPLANC = 'A'
	  AND G6Y_STSDEP = '1'
	  AND %NotDel%

EndSql

While (cAliasG6Y)->(!Eof())
	
	cNumero	:= GtpTitNum('SE1', 'DEP', cParcela, 'TF')
	cChave	:= xFilial("SE1")+PadR(cPrefixo,TamSx3('E1_PREFIXO')[1])+cNumero+PadR(cParcela,TamSx3('E1_PARCELA')[1])+PadR("TF",TamSx3('E1_TIPO')[1])
	
	GI6->(dbSetOrder(1))
	GI6->(dbSeek(xFilial("GI6")+cAgencia))

	If !Empty(GI6->GI6_CLIENT) .AND. !Empty(GI6->GI6_LJCLI)
		aAdd(aTitulo, {"E1_PREFIXO"	,cPrefixo					,NIL } )
		aAdd(aTitulo, {"E1_NUM" 	,cNumero					,NIL } )
		aAdd(aTitulo, {"E1_TIPO" 	,"TF" 						,NIL } )
		aAdd(aTitulo, {"E1_NATUREZ"	,cNatureza 					,NIL } )
		aAdd(aTitulo, {"E1_CLIENTE" ,GI6->GI6_CLIENT			,NIL } )
		aAdd(aTitulo, {"E1_LOJA"	,GI6->GI6_LJCLI				,NIL } )
		aAdd(aTitulo, {"E1_PARCELA" ,cParcela 					,NIL } )
		aAdd(aTitulo, {"E1_EMISSAO"	,dDataBase					,NIL } )
		aAdd(aTitulo, {"E1_VENCTO"	,dDataBase					,NIL } )
		aAdd(aTitulo, {"E1_VENCREA"	,dDataBase					,NIL } )
		aAdd(aTitulo, {"E1_VALOR" 	,(cAliasG6Y)->G6Y_VALOR		,NIL } )
		aAdd(aTitulo, {"E1_HIST"	, cAgencia + cNumFch		,NIL } )
		aAdd(aTitulo, {"E1_ORIGEM"	,'GTPA700A' 				,NIL } )
	
		MsExecAuto( { |x,y| FINA040(x,y)}, aTitulo, 3) // 3-Inclusao,4-Alteração,5-Exclusão
	
		If lMsErroAuto
			lRet := .F.
			cMsgErro := MostraErro(cPath, cFile) + CRLF
			Exit
		Else
			dbSelectArea('G6Y')
			G6Y->(dbGoto((cAliasG6Y)->RECNO))

			If RecLock("G6Y", .F.)
				G6Y->G6Y_CHVTIT := cChave
			Endif

			G6Y->(MsUnlock())	

			SE1->(dbSetOrder(1))

			If SE1->(dbSeek(cChave))
				aBaixa 	:= {}	
				aBaixa 	 := {{"E1_FILIAL"  ,SE1->E1_FILIAL       		,Nil},;
							{"E1_PREFIXO"  ,SE1->E1_PREFIXO     	  	,Nil},;
							{"E1_NUM"      ,SE1->E1_NUM          		,Nil},;
							{"E1_TIPO"     ,SE1->E1_TIPO            	,Nil},;
							{"AUTMOTBX"    ,"NOR"                  		,Nil},;
							{"AUTBANCO"    ,(cAliasG6Y)->G6Y_BANCO    	,Nil},;
							{"AUTAGENCIA"  ,(cAliasG6Y)->G6Y_AGEBCO   	,Nil},;
							{"AUTCONTA"    ,(cAliasG6Y)->G6Y_CTABCO   	,Nil},;
							{"AUTDTBAIXA"  ,dDataBase  					,Nil},;
							{"AUTDTCREDITO",dDataBase					,Nil},;
							{"AUTHIST"     ,STR0125	+ (cAliasG6Y)->G6Y_NUMFCH	,Nil    },; // "Bx tit. no fechamento da Ficha: "
							{"AUTJUROS"    ,0                      		,Nil,.T.},;
							{"AUTVALREC"   ,(cAliasG6Y)->G6Y_VALOR    	,Nil    }}
							
				MsExecAuto({|x,y| FINA070(x,y)}, aBaixa, 3)
							
				If lMsErroAuto
					lRet := .F.
					cMsgErro := MostraErro(cPath,cFile) + CRLF
					Exit

				Else
					ConfirmSX8()
				Endif
			Endif

		Endif
	Endif

	(cAliasG6Y)->(dbSkip())

EndDo

(cAliasG6Y)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} EstTitTerc(cAgencia, cNumFch)
Função que estorna baixa e o título para os depósitos de terceiros
@type Static Function
@author Flavio Martins
@since 16/02/2022
@version 1.0
@return lRet Lógico
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function EstTitTerc(cAgencia, cNumFch)
Local lRet 		:= .T.
Local cFilAtu 	:= cFilAnt
Local cAliasG6Y	:= GetNextAlias()
Local aBaixa	:= {}
Local cMsgErro	:= ''
Local cPath		:= ''
Local cFile		:= ''

BeginSql Alias cAliasG6Y
	
	SELECT  G6Y_NUMFCH,
			G6Y_CHVTIT,
			R_E_C_N_O_ AS RECNO
	FROM %Table:G6Y% G6Y
	WHERE G6Y_FILIAL = %xFilial:G6Y%
	  AND G6Y_CODAGE = %Exp:cAgencia%
	  AND G6Y_NUMFCH = %Exp:cNumFch%
	  AND G6Y_TPLANC = 'A'
	  AND G6Y_STSDEP = '1'
	  AND G6Y_CHVTIT <> ''
	  AND %NotDel%

EndSql

While (cAliasG6Y)->(!Eof())

	SE1->(dbSetOrder(1))

	If SE1->(dbSeek((cAliasG6Y)->G6Y_CHVTIT))

		If !Empty(SE1->E1_BAIXA)
			cFilAnt := 	SE1->E1_FILORIG
			aBaixa	:= {{"E1_FILIAL"	,SE1->E1_FILIAL 		,Nil},;
						{"E1_PREFIXO"	,SE1->E1_PREFIXO 		,Nil},;
						{"E1_NUM"		,SE1->E1_NUM       		,Nil},;
						{"E1_PARCELA"	,SE1->E1_PARCELA  		,Nil},;
						{"E1_TIPO"	    ,SE1->E1_TIPO     		,Nil},;
						{"E1_CLIENTE"   ,SE1->E1_CLIENTE      	,Nil},;
						{"E1_LOJA"		,SE1->E1_LOJA			,Nil},;
						{"AUTHIST"	    ,STR0126 + (cAliasG6Y)->G6Y_NUMFCH,Nil}} // "Reabertura da ficha: "

			MsExecAuto({|x,y| Fina070(x,y)}, aBaixa,6) // Exclui a baixa do título
									
			If lMsErroAuto
				lRet 	 := .F.
				cMsgErro := MostraErro(cPath,cFile) + CRLF
				Exit										
			Else
				MsExecAuto( { |x,y| FINA040(x,y)} , aBaixa, 5)  // Exclui o título
					
				If lMsErroAuto
					lRet := .F.
					cMsgErro := MostraErro(cPath,cFile) + CRLF		
					Exit
				Else
					G6Y->(dbGoto((cAliasG6Y)->RECNO))

					If RecLock("G6Y", .F.)
						G6Y->G6Y_CHVTIT := ''
					Endif

					G6Y->(MsUnlock())	
				Endif
				

			Endif
		Endif
	Endif

	(cAliasG6Y)->(dbSkip())

EndDo

(cAliasG6Y)->(dbCloseArea())

cFilAnt := cFilAtu

Return lRet
