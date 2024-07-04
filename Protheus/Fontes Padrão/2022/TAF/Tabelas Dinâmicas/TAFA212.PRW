#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA212.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA212

Cadastro MVC das Categorias de Trabalhadores do eSocial
Tabela 01

@author Felipe C. Seolin
@since 06/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA212()

	Local oBrw := FwMBrowse():New()

	oBrw:SetDescription(STR0001) //"Cadastro das Categorias de Trabalhadores"
	oBrw:SetAlias("C87")
	oBrw:SetMenuDef("TAFA212")
	oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 06/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA212"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 06/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruC87 := FwFormStruct(1,"C87")
	Local oModel   := MpFormModel():New("TAFA212")

	oModel:AddFields("MODEL_C87",/*cOwner*/,oStruC87)
	oModel:GetModel("MODEL_C87"):SetPrimaryKey({"C87_FILIAL","C87_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 06/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FwLoadModel("TAFA212")
	Local oStruC87 := FwFormStruct(2,"C87")
	Local oView    := FwFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_C87",oStruC87,"MODEL_C87")

	oView:EnableTitleView("VIEW_C87",STR0001) //"Cadastro das Categorias de Trabalhadores")
	oView:CreateHorizontalBox("FIELDSC87",100)
	oView:SetOwnerView("VIEW_C87","FIELDSC87")

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
Static Function FAtuCont(nVerEmp, nVerAtu)

	Local aHeader := {}
	Local aBody   := {}
	Local aRet    := {}

	nVerAtu := 1032.05

	If nVerEmp < nVerAtu
	
		aAdd( aHeader, "C87_FILIAL" )
		aAdd( aHeader, "C87_ID" 	)
		aAdd( aHeader, "C87_CODIGO" )
		aAdd( aHeader, "C87_DESCRI" )
		aAdd( aHeader, "C87_VALIDA" )
		aAdd( aHeader, "C87_ALTCON" )

		//Empregado e Trabalhador Temporário
		aAdd( aBody, { "", "000001", "101", "EMPREGADO – GERAL INCLUSIVE O EMPREGADO PÚBLICO DA ADMINISTRAÇÃO DIRETA OU INDIRETA CONTRATADO PELA CLT.", "" } )
		aAdd( aBody, { "", "000002", "102", "EMPREGADO – TRABALHADOR RURAL POR PEQUENO PRAZO DA LEI 11.718/2008", "" } )
		aAdd( aBody, { "", "000003", "103", "EMPREGADO – APRENDIZ", "" } )
		aAdd( aBody, { "", "000004", "104", "EMPREGADO – DOMÉSTICO", "" } )
		aAdd( aBody, { "", "000005", "105", "EMPREGADO – CONTRATO A TERMO FIRMADO NOS TERMOS DA LEI 9601/98", "" } )
		aAdd( aBody, { "", "000006", "106", "TRABALHADOR TEMPORÁRIO - CONTRATO NOS TERMOS DA LEI 6.019/74", "" } )
		aAdd( aBody, { "", "000007", "107", "TRABALHADOR NAO VINCULADO AO RGPS COM DIREITO AO FGTS", "20191231" } )
		
		//Avulso
		aAdd( aBody, { "", "000008", "201", "TRABALHADOR AVULSO – PORTUARIO", "" } )
		aAdd( aBody, { "", "000009", "202", "TRABALHADOR AVULSO – NÃO PORTUÁRIO", "" } )
		aAdd( aBody, { "", "000010", "203", "TRABALHADOR AVULSO – NAO PORTUARIO (INFORMACAO DO CONTRATANTE)", "20210509" } )
		
		//Agente Público
		aAdd( aBody, { "", "000011", "301", "AGENTE PÚBLICO – SERVIDOR PÚBLICO TITULAR DE CARGO EFETIVO, MAGISTRADO, MINISTRO DE TRIBUNAL DE CONTAS, CONSELHEIRO DE TRIBUNAL DE CONTAS E MEMBRO DO MINISTÉRIO PÚBLICO", "" } )
		aAdd( aBody, { "", "000012", "302", "AGENTE PÚBLICO – SERVIDOR PÚBLICO OCUPANTE DE CARGO EXCLUSIVO EM COMISSÃO", "" } )
		aAdd( aBody, { "", "000013", "303", "AGENTE PÚBLICO – EXERCENTE DE MANDATO ELETIVO", "" } )
		aAdd( aBody, { "", "000014", "304", "AGENTE PÚBLICO – SERVIDOR PUBLICO EXERCENTE DE MANDATO ELETIVO, INCLUSIVE COM EXERCICIO DE CARGO EM COMISSAO", "" } )
		aAdd( aBody, { "", "000015", "305", "AGENTE PÚBLICO - SERVIDOR PÚBLICO INDICADO PARA CONSELHO OU ÓRGÃO DELIBERATIVO, NA CONDIÇÃO DE REPRESENTANTE DO GOVERNO, ÓRGÃO OU ENTIDADE DA ADMINISTRAÇÃO PÚBLICA", "" } )
		
		//Cessão
		aAdd( aBody, { "", "000016", "401", "CESSÃO - DIRIGENTE SINDICAL – EM RELACAO A REMUNERACAO RECEBIDA NO SINDICATO.", "" } )
		
		//Contribuinte Individual		
		aAdd( aBody, { "", "000017", "701", "CONTRIBUINTE INDIVIDUAL – CONTRIBUINTE INDIVIDUAL - AUTÔNOMO EM GERAL, EXCETO SE ENQUADRADO EM UMA DAS DEMAIS CATEGORIAS DE CONTRIBUINTE INDIVIDUAL", "" } )
		aAdd( aBody, { "", "000018", "702", "CONTRIBUINTE INDIVIDUAL – AUTONOMO CONTRATADO POR CONTRIBUINTE INDIVIDUAL, POR PESSOA FISICA EM GERAL, OU POR MISSAO DIPLOMATICA E REPARTICAO CONSULAR DE CARREIRA ESTRANGEIRAS", "20210509" } )
		aAdd( aBody, { "", "000019", "703", "CONTRIBUINTE INDIVIDUAL – AUTONOMO CONTRATADO POR ENTIDADE BENEFICENTE DE ASSISTENCIA SOCIAL ISENTA DA COTA PATRONAL", "20210509" } )
		aAdd( aBody, { "", "000020", "704", "EXCLUIDO.", "20210509" } )
		aAdd( aBody, { "", "000021", "711", "CONTRIBUINTE INDIVIDUAL – TRANSPORTADOR AUTÔNOMO DE PASSAGEIROS", "" } )
		aAdd( aBody, { "", "000022", "712", "CONTRIBUINTE INDIVIDUAL – TRANSPORTADOR AUTÔMOMO DE CARGA", "" } )
		aAdd( aBody, { "", "000023", "713", "CONTRIBUINTE INDIVIDUAL – TRANSPORTADOR AUTONOMO CONTRATADO POR ENTIDADE BENEFICENTE DE ASSISTENCIA SOCIAL ISENTA DA COTA PATRONAL", "20210509" } )
		aAdd( aBody, { "", "000024", "721", "CONTRIBUINTE INDIVIDUAL – DIRETOR NAO EMPREGADO COM FGTS", "" } )
		aAdd( aBody, { "", "000025", "722", "CONTRIBUINTE INDIVIDUAL – DIRETOR NAO EMPREGADO SEM FGTS", "" } )
		aAdd( aBody, { "", "000026", "731", "CONTRIBUINTE INDIVIDUAL – COOPERADO QUE PRESTA SERVIÇOS POR INTERMÉDIO DE COOPERATIVA DE TRABALHO", "" } )
		aAdd( aBody, { "", "000027", "732", "CONTRIBUINTE INDIVIDUAL – COOPERADO QUE PRESTA SERVICOS A ENTIDADE BENEFICENTE DE ASSISTENCIA SOCIAL ISENTA DA COTA PATRONAL OU PARA PESSOA FISICA", "20210509" } )
		aAdd( aBody, { "", "000028", "733", "CONTRIBUINTE INDIVIDUAL – COOPERADO ELEITO PARA DIRECAO DA COOPERATIVA", "20210509" } )
		aAdd( aBody, { "", "000029", "734", "CONTRIBUINTE INDIVIDUAL – TRANSPORTADOR COOPERADO QUE PRESTA SERVIÇOS POR INTERMÉDIO DE COOPERATIVA DE TRABALHO", "" } )
		aAdd( aBody, { "", "000030", "735", "CONTRIBUINTE INDIVIDUAL – TRANSPORTADOR COOPERADO QUE PRESTA SERVICOS A ENTIDADE BENEFICENTE DE ASSISTENCIA SOCIAL ISENTA DA COTA PATRONAL OU PARA PESSOA FISICA", "20210509" } )
		aAdd( aBody, { "", "000031", "736", "CONTRIBUINTE INDIVIDUAL – TRANSPORTADOR COOPERADO ELEITO PARA DIRECAO DA COOPERATIVA.", "20210509" } )
		aAdd( aBody, { "", "000032", "741", "CONTRIBUINTE INDIVIDUAL – MICROEMPREENDEDOR INDIVIDUAL", "" } )
		aAdd( aBody, { "", "000033", "751", "CONTRIBUINTE INDIVIDUAL – MAGISTRADO CLASSISTA TEMPORÁRIO DA JUSTIÇA DO TRABALHO OU DA JUSTIÇA ELEITORAL QUE SEJA APOSENTADO DE QUALQUER REGIME PREVIDENCIÁRIO", "" } )
		
		//Bolsista
		aAdd( aBody, { "", "000034", "901", "BOLSISTAS - ESTAGIARIO", "" } )
		
		//Agente Público
		aAdd( aBody, { "", "000035", "306", "AGENTE PÚBLICO - SERVIDOR PUBLICO CONTRATADO POR TEMPO DETERMINADO, SUJEITO A REGIME ADMINISTRATIVO ESPECIAL DEFINIDO EM LEI PROPRIA", "" } )
		aAdd( aBody, { "", "000036", "307", "AGENTE PÚBLICO - MILITAR", "" } )
		aAdd( aBody, { "", "000037", "308", "AGENTE PÚBLICO - CONSCRITO", "" } )
		aAdd( aBody, { "", "000038", "309", "AGENTE PÚBLICO - OUTROS", "" } )
		
		//Cessão
		aAdd( aBody, { "", "000039", "410", "CESSÃO - TRABALHADOR CEDIDO/EXERCICIO EM OUTRO ORGAO/JUIZ AUXILIAR - INFORMACAO PRESTADA PELO CESSIONARIO/DESTINO", "" } )
		
		//Contribuinte Individual
		aAdd( aBody, { "", "000040", "723", "CONTRIBUINTE INDIVIDUAL – EMPRESÁRIOS, SÓCIOS E MEMBRO DE CONSELHO DE ADMINISTRAÇÃO OU FISCAL", "" } )
		aAdd( aBody, { "", "000041", "738", "CONTRIBUINTE INDIVIDUAL – COOPERADO FILIADO A COOPERATIVA DE PRODUÇÃO", "" } )
		aAdd( aBody, { "", "000042", "761", "CONTRIBUINTE INDIVIDUAL – ASSOCIADO ELEITO PARA DIREÇÃO DE COOPERATIVA, ASSOCIAÇÃO OU ENTIDADE DE CLASSE DE QUALQUER NATUREZA OU FINALIDADE, BEM COMO O SÍNDICO OU ADMINISTRADOR ELEITO PARA EXERCER ATIVIDADE DE DIREÇÃO CONDOMINIAL, DESDE QUE RECEBAM REMUNERAÇÃO", "" } )
		aAdd( aBody, { "", "000043", "771", "CONTRIBUINTE INDIVIDUAL – MEMBRO DE CONSELHO TUTELAR, NOS TERMOS DA LEI Nº 8.069, DE 13 DE JULHO DE 1990", "" } )
		aAdd( aBody, { "", "000044", "781", "CONTRIBUINTE INDIVIDUAL – MINISTRO DE CONFISSÃO RELIGIOSA OU MEMBRO DE VIDA CONSAGRADA, DE CONGREGAÇÃO OU DE ORDEM RELIGIOSA", "" } )
		
		//Bolsista
		aAdd( aBody, { "", "000045", "902", "BOLSISTAS - MÉDICO RESIDENTE OU RESIDENTE EM ÁREA PROFISSIONAL DE SAÚDE", "" } )
		aAdd( aBody, { "", "000046", "903", "BOLSISTAS", "" } )
		aAdd( aBody, { "", "000047", "904", "BOLSISTAS - PARTICIPANTE DE CURSO DE FORMAÇÃO, COMO ETAPA DE CONCURSO PÚBLICO, SEM VÍNCULO DE EMPREGADO/ESTATUTÁRIO.", "" } )
		aAdd( aBody, { "", "000048", "905", "BOLSISTAS - ATLETA NÃO PROFISSIONAL EM FORMAÇÃO QUE RECEBA BOLSA.", "20211110" } )
		
		//Empregado e Trabalhador Temporário
		aAdd( aBody, { "", "000049", "111", "EMPREGADO - CONTRATO DE TRABALHO INTERMITENTE", "" } )
		aAdd( aBody, { "", "000050", "107", "EMPREGADO - CONTRATO DE TRABALHO VERDE E AMARELO - SEM ACORDO PARA ANTECIPAÇÃO MENSAL DA MULTA RESCISÓRIA DO FGTS", "" } )
		aAdd( aBody, { "", "000051", "108", "EMPREGADO - CONTRATO DE TRABALHO VERDE E AMARELO - COM ACORDO PARA ANTECIPAÇÃO MENSAL DA MULTA RESCISÓRIA DO FGTS", "" } )

		//Simplificação do E-Solcial
		//Agente Público
		aAdd( aBody, { "", "000053", "310", "AGENTE PÚBLICO - SERVIDOR PUBLICO EVENTUAL", "" } )
		aAdd( aBody, { "", "000054", "311", "AGENTE PÚBLICO - MINISTROS, JUIZES, PROCURADORES, PROMOTORES OU OFICIAIS DE JUSTICA A DISPOSICAO DA JUSTICA ELEITORAL ", "" } )
		aAdd( aBody, { "", "000055", "312", "AGENTE PÚBLICO - AUXILIAR LOCAL", "" } )
		aAdd( aBody, { "", "000056", "313", "AGENTE PÚBLICO - SERVIDOR PUBLICO EXERCENTE DE ATIVIDADE DE INSTRUTORIA, CAPACITACAO, TREINAMENTO, CURSO OU CONCURSO, OU CONVOCADO PARA PARECERES TECNICOS OU DEPOIMENTOS", "" } )

		//NT - 02/202 - Leiaute S-1.0
		//Segurado Especial
		aAdd( aBody, { "", "000057", "501", "DIRIGENTE SINDICAL - SEGURADO ESPECIAL", "" } )

		//NOTA TÉCNICA S-1.0 Nº 05/2022
		//Bolsista
		aAdd( aBody, { "", "000058", "906", "BOLSISTAS - BENEFICIÁRIO DO PROGRAMA NACIONAL DE PRESTAÇÃO DE SERVIÇO CIVIL VOLUNTÁRIO", "", 1032.05 } )

		aAdd( aRet, { aHeader, aBody } )

	EndIf

Return aRet
