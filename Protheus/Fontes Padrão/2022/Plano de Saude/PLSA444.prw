#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' //Necessita desse include quando usar MVC.
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "PLSMGER.CH"
#include "TOTVS.CH"
#include "PLSA444.CH"
#include "dbtree.ch"

/* J
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ PLSA444  บ Autor ณEverton M. Fernandesบ Data ณ  03/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Fun็ใo voltada para o cadastro das terminologias do TISS   ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA444                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSA444()
	Local oBrowse
	Local aArea   := GetArea()

//Retorno F3 do campo BTP_CHVTAB
	PRIVATE cChv444	:= ""
	Private cChv445 := ""

	If !FWAliasInDic("BTP", .F.)
		MsgAlert(STR0045) //"Para esta funcionalidade ้ necessแrio executar os procedimentos referente ao chamado: THQGIW"
	Return()
	EndIf

// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()

// Defini็ใo da tabela do Browse
	oBrowse:SetAlias('BTP')

// Titulo da Browse
	oBrowse:SetDescription(STR0001) //'Cadastro de Terminologias TISS'

// Ativa็ใo da Classe
	oBrowse:Activate()

	RestArea(aArea)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ MenuDef  บ Autor ณEverton M. Fernandesบ Data ณ  03/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Define o menu da aplica็ใo                                 ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA444                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.PLSA444' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PLSA444' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PLSA444' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PLSA445' OPERATION 4 ACCESS 0 //'Campos Adic.'
	ADD OPTION aRotina Title STR0006 Action 'PLSA443(BTP->BTP_CODTAB)' OPERATION 4 ACCESS 0 //'Protheus x TISS'
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.PLSA444' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina Title STR0009 Action 'PLSUGEVIN' OPERATION 4 ACCESS 0 //'Sugestใo De-Para'
	ADD OPTION aRotina Title STR0046 Action 'PLSA449(BTP->BTP_CODTAB)' OPERATION 4 ACCESS 0 //'Termos'
	ADD OPTION aRotina Title 'Atualizar Terminologias' Action 'PLSA444REC(.f.)' OPERATION 2 ACCESS 0 
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ ModelDef บ Autor ณEverton M. Fernandesบ Data ณ  03/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Define o modelo de dados da aplica็ใo                      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA444                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
	Local oStruBTP := FWFormStruct( 1, 'BTP' )
	Local oStruBVL := FWFormStruct( 1, 'BVL' )
	Local oModel		:= Nil // Modelo de dados construํdo

// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PLSA444', /*bPreValidacao*/, {|oModel|P444POS(oModel)} , /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo um componente de formulแrio
	oModel:AddFields( 'BTPMASTER', /*cOwner*/, oStruBTP )

// Adiciona ao modelo uma componente de grid
	oModel:AddGrid( 'BVLDETAIL', 'BTPMASTER', oStruBVL )

// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'BVLDETAIL', { { 'BVL_FILIAL', 'xFilial( "BVL" )'},;
		{ 'BVL_CODTAB', 'BTP_CODTAB' } }, BVL->( IndexKey( 1 ) ) )

// Adiciona a descri็ใo do Modelo de Dados
	oModel:SetDescription( STR0010 ) //'Cadastro de Termos TISS'

// Adiciona a descri็ใo dos Componentes do Modelo de Dados
	oModel:GetModel( 'BTPMASTER' ):SetDescription( STR0011 ) //'Cabe็alho do Termo'
	oModel:GetModel( 'BVLDETAIL' ):SetDescription( STR0013 ) //'Alias TISS'

// Retorna o Modelo de dados
Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ ViewDef  บ Autor ณEverton M. Fernandesบ Data ณ  03/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Define o modelo de dados da aplica็ใo                      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA444                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
	Local oModel := FWLoadModel( 'PLSA444' )

// Cria as estruturas a serem usadas na View
	Local oStruBTP := FWFormStruct( 2, 'BTP' )
	Local oStruBVL := FWFormStruct( 2, 'BVL' )

// Interface de visualiza็ใo construํda
	Local oView

	Local aArea      := GetArea()

// Cria o objeto de View
	oView := FWFormView():New()

// Define qual Modelo de dados serแ utilizado
	oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulแrio (antiga Enchoice)
	oView:AddField( 'VIEW_BTP', oStruBTP, 'BTPMASTER' )

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid( 'VIEW_BVL', oStruBVL, 'BVLDETAIL' )

//Permite gravar apenas a tabela BTP
	oModel:GetModel('BVLDETAIL'):SetOptional(.T.)

//Retira o campo c๓digo da tela
	oStruBVL:RemoveField('BVL_CODTAB')

// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 20 )
	oView:CreateHorizontalBox( 'INFERIOR', 80 )

//Cria as Folders
	oView:CreateFolder( 'PASTA_INFERIOR' ,'INFERIOR' )

//Cria as pastas
	oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_ALIAS'    , STR0013 ) //'Alias TISS'

	oView:CreateVerticalBox( 'BOX_ALIAS', 100,,, 'PASTA_INFERIOR', 'ABA_ALIAS' )

