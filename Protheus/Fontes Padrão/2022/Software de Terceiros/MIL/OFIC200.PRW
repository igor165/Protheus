#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIC200.CH"

/*/{Protheus.doc} OFIC200()
Consulta Detalhada por Campo DEF

@author Andre Luis Almeida
@since 05/03/2021
@version 1.0
@return NIL
/*/
Function OFIC200()
Local cQuery      := ""
Local cQAlias     := "SQLVD7"
Local aVD7        := {}
Local nCntFor     := 0
Local aRotina     := MenuDef()
Private cCadastro := STR0001 // Consulta Detalhada por Campo DEF
//

//
// Validacao de Licencas DMS
//
If !OFValLicenca():ValidaLicencaDMS()
	Return
EndIf

cQuery := "SELECT VD7_CODDEF, VD7_DESDEF "
cQuery += "  FROM "+ RetSQLName("VD7")
cQuery += " WHERE VD7_FILIAL='"+ xFilial("VD7")+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .f., .t.)
Do While !(cQAlias)->(EoF())
	AAdd(aVD7, { (cQAlias)->VD7_CODDEF , (cQAlias)->VD7_DESDEF })
	(cQAlias)->(dbSkip())
EndDo
(cQAlias)->(DbCloseArea())
//
DbSelectArea("VDB")
oBrwVDB := FWMBrowse():New()
oBrwVDB:SetAlias("VDB")
oBrwVDB:SetDescription(STR0001) // Consulta Detalhada por Campo DEF
For nCntFor := 1 to len(aVD7)
	oBrwVDB:AddFilter( Alltrim(aVD7[nCntFor,2])+" ( "+aVD7[nCntFor,1]+" )" , "VDB_CODDEF=='"+aVD7[nCntFor,1]+"'" ,.f.,.f.,) // Filtro por VDB_CODDEF com VD7
Next
oBrwVDB:DisableDetails()
oBrwVDB:ForceQuitButton(.T.)
oBrwVDB:Activate()
//
Return NIL

/*/{Protheus.doc} MenuDef
MenuDef aRotina

@author Andre Luis Almeida
@since 05/03/2021
@version 1.0
@return NIL
/*/
Static Function MenuDef()
Local aRotina := {	{ STR0002,"AxPesqui"           , 0 , 1},;	// Pesquisar
					{ STR0003,"OC2000011_Consultar", 0 , 2}}	// Consultar
Return aRotina

/*/{Protheus.doc} OC2000011_Consultar
Chamada pelo MENU - Consulta Detalhada por Campo DEF

@author Andre Luis Almeida
@since 05/03/2021
@version 1.0
@return NIL
/*/
Function OC2000011_Consultar(cAlias,nReg,nOpc)
//
OC2000021_DetalharDEF( VDB->VDB_FILIAL , VDB->VDB_CODDEF , VDB->VDB_DATA ) // Montagem da Tela com os Browsers
//
Return .t.

/*/{Protheus.doc} OC2000021_DetalharDEF
Browsers da Consulta Detalhada por Campo DEF

@author Andre Luis Almeida
@since 05/03/2021
@version 1.0
@return NIL
/*/
Function OC2000021_DetalharDEF( cFilDEF , cCodDEF , dDatDEF )
Local aSizeAut  := MsAdvSize(.f.)
Default cFilDEF := VDB->VDB_FILIAL
Default cCodDEF := VDB->VDB_CODDEF
Default dDatDEF := VDB->VDB_DATA

oOFIC200 := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],STR0001,,,,128,,,,,.t.) // Consulta Detalhada por Campo DEF

oTPanVCU := TPanel():New(0,0,"",oOFIC200,NIL,.T.,.F.,NIL,NIL,100,(oOFIC200:nClientHeight/4)-10,.F.,.F.)
oTPanVCU:Align := CONTROL_ALIGN_TOP

oTPanVCV := TPanel():New(0,0,"",oOFIC200,NIL,.T.,.F.,NIL,NIL,100,(oOFIC200:nClientHeight/4)-10,.F.,.F.)
oTPanVCV:Align := CONTROL_ALIGN_BOTTOM 

oBrwVCU := FWMBrowse():New()
oBrwVCU:SetAlias("VCU")
oBrwVCU:SetOwner(oTPanVCU)
oBrwVCU:SetDescription(STR0001) // Consulta Detalhada por Campo DEF
oBrwVCU:SetMenuDef('')
If !Empty( cFilDEF + cCodDEF )
	oBrwVCU:AddFilter( STR0004 , " VCU_FILIAL=='"+cFilDEF+"' .and. VCU_CODDEF=='"+cCodDEF+"' .and. DTOS(VCU_DATA)=='"+dtos(dDatDEF)+"'" ,.t.,.t.,) // Filtro Padrão
EndIf
oBrwVCU:DisableDetails()
oBrwVCU:ForceQuitButton(.T.)
oBrwVCU:Activate()
oBrwVCU:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oBrwVCV := FWMBrowse():New()
oBrwVCV:SetAlias("VCV")
oBrwVCV:SetOwner(oTPanVCV)
oBrwVCV:SetDescription(STR0005) // Analitico por Centro de Custo, Conta e Item Contabil
oBrwVCV:SetMenuDef('')
oBrwVCV:DisableDetails()
oBrwVCV:ForceQuitButton(.T.)
oBrwVCV:Activate()
oBrwVCV:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oRelac:= FWBrwRelation():New()
oRelac:AddRelation( oBrwVCU , oBrwVCV , { { "VCV_FILIAL" , "VCU_FILIAL" } , { "VCV_CODDEF" , "VCU_CODDEF" } , { "VCV_CPODEF" , "VCU_CPODEF" } , { "DTOS(VCV_DATA)" , "DTOS(VCU_DATA)" } } )
oRelac:Activate()

oOFIC200:Activate()

Return NIL
