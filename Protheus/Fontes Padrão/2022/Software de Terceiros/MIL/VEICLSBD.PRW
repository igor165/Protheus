////////////////
// versao 04 //
////////////////

#include "protheus.ch"
#include "VEICLSAD.ch"

Function VEICLSBD()
Return

/*/{Protheus.doc} DMSB_DpePecas
	Classe que terá metodos para tratamento e geração de um arquivo DPE ou dealer parts extract
	que é o arquivo parts data, com as informações diárias do cliente

	@author       Vinicius Gati
	@since        30/03/2017
	@description  Utiliza array de arrays para salvar, recuperar e executar operacoes com dados complexos.
/*/
Class DMSB_DpePecas
	Data aData
	Data oTempTable
	Data cTableName

	METHOD New() CONSTRUCTOR
	METHOD GetPecas()
	METHOD ColetaItensDia()
	METHOD Drop()
	Method TableName()
EndClass

/*/{Protheus.doc} New
	Construtor simples

	@author Vinicius Gati
	@since 30/03/2017
/*/
METHOD New() Class DMSB_DpePecas
	Local cCreate := ""
	Local oSqlHlp := DMS_SqlHelper():New()
	::cTableName := 'DPM_DPE_PARTS'

	cCreate += "CREATE TABLE "+::cTableName+ "( "
	cCreate += "  DATAGER VARCHAR(8), "
	cCreate += "  FILIAL VARCHAR("+STR(FWSizeFilial())+"), "
	cCreate += "  PRODUTO VARCHAR("+STR(tamsx3("B1_COD")[1])+"), "
	cCreate += "  LOCACAO VARCHAR("+STR(tamsx3('BE_LOCALIZ')[1])+")"
	cCreate += ")"

	if ! oSqlHlp:ExistTable( ::cTableName )
		TcSqlExec(cCreate)
		TcSqlExec("CREATE INDEX idx_1 ON "+::cTableName+" (DATAGER, FILIAL , PRODUTO)")
		TcSqlExec("CREATE UNIQUE INDEX idx_2 ON "+::cTableName+" (DATAGER, FILIAL , PRODUTO)")
	endIf
Return SELF

/*/{Protheus.doc} GetPecas
	Retorna um array com todas as peças para geração do DPE na data informada

	@author Vinicius Gati
	@since 30/03/2017
/*/

METHOD GetPecas(dData) CLASS DMSB_DpePecas
	Local oSqlHlp := DMS_SqlHelper():New()
	Local cQuery  := ''
	cQuery += " SELECT * "
	cQuery += "   FROM " + self:cTableName
	cQuery += "  WHERE DATA = '" + DTOS(dData) + "' "

Return oSqlHlp:GetSelectArray(cQuery, 3)

/*/{Protheus.doc} Drop
	Dropa a tabela temporaria criada

	@author Vinicius Gati
	@since 30/03/2017
/*/
METHOD Drop() Class DMSB_DpePecas
Return TcSqlExec("DROP TABLE "+self:cTableName) > 0

