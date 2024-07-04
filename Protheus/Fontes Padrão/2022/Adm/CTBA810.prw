#INCLUDE "PROTHEUS.CH"                         
#INCLUDE "DBTREE.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "CTBA810.CH"                         

// ESTRUTURA DE DADOS DA ARRAY __ADADOSENT
#DEFINE AE_ENTIDADE		1
#DEFINE AE_DESCRICAO	2
#DEFINE AE_ALIAS		3
#DEFINE AE_CAMPO		4
#DEFINE AE_DESCITEM		5
#DEFINE AE_F3			6

#DEFINE TMPORI

#DEFINE BMPALTERAR 		"NOTE.PNG"

// Array principal para montagem e manipulaÁ„o da tela.
Static __aDadosEnt	:= {}
Static __CtbUseAmar := Nil

// Array contendo os dados de filtros.
Static __aFiltros	:= {}
Static __aFiliais	:= {cFilAnt}
Static __aTmpFil	:= {}
Static __aTmpAux	:= {}

Static nQtdEntid	:= Nil
Static __nTmpOri	:= Nil

Static __lConOutR	:= Nil

Static __lCTB810MNU	:= ExistBlock("CTB810MNU")
Static lCtb810Grv	:= ExistBlock("CTB810Grv")	

Static nCont		:= 0
Static nAplySelect  := 0

Static __cProcZero := NIL   //procedure strzero
Static __cProcSoma1 := NIL  //procedure soma1

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : CTBA810
//± Autor        : Renato Campos
//± Data         : 28/03/2013
//± Uso          : Rotina de AmarraÁ„o de entidades contabeis.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Function CTBA810( cAlias,nRecno,nOpc )
Local nIx	:= 0

Private aIndexFil	:= {}
Private aIndexes

Private cCadastro 	:= OemToAnsi(STR0001)  //"Cadastro AmarraÁ„o de entidades"

Private aHeaderOri	:= {}
Private aHeaderDes  := {}

Private cAliasOri	:= ""
Private cAliasEnt01	:= ""
Private cAliasEnt02	:= ""
Private cAliasDes	:= ""

Private aResult 	
Private aAliasOri	:= {}

Private nEntAnt		:= 0 	//Entidade Anterior

//-----------------------------------
// ValidaÁıes para utilizaÁ„o da tela
//-----------------------------------
// Acesso somente pelo SIGACTB
If ( !AMIIn(34) )
	Return
EndIf

// Se o parametro estiver nulo, atribuo conforme a regra do parametro MV_CTBAMAR
If __CtbUseAmar == Nil
	__CtbUseAmar := CtbUseAmar() $ '2#3' 
Endif

If __lConOutR == Nil
	__lConOutR := FindFunction("CONOUTR")
EndIf

If !__CtbUseAmar .OR. ( FunName() <> "CTBA250" )
	// Se n„o tiver controle de amarraÁ„o, desvio para a CTBA250 
    CTBA250()   
	Return
EndIf

// Rotina disponivel somente para ambientes TOPCONN
If !IfDefTopCTB()
	MsgAlert( STR0032 )  //"AtenÁ„o, rotina disponivel somente para ambientes TOPConnect ou TOTVSDbAcess"
	Return
Endif

// Quantidade de entidades.
If nQtdEntid == NIL
	nQtdEntid := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

// Define a posiÁ„o do temporario de origem
__nTmpOri := nQtdEntid + 1

// define o tamanho da array de temporarios
aAliasOri := Array(__nTmpOri)

For nIx := 1 To Len( aAliasOri )
	If nIx <= nQtdEntid
		aAliasOri[nIx]	:= CriaTmpOri( @aHeaderOri, nIx )
	Else
		aAliasOri[nIx]	:= CriaTmpOri( @aHeaderOri, 10 )   //coloca sempre 10 
	EndIf 
Next

cAliasDes	:= CriaTmpDes( @aHeaderDes ) 

CTBA810Dlg(cAlias,nRecno,nOpc)

If !Empty(aAliasOri)
	For nIx := 1 To Len(aAliasOri)
		DeleteTmp(aAliasOri[nIx])
	Next nIx
Endif

If !Empty( cAliasDes )
	DeleteTmp( cAliasDes )
Endif

CTDelTmpFil()
For nIx := 1 TO Len( __aTmpFil )
	CtbTmpErase( __aTmpFil[nIx] )
Next

__aTmpAux := {}

If __cProcZero != NIL
	If TcSqlExec( "DROP PROCEDURE "+__cProcZero+"_"+cEmpAnt  ) <> 0
			UserException( "CTBA810 - Error in Drop procedure temp" + __cProcZero+"_"+ cEmpAnt; 
						+ CRLF + "Error: " + CRLF + TCSqlError() )
	EndIf   
	__cProcZero := NIL   //procedure strzero
EndIf   

If __cProcSoma1 != NIL
	If TcSqlExec( "DROP PROCEDURE "+__cProcSoma1+"_"+cEmpAnt  ) <> 0
			UserException( "CTBA810 - Error in Drop procedure temp" + __cProcSoma1+"_" + cEmpAnt; 
						+ CRLF + "Error: " + CRLF + TCSqlError() )
	EndIf   
	__cProcSoma1 := NIL  //procedure soma1
EndIf   

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : CTBA810Dlg
//± Autor        : Renato Campos
//± Data         : 28/03/2013
//± Uso          : Efetua a montagem da tela (FwLayer, FwBrowse, xTree)
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Function CTBA810Dlg(cAlias,nRecno,nOpc)
Local oDlg
Local oFWLayer, oWin01, oWin02, oWin03
Local oBarTree, oButtonBar 
Local oFont

Local aArea			:= GetArea()
Local aSize 		:= MsAdvSize(,.F.,400)
Local bSair			:= {|| oDlg:End() }

Local bActHide		:= {|| oWin03:Hide(), oWin02:Hide() , oWin03:Hide() }
Local bAction		:= {|| IIf( !VISUAL, CtbEditTree(oBrwWin01, oBrwWin02,.F.),.F.),oWin03:Show(),oWin04:Show() }
Local bGrava		:= {|| MsgRun(STR0033,"",{||CTBA810Grava(nOpc), oDlg:End() } ) }  //"Salvando os dados, aguarde..."
Local bFiltro		:= {|| MsgRun(STR0034,"",{||CtbEditTree(oBrwWin01, oBrwWin02,.T.),oWin03:Show(),oWin04:Show()} ) } //"Filtrando Dados, aguarde..."
Local bMarkAll		:= {|| If(!VerCartesi(1),NIL,(MarkOnOff(.T.),FiltraDestino(),oBrwWin01:Refresh()))}
Local bMarkAllDs	:= {|| If(!VerCartesi(3),NIL,(MarkDOnOff(.T.),FiltraDestino(),oBrwWin02:Refresh()))}
Local bAplyFilter   := {|| If(!VerCartesi(2),NIL,(nAplySelect:=If(Aviso( STR0035, STR0036,{ STR0037,STR0038})==1,1,0),;  //"Aplicar SeleÁ„o"##"Confirma a aplicaÁ„o dos novos itens selecionados ?"##"Sim"##"Nao"
 							If(nAplySelect==1,FiltraDestino(),NIL)))}
Local nIx			:= 0
Local nWinOri 		:= 37
Local nWinDes 		:= 41

Private oBrwWin01, oBrwWin02

Private VISUAL		:= nOpc==2
Private INCLUI		:= nOpc==3
Private ALTERA		:= nOpc==4 
Private EXCLUI		:= nOpc==5

// retorna a array __aDadosEnt para a montagem dos componentes da tela
If !CtbGetEnt()
	MsgAlert( STR0039 )  //"Erro! N„o foi encontrado nenhuma entidade configurada."
	Return .F.
Endif

DbSelectArea( "CTA" )
RegToMemory("CTA",.F.)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ MONTAGEM DA TELA ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
DEFINE DIALOG oDlg TITLE ""  FROM aSize[7],0 to aSize[6],aSize[5]  PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria instancia do fwlayer≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
oFWLayer := FWLayer():New()

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Inicializa componente passa a Dialog criada,o segundo parametro È para ≥
//≥criaÁ„o de um botao de fechar utilizado para Dlg sem cabeÁalho 		  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
oFWLayer:Init( oDlg, .T. )

// Efetua a montagem das colunas das telas
oFWLayer:AddCollumn( "Col01", 20, .T. )
oFWLayer:AddCollumn( "Col02", 80, .F. )

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria a window passando, nome da coluna onde sera criada, nome da window			 	≥
//≥ titulo da window, a porcentagem da altura da janela, se esta habilitada para click,	≥
//≥ se È redimensionada em caso de minimizar outras janelas e a aÁ„o no click do split 	≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
oFWLayer:AddWindow( "Col01", "Win01", STR0013	, 98 		, .F., .T.,	 			,,) //'Entidade'
oFWLayer:AddWindow( "Col02", "Win02", STR0040	, 20  		, .F., .T., {|| .T. }	,,) //'Dados da AmarraÁ„o'
oFWLayer:AddWindow( "Col02", "Win03", STR0041	, nWinOri  	, .F., .T., {|| .T. }	,,) //'Entidade de Origem'
oFWLayer:AddWindow( "Col02", "Win04", STR0042	, nWinDes  	, .F., .T., {|| .T. }	,,) //'Entidade de Destino'

oFWLayer:SetColSplit( "Col01", CONTROL_ALIGN_RIGHT,, {|| .T. } )

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Painel 1					  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oWin01	:= oFWLayer:GetWinPanel('Col01','Win01')

//--------------------------------
//Adiciona a arvore no painel 1
//--------------------------------
oTree	:= Xtree():New(00,00,oWin01:NCLIENTHEIGHT*.48,oWin01:NCLIENTWIDTH*.50, oWin01)
CriaArvore( oTree, bAction, bActHide )

//--------------------------------
//Adiciona as barras dos botıes
//--------------------------------
DEFINE BUTTONBAR oBarTree SIZE 10,10 3D BOTTOM OF oWin01
oButtTree		:= thButton():New(01,01, STR0008  , oBarTree,  bSair	,30,20,) //'Sair'

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Painel 2					  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oWin02 := oFWLayer:getWinPanel('Col02','Win02')
CtbGetAmar(oWin02,nOpc) 

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Painel 3					  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oWin03 := oFWLayer:getWinPanel('Col02','Win03')

//--------------------------------
//Adiciona o browse no painel 3
//--------------------------------
DEFINE FWBROWSE oBrwWin01 DATA TABLE ALIAS (aAliasOri[__nTmpOri]) OF oWin03 
ADD MARKCOLUMN   oColumn DATA { || Iif(( aAliasOri[__nTmpOri] )->MARCA=='T' ,'LBOK', 'LBNO' ) } DOUBLECLICK { |oBrwWin01| MarkOnOff(),FiltraDestino() } HEADERCLICK bMarkAll OF oBrwWin01		
LoadBrowse(aAliasOri[__nTmpOri], aHeaderOri, oBrwWin01)

If !VISUAL
	//--------------------------------
	//Adiciona as barras dos botıes
	//--------------------------------
	DEFINE BUTTONBAR oButtonBar SIZE 10,10 3D BOTTOM OF oWin03
	oButtTree := thButton():New(01,01, STR0043	, oButtonBar,  bMarkAll  	,50,20,) //"Marcar(Des) Todos"
	oButtTree := thButton():New(01,01, STR0044	, oButtonBar,  bFiltro   	,50,20,) //"Parametros"
	If Altera
		oButtTree := thButton():New(01,01, STR0045	, oButtonBar,  bAplyFilter 	,50,20,) //"Aplicar SeleÁ„o"
	EndIf
Endif
	
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Painel 4					  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oWin04 := oFWLayer:getWinPanel('Col02','Win04')

//--------------------------------
//Adiciona o browse no painel 4
//--------------------------------
DEFINE FWBROWSE oBrwWin02 DATA TABLE ALIAS (cAliasDes) OF oWin04
ADD MARKCOLUMN   oColumn DATA { || Iif(( cAliasDes )->MARCA=='T' ,'LBOK', 'LBNO' ) } DOUBLECLICK { |oBrwWin02| MarkDOnOff() } HEADERCLICK bMarkAllDs OF oBrwWin02		
LoadBrowse(cAliasDes, aHeaderDes, oBrwWin02)
oBrwWin02:SetDelete(.T., {||.T.})

If !VISUAL
	DEFINE BUTTONBAR oBarTree SIZE 10,10 3D BOTTOM OF oWin04
	oButtTree := thButton():New(01,01, STR0043	, oBarTree,  bMarkAllDs ,50,20,) //"Marcar(Des) Todos"
	oButtTree := thButton():New(01,01, STR0046	, oBarTree,  bGrava	,30,20,) //'Gravar'
Endif
	
//Esconde os dados dos paineis 2 e 3 ao iniciar
oWin03:Hide(.T.)
oWin04:Hide(.T.)

If !INCLUI
	LoadDadosCTA()
	oWin04:Show(.T.)
	oBrwWin02:Refresh(.T.)
Endif

ACTIVATE DIALOG oDlg CENTERED

RestArea( aArea )

Return  

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : CriaArvore
//± Autor        : Renato Campos
//± Data         : 28/03/2013
//± Uso          : Cria a arvore (Pai e Filho) do painel 1 no xTree
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function CriaArvore( oTree, bAction, bActHide )
Local nIX
Local cCargo		:= "ENT"
Local cCargoEnt		:= ""

oTree:BeginUpdate()
oTree:Reset()

oTree:AddTree( STR0047,"IndicatorCheckBox","IndicatorCheckBoxOver",cCargo,bActHide) //'Entidade Cont·bil'

If Len(__aDadosEnt) > 0
	For nIx := 1 To Len(__aDadosEnt)
		
		cCargoEnt	:= cCargo+ __aDadosEnt[nIx][AE_ENTIDADE] 
			
		oTree:TreeSeek(cCargo)
		oTree:AddTree(	__aDadosEnt[nIx][AE_ENTIDADE] + " - " + __aDadosEnt[nIx][AE_DESCRICAO],; //descricao do node
						"IndicatorCheckBox", ; //bitmap fechado
						"IndicatorCheckBoxOver",; //bitmap aberto
						cCargoEnt , ;  //cargo (id)
						bAction ; //bAction - bloco de codigo para exibir
					 )
		
		oTree:EndTree()
	Next
Endif
    
oTree:EndUpdate()
oTree:Refresh()

Return oTree

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : CtbGetAmar
//± Autor        : Renato Campos
//± Data         : 28/03/2013
//± Uso          : Monta a Get dos dados basicos da amarraÁ„o.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function CtbGetAmar(oWin,nOpc) 
Local aAreaAtu	:= GetArea() 

Local aCpoEnch		:= {'NOUSER','CTA_REGRA','CTA_DESC'}
Local aIncluEnch	:= {'CTA_REGRA','CTA_DESC'}

Local cAliasE		:= 'CTA'
Local nModelo		:= 2

Private aTELA[0][0]
Private aGETS[0]

If IsInCallStack('CTBA250')
	oGet := MsMGet():New(cAliasE,(cAliasE)->(RecNo()),4,,,,aCpoEnch,{0,0,60,300},aIncluEnch,nModelo,,,,oWin)  //forca alteracao pois axinclui - ctba250
Else
	oGet := MsMGet():New(cAliasE,(cAliasE)->(RecNo()),nOpc,,,,aCpoEnch,{0,0,60,300},aIncluEnch,nModelo,,,,oWin)
EndIf
oGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT


RestArea(aAreaAtu)

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : LoadBrowse
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Carrega a estrutura de dados no FWBrowse
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function LoadBrowse(cAlias, aHeader, oBrowse, bDbClik)
Local aCampos	:= {}
Local aStru		:= {}
Local nI
Private cIdProf810	:= "CT810" // Variavel para identificaÁ„o de ID quando existem multiplos browsers.

Default			:= {|| .T. }

oBrowse:SetUseFilter()
oBrowse:SetProfileID(cIdProf810) //Definindo ID para identificaÁ„o dos browser's.
//-------------------------------------------------------------------
// Adiciona as colunas do Browse
//-------------------------------------------------------------------
nI := 0
For nI := 1 To Len( aHeader )
	ADD COLUMN oColumn DATA &( '{ || ' + aHeader[nI][2] + ' }' ) Title aHeader[nI][1] PICTURE aHeader[nI][6] DOUBLECLICK bDbClik Of oBrowse
Next                                           

oBrowse:Activate()

Return( oBrowse )


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : MarkOnOff
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function MarkOnOff( lAll )
Local nEntid		:= Val(oTree:aNodes[Val(oTree:CurrentNodeId)][2])-1
Local cQuery		:= ""
Local lMarca
Local nRecno		:= (aAliasOri[__nTmpOri])->(Recno())
Local nRecAux       
Default lAll		:= .F.
lMarca		:= ( (aAliasOri[__nTmpOri])->MARCA=='T' )

(aAliasOri[nEntid])->( dbGoTop() )

