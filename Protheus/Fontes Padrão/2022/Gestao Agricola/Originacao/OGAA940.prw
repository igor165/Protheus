#INCLUDE "OGAA940.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} OGAA940()
Rotina para cadastro de Tabela de Qualidade Destino
@type  Function
@author tamyris.g
@since 04/10/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function OGAA940()
Local   oMBrowse

//Proteç?o
If !TableInDic('NL8')
	Help( , , STR0011, , STR0013, 1, 0 ) //"Atenç?o" //"Para acessar esta funcionalidade é necessario atualizar o dicionario do Protheus."
	Return(Nil)
EndIf 

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NL8" )
oMBrowse:SetDescription( STR0001 ) //"Tabela de Qualidade Destino"
oMBrowse:Activate()

Return()

/*/{Protheus.doc} MenuDef()
Função que retorna os itens para construção do menu da rotina
@type  Function
@author tamyris.g
@since 04/10/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, 'PesqBrw'        , 0, 1, 0, .T. } ) //'Pesquisar'
aAdd( aRotina, { STR0003, 'ViewDef.OGAA940', 0, 2, 0, Nil } ) //'Visualizar'
aAdd( aRotina, { STR0004, 'ViewDef.OGAA940', 0, 3, 0, Nil } ) //'Incluir'
aAdd( aRotina, { STR0005, 'ViewDef.OGAA940', 0, 4, 0, Nil } ) //'Alterar'
aAdd( aRotina, { STR0006, 'ViewDef.OGAA940', 0, 5, 0, Nil } ) //'Excluir'
aAdd( aRotina, { STR0007, 'ViewDef.OGAA940', 0, 8, 0, Nil } ) //'Imprimir'

Return aRotina

/*/{Protheus.doc} ModelDef()
Função que retorna o modelo padrao para a rotina
@type  Function
@author tamyris.g
@since 04/10/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oStruNL8 := FWFormStruct( 1, "NL8" )
Local oStruNL9 := FWFormStruct( 1, "NL9" )
Local oStruNLA := FWFormStruct( 1, "NLA" )
Local oStruNLC := FWFormStruct( 1, "NLC" )
Local oModel   := MPFormModel():New( "OGAA940",  , , )

oStruNLA:SetProperty( "NLA_CODUNS" , MODEL_FIELD_WHEN , {|| fWhenNLA('1')  })
oStruNLA:SetProperty( "NLA_VALINI" , MODEL_FIELD_WHEN , {|| fWhenNLA('2')  })
oStruNLA:SetProperty( "NLA_VALFIM" , MODEL_FIELD_WHEN , {|| fWhenNLA('2')  })
oStruNL9:SetProperty( "NL9_TIPO"   , MODEL_FIELD_VALID, {|| fLoadGrd()	   })
oStruNLC:SetProperty( "NLC_DESMOE" , MODEL_FIELD_INIT , {|| fIniDesMoe()   })

oModel:AddFields( 'NL8UNICO', Nil, oStruNL8 )
oModel:SetDescription( STR0001 ) //"Tabela de Qualidade Destino"
oModel:GetModel( 'NL8UNICO' ):SetDescription( STR0001 ) //"Tabela de Qualidade Destino"
	
oModel:AddGrid(  "NL9UNICO", "NL8UNICO", oStruNL9,,,,, )
oModel:GetModel( "NL9UNICO" ):SetDescription( STR0008 ) //"Tipos de Análise Destino"
oModel:GetModel( "NL9UNICO" ):SetUniqueLine( { "NL9_CODTAB", "NL9_CODTIP" } )
oModel:GetModel( "NL9UNICO" ):SetOptional( .t. )
oModel:SetRelation( "NL9UNICO", { { "NL9_FILIAL", "xFilial( 'NL9' )" }, { "NL9_CODTAB", "NL8_CODIGO" } }, NL9->( IndexKey( 1 ) ) )

oModel:AddGrid(  "NLAUNICO", "NL9UNICO", oStruNLA,, { | oGrid | PosGride( oGrid )},,, )
oModel:GetModel( "NLAUNICO" ):SetDescription( STR0009 ) //"Faixas de Resultado de Análise"
oModel:GetModel( "NLAUNICO" ):SetUniqueLine( { "NLA_CODTAB", "NLA_CODTIP","NLA_SEQTIP" } )
oModel:GetModel( "NLAUNICO" ):SetOptional( .t. )
oModel:SetRelation( "NLAUNICO", { { "NLA_FILIAL", "xFilial( 'NLA' )" }, { "NLA_CODTAB", "NL9_CODTAB" },  { "NLA_CODTIP", "NL9_CODTIP" }  }, NLA->( IndexKey( 1 ) ) )

