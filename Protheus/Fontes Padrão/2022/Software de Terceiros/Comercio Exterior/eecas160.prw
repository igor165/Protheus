#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EECAS160.CH"
/*
Programa   : EECAS160
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
Revisão    : Clayton Fernandes - 29/03/2011
Obs        : Adaptação do Codigo para o padrão MVC 
*/ 

Static Function MenuDef() 
Local aRotina:= {}

If !EasyHasMVC()
   Private cAvStaticCall := "EECAS160"
   Return StaticCall(EECCAD00, MenuDef) 
EndIf 
   
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECAS160" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECAS160" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECAS160" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECAS160" OPERATION 5 ACCESS 0

Return aRotina

//CRF
Function MVC_AS160EEC()
Local oBrowse                    

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SY8") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECAS160") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Fundamento Legal
oBrowse:Activate()              

Return    

//CRF                                                      
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSY8 := FWFormStruct( 1, "SY8") //Monta a estrutura da tabela SY8

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP027', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela SY8
oModel:AddFields( 'EECP027_SY8',/*nOwner*/,oStruSY8, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Fundamento Legal
  
Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECAS160")

// Cria a estrutura a ser usada na View
Local oStruSY8:=FWFormStruct(2,"SY8")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP027_SY8', oStruSY8)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP027_SY8') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 
