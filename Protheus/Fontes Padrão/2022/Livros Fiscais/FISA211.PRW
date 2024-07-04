#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#Include "FISA211.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA211()

Rotina com objetivo de cadastrar os recibod de transmissão do SPED

@author Erick G Dias
@since 13/12/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA211()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F3N")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F3N")
    oBrowse:SetDescription(STR0001) //"Cadastro de Recibos de Transmissão do SPED"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicionário desatualizado, favor verificar atualização da EFD Contribuições"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 13/12/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA211" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro das regras de apuração

@author Erick G Dias
@since 13/12/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabeçalho da rotina
Local oCabecalho := FWFormStruct(1, "F3N" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA211',/*Pre-Validacao*/,{|oModel|VALIDACAO(oModel) })

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA211",,oCabecalho)

oModel:SetPrimaryKey( {"F3N_FILIAL","F3N_ANO","F3N_MES","F3N_RECIBO"} )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001) //"Cadastro de Recibos de Transmissão do SPED"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias    
@since 13/12/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA211" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F3N")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA211' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Função que realiza as validações do modelo
@param		oModel	    - Objeto  -  Objeto do modelo FISA150
@Return     lRet       - Booleano - REtorno com validação, .T. pode gravar, .F. não poderá gravar.
@author Erick G Dias
@since 09/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function VALIDACAO(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cMes 		    := oModel:GetValue ('FISA211',"F3N_MES")
Local cAno 		    := oModel:GetValue ('FISA211',"F3N_ANO")
Local cRecibo 		:= oModel:GetValue ('FISA211',"F3N_RECIBO")
Local lRet          := .T.
Local nRecno        := F3N->(RECNO())
Local aAreaF3N      := F3N->(GetArea())

//Validações para operações de inclusão e alteração.
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    dbSelectArea("F3N")
    dbSetOrder(1)
    If F3N->(MsSeek(xFilial('F3N') + cAno + cMes))
        //Na inclusão, se a informação existir já barro o usuário para não gravar informação duplicada
        If nOperation == MODEL_OPERATION_INSERT
            lRet    := .F.
        //Já na edição, somente certifico se o RECNO é do próprio registro, se for permite a edição, caso contrário barrará o usuário
        ElseIF nOperation == MODEL_OPERATION_UPDATE .AND. nRecno <> F3N->(RECNO())
            lRet    := .F.            
        EndIF

        IF !lRet
            Help( ,, 'Help',, "Já existe recibo informado para este período!", 1, 0 )//"Já existe recibo informado para este período!"
        EndIF

    EndIF

EndIF

RestArea(aAreaF3N)   

Return lRet