#Include "GTPA818.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"

/*/
 * {Protheus.doc} EnvEmail()
 * Envia a DACTE por e-mail
 * type    Function
 * author  Eduardo Ferreira
 * since   04/12/2019
 * version 12.25
 * param   lRet
 * return  Não há
/*/ 
Function GTPA818(lRet)
Local aArea     := GetArea()
Local aAreaG99  := G99->(GetArea())
Local aParam    := {}
Local cTemp     := GetNextAlias() 
Local cCliRem   := ''
Local cCliDes   := ''
Local cTomador  := ''
Local cChvCte   := ''
Local cNroCte   := ''
Local cNomRem   := ''
Local cNomDes   := ''
Local cTitPadr  := STR0001 //'DACTE - Encomendas'
Local cCorPadr  := STR0002  //'Segue em anexo a DACTE referente a encomenda: '
Local cEmailLoc := SuperGetMV("MV_RELACNT")
Local cEmailPar := ''
Local cRootpath := GetSrvProfString("ROOTPATH","")
Local cCodUser  := RetCodUsr()
Local cTitEmail := ''
Local cCorEmail := ''
Local cStartPat := IIF(!IsBlind(), GetTempPath(.T.), "")
Local lOk      := .T.
Local lPEEnv   :=  ExistBlock("ENCDACTE") .AND. ExistBlock("G818EMAIL")
Local cExp := ''

if !IsBlind()
    If !lPEEnv
        FwAlertHelp(STR0004)  //'Ponto(s) de entrada nÃ£o compilado(s) para envio.(ENCDACTE e/ou G818EMAIL)'
        Return
    EndIf  
EndIf
 
