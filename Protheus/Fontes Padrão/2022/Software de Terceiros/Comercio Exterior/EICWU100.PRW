#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "EICWU100.CH"

/*
Programa   : EICWU100
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Clayton Reis Fernandes
Data/Hora  : 30/03/11 10:06 
Obs.       : Criado com gerador automático de fontes 
Revisão    : Clayton Fernandes - 29/03/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Clayton Reis Fernandes
Data/Hora  : 30/03/2011 - 10:07
*/ 
Static Function MenuDef() 
Local aRotina := {}

If !EasyHasMVC()
   Private cAvStaticCall := "EICWU100"
   Return StaticCall(EICCAD00, MenuDef)  
EndIf

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EICWU100" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EICWU100" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EICWU100" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EICWU100" OPERATION 5 ACCESS 0

Return aRotina  


Function MVC_EICWU100()
Local oBrowse                                             

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SWU") //Informando o Alias                                             `
oBrowse:SetMenuDef("EICWU100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Modelo de P.o.
oBrowse:Activate()

Return 
 
//CRF 
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSWU := FWFormStruct( 1, "SWU") //Monta a estrutura da tabela SWU
Local bCommit  := {|oMdl| EasyMVCGrava(oMdl,"SWU")}                                                 


/*Criação do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'IMPP002', /*bPreValidacao*/, /*bPosValidacao*/, bCommit, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela SWU
oModel:AddFields( 'EICP002_SWU',/*nOwner*/,oStruSWU, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Modelo de P.o.

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})
             
  
  
  
  
Return oModel

//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICWU100")

// Cria a estrutura a ser usada na View
Local oStruSWU:=FWFormStruct(2,"SWU")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EICP002_SWU', oStruSWU)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EICP002_SWU') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 