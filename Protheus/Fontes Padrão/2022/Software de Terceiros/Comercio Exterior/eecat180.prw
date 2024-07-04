#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EECAT180.CH"

/*
Programa   : EECAT180
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
   Private cAvStaticCall := "EECAT180"
   Return StaticCall(EECCAD00, MenuDef)  
EndIf

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECAT180" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECAT180" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECAT180" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECAT180" OPERATION 5 ACCESS 0

   //LGS-04/09/2015 - Tabela de/Para - FIERGS
   //A - Norma
   IF AvFlags("TABELA_DE_PARA_FIERGS")
      ADD OPTION aRotina TITLE "Tabela de/Para" ACTION 'TE110Inclui("A",EEI->EEI_COD)' OPERATION 4 ACCESS 0
   EndIf

Return aRotina  


Function MVC_EECAT180()
Local oBrowse                    

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EEI") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECAT180") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Normas
oBrowse:Activate()

Return 
 
//CRF 
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruEEI := FWFormStruct( 1, "EEI") //Monta a estrutura da tabela EEI
Local bCommit  := {|oMdl| EasyMVCGrava(oMdl,"EEI")}                                                 


/*Criação do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP017', /*bPreValidacao*/, /*bPosValidacao*/, bCommit, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela EEI
oModel:AddFields( 'EECP017_EEI',/*nOwner*/,oStruEEI, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Normas

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})
             
  
  
  
  
Return oModel

//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECAT180")

// Cria a estrutura a ser usada na View
Local oStruEEI:=FWFormStruct(2,"EEI")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP017_EEI', oStruEEI)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP017_EEI') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 

