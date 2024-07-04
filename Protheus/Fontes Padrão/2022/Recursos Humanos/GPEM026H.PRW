#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM026.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} fGrvRJ0()
Função responsável pelo geração do XML do evento S-2420
@author  lidio.oliveira
@since   13/10/2021
@version V 1.0
@param oModel	    = Modelo
@param aErros	    = retorna array com erros:
@return lRet -> Retorna se a geração e integração evento foi realizada
/*/
//-------------------------------------------------------------------
Function fInt2420( oModel, aErros)

    Local cFilEnv		:= ""
    Local cXml          := ""
    Local lRet          := .T.
    Local aFilInTaf 	:= {}
    Local aArrayFil 	:= {}

    //Verifica a filial de envio do TAF
    fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)

    If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

    cXml    := '<eSocial>'
    cXml    +=      '<evtCdBenTerm>'
    cXml    +=          '<ideBeneficio>'
    cXml    +=              '<cpfBenef>' + alltrim(RI0->RI0_CPF) + '</cpfBenef>'
    cXml    +=              '<nrBeneficio>' + alltrim(RI0->RI0_NRBEN) + '</nrBeneficio>'
    cXml    +=          '</ideBeneficio>'
    cXml    +=          '<infoBenTermino>'
    cXml    +=              '<dtTermBeneficio>' + DTOS(oModel:GetValue("GPEA019_RI0","RI0_DTTERM")) + '</dtTermBeneficio>'
    cXml    +=              '<mtvTermino>' + alltrim(oModel:GetValue("GPEA019_RI0","RI0_TERMOT")) + '</mtvTermino>'

    //Gera a tag cnpjOrgaoSuc somente se motivo for 09
    If alltrim(oModel:GetValue("GPEA019_RI0","RI0_TERMOT")) == "09" .And. !Empty(oModel:GetValue("GPEA019_RI0","RI0_CNPJSU"))
        cXml    +=              '<cnpjOrgaoSuc>' + alltrim(oModel:GetValue("GPEA019_RI0","RI0_CNPJSU")) + '</cnpjOrgaoSuc>'
    EndIf

    //Gera a tag novoCPF somente se motivo for 10
    If alltrim(oModel:GetValue("GPEA019_RI0","RI0_TERMOT")) == "10" .And. !Empty(oModel:GetValue("GPEA019_RI0","RI0_NVCPF"))
        cXml    +=              '<novoCPF>' + alltrim(oModel:GetValue("GPEA019_RI0","RI0_NVCPF")) + '</novoCPF>'
    EndIf

    cXml    +=          '</infoBenTermino>'
    cXml    +=      '</evtCdBenTerm>'
    cXml    += '</eSocial>'

    //Realiza geração de XML
	GrvTxtArq(alltrim(cXml), "S2420")

    //Realiza a integração com o TAF
    aErros := TafPrepInt(cEmpAnt, cFilEnv, cXml, ,"1", "S2420",,,,,,"GPE",,,,,,,,,)
    If Len(aErros) > 0
        lRet := .F.
    EndIf

Return lRet


/*/{Protheus.doc} fInt2418
Função responsável pela geração do XML do evento S-2418
@author  isabel.noguti
@since   14.10.2021
@version V 1.0
@param oModel	    = Modelo
@param aErros	    = retorna array com erros
@return lRet -> Retorna se a geração e integração evento foi realizada
/*/
Function fInt2418( oModel, aErros)

	Local cFilEnv		:= ""
	Local cXml          := ""
	Local lRet          := .T.
	Local aFilInTaf 	:= {}
	Local aArrayFil 	:= {}

	//Verifica a filial de envio do TAF
	fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)

	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	cXml := '<eSocial>'
	cXml += '	<evtReativBen>'
	cXml += '		<ideBeneficio>'
	cXml += '			<cpfBenef>' + AllTrim(RI0->RI0_CPF) + '</cpfBenef>'
	cXml += '			<nrBeneficio>' + alltrim(RI0->RI0_NRBEN) + '</nrBeneficio>'
	cXml += '		</ideBeneficio>'
	cXml += '		<infoReativ>'

	cXml += '			<dtEfetReativ>' + DTOS(oModel:GetValue("GPEA019_RI0","RI0_DTEFRE")) + '</dtEfetReativ>'
	cXml += '			<dtEfeito>' + DTOS(oModel:GetValue("GPEA019_RI0","RI0_DTEFFI")) + '</dtEfeito>'
	cXml += '		</infoReativ>'
	cXml += '	</evtReativBen>'
	cXml += '</eSocial>'

	//Realiza geração de XML
	GrvTxtArq(alltrim(cXml), "S2418")

	//Realiza a integração com o TAF
	aErros := TafPrepInt(cEmpAnt, cFilEnv, cXml, ,"1", "S2418",,,,,,"GPE")
	If Len(aErros) > 0
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} fIntOP3000
Função responsável pela integração da exclusão(S-3000) para os eventos: S-2410,S-2416,S-2418,S-2420
@author  martins.marcio
@since   10.11.2021
@version V 1.0
@param cEvento	    = evento que deseja excluir
@param cRecib	    = chave para identificar o evento no TAF. Ex: cpfBenef + nrBeneficio + [dtAltBeneficio]
@param aErros	    = retorna array com erros
@return lRet -> Retorna se a geração e integração evento foi realizada
/*/
Function fIntOP3000(cEvento, cRecib, aErros)

    Local lRet := .T.
    Local cFilEnv		:= ""
	Local cXml          := ""
	Local aFilInTaf 	:= {}
	Local aArrayFil 	:= {}

    Default cEvento := ""
    Default cRecib := RI0->RI0_CPF + RI0->RI0_NRBEN

	//Verifica a filial de envio do TAF
	fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)

    If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

    InExc3000(@cXml, cEvento, cRecib, RI0->RI0_CPF)
    
    //Realiza geração de XML na System
    GrvTxtArq(alltrim(cXml), "S3000", RI0->RI0_CPF)
	
    //Realiza a integração com o TAF
	aErros := TafPrepInt(cEmpAnt, cFilEnv, cXml, ,"1", "S3000",,,,,,"GPE")
	If Len(aErros) > 0
		lRet := .F.
	EndIf

Return lRet	
