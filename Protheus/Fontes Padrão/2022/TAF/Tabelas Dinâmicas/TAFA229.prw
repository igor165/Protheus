#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA229.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA229
Cadastro MVC de C�digos de Motivos de Afastamento - Tabela 18

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA229()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //C�digos de Motivos de Afastamento 	
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

// Adiciona ao modelo um componente de formul�rio
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

oView:EnableTitleView( 'VIEW_C8N',  STR0001 ) //C�digos de Motivos de Afastamento 

oView:CreateHorizontalBox( 'FIELDSC8N', 100 )

oView:SetOwnerView( 'VIEW_C8N', 'FIELDSC8N' )

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

		aAdd( aBody, { "", "000001", "01", "ACIDENTE/DOEN�A DO TRABALHO", "" } )
		aAdd( aBody, { "", "000002", "02", "NOVO AFASTAMENTO EM DECORRENCIA DO MESMO ACIDENTE DE TRABALHO", "20181231" } )
		aAdd( aBody, { "", "000003", "03", "ACIDENTE/DOEN�A N�O RELACIONADA AO TRABALHO", "" } )
		aAdd( aBody, { "", "000004", "04", "NOVO AFASTAMENTO EM DECORRENCIA DA MESMA DOENCA, DENTRO DE 60 DIAS CONTADOS DA CESSACAO DO AFASTAMENTO ANTERIOR", "20181231" } )
		aAdd( aBody, { "", "000005", "05", "AFASTAMENTO/LICEN�A PREVISTA EM REGIME PR�PRIO (ESTATUTO), SEM REMUNERA��O", "20211109" } )
		aAdd( aBody, { "", "000006", "06", "APOSENTADORIA POR INVALIDEZ", "" } )
		aAdd( aBody, { "", "000007", "07", "ACOMPANHAMENTO - LICEN�A PARA ACOMPANHAMENTO DE MEMBRO DA FAM�LIA ENFERMO", "" } )
		aAdd( aBody, { "", "000008", "08", "AFASTAMENTO DO EMPREGADO PARA PARTICIPAR DE ATIVIDADE DO CONSELHO CURADOR DO FGTS - ART. 65 �6�, DEC. 99.684/90 (REGULAMENTO DO FGTS)", "20210718" } )
		aAdd( aBody, { "", "000009", "09", "LICENCA MATERNIDADE DECORRENTE DE ADOCAO OU GUARDA JUDICIAL DE CRIANCA A PARTIR DE 1 (UM) ANO ATE 4 (QUATRO) ANOS DE IDADE (60 DIAS)", "20181231" } )
		aAdd( aBody, { "", "000010", "10", "AFASTAMENTO/LICEN�A PREVISTA EM REGIME PR�PRIO (ESTATUTO), COM REMUNERA��O", "20211109" } )
		aAdd( aBody, { "", "000011", "11", "C�RCERE", "" } )
		aAdd( aBody, { "", "000012", "12", "CARGO ELETIVO - CANDIDATO A CARGO ELETIVO - LEI 7.664/1988. ART. 25�, PAR�GRAFO �NICO - CELETISTAS EM GERAL", "" } )
		aAdd( aBody, { "", "000013", "13", "CARGO ELETIVO - CANDIDATO A CARGO ELETIVO - LEI COMPLEMENTAR 64/1990. ART. 1�, INCISO II, AL�NEA 1 - SERVIDOR P�BLICO, ESTATUT�RIO OU N�O, DOS �RG�OS OU ENTIDADES DA ADMINISTRA��O DIRETA OU INDIRETA DA UNI�O, DOS ESTADOS, DO DISTRITO FEDERAL, DOS MUNIC�PIOS E DOS TERRIT�RIOS, INCLUSIVE DAS FUNDA��ES MANTIDAS PELO PODER P�BLICO.", "" } )
		aAdd( aBody, { "", "000014", "14", "CESS�O / REQUISI��O", "20220309" } )
		aAdd( aBody, { "", "000015", "15", "GOZO DE F�RIAS OU RECESSO - AFASTAMENTO TEMPOR�RIO PARA O GOZO DE F�RIAS OU RECESSO", "" } )
		aAdd( aBody, { "", "000016", "16", "LICEN�A REMUNERADA - LEI, LIBERALIDADE DA EMPRESA OU ACORDO/CONVEN��O COLETIVA DE TRABALHO", "" } )
		aAdd( aBody, { "", "000017", "17", "LICEN�A MATERNIDADE - 120 DIAS, INCLUSIVE PARA O C�NJUGE SOBREVIVENTE", "20210718" } )
		aAdd( aBody, { "", "000018", "18", "LICEN�A MATERNIDADE - 121 DIAS A 180 DIAS, LEI 11.770/2008 (EMPRESA CIDAD�), INCLUSIVE PARA O C�NJUGE SOBREVIVENTE", "20211109" } )
		aAdd( aBody, { "", "000019", "19", "LICEN�A MATERNIDADE - AFASTAMENTO TEMPOR�RIO POR MOTIVO DE ABORTO N�O CRIMINOSO", "" } )
		aAdd( aBody, { "", "000020", "20", "LICEN�A MATERNIDADE - AFASTAMENTO TEMPOR�RIO POR MOTIVO DE LICEN�A-MATERNIDADE DECORRENTE DE ADO��O OU GUARDA JUDICIAL DE CRIAN�A, INCLUSIVE PARA O C�NJUGE SOBREVIVENTE", "20210718" } )
		aAdd( aBody, { "", "000021", "99", "OUTROS MOTIVOS DE AFASTAMENTO TEMPORARIO", "" } )
		
		//Layout 2.2
		aAdd( aBody, { "", "000022", "21", "LICEN�A N�O REMUNERADA OU SEM VENCIMENTO", "" } )
		aAdd( aBody, { "", "000023", "22", "MANDATO ELEITORAL - AFASTAMENTO TEMPOR�RIO PARA O EXERC�CIO DE MANDATO ELEITORAL, SEM REMUNERA��O", "20210718" } )
		aAdd( aBody, { "", "000024", "23", "MANDATO ELEITORAL - AFASTAMENTO TEMPOR�RIO PARA O EXERC�CIO DE MANDATO ELEITORAL, COM REMUNERA��O", "20210718" } )
		aAdd( aBody, { "", "000025", "24", "MANDATO SINDICAL - AFASTAMENTO TEMPOR�RIO PARA EXERC�CIO DE MANDATO SINDICAL", "" } )
		aAdd( aBody, { "", "000026", "25", "MULHER V�TIMA DE VIOL�NCIA - LEI 11.340/2006 - ART. 9� �2O, II - LEI MARIA DA PENHA", "" } )
		aAdd( aBody, { "", "000027", "26", "PARTICIPA��O DE EMPREGADO NO CONSELHO NACIONAL DE PREVID�NCIA SOCIAL-CNPS (ART. 3�, LEI 8.213/1991)", "" } )
		aAdd( aBody, { "", "000028", "27", "QUALIFICA��O - AFASTAMENTO POR SUSPENS�O DO CONTRATO DE ACORDO COM O ART 476-A DA CLT", "" } )
		aAdd( aBody, { "", "000029", "28", "REPRESENTANTE SINDICAL - AFASTAMENTO PELO TEMPO QUE SE FIZER NECESS�RIO, QUANDO, NA QUALIDADE DE REPRESENTANTE DE ENTIDADE SINDICAL, ESTIVER PARTICIPANDO DE REUNI�O OFICIAL DE ORGANISMO INTERNACIONAL DO QUAL O BRASIL SEJA MEMBRO", "" } )
		aAdd( aBody, { "", "000030", "29", "SERVI�O MILITAR - AFASTAMENTO TEMPOR�RIO PARA PRESTAR SERVI�O MILITAR OBRIGAT�RIO", "" } )
		aAdd( aBody, { "", "000031", "30", "SUSPENS�O DISCIPLINAR - CLT, ART. 474", "20210718" } )
		aAdd( aBody, { "", "000032", "31", "SERVIDOR P�BLICO EM DISPONIBILIDADE", "" } )
		aAdd( aBody, { "", "000033", "32", "TRANSFER�NCIA PARA PRESTA��O DE SERVI�OS NO EXTERIOR EM PER�ODO SUPERIOR A 90 DIAS", "20181231" } )
		
		//layout 2.3
		aAdd( aBody, { "", "000034", "33", "LICEN�A MATERNIDADE - DE 180 DIAS, LEI 13.301/2016.", "20210718" } )
		aAdd( aBody, { "", "000035", "34", "INATIVIDADE DO TRABALHADOR AVULSO (PORTU�RIO OU N�O PORTU�RIO) POR PER�ODO SUPERIOR A 90 DIAS", "" } )

		//NT- N� 07-2018
		aAdd( aBody, { "", "000036", "35", "LICEN�A MATERNIDADE - ANTECIPA��O E/OU PRORROGA��O MEDIANTE ATESTADO M�DICO. IN�CIO DE VIG�NCIA EM 01/07/2018.", "" } )
		
		//COVID-19
		aAdd( aBody, { "", "000037", "37", "SUSPENS�O TEMPOR�RIA DO CONTRATO DE TRABALHO NOS TERMOS DA MP 936/2020.", "20201123" } )
		aAdd( aBody, { "", "000038", "38", "IMPEDIMENTO DE CONCORR�NCIA � ESCALA PARA TRABALHO AVULSO.", "" } )

		//NT-19/2020
		aAdd( aBody, { "", "000039", "37", "SUSPENS�O TEMPOR�RIA DO CONTRATO DE TRABALHO NOS TERMOS DA MP 936/2020 14.020/2020 (CONVERS�O DA MP 936/2020).", "20210718" } )

		// S_1.0
		aAdd( aBody, { "", "000040", "05", "AFASTAMENTO/LICEN�A DE SERVIDOR P�BLICO PREVISTA EM ESTATUTO, SEM REMUNERA��O", "" } )
		aAdd( aBody, { "", "000041", "10", "AFASTAMENTO/LICEN�A DE SERVIDOR P�BLICO PREVISTA EM ESTATUTO, COM REMUNERA��O", "" } )
		aAdd( aBody, { "", "000042", "17", "LICEN�A MATERNIDADE"														  , "" } )
		aAdd( aBody, { "", "000043", "18", "LICEN�A MATERNIDADE - PRORROGA��O POR 60 DIAS, LEI 11.770/2008 (EMPRESA CIDAD�), INCLUSIVE PARA O C�NJUGE SOBREVIVENTE", "" } )
		aAdd( aBody, { "", "000044", "20", "LICEN�A MATERNIDADE - AFASTAMENTO TEMPOR�RIO POR MOTIVO DE LICEN�A - MATERNIDADE PARA O C�NJUGE SOBREVIVENTE OU DECORRENTE DE ADO��O OU DE GUARDA JUDICIAL DE CRIAN�A", "" } )
		aAdd( aBody, { "", "000045", "22", "MANDATO ELEITORAL - AFASTAMENTO TEMPOR�RIO PARA O EXERC�CIO DE MANDATO ELEITORAL", "" } )
		aAdd( aBody, { "", "000046", "36", "AFASTAMENTO TEMPOR�RIO DE EXERCENTE DE MANDATO ELETIVO PARA CARGO EM COMISS�O", "" } )

		//NT - 02/2021 - Leiaute S-1.0
		aAdd( aBody, { "", "000047", "37", "SUSPENS�O TEMPOR�RIA DO CONTRATO DE TRABALHO NOS TERMOS DO PROGRAMA EMERGENCIAL DE MANUTEN��O DO EMPREGO E DA RENDA", "20210825", 1032.05 } )
		
		//NT 22/2021
		aAdd( aBody, { "", "000048", "39", "SUSPENS�O DE PAGAMENTO DE SERVIDOR P�BLICO POR N�O RECADASTRAMENTO", "" } )
		aAdd( aBody, { "", "000049", "40", "EXERC�CIO EM OUTRO �RG�O DE SERVIDOR OU EMPREGADO P�BLICO CEDIDO", "" } )
		
		//NOTA T�CNICA S-1.0 N� 05/2022
		aAdd( aBody, { "", "000050", "41", "QUALIFICA��O - AFASTAMENTO POR SUSPENS�O DO CONTRATO DE ACORDO COM O ART. 17 DA MP 1.116/2022", "", 1032.05 } )
		aAdd( aBody, { "", "000051", "42", "QUALIFICA��O - AFASTAMENTO POR SUSPENS�O DO CONTRATO DE ACORDO COM O ART. 19 DA MP 1.116/2022", "", 1032.05 } )

		aAdd( aRet, { aHeader, aBody } )
		
	EndIf

Return aRet
