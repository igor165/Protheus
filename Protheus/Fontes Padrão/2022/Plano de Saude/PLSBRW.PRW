#INCLUDE "plsbrw.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TcBrowse.ch"
#INCLUDE "MSObject.ch"
#INCLUDE "plsmger.ch"
#INCLUDE "colors.ch"

#DEFINE GD_INSERT	1
#DEFINE GD_UPDATE	2
#DEFINE GD_DELETE	4

STATIC lEnchoice := .f.
STATIC oObjBRG	 := nil
STATIC lPLSA094B := funName() == "PLSA094B"

/*/{Protheus.doc} TBRWPLS
Classe desenvolvida com o objetivo de se utilizar varias GETDADOS
no mesmo dialog, permanecendo a sintaxe e o modo de se utilizar semelhante.
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
CLASS TBRWPLS
DATA oBrowse
DATA nQtdLin
DATA aCpoObri
DATA aCols
DATA aHeader
DATA aCampos
DATA cTitBrw
DATA aSemaf
DATA cFunIni
DATA cAlias
DATA nOpc
DATA cTitulo
DATA aVetTrab
DATA aVetNoFil
DATA laddLine
DATA lInaddLine
DATA lDelLine
DATA cVldLIne
DATA cVldDel
DATA bGotFocus
DATA bLostFocus
DATA bFilter
DATA lFilter
DATA aColsNoFil
DATA aItcolDel
DATA aRecAlt
DATA oWnd
DATA oPai
DATA aOrigem
DATA aRelac
DATA bChange
DATA lAltered
DATA nOpcx
DATA bAfterEdit
DATA bBeforeEdit
DATA bBeforeDialog
DATA bLostFoPad
DATA aButEsp
DATA bBeforeAdd
DATA bAfterAdd
DATA bMultaCols
DATA bAftCancel
DATA lAtuSVCOL
DATA lOrdColED
DATA lConsFold
DATA aFieldRO
DATA bBeforAddC

//nesta propriedade se pode gravar qualquer tipo de dado que o desenvolvedor necessite (Caracter, Numerico, Data, Array, Objeto, etc)
DATA Cargo      

//propriedade utilizada para informar quais campos de um item negado devem ser desconsiderados para permitir
//inserir uma nova linha no grid de procedimento.
//Os campos devem ser separados por virgula.
DATA cDescCmpo

//propriedade utilizada para informar qual o nome do campo de status, que informa se o procedimento está aprovado ou negado,
//esta variável será utilizada para verificar dentro do aHeader a posição desse campo que será utilizado em conjunto com o parâmetro cDeCampos
DATA cCmpStat

METHOD new(nRow,nCol,nWidth,nHeigth,bLine,oWnd,bChange,bLDblClick,bRClick,oFont,cMsg,lUpdate,bWhen,lDesign,bValid,aHeaderBrw,aColsBrw,lSemafaro,cAlias,nOpc,cTitulo,aExpSem,cFunIni,bAdd,aVetTrab,cVldLine,cVldDel,bFilter,bAfterEdit,aButEsp,bMultaCols,bAftCancel,bBeforeDialog,lOrdColED,lConsFold,aFieldRO,lSx3User,aDifSize) CONSTRUCTOR
METHOD verExiData() CONSTRUCTOR
METHOD editRecord(cAlias,nOpc,cTitulo,nLinha,aColsEd,aHeaderEd,bAfterEdit,bMultaCols,bAftCancel,bBeforeDialog,aFieldRO,aRotinaNew,lOrdColED,lConsFold,aDifSize) CONSTRUCTOR
METHOD addLine() 											CONSTRUCTOR
METHOD linha() 												CONSTRUCTOR
METHOD atualiza() 											CONSTRUCTOR
METHOD addBlank() 											CONSTRUCTOR
METHOD refresh() 											CONSTRUCTOR
METHOD colDel() 											CONSTRUCTOR
METHOD notDel() 											CONSTRUCTOR
METHOD retCol(cColuna,aHeader) 								CONSTRUCTOR
METHOD plBlock(aColsEd,aHeaderEd,nLinha,aExpSem)			CONSTRUCTOR
METHOD linhaOK(lHelp)										CONSTRUCTOR
METHOD tudoOK()												CONSTRUCTOR
METHOD semOK()												CONSTRUCTOR
METHOD coluna(cNameCol)										CONSTRUCTOR
METHOD plRetPos(cCampo,lHelp,aHead)							CONSTRUCTOR
METHOD grava(aChave,lForce)	   								CONSTRUCTOR
METHOD setArray(aArray)										CONSTRUCTOR
METHOD filtra(bFilter)										CONSTRUCTOR
METHOD endFilter(lInterface)								CONSTRUCTOR
METHOD forceRefresh()										CONSTRUCTOR
METHOD forceAtualiza() 										CONSTRUCTOR
METHOD fieldGet(cCampo,nLine,aObsoleto)						CONSTRUCTOR
METHOD fieldPut(cCampo,uValor,nLine,aObsoleto)				CONSTRUCTOR
METHOD fieldPos(cCampo,aObsoleto)             				CONSTRUCTOR
METHOD consiste(oGet,aCamp1,aCamp2)							CONSTRUCTOR
METHOD isDeleted(nLine)										CONSTRUCTOR
METHOD chkDel()          									CONSTRUCTOR
METHOD retAcols()          									CONSTRUCTOR
METHOD retRAlt()          									CONSTRUCTOR
METHOD brwSeek(nOrdem,cChave)          						CONSTRUCTOR
METHOD setPos(nPos)          								CONSTRUCTOR
METHOD recno()
                   
ENDCLASS

/*/{Protheus.doc} new
new da clasee
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD new(	nRow,nCol,nWidth,nHeigth,bLine,oWnd,bChange,bLDblClick,bRClick,oFont,cMsg,lUpdate,bWhen,lDesign,;
			bValid,aHeaderBrw,aColsBrw,lSemafaro,cAlias,nOpc,cTitulo,aExpSem,cFunIni,bAdd,aVetTrab,cVldLine,;
			cVldDel,bFilter,bAfterEdit,aButEsp,bMultaCols,bAftCancel,bBeforeDialog,lOrdColED,lConsFold,aFieldRO,lSx3User,aDifSize) CLASS TBRWPLS

local nInd		:= 0
local nI		:= 0
local nOpcGD    := K_Visualizar
local oBrowse   := nil
local bBakDelete:= nil

private aRotina := {	{ "",'AxPesqui' , 0 ,K_Pesquisar },; //Pesquisar
						{ "",'AxPesqui' , 0 ,K_Visualizar},;
						{ "",'AxInclui' , 0 ,K_Incluir   },;
						{ "",'AxAltera' , 0 ,K_Alterar   },;
						{ "",'AxDeleta' , 0 ,K_Excluir   }}

if type("N") # "N"
	public  n := 1
endIf

default cTitulo    		:= ""
default cAlias     		:= Alias()
default lSemafaro  		:= .f.
default bLine      		:= nil
default bChange    		:= {||.t.}
default bRClick    		:= nil
default oFont      		:= AdvFont
default cMsg       		:= nil
default bWhen      		:= nil
default bValid     		:= nil
default aExpSem    		:= {}
default cVldLine   		:= "AllWaysTrue()"
default cVldDel    		:= "AllWaysTrue()"
default bAfterEdit 		:= {|| }
default bMultaCols 		:= {|| }
default bAftCancel 		:= {|| }
default bBeforeDialog	:= {|| }
default ::lAtuSVCOL		:= .t.
default lOrdColED		:= .f.
default lConsFold		:= .t.
default aFieldRO		:= {}
default lSx3User		:= .t.
default aDifSize		:= {}
default bLDblClick 		:= {|| ::editRecord(cAlias, iIf( ::oBrowse:oBrowse:nAt>::nQtdLin .and. nOpc <> K_Incluir, K_Incluir, nOpc ), cTitulo, ::linha(), ::oBrowse:aCols, ::oBrowse:aHeader, bAfterEdit, bMultaCols, bAftCancel, bBeforeDialog, ::aFieldRO,,lOrdColED,lConsFold,lSx3User,aDifSize) }
default cFunIni    		:= "AllWaysTrue()"

