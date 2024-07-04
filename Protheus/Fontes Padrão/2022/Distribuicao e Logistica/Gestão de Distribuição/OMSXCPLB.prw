#include "PROTHEUS.CH"
#include "OMSXCPLB.CH"

#DEFINE OMSCPLB01 "OMSCPLB01"
#DEFINE OMSCPLB02 "OMSCPLB02"
#DEFINE OMSCPLB03 "OMSCPLB03"
#DEFINE OMSCPLB04 "OMSCPLB04"
#DEFINE OMSCPLB05 "OMSCPLB05"
#DEFINE OMSCPLB06 "OMSCPLB06"
#DEFINE OMSCPLB07 "OMSCPLB07"
#DEFINE OMSCPLB08 "OMSCPLB08"
#DEFINE OMSCPLB09 "OMSCPLB09"
#DEFINE OMSCPLB10 "OMSCPLB10"
#DEFINE OMSCPLB11 "OMSCPLB11"
#DEFINE OMSCPLB12 "OMSCPLB12"

Static cOmsCplRel := "VIAGEM_OMSXCPL"

//---------------------------------------------
/*/{Protheus.doc} OmsTrip
	Classe auxiliar para o OMS, incluído o array de empresas
@author  Jackson Patrick Werka
@since   08/08/2018
@version 1.0
/*/
//---------------------------------------------
CLASS OmsTrip FROM Trip
	DATA aEmpFilAux
	DATA lHasImped
	METHOD New() CONSTRUCTOR
ENDCLASS

METHOD New() CLASS OmsTrip
	_Super:New()
	Self:aEmpFilAux := {}
	Self:lHasImped  := .F.
Return 

//-----------------------------------------------------------------------------
/*/{Protheus.doc} OmsCanTrip
	Função responsável por efetuar a leitura do XML, validar e cancelar as viagens integradas a partir do CPL. Efetua a abertura do ambiente correto
	com base na empresa e filial recebida na localidade de carregamento do XML
@param   oXml, objeto, Objeto XML que representa o conteúdo da mensagem
@param   cConteudo, caracter, Texto com o conteúdo da mensagem xml recebida
@author  Jackson Patrick Werka
@since   13/07/2018
@version 1.0
/*/
//-----------------------------------------------------------------------------
Function OmsCanTrip(oXml,cConteudo)
Local oResponse := Nil
	OMSXGRVLOG("CancelService",@cConteudo,"DK0")
	oResponse := CanRepTrip(oXml,'cancel')
Return oResponse

//-----------------------------------------------------------------------------
/*/{Protheus.doc} OmsRepTrip
	Função responsável por efetuar a leitura do XML, validar e reprogramar as viagens integradas a partir do CPL. 
@param   oXml, objeto, Objeto XML que representa o conteúdo da mensagem
@param   cConteudo, caracter, Texto com o conteúdo da mensagem xml recebida
@author  Jackson Patrick Werka
@since   13/07/2018
@version 1.0
/*/
//-----------------------------------------------------------------------------
Function OmsRepTrip(oXml,cConteudo)
Local oResponse := Nil
	OMSXGRVLOG("ReprogramService",@cConteudo,"DK0")
	oResponse := CanRepTrip(oXml,'reprogram')
Return oResponse

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CanRepTrip
	Função responsável por efetuar a leitura do XML, validar e cancelar ou reprogramar 
	as viagens integradas a partir do CPL. Efetua a abertura do ambiente para cada empresa/filial
	em que a viagem foi originalmente integrada, com base no relacionamento gravado no recebimento da viagem.
