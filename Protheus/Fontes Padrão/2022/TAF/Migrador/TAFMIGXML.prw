#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF Chr(13)+Chr(10)

// Cache da entidade
Static cIdEntidade := ""

/*{Protheus.doc} TAFMIGXML
Wizard responsável pelo processo de geração dos XMLs já transmitidos 
pelo TAF para migração para o Smart E-Social ou outra instalação TAF.
@type  Function
@author Diego Santos
@since 04-10-2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/

Function TAFMIGXML()

Local oNewPag
Local oStepWiz  := Nil
Local lCheck    := .F.
Local lRetMig   := .T.
Local lProcErr  := .F.

Local cUrlRest  := Space(100)
Local cUser     := Space(20)
Local cPsw      := Space(20)

Private aErros  := {}

//oNewPag:SetPrevWhen({|| !MigrInExec() })

If !isTAFInCloud()

    oStepWiz        := FWWizardControl():New()         //Instancia a classe FWWizard

    oStepWiz:ActiveUISteps()
    
    //----------------------
    // Pagina 1
    //----------------------
    oNewPag := oStepWiz:AddStep("1")
    //Altera a descrição do step
    oNewPag:SetStepDescription("Apresentação")
    //Define o bloco de construção
    oNewPag:SetConstruction(  { |Panel| TafWizSp1(Panel)} )
    //Define o bloco ao clicar no botão Próximo
    oNewPag:SetNextAction( { || .T. } )
    //Define o bloco ao clicar no botão Cancelar
    oNewPag:SetCancelAction( {  ||  Alert("Rotina cancelada pelo usuário.","TAF"), .T.} )

    
    //----------------------
    // Pagina 2
    //----------------------
    oNewPag := oStepWiz:AddStep("2", {  |Panel| TafWizSp2(Panel, @lCheck)   }   )
    oNewPag:SetStepDescription("Tabela de Migração")
    oNewPag:SetNextAction( { |Panel| TafGeraV2I(Panel, @lCheck) } )

    //Define o bloco ao clicar no botão Voltar
    oNewPag:SetCancelAction( {  ||  Alert("Rotina cancelada pelo usuário.","TAF"), .T.} )
    //oNewPag:SetCancelWhen(  { ||.F.} )
    //oNewPag:SetPrevWhen({|| .F. })
    
    //----------------------
    // Pagina 3
    //----------------------
    oNewPag := oStepWiz:AddStep("3", {  |Panel| TafWizSp3(Panel, @cUrlRest, @cUser, @cPsw)  }   )
    oNewPag:SetStepDescription("Integração API TAF")
    oNewPag:SetNextAction(  { |Panel| FwMsgRun(, { |Panel|validaCheck(lCheck,@lProcErr),TafRestMig(Panel, @cUrlRest, @cUser, @cPsw,@lRetMig,lProcErr) }, "Aguarde...", "Integração registros com a API do TAF... " ), lRetMig  }  )
    oNewPag:SetCancelAction( {  ||  Alert("Rotina cancelada pelo usuário.","TAF"), .T.} )
    oNewPag:SetCancelWhen(  { ||.T.} )
    oNewPag:SetPrevWhen({|| .F. })

    //----------------------
    // Pagina 4
    //----------------------
    oNewPag := oStepWiz:AddStep("4", {  |Panel| TafWizSp4(Panel)  }   )
    oNewPag:SetStepDescription("Relatório")
    //oNewPag:SetNextAction( { || .T.  } )
    oNewPag:SetNextAction( {  |Panel|  FwMsgRun( , { |Panel| TafRelMigr(Panel, aErros) }, "Aguarde...", "Gerando relatório de inconsistências de migração..." ) , .T.} )
    oNewPag:SetCancelWhen(  { ||.F.} )
    oNewPag:SetPrevWhen({|| .F. })

    //----------------------
    // Pagina 5
    //----------------------
    oNewPag := oStepWiz:AddStep("5", {  |Panel| TafWizSp5(Panel)  }   )
    oNewPag:SetStepDescription("Conclusão")
    oNewPag:SetNextAction( { || .T.  } )
    oNewPag:SetCancelAction( {  ||  Alert("Rotina cancelada pelo usuário.","TAF"), .T.} )
    oNewPag:SetCancelWhen(  { ||.F.} )
    oNewPag:SetPrevWhen({|| .F. })

    oStepWiz:Activate()

Else
    MsgAlert("Funcionalidade não disponível para processar no Smart")
EndIf

Return

/*
{Protheus.doc} validaCheck

@type  Static Function
@author Evandro dos Santos Oliveira
@since 07/06/2020
@version 1.0
@param lCheck - CheckBox de controle para informar que a execução
de um reprocessamento. 
@param lProcErr - Indica que o reprocessamento deve ser somente dos
itens com erro.
*/
Static Function validaCheck(lCheck,lProcErr)

    Local cSql := ""
    Local cMsg := ""
    Local nQtdErr := 0 

    cSql := "SELECT COUNT(*) QTD "
    cSql += "FROM " + RetSqlName("V2I") + " V2I "
    cSql += "WHERE "
    cSql += "V2I.V2I_FILIAL = '" + xFilial("V2I") + "' "
    cSql += "AND ((V2I.V2I_STATUS = '2' "
    cSql += "OR V2I.V2I_STATUS = '3') "
    cSql += "AND V2I.V2I_CODERR != ' ') "
    cSql += "AND V2I.D_E_L_E_T_ = ' ' "

    TCQuery cSql New Alias 'rsCountV2I'
    nQtdErr := rsCountV2I->QTD
    rsCountV2I->(dbCloseArea())

    cMsg := "Deseja realizar o reenvio somente dos registros com erro ?" 
    cMsg += CRLF + CRLF + "Ao clicar em Não serão processados somente os registros sem status de erro."

    If nQtdErr > 0 .And. lCheck .And. MsgYesNo(cMsg, "TOTVS" )
        lProcErr := .T.
    EndIf

Return Nil 
 