If (aAliasOri[nEntid])->( ! Eof() )
	cQuery := "UPDATE " + aAliasOri[__nTmpOri]
	If !lAll
		cQuery += "   SET MARCA = CASE WHEN MARCA = 'F' THEN 'T' ELSE 'F' END" 
		cQuery += " WHERE R_E_C_N_O_ = " +  StrZero( nRecno , 10 )
	Else
		cQuery += "   SET MARCA = '" + Iif( lMarca , 'F' , 'T' ) + "'" 
		
	Endif
	
	If CtbSqlExec( cQuery )
		TcRefresh( aAliasOri[__nTmpOri] )
		
		cQuery := "UPDATE " + aAliasOri[nEntid] + " SET MARCA = ( SELECT MARCA FROM " + aAliasOri[__nTmpOri] + " WHERE " + aAliasOri[__nTmpOri] + ".R_E_C_N_O_ = " + aAliasOri[nEntid] + ".R_E_C_N_O_ )" 
		If !lAll
			cQuery += " WHERE R_E_C_N_O_ = " +  StrZero( nRecno , 10 )
		Endif
			
		If CtbSqlExec( cQuery )
			TcRefresh( aAliasOri[nEntid] ) 
			TcRefresh( cAliasDes ) 
		Endif
		//este trecho eh somente para dar refresh na tabela---NAO RETIRAR
		nRecAux := 	( aAliasOri[nEntid] )->( Recno() )
		DbSelectArea( aAliasOri[nEntid] )
		dbGoBottom()
		dbGoTop()
		DbGoTo( nRecAux )
		//-----------------------------------------------------------------
		DbSelectArea( aAliasOri[__nTmpOri] )
		DbGoTo( nRecno )
	Endif                        
Endif                        

oBrwWin01:Refresh()
oBrwWin02:Refresh()
	
Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : MarkDOnOff
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function MarkDOnOff(lAll)

Local cQuery		:= ""
Local nRecno		:= (cAliasDes)->(Recno())
Local lMarca        := .F.

Default lAll := .F.

lMarca		:= ( (cAliasDes)->MARCA=='T' )

cQuery := "UPDATE " + cAliasDes
If !lAll
	cQuery += "   SET MARCA = CASE WHEN MARCA = 'F' THEN 'T' ELSE 'F' END" 
	cQuery += " WHERE R_E_C_N_O_ = " +  StrZero( nRecno , 10 )
Else
	cQuery += "   SET MARCA = '" + Iif( lMarca , 'F' , 'T' ) + "'" 
EndIf

If CtbSqlExec( cQuery )
	TcRefresh( cAliasDes )
	
	DbSelectArea( cAliasDes )
	DbGoTo( nRecno )
Endif                        

If !lAll
	//Refresh apenas na linha para que o posicionamento no grid n„o mude e atualize a visualizaÁ„o apenas da linha
	oBrwWin02:LineRefresh(oBrwWin02:nAt)
Else
	oBrwWin02:Refresh()
EndIf
	
Return


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//
//                      FILTRAGEM E GRAVACAO DE DADOS
//
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CtbGetEnt 
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Busca os dados das entidades
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CtbGetEnt()
Local aArea		:= GetArea()

Local nTotEnt	:= 0
Local nX		:= 0

Local oEntCT0	:= Nil

__aDadosEnt := {}

// Conta
Aadd( __aDadosEnt , {"01", STR0048,"CT1","CT1_CONTA", "CT1_DESC01" , "CT1"	} )  //"Plano de Contas"
// Centro de Custo
Aadd( __aDadosEnt , {"02", STR0049,"CTT","CTT_CUSTO","CTT_DESC01" , "CTT"	} )  //"Centro de Custo"
// Item contabil
Aadd( __aDadosEnt , {"03", STR0050,"CTD","CTD_ITEM","CTD_DESC01" , "CTD"	} )  //"Item Cont·bil"  
// Classe de valor
Aadd( __aDadosEnt , {"04", STR0051,"CTH","CTH_CLVL","CTH_DESC01" , "CTH"	} )  //"Classe de Valor"

// Demais entidades
If nQtdEntid > 4
	oEntCT0:= Adm_List_Records():New()
	oEntCT0:SetAlias("CT0")  //alias
	oEntCT0:SetOrder(1)		//ordem do indice	
	oEntCT0:Fill_Records() //preenche os registros 

	For nX := 1 TO oEntCT0:CountRecords()
		oEntCT0:SetPosition(nX)
		oEntCT0:SetRecord()
	    
		If nX > 4
			Aadd( __aDadosEnt , {StrZero(nX,2), CT0->CT0_DSCRES, CT0->CT0_ALIAS, CT0->CT0_CPOCHV, CT0->CT0_CPODSC, CT0->CT0_F3ENTI} )
		Endif
	Next
	
	nTotEnt	:= oEntCT0:CountRecords() 
	oEntCT0 := Nil
Endif

RestArea( aArea )

Return ( Len(__aDadosEnt) > 0)


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : FiltraOrigem
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Efetua a filtragem dos dados da Origem, escolhida na tree
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function FiltraOrigem(nEntid, aResult )
Local cCodEnt		:= AllTrim(__aDadosEnt[nEntid][1])	//Codigo da Entidade
Local cAlias		:= Alltrim(__aDadosEnt[nEntid][3])  // Alias do filtro
Local lCpoClasse	:= ( cAlias $ 'CT1*CTT*CTD*CTH*CV0' ) // Filtra Classe
Local cQuery		:= ''
Local cFuncTrim     := "RTRIM("

If ! ( Alltrim( Upper(TcGetDb())) $ 'MSSQL7|MSSQL|ORACLE|DB2' )
	cFuncTrim     := "TRIM("
EndIf
 
//Limpa tabela temporaria
CtbSqlExec( "DELETE FROM "+ aAliasOri[__nTmpOri] )

// Monta a query de filtro dos dados
cQuery := "SELECT 'F' MARCA"

cQuery += "     , "+ cFuncTrim + Alltrim(__aDadosEnt[nEntid][4]) + " ) CODIGO"
cQuery += "     , "+ cFuncTrim + AllTrim(__aDadosEnt[nEntid][5]) + " ) DESCRICAO"
cQuery += "     , D_E_L_E_T_, R_E_C_N_O_ "
cQuery += "  FROM " + RetSqlName(cAlias) + " " + cAlias + " " 
cQuery += " WHERE " + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "'"
cQuery += "   AND " + Alltrim(__aDadosEnt[nEntid][4]) + " BETWEEN '" + aResult[nEntid,1] + "' AND '" + aResult[nEntid,2] + "' "

If lCpoClasse
	cQuery += "AND  "+PrefixoCpo(cAlias)+"_CLASSE = '2' "	
EndIf 

If cAlias == 'CV0
	cQuery += " AND CV0_PLANO = '"+ cCodEnt +"' "
EndIf		
			
If !Empty(aResult[nEntid, 3])
	_cFiltro := PcoParseFil( aResult[nEntid, 3], cAlias )
	
	If !Empty(_cFiltro)		
		cQuery += " AND "+_cFiltro
	Else
		If !MsgYesNo( STR0052 )   //"Somente ser„o aceitas expressıes exatas. As expressıes [ContÈm a express„o], [N„o ContÈm], [Esta Contido em] e [N„o esta Contido em]  n„o ser„o executadas.Prosseguir?")
			Return()  
		EndIf						
	EndIf
EndIf

cQuery += "   AND D_E_L_E_T_ = ' '"

If ! ( Alltrim( Upper(TcGetDb())) $ 'INFORMIX' )
	cQuery += " ORDER BY CODIGO "
EndIf

cQuery := ChangeQuery( cQuery )             
cQuery:= StrTran ( cQuery, "FOR READ ONLY", "")

cInsert := "INSERT INTO " + aAliasOri[__nTmpOri] + "(MARCA, CODIGO, DESCRICAO, D_E_L_E_T_, R_E_C_N_O_) " + cQuery

IF CtbSqlExec(cInsert)
	TcRefresh( aAliasOri[__nTmpOri] )

	// Efetua a copia dos registros para o temporario
	CopyEnt(aAliasOri[__nTmpOri],aAliasOri[nEntid])
Endif

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : FiltraDestino
//± Autor         : Renato Campos
//± Data          : 25/04/2013
//± Uso           : Executa o filtro do destino
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function FiltraDestino()
Local aArea		:= GetArea()
Local cArqTrb	:= ""
Local cArq		:= ""
Local aProc		:= {}
Local aResult	:= {}
Local nIx		:= 0
Local lUsaProc	:= .T.
Local nCont 	:= 0
Local lContinua := .T.

If Inclui 
	lContinua := CtbSqlExec( "DELETE FROM "+ cAliasDes )  //Limpa tabela temporaria
	TcRefresh( cAliasDes )
ElseIf Altera
	lContinua := nAplySelect > 0  //verifica se confirmou filtro selecionado atravez do Aviso
