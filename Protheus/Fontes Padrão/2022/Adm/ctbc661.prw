#INCLUDE "CTBC661.CH"
#INCLUDE "PROTHEUS.CH"                         
#INCLUDE 'DBTREE.CH'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "APWIZARD.CH"

// ESTRUTURA DE DADOS DA ARRAY __ADADOSMOD
#DEFINE RT_MODULO		1
#DEFINE RT_LP			2

#DEFINE LP_CODIGO		1
#DEFINE LP_DESCRI		2
#DEFINE LP_ALIAS		3

#DEFINE ALIAS_TAB		1
#DEFINE ALIAS_QCDOC		2
#DEFINE ALIAS_QCDATA	3
#DEFINE ALIAS_QCMOED	4
#DEFINE ALIAS_QCVLRD	5
#DEFINE ALIAS_QCCORR	6
#DEFINE ALIAS_EXECUT	7

// ESTRUTURA DE DADOS DA ARRAY __AFILTROS
#DEFINE FILTRO_DTINI	1
#DEFINE FILTRO_DTFIM	2
#DEFINE FILTRO_MOEDA	3
#DEFINE FILTRO_LCONF	4
#DEFINE FILTRO_DIVER	5
#DEFINE FILTRO_FILALL	6
#DEFINE FILTRO_LSEQUEM	7

// Array principal para montagem e manipulação da tela.
Static __aDadosMod	:= {}

// Array contendo os dados de filtros.
Static __aFiltros	:= {}
Static __aFiliais	:= {cFilAnt}
Static __aTmpFil	:= {}

Static nQtdEntid	:= Nil

Static __lConOutR	:= Nil


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : Ctbc661
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : Rotina de Rastreamento de lançamentos a partir da origem do 
//±              : Lançamento. Ex. Financeiro, Compras, Estoque, etc... 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Function Ctbc661()
Local nIx	:= 0

Private aRotina		:= MenuDef()

Private aHeaderOri	:= {}
Private aHeaderDes  := {}

Private cAliasOri	:= ""
Private cAliasDes	:= ""

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

If __lConOutR == Nil
	__lConOutR := FindFunction("CONOUTR")
EndIf


AtuCTL()

If nQtdEntid == NIL
	nQtdEntid := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

cAliasOri	:= CriaTmpOri( @aHeaderOri ) 
cAliasDes	:= CriaTmpDes( @aHeaderDes ) 

If Ctbc661A( cEmpAnt, @__aFiltros, @__aFiliais )
	Ctbc661Dlg()
Endif

If !Empty( cAliasOri )
	DeleteTmp( cAliasOri )
Endif
If !Empty( cAliasDes )
	DeleteTmp( cAliasDes )
Endif

CTDelTmpFil()
For nIx := 1 TO Len( __aTmpFil )
	CtbTmpErase( __aTmpFil[nIx] )
Next

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : Ctbc661Dlg
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : Efetua a montagem da tela (FwLayer, FwBrowse, xTree)
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function Ctbc661Dlg()
Local oDlg
Local oFWLayer, oWin01, oWin02, oWin03
Local oBarTree, oButtonBar 
Local oFont

Local aArea			:= GetArea()
Local aSize 		:= MsAdvSize(,.F.,400)

Local bParam		:= {|| Iif( CTBC661AP( @__aFiltros ),RefreshTela(oBrwWin02, oBrwWin03), .F. )  }
Local bSair			:= {|| oDlg:End() }

Local bActHide		:= {|| oWin02:Hide() , oWin03:Hide() }
Local bAction		:= {|| MsgRun(STR0002,"",{||RefreshTela(oBrwWin02, oBrwWin03),oWin02:Show(),oWin03:Show()} ) } //"Filtrando Dados, aguarde..."
Local bDbCOri		:= {|| RastreaOri()}
Local bDbCDes		:= {|| RastreaDes()}
Local bConfAll		:= {|| ConfTudo( Substr( oTree:GetCargo(),4,2) ),RefreshTela(oBrwWin02, oBrwWin03) }

Local bMarkAll		:= {|| MarkOnOffAll(),oBrwWin02:Refresh() }
Local nIx			:= 0

Private oBrwWin02, oBrwWin03

SetKey(VK_F12,bParam)

// retorna a array __aDadosMod para a montagem dos componentes da tela
If !CtbGetMod()
	MsgAlert( STR0003 ) //'Erro! Não foi encontrado nenhum lançamento padrão configurado.'
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MONTAGEM DA TELA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE DIALOG oDlg TITLE ""  FROM aSize[7],0 to aSize[6],aSize[5]  PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria instancia do fwlayer³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oFWLayer := FWLayer():New()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa componente passa a Dialog criada,o segundo parametro é para ³
//³criação de um botao de fechar utilizado para Dlg sem cabeçalho 		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oFWLayer:Init( oDlg, .T. )

// Efetua a montagem das colunas das telas
oFWLayer:AddCollumn( "Col01", 20, .T. )
oFWLayer:AddCollumn( "Col02", 80, .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria a window passando, nome da coluna onde sera criada, nome da window			 	³
//³ titulo da window, a porcentagem da altura da janela, se esta habilitada para click,	³
//³ se é redimensionada em caso de minimizar outras janelas e a ação no click do split 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oFWLayer:AddWindow( "Col01", "Win01", STR0004			, 100 , .F., .T.,	 			,,) 		 //'Modulo/Processo'
oFWLayer:AddWindow( "Col02", "Win02", STR0005			, 60  , .F., .T., {|| .T. }	,,) //'Origem'
oFWLayer:AddWindow( "Col02", "Win03", STR0006			, 40  , .F., .T., {|| .T. }	,,) //'Destino'

oFWLayer:SetColSplit( "Col01", CONTROL_ALIGN_RIGHT,, {|| .T. } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel 1					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWin01	:= oFWLayer:GetWinPanel('Col01','Win01')

//--------------------------------
//Adiciona a arvore no painel 1
//--------------------------------
oTree	:= Xtree():New(00,00,oWin01:NCLIENTHEIGHT*.48,oWin01:NCLIENTWIDTH*.50, oWin01)
CriaArvore( oTree, bAction, bActHide )

//--------------------------------
//Adiciona as barras dos botões
//--------------------------------
DEFINE BUTTONBAR oBarTree SIZE 10,10 3D BOTTOM OF oWin01
oButtTree		:= thButton():New(01,01, STR0007, oBarTree,  bParam	,30,20,) //'Parametros'
oButtTree		:= thButton():New(01,01, 'Conf. Automática', oBarTree,  bConfAll	,50,20,)
oButtTree		:= thButton():New(01,01, STR0008, oBarTree,  bSair	,30,20,) //'Sair'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel 2					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWin02 := oFWLayer:getWinPanel('Col02','Win02')

//--------------------------------
//Adiciona o browse no painel 2
//--------------------------------
bColor02 := { || Iif( !Empty(( cAliasOri )->DTCONF) , 'BR_VERDE' , Iif( !Empty( ( cAliasOri)->QCDOC ) .And. ( cAliasOri)->CT2_RECNO <> 0 ,'BR_AMARELO', Iif( !Empty( ( cAliasOri)->QCDOC ) .And. ( cAliasOri)->CT2_RECNO==0,'BR_VERMELHO',Iif( Empty( ( cAliasOri)->QCDOC ) .And. ( cAliasOri)->CT2_RECNO <> 0,	'BR_PRETO','BR_BRANCO' ) ) ) ) }

DEFINE FWBROWSE oBrwWin02 DATA TABLE ALIAS (cAliasOri) OF oWin02 
ADD MARKCOLUMN   oColumn DATA { || Iif(( cAliasOri )->CV3_FLAG ,'LBOK', 'LBNO' ) } DOUBLECLICK { |oBrwWin02| MarkOnOff() } HEADERCLICK { || MarkOnOffAll() } OF oBrwWin02		
ADD STATUSCOLUMN oColumn DATA bColor02 DOUBLECLICK { |oBrwWin02| /* Função executada no duplo clique na coluna*/ } OF oBrwWin02		

LoadBrowse(cAliasOri, aHeaderOri, oBrwWin02 , bDbCOri)

oBrwWin02:SetChange ( {|| FiltraDestino( (cAliasOri)->CV3_SEQUEN, (cAliasOri)->CT2_RECNO ), oBrwWin03:Refresh( .T. ) } )

//--------------------------------
//Adiciona as barras dos botões
//--------------------------------
DEFINE BUTTONBAR oButtonBar SIZE 10,10 3D BOTTOM OF oWin02
If Subs(Upper(ACBROWSE),4,1)=="X" .Or. Subs(Upper(ACBROWSE),5,1)=="X"
	oButtTree := thButton():New(01,01, STR0009 , oButtonBar,  bMarkAll  ,50,20,) //"Marcar(Des) Todos"
EndIf

For nIx := 1 TO Len( aRotina )
    If (nIx < 3 .And. (Subs(Upper(ACBROWSE),4,1)=="X") .Or. (Subs(Upper(ACBROWSE),5,1)=="X")) .Or. nIx == 3
		oButtTree := thButton():New(01,01, aRotina[nIx,1] , oButtonBar,  &( "{|| " + aRotina[nIx,2] + "}" )  ,30,20,) //WHEN .T. Substr(cAcesso,50,1) == "S"
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel 3					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWin03 := oFWLayer:getWinPanel('Col02','Win03')

//--------------------------------
//Adiciona o browse no painel 2
//--------------------------------
DEFINE FWBROWSE oBrwWin03 DATA TABLE ALIAS (cAliasDes) OF oWin03 
ADD STATUSCOLUMN oColumn DATA { || If( !Empty(( cAliasDes)->CT2_DTCONF ),'BR_VERDE','BR_AMARELO') } DOUBLECLICK { |oBrwWin03| /* Função executada no duplo clique na coluna*/ } OF oBrwWin03		

LoadBrowse(cAliasDes, aHeaderDes, oBrwWin03, bDbCDes)

//Esconde os dados dos paineis 2 e 3 ao iniciar
oWin02:Hide()
oWin03:Hide()

ACTIVATE DIALOG oDlg CENTERED

RestArea( aArea )

Return  

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : CriaArvore
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : Cria a arvore (Pai e Filho) do painel 1 no xTree
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function CriaArvore( oTree, bAction, bActHide )
Local aModulo		:= RetModName()
Local aAlias 		:= {}

Local nYx, nIX
Local cCargo		:= "MOD"
Local cCargoMod		:= ""
Local cModAux		:= ""
Local cAliasMod		:= ""

oTree:BeginUpdate()
oTree:Reset()

oTree:AddTree( STR0010,"IndicatorCheckBox","IndicatorCheckBoxOver",cCargo,bActHide) //'Origem da Contabilização'

If Len(__aDadosMod) > 0
	For nIx := 1 To Len(__aDadosMod)
		
		nPos := Ascan( aModulo, {|x| x[1] = Val( __aDadosMod[nIx][RT_MODULO] ) } )
		
		If nPos <> 0
			cCargoMod	:= cCargo+ __aDadosMod[nIx][RT_MODULO] 
			
			oTree:TreeSeek(cCargo)
			oTree:AddTree(	StrZero(aModulo[nPos][1],2) + " - " + aModulo[nPos][3],; //descricao do node
							aModulo[nPos][5], ; //bitmap fechado
							aModulo[nPos][5],; //bitmap aberto
							cCargoMod , ;  //cargo (id)
							/*bAction*/ ; //bAction - bloco de codigo para exibir
						 )
			

			If Len( __aDadosMod[nIx][RT_LP] ) > 0
				
				For nYx := 1 TO Len( __aDadosMod[nIx][RT_LP] )
					
					oTree:TreeSeek(cCargoMod)
					oTree:AddTree(	__aDadosMod[nIx][RT_LP][nYx][LP_CODIGO]+ " - " + Alltrim(__aDadosMod[nIx][RT_LP][nYx][LP_DESCRI]),; //descricao do node
									"IndicatorCheckBox", ; //bitmap fechado
									"IndicatorCheckBoxOver",; //bitmap aberto
									cCargoMod +	__aDadosMod[nIx][RT_LP][nYx][LP_CODIGO] , ;  //cargo (id)
									bAction ; //bAction - bloco de codigo para exibir
								 )
					


					oTree:EndTree()
				Next
			EndIf
			
			oTree:EndTree()
		Endif
	Next
Endif
    
oTree:EndUpdate()
oTree:Refresh()

Return oTree

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : MenuDef
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : Carrega a estrutura de menu da tela
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function MenuDef()
Local aRotina := {}

aAdd(aRotina,{STR0011,"Conferir(.T.)"	,0, 4	})	//'Conferir'###'Conferir'
aAdd(aRotina,{STR0012,"Conferir(.F.)"	,0, 5	})	//'Reverter'###'Reverter'
aAdd(aRotina,{STR0013,"CTC661Leg()"		,0, 2	})	//"Legenda"###"Legenda"

Return aRotina
                    

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : MenuDef
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : Carrega a estrutura de menu da tela
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CTC661Leg()

Local aCores := {	{'BR_VERDE'   , STR0014	},; //"Documentos conferidos"
				 	{'BR_AMARELO' , STR0015	},; //"Docs. corretos sem conf."
				 	{'BR_VERMELHO', STR0016	},; //"Docs. desbalanceados ORIGEM->DESTINO"
				 	{'BR_PRETO'   , STR0017	},; //"Docs. desbalanceados DESTINO->ORIGEM"
				 	{'BR_BRANCO'  , STR0018	}; //"Documentos com erro"
				 	}

BrwLegenda(STR0019,STR0013,aCores) //"Rastreamento de lançamentos"###"Legenda"

Return()

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : RefreshTela
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : Carrega todos os componentes do FWLayer
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function RefreshTela(oBrwWin02, oBrwWin03)
Local bBlock	:= ErrorBlock( { |e| ChecErro(e) } )
Local cLP		:= ""
Local cModulo	:= ""
Local cSequem	:= ""
Local cRecDes	:= 0
Local lRet		:= .F.

If ValType(oTree:GetCargo()) == 'C'
	cModulo := Substr( oTree:GetCargo(),4,2)
	cLP 	:= Substr( oTree:GetCargo(),6,3)
Endif

bBlock := ErrorBlock( { |e| ChecErro(e) } )
BEGIN SEQUENCE
	If ! Empty( cLP ) .And. ! Empty( cModulo )
		FiltraOrigem( cModulo, cLP , cAliasOri )

		If ( cAliasOri)->( !Eof() )
			cSequem := (cAliasOri)->CV3_SEQUEN
			cRecDes	:= (cAliasOri)->CT2_RECNO
		Endif
		
		FiltraDestino( cSequem, cRecDes )
	Endif
RECOVER
	lRet := .F.
END SEQUENCE
ErrorBlock(bBlock)

oBrwWin02:Refresh( .T. )
oBrwWin03:Refresh( .T. )

Return lRet

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : LoadBrowse
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : Carrega a estrutura de dados no FWBrowse
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function LoadBrowse(cAlias, aHeader, oBrowse, bDbClik)
Local aCampos	:= {}
Local aStru		:= {}
Local nI

Default			:= {|| .T. }

oBrowse:DisableLocate() 

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
//± Data          : 11/08/2012
//± Uso           : 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function MarkOnOff( lMsg )
Local lMarca	:= .F.

Default lMsg	:= .T.

If (cAliasOri)->(!Eof())
	If !Empty( ( cAliasOri)->DTCONF )
		If lMsg
			MsgAlert( STR0020 ) //'Documento já conferido!'
		Endif
		lMarca := .F.
	ElseIf !Empty( (cAliasOri)->QCDOC ) .And. (cAliasOri)->CT2_RECNO <> 0
		lMarca := .T.

	ElseIf !Empty( (cAliasOri)->QCDOC ) .And. (cAliasOri)->CT2_RECNO == 0
		lMarca := .F.
		If lMsg
			MsgAlert( 'Documento sem lançamento contábil!' )
		Endif

	ElseIf Empty( (cAliasOri)->QCDOC ) .And. (cAliasOri)->CT2_RECNO <> 0
		IF lMsg
			lMarca := MsgYesNo( 'Documento desbalanceado! Deseja realmente marcar para conferencia?' )
		Else
			lMarca := .F.
		Endif

	Endif

	If lMarca
		Reclock( cAliasOri , .F. )
		Replace (cAliasOri)->CV3_FLAG WITH !(cAliasOri)->CV3_FLAG
		(cAliasOri)->( MsUnLock() )
	Endif
EndIf

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : MarkOnOffAll
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function MarkOnOffAll()
Local aArea := GetArea()
Local lMark	:= .F.

nRecnoOri := (cAliasOri)->(Recno())

DbSelectArea(cAliasOri)
(cAliasOri)->(DbGoTop())

lMark	:= (cAliasOri)->CV3_FLAG

While (cAliasOri)->(!Eof())

	MarkOnOff(.F.)
	
	(cAliasOri)->(DbSkip())
EndDo

DbSelectArea( cAliasOri )
(cAliasOri)->(DbGoTo(nRecnoOri))

RestArea(aArea)

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : Conferir
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function Conferir(lConf)
Local aSizeDlg	:= FWGetDialogSize(oMainWnd)

Local bUpdate	:= {|| Iif( !Empty(cObs) .And. GravaConf(lConf,cObs),oDlg:End(),MsgAlert( STR0022) )} //'Erro na gravação da conferência.'
Local bEndWin	:= {|| oDlg:End()}							
Local bEnchBar	:= {|| EnchoiceBar(oDlg,bUpdate,bEndWin) }

Local cObs      := CriaVar("CT2_OBSCNF")              
Local cUsrConf	:= CriaVar("CT2_USRCNF")
Local dDtConf	:= CriaVar("CT2_DTCONF")
           
Local nHeight	:= aSizeDlg[3] * 0.40
Local nWidth    := aSizeDlg[4] * 0.50

Local oDlg		:= Nil
Local oFnt2		:= Nil
Local oObs 		:= Nil
Local oUsrConf	:= Nil
Local oDtConf	:= Nil

Default lConf	:= .T.
                                        
If !lConf
	cUsrConf	:= (cAliasOri)->USRCNF
	dDtConf		:= (cAliasOri)->DTCONF
	cObs		:= (cAliasOri)->OBSCONF
Else
	cUsrConf	:= cUsername
	dDtConf		:= MsDate()
Endif

DEFINE FONT oFnt2 	NAME "Courier New" 	SIZE 0,14
  
DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight, nWidth TITLE STR0023 PIXEL STYLE DS_MODALFRAME of oMainWnd  //'Conferencia do Documento'

@ 023,011  SAY OemToAnsi(STR0024)	PIXEL OF oDlg SIZE 50,9			 //"Conferido Por:"
@ 030,010  GET oUsrConf VAR cUsrConf When .F. OF oDlg SIZE 100,10	PIXEL FONT oFnt2 COLOR CLR_BLACK,CLR_HGRAY

@ 043,011  SAY OemToAnsi(STR0025)	PIXEL OF oDlg SIZE 50,9			 //"Conferido Em:"
@ 050,010  GET oDtConf VAR dDtConf When .F. OF oDlg SIZE 50,10	PIXEL FONT oFnt2 COLOR CLR_BLACK,CLR_HGRAY

@ 063,011  SAY OemToAnsi(STR0026)	PIXEL OF oDlg SIZE 50,9			 //"Observação"
@ 070,010  GET oObs VAR cObs When lConf OF oDlg MEMO SIZE 250,50	PIXEL FONT oFnt2 COLOR CLR_BLACK,CLR_HGRAY

oDlg:Activate(,,,.T.,,,bEnchBar)

oBrwWin02:Refresh()
oBrwWin03:Refresh()

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : ConfTudo
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : Efetua a conferencia automatica dos registros OKs
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function ConfTudo( cModulo )
Local aArea		:= GetArea()
Local cLp		:= ""
Local cConfst	:= "1"
Local cObsCnf	:= "CONFERENCIA AUTOMATICA"
Local cUsrCnf	:= cUsername
Local dDtConf	:= MsDate()
Local cHrConf	:= Time()
Local nPos    := 0

Local lConfAll	:= .F.

Local nIx		:= 0

Default cModulo	:= ''

If Empty( cModulo )
	Return
Endif

If MsgYesNo( "Deseja Realmente conferir todos os itens do ambiente '" + cModulo + "'?" )
	nPos := Ascan( __aDadosMod, {|x| x[1] = cModulo } )

	For nIx := 1 To Len( __aDadosMod[nPos][RT_LP] )

		cLp := __aDadosMod[nPos][RT_LP][nIx][LP_CODIGO]

		If FiltraOrigem( cModulo, cLP, cAliasOri)	

			DbSelectArea(cAliasOri)
			(cAliasOri)->(DbGoTop())
			While (cAliasOri)->(!Eof())
			
				If !Empty( ( cAliasOri)->QCDOC ) .And. ( cAliasOri)->CT2_RECNO <> 0
					If (cAliasOri)->CV3_RECNO <> 0
						CV3->( dbGoTo( (cAliasOri)->CV3_RECNO ) )
					EndIf
					GrvConf(cUsrcnf,dDtconf,cObsCnf,cHrConf,cConfst)
				Endif
			
				(cAliasOri)->(DbSkip())
			Enddo
		Endif
	Next

Endif

RestArea( aArea )

Return


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : RastreaOri
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function RastreaOri()
Local aArea			:= GetArea()
Local aRotinaOri	:= aClone( aRotina )

Local cRotina  		:= ''
Local cFilOrig		:= ''
Local cTabOri		:= ''

Local nRecOri		:= 0
Local nRecnoAlias	:= 0

Private cCadastro	:= ''

aRotina := {}

DbSelectArea( cAliasOri )
nRecnoAlias	:= ( cAliasOri )->(Recno())
cTabOri		:= ( cAliasOri )->CV3_TABORI

DbSelectArea( "CV3" )
DbGoto( ( cAliasOri )->CV3_RECNO )

If CV3->( !Eof() )

	cRecOri		:= CV3->CV3_RECORI

	If !Empty(cTabOri) .and. !Empty(cRecOri)

		// Substituir pela array
		DbSelectArea("CTL")
		DbSetOrder(1)
		DbSelectArea("CT5")
		DbSetOrder(1)

		If CT5->(dbSeek(xFilial("CT5")+CV3->CV3_LP,.F.)) .and. !Empty(CT5->CT5_ROTRAS)
			// ROTINA DE RASTREAMENTO SE HOUVER O CAMPO NO CT5
			cRotina := CT5->CT5_ROTRAS
		ElseIf CTL->(dbSeek(xFilial("CTL")+CV3->CV3_LP)) .AND. !Empty(CTL->CTL_EXECUT) /// SE HOUVER CTL CONFIGURADO PARA O LANÇAMENTO...
			// ROTINA DE RASTREAMENTO SE HOUVER NO CTL
			cRotina := CTL->CTL_EXECUT
		Else
			// SE NÃO TIVER EXECUTA ROTINA PADRAO AXVISUAL
			cRotina := "AxVisual('" + cTabOri + "',Recno(),2)"
		EndIf
		
		DbSelectArea("SX2")
		DbSetOrder(1)

		If DbSeek(cTabOri)
			cCadastro := X2Nome()
			cCadastro += STR0032 + Alltrim(cRecOri)  //" - Registro: "
		EndIf
		
		DbSelectArea(cTabOri)
		nRecOri := int(val(cRecOri))
		DbGoTo(nRecOri)

		If CV3->CV3_TABORI $ 'SD1|SD2'
			If CV3->CV3_TABORI == 'SD1'
				dbSelectArea("SF1")
				dbSetOrder(1)
				dbSeek(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_TIPO))
				dbSelectArea("SD1")
			Else
				dbSelectArea("SF2")
				dbSetOrder(2)
				dbSeek(SD2->(D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_DOC+D2_SERIE))
				dbSelectArea("SD2")
			EndIf
		EndIf

		If (cTabOri)->( !Eof() ) .And. (cTabOri)->( Recno() ) == nRecOri

			DbSetOrder(1)
			If Deleted()
				cCadastro := STR0033 + cCadastro //" já excluido. "
			EndIf

			cFilOrig := cFilAnt
			If !Empty( cTabOri )
				cFilAnt := &( PrefixoCpo(cTabOri) + "_FILIAL" )
			EndIf

			// Executa a rotina cadatrada para rastreamento.
			&(cRotina)

			cFilAnt := cFilOrig
		EndIf

	EndIf
EndIf

aRotina := aClone( aRotinaOri )

DbSelectArea( cAliasOri )
DbGoto( nRecnoAlias )

RestArea( aArea )

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : RastreaDest
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function RastreaDest()
Local aArea			:= GetArea()
Local aRotinaOri	:= aClone( aRotina )

Local nRecDes		:= (cAliasDes)->(Recno())

Private __lCusto	:= .F.
Private __lItem		:= .F.
Private __lCLVL		:= .F.
Private cCadastro	:= ""
Private cSeqCorr	:= ""
Private aTotRdpe	:= {{0,0,0,0},{0,0,0,0}}
Private aCtbEntid

aRotina := {	{STR0034 ,"AxPesqui"  , 0 , 1,,.F.},; // "Pesquisar" //"Pesquisar"
				{STR0035 ,"Ctba101Cal", 0 , 2}} // "Visualizar" //"Visualizar"

DbSelectArea( "CT2" )
DbGoTo( (cAliasDes)->CT2_RECNO )

If CT2->( !Eof() )
	cSeqCorr := CT2_SEGOFI
	Ctba101Lan("CT2",CT2->(Recno()),2,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,0,CT2_LP,"",,,CT2_VALOR)
Endif

DbSelectArea( cAliasDes )
DbGoTo( nRecDes )

aRotina := aClone( aRotinaOri )

RestArea( aArea )

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//
//                    MONTAGEM DE ESTRUTURA DE DADOS
//
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CriaTmpOri
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : Cria a tabela temporaria a ser usada no FwBrowse de Origem
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CriaTmpOri( aHeader )
Local aChvOri   := {}
Local aCampos	:= {}

Local cAliasOri := ""

Local nX		:= 0

Default aHeader	:= {}

aObrigat := {"CV3_FILIAL","CV3_SEQUEN","CV3_LP","CV3_LPSEQ","CV3_DC","CV3_DEBITO","CV3_CREDIT","CV3_VLR01","CV3_HIST","CV3_CCD","CV3_CCC","CV3_ITEMD","CV3_ITEMC","CV3_CLVLDB","CV3_CLVLCR","CV3_TABORI"}

For nX := 5 TO nQtdEntid
	aAdd( aObrigat , "CV3_EC" + StrZero(nX,2) + "DB" )
	aAdd( aObrigat , "CV3_EC" + StrZero(nX,2) + "CT" )
Next 

aAdd( aHeader, { STR0027		, "QCDOC"	, "C", 250,0,"@!" } ) //"Documento de Origem"
Aadd( aCampos, { "QCDOC","C",250,0} )

aAdd( aHeader, { STR0028		, "QCDATA"	, "D",   8,0,"" } ) //"Data Doc. Origem"
Aadd( aCampos, { "QCDATA","D",8,0} )

/*
aAdd( aHeader, { STR0029		, "QCMOED"	, "C",   2,0,"" } ) //"Moeda de Origem"
Aadd( aCampos, { "QCMOED","C",2,0} )
*/

aAdd( aHeader, { STR0030		, "QCVLRD"	, "N",  20,2,PesqPict('CT2','CT2_VALOR') } ) //"Valor de Origem"
Aadd( aCampos, { "QCVLRD","N",20,2} )

// carrega os campos da CV3 a partir do dicionario
CtbLoadSx3( 'CV3', aObrigat, @aHeader, @aCampos )

aAdd( aHeader, { STR0024		, "USRCNF"	, "C",  20,0,"" } ) //"Conferido Por:"
Aadd( aCampos, { "USRCNF","C",20,0} )

aAdd( aHeader, { STR0025		, "DTCONF"	, "C",  8,0,"" } ) //"Conferido Em:"
Aadd( aCampos, { "DTCONF","D",8,0} )

aAdd( aHeader, { STR0031		, "OBSCONF"	, "C",250,0,"" } ) //"Conf. Obs.:"
Aadd( aCampos, { "OBSCONF"   ,"C",250,0} )

Aadd( aCampos, { "CV3_RECNO" ,"N",9,0} ) 
Aadd( aCampos, { "CT2_RECNO" ,"N",9,0} ) 
Aadd( aCampos, { "CV3_FLAG"  ,"L",1,0} ) 

// Montagem da Matriz aChvDes ( Chaves de Busca )
Aadd( aChvOri, "QCDOC+DTOS(QCDATA)+CV3_LP" ) // 'Documento de Origem + Data de Origem + L.Padrão' 

If ExistBlock( "CTC661CORI" )
	ExecBlock( "CTC661CORI" , .F. , .F. , {aCampos, aChvOri})			
Endif

// Cria o temporario a ser utilizado na tela.
cAliasOri := CriaTmp( aCampos, aChvOri )

RETURN cAliasOri

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao	   	  : CriaTmpDes
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : Cria a tabela temporaria a ser usada no FwBrowse de Destino
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CriaTmpDes(aHeader)
Local aChvDes   := {}
Local aCampos	:= {}
Local aObrigat	:= {}

Local cAliasDes := ""

Local nX		:= 0

Default aHeader	:= {}

// campos a serem exibidos
aObrigat := {"CT2_FILIAL"	,"CT2_LP"		,"CT2_DATA"		,"CT2_LOTE"		,"CT2_SBLOTE"	,"CT2_DOC"		,"CT2_LINHA",;
		     "CT2_SEQLAN"	,"CT2_MOEDLC"	,"CT2_TPSALD"	,"CT2_DC"		,"CT2_DEBITO"	,"CT2_CREDIT"	,"CT2_VALOR",;
			 "CT2_HIST"		,"CT2_SEQUEN"	,"CT2_CCD"		,"CT2_CCC"		,"CT2_ITEMD"	,"CT2_ITEMC"	,"CT2_CLVLDB",;
			 "CT2_CLVLCR"	,"CT2_KEY"		,"CT2_DTCONF"	,"CT2_USRCNF"	,"CT2_DTCONF"	}

For nX := 5 TO nQtdEntid
	aAdd( aObrigat , "CT2_EC" + StrZero(nX,2) + "DB" )
	aAdd( aObrigat , "CT2_EC" + StrZero(nX,2) + "CT" )
Next 

// carrega os campos da CT2 a partir do dicionario
CtbLoadSx3( 'CT2', aObrigat, @aHeader, @aCampos )
	
Aadd( aCampos, { "CT2_RECNO","N",9,0} )

// Montagem da Matriz aChvDes ( Chaves de Busca )
Aadd( aChvDes, "CT2_RECNO"          ) // 'Registro'
Aadd( aChvDes, "CT2_SEQUEN+CT2_KEY" ) // 'Sequencia + Chave' )
Aadd( aChvDes, "CT2_DC+CT2_DEBITO+CT2_CREDIT+CT2_CCD+CT2_CCC+CT2_ITEMD+CT2_ITEMC+CT2_CLVLDB+CT2_CLVLCR+CT2_TPSALD") // 'Tipo Lcto + Debito + Credito + C.CustoD + C.CustoC + ItemD + ItemC + ClasseVlD + ClasseVlC + Tipo Saldo'

If ExistBlock( "CTC661CDES" )
	ExecBlock( "CTC661CDES" , .F. , .F. , {aCampos, aChvDes})			
Endif

// Cria o temporario a ser utilizado na tela.
cAliasDes := CriaTmp( aCampos, aChvDes )

RETURN cAliasDes


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao	   	  : CriaTmp
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : Cria a tabela temporaria a ser usada no FwBrowse no Banco
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CriaTmp( aCampos, aChaves )
Local aArea		:= GetArea()

Local cArq		:= ""
Local cChave	:= ""

Local nIx		:= 0

Default aChaves := {}

cArq	:= CriaTrab( , .F. )
MsCreate(cArq, aCampos, "TOPCONN")
// Sleep(1000)

dbUseArea( .T., "TOPCONN", cArq, cArq, .F., .F. )

If Len( aChaves ) > 0
	// Efetua a criação da tabela no banco
	For nIx := 1 TO Len( aChaves )
		cChave := aChaves[nIx]
		
		cOrdName := cArq + StrZero( nIx ,2)
		If ( !TcCanOpen(cArq,cOrdName) )
			INDEX ON &(ClearKey( cChave )) TO &(cOrdName)
   		EndIf

		DbSetIndex(cOrdName)
		DbSetNickName(OrdName(nIx),cOrdName)
	Next nIx
	
	DbSelectArea( cArq )
	DbSetOrder(1)
Endif

RestArea(aArea)

Return cArq

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : DeleteTmp
//± Autor         : Renato Campos
//± Data          : 11/08/2012
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
//± Data          : 11/08/2012
//± Uso           : Carrega os campos da SX3 para a criação do temporario
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function CtbLoadSx3( cAlias, aObrigat, aHeader, aCampos )
Local aArea		:= GetArea()

Default aHeader := {}

// Montagem da matriz aCampos
DbSelectArea("SX3")
SX3->( DbSetOrder(1) )
SX3->( MsSeek(cAlias) )

While SX3->( !EOF() .And. (x3_arquivo == cAlias) )

	If ( aScan( aObrigat , Alltrim(x3_campo) ) > 0 ) .and. cNivel >= x3_nivel
		aAdd( aHeader, { TRIM(X3TITULO()) , SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE, x3Uso(x3_usado) } )
		aAdd( aCampos, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_DECIMAL } )
	Endif

	SX3->( DbSkip() )
