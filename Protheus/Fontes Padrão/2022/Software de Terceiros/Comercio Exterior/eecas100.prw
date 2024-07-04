#INCLUDE "PROTHEUS.CH"
#INCLUDE "EECAS100.CH"
#INCLUDE "FWMVCDEF.CH"
#include  "Average.ch"
#include "EEC.CH"              
                                                       
#DEFINE ENTER CHR(13) + CHR(10)

/*
Programa   : EECAS100
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:11 
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
Data/Hora  : 25/04/07 11:46:11   
Revisão    : Clayton Fernandes - 21/03/2011
Obs        : Atualização do codigo fonte para adequação ao padrão MVC
*/ 


Static Function MenuDef() 
Local aRotina:= {}

If !EasyHasMVC()
   Private cAvStaticCall := "EECAS100"
   Return StaticCall(EECCAD00, MenuDef) 
EndIf 
   
//Adiciona os botões na MBROWSE - CRF - 21/03/2011
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECAS100" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECAS100" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECAS100" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECAS100" OPERATION 5 ACCESS 0

Return aRotina



/* 
Funcao     : AS100V_Enq() 
Parametros : cEnq     - Codigo de Enquadramento a ser analisado.
             cCodEnq1 - Código de Enquadramento que ja esta preenchido no embarque.
             cCodEnq2 - Código de Enquadramento que ja esta preenchido no embarque.
             cCodEnq3 - Código de Enquadramento que ja esta preenchido no embarque.
Retorno    : lRet
Objetivos  : Analisar cEnq e confirmar se há vinculação com os cCodEnq's
Autor      : Olliver Adami Pedroso 
Data/Hora  : 27/01/11 11:46:11 
*/                   
Function AS100V_Enq(cEnq,cCodEnq1,cCodEnq2,cCodEnq3)

Local x          := 0
Local aCodEnq    := {}
Local lRet       := .T.
Default cCodEnq2 := ""
Default cCodEnq3 := ""

    
AADD(aCodEnq,cCodEnq1)
If !Empty(cCodEnq2)
   AADD(aCodEnq,cCodEnq2)
   If !Empty(cCodEnq3)
      AADD(aCodEnq,cCodEnq3)
   EndIf
EndIf
      
If Select("EED")==0
   DbSelectArea("EED")
EndIf


For x:=1 To Len(aCodEnq)
      
   If lRet == .F. .OR. Empty(cEnq)
      EXIT
   Else
      EED->(DBSetOrder(1))
   
      Begin Sequence
          
         If EED->(DBSEEK(xFilial("EED") + aCodEnq[x]))       
            If EED->EED_DESABI == "1"
               If cEnq $ (EED->EED_CODVIN)       //Implica que o Código de Enquadramento esta dentro do CODVIN, logo não pode ser exibido                      
                  lRet := .F.
                  MsgInfo("Atenção:" +ENTER + ENTER +"-O Código " +cEnq+" não pode ser vinculado a " + aCodEnq[x] )       
                  Break
               Else
                  lRet := .T.
                  Break   
               EndIf
            Else                                  //Habilita os que forem vinculados
               If cEnq $ (EED->EED_CODVIN)        //Caso esteja no CODVIN
                  lRet := .T.                     //EXIBA
                  Break
               Else
                  lRet := .F.
                  MsgInfo("Atenção:" +ENTER + ENTER +"-O Código " +cEnq+" não pode ser vinculado a " +aCodEnq[x] )
                  Break
               EndIf      
            EndIf
         EndIf
      
      End Sequence   
   EndIf
Next x          

Return lRet   



//CRF 21/03/2011           
*-------------------------*
Function MVC_AS100EEC()    
*-------------------------*
Local oBrowse                    

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EED") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECAS100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Enquadramento
oBrowse:Activate()

Return    


//CRF 21/03/2011           
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruEED := FWFormStruct( 1, "EED") //Monta a estrutura da tabela EED

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP024', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela EED
oModel:AddFields( 'EECP024_EED',/*nOwner*/,oStruEED, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Enquadramento
  
Return oModel



//CRF 21/03/2011           
*-------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECAS100")

// Cria a estrutura a ser usada na View
Local oStruEED:=FWFormStruct(2,"EED")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP024_EED', oStruEED)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP024_EED') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 

