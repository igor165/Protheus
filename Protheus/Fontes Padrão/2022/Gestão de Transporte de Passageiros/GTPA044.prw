#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA044.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA044
Rotina de disparo de emails de alertas atraves do Job

@author	Renan Ribeiro Brando
@since  25/07/2017
@return	Nil
/*/
//-------------------------------------------------------------------
Function GTPA044(aParams)

RpcSetType(3) // Executa sem consumir licença

RpcSetEnv(aParams[1], aParams[2], , , "GTP")

// Inicia a JOB
GTPA044JOB()
	
RpcClearEnv()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA044JOB
JOB de envio de e-mails
@author  Renan Ribeiro Brando
@since   19/07/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPA044JOB() 

    Local cQuery := ""
    Local cStyle := ""
    Local nStatus := 0
    Local aMails := {}
    Local aEvent := {}
    Local aValid := {}
    Local nI := 1
    Local cAliasGZ8 := GetNextAlias()
    Local cAliasQuery := GetNextAlias()

    // Cria estilo da tabela disparada no e-mail
    cStyle := "<style>"
    cStyle += "table { margin-top:50px; border-style:outset; width: 100%; font-family:arial, helvetica, sans-serif; }"
    cStyle += "table, th, td { border: 1px solid #08667E; }"
    cStyle += "th { background-color: #08667E; color: #FFF; }"
    cStyle += "th, td { text-align: left; padding: 8px; }"
    cStyle += "td { color: #555; font-weight:bold }"
    cStyle += "tr:nth-child(odd){ background-color: #95D8E9 }"
    cStyle += ".totvs{ margin: 20px; font-weight:bold; color:#08667E; font-size:14px; text-align:center; font-family:arial, helvetica, sans-serif; }"
    cStyle += "</style>"

    // Busca todos os eventos
    BeginSQL alias cAliasGZ8
        SELECT GZ8.GZ8_CODIGO, 
            GZ8.GZ8_DESEVE, 
            GZ8.GZ8_STATUS, 
            GZ8.GZ8_TITULO, 
            GZ8.GZ8_TEXTO,
            GZ8.GZ8_RECOR,
            GZ8.GZ8_SQL,
            GZ8.R_E_C_N_O_ GZ8_RECNO
        FROM %table:GZ8% GZ8  
        WHERE GZ8.GZ8_FILIAL = %xFilial:GZ8%
            AND GZ8.%NotDel% 
        ORDER BY GZ8.GZ8_CODIGO
    EndSQL

    // Percorre a tabela de eventos
    WHILE ((cAliasGZ8)->(!Eof()))
        AADD(aEvent, (cAliasGZ8)->GZ8_CODIGO)
        AADD(aEvent, (cAliasGZ8)->GZ8_DESEVE)
        AADD(aEvent, (cAliasGZ8)->GZ8_STATUS)
        AADD(aEvent, (cAliasGZ8)->GZ8_TITULO)
        // Pega o registro via recno, pois leitura normal do campo memo trazia null
        GZ8->(DBGoTo((cAliasGZ8)->GZ8_RECNO))
        AADD(aEvent, GZ8->GZ8_TEXTO)
        AADD(aEvent, (cAliasGZ8)->GZ8_RECOR)
        GZ8->(DBGoTo((cAliasGZ8)->GZ8_RECNO))
        cQuery := GZ8->GZ8_SQL
        cQuery := changeKey(cQuery)
        
         // Roda query no alias cAliasQuery
        dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQuery, .T., .T.)
        
        If ((cAliasQuery)->(!Eof()))
            // Se o e-mail for ativo    
            If (aEvent[3] == "1")
                // Pega todos os destinatários que vão receber o e-mail para o evento
                aMails := GA044GetUsers(aEvent[1])
                // Executa validação da query
                nStatus := TCSqlExec(cQuery)

                If nStatus == 0
                    // Envia os emails para todos os destinatário um por vez validando sua recorrência 
                    GA044SendMail(aEvent, aMails, cQuery, cStyle)

                EndIf

            EndIf
            
            (cAliasQuery)->(DbCloseArea())

            (cAliasGZ8)->(DBSkip())
            
            aEvent := {}
        Else 
            (cAliasQuery)->(DbCloseArea())  
            (cAliasGZ8)->(DBSkip()) 
            aEvent := {}
        EndIf
   
    END

    (cAliasGZ8)->(DbCloseArea())

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GA044GetUsers(nEvent)
Traz um array com os destinatários daquele evento
@author  Renan Ribeiro Brando   
@since   20/07/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function GA044GetUsers(nEvent)

    Local aMails := {}
    Local cAliasGZ5 := GetNextAlias()

    BeginSQL alias cAliasGZ5
        SELECT GZ5.GZ5_EMAIL 
        FROM  %TABLE:GZ5% GZ5, 
            %TABLE:GZ4% GZ4 
	    WHERE GZ5.GZ5_FILIAL = %xFilial:GZ5%
            AND GZ4.GZ4_FILIAL = %xFilial:GZ4%
            AND GZ5.%NotDel% 
            AND GZ4.%NotDel%
            AND GZ5.GZ5_CODIGO = GZ4.GZ4_CODDES
		    AND GZ4.GZ4_CODEVE = %Exp:nEvent% 
    EndSQL

    WHILE ((cAliasGZ5)->(!Eof()))
        AADD(aMails, (cAliasGZ5)->GZ5_EMAIL)
        (cAliasGZ5)->(DBSkip())
    END

    (cAliasGZ5)->(DbCloseArea())

Return AClone(aMails)

//-------------------------------------------------------------------
/*/{Protheus.doc} GA044GenLog(aData)
Gera log do e-mail enviado
@sample  GA044GenLog({cCode, cEmail, cExpression, cHash, cStatus})
@author  Renan Ribeiro Brando   
@since   21/07/2017 
@version P12
/*/
//-------------------------------------------------------------------
Function GA044GenLog(aData)

    Local oModel := FWLoadModel("GTPA043")
    Local oModelGZ9 := oModel:GetModel("GZ9MASTER")
    Local lRet := .F.
    Default aData := Array(6) //aData[1] := nil; aData[2] := nil; ...; aData[5] := Nil
    
    If (Len(aData) >= 6 .And. ValType(aData[6]) == "U")
        aData[6] := 1
    EndIf

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()  

    oModelGZ9:SetValue("GZ9_CODIGO", GetSXEnum("GZ9"))
    oModelGZ9:SetValue("GZ9_CODEVE", aData[1])
    oModelGZ9:SetValue("GZ9_DESCEV", POSICIONE("GZ8", 1, XFILIAL("GZ8")+aData[1], "GZ8_DESEVE"))
    oModelGZ9:SetValue("GZ9_DEST"  , aData[2])
    oModelGZ9:SetValue("GZ9_EXPREG", aData[3])
    oModelGZ9:SetValue("GZ9_DTDISP", dDatabase)
    oModelGZ9:SetValue("GZ9_HRDISP", Time())
    oModelGZ9:SetValue("GZ9_HASH"  , aData[4])
    oModelGZ9:SetValue("GZ9_STATUS", aData[5])

    If (lRet := oModel:VldData())
        lRet := oModel:CommitData()
    EndIf

    oModel:Deactivate()  
    oModel:Destroy()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GA044SendMail(aEvent, aMails, cQuery, cStyle)
Envia o e-mail para os destinatários
@author  Renan Ribeiro Brando
@since   24/07/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GA044SendMail(aEvent, aMails, cQuery, cStyle, lLog)

    Local aValid := {}
    Local aStruct := {}
    Local aMailsFailed := {}
    Local nI := 1
    Local lRet := .T.
    Local cHeader := ""
    Local cBody := ""
    Local cRows := ""
    Local cResultSet := ""
    Local cAliasGZ9 := GetNextAlias()
    Local cAliasQuery := GetNextAlias()
    Default lLog := .T.
    Default cStyle := "<style>";
    + "table { margin-top:50px; border-style:outset; width: 100%; font-family:arial, helvetica, sans-serif; }";
    + "table, th, td { border: 1px solid #08667E; }";
    + "th { background-color: #08667E; color: #FFF; }";
    + "th, td { text-align: left; padding: 8px; }";
    + "td { color: #555; font-weight:bold }";
    + "tr:nth-child(odd){ background-color: #95D8E9 }";
    + ".totvs{ margin: 20px; font-weight:bold; color:#08667E; font-size:14px; text-align:center; font-family:arial, helvetica, sans-serif; }";
    + "</style>"

    // Adiciona estilo ao html da tabela
    cBody := cStyle + "<table>"

    // Roda query no alias cAliasQuery
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQuery, .T., .T.)

    // Armazena resultset no array aStruct
    aStruct := (cAliasQuery)->(DbStruct())

    // Inicia linha do cabeçalho
    cBody += "<tr>"

    // Percorre e cria campos do cabeçalho como table headers 
    For nI := 1 to Len(aStruct)  
        cHeader += "<th>" + RetTitle((cAliasQuery)->(aStruct[nI][1])) +  "</th>"
    Next nI

    // Adiciona cabeçalho da tabela 
    cBody += cHeader

    // Fecha linha de cabeçalho
    cBody += "</tr>"

    // Percorre resultset e cria os table datas correspondentes com os formatos dos campos
    While ((cAliasQuery)->(!Eof()))
    	cRows += "<tr>"
     
    	For nI := 1 to Len(aStruct)
    		If Len(TamSx3(aStruct[nI][1])) >= 3
            // Caso o campo seja uma data
            	If TamSx3(aStruct[nI][1])[3] == "D"
            		cRows += "<td>" +AllToChar( StoD( (cAliasQuery)->(&(aStruct[nI][1])) ) )  +  "</td>"
            	Else
                // Caso o campo possua uma picture
                	If !Empty(cPicture := AvSx3(aStruct[nI][1] , 6 /*Picture*/) )
                		cRows += "<td>" + AllToChar(Transform((cAliasQuery)->(&(aStruct[nI][1])) ,cPicture)) +  "</td>"
                	Else
                // Se o campo não possuir picture
                    cRows += "<td>" + AllToChar((cAliasQuery)->(&(aStruct[nI][1]))) +  "</td>"
                    Endif   
                Endif
           Else
           	  cRows += "<td>" + AllToChar((cAliasQuery)->(&(aStruct[nI][1]))) +  "</td>"
           EndIf
           
		Next nI
		
			cRows += "</tr>"
		    (cAliasQuery)->(DBSkip())
	End

    // Fecha tabela
    cBody += cRows + "</table>"
    // Adiciona rodapé da tabela
    cBody += "<div class='totvs'>" + STR0003 + " &copy</div>" // RELATÓRIO DE E-MAIL ENVIADO POR TOTVS 

    (cAliasQuery)->(DbCloseArea())

    // Se o e-mail for recorrente 
    If (aEvent[6] == "1")
        // Dispara os e-mails individualmente para cada destinatário 
        For nI:= 1 to Len(aMails)
            aValid := AClone(GTPXEnvMail( "noreply@totvs.com.br", aMails[nI], "", "", aEvent[4], aEvent[5] + cBody, {}))
            If (aValid[1])
                // Quando o e-mail for um teste não é necessário gerar log
                If (lLog)
                    GA044GenLog({aEvent[1], aMails[nI], cQuery, MD5(cBody, 2), "1"})
                EndIf
            Else
                // Quando o e-mail for um teste não é necessário gerar log
                If (lLog)
                    GA044GenLog({aEvent[1], aMails[nI], cQuery, MD5(cBody, 2), "2"})
                EndIf
                lRet := .F.
                AADD(aMailsFailed, aMails[nI])
            EndIf
        Next nI
    // Se o e-mail não for recorrente
    Else
        // Pega o hash do último resultset enviado  
           BeginSQL alias cAliasGZ9
                SELECT GZ9.GZ9_HASH 
                FROM %TABLE:GZ9% GZ9
	            WHERE GZ9.GZ9_FILIAL = %xFilial:GZ9%
                    AND GZ9.%NotDel% 
                    AND GZ9.GZ9_CODEVE = %Exp:aEvent[1]% 
	            ORDER BY GZ9.GZ9_DTDISP DESC, 
                    GZ9.GZ9_HRDISP DESC
            EndSQL

            // Verifica os hashs dos corpos dos e-mails para ver se são os mesmos
            If ((cAliasGZ9)->GZ9_HASH !=  MD5(cBody, 2))

                For nI:= 1 to Len(aMails)
                    aValid := AClone(GTPXEnvMail( "noreply@totvs.com.br", aMails[nI], "", "", aEvent[4], aEvent[5] + cBody, {}))
                    If (aValid[1])
                        // Quando o e-mail for um teste não é necessário gerar log
                        If (lLog)
                            GA044GenLog({aEvent[1], aMails[nI], cQuery, MD5(cBody, 2), "1"})
                        EndIf
                    Else
                        // Quando o e-mail for um teste não é necessário gerar log
                        If (lLog)
                            GA044GenLog({aEvent[1], aMails[nI], cQuery, MD5(cBody, 2), "2"})
                        EndIf

                        lRet := .F.
                        AADD(aMailsFailed, aMails[nI])
                    EndIf
                Next nI

            EndIf

            (cAliasGZ9)->(DbCloseArea())
        
    EndIf

