#INCLUDE "OGA720.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI

/** {Protheus.doc} OGA720
Rotina para cadastro de negociadores e lideres de mesa de operação de trader.

@param: 	Nil
@author: 	Marcelo Ferrari
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA720()
	Local oMBrowse 	:= Nil

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N8C" )
	oMBrowse:SetDescription( STR0001 ) //"Bolsa de Referência"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return( Nil )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA720 - Safra
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002, 'PesqBrw'       , 0, 1, 0, .T. } ) //'Pesquisar'
	aAdd( aRotina, { STR0003, 'ViewDef.OGA720', 0, 2, 0, Nil } ) //'Visualizar'
	aAdd( aRotina, { STR0004, 'ViewDef.OGA720', 0, 3, 0, Nil } ) //'Incluir'
	aAdd( aRotina, { STR0005, 'ViewDef.OGA720', 0, 4, 0, Nil } ) //'Alterar'
	aAdd( aRotina, { STR0006, 'ViewDef.OGA720', 0, 5, 0, Nil } ) //'Excluir'
	aAdd( aRotina, { STR0007, 'ViewDef.OGA720', 0, 8, 0, Nil } ) //'Imprimir'
	aAdd( aRotina, { STR0010, 'OGA720AIB()'	  , 0, 9, 0, Nil } ) //'Atualizar Indices Bolsa'

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA720 - Safra
*/
Static Function ModelDef()
	Local oStruN8C := FWFormStruct( 1, "N8C" )
	Local oStruN8U := FWFormStruct( 1, "N8U" )
	Local oModel   := MPFormModel():New( "OGA720" )

	oStruN8C:AddTrigger( "N8C_CODUSU", "N8C_NOMUSU", { || .t. }, { | x | fTrgNomUsu( x ) } )
	oStruN8C:AddTrigger( "N8C_GRPUSU", "N8C_DGRUSU", { || .t. }, { | x | fTrgNomGrp( x ) } )
	
	oModel:AddFields( "N8CUNICO", Nil, oStruN8C )
	oModel:SetDescription( STR0001 ) //"Bolsa de Referência"
	oModel:GetModel( "N8CUNICO" ):SetDescription( STR0008 ) //"Bolsa de Referêcia"
	
	//Cria o grid e pega o modelo  
	oModel:AddGrid( "N8UUNICO", "N8CUNICO", oStruN8U )
	oModel:GetModel('N8UUNICO'):SetDescription( STR0009 ) //"Indices de commodity"
	
	//Atribui um relacionamento de Pai X Filho
	oModel:SetRelation( 'N8UUNICO', {{'N8U_FILIAL', 'N8C_FILIAL'},{ 'N8U_CODBOL', 'N8C_CODIGO' }}, N8U ->(IndexKey( 1 ) ) )
	
	//Não Obriga a informar os dados da grid
	oModel:GetModel( "N8UUNICO" ):SetOptional( .T. )	
	//Define a chave unica do modelo
	oModel:GetModel( "N8UUNICO" ):SetUniqueLine( { "N8U_CODP2","N8U_CODPRO" } ) 

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA720 - Safra
*/
Static Function ViewDef()
	Local oStruN8C := FWFormStruct( 2, "N8C" )
	Local oStruN8U := FWFormStruct( 2, "N8U", {|cCampo|!(Alltrim(cCampo) $ "N8U_CODBOL")} ) 
	Local oModel   := FWLoadModel( "OGA720" )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( "VIEW_N8C", oStruN8C, "N8CUNICO" )
	//Adiciona ao view um formulário do tipo FWFormGrid
	oView:AddGrid( "VIEW_N8U", oStruN8U, "N8UUNICO" )
	
	//oView:CreateHorizontalBox( "UM"  , 100 )
	//Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "SUPERIOR", 50 )
	oView:CreateHorizontalBox( "INFERIOR", 50 )
	
	//Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( "VIEW_N8C", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_N8U", "INFERIOR" )
	
	//Cria um título para um formulário
	oView:EnableTitleView( "VIEW_N8C" )
	oView:EnableTitleView( "VIEW_N8U" )
	
	oView:AddIncrementField( "VIEW_N8U", "N8U_ITEM" )

	oView:SetCloseOnOk( {||.t.} )

Return( oView )

/*/{Protheus.doc} OGA720AIB
Realiza a atualização dos indices da bolsa de referencia posicionada.
Chamando a função de integração com a API externa.

@author claudineia.reinert
@since 05/06/2018
@version P12
@type function
/*/
Function OGA720AIB()
	
	MsAguarde( {|| lRet := OGX300D(N8C->N8C_CODIGO) },STR0011,STR0012 )//"Aguarde" #"Atualizando indices da bolsa de referência... " 
	
