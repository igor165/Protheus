#Include "FISA300A.CH"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA300A()

Esta rotina tem objetivo de exibir as informações da apuração de ISS
por município e também por código de serviço.

@author Erick G. Dias
@since 12/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FISA300A(cModo)

Private cModApur := cModo

FWExecView(STR0001 + FWGETCODFILIAL + ' - ' +SM0->M0_FILIAL,'FISA300A', MODEL_OPERATION_VIEW) //'Filial: '

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 11/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA300A" ) 

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Criação do modelo, para exibir cabeçalho com informaçõe da apuração, grid com os totais por
código ed município, e outro grid com as informações totalizadas por código de serviço.

@author Erick G Dias
@since 12/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil
Local lSaveApur := isincallstack("SAVEAPUR")
Local lNoDel    := !lSaveApur
Local lNoAdd    := !lSaveApur
Local lNoUpd    := !lSaveApur
Local bPreValid := { |oModelGrid, nLine, cAction, cField| FSA300APRE(oModelGrid, nLine, cAction, cField) }	

//Estrutura Pai com as informações de cabeçalho da apuração
Local oCabApur := FWFormStruct(1, "F1P")

//Estrutura Filho com as informações agrupadas por código município 
Local oMunicipio := FWFormStruct(1, "F1N")

//Estrutura Filho com as informações agrupadas por código de serviço do município selecionado
Local oServico := FWFormStruct(1, "F1O")

//Estrutura Filho com as informações dos títulos gerados pela apuração por município
Local oTitulo := FWFormStruct(1, "F1R")

//Estrutura Filho com as informações das deduções de ISS
Local oDeducao := FWFormStruct(1, "F1Q")

//Instanciando o modelo
oModel := MPFormModel():New('FISA300A')

//Atribuindo estruturas para o modelo, cabeçalho da apuração
oModel:AddFields("FISA300A",, oCabApur)

//Adiciona o Grid ao modelo, correspondente ao município
oModel:AddGrid('FISA300AMUNICIPIO', 'FISA300A', oMunicipio)
//Somente permite adicionar e excluir linha quando modelo é processado por meio da classe de apuração
oModel:GetModel('FISA300AMUNICIPIO'):SetNoInsertLine(lNoAdd)
oModel:GetModel('FISA300AMUNICIPIO'):SetNoDeleteLine(lNoDel)
oModel:GetModel( 'FISA300AMUNICIPIO' ):SetNoUpdateLine(lNoUpd)

//Adiciona o grid com informações do serviço prestado
oModel:AddGrid('FISA300ASERVICO', 'FISA300AMUNICIPIO', oServico)
//Somente permite adicionar e excluir linha quando modelo é processado por meio da classe de apuração
oModel:GetModel('FISA300ASERVICO'):SetNoInsertLine(lNoAdd)
oModel:GetModel('FISA300ASERVICO'):SetNoDeleteLine(lNoDel)

//Adiciona o grid com informações do título
oModel:AddGrid('FISA300ATITULO', 'FISA300AMUNICIPIO', oTitulo, bPreValid)
//Somente permite adicionar e excluir linha quando modelo é processado por meio da classe de apuração
oModel:GetModel('FISA300ATITULO'):SetNoInsertLine(lNoAdd)

//Não permite alteração do tipo de apuração e o valor
oTitulo:SetProperty('F1R_TPIMP' , MODEL_FIELD_WHEN, {|| .F. })
oTitulo:SetProperty('F1R_VALOR' , MODEL_FIELD_WHEN, {|| .F. })

//Torna obrigatório o preenchimento dos campos abaixo para geração dos títulos
oTitulo:SetProperty( 'F1R_FORN'   , MODEL_FIELD_OBRIGAT, lNoAdd )
oTitulo:SetProperty( 'F1R_LOJA'   , MODEL_FIELD_OBRIGAT, lNoAdd )
oTitulo:SetProperty( 'F1R_VENCTO' , MODEL_FIELD_OBRIGAT, lNoAdd )
oTitulo:SetProperty( 'F1R_NATURE' , MODEL_FIELD_OBRIGAT, lNoAdd )
oTitulo:SetProperty( 'F1R_VALOR'  , MODEL_FIELD_OBRIGAT, lNoAdd )

//Regra de validação do vencimento
oTitulo:SetProperty( 'F1R_VENCTO'  , MODEL_FIELD_VALID, {|| oModel:GetValue ('FISA300ATITULO',"F1R_VENCTO") >= dDataBase } )

