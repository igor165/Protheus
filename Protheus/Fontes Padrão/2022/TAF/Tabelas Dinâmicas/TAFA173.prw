#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA173.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA173
Cadastro MVC Cadastro de C�digos da Receita

@author Vitor Siqueira
@since 17/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA173()

Local oBrw	as object

oBrw	:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de C�digos da Receita	
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

// Adiciona ao modelo um componente de formul�rio
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

oView:EnableTitleView( 'VIEW_C80',  STR0001 ) //Cadastro de C�digos da Receita

oView:CreateHorizontalBox( 'FIELDSC80', 100 )

oView:SetOwnerView( 'VIEW_C80', 'FIELDSC80' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

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

	//C�DIGOS E-SOCIAL
	aAdd( aBody, { "", "000001", "108201", "CONTRIBUI��O PREVIDENCI�RIA (CP) DESCONTADA DO SEGURADO EMPREGADO/AVULSO, AL�QUOTAS 8%, 9% OU 11%", "" } )
	aAdd( aBody, { "", "000002", "108202", "CP DESCONTADA DO SEGURADO EMPREGADO RURAL CURTO PRAZO, AL�QUOTA DE 8%, LEI 11718/2008", "" } )
	aAdd( aBody, { "", "000003", "108203", "CP DESCONTADA DO SEGURADO EMPREGADO DOM�STICO OU SEGURADO ESPECIAL, AL�QUOTA DE 8%, 9% OU 11%", "" } )
	aAdd( aBody, { "", "000004", "108204", "CP DESCONTADA DO SEGURADO ESPECIAL CURTO PRAZO, AL�QUOTA DE 8%, LEI 11718/2008", "" } )
	aAdd( aBody, { "", "000005", "108221", "CP DESCONTADA DO SEGURADO EMPREGADO/AVULSO 13�SAL�RIO, AL�QUOTAS 8%, 9% OU 11%", "" } )
	aAdd( aBody, { "", "000006", "108222", "CP DESCONTADA DO SEGURADO EMPREGADO RURAL CURTO PRAZO 13� SAL�RIO, AL�QUOTA DE 8%, LEI 11718/2008", "" } )
	aAdd( aBody, { "", "000007", "108223", "CP DESCONTADA DO SEGURADO EMPREGADO DOM�STICO OU SEGURADO ESPECIAL 13� SAL�RIO, AL�QUOTA DE 8%, 9% OU 11%", "" } )
	aAdd( aBody, { "", "000008", "108224", "CP DESCONTADA DO SEGURADO ESPECIAL CURTO PRAZO 13� SAL�RIO, AL�QUOTA DE 8%, LEI 11718/2008", "" } )
	aAdd( aBody, { "", "000009", "109901", "CP DESCONTADA DO CONTRIBUINTE INDIVIDUAL, AL�QUOTA DE 11%", "" } )
	aAdd( aBody, { "", "000010", "109902", "CP DESCONTADA DO CONTRIBUINTE INDIVIDUAL, AL�QUOTA DE 20%", "" } )
	aAdd( aBody, { "", "000011", "121802", "CONTRIBUI��O AO SEST, DESCONTADA DO TRANSPORTADOR AUT�NOMO, � AL�QUOTA DE 1,5%", "" } )
	aAdd( aBody, { "", "000012", "122102", "CONTRIBUI��O AO SENAT, DESCONTADA DO TRANSPORTADOR AUT�NOMO, � AL�QUOTA DE 1,0%", "" } )
	aAdd( aBody, { "", "000013", "056107", "IRRF MENSAL, 13� SAL�RIO E F�RIAS SOBRE TRABALHO ASSALARIADO NO PA�S OU AUSENTE NO EXTERIOR A SERVI�O DO PA�S, EXCETO SE CONTRATADO POR EMPREGADOR DOM�STICO", "" } )
	aAdd( aBody, { "", "000014", "056108", "IRRF MENSAL, 13� SAL�RIO E F�RIAS SOBRE TRABALHO ASSALARIADO NO PA�S OU AUSENTE NO EXTERIOR A SERVI�O DO PA�S, EMPREGADO DOM�STICO OU TRABALHADOR CONTRATADO POR SEGURADO", "" } )
	aAdd( aBody, { "", "000015", "056109", "IRRF 13� SAL�RIO NA RESCIS�O DE CONTRATO DE TRABALHO RELATIVO A EMPREGADOR SUJEITO A RECOLHIMENTO UNIFICADO", "" } )
	aAdd( aBody, { "", "000016", "058806", "IRRF SOBRE RENDIMENTO DO TRABALHO SEM V�NCULO EMPREGAT�CIO", "" } )
	aAdd( aBody, { "", "000017", "061001", "IRRF SOBRE RENDIMENTOS RELATIVOS A PRESTA��O DE SERVI�OS DE TRANSPORTE RODOVI�RIO INTERNACIONAL DE CARGA, PAGOS A TRANSPORTADOR AUT�NOMO PF RESIDENTE NO PARAGUAI", "" } )
	aAdd( aBody, { "", "000018", "328006", "IRRF SOBRE SERVI�OS PRESTADOS POR ASSOCIADOS DE COOPERATIVAS DE TRABALHO", "" } )
	aAdd( aBody, { "", "000019", "356201", "IRRF SOBRE PARTICIPA��O DOS TRABALHADORES EM LUCROS OU RESULTADOS (PLR)", "" } )
	aAdd( aBody, { "", "000020", "206201", "IRRF SOBRE REMUNERA��O INDIRETA A BENEFICI�RIO N�O IDENTIFICADO", "" } )

	//C�DIGOS SPED PIS COFINS
	aAdd( aBody, { "", "000021", "0067", "PRODUTOS-RETEN��O EM PAGAMENTOS POR �RG�OS P�BLICOS-OPERA��ES INTRA OR�AMENT�RIAS", "" } )
	aAdd( aBody, { "", "000022", "0070", "TRANSPORTE DE PASSAGEIROS-RETEN��O EM PAGAMENTOS POR �RG�OS P�BLICOS-OPERA��ES INTRA OR�AMENT�RIAS", "" } )
	aAdd( aBody, { "", "000023", "0082", "FINANCEIRAS-RETEN��O EM PAGAMENTOS POR �RG�OS P�BLICOS-OPERA��ES INTRA OR�AMENT�RIAS", "" } )
	aAdd( aBody, { "", "000024", "0095", "SERVI�OS-RETEN��O EM PAGAMENTOS POR �RG�OS P�BLICOS-OPERA��ES INTRA OR�AMENT�RIAS", "" } )
	aAdd( aBody, { "", "000025", "0123", "BENS E SERVI�OS ADQUIRIDOS DE SOCIEDADES COOPERATIVAS E ASSOCIA��ES PROFISSIONAIS OU ASSEMELHADAS - RETIDO POR �RG�O P�BLICO - OPERA��ES INTRA-OR�AMENT�RIAS", "" } )
	aAdd( aBody, { "", "000026", "3316", "COFINS - RET FONTE PAG PJ/PJ D PRIV -L OFICIO", "" } )
	aAdd( aBody, { "", "000027", "3332", "COFINS - RET PAGT ENT PUBL A PJ - L OFICIO", "" } )
	aAdd( aBody, { "", "000028", "3359", "PIS - RET FONTE PAG PJ/PJ DIR PRIV - L OFICIO", "" } )
	aAdd( aBody, { "", "000029", "3360", "PIS - RET FONTE PAGT ENT PUBL A PJ - L OFICIO", "" } )
	aAdd( aBody, { "", "000030", "3346", "COFINS - RETEN��O NA FONTE/AQUISI��O DE AUTOPE�AS", "" } )
	aAdd( aBody, { "", "000031", "3370", "PIS/PASEP - RETEN��O NA FONTE/AQUISI��O DE AUTOPE�AS", "" } )
	aAdd( aBody, { "", "000032", "4085", "RET CONTRIB PAGT EST/DF/MUNIC - BENS/SERVI�OS - CSLL/COFINS/PIS", "" } )
	aAdd( aBody, { "", "000033", "4166", "COFINS - REGIME ESPECIAL DE TRIBUTA��O DO PATRIM�NIO DE AFETA��O", "" } )
	aAdd( aBody, { "", "000034", "4407", "COFINS - RET FONTE PAGT ESTADOS/DF/MUNIC�PIOS - BENS/SERVI�OS", "" } )
	aAdd( aBody, { "", "000035", "4409", "PIS - RET FONTE PAGT ESTADOS/DF/MUNIC�PIOS - BENS/SERVI�OS", "" } )
	aAdd( aBody, { "", "000036", "5952", "RETEN��O DE CONTRIBUI��ES SOBRE PAGAMENTOS DE PESSOA JUR�DICA A PESSOA JUR�DICA DE DIREITO PRIVADO - CSLL, COFINS E PIS", "" } )
	aAdd( aBody, { "", "000037", "5960", "COFINS - RETEN��O SOBRE PAGAMENTOS DE PESSOA JUR�DICA A PESSOA JUR�DICA DE DIREITO PRIVADO (ART. 30 DA LEI N� 10.833/2003)", "" } )
	aAdd( aBody, { "", "000038", "5979", "PIS - RETEN��O SOBRE PAGAMENTOS DE PESSOA JUR�DICA A PESSOA JUR�DICA DE DIREITO PRIVADO", "" } )
	aAdd( aBody, { "", "000039", "6147", "PRODUTOS - RETEN��O EM PAGAMENTOS POR �RG�O P�BLICO", "" } )
	aAdd( aBody, { "", "000040", "6175", "TRANSPORTE DE PASSAGEIROS - RETEN��O EM PAGAMENTO POR �RG�O P�BLICO", "" } )
	aAdd( aBody, { "", "000041", "6188", "FINANCEIRAS - RETEN��O EM PAGAMENTO POR �RG�O P�BLICO", "" } )
	aAdd( aBody, { "", "000042", "6190", "SERVI�OS - RETEN��O EM PAGAMENTO POR �RG�O P�BLICO", "" } )
	aAdd( aBody, { "", "000042", "6215", "ENTIDADES ISENTAS - RETEN��O EM PAGAMENTO POR �RG�O P�BLICO", "" } )
	aAdd( aBody, { "", "000043", "6230", "PIS - RETEN��O NA FONTE SOBRE PAGAMENTO EFETUADO POR �RG�O P�BLICO � PESSOA JUR�DICA", "" } )
	aAdd( aBody, { "", "000044", "6243", "COFINS - RETEN��O NA FONTE SOBRE PAGAMENTO � PESSOA JUR�DICA (ART. 34 DA LEI N� 10.833/2003", "" } )
	aAdd( aBody, { "", "000045", "8863", "BENS OU SERVI�OS ADQUIRIDOS DE SOCIEDADES COOPERATIVAS E ASSOCIA��ES PROFISSIONAIS OU ASSEMELHADAS - RETIDO POR �RG�O P�BLICO", "" } )
	aAdd( aBody, { "", "000046", "9060", "QUEROSENE DE AVIA��O ADQUIRIDO DE PRODUTOR OU IMPORTADOR - RETIDO POR �RG�O P�BLICO", "" } )
	aAdd( aBody, { "", "000047", "298501", "CONTRIBUI��O PREVIDENCI�RIA SOBRE RECEITA BRUTA - ART. 7� DA LEI 12.546/2011", "" } )
	aAdd( aBody, { "", "000048", "298503", "CONTRIBUI��O PREVIDENCI�RIA SOBRE RECEITA BRUTA - ART. 7� DA LEI 12.546/2011 - SCP", "" } )
	aAdd( aBody, { "", "000049", "299101", "CONTRIBUI��O PREVIDENCI�RIA SOBRE RECEITA BRUTA - ART. 8� DA LEI 12.546/2011", "" } )
	aAdd( aBody, { "", "000050", "299103", "CONTRIBUI��O PREVIDENCI�RIA SOBRE RECEITA BRUTA - ART. 8� DA LEI 12.546/2011 - SCP", "" } )

	//C�DIGOS SPED FISCAL
	aAdd( aBody, { "", "000051", "100013", "ICMS COMUNICA��O", "" } )
	aAdd( aBody, { "", "000052", "100021", "ICMS ENERGIA EL�TRICA", "" } )
	aAdd( aBody, { "", "000053", "100030", "ICMS TRANSPORTE", "" } )
	aAdd( aBody, { "", "000054", "100048", "ICMS SUBSTITUI��O TRIBUT�RIA POR APURA��O", "" } )
	aAdd( aBody, { "", "000055", "100056", "ICMS IMPORTA��O", "" } )
	aAdd( aBody, { "", "000056", "100064", "ICMS AUTUA��O FISCAL", "" } )
	aAdd( aBody, { "", "000057", "100072", "ICMS PARCELAMENTO", "" } )
	aAdd( aBody, { "", "000058", "100080", "ICMS RECOLHIMENTOS ESPECIAIS", "" } )
	aAdd( aBody, { "", "000059", "100099", "ICMS SUBST. TRIBUT�RIA POR OPERA��O", "" } )
	aAdd( aBody, { "", "000060", "100102", "ICMS CONSUMIDOR FINAL N�O CONTRIBUINTE OUTRA UF POR OPERA��O", "" } )
	aAdd( aBody, { "", "000061", "100110", "ICMS CONSUMIDOR FINAL N�O CONTRIBUINTE OUTRA UF POR APURA��O", "" } )
	aAdd( aBody, { "", "000062", "100129", "ICMS FUNDO ESTADUAL DE COMBATE � POBREZA POR OPERA��O", "" } )
	aAdd( aBody, { "", "000063", "100137", "ICMS FUNDO ESTADUAL DE COMBATE � POBREZA POR APURA��O", "" } )
	aAdd( aBody, { "", "000064", "150010", "ICMS D�VIDA ATIVA", "" } )
	aAdd( aBody, { "", "000065", "500011", "MULTA P/ INFRA��O � OBRIGA��O ACESS�RIA", "" } )
	aAdd( aBody, { "", "000066", "600016", "TAXA", "" } )

	//C�DIGOS ECF
	aAdd( aBody, { "", "000067", "4085", "RET CONTRIB PAGT EST/DF/MUNIC - BENS/SERVI�OS - CSLL/COFINS/PIS", "" } )
	aAdd( aBody, { "", "000068", "4397", "CSLL - RET FONTE PAGT ESTADOS/DF/MUNIC�PIOS - BENS/SERVI�OS", "" } )
	aAdd( aBody, { "", "000069", "5928", "IRRF -REND DECOR DECIS�O JUSTI�A FEDERAL, EXCETO ART 12A L 7713/88", "" } )
	aAdd( aBody, { "", "000070", "5936", "IRRF - REND DECOR DEC JUSTI�A TRABALHO, EXCETO ART 12A L. 7.713/88", "" } )
	aAdd( aBody, { "", "000071", "5944", "IRRF - PAGAMENTO DE PJ A PJ POR SERVI�OS DE FACTORING", "" } )
	aAdd( aBody, { "", "000072", "6147", "PRODUTOS - RETEN��O EM PAGAMENTOS POR �RG�O P�BLICO", "" } )
	aAdd( aBody, { "", "000073", "6175", "TRANSPORTE DE PASSAGEIROS - RETEN��O EM PAGAMENTO POR �RG�O P�BLICO", "" } )
	aAdd( aBody, { "", "000074", "6188", "FINANCEIRAS - RETEN��O EM PAGAMENTO POR �RG�O P�BLICO", "" } )
	aAdd( aBody, { "", "000075", "6190", "SERVI�OS - RETEN��O EM PAGAMENTO POR �RG�O P�BLICO", "" } )
	aAdd( aBody, { "", "000076", "6228", "CSLL - RETEN��O NA FONTE SOBRE PAGAMENTO DE �RG�O PUBLICO A PESSOA JUR�DICA", "" } )
	aAdd( aBody, { "", "000077", "6256", "IRPJ - PAGAMENTO EFETUADO POR �RG�O P�BLICO", "" } )
	aAdd( aBody, { "", "000078", "8739", "GASOL/DIESEL/GLP E ALCOOL NO VAREJO-R ORG PUB", "" } )
	aAdd( aBody, { "", "000079", "8767", "MEDICAMENTO ADQUIR DISTRIB/VAREJ-RET ORG PUBL", "" } )
	aAdd( aBody, { "", "000080", "8850", "TRANSPORTE INTERNACIONAL PASSAGEIRO-R ORG PUB", "" } )
	aAdd( aBody, { "", "000081", "8863", "BENS OU SERVI�OS ADQUIRIDOS DE SOCIEDADES COOPERATIVAS E ASSOCIA��O", "" } )
	aAdd( aBody, { "", "000082", "9060", "QUEROSENE DE AVIA��O ADQUIRIDO DE PRODUTOR OU IMPORTADOR - RETIDO", "" } )
	aAdd( aBody, { "", "000083", "9997", "OUTRAS RETEN��ES N�O ESPECIFICADAS ACIMA", "" } )
	aAdd( aBody, { "", "000084", "916",  "IRRF - PR�MIOS OBTIDOS EM CONCURSOS SORTEIOS", "" } )
	aAdd( aBody, { "", "000085", "924",  "IRRF - DEMAIS RENDIMENTOS CAPITAL", "" } )
	aAdd( aBody, { "", "000086", "1708", "IRRF - REMUNERA��O SERVI�OS PRESTADOS POR PESSOA JUR�DICA", "" } )
	aAdd( aBody, { "", "000087", "3277", "IRRF - RENDIMENTOS DE PARTES BENEFICI�RIAS OU DE FUNDADOR", "" } )
	aAdd( aBody, { "", "000088", "3426", "IRRF - APLICA��ES FINANCEIRAS DE RENDA FIXA - PESSOA JUR�DICA", "" } )
	aAdd( aBody, { "", "000089", "5204", "IRRF - JUROS INDENIZA��ES LUCROS CESSANTES", "" } )
	aAdd( aBody, { "", "000090", "5232", "IRRF - APLICA��ES FINANCEIRAS EM FUNDOS DE INVESTIMENTO IMOBILI�RIOS", "" } )
	aAdd( aBody, { "", "000091", "5273", "IRRF - OPERA��ES DE SWAP (ART. 74 L 8981/95)", "" } )
	aAdd( aBody, { "", "000092", "5557", "IRRF - GANHOS L�QUIDOS EM OPERA��ES EM BOLSAS E ASSEMELHADOS", "" } )
	aAdd( aBody, { "", "000093", "5706", "IRRF - JUROS SOBRE O CAPITAL PR�PRIO", "" } )
	aAdd( aBody, { "", "000094", "5952", "RETEN��O CONTRIBUI��ES PAGT DE PJ A PJ DIR PRIV - CSLL/COFINS/PIS", "" } )
	aAdd( aBody, { "", "000095", "5987", "CSLL - RETEN��O PAGAMENTOS DE PJ A PJ DIREITO PRIVADO", "" } )
	aAdd( aBody, { "", "000096", "6800", "IRRF - APLICA��ES FINANCEIRAS EM FUNDOS DE INVESTIMENTO DE RENDA FIXA", "" } )
	aAdd( aBody, { "", "000097", "6813", "IRRF - FUNDOS DE INVESTIMENTO - A��ES", "" } )
	aAdd( aBody, { "", "000098", "8045", "IRRF - OUTROS RENDIMENTOS", "" } )
	aAdd( aBody, { "", "000099", "8468", "IRRF - DAY-TRADE OPERA��ES EM BOLSA", "" } )
	aAdd( aBody, { "", "000100", "9385", "IRRF - MULTAS E VANTAGENS", "" } )
	aAdd( aBody, { "", "000101", "9998", "CSLL - OUTRAS RETEN��ES N�O ESPECIFICADAS ACIMA", "" } )
	aAdd( aBody, { "", "000102", "9999", "IRPJ - OUTRAS RETEN��ES N�O ESPECIFICADAS ACIMA", "" } )

	aAdd( aRet, { aHeader, aBody } )

EndIf

Return( aRet )