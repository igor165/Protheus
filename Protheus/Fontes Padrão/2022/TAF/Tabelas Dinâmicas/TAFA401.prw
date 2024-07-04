#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA401
Cadastro MVC dos Modelos de Documentos Fiscais 
@author Marcos Buschmann
@since 28/09/2015
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA401()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( "Cadastro de Ajuste" )	//"Cadastro de Ajuste"
oBrw:SetAlias( 'T34' )
oBrw:SetMenuDef( 'TAFA401' )

T34->(DbSetOrder(1))

oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Marcos Buschmann
@since 28/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA401" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC
@author Marcos Buschmann
@since 28/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT34 := 	FWFormStruct( 1, 'T34' )
Local oModel 	 := 	MPFormModel():New( 'TAFA401MVC' )

oModel:AddFields('MODEL_T34', /*cOwner*/, oStruT34)
oModel:GetModel('MODEL_T34'):SetPrimaryKey({"T34_CODAJU"})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC
@author Marcos Buschmann
@since 28/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 	:= 	FWLoadModel( 'TAFA401' )
Local 	oStruT34 	:= 	FWFormStruct( 2, 'T34' )
Local 	oView 		:= 	FWFormView():New()

//Remover Campos da tela
oStruT34:RemoveField( 'T34_ID' )

oView:SetModel( oModel )
oView:AddField( 'VIEW_T34', oStruT34, 'MODEL_T34' )

oView:EnableTitleView( 'VIEW_T34', "Cadastro de Ajuste" )	//"Cadastro de Ajuste"
oView:CreateHorizontalBox( 'FIELDST34', 100 )
oView:SetOwnerView( 'VIEW_T34', 'FIELDST34' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Marcos Buschmann
@Since		09/12/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody		:=	{}
Local aRet		:=	{}

nVerAtu := 1007

If nVerEmp < nVerAtu
	aAdd( aHeader, "T34_FILIAL" )
	aAdd( aHeader, "T34_ID" )
	aAdd( aHeader, "T34_CODAJU" )
	aAdd( aHeader, "T34_DESCRI" )
	aAdd( aHeader, "T34_TIPREG" )
	aAdd( aHeader, "T34_VALIDA" )

	aAdd( aBody, { "", "23a1dff3-03b5-b887-22a4-3f20459a1c93", "7" , "Operações relativas ao ativo imobilizado                                                          ", "1", "" } )
	aAdd( aBody, { "", "4e5a491a-1bb3-ecd5-5d4c-957fcf4d2cb1", "8" , "Operações relativas ao uso ou consumo                                                             ", "1", "" } )
	aAdd( aBody, { "", "3e42c034-ea81-fc4f-1ccc-21d2d09ec46f", "10", "IPI nas entradas de matéria prima                                                                 ", "1", "" } )
	aAdd( aBody, { "", "a648fae4-a509-fc3d-8f9e-233d64e5da6e", "36", "Operações/prestações que não são FG do ICMS ou não utilizadas no VA de mercadorias (especificadas)", "1", "" } )
	aAdd( aBody, { "", "0306ad23-6bb9-96cf-8050-260a9e06ed77", "25", "ICMS retido por substituição tributária                                                           ", "1", "" } )
	aAdd( aBody, { "", "67c65bb6-1d3d-92c6-2ef2-ed04ad5d3bed", "2" , "Operações relativas ao ativo imobilizado                                                          ", "1", "" } )
	aAdd( aBody, { "", "8693e391-eab9-9059-6d65-b11d1bfdcf74", "3" , "Operações relativas ao uso ou consumo                                                             ", "1", "" } )
	aAdd( aBody, { "", "2bbce40d-505a-8cc5-b08f-264c2def3605", "5" , "IPI que não integra a base de cálculo de ICMS                                                     ", "1", "" } )
	aAdd( aBody, { "", "78fd9f94-23c6-d41d-cba1-d87ef4d5e86c", "29", "IPI que integra a base de cálculo de ICMS                                                         ", "1", "" } )
	aAdd( aBody, { "", "22f7359d-498e-13b8-bb66-70756253f6c3", "37", "Operações/prestações que não são FG do ICMS ou não utilizadas no VA de mercadorias (especificadas)", "1", "" } )
	aAdd( aBody, { "", "b73f2f63-560a-458e-5dcf-d940f4254eed", "24", "ICMS retido por substituição tributária                                                           ", "1", "" } )
	aAdd( aBody, { "", "22336335-e23c-b648-6d82-83f5b1f678b9", "13", "Estoque inicial                                                                                   ", "1", "" } )
	aAdd( aBody, { "", "5d2fbc24-4b2a-dd40-b675-1352b1970358", "14", "Estoque final                                                                                     ", "1", "" } )
	aAdd( aBody, { "", "d64a632c-4925-a656-f96d-b82f43650b24", "31", "Importações destinadas à industrialização ou comercialização                                      ", "1", "" } )
	aAdd( aBody, { "", "e6545f5f-6846-5418-146c-b5b47292691f", "40", "Compras e Aquisições de Serviços do ICMS                                                          ", "2", "" } )
	aAdd( aBody, { "", "dd53b923-3227-ff0c-0c81-2b0cf9d4f81e", "41", "Transferências                                                                                    ", "2", "" } )
	aAdd( aBody, { "", "9f720912-0e99-fcc1-b748-6dc68ad20b76", "42", "Devoluções de Vendas                                                                              ", "2", "" } )
	aAdd( aBody, { "", "2b7f4610-0b71-3fab-2aee-48bcc7e1c32e", "44", "Vendas e Prestações de Serviços do ICMS                                                           ", "2", "" } )
	aAdd( aBody, { "", "b66b0a51-4ea0-deea-50a6-39209f1b41b2", "45", "Transferências                                                                                    ", "2", "" } )
	aAdd( aBody, { "", "ca541910-1bf0-f993-ed80-b86b48f348bd", "46", "Devoluções de Compras                                                                             ", "2", "" } )
	aAdd( aBody, { "", "1c2204f0-fbf9-807c-17d0-b1f1be919cae", "48", "Estoque inicial                                                                                   ", "2", "" } )
	aAdd( aBody, { "", "e36f2e8a-a9b1-d921-f8d5-a505bcc2f9bb", "49", "Estoque final                                                                                     ", "2", "" } )
	aAdd( aBody, { "", "67f49cb1-5af1-51f5-bcf1-050093704136", "51", "Importações destinadas à industrialização ou comercialização                                      ", "2", "" } )
	aAdd( aBody, { "", "eb14fe33-0508-6626-d294-92e477622e2e", "52", "Outros Ajustes de Vendas para apuração da Receita Bruta das operações do ICMS                     ", "2", "" } )
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