Return AClone({lRet, aMailsFailed})


//-------------------------------------------------------------------
/*/{Protheus.doc} changeKey(cQuery)
Substitui uma expressão "[|exp|]" por seu conteúdo executado. 
E.g. [|dDataBase|] retornará a data atual
@author  Renan Ribeiro Brando   
@since   03/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function changeKey(cQuery)
    
    Local nFirst := AT("[|", cQuery)
    Local nLast := 0
    Local cTemp := ""
    
    If (nFirst>0)
        nLast :=  AT("|]", cQuery) 
        cTemp := SubStr( cQuery, nFirst, nLast+2-nFirst)
        cQuery := StrTran( cQuery, cTemp, getMacroKey(cTemp), 1, 1)
        return changeKey(cQuery)
    EndIf
    
return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} getMacroKey(cKey)
Função auxiliar de changeKey(cQuery) que extrai o conteúdo da tag [||]
e retorna o valor de seu conteúdo executado
@author  Renan Ribeiro Brando   
@since   03/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function getMacroKey(cKey)

    cKey := SubStr(cKey, 3, Len(cKey)-4)

    // Tratamento para trasnformar datas corretamente
    If (ValType(CtoD(DTOS(&cKey))) == "D")
        Return DTOS(&cKey)
    EndIf

Return cValToChar(&cKey)


//-------------------------------------------------------------------
/*/{Protheus.doc} getCAlias(cField)
Função que retorna o alias do campo

@author  Renan Ribeiro Brando   
@since   03/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function getCAlias(cField)
Return ALLTRIM(AvSx3(cField, 8))

//-------------------------------------------------------------------
/*/{Protheus.doc} getCAlias(cField)
Função que retorna o alias do campo

@author  Renan Ribeiro Brando   
@since   03/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function getDate(cField)

If (ValType(cField) == D)
    Return StoD(cField)
EndIf

Return cField