#INCLUDE "Protheus.ch"
#INCLUDE "OMSA180.CH"
#INCLUDE "FWMVCDEF.CH"
//---------------------------------------
/*	Manutencao do Modelo de Carga
@author 	Flavio Luiz Vicco
@version	P11
@build		7.00.101202A
@since		16/09/2013
@return		oView Objeto do View*/
//---------------------------------------
Function OMSA180()
Local oMBrowse	:= Nil

Private aRotina := MenuDef()

dbSelectArea("DB0")
dbSetOrder(1) //DB0_FILIAL+DB0_CODMOD

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("DB0")
oBrowse:SetMenuDef("OMSA180")
oBrowse:SetDescription(STR0001) //"Cadastro de Modelos de Carga"
oBrowse:Activate()

Return .T.

//-------------------------------------
/*	MenuDef
@author		Flavio Luiz Vicco 
@version	P11
@since		16/09/2013
@return		aRotina    */
//-------------------------------------
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.OMSA180" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.OMSA180" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.OMSA180" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.OMSA180" OPERATION 5 ACCESS 0
Return (aRotina)

//-------------------------------------
/*	Modelo de Dados
@author  	Flavio Luiz Vicco
@version 	P11
@build		7.00.101202A
@since 		16/09/2013
@return		oModel Objeto do Modelo*/
//-------------------------------------
Static Function ModelDef()
Local oModel   := Nil
Local oStruDB0 := FWFormStruct( 1, "DB0" )

oModel:= MpFormModel():New("OMSA180", /*Pre-Validacao*/, { |oModel| PosVldMdl( oModel ) }, /*Commit*/, /*Cancel*/)
oModel:SetDescription(STR0001) //"Cadastro de Pauta de Frete"

oModel:AddFields("DB0MASTER",/*cOwner*/,oStruDB0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:SetPrimaryKey( { "DB0_FILIAL", "DB0_CODMOD" } )

Return(oModel)

//-------------------------------------
/*	ViewDef
@author	Flavio Luiz Vicco
@version 	P11
@since 		16/09/2013
@return	oView  View do Cadastro*/
//-------------------------------------
Static Function ViewDef()
Local oView    := Nil
Local oModel   := FwLoadModel("OMSA180")
Local oStruDB0 := FWFormStruct( 2, "DB0" )

oView:= FWFormView():New()
oView:SetModel(oModel)

oView:AddField( "VIEW_DB0", oStruDB0, "DB0MASTER")

Return(oView)

//--------------------------------------------------------------
/*/{Protheus.doc}
 Validacao na exclusao do modelo de carga
@param		oModel Objeto do Modelo
@author		Flavio Luiz Vicco
@version	P11
@Since		16/09/13
/*/ 
//--------------------------------------------------------------
Static Function PosVldMdl( oMdl )
Local lRet   := .T.
Local aArea  := GetArea()
Local cQuery := ""
Local cAlias := ""
Local nOpcx  := oMdl:GetOperation()

If nOpcx == MODEL_OPERATION_DELETE
	cAlias := "QRYSB1"
	cQuery := "SELECT 1 RECSB1 FROM "+RetSqlName("SB1")+ " SB1 "
	cQuery += "WHERE "
	cQuery += "B1_FILIAL = '"+xFilial("SB1") +"' AND "
	cQuery += "B1_TIPCAR = '"+DB0->DB0_TIPCAR+"' AND "
	cQuery += "SB1.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)
	If (cAlias)->RECSB1 > 0
		lRet := .F.
		Help(" ",1,"OMS180EXCL")
	EndIf
	(cAlias)->(dbCloseArea())
EndIf
RestArea( aArea )

Return(lRet)