@param   oXml, objeto, Objeto XML que representa o conteúdo da mensagem
@param   cConteudo, caracter, Texto com o conteúdo da mensagem xml recebida
@author  Jackson Patrick Werka
@since   13/07/2018
@version 1.0
/*/
//-----------------------------------------------------------------------------
Static Function CanRepTrip(oXml,cModo)
Local oRepCan    := ServiceReprogram():New()
Local oResponse  := ReprogramResponse():New()
Local oTrip      := Nil
Local oItem      := Nil
Local nX         := 0
Local nY         := 0
Local aTrips     := {}
Local cRpcEmp    := ""
Local cRpcFil    := ""
Local cRpcEmpAnt := ""
Local cQuery     := ""
Local cAliasDK3  := ""
Local cErro      := ""
Local lRpcSetEnv := .F.
Local aCab      := {}   // Array do Cabeçalho da Carga
Local aItem     := {}   // Array dos Pedidos da Carga

Private lMsErroAuto := .F. //Variavel que informa a ocorrência de erros no ExecAuto
Private XMLREC := oXml

	OsLogCpl("-----------------------------------------------------------------------------------------","INFO")
	OsLogCpl("OMSXCPLB -> CanRepTrip ->leitura do XML, validar e cancelar ou reprogramar","INFO" )

	If cModo == 'cancel'
		XMLREC := TMSXGetItens("publishCancelService","O")
	Else
		XMLREC := TMSXGetItens("publishReprogrammingService","O")
	EndIf

	oRepCan:regionSourceId := TMSXGetItens("regionSourceId")
	aTrips := TMSXGetAll("trips:trip")
	
	For nX := 1 To Len(aTrips)
		XMLREC := aTrips[nX]
		oTrip := OmsTrip():New()
		oTrip:tripId := TMSXGetItens("tripId","N")
		aAdd(oRepCan:trips,oTrip)
	Next nX
	aTrips := {} // Descarta a memória utilizada

	For nX := 1 To Len(oRepCan:trips)

		oItem := oResponse:Result:NewItem()
		oItem:tripId := oRepCan:trips[nX]:tripId
		oItem:regionSourceId := oRepCan:regionSourceId

		// Busca todas as empresas onde esta viagem está relacionada
		oRepCan:trips[nX]:aEmpFilAux := OMSGetEmp(oItem:tripId,@cErro)

		If !Empty(oRepCan:trips[nX]:aEmpFilAux)
			For nY := 1 to Len(oRepCan:trips[nX]:aEmpFilAux)

				cRpcEmp := oRepCan:trips[nX]:aEmpFilAux[nY,1]
				cRpcFil := oRepCan:trips[nX]:aEmpFilAux[nY,2]

				// Por uma questão de performance, só abre uma vez o ambiente por empresa
				If !(cRpcEmpAnt == cRpcEmp)
					// Fecha o ambiente atual
					If lRpcSetEnv
						RpcClearEnv()
						lRpcSetEnv := .F.
					EndIf
					RpcSetType(3)
					// Abertura do ambiente em rotinas automáticas
					// RpcSetEnv( [ cRpcEmp ] [ cRpcFil ] [ cEnvUser ] [ cEnvPass ] [ cEnvMod ] [ cFunName ] [ aTables ] [ lShowFinal ] [ lAbend ] [ lOpenSX ] [ lConnect ] ) --> lRet
					If !RpcSetEnv( cRpcEmp, cRpcFil, /*cEnvUser*/, /*cEnvPass*/, "OMS", Iif(cModo == 'cancel',"OmsCanTrip","OmsRepTrip"), {"DK0"}) 
						SetFaultTMS(STR0009,STR0010+cRpcEmp+STR0011+cRpcFil+".") //"Falha Ambiente" //"Não foi possível inicializar o ambiente Protheus para a empresa " //" e filial "
						Exit
					EndIf
					lRpcSetEnv := .T.
					cRpcEmpAnt := cRpcEmp
				EndIf
				cFilAnt := cRpcFil

				If DK0->(dbSeek(xFilial("DK0") + PadR(oItem:regionSourceId,Len(DK0->DK0_REGID)) + PadR(cValToChar(oItem:tripId),Len(DK0->DK0_VIAGID)) ))
					/*Retorno Cancelamento
					0=Viagem cancelada com sucesso; 1=Viagem já estava cancelada; 2=Viagem não encontrada; 3=Viagem já despachada; 4=Viagem não pode ser cancelada;
					
					Retorno Reprogramação
					0=Reprogramação autorizada; 1=Viagem cancelada; 2=Viagem não encontrada; 3=Viagem já despachada/Reprogramação não autorizada
					
					Situações DK0
					0=Recebida;1=Aguardando liberacao;2=Liberada;3=Falha liberacao;4=Reprogramada;5=Cancelada;6=Rejeitada. */

					// se possuir uma carga gerada não permitir reprogramação

					OsLogCpl("OMSXCPLB -> CanRepTrip -> Situação da viagem Tabela DKO : "+ cValToChar(DK0->DK0_SITINT) ,"INFO")
					If !Empty(DK0->DK0_CARGA)
						OsLogCpl("OMSXCPLB -> CanRepTrip -> Encontrado a carga: " + cValToChar(DK0->DK0_CARGA) + " " + "Associado a viagem " + cValToChar(DK0->DK0_VIAGID) + "Filial: "+ cValToChar(DK0->DK0_FILIAL) + ".","INFO")
						If SuperGetMv("MV_CPLESCG",.F.,"2") == "1" //Indica se permite estorno automático da carga
							DAK->(DbSetOrder(1))
							If DAK->(DbSeek(xFilial('DAK')+DK0->DK0_CARGA))
								MSExecAuto( { |x, y, z| OMSA200(x, y, z) },aCab,aItem,6)
								If lMsErroAuto
									oItem:NewErrorMessage(STR0012) //"Não foi possível estornar a carga associada à viagem."
									oItem:Status := Iif(cModo == 'cancel',4,3)
									OsLogCpl("OMSXCPLB -> CanRepTrip -> Não foi possível estornar a carga associada à viagem","ERROR" )
								Else
									oItem:Status := 0
									OsLogCpl("OMSXCPLB -> CanRepTrip -> Estorno da carga associada à viagem efetuado com sucesso.","INFO" )
								EndIf
							Else
								OsLogCpl("OMSXCPLB -> CanRepTrip -> Carga não foi encontrada na tabela DAK !","ERROR")
								Exit
							EndIf
						Else
							oItem:NewErrorMessage(STR0013) //"Viagem possui carga gerada."
							oItem:Status := Iif(cModo == 'cancel',4,3)
							OsLogCpl("OMSXCPLB -> CanRepTrip -> Viagem possui carga gerada.","INFO" )
						EndIf
					ElseIf DK0->DK0_SITINT == "5" // Cancelada
						oItem:Status := 1
						OsLogCpl("OMSXCPLB -> CanRepTrip -> Viagem cancelada","INFO")
					Else
						oItem:Status := 0
						OsLogCpl("OMSXCPLB -> CanRepTrip -> Não existe carga relacionada a Viagem.","INFO")
					EndIf
					
				Else
					oItem:Status := 2 //Viagem não localizada
					OsLogCpl("OMSXCPLB -> CanRepTrip -> Viagem não localizada.","INFO" )
				EndIf

				// Se em alguma empresa não puder cancelar a viagem, já retorna
				If oItem:Status != 0 .And. oItem:Status != 2
					oRepCan:trips[nX]:lHasImped := .T.
					OsLogCpl("OMSXCPLB -> CanRepTrip -> Viagem não pode ser cancelada" ,"INFO" )
					Exit
				EndIf

			Next nY
		Else
			oItem:NewErrorMessage(cErro)
			oItem:Status := Iif(cModo == 'cancel',4,3)
			oRepCan:trips[nX]:lHasImped := .T.
			OsLogCpl("OMSXCPLB -> CanRepTrip -> Conteúdo da variável: ",+cValtoChar(cErro),"INFO" )
		EndIf
	Next nX

	For nX := 1 To Len(oRepCan:trips)
		// Se a viagem possui algum impedidmento, não faz nada
		If oRepCan:trips[nX]:lHasImped 
			Loop
		EndIf

		For nY := 1 to Len(oRepCan:trips[nX]:aEmpFilAux)

			cRpcEmp := oRepCan:trips[nX]:aEmpFilAux[nY,1]
			cRpcFil := oRepCan:trips[nX]:aEmpFilAux[nY,2]

			// Por uma questão de performance, só abre uma vez o ambiente por empresa
			If !(cRpcEmpAnt == cRpcEmp)
				// Fecha o ambiente atual
				If lRpcSetEnv
					RpcClearEnv()
					lRpcSetEnv := .F.
				EndIf
				RpcSetType(3)
				// Abertura do ambiente em rotinas automáticas
				// RpcSetEnv( [ cRpcEmp ] [ cRpcFil ] [ cEnvUser ] [ cEnvPass ] [ cEnvMod ] [ cFunName ] [ aTables ] [ lShowFinal ] [ lAbend ] [ lOpenSX ] [ lConnect ] ) --> lRet
				If !RpcSetEnv( cRpcEmp, cRpcFil, /*cEnvUser*/, /*cEnvPass*/, "OMS", Iif(cModo == 'cancel',"OmsCanTrip","OmsRepTrip"), {"DK0"}) 
					SetFaultTMS(STR0009,STR0010+cRpcEmp+STR0011+cRpcFil+".") //"Falha Ambiente" //"Não foi possível inicializar o ambiente Protheus para a empresa " //" e filial "
					Exit
				EndIf
				lRpcSetEnv := .T.
				cRpcEmpAnt := cRpcEmp
			EndIf
			cFilAnt := cRpcFil

			If DK0->(dbSeek(xFilial("DK0") + PadR(oRepCan:regionSourceId,Len(DK0->DK0_REGID)) + PadR(cValToChar(oRepCan:trips[nX]:tripId),Len(DK0->DK0_VIAGID)) ))
				RecLock('DK0',.F.)
				DK0->DK0_SITINT := Iif(cModo=='cancel',"5","4")
				DK0->DK0_DATINT := Date()
				DK0->DK0_HORINT := Time()
				DK0->(MsUnlock())
				//Remove código da viagem da sequência de integração
				If TableInDic('DK3')
					cQuery := " SELECT DK3.R_E_C_N_O_ RECNODK3"
					cQuery +=   " FROM "+RetSqlName('DK1')+" DK1"
					cQuery +=  " INNER JOIN "+RetSqlName('DK3')+" DK3"
					cQuery +=     " ON DK3.DK3_FILIAL = DK1.DK1_FILPED"
					cQuery +=    " AND DK3.DK3_PEDIDO = DK1.DK1_PEDIDO"
					cQuery +=    " AND DK3.DK3_VIAGID = DK1.DK1_VIAGID"
					cQuery +=    " AND DK3.DK3_ITEMPE = DK1.DK1_ITEMPE"
					cQuery +=    " AND DK3.DK3_PRODUT = DK1.DK1_PRODUT"
					cQuery +=    " AND DK3.D_E_L_E_T_ = ' '"
					cQuery +=  " WHERE DK1.DK1_FILIAL = '"+xFilial('DK1')+"'"
					cQuery +=    " AND DK1.DK1_REGID  = '"+PadR(oRepCan:regionSourceId,Len(DK0->DK0_REGID))+"'"
					cQuery +=    " AND DK1.DK1_VIAGID = '"+PadR(cValToChar(oRepCan:trips[nX]:tripId),Len(DK0->DK0_VIAGID))+"'"
					cQuery +=    " AND DK1.D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					OsLogCpl("OMSXCPLB -> CanRepTrip-> Viagem "+cValToChar(oRepCan:trips[nX]:tripId)+" Conteúdo de cQuery: " +cValtoChar(cQuery),"INFO" )
					cAliasDK3 := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasDK3, .F., .T.)
					While (cAliasDK3)->(!EoF())
						DK3->(DbGoTo((cAliasDK3)->RECNODK3))
						RecLock('DK3',.F.)
						DK3->DK3_VIAGID := " "
						DK3->(MsUnlock())
						(cAliasDK3)->(DbSkip())
					EndDo
					(cAliasDK3)->(DbCloseArea())
				EndIf
			EndIf

		Next nY
	Next nX

	For nX := 1 To Len(oRepCan:trips)
		oRepCan:trips[nX] := Nil // Descarta a memória utilizada
	Next nX
	oRepCan:trips := {} // Descarta a memória utilizada

	If lRpcSetEnv
		RpcClearEnv()
	EndIf
