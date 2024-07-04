////////////////
// Versao 014 //
////////////////

#include "protheus.ch"
#include "ofixdef.ch"

STATIC cSGBD := TcGetDb()

Function VEICLSAS()
Return()

/*/{Protheus.doc} DMS_SqlHelper
	Class que foi criada para ajudar na compatibilização de comandos sql que devem ser multi SGBD'S

	@author Vinicius Gati
	@since  13/06/2014
/*/
Class DMS_SqlHelper
	Method New() Constructor
	Method CompatFunc()
	Method TOPFunc()
	Method RowCountFunc()
	Method NoLock()
	Method ConvToDate()
	Method DateDiff()
	Method GetSelect()
	Method ExistTable()
	Method Concat()
	Method GetSelectArray()
	Method GetSelectMVC()
	Method Any()
	Method StrWithinAStr()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_SqlHelper

	@author Vinicius Gati
	@since  13/06/2014
/*/
Method New() Class DMS_SqlHelper
Return Self

/*/{Protheus.doc} Any
Verifica se existe algum registro que atende ao where na tabela

@author Vinicius Gati
@since  04/07/2017
/*/
Method Any(cTbl, cWhere) Class DMS_SqlHelper
Return FM_SQL("SELECT COUNT("+cTbl+"_FILIAL) FROM "+RetSqlName(cTbl)+" WHERE "+cTbl+"_FILIAL = '"+xfilial(cTbl)+"' AND D_E_L_E_T_ = ' ' AND " + cWhere) > 0

/*/{Protheus.doc} Concat
	Concat multi database, para concatenar textos

	@author Vinicius Gati
	@since  23/12/2015
	@param aItens, array, Array contendo dados que serão concatenados
	@return string, 'texto' + VE6_NUMPED + 'TEXTO'
/*/
Method Concat(aItens) Class DMS_SqlHelper
	Local oArrHlp := DMS_ArrayHelper():New()

	Do Case
	Case "ORACLE" $ cSGBD .or. "POSTGRES" $ cSGBD
		return oArrHlp:Join(aItens, " || ")
	OtherWise
		return oArrHlp:Join(aItens, " + ")
	EndCase

return "" // pra dar erro pois usou errado

/*/{Protheus.doc} CompatFunc
	Converte algumas funcoes SQL para o banco de dados utilizado

	@author Vinicius Gati
	@since  13/06/2014

/*/
Method CompatFunc(cFuncName) Class DMS_SqlHelper
	Local cRet := ''
	Do Case
		Case cFuncName == 'SUBSTR'
			If 'MSSQL' $ cSGBD
				cRet := 'SUBSTRING'
			Else
				cRet := cFuncName
			EndIf
		Case cFuncName == 'LEN'
			If 'MSSQL' $ cSGBD
				cRet := 'LEN'
			Else
				cRet := 'LENGTH'
			EndIf
		Case cFuncName == 'TRIM'
			If 'MSSQL' $ cSGBD
				cRet := 'RTRIM'
			Else
				cRet := 'RTRIM'
			EndIf
	EndCase
Return cRet

/*/{Protheus.doc} TOPFunc
	Converte string SQL adicionando clausula TOP de acordo com o banco de dados utilizado

	@author Rubens Takahashi
	@since  11/05/2015

	@param cQuery, character, String SQL a ser convertida
	@param nRows, numérico, Quantidade de registros retornado
	@example oSqlHelper:TOPFunc("select * from VAI", 1)
/*/
Method TOPFunc(cQuery,nRows) Class DMS_SqlHelper
	Do Case
	Case "ORACLE" $ cSGBD
		cQuery := "SELECT * FROM ( " + cQuery + " ) WHERE ROWNUM <= " + AllTrim(Str(nRows))
	Case "MSSQL" $ cSGBD
		cQuery := StrTran(cQuery,"SELECT ", "SELECT TOP " + AllTrim(Str(nRows)) + " ", , 1)
	Case "MYSQL" $ cSGBD .or. "POSTGRES" $ cSGBD
		cQuery += " LIMIT " + AllTrim(Str(nRows))
	Case "INFORMIX" $ cSGBD
		cQuery := StrTran(cQuery,"SELECT ", "SELECT FIRST " + AllTrim(Str(nRows)) + " ", , 1)
	OtherWise
		cQuery := StrTran(cQuery,"SELECT ", "SELECT TOP " + AllTrim(Str(nRows)) + " ", , 1)
	EndCase
Return cQuery

/*/{Protheus.doc} RowCountFunc
	Converte string SQL adicionando o rowcount que pode ser adicionado a select para dar uma numeracao sequenciar a cada row

	@author Vinicius gati
	@since  26/05/2015

	@param cQuerySel, character, String SQL a ser convertida
	@param cOver, character, No sqlserver o over é obrigatorio
	@example oSqlHelper:TOPFunc("select * from VAI", 1)
