#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURRESTMODELS.CH"

Static _lIsLegalDesk := .F.
Static _cRestURL     := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} JurRESTModels
Publicação dos modelos que devem ficar disponíveis no REST.
Vide classe FwRestModel.

@author Cristina Cintra
@since 11/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Class JRestModel From FwRestModel
	Data searchKey AS STRING
	
	Method Activate()
	Method DeActivate()

EndClass

//-------------------------------------------------------------------
Method Activate() Class JRestModel
Local cLD     := self:GetHttpHeader("LEGALDESK")
Local cFiltro := ""

	self:searchKey := self:GetHttpHeader("searchKey")
	If cLD == Nil
		cLD := ""
	EndIf
	
	_lIsLegalDesk := (Upper(cLD) == "TRUE")
	_cRestURL     := self:GetHttpHeader("_URL_")
	I18nConOut("LEGALDESK: #1", {cLD})

	If !Empty(self:searchKey)
		If (!Empty(Self:cFilter))
			cFiltro := Self:cFilter + " AND "
		EndIf
		Self:SetFilter(cFiltro + JMontSrcky(self:searchKey))
	EndIf
Return _Super:Activate()

//-------------------------------------------------------------------
Method DeActivate() Class JRestModel

	_lIsLegalDesk := .F.
	_cRestURL     := ""

Return _Super:DeActivate()

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSetLD
Função para setar um valor na variável _lIsLegalDesk, 
para a função JurIsRest() funcionar corretamente

@param lLd, lógico, Se a execução está sendo feita por uma requisição do LegalDesk

@author bruno.ritter/queizy.nascimento
@since 12/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSetLD(lLd)

	_lIsLegalDesk := lLd

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSetURL
Função para setar um valor na variável _cRestURL, 
para a função JIsRestID() funcionar corretamente

@param cRestURL, URL da chamada REST

@author Bruno Ritter
@since 23/10/2019
/*/
//-------------------------------------------------------------------
Function JurSetURL(cRestURL)

	_cRestURL := cRestURL

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIsRest
Indica se a execução está sendo feita por uma requisição do LegalDesk

@return _lIsLegalDesk, .T. - Requisição do LegalDesk

@author bruno.ritter/queizy.nascimento
@since 12/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIsRest()
Return _lIsLegalDesk 

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetRestURL
Retornar a URL da requisição REST

@return _cRestURL, URL da requisição 

@author Jonatas Martins
@since  22/07/2019
@Obs    _cRestURL, Variável STATIC alimentada no ACTIVATE
/*/
//-------------------------------------------------------------------
Function JGetRestURL()
Return (_cRestURL)

//-------------------------------------------------------------------
/*/{Protheus.doc} JIsRestID
Indica se o ID do modelo da requisição via LegalDesk é o mesmo que o
informado no parâmetro cModelID.

@param  cModelID , Id de identificação do modelo (Ex: "JURA241")
@param  cNickName, Apelido de identificação do modelo (Ex: "JLANCAMENTOS")

@return lMatch   , Se .T. o modelo da requisição é igual ao do parâmetro

@author Jonatas Martins
@since  22/07/2019
@Obs    _cRestURL, Variável STATIC alimentada no ACTIVATE
/*/
//-------------------------------------------------------------------
Function JIsRestID(cModelID, cNickName)
	Local lMatch      := .F.

	Default cModelID  := ""
	Default cNickName := ""

	lMatch := (cModelID $ _cRestURL) .Or. (cNickName $ _cRestURL)
	
Return (lMatch)

//-------------------------------------------------------------------
/* Publicação dos modelos que são disponibilizados no REST */

						//Apelido        //Fonte                //Objeto 
PUBLISH MODEL REST NAME JPARAM SOURCE JURA171                                     //Parâmetros - JURA171
PUBLISH MODEL REST NAME JEMPRESA SOURCE JURA193 RESOURCE OBJECT Rest193           //Empresas/Filiais - JURA193
PUBLISH MODEL REST NAME JFILASINC SOURCE JURA170 RESOURCE OBJECT JurRest170       //Fila de Sincronização - JURA170
PUBLISH MODEL REST NAME JIDIOMA SOURCE JURA029 RESOURCE OBJECT JRestModel         //Idioma - JURA029
PUBLISH MODEL REST NAME JMOEDA SOURCE CTBA140 RESOURCE OBJECT JRestModel          //Moedas Contábeis - CTBA140
PUBLISH MODEL REST NAME JGRPJUR SOURCE CTBA030 RESOURCE OBJECT JRestModel         //Centros de Custos/Grupos Jurídicos - CTBA030
PUBLISH MODEL REST NAME JCOTDIARIA SOURCE MATA090 RESOURCE OBJECT Rest090         //Cotações Diárias - MATA090
PUBLISH MODEL REST NAME JLANCTAB SOURCE JURA027 RESOURCE OBJECT JRestModel        //Lançamentos Tabelados - JURA027
PUBLISH MODEL REST NAME JFECHPER SOURCE JURA030 RESOURCE OBJECT JRestModel        //Fechamento de Período - JURA030
PUBLISH MODEL REST NAME JAREAJUR SOURCE JURA038 RESOURCE OBJECT JRestModel        //Área Jurídica - JURA038
PUBLISH MODEL REST NAME JTPDESP SOURCE JURA044 RESOURCE OBJECT JRestModel         //Tipo de Despesas - JURA044
PUBLISH MODEL REST NAME JDESPESA SOURCE JURA049 RESOURCE OBJECT JRestModel        //Despesas - JURA049
PUBLISH MODEL REST NAME JESCRITORIO SOURCE JURA068 RESOURCE OBJECT JRestModel     //Escritórios - JURA068
PUBLISH MODEL REST NAME JCASO SOURCE JURA070 RESOURCE OBJECT JRestModel           //Casos - JURA070
PUBLISH MODEL REST NAME JCONTRATO SOURCE JURA096 RESOURCE OBJECT JRestModel       //Contratos - JURA096
PUBLISH MODEL REST NAME JTIMESHEET SOURCE JURA144 RESOURCE OBJECT JRestModel      //Time Sheets - JURA144
PUBLISH MODEL REST NAME JCLIENTE SOURCE JURA148 RESOURCE OBJECT JRestModel        //Clientes - JURA148
PUBLISH MODEL REST NAME JPARTICIPANTE SOURCE JURA159 RESOURCE OBJECT JRestModel   //Participantes - JURA159
PUBLISH MODEL REST NAME JPREFAT SOURCE JURA202 RESOURCE OBJECT JRestModel         //Pré-faturas - JURA202
PUBLISH MODEL REST NAME JURA202RES SOURCE JURA202E RESOURCE OBJECT JRestModel     //Pré-faturas Resumido - JURA202E
PUBLISH MODEL REST NAME JFATURA SOURCE JURA204 RESOURCE OBJECT JRestModel         //Faturas - JURA204
PUBLISH MODEL REST NAME JMUNICIPIO SOURCE FISA010 RESOURCE OBJECT JRestModel      //Municípios - FISA010
PUBLISH MODEL REST NAME JPAIS SOURCE JURA194 RESOURCE OBJECT JRestModel           //Países - JURA194
PUBLISH MODEL REST NAME JESTADO SOURCE JURA195 RESOURCE OBJECT Rest195            //Estados - JURA195
PUBLISH MODEL REST NAME JTPHONOR SOURCE JURA037 RESOURCE OBJECT JRestModel        //Tipo de Honorários - JURA037
PUBLISH MODEL REST NAME JTPATIV SOURCE JURA039 RESOURCE OBJECT JRestModel         //Tipos de Atividade - JURA039
PUBLISH MODEL REST NAME JSERVTAB SOURCE JURA040 RESOURCE OBJECT JRestModel        //Serviços Tabelados - JURA040
PUBLISH MODEL REST NAME JTABSERV SOURCE JURA041 RESOURCE OBJECT JRestModel        //Tabela de Serviços - JURA041
PUBLISH MODEL REST NAME JTPORIG SOURCE JURA045 RESOURCE OBJECT JRestModel         //Tipo de Originação - JURA045
PUBLISH MODEL REST NAME JTPTABSERV SOURCE JURA047 RESOURCE OBJECT JRestModel      //Tipo de Tabela de Serviços - JURA047
PUBLISH MODEL REST NAME JSUBAREAJUR SOURCE JURA048 RESOURCE OBJECT JRestModel     //SubÁrea Jurídica - JURA048
PUBLISH MODEL REST NAME JCATEGPART SOURCE JURA050 RESOURCE OBJECT JRestModel      //Categoria de Participantes - JURA050
PUBLISH MODEL REST NAME JDOCEBILL SOURCE JURA057 RESOURCE OBJECT JRestModel       //Documento E-billing - JURA057
PUBLISH MODEL REST NAME JEMPEBILL SOURCE JURA058 RESOURCE OBJECT JRestModel       //Empresa E-billing - JURA058
PUBLISH MODEL REST NAME JFERIADO SOURCE JURA078 RESOURCE OBJECT JRestModel        //Feriados - JURA078
PUBLISH MODEL REST NAME JCOTMENSAL SOURCE JURA111 RESOURCE OBJECT JRestModel      //Cotações Mensais - JURA111
PUBLISH MODEL REST NAME JLOCALIDADE SOURCE JURA123 RESOURCE OBJECT JRestModel     //Localidades - JURA123
PUBLISH MODEL REST NAME JTPPREST SOURCE JURA164 RESOURCE OBJECT JRestModel        //Tipo de Prestação de Contas - JURA164
PUBLISH MODEL REST NAME JTPRET SOURCE JURA073 RESOURCE OBJECT JRestModel          //Tipo de Retorno / Situação de Cobrança - JURA073
PUBLISH MODEL REST NAME JGRPCLI SOURCE FATA110 RESOURCE OBJECT JRestModel         //Grupo de Clientes - FATA110 (ACY)
PUBLISH MODEL REST NAME JCONDPAG SOURCE MATA360 RESOURCE OBJECT JRestModel        //Condição de Pagamento - MATA360 (SE4)
PUBLISH MODEL REST NAME JMOTIVOWO SOURCE JURA140 RESOURCE OBJECT JRestModel       //Motivo de WO - JURA140
PUBLISH MODEL REST NAME JANEXOS SOURCE JURA026 RESOURCE OBJECT JRestModel         //Anexos - Docs Jurídicos - JURA026
PUBLISH MODEL REST NAME JCONTATOS SOURCE JURA232 RESOURCE OBJECT JRestModel       //Contatos - JURA232
PUBLISH MODEL REST NAME JTABHONOR SOURCE JURA042 RESOURCE OBJECT JRestModel       //Tabela de Honorários - JURA042
PUBLISH MODEL REST NAME JFATADIC SOURCE JURA033 RESOURCE OBJECT JRestModel        //Fatura Adicional - JURA033
PUBLISH MODEL REST NAME JSOLICDES SOURCE JURA235 RESOURCE OBJECT JRestModel        //Solicitação de Despesas - JURA235
PUBLISH MODEL REST NAME JCONSULTWO SOURCE JURA146 RESOURCE OBJECT JRestModel      //Consulta WO - JURA146
PUBLISH MODEL REST NAME JNATUREZA SOURCE FINA010 RESOURCE OBJECT JRestModel       //Naturezas Financeiras - FINA010
PUBLISH MODEL REST NAME JTABRATEIO SOURCE JURA238 RESOURCE OBJECT JRestModel      //Tabela Rateio - JURA238
PUBLISH MODEL REST NAME JLANCAMENTOS SOURCE JURA241 RESOURCE OBJECT JRestModel    //Lançamentos - JURA241
PUBLISH MODEL REST NAME JORCAMENTOS SOURCE JURA252 RESOURCE OBJECT JRestModel     //Orçamentos - JURA252
PUBLISH MODEL REST NAME JCALENDARIO SOURCE JURA253 RESOURCE OBJECT JRestModel     //Calendário Contábil - JURA253
PUBLISH MODEL REST NAME JADIANTAMENTO SOURCE JURA069 RESOURCE OBJECT JRestModel   //Controle de Adiantamento - JURA069
PUBLISH MODEL REST NAME JPOSRECEBER SOURCE JURA255 RESOURCE OBJECT JRestModel     //Posição Historico CAR - JURA255
PUBLISH MODEL REST NAME JRASTRECEBER SOURCE JURA256 RESOURCE OBJECT JRestModel    //Rastreio de recebimento dos casos da fatura - JURA256
PUBLISH MODEL REST NAME JBANCO SOURCE MATA070 RESOURCE OBJECT JRestModel          //Bancos - MATA070
PUBLISH MODEL REST NAME JPROJETO SOURCE JURA264 RESOURCE OBJECT JRestModel        //Projetos e Finalidades - JURA264
PUBLISH MODEL REST NAME JFORNECE SOURCE MATA020 RESOURCE OBJECT JRestModel        //Fornecedores - MATA020
PUBLISH MODEL REST NAME JCOBRANCA SOURCE JURA244 RESOURCE OBJECT JRestModel       //Cobrança - JURA244
PUBLISH MODEL REST NAME JSEGMENTO SOURCE CRMA610 RESOURCE OBJECT JRestModel       //Segmentos (AOV) - CRMA610
PUBLISH MODEL REST NAME JDOCANEXO SOURCE JURA290 RESOURCE OBJECT JRestModel       //Anexos (NUM) - JURA290

//Mesmos modelos acima, mas tratando o apelido com o nome do fonte
PUBLISH MODEL REST NAME JURA171 SOURCE JURA171                               //Parâmetros - JURA171
PUBLISH MODEL REST NAME JURA193 SOURCE JURA193 RESOURCE OBJECT Rest193       //Empresas/Filiais - JURA193
PUBLISH MODEL REST NAME JURA170 SOURCE JURA170 RESOURCE OBJECT JurRest170    //Fila de Sincronização - JURA170
PUBLISH MODEL REST NAME JURA029 SOURCE JURA029 RESOURCE OBJECT JRestModel    //Idioma de Faturamento - JURA029
PUBLISH MODEL REST NAME JURA027 SOURCE JURA027 RESOURCE OBJECT JRestModel    //Lançamentos Tabelados - JURA027
PUBLISH MODEL REST NAME JURA030 SOURCE JURA030 RESOURCE OBJECT JRestModel    //Fechamento de Período - JURA030
PUBLISH MODEL REST NAME JURA038 SOURCE JURA038 RESOURCE OBJECT JRestModel    //Área Jurídica - JURA038
PUBLISH MODEL REST NAME JURA044 SOURCE JURA044 RESOURCE OBJECT JRestModel    //Tipo de Despesas - JURA044
PUBLISH MODEL REST NAME JURA049 SOURCE JURA049 RESOURCE OBJECT JRestModel    //Despesas - JURA049
PUBLISH MODEL REST NAME JURA068 SOURCE JURA068 RESOURCE OBJECT JRestModel    //Escritórios - JURA068
PUBLISH MODEL REST NAME JURA070 SOURCE JURA070 RESOURCE OBJECT JRestModel    //Casos - JURA070
PUBLISH MODEL REST NAME JURA096 SOURCE JURA096 RESOURCE OBJECT JRestModel    //Contratos - JURA096
PUBLISH MODEL REST NAME JURA144 SOURCE JURA144 RESOURCE OBJECT JRestModel    //Time Sheets - JURA144
PUBLISH MODEL REST NAME JURA148 SOURCE JURA148 RESOURCE OBJECT JRestModel    //Clientes - JURA148
PUBLISH MODEL REST NAME JURA159 SOURCE JURA159 RESOURCE OBJECT JRestModel    //Participantes - JURA159
PUBLISH MODEL REST NAME JURA202 SOURCE JURA202 RESOURCE OBJECT JRestModel    //Pré-faturas - JURA202
PUBLISH MODEL REST NAME JURA202E SOURCE JURA202E RESOURCE OBJECT JRestModel  //Pré-faturas Resumido - JURA202E
PUBLISH MODEL REST NAME JURA204 SOURCE JURA204 RESOURCE OBJECT JRestModel    //Faturas - JURA204
PUBLISH MODEL REST NAME JURA194 SOURCE JURA194 RESOURCE OBJECT JRestModel    //Países - JURA194
PUBLISH MODEL REST NAME JURA195 SOURCE JURA195 RESOURCE OBJECT Rest195       //Estados - JURA195
PUBLISH MODEL REST NAME JURA037 SOURCE JURA037 RESOURCE OBJECT JRestModel    //Tipo de Honorários - JURA037
PUBLISH MODEL REST NAME JURA039 SOURCE JURA039 RESOURCE OBJECT JRestModel    //Tipos de Atividade - JURA039
PUBLISH MODEL REST NAME JURA040 SOURCE JURA040 RESOURCE OBJECT JRestModel    //Serviços Tabelados - JURA040
PUBLISH MODEL REST NAME JURA041 SOURCE JURA041 RESOURCE OBJECT JRestModel    //Tabela de Serviços - JURA041
PUBLISH MODEL REST NAME JURA045 SOURCE JURA045 RESOURCE OBJECT JRestModel    //Tipo de Originação - JURA045
PUBLISH MODEL REST NAME JURA047 SOURCE JURA047 RESOURCE OBJECT JRestModel    //Tipo de Tabela de Serviços - JURA047
PUBLISH MODEL REST NAME JURA048 SOURCE JURA048 RESOURCE OBJECT JRestModel    //SubÁrea Jurídica - JURA048
PUBLISH MODEL REST NAME JURA050 SOURCE JURA050 RESOURCE OBJECT JRestModel    //Categoria de Participantes - JURA050
PUBLISH MODEL REST NAME JURA057 SOURCE JURA057 RESOURCE OBJECT JRestModel    //Documento E-billing - JURA057
PUBLISH MODEL REST NAME JURA058 SOURCE JURA058 RESOURCE OBJECT JRestModel    //Empresa E-billing - JURA058
PUBLISH MODEL REST NAME JURA078 SOURCE JURA078 RESOURCE OBJECT JRestModel    //Feriados - JURA078
PUBLISH MODEL REST NAME JURA111 SOURCE JURA111 RESOURCE OBJECT JRestModel    //Cotações Mensais - JURA111
PUBLISH MODEL REST NAME JURA123 SOURCE JURA123 RESOURCE OBJECT JRestModel    //Localidades - JURA123
PUBLISH MODEL REST NAME JURA164 SOURCE JURA164 RESOURCE OBJECT JRestModel    //Tipo de Prestação de Contas - JURA164
PUBLISH MODEL REST NAME JURA073 SOURCE JURA073 RESOURCE OBJECT JRestModel    //Tipo de Retorno / Situação de Cobrança - JURA073
PUBLISH MODEL REST NAME JURA140 SOURCE JURA140 RESOURCE OBJECT JRestModel    //Motivo de WO - JURA140
PUBLISH MODEL REST NAME JURA026 SOURCE JURA026 RESOURCE OBJECT JRestModel    //Anexos - Docs Jurídicos - JURA026
PUBLISH MODEL REST NAME JURA232 SOURCE JURA232 RESOURCE OBJECT JRestModel    //Contatos - JURA232
PUBLISH MODEL REST NAME JURA042 SOURCE JURA042 RESOURCE OBJECT JRestModel    //Tabela de Honorários - JURA042
PUBLISH MODEL REST NAME JURA033 SOURCE JURA033 RESOURCE OBJECT JRestModel    //Fatura Adicional - JURA033
PUBLISH MODEL REST NAME JURA235 SOURCE JURA235 RESOURCE OBJECT JRestModel    //Solicitação de Despesas - JURA235
PUBLISH MODEL REST NAME JURA146 SOURCE JURA146 RESOURCE OBJECT JRestModel    //Consulta WO - JURA146
PUBLISH MODEL REST NAME JURA238 SOURCE JURA238 RESOURCE OBJECT JRestModel    //Tabela Rateio - JURA238
PUBLISH MODEL REST NAME JURA241 SOURCE JURA241 RESOURCE OBJECT JRestModel    //Lançamentos - JURA241
PUBLISH MODEL REST NAME JURA252 SOURCE JURA252 RESOURCE OBJECT JRestModel    //Orçamentos - JURA252
PUBLISH MODEL REST NAME JURA253 SOURCE JURA253 RESOURCE OBJECT JRestModel    //Calendário Contábil - JURA253
PUBLISH MODEL REST NAME JURA069 SOURCE JURA069 RESOURCE OBJECT JRestModel    //Controle de Adiantamento - JURA069
PUBLISH MODEL REST NAME JURA255 SOURCE JURA255 RESOURCE OBJECT JRestModel    //Posição Historico CAP - JURA255
PUBLISH MODEL REST NAME JURA256 SOURCE JURA256 RESOURCE OBJECT JRestModel    //Rastreio de recebimento dos casos da fatura - JURA255
PUBLISH MODEL REST NAME JURA264 SOURCE JURA264 RESOURCE OBJECT JRestModel    //Projetos e Finalidades - JURA264
PUBLISH MODEL REST NAME JURA244 SOURCE JURA244 RESOURCE OBJECT JRestModel    //Cobrança - JURA244
PUBLISH MODEL REST NAME JURA290 SOURCE JURA290 RESOURCE OBJECT JRestModel    //Anexos (NUM) - JURA290
PUBLISH MODEL REST NAME JURA300 SOURCE JURA300 RESOURCE OBJECT JRestModel	 // Controle de versão LegalDesk - JURA300