EndDO

RestArea( aArea )

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//
//                      FILRAGEM E GRAVACAO DE DADOS
//
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CtbGetMod 
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : Busca os dados dos modulos, tabelas relacionadas e LPs
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CtbGetMod()

Local aArea		:= GetArea()
Local aArray	:= {}
Local cTmpFil	:= ""
Local cQuery	:= ""
Local cAliasMod	:= GetNextAlias()

Local nCont		:= 0
Local nContLp	:= 0

//-------------------------------------------------------------------
// ESTRUTURA DE DADOS DA ARRAY __ADADOSMOD
//
// Nivel 1
// Array[1] 	:= RT_MODULO 	--> Char
// Array[2] 	:= RT_LP 		--> Array
// 
// Nivel 2
// Array[2,1] 	:= LP_CODIGO	--> Char
// Array[2,2] 	:= LP_DESCRI	--> Char
// Array[2,3] 	:= LP_ALIAS		--> Array
// 
// Nivel 3
// Array[2,3,1] := ALIAS_TAB	--> Char
// Array[2,3,2] := ALIAS_QCDOC	--> Char
// Array[2,3,3] := ALIAS_QCDATA	--> Array
// Array[2,3,4] := ALIAS_QCMOED	--> Numeric
// Array[2,3,5] := ALIAS_QCVLRD	--> Float
// Array[2,3,6] := ALIAS>QCCORR	--> Char
//-------------------------------------------------------------------

