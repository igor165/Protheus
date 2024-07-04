#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "GTPA026C.CH"

/*/{Protheus.doc} GTPA026C()
Função que faz a chamada para geração dos títulos POS
@type function
@author flavio.martins
@since 04/06/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function GTPA026C(lJob, cEmp, cFil, cAgencia, cNumFch)
Local cDataIni		:= ''
Local cDataFim		:= ''
Local cAgeIni		:= cAgencia
Local cAgeFim		:= cAgencia

Default lJob     := .F.
Default cAgencia := ''
Default cNumFcha := ''

If lJob
    RpcSetType(3)
    RpcClearEnv()
    RpcSetEnv(cEmp,cFil,,,'GTP',,)
Endif

GeraTitPos(lJob, cDataIni, cDataFim, cAgeIni, cAgeFim, cNumFch)

Return

Function GTPJPOS(aParam)
Local lJob			:= Iif(Select("SX6")==0,.T.,.F.)  //Rotina automatica (schedule)
Local cEmpJob		:= ""
Local cFilJob		:= ""
Local lUsaColab 	:= .F.
Local cFilOk 		:= ""
Local cDataIni		:= ""
Local cDataFim		:= ""
Local cAgeIni		:= ""
Local cAgeFim		:= ""

cEmpJob := aParam[Len(aParam)-3]
cFilJob := aParam[Len(aParam)-2]

If lJob
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob MODULO "FAT"
EndIf   

cFilOk := cfilant

If !Empty(StoD(aParam[1])) .And. !Empty(StoD(aParam[2]))
	cDataIni := aParam[1]
	cDataFim := aParam[2]
	cAgeIni  := aParam[3]
	cAgeFim  := aParam[4]
Endif

GeraTitPos(ljob, cDataIni, cDataFim, cAgeIni, cAgeFim)

cFilAnt	:= cFilOk

Return()

/*/{Protheus.doc} GeraTitPos()
Geração de títulos das vendas por POS
@type function
@author flavio.martins
@since 04/06/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraTitPos(lJob, cDataIni, cDataFim, cAgeIni, cAgeFim, cNumFch)
Local aTitSE1 	:= {}
Local aParcelas := {}
Local lRet		:= .T.
Local cAliasQry	:= GetNextAlias()
Local cParc		:= StrZero(1,TamSx3('E1_PARCELA')[1])
Local cNum		:= ''
Local cFilAtu	:= cFilAnt
Local cPrefixo  := PadR("POS",TamSx3('E1_PREFIXO')[1])  
Local cTipo     := PadR("TF" ,TamSx3('E1_TIPO')[1])
Local nParcelas := 0
Local nParc		:= 0
Local cHistTit	:= ""	
Local cPath     := GetSrvProfString("StartPath","")
Local cFile     := ""
Local nRecno    := 0
Local cStatus   := ""
Local cCarDeb   := GTPGetRules('TPCARDDEBI', .F., Nil, "CD")
Local cCarCred  := GTPGetRules('TPCARDCRED', .F., Nil, "CC")
Local cCarParc  := GTPGetRules('TPCARDPARC', .F., Nil, "CP")
Local aNewFlds  := {'GQM_CONFER', 'GQM_DTCONF', 'GQM_USUCON', 'GQM_FILTIT'}
Local lNewFlds  := GTPxVldDic('GQM', aNewFlds, .F., .T.)
Local cQuery    := ''
Local cChaveGQM := ''
Local lGTTITPOS := ExistBlock('GTTITPOS')

Default cMsgErro	:= ""
Default cMsgTit		:= ""
Default lJob		:= .F.
Default cDataIni    := ''
Default cDataFim    := ''
Default cAgeIni     := ''
Default cAgeFim     := '' 
Default cNumFch     := '' 

Private lMsErroAuto	:= .F.

If !(lNewFlds)
    If !(lJob) .And. !IsBlind()
        FwAlertHelp(STR0007, STR0008) // "Dicionário desatualizado", "Atualize o dicionário para utilizar esta rotina" 
    Endif

    Return
Endif

If !Empty(cDataIni) .And. !Empty(cDataFim)
	cQuery += " AND GQM.GQM_DTVEND BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
Endif

If !Empty(cAgeIni) .And. !Empty(cAgeFim)
	cQuery += " AND GQL.GQL_CODAGE BETWEEN '" + cAgeIni + "' AND '" + cAgeFim + "' "
Endif

If !Empty(cNumFch)
	cQuery += " AND GQL.GQL_NUMFCH = '" + cNumFch + "' "
Endif

cQuery := "%"+cQuery+"%"

BeginSql Alias cAliasQry

    SELECT GQL.GQL_CODADM,
        GQL.GQL_TPVEND,
        GQM.GQM_FILIAL,
        GQM.GQM_CODGQL,
        GQM.GQM_CODNSU,
        GQM.GQM_CODAUT,
        GQM.GQM_CODIGO,
        GQM.GQM_DTVEND,
        GQM.GQM_VALOR,
        GQM.GQM_QNTPAR,
        GQM.R_E_C_N_O_ RECNO,
        GI6.GI6_FILRES,
        SAE.AE_COD,
        SAE.AE_TIPO,
        G58.G58_NATURE,
        SA1.A1_COD,
        SA1.A1_LOJA
    FROM %Table:GQL% GQL
    INNER JOIN %Table:GQM% GQM 
        ON GQM.GQM_FILIAL = GQL.GQL_FILIAL
    AND GQM.GQM_CODGQL = GQL.GQL_CODIGO
    AND GQM.%NotDel%
    INNER JOIN %Table:GI6% GI6 
        ON GI6.GI6_FILIAL = %xFilial:GI6%
    AND GI6.GI6_CODIGO = GQL.GQL_CODAGE
    AND GI6.%NotDel%
    LEFT JOIN %Table:SAE% SAE 
        ON SAE.AE_FILIAL = %xFilial:SAE%
    AND SAE.AE_COD = GQL.GQL_CODADM
    AND SAE.%NotDel%
    LEFT JOIN %Table:G58% G58 
        ON G58.G58_FILIAL = %xFilial:G58%
    AND G58.G58_CODADM = SAE.AE_COD
    AND G58.%NotDel%
    LEFT JOIN %Table:SA1% SA1 
        ON SA1.A1_FILIAL = %xFilial:SA1%
    AND SA1.A1_COD = G58.G58_CLIENT
    AND SA1.A1_LOJA = G58.G58_LOJA
    AND SA1.%NotDel%
    WHERE GQL.GQL_FILIAL = %xFilial:GQL%
    AND GQM.GQM_CONFER = '2'
    %Exp:cQuery%
    AND GQM.GQM_STATIT = '0'
    AND GQL.%NotDel%

EndSql
        
Begin Transaction

