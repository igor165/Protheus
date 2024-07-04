#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EECPEN100.CH"


/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Clayton Fernandes
Data/Hora  : 23/03/11 15:46:10 
Revisão    : Clayton Fernandes - 29/03/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/ 
Static Function MenuDef() 
Local aRotina := {}

/* AOM - 04/11/2011
If !EasyHasMVC()
   Private cAvStaticCall := "EECPEN100"
   Return StaticCall(EECPEN100, MenuDef) 
EndIf 
*/
   
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECPEN100" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECPEN100" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECPEN100" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECPEN100" OPERATION 5 ACCESS 0

Return aRotina


//CRF
Function MVC_PEN100EEC()
Local oBrowse                    

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EXX") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECPEN100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Peneira
oBrowse:Activate()

Return    

//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruEXX := FWFormStruct( 1, "EXX") //Monta a estrutura da tabela EEH

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP029', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela EEH
oModel:AddFields( 'EECP029_EXX',/*nOwner*/,oStruEXX, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Peneira
 
oModel:SetPrimaryKey({''}) 
 
  
Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECPEN100")

// Cria a estrutura a ser usada na View
Local oStruEXX:=FWFormStruct(2,"EXX")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP029_EXX', oStruEXX)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP029_EXX') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 