// Relaciona o identificador (ID) da View com o "box" para exibi็ใo
	oView:SetOwnerView( 'VIEW_BTP', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_BVL', 'BOX_ALIAS' )

	RestArea( aArea )

// Retorna o objeto de View criado
Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ PL444CMP บ Autor ณEverton M. Fernandesบ Data ณ  03/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Valida se um campo faz parte da estrutura da tabela e      ณฑฑ
ฑฑบ          ณ permite sua edi็ใo                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA444                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PL444CMP(cCampo)
	Local lRet

	Default cCampo:=""

	DbSelectArea("BTD")
	DbSetOrder(1)
//Verifica se o campo pode ser editado.
	lRet := !Empty(BTP->BTP_CODTAB) .AND. DbSeek(xFilial("BTD")+ BTP->BTP_CODTAB+cCampo)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ P444POS  บ Autor ณEverton M. Fernandesบ Data ณ  03/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Define o modelo de dados da aplica็ใo                      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA444                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function P444POS( oModel )
	Local lRet := .T.
	Local nOperation := oModel:GetOperation()
// Segue a fun็ใo ...
	If nOperation == MODEL_OPERATION_INSERT
	//Valida se foi informado o alias da tabela do protheus.
		If M->BTP_TIPVIN=='0'
			If EMPTY(M->BTP_ALIAS)
				Help( ,, STR0015,, STR0016, 1, 0 ) //'Erro de preenchimento' , 'Informe o Alias da Tabela.'
				lRet := .F.
			ElseIf	EMPTY(M->BTP_CHVTAB)
				Help( ,, STR0015,, STR0017, 1, 0 ) //'Erro de preenchimento' , 'Informe a Chave da Tabela.'
				lRet := .F.
			EndIf
		EndIf

	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLS444CHV บ Autor ณEverton M. Fernandesบ Data ณ  19/01/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Insere em Campo Memo campos pre-definidos para o Relatorio บฑฑ
ฑฑบ          ณ de Informe de Rendimento PLSR997                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLS444CHV(cOrigem)

	Local oModel  := Nil
	Local oModelAux := Nil
	Local oDlg   := Nil
	Local oBtnCancelar := Nil
	Local oBtnOK  := Nil
	Local oPnGrid  := Nil
	Local oBtnRemove := Nil

	Local aHeadCpo  := {}
	Local aHeadChv  := {}
	Local aColsCpo  := {}
	Local aColsChv  := {}

	Local nPos1  := 0

	Local cCampo  := ""
	Local cDesAlias := ""
	Local cChave  := ""
	Local cPerg  := ""

	Default cOrigem := ""


	If !FWAliasInDic("BTP", .F.)
		MsgAlert(STR0045) //"Para esta funcionalidade ้ necessแrio executar os procedimentos referente ao chamado: THQGIW"
	Return()
	EndIf



	oModel   := FWModelActive()

	Do Case
	Case cOrigem == 'BTP'
		oModelMaster   := oModel:GetModel( 'BTPMASTER' )
		oModelAux := oModel:GetModel( 'BTQDETAIL' )

		cAlias := oModelMaster:GetValue( 'BTP_ALIAS')
		cChave := oModelMaster:GetValue( 'BTP_CHVTAB')
		cDesAlias := oModelMaster:GetValue(  'BTP_ALIDES')
		cPerg := ""// oModelB7A:GetValue( 'B7ADETAIL', 'B7A_ALIAS')

	Case cOrigem == 'B7B'
		oModelMaster := oModel:GetModel( 'BCLMASTER' )
		oModelAux := oModel:GetModel( 'B7BDETAIL' )

		cAlias := oModelAux:GetValue( 'B7B_ALIAS')
		cChave := oModelAux:GetValue( 'B7B_CAMPO')
		cDesAlias := oModelAux:GetValue(  'B7B_ALIDES')
		cPerg := ""// oModelB7A:GetValue( 'B7ADETAIL', 'B7A_ALIAS')

	Case cOrigem == 'BVL'
		oModelMaster := oModel:GetModel( 'BTPMASTER' )
		oModelAux := oModel:GetModel( 'BVLDETAIL' )

		cAlias := oModelAux:GetValue( 'BVL_ALIAS')
		cChave := oModelAux:GetValue( 'BVL_CHVTAB')
		cDesAlias := oModelAux:GetValue(  'BVL_ALIDES')
		cPerg := ""// oModelB7A:GetValue( 'B7ADETAIL', 'B7A_ALIAS')
	Otherwise
		cOrigem := ""
	EndCase
	cChv444 := cChave
	If !Empty(cOrigem)
		DbSelectArea("SX3")
		DbSelectArea("SX2")
		DbSelectArea("SX1")

		If !Empty(cPerg)
			DbSetOrder(1)
			If DbSeek(cPerg)
				While !Eof() .AND. Alltrim(SX1->X1_GRUPO) == Alltrim(cPerg)
					AADD(aColsChv, {SX1->(X1_PAR01),SX1->(X1_PERGUNTE),.F.})
					DbSkip()
				EndDo
			EndIf
		EndIf

 //Monta aCols CHAVE
		While !Empty(cChave)
  //Quebra a chave para adicionala na grid
			If (nPos1 := At("+", cChave)) > 0
				cCampo := Substr(cChave, 1, nPos1 - 1)
				cChave :=  Substr(cChave, nPos1 + 1, Len(cChave))
			Else
				cCampo := cChave
				cChave := ""
			EndIf
			If !(cAlias $ Substr(cCampo,1,3)) .AND. (nPos1:= At("(", cCampo)) > 0
				cCampo := Alltrim(Substr(cCampo,nPos1+1, Len(cCampo)-1))
			EndIf
  //Procura o campo da chave
			DbSelectArea("SX3")
			SX3->(DbSetOrder(2))
			If SX3->(DbSeek(cCampo))
				If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL ;
						.And. SX3->X3_ARQUIVO == cAlias .AND. !("_FILIAL" $ SX3->X3_CAMPO)
					AADD(aColsChv, {cCampo,SX3->X3_DESCRIC,.F.})
				EndIf
			EndIf
		EndDo

 //Monta aCols CAMPOS
		DbSelectArea("SX3")
		SX3->(DbSetOrder(1))
		SX3->(DbSeek(cAlias))
		While !SX3->(EoF()) .And. SX3->X3_ARQUIVO == cAlias
			If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .AND. !("_FILIAL" $ SX3->X3_CAMPO) ;
					.AND. aScan(aColsChv,{ |x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)}) == 0
				AADD(aColsCpo, {SX3->X3_CAMPO,SX3->X3_DESCRIC,.F.})
			EndIf
			SX3->(DbSkip())
		EndDo

		DEFINE MSDIALOG oDlg TITLE STR0018 FROM 000, 000  TO 340, 490 COLORS 0, 16777215 PIXEL //"Montar Chave"

		@ 003, 003 MSPANEL oPnGrid SIZE 237, 146 OF oDlg //COLORS 0, 14215660 RAISED

 //Monta aHeader e define a MSNEWGETDADOS dos CAMPOS
		aAdd(aHeadCpo,{"Campo"  ,"HSPCAMPO" ,"@!" , Len(SX3->X3_CAMPO)  ,0, , ,"C", ,"R", , , ,"V", , ,.T.})
		aAdd(aHeadCpo,{"Dado"  ,"HSPDADO"  ,""  , 100      ,0, , ,"C", ,"R", , , ,"V", , ,.T.})
		oCampos := MsNewGetDados():New(001, 004, 143, 104, GD_UPDATE,,,,,,,,,, oPnGrid, aHeadCpo, aColsCpo)

 //Monta aHeader e define a MSNEWGETDADOS da CHAVE
		aAdd(aHeadChv,{"Campo"  ,"HSPCAMPO" ,"@!" , Len(SX3->X3_CAMPO)  ,0, , ,"C", ,"R", , , ,"V", , ,.T.})
		aAdd(aHeadChv,{"Dado"  ,"HSPDADO"  ,""  , 100      ,0, , ,"C", ,"R", , , ,"V", , ,.T.})
		oChave := MsNewGetDados():New( 001, 134, 143, 234, GD_UPDATE,,,,,,,,,, oPnGrid, aHeadChv, aColsChv)

		@ 051, 107 BUTTON oBtnOK   PROMPT ">>" SIZE 023, 012 OF oPnGrid PIXEL ACTION (PLS444ADD(@oCampos,@oChave))
		@ 069, 107 BUTTON oBtnRemove PROMPT "<<" SIZE 023, 012 OF oPnGrid PIXEL ACTION (PLS444ADD(@oChave,@oCampos))
		@ 153, 161 BUTTON oBtnOK PROMPT STR0019 SIZE 037, 012 OF oDlg PIXEL ACTION (nOpca:=1,PLS444STR(oChave),oDlg:End()) //"OK"
		@ 153, 202 BUTTON oBtnCancelar PROMPT STR0020 SIZE 037, 012 OF oDlg PIXEL ACTION (nOpca:=2,oDlg:End()) //"Cancelar"

		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		MsgAlert(STR0021) //"Origem invแlida."
	EndIf
Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLS444ADD บ Autor ณEverton M. Fernandesบ Data ณ  19/01/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Insere em Campo Memo campos pre-definidos para o Relatorio บฑฑ
ฑฑบ          ณ de Informe de Rendimento PLSR997                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLS444ADD(oOrigem,oDestino)

	Local nPosOri	:= oOrigem:nAt
	Local nPosDes	:= oDestino:nAt

	Local nLenOri	:= Len(oOrigem:aCols)
	Local nLenDes	:= 0

	If nLenOri > 0
		If len(oDestino:aCols) <= 0 .OR. !Empty(oDestino:aCols[nPosDes,1])
		//Insere nova linha na chave
			aAdd(oDestino:aCols,{,,.F.})
		EndIf
	//Pega o tamanho da grid de destino
		nLenDes := Len(oDestino:aCols)
	//Copia a Campo para a Chave
		ACopy ( oOrigem:aCols, oDestino:aCols, nPosOri, 1, nLenDes )
	//Apaga valor do Campo
		aDel (oOrigem:aCols,nPosOri)
	//Remove a ultima linha
		aSize(oOrigem:aCols, nLenOri - 1)

	//Atualiza os Grids
		oOrigem:ForceRefresh()
		oDestino:ForceRefresh()

	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLS444STR บ Autor ณEverton M. Fernandesบ Data ณ  19/01/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta a chave baseado no grid Chave                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLS444STR(oChave)
	Local nI := 0
	If Len(oChave:aCols) > 0
		cChv444:= ""
		For nI:=1 to Len(oChave:aCols)
			cChv444 += AllTrim(oChave:aCols[nI,1]) + "+"
		Next I
	//Remove o ultim "+"
		cChv444 := SubStr(cChv444,1,Len(cChv444)-1)
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSUGEVINบ Autor ณBruno Iserhardt     บ Data ณ  02/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Realiza a sugest็ao de De-Para da TISS 3.00.01             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
function PLSUGEVIN()

	Local aCoors := FWGetDialogSize( oMainWnd )
	Local aAlias := PLGetAlias(BTP->BTP_CODTAB) //pesquisa os alias cadastrados na tabela de domํnio
	Local oPanelUp
	Local oFWLayer
	Local oFWLayerRight
	Local oPanelLeft
	Local oPanelRight
	Local oBtnGravar
	Local oBtnBuscar
	Local oChkTodos
	Local lBrwActive := .F.
	LOCAL aCampos	:= {}
	LOCAL oBtnSair
	LOCAL cKey := ''
	PRIVATE oOK := LoadBitmap(GetResources(),'br_verde')
	PRIVATE oNO := LoadBitmap(GetResources(),'br_vermelho')
	PRIVATE aColsGrid := { {.F.,"","",""} }
	PRIVATE aColsFil := { {.F.,"","",""} }
	PRIVATE oBrowseLeft
	PRIVATE oBrowseRight
	PRIVATE cCod := Space(10)
	PRIVATE cFiltro := Space(100)
	PRIVATE cDesc := Space(10)
	PRIVATE nCBTpComp
	PRIVATE oDlgPrinc
	PRIVATE cCBAlias
	PRIVATE lCheckVin := .F.
	PRIVATE lChkTodos := .F.
	PRIVATE cAliasAtua := "" //representa o alias selecionado na hora de realizar a busca das sugest๕es



	If !FWAliasInDic("BTP", .F.)
		MsgAlert(STR0045) //"Para esta funcionalidade ้ necessแrio executar os procedimentos referente ao chamado: THQGIW"
	Return()
	EndIf


	If (aAlias == NIL .OR. Len(aAlias) <= 0)
		MsgInfo(STR0022) //"Nenhum alias cadastrado para a terminologia."
	Return
	EndIf

	Define MsDialog oDlgPrinc Title STR0023 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel //"Sugestใo de De-Para"

// Cria o conteiner
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )

// linha 100%
	oFWLayer:AddLine( 'LINE', 100, .F. )
// coluna 50%
	oFWLayer:AddCollumn( 'COLLEFT', 50, .T., 'LINE' )
// coluna 50%
	oFWLayer:AddCollumn( 'COLRIGHT', 50, .T., 'LINE' )

//pega o objeto da coluna da esqueda
	oPanelLeft := oFWLayer:GetColPanel( 'COLLEFT', 'LINE' )
//pega o objeto da coluna da direita
	oPanelRight := oFWLayer:GetColPanel( 'COLRIGHT', 'LINE' )

//cria conteiner no painel da direita
	oFWLayerRight := FWLayer():New()
	oFWLayerRight:Init( oPanelRight, .F., .T. )
//linha 30%
	oFWLayerRight:AddLine( 'LINEUP', 30, .F. )
// coluna 100%
	oFWLayerRight:AddCollumn( 'COLUP', 100, .T., 'LINEUP' )
//linha 60%
	oFWLayerRight:AddLine( 'LINECENTER', 65, .F. )
// coluna 100%
	oFWLayerRight:AddCollumn( 'COLCENTER', 100, .T., 'LINECENTER' )
//linha 10%
	oFWLayerRight:AddLine( 'LINEDOWN', 5, .F. )
// coluna 100%
	oFWLayerRight:AddCollumn( 'COLDOWN', 100, .T., 'LINEDOWN' )

//pega o objeto da primeira linha da coluna da direita
	oPanelUp := oFWLayerRight:GetColPanel( 'COLUP', 'LINEUP' )
//pega o objeto da segunda linha da coluna da direita
	oPanelCenter := oFWLayerRight:GetColPanel( 'COLCENTER', 'LINECENTER' )
//pega o objeto da terceira linha da coluna da direita
	oPanelDown := oFWLayerRight:GetColPanel( 'COLDOWN', 'LINEDOWN' )

