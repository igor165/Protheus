////////////////
// versao 031 //
////////////////

#include "protheus.ch"
#include "VEICLSAD.ch"

Function VEICLSAD()
Return()

/*/{Protheus.doc} DMS_DataContainer
	Ajuda ao trabalhar com arrays com indices intuitivos e metodos mais poderosos de contagem e soma.
	Utilizar com cautela, em volume baixo de dados para evitar overhead de metodos, para maior volume de dados ainda nao existe uma solucao.

	@author       Vinicius Gati
	@since        17/04/14
	@description  Utiliza array de arrays para salvar, recuperar e executar operacoes com dados complexos.
/*/
Class DMS_DataContainer
	Data aData

	METHOD New() CONSTRUCTOR
	METHOD GetBool() 
	METHOD GetValue()
	METHOD Gv()
	METHOD SetValue()
	METHOD Sum()
	METHOD Count()
	METHOD RemAttr()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_DataContainer
	@author Vinicius Gati
	@since 05/05/2014
/*/
METHOD New(aDataValues) Class DMS_DataContainer
	Default aDataValues := {}
	::aData := aDataValues
Return SELF

/*/{Protheus.doc} GetValue
	Pega o valor relacionado ao label

	@author  Vinicius Gati
	@since   05/05/2014
	@param   cLabel  , Array, Busca o valor dentro dos dados contidos no obj de acordo como label
	@param   bBlock  , Bloco, String usada no join
	@param   cRetPad , AnyType,   Caso não encontre valor será retornado esse parametro
	@example oObj := DMS_DataContainer:New({ {'Nome', 'Vinicius'} })
						oObj:GetValue('Nome')      => 'Vinicius'
						oObj:GetValue('Idade', 18) => 18
/*/
METHOD GetValue(cLabel, cRetPad) Class DMS_DataContainer
	nIndex := ASCAN( ::aData, {|el| el[1] == cLabel } )
	If nIndex < 1
		value := cRetPad
	Else
		value := ::aData[nIndex][2]
	EndIf
Return value

/*/{Protheus.doc} GV
	alias for GetValue
	
	@type function
	@author Vinicius Gati
	@since 11/03/2019
/*/
Method Gv(cLabel, cRetPad) Class DMS_DataContainer
return self:GetValue(cLabel, cRetPad)

/*/{Protheus.doc} GetBool
	Pega o valor relacionado ao label retornando um boolean

	@author  Vinicius Gati
	@since   05/05/2014
/*/
Method GetBool(cLabel, cRetPad) Class DMS_DataContainer
	local lVal := .F.
	uVal := self:GetValue(cLabel, cRetPad)
	if VALTYPE(uVal) == 'C'
		if UPPER(uVal) == 'TRUE'
			lVal := .T.
		endif
	else
		lVal := uVal
	endif
Return lVal

/*/{Protheus.doc} RemAttr
	Remove valor do data container

	@author Vinicius Gati
	@since 20/06/2017
/*/
Method RemAttr(cLabel) class DMS_DataContainer
	nIndex := ASCAN( self:aData, {|el| el[1] == cLabel } )
	if nIndex > 0
		aDel(self:adata, nIndex)
		aSize(self:adata, LEN(self:adata)-1)
	else
		return .f.
	end
Return .T.

/*/{Protheus.doc} SetValue
	Seta o valor relacionado ao label

	@author  Vinicius Gati
	@since   05/05/2014
	@param   cLabel  , Array, Busca o valor dentro dos dados contidos no obj de acordo como label
	@param   vValue  , Any, Valor que será setado no lavel
	@example oObj := DMS_DataContainer:New({ {'Nome', 'Vinicius'} })
						oObj:SetValue('Nome', 'Otavio')      => 'Otavio'
						oObj:GetValue('Nome')                => 'Otavio'
	@return  nil em caso de não encontrar o label
/*/
METHOD SetValue(cLabel, vValue) Class DMS_DataContainer
	nIndex := ASCAN( ::aData, { |el| el[1] == cLabel } )
	if nIndex > 0
		::aData[nIndex][2] := vValue
	Else
		AADD( ::aData , { cLabel , vValue } )
	Endif
Return vValue

/*/{Protheus.doc} Sum
	Usado fazer a soma de um determinado valor dos dados do Obj

	@author Vinicius Gati
	@since 05/05/2014
	@param cField  , Array, Label para pegar o valor por getValue
	@param bBlock  , Bloco, Bloco que será avaliado como filtro da soma, deve retornar .T. ou .F., usado para filtrar quais elementos serão filtrados, por exemplo de {1,2,3,4} quero somente a soma dos numeros pares
	@example oObj := DMS_DataContainer:New({{'Nome', 'Vinicius'}, {'Quantidade', 14}})
						oObj:Sum('Quantidade', {|el| el:GetValue('Nome' == 'Vinicius')}) // soma somente quando o nome for Vinicius
						oObj:Sum('Quantidade')                                           // Soma a quantidade de todos os dados contidos no container
/*/
METHOD Sum(cField, bBlock) Class DMS_DataContainer
	Local nSum := 0
	If VALTYPE(bBlock) == 'B'
		AEVAL(::aData, { |el| IIF(EVAL(bBlock, el), nSum += el:GetValue(cField), Nil) })
	Else
		AEVAL(::aData, { |el| nSum += el:GetValue(cField) } )
	EndIf
Return nSum

/*/{Protheus.doc} Count
	Usado para contar numero de registros que seja compativel com o retorno do bloco passado por parametro que normalmente é usado para filtro

	@author Vinicius Gati
	@since 05/05/2014
	@param bBlock , bloco , Bloco que deve retornar .T. ou .F. para filtrar os dados do Container como um seletor e definir se vai somar +1 ao Count
	@example DMS_DataContainer:Count()
/*/
METHOD Count(bBlock) Class DMS_DataContainer
	Local nQtd := 0
	If VALTYPE(bBlock) == 'B'
		AEVAL(::aData, { |el| IIF( EVAL(bBlock, el) , nQtd++, Nil ) })
	Else
		nQtd := Len(::aData)
	EndIf
Return nQtd

/*/{Protheus.doc} DMS_Devolucoes

	@author       Vinicius Gati
	@since        17/04/14
	@description  Acopla comandos de Devoluções de Vendas.
/*/
Class DMS_Devolucoes
	Data cTipFatNovo
	Data cTipFatUsado

	METHOD New() CONSTRUCTOR
	METHOD Todos()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_Devolucoes
	@author Vinicius Gati
	@since  05/05/2014
/*/
METHOD New() Class DMS_Devolucoes
	::cTipFatNovo  := "0"
	::cTipFatUsado := "1"
Return SELF

