#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICSJL.CH"
/*
Programa   : EICSJL
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em fun��es que n�o est�o 
             definidas em um programa com o mesmo nome da fun��o. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:09 
Obs.       : Criado com gerador autom�tico de fontes 
*/ 


/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da fun��o MenuDef no programa onde a fun��o est� declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:09 
*/ 
Static Function MenuDef()
Local aRotina := {}

//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"       OPERATION 1 ACCESS 0 //Pesquisar
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.EICSJL" OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.EICSJL" OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.EICSJL" OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.EICSJL" OPERATION 5 ACCESS 0 //Excluir

Return aRotina

// CRF
Function EICSJL()
Local oBrowse                    
//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SJL") //Informando o Alias
oBrowse:SetMenuDef("EICSJL") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001) //Especifica��o Para N.v.e
oBrowse:Activate()
Return



//crf
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSJL := FWFormStruct( 1, "SJL") //Monta a estrutura da tabela SJL

//Adiciona a propriedade de valida��o no campo JL_ESPECIF para que n�o haja inclus�o de valores j� existentes
oStruSJL:SetProperty('JL_ESPECIF', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID,'ExistChav("SJL", M->JL_NCM+M->JL_ATRIB+M->JL_ESPECIF)' ) )

/*Cria��o do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EICSJL', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela SJL
oModel:AddFields( 'SJLMASTER',/*nOwner*/,oStruSJL, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Especifica��o Para N.v.e

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