/*/
Method RowCountFunc(cQuerySel, cOver, cQueryCount) class DMS_SqlHelper
	Local   cQuery       := ""
	Default cOver        := ""
	Default cQueryCount  := ""
	// Oracle, postgresql e Sql server sao iguais
	cQuery := " SELECT "+cQueryCount+" Row_Number() OVER " + cOver + " as xrownum, aaaaz.*  FROM ( " + cQuerySel + " ) aaaaz "
	Do Case
	Case "MYSQL" $ cSGBD
		cQuery := " SELECT @rn:=@rn+1 AS xrownum, aaaaz.* FROM ( " + cQuerySel + " ) as aaaaz, (SELECT @rn:= "+cQueryCount+" ) AS t "
	EndCase
Return cQuery

/*/{Protheus.doc} NoLock
	Retorna RetSqlName com noLock syntax dependendo o banco de dados utilizado, lembrando que Oracle e postgresql
	nao da block em selects e nao é necessario usar
	este metodo, que em caso de outros bancos
	diferentes de sqlserver e mysql ira retornar normalmente sem nolock

	@author Vinicius gati
	@since  5/06/2015

	@param cTableName, character, Nome da tabela, mesmo parametro do RetSqlName
	@param cAlias, character, Alias que sera incluido ex: "VAI"
	@example oSqlHelper:NoLock("VAI") => "VAI020 VAI with(nolock)" -> No caso de sqlserver
/*/
Method NoLock(cTableName, cQueryAlias) class DMS_SqlHelper
	Local cTabela      := " " + RetSqlName(cTableName)
	Default cQueryAlias     := cTableName
	Do Case
	Case "MYSQL" $ cSGBD
		return cTabela + " " + cQueryAlias + " " // Não faz para outros bancos diferentes
	Case "ORACLE" $ cSGBD
		return cTabela + " " + cQueryAlias + " " // Não faz para outros bancos diferentes
	Case "POSTGRES" $ cSGBD
		return cTabela + " " + cQueryAlias + " " // Não faz para outros bancos diferentes
	OtherWise
		return cTabela + " " + cQueryAlias + " with(nolock) "
	EndCase
Return RetSqlName(cTableName)

/*/{Protheus.doc} ConvToDate
	retorna um campo data valido para o banco alvo

	@author Vinicius gati
	@since  5/06/2015

	@param cTableName, character, Nome da tabela, mesmo parametro do RetSqlName
	@param cAlias, character, Alias que sera incluido ex: "VAI"
	@example oSqlHelper:ConvToDate("VO4_DATFIN") => "CONVERT(DATETIME,VO4_DATFIN)" -> No caso de sqlserver
/*/
Method ConvToDate(cConteudo, cFieldAlias, cFormat) class DMS_SqlHelper
	Default cFieldAlias := ""
	Default cFormat     := "%Y%m%d" // formato necessário no mysql/oracle

	Do Case
	Case "MYSQL" $ cSGBD
		return " STR_TO_DATE(" + cConteudo + ", '"+cFormat+"') " + cFieldAlias + " "
	Case "MSSQL" $ cSGBD
		return " CONVERT(DATETIME, " + cConteudo + ") " + cFieldAlias + " "
	Case "ORACLE" $ cSGBD
		return " TO_DATE(" + cConteudo + IIF( !Empty(cFormat) , ", '" + cFormat + "'" , "" ) + " ) " + cFieldAlias + " "
	OtherWise
		return cTabela + " " + cQueryAlias + " " // Não faz para outros bancos diferentes
	EndCase
Return ""

/*/{Protheus.doc} DateDiff
	Retorna string para operação com campos do tipo Data

	@author Rubens Takahashi
	@since  25/11/2015

	@param cCampo1, character, Nome do campo do tipo DATE Inicio para operação
	@param cCampo2, character, Nome do campo do tipo DATE Fim para operação
	@example oSqlHelper:DateDiff("DATFIN","DATINI") => "DATEDIFF( DAY , DATFIN , DATINI ) -> No caso de sqlserver
