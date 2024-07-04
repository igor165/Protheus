////////////////
// Versao 001 //
////////////////

#include "protheus.ch"

Function VEICLSAM()
Return()

/*/{Protheus.doc} DMS_MetasDeInteresseDAO

	@author       Vinicius Gati
	@since        02/05/2014
	@description  Helper para manipulação de arrays no protheus

/*/
CLASS DMS_MetasDeInteresseDAO

	DATA cCodigo      // VDY_CODIGO
	DATA cCodCampanha // VDY_CAMPOP
	DATA cMesCampanha // VDY_MESMET
	Data cAnoCampanha // VDY_ANOMET
	DATA cCodVendedor // VDY_CODVEN
	DATA cCodMarca    // VDY_CODMAR
	DATA cCodModelo   // VDY_MODVEI
	DATA nQtd         // VDY_QTDINT
	DATA nQtdAtendida
	DATA nQtdValidas
	DATA nQtdCanceladas
	DATA nQtdFaturadas

	METHOD New() CONSTRUCTOR
	METHOD Andamento()
	METHOD Buscar()

ENDCLASS

/*/{Protheus.doc} New

	@author       Vinicius Gati
	@since        31/10/2014
	@description  

/*/
METHOD New(aData) CLASS DMS_MetasDeInteresseDAO
	oData           := DMS_DataContainer():New(aData)
	::cCodigo       := oData:GetValue('cCodigo')
	::cCodCampanha  := oData:GetValue('cCodCampanha')
	::cMesCampanha  := oData:GetValue('cMesCampanha')
	::cAnoCampanha  := oData:GetValue('cAnoCampanha')
	::cCodVendedor  := oData:GetValue('cCodVendedor')
	::cCodMarca     := oData:GetValue('cCodMarca')
	::cCodModelo    := oData:GetValue('cCodModelo')
	::nQtd          := oData:GetValue('nQtd')
Return SELF

/*/{Protheus.doc} Buscar

	@author       Vinicius Gati
	@since        01/11/2014
	@description  Retorna as metas do banco de dados de acordo com o filtro passado
	@example  Atributos válidos
						aData := {
								{'mes'             , '06'       }, 
								{'ano'             , '2014'     }, 
								{'codigo_campanha' , '00000001' }, 
								{'codigo_vendedor' , '00000001' }, 
								{'codigo_marca'    , '00000001' }, 
								{'codigo_modelo'   , '00000001' }
						}
						aUsados := o_MetasI:Todos( aData )

/*/
Method Buscar(aData, lObj) CLASS DMS_MetasDeInteresseDAO
	Local aResults := {}
	Local oData := DMS_DataContainer():New(aData)

	cAlias    := "Metas"
	cTblVDY   := RetSqlName("VDY")
	cSqlMetas := ""
	cSqlMetas += " SELECT VDY_CODIGO, VDY_CAMPOP , VDY_MESMET , VDY_ANOMET , VDY_CODVEN , VDY_CODMAR , VDY_MODVEI , VDY_QTDINT "
	cSqlMetas += "   FROM " + cTblVDY + " VDY "
	cSqlMetas += "  WHERE VDY.VDY_FILIAL = '" + xFilial("VDY") + "' "
	cSqlMetas += "    AND VDY.D_E_L_E_T_ = ' ' "

	If !Empty(oData:GetValue("mes"))
		cSqlMetas += "  AND VDY.VDY_MESMET = '" + oData:GetValue('mes') + "' "
	EndIf

	If !Empty(oData:GetValue("ano"))
		cSqlMetas += "  AND VDY.VDY_ANOMET = '" + oData:GetValue('ano') + "' "
	EndIf

	If !Empty(oData:GetValue("codigo_campanha"))
		cSqlMetas += "  And VDY.VDY_CAMPOP = '" + oData:GetValue('codigo_campanha') + "' "
	EndIf

	If !Empty(oData:GetValue("codigo_vendedor"))
		cSqlMetas += "  AND VDY.VDY_CODVEN = '" + oData:GetValue('codigo_vendedor') + "' "
	EndIf

	If !Empty(oData:GetValue("codigo_marca"))
		cSqlMetas += "  AND VDY.VDY_CODMAR = '" + oData:GetValue('codigo_marca') + "' "
	EndIf

	If !Empty(oData:GetValue("codigo_modelo"))
		cSqlMetas += "  AND VDY.VDY_MODVEI = '" + oData:GetValue('codigo_modelo') + "' "
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSqlMetas),cAlias, .F., .T. )

	(cAlias)->(DbGoTop())
	While !EOF()
		aEl := {                ;
			{'cCodigo'      , (cAlias)->VDY_CODIGO},;
			{'cCodCampanha' , (cAlias)->VDY_CAMPOP},;
			{'cMesCampanha' , (cAlias)->VDY_MESMET},;
			{'cAnoCampanha' , (cAlias)->VDY_ANOMET},;
			{'cCodVendedor' , (cAlias)->VDY_CODVEN},;
			{'cCodMarca'    , (cAlias)->VDY_CODMAR},;
			{'cCodModelo'   , (cAlias)->VDY_MODVEI},;
			{'nQtd'         , (cAlias)->VDY_QTDINT} ;
		}
		If lObj
			AADD(aResults, DMS_MetasDeInteresseDAO():New(aEl))
		Else
			oArrHlp := DMS_ArrayHelper():New()
			aMapped := oArrHlp:Map(aEl, {|el| el[2] })
			AADD(aResults, aMapped)
		EndIf

		DbSkip()
	End
	(cAlias)->(dbCloseArea())

