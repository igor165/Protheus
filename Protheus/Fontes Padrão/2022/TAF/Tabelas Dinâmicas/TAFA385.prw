#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA385
Cadastro de Códigos CNC(ECF)

@author Evandro dos Santos Oliveira
@since 06/05/2015
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA385()
Local   oBrw  :=  FWmBrowse():New()

oBrw:SetDescription("Cadastro de Códigos CNC")    //"Cadastro de Códigos CNC"
oBrw:SetAlias( 'CZT')
oBrw:SetMenuDef( 'TAFA385' )
CZT->(DbSetOrder(2))
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
Return XFUNMnuTAF( "TAFA385" ,,,,.T. )
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
Local oStruCZT  :=  FWFormStruct( 1, 'CZT' )
Local oModel    :=  MPFormModel():New( 'TAFA385' )

oModel:AddFields('MODEL_CZT', /*cOwner*/, oStruCZT)
oModel:GetModel('MODEL_CZT'):SetPrimaryKey({'CZT_FILIAL','CZT_ID'})

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
Local   oModel      :=  FWLoadModel( 'TAFA385' )
Local   oStruCZT    :=  FWFormStruct( 2, 'CZT' )
Local   oView       :=  FWFormView():New()


oView:SetModel( oModel )
oView:AddField( 'VIEW_CZT', oStruCZT, 'MODEL_CZT' )

oView:EnableTitleView( 'VIEW_CZT',"Cadastro de Códigos CNC")    //"Cadastro de Códigos CNC"
oView:CreateHorizontalBox( 'FIELDSCZT', 100 )
oView:SetOwnerView( 'VIEW_CZT', 'FIELDSCZT' )

