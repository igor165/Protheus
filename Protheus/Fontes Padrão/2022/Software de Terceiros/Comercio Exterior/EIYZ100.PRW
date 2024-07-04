#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EIYZ100.CH"

/*
Programa   : EIYZ100
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:07 
Obs.       : Criado com gerador automático de fontes 
RevisãO    : Clayton Fernandes - 29/03/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:07 
*/ 
Static Function MenuDef() 
Local aRotina := {}
   If !EasyHasMVC()
      Private cAvStaticCall := "EIYZ100"
      Return StaticCall(EICCAD00, MenuDef) 
   EndIf

   
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EIYZ100" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EIYZ100" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EIYZ100" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EIYZ100" OPERATION 5 ACCESS 0

Return aRotina


//CRF
Function MVC_EIYZ100()
Local oBrowse                    

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SYZ") //Informando o Alias                                             `
oBrowse:SetMenuDef("EIYZ100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Produtos Suframa
oBrowse:Activate()

Return    

//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSYZ := FWFormStruct( 1, "SYZ") //Monta a estrutura da tabela SYZ

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'IMPP001', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela SYZ
oModel:AddFields( 'EICP001_SYZ',/*nOwner*/,oStruSYZ, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Produtos Suframa

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})
  
Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EIYZ100")

// Cria a estrutura a ser usada na View
Local oStruSYZ:=FWFormStruct(2,"SYZ")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EICP001_SYZ', oStruSYZ)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EICP001_SYZ') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 