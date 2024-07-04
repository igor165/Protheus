#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA272
Função para cadastro de Grupo de Beneficiarios Habituais de intercambio (B5F) Modelo 3 em MVC

@author  Lucas Nonato
@version P12
@since   16/04/2018
/*/
//------------------------------------------------------------------- 
Function PLSA272()
Local aArea   := GetArea()
Local oBrowse

oBrowse := FWMBrowse():New()    
oBrowse:SetAlias("B5F")    
oBrowse:SetDescription("Beneficiarios Habituais")
oBrowse:SetMenuDef( 'PLSA272' )      

oBrowse:Activate()
 
RestArea(aArea)
Return Nil
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Criação do menu MVC

@author  Lucas Nonato
@version P12
@since   16/04/2018
/*/
//-------------------------------------------------------------------  
Static Function MenuDef()
Local aRotina := {} 

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.PLSA272' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Criação do modelo de dados MVC 

@author  Lucas Nonato
@version P12
@since   16/04/2018
/*/
//------------------------------------------------------------------- 
Static Function ModelDef()
Local oModel        := Nil
Local oStPai        := FWFormStruct(1, 'BA1')
Local oStFilho     	:= FWFormStruct(1, 'B5F')
Local aB5FRel        := {}
 
oModel := MPFormModel():New('PLSA272M')
oModel:AddFields('BA1MASTER',/*cOwner*/,oStPai)
oModel:AddGrid('B5FDETAIL','BA1MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/) 
 
// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'B5FDETAIL', { 	{ 'B5F_FILIAL', 'BA1->BA1_FILIAL' },; 
									{ 'B5F_CODINT', 'BA1->BA1_CODINT' },; 
									{ 'B5F_CODEMP', 'BA1->BA1_CODEMP' },; 
									{ 'B5F_MATRIC', 'BA1->BA1_MATRIC' },; 
									{ 'B5F_TIPREG', 'BA1->BA1_TIPREG' },; 
									{ 'B5F_DIGITO', 'BA1->BA1_DIGITO' } }, B5F->(IndexKey(3)) )

oModel:GetModel('B5FDETAIL'):SetUniqueLine({"B5F_FILIAL","B5F_OPEORI","B5F_OPEHAB","B5F_CODINT","B5F_CODEMP","B5F_MATRIC","B5F_TIPREG","B5F_DIGITO","B5F_VIGINI"})   
oModel:SetPrimaryKey({})
 
oModel:SetDescription("Beneficiários Habituais Intercambio")
oModel:GetModel('BA1MASTER'):SetDescription('Beneficiarios')
oModel:GetModel('B5FDETAIL'):SetDescription('Habitualidade')
oModel:GetModel('BA1MASTER'):SetOnlyView ( .T. )
Return oModel
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Criação da visão MVC   

@author  Lucas Nonato
@version P12
@since   16/04/2018
/*/
//-------------------------------------------------------------------  
Static Function ViewDef()
Local aArea   	:= GetArea()
Local oView		:= Nil
Local oModel	:= FWLoadModel('PLSA272')
Local oStPai	:= FWFormStruct(2, 'BA1')
Local oStFilho	:= FWFormStruct(2, 'B5F')

oView := FWFormView():New()
oView:SetModel(oModel)     

oView:AddField('VIEW_BA1',oStPai,'BA1MASTER')
oView:AddGrid('VIEW_B5F',oStFilho,'B5FDETAIL')     

oView:CreateHorizontalBox('CABEC',30)
oView:CreateHorizontalBox('GRID',70)     

oView:SetOwnerView('VIEW_BA1','CABEC')
oView:SetOwnerView('VIEW_B5F','GRID')     

oView:EnableTitleView('VIEW_BA1','Beneficiario')
oView:EnableTitleView('VIEW_B5F','Habitualidade')

oStFilho:RemoveField('B5F_MATANT')

RestArea(aArea)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS272GRV
Gravação da tabela B5F para rotinas de processamento   

@author  Lucas Nonato
@version P12
@since   16/04/2018
/*/
//-------------------------------------------------------------------
Function PLS272GRV( nOpc, aCampos ) 
local oAux		:= nil
local oStruct	:= nil
local oModel	:= nil
local aAux		:= {}
local aErro		:= {}
local cModel 	:= "B5FMASTER"
local cLoadModel:= "PLSA272M"
local nI		:= 0
local nPos		:= 0

