#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/*/{Protheus.doc} PL260BF4EVDEF
Classe Responsavel pelo Evento de valida��es e  
atualiza��es do cadastro de Opcionais do Beneficiario
@author    Roberto Barbosa
@since     04/09/2019
/*/
Class PL260BF4EVDEF From FwModelEvent
Data auMovStatus	As Array
Data oModel			As Object

Method New() Constructor
//Method AfterTTS( oModel, cIdModel  )
//Method After(oSubModel, cModelId, cAlias, lNewRecord)
//Method ModelPreVld( oModel, cModelId )
Method ModelPosVld( oModel, cModelId )
//Method Before(oModel, cModelId)
//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue)
//Method BeforeTTS(oModel, cModelId)
//Method InTTS(oModel, cModelId)

EndClass

/*/{Protheus.doc} new
Metodo construtor da classe
@author    Roberto Barbosa
@since     04/09/2019
/*/
Method new() Class PL260BF4EVDEF
Self:oModel 	:= Nil
Self:auMovStatus:= {}

Return Self

/*/{Protheus.doc} After
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit
depois da grava��o de cada submodelo (field ou cada linha de uma grid)
@author    Roberto Barbosa
@since     04/09/2019
/*/
//Method After(oSubModel, cModelId, cAlias, lNewRecord) Class PL260BF4EVDEF
//Local lRet := .T.
//Return lRet

/*/{Protheus.doc} BeforeTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes da transa��o.
Esse evento ocorre uma vez no contexto do modelo principal.
@author    Roberto Barbosa
@since     04/09/2019
/*/
//Method BeforeTTS(oModel, cModelId) Class PL260BF4EVDEF
//Local lRet := .T.
//Return lRet

/*/{Protheus.doc} InTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit Ap�s as grava��es por�m 
antes do final da transa��o.
Esse evento ocorre uma vez no contexto do modelo principal.

@author    Roberto Barbosa
@since     04/09/2019
/*/
//Method InTTS(oModel, cModelId) Class PL260BF4EVDEF
//Local lRet := .T.
//Return lRet


/*/{Protheus.doc} ModelPreVld
Metodo responsavel por realizar a pre valida��o do modelo
@author    Roberto Barbosa
@since     04/09/2019
/*/
//Method ModelPreVld( oModel, cModelId ) Class PL260BF4EVDEF
//Return .T.


//Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class PL260BF4EVDEF
//Return .T.

/*/{Protheus.doc} ModelPosVld
Metodo responsavel por realizar a pos valida��o do modelo
@author    Roberto Barbosa
@since     04/09/2019
/*/
Method ModelPosVld( oModel, cModelId ) Class PL260BF4EVDEF
LOCAL cCodFor    := ""
LOCAL lBF4Del    := oModel:GetModel("BF4DETAIL"):IsDeleted()
LOCAL lBYXDel    := oModel:GetModel("BYXDETAIL"):IsDeleted()
LOCAL lBZXDel    := oModel:GetModel("BZXDETAIL"):IsDeleted()
Local lBF4Upd    := oModel:GetModel("BF4DETAIL"):IsUpdated()
Local lBYXUpd    := oModel:GetModel("BYXDETAIL"):IsUpdated()
Local lBZXUpd    := oModel:GetModel("BZXDETAIL"):IsUpdated()

cCodFor   := oModel:GetValue("BYXDETAIL","BYX_CODFOR")

If !lBF4Del .AND. !lBYXDel .AND. !lBZXDel //Realizo a opera��o apenas se o processo realizado � a dele��o de uma linha do grid            
    If !Empty(cCodFor) .AND. lBF4Upd .AND. lBYXUpd .AND. lBZXUpd //Atualizo apenas se estiver sendo uma inclus�o.
    /*    oModelBA3 := FWLoadModel('PLSA260FD3PLANO')
        oModelBA3:SetDescription("Plano")
        oModelBA3:SetOperation(MODEL_OPERATION_UPDATE)
        oModelBA3:Activate()
        oModelBA3:LoadValue("MasterBA3","BA3_FORCOP",cCodFor)
        oModelBA3:LoadValue("MasterBA3","BA3_DEFOOP",BJ1->(Posicione("BJ1",1,xFilial("BJ1")+cCodFor,"BJ1_DESCRI"))) 
        If oModelBA3:VldData()
            oModelBA3:CommitData()
        EndIF*/
    EndIF
EndIF

Return .T.

/*/{Protheus.doc} AfterTTS
Metodo Utilizado apos Concluido o Commit do Modelo
Realizo as integra��es
@author    Roberto Barbosa
@since     04/09/2019
/*/
//Method AfterTTS( oModel, cIdModel ) Class PL260BF4EVDEF
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
//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue) Class PL260BF4EVDEF
//Return .T.