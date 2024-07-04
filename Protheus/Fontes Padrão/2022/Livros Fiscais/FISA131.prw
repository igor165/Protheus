#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA131.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} FISA131
Cadastro MVC para atender o cadastro do CEST - Código Especificador da Substituição Tributária.

@author Diego Dias Godas
@since 21.09.2016
@version P11

/*/
//-------------------------------------------------------------------
Function FISA131()

	Local   oBrowse := Nil
	Local 	 aArea   := GetArea()
	Local	 cAlias  := "SX3"	

			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias("F0G")
			oBrowse:SetDescription(STR0007)
			oBrowse:Activate()
			
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Diego Dias Godas
@since 21.09.2016
@version P11

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

	Local aRotina := {}
	
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.FISA131' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA131' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA131' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA131' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA131' OPERATION 9 ACCESS 0 //'Copiar'
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Diego Dias Godas
@since 21.09.2016
@version P11

/*/
//-------------------------------------------------------------------

Static Function ModelDef()
	//Criação do objeto do modelo de dados
	Local oModel	:= Nil
	
	//Criação da estrutura de dados utilizada na interface
	//Local oStructF0G := FWFormStruct(1, "F0G",{|cCampo| COMP11STRU(cCampo,"CAB")})
	
	Local oStructF0G := FWFormStruct(1, "F0G")
	
	//Instanciando o modelo
	oModel	:=	MPFormModel():New('FISA131MOD',/*Pre-Validacao*/,{ |oModel| ValidForm(oModel) }/*Pos-Validacao*/, {|oModel| GravaSYP(oModel) }/*Commit*/,/*Cancel*/ )	
	
	//Tornando o campo código da CEST para obrigatorio na inclusão
	oStructF0G:SetProperty('F0G_CEST' , MODEL_FIELD_OBRIGAT, .T. )
	
	//Bloqueando o código da CEST para edição
	oStructF0G:SetProperty('F0G_CEST' , MODEL_FIELD_WHEN,  {|| (oModel:GetOperation()==3) } )
	
	//Atribuindo formulários para o modelo
	oModel:AddFields('FISA131MOD' ,, oStructF0G )	
	
	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({"F0G_FILIAL"},{"F0G_CEST"},{"F0G_DESCRV"},{"F0G_DESCR2"},{"F0G_CONV"})	
	
	//Adicionando descrição ao modelo
	oModel:SetDescription(STR0007) //CEST - Código Especificador da Substituição Tributária
	
	//Setando a descrição do formulário
	oModel:GetModel('FISA131MOD'):SetDescription(STR0009)
		
Return oModel 


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Diego Dias Godas
@since 21.09.2016
@version P11

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	//Criação do objeto do modelo de dados da Interface do Cadastro
	Local oModel     := FWLoadModel( "FISA131" )
	
	//Criação da estrutura de dados utilizada na interface do cadastro
	//Local oStructF0G := FWFormStruct(2, "F0G",{|cCampo| COMP11STRU(cCampo,"CAB")})
	
	Local oStructF0G := FWFormStruct(2, "F0G")
	
	//Criando oView como nulo
	Local oView := Nil
	
	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	//Atribuindo formulários para interface
	oView:AddField( "VIEW" , oStructF0G , 'FISA131MOD')
	
	//Remove os campos que não irão aparecer	
	oStructF0G:RemoveField( 'F0G_DESCRI' )
	oStructF0G:RemoveField( 'F0G_DESCR2' )
	
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

@author Diego Dias Godas
@since 21.09.2016
@version P11

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

	Local lRet			:=	.T.
	Local cCod			:=	oModel:GetValue ('FISA131MOD','F0G_CEST')	
	Local nOper 	:=	oModel:GetOperation()
	Local aArea    := GetArea()
	Local nTam 	:= TamSX3("F0G_DESCRI")
	
	If nOper == 3 
		F0G->(DbSetOrder (1))
		If F0G->(DbSeek(xFilial("F0G")+cCod))						
			Help("",1,"Help","Help",STR0008,1,0) //Já existe registro com esses dados
			lRet := .F.
		EndIF		
		
		RestArea(aArea)
				
		// Função MSMM, para gravar o campo memo na tabela SYP
		If	lRet			
			oModel:SetValue ('FISA131MOD','F0G_DESCRI', SubStr( oModel:GetValue ('FISA131MOD','F0G_DESCRV'), 1, nTam[1] ) )
			FWFormCommit( oModel )
		EndIf		
	ElseIf nOper == 4	
			MSMM(F0G->F0G_DESCR2,,,oModel:GetValue ('FISA131MOD','F0G_DESCRV'),1,,,"F0G","F0G_DESCR2")
			oModel:SetValue ('FISA131MOD','F0G_DESCRI', SubStr( oModel:GetValue ('FISA131MOD','F0G_DESCRV'), 1, nTam[1] ) )
			FWFormCommit( oModel )				
	ElseIf nOper == 5
			MSMM(F0G->F0G_DESCR2,,,oModel:GetValue ('FISA131MOD','F0G_DESCRV'),2,,,"F0G","F0G_DESCR2")
			FWFormCommit( oModel )				
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaSYP
Função para fazer a gravação do campo MEMO do formulário

@author Diego Dias
@since 15/12/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function GravaSYP(oModel)

Local lRet			:=	.T.
Local nOperation 	:=	oModel:GetOperation()

IF	nOperation == 3 // Inclusão 
	MSMM(,,,oModel:GetValue ('FISA131MOD','F0G_DESCRV'),1,,,"F0G","F0G_DESCR2")	
EndIF

Return lRet  
