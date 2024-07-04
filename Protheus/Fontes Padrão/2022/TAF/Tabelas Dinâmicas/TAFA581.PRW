#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
//#INCLUDE "TAFA581.CH" 

/*--------------------------------------------------------------------------
{Protheus.doc} TAFA581
Cadastro MVC de Tipos de Ajuste de Preços de Importação e Exportação da ECF.

@author Carlos Eduardo N. da Silva
@since 20/04/2021
@version 1.0
---------------------------------------------------------------------------*/
Function TAFA581()
Local lRet := .t.
Local oBrowse :=  FWmBrowse():New()

oBrowse:SetDescription('Tipos de Ajuste de Preços de Exportação(X305) e Importação(X325) da ECF')
oBrowse:SetAlias('V6T')
oBrowse:SetMenuDef('TAFA581')
V6T->(DbSetOrder(1))
oBrowse:Activate()

return lRet

/*-------------------------------------------------------------------
{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Carlos Eduardo N. da Silva
@since 20/04/2021
@version 1.0
-------------------------------------------------------------------*/
Static Function MenuDef()
return XFUNMnuTAF('TAFA581',,,,.t.)

/*-------------------------------------------------------------------
{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Carlos Eduardo N. da Silva
@since 20/04/2021
@version 1.0
-------------------------------------------------------------------*/
Static Function ModelDef()
Local oStruV6T :=  FWFormStruct( 1, 'V6T' )
Local oModel   :=  MPFormModel():New( 'TAFA581' )

oModel:AddFields('MODEL_V6T', /*cOwner*/, oStruV6T)
oModel:GetModel('MODEL_V6T'):SetPrimaryKey({'V6T_FILIAL','V6T_ID'})

return oModel

/*-------------------------------------------------------------------
{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Carlos Eduardo N. da Silva
@since 20/04/2021
@version 1.0
--------------------------------------------------------------------*/
Static Function ViewDef()
Local oModel    :=  FWLoadModel( 'TAFA581' )
Local oStruV6T  :=  FWFormStruct( 2, 'V6T' )
Local oView     :=  FWFormView():New()
 
oStruV6T:RemoveField('V6T_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_V6T', oStruV6T, 'MODEL_V6T' )

oView:EnableTitleView( 'VIEW_V6T' ) 
oView:CreateHorizontalBox( 'FIELDSV6T', 100 )
oView:SetOwnerView( 'VIEW_V6T', 'FIELDSV6T' )

Return oView 

/*-------------------------------------------------------------------
{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Carlos Eduardo N. da Silva
@Since		20/04/2021
@Version	1.0
--------------------------------------------------------------------*/
Static Function FAtuCont( nVerEmp, nVerAtu )
Local aRet		:=	{}
Local aHeader   :=	{}
Local aBody	    :=	{}

nVerAtu :=  1031
	
