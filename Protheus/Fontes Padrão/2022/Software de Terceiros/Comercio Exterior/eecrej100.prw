#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EECREJ100.CH"


/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Clayton Fernandes
Data/Hora  : 24/03/11 09:20:07 
Revisão    : Clayton Fernandes - 29/03/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/ 
Static Function MenuDef() 
Local aRotina := {}

If !EasyHasMVC()
   Private cAvStaticCall := "EECREJ100"
   Return StaticCall(MATXATU,MENUDEF)//FDR - 18/07/12 //StaticCall(EECREJ100, MenuDef) 
EndIf 
   
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECREJ100" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECREJ100" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECREJ100" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECREJ100" OPERATION 5 ACCESS 0

Return aRotina

//CRF
Function MVC_REJ100EEC()
Local oBrowse                    

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EY1") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECREJ100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Tipos de Rejeição
oBrowse:Activate()

Return    

//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruEY1 := FWFormStruct( 1, "EY1") //Monta a estrutura da tabela EEH

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP031', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela EEH
oModel:AddFields( 'EECP031_EY1',/*nOwner*/,oStruEY1, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Tipos de Rejeição
 
oModel:SetPrimaryKey({''}) 
 
  
Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECREJ100")

// Cria a estrutura a ser usada na View
Local oStruEY1:=FWFormStruct(2,"EY1")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP031_EY1', oStruEY1)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP031_EY1') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 