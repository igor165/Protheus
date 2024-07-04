#Include 'Protheus.ch'
#Include "Average.ch"
#Include "FWMVCDEF.CH"
#Include "EICTRI100.CH"

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : EICTRI100()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Chamada principal para rotina da Tributos SUFRAMA
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Function EICTRI100()
Local oBrowse

AjustaDic()  // GFP - 17/11/2014 

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EJC") //Informando o Alias
oBrowse:SetMenuDef("EICTRI100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001) // "Cadastro de Tributos SUFRAMA" //Descrição a ser apresentada no Browse
oBrowse:Activate()

Return Nil

*------------------------*
Static Function MenuDef()
*------------------------*

Local aRotina := {}

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"          OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.EICTRI100" OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.EICTRI100" OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.EICTRI100" OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.EICTRI100" OPERATION 5 ACCESS 0 // "Excluir"

Return aRotina

*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruEJC := FWFormStruct(1,"EJC",,)
Local bPosValidacao := { |oModel| TRI100Valid('MANUT',oModel) }
oModel := MPFormModel():New("EICTRI100",,bPosValidacao,/*bCommit*/,/*bCancel*/)

//Modelo para criação da antiga Enchoice com a estrutura da tabela EJC
oModel:AddFields("EJCMASTER", /*nOwner*/, oStruEJC)

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001) // "Cadastro de Tributos SUFRAMA"
oModel:GetModel("EJCMASTER"):SetDescription(STR0001) // "Cadastro de Tributos SUFRAMA" //Título da Capa'

Return oModel

*------------------------*
Static Function ViewDef()
*------------------------*
//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICTRI100")

//Cria a estrutura a ser usada na View
Local oStruEJC := FWFormStruct(2,"EJC",,)

Local oView

INCLUI := oModel:getOperation() == INCLUIR
ALTERA := oModel:getOperation() == ALTERAR
EXCLUI := oModel:getOperation() == EXCLUIR

//Cria o objeto de View  
oView := FWFormView():New()

oStruEJC:RemoveField("EJC_CODDES")

//Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_EJC", oStruEJC, "EJCMASTER")

//Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("SUPERIOR", 100/*,,,"IDFOLDER","IDSHEET01"*/)

//Relaciona o ID da View com o "box" para exibição
oView:SetOwnerView("VIEW_EJC", "SUPERIOR")

//Liga a identificação do componente
oView:EnableTitleView("VIEW_EJC", STR0001, RGB(240,248,255)) // "Cadastro de Tributos SUFRAMA"

Return oView

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : TRI100Valid()
Parametros : cOpc   - Opção de validação
             oModel - Objeto Model
Retorno    : lRet
Objetivos  : Validação da Tributos SUFRAMA
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/
Function TRI100Valid(cOpc,oModel)
Local lRet := .T.
Local cQuery := "" 
Local oModelEJC := oModel:GetModel("EJCMASTER")
Local nRecno := 0
Local nOrd := 0

   Do Case
      Case AllTrim(Upper(cOpc)) == 'MANUT'
     
         If oModel:getOperation() == EXCLUIR
            #IfDef TOP      
               If Select("Work") > 0
                  Work->(DBCloseArea())
               EndIf

               cQuery := "Select * From " + RetSqlName("EJB") + " where D_E_L_E_T_ <> '*' And EJB_FILIAL = '"+xFilial("EJC")+"' And EJB_CODTRI = '" + oModelEJC:GetValue("EJC_CODTRI") + "'"
               cQuery := ChangeQuery(cQuery)

               DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "Work", .T., .T.) 
      
               lRet := Work->(Bof()) .And. Work->(Eof()) 
     
               Work->(DBCloseArea())

               If !lRet
                  EasyHelp(STR0007,STR0008) // "Registro está sendo utilizado no cadastro de Matriz de Tributação.","Atenção"
               EndIf

            #EndIf
         ElseIf oModel:getOperation() == INCLUIR
            nRecno := EJC->(Recno())
            nOrd :=  EJC->(IndexOrd())
            EJC->(DbSetOrder(1))
            lRet := !EJC->(DbSeek(xFilial("EJC")+oModelEJC:GetValue("EJC_CODTRI")))
            If !lRet
               EasyHelp(STR0009,STR0008) // "Registro já cadastrado.","Atenção"            
            EndIf
         EndIf

   End Case

Return lRet

/*
Funcao     : AjustaDic()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Atualização de Dicionarios de Dados
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 17/11/2014 :: 14:30
*/
*-------------------------*
Static Function AjustaDic()
*-------------------------*
Private oUpdAtu

If FindFunction("AvUpdate01")
   oUpdAtu := AvUpdate01():New()
EndIf

If ValType(oUpdAtu) == "O"
   oUpdAtu:aChamados := {{nModulo,{|o| AjustaSX3(o)}}}
   oUpdAtu:Init(,.T.)
EndIf

Return Nil

/*
Funcao     : AjustaSX3()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Atualização de Dicionario SX3
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 17/11/2014 :: 14:30
*/
*---------------------------*
Static Function AjustaSX3(o)
*---------------------------*

o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_BROWSE"},2)
o:TableData("SX3"  ,{"EJC_CODTRI","S"        }  )
o:TableData("SX3"  ,{"EJC_DESCRI","S"        }  )

Return