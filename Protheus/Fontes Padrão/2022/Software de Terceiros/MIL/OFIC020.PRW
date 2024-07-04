#include 'protheus.ch'
#include "OFIC020.ch"

/*/{Protheus.doc} OFIC020
    Tela para visualizar os Logs de Execuções

    @author Andre Luis Almeida
    @since  05/07/2018
/*/
Function OFIC020(cAgrDefault, cFilter, lExibeAgrup)
Local aTELA       := FWGetDialogSize(oMainWnd)
Local oDlgLogsExec
Local oBrowse
Local oBrowseDet
Local nCntFor     := 0
Local cAgrup      := ""
Local oAgrup      := DMS_DPM():New()
Local aAgrup      := oAgrup:GetRotinasProcesso()
Local cAgrNaoCons := "OFINJD25/DPMXFER/DPMXFER_DPE/SCHEDULER/DPMORD_DPE/BO_DELETED/DPM/" // Agrupadores NAO considerados
Default cAgrDefault := ""
Default cFilter := ""
Default lExibeAgrup := .t.

DbSelectArea("VQL")

If lExibeAgrup

    DEFINE MSDIALOG oDlgLogsExec TITLE STR0001 FROM aTELA[1], aTELA[2] TO aTELA[3], aTELA[4] PIXEL // Logs de Execuções

    // Cria Layers para os Browses
    oFWLayerMAS := FWLayer():New()
    oFWLayerMAS:Init( oDlgLogsExec, .F., .T.)
    oFWLayerMAS:AddLine( 'TOP' , 60, .F.)
    oFWLayerMAS:AddLine( 'DOWN', 40, .F.)
    // Define paineis Top e Down
    oPnlTop := oFWLayerMAS:GetLinePanel ('TOP')
    oPnlDow := oFWLayerMAS:GetLinePanel ('DOWN')
    //
EndIf

oBrowse:= FWMBrowse():New()
oBrowse:SetMenuDef("OFIC020")
oBrowse:SetAlias("VQL")
If lExibeAgrup
    oBrowse:SetOwner(oPnlTop)
EndIf
oBrowse:AddFilter(STR0002,"VQL_CODVQL=' ' .AND. !(Alltrim(VQL_AGROUP)$'"+cAgrNaoCons+"')",.t.,.t.,,,,'OFIC020_'+'01') // Filtro PADRAO - SOMENTE CABECALHO - NAO desmarca (vem selecionado)
oBrowse:AddFilter(STR0003,"dtos(VQL_DATAI)>='"+dtos(dDataBase-30)+"'"                    ,.f.,.t.,,,,'OFIC020_'+'02') // Filtro Adicionais - 30 dias - pode desmarcar (vem selecionado)
oBrowse:AddFilter(STR0004,"dtos(VQL_DATAI)>='"+dtos(dDataBase-07)+"'"                    ,.f.,.f.,,,,'OFIC020_'+'03') // Filtro Adicionais - 07 dias - pode desmarcar
oBrowse:AddFilter(STR0005,"!Empty(VQL_DATAF)"                                            ,.f.,.f.,,,,'OFIC020_'+'04') // Filtro Adicionais - Com Sucesso
oBrowse:AddFilter(STR0006," Empty(VQL_DATAF)"                                            ,.f.,.f.,,,,'OFIC020_'+'05') // Filtro Adicionais - Com Erro
For nCntFor := 1 to len(aAgrup)
    cAgrup := Alltrim(aAgrup[nCntFor]:GetValue('VQL_AGROUP'))
    If !( cAgrup $ cAgrNaoCons )
        oBrowse:AddFilter(STR0007+": "+cAgrup   ,"VQL_AGROUP='"+cAgrup+"'"              ,.f.,(cAgrDefault==cAgrup),,,,'OFIC020_'+'06'+cAgrup) // Filtro Adicionais - Agrupador
    EndIf
Next
If ! Empty(cFilter)
    oBrowse:AddFilter("Default"   , cFilter ,.f.,.t.,,,,'OFIC020_'+'07') // Filtro Default
EndIf
oBrowse:AddLegend( "!Empty(VQL_DATAF)" , "BR_VERDE"    , STR0005 ) // Legenda - Execuções com Sucesso 
oBrowse:AddLegend( " Empty(VQL_DATAF)" , "BR_VERMELHO" , STR0006 ) // Legenda - Execuções com Erro
oBrowse:SetDescription(STR0001) // Logs de Execuções
oBrowse:DisableDetails()

