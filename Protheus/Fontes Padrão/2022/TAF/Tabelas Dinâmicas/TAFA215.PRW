#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA215.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA001
Cadastro MVC dos Códigos e AlIquotas de Fpas/Terceiros
Tabela 04

@author Rodrigo Aguilar
@since 06/08/2013
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA215()

	Local oBrw := FWmBrowse():New()

	oBrw:SetDescription( STR0001 )	//Cadastro de Códigos e Alíquotas de Fpas/Terceiros
	oBrw:SetAlias( 'C8A' )
	oBrw:SetMenuDef( 'TAFA215' )
	oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rodrigo Aguilar
@since 06/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA215" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@author Rodrigo Aguilar
@since 06/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruC8A := FWFormStruct( 1, 'C8A' )
	Local oModel   := MPFormModel():New('TAFA215' )

	oModel:AddFields('MODEL_C8A', /*cOwner*/, oStruC8A)
	oModel:GetModel('MODEL_C8A'):SetPrimaryKey({'C8A_FILIAL','C8A_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Rodrigo Aguilar
@since 06/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel( 'TAFA215' )
	Local oStruC8A := FWFormStruct( 2, 'C8A' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_C8A', oStruC8A, 'MODEL_C8A' )

	oView:EnableTitleView( 'VIEW_C8A', STR0001 )	//Cadastro de Códigos e Alíquotas de Fpas/Terceiros
	oView:CreateHorizontalBox( 'FIELDSC8A', 100 )
	oView:SetOwnerView( 'VIEW_C8A', 'FIELDSC8A' )

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

	Local aHeader := {}
	Local aBody   := {}
	Local aRet    := {}

	nVerAtu := 1032.00

	If nVerEmp < nVerAtu

		aAdd( aHeader, "C8A_FILIAL" )
		aAdd( aHeader, "C8A_ID" )
		aAdd( aHeader, "C8A_CDFPAS" )
		aAdd( aHeader, "C8A_SITCTB" )
		aAdd( aHeader, "C8A_CODTER" )
		aAdd( aHeader, "C8A_ALIQ" )
		aAdd( aHeader, "C8A_VALIDA" )

		aAdd( aBody, { "", "000001", "507", "Com convenio Sal. Educ. + SENAI + SESI", "0066", "0.8", "20181231" } )
		aAdd( aBody, { "", "000002", "507", "Com convenio SESI + SENAI", "0067", "3.3", "" } )
		aAdd( aBody, { "", "000003", "507", "Com convenio Sal. Educ. + SESI", "0070", "1.8", "20181231" } )
		aAdd( aBody, { "", "000004", "507", "Com convenio SESI", "0071", "4.3", "" } )
		aAdd( aBody, { "", "000005", "507", "Com convenio Sal. Educ. + SENAI", "0074", "2.3", "20181231" } )
		aAdd( aBody, { "", "000006", "507", "Com convenio SENAI", "0075", "4.8", "" } )
		aAdd( aBody, { "", "000007", "507", "Com convenio Sal. Educacao", "0078", "3.3", "20181231" } )
		aAdd( aBody, { "", "000008", "507", "Sem convenio", "0079", "5.8", "" } )
		aAdd( aBody, { "", "000009", "507", "Com convenio Sal. Educacao (SESCOOP)", "4162", "3.3", "20181231" } )
		aAdd( aBody, { "", "000010", "507", "Sem convenio Sal. Educacao (SESCOOP)", "4163", "5.8", "" } )
		aAdd( aBody, { "", "000011", "663", "Com convenio Sal. Educ. + SENAI + SESI", "0066", "0.8", "" } )
		aAdd( aBody, { "", "000012", "663", "Com convenio SESI + SENAI", "0067", "3.3", "" } )
		aAdd( aBody, { "", "000013", "663", "Com convenio Sal. Educ. + SESI", "0070", "1.8", "" } )
		aAdd( aBody, { "", "000014", "663", "Com convenio SESI", "0071", "4.3", "" } )
		aAdd( aBody, { "", "000015", "663", "Com convenio Sal. Educ. + SENAI", "0074", "2.3", "" } )
		aAdd( aBody, { "", "000016", "663", "Com convenio SENAI", "0075", "4.8", "" } )
		aAdd( aBody, { "", "000017", "663", "Com convenio Sal. Educacao", "0078", "3.3", "" } )
		aAdd( aBody, { "", "000018", "663", "Sem convenio", "0079", "5.8", "" } )
		aAdd( aBody, { "", "000019", "698", "Com convenio Sal. Educ. + SENAI + SESI", "0066", "0.8", "" } )
		aAdd( aBody, { "", "000020", "698", "Com convenio SESI + SENAI", "0067", "3.3", "" } )
		aAdd( aBody, { "", "000021", "698", "Com convenio Sal. Educ. + SESI", "0070", "1.8", "" } )
		aAdd( aBody, { "", "000022", "698", "Com convenio SESI", "0071", "4.3", "" } )
		aAdd( aBody, { "", "000023", "698", "Com convenio Sal. Educ. + SENAI", "0074", "2.3", "" } )
		aAdd( aBody, { "", "000024", "698", "Com convenio SENAI", "0075", "4.8", "" } )
		aAdd( aBody, { "", "000025", "698", "Com convenio Sal. Educacao", "0078", "3.3", "" } )
		aAdd( aBody, { "", "000026", "698", "Sem convenio", "0079", "5.8", "" } )
		aAdd( aBody, { "", "000027", "515", "Com convenio Salario Educacao", "0114", "3.3", "" } )
		aAdd( aBody, { "", "000028", "515", "Sem convenio", "0115", "5.8", "" } )
		aAdd( aBody, { "", "000029", "515", "Com convenio Salario Educacao (SESCOOP)", "4162", "3.3", "" } )
		aAdd( aBody, { "", "000030", "515", "Sem convenio Salario Educacao (SESCOOP)", "4163", "5.8", "" } )
		aAdd( aBody, { "", "000031", "671", "Com convenio Salario Educacao", "0114", "3.3", "" } )
		aAdd( aBody, { "", "000032", "671", "Sem convenio", "0115", "5.8", "" } )
		aAdd( aBody, { "", "000033", "701", "Com convenio Salario Educacao", "0114", "3.3", "" } )
		aAdd( aBody, { "", "000034", "701", "Sem convenio", "0115", "5.8", "" } )
		aAdd( aBody, { "", "000035", "523", "Com convenio Salario Educacao", "0002", "0.2", "" } )
		aAdd( aBody, { "", "000036", "523", "Sem convenio", "0003", "2.7", "" } )
		aAdd( aBody, { "", "000037", "604", "Com convenio Salario Educacao", "0002", "0.2", "20210509" } )
		aAdd( aBody, { "", "000038", "604", "Sem convenio", "0003", "2.7", "20210509" } )
		aAdd( aBody, { "", "000039", "736", "Com convenio Salario Educacao", "0002", "0.2", "" } )
		aAdd( aBody, { "", "000040", "736", "Sem convenio", "0003", "2.7", "" } )
		aAdd( aBody, { "", "000041", "531", "Com convenio Salario Educacao", "0002", "2.7", "" } )
		aAdd( aBody, { "", "000042", "531", "Sem convenio", "0003", "5.2", "" } )
		aAdd( aBody, { "", "000043", "540", "Com convenio Salario Educacao", "0130", "2.7", "" } )
		aAdd( aBody, { "", "000044", "540", "Sem convenio", "0131", "5.2", "" } )
		aAdd( aBody, { "", "000045", "680", "Com convenio Salario Educacao", "0130", "2.7", "" } )
		aAdd( aBody, { "", "000046", "680", "Sem convenio", "0131", "5.2", "" } )
		aAdd( aBody, { "", "000047", "710", "Com convenio Salario Educacao", "0130", "2.7", "" } )
		aAdd( aBody, { "", "000048", "710", "Sem convenio", "0131", "5.2", "" } )
		aAdd( aBody, { "", "000049", "558", "Com convenio Salario Educacao", "0258", "2.7", "" } )
		aAdd( aBody, { "", "000050", "558", "Sem convenio", "0259", "5.2", "" } )
		aAdd( aBody, { "", "000051", "566", "Com convenio Salario Educacao", "0098", "2", "" } )
		aAdd( aBody, { "", "000052", "566", "Sem convenio", "0099", "4.5", "" } )
		aAdd( aBody, { "", "000053", "566", "Com convenio Salario Educacao (SESCOOP)", "4162", "3", "" } )
		aAdd( aBody, { "", "000054", "566", "Sem convenio Salario Educacao (SESCOOP)", "4163", "5.5", "" } )
		aAdd( aBody, { "", "000055", "574", "Com convenio Salario Educacao ou excecao prevista na MP n. 1.518/96.", "0098", "2", "" } )
		aAdd( aBody, { "", "000056", "574", "Sem convenio", "0099", "4.5", "" } )
		aAdd( aBody, { "", "000057", "574", "Com convenio Salario Educacao ou excecao prevista na MP n. 1.518/96 (SESCOOP)", "4162", "3", "" } )
		aAdd( aBody, { "", "000058", "574", "Sem convenio Salario Educacao (SESCOOP)", "4163", "5.5", "" } )
		aAdd( aBody, { "", "000059", "590", "Com convenio Salario Educacao", "0000", "0", "" } )
		aAdd( aBody, { "", "000060", "590", "Sem convenio", "0001", "2.5", "" } )
		aAdd( aBody, { "", "000061", "612", "Com convenio Salario Educacao", "3138", "3.3", "" } )
		aAdd( aBody, { "", "000062", "612", "Com convenio Sal. Educacao + SEST", "2114", "1.8", "" } )
		aAdd( aBody, { "", "000063", "612", "Com convenio Sal. Educacao + SENAT", "1090", "2.3", "" } )
		aAdd( aBody, { "", "000064", "612", "Com convenio Sal. Educ. + SEST + SENAT", "0066", "0.8", "" } )
		aAdd( aBody, { "", "000065", "612", "Com convenio SEST + SENAT", "0067", "3.3", "" } )
		aAdd( aBody, { "", "000066", "612", "Com convenio SEST", "2115", "4.3", "" } )
		aAdd( aBody, { "", "000067", "612", "Com convenio SENAT", "1091", "4.8", "" } )
		aAdd( aBody, { "", "000068", "612", "Sem convenio", "3139", "5.8", "" } )
		aAdd( aBody, { "", "000069", "612", "Com convenio Sal. Educacao (SESCOOP)", "4162", "3.3", "" } )
		aAdd( aBody, { "", "000070", "612", "Sem convenio Sal. Educacao (SESCOOP)", "4163", "5.8", "" } )
		aAdd( aBody, { "", "000071", "620", "Com convenio SEST", "2048", "1", "" } )
		aAdd( aBody, { "", "000072", "620", "Com convenio SENAT", "1024", "1.5", "" } )
		aAdd( aBody, { "", "000073", "620", "Com convenio SEST + SENAT", "0000", "0", "" } )
		aAdd( aBody, { "", "000074", "620", "Sem convenio", "3072", "2.5", "" } )
		aAdd( aBody, { "", "000075", "647", "Com convenio Salario Educacao", "0098", "2", "" } )
		aAdd( aBody, { "", "000076", "647", "Sem convenio", "0099", "4.5", "" } )
		aAdd( aBody, { "", "000077", "655", "Sem convenio", "0001", "2.5", "" } )
		aAdd( aBody, { "", "000078", "744", "Adquirente, Consignatario, Cooperativa, Produtor Rural PJ, Produtor Rural PF e Segurado Especial (qu", "0512", "2.05", "" } )
		aAdd( aBody, { "", "000079", ""   , "Adquirente, Consignatario, Cooperativa, Produtor Rural PF e Segurado Especial (quando comercializare", "0512", "0.2", "20220324" } )
		aAdd( aBody, { "", "000080", ""   , "Produtor Rural PJ e Agroindustria (exceto a de piscicultura, carcinicultura, suinocultura e de avicu", "0512", "0.25", "" } )
		aAdd( aBody, { "", "000081", "787", "Com convenio Salario Educacao", "0514", "2.7", "" } )
		aAdd( aBody, { "", "000082", "787", "INCRA", "0002", "0.2", "" } )
		aAdd( aBody, { "", "000083", "787", "SALARIO EDUCACAO + INCRA + SENAR", "0515", "5.2", "" } )
		aAdd( aBody, { "", "000084", "787", "Com convenio Salario Educacao (SESCOOP)", "4098", "2.7", "" } )
		aAdd( aBody, { "", "000085", "787", "SALARIO EDUCACAO + INCRA + SESCOOP", "4099", "5.2", "" } )
		aAdd( aBody, { "", "000086", "795", "Com convenio Salario Educacao", "0514", "5.2", "" } )
		aAdd( aBody, { "", "000087", "795", "Sem convenio", "0515", "7.7", "" } )
		aAdd( aBody, { "", "000088", "795", "Com convenio Salario Educacao (SESCOOP)", "4098", "5.2", "" } )
		aAdd( aBody, { "", "000089", "795", "Sem convenio Salario Educacao (SESCOOP)", "4099", "7.7", "" } )
		aAdd( aBody, { "", "000090", "825", "Com convenio Salario Educacao", "0002", "2.7", "" } )
		aAdd( aBody, { "", "000091", "825", "SALARIO EDUCACAO + INCRA", "0003", "5.2", "" } )
		aAdd( aBody, { "", "000092", "833", "Com convenio Sal. Educ. + SENAI + SESI", "0066", "0.8", "" } )
		aAdd( aBody, { "", "000093", "833", "Com convenio SESI + SENAI", "0067", "3.3", "" } )
		aAdd( aBody, { "", "000094", "833", "Com convenio Sal. Educ. + SESI", "0070", "1.8", "" } )
		aAdd( aBody, { "", "000095", "833", "Com convenio SESI", "0071", "4.3", "" } )
		aAdd( aBody, { "", "000096", "833", "Com convenio Sal. Educ. + SENAI", "0074", "2.3", "" } )
		aAdd( aBody, { "", "000097", "833", "Com convenio SENAI", "0075", "4.8", "" } )
		aAdd( aBody, { "", "000098", "833", "Com convenio Sal. Educacao", "0078", "3.3", "" } )
		aAdd( aBody, { "", "000099", "833", "Sem convenio", "0079", "5.8", "" } )
		aAdd( aBody, { "", "000100", "639", "Entidade Beneficente de Assistência Social", "0000", "0", "" } )
		aAdd( aBody, { "", "000101", "507", "Com convenio INCRA", "0077", "5.6", "20181231" } )
		aAdd( aBody, { "", "000102", "507", "Com convenio SEBRAE", "0015", "5.2", "20181231" } )
		aAdd( aBody, { "", "000103", "507", "Com convenio INCRA + SEBRAE", "0013", "5", "20181231" } )
		aAdd( aBody, { "", "000104", "507", "Com convenio Sal. Educ. + SENAI + SESI + SEBRAE", "0002", "0.2", "20181231" } )
		aAdd( aBody, { "", "000105", "507", "Com convenio INCRA + SENAI + SESI", "0065", "3.1", "20181231" } )
		aAdd( aBody, { "", "000106", "507", "Sal. Educ.", "0001", "2.5", "" } )
		aAdd( aBody, { "", "000107", "507", "INCRA", "0002", "0.2", "" } )
		aAdd( aBody, { "", "000108", "507", "SENAI", "0004", "1.0", "" } )
		aAdd( aBody, { "", "000109", "507", "SESI", "0008", "1.5", "" } )
		aAdd( aBody, { "", "000110", "507", "SEBRAE", "0064", "0.6", "" } )
		aAdd( aBody, { "", "000111", "507", "SESCOOP", "4096", "2.5", "" } )
		aAdd( aBody, { "", "000112", "515", "SALÁRIO EDUCAÇÃO", "0001", "2.5", "" } )
		aAdd( aBody, { "", "000113", "515", "INCRA", "0002", "0.2", "" } )
		aAdd( aBody, { "", "000114", "515", "SENAC", "0016", "1.0", "" } )
		aAdd( aBody, { "", "000115", "515", "SESC", "0032", "1.5", "" } )
		aAdd( aBody, { "", "000116", "515", "SEBRAE", "0064", "0.6", "" } )
		aAdd( aBody, { "", "000117", "515", "SESCOOP", "4096", "2.5", "" } )
		aAdd( aBody, { "", "000118", "787", "Salário educação + INCRA ", "0003", "2.7", "" } )

		aAdd( aBody, { "", "000119", "515", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000120", "507", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000121", "612", "Sem Convênio", "0000", "0", "" } )

		aAdd( aBody, { "", "000122", "523", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000123", "531", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000124", "540", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000125", "558", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000126", "566", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000127", "574", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000128", "604", "Sem Convênio", "0000", "0", "20210509" } )
		aAdd( aBody, { "", "000129", "647", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000130", "655", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000131", "663", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000132", "671", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000133", "680", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000134", "698", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000135", "701", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000136", "710", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000137", "736", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000138", "744", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000139", "787", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000140", "795", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000141", "825", "Sem Convênio", "0000", "0", "" } )
		aAdd( aBody, { "", "000142", "833", "Sem Convênio", "0000", "0", "" } )

		//Simplificação

		//Alterações
		aAdd( aBody, { "", "000143", "604", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000144", "604", "INCRA"											, "0002", "0.2", "" } )
		aAdd( aBody, { "", "000145", "604", "SALARIO EDUCACAO + INCRA"						, "0003", "2.7", "" } )
		aAdd( aBody, { "", "000146", "787", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000147", "787", "INCRA"											, "0002", "0.2", "20220324" } )
		aAdd( aBody, { "", "000148", "787", "SENAR"											, "0512", "2.5", "" } )
		aAdd( aBody, { "", "000149", "787", "SESCOOP"										, "4096", "2.5", "" } )
		aAdd( aBody, { "", "000150", "787", "SALARIO EDUCACAO + INCRA + SENAR"				, "0515", "5.2", "20220324" } )
		aAdd( aBody, { "", "000151", "787", "SALARIO EDUCACAO + INCRA + SESCOOP"			, "4099", "5.2", "20220324" } )

		//Inclusões
		aAdd( aBody, { "", "000152", "523", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000153", "531", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000154", "540", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000155", "540", "INCRA"											, "0002", "0.2", "" } )
		aAdd( aBody, { "", "000156", "540", "DPC"											, "0128", "2.5", "" } )
		aAdd( aBody, { "", "000157", "558", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000158", "558", "INCRA"											, "0002", "0.2", "" } )
		aAdd( aBody, { "", "000159", "558", "FUNDO AEROVIARIO"								, "0256", "2.5", "" } )
		aAdd( aBody, { "", "000160", "566", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000161", "566", "INCRA"											, "0002", "0.2", "" } )
		aAdd( aBody, { "", "000162", "566", "SESC"											, "0032", "1.5", "" } )
		aAdd( aBody, { "", "000163", "566", "SEBRAE"										, "0064", "0.3", "" } )
		aAdd( aBody, { "", "000164", "566", "SESCOOP"										, "4096", "2.5", "" } )
		aAdd( aBody, { "", "000165", "574", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000166", "574", "INCRA"											, "0002", "0.2", "" } )
		aAdd( aBody, { "", "000167", "574", "SESC"											, "0032", "1.5", "" } )
		aAdd( aBody, { "", "000168", "574", "SEBRAE"										, "0064", "0.3", "" } )
		aAdd( aBody, { "", "000169", "574", "SESCOOP"										, "4096", "2.5", "" } )
		aAdd( aBody, { "", "000170", "582", "ORGANISMO OFICIAL BRASILEIRO E INTERNACIONAL"	, "0000", "0.0", "" } )
		aAdd( aBody, { "", "000171", "612", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000172", "612", "INCRA"											, "0002", "0.2", "" } )
		aAdd( aBody, { "", "000173", "612", "SEBRAE"										, "0064", "0.6", "" } )
		aAdd( aBody, { "", "000174", "612", "SEST"											, "1024", "1.5", "" } )
		aAdd( aBody, { "", "000175", "612", "SENAT"											, "2048", "1.0", "" } )
		aAdd( aBody, { "", "000176", "612", "SESCOOP"										, "4096", "2.5", "" } )	
		aAdd( aBody, { "", "000177", "647", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000178", "647", "INCRA"											, "0002", "0.2", "" } )
		aAdd( aBody, { "", "000179", "647", "SESC"											, "0032", "1.5", "" } )
		aAdd( aBody, { "", "000180", "647", "SEBRAE"										, "0064", "0.3", "" } )	
		aAdd( aBody, { "", "000181", "680", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000182", "680", "INCRA"											, "0002", "0.2", "" } )
		aAdd( aBody, { "", "000183", "680", "DPC"											, "0128", "2.5", "" } )
		aAdd( aBody, { "", "000184", "736", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000185", "744", "ADQUIRE PROD. RURAL DE PRODUTOR PF"			, "0512", "1.5", "" } )
		aAdd( aBody, { "", "000186", "779", "ASSOC. DESPORTIVA FUTEBOL PROF. E FEDERACOES"	, "0000", "0.0", "" } )
		aAdd( aBody, { "", "000187", "795", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000188", "795", "INCRA"											, "0002", "2.7", "" } )
		aAdd( aBody, { "", "000189", "795", "SESCOOP"										, "4096", "2.5", "" } )
		aAdd( aBody, { "", "000190", "825", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		
		aAdd( aBody, { "", "000192", "833", "SALARIO EDUCACAO"								, "0001", "2.5", "" } )
		aAdd( aBody, { "", "000193", "833", "INCRA"											, "0002", "0.2", "" } )
		aAdd( aBody, { "", "000194", "833", "SENAI"											, "0004", "1.0", "" } )
		aAdd( aBody, { "", "000195", "833", "SESI"											, "0008", "1.5", "" } )
		aAdd( aBody, { "", "000196", "833", "SEBRAE"										, "0064", "0.6", "" } )
		aAdd( aBody, { "", "000197", "833", "SESCOOP"										, "4096", "2.5", "" } )
		aAdd( aBody, { "", "000198", "833", "SALARIO EDUCACAO + INCRA + SEBRAE + SESCOOP"	, "4163", "5.8", "" } )
		aAdd( aBody, { "", "000199", "868", "EMPREGADOR DOMESTICO"							, "0000", "0.0", "" } )
		aAdd( aBody, { "", "000200", "876", "MISSOES DIPLOMATICAS" 							, "0000", "0.0", "" } )

		aAdd( aRet, { aHeader, aBody } )

	EndIf

Return( aRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAGetId

Rotina para carga e atualização da tabela autocontida.
Retorna próximo ID a ser utilizado.

@Return		cRet - ID disponível para utilização

@Author		Felipe de Carvalho Seolin
@Since		17/10/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function TAFAGetId( )

	Local cRet      := ''
	Local aAreaC8A  := C8A->(GetArea())
	Local lContinua := .T.

	C8A->(DbSetOrder(1))	//C8A_FILIAL+C8A_ID

	While lContinua

		cRet	:= GetSX8Num('C8A','C8A_ID')

		lContinua := ( C8A->(MsSeek(xFilial('C8A') + cRet)) )
		ConfirmSX8()

	EndDo

	RestArea(aAreaC8A)

Return(cRet)
