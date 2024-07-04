#INCLUDE "Protheus.CH"
#INCLUDE "FwMVCDef.CH"
#INCLUDE "TAFA442.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA442

Cadastro MVC de Informações de identificação do registrador da CAT

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
 
/*/
//------------------------------------------------------------------
Function TAFA442()

Local oBrw := FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Codificação de Acidente de Trabalho"
oBrw:SetAlias( "LE5" )
oBrw:SetMenuDef( "TAFA442" )
LE5->( DBSetOrder( 1 ) )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA442",,,, .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@Return oModel - Objeto do Modelo MVC

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruLE5 := FwFormStruct( 1, "LE5" )
Local oModel   := MpFormModel():New( "TAFA442" )

oModel:AddFields( "MODEL_LE5", /*cOwner*/, oStruLE5 )
oModel:GetModel ( "MODEL_LE5" ):SetPrimaryKey( { "LE5_FILIAL", "LE5_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@Return oView - Objeto da View MVC

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA442" )
Local oStruLE5 := FwFormStruct( 2, "LE5" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_LE5", oStruLE5, "MODEL_LE5" )
oView:EnableTitleView( "VIEW_LE5", STR0001 ) //"Informações de identificação do registrador da CAT"
oView:CreateHorizontalBox( "FIELDSLE5", 100 )
oView:SetOwnerView( "VIEW_LE5", "FIELDSLE5" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida:
LE5 - (Info. iden. registrador da CAT) 
Informações de identificação do registrador da CAT

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1032.01

If nVerEmp < nVerAtu
	aAdd( aHeader, "LE5_FILIAL" )
	aAdd( aHeader, "LE5_ID" )
	aAdd( aHeader, "LE5_CODIGO" )
	aAdd( aHeader, "LE5_DESCRI" )
	aAdd( aHeader, "LE5_VALIDA" )

	aAdd( aBody, { "", "000001", "1.0.01", "LESÃO CORPORAL  QUE CAUSE A MORTE OU A PERDA OU REDUÇÃO, PERMANENTE OU TEMPORÁRIA, DA CAPACIDADE PARA O TRABALHO, DESDE QUE NAO ENQUADRADA EM NENHUM DOS DEMAIS CODIGOS.", "" } )
	aAdd( aBody, { "", "000002", "1.0.02", "PERTURBAÇÃO FUNCIONAL QUE CAUSE A MORTE OU A PERDA OU REDUÇÃO, PERMANENTE OU TEMPORARIA, DA CAPACIDADE PARA O TRABALHO, DESDE QUE NÃO ENQUADRADA EM NENHUM DOS DEMAIS CODIGOS.", "" } )
	aAdd( aBody, { "", "000003", "2.0.01", "DOENÇA PROFISSIONAL, ASSIM ENTENDIDA A PRODUZIDA OU DESENCADEADA PELO EXERCICIO DO TRABALHO PECULIAR A DETERMINADA ATIVIDADE E CONSTANTE DA RESPECTIVA RELAÇÃO ELABORADA PELO MINISTERIO TRAB. E PREVID.SOCIAL, DESDE QUE NAO ENQUADRADA EM NENHUM DOS DEMAIS CÓDIGOS.", "" } )
	aAdd( aBody, { "", "000004", "2.0.02", "DOENÇA DO TRABALHO, ASSIM ADQUIRIDA OU DESENCADEADA EM FUNÇÃO DE CONDIÇÕES ESPECIAIS EM QUE O TRABALHO E REALIZADO E COM ELE SE RELACIONE DIRETAMENTE, CONSTANTE DA RESPECTIVA RELAÇÃO ELABORADA PELO MINIST. TRAB. E PREVID. SOCIAL, DESDE QUE NÃO ENQUADRADA NOS DEMAIS CÓDIGOS.", "" } )
	aAdd( aBody, { "", "000005", "2.0.03", "DOENÇA PROVENIENTE DE CONTAMINAÇÃO ACIDENTAL DO EMPREGADO NO EXERCÍCIO DE SUA ATIVIDADE.", "" } )
	aAdd( aBody, { "", "000006", "2.0.04", "DOENÇA ENDEMICA ADQUIRIDA POR SEGURADO HABITANTE DE REGIÃO EM QUE ELA SE DESENVOLVA QUANDO RESULTANTE DE EXPOSIÇÃO OU CONTATO DIRETO DETERMINADO PELA NATUREZA DO TRABALHO.", "" } )
	aAdd( aBody, { "", "000007", "2.0.05", "DOENÇA PROFISSIONAL OU DO TRABALHO NAO INCLUIDA NA RELAÇÃO ELABORADA PELO MINISTERIO DO TRABALHO E PREVIDENCIA SOCIAL QUANDO RESULTANTE DAS CONDIÇOES ESPECIAIS EM QUE O TRABALHO E EXECUTADO E COM ELE SE RELACIONA DIRETAMENTE.", "" } )
	aAdd( aBody, { "", "000008", "2.0.06", "DOENÇA PROFISSIONAL OU DO TRABALHO ENQUADRADA NA RELAÇÃO ELABORADA PELO MINISTÉRIO DO TRABALHO E PREVIDÊNCIA SOCIAL RELATIVA NEXO TÉCNICO EPIDEMIOLOGICO PREVIDENCIÁRIO - NTEP.", "" } )
	aAdd( aBody, { "", "000009", "3.0.01", "ACIDENTE LIGADO AO TRABALHO QUE, EMBORA NÃO TENHA SIDO A CAUSA ÚNICA, HAJA CONTRIBUÍDO DIRETAMENTE PARA A MORTE DO SEGURADO, PARA REDUÇÃO OU PERDA DA SUA CAPACIDADE PARA O TRABALHO, OU PRODUZIDO LESÃO QUE EXIJA ATENÇÃO MEDICA PARA A SUA RECUPERAÇÃO.", "" } )
	aAdd( aBody, { "", "000010", "3.0.02", "ACIDENTE SOFRIDO PELO SEGURADO NO LOCAL E NO HORÁRIO DO TRABALHO, EM CONSEQÜENCIA DE  ATO DE AGRESSÃO, SABOTAGEM OU TERRORISMO PRATICADO POR TERCEIRO OU COMPANHEIRO DE TRABALHO.", "" } )
	aAdd( aBody, { "", "000011", "3.0.03", "ACIDENTE SOFRIDO PELO SEGURADO NO LOCAL E NO HORÁRIO DO TRABALHO, EM CONSEQÜENCIA DE OFENSA FISICA INTENCIONAL, INCLUSIVE DE TERCEIRO, POR MOTIVO DE DISPUTA RELACIONADA AO TRABALHO.", "" } )
	aAdd( aBody, { "", "000012", "3.0.04", "ACIDENTE SOFRIDO PELO SEGURADO NO LOCAL E NO HORÁRIO DO TRABALHO, EM CONSEQÜENCIA DE ATO DE IMPRUDÊNCIA, DE NEGLIGÊNCIA OU DE IMPERICIA DE TERCEIRO OU DE COMPANHEIRO DE TRABALHO.", "" } )
	aAdd( aBody, { "", "000013", "3.0.05", "ACIDENTE SOFRIDO PELO SEGURADO NO LOCAL E NO HORÁRIO DO TRABALHO, EM CONSEQÜENCIA DE ATO DE PESSOA PRIVADA DO USO DA RAZÃO.", "" } )
	aAdd( aBody, { "", "000014", "3.0.06", "ACIDENTE SOFRIDO PELO SEGURADO NO LOCAL E NO HORÁRIO DO TRABALHO, EM CONSEQÜENCIA DE DESABAMENTO, INUNDAÇÃO, INCENDIO E OUTROS CASOS FORTUITOS OU DECORRENTES DE FORÇA MAIOR.", "" } )
	aAdd( aBody, { "", "000015", "3.0.07", "ACIDENTE SOFRIDO PELO SEGURADO AINDA QUE FORA DO LOCAL E HORÁRIO DE TRABALHO NA EXECUÇÃO DE ORDEM OU NA REALIZAÇÃO DE SERVIÇO SOB A AUTORIDADE DA EMPRESA.", "" } )
	aAdd( aBody, { "", "000016", "3.0.08", "ACIDENTE SOFRIDO PELO SEGURADO AINDA QUE FORA DO LOCAL E HORÁRIO DE TRABALHO NA PRESTAÇÃO ESPONTANEA DE QUALQUER SERVIÇO A EMPRESA PARA LHE EVITAR PREJUÍZO OU PROPORCIONAR PROVEITO.", "" } )
	aAdd( aBody, { "", "000017", "4.0.01", "SUSPEITA DE DOENÇAS PROFISSIONAIS OU DO TRABALHOS PRODUZIDAS PELAS CONDIÇOES ESPECIAIS DE TRABALHO, NOS TERMOS DO ART 169 DA CLT.", "" } )
	aAdd( aBody, { "", "000018", "4.0.02", "CONSTATAÇÃO DE OCORRÊNCIA AGRAVAMENTO DOENÇAS PROFISSIONAIS, ATRAVÉS EXAMES MEDICOS QUE INCLUAM OS DEFINIDOS NA NR07; OU VERIFICADAS ALTERAÇÕES QUE REVELEM QUALQUER TIPO DE DISFUNÇÃO DE ORGÃO OU SISTEMA BIOLÓGICO ATRAVÉS DOS EXAMES DO QUADRO I (APENAS AQUELES COM INTERPRETAÇÃO SC) E II, E DO ITEM 7.4.2.3 DESTA NR, MESMO SEM SINTOMATOLOGIA, CABERÁ AO MÉDICO-COORDENADOR OU ENCARREGADO.", "" } )
	aAdd( aBody, { "", "000019", "5.0.01", "OUTROS.", "" } )
	aAdd( aBody, { "", "000020", "3.0.09", "ACID. SOFRIDO PELO SEGURADO AINDA QUE FORA DO LOCAL/HOR. TRAB. EM VIAGEM A SERV. DA EMP., INCLUSIVE P/ ESTUDO QUANDO FINAN. POR ESTA DENTRO DE SEUS PLANOS PARA CAPAC. DE MO., INDEP. DO MEIO DE LOCOMOÇÃO UTILIZADO, INCLUSIVE DE PROPRIEDADE SEGURADO.", "" } )
	aAdd( aBody, { "", "000021", "3.0.10", "ACIDENTE SOFRIDO PELO SEGURADO AINDA QUE FORA DO LOCAL E HORÁRIO DE TRABALHO NO PERCURSO DA RESIDÊNCIA PARA O LOCAL DE TRABALHO OU DESTE PARA AQUELA, QUALQUER QUE SEJA O MEIO DE LOCOMOÇÃO, INCLUSIVE VEÍCULO DE PROPRIEDADE DO SEGURADO.", "" } )
	aAdd( aBody, { "", "000022", "3.0.11", "ACIDENTE SOFRIDO PELO SEGURADO NOS PERIODOS DESTINADOS A REFEIÇÃO OU DESCANSO, OU POR OCASIÃO DA SATISFAÇÃO DE OUTRAS NECESSIDADES FISIOLOGICAS, NO LOCAL DO TRABALHO OU DURANTE ESTE.", "" } )
	
	aAdd( aRet, { aHeader, aBody } )

EndIf

Return( aRet )