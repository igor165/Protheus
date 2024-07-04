//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'CTBA519.ch'
 
/*/{Protheus.doc} CTBA519
Cadastro da Proje��o aturial do RPPS
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
    
    //Inst�nciando FWMBrowse - Somente com dicion�rio de dados
    SetFunName("CTBA519")
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela 
    oBrowse:SetAlias("QL8")
 
    //Setando a descri��o da rotina
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
 | Desc:  Cria��o do menu MVC                                          |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
    Local aRot := {}

    aRot :=  FWMVCMenu( 'CTBA519' )

    //Adicionando op��es 
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
 | Desc:  Cria��o do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
    //Cria��o do objeto do modelo de dados
    Local oModel := Nil
     
    //Cria��o da estrutura de dados utilizada na interface
    Local oStQL8 := FWFormStruct(1, "QL8")

    //Editando caracter�sticas do dicion�rio
    oStQL8:SetProperty('QL8_CODBIM',    MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'CtbQL8Chv()'))
    oStQL8:SetProperty('QL8_ANOREF',    MODEL_FIELD_WHEN,{|oModel|INCLUI})
    //Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("CTBA519",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formul�rios para o modelo
    oModel:AddFields("QL8MASTER",/*cOwner*/,oStQL8)

    //Setando a chave prim�ria da rotina
    oModel:SetPrimaryKey({'QL8_FILIAL', 'QL8_ANOREF', 'QL8_CODBIM'})

     //Adicionando descri��o ao modelo    
    oModel:SetDescription(STR0001)

Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Jamer Nunes Pedroso                                          |
 | Data:  25/11/2020                                                   |
 | Desc:  Cria��o da vis�o MVC                                         |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
    //Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("CTBA519")
     
    //Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStQL8 := FWFormStruct(2, "QL8")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'QL8_NOME|QL8_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formul�rios para interface
    oView:AddField("VIEW_QL8", oStQL8, "QL8MASTER")

    
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando t�tulo do formul�rio
    oView:EnableTitleView('VIEW_QL8', 'Dados - '+STR0001 )  
     
    //For�a o fechamento da janela na confirma��o
    oView:SetCloseOnOk({||.T.})
     
    //O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView("VIEW_QL8","TELA")
     
Return oView
 
/*/{Protheus.doc} CtbQL8Chv
Fun��o que valida a digita��o do campo Chave, para verificar se j� existe
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
     
    //Se conseguir posicionar, j� existe
    If QL8->(DbSeek(FWxFilial('QL8') + cQL8Chave))
        MsgAlert(STR0002+" (<b>"+cQL8Chave+"</b>)!", STR0003 )
        lRet := .F.
    EndIf
     
    RestArea(aArea)
Return lRet
