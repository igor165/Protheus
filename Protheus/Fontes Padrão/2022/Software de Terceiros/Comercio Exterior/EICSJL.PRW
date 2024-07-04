#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICSJL.CH"
/*
Programa   : EICSJL
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:09 
Obs.       : Criado com gerador automático de fontes 
*/ 


/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:09 
*/ 
Static Function MenuDef()
Local aRotina := {}

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"       OPERATION 1 ACCESS 0 //Pesquisar
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.EICSJL" OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.EICSJL" OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.EICSJL" OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.EICSJL" OPERATION 5 ACCESS 0 //Excluir

Return aRotina

// CRF
Function EICSJL()
Local oBrowse                    
//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SJL") //Informando o Alias
oBrowse:SetMenuDef("EICSJL") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001) //Especificação Para N.v.e
oBrowse:Activate()
Return



//crf
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSJL := FWFormStruct( 1, "SJL") //Monta a estrutura da tabela SJL

//Adiciona a propriedade de validação no campo JL_ESPECIF para que não haja inclusão de valores já existentes
oStruSJL:SetProperty('JL_ESPECIF', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID,'ExistChav("SJL", M->JL_NCM+M->JL_ATRIB+M->JL_ESPECIF)' ) )

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EICSJL', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela SJL
oModel:AddFields( 'SJLMASTER',/*nOwner*/,oStruSJL, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Especificação Para N.v.e

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})

Return oModel



//crf
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICSJL")

// Cria a estrutura a ser usada na View
Local oStruSJL:=FWFormStruct(2,"SJL")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('SJLMASTER', oStruSJL)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'SJLMASTER') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 