#include 'protheus.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'
#DEFINE ARQUIVO_LOG "job_extdmed.log"

/*/{Protheus.doc}  PlObjExtDmed
	Classe com dados pertinentes ao Job de extratação de informação para Dmed no modulo da Central de Obrigações.

	@type class
	@author Robson Nayland
	@since 23/11/2020
/*/

Class PlObjExtDmed
    Data lExistDep   AS Logical
    Data lExistBM1   AS Logical
    Data lExistB44   AS Logical
    Data cCpfTitular AS String
    Data cMatricTit  AS String
    Data cNomeTit    AS String
    Data aMesesDMED  as Array

    Method new() Constructor
    Method LoadDmedBm1()    // Cria Query para analisar os Registros da BM1XSE1
    Method LoadDmedB44()    // Cria Query para analisar os Registros da B44XB45
    Method VerFamilia()     // Verifica se na familia existe somente o titular para tratar o Top/Dtop.
    Method CarregaJson()    // Carrega itens com informação do BM1/B44
    Method EnviaCentral()   // Envia Json Para central
    Method MarcaFlag()      // tem como objetivo Flagar os campos BM1_FLDMED E B44_FLDMED que determiva que foi enviado arquivo para DMED
    Method destroy()

EndClass



Method new() Class PlObjExtDmed

    Self:lExistDep  := .F.
    Self:cCpfTitular:= ''
    Self:cMatricTit := ''
    Self:cNomeTit   := ''
    Self:lExistBM1  := .F.
    Self:lExistB44  := .F.
    Self:aMesesDMED := {}


Return self



/*/{Protheus.doc} LoadDmedBm1
	Methodo que verifica se há movimentos na BM1 para ser enviado para Central de Obrigações

	@type method
	@author Robson Nayland
	@since 24/11/2020
	@version 1.0
/*/

Method LoadDmedBm1(dDataref,cAliasBM1,lVerMeses) Class PlObjExtDmed

    Local cAno          := StrZero(Year(dDataref),4)
    Local cIntPad       := PlsIntPad()
    Local cMesIni       := If(lVerMeses,'01',StrZero(Month(dDataref),2))
    Local cMesFim       := If(lVerMeses .and. Month(dDataref) <> 12,StrZero((Month(dDataref)-1),2),StrZero(Month(dDataref),2))
    DeFault lVerMeses   := .F.


    //Procuro no cadastro de agendamento se existe uma data para ser exeutada
    BeginSql Alias cAliasBM1
        SELECT
            BM1.BM1_FILIAL,
            BM1.BM1_CODINT,
            BM1.BM1_CODEMP,
            BM1.BM1_MATRIC,
            BM1.BM1_ANO,
            BM1.BM1_MES,
            BM1.BM1_TIPREG,
            BM1.BM1_SEQ,
            BM1.BM1_DIGITO,
            BM1.BM1_MES,
            BM1.BM1_ANO,
            BM1.BM1_PREFIX,
            BM1.BM1_NUMTIT,
            BM1.BM1_VALOR,
            BM1.BM1_CODTIP,
            BM1.R_E_C_N_O_ RECNOFLG,
            BA1.BA1_CODINT,
            BA1.BA1_CODEMP,
            BA1.BA1_MATRIC,
            BA1.BA1_TIPUSU,
            BA1.BA1_TIPREG,
            BA1.BA1_DIGITO,
            BA1.BA1_CPFUSR,
            BA1.BA1_NOMUSR,
            BA1.BA1_DATNAS,
            BA1.BA1_GRAUPA,
            BA1.R_E_C_N_O_ RECNOBA1
        FROM
            %table:BM1% BM1
        INNER JOIN %table:BFQ% BFQ
        ON BFQ.BFQ_FILIAL = %xFilial:BFQ%
            AND BM1.BM1_CODINT = BFQ.BFQ_CODINT
            AND BM1.BM1_CODTIP = BFQ.BFQ_PROPRI || BFQ.BFQ_CODLAN
            AND (
                BFQ.BFQ_CMPCUS = %exp:' '%
                OR BFQ.BFQ_CMPCUS = %exp:'1'%
            )
            AND BFQ.%notDel%
        INNER JOIN %table:BA1% BA1
        ON BA1.BA1_FILIAL = %xFilial:BA1%
            AND BA1.BA1_CODINT = BM1.BM1_CODINT
            AND BA1.BA1_CODEMP = BM1.BM1_CODEMP
            AND BA1.BA1_MATRIC = BM1.BM1_MATRIC
            AND BA1.BA1_TIPREG = BM1.BM1_TIPREG
            AND BA1.BA1_DIGITO = BM1.BM1_DIGITO
            AND BA1.%notDel%
        INNER JOIN %table:SE1% SE1
        ON SE1.E1_FILIAL = %xFilial:SE1%
            AND SE1.E1_PREFIXO = BM1.BM1_PREFIX
            AND SE1.E1_NUM = BM1.BM1_NUMTIT
            AND SE1.E1_TIPO = BM1.BM1_TIPTIT
            AND SE1.E1_SALDO = %exp:0%
            AND SE1.%notDel%
        WHERE
            BM1.BM1_FILIAL = %xFilial:BM1%
            AND BM1.BM1_CODINT = %exp:cIntPad%
            AND BM1.BM1_ANO = %exp:cAno%
            AND BM1.BM1_MES BETWEEN %Exp:cMesIni% AND %Exp:cMesFim%
            AND BM1.BM1_FLDMED = %exp:' '%
            AND BM1.%notDel%
        ORDER BY
            BM1.BM1_FILIAL,
            BM1.BM1_CODINT,
            BM1.BM1_CODEMP,
            BM1.BM1_MATRIC,
            BM1.BM1_TIPREG,
            BM1.BM1_ANO,
            BM1.BM1_MES,
            BM1.BM1_SEQ
    EndSql

    If (cAliasBM1)->(Eof())
        //Não existindo registro gero log informativo
        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Não existe dados para BM1 job DMED PlObjExtDmed ",ARQUIVO_LOG)
    Else
        Self:lExistBM1  := .T.

        // Verificando quais os meses que tenho para enviar, assim não cria um objeto grande com muita informação sobrecarregando
        If lVerMeses

            Self:aMesesDmed := {}

            While (cAliasBM1)->(!Eof())

                If aScan(Self:aMesesDMED,(cAliasBM1)->(BM1_ANO+BM1_MES)) == 0
                    aAdd(Self:aMesesDMED,  (cAliasBM1)->(BM1_ANO+BM1_MES))
                Endif

                (cAliasBM1)->(DbSkip())
            Enddo
            (cAliasBM1)->(dbCloseArea())
        Endif
    Endif


Return


/*/{Protheus.doc} LoadDmedB44
	Methodo que verifica se há movimentos na B44 para ser enviado para Central de Obrigações

	@type method
	@author Robson Nayland
	@since 24/11/2020
	@version 1.0.
/*/

Method LoadDmedB44(dDataref,cAliasB44,lVerMeses) Class PlObjExtDmed

    Local cAno          := StrZero(Year(dDataref),4)
    Local cIntPad       := PlsIntPad()
    Local cMesIni       := If(lVerMeses,'01',StrZero(Month(dDataref),2))
    Local cMesFim       := If(lVerMeses .and. Month(dDataref) <> 12 ,StrZero((Month(dDataref)-1),2),StrZero(Month(dDataref),2))
    DeFault lVerMeses   := .F.

    //Procuro no cadastro de agendamento se existe uma data para ser exeutada
    BeginSql Alias cAliasB44
        SELECT
            B44.B44_NUMAUT,
            B44.B44_ANOAUT,
            B44.B44_MESAUT,
            B44.B44_OPEUSR,
            B44.B44_CODEMP,
            B44.B44_MATRIC,
            B44.B44_TIPREG,
            B44.B44_DIGITO,
            B44.B44_CODCLI,
            B44.B44_LOJA,
            B44.B44_VLRMAN,
            B44.B44_NUM,
            B44.B44_PREFIX,
            B44.B44_TIPO,
            B44.R_E_C_N_O_ RECNOFLG,
            BA1.BA1_CODINT,
            BA1.BA1_CODEMP,
            BA1.BA1_MATRIC,
            BA1.BA1_TIPUSU,
            BA1.BA1_TIPREG,
            BA1.BA1_DIGITO,
            BA1.BA1_CPFUSR,
            BA1.BA1_NOMUSR,
            BA1.BA1_DATNAS,
            BA1.BA1_GRAUPA,
            BA1.R_E_C_N_O_ RECNOBA1,
            BK6.BK6_CGC,
            BK6.BK6_NOME,
            B45.B45_DATPRO
        FROM
            %table:B44% B44
        INNER JOIN %table:BA1% BA1
        ON BA1.BA1_FILIAL = %xFilial:BA1%
            AND BA1.BA1_CODINT = B44.B44_OPEUSR
            AND BA1.BA1_CODEMP = B44.B44_CODEMP
            AND BA1.BA1_MATRIC = B44.B44_MATRIC
            AND BA1.BA1_TIPREG = B44.B44_TIPREG
            AND BA1.BA1_DIGITO = B44.B44_DIGITO
            AND BA1.%notDel%
        INNER JOIN %table:B45% B45
        ON B45.B45_FILIAL = %xFilial:B45%
            AND B45.B45_OPEMOV = B44.B44_OPEMOV
            AND B45.B45_ANOAUT = B44.B44_ANOAUT
            AND B45.B45_MESAUT = B44.B44_MESAUT
            AND B45.B45_NUMAUT = B44.B44_NUMAUT
            AND B45.%notDel%
        INNER JOIN %table:BK6% BK6
        ON BK6.BK6_FILIAL = %xFilial:BK6%
            AND BK6.BK6_CGC = B45.B45_CODREF
            AND BK6.%notDel%
        WHERE
            B44.B44_FILIAL = %xFilial:B44%
            AND B44.B44_OPEUSR = %exp:cIntPad%
            AND (
                B44.B44_MESAUT BETWEEN %Exp:cMesIni% AND %Exp:cMesFim%
                AND B44.B44_ANOAUT = %exp:cAno%
                OR B44.B44_MESAUT BETWEEN %Exp:'01'% AND %Exp:'12'%
                AND B44_ANOAUT < %Exp:cAno%
            )
            AND B44.B44_FLDMED = %exp:' '%
            AND B44.B44_STATUS = %exp:'2'%
            AND B44.%notDel%
        GROUP BY
            B44.B44_NUMAUT,
            B44.B44_ANOAUT,
            B44.B44_MESAUT,
            B44.B44_OPEUSR,
            B44.B44_CODEMP,
            B44.B44_MATRIC,
            B44.B44_TIPREG,
            B44.B44_DIGITO,
            B44.B44_CODCLI,
            B44.B44_LOJA,
            B44.B44_VLRMAN,
            B44.B44_NUM,
            B44.B44_PREFIX,
            B44.B44_TIPO,
            B44.R_E_C_N_O_,
            BA1.BA1_CODINT,
            BA1.BA1_CODEMP,
            BA1.BA1_MATRIC,
            BA1.BA1_TIPUSU,
            BA1.BA1_TIPREG,
            BA1.BA1_DIGITO,
            BA1.BA1_CPFUSR,
            BA1.BA1_NOMUSR,
            BA1.BA1_DATNAS,
            BA1.BA1_GRAUPA,
            BA1.R_E_C_N_O_,
            BK6.BK6_CGC,
            BK6.BK6_NOME,
            B45.B45_DATPRO
        ORDER BY
            B44.B44_NUMAUT,
            B44.B44_ANOAUT,
            B44.B44_MESAUT,
            B44.B44_OPEUSR,
            B44.B44_CODEMP,
            B44.B44_MATRIC,
            B44.B44_TIPREG,
            B44.B44_DIGITO,
            B44.B44_CODCLI,
            B44.B44_LOJA,
            B44.B44_VLRMAN,
            B44.B44_NUM,
            B44.B44_PREFIX,
            B44.B44_TIPO,
            B44.R_E_C_N_O_,
            BA1.BA1_CODINT,
            BA1.BA1_CODEMP,
            BA1.BA1_MATRIC,
            BA1.BA1_TIPUSU,
            BA1.BA1_TIPREG,
            BA1.BA1_DIGITO,
            BA1.BA1_CPFUSR,
            BA1.BA1_NOMUSR,
            BA1.BA1_DATNAS,
            BA1.BA1_GRAUPA,
            BA1.R_E_C_N_O_,
            BK6.BK6_CGC,
            BK6.BK6_NOME
    EndSql

    If (cAliasB44)->(Eof())
        //Não existindo registro gero log informativo
        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Não existe dados para B44 job DMED PlObjExtDmed ",ARQUIVO_LOG)
    Else
        Self:lExistB44  := .T.

        // Verificando quais os meses que tenho para enviar, assim não cria um objeto grande com muita informação sobrecarregando
        If lVerMeses

            Self:aMesesDmed := {}

            While (cAliasB44)->(!Eof())

                If aScan(Self:aMesesDMED,  (cAliasB44)->(B44_ANOAUT+B44_MESAUT)) == 0
                    aAdd(Self:aMesesDMED,  (cAliasB44)->(B44_ANOAUT+B44_MESAUT))
                Endif

                (cAliasB44)->(DbSkip())
            Enddo
            (cAliasB44)->(dbCloseArea())
        Endif
    Endif

