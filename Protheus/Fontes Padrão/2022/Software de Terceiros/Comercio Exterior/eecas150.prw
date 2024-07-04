#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EECAS150.CH"
/*
Programa   : EECAS150
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em fun��es que n�o est�o 
             definidas em um programa com o mesmo nome da fun��o. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:11 
Obs.       : Criado com gerador autom�tico de fontes
Revis�o    : Clayton Fernandes - 29/03/2011
Obs        : Adapta��o do Codigo para o padr�o MVC 
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da fun��o MenuDef no programa onde a fun��o est� declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:11 
Revis�o    : Clayton Fernandes - 29/03/2011
Obs        : Adapta��o do Codigo para o padr�o MVC
*/ 

Static Function MenuDef() 
Local aRotina:= {}

If !EasyHasMVC()
   Private cAvStaticCall := "EECAS150"
   Return StaticCall(EECCAD00, MenuDef) 
EndIf 
   
//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECAS150" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECAS150" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECAS150" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECAS150" OPERATION 5 ACCESS 0

Return aRotina

//CRF
Function MVC_AS150EEC()
Local oBrowse                    

//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SJ9") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECAS150") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Agencia Secex
oBrowse:Activate()              

Return    

//CRF                                                      
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSJ9 := FWFormStruct( 1, "SJ9") //Monta a estrutura da tabela SJ9

/*Cria��o do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP026', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela SJ9
oModel:AddFields( 'EECP026_SJ9',/*nOwner*/,oStruSJ9, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Agencia Secex
  
Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECAS150")

// Cria a estrutura a ser usada na View
Local oStruSJ9:=FWFormStruct(2,"SJ9")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP026_SJ9', oStruSJ9)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP026_SJ9') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 