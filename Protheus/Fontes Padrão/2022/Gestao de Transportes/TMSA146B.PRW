#INCLUDE "PROTHEUS.CH" 

Static lDataPrev:= .T.   //Identifica se existe Docto com Previsao de Entrega
//---------------- CALLBACK RESULT
//--- TRANSPORTE E COLETA NAO DEIXA
//--- TRANSPORTE E ENTREGA (COLIGA SIM OU NAO)
//--- COLETA, OU COLETA E ENTREGA ->>> viagem entrega

/*/{Protheus.doc} T146RejTPR
Processa os documentos que foram rejeitados na Roteirização
- CallBack Roteirização
@author Katia
@since  06/09/2021
@version P12.1.35
@type function
/*/
Function T146RejTPR(cIdRot,aRejeitados,cMsgRejeit)
Local lRet       := .T.
Local nCount     := 0
Local nTamFil    := TamSx3("DMS_FILROT")[1] 
Local nTamRot    := TamSx3("DMS_IDROT")[1] 
Local cFilRot    := ""
Local cNumRot    := ""
Local cChvEnt    := ""
Local lContinua  := .F.
Local cEntida    := ""

Default cIdRot     := ""
Default aRejeitados:= {}

For nCount:= 1 To Len(aRejeitados)
    //-- Atualiza DMS_Status dos Doctos Rejeitados
    T146GetChv(aRejeitados[nCount][1], @cChvEnt, @cEntida ) 
    T146AtuDMS(cIdRot,cChvEnt,cEntida,'2',aRejeitados[nCount][2])  //2-Rejeitado

    lContinua:= .T.
Next nCount

If lContinua
    //--Valida e Gera os Lotes rejeitados
    cFilRot:= Left( cIdRot, nTamFil ) 
    cNumRot:= Right( AllTrim(cIdRot), nTamRot )

    lRet:= T146DocRej(cFilRot,cNumRot)
EndIf

Return lRet

/*/{Protheus.doc} T146PrcTPR
Processa dados do retorno para geração da Programação de Carregamento
- CallBack Roteirização
@author Katia
@since  06/09/2021
@version P12.1.35
@type function
/*/
Function T146PrcTPR(cIdRot,aSequen)
Local lRet    := .T.
Local n       := 0
Local n1      := 0
Local aDocPrg :=  {}
Local cEntida := ""
Local dDtPrevIni := cToD('')
Local dDtPrevFim := cToD('')
Local dDtEmiIni  := cToD('')
Local dDtEmiFim  := cToD('')
Local cChvEnt    := ""
Local nSeqRot    := 0
Local nPos       := 0
Local nSeqDoc    := 0
Local dDtIniRot  := cTod('')
Local cHrIniRot  := ""
Local dDtFimRot  := cTod('')
Local cHrFimRot  := ""

Default cIdRot := ""
Default aSequen:= {}

