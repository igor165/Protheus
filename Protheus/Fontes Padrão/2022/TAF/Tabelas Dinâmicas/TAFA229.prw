#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA229.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA229
Cadastro MVC de Códigos de Motivos de Afastamento - Tabela 18

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA229()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Códigos de Motivos de Afastamento 	
oBrw:SetAlias( 'C8N')
oBrw:SetMenuDef( 'TAFA229' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA229" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruC8N := FWFormStruct( 1, 'C8N' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA229' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_C8N', /*cOwner*/, oStruC8N)
oModel:GetModel( 'MODEL_C8N' ):SetPrimaryKey( { 'C8N_FILIAL' , 'C8N_ID' } )
Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel( 'TAFA229' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruC8N		:= FWFormStruct( 2, 'C8N' )// Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C8N', oStruC8N, 'MODEL_C8N' )

oView:EnableTitleView( 'VIEW_C8N',  STR0001 ) //Códigos de Motivos de Afastamento 

oView:CreateHorizontalBox( 'FIELDSC8N', 100 )

oView:SetOwnerView( 'VIEW_C8N', 'FIELDSC8N' )

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
Static Function FAtuCont(nVerEmp, nVerAtu)

	Local aHeader	:=	{}
	Local aBody		:=	{}
	Local aRet		:=	{}

	If TAFColumnPos("C8K_APLICA")
		nVerAtu := 1032.05 
	Else
		nVerAtu := 1031.39
	EndIf

	If nVerEmp < nVerAtu

		aAdd( aHeader, "C8N_FILIAL" )
		aAdd( aHeader, "C8N_ID" 	)
		aAdd( aHeader, "C8N_CODIGO" )
		aAdd( aHeader, "C8N_DESCRI" )
		aAdd( aHeader, "C8N_VALIDA" )
		aAdd( aHeader, "C8N_ALTCON" )

		aAdd( aBody, { "", "000001", "01", "ACIDENTE/DOENÇA DO TRABALHO", "" } )
		aAdd( aBody, { "", "000002", "02", "NOVO AFASTAMENTO EM DECORRENCIA DO MESMO ACIDENTE DE TRABALHO", "20181231" } )
		aAdd( aBody, { "", "000003", "03", "ACIDENTE/DOENÇA NÃO RELACIONADA AO TRABALHO", "" } )
		aAdd( aBody, { "", "000004", "04", "NOVO AFASTAMENTO EM DECORRENCIA DA MESMA DOENCA, DENTRO DE 60 DIAS CONTADOS DA CESSACAO DO AFASTAMENTO ANTERIOR", "20181231" } )
		aAdd( aBody, { "", "000005", "05", "AFASTAMENTO/LICENÇA PREVISTA EM REGIME PRÓPRIO (ESTATUTO), SEM REMUNERAÇÃO", "20211109" } )
		aAdd( aBody, { "", "000006", "06", "APOSENTADORIA POR INVALIDEZ", "" } )
		aAdd( aBody, { "", "000007", "07", "ACOMPANHAMENTO - LICENÇA PARA ACOMPANHAMENTO DE MEMBRO DA FAMÍLIA ENFERMO", "" } )
		aAdd( aBody, { "", "000008", "08", "AFASTAMENTO DO EMPREGADO PARA PARTICIPAR DE ATIVIDADE DO CONSELHO CURADOR DO FGTS - ART. 65 §6º, DEC. 99.684/90 (REGULAMENTO DO FGTS)", "20210718" } )
		aAdd( aBody, { "", "000009", "09", "LICENCA MATERNIDADE DECORRENTE DE ADOCAO OU GUARDA JUDICIAL DE CRIANCA A PARTIR DE 1 (UM) ANO ATE 4 (QUATRO) ANOS DE IDADE (60 DIAS)", "20181231" } )
		aAdd( aBody, { "", "000010", "10", "AFASTAMENTO/LICENÇA PREVISTA EM REGIME PRÓPRIO (ESTATUTO), COM REMUNERAÇÃO", "20211109" } )
		aAdd( aBody, { "", "000011", "11", "CÁRCERE", "" } )
		aAdd( aBody, { "", "000012", "12", "CARGO ELETIVO - CANDIDATO A CARGO ELETIVO - LEI 7.664/1988. ART. 25°, PARÁGRAFO ÚNICO - CELETISTAS EM GERAL", "" } )
		aAdd( aBody, { "", "000013", "13", "CARGO ELETIVO - CANDIDATO A CARGO ELETIVO - LEI COMPLEMENTAR 64/1990. ART. 1°, INCISO II, ALÍNEA 1 - SERVIDOR PÚBLICO, ESTATUTÁRIO OU NÃO, DOS ÓRGÃOS OU ENTIDADES DA ADMINISTRAÇÃO DIRETA OU INDIRETA DA UNIÃO, DOS ESTADOS, DO DISTRITO FEDERAL, DOS MUNICÍPIOS E DOS TERRITÓRIOS, INCLUSIVE DAS FUNDAÇÕES MANTIDAS PELO PODER PÚBLICO.", "" } )
		aAdd( aBody, { "", "000014", "14", "CESSÃO / REQUISIÇÃO", "20220309" } )
		aAdd( aBody, { "", "000015", "15", "GOZO DE FÉRIAS OU RECESSO - AFASTAMENTO TEMPORÁRIO PARA O GOZO DE FÉRIAS OU RECESSO", "" } )
		aAdd( aBody, { "", "000016", "16", "LICENÇA REMUNERADA - LEI, LIBERALIDADE DA EMPRESA OU ACORDO/CONVENÇÃO COLETIVA DE TRABALHO", "" } )
		aAdd( aBody, { "", "000017", "17", "LICENÇA MATERNIDADE - 120 DIAS, INCLUSIVE PARA O CÔNJUGE SOBREVIVENTE", "20210718" } )
		aAdd( aBody, { "", "000018", "18", "LICENÇA MATERNIDADE - 121 DIAS A 180 DIAS, LEI 11.770/2008 (EMPRESA CIDADÃ), INCLUSIVE PARA O CÔNJUGE SOBREVIVENTE", "20211109" } )
		aAdd( aBody, { "", "000019", "19", "LICENÇA MATERNIDADE - AFASTAMENTO TEMPORÁRIO POR MOTIVO DE ABORTO NÃO CRIMINOSO", "" } )
		aAdd( aBody, { "", "000020", "20", "LICENÇA MATERNIDADE - AFASTAMENTO TEMPORÁRIO POR MOTIVO DE LICENÇA-MATERNIDADE DECORRENTE DE ADOÇÃO OU GUARDA JUDICIAL DE CRIANÇA, INCLUSIVE PARA O CÔNJUGE SOBREVIVENTE", "20210718" } )
		aAdd( aBody, { "", "000021", "99", "OUTROS MOTIVOS DE AFASTAMENTO TEMPORARIO", "" } )
		
		//Layout 2.2
		aAdd( aBody, { "", "000022", "21", "LICENÇA NÃO REMUNERADA OU SEM VENCIMENTO", "" } )
		aAdd( aBody, { "", "000023", "22", "MANDATO ELEITORAL - AFASTAMENTO TEMPORÁRIO PARA O EXERCÍCIO DE MANDATO ELEITORAL, SEM REMUNERAÇÃO", "20210718" } )
		aAdd( aBody, { "", "000024", "23", "MANDATO ELEITORAL - AFASTAMENTO TEMPORÁRIO PARA O EXERCÍCIO DE MANDATO ELEITORAL, COM REMUNERAÇÃO", "20210718" } )
		aAdd( aBody, { "", "000025", "24", "MANDATO SINDICAL - AFASTAMENTO TEMPORÁRIO PARA EXERCÍCIO DE MANDATO SINDICAL", "" } )
		aAdd( aBody, { "", "000026", "25", "MULHER VÍTIMA DE VIOLÊNCIA - LEI 11.340/2006 - ART. 9º §2O, II - LEI MARIA DA PENHA", "" } )
		aAdd( aBody, { "", "000027", "26", "PARTICIPAÇÃO DE EMPREGADO NO CONSELHO NACIONAL DE PREVIDÊNCIA SOCIAL-CNPS (ART. 3º, LEI 8.213/1991)", "" } )
		aAdd( aBody, { "", "000028", "27", "QUALIFICAÇÃO - AFASTAMENTO POR SUSPENSÃO DO CONTRATO DE ACORDO COM O ART 476-A DA CLT", "" } )
		aAdd( aBody, { "", "000029", "28", "REPRESENTANTE SINDICAL - AFASTAMENTO PELO TEMPO QUE SE FIZER NECESSÁRIO, QUANDO, NA QUALIDADE DE REPRESENTANTE DE ENTIDADE SINDICAL, ESTIVER PARTICIPANDO DE REUNIÃO OFICIAL DE ORGANISMO INTERNACIONAL DO QUAL O BRASIL SEJA MEMBRO", "" } )
		aAdd( aBody, { "", "000030", "29", "SERVIÇO MILITAR - AFASTAMENTO TEMPORÁRIO PARA PRESTAR SERVIÇO MILITAR OBRIGATÓRIO", "" } )
		aAdd( aBody, { "", "000031", "30", "SUSPENSÃO DISCIPLINAR - CLT, ART. 474", "20210718" } )
		aAdd( aBody, { "", "000032", "31", "SERVIDOR PÚBLICO EM DISPONIBILIDADE", "" } )
		aAdd( aBody, { "", "000033", "32", "TRANSFERÊNCIA PARA PRESTAÇÃO DE SERVIÇOS NO EXTERIOR EM PERÍODO SUPERIOR A 90 DIAS", "20181231" } )
		
		//layout 2.3
		aAdd( aBody, { "", "000034", "33", "LICENÇA MATERNIDADE - DE 180 DIAS, LEI 13.301/2016.", "20210718" } )
		aAdd( aBody, { "", "000035", "34", "INATIVIDADE DO TRABALHADOR AVULSO (PORTUÁRIO OU NÃO PORTUÁRIO) POR PERÍODO SUPERIOR A 90 DIAS", "" } )

		//NT- Nº 07-2018
		aAdd( aBody, { "", "000036", "35", "LICENÇA MATERNIDADE - ANTECIPAÇÃO E/OU PRORROGAÇÃO MEDIANTE ATESTADO MÉDICO. INÍCIO DE VIGÊNCIA EM 01/07/2018.", "" } )
		
		//COVID-19
		aAdd( aBody, { "", "000037", "37", "SUSPENSÃO TEMPORÁRIA DO CONTRATO DE TRABALHO NOS TERMOS DA MP 936/2020.", "20201123" } )
		aAdd( aBody, { "", "000038", "38", "IMPEDIMENTO DE CONCORRÊNCIA À ESCALA PARA TRABALHO AVULSO.", "" } )

		//NT-19/2020
		aAdd( aBody, { "", "000039", "37", "SUSPENSÃO TEMPORÁRIA DO CONTRATO DE TRABALHO NOS TERMOS DA MP 936/2020 14.020/2020 (CONVERSÃO DA MP 936/2020).", "20210718" } )

		// S_1.0
		aAdd( aBody, { "", "000040", "05", "AFASTAMENTO/LICENÇA DE SERVIDOR PÚBLICO PREVISTA EM ESTATUTO, SEM REMUNERAÇÃO", "" } )
		aAdd( aBody, { "", "000041", "10", "AFASTAMENTO/LICENÇA DE SERVIDOR PÚBLICO PREVISTA EM ESTATUTO, COM REMUNERAÇÃO", "" } )
		aAdd( aBody, { "", "000042", "17", "LICENÇA MATERNIDADE"														  , "" } )
		aAdd( aBody, { "", "000043", "18", "LICENÇA MATERNIDADE - PRORROGAÇÃO POR 60 DIAS, LEI 11.770/2008 (EMPRESA CIDADÃ), INCLUSIVE PARA O CÔNJUGE SOBREVIVENTE", "" } )
		aAdd( aBody, { "", "000044", "20", "LICENÇA MATERNIDADE - AFASTAMENTO TEMPORÁRIO POR MOTIVO DE LICENÇA - MATERNIDADE PARA O CÔNJUGE SOBREVIVENTE OU DECORRENTE DE ADOÇÃO OU DE GUARDA JUDICIAL DE CRIANÇA", "" } )
		aAdd( aBody, { "", "000045", "22", "MANDATO ELEITORAL - AFASTAMENTO TEMPORÁRIO PARA O EXERCÍCIO DE MANDATO ELEITORAL", "" } )
		aAdd( aBody, { "", "000046", "36", "AFASTAMENTO TEMPORÁRIO DE EXERCENTE DE MANDATO ELETIVO PARA CARGO EM COMISSÃO", "" } )

		//NT - 02/2021 - Leiaute S-1.0
		aAdd( aBody, { "", "000047", "37", "SUSPENSÃO TEMPORÁRIA DO CONTRATO DE TRABALHO NOS TERMOS DO PROGRAMA EMERGENCIAL DE MANUTENÇÃO DO EMPREGO E DA RENDA", "20210825", 1032.05 } )
		
		//NT 22/2021
		aAdd( aBody, { "", "000048", "39", "SUSPENSÃO DE PAGAMENTO DE SERVIDOR PÚBLICO POR NÃO RECADASTRAMENTO", "" } )
		aAdd( aBody, { "", "000049", "40", "EXERCÍCIO EM OUTRO ÓRGÃO DE SERVIDOR OU EMPREGADO PÚBLICO CEDIDO", "" } )
		
		//NOTA TÉCNICA S-1.0 Nº 05/2022
		aAdd( aBody, { "", "000050", "41", "QUALIFICAÇÃO - AFASTAMENTO POR SUSPENSÃO DO CONTRATO DE ACORDO COM O ART. 17 DA MP 1.116/2022", "", 1032.05 } )
		aAdd( aBody, { "", "000051", "42", "QUALIFICAÇÃO - AFASTAMENTO POR SUSPENSÃO DO CONTRATO DE ACORDO COM O ART. 19 DA MP 1.116/2022", "", 1032.05 } )

		aAdd( aRet, { aHeader, aBody } )
		
	EndIf

Return aRet
