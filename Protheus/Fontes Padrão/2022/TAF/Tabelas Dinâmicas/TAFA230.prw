#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA230.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA230
Tabela 19 - Cadastro de Motivos de Desligamento

@author Anderson Costa
@since 09/08/2013
@version 1.0
/*/ 
//-------------------------------------------------------------------
Function TAFA230()

	Local   oBrw        :=  FWmBrowse():New()

	oBrw:SetDescription(STR0001)    //"Cadastro de Motivos de Desligamento"
	oBrw:SetAlias( 'C8O')
	oBrw:SetMenuDef( 'TAFA230' )
	oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 09/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA230" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 09/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruC8O  :=  FWFormStruct( 1, 'C8O' )
	Local oModel    :=  MPFormModel():New( 'TAFA230' )

	oModel:AddFields('MODEL_C8O', /*cOwner*/, oStruC8O)
	oModel:GetModel('MODEL_C8O'):SetPrimaryKey({'C8O_FILIAL', 'C8O_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 09/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local   oModel      :=  FWLoadModel( 'TAFA230' )
	Local   oStruC8O    :=  FWFormStruct( 2, 'C8O' )
	Local   oView       :=  FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_C8O', oStruC8O, 'MODEL_C8O' )

	oView:EnableTitleView( 'VIEW_C8O', STR0001 )    //"Cadastro de Motivos de Desligamento"
	oView:CreateHorizontalBox( 'FIELDSC8O', 100 )
	oView:SetOwnerView( 'VIEW_C8O', 'FIELDSC8O' )

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
Static Function FAtuCont( nVerEmp as Numeric, nVerAtu as Numeric)

	Local aHeader as Array
	Local aBody   as Array
	Local aRet    as Array

	aHeader := {}
	aBody   := {}
	aRet    := {}

	nVerAtu := 1032.08

	If nVerEmp < nVerAtu

		aAdd( aHeader, "C8O_FILIAL" )
		aAdd( aHeader, "C8O_ID" 	)
		aAdd( aHeader, "C8O_CODIGO" )
		aAdd( aHeader, "C8O_DESCRI" )
		aAdd( aHeader, "C8O_VALIDA" )
		aAdd( aHeader, "C8O_ALTCON" )

		aAdd( aBody, { "", "000001", "01", "RESCISÃO COM JUSTA CAUSA, POR INICIATIVA DO EMPREGADOR"																																															, "" 		} )
		aAdd( aBody, { "", "000002", "02", "RESCISÃO SEM JUSTA CAUSA, POR INICIATIVA DO EMPREGADOR"																																															, "" 		} )
		aAdd( aBody, { "", "000003", "03", "RESCISÃO ANTECIPADA DO CONTRATO A TERMO POR INICIATIVA DO EMPREGADOR"																																											, "" 		} )
		aAdd( aBody, { "", "000004", "04", "RESCISÃO ANTECIPADA DO CONTRATO A TERMO POR INICIATIVA DO EMPREGADO"																																											, "" 		} )
		aAdd( aBody, { "", "000005", "05", "RESCISÃO POR CULPA RECÍPROCA"																																																					, "" 		} )
		aAdd( aBody, { "", "000006", "06", "RESCISÃO POR TÉRMINO DO CONTRATO A TERMO"																																																		, "" 		} )
		aAdd( aBody, { "", "000007", "07", "RESCISÃO DO CONTRATO DE TRABALHO POR INICIATIVA DO EMPREGADO"																																													, "" 		} )
		aAdd( aBody, { "", "000008", "08", "RESCISÃO DO CONTRATO DE TRABALHO POR INTERESSE DO(A) EMPREGADO(A), NAS HIPÓTESES PREVISTAS NOS ARTS. 394 E 483, § 1º DA CLT"																													, "" 		} )
		aAdd( aBody, { "", "000009", "09", "RESCISÃO POR OPÇÃO DO EMPREGADO EM VIRTUDE DE FALECIMENTO DO EMPREGADOR INDIVIDUAL OU EMPREGADOR DOMÉSTICO"																																		, "" 		} ) // LAYOUT 2.4.02
		aAdd( aBody, { "", "000010", "10", "RESCISÃO POR FALECIMENTO DO EMPREGADO"																																																			, "" 		} )
		aAdd( aBody, { "", "000011", "11", "TRANSFERÊNCIA DE EMPREGADO PARA EMPRESA DO MESMO GRUPO EMPRESARIAL QUE TENHA ASSUMIDO OS ENCARGOS TRABALHISTAS, SEM QUE TENHA HAVIDO RESCISÃO DO CONTRATO DE TRABALHO"																			, "" 		} )
		aAdd( aBody, { "", "000012", "12", "TRANSFERÊNCIA DE EMPREGADO DA EMPRESA CONSORCIADA PARA O CONSÓRCIO QUE TENHA ASSUMIDO OS ENCARGOS TRABALHISTAS, E VICE-VERSA, SEM QUE TENHA HAVIDO RESCISÃO DO CONTRATO DE TRABALHO"															, "" 		} )
		aAdd( aBody, { "", "000013", "13", "TRANSFERÊNCIA DE EMPREGADO DE EMPRESA OU CONSÓRCIO, PARA OUTRA EMPRESA OU CONSÓRCIO QUE TENHA ASSUMIDO OS ENCARGOS TRABALHISTAS POR MOTIVO DE SUCESSÃO (FUSÃO, CISÃO OU INCORPORAÇÃO), SEM QUE TENHA HAVIDO RESCISÃO DO CONTRATO DE TRABALHO"	, "" 		} )
		aAdd( aBody, { "", "000014", "14", "RESCISÃO DO CONTRATO DE TRABALHO POR ENCERRAMENTO DA EMPRESA, DE SEUS ESTABELECIMENTOS OU SUPRESSÃO DE PARTE DE SUAS ATIVIDADES OU FALECIMENTO DO EMPREGADOR INDIVIDUAL OU EMPREGADOR DOMÉSTICO SEM CONTINUAÇÃO DA ATIVIDADE"					, "" 		} )
		aAdd( aBody, { "", "000015", "15", "RESCISÃO DO CONTRATO DE APRENDIZAGEM POR DESEMPENHO INSUFICIENTE, INADAPTAÇÃO OU AUSÊNCIA INJUSTIFICADA DO APRENDIZ À ESCOLA QUE IMPLIQUE PERDA DO ANO LETIVO"																					,"20210718" } )
		aAdd( aBody, { "", "000016", "16", "DECLARAÇÃO DE NULIDADE DO CONTRATO DE TRABALHO POR INFRINGÊNCIA AO INCISO II DO ART. 37 DA CONSTITUIÇÃO FEDERAL, QUANDO MANTIDO O DIREITO AO SALÁRIO"																							, "" 		} )
		aAdd( aBody, { "", "000017", "17", "RESCISÃO INDIRETA DO CONTRATO DE TRABALHO"																																																		, "" 		} )
		aAdd( aBody, { "", "000018", "99", "OUTROS MOTIVOS DE RESCISAO DO CONTRATO DE TRABALHO"																																																, "" 		} )
		
		//Layout 2.2
		aAdd( aBody, { "", "000019", "18", "APOSENTADORIA COMPULSÓRIA " 																																																					,"20210718" } )
		aAdd( aBody, { "", "000020", "19", "APOSENTADORIA POR IDADE (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 309)" 																																									,"20210718" } )
		aAdd( aBody, { "", "000021", "20", "APOSENTADORIA POR IDADE E TEMPO DE CONTRIBUIÇÃO (SOMENTE CATEGORIAS 301 A 309)" 																																								,"20210509" } )
		aAdd( aBody, { "", "000022", "21", "REFORMA MILITAR (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 309)" 																																											,"20210718" } )
		aAdd( aBody, { "", "000023", "22", "RESERVA MILITAR (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 309)" 																																											,"20210718" } )
		aAdd( aBody, { "", "000024", "23", "EXONERAÇÃO (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 309)"																																												,"20210718" } )
		aAdd( aBody, { "", "000025", "24", "DEMISSÃO (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 309)"																																													,"20210718" } )
		aAdd( aBody, { "", "000026", "25", "VACÂNCIA PARA ASSUMIR OUTRO CARGO EFETIVO (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 309)" 																																				,"20210718" } )
		aAdd( aBody, { "", "000027", "26", "RESCISÃO DO CONTRATO DE TRABALHO POR PARALISAÇÃO TEMPORÁRIA OU DEFINITIVA DA EMPRESA, ESTABELECIMENTO OU PARTE DAS ATIVIDADES MOTIVADA POR ATOS DE AUTORIDADE MUNICIPAL, ESTADUAL OU FEDERAL"													, "" 		} )
		aAdd( aBody, { "", "000028", "27", "RESCISÃO POR MOTIVO DE FORÇA MAIOR"																																																				, "" 		} )
		aAdd( aBody, { "", "000029", "28", "TÉRMINO DA CESSÃO/REQUISIÇÃO" 																																																					,"20210718" } )
		aAdd( aBody, { "", "000030", "29", "REDISTRIBUIÇÃO"																																																									,"20210718"	, 1032.05 } )
		aAdd( aBody, { "", "000031", "30", "MUDANÇA DE REGIME TRABALHISTA"																																																					, "" 		} )
		aAdd( aBody, { "", "000032", "31", "REVERSÃO DE REINTEGRAÇÃO"																																																						, "" 		} )
		aAdd( aBody, { "", "000033", "32", "EXTRAVIO DE MILITAR"																																																							, "" 		} )
		
		//Layout 2.4 E-social
		aAdd( aBody, { "", "000034", "33", "RESCISÃO POR ACORDO ENTRE AS PARTES (ART. 484-A DA CLT)"																																														, "" 		} )
		aAdd( aBody, { "", "000035", "34", "TRANSFERÊNCIA DE TITULARIDADE DO EMPREGADO DOMÉSTICO PARA OUTRO REPRESENTANTE DA MESMA UNIDADE FAMILIAR"																																		, "" 		} )
		
		// Layout 2.4.02
		aAdd( aBody, { "", "000036", "35", "FIM DE VIGÊNCIA EM 30/06/2018"																																																					, "" 		} )
		
		// Layout 2.5
		aAdd( aBody, { "", "000037", "36", "MUDANÇA DE CPF"																																																									, "" 		} )
		
		// Layout 1.0
		aAdd( aBody, { "", "000038", "37", "REMOÇÃO, EM CASO DE ALTERAÇÃO DO ÓRGÃO DECLARANTE"																																																, "" 		} )
		aAdd( aBody, { "", "000039", "38", "APOSENTADORIA, EXCETO POR INVALIDEZ"																																																			, "" 		} )
		aAdd( aBody, { "", "000040", "39", "APOSENTADORIA DE SERVIDOR ESTATUTÁRIO, POR INVALIDEZ"																																															, "" 		} )
		aAdd( aBody, { "", "000041", "40", "TÉRMINO DO EXERCÍCIO DO MANDATO ELETIVO"																																																		, "" 		} )
		aAdd( aBody, { "", "000042", "41", "RESCISÃO DO CONTRATO DE APRENDIZAGEM POR DESEMPENHO INSUFICIENTE OU INADAPTAÇÃO DO APRENDIZ"																																					, "" 		} )
		aAdd( aBody, { "", "000043", "42", "RESCISÃO DO CONTRATO DE APRENDIZAGEM POR AUSÊNCIA INJUSTIFICADA DO APRENDIZ À ESCOLA QUE IMPLIQUE PERDA DO ANO LETIVO"																															, "" 		} )
		aAdd( aBody, { "", "000044", "19", "APOSENTADORIA POR IDADE (SOMENTE PARA CATEGORIAs DE TRABALHADORES 301, 302, 303, 306, 307, 309)" 																																				,"20210509" } )
		aAdd( aBody, { "", "000045", "20", "APOSENTADORIA POR IDADE E TEMPO DE CONTRIBUIÇÃO (SOMENTE PARA CATEGORIAs DE TRABALHADORES 301, 302, 303, 306, 307, 309)" 																														,"20210718" } )
		aAdd( aBody, { "", "000046", "21", "REFORMA MILITAR (SOMENTE PARA A CATEGORIA DE TRABALHADOR 307)"																																													, "" 		} )
		aAdd( aBody, { "", "000047", "22", "RESERVA MILITAR (SOMENTE PARA A CATEGORIA DE TRABALHADOR 307)"																																													, "" 		} )
		aAdd( aBody, { "", "000048", "23", "EXONERAÇÃO (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301, 302, 303, 306, 307, 309, 310, 312)"																																					, "" 		} )
		aAdd( aBody, { "", "000049", "24", "DEMISSÃO (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301, 302, 303, 306, 307, 309, 310, 312)"																																						, "" 		} )
		aAdd( aBody, { "", "000050", "25", "VACÂNCIA PARA ASSUMIR OUTRO CARGO EFETIVO (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301, 307)"																																					, "" 		} )

		//NOTA TÉCNICA S-1.0 Nº 05/2022
		aAdd( aBody, { "", "000051", "29", "REDISTRIBUIÇÃO OU REFORMA ADMINISTRATIVA"																																																		, "" 		, 1032.05 } )
		aAdd( aBody, { "", "000052", "43", "TRANSFERÊNCIA DE EMPREGADO DE EMPRESA CONSIDERADA INAPTA POR INEXISTÊNCIA DE FATO"																																								, "" 		, 1032.05 } )

		//NOTA TÉCNICA S-1.0 Nº 06/2022
		aAdd( aBody, { "", "000053", "44", "AGRUPAMENTO CONTRATUAL"																																																							, "" 		, 1032.08 } )

		aAdd( aRet, { aHeader, aBody } )

	EndIf

Return aRet
