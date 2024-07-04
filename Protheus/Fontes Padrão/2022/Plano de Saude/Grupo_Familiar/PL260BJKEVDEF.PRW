#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "PLSA260.ch"

/*/{Protheus.doc} PL260BJKEVDEF
Classe Responsavel pelo Evento de validações e  
atualizações do cadastro de Gratuidade
@author    Roberto Barbosa
@since     21/08/2019
/*/
Class PL260BJKEVDEF From FwModelEvent
Data auMovStatus	As Array
Data oModel			As Object

Method New() Constructor
/*Method AfterTTS( oModel, cIdModel  )
Method After(oSubModel, cModelId, cAlias, lNewRecord)
Method ModelPreVld( oModel, cModelId )
Method ModelPosVld( oModel, cModelId )
Method Before(oModel, cModelId)
Method FieldPreVld(oModel, cModelID, cAction, cId, xValue)
Method BeforeTTS(oModel, cModelId)
Method InTTS(oModel, cModelId)*/

EndClass

/*/{Protheus.doc} new
Metodo construtor da classe
@author    Roberto Barbosa
@since     21/08/2019
/*/
Method new() Class PL260BJKEVDEF
Self:oModel 	:= Nil
Self:auMovStatus:= {}

Return Self

/*/{Protheus.doc} After
Método que é chamado pelo MVC quando ocorrer as ações do commit
depois da gravação de cada submodelo (field ou cada linha de uma grid)
@author    Roberto Barbosa
@since     21/08/2019
/*/
//Method After(oSubModel, cModelId, cAlias, lNewRecord) Class PL260BJKEVDEF
    //FWFormCommit( oSubModel )
//Return .T.

/*/{Protheus.doc} BeforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.
Esse evento ocorre uma vez no contexto do modelo principal.
@author    Roberto Barbosa
@since     21/08/2019
/*/
//Method BeforeTTS(oModel, cModelId) Class PL260BJKEVDEF

//FWFormCommit( oModel )
//Return .T.

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém 
antes do final da transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@author    Roberto Barbosa
@since     21/08/2019
/*/
//Method InTTS(oModel, cModelId) Class PL260BJKEVDEF
//Return .T.

/*/{Protheus.doc} ModelPreVld
Metodo responsavel por realizar a pre validação do modelo
@author    Roberto Barbosa
@since     21/08/2019

/*/
//Method ModelPreVld( oModel, cModelId ) Class PL260BJKEVDEF
//Return .T.


/*/{Protheus.doc} ModelPreVld
Método que é chamado pelo MVC quando ocorrer as ações do commit
antes da gravação de cada submodelo (field ou cada linha de uma grid)
@author    Roberto Barbosa
@since     21/08/2019
/*/
//Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class PL260BJKEVDEF
//Return .T.

/*/{Protheus.doc} ModelPosVld
Metodo responsavel por realizar a pos validação do modelo
@author    Roberto Barbosa
@since     21/08/2019
/*/
//Method ModelPosVld( oModel, cModelId ) Class PL260BJKEVDEF
//Return .T.

/*/{Protheus.doc} AfterTTS
Metodo Utilizado apos Concluido o Commit do Modelo
Realizo as integrações
@author    Roberto Barbosa
@since     21/08/2019
/*/
//Method AfterTTS( oModel, cIdModel ) Class PL260BJKEVDEF
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
//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue) Class PL260BJKEVDEF
//Return .T.