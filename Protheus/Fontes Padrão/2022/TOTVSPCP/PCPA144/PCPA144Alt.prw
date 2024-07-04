#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA144.CH"
#INCLUDE "PCPA144DEF.CH"

#DEFINE IND_ALT_DOC_FILIAL        1
#DEFINE IND_ALT_DOC_TPDCPA        2
#DEFINE IND_ALT_DOC_DOCPAI        3
#DEFINE IND_ALT_DOC_TRT           4
#DEFINE IND_ALT_DOC_CHAVE         5
#DEFINE IND_ALT_DOC_CHVSUB        6
#DEFINE IND_ALT_DOC_SEQUEN        7
#DEFINE IND_ALT_DOC_QTNECE_DE     8
#DEFINE IND_ALT_DOC_QTNECE_PARA   9
#DEFINE IND_ALT_DOC_QTEMPE_DE    10
#DEFINE IND_ALT_DOC_QTEMPE_PARA  11
#DEFINE IND_ALT_DOC_TAMANHO      11

#DEFINE IND_ALT_RES_SAIDAS_PARA   1
#DEFINE IND_ALT_RES_SAID_EST_PARA 2
#DEFINE IND_ALT_RES_SALDO_PARA    3
#DEFINE IND_ALT_RES_NECESS_PARA   4
#DEFINE IND_ALT_RES_TAMANHO       4

#DEFINE IND_OPCAO_VOLTAR          1
#DEFINE IND_OPCAO_DESCARTAR       2
#DEFINE IND_OPCAO_SALVAR          3

/*/{Protheus.doc} AlteracaoResultado
Classe para controle das alterações da tela de resultados
@author Marcelo Neumann
@since 21/10/2020
@version P12
/*/
CLASS AlteracaoResultado FROM LongClassName

	DATA cTicketAlt AS STRING
	DATA nOpcao     AS INTEGER
	DATA nQtdAlter  AS LOGICAL
	DATA oAltDocs   AS OBJECT
	DATA oAltResul  AS OBJECT
	DATA oDesProd   AS OBJECT
	DATA oModel     AS OBJECT
	DATA oView      AS OBJECT

	METHOD New() CONSTRUCTOR
	METHOD AbreTela()
	METHOD Destroy()
	METHOD TemAlteracao()
	METHOD SalvaAlteracao(lCarregado)
	METHOD DesfazAlteracao()
	METHOD GuardaAlteracao()
	METHOD RecuperaAlteracao(cTabela, nLinha, cPeriodo, cChaveDoc)
	METHOD GetChavDoc(nLinDoc)
	METHOD AlterouQuantidade(nNovaQtd)

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe para o armazenamento e gravação das alterações da tela de Resultados
@author Marcelo Neumann
@since 21/10/2020
@version P12
@return Self, objeto, classe AlteracaoResultado
/*/
METHOD New() CLASS AlteracaoResultado

	::cTicketAlt := ""
	::nOpcao     := 0
	::nQtdAlter  := 0
	::oAltDocs   := JsonObject():New()
	::oAltResul  := JsonObject():New()
	::oDesProd   := JsonObject():New()
	::oModel     := Nil
	::oView      := Nil

Return Self

/*/{Protheus.doc} Destroy
Método para limpar da memória os objetos utilizados pela classe
@author Marcelo Neumann
@since 21/10/2020
@version P12
@return Nil
/*/
METHOD Destroy() CLASS AlteracaoResultado

	If ::TemAlteracao()
		::DesfazAlteracao()
	EndIf

	If ::oModel <> Nil
		::oModel:DeActivate()
		::oModel:Destroy()
	EndIf
	FreeObj(::oModel)

	If ::oView <> Nil
		::oView:DeActivate()
	EndIf
	FreeObj(::oView)

Return

/*/{Protheus.doc} TemAlteracao
Indica se foi realizada alguma alteração na tela que não está salva
@author Marcelo Neumann
@since 21/10/2020
@version P12
@return lógico, indica se existe alteração não salva
/*/
METHOD TemAlteracao() CLASS AlteracaoResultado

Return ::nQtdAlter > 0

/*/{Protheus.doc} AbreTela
Método para abrir a tela com as alterações realizadas
@author Marcelo Neumann
@since 21/10/2020
@version P12
@return ::nOpcao, numérico, indica a opção selecionada na tela
/*/
METHOD AbreTela() CLASS AlteracaoResultado

	Local aArea     := GetArea()
	Local aButtons  := { {.F.,Nil    },{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
	                     {.T.,STR0214},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} } //"Salvar"
	Local oViewExec := FWViewExec():New()

	If ::oModel == Nil
 		::oModel := ModelDef(self)
	EndIf

	::nOpcao := 0

	If ::oView == Nil
		::oView := ViewDef()
		::oView:AddUserButton(STR0219, "", {|| AcaoBotao(self, IND_OPCAO_VOLTAR   )}, , , , .T.) //"Voltar"
		::oView:AddUserButton(STR0226, "", {|| AcaoBotao(self, IND_OPCAO_DESCARTAR)}, , , , .T.) //"Descartar"
	EndIf

	oViewExec:setModel(::oModel)
	oViewExec:setView(::oView)
	oViewExec:setTitle(STR0225) //"Salvar alterações"
	oViewExec:setOperation(MODEL_OPERATION_VIEW)
	oViewExec:setReduction(55)
	oViewExec:setButtons(aButtons)
	oViewExec:setCancel({|| AcaoBotao(self, IND_OPCAO_SALVAR)})
	oViewExec:openView(.F.)

	RestArea(aArea)

Return ::nOpcao

/*/{Protheus.doc} ModelDef
Definição do Modelo da tela
@author Marcelo Neumann
@since 21/10/2020
@version P12
@param oSelf, objeto, instancia da classe AlteracaoResultado
@return oModel, objeto, modelo definido
/*/
Static Function ModelDef(oSelf)

	Local oModel    := MPFormModel():New('PCPA144Alt')
	Local oStruCab  := FWFormModelStruct():New()
	Local oStruGrid := FWFormModelStruct():New()

	StrGrdMdl(@oStruGrid)

	//Cria campo para o modelo invisível
	oStruCab:AddField(STR0227, STR0227, "ARQ", "C", 1, 0, , , {}, .T., , .F., .F., .F., , ) //"Cabeçalho"

	//FLD_INVISIVEL - Modelo "invisível"
	oModel:addFields('FLD_INVISIVEL', /*cOwner*/, oStruCab, , , {|| LoadMdlFld()})
	oModel:GetModel("FLD_INVISIVEL"):SetDescription(STR0227) //"Cabeçalho"
	oModel:GetModel("FLD_INVISIVEL"):SetOnlyQuery(.T.)

	//::cModelName - Grid de resultados
	oModel:AddGrid("GRID_RESULTS", "FLD_INVISIVEL", oStruGrid, , , , , {|| LoadMdlGrd(oSelf)})
	oModel:GetModel("GRID_RESULTS"):SetDescription(STR0228) //"Alterações"
	oModel:GetModel("GRID_RESULTS"):SetOnlyQuery(.T.)
	oModel:GetModel("GRID_RESULTS"):SetOptional(.T.)

	oModel:SetDescription(STR0225) //"Salvar alterações"
	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View da tela