//PRIMEIRA LINHA COLUNA DA ESQUERDA
//Grid termos da terminologia
 	oBrowseLeft:= FWmBrowse():New()
   	oBrowseLeft:SetOwner( oPanelLeft )
	oBrowseLeft:SetDescription( STR0024 ) //"Termos"
  	oBrowseLeft:SetAlias( 'BTQ' )
	oBrowseLeft:SetFilterDefault("BTQ_FILIAL = '"+xFilial("BTQ")+"' .AND. BTQ_CODTAB = '"+BTP->BTP_CODTAB+"'" + IIF(lCheckVin == .F., " .AND. BTQ_HASVIN = '0'",''))
  	oBrowseLeft:DisableConfig()
	oBrowseLeft:DisableSeek()
	//oBrowseLeft:DisableReport()
	oBrowseLeft:DisableDetails()
  	oBrowseLeft:ForceQuitButton()
	oBrowseLeft:SetAmbiente(.F.)
  	oBrowseLeft:SetWalkThru(.F.)
	oBrowseLeft:SetMenuDef("")
	oBrowseLeft:nAt := 1
 	oBrowseLeft:setDoubleClick({ || Processa( {|| PLAtuSuges(!lBrwActive, lChkTodos)}, "Aguarde..", "Buscando sugest๕es...")})
	oBrowseLeft:AddLegend( "BTQ_HASVIN == '0' ", "RED"		, STR0025	,,.F. ) //"Nใo tem vinculo De-Para"
	oBrowseLeft:AddLegend( "BTQ_HASVIN == '1' ", "GREEN"		, STR0026,,.F. ) //"Tem vinculo De-Para"
	oBrowseLeft:Activate()
	oBrowseLeft:SetChange({||FS_LIMPAGRID(lChkTodos)})


	lBrwActive := .T.

//CheckBox Exibir termos ja vํnculados
	oCheckVin := TCheckBox():New(026,075,STR0027,{||lCheckVin},oPanelLeft,100,200,,,,,,,,.T.,,,) //'Exibir termos jแ vinculados'
	oCheckVin:bLClicked := {||	lCheckVin := !lCheckVin, ;
	PLAtuSuges(.T.,lChkTodos) }
                                                     

//PRIMEIRA LINHA DA COLUNA DA DIREITA
//Combo Alias
	oSay4 = TSay():New( 002,005,{||STR0028},oPanelUp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008) //"Alias"
	oCBAlias := TComboBox():New( 008,005,{|u| cKey := PLKEY(), If(PCount()>0,cCBAlias:=u,cCBAlias), PL444FIELD() },aAlias,060,010,oPanelUp,,{|| PL444FIELD(), cKey := PLKEY()  },,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,cCBAlias)
//Combo Tipo Compara็ao
	oSay3 = TSay():New( 002,070,{||STR0029},oPanelUp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008) //"Tipo de Compara็ใo"
	oCBTpComp  := TComboBox():New( 008,070,{|u| If(PCount()>0,nCBTpComp:=u,nCBTpComp)},{"1="+STR0030,"2="+STR0031},060,010,oPanelUp,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,nCBTpComp) //"C๓digo", "Descri็ใo"
//Botใo De/Para Automแtico
	oBtnDPAuto := TButton():New( 008,132,"De/Para Automแtico",oPanelUp,{|| Processa( {|| PLDParAuto()}, "Aguarde..", "Processando De/Para Automแtico...")},053,012,,,,.T.,,,,,,.F. ) //"Buscar"
//Texto C๓digo Protheus
	oSay1 = TSay():New( 025,005,{||STR0032},oPanelUp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008) //"Campo C๓digo Tab. Protheus"
	@ 031,005 MSGET cCod SIZE 55,11 OF oPanelUp PIXEL PICTURE "@!" F3 "VINSX3" VALID PLValidProt()
//Texto Descri็ใo Protheus
	oSay2 = TSay():New( 025,070,{||STR0033},oPanelUp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008) //"Campo Descri็ใo Tab. Protheus"
	@ 031,070 MSGET cDesc SIZE 55,11 OF oPanelUp PIXEL PICTURE "@!" F3 "VINSX3" VALID PLValidProt()
//Botใo Buscar
	oBtnBuscar := TButton():New( 031,140,STR0034,oPanelUp,{|| PLAtuSuges(,lChkTodos)},037,012,,,,.T.,,,,,,.F. ) //"Buscar"

	oSay5 = TSay():New( 046,005,{||"Filtrar itens encontrados"},oPanelUp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008) //"Filtrar itens encontrados"
	@ 053,005 MSGET cFiltro SIZE 100,10 OF oPanelUp PIXEL PICTURE "@!" VALID P444Filtra()

//Texto Chave
 	oSay6 = TSay():New( 067,005,{||"Chave="+cKey},oPanelUp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,150,008) //"Chave"

	aCampos := {@oCheckVin,@oCBAlias,@oCBTpComp,@oBtnDPAuto,@oBtnBuscar}

	oChkTodos := TCheckBox():New(054,140,'Mostrar Todos',{||lChkTodos},oPanelUp,100,210,,,,,,,,.T.,,,) //Todos
	oChkTodos:bLClicked := {||	PLBlqCmp(lChkTodos, aCampos),;
		lChkTodos := !lChkTodos, ;
		PLAtuSuges(.F.,lChkTodos) ;
		}
//SEGUNDA LINHA COLUNA DA DIREITA
//cria a grid que terใo os itens a serem vinculados, as outras configura็๕es da grid estใo na fun็ใo PLAtuSuges

	oBrowseRight := TWBrowse():New( 00, 00, aCoors[4]*0.25, aCoors[3]*0.3,,{'', STR0035, STR0036, "Chave"},{20,30,30},oPanelCenter,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) //'C๓digo', 'Descri็ใo'
	oBrowseRight:bLDblClick := {|| PLMarcVinc() }
	oBrowseRight:SetArray(aColsGrid)
	oBrowseRight:bLine := {||{If(aColsGrid[oBrowseRight:nAt,01],oOK,oNO),aColsGrid[oBrowseRight:nAt,02],aColsGrid[oBrowseRight:nAt,03],aColsGrid[oBrowseRight:nAt,04] } }
	oBrowseRight:DrawSelect()


//TERCEIRA LINHA COLUNA DA DIREITA
	oBtnGravar := TButton():New( 000,(aCoors[4]/4)-050,STR0037,oPanelDown,{|| PLVincTISS(), FS_LIMPALGRID() },037,012,,,,.T.,,"",,,,.F. ) //"Gravar"
	oBtnSair := TButton():New( 000,(aCoors[4]/4)-090,"Sair",oPanelDown,{|| oDlgPrinc:End() },037,012,,,,.T.,,"",,,,.F. ) //"Gravar"

	Activate MsDialog oDlgPrinc Center

Return Nil

Static Function FS_LIMPAGRID(lChkTodos)        

Default lChkTodos:=.F.
 
If (!lChkTodos)  
	If Len(oBrowseRight:Aarray) > 0
		If !Empty(oBrowseRight:AARRAY[1,2])
			//aColsGrid := { {.F., "", "", ""} }
		  //oBrowseRight:SetArray(aColsGrid)
	      //oBrowseRight:Refresh()
		Endif	
	Endif	
EndIf

Return()


Static Function FS_LIMPALGRID()
	oBrowseLeft:CleanFilter()
	oBrowseLeft:SetFilterDefault("BTQ_FILIAL = '"+xFilial("BTQ")+"' .AND. BTQ_CODTAB = '"+BTP->BTP_CODTAB+"'" + IIF(lCheckVin == .F., " .AND. BTQ_HASVIN = '0'",''))
	oBrowseLeft:Refresh()
Return ()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณP444Filtra บ AutorณBruno Iserhardt     บ Data ณ  17/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Faz o filtro da grid da direita                			    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function P444Filtra()

Local i := 1

	aColsFil := {}

	If !Empty(ALLTRIM(cFiltro))
		For i := 1 To Len(aColsGrid)
			If (ALLTRIM(cFiltro) $ aColsGrid[i, 2] .OR. ALLTRIM(cFiltro) $ aColsGrid[i, 3])
				Aadd(aColsFil, aColsGrid[i])
			EndIf
		Next

		If Len(aColsFil) <= 0
			aColsFil := { {.F., "", "", ""} }
		EndIf

		oBrowseRight:SetArray(aColsFil)
		oBrowseRight:bLine := {||{If(aColsFil[oBrowseRight:nAt,01],oOK,oNO),aColsFil[oBrowseRight:nAt,02],aColsFil[oBrowseRight:nAt,03],aColsFil[oBrowseRight:nAt,04] } }
	Else
		oBrowseRight:SetArray(aColsGrid)
		oBrowseRight:bLine := {||{If(aColsGrid[oBrowseRight:nAt,01],oOK,oNO),aColsGrid[oBrowseRight:nAt,02],aColsGrid[oBrowseRight:nAt,03],aColsGrid[oBrowseRight:nAt,04] } }
	EndIf


	oBrowseRight:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLValidProtบ AutorณBernardo Andr้ia    บ Data ณ  08/07/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                              			    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLValidProt()

	Local cAlias := cCBAlias

	If PLSALIASEX(cAlias)

		If !HS_EXISDIC({{"C", cCod}},.F.)
			MsgInfo("O campo selecionado nใo ้ vแlido") //
		EndIf
	EndIf

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLGetAliasบ Autor ณBruno Iserhardt     บ Data ณ  08/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna um array com os alias da terminologia			    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
function PLGetAlias(cCodTab)
	Local aAlias := {}

	If !FWAliasInDic("BVL", .F.)
		MsgAlert(STR0045) //"Para esta funcionalidade ้ necessแrio executar os procedimentos referente ao chamado: THQGIW"
	Return()
	EndIf

	If !Empty(BTP->BTP_ALIAS)
		aAdd(aAlias, BTP->BTP_ALIAS)
	EndIf

	BVL->(DbSelectArea("BVL"))
	BVL->(DbSetOrder(1))
	If (BVL->(MsSeek(xFilial("BVL")+cCodTab)))
		While (!BVL->(Eof()) .And. AllTrim(BVL->(BVL_FILIAL+BVL_CODTAB)) == AllTrim(xFilial("BVL")+cCodTab))
			aAdd(aAlias, BVL->BVL_ALIAS)
			BVL->(DbSkip())
		EndDo
	EndIf

Return aAlias

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLMarcVincบ Autor ณBruno Iserhardt     บ Data ณ  04/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca o item para ser vinculado posteriormente			    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PLMarcVinc()
	If !Empty(ALLTRIM(cFiltro))
		If (Len(aColsFil) > 0)
			aColsFil[oBrowseRight:nAt,1] := !aColsFil[oBrowseRight:nAt,1]
			oBrowseRight:DrawSelect()
		EndIf
	Else
		If (Len(aColsGrid) > 0)
			aColsGrid[oBrowseRight:nAt,1] := !aColsGrid[oBrowseRight:nAt,1]
			oBrowseRight:DrawSelect()
		EndIf
	EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLVincTISSบ Autor ณBruno Iserhardt     บ Data ณ  04/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Realiza a vincula็ใo dos itens marcados					    บฑฑ
