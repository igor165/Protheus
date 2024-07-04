#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "QLTLGPD.CH"


#DEFINE _CRLF CHR(13)+CHR(10)

/*---------------------------------------------------------/
    {Protheus.doc} 
    @type  Function QLTLGPD
    @author thiago.rover
    @since 30/06/2020
    @version version
    @param 01 cCod, caractere, Código da matricula.
/----------------------------------------------------------*/
Function QLTLGPD(cCod) 

    Local cErrorFw   := ""
    Local cErrorMsgT := ""
    Local cFilAux    := ""
    Local cMensagemP := STR0006 + cCod + STR0007 + _CRLF //STR0006 Os campos com permissão de anonimização vinculados a matricula. - STR0007 - Foram anonimizados com sucesso nas tabelas:
    Local cMensagemT := "" 
    Local cQuery1    := ""
    Local lRet       := .F.

    cCod := Rtrim(cCod)

    // Cadastro de Usuários
    DbSelectArea("QAA")
	QAA->(dbSetOrder(1))
    cFilAux := xFilial("QAA")
	If QAA->(dbSeek(cFilAux+cCod))
        While       QAA->QAA_FILIAL == cFilAux .AND.;
              Rtrim(QAA->QAA_MAT)   == cCod    .AND. !QAA->(Eof())

            lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QAA", {QAA->(Recno())}, , @cErrorFw )
            If lRet
                If !("QAA" $ cMensagemT)
                    cMensagemT += "-> QAA - Cadastro de Usuários "  +_CRLF      
                EndIf
            Else
                // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                Help(NIL, NIL, STR0003, NIL, STR0001 + "'QAA - Cadastro de Usuários ': " + cErrorFw,;
                    1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
            EndIf

            QAA->(DbSkip())
        EndDo
    else
        MsgAlert(STR0008 , STR0009)
    EndIf
    
    //Agendas de Auditorias
    DbSelectArea("QUM")
    If FWSIXUtil():ExistIndex( "QUM" , "2" )
        QUM->(dbSetOrder(2))
        cFilAux := xFilial("QUM") 
        If QUM->(dbSeek(cFilAux+cCod))
            While       QUM->QUM_FILIAL  == cFilAux .AND.;
                  Rtrim(QUM->QUM_CODAUD) == cCod    .AND. !QUM->(Eof())

                lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QUM", {QUM->(Recno())}, , @cErrorFw )
                If lRet
                    If !("QUM" $ cMensagemT)
                        cMensagemT += "-> QUM - Agendas de Auditorias" + _CRLF     
                    EndIf
                Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                    Help(NIL, NIL, STR0003, NIL, STR0001 + "'QUM - Agendas de Auditorias': " + cErrorFw,;
                        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                EndIf

                QUM->(DbSkip())
            EndDo
        EndIf
    Else
       cErrorMsgT += "->  QUM - Agendas de Auditorias"  +_CRLF
    EndIf

    // Auditorias 
    DbSelectArea("QUC")
    If FWSIXUtil():ExistIndex( "QUC" , "4" )
        QUC->(dbSetOrder(4))
        cFilAux := xFilial("QUC")
        If QUC->(dbSeek(cFilAux+cCod))
            While       QUC->QUC_FILIAL  == cFilAux .AND.;
                  Rtrim(QUC->QUC_CODAUD) == cCod    .AND. !QUC->(Eof())

                lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QUC", {QUC->(Recno())}, , @cErrorFw )
                If lRet
                    If !("QUC" $ cMensagemT)
                        cMensagemT += "-> QUC - Auditorias"  +_CRLF      
                    EndIf
                Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                    Help(NIL, NIL, STR0003, NIL, STR0001 + "'QUC - Auditorias': " + cErrorFw,;
                        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                EndIf

                QUC->(DbSkip())
            EndDo
        EndIf
    Else
       cErrorMsgT += "-> QUC - Auditorias"  +_CRLF
    EndIf

    // Usuarios     
    DbSelectArea("QU1")
    QU1->(dbSetOrder(1))
    cFilAux := xFilial("QU1")
    If QU1->(dbSeek(cFilAux+cCod))
        While       QU1->QU1_FILIAL  == cFilAux .AND.;
              Rtrim(QU1->QU1_CODAUD) == cCod    .AND. !QU1->(Eof())

            lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QU1", {QU1->(Recno())}, , @cErrorFw )
            If lRet
                If !("QU1" $ cMensagemT)
                    cMensagemT += "-> QU1 - Usuários "  +_CRLF      
                EndIf
            Else
                // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                Help(NIL, NIL, STR0003, NIL, STR0001 + "'QU1 - Usuários ': " + cErrorFw,;
                    1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
            EndIf

            QU1->(DbSkip())
        EndDo  
    EndIf

    // Resultados     
    DbSelectArea("QQJ")
    If FWSIXUtil():ExistIndex( "QQJ" , "3" )
        QQJ->(dbSetOrder(3))
        cFilAux := xFilial("QQJ")
        If QQJ->(dbSeek(cFilAux+cCod))
            While      QQJ->QQJ_FILIAL == cFilAux .AND.;
                  Rtrim(QQJ->QQJ_MAT)  == cCod    .AND. !QQJ->(Eof())

                lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QQJ", {QQJ->(Recno())}, , @cErrorFw )
                If lRet
                    If !("QQJ" $ cMensagemT)
                        cMensagemT += "-> QQJ - Resultados  "  +_CRLF      
                    EndIf
                Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                    Help(NIL, NIL, STR0003, NIL, STR0001 + "'QQJ - Resultados  ': " + cErrorFw,;
                        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                EndIf

                QQJ->(DbSkip())
            EndDo
        EndIf
    Else
       cErrorMsgT += "-> QQJ - Resultados "  +_CRLF
    EndIf

    // Peças
    DbSelectArea("QKW")
    If FWSIXUtil():ExistIndex( "QKW" , "5" )
        QKW->(dbSetOrder(5))
        cFilAux := xFilial("QKW")
        If QKW->(dbSeek(cFilAux+cCod))
            While       QKW->QKW_FILIAL  == cFilAux .AND.;
                  Rtrim(QKW->QKW_RESPOR) == cCod    .AND. !QKW->(Eof())

                lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QKW", {QKW->(Recno())}, , @cErrorFw )
                If lRet
                    If !("QKW" $ cMensagemT)
                        cMensagemT += "-> QKW - Peças  "  +_CRLF      
                    EndIf
                Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                    Help(NIL, NIL, STR0003, NIL, STR0001 + "'QKW - Peças  ': " + cErrorFw,;
                        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                EndIf

                QKW->(DbSkip())
            EndDo
        EndIf
    Else
       cErrorMsgT += "-> QKW - Peças "  +_CRLF
    EndIf
    
    // Checklist APQP - A6 Fluxograma de processo 
    DbSelectArea("QKV")
    If FWSIXUtil():ExistIndex( "QKV" , "5" )
        QKV->(dbSetOrder(5))
        cFilAux := xFilial("QKV")
        If QKV->(dbSeek(cFilAux+cCod))
            While       QKV->QKV_FILIAL  == cFilAux .AND.;
                  Rtrim(QKV->QKV_RESPOR) == cCod    .AND. !QKV->(Eof())

                lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QKV", {QKV->(Recno())}, , @cErrorFw )
                If lRet
                    If !("QKV" $ cMensagemT)
                        cMensagemT += "-> QKV - A6 Fluxograma de processo   "  +_CRLF      
                    EndIf
                Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                    Help(NIL, NIL, STR0003, NIL, STR0001 + "'QKV - A6 Fluxograma de processo   ': " + cErrorFw,;
                        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                EndIf

                QKV->(DbSkip())
            EndDo
        EndIf
    Else
       cErrorMsgT += "-> QKV - A6 Fluxograma de processo  "  +_CRLF
    EndIf
    
    //Checklist APQP - A5 Instalaçôes
    DbSelectArea("QKU")
    If FWSIXUtil():ExistIndex( "QKU" , "5" )
        cFilAux := xFilial("QKU")
        QKU->(dbSetOrder(5))
        If QKU->(dbSeek(cFilAux+cCod))
            While       QKU->QKU_FILIAL  == cFilAux .AND.;
                  Rtrim(QKU->QKU_RESPOR) == cCod    .AND. !QKU->(Eof())

                lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QKU", {QKU->(Recno())}, , @cErrorFw )
                If lRet
                    If !("QKU" $ cMensagemT)
                        cMensagemT += "-> QKU - A5 Instalaçôes  "  +_CRLF      
                    EndIf
                Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                    Help(NIL, NIL, STR0003, NIL, STR0001 + "'QKU - A5 Instalaçôes  ': " + cErrorFw,;
                        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                EndIf

                QKU->(DbSkip())
            EndDo
        EndIf
    Else
       cErrorMsgT += "-> QKU - A5 Instalaçôes "  +_CRLF
    EndIf

    //Checklist APQP - Checklist A4 Qualidade do Produto/Processo
    DbSelectArea("QKT")
    If FWSIXUtil():ExistIndex( "QKT" , "5" )
        QKT->(dbSetOrder(5))
        cFilAux := xFilial("QKT")
        If QKT->(dbSeek(cFilAux+cCod))
            While       QKT->QKT_FILIAL  == cFilAux .AND.;
                  Rtrim(QKT->QKT_RESPOR) == cCod    .AND. !QKT->(Eof())

                lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QKT", {QKT->(Recno())}, , @cErrorFw )
                If lRet
                    If !("QKT" $ cMensagemT)
                        cMensagemT += "-> QKT - Qualidade do Produto/Processo "  +_CRLF      
                    EndIf
                Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                    Help(NIL, NIL, STR0003, NIL, STR0001 + "'QKT - Qualidade do Produto/Processo': " + cErrorFw,;
                        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                EndIf

                QKT->(DbSkip())
            EndDo
        EndIf
    Else
       cErrorMsgT += "-> QKT - Qualidade do Produto/Processo "  +_CRLF
    EndIf

    //Checklist APQP - A3 Novos Equipamentos, Ferramental e Teste
    DbSelectArea("QKS")
    If FWSIXUtil():ExistIndex( "QKS" , "5" )
        QKS->(dbSetOrder(5))
        cFilAux := xFilial("QKS")
        If QKS->(dbSeek(cFilAux+cCod))
            While       QKS->QKS_FILIAL  == cFilAux .AND.;
                  Rtrim(QKS->QKS_RESPOR) == cCod    .AND. !QKS->(Eof())

                lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QKS", {QKS->(Recno())}, , @cErrorFw )
                If lRet
                    If !("QKS" $ cMensagemT)
                        cMensagemT += "-> QKS - Novos Equipamentos, Ferramental e Teste  "  +_CRLF      
                    EndIf
                Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                    Help(NIL, NIL, STR0003, NIL, STR0001 + "'QKS - Novos Equipamentos, Ferramental e Teste': " + cErrorFw,;
                        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                EndIf

                QKS->(DbSkip())
            EndDo
        EndIf
    Else
       cErrorMsgT += "-> QKS - Novos Equipamentos, Ferramental e Teste"  +_CRLF
    EndIf

    //Checklist APQP - A2 Informação do Projeto
    DbSelectArea("QKR")
    If FWSIXUtil():ExistIndex( "QKR" , "5" )
        QKR->(dbSetOrder(5))
        cFilAux := xFilial("QKR")
        If QKR->(dbSeek(cFilAux+cCod))
            While       QKR->QKR_FILIAL  == cFilAux .AND.;
                  Rtrim(QKR->QKR_RESPOR) == cCod    .AND. !QKR->(Eof())

                lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QKR", {QKR->(Recno())}, , @cErrorFw )
                If lRet
                    If !("QKR" $ cMensagemT)
                        cMensagemT += "-> QKR - Informação do Projeto "  +_CRLF      
                    EndIf
                Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                    Help(NIL, NIL, STR0003, NIL, STR0001 + "'QKR - Informação do Projeto ': " + cErrorFw,;
                        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                EndIf

                QKR->(DbSkip())
            EndDo
        EndIf
    Else
       cErrorMsgT += "-> QKR -Informação do Projeto "  +_CRLF
    EndIf

    //Checklist APQP - A1 DFMEA
    DbSelectArea("QKQ")
    If FWSIXUtil():ExistIndex( "QKQ" , "5" )
        QKQ->(dbSetOrder(5))
        cFilAux := xFilial("QKQ")
        If QKQ->(dbSeek(cFilAux+cCod))
            While       QKQ->QKQ_FILIAL  == cFilAux .AND.;
                  Rtrim(QKQ->QKQ_RESPOR) == cCod    .AND. !QKQ->(Eof())

                lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QKQ", {QKQ->(Recno())}, , @cErrorFw )
                If lRet
                    If !("QKQ" $ cMensagemT)
                        cMensagemT += "-> QKQ - DFMEA "  +_CRLF      
                    EndIf
                Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                    Help(NIL, NIL, STR0003, NIL, STR0001 + "'QKQ - DFMEA ': " + cErrorFw,;
                        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                EndIf

                QKQ->(DbSkip())
            EndDo
        EndIf
    Else
       cErrorMsgT += "-> QKQ -DFMEA "  +_CRLF
    EndIf

    //Equipe Multifuncional APQP
    DbSelectArea("QKE")
    If FWSIXUtil():ExistIndex( "QKE" , "3" )
        cFilAux := xFilial("QKE")
        QKE->(dbSetOrder(3))
        If QKE->(dbSeek(cFilAux+cCod))
            While       QKE->QKE_FILIAL == cFilAux .AND.;
                  Rtrim(QKE->QKE_MAT)   == cCod    .AND. !QKE->(Eof())

                lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QKE", {QKE->(Recno())}, , @cErrorFw )
                If lRet
                    If !("QKE" $ cMensagemT)
                        cMensagemT += "-> QKE - Equipe Multifuncional APQP "  +_CRLF      
                    EndIf
                Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                    Help(NIL, NIL, STR0003, NIL, STR0001 + "'QKE - Equipe Multifuncional APQP ': " + cErrorFw,;
                        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                EndIf

                QKE->(DbSkip())
            EndDo
        EndIf
    Else
       cErrorMsgT += "-> QKE - Equipe Multifuncional APQP "  +_CRLF
    EndIf

    // Nao Conformidades
    DbSelectArea("QI2")
    If FWSIXUtil():ExistIndex( "QI2" , "6" )
        QI2->(dbSetOrder(6))
        cFilAux := xFilial("QI2")
        If QI2->(dbSeek(cFilAux+cCod))
            While       QI2->QI2_FILIAL == cFilAux .AND.;
                  Rtrim(QI2->QI2_MAT)   == cCod    .AND. !QI2->(Eof())

                lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QI2", {QI2->(Recno())}, , @cErrorFw )
                If lRet
                    If !("QI2 - Não Conformidades" $ cMensagemT)
                        cMensagemT += "-> QI2 - Não Conformidades "  +_CRLF      
                    EndIf
                Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                    Help(NIL, NIL, STR0003, NIL, STR0001 + "'QI2 - Não Conformidades ': " + cErrorFw,;
                        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                EndIf

                QI2->(DbSkip())
            EndDo
        EndIf
    Else
       cErrorMsgT += "-> QI2 - Não Conformidades "  +_CRLF
    EndIf

    //Cadastro de resultados
    DbSelectArea("QF7")
    If FWSIXUtil():ExistIndex( "QF7" , "3" )
        QF7->(dbSetOrder(3))
        cFilAux := xFilial("QF7")
        If QF7->(dbSeek(cFilAux+cCod))
            While       QF7->QF7_FILIAL == cFilAux .AND.;
                  Rtrim(QF7->QF7_MAT)   == cCod    .AND. !QF7->(Eof())

                lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QF7", {QF7->(Recno())}, , @cErrorFw )
                If lRet
                    If !("QF7" $ cMensagemT)
                        cMensagemT += "-> QF7 - Cadastro de resultados "  +_CRLF      
                    EndIf
                Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                    Help(NIL, NIL, STR0003, NIL, STR0001 + "'QF7 - Cadastro de resultados ': " + cErrorFw,;
                        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                EndIf

                QF7->(DbSkip())
            EndDo
        EndIf
    Else
       cErrorMsgT += "-> QF7 - Cadastro de resultados "  +_CRLF
    EndIf

    // Nao Conformidades
    cQuery1 := " SELECT * FROM " + RetSqlName("QI2")+" QI2 "
	cQuery1 += " WHERE RTRIM(QI2_MAT) = '"+ cValToChar(cCod) +"' OR RTRIM(QI2_MATRES) = '"+ cValToChar(cCod) +"' "
    cQuery1 += " AND QI2_CONREA <> '' AND QI2_CODACA <> '' AND QI2_REVACA <> '' "
	cQuery1 += " AND D_E_L_E_T_ <> '*' "
    cQuery1 := ChangeQuery(cQuery1)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),"QI2TRB",.T.,.T.)

    DbSelectArea("QI2") 
    If FWSIXUtil():ExistIndex( "QI2" , "4" )
        // Responsável pela Não Conformidade
        QI2->(dbSetOrder(4))
        WHILE QI2TRB->(!EOF())
            If QI2->(dbSeek(QI2TRB->QI2_FILRES+cCod))
                While     QI2->QI2_FILIAL  == QI2TRB->QI2_FILRES .AND.;
                    Rtrim(QI2->QI2_MATRES) == cCod    .AND. !QI2->(Eof())

                    lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QI2", {QI2->(Recno())}, , @cErrorFw ) 
                    If lRet
                        If !("QI2 - Responsável pela Não Conformidades" $ cMensagemT)
                            cMensagemT += "-> QI2 - Responsável pela Não Conformidades "+_CRLF     
                        EndIf
                    Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                        Help(NIL, NIL, STR0003, NIL, STR0001 + "'QI2 - Responsável pela Não Conformidades': " + cErrorFw,;
                            1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002}) 
                    EndIf

                    QI2->(DbSkip())
                EndDo
                
            EndIf
            QI2TRB->(DbSkip())
        ENDDO
    Else
       cErrorMsgT += "-> QI2 - Responsável pela Não Conformidades "  +_CRLF
    EndIf

    QI2TRB->(DBGoTop())
    

    DbSelectArea("QI2") 
    If FWSIXUtil():ExistIndex( "QI2" , "6" )
        // Digitador da Não Conformidade
        QI2->(dbSetOrder(6))
        WHILE QI2TRB->(!EOF())
            If QI2->(dbSeek(QI2TRB->QI2_FILMAT+cCod))
                
                While       QI2->QI2_FILIAL == QI2TRB->QI2_FILMAT .AND.;
                    Rtrim(QI2->QI2_MAT)   == cCod    .AND. !QI2->(Eof())

                    lRet := FwProtectedDataUtil():ToAnonymizeByRecno( "QI2", {QI2->(Recno())}, , @cErrorFw ) 
                    If lRet
                        If !("QI2 - Digitador da Não Conformidades" $ cMensagemT)
                            cMensagemT += "-> QI2 - Digitador da Não Conformidades"+_CRLF       
                        EndIf
                    Else
                    // STR0001 - Ocorreu um erro durante a anonimização dos campos da tabela
                    // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
                        Help(NIL, NIL, STR0003, NIL, STR0001 + " 'QI2 - Digitador da Não Conformidades': " + cErrorFw,;
                            1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002}) 
                    EndIf

                    QI2->(DbSkip())
                EndDo
            EndIf
            QI2TRB->(DbSkip())
        ENDDO
    Else
       cErrorMsgT += "-> QI2 - Digitador da Não Conformidades "  +_CRLF
    EndIf

    QI2TRB->(DbCLOSEAREA())

    If !Empty(cMensagemT)
        MsgInfo( cMensagemP + _CRLF + cMensagemT  )
    EndIf

    If !Empty(cErrorMsgT)
        //STR0004 - Ocorreu um erro durante a anonimização dos campos das tabelas abaixo devido a falta do índice para realização da anonimização
        // STR0002 - Entre em contato com o departamento de TI ou com o suporte da TOTVS.
        Help(NIL, NIL, STR0003, NIL, STR0004 + _CRLF +  cErrorMsgT,;
                    1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002}) 
    EndIf
    
Return lRet
