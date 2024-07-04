#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "PLSA260.ch"

/*/{Protheus.doc} PL260FD1EVDEF
Classe Responsavel pelo Evento de validações e  
atualizações do cadastro de Gratuidade
@author    Totver
@since     21/08/2019
/*/
Class PL260FD1EVDEF From FwModelEvent
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
@author    Totver
@since     21/08/2019
/*/
Method new() Class PL260FD1EVDEF
Self:oModel 	:= Nil
Self:auMovStatus:= {}

Return Self

/*/{Protheus.doc} After
Método que é chamado pelo MVC quando ocorrer as ações do commit
depois da gravação de cada submodelo (field ou cada linha de uma grid)
@author    Totver
@since     21/08/2019
/*/
//Method After(oSubModel, cModelId, cAlias, lNewRecord) Class PL260FD1EVDEF
    //FWFormCommit( oSubModel )
//Return .T.

/*/{Protheus.doc} BeforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.
Esse evento ocorre uma vez no contexto do modelo principal.
@author    Totver
@since     21/08/2019
/*/
//Method BeforeTTS(oModel, cModelId) Class PL260FD1EVDEF

//FWFormCommit( oModel )
//Return .T.

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém 
antes do final da transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@author    Totver
@since     21/08/2019
/*/
//Method InTTS(oModel, cModelId) Class PL260FD1EVDEF
//Return .T.

/*/{Protheus.doc} ModelPosVld
Metodo responsavel por realizar a pos validação do modelo
@author    Totver
@since     21/08/2019

/*/
Method ModelPosVld( oModel, cModelId ) Class PL260FD1EVDEF
Local lRet     := .T.
Local cCobNiv  := oModel:GetValue("BA3MASTER","BA3_COBNIV")
Local nVencto  := oModel:GetValue("BA3MASTER","BA3_VENCTO")
Local lCondPa  := BA3->( FieldPos("BA3_CONDPA") )>0
Local cCondPa  := Iif(lCondPa == .T. .AND. oModel:HasField("BA3MASTER", "BA3_CONDPA") == .T.,oModel:GetValue("BA3MASTER","BA3_CONDPA"), "")
Local cCodCli  := oModel:GetValue("BA3MASTER","BA3_CODCLI")
LOCAL cCriaCli := GetNewPar("MV_PLSFMCL","1")
Local cTpUs    := BA3->BA3_TIPOUS //Campos estaticos eu pego da tabela posicionada
Local cCodInt  := BA3->BA3_CODINT 
Local cCodEmp  := BA3->BA3_CODEMP 
Local cConEmp  := BA3->BA3_CONEMP 
Local cVerCon  := BA3->BA3_VERCON 
Local cSubCon  := BA3->BA3_SUBCON 
Local cVerSub  := BA3->BA3_VERSUB 
Local cChvBQC  := cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub
Local cChvBT5  := cCodInt+cCodEmp+cConEmp+cVerCon
Local cNature  := oModel:GetValue("BA3MASTER","BA3_NATURE")
Local cLoja    := oModel:GetValue("BA3MASTER","BA3_LOJA")

If cCobNiv == "1"
	If ( nVencto == 0 .And. Empty(cCondPa) )
		lRet := .F.
		//MsgStop(OemtoAnsi(STR0067)) //"Dia do Vencimento ou Condicao de pagamento obrigatorio para este contrato"
		Help( ,, 'Atenção',, 'Dia do Vencimento ou Condicao de pagamento obrigatorio para este contrato.', 1, 0 )
        //Return(lRet)
	//ElseIf Empty(cCodCli) .AND. cCriaCli <> "1"
		//MsgAlert(OemtoAnsi(STR0068)+;	//"A criacao automatica de clientes esta desabilitada no paramentro MV_PLSFMCL, "
	//	Help( ,, 'Atenção',, 'A criação automatica de clientes esta desabilitada no paramentro MV_PLSFMCL. É obrigatorio informa-lo manualmente juntamente com a data de vencimento', 1, 0 )
		//OemtoAnsi(STR0069))	//"e obrigatorio informa-lo manualmente juntamente com a data de vencimento"
      //  lRet := .F.
        //Return(lRet)
	EndIf
EndIf
    