Return oResponse

//-----------------------------------------------------------------------------
/*/{Protheus.doc} OMSGetEmp
	Busca todas as empresas e filiais em que a viagem foi gravada 
	no recebimento da publicação da viagem feita pelo CPL
@param nTripId, numérico, Número da viagem recebida na mensagem do CPL
@author  Jackson Patrick Werka
@since   23/07/2018
@version 1.0
/*/
//-----------------------------------------------------------------------------
Function OMSGetEmp(nTripId,cErro)
Local aRet      := {}
Local cNumTrip  := ""
Local nHwnd     := -1
Local nRetry    := 4
Local cQuery    := ""
Local cAliasNew := ''

Default cErro := ""
	OsLogCpl("OMSXCPLB -> OMSGetEmp -> Inicio da Viagem " + cValToChar(nTripId),"INFO" )
	
	While nHwnd < 0 .And. nRetry > 0
		nHwnd := TcLink()
		nRetry--
	EndDo

	// Abrindo a tabela de relacionamento de viagens, para buscar as empresas/filiais das viagens
	If nHwnd >= 0
		OsLogCpl("OMSXCPLB -> OMSGetEmp -> Conteúdo da variável nHwnd: " + cValToChar(nHwnd),"INFO" )
		If Select( cOmsCplRel ) <= 0
			// DBUseArea( [ lNewArea ], [ cDriver ], < cFile >, < cAlias >, [ lShared ], [ lReadOnly ] )
			DbUseArea(.T.,'TOPCONN',cOmsCplRel,cOmsCplRel,.T.,.T.)
			TCSetField(cOmsCplRel,'DATAINT','D',8,0)
			TCSetField(cOmsCplRel,'CPLMSGID','N',10,0)
			TCSetField(cOmsCplRel,'RECNOVIAG','N',10,0)
			(cOmsCplRel)->(DbSetIndex(cOmsCplRel +"1"))
			(cOmsCplRel)->(DbSetIndex(cOmsCplRel +"2"))
		EndIf
		cNumTrip := PadR(cValToChar(nTripId),Len((cOmsCplRel)->VIAGEM))
		
		cQuery := "SELECT EMPRESA, FILIAL FROM " + cOmsCplRel + " WHERE VIAGEM = '" + cNumTrip + "' AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		OsLogCpl("OMSXCPLB -> OMSGetEmp-> Conteúdo cQuery" + cValToChar(Trim(cQuery)) ,"INFO" )
		cAliasNew := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.T.,.T.)
		While (cAliasNew)->(!Eof()) 
			OsLogCpl("OMSXCPLB -> OMSGetEmp-> Empresa: " + cValToChar(Trim((cAliasNew)->EMPRESA)) + " / Filial: " + cValToChar(Trim((cAliasNew)->FILIAL)), "INFO" )
			Aadd(aRet, {(cAliasNew)->EMPRESA, (cAliasNew)->FILIAL})
			(cAliasNew)->( DbSkip() )			
		EndDo
		(cAliasNew)->(DbcloseArea())		

		If Empty(aRet)
			OsLogCpl("OMSXCPLB -> OMSGetEmp-> Não encontrou nenhuma empresa/filial.","INFO" )
		EndIf

		(cOmsCplRel)->( DbCloseArea() )
		// Se criou uma conexão temporária, fecha ela
		If nHwnd >= 0
			TCUnlink(nHwnd)
		EndIf
	Else
		cErro := STR0017 //Falha em estabelecer uma conexão com o banco de dados. 
		cErro += OmsFmtMsg(STR0018,{{"[VAR01]",cValToChar(nHwnd)}}) //Código de erro DBACCESS: [VAR01]. 
		cErro += STR0019 //Busque pelo código de erro no TDN para verificar sua descrição e solução. 
		cErro += STR0020 //Verifique também o DBAlias, DBPort, DBDataBase e DBServer informados no appserver.ini. 
		OsLogCpl("OMSXCPLB -> OMSGetEmp-> Conteúdo da variável cErro: "+cValToChar(Trim(cErro)),"ERROR" )
		SetFaultTMS(STR0021,cErro) //Falha na Comunicação com o Banco
	EndIf