if !("(" $ cVldLine)
	cVldLine := allTrim(cVldLine)+"()"
endIf

cVldLine := allTrim(cVldLine)

if !("(" $ cVldDel)
	cVldDel := allTrim(cVldDel)+"()"
endIf

cVldDel := allTrim(cVldDel)

n := 1

::aButEsp  		:= iIf(valType(aButEsp)=="A",aClone(aButEsp),{})
::aCols    		:= aClone(aColsBrw)
::aHeader  		:= aClone(aHeaderBrw)
::aVetTrab 		:= aClone(aVetTrab)
::cAlias   		:= cAlias
::nOpc     		:= nOpc
::cTitulo  		:= cTitulo
::cVldLine 		:= cVldLine
::cVldDel  		:= cVldDel
::bGotFocus  	:= {||.t.}
::bLostFocus 	:= {||.t.}
::lFilter    	:= .f.
::bFilter    	:= bFilter
::aColsNoFil 	:= {}
::aItcolDel  	:= {}
::aRecAlt		:= {}
::oWnd       	:= oWnd
::bChange    	:= bChange
::lAltered   	:= iIf( nOpc <> K_Excluir, .f., .t. )
::bAfterEdit 	:= bAfterEdit
::bMultaCols 	:= bMultaCols
::bAftCancel 	:= bAftCancel
::lOrdColED		:= lOrdColED
::lConsFold		:= lConsFold
::aFieldRO		:= aFieldRO
::bBeforeDialog := bBeforeDialog

//Item nOpc == 6 foi adicionado para os itens de copiar sem esse tartamento nao podemos adicionar itens nas guias
if nOpc == K_Incluir .or. nOpc == K_Alterar  .or. nOpc == 6   
	::laddLine := .t.
	::lDelLine := .t.
else
	::laddLine := .f.
	::lDelLine := .f.
	::cVldDel  := "!AllWaysTrue()"
endIf

//help(" ",1,"MLIBDADOS",,"Alias : "+cAlias,4,1)						
//foi retirado porque vai ter caso que o analista vai desabilitar 	
//a exibicao de um folder pelo cNivel x3_nivel e realmente			
//nao vai ter aHeader para um browse...								
if len(::aCols) == 0 .or. len(::aHeader) == 0
	return
endIf

if valType(::aCols[1,len(::aHeader)+1]) <> "L"
	help(" ",1,"MLIBDADDL")
	return
endIf

if lSemafaro .and. len(aExpSem) == 0
	help(" ",1,"MLIBSEMAF")
	return
endIf

if valType(::aVetTrab) # "A"
	::aVetTrab := {}
endIf

::aVetTrab := aSize(::aVetTrab,len(::aCols))

for nInd := 1 to len(::aCols)

	if ::aVetTrab[nInd] == nil

		::aVetTrab[nInd] := 0
		
		if ! ::aCols[nInd,len(::aCols[nInd])] 
			aadd(::aRecAlt,{ ::cAlias, 'I', 0, nInd } )
		endIf	
		
	endIf
	
next

::aCpoObri := {}

SX3->(dbSetOrder(2))
for nInd := 1 to len(::aHeader)

	if SX3->(msSeek(allTrim(::aHeader[nInd,2])))

		if SX3->X3_CONTEXT <> "V"
			
			if X3Obrigat(SX3->X3_CAMPO) 
				aadd(::aCpoObri,allTrim(::aHeader[nInd,2]))
			endIf
			
		endIf
		
	endIf
next

::cFunIni := cFunIni

::filtra(::bFilter,.t.,aColsBrw)

if nOpc = K_Visualizar
	::oBrowse := MsnewGetDados():new(nRow,nCol,nHeigth,nWidth,nOpcGD,,/*tudoOk*/,,,/*freeze*/,120,/*fieldok*/,/*superdel*/,/*delok*/,oWnd,aHeaderBrw,aColsBrw)
else
	::oBrowse := MsnewGetDados():new(nRow,nCol,nHeigth,nWidth,GD_INSERT+GD_DELETE,,/*tudoOk*/,,,/*freeze*/,120,/*fieldok*/,/*superdel*/,/*delok*/,oWnd,aHeaderBrw,aColsBrw)
endIf

::oBrowse:oBrowse:bGotFocus  	:= {||::filtra(::bFilter),/*::oBrowse:aHeader:=::aHeader,*/::oBrowse:aCols:=aClone(::aCols),n:=::linha(), ::oBrowse:oBrowse:lDisablePaint := .f.,  eval(::bGotFocus,::oBrowse:oBrowse)} //Acerto juan
::oBrowse:oBrowse:bLostFocus 	:= {||::oBrowse:oBrowse:lDisablePaint := .f., /*::aHeader:=aClone(aHeader),*/::aCols:=aClone(::oBrowse:aCols),eval(::bLostFocus,SELF),::endFilter()}
::oBrowse:oBrowse:default()
::oBrowse:oBrowse:bLDblClick 	:= {|| iIf( valType(::bBeforeEdit)=="B", eval(::bBeforeEdit) ,.t. ), eval(bLDblClick), iIf( valType(::bAfterAdd)=="B", eval(::bAfterAdd) ,.t. ) }
::oBrowse:oBrowse:bAdd       	:= {|| iIf( valType(::bBeforeAdd)=="B", eval(::bBeforeAdd) ,.t. ), ::addLine()}
::oBrowse:oBrowse:bChange    	:= {|| eval(::bChange)}

::oBrowse:nMax               	:= len(::aCols)+5
bBakDelete 						:= ::oBrowse:oBrowse:bDelete

::oBrowse:oBrowse:bDelete 		:= {||::lAltered := .t.,,eval(bBakDelete),::chkDel(),::aCols := aClone(::oBrowse:aCols)}
::endFilter()

oBrowse				:=::oBrowse
::oBrowse:bDelOk 	:= {||&cVldDel}
::nQtdLin 			:= iIf(nOpc == K_Incluir .or. len(::aVetTrab) == 0,0,len(::aCols))
::cTitBrw 			:= cTitulo
::aSemaf  			:= aExpSem

for nInd := 1 to len(::oBrowse:aHeader)
	::oBrowse:aHeader[nInd,9] := ""
next

return Self