oModel:AddGrid(  "NLCUNICO", "NL9UNICO", oStruNLC,,,,, )
oModel:GetModel( "NLCUNICO" ):SetDescription( STR0010 ) //"Taxas"
oModel:GetModel( "NLCUNICO" ):SetUniqueLine( { "NLC_CODTAB", "NLC_CODTIP", "NLC_CODTAX" } )
oModel:GetModel( "NLCUNICO" ):SetOptional( .t. )
oModel:SetRelation( "NLCUNICO", { { "NLC_FILIAL", "xFilial( 'NLC' )" }, { "NLC_CODTAB", "NL9_CODTAB" }, { "NLC_CODTIP", "NL9_CODTIP" }  }, NLC->( IndexKey( 1 ) ) )

oModel:SetActivate(   { | oModel | fIniModelo(oModel) } )

Return oModel

/*/{Protheus.doc} ViewDef()
Função que retorna a view para o modelo padrao da rotina
@type  Function
@author tamyris.g
@since 04/10/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oStruNL8	:= FWFormStruct( 2, "NL8" )
Local oStruNL9	:= FWFormStruct( 2, "NL9" )
Local oStruNLA	:= FWFormStruct( 2, "NLA" )
Local oStruNLC	:= FWFormStruct( 2, "NLC" )
Local oModel	:= FWLoadModel( "OGAA940" )
Local oView		:= FWFormView():New()

oStruNL9:RemoveField( "NL9_CODTAB" )
oStruNLA:RemoveField( "NLA_CODTAB" )
oStruNLA:RemoveField( "NLA_CODTIP" )
oStruNLC:RemoveField( "NLC_CODTAB" )
oStruNLC:RemoveField( "NLC_CODTIP" )
oStruNLC:RemoveField( "NLC_DESTIP" )

oView:SetModel( oModel )
oView:AddField( "VIEW_NL8", oStruNL8, "NL8UNICO" )
oView:AddGrid(  "VIEW_NL9", oStruNL9, "NL9UNICO" )
oView:AddGrid(  "VIEW_NLA", oStruNLA, "NLAUNICO" )
oView:AddGrid(  "VIEW_NLC", oStruNLC, "NLCUNICO" )

oView:AddIncrementField( "VIEW_NL9", "NL9_CODTIP" )
oView:AddIncrementField( "VIEW_NLA", "NLA_SEQTIP" )
oView:AddIncrementField( "VIEW_NLC", "NLC_CODTAX" )

oView:CreateHorizontalBox( "SUPERIOR" , 15 )
oView:CreateHorizontalBox( "MEIO"     , 40 )
oView:CreateHorizontalBox( "INFERIOR" , 45 )

oView:CreateFolder( "GRADES", "INFERIOR")
oView:AddSheet( "GRADES", "PASTA01", OemToAnsi( STR0009 ) ) //"Faixas de Resultados de Análise"
oView:AddSheet( "GRADES", "PASTA02", OemToAnsi( STR0010 ) ) //"Taxas"
oView:CreateHorizontalBox( "PASTA_NLA", 100, , , "GRADES", "PASTA01" )
oView:CreateHorizontalBox( "PASTA_NLC", 100, , , "GRADES", "PASTA02" )

oView:SetOwnerView( "VIEW_NL8", "SUPERIOR" )
oView:SetOwnerView( "VIEW_NL9", "MEIO" )
oView:SetOwnerView( "VIEW_NLA", "PASTA_NLA" )
oView:SetOwnerView( "VIEW_NLC", "PASTA_NLC" )

oView:EnableTitleView( "VIEW_NL8" )
oView:EnableTitleView( "VIEW_NL9" )
oView:EnableTitleView( "VIEW_NLA" )
oView:EnableTitleView( "VIEW_NLC" )

oView:SetCloseOnOk( {||.t.} )

Return oView

/** {Protheus.doc} fWhenNLA
Função criada para habilitar / desabilitar os campos conforme o tipo
@return:    lRet - conteudo do campo
@author:    Tamyris Ganzenmueller
@since:     08/10/2018
@Uso:       OGAA940*/
Static Function fWhenNLA( cOpc )
	Local oModel	:= FwModelActive()
	Local oNL9		:= oModel:GetModel( "NL9UNICO" )
	Local cTipo     := oNL9:GetValue("NL9_TIPO")
	Local lRet      := IIf (cTipo = '2' ,.F., .T.) //Se Universal Standard, desabilita os campos
	
	If cOpc == '1'
		lRet := !lRet
	EndIF
		 
return lRet

/*/{Protheus.doc} fLoadGrd()
Função de validação dos campos NLA_CODUNS e NLA_DESRES, limpa/gatilha os valores dos campos NL7_CODUNS e NL7_DESUNS
@type  Static Function
@author christopher.miranda
@since 08/10/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
/*/
Static Function fLoadGrd()

	Local oView   := FWViewActive()
	Local oModel  := FwModelActive()
	Local oGrdNLA := oModel:GetModel("NLAUNICO")
	Local oGrdNL9 := oModel:GetModel("NL9UNICO")
	Local nX	  := 0
	Local nY	  := 1 
	Local cTipo   := oGrdNL9:GetValue('NL9_TIPO')

	If cTipo = '2'

		For nX := 1 to oGrdNLA:Length()

			oGrdNLA:GoLine( nX )

			If .Not. oGrdNLA:IsDeleted() .And. .not. empty(oGrdNLA:GetValue('NLA_CODUNS'))
				
				oGrdNLA:DeleteLine()

			EndIf

		Next nX

		DbselectArea('NL7')
		NL7->(dbGoTop())
		While .Not. Eof()
			
			oGrdNLA:GoLine(oGrdNLA:Length())

			if nY > 1 .Or. oGrdNLA:IsDeleted()

				oGrdNLA:AddLine()

			EndIf	
			
			oGrdNLA:SetValue( "NLA_SEQTIP", STRzero(nY,6) 	  )
			oGrdNLA:SetValue( "NLA_CODUNS", NL7->(NL7_CODUNS) )
			oGrdNLA:SetValue( "NLA_DESRES", NL7->(NL7_DESUNS) )
			oGrdNLA:LoadValue( "NLA_VALINI", 0 			 	  )
			oGrdNLA:LoadValue( "NLA_VALFIM", 0				  )

			NL7->(DbSkip())

			nY++ 
			
		Enddo

		oGrdNLA:GoLine(1)
		oView:Refresh() 

	EndIf

	NL7->(DbCloseArea())

Return .T.

/*/{Protheus.doc} fIniModelo()
Função para setar a descrição da moeda
@type  Static Function
@author rafael.kleestadt
@since 09/10/2018
@version 1.0
@param oModel, object, objeto do modelo principal da tela
@return cDesMoe, caractere, descrição da moeda conforme função AgrMvSimb do AGRUTIL01.PRW
@example
(examples)
@see (links_or_references)
/*/
Static Function fIniModelo(oModel)
	Local oNLC       := oModel:GetModel('NLCUNICO')
	Local nOperation := oModel:GetOperation()
	Local cDesMoe    := ""
	Local nX         := 0

	If nOperation <> MODEL_OPERATION_DELETE
		For nX := 1 To oNLC:Length()
		
			oNLC:GoLine(nX)

			cDesMoe := Iif( .NOT. Empty(oNLC:GetValue('NLC_MOEDA')), AgrMvSimb(oNLC:GetValue('NLC_MOEDA')), '')

			oNLC:LoadValue('NLC_DESMOE', cDesMoe)

		Next nX
	EndIf

Return .T.

/*/{Protheus.doc} fIniDesMoe( )
Função de inicialização do campo quando o model já foi aberto
@type  Static Function
@author rafael.kleestadt
@since 09/10/2018
@version version
@param param, param_type, param_descr
@return cDesMoe, caractere, descrição da moeda conforme função AgrMvSimb do AGRUTIL01.PRW
@example
(examples)
@see (links_or_references)
/*/
Static Function fIniDesMoe()
	Local oView	  := FwViewActive() // View ativa no momento
	Local oModel  := oView:GetModel()
    Local oNLC    := NIL
	Local cDesMoe := ""	

	If !Empty(oModel) .And. oView:IsActive()
		oNLC    := oModel:GetModel('NLCUNICO')
		nMoeda  := oNLC:InitValue('NLC_MOEDA')
		cDesMoe := Iif( .NOT. Empty(nMoeda), AgrMvSimb(nMoeda), '')
	EndIf

Return cDesMoe


/** {Protheus.doc} PosGride
Função que valida o gride de dados após a perda do foco ou a confirmação do modelo

@param: 	oGride - Gride do modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	05/07/2018
@Uso: 		OGA820
*/
Static Function PosGride( oGride)
	If oGride:GetValue('NLA_VALFIM') < oGride:GetValue('NLA_VALINI')
		Help('',1,'.OGAA94000001.')    
		Return .F.
	EndIf 
Return .t.
