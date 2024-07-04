#include "VDFA030.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFA030
Cadastro de Candidato x Concurso / Controle de Requisitos.
@author		Everson S P Junior
@since		19/08/2013
@version	P11.8
@sample 	VDFA030()
/*/
//------------------------------------------------------------------------------
Function VDFA030()
Local oBrowse

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'REW' )
	oBrowse:SetDescription(STR0001) //'Manutenção Concurso/Funções/Requesitos'
	oBrowse:DisableDetails()
	oBrowse:Activate()

Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Incluindo opção no Menu do browse.
@author		Everson S P Junior
@since		15/08/2013
@version	P11.8
@sample 	MenuDef()
@return		aRotina, array, lista das opções de menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina Title STR0002  Action 'VIEWDEF.VDFA030' OPERATION 2 ACCESS 0//'Visualizar'
	ADD OPTION aRotina Title STR0003  Action 'VIEWDEF.VDFA030' OPERATION 4 ACCESS 0//'Manutenção'
	ADD OPTION aRotina Title STR0004  Action 'VIEWDEF.VDFA030' OPERATION 5 ACCESS 0//'Excluir'

Return aRotina


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cria a estrutura a ser usada no Modelo de Dados.
@author		Everson S P Junior
@since		15/08/2013
@version	P11.8
@sample 	ModelDef()
@return		oModel, objeto, Retorna o Modelo de dados 

/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruREW := FWFormStruct( 1, 'REW', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruRI7 := FWFormStruct( 1, 'RI7', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruREX := FWFormStruct( 1, 'REX', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

	bCpoInit1 := {|| oModel:GetValue("REWMASTER", "REW_CODIGO") } 
	oStruRI7:SetProperty('RI7_CODCON', MODEL_FIELD_INIT, bCpoInit1 )

	//passa para o campo não obrigatorio.
	oStruRI7:SetProperty('RI7_CODCON',    MODEL_FIELD_OBRIGAT, .F. )
	oStruREX:SetProperty('REX_FILFUN',    MODEL_FIELD_OBRIGAT, .F. )
	oStruREX:SetProperty('REX_CODCON',    MODEL_FIELD_OBRIGAT, .F. )
	oStruREX:SetProperty('REX_CODFUN',    MODEL_FIELD_OBRIGAT, .F. )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('VDFA030MODEL', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'REWMASTER', /*cOwner*/, oStruREW )

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'RI7DETAIL', 'REWMASTER', oStruRI7, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'REXDETAIL', 'RI7DETAIL', oStruREX, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relaciomaneto entre os compomentes do model 
	oModel:SetRelation( 'RI7DETAIL', { { 'RI7_FILIAL', 'FWxFilial( "RI7",REW->REW_FILIAL )' }, { 'RI7_CODCON', 'REW_CODIGO' } }, RI7->(IndexKey( 1 ) ) )
	oModel:SetRelation( 'REXDETAIL', { { 'REX_FILIAL', 'FWxFilial( "REX",REW->REW_FILIAL )' }, { 'REX_CODCON', 'RI7_CODCON' }, { 'REX_FILFUN', 'RI7_FILFUN' }, { 'REX_CODFUN', 'RI7_CODFUN' }} , REX->( IndexKey( 1 ) ) )

	oModel:SetPrimaryKey( { "REW_FILIAL", "REW_CODIGO" } ) //Concursos

	// Liga o controle de nao repeticao de linha        
	oModel:GetModel( 'RI7DETAIL' ):SetUniqueLine( { 'RI7_FILFUN','RI7_CODFUN' } )
	oModel:GetModel( 'REXDETAIL' ):SetUniqueLine( { 'REX_CODREQ' } )

	// Indica que é opcional ter dados informados na Grid
	oModel:GetModel( 'RI7DETAIL' ):SetOptional(.T.) 

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0005 )//'Manutenção de Concursos/Funções/Requesitos'

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'REWMASTER' ):SetDescription( STR0006)//'Dados do Concurso'
	oModel:GetModel( 'RI7DETAIL' ):SetDescription( STR0007)//'Funções do Concurso'
	oModel:GetModel( 'REXDETAIL' ):SetDescription( STR0008  )//'Requisitos do Concurso/Função'

	//Permissão de grid sem dados
	oModel:GetModel( 'REXDETAIL' ):SetOptional( .T. )

	//Não permite alterar as linhas do grid.
	oModel:GetModel( 'RI7DETAIL' ):SetNoDeleteLine( .F. )