cQuery += "SELECT CVA_MODULO AS MODULO"
cQuery += "     , CVA_CODIGO AS CODLP"
cQuery += "     , CVA_DESCRI AS DESCRLP"
cQuery += "     , IsNull( CTL_ALIAS , ' ' ) AS ALIAS " 
cQuery += "     , IsNull( CTL_QCDOC , ' ' ) AS QCDOC"
cQuery += "     , IsNull( CTL_QCDATA, ' ' ) AS QCDATA"
cQuery += "     , IsNull( CTL_QCMOED, ' ' ) AS QCMOED"
cQuery += "     , IsNull( CTL_QCVLRD, ' ' ) AS QCVLRD"
cQuery += "     , IsNull( CTL_QCCORR, ' ' ) AS QCCORR"
cQuery += "     , IsNull( CTL_EXECUT, ' ' ) AS EXECUT"
cQuery += "  FROM " + RetSqlName( 'CVA' ) + " CVA" 
cQuery += "  LEFT OUTER JOIN " + RetSqlName( 'CTL' ) + " CTL"
cQuery += "    ON CTL.CTL_LP = CVA.CVA_CODIGO"

// filtro de filial da CTL
If !__aFiltros[FILTRO_FILALL]
	cQuery += " AND CTL.CTL_FILIAL " + GetRngFil( __aFiliais, 'CTL', .T., @cTmpFil)
	aAdd(__aTmpFil, cTmpFil)
