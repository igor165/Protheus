#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#Include "TryException.ch"
/* Igor Gomes Oliveira 
    P.E     : MT131WF - Customiza��o de WorkFlow
    Rotina  : MATA131.PRW
    Data    : 22/03/2023  
     */
User Function MT131WF(aSolicitac)

    local aArea         := GetArea()
    Local i,j,x
    Local _cQry         := ''
    Local cMailSend     := ''
    Local cWFID         := ''
    Local cChave        := ''
    Local _cCODCOMP     := Posicione("SY1", 3, xFilial("SY1") + RetCodUsr(), "Y1_COD")
    Local _cGRUPCOM     := SY1->Y1_GRUPCOM
    Local lEnvia        := .f.
    Local aCotacao      := {}//Enviado como chave para VACOMR10
    Local aImprimir     := {}//Array de dados para VACOMR10
    Local aDados        := {} // dados gerais
    Local cForMail      := ''
    Private cTimeIni	:= Time()
    Private cMessage    := ""
    private cServPath   := "\cotacoes\"
    Private cLocalPath  := "C:\TOTVS_RELATORIOS\COTACOES\"
    private cOperacao   := "MATA131"

    default aSolicitac := ParamIXB[2] // ParamIXB[1] � a mesma coisa que ParamIXB[2][1]
    
    if Type("oMainWnd") == 'U' .or. Aviso("Email","Deseja Enviar email de cota��o para o Fornecedor? ",{"Sim","N�o"}) == 1
        
        DbSelectArea("SY1")
        DbSetOrder(3) // Y1_FILIAL+Y1_USER
        DbSeek(xFilial("SY1")+__cUserID)

        DbSelectArea("SC8")
        DbSetOrder(1) // C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD

        DbSelectArea("SC1")
        DbSetOrder(1) // C1_FILIAL+C1_NUM+C1_ITEM

        DbSelectArea("SA2")
        DbSetOrder(1) // A2_FILIAL+A2_COD+A2_LOJA\
        
        DbSelectArea("SB1")
        DbSetorder(1) // B1_FILIAL+B1_COD
        
        cWFID := u_GetWFID()

        begin transaction

            nLen := Len(aSolicitac) 
            for i := 1 to nLen

                _cQry := " select SC8.C8_FILIAL" + CRLF
                _cQry += " , SC8.C8_NUM" + CRLF
                _cQry += " , SC8.C8_FORNECE" + CRLF
                _cQry += " , SC8.C8_LOJA" + CRLF
                _cQry += " , SC8.C8_NUMPRO" + CRLF
                _cQry += " , SC8.C8_FILENT" + CRLF
                _cQry += " , SC8.C8_FORMAIL" + CRLF
                _cQry += " , ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), C8_MSGMAIL)),'') AS MSGMAIL" + CRLF
                _cQry += " , SC1.C1_ITEM" + CRLF
                _cQry += " , SC1.C1_NUM" + CRLF
                _cQry += " , SC1.C1_DATPRF" + CRLF
                _cQry += " , SC1.C1_EMISSAO" + CRLF
                _cQry += " , SC1.C1_UM" + CRLF
                _cQry += " , SC1.C1_DESCRI" + CRLF
                _cQry += " , SC1.C1_PRODUTO" + CRLF
                _cQry += " , SC1.C1_QUANT" + CRLF
                _cQry += " , SC1.C1_ITEM" + CRLF
                _cQry += " , SA2.A2_NOME" + CRLF
                _cQry += " , SA2.A2_EST" + CRLF
                _cQry += " , SA2.A2_COD_MUN" + CRLF
                _cQry += " , SA2.A2_END" + CRLF
                _cQry += " , SA2.A2_TEL" + CRLF
                _cQry += " , SA2.A2_FAX" + CRLF
                _cQry += " , SA2.A2_CONTATO" + CRLF
                _cQry += " , SA2.A2_MUN" + CRLF
                _cQry += " , SA2.A2_CGC" + CRLF
                _cQry += " , SA2.A2_CGC" + CRLF
                _cQry += " , SA2.A2_EMAIL" + CRLF
                _cQry += " , SB1.B1_DESC" + CRLF
                _cQry += " , SC8.R_E_C_N_O_ C8_RECNO" + CRLF
                _cQry += " , SC1.R_E_C_N_O_ C1_RECNO" + CRLF
                _cQry += " , SA2.R_E_C_N_O_ A2_RECNO" + CRLF
                _cQry += " from " + RetSqlName("SC8") + " SC8" + CRLF 
                _cQry += " join " + RetSqlName("SC1") + " SC1" + CRLF 
                _cQry += " on SC1.C1_FILIAL  = '" + xFilial("SC1") + "'" + CRLF 
                _cQry += " and SC1.C1_NUM     = SC8.C8_NUMSC" + CRLF 
                _cQry += " and SC1.C1_ITEM    = SC8.C8_ITEMSC" + CRLF 
                _cQry += " and SC1.D_E_L_E_T_ = ' '" + CRLF 
                _cQry += " join " + RetSqlName("SA2") + " SA2" + CRLF 
                _cQry += " on SA2.A2_FILIAL  = '" + xFilial("SA2") + "'" + CRLF 
                _cQry += " and SA2.A2_COD     = SC8.C8_FORNECE" + CRLF 
                _cQry += " and SA2.A2_LOJA    = SC8.C8_LOJA" + CRLF 
                _cQry += " and SA2.D_E_L_E_T_ = ' '" + CRLF 
                _cQry += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON C1_PRODUTO = B1_COD " + CRLF 
                _cQry += " AND SB1.D_E_L_E_T_ = '' " + CRLF 
                _cQry += " where SC8.C8_FILIAL  = '" + xFilial("SC8") + "'" + CRLF 
                _cQry += " and " + Iif( ValType(aSolicitac[i]) == 'C', "SC8.C8_NUM = '" + aSolicitac[i] + "'" , " SC8.C8_NUM = '" + aSolicitac[i][1] + "' ")+ CRLF 
                _cQry += " and SC8.D_E_L_E_T_ = ' '" + CRLF
                _cQry += " order by SC8.C8_FILIAL, SC8.C8_NUM, SC8.C8_FORNECE, SC8.C8_LOJA, SC8.C8_ITEM"
                
                    //" and " + Iif( ValType(aSolicitac[i]) == 'C', "SC8.C8_NUM = '" + aSolicitac[i] + "'" , " SC8.C8_NUM = '" + aSolicitac[i][1] + "' and SC8.C8_FORNECE+SC8.C8_LOJA = '" + aSolicitac[i][2] + "' and SC8.C8_NUMPRO = '" + aSolicitac[i][3] + "'" ) +;
                if cUserName $ 'Administrador,ioliveira'
                    MemoWrite("C:\totvs_relatorios\" +"MT131WF" + ".sql" , _cQry)
                endif

                DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(_cQry)), "TMPSC8", .f., .f.)

                while !TMPSC8->(Eof())

                    if TMPSC8->C8_FILIAL+TMPSC8->C8_NUM+TMPSC8->C8_FORNECE+TMPSC8->C8_LOJA != cChave

                        cMessage := iif(Val(SubStr(Time(),1,2))<12,"Bom dia!! <br>",iif(Val(SubStr(Time(),1,2))>18,"Boa Noite!! <br>","Boa Tarde!! <br>")) + CRLF 
                        cMessage += "<br>"  + CRLF
                        cMessage += "Segue em anexo, a solicita��o de Or�amento! <br>" + CRLF
                        cMessage += "Por Gentileza informar Pre�o, Forma de Pagamento, Frete e Prazo de Entrega.<br>" + CRLF
                        cMessage += " <br>" + CRLF
                        if !Empty(TMPSC8->MSGMAIL)
                            For x := 1 to len(TMPSC8->MSGMAIL)
                                if AllTrim(SubStr(TMPSC8->MSGMAIL,x,5)) != "."
                                    cMessage += SubStr(TMPSC8->MSGMAIL,x,1)
                                else
                                    cMessage += ".<br>" + CRLF 
                                endif
                                if AllTrim(SubStr(TMPSC8->MSGMAIL,x,Len(TMPSC8->MSGMAIL))) == ""
                                    exit
                                endif
                            next x
                            cMessage += "<br>"  + CRLF
                        endif 
                        cMessage += "Desde j�,�agrade�o.<br>" + CRLF
                        cMessage += "<br>" + CRLF
                        cMessage += "Atenciosamente,<br>" + CRLF
                        cMessage += "<br>" + CRLF
                        cMessage += ALLTRIM(SY1->Y1_NOME) + "<br>" + CRLF
                        cMessage += ALLTRIM(SY1->Y1_TEL) + "<br>" + CRLF
                        cMessage += ALLTRIM(SY1->Y1_EMAIL) + "<br>" + CRLF
                        cMessage += "<br>" + CRLF
                        cMessage += "www.vistaalegre.agr.br" + CRLF

                        if Empty(aDados)
                            while !TMPSC8->(Eof())
                                aAdd(aDados,{TMPSC8->C1_ITEM,;      //01
                                            TMPSC8->B1_DESC,;       //02
                                            TMPSC8->C8_FILENT,;     //03
                                            TMPSC8->C8_FORNECE,;    //04
                                            TMPSC8->A2_NOME,;       //05
                                            TMPSC8->C1_PRODUTO,;    //06
                                            TMPSC8->C1_UM,;         //07
                                            TMPSC8->C1_QUANT,;      //08
                                            TMPSC8->C1_EMISSAO,;    //09
                                            TMPSC8->C8_NUM,;        //10
                                            TMPSC8->C1_NUM,;        //11
                                            TMPSC8->A2_END,;        //12
                                            TMPSC8->A2_MUN,;        //13
                                            TMPSC8->A2_EST,;        //14
                                            TMPSC8->A2_TEL,;        //15
                                            TMPSC8->A2_FAX,;        //16
                                            TMPSC8->A2_CONTATO,;    //17
                                            TMPSC8->A2_CGC,;        //18
                                            TMPSC8->C1_DATPRF,;     //19
                                            TMPSC8->A2_EMAIL,;      //20
                                            TMPSC8->C8_FILIAL,;     //21
                                            TMPSC8->C8_LOJA,;       //22
                                        })
                                TMPSC8->(DbSkip())
                            end
                            TMPSC8->(DBGoTop())
                        endif

                        if lEnvia .and. !Empty(cChave)
                            WFEnvCot( cChave + "_" + StrTran(cTimeIni,":","-",,), cForMail)
                        endif

                        lEnvia := .t.
                        
                        cChave    := TMPSC8->C8_FILIAL+TMPSC8->C8_NUM+TMPSC8->C8_FORNECE+TMPSC8->C8_LOJA
                        aCotacao  := {TMPSC8->C8_NUM,TMPSC8->C8_FORNECE,TMPSC8->C8_LOJA,TMPSC8->C8_NUMPRO}
                        aImprimir := {}

                        for j := 1 to len(aDados)
                            j:=1
                            if aDados[j] == nil 
                                exit
                            endif 
                            if cChave == aDados[j][21]+aDados[j][10]+aDados[j][04]+aDados[j][22]
                                aAdd(aImprimir,{ aDados[j][01],;    //01
                                                 aDados[j][02],;    //02
                                                 aDados[j][03],;    //03
                                                 aDados[j][04],;    //04
                                                 aDados[j][05],;    //05
                                                 aDados[j][06],;    //06
                                                 aDados[j][07],;    //07
                                                 aDados[j][08],;    //08
                                                 aDados[j][09],;    //09
                                                 aDados[j][10],;    //10
                                                 aDados[j][11],;    //12
                                                 aDados[j][12],;    //13
                                                 aDados[j][13],;    //14
                                                 aDados[j][14],;    //15
                                                 aDados[j][15],;    //16
                                                 aDados[j][16],;    //17
                                                 aDados[j][17],;    //18
                                                 aDados[j][18],;    //19
                                                 aDados[j][19],;    //20
                                                 aDados[j][20],;    //21
                                                 aDados[j][22],;    //22
                                                 cTimeIni,;         //23
                                                 })
                                aDel(aDados,j)
                            else
                                exit
                            endif
                        next j
        
                        SC8->(DbGoTo(TMPSC8->C8_RECNO))
                        SC1->(DbGoTo(TMPSC8->C1_RECNO))
                        SA2->(DbGoTo(TMPSC8->A2_RECNO))

                        if TMPSC8->C8_FORMAIL != SA2->A2_EMAIL
                            RecLock("SA2",.F.)
                                SA2->A2_EMAIL := TMPSC8->C8_FORMAIL
                            MsUnlock()
                        endif

                        if Empty(SA2->A2_EMAIL)
                            if Empty(TMPSC8->C8_FORMAIL)
                                ShowHelpDlg("WFPROC01", {"O e-mail do fornecedor n�o est� preenchido."}, 1, {"Por favor, preencha o e-mail do fornecedor "+SA2->A2_COD+" e use a rotina de o reenvio da cota��o em atualiza��o de cota��es."}, 1 )
                                lEnvia := .f.
                            else
                                RecLock("SA2",.F.)
                                    SA2->A2_EMAIL := TMPSC8->C8_FORMAIL
                                MsUnlock()
                            ENDIF 
                        endif
                        
                        cForMail := TMPSC8->C8_FORMAIL

                        if lEnvia
                            U_VACOMR10(aCotacao,cTimeIni,aImprimir)
                            
                            /* Mb */
                            RecLock("SC1", .f.)
                                SC1->C1_CODCOMP := _cCODCOMP
                                SC1->C1_GRUPCOM := _cGRUPCOM
                            SC1->(MsunLock())
                            
                            RecLock('SC8', .f.)
                            SC8->C8_WFCO   := "1"
                            if Empty(SC8->C8_WFDT)
                                SC8->C8_WFDT   := dDataBase
                            endif

                            SC8->C8_GRUPCOM := _cGRUPCOM 
                            SC8->C8_CODCOM  := _cCODCOMP
                            
                            if empty(SC8->C8_WFEMAIL)
                                if cUsername == "Administrador"
                                    //cMailSend :=  "igor.oliveira@vistaalegre.agr.br"
                                    cMailSend :=  GetMV("MV_RELACNT")
                                else
                                    PswOrder(1)
                                    PswSeek(__cUserId)
                                    //cMailSend :=  "igor.oliveira@vistaalegre.agr.br"
                                    cMailSend := Iif(Empty(SY1->Y1_EMAIL), PswRet(1)[1][14], AllTrim(SY1->Y1_EMAIL))
                                endif
                            endif
                            
                            SC8->C8_WFID := cWFID
                            
                            MsUnlock()
                        
                    else
                        SC8->(DbGoTo(TMPSC8->C8_RECNO))
                        SC1->(DbGoTo(TMPSC8->C1_RECNO))
                        SA2->(DbGoTo(TMPSC8->A2_RECNO))
                    endif
                
                    endif  
                    TMPSC8->(DbSkip())
                end        
                TMPSC8->(DbCloseArea())

                if lEnvia .and. !Empty(cChave)
                    WFEnvCot(/* aAnexos,  */cChave + "_" + StrTran(cTimeIni,":","-",,),cForMail)
                endif
            next i
        end transaction
    endif
    RestArea(aArea)
Return nil

Static Function WFEnvCot(/* aForm, */cChave,cForMail)

cMessage := StrTran(cMessage, "{%NUMCOT%}", SubStr(cChave, TamSX3("C8_FILIAL")[1]+1,TamSX3("C8_NUM")[1]))
u_EnvMail(cForMail/* "igor.oliveira@vistaalegre.agr.br" */, /*_cCc*/, /*_cBCC*/, "Solicita��o de proposta de cota��o V@ " + SubStr(cChave, 1, TamSX3("C8_FILIAL")[1] + TamSX3("C8_NUM")[1]) + ".", {cServPath + cChave + ".pdf"}, cMessage, /*_lAudit*/)

return nil