/*/{Protheus.doc} Todos
	Retorna todas as devoluções de veiculos filtrando os dados da como no exeplo

	@author    Vinicius Gati
	@since     05/05/2014
	@param     oObjData, character, Objeto do tipo DMS_DataContainer
	@example   Atributos válidos(Passar como DMS_DataContainer)
							- DataInicial   : Data inicial do periodo de vendas
							- DataFinal     : Data final do periodo de vendas
							- Novos?        : .T. ou .F. caso buscar veículos novos ou usados
							- Tipo          : Tipo do filtro de devolução
								- 'Venda'     : Filtrar Pela Data da Venda, para saber total de devoluções das vendas do periodo
								- 'Devolução' : Filtrar Pela Data da Devolução, para saber devoluções ocorridas no periodo
							- Filiais       : Array de empresas

							aData := {
									{'Novos?'     , .F.},
									{'DataInicial', '20140310'},
									{'DataFinal'  , '20140320'},
									{'Filiais'    , {'E04', 'E05'}},
									{'Tipo'       , 'Venda'}
							}
							aUsados := oDevolucoes:Todos( DMS_DataContainer():New(aData) )
/*/
METHOD Todos(oObjData) Class DMS_Devolucoes
	Local cQuery       := ''
	Local cAlias       := 'Devolucoes'
	Local aResults     := {}
	Local nIdx         := 0
	Local cDataInicio  := oObjData:GetValue('DataInicial')
	Local cDataFim     := oObjData:GetValue('DataFinal')
	Local cTipo        := oObjData:GetValue('Tipo')
	Local aFiliais     := oObjData:GetValue('Filiais')
	Local oFilHelp     := DMS_FilialHelper():New()
	Local oArrHelp     := DMS_ArrayHelper():New()
	Local cGruVei      := Left(GetMv("MV_GRUVEI")+Space(10),Len(SB1->B1_GRUPO))+"_"

	// Filiais envolvidas
	Local cFilSD1      := ''
	Local cFilVVA      := ''
	Local cFilVVR      := ''
	Local cFilVV9      := ''
	Local cFilVV0      := ''
	// Tabelas envolvidas
	Local cTblVV0 := RetSqlName("VV0")
	Local cTblSD1 := RetSqlName("SD1")
	Local cTblVVA := RetSqlName("VVA")
	Local cTblVVR := RetSqlName("VVR")
	Local cTblVV9 := RetSqlName("VV9")

	Local lTIPMOV := ( VV0->(FieldPos("VV0_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )

	For nIdx := 1 To Len(aFiliais)
		cFilSD1 := oFilHelp:GetFilial( aFiliais[nIdx], 'SD1' )
		cFilVVA := oFilHelp:GetFilial( aFiliais[nIdx], 'VVA' )
		cFilVVR := oFilHelp:GetFilial( aFiliais[nIdx], 'VVR' )
		cFilVV9 := oFilHelp:GetFilial( aFiliais[nIdx], 'VV9' )
		cFilVV0 := oFilHelp:GetFilial( aFiliais[nIdx], 'VV0' )

		cQuery += " SELECT VVA.VVA_GRUMOD , VV0.VV0_OPEMOV , VV0.VV0_FILIAL , VV0.VV0_DATMOV , "
		cQuery += "        VVA.VVA_VALMOV , VV0.VV0_DATMOV , VV0.VV0_TIPFAT , VV9.VV9_STATUS , "
		cQuery += "        VVA.VVA_CODMAR , SD1.D1_TIPO    , VVR.VVR_DESCRI "
		cQuery += "   FROM " +cTblVV0+ " VV0 "
		cQuery += "   JOIN " +cTblVVA+ " VVA ON VVA.VVA_FILIAL = '" +cFilVVA+ "' AND VVA.VVA_NUMTRA = VV0.VV0_NUMTRA "
		cQuery += "   JOIN " +cTblSD1+ " SD1 ON SD1.D1_FILIAL  = '" +cFilSD1+ "' AND SD1.D1_NFORI   = VV0.VV0_NUMNFI AND SD1.D1_SERIORI = VV0.VV0_SERNFI AND SD1.D1_TIPO = 'D' AND SD1.D1_COD = ('"+cGruVei+"'+ VVA.VVA_CHAINT) "
		cQuery += "   JOIN " +cTblVVR+ " VVR ON VVR.VVR_FILIAL = '" +cFilVVR+ "' AND VVR_CODMAR     = VVA.VVA_CODMAR AND VVR.VVR_GRUMOD = VVA.VVA_GRUMOD "
		cQuery += "   JOIN " +cTblVV9+ " VV9 ON VV9.VV9_FILIAL = '" +cFilVV9+ "' AND VV9.VV9_NUMATE = VV0.VV0_NUMTRA AND VV9.VV9_STATUS IN ('F','T','O','L') "
		cQuery += "  WHERE VV0.VV0_FILIAL = '" +cFilVV0+ "'             AND VV0.VV0_OPEMOV IN (' ','0','8')               "
		cQuery += "    AND VV0.VV0_TIPFAT IN ('0','1','2')                                                                 "
		cQuery += "    AND VV0.D_E_L_E_T_ =' '  AND VVA.D_E_L_E_T_ = ' ' AND VV9.D_E_L_E_T_ = ' ' AND SD1.D_E_L_E_T_ = ' ' AND VVR.D_E_L_E_T_ = ' ' "

		If(cTipo == 'Venda')
			cQuery += "    AND VV0.VV0_DATMOV >= '" +DTOS(cDataInicio)+ "'   AND VV0.VV0_DATMOV <= '" +DTOS(cDataFim)+ "' "
		Else
			cQuery += "    AND SD1.D1_EMISSAO >= '" +DTOS(cDataInicio)+ "'   AND SD1.D1_EMISSAO <= '" +DTOS(cDataFim)+ "' "
		EndIf

		cQuery += "    AND VV0.VV0_TIPFAT = '" + If(oObjData:GetValue('Novos?'), ::cTipFatNovo, ::cTipFatUsado) + "' "

		If lTIPMOV
			cQuery += " AND VV0.VV0_TIPMOV IN (' ','0') "
		EndIf

		If( !oArrHelp:LastIndex(nIdx, aFiliais) )
			cQuery += " UNION ALL "
		EndIf
	Next

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAlias, .F., .T. )

	(cAlias)->(DbGoTop()) // Posiciona o cursor no início da área de trabalho ativa
	While !EOF()          // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
		aEl := {                                 ;
			{ 'VVA_CODMAR', (cAlias)->VVA_CODMAR },;
			{ 'VVA_GRUMOD', (cAlias)->VVA_GRUMOD },;
			{ 'VVR_DESCRI', (cAlias)->VVR_DESCRI },;
			{ 'VVA_VALMOV', (cAlias)->VVA_VALMOV },;
			{ 'VV0_OPEMOV', (cAlias)->VV0_OPEMOV },;
			{ 'VV0_FILIAL', (cAlias)->VV0_FILIAL },;
			{ 'VV0_DATMOV', (cAlias)->VV0_DATMOV },;
			{ 'VV0_DATMOV', (cAlias)->VV0_DATMOV },;
			{ 'VV0_TIPFAT', (cAlias)->VV0_TIPFAT },;
			{ 'VV9_STATUS', (cAlias)->VV9_STATUS },;
			{ 'D1_TIPO'   , (cAlias)->D1_TIPO    },;
		}
		oEl := DMS_DataContainer():New(aEl)
		AADD(aResults, oEl)

		DbSkip()
	End
	(cAlias)->(dbCloseArea())

Return aResults

/*/{Protheus.doc} DMS_DPM

	@author       Vinicius Gati
	@since        17/05/15
	@description  Acopla helpers para buscar informacoes relacionadas a DPM
/*/
Class DMS_DPM
	DATA aFilis
	DATA cLastError
	DATA cFileName
	DATA oConf
	DATA oUtil

	METHOD New() CONSTRUCTOR
	METHOD getRotinasProcesso()
	METHOD getStatus()
	METHOD GetPecGroups()
	METHOD GetFiliais()
	METHOD GetFilArms()
	METHOD OrcToReproc()
	//METHOD OsToReproc() - Alex - Obsoleto
	METHOD GetType()
	METHOD OrcsToReproc()
	//METHOD OssToReproc() -- Alex - Obsoleto
	METHOD ResetDemOs()
	METHOD ResetDemOrc()
	METHOD ClrDemanda()
	METHOD GetConfigs()
	METHOD GetMedInv()
	METHOD Get24MedInv()
	METHOD GetDevCount()
	METHOD GetDevData()
	METHOD GetQtdCan()
	METHOD GetSitsDem()
	METHOD GetInGroups()
	METHOD GetImportantMessages()
	METHOD Alerted()
	METHOD IsProcessed()
	Method GetFilial()
	Method GetJdCode()
	Method Ready()
	Method isFilEst()
	Method UsaFilArm()
	Method DebugMode()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_DPM
	@author Vinicius Gati
	@since  17/07/2015
/*/
METHOD New() Class DMS_DPM
	::aFilis := {}
	::oUtil  := DMS_Util():New()
	::oConf  := ::oUtil:ParamFileOpen(FWCodEmp() + "_dpm_config.json")
Return SELF

/*/{Protheus.doc} DebugMode
	Se o DPM está configurado no OFIA170 para debug, sendo assim alguns
	programas vao gravar mais logs

	@type function
	@author Vinicius Gati
	@since 16/07/2019
/*/
Method DebugMode() Class DMS_DPM
Return self:oConf:GetValue("DEBUGANDO", "0") == "1"

/*/{Protheus.doc} isFilEst
	Verifica se a filial possui a filial de reserva como estoque adicional

	@type function
	@author Vinicius Gati
	@since 31/05/2019
/*/
Method isFilEst(cFil, cFilEst) Class DMS_DPM
	aFilsArm := self:oConf:GetValue("FILIAIS_ARMAZEM", {})
	nFound   := ASCAN(aFilsArm, {|oCfg| oCfg:GetValue('FILIAL') == cFil .and. oCfg:GetValue('FILIAL_ARM') == cFilEst })
Return nFound > 0

/*/{Protheus.doc} GetFilArms
	Pega as filiais do DPM que foram configuradas como armazem

	@type function
	@author Vinicius Gati
	@since 04/06/2019
/*/
Method GetFilArms(cFil) Class DMS_DPM
	local oArrHelp := DMS_ArrayHelper():New()
	local aArms    := self:oConf:GetValue("FILIAIS_ARMAZEM", {})
	default cFil   := ''

	// filtra somente os armazens daquela filial x
	if ! empty(cFil)
		aArms := oArrHelp:Select(aArms, {|oArm| oArm:GetValue('FILIAL', '') == cFil })
	endif
return oArrHelp:Map(aArms, {|oEl| {oEl:GetValue('FILIAL_ARM'),'ARM','ARM'} })

/*/{Protheus.doc} UsaFilArm
	Verifica se usa filiais armazem no dpm
	
	@type function
	@author Vinicius Gati
	@since 18/06/2019
/*/
Method UsaFilArm() Class DMS_DPM
return len(self:GetFilArms()) > 0

/*/{Protheus.doc} Ready
	Função que determina se o DPM está 100% compatível com a versão dos programas

	@type function
	@author Vinicius Gati
	@since 16/10/2017
/*/
Method Ready(lSendMail) Class DMS_DPM
	local cMsg := "Base VQ3 não transferida para VB8 completamente, por favor rode o OFINJD45 para completar o processo."
	local nQtdToImp := FM_SQL("SELECT COUNT(*) FROM " + RetSqlName('VQ3') + " WHERE VQ3_TIPREG in ('C','N',' ') AND D_E_L_E_T_ = ' ' ")
	Default lSendMail := .T.
	if nQtdToImp > 0
		self:cLastError := cMsg
		if lSendMail
			oEmail := DMS_EmailHelper():New()
			oEmail:SendTemplate({;
				{'template'           , 'mil_sys_err'                                               },;
				{'origem'             , GetNewPar("MV_MIL0088", "")                                 },;
				{'destino'            , GetNewPar("MV_MIL0102", "")                                 },;
				{'assunto'            , "[DPM] problema detectado " + dtoc(DATE()) + " " + TIME()   },;
				{':titulo'            , "[DPM] problema detectado " + dtoc(DATE()) + " " + TIME()   },;
				{':cabecalho1'        , "O DPM detectou um problema:"                               },;
				{':dados_cabecalho1'  , cMsg                                                        } ;
			})
		endif
		conout('################################')
		conout('######|  _ \|  _ \|  \/  |######')
		conout('######| | | | |_) | |\/| |######')
		conout('######| |_| |  __/| |  | |######')
		conout('######|____/|_|   |_|  |_|######')
		conout('################################')
		conout(cMsg)
		return .F.
	endif
Return .T.

/*/{Protheus.doc} GetFilial
	Retorna a filial protheus do JDCode
	@author Vinicius Gati
	@since  17/07/2015
/*/
Method GetFilial(cJdCode) class DMS_DPM
	if Empty(self:aFilis)
		self:GetFiliais()
	End

	nIdx := ASCAN(self:aFilis, {|i| ALLTRIM( i[2] ) == ALLTRIM(cJdCode)})
Return self:aFilis[nIdx][1] // filial pos 1

/*/{Protheus.doc} GetJdCode
	Retorna o JD code da filial protheus
	@author Vinicius Gati
	@since  06/10/2017
/*/
Method GetJdCode(cFilOri) class DMS_DPM
	if Empty(self:aFilis)
		self:GetFiliais()
	End
	nIdx := ASCAN(self:aFilis, {|i| ALLTRIM( i[1] ) == ALLTRIM(cFilOri)})
Return self:aFilis[nIdx,2]

/*/{Protheus.doc} getRotinas
	Retorna as rotinas que possuem processamento
	@author Vinicius Gati
	@since  17/07/2015
/*/
METHOD getRotinasProcesso() Class DMS_DPM
	Local oSqlHlp := DMS_SqlHelper():New()
Return oSqlHlp:GetSelect({;
		{'campos', {"VQL_AGROUP"}}, ;
		{'query', "SELECT DISTINCT VQL_AGROUP FROM " +RetSqlName('VQL') + " WHERE VQL_CODVQL=' ' AND D_E_L_E_T_ = ' ' ORDER BY VQL_AGROUP"};
	})

/*/{Protheus.doc} getStatus

	Retorna status da rotina, se está normal ou precisa de atenção.
	Não existe uma maneira de saber exatamente se foi rodada ainda (isso será feito com logs), mas este metodo retorna
	um acompanhamento que serve de base para averiguar e normalizar possíveis inconsistencias.

	@author  Vinicius Gati
	@since   05/05/2014
	@param   aData  , Array, Parametros do metodo: rotina, mes, ano
	@example oX:getStatus({ {'rotina', 'OFINJDXX'}, {'mes', '06'}, {'ano', '2015'} })

/*/
METHOD getStatus(aData) Class DMS_DPM
	Local cQuery     := ""
	Local oSqlHlp    := DMS_SqlHelper():New()
	Local oUtil      := DMS_Util():New()
	Local oData      := DMS_DataContainer():New(aData)

	cDataInicio := oData:GetValue('ano') + oData:GetValue('mes') + "01" // Formato DTOS ano mes dia
	cDataFim    := DTOS( oUtil:UltimoDia(VAL(oData:GetValue('ano')), VAL(oData:GetValue('mes'))) )

	cQuery := "  SELECT * FROM " + oSqlHlp:NoLock('VQL')
	cQuery += "   WHERE VQL_AGROUP = '"+oData:GetValue('rotina', "")+"' "
	cQuery += "     AND D_E_L_E_T_ = ' ' "
	cQuery += "     AND VQL_DATAI  BETWEEN '"+cDataInicio+"' AND '"+cDataFim+"' "
	cQuery += " ORDER BY VQL_DATAI DESC "
	cQuery += oSqlHlp:TopFunc(cQuery, 400)
Return  oSqlHlp:GetSelect({ ;
			{'campos', {'VQL_AGROUP','VQL_DATAI', 'VQL_DATAF', 'VQL_DADOS'} },;
			{'query' , cQuery                                               } ;
		})

/*/{Protheus.doc} GetPecGroups

	@author       Vinicius Gati
	@since        13/07/2015
	@description  Pega grupos considerados do OFINJD09 para cachear saldos

/*/
Method GetPecGroups() Class DMS_DPM
	Local aGrupos    := {}
	Local lNewGrpDPM := (SBM->(FieldPos('BM_VAIDPM')) > 0)
	Local oArrHelp   := DMS_ArrayHelper():New()
	Local oSqlHlp    := DMS_SqlHelper():New()
	Local cGrupos    := ""
	Local cQuery

	if lNewGrpDPM
		cQuery := " SELECT BM_GRUPO FROM "+RetSqlName('SBM')+" WHERE BM_FILIAL = '"+xFilial('SBM')+"' AND BM_VAIDPM = '1' AND D_E_L_E_T_ = ' ' "
		aGrupos := oSqlHlp:GetSelect({;
			{'campos', {"BM_GRUPO"}},;
			{'query' , cQuery      } ;
		})
		aGrupos := oArrHelp:Map(aGrupos, {|oEl| oEl:GetValue("BM_GRUPO") })
	Else
		dbSelectArea("SX1")
		dbSetOrder(1)
		dbSeek('OFINJD09  '+"03")
		cGrupos += ALLTRIM(SX1->X1_CNT01)
		dbSeek('OFINJD09  '+"05")
		cGrupos += ALLTRIM(SX1->X1_CNT01)
		dbSeek('OFINJD09  '+"06")
		cGrupos += ALLTRIM(SX1->X1_CNT01)
		dbSeek('OFINJD09  '+"07")
		cGrupos += ALLTRIM(SX1->X1_CNT01)
		dbSeek('OFINJD09  '+"08")
		cGrupos += ALLTRIM(SX1->X1_CNT01)
		dbSeek('OFINJD09  '+"09")
		cGrupos += ALLTRIM(SX1->X1_CNT01)
		aGrupos := STRTOKARR( cGrupos, "/" )
	EndIf
Return aGrupos

/*/{Protheus.doc} GetInGroups

	@author       Vinicius Gati
	@since        13/07/2015
	@description  Retorna os grupos como formatados para usar em um IN já com parenteses[pronto para novo padrão DPM]

/*/
Method GetInGroups() Class DMS_DPM
	Local oArHlp
	Local aGrupos, aGruposIN
	oArHlp    := DMS_ArrayHelper():New()
	aGrupos   := self:GetPecGroups()
	aGruposIN := oArHlp:Map(aGrupos, { |cGrupo| "'" + ALLTRIM(cGrupo) + "'" })
Return " (" + oArHlp:Join(aGruposIN, ",") + ") "

/*/{Protheus.doc} GetSitsDem

	@author       Vinicius Gati
	@since        08/09/2015
	@description  Retorna as situacoes que sao consideradas na demanda do DPM

/*/
Method GetSitsDem() Class DMS_DPM
	Local oSqlHlp := DMS_SqlHelper():New()
	Local oArrHelp := DMS_ArrayHelper():New()
	Local aSits := {}

	aSits := oSqlHlp:GetSelect({ ;
		{'campos', {'V09_CODSIT'} },;
		{'query' , "SELECT V09_CODSIT FROM " + oSqlHlp:NoLock('V09') + " WHERE V09.D_E_L_E_T_ = ' ' AND V09.V09_LEVDEM = '1' " } ;
	})

	aSits := oArrHelp:Map( aSits, {|el| el:GetValue('V09_CODSIT') } )
Return aSits


/*/{Protheus.doc} GetFiliais

	@author       Vinicius Gati
	@since        13/07/2015
	@description  Pega os dados de todas as filiais do sistema configuradas para DPM

/*/
Method GetFiliais(cDealerAcc) Class DMS_DPM

	Local nPosFil := 0

	Default cDealerAcc := ""

	If Empty(self:aFilis)
		DBSelectArea("SX6")
		SX6->(DBSetOrder(1)) // não tem chave #lento
		SX6->(DBGoTop())
		while !SX6->(EOF())
			if ALLTRIM(SX6->X6_VAR) == "MV_MIL0005"
				aAdd(::aFilis,{SX6->X6_FIL, SX6->X6_CONTEUD, Right(ALLTRIM(SX6->X6_FIL),2)})
			endif
			SX6->( DBSkip() )
		enddo
	EndIf

	If !Empty(cDealerAcc)
		nPosFil := ASCAN(::aFilis,{ |x| Alltrim(x[2]) == cDealerAcc })
		If nPosFil > 0
			Return ::aFilis[nPosFil,1]
		Else
			Return ""
		EndIf
	EndIf

Return ::aFilis

/*/{Protheus.doc} OrcToReproc
	Vai colocar ele em espera para reprocessar no OFINJD31

	@author Vinicius Gati
	@since  12/08/2015
/*/
Method OrcToReproc(cFil, cOrc) Class DMS_DPM
	Local oLogger := DMS_Logger():New()
	oLogger:LogToTable({ ;
		{'VQL_AGROUP'     , 'OFINJD31'   },;
		{'VQL_TIPO'       , "REPROC_ORC" },;
		{'VQL_DADOS'      , cOrc         },;
		{'VQL_FILORI'     , cFil         } ;
	})
Return .T.

/*/{Protheus.doc} OsToReproc
	Vai colocar ele em espera para reprocessar no OFINJD31

	@author Vinicius Gati
	@since  12/08/2015
/*/
/*
Method OsToReproc(cFil, cOsNum) Class DMS_DPM
	Local oLogger := DMS_Logger():New()
	oLogger:LogToTable({ ;
		{'VQL_AGROUP'     , 'OFINJD31'   },;
		{'VQL_TIPO'       , "REPROC_OS"  },;
		{'VQL_DADOS'      , cOsNum       },;
		{'VQL_FILORI'     , cFil         } ;
	})
Return .T.
*/

/*/{Protheus.doc} OrcsToReproc

	@author       Vinicius Gati
	@since        17/08/2015
	@description  Retorna os orçamentos que tem requisicoes marcadas para reprocessamento

/*/
Method OrcsToReproc() Class DMS_DPM
	LOCAL oSql     := DMS_SqlHelper():New()
Return oSql:GetSelect({ ;
	{'campos', {'VQL_FILORI','VQL_DADOS'}},;
	{'query' , " SELECT VQL_FILORI,VQL_DADOS FROM " + RetSqlName('VQL') + " WHERE D_E_L_E_T_ = ' ' AND VQL_AGROUP = 'OFINJD31' AND VQL_TIPO = 'REPROC_ORC' " } ;
})

/*/{Protheus.doc} OssToReproc

	@author       Vinicius Gati
	@since        17/08/2015
	@description  Retorna as os's que tem requisicoes marcadas para reprocessar

/*/
/* - Alex - Obsoleto
Method OssToReproc() Class DMS_DPM
	LOCAL oSql := DMS_SqlHelper():New()
Return oSql:GetSelect({;
	{'campos', {'VQL_FILORI','VQL_DADOS'}},;
	{'query' , " SELECT VQL_FILORI, VQL_DADOS FROM " + RetSqlName('VQL') + " WHERE D_E_L_E_T_ = ' ' AND VQL_AGROUP = 'OFINJD31' AND VQL_TIPO = 'REPROC_OS' " } ;
})
*/

/*/{Protheus.doc} ResetDemOs

	@author       Vinicius Gati
	@since        17/08/2015
	@description  Zera demanda criada para esta Ordem de serviço e demais no mesmo dia, o esquema vai ser reprocessar os dias inteiros afetados pela OS

/*/
Method ResetDemOs(cFil, cOs) CLASS DMS_DPM
	//TODO: faremos em outro CI
Return .T.

/*/{Protheus.doc} ResetDemOrc

	@author       Vinicius Gati
	@since        17/08/2015
	@description  Zera demanda gerada para este orçamento

/*/
Method ResetDemOrc(cFil, cOrc) CLASS DMS_DPM
	LOCAL cFilBck  := cFilAnt
	LOCAL oSql     := DMS_SqlHelper():New()
	LOCAL oArrHelp := DMS_ArrayHelper():New()

	cFilAnt := cFil
	cOrc := ALLTRIM(cOrc) // ta grande o tamanho dou uma limpada para evitar trafego

	// tem venda perdida? data no VB8 quando tem venda perdida é do orcamento
	lTemVP := FM_SQL(" SELECT COALESCE(COUNT(*), 0) FROM " + oSql:NoLock('VS3') + " WHERE VS3_FILIAL = '"+xfilial('VS3')+"' AND VS3_FLGNAT = 'I' AND VS3_NUMORC = '"+cOrc+"' AND D_E_L_E_T_ = ' ' ") > 0
	If lTemVP
		cDataVP := FM_SQL(" SELECT VS1_DATORC FROM " + oSql:NoLock('VS1') + " WHERE VS1_FILIAL = '"+xfilial('VS1')+"' AND VS1_NUMORC = '"+cOrc+"' AND D_E_L_E_T_ = ' ' ")
		self:ClrDemanda(STOD(cDataVP))
	EndIf
	//
	// Pego as datas afetadas pelo orcamento faturado para limpar VB8
	cQuery := "    SELECT D2_EMISSAO "
	cQuery += "      FROM " + oSql:NoLock('SD2')
	cQuery += "      JOIN " + oSql:NoLock('VS1') + " ON VS1_FILIAL = SD2.D2_FILIAL AND VS1_NUMORC = '"+cOrc+"' AND VS1_NUMNFI = D2_DOC AND VS1_SERNFI = D2_SERIE AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "     WHERE SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL  = '" + xFilial('SD2') + "'"
	cQuery += "  GROUP BY D2_EMISSAO "
	aDatas := oSql:GetSelect({ ;
		{'campos', {'D2_EMISSAO'}},;
		{'query' , cQuery        } ;
	})
	if LEN(aDatas) == 0 // é pedido
		cQuery := "    SELECT D2_EMISSAO "
		cQuery += "      FROM " + oSql:NoLock('SD2')
		cQuery += "      JOIN " + oSql:NoLock('VS1')        + " ON VS1.VS1_FILIAL = SD2.D2_FILIAL  AND VS1.VS1_NUMNFI = D2_DOC         AND VS1_SERNFI     = D2_SERIE       AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "      JOIN " + oSql:NoLock('VS1', 'PED') + " ON PED.VS1_FILIAL = VS1.VS1_FILIAL AND PED.VS1_NUMORC = VS1.VS1_PEDREF AND PED.VS1_NUMORC = '" + cOrc + "' AND PED.VS1_TIPORC = 'P' AND PED.D_E_L_E_T_ = ' ' "
		cQuery += "     WHERE SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL  = '" + xFilial('SD2') + "'"
		cQuery += "  GROUP BY D2_EMISSAO "
		aDatas := oSql:GetSelect({ ;
			{'campos', {'D2_EMISSAO'}},;
			{'query' , cQuery        } ;
		})
	EndIf
	//
	if LEN(aDatas) > 0
		oArrHelp:Map(aDatas, { |oEl| self:ClrDemanda(oEl:GetValue('D2_EMISSAO')) }) // executa clear demanda para todas as datas
	EndIf
	//
	cFilAnt := cFilBck
Return .T.

/*/{Protheus.doc} ClrDemanda

	@author       Vinicius Gati
	@since        17/08/2015
	@description  Limpa VB8 na data passada, e limpa todos os registros que podem ter afetado a data

/*/
Method ClrDemanda(dData) Class DMS_DPM
	LOCAL cQuery   := ""
	LOCAL oSql     := DMS_SqlHelper():New()
	LOCAL nIdx     := 1
	Local nIdxCd   := 1
	LOCAL cPrefBal := GetNewPar("MV_PREFBAL","BAL")

	If VALTYPE(dData) != "D" // deu erro na agro embora testei aqui e estava ok
		dData := STOD(dData)
	Endif

	cbckFil := cFilAnt

	cQuery := ""
	cQuery += "SELECT SD2.R_E_C_N_O_ as ID_SD2, SF2.R_E_C_N_O_ as ID_SF2, SF2.F2_PREFORI F2_PREFORI, "
	cQuery += "     (SELECT COALESCE(COUNT(*), 0) "
	cQuery += "        FROM " +oSql:Nolock('SD1')
	cQuery += "       WHERE SF2.F2_FILIAL  = SD1.D1_FILIAL    AND SF2.F2_DOC      = SD1.D1_NFORI "
	cQuery += "         AND SF2.F2_SERIE   = SD1.D1_SERIORI   AND SD1.D_E_L_E_T_  = ' ' "
	cQuery += "         AND SD2.D2_COD     = SD1.D1_COD     "
	cQuery += "         AND SD1.D1_ITEMORI = SD2.D2_ITEM    "
	cQuery += "         AND SD2.D2_EMISSAO = SD2.D2_EMISSAO "
	cQuery += "         AND D1_FLGNAT      = 'A' ) as DEVOLUCOES_NA_DATA "
	cQuery += "  FROM " +oSql:Nolock('SD2')
	cQuery += "  JOIN " +oSql:Nolock('SF2') + " ON SF2.F2_FILIAL = D2_FILIAL AND SD2.D2_FILIAL = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE D2_EMISSAO     = '"+DTOS(dData)+"' "
	cQuery += "   AND D2_FLGNAT     <> ' ' "
	cQuery += "   AND D2_FLGNAT     <> 'C' "
	cQuery += "   AND SD2.D_E_L_E_T_ = ' ' "
	aNotas := oSql:GetSelect({;
		{'campos', {'ID_SD2', 'F2_PREFORI', 'DEVOLUCOES_NA_DATA'}},;
		{'query' , cQuery                                        } ;
	})

	For nIdx := 1 to LEN(aNotas)
		oNota := aNotas[nIdx]
		dbSelectArea('SD2')
		dbGoTo( oNota:GetValue('ID_SD2') )
		reclock('SD2', .F.)

		cFilAnt := SD2->D2_FILIAL

		// VOLTANDO DEVOLUCOES
		If VAL(ALLTRIM(oNota:GetValue('DEVOLUCOES_NA_DATA'))) > 0
			dbSelectArea('SF2')
			dbGoTo( oNota:GetValue('ID_SF2') )
			TCSqlExec( "UPDATE " + RetSqlName('SD1') + " SET D1_FLGNAT = ' ' WHERE D1_FILIAL = '" + ALLTRIM(SF2->F2_FILIAL) + "' AND SD1.D1_NFORI = '"+SF2->F2_DOC+"' AND SD1.D1_SERIORI = '"+SF2->F2_SERIE+"' AND SD1.D1_COD = '"+SD2->D2_COD+"' AND SD1.D1_ITEMORI = '"+SD2->D2_ITEM+"'  AND SD2.D2_EMISSAO = '"+DTOS(SD2->D2_EMISSAO)+"' AND D1_FLGNAT <> ' ' AND D1_FLGNAT <> 'C' " )
		EndIf

		If oNota:GetValue('F2_PREFORI') == cPrefBal // foi balcão
			// Limpar os VS3's
			cQuery := " UPDATE " + RetSqlName('VS3') + " SET VS3_FLGNAT = ' ' WHERE R_E_C_N_O_ IN ( "
			cQuery += " SELECT VS3.R_E_C_N_O_ " // RECNO do PEDIDO(muito importante isso)
			cQuery += "   FROM " + oSql:NoLock('VS1', 'ORC')
			cQuery += "   JOIN " + oSql:NoLock('VS1', 'PED') + " ON PED.VS1_FILIAL = ORC.VS1_FILIAL AND PED.VS1_NUMORC = ORC.VS1_PEDREF AND PED.D_E_L_E_T_ = ' ' AND PED.VS1_TIPORC = 'P' "
			cQuery += "   JOIN " + oSql:Nolock('VS3')        + " ON VS3.VS3_FILIAL = PED.VS1_FILIAL AND VS3.VS3_NUMORC = PED.VS1_NUMORC AND VS3.D_E_L_E_T_ = ' ' "
			cQuery += "  WHERE ORC.VS1_NUMNFI = '"+SD2->D2_DOC   +"'"
			cQuery += "    AND ORC.VS1_SERNFI = '"+SD2->D2_SERIE +"'"
			cQuery += "    AND ORC.VS1_FILIAL = '"+SD2->D2_FILIAL+"'"
			cQuery += "    AND VS3_FLGNAT != 'C' "
			cQuery += "    AND ORC.D_E_L_E_T_ = ' ' "
			cQuery += " )"
			TCSqlExec(cQuery)
		End

		SD2->D2_FLGNAT = ' '
		SD2->(MSUNLOCK())
	Next


	For nIdx := 1 to LEN(self:GetFiliais())
		cFilAnt := self:GetFiliais()[nIdx,1]

		If VSJ->(FieldPos("VSJ_FLGNAT")) > 0 // se possui nivel de atendimento oficina
			//
			// Nivel de atendimento oficina, parte do rubens (OS)
			//
			TCSqlExec(" UPDATE "+RetSqlName('VSJ')+" SET VSJ_FLGNAT  = ' ' WHERE VSJ_FILIAL = '"+xFilial('SFJ')+"' AND VSJ_DATREQ = '"+DTOS(SD2->D2_EMISSAO)+"' AND VSJ_FLGNAT <> 'C' ")
		End
		//
		// Essa query é copiada "quase" identica do OFINJD31, e necessario altera-la se alterar la
		// "quase" fica por conta de certos parametros que não cabem aqui, tipo flagnat em branco, aqui vamos deixar em branco então não faz sentido
		//
		cQuery := " "
		cQuery += "      SELECT SD2.R_E_C_N_O_ CODIGO, VS3.R_E_C_N_O_ CODIGO2, VS3_CODSIT, D2_COD, B1_CRICOD, D2_CLIENTE, D2_LOJA, D2_EMISSAO, BM_PROORI, D2_TOTAL, D2_CUSTO1, D2_QUANT, VS3_QESTNA, VS3_QTDINI "
		cQuery += "        FROM " + oSql:NoLock("SD2") + " "
		cQuery += "  INNER JOIN " + oSql:NoLock("VOO") + " ON VOO_FILIAL = '"+xFilial('VOO')+"' AND VOO_NUMNFI    = D2_DOC        AND VOO_SERNFI     = D2_SERIE      AND VOO_TOTPEC > 0          AND VOO.D_E_L_E_T_ = ' ' "
		cQuery += "  INNER JOIN " + oSql:NoLock("VS1") + " ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMOSV    = VOO_NUMOSV    AND VS1_TIPORC     = '2'           AND VS1_TIPTEM = VOO_TIPTEM AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "  INNER JOIN " + oSql:NoLock("VS3") + " ON VS3_FILIAL = VS1_FILIAL           AND VS3_NUMORC    = VS1_NUMORC    AND VS3.D_E_L_E_T_ = ' ' "
		cQuery += "  INNER JOIN " + oSql:NoLock("SB1") + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_COD        = D2_COD        AND B1_COD         = VS3_CODITE    AND B1_GRUPO   = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "  INNER JOIN " + oSql:NoLock("SBM") + " ON BM_FILIAL  = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO  = SBM.BM_GRUPO  AND SBM.D_E_L_E_T_ = ' ' "
		cQuery += "  INNER JOIN " + oSql:NoLock("SF4") + " ON F4_FILIAL  = '"+xFilial("SF4")+"' AND SD2.D2_TES    = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ = ' ' "
		cQuery += "       WHERE D2_FILIAL  = '"+xFilial('SD2')+"' AND SD2.D_E_L_E_T_ = ' ' "
		cQuery += "         AND D2_EMISSAO = '"+DTOS(dData)+"' "
		cQuery += "         AND D2_FLGNAT   != 'C' " // congelamento de demanda para minas verde
		cQuery += "         AND VS3_FLGNAT  != 'C' " // congelamento de demanda para minas verde
		if SBM->(FieldPos('BM_VAIDPM')) > 0
			cQuery += " AND BM_VAIDPM = '1' "
		else
			cQuery += " AND VS3.VS3_GRUITE IN " + oDpm:GetInGroups()
		endif
		aCodigos := oSql:GetSelect({;
			{'campos', {'CODIGO', 'CODIGO2'}},;
			{'query' , cQuery               } ;
		})
		//
		For nIdxCd := 1 to LEN(aCodigos)
			TCSqlExec(" UPDATE "+RetSqlName('SD2')+" SET D2_FLGNAT  = ' ' WHERE R_E_C_N_O_ = "+ ALLTRIM(STR(aCodigos[nIdxCd]:getValue('CODIGO' )))+ " AND D2_FLGNAT  != 'C' " )
			TCSqlExec(" UPDATE "+RetSqlName('VS3')+" SET VS3_FLGNAT = ' ' WHERE R_E_C_N_O_ = "+ ALLTRIM(STR(aCodigos[nIdxCd]:getValue('CODIGO2')))+ " AND VS3_FLGNAT != 'C' " )
		next
		//
		if TCSqlExec(" UPDATE " + RetSqlName('VOO') + " SET VOO_FLGNAT = ' ' WHERE VOO_FILIAL = '" + xFilial('VOO') + "' AND VOO_SERNFI = '" + ALLTRIM(SD2->D2_SERIE) + "' AND VOO_NUMNFI = '"+ALLTRIM(SD2->D2_DOC)+"' AND D_E_L_E_T_ = ' ' AND VOO_FLGNAT <> ' ' AND VOO_FLGNAT != 'C' ") < 0
			conout(TCSQLError())
		endif

		// VENDA PERDIDA
		cQuery := " UPDATE " + RetSqlName('VS3') + " SET VS3_FLGNAT = ' ' WHERE R_E_C_N_O_ IN ("
		cQuery += " SELECT VS3.R_E_C_N_O_ "
		cQuery += "   FROM "+oSql:NoLock('VS3')+" "
		cQuery += "   JOIN "+oSql:NoLock('VS1')+" ON VS1.VS1_FILIAL = VS3.VS3_FILIAL AND VS1.VS1_NUMORC = VS3.VS3_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "  WHERE VS3.D_E_L_E_T_ = ' ' "
		cQuery += "    AND VS3.VS3_FLGNAT = 'I' "
		cQuery += "    AND VS1.VS1_DATORC = '" + DTOS(dData) + "' "
		cQuery += "    AND VS1.VS1_TIPORC = 'P' "
		cQuery += ") AND VS3_FLGNAT <> ' ' "
		if TCSqlExec(cQuery) < 0
			conout(TCSQLError())
		endif

		TCSqlExec(" UPDATE " + RetSqlName('VB8') + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE VB8_ANO = '" + LEFT(DTOS(dData), 4) + "' AND VB8_MES = '" + Subs(DTOS(dData), 5, 2) + "' AND VB8_DIA = '" + RIGHT(DTOS(dData), 2) + "' AND VB8_TIPREG IN (' ', 'N') AND VB8_TIPREG != 'C' AND D_E_L_E_T_ = ' ' ")

		TCSqlExec(" UPDATE " + RetSqlName('SD2') + " SET D2_FLGNAT = ' ' WHERE D2_FILIAL = '"+xFilial('SD2')+"' AND D2_EMISSAO = '"+DTOS(dData)+"' AND D2_FLGNAT = 'A' ")
	Next
	//
	cFilAnt := cbckFil
Return .T.

/*/{Protheus.doc} GetMedInv
	Media de inventario ultimos 12 meses

	@author       Vinicius Gati
	@since        21/08/2015

/*/
Method GetMedInv(cFil, cCodCri, dDataAnt, cTipo) CLASS DMS_DPM
	Local oUtil      := DMS_Util():New()
	Local oCache     := DMS_CacheB2():New()
	Local nIdx       := 1
	Local nTot       := 0
	Local nQtdInvs   := 0
	Local nHighValue := 0
	Local aTots      := {}
	Local nValue     := 0  // auxiliar
	Local nPercCorte := 10 // percentual de corte de lixo, alguns inventarios podem conter lixos com valores e esses devem ser cortados da conta pois podem afetar drasticamente a media
	//
	// dDataAnt := oUtil:RemoveMeses(dData, 1) // mes passado
	//
	// Pega o inventario dos ultimos 12 meses e vai salvando os valores, inclusive o maior valor que sera usado nos cortes
	//
	for nIdx := 1 to 12 // 11 meses atras pois faz media dos ultimos 12 incluindo o atual
		dUltDia := oUtil:UltimoDia( YEAR(dDataAnt), MONTH(dDataAnt) )

		nInv := oCache:GetTotInv({;
			{'filial'        , cFil    },;
			{'data'          , dUltDia },;
			{'critical_code' , cCodCri },;
			{'tipo'          , cTipo   } ; // tipo = original ou nao original
		})

		nHighValue := IIF(nHighValue < nInv, nInv, nHighValue)
		AADD(aTots, nInv)

		dDataAnt := oUtil:RemoveMeses(dDataAnt, 1) // diminui um mes, ate 12 meses atras
	next
	//
	// Para cada valor, vejo se o valor esta dentro do valor de corte e removo ou registro se estiver nos conformes
	//
	for nIdx := 1 to LEN(aTots)
		nValue := aTots[nIdx]
		If ( (nValue*100)/nHighValue ) > nPercCorte
			nTot += nValue
			nQtdInvs ++
		EndIf
	Next
	//
Return nTot/nQtdInvs // calcula a media

/*/{Protheus.doc} Get24MedInv
	Media de inventario dos 12 meses anteriores ao ultimos 12, por isso 24 no nome da funcao
	o algoritmo é basicamente remover 12 meses da data atual e passar pra fazer o inventario dos ultimos 12 meses, so alegria usar metodo ja pronto

	@author       Vinicius Gati
	@since        21/08/2015

/*/
Method Get24MedInv(cFil, cCodCri, dData, cTipo) CLASS DMS_DPM
	Local dData12Ant := dData
	Local nIdx       := 1
	for nIdx := 1 to 12
		dData12Ant := oUtil:RemoveMeses(dData12Ant, 1) // diminui um mes, ate 12 meses atras
	next
Return self:GetMedInv(cFil, cCodCri, dData12Ant, cTipo)

/*/{Protheus.doc} GetConfigs
	Metodo que retorna as configuracoes de dpm

	@author       Vinicius Gati
	@since        21/08/15
/*/
Method GetConfigs() Class DMS_DPM
	Local aDados := {}
	Local aCfgs  := {}
	Local oArHlp := DMS_ArrayHelper():New()
	Local oSql   := DMS_SqlHelper():New()

	aDados := oSql:GetSelect({;
		{'campos', {'VQL_AGROUP'}},;
		{'query' , "SELECT VQL_AGROUP FROM " + RetSqlName('VQL') + " WHERE D_E_L_E_T_ =' ' and VQL_AGROUP like 'DPMC%' GROUP BY VQL_AGROUP "} ;
	})
Return oArHlp:Map(aDados, {|el| DMS_DPMConfig():New(el:GetValue('VQL_AGROUP')) })

/*/{Protheus.doc} GetDevCount
	Retorna quantidade de hits/popularidade para subtrair desse produto nesse mes nesse dia

	@author       Vinicius Gati
	@since        21/08/15
/*/
Method GetDevCount(cFil, cProdut, cAno, cMes, cDia) Class DMS_DPM
	Local cQuery
	Local cBckFilial := cFilAnt
	Local oSqlHlp    := DMS_SqlHelper():New()
	Local oUtil      := DMS_Util():New()
	Local cData1
	Local cData2     := ""
	Default cDia     := ""

	cData1 := cAno + cMes + cDia
	cFilAnt := cFil

	If Empty(cDia)
		cData2 := DTOS(oUtil:UltimoDia( VAL(cAno), VAL(cMes) ))
		cData1 := LEFT( cData2 , 6) + "01"
	Else
		cData2 := cData1
	EndIf

	cTopQry := " SELECT VS3_CODSIT FROM "+oSqlHlp:NoLock('VS1', 'VS1P')+" JOIN "+oSqlHlp:NoLock('VS3', 'VS3P')+"  ON VS1P.VS1_FILIAL = VS3P.VS3_FILIAL AND VS3P.VS3_NUMORC = VS1P.VS1_NUMORC AND VS3P.VS3_CODITE = SB1.B1_COD AND VS3P.VS3_GRUITE = SB1.B1_GRUPO AND VS3P.D_E_L_E_T_ = ' ' WHERE VS1P.VS1_NUMORC = VS1.VS1_PEDREF "
	cTopQry := oSqlHlp:TOPFunc(cTopQry, 1)

	// o select pega a quantidade da nota devolvida, porem e necessario averiguar se a mesma entrou na demanda para contabilizar, caso contrario sera considerada e valores negativos podem ocorrer nas contabilizacoes
	cQuery := " SELECT COALESCE( SUM(QUANT), 0) as QUANTIDADE from ( " // soma quantos foram devolvidos por completo, para remover dos hits.
	cQuery += " SELECT CASE WHEN VS1.VS1_TIPORC = 'P' THEN VS3_CODSIT ELSE ("+cTopQry+") END AS VS3_CODSIT, "
	cQuery += "        CASE WHEN SD2.D2_QUANT = SD1.D1_QUANT THEN 1 ELSE 0 END QUANT " // se devolveu mesmo tanto remove 1 hit senao nenhum.
	cQuery += "   FROM "+oSqlHlp:NoLock("SD1")
	cQuery += "   JOIN "+oSqlHlp:NoLock("SF2")+" ON ( SF2.F2_FILIAL =SD1.D1_FILIAL        AND SF2.F2_DOC=SD1.D1_NFORI AND SF2.F2_SERIE=SD1.D1_SERIORI  AND SF2.F2_PREFORI IN ('"+GetNewPar("MV_PREFBAL","BAL")+"','"+GetNewPar("MV_PREFOFI","OFI")+"') AND SF2.D_E_L_E_T_=' ' ) "
	cQuery += "   JOIN "+oSqlHlp:NoLock("SD2")+" ON ( SD2.D2_FILIAL =SF2.F2_FILIAL        AND SD2.D2_DOC=SF2.F2_DOC   AND SD2.D2_SERIE=SF2.F2_SERIE    AND SD2.D2_COD = SD1.D1_COD AND SD1.D1_ITEMORI = SD2.D2_ITEM AND SD2.D_E_L_E_T_=' ' ) "
	cQuery += "   JOIN "+oSqlHlp:NoLock("SF4")+" ON ( SF4.F4_FILIAL ='"+xFilial("SF4")+"' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_=' ' ) " // OPEMOV = 05 = VENDA
	cQuery += "   JOIN "+oSqlHlp:NoLock("SB1")+" ON ( SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' ) "
	cQuery += "   JOIN "+oSqlHlp:NoLock("VS1")+" ON ( VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_NUMNFI = SD2.D2_DOC AND VS1.VS1_SERNFI = SD2.D2_SERIE AND VS1.D_E_L_E_T_ = ' ' ) "
	cQuery += "   JOIN "+oSqlHlp:NoLock("VS3")+" ON ( VS3.VS3_FILIAL='"+xFilial('VS3')+"' AND VS3.VS3_NUMORC = VS1.VS1_NUMORC AND VS3.VS3_CODITE = SB1.B1_COD AND VS3.VS3_GRUITE = SB1.B1_GRUPO AND VS3.D_E_L_E_T_ = ' ' ) "
	cQuery += "  WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_=' ' "
	cQuery += "    AND D2_COD = '"+cProdut+"' AND D1_COD = D2_COD AND D2_EMISSAO BETWEEN '" + cData1 + "' AND '" + cData2 + "' "
	cQuery += ") as tbl WHERE VS3_CODSIT IN ( SELECT V09_CODSIT from "+oSqlHlp:NoLock('V09')+" WHERE V09.V09_LEVDEM = '1' AND V09.D_E_L_E_T_ = ' ' ) OR VS3_CODSIT = ' ' "
	cFilAnt := cBckFilial
Return FM_SQL(cQuery)

/*/{Protheus.doc} GetQtdCan
	Retorna quantidade cancelada da peça conforme filtro

	@author       Vinicius Gati
	@since        04/09/15
/*/
Method GetQtdCan(cFil, cProdut, cAno, cMes, cDia) Class DMS_DPM
	Local cQuery
	Local cBckFilial := cFilAnt
	Local oSqlHlp    := DMS_SqlHelper():New()
	Local oUtil      := DMS_Util():New()
	Local cData1
	Local cData2     := ""
	Default cDia     := ""

	cData1  := cAno + cMes + cDia
	cFilAnt := cFil

	If Empty(cDia)
		cData2 := DTOS(oUtil:UltimoDia( VAL(cAno), VAL(cMes) ))
		cData1 := LEFT(cData2 , 6) + "01"
	Else
		cData2 := cData1
	EndIf

	cTopQry := " SELECT VS3_CODSIT FROM "+oSqlHlp:NoLock('VS1', 'VS1P')+" JOIN "+oSqlHlp:NoLock('VS3', 'VS3P')+"  ON VS1P.VS1_FILIAL = VS3P.VS3_FILIAL AND VS3P.VS3_NUMORC = VS1P.VS1_NUMORC AND VS3P.VS3_CODITE = SB1.B1_COD AND VS3P.VS3_GRUITE = SB1.B1_GRUPO AND VS3P.D_E_L_E_T_ = ' ' WHERE VS1P.VS1_NUMORC = VS1.VS1_PEDREF "
	cTopQry := oSqlHlp:TOPFunc(cTopQry, 1)

	cQuery := " SELECT COALESCE( SUM(D1_QUANT), 0) as QUANTIDADE from ( "
	// o select pega a quantidade da nota devolvida, porem e necessario averiguar se a mesma entrou na demanda para contabilizar, caso contrario sera considerada e valores negativos podem ocorrer nas contabilizacoes
	cQuery += " SELECT CASE WHEN VS1.VS1_TIPORC = 'P' then VS3_CODSIT else ("+cTopQry+") end as VS3_CODSIT, "
	cQuery += "        SD1.D1_QUANT "
	cQuery += "   FROM "+oSqlHlp:NoLock("SD1")
	cQuery += "   JOIN "+oSqlHlp:NoLock("SF2")+" ON ( SF2.F2_FILIAL =SD1.D1_FILIAL        AND SF2.F2_DOC=SD1.D1_NFORI AND SF2.F2_SERIE=SD1.D1_SERIORI  AND SF2.F2_PREFORI IN ('"+GetNewPar("MV_PREFBAL","BAL")+"','"+GetNewPar("MV_PREFOFI","OFI")+"') AND SF2.D_E_L_E_T_=' ' ) "
	cQuery += "   JOIN "+oSqlHlp:NoLock("SD2")+" ON ( SD2.D2_FILIAL =SF2.F2_FILIAL        AND SD2.D2_DOC=SF2.F2_DOC   AND SD2.D2_SERIE=SF2.F2_SERIE    AND SD2.D2_COD = SD1.D1_COD AND SD1.D1_ITEMORI = SD2.D2_ITEM AND SD2.D_E_L_E_T_=' ' ) "
	cQuery += "   JOIN "+oSqlHlp:NoLock("SF4")+" ON ( SF4.F4_FILIAL ='"+xFilial("SF4")+"' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_=' ' ) " // OPEMOV = 05 = VENDA
	cQuery += "   JOIN "+oSqlHlp:NoLock("SB1")+" ON ( SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' ) "
	cQuery += "   JOIN "+oSqlHlp:NoLock("VS1")+" ON ( VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_NUMNFI = SD2.D2_DOC AND VS1.VS1_SERNFI = SD2.D2_SERIE AND VS1.D_E_L_E_T_ = ' ' ) "
	cQuery += "   JOIN "+oSqlHlp:NoLock("VS3")+" ON ( VS3.VS3_FILIAL='"+xFilial('VS3')+"' AND VS3.VS3_NUMORC = VS1.VS1_NUMORC AND VS3.VS3_CODITE = SB1.B1_COD AND VS3.VS3_GRUITE = SB1.B1_GRUPO AND VS3.D_E_L_E_T_ = ' ' ) "
	cQuery += "  WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_=' ' "
	cQuery += "    AND D2_COD = '"+cProdut+"' AND D1_COD = D2_COD AND D2_EMISSAO BETWEEN '" + cData1 + "' AND '" + cData2 + "' "
	cQuery += ") as tbl WHERE VS3_CODSIT IN ( SELECT V09_CODSIT from "+oSqlHlp:NoLock('V09')+" WHERE V09.V09_LEVDEM = '1' AND V09.D_E_L_E_T_ = ' ' ) OR VS3_CODSIT = ' ' "

	cFilAnt := cBckFilial
Return FM_SQL(cQuery)

/*/{Protheus.doc} GetDevData
	Retorna todos os dados necessários para devolucao no parts data de uma so vez

	@author       Vinicius Gati
	@since        30/10/15
/*/
Method GetDevData(cFil, dData, cB1Cod, nNroAnos, cPrefOris, cInGroups) Class DMS_DPM
	Local aDados       := {}
	Local cQuery       := " "
	Local cBckFilial   := cFilAnt
	Local oSqlHlp      := DMS_SqlHelper():New()
	Local oUtil        := DMS_Util():New()
	Local nIdx         := 1
	Local dData36At
	Default cPrefOris  := "'"+GetNewPar("MV_PREFBAL","BAL")+"','"+GetNewPar("MV_PREFOFI","OFI")+"'"
	Default nNroAnos   := 3
	Default cB1Cod     := ""
	Default dData      := dDatabase
	Default cInGroups  := self:GetInGroups()

	cFilAnt := cFil

	dData36At := dData
	for nIdx := 1 to nNroAnos
		dData36At := oUtil:RemoveMeses(dData36At, 12)
	Next

	PL := chr(13) + chr(10)
	cQuery += " SELECT TMP.*,"
	cQuery +=        " D1_QUANT AS QTD_ITENS,"
	cQuery +=        " CASE"
	cQuery +=        "   WHEN D2_QUANT = D1_QUANT THEN 1"
	cQuery +=        "   ELSE 0"
	cQuery +=        " END QTD_HITS "
	cQuery += " FROM ( "
	cQuery +=        " SELECT DISTINCT SD1.R_E_C_N_O_, SD2.D2_DOC, SD2.D2_SERIE, D2_FILIAL, D2_EMISSAO, D2_COD, D2_QUANT, D1_QUANT"
	cQuery +=        " FROM " + oSqlHlp:Nolock("SD2")
	cQuery +=        "  JOIN " + oSqlHlp:NoLock("SF2")
	cQuery +=                "  ON SF2.F2_FILIAL  = '" + xFilial("SF2") + "'"
	cQuery +=                " AND SF2.F2_DOC     = SD2.D2_DOC "
	cQuery +=                " AND SF2.F2_SERIE   = SD2.D2_SERIE "
	cQuery +=                " AND SF2.F2_PREFORI IN ("+cPrefOris+")"
	cQuery +=                " AND SF2.D_E_L_E_T_ = ' '"
	cQuery +=        "  JOIN " + oSqlHlp:NoLock("SD1")
	cQuery +=                "  ON SD1.D1_FILIAL  = '" + xFilial("SD1") + "'"
	cQuery +=                " AND SD1.D1_NFORI   = SD2.D2_DOC "
	cQuery +=                " AND SD1.D1_SERIORI = SD2.D2_SERIE "
	cQuery +=                " AND SD1.D1_COD     = SD2.D2_COD "
	cQuery +=                " AND SD1.D1_ITEMORI = SD2.D2_ITEM "
	cQuery +=                " AND SD1.D_E_L_E_T_ = ' ' "
	cQuery +=        "  JOIN " + oSqlHlp:NoLock("SB1")
	cQuery +=                "  ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery +=                " AND SB1.B1_COD     = SD2.D2_COD "
	cQuery +=                " AND SB1.D_E_L_E_T_ = ' '"
	cQuery +=        "  JOIN " + oSqlHlp:NoLock("SF4")
	cQuery +=                "  ON SF4.F4_FILIAL  = '" + xFilial("SF4") + "' "
	cQuery +=                " AND SF4.F4_CODIGO  = SD2.D2_TES "
	cQuery +=                " AND SF4.F4_OPEMOV  = '05'"
	cQuery +=                " AND SF4.D_E_L_E_T_ = ' '"
	cQuery +=        "  JOIN " + oSqlHlp:NoLock("SF4", "SF4_SD1")
	cQuery +=                "  ON SF4_SD1.F4_FILIAL  = '" + xFilial("SF4") + "' "
	cQuery +=                " AND SF4_SD1.F4_CODIGO  = SD1.D1_TES "
	cQuery +=                " AND SF4_SD1.F4_OPEMOV  = '09' "
	cQuery +=                " AND SF4_SD1.D_E_L_E_T_ = ' '"
	cQuery +=        " LEFT JOIN " + oSqlHlp:NoLock("VS1")
	cQuery +=                "  ON VS1.VS1_FILIAL = '" + xFilial("VS1") + "' "
	cQuery +=                " AND VS1.VS1_NUMNFI = SD2.D2_DOC "
	cQuery +=                " AND VS1.VS1_SERNFI = SD2.D2_SERIE "
	cQuery +=                " AND VS1_TIPORC     = '1' "
	cQuery +=                " AND VS1.D_E_L_E_T_ = ' '"
	cQuery +=        " LEFT JOIN " + oSqlHlp:NoLock("VS3")
	cQuery +=                "  ON VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
	cQuery +=                " AND VS3.VS3_NUMORC = VS1.VS1_NUMORC "
	cQuery +=                " AND VS3.D_E_L_E_T_ = ' '"
	cQuery += " WHERE  SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
	if ! Empty(cInGroups)
		cQuery += " AND SB1.B1_GRUPO IN " + cInGroups
	endif
	if ! Empty(cB1Cod)
		cQuery += " AND SB1.B1_COD = '"+cB1Cod+"' "
	endif
	cQuery += "    AND D2_EMISSAO BETWEEN '" + DTOS(dData36At-1) + "' AND '" + DTOS(dData+1) + "' "
	cQuery += "    AND (   VS3_CODSIT = ' '"
	cQuery +=         " OR VS3_CODSIT IS NULL"
	cQuery +=         " OR VS3_CODSIT IN ( SELECT V09_CODSIT "
	cQuery +=                              " FROM " + oSqlHlp:NoLock('V09')
	cQuery +=                             " WHERE V09_DEMDPM = '1' "
	cQuery +=                               " AND V09.D_E_L_E_T_ = ' ' ) "
	cQuery +=        " ) "
	cQuery += " ) TMP "
	cQuery += " ORDER BY D2_COD, D2_EMISSAO DESC "
	aDados := oSqlHlp:GetSelect({;
		{'campos', {'D2_DOC','D2_SERIE','D2_FILIAL','D2_EMISSAO','D2_COD','D1_QUANT', 'QTD_HITS','QTD_ITENS'}},;
		{'query' , cQuery} ;
	})

	cFilAnt := cBckFilial
Return aDados

/*/{Protheus.doc} GetImportantMessages
	Retorna quantidade cancelada da peça conforme filtro

	@author       Vinicius Gati
	@since        04/09/15
/*/
Method GetImportantMessages(dData) Class DMS_DPM
	Local cMessages := ""
	lFalha06 := FM_SQL("SELECT COALESCE(COUNT(*),0) FROM "+RetSqlName('VQL')+" WHERE VQL_FILIAL = '"+xFilial('VQL')+"' AND VQL_AGROUP = 'OFINJD06' AND VQL_TIPO = 'LOG_EXECUCAO' AND D_E_L_E_T_ = ' ' AND VQL_DATAI = '"+DTOS(dData-1)+"' AND VQL_DATAF = ' ' ") > 0
	lFalha31 := FM_SQL("SELECT COALESCE(COUNT(*),0) FROM "+RetSqlName('VQL')+" WHERE VQL_FILIAL = '"+xFilial('VQL')+"' AND VQL_AGROUP = 'OFINJD09' AND VQL_TIPO = 'LOG_EXECUCAO' AND D_E_L_E_T_ = ' ' AND VQL_DATAI = '"+DTOS(dData-1)+"' AND VQL_DATAF = ' ' ") > 0
	lFalha09 := FM_SQL("SELECT COALESCE(COUNT(*),0) FROM "+RetSqlName('VQL')+" WHERE VQL_FILIAL = '"+xFilial('VQL')+"' AND VQL_AGROUP = 'OFINJD31' AND VQL_TIPO = 'LOG_EXECUCAO' AND D_E_L_E_T_ = ' ' AND VQL_DATAI = '"+DTOS(dData-1)+"' AND VQL_DATAF = ' ' ") > 0
	If lFalha06 .OR. lFalha31 .OR. lFalha09
		cMessages := STR0007 // "Problemas urgentes requerem atenção do gerenciador do DPM:"
	EndIf
	If lFalha06
		cMessages += chr(13) + chr(10) + STR0008 // "Parts Data não gerado corretamente no dia anterior."
	EndIf
	If lFalha09
		cMessages += chr(13) + chr(10) + STR0010 // "PMM não gerado corretamente no dia anterior."
	EndIf
	If lFalha31
		cMessages += chr(13) + chr(10) + STR0009 // "Processamento Diário não finalizado corretamente no dia anterior."
	EndIf
Return cMessages

/*/{Protheus.doc} Alerted
	Retorna se o usuário já foi alertado sobre problemas no DPM para o usuario logado

	@author       Vinicius Gati
	@since        04/09/15
/*/
Method Alerted(dData) Class DMS_DPM
Return FM_SQL("SELECT COALESCE(COUNT(*),0) FROM "+RetSqlName('VQL')+" WHERE VQL_FILIAL = '"+xFilial('VQL')+"' AND VQL_AGROUP = 'DPM' AND VQL_TIPO = 'ALERTA_1' AND VQL_DADOS = '"+__cUserID+"' AND VQL_DATAI = '"+DTOS(dData)+"' AND D_E_L_E_T_ = ' ' ") > 0

/*/{Protheus.doc} IsProcessed
	Retorna se o usuário já foi alertado sobre problemas no DPM para o usuario logado

	@author       Vinicius Gati
	@since        04/09/15
/*/
Method IsProcessed(dData) Class DMS_DPM
Return FM_SQL("SELECT COALESCE(COUNT(*),0) FROM "+RetSqlName('VQL')+" WHERE VQL_FILIAL = '"+xFilial('VQL')+"' AND VQL_AGROUP = 'OFINJD31' AND VQL_TIPO = 'LOG_EXECUCAO' AND VQL_DATAI = '"+DTOS(dData)+"' AND VQL_DATAF <> ' ' AND D_E_L_E_T_ = ' ' ") > 0

/*/{Protheus.doc} DMS_DataContainer
	Classe de configuracao do DPM contendo dados de filiais e caminho de criacao de arquivos

	@author       Vinicius Gati
	@since        21/08/15

/*/
CLASS DMS_DPMConfig
	Data aFilis
	Data cGrupo
	Data aLogger

	Method New() CONSTRUCTOR
	Method GetPath()
	Method GetFiliais()
	Method GetAccount()
	Method GetHoraProcDiario()
	Method GetHoraDPE()
	Method GetHoraPMM()
	//Method GetPathDPMSCHED() // Método Obsoleto - Alecsandre Ferreira - 02/03/2022
ENDCLASS

/*/{Protheus.doc} New
	Simples construtor

	@author       Vinicius Gati
	@since        21/08/2015

/*/
Method New(cGrupo) CLASS DMS_DPMConfig
	::aLogger := DMS_Logger():New()
	::cGrupo  := cGrupo
	::aFilis  := {}
Return SELF

/*/{Protheus.doc} GetPath
	Retorna o caminho configurado

	@author       Vinicius Gati
	@since        21/08/2015

/*/
Method GetPath()  CLASS DMS_DPMConfig
	Return ALLTRIM(FM_SQL(" SELECT VQL_DADOS FROM " + RetSqlName('VQL') + " WHERE D_E_L_E_T_ = ' ' AND VQL_AGROUP = '" + self:cGrupo + "' AND VQL_TIPO = 'PATH' "))
Return

/*/{Protheus.doc} GetAccount
	Retorna a conta configurada para grupo do dPM

	@author       Vinicius Gati
	@since        31/08/2015

/*/
Method GetAccount()  CLASS DMS_DPMConfig
	return ALLTRIM( FM_SQL(" SELECT VQL_DADOS FROM " + RetSqlName('VQL') + " WHERE D_E_L_E_T_ = ' ' AND VQL_AGROUP = '"+self:cGrupo+"' AND VQL_TIPO = 'CONTA' ") )
Return

/*/{Protheus.doc} New
	Simples construtor

	@author       Vinicius Gati
	@since        21/08/2015

/*/
Method GetFiliais()  CLASS DMS_DPMConfig
	Local oArHlp := DMS_ArrayHelper():New()
	Local oSql   := DMS_SqlHelper():New()
	Local aDados := {}
	Local aRet   := {}

	If Empty(self:aFilis)
		DBSelectArea("SX6")
		DBSetOrder(1) // não tem chave #lento
		DBGoTop()
		while !EOF()
			if ALLTRIM(SX6->X6_VAR) == "MV_MIL0005"
				aAdd(self:aFilis,{SX6->X6_FIL, SX6->X6_CONTEUD, Right(ALLTRIM(SX6->X6_FIL),2)})
			endif
			DBSkip()
		enddo
	EndIf

	aDados := oSql:GetSelect({;
		{'campos', {'VQL_DADOS'}},;
		{'query' , 'SELECT VQL_DADOS FROM ' + RetSqlName('VQL') + " WHERE D_E_L_E_T_ = ' ' AND VQL_AGROUP = '" + self:cGrupo + "' AND VQL_TIPO = 'FILS' "};
	})

	aDados := oArHlp:Map(aDados, {|oEl| ALLTRIM( oEl:GetValue('VQL_DADOS') ) })
	oArHlp:Map(self:aFilis, {|el| IIF( ASCAN(aDados, el[1]) > 0, aAdd(aRet, el), nil ) })
Return aRet

/*/{Protheus.doc} GetHoraProcDiario
	Retorna o valor configurado da hora do processamento diário

	@author       Vinicius Gati
	@since        30/11/2015

/*/
Method GetHoraProcDiario() Class DMS_DPMConfig
Return ALLTRIM( FM_SQL(" SELECT VQL_DADOS FROM " + RetSqlName('VQL') + " WHERE D_E_L_E_T_ = ' ' AND VQL_AGROUP = '"+self:cGrupo+"' AND VQL_TIPO = 'HORA_PRC_DIARIO' ") )

/*/{Protheus.doc} GetHoraDPE
	Retorna o valor configurado da hora de geração do DPE

	@author       Vinicius Gati
	@since        30/11/2015

/*/
Method GetHoraDPE() Class DMS_DPMConfig
Return ALLTRIM( FM_SQL(" SELECT VQL_DADOS FROM " + RetSqlName('VQL') + " WHERE D_E_L_E_T_ = ' ' AND VQL_AGROUP = '"+self:cGrupo+"' AND VQL_TIPO = 'HORA_DPE' ") )

/*/{Protheus.doc} GetHoraPMM
	Retorna o valor configurado da hora que o PMM será gerado

	@author       Vinicius Gati
	@since        30/11/2015

/*/
Method GetHoraPMM() Class DMS_DPMConfig
Return ALLTRIM( FM_SQL(" SELECT VQL_DADOS FROM " + RetSqlName('VQL') + " WHERE D_E_L_E_T_ = ' ' AND VQL_AGROUP = '"+self:cGrupo+"' AND VQL_TIPO = 'HORA_PMM' ") )

/*/{Protheus.doc} GetPathDPMSCHED
	Retorna o valor configurado do local de monitoramento do arquivo DPMSCHED
	@author       Vinicius Gati
	@since        30/11/2015

// Alecsandre Ferreira - 02/03/2022
// Método comentado por ser obsoleto
Method GetPathDPMSCHED() Class DMS_DPMConfig
Return ALLTRIM(FM_SQL(" SELECT VQL_DADOS FROM " + RetSqlName('VQL') + " WHERE D_E_L_E_T_ = ' ' AND VQL_AGROUP = '" + self:cGrupo + "' AND VQL_TIPO = 'PATH_DPMSCHED_F' "))
/*/

/*/{Protheus.doc} DMS_DPMSched
	Classe de controle dos DPMSCHEDS do JDPrism interface
	Terá os dados salvos no VQL

	@author       Vinicius Gati
	@since        26/11/15

/*/
CLASS DMS_DPMSched
	DATA aFileStructure
	DATA cGrupo
	DATA aGeracoes

	Method New() CONSTRUCTOR
	Method GetLast()
	Method WhatToGen()
	Method UpdateGers()
ENDCLASS

/*/{Protheus.doc} New
	Simples construtor

	@author       Vinicius Gati
	@since        26/11/15

/*/
Method New(cGrupo) CLASS DMS_DPMSched
	::aFileStructure := {}
	::aGeracoes      := {}
	::cGrupo         := cGrupo
	aAdd(::aFileStructure, {'C', 2, 'Tipo'           }) // para documentar como é o arquivo, mas não uso por ser simples, fiz direto a logica
	aAdd(::aFileStructure, {'C', 3, 'Dia geração 1'  }) //
	aAdd(::aFileStructure, {'C', 4, 'Hora geração 1' }) //
	aAdd(::aFileStructure, {'C', 3, 'Dia geração 2'  }) //
	aAdd(::aFileStructure, {'C', 4, 'Hora geração 2' }) //
	aAdd(::aFileStructure, {'C', 3, 'Dia geração 3'  }) //
	aAdd(::aFileStructure, {'C', 4, 'Hora geração 3' }) //
	aAdd(::aFileStructure, {'C', 3, 'Dia geração 4'  }) //
	aAdd(::aFileStructure, {'C', 4, 'Hora geração 4' }) //
	aAdd(::aFileStructure, {'C', 3, 'Dia geração 5'  }) //
	aAdd(::aFileStructure, {'C', 4, 'Hora geração 5' }) //
	aAdd(::aFileStructure, {'C', 3, 'Dia geração 6'  }) //
	aAdd(::aFileStructure, {'C', 4, 'Hora geração 6' }) //
	aAdd(::aFileStructure, {'C', 3, 'Dia geração 7'  }) //
	aAdd(::aFileStructure, {'C', 4, 'Hora geração 7' }) //
	aAdd(::aFileStructure, {'C', 3, 'Dia geração 8'  }) //
	aAdd(::aFileStructure, {'C', 4, 'Hora geração 8' }) //
Return SELF

/*/{Protheus.doc} GetAll
	Busca os dpmsched, todos, para remover os deletados passar parametro

	@author       Vinicius Gati
	@since        26/11/15

/*/
Method GetLast(cGrupo) CLASS DMS_DPMSched
	Local oSqlHlp  := DMS_SqlHelper():New()
	Local cQuery   := ""
	Local oDpmSch  := Nil
	cGrupo := Iif(Empty(cGrupo), "SCHEDULER", cGrupo)
	//
	cQuery := " SELECT "
	cQuery += " 	VQL_DADOS "
	cQuery += " FROM "
	cQuery += " 	" + RetSqlName('VQL') + " VQLA "
	cQuery += " WHERE "
	cQuery += " 	VQLA.VQL_AGROUP = '" + cGrupo + "' "
	cQuery += " 	AND VQLA.VQL_TIPO = 'DPMSCHED_FILE' "
	cQuery += " 	AND VQLA.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY "
	cQuery += " 	VQLA.VQL_DATAI DESC, "
	cQuery += " 	VQLA.VQL_DADOS DESC "

	cQuery := oSqlHlp:TopFunc(cQuery, 1)
	aScheds := oSqlHlp:GetSelect({;
		{'campos',{'VQL_DADOS'}},;
		{'query' ,cQuery       } ;
	})
	If LEN(aScheds) > 0
		oDpmSch := aScheds[1]
	EndIf
Return oDpmSch

/*/{Protheus.doc} WhatToGen
	Busca os dpmsched, todos, para remover os deletados passar parametro

	@author       Vinicius Gati
	@since        02/12/15

/*/
Method WhatToGen(cHour1, cHour2) Class DMS_DPMSched
	Local aGerar  := {}
//	Local cAl     := GetNextAlias()
	Local oSqlHlp := DMS_SqlHelper():New()
	Local cQuery  := ""
	Local nIdx    := 1

	cHour1 := STRTRAN(cHour1, ':', '')
	cHour2 := STRTRAN(cHour2, ':', '')
	self:updateGers()
	for nIdx := 1 to LEN(self:aGeracoes)
		oGeracao := self:aGeracoes[nIdx]
		cQuery   := " SELECT COUNT(*) FROM " + oSqlHlp:NoLock('SBM') + " WHERE '" + oGeracao:GetTime() + "' BETWEEN '"+cHour1+"' AND '"+cHour2+"' "
		if FM_SQL(cQuery) > 0
			AADD(aGerar, oGeracao)
		EndIf
	Next
Return aGerar

/*/{Protheus.doc} UpdateGers
	Busca os dpmsched, todos, para remover os deletados passar parametro

	@author       Vinicius Gati
	@since        02/12/15

/*/
Method UpdateGers(lNovo) Class DMS_DPMSched
	oArq   := self:GetLast(self:cGrupo)
	If Empty(oArq)
		Return
	EndIf
	aDados := STRTOKARR( oArq:GetValue('VQL_DADOS'), CHR(09) /* tab */ )

	if lNovo
		cTipo  := aDados[1]
		if UPPER(cTipo) == "I"
			// logar uma geracao de init no vql pois a primeira geração pode ser init mas deve ser convertida em D a partir dela
			oLogger:LogToTable({; // salva arquivo já importado para não fazer 2 vezes pro mesmo grupo
				{'VQL_AGROUP' , self:cGrupo         },;
				{'VQL_TIPO'   , 'SCHED_I'           },;
				{'VQL_DADOS'  , "DEVE GERAR 1 INIT" } ;
			})
		EndIf
	Endif

	If LEN(aDados) >= 3
		aAdd( self:aGeracoes , DMS_Geracao():New("D", "DPE", ALLTRIM(aDados[02]) , ALLTRIM(aDados[03])) )
	EndIf
	If LEN(aDados) >= 5
		aAdd( self:aGeracoes , DMS_Geracao():New("D", "DPE", ALLTRIM(aDados[04]) , ALLTRIM(aDados[05])) )
	EndIf
	If LEN(aDados) >= 7
		aAdd( self:aGeracoes , DMS_Geracao():New("D", "DPE", ALLTRIM(aDados[06]) , ALLTRIM(aDados[07])) )
	EndIf
	If LEN(aDados) >= 9
		aAdd( self:aGeracoes , DMS_Geracao():New("D", "DPE", ALLTRIM(aDados[08]) , ALLTRIM(aDados[09])) )
	EndIf
	If LEN(aDados) >= 11
		aAdd( self:aGeracoes , DMS_Geracao():New("D", "DPE", ALLTRIM(aDados[10]) , ALLTRIM(aDados[11])) )
	EndIf
	If LEN(aDados) >= 13
		aAdd( self:aGeracoes , DMS_Geracao():New("D", "DPE", ALLTRIM(aDados[12]) , ALLTRIM(aDados[13])) )
	EndIf
	If LEN(aDados) >= 15
		aAdd( self:aGeracoes , DMS_Geracao():New("D", "DPE", ALLTRIM(aDados[14]) , ALLTRIM(aDados[15])) )
	EndIf
	If LEN(aDados) >= 17
		aAdd( self:aGeracoes , DMS_Geracao():New("D", "DPE", ALLTRIM(aDados[16]) , ALLTRIM(aDados[17])) )
	EndIf
Return .T.


/*/{Protheus.doc} DMS_DPMXFers
	Classe de controle dos DPMXFERS do JDPrism interface
	Terá os dados salvos no VQL

	@author       Vinicius Gati
	@since        26/11/15

/*/
CLASS DMS_DPMXFers
	Data aHeaderStructure
	DATA aFileStructure
	Data aXFers
	Data oHeader
	Data cFileName
	Data lOk
	Data cGrupo

	Method New() CONSTRUCTOR
	Method Efetivar()
	Method GetValue()
	Method GetHeaderValue()
	Method Persist()
	Method AllOk()
ENDCLASS

/*/{Protheus.doc} New
	Simples construtor

	@author       Vinicius Gati
	@since        26/11/15

/*/
Method New(cPath, cFilePath, cGrupo) CLASS DMS_DPMXFers
	Local lHeader := .T.

	::aXFers := {}
	::cFileName := cFilePath
	cFullFilePath := cPath + ALLTRIM(" \ ") + cFilePath
	::cGrupo := cGrupo

	::aHeaderStructure := {}
	aAdd(::aHeaderStructure , {'CODIGO'           , 'C', 06, 00, 'File Header ID' })
	aAdd(::aHeaderStructure , {'CODIGO_DPE'       , 'I', 00, 00, 'Transfer Coordination/Id unico do arquivo usado no parts data para avisar que foi importado'  })

	::aFileStructure   := {}
	aAdd(::aFileStructure   , {'B1_COD'           , 'C', 18, 00, 'PartNumber/B1_COD' })
	aAdd(::aFileStructure   , {'QUANTIDADE'       , 'C', 06, 02, 'Quantidade to xfer'  })
	aAdd(::aFileStructure   , {'DATA_CRIACAO'     , 'C', 10, 00, 'Data criacao do xfer (so informativo)' })
	aAdd(::aFileStructure   , {'HORA_CRIACAO'     , 'C', 08, 00, 'Hora criacao do xfer (so informativo)'  })
	aAdd(::aFileStructure   , {'FILIAL_ORIGEM'    , 'C', 06, 00, 'From dealer account/filial que vai transferir' })
	aAdd(::aFileStructure   , {'FILIAL_ORIGEM_2'  , 'C', 10, 00, 'From wharehouse/ filial em formato protheus(nao usado)'  })
	aAdd(::aFileStructure   , {'FILIAL_DESTINO'   , 'C', 06, 00, 'To dealer account/filial que vai receber' })
	aAdd(::aFileStructure   , {'FILIAL_DESTINO_2' , 'C', 10, 00, 'To wharehouse/filial em formato protheus(nao usado)'  })

	FT_FUse( cFullFilePath )
	While !FT_FEof()
		If lHeader
			// Header 1 linha
			cLinha := FT_FReadLN()
			::oHeader := DMS_JdFileInterpreter():New(cLinha, ::aHeaderStructure)
			FT_FSkip()
			lHeader := .F.
		Else
			// Xfers N linhas
			cLinha := FT_FReadLN()
			aAdd(::aXFers, DMS_JdFileInterpreter():New(cLinha, ::aFileStructure))
			FT_FSkip()
		EndIf
	EndDo
	FT_FUse()
	::lOk := .T.
Return SELF

/*/{Protheus.doc} Efetivar
	Criará VS1->N->VS3 de tranferência e efetivar a transferencia conforme dados do arquivo.

	@author  Vinicius Gati
	@since   22/12/2015
/*/
Method Efetivar(lDebug) Class DMS_DPMXFers
	Local aArrHlp   := DMS_ArrayHelper():New()
	Local oDpm      := DMS_DPM():New()
	Local oLogger   := DMS_Logger():New()
	Local nIdx      := 1
	Local nEx       := 1
	Local nMaxItems := GetNewPar("MV_NUMITEN",499)
	Local cOri      := ""
	Local cDest     := ""
	Local cArmDes   := ""
	Local aItens    := {}
	Local cDpeVql   := ""
	Local nTotal    := 0

	for nIdx := 1 to Len(self:aXFers)
		oXFer := self:aXFers[nIdx]
		SB1->(dbSetOrder(1))
		SB1->(dbSeek( xFilial('SB1') + oXFer:GetValue('B1_COD') ))
		if !Empty(SB1->B1_LOCPAD)
			oXFer:SetValue('ARMAZEM_ORIGEM', SB1->B1_LOCPAD)
			oXFer:SetValue('ARMAZEM_DESTINO', SB1->B1_LOCPAD)
		Else
			oXFer:SetValue('ARMAZEM_ORIGEM', '01')
			oXFer:SetValue('ARMAZEM_DESTINO', '01')
		End
		oXFer:SetValue('ARMAZEM_ORIGEM', SB1->B1_LOCPAD)
		oXFer:SetValue('ARMAZEM_DESTINO', SB1->B1_LOCPAD)
	next

	aSrtXfers := aSort( self:aXFers,,, {|x,y| x:GetValue('FILIAL_ORIGEM')+x:GetValue('FILIAL_DESTINO')+x:GetValue('ARMAZEM_DESTINO')+x:GetValue('B1_COD') ;
																					< y:GetValue('FILIAL_ORIGEM')+y:GetValue('FILIAL_DESTINO')+y:GetValue('ARMAZEM_DESTINO')+y:GetValue('B1_COD') } )
	BEGIN TRANSACTION
		for nIdx := 1 to Len(aSrtXfers)
			oXFer := aSrtXfers[nIdx]

			conout(STR0013/*"Conferindo item para transferencia"*/)
			If Empty(cOri)
				cOri    := oDpm:GetFilial( oXFer:GetValue('FILIAL_ORIGEM') ) // o get filial é pra converter do codigo da jd para filial do protheus
				cDest   := oDpm:GetFilial( oXFer:GetValue('FILIAL_DESTINO') )
				cArmDes := oXFer:GetValue('ARMAZEM_DESTINO')
			ElseIf cOri    != oDpm:GetFilial( oXFer:GetValue('FILIAL_ORIGEM'))  .OR.; // funciona como uma chave, pois não tem como ter 1 só orçamento com diversos destinos entao filiais e armazem são unicos
						 cDest   != oDpm:GetFilial( oXFer:GetValue('FILIAL_DESTINO')) .OR.;
						 cArmDes != oXFer:GetValue('ARMAZEM_DESTINO') .OR.;
						 LEN(aItens) == nMaxItems
				oTrf    := DMS_Transferencia():New(cOri, cDest, cArmDes, @aItens)
				if ! oTrf:Efetivar(self:cFileName)
					conout(STR0012/*"Ocorreu um erro na importação do arquivo"*/ + "jdprism_syserr_tranfer.log")
					oLogger:LogSysErr("jdprism_syserr_tranfer.log")
					disarmTransaction()
					return .F.
				EndIf
				cOri    := oDpm:GetFilial( oXFer:GetValue('FILIAL_ORIGEM') )
				cDest   := oDpm:GetFilial( oXFer:GetValue('FILIAL_DESTINO') )
				cArmDes := oXFer:GetValue('ARMAZEM_DESTINO')
				aItens  := {}
			EndIf

			AADD(aItens, @oXfer)

		next
		if LEN(aItens) > 0
			oTrf := DMS_Transferencia():New(cOri, cDest, cArmDes, @aItens)
			if ! oTrf:Efetivar(self:cFileName)
				disarmTransaction()
				conout(STR0012/*"Ocorreu um erro na importação do arquivo"*/+ "jdprism_syserr_tranfer.log")
				oLogger:LogSysErr("jdprism_syserr_tranfer.log")

				return .F.
			EndIf
		EndIf
		//
		// Não remover, usado na geração do parts data
		//
		oLogger:LogToTable({;
			{'VQL_AGROUP'     , 'DPMXFER_DPE'                       },;
			{'VQL_TIPO'       , 'CODIGO_DPE'                        },;
			{'VQL_DADOS'      , self:oHeader:GetValue('CODIGO_DPE') } ;
		})
		//
		oLogger:LogToTable({; // salva arquivo já importado para não fazer 2 vezes pro mesmo grupo
			{'VQL_AGROUP' , self:cGrupo    },;
			{'VQL_TIPO'   , 'DPMXFER_IMP'  },;
			{'VQL_DADOS'  , self:cFileName } ;
		})
		self:Persist()
	END TRANSACTION
Return .T.

/*/{Protheus.doc} GetValue
	Pega o valor relacionado ao label

	@author  Vinicius Gati
	@since   21/12/2015
	@param   cLabel  , Array, Busca o valor dentro dos dados contidos no obj de acordo como label
	@param   bBlock  , Bloco, String usada no join
	@param   cRetPad , AnyType,   Caso não encontre valor será retornado esse parametro
/*/
METHOD GetValue(cLabel, cRetPad) Class DMS_DPMXFers
	self:oData:GetValue(cLabel, cRetPad)
Return value

/*/{Protheus.doc} GetHeaderValue
	Pega o valor relacionado ao label

	@author  Vinicius Gati
	@since   21/12/2015
	@param   cLabel  , Array, Busca o valor dentro dos dados contidos no obj de acordo como label
	@param   bBlock  , Bloco, String usada no join
	@param   cRetPad , AnyType,   Caso não encontre valor será retornado esse parametro
/*/
METHOD GetHeaderValue(cLabel, cRetPad) Class DMS_DPMXFers
	self:oHeader:GetValue(cLabel, cRetPad)
Return value

/*/{Protheus.doc} GetValue
	Gravação do arquivo no banco de dados a pedido de evandro

	@author  Vinicius Gati
	@since   23/12/2015
/*/
METHOD Persist() Class DMS_DPMXFers
	Local oXfer
	Local nIdx

	chkfile('VQZ')
	dbSelectArea('VQZ')
	reclock('VQZ', .T.)
	VQZ->VQZ_FILIAL := xFilial('VQZ')
	VQZ->VQZ_CODIGO := GetSxeNum("VQZ", 'VQZ_CODIGO')
	VQZ->VQZ_NOMARQ := RIGHT(ALLTRIM(self:cFileName), 150)
	VQZ->VQZ_TIPO   := 'T'
	if VQZ->(FieldPos('VQZ_DATA')) > 0
		VQZ->VQZ_DATA   := dDataBase
		VQZ->VQZ_HORA   := TIME()
		VQZ->VQZ_COONUM := self:oHeader:GetValue("CODIGO_DPE")
	end
	VQZ->(MSUNLOCK())
	ConfirmSx8()

	For nIdx := 1 To Len(self:aXFers)
		oXfer := self:aXFers[nIdx]
		dbSelectArea('VR1')
		reclock('VR1', .T.)
		VR1->VR1_FILIAL := xFilial('VR1')
		VR1->VR1_CODIGO := GetSxeNum("VR1", 'VR1_CODIGO')
		VR1->VR1_PRODUT := oXfer:GetValue('B1_COD')
		VR1->VR1_QUANT  := VAL(oXfer:GetValue('QUANTIDADE'))
		VR1->VR1_FILORI := oXfer:GetValue('FILIAL_ORIGEM')
		VR1->VR1_ARMORI := oXfer:GetValue('ARMAZEM_ORIGEM')
		VR1->VR1_FILDES := oXfer:GetValue('FILIAL_DESTINO')
		VR1->VR1_ARMDES := oXfer:GetValue('ARMAZEM_DESTINO')
		if VR1->(FieldPos('VR1_NUMORC')) > 0
			VR1->VR1_CODVQZ := VQZ->VQZ_CODIGO
			VR1->VR1_NUMORC := oXfer:GetValue('NUMERO_ORCAMENTO')
		EndIf
		VR1->(MSUNLOCK())
		ConfirmSx8()
	Next

Return .T.

/*/{Protheus.doc} AllOk
	Retorna se importou todo o arquivo sem erros

	@author  Vinicius Gati
	@since   21/12/2015
/*/
Method AllOk() Class DMS_DPMXFers
return self:lOk


/*/{Protheus.doc} DMS_DPMOrders
	Classe de controle dos DPMOrders do JDPrism interface
	Terá os dados salvos no VQL

	@author       Vinicius Gati
	@since        23/12/2015

/*/
CLASS DMS_DPMOrders
	Data aHeaderStructure
	DATA aFileStructure
	Data aOrders
	Data oHeader
	Data lOk
	Data cFilePath
	Data cGrupo

	Method New() CONSTRUCTOR
	Method Efetivar()
	Method GetValue()
	Method GetHeaderValue()
	Method Persist()
	Method AllOk()
ENDCLASS

/*/{Protheus.doc} New
	Simples construtor

	@author       Vinicius Gati
	@since        23/12/15

/*/
Method New(cPath, cFilePath, cGrupo) CLASS DMS_DPMOrders
	Local lHeader := .T.

	::aOrders         := {}
	::aHeaderStructure:= {}
	::aFileStructure  := {}
	cFullFilePath     :=  cPath + ALLTRIM(" \ ") + cFilePath
	::cFilePath       := cFilePath
	::cGrupo  := cGrupo

	aAdd(::aHeaderStructure , {'CODIGO'              , 'C', 06, 00, 'File Header ID' })
	aAdd(::aHeaderStructure , {'CODIGO_DPE'          , 'C', 00, 00, 'Unique file identifier exchanged for data verification. The DBS should always retain the most recently downloaded Order Coordination value and return it in the header records of the next extract/upload.  Deere will then assume that all earlier order files were received, and that the DBS processed them in order.' })

	aAdd(::aFileStructure , {'FILIAL_DESTINO'        , 'C', 06, 00, 'Dealer Account' })
	aAdd(::aFileStructure , {'ARMAZEM_DESTINO'       , 'C', 10, 02, 'DBS Warehouse/Franchise'  })
	aAdd(::aFileStructure , {'ATIVIDADE'             , 'C', 10, 00, 'Order Activity  “O” = Ordered (for Deere parts only) “S” = Suggested' })
	aAdd(::aFileStructure , {'DATA'                  , 'C', 10, 00, 'Data criacao do xfer (so informativo)' })
	aAdd(::aFileStructure , {'HORA'                  , 'C', 08, 00, 'Hora criacao do xfer (so informativo)'  })
	aAdd(::aFileStructure , {'TIPO'                  , 'C', 03, 00, 'Order Type => “MD” = Machine Down (next day delivery) “MDP” = Machine Down Plus (ordered after cutoff / next day delivery) “SO” = Stock Order “ST” = Special Terms (Deere-sourced) “TS” = Special terms (Vendor-sourced) “IS” = Initial Stock Order ' })
	aAdd(::aFileStructure , {'FONTE'                 , 'C', 08, 00, '1 = JDPrism Stock Replenishment 2 = Other' })
	aAdd(::aFileStructure , {'C7_DLINORI'            , 'C', 17, 00, 'Original Order Line ID ' })
	aAdd(::aFileStructure , {'B1_COD'                , 'C', 18, 00, 'Part Number' })
	aAdd(::aFileStructure , {'QUANTIDADE'            , 'C', 06, 00, 'Order Quantity' })
	aAdd(::aFileStructure , {'C7_PEDFAB'             , 'C', 10, 00, 'Order Reference ID ' })
	aAdd(::aFileStructure , {'NUMERO_PROGRAMA'       , 'C', 10, 00, 'Special Term Program Number' })
	aAdd(::aFileStructure , {'DATA_ENVIO_SOLICITADO' , 'C', 10, 00, 'Requested Ship Date' })
	aAdd(::aFileStructure , {'TIPO_ATIVIDADE'        , 'C', 01, 00, 'Line Activity=>“A” = Added (new )order line “C” = Changed order line “D” = Deleted order line' })

	FT_FUse( cFullFilePath )
	While !FT_FEof()
		If lHeader
			cLinha := FT_FReadLN()
			::oHeader := DMS_JdFileInterpreter():New(cLinha, ::aHeaderStructure)
			FT_FSkip()
			lHeader := .F.
		Else
			// Xfers N linhas
			cLinha := FT_FReadLN()
			aAdd(::aOrders, DMS_JdFileInterpreter():New(cLinha, ::aFileStructure))
			FT_FSkip()
		EndIf
	EndDo
	FT_FUse()
	::lOk := .T.
Return SELF

/*/{Protheus.doc} Efetivar
	Criará VS1->N->VS3 de tranferência e efetivar a transferencia conforme dados do arquivo.

	@author  Vinicius Gati
	@since   23/12/2015
/*/
Method Efetivar(lDebug) Class DMS_DPMOrders
	Local nIdx      := 1
	Local cPedido   := ""
	Local cArmDes   := ""
	Local cOri      := ""
	Local cPedFab   := ""
	Local aItens    := {}
	Local oDpm      := DMS_DPM():New()
	Local oLogger   := DMS_Logger():New()
	Local cDpeVql   := ""
	cFilBck := cFilAnt

	for nIdx := 1 to Len(self:aOrders)
		oOrder := self:aOrders[nIdx]
		SB1->(dbSetOrder(1))
		SB1->(dbSeek( xFilial('SB1') + oOrder:GetValue('B1_COD') ))
		if !Empty(SB1->B1_LOCPAD)
			oOrder:SetValue('ARMAZEM_ORIGEM', SB1->B1_LOCPAD)
			oOrder:SetValue('ARMAZEM_DESTINO', SB1->B1_LOCPAD)
		Else
			oOrder:SetValue('ARMAZEM_ORIGEM', '01')
			oOrder:SetValue('ARMAZEM_DESTINO', '01')
		End
	next

	aSrtOrders := aSort( self:aOrders,,, {|x,y| x:GetValue('FILIAL_DESTINO')+x:GetValue('ARMAZEM_DESTINO')+x:GetValue('C7_PEDFAB')+x:GetValue('B1_COD') ;
																						< y:GetValue('FILIAL_DESTINO')+y:GetValue('ARMAZEM_DESTINO')+y:GetValue('C7_PEDFAB')+y:GetValue('B1_COD') } )

	BEGIN TRANSACTION
		for nIdx := 1 to Len(aSrtOrders)
			oOrder := aSrtOrders[nIdx]

			if ALLTRIM( oOrder:GetValue("ATIVIDADE") ) == "S"
				oLogger:LogToTable({;
					{'VQL_AGROUP'     , 'DPMORD_DPE' },;
					{'VQL_TIPO'       , 'WARNING'    },;
					{'VQL_DADOS'      , STR0011 /*"Sugestão detectada, importar manualmente(não JDPRISM)"*/ } ;
				})
				LOOP
			EndIf

			If oOrder:GetValue('TIPO_ATIVIDADE') == 'A' // A=>Added (novo)
				If Empty(cOri)
					cOri    := oDpm:GetFilial(oOrder:GetValue('FILIAL_DESTINO')) // o get filial é pra converter do codigo da jd para filial do protheus
					cArmDes := oOrder:GetValue('ARMAZEM_DESTINO')
					cPedFab := oOrder:GetValue('C7_PEDFAB')
				ElseIf cOri    != oDpm:GetFilial(oOrder:GetValue('FILIAL_DESTINO'))  .OR.; // funciona como uma chave, pois não tem como ter 1 só orçamento com diversos destinos entao filiais e armazem são unicos
				       cArmDes != oOrder:GetValue('ARMAZEM_DESTINO') .OR.;
				       cPedFab != oOrder:GetValue('C7_PEDFAB')
				    oPedido := DMS_Pedido():New(cOri, cArmDes, @aItens)
					if ! oPedido:Efetivar(self:cFilePath)
						conout(STR0012/*"Ocorreu um erro na importação do arquivo"*/ + "jdprism_syserr_order.log")
						disarmTransaction()
						oLogger:LogSysErr("jdprism_syserr_order.log")
						return .F.
					Endif
					cOri    := oDpm:GetFilial( oOrder:GetValue('FILIAL_DESTINO') )
					cArmDes := oOrder:GetValue('ARMAZEM_DESTINO')
					cPedFab := oOrder:GetValue('C7_PEDFAB')
					aItens  := {}
				EndIf
				//
				AADD(aItens, @oOrder)
			ElseIf oOrder:GetValue('TIPO_ATIVIDADE') == 'C' // C=>Changed
				cFilAnt := oDpm:GetFilial( oOrder:GetValue('FILIAL_DESTINO') )
				TCSqlExec(" UPDATE "+RetSqlName('SC7')+" SET C7_DDATALT = '"+DTOS(dDataBase)+"', C7_QUANT = "+oOrder:GetValue('QUANTIDADE')+" WHERE C7_FILIAL = '"+xFilial('SC7')+"' AND C7_PRODUTO = '"+oOrder:GetValue('B1_COD')+"' AND C7_PEDFAB = '"+oOrder:GetValue('C7_PEDFAB')+"' AND C7_DLINORI = '"+oOrder:GetValue('C7_DLINORI')+"' AND D_E_L_E_T_ = ' ' ")
				// grava log do arquivo que alterou este registro
				oLogger:LogToTable({;
					{'VQL_AGROUP'     , 'JDPRISM_DPMORD'                    },;
					{'VQL_TIPO'       , 'DPMORD_C'                          },;
					{'VQL_DADOS'      , self:oHeader:GetValue('CODIGO_DPE') } ;
				})
				cFilAnt := cFilBck
			ElseIf oOrder:GetValue('TIPO_ATIVIDADE') == 'D' // excluir item do pedido
				cFilAnt := oDpm:GetFilial( oOrder:GetValue('FILIAL_DESTINO') )
				TCSqlExec(" UPDATE "+RetSqlName('SC7')+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE C7_FILIAL = '"+xFilial('SC7')+"' AND C7_PRODUTO = '"+oOrder:GetValue('B1_COD')+"' AND C7_OREFID = '"+oOrder:GetValue('C7_PEDFAB')+"' AND C7_DLINORI = '"+oOrder:GetValue('C7_DLINORI')+"' AND D_E_L_E_T_ = ' ' ")
				// grava log do arquivo que alterou este registro
				oLogger:LogToTable({;
					{'VQL_AGROUP'     , 'JDPRISM_DPMORD'                    },;
					{'VQL_TIPO'       , 'DPMORD_D'                          },;
					{'VQL_DADOS'      , 'B1_COD: ' + oOrder:GetValue('B1_COD') + " LinhaOri: " + oOrder:GetValue('C7_DLINORI') + " DPMORD: " + self:oHeader:GetValue('CODIGO_DPE') } ;
				})
				cFilAnt := cFilBck
			EndIf
		next
		if LEN(aItens) > 0
			oPedido := DMS_Pedido():New(cOri, cArmDes, @aItens)
			If ! oPedido:Efetivar(self:cFilePath)
				conout(STR0012/*"Ocorreu um erro na importação do arquivo"*/ + "jdprism_syserr_order.log")
				disarmTransaction()
				oLogger:LogSysErr("jdprism_syserr_order.log")
				return .F.
			EndIf
		EndIf
	END TRANSACTION

	// Não remover, usado na geração do parts data
	oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'DPMORD_DPE'                        },;
		{'VQL_TIPO'       , 'CODIGO_DPE'                        },;
		{'VQL_DADOS'      , self:oHeader:GetValue('CODIGO_DPE') } ;
	})
	//
	oLogger:LogToTable({; // salva arquivo já importado para não fazer 2 vezes pro mesmo grupo
		{'VQL_AGROUP' ,  self:cGrupo   },;
		{'VQL_TIPO'   , 'DPMORD_IMP'   },;
		{'VQL_DADOS'  , self:cFilePath } ;
	})
	self:Persist()
	//
Return .T.

/*/{Protheus.doc} GetValue
	Gravação do arquivo no banco de dados a pedido de evandro

	@author  Vinicius Gati
	@since   23/12/2015
/*/
METHOD Persist() Class DMS_DPMOrders
	Local oOrder
	Local nIdx

	BEGIN TRANSACTION

	chkfile('VQZ')
	dbSelectArea('VQZ')
	reclock('VQZ', .T.)
	VQZ->VQZ_FILIAL := xFilial('VQZ')
	VQZ->VQZ_CODIGO := GetSxeNum("VQZ", 'VQZ_CODIGO')
	VQZ->VQZ_NOMARQ := RIGHT(ALLTRIM(self:cFilePath), 150)
	VQZ->VQZ_TIPO   := 'O'
	if VQZ->(FieldPos('VQZ_DATA')) > 0
		VQZ->VQZ_DATA   := dDataBase
		VQZ->VQZ_HORA   := TIME()
		VQZ->VQZ_COONUM := self:oHeader:GetValue("CODIGO_DPE")
	end
	VQZ->(MSUNLOCK())
	ConfirmSx8()

	For nIdx := 1 To Len(self:aOrders)
		oOrder := self:aOrders[nIdx]
		dbSelectArea('VR0')
		reclock('VR0', .T.)
		VR0->VR0_FILIAL := xFilial('VR0')
		VR0->VR0_CODIGO := GetSxeNum("VR0", 'VR0_CODIGO')
		VR0->VR0_FILDES := oOrder:GetValue('FILIAL_DESTINO')
		VR0->VR0_ARMDES := oOrder:GetValue('ARMAZEM_DESTINO')
		VR0->VR0_TIPORD := oOrder:GetValue('ATIVIDADE')
		VR0->VR0_CLASSF := oOrder:GetValue('TIPO')
		VR0->VR0_FONTE  := oOrder:GetValue('FONTE')
		VR0->VR0_ORIGID := oOrder:GetValue('C7_DLINORI')
		VR0->VR0_PRODUT := oOrder:GetValue('B1_COD')
		VR0->VR0_QUANT  := VAL(oOrder:GetValue('QUANTIDADE'))
		VR0->VR0_ORDREF := oOrder:GetValue('C7_PEDFAB')
		VR0->VR0_SPCPRG := oOrder:GetValue('NUMERO_PROGRAMA')
		VR0->VR0_SHIPDT := oOrder:GetValue('DATA_ENVIO_SOLICITADO')
		VR0->VR0_ACAO   := oOrder:GetValue('TIPO_ATIVIDADE')
		if VR0->(FieldPos('VR0_NUMPED')) > 0
			VR0->VR0_CODVQZ:= VQZ->VQZ_CODIGO
			VR0->VR0_NUMPED:= oOrder:GetValue('NUMERO_PEDIDO')
		EndIf
		VR0->(MSUNLOCK())
		ConfirmSx8()
	Next

	END TRANSACTION

Return .T.

/*/{Protheus.doc} GetValue
	Pega o valor relacionado ao label

	@author  Vinicius Gati
	@since   23/12/2015
	@param   cLabel  , Array, Busca o valor dentro dos dados contidos no obj de acordo como label
	@param   bBlock  , Bloco, String usada no join
	@param   cRetPad , AnyType,   Caso não encontre valor será retornado esse parametro
/*/
METHOD GetValue(cLabel, cRetPad) Class DMS_DPMOrders
	self:oData:GetValue(cLabel, cRetPad)
Return value

/*/{Protheus.doc} GetHeaderValue
	Pega o valor relacionado ao label

	@author  Vinicius Gati
	@since   23/12/2015
	@param   cLabel  , Array, Busca o valor dentro dos dados contidos no obj de acordo como label
	@param   bBlock  , Bloco, String usada no join
	@param   cRetPad , AnyType,   Caso não encontre valor será retornado esse parametro
/*/
METHOD GetHeaderValue(cLabel, cRetPad) Class DMS_DPMOrders
	self:oHeader:GetValue(cLabel, cRetPad)
Return value

/*/{Protheus.doc} AllOk
	Retorna se importou todo o arquivo sem erros

	@author  Vinicius Gati
	@since   23/12/2015
/*/
Method AllOk() Class DMS_DPMOrders
return self:lOk

/*/{Protheus.doc} DMS_DPMDPE_1_3
	Classe de controle dos DPMOrders do JDPrism interface
	Terá os dados salvos no VQL

	@author       Vinicius Gati
	@since        30/12/2015

/*/
CLASS DMS_DPMDPE_1_3
	DATA aHeader
	DATA aHeader2
	DATA aInicio
	DATA aMeio
	DATA aFim

	Method New() CONSTRUCTOR
	Method StartArq()
	Method IncHead()
	Method IncWhHead()
	Method IncLine()
	Method EndArq()
	Method isPrism()
	Method canGenDelta()
ENDCLASS

/*/{Protheus.doc} New
	Simples construtor

	@author       Vinicius Gati
	@since        30/12/15

/*/
Method New() CLASS DMS_DPMDPE_1_3
//	Local lHeader := .T.

	::aHeader  := {}
	::aHeader2 := {}
	::aInicio  := {}
	::aMeio    := {}
	::aFim     := {}

	aAdd(::aHeader , {001 , 'C', 08, 00, 'Record Code' })
	aAdd(::aHeader , {002 , 'C', 10, 00, 'Date of extract ' })
	aAdd(::aHeader , {003 , 'C', 08, 00, 'Time of extract' })
	aAdd(::aHeader , {004 , 'C', 10, 00, 'type of extract' })
	aAdd(::aHeader , {005 , 'C', 08, 00, 'interface version' })
	aAdd(::aHeader , {006 , 'C', 10, 00, 'dbs name' })
	aAdd(::aHeader , {007 , 'C', 08, 00, 'dbs version' })
	aAdd(::aHeader , {008 , 'C', 10, 00, 'ultimo order importado' })
	aAdd(::aHeader , {009 , 'C', 10, 00, 'ultimo xfer  importado' })
	aAdd(::aHeader , {010 , 'C', 10, 00, 'orders e xfers importados separados por ","  ' })

	aAdd(::aHeader2 , {001, 'C', 03, 00, '~H~'})
	aAdd(::aHeader2 , {002, 'C', 06, 00, 'Account Number'})
	aAdd(::aHeader2 , {003, 'C', 10, 00, 'DBS Warehouse/Franchise'})
	aAdd(::aHeader2 , {004, 'C', 02, 00, 'Fiscal Month'})
	aAdd(::aHeader2 , {005, 'C', 10, 00, 'Next parts month-end date ?!?!??!?!'})
	aAdd(::aHeader2 , {006, 'C', 01, 00, 'Warehouse / franchise type 1 = Deere Parts 2 = Non-Deere Parts '})
	aAdd(::aHeader2 , {007, 'C', 01, 00, 'Where data is to be loaded 1 = Parts Locator (JDParts, Dealer Locator, D2D) ONLY 2 = JDPoint Order Replenishment (JDPrism) ONLY 3 = Parts Locator AND JDPoint Order Replenishment'})

	aAdd(::aInicio , {001 , 'C', 06, 00, '~P~'})
	aAdd(::aInicio , {002 , 'C', 06, 00, 'Part Number <sem espaços>'})
	aAdd(::aInicio , {003 , 'C', 06, 00, 'Estoque'})
	aAdd(::aInicio , {004 , 'C', 06, 00, 'Em pedido'})
	aAdd(::aInicio , {005 , 'C', 06, 00, 'Qtd Reservada Oficina'})
	aAdd(::aInicio , {006 , 'C', 06, 00, 'Qtd Reservada Orçamentos'})
	aAdd(::aInicio , {007 , 'C', 06, 00, 'Qtd Vendas'})
	aAdd(::aInicio , {008 , 'C', 06, 00, 'Qtd Hits'})
	aAdd(::aInicio , {009 , 'C', 06, 00, 'Qtd Vendas Perdidas'})
	aAdd(::aInicio , {010 , 'C', 06, 00, 'Qtd Hits Perdidos'})
	aAdd(::aInicio , {011 , 'C', 06, 00, 'Parts per package unidade de medida?'})
	aAdd(::aInicio , {012 , 'C', 06, 00, 'Armazem local'})
	aAdd(::aInicio , {013 , 'C', 06, 00, 'Armazem alternativo'})
	aAdd(::aInicio , {014 , 'C', 06, 00, 'Valor da peças - For non-Deere parts only(ver ofinjd06)'})
	aAdd(::aInicio , {015 , 'C', 06, 00, 'Quantidade por pacote - For non-Deere parts only(ver ofinjd06)'})
	aAdd(::aInicio , {016 , 'C', 06, 00, 'Codigo do vendedor - For non-Deere parts only(ver ofinjd06)'})
	aAdd(::aInicio , {017 , 'C', 06, 00, 'Vendor substitution information '})
	aAdd(::aInicio , {018 , 'C', 06, 00, 'Pricing base (JDParts) '})
	aAdd(::aInicio , {019 , 'C', 06, 00, 'Pricing additive (JDParts) '})
	aAdd(::aInicio , {020 , 'C', 06, 00, 'Dealer Price (JDParts) '})
	aAdd(::aInicio , {021 , 'C', 06, 00, 'Order Formula Code (OFC) '})
	aAdd(::aInicio , {022 , 'C', 06, 00, 'Delete Indicator'})
	aAdd(::aInicio , {023 , 'C', 06, 00, 'Reserved Hits – Work Orders '})
	aAdd(::aInicio , {024 , 'C', 06, 00, 'Reserved Hits – Part Tickets '})
	aAdd(::aInicio , {025 , 'C', 06, 00, 'Average Cost'})
	aAdd(::aInicio , {026 , 'C', 06, 00, 'Start of initialization record fields '})
	aAdd(::aInicio , {027 , 'C', 06, 00, 'Part Description '})
	aAdd(::aInicio , {028 , 'C', 06, 00, 'Dealer part note'})
	aAdd(::aInicio , {029 , 'C', 06, 00, 'Order Indicator'})
	aAdd(::aInicio , {030 , 'C', 06, 00, 'Date Added'})
	aAdd(::aInicio , {031 , 'C', 06, 00, 'Dealer Group Code'})
	aAdd(::aInicio , {032 , 'C', 06, 00, 'Minimum Order Quantity'})
	aAdd(::aInicio , {033 , 'C', 06, 00, 'Maximum Order Quantity'})
	aAdd(::aInicio , {034 , 'C', 06, 00, 'Number of monthly history buckets included in this record'})
	aAdd(::aInicio , {035 , 'C', 06, 00, 'Pieces in Set'})

	/* Esta parte tem repetição pois todo o resto do arquivo é este fim repetido 36 vezes depois vem mais dados */
	aAdd(::aMeio, {001 , 'C', 00, 00, 'Sales'})
	aAdd(::aMeio, {002 , 'C', 00, 00, 'Hits'})
	aAdd(::aMeio, {003 , 'C', 00, 00, 'Lost Sales'})
	aAdd(::aMeio, {004 , 'C', 00, 00, 'Lost Hits'})
	/* ---- */

	aAdd(::aFim, {180, 'C', 00, 00, 'Total Sales 1–12 months ago'})
	aAdd(::aFim, {181, 'C', 00, 00, 'Total Hits 1–12 months ago'})
	aAdd(::aFim, {182, 'C', 00, 00, 'Total Lost Sales 1–12 months ago'})
	aAdd(::aFim, {183, 'C', 00, 00, 'Total Lost Hits 1–12 months ago'})
	aAdd(::aFim, {184, 'C', 00, 00, 'Total Sales 13-24 months ago'})
	aAdd(::aFim, {185, 'C', 00, 00, 'Total Hits 13-24 months ago'})
	aAdd(::aFim, {186, 'C', 00, 00, 'Total Lost Sales 13-24 months ago'})
	aAdd(::aFim, {187, 'C', 00, 00, 'Total Lost Hits 13-24 months ago'})
	aAdd(::aFim, {188, 'C', 00, 00, 'Total Sales 25-36 months ago'})
	aAdd(::aFim, {189, 'C', 00, 00, 'Total Hits 25-36 months ago'})
	aAdd(::aFim, {190, 'C', 00, 00, 'Total Lost Sales 25-36 months ago'})
	aAdd(::aFim, {191, 'C', 00, 00, 'Total Lost Hits 25-36 months ago'})
	aAdd(::aFim, {192, 'C', 00, 00, 'Total Sales 37-48 months ago'})
	aAdd(::aFim, {193, 'C', 00, 00, 'Total Hits 37-48 months ago'})
	aAdd(::aFim, {194, 'C', 00, 00, 'Total Lost Sales 37-48 months ago'})
	aAdd(::aFim, {195, 'C', 00, 00, 'Total Lost Hits 37-48 months ago'})

Return SELF

/*/{Protheus.doc} StartArq
	Pega o valor relacionado ao label

	@author  Vinicius Gati
	@since   30/12/2015
/*/
Method StartArq() Class DMS_DPMDPE_1_3

Return .T.

/*/{Protheus.doc} IncHead
	Inclui linha de header no arquivo

	@author  Vinicius Gati
	@since   30/12/2015
/*/
Method IncHead() Class DMS_DPMDPE_1_3

Return .T.

/*/{Protheus.doc} IncWhHead
	Inclui linha de header de armazem no arquivo

	@author  Vinicius Gati
	@since   30/12/2015
/*/
Method IncWhHead() Class DMS_DPMDPE_1_3

Return .T.

/*/{Protheus.doc} IncLine
	Pega o valor relacionado ao label

	@author  Vinicius Gati
	@since   30/12/2015
/*/
Method IncLine() Class DMS_DPMDPE_1_3

Return .T.

/*/{Protheus.doc} EndArq
	Pega o valor relacionado ao label

	@author  Vinicius Gati
	@since   30/12/2015
/*/
Method EndArq() Class DMS_DPMDPE_1_3

Return .T.

/*/{Protheus.doc} isPrism
	Utiliza Jd Prism?

	@author  Vinicius Gati
	@since   30/12/2015
/*/
Method isPrism() Class DMS_DPMDPE_1_3
Return GetNewPar("MV_MIL0067","N") == "S"

/*/{Protheus.doc} canGenDelta
	Pode gerar extração delta?

	@author  Vinicius Gati
	@since   30/12/2015
/*/
Method canGenDelta() Class DMS_DPMDPE_1_3
Return GetNewPar("MV_MIL0068","N") == "S"


/*/{Protheus.doc} DMS_DemandaDPM
	Classe de controle dos DPMOrders do JDPrism interface
	Terá os dados salvos no VQL

	@author       Vinicius Gati
	@since        30/12/2015

/*/
CLASS DMS_DemandaDPM
	DATA aSitDem
	DATA aSitEsp
	DATA aSitRec

	Method New() CONSTRUCTOR
	Method ConsDemanda()
	Method isEspecial()
	Method isRecompra()
	Method InSitDem()
ENDCLASS


/*/{Protheus.doc} New
	Cria o objeto e busca as informações de situacoes de demanda

	@author  Vinicius Gati
	@since   30/12/2015
/*/
Method New() class DMS_DemandaDPM
	oSqlHlp  := DMS_SqlHelper():New()
	oArrHelp := DMS_ArrayHelper():New()

	//1=Considerar;2=Recompra;3=Especial
	::aSitDem := oArrHelp:Map( oSqlHlp:GetSelect({ {'campos', {'V09_CODSIT'}},{'query', " SELECT V09_CODSIT FROM "+RetSqlName('V09')+" WHERE V09_FILIAL = '"+xFilial('V09')+"' AND V09_DEMDPM = '1' AND D_E_L_E_T_ =  ' ' "} }) , {|e| e:GetValue('V09_CODSIT')} )
	::aSitRec := oArrHelp:Map( oSqlHlp:GetSelect({ {'campos', {'V09_CODSIT'}},{'query', " SELECT V09_CODSIT FROM "+RetSqlName('V09')+" WHERE V09_FILIAL = '"+xFilial('V09')+"' AND V09_DEMDPM = '2' AND D_E_L_E_T_ =  ' ' "} }) , {|e| e:GetValue('V09_CODSIT')} )
	::aSitEsp := oArrHelp:Map( oSqlHlp:GetSelect({ {'campos', {'V09_CODSIT'}},{'query', " SELECT V09_CODSIT FROM "+RetSqlName('V09')+" WHERE V09_FILIAL = '"+xFilial('V09')+"' AND V09_DEMDPM = '3' AND D_E_L_E_T_ =  ' ' "} }) , {|e| e:GetValue('V09_CODSIT')} )

	nTst := 1
return SELF

/*/{Protheus.doc} ConsDemanda
	Considera esta situação na demanda?

	@author  Vinicius Gati
	@since   30/12/2015
/*/
Method ConsDemanda(cCodSit) Class DMS_DemandaDPM
return ASCAN(self:aSitDem, {|el| el == cCodSit}) > 0


/*/{Protheus.doc} isEspecial
	Considera esta situação como especial?

	@author  Vinicius Gati
	@since   30/12/2015
/*/
Method isEspecial(cCodSit) Class DMS_DemandaDPM
return ASCAN(self:aSitEsp, {|el| el == cCodSit}) > 0

/*/{Protheus.doc} isRecompra
	Considera esta situação como recompra?

	@author  Vinicius Gati
	@since   30/12/2015
/*/
Method isRecompra(cCodSit) Class DMS_DemandaDPM
return ASCAN(self:aSitRec, {|el| el == cCodSit}) > 0

/*/{Protheus.doc} InSitDem
	In para sql que retorna as situações de venda em que enquandram demanda

	@type function
	@author Vinicius Gati
	@since 17/08/2017
/*/
Method InSitDem() Class DMS_DemandaDPM
	local cIn := ""
	local oArHlp := DMS_ArrayHelper():New()
	local aDados := {}

	aDados := oArHlp:Map(self:aSitDem, {|sit| "'" + sit + "'" })
	cIn    += oArHlp:Join(aDados, ',')
return cIn


/*/{Protheus.doc} DMS_DevPecas
	Classe para ajudar a coletar dados de devoluções de peças

	@author       Vinicius Gati
	@since        19/07/2016

/*/
CLASS DMS_DevPecas
	Method New() CONSTRUCTOR
	Method GetDevData()
ENDCLASS

/*/{Protheus.doc} New
	Cria o objeto e busca as informações de situacoes de demanda

	@author  Vinicius Gati
	@since   19/07/2016
/*/
Method New() class DMS_DevPecas
return SELF

/*/{Protheus.doc} GetDevData
	Retorna os dados de devolucao da peca

	@author  Vinicius Gati
	@since   19/07/2016
/*/
Method GetDevData(cFil, cB1Cod, nNroAnos) class DMS_DevPecas
	Local aDevData   := {}
	Local cQuery     := " "
	Local cBckFilial := cFilAnt
	Local oSqlHlp    := DMS_SqlHelper():New()
	Local oUtil      := DMS_Util():New()
	Local nIdx       := 0
	Local dData36At
	Default nNroAnos := 1

	dData    := dDataBase
	cFilAnt := cFil

	dData36At := dData
	for nIdx := 1 to nNroAnos
		dData36At := oUtil:RemoveMeses(dData36At, 12)
	Next

	cQuery += " SELECT D1_FILIAL, D1_COD, D1_DTDIGIT, SUM(D1_QUANT) QTD_ITENS FROM "
	cQuery += " ( "
	cQuery += "  SELECT D1_FILIAL, D1_COD, D1_DTDIGIT, D1_QUANT "
	cQuery += "    FROM "+oSqlHlp:NoLock('SD1')
	cQuery += "    JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD    = SD1.D1_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "    JOIN "+oSqlHlp:NoLock('SF4')+" ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_OPEMOV  = '09' AND SF4.D_E_L_E_T_ = ' '  "
	cQuery += "   WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"' "
	cQuery += "	    AND SD1.D1_COD = '"+cB1Cod+"' "
	cQuery += "     AND D1_DTDIGIT BETWEEN '" + DTOS(dData36At) + "' AND '" + DTOS(dData) + "' "
	cQuery += "	    AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += " ) T "
	cQuery += " GROUP BY D1_FILIAL , D1_COD , D1_DTDIGIT "
	cQuery += " ORDER BY D1_FILIAL, D1_COD , D1_DTDIGIT "

	aDevData := oSqlHlp:GetSelect({;
		{'campos', {'D1_FILIAL','D1_COD', 'D1_DTDIGIT', 'QTD_ITENS'}},;
		{'query' , cQuery} ;
	})

	cFilAnt := cBckFilial
return aDevData