/*/{Protheus.doc} editRecord
editRecord
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD editRecord(cAlias,nOpc,cTitulo,nlinha,aColsEd,aHeaderEd,bAfterEdit,bMultaCols,bAftCancel,bBeforeDialog,aFieldRO,aRotinaNew,lOrdColED,lConsFold,lSx3User,aDifSize) CLASS TBRWPLS
local aOldArea 			:= getArea()
local nI				:= 0
local nJ				:= 0
local nInd     			:= 0
local nfor				:= 0
local nOpca				:= 0
local nPosicao			:= 0
local nRecno			:= 0
local nOpcao   			:= nOpc
local cCampo			:= ""
local lReturn 			:= .f.
local lFlag     		:= .f.
local lBakInclui 		:= iIf(type("INCLUI") == "L",INCLUI,nil)
local aCampos2  		:= {}
local aCamposOrd		:= nil
local aFolder			:= nil
local aButtons  		:= aClone(::aButEsp)
local aCposMemo 		:= {}
local aSvCols   		:= aClone(::oBrowse:aCols)
local aRetAux			:= {}
local nA                := 0
local nB                := 0
local nC                := 0
local nD                := 0
local nE                := 0
local nF                := 0
local nG                := 0
local nH                := 0

default bMultaCols 		:= {|| }
default bAftCancel 		:= {|| }
default bBeforeDialog 	:= {|| }
default aFieldRO 		:= {}
default aRotinaNew 		:= {}
default aDifSize        := {}
default lOrdColED		:= .f.
default lConsFold		:= .t.
default lSx3User		:= .f.

private oEncPLS
private aGets[0]
private aTela[0][0]
private oDlg		
private aRotina 	:= {	{	STR0001 , '' , 0 ,K_Pesquisar  },;  //"Pesquisar"
							{  	STR0002 , '' , 0 ,K_Visualizar },;  //"Visualizar"
							{ 	STR0003 , '' , 0 ,K_Incluir    },;  //"Incluir"
							{ 	STR0004	, '' , 0 ,K_Alterar    },;  //"Alterar"
							{ 	STR0005	, '' , 0 ,K_Excluir    },;  //"Excluir"
							{ 	STR0015, '' , 0 ,K_Incluir     }}   //"Copiar"

private aCols 	:= ::aCols
private aHeader := aClone(::aHeader)

if len(aRotinaNew) == 0
	aRotinaNew := aClone(aRotina)
endIf

//Monta Titulo da Enchoice...
cTitulo 	+= " - " + aRotinaNew[nOpc,1]
lrefresh 	:= .t.
lEnchoice 	:= .t.

if  ::lInaddLine = nil
	::lInaddLine := .f.
endIf

if ! ::lInaddLine
	N := ::oBrowse:oBrowse:nAt
endIf

if valType(::bBeforeEdit) == "B"
	eval(::bBeforeEdit)
endIf

//Layout Protheus V12
if val(GetVersao(.f.)) == 12

	if len(aDifSize) > 0

		iIf(!empty(aDifSize[1]),nA := aDifSize[1],nA := 008.2)
		iIf(!empty(aDifSize[2]),nB := aDifSize[2],nB := 010.3)
		iIf(!empty(aDifSize[3]),nC := aDifSize[3],nC := 042)
		iIf(!empty(aDifSize[4]),nD := aDifSize[4],nD := 110)
		iIf(!empty(aDifSize[5]),nE := aDifSize[5],nE := 030)
		iIf(!empty(aDifSize[6]),nF := aDifSize[6],nF := 000)
		iIf(!empty(aDifSize[7]),nG := aDifSize[7],nG := 255.5)
		iIf(!empty(aDifSize[8]),nH := aDifSize[8],nH := 395.7)
		
	else
		nA := 008.2
		nB := 010.3
		nC := 042
		nD := 110
		nE := 030//linha
		nF := 000 //coluna
		nG := 255.5//altura
		nH := 395.7//largura
	endIf
	
endIf

if val(GetVersao(.f.)) <= 11
	
	if len(aDifSize) > 0

		iIf(!empty(aDifSize[1]),nA := aDifSize[1],nA := 008.2)
		iIf(!empty(aDifSize[2]),nB := aDifSize[2],nB := 010.3)
		iIf(!empty(aDifSize[3]),nC := aDifSize[3],nC := 036 )
		iIf(!empty(aDifSize[4]),nD := aDifSize[4],nD := 100.3)
		iIf(!empty(aDifSize[5]),nE := aDifSize[5],nE := 014)
		iIf(!empty(aDifSize[6]),nF := aDifSize[6],nF := 001)
		iIf(!empty(aDifSize[7]),nG := aDifSize[7],nG := 197)
		iIf(!empty(aDifSize[8]),nH := aDifSize[8],nH := 355)
		
	else
	
		nA := 008.2
		nB := 010.3
		nC := 036
		nD := 100.3
		nE := 014
		nF := 001
		nG := 197
		nH := 355
		
	endIf
	
endIf

DEFINE MSDIALOG oDlg TITLE cTitulo FROM nA,nB to nC,nD OF GetWnddefault()

dbSelectArea(cAlias)
aCampos := {}

//Gera dados para a memoria...
for nInd := 1 to len(aHeaderEd)

	if subs(aHeaderEd[nInd,3],1,4) <> "@BMP" .and. len(aColsEd) >= nlinha
		
		if nOpc == K_Visualizar .and. aHeaderEd[nInd,8] == "M"
			aadd(aCposMemo,allTrim(aHeaderEd[nInd,2]))
		endIf
		
		aadd(aCampos,allTrim(aHeaderEd[nInd,2]))
		
		if ( aHeaderEd[nInd,10] == "V" .or. cpoObri(aHeaderEd[nInd,2]) ) .and. empty(aColsEd[nlinha,nInd])
			M->&(aHeaderEd[nInd,2]) := criaVar(aHeaderEd[nInd,2])
		else
			M->&(aHeaderEd[nInd,2]) := aColsEd[nlinha,nInd]
		endIf
		
	endIf
	
next

if ::aCampos != nil
	aCampos := aClone(::aCampos)
endIf

//Monta Enchoice...
//Caso todos os campos obrigatorios nao esteja preenchido exibo o
//msmget como inclusao
if nOpcao <> K_Visualizar

	lFlag := .f.

	for nInd := 1 to len(::aCpoObri)

		cCampo   := allTrim(::aCpoObri[nInd])
		nPosicao := ::plRetPos(cCampo,.f.,aHeaderEd)
		
		if empty(aColsEd[nlinha,nPosicao])
			lFlag := .t.
			exit
		endIf
		
	next
	
	if lFlag
		nOpcao := K_Incluir
		INCLUI := .t.
	endIf
	
endIf

if nOpcao == K_Visualizar

	if len(aCposMemo) == 0
		aCampos2 := {}
	else
		aCampos2 := aClone(aCposMemo)
	endIf
	
else
	
	aCampos2 := aClone(aCampos)
	
endIf

nOpcao := ( iIf(nOpcao == K_Visualizar, K_Alterar, nOpcao) )

::nOpcx := nOpcao

if len(aCampos) == 0
	msgInfo(STR0008) //"Nao-conformidade METHOD editRecord"
endIf

//Quando for exclusão e utilizado o recno mais na maioria das vezes a tabela nao esta posicionada
//como para todos os casos os M-> ja estao carregados vai ser mostrado na exclusao igual a uma
//visualização
if nOpcao == K_Excluir
	nOpcao :=  K_Visualizar
endIf

//Campos somente leitura podem ser passados
if len(aFieldRO) > 0 .and. len(aCampos2) > 0

	for nInd := 1 to len(aFieldRO)

		nfor := aScan(aCampos2,{|x| allTrim(x) == allTrim(aFieldRO[nInd])})

		if nfor > 0
			aCampos2[nfor] := ""
		endIf
		
	next
	
endIf

//Se vai considerar a ordem enviada no aHeader ou ordem do SX3
if lOrdColED
	aRetAux 	:= PLSORDFIE(cAlias,aCampos,aCampos2,lConsFold,iIf(lPLSA094B,iIf(lCopyGui,.t.,.f.),.f.))
	aCamposOrd 	:= aRetAux[1]
	aFolder	  	:= aRetAux[2]
endIf

//Verifica se deve desconsiderar os campos de usuario
if lSx3User
	aadd(aCampos,"NOUSER")
endIf

oEncPLS := MSMGet():new(cAlias,recno(),nOpcao,,,,aCampos,{nE,nF,nG,nH},aCampos2,,,,,oDlg,,,.f.,,,,aCamposOrd, aFolder, .t. )

for nInd := 1 to len(aHeaderEd)
    
    if aHeaderEd[nInd,10] == "V" .and. subs(aHeaderEd[nInd,3],1,4) <> "@BMP"
		M->&(aHeaderEd[nInd,2]) := iIf(nOpc == 2 .and. empty(aColsEd[nLinha,nInd]), criaVar(aHeaderEd[nInd,2]), aColsEd[nLinha,nInd])
    endIf
       
next 

//Para ajustar o caso quando tiver somente 1 campo e ser executado
PlsBut(oDlg)

eval(bBeforeDialog,nlinha,aHeaderEd,aColsEd,Self,oEncPLS)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnChoiceBar(oDlg,{|| nOpca := 1,iIf((Obrigatorio(aGets,aTela) .and. &(::cVldLine) ),oDlg:End(),(nOpca := 3,.f.))},{|| nOpca := 3,oDlg:End()},.f.,aButtons)

if lBakInclui # nil
	INCLUI := lBakInclui
endIf

lEnchoice := .f.

if nLinha <= len(::aCols) 
	
	for nJ := 1 to len(::aHeader)
	
		if ! ( ::aCols[nLinha,nJ] == aColsEd[nLinha,nJ] )
			aColsEd[nLinha,nJ] := ::aCols[nLinha,nJ]
		endIf
		
	next
	
endIf	

if 	nOpca == K_OK
	
	//atualiza dados no TBRWPLS quando for inclusao ou alteracao...
	eval(bAfterEdit,nlinha,aHeaderEd,aColsEd,Self)
	
	if nOpcao == K_Incluir .or. nOpcao == K_Alterar
		
		for nInd := 1 to len(aHeaderEd)
		
			if ( subs(aHeaderEd[nInd,3],1,4) <> "@BMP" ) .and. ! ( aColsEd[nlinha,nInd] == M->&(aHeaderEd[nInd,2]) )
				::lAltered 	:= .t.
			endIf
			
			if subs(aHeaderEd[nInd,3],1,4) <> "@BMP"
				aColsEd[nlinha,nInd] := M->&(aHeaderEd[nInd,2])
			endIf
			
		next

		if ::lAltered
			
			nRecno := ::recno(nLinha)
			
			if aScan(::aRecAlt, { |x| x[3] == nRecno } ) == 0 .or. nRecno == 0
				aadd(::aRecAlt,{ ::cAlias, iIf(nOpcao == K_Alterar,'A','I'), nRecno, nlinha } )
			endIf
			
		endIf
		
		::aCols   		:= aColsEd
		::oBrowse:nMax 	:= len(::aCols) + 5
		
	endIf
	
	eval(bMultaCols,nlinha,aHeaderEd,aColsEd,Self)
	
	lReturn := .t.
	
else

	aColsEd 		:= aClone(aSvCols)
	::aCols 		:= aClone(aSvCols)
	::oBrowse:aCols	:= aClone(aSvCols)

	::oBrowse:setArray(aSvCols)
	
	//Restaura a linha que estava posicionada, se for possível.
	if n <= len(aSvCols) 
	
		::oBrowse:oBrowse:nAt := n
	
	//Se não for possivel, verifica se a matriz ainda é valida e se for válida, posiciona na primeira linha.
	elseIf len(aSvCols) > 0 
	
		::oBrowse:oBrowse:nAt := 1
		
	endIf
	
	::oBrowse:refresh()
	
	eval(bAftCancel,nlinha,aHeaderEd,aColsEd,Self)
	
endIf

restArea(aOldArea)

return(lReturn)

/*/{Protheus.doc} addLine
addLine
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD addLine() CLASS TBRWPLS
local nI			:= 0 
local nJ 			:= 0
local ntotCol   	:= 0
local nInd			:= 0
local lFlag   		:= .t.
local cFuncao 		:= ::cFunIni
local lOK           := .t.
local aSvColAdd 	:= {}
local aSvCols       := {}

private nLinsetPos	:= 1
private aRotina 	:=  { 	{ "",'AxPesqui' , 0 ,K_Pesquisar },; //Pesquisar
							{ "",'AxPesqui' , 0 ,K_Visualizar},;
							{ "",'AxInclui' , 0 ,K_Incluir   },;
							{ "",'AxAltera' , 0 ,K_Alterar   },;
							{ "",'AxDeleta' , 0 ,K_Excluir   } }
private Inclui 		:= .t.
private aCols 		:= ::aCols
private aHeader 	:= aClone(::aHeader)

default ::lAtuSVCOL 	:= .t.

if !::laddLine
	return(.f.)
endIf

if ! ::linhaOK()
	return(.f.)
endIf

while .t.

	::lInaddLine := .t.
	aSvCols   	 := aClone(::oBrowse:aCols)
	
	aadd(::oBrowse:aCols,{})
	
	n := len(::oBrowse:aCols)
	
	if valType(::bBeforeAdd) == "B"
		eval(::bBeforeAdd)
	endIf
	
	for nInd :=  1 to len(::aHeader)+1
	
		if nInd <= len(::aHeader)
	
			if ::aHeader[nInd,8] == "C"
			
				aadd(::oBrowse:aCols[len(::oBrowse:aCols)],space(::aHeader[nInd,4]))
				
			elseIf ::aHeader[nInd,8] == "D"
			
				aadd(::oBrowse:aCols[len(::oBrowse:aCols)],ctod(""))
				
			elseIf ::aHeader[nInd,8] == "N"
			
				aadd(::oBrowse:aCols[len(::oBrowse:aCols)],0)
				
			else
			
				aadd(::oBrowse:aCols[len(::oBrowse:aCols)],nInd)
				
			endIf
			
		else
		
			aadd(::oBrowse:aCols[len(::oBrowse:aCols)],.f.)
			
		endIf
		
	next
	
	for nInd :=  1 to len(::aHeader)+1
	
		if nInd <= len(::aHeader)
	
			::oBrowse:aCols[len(::oBrowse:aCols),nInd] := criaVar(::aHeader[nInd,2],.t.)
			
		else
	
			::oBrowse:aCols[len(::oBrowse:aCols),nInd] := .f.
	
		endIf
		
	next
	
	//execucao	
	If "(" $ cFuncao
		&(cFuncao)
	else
		&(cFuncao)(,,,)
	endIf	
	lOK := ::editRecord(::cAlias, 3 ,::cTitulo,len(::oBrowse:aCols),aClone(::oBrowse:aCols),::aHeader,::bAfterEdit,::bMultaCols,::bAftCancel,::bBeforeDialog,::aFieldRO,,::lOrdColED,::lConsFold)
	
	If ValType(::bBeforAddC) == "B"
    	Eval(::bBeforAddC)
	EndIf
	
	if ! lOK	
			
		n := len(aSvCols)
		
		for nI := 1 to n
		
			for nJ := 1 to len(::aHeader)
			
				if ::aCols[nI,nJ] <> aSvCols[nI,nJ]
					aSvCols[nI,nJ] := ::aCols[nI,nJ]
				endIf
				
			next
			
		next
		
		::aCols 				:= aClone(aSvCols)
		::oBrowse:aCols 		:= aClone(aSvCols)
		
		::oBrowse:setArray(aSvCols)
		::oBrowse:oBrowse:nAt := len(::oBrowse:aCols)
		::oBrowse:refresh()
		
		exit	
		
	else
		
		oobj		:= SELF
		aSvColAdd 	:= {}
		ntotCol 	:= len(::aCols)
		
		for nI := 1 to len(::aCols[ntotCol])
			aadd(aSvColAdd,::aCols[ntotCol,nI])
		next
		
		::oBrowse:aCols 	:= aClone(aSvCols)
		::oBrowse:addLine()
		
		::lAltered := .t.
		
		for nI := 1 to len(::oBrowse:aCols[ntotcol])
			::oBrowse:aCols[ntotCol,nI] := aSvColAdd[nI]
		next
		
		::oBrowse:refresh()
		
		//inclui 0 no vettrab indicando que e' um registro novo
		aadd(::aVetTrab,0)
		
		if valType(::bAfterAdd) == "B"
			eval(::bAfterAdd)
		endIf
		
	endIf
	