Endif
cQuery += "   AND CTL.D_E_L_E_T_ = ' '"

cQuery += " WHERE "

// filtro de filial da CVA
If !__aFiltros[FILTRO_FILALL]
	cQuery += "  CVA.CVA_FILIAL " + GetRngFil( __aFiliais, 'CVA', .T., @cTmpFil)
	cQuery += "   AND "
	aAdd(__aTmpFil, cTmpFil)
Endif
cQuery += "   CVA.D_E_L_E_T_ = ' '"

cQuery += "   AND Exists( SELECT CT5.CT5_LANPAD FROM " + RetSqlName( 'CT5' ) + " CT5"

// filtro de CT5
cQuery += "                WHERE "
If !__aFiltros[FILTRO_FILALL]
	cQuery += "  CT5.CT5_FILIAL " + GetRngFil( __aFiliais, 'CT5', .T., @cTmpFil)
	cQuery += " AND "
	aAdd(__aTmpFil, cTmpFil)
Endif
cQuery += "                  CT5.CT5_LANPAD = CVA.CVA_CODIGO"
cQuery += "                  AND CT5.D_E_L_E_T_ = ' ' )"

cQuery += " ORDER BY CVA_MODULO, CVA_CODIGO"

cQuery := ChangeQuery( cQuery )

// verifica se temporario está aberto e tenta fechalo
If Select( cAliasMod ) > 0
	DbSelectArea( cAliasMod )
	( cAliasMod )->( DbCloseArea() )
Endif

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasMod )

If Select( cAliasMod ) > 0
	DbSelectArea( cAliasMod )
	(cAliasMod)->(DbGoTop())

	nCont := 0
	While (cAliasMod)->(!Eof())
		nCont++	
		cModulo := (cAliasMod)->MODULO

		cCodLP	:= ""
		nContLP := 0
		
		// Nivel 1
		aAdd( aArray , { cModulo , {}} )

		While (cAliasMod)->MODULO == cModulo .And. (cAliasMod)->(!Eof())
			nContLP++
			cCodLP := (cAliasMod)->CODLP

			// Nivel 2
			aAdd( aArray[nCont][RT_LP] , {(cAliasMod)->CODLP , (cAliasMod)->DESCRLP,{}} )

			// Nivel 3
			aArray[nCont][RT_LP][nContLP][LP_ALIAS] := 	{ (cAliasMod)->ALIAS  ;
														 	, (cAliasMod)->QCDOC  ;
									     	 				, (cAliasMod)->QCDATA ;
															, (cAliasMod)->QCMOED ;
													    	, (cAliasMod)->QCVLRD ;
															, (cAliasMod)->QCCORR ;
															, (cAliasMod)->EXECUT ;
						    								}
		
			(cAliasMod)->(DbSkip())
		EndDo
	EndDo

	DbSelectArea(cAliasMod)	
	DbCloseArea()
Endif

If Len( aArray ) > 0
	__aDadosMod := aClone( aArray )
Endif

RestArea( aArea )

Return ( Len(__aDadosMod) > 0)


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : FiltraOrigem
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : Efetua a filtragem dos dados da Origem, escolhida na tree
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function FiltraOrigem( cModulo, cLP, cAliasOri, lMostraTudo )
Local aArea			:= GetArea()

