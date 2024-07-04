#INCLUDE 'TOTVS.CH'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'
#Include 'EECDU010.CH'

/*/{Protheus.doc} EECDU010()
   (long_description)
   @type  Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return returno,return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Function EECDU010()

Local aArea        := GetArea()
Local oBrowse
Private aRotina     := MenuDef()

   //Instânciando FWMBrowse - Somente com dicionário de dados
   oBrowse := FWMBrowse():New()
   oBrowse:setmenudef("EECDU010")
   //oBrowse:SetFilterDefault( cFiltro )
    
   //Setando a tabela de cadastro de Autor/Interprete
   oBrowse:SetAlias("EK5")

   //Setando a descrição da rotina
   oBrowse:SetDescription(STR0001) //"Destaques NCM"
   
   //Ativa a Browse
   oBrowse:Activate()

RestArea( aArea )

Return
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Menu com as rotinas                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
    Local aRot := {}

    ADD OPTION aRot TITLE STR0002 ACTION 'VIEWDEF.EECDU010' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1 'Visualizar'
    ADD OPTION aRot TITLE STR0003 ACTION 'VIEWDEF.EECDU010' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 5 'Incluir'
    ADD OPTION aRot TITLE STR0004 ACTION 'VIEWDEF.EECDU010' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 3 'Alterar'
    ADD OPTION aRot TITLE STR0005 ACTION 'VIEWDEF.EECDU010' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 4 'Excluir'

Return aRot
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 Static Function ModelDef()

    //Criação do objeto do modelo de dados
    Local oModel := Nil
    Local bPost := { |o| DU010VALID(o) }

    //Criação da estrutura de dados utilizada na interface
    Local oStEK5 := FWFormStruct(1, "EK5")

    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("EECDU010",/*bPre*/,bPost,/*bCommit*/,/*bCancel*/)
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("EK5MASTER",/*cOwner*/ ,oStEK5 )

    //Setando a chave primária da rotina
    //Adicionando descrição ao modelo
    oModel:SetDescription(STR0001) //"Destaques NCM"

    //Setando a chave primária da rotina EK5_FILIAL+EK5_NCM+EK5_DESTAQ+EK5_TIPO
    oModel:SetPrimaryKey({'EK5_FILIAL','EK5_NCM','EK5_DESTAQ','EK5_TIPO'})

    //Setando a descrição do formulário
    oModel:GetModel("EK5MASTER"):SetDescription(STR0001) //"Destaques NCM"

Return oModel
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ViewDef()

    //Criação do objeto do modelo de dados da Interface
    Local oModel := FWLoadModel("EECDU010")
     
    //Criação da estrutura de dados utilizada na interface
    Local oStEK5 := FWFormStruct(2, "EK5")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'EK5_NOME|EK5_DTAFAL|'}

    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_EK5", oStEK5, "EK5MASTER")

    oView:CreateHorizontalBox( 'CABEC', 100, , , , )

    oView:SetOwnerView("VIEW_EK5","CABEC")

    oModel:GetModel("EK5MASTER"):SetDescription(STR0001) //"Destaques NCM"

    oView:EnableTitleView('VIEW_EK5', STR0001 ) //"Destaques NCM"

Return oView
/*---------------------------------------------------------------------*
 | Func:  DU010VALID                                                   |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Validação para deletar a linha                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function DU010VALID(oModel)
Local lRet        := .T.
Local nOperation  := oModel:GetOperation()
Local cChaveEK5   := ""
Local aAreaEK5    := EK5->( GetArea() )

   If nOperation == 3 //.and. EK0->EK0_STATUS <> "1"
      cChaveEK5 := FWFldGet( "EK5_FILIAL" ) + FWFldGet( "EK5_NCM" ) + FWFldGet( "EK5_DESTAQ" )
      if EK5->( DBSETORDER(1) , dbseek( cChaveEK5 ) )
         Help( ,, 'HELP',STR0001, STR0006 , 1, 0) //"Destaques NCM" # "Já existe cadastro desse destaque para esse NCM."
         lRet := .F.
      EndIf
   EndIf

RestArea(aAreaEK5)

return lRet
