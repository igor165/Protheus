#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EECAF400.CH"


/*
Programa   : EECAF400
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:11 
Obs.       : Criado com gerador automático de fontes 
Revisão    : Clayton Fernandes - 29/03/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:11 
*/ 
Static Function MenuDef() 
Local aRotina := {}
If !EasyHasMVC()
   Private cAvStaticCall := "EECAF400"
   Return StaticCall(EECCAD00, MenuDef) 
EndIf
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0002    ACTION "AxPesqui"          OPERATION 1 ACCESS 0 //STR0002 "Pesquisar"
ADD OPTION aRotina TITLE STR0003    ACTION "VIEWDEF.eecaf400" OPERATION 2 ACCESS 0 //STR0003 "Visualizar"
ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.eecaf400" OPERATION 3 ACCESS 0 //STR0004 "Incluir"
ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.eecaf400" OPERATION 4 ACCESS 0 //STR0005 "Alterar"
ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.eecaf400" OPERATION 5 ACCESS 0 //STR0006 "Excluir"

Return aRotina
Function MVC_EECAF400()
Local oBrowse                    

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SYB") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECAF400") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Despesas
oBrowse:Activate()

Return  

//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSYB := FWFormStruct( 1, "SYB") //Monta a estrutura da tabela SYB

/*Criação do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP016', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela SYB
oModel:AddFields( 'EECP016_SYB',/*nOwner*/,oStruSYB, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Despesas

//Utiliza a chave primaria
oModel:SetPrimaryKey({'YB_FILIAL'},{'YB_DESP'})
  
  
Return oModel

//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECAF400")

// Cria a estrutura a ser usada na View
Local oStruSYB:=FWFormStruct(2,"SYB")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP016_SYB', oStruSYB)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP016_SYB') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 