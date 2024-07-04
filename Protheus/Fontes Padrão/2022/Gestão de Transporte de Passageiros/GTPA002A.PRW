#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA002A.CH'

/*/{Protheus.doc} GTPA002A
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
Function GTPA002A()

If GI2->(!EOF())
    GYZ->(DbSetOrder(1))
    FWExecView(STR0001,"VIEWDEF.GTPA002A",MODEL_OPERATION_UPDATE,,{|| .T.})	//"Veículos por Linha"
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
Local oStrGYZ	:= FWFormStruct( 1, "GYZ",,.F. )	//Tabela de Veículos x Linhas

Local aGatilho	:= {}
Local aRelation	:= {}


GA002StrGI2(oStrGI2,"GTPA002A","M")

oModel := MPFormModel():New("GTPA002A")//, /*bPreValidacao*/, {|oMdl| TA39FVld(oMdl)}/*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )

oModel:AddFields("GI2MASTER", /*cOwner*/, oStrGI2,/*bLinePre*/)

oModel:AddGrid("GYZDETAIL", "GI2MASTER", oStrGYZ)

oModel:SetRelation( "GYZDETAIL", {{ "GYZ_FILIAL", "XFilial('GYZ')" },{ "GYZ_CODLIN", "GI2_COD" }}, GYZ->(IndexKey(1)) )	//GZ1_FILIAL+GZ1_CODGI6+GZ1_LINHA

oModel:GetModel("GI2MASTER"):SetOnlyQuery(.t.)
oModel:GetModel("GYZDETAIL"):SetOptional(.t.)

//Descrições
oModel:SetDescription(STR0001) // "Veículos por Linha"
oModel:GetModel("GI2MASTER"):SetDescription(STR0003) // "Dados da Linha"
oModel:GetModel("GYZDETAIL"):SetDescription(STR0004) // "Veículos"

oModel:SetPrimaryKey({"GI2_FILIAL","GI2_COD"})
//Regra de Integridade de Itens
oModel:GetModel("GYZDETAIL"):SetUniqueLine( {"GYZ_CODVEI"} )

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

Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA002A")
Local oStrGI2	:= FWFormStruct( 2, 'GI2',{ |x| ALLTRIM(x)+"|" $ "GI2_COD|" } , .F.) //Tabela de Linhas
Local oStrGYZ	:= FWFormStruct( 2, "GYZ",{ |x| ALLTRIM(x)+"|" $ "GYZ_CODVEI|GYZ_DESVEI|" } ,.F. )

GA002StrGI2(oStrGI2,"GTPA002A","V")
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField("VIEW_GI2", oStrGI2, "GI2MASTER" )
oView:AddGrid("VIEW_GYZ", oStrGYZ, "GYZDETAIL")

// Divisão Horizontal
oView:CreateHorizontalBox("HEADER",25)
oView:CreateHorizontalBox("BODY",75)

oView:SetOwnerView("VIEW_GI2", "HEADER")
oView:SetOwnerView("VIEW_GYZ", "BODY")

//Habitila os títulos dos modelos para serem apresentados na tela
oView:EnableTitleView("VIEW_GI2")
oView:EnableTitleView("VIEW_GYZ")

Return(oView)

/*/{Protheus.doc} Ga002Avld()
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    
/*/
Function Ga002AVld()
Local oModel		:= FwModelActive()
Local lRet          := .T.
Local cNextAlias    := GetNextAlias()
Local cCodLin       := oModel:GetModel('GI2MASTER'):GetValue('GI2_COD')
Local cCodBem       := oModel:GetModel('GYZDETAIL'):GetValue('GYZ_CODVEI')


BeginSql alias cNextAlias
    SELECT COUNT(*) AS TOTAL
	FROM 
		%table:G9D% G9D 
	WHERE 
		G9D.G9D_FILIAL = %xFilial:G9D% AND
        G9D.G9D_CODLIN = %Exp:cCodLin% AND
		G9D.%notdel% AND
		G9D.G9D_CODCAR NOT IN 
			(
				SELECT 
					STB.TB_CARACTE  
				FROM %table:STB%  STB 
					INNER JOIN %table:ST9%  ST9 ON
                        ST9.T9_FILIAL = %xFilial:ST9% And
						STB.TB_CODBEM = ST9.T9_CODBEM And 
						ST9.%notdel%
				WHERE 
                    STB.TB_FILIAL = %xFilial:STB% And
                    STB.%notdel% And
                    ST9.T9_CODBEM = %Exp:cCodBem% 
                    
			)
EndSql
IF (cNextAlias)->TOTAL > 0
    lRet := .F.
    oModel:SetErrorMessage('GYZDETAIL','GYZ_CODVEI','GYZDETAIL','GYZ_CODVEI','Ga002AVld',STR0005,STR0006)//'O veículo não atende às características da linha'##'Verifique as características do veículo e da linha'
EndIf
	
(cNextAlias)->( dbCloseArea() )
Return lRet