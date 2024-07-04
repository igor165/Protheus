#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA300.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA300
Cadastro MVC Códigos de Rendimento            

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA300()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Códigos de Rendimento"
oBrw:SetAlias("CUF")
oBrw:SetMenuDef("TAFA300")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA300"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCUF := FwFormStruct(1,"CUF")
Local oModel   := MpFormModel():New("TAFA300")

oModel:AddFields("MODEL_CUF",/*cOwner*/,oStruCUF)
oModel:GetModel("MODEL_CUF"):SetPrimaryKey({"CUF_FILIAL","CUF_CODIGO"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA300")
Local oStruCUF := FwFormStruct(2,"CUF")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CUF",oStruCUF,"MODEL_CUF")

oView:EnableTitleView("VIEW_CUF",STR0001) //"Códigos de Rendimento"
oView:CreateHorizontalBox("FIELDSCUF",100)
oView:SetOwnerView("VIEW_CUF","FIELDSCUF")

Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1022.01

If nVerEmp < nVerAtu
	aAdd( aHeader, "CUF_FILIAL" )
	aAdd( aHeader, "CUF_ID" )
	aAdd( aHeader, "CUF_CLASRE" )
	aAdd( aHeader, "CUF_BENEFI" )
	aAdd( aHeader, "CUF_CODIGO" )
	aAdd( aHeader, "CUF_DESCRI" )
	aAdd( aHeader, "CUF_VALIDA" )
	

	aAdd( aBody, { "", "000001", "1", "2", "0561", "RENDIMENTO DO TRABALHO ASSALARIADO NO PAIS", "" } )
	aAdd( aBody, { "", "000002", "1", "2", "0588", "RENDIMENTO DO TRABALHO SEM VINCULO EMPREGATICIO", "" } )
	aAdd( aBody, { "", "000003", "1", "2", "5936", "RENDIMENTO DECORRENTE DE DECISAO DA JUSTICA DO TRABALHO EXCETO O DISPOSTO NO ARTIGO 12-A DA LEI Nº 7.713, DE 1988", "" } )
	aAdd( aBody, { "", "000004", "2", "2", "1889", "RENDIMENTOS ACUMULADOS – ART. 12-A DA LEI Nº 7.713, DE 1988", "" } )
	aAdd( aBody, { "", "000005", "1", "2", "3223", "RESGATE DE PREVIDENCIA PRIVADA E FAPI – NAO OPTANTES", "" } )
	aAdd( aBody, { "", "000006", "1", "2", "5565", "BENEFICIO OU RESGATE DE PREVIDENCIA PRIVADA E FAPI – OPTANTES", "" } )
	aAdd( aBody, { "", "000007", "1", "1", "2063", "REMUNERACAO INDIRETA", "" } )
	aAdd( aBody, { "", "000008", "1", "3", "5706", "JUROS SOBRE O CAPITAL PROPRIO", "" } )
	aAdd( aBody, { "", "000009", "1", "1", "3426", "APLICACOES FINANCEIRAS DE RENDA FIXA, EXCETO EM FUNDOS DE INVESTIMENTO - PESSOA JURIDICA", "" } )
	aAdd( aBody, { "", "000010", "1", "2", "8053", "APLICACOES FINANCEIRAS DE RENDA FIXA, EXCETO EM FUNDOS DE INVESTIMENTO - PESSOA FISICA", "" } )
	aAdd( aBody, { "", "000011", "1", "3", "6800", "FUNDOS DE INVESTIMENTO E FUNDOS DE INVESTIMENTO EM QUOTAS DE FUNDOS DE INVESTIMENTO", "" } )
	aAdd( aBody, { "", "000012", "1", "3", "6813", "FUNDOS DE INVESTIMENTO EM ACOES E FUNDOS DE INVESTIMENTO EM QUOTAS DE FUNDOS DE INVESTIMENTO EM ACOES", "" } )
	aAdd( aBody, { "", "000013", "1", "3", "5232", "FUNDOS DE INVESTIMENTO IMOBILIARIO", "" } )
	aAdd( aBody, { "", "000014", "1", "3", "0924", "FUNDOS DE INVESTIMENTO CULTURAL E ARTISTICO (FICART) E DEMAIS RENDIMENTOS DE CAPITAL", "" } )
	aAdd( aBody, { "", "000015", "1", "2", "3208", "ALUGUEIS, ROYALTIES E JUROS PAGOS A PESSOA FISICA", "" } )
	aAdd( aBody, { "", "000016", "1", "3", "3277", "RENDIMENTOS DE PARTES BENEFICIARIAS OU DE FUNDADOR", "" } )
	aAdd( aBody, { "", "000017", "1", "3", "5273", "OPERACOES DE SWAP", "" } )
	aAdd( aBody, { "", "000018", "1", "3", "8468", "OPERACOES DAY TRADE", "" } )
	aAdd( aBody, { "", "000019", "1", "3", "5557", "MERCADO DE RENDA VARIAVEL", "" } )
	aAdd( aBody, { "", "000020", "1", "1", "8045", "COMISSOES E CORRETAGENS PAGAS A PESSOA JURIDICA", "" } )
	aAdd( aBody, { "", "000021", "1", "1", "5217", "PAGAMENTOS A BENEFICIARIOS NAO IDENTIFICADOS", "" } )
	aAdd( aBody, { "", "000022", "1", "3", "0916", "PREMIOS EM BENS E SERVICOS / PREMIOS E SORTEIOS EM GERAL / PREMIOS DE PROPRIETARIOS E CRIADORES DE CAVALOS DE CORRIDA / TITULOS DE CAPITALIZACAO", "" } )
	aAdd( aBody, { "", "000023", "1", "3", "8673", "JOGOS DE BINGO PERMANENTE OU EVENTUAL - PREMIOS EM BENS E SERVICOS / EM DINHEIRO", "" } )
	aAdd( aBody, { "", "000024", "1", "3", "9385", "MULTAS E VANTAGENS", "" } )
	aAdd( aBody, { "", "000025", "1", "1", "3280", "REMUNERACAO DE SERVICOS PESSOAIS PRESTADOS POR ASSOCIADOS DE COOPERATIVAS DE TRABALHO", "" } )
	aAdd( aBody, { "", "000026", "1", "1", "1708", "REMUNERACAO DE SERVICOS PROFISSIONAIS PRESTADOS POR PESSOA JURIDICA", "" } )
	aAdd( aBody, { "", "000027", "1", "1", "5944", "PAGAMENTOS DE PESSOA JURIDICA A PESSOA JURIDICA POR SERVICOS DE ASSESSORIA CREDITICIA, MERCADOLOGICA E ADM DE CONTAS A PAGAR E A RECEBER", "" } )
	aAdd( aBody, { "", "000028", "1", "3", "5204", "JUROS E INDENIZACOES POR LUCROS CESSANTES", "" } )
	aAdd( aBody, { "", "000029", "1", "1", "6891", "BENEFICIO OU RESGATE DE SEGURO DE VIDA COM CLAUSULA DE COBERTURA POR SOBREVIVENCIA – VGBL – NAO OPTANTE", "" } )
	aAdd( aBody, { "", "000030", "1", "1", "5928", "RENDIMENTO DECORRENTE DE DECISAO DA JUSTICA FEDERAL, EXCETO O DISPOSTO NO ARTIGO 12-A DA LEI Nº 7.713, DE 1988", "" } )
	aAdd( aBody, { "", "000031", "1", "1", "1895", "RENDIMENTOS DECORRENTES DE DECISAO DA JUSTICA DOS ESTADOS/DISTRITO FEDERAL, EXCETO O DISPOSTO NO ARTIGO 12-A DA LEI Nº 7.713, DE 1988", "" } )
	aAdd( aBody, { "", "000032", "3", "3", "0422", "ROYALTIES E PAGAMENTO DE ASSISTENCIA TECNICA", "" } )
	aAdd( aBody, { "", "000033", "3", "3", "0490", "RENDIMENTOS DE APLICACOES EM FUNDOS DE INVESTIMENTO DE CONVERSAO DE DEBITOS EXTERNOS", "" } )
	aAdd( aBody, { "", "000034", "3", "3", "0481", "JUROS E COMISSOES EM GERAL", "" } )
	aAdd( aBody, { "", "000035", "3", "3", "9453", "JUROS SOBRE O CAPITAL PROPRIO", "" } )
	aAdd( aBody, { "", "000036", "3", "3", "9478", "ALUGUEL E ARRENDAMENTO", "" } )
	aAdd( aBody, { "", "000037", "3", "3", "5286", "APLICACOES EM FUNDOS OU ENTIDADES DE INVESTIMENTO COLETIVO/APLICACOES EM CARTEIRAS DE VALORES MOBILIARIOS/ APLICACOES FINANCEIRAS NOS MERCADOS DE RENDA FIXA OU RENDA VARIAVEL", "" } )
	aAdd( aBody, { "", "000038", "3", "3", "0473", "RENDA E PROVENTOS DE QUALQUER NATUREZA", "" } )
	aAdd( aBody, { "", "000039", "3", "1", "9412", "FRETES INTERNACIONAIS", "" } )
	aAdd( aBody, { "", "000040", "3", "2", "0610", "SERVICOS DE TRANSPORTE RODOVIARIO INTERNACIONAL DE CARGA, AUFERIDOS POR TRANSPORTADOR AUTONOMO PESSOA FISICA, RESIDENTE NA REPUBLICA DO PARAGUAI, CONSIDERADO COMO SOCIEDADE UNIPESSOAL NESSE PAIS", "" } )
	aAdd( aBody, { "", "000041", "3", "2", "9466", "BENEFICIO OU RESGATE DE PREVIDENCIA PRIVADA E FAPI", "" } )
	aAdd( aBody, { "", "000042", "3", "3", "9427", "REMUNERACAO DE DIREITOS", "" } )
	aAdd( aBody, { "", "000043", "3", "3", "5192", "OBRAS AUDIOVISUAIS, CINEMATOGRAFICAS E VIDEOFONICAS", "" } )
	
	aAdd( aBody, { "", "000044", "1", "2", "3533", "APOSENTADORIA, RESERVA, REFORMA OU PENSÃO PAGOS POR PREVIDÊNCIA PÚBLICA", "" } )	
	aAdd( aBody, { "", "000045", "1", "2", "3540", "BENEFÍCIO DE PREVIDÊNCIA COMPLEMENTAR - NÃO OPTANTE PELA TRIBUTAÇÃO EXCLUSIVA", "" } )
	aAdd( aBody, { "", "000046", "1", "2", "3556", "RESGATE DE PREVIDÊNCIA COMPLEMENTAR- MODALIDADE BENEFÍCIO DEFINIDO - NÃO OPTANTE PELA TRIBUTAÇÃO EXCLUSIVA", "" } )
	aAdd( aBody, { "", "000047", "1", "2", "3579", "REGASTE DE PREVIDÊNCIA COMPLEMENTAR - OPTANTE PELA TRIBUTAÇÃO EXCLUSIVA", "" } )
	aAdd( aBody, { "", "000048", "1", "1", "3746", "COFINS – PAGAMENTOS PARA PESSOAS JURÍDICAS REFERIDAS NA LEI Nº 10.485/2002", "" } )
	aAdd( aBody, { "", "000049", "1", "1", "3770", "CONTRIBUIÇÃO PIS/PASEP – PAGAMENTOS PARA PESSOAS JURÍDICAS REFERIDAS NA LEI º 10.485/2002", "" } )
	aAdd( aBody, { "", "000050", "1", "1", "4085", "RETENÇÕES CONTRIBUIÇÕES – PAGAMENTOS EFETUADOS PELOS ESTADOS, MUNICÍPIOS E DF PELA AQUISIÇÃO DE BENS E SERVIÇOS.", "" } )
	aAdd( aBody, { "", "000051", "1", "1", "4397", "CSLL – PAGAMENTOS EFETUADOS PELOS ESTADOS, MUNICÍPIOS E DF PELA AQUISIÇÃO DE BENS E SERVIÇOS.", "" } )
	aAdd( aBody, { "", "000052", "1", "1", "4407", "COFINS – PAGAMENTOS EFETUADOS PELOS ESTADOS, MUNICÍPIOS E DF PELA AQUISIÇÃO DE BENS E SERVIÇOS.", "" } )
	aAdd( aBody, { "", "000053", "1", "1", "4409", "PIS – PAGAMENTOS EFETUADOS PELOS ESTADOS, MUNICÍPIOS E DF PELA AQUISIÇÃO DE BENS E SERVIÇOS.", "" } )
	aAdd( aBody, { "", "000054", "1", "1", "5952", "RETENÇÕES DE CONTRIBUIÇÕES PAGAMENTO PJ A PJ DE DIREITO PRIVADO", "" } )
	aAdd( aBody, { "", "000055", "1", "1", "5960", "CONFIS – RETENÇÃO PAGAMENTO PJ A PJ DE DIREITO PRIVADO", "" } )
	aAdd( aBody, { "", "000056", "1", "1", "5979", "PIS/PASEP – RETENÇÃO PAGAMENTO PJ A PJ DE DIREITO PRIVADO", "" } )
	aAdd( aBody, { "", "000057", "1", "1", "5987", "CSLL – RETENÇÃO PAGAMENTO PJ A PJ DE DIREITO PRIVADO", "" } )
	aAdd( aBody, { "", "000058", "1", "1", "6147", "ALIMENTAÇÃO, ENERGIA ELÉTRICA, TRANSPORTE DE CARGAS, BENS EM GERAL, SERVIÇOS C/ FORN. DE BENS", "" } )
	aAdd( aBody, { "", "000059", "1", "1", "6175", "PASSAGENS AÉREAS, RODOVIÁRIAS E DEMAIS SERVIÇOS DE TRANSPORTE DE PASSAGEIROS", "" } )
	aAdd( aBody, { "", "000060", "1", "1", "6190", "ÁGUA, TELEFONE, CORREIOS, VIGILÂNCIA, LIMPEZA, LOCAÇÃO DE MÃO-DE-OBRA, LOCAÇÃO E DEMAIS SERVIÇOS", "" } )
	aAdd( aBody, { "", "000061", "1", "1", "6228", "CSLL – ISENÇÃO OU SUSPENSÃO AMPARADA POR LEI, DE PIS/PASEP E/OU COFINS E/OU IRPJ", "" } )
	aAdd( aBody, { "", "000062", "1", "1", "6230", "PIS/PASEP – ISENÇÃO OU SUSPENSÃO AMPARADA POR LEI, DE CSLL E/OU COFINS E/OU IRPJ", "" } )
	aAdd( aBody, { "", "000063", "1", "1", "6243", "COFINS – ISENÇÃO OU SUSPENSÃO AMPARADA POR LEI, DE CSLL E/OU PIS/PASEP E/OU IRPJ", "" } )
	aAdd( aBody, { "", "000064", "1", "1", "6256", "IRPJ – ISENÇÃO OU SUSPENSÃO AMPARADA POR LEI, DE CSLL E/OU PIS/PASP E/OU COFINS", "" } )
	aAdd( aBody, { "", "000065", "1", "2", "6904", "INDENIZAÇÃO POR DANO MORAIS", "" } )
	aAdd( aBody, { "", "000066", "1", "1", "8739", "GASOLINA, ÓLEO DIESEL E GLP, ADQ. DE DISTRIB. EVAREJ. E ÁLCOOL ADQ. DE VAREJ.", "" } )
	aAdd( aBody, { "", "000067", "1", "1", "8767", "MEDICAMENTOS E PROD. DE PERFUMARIA ETC...(TIPI) ADQ. DISTRIB. OU VAREJ.", "" } )
	aAdd( aBody, { "", "000068", "1", "1", "8850", "TRANSPORTE INTERNACIONAL DE PASSAGEIROS EFETUADO POR EMPRESAS NACIONAIS.", "" } )
	aAdd( aBody, { "", "000069", "1", "1", "8863", "BENS SERVIÇOS ADQUIRIDOS DE SOCIEDADES COOP. E ASS. PROFISSIONAIS OU ASSEMELHADOS.", "" } )
	aAdd( aBody, { "", "000070", "1", "1", "9060", "QUEROSENE DE AVIAÇÃO ADQUIRIDO DE PRODUTOR OU IMPORTADOR", "" } )	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAGetId

Rotina para carga e atualização da tabela autocontida.
Retorna proximo ID a ser utilizado

@Return	cRet		-	ID disponível para utilização

@Author	Karen Honda
@Since		23/04/2018
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function TAFAGetId( )
	Local cRet				:= ''
	Local aAreaCUF		:= CUF->(GetArea())
	Local lContinua		:= .T.
	
	CUF->(DbSetOrder(1))	//CUF_FILIAL+CUF_ID
	
	While lContinua
		cRet	:= GetSX8Num('CUF','CUF_ID')
	
		lContinua := ( CUF->(MsSeek(xFilial('CUF') + cRet)) )
		ConfirmSX8()
	EndDo
	
	RestArea(aAreaCUF)
Return cRet