lDataPrev:= .T.
For n:= 1 To Len(aSequen)

    For n1:= 1 To Len(aSequen[n])

        If n1 == 1
            If Len(aDocPrg) > 0
                //-- Chama rotina de Programacao de Carregamento    
                lRet:= T146GerPrg(cVeiculo,aDocPrg,dDtPrevIni,dDtPrevFim,dDtEmiIni,dDtEmiFim,cIdRot,dDtIniRot,cHrIniRot,dDtFimRot,cHrFimRot)
                aDocPrg := {}
                nSeqDoc := 0
            EndIf
            nPos:=  Ascan(aSequen[n], {|x| AllTrim(Upper(x[1])) == 'SEQUENTIAL' })
            If nPos > 0
                nSeqRot     := aSequen[n][nPos][2]   //Sequencia Roteirização do Mapa
                cVeiculo    := aSequen[n][nPos][3]   //Veiculo
                dDtIniRot   := aSequen[n][nPos][4]   //Data Inicio Roteirização  
                cHrIniRot   := aSequen[n][nPos][5]   //Hora Inicio Roteirização
                dDtFimRot   := aSequen[n][nPos][6]   //Data Fim Roteirização
                cHrFimRot   := aSequen[n][nPos][7]   //Hora Fim Roteirização
            EndIf

        Else
            nSeqDoc++
            T146GetChv(aSequen[n][n1],@cChvEnt, @cEntida)

            DbSelectArea("DMS")    
        	DMS->(DbSetOrder(4))  
            If DMS->(DbSeek(xFilial("DMS")+cIdRot+Padr(cChvEnt,Len(DMS->DMS_CHVENT))+cEntida))
                T146AtuDMS(cIdRot,cChvEnt,cEntida,'4','',.T.,nSeqRot)  //Inicia como 4-Falha e conforme incluindo na programação altera-se para 2

                DbSelectArea(AllTrim(DMS->DMS_ENTIDA) )
                DbSetOrder(Val(DMS->DMS_INDENT))                
                If &(cEntida)->(DbSeek(DMS->DMS_CHVENT))
                    If cEntida == "DTC"
                        aAdd(aDocPrg,{  ''                 ,;  //Filial do Documento (DT6_FILDOC)
                                        ''                 ,;  //Documento (DT6_DOC)
                                        ''                 ,;  //Serie Documento (DT6_SERIE)
                                        DTC->DTC_NUMNFC    ,;  //Numero da Nota (DTC_NUMNFC)
                                        DTC->DTC_SERNFC    ,;  //Serie da Nota (DTC_SERNFC)
                                        DTC->DTC_FILORI    ,;  //Filial de Origem (DTC_FILORI)
                                        DTC->DTC_LOTNFC    ,;  //Numero do Lote (DTC_LOTNFC)
                                        ''                 ,;  //Codigo do Cavalo, caso for uma programação para Reboque
                                        .F.                ,;  //Controle interno da rotina TMSA146, enviar sempre F   
                                        DTC->(RECNO())     ,;  //Recno DTC 
                                        StrZero(nSeqDoc,TamSX3('DUD_SEQUEN')[1])  })  //Sequencia Docto na Viagem
                                        

                        T146SetDat(DTC->DTC_PRVENT,DTC->DTC_EMINFC,@dDtPrevIni,@dDtPrevFim,@dDtEmiIni,@dDtEmiFim)
                    ElseIf cEntida == "DT5"
                        aAdd(aDocPrg,{  DT5->DT5_FILDOC ,;  //Filial do Documento (DT6_FILDOC)
                                        DT5->DT5_DOC    ,;  //Documento (DT6_DOC)
                                        DT5->DT5_SERIE  ,;  //Serie Documento (DT6_SERIE)
                                        ''              ,;  //Numero da Nota (DTC_NUMNFC)
                                        ''              ,;  //Serie da Nota (DTC_SERNFC)
                                        ''              ,;  //Filial de Origem (DTC_FILORI)
                                        ''              ,;  //Numero do Lote (DTC_LOTNFC)
                                        ''              ,;  //Codigo do Cavalo, caso for uma programação para Reboque
                                        .F.             ,;  //Controle interno da rotina TMSA146, enviar sempre F
                                        DT5->(RECNO())  ,; //Recno DT6
                                        StrZero(nSeqDoc,TamSX3('DUD_SEQUEN')[1]) })  //Sequencia Docto na Viagem
                        
                        T146SetDat(DT5->DT5_DATPRV,DT5->DT5_DATSOL,@dDtPrevIni,@dDtPrevFim,@dDtEmiIni,@dDtEmiFim)
                    Else
                        aAdd(aDocPrg,{  DT6->DT6_FILDOC ,;  //Filial do Documento (DT6_FILDOC)
                                        DT6->DT6_DOC    ,;  //Documento (DT6_DOC)
                                        DT6->DT6_SERIE  ,;  //Serie Documento (DT6_SERIE)
                                        ''              ,;  //Numero da Nota (DTC_NUMNFC)
                                        ''              ,;  //Serie da Nota (DTC_SERNFC)
                                        ''              ,;  //Filial de Origem (DTC_FILORI)
                                        ''              ,;  //Numero do Lote (DTC_LOTNFC)
                                        ''              ,;  //Codigo do Cavalo, caso for uma programação para Reboque
                                        .F.             ,;  //Controle interno da rotina TMSA146, enviar sempre F
                                        DT6->(RECNO())  ,; //Recno DT6
                                        StrZero(nSeqDoc,Len(DUD->DUD_SEQUEN))  })  //Sequencia Docto na Viagem
                        
                        T146SetDat(DT6->DT6_PRZENT,DT6->DT6_DATEMI,@dDtPrevIni,@dDtPrevFim,@dDtEmiIni,@dDtEmiFim)
                    EndIf
                EndIf

            EndIf
        EndIf
    Next n1
