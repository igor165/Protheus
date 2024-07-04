#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA383
Cadastro de Ativos no Exterior (ECF)

@author Evandro dos Santos Oliveira
@since 06/05/2015
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA383()
Local   oBrw  :=  FWmBrowse():New()

oBrw:SetDescription("Cadastro de Ativos no Exterior")    //"Cadastro de Ativos no Exterior"
oBrw:SetAlias( 'CW6')
oBrw:SetMenuDef( 'TAFA383' )
CW6->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Evandro dos Santos Oliveira	
@since 06/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA383" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Evandro dos Santos Oliveira
@since 06/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCW6  :=  FWFormStruct( 1, 'CW6' )
Local oModel    :=  MPFormModel():New( 'TAFA383' )

oModel:AddFields('MODEL_CW6', /*cOwner*/, oStruCW6)
oModel:GetModel('MODEL_CW6'):SetPrimaryKey({'CW6_FILIAL','CW6_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Evandro dos Santos Oliveira 
@since 06/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA383' )
Local   oStruCW6    :=  FWFormStruct( 2, 'CW6' )
Local   oView       :=  FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CW6', oStruCW6, 'MODEL_CW6' )

oView:EnableTitleView( 'VIEW_CW6',"Cadastro de Ativos no Exterior")    //"Cadastro de Ativos no Exterior"
oView:CreateHorizontalBox( 'FIELDSCW6', 100 )
oView:SetOwnerView( 'VIEW_CW6', 'FIELDSCW6' )

oStruCW6:RemoveField( "CW6_ID" )

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

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1005

If nVerEmp < nVerAtu
	aAdd( aHeader, "CW6_FILIAL" )
	aAdd( aHeader, "CW6_ID" )
	aAdd( aHeader, "CW6_CODIGO" )
	aAdd( aHeader, "CW6_DESCRI" )
	aAdd( aHeader, "CW6_GRUPO" )
	aAdd( aHeader, "CW6_DTINI" )
	aAdd( aHeader, "CW6_DTFIN" )

	aAdd( aBody, { "", "cf9e3568-ef21-eb07-441c-7fe348eeddfa", "0102", "PREDIO COMERCIAL", "1", "20140101", "" } )
	aAdd( aBody, { "", "7e337ecf-f403-a07d-ca53-3b017c3648e8", "0103", "GALPAO", "1", "20140101", "" } )
	aAdd( aBody, { "", "4bc6c06d-44b5-ed2e-13ec-fcd02ac29279", "0111", "APARTAMENTO", "1", "20140101", "" } )
	aAdd( aBody, { "", "eed2de0f-ef55-e324-fe6f-942fb4c8c9d5", "0112", "CASA", "1", "20140101", "" } )
	aAdd( aBody, { "", "8ba7e246-0381-96b9-67c5-d81731a62521", "0113", "TERRENO", "1", "20140101", "" } )
	aAdd( aBody, { "", "df8a193c-e81a-38bd-9a1b-04b850b86d7a", "0114", "TERRA NUA", "1", "20140101", "" } )
	aAdd( aBody, { "", "59035a6f-6365-8e45-49ab-604c13340920", "0115", "SALA OU CONJUNTO", "1", "20140101", "" } )
	aAdd( aBody, { "", "bc3e9c11-5e61-42ca-0926-2af224e8da09", "0116", "CONSTRUCAO", "1", "20140101", "" } )
	aAdd( aBody, { "", "a552fa57-c2eb-5f5b-e12c-2616675cfaf5", "0117", "BENFEITORIAS", "1", "20140101", "" } )
	aAdd( aBody, { "", "5c53f39b-ca77-37a7-f9b0-286418d2d99e", "0118", "LOJA", "1", "20140101", "" } )
	aAdd( aBody, { "", "2c19e56d-2eb2-2a07-ca29-a3bccc4026c9", "0119", "OUTROS IMOVEIS", "1", "20140101", "" } )
	aAdd( aBody, { "", "01667c47-2808-344b-6505-bf53551e70f2", "0221", '"VEICULO AUTOMOTOR TERRESTRE: CAMINHAO, AUTOMOVEL, MOTO, ETC."', "2", "20140101", "" } )
	aAdd( aBody, { "", "21c7e388-e450-427d-3706-708b4bc6d7fd", "0222", "AERONAVE", "2", "20140101", "" } )
	aAdd( aBody, { "", "a7fc40a8-3ebf-f368-ef13-f89e136bf028", "0223", "EMBARCACAO", "2", "20140101", "" } )
	aAdd( aBody, { "", "4d790345-d976-49d2-a694-2a2542d9f24f", "0224", "BEM RELACIONADO COM O EXERCICIO DA ATIVIDADE AUTONOMA", "2", "20140101", "" } )
	aAdd( aBody, { "", "d497d834-3c56-9b30-cd16-9ba5885bd7d1", "0225", '"JOIA, QUADRO, OBJETO DE ARTE, DE COLECAO, ANTIGUIDADE, ETC."', "2", "20140101", "" } )
	aAdd( aBody, { "", "b62b77b2-387a-a45c-f3b7-61381a9472d5", "0226", "LINHA TELEFONICA", "2", "20140101", "" } )
	aAdd( aBody, { "", "1765a4b4-ebd1-fa01-c335-91fea6be764b", "0229", "OUTROS BENS MOVEIS", "2", "20140101", "" } )
	aAdd( aBody, { "", "4e47cf3f-92ea-fc41-0ddf-8d0c0abdcb34", "0331", "ACOES", "3", "20140101", "" } )
	aAdd( aBody, { "", "9942fe18-ec9b-f2f1-36ee-2e428689b427", "0332", "QUOTAS OU QUINHOES DE CAPITAL", "3", "20140101", "" } )
	aAdd( aBody, { "", "3da06862-9123-02cb-22a6-3d307448efa9", "0339", "OUTRAS PARTICIPACOES SOCIETARIAS", "3", "20140101", "" } )
	aAdd( aBody, { "", "942c4922-f90e-4d48-eec2-576e21be561d", "0000", "APLICACOES E INVESTIMENTOS", "4", "20140101", "" } )
	aAdd( aBody, { "", "a57adbe1-e0c1-6505-e5f3-81a0f354336e", "0441", "CADERNETA DE POUPANCA", "4", "20140101", "" } )
	aAdd( aBody, { "", "dc84a57e-067d-c1eb-a578-7c8ff0f81d95", "0445", '"APLICACAO DE RENDA FIXA (CDB, RDB E OUTROS)"', "4", "20140101", "" } )
	aAdd( aBody, { "", "4a00344d-cd8e-536a-503e-ffdec2f5ef9a", "0446", '"OURO, ATIVO FINANCEIRO"', "4", "20140101", "" } )
	aAdd( aBody, { "", "5eda4768-0754-9e71-c064-457fe4e2f53c", "0447", '"MERCADOS FUTUROS, DE OPCOES E A TERMO"', "4", "20140101", "" } )
	aAdd( aBody, { "", "6604163f-dd4a-42fe-8672-10b069bcdac4", "0449", "OUTRAS APLICACOES E INVESTIMENTOS", "4", "20140101", "" } )
	aAdd( aBody, { "", "70a19d27-5ac2-26dc-f33e-c101c88c9935", "0551", "CREDITO DECORRENTE DE EMPRESTIMO", "5", "20140101", "" } )
	aAdd( aBody, { "", "3ac65d2f-47c2-263c-2e6a-fac4aba031c2", "0552", "CREDITO DECORRENTE DE ALIENACAO", "5", "20140101", "" } )
	aAdd( aBody, { "", "858a448a-578c-5087-587c-f12a0bde98e5", "0553", "PLANO PAIT E CADERNETA DE PECULIO", "5", "20140101", "" } )
	aAdd( aBody, { "", "cba0f80c-b4be-95e7-3e58-102181605871", "0554", "POUPANCA PARA CONSTRUCAO OU AQUISICAO DE BEM IMOVEL", "5", "20140101", "" } )
	aAdd( aBody, { "", "179b99e4-0992-1fe6-52c0-0059b669f388", "0559", "OUTROS CREDITOS E POUPANCA VINCULADOS", "5", "20140101", "" } )
	aAdd( aBody, { "", "c99bc653-85fc-ed73-0e93-1b52e8b9414c", "0662", "DEPOSITO BANCARIO EM CONTA CORRENTE", "6", "20140101", "" } )
	aAdd( aBody, { "", "7db4f183-ba37-3a8c-8709-0f67f9cea68f", "0663", "DINHEIRO EM ESPECIE - MOEDA NACIONAL", "6", "20140101", "" } )
	aAdd( aBody, { "", "10b0ccc3-27f1-6a2a-feea-cac584a8389c", "0664", "DINHEIRO EM ESPECIE - MOEDA ESTRANGEIRA", "6", "20140101", "" } )
	aAdd( aBody, { "", "11217bc2-0056-c2f6-80f4-7e6d0ddc51cc", "0669", "OUTROS DEPOSITOS A VISTA E NUMERARIO", "6", "20140101", "" } )
	aAdd( aBody, { "", "05886c90-561d-3875-cc81-f32104d57989", "0771", "FUNDO DE INVESTIMENTO FINANCEIRO - FIF", "7", "20140101", "" } )
	aAdd( aBody, { "", "913e4259-d6a4-bab6-1949-2f32794e6f4a", "0772", "FUNDO DE APLICACAO EM QUOTAS DE FUNDOS DE INVESTIMENTO", "7", "20140101", "" } )
	aAdd( aBody, { "", "9aef7a72-cda3-f933-2332-6ada72fefcb2", "0773", "FUNDO DE CAPITALIZACAO", "7", "20140101", "" } )
	aAdd( aBody, { "", "c9fc889a-9338-2076-1242-2135e415963d", "0774", '"FUNDO DE ACOES, INCLUSIVE CARTEIRA LIVRE E FUNDO DE INVESTIMENTO "', "7", "20140101", "" } )
	aAdd( aBody, { "", "7750f6ae-8fa2-eef7-8c3f-fd29af27409d", "0779", "OUTROS FUNDOS", "7", "20140101", "" } )
	aAdd( aBody, { "", "4a463d38-d69b-fde2-84ad-7da6731d5b77", "0991", "LICENCA E CONCESSAO ESPECIAIS", "9", "20140101", "" } )
	aAdd( aBody, { "", "a7478b65-0472-c8e9-6d1b-790b03270f8a", "0992", "TITULO DE CLUBE E ASSEMELHADO", "9", "20140101", "" } )
	aAdd( aBody, { "", "6566105d-bf80-1f01-08ad-2c3bc3c111ae", "0993", '"DIREITO DE AUTOR, DE INVENTOR E DE PATENTE"', "9", "20140101", "" } )
	aAdd( aBody, { "", "c35f3103-9810-7e28-5e2d-5910e4a19dc0", "0994", "DIREITO DE LAVRA E ASSEMELHADO", "9", "20140101", "" } )
	aAdd( aBody, { "", "bc176a3a-7863-2823-c440-7195bc3a5c5d", "0995", "CONSORCIO NAO CONTEMPLADO", "9", "20140101", "" } )
	aAdd( aBody, { "", "c70c998b-cde0-cbea-798d-327525c4e8d3", "0996", "LEASING", "9", "20140101", "" } )
	aAdd( aBody, { "", "82de7624-d7f2-6abf-2459-19868972bab9", "0999", "OUTROS BENS E DIREITOS", "9", "20140101", "" } )
	aAdd( aBody, { "", "52ede59c-4e6c-358b-07c9-082d34311884", "1011", '"PREDIO, GALPAO, ESTABULO, MANGUEIRA, CURRAL, AVIARIO, COMPORTA, CANAL, ACUDE, BARRAGEM."', "1", "20140101", "" } )
	aAdd( aBody, { "", "ec2072ff-f232-4997-f9ec-593a94b148c3", "1012", "INSTALACAO PARA ABRIGO E/OU TRATAMENTO DE ANIMAIS E CERCAS.", "1", "20140101", "" } )
	aAdd( aBody, { "", "cc6d4e08-55f8-feba-b727-1a67b5c55770", "1013", '"ELETRIFICACAO RURAL, TELEFONE, RADIO, BUSSOLA, SONDA, RADAR."', "1", "20140101", "" } )
	aAdd( aBody, { "", "b5adc84a-b26c-47e7-9778-6b0e910dff61", "1014", '"CULTURAS PERMANENTES, ESSENCIAS FLORESTAIS, PASTAGENS ARTIFICIAIS."', "1", "20140101", "" } )
	aAdd( aBody, { "", "feb84f4a-dbc1-a219-976e-2765babbf28d", "1015", "PRODUTOS ESTOCADOS.", "1", "20140101", "" } )
	aAdd( aBody, { "", "dd98ec71-28f0-a087-cd47-3cdaddf7dede", "1016", '"TRATOR, VEICULO DE CARGA, UTILITARIO RURAL, EMBARCACAO, AERONAVE DE USO AGRICOLA."', "1", "20140101", "" } )
	aAdd( aBody, { "", "710434b3-6695-9913-eeb6-8a2a964c4d07", "1017", "MOTORES E IMPLEMENTOS AGRICOLAS EM GERAL.", "1", "20140101", "" } )
	aAdd( aBody, { "", "eabb727e-1a90-871d-e2e6-8ee426ef0e6c", "1018", "EQUIPAMENTOS E VEICULOS DE TRACAO ANIMAL.", "1", "20140101", "" } )
	aAdd( aBody, { "", "6cdda4bf-3c96-47e4-b71c-24631f4532f6", "1019", '"OUTROS BENS MOVEIS, IMOVEIS E EQUIPAMENTOS DA ATIVIDADE RURAL"', "1", "20140101", "" } )
	aAdd( aBody, { "", "75a19d44-2513-b4fe-1ff3-bf89d44a819a", "1020", "POUPANCA PARA AQUISICAO DE BENS MOVEL POR INTERMEDIO DE COMERCIO.", "1", "20140101", "" } )
	aAdd( aBody, { "", "a3e0ddfc-6839-3c60-7625-2ffe67e99b08", "1099", "OUTROS BENS VINCULADOS A ATIVIDADE RURAL.", "1", "20140101", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )