/*
Programa   : ESSNS400
Objetivo   : Rotina de Cadastro de NBS
Retorno    : Nil
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 16/08/2012 15:07 
Revisao    : 
*/

#Include 'Protheus.ch'               
#Include "Average.ch"
#Include "FWMVCDEF.CH"
Function ESSNS400()

Local oBrowse 
Local cFonte       := "ESSNS400"

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EL0") //Informando o Alias
oBrowse:SetMenuDef(cFonte) //Nome do fonte do MenuDef
oBrowse:SetDescription("NBS") //Descrição a ser apresentada no Browse     
oBrowse:Activate()

Return Nil

*------------------------*
Static Function MenuDef()
*------------------------*

Local aRotina := {}

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ESSNS400" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ESSNS400" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ESSNS400" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "FWExecView('EXCLUIR','VIEWDEF.ESSNS400', 5,,,{|| INTEGREF('EL0')})" OPERATION 5 ACCESS 0

Return aRotina

*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruEL0 := FWFormStruct(1,"EL0",,)

oModel := MPFormModel():New("ESSNS400",/*bGridValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

//Modelo para criação da antiga Enchoice com a estrutura da tabela
oModel:AddFields("EL0MASTER", /*nOwner*/, oStruEL0, /*bPre */,/*bPos*/) 

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription("NBS")
oModel:GetModel("EL0MASTER"):SetDescription("NBS") // Título da Capa

Return oModel

*------------------------*
Static Function ViewDef()
*------------------------*
//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("ESSNS400")

//Cria a estrutura a ser usada na View
Local oStruEL0 := FWFormStruct(2,"EL0",,)

Local oView

//Cria o objeto de View  
oView := FWFormView():New()

//Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_EL0", oStruEL0, "EL0MASTER")

//Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("SUPERIOR", 100/*,,,"IDFOLDER","IDSHEET01"*/)

//Relaciona o ID da View com o "box" para exibição
oView:SetOwnerView("VIEW_EL0", "SUPERIOR")

//Liga a identificação do componente
oView:EnableTitleView("VIEW_EL0", "NBS", RGB(240,248,255))

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView

/*
Programa   : NS400Valid
Objetivo   : Validação dos campos que fazem parte da Rotina de Processo de Serviços
Parametros : Informação a ser validada
Retorno    : Lógico
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 20/08/2012 14:21 
Revisao    : 
*/

Function NS400Valid(cCampo)
Local oModel
Local cCont
Local lRet       := .T. 
Default cCampo   := ""

//oModel    := FWModelActive()
 
Begin Sequence

Do Case //If(!Empty(M->B5_NBS),(EXISTCPO("EL0",M->B5_NBS).AND.LEN(ALLTRIM(M->B5_NBS))>=9),.T.)
   
   Case cCampo == "B5_NBS"
      If !(vazio().Or.existcpo("EL0",M->B5_NBS).And.LEN(ALLTRIM(M->B5_NBS)) >= LEN(M->B5_NBS))
         lRet := .F.
         EasyHelp("Digite N.B.S valido! Selecione um N.B.S sem espaços e registrado no sistema.","Aviso")
      EndIf

   OtherWise
      EasyHelp("Parametro invalido na função NS400Valid.","Aviso")
      
End Case

End Sequence
//RestOrd(aOrd,.T.)
Return lRet 