Return .T.

/*/{Protheus.doc} OG720VFIND
//TODO Valida a formatação informada para o campo N8U_FORIND
@author claudineia.reinert
@since 28/06/2018
@version undefined

@type function
/*/
Function OG720VFIND()
	Local lRet := .T.
	Local oModel    := FwModelActive()
	Local oModelN8U := oModel:GetModel( "N8UUNICO" )
	Local cFormat	:= AllTrim(oModelN8U:GetValue("N8U_FORIND"))
	local aFormat	:= {}
	Local aPos		:= {} 
	Local nX		:= 0
	Local cAnt		:= ""
	
	//verifica cada caracter para validar se é valido, permitindo apenas numeros de 0-9, virgula e hifen
	For nX = 1 to Len(cFormat)
		If .not.( AllTrim(SUBSTR(cFormat, nX, 1)) $ "0|1|2|3|4|5|6|7|8|9|,|-" ) //caracters validos
			lRet := .F.
			Exit
		ElseIf ( AllTrim(SUBSTR(cFormat, nX, 1)) $ ",|-" .AND. cAnt $ ",|-" ) ;
		        .OR. ( nX = 1 .AND. AllTrim(SUBSTR(cFormat, nX, 1)) $ ",|-" ) ;
		        .OR. ( nX = Len(cFormat) .AND. AllTrim(SUBSTR(cFormat, nX, 1)) $ ",|-" )
			//não deixar digitar hifen(--), virgulas(,,) ou hifen e virgula(-,) vice-versa sequencialmente, ou no inicio ou fim
			lRet := .F.
			Exit
		EndIf
		cAnt := AllTrim(SUBSTR(cFormat, nX, 1))
	Next nX
	
	If lRet
		aFormat	:= StrTokArr( AllTrim(cFormat), "," ) //quebra em um array
		If Len(aFormat) = 0 //quebrou pela virguila mas não tem valor
			lRet := .F. 
		EndIf
		For nX = 1 to Len(aFormat)
			If AT("-",aFormat[nX]) //procura pelo hifen na cadeia de String
				aPos := StrTokArr( aFormat[nX], "-" ) //quebra em um array
				If Len(aPos) <= 1 .OR. VAL(AllTrim(aPos[1])) = 0 .OR. VAL(AllTrim(aPos[2])) = 0 .OR. Len(aPos)> 2  //valida se consegue converter para numero, ambos precisam ser numeros e maior que zero
					lRet := .F.
					Exit
				EndIf
			ElseIf VAL(AllTrim(aFormat[nX])) = 0
				lRet := .F.
				Exit
			EndIf
		Next nX	
	EndIf
	
	If .not. lRet
		Help('',1,".OGA720000001.") //###Formatação invalida, use apenas numeros(0-9), vírgula(,) e hífen(-).
	EndIf

Return lRet

/*/{Protheus.doc} fTrgNomUsu( x )
Gatilho para retornar o nome do usuario
@type  Function
@author rafael.kleestadt
@since 14/11/2018
@version 1.0
@param oParModel, object, objeto do modelo
@return cNomUser, caracter, nome completo do usuário
@example
(examples)
@see (links_or_references)
/*/
Static Function fTrgNomUsu( oParModel )
	Local oModel   := oParModel:GetModel()
	Local oN8C	   := oModel:GetModel( "N8CUNICO" )
	Local cNomUser := ""

	cNomUser := UsrFullName( oN8C:GetValue( "N8C_CODUSU" ) )

Return cNomUser

/*/{Protheus.doc} fTrgNomGrp( x )
Gatilho para retornar o nome do grupo de usuario
@type  Function
@author rafael.kleestadt
@since 14/11/2018
@version 1.0
@param oParModel, object, objeto do modelo
@return cNomGrp, caracter, nome completo do grupo de usuário
@example
(examples)
@see (links_or_references)
/*/
Static Function fTrgNomGrp( oParModel )
	Local oModel  := oParModel:GetModel()
	Local oN8C	  := oModel:GetModel( "N8CUNICO" )
	Local cNomGrp := ""

	cNomGrp := IIf(!Empty(oN8C:GetValue( "N8C_GRPUSU" )),GrpRetName( oN8C:GetValue( "N8C_GRPUSU" ) ),"")

Return cNomGrp