@author Marcelo Neumann
@since 21/10/2020
@version P12
@return oView, objeto, view definida
/*/
Static Function ViewDef()

	Local oModel    := FWLoadModel("PCPA144Alt")
	Local oStruGrid := FWFormViewStruct():New()
	Local oView     := FWFormView():New()

	StrGrdView(@oStruGrid)

	//Definições da View
	oView:SetModel(oModel)

	//V_GRID_RESULTS - View da Grid com resultado da pesquisa
	oView:AddGrid("V_GRID_RESULTS", oStruGrid, "GRID_RESULTS")

	//Relaciona a SubView com o Box
	oView:CreateHorizontalBox("BOX_GRID", 100)
	oView:SetOwnerView("V_GRID_RESULTS", 'BOX_GRID')

	//Habilita os botões padrões de filtro e pesquisa
	oView:SetViewProperty("V_GRID_RESULTS", "GRIDFILTER", {.T.})
	oView:SetViewProperty("V_GRID_RESULTS", "GRIDSEEK"  , {.T.})

Return oView

/*/{Protheus.doc} StrGrdMdl
Monta a estrutura do modelo da grid
@author Marcelo Neumann
@since 21/10/2020
@version P12
@param oStruGrid, objeto, estrutura com os campos do modelo
@return Nil
/*/
Static Function StrGrdMdl(oStruGrid)

	oStruGrid:AddField(STR0055                                , ; // [01]  C   Titulo do campo  //"Filial"
					   STR0055                                , ; // [02]  C   ToolTip do campo //"Filial"
					   "FILIAL"                               , ; // [03]  C   Id do Field
					   "C"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("HWC_FILIAL", "X3_TAMANHO"), ; // [05]  N   Tamanho do campo
					   0                                      , ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0003                                , ; // [01]  C   Titulo do campo  //"Produto"
					   STR0003                                , ; // [02]  C   ToolTip do campo //"Produto"
					   "PRODUTO"                              , ; // [03]  C   Id do Field
					   "C"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("B1_COD", "X3_TAMANHO")    , ; // [05]  N   Tamanho do campo
					   0                                      , ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0229                                , ; // [01]  C   Titulo do campo  //"Data"
					   STR0229                                , ; // [02]  C   ToolTip do campo //"Data"
					   "DATA"                                 , ; // [03]  C   Id do Field
					   "D"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("HWC_DATA", "X3_TAMANHO")  , ; // [05]  N   Tamanho do campo
					   0                                      , ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0230                                , ; // [01]  C   Titulo do campo  //"Quantidade De"
					   STR0230                                , ; // [02]  C   ToolTip do campo //"Quantidade De"
					   "NECE_DE"                              , ; // [03]  C   Id do Field
					   "N"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("HWC_QTNECE", "X3_TAMANHO"), ; // [05]  N   Tamanho do campo
					   GetSx3Cache("HWC_QTNECE", "X3_DECIMAL"), ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0231                                , ; // [01]  C   Titulo do campo  //"Quantidade Para"
					   STR0231                                , ; // [02]  C   ToolTip do campo //"Quantidade Para"
					   "NECE_PARA"                            , ; // [03]  C   Id do Field
					   "N"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("HWC_QTNECE", "X3_TAMANHO"), ; // [05]  N   Tamanho do campo
					   GetSx3Cache("HWC_QTNECE", "X3_DECIMAL"), ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0004                                , ; // [01]  C   Titulo do campo  //"Documento"
					   STR0004                                , ; // [02]  C   ToolTip do campo //"Documento"
					   "DOCPAI"                               , ; // [03]  C   Id do Field
					   "C"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("HWC_DOCPAI", "X3_TAMANHO"), ; // [05]  N   Tamanho do campo
					   0                                      , ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0155                                , ; // [01]  C   Titulo do campo  //"Opcional"
					   STR0155                                , ; // [02]  C   ToolTip do campo //"Opcional"
					   "OPCIONAL"                             , ; // [03]  C   Id do Field
					   "C"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("HWC_IDOPC", "X3_TAMANHO") , ; // [05]  N   Tamanho do campo
					   0                                      , ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0016                                , ; // [01]  C   Titulo do campo  //"Descrição"
					   STR0016                                , ; // [02]  C   ToolTip do campo //"Descrição"
					   "DESCRICAO"                            , ; // [03]  C   Id do Field
					   "C"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("B1_DESC", "X3_TAMANHO")   , ; // [05]  N   Tamanho do campo
					   0                                      , ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0049                                , ; // [01]  C   Titulo do campo  //"Tipo Documento"
					   STR0049                                , ; // [02]  C   ToolTip do campo //"Tipo Documento"
					   "TPDCPA"                               , ; // [03]  C   Id do Field
					   "C"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("HWC_TPDCPA", "X3_TAMANHO"), ; // [05]  N   Tamanho do campo
					   0                                      , ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0107                                , ; // [01]  C   Titulo do campo  //"TRT"
					   STR0107                                , ; // [02]  C   ToolTip do campo //"TRT"
					   "TRT"                                  , ; // [03]  C   Id do Field
					   "C"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("HWC_TRT", "X3_TAMANHO")   , ; // [05]  N   Tamanho do campo
					   0                                      , ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0232                                , ; // [01]  C   Titulo do campo  //"Chave"
					   STR0232                                , ; // [02]  C   ToolTip do campo //"Chave"
					   "CHAVE"                                , ; // [03]  C   Id do Field
					   "C"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("HWC_CHAVE", "X3_TAMANHO") , ; // [05]  N   Tamanho do campo
					   0                                      , ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0233                                , ; // [01]  C   Titulo do campo  //"Chave Substituição"
					   STR0233                                , ; // [02]  C   ToolTip do campo //"Chave Substituição"
					   "CHVSUB"                               , ; // [03]  C   Id do Field
					   "C"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("HWC_CHVSUB", "X3_TAMANHO"), ; // [05]  N   Tamanho do campo
					   0                                      , ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0234                                , ; // [01]  C   Titulo do campo  //"Sequencia"
					   STR0234                                , ; // [02]  C   ToolTip do campo //"Sequencia"
					   "SEQUEN"                               , ; // [03]  C   Id do Field
					   "N"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("HWC_SEQUEN", "X3_TAMANHO"), ; // [05]  N   Tamanho do campo
					   0                                      , ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0235                                , ; // [01]  C   Titulo do campo  //"Empenho Para"
					   STR0235                                , ; // [02]  C   ToolTip do campo //"Empenho Para"
					   "EMPE_PARA"                            , ; // [03]  C   Id do Field
					   "N"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("HWC_QTEMPE", "X3_TAMANHO"), ; // [05]  N   Tamanho do campo
					   GetSx3Cache("HWC_QTEMPE", "X3_DECIMAL"), ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

	oStruGrid:AddField(STR0242                                , ; // [01]  C   Titulo do campo  //"Empenho De"
					   STR0242                                , ; // [02]  C   ToolTip do campo //"Empenho De"
					   "EMPE_DE"                              , ; // [03]  C   Id do Field
					   "N"                                    , ; // [04]  C   Tipo do campo
					   GetSx3Cache("HWC_QTEMPE", "X3_TAMANHO"), ; // [05]  N   Tamanho do campo
					   GetSx3Cache("HWC_QTEMPE", "X3_DECIMAL"), ; // [06]  N   Decimal do campo
					   NIL, NIL, NIL, .F., Nil, NIL, NIL, .T.)

Return

/*/{Protheus.doc} StrGrdView
Monta a estrutura da view da grid
@author Marcelo Neumann
@since 21/10/2020
@version P12
@param oStruGrid, objeto, estrutura com os campos da view
@return Nil
/*/
Static Function StrGrdView(oStruGrid)

	Local cCBOX := GetSx3Cache("VR_TIPO","X3_CBOX")

	cCBOX += ";" + AllTrim(STR0126) + "=" + AllTrim(STR0130) //";OP=Ordem de Produção"
	cCBOX += ";" + AllTrim(STR0127) + "=" + AllTrim(STR0131) //";Pré-OP=Ordem de Produção Pré Existente"
	cCBOX += ";" + AllTrim(STR0128) + "=" + AllTrim(STR0132) //";Est.Seg.=Estoque de Segurança"
	cCBOX += ";" + AllTrim(STR0129) + "=" + AllTrim(STR0133) //";Ponto Ped.=Ponto de Pedido"
	cCBOX += ";" + "0"              + "=" + AllTrim(STR0160) //";0=Consolidado"
	cCBOX += ";" + "SUBPRD"         + "=" + AllTrim(STR0181) //";SUBPRD=Subproduto de OP"
	cCBOX += ";" + "AGL"            + "=" + AllTrim(STR0246) //";AGL=Necessidade aglutinada"
	cCBOX += ";" + "TRANF_PR"       + "=" + AllTrim(STR0256) //";TRANF_PR=Transferência de produção"
	cCBOX += ";" + "TRANF_ES"       + "=" + AllTrim(STR0267) //";TRANF_ES=Transferência de estoque"

	If nDC_FILIAL
		oStruGrid:AddField("FILIAL"                            , ; // [01]  C   Nome do Campo
						   "01"                                , ; // [02]  C   Ordem
						   STR0055                             , ; // [03]  C   Titulo do campo    //"Filial"
						   STR0055                             , ; // [04]  C   Descricao do campo //"Filial"
						   NIL, "C"                            , ; // [06]  C   Tipo do campo
						   "@S15"                              , ; // [07]  C   Picture
						   NIL, NIL, .F.                       , ; // [10]  L   Indica se o campo é alteravel
						   NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)
	EndIf

	oStruGrid:AddField("PRODUTO"                           , ; // [01]  C   Nome do Campo
					   "02"                                , ; // [02]  C   Ordem
					   STR0003                             , ; // [03]  C   Titulo do campo    //"Produto"
					   STR0003                             , ; // [04]  C   Descricao do campo //"Produto"
					   NIL, "C"                            , ; // [06]  C   Tipo do campo
					   "@S20"                              , ; // [07]  C   Picture
					   NIL, NIL, .F.                       , ; // [10]  L   Indica se o campo é alteravel
					   NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

	oStruGrid:AddField("DATA"                              , ; // [01]  C   Nome do Campo
					   "03"                                , ; // [02]  C   Ordem
					   STR0229                             , ; // [03]  C   Titulo do campo    //"Data"
					   STR0229                             , ; // [04]  C   Descricao do campo //"Data"
					   NIL, "D", Nil, NIL, NIL             , ;
					   .F.                                 , ; // [10]  L   Indica se o campo é alteravel
					   NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

	oStruGrid:AddField("NECE_DE"                           , ; // [01]  C   Nome do Campo
					   "04"                                , ; // [02]  C   Ordem
					   STR0230                             , ; // [03]  C   Titulo do campo    //"Quantidade De"
					   STR0231                             , ; // [04]  C   Descricao do campo //"Quantidade De"
					   NIL, "N"                            , ; // [06]  C   Tipo do campo
					   PesqPict('HWC','HWC_QTNECE')        , ; // [07]  C   Picture
					   NIL, NIL, .F.                       , ; // [10]  L   Indica se o campo é alteravel
					   NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

	oStruGrid:AddField("NECE_PARA"                         , ; // [01]  C   Nome do Campo
					   "05"                                , ; // [02]  C   Ordem
					   STR0231                             , ; // [03]  C   Titulo do campo    //"Quantidade Para"
					   STR0231                             , ; // [04]  C   Descricao do campo //"Quantidade Para"
					   NIL, "N"                            , ; // [06]  C   Tipo do campo
					   PesqPict('HWC','HWC_QTNECE')        , ; // [07]  C   Picture
					   NIL, NIL, .F.                       , ; // [10]  L   Indica se o campo é alteravel
					   NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

	oStruGrid:AddField("DOCPAI"                            , ; // [01]  C   Nome do Campo
					   "06"                                , ; // [02]  C   Ordem
					   STR0004                             , ; // [03]  C   Titulo do campo    //"Documento"
					   STR0004                             , ; // [04]  C   Descricao do campo //"Documento"
					   NIL, "C"                            , ; // [06]  C   Tipo do campo
					   "@S20"                              , ; // [07]  C   Picture
					   NIL, NIL, .F.                       , ; // [10]  L   Indica se o campo é alteravel
					   NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

	oStruGrid:AddField("OPCIONAL"                          , ; // [01]  C   Nome do Campo
					   "07"                                , ; // [02]  C   Ordem
					   STR0155                             , ; // [03]  C   Titulo do campo    //"Opcional"
					   STR0155                             , ; // [04]  C   Descricao do campo //"Opcional"
					   NIL, "C"                            , ; // [06]  C   Tipo do campo
					   "@S20"                              , ; // [07]  C   Picture
					   NIL, NIL, .F.                       , ; // [10]  L   Indica se o campo é alteravel
					   NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

	oStruGrid:AddField("DESCRICAO"                         , ; // [01]  C   Nome do Campo
					   "08"                                , ; // [02]  C   Ordem
					   STR0016                             , ; // [03]  C   Titulo do campo    //"Descrição"
					   STR0016                             , ; // [04]  C   Descricao do campo //"Descrição"
					   NIL, "C"                            , ; // [06]  C   Tipo do campo
					   "@S20"                              , ; // [07]  C   Picture
					   NIL, NIL, .F.                       , ; // [10]  L   Indica se o campo é alteravel
					   NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

	oStruGrid:AddField("TPDCPA"                            , ; // [01]  C   Nome do Campo
					   "09"                                , ; // [02]  C   Ordem
					   STR0049                             , ; // [03]  C   Titulo do campo    //"Tipo Documento"
					   STR0049                             , ; // [04]  C   Descricao do campo //"Tipo Documento"
					   NIL, "C"                            , ; // [06]  C   Tipo do campo
					   "@S20"                              , ; // [07]  C   Picture
					   NIL, NIL, .F.                       , ; // [10]  L   Indica se o campo é alteravel
					   NIL, NIL                            , ;
					   StrTokArr(cCBOX, ";")               , ; // [13]  A   Array com os Valores do combo
					   NIL, NIL, .T., NIL, NIL)

	oStruGrid:AddField("TRT"                               , ; // [01]  C   Nome do Campo
					   "10"                                , ; // [02]  C   Ordem
					   STR0107                             , ; // [03]  C   Titulo do campo    //"TRT"
					   STR0107                             , ; // [04]  C   Descricao do campo //"TRT"
					   NIL, "C"                            , ; // [06]  C   Tipo do campo
					   "@S20"                              , ; // [07]  C   Picture
					   NIL, NIL, .F.                       , ; // [10]  L   Indica se o campo é alteravel
					   NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

	oStruGrid:AddField("CHAVE"                             , ; // [01]  C   Nome do Campo
					   "11"                                , ; // [02]  C   Ordem
					   STR0232                             , ; // [03]  C   Titulo do campo    //"Chave"
					   STR0232                             , ; // [04]  C   Descricao do campo //"Chave"
					   NIL, "C"                            , ; // [06]  C   Tipo do campo
					   "@S20"                              , ; // [07]  C   Picture
					   NIL, NIL, .F.                       , ; // [10]  L   Indica se o campo é alteravel
					   NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

	oStruGrid:AddField("CHVSUB"                            , ; // [01]  C   Nome do Campo
					   "12"                                , ; // [02]  C   Ordem
					   STR0233                             , ; // [03]  C   Titulo do campo    //"Chave Substituição"
					   STR0233                             , ; // [04]  C   Descricao do campo //"Chave Substituição"
					   NIL, "C"                            , ; // [06]  C   Tipo do campo
					   "@S20"                              , ; // [07]  C   Picture
					   NIL, NIL, .F.                       , ; // [10]  L   Indica se o campo é alteravel
					   NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

	oStruGrid:AddField("SEQUEN"                            , ; // [01]  C   Nome do Campo
					   "13"                                , ; // [02]  C   Ordem
					   STR0234                             , ; // [03]  C   Titulo do campo    //"Sequencia"
					   STR0234                             , ; // [04]  C   Descricao do campo //"Sequencia"
					   NIL, "N"                            , ; // [06]  C   Tipo do campo
					   "@E 9999999999"                     , ; // [07]  C   Picture
					   NIL, NIL, .F.                       , ; // [10]  L   Indica se o campo é alteravel
					   NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

Return

/*/{Protheus.doc} LoadMdlFld
Carga do modelo mestre (invisível)
@author Marcelo Neumann
@since 21/10/2020
@version P12
@return aLoad, array, array de load do modelo preenchido
/*/
Static Function LoadMdlFld()

	Local aLoad := {}

	aAdd(aLoad, {"A"}) //dados
	aAdd(aLoad, 1    ) //recno

Return aLoad

/*/{Protheus.doc} LoadMdlGrd
Carga do modelo da Grid com as alterações
@author Marcelo Neumann
@since 21/10/2020
@version P12
@param oSelf, objeto, instância da classe AlteracaoResultado
@return aProdsAlt, array, array de load do modelo preenchido
/*/
Static Function LoadMdlGrd(oSelf)

	Local aNamesDoc := {}
	Local aNamesOpc := {}
	Local aNamesPer := {}
	Local aNamesPrd := oSelf:oAltDocs:GetNames()
	Local aProdsAlt := {}
	Local nIndDoc   := 0
	Local nIndOpc   := 0
	Local nIndPer   := 0
	Local nIndPrd   := 0
	Local nTotDoc   := 0
	Local nTotPer   := 0
	Local nTotPrd   := Len(aNamesPrd)
	Local nTotOpc   := 0

	For nIndPrd := 1 To nTotPrd
		If oSelf:oAltDocs[aNamesPrd[nIndPrd]] == Nil
			Loop
		EndIf
		aNamesOpc := oSelf:oAltDocs[aNamesPrd[nIndPrd]]:GetNames()
		nTotOpc   := Len(aNamesOpc)

		For nIndOpc := 1 To nTotOpc
			If oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]] == Nil
				Loop
			EndIf
			aNamesPer := oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]]:GetNames()
			nTotPer   := Len(aNamesPer)

			For nIndPer := 1 To nTotPer
				If oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]] == Nil
					Loop
				EndIf
				aNamesDoc := oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]]:GetNames()
				nTotDoc   := Len(aNamesDoc)

				For nIndDoc := 1 To nTotDoc
					If oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]][aNamesDoc[nIndDoc]] == Nil
						Loop
					EndIf
					aAdd(aProdsAlt, {0, {oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]][aNamesDoc[nIndDoc]][IND_ALT_DOC_FILIAL]         , ;
										 AllTrim(aNamesPrd[nIndPrd])                                                                                                , ;
										 SToD(aNamesPer[nIndPer])                                                                                                   , ;
										 oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]][aNamesDoc[nIndDoc]][IND_ALT_DOC_QTNECE_DE]      , ;
										 oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]][aNamesDoc[nIndDoc]][IND_ALT_DOC_QTNECE_PARA]    , ;
										 AllTrim(oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]][aNamesDoc[nIndDoc]][IND_ALT_DOC_DOCPAI]), ;
										 AllTrim(aNamesOpc[nIndOpc])                                                                                                , ;
										 AllTrim(P144DesPrd(aNamesPrd[nIndPrd]))                                                                                    , ;
										 AllTrim(oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]][aNamesDoc[nIndDoc]][IND_ALT_DOC_TPDCPA]), ;
										 AllTrim(oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]][aNamesDoc[nIndDoc]][IND_ALT_DOC_TRT])   , ;
										 AllTrim(oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]][aNamesDoc[nIndDoc]][IND_ALT_DOC_CHAVE]) , ;
										 AllTrim(oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]][aNamesDoc[nIndDoc]][IND_ALT_DOC_CHVSUB]), ;
										 oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]][aNamesDoc[nIndDoc]][IND_ALT_DOC_SEQUEN]         , ;
										 oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]][aNamesDoc[nIndDoc]][IND_ALT_DOC_QTEMPE_PARA]    , ;
										 oSelf:oAltDocs[aNamesPrd[nIndPrd]][aNamesOpc[nIndOpc]][aNamesPer[nIndPer]][aNamesDoc[nIndDoc]][IND_ALT_DOC_QTEMPE_DE]}})
				Next nIndDoc
			Next nIndPer
		Next nIndOpc
	Next nIndPrd

	aSort(aProdsAlt, , , {|x,y| x[1] < y[1]})

Return aProdsAlt

/*/{Protheus.doc} AcaoBotao
Função chamada ao pressionar algum botão da tela
@author Marcelo Neumann
@since 21/10/2020
@version P12
@param 01 oSelf , objeto  , classe da tela de consulta
@param 02 nOpcao, numérico, indicador do botão clicado
@return lFechaTela, lógico, indicador para sempre fechar a tela
/*/
Static Function AcaoBotao(oSelf, nOpcao)

	Local lFechaTela := .F.

	oSelf:nOpcao := nOpcao
	If nOpcao == IND_OPCAO_SALVAR
		If oSelf:SalvaAlteracao(.T.)
			lFechaTela := .T.
			ApMsgInfo(STR0236, STR0237) //"Alterações salvas com sucesso.", "Processo finalizado"
		EndIf
	Else
		If nOpcao == IND_OPCAO_DESCARTAR
			oSelf:DesfazAlteracao()
		EndIf
		oSelf:oView:CloseOwner()
	EndIf

Return lFechaTela

/*/{Protheus.doc} SalvaAlteracao
Método para salvar as alterações no banco (API)
@author Marcelo Neumann
@since 21/10/2020
@version P12
@param lCarregado, lógico, indica se o modelo já está carregado com as alterações
@return lRet     , lógico, indicador para sempre fechar a tela
/*/
METHOD SalvaAlteracao(lCarregado) CLASS AlteracaoResultado

	Local aReturn := {}
	Local lRet    := .T.
	Default lCarregado := .F.

	If ::TemAlteracao()
		FWMsgRun( , {|| aReturn := SalvaAlter(Self, lCarregado)}, STR0164, STR0238) //"Aguarde...", "Salvando as alterações..."

		If aReturn[1] >= 400
			lRet := .F.
			Help( ,  , "Help", , STR0239, 1, 0, , , , , , {aReturn[2]}) //"Ocorreu um erro ao salvar as alterações."
		Else
			//Limpa os dados das alterações
			::DesfazAlteracao()

			::oModel:DeActivate()
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} SalvaAlter
Método chamado ao pressionar algum botão da tela
@author Marcelo Neumann
@since 21/10/2020
@version P12
@param 01 oSelf     , objeto, instância da classe atual
@param 02 lCarregado, lógico, indica se o modelo já está carregado com as alterações
@return aReturn     , array , array com o retorno da API
/*/
Static Function SalvaAlter(oSelf, lCarregado)
	Local aBranches := {}
	Local aIdOpc    := {}
	Local aPeriod   := {}
	Local aProdsAlt := {}
	Local aReturn   := {}
	Local lRet      := .T.
	Local nIndBran  := 0
	Local nIndDoc   := 0
	Local nIndPer   := 0
	Local nIndProd  := 0
	Local nIndOpc   := 0
	Local nTotal    := 0
	Local nTotBran  := 0
	Local nTotPer   := 0
	Local nTotProd  := 0
	Local nTotOpc   := 0
	Local oBody     := JsonObject():New()

	//Carrega o modelo com as alterações
	If !lCarregado
		oSelf:oModel := ModelDef(oSelf)
		oSelf:oModel:Activate()
	EndIf

	//Prepara a alteração da HWC
	nTotal         := oSelf:oModel:GetModel("GRID_RESULTS"):Length()
	oBody          := JsonObject():New()
	oBody["items"] := Array(nTotal)
	oBodyAlt          := JsonObject():New()
	oBodyAlt["items"] := Array(nTotal)

	For nIndDoc := 1 To nTotal
		oBody["items"][nIndDoc] := JsonObject():New()
		oBody["items"][nIndDoc]["branchId"           ] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("FILIAL"    , nIndDoc)
		oBody["items"][nIndDoc]["ticket"             ] := oSelf:cTicketAlt
		oBody["items"][nIndDoc]["parentDocumentType" ] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("TPDCPA"    , nIndDoc)
		oBody["items"][nIndDoc]["parentDocument"     ] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("DOCPAI"    , nIndDoc)
		oBody["items"][nIndDoc]["sequenceInStructure"] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("TRT"       , nIndDoc)
		oBody["items"][nIndDoc]["componentCode"      ] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("PRODUTO"   , nIndDoc)
		oBody["items"][nIndDoc]["recordKey"          ] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("CHAVE"     , nIndDoc)
		oBody["items"][nIndDoc]["substitutionKey"    ] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("CHVSUB"    , nIndDoc)
		oBody["items"][nIndDoc]["breakupSequence"    ] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("SEQUEN"    , nIndDoc)
		oBody["items"][nIndDoc]["quantityNecessity"  ] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("NECE_PARA" , nIndDoc)
		oBody["items"][nIndDoc]["alocationQuantity"  ] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("EMPE_PARA" , nIndDoc)

		If oBody["items"][nIndDoc]["parentDocumentType"] == "1"
			oBody["items"][nIndDoc]["parentDocumentType"] := "3"
		ElseIf oBody["items"][nIndDoc]["parentDocumentType"] == "3"
			oBody["items"][nIndDoc]["parentDocumentType"] := "1"
		EndIf

		//Prepara o log de alteração para gravar a SMG
		oBodyAlt["items"][nIndDoc] := JsonObject():New()
		oBodyAlt["items"][nIndDoc]["branchId"             ] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("FILIAL"    , nIndDoc)
		oBodyAlt["items"][nIndDoc]["ticket"               ] := oSelf:cTicketAlt
		oBodyAlt["items"][nIndDoc]["necessityDate"        ] := DToS(oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("DATA"    , nIndDoc))
		oBodyAlt["items"][nIndDoc]["documentType"         ] := oBody["items"][nIndDoc]["parentDocumentType" ]
		oBodyAlt["items"][nIndDoc]["document"             ] := oBody["items"][nIndDoc]["parentDocument"     ]
		oBodyAlt["items"][nIndDoc]["componentCode"        ] := oBody["items"][nIndDoc]["componentCode"      ]
		oBodyAlt["items"][nIndDoc]["sequenceInStructure"  ] := oBody["items"][nIndDoc]["sequenceInStructure"]
		oBodyAlt["items"][nIndDoc]["quantityNecessityFrom"] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("NECE_DE" , nIndDoc)
		oBodyAlt["items"][nIndDoc]["quantityNecessityTo"  ] := oBody["items"][nIndDoc]["quantityNecessity"  ]
		oBodyAlt["items"][nIndDoc]["alocationQuantityFrom"] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("EMPE_DE" , nIndDoc)
		oBodyAlt["items"][nIndDoc]["alocationQuantityTo"  ] := oBody["items"][nIndDoc]["alocationQuantity"  ]
		oBodyAlt["items"][nIndDoc]["recordKey"            ] := oBody["items"][nIndDoc]["recordKey"          ]
		oBodyAlt["items"][nIndDoc]["substitutionKey"      ] := oBody["items"][nIndDoc]["substitutionKey"    ]
		oBodyAlt["items"][nIndDoc]["breakupSequence"      ] := oBody["items"][nIndDoc]["breakupSequence"    ]
		oBodyAlt["items"][nIndDoc]["optionalId"           ] := oSelf:oModel:GetModel("GRID_RESULTS"):GetValue("OPCIONAL", nIndDoc)
		oBodyAlt["items"][nIndDoc]["user"                 ] := RetCodUsr()
		oBodyAlt["items"][nIndDoc]["logDate"              ] := DToS(Date())
		oBodyAlt["items"][nIndDoc]["logTime"              ] := Time()
	Next nIndDoc

	BEGIN TRANSACTION
		aReturn := MrpPostHWC(oBody)
		If aReturn[1] >= 400
			lRet := .F.
		EndIf

		FreeObj(oBody)
		oBody := Nil

		If lRet
			If FWAliasInDic("SMG", .F.)
				//Grava o log de alteração na SMG
				aReturn := MrpPostSMG(oBodyAlt)
				If aReturn[1] >= 400
					lRet := .F.
				EndIf
			EndIf

			If lRet
				//Prepara a alteração da HWB
				nIndDoc        := 0
				oBody          := JsonObject():New()
				oBody["items"] := {}
				aProdsAlt      := oSelf:oAltResul:GetNames()
				nTotProd       := Len(aProdsAlt)

				For nIndProd := 1 To nTotProd
					If oSelf:oAltResul[aProdsAlt[nIndProd]] == Nil
						Loop
					EndIf
					aIdOpc  := oSelf:oAltResul[aProdsAlt[nIndProd]]:GetNames()
					nTotOpc := Len(aIdOpc)

					For nIndOpc := 1 To nTotOpc
						If oSelf:oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]] == Nil
							Loop
						EndIf
						aPeriod := oSelf:oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]]:GetNames()
						nTotPer := Len(aPeriod)

						For nIndPer := 1 To nTotPer
							If oSelf:oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]] == Nil
								Loop
							EndIf
							aBranches := oSelf:oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]]:GetNames()
							nTotBran  := Len(aBranches)

							For nIndBran := 1 To nTotBran
								If oSelf:oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]][aBranches[nIndBran]] == Nil
									Loop
								EndIf

								aAdd(oBody["items"], JsonObject():New())
								nIndDoc++
								oBody["items"][nIndDoc]["branchId"         ] := aBranches[nIndBran]
								oBody["items"][nIndDoc]["ticket"           ] := oSelf:cTicketAlt
								oBody["items"][nIndDoc]["necessityDate"    ] := SubStr(aPeriod[nIndPer],1,4) + "-" + SubStr(aPeriod[nIndPer],5,2) + "-" + SubStr(aPeriod[nIndPer],7,2)
								oBody["items"][nIndDoc]["product"          ] := aProdsAlt[nIndProd]
								oBody["items"][nIndDoc]["optionalId"       ] := aIdOpc[nIndOpc]
								oBody["items"][nIndDoc]["outFlows"         ] := oSelf:oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]][aBranches[nIndBran]][IND_ALT_RES_SAIDAS_PARA  ]
								oBody["items"][nIndDoc]["structureOutFlows"] := oSelf:oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]][aBranches[nIndBran]][IND_ALT_RES_SAID_EST_PARA]
								oBody["items"][nIndDoc]["finalBalance"     ] := oSelf:oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]][aBranches[nIndBran]][IND_ALT_RES_SALDO_PARA   ]
								oBody["items"][nIndDoc]["necessityQuantity"] := oSelf:oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]][aBranches[nIndBran]][IND_ALT_RES_NECESS_PARA  ]
							Next nIndBran
						Next nIndPer
					Next nIndOpc
				Next nIndProd

				aReturn := MrpPostHWB(oBody)
				If aReturn[1] >= 400
					lRet := .F.
				EndIf

				FreeObj(oBody)
				oBody := Nil
			EndIf
		EndIf

		FreeObj(oBodyAlt)
		oBodyAlt := Nil

		If !lRet
			DisarmTransaction()
		EndIf
	END TRANSACTION

Return aReturn

/*/{Protheus.doc} DesfazAlteracao
Descarta as alterações realizadas na tela
@author marcelo.neumann
@since 21/10/2020
@version P12
@return Nil
/*/
METHOD DesfazAlteracao() CLASS AlteracaoResultado
	Local aBranches := {}
	Local aChaveDoc := {}
	Local aIdOpc    := {}
	Local aPeriod   := {}
	Local aProdsAlt := {}
	Local nIndBran  := 0
	Local nIndChv   := 0
	Local nIndOpc   := 0
	Local nIndPer   := 0
	Local nIndProd  := 0
	Local nTotBran  := 0
	Local nTotChv   := 0
	Local nTotPer   := 0
	Local nTotProd  := 0
	Local nTotOpc   := 0

	If ::TemAlteracao()
		//RESULTADOS
		aProdsAlt := ::oAltResul:GetNames()
		nTotProd  := Len(aProdsAlt)
		For nIndProd := 1 To nTotProd
			If ::oAltResul[aProdsAlt[nIndProd]] == Nil
				Loop
			EndIf
			aIdOpc  := ::oAltResul[aProdsAlt[nIndProd]]:GetNames()
			nTotOpc := Len(aIdOpc)

			For nIndOpc := 1 To nTotOpc
				If ::oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]] == Nil
					Loop
				EndIf
				aPeriod := ::oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]]:GetNames()
				nTotPer := Len(aPeriod)

				For nIndPer := 1 To nTotPer
					If ::oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]] == Nil
						Loop
					EndIf
					aBranches := ::oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]]:GetNames()
					nTotBran  := Len(aBranches)

					For nIndBran := 1 To nTotBran
						If ::oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]][aBranches[nIndBran]] == Nil
							Loop
						EndIf

						aSize(::oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]][aBranches[nIndBran]], 0)
					Next nIndBran

					FreeObj(::oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]])
				Next nIndPer

				FreeObj(::oAltResul[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]])
			Next nIndOpc

			FreeObj(::oAltResul[aProdsAlt[nIndProd]])
		Next nIndProd

		FreeObj(::oAltResul)

		//DOCUMENTOS
		aProdsAlt := ::oAltDocs:GetNames()
		nTotProd  := Len(aProdsAlt)
		For nIndProd := 1 To nTotProd
			If ::oAltDocs[aProdsAlt[nIndProd]] == Nil
				Loop
			EndIf
			aIdOpc  := ::oAltDocs[aProdsAlt[nIndProd]]:GetNames()
			nTotOpc := Len(aIdOpc)

			For nIndOpc := 1 To nTotOpc
				If ::oAltDocs[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]] == Nil
					Loop
				EndIf
				aPeriod := ::oAltDocs[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]]:GetNames()
				nTotPer := Len(aPeriod)

				For nIndPer := 1 To nTotPer
					If ::oAltDocs[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]] == Nil
						Loop
					EndIf
					aChaveDoc := ::oAltDocs[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]]:GetNames()
					nTotChv   := Len(aChaveDoc)

					For nIndChv := 1 To nTotChv
						If ::oAltDocs[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]][aChaveDoc[nIndChv]] == Nil
							Loop
						EndIf
						aSize(::oAltDocs[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]][aChaveDoc[nIndChv]], 0)
					Next nIndChv

					FreeObj(::oAltDocs[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]][aPeriod[nIndPer]])
				Next nIndPer

				FreeObj(::oAltDocs[aProdsAlt[nIndProd]][aIdOpc[nIndOpc]])
			Next nIndOpc

			FreeObj(::oAltDocs[aProdsAlt[nIndProd]])
		Next nIndProd

		FreeObj(::oAltDocs)

		::oAltResul := JsonObject():New()
		::oAltDocs  := JsonObject():New()
		::nQtdAlter := 0

		//Desabilita o botão "Salvar"
		If oButton7 <> Nil
			oButton7:Disable()
		EndIf
	EndIf

	::cTicketAlt := ""

Return

/*/{Protheus.doc} GuardaAlteracao
Armazena a alteração nas propriedades de controle de alterações
@author marcelo.neumann
@since 21/10/2020
@version P12
@return Nil
/*/
METHOD GuardaAlteracao() CLASS AlteracaoResultado
	Local nDiferAnt  := 0
	Local nDiferDep  := 0
	Local nLinDoc    := oBrwDocs:nAt
	Local nLinRes    := oBrwResult:nAt
	Local cChaveDoc  := ::GetChavDoc(nLinDoc)
	Local cBranch    := IIf(nDC_FILIAL > 0, aDocs[nLinDoc][nDC_FILIAL], xFilial("HWB"))
	Local cIdOpc     := aProdutos[oBrwProd:nAt][IND_APRODUTOS_OPCIONAL]
	Local cPeriodo   := DToS(aResults[nLinRes][nRE_DATA])
	Local cProduto   := aProdutos[oBrwProd:nAt][IND_APRODUTOS_CODIGO]

	::cTicketAlt := cTicket

	//DOCUMENTOS (HWC)
	If ::oAltDocs[cProduto] == Nil
		::oAltDocs[cProduto] := JsonObject():New()
	EndIf
	If ::oAltDocs[cProduto][cIdOpc] == Nil
		::oAltDocs[cProduto][cIdOpc] := JsonObject():New()
	EndIf
	If ::oAltDocs[cProduto][cIdOpc][cPeriodo] == Nil
		::oAltDocs[cProduto][cIdOpc][cPeriodo] := JsonObject():New()
	EndIf
	If ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc] == Nil
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc]                          := Array(IND_ALT_DOC_TAMANHO)
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_FILIAL]      := IIf(nDC_FILIAL > 0, aDocs[nLinDoc][nDC_FILIAL], xFilial("HWC"))
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_TPDCPA]      := aDocs[nLinDoc][nDC_TPDCPA]
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_DOCPAI]      := aDocs[nLinDoc][nDC_DOCPAI]
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_TRT]         := aDocs[nLinDoc][nDC_TRT]
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_CHAVE]       := aDocs[nLinDoc][nDC_CHAVE]
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_CHVSUB]      := aDocs[nLinDoc][nDC_CHVSUB]
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_SEQUEN]      := aDocs[nLinDoc][nDC_SEQUEN]
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTNECE_DE]   := aDocs[nLinDoc][nDC_QTNECE]
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTNECE_PARA] := aDocs[nLinDoc][nDC_QTNECE]
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTEMPE_DE]   := aDocs[nLinDoc][nDC_QTEMPE]
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTEMPE_PARA] := aDocs[nLinDoc][nDC_QTEMPE]
		::nQtdAlter++
	EndIf

	//Calcula a diferença antes da alteração
	nDiferAnt := ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTNECE_PARA] - ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTNECE_DE]

	::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTNECE_PARA] := M->HWC_QTNECE

	//Calcula a diferença após a alteração
	nDiferDep := ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTNECE_PARA] - ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTNECE_DE]

	If ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTEMPE_DE] > 0
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTEMPE_PARA] := ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTEMPE_DE] + nDiferDep
		::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTEMPE_PARA] := Round(::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTEMPE_PARA],GetSx3Cache("HWC_QTEMPE","X3_DECIMAL"))
	EndIf

	//RESULTADOS (HWB)
	If ::oAltResul[cProduto] == Nil
		::oAltResul[cProduto] := JsonObject():New()
	EndIf
	If ::oAltResul[cProduto][cIdOpc] == Nil
		::oAltResul[cProduto][cIdOpc] := JsonObject():New()
	EndIf
	If ::oAltResul[cProduto][cIdOpc][cPeriodo] == Nil
		::oAltResul[cProduto][cIdOpc][cPeriodo] := JsonObject():New()
	EndIf
	If ::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch] == Nil
		::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch]                            := Array(IND_ALT_RES_TAMANHO)
		::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch][IND_ALT_RES_SAIDAS_PARA  ] := aResults[nLinRes][nRE_SAIDAS]
		::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch][IND_ALT_RES_SAID_EST_PARA] := aResults[nLinRes][nRE_SAIEST]
		::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch][IND_ALT_RES_SALDO_PARA   ] := aResults[nLinRes][nRE_SALDOF]
		::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch][IND_ALT_RES_NECESS_PARA  ] := aResults[nLinRes][nRE_NECESS]
	EndIf

	If ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_TPDCPA] == "3" //Plano Mestre
		::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch][IND_ALT_RES_SAIDAS_PARA] += nDiferDep - nDiferAnt
		::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch][IND_ALT_RES_NECESS_PARA] += nDiferDep - nDiferAnt

	ElseIf ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_TPDCPA] == STR0128 //"Est.Seg."
		::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch][IND_ALT_RES_SALDO_PARA ] -= nDiferDep - nDiferAnt
		::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch][IND_ALT_RES_NECESS_PARA] += nDiferDep - nDiferAnt

	ElseIf ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_TPDCPA] == STR0129 //"Ponto Ped."
		::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch][IND_ALT_RES_NECESS_PARA] += nDiferDep - nDiferAnt

	Else
		::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch][IND_ALT_RES_SALDO_PARA ] -= nDiferDep - nDiferAnt
		::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch][IND_ALT_RES_NECESS_PARA] += nDiferDep - nDiferAnt

		If ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTEMPE_DE] == 0
			::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch][IND_ALT_RES_SAIDAS_PARA]   += nDiferDep - nDiferAnt
		Else
			::oAltResul[cProduto][cIdOpc][cPeriodo][cBranch][IND_ALT_RES_SAID_EST_PARA] += nDiferDep - nDiferAnt
		EndIf
	EndIf

	::RecuperaAlteracao("RES", nLinRes, cPeriodo)
	::RecuperaAlteracao("DOC", nLinDoc, cPeriodo, cChaveDoc)

	//Verifica se a alteração foi desfeita
	If ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTNECE_DE] == ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTNECE_PARA]
		::nQtdAlter--
		aSize(::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc], 0)
		FreeObj(::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc])
	EndIf