/*/
Method DateDiff(cCampo1, cCampo2) class DMS_SqlHelper
	Do Case
	Case "MSSQL" $ cSGBD
		return " DATEDIFF ( d , " + cCampo1 + " , " + cCampo2 + " )"
	OtherWise
		return cCampo2 + " - " + cCampo1
	EndCase
Return ""

/*/{Protheus.doc} GetSelect
	Retornar array de data containers com os dados do select, passe os campos como select em um data container

	@author Vinicius gati
	@since  18/06/2015
	@param aData, deve estar no formato {
											{'campos', {"SD1.D1_DTDIGIT", "D1_COD"}},
											{'query' , 'select * from SD1010'}
										}
	@return O retorno depende do que você pediu no select
/*/
Method GetSelect(aData) Class DMS_SqlHelper
	Local oData     := DMS_DataContainer():New(aData)
	Local aCampos   := oData:GetValue('campos')
	Local cQuery    := oData:GetValue('query')
	//Local aBckAlias := {}
	Local cAl       := GetNextAlias()
	Local nIdx      := 1
	Local aResults  := {}
	Local aArea     := GetArea()

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )
	//(cAl)->(DbGoTop()) // Posiciona o cursor no início da área de trabalho ativa
	//dbSelectArea(cAl) // Problemas com o dbCloseArea() no final e por isso, trocado por GetArea() e RestArea()
	While !(cAl)->(EOF())          // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
		aEl := {}
		aEval(aCampos,{ |x| (cCampo := SubStr(x,At(".",x)+1) , AADD(aEl,{ cCampo , (cAl)->&(cCampo) } )) })
		oEl := DMS_DataContainer():New(aEl)
		AADD(aResults, oEl)
		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())

	RestArea( aArea )
Return aResults

/*/{Protheus.doc} ExistTable
	Retornar array de data containers com os dados do select, passe os campos como select em um data container

	@author Vinicius gati
	@since  18/06/2015
	@param  cTableName, nome da tabela para verificar
	@return .t.|.f. Boolean
/*/
Method ExistTable(cTableName) Class DMS_SqlHelper
	Local lRet := .F.

	lRet := MsFile(cTableName)

Return lRet

/*/{Protheus.doc} GetSelectArray

Metodo que retornara uma matriz contendo o resultado do select passado por parametro.
Será utilizando somente a primeira coluna do select caso o parametro nQtdCampos não
seja preenchido

@author Rubens
@since 07/12/2016
@version 1.0
@param cQuery, characters, Query a ser executada
@param nQtdCampos, numérico, Quantidade de campos do select
@type function
/*/
Method GetSelectArray(cQuery, nQtdCampos) Class DMS_SqlHelper
	Local cAl       := "TGETSELECT"
	Local aResults  := {}
	Local nIdx       := 1
	Local aEl
	Default nQtdCampos := 1

    
	if nQtdCampos == 1
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )
		(cAl)->(dbEval( { || AADD( aResults , (cAl)->(FieldGet(1)) ) } ))
		(cAl)->(dbCloseArea())
	else
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )
		dbSelectArea(cAl)
		aEl := Array(nQtdCampos)
		While !(cAl)->(EOF())
			for nIdx := 1 to nQtdCampos
				aEl[nIdx] := (cAl)->( FieldGet(nIdx) )
			next
			AADD(aResults, aClone(aEl))
			(cAl)->(DbSkip())
		End
		(cAl)->(dbCloseArea())
	end
	
Return aResults

/*/{Protheus.doc} GetSelectArray

Metodo que retornara uma matriz contendo o resultado do select passado por parametro.
Retorna a matriz no formato utilizado no LOAD da Grid do MVC

@author Rubens
@since 17/11/2018
@version 1.0
@param cQuery, characters, Query a ser executada
@param nQtdCampos, numérico, Quantidade de campos do select
@type function
/*/
Method GetSelectMVC(cQuery, nQtdCampos) Class DMS_SqlHelper
	Local cAl       := "TGETSELECT"
	Local aResults  := {}
	Local nIdx       := 1
	Local aEl
	Local nRegRecno := 0
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )
	dbSelectArea(cAl)
	aEl := Array(nQtdCampos)
	While !(cAl)->(EOF())
		for nIdx := 1 to nQtdCampos
			aEl[nIdx] := (cAl)->( FieldGet(nIdx) )
		next
		AADD(aResults, { nRegRecno++ , aClone(aEl) } )
		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())
	
Return aResults

/*/{Protheus.doc} StrWithinAStr