Return oModel


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado.
@author		Everson S P Junior
@since		15/08/2013
@version	P11.8
@sample 	ViewDef()
@return		oView, obejto, Retorna o objeto de View criado 
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oStruREW := FWFormStruct( 2, 'REW' )
Local oStruRI7 := FWFormStruct( 2, 'RI7' )
Local oStruREX := FWFormStruct( 2, 'REX' ) 

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'VDFA030' )
Local oView
Local nOper   := ALTERA

	//Remove campos da struct
	oStruRI7:RemoveField( 'RI7_CODCON')
	oStruRI7:RemoveField( 'RI7_DESCON')
	oStruREX:RemoveField( 'REX_CODCON')
	oStruREX:RemoveField( 'REX_DESCON')
	oStruREX:RemoveField( 'REX_FILFUN')
	oStruREX:RemoveField( 'REX_CODFUN')
	oStruREX:RemoveField( 'REX_DESFUN')

	//Deixa o campo  visual.
	oStruREW:SetProperty('REW_CODIGO', MVC_VIEW_CANCHANGE  ,.F.)

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_REW', oStruREW, 'REWMASTER' )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid(  'VIEW_RI7',  oStruRI7,  'RI7DETAIL' )
	oView:AddGrid(  'VIEW_REX',  oStruREX,  'REXDETAIL' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR',  20 )
	oView:CreateHorizontalBox( 'INFERIOR1', 40 )
	oView:CreateHorizontalBox( 'INFERIOR2', 40 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_REW', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_RI7', 'INFERIOR1')
	oView:SetOwnerView( 'VIEW_REX', 'INFERIOR2')

	// Liga a identificacao do componente
	oView:EnableTitleView( 'VIEW_REW' )
	oView:EnableTitleView( 'VIEW_RI7' )
	oView:EnableTitleView( 'VIEW_REX' )

	oView:SetCloseOnOk({ || .T. }) //Não exibe o botão "Salvar e Criar Novo"

Return oView 


//------------------------------------------------------------------------------
/*/{Protheus.doc} fVldRI7Fun
Valida preenchimento do campo RI7_CODFUN
@author		esther.viveiro
@since		02/10/2018
@version	P12
@return		lRet, lógico, resultado da validação 
/*/
//------------------------------------------------------------------------------
Function fVldRI7Fun()
Local oModel	:= FWModelActive()
Local cFilFun	:= oModel:GetModel( 'RI7DETAIL' ):GetValue('RI7_FILFUN')
Local lRet		:= .T.

	If !Empty(xFilial("SRJ")) .AND. Empty(cFilFun)
		//"Preencha o campo Filial da Função para selecionar uma função para o curso."###"Atenção!"
		MsgAlert(OemToAnsi( STR0010 ),OemToAnsi( STR0011 ))
		lRet = .F.
	Else
		DbSelectArea("SRJ")
		SRJ->(DbSetOrder(RetOrder("SRJ","RJ_FILIAL+RJ_FUNCAO")))
		SRJ->(DbGoTop())
		lRet := SRJ->(DbSeek(cFilFun+M->RI7_CODFUN))
	EndIf

	lRet := fVldCargo()

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} function fVldCargo
Realiza a validação da categoria da Função
@author  oliveira.hugo
@since   18/03/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function fVldCargo()
	Local lRet		:= .T.
	Local oModel	:= FWModelActive()
	Local cFilial	:= oModel:GetModel( 'RI7DETAIL' ):GetValue('RI7_FILFUN')

	DbSelectArea("SRJ")
	SRJ->(DbSetOrder(RetOrder("SRJ","RJ_FILIAL+RJ_FUNCAO")))
	SRJ->(DbGoTop())
	
	IF (SRJ->(DbSeek(cFilial+M->RI7_CODFUN)))
		DbSelectArea("SQ3")
		SQ3->(DbSetOrder(RetOrder("SQ3","Q3_FILIAL+Q3_CARGO")))
		SQ3->(DbGoTop())

		IF (SQ3->(DbSeek(cFilial+SRJ->RJ_CARGO)))
			IF !(SQ3->Q3_CATEG $ "0|2|E|G")
				MsgAlert(STR0013 + CRLF + CRLF ;  // "A categoria utilizada no cargo da funçao não faz parte do processo de concurso."
				+ STR0014 + SRJ->RJ_FUNCAO + " - " + SRJ->RJ_DESC + CRLF  ;   // "Função: " + Função + Descrição
				+ STR0015 + SRJ->RJ_CARGO + " - " +  SQ3->Q3_DESCSUM + CRLF ; // "Cargo: "  + Cargo + Descrição
				+ STR0016 + SQ3->Q3_CATEG)									  // "Categoria: " + Categoria
				lRet := .F.
			ENDIF
		ENDIF
	ENDIF
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} fVldFilFun
Valida preenchimento do campo _FILFUN
@author		esther.viveiro
@since		02/10/2018
@version	P12
@return		lRet, lógico, resultado da validação 
/*/
//------------------------------------------------------------------------------
Function fVldFilFun()
Local oModel	:= FWModelActive()
Local cFilFun	:= ''
Local lRet		:= .T.

	cFilFun := xFilial("SRJ",oModel:GetModel("RI7DETAIL"):GETVALUE("RI7_FILFUN"))

	If !(xFilial("REW",oModel:GetModel("RI7DETAIL"):GETVALUE("RI7_FILFUN")) == oModel:GetModel("REWMASTER"):GETVALUE("REW_FILIAL"))
		lRet := .F. //somente permito escolher filiais, para as funções, que estão dentro do compartilhamento da tabela de Concursos (REW)
	EndIf

	If lRet .AND. !( AllTrim(CFILFUN) $ fValidFil() )
		MsgAlert(OemToansi(STR0012) ,  OemToAnsi( STR0011 ) ) //Usuario sem acesso a filial escolhida. Favor escolher outra filial.###Atencao
		lRet := .F.
	Else 
		SRJ->(DbSetOrder(RetOrder("SRJ","RJ_FILIAL+RJ_FUNCAO")))
		SRJ->(DbGoTop())
		If !(SRJ->(DbSeek(cFilFun)))
			lRet := .F.
		Else
			oModel:GetModel( 'RI7DETAIL' ):SetValue('RI7_FILFUN',cFilFun)
		EndIf
	EndIf

Return lRet
