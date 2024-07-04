#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA173.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA173
Cadastro MVC Cadastro de Códigos da Receita

@author Vitor Siqueira
@since 17/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA173()

Local oBrw	as object

oBrw	:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Códigos da Receita	
oBrw:SetAlias( 'C80')
oBrw:SetMenuDef( 'TAFA173' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Vitor Siqueira
@since 17/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return xFunMnuTAF( "TAFA173" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Vitor Siqueira
@since 17/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()

Local oStruC80	as object
Local oModel		as object

oStruC80	:=	FWFormStruct( 1, "C80" ) //Cria a estrutura a ser usada no Modelo de Dados
oModel		:=	MPFormModel():New( "TAFA173" )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_C80', /*cOwner*/, oStruC80)
oModel:GetModel( 'MODEL_C80' ):SetPrimaryKey( { 'C80_FILIAL' , 'C80_ID' } )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Vitor Siqueira
@since 17/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oStruC80	as object
Local oView		as object

oModel		:=	FWLoadModel( "TAFA173" ) //Objeto de Modelo de dados baseado no ModelDef() do fonte informado
oStruC80	:=	FWFormStruct( 2, "C80" ) //Cria a estrutura a ser usada na View
oView		:=	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C80', oStruC80, 'MODEL_C80' )

oView:EnableTitleView( 'VIEW_C80',  STR0001 ) //Cadastro de Códigos da Receita

oView:CreateHorizontalBox( 'FIELDSC80', 100 )

oView:SetOwnerView( 'VIEW_C80', 'FIELDSC80' )

Return oView

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

Local aHeader	as array
Local aBody	as array
Local aRet		as array

aHeader	:=	{}
aBody		:=	{}
aRet		:=	{}

If TAFColumnPos( "C80_DESCRI" )
	nVerAtu := 1009
Else
	nVerAtu := 1000
EndIf

If nVerEmp < nVerAtu
	aAdd( aHeader, "C80_FILIAL" )
	aAdd( aHeader, "C80_ID" )
	aAdd( aHeader, "C80_CODIGO" )
	aAdd( aHeader, "C80_DESCRI" )
	aAdd( aHeader, "C80_VALIDA" )

	//CÓDIGOS E-SOCIAL
	aAdd( aBody, { "", "000001", "108201", "CONTRIBUIÇÃO PREVIDENCIÁRIA (CP) DESCONTADA DO SEGURADO EMPREGADO/AVULSO, ALÍQUOTAS 8%, 9% OU 11%", "" } )
	aAdd( aBody, { "", "000002", "108202", "CP DESCONTADA DO SEGURADO EMPREGADO RURAL CURTO PRAZO, ALÍQUOTA DE 8%, LEI 11718/2008", "" } )
	aAdd( aBody, { "", "000003", "108203", "CP DESCONTADA DO SEGURADO EMPREGADO DOMÉSTICO OU SEGURADO ESPECIAL, ALÍQUOTA DE 8%, 9% OU 11%", "" } )
	aAdd( aBody, { "", "000004", "108204", "CP DESCONTADA DO SEGURADO ESPECIAL CURTO PRAZO, ALÍQUOTA DE 8%, LEI 11718/2008", "" } )
	aAdd( aBody, { "", "000005", "108221", "CP DESCONTADA DO SEGURADO EMPREGADO/AVULSO 13°SALÁRIO, ALÍQUOTAS 8%, 9% OU 11%", "" } )
	aAdd( aBody, { "", "000006", "108222", "CP DESCONTADA DO SEGURADO EMPREGADO RURAL CURTO PRAZO 13° SALÁRIO, ALÍQUOTA DE 8%, LEI 11718/2008", "" } )
	aAdd( aBody, { "", "000007", "108223", "CP DESCONTADA DO SEGURADO EMPREGADO DOMÉSTICO OU SEGURADO ESPECIAL 13° SALÁRIO, ALÍQUOTA DE 8%, 9% OU 11%", "" } )
	aAdd( aBody, { "", "000008", "108224", "CP DESCONTADA DO SEGURADO ESPECIAL CURTO PRAZO 13° SALÁRIO, ALÍQUOTA DE 8%, LEI 11718/2008", "" } )
	aAdd( aBody, { "", "000009", "109901", "CP DESCONTADA DO CONTRIBUINTE INDIVIDUAL, ALÍQUOTA DE 11%", "" } )
	aAdd( aBody, { "", "000010", "109902", "CP DESCONTADA DO CONTRIBUINTE INDIVIDUAL, ALÍQUOTA DE 20%", "" } )
	aAdd( aBody, { "", "000011", "121802", "CONTRIBUIÇÃO AO SEST, DESCONTADA DO TRANSPORTADOR AUTÔNOMO, À ALÍQUOTA DE 1,5%", "" } )
	aAdd( aBody, { "", "000012", "122102", "CONTRIBUIÇÃO AO SENAT, DESCONTADA DO TRANSPORTADOR AUTÔNOMO, À ALÍQUOTA DE 1,0%", "" } )
	aAdd( aBody, { "", "000013", "056107", "IRRF MENSAL, 13° SALÁRIO E FÉRIAS SOBRE TRABALHO ASSALARIADO NO PAÍS OU AUSENTE NO EXTERIOR A SERVIÇO DO PAÍS, EXCETO SE CONTRATADO POR EMPREGADOR DOMÉSTICO", "" } )
	aAdd( aBody, { "", "000014", "056108", "IRRF MENSAL, 13° SALÁRIO E FÉRIAS SOBRE TRABALHO ASSALARIADO NO PAÍS OU AUSENTE NO EXTERIOR A SERVIÇO DO PAÍS, EMPREGADO DOMÉSTICO OU TRABALHADOR CONTRATADO POR SEGURADO", "" } )
	aAdd( aBody, { "", "000015", "056109", "IRRF 13° SALÁRIO NA RESCISÃO DE CONTRATO DE TRABALHO RELATIVO A EMPREGADOR SUJEITO A RECOLHIMENTO UNIFICADO", "" } )
	aAdd( aBody, { "", "000016", "058806", "IRRF SOBRE RENDIMENTO DO TRABALHO SEM VÍNCULO EMPREGATÍCIO", "" } )
	aAdd( aBody, { "", "000017", "061001", "IRRF SOBRE RENDIMENTOS RELATIVOS A PRESTAÇÃO DE SERVIÇOS DE TRANSPORTE RODOVIÁRIO INTERNACIONAL DE CARGA, PAGOS A TRANSPORTADOR AUTÔNOMO PF RESIDENTE NO PARAGUAI", "" } )
	aAdd( aBody, { "", "000018", "328006", "IRRF SOBRE SERVIÇOS PRESTADOS POR ASSOCIADOS DE COOPERATIVAS DE TRABALHO", "" } )
	aAdd( aBody, { "", "000019", "356201", "IRRF SOBRE PARTICIPAÇÃO DOS TRABALHADORES EM LUCROS OU RESULTADOS (PLR)", "" } )
	aAdd( aBody, { "", "000020", "206201", "IRRF SOBRE REMUNERAÇÃO INDIRETA A BENEFICIÁRIO NÃO IDENTIFICADO", "" } )

	//CÓDIGOS SPED PIS COFINS
	aAdd( aBody, { "", "000021", "0067", "PRODUTOS-RETENÇÃO EM PAGAMENTOS POR ÓRGÃOS PÚBLICOS-OPERAÇÕES INTRA ORÇAMENTÁRIAS", "" } )
	aAdd( aBody, { "", "000022", "0070", "TRANSPORTE DE PASSAGEIROS-RETENÇÃO EM PAGAMENTOS POR ÓRGÃOS PÚBLICOS-OPERAÇÕES INTRA ORÇAMENTÁRIAS", "" } )
	aAdd( aBody, { "", "000023", "0082", "FINANCEIRAS-RETENÇÃO EM PAGAMENTOS POR ÓRGÃOS PÚBLICOS-OPERAÇÕES INTRA ORÇAMENTÁRIAS", "" } )
	aAdd( aBody, { "", "000024", "0095", "SERVIÇOS-RETENÇÃO EM PAGAMENTOS POR ÓRGÃOS PÚBLICOS-OPERAÇÕES INTRA ORÇAMENTÁRIAS", "" } )
	aAdd( aBody, { "", "000025", "0123", "BENS E SERVIÇOS ADQUIRIDOS DE SOCIEDADES COOPERATIVAS E ASSOCIAÇÕES PROFISSIONAIS OU ASSEMELHADAS - RETIDO POR ÓRGÃO PÚBLICO - OPERAÇÕES INTRA-ORÇAMENTÁRIAS", "" } )
	aAdd( aBody, { "", "000026", "3316", "COFINS - RET FONTE PAG PJ/PJ D PRIV -L OFICIO", "" } )
	aAdd( aBody, { "", "000027", "3332", "COFINS - RET PAGT ENT PUBL A PJ - L OFICIO", "" } )
	aAdd( aBody, { "", "000028", "3359", "PIS - RET FONTE PAG PJ/PJ DIR PRIV - L OFICIO", "" } )
	aAdd( aBody, { "", "000029", "3360", "PIS - RET FONTE PAGT ENT PUBL A PJ - L OFICIO", "" } )
	aAdd( aBody, { "", "000030", "3346", "COFINS - RETENÇÃO NA FONTE/AQUISIÇÃO DE AUTOPEÇAS", "" } )
	aAdd( aBody, { "", "000031", "3370", "PIS/PASEP - RETENÇÃO NA FONTE/AQUISIÇÃO DE AUTOPEÇAS", "" } )
	aAdd( aBody, { "", "000032", "4085", "RET CONTRIB PAGT EST/DF/MUNIC - BENS/SERVIÇOS - CSLL/COFINS/PIS", "" } )
	aAdd( aBody, { "", "000033", "4166", "COFINS - REGIME ESPECIAL DE TRIBUTAÇÃO DO PATRIMÔNIO DE AFETAÇÃO", "" } )
	aAdd( aBody, { "", "000034", "4407", "COFINS - RET FONTE PAGT ESTADOS/DF/MUNICÍPIOS - BENS/SERVIÇOS", "" } )
	aAdd( aBody, { "", "000035", "4409", "PIS - RET FONTE PAGT ESTADOS/DF/MUNICÍPIOS - BENS/SERVIÇOS", "" } )
	aAdd( aBody, { "", "000036", "5952", "RETENÇÃO DE CONTRIBUIÇÕES SOBRE PAGAMENTOS DE PESSOA JURÍDICA A PESSOA JURÍDICA DE DIREITO PRIVADO - CSLL, COFINS E PIS", "" } )
	aAdd( aBody, { "", "000037", "5960", "COFINS - RETENÇÃO SOBRE PAGAMENTOS DE PESSOA JURÍDICA A PESSOA JURÍDICA DE DIREITO PRIVADO (ART. 30 DA LEI Nº 10.833/2003)", "" } )
	aAdd( aBody, { "", "000038", "5979", "PIS - RETENÇÃO SOBRE PAGAMENTOS DE PESSOA JURÍDICA A PESSOA JURÍDICA DE DIREITO PRIVADO", "" } )
	aAdd( aBody, { "", "000039", "6147", "PRODUTOS - RETENÇÃO EM PAGAMENTOS POR ÓRGÃO PÚBLICO", "" } )
	aAdd( aBody, { "", "000040", "6175", "TRANSPORTE DE PASSAGEIROS - RETENÇÃO EM PAGAMENTO POR ÓRGÃO PÚBLICO", "" } )
	aAdd( aBody, { "", "000041", "6188", "FINANCEIRAS - RETENÇÃO EM PAGAMENTO POR ÓRGÃO PÚBLICO", "" } )
	aAdd( aBody, { "", "000042", "6190", "SERVIÇOS - RETENÇÃO EM PAGAMENTO POR ÓRGÃO PÚBLICO", "" } )
	aAdd( aBody, { "", "000042", "6215", "ENTIDADES ISENTAS - RETENÇÃO EM PAGAMENTO POR ÓRGÃO PÚBLICO", "" } )
	aAdd( aBody, { "", "000043", "6230", "PIS - RETENÇÃO NA FONTE SOBRE PAGAMENTO EFETUADO POR ÓRGÃO PÚBLICO À PESSOA JURÍDICA", "" } )
	aAdd( aBody, { "", "000044", "6243", "COFINS - RETENÇÃO NA FONTE SOBRE PAGAMENTO À PESSOA JURÍDICA (ART. 34 DA LEI Nº 10.833/2003", "" } )
	aAdd( aBody, { "", "000045", "8863", "BENS OU SERVIÇOS ADQUIRIDOS DE SOCIEDADES COOPERATIVAS E ASSOCIAÇÕES PROFISSIONAIS OU ASSEMELHADAS - RETIDO POR ÓRGÃO PÚBLICO", "" } )
	aAdd( aBody, { "", "000046", "9060", "QUEROSENE DE AVIAÇÃO ADQUIRIDO DE PRODUTOR OU IMPORTADOR - RETIDO POR ÓRGÃO PÚBLICO", "" } )
	aAdd( aBody, { "", "000047", "298501", "CONTRIBUIÇÃO PREVIDENCIÁRIA SOBRE RECEITA BRUTA - ART. 7º DA LEI 12.546/2011", "" } )
	aAdd( aBody, { "", "000048", "298503", "CONTRIBUIÇÃO PREVIDENCIÁRIA SOBRE RECEITA BRUTA - ART. 7º DA LEI 12.546/2011 - SCP", "" } )
	aAdd( aBody, { "", "000049", "299101", "CONTRIBUIÇÃO PREVIDENCIÁRIA SOBRE RECEITA BRUTA - ART. 8º DA LEI 12.546/2011", "" } )
	aAdd( aBody, { "", "000050", "299103", "CONTRIBUIÇÃO PREVIDENCIÁRIA SOBRE RECEITA BRUTA - ART. 8º DA LEI 12.546/2011 - SCP", "" } )

	//CÓDIGOS SPED FISCAL
	aAdd( aBody, { "", "000051", "100013", "ICMS COMUNICAÇÃO", "" } )
	aAdd( aBody, { "", "000052", "100021", "ICMS ENERGIA ELÉTRICA", "" } )
	aAdd( aBody, { "", "000053", "100030", "ICMS TRANSPORTE", "" } )
	aAdd( aBody, { "", "000054", "100048", "ICMS SUBSTITUIÇÃO TRIBUTÁRIA POR APURAÇÃO", "" } )
	aAdd( aBody, { "", "000055", "100056", "ICMS IMPORTAÇÃO", "" } )
	aAdd( aBody, { "", "000056", "100064", "ICMS AUTUAÇÃO FISCAL", "" } )
	aAdd( aBody, { "", "000057", "100072", "ICMS PARCELAMENTO", "" } )
	aAdd( aBody, { "", "000058", "100080", "ICMS RECOLHIMENTOS ESPECIAIS", "" } )
	aAdd( aBody, { "", "000059", "100099", "ICMS SUBST. TRIBUTÁRIA POR OPERAÇÃO", "" } )
	aAdd( aBody, { "", "000060", "100102", "ICMS CONSUMIDOR FINAL NÃO CONTRIBUINTE OUTRA UF POR OPERAÇÃO", "" } )
	aAdd( aBody, { "", "000061", "100110", "ICMS CONSUMIDOR FINAL NÃO CONTRIBUINTE OUTRA UF POR APURAÇÃO", "" } )
	aAdd( aBody, { "", "000062", "100129", "ICMS FUNDO ESTADUAL DE COMBATE À POBREZA POR OPERAÇÃO", "" } )
	aAdd( aBody, { "", "000063", "100137", "ICMS FUNDO ESTADUAL DE COMBATE À POBREZA POR APURAÇÃO", "" } )
	aAdd( aBody, { "", "000064", "150010", "ICMS DÍVIDA ATIVA", "" } )
	aAdd( aBody, { "", "000065", "500011", "MULTA P/ INFRAÇÃO À OBRIGAÇÃO ACESSÓRIA", "" } )
	aAdd( aBody, { "", "000066", "600016", "TAXA", "" } )

	//CÓDIGOS ECF
	aAdd( aBody, { "", "000067", "4085", "RET CONTRIB PAGT EST/DF/MUNIC - BENS/SERVIÇOS - CSLL/COFINS/PIS", "" } )
	aAdd( aBody, { "", "000068", "4397", "CSLL - RET FONTE PAGT ESTADOS/DF/MUNICÍPIOS - BENS/SERVIÇOS", "" } )
	aAdd( aBody, { "", "000069", "5928", "IRRF -REND DECOR DECISÃO JUSTIÇA FEDERAL, EXCETO ART 12A L 7713/88", "" } )
	aAdd( aBody, { "", "000070", "5936", "IRRF - REND DECOR DEC JUSTIÇA TRABALHO, EXCETO ART 12A L. 7.713/88", "" } )
	aAdd( aBody, { "", "000071", "5944", "IRRF - PAGAMENTO DE PJ A PJ POR SERVIÇOS DE FACTORING", "" } )
	aAdd( aBody, { "", "000072", "6147", "PRODUTOS - RETENÇÃO EM PAGAMENTOS POR ÓRGÃO PÚBLICO", "" } )
	aAdd( aBody, { "", "000073", "6175", "TRANSPORTE DE PASSAGEIROS - RETENÇÃO EM PAGAMENTO POR ÓRGÃO PÚBLICO", "" } )
	aAdd( aBody, { "", "000074", "6188", "FINANCEIRAS - RETENÇÃO EM PAGAMENTO POR ÓRGÃO PÚBLICO", "" } )
	aAdd( aBody, { "", "000075", "6190", "SERVIÇOS - RETENÇÃO EM PAGAMENTO POR ÓRGÃO PÚBLICO", "" } )
	aAdd( aBody, { "", "000076", "6228", "CSLL - RETENÇÃO NA FONTE SOBRE PAGAMENTO DE ÓRGÃO PUBLICO A PESSOA JURÍDICA", "" } )
	aAdd( aBody, { "", "000077", "6256", "IRPJ - PAGAMENTO EFETUADO POR ÓRGÃO PÚBLICO", "" } )
	aAdd( aBody, { "", "000078", "8739", "GASOL/DIESEL/GLP E ALCOOL NO VAREJO-R ORG PUB", "" } )
	aAdd( aBody, { "", "000079", "8767", "MEDICAMENTO ADQUIR DISTRIB/VAREJ-RET ORG PUBL", "" } )
	aAdd( aBody, { "", "000080", "8850", "TRANSPORTE INTERNACIONAL PASSAGEIRO-R ORG PUB", "" } )
	aAdd( aBody, { "", "000081", "8863", "BENS OU SERVIÇOS ADQUIRIDOS DE SOCIEDADES COOPERATIVAS E ASSOCIAÇÃO", "" } )
	aAdd( aBody, { "", "000082", "9060", "QUEROSENE DE AVIAÇÃO ADQUIRIDO DE PRODUTOR OU IMPORTADOR - RETIDO", "" } )
	aAdd( aBody, { "", "000083", "9997", "OUTRAS RETENÇÕES NÃO ESPECIFICADAS ACIMA", "" } )
	aAdd( aBody, { "", "000084", "916",  "IRRF - PRÊMIOS OBTIDOS EM CONCURSOS SORTEIOS", "" } )
	aAdd( aBody, { "", "000085", "924",  "IRRF - DEMAIS RENDIMENTOS CAPITAL", "" } )
	aAdd( aBody, { "", "000086", "1708", "IRRF - REMUNERAÇÃO SERVIÇOS PRESTADOS POR PESSOA JURÍDICA", "" } )
	aAdd( aBody, { "", "000087", "3277", "IRRF - RENDIMENTOS DE PARTES BENEFICIÁRIAS OU DE FUNDADOR", "" } )
	aAdd( aBody, { "", "000088", "3426", "IRRF - APLICAÇÕES FINANCEIRAS DE RENDA FIXA - PESSOA JURÍDICA", "" } )
	aAdd( aBody, { "", "000089", "5204", "IRRF - JUROS INDENIZAÇÕES LUCROS CESSANTES", "" } )
	aAdd( aBody, { "", "000090", "5232", "IRRF - APLICAÇÕES FINANCEIRAS EM FUNDOS DE INVESTIMENTO IMOBILIÁRIOS", "" } )
	aAdd( aBody, { "", "000091", "5273", "IRRF - OPERAÇÕES DE SWAP (ART. 74 L 8981/95)", "" } )
	aAdd( aBody, { "", "000092", "5557", "IRRF - GANHOS LÍQUIDOS EM OPERAÇÕES EM BOLSAS E ASSEMELHADOS", "" } )
	aAdd( aBody, { "", "000093", "5706", "IRRF - JUROS SOBRE O CAPITAL PRÓPRIO", "" } )
	aAdd( aBody, { "", "000094", "5952", "RETENÇÃO CONTRIBUIÇÕES PAGT DE PJ A PJ DIR PRIV - CSLL/COFINS/PIS", "" } )
	aAdd( aBody, { "", "000095", "5987", "CSLL - RETENÇÃO PAGAMENTOS DE PJ A PJ DIREITO PRIVADO", "" } )
	aAdd( aBody, { "", "000096", "6800", "IRRF - APLICAÇÕES FINANCEIRAS EM FUNDOS DE INVESTIMENTO DE RENDA FIXA", "" } )
	aAdd( aBody, { "", "000097", "6813", "IRRF - FUNDOS DE INVESTIMENTO - AÇÕES", "" } )
	aAdd( aBody, { "", "000098", "8045", "IRRF - OUTROS RENDIMENTOS", "" } )
	aAdd( aBody, { "", "000099", "8468", "IRRF - DAY-TRADE OPERAÇÕES EM BOLSA", "" } )
	aAdd( aBody, { "", "000100", "9385", "IRRF - MULTAS E VANTAGENS", "" } )
	aAdd( aBody, { "", "000101", "9998", "CSLL - OUTRAS RETENÇÕES NÃO ESPECIFICADAS ACIMA", "" } )
	aAdd( aBody, { "", "000102", "9999", "IRPJ - OUTRAS RETENÇÕES NÃO ESPECIFICADAS ACIMA", "" } )

	aAdd( aRet, { aHeader, aBody } )

EndIf

Return( aRet )