If lExibeAgrup
    oBrowseDet:= FWMBrowse():New()
    oBrowseDet:SetOwner(oPnlDow)
    oBrowseDet:SetDescription(STR0008) // Detalhes
    oBrowseDet:DisableDetails()
    oBrowseDet:SetDataQuery(.T.)
    oBrowseDet:SetAlias("SQLVQL") 
    oBrowseDet:SetQuery(OC0200021_MontaSQLBrowseDetalhes(VQL->VQL_FILIAL,VQL->VQL_CODIGO))
    oBrowseDet:SetUseFilter(.f.)
    oBrowseDet:SetColumns(OC0200011_ColunasBrowseDetalhes())
    oBrowseDet:SetMenuDef(" ")

    oBrowse:bChange := { ||	oBrowseDet:SetQuery(OC0200021_MontaSQLBrowseDetalhes(VQL->VQL_FILIAL,VQL->VQL_CODIGO)), oBrowseDet:Refresh() }

    oBrowseDet:Activate()

    oBrowse:Activate()

    ACTIVATE MSDIALOG oDlgLogsExec

Else
    oBrowse:Activate()

EndIf

Return

/*/{Protheus.doc} OC0200011_ColunasBrowseDetalhes()
    Retorna as Colunas do Browse de Detalhes ( browse em SQL )

    @author Andre Luis Almeida
    @since  05/07/2018
/*/
Static Function OC0200011_ColunasBrowseDetalhes()
Local aColumns := {}
AAdd(aColumns,FWBrwColumn():New())
    aColumns[1]:SetData( &("{|| Transform(stod(VQL_DATAI),'@D') }") ) 
    aColumns[1]:SetTitle(STR0009) // Data
    aColumns[1]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[2]:SetData( &("{|| Transform(VQL_HORAI,'@R 99:99') }") ) 
    aColumns[2]:SetTitle(STR0010) // Hora
    aColumns[2]:SetSize(5) // 5 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[3]:SetData( &("{|| VQL_TIPO }") ) 
    aColumns[3]:SetTitle(STR0012) // Tipo
    aColumns[3]:SetSize(15) // 15 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[4]:SetData( &("{|| VQL_DADOS }") ) 
    aColumns[4]:SetTitle(STR0011) // Observação
    aColumns[4]:SetSize(70) // 70 %
Return aColumns

/*/{Protheus.doc} OC0200021_MontaSQLBrowseDetalhes
    Cria SQL para popular o Browse de Detalhes ( browse em SQL )

    @author Andre Luis Almeida
    @since  05/07/2018
/*/
Static Function OC0200021_MontaSQLBrowseDetalhes( _cFil , _cCod )
Local cQuery := ""
cQuery += "SELECT DISTINCT "
cQuery += "       VQL.VQL_DATAI ,"
cQuery += "       VQL.VQL_HORAI ,"
cQuery += "       VQL.VQL_TIPO  ,"
cQuery += "       VQL.VQL_DADOS  "
cQuery += "  FROM " + RetSqlName("VQL") + " VQL "
cQuery += " WHERE VQL.VQL_FILIAL = '" + _cFil + "'"
cQuery += "	  AND VQL.VQL_CODVQL = '" + IIf(!Empty(_cCod),_cCod,"NAOLEVANTAR") + "'" 
cQuery += "   AND VQL.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VQL.VQL_DATAI , VQL.VQL_HORAI "
Return cQuery


Static Function MenuDef()
Local aAuxRot := {}

aAdd( aAuxRot, { STR0013 , 'VIEWDEF.OFIC020', 0, 2, 0, NIL } )  // 'Visualizar'

Return aAuxRot

Static Function ModelDef()
Local oModel
Local oStruVQL := FWFormStruct(1,"VQL")

 oModel := MPFormModel():New("OFIC020") 
 oModel:addFields('MODEL_VQL',,oStruVQL)
 
Return oModel

Static Function ViewDef()
Local oModel := ModelDef()
Local oView
Local oStruVQL:= FWFormStruct(2, 'VQL')
 
 oView := FWFormView():New()
 oView:SetModel(oModel)
 oView:AddField('VIEW_VQL' , oStruVQL,'MODEL_VQL' ) 
 oView:CreateHorizontalBox( 'TELA', 100)
 oView:SetOwnerView('VIEW_VQL','TELA')
 
Return oView