/*
{Protheus.doc} TafWizSp1
Passo 1 da rotina de geração de XMLs TAF.
@type  Static Function
@author Diego Santos
@since 04-10-2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function TafWizSp1(oPanel)

Local oSay1
Local oSay2
Local oSay3
Local oSay4

oSay1   := TSay():New(25, 20, {|| GetStepText("STEP1", "BEMVINDO")      }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

oSay2   := TSay():New(45, 20, {|| GetStepText("STEP1", "ASSIST")        }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

oSay3   := TSay():New(90, 20, {|| GetStepText("STEP1", "TITETAPAS")     }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

oSay4   := TSay():New(110, 25, {|| GetStepText("STEP1", "TEXTETAPAS")    }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

Return

/*
{Protheus.doc} TafWizSp2
Passo 2 da rotina de geração de XMLs TAF.
@type  Static Function
@author Diego Santos
@since 04-10-2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function TafWizSp2(oPanel, lCheck)

Local oSay1
Local oSay2
Local oSay3
Local oSay4


Local oCheckBox

oSay1 := TSay():New(25, 20, {|| GetStepText("STEP2", "PASSO1")      }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

oSay2 := TSay():New(65, 30, {|| GetStepText("STEP2", "INFOPAS1-1")  }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

oSay3 := TSay():New(95, 30, {|| GetStepText("STEP2", "INFOPAS1-2")  }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

oCheckBox := TCheckBox():New( 145, 30, "", {|| lCheck }, oPanel, 10, 10,, {|| lCheck := !lCheck } ,,,,,,.T.,,, )	//CheckBox para não processar novamente a tabela temporária

oSay4 := TSay():New(145, 40, {|| GetStepText("STEP2", "CHECKPAS1")  }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

Return

/*
{Protheus.doc} TafWizSp3
Passo 3 da rotina de geração de XMLs TAF.
@type  Static Function
@author Diego Santos
@since 04-10-2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TafWizSp3(oPanel, cUrlRest, cUser, cPsw)

Local oSay1
Local oSay2
Local oSay3
Local oSay4

Local oGetRestServer
Local oGetRestUser
Local oGetRestPsw

oSay1 := TSay():New(18, 20, {|| GetStepText("STEP3", "PASSO2")      }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

oSay2 := TSay():New(35, 30, {|| GetStepText("STEP3", "INFOPAS2-1")  }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

oSay3 := TSay():New(65, 30, {|| GetStepText("STEP3", "INFOPAS2-2")  }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

oSay4 := TSay():New(95, 30, {|| GetStepText("STEP3", "INFOPAS2-3")  }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

oGetRestUser    := TGet():New(125, 30, {|u|If( PCount()==0, cUser , cUser := u    )}, oPanel, 160, 009, ,,,,,,,.T.,,,,,,,.F.,.F.,,,,,,.T.,,,"Usuário Smart E-Social:" ,1,,CLR_BLUE)

oGetRestPsw     := TGet():New(145, 30, {|u|If( PCount()==0, cPsw  , cPsw := u     )}, oPanel, 160, 009, "@K",,,,,,,.T.,,,,,,,.F.,.T.,,,,,,.T.,,,"Senha Smart E-Social:"   ,1,,CLR_BLUE)

oGetRestServer  := TGet():New(165, 30, {|u|If( PCount()==0, cUrlRest, cUrlRest := u )}, oPanel, 160, 009, "",,,,,,,.T.,,,,,,,.F.,.F.,,,,,,.T.,,,"Url do Servidor REST TAF:",1,,CLR_BLUE)


Return

/*
{Protheus.doc} TafWizSp4
Passo 3 da rotina de geração de XMLs TAF.
@type  Static Function
@author Diego Santos
@since 04-10-2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TafWizSp4(oPanel)

Local oSay1
Local oSay2
Local oSay3

oSay1 := TSay():New(25, 20, {|| GetStepText("STEP4", "PASSO3")      }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

oSay2 := TSay():New(65, 30, {|| GetStepText("STEP4", "INFOPAS3-1")  }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

oSay3 := TSay():New(95, 30, {|| GetStepText("STEP4", "INFOPAS3-2")  }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

Return

/*
{Protheus.doc} TafWizSp5
Passo 3 da rotina de geração de XMLs TAF.
@type  Static Function
@author Diego Santos
@since 04-10-2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TafWizSp5(oPanel)

Local oSay1
Local oSay2

oSay1 := TSay():New(25, 20, {|| GetStepText("STEP5", "PASSO4")      }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)
oSay2 := TSay():New(65, 30, {|| GetStepText("STEP5", "INFOPAS4-1")  }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

Return

/*
{Protheus.doc} GetStepText
Retorna o Texto presentes no passo a passo 
do Wizard de Migração TAF
@type  Static Function
@author Diego Santos
@since 04-10-2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function GetStepText(cStep, cInfo)

Local cRet := ""

If cStep == "STEP1"

    If cInfo == "BEMVINDO"
        cRet := '<font size="6" color="#0c9abe"><b> Bem vindo...</b></font>'
        cRet += '<br/>'
    EndIf

    If cInfo == "ASSIST"
        cRet += '<font size="5" color="#888"><b>Este é o assistente de migração dos XMLs transmitidos pelo TAF.</b></font>'
        cRet += '<br/>'
    EndIf
    
    If cInfo == "TITETAPAS"
        cRet += '<font size="5" color="#888">Esta rotina consiste de 3 etapas: </font>'
        cRet += '<br/>'
    EndIf

    If cInfo == "TEXTETAPAS"
        cRet += '<font size="4" color="#888"> - Importação dos XMLs transmitidos pelo TAF aceitos pelo RET para a tabela de migração.</font><br/><br/>'
        cRet += '<font size="4" color="#888"> - Envio das informações para a nova instalação TAF.</font><br/><br/>'
        cRet += '<font size="4" color="#888"> - Geração de Relatório com as inconsistências encontradas no processo.</font>'
    EndIf    

ElseIf cStep == "STEP2"

    If cInfo == "PASSO1"
        cRet := '<font size="6" color="#0c9abe"><b> 1º Passo - </b> Geração da tabela de migração.</font>'
        cRet += '<br/>'
    EndIf

    If cInfo == "INFOPAS1-1"
        cRet := '<font size="4" color="#888">'
        cRet += ' - Este processo visa identificar todos os registros aceitos pelo RET <br/>'
        cRet += ' que encontram-se na base de dados do TAF.'
        cRet += '</font><br/>'
    EndIf

    If cInfo == "INFOPAS1-2"
        cRet := '<font size="4" color="#888">'
        cRet += ' - Ao clicar em <b>Avançar</b>, o sistema irá realizar o processo descrito acima<br/>'
        cRet += '  e irá gerar as informações consolidadas a serem enviadas a nova base TAF.<br/>'
        cRet += '</font><br/>'
    EndIf

    If cInfo == "CHECKPAS1"
        cRet := '<font size="3" color="#888"><b>'
        cRet += ' Habilitando esta opção este passo será ignorado <br> '         
        cRet += ' e seguirá para o passo de integração com a nova base TAF. </b>'
        cRet += '</font><br/>'
    EndIf

ElseIf cStep == "STEP3"

    If cInfo == "PASSO2"
        cRet := '<font size="6" color="#0c9abe"><b> 2º Passo - </b> Integração com API da nova instalação TAF.</font>'
        cRet += '<br/>'    
    EndIf

    If cInfo == "INFOPAS2-1"
        cRet := '<font size="4" color="#888">'
        cRet += ' - Agora iremos enviar todas as informações presentes na tabela <br/>'
        cRet += ' temporária para a nova instalação do TAF.'
        cRet += '</font><br/>'
    EndIf

    If cInfo == "INFOPAS2-2"
        cRet := '<font size="4" color="#888">'
        cRet += ' - Ao clicar em <b>Avançar</b>, o sistema irá realizar o processo descrito acima<br/>'
        cRet += '  e consumir a API para o envio das informações.<br/>'
        cRet += '</font><br/>'    
    EndIf

    If cInfo == "INFOPAS2-3"
        cRet := '<font size="4" color="#888">'
        cRet += '<b>Por favor, informe a URL do Servidor REST, Usuário e Senha <br/>'
        cRet += 'da nova instalação do TAF para realizar a migração das informações.</b><br/>'
        cRet += '</font><br/>'    
    EndIf
ElseIf cStep == "STEP4"
    
    If cInfo == "PASSO3"
        cRet := '<font size="6" color="#0c9abe"><b> 3º Passo - </b> Relatório de inconsistências de Migração TAF.</font>'
        cRet += '<br/>'    
    EndIf

    If cInfo == "INFOPAS3-1"
        cRet := '<font size="4" color="#888">'
        cRet += " Neste passo, iremos gerar um relatório do procedimento executado. <br/> "
        cRet += " Ele irá informar, as inconsistências que "
        cRet += " ocorreram durante o processo de migração. "
        cRet += '</font><br/>'
    EndIf

ElseIf cStep == "STEP5"

    If cInfo == "PASSO4"
        cRet := '<font size="6" color="#0c9abe"><b> Conclusão - </b> Processamento finalizado.</font>'
        cRet += '<br/>'    
    EndIf

    If cInfo == "INFOPAS4-1"
        cRet := '<font size="4" color="#888">'
        cRet += ' Você executou com sucesso o processo de migração do TAF. <br/>'
        cRet += ' Clique em Concluir para finalizar o processo.'
        cRet += '</font><br/>'
    EndIf

EndIf

Return cRet
 
/*{Protheus.doc} TafGeraV2I
Rotina responsável por realizar a comunicação
@type  Function
@author user
@since date
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TafGeraV2I(oPanel, lCheck)
Local lRet          := .T.
Local nY            := 0
Local nX            := 0
Local aArea         := {}
Local aEventosESoc  := TAFRotinas( ,, .T., 2 ) 
Local cCodEmp       := ""
Local cCodGrp       := ""
Local cCodFilial    := ""
Local cFilCompart   := ""  

cCodEmp := FWCompany()
cCodGrp := FWGrpCompany()
aArea := GetArea()

If !lCheck
    
    aSM0 := FwLoadSM0()
    nX := 0

    For nX := 1 To Len(aSM0)

        If (aSM0[nX][SM0_EMPRESA] == cCodEmp) .And. (aSM0[nX][SM0_GRPEMP] == cCodGrp)

            For nY := 1 To Len(aEventosESoc)

                If FWModeAccess(aEventosESoc[nY][3],3,aSM0[nX][SM0_GRPEMP]) == "C" 

                    //Quando a tabela é compartilhada só devo gerar ela na primeira interação do laço de filial.
                    If cFilCompart != aSM0[nX][SM0_FILIAL] .And. !Empty(cFilCompart)
                        Loop
                    ElseIf Empty(cFilCompart)
                        cFilCompart := aSM0[nX][SM0_FILIAL]
                    EndIf 
                EndIf

                cCodFilial := aSM0[nX][SM0_CODFIL]
                dbSelectArea(aEventosESoc[nY][3])
                If ( FieldPos(aEventosESoc[nY][3] + "_STATUS" ) > 0 )
                    FWMsgRun(, { |oPanel| TafMigSearchXML( aEventosESoc[nY][3], aEventosESoc[nY][4], aEventosESoc[nY][9],aEventosESoc[nY][8],aEventosESoc[nY][12],cCodFilial) } , "Aguarde...", "Gerando tabela temporária... " + "Filial : " + cCodFilial + " - Evento : " + aEventosESoc[nY][4] )
                EndIf
                (aEventosESoc[nY][3])->( dbCloseArea() )

            Next nY
        EndIf 
    Next nX
EndIf

RestArea(aArea)


Return lRet

/*/
{Protheus.doc} TafMigSearchXML
Rotina que irá realizar por evento a query dos eventos 
enviados ao TAF para integração com a API de migração TAF.

@param cTipoEvt - Tipo de Evento eSocial
@param cCodFilial - Codigo da Filial para a geracao dos arquivos

@type  Static Function
@author Diego Santos
@since 15-10-2018
@version 1.0
@return return, return_type, return_description
/*/
Static Function TafMigSearchXML( cTableTAF, cEvtoESoc, cEvtTagRET,cFunXML,cTipoEvt,cCodFilial)

Local cQryTAF       := ""
Local cProtul       := ""
Local cAlsTAF       := GetNextAlias()

Local aInfoGrv      := {}
Local aXmls         := {}
Local aXmlsRetorno  := {}
Local aXmlsLote     := {}

Local nTamLote      := 50
Local nContLote     := 0
Local nX            := 0
Local nItem         := 0
Local nStart        := 0

Local cEvt          := StrTran(cEvtoESoc,"-","")
Local oHashMap      := tHashMap():New()

Local lInfoRPT      := .F.
Local cXmlId        := ""
Local cReciboEvt    := ""
Local cDataTrans    := ""
Local cIndRet       := "" 
Local cXmlERP       := ""
Local cXmlTot       := ""
Local cRec3000      := ""
Local lObrRecibo    := .T.


lObrRecibo := SuperGetMv("MV_TAFMGRC",.F.,.T.)
//Ajusta para Filial do evento
//cFilBkp := cFilAnt
//If !Empty((cAliasRegs)->FILIAL)
 //   cFilAnt :=  (cAliasRegs)->FILIAL //&(AllTrim((cAliasRegs)->ALIASEVT)+"->"+AllTrim((cAliasRegs)->ALIASEVT)+"_FILIAL")
//EndIf

cQryTAF := "SELECT " 
cQryTAF += cTableTAF+"."+cTableTAF+"_FILIAL, "
cQryTAF += cTableTAF+"."+cTableTAF+"_ID, "
cQryTAF += cTableTAF+"."+cTableTAF+"_VERSAO, "
cQryTAF += cTableTAF+"."+cTableTAF+"_PROTUL, "
cQryTAF += cTableTAF+"."+cTableTAF+"_EVENTO, "

If TAFColumnPos(cTableTAF+"_XMLID")
    cQryTAF += cTableTAF+"."+cTableTAF+"_XMLID CXMLID , "
Else
    cQryTAF += " ' ' CXMLID, "
EndIf 

If TAFColumnPos(cTableTAF+"_DINSIS")
    cQryTAF += cTableTAF+"."+cTableTAF+"_DINSIS DTSIST, "
Else
    cQryTAF += " ' ' DTSIST, "
EndIf 

cQryTAF += cTableTAF+"."+ "R_E_C_N_O_ RECNO " 
cQryTAF += " FROM " + RetSqlName(cTableTAF) + " " + cTableTAF
cQryTAF += " WHERE "
cQryTAF += cTableTAF + "." + cTableTAF + "_FILIAL = '" + xFilial(cTableTaf,cCodFilial) +  "'  AND "

If lObrRecibo
    cQryTAF += cTableTAF + "." + cTableTAF + "_PROTUL <> ' '  AND "
EndIf 
cQryTAF += cTableTAF + "." + cTableTAF + "_STATUS  = '4' AND "
If cEvt $ "S2200|S2300|S1200|S1202" 
    cQryTAF += cTableTAF + "." + cTableTAF + "_NOMEVE  = '"+cEvt+"'  AND "
EndIf
cQryTAF += cTableTAF + ".D_E_L_E_T_ = ' ' "
cQryTAF += "ORDER BY "
cQryTAF += cTableTAF + "." + cTableTAF + "_FILIAL, "
cQryTAF += cTableTAF + "." + cTableTAF + "_ID, "
cQryTAF += cTableTAF + "." + cTableTAF + "_VERSAO "

//TCQuery cQryTAF New Alias (cAlsTAF)
If !TAFSqlExec(cQryTAF, cAlsTAF)
    Return
Endif

If !Empty(cEvt) .And. AllTrim(cEvt) != "TAUTO"

    While (cAlsTAF)->(!Eof())

        If !Empty( cEvt + AllTrim( (cAlsTAF)->&(cTableTAF+"_ID") ) + AllTrim( (cAlsTAF)->&(cTableTAF+"_VERSAO") ) )
            nContLote++
            cTSSKey := cEvt + AllTrim( (cAlsTAF)->&(cTableTAF+"_ID") ) + AllTrim( (cAlsTAF)->&(cTableTAF+"_VERSAO") )
            aAdd( aXmls, cTSSKey )

            If nContLote == nTamLote
                aAdd(aXmlsLote,aClone(aXmls))
                aSize(aXmls,0)
                aXmls     := {}
                nContLote := 0
            EndIf 

            aAdd( aInfoGrv, (cAlsTAF)->&(cTableTAF+"_FILIAL")  )
            aAdd( aInfoGrv, AllTrim( (cAlsTAF)->&(cTableTAF+"_ID") ) )
            aAdd( aInfoGrv, AllTrim( (cAlsTAF)->&(cTableTAF+"_VERSAO") ) )
            aAdd( aInfoGrv, AllTrim( (cAlsTAF)->&(cTableTAF+"_PROTUL") ) )
            aAdd( aInfoGrv, AllTrim( (cAlsTAF)->&("CXMLID") ) )
            aAdd( aInfoGrv, AllTrim( (cAlsTAF)->&("DTSIST") ) )
            aAdd( aInfoGrv, (cAlsTAF)->&("RECNO"))
            aAdd( aInfoGrv, AllTrim( (cAlsTAF)->&(cTableTAF+"_EVENTO") ) )

            If !oHashMap:Get( cTSSKey )
                oHashMap:Set( cTSSKey, aInfoGrv )
                aInfoGrv := {}
            EndIf

        EndIf

        (cAlsTAF)->(DbSkip())
    EndDo

    If Len(aXmls) > 0
        aAdd(aXmlsLote,aClone(aXmls))
        aSize(aXmls,0)
        aXmls := {}
    EndIf     

    For nX := 1 To Len(aXmlsLote)

        aXmlsRetorno := TAFGETXMLTSS(aXmlsLote[nX])

        If Len(aXmlsRetorno) > 0

            For nItem := 1 To Len(aXmlsRetorno)
            
                cProtul := ""

                If oHashMap:Get( aXmlsRetorno[nItem][2], aInfoGrv ) 
                
                    If aXmlsRetorno[nItem][1]

                        aXmlsRetorno[nItem][3] := StrTran(aXmlsRetorno[nItem][3], '<?xml version="1.0" encoding="UTF-8"?>', '' ) // UTF Upper
                        aXmlsRetorno[nItem][3] := StrTran(aXmlsRetorno[nItem][3], '<?xml version="1.0" encoding="utf-8"?>', '' ) // UTF Lower

                        cProtul := GetRetTag( aXmlsRetorno[nItem][4] , "PROTUL" )
                        lInfoRPT := AllTrim(cEvt) $ "S1200|S2299|S2399"
                        cXmlId :=  GetRetTag( aXmlsRetorno[nItem][3] , "XMLID"  , cEvtTagRET  )
                        cReciboEvt := Iif( !Empty(cProtul), cProtul, aInfoGrv[4] )
                        cDataTrans := GetRetTag( aXmlsRetorno[nItem][4] , "DTRANS" )
                        cIndRet :=  GetRetTag( aXmlsRetorno[nItem][3] , "INDRETIF", cEvtTagRET, cEvtoESoc  )
                        cXmlERP :=  aXmlsRetorno[nItem][3]
                        cXmlTot :=  GetRetTag( aXmlsRetorno[nItem][4] , "XMLTOT"     , cEvtTagRET  )
                        If cEvtoESoc == "S-3000"
                            cRec3000 := GetRetTag( aXmlsRetorno[nItem][3] , "RECS3000" )
                        Else
                            cRec3000 := ""
                        EndIf 

                    Else
                        //Quando o registro nao for encontrado no TSS, pego os dados no TAF
                        (cTableTAF)->(dbGoTo(aInfoGrv[7]))
                        
                        lInfoRPT := AllTrim(cEvt) $ "S1200|S2299|S2399"
                        cXmlId := aInfoGrv[5]
                        cReciboEvt := aInfoGrv[4]

                        //Tento pegar a data sistemica, se nao achar pego a data no campo versao.
                        If Empty(aInfoGrv[6])
                            If Empty(aInfoGrv[3])
                                cDataTrans := ""
                            Else
                                cDataTrans := "20"+Substr(aInfoGrv[3],5,2)+"-"+Substr(aInfoGrv[3],3,2)+"-"+Substr(aInfoGrv[3],1,2)+"T00:00:00.00"
                            EndIf 
                        Else
                            cDataTrans := Substr(aInfoGrv[6],1,4)+"-"+Substr(aInfoGrv[6],5,2)+"-"+Substr(aInfoGrv[6],7,2)+"T00:00:00.00" 
                        EndIf 

                        cXmlERP := &cFunXML.(cTableTAF,aInfoGrv[7],, .T.,, "",lInfoRPT)
                        nStart := AT(">",cXmlERP)
                        cXmlERP := "<eSocial>" + Substr(cXmlERP,nStart +1)
                        cXmlTot := ""

                        If cTipoEvt != 'C'
                            If aInfoGrv[8] == "I" .Or. aInfoGrv[8] == "E"
                                cIndRet := "1"
                            ElseIf aInfoGrv[8] == "A" .Or. aInfoGrv[8] == "R"
                                cIndRet := "2"
                            Else 
                                cIndRet := ""
                            EndIf
                        EndIf 

                        If cEvtoESoc == "S-3000" .Or. Empty(cIndRet) .Or. Empty(cXmlId)
                            getValXmlTAF(cXmlERP,cEvtTagRET,cEvtoESoc,@cIndRet,@cRec3000,@cXmlId)
                        Else
                            cRec3000 := ""
                            cIndRet  := ""
                        EndIf 
                    EndIf 
                    
                    //Begin Transaction

                    V2I->(DbSetOrder(1))
                    If V2I->(DbSeek( xFilial("V2I") + aInfoGrv[1] + cEvtoESoc + PadR(aInfoGrv[2], 36) + aInfoGrv[3] ) )
                        If V2I->V2I_STATUS == "1"
                            RecLock("V2I", .F.)
                                V2I->V2I_FILIAL := xFilial("V2I")
                                V2I->V2I_FILREG := aInfoGrv[1]
                                V2I->V2I_EVENTO := cEvtoESoc
                                V2I->V2I_ID     := aInfoGrv[2]
                                V2I->V2I_VERSAO := aInfoGrv[3]
                                V2I->V2I_STATUS := "1"
                                V2I->V2I_TIPO   := "1"
                                V2I->V2I_XMLERP := cXmlERP
                                V2I->V2I_XMLID  := cXmlId
                                V2I->V2I_PROTUL := cReciboEvt
                                V2I->V2I_DTRANS := cDataTrans
                                V2I->V2I_INDRET := cIndRet
                                If V2I->V2I_EVENTO $ "S-1200|S-1210|S-1295|S-1299|S-2299" 
                                    V2I->V2I_XMLTOT := cXmlTot
                                EndIf
                                V2I->V2I_CODERR := ""
                                V2I->V2I_OBS    := ""
                                V2I->V2I_TABTAF := cTableTAF
                                V2I->V2I_RECEXC := cRec3000 //Recibo de exclusão enviado para o S-3000

                            MsUnlock()
                            TAFConOut("Registro atualizado " + aInfoGrv[1] + cEvt + aInfoGrv[2] + aInfoGrv[3])

                        ElseIf !Empty(V2I->V2I_CODERR) .And. V2I->V2I_STATUS <> '1'
                            RecLock("V2I", .F.)
                                V2I->V2I_FILIAL := xFilial("V2I")
                                V2I->V2I_FILREG := aInfoGrv[1]
                                V2I->V2I_EVENTO := cEvtoESoc
                                V2I->V2I_ID     := aInfoGrv[2]
                                V2I->V2I_VERSAO := aInfoGrv[3]
                                V2I->V2I_STATUS := "1"
                                V2I->V2I_TIPO   := "1"
                                V2I->V2I_XMLERP := cXmlERP
                                V2I->V2I_XMLID  := cXmlId
                                V2I->V2I_PROTUL := cReciboEvt
                                V2I->V2I_DTRANS := cDataTrans
                                V2I->V2I_INDRET := cIndRet
                                If V2I->V2I_EVENTO $ "S-1200|S-1210|S-1295|S-1299|S-2299" 
                                    V2I->V2I_XMLTOT := cXmlTot
                                EndIf
                                V2I->V2I_CODERR := ""
                                V2I->V2I_OBS    := ""
                                V2I->V2I_TABTAF := cTableTAF
                                V2I->V2I_RECEXC := cRec3000 //Recibo de exclusão enviado para o S-3000
                            
                            MsUnlock()
                            TAFConOut("Registro com o erro, atualizado para nova tentativa de migração.")
                        EndIf
                    Else
                        RecLock("V2I", .T.)
                            V2I->V2I_FILIAL := xFilial("V2I")
                            V2I->V2I_FILREG := aInfoGrv[1]
                            V2I->V2I_EVENTO := cEvtoESoc
                            V2I->V2I_ID     := aInfoGrv[2]
                            V2I->V2I_VERSAO := aInfoGrv[3]
                            V2I->V2I_STATUS := "1"
                            V2I->V2I_TIPO   := "1"      //E-Social
                            V2I->V2I_XMLERP := cXmlERP
                            V2I->V2I_XMLID  := cXmlId
                            V2I->V2I_PROTUL := cReciboEvt
                            V2I->V2I_DTRANS := cDataTrans
                            V2I->V2I_INDRET := cIndRet
                            If V2I->V2I_EVENTO $ "S-1200|S-1210|S-1295|S-1299|S-2299"
                                V2I->V2I_XMLTOT := cXmlTot
                            EndIf
                            V2I->V2I_CODERR := ""
                            V2I->V2I_OBS    := ""
                            V2I->V2I_TABTAF := cTableTAF
                            V2I->V2I_RECEXC := cRec3000 //Recibo de exclusão enviado para o S-3000
                        MsUnlock()

                        TAFConOut("Registro incluido " + aInfoGrv[1] + cEvt + aInfoGrv[2] + aInfoGrv[3])
                    EndIf
                    //End Transaction           
                EndIf
            Next nItem
            
        EndIf

        aSize(aXmlsRetorno, 0)
	    aXmlsRetorno := Nil

    Next nX

    aSize(aXmlsLote, 0)
	aXmlsLote := Nil

EndIf

oHashMap:Clean()
FreeObj(oHashMap)

(cAlsTAF)->(DbCloseArea())

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} getValXmlTAF
Retorna informações do XML gerado pelo TAF

@Param  cXmlERP		- XML do TAF
		cEvtTagRET  - Taf de identificação do evento E-Social
		cEvtoESoc   - Nome do Evento E-Social
        cIndRet     - retorno da tag indRetif (referencia)
        cRec3000    - retorno da tag nrRecEvt - Evento S-3000 (referencia)
        cXmlId      - retorno do atributo Id (referencia)
    
@Return Nil

@Author Evandro dos Santos Oliveira
@Since 14/08/2020
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function getValXmlTAF(cXmlERP,cEvtTagRET,cEvtoESoc,cIndRet,cRec3000,cXmlId)

    Local oXML := Nil 

    Default cIndRet := ""
    Default cRec3000 := ""
    Default cXmlId := ""

    oXML := tXmlManager():New()
    oXml:Parse(cXmlERP)
    oXml:bDecodeUtf8 = .T.
    
    If Empty(cXmlId)
        cXmlId := oXml:xPathGetAtt( "/" + oXML:cPath + "/"+cEvtTagRET, "Id" )
    EndIf 	

    If cEvtoESoc == "S-3000"
        cRec3000 := oXML:XPathGetNodeValue("/eSocial/evtExclusao/infoExclusao/nrRecEvt")
        cIndRet  := "" //s-3000 nao tem indRetif
    Else 

        If Empty(cIndRet)
            cIndRet :=  oXML:XPathGetNodeValue("/eSocial/" + cEvtTagRET + "/ideEvento/indRetif")
        EndIf 
        cRec3000 := ""
    EndIf 

    oXml := Nil
    FreeObj( oXml )

Return Nil 

/*/
{Protheus.doc} TafGetXMLTSS
Rotina que irá realizar a consulta dos eventos no TSS.
Para retorno do recibo e do XML de envio 
@type  Static Function
@author Diego Santos
@since 15-10-2018
@version 1.0
@return return, return_type, return_description
/*/

Function TAFGETXMLTSS(aLoteXML)

Local cUrl              := ""
Local nX                := 0
Local nItemLote         := 0 
Local oSocialRetorno    := Nil
Local oSocial           := Nil
Local cMsgErro          := ""
Local aXmlsRetorno      := {}
Local cAmbiente         := SuperGetMv('MV_TAFAMBE',.F.,"2")

cUrl := getUrlTSS()

If Empty(cIdEntidade)
    getIdEntidade(cUrl,@cIdEntidade,@cMsgErro)
EndIf

If !Empty(cIdEntidade)

    oSocial 	   						:= WSTSSWSSOCIAL():New()
    oSocial:_Url 						:= cUrl 
    oSocial:oWSENTEXPDADOS:cUSERTOKEN 	:= "TOTVS"
    oSocial:oWSENTEXPDADOS:cID_ENT    	:= cIdEntidade
    oSocial:oWSENTEXPDADOS:cAMBIENTE   	:= cAmbiente    

    oSocial:oWSENTEXPDADOS:oWSENTEXPDOCS := WsClassNew("TSSWSSOCIAL_ARRAYOFENTEXPDOC")  
    oSocial:oWSENTEXPDADOS:oWSENTEXPDOCS:OWSENTEXPDOC := {}
    

    For nItemLote := 1 To Len(aLoteXML)
        aAdd(oSocial:oWSENTEXPDADOS:oWSENTEXPDOCS:OWSENTEXPDOC,WsClassNew("TSSWSSOCIAL_ENTEXPDOC"))
        ATAIL(oSocial:oWSENTEXPDADOS:oWSENTEXPDOCS:OWSENTEXPDOC):CID := aLoteXML[nItemLote] //'S220000003718061884265372'
    Next nItemLote

    oSocial:ExportarDocumentos()

    If ValType(oSocial:oWSEXPORTARDOCUMENTOSRESULT:oWSSAIDAEXPDOCS) <> "U"

        oSocialRetorno := oSocial:oWSEXPORTARDOCUMENTOSRESULT:oWSSAIDAEXPDOCS:oWSSAIDAEXPDOC

        For nX := 1 To Len(oSocialRetorno)
            aAdd(aXmlsRetorno,{oSocialRetorno[nX]:lSucesso,AllTrim(oSocialRetorno[nX]:cID),oSocialRetorno[nX]:cXMLERP, oSocialRetorno[nX]:cXMLRET})
        Next nX
    
    Else
        cMsgErro := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
        MsgStop(cMsgErro,"SoapFault")
    EndIf

    FreeObj(oSocialRetorno)
    FreeObj(oSocial)
    oSocialRetorno  := Nil 
    oSocial         := Nil 
    DelClassIntF()

Else    
    MsgStop(cMsgErro)
EndIf 

Return aXmlsRetorno

/*/
{Protheus.doc} getUrlTSS
Rotina para retornar a URL do TSS
@type  Static Function
@author Diego Santos
@since 15-10-2018
@version 1.0
@return return, return_type, return_description
/*/

Static Function getUrlTSS()

Local cUrl := ""

If FindFunction("TafGetUrlTSS")
    cUrl := AllTrim((TafGetUrlTSS()))
Else
    cUrl := AllTrim(GetNewPar("MV_TAFSURL","http://"))
EndIf 

If !("TSSWSSOCIAL.APW" $ Upper(cUrl)) 
    cUrl += "/TSSWSSOCIAL.apw"
EndIf	

Return cUrl

/*/
{Protheus.doc} getUrlTSS
Rotina para retornar a URL do TSS.
@type  Static Function
@author Diego Santos
@since 15-10-2018
@version 1.0
@return return, return_type, return_description
/*/

Static Function getIdEntidade(cUrl,cIdEntidade,cMsgErro)

    Local lTransFil := .F.
    Local cCheckURL := ""
    Local lRet := .T. 


    If FindFunction("TAFTransFil")
        lTransFil := TAFTransFil(.T.)
    EndIf

    If !("TSSWSSOCIAL.APW" $ Upper(cUrl))
        cCheckURL := cUrl
    Else
        cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
    EndIf

    If TAFCTSpd(cCheckURL,,,@cMsgErro)
        cIdEntidade := TAFRIdEnt(lTransFil)
    Else
        lRet := .F.

        TafConOut("Não foi possivel conectar com o servidor TSS")
        TafConOut(cMsgErro)

    EndIf
    
Return lRet

/*/
{Protheus.doc} GetRetTag
Rotina que irá realizar o parse do XML retornado 
pelo TSS para capturar apenas o recibo do RET
@type  Static Function
@author Diego Santos
@since 15-10-2018
@version 1.0
@return return, return_type, return_description
/*/

Static Function GetRetTag( cXML, cCodTag, cEvtTagRET, cEvtoESoc )

Local oXML          := tXMLManager():New()
Local cRetTag       := ""

Local cXMLTratado   := ""
Local nPosNS
Local nPosNSEnd
Local cNameSpace    := ""

If oXml:Parse(EncodeUTF8(cXML)) // Faz o parser para garantir que é um arquivo XML válido

    If cCodTag == "INDRETIF"

        // Utilizada para registrar o path do XML
        cXMLTratado	:= StrTran(cXML, '<?xml version="1.0" encoding="UTF-8"?>', '' ) // UTF Upper
        cXMLTratado	:= StrTran(cXMLTratado, '<?xml version="1.0" encoding="utf-8"?>', '' ) // UTF Lower
        cXMLTratado := StrTran( cXMLTratado, "'", '"' )

        nPosNS		:= At( "xmlns", cXMLTratado ) + 7
        nPosNSEnd	:= At(">", cXMLTratado) - nPosNS - 1
        cNameSpace 	:= SubStr( cXMLTratado, nPosNS, nPosNSEnd  )

        oXml:XPathRegisterNS( "ns1", cNameSpace )

    EndIf

    cRetTag := Migr01RetTag(oXML, cCodTag, cEvtTagRET, cEvtoESoc, cXMLTratado)
EndIf

// Limpa da memória as classes de interfaces criadas por tXMLManager
FreeObj(oXml)
oXml := Nil

DelClassIntF()

Return cRetTag


//-------------------------------------------------------------------
/*/{Protheus.doc} Migr01RetTag
Retorna o recibo do arquivo xml
@author  Victor A. Barbosa
@since   03/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Migr01RetTag(oXML, cCodTag, cEvtTagRET, cEvtoESoc, cXML )

Local cCodRet		:= ""
Local cRet          := ""

If cCodTag == "INDRETIF"

    //cNameSpace := 
    // Verifica o tipo de envio ao governo
    If oXml:XPathHasNode("/ns1:eSocial/ns1:" + cEvtTagRET + "/ns1:ideEvento/ns1:indRetif")
        cRet := oXml:XPathGetNodeValue("/ns1:eSocial/ns1:" + cEvtTagRET + "/ns1:ideEvento/ns1:indRetif")
    EndIf

    // Se está vazio é sinal que é evento de tabela ou totalizador que será analisado abaixo
    If Empty( cRet )
        If At( "<inclusao>", cXML ) > 0
            cRet := "3"
        ElseIf At( "<alteracao>", cXML ) > 0
            //oVOMigr:SetTypeEvent("4")
            cRet := "4"
        ElseIf At( "<exclusao>", cXML ) > 0
            //oVOMigr:SetTypeEvent("5")
            cRet := "5"
        EndIf
    EndIf

    // Verifica se é evento totalizador ou evento de exclusão
    If Empty( cRet ) .And. cEvtoESoc $ "S-1295|S-1299|S-1298|S-3000"
        cRet := "1"
    EndIf

ElseIf  cCodTag == "XMLTOT"

    If oXML:XPathDelNode( "/evento/retornoEvento" )
        cRet := oXML:Save2String()
    EndIf

    cRet := StrTran(cRet, '<?xml version="1.0" encoding="UTF-8"?>', '' ) // UTF Upper
    cRet := StrTran(cRet, '<?xml version="1.0" encoding="utf-8"?>', '' ) // UTF Lower

ElseIf cCodTag == "XMLID"

    oXML:DOMChildNode()
    If oXML:cName == cEvtTagRET
       cRet := oXML:DOMGetAtt( "Id" )
    EndIf

ElseIf  cCodTag == "RECS3000"
    oXml:XPathRegisterNS( "ns1", "http://www.esocial.gov.br/schema/evt/evtExclusao/v02_04_02" )
    If oXml:XPathHasNode("/ns1:eSocial/ns1:evtExclusao/ns1:infoExclusao")
        cRet := oXml:XPathGetNodeValue("/ns1:eSocial/ns1:evtExclusao/ns1:infoExclusao/ns1:nrRecEvt")
    EndIf
Else

    // Tratamento para caso o ERP disponibiliza o XML completo de retorno ou somente a partir do grupo <retornoEvento>
    If oXml:XPathHasNode("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:retornoEventos")
        
        oXml:XPathRegisterNS( "ns1", "http://www.esocial.gov.br/schema/lote/eventos/envio/retornoProcessamento/v1_3_0" )
        oXml:XPathRegisterNS( "ns2", "http://www.esocial.gov.br/schema/evt/retornoEvento/v1_2_0" )

        If oXml:XPathHasNode("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:status")
            cCodRet := oXml:XPathGetNodeValue("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:status/ns1:cdResposta")
        EndIf

        If cCodRet $ "201|202"
            If oXml:XPathHasNode("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:retornoEventos")
                If oXml:XPathGetNodeValue("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:retornoEventos/ns1:evento/ns1:retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:recepcao/ns2:tpAmb") == GetNewPar("MV_TAFAMBE")
                    If oXml:XPathHasNode("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:retornoEventos/ns1:evento/ns1:retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:recibo")                    
                        If cCodTag == "PROTUL"
                            cRet := oXml:XPathGetNodeValue("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:retornoEventos/ns1:evento/ns1:retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:recibo/ns2:nrRecibo")
                        ElseIf cCodTag == "DTRANS"
                            cRet := oXml:XPathGetNodeValue("/ns1:eSocial/ns1:retornoProcessamentoLoteEventos/ns1:retornoEventos/ns1:evento/ns1:retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:dhProcessamento")
                        EndIf
                    EndIf
                Else
                    TAFConOut("Ambiente do XML diverge do ambiente do TAF (tpAmb). Consulta Processamento Consulta Governo" )
                EndIf
            EndIf
        EndIf

    ElseIf oXml:XPathHasNode("/evento/retornoEvento")
        
        oXml:XPathRegisterNS( "ns2", "http://www.esocial.gov.br/schema/evt/retornoEvento/v1_2_0" )

        If oXml:XPathHasNode("/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:cdResposta")
            cCodRet := oXml:XPathGetNodeValue("/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:cdResposta")
        EndIf

        If cCodRet $ "201|202"
            If oXml:XPathGetNodeValue("/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:recepcao/ns2:tpAmb") == GetNewPar("MV_TAFAMBE")
                If oXml:XPathHasNode("/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:recibo")
                    If cCodTag == "PROTUL"
                        cRet := oXml:XPathGetNodeValue("/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:recibo/ns2:nrRecibo")
                    ElseIf cCodTag == "DTRANS"
                        cRet := oXml:XPathGetNodeValue("/evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:dhProcessamento")
                    EndIf
                EndIf
            Else
                TAFConOut( "Ambiente do XML diverge do ambiente do TAF (tpAmb). Consulta Processamento Consulta Governo" )
            EndIf
        EndIf

    EndIf

EndIf

Return cRet

/*/{Protheus.doc} TafRestMig
Rotina responsável por consumir a API do Novo Serviço TAF.
@type  Function
@author Diego Santos
@since 19-10-2018
@version 1.0
/*/
Function TafRestMig(oPanel, cUrlRest, cUser, cPsw, lRestMig,lProcErr)

Local lRet          := .T.
Local lRetRest		:= .F.

Local cQryTAF       := ""
Local cAlsTAF       := GetNextAlias()

Local nTamLote      := 100
Local nContLote     := 0
Local cCnpj         := ""
Local aArea         := GetArea()

Local aRecnos       := {}
Local cBody         := ""

Local aJsonObj      := {}
Local oRestClient   := Nil

Default lProcErr    := .F. 

if !("/rest" $ cUrlRest)
    cUrlRest += "/rest"
EndIf

oRestClient := FWRest():New( AllTrim(cUrlRest) )

lRetRest := StaticCall(TAFLoad,ValidRest,cUrlRest)

If lRetRest

    oRestClient:SetPath("/wstafmigratory")

    cQryTAF := "SELECT * "
    cQryTAF += "FROM " + RetSqlName("V2I") + " V2I "
    cQryTAF += "WHERE "
    cQryTAF += "V2I.V2I_FILIAL = '" + xFilial("V2I") + "' "

    If lProcErr 
        cQryTAF += "AND ((V2I.V2I_STATUS = '2' "
        cQryTAF += "OR V2I.V2I_STATUS = '3') "
        cQryTAF += "AND V2I.V2I_CODERR != ' ') "
    Else 
        cQryTAF += "AND V2I.V2I_STATUS = '1' "
    EndIf 

    cQryTAF += "AND V2I.D_E_L_E_T_ = ' ' "
    cQryTAF += "ORDER BY V2I.V2I_FILIAL, V2I.V2I_FILREG, V2I.V2I_EVENTO, V2I.V2I_ID, V2I.V2I_VERSAO "

    TCQuery cQryTAF New Alias (cAlsTAF)

    While (cAlsTAF)->(!Eof())


        aAdd(aRecnos, CvalToChar((cAlsTAF)->R_E_C_N_O_)  )

        V2I->(DbGoTo( (cAlsTAF)->R_E_C_N_O_) )

        cCnpj := TafFilMigr( V2I->V2I_TABTAF )

        if !Empty(cCnpj)

            //Incrementa consulta do Lote.
            nContLote++
        
            aAdd(aJsonObj, JsonObject():New() )
            aJsonObj[nContLote]['cnpj']            := AllTrim(cCnpj)
            aJsonObj[nContLote]['keyERP']          := V2I->V2I_FILIAL + V2I->V2I_FILREG + V2I->V2I_EVENTO + V2I->V2I_ID + V2I->V2I_VERSAO
            aJsonObj[nContLote]['keyESocial']      := V2I->V2I_XMLID
            aJsonObj[nContLote]['xmlSendESocial']  := Encode64(V2I->V2I_XMLERP)
            aJsonObj[nContLote]['xmlTotESocial']   := Encode64(V2I->V2I_XMLTOT)
            aJsonObj[nContLote]['indRetif']        := V2I->V2I_INDRET
            aJsonObj[nContLote]['dtTrans']         := V2I->V2I_DTRANS
            aJsonObj[nContLote]['receipt']         := AllTrim(V2I->V2I_PROTUL)
            aJsonObj[nContLote]['event']           := V2I->V2I_EVENTO
            aJsonObj[nContLote]['reciboS3000']     := V2I->V2I_RECEXC
        
        Else
        RecLock("V2I", .F.)
                V2I->V2I_OBS := "O registro nao tem o codigo Empresa, Unidade de Negócio ou Filial"
                V2I->V2I_CODERR := "000003"
        MsUnlock()
        EndIf
        
        If nContLote == nTamLote

            cBody := FwJsonSerialize(aJsonObj)

            SendSmart(oRestClient, cUser, cPsw, cBody, aRecnos)

            aSize(aJsonObj,0)
            aSize(aRecnos, 0)
            
            aJsonObj := {}
            aRecnos := {}
            cBody   := ""

            nContLote := 0

        EndIf

        (cAlsTAF)->(DbSkip())
    End

    If nContLote <> 0

        cBody := FwJsonSerialize(aJsonObj)

        SendSmart(oRestClient, cUser, cPsw, cBody, aRecnos)
        
        aSize(aRecnos, 0)
        aSize(aJsonObj,0)

        cBody       := ""
        aRecnos     := {}
        aJsonObj    := {}
        nContLote   := 0

    EndIf
Else
	MsgAlert("URL do serviço REST incorreto ou não encontra-se ativo")
	lRet := .F.
End

lRestMig := lRet

FreeObj(oRestClient)
RestArea(aArea)

Return lRet


/*/{Protheus.doc} V2IUpdStatRecno
Rotina para alterar o status dos registros da 
tabela temporária de migração
@type  Static Function
@author Diego Santos
@since 23-10-2018
@version 1.0
/*/
Static Function V2IUpdStatRecno( aRecs, nOpc)

Local cUpdate
Local nY
Local cRecnos   := ""

For nY := 1 To Len(aRecs)
    If nY != Len(aRecs)
        cRecnos += aRecs[nY] + ";"
    Else
        cRecnos += aRecs[nY]
    EndIf
Next nY

cUpdate := " UPDATE " + RetSqlName("V2I")
If nOpc == 1
    cUpdate += " SET V2I_STATUS = '2' "
ElseIf nOpc == 2
    cUpdate += " SET V2I_STATUS = '3', "
    cUpdate += " V2I_CODERR = ' ', "
ElseIf nOpc == 3 //RollBack em virtude de erro de execução
    cUpdate += " SET V2I_STATUS = '1', "
    cUpdate += " V2I_CODERR = '999999', "
    cUpdate += " V2I_OBS = 'Erro de comunicacao com a API da Nova Instalacao TAF. Por favor, entre em contato com o suporte e verifique se o serviço REST encontra-se ativo.' " 
EndIf

cUpdate += " WHERE R_E_C_N_O_  IN " +  FormatIN( cRecnos, ";" ) 

TcSqlExec(cUpdate)

Return 

/*/{Protheus.doc} TafFilMigr
Rotina para retornar o CNPJ especifico 
dependendo do compartilhamento utilizado na tabela.
@type  Static Function
@author Diego Santos
@since 25-10-2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
/*/

Static Function TafFilMigr( cTabTaf )

Local aEmpresas     := FwLoadSM0()
Local aModeAccess   := {}
Local cRetCNPJ      := ""

Local nZ := 1

For nZ := 1 To 3
    aAdd( aModeAccess, FwModeAccess( cTabTaf, nZ ) )
Next nZ

//Se todas compartilhadas, retorno o CNPJ da filial Matriz.
If aModeAccess[1] == "C" .And. aModeAccess[2] == "C" .And. aModeAccess[3] == "C"
    cRetCNPJ := TAFGFilMatriz()[3]
//Se exclusiva apenas para a empresa, retorno o CNPJ da empresa exclusiva.
ElseIf aModeAccess[1] == "E" .And. aModeAccess[2] == "C" .And. aModeAccess[3] == "C"
    
    nPosEmp  := aScan( aEmpresas, { |x| Alltrim(x[3]) == Alltrim(xFilial(cTabTaf))} )//colocar alltrim

    //se o scan encontrar a posição do array
    if nPosEmp > 0
        cRetCNPJ := aEmpresas[nPosEmp][18]
    EndIf

//Se estiver completamente exclusiva, retorno o CNPJ da filial Matriz TAF.
ElseIf aModeAccess[1] == "E" .And. aModeAccess[2] == "E" .And. aModeAccess[3] == "E"
    nPosEmp  := aScan( aEmpresas, { |x| x[2] == xFilial(cTabTaf) } )
    cRetCNPJ := aEmpresas[nPosEmp][18]
Else
    cRetCNPJ := SM0->M0_CGC
EndIf

Return cRetCNPJ

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSqlExec
Monta a view
@author  Renato F Campos
@since   18/04/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAFSqlExec(cQryTAF, cAlsTAF)
Local bBlock	:= ErrorBlock( { |e| ChecErro(e) } )
Local lRetorno := .T.

BEGIN SEQUENCE
    TCQuery cQryTAF New Alias (cAlsTAF)
    
RECOVER
    lRetorno := .F.
END SEQUENCE

ErrorBlock(bBlock)

IIf (!lRetorno, TAFConOut( "Erro na instrução de execução SQL" + CRLF + TCSqlError()  + CRLF + ProcName(1) + CRLF + cQryTAF ) , Nil)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} SendSmart
Envia o lote processado para o Smart
@author  TOTVS
@since   18/04/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function SendSmart(oRestClient, cUser, cPsw, cBody, aRecnos)

Local nY            := 0
Local oRetJson      := Nil
Local aHeader       := {}
Local cAuthB64      := Encode64( AllTrim(cUser) + ":" + AllTrim(cPsw) )

aAdd( aHeader, "Authorization: Basic " + cAuthB64 )

V2IUpdStatRecno(aRecnos, 1)     //Atualizar para Em Processamento.
        
// define o conteúdo do body
oRestClient:SetPostParams(cBody)

If oRestClient:Post(aHeader)

    FwJsonDeSerialize(oRestClient:GetResult(), @oRetJson) 

    For nY := 1 To Len(oRetJson)

        If !oRetJson[nY]:RESULT
            V2I->(DbSetOrder(1))
            If V2I->(DbSeek( oRetJson[nY]:KEYERP))
                RecLock("V2I", .F.)
                    V2I->V2I_CODERR := "000001"
                    V2I->V2I_OBS    := oRetJson[nY]:MESSAGE
                V2I->(MsUnlock())
            EndIf
        Else
           V2I->(DbSetOrder(1))
           If V2I->(DbSeek( oRetJson[nY]:KEYERP))
               RecLock("V2I", .F.)
                   V2I->V2I_CODERR := ""
                   V2I->V2I_OBS    := oRetJson[nY]:MESSAGE
               V2I->(MsUnlock())
           EndIf
        EndIf

    Next nY

    V2IUpdStatRecno(aRecnos, 2) //Atualizar para Processado.

Else

    For nY := 1 To Len(aRecnos)
        V2I->(DbGoTo(Val(aRecnos[nY])))
        RecLock("V2I", .F.)
            V2I->V2I_CODERR := "000002"
            V2I->V2I_OBS    := oRestClient:GetLastError()
        MsUnlock()
    Next nY

    V2IUpdStatRecno(aRecnos, 3) //Realizo o RollBack da Transação.
    TAFConOut("POST", oRestClient:GetLastError())

EndIf

Return