Return aRet
// ---------------------------------------------------------
/*/{Protheus.doc} ExistViag
Verifica se existe viagem com carga montada para o pedido
@author amanda.vieira
@since 23/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static Function ExistViag(cPedido)
Local lRet      := .F.
Local cQuery    := ""
Local cAliasQry := ""
    cQuery := " SELECT SC6.C6_NUM"
    cQuery +=   " FROM "+RetSqlName('SC6')+" SC6"
    cQuery +=  " INNER JOIN "+RetSqlName('DK1')+" DK1"
    cQuery +=     " ON DK1.DK1_FILIAL = '"+xFilial('DK1')+"'"
    cQuery +=    " AND DK1.DK1_FILPED = SC6.C6_FILIAL"
    cQuery +=    " AND DK1.DK1_PEDIDO = SC6.C6_NUM"
    cQuery +=    " AND DK1.DK1_ITEMPE = SC6.C6_ITEM"
    cQuery +=    " AND DK1.DK1_PRODUT = SC6.C6_PRODUTO"
    cQuery +=    " AND DK1.DK1_NFISCA = ' '"  //Ainda não faturada
    cQuery +=    " AND DK1.D_E_L_E_T_ = ' '"
    cQuery +=  " INNER JOIN "+RetSqlName('DK0')+" DK0"
    cQuery +=     " ON DK0.DK0_FILIAL = '"+xFilial('DK0')+"'"
    cQuery +=    " AND DK0.DK0_REGID  = DK1_REGID"
    cQuery +=    " AND DK0.DK0_VIAGID = DK1_VIAGID"
    cQuery +=    " AND DK0.DK0_CARGER  = '1'" //Carga gerada
    cQuery +=    " AND DK0.DK0_SITINT NOT IN ('4','5')"    //0=Recebida;1=Aguardando liberação;2=Liberada;3=Falha liberação;4=Reprogramada;5=Cancelada;6=Rejeitada
    cQuery +=    " AND DK0.D_E_L_E_T_ = ' '"
    cQuery +=  " WHERE SC6.C6_FILIAL  = '"+xFilial('SC6')+"'"
    cQuery +=    " AND SC6.C6_NUM     = '"+cPedido+"'"
    cQuery +=    " AND SC6.D_E_L_E_T_ = ' '"
    cQuery := ChangeQuery(cQuery)
	OsLogCpl("OMSXCPLB -> ExistViag-> Pedido "+cValToChar(Trim(cPedido))+" Conteúdo de cQuery: " +cValToChar(Trim(cQuery)),"INFO" )
    cAliasQry := GetNextAlias()
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
    If (cAliasQry)->(!EoF())
        lRet := .T.
    EndIf
    (cAliasQry)->(DbCloseArea())
Return lRet
// ---------------------------------------------------------
/*/{Protheus.doc} VldPedInt
Valida se o pedido encontra-se integrado com o CPL
@author amanda.vieira
@since 23/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
Static Function VldPedInt(cPedido,cItem,cProduto)
Local lRet      := .F.
Local cAliasSC6 := GetNextAlias()
Local cQuery    := ""
Default cItem   := ""
Default cProduto:= ""
	cQuery := " SELECT C6_NUM"
	cQuery +=   " FROM "+RetSqlName('SC6')
	cQuery +=  " WHERE C6_FILIAL  = '"+xFilial('SC6')+"'"
	cQuery +=    " AND C6_NUM     = '"+cPedido+"'"
	cQuery +=    " AND C6_INTROT IN ('2','4')"
	If !Empty(cItem)
		cQuery +=    " AND C6_ITEM    = '"+cItem+"'"
	EndIf
	If !Empty(cProduto)
		cQuery +=    " AND C6_PRODUTO = '"+cProduto+"'"
	EndIf
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	OsLogCpl("OMSXCPLB -> VldPedInt-> Pedido "+cValToChar(Trim(cPedido))+" Conteúdo de cQuery: " +cValToChar(Trim(cQuery)),"INFO" )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSC6, .F., .T.)
	If (cAliasSC6)->(!EoF())
		lRet := .T.
	EndIf
	(cAliasSC6)->(DbCloseArea())
Return lRet
// ---------------------------------------------------------
/*/{Protheus.doc} OMSCPLVlQt
Valida quantidade digitada na alteração do pedido
@author amanda.vieira
@since 23/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
Function OMSCPLVlQt(cReadVar,xConteudo,lHelp)
Local lRet      := .T.
Local lExistDK3 := TableInDic('DK3') .And. OMSCPLDK3(SC6->C6_NUM)
Local nQtdInt   := 0
    If lExistDK3 .And. "C6_QTDVEN" $ cReadVar
        If !(QtdComp(xConteudo) == QtdComp(SC6->C6_QTDVEN))
            nQtdInt := Cpl6QtdInt(SC6->C6_FILIAL,SC6->C6_NUM,SC6->C6_ITEM,SC6->C6_PRODUTO)
            If QtdComp(xConteudo) < QtdComp(nQtdInt)
                If lHelp
                    OmsMessage(STR0002,OMSCPLB09) //Quantidade do pedido já comprometida com a integração do Cockpit Logístico. Desfaça a integração antes da alteração.
                EndIf
                lRet := .F.
            EndIf
        EndIf
    EndIf
Return lRet
// ---------------------------------------------------------
/*/{Protheus.doc} OMSCPLDK3
Valida se o pedido possuí DK3 (função para suavização)
@author amanda.vieira
@since 23/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
Function OMSCPLDK3(cPedido)
Local lRet   := .F.
Local cQuery := " "
Local cAliasDK3 := GetNextAlias()
	cQuery := " SELECT DK3_PEDIDO"
	cQuery +=   " FROM "+RetSqlName('DK3')
	cQuery +=  " WHERE DK3_FILIAL = '"+xFilial('DK3')+"'"
	cQuery +=    " AND DK3_PEDIDO = '"+cPedido+"'"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	OsLogCpl("OMSXCPLB -> OMSCPLDK3-> Pedido "+cValToChar(Trim(cPedido))+" Conteúdo de cQuery: " +cValToChar(Trim(cQuery)),"INFO" )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasDK3, .F., .T.)
	If (cAliasDK3)->(!EoF())
		lRet := .T.
	EndIf
	(cAliasDK3)->(DbCloseArea())
Return lRet
// ---------------------------------------------------------
/*/{Protheus.doc} OMSCPLVlPd
Valida ações da manipulação do pedido
@author amanda.vieira
@since 23/10/2018
@version 1.0
/*/
// ---------------------------------------------------------
Function OMSCPLVlPd(nAcao,cPedido,aHeader,aCols)
Local lRet      := .T.
Local lExistDK3 := TableInDic('DK3') .And. OMSCPLDK3(cPedido)
Local nQtdInt   := 0
Local nPosItem  := 0
Local nPosProd  := 0
Local nPosQtd   := 0
Local nUltPos   := 0 //Ultima posição do aCols que indica se o registro foi excluído
Local nQtdPed   := 0
Local nQtdNFat  := 0
Local nI        := 0
Local nPosQtdLib:= 0
Local nQtdFat   := 0
Local nQtdVen   := 0
Local aAreaSC6  := SC6->(GetArea())
Local aTamSX3   := TamSX3("C6_QTDVEN") 
Local cItem     := ""
Local cProduto  := ""
Local cQuery    := ""
Local cAliasSC6 := ""
Local cAliasPed := ""
Local cIntRot   := ""
Local lPedLib   := (SuperGetMv("MV_CPLPELB",.F.,"2") == "2") //Indica se permite integração de quantidades não liberadas
Default nAcao := 1

	PutGlbValue( "GLB_OMSLOG",GetSrvProfString("LOGCPLOMS", ".F.") )
	PutGlbValue( "GLB_OMSTIP",GetSrvProfString("LOGTIPOMS", "CONSOLE") )

    If nAcao == 1 //Ao confirmar a exclusão do pedido
		If VldPedInt(cPedido)
			OmsMessage(STR0004,OMSCPLB01) //O pedido possui quantidade integrada com o Cockpit Logístico. Desfaça a integração antes da exclusão.
			lRet := .F.
		EndIf
    ElseIf nAcao == 2 //Antes de abrir a tela de alteração do pedido
		If lRet
			If lExistDK3
				If ExistViag(cPedido)
					OmsMessage(STR0005,OMSCPLB02) //O pedido possui viagem e carga gerada pelo Cockpit Logístico. Desfaça a montagem da carga antes da alteração.
					lRet := .F.
				EndIf
			Else
				If VldPedInt(cPedido)
					OmsMessage(STR0006,OMSCPLB03) //O pedido possui quantidade comprometida com Cockpit Logístico. Desfaça a integração antes da alteração.
					lRet := .F.
				EndIf
			EndIf
		EndIf
    ElseIf nAcao == 4 //Ao confirmar a alteração
    	//O número do pedido à ser considerado deve ser o valor em memória quando chamado da função A410VldTOk (ação 4)
    	cPedido := M->C5_NUM
    	
		If lExistDK3
			If ExistViag(cPedido)
				OmsMessage(STR0005,OMSCPLB04) //O pedido possui viagem e carga gerada pelo Cockpit Logístico. Desfaça a montagem da carga antes da alteração.
				lRet := .F.
			EndIf
			If lRet
				nPosItem   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
				nPosProd   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
				nPosQtd    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
				nPosQtdLib := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})

				For nI := 1 To Len(aCols)
					cItem   := aCols[nI][nPosItem]
					cProduto:= aCols[nI][nPosProd]
					nUltPos := Len(aHeader)+1
					
					cAliasPed := GetNextAlias()
					BeginSql Alias cAliasPed
						SELECT SC6.C6_QTDENT,
							   SC6.C6_INTROT,
							   SC6.C6_QTDVEN
						  FROM %Table:SC6% SC6
						 WHERE SC6.C6_FILIAL = %xFilial:SC6%
						   AND SC6.C6_NUM = %Exp:cPedido%
						   AND SC6.C6_ITEM = %Exp:cItem%
						   AND SC6.C6_PRODUTO = %Exp:cProduto%
						   AND SC6.%NotDel%
					EndSql
					If (cAliasPed)->(!EoF())
						nQtdFat := (cAliasPed)->C6_QTDENT
						cIntRot := (cAliasPed)->C6_INTROT
						nQtdVen := (cAliasPed)->C6_QTDVEN
					EndIf
					(cAliasPed)->(DbCloseArea())
					
					If lPedLib // Se permite a integração apenas de pedidos liberados, realiza a validação com a quantidade liberada
						nQtdPed := Iif(aCols[nI][nUltPos],0,aCols[nI][nPosQtdLib]+nQtdFat)
					Else
						nQtdPed := Iif(aCols[nI][nUltPos],0,aCols[nI][nPosQtd])
					EndIf
					
					nQtdInt := Cpl6QtdInt(xFilial('SC6'),cPedido,cItem,cProduto)
					If QtdComp(nQtdPed) < QtdComp(nQtdInt)
						OmsMessage(STR0006,OMSCPLB05) //O pedido possui quantidade comprometida com Cockpit Logístico. Desfaça a integração antes da alteração.
						lRet := .F.
						Exit
					EndIf
					If lRet .And. QtdComp(nQtdInt) > 0 
						If cIntRot == "2" .And. QtdComp(nQtdPed) > QtdComp(nQtdVen) //Se aumentou a quantidade do pedido e o status da integração é 2-Integrado 'total' é necessário alterar para 4-Integrado Parcial
							nPosIntR := aScan(aHeader,{|x| AllTrim(x[2])=="C6_INTROT"})
							aCols[nI][nPosIntR] := "4" //Integrado Parcial
						ElseIf !(cIntRot == "2") .And. QtdComp(aCols[nI][nPosQtd]) == QtdComp(nQtdInt) //Se a quantidade do pedido for igual a quantidade integada o status deverá ser mudado para 2-Integrado
							nPosIntR := aScan(aHeader,{|x| AllTrim(x[2])=="C6_INTROT"})
							aCols[nI][nPosIntR] := "2" //Integrado
						EndIf
					EndIf
				Next nI
			EndIf
		Else
			If VldPedInt(cPedido)
				OmsMessage(STR0006,OMSCPLB06) //O pedido possui quantidade comprometida com Cockpit Logístico. Desfaça a integração antes da alteração.
				lRet := .F.
			EndIf
		EndIf
    ElseIf nAcao == 5 // Ao confirmar a eliminação de resíduos
		cQuery := " SELECT C6_ITEM,"
		cQuery +=        " C6_PRODUTO,"
		cQuery +=        " C6_QTDENT,"
		cQuery +=        " C6_QTDVEN"
		cQuery +=   " FROM "+RetSqlName('SC6')
		cQuery +=  " WHERE C6_FILIAL = '"+xFilial('SC6')+"'"
		cQuery +=    " AND C6_NUM = '"+cPedido+"'"
		cQuery +=    " AND C6_INTROT <> '1'"
		cQuery +=    " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		OsLogCpl("OMSXCPLB -> OMSCPLVlPd-> Pedido "+cValToChar(Trim(cPedido))+" Conteúdo de cQuery: " +cValToChar(Trim(cQuery)),"INFO" )
		cAliasSC6 := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSC6, .F., .T.)
		TCSetField(cAliasSC6,'C6_QTDENT','N',aTamSx3[1],aTamSx3[2])
		TCSetField(cAliasSC6,'C6_QTDVEN','N',aTamSx3[1],aTamSx3[2])
		While (cAliasSC6)->(!EoF()) .And. lRet
			If lExistDK3
				nQtdInt := Cpl6QtdInt(xFilial('SC6'),cPedido,(cAliasSC6)->C6_ITEM,(cAliasSC6)->C6_PRODUTO)
				If QtdComp(nQtdInt) > QtdComp((cAliasSC6)->C6_QTDENT)
					nQtdNFat := nQtdInt - (cAliasSC6)->C6_QTDENT
					OmsMessage(OmsFmtMsg(STR0007,{{"[VAR01]",(cAliasSC6)->C6_ITEM},{"[VAR02]",AllTrim((cAliasSC6)->C6_PRODUTO)},{"[VAR03]",cValToChar(nQtdNFat)}}),OMSCPLB07) //O item/produto [VAR01]/[VAR02] possuí quantidade [VAR03] não faturada, porém integrada com o Cockpit Logístico. Desfaça a integração ou fature o restante do pedido antes de eliminar resíduos.
					lRet := .F.
				EndIf
			Else
				//Quando não existe controle de envio parcial, considera-se que a quantidade integrada é igual à quantidade do pedido.
				//Verifica se usuário quer permitir a eliminação de resíduos mesmo sabendo que a quantidade do pedido não será estornada do CPL.
				If !((cAliasSC6)->C6_QTDENT == (cAliasSC6)->C6_QTDVEN)
					nQtdNFat := (cAliasSC6)->C6_QTDVEN - (cAliasSC6)->C6_QTDENT
					If !OmsMessage(STR0016,OMSCPLB08,3)  // O pedido possuí quantidade integrada com o Cockpit Logístico. Ao eliminar resíduos, os itens e quantidades removidas do pedido não refletirão no Cockpit. Deseja confirmar ação?
						lRet := .F.
					Else 
						Exit
					EndIf
				EndIf
			EndIf
			(cAliasSC6)->(DbSkip())
		EndDo
		(cAliasSC6)->(DbCloseArea())
	ElseIf nAcao == 6 //Ao tentar realizar o estorno da liberação via rotina de Preparação dos Documentos de Saída (MATA461)
		If lPedLib 
			If !VldPedSc9(cPedido,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_SEQUEN) //Verifica se o registro da SC9 pode ser estornado.
				OmsMessage(OmsFmtMsg(STR0014,{{"[VAR01]",cPedido},{"[VAR02]",SC9->C9_ITEM}}),OMSCPLB11) // O pedido/item [VAR01]/[VAR02] possui quantidade comprometida com Cockpit Logístico. Desfaça a integração antes de estornar a liberação do pedido.
				lRet := .F.
			Endif
		else
			If  VldPedInt(cPedido,SC9->C9_ITEM,SC9->C9_PRODUTO) //Se estiver configurado para enviar apenas quantidades liberadas ou se não existe a tabela de envio parcial de pedido, não deixa alterar o pedido, pois isso causaria o estorno da liberação.
				OmsMessage(OmsFmtMsg(STR0014,{{"[VAR01]",cPedido},{"[VAR02]",SC9->C9_ITEM}}),OMSCPLB11) // O pedido/item [VAR01]/[VAR02] possui quantidade comprometida com Cockpit Logístico. Desfaça a integração antes de estornar a liberação do pedido.
				lRet := .F.
			EndIf
			If lRet .And. lExistDK3
				If ExistViag(cPedido)
					OmsMessage(OmsFmtMsg(STR0015,{{"[VAR01]",cPedido},{"[VAR02]",SC9->C9_ITEM}}),OMSCPLB12) // O pedido/item [VAR01]/[VAR02] possui viagem e carga gerada pelo Cockpit Logístico. Desfaça a montagem da carga antes de estornar a liberação do pedido.
					lRet := .F.
				Endif	
			EndIf
		EndIf
	EndIf
    RestArea(aAreaSC6)