ฑฑบ          ณ 																    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function PLVincTISS()
	Local i := 1
	Local lPassou := .F.
	Local lMarcouUm := .F.
	Local nRecnoBk := BTQ->(Recno())

	If !FWAliasInDic("BTU", .F.)
		MsgAlert(STR0045) //"Para esta funcionalidade ้ necessแrio executar os procedimentos referente ao chamado: THQGIW"
	Return()
	EndIf

	If (Len(aColsGrid) > 0) //.AND. !Empty(AllTrim(aColsGrid[1,2]))
		For i := 1 To Len(aColsGrid)
			If (aColsGrid[i,1] == .T. .AND. !Empty(AllTrim(aColsGrid[i,2]))) .And. PlsBusBTU(BTQ->BTQ_CODTAB,aColsGrid[i,4],aColsGrid[i,2],BTQ->BTQ_CDTERM,cAliasAtua) == 0
				lMarcouUm := .T.
				If MsgYesNo("Realizar o vinculo entre os dois itens abaixo? " + CRLF + CRLF + "Termo TISS: " + ALLTRIM(BTQ->BTQ_CODTAB) + "-" + ALLTRIM(BTQ->BTQ_DESTER) + CRLF + "Protheus: " + AllTrim(aColsGrid[i,2]) + "-" + AllTrim(aColsGrid[i,3]))
					//INSERE O VINCULO NA TABELA DE DE/PARA
					lPassou := .T.
					BTU->(RecLock('BTU',.T.))
					BTU->BTU_FILIAL := xFilial("BTU")
					BTU->BTU_CODTAB := BTQ->BTQ_CODTAB
					BTU->BTU_VLRSIS := aColsGrid[i,4]
					BTU->BTU_VLRBUS := aColsGrid[i,2]
					BTU->BTU_CDTERM := BTQ->BTQ_CDTERM
					BTU->BTU_ALIAS  := cAliasAtua
					BTU->( MsUnlock() )
				EndIf
			EndIf
		Next i
		If lPassou
			//CHAMA A FUNวAO QUE ATUALIZA O CAMPO BTU_HASVIN
			PLSAHASVIN(BTQ->BTQ_CODTAB, BTQ->BTQ_CDTERM, cAliasAtua)

			//ATUALIZA A GRID DOS TERMOS DA TERMINOLOGIA
			oBrowseLeft:Refresh()

			cFiltro := Space(100)
			PLAtuSuges(.T., lChkTodos)
			MsgInfo(STR0038) //"Vincula็ใo realizada com sucesso."
		ElseIf lMarcouUm == .F.
			MsgInfo("Informe ao menos um item para realizar o vinculo!") //"Vincula็ใo realizada com sucesso."
		EndIf
	Else
		MsgInfo("Nao possui vinculo para realizar!") //"Vincula็ใo realizada com sucesso."
	EndIf
	BTQ->(DbGoTo(nRecnoBk))
	oBrowseLeft:Refresh()


Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLDParAutoบ Autor ณBruno Iserhardt     บ Data ณ  05/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Realiza o De-Para automแtico pelo codigo de acordo com os  บฑฑ
ฑฑบ          ณ parametros informados                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLDParAuto()
Local iCount := 0
Local cAlias := cCBAlias
	//Caso o Alias comece com S, o prefixo das colunas das tabelas tem somente 2 caracteres, exemplo SX5 X5_FILIAL
Local cAliasFil := IIf (SubStr(cAlias, 1, 1) == "S", SubStr(cAlias, 2, 2), cAlias)
Local aArray := {}
Local nI := 0
Local nBTU_CDTERM := TamSX3("BTQ_CDTERM")[1]

If (PLDParObrg(.F.))
	//verifica se continua pela BTP ou BVL
	If cAlias == BTP->BTP_ALIAS

		//"Deseja realizar o De-Para automแtico da Tabela de Domํnio {0}-{1} para o Alias {2} que tenham c๓digos iguais?"
		If (MsgYesNo(StrTran(StrTran(StrTran(STR0043, "{0}", BTP->BTP_CODTAB), "{1}", BTP->BTP_DESCRI), "{2}", cCBAlias)))
			//atualiza a variแvel que representa o alias selecionado na hora da busca
			cAliasAtua := cCBAlias

			//percorre a BTQ
			BTQ->(DbSelectArea("BTQ"))
			BTQ->(DbSetOrder(1)) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM

			//posiciona a BTU
			DbSelectArea("BTU")
			BTU->(DbSetOrder(2)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS

			//posiciona a tabela do alias selcionado
			DbSelectArea(cAlias)
			&(cAlias)->(DbSetOrder(1)) //FILIAL

			//SE TEM REGISTROS NA TABELA DO ALIAS
			If &(cAlias)->(MsSeek(xFilial(cAlias)))
				ProcRegua(RecCount())
				//PERCORRE A TABELA DO ALIAS
				While !&(cAlias)->(Eof())
					IncProc()
					If cAlias == "BR8" .AND. BR8->BR8_PROBLO <> '1'
						//verifica se o item do alias ja tem um De-Para cadastrado
						If !BTU->(MsSeek(xFilial("BTU") + BTP->BTP_CODTAB + cAlias + &(cAlias + "->(" + cAliasFil + "_FILIAL+" + BTP->BTP_CHVTAB+")")))
							//procura um item na BTQ que tenha o mesmo codigo do item do alias

							If (BTQ->(MsSeek(xFilial("BTQ")+BTP->BTP_CODTAB+PadR(&(cAlias + "->" + cCod), nBTU_CDTERM, " "))))
								//INSERE O VINCULO NA TABELA DE DE/PARA
								BTU->(RecLock('BTU',.T.))
								BTU->BTU_FILIAL := xFilial("BTU")
								BTU->BTU_CODTAB := BTQ->BTQ_CODTAB
								BTU->BTU_VLRSIS := &(cAlias + "->(" + cAliasFil + "_FILIAL+" + BTP->BTP_CHVTAB + ")")
								BTU->BTU_VLRBUS := &(cAlias + "->" + cCod)
								BTU->BTU_CDTERM := BTQ->BTQ_CDTERM
								BTU->BTU_ALIAS  := cAliasAtua
								BTU->( MsUnlock() )

								// MONTA ARRAY PARA FUNวAO QUE ATUALIZA O CAMPO BTU_HASVIN
								aAdd(aArray,{BTQ->BTQ_CODTAB, BTQ->BTQ_CDTERM, cAliasAtua})
								iCount++
							EndIf
						EndIF

					Elseif cAlias <> "BR8"

						//verifica se o item do alias ja tem um De-Para cadastrado
						If !BTU->(MsSeek(xFilial("BTU") + BTP->BTP_CODTAB + cAlias + &(cAlias + "->(" + cAliasFil + "_FILIAL+" + BTP->BTP_CHVTAB+")")))
							//procura um item na BTQ que tenha o mesmo codigo do item do alias
							If (BTQ->(MsSeek(xFilial("BTQ")+BTP->BTP_CODTAB+PadR(&(cAlias + "->" + cCod), nBTU_CDTERM, " "))))
								//INSERE O VINCULO NA TABELA DE DE/PARA
								BTU->(RecLock('BTU',.T.))
								BTU->BTU_FILIAL := xFilial("BTU")
								BTU->BTU_CODTAB := BTQ->BTQ_CODTAB
								BTU->BTU_VLRSIS := &(cAlias + "->(" + cAliasFil + "_FILIAL+" + BTP->BTP_CHVTAB + ")")
								BTU->BTU_VLRBUS := &(cAlias + "->" + cCod)
								BTU->BTU_CDTERM := BTQ->BTQ_CDTERM
								BTU->BTU_ALIAS  := cAliasAtua
								BTU->( MsUnlock() )

								// MONTA ARRAY PARA FUNวAO QUE ATUALIZA O CAMPO BTU_HASVIN
								aAdd(aArray,{BTQ->BTQ_CODTAB, BTQ->BTQ_CDTERM, cAliasAtua})

								iCount++
							EndIf
						EndIF

					EndIf
					&(cAlias)->(DbSkip())
				EndDo

				//"Realizado De/Para de {0} registros.<br>Tabela de Domํnio: {1}-{2}<br>Tabela do Sistema: {3}"
				MsgInfo(StrTran(StrTran(StrTran(StrTran(STR0044, "{0}", cValToChar(iCount)), "{1}", BTP->BTP_CODTAB), "{2}", BTP->BTP_DESCRI), "{3}", cAlias))

				PLAtuSuges(.T., lChkTodos)

			EndIf
		EndIf

	Else

		//posiciona a BVL
		DbSelectArea("BVL")
		BVL->(DbSetOrder(2))//BVL_FILIAL+BVL_ALIAS+BVL_CODTAB

		If BVL->(MsSeek(xFilial("BVL")+cAlias+BTP->BTP_CODTAB))

			//"Deseja realizar o De-Para automแtico da Tabela de Domํnio {0}-{1} para o Alias {2} que tenham c๓digos iguais?"
			If (MsgYesNo(StrTran(StrTran(StrTran(STR0043, "{0}", BTP->BTP_CODTAB), "{1}", BTP->BTP_DESCRI), "{2}", cCBAlias)))
				//atualiza a variแvel que representa o alias selecionado na hora da busca
				cAliasAtua := cCBAlias

		//percorre a BTQ
				BTQ->(DbSelectArea("BTQ"))
				BTQ->(DbSetOrder(1)) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM

		//posiciona a BTU
				DbSelectArea("BTU")
				BTU->(DbSetOrder(2)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS



		//posiciona a tabela do alias selcionado
				DbSelectArea(cAlias)
				&(cAlias)->(DbSetOrder(1)) //FILIAL

		//SE TEM REGISTROS NA TABELA DO ALIAS
				If &(cAlias)->(MsSeek(xFilial(cAlias)))
					ProcRegua(RecCount())
			//PERCORRE A TABELA DO ALIAS
					While !&(cAlias)->(Eof())
						IncProc()
						If cAlias == "BR8" .AND. BR8->BR8_PROBLO <> '1'
				//verifica se o item do alias ja tem um De-Para cadastrado
							If !BTU->(MsSeek(xFilial("BTU") + BTP->BTP_CODTAB + cAlias + &(cAlias + "->(" + cAliasFil + "_FILIAL+" + BVL->BVL_CHVTAB+")")))
					//procura um item na BTQ que tenha o mesmo codigo do item do alias
								If (BTQ->(MsSeek(xFilial("BTQ")+BTP->BTP_CODTAB+PadR(&(cAlias + "->" + cCod), nBTU_CDTERM, " "))))
						//INSERE O VINCULO NA TABELA DE DE/PARA
									BTU->(RecLock('BTU',.T.))
									BTU->BTU_FILIAL := xFilial("BTU")
									BTU->BTU_CODTAB := BTQ->BTQ_CODTAB
									BTU->BTU_VLRSIS := &(cAlias + "->(" + cAliasFil + "_FILIAL+" + BVL->BVL_CHVTAB + ")")
									BTU->BTU_VLRBUS := &(cAlias + "->" + cCod)
									BTU->BTU_CDTERM := BTQ->BTQ_CDTERM
									BTU->BTU_ALIAS  := cAliasAtua
									BTU->( MsUnlock() )

						// MONTA ARRAY PARA FUNวAO QUE ATUALIZA O CAMPO BTU_HASVIN
									aAdd(aArray,{BTQ->BTQ_CODTAB, BTQ->BTQ_CDTERM, cAliasAtua})

									iCount++
								EndIf
							EndIF

						Elseif cAlias <> "BR8"

				//verifica se o item do alias ja tem um De-Para cadastrado
							If !BTU->(MsSeek(xFilial("BTU") + BTP->BTP_CODTAB + cAlias + &(cAlias + "->(" + cAliasFil + "_FILIAL+" + BVL->BVL_CHVTAB+")")))
					//procura um item na BTQ que tenha o mesmo codigo do item do alias
								If (BTQ->(MsSeek(xFilial("BTQ")+BTP->BTP_CODTAB+PadR(&(cAlias + "->" + cCod), nBTU_CDTERM, " "))))
						//INSERE O VINCULO NA TABELA DE DE/PARA
									BTU->(RecLock('BTU',.T.))
									BTU->BTU_FILIAL := xFilial("BTU")
									BTU->BTU_CODTAB := BTQ->BTQ_CODTAB
									BTU->BTU_VLRSIS := &(cAlias + "->(" + cAliasFil + "_FILIAL+" + BVL->BVL_CHVTAB + ")")
									BTU->BTU_VLRBUS := &(cAlias + "->" + cCod)
									BTU->BTU_CDTERM := BTQ->BTQ_CDTERM
									BTU->BTU_ALIAS  := cAliasAtua
									BTU->( MsUnlock() )

						// MONTA ARRAY PARA FUNวAO QUE ATUALIZA O CAMPO BTU_HASVIN
									aAdd(aArray,{BTQ->BTQ_CODTAB, BTQ->BTQ_CDTERM, cAliasAtua})

									iCount++
								EndIf
							EndIF

						Endif
						&(cAlias)->(DbSkip())
					EndDo

			//"Realizado De/Para de {0} registros.<br>Tabela de Domํnio: {1}-{2}<br>Tabela do Sistema: {3}"
					MsgInfo(StrTran(StrTran(StrTran(StrTran(STR0044, "{0}", cValToChar(iCount)), "{1}", BTP->BTP_CODTAB), "{2}", BTP->BTP_DESCRI), "{3}", cAlias))

					PLAtuSuges(.T., lChkTodos)
				EndIf
			EndIf
		EndIf

	EndIf
EndIf

//FUNวรO PARA ATUALIZAR O O CAMPO BTU_HASVIN
For nI = 1 To Len(aArray)
	PLSAHASVIN(aArray[nI,1], aArray[nI,2], aArray[nI,3])
Next


Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLAtuSugesบ Autor ณBruno Iserhardt     บ Data ณ  04/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza a grid de sugest๕es de vincula็ใo				    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ lForce = For็a o reload da grid sem perguntar se realmente บฑฑ
ฑฑบ          ณ deseja atualizar												    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function PLAtuSuges(lForce,lTodos)
	Local cAlias := cCBAlias
//Caso o Alias comece com S, o prefixo das colunas das tabelas tem somente 2 caracteres, exemplo SX5 X5_FILIAL
	Local cAliasFil := IIf (SubStr(cAlias, 1, 1) == "S", SubStr(cAlias, 2, 2), cAlias)
	Local i := 1
	Local nRecnoBk := BTQ->(Recno())
	Local nAtBk := oBrowseLeft:nAt
	Local lRet := .T.
	Private cSql := ''

	Default lForce := .F.
	Default lTodos := .F.

	if (!lForce)
//VERIFICA SE TEM ALGUM ITEM MARCADO NA GRID DA DIREITA PARA REALIZAR VINCULAวรO E PERGUNTA SE O USUมRIO QUER DESMARCA-LO
		if (Len(aColsGrid) > 0)
			For i := 1 To Len(aColsGrid)
				If (aColsGrid[i,1] == .T. .AND. (!Empty(AllTrim(aColsGrid[i,2])) .OR. !Empty(AllTrim(aColsGrid[i,3]))))
					If (!MsgYesNo(STR0039)) //"Existem itens marcados para realizar vincula็ใo, essa opera็ใo irแ desmarca-los. Deseja proseguir?"
					Return .F.
					EndIF
					EXIT
				EndIf
			Next i
		EndIf
	EndIf

//verifica se os campo obrigat๓rios estใo preenchidos
	If (PLDParObrg(lForce))
//LIMPA O ACOLS
		aColsGrid := {}
		aColsFil := {}
		cFiltro := Space(100)
//verifica se continua pela BTP ou BVL
		If cAlias == BTP->BTP_ALIAS

//posiciona a tabela do alias
			DbSelectArea(cAlias)
			&(cAlias)->(DbSetOrder(1)) //FILIAL

//posiciona a BTU
			DbSelectArea("BTU")
			BTU->(DbSetOrder(2)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS

//SE TEM REGISTROS NA TABELA DO ALIAS
			If &(cAlias)->(MsSeek(xFilial(cAlias)))
//PERCORRE A TABELA DO ALIAS

				cSQL	:= " SELECT " + cCod + "," + cDesc + "," + Replace(BTP->BTP_CHVTAB, "+", ",")
				cSQL	+= " FROM " + RetSQLName(cAlias)
				If BTP->BTP_CODTAB != "59" .AND. BTP->BTP_CODTAB != "60"
				cSQL	+= " WHERE " + cAliasFil + "_FILIAL = '" + xFilial(cAlias) + "'"
				ElseIf BTP->BTP_CODTAB == "59"
				cSQL	+= " WHERE X5_FILIAL = '" + xFilial(cAlias) + "'" + " AND X5_TABELA ='12'"
				ElseIf BTP->BTP_CODTAB == "60"
				cSQL	+= " WHERE AH_FILIAL = '" + xFilial(cAlias) + "'"
				EndIf
				If !lTodos
					If nCBTpComp == '1' //C๓digo
						cSQL	+= " AND " + cCod + " like '%" + Upper( Alltrim(BTQ->BTQ_CDTERM)) + "%'"
					Else
						cSQL	+= " AND UPPER(" + cDesc + ") like '%" + Upper( AllTrim(BTQ->BTQ_DESTER)) + "%'"
					EndIf
				EndIf
				If cAlias == "BR8"
				cSQL += " AND BR8_PROBLO IN ('', '0')"
				Endif
				cSQL += " AND D_E_L_E_T_ = ''"

				PlsQuery(cSQL,"TrbQRY")

				While !TrbQRY->(Eof())
					//SE O ITEM DO ALIAS NรO ESTม NA TABELA DE DE/PARA
					//A tabela de domํnio 59(Unidade da Federacao) utiliza a tabela SX5 como alias, e deve ser filtrada apenas X5_TABELA=12
					If !BTU->(MsSeek(xFilial("BTU") + BTP->BTP_CODTAB + cAlias + &(cAlias + "->(" + cAliasFil + "_FILIAL)")+"+"+BTP->BTP_CHVTAB)) //;
						//	.AND. (BTP->BTP_CODTAB != "59" .OR. SX5->X5_TABELA=="12")

						aAdd(aColsGrid, {.F.,  TrbQRY->&(cCod), TrbQRY->&(cDesc), &(cAlias + "->" + cAliasFil + "_FILIAL") + TrbQRY->&(AllTrim(BTP->BTP_CHVTAB))})
					EndIf
					TrbQRY->(DbSkip())
				EndDo
				TrbQRY->(dbCloseArea())
			EndIf

		Else

//posiciona a tabela do alias
			DbSelectArea(cAlias)
			&(cAlias)->(DbSetOrder(1)) //FILIAL
//posiciona BVL para buscar chave
			DbSelectArea("BVL")
			BVL->(DbSetOrder(2))//BVL_FILIAL+BVL_ALIAS+BVL_CODTAB
//posiciona a BTU
			DbSelectArea("BTU")
			BTU->(DbSetOrder(2)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS

//SE TEM REGISTROS NA TABELA DO ALIAS
			If &(cAlias)->(MsSeek(xFilial(cAlias)))
				If BVL->(MsSeek(xFilial("BVL")+cAlias+BTP->BTP_CODTAB))
//PERCORRE A TABELA DO ALIAS
					cSQL	:= " SELECT " + cCod + "," + cDesc + "," + Replace(BVL->BVL_CHVTAB, "+", ",")
					cSQL	+= " FROM " + RetSQLName(cAlias)
					If BTP->BTP_CODTAB != "59" 
						cSQL	+= " WHERE " + cAliasFil + "_FILIAL = '" + xFilial(cAlias) + "'"
					ElseIf BTP->BTP_CODTAB == "59"
						cSQL	+= " WHERE X5_FILIAL = '" + xFilial(cAlias) + "'" + " AND X5_TABELA ='12'"
			  		EndIf
					If !lTodos
						If nCBTpComp == '1' //C๓digo
							cSQL	+= " AND " + cCod + " like '%" + Upper( Alltrim(BTQ->BTQ_CDTERM)) + "%'"
						Else
							cSQL	+= " AND UPPER(" + cDesc + ") like '%" + Upper( AllTrim(BTQ->BTQ_DESTER)) + "%'"
						EndIf
					EndIf
					If cAlias == "BR8"
					cSQL += " BR8_PROBLO IN ('', '0')"
					Endif
					cSQL += " AND D_E_L_E_T_ = ''"

					PlsQuery(cSQL,"TrbQRY")

					While !TrbQRY->(Eof())
	//SE O ITEM DO ALIAS NรO ESTม NA TABELA DE DE/PARA
	//A tabela de domํnio 59(Unidade da Federacao) utiliza a tabela SX5 como alias, e deve ser filtrada apenas X5_TABELA=12
						If !BTU->(MsSeek(xFilial("BTU") + BVL->BVL_CODTAB + cAlias + &(cAlias + "->(" + cAliasFil + "_FILIAL)")+"+"+BVL->BVL_CHVTAB)) //;
								//.AND. (BVL->BVL_CODTAB != "59" .OR. SX5->X5_TABELA=="12")


							aAdd(aColsGrid, {.F.,  &(TrbQRY->(cCod)), &(TrbQRY->(cDesc)), &(cAlias + "->(" + cAliasFil + "_FILIAL)+" +BVL->BVL_CHVTAB )})

						EndIf

						TrbQRY->(DbSkip())
					EndDo
					TrbQRY->(dbCloseArea())
				EndIf
			EndIf

		EndIf


		IF (Len(aColsGrid) <= 0)
			aColsGrid := { {.F.,"","",""} }

			if (!lForce)
				MsgInfo(STR0042) //"Nใo encontrado nenhum item para sugerir."
			EndIf
		EndIf

//atualiza a variแvel que representa o alias selecionado na hora da busca
		cAliasAtua := cCBAlias

		oBrowseRight:SetArray(aColsGrid)
		oBrowseRight:bLine := {||{If(aColsGrid[oBrowseRight:nAt,01],oOK,oNO),aColsGrid[oBrowseRight:nAt,02],aColsGrid[oBrowseRight:nAt,03],aColsGrid[oBrowseRight:nAt,04] } }
		//oBrowseRight:Refresh()

		if (lForce)
//			oBrowseLeft:nAt := 1
//			oBrowseLeft:SetChange({ || Processa( {|| PLAtuSuges()}, "Aguarde..", "Buscando sugest๕es...")})
			oBrowseLeft:CleanFilter()
			oBrowseLeft:SetFilterDefault("BTQ_FILIAL = '"+xFilial("BTQ")+"' .AND. BTQ_CODTAB = '"+BTP->BTP_CODTAB+"'" + IIF(lCheckVin == .F., " .AND. BTQ_HASVIN = '0'",''))
			oBrowseLeft:Refresh()
		EndIf
		BTQ->(DbGoTo(nRecnoBk))
		oBrowseLeft:nAt := nAtBk
		If(!lForce)
			oBrowseLeft:Refresh()
		EndIf
	Else
		lRet := .F.
	EndIf
Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLDParObrgบ Autor ณ                    บ Data ณ  19/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica o preenchimento dos campos obrigat๓rios para      บฑฑ
ฑฑบ          ณrealizar o De-Para.   								           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lForce == .T. significa que ้ para forcar a atualiza็ao    บฑฑ
ฑฑบ          ณ e nao mostrar mensagem de obrigatoriedade, por้m tamb้m    บฑฑ
ฑฑบ          ณ nใo realizarแ a atualiza็ao                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLDParObrg(lForce)
	Local lRet := .T.

	If Empty(AllTrim(cCod))
		if (!lForce)
			MsgInfo(STR0040) //"Campo C๓digo Tab. Protheus obrigat๓rio."
		EndIf
		lRet := .F.
	ElseIf (Empty(AllTrim(cDesc)))
		if (!lForce)
			MsgInfo(STR0041) //"Campo Descri็ใo Tab. Protheus obrigat๓rio."
		EndIf
		lRet := .F.
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PL444TREEบ Autor ณ                    บ Data ณ  19/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ 													    	 บฑฑ
ฑฑบ          ณ                     									       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PL444TREE()

	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oTreeTab 	:= Nil
	Local nOpcI		:= 2
	Local cTexto		:= ""
	Local nNvlAtu 	:= 0
	Local nNvlAnt		:= 0
	Local nCdGrAtu	:= 0
	Local nCdGrAnt 	:= 0
	Local aa 			:= 1
	Local aRetorno  := {}



	Define MsDialog oDlgIND Title "Itens do Layout" From aCoors[1]/2, aCoors[2]/2 To aCoors[3]/2, aCoors[4]/2 Pixel
//DEFINE MSDIALOG oDlgIND FROM 62,100 TO 800,800 TITLE "Itens do Layout" PIXEL //"Titulo da tela"

	Define  FONT oFont NAME "Arial,12," BOLD

	oScr := TScrollBox():Create(oDlgIND,01,01,350,350,.T.,.T.,.T.)

	DEFINE DBTREE oTreeTab FROM 01, 01 TO 5000, 5000 CARGO OF oScr Pixel
//Adiciona a tree apenas as tabelas que estใo "abaixo" na ordem


	DbSelectArea("GG3")
	GG3->(DbSetOrder(1))
	DbSelectArea("GG1")
	GG1->(DbSetOrder(1))
	DbSelectArea("GG0")
	GG0->(DbSetOrder(1))

	If Fs_ProTela()
		DBADDTREE oTreeTab PROMPT PADR(GG2->GG2_DESCRI,100) RESOURCE "PRODUTO" CARGO PADR("Tabelas",100)

		If GG3->(MsSeek(xFilial("GG3")+GG2->GG2_CODPAR)) .AND. GG0->(MsSeek(xFilial("GG0")+GG3->GG3_CODGRU)) .AND. GG1->(MsSeek(xFilial("GG1")+GG3->GG3_CODGRU))

			While GG3->(!Eof()) .AND. GG3->(GG3_FILIAL+GG3_CODPAR) = xFilial("GG3")+GG2->GG2_CODPAR
				GG0->(MsSeek(xFilial("GG0")+GG3->GG3_CODGRU))
				GG1->(MsSeek(xFilial("GG1")+GG3->GG3_CODGRU))

				While GG1->(!Eof()) .AND. GG1->(GG1_FILIAL+GG1_CODGRU) == xFilial("GG1")+GG3->GG3_CODGRU
					nNvlAtu 	:= val(GG1->GG1_NNIVEL)
					nCdGrAtu	:= val(GG1->GG1_CODGRU)

					If (nNvlAtu < nNvlAnt)
						For aa := 1 to nNvlAnt-nNvlAtu
							DBENDTREE oTreeTab
						Next aa
					EndIf

					IF (Empty(GG1->GG1_COLUNA))
						DBADDTREE oTreeTab PROMPT PADR(GG1->GG1_FUNEXP + ' - ' , 100) RESOURCE "PRODUTO" CARGO PADR(GG1->(RECNO()),100)
					Else
						DBADDITEM oTreeTab PROMPT PADR(Alltrim(GG1->GG1_COLUNA) ,100)   RESOURCE "BR_WHITE" CARGO PADR(GG1->(RECNO()),100)
					EndIf

					nNvlAnt 	:= val(GG1->GG1_NNIVEL)
					nCdGrAnt	:= val(GG1->GG1_CODGRU)
					GG1->(DbSkip())
				EndDo

				DBENDTREE oTreeTab
				GG3->(DbSkip())
			EndDo

			DBENDTREE oTreeTab
		EndIf
	EndIf


	oTreeTab:BLDblClick := {|| aAdd(aRetorno, StrTran(StrTran(oTreeTab:GetPrompt(.T.),"ans:", "", ,  ), '"', "", ,  ) ), aAdd(aRetorno,PL444PATH(oTreeTab:GetCargo())  ), oDlgIND:End() }


	DEFINE SBUTTON FROM 355,155 TYPE 1 ACTION {|| nOpcI := 1, cTexto := oTreeTab:GetPrompt(.T.), oDlgIND:End()} ENABLE OF oDlgIND//Ok
	DEFINE SBUTTON FROM 355,195 TYPE 2 ACTION {|| nOpcI := 2, oDlgIND:End()} ENABLE OF oDlgIND	//Cancelar

	ACTIVATE MSDIALOG oDlgIND CENTERED


Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFs_ProTelaบAutor  ณMicrosiga        บ Data ณ  12/26/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Fs_ProTela()
	Local aArea    	:= 	GetArea()
	Local aHGG2    	:= 	{}
	Local aCGG2    	:= 	{}
	Local nOpcA    	:= 	0
	Local oGG2
	Local lStatus		:= .F.
//	Local nFor     	:= 	0
	Local nUGG2   	:= 	0
//	Local nUBOB    	:= 	0
//	Local cSql     	:= 	""
	Local cCond		:=	""
//	Local cCdProgram:=	""
//	lOCAL cLstEsp	:=	""
//	LOCAL nI		:=	0
//	LOCAL lFilVir	:=	.T.
//	LOCAL cRisco	:=	""
//	Private oBOB
//	Private aHBOB   := {}
//	Private aCBOB   := {}

	cCond:=" GG2_TIPARQ = '3' "

	Cond:=" GG2_TIPARQ = '3' "
	//Function HS_BDados(cAlias, aHDados, aCDados, nUDados, nOrd, lFilial, cCond, lStatus, cCpoLeg, cLstCpo, cElimina, cCpoNao, cStaReg, cCpoMar, cMarDef, lLstCpo, aLeg, lEliSql, lOrderBy, cCposGrpBy, cGroupBy, aCposIni, aJoin, aCposCalc, cOrderBy, aCposVis, aCposAlt, cCpoFilial, aCposFim)
	nUGG2 := (HS_BDados("GG2", @aHGG2, @aCGG2,, 1,, cCond,,,,,,,"GG2_IDMARC","GG2_CODPAR"))
	nGG2IDMARC := aScan(aHGG2, {| aVet | aVet[2] == "GG2_IDMARC"})
	nGG2CODPAR := aScan(aHGG2, {| aVet | aVet[2] == "GG2_CODPAR"})

	If nUGG2==0
	MsgInfo("Nใo hเ registros na tabela GG2 - Cabecalho Layout")
	Return(lStatus)
	Endif

	aSize    := MsAdvSize(.T.)
	aObjects := {}

	aAdd( aObjects, { 100, 030, .T., .T.} )

	aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObjs := MsObjSize( aInfo, aObjects, .T. )

	nOpcA := 0
	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Layouts") From aSize[7], 000 To aSize[6]/2, aSize[5]/2	PIXEL Of oMainWnd

	oGG2 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4],,,,,,,,,,,, aHGG2, aCGG2)

	oGG2:oBrowse:Align :=  CONTROL_ALIGN_TOP
//oGG2:oBrowse:BlDblClick := {|| FS_DblClik(oGG2)}


	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1,  oDlg:End()}, ;
		{|| nOpcA := 0, oDlg:End()})
	If nOpcA == 1

		DbSelectArea("GG2")
		GG2->(DbSetOrder(1))
		GG2->(MsSeek(xFilial("GG2")+oGG2:aCols[oGG2:nAt,1]))

	EndIf

	RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PL444PATHบ Autor ณ                    บ Data ณ  19/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ 													               บฑฑ
