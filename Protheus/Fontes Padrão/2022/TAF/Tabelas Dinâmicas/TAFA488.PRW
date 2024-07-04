#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA488.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA488
Cadastro MVC de Tipos de Arquivo da Reinf 

@author Henrique Pereira
@since 19/01/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA488()
Local oBrw	as object

If TAFAlsInDic( "T9B" )
	oBrw := FWmBrowse():New() 
	oBrw:SetDescription( STR0001 ) //Cadastro de Tipos de Arquivo da Reinf 	
	oBrw:SetAlias( 'T9B')
	oBrw:SetMenuDef( 'TAFA488' )
	oBrw:Activate()
Else
	MsgInfo( STR0003 , STR0002 ) // "Não é possível proceder com a execução da Rotina, necessário atualização de dicionário referente ao layout do 1.3 do Reinf" / Tabela T9B não existe!
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Henrique Pereira
@since 19/01/2018
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA488" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Henrique Pereira
@since 19/01/2018
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruT9B as object
Local oModel   as object

oStruT9B := FWFormStruct( 1, 'T9B' )// Cria a estrutura a ser usada no Modelo de Dados
oModel   := MPFormModel():New('TAFA488' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_T9B', /*cOwner*/, oStruT9B)
oModel:GetModel( 'MODEL_T9B' ):SetPrimaryKey( { 'T9B_FILIAL' , 'T9B_ID' } )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Henrique Pereira
@since 19/01/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		as object
Local oStruT9B		as object
Local oView			as object

oModel		:= FWLoadModel( 'TAFA488' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
oStruT9B	:= FWFormStruct( 2, 'T9B' )// Cria a estrutura a ser usada na View
oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_T9B', oStruT9B, 'MODEL_T9B' )

oView:EnableTitleView( 'VIEW_T9B',  STR0001 ) //Cadastro de Tipos de Arquivo da Reinf 	

oView:CreateHorizontalBox( 'FIELDST9B', 100 )

oView:SetOwnerView( 'VIEW_T9B', 'FIELDST9B' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Henrique Pereira
@Since		19/01/2018
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	as array
Local aBody		as array
Local aRet		as array

aHeader	:=	{}
aBody	:=	{}
aRet	:=	{}

nVerAtu := 1031.27

If (nVerEmp < nVerAtu) .AND. TAFAlsInDic( "T9B" ) //TafAtualizado()
	aAdd( aHeader, "T9B_FILIAL" )
	aAdd( aHeader, "T9B_ID" )
	aAdd( aHeader, "T9B_CODIGO" )
	aAdd( aHeader, "T9B_DESCRI" )
	aAdd( aHeader, "T9B_VALIDA" )

	aAdd( aBody, { "", "75651686-1fea-ed98-d956-e18df9f8ee62", "R-1000", "INFORMAÇÕES DO CONTRIBUINTE", "" } )
	aAdd( aBody, { "", "78072418-024a-431e-a2fa-e96a8d6fb605", "R-1070", "TABELA DE PROCESSOS ADMINISTRATIVOS/JUDICIAIS", "" } )
	aAdd( aBody, { "", "1f300ff7-f429-9ec0-e2d3-e49b22b03bd1", "R-2010", "RETENÇÃO CONTRIBUIÇÃO PREVIDENCIÁRIA - SERVIÇOS TOMADOS", "" } )
	aAdd( aBody, { "", "8b87a50d-c51a-81b0-2e57-a2f7dee63d49", "R-2020", "RETENÇÃO CONTRIBUIÇÃO PREVIDENCIÁRIA - SERVIÇOS PRESTADOS", "" } )
	aAdd( aBody, { "", "e972a02e-2762-655c-f69a-009680412edd", "R-2030", "RECURSOS RECEBIDOS POR ASSOCIAÇÃO DESPORTIVA", "" } )
	aAdd( aBody, { "", "66646f64-2bca-4b68-5584-4d6377959bcf", "R-2040", "RECURSOS REPASSADOS PARA ASSOCIAÇÃO DESPORTIVA", "" } )
	aAdd( aBody, { "", "b54f134a-2a3f-e383-9ecc-f2d8fedf97de", "R-2050", "COMERCIALIZAÇÃO DA PRODUÇÃO POR PRODUTOR RURAL PJ/AGROINDÚSTRIA", "" } )
	aAdd( aBody, { "", "b871fcc1-0154-cb28-955f-d39f281ce398", "R-2055", "AQUISIÇÃO DE PRODUÇÃO RURAL", "" } )
	aAdd( aBody, { "", "d3f7e028-47e0-a37a-7402-565b52687367", "R-2060", "CONTRIBUIÇÃO PREVIDENCIÁRIA SOBRE A RECEITA BRUTA - CPRB", "" } )
	aAdd( aBody, { "", "8013fef7-4216-330d-2985-6518618d9cb3", "R-2070", "RETENÇÕES NA FONTE - IR, CSLL, COFINS, PIS/PASEP", "" } )
	aAdd( aBody, { "", "ba59be28-0869-6a4c-1799-4c528f551886", "R-2098", "REABERTURA DOS EVENTOS PERIÓDICOS", "" } )
	aAdd( aBody, { "", "63b3604b-b02a-3610-2afb-08ac76e9a871", "R-2099", "FECHAMENTO DOS EVENTOS PERIÓDICOS", "" } )
	aAdd( aBody, { "", "a33daec4-9893-14d2-2eba-cae645765c87", "R-3010", "RECEITA DE ESPETÁCULO DESPORTIVO", "" } )
	aAdd( aBody, { "", "1bbd2102-d557-dc5b-b79f-19f761413c7f", "R-5001", "INFORMAÇÕES DE BASES E TRIBUTOS POR EVENTO", "" } )
	aAdd( aBody, { "", "47235594-823f-e6e9-60c3-24285e28cd48", "R-5011", "INFORMAÇÕES DE BASES E TRIBUTOS CONSOLIDADAS POR PERÍODO DE APURAÇÃO", "" } )
	aAdd( aBody, { "", "30e1df5a-ca6a-6b50-5ccc-4acfed513b49", "R-9000", "EXCLUSÃO DE EVENTOS", "" } )	
		
	aAdd( aRet, { aHeader, aBody } )

EndIf

Return( aRet )