If cTpUs == "2" .and. lRet // pessoa juridica
	BQC->(DbSetOrder(1))
	If BQC->(MsSeek(xFilial("BQC")+cChvBQC))
		BT5->(DbSetOrder(1))
		If BT5->(MsSeek(xFilial("BT5")+cChvBT5))
			If BQC->BQC_OBRFAM == "1"
				If cCobNiv # "1"
					//ApMsgAlert(OemtoAnsi(STR0070) ,OemtoAnsi(STR0071)) //" O campo 'Cobranca neste nivel' deve ser preenchido com 1=Sim. "
					Help( ,, 'Atenção',, 'O campo Cobranca neste nivel deve ser preenchido com 1=Sim.', 1, 0 )
					lRet := .F.
				//	Return(lRet)
				EndIf
			ElseIf BQC->BQC_COBNIV <> "1" .And. BT5->BT5_COBNIV <> "1" .And. Empty(BG9->BG9_CODCLI)
				If cCobNiv # "1"
					//ApMsgAlert(OemtoAnsi(STR0070)+Chr(13)+OemtoAnsi(STR0171) ,OemtoAnsi(STR0071)) //" O campo 'Cobranca neste nivel' deve ser preenchido com 1=Sim. "###"A cobrança não foi definida em nenhum dos possíveis níveis (grupo/empresa, contrato ou subcontrato)."
					Help( ,, 'Atenção',, 'O campo Cobranca neste nivel deve ser preenchido com 1=Sim. A cobrança não foi definida em nenhum dos possíveis níveis (grupo/empresa, contrato ou subcontrato)..', 1, 0 )
					lRet := .F.
					//Return(lRet)
				EndIf
			EndIf
		EndIf
	EndIf
Elseif cTpUs == "1" .and. lRet // pessoa juridica
	If Empty(cCodCli) .AND. cCriaCli <> "1"
		//MsgAlert(OemtoAnsi(STR0068)+; //"A criacao automatica de clientes esta desabilitada no paramentro MV_PLSFMCL, "
		//OemtoAnsi(STR0069)) //"e obrigatorio informa-lo manualmente juntamente com a data de vencimento"
		Help( ,, 'Atenção',, 'A criacao automatica de clientes esta desabilitada no paramentro MV_PLSFMCL', 1, 0 )
		Help( ,, 'Atenção',, 'É obrigatorio informa-lo manualmente juntamente com a data de vencimento', 1, 0 )
        lRet := .F.
      //  Return(lRet)
	Endif
EndIf

If lRet .AND. oModel:GetOperation() == 4 .AND. cCobNiv == "1"
	If EMPTY(cCodCli)

		GerSincronismo(oModel)

    Else
        SA1->(DBSetOrder(1))
        SA1->(MsSeek(xFilial("SA1")+cCodCli+cLoja))
        If EMPTY(cNature + SA1->A1_NATUREZ)
			lRet := .F.			
			//MsgInfo(OemtoAnsi(STR0267))	//	"Informe uma Natureza antes de confirmar a cobranca neste nivel"
			Help( ,, 'Atenção',, 'Informe uma Natureza antes de confirmar a cobranca neste nivel', 1, 0 )
           // Return(lRet)
        EndIf
	EndIf
EndIf
    
Return lRet


/*/{Protheus.doc} ModelPreVld
Método que é chamado pelo MVC quando ocorrer as ações do commit
antes da gravação de cada submodelo (field ou cada linha de uma grid)
@author    Totver
@since     21/08/2019
/*/
//Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class PL260FD1EVDEF
//Return .T.

/*/{Protheus.doc} AfterTTS
Metodo Utilizado apos Concluido o Commit do Modelo
Realizo as integrações
@author    Totver
@since     21/08/2019
/*/
//Method AfterTTS( oModel, cIdModel ) Class PL260FD1EVDEF
//Return .T.

/*/{Protheus.doc} FieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field
@param oSubModel , Modelo principal
@param cModelId  , Id do submodelo
@param nLine     , Linha do grid
@param cAction   , Ação executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cId     , nome do campo
@param xValue    , Novo valor do campo

@author Totver
@since 13/08/2019
/*/
//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue) Class PL260FD1EVDEF
//Return .T.