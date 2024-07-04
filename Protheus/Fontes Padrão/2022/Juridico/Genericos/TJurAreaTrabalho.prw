#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "TOTVS.CH"


//-------------------------------------------------------------------
Function __TJurAreaTrabalho() // Function Dummy
ApMsgInfo( 'JurAreaTrabalho -> Utilizar Classe ao inves da funcao' )
Return NIL 

//-------------------------------------------------------------------
/*/{Protheus.doc} JurAreaTrabalho
CLASS TJurAreaTrabalho

@author André Spirigoni Pinto
@since 22/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS TJurAreaTrabalho

DATA oMainDlg //Janela Principal
DATA oWorkarea 
DATA cTitulo //Título da janela
DATA nMenuSize
DATA oMenu
DATA aSizeDlg
DATA oParent
DATA bBeforeActivate

METHOD New (cTitulo) CONSTRUCTOR
METHOD getRelSize(nPerc)
METHOD SetLayout(aTelas)
METHOD Activate()
METHOD Sair()
METHOD getPanel(cId)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} JurAreaTrabalho
CLASS TJurAreaTrabalho

@author André Spirigoni Pinto
@since 22/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New (cTitulo, oParent, bBeforeActivate) CLASS TJurAreaTrabalho
Default oParent := Nil
Default bBeforeActivate := {||}

Self:oParent := oParent
Self:bBeforeActivate := bBeforeActivate
   
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetLayout(aTelas)
Método que vai receber a forma que será criada o layout da tela.

@Param	aTelas		Array com detalhes referentes as telas. {'01' ID da tela, 50 % tamanho vertical da tela útil, .T. Indica se ocupará a linha inteira ou não}
@Param	lColunas	Variável lógica que indica se o layout será quebrado em colunas ou uma tela por linha

@author André Spirigoni Pinto
@since 22/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetLayout(aTelas) CLASS TJurAreaTrabalho
Local nT := 0
Local nL := 0
Local nTelas := 0
Local cLinha := ""
Default aTelas := {{"01",70,.T.},{"02",30,.T.}}

//Monta as talas a partir do array informado
nTelas := len(aTelas)

nL := 0
nT := 0

For nT := 1 to nTelas
	nL++
	
	cLinha := PADL(AllTrim(Str(nL)),2,'0')
	Self:oWorkarea:CreateHorizontalBox( "LINE" + cLinha, Self:getRelSize(aTelas[nT][2]), .T. )
	
	//Inicializa a posição do array caso não tenha sido informada.
	if len(aTelas[nT]) == 2
		aAdd(aTelas[nT] , .F.)
	endif
	
	if aTelas[nT][3] == .F. .And. nT < nTelas 
		Self:oWorkarea:SetBoxCols( "LINE" + cLinha, { "WDGT" + aTelas[nT][1], "WDGT" + aTelas[nT+1][1] } )
		nT++
	elseif (nL == nTelas .Or. aTelas[nT][3] == .T.)
		Self:oWorkarea:SetBoxCols( "LINE" + cLinha, { "WDGT" + aTelas[nT][1] } )
	endif
	
Next

//Ativa a WorkArea
Self:oWorkarea:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getRelSize(nPerc)
Método que recebe uma porcentagem e devolve o tamanho absoluto do camponente

@Param	nPerc		Percentagem do tamanho relativo do componente

@author André Spirigoni Pinto
@since 22/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getRelSize(nPerc) CLASS TJurAreaTrabalho
Local nSize

nSize := Round( ((Self:aSizeDlg[3] * nPerc) / 100) ,0) + 11

Return nSize

//-------------------------------------------------------------------
/*/{Protheus.doc} Activate()
Método que inicializa o componente na tela


@author André Spirigoni Pinto
@since 22/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Activate() CLASS TJurAreaTrabalho

//executa um bloco caso exista
Eval(Self:bBeforeActivate)

Self:oMainDlg:Activate( , , , , , , ) //ativa a janela

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Sair()
Método que fecha a tela


@author André Spirigoni Pinto
@since 22/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Sair() CLASS TJurAreaTrabalho

Self:oMainDlg:End() //fecha a janela

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getPanel(cId)
Método que fecha a tela


@author André Spirigoni Pinto
@since 22/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getPanel(cId) CLASS TJurAreaTrabalho
Return Self:oWorkarea:GetPanel( "WDGT" + cId )
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author andre.spirigoni

@since 27/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()

oView := FWFormView():New()

oView:SetModel(oModel)

Return oView