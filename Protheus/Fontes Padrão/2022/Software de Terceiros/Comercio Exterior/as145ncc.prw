#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AS145NCC.CH"

/*
Programa   : AS145NCC
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:11 
Obs.       : Criado com gerador automático de fontes 
Revisão     : Clayton Fernandes - 29/03/2011
Obs         : Adaptação do Codigo para o padrão MVC

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
Local aRotAdic := {}   
                   
If !EasyHasMVC()
   Private cAvStaticCall := "AS145NCC"
   Return StaticCall(EECAS145, MenuDef) 
EndIf 
   
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.AS145NCC" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.AS145NCC" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.AS145NCC" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.AS145NCC" OPERATION 5 ACCESS 0

// P.E. utilizado para adicionar itens no Menu da mBrowse
/*If EasyEntryPoint("EAT140MNU")
   aRotAdic := ExecBlock("EAT140MNU",.f.,.f.)
   If ValType(aRotAdic) == "A"
      AEval(aRotAdic,{|x| AAdd(aRotina,x)})
   EndIf
EndIf */
    
Return aRotina       

// CRF
Function MVC_AS145NCC()
Local oBrowse                    

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SJ2") //Informando o Alias                                             `
oBrowse:SetMenuDef("AS145NCC") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Naladi N N C a
oBrowse:Activate()

Return    
                                                    


//crf
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSJ2 := FWFormStruct( 1, "SJ2") //Monta a estrutura da tabela SJ2

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP020', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela SJ2
oModel:AddFields( 'EECP020_SJ2',/*nOwner*/,oStruSJ2, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Naladi N N C a

//Utiliza a chave primaria
//oModel:SetPrimaryKey({'YE_FILIAL'},{'DTOS(YE_DATA)'},{'YE_MOEDA'})
  
Return oModel


//crf
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("AS145NCC")

// Cria a estrutura a ser usada na View
Local oStruSJ2:=FWFormStruct(2,"SJ2")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP020_SJ2', oStruSJ2)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP020_SJ2') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 