ฑฑบ          ณ                     								           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PL444PATH(nRecno)
	Local cCaminho	:= ""
	Local cNivel	:= ""
	Default nRecno := ""

//Protege a fun็ใo
	If !Empty(val(nRecno))
	//Posiciona no registro
		GG1->(DbGoto(val(nRecno))) //Nใo lembro se ้ texto ou num้rico
	//Guarda o nํvel
		cNivel := GG1->GG1_NNIVEL
		cGrupo := GG1->GG1_CODGRU

	//Percorremos a arvore, subindo os nํveis at้ chegar no come็o do arquivo ou no nivel 00
		Do While !GG1->(Bof()) .AND. cGrupo == GG1->(GG1_CODGRUPO) .AND. cNivel > "00" //V๊ se precisa colocar filial e de onde vai vir esse cGrupo
		//Verifica se ้ nํvel superior
			If GG1->GG1_NNIVEL < cNivel
			//Incrementamos o caminho
				cCaminho := P444ADDPAT(cCaminho, Iif (Empty(GG1->GG1_COLUNA), GG1->GG1_FUNEXP, GG1->GG1_COLUNA), GG1->GG1_NNIVEL)

			//Guarda o nํvel que acabamos de encontrar
				cNivel := GG1->GG1_NNIVEL
			EndIf
			GG1->(DbSkip(-1))

			cGrupo := GG1->GG1_CODGRU
		EndDo
	EndIf