endDo

::lInaddLine := .f.

return(lFlag)

/*/{Protheus.doc} addBlank
addBlank
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD addBlank() CLASS TBRWPLS
local nInd	:= 0

aadd(::aCols,{})

for nInd :=  1 to len(::aHeader)+1

	if nInd <= len(::aHeader)
		
		if ::aHeader[nInd,8] == "C"
		
			aadd(::aCols[len(::aCols)],space(::aHeader[nInd,4]))
		
		elseIf ::aHeader[nInd,8] == "D"
		
			aadd(::aCols[len(::aCols)],ctod(""))
		
		elseIf ::aHeader[nInd,8] == "N"
		
			aadd(::aCols[len(::aCols)],0)
		
		else
		
			aadd(::aCols[len(::aCols)],nInd)
		
		endIf
		
	else
		
		aadd(::aCols[len(::aCols)],.f.)
		
	endIf
	
next

for nInd :=  1 to len(::aHeader)+1

	if nInd <= len(::aHeader)
	
		::aCols[len(::aCols),nInd] := criaVar(::aHeader[nInd,2],.t.)
	
	else
	
		::aCols[len(::aCols),nInd] := .f.
	
	endIf
	
next

::oBrowse:aCols := aClone(::aCols)

aadd(::aVetTrab,0)

n := len(::aCols)
	
return

/*/{Protheus.doc} linha
linha
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD linha() CLASS TBRWPLS
local nLine := 1

if valType(::oBrowse) == "O"
	
	if valType(::oBrowse:oBrowse) == "O"
		nLine := ::oBrowse:oBrowse:nAt
	endIf
	
endIf

return(nLine)

/*/{Protheus.doc} atualiza
atualiza
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD atualiza(lFocusBrow) CLASS TBRWPLS
local lFilter 		:= ::lFilter

default lFocusBrow  := .t. 

if !lFilter
	::filtra()
endIf

::oBrowse:setArray(::aCols)

if ::oBrowse:oBrowse:nAt > len(::aCols)
	::oBrowse:oBrowse:nAt := 1
endIf

::oBrowse:refresh()

if !lFilter
	::endFilter()
endIf

//getdados
if !IsInCallStack("forceAtualiza") .and. lFocusBrow
	::oBrowse:oBrowse:SetFocus()
endIf

return

/*/{Protheus.doc} setPos
setPos
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD setPos(nPos) CLASS TBRWPLS
	
if nPos <= len(::oBrowse:aCols)
	
	if valType(::oBrowse:oBrowse) == 'O'
		::oBrowse:oBrowse:nAt := nPos
		::oBrowse:refresh()
	else
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "setPos - Error" , 0, 0, {})
	endIf
	
endIf
	
return

/*/{Protheus.doc} recno
recno
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD recno(nLinha) CLASS TBRWPLS
local nRecno := 0

default nLinha := ::linha()

if len(::aVetTrab) >= nLinha
	nRecno := ::aVetTrab[nLinha]
endIf

return(nRecno)

/*/{Protheus.doc} refresh
refresh
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD refresh() CLASS TBRWPLS
::atualiza()
return

/*/{Protheus.doc} colDel
colDel
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD colDel() CLASS TBRWPLS
return(len(::aHeader)+1)

/*/{Protheus.doc} notDel
notDel
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD notDel() CLASS TBRWPLS
lFlag := !::aCols[::oBrowse:oBrowse:nAt,len(::aHeader)+1]
return(lFlag)

/*/{Protheus.doc} retCol
retCol
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD retCol(ccoluna,aObsoleto) CLASS TBRWPLS
local nColuna := ::plRetPos(ccoluna,.f.,::aHeader)
return(nColuna)

/*/{Protheus.doc} plBlock
plBlock
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD plBlock(aColsEd,aHeaderEd,nlinha,aExpSem) CLASS TBRWPLS
local nColuna	:= 0
local nInd      := 0
local cExp 		:= ""
local bBlock   	:= ""
local cValue    := ""
local lFlag		:= .f.

for nInd := 1 to len(aExpSem)
	
	nColuna := ::retCol(::aHeader[::retCol(aExpSem[nInd,1]),2],aHeaderEd)
	
	cExp    := cExp +  "aCols["+allTrim(Str(nlinha))+","+allTrim(Str(nColuna))+"] "+aExpSem[nInd,2]
	cValue  := aExpSem[nInd,3]
	
	if valType(cValue) == "C"
		
		cExp += cValue
	
	elseIf valType(cValue) == "N"
	
		cExp += allTrim(Str(cValue))
	
	elseIf valType(cValue) == "D"
	
		cExp += 'ctod("'+dtoc(cValue)+'")'
	
	endIf
	
	cExp    := cExp + " .and. "
	
next

cExp := subs(cExp,1,len(cExp)-6)

bblock := &("{ || "+cExp+"}")

lFlag := !eval(bBlock)
	
return(lFlag)

/*/{Protheus.doc} linhaOK
linhaOK
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD linhaOK(lHelp,nlinha,aColRea) CLASS TBRWPLS
local nInd		:= 0
local naScan  	:= 0
local lFlag 	:= .t.
local aCampos 	:= {}

default lHelp 	:= .t.
default nlinha  := ::oBrowse:oBrowse:nAt
default aColRea := ::aCols

if aColRea[nlinha,len(::aHeader)+1]
	return(.t.)
endIf

for nInd := 1 to len(::aCpoObri)
	
	if (naScan := aScan(::aHeader,{|a| a[2] $ allTrim(::aCpoObri[nInd]) })) > 0
		
		//propriedade utilizada para informar quais campos de um item negado devem ser desconsiderados para permitir
		//Os campos devem ser separados por virgula.
		if valType(::cDescCmpo) <> 'U' .and. ! empty(::cDescCmpo) .and. allTrim(::aCpoObri[nInd]) $ ::cDescCmpo
			loop
		endIf
			
		if empty(aColRea[nlinha,naScan])
		
			lFlag := .f.
			
			aadd(aCampos,{allTrim(::aHeader[naScan,2]),allTrim(::aHeader[naScan,1])})
			
		endIf
			
	endIf
	
next

if ! lFlag .and. lHelp
	
	//Implementacao Tulio Cesar em 06.01.2004... exibir os campos obrigatorios que
	//ainda nao foram digitados
	PLSCRIGEN(aCampos,{ {STR0009,"@C",50},{STR0010,"@C",100} },STR0011+"   "+STR0012+" [ "+::cTitulo+" ]") //"Campo"###"Descricao"###"Existem campos obrigatorios que nao foram informados."###"Verifique no Browse"
	
endIf
	
return(lFlag)

/*/{Protheus.doc} tudoOk
tudoOk
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD tudoOk(lMsg,cDeCampos) CLASS TBRWPLS
local nInd		:= 0
local nCont		:= 0
local naScan  	:= 0
local lFlag   	:= .t.
local aCampos 	:= {}

default lMsg  		:= .t.
default cDeCampos 	:= ""

for nCont := 1 to len(::aCols)
	
	if ::aCols[nCont,::colDel()]
		loop
	endIf
	
	if ! ::aCols[::oBrowse:oBrowse:nAt,::colDel()]
		
		for nInd := 1 to len(::aCpoObri)
			
			if (naScan := aScan(::aHeader,{|a| a[2] $ allTrim(::aCpoObri[nInd]) })) > 0
				
				//cDeCampos - variável utilizada para informar quais campos de um item negado devem ser desconsiderados para permitir
				//inserir uma nova linha no grid de procedimento.
				//Os campos devem ser separados por virgula.
				
				//cCmpStat - parâmetro utilizada para informar qual o nome do campo de status, que informa se o procedimento está aprovado ou negado,
				//esta variável será utilizada para verificar dentro do aHeader a posição desse campo que será utilizado em conjunto com
				//a variável cDeCampos.
				
				if !empty(cDeCampos) .and. valType(::cCmpStat) <> 'U' .and. !empty(::cCmpStat)
					
					if allTrim(::aCpoObri[nInd]) $ cDeCampos .or. ::aCols[nCont][GdfieldPos(::cCmpStat,::aHeader)] == "ENABLE"
						loop
					endIf
					
				endIf		
				
				if empty(::aCols[nCont,naScan])
				
					lFlag := .f.
					
					aadd(aCampos,{allTrim(::aHeader[naScan,2]),allTrim(::aHeader[naScan,1])})
				
				endIf
				
			endIf
			
		next
		
	endIf
	
next

if ! lFlag .and. lMsg

	//exibir os campos obrigatorios
	PLSCRIGEN(aCampos,{ {STR0009,"@C",50},{STR0010,"@C",100} },STR0011+"   "+STR0012+" [ "+::cTitulo+" ]") //"Campo"###"Descricao"###"Existem campos obrigatorios que nao foram informados."###"Verifique no Browse"

endIf

return(lFlag)

/*/{Protheus.doc} semOk
semOk
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD semOk() CLASS TBRWPLS
local lReturn	:= .f.

lReturn := ::plBlock(::aCols,::aHeader,::linha(),::aSemaf)
	
return(lReturn)

/*/{Protheus.doc} coluna
coluna
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD coluna(cNameCol) CLASS TBRWPLS
local nCol	:= 0

nCol := aScan(::aHeader,{|a| allTrim(a[2]) $ allTrim(cNameCol)})

if nCol == 0

	msgStop(STR0007+cCampo)//Nao-conformidade METHOD coluna(cNameCol)

endIf

return(nCol)

/*/{Protheus.doc} plRetPos
plRetPos
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD plRetPos(cCampo,lHelp,aHead) CLASS TBRWPLS
local nCol	:= 0
local oObj 	:= SELF

default lHelp := .t.
default aHead := {}

nCol := aScan(::aHeader,{|a| allTrim(a[2]) == allTrim(cCampo)})

if nCol == 0

	nCol := aScan(aHead,{|a| allTrim(a[2]) == allTrim(cCampo)})
	
	if nCol == 0 .and. lHelp

		msgStop(STR0013+cCampo)//"Nao-conformidade METHOD plRetPos de BRWPLS campo "

	endIf

endIf

return(nCol)

/*/{Protheus.doc} grava
grava
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD grava(aChave,lforce,lObrig) CLASS TBRWPLS
default lforce := PlsSetforce()
default lObrig := .t.

if ! ( ::nOpc == K_Incluir .or. ::nOpc == K_Alterar .or. ::nOpc == K_Excluir )
	return(.t.)
endIf

if valType(::oPai) == "O"

	if ::oPai:lAltered
		lforce := .t.
	endIf

endIf

if ::lAltered .or. lforce
	::consiste()
endIf

//um folder que nao teve inclusao, alteracao etc nao precisa ser atualizado...  
if ::lAltered .or. lforce

	PLUPTCOLS(::cAlias, ::retACols(), ::aHeader, ::aVetTrab, ::nOpc, aChave, lObrig, nil, nil, ::retRAlt())

endIf

return .t.

/*/{Protheus.doc} fieldGet
fieldGet
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD fieldGet(cCampo,nLine,aObsoleto) CLASS TBRWPLS
local uValor := ""
local uplRetPos := ::plRetPos(cCampo,.f.,::aHeader)

default nLine 	:= ::linha()

if uplRetPos > 0 .and. len(::aCols) > 0
	uValor := ::aCols[nLine,uplRetPos]
endIf
	
return uValor

/*/{Protheus.doc} fieldPut
fieldPut
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD fieldPut(cCampo,uValor,nLine,aObsoleto) CLASS TBRWPLS
default nLine := ::linha()

nPos := ::plRetPos(cCampo,.f.,::aHeader)

if nPos > 0

	::aCols[nLine,nPos] := uValor

	::lAltered := .t.
	
	if aScan(::aRecAlt, { |x| x[4] == nLine } ) == 0
		if ::nOpc == K_Alterar .and. ::Recno(nLine) > 0 
			aadd(::aRecAlt,{ ::cAlias, 'A', ::Recno(nLine), nLine } )
		else
			aadd(::aRecAlt,{ ::cAlias, 'I', ::Recno(nLine), nLine } )
		endIf	
	endIf

endIf
	
return

/*/{Protheus.doc} fieldPos
fieldPos
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD fieldPos(cCampo,aObsoleto) CLASS TBRWPLS
return ::plRetPos(cCampo,.f.,::aHeader)

/*/{Protheus.doc} setArray
setArray
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD setArray(aArray) CLASS TBRWPLS

::aCols 		:= aClone(aArray)
::oBrowse:aCols	:= ::aCols
::oBrowse:setArray(::aCols)
::lAltered := .t.

return .t.

/*/{Protheus.doc} filtra
filtra
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD filtra(bFilter,lInic,aColsAux) CLASS TBRWPLS
local nInd		:= 0
local nI 		:= 0
local nPos 		:= 0
local nLin 		:= 0
local nLinAux	:= 0
local aDadosSav := {}

default lInic 	:= .f.
default bFilter := ::bFilter

if bFilter == nil .or. ::lFilter

	nLinsetPos := len(::aCols)

	return

endIf

oObjBRG := SELF

//acontecia que quando colocamos oObj:aVetTrab := aTrb ele nao fazia o tratamento      
//que o new() da classe faz, colocando zero ate a qtd do acols.. vou fazer isso aqui...
if len(::aVetTrab) == 0

	::aVetTrab := aSize(::aVetTrab,len(::aCols))

	for nInd := 1 to len(::aCols)

		if ::aVetTrab[nInd] == nil

			::aVetTrab[nInd] := 0

		endIf

	next

endIf

::aColsNoFil := aClone(::aCols)
::aVetNoFil  := aClone(::aVetTrab)
::lFilter    := .t.
::aCols      := {}
::aVetTrab   := {}
::aItcolDel  := {}

for nI := 1 to len(::aColsNoFil)

	if !eval(bFilter,nI,::aColsNoFil,::aHeader)
		loop
	endIf
	
	aadd(::aItcolDel,nI)
	aadd(::aCols,aClone(::aColsNoFil[nI]))
	aadd(::aVetTrab,::aVetNoFil[nI])
	
next

if len(::aCols) == 0
	
	n := 1
	
	Store COLS Blank ::cAlias to ::aCols FROM ::aHeader
	
	//Verifica se no registro novo (blank) tem campo virtual e limpa o conteudo
	
	while ( (nPos := aScan(::aHeader,{|x| x[10] == 'V'} )) > 0  )
	
		if !empty(::aCols[len(::aCols),nPos])
			::aCols[len(::aCols),nPos] := ""
		endIf
		
		exit
		
	endDo
	
	if aColsAux == nil
		if len(self:oBrowse:aCols) > 0
			aadd(::aColsNoFil,aClone(::oBrowse:aCols[1]))
		endIf	
	else
		aadd(::aColsNoFil,aClone(aColsAux))
	endIf
	
	aadd(::aItcolDel,len(::aColsNoFil))
	aadd(::aVetTrab,0)
	aadd(::aVetNoFil,0)
	
endIf

if !lInic
	
	n := 1
	
	if type("nLinsetPos") <> "U"
		nLinsetPos := len(::aCols)
	endIf
	
	::refresh()
	
	nLinAux := ::linha()
	
	for nI := 1 to len(::aCols[nLinAux])
		aadd(aDadosSav,::aCols[nLinAux,nI])
	next
	
	nLin := PosACols(::aCols,aDadosSav)
	
	if nLin == 1
		
		::oBrowse:aCols := ::aCols
		::oBrowse:setArray(::aCols)
		
		::oBrowse:oBrowse:nAt := nLin
		::oBrowse:forceRefresh()
		
		eval(::oBrowse:oBrowse:bChange)
		
	endIf
	
endIf

return .t.

/*/{Protheus.doc} endFilter
endFilter
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD endFilter(lInterface) CLASS TBRWPLS
local nI	:= 0
local nLine := 0

default lInterface := .t.

if !::lFilter
	return
endIf

if valType(::oBrowse:oBrowse) # "O"
	lInterface := .f.
endIf

for nI := 1 to len(::aItColDel)
	
	lColsNoFil := .f.
	lVetNotFil := .f.
	
	//tratamento realizado para os casos em que o aColsNoFil esteja zerado
	if valType(::aColsNoFil) <> "U"  
	
		if len(::aColsNoFil) > 0 .and. len(::aColsNoFil) >= ( (::aItcolDel[nI] - nI) + 1 )
	
			aDel( ::aColsNoFil, (::aItColDel[nI] - nI) + 1 )
	
			lColsNoFil := .t.
	
		endIf
		
	endIf
	
	//tratamento realizado para os casos em que o aVetNoFil esteja zerado
	if valType(::aVetNoFil) <> "U"
		
		if len(::aVetNoFil) > 0	.and. len(::aVetNoFil) >= ( (::aItcolDel[nI] - nI) + 1)
			
			aDel( ::aVetNoFil, (::aItColDel[nI] - nI) + 1 )
			
			lVetNotFil := .t.
			
		endIf

	endIf

	if 	lVetNotFil
		aSize( ::aVetNoFil, len(::aVetNoFil) - 1 )
	endIf
	
	if lColsNoFil
		aSize( ::aColsNoFil, len(::aColsNoFil) - 1 )
	endIf
	
next

nLine := len(::aColsNoFil)

for nI := 1 to len(::aCols)

	aadd(::aColsNoFil,aClone(::aCols[nI]))

	if len(::aVetTrab) >= nI

		aadd(::aVetNoFil,::aVetTrab[nI])

	endIf

next

if lInterface

	nLine += ::linha()

	::oBrowse:aCols   := aClone(::aColsNoFil)

endIf

::aCols 	:= aClone(::aColsNoFil)
::aVetTrab 	:= aClone(::aVetNoFil)

if lInterface

	::oBrowse:oBrowse:nAt := nLine

	n := nLine
	
	::oBrowse:oBrowse:refresh()
	
endIf

::lFilter    := .f.
::aColsNoFil := {}
::aVetNoFil  := {}
::aItcolDel  := {}

return .t.

/*/{Protheus.doc} retACols
retACols
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD retACols() CLASS TBRWPLS

if ::lFilter
	
	::endFilter(.f.)
	
endIf
	
return ::aCols

/*/{Protheus.doc} retRAlt
retorna aRecAlt
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD retRAlt(aRecAlt, lCabAltered) CLASS TBRWPLS
local nI := 0

default aRecAlt 	:= {}
default lCabAltered := .f.

if ! lCabAltered

	if len(aRecAlt) == 0
		aRecAlt := ::aRecAlt
	else
	
		for nI := 1 to len(::aRecAlt)
		
			aadd(aRecAlt,::aRecAlt[nI])
			
		next
			
	endIf
	
//garante por exemplo caso o cabecalho tenha sido alterado exemplo BD5 a cFUNGRV vai rodar todos os itens.	
else
	aRecAlt := { {"","",0,0} }
endIf

return aRecAlt

/*/{Protheus.doc} forceRefresh
forceRefresh
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD forceRefresh(oObj) CLASS TBRWPLS
local nNPosAnt   := N
local oObjBRGOld := oObjBRG
local nLinObj    := 0
local cAliObj    := ''
local nRecObj    := 0

default oObj := self

if oObj:cAlias <> alias()

    nLinObj := oObj:oBrowse:nAt
    cAliObj := oObj:cAlias
    nRecObj := oObj:recno(oObj:oBrowse:nAt)

    if nRecObj <> (cAliObj)->(recno())
        (cAliObj)->(dbGoTo(nRecObj))
    endIf    

else

    nRecObj := ::recno(nNPosAnt)
    
    if nRecObj <> recno()
        dbGoTo(nRecObj)
    endIf

endIf

if valType(::oBrowse) <> "U"

	::oBrowse:oBrowse:lDisablePaint	:= .f.
	::oBrowse:aCols   				:= ::aCols
	
	if valType(::bFilter) == "B"
	
		::filtra(::bFilter,.t.)
		
	endIf
	
	n := 1
	
	::oBrowse:forceRefresh()
	::endFilter()
	
	oObjBRG := oObjBRGOld
	
	N := nNPosAnt
	
	::oBrowse:oBrowse:lDisablePaint := .t.
	
endIf
	
return

/*/{Protheus.doc} forceAtualiza
forceAtualiza
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD forceAtualiza(lFocusBrow) CLASS TBRWPLS
local lFilter 		:= ::lFilter

default lFocusBrow  := .t. 

if lFilter
	::endFilter()
endIf

::filtra()

::oBrowse:setArray(::aCols)

if ::oBrowse:oBrowse:nAt > len(::aCols)
	::oBrowse:oBrowse:nAt := 1
endIf

::oBrowse:refresh()

::lAltered := .t.

if lFocusBrow
	::oBrowse:oBrowse:SetFocus()
endIf

return

/*/{Protheus.doc} consiste
consiste
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD consiste() CLASS TBRWPLS
	
if valType(::oPai) == "O"
	PlsConsiste(::oPai:aCols,::oPai:aHeader,::aOrigem,::aCols,::aHeader,::aRelac,::aRecAlt, self)
endIf
	
return

/*/{Protheus.doc} isDeleted
isDeleted
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD isDeleted(nLine)	CLASS TBRWPLS
default nLine := ::linha()
	
return ::aCols[nLine,::colDel()]

