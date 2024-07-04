#Include "EEC.CH"
#Include "EECAD100.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"



/*
Programa        : EECAD100.PRW
Objetivo        : Manuten��o do cadastro de Naturezas utilizadas nos controles da Nova Legisla��o e Regula��o Cambial
Autor           : Rodrigo Mendes Diaz
Data/Hora       : 19/10/2007
Obs. 
*/

/*
Funcao      : EECAD100
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Efetuar manuten��o no cadastro das naturezas das movimenta��es registradas para as contas no exterior.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 19/10/07
Revis�o     : Clayton Fernandes - 29/03/2011
Obs         : Adapta��o do Codigo para o padr�o MVC
*/

Function EECAD100()
Local cArea := Select()

If !EasyCallMVC("MVC_EECAD100",1)//crf
   Begin Sequence
      AxCadastro("EYQ", STR0001) //Cadastro de Naturezas
   End Sequence
   DbSelectArea(cArea)
EndIf 

Return .T.     


/*
Funcao      : MenuDef
Parametros  : Nenhum
Retorno     : 
Objetivos   : Efetuar manuten��o no cadastro 
Autor       : Clayton Fernandes
Data/Hora   : 29/03/2011
Revis�o     : Clayton Fernandes - 29/03/2011
Obs         : Adapta��o do Codigo para o padr�o MVC
*/



*-----------------------
Static Function MenuDef()
*-----------------------
Local aRotina := {}
If !EasyHasMVC() //LRS 05/08/2014 - caso o parametro do MVC estiver 0, foi mudado para n�o dar erro log
   Return aRotina := StaticCall(MATXATU,MENUDEF)
EndIf


//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECAD100" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECAD100" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECAD100" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECAD100" OPERATION 5 ACCESS 0 

Return aRotina  


Function MVC_EECAD100()
Local oBrowse                    

//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EYQ") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECAD100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Cadastro de Naturezas
oBrowse:Activate()

Return 

 //crf
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruEYQ := FWFormStruct( 1, "EYQ") //Monta a estrutura da tabela EEI
//Local bCommit  := {|oMdl| EasyMVCGrava(oMdl,"EYQ")}

/*Cria��o do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP020', /*bPreValidacao*/, /*bPosValidacao*/,/* bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela EEI
oModel:AddFields( 'EECP020_EYQ',/*nOwner*/,oStruEYQ, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Cadastro de Naturezas

//Utiliza a chave primaria
//oModel:SetPrimaryKey({'YB_FILIAL'},{'YB_DESP'})
  
  
Return oModel


//crf
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECAD100")

// Cria a estrutura a ser usada na View
Local oStruEEI:=FWFormStruct(2,"EYQ")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP020_EYQ', oStruEEI)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP020_EYQ') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 