//Adiciona o grid com as deduçõees
oModel:AddGrid('FISA300ADEDUCOES', 'FISA300AMUNICIPIO', oDeducao)

//As informações de detalhamento por serviço é opicional, na hipótese de não existir nenhuma movimentação no período
oModel:GetModel( 'FISA300ASERVICO' ):SetOptional( .T. )

//As informações do título é opicional, pois nem sempre haverá título gerado
oModel:GetModel( 'FISA300ATITULO' ):SetOptional( .T. )

//Deduções é opicional, nem sempre terá deduções
oModel:GetModel( 'FISA300ADEDUCOES' ):SetOptional( .T. )

//Relacionamento entre as tabelas F1P cabeçalho da apuração com a tabela F1N totais por município
oModel:SetRelation('FISA300AMUNICIPIO', {{'F1N_FILIAL', 'xFilial("F1N")'}, {'F1N_IDAPUR', 'F1P_ID'}}, F1N->(IndexKey(2)))

//Relacionamento entre as tabelas F1N apuração por município com a tbaela F1N apuração por município
oModel:SetRelation( 'FISA300ASERVICO', {{'F1O_FILIAL', 'xFilial("F1O")'}, {'F1O_IDAPUR', 'F1N_ID'}}, F1O->( IndexKey(2))) 

//Relacionamento entre as tabelas F1N apuração por município com a tbaela F1R informações dos títulos
oModel:SetRelation( 'FISA300ATITULO', {{'F1R_FILIAL', 'xFilial("F1R")'}, {'F1R_IDAPUR', 'F1N_ID'}}, F1R->( IndexKey(1)))

//Relacionamento entre as tabelas F1N apuração por município com a tbaela F1Q deduções de ISS
oModel:SetRelation( 'FISA300ADEDUCOES', {{'F1Q_FILIAL', 'xFilial("F1Q")'}, {'F1Q_IDAPUR', 'F1N_ID'}}, F1Q->( IndexKey(1)))

//Adicionando descrição ao modelo
oModel:SetDescription(STR0002) //"Totais da Apuração de ISS"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias
@since 12/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados
Local oModel := FWLoadModel("FISA300A")

//Criação da estrutura de dados utilizada na interface
Local oMunicipio    := FWFormStruct(2, "F1N")
Local oServico      := FWFormStruct(2, "F1O")
Local oView         := Nil

oView := FWFormView():New()
oView:SetModel(oModel)

//Atribuindo formulários para interface
oView:AddGrid('VIEW_MUNICIPIO', oMunicipio  , 'FISA300AMUNICIPIO' )
oView:AddGrid('VIEW_SERVICO'  , oServico    , 'FISA300ASERVICO'   )

//Retira da view os campos de ID
oMunicipio:RemoveField('F1N_ID')
oMunicipio:RemoveField('F1N_IDAPUR')
oMunicipio:RemoveField('F1N_DEDPRP')
oMunicipio:RemoveField('F1N_DEDSUB')
oMunicipio:RemoveField('F1N_DEDUNI')
oMunicipio:RemoveField('F1N_RECUNI')
oMunicipio:RemoveField('F1N_QTDUNI')
oMunicipio:RemoveField('F1N_VLFUNI')
oMunicipio:RemoveField('F1N_STATUS')
oServico:RemoveField( 'F1O_ID')
oServico:RemoveField( 'F1O_IDAPUR')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox('SUPERIOR', 50)
oView:CreateHorizontalBox('INFERIOR', 50)

//O formulário da interface será colocado dentro do container
oView:SetOwnerView('VIEW_MUNICIPIO', 'SUPERIOR'   )
oView:SetOwnerView('VIEW_SERVICO'  , 'INFERIOR')

//Colocando título do formulário
oView:EnableTitleView('VIEW_MUNICIPIO'  , STR0003) //"Totais por Município"
oView:EnableTitleView('VIEW_SERVICO' , STR0004) //"Totais por Serviço"

//Desabilita opção de ordenação do Grid
oView:SetViewProperty( "*", "GRIDNOORDER")

//Duplo clique no muniucípio terá ação de abrir tela com detalhamento da apuração
oView:SetViewProperty("VIEW_MUNICIPIO", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel, cField| FSA300AGDC(oFormulario,cFieldName,nLineGrid,nLineModel,cField)}}) 

