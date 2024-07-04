#include "jura132a.ch"
#include "protheus.ch"
#include "parmtype.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

//----------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Especialidade do Contato

@author Daniel Magalhaes
@since 18/08/2011
@version 1.0
/*/
//----------------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := FWLoadModel("JURA132A")

J132AChkDel()

oStructSU5 := FWFormStruct(2, "SU5")
oStructNWA := FWFormStruct(2, "NWA")

oStructNWA:RemoveField("NWA_CCONT")

oView := FWFormView():New()
oView:SetModel(oModel)

//oView:AddField("SU5_FIELD", oStructSU5, "SU5MASTER" )
oView:AddGrid ("NWA_GRID1", oStructNWA, "NWADETAIL" )

//oView:CreateHorizontalBox("FORMFIELD", 40)
oView:CreateHorizontalBox("FORMGRID1", 100)

//oView:SetOwnerView("SU5_FIELD" , "FORMFIELD")
oView:SetOwnerView("NWA_GRID1" , "FORMGRID1")

oView:SetDescription( STR0005 ) //"Contato"

Return oView

//----------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Especialidade do Contato

@author Daniel Magalhaes
@since 18/08/2011
@version 1.0
/*/
//----------------------------------------------------------------------------
Static Function ModelDef()
Local oModel     := Nil
Local oStructSU5 := FWFormStruct(1, "SU5")
Local oStructNWA := FWFormStruct(1, "NWA")

//----------------------------------------------
//Monta o modelo do formulario
//----------------------------------------------
oStructSU5:SetProperty( "*", MODEL_FIELD_NOUPD, .T. )
oStructNWA:RemoveField( "NWA_CCONT")

oModel:= MPFormModel():New( "JURA132A", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:SetDescription( STR0002 ) // "Modelo de dados Especialidade do Contato"

oModel:AddFields("SU5MASTER", Nil, oStructSU5, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid(  "NWADETAIL", "SU5MASTER" /*cOwner*/, oStructNWA, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/)

oModel:GetModel( "SU5MASTER" ):SetDescription( STR0003 ) // "Dados do Contato"
oModel:GetModel( "NWADETAIL" ):SetDescription( STR0004 ) // "Dados das Especialidades do Contato"

oModel:GetModel( "NWADETAIL" ):SetUniqueLine( { "NWA_CESPEC" } )
   
oModel:SetRelation("NWADETAIL", {{"NWA_FILIAL", "XFILIAL('NWA')" }, {"NWA_CCONT", "U5_CODCONT"} }, NWA->( IndexKey( 2 ) ) )

oModel:SetOptional("NWADETAIL", .T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132AEsp
Grid Contato x Especialidade

@author Daniel Magalhaes
@since 18/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA132AEsp(cAlias,nReg,nOpc)

Local oView
Local oExecView

Default cAlias := "SU5"
Default nReg   := Recno()
Default nOpc   := 4

//SU5->( DbGoTo(17) )

oView := FwLoadView("JURA132A")
oView:SetOperation( nOpc )

oExecView:= FwViewExec():New()
oExecView:setView(oView)
oExecView:setSize(400, 750)
oExecView:setTitle(STR0001) //"Especialidades do Contato"
//oExecView:setOk()
oExecView:setCloseOnOK({|| .T.})
oExecView:openView(.F.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J132AChkDel
Verifica se existem amarracoes cujos contatos foram excluidos

@author Daniel Magalhaes
@since 25/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J132AChkDel()
Local aRecnos := {}
Local cQryDel := ""
Local cAliDel := GetNextAlias()
Local nFor    := 0

cQryDel := " select" + CRLF
cQryDel += "     NWA.R_E_C_N_O_ NWA_RECNO" + CRLF
cQryDel += " from" + CRLF
cQryDel += "     " + RetSqlName("NWA") + " NWA " + CRLF
cQryDel += " where" + CRLF
cQryDel += "     NWA.NWA_FILIAL = '" + xFilial("NWA") + "'" + CRLF
cQryDel += "     and NWA.D_E_L_E_T_ = ' ' " + CRLF
cQryDel += "     and not exists (select U5_FILIAL" + CRLF
cQryDel += "                     from " + RetSqlName("SU5") + " SU5 " + CRLF
cQryDel += "                     where SU5.U5_FILIAL = '" + xFilial("SU5") + "'" + CRLF
cQryDel += "                     and SU5.U5_CODCONT = NWA.NWA_CCONT" + CRLF
cQryDel += "                     and SU5.D_E_L_E_T_ = ' ')" + CRLF
cQryDel += " order by" + CRLF
cQryDel += "     NWA.R_E_C_N_O_" + CRLF

cQryDel := ChangeQuery(cQryDel)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQryDel ) , cAliDel, .T., .F. )

DbEval( { || AAdd(aRecnos,(cAliDel)->NWA_RECNO) } )

(cAliDel)->(DbCloseArea())

If Len(aRecnos) > 0
	For nFor := 1 To Len(aRecnos)
		NWA->(DbGoTo(aRecnos[nFor]))
		
		NWA->(Reclock("NWA",.F.))
		NWA->(DbDelete())
		NWA->(MsUnlock())
	Next nFor
EndIf

Return