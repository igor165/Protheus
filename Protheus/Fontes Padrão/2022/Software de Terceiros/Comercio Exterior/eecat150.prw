#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EECAT150.CH"
#INCLUDE "AVERAGE.CH"  // GFP - 30/01/2012

/*
Programa   : EECAT150
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em fun��es que n�o est�o 
             definidas em um programa com o mesmo nome da fun��o. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:10 
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
Data/Hora  : 25/04/07 11:46:10 
Revis�o    : Clayton Fernandes - 29/03/2011
Obs        : Adapta��o do Codigo para o padr�o MVC
*/ 
Static Function MenuDef() 
Local   aRotina := {}
//Local   aRotAdic := {}


   If !EasyHasMVC()
      Private cAvStaticCall := "EECAT150"
      Return StaticCall(EECCAD00, MenuDef) 
   EndIf
   
//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECAT150" OPERATION 2 ACCESS 0
//ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECAT150" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "AT150INC"         OPERATION 3 ACCESS 0 //LGS-12/08/2014
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECAT150" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECAT150" OPERATION 5 ACCESS 0

// P.E. utilizado para adicionar itens no Menu da mBrowse
/*If EasyEntryPoint("EAT140MNU")
   aRotAdic := ExecBlock("EAT140MNU",.f.,.f.)
   If ValType(aRotAdic) == "A"
      AEval(aRotAdic,{|x| AAdd(aRotina,x)})
   EndIf
EndIf */
    
Return aRotina 
    

// CRF
Function MVC_EEC150AT()
Local oBrowse 
Private nOpc  // GFP - 16/08/2013
                   

//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EX7") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECAT150") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Mensagens
oBrowse:Activate()

Return    
                                                    


//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruEX7 := FWFormStruct( 1, "EX7") //Monta a estrutura da tabela EX7

/*Cria��o do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP014', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela EX7
oModel:AddFields( 'EECP014_EX7',/*nOwner*/,oStruEX7, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Mensagens

//Utiliza a chave primaria
oModel:SetPrimaryKey({'EX7_FILIAL'},{'DTOS(EX7_DATA)'},{'EX7_CODBOL'},{'EX7_MESANO'})

 
  
Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECAT150")

// Cria a estrutura a ser usada na View
Local oStruEX7:=FWFormStruct(2,"EX7")

Local oView 


nOpc := oModel:GetOperation() 

//GFP - 30/01/2012 - Defini��es de WHEN dos campos
INCLUI := nOpc == INCLUIR
ALTERA := nOpc == ALTERAR
EXCLUI := nOpc == EXCLUIR
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP014_EX7', oStruEX7)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP014_EX7') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.) 

Return oView 

/*
Fun��o      : AT150INC
Objetivos   : Apresentar a tela de inclus�o igual a que � apresentada no cenario onde o paramentro MV_AVG0203 == 0
Par�metros  : cAlias  - 'EX7'
              nReg    - 1
              nOpc    - 3 (Inclus�o)
Retorno     : Nil
Autor       : Laercio G S Junior
Data/Hora   : 12/08/2014
*/
*------------------------*
Function AT150INC()
*------------------------*
Local cAlias := "EX7"
Local nReg   := 1 
Local nOpc   := 3

Private cCadastro := STR0002

AT150MAN(cAlias,nReg,nOpc)

Return Nil