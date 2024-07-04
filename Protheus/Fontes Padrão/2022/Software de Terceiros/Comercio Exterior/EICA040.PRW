#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICA040.CH"
/*
Programa   : EICA040
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão
             definidas em um programa com o mesmo nome da função.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/04/07 11:46:06
Obs.       : Criado com gerador automático de fontes
Revisão    : Clayton Fernandes - 07/04/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/04/07 11:46:06
Revisão    : Clayton Fernandes - 07/04/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/

Static Function MenuDef()
Local aRotina := {}

If !EasyHasMVC()
   Private cAvStaticCall := "EICA040"

   Return StaticCall(EICCAD00, MenuDef)
EndIf

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0		//"Pesquisar"
ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.EICA040" OPERATION 2 ACCESS 0		//"Visualizar"
ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.EICA040" OPERATION 3 ACCESS 0		//"Incluir"
ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.EICA040" OPERATION 4 ACCESS 0		//"Alterar"
ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.EICA040" OPERATION 5 ACCESS 0		//"Excluir"

Return aRotina


Function MVC_040AEIC()
Local oBrowse

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SY4") //Informando o Alias                                             `
oBrowse:SetMenuDef("EICA040") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Agentes Transp.
oBrowse:Activate()

Return

//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruSY4 := FWFormStruct( 1, "SY4") //Monta a estrutura da tabela SJO


/*Criação do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'IMPP032', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela SJO
oModel:AddFields( 'EICP032_SY4',/*nOwner*/,oStruSY4, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Agentes Transp.

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})


Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICA040")

// Cria a estrutura a ser usada na View
Local oStruSY4:=FWFormStruct(2,"SY4")

Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EICP032_SY4', oStruSY4)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EICP032_SY4')

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView

