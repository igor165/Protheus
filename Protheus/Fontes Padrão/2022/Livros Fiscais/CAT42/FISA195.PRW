#Include "FISA195.ch"
#include "protheus.ch"
#include "FWMBROWSE.CH"
#include "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA195()

Carga de estoque inicial.
PORTARIA CAT 42/2018 - SISTEMA DE APURA��O E RESSARCIMENTO OU 
COMPLEMENTO DO ICMS RETIDO POR SUBSTITUI��O TRIBUT�RIA. 
Esta rotina faz o Cadastro dos saldos iniciais em estoque dos produtos.

@author Eduardo Vicente da Silva
@since 27/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA195()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
If AliasIndic("F2W") .And. AliasIndic("F3M")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F2W")
    oBrowse:SetDescription("") // Cadastro de Regras - Ressarcimento ICMS-ST
    oBrowse:SetFilterDefault("F2W_FILIAL == " + ValToSql(xFilial("F2W")))
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0001,1,0) // Dicion�rio desatualizado, verifique as atualiza��es da PORTARIA CAT 42/2018 - SISTEMA DE APURA��O E RESSARCIMENTO OU COMPLEMENTO DO ICMS RETIDO POR SUBSTITUI��O TRIBUT�RIA. //"Dicion�rio desatualizado, verifique as atualiza��es da PORTARIA CAT 42/2018 - SISTEMA DE APURA��O E RESSARCIMENTO OU COMPLEMENTO DO ICMS RETIDO POR SUBSTITUI��O TRIBUT�RIA."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar menu

@author Eduardo Vicente da Silva
@since 27/11/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu("FISA195")

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo o cadastro de saldo incial com a tabela F2V

@author Eduardo Vicente da Silva
@since 27/11/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local cIdTab := FWUUID("F2W")

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura correspondete a tabela de Saldo Inicial F2W
Local oCabecalho := FWFormStruct(1, "F2W" )

//Estrutura de CST considerando a tabela F3M
Local oCST := FWFormStruct(1, "F3M" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA195') 

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA195",,oCabecalho)

//Adicionando o grid de CST
oModel:AddGrid( 'FISA195CST', 'FISA195', oCST)
oModel:GetModel( 'FISA195CST' ):SetUseOldGrid()

//Inicializa o campo F2W_IDTAB com o ID.
oCabecalho:SetProperty('F2W_IDTAB' , MODEL_FIELD_INIT ,{||cIdTab} )

//Inicializa o campo F3M_IDF2W com o ID.
oCST:SetProperty('F3M_IDF2W' , MODEL_FIELD_INIT ,{||cIdTab} )

//Relacionamento entre as tabelas F2W Regras com F3M Detalhe da Regra
oModel:SetRelation( 'FISA195CST', { { 'F3M_FILIAL', 'xFilial("F3M")' }, { 'F3M_IDF2W', 'F2W_IDTAB' } }, F3M->( IndexKey( 1 ) ) )

//Define para n�o repetir o c�digo de produto
oModel:GetModel( 'FISA195CST' ):SetUniqueLine( { 'F3M_CSTICM'} )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0002) // Cadastro de Regras - Ressarcimento ICMS-ST

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Eduardo Vicente da Silva
@since 27/11/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA195" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho    := FWFormStruct(2, "F2W")
Local oCST          := FWFormStruct(2, "F3M")
Local oView         := Nil
Local cVersao       := GetVersao(.F.)

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO', oCabecalho    , 'FISA195')
oView:AddGrid(  'VIEW_CST'      , oCST          , 'FISA195CST')

//Retira os campos da View
oCabecalho:RemoveField( 'F2W_IDTAB' )
oCST:RemoveField( 'F3M_IDF2W' )

//Ajuste do T�tulo do campo F2W_FATGER.
oCabecalho:SetProperty("F2W_FATGER", MVC_VIEW_TITULO, STR0003) //"Fato Gerador n�o Realizado"

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
oView:CreateHorizontalBox( 'INFERIOR'  , 80 )

//O formul�rio da interface ser� colocado dentro do container
oView:SetOwnerView( 'VIEW_CABECALHO', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CST'      , 'INFERIOR' )

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_CABECALHO', "CFOP" )
oView:EnableTitleView('VIEW_CST'      , "CST" )

If cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER" )
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F195Carga
Funcao respons�vel por realizar a carga inicial dos registros.

@author Eduardo Vicente da Silva
@since 27/11/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function F195Carga()
Local cCfop         := ""
Local aCstTrib      := {"00","10","20","60","70"}
Local aCst          := {"00","10","20","30","40","41","50","51","60","70","90"}
Local aCstAux       := {}
Local nX            := 1
Local aArea         := GetArea()
Local cAlias        := ""
Local cIdTab        := ""
Local cFatoNGer     := "5927"  
Local cChave        := ""

cCfop := "1912/2912/1913/2913/1914/2914/1915/2915/1916/2916/5906/6906/5907/6907/5912/6912/5913/"
cCfop += "6913/5914/6914/5915/6915/5916/6916/5414/6414/5415/6415/5904/6904"

//Verifica se existe registro na tabela antes de realizar a carga inicial.
F2W->(dbSetOrder(1))
If F2W->(dbSeek(xFilial("F2W")))
    Return
EndIf

cAlias := GetNextAlias()

Begin Transaction

BeginSql Alias cAlias
        
    SELECT  X5_CHAVE
    FROM 	%TABLE:SX5% SX5
    WHERE  SX5.X5_FILIAL=%XFILIAL:SX5%
    AND SX5.X5_TABELA = %EXP:"13"%
    AND SX5.%NOTDEL%
            
EndSql

While !(cAlias)->(EOF())
   
    cChave := AllTrim((cAlias)->X5_CHAVE)
    
    If Len(cChave) != 4
        (cAlias)->(dbSkip())
        Loop
    EndIf
    
    RecLock("F2W",.T.)
    cIdTab := FWUUID("F2W")

    F2W->F2W_FILIAL := xFilial("F2W")
    F2W->F2W_IDTAB  := cIdTab
    F2W->F2W_CFOP   := cChave
    F2W->F2W_FATGER := "2"
    MsUnLock()

    //Para os CFOP's contidos na vari�vel cCfop ser� carregados apenas o c�digo de CST com tributa��o de ICMS.
    If cChave $ cCfop
        aCstAux := aCstTrib
    Else
        aCstAux := aCst
    EndIf

    For nX := 1 To Len(aCstAux)

        RecLock("F3M",.T.)
        F3M->F3M_FILIAL := xFilial("F3M")
        F3M->F3M_CSTICM := aCstAux[nX]
        F3M->F3M_IDF2W  := cIdTab
        MsUnLock()
        
    Next

    (cAlias)->(dbSkip())
EndDo

//Por se tratar de apenas 1 c�digo realiza o update no final do processamento.
F2W->(dbSetOrder(2))
If F2W->(dbSeek(xFilial("F2W")+cFatoNGer))
    RecLock("F2W",.F.)
    F2W->F2W_FATGER := "1"
    MsUnLock()
EndIf

End Transaction

(cAlias)->(dbCloseArea())

RestArea(aArea)

Return