//Adiciona o botão de FSA300DLEG
oView:AddUserButton( STR0005, 'CLIPS', {|oView| FSA300DLEG()} ) //'Legenda'

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300AGDC

Função que faz o tratamento do duplo click no município
para abrir a tela com resumo da apuração do município em questão

@author Erick G. Dias
@since 13/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300AGDC(oFormulario,cFieldName,nLineGrid,nLineModel,cField)

Local oMunicipio 	:= oFormulario:GetModel("FISA300AMUNICIPIO") //Obtenho o modelo da F1N
Local cIdF1N	    := oMunicipio:GetValue("F1N_ID") //Obtenho o ID que foi clicado
Local cIdF1P	    := oMunicipio:GetValue("F1N_IDAPUR") //Obtenho o ID que foi clicado
Local cUf	        := oMunicipio:GetValue("F1N_UF") //Obtenho o Estado
Local cCodMun	    := oMunicipio:GetValue("F1N_CODMUN") //Obtenho o ID que foi clicado
Local cStatus       := oMunicipio:GetValue("F1N_STATUS")
Local oModel        := FWModelActive()
Local oView 		:= FWViewActive()
Local oApurISS		:= Nil
Local aApurMun  	:= {}
Local oTotServ      := {}

//Verifico primeiro se o ID não está vazio
If !Empty(cIdF1N) .AND. CC2->(MsSeek(xFilial("CC2") + cUf + cCodMun ))        
    
    //Criação do objeto da apuração
    oApurISS := APURISS():New()
    
    //Faz carga dos valores da apuração
    oApurISS:LoadApur(cIdF1P)
    
    //Faz carga dos valores por código de serviço
    aApurMun := oApurISS:getApurMun(RetUfIBGE(cUf)+cCodMun)

    IF Len(aApurMun) > 0

        //Totalizar os valores da lista de serviços
        oTotServ := FSA300SMOV(aApurMun)
        
        //Chamo tela de resumo da apuração do município selecionado
        FISA300B(cModApur, cIdF1P, cIdF1N, Alltrim(CC2->CC2_MUN), oApurISS, aApurMun[1], oTotServ, RetUfIBGE(cUf)+cCodMun, cStatus)

        //Destroi objeto
        FreeObj(oTotServ)
	    oTotServ:= NIL

    EndIf
    
    oApurISS:Clear()

    //Destroi objeto
    FreeObj(oApurISS)   
    oApurISS := Nil     

    //Faz atualização dos valores na tela
    oModel:DeActivate() 
    oModel:Activate()           
    oview:Refresh( 'FISA300AMUNICIPIO' )

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300SMOV

Função que fará a totalização dos valores da lsita de serviços
para exibir na tela de resumo da apuração do município selecionado

@author Erick G. Dias
@since 17/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300SMOV(aApurMun)

Local nX     := 0
Local nY     := 0
Local aServicos := {}
Local oTotServ := APURISSMOV():New()

//Preenche o array com zeros
aFill(aServicos, 0, ,10)

//Laço nos municípios
For nX:= 1 to Len(aApurMun)
    
    //Obte a lista de serviços do município corrente no laço
    aServicos:= aApurMun[nX]:getServicos()    

    //Laço na lista dos serviços
    For nY:= 1 to Len(aServicos)        

        //Realiza a soma dos valores e deixa encapsulado no objeto
        oTotServ:somarMov(aServicos[nY])
    Next nY

Next nX

Return oTotServ

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300APRE

Função que fará a validação para não permitir alterar todos os campos
do grid dos títulos.

@author Erick G. Dias
@since 01/07/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function FSA300APRE(oModelGrid, nLine, cAction, cField)

Local cCampoAlt     := "F1R_PREFIX/F1R_FORN/F1R_LOJA/F1R_VENCTO/F1R_NATURE"
Local lRet          := .F.
Local oModel        :=	FWModelActive()
Local oMunicipio	:= oModel:GetModel('FISA300AMUNICIPIO')
Local cStatus   	:= oMunicipio:GetValue("F1N_STATUS")

//Verificação para permitir edição dos campos.
If isInCallStack("FSA300FATU") .OR. isInCallStack("SAVEAPUR")
    //Para estes processos permitirá editar informação
    lRet    := .T.    
ElseIf cCampoAlt $ cCampoAlt .AND. cStatus == "1"
    //Para estes campos se for edição manual também permitirá, porém somente para apurações que ainda não geraram título e/ou contabilização.
    lRet    := .T.    
EndIF

Return lRet
 