Return

/*/{Protheus.doc} RecuperaAlteracao
Recupera as alterações realizadas em tela atriubuindo na grid
@author marcelo.neumann
@since 21/10/2020
@version P12
@param 01 cTabela  , caracter, tabela a ser recuperada
@param 02 nLinha   , caracter, linha a ser recuperada
@param 03 cPeriodo , caracter, período a ser recuperado
@param 04 cChaveDoc, caracter, documento a ser recuperado
/*/
METHOD RecuperaAlteracao(cTabela, nLinha, cPeriodo, cChaveDoc) CLASS AlteracaoResultado
	Local aBranches := {}
	Local cIdOpc    := aProdutos[oBrwProd:nAt][IND_APRODUTOS_OPCIONAL]
	Local cProduto  := aProdutos[oBrwProd:nAt][IND_APRODUTOS_CODIGO]
	Local nIndex    := 0

	If ::TemAlteracao()
		If cTabela == "RES"
			If ::oAltResul[cProduto]                   <> NIL .And. ;
			   ::oAltResul[cProduto][cIdOpc]           <> NIL .And. ;
			   ::oAltResul[cProduto][cIdOpc][cPeriodo] <> NIL

				aResults[nLinha][nRE_SAIDAS] := 0
				aResults[nLinha][nRE_SAIEST] := 0
				aResults[nLinha][nRE_SALDOF] := 0
				aResults[nLinha][nRE_NECESS] := 0

				aBranches := ::oAltResul[cProduto][cIdOpc][cPeriodo]:GetNames()
				nTotal    := Len(aBranches)

				For nIndex := 1 To nTotal
					aResults[nLinha][nRE_SAIDAS] += ::oAltResul[cProduto][cIdOpc][cPeriodo][aBranches[nIndex]][IND_ALT_RES_SAIDAS_PARA  ]
					aResults[nLinha][nRE_SAIEST] += ::oAltResul[cProduto][cIdOpc][cPeriodo][aBranches[nIndex]][IND_ALT_RES_SAID_EST_PARA]
					aResults[nLinha][nRE_SALDOF] += ::oAltResul[cProduto][cIdOpc][cPeriodo][aBranches[nIndex]][IND_ALT_RES_SALDO_PARA   ]
					aResults[nLinha][nRE_NECESS] += ::oAltResul[cProduto][cIdOpc][cPeriodo][aBranches[nIndex]][IND_ALT_RES_NECESS_PARA  ]
				Next nIndex
			EndIf

		ElseIf cTabela == "DOC"
			If ::oAltDocs[cProduto]                              <> NIL .And. ;
			   ::oAltDocs[cProduto][cIdOpc]                      <> NIL .And. ;
			   ::oAltDocs[cProduto][cIdOpc][cPeriodo]            <> NIL .And. ;
			   ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc] <> NIL

				aDocs[nLinha][nDC_QTEMPE] := ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTEMPE_PARA]
				aDocs[nLinha][nDC_QTNECE] := ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTNECE_PARA]
			EndIf
		EndIf
	EndIf

