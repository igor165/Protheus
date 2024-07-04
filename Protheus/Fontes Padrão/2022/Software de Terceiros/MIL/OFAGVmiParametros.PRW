#include "protheus.ch"

function OFAGVmiParametros()
return .t.

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  23/03/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFAGVmiParametros
	Classe responsavel por retornar os parametros de configuracao do VMI

	@type class
	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiParametros
	Data aTposPed
	Data oDados
	Data oArrHlp
	Data oSqlHlp
	Data aTiposGar
	Data aTiposRepo
	Data aTiposMP
	Data oUtil

	Method New() CONSTRUCTOR
	Method filiais()
	Method grupos()
	Method gruposParalelos()
	Method user()
	Method pass()
	Method codVendaPerdida()
	Method codSitVendaAnormal()
	Method FornecedoresAGCO()
	Method DocFornPadrao()
	Method ClientesAGCO()
	Method ClienteValido()
	Method TipPedGar()
	Method TipPedRepo()
	Method TipPedMP()
	Method FilialValida()
	Method ArmReserva()
	Method DocMatriz()
	Method DelimitaInit()
	Method DataInit()
	Method NomeArqConfig()
	Method QtdDiasArmazenar()
EndClass

/*/{Protheus.doc} New
	Simples construtor

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method New() Class OFAGVmiParametros
	::oUtil      := DMS_Util():New()
	::oSqlHlp    := DMS_SqlHelper():New()
	::oArrHlp    := DMS_ArrayHelper():New()
	::oDados     := ::oUtil:ParamFileOpen(::NomeArqConfig())
	::aTposPed   := ::oDados:GetValue("TIPOS_DE_PEDIDOS")
	::aTiposGar  := {}
	::aTiposRepo := {}
	::aTiposMP   := {}
return self

/*/{Protheus.doc} FornecedoresAGCO
	Retorna os recnos dos fornecedores  AGCO

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method FornecedoresAGCO() Class OFAGVmiParametros
Return self:oDados:GetValue("FORNECEDORES_AGCO")

/*/{Protheus.doc} ClientesAGCO
	Retorna os recnos dos clientes parceiros AGCO, serão pegos via CNPJ do fornecedor

	@type function
	@author Vinicius Gati
	@since 12/07/2017
/*/
Method ClientesAGCO() Class OFAGVmiParametros
Return self:oDados:GetValue("CONCESSIONARIOS_DA_REDE")

/*/{Protheus.doc} ClienteValido
	Verifica se o cliente é um cliente valido ao VMI ou deve ser desconsiderado(parceiro)

	@type function
	@author Vinicius Gati
	@since 12/07/2017
/*/
Method ClienteValido(nRecno) Class OFAGVmiParametros
Return ! self:oArrHlp:Exists(self:ClientesAGCO(), ALLTRIM(STR(nRecno)))

/*/{Protheus.doc} filiais
	Retorna as filiais que usam VMI

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method filiais() Class OFAGVmiParametros
Return self:oArrHlp:Map( self:oDados:GetValue("FILIAIS_AGCO"), {|oObj| oObj:GetValue("FILIAL") } )

/*/{Protheus.doc} Grupos
	Retorna os grupos de peças originais AGCO

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method grupos() Class OFAGVmiParametros
Return self:oDados:GetValue("GRUPOS_ORIGINAIS")

/*/{Protheus.doc} gruposParalelos
	Retorna os grupos de peças paralelas AGCO

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method gruposParalelos() Class OFAGVmiParametros
Return self:oDados:GetValue("GRUPOS_PARALELOS")

/*/{Protheus.doc} user
	Retorna o usuário de conexão com servidor VMI

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method user() Class OFAGVmiParametros
	Local aFil := self:oDados:GetValue("FILIAIS_AGCO",{})
	Local nPos := aScan(aFil,{|x| x:GetValue("FILIAL") == cFilAnt })
	Local cRet := IIf(nPos>0,aFil[nPos]:GetValue("CODIGO_DO_USUARIO"),"") // Retorna o Codigo do Usuario na AGCO por Filial
	If Empty(cRet)
		conout('VMI -> CODIGO_DO_USUARIO NA AGCO ESTA EM BRANCO - Filial: ' + cFilAnt)
	EndIf
Return cRet

/*/{Protheus.doc} pass
	Retorna senha de conexão com servidor AGCO

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method pass() Class OFAGVmiParametros
	Local aFil := self:oDados:GetValue("FILIAIS_AGCO",{})
	Local nPos := aScan(aFil,{|x| x:GetValue("FILIAL") == cFilAnt })
	Local cRet := IIf(nPos>0,aFil[nPos]:GetValue("SENHA_DO_USUARIO"),"") // Retorna a Senha do Usuario na AGCO por Filial
	If Empty(cRet)
		conout('VMI -> SENHA_DO_USUARIO NA AGCO ESTA EM BRANCO - Filial: ' + cFilAnt)
	EndIf
Return cRet

/*/{Protheus.doc} NomeMetodo
	Retorna o código do motivo de venda perdida, cadastro de motivos chave 000004

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method codVendaPerdida() Class OFAGVmiParametros
Return self:oDados:GetValue("MOTIVO_VENDA_PERDIDA")

/*/{Protheus.doc} TipPedGar
	Verifica se o tipo de pedido é de garantia

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method TipPedGar(cTipo) Class OFAGVmiParametros
	local aTipos
	local oTipos
	if Empty(self:aTiposGar)
		oTipos := self:oArrHlp:Select(self:aTposPed, {;
			|oTipo| (oTipo:GetValue("FILIAL") == cFilAnt .OR. Empty(oTipo:GetValue("FILIAL"))) .AND. !Empty(oTipo:GetValue("TIPO_GARANTIA"));
		})
		self:aTiposGar := self:oArrHlp:Map(oTipos, {|oTipo| oTipo:GetValue("TIPO_GARANTIA")})
	endif
return self:oArrHlp:Exists(self:aTiposGar, cTipo)

/*/{Protheus.doc} TipPedRepo
	Verifica se o tipo de pedido é de simples reposição

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method TipPedRepo(cTipo) Class OFAGVmiParametros
	local aTipos
	local oTipos
	if Empty(self:aTiposRepo)
		oTipos := self:oArrHlp:Select(self:aTposPed, {;
			|oTipo| (oTipo:GetValue("FILIAL") == cFilAnt .OR. Empty(oTipo:GetValue("FILIAL"))) .AND. !Empty(oTipo:GetValue("TIPO_ESTOQUE_REPOSICAO"));
		})
		self:aTiposRepo := self:oArrHlp:Map(oTipos, {|oTipo| oTipo:GetValue("TIPO_ESTOQUE_REPOSICAO")})
	endif
return self:oArrHlp:Exists(self:aTiposRepo, cTipo)

/*/{Protheus.doc} TipPedMP
	Verifica se o tipo de pedido é de máquina parada

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method TipPedMP(cTipo) Class OFAGVmiParametros
	local aTipos
	local oTipos
	if Empty(self:aTiposMP)
		oTipos := self:oArrHlp:Select(self:aTposPed, {;
			|oTipo| (oTipo:GetValue("FILIAL") == cFilAnt .OR. Empty(oTipo:GetValue("FILIAL"))) .AND. !Empty(oTipo:GetValue("TIPO_MAQUINA_PARADA"));
		})
		self:aTiposMP := self:oArrHlp:Map(oTipos, {|oTipo| oTipo:GetValue("TIPO_MAQUINA_PARADA")})
	endif
return self:oArrHlp:Exists(self:aTiposMP, cTipo)

/*/{Protheus.doc} codSitVendaAnormal
	Verifica se a situação da venda é a mesma configurada como venda anormal

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method codSitVendaAnormal() Class OFAGVmiParametros
return self:oDados:GetValue("SITUACAO_VENDA_ANORMAL")

/*/{Protheus.doc} FilialValida
	Verifica se a filial utiliza o VMI

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method FilialValida(cFil) Class OFAGVmiParametros
return self:oArrHlp:Exists(self:filiais(), cFil)

/*/{Protheus.doc} ArmReserva
	Retorna um array contendo os armazens de reserva

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method ArmReserva() Class OFAGVmiParametros
	local aArms
	cQuery := "SELECT distinct VOI_CODALM "
	cQuery += "  FROM " + RetSqlName('VOI')
	cQuery += " WHERE VOI_FILIAL = '"+xFilial('VOI')+"' "
	cQuery += "   AND VOI_REQPEC = '1' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	aArms := self:oSqlHlp:GetSelectArray(cQuery)
	AADD(aArms, GetNewPar("MV_RESITE", "  "))
return aArms

/*/{Protheus.doc} DocMatriz
	Retorna CNPJ da Filial LOGADA para comunicação com VMI
	---
	Esta configuração foi criada para manter o cnpj da matriz, porem parece
	que a documentacao estava errada e ela não é necessária, sendo assim
	utilizei o metodo para retornar o cnpj da filial corrente.

	@type function
	@author Vinicius Gati
	@since 06/07/2017
/*/
Method DocMatriz() Class OFAGVmiParametros
	Local aFil := self:oDados:GetValue("FILIAIS_AGCO",{})
	Local nPos := aScan(aFil,{|x| x:GetValue("FILIAL") == cFilAnt })
return aFil[nPos]:GetValue("CNPJ") // Retorna CNPJ da Filial LOGADA

/*/{Protheus.doc} DelimitaInit
	Marca um ponto para separação do init e diário

	@type function
	@author Vinicius Gati
	@since 20/07/2017
/*/
Method DelimitaInit(aFilis) Class OFAGVmiParametros
	local nIdx      := 0
	local cFileName := ''

	if ! Empty(aFilis)
		for nIdx:= 1 to Len(aFilis)
			cFilAnt   := aFilis[nIdx]
			cFileName := xFilial('VS3') + "_VMI_DELIMITA_INIT.JSON"
			if ! FILE(cFileName) // se nao existe o arquivo ainda nao esta delimitado
				oDados    := self:oUtil:ParamFileOpen(cFileName)
				cD1NUMSEQ := FM_SQL(" SELECT MAX(D1_NUMSEQ) FROM "+RetSqlName('SD1')+" WHERE D1_FILIAL = '"+xFilial('SD1')+"' AND D_E_L_E_T_ = ' ' ")
				cD2NUMSEQ := FM_SQL(" SELECT MAX(D2_NUMSEQ) FROM "+RetSqlName('SD2')+" WHERE D2_FILIAL = '"+xFilial('SD2')+"' AND D_E_L_E_T_ = ' ' ")
				cD3NUMSEQ := FM_SQL(" SELECT MAX(D3_NUMSEQ) FROM "+RetSqlName('SD3')+" WHERE D3_FILIAL = '"+xFilial('SD3')+"' AND D_E_L_E_T_ = ' ' ")
				oObjD1 := DMS_DataContainer():New({{"NUMSEQ", cD1NUMSEQ}})
				oObjD2 := DMS_DataContainer():New({{"NUMSEQ", cD2NUMSEQ}})
				oObjD3 := DMS_DataContainer():New({{"NUMSEQ", cD3NUMSEQ}})
				oDados:SetValue("SD1", oObjD1)
				oDados:SetValue("SD2", oObjD2)
				oDados:SetValue("SD3", oObjD3)
				oDados:SetValue("DATA", DTOS(date()))
				self:oUtil:ParamFileSave(cFileName, oDados)
			endif
		next
	endif
return .T.

/*/{Protheus.doc} DataInit
	Data em que foi delimitado init

	@type function
	@author Vinicius Gati
	@since 20/07/2017
/*/
Method DataInit() Class OFAGVmiParametros
	local cFilBck := cFilAnt
	cFilAnt := self:filiais()[1]
	oDados  := self:oUtil:ParamFileOpen(xFilial('VS3') + "_VMI_DELIMITA_INIT.JSON")
	cFilAnt := cFilBck
Return STOD(oDados:GetValue("DATA"))

/*/{Protheus.doc} DocFornPadrao()
	Retorna documento padrão do fornecedor de peças
	
	@type function
	@author Vinicius Gati
	@since 21/07/2017
/*/
Method DocFornPadrao() Class OFAGVmiParametros
Return self:oDados:GetValue("DOC_FORNECEDOR_PADRAO", "99.999.999/0001-99")

/*/{Protheus.doc} NomeArqConfig
	Retorna o nome do Arquivo de Configuracao do VMI

	@type function
	@author Andre Luis Almeida
	@since 20/05/2019
/*/
Method NomeArqConfig() Class OFAGVmiParametros
Return FWCodEmp()+"_VMI_CONFIG.JSON"


/*/{Protheus.doc} QtdDiasArmazenar
	Retorna a Qtde de Dias Armazenar AGCO

	@type function
	@author Andre Luis Almeida
	@since 12/02/2020
/*/
Method QtdDiasArmazenar() Class OFAGVmiParametros
Return self:oDados:GetValue("QTD_DIAS_ARMAZENAR")