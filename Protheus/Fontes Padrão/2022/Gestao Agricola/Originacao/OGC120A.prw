#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "OGC120A.CH"

#DEFINE __CRLF CHR(13)+CHR(10)

Function OGC120A()
Return

/*{Protheus.doc} OGC120ACNT
//Função de tela do contato.
@author roney.maia
@since 24/04/2018
@version 1.0
@type function
*/
Function OGC120ACNT()

    Local aArea         := GetArea()
    Local oSize         := Nil
    Local oMStruNN7     := FwFormStruct(1, "NN7", {|x| AllTrim(x) $ "NN7_CONTOB;NN7_CONTST"})
    Local oVStruNN7     := FwFormStruct(2, "NN7", {|x| AllTrim(x) $ "NN7_CONTOB;NN7_CONTST"})
    Local oModel        := FwFormModel():New("OGC120", , , {|| .T.}, {|| .T.}) // Instancia um modelo
    Local oView         := FwFormView():New() // Instancia uma View
    Local oViewExec     := FWViewExec():New() // Instancia um Executor de View
    Local aButtons 	    := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., STR0011},{.T., STR0012},{.F., Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // # "Confirmar" # "Fechar"
	Local nWidth        := 0
    Local nHeight       := 0
    Local lRet          := .f.

  
    If NN7->NN7_STATUS == "5"
        Help( , , STR0003, , STR0013, 1, 0, ,,,,,{} )  //AJUDA //Previsão encontra-se com situação Finalizada. Não é possível registrar contato.
        RestArea(aArea)
        Return .F.
    EndIf
    
    oSize   := FwDefSize():New(.T.) // Considera a enchoice bar

	nWidth  := (oSize:AWINDSIZE[4] * 0.30) // 30% da largura total
    nHeight := (oSize:AWINDSIZE[3] * 0.25) // 20% da altura total

    oMStruNN7:SetProperty("NN7_CONTOB", MODEL_FIELD_INIT, {|| NN7->NN7_CONTOB})
    oMStruNN7:SetProperty("NN7_CONTST", MODEL_FIELD_INIT, {|| NN7->NN7_CONTST})
    
    oVStruNN7:SetProperty("NN7_CONTOB", MVC_VIEW_CANCHANGE, .T.)
    oVStruNN7:SetProperty("NN7_CONTST", MVC_VIEW_CANCHANGE, .T.)
    
    oVStruNN7:SetNoFolders(.T.)

    oModel:SetDescription(STR0001) // Pré requisito para criação de uma view # Contato
    oModel:AddFields("FIELDCONTATO", , oMStruNN7) // Pre requisito para criacao de uma view
    oModel:SetPrimaryKey({"NN7_CONTOB"})

    oView:SetModel(oModel)
    oView:AddField("VIEWCONTATO", oVStruNN7, "FIELDCONTATO")

    oView:CreateHorizontalBox("BOXVIEWCONTATO", 100)
    oView:SetOwnerView("VIEWCONTATO", "BOXVIEWCONTATO")

    oView:SetViewProperty("VIEWCONTATO", "SETLAYOUT", {FF_LAYOUT_VERT_DESCR_TOP, 1}) // Seta o layout de forma vertical com 1 coluna
 
    oViewExec:SetView(oView)
    oViewExec:setOperation(MODEL_OPERATION_INSERT)
    oViewExec:SetButtons(aButtons)
    oViewExec:SetTitle(STR0001) // # Contato
    oViewExec:SetOk({|oView| lRet := OGC120AOK(oModel)})
    oViewExec:SetSize(nHeight, nWidth) // Dimensões da tela
  
    oViewExec:openView(.F.)

    RestArea(aArea)

Return lRet

/*{Protheus.doc} OGC120AOK
//Confirmar da tela de contato, grava na
temporaria.
@author roney.maia
@since 24/04/2018
@version 1.0
@return ${return}, ${.T. - Valido, .F. - Invalido}
@param oModel, object, Modelo da tela
@type function
*/
Static Function OGC120AOK(oModel)

    Local cObs          := oModel:GetModel("FIELDCONTATO"):GetValue("NN7_CONTOB")
    Local cStatus       := oModel:GetModel("FIELDCONTATO"):GetValue("NN7_CONTST")
    Local lRet          := .T.

    Private _aRetGrv    := {}

    FwMsgRun(, {|tSay| _aRetGrv := fGravaCnt(cObs, cStatus)}, STR0002 + "...") // # Gravando contato... // Grava os contatos e modifica o status das previsões financeiras com base no agrupamento do painel

    If _aRetGrv[1] .AND. RecLock("NN7", .F.) // Se ocorreu tudo bem, então grava na temporaria
        NN7->NN7_CONTOB := cObs
        NN7->NN7_CONTST := cStatus

        NN7->(MsUnlock())
        
    ElseIf !_aRetGrv[1] // Se ocorreu algum erro na gravacao do contato na NN7, entao apresenta o erro
        Do Case
            Case _aRetGrv[2] == "SEEK"
                Help( , ,STR0003, , /*Mensagem de erro*/ _aRetGrv[3], 1, 0, ,,,,,{STR0004} ) // # "Ajuda" # "Verificar as previsões."
            Case _aRetGrv[2] == "RECLOCK"
                Help( , ,STR0003, , /*Mensagem de erro*/ _aRetGrv[3], 1, 0, ,,,,,{STR0005} ) // # "Ajuda" # "Verificar a tabela de previsões financeiras."
        EndCase
        lRet := .F.
    EndIf

Return lRet

/*{Protheus.doc} fGravaCnt
//Realiza a gravação da observacao e status do contato,
juntamente com o status da previsao financeira, respeitando o
agrupamento.
@author rafael.voltz / roney.maia
@since 30/04/2018
@version 1.0
@return ${return}, ${Array de retorno válido ou inválido contendo a mensagem de erro.}
@param cContOb, characters, Observação do contato
@param cContSt, characters, Status do contato
@type function
*/
Static Function fGravaCnt(cContOb, cContSt)

	Local cAliasQry  := GetNextAlias()	
	Local aAreaNN7   := NN7->(GetArea())
	Local aAreaN9K   := N9K->(GetArea())
    Local cStatus    := ""
    Local aRet       := {.T., ""}
    Local cMsg       := ""

    If "1" $ cContSt // Status 1 no combo e igual a confirmado
        cStatus := "2" // Status - Confirmado da Previsao financeira NN7
    ElseIf "2" $ cContSt // Status 2 no combo e igual a divergente
        cStatus := "3" // Status - Divergente da Previsao financeira NN7
    EndIf	
	
	cQuery := fQryContat() //OGC120AQRY( "2", "5" )  

	If Select(cAliasQry) > 0 // Se o alias estiver aberto, fecha o alias
		(cAliasQry)->( dbCloseArea() )
	EndIf
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , ChangeQuery(cQuery) ), cAliasQry, .F., .T. ) // Executa a query

	NN7->(dbSetOrder(1))
	While !(cAliasQry)->(EOF())		
		NN7->(dbGoTop()) // Posiciona no topo
		If NN7->(dbSeek((cAliasQry)->NN7_FILIAL + (cAliasQry)->NN7_CODCTR + (cAliasQry)->NN7_ITEM))
			
			If RecLock("NN7", .F.) // Grava na NN7 - Previsoes financeiras
				NN7->NN7_CONTOB := cContOb // Contato Observacao
				NN7->NN7_CONTST := cContSt // Status do contato
				If !Empty(cStatus) // Somente grava quando status for 1 ou 2 do combo
					NN7->NN7_STATUS := cStatus // Status da previsao financeira
				EndIf
				NN7->(MsUnlock())
				(cAliasQry)->(DbSkip())
			Else // Casso ocorrer erro na gravacao, retorna como falso e o ponto de erro
				(cAliasQry)->(dbCloseArea())
				RestArea(aAreaNN7)
				Return {.F., "RECLOCK", STR0006 } // # "Falha ao gravar a tabela NN7."						
			Endif
		Else // Casso nao encontrar o registro, retorna como falso e o ponto de erro			
			RestArea(aAreaNN7)
            cMsg := STR0007 + " " + STR0008 + " : " + (cAliasQry)->NN7_FILIAL +; // # "Previsão financeira não localizada." # Filial 
					" | " + STR0009 + " : " + (cAliasQry)->NN7_CODCTR + " | " + STR0010 + " : " + (cAliasQry)->NN7_ITEM // # Contrato # Item
			(cAliasQry)->(dbCloseArea())                                
            Return {.F., "SEEK", cMsg}	
		EndIf					
	EndDo
	(cAliasQry)->(dbCloseArea())	
	
	RestArea(aAreaNN7)
	RestArea(aAreaN9K)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fQryVincPR
Função responsável por montar a query de PR no browse vinculo
@author  Rafael Voltz
@since   31/07/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function fQryContat()
  Local cQuery  := ""  

    cQuery := " SELECT DISTINCT NN7.NN7_FILIAL  NN7_FILIAL, "
    cQuery += "                 NN7.NN7_CODCTR  NN7_CODCTR, "
    cQuery += "                 NN7.NN7_ITEM    NN7_ITEM    "
    cQuery += "      FROM "  + RetSqlName("NN7") + " NN7    "    
    cQuery += "     WHERE NN7.NN7_FILIAL = '"+ xFilial("NN7") + "' "    
    cQuery += "       AND NN7.NN7_CODCTR = '" + NN7->NN7_CODCTR + "'"
	cQuery += "       AND NN7.NN7_ITEM	 = '" + NN7->NN7_ITEM + "'"	
	cQuery += "       AND NN7.D_E_L_E_T_ = ''  "      

    cQuery := ChangeQuery(cQuery)

Return cQuery 





