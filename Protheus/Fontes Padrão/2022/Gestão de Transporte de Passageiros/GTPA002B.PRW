#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA002B.CH'

/*/{Protheus.doc} GTPA002B
    Programa em MVC para o cadastro de Configuração DARUMA da Agência
    @type  Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return nil,null, sem retorno	
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPA002B()

If GI2->(!EOF())
    G9D->(DbSetOrder(1))
	FWExecView(STR0001,"VIEWDEF.GTPA002B",MODEL_OPERATION_UPDATE,,{|| .T.})	//"Características por Linha"
Else
    HELP(" ",1,"ARQVAZIO")
Endif

Return()

/*/{Protheus.doc} ModelDef
    Função que define o modelo de dados para o cadastro de Configuração DARUMA da Agência
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()

Local oModel	:= nil
Local oStrGI2	:= FWFormStruct( 1, 'GI2',{ |x| ALLTRIM(x)+"|" $ "GI2_COD|" } , .F.) //Tabela de Linhas
Local oStrG9D	:= FWFormStruct( 1, "G9D",{ |X| Alltrim(x)+"|" $ "G9D_CODCAR|G9D_DESCAR|"},.F. )	//Tabela de Características x Linhas

GA002StrGI2(oStrGI2,"GTPA002B","M")

oModel := MPFormModel():New("GTPA002B")//, /*bPreValidacao*/, {|oMdl| TA39FVld(oMdl)}/*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )

oModel:AddFields("GI2MASTER", /*cOwner*/, oStrGI2,/*bLinePre*/)
oModel:SetPrimaryKey({"GI2_FILIAL","GI2_COD"})

oModel:AddGrid("G9DDETAIL", "GI2MASTER", oStrG9D)
				
oModel:SetRelation( "G9DDETAIL", {	{ "G9D_FILIAL", "XFilial('G9D')" },	{ "G9D_CODLIN", "GI2_COD" }}, G9D->(IndexKey(1)) )	//GZ1_FILIAL+GZ1_CODGI6+GZ1_LINHA

oModel:GetModel("GI2MASTER"):SetOnlyQuery(.t.)
oModel:GetModel("G9DDETAIL"):SetOptional(.t.)

//Descrições
oModel:SetDescription(STR0001) // "Características por Linha"
oModel:GetModel("GI2MASTER"):SetDescription(STR0002) // "Dados da Linha"
oModel:GetModel("G9DDETAIL"):SetDescription(STR0003) // "Características"

//Regra de Integridade de Itens
oModel:GetModel("G9DDETAIL"):SetUniqueLine( {"G9D_CODCAR"} )

oModel:SetActivate({|oMdl| GA002LoadGI2(oMdl,"GI2MASTER")})

Return(oModel)

/*/{Protheus.doc} ViewDef
    Função que define a View para o cadastro de Configuração DARUMA da Agência
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()

Local oView     := FWFormView():New()
Local oModel	:= FwLoadModel("GTPA002B")
Local oStrGI2	:= FWFormStruct( 2, 'GI2', { |x| ALLTRIM(x)+"|" $ "GI2_COD|" } , .F.) //Tabela de Linhas
Local oStrG9D	:= FWFormStruct( 2, "G9D", { |X| Alltrim(x)+"|" $ "G9D_CODCAR|G9D_DESCAR|"} ,.F. )

GA002StrGI2(oStrGI2,"GTPA002B","V")

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField("VIEW_GI2", oStrGI2, "GI2MASTER" )
oView:AddGrid("VIEW_G9D", oStrG9D, "G9DDETAIL")

// Divisão Horizontal
oView:CreateHorizontalBox("HEADER",25)
oView:CreateHorizontalBox("BODY",75)

oView:SetOwnerView("VIEW_GI2", "HEADER")
oView:SetOwnerView("VIEW_G9D", "BODY")

//Habitila os títulos dos modelos para serem apresentados na tela
oView:EnableTitleView("VIEW_GI2")
oView:EnableTitleView("VIEW_G9D")

Return(oView)