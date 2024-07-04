#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/*/{Protheus.doc} PL260BCPEVDEF
Classe Responsavel pelo Evento de validações e  
atualizações do cadastro de Opcionais do Beneficiario
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
Método que é chamado pelo MVC quando ocorrer as ações do commit
depois da gravação de cada submodelo (field ou cada linha de uma grid)
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
Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.
Esse evento ocorre uma vez no contexto do modelo principal.
@author    Totver
@since     08/04/2020
/*/
//Method BeforeTTS(oModel, cModelId) Class PL260BCPEVDEF
//Local lRet := .T.
//Return lRet

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém 
antes do final da transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@author    Totver
@since     08/04/2020
/*/
//Method InTTS(oModel, cModelId) Class PL260BCPEVDEF
//Local lRet := .T.
//Return lRet


/*/{Protheus.doc} ModelPreVld
Metodo responsavel por realizar a pre validação do modelo
@author    Totver
@since     08/04/2020
/*/
//Method ModelPreVld( oModel, cModelId ) Class PL260BCPEVDEF
//Return .T.


//Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class PL260BCPEVDEF
//Return .T.

/*/{Protheus.doc} ModelPosVld
Metodo responsavel por realizar a pos validação do modelo
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
    Help(" ",1,"DOCSOBRIGAT",,"Há documentos obrigatórios a serem entregues.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Preencha o campo entregue como 'SIM' para os documentos obrigatórios"})		//Há documentos obrigatórios a serem entregues.
Endif

// Quando vir pela inclusão do beneficiario essa verificação sera feita depois de incluir o beneficiario
If (IsInCallStack("P260ChkDoc"),(lEntrega:=.T.),) 


Return lEntrega

/*/{Protheus.doc} AfterTTS
Metodo Utilizado apos Concluido o Commit do Modelo
Realizo as integrações
@author    Totver
@since     08/04/2020
/*/
//Method AfterTTS( oModel, cIdModel, cAlias, lNewRecord ) Class PL260BCPEVDEF
//Return .T.


/*/{Protheus.doc} FieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field
@param oSubModel , Modelo principal
@param cModelId  , Id do submodelo
@param nLine     , Linha do grid
@param cAction   , Ação executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cId     , nome do campo
@param xValue    , Novo valor do campo

@author Roberto Barbosa
@since 13/08/2019
/*/
//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue) Class PL260BCPEVDEF
//Return .T.