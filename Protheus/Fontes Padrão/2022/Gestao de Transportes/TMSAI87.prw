#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAI87.CH"

Static lTMI87Con := ExistBlock("TMI87CON")

/*{Protheus.doc} TMSAI87()
Funcao de Job de retrono da integração Coleta entrega

@author     Carlos A. Gomes Jr.
@since      22/06/2022
*/
Function TMSAI87()
    FWMsgrun(,{|| TMSAI87Aux()}, STR0006, STR0007 )
Return

/*{Protheus.doc} TMSAI87Aux()
Funcao auxiliar de Loop do Coleta entrega
@author     Carlos A. Gomes Jr.
@since      19/08/2022
*/
Function TMSAI87Aux()
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local aResult    := {}
Local cErroInt   := ""
Local aStruct    := {}
Local nPosStruc  := 0
Local aViagem    := {}
Local aViaCol    := {}
Local nViaCol    := 0
Local aDocVia    := {}
Local nDoc       := 0
Local aEvidencia := {}
Local aPEDocVia  := {}
Local cCodOco    := ""
Local cErroOco   := ""
Local aImagem    := {}
Local aDadosGrv  := {}
Local cIdMPOS    := ""
Local aNFsComp   := {}
Local nNFComp    := 0
Local aRegDados  := {}
Local oColEnt As Object

    If LockByName("TM87JbLoop",.T.,.T.)
        oColEnt := TMSBCACOLENT():New("DN1")
        If oColEnt:DbGetToken()
            DN1->(DbGoTo(oColEnt:config_recno))

            //-- Inicializa a estrutura
            aStruct := TMSMntStru(DN1->DN1_CODFON,.T.)
            //-- Localiza primeiro registro da estrutura
            For nPosStruc := 1 To Len(aStruct)
                //-- Não é adicional de ninguém, ainda não foi processado e não dependente de ninguém
                If (Ascan(aStruct,{|x| x[11] + x[12] == aStruct[nPosStruc,1] + aStruct[nPosStruc,2]}) == 0) .And. ;
                                                    aStruct[nPosStruc,10] == "2" .And. Empty(aStruct[nPosStruc,6])
                    Exit
                EndIf
            Next
            
            cQuery := "SELECT DN5.DN5_PROCES, DN4.R_E_C_N_O_ DN4REC, DN5.R_E_C_N_O_ DN5REC " + CRLF
            cQuery += "FROM "+RetSQLName("DN5")+" DN5 " + CRLF
            cQuery += "INNER JOIN "+RetSQLName("DN4")+" DN4 ON " + CRLF
            cQuery += "  DN4.DN4_FILIAL = '"+xFilial("DN4")+"' AND " + CRLF
            cQuery += "  DN4.DN4_CODFON = DN5.DN5_CODFON AND " + CRLF
            cQuery += "  DN4.DN4_CODREG = DN5.DN5_CODREG AND " + CRLF
            cQuery += "  DN4.DN4_CHAVE  = DN5.DN5_CHAVE AND " + CRLF
            cQuery += "  DN4.D_E_L_E_T_ = '' " + CRLF
            cQuery += "WHERE " + CRLF
            cQuery += "DN5.DN5_FILIAL = '"+xFilial("DN5")+"' AND " + CRLF
            cQuery += "DN5.DN5_FILORI = '"+cFilAnt+"' AND " + CRLF
            cQuery += "DN5.DN5_CODFON = '" + aStruct[nPosStruc,1] + "' AND " + CRLF
            cQuery += "DN5.DN5_CODREG = '" + aStruct[nPosStruc,2] + "' AND " + CRLF
            cQuery += "DN5.DN5_STATUS = '1' AND " + CRLF
            cQuery += "DN5.DN5_SITUAC = '2' AND " + CRLF
            cQuery += "DN5.D_E_L_E_T_ = '' " + CRLF
            cQuery += "ORDER BY DN5.DN5_PROCES" + CRLF

            cQuery := ChangeQuery(cQuery)
            DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
            Begin Transaction
                Do While !(cAliasQry)->(Eof())
                    DN4->(DbGoTo((cAliasQry)->DN4REC))
                    DN5->(DbGoTo((cAliasQry)->DN5REC))
                    DTQ->(DbSetOrder(2))
                    If !DTQ->(MsSeek(RTrim(DN5->DN5_CHAVE))) .Or. DTQ->DTQ_STATUS == "3" //3==Encerrada
                        TMSAC30Err( "TMSAI87Job", STR0001 + DTQ->(DTQ_FILORI+"/"+DTQ_VIAGEM), STR0002 )
                        aRegDados := {}
                        AAdd( aRegDados, {"DN5_STATUS", "4"} ) //-- Erro Devolução
                        AAdd( aRegDados, {"DN5_SITUAC", "3"} ) //-- Recebido
                        AAdd( aRegDados, {"DN5_MOTIVO", DN5->DN5_MOTIVO + TMSAC30GEr()} )
                        AtuStatDN5(,,, aRegDados )

                    Else
                        If ( aViagem := TMSAC30GDV(AllTrim(DN5->DN5_IDEXT),,.F.) )[1] .And. aViagem[2] != "EXCLUIDA"
                            aViaCol := DTQ->( DocViaCol(DTQ_FILORI,DTQ_VIAGEM) )
                            If AScan(aViaCol, {|x| x[6] != "2" .And. x[6] != "4" } ) == 0 //2=Em Transito 4=Chegada Em Filial
                                //Verifica se configurado para baixar direto do motorista ou aguarda viagem encerrada
                                If aViagem[2] == "ENCERRADA"
                                    aDocVia := TMSAC30GDV(AllTrim(DN5->DN5_IDEXT))
                                    For nDoc := 1 To Len(aDocVia[2])
                                        If (aEvidencia := TMSAC30GEv(aDocVia[2][nDoc][1]))[1]
                                            AAdd(aDocVia[2][nDoc],AClone(aEvidencia))
                                        EndIf
                                    Next
                                    If lTMI87Con
                                        aPEDocVia := ExecBlock("TMI87CON",.F.,.F.,{AClone(aDocVia)})
                                        aDocVia := AClone(aPEDocVia)
                                    EndIf
                                    //Verfica se todas as evidencias lançadas (sucesso ou insucesso) e se configurado só com encerramento/motorista ou após análise (aprovação/reprovação)
                                    If AScan(aDocVia[2],{|x| x[4] == "NAO_FINALIZADA" }) == 0 .And. ( DN1->DN1_BEREAL == "3" .Or. AScan(aDocVia[2],{|x| x[6][2][11] == "PENDENTE_ANALISE" }) == 0 )
                                        DUD->(DbSetOrder(1))
                                        For nDoc := 1 To Len(aDocVia[2])
                                            If ( nViaCol := AScan(aViaCol,{|x| AllTrim(x[3]+x[4]+x[5]) == aDocVia[2][nDoc][3] }) ) > 0
                                                If DUD->(MsSeek(xFilial("DUD")+aViaCol[nViaCol][3]+aViaCol[nViaCol][4]+aViaCol[nViaCol][5]+aViaCol[nViaCol][1]+aViaCol[nViaCol][2]))
                                                    aEvidencia := AClone(aDocVia[2][nDoc][6])
                                                    cCodOco := ""
                                                    If aDocVia[2][nDoc][2] == "ENTREGA"
                                                        If aEvidencia[2][6] == "FINALIZADA_COM_SUCESSO"
                                                            cCodOco := DN1->DN1_OCOENT
                                                        ElseIf aEvidencia[2][6] == "FINALIZADA_COM_INSUCESSO"
                                                            cCodOco := DN1->DN1_OCNFEC
                                                        EndIf
                                                    ElseIf aDocVia[2][nDoc][2] == "COLETA"
                                                        If aEvidencia[2][6] == "FINALIZADA_COM_SUCESSO"
                                                            cCodOco := DN1->DN1_OCOCOL
                                                        ElseIf aEvidencia[2][6] == "FINALIZADA_COM_INSUCESSO"
                                                            cCodOco := DN1->DN1_OCNCOL
                                                        EndIf
                                                    EndIf
                                                    cErroOco := ""
                                                    If !Empty(cCodOco) .And. DUD->(ApontaOcor(DUD_FILORI,DUD_VIAGEM,DUD_FILDOC,DUD_DOC,DUD_SERIE,DUD_SERTMS,cCodOco,aEvidencia[2][1],aEvidencia[2][2],aEvidencia[2][4],,,,@cErroOco))
                                                        If !Empty(aEvidencia[2][3][1]) .And. (aImagem := TMSAC30Img(aClone(aEvidencia[2][3])))[1]
                                                            aDadosGrv := {}
                                                            AAdd(aDadosGrv,{ "DM0_FILDOC", DUD->DUD_FILDOC        , Nil } )
                                                            AAdd(aDadosGrv,{ "DM0_DOC"   , DUD->DUD_DOC           , Nil } )
                                                            AAdd(aDadosGrv,{ "DM0_SERIE" , DUD->DUD_SERIE         , Nil } )
                                                            AAdd(aDadosGrv,{ "DM0_IDINTG", DN5->DN5_IDEXT         , Nil } )
                                                            AAdd(aDadosGrv,{ "DM0_IMAGEM", Encode64(aImagem[2][5]), Nil } )
                                                            AAdd(aDadosGrv,{ "DM0_DATREA", aEvidencia[2][01]      , Nil } )
                                                            AAdd(aDadosGrv,{ "DM0_HORREA", aEvidencia[2][02]      , Nil } )
                                                            AAdd(aDadosGrv,{ "DM0_NOMRES", aEvidencia[2][04]      , Nil } )
                                                            AAdd(aDadosGrv,{ "DM0_DOCRES", aEvidencia[2][05]      , Nil } )
                                                            AAdd(aDadosGrv,{ "DM0_EXTENS", Substr(aImagem[2][3],At(aImagem[2][3],".")), Nil } )
                                                            AAdd(aDadosGrv,{ "DM0_STATUS", "2", Nil } )
                                                            cIdMPOS := ""
                                                            DUD->( GrvLocal( DUD_FILORI, DUD_VIAGEM, aEvidencia[2][09], aEvidencia[2][10], aEvidencia[2][01], aEvidencia[2][02], @cIdMPOS ) )
                                                            AAdd(aDadosGrv,{ "DM0_IDMPOS", cIdMPOS          , Nil } )
                                                            AAdd(aDadosGrv,{ "DM0_LATITU", aEvidencia[2][09], Nil } )
                                                            AAdd(aDadosGrv,{ "DM0_LONGIT", aEvidencia[2][10], Nil } )
                                                            ApontaCEle("DM0",4,aDadosGrv,xFilial("DM0")+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE),1)
                                                            If aDocVia[2][nDoc][2] == "ENTREGA" .And. aDocVia[2][nDoc][4] == "FINALIZADA_COM_SUCESSO"
                                                                aNFsComp := DUD->(ApontaComp(DUD_FILDOC,DUD_DOC,DUD_SERIE,aEvidencia[2][1],aEvidencia[2][2],aEvidencia[2][1],aEvidencia[2][2]))
                                                                If !DUD->(TMSVeApoio(DUD_FILDOC,DUD_DOC,DUD_SERIE))
                                                                    For nNFComp := 1 To Len(aNFsComp)
                                                                        aDadosGrv := {}
                                                                        AAdd(aDadosGrv,{ "DLY_RECEBE", aEvidencia[2][04], Nil } )
                                                                        AAdd(aDadosGrv,{ "DLY_DOCREC", aEvidencia[2][05], Nil } )
                                                                        AAdd(aDadosGrv,{ "DLY_STATUS", "2", Nil } )
                                                                        ApontaCEle("DLY",4,aDadosGrv,xFilial("DLY")+aNFsComp[nNFComp],2)
                                                                    Next
                                                                EndIf
                                                            EndIf
                                                        EndIf
                                                    Else
                                                        cErroInt := DtoC(dDataBase) + "-" + Time() + CRLF
                                                        If Empty(cCodOco)
                                                            cErroInt += STR0003 + CRLF
                                                        Else
                                                            cErroInt += cErroOco + CRLF
                                                            cErroOco := ""
                                                        EndIf
                                                        TMSAC30PEr(cErroInt)
                                                    EndIf
                                                EndIf
                                            EndIf
                                        Next
                                        cErroInt := TMSAC30GEr()
                                        If !Empty(cErroInt)
                                            aRegDados := {}
                                            AAdd( aRegDados, {"DN5_STATUS", "4" } ) //-- Erro Devolução
                                            AAdd( aRegDados, {"DN5_SITUAC", "3" } ) //-- Recebido
                                            AAdd( aRegDados, {"DN5_MOTIVO", DN5->DN5_MOTIVO + cErroInt } )
                                            AtuStatDN5(,,, aRegDados )
                                        Else
                                            aRegDados := {}
                                            AAdd( aRegDados, {"DN5_STATUS", "1" } ) //-- Integrado
                                            AAdd( aRegDados, {"DN5_SITUAC", "3" } ) //-- Recebido
                                            AAdd( aRegDados, {"DN5_MOTIVO", DN5->DN5_MOTIVO + DtoC(dDataBase) + " " + Time() + CRLF + STR0004 } )
                                            AtuStatDN5(,,, aRegDados )
                                        EndIf
                                    EndIf
                                EndIf
                            EndIf
                        Else
                            AtuStatDN5(,,,, .T. )
                        EndIf
                    EndIf
                (cAliasQry)->(DbSkip())
                EndDo
            End Transaction
            (cAliasQry)->(DbCloseArea())
        EndIf
        UnLockByName("TM87JbLoop")
    EndIf

    FwFreeArray(aResult)
    FwFreeArray(aStruct)
    FwFreeArray(aViagem)
    FwFreeArray(aViaCol)
    FwFreeArray(aDocVia)
    FwFreeArray(aEvidencia)
    FwFreeArray(aPEDocVia)
    FwFreeArray(aImagem)
    FwFreeArray(aDadosGrv)
    FwFreeArray(aNFsComp)
    FwFreeArray(aRegDados)

    FWFreeObj(oColEnt)

Return

/*{Protheus.doc} Scheddef()
@Função Função para atualizar DN5 por Processo (todos registros iguais)
@author Carlos Alberto Gomes Junior
@since 28/07/2022
*/
Static Function AtuStatDN5( cCodFon, cProcess, cLocali, aRegDados, lDelDN4DN5 )
Local aAreas := {}

DEFAULT cCodFon    := DN5->DN5_CODFON
DEFAULT cProcess   := DN5->DN5_PROCES
DEFAULT cLocali    := AllTrim(DN5->DN5_LOCALI)
DEFAULT aRegDados  := {}
DEFAULT lDelDN4DN5 := .F.

    DNC->(DbSetOrder(1))
    If lDelDN4DN5
        aAreas := { dn4->(GetArea()), DN5->(GetArea()), GetArea() }
        DN4->(DbSetOrder(1))
        DN5->(DbSetOrder(5))
        Do While DN5->(DbSeek( xFilial("DN5") + cCodFon + cProcess))
            If DN4->(DbSeek( xFilial("DN4") + cCodFon + DN5->(DN5_CODREG + DN5_CHAVE)))
                RecLock("DN4",.F.)
                DN4->( DbDelete() )
                MsUnlock()
            EndIf
            If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
                RecLock("DNC", .F.)
                DNC->( DbDelete() )
                MsUnlock()
            EndIf
            RecLock("DN5",.F.)
            DN5->( DbDelete() )
            MsUnlock()
        EndDo
        AEval(aAreas, {|aArea| RestArea(aArea), FwFreeArray(aArea) })

    ElseIf !Empty(aRegDados)
        aAreas := { DN5->(GetArea()), GetArea() }
        DN5->(DbSetOrder(5))
        DN5->(MsSeek(xFilial("DN5") + cCodFon + cProcess + cLocali))
        Do While !DN5->(Eof()) .And. xFilial("DN5") + cCodFon + cProcess + cLocali == DN5->(DN5_FILIAL + DN5_CODFON + DN5_PROCES + Left(DN5_LOCALI,Len(cLocali)))
            RecLock("DN5",.F.)
            DN5->( AEval(aRegDados,{|x| FieldPut( FieldPos(x[1]), x[2] ) }) )
            MsUnlock()
            If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
                RecLock("DNC", .F.)
                DNC->( AEval(aRegDados,{|x| If(Substr(x[1],4) $ "_STATUS|_SITUAC", FieldPut( FieldPos("DNC"+Substr(x[1],4)), x[2] ) , ) }) )
                DNC->DNC_DATULT := dDataBase
				DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
                MsUnlock()
            EndIf
            DN5->(DbSkip())
        EndDo
        AEval(aAreas, {|aArea| RestArea(aArea), FwFreeArray(aArea) })

    EndIf
    FwFreeArray(aRegDados)
    FwFreeArray(aAreas)

Return

/*{Protheus.doc} GrvLocal
Grava Geolocalização Tabela DAV
@author Carlos Alberto Gomes Junior
@CopiadoDe Função statica no TMSAO10 de Rodrigo Pirolo
@since 09/05/22
*/
Static Function GrvLocal( cFilOrigem, cNumViagem, cLatitu, cLongit, dDatEnt, cHorEnt, cIdMPOS )

    Local aAreas  := { DTR->(GetArea()), GetArea() }
    Local lRet    := .T.
    Local lBlind  := IsBlind()
    Local aCabDAV := {}
    
    Private lMsErroAuto     := .F.
    Private lAutoErrNoFile  := .T.

    Default cFilOrigem := ""
    Default cNumViagem := ""
    Default cLatitu    := 0
    Default cLongit    := 0
    Default dDatEnt    := CToD("")
    Default cHorEnt    := ""

    DbSelectArea( "DTR" )
    DTR->( DbSetOrder( 1 ) ) // DTR_FILIAL, DTR_FILORI, DTR_VIAGEM, DTR_ITEM
    If DTR->( DbSeek( xFilial( "DTR" ) + cFilOrigem + cNumViagem + StrZero( 1, Len( DTR->DTR_ITEM ) ) ) )

        AAdd( aCabDAV, { "DAV_CODVEI", DTR->DTR_CODVEI, NIL } )
        AAdd( aCabDAV, { "DAV_FILORI", cFilOrigem,      NIL } )
        AAdd( aCabDAV, { "DAV_VIAGEM", cNumViagem,      NIL } )
        AAdd( aCabDAV, { "DAV_TIPPOS", "3",             NIL } ) // 1=GPRS Memória; 2=GPRS Atual; 3=Satelital
        AAdd( aCabDAV, { "DAV_LATITU", cLatitu,         NIL } )
        AAdd( aCabDAV, { "DAV_LONGIT", cLongit,         NIL } )
        AAdd( aCabDAV, { "DAV_STATUS", "3",             NIL } ) // 1=Nao Processado; 2=Processado com erro; 3=Processado
        AAdd( aCabDAV, { "DAV_DATPOS", dDatEnt,         NIL } )
        Aadd( aCabDAV, { "DAV_HORPOS", cHorEnt,         NIL } )
        Aadd( aCabDAV, { "DAV_IGNICA", "2",             NIL } ) // 0=Desligada; 1=Ligada; 2=Não identificada

        lAutoErrNoFile := If( lBlind, .T., .F. )
        MSExecAuto( { | x, y | TMSAO10( x, y ) }, aCabDAV, 3 )
        If lMsErroAuto
            If !lBlind
                MostraErro()
            EndIf
            lRet := .F.
        Else
            cIdMPOS := DAV->DAV_IDMPOS
        EndIf
        lMsErroAuto := .F.
    EndIf

    FwFreeArray( aCabDAV )
    AEval(aAreas, {|aArea| RestArea(aArea) })
    FwFreeArray( aAreas )
    
Return lRet

/*{Protheus.doc} Scheddef()
@Função Função de parâmetros do Scheduler
@author Carlos Alberto Gomes Junior
@since 25/07/2022
*/
Static Function SchedDef()
Local aParam := { "P",;        //Tipo R para relatorio P para processo
                  "",;         //Pergunte do relatorio, caso nao use passar ParamDef
                  "DN5",;      //Alias
                  ,;           //Array de ordens
                  STR0005 }    //Descrição do Schedule
Return aParam