While (cAliasQry)->(!Eof()) 

    nRecno  := (cAliasQry)->RECNO
    cStatus := "1"

    If Empty((cAliasQry)->AE_COD)
        cStatus  := '2'
        cMsgErro := STR0001 // 'Administradora da venda não encontrada na tabela SAE'
    ElseIf Empty((cAliasQry)->A1_COD)       
        cStatus  := '2'
        cMsgErro := STR0002 // 'Cliente não encontrado na amarração Administradora x Bandeira'
    ElseIf Empty((cAliasQry)->GI6_FILRES)
        cStatus  := '2'
        cMsgErro := STR0003 // 'Filial responsável não informada no cadastro de agência'
    ElseIf Empty((cAliasQry)->G58_NATURE)
        cStatus  := '2'
        cMsgErro := STR0004 // 'Natureza não informada na amarração Administradora x Bandeira'
    Endif

    If cStatus == '2'

        GQM->(dbGoto(nRecno))

        Reclock("GQM", .F.)
            GQM->GQM_STATIT := cStatus
            GQM->GQM_MOTERR := cMsgErro
        GQM->(MsUnlock())

        (cAliasQry)->(dbSkip())
        Loop

    Endif

    nParcelas := Val((cAliasQry)->GQM_QNTPAR)

    If nParcelas <= 0
        nParcelas := 1
    Endif

    If AllTrim((cAliasQry)->AE_TIPO) == "CD"
        cTipo	:= cCarDeb 
    ElseIf nParcelas > 1
        cTipo	:= cCarParc 
    Else
        cTipo	:= cCarCred 
    Endif

    If !Empty((cAliasQry)->GI6_FILRES)
        cFilAnt := (cAliasQry)->GI6_FILRES
    Endif

    aParcelas := ParcTit(nParcelas,(cAliasQry)->GQM_VALOR ,STOD((cAliasQry)->GQM_DTVEND),(cAliasQry)->GQL_TPVEND)

    cNum := GtpTitNum('SE1', cPrefixo, cParc, cTipo)

    aTitSE1 := {}

    For nParc := 1 to Len(aParcelas)
        aTitSE1 :=	{;
                        { "E1_PREFIXO"	, cPrefixo									, Nil },; //Prefixo 
                        { "E1_NUM"		, cNum										, Nil },; //Numero
                        { "E1_PARCELA"	, StrZero(nParc,TamSx3('E1_PARCELA')[1])	, Nil },; //Parcela
                        { "E1_TIPO"		, cTipo										, Nil },; //Tipo
                        { "E1_NATUREZ"	, (cAliasQry)->G58_NATURE					, Nil },; //Natureza
                        { "E1_CLIENTE"	, (cAliasQry)->A1_COD  			    		, Nil },; //Cliente
                        { "E1_LOJA"		, (cAliasQry)->A1_LOJA 		    			, Nil },; //Loja
                        { "E1_EMISSAO"	, STOD((cAliasQry)->GQM_DTVEND)				, Nil },; //Data Emissão
                        { "E1_VALOR"	, aParcelas[nParc][1]						, Nil },; //Valor
                        { "E1_SALDO"	, aParcelas[nParc][1]	   					, Nil },; //Saldo
                        { "E1_VENCTO"	, aParcelas[nParc][2]						, Nil },; //Data Vencimento
                        { "E1_VENCREA"	, aParcelas[nParc][3]						, Nil },; //Data Vencimento Real
                        { "E1_HIST"		, cHistTit									, Nil },; //HIstórico
                        { "E1_NSUTEF"	, (cAliasQry)->GQM_CODNSU   				, Nil },; //HIstórico
                        { "E1_CARTAUT"	, (cAliasQry)->GQM_CODAUT					, Nil },; //HIstórico
                        { "E1_ORIGEM"	, "GTPA026C"						    	, Nil };  //Origem										
                    }
                
        If lGTTITPOS
            cChaveGQM := (cAliasQry)->GQM_FILIAL+(cAliasQry)->GQM_CODGQL+(cAliasQry)->GQM_CODNSU+(cAliasQry)->GQM_CODAUT
            aTitSe1 := ExecBlock("GTTITPOS",.F.,.F., {aTitSE1, cChaveGQM})
        Endif

        MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 3) // 3-Inclusao,4-Alteração,5-Exclusão		
        
        If !lMsErroAuto

            GQM->(dbGoto(nRecno))

            Reclock("GQM", .F.)
                GQM->GQM_STATIT := cStatus
                GQM->GQM_FILTIT := SE1->E1_FILIAL
                GQM->GQM_PRETIT := SE1->E1_PREFIXO
                GQM->GQM_NUMTIT := SE1->E1_NUM
                GQM->GQM_PARTIT := SE1->E1_PARCELA
                GQM->GQM_TIPTIT := SE1->E1_TIPO
            GQM->(MsUnlock())

        Else
            If !lJob
                MostraErro()
            Else
                cMsgErro := MostraErro(cPath,cFile)

                Reclock("GQM", .F.)
                    GQM->GQM_STATIT := '2'
                    GQM->GQM_MOTERR := cMsgErro
                GQM->(MsUnlock())

                Exit
            Endif
        Endif

    Next nParc	

    (cAliasQry)->(dbSkip())

EndDo

cFilAnt := cFilAtu

End Transaction

If Select(cAliasQry) > 0
    (cAliasQry)->(dbCloseArea())
Endif

If !lJob .And. !IsBlind()
    FwAlertSuccess(STR0005, STR0006) // "Títulos gerados com sucesso","Geração dos Títulos de POS"
Endif	

Return