/*/{Protheus.doc} chkDel
chkDel
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD chkDel()	CLASS TBRWPLS
local nRecno := ::recno() 
local nPos	 := aScan(::aRecAlt, { |x| x[3] == nRecno } )

if nRecno > 0

	if ! ::isDeleted() .and. nPos == 0
	
		aadd(::aRecAlt,{ ::cAlias, 'E', nRecno, ::linha()} )
		
	elseIf nPos > 0 .and. ::aRecAlt[nPos,2] == 'E'
	
		nTam := len(::aRecAlt)
		aDel(::aRecAlt,nPos)
		aSize(::aRecAlt,nTam-1)
		
	endIf
	
endIf
	
return

/*/{Protheus.doc} brwSeek
brwSeek
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD brwSeek(nOrdem,cChave) CLASS TPLSBRW
local nfor    	:= 0
local nCont     := 0
local cFieldKey	:= ""
local cCampoAux	:= ""
local lFound    := .t.
local aCampos   := {}
local aKeys     := {}

SIX->( dbSetOrder(1) )
if SIX->( msSeek(cAlias+Str(nOrdem)) )

	cFieldKey := allTrim(SIX->INDICE)
	cFieldKey := strTran(cFieldKey," ","")
	cFieldKey := strTran(cFieldKey,"(","")
	cFieldKey := strTran(cFieldKey,")","")
	cFieldKey := strTran(upper(cFieldKey),"STR","")
	cFieldKey := strTran(upper(cFieldKey),"DtoS","")
	
	cCampoAux := ""
	
	nInicio   := 0
	
	for nfor  := 1 to len(cFieldKey)
	
		if subs(cFieldKey,nfor,1) <> "+"
		
			if nCont == 0
				nCont := nfor
			endIf
			
			cCampoAux += subs(cFieldKey,nfor,1)
			
		else
		
			if ::plRetPos(cCampoAux,.f.) > 0
			
				aadd(aCampos,cCampoAux)
				aadd(aKeys,subs(cChave,nCont,nfor))
				
			endIf
			
			cCampoAux := ""
			nCont     := 0
			
		endIf
		
	next
	
endIf

return(lFound)

/*/{Protheus.doc} verExiData
verExiData
@type method
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
METHOD verExiData() CLASS TBRWPLS
local _nAux
local _lOK := .f.

for _nAux := 1 to len(::aCols)
	
	if ! ::isDeleted() .and. ::linhaOK(.f.,_nAux)
		_lOK := .t.
	endIf
	
next

return(_lOK)

/*/{Protheus.doc} BRWPLSEnc
BRWPLSEnc
@type function
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
function BRWPLSEnc()
return lEnchoice

/*/{Protheus.doc} PlsEndBrw
PlsEndBrw
@type function
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
function PlsEndBrw()

if valType(oObjBRG) == "O"
	oObjBRG:endFilter()
endIf

return

/*/{Protheus.doc} PlsConsiste
PlsConsiste
@type function
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
function plsConsiste(aPaiCols,aPaiHeader,aPaiCpo,aFilCols,aFilHeader,aFilCpo,aRecAlt,oObj)
local nI		:= 0
local nJ		:= 0
local nK		:= 0
local nRecno	:= 0
local nTamPai 	:= 0 
local nTamFil 	:= 0 
local aAuxPai	:= aClone(aPaiCols)
local cFind		:= ""
local cChkPai 	:= ""
local cChkFil	:= ""
local cCompFil	:= ""

default aRecAlt 	:= { {"","",0,0} }
default oObj		:= nil
default aPaiCpo		:= {}
default aFilCols	:= {}
default aFilHeader	:= {}
default aFilCpo		:= {}
default aRecAlt		:= {}

nTamPai := len(aPaiHeader) + 1 
nTamFil := len(aFilHeader) + 1 

aSort(aAuxPai,,,{|a,b| a[nTamPai] > b[nTamPai] })

for nI := 1 to len(aAuxPai)

	if ! aAuxPai[ nI, nTamPai ]
		exit
	endIf
	
	if aScan( aAuxPai, {|x| procCols(x, aPaiHeader, aPaiCpo, aAuxPai[nI]) }, nI + 1 ) > 0
		loop
	endIf
	
	cFind	:= "aScan(aFilCols, {|x| "
	cChkPai := ""
	cChkFil	:= ""
	cCompFil:= ""
	
	for nJ := 1 to len(aPaiCpo)
	
		nPos := gdFieldPos(aPaiCpo[nJ], aPaiHeader)
	
		if nPos == 0
			msgStop(STR0014 + aPaiCpo[nJ])//"Erro no PlsConsiste. Campo nao encontrado "
		else
			cChkPai += aAuxPai[nI,nPos] 
		endIf
		
	next
	
	for nJ := 1 to len(aFilCpo)
			
		nPos := gdFieldPos(aFilCpo[nJ], aFilHeader)
		
		if nPos == 0
			msgStop(STR0014 + aFilCpo[nJ])//"Erro no PlsConsiste. Campo nao encontrado "
		else
			cChkFil += "x[" + cValToChar(nPos) + "]" + iIf(nJ < len(aFilCpo), "+","")
			cCompFil+= "aFilCols[nK," + cValToChar(nPos) + "] " + iIf(nJ < len(aFilCpo), "+","")
		endIf	
		
	next
	
	cFind += cChkFil + " == '" + cChkPai + "' } )"

	nPos := &cFind
	
	if nPos > 0
	
		//roda o array filho
		for nK := nPos to len(aFilCols)
	
			if &cCompFil != cChkPai
				exit
			endIf

			aFilCols[ nK, nTamFil ] := .t.
			
			if oObj <> nil
			
				oObj:lAltered := .t.
				
				if oObj != nil
					
					nRecno := oObj:recno(nK)
				
					if aScan(aRecAlt, { |x| x[3] == nRecno } ) == 0
						aadd(aRecAlt, { oObj:cAlias, 'E', nRecno, nK } )
					endIf
					
				endIf
				
			endIf	
				
		next
		
	endIf
	
next

return

/*/{Protheus.doc} FunTeste
FunTeste
@type function
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
function FunTeste(oBrowse)

x := 1
oBrowse:addLine()

return

/*/{Protheus.doc} PlsSetforce
PlsSetforce
@type function
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
function PlsSetforce(lforce)
local lforceAnt	 := .f.

static lSetforce := .f.

lforceAnt := lSetforce

if lforce # nil
	lSetforce := lforce
endIf

return lforceAnt

/*/{Protheus.doc} PosACols
PosACols
@type function
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
static function PosACols(aCols,aDados)
local nPos 	:= 1
local nI 	:= 0
local nJ 	:= 0
local lIgual:= .f.

for nI := 1 to len(aCols)

	lIgual := .t.

	for nJ := 1 to len(aDados)

		if aCols[nI,nJ] # aDados[nJ]
			lIgual := .f.
			exit
		endIf

	next

	if lIgual
		nPos := nI
		exit
	endIf

next
	
return nPos

/*/{Protheus.doc} ProcCols
ProcCols
@type function
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
static function ProcCols(aLine,aHeader,aCamp1,aLineAtu)
local nI	:= 0
local nPos  := 0
local lRet 	:= .t.

if aLine[len(aHeader)+1]
	return .f.
endIf

for nI := 1 to len(aCamp1)

	nPos := GdfieldPos(aCamp1[nI],aHeader)

	if aLine[nPos] # aLineAtu[nPos]
		lRet := .f.
	endIf
	
next

return lRet

/*/{Protheus.doc} CpoObri
CpoObri
@type function
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
static function CpoObri(cCampo)
local aArea 	:= getArea()
local lObrig	:= .f.

SX3->(dbSetOrder(2))
SX3->(msSeek(cCampo))

lObrig := X3Obrigat(SX3->X3_CAMPO)

restArea(aArea)
	
return lObrig

/*/{Protheus.doc} _BRWPLS
_BRWPLS
@type function
@author PLSTEAM
@since 16.07.01
@version 1.0
/*/
function _BRWPLS()
return .t.
 