Metodo que retornara string com a funcao a ser utilizada para procurar uma String dentro de uma String

@author Rubens
@since 02/07/2019
@version 1.0
@param cString, characters, String
@param cSubString, characters, String a ser pesquisada
@type function
/*/
Method StrWithinAStr(cString, cSubString) Class DMS_SqlHelper
	Do Case
	Case "MSSQL" $ cSGBD
		return " CHARINDEX(" + cSubString + ", " + cString + ") "
	Case "ORACLE" $ cSGBD
		return " INSTR(" + cString + ", " + cSubString + ") "
	Case "MYSQL" $ cSGBD
		return " INSTR(" + cString + ", " + cSubString + ") "
	Case "POSTGRES" $ cSGBD
		return " STRPOS(" + cString + ", " + cSubString + ") "
	EndCase

Return ""

/*/{Protheus.doc} DMS_Servico
	Classe para auxiliar a manipulação do serviço (Oficina)
	@author       Rubens Takahashi
	@since        30/06/2015
	@version      1.0
	@description  Classe para auxiliar a manipulação do serviço (Oficina)

/*/
Class DMS_Servico

	Data cChaInt // Não acessar propriedades diretamente
	Data cCodMar // Não acessar propriedades diretamente
	Data cModVei // Não acessar propriedades diretamente
	Data cSegMod // Não acessar propriedades diretamente

	Method New() Constructor
	Method GetTemPad()
	Method GetSrvcMarca()
	Method SetChassiInterno()
	Method TipServBloqueado()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_Servico
	@author       Rubens Takahashi
	@since        30/06/2015
	@version      1.0
/*/
Method New( cChaInt ) Class DMS_Servico
	If cChaInt <> NIL
		Self:SetChassiInterno( cChaInt )
	Else
		Self:cChaInt := ""
	EndIf
Return Self

/*/{Protheus.doc} SetChassiInterno

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param cChaInt, character, Codigo do Chassi Interno
/*/
Method SetChassiInterno( cChaInt ) Class DMS_Servico
	Local aVV1 := VV1->(GetArea("VV1"))
	VV1->(dbSetOrder(1))
	If VV1->(MsSeek( xFilial("VV1") + cChaInt ))
		Self:cChaInt := VV1->VV1_CHAINT
		Self:cCodMar := VV1->VV1_CODMAR
		Self:cModVei := VV1->VV1_MODVEI
		Self:cSegMod := VV1->VV1_SEGMOD
	Else
		Self:cCodMar := ""
		Self:cModVei := ""
		Self:cSegMod := ""
		Self:cChaInt := ""
	EndIf

	RestArea(aVV1)
Return

/*/{Protheus.doc} GetSrvcMarca
	Verifica se o posicionamento na tabela de servico deve ser com ou sem marca.

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param cCodSer, character, Codigo do Servico
/*/
Method GetSrvcMarca(cCodSer) Class DMS_Servico
Return FG_MARSRV(Self:cCodMar,cCodSer)

/*/{Protheus.doc} GetTemPad
	Retorna o tempo padrao de um servico

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param cCodSer, character, Codigo do servico
	@param cIncMob, character, Configuracao do tipo de cobranca (VOK_INCMOB)
	@param cIncTem, character, Configuracao do tempo para calculo (VOK_INCTEM)
/*/
Method GetTemPad(cCodSer, cIncMob, cIncTem) Class DMS_Servico

Local cMarcaVO6
Local nTemPad := 99999

If cIncMob == TSER_TERCEIRO .or. cIncMob == TSER_KM
	Return 0
EndIf

If Empty(Self:cChaInt)
	MsgStop("Erro ao utilizar Função")
EndIf

cMarcaVO6 := Self:GetSrvcMarca(cCodSer)
cCpoTempo := IIf( cIncTem == TSER_TPO_CONCESS , "_TEMCON" , "_TEMFAB" )