Local cTmpFil		:= ""
Local cQuery		:= ""
Local cQueryAll		:= ""
Local cJoinCV3		:= ""
Local cWhereAlias	:= ""

Local cFilCV3		:= xFilial( 'CV3' )
Local cAliasTmp		:= GetNextAlias()
Local cAlias		:= ""
Local cFilAlias 	:= ""
Local cFilCpo		:= "" 

Local cQcDoc		:= ""
Local cQcData		:= ""
Local cQcMoed		:= ""
Local cQcVlrd		:= ""

Local lRet			:= .F.

Local nPos			:= 0
Local nPosLP		:= 0
Local nIx 			:= 0

Static cQueryCV3	:= ""

Default lMostraTudo := .T.

If Empty( cQueryCV3 )
	For nIx := 1 TO Len( aHeaderOri )
		If Substr(aHeaderOri[nIx][2],1,3) == "CV3"
			cQueryCV3 += ", CV3." + aHeaderOri[nIx][2] + ""
		Endif
	Next
Endif

// monta a regra de filtragem dos dados a serem exibidos.
// caso o alias de origem não tenha uma das condições atendidas pelo filtro (como campo de data) será utiizado da tabela CV3
// Para os casos da utilização da CV3, o filtro será aplicada diretamente no LEFT JOIN.
IF Len( __aFiltros ) > 0
	// Filtro das datas
	If !Empty( __aFiltros[FILTRO_DTINI] ) .And. !Empty( __aFiltros[FILTRO_DTFIM] )
		If !Empty( cQcData )
			cWhereAlias	+= " AND " + cAlias + "." + cQcData + " BETWEEN '" + Dtos(__aFiltros[FILTRO_DTINI]) + "' AND '" + Dtos(__aFiltros[FILTRO_DTFIM]) + "'"
		Else
			cJoinCV3 	+= " AND CV3.CV3_DTSEQ BETWEEN '" + Dtos(__aFiltros[FILTRO_DTINI]) + "' AND '" + Dtos(__aFiltros[FILTRO_DTFIM]) + "'"
		Endif
	ElseIf !Empty( __aFiltros[FILTRO_DTINI] )
		If !Empty( cQcData )
			cWhereAlias	+= " AND " + cAlias + "." + cQcData + " >= '" + Dtos(__aFiltros[FILTRO_DTINI]) + "'"
		Else
			cJoinCV3 	+= " AND CV3.CV3_DTSEQ >= '" + Dtos(__aFiltros[FILTRO_DTINI]) + "'"
		Endif

	ElseIf !Empty( __aFiltros[FILTRO_DTFIM] )
		If !Empty( cQcData )
			cWhereAlias	+= " AND " + cAlias + "." + cQcData + " <= '" + Dtos(__aFiltros[FILTRO_DTFIM]) + "'"
		Else
			cJoinCV3 	+= " AND CV3.CV3_DTSEQ <= '" + Dtos(__aFiltros[FILTRO_DTFIM]) + "'"
		Endif
	Endif

	If !Empty( __aFiltros[FILTRO_MOEDA] )
		cJoinCV3 += " AND CV3.CV3_MOEDLC IN ( '  ','" + __aFiltros[FILTRO_MOEDA] + "')"
	Endif
EndIf

// Limpa o temporario
If Select( cAliasOri ) > 0
	DbSelectArea( cAliasOri )
	Zap
Endif

nPos := Ascan( __aDadosMod, {|x| x[1] = cModulo } )

If nPos <> 0
	nPosLP := Ascan( __aDadosMod[nPos][RT_LP], {|x| x[1] = cLP } )
	
	If nPosLP <> 0

		If !Empty( __aDadosMod[nPos][RT_LP][nPosLp][LP_ALIAS][ALIAS_TAB])	
			cAlias		:= __aDadosMod[nPos][RT_LP][nPosLp][LP_ALIAS][ALIAS_TAB]
			cFilAlias 	:= xFilial( cAlias )
			cFilCpo		:= PrefixoCpo(cAlias) + "_FILIAL"
	

			cQcDoc	:= __aDadosMod[nPos][RT_LP][nPosLp][LP_ALIAS][ALIAS_QCDOC]
			cQcData	:= __aDadosMod[nPos][RT_LP][nPosLp][LP_ALIAS][ALIAS_QCDATA]
			cQcMoed	:= __aDadosMod[nPos][RT_LP][nPosLp][LP_ALIAS][ALIAS_QCMOED]
			cQcVlrd	:= __aDadosMod[nPos][RT_LP][nPosLp][LP_ALIAS][ALIAS_QCVLRD]
		Endif
    Endif
Endif
	
If !Empty( cAlias )
	cQuery := "SELECT CV3.R_E_C_N_O_ AS CV3_RECNO " 
	
	If !Empty( cQcDoc )
		cQuery += "," + ADMParSQL(cQcDoc) + "  AS QCDOC"
	Endif
	If !Empty( cQcData )
		cQuery += "," + ADMParSQL(cQcData) + "  AS QCDATA"
	Endif
	If !Empty( cQcMoed )
//		cQuery += "," + ADMParSQL(cQcMoed) + "  AS QCMOED"
	Endif
	If !Empty( cQcVlrd )
		cQuery += "," + ADMParSQL(cQcVlrd) + "  AS QCVLRD"
	Endif
	
	cQuery += cQueryCV3
	
	cQuery += "     , CT2.CT2_DTCONF AS DTCONF"	
	cQuery += "     , CT2.CT2_USRCNF AS USRCNF"
	cQuery += "     , CT2.CT2_OBSCNF AS OBSCONF"
	cQuery += "     , CT2.R_E_C_N_O_ AS CT2_RECNO"
	cQuery += "  FROM " + RetSqlName( cAlias ) + " " + cAlias
	
	If __aFiltros[FILTRO_DIVER] == 1
		cQuery += "  LEFT OUTER "
	Endif
	
	cQuery += "  JOIN " + RetSqlName( 'CV3' ) + " CV3 ON "

	If !__aFiltros[FILTRO_FILALL]
		cQuery += " CV3.CV3_FILIAL " + GetRngFil( __aFiliais, 'CV3', .T., @cTmpFil)
		cQuery += " AND "
		aAdd(__aTmpFil, cTmpFil)
	Endif

	cQuery += "     CV3.CV3_TABORI = '" + cAlias  + "'"

	If Upper(TcGetDb()) $ "ORACLE,DB2,INFORMIX"		// Sinal de concatencao nesses ambientes
		cQuery += "   AND NVL(TO_NUMBER(TRIM(CV3_RECORI)),0) = " + cAlias + ".R_E_C_N_O_"
	ElseIf  Upper(TcGetDb()) $ "POSTGRES"
		cQuery += "   AND COALESCE(CAST(TRIM(CV3_RECORI) AS INT),0) = " + cAlias + ".R_E_C_N_O_"
	Else
		cQuery += "   AND CONVERT(Int,CV3_RECORI) = " + cAlias + ".R_E_C_N_O_"
	Endif

	cQuery += "   AND CV3.CV3_DC <> '4'"
	cQuery += "   AND CV3.D_E_L_E_T_ = ''"
	cQuery += cJoinCV3

	cQuery += "  LEFT OUTER JOIN " + RetSqlName( 'CT2' ) + " CT2 ON " 
	
	If Upper(TcGetDb()) $ "ORACLE,DB2,INFORMIX"		// Sinal de concatencao nesses ambientes
		cQuery += " NVL(TO_NUMBER(TRIM(CV3_RECDES)),0) = CT2.R_E_C_N_O_"
	ElseIf  Upper(TcGetDb()) $ "POSTGRES"
		cQuery += "   COALESCE(CAST(TRIM(CV3_RECDES) AS INT),0) = CT2.R_E_C_N_O_"
	Else
		cQuery += " CONVERT(Int,CV3_RECDES) = CT2.R_E_C_N_O_"
	Endif

	// Filtra as filiais
	If !__aFiltros[FILTRO_FILALL]
		cQuery += " AND CT2.CT2_FILIAL " + GetRngFil( __aFiliais, 'CT2', .T., @cTmpFil)
		aAdd(__aTmpFil, cTmpFil)
	Endif

	cQuery += "   AND CT2.D_E_L_E_T_ = ''"

	cQuery += " WHERE " 

	// Filtra as filiais
	If !__aFiltros[FILTRO_FILALL]
		cQuery += " " + cAlias + "." + cFilCpo + " " + GetRngFil( __aFiliais, cAlias, .T., @cTmpFil)
		cQuery += "   AND "
		aAdd(__aTmpFil, cTmpFil)
	Endif

	cQuery += " " + cAlias + ".D_E_L_E_T_ = ''" 
	IF !Empty( cWhereAlias )
		cQuery += "   AND " + cWhereAlias
	Endif
	cQuery += " AND CV3_LP = '" + cLp + "'"
	cQuery += " AND CV3_RECDES <> ' ' "
	
	
	If __aFiltros[FILTRO_DIVER] == 1
		cQuery += " UNION ALL "
		
		cQuery += "SELECT CV3.R_E_C_N_O_ AS CV3_RECNO " 
		
		If !Empty( cQcDoc )
			cQuery += ",'" + Space(250) + "' AS QCDOC"
		Endif
		If !Empty( cQcData )
			cQuery += ",'" + Space(8) + "' AS QCDATA"
		Endif
		If !Empty( cQcMoed )
//			cQuery += ",'  ' AS QCMOED"
		Endif
		If !Empty( cQcVlrd )
			cQuery += ",0.00 AS QCVLRD"
		Endif
		
		cQuery += cQueryCV3
		
		cQuery += "     , CT2.CT2_DTCONF AS DTCONF"	
		cQuery += "     , CT2.CT2_USRCNF AS USRCNF"
		cQuery += "     , CT2.CT2_OBSCNF AS OBSCNF"
		cQuery += "     , CT2.R_E_C_N_O_ AS CT2_RECNO"
		cQuery += "  FROM " + RetSqlName( 'CV3' ) + " CV3"
		cQuery += "  LEFT OUTER JOIN " + RetSqlName( 'CT2' ) + " CT2 ON "

		// Filtra as filiais
		If !__aFiltros[FILTRO_FILALL]
			cQuery += " CT2.CT2_FILIAL " + GetRngFil( __aFiliais, 'CT2', .T., @cTmpFil)
			cQuery += " AND "
			aAdd(__aTmpFil, cTmpFil)
		Endif
	
		If Upper(TcGetDb()) $ "ORACLE,DB2,INFORMIX"		// Sinal de concatencao nesses ambientes
			cQuery += " NVL(TO_NUMBER(TRIM(CV3_RECDES)),0) = CT2.R_E_C_N_O_"			
		ElseIf  Upper(TcGetDb()) $ "POSTGRES"
			cQuery += " COALESCE(CAST(TRIM(CV3_RECDES) AS INT),0) = CT2.R_E_C_N_O_"			
		Else
			cQuery += " CONVERT(Int,CV3_RECDES) = CT2.R_E_C_N_O_"
		Endif
	
		cQuery += "   AND CT2.D_E_L_E_T_ = ''"
		cQuery += " WHERE "

		If !__aFiltros[FILTRO_FILALL]
			cQuery += " CV3.CV3_FILIAL " + GetRngFil( __aFiliais, 'CV3', .T., @cTmpFil)
			cQuery += " AND "
			aAdd(__aTmpFil, cTmpFil)
		Endif

		cQuery += "       CV3.CV3_TABORI = '" + cAlias  + "'"
		cQuery += "   AND CV3_LP = '" + cLp + "'"
		cQuery += "   AND CV3_RECDES <> ' ' " 
		cQuery += "   AND CV3.CV3_DC <> '4'"
		cQuery += "   AND CV3.D_E_L_E_T_ = ''"
		cQuery += "   AND NOT EXISTS( SELECT R_E_C_N_O_"
		cQuery += "                     FROM " + RetSqlName( cAlias ) + " " + cAlias
		cQuery += "                    WHERE "

		// Filtra as filiais
		If !__aFiltros[FILTRO_FILALL]
			cQuery += " " + cAlias + "." + cFilCpo + " " + GetRngFil( __aFiliais, cAlias, .T., @cTmpFil)
			cQuery += " AND "
			aAdd(__aTmpFil, cTmpFil)
		Endif

		If Upper(TcGetDb()) $ "ORACLE,DB2,INFORMIX"		// Sinal de concatencao nesses ambientes
			cQuery += " NVL(TO_NUMBER(TRIM(CV3_RECORI)),0) = " + cAlias + ".R_E_C_N_O_"			
		ElseIf  Upper(TcGetDb()) $ "POSTGRES"
			cQuery += " COALESCE(CAST(TRIM(CV3_RECORI) AS INT),0) = " + cAlias + ".R_E_C_N_O_"			
		Else
			cQuery += " CONVERT(Int,CV3_RECORI) = " + cAlias + ".R_E_C_N_O_"
		Endif

		cQuery += " AND " + cAlias + ".D_E_L_E_T_ = ''"
		cQuery += " ) "
		cQuery += cJoinCV3
	Endif
			
	cQuery := ChangeQuery( cQuery )

	If __lConOutR
		// conout para exibição da query.1
		ConoutR(cQuery)
	Endif 

	// verifica se temporario está aberto e tenta fechalo
	If Select(cAliasTmp) > 0
		DbSelectArea(cAliasTmp)
		(cAliasTmp)->(DbCloseArea())
	Endif

	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasTmp )
Endif

If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	( cAliasTmp )->( DbGoTop() )

	While ( cAliasTmp )->( !Eof() )

		// condição do filtro foi posta aqui para não degradar a performance na query
		If Len(__aFiltros ) > 0 
			If 	__aFiltros[FILTRO_LCONF] <> 3;															// Diferentes de todos
				.And. (     ( __aFiltros[FILTRO_LCONF] == 1 .And. !Empty( ( cAliasTmp )->DTCONF ) ) ;	// Não Conferidos
					   .OR. ( __aFiltros[FILTRO_LCONF] == 2 .And. Empty( ( cAliasTmp )->DTCONF  ) ) )	// Conferidos
		       	( cAliasTmp )->( DbSkip() )
		       	Loop
			Endif
		Endif

		DbSelectArea( cAliasOri )
		dbAppend()
		
		For nIx := 1 TO Len( aHeaderOri )
			nPos	:= FieldPos(aHeaderOri[nIx][2])

			If nPos <> 0
				If ( cAliasOri )->(FieldPos(aHeaderOri[nIx][2])) > 0 .And. (cAliasTmp)->(FieldPos( aHeaderOri[nIx][2] )) > 0
					FieldPut(nPos,(cAliasTmp)->(FieldGet(FieldPos( aHeaderOri[nIx][2] ))))
				Endif
			Endif
		Next nCont
		
		Replace ( cAliasOri )->CV3_RECNO WITH ( cAliasTmp )->CV3_RECNO
		Replace ( cAliasOri )->CT2_RECNO WITH ( cAliasTmp )->CT2_RECNO

       	( cAliasTmp )->( DbSkip() )
	EndDo
   		
	lRet := .T.
Endif
	
DeleteTmp( cAliasTmp )
RestArea( aArea )

Return lRet


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : FiltraDestino
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : Efetua a filtragem dos dados de destino, escolhida na tree
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function FiltraDestino( cSequen, nRecDes, lFiltraTudo )
Local aArea			:= GetArea()

Local cFilCT2		:= xFilial( 'CT2' )
Local cAliasTmp		:= GetNextAlias()
Local cWhere		:= ''

Local lRet			:= .F.

Local nPos			:= 0
Local nIx 			:= 0

Static cQuery		:= ''

Default cSequen		:= ''
Default nRecDes		:= 0
Default lFiltraTudo	:= .F.

// Limpa o temporario
If Select( cAliasDes ) > 0
	DbSelectArea( cAliasDes )
	Zap
Endif

IF Len( __aFiltros ) > 0
	If Empty( nRecDes ) .And. __aFiltros[FILTRO_LSEQUEM] == 1
		Return
	Endif
	If Empty( cSequen ) .And. __aFiltros[FILTRO_LSEQUEM] == 2
		Return
	Endif