Return "\" + cCaminho

Function P444ADDPAT(cCaminho, cAddCaminh, cNivel)
	Local cCamAux := Alltrim(StrTran(StrTran(cAddCaminh,"ans:", "", , ), '"', "", , ))

	If (cNivel == "00")
		if (At("<", cCamAux) > 0 .And. At(" ", cCamAux) > 0)
			cCamAux := SubStr(cCamAux, At("<", cCamAux)+1, At(" ", cCamAux) - At("<", cCamAux)-1)
		EndIF
	EndIF

	cCaminho := cCamAux + Iif(Empty(AllTrim(cCaminho)), "", "\") + cCaminho

Return cCaminho


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PL444FIELDบ Autor ณ BERNARDO ANDRษIA  บ Data ณ  05/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Array com o c๓digo e descri็ใo	da Tab Protheus              บฑฑ
ฑฑบ          ณ                     								           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PL444FIELD()

	Local aCampos   := {}
	Local nCount := 0

	// Vinculo tiss para Plano de Sa๚de
	
	aAdd(aCampos, {"B04"	, "B04_CODIGO"	, "B04_DESCRI"		}) // "28"
	aAdd(aCampos, {"B09"	, "B09_FADENT"	, "B09_FACDES"		}) // "32"
	aAdd(aCampos, {"B0X"	, "B0X_CODCBO"	, "B0X_DESCBO"		}) // "24"
	aAdd(aCampos, {"BAH"	, "BAH_CODIGO"	, "BAH_DESCRI"		}) // "26"
	aAdd(aCampos, {"BAU"	, "BAU_CODIGO"	, "BAU_NOME"		}) //  NรO ษ NECESSARIO CADASTRO DE REDES REFERENCIADAS
	aAdd(aCampos, {"BCT"	, "BCT_CODGLO"	, "BCT_DESCRI"		}) // "38"
	aAdd(aCampos, {"BDR"	, "BDR_CODTAD"	, "BDR_DESCRI"		}) // "23"
	aAdd(aCampos, {"BGR"	, "BGR_CODVIA"	, "BGR_VIATIS"		}) // "61"
	aAdd(aCampos, {"BI4"	, "BI4_CODACO"	, "BI4_DESCRI"		}) // "49"
	aAdd(aCampos, {"BIY"	, "BIY_CODSAI"	, "BIY_DESCRI"		}) // "39"
	aAdd(aCampos, {"BK6"	, "BK6_CODIGO"	, "BK6_NOME"		}) //  NรO ษ NECESSARIO CADASTRO DE REDES NรO REFERENCIADAS
	aAdd(aCampos, {"BLR"	, "BLR_CODLAN"	, "BLR_DESCRI"		}) // "27"
	aAdd(aCampos, {"BQR"	, "BQR_TIPINT"	, "BQR_DESTIP"		}) // "41" "57"
	aAdd(aCampos, {"BR4"	, "BR4_CODPAD"	, "BR4_DESCRI"		}) // "87" "25"
	aAdd(aCampos, {"BR8"	, "BR8_CODPSA"	, "BR8_DESCRI"		}) // "01" "02" "03" "04" "05" "06" "07" "08" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "94" "95" "96" "97" "98" "99"
	aAdd(aCampos, {"BWT"	, "BWT_CODPAR"	, "BWT_DESCRI"		}) // "35"
	aAdd(aCampos, {"BAQ"	, "BAQ_CODESP"	, "BAQ_DESCRI"		}) // "24"
	aAdd(aCampos, {"BQL"	, "BQL_CODIGO"	, "BQL_DESCRI"		}) // "34"
	aAdd(aCampos, {"BI5"	, "BI5_CODRED"	, "BI5_DESCRI"		}) // "40" 
	aAdd(aCampos, {"BJE"	, "BJE_CODIGO"	, "BJE_DESCRI"		}) // "63" 
	aAdd(aCampos, {"BRW"	, "BRW_CODROL"	, "BRW_DESROL"		}) // "09"
	aAdd(aCampos, {"BD3"	, "BD3_CODIGO"	, "BD3_DESCRI"		}) // "60" 
	
	// Vinculo tiss para tabelas de outros Modulos
	
	aAdd(aCampos, {"SX5"	, "X5_TABELA"	 	, "X5_DESCRI"		}) // "57"
	aAdd(aCampos, {"SAH"	, "AH_UNIMED" 		, "AH_DESCPO"		}) // "60" USADO NO GH
	aAdd(aCampos, {"SB1"	, "B1_COD"	  		, "B1_DESC"			}) // "20" PODE SER UTILIZADA NO GH PARA PRODUTOS FARMACIA 
	
	// Vinculo tiss para Gestใo Hospitalar
	
	aAdd(aCampos, {"GD0"	, "GD0_ORIPAC"	, "GD0_DORIPA"	}) // "40"
	aAdd(aCampos, {"GMC"	, "GMC_CODATO"	, "GMC_DESATO"	}) // "35"
	aAdd(aCampos, {"GAA"	, "GAA_CODTXD"	, "GAA_DESC"    }) // "18"
	aAdd(aCampos, {"G24"	, "G24_CODIGO"	, "G24_DESCRI"	}) // "05"
	aAdd(aCampos, {"GCW"	, "GCW_CODCLI"	, "GCW_DESCLI"	}) // "57"
	aAdd(aCampos, {"GD1"	, "GD1_CARATE"	, "GD1_DCARAT"	}) // "23"
	aAdd(aCampos, {"GN1"	, "GN1_CODCBO"	, "GN1_DESCBO"	}) // "24"
	aAdd(aCampos, {"G05"	, "G05_CODIGO"	, "G05_DESCRI"	}) 
	aAdd(aCampos, {"G08"	, "G08_CODIGO"	, "G08_DESCRI"	}) // "50"
	aAdd(aCampos, {"GE4"	, "GE4_CODVIA"	, "GE4_DESVIA"	}) // "61"
	aAdd(aCampos, {"GCA"	, "GCA_CODTAB"	, "GCA_DESCRI"	}) // "87"
	aAdd(aCampos, {"GD2"	, "GD2_CODTAB"	, "GD2_DESCRI"	}) // "87"
	aAdd(aCampos, {"GDB"	, "GDB_CHAVE" 	, "GDB_DESCRI"	}) // "87" 
	aAdd(aCampos, {"GA7"	, "GA7_CODPRO"	, "GA7_DESC"  	}) // "22"
	aAdd(aCampos, {"G20"	, "G20_CODIGO"	, "G20_DESCRI"	}) // "25"
	aAdd(aCampos, {"GF4"	, "GF4_TPALTA"	, "GF4_DSTPAL"	}) // "39" 
	aAdd(aCampos, {"G12"	, "G12_CODIGO"	, "G12_CODIGO"	}) // "52"
	
	// TABELAS PARA VERIFICAR COM O ROGEIRO
	aAdd(aCampos, {"GAV"	, "GAV_TATISS"	, "GAV_DTATIS"	}) // "49" - TIPO DE ACOMODAวรO 	GAV
	aAdd(aCampos, {"GFX"	, "GFX_CDFORA"	, "GFX_DSFORA"	}) // "62" - TIPO DE ADMINISTRAวรO 	GFX 
	aAdd(aCampos, {"GFW"	, "GFW_CODVIA"	, "GFW_DESVIA"	}) // "61" - TIPO DE VIA DE ACESSO 	GFW 

	nCount := aScan(aCampos,{|x| x[1]== cCBAlias})

	If nCount > 0

		If Empty(cCod) .AND. Empty(cCod)
			cCod := aCampos[nCount][2]
			cDesc := aCampos[nCount][3]
		EndIf

		If aCampos[nCount][2] <> cCod .AND. SUBSTR(aCampos[nCount][2], 1, 3) <> SUBSTR(cCod, 1, 3)
			cCod := aCampos[nCount][2]

			If aCampos[nCount][3] <> cDesc .AND. SUBSTR(aCampos[nCount][2], 1, 3) <> SUBSTR(cDesc, 1, 3)
				cDesc := aCampos[nCount][3]

			EndIf
		EndIf
	Else
		cCod := SPACE(10)
		cDesc := SPACE(10)
	EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLBlqCmp  บ Autor ณ Everton M. Fernandes Data ณ  05/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใoo ณ Bloqueia os campos da consulta                  			บฑฑ
ฑฑบ          ณ                     								           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PLBlqCmp(lBlq,aCampos)
	LOCAL nI := 1
	LOCAL nLen

	Default aCampos := {}

	nLen := Len(aCampos)
	For nI := 1 to nLen
		aCampos[nI]:lActive := lBlq
	Next nI

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLKEY	  บ Autor ณ Bernardo A. Data 			ณ  22/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใoo ณ Busca chave para label de/para		             			บฑฑ
ฑฑบ          ณ                     								           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PLKEY()
Local cVar := ''

If Empty(cCBAlias)
Return cVar
Else
	If (cCBAlias == BTP->BTP_ALIAS)
		cVar := BTP->BTP_CHVTAB
	Else
		DbSelectArea("BVL")
		BVL->(DbSetOrder(2))//BVL_FILIAL+BVL_ALIAS+BVL_CODTAB
		If BVL->(MsSeek(xFilial("BVL")+cCBAlias+BTP->BTP_CODTAB))
			cVar := BVL->BVL_CHVTAB
		EndIf
	EndIf
EndIf

Return cVar

/*Procura um registro para evitar chave duplicada*/
Static Function PlsBusBTU(cCodTab,cVlrSis,cVlrBus,cCdTerm,cCodAli)
Local nReturn := 0
Local cSql := "SELECT COUNT(1) QTDE FROM " + RetSqlName("BTU") + " WHERE BTU_FILIAL = '" + xFilial("BTU") + "' "
	cSql += " AND BTU_CODTAB = '"+cCodTab+"' AND BTU_VLRSIS = '"+cVlrSis+"' AND BTU_VLRBUS = '"+cVlrBus+"' AND BTU_CDTERM = '"+cCdTerm+"' AND BTU_ALIAS = '"+cCodAli+"' "
	cSql += " AND D_E_L_E_T_ <> '*'"
Default cCodTab := ""
Default cVlrSis := ""
Default cVlrBus := ""
Default cCdTerm := ""
Default cCodAli := ""

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

If !TRB1->(Eof())
	nReturn := TRB1->QTDE
EndIf

TRB1->(DbCloseArea())

Return nReturn


/*/{Protheus.doc} PL444VLD
Efetua o cแlculo da แrea de alguns quadrilแteros.
@type function
@author Victor Ferreira
@since 24/04/2015
@param cCampo, caracter, Campo a ser validado
@return lRet, l๓gico, Retorno da valida็ใo
/*/
Function PL444VLD(cCampo)
Local lRet		:= .T.
Local cValue 	:= &(ReadVar())

Do Case
Case cCampo == "BVL_ALIAS"
	DbSelectArea("SX2")
	SX2->(DbSetOrder(1))
	If !SX2->(MsSeek(cValue))
		lRet := .F.
	EndIf
EndCase

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSA444REC 
Baixa as terminologias atualizadas da TISS

@author    Lucas Nonato
@version   V12
@since     20/12/2019
/*/
function PLSA444REC(lAuto,cVerAtual)
local aUrlPath := Separa(getNewPar("MV_PLURTIS", "https://arte.engpro.totvs.com.br,/public/sigapls/TISS/"), ",")
local cURL    	:= ""
local cPath   	:= ""
local aTerm   	:= {}
local aMatCol  	:= {}                              
local cRet		:= ""     
local nX 		:= 0                               
local lOk 		:= .f.
local lAll 		:= .f.
local cDirRaiz	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\") )
local cDirTerm 	:= PLSMUDSIS( cDirRaiz+"TERMINOLOGIAS\" )
local cArquivo	:= ""
local lRetTar	:= .F.
local aRetArq	:= {}
local aDemais	:= {}
local cCodigo	:= ""
local lEscolha	:= .f. //Garante que ao menos uma op็ใo foi escolhida
local lExsProc	:= ( !isBlind() .and. IsInCallStack("PLSA447") )
private oProcess as object                            

default lAuto := .f.
default cVerAtual := "3.05.00"

if len(aUrlPath) == 2 .and. !empty(aUrlPath[1]) .and. !empty(aUrlPath[2])
	cURL	:= aUrlPath[1]
	cPath	:= aUrlPath[2]+"Terminologias/"
else
	cRet := "O parโmetro MV_PLURTIS estแ vazio na base." + CRLF + "Preencha o valor do parโmetro, conforme documenta็ใo da rotina."
	if !lAuto
		MsgInfo(cRet, "Aten็ใo")		
	endif
	return cRet
endif

if !existDir(cDirTerm)
	if makeDir(cDirTerm) != 0
		cRet := "Nใo foi possivel criar o diretorio " + cDirTerm
		if !lAuto
			msgInfo(cRet,"Erro")
		Endif
		return cRet
	endif  
endif 

cArquivo 	:= "padraotissterminologias.tar"
MsgRun ( "Aguarde, os arquivos estใo sendo baixados" , "Processando", { || lRetTar := PLSGETZIP(cURL,cPath,cDirTerm,cArquivo) } )

if lRetTar

	if lAuto .or. msgYesNo( "Deseja importar todas as terminologias?" ) 
		lOk 	:= .t.
		lAll 	:= .t.		

	elseif !lAuto
		aAdd( aMatCol,{"C๓digo"			,'@!',020} )
		aAdd( aMatCol,{"Terminologia"	,'@!',200} )
		//Dispondo as possibilidades da mesma maneira que a TISS organiza os arquivos -> 18/19/20/22/64/Demais Terminologias
		aadd(aTerm,{"18","DIARIAS, TAXAS E GASES MEDICINAIS"								,.f.})
		aadd(aTerm,{"19","MATERIAIS E ORTESES, PROTESES E MATERIAIS ESPECIAIS (OPME)"		,.f.})
		aadd(aTerm,{"20","MEDICAMENTOS"														,.f.})
		aadd(aTerm,{"22","PROCEDIMENTOS E EVENTOS EM SAUDE"									,.f.})
		aadd(aTerm,{"64","FORMA DE ENVIO DE PROCEDIMENTOS E ITENS ASSISTENCIAIS PARA ANS"	,.f.})
		aadd(aTerm,{"--","DEMAIS TERMINOLOGIAS"												,.f.})

		While !lEscolha
			lOk := PLSSELOPT( "Selecione o(s) arquivos(s) a serem importados", "Marca e Desmarca todos", aTerm, aMatCol,,.T.,.T.,.F.)		
			for nX:=1 To Len(aTerm)
				lEscolha := iif(aTerm[nX][3]==.t.,.t.,lEscolha)
			Next
			If !lEscolha
				msgInfo("Ao menos uma op็ใo deve ser selecionada.","Aviso")
			Endif
		endDo

		//Exclui Terminologias conforme o que foi escolhido pelo user
		For nX:=1 to (len(aTerm)-1)
			If !aTerm[nX][3]
				aRetArq := PLSDELARQ(cDirTerm,"Tab"+aTerm[nX][1]+".csv") //Caso o arquivo nใo seja encontrado, ้ retornado o erro mas o processamento nใo para.
			Endif
		Next

		//Exclui as demais Terminologias, caso seja a op็ใo selecionada (representada pela flag aTerm[6][3])
		If !aTerm[6][3]
			aDemais := (Directory(cDirTerm + '\*.csv'))
			For nX:=1 To Len(aDemais)
				cCodigo := SUBSTR(aDemais[nX][1],4,2)
				If cCodigo != "18" .and. cCodigo != "19" .and. cCodigo != "20" .and. cCodigo != "22" .and. cCodigo != "64"
					aRetArq := PLSDELARQ(cDirTerm,"Tab"+cCodigo+".csv") //Caso o arquivo nใo seja encontrado, ้ retornado o erro mas o processamento nใo para.
				Endif
			Next
		Endif
	
	Endif
	
	if lOk		
		cIni := time()
		if !lAuto .or. lExsProc
			oProcess := MsNewProcess():New( { || cRet := PLSIMPTERM(cDirTerm,cVerAtual) } , "Processando" , "Aguarde..." , .f. )
			oProcess:Activate()
		else
			cRet := PLSIMPTERM(cDirTerm,cVerAtual)
		endif
		cFim := time()
		if !lAuto
			Aviso( "Resumo","Processamento finalizado. " + CRLF + 'Inicio: ' + cvaltochar( cIni ) + "  -  " + 'Fim: ' + cvaltochar( cFim ) ,{ "Ok" }, 2 )
		endif
		cRet := iif( empty(cRet), "Importa็ใo finalizada. " + 'Inicio: ' + cvaltochar( cIni ) + "  -  " + 'Fim: ' + cvaltochar( cFim )+".", cRet)
	Else
		cRet := "Houve um erro no processamento."
		if !lAuto
			msgInfo(cRet)
		endif
	Endif
	
	aRetLimp := PLSLIMPDIR(cDirTerm)
	If !aRetLimp[1]
		cRet := cRet+" Nใo foi possํvel deletar os arquivos da pasta '\tiss\terminologias."
		If !lAuto
			msgInfo("Nใo foi possํvel deletar os arquivos da pasta '\tiss\terminologias.","Aviso")
		Endif
	Endif

else

	cRet := "Nใo foi possivel realizar o download do arquivo: " + cArquivo + ". Tente a importa็ใo dos arquivos de forma manual, confome documento de refer๊ncia 'Padrใo TISS - Como atualizar sua versใo'."
	If !lAuto
		msgInfo(cRet,"Erro")
	Endif
	
endif

If lAuto
	return cRet
Else
	return
Endif
