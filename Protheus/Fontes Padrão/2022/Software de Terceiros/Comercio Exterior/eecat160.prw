#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EECAT160.CH"

/*
Programa   : EECAT160
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
Local aRotAdic := {}   

   If !EasyHasMVC()
      Private cAvStaticCall := "EECAT160"
      Return StaticCall(EECCAD00, MenuDef) 
   EndIf
   
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECAT160" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECAT160" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECAT160" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECAT160" OPERATION 5 ACCESS 0

// P.E. utilizado para adicionar itens no Menu da mBrowse
/*If EasyEntryPoint("EAT140MNU")
   aRotAdic := ExecBlock("EAT140MNU",.f.,.f.)
   If ValType(aRotAdic) == "A"
      AEval(aRotAdic,{|x| AAdd(aRotina,x)})
   EndIf
EndIf */
    
Return aRotina 
    

// CRF
Function MVC_EEC160AT()
Local oBrowse                    

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SY9") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECAT160") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Portos/Aeroportos
oBrowse:Activate()

Return    
                                                    


//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSY9 := FWFormStruct( 1, "SY9") //Monta a estrutura da tabela SY9
Local bCommit := {|oModel| commit(oModel)}

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP014', /*bPreValidacao*/, /*bPosValidacao*/, bCommit, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela SY9
oModel:AddFields( 'EECP014_SY9',/*nOwner*/,oStruSY9, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Portos/Aeroportos

//Utiliza a chave primaria
//oModel:SetPrimaryKey({'YE_FILIAL'},{'DTOS(YE_DATA)'},{'YE_MOEDA'})
  
Return oModel

Static Function commit(oModel)
Local cAlias := "QUERY"
Local lAtuVias := .F.

If cidadeAlt(oModel)
  viasDest(oModel, cAlias)
  If temVias(cAlias)
    lAtuVias := MsgYesNo(STR0003, STR0002) // Foram encontradas vias de transporte que fazem uso deste cadastro. Deseja atualizar a descrição da cidade destas vias de transportes? | Aviso
  EndIf
EndIf
BEGIN TRANSACTION
  If lAtuVias
    updateVias(oModel, cAlias)
  EndIf
  close(cAlias)
  FWFormCommit(oModel,,)
END TRANSACTION
Return .T.

// Verifica se a descrição da cidade foi alterada
Static Function cidadeAlt(oModel)
Return SY9->Y9_CIDADE != oModel:getValue("EECP014_SY9", "Y9_CIDADE")

// Verifica se existe algum cadastro de via de transporte no arquivo de trabalho
Static Function temVias(cAlias)
Return !(cAlias)->(Eof()) .And. !(cAlias)->(Bof())

Static Function updateVias(oModel, cAlias)
Local cSigla := oModel:getValue("EECP014_SY9", "Y9_SIGLA")
Local cDescCidad := oModel:getValue("EECP014_SY9", "Y9_CIDADE")

While !(cAlias)->(Eof()) .And. !(cAlias)->(Bof()) 
  SYR->(dbGoTo((cAlias)->RECNO))
  SYR->(RecLock("SYR"), .F.)

  If SYR->YR_ORIGEM == cSigla
    SYR->YR_CID_ORI := cDescCidad
  EndIf
  If SYR->YR_DESTINO == cSigla
    SYR->YR_CID_DES := cDescCidad
  EndIf

  SYR->(MsUnlock())
  (cAlias)->(dbSkip())
EndDo

Return

// Cria uma work que possui todas as vias com a mesma sigla da tela de cadastro do Portos/Aeroportos
Static Function viasDest(oModel, cAlias)
  Local cSigla := oModel:getValue("EECP014_SY9", "Y9_SIGLA")

  BeginSql Alias cAlias
    SELECT SYR.R_E_C_N_O_ as RECNO
    FROM %table:SYR% SYR
    WHERE SYR.%NotDel% AND SYR.YR_FILIAL = %xFilial:SYR% AND (YR_ORIGEM = %Exp:cSigla% OR YR_DESTINO = %Exp:cSigla%)
  EndSql
Return

Static Function close(cAlias)
  If Select(cAlias) > 0
    (cAlias)->(dbCloseArea())
  EndIf
Return

//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECAT160")

// Cria a estrutura a ser usada na View
Local oStruSY9:=FWFormStruct(2,"SY9")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP014_SY9', oStruSY9)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP014_SY9') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 