Return

/*/{Protheus.doc} AlterouQuantidade
Indica se a quantidade foi alterada
@author marcelo.neumann
@since 21/10/2020
@version P12
@param nNovaQtd , caracter, quantidade informada
@return lAlterou, lógico  , indica se a quantidade foi alterada
/*/
METHOD AlterouQuantidade(nNovaQtd) CLASS AlteracaoResultado

	Local cChaveDoc := ::GetChavDoc(oBrwDocs:nAt)
	Local cIdOpc    := aProdutos[oBrwProd:nAt][IND_APRODUTOS_OPCIONAL]
	Local cPeriodo  := DToS(aResults[oBrwResult:nAt][nRE_DATA])
	Local cProduto  := aProdutos[oBrwProd:nAt][IND_APRODUTOS_CODIGO]
	Local lAlterou  := .T.

	If ::oAltDocs[cProduto]                              <> NIL .And. ;
	   ::oAltDocs[cProduto][cIdOpc]                      <> NIL .And. ;
	   ::oAltDocs[cProduto][cIdOpc][cPeriodo]            <> NIL .And. ;
	   ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc] <> NIL

		If ::oAltDocs[cProduto][cIdOpc][cPeriodo][cChaveDoc][IND_ALT_DOC_QTNECE_PARA] == nNovaQtd
			lAlterou := .F.
		EndIf
	EndIf

Return lAlterou

/*/{Protheus.doc} GetChavDoc
Retorna a chave do documento
@author marcelo.neumann
@since 21/10/2020
@version P12
@param nLinDoc, numérico, linha do documento a ser gerado a chave
@return cChave, caracter, chave do documento concatenada como string
/*/
METHOD GetChavDoc(nLinDoc) CLASS AlteracaoResultado

	Local cChave := ""

	If nDC_FILIAL > 0
		cChave += aDocs[nLinDoc][nDC_FILIAL]
	EndIf
	cChave += aDocs[nLinDoc][nDC_TPDCPA] + ;
	          aDocs[nLinDoc][nDC_DOCPAI] + ;
	          aDocs[nLinDoc][nDC_TRT   ] + ;
	          aDocs[nLinDoc][nDC_CHAVE ] + ;
	          aDocs[nLinDoc][nDC_CHVSUB] + ;
	          StrZero(aDocs[nLinDoc][nDC_SEQUEN],10)

Return cChave
