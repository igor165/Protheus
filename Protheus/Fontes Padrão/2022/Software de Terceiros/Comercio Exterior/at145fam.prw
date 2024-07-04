#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AT145FAM.CH"

/*
Programa   : AT145FAM
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:10 
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
Data/Hora  : 25/04/07 11:46:10 
*/ 
Static Function MenuDef() 
Local aRotina := {}
Private cAvStaticCall := "AT145FAM"




If !EasyHasMVC()
   Private cAvStaticCall := "AT145FAM"
   Return StaticCall(EECAT145, MenuDef) 
EndIf 
   
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.AT145FAM" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.AT145FAM" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.AT145FAM" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.AT145FAM" OPERATION 5 ACCESS 0

Return aRotina


Function MVC_AT145FAM()
Local oBrowse                    
Local lExecAuto := Type("aCapAuto") == "A" .And. Type("nOpcAuto") == "N"
Local oAvObject := AvObject():New()
Private aRotina
Private lMsErroAuto := .F.

If !lExecAuto	
   //CRIAÇÃO DA MBROWSE
   oBrowse := FWMBrowse():New() //Instanciando a Classe
   oBrowse:SetAlias("SYC") //Informando o Alias                                             `
   oBrowse:SetMenuDef("AT145FAM") //Nome do fonte do MenuDef
   oBrowse:SetDescription(STR0001) //Família de Produtos
   oBrowse:Activate()
Else
   aRotina := MenuDef()
   oModel := ModelDef()
   lMsErroAuto := !EasyMVCAuto("AT145FAM",nOpcAuto,{{"EECP011_SYC" ,aCapAuto}},@oAvObject)
   If lMsErroAuto
      AEval(oAvObject:aError,{|X| AutoGrLog(x)}) 
   EndIf
EndIf

Return    

//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSYC := FWFormStruct( 1, "SYC") //Monta a estrutura da tabela SYC

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP011', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela SYC     
oModel:AddFields( 'EECP011_SYC',/*nOwner*/,oStruSYC, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001) //Família de Produtos

oModel:SetPrimaryKey({'YC_FILIAL'},{'YC_COD'},{'YC_IDIOMA'})

  
Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("AT145FAM")

// Cria a estrutura a ser usada na View
Local oStruSYC:=FWFormStruct(2,"SYC")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP011_SYC', oStruSYC)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP011_SYC') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView   