local lRet := .T.

oModel := FWLoadModel( cLoadModel )
oModel:setOperation( nOpc )
oModel:activate()

oAux	:= oModel:getModel( cModel )
oStruct	:= oAux:getStruct()
aAux	:= oStruct:getFields()

if( nOpc <> MODEL_OPERATION_DELETE )
	begin Transaction
		for nI := 1 to len( aCampos )
			if( nPos := aScan( aAux,{| x | allTrim( x[ 3 ] ) == allTrim( aCampos[ nI,1 ] ) } ) ) > 0
				if !( lRet := oModel:setValue( cModel,aCampos[ nI,1 ],aCampos[ nI,2 ] ) )
					aErro := oModel:getErrorMessage()				
					
					PlsPtuLog("------------------------------------------------------------------", "RN430.log")
					PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "RN430.log")
					PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "RN430.log")
					PlsPtuLog("Conteudo do erro: " 			+ ' [' + AllToChar( aErro[ 9 ] ) + ']', "RN430.log")							
					PlsPtuLog("------------------------------------------------------------------", "RN430.log")						
					disarmTransaction()
					exit
				endif
			endIf
		next nI
	end Transaction
endIf		

if( lRet := oModel:vldData() )
	oModel:commitData()
else
	aErro := oModel:getErrorMessage()				
	PlsPtuLog("------------------------------------------------------------------", "RN430.log")
	PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "RN430.log")
	PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "RN430.log")						
	PlsPtuLog("------------------------------------------------------------------", "RN430.log")		
	disarmTransaction()
endif

oModel:deActivate()
oModel:destroy()
freeObj( oModel )
oModel := nil
delClassInf()

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS272VLD
Posiciona no habitual com vigencia ativa.

@author  Lucas Nonato
@version P12
@since   16/04/2018
/*/
//-------------------------------------------------------------------
function PLS272VLD(cOpeOri, cOpeHab, cMatric, dData, cCodInt) 

local cSql	:= ""
local lRet	:= .f.
default cCodInt := cOpeOri

cSql := " SELECT B5F.R_E_C_N_O_ RECNO, B5F_VIGFIM FROM " + RetSQLName("B5F") + " B5F "
cSql += " WHERE B5F_FILIAL = '" + xFilial("B5F") + "' "
cSql += " AND B5F_OPEORI = '"+ cOpeOri +"' "
cSql += " AND B5F_OPEHAB = '"+ cOpeHab +"' "
cSql += " AND B5F_CODINT = '"+ cCodInt +"' "
cSql += " AND B5F_CODEMP = '"+ substr(cMatric,1,4) +"' "
cSql += " AND B5F_MATRIC = '"+ substr(cMatric,5,6) +"' "
cSql += " AND B5F_TIPREG = '"+ substr(cMatric,11,2) +"' "
cSql += " AND B5F_DIGITO = '"+ substr(cMatric,13,1) +"' "
cSql += " AND B5F.D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbVLD",.F.,.T.)

while !TrbVLD->(eof())
	if empty(TrbVLD->B5F_VIGFIM) .or. stod(TrbVLD->B5F_VIGFIM) >=  dData
		B5F->(dbgoto(TrbVLD->RECNO))
		lRet := .t.
		exit
	endif
	TrbVLD->(dbskip())
enddo 

TrbVLD->(dbclosearea())
return lRet

  
//-------------------------------------------------------------------
/*/{Protheus.doc} P272VldFie
Valida digitacao dos campos de Operadora

@author  Renan Sakai
@version P12
@since   16/04/2018
/*/
//-------------------------------------------------------------------
Function P272VldFie() 
Local lRet := .T.

if ReadVar() == "M->B5F_OPEORI" .And. ;  
	(BA1->BA1_CODEMP <> GetNewPar("MV_PLSGEIN","0050")) .And. ;
	(M->B5F_OPEORI <> PlsIntPad() )

	MsgInfo("Para beneficiário local, a Operadora Origem deve ser a Padrão.")
	lRet := .F.
endIf
       
if ReadVar() == "M->B5F_OPEHAB" .And. ;  
	(BA1->BA1_CODEMP <> GetNewPar("MV_PLSGEIN","0050")) .And. ;
	(M->B5F_OPEHAB == PlsIntPad() )

	MsgInfo("Para beneficiário local, a Operadora Destino deve ser diferente da Padrão.")
	lRet := .F.
endIf

Return lRet