oStruCZT:RemoveField( "CZT_ID" )

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
	aAdd( aHeader, "CZT_FILIAL" )
	aAdd( aHeader, "CZT_ID" )
	aAdd( aHeader, "CZT_CODIGO" )
	aAdd( aHeader, "CZT_DESCRI" )
	aAdd( aHeader, "CZT_DTINI" )
	aAdd( aHeader, "CZT_DTFIN" )

	aAdd( aBody, { "", "69608f85-6c3d-ea84-e975-9dd46c24916b", "35109", "ENCARGOS ACESSORIOS INCIDENTES SOBRE O ENDIVIDAMENTO EXTERNO COMISSOES SOBRE OPERACOES DE EMPRESTIMOS E FINANCIAMENTOS", "20140101", "" } )
	aAdd( aBody, { "", "8afaaa1e-2c39-3e16-3f27-68207123c806", "35123", "ENCARGOS ACESSORIOS INCIDENTES SOBRE O ENDIVIDAMENTO EXTERNO OUTROS", "20140101", "" } )
	aAdd( aBody, { "", "753ad366-96a3-c323-9c49-857e77d2de7a", "35532", "JUROS DE FINANCIAMENTO A EXPORTACAO DE BENS E SERVICOS OUTROS DESCONTOS DE CAMBIAIS", "20140101", "" } )
	aAdd( aBody, { "", "6fff56b9-24f2-11e4-795d-7e21ed18a4a3", "35549", "JUROS DE FINANCIAMENTO A EXPORTACAO DE BENS E SERVICOS OUTROS CREDITOS UTILIZADOS", "20140101", "" } )
	aAdd( aBody, { "", "0e49dd32-928d-ce3c-582b-23e0bf385284", "35556", "JUROS DE PAGAMENTO ANTECIPADO SOBRE EXPORTACOES", "20140101", "" } )
	aAdd( aBody, { "", "515db0a5-ba4a-e36e-d514-2eb1ce591b6b", "35563", "JUROS DE FINANCIAMENTO A EXPORTACAO DE BENS E SERVICOS FINEX DESCONTOS DE CAMBIAIS", "20140101", "" } )
	aAdd( aBody, { "", "67579fc5-4987-c7ae-7e24-47773b3689f4", "35570", "JUROS DE FINANCIAMENTO A EXPORTACAO DE BENS E SERVICOS FINEX CREDITOS UTILIZADOS", "20140101", "" } )
	aAdd( aBody, { "", "3cf12817-02e7-1ca4-d528-c9ca40e92c89", "35587", "JUROS DE FINANCIAMENTO A EXPORTACAO DE BENS E SERVICOS FINEX EQUALIZACAO DE TAXAS", "20140101", "" } )
	aAdd( aBody, { "", "3ca0c83f-50c8-3526-97e7-a464d7fa6252", "35666", "JUROS DE MORA", "20140101", "" } )
	aAdd( aBody, { "", "bbd0ce42-d263-4b8a-e0a3-21e71e220e68", "35673", "JUROS SOBRE CONTAS DE DEPOSITO", "20140101", "" } )
	aAdd( aBody, { "", "68fef01a-01f0-5288-902d-1972f605664b", "35697", "JUROS S/DESCOBERTOS EM CONTA CORRENTE", "20140101", "" } )
	aAdd( aBody, { "", "fecd6f7a-9a37-8223-1424-a6355808e354", "35714", "JUROS DE MORA SOBRE DEPOSITOS SOB A RESOLUCAO 1564 / CIRCULAR 1686", "20140101", "" } )
	aAdd( aBody, { "", "459628cf-e09e-05b0-3f61-d060403699fa", "35738", "JUROS DE TITULOS MOBILIARIOS BRASILEIROS OUTROS", "20140101", "" } )
	aAdd( aBody, { "", "5097ee9c-2830-6d3a-7441-cc3200b60759", "35783", "JUROS DE TITULOS MOBILIARIOS ESTRANGEIROS OUTROS", "20140101", "" } )
	aAdd( aBody, { "", "054529e7-2c8a-1cef-c9b2-9de57a23df0d", "35800", 'JUROS DE TRANSACOES ESPECIAIS "GENERAL ACCOUNT"', "20140101", "" } )
	aAdd( aBody, { "", "5724d199-aa74-69bf-0659-01c97bce8617", "35817", 'JUROS DE TRANSACOES ESPECIAIS "SPECIAL DRAWING ACCOUNT"', "20140101", "" } )
	aAdd( aBody, { "", "f6c29c48-f214-8a44-3651-0fcde9eedd4d", "35824", "JUROS DE TRANSACOES ESPECIAIS OUTRAS", "20140101", "" } )
	aAdd( aBody, { "", "88ea96bd-b2a6-bc66-f5a8-2a1f814e5ec6", "35848", "JUROS DE FINANCIAMENTO A EXPORTACAO DE BENS E SERVICOS PROEX CREDITOS UTILIZADOS", "20140101", "" } )
	aAdd( aBody, { "", "4e00fd64-7412-a9e0-5261-bebc81f5cacc", "35855", "JUROS DE FINANCIAMENTO A EXPORTACAO DE BENS E SERVICOS PROEX DESCONTOS DE CAMBIAIS", "20140101", "" } )
	aAdd( aBody, { "", "f8f1d8c2-ce3a-05d7-1f40-b86f41e9583a", "35862", "JUROS DE FINANCIAMENTO A EXPORTACAO DE BENS E SERVICOS PROEX EQUALIZACAO DE TAXAS", "20140101", "" } )
	aAdd( aBody, { "", "cbcc6a07-8fb7-df0c-5cd9-44d342f41c28", "35879", "JUROS DE FINANCIAMENTO A EXPORTACAO DE BENS E SERVICOS BNDES EXIM", "20140101", "" } )
	aAdd( aBody, { "", "a1028a58-b0fe-a1b3-0f57-e7138f009650", "35886", "JUROS DE FINANCIAMENTO A EXPORTACAO DE BENS E SERVICOS RECURSOS PROPRIOS", "20140101", "" } )
	aAdd( aBody, { "", "4ddeef7b-2ff2-cea1-76b9-2ef4e0db863b", "35903", "JUROS SOBRE ARRENDAMENTOS", "20140101", "" } )
	aAdd( aBody, { "", "0da4a106-0fec-d886-4bd7-514335022139", "35965", "JUROS SOBRE CREDITOS UTILIZADOS OUTROS", "20140101", "" } )
	aAdd( aBody, { "", "1c6c5bee-97f3-12db-b958-77889fb22539", "38508", "OUTROS JUROS CONTRATUAIS (INCLUI MULTAS)", "20140101", "" } )
	aAdd( aBody, { "", "2a9178e9-5fc4-ab70-0881-82e76ac5253d", "38663", "JUROS BANCARIOS", "20140101", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )