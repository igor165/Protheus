#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EECAS101.CH"

/*
Programa   : EECAS101
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
*/ 

Static Function MenuDef() 
Local aRotina:= {}

If !EasyHasMVC() //CRF
   Private cAvStaticCall := "AS101EEC"
   Return StaticCall(EECCAD00, MenuDef) 
EndIf 
   
//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECAS101" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECAS101" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECAS101" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECAS101" OPERATION 5 ACCESS 0

Return aRotina

//CRF
Function MVC_AS101EEC()
Local oBrowse                    

//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EEF") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECAS101") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Modalidade Pgto
oBrowse:Activate()              

Return    

//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruEEF := FWFormStruct( 1, "EEF") //Monta a estrutura da tabela EEF

/*Cria��o do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP025', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela EEF
oModel:AddFields( 'EECP025_EEF',/*nOwner*/,oStruEEF, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Modalidade Pgto
  
Return oModel



//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECAS101")

// Cria a estrutura a ser usada na View
Local oStruEEF:=FWFormStruct(2,"EEF")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP025_EEF', oStruEEF)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP025_EEF') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 