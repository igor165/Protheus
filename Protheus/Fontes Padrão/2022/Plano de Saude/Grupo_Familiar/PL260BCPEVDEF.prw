#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/*/{Protheus.doc} PL260BCPEVDEF
Classe Responsavel pelo Evento de valida��es e  
atualiza��es do cadastro de Opcionais do Beneficiario
@author    Totver
@since     08/04/2020
/*/
Class PL260BCPEVDEF From FwModelEvent
Data auMovStatus	As Array
Data oModel			As Object

Method New() Constructor
//Method AfterTTS( oModel, cIdModel  )
Method After(oSubModel, cModelId, cAlias, lNewRecord)
//Method ModelPreVld( oModel, cModelId )
Method ModelPosVld( oModel, cModelId )
//Method Before(oModel, cModelId)
//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue)
//Method BeforeTTS(oModel, cModelId)
//Method InTTS(oModel, cModelId)

EndClass

/*/{Protheus.doc} new
Metodo construtor da classe
@author    Totver
@since     08/04/2020
/*/
Method new() Class PL260BCPEVDEF
Self:oModel 	:= Nil
Self:auMovStatus:= {}

Return Self

/*/{Protheus.doc} After
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit
depois da grava��o de cada submodelo (field ou cada linha de uma grid)
@author    Totver
@since     08/04/2020
/*/
Method After(oSubModel, cModelId, cAlias, lNewRecord) Class PL260BCPEVDEF
Local lRet := .T.

If cModelId = "BCPDETAIL" .and. lNewRecord
    BCP->BCP_MATRIC :=oSubModel:GetValue("BCP_MATRIC") 
Endif



Return lRet

/*/{Protheus.doc} BeforeTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes da transa��o.
Esse evento ocorre uma vez no contexto do modelo principal.
@author    Totver
@since     08/04/2020
/*/
//Method BeforeTTS(oModel, cModelId) Class PL260BCPEVDEF
//Local lRet := .T.
//Return lRet

/*/{Protheus.doc} InTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit Ap�s as grava��es por�m 
antes do final da transa��o.
Esse evento ocorre uma vez no contexto do modelo principal.

@author    Totver
@since     08/04/2020
/*/
//Method InTTS(oModel, cModelId) Class PL260BCPEVDEF
//Local lRet := .T.
//Return lRet


/*/{Protheus.doc} ModelPreVld
Metodo responsavel por realizar a pre valida��o do modelo
@author    Totver
@since     08/04/2020
/*/
//Method ModelPreVld( oModel, cModelId ) Class PL260BCPEVDEF
//Return .T.


//Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class PL260BCPEVDEF
//Return .T.

/*/{Protheus.doc} ModelPosVld
Metodo responsavel por realizar a pos valida��o do modelo
@author    Totver
@since     08/04/2020
/*/
Method ModelPosVld( oModel, cModelId ) Class PL260BCPEVDEF
Local nLinha        := 0
Local cDocObrigat   := ""
Local cEntrega      := ""
Local lEntrega      := .T.

nQTD    := oModel:GetModel("BCPDETAIL"):Length(.T.)

For nLinha:= 1 to nQTD
    oModel:GetModel("BCPDETAIL"):GoLine(nLinha)
    cDocObrigat := oModel:GetValue("BCPDETAIL",'BCP_DOCOBR')
    cEntrega    := oModel:GetValue("BCPDETAIL",'BCP_ENTREG')


    If cDocObrigat == "1" .and. cEntrega == "0"
        lEntrega:= .F.
        exit
    Endif

Next nLinha

If !lEntrega
    Help(" ",1,"DOCSOBRIGAT",,"H� documentos obrigat�rios a serem entregues.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Preencha o campo entregue como 'SIM' para os documentos obrigat�rios"})		//H� documentos obrigat�rios a serem entregues.
Endif

// Quando vir pela inclus�o do beneficiario essa verifica��o sera feita depois de incluir o beneficiario
If (IsInCallStack("P260ChkDoc"),(lEntrega:=.T.),) 


Return lEntrega

/*/{Protheus.doc} AfterTTS
Metodo Utilizado apos Concluido o Commit do Modelo
Realizo as integra��es
@author    Totver
@since     08/04/2020
/*/
//Method AfterTTS( oModel, cIdModel, cAlias, lNewRecord ) Class PL260BCPEVDEF
//Return .T.


/*/{Protheus.doc} FieldPreVld
M�todo que � chamado pelo MVC quando ocorrer a a��o de pr� valida��o do Field
@param oSubModel , Modelo principal
@param cModelId  , Id do submodelo
@param nLine     , Linha do grid
@param cAction   , A��o executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cId     , nome do campo
@param xValue    , Novo valor do campo

@author Roberto Barbosa
@since 13/08/2019
/*/
//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue) Class PL260BCPEVDEF
//Return .T.