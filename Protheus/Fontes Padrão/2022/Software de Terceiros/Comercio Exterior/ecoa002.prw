#INCLUDE "PROTHEUS.CH"
#INCLUDE "ECOA002.CH"
#INCLUDE "FWMVCDEF.CH"


/*
Programa   : ECOA002
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:07 
Obs.       : Criado com gerador automático de fontes   
Revisão    : Clayton Fernandes - 29/03/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:07 
*/ 
Static Function MenuDef() 

Local aRotina := {}
Local aRotAdic := {}   

   If !EasyHasMVC()
      Private cAvStaticCall := "ECOA002"
      Return StaticCall(ECOCAD00, MenuDef) 
   EndIf
   
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ECOA002" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ECOA002" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ECOA002" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ECOA002" OPERATION 5 ACCESS 0

// P.E. utilizado para adicionar itens no Menu da mBrowse
/*If EasyEntryPoint("EAT140MNU")
   aRotAdic := ExecBlock("EAT140MNU",.f.,.f.)
   If ValType(aRotAdic) == "A"
      AEval(aRotAdic,{|x| AAdd(aRotina,x)})
   EndIf
EndIf */
    
Return aRotina 
    

// CRF
Function MVC_ECO002A()
Local oBrowse                    

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EC6") //Informando o Alias                                             `
oBrowse:SetMenuDef("ECOA002") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0002)//Contas
oBrowse:Activate()

Return    
                                                    


//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruEC6 := FWFormStruct( 1, "EC6") //Monta a estrutura da tabela SY9

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP018', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela SY9
oModel:AddFields( 'EECP018_EC6',/*nOwner*/,oStruEC6, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Contas

//Utiliza a chave primaria
//oModel:SetPrimaryKey({'YE_FILIAL'},{'DTOS(YE_DATA)'},{'YE_MOEDA'})
  
Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("ECOA002")

// Cria a estrutura a ser usada na View
Local oStruEC6:=FWFormStruct(2,"EC6")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP018_EC6', oStruEC6)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP018_EC6') 

if EC6->(fieldpos("EC6_MVBCLQ")) > 0 .and. oView:HasField('EECP018_EC6','EC6_MVBCLQ') .and. !avflags("EEC_LOGIX")
   oStruEC6:RemoveField('EC6_MVBCLQ')
endif

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView