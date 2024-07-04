#INCLUDE "PLSEXCEUS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "PLSMGER.CH"

#DEFINE PLS_MODELO_CABECALHO	"VIEWDEF.PLSEXCEUS"
#DEFINE PLS_MODELO_ITENS 		"PLSEXCEUS"
#DEFINE PLS__ALIAS_CABECALHO 	"B4R"
#DEFINE PLS_TITULO 	STR0001//"Exceção de cobrança de participação"
#DEFINE PLS_CORLIN 	"#D6E4EA"

STATIC cString := ""

//------------------------------------------------------------------- 
/*/{Protheus.doc} PLSEXCEUS
Excessão de participação
@author: Thiago Ribas
@since : 07-16
/*/
//-------------------------------------------------------------------
Function PLSEXCEUS()

LOCAL aArea     := GetArea()
LOCAL cFiltro   := " B4R->B4R_CODRDA == '" + BAU->BAU_CODIGO + "'"
PRIVATE aRotina := {}

oB4R := FWmBrowse():New()
oB4R:SetProfileID( '0' )
oB4R:SetAlias( PLS__ALIAS_CABECALHO ) 
oB4R:SetDescription( PLS_TITULO )
oB4R:SetMenuDef(PLS_MODELO_ITENS)
oB4R:DisableDetails()
oB4R:SetFilterDefault(cFiltro)
oB4R:ForceQuitButton()
oB4R:SetAmbiente(.T.)
oB4R:SetWalkThru(.T.)
oB4R:SetBlkBackColor( {||PLS_CORLIN} )
oB4R:setMainProc("PLSEXCEUS")
oB4R:Activate()                  

RestArea( aArea )           
        
Return NIL

//------------------------------------------------------------------- 
/*/{Protheus.doc} MenuDef

@author: Thiago Ribas
@since : 07-16
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'  Action 'PesqBrw'          	OPERATION 1 ACCESS 0
ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.PLSEXCEUS' 	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.PLSEXCEUS' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.PLSEXCEUS' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.PLSEXCEUS' 	OPERATION 5 ACCESS 0
Return aRotina

//------------------------------------------------------------------- 
/*/{Protheus.doc} ModelDef

@author: Thiago Ribas
@since : 07-16
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

LOCAL oModelExP

// Cria o objeto do Modelo de Dados

Local oStrB4R:= FWFormStruct(1,'B4R')