//-------------------------------------------------------------------
/*/{Protheus.doc} Total
Método responsável retornar a quantidade total de regitros do alias.
Classe criada para tratar a exceção da SM2 sem Filial.

@return nTotal  Quantidade total de registros.

@author Rafael Telles de Macedo
@since 08/09/2015
/*/
//-------------------------------------------------------------------
Class Rest090 From JRestModel
	Method Total()
EndClass

Method Total() Class Rest090
Local nRecno := SM2->(Recno())
Local nTotal := 0

If self:Seek()
	While !SM2->(Eof())
		nTotal++
		self:Skip()
	EndDo
EndIf
SM2->(dbGoTo(nRecno))

Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} JurRest170
Publicação do modelo JURA170 - Fila de sincronização.
Vide classe JRestModel/FwRestModel.

@author Abner Oliveira / Bruno Ritter
@since 24/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Class JurRest170 From JRestModel
	Method GetData()
	Method DelData(cPK, cError)
EndClass

//-------------------------------------------------------------------
Method GetData() Class JurRest170
Local cRet := _Super:GetData()
Local nRec := 0

	If JurIsRest() .And. Self:oModel:GetOperation() == MODEL_OPERATION_VIEW
		If !NYS->(Eof()) 
			If NYS->(SimpleLock())
				nRec := NYS->(Recno())
				NYS->NYS_STATUS := "2"
				NYS->(MsRUnlock(nRec))
				NYS->(DbCommit())
			EndIf
		EndIf
	Else
		cRet := _Super:GetData()
	EndIf

Return cRet

//-------------------------------------------------------------------
Method DelData(cPK, cError) Class JurRest170
Local lRet  := .F.
Local nRec  := 0

Default cPK := ""

	If Self:Seek(cPK)
		If NYS->(SimpleLock())
			nRec := NYS->(Recno())
			NYS->(MsRUnlock(nRec))
			lRet := _Super:DelData(cPK, @cError)
		Else
			cError := i18n(STR0006, {cPK, self:cAlias}) // "O registro #1 não pode ser deletado na tabela #2."
		EndIf
	Else
		cError := i18n(STR0007, {cPK, self:cAlias}) // "Registro #1 não encontrado na tabela #2."
	EndIf

	If !lRet
		SetRestFault(404, cError)
	EndIf

Return lRet
