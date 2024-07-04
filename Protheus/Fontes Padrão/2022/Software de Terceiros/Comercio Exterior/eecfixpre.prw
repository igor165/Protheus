#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EECFIXPRE.CH"


/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Clayton Fernandes
Data/Hora  : 24/03/11 09:20:07 
*/ 
Static Function MenuDef() 
Local aRotina := {}

If !EasyHasMVC()
   Private cAvStaticCall := "EECFIXPRE"
   Return StaticCall(MATXATU,MENUDEF)//FDR - 18/07/12 //StaticCall(EECFIXPRE, MenuDef) 
EndIf 
   
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECFIXPRE" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECFIXPRE" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECFIXPRE" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECFIXPRE" OPERATION 5 ACCESS 0

Return aRotina


Function MVC_FIX100EEC()
Local oBrowse                    

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EY0") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECFIXPRE") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Condições de Fix. de Preço
oBrowse:Activate()

Return    


*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruEY0 := FWFormStruct( 1, "EY0") //Monta a estrutura da tabela EEH

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP032', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela EEH
oModel:AddFields( 'EECP032_EY0',/*nOwner*/,oStruEY0, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Condições de Fix. de Preço
 
oModel:SetPrimaryKey({''}) 
 
  
Return oModel



*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECFIXPRE")

// Cria a estrutura a ser usada na View
Local oStruEY0:=FWFormStruct(2,"EY0")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP032_EY0', oStruEY0)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP032_EY0') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 