cSQL := "SELECT CASE WHEN VO7" + cCpoTempo + " IS NULL THEN VO6" + cCpoTempo + " ELSE VO7" + cCpoTempo + " END TEMPO"
cSQL +=  " FROM " + RetSQLName("VO6") + " VO6 "
cSQL +=  " LEFT JOIN " + RetSQLName("VO7") + " VO7 "
cSQL +=         " ON VO7.VO7_FILIAL = '" + xFilial("VO7") + "'"
cSQL +=        " AND VO7.VO7_CODMAR = VO6.VO6_CODMAR "
cSQL +=        " AND VO7.VO7_CODSER = VO6.VO6_CODSER "
cSQL +=        " AND VO7.VO7_MODVEI = '" + Self:cModVei + "'"
cSQL +=        " AND VO7.VO7_SEGMOD = '" + Self:cSegMod + "'"
cSQL +=        " AND VO7.D_E_L_E_T_ = ' '"
cSQL += " WHERE VO6.VO6_FILIAL = '" + xFilial("VO6") + "'"
cSQL +=   " AND VO6.VO6_CODMAR = '" + cMarcaVO6 + "'"
cSQL +=   " AND VO6.VO6_CODSER = '" + cCodSer   + "'"
cSQL +=   " AND VO6.D_E_L_E_T_ = ' '"
nTemPad := FM_SQL(cSQL)

Return nTemPad


/*/{Protheus.doc} DMS_Servico
	Classe para manipulação de string, mais precisamente foi criado só pra resolver<br>
	o problema do strtokarr2 que da errorlog pra todo lado

	@author       Vinicius Gati
	@since        13/06/2017
/*/
Class DMS_StringHelper
  Method New() Constructor
  Method StrToKarr2()
EndClass

Method New() class DMS_StringHelper
Return Self

/*/{Protheus.doc} StrToKarr2
	Quebra a string em cada lugar onde o cSeparador estiver e retorna um array <br>
	com os dados

	@author       Vinicius Gati
	@since        13/06/2017
/*/
Method StrToKarr2(cString, cSeparador) class DMS_StringHelper
	Local nIdx := 1, nPosFrs := 0
	Local aDados := {}
	Local cEl
	for nIdx := 1 to LEN( cString )
		nPosFrs := AT(cSeparador, cString)
		if nPosFrs == 0
			AADD(aDados, cString)
			Exit
		ElseIf nPosFrs > 1
			if SUBSTR(cString, 1, nPosFrs-1) == cSeparador
				AADD(aDados, "")
				cString := RIGHT(cString, (LEN(cString)-1) - Len(cEl) )
			else
				cEl     := SUBSTR(cString, 1, nPosFrs-1)
				cString := RIGHT(cString, (LEN(cString)-1) - Len(cEl) )
				AADD(aDados, cEl)
			endif
		ElseIf nPosFrs == 1 .AND. LEN(cString) > 1 
			AADD(aDados, "")
			cString := RIGHT(cString, (LEN(cString)-1))
		Elseif nPosFrs == 1
			Exit
		EndIf
	next
Return aDados

/*/{Protheus.doc} TipServBloqueado
	Verifica se o tipo de serviço está bloqueado através do campo VOK_MSBLQL
	e se parametrizado mostrará o help

	@author Fernando Vitor Cavani
	@since 21/12/2018
	@param cTipSer , characters, Tipo de Serviço
	@param lShowHlp, logical   , Mensagem
	@return boolean, .t.|.f.   , Se bloqueado ou não
	@type method
/*/
Method TipServBloqueado(cTipSer, lShowHlp) Class DMS_Servico
	Local cMsg  := ""
	Local lBloq := .F.

	Default cTipSer  := ""
	Default lShowHlp := .T.

	If VOK->(FieldPos("VOK_MSBLQL")) > 0
		If !Empty(cTipSer)
			VOK->(dbSetOrder(1))
			VOK->(msSeek(xFilial("VOK") + cTipSer))
		EndIf

		If VOK->(Found()) .And. VOK->VOK_MSBLQL == '1'
			lBloq := .T.
		EndIf

		If lBloq .And. lShowHlp
			cMsg := chr(13) + chr(10) + "VOK" + chr(13) + chr(10)
			cMsg += RetTitle("VOK_TIPSER") + ":" + VOK->VOK_TIPSER + chr(13) + chr(10)
			cMsg += RetTitle("VOK_DESSER") + ":" + VOK->VOK_DESSER + chr(13) + chr(10)
			cMsg += RetTitle("VOK_GRUITE") + ":" + VOK->VOK_GRUITE + chr(13) + chr(10)
			cMsg += RetTitle("VOK_CODITE") + ":" + VOK->VOK_CODITE + chr(13) + chr(10)

			HELP(" ", 1, "REGBLOQ",, cMsg, 3, 1)
		EndIf
	EndIf
Return lBloq