If lRet 
    If G99->G99_STATRA == '2' 
        cCliRem   := G99->G99_CLIREM
        cCliDes   := G99->G99_CLIDES
        cTomador  := G99->G99_TOMADO 
        cChvCte   := G99->G99_CHVCTE
        cNroCte   := G99->G99_NUMDOC
        cNomRem   := AllTrim(Iif(cTomador == '0', Posicione('SA1', 1, xFilial('SA1')+cCliRem, 'A1_NOME' ), Posicione('SA1', 1, xFilial('SA1')+cCliDes, 'A1_NOME' )))
        cNomDes   := AllTrim(Iif(cTomador == '0', Posicione('SA1', 1, xFilial('SA1')+cCliRem, 'A1_NOME' ), Posicione('SA1', 1, xFilial('SA1')+cCliDes, 'A1_NOME' )))
        cEmailPar := AllTrim(Iif(cTomador == '0', Posicione('SA1', 1, xFilial('SA1')+cCliRem, 'A1_EMAIL'), Posicione('SA1', 1, xFilial('SA1')+cCliDes, 'A1_EMAIL')))

       
        ExecBlock("ENCDACTE", .f., .f., {cChvCte})
     

        If lOk .And. !ExistDir(Iif(RIGHT(cRootpath, 1) != '\', cRootpath+'\dacte', cRootpath+'dacte'))
            FwMakeDir(Iif(RIGHT(cRootpath, 1) != '\', cRootpath+'\dacte', cRootpath+'dacte'))
        EndIf 

        if !isBlind()
            If lOk
                CpyT2S(cStartPat+cChvCte+'.pdf', '\dacte')
            EndIf
        EndIf

        If lOk    
            aParam :=  ExecBlock("G818EMAIL", .f., .f., {cNomRem, cNomDes, cTomador, cTitEmail, cCorEmail, cChvCte, cNroCte})
        Endif
        if !isBlind()
            If lOk
                GTPXEnvMail(cEmailLoc, cEmailPar,,, Iif(Len(aParam) > 0, aParam[1, 1], cTitPadr), Iif(Len(aParam) > 0, aParam[1, 2], cCorPadr + cNroCte), {'dacte\'+cChvCte+'.pdf'})
            EndIf 
        Endif
    Else 
        FwAlertHelp(STR0003)  //'Somente CTE autorizado podem enviar DACTE.'
    EndIf 
Else
    Pergunte('GTPENCMAIL',.T.)

    cExp := '%'

    cExp += " AND G99.G99_DTEMIS >= '" + DTOS(MV_PAR01) + "'"
    cExp += " AND G99.G99_DTEMIS <= '" + DTOS(MV_PAR02) + "'"

    cExp += " AND G99.G99_CLIREM >= '" + MV_PAR03 + "'"
    cExp += " AND G99.G99_LOJREM >= '" + MV_PAR04 + "'"
    cExp += " AND G99.G99_CLIREM <= '" + MV_PAR05 + "'"
    cExp += " AND G99.G99_LOJREM <= '" + MV_PAR06 + "'"

    cExp += " AND G99.G99_CLIDES >= '" + MV_PAR07 + "'"
    cExp += " AND G99.G99_LOJDES >= '" + MV_PAR08 + "'"
    cExp += " AND G99.G99_CLIDES <= '" + MV_PAR09 + "'"
    cExp += " AND G99.G99_LOJDES <= '" + MV_PAR10 + "'"

    if !IsBlind()
        If MV_PAR11 == '1' //NÃO
            cExp += " AND G99.G99_ENVMAI IN (' ','1') " 
        Endif
    Endif

    cExp += '%'

    BeginSql Alias  cTemp
        SELECT 
            G99.G99_CLIREM,
            G99.G99_CLIDES,
            G99.G99_TOMADO,
            G99.G99_CHVCTE,
            G99.G99_NUMDOC,
            G99.R_E_C_N_O_ RECNOG99
        FROM %Table:G99% G99
            INNER JOIN %Table:GI6% GI6 ON GI6.GI6_FILIAL = G99.G99_FILIAL
                AND GI6.GI6_CODIGO = G99.G99_CODEMI
                AND GI6.%NotDel%
                %Exp:cExp%
            INNER JOIN %Table:G9X% G9X ON G9X.G9X_FILIAL = GI6.GI6_FILIAL
                AND G9X.G9X_CODGI6 = GI6.GI6_CODIGO
                AND G9X.G9X_CODUSR = %Exp:cCodUser%
                AND G9X.%NotDel%
        WHERE G99.G99_FILIAL = %xFilial:G99%
            AND G99.G99_STATRA  = '2'
            AND G99.G99_TIPCTE != '2'
            AND G99.G99_STAENC  = '1' OR G99.G99_STAENC = '2' OR G99.G99_STAENC = '3'
            AND G99.G99_CHVCTE != ''
            AND G99.%NotDel%            
    EndSql 

    While !(cTemp)->(Eof())   
        cCliRem   := (cTemp)->G99_CLIREM
        cCliDes   := (cTemp)->G99_CLIDES
        cTomador  := (cTemp)->G99_TOMADO
        cChvCte   := (cTemp)->G99_CHVCTE
        cNroCte   := (cTemp)->G99_NUMDOC
        cNomRem   := AllTrim(Iif(cTomador == '0', Posicione('SA1', 1, xFilial('SA1')+cCliRem, 'A1_NOME' ), Posicione('SA1', 1, xFilial('SA1')+cCliDes, 'A1_NOME' )))
        cNomDes   := AllTrim(Iif(cTomador == '0', Posicione('SA1', 1, xFilial('SA1')+cCliRem, 'A1_NOME' ), Posicione('SA1', 1, xFilial('SA1')+cCliDes, 'A1_NOME' )))
        cEmailPar := AllTrim(Iif(cTomador == '0', Posicione('SA1', 1, xFilial('SA1')+cCliRem, 'A1_EMAIL'), Posicione('SA1', 1, xFilial('SA1')+cCliDes, 'A1_EMAIL')))

        G99->(DbGoto((cTemp)->RECNOG99))

        ExecBlock("ENCDACTE", .f., .f., {cChvCte})
   
        If lOk .And. !ExistDir(Iif(RIGHT(cRootpath, 1) != '\', cRootpath+'\dacte', cRootpath+'dacte'))
            FwMakeDir(Iif(RIGHT(cRootpath, 1) != '\', cRootpath+'\dacte', cRootpath+'dacte'))
        EndIf 

        if !IsBlind()
            If lOk       
                CpyT2S(cStartPat+cChvCte+'.pdf', '\dacte')
            EndIf
        EndIf

        If lOk   
            aParam :=  ExecBlock("G818EMAIL", .f., .f., {cNomRem, cNomDes, cTomador, cTitEmail, cCorEmail, cChvCte, cNroCte})
        Endif

        if !IsBlind()
            If lOk
                lOk := GTPXEnvMail(cEmailLoc, cEmailPar,,, Iif(Len(aParam) > 0, aParam[1, 1], cTitPadr), Iif(Len(aParam) > 0, aParam[1, 2], cCorPadr + cNroCte), {'dacte\'+cChvCte+'.pdf'})[1]
            EndIf
        EndIf

        if lOk
            G99->(RecLock('G99',.F.))
            G99->G99_ENVMAI := '2' 
            G99->(MsUnlock())
        EndIf

        (cTemp)->(dbSkip())
    End
    (cTemp)->(DBCloseArea())
EndIf 

RestArea(aAreaG99)
RestArea(aArea)

Return