If nVerEmp < nVerAtu 
	aAdd( aHeader, "V6T_FILIAL" )
	aAdd( aHeader, "V6T_ID" )
	aAdd( aHeader, "V6T_REGECF" )
	aAdd( aHeader, "V6T_CODTPA" )
	aAdd( aHeader, "V6T_DESCTA" )

	//Exportação X305
	aAdd( aBody, { '','df694217-663a-bf22-5b92-896d5b93985b', 'X305', '01', 'Prêmio (art. 34, §7º) ' } )
	aAdd( aBody, { '','6432ef6e-7519-8c9c-7a9e-19559a004d3e', 'X305', '02', 'Prazo para pagamento (art. 34, §10, I) ' } )
	aAdd( aBody, { '','1ce87b67-ca99-49db-5d74-8ed342b10b1e', 'X305', '03', 'Quantidades negociadas (art. 34, §10, II) ' } )
	aAdd( aBody, { '','7f69da00-8a5c-4589-8ca3-653d85576270', 'X305', '04', 'Influências climáticas nas características do bem exportado (art. 34, §10, III) ' } )
	aAdd( aBody, { '','a8be854d-6186-3283-08e9-e861d2dae953', 'X305', '05', 'Custos de intermediação (art. 34, §10, IV) ' } )
	aAdd( aBody, { '','51f3cfd7-8b68-c880-1ce2-18f0e254c87a', 'X305', '06', 'Acondicionamento (art. 34, §10, V) ' } )
	aAdd( aBody, { '','ca38c4dc-3699-a61a-cdb3-173f758950d2', 'X305', '07', 'Frete e seguro (art. 34, §10, VI) ' } )
	aAdd( aBody, { '','035ec9ed-4f6a-5f1d-1fe3-7d4cb97ede81', 'X305', '08', 'Custos de desembarque no porto, de transporte interno, de armazenagem e de desembaraço aduaneiro, incluídos impostos e taxas incidentes na importação (art. 34, §10, VII) ' } )
	aAdd( aBody, { '','125104e8-3b8b-7984-b83e-2d60283adf06', 'X305', '09', 'Prazo para pagamento (art. 22, §1º, I) ' } )
	aAdd( aBody, { '','502cd323-7070-1894-fe85-bc1ca88e7ad2', 'X305', '10', 'Quantidades negociadas (art. 22, §1º, II) ' } )
	aAdd( aBody, { '','3cca8c55-28ba-cd6a-8901-9f830a16ed63', 'X305', '11', 'Garantia de funcionamento do bem ou da aplicabilidade do serviço ou direito (art. 22, §1º, III) ' } )
	aAdd( aBody, { '','16826394-1b95-2b0a-795e-183495a2be95', 'X305', '12', 'Promoção do bem, serviço ou direito (art. 22, §1º, IV) ' } )
	aAdd( aBody, { '','270a51de-25c4-4f6a-aec5-1cb9954a2a90', 'X305', '13', 'Custos de fiscalização de qualidade, de padrão dos serviços e das condições de higiene (art. 22, §1º, V) ' } )
	aAdd( aBody, { '','00ee3c83-5da3-2b3a-ec09-ff5c7f67d38e', 'X305', '14', 'Custos de intermediação (art. 22, §1º, VI) ' } )
	aAdd( aBody, { '','339bd075-8068-ce08-9f7c-c436f0a67fb7', 'X305', '15', 'Acondicionamento (art. 22, §1º, VII) ' } )
	aAdd( aBody, { '','518913a9-846b-7de6-6a02-86e107b4d26b', 'X305', '16', 'Frete e seguro (art. 22, §1º, VIII) ' } )
	aAdd( aBody, { '','1b7b76a9-aab5-97e3-8812-c6fb9d5dabe7', 'X305', '17', 'Riscos de crédito (art. 22, §1º, IX) ' } )
	aAdd( aBody, { '','a5663d48-ea56-be11-654d-7ab36360c475', 'X305', '18', 'Custos de desembarque no porto, de transporte interno, de armazenagem e de desembaraço aduaneiro, incluídos impostos e taxas incidentes na importação (art. 22, §1º, X) ' } )
	aAdd( aBody, { '','75be680d-5597-6f91-7400-b39e938544eb', 'X305', '19', 'Similaridade (art. 24) ' } )
	aAdd( aBody, { '','d6718ab3-f3d5-e40a-5fd5-ee0a82aa95bf', 'X305', '20', 'Variação cambial (art. 25)' } )
	aAdd( aBody, { '','5a73799b-f7af-8528-5a5c-a8a9a7721c53', 'X305', '99', 'Outros ajustes - essa opção deve ser utilizada apenas em caso de alteração da Instrução Normativa RFB nº 1.312/2012 com previsão de ajustes não contemplados nos códigos anteriores' } )

	//Importação X325 
	aAdd( aBody, { '','32d946da-da30-799f-b038-9d0d7d84f72a', 'X325', '01', 'Prêmio (art. 16, §6º) ' } )
	aAdd( aBody, { '','db20aa11-1bf2-62db-9966-ed795ff9b632', 'X325', '02', 'Prazo para pagamento (art. 16, §9º, I) ' } )
	aAdd( aBody, { '','45f57518-7768-3ca0-8671-328bf77e50ff', 'X325', '03', 'Quantidades negociadas (art. 16, §9º, II) ' } )
	aAdd( aBody, { '','6d788030-94ec-60cf-c7bf-f16a41a3e5a3', 'X325', '04', 'Influências climáticas nas características do bem exportado (art. 16, §9º, III) ' } )
	aAdd( aBody, { '','234632c1-2f8a-e283-b2f3-afed01f2697a', 'X325', '05', 'Custos de intermediação (art. 16, §9º, IV) ' } )
	aAdd( aBody, { '','c86ab4fc-8dea-e7a9-9ed9-736491ca222a', 'X325', '06', 'Acondicionamento (art. 16, §9º, V) ' } )
	aAdd( aBody, { '','29a4ee9e-6c6c-0b05-485b-ebc19b7d1977', 'X325', '07', 'Frete e seguro (art. 16, §9º, VI) ' } )
	aAdd( aBody, { '','fcde9893-80e2-5760-5501-96311aa7fd8e', 'X325', '08', 'Custos de desembarque no porto, de transporte interno, de armazenagem e de desembaraço aduaneiro, incluídos impostos e taxas incidentes na importação (art. 16, §9º, VII) ' } )
	aAdd( aBody, { '','b3e64ef5-9bc4-d0d1-c561-309da21f55f7', 'X325', '09', 'Prazo para pagamento (art. 9, §1º, I) ' } )
	aAdd( aBody, { '','6a133d8f-6df6-e3c2-9d65-74b28c73275c', 'X325', '10', 'Quantidades negociadas (art. 9, §1º, II) ' } )
	aAdd( aBody, { '','a9ce6588-e8f4-c159-744b-3238eea3d01a', 'X325', '11', 'Garantia de funcionamento do bem ou da aplicabilidade do serviço ou direito (art. 9, §1º, III) ' } )
	aAdd( aBody, { '','c793a066-7c6a-e225-9319-95524c97b1de', 'X325', '12', 'Promoção do bem, serviço ou direito (art. 9, §1º, IV) ' } )
	aAdd( aBody, { '','b5a00e3f-8281-1910-ed9d-fc3c581b205d', 'X325', '13', 'Custos de fiscalização de qualidade, de padrão dos serviços e das condições de higiene (art. 9, §1º, V) ' } )
	aAdd( aBody, { '','fd455f05-58f1-386a-e839-26dd826ab5a3', 'X325', '14', 'Custos de intermediação (art. 9, §1º, VI) ' } )
	aAdd( aBody, { '','a0ed57e4-2f26-d5b6-1e86-e86c5e21de5a', 'X325', '15', 'Acondicionamento (art. 9, §1º, VII) ' } )
	aAdd( aBody, { '','9b314c2c-15d1-24e9-8bea-be4cd3afa2da', 'X325', '16', 'Frete e seguro (art. 9, §1º, VIII) ' } )
	aAdd( aBody, { '','7b2d3820-141d-2a6c-edd5-5d8a141d1862', 'X325', '17', 'Custos de desembarque no porto, de transporte interno, de armazenagem e de desembaraço aduaneiro, incluídos impostos e taxas incidentes na importação (art. 9, §1º, IX) ' } )
	aAdd( aBody, { '','9a1b663e-4eaa-346b-4224-e4a04fdf13c7', 'X325', '18', 'Similaridade (art. 10) ' } )
	aAdd( aBody, { '','470dcb6a-5e42-d064-2259-d12a4e461c10', 'X325', '19', 'Variação cambial (art. 24) ' } )
	aAdd( aBody, { '','4ff3d299-cef8-3b54-ad1e-2eeb2fa10c02', 'X325', '20', 'Variação cambial (art. 11, §1º ou art. 15, §7º) ' } )
	aAdd( aBody, { '','5b343927-4b07-c5c8-e89a-585974d3c7f5', 'X325', '99', 'Outros ajustes - essa opção deve ser utilizada apenas em caso de alteração da Instrução Normativa RFB nº 1.312/2012 com previsão de ajustes não contemplados nos códigos anteriore' } )	

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