oModelExP := MPFormModel():New( PLS_TITULO, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModelExP:AddFields( 'B4RMASTER', NIL, oStrB4R )
oModelExP:SetPrimaryKey( { "B4R_FILIAL", "B4R_CODRDA" } ) 

// Adiciona a descricao do Modelo de Dados
oModelExP:SetDescription( PLS_TITULO )

// Adiciona a descricao do Componente do Modelo de Dados
oModelExP:GetModel( 'B4RMASTER' ):SetDescription( PLS_TITULO )

Return oModelExP

//------------------------------------------------------------------- 
/*/{Protheus.doc} ViewDef

@author: Thiago Ribas
@since : 07-16
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSEXCEUS' )
Local oStruB4R := FWFormStruct(2, 'B4R')
Local oView    := FWFormView():New()

// Define qual o Modelo de dados será utilizado

oView:SetModel( oModel )
oView:AddField('B4R' , oStruB4R,'B4RMASTER' )

oView:SetViewAction( 'BUTTONOK', { |oView| } )

oView:CreateHorizontalBox( 'BOX1', 50)
oView:CreateVerticalBox( 'FORMB4R', 100, 'BOX1')

oView:SetOwnerView('B4R','FORMB4R')

Return oView

//------------------------------------------------------------------- 
/*/{Protheus.doc} PLEXBUNID
Monta a tela para selecuinar as unidades
@author: Thiago Ribas
@since : 07-16
/*/
//-------------------------------------------------------------------
Function PLEXBUNID()

	Static objCENFUNLGP := CENFUNLGP():New()

Local aDados 	:= {}
Local nCnt
Local oDlgMar
Local oDados
Local bOk		:= {|| nOpca := 1, oDlgMar:End() }
Local bCancel	:= {|| nOpca := 2, oDlgMar:End() }
Local nOpca		:= 0

cString := ""
//Default cString := ''

BD3->( dbSetorder(01) )
BD3->( MsSeek(xFilial("BD3")) )
BD3->( dbEval({|| Aadd(aDados, {.F., BD3_CODIGO, BD3_DESCRI})},,))
               
DEFINE MSDIALOG oDlgMar TITLE STR0004 FROM 018,005 TO 034, 100 //"Unidade de Saúde"

oDados := TcBrowse():New( 035, 002, 372, 080,,,, oDlgMar,,,,,,,,,,,, .F.,, .T.,, .F., )
ADD COLUMN TO oDados BITMAP DATA IF(!aDados[oDados:nAt,1],LoadBitmap( GetResources(), "LBNO" ),;
	LoadBitmap( GetResources(), "LBOK" )) TITLE "" WIDTH 015 ALIGN CENTERED NOHILITE

oDados:AddColumn(TcColumn():New(STR0005,nil,; //"Código"
	nil,nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil))
oDados:ACOLUMNS[2]:BDATA     := {|| aDados[oDados:nAt,2] }

oDados:AddColumn(TcColumn():New(STR0006,nil,; //"Descrição"
	nil,nil,nil,nil,115,.F.,.F.,nil,nil,nil,.F.,nil))
oDados:ACOLUMNS[3]:BDATA     := {|| aDados[oDados:nAt,3] }

oDados:BLDBLCLICK := {|| (aDados[oDados:nAt][1] := Iif(aDados[oDados:nAt][1], .F., .T.),;
	oDados:SetArray(aDados), oDados:Refresh()) }

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {.F., "BD3_CODIGO", "BD3_DESCRI"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oDados:aObfuscatedCols := aBls
	endif

oDados:SetArray(aDados)
oDados:Refresh()

ACTIVATE MSDIALOG oDlgMar CENTER ON INIT Eval({||EnChoiceBar(oDlgMar,{||Eval(bOk)},{||Eval(bCancel)},.F.)} )

If nOpca == 1
	For nCnt := 1 To Len(aDados)
		If aDados[nCnt][1]
			cString += Alltrim(aDados[nCnt][2])+','
		Endif
	Next
	cString := Substr(cString, 1, (Len(Alltrim(cString))-1))
Endif

lRefresh := .T.

Return cString

//------------------------------------------------------------------- 
/*/{Protheus.doc} PLLIMPCMP
Limpa os campos
@author: Thiago Ribas
@since : 07-16
/*/
//-------------------------------------------------------------------
Function PLLIMPCMP()


If ReadVar() == "M->B4R_CPADDE"
	M->B4R_CPRODE := SPACE(LEN(B4R->B4R_CPRODE))
	
ElseIf ReadVar() == "M->B4R_PADATE"
	M->B4R_PROATE := SPACE(LEN(B4R->B4R_PROATE))
	
ElseIf ReadVar() == "M->B4R_CODLOC"
	M->B4R_CODESP := SPACE(LEN(B4R->B4R_CODESP))
EndIf

RETURN .T.



Function PLVLDPROC()

LOCAL lRet := .T.

If ReadVar() == "M->B4R_CPRODE"
	If !EMPTY(M->B4R_PROATE) .AND. M->B4R_CPADDE + M->B4R_CPRODE > M->B4R_PADATE + M->B4R_PROATE
		Help( ,, 'Help',, STR0002, 1, 0 ) //"O Procedimento inicial é maior que o procedimento final."
		lRet := .F.
	EndIf

ElseIf ReadVar() == "M->B4R_PROATE"
	
	If !EMPTY(M->B4R_CPRODE) .AND. M->B4R_CPADDE + M->B4R_CPRODE > M->B4R_PADATE + M->B4R_PROATE
		Help( ,, 'Help',, STR0003, 1, 0 ) //"O Procedimento final é menor que o procedimento inicial."
		
		lRet := .F.
	EndIf
EndIf
Return lRet






