Endif

If Empty( cQuery )
	// Filtra dados Principais
	cQuery := "SELECT R_E_C_N_O_ AS CT2_RECNO"
	
	For nIx := 1 TO Len( aHeaderDes )
		If aHeaderDes[nIx][2] <> "CT2_RECNO" .And. aHeaderDes[nIx][7] .And. CT2->(FieldPos( aHeaderDes[nIx][2] ) ) > 0
			cQuery += "     ," + aHeaderDes[nIx][2] + ""
		Endif
	Next

	cQuery += "  FROM " + RetSqlName( "CT2" ) + " CT2"
	cQuery += " WHERE CT2.CT2_FILIAL = '" + cFilCT2 + "'"
	cQuery += "   AND CT2.CT2_MOEDLC = '" + __aFiltros[FILTRO_MOEDA] + "'"
	cQuery += "   AND CT2.CT2_DC <> '4'"
	cQuery += "   AND CT2.D_E_L_E_T_ = ''"
Endif

If !lFiltraTudo
	If !Empty( nRecDes ) .And. __aFiltros[FILTRO_LSEQUEM] == 1
		cWhere := "   AND CT2.R_E_C_N_O_ = " + Str( nRecDes )
	Endif
	If !Empty( cSequen ) .And. __aFiltros[FILTRO_LSEQUEM] == 2
		cWhere := "   AND CT2.CT2_SEQUEN = '" + cSequen + "'"
	Endif
Else
	cWhere := "   AND CT2.R_E_C_N_O_ IN ( SELECT CV3_RECDES FROM " + cAliasOri + " ) "
Endif

cQueryDes := ChangeQuery( cQuery + cWhere )

// verifica se temporario está aberto e tenta fechalo
If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	( cAliasTmp )->( DbCloseArea() )
Endif

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQueryDes) , cAliasTmp )

For nIx := 1 to Len(aHeaderDes)
	If aHeaderDes[nIx,3] != 'C'
		TCSetField(cAliasTmp,aHeaderDes[nIx,2], aHeaderDes[nIx,3],aHeaderDes[nIx,4],aHeaderDes[nIx,5])
	Endif
Next

If Select( cAliasTmp ) > 0
	DbSelectArea( cAliasTmp )
	( cAliasTmp )->( DbGoTop() )
	
	While ( cAliasTmp )->( !Eof() )
		
		DbSelectArea( cAliasDes )
		dbAppend()
		
		For nIx := 1 TO Len( aHeaderDes )
			nPos	:= FieldPos(aHeaderDes[nIx][2])
			
			If ( cAliasDes )->(FieldPos(aHeaderDes[nIx][2])) > 0 .And. (cAliasTmp)->(FieldPos( aHeaderDes[nIx][2] )) > 0
				FieldPut(nPos,(cAliasTmp)->(FieldGet(FieldPos( aHeaderDes[nIx][2] ))))
			Endif
		Next nCont
		
		Replace ( cAliasDes )->CT2_RECNO WITH ( cAliasTmp )->CT2_RECNO
		
		( cAliasTmp )->( DbSkip() )
	EndDo
	
	lRet := .T.
Endif
	
DeleteTmp( cAliasTmp )
RestArea( aArea )
	
Return lRet

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : GravaConf
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : Efetua a gravação dos dados da conferencia.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function GravaConf( lConf,cObs ) 
Local aArea 	:= GetArea()

Local cConfst	:= ""
Local cObsCnf	:= ""
Local cUsrCnf	:= ""
Local dDtConf	:= cTod( "")
Local cHrConf	:= ""

Local nRecOri	:= (cAliasOri)->( Recno() )

Default lConf		:= .F.

BEGIN TRANSACTION 

IF lConf
	cConfst	:= "1"
	cObsCnf	:= cObs
	cUsrCnf	:= cUsername
	dDtConf	:= MsDate()
	cHrConf	:= Time()

	DbSelectArea( cAliasOri )
	While (cAliasOri)->( !Eof() )
	
		If (cAliasOri)->CV3_FLAG 
			CV3->( DbGoTo( (cAliasOri)->CV3_RECNO ) )
			
			If CV3->( !EOF() )
				GrvConf(cUsrcnf,dDtconf,cObsCnf,cHrConf,cConfst)
			Endif
	    Endif
	    
		(cAliasOri)->( DbSkip() )
	EndDo
Else
	CV3->( DbGoTo( (cAliasOri)->CV3_RECNO ) )
	If CV3->( !EOF() )
		GrvConf(cUsrcnf,dDtconf,cObsCnf,cHrConf,cConfst)
	Endif
Endif

END TRANSACTION     
	
// Volta a posição do cursor.
DbSelectArea( cAliasOri )
DbGoTo( nRecOri	)

RestArea(aArea)

Return .T.

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : GrvConf
//± Autor         : Renato Campos
//± Data          : 11/08/2012
//± Uso           : 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function GrvConf(cUsrcnf,dDtconf,cObsCnf,cHrConf,cConfst)

// Atualiza o tempotario
RecLock( cAliasOri, .F. )
Replace (cAliasOri)->USRCNF		With cUsrcnf
Replace (cAliasOri)->DTCONF		With dDtconf
Replace (cAliasOri)->OBSCONF	With cObsCnf
Replace (cAliasOri)->CV3_FLAG	With .F.
(cAliasOri)->( MsUnLock() )

If !Empty( CV3->CV3_RECDES ) // Aualiza o CT2

	CT2->( DbGoTo( Val( CV3->CV3_RECDES ) ) )

	If CT2->( !EOF() )
		RecLock( 'CT2', .F. )

		Replace CT2->CT2_CONFST	With cConfst
		Replace CT2->CT2_OBSCNF	With cObsCnf
		Replace CT2->CT2_USRCNF	With cUsrCnf
		Replace CT2->CT2_DTCONF	With dDtConf
		Replace CT2->CT2_HRCONF	With cHrConf

		CT2->( MsUnLock() )
	Endif
Endif

Return  


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : AtuCTL
//± Autor         : Julio Saraiva
//± Data          : 03/10/2013
//± Uso           : 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function AtuCTL()

Local aArea := GetArea()

dbSelectArea("CTL")
dbSetOrder(1)   
If dbseek(xFilial("CTL")+"650") // Procura LP Documento de entrada
	While CTL->(!Eof() .And. CTL_FILIAL+CTL_LP <= xFilial("CTL")+"651")
		If CTL->CTL_LP $ "650" .And. CTL->CTL_KEY != "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM"
			RecLock("CTL",.F.)
			CTL->CTL_KEY   := "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM"
			CTL->CTL_ALIAS := "SD1"
			MsUnlock()
		Endif
		
		If  CTL->CTL_LP $ "651"
			RecLock("CTL",.F.)
			CTL->CTL_KEY   := "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM"
			CTL->CTL_ALIAS := "SD1"
			MsUnlock()
		Endif
		CTL->(DbSkip())
	Enddo
EndIf
	
If DbSeek (xFilial("CTL")+"508")
	While CTL->(!Eof() .And. CTL_FILIAL+CTL_LP == xFilial("CTL")+"508")
		If  CTL->CTL_LP $ "508" .And. CTL->CTL_KEY != "EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA"
			RecLock("CTL",.F.)                                         
			
			CTL->CTL_KEY    := "EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA"
			CTL->CTL_ALIAS  := "SEZ"
			
			If CTL->(FieldPos("CTL_QCDATA")) > 0 
				CTL->CTL_QCDATA := ""
			EndIf 
			
			If CTL->(FieldPos("CTL_QCDOC")) > 0 
				CTL->CTL_QCDOC  := "EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO"
			EndIf 
			
			If CTL->(FieldPos("CTL_QCVLRD")) > 0 
		   		CTL->CTL_QCVLRD := "EZ_VALOR"
		 	EndIf 
			MsUnlock()
		Endif	
        CTL->(DbSkip())
  	EndDo
Endif          
RestArea(aArea)

Return .T.
