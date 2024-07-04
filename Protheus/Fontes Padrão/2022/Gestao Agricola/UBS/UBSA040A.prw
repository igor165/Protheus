#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'ubsa040.ch'
/*/
	{Protheus.doc} UBSA040A(oFolder)
	Carrega a aba de qualidade
	@author  FSW
	@since   12/2020
	@version 12.1.27
/*/
Function UBSA040A(oFolder)

    Local oBrowse as object
	local aFiltros :={}
	Local cAliasBrw := GetNextAlias()
	Local cQryBrw as char

	cQryBrw := " SELECT NPX_CODPRO, NPX_RESNUM,NPX_DESVA, NPX_DTATU, NPX_USUATU, NPX_OFI"
	/*cQryBrw += "Case NPX_OFI "
	cQryBrw += " when '1' then 'SIM' "
	cQryBrw += " when '0' then 'NÃO' "
	cQryBrw += " end as NPX_OFI "*/
	cQryBrw += " FROM " + RetSqlName('NPX') + " "
	cQryBrw += " WHERE NPX_FILIAL = '"+NP9->NP9_FILIAL+"'"
	cQryBrw += "  AND NPX_CODSAF = '"+NP9->NP9_CODSAF+"'"
	// cQryBrw += "  AND NPX_CODPRO = '"+NP9->NP9_PROD+"'"
	cQryBrw += "  AND NPX_LOTE   = '"+NP9->NP9_LOTE+"'"
	cQryBrw += "  AND D_E_L_E_T_ = ' ' "
	cQryBrw := ChangeQuery(cQryBrw)

    oFolder:AddItem(STR0008, .T.)
    
    aColumns := getColumns(cAliasBrw)
 	aAdd(aFiltros,{"NPX_USUATU",aColumns[4]:CTITLE,aColumns[4]:CTYPE,aColumns[4]:NSIZE,aColumns[4]:NDECIMAL,aColumns[4]:XPICTURE})

	oBrowse := FWFormBrowse():New()
    //oBrowse:SetDescription(STR0001)
    oBrowse:SetDescription(STR0033)
    oBrowse:DisableDetails()
    oBrowse:DisableLocate()
    //oBrowse:DisableReport()
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetQuery(cQryBrw)
	oBrowse:SetAlias(cAliasBrw)
    oBrowse:SetColumns(aColumns)
	
	oBrowse:SetUseFilter(.T.)
	//oBrowse:SetFieldFilter(aFiltros)
	oBrowse:SetFieldFilter(UBSA040DFL(aColumns))
    oBrowse:Activate(oFolder:aDialogs[Len(oFolder:aDialogs)])
Return oFolder

/*/
	{Protheus.doc} getColumns()
	Retorna as colunas do browse
	@type  Static Function
	@author fsw
	@since 12/2020
	@return aColumns
/*/
Static Function getColumns(cAliasBrw)
	Local aColumns:={}

	//Adiciona coluna externa de "Descrição de Exam
	oColumn := FWBrwColumn():New()
	oColumn:SetType("C")
	oColumn:SetData({|| (cAliasBrw)->NPX_CODPRO })
	oColumn:SetTitle(FWX3Titulo("NPX_CODPRO"))//Exame
	oColumn:SetSize(TamSx3("NPX_CODPRO")[1])
	aAdd(aColumns, oColumn)

	oColumn := FWBrwColumn():New()
	oColumn:SetType("C")
	oColumn:SetData({|| getExame() })
	oColumn:SetTitle(STR0009)//Exame
	oColumn:SetSize(TamSx3("NPT_DESCRI")[1])
	aAdd(aColumns, oColumn)

	//Adiciona a coluna NPX_DESVA
	oColumn := FWBrwColumn():New()
	oColumn:SetType(TamSx3("NPX_DESVA")[3])
	oColumn:SetData({|| (cAliasBrw)->NPX_DESVA })
	oColumn:SetTitle(FWX3Titulo("NPX_DESVA"))
	oColumn:SetSize(TamSx3("NPX_DESVA")[1])
	aAdd(aColumns, oColumn)

	//Adiciona a coluna NPX_RESNUM
	oColumn := FWBrwColumn():New()
	oColumn:SetType(TamSx3("NPX_RESNUM")[3])
	oColumn:SetData({|| (cAliasBrw)->NPX_RESNUM })
	oColumn:SetTitle(FWX3Titulo("NPX_RESNUM"))
	oColumn:SetSize(TamSx3("NPX_RESNUM")[1])
    oColumn:SetPicture(PesqPict('NPX','NPX_RESNUM'))
	aAdd(aColumns, oColumn)

	//Adiciona a coluna NPX_DTATU
	oColumn := FWBrwColumn():New()
	oColumn:SetType(TamSx3("NPX_DTATU")[3])
	oColumn:SetData({|| SubStr((cAliasBrw)->NPX_DTATU,7)+"/"+SubStr((cAliasBrw)->NPX_DTATU,5,2)+"/"+SubStr((cAliasBrw)->NPX_DTATU,1,4) })
	oColumn:SetTitle(FWX3Titulo("NPX_DTATU"))
	oColumn:SetSize(TamSx3("NPX_DTATU")[1])
	aAdd(aColumns, oColumn)

	//Adiciona a coluna NPX_USUATU
	oColumn := FWBrwColumn():New()
	oColumn:SetType(TamSx3("NPX_USUATU")[3])
	oColumn:SetData({|| (cAliasBrw)->NPX_USUATU })
	oColumn:SetTitle(FWX3Titulo("NPX_USUATU"))
	oColumn:SetSize(TamSx3("NPX_USUATU")[1])
	aAdd(aColumns, oColumn)

	//Adiciona coluna "Oficial" com tratamento no valor a ser apresentado
	oColumn := FWBrwColumn():New()
	oColumn:SetType("C")
	oColumn:SetData({|| getOficial() })
	oColumn:SetTitle(STR0010)//Oficial
	oColumn:SetSize(3)
	aAdd(aColumns, oColumn)
Return aColumns

/*/
	{Protheus.doc} getExame
	Retorna a descrição do exame ( NPT )
	@type  Static Function
	@author fsw
	@since 12/2020
	@return cDesc
/*/
Static Function getExame()
	Local cDesc:= ''
	Local cAliasNPT:= GetNextAlias()

	If Select(cAliasNPT) <> 0
		(cAliasNPT)->(dbCloseArea())
	EndIf

	BeginSql Alias cAliasNPT
		SELECT NPT_DESCRI
	  		FROM %table:NPT% NPT
  			WHERE NPT.%notDel%
				AND NPT.NPT_FILIAL  = %exp:FWxFilial("NPT")%
	  		    AND NPT.NPT_CODTA = %exp:NPX->NPX_CODTA%
	EndSql

	If (cAliasNPT)->(!EOF())
		cDesc:= (cAliasNPT)->NPT_DESCRI
	Endif
	(cAliasNPT)->(dbCloseArea())

Return cDesc

/*/
	{Protheus.doc} getOficial
	(long_description)
	@type  Static Function
	@author user
	@since date
/*/
Static Function getOficial()
	Local cDesc:= ''
	if NPX->NPX_OFI = '1'
		cDesc:= STR0012 //Não
	Else
		cDesc:= STR0011 //Sim
	endif

Return cDesc