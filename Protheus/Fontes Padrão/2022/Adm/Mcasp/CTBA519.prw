//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'CTBA519.ch'
 
/*/{Protheus.doc} CTBA519
Cadastro da Projeção aturial do RPPS
@author Jamer Nunes Pedroso
@since 25/11/2020
@version 1.0
/*/ 
Function CTBA519()
    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()

    DbSelectArea('QL8')
    QL8->(DbSetOrder(1)) // QL8_FILIAL+QL8_ANOREF+QL8_CODBIM
    QL8->(DbGoTop())
    
    //Instânciando FWMBrowse - Somente com dicionário de dados
    SetFunName("CTBA519")
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela 
    oBrowse:SetAlias("QL8")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(STR0001)
    //Ativa a Browse

    If !IsBlind()    
        oBrowse:Activate()
    EndIf
     
    SetFunName(cFunBkp)
    RestArea(aArea)
Return
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Jamer Nunes Pedroso                                          |
 | Data:  25/11/2020                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
    Local aRot := {}

    aRot :=  FWMVCMenu( 'CTBA519' )

    //Adicionando opções 
    /*
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.CTBA519' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.CTBA519' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.CTBA519' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.CTBA519' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION aRot Title 'Imprimir' Action 'VIEWDEF.CTBA519' OPERATION 8 ACCESS 0 //"Imprimir"
    ADD OPTION aRot TITLE 'Copiar' ACTION 'VIEWDEF.CTBA519' OPERATION 9 ACCESS 0 //'Copiar'
    */

Return aRot 
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Jamer Nunes Pedroso                                          |
 | Data:  05/08/2016                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStQL8 := FWFormStruct(1, "QL8")

    //Editando características do dicionário
    oStQL8:SetProperty('QL8_CODBIM',    MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'CtbQL8Chv()'))
    oStQL8:SetProperty('QL8_ANOREF',    MODEL_FIELD_WHEN,{|oModel|INCLUI})
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("CTBA519",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("QL8MASTER",/*cOwner*/,oStQL8)

    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'QL8_FILIAL', 'QL8_ANOREF', 'QL8_CODBIM'})

     //Adicionando descrição ao modelo    
    oModel:SetDescription(STR0001)

Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Jamer Nunes Pedroso                                          |
 | Data:  25/11/2020                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("CTBA519")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStQL8 := FWFormStruct(2, "QL8")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'QL8_NOME|QL8_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_QL8", oStQL8, "QL8MASTER")

    
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_QL8', 'Dados - '+STR0001 )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_QL8","TELA")
     
Return oView
 
/*/{Protheus.doc} CtbQL8Chv
Função que valida a digitação do campo Chave, para verificar se já existe
@type function
@author Jamer Nunes Pedroso
@since 25/11/2020
@version 1.0
/*/
Function CtbQL8Chv()
    Local aArea    := GetArea()
    Local lRet     := .T.
    Local cQL8Chave := M->QL8_ANOREF+M->QL8_CODBIM
     
    DbSelectArea('QL8')
    QL8->(DbSetOrder(1)) // QL8_FILIAL+QL8_ANOREF+QL8_CODBIM
    QL8->(DbGoTop())
     
    //Se conseguir posicionar, já existe
    If QL8->(DbSeek(FWxFilial('QL8') + cQL8Chave))
        MsgAlert(STR0002+" (<b>"+cQL8Chave+"</b>)!", STR0003 )
        lRet := .F.
    EndIf
     
    RestArea(aArea)
Return lRet
