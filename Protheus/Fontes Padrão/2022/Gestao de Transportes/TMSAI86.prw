#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAI86.CH"

/*{Protheus.doc} TMSAI86()
Funcao de Job Envio Coleta entrega (Envio)

@author     Carlos A. Gomes Jr.
@since      22/06/2022
*/
Function TMSAI86()
    FWMsgrun(,{|| TMSAI86AUX()}, STR0005, STR0006 )
RETURN

/*{Protheus.doc} TMSAI86()
Funcao auxiliar do Job Envio Coleta entrega (Envio)
@author     Carlos A. Gomes Jr.
@since      18/08/2022
*/
Function TMSAI86AUX(cProcess)
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local cJSon     := ""
Local aResult   := {}
Local cIDExt    := ""
Local cErroInt  := ""
Local cFuncPre  := ""
Local lExecAlt  := .F.
Local oColEnt As Object
Local cProcAtu  := ""

DEFAULT cProcess := ""

    If LockByName("TM86JbLoop",.T.,.T.)
        oColEnt := TMSBCACOLENT():New("DN1")
        If oColEnt:DbGetToken()
            DN1->(DbGoTo(oColEnt:config_recno))
            DNC->(DbSetOrder(1))

            cQuery := "SELECT DN5.DN5_PROCES, DN2.DN2_PRIORI, DN4.R_E_C_N_O_ DN4REC, DN5.R_E_C_N_O_ DN5REC, DN2.R_E_C_N_O_ DN2REC " + CRLF
            cQuery += "FROM "+RetSQLName("DN5")+" DN5 " + CRLF
            cQuery += "INNER JOIN "+RetSQLName("DN4")+" DN4 ON " + CRLF
            cQuery += "  DN4.DN4_FILIAL = '"+xFilial("DN4")+"' AND " + CRLF
            cQuery += "  DN4.DN4_CODFON = DN5.DN5_CODFON AND " + CRLF
            cQuery += "  DN4.DN4_CODREG = DN5.DN5_CODREG AND " + CRLF
            cQuery += "  DN4.DN4_CHAVE  = DN5.DN5_CHAVE AND " + CRLF
            cQuery += "  DN4.D_E_L_E_T_ = '' " + CRLF
            cQuery += "INNER JOIN "+RetSQLName("DN2")+" DN2 ON  " + CRLF
            cQuery += "  DN2.DN2_FILIAL = '"+xFilial("DN2")+"' AND  " + CRLF
            cQuery += "  DN2.DN2_CODFON = DN5.DN5_CODFON AND  " + CRLF
            cQuery += "  DN2.DN2_CODREG = DN5.DN5_CODREG AND  " + CRLF
            cQuery += "  DN2.D_E_L_E_T_ = ''  " + CRLF
            cQuery += "WHERE " + CRLF
            cQuery += "DN5.DN5_FILIAL = '"+xFilial("DN5")+"' AND " + CRLF
            cQuery += "DN5.DN5_FILORI = '"+cFilAnt+"' AND " + CRLF
            cQuery += "DN5.DN5_STATUS = '2' AND " + CRLF
            cQuery += "DN5.DN5_SITUAC = '1' AND " + CRLF
            If !Empty(cProcess)
                cQuery += "DN5.DN5_PROCES = '" + cProcess + "' AND " + CRLF
            EndIf
            cQuery += "DN5.D_E_L_E_T_ = '' " + CRLF
            cQuery += "ORDER BY DN5.DN5_CODFON, DN5.DN5_PROCES, DN2.DN2_PRIORI " + CRLF

            cQuery := ChangeQuery(cQuery)
            DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

            Begin Transaction
                Do While !(cAliasQry)->(Eof())
                    DN2->(DbGoTo((cAliasQry)->DN2REC))
                    DN4->(DbGoTo((cAliasQry)->DN4REC))
                    DN5->(DbGoTo((cAliasQry)->DN5REC))
                    If !Empty(cProcAtu) .And. DN5->DN5_PROCES == cProcAtu .And. !Empty(cErroInt)
                        RecLock("DN5",.F.)
                        DN5->DN5_STATUS := '7' //-- Erro Processo
                        DN5->DN5_MOTIVO := DN5->DN5_MOTIVO + DtoC(dDataBase) + "-" + Time() + CRLF + cErroInt + CRLF + CRLF
                        MsUnLock()
						If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
                            RecLock("DNC", .F.)
                            DNC->DNC_STATUS := '3' //-- Erro Envio
           					DNC->DNC_DATULT := dDataBase
							DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
                            MsUnlock()
                        EndIf
                        (cAliasQry)->(DbSkip())
                        Loop
                    Else
                        cProcAtu := DN5->DN5_PROCES
                    EndIf
                    cErroInt := ""
                    cIDExt   := ""
                    lExecAlt := .T.

                    If !Empty(DN2->DN2_GETFUN)
                        aLayout   := DN5->(BscLayout(DN5_CODFON,DN5_CODREG))
                        aConteudo := DN5->(QuebraReg(DN5_CODFON,DN5_CODREG,DN5_SEQUEN,AClone(aLayout)))
                        cFuncPre  := StrTran(AllTrim(DN2->DN2_GETFUN),"()","(oColEnt,AClone(aLayout),AClone(aConteudo),@lExecAlt)")
                        cIDExt    := &(cFuncPre)
                    EndIf
                    If Empty(cIDExt)
                        cJSon := TMSMntJSon( DN5->DN5_CODFON, DN5->DN5_CODREG, DN2->DN2_BASE, DN5->DN5_CONTEU )
                        cEndPoint := &(AllTrim(DN2->DN2_ENDPNT))
                        cEndPoint := TMSMntJSon( DN5->DN5_CODFON, DN5->DN5_CODREG, cEndPoint, DN5->DN5_CONTEU )
                        If !Empty(cEndPoint)
                            If (aResult := oColEnt:Post( cEndPoint, cJson ))[1]
                                cIDExt := aResult[2]
                            Else
                                TMSAC30Err( "TMSAI86002", oColEnt:last_error, oColEnt:desc_error )
                            EndIf
                        EndIf
                    ElseIf !Empty(DN2->DN2_ALTPNT) .And. lExecAlt
                        cJSon := TMSMntJSon( DN5->DN5_CODFON, DN5->DN5_CODREG, DN2->DN2_ALTERN, DN5->DN5_CONTEU )
                        cEndPoint := &(AllTrim(DN2->DN2_ALTPNT))
                        cEndPoint := TMSMntJSon( DN5->DN5_CODFON, DN5->DN5_CODREG, cEndPoint, DN5->DN5_CONTEU )
                        cEndPoint := StrTran(cEndPoint,"#IDEXT#",cIDExt)
                        If !Empty(cEndPoint)
                            If !(aResult := oColEnt:Post( cEndPoint, cJson ))[1]
                                TMSAC30Err( "TMSAI86003", oColEnt:last_error, oColEnt:desc_error )
                            EndIf
                        EndIf
                    EndIf

                    cErroInt := TMSAC30GEr()
                    If !Empty(cErroInt)
                        RecLock("DN5",.F.)
                        DN5->DN5_STATUS := '3' //-- Erro Envio
                        DN5->DN5_MOTIVO := DN5->DN5_MOTIVO + cErroInt
                        MsUnLock()
                        cErroInt := STR0003 + DN5->DN5_CODREG + STR0004 + DN5->DN5_SEQUEN + "." + CRLF + CRLF
						If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
                            RecLock("DNC", .F.)
                            DNC->DNC_STATUS := '3' //-- Erro Envio
           					DNC->DNC_DATULT := dDataBase
							DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
                            MsUnlock()
                        EndIf
                    Else
                        RecLock("DN4",.F.)
                        If !Empty(cIDExt)
                            DN4->DN4_IDEXT  := cIDExt
                        EndIf
                        DN4->DN4_STATUS := '1' //-- Integrado
                        MsUnLock()
                        RecLock("DN5",.F.)
                        If !Empty(cIDExt)
                            DN5->DN5_IDEXT  := cIDExt
                        EndIf
                        DN5->DN5_STATUS := '1' //-- Integrado
                        DN5->DN5_SITUAC := '2' //-- Enviado
                        DN5->DN5_MOTIVO := DN5->DN5_MOTIVO + DtoC(dDataBase) + "-" + Time() + CRLF + STR0001 + CRLF + CRLF
                        MsUnLock()
						If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
                            RecLock("DNC", .F.)
                            DNC->DNC_STATUS := '1' //-- Integrado
                            DNC->DNC_SITUAC := '2' //-- Enviado
           					DNC->DNC_DATULT := dDataBase
							DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
                            MsUnlock()
                        EndIf
                        If !Empty(cIDExt)
                            DN5->(GrvHeranca(DN5_CODFON,DN5_CODREG,DN5_SEQUEN))
                        EndIf
                    EndIf

                    (cAliasQry)->(DbSkip())
                EndDo
            End Transaction
            (cAliasQry)->(DbCloseArea())
        EndIf
        UnLockByName("TM86JbLoop")
    EndIf
    FWFreeObj(oColEnt)
    FwFreeArray(aResult)

Return

/*{Protheus.doc} TMSAI86VCL()
Retorna Vetor com os dados do cliente

@author     Carlos A. Gomes Jr.
@since      01/04/2022
*/
Function TMSAI86VCL( aDocEnd, nCli )
Local aRet    := {}
Local aEndNum := {}
Local aEstado := {}

    aEstado := FWGetSX5( "12", aDocEnd[nCli][05] )
    If Len(aEstado) == 0 .Or. Len(aEstado[1]) < 4 .Or. Empty(aEstado[1][4])
        aEstado := { { "", "12", aDocEnd[nCli][05], aDocEnd[nCli][05] } }
    EndIf

    aEndNum := FisGetEnd(aDocEnd[nCli][01])

    AAdd(aRet, aDocEnd[nCli][10] )                                          //01 - CGC
    AAdd(aRet, aDocEnd[nCli][09] )                                          //02 - Nome
    AAdd(aRet, Iif(aDocEnd[nCli][11] == 'J',aDocEnd[nCli][08],"") )         //03 - Nome Fantasia
    AAdd(aRet, AClone(aDocEnd[nCli][12]) )                                  //04 - Pais
    AAdd(aRet, { AllTrim(aDocEnd[nCli][05]), AllTrim(aEstado[1][4]) } )     //05 - Estado
    AAdd(aRet, AllTrim(aDocEnd[nCli][04]) )                                 //06 - Municipio
    AAdd(aRet, AllTrim(aDocEnd[nCli][02]) )                                 //07 - Bairro
    AAdd(aRet, AllTrim(aEndNum[1]) )                                        //08 - Logradouro
    AAdd(aRet, AllTrim(aEndNum[3]) )                                        //09 - Numero
    AAdd(aRet, AllTrim(aEndNum[4]) )                                        //10 - Complemento
    AAdd(aRet, Left(aDocEnd[nCli][03],5)+"-"+Right(aDocEnd[nCli][03],3) )   //11 - CEP
    AAdd(aRet, aDocEnd[nCli][13])                                           //12 - Telefone
    AAdd(aRet, aDocEnd[nCli][06]+aDocEnd[nCli][07])                         //13 - Código+Loja
    
    FwFreeArray(aEstado)
    FwFreeArray(aEndNum)

Return aRet

/*{Protheus.doc} Scheddef()
@Função Função de parâmetros do Scheduler
@author Carlos Alberto Gomes Junior
@since 25/07/2022
*/
Static Function SchedDef()
Local aParam := { "P",;       //Tipo R para relatorio P para processo
                  "",;        //Pergunte do relatorio, caso nao use passar ParamDef
                  "DN5",;     //Alias
                  ,;          //Array de ordens
                  STR0002 }   //Descrição do Schedule
Return aParam
