#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EECQUAL100.CH"


/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada adaptada para padrão MVC. 
Autor      : Clayton Fernandes
Data/Hora  : 22/02/11 11:36:59 
*/ 

Static Function MenuDef() 
Local aRotina:= {}

If !EasyHasMVC()//CRF
   Private cAvStaticCall := "EECQUAL100"
   Return StaticCall(EECCAD02, MenuDef) 
EndIf 
   
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECQUAL100" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECQUAL100" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECQUAL100" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECQUAL100" OPERATION 5 ACCESS 0

Return aRotina


Function MVC_EECCAD02()
Local oBrowse                    

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EXW") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECQUAL100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Qualidades
oBrowse:Activate()              

Return    

//CRF                                                      
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruEXW := FWFormStruct( 1, "EXW", /*bAvalCampo*/,/*lViewUsado*/) //Monta a estrutura da tabela EXW

//Local bCarga   := {|oMdl| CargaDados(oMdl)}
Local bCommit  := {|oMdl| EasyMVCGrava(oMdl,"EXW")}
/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP028', /*bPreValidacao*/, /*bPosValidacao*/, bCommit /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela EXW
oModel:AddFields( 'EECP028_EXW',/*nOwner*/,oStruEXW, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Qualidades

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})
  
Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECQUAL100")

// Cria a estrutura a ser usada na View
Local oStruEXW:=FWFormStruct(2,"EXW")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP028_EXW', oStruEXW)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP028_EXW') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 




Static Function CargaDados(oMdl)

oMdl:SetValue("EECP028_EXW", "EXW_DSCQUA",MSMM(EXW->EXW_QUADES, AvSx3("EXW_DSCQUA",AV_TAMANHO),,,LERMEMO))

Return

