#INCLUDE "AGRA690.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"

/** {Protheus.doc} AGRA690
Cadastro de Produtores

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: UBA
*/
Function AGRA690()
	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "DX8" )
	oBrowse:SetDescription( STR0001 ) //"Cadastro de Produtores"
	if !(GetRPORelease() < '12.1.023')
		MsgAlert(STR0021)//"O cadastro de Produtor foi substituido pelo cadastro de Entidades. Atualize seu menu!"		
		Return .F. 
	Endif
	If DX8->(ColumnPos('DX8_ATIVO')) > 0
		oBrowse:AddLegend( "DX8->DX8_ATIVO <> '2'", "GREEN", OemToAnsi( STR0002 ) ) //"Ativo"
		oBrowse:AddLegend( "DX8->DX8_ATIVO  = '2'", "RED"  , OemToAnsi( STR0003 ) ) //"Inativo"
	Endif

	oBrowse:Activate()

Return( )

/** {Protheus.doc} ModelDef
Retorna o modelo de Dados da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: AGRA690
*/
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruDX8 	:= FwFormStruct( 1, "DX8" ) // Cadastro de Produtores

	oModel := MpFormModel():New( "AGRA690", , {|x| PosModelo( x ) } )
	oModel:SetDescription( STR0002 ) //"Modelo de Dados do Cadastro de Produtores"

	oModel:AddFields( "DX8MASTER", , oStruDX8 )
	oModel:GetModel( "DX8MASTER" ):SetDescription( STR0003 ) //"Dados do Produtor"
	oModel:SetPrimaryKey( {"DX8_FILIAL", "DX8_CODIGO", "DX8_LOJA" } )

	oModel:SetVldActivate( { | oModel | IniModelo( oModel, oModel:GetOperation() ) } )

Return( oModel )

/** {Protheus.doc} ViewDef
Retorna a View (tela) da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: AGRA690
*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( "AGRA690" )
	Local oStruDX8 	:= FwFormStruct( 2, "DX8" ) // Cadastro de Produtores

	oView := FwFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "VIEW_DX8", oStruDX8, "DX8MASTER" )

	oView:CreateHorizontalBox( "SUP", 100 )
	oView:SetOwnerView( "VIEW_DX8", "SUP" )

Return( oView )

/** {Protheus.doc} MenuDef
Menu Padrao da Rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: AGRA690
*/
Static Function MenuDef()
	Local aRotina := {}    

	aAdd( aRotina, { STR0004	, 'PesqBrw'			, 0, 1, 0, .T. } ) //'Pesquisar'
	aAdd( aRotina, { STR0005	, 'ViewDef.AGRA690'	, 0, 2, 0, Nil } ) //'Visualizar'
	aAdd( aRotina, { STR0006	, 'ViewDef.AGRA690'	, 0, 3, 0, Nil } ) //'Incluir'
	aAdd( aRotina, { STR0007	, 'ViewDef.AGRA690'	, 0, 4, 0, Nil } ) //'Alterar'
	aAdd( aRotina, { STR0008	, 'ViewDef.AGRA690'	, 0, 5, 0, Nil } ) //'Excluir'
	aAdd( aRotina, { STR0009	, 'ViewDef.AGRA690'	, 0, 7, 0, Nil } ) //'Imprimir'
	aAdd( aRotina, { STR0010	, 'ViewDef.AGRA690'	, 0, 9, 0, Nil } ) //'Copiar'

Return( aRotina )

/** {Protheus.doc} IniModelo
Rotina para validaçao antes de iniciar o modelo de dados

@return:	.t. ou .f.	Verdadeiro (.t.) se deve carregar o modelo 
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA690
*/
Static Function IniModelo( oModel, nOperation )
	Local lRetorno	:= .t.
	Local cCodPro	:= DX8->( DX8_CODIGO )
	LOcal cLjPro	:= DX8->( DX8_LOJA )

	If nOperation == MODEL_OPERATION_DELETE

		BeginSql Alias 'QryNN2'
			Select
			Count( * ) as X_TOTAL
			From
			%table:NN2% NN2
			Where
			NN2.NN2_PRDTOR = %exp:cCodPro% And
			NN2.NN2_LJPRO  = %exp:cLjPro% And
			NN2.NN2_FILIAL = %xFilial:NN2% And
			NN2.%NotDel%
		EndSql
		QryNN2->( dbGotop() )
		If QryNN2->( X_TOTAL ) > 0
			Help( , , STR0011, ,STR0012, 1, 0 ) //"Ajuda"###"Não é permitido Excluir o cadastro, pois ha fazendas vinculadas!"
			lRetorno := .f.
		EndIf
		QryNN2->( dbCloseArea( ) )

	EndIf

Return( lRetorno )

/** {Protheus.doc} PosModelo
Rotina para validaçao após a confirmação do modelo

@param:		oModel - Modelo de dados
@return:	.t. ou .f.	Verdadeiro (.t.) se deve gravar o modelo 
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA690
*/
Static Function PosModelo( oModel )
	Local lRetorno		:= .t.
	Local nOperation	:= oModel:GetOperation()
	Local aAreaAtu		:= GetArea()
	Local aAreaDX8		:= DX8->( GetArea() )
	Local aAreaSA2		:= SA2->( GetArea() )
	Local aAreaSA1		:= SA1->( GetArea() )
	Local aAreaNN2		:= NN2->( GetArea() )

	Local cCodPro		:= oModel:GetValue( "DX8MASTER", "DX8_CODIGO" )
	Local cLjPro		:= oModel:GetValue( "DX8MASTER", "DX8_LOJA"   )
	Local cCGCPro		:= oModel:GetValue( "DX8MASTER", "DX8_CGC"    )
	Local cIEPro		:= oModel:GetValue( "DX8MASTER", "DX8_INSCR"  )

	Local cCodFor		:= oModel:GetValue( "DX8MASTER", "DX8_FORNEC" )
	Local cLojFor		:= oModel:GetValue( "DX8MASTER", "DX8_LJFOR"  )

	Local cCodCli		:= oModel:GetValue( "DX8MASTER", "DX8_CLIENT" )
	Local cLojCli		:= oModel:GetValue( "DX8MASTER", "DX8_LJCLI"  )

	Local cMsgErro		:= ""

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

		If .Not. Empty( AllTrim( cCGCPro + cIEPro ) )

			dbSelectArea( "DX8" )
			dbSetOrder( 3 )
			If dbSeek( fwxFilial( "DX8" ) + cCGCPro + cIEPro )
				cMsgErro += STR0013 //"[x] Ja existe Produtor com este CNPJ/CPF e Iscrição Estadual;"
			EndIf

		EndIf

		If .Not. Empty( AllTrim( cCodFor + cLojFor ) )

			dbSelectArea( "SA2" )
			dbSetOrder( 1 )
			If dbSeek( fwxFilial( "SA2" ) + cCodFor + cLojFor )

				If AllTrim( SA2->( A2_CGC ) ) <> AllTrim( cCGCPro )
					cMsgErro += STR0014 + Chr(13)+Chr(10) //"[x] CNPJ/CPF do Produtor é diferente do CNPJ/CPF do Fornecedor selecionado;"
				EndIf

				If AllTrim( SA2->( A2_INSCR ) ) <> AllTrim( cIEPro )
					cMsgErro += STR0015 + Chr(13)+Chr(10) //"[x] I.E. do Produtor é diferente da I.E. do Fornecedor selecionado;"
				EndIf

			EndIf

		EndIf

		If .Not. Empty( AllTrim( cCodCli + cLojCli ) )

			dbSelectArea( "SA1" )
			dbSetOrder( 1 )
			If dbSeek( fwxFilial( "SA1" ) + cCodCli + cLojCli )

				If AllTrim( SA1->( A1_CGC ) ) <> AllTrim( cCGCPro )
					cMsgErro += STR0016 + Chr(13)+Chr(10) //"[x] CNPJ/CPF do Produtor é diferente do CNPJ/CPF do Cliente selecionado;"
				EndIf

				If AllTrim( SA1->( A1_INSCR ) ) <> AllTrim( cIEPro )
					cMsgErro += STR0017 + Chr(13)+Chr(10) //"[x] I.E. do Produtor é diferente da I.E. do Cliente selecionado;"
				EndIf

			EndIf

		EndIf

		If .Not. Empty( AllTrim( cMsgErro ) )
			MsgInfo( cMsgErro )
			lRetorno := .f.
		EndIf

	EndIf

	If nOperation == MODEL_OPERATION_DELETE

		dbSelectArea( "NN2" )
		dbSetOrder( 3 )
		If dbSeek( fwxFilial( "NN2" ) + cCodPro + cLjPro )

			Help( , , "AJUDA", , STR0018, 1, 0 ) //"Existem fazendas cadastradas para este Produtor."
			lRetorno := .f.

		EndIf

	EndIf

	RestArea( aAreaNN2 )
	RestArea( aAreaSA1 )
	RestArea( aAreaSA2 )
	RestArea( aAreaDX8 )
	RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} AGR690PCGC
Altera mascara do campo DX8_CGC para digitação de CNPJ ou CPF

@param:  Nil
@author: Aecio Ferreira Gomes
@since:  05/11/2012
@Uso: 	 UBA
*/
Function AGR690PCGC()
Return( PicPes(M->DX8_TIPENT))

/*/{Protheus.doc} IntegDef
//Função responsavel pela chamada de integração
@author bruna.rocio
@since 09/10/2017
@version 12.1.19
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local aRet := {}
	//a funcao integdef original foi transferida para o fonte AGRI690, conforme novas regras de mensagem unica.
	If FindFunction('AGRI690') .And. DX8->(ColumnPos('DX8_ATIVO')) > 0
		aRet:= AGRI690( cXml, nTypeTrans, cTypeMessage )
	Else
		MsgNextRel() // É necessária a atualização do sistema para a expedição mais recente
	Endif
Return aRet


