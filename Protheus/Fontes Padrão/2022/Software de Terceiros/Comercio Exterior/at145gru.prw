#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "AT145GRU.CH" 
#INCLUDE "Totvs.CH" 

/*
Programa   : AT145GRU
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
Revis�o    : Altera��o do MenuDef para adapta��o de constru��o de codigo estabelecendo o padr�o MVC
Data/Hora  : 14/03/11 12:00 - Clayton Reis Fernandes
*/ 
Static Function MenuDef() 
Local aRotina:= {}

If !EasyHasMVC()
   Private cAvStaticCall := "AT145GRU"
   Return StaticCall(EECAT145, MenuDef) 
EndIf 
   
//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.AT145GRU" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.AT145GRU" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.AT145GRU" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.AT145GRU" OPERATION 5 ACCESS 0

Return aRotina

//CRF
Function MVC_AT145GRU()
Local oBrowse                    

//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EEH") //Informando o Alias                                             `
oBrowse:SetMenuDef("AT145GRU") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Grupo de Produtos
oBrowse:Activate()

Return    

//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruEEH := FWFormStruct( 1, "EEH") //Monta a estrutura da tabela EEH

/*Cria��o do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP012', /*bPreValidacao*/, {|oMdl| at145lPos( oMdl )}/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela EEH
oModel:AddFields( 'EECP012_EEH',/*nOwner*/,oStruEEH, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Grupo de Produtos
  
Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("AT145GRU")

// Cria a estrutura a ser usada na View
Local oStruEEH:=FWFormStruct(2,"EEH")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP012_EEH', oStruEEH)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP012_EEH') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 
/*
  FormModel PosValid at145lPos
 */
Static Function at145lPos( oModel )    
   Local nOperation := oModel:GetOperation()
   Local lRet := .T.

   If ( nOperation == MODEL_OPERATION_DELETE .And. VldIdioma(EEH->EEH_COD,EEH->EEH_IDIOMA) )
      Help( ,, "HELP","at145Pos", "N�o � permitida exclus�o de um grupo relacionado a um cadastro de fam�lia de produtos.", 1, 0)      
      lRet := .F.
   EndIf

Return lRet
/* 
  Valida��o para que quando exista fam�lia de produtos j� cadastrado com o grupo n�o permitir a exclus�o 
 */
Static Function VldIdioma(cCod,cIdioma)
Local lRet := .F.
Local cTrb := getNextAlias()

beginSql Alias cTrb
  SELECT * FROM %Table:EEH% EEH
  INNER JOIN %Table:SYC% YC
  ON YC.YC_FILIAL=%xFilial:SYC%
  AND YC.YC_COD_RL = EEH.EEH_COD
  AND YC.YC_IDIOMA = EEH.EEH_IDIOMA
  AND YC.%notDel%
  WHERE EEH.%notDel%
  AND EEH.EEH_FILIAL = %xFilial:EEH%
  AND EEH.EEH_COD = %Exp:cCod%
  AND EEH.EEH_IDIOMA = %Exp:cIdioma%
endSql

if (cTrb)->(!eof())
  lRet := .T.
endif

(cTrb)->(dbCloseArea())

Return lRet