EndIf
If lContinua
	// inicia a geraÁ„o dos dados na procedure.
	If Alltrim( Upper(TcGetDb())) $ 'MSSQL7|MSSQL|ORACLE|DB2|INFORMIX' .and. Alltrim(TcSrvType()) != "AS/400"
		cArqTrb := CriaTrab(,.F.)
		
		cArq  := cArqTrb + '01'
		AADD( aProc, cArq+"_"+cEmpAnt)
		
		// Cria a procedure dos dados
		lUsaProc := CriaProc( aProc )
		
		// chamada da procedure do contaref
		If lUsaProc
			MsgRun( STR0053, STR0054 , {|| aResult := TCSPEXEC( xProcedures( SubString( aProc[1] , 1 , Len(aProc[1])- 3)))	} )  //"Aguarde"##"Carregando dados..."
			TcRefresh( cAliasDes )			
		EndIf
		
		If Len( aProc ) > 0
			For nIx := 1 to Len(aProc)
				CtbSqlExec( "Drop procedure "+ aProc[nIx] )
			Next
		EndIf
		
		If Altera
			nAplySelect := 0
		EndIf
	Else
		lUsaProc := .F.
	EndIf

	TcRefresh( cAliasDes )

	oBrwWin01:Refresh()
	oBrwWin02:Refresh( .T. )

	//oBrwWin02:SetFilterDefault( cAliasDes+"->(RECNO() <> 0 ) " )
	oBrwWin02:SetFilterDefault( cAliasDes+"->(CTA_CONTA<>'ZZZZZZZZZZZZZZZZ' ) " )
	oBrwWin02:ExecuteFilter()
	
Endif

RestArea( aArea )

Return lUsaProc


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CopyEnt
//± Autor         : Renato Campos
//± Data          : 25/04/2013
//± Uso           : Executa a copia dos dados de origem para o destino
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CopyEnt(cAliasFrom, cAliasTO)
Local cQuery	:= ""    
Local cFuncTrim     := "RTRIM("

If ! ( Alltrim( Upper(TcGetDb())) $ 'MSSQL7|MSSQL|ORACLE|DB2' )
	cFuncTrim     := "TRIM("
EndIf

//Limpa tabela temporaria
cQuery := "DELETE FROM " + cAliasTO

If CtbSqlExec(cQuery)
	TcRefresh( cAliasTO )

	If Alltrim( Upper(TcGetDb())) $ 'INFORMIX'
		cQuery := "INSERT INTO " + cAliasTO +  " (MARCA, CODIGO, DESCRICAO, D_E_L_E_T_, R_E_C_N_O_) SELECT MARCA, "+cFuncTrim+" CODIGO ),"+cFuncTrim+" DESCRICAO ), D_E_L_E_T_, R_E_C_N_O_ FROM " + cAliasFrom 
	Else
		cQuery := "INSERT INTO " + cAliasTO +  " (MARCA, CODIGO, DESCRICAO, D_E_L_E_T_, R_E_C_N_O_) (SELECT MARCA, "+cFuncTrim+" CODIGO ), DESCRICAO, D_E_L_E_T_, R_E_C_N_O_ FROM " + cAliasFrom + ")"
	EndIf
	CtbSqlExec(cQuery)
Endif
	
TcRefresh(cAliasTO)

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : LoadDadosCTA
//± Autor         : Felipe Cunha
//± Data          : 26/04/2013
//± Uso           : Informa parametros para seleÁ„o de dados 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function LoadDadosCTA()
Local cQuery	:= ""
Local cCampos	:= ""
Local nX		:= 0

//Informa quais colunas ser„o exibidas
cCampos := "CTA_CONTA,CTA_CUSTO,CTA_ITEM,CTA_CLVL"

For nX := 5 To nQtdEntid 
	cCampos += "," + AllTrim("CTA_ENTI") + STRZERO(nX,2)
Next nX

If Alltrim( Upper(TcGetDb())) $ 'INFORMIX'
	cQuery += "INSERT INTO " + cAliasDes + " ( MARCA, " + cCampos + ", D_E_L_E_T_, R_E_C_N_O_)  "
Else
	cQuery += "INSERT INTO " + cAliasDes + " ( MARCA, " + cCampos + ", D_E_L_E_T_, R_E_C_N_O_)  ( "	
EndIf

cQuery += "SELECT 'T', " + cCampos + ", D_E_L_E_T_, R_E_C_N_O_
cQuery += "  FROM " + RetSqlName( "CTA" ) + " CTA "
cQuery += " WHERE CTA_FILIAL = '" + xFilial( "CTA" ) + "'"
cQuery += "   AND CTA_REGRA = '" + M->CTA_REGRA + "'"
cQuery += "   AND D_E_L_E_T_  = ' '"
If ! ( Alltrim( Upper(TcGetDb())) $ 'INFORMIX' )
	cQuery += ")"
EndIF 

If CtbSqlExec(cQuery)
	TcRefresh( cAliasDes )
Endif

//Ao inicializar a grid carregada, posicionar no topo 
(cAliasDes)->(dbGoTop())

Return


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CtbEditTree
//± Autor         : Felipe Cunha
//± Data          : 26/04/2013
//± Uso           : Informa parametros para selecÁ„o de dados 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CtbEditTree(oBrwWin01,oBrwWin02,lForce)
Local cAlias
LocaL cCodEnt		:= ""
Local cCampo 		:= ""
Local cFiltro 		:= ""
Local cF3 			:= ""
Local cRange_De 	:= ""
Local cRange_Ate    := ""
Local cDesc			:= ""
Local cDesc2		:= ""
Local cTitulo 		:= SubStr(oTree:GetPrompt(),At('-',oTree:GetPrompt())+2,Len(oTree:GetPrompt()))
Local aParametros	:= {}
Local aConfig 		:= {}  
Local aTamCpo       
Local lRet 			:= .T.
Local nEntid		:=Val(oTree:aNodes[Val(oTree:CurrentNodeId)][2])-1
Local lFiltra		:= .F.

Default lForce		:= .F.

If ValType(aResult) == "U"
	aResult := 	ARRAY( Len(__aDadosEnt) )
EndIf

cCodEnt		:= AllTrim(__aDadosEnt[nEntid][1])	//Codigo da Entidade
cDesc		:= AllTrim(__aDadosEnt[nEntid][2])	//Nome da Entidade
cF3 		:= Alltrim(__aDadosEnt[nEntid][3])  //Consulta Padr„o
cCampo 		:= Alltrim(__aDadosEnt[nEntid][4])	//Campo Chave	               
cDesc2		:= AllTrim(__aDadosEnt[nEntid][5])	//Campo DescriÁ„o
cAlias		:= Alltrim(__aDadosEnt[nEntid][3])
aTamCpo 	:= TamSX3(cCampo)[1]				//Tamanho do Campo

//-------------------------------------------
//Se for a primeira vez, chama tela de
//filtro para informar parametros.
//Senao aplica o ultimo filtro ja gravado
//-------------------------------------------
If aResult[nEntid] == NIL   
	cRange_De 	:= Space(aTamCpo)
	cRange_Ate 	:= Replicate("Z",aTamCpo)
	cFiltro 	:= ""     
Else
	cRange_De 	:= aResult[nEntid, 1]
	cRange_Ate 	:= aResult[nEntid, 2]
	cFiltro		:= aResult[nEntid, 3]
EndIf

//Cria campos da tela de filtro.
aAdd(aParametros,{1, Alltrim(cDesc)+" de "	, cRange_De		, "" 	,"",cF3	,""	, aTamCpo*5 , .F. } ) 	//" de "
aAdd(aParametros,{1, Alltrim(cDesc)+" atÈ "	, cRange_Ate	, "" 	,"",cF3	,""	, aTamCpo*5 , .F. } ) 	//" Ate "
aAdd(aParametros,{7, "Filtro "				, cF3			,cFiltro,""} ) 							  	//"Filtro "

If aResult[nEntid] == NIL .Or. lForce
	lFiltra := ParamBox(  aParametros ,cTitulo,aConfig,,,.F.,,,,,.F.)

	If lFiltra
		aResult[nEntid] := aClone(aConfig)
		oTree:ChangeBmp(BMPALTERAR,BMPALTERAR,oTree:GetCargo()) 
	Else
		aResult[nEntid] := aClone( {cRange_De, cRange_Ate, ""} ) 
	Endif
EndIf

IF nEntAnt <> 0
	CopyEnt(aAliasOri[__nTmpOri],aAliasOri[nEntAnt])
Endif

If lFiltra
	// Efetua a filtro dos dados.
	FiltraOrigem(nEntid, aResult)
Else
	// Efetua a copia dos dados j· filtrados
	CopyEnt(aAliasOri[nEntid],aAliasOri[__nTmpOri])
Endif

nEntAnt := nEntid

oBrwWin01:Refresh( .T. )

Return lRet

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//
//                    MONTAGEM DE ESTRUTURA DE DADOS
//
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CriaTmpOri
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Cria a tabela temporaria a ser usada no FwBrowse de Origem
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CriaTmpOri( aHeader, nEntidAux )
Local aChvOri   := {}
Local aCampos	:= {}
Local nCont
Local nTam	:= TAMSX3("CT1_DESC01")[1]
Local nTmaior	:= 0
Local cAliasOri	:= ""
Local aCpos	:={"CTH_DESC01","CT1_DESC01","CTT_DESC01","CTD_DESC01","CV0_DESC"}

Default nEntidAux := 0

For nCont:=1 to Len(aCpos)
		nTam := TAMSX3(aCpos[ncont])[1]
	If nTmaior < nTam
		ntmaior := nTam
	EndIf
	
Next nCont



Default aHeader	:= {}

If Len( aHeader ) <= 0
	//aAdd( aHeader, { "Marca"		, "MARCA"	, "L", 1,0,".F." } )
	aAdd( aHeader, { STR0055, "CODIGO"	, "C", TamSx3("CT1_CONTA")[1],0,"@!" } )  //"Entidade"
	aAdd( aHeader, { STR0056, "DESCRICAO","C",nTmaior,0,"@!" } )  //"DescriÁ„o"
Endif
	
Aadd( aCampos, { "MARCA"		, "C", 1,0} )

If 			nEntidAux == 1
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_CONTA")[1],0} )
ElseIf 		nEntidAux == 2
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_CUSTO")[1],0} )
ElseIf 		nEntidAux == 3
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_ITEM")[1],0} )
ElseIf	 	nEntidAux == 4
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_CLVL")[1],0} )
ElseIf	 	nEntidAux == 5
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_ENTI05")[1],0} )
ElseIf 		nEntidAux == 6
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_ENTI06")[1],0} )
ElseIf 		nEntidAux == 7
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_ENTI07")[1],0} )
ElseIf 		nEntidAux == 8
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_ENTI08")[1],0} )
ElseIf 		nEntidAux == 9
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_ENTI09")[1],0} )
Else
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CT1_CONTA")[1],0} )
EndIf
//MAIOR DESCRICAO
Aadd( aCampos, { "DESCRICAO"	, "C",nTmaior,0} )

// Montagem da Matriz aChvDes ( Chaves de Busca )
Aadd( aChvOri, "CODIGO" )

If ExistBlock( "CTC810CORI" )
	ExecBlock( "CTC810CORI" , .F. , .F. , {aCampos, aChvOri})			
Endif
	
// Cria o temporario a ser utilizado na tela.
cAliasOri := CriaTmp( aCampos, aChvOri )

RETURN cAliasOri

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao	   	  : CriaTmpDes
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Cria a tabela temporaria a ser usada no FwBrowse de Destino
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CriaTmpDes(aHeader)
Local aChvDes   := {}
Local aCampos	:= {}
Local aObrigat	:= {}

Local cAliasDes := ""  
lOCAL Nx 		:= 0

Default aHeader	:= {}

//Informa quais colunas ser„o exibidas
Aadd( aObrigat, "CTA_CONTA" )
Aadd( aObrigat, "CTA_CUSTO" )
Aadd( aObrigat, "CTA_ITEM" 	)
Aadd( aObrigat, "CTA_CLVL" 	)

For nX :=5 To nQtdEntid 
	Aadd( aObrigat, AllTrim("CTA_ENTI") + STRZERO(nX,2))
Next nX

Aadd( aCampos, { "MARCA"		, "C", 1,0} )

// Carrega os campos da CTA a partir do dicionario
CtbLoadSx3( 'CTA', aObrigat, @aHeader, @aCampos )

// Montagem da Matriz aChvDes ( Chaves de Busca )
//Aadd( aChvDes, "CTA_CONTA,CTA_CUSTO,CTA_ITEM,CTA_CLVL" )

If ExistBlock( "CTC810CDES" )
	ExecBlock( "CTC810CDES" , .F. , .F. , {aCampos, aChvDes})			
Endif

// Cria o temporario a ser utilizado na tela.
cAliasDes := CriaTmp( aCampos, aChvDes )

RETURN cAliasDes


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao	   	  : CriaTmp
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Cria a tabela temporaria a ser usada no FwBrowse no Banco
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CriaTmp( aCampos, aChaves )
Local aArea		:= GetArea()

Local cArq		:= ""
Local cChave	:= ""

Local nIx		:= 0

Default aChaves := {}

cArq	:= CriaTrab(,.F.)
If aScan(__aTmpAux, cArq)>0
	While aScan(__aTmpAux, cArq)>0
		aAdd(__aTmpAux, cArq)
		cArq	:= CriaTrab(,.F.)
	EndDo
Else	
	aAdd(__aTmpAux, cArq)
EndIf

MsCreate(cArq, aCampos, "TOPCONN")
Sleep(100)

dbUseArea( .T., "TOPCONN", cArq, cArq, .F., .F. )

If Len( aChaves ) > 0
	// Efetua a criaÁ„o da tabela no banco
	For nIx := 1 TO Len( aChaves )
		cChave := aChaves[nIx]
		
		cOrdName := "X"+ StrZero( nIx ,2)+cArq 
		If ( !TcCanOpen(cArq,cOrdName) )
			INDEX ON &(ClearKey( cChave )) TO &(cOrdName)
   		EndIf

		DbSetIndex(cOrdName)
		DbSetNickName(OrdName(nIx),cOrdName)
	Next nIx
	
	DbSelectArea( cArq )
	DbSetOrder(1)
	Sleep(100)
Endif

RestArea(aArea)

Return cArq

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : DeleteTmp
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Delela o temporario criado
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function DeleteTmp( cAliasTmp )
Local aArea := GetArea()

If cAliasTmp <> NIL .And. Valtype(cAliasTmp) == "C" .And. !Empty(cAliasTmp)
	If Select(cAliasTmp) > 0
		DbSelectArea(cAliasTmp)
		dbCloseArea()
	EndIf

	MsErase(cAliasTmp)
EndIf

RestArea(aArea)

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CtbLoadSx3
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Carrega os campos da SX3 para a criaÁ„o do temporario
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function CtbLoadSx3( cAlias, aObrigat, aHeader, aCampos )
Local aArea		:= GetArea()

Default aHeader := {}

// Montagem da matriz aCampos
DbSelectArea("SX3")
SX3->( DbSetOrder(1) )
SX3->( MsSeek(cAlias) )

While SX3->( !EOF() .And. (x3_arquivo == cAlias) )

	If cNivel >= x3_nivel
		If ( Len( aObrigat ) > 0 .And. aScan( aObrigat , Alltrim(x3_campo) ) <= 0 )
			SX3->( DbSkip() )
			Loop
		EndIf         
		aAdd( aHeader, { TRIM(X3TITULO()) , SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE, x3Uso(x3_usado) } )
		aAdd( aCampos, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
	Endif

	SX3->( DbSkip() )
EndDO

RestArea( aArea )

Return


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CtbSqlExec
//± Autor         : Renato Campos
//± Data          : 25/04/2013
//± Uso           : Executa a instruÁ„o de banco via TCSQLExec
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function CtbSqlExec( cStatement )
Local bBlock	:= ErrorBlock( { |e| ChecErro(e) } )
Local lRetorno := .T.

BEGIN SEQUENCE
	IF TcSqlExec(cStatement) <> 0
		UserException( STR0057 + CRLF + TCSqlError()  + CRLF + ProcName(1) + CRLF + cStatement )  //"Erro na instruÁ„o de execuÁ„o SQL"
		lRetorno := .F.
	Endif
RECOVER
	lRetorno := .F.
END SEQUENCE
ErrorBlock(bBlock)

Return lRetorno


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CriaProc
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Monta a procedure de concatenaÁ„o das entidades.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CriaProc( aProc )
Local lOk		:= .T.

Local nPTratRec := 0
Local nIx		:= 0

Local cCampo	:= ""  

Local cQuery	:= ""
Local cInsert	:= ""
Local cVarProc	:= ""
Local aCpoTmp      := {}
If Len( aProc ) <= 0
	Return
Endif

cQuery += "Create procedure " + aProc[1] + CRLF
cQuery+="   ( "+CRLF
cQuery+="   @OUT_RET Char( 01 ) OutPut"+CRLF
cQuery+="   )"+CRLF
cQuery += " AS " + CRLF

cQuery += " " + CRLF
cQuery += "Declare @iRecno integer" + CRLF

If ! ( Alltrim( Upper(TcGetDb())) $ 'INFORMIX' )
	cQuery += "Declare @iCommit integer" + CRLF
	cQuery += "Declare @iTranCount integer" + CRLF
EndIf 

If Altera
	cQuery += "Declare @iCtdReg integer" + CRLF
EndIf

For nIx := 1 To Len( __aDadosEnt )	 
	
	If aResult[nIx] <> NIL .And. Ctb810Qlp(aAliasOri[nIx]) 
		If nIx <= 4
			cCampo := " CTA_" + Substr( __aDadosEnt[nIx][AE_CAMPO] , 5 )
		Else
			cCampo := " CTA_ENTI" + StrZero( nIx , 2 )
		Endif
		cInsert += cCampo + ", "
		
		If CTA->( FieldPos(Alltrim(Upper(cCampo))) ) > 0
			cQuery += "Declare @c" +  Alltrim( cCampo ) + " Varchar(" + StrZero(TamSx3(Alltrim(Upper(cCampo)))[1],3) + ")" + CRLF
		Else
			cQuery += "Declare @c" +  Alltrim( cCampo ) + " Varchar(" + StrZero(TamSx3("CT1_CONTA")[1],3) + ")" + CRLF
		EndIf
		cVarProc += "@c" +  Alltrim( cCampo ) + ", "
		aAdd(aCpoTmp, { cCampo, "@c" +  Alltrim( cCampo ) })
	Endif
Next     

If Empty( aCpoTmp ) .OR. ( Altera .And. Empty( aCpoTmp[1,1] ) )
	ADEL( aProc, Len(aProc) )
	ASIZE( aProc, Len(aProc)-1 )
	If Altera
		nAplySelect := 0
	EndIf
	Return(.F.	)
EndIf

cVarProc := Substr( cVarProc , 1, Len(cVarProc) - 2)

cQuery += " " + CRLF
cQuery += "Begin " + CRLF
cQuery += "   " + CRLF
cQuery += "   select @OUT_RET = '0' " + CRLF

If ! ( Alltrim( Upper(TcGetDb())) $ 'INFORMIX' )
	cQuery += "   select @iCommit = 1" + CRLF
EndIf

cQuery += "   select @iRecno = 0 "+ CRLF
cQuery += "   select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from " + cAliasDes + CRLF
cQuery += "   select @iRecno = @iRecno + 1" + CRLF
cQuery += "   " + CRLF

cQuery += "   Declare cursor_proc insensitive cursor for"+CRLF
cQuery += MontaQuery()
cQuery += "   " + CRLF
cQuery += "   for read only"+CRLF

cQuery += "   "+CRLF
cQuery += "	  OPEN cursor_proc"+CRLF
cQuery += "	  Fetch cursor_proc into " + cVarProc + CRLF
cQuery += "   "+CRLF
cQuery += "   While ( @@Fetch_Status = 0) begin"+CRLF
cQuery += "      "+CRLF
//aqui tratamento para alterar nao gravar novamente os ja existentes
If Altera
	cQuery += "   select @iCtdReg = 0" + CRLF
	cQuery += "   select @iCtdReg = Count("+aCpoTmp[1,1]+")  From "+cAliasDes + CRLF
	cQuery += "   where " + CRLF
	For nIx := 1 TO Len(aCpoTmp)
		cQuery += " "+aCpoTmp[nIx,1]+"="+aCpoTmp[nIx,2]+If(nIx<Len(aCpoTmp)," AND ", " ") + CRLF
	Next
	cQuery += "   If @iCtdReg = 0 begin"+CRLF
EndIf

If ! ( Alltrim( Upper(TcGetDb())) $ 'INFORMIX' )
	cQuery += "      If @iCommit = 1 begin"+CRLF
	cQuery += "         begin Transaction"+CRLF 
	cQuery += "         Select @iCommit = @iCommit"+CRLF 
	cQuery += "      End"+CRLF
EndIf

cQuery += "      "+CRLF

cQuery += "   select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from " + cAliasDes + CRLF
cQuery += "   select @iRecno = @iRecno + 1" + CRLF

cQuery += "      ##TRATARECNO @iRecno\" + CRLF

If ( Alltrim( Upper(TcGetDb())) $ 'INFORMIX' )
	cQuery += "      Begin tran" + CRLF   //informix
EndIf

cQuery += "      INSERT INTO " + cAliasDes + " ( MARCA, " + cInsert + " D_E_L_E_T_, R_E_C_N_O_) VALUES ( 'T'," + cVarProc + ", ' ' , @iRecno )"

If ( Alltrim( Upper(TcGetDb())) $ 'INFORMIX' )
	cQuery += "      commit tran" + CRLF   //informix
EndIf

cQuery += "	     ##FIMTRATARECNO" + CRLF 
cQuery += "      "+CRLF

If !( Alltrim( Upper(TcGetDb())) $ 'INFORMIX' )
	cQuery += "      Select @iCommit = @iCommit + 1"+CRLF  
EndIf

cQuery += "      "+CRLF
If Altera
	cQuery += "      End"+CRLF
EndIf
cQuery += "		 Fetch cursor_proc into " + cVarProc + CRLF
cQuery += "      "+CRLF
If !( Alltrim( Upper(TcGetDb())) $ 'INFORMIX' )
	cQuery += "      If @iCommit >= 10000 begin"+CRLF
	cQuery += "         Commit Transaction "+CRLF
	cQuery += "         Select @iCommit = 1"+CRLF
	cQuery += "      End"+CRLF
EndIf

cQuery += "   select @OUT_RET = '1' " + CRLF

cQuery += "      "+CRLF
cQuery += "   End" + CRLF

If !( Alltrim( Upper(TcGetDb())) $ 'INFORMIX' )
	cQuery += "   If @iCommit > 1 begin"+CRLF
	cQuery += "      Commit Transaction"+CRLF
	cQuery += "      select @iTranCount = 0 "+CRLF
	cQuery += "   End"+CRLF
EndIf

cQuery += "	  Close cursor_proc" + CRLF
cQuery += "	  Deallocate cursor_proc" + CRLF

cQuery += "End" + CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If !TCSPExist( aProc[1] )
	lOk := CtbSqlExec(cQuery)
//	TcRefresh(cAliasDes)	
EndIf

Return lOk


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : MontaQuery
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Monta a query
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function MontaQuery()
Local nIx			:= 0

Local cQuery		:= "SELECT "
Local cFrom			:= "FROM "
Local cWhere		:= ""
Local cFuncTrim     := "RTRIM("

If ! ( Alltrim( Upper(TcGetDb())) $ 'MSSQL7|MSSQL|ORACLE|DB2' )
	cFuncTrim     := "TRIM("
EndIf

For nIx := 1 TO Len( aAliasOri ) - 1 
	
	If aResult[nIx] <> NIL  .And. Ctb810Qlp(aAliasOri[nIx])
		cQuery += cFuncTrim+" "+aAliasOri[nIx] + ".CODIGO )"

		If nIx <= 4
			cQuery += " CTA_" + Substr( __aDadosEnt[nIx][AE_CAMPO] , 5 )
		Else
			cQuery += " CTA_ENTI" + StrZero( nIx , 2 )
		Endif
		cFrom  += aAliasOri[nIx]
	
		cWhere := AddSqlExpr( cWhere , aAliasOri[nIx] + ".MARCA = 'T'"      )
		cWhere := AddSqlExpr( cWhere , aAliasOri[nIx] + ".D_E_L_E_T_ = ' '" )

		cQuery += ", "
		cFrom  += ", "
	Endif
Next

cQuery 	:= Substr( cQuery , 1 , Len(cQuery) - 2)
cFrom 	:= Substr( cFrom  , 1 , Len(cFrom) - 2 )

cQuery := ChangeQuery( cQuery + cFrom + cWhere )

Return cQuery


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CTBA810Grava Autor≥TOTVS               ∫ Data ≥  07/04/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Gravacao                                                   ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ/ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function CTBA810Grava(nOpc)
Local nIx			:= 0
Local cItemRegra	:= Replicate('0',TamSx3('CTA_ITREGR')[1])	//Item da Regra
Local cCodRegra	:= M->CTA_REGRA									//Codigo da Regra
Local lMarcado 	:= .T.
Local cQuery     := ""
Local cProc      := CriaTrab(,.F.)
Local nPTratRec  := 0

Local cCpoFixCTA := "CTA_FILIAL, CTA_REGRA, CTA_DESC, CTA_NIVEL, CTA_ITREGR,"
Local cVarFixCTA := "@IN_CTA_FILIAL, @IN_CTA_REGRA, @IN_CTA_DESC, @IN_CTA_NIVEL, @C_CTA_ITREGR,"

Local cCposCTA   := ""
Local cVarsCTA   := ""
Local cVarsFetch   := ""

Local lEntid05   := .F.
Local lEntid06   := .F.
Local lEntid07   := .F.
Local lEntid08   := .F.
Local lEntid09   := .F.

Local cRet   		:= ""
Local lRet       := .T.

Local bProc := {||}
Local aResult := {}

Default lCtb810Grv	:= ExistBlock("CTB810Grv")	


//cria procedures StrZero e Soma1 a ser utilizada para imcrementar campo CTA_ITREGR
If ! A810Tools()
	Return
EndIf

//cria a procedure de gravacao antes da transacao 
//utiliza insert para melhoria de performance

For nIx := 1 TO Len( aHeaderDes )
	If ( cAliasDes )->(FieldPos(aHeaderDes[nIx][2])) > 0 .And. CTA->(FieldPos( aHeaderDes[nIx][2] )) > 0
		cCposCTA += Alltrim(aHeaderDes[nIx][2])+", "
		cVarsCTA += "@C_"+Alltrim(aHeaderDes[nIx][2])+", "
		cVarsFetch += "@C_"+Alltrim(aHeaderDes[nIx][2])+", "
				
		If   		Alltrim(aHeaderDes[nIx][2])  == "CTA_ENTI05"
					lEntid05   := .T.
		
		ElseIf   	Alltrim(aHeaderDes[nIx][2])  == "CTA_ENTI06"
					lEntid06   := .T.

		ElseIf   	Alltrim(aHeaderDes[nIx][2])  == "CTA_ENTI07"
					lEntid07   := .T.

		ElseIf   	Alltrim(aHeaderDes[nIx][2])  == "CTA_ENTI08"
					lEntid08   := .T.

		ElseIf   	Alltrim(aHeaderDes[nIx][2])  == "CTA_ENTI09"
					lEntid09   := .T.

		Endif


	Endif
Next nCont
		
cCposCTA += "D_E_L_E_T_ "+", "
cVarsCTA += "@C_Delet, "

cCposCTA += "R_E_C_N_O_ "
cVarsCTA += "@iRecno "

cVarsFetch := Substr( cVarsFetch, 1 , Len( cVarsFetch )-2 ) //tirar a virgula + space

cQuery :="create procedure "+cProc+CRLF
cQuery +="( "+CRLF

cQuery +="	@IN_CTA_FILIAL 	Char("+Alltrim(Str(Len(CTA->CTA_FILIAL)))	+"),"+CRLF
cQuery +="	@IN_CTA_REGRA 	Char("+Alltrim(Str(Len(CTA->CTA_REGRA)))	+"),"+CRLF
cQuery +="	@IN_CTA_ITREGR 	Char("+Alltrim(Str(Len(CTA->CTA_ITREGR)))	+"),"+CRLF
cQuery +="	@IN_CTA_NIVEL 	Char("+Alltrim(Str(Len(CTA->CTA_NIVEL)))	+"),"+CRLF
cQuery +="	@IN_CTA_DESC 	    Char("+Alltrim(Str(Len(CTA->CTA_DESC)))	+"),"+CRLF
cQuery+="  @OUT_RESULT       Char( 01 ) OutPut"+CRLF

cQuery +=" )"+CRLF
cQuery +="as"+CRLF
/* ---------------------------------------------------------------------------------------------------------------------
    Vers„o          - <v> Protheus 12 </v>
    Assinatura      - <a> 001 </a>
    Fonte Microsiga - <s> CTBA810 </s>
    Descricao       - <d> Insere Registros na CTA por conta de performance  </d>
    Funcao do Siga  -     CTBA810Grava()
    -----------------------------------------------------------------------------------------------------------------
    Entrada         -  <ri> TODOS OS CAMPOS DA TABELA CTA 
    							@IN_NOMEDOCAMPO 
	</ri>
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> Sem saida </ro>
    -----------------------------------------------------------------------------------------------------------------
    Vers„o      :  <v> Advanced Protheus </v>
    -----------------------------------------------------------------------------------------------------------------
    ObservaÁıes :  <o>   </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Paulo Carnelossi  </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 08/06/2017 </dt>

    Estrutura de chamadas
    ========= == ========
   --------------------------------------------------------------------------------------------------------------------- */

//declare das variaveis de entidades conta / centro de custo / item contabil / classe de valor / entidades adicionadas via wizard
For nIx := 1 TO Len( aHeaderDes )
	If ( cAliasDes )->(FieldPos(aHeaderDes[nIx][2])) > 0 .And. CTA->(FieldPos( aHeaderDes[nIx][2] )) > 0
			cQuery +="	Declare @C_"+Alltrim(aHeaderDes[nIx][2])+" 	    Char("+Alltrim(Str(aHeaderDes[nIx][4]))	+") "+CRLF
	Endif
Next nCont

cQuery += "Declare @iRecno integer" + CRLF
cQuery += "Declare @C_Delet Char(1) " + CRLF
cQuery += "Declare @C_CTA_ITREGR 	Char("+Alltrim(Str(Len(CTA->CTA_ITREGR)))	+") "+CRLF

cQuery +=" begin"+CRLF

cQuery += " select @OUT_RESULT = '0' "+CRLF
cQuery += " select @C_Delet = ' ' " + CRLF
cQuery += " select @C_CTA_ITREGR = @IN_CTA_ITREGR " + CRLF

cQuery += " select @iRecno = 0 "+ CRLF
cQuery += " select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from " + RetSqlName("CTA") + CRLF
cQuery += " select @iRecno = @iRecno + 1" + CRLF
cQuery += " " + CRLF

//DECLARE CURSOR
cQuery += "   Declare cursor_cta insensitive cursor for"+CRLF
cQuery += " SELECT "

//laco para lista dos campos na query
For nIx := 1 TO Len( aHeaderDes )
	cQuery +=" "+Alltrim(aHeaderDes[nIx][2])+If(nIx==Len( aHeaderDes )," ", ", ")+CRLF
Next nCont

//tabela destino
cQuery +=" FROM "+cAliasDes+CRLF

//condicao where
cQuery +=" WHERE MARCA = 'T' AND D_E_L_E_T_ = ' ' "+CRLF

cQuery += "   for read only"+CRLF

//abertura do cursor
cQuery += "   "+CRLF
cQuery += "	  OPEN cursor_cta"+CRLF

//fetch
cQuery += "	  Fetch cursor_cta into " + cVarsFetch + CRLF
cQuery += "   "+CRLF

//CURSOR (LACO)
cQuery += "   While ( @@Fetch_Status = 0) begin"+CRLF
cQuery += "      "+CRLF

//inicio laco	

cQuery +=" begin"+CRLF //finaliza,
		
cQuery += "      ##TRATARECNO @iRecno\ "+ CRLF
cQuery += "      begin tran"+CRLF

cQuery += "      INSERT INTO "+RetSqlName("CTA") +" ("+cCpoFixCTA+cCposCTA+")"+ CRLF 
cQuery += "                                  VALUES ("+cVarFixCTA+cVarsCTA+")" + CRLF
cQuery += "      commit tran"+CRLF
cQuery += "       ##FIMTRATARECNO "+ CRLF

cQuery += "     EXEC "+__cProcSoma1+"_"+cEmpAnt+" @C_CTA_ITREGR, '0', @C_CTA_ITREGR OutPut "+CRLF

cQuery += "     select @iRecno = @iRecno + 1" + CRLF

//fetch
cQuery += "	  Fetch cursor_cta into " + cVarsFetch + CRLF
cQuery += "   "+CRLF

//FIM CURSOR (LACO)
cQuery +=" end"+CRLF //finaliza laco while

cQuery +=" end"+CRLF //finaliza cursor


cQuery += "	  Close cursor_cta" + CRLF
cQuery += "	  Deallocate cursor_cta" + CRLF

cQuery += " Select @OUT_RESULT = '1' "+CRLF

cQuery +=" end"+CRLF //finaliza,

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)		

If !Empty(cQuery)		
	//executa o script cQuery para criar a procedure que ira fazer insert na tabela CTA - AMARRACAO		
	cRet := TcSqlExec( cQuery )
	If cRet <> 0
		If !IsBlind()
			MsgAlert( "CTBA810 - Error in create procedure - Table" + RetSqlName("CTA")  + " Procedure: " + cProc + TcSQLError() )  //'Erro na criacao da procedure'
		EndIf
		lRet := .F.	
	EndIf
Else
	If !IsBlind()
		MsgAlert( "CTBA810 - Error in parser - create procedure - Table" + RetSqlName("CTA") + " Procedure: " + cProc + MsParseError() )  //'Erro na criacao da procedure'
	EndIf
	lRet := .F.	
EndIf

If !lRet  //se ocorrer erro retorna e nao grava nada
	Return
EndIf

BEGIN TRANSACTION

//Este comando SQL vai excluir todos os registros com o mesmo codigo de amarracao
If nOpc == 4 // alteracao

	cQuery := " DELETE FROM "
	cQuery += RetSqlName("CTA") + " "
	cQuery += " WHERE " 
	cQuery += "       CTA_FILIAL = '"+xFilial("CTA")+"' "
	cQuery += "   AND CTA_REGRA = '"+M->CTA_REGRA+"' "
	cQuery += "   AND D_E_L_E_T_  = ' ' "
	
	If TcSqlExec( cQuery  ) <> 0
		UserException( "CTBA810 - Error in delete - Table" + RetSqlName(cAlias) ;
					+ CRLF + "Error: " + CRLF + TCSqlError() )
	EndIf   

EndIf

DbSelectArea( "CTA" )
DbSetOrder(0)
					
bProc := {||aResult := TCSPEXEC( cProc,;
											xFilial('CTA'),;
											cCodRegra,;
											StrZero(1, Len(CTA->CTA_ITREGR) ),;
											"1",;
											M->CTA_DESC)}