/*/{Protheus.doc} ColetaItensDia
	Cria registro dos itens na tabela temporária para uso posterior

	@author Vinicius Gati
	@since 30/03/2017
/*/
METHOD ColetaItensDia() Class DMSB_DpePecas
	Local cSQL        := ""
	Local oSqlHlp     := DMS_SqlHelper():New()
	Local oUtil       := DMS_Util():New()
	Local oDpm        := DMS_DPM():New()
	Local oArrHlp     := DMS_ArrayHelper():New()
	Local cBckFil     := cFilAnt
	Local nIdx        := 1
	Local aFilis      := oDpm:GetFiliais()
	Local lSBZ        := SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"
	Local lBZ_LOCALI2 := ( lSBZ .and. SBZ->(FieldPos("BZ_LOCALI2")) > 0 )
	Private dData36At := Nil
	dData36At         := oUtil:RemoveMeses(dDataBase, 12)
	dData36At         := oUtil:RemoveMeses(dData36At, 12) // 24
	dData36At         := oUtil:RemoveMeses(dData36At, 12) // 36

	// limpeza para que a tabela não fique gigante
	TcSqlExec("DELETE FROM " + self:cTableName + " WHERE DATAGER < '"+DTOS(dDatabase-60)+"' ")

	if FM_SQL("SELECT COUNT(*) from " + self:cTableName + " WHERE DATAGER = '"+DTOS(dDataBase)+"' ") > 0
		return .T.
	endif

	aArms := oDpm:GetFilArms()
	oArrHlp:Merge(aFilis, aArms)

	for nIdx := 1 to LEN(aFilis)
		cFilAnt := aFilis[nIdx, 1]

		// inserindo dados dos itens direct shipment primeiro caso tenha o campo na base
		if SB5->(FieldPos("B5_ISDSHIP")) > 0
			cSQL := ""
			cSQL += " SELECT '"+DTOS(dDataBase)+"' ,'"+xFilial('VS3')+"', B5_COD "
			cSQL += "   FROM " + RetSqlName('SB5')
			cSQL += "  WHERE B5_FILIAL  = '"+xFilial('SB5')+"'"
			cSQL += "    AND B5_ISDSHIP = '1' "
			cSQL += "    AND D_E_L_E_T_ = ' ' "
			cSQL += "    AND NOT EXISTS (SELECT PRODUTO FROM "+self:cTableName+" WHERE FILIAL = '"+xFilial('VS3')+"' AND PRODUTO = B5_COD AND DATAGER = '"+DTOS(dDataBase)+"')"
			nOk := TcSqlExec("INSERT INTO " + self:cTableName + "(DATAGER, FILIAL, PRODUTO)" + cSQL)
		end

		// resto dos itens, dpm normal
		cSQL := ""
		cSQL += " SELECT '"+DTOS(dDataBase)+"' ,'"+xFilial('VS3')+"', B1_COD "
		cSQL += "   FROM " + RetSqlName('SB1')
		cSQL += "  WHERE B1_FILIAL  = '"+xFilial('SB1')+"' "
		cSQL += "    AND D_E_L_E_T_ = ' ' "
		cSQL += "    AND B1_GRUPO IN " + oDpm:GetInGroups()
		cSQL += "    AND ( "
		cSQL += "         EXISTS ( SELECT VB8CH.VB8_PRODUT FROM "+oSqlHlp:NoLock('VB8', 'VB8CH')+" WHERE VB8CH.VB8_FILIAL = '"+xFilial('VB8')+"' AND VB8CH.VB8_PRODUT = B1_COD AND ("+oSqlHlp:Concat({'VB8CH.VB8_ANO', 'VB8CH.VB8_MES', 'VB8CH.VB8_DIA'})+") BETWEEN '" + DTOS(dData36At) + "' AND '" + DTOS(dDatabase) + "' AND VB8CH.D_E_L_E_T_ = ' ') "
		cSQL += "         OR "
		cSQL += "         EXISTS ( SELECT VS3_CODITE FROM "+oSqlHlp:NoLock('VS3')+" JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1_FILIAL = VS3_FILIAL AND VS1_NUMORC = VS3_NUMORC AND VS1.D_E_L_E_T_ = ' ' WHERE VS3_FILIAL = '"+xFilial('VS3')+"' AND VS3_CODITE = B1_CODITE AND VS3_GRUITE = B1_GRUPO AND VS1_DATORC BETWEEN '" + DTOS(dData36At) + "' AND '" + DTOS(dDatabase) + "' AND VS3_QTDITE > 0 AND VS3.D_E_L_E_T_ = ' ' ) "
		cSQL += "         OR "
		cSQL += "         EXISTS ( SELECT B9_COD     FROM "+oSqlHlp:NoLock('SB9')+" WHERE B9_FILIAL = '"+xFilial('SB9')+"' AND B9_COD = B1_CODITE AND B9_QINI > 0 AND SB9.D_E_L_E_T_ = ' ' ) "
		cSQL += "         OR "
		cSQL += "         EXISTS ( SELECT B2_COD     FROM "+oSqlHlp:NoLock('SB2')+" WHERE B2_FILIAL = '"+xFilial('SB2')+"' AND B2_COD = B1_CODITE AND B2_QATU > 0 AND SB2.D_E_L_E_T_ = ' ' ) "
		cSQL += "         OR "
		cSQL += "         EXISTS ( SELECT C7_PRODUTO FROM "+oSqlHlp:NoLock('SC7')+" WHERE C7_FILIAL = '"+xFilial('SC7')+"' AND C7_PRODUTO = B1_COD AND C7_PEDFAB != ' ' AND SC7.D_E_L_E_T_ = ' ' ) "
		cSQL += "     ) "
		cSQL += "   AND NOT EXISTS (SELECT PRODUTO FROM "+self:cTableName +" WHERE FILIAL = '"+xFilial('VS3')+"' AND PRODUTO = B1_COD AND DATAGER = '"+DTOS(dDataBase)+"') "
		nOk := TcSqlExec("INSERT INTO " + self:cTableName + " (DATAGER, FILIAL, PRODUTO) " + cSQL)
		if nOk < 0
			MSGSTOP("Erro de sql detectado: " + TCSQLError())
		end

		if lSBZ .AND. lBZ_LOCALI2
			if tcGetDb() == "ORACLE"
				cSQL := " UPDATE "+self:cTableName+" T1 "
				cSQL += "    SET LOCACAO = ( "
				cSQL += "         SELECT T2.BZ_LOCALI2 "
				cSQL += "           FROM "+RetSqlName('SBZ')+" T2 "
				cSQL += "          WHERE T2.BZ_FILIAL   = '"+xFilial('SBZ')+"' "
				cSQL += "            AND T2.BZ_COD      = T1.PRODUTO "
				cSQL += "            AND T2.BZ_LOCALI2 != ' ' "
				cSQL += "            AND T2.D_E_L_E_T_  = ' ' "
				cSQL += " ) "
				cSQL += " WHERE T1.FILIAL  = '"+xFilial('VS3')+"' "
				cSQL += "   AND T1.LOCACAO is null "
				cSQL += "   AND EXISTS ( "
				cSQL += "       SELECT T3.BZ_LOCALI2 "
				cSQL += "         FROM "+RetSqlName('SBZ')+" T3 "
				cSQL += "          WHERE T3.BZ_FILIAL   = '"+xFilial('SBZ')+"' "
				cSQL += "            AND T3.BZ_COD      = T1.PRODUTO "
				cSQL += "            AND T3.BZ_LOCALI2 != ' ' "
				cSQL += "            AND T3.D_E_L_E_T_  = ' ' "
				cSQL += "   ) "
			else
				cSQL := " UPDATE "+self:cTableName
				cSQL += "    SET LOCACAO = TMP.BZ_LOCALI2 "
				cSQL += "   FROM (SELECT BZ_FILIAL, BZ_COD, BZ_LOCALI2 "
				cSQL += "           FROM "+RetSqlName('SBZ')+" BZ"
				cSQL += "          WHERE BZ.BZ_FILIAL  = '"+xFilial('SBZ')+"' "
				cSQL += "            AND BZ.BZ_LOCALI2 != ' ' "
				cSQL += "            AND BZ.D_E_L_E_T_ = ' ') TMP "
				cSQL += "  WHERE "+self:cTableName+".FILIAL    = '"+xFilial('VS3')+"' "
				cSQL += "    AND TMP.BZ_FILIAL                 = '"+xFilial('SBZ')+"' "
				cSQL += "    AND "+self:cTableName+".PRODUTO   = TMP.BZ_COD "
				cSQL += "    AND "+self:cTableName+".LOCACAO   is null "
			endif
			if tcSqlExec(cSQL) < 0
				MSGSTOP("Erro de sql detectado: " + TCSQLError())
				conout(TCSQLError())
			endif
		end

		if SB5->(FieldPos('B5_LOCALI2')) > 0
			if tcGetDb() == "ORACLE"
				cSQL := " UPDATE "+self:cTableName+" T1 "
				cSQL += "    SET LOCACAO = ( "
				cSQL += "         SELECT T2.B5_LOCALI2 "
				cSQL += "           FROM "+RetSqlName('SB5')+" T2 "
				cSQL += "          WHERE T2.B5_FILIAL   = '"+xFilial('SB5')+"' "
				cSQL += "            AND T2.B5_COD      = T1.PRODUTO "
				cSQL += "            AND T2.B5_LOCALI2 != ' ' "
				cSQL += "            AND T2.D_E_L_E_T_  = ' ' "
				cSQL += " ) "
				cSQL += " WHERE T1.FILIAL  = '"+xFilial('VS3')+"' "
				cSQL += "   AND T1.LOCACAO is null "
				cSQL += "   AND EXISTS ( "
				cSQL += "       SELECT T3.B5_LOCALI2 "
				cSQL += "         FROM "+RetSqlName('SB5')+" T3 "
				cSQL += "          WHERE T3.B5_FILIAL   = '"+xFilial('SB5')+"' "
				cSQL += "            AND T3.B5_COD      = T1.PRODUTO "
				cSQL += "            AND T3.B5_LOCALI2 != ' ' "
				cSQL += "            AND T3.D_E_L_E_T_  = ' ' "
				cSQL += "   ) "
			else
				cSQL := " UPDATE "+self:cTableName
				cSQL += "    SET LOCACAO = TMP.B5_LOCALI2 "
				cSQL += "   FROM (SELECT B5_FILIAL, B5_COD, B5_LOCALI2 "
				cSQL += "           FROM "+RetSqlName('SB5')
				cSQL += "          WHERE B5_FILIAL  = '"+xFilial('SB5')+"' "
				cSQL += "            AND B5_LOCALI2 != ' ' "
				cSQL += "            AND D_E_L_E_T_ = ' ') TMP "
				cSQL += "  WHERE "+self:cTableName+".FILIAL    = '"+xFilial('VS3')+"' "
				cSQL += "    AND TMP.B5_FILIAL                 = '"+xFilial('SB5')+"' "
				cSQL += "    AND "+self:cTableName+".PRODUTO   = TMP.B5_COD "
				cSQL += "    AND "+self:cTableName+".LOCACAO   is null "
			endif
			if tcSqlExec(cSQL) < 0
				MSGSTOP("Erro de sql detectado: " + TCSQLError())
				conout(TCSQLError())
			endif
			// evita os nulos
			tcSqlExec("UPDATE "+self:cTableName+ " SET LOCACAO = ' ' WHERE LOCACAO is null")
		endif
	next

	cFilAnt := cBckFil