Next n

If Len(aDocPrg) > 0
    If !lDataPrev                        
        dDtPrevIni:= cToD('')
        dDtPrevFim:= dDataBase
    EndIf
    
    //-- Chama rotina de Programacao de Carregamento 
    //Conout('Processando Programação de Carregamento') 
    TmsLogMsg("INFO","Processando Programação de Carregamento")   
    lRet:= T146GerPrg(cVeiculo,aDocPrg,dDtPrevIni,dDtPrevFim,dDtEmiIni,dDtEmiFim,cIdRot,dDtIniRot,cHrIniRot,dDtFimRot,cHrFimRot)

    If lRet    
        TmsLogMsg("INFO","Programação de Carregamento processada com sucesso'")   
        //Conout('Programação de Carregamento processada com sucesso')   
    Else
        TmsLogMsg("WARN","Falha no processamento da Programação de Carregamento")   
        //Conout('Falha no processamento da Programação de Carregamento')   
    EndIf
EndIf

lDataPrev:= .T.
FwFreeArray(aDocPrg)
Return lRet

/*/{Protheus.doc} T146GerPrg()
Rotina para gerar a Programação de Carregamento
@author     Katia
@since      27/08/2021
@version    12.1.35
@return     lRet
/*/
Function T146GerPrg(cCodVei,aDoctosPrg,dDtPrevIni,dDtPreFim,dDtEmiIni,dDtEmiFim,cIdRot,dDtIniRot,cHrIniRot,dDtFimRot,cHrFimRot)

Local lRet       := .F.
Local nOperacao  := 3
Local cRota      := ""

//--- Variaveis que devem ser do retorno da TPR
Default cCodVei      := " "
Default aDoctosPrg   := {}
Default dDtPrevIni   := CtoD('')
Default dDtPreFim    := CtoD('')
Default dDtEmiIni    := CtoD('')
Default dDtEmiFim    := CtoD('')
Default dDtIniRot    := cTod('')
Default cHrIniRot    := ""
Default dDtFimRot    := cTod('')
Default cHrFimRot    := ""

If FindFunction("TMSAC20Rot") .And. DLV->( FieldPos("DLV_ROTA")) > 0  
    cRota:= TMSAC20Rot("2")  //Busca a Rota informada na Conf.TPR
EndIf

DA3->(dbSetOrder(1))
If DA3->(MsSeek(xFilial('DA3')+cCodVei))  
			
    //Inicializa os Parametros da Programação 
    T153GSetPa(.F.,DA3->DA3_PLACA,dDtPrevIni,dDtPreFim,dDtEmiIni,dDtEmiFim)

    lRet:= TMSA146(.T., aDoctosPrg, nOperacao, cRota, cIdRot, dDtIniRot, cHrIniRot, dDtFimRot, cHrFimRot)  

    //--- Restaura os Parametros da Programação
    RestPer146()

EndIf
Return lRet 

/*/{Protheus.doc} T146DocRej()
Lista os Lotes dos Doctos rejeitados que possuem uma NF Pendente/processada
@author     Katia
@since      27/08/2021
@version    12.1.35
@return     lRet
/*/
Function T146DocRej(cFilRot,cNumRot)
Local cQuery   := ""
Local cAliasQry:= GetNextAlias()
Local nPosIni  := TamSx3("DTC_FILIAL")[1] + 1
Local nTamLot  := TamSx3("DTC_FILORI")[1] + TamSx3("DTC_LOTNFC")[1]
Local lRet     := .T.

Default cFilRot:= ""
Default cNumRot:= ""

//Composição do campo DMS_CHVENT
//DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC
//Composição do Identifier enviado para a TPR
//NFC|DTC|DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC

//--- Lista as NFs com status 'Rejeitado' que estão em um mesmo Lote com NFs com status 'processado'
//--- Exemplo:
//--- Lote A1 - NF 1010  - Retorno TPR Rejeitado
//--- Lote A1 - NF 2020  - Retorno TPR Processado
//--- Lote A1 - NF 3030  - Retorno TPR Rejeitado
//--- Será incluido um novo Lote (A2) com as novas Rejeitas (NF 1010 e NF 3030) e a Qtde de Nfs digitadas no Lote A1 será atualizada.

cQuery := " SELECT SUBSTRING(DMS.DMS_CHVENT," + Alltrim(Str(nPosIni)) + ", " + Alltrim(Str(nTamLot)) + ")  LOTE, COUNT(*)  NREG FROM " + RetSqlName("DMS") + " DMS "
cQuery += " WHERE DMS.DMS_FILIAL = '" + xFilial('DMS') + "' "
cQuery += " AND DMS.DMS_ENTIDA = 'DTC' "
cQuery += " AND DMS.DMS_FILROT = '" + cFilRot + "' "
cQuery += " AND DMS.DMS_IDROT  = '" + cNumRot + "' "  
cQuery += " AND DMS.DMS_STATUS = '2' "   //Rejeitado
cQuery += " AND DMS.DMS_CHVEXT = ' ' "
cQuery += " AND DMS.D_E_L_E_T_ = ' ' "
cQuery += " AND SUBSTRING(DMS.DMS_CHVENT," + Alltrim(Str(nPosIni)) + ", " + Alltrim(Str(nTamLot)) + ") "
cQuery += "  IN (SELECT SUBSTRING(DMS1.DMS_CHVENT," + Alltrim(Str(nPosIni)) + ", " + Alltrim(Str(nTamLot)) + ")  FROM  "
cQuery +=           RetSqlName("DMS") + " DMS1 "
cQuery += "         WHERE DMS1.DMS_FILIAL = '" + xFilial('DMS') + "' "
cQuery += "         AND DMS1.DMS_ENTIDA = 'DTC' "
cQuery += "         AND DMS1.DMS_FILROT = '" + cFilRot + "' "
cQuery += "         AND DMS1.DMS_IDROT  = '" + cNumRot + "' "  
cQuery += "         AND DMS1.DMS_STATUS <> '2' "   //Rejeitado
cQuery += "         AND DMS1.DMS_CHVEXT = ' ' "
cQuery += "         AND DMS1.D_E_L_E_T_ = ' ' ) "
cQuery += " GROUP BY SUBSTRING(DMS.DMS_CHVENT," + Alltrim(Str(nPosIni)) + ", " + Alltrim(Str(nTamLot)) + ") "
cQuery += " ORDER BY SUBSTRING(DMS.DMS_CHVENT," + Alltrim(Str(nPosIni)) + ", " + Alltrim(Str(nTamLot)) + ") "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
While (cAliasQry)->(!Eof())

    //--- Gera o Lote    
    lRet:= T146GerLot((cAliasQry)->LOTE, (cAliasQry)->NREG, cFilRot,cNumRot)
    If !lRet
        Exit
    EndIf

    (cAliasQry)->(DbSkip())
EndDo

Return lRet

/*/{Protheus.doc} T146GerLot()
Gera um Novo Lote para os Doctos Rejeitados 
@author     Katia
@since      27/08/2021
@version    12.1.35
@return     lRet
/*/
Static Function T146GerLot(cLote, nReg, cFilRot, cNumRot)
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local nPosIni   := TamSx3("DTC_FILIAL")[1] + 1
Local nTamLot   := TamSx3("DTC_FILORI")[1] + TamSx3("DTC_LOTNFC")[1]
Local nQtdDig   := 0
Local cLoteOri  := ""
Local cNewLote  := ""
Local lRet      := .F.

Default cLote   := ""
Default cFilRot := ""
Default cIdRot  := ""
Default nReg    := 0

//--- Inclui um Novo Lote
cNewLote:= T146IncLot(nReg)
If !Empty(cNewLote)
    lRet:= .T.

    cQuery := " SELECT DMS.R_E_C_N_O_  NRECNO FROM " + RetSqlName("DMS") + " DMS "
    cQuery += " WHERE DMS.DMS_FILIAL = '" + xFilial('DMS') + "' "
    cQuery += " AND DMS.DMS_ENTIDA = 'DTC' "
    cQuery += " AND DMS.DMS_FILROT = '" + cFilRot + "' "
    cQuery += " AND DMS.DMS_IDROT  = '" + cNumRot + "' "  
    cQuery += " AND DMS.DMS_STATUS = '2' "   //Rejeitado
    cQuery += " AND DMS.DMS_CHVEXT = ' ' "
    cQuery += " AND DMS.D_E_L_E_T_ = ' ' "
    cQuery += " AND SUBSTRING(DMS.DMS_CHVENT," + Alltrim(Str(nPosIni)) + ", " + Alltrim(Str(nTamLot)) + ") = '" + cLote + "' "
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
    While (cAliasQry)->(!Eof())

        DMS->(DBGoTo((cAliasQry)->NRECNO))
        
        //--- Atualiza Nro do Lote da NF
        DTC->(DBSetOrder(Val(DMS->DMS_INDENT)))
        If DTC->(DBSeek(DMS->DMS_CHVENT))    
            nQtdDig++
            cLoteOri:= DTC->DTC_LOTNFC

            Reclock("DTC",.F.)
            DTC->DTC_LOTNFC:= cNewLote
            DTC->(MsUnLock())   

            //-- Atualiza Chave Externa da DMS com o Nro do Lote
            T146GrvExt(DTC->(DTC_FILIAL+DTC_FILORI+DTC_LOTNFC), '2', 'DTP')
           
        EndIf

        (cAliasQry)->(DbSkip())
    EndDo

    If nQtdDig
        //Atualiza Qtde do Lote de Origem
        T146AtuLot(cLoteOri, nQtdDig, .F.)

        //Atualiza Qtde do Novo Lote
        T146AtuLot(cNewLote, nQtdDig, .T.)
    EndIf
EndIf

Return lRet

/*/{Protheus.doc} T146IncLot()
Inclusão de Lote
@author     Katia
@since      19/09/2021
@version    12.1.35
@return     cRet
/*/
Function T146IncLot(nReg)
Local cRet   := ""
Local aCab   := {}

Default nReg := 0

lMsErroAuto := .F.

AAdd(aCab,{'DTP_QTDLOT', nReg ,Nil})
AAdd(aCab,{'DTP_QTDDIG', 0    ,Nil})
AAdd(aCab,{'DTP_STATUS','1'   ,Nil})	//-- Em aberto

MsExecAuto({|x,y|cRet := TmsA170(x,y)},aCab,3)
If lMsErroAuto
    cRet    := ""
EndIf

Return cRet

/*/{Protheus.doc} T146AtuLot()
Atualiza Quantidade de Notas no Lote Atual e Novo
@author     Katia
@since      27/08/2021
@version    12.1.35
@return     lRet
/*/
Function T146AtuLot(cLote, nQtdDig, lNewLote)

Default cLote     := ""
Default nQtdDig   := 0
Default lNewLote  := .F.    //Novo Lote

DTP->(DbSetOrder(1))
If DTP->(DbSeek(xFilial('DTP') + cLote))
    Reclock('DTP',.F.)
    
    If lNewLote
	    DTP->DTP_QTDDIG := nQtdDig
        If DTP->DTP_QTDLOT == nQtdDig
            DTP->DTP_STATUS := '2' //Digitado
        EndIf
    Else
        DTP->DTP_QTDLOT := DTP->DTP_QTDLOT - nQtdDig
	    DTP->DTP_QTDDIG := DTP->DTP_QTDDIG - nQtdDig
    EndIf

    DTP->(MsUnLock())
EndIf

Return 