Return aResults

/*/{Protheus.doc} Andamento

	@author       Vinicius Gati
	@since        02/11/2014
	@description  Retorna o andamento atual da meta
	@return  {16, 25} // primeira posição quantidade atendida do montante da meta, e segunda posição porcentagem atendida

/*/
Method Andamento() CLASS DMS_MetasDeInteresseDAO
	Local oSqlHelp       := DMS_SqlHelper():New()
	Local cTblVDM        := RetSqlName("VDM")
	Local cTblVV9        := RetSqlName("VV9")
	Local cFilVDM        := xFilial("VDM")
	Local cSql           := ""
	Local cWhereCanc     := "   AND ( VDM.VDM_MOTCAN <> ' ' OR  VV9.VV9_STATUS =  'C' ) "
	Local cWhereValid    := "   AND ( VDM.VDM_MOTCAN =  ' ' AND COALESCE(VV9.VV9_STATUS, '') <> 'C' ) "
	Local cWhereFat      := "   AND VV9.VV9_STATUS   =  'F' "

	cSql += " SELECT COALESCE( SUM(VDM_QTDINT), 0 ) as SOMA "
	cSql += "      FROM  " + cTblVDM + " VDM "
	cSql += " LEFT JOIN  " + cTblVV9 + " VV9 on VDM.VDM_FILATE = VV9_FILIAL and VDM.VDM_NUMATE = VV9_NUMATE AND VV9.D_E_L_E_T_ = ' ' "
	cSql += "     WHERE VDM.VDM_FILIAL = '" + cFilVDM + "' AND VDM.D_E_L_E_T_ = ' ' "

	If !Empty(self:cMesCampanha)
		cSql += "   AND ("+ oSqlHelp:CompatFunc('SUBSTR') +"(VDM_DATINT, 5, 2) = '" + self:cMesCampanha + "' OR VDM_DATINT = ' ') "
	EndIf

	If !Empty(self:cAnoCampanha)
		cSql += "   AND ("+ oSqlHelp:CompatFunc('SUBSTR') +"(VDM_DATINT, 1, 4) = '" + self:cAnoCampanha + "' OR VDM_DATINT = ' ') "
	EndIf

	If !Empty(self:cCodCampanha)
		cSql += "   AND VDM.VDM_CAMPOP = '" + self:cCodCampanha + "' "
	EndIf

	If !Empty(self:cCodVendedor)
		cSql += "   AND VDM.VDM_CODVEN = '" + self:cCodVendedor + "' "
	EndIf

	If !Empty(self:cCodMarca)
		cSql += "   AND VDM.VDM_CODMAR = '" + self:cCodMarca + "' "
	EndIf

	If !Empty(self:cCodModelo)
		cSql += "   AND VDM.VDM_MODVEI = '" + self:cCodModelo + "' "
	EndIf

	self:nQtdAtendida   := FM_SQL(cSql) // sql contendo quantidade total
	self:nQtdValidas    := FM_SQL(cSql + cWhereValid)
	self:nQtdCanceladas := FM_SQL(cSql + cWhereCanc)
	self:nQtdFaturadas  := FM_SQL(cSql + cWhereFat)
Return {self:nQtdAtendida, self:nQtdValidas, self:nQtdCanceladas, self:nQtdFaturadas}