Return lRet

/*/{Protheus.doc} VldPedSC9
Valida se o Registro da SC9 pode ser estornado.
@author Murilo Brandao
@since 23/10/2022
@version 1.0
/*/
// ---------------------------------------------------------
Static Function VldPedSc9(cPedido,cItem,cProduto,cSeqSc9)
Local lRet      := .F.
Local cAliasSC9 := GetNextAlias()
Local cQuery    := ""

	cQuery := " SELECT C9_PEDIDO"
	cQuery +=   " FROM "+RetSqlName('SC9')
	cQuery +=  " WHERE C9_FILIAL  = '"+xFilial('SC9')+"'"
	cQuery +=    " AND C9_PEDIDO  = '"+cPedido+"'"
	cQuery +=    " AND C9_ITEM    = '"+cItem+"'"
	cQuery +=    " AND C9_PRODUTO = '"+cProduto+"'"
	cQuery +=    " AND C9_SEQUEN  = '"+cSeqSc9+"'"
	cQuery +=    " AND C9_NFISCAL = ' '"
	cQuery +=    " AND C9_SERIENF = ' '"
	cQuery +=    " AND C9_CARGA   = ' '"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	OsLogCpl("OMSXCPLB -> VldPedSc9-> Pedido "+cValToChar(Trim(cPedido))+" Conteúdo de cQuery: " +cValToChar(Trim(cQuery)),"INFO" )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSC9, .F., .T.)
	If (cAliasSC9)->(!EoF())
		lRet := .T.
	EndIf
	(cAliasSC9)->(DbCloseArea())
Return lRet