/*/{Protheus.doc} T146AtuDMS()
Função para atualizar o Status da DMS
@author     Katia
@since      27/08/2021
@version    12.1.35
@param      cIdRot,cChvEnt,cStatus
@return     lRet
/*/
Function T146AtuDMS(cIdRot,cChvEnt,cEntida,cStatus,cMsgRejeit,lPosDMS,nSeqRot) 
Local lRet        := .T.

Default cIdRot    := ""
Default cChvEnt   := ""
Default cEntida   := ""
Default cStatus   := ""   //1-Pendente,2-Rejeitado,3-Processado,4-Processado com Erro
Default cMsgRejeit:= ""
Default lPosDMS   := .F.  //Registro DMS posicionado
Default nSeqRot   := 9999 //Somente grava o DMS_SEQROT se passar o nSeqRot

If !lPosDMS
    DMS->(DbSetOrder(4))  
    If !DMS->(DbSeek(xFilial("DMS")+cIdRot+Padr(cChvEnt,Len(DMS->DMS_CHVENT))+cEntida))
        lRet:= .F.
    EndIf
EndIf

If lRet
    Reclock("DMS",.F.)
    DMS->DMS_STATUS:= cStatus
    If nSeqRot <> 9999
        DMS->DMS_SEQROT:= nSeqRot
    EndIf
    If !Empty(cMsgRejeit)
        DMS->DMS_MSGERR:= cMsgRejeit
    EndIf
    DMS->(MsUnLock())
EndIf

Return lRet

/*/{Protheus.doc} T146SetDat()
Função para setar as Datas de Previsaõ de Entrega e Emissão para
filtro da Programação de Carregamento
@author     Katia
@since      19/09/2021
@version    12.1.35
@return     Nil
---*/
Static Function T146SetDat(dDtPrvent, dDtEmiNFC, dDtPrevIni, dDtPrevFim, dDtEmiIni, dDtEmiFim)

//---- Data de Previsao
If Empty(dDtPrvent)
    lDataPrev:= .F.  //Seta que Docto não tem Data de Previsão de Entrega
EndIf

If Empty(dDtPrevIni)
    dDtPrevIni:= dDtPrvent
    dDtPrevFim:= dDtPrvent
Else    
    If dDtPrvent < dDtPrevIni
        dDtPrevIni:= dDtPrvent 
    Else
        If dDtPrvent > dDtPrevFim
            dDtPrevFim:= dDtPrvent 
        EndIf
    EndIf
EndIf

//---- Data de Emissao
If Empty(dDtEmiIni)
    dDtEmiIni:= dDtEmiNFC 
    dDtEmiFim:= dDtEmiNFC 
Else    
    If dDtEmiNFC < dDtEmiIni
        dDtEmiIni:= dDtEmiNFC 
    ElseIf dDtEmiNFC > dDtEmiFim
        dDtEmiFim:= dDtEmiNFC 
    EndIf
EndIf

Return

/*/{Protheus.doc} T146AtuDMR()
Função para atualizar o Status da DMR
@author     Katia
@since      27/08/2021
@version    12.1.35
@param      cIdRot,cStatus
@return     lRet
---*/
Function T146AtuDMR(cIdRot,cStatus) 

Default cIdRot := ""
Default cStatus:= ""   //1-Pendente,2-Processado

DMR->(DbSetOrder(1))  
If DMR->(DbSeek(xFilial("DMR")+cIdRot))
    Reclock("DMR",.F.)
    DMR->DMR_STATUS:= cStatus
    DMR->(MsUnLock())
EndIf

Return Nil

/*/{Protheus.doc} T146GrvExt()
Função para gravar dados da chave externa
@author     Katia
@since      27/08/2021
@version    12.1.35
@param      cIdRot,cStatus
@return     lRet
---*/
Function T146GrvExt(cChvExt, cIndExt, cEntExt,cStatus)

Default cStatus:= ""

    Reclock("DMS",.F.)
    DMS->DMS_CHVEXT:= cChvExt
    DMS->DMS_INDEXT:= cIndExt
    DMS->DMS_ENTEXT:= cEntExt
    If !Empty(cStatus)
        DMS->DMS_STATUS:= cStatus
    EndIf
    DMS->(MsUnLock())

Return

/* {Protheus.doc} T146PosDMS
Posiciona o Registro de Roteirização DMS e atualiza Chave Externa
@author		Katia
@since		21/09/2021
@version	12.1.35
---*/
Function T146PosDMS(oMdlGridDoc,cChvExt,cIdRot)
Local  aRet  := {}
Local cStatus:= '3'  //Processado

Default oMdlGridDoc:= Nil
Default cChvExt    := ""
Default cIdRot     := ""

If !Empty(oMdlGridDoc) .And. !Empty(cChvExt)
    aRet:= T146IdDMS(oMdlGridDoc)
    If Len(aRet) > 0 
        DMS->(DbSetOrder(4))  
        If DMS->(DbSeek(xFilial("DMS")+cIdRot+Padr(aRet[1],Len(DMS->DMS_CHVENT))+aRet[2]))
            T146GrvExt(cChvExt, '1', 'DF8', cStatus )
        EndIf
    EndIf
EndIf

FwFreeArray(aRet)
Return

/* {Protheus.doc} T146IdDMS
Prepara o ID para validação da DMS
@author		Katia
@since		09/09/2021
@version	12.1.35	
---*/
Function T146IdDMS(oMdlGridDoc,cFilDoc,cDoc,cSerie,nRecnoDTC)
Local aRet := {}
Local aArea:= GetArea()

Default oMdlGridDoc:= Nil   //Programação de Carregamento (TMSA146)
Default cFilDoc    := ""
Default cDoc       := ""
Default cSerie     := ""
Default nRecnoDTC  := 0
Default nRecnoDT6  := 0

If !Empty(oMdlGridDoc)  //Rotina Prog. Carregamento
	aRet:= T146Ident(oMdlGridDoc:GetValue('T01_FILORI'), ;
						oMdlGridDoc:GetValue('T01_LOTNFC') ,;    
						oMdlGridDoc:GetValue('T01_CLIREM'),;    
						oMdlGridDoc:GetValue('T01_LOJREM'),;    
						oMdlGridDoc:GetValue('T01_CLIDES'),;    
						oMdlGridDoc:GetValue('T01_LOJDES'),; 
						oMdlGridDoc:GetValue('T01_SERVIC'),;   
						oMdlGridDoc:GetValue('T01_CODPRO'),;                          
						oMdlGridDoc:GetValue('T01_NUMNFC'),;    
						oMdlGridDoc:GetValue('T01_SERNFC'),;
						oMdlGridDoc:GetValue('T01_FILDOC'),;
						oMdlGridDoc:GetValue('T01_DOC') ,;
						oMdlGridDoc:GetValue('T01_SERIE'))
ElseIf !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
   
    aRet:= T146Ident('',;  
                     '',;    
                     '',;    
                     '',;    
                     '',;    
                     '',; 
                     '',;   
                     '',;                          
                     '',;    
                     '',;
                     cFilDoc,;
                     cDoc,;
                     cSerie )
                     
ElseIf nRecnoDTC > 0
    DTC->(dbGoto(nRecnoDTC))
    aRet:= T146Ident(DTC->DTC_FILORI, ;  
                     DTC->DTC_LOTNFC,;    
                     DTC->DTC_CLIREM,;    
                     DTC->DTC_LOJREM,;    
                     DTC->DTC_CLIDES,;    
                     DTC->DTC_LOJDES,; 
                     DTC->DTC_SERVIC,;   
                     DTC->DTC_CODPRO,;                          
                     DTC->DTC_NUMNFC,;    
                     DTC->DTC_SERNFC,;
                     DTC->DTC_FILDOC,;
                     DTC->DTC_DOC ,;
                     DTC->DTC_SERIE )
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return aRet

/*/{Protheus.doc} T146GetChv()
Retorna a Entidade e Chave do Identifier
@author		Katia
@since		27/09/2021
@version	12.1.35
@return 	
---*/
Function T146GetChv(cIdentifier, cChvEnt, cEntida ) 
Local aChvEnt      := {}
Default cIdentifier:= ""

