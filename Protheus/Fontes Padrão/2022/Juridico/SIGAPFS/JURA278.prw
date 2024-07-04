#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA278.CH"


Static _lFinQRCode
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA278
Modelo de Titulos a pagar

ESTE MODELO É SÓ UTILIZADO PARA CONSULTAR OS DADOS DA SE2,
VINCULANDO A FK7 e A FKF, NÃO É PARA UTILIZAR PARA CADASTRAR. 
ELE NÃO RODA OS VALIDS QUE EXISTEM NO EXECAUTO DA FINA050

@author Willian Kazahaya
@since  08/02/2021
/*/
//-------------------------------------------------------------------
Function JURA278()
	Local oBrowse := FWMBrowse():New()
	
	oBrowse:SetDescription(STR0001) //"Contas a Pagar - PFS"
	oBrowse:SetAlias("SE2")
	oBrowse:SetLocate()
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura do menu
        [n,1] Nome a aparecer no cabecalho
        [n,2] Nome da Rotina associada
        [n,3] Reservado
        [n,4] Tipo de Transação a ser efetuada:
            1 - Pesquisa e Posiciona em um Banco de Dados
            2 - Simplesmente Mostra os Campos
            3 - Inclui registros no Bancos de Dados
            4 - Altera o registro corrente
            5 - Remove o registro corrente do Banco de Dados
        [n,5] Nivel de acesso
        [n,6] Habilita Menu Funcional

ESTE MODELO É SÓ UTILIZADO PARA CONSULTAR OS DADOS DA SE2,
VINCULANDO A FK7 e A FKF, NÃO É PARA UTILIZAR PARA CADASTRAR. 
ELE NÃO RODA OS VALIDS QUE EXISTEM NO EXECAUTO DA FINA050

@author Willian Kazahaya
@since  08/02/2021
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Estutura da tela de Contas a Pagar - PFS

ESTE MODELO É SÓ UTILIZADO PARA CONSULTAR OS DADOS DA SE2,
VINCULANDO A FK7 e A FKF, NÃO É PARA UTILIZAR PARA CADASTRAR. 
ELE NÃO RODA OS VALIDS QUE EXISTEM NO EXECAUTO DA FINA050

@author Willian Kazahaya
@since  08/02/2021
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oStructSE2 := FWFormStruct(2, "SE2")
	Local oModel     := FWLoadModel("JURA278")
	Local oView      := Nil
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("JURA278_VIEW", oStructSE2, "SE2MASTER")
	oView:CreateHorizontalBox("FORMFIELD", 100)
	oView:SetOwnerView("JURA278_VIEW", "FORMFIELD")
	oView:SetDescription(STR0001) //"Contas a Pagar - PFS"
	oView:EnableControlBar(.T.)

Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Estrutura do modelo de dados do Contas a Pagar - PFS

ESTE MODELO É SÓ UTILIZADO PARA CONSULTAR OS DADOS DA SE2,
VINCULANDO A FK7 e A FKF, NÃO É PARA UTILIZAR PARA CADASTRAR. 
ELE NÃO RODA OS VALIDS QUE EXISTEM NO EXECAUTO DA FINA050

@author Willian Kazahaya
@since  08/02/2021
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructSE2 := FWFormStruct(1, "SE2")
Local oStructFK7 := FWFormStruct(1, "FK7")
Local oStructFKF := FWFormStruct(1, "FKF")
Local cChave     := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
Local oModel     := NIL
Local lFKF_PAGPIX:= FKF->(ColumnPos("FKF_PAGPIX")) > 0
	
	oModel:= MPFormModel():New("JURA278", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields("SE2MASTER", Nil, oStructSE2, /*Pre-Validacao*/, /*Pos-Validacao*/)
	oModel:SetDescription(STR0001) //"Contas a Pagar - PFS"
	
	//valid para qr code
	If lFKF_PAGPIX
		oStructFKF:SetProperty('FKF_PAGPIX',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| J278QRCode(nValAtu)})
	EndIf

	oModel:AddGrid("FK7DETAIL", "SE2MASTER", oStructFK7, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/)
	oModel:AddGrid("FKFDETAIL", "FK7DETAIL", oStructFKF, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/)

	oModel:SetRelation("FK7DETAIL", {{"FK7_FILIAL", "xFilial('FK7')"},{"FK7_ALIAS", '"' + "SE2" + '"'}, {"FK7_CHAVE", '"' + cChave + '"'}}, FK7->(IndexKey(2)))

	oModel:SetRelation("FKFDETAIL", {{"FKF_FILIAL", "xFilial('FKF')"}, { "FKF_IDDOC","FK7_IDDOC" }}, FKF->(IndexKey(1)) )
		
	oModel:GetModel("SE2MASTER"):SetDescription(STR0001) // "Contas a Pagar - PFS"
	oModel:GetModel("FK7DETAIL"):SetDescription(STR0002) // "Chave IDDOC"
	oModel:GetModel("FKFDETAIL"):SetDescription(STR0003) // "Complemento do Titulo"
Return (oModel)


//-------------------------------------------------------------------
/*/{Protheus.doc} J278QRCode(cPagPixAtu)
Validação do numero do PIX

@param cPagPixAtu - Valor do QRCode do PIX atual.

@author Willian Kazahaya
@since  08/02/2021
/*/
//-------------------------------------------------------------------
Static Function J278QRCode(cPagPixAtu) As Logical
	Local lRet As Logical
	lRet := .T. 

	If _lFinQRCode == Nil
		_lFinQRCode := FindFunction('FinQRCode')
	EndIf 

	If _lFinQRCode
		FinQRCode(cPagPixAtu,.T.,.F.)
	EndIf 

	If !Empty(Alltrim(cPagPixAtu)) .AND. SubStr(cPagPixAtu,1,6) != '000201'
		Help(" ", 1, "QRCODEPIX", Nil, STR0004, 2, 0,,,,,,{STR0005}) //"Não identificamos no conteúdo do campo, um formato de código de QR Code válido." // "Verifique o QR Code utilizado!"
		lRet:= .F.
	Endif
Return lRet
