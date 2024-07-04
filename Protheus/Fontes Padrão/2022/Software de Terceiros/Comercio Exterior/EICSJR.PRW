#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"   
#INCLUDE "EICSJR.CH"
/*
Programa   : EICSJR
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:09 
Obs.       : Criado com gerador automático de fontes 
Revisão    : Clayton Fernandes - 31/03/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:09                    
Revisão    : Clayton Fernandes - 31/03/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/ 

Static Function MenuDef() 
Local aRotina := {}                       

If !EasyHasMVC()
   Private cAvStaticCall := "EICSJR"
   Return StaticCall(EICCADGE, MenuDef) 
EndIf

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EICSJR" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EICSJR" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EICSJR" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EICSJR" OPERATION 5 ACCESS 0

Return aRotina  
                                           
                      
Function MVC_EICSJR()
Local oBrowse                                             

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SJR") //Informando o Alias                                             `
oBrowse:SetMenuDef("EICSJR") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Motiv. Adm. temporia
oBrowse:Activate()

Return 
 
//CRF 
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSJR := FWFormStruct( 1, "SJR") //Monta a estrutura da tabela SJR
//Local bCommit  := {|oMdl| EasyMVCGrava(oMdl,"SJR")}                                                 


/*Criação do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'IMPP009', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela SJR
oModel:AddFields( 'EICP009_SJR',/*nOwner*/,oStruSJR, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Motiv. Adm. temporia

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})
  
  
Return oModel
  

//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICSJR")

// Cria a estrutura a ser usada na View
Local oStruSJR:=FWFormStruct(2,"SJR")                        

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EICP009_SJR', oStruSJR)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EICP009_SJR') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 
