#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA304.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} FISA304
Cadastro MVC para atender o cadastro de codigos de enquadramentos de IPI

@author Erich Buttner
@since 27.05.2020
@version P11

/*/
//-------------------------------------------------------------------
Function FISA304()

	Local   oBrowse := Nil
	Local 	 aArea   := GetArea()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("F08")
    oBrowse:SetDescription(STR0007)
	oBrowse:Activate()
			
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Erich Buttner
@since 27.05.2020
@version P11

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

	Local aRotina := {}
	
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.FISA304' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA304' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA304' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA304' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA304' OPERATION 9 ACCESS 0 //'Copiar'
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Erich Buttner
@since 27.05.2020
@version P11

/*/
//-------------------------------------------------------------------

Static Function ModelDef()
	//Criação do objeto do modelo de dados
	Local oModel	:= Nil
	
	//Criação da estrutura de dados utilizada na interface
	
	Local oStructF08 := FWFormStruct(1, "F08")
	
	//Instanciando o modelo
	oModel	:=	MPFormModel():New('FISA304MOD',/*Pre-Validacao*/,{ |oModel| ValidForm(oModel) }/*Pos-Validacao*/, {|oModel| GravaSYP(oModel) }/*Commit*/,/*Cancel*/ )	
	
	//Tornando o campo código da CEST para obrigatorio na inclusão
	oStructF08:SetProperty('F08_CODIGO' , MODEL_FIELD_OBRIGAT, .T. )
	
	//Bloqueando o código da CEST para edição
	oStructF08:SetProperty('F08_CODIGO' , MODEL_FIELD_WHEN,  {|| (oModel:GetOperation()==3) } )
	
	//Atribuindo formulários para o modelo
	oModel:AddFields('FISA304MOD' ,, oStructF08 )	

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({"F08_FILIAL"},{"F08_CODIGO"},{"F08_DESCRV"},{"F08_DESCR2"})	
	
	//Adicionando descrição ao modelo
	oModel:SetDescription(STR0007) //CEST - Código Especificador da Substituição Tributária
	
	//Setando a descrição do formulário
	oModel:GetModel('FISA304MOD'):SetDescription(STR0009)
		
Return oModel 


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Erich Buttner
@since 27.05.2020
@version P11

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	//Criação do objeto do modelo de dados da Interface do Cadastro
	Local oModel     := FWLoadModel( "FISA304" )
	
	//Criação da estrutura de dados utilizada na interface do cadastro
	
	Local oStructF08 := FWFormStruct(2, "F08")
	
	//Criando oView como nulo
	Local oView := Nil
	
	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	//Atribuindo formulários para interface
	oView:AddField( "VIEW" , oStructF08 , 'FISA304MOD')
	
	//Remove os campos que não irão aparecer	
	oStructF08:RemoveField( 'F08_DESCRI' )
	oStructF08:RemoveField( 'F08_DESCR2' )
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox( "TELA" , 100 )
	
	//Colocando título do formulário
    oView:EnableTitleView('VIEW', 'Dados do CEST' )
    
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW","TELA")	
	
Return oView


//-------------------------------------------------------------------

/*/{Protheus.doc} ValidForm
Validação das informações digitadas no form.

@author Erich Buttner
@since 27.05.2020
@version P11

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

	Local lRet			:=	.T.
	Local cCod			:=	oModel:GetValue ('FISA304MOD','F08_CODIGO')	
	Local nOper 	:=	oModel:GetOperation()
	Local aArea    := GetArea()
	Local nTam 	:= TamSX3("F08_DESCRI")
	
	If nOper == 3 
		F08->(DbSetOrder (1))
		If F08->(DbSeek(xFilial("F08")+cCod))						
			Help("",1,"Help","Help",STR0008,1,0) //Já existe registro com esses dados
			lRet := .F.
		EndIF		
		
		RestArea(aArea)
				
		// Função MSMM, para gravar o campo memo na tabela SYP
		If	lRet			
			oModel:SetValue ('FISA304MOD','F08_DESCRI', SubStr( oModel:GetValue ('FISA304MOD','F08_DESCRV'), 1, nTam[1] ) )
			FWFormCommit( oModel )
		EndIf		
	ElseIf nOper == 4	
			MSMM(F08->F08_DESCR2,,,oModel:GetValue ('FISA304MOD','F08_DESCRV'),1,,,"F08","F08_DESCR2")
			oModel:SetValue ('FISA304MOD','F08_DESCRI', SubStr( oModel:GetValue ('FISA304MOD','F08_DESCRV'), 1, nTam[1] ) )
			FWFormCommit( oModel )				
	ElseIf nOper == 5
			MSMM(F08->F08_DESCR2,,,oModel:GetValue ('FISA304MOD','F08_DESCRV'),2,,,"F08","F08_DESCR2")
			FWFormCommit( oModel )				
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaSYP
Função para fazer a gravação do campo MEMO do formulário

@author Erich Buttner
@since 27.05.2020
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function GravaSYP(oModel)

Local lRet			:=	.T.
Local nOperation 	:=	oModel:GetOperation()

IF	nOperation == 3 // Inclusão 
	MSMM(,,,oModel:GetValue ('FISA304MOD','F08_DESCRV'),1,,,"F08","F08_DESCR2")	
EndIF

Return lRet  