Return


/*/{Protheus.doc} CarregaJson
	Methodo que carrega os itens no array para depois aplicar o FWJsonSerialize
	@type method
	@author Robson Nayland
	@since 24/11/2020
	@version 1.0
/*/

Method CarregaJson(oJson,cAliasTrb,cTipo) Class PlObjExtDmed

    Local   cCodOpAns   := ''
    Local   oItem       := {}
    Local   oRecFlg     := {}
    Local   lAnoAnterior:= .F.
    Default cTipo       := 0           // 0 = Bm1 - Cobrabça 1= b44 - Reembolso

    BRP->(DbSetOrder(1))

    While (cAliasTrb)->(!Eof())

        // Verifico se o Titular possui dependentes
        If (cAliasTrb)->(BA1_TIPUSU) == 'T'
            self:VerFamilia((cAliasTrb)->(BA1_CODINT),(cAliasTrb)->(BA1_CODEMP),(cAliasTrb)->(BA1_MATRIC),;
                Iif(cTipo=0,(cAliasTrb)->(BM1_ANO),(cAliasTrb)->(B44_ANOAUT)) ,;
                Iif(cTipo=0,(cAliasTrb)->(BM1_MES),(cAliasTrb)->(B44_MESAUT)) ,;
                (cAliasTrb)->(BA1_NOMUSR),(cAliasTrb)->BA1_TIPREG,(cAliasTrb)->BA1_DIGITO,(cAliasTrb)->(BA1_CPFUSR))
        Endif

        aAreaBA0 := BA0->(GetArea())

        BA0->(DbSetOrder(1))
        If BA0->(DbSeek(xFilial("BA0")+(cAliasTrb)->(BA1_CODINT)))
            cCodOpAns := BA0->BA0_SUSEP
        Endif

        If cTipo = 1
            lAnoAnterior:= .F.
            If Year(sTod((cAliasTrb)->(B45_DATPRO))) < Year(Msdate())
                lAnoAnterior:= .T.
            Endif
        Endif

        RestArea(aAreaBA0)

        Aadd(oItem  ,JsonObject():new())
        Aadd(oRecFlg,JsonObject():new())

        nPos := Len(oItem)
        nPos2:= Len(oRecFlg)

        oItem[nPos]['healthInsurerCode']      := cCodOpAns
        oItem[nPos]['ssnHolder']              := self:cCpfTitular
        oItem[nPos]['titleHolderEnrollment']  := self:cMatricTit
        oItem[nPos]['holderName']             := Alltrim(self:cNomeTit)
        //Tratativa para Rtop/ RdTop
        If (cAliasTrb)->(BA1_TIPUSU) <> 'T'
            oItem[nPos]['dependentSsn']           := (cAliasTrb)->(BA1_CPFUSR)
            oItem[nPos]['dependentEnrollment']    := (cAliasTrb)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
            oItem[nPos]['dependentName']          := (cAliasTrb)->(BA1_NOMUSR)
            oItem[nPos]['dependentBirthDate']     := (cAliasTrb)->(BA1_DATNAS)

            If BRP->(DbSeek(xFilial("BRP")+(cAliasTrb)->(BA1_GRAUPA)))
                oItem[nPos]['dependenceRelationships']:= BRP->BRP_CODSIB
            Else
                oItem[nPos]['dependenceRelationships']:= ''
            Endif

        Endif
        oItem[nPos]['expenseKey']               := Iif(cTipo =0,(cAliasTrb)->(BM1_NUMTIT+BM1_PREFIX+BM1_ANO+BM1_MES+BM1_CODTIP),(cAliasTrb)->(B44_NUM+B44_PREFIX+B44_TIPO)+"REE")

        //Tratativa para rtop/ RDTop
        If cTipo == 1  //  Reembolso
            oItem[nPos]['providerSsnEin']       := (cAliasTrb)->(BK6_CGC)
            oItem[nPos]['providerName']         := Alltrim((cAliasTrb)->(BK6_NOME))
            oItem[nPos]['refundAmount']         := Val(Alltrim(Str((cAliasTrb)->(B44_VLRMAN))))
            If lAnoAnterior
                oItem[nPos]['previousYearRefundAmt'] := Alltrim(Str((cAliasTrb)->(B44_VLRMAN)))
            Endif
        Else
            oItem[nPos]['expenseAmount']      := Val(Alltrim(Str((cAliasTrb)->(BM1_VALOR))))
        Endif
        oItem[nPos]['period']                   := Iif(cTipo=0,(cAliasTrb)->(BM1_ANO+BM1_MES),If(lAnoAnterior,Str(Year(sTod((cAliasTrb)->(B45_DATPRO))),4)+StrZero(Month(sTod((cAliasTrb)->(B45_DATPRO))),2),(cAliasTrb)->(B44_ANOAUT+B44_MESAUT)))
        oItem[nPos]['exclusionId']            := '0'

        oRecFlg[nPos2]  := (cAliasTrb)->( RECNOFLG)

        (cAliasTrb)->(DbSkip())
    Enddo

    oJson['Itens']  := oItem
    oJson['RecFlg'] := oRecFlg

Return


Method destroy() Class PlObjExtDmed
Return



/*/{Protheus.doc} VerFamilia
	Methodo que verifica se há mais membros na familia para preencimento do json Dtop

	@type method
	@author Robson Nayland
	@since 24/11/2020
	@version 1.0
/*/
Method VerFamilia(cCodInt,cCodemp,cMatric,cAno,cMes,cNomeTit,cTipReg,cDigito,cCpfTitular) Class PlObjExtDmed

    // aRetUsr   := PLSLOADUSR(cCodInt,cCodemp,cMatric,cAno,cMes)

    self:cCpfTitular:= cCpfTitular
    self:cMatricTit := cCodInt+cCodemp+cMatric+cTipReg+cDigito
    self:cNomeTit   := cNomeTit

Return


/*/{Protheus.doc} EnviaCentral
	Methodo que envia Json para central de obrigação

	@type method
	@author Robson Nayland
	@since 24/11/2020
	@version 1.0
/*/
Method EnviaCentral(oJson,cAliasFlag,lAutoma) Class PlObjExtDmed

    Local nLin      := 0
    Local oOffB2Y   := CenOffB2Y():New()
    Local lSucess   :=.F.
    Default lAutoma := .F.

    PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Incio do envio Json DMED ",ARQUIVO_LOG)

    For nLin:=1 to Len(oJson['Itens'])
        cJson := FWJsonSerialize(oJson['Itens'][nLin], .F., .F.)

        if !Empty(cJson)
            oOffB2Y:setContent(cJson)
            oOffB2Y:post()
            lSucess:=.t.
        endIf
        if !lSucess
            PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Ouve erro de transmissão Json DMED --> "+cJson ,ARQUIVO_LOG)
        Else
            //Marca os Registrso que foram eviados para central
            self:MarcaFlag(cAliasFlag,oJson["RecFlg"][nLin])
        endIf
    Next nLin

Return




/*/{Protheus.doc}  MarcaFlag(cAliasTrb)
	Methodo tem como objetivo Flagar os campos BM1_FLDMED E B44_FLDMED que determiva que foi enviado arquivo para DMED

	@type method
	@author Robson Nayland
	@since 24/11/2020
	@version 1.0
/*/

Method MarcaFlag(cAliasFlag,nRecFlg) Class PlObjExtDmed

    (cAliasFlag)->(DbGoTop())
    (cAliasFlag)->(DbGoTo(nRecFlg))
    RecLock(cAliasFlag,.F.)
    &(cAliasFlag+'->'+cAliasFlag+'_FLDMED') = 'S'
    MsUnLock()
    PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Item "+cAliasFlag+" enviado para Cetral de ObrigaçõesJson DMED --> "+Alltrim(Str(nRecFlg)) ,ARQUIVO_LOG)

Return
