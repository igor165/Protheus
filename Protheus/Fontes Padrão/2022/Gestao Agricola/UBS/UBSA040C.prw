#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'ubsa040.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadHistory(oFolder)
Carrega a aba de Insumos utilizados no beneficiamento
@author  fsw
@since   12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA040C(oFolder)

    oFolder:AddItem(STR0013 , .T.)

    LoadInTop(oFolder:aDialogs[Len(oFolder:aDialogs)])

Return oFolder

/*/{Protheus.doc} LoadInTop
	Faz o load dos campos do layer de cima da aba de insumos
	@type  Static Function
	@author fsw
	@since 12/2020
/*/
Static Function LoadInTop(oParent)
    Local oBrowse as object
    Local aFiltros :={}
    Local cAliasBrw := GetNextAlias()
    Local cQryBrw:= UBSA040INS()


    aColumns := getColIns(cAliasBrw)
    aAdd(aFiltros,{"D3_OP",aColumns[1]:CTITLE,aColumns[1]:CTYPE,aColumns[1]:NSIZE,aColumns[1]:NDECIMAL,aColumns[1]:XPICTURE})
    aAdd(aFiltros,{"D3_DOC",aColumns[2]:CTITLE,aColumns[2]:CTYPE,aColumns[2]:NSIZE,aColumns[2]:NDECIMAL,aColumns[2]:XPICTURE})
    aAdd(aFiltros,{"D3_COD",aColumns[3]:CTITLE,aColumns[3]:CTYPE,aColumns[3]:NSIZE,aColumns[3]:NDECIMAL,aColumns[3]:XPICTURE})
    aAdd(aFiltros,{"D3_LOTECTL",aColumns[6]:CTITLE,aColumns[6]:CTYPE,aColumns[6]:NSIZE,aColumns[6]:NDECIMAL,aColumns[6]:XPICTURE})
    aAdd(aFiltros,{"D3_LOCAL",aColumns[7]:CTITLE,aColumns[7]:CTYPE,aColumns[7]:NSIZE,aColumns[7]:NDECIMAL,aColumns[7]:XPICTURE})

    oBrowse := FWFormBrowse():New()
    oBrowse:SetOwner( oParent )
    oBrowse:SetDescription(STR0013)
    oBrowse:DisableDetails()
    oBrowse:DisableLocate()

    oBrowse:SetDataQuery(.T.)
    oBrowse:SetQuery(cQryBrw)
    oBrowse:SetAlias(cAliasBrw)
    oBrowse:SetColumns(aColumns)
    oBrowse:SetUseFilter(.T.)
    oBrowse:SetFieldFilter(aFiltros)
    oBrowse:Activate(oParent)
Return

/*/{Protheus.doc} UBSA040INS
Retorna dados da aba de insumos
@type function
@version P12
@author fsw
@since 12/2020
@param cRetorno, character, Variavel para definir o local que esta chamando
@return cQuery, String com a query da consulta
/*/
Function UBSA040INS(cRetorno)
    Local cQuery := ''
    Local cTm := GetMv("MV_AGRTMPS")
    Local cCF := 'PR0'
    Local cEstorno := 'S'
    Local cMovsAx := Alltrim(GetMv("MV_AGRSD3S"))
    Local cAliasSD3:= GetNextAlias()
    Local cOP := ''
    Local cDoc := ''
    Local cMovsai := cMovsAx+Space(Len(SF5->F5_CODIGO)-Len(cMovsAx))

    If Select(cAliasSD3) <> 0
        (cAliasSD3)->(dbCloseArea())
    EndIf

    BeginSql Alias cAliasSD3
		SELECT SD3.D3_OP,SD3.D3_DOC
	  		FROM %table:SD3% SD3
  			WHERE SD3.%notDel%
				AND SD3.D3_FILIAL  = %exp:FWxFilial("SD3")%
	  		    AND SD3.D3_TM = %exp:cTm%
				AND SD3.D3_CODSAF = %exp:NP9->NP9_CODSAF%
				AND SD3.D3_LOTECTL = %exp:NP9->NP9_LOTE%
				AND SD3.D3_CF = %exp:cCF%
				AND SD3.D3_ESTORNO <> %exp:cEstorno%
    EndSql

    while (cAliasSD3)->(!EOF())
        if Empty(cOP)
            cOP:= "'"+(cAliasSD3)->D3_OP+"'"
        else
            cOP+= " ,'"+(cAliasSD3)->D3_OP+"'"
        endif

        if Empty(cDoc)
            cDoc:= "'"+(cAliasSD3)->D3_DOC+"'"
        else
            cDoc+= " ,'"+(cAliasSD3)->D3_DOC+"'"
        endif
        (cAliasSD3)->(DBSkip())
    EndDo
    (cAliasSD3)->(dbCloseArea())

    if !Empty(cOP) .AND. !Empty(cDoc)
       
       IF cRetorno = 'UBSA40DQRY'
        cQuery:= " SELECT SD3.D3_LOTECTL "		
       ELSE
        cQuery:= " SELECT SD3.D3_CODSAF,SD3.D3_OP,SD3.D3_DOC,SD3.D3_COD,SB1.B1_DESC,SD3.D3_QUANT,SD3.D3_LOTECTL,SD3.D3_LOCAL, NNR.NNR_DESCRI,D3_CONTA, D3_UM, D3_CUSTO1,"
		cQuery+= " D3_LOCALIZ, D3_NUMSERI, D3_TM, D3_USUARIO "
       ENDIF

        cQuery+= " FROM " + RetSqlName('SD3') + " SD3, "+ RetSqlName('SB1') +" SB1, "+ RetSqlName('NNR') + " NNR "
        cQuery+= " WHERE SD3.D3_FILIAL  = '"+FWxFilial("SD3")+"'"
        cQuery+= " AND SD3.D3_OP in ("+cOP+")"
        cQuery+= " AND SD3.D3_DOC in ("+cDoc+")"
        cQuery+= " AND (SD3.D3_TM = '"+cMovsai+"' OR SD3.D3_TM = '999')"
        cQuery+= " AND SUBSTRING(SD3.D3_CF,1,2) = 'RE'"
        cQuery+= " AND SD3.D3_ESTORNO <> 'S'"
        cQuery+= " AND SD3.D_E_L_E_T_ <> '*'"
        cQuery+= " AND SB1.B1_FILIAL =  '"+FWxFilial("SB1")+"'"
        cQuery+= " AND SB1.B1_COD = SD3.D3_COD"
        cQuery+= " AND SB1.D_E_L_E_T_ <> '*'"
        cQuery+= " AND NNR.NNR_FILIAL = '"+FWxFilial("NNR")+"'"
        cQuery+= " AND NNR.NNR_CODIGO = SD3.D3_LOCAL"
        cQuery+= " AND NNR.D_E_L_E_T_ <> '*'"

    else
        // Caso não tenha OP nem Documento, não lista nada.
        IF cRetorno = 'UBSA40DQRY'
            cQuery := " SELECT SD3.D3_LOTECTL "		
        ELSE
            cQuery := " SELECT SD3.D3_OP,SD3.D3_DOC,SD3.D3_COD,SB1.B1_DESC,SD3.D3_QUANT,SD3.D3_LOTECTL,SD3.D3_LOCAL, NNR.NNR_DESCRI, SD3.D3_CONTA, SD3.D3_UM, SD3.D3_CUSTO1, "
            cQuery += " SD3.D3_LOCALIZ, SD3.D3_NUMSERI, SD3.D3_TM, SD3.D3_USUARIO "
		EndIf 
       
        cQuery += " FROM " + RetSqlName('SD3') + " SD3, "+ RetSqlName('SB1') +" SB1, "+ RetSqlName('NNR') + " NNR "
        cQuery += " WHERE 1 = 2 "
    endif
Return cQuery

/*/{Protheus.doc} getColIns
	Retorna as colunas da tela de inspecao
	@type  Static Function
	@author fsw
	@since 12/2020
	@return aColumns, array com as configs das colunas
/*/
Static Function getColIns(cAliasBrw)
    Local aColumns:={}
    Local aCols:= {"D3_OP","D3_DOC","D3_COD","B1_DESC","D3_QUANT","D3_LOTECTL","NNR_DESCRI","D3_CONTA", "D3_UM", "D3_CUSTO1", "D3_LOCALIZ", "D3_NUMSERI", "D3_TM", "D3_USUARIO"}
    Local nX:=1
	Local cAlias:= ''

	oColumn := FWBrwColumn():New()
	oColumn:SetType(TamSx3("NP9_PROD")[3])
	oColumn:SetData({|| GetProd(cAliasBrw) })
	oColumn:SetTitle(FWX3Titulo("NP9_PROD"))
	oColumn:SetSize(TamSx3("NP9_PROD")[1])
	oColumn:SetPicture(PesqPict('NP9','NP9_PROD'))
	
    aAdd(aColumns, oColumn)

    for nX:= 1 to len(aCols)
        oColumn := FWBrwColumn():New()
        oColumn:SetType(TamSx3(aCols[nX])[3])
		oColumn:SetData(&("{||"+aCols[nX]+"}"))        
        if aCols[nX] = "NNR_DESCRI"
            oColumn:SetTitle(FWX3Titulo("D3_LOCAL"))
		else
            oColumn:SetTitle(FWX3Titulo(aCols[nX]))
        endif
        oColumn:SetSize(TamSx3(aCols[nX])[1])

		if Left(aCols[nX],2)=='D3'
			cAlias:= 'SD3'
		elseif Left(aCols[nX],2)=='B1'
			cAlias:= 'SB1'
		else
			cAlias:= 'NNR'
		endif

		oColumn:SetPicture(PesqPict(cAlias,aCols[nX]))
        aAdd(aColumns, oColumn)
    next

Return aColumns

//-------------------------------------------------------------------
/*/{Protheus.doc} GetProd(cAliasBrw)
Retorna código do produto do lote de sementes relacionado com o insumo
@author  Lucas Briesemeister
@since   12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetProd(cAliasBrw)

    Local cAlias as char
    Local cProd as char
    Local cTm  as char
    
    cTm := GetMv("MV_AGRTMPS")

    cAlias := GetNextAlias()

    BeginSql Alias cAlias
        SELECT 
            SD3.D3_COD
        FROM 
            %table:SD3% SD3 
        WHERE SD3.%notDel%
            AND SD3.D3_FILIAL = %Exp:xFilial('SD3')%
            AND SD3.D3_TM = %Exp:cTm%
            AND SD3.D3_CODSAF = %Exp:(cAliasBrw)->D3_CODSAF%
            AND SD3.D3_OP = %Exp:(cAliasBrw)->D3_OP%
            AND SD3.D3_CF = 'PR0' 
            AND SD3.D3_ESTORNO <> 'S'
    EndSql

    If !(cAlias)->(EoF())
        cProd := (cAlias)->D3_COD
    EndIf

    (cAlias)->(DBCloseArea())

Return cProd
