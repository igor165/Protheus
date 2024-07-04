#INCLUDE "Protheus.CH"
#INCLUDE "FwMVCDef.CH"
#INCLUDE "TAFA465.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA465

Cadastro MVC de Informações de identificação do registrador da CAT

@Author	Paulo V.B. Santana
@Since		05/01/2017
@Version	1.0
 
/*/
//------------------------------------------------------------------
Function TAFA465()

Local oBrw := FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Codificação de Acidente de Trabalho"
oBrw:SetAlias( "T5G" )
oBrw:SetMenuDef( "TAFA465" )
T5G->( DBSetOrder( 1 ) )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@Author	Paulo V.B. Santana
@Since		05/01/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA465",,,, .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@Return oModel - Objeto do Modelo MVC

@Author	Paulo V.B. Santana
@Since		05/01/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT5G := FwFormStruct( 1, "T5G" )
Local oModel   := MpFormModel():New( "TAFA465" )

oModel:AddFields( "MODEL_T5G", /*cOwner*/, oStruT5G )
oModel:GetModel ( "MODEL_T5G" ):SetPrimaryKey( { "T5G_FILIAL", "T5G_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@Return oView - Objeto da View MVC

@Author	Paulo V.B. Santana
@Since		05/01/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA465" )
Local oStruT5G := FwFormStruct( 2, "T5G" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_T5G", oStruT5G, "MODEL_T5G" )
oView:EnableTitleView( "VIEW_T5G", STR0001 ) //"Tipos de Benefícios Previdenciários dos Regimes Próprios de Previdência"
oView:CreateHorizontalBox( "FIELDST5G", 100 )
oView:SetOwnerView( "VIEW_T5G", "FIELDST5G" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida:
T5G - (Tipos Benef. Previdenciários  ) 
Tipos de Benefícios Previdenciários dos Regimes Próprios de Previdência

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Paulo Vilas Boas Santana
@Since		05/01/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1013

If nVerEmp < nVerAtu
	aAdd( aHeader, "T5G_FILIAL" )
	aAdd( aHeader, "T5G_ID" )
	aAdd( aHeader, "T5G_CODIGO" )
	aAdd( aHeader, "T5G_DESCRI" )
	aAdd( aHeader, "T5G_VALIDA" )

	aAdd( aBody, { " ", "000001","01","Aposentadoria Voluntária por Idade e Tempo de Contribuição - Proventos Integrais: Art. 40, § 1°, III 'a' da CF, Redação EC 20/98", " " } )
	aAdd( aBody, { " ", "000002","02","Aposentadoria por Idade - Proventos proporcionais: Art. 40, III, c da CF redação original - Anterior à EC 20/1998", " " } )
	aAdd( aBody, { " ", "000003","03","Aposentadoria por Invalidez - Proventos integrais ou proporcionais: Art. 40, I da CF redação original - anterior à EC 20/1998", " " } )
	aAdd( aBody, { " ", "000004","04","Aposentadoria Compulsória - Proventos proporcionais: Art. 40, II da CF redação original, anterior à EC 20/1998 *", " " } )
	aAdd( aBody, { " ", "000005","05","Aposentadoria por Tempo de Serviço Integral - Art. 40, III, a da CF redação original - anterior à EC 20/1998 *", " " } )
	aAdd( aBody, { " ", "000006","06","Aposentadoria por Tempo de Serviço Proporcional - Art. 40, III, a da CF redação original - anterior à EC 20/1998 *", " " } )
	aAdd( aBody, { " ", "000007","07","Aposentadoria Compulsória Proporcional calculada sobre a última remuneração- Art. 40, § 1°, Inciso II da CF, Redação EC 20/1998", " " } )
	aAdd( aBody, { " ", "000008","08","Aposentadoria Compulsória Proporcional calculada pela média - Art. 40, § 1° Inciso II da CF, Redação EC 41/03", " " } )
	aAdd( aBody, { " ", "000009","09","Aposentadoria Compulsória Proporcional calculada pela média - Art. 40, § 1° Inciso II da CF, Redação EC 41/03, c/c EC 88/2015", " " } )
	aAdd( aBody, { " ", "000010","10","Aposentadoria Compulsória Proporcional calculada pela média - Art. 40, § 1° Inciso II da CF, Redação EC 41/03, c/c LC 152/2015", " " } )
	aAdd( aBody, { " ", "000011","11","Aposentadoria - Magistrado, Membro do MP e TC - Proventos Integrais correspondentes à última remuneração: Regra de Transição do Art. 8°, da EC 20/98", " " } )
	aAdd( aBody, { " ", "000012","12","Aposentadoria - Proventos Integrais correspondentes à última remuneração - Regra de Transição do Art. 8°, da EC 20/98: Geral", " " } )
	aAdd( aBody, { " ", "000013","13","Aposentadoria Especial do Professor - Regra de Transição do Art. 8°, da EC 20/98: Proventos Integrais correspondentes à última remuneração.", " " } )
	aAdd( aBody, { " ", "000014","14","Aposentadoria com proventos proporcionais calculados sobre a última remuneraçãoRegra de Transição do Art. 8°, da EC20/98 - Geral", " " } )
	aAdd( aBody, { " ", "000015","15","Aposentadoria - Regra de Transição do Art. 3°, da EC 47/05: Proventos Integrais correspondentes à última remuneração", " " } )
	aAdd( aBody, { " ", "000016","16","Aposentadoria Especial de Professor - Regra de Transição do Art. 2°, da EC41/03: Proventos pela Média com redutor (Implementação a partir de 01/01/2006)", " " } )
	aAdd( aBody, { " ", "000017","17","Aposentadoria Especial de Professor - Regra de Transição do Art. 2°, da EC41/03: Proventos pela Média com redutor (Implementação até 31/12/2005)", " " } )
	aAdd( aBody, { " ", "000018","18","Aposentadoria Magistrado, Membro do MP e TC (homem) - Regra de Transição do Art. 2°, da EC41/03: Proventos pela Média com redutor (Implementação a partir de 01/01/2006)", " " } )
	aAdd( aBody, { " ", "000019","19","Aposentadoria Magistrado, Membro do MP e TC - Regra de Transição do Art. 2°, da EC41/03: Proventos pela Média com redutor (Implementação até 31/12/2005)", " " } )
	aAdd( aBody, { " ", "000020","20","Aposentadoria Voluntária - Regra de Transição do Art. 2°, da EC 41/03 - Proventos pela Média com redutor - Geral (Implementação a partir de 01/01/2006)", " " } )
	aAdd( aBody, { " ", "000021","21","Aposentadoria Voluntária - Regra de Transição do Art. 2°, da EC 41/03 - Proventos pela Média reduzida - Geral (Implementação até 31/12/2005)", " " } )
	aAdd( aBody, { " ", "000022","22","Aposentadoria Voluntária - Regra de Transição do Art. 6°, da EC41/03: Proventos Integrais correspondentes á ultima remuneração do cargo - Geral", " " } )
	aAdd( aBody, { " ", "000023","23","Aposentadoria Voluntária Professor Educação infantil, ensino fundamental e médioRegra de Transição do Art. 6°, da EC41/03: Proventos Integrais correspondentes à última remuneração do cargo", " " } )
	aAdd( aBody, { " ", "000024","24","Aposentadoria Voluntária por Idade - Proventos Proporcionais calculados sobre a última remuneração do cargo: Art. 40, § 1°, Inciso III, alínea 'b'' CF, Redação EC 20/98", " " } )
	aAdd( aBody, { " ", "000025","25","Aposentadoria Voluntária por Idade - Proventos pela Média proporcionais - Art. 40, § 1°, Inciso III, alínea 'b' CF, Redação EC 41/03", " " } )
	aAdd( aBody, { " ", "000026","26","Aposentadoria Voluntária por Idade e por Tempo de Contribuição - Proventos pela Média: Art. 40, § 1°, Inciso III, aliena 'a', CF, Redação eC 41/03", " " } )
	aAdd( aBody, { " ", "000027","27","Aposentadoria Voluntária por Tempo de Contribuição - Especial do professor de q/q nível de ensino - Art. 40, III, alínea b, da CF- Red. Original até EC 20/1998", " " } )
	aAdd( aBody, { " ", "000028","28","Aposentadoria Voluntária por idade e Tempo de Contribuição - Especial do professor ed. infantil, ensino fundamental e médio - Art. 40, § 1°, Inciso III, alínea a, c/c § 5° da CF red. da EC 20/1998 )", " " } )
	aAdd( aBody, { " ", "000029","29","Aposentadoria Voluntária por idade e Tempo de Contribuição - Especial de Professor - Proventos pela Média: Art. 40, § 1°, Inciso III, alínea 'a', C/C § 5° da CF, Redação EC 41/2003", " " } )
	aAdd( aBody, { " ", "000030","30","Aposentadoria por Invalidez (proporcionais ou integrais, calculadas com base na última remuneração do cargo) - Art. 40, Inciso I, Redação Original, CF", " " } )
	aAdd( aBody, { " ", "000031","31","Aposentadoria por Invalidez (proporcionais ou integrais , calculadas com base na última remuneração do cargo) - Art. 40, § 1°, Inciso I da CF com Redação da EC 20/1998", " " } )
	aAdd( aBody, { " ", "000032","32","Aposentadoria por Invalidez (proporcionais ou integrais, calculadas pela média) - Art. 40, § 1°, Inciso I da CF com Redação da EC 41/2003", " " } )
	aAdd( aBody, { " ", "000033","33","Aposentadoria por Invalidez (proporcionais ou integrais calculadas com base na última remuneração do cargo) -Art. 40 ° 1°, Inciso I da CF C/C combinado com Art. 6a- A da EC 70/2012", " " } )
	aAdd( aBody, { " ", "000034","34","Reforma por invalidez", " " } )
	aAdd( aBody, { " ", "000035","35","Reserva Remunerada Compulsória", " " } )
	aAdd( aBody, { " ", "000036","36","Reserva Remunerada Integral", " " } )
	aAdd( aBody, { " ", "000037","37","Reserva Remunerada Proporcional", " " } )
	aAdd( aBody, { " ", "000038","38","Auxílio Doença - Conforme lei do Ente", " " } )
	aAdd( aBody, { " ", "000039","39","Auxílio Reclusão - Art. 13 da EC 20/1998 c/c lei do Ente", " " } )
	aAdd( aBody, { " ", "000040","40","Pensão por Morte", " " } )
	aAdd( aBody, { " ", "000041","41","Salário Família - Art. 13 da EC 20/1998 c/c lei do Ente", " " } )
	aAdd( aBody, { " ", "000042","42","Salário Maternidade - Art. 7°, XVIII c/c art. 39, § 3° da Constituição Federal", " " } )
	aAdd( aBody, { " ", "000043","43","Complementação de Aposentadoria do Regime Geral de Previdência Social (RGPS)", " " } )
	aAdd( aBody, { " ", "000044","44","Complementação de Pensão por Morte do Regime Geral de Previdência Social (RGPS)", " " } )
	aAdd( aBody, { " ", "000045","91","Aposentadoria sem paridade concedida antes do início de vigência do eSocial", " " } )
	aAdd( aBody, { " ", "000046","92","Aposentadoria com paridade concedida antes do início de vigência do eSocial", " " } )
	aAdd( aBody, { " ", "000047","93","Aposentadoria por invalidez com paridade concedida antes do início de vigência do eSocial", " " } )
	aAdd( aBody, { " ", "000048","94","Aposentadoria por invalidez sem paridade concedida antes do início de vigência do eSocial", " " } )
	aAdd( aBody, { " ", "000049","95","Transferência para reserva concedida antes do início de vigência do eSocial", " " } )
	aAdd( aBody, { " ", "000050","96","Reforma concedida antes do início de vigência do eSocial", " " } )
	aAdd( aBody, { " ", "000051","97","Pensão por morte com paridade concedida antes do início de vigência do eSocial", " " } )
	aAdd( aBody, { " ", "000052","98","Pensão por morte sem paridade concedida antes do início de vigência do eSocial", " " } )
	aAdd( aBody, { " ", "000053","99","Outros Benefícios previdenciários concedidos antes do início de vigência do eSocial", " " } )	

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )