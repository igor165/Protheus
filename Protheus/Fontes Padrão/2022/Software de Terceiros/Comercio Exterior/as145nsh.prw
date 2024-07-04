#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AS145NSH.CH"

/*
Programa   : AS145NSH
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
Local aRotina := {}
Local aRotAdic := {}   
                   
If !EasyHasMVC()
   Private cAvStaticCall := "AS145NSH"
   Return StaticCall(EECAS145, MenuDef) 
EndIf 
   
//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.AS145NSH" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.AS145NSH" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.AS145NSH" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.AS145NSH" OPERATION 5 ACCESS 0

// P.E. utilizado para adicionar itens no Menu da mBrowse
/*If EasyEntryPoint("EAT140MNU")
   aRotAdic := ExecBlock("EAT140MNU",.f.,.f.)
   If ValType(aRotAdic) == "A"
      AEval(aRotAdic,{|x| AAdd(aRotina,x)})
   EndIf
EndIf */
    
Return aRotina       

// CRF
Function MVC_ASNSH145()
Local oBrowse                    

//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SJ1") //Informando o Alias                                             `
oBrowse:SetMenuDef("AS145NSH") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Naladi S H
oBrowse:Activate()

Return    
                                                    


//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSJ1 := FWFormStruct( 1, "SJ1") //Monta a estrutura da tabela SJ1

/*Cria��o do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP021', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela SJ1
oModel:AddFields( 'EECP021_SJ1',/*nOwner*/,oStruSJ1, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Naladi S H

//Utiliza a chave primaria
//oModel:SetPrimaryKey({'YE_FILIAL'},{'DTOS(YE_DATA)'},{'YE_MOEDA'})
  
Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("AS145NSH")

// Cria a estrutura a ser usada na View
Local oStruSJ1:=FWFormStruct(2,"SJ1")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP021_SJ1', oStruSJ1)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP021_SJ1') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 


                        