#INCLUDE "TMSAF70.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


/*
-----------------------------------------------------------
{Protheus.doc} TMSAF70()
Cadastro de Negociações 

Uso: SIGATMS

@sample
//TMSAF70()

@author Valdemar Roberto Mognon.
@since 08/12/2014
@version 1.0
-----------------------------------------------------------
*/

Function TMSAF70()
Local oBrowse

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DDB")
oBrowse:SetMenuDef("TMSAF70")
oBrowse:SetDescription(STR0001)	//-- Cadastro de Negociações
oBrowse:Activate()

Return Nil            

/*
-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  

Uso: TMSAF70

@sample
//MenuDef()

@author Valdemar Roberto Mognon
@since 08/12/2014
@version 1.0
-----------------------------------------------------------
*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //-- Pesquisar
ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSAF70" OPERATION 2 ACCESS 0 //-- Visualizar
ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSAF70" OPERATION 3 ACCESS 0 //-- Incluir
ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSAF70" OPERATION 4 ACCESS 0 //-- Alterar
ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSAF70" OPERATION 5 ACCESS 0 //-- Excluir

Return aRotina

/*
-----------------------------------------------------------
{Protheus.doc} ModelDef()
Definição do Modelo

Uso: TMSAF70

@sample
//ModelDef()

@author Valdemar Roberto Mognon
@since 08/12/2014
@version 1.0
-----------------------------------------------------------
*/

Static Function ModelDef()
Local oModel
Local oStruDDB

oStruDDB:= FWFormStruct(1,"DDB")

oModel := MPFormModel():New("TMSAF70",,{|oModel|PosVldMdl(oModel)},/*bCommit*/, /*bCancel*/)

oModel:AddFields("MdFieldDDB",,oStruDDB,,,/*Carga*/)
oModel:GetModel("MdFieldDDB"):SetDescription(STR0001)	//-- Cadastro de Negociações
oModel:SetPrimaryKey({"DDB_FILIAL","DDB_CODNEG"})  
     
oModel:SetActivate()
     
Return oModel 

/*
-----------------------------------------------------------
{Protheus.doc} ViewDef()
Definição da View

Uso: TMSAF70

@sample
//ViewDef()

@author Valdemar Roberto Mognon
@since 08/12/2014
@version 1.0
-----------------------------------------------------------
*/

Static Function ViewDef()     
Local oModel
Local oStruDDB
Local oView

oModel   := FwLoadModel("TMSAF70")
oStruDDB := FWFormStruct(2,"DDB")

oView := FwFormView():New()

oView:SetModel(oModel)     
oView:AddField('VwFieldDDB',oStruDDB,"MdFieldDDB")
oView:CreateHorizontalBox("CABECALHO",100)  
oView:SetOwnerView("VwFieldDDB","CABECALHO")

Return oView

/*
-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
Validação do Modelo

Uso: TMSAF70

@sample
//PosVldMdl(oModel)

@author Valdemar Roberto Mognon
@since 08/12/2014
@version 1.0
-----------------------------------------------------------
*/

Static Function PosVldMdl(oModel)
Local aArea      := GetArea()
Local lRet       := .T.
Local nOperation := 0
Local cQuery     := ""
Local cAliasQry  := ""

nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_DELETE
	cAliasQry := GetNextAlias()
	cQuery := "SELECT COUNT(*) NTOTAL "
	cQuery += "  FROM " + RetSQLName("DF1") + " DF1 "
	cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
	cQuery += "   AND DF1.DF1_CODNEG = '" + DDB->DDB_CODNEG + "' "
	cQuery += "   AND DF1.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	
	If (cAliasQry)->NTOTAL > 0                
		Help(' ', 1, 'TMSAF7001' )	//-- Não é permitido excluir um Tipo de Negociação já relacionado a um agendamento.
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
EndIf	

Return lRet
