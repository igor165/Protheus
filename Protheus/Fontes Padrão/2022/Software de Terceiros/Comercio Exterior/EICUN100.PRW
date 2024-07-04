#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICUN100.CH"

/*
Programa   : EICUN100
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:08 
Obs.       : Criado com gerador automático de fontes  
RevisãO    : Clayton Fernandes - 31/03/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:08   
RevisãO    : Clayton Fernandes - 31/03/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/ 
Static Function MenuDef() 
Local aRotina := {}

If !EasyHasMVC() 
   Private cAvStaticCall := "EICUN100"
   Return StaticCall(EICCADGE, MenuDef) 
EndIf



//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0		//"Pesquisar"
ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.EICUN100" OPERATION 2 ACCESS 0	//"Visualizar"
ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.EICUN100" OPERATION 3 ACCESS 0	//"Incluir"
ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.EICUN100" OPERATION 4 ACCESS 0	//"Alterar"
ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.EICUN100" OPERATION 5 ACCESS 0	//"Excluir"

Return aRotina  
   


Function MVC_EICUN100()
Local oBrowse                                             

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SAH") //Informando o Alias                                             `
oBrowse:SetMenuDef("EICUN100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Unidades de Medida
oBrowse:Activate()

Return 
 
//CRF 
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSAH := FWFormStruct( 1, "SAH") //Monta a estrutura da tabela SAH
//Local bCommit  := {|oMdl| EasyMVCGrava(oMdl,"SAH")}                                                 


/*Criação do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'IMPP004', /*bPreValidacao*/, /*bPosValidacao*/,/* bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela SAH
oModel:AddFields( 'EICP004_SAH',/*nOwner*/,oStruSAH, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Unidades de Medida

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})
             
  
  
  
Return oModel

//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICUN100")

// Cria a estrutura a ser usada na View
Local oStruSAH:=FWFormStruct(2,"SAH")

Local oView  
 
// Cria o objeto de View                         
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EICP004_SAH', oStruSAH)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EICP004_SAH') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 