If !Empty(cIdentifier)
    aChvEnt    := aClone( StrTokArr(cIdentifier,"|" ) )
    cEntida    := aChvEnt[2]
    cChvEnt    := aChvEnt[3]
EndIf

FwFreeArray(aChvEnt)
Return

/*/{Protheus.doc} T146BCons()
Painel Integração Planejamento Rotas (TPR)
@author  	Katia
@version 	12.1.35
@since 		08/10/2021
@return 	
---*/
Function T146PnlTPR(cAlias,nRecno,nOpcx)
Local cFilRot := ""
Local cIdRot  := ""
Local nSeqRot := 0
Local cFiltro := ""
Local aArea   := GetArea()
Local lRet    := .T.

TMSAC24Id( cAlias, nRecno, nOpcx, @cFilRot, @cIdRot, @nSeqRot ) 

If !Empty(cIdRot)
    cFiltro:= "DMR_FILROT == '" + cFilRot + "' .AND. DMR_IDROT == '" + cIdRot  + "' "
    TMSAC19(cFiltro)
Else
	Help(" ",1,"REGNOIS")
    lRet:= .F.
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return lRet

/*/{Protheus.doc} T146CanRot()
Função para Cancelar a Roteirização via Programaçao de Carregamento
@param      cFilOri, cNumPrg, cSeqPrg
@author     Katia
@since      24/11/2021
@version    12.1.35
@return     lRet
/*/
Function T146CanRot(cFilOri, cNumPrg, cSeqPrg)
Local aArea     := GetArea()
Local cIdRot    := ""
Local oModel    := Nil
Local oMdFldDMR := Nil
Local oMdGrdDMS := Nil
Local nX        := 0
Local aErrors   := {}
Local cChvExt   := ""
Local lCanDMR   := .T.
Local lRet      := .T.

Default cFilOri := ""
Default cNumPrg := ""
Default cSeqPrg := ""

//-- Busca o Nro da Roteirização da Programação
cChvExt:= xFilial("DF8") + cFilOri + cNumPrg + cSeqPrg
cChvExt:= PadR(cChvExt, Len(DMS->DMS_CHVEXT))

cIdRot:= T146VldTPR('DF8',cFilOri, cNumPrg, cSeqPrg) 
If !Empty(cIdRot)
    DMR->(DbSetOrder(1))
    If DMR->(DbSeek(xFilial("DMR") + cIdRot))

		oModel := FWLoadModel( 'TMSAC19' )
		oModel:SetOperation( 4 )
		oModel:Activate()

		oMdFldDMR:= oModel:GetModel("MdFieldDMR")
		oMdGrdDMS:= oModel:GetModel("MdGridDMS")

	    For nX := 1 To oMdGrdDMS:Length()
	        oMdGrdDMS:GoLine(nX)
        	If !oMdGrdDMS:IsDeleted() .And. !oMdGrdDMS:IsEmpty()
                If oMdGrdDMS:GetValue("DMS_ENTEXT")  == "DF8" .And. ;
                    oMdGrdDMS:GetValue("DMS_CHVEXT")  == cChvExt
                    oMdGrdDMS:LoadValue("DMS_STATUS", '5' )  //Cancelado
                Else    
                    //Nao cancela a DMR, pois existem outros doctos na mesma roteirização com outra Programação
                    lCanDMR:= .F.                           
                EndIf
            EndIf
        Next nX

        If lCanDMR
            oMdFldDMR:LoadValue("DMR_STATUS", '3' )  //Cancelado
        EndIf

		lRet := oModel:VldData()
		If lRet 
			oModel:CommitData()
		Else
			Aadd(aErrors,  oModel:GetErrorMessage()[6] )
		EndIf
		oModel:Destroy()
		oModel:= Nil	

        If lRet
		    //---- Atualiza DLU para cancelado
		    lRet:= TMSAC19DLU(cIdRot)
	    EndIf

    EndIf
EndIf    

RestArea(aArea)
FwFreeArray(aArea)
Return lRet