MsgRun("Gravando Registros","Aguarde",bProc)

If Empty(aResult) .or. aResult[1] = "0"
	MsgAlert( "CTBA810 - Error in exec procedure - Table: " + RetSqlName("CTA") + " Procedure: " + cProc ) 
	DisarmTransaction()	 
EndIf

If nOpc == 3
	ConfirmSx8()
EndIf

END TRANSACTION

//PE executado apÛs a gravaÁ„o das amarraÁıes de entidade
If lCtb810Grv
	ExecBlock("CTB810Grv", .F., .F.,{nOpc})
EndIf		                                            

If TcSqlExec( "DROP PROCEDURE "+cProc  ) <> 0
		UserException( "CTBA810 - Error in delete - Table" + RetSqlName(cAlias) ;
					+ CRLF + "Error: " + CRLF + TCSqlError() )
EndIf   

Return()


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : Ctb810Qlp
//± Autor         : Felipe Cunha
//± Data          : 23/07/2013
//± Uso           : 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function Ctb810Qlp(cAliasTmp)
Local lRet 		:= .F.
Local cNewAlias	:= GetNextAlias()
Local cQryCount	:= ""

//Verifica se a tabela de origem esta populada
cQryCount := "SELECT COUNT(*) NREG FROM " + cAliasTmp
cQryCount := ChangeQuery( cQryCount )	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCount),cNewAlias)	

If ( cNewAlias )->NREG > 0
	lret := .T.
EndIf	
( cNewAlias )->(dbCloseArea())
	
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CtbRegCt0 ∫ Autor ≥TOTVS               ∫ Data ≥  04/07/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Retorna array com os registros da CT0                      ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function CtbRegCt0()
Local aArea	:= GetArea()
Local aRegs	:= {}
DbSelectArea('CT0')
DbSetOrder(1)
If DbSeek(xFilial('CT0')) 
	While !Eof() .And. xFilial('CT0') == CT0->CT0_FILIAL
			AADD( aRegs , {CT0->CT0_ALIAS , CT0->CT0_ENTIDA, CT0->CT0_ID, CT0->CT0_CPOCHV,CT0->CT0_CPODSC,CT0->CT0_F3ENTI } )  
		DbSkip()			
	EndDo			
EndIf                        
RestArea( aArea )
Return aRegs

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : VerCartesi()
//± Autor         : Paulo Carnelossi
//± Data          : 04/08/2015
//± Uso           : Verifica se cartesiano ao Marcar Todos excede 100.000 reg.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function VerCartesi(nOption)
Local lRet 		:= .T.
Local nEntidOri	:= Val(oTree:aNodes[Val(oTree:CurrentNodeId)][2])-1
Local aRetCount := {}
Local nResult  	:= 1
Local lMarcado
Local nX

Default nOption := 1

If nOption == 1   //marcar / desmarcar

	lMarcado 	:= ( (aAliasOri[nEntidOri])->MARCA=='T' )
	
	If !lMarcado  //se nao estiver marcado vai marcar todos ai valida senao nao eh necessario
		//montar query entre marcados x Entidade posicionada e pressionado Marcar Todos e retornar array  
		aRetCount := MontQryMrk(nEntidOri, .F.)
		//faz multiplicacao de todos os elementos do array
		For nX := 1 TO Len(aRetCount)	
			nResult *= aRetCount[nX]
		Next
	EndIf

ElseIf nOption == 2  // aplicar filtro na alteracao
	
	//montar query entre marcados x Entidade posicionada e pressionado Marcar Todos e retornar array  
	aRetCount := MontQryMrk(nEntidOri, .T.)
	//faz multiplicacao de todos os elementos do array
	For nX := 1 TO Len(aRetCount)	
		nResult *= aRetCount[nX]
	Next
	
	//soma a nResult a quantidade ja incluida no destino antes de aplicar filtro
	nResult += QryDestino()

ElseIf nOption == 3  //marcar / desmarcar entidade destino

	lMarcado 	:= ( (cAliasDes)->MARCA=='T' )
	
	If !lMarcado  //se nao estiver marcado vai marcar todos ai valida senao nao eh necessario
		//montar query entre marcados x Entidade posicionada e pressionado Marcar Todos e retornar array  
		aRetCount := MontQryMrk(nEntidOri, .T.)
		//faz multiplicacao de todos os elementos do array
		For nX := 1 TO Len(aRetCount)	
			nResult *= aRetCount[nX]
		Next
	EndIf

	nResult += QryDestino()

EndIf

//se atingiu os 50.000 registro informa ao usuario e nao deixa marcar todos
If nResult > 50000 //(maior que cem mil registros avisa e nao deixa prosseguir com marcar todos)
	Aviso(STR0058, STR0059+If(nOption==1, STR0060, STR0061)+CRLF+; //"Atencao"##"O numero de combinacoes pretendidas ao marcar todos excede a 50.000 registros, portanto n„o ser· "##"marcado."##"aplicado."
					STR0062+;   //"Usuario deve restringir o numero de registros a marcar e se necessario deve se efetuar uma nova "
					STR0063, {STR0064})  //"amarracao com outro codigo, pois na avaliacao da regra n„o e considerado o codigo da amarracao."##"Fechar"
	lRet := .F.
EndIf

Return(lRet)

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : MontQryMrk
//± Autor         : Renato Campos/Paulo Carnelossi
//± Data          : 28/03/2013
//± Uso           : Monta query p cartesiano entre os marcados x Marcar Todos
//±               : retorna um array contendo as contagem por entidade
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function MontQryMrk(nEntOrig, lMark)
Local nIx			:= 0
Local cQuery		:= " "
Local aRetorno      := {}
Local cNewAlias   	:= CriaTrab(,.F.)
Local aArea 		:= GetArea()

Default lMark := .F.

For nIx := 1 TO Len( aAliasOri ) - 1 
	
	If Ctb810Qlp(aAliasOri[nIx])

		cQuery := " SELECT COUNT(*) NREG FROM "+aAliasOri[nIx]
		cQuery += " WHERE "+aAliasOri[nIx] + ".D_E_L_E_T_ = ' '"

		If nIx != nEntOrig .OR. lMark	
			cQuery := AddSqlExpr( cQuery , aAliasOri[nIx] + ".MARCA = 'T'"      )
		EndIf

		//Verifica se a tabela de origem esta populada
		cQuery := ChangeQuery( cQuery )	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNewAlias)	

		If ( cNewAlias )->NREG > 0
			aAdd(aRetorno, ( cNewAlias )->NREG)
		Else
			aAdd(aRetorno, 1)
		EndIf	
		( cNewAlias )->(dbCloseArea())
	Else
		aAdd(aRetorno, 1)
	Endif
Next

RestArea(aArea)

Return(aRetorno)


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : QryDestino
//± Autor         : Renato Campos/Paulo Carnelossi
//± Data          : 28/03/2013
//± Uso           : Monta query p/ contar na tabela destino todos os ja marcados
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function QryDestino()

Local cQuery		:= " "
Local nRetorno      := 0
Local cNewAlias   	:= CriaTrab(,.F.)
Local aArea 		:= GetArea()

cQuery := " SELECT COUNT(*) NREG FROM "+cAliasDes
cQuery += " WHERE "+cAliasDes + ".D_E_L_E_T_ = ' '"

cQuery := AddSqlExpr( cQuery , cAliasDes + ".MARCA = 'T'"      )

//Verifica se a tabela de origem esta populada
cQuery := ChangeQuery( cQuery )	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNewAlias)	

If ( cNewAlias )->NREG > 0
	nRetorno := ( cNewAlias )->NREG
EndIf

( cNewAlias )->( dbCloseArea() )

RestArea(aArea)

Return(nRetorno)


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : A810Tools
//± Autor         : Paulo Carnelossi
//± Data          : 16/06/2017
//± Uso           : Cria Procedure StrZero / Soma1
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


Static Function A810Tools()
Local lRet := .T.
Local cSqlCtbZERO
Local cRet

If lRet
	
	If __cProcZero == NIL
		__cProcZero := CriaTrab(,.F.)

		cSqlCtbZERO := ProcSTRZERO(__cProcZero)
		
		If !TCSPExist( __cProcZero )
			cRet := TcSqlExec(cSqlCtbZERO)
			If cRet <> 0
				If !IsBlind()
					MsgAlert("Error in create procedure CtbZero[StrZero] : "+__cProcZero,"Error") 
					lRet:= .F.
				EndIf
			EndIf
		EndIf

	EndIf


	If lRet

		If __cProcSoma1 == NIL
			__cProcSoma1 := CriaTrab(,.F.)

			If ! TCSPExist( __cProcSoma1 )
				lRet := CTM300SOMA( __cProcSoma1 , __cProcZero+"_"+cEmpAnt )
			EndIf
		
		Endif
		
	EndIf

EndIf

Return(lRet)