Return .T.

/*/{Protheus.doc} TableName
	Retorna nome da tabela temporaria criada

	@author Vinicius Gati
	@since 30/03/2017
/*/
METHOD TableName() CLASS DMSB_DpePecas
Return self:cTableName

/*/{Protheus.doc} DMSB_DirectShipment

	@author       Vinicius Gati
	@since        07/04/2017
	@description  Classe responsavel por atualizar e coletar itens de direct shipment
/*/
Class DMSB_DirectShipment
	Data aData
	Data oTempTable
	Data cTableName

	METHOD New() CONSTRUCTOR
	METHOD GetPecas()
	METHOD AtualizarPecas()
EndClass

/*/{Protheus.doc} New
	Construtor simples

	@author Vinicius Gati
	@since  30/03/2017
/*/
METHOD New() Class DMSB_DirectShipment
Return SELF

/*/{Protheus.doc} GetPecas

	@author Vinicius Gati
	@since  30/03/2017
	@description Busca a lista de peças direct shipment na web
/*/
METHOD GetPecas() Class DMSB_DirectShipment
	Local aCodigos   := {}
	Local sPostRet   := ""
	Local cHeaderGet := ""
	Local nIdx       := 1
	Local oObj       := Nil

	sPostRet := HttpGet("http://www.itmil.com.br/john_deere/direct_shipment.php", , , , @cHeaderGet)
	if ! empty(sPostRet)
		If FWJsonDeserialize(sPostRet,@oObj)
			for nIdx := 1 to LEN(oObj:pecas)
				AADD(aCodigos, oObj:pecas[nIdx])
			next
		end
	else
		ConOut("Não foi possivel acessar o servidor, sem acesso a internet?")
	end
Return aCodigos

/*/{Protheus.doc} AtualizarPecas

	@author Vinicius Gati
	@since  30/03/2017
	@description Pega as peças e altera o B5 das peças para direct shipment = 1
/*/
METHOD AtualizarPecas() Class DMSB_DirectShipment
	Local aPecas  := self:GetPecas()
	Local aArHlp  := DMS_ArrayHelper():New()
	Local cUpd    := ""
	Local nRes    := 1

	cIn  := "'" + aArHlp:Join(aPecas, "','") + "'"

	cUpd := ""
	cUpd += "UPDATE " + RetSqlName('SB5')
	cUpd += "   SET B5_ISDSHIP = '1' "
	cUpd += " WHERE B5_COD IN ("+cIn+") "
	cUpd += "   AND D_E_L_E_T_ = ' '"
	nRes := TcSqlExec(cUpd)
	if nRes < 0
		conout("Erro importação de itens direct shipment: " + TCSQLError())
		return .F.
	end
Return .T.
 