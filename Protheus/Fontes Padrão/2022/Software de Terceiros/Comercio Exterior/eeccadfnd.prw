#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EECCADFND.CH"

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
   Private cAvStaticCall := "EECCADFND"
   Return StaticCall(EECCAD02, MenuDef) 
EndIf 
   
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"          OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECCADFND" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECCADFND" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECCADFND" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECCADFND" OPERATION 5 ACCESS 0

Return aRotina

//CRF
Function MVC_CADFNDEEC()
Local oBrowse                    

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EY4") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECCADFND") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//First Notice Day
oBrowse:Activate()

Return    

//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruEY4 := FWFormStruct( 1, "EY4") //Monta a estrutura da tabela EEH

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP033', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela EEH
oModel:AddFields( 'EECP033_EY4',/*nOwner*/,oStruEY4, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//First Notice Day
 
oModel:SetPrimaryKey({''}) 
 
  
Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECCADFND")

// Cria a estrutura a ser usada na View
Local oStruEY4:=FWFormStruct(2,"EY4")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP033_EY4', oStruEY4)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP033_EY4') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 