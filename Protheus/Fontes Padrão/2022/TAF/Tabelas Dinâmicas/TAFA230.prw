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

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

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

		aAdd( aBody, { "", "000001", "01", "RESCIS�O COM JUSTA CAUSA, POR INICIATIVA DO EMPREGADOR"																																															, "" 		} )
		aAdd( aBody, { "", "000002", "02", "RESCIS�O SEM JUSTA CAUSA, POR INICIATIVA DO EMPREGADOR"																																															, "" 		} )
		aAdd( aBody, { "", "000003", "03", "RESCIS�O ANTECIPADA DO CONTRATO A TERMO POR INICIATIVA DO EMPREGADOR"																																											, "" 		} )
		aAdd( aBody, { "", "000004", "04", "RESCIS�O ANTECIPADA DO CONTRATO A TERMO POR INICIATIVA DO EMPREGADO"																																											, "" 		} )
		aAdd( aBody, { "", "000005", "05", "RESCIS�O POR CULPA REC�PROCA"																																																					, "" 		} )
		aAdd( aBody, { "", "000006", "06", "RESCIS�O POR T�RMINO DO CONTRATO A TERMO"																																																		, "" 		} )
		aAdd( aBody, { "", "000007", "07", "RESCIS�O DO CONTRATO DE TRABALHO POR INICIATIVA DO EMPREGADO"																																													, "" 		} )
		aAdd( aBody, { "", "000008", "08", "RESCIS�O DO CONTRATO DE TRABALHO POR INTERESSE DO(A) EMPREGADO(A), NAS HIP�TESES PREVISTAS NOS ARTS. 394 E 483, � 1� DA CLT"																													, "" 		} )
		aAdd( aBody, { "", "000009", "09", "RESCIS�O POR OP��O DO EMPREGADO EM VIRTUDE DE FALECIMENTO DO EMPREGADOR INDIVIDUAL OU EMPREGADOR DOM�STICO"																																		, "" 		} ) // LAYOUT 2.4.02
		aAdd( aBody, { "", "000010", "10", "RESCIS�O POR FALECIMENTO DO EMPREGADO"																																																			, "" 		} )
		aAdd( aBody, { "", "000011", "11", "TRANSFER�NCIA DE EMPREGADO PARA EMPRESA DO MESMO GRUPO EMPRESARIAL QUE TENHA ASSUMIDO OS ENCARGOS TRABALHISTAS, SEM QUE TENHA HAVIDO RESCIS�O DO CONTRATO DE TRABALHO"																			, "" 		} )
		aAdd( aBody, { "", "000012", "12", "TRANSFER�NCIA DE EMPREGADO DA EMPRESA CONSORCIADA PARA O CONS�RCIO QUE TENHA ASSUMIDO OS ENCARGOS TRABALHISTAS, E VICE-VERSA, SEM QUE TENHA HAVIDO RESCIS�O DO CONTRATO DE TRABALHO"															, "" 		} )
		aAdd( aBody, { "", "000013", "13", "TRANSFER�NCIA DE EMPREGADO DE EMPRESA OU CONS�RCIO, PARA OUTRA EMPRESA OU CONS�RCIO QUE TENHA ASSUMIDO OS ENCARGOS TRABALHISTAS POR MOTIVO DE SUCESS�O (FUS�O, CIS�O OU INCORPORA��O), SEM QUE TENHA HAVIDO RESCIS�O DO CONTRATO DE TRABALHO"	, "" 		} )
		aAdd( aBody, { "", "000014", "14", "RESCIS�O DO CONTRATO DE TRABALHO POR ENCERRAMENTO DA EMPRESA, DE SEUS ESTABELECIMENTOS OU SUPRESS�O DE PARTE DE SUAS ATIVIDADES OU FALECIMENTO DO EMPREGADOR INDIVIDUAL OU EMPREGADOR DOM�STICO SEM CONTINUA��O DA ATIVIDADE"					, "" 		} )
		aAdd( aBody, { "", "000015", "15", "RESCIS�O DO CONTRATO DE APRENDIZAGEM POR DESEMPENHO INSUFICIENTE, INADAPTA��O OU AUS�NCIA INJUSTIFICADA DO APRENDIZ � ESCOLA QUE IMPLIQUE PERDA DO ANO LETIVO"																					,"20210718" } )
		aAdd( aBody, { "", "000016", "16", "DECLARA��O DE NULIDADE DO CONTRATO DE TRABALHO POR INFRING�NCIA AO INCISO II DO ART. 37 DA CONSTITUI��O FEDERAL, QUANDO MANTIDO O DIREITO AO SAL�RIO"																							, "" 		} )
		aAdd( aBody, { "", "000017", "17", "RESCIS�O INDIRETA DO CONTRATO DE TRABALHO"																																																		, "" 		} )
		aAdd( aBody, { "", "000018", "99", "OUTROS MOTIVOS DE RESCISAO DO CONTRATO DE TRABALHO"																																																, "" 		} )
		
		//Layout 2.2
		aAdd( aBody, { "", "000019", "18", "APOSENTADORIA COMPULS�RIA " 																																																					,"20210718" } )
		aAdd( aBody, { "", "000020", "19", "APOSENTADORIA POR IDADE (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 309)" 																																									,"20210718" } )
		aAdd( aBody, { "", "000021", "20", "APOSENTADORIA POR IDADE E TEMPO DE CONTRIBUI��O (SOMENTE CATEGORIAS 301 A 309)" 																																								,"20210509" } )
		aAdd( aBody, { "", "000022", "21", "REFORMA MILITAR (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 309)" 																																											,"20210718" } )
		aAdd( aBody, { "", "000023", "22", "RESERVA MILITAR (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 309)" 																																											,"20210718" } )
		aAdd( aBody, { "", "000024", "23", "EXONERA��O (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 309)"																																												,"20210718" } )
		aAdd( aBody, { "", "000025", "24", "DEMISS�O (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 309)"																																													,"20210718" } )
		aAdd( aBody, { "", "000026", "25", "VAC�NCIA PARA ASSUMIR OUTRO CARGO EFETIVO (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 309)" 																																				,"20210718" } )
		aAdd( aBody, { "", "000027", "26", "RESCIS�O DO CONTRATO DE TRABALHO POR PARALISA��O TEMPOR�RIA OU DEFINITIVA DA EMPRESA, ESTABELECIMENTO OU PARTE DAS ATIVIDADES MOTIVADA POR ATOS DE AUTORIDADE MUNICIPAL, ESTADUAL OU FEDERAL"													, "" 		} )
		aAdd( aBody, { "", "000028", "27", "RESCIS�O POR MOTIVO DE FOR�A MAIOR"																																																				, "" 		} )
		aAdd( aBody, { "", "000029", "28", "T�RMINO DA CESS�O/REQUISI��O" 																																																					,"20210718" } )
		aAdd( aBody, { "", "000030", "29", "REDISTRIBUI��O"																																																									,"20210718"	, 1032.05 } )
		aAdd( aBody, { "", "000031", "30", "MUDAN�A DE REGIME TRABALHISTA"																																																					, "" 		} )
		aAdd( aBody, { "", "000032", "31", "REVERS�O DE REINTEGRA��O"																																																						, "" 		} )
		aAdd( aBody, { "", "000033", "32", "EXTRAVIO DE MILITAR"																																																							, "" 		} )
		
		//Layout 2.4 E-social
		aAdd( aBody, { "", "000034", "33", "RESCIS�O POR ACORDO ENTRE AS PARTES (ART. 484-A DA CLT)"																																														, "" 		} )
		aAdd( aBody, { "", "000035", "34", "TRANSFER�NCIA DE TITULARIDADE DO EMPREGADO DOM�STICO PARA OUTRO REPRESENTANTE DA MESMA UNIDADE FAMILIAR"																																		, "" 		} )
		
		// Layout 2.4.02
		aAdd( aBody, { "", "000036", "35", "FIM DE VIG�NCIA EM 30/06/2018"																																																					, "" 		} )
		
		// Layout 2.5
		aAdd( aBody, { "", "000037", "36", "MUDAN�A DE CPF"																																																									, "" 		} )
		
		// Layout 1.0
		aAdd( aBody, { "", "000038", "37", "REMO��O, EM CASO DE ALTERA��O DO �RG�O DECLARANTE"																																																, "" 		} )
		aAdd( aBody, { "", "000039", "38", "APOSENTADORIA, EXCETO POR INVALIDEZ"																																																			, "" 		} )
		aAdd( aBody, { "", "000040", "39", "APOSENTADORIA DE SERVIDOR ESTATUT�RIO, POR INVALIDEZ"																																															, "" 		} )
		aAdd( aBody, { "", "000041", "40", "T�RMINO DO EXERC�CIO DO MANDATO ELETIVO"																																																		, "" 		} )
		aAdd( aBody, { "", "000042", "41", "RESCIS�O DO CONTRATO DE APRENDIZAGEM POR DESEMPENHO INSUFICIENTE OU INADAPTA��O DO APRENDIZ"																																					, "" 		} )
		aAdd( aBody, { "", "000043", "42", "RESCIS�O DO CONTRATO DE APRENDIZAGEM POR AUS�NCIA INJUSTIFICADA DO APRENDIZ � ESCOLA QUE IMPLIQUE PERDA DO ANO LETIVO"																															, "" 		} )
		aAdd( aBody, { "", "000044", "19", "APOSENTADORIA POR IDADE (SOMENTE PARA CATEGORIAs DE TRABALHADORES 301, 302, 303, 306, 307, 309)" 																																				,"20210509" } )
		aAdd( aBody, { "", "000045", "20", "APOSENTADORIA POR IDADE E TEMPO DE CONTRIBUI��O (SOMENTE PARA CATEGORIAs DE TRABALHADORES 301, 302, 303, 306, 307, 309)" 																														,"20210718" } )
		aAdd( aBody, { "", "000046", "21", "REFORMA MILITAR (SOMENTE PARA A CATEGORIA DE TRABALHADOR 307)"																																													, "" 		} )
		aAdd( aBody, { "", "000047", "22", "RESERVA MILITAR (SOMENTE PARA A CATEGORIA DE TRABALHADOR 307)"																																													, "" 		} )
		aAdd( aBody, { "", "000048", "23", "EXONERA��O (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301, 302, 303, 306, 307, 309, 310, 312)"																																					, "" 		} )
		aAdd( aBody, { "", "000049", "24", "DEMISS�O (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301, 302, 303, 306, 307, 309, 310, 312)"																																						, "" 		} )
		aAdd( aBody, { "", "000050", "25", "VAC�NCIA PARA ASSUMIR OUTRO CARGO EFETIVO (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301, 307)"																																					, "" 		} )

		//NOTA T�CNICA S-1.0 N� 05/2022
		aAdd( aBody, { "", "000051", "29", "REDISTRIBUI��O OU REFORMA ADMINISTRATIVA"																																																		, "" 		, 1032.05 } )
		aAdd( aBody, { "", "000052", "43", "TRANSFER�NCIA DE EMPREGADO DE EMPRESA CONSIDERADA INAPTA POR INEXIST�NCIA DE FATO"																																								, "" 		, 1032.05 } )

		//NOTA T�CNICA S-1.0 N� 06/2022
		aAdd( aBody, { "", "000053", "44", "AGRUPAMENTO CONTRATUAL"																																																							, "" 		, 1032.08 } )

		aAdd( aRet, { aHeader, aBody } )

	EndIf

Return aRet
