#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "GTPA421D.CH"
/*/{Protheus.doc} GTPA421D()
Função que faz a chamada para geração dos títulos POS
@type function
@author flavio.martins
@since 04/06/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function GTPA421D(lJob, cEmp, cFil, cAgencia, cNumFch, cTipoOp)

Default lJob     := .F.
Default cAgencia := ''
Default cNumFcha := ''

If lJob
    RpcSetType(3)
    RpcClearEnv()
    RpcSetEnv(cEmp,cFil,,,'GTP',,)
Endif

GeraTit(lJob, cAgencia, cNumFch, cTipoOp)

Return

/*/{Protheus.doc} GeraTit()
Geração de títulos das vendas por POS
@type function
@author flavio.martins
@since 04/06/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraTit(lJob, cAgencia, cNumFch, cTipoOp)

Local cAliasQry	    := GetNextAlias()
Local cFilAtu	    := cFilAnt
Local nRecno        := 0
Local cStatus       := ""
Local aNewFlds      := {'GZG_CONFER', 'GZG_DTCONF', 'GZG_USUCON', 'GZG_FILTIT'}
Local lNewFlds      := GTPxVldDic('GZG', aNewFlds, .F., .T.)
Local aDados        := {}
Local cTitulo       := IIF(cTipoOp == "1", STR0006, STR0007) // "Receita", "Despesa"
Default cMsgErro	:= ""
Default cMsgTit		:= ""
Default lJob		:= .F.


Private lMsErroAuto	:= .F.

If !(lNewFlds)
    If !(lJob)
        FwAlertHelp(STR0001, STR0002 ) //"Dicionário desatualizado" //"Atualize o dicionário para utilizar esta rotina"
    Endif

    Return
Endif

BeginSql Alias cAliasQry

    SELECT GZG.GZG_COD
        , GZG.GZG_SEQ
        , GZG.GZG_VALOR
        , GZG_AGENCI
        , GZG_NUMFCH
        , GZG_TIPO
        , GZG.R_E_C_N_O_ RECNO
        , GI6_CLIENT
        , GI6_LJCLI
        , GI6_FORNEC
        , GI6_LOJA
        , GI6_FILRES
    FROM %Table:GZG% GZG 
    INNER JOIN %Table:GZC% GZC 
        ON GZC.GZC_FILIAL = %xFilial:GZC%
        AND GZC.GZC_CODIGO = GZG.GZG_COD
        AND GZC.GZC_GERTIT = '1'
        AND GZC.%NotDel%
    INNER JOIN %Table:GI6% GI6 
        ON GI6.GI6_FILIAL = %xFilial:GI6%
        AND GI6.GI6_CODIGO = GZG.GZG_AGENCI
        AND GI6.%NotDel%
    WHERE GZG.GZG_FILIAL = %xFilial:GZG%
        AND GZG.GZG_TIPO = %EXP:cTipoOp%
        AND GZG.GZG_CONFER = '2'
        AND GZG.GZG_STATIT IN ('0', ' ')
        AND GZG.%NotDel%

EndSql

While (cAliasQry)->(!Eof()) 

    nRecno  := (cAliasQry)->RECNO
    cStatus := "1"

    If  Empty((cAliasQry)->GI6_FILRES)
        cStatus  := '2'
        cMsgErro := STR0003 //'Filial responsável não informada no cadastro de agência'
    Endif

    If cStatus == '2'

        GZG->(dbGoto(nRecno))

        Reclock("GZG", .F.)
            GZG->GZG_STATIT := cStatus
            GZG->GZG_MOTERR := cMsgErro
        GZG->(MsUnlock())

        (cAliasQry)->(dbSkip())
        Loop

    Endif

    If !Empty((cAliasQry)->GI6_FILRES)
        cFilAnt := (cAliasQry)->GI6_FILRES
    Endif
    Aadd(aDados,{	(cAliasQry)->GZG_COD,;//1
                    (cAliasQry)->GZG_AGENCI,;//2
                    (cAliasQry)->GZG_NUMFCH,;//3
                    (cAliasQry)->GZG_TIPO,;//4
                    "",;//5
                    "",;//6
                    (cAliasQry)->RECNO,;//7
                    (cAliasQry)->GZG_VALOR,;//8
                    (cAliasQry)->GI6_CLIENT,;//9
                    (cAliasQry)->GI6_LJCLI,;//10
                    (cAliasQry)->GI6_FORNEC,;//11
                    (cAliasQry)->GI6_LOJA,;//12
                    (cAliasQry)->GI6_FILRES})//13
    
    Begin Transaction

    If cTipoOp == "1"
        CanTitRec(aDados,lJob,cStatus)
    Else
        CanTitDesp(aDados,lJob,cStatus)
    EndIf
    
    End Transaction

    (cAliasQry)->(dbSkip())

EndDo

cFilAnt := cFilAtu

If Select(cAliasQry) > 0
    (cAliasQry)->(dbCloseArea())
Endif

If !lJob .and. !isBlind()
    FwAlertSuccess(STR0008, STR0009 + cTitulo) //"Títulos gerados com sucesso", "Geração dos Títulos de "
Endif	

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CanTitDesp()

Função para geração dos títulos de despesas

@sample	GTPA700M()
 
@return	
 
@author	SIGAGTP | Flavio Martins
@since		09/12/2018
@version	P12
/*/
Static Function CanTitDesp(aDados,lJob,cStatus)
Local lRet			:= .T.
Local aTitulo		:= {}
Local aBaixa		:= {}
Local cNum			:= ''
Local cHistTit	:= ''
Local cTipo		:= 'TF'
Local cParcela	:= StrZero(1, TamSx3('E2_PARCELA')[1])
Local cNatTit  	:= GPA281PAR("NATUREZA")
Local cPrefixo	:= PadR("DSP", TamSx3('E2_PREFIXO')[1])  
Local cHistBaixa	:= STR0004 //'Baixa automatica de título de despesa'

Local cPath     := GetSrvProfString("StartPath","")
Local cFile     := ""

private lMsErroAuto	:= .F.

Default cStatus := "1"
	cNum	:= GetSxEnum('SE2', 'E2_NUM')

	cTitChave := xFilial("SE2") + cPrefixo + cNum + cParcela + cTipo
	
	cHistTit	:=  aDados[1][1] + aDados[1][2] + aDados[1][3] + aDados[1][4]
	
	SE2->(DbSetOrder(1))
	
	If !Empty(aDados[1][12]) // GI6_FILRES
	
		cFilAnt := aDados[1][13]
		
	Endif 
	SED->(DbSetOrder(1))
	SED->(DbSeek(xFilial("SED") + cNatTit ))						
	aTitulo :=	{;
					{ "E2_PREFIXO"	, cPrefixo /*aDados[1][5]*/	, Nil },; //Prefixo 
					{ "E2_NUM"		, cNum						, Nil },; //Numero
					{ "E2_TIPO"		, cTipo						, Nil },; //Tipo
					{ "E2_PARCELA"	, cParcela					, Nil },; //Parcela
					{ "E2_NATUREZ"	, cNatTit					, Nil },; //Natureza
					{ "E2_FORNECE"	, aDados[1][11]				, Nil },; //Fornecedor
					{ "E2_LOJA"		, aDados[1][12]				, Nil },; //Loja
					{ "E2_EMISSAO"	, dDataBase					, Nil },; //Data Emissão
					{ "E2_VENCTO"	, dDataBase					, Nil },; //Data Vencto
					{ "E2_VENCREA"	, dDataBase					, Nil },; //Data Vencimento Real
					{ "E2_MOEDA"	, 1							, Nil },; //Moeda
					{ "E2_VALOR"	, aDados[1][8]				, Nil },; //Valor
					{ "E2_HIST"		, cHistTit					, Nil },; //Historico
					{ "E2_ORIGEM"	, "GTPA421D"	    		, Nil };  //Origem
				}
									
	MsExecAuto( { |x,y| Fina050(x,y)}, aTitulo, 3) // 3-Inclusao,4-Alteração,5-Exclusão	
	
		
	If !lMsErroAuto
        GZG->(dbGoto(aDados[1][07]))

        Reclock("GZG", .F.)
            GZG->GZG_STATIT := cStatus
            GZG->GZG_FILTIT := SE2->E2_FILIAL
            GZG->GZG_PRETIT := SE2->E2_PREFIXO
            GZG->GZG_NUMTIT := SE2->E2_NUM
            GZG->GZG_PARTIT := SE2->E2_PARCELA
            GZG->GZG_TIPTIT := SE2->E2_TIPO
        GZG->(MsUnlock())
		CONFIRMSX8()
						
	Else
					
		lRet := .F.
		RollbackSx8()
		If !lJob
            cMsgErro := MostraErro()
        Else
            cMsgErro := MostraErro(cPath,cFile)
        Endif
        GZG->(dbGoto(aDados[1][07]))
        Reclock("GZG", .F.)
            GZG->GZG_STATIT := '2'
            GZG->GZG_MOTERR := cMsgErro
        GZG->(MsUnlock())
	Endif
						
	If lRet
					
		aBaixa := { {"E2_PREFIXO"		,aTitulo[1][2] 	,Nil},;
						{"E2_NUM"			,aTitulo[2][2] 	,Nil},;
						{"E2_TIPO"			,aTitulo[3][2]	,Nil},;
						{"E2_PARCELA"		,aTitulo[4][2] 	,Nil},;
						{"E2_CLIENTE"		,aTitulo[6][2] 	,Nil},;
						{"E2_LOJA"			,aTitulo[7][2] 	,Nil},;
						{"E2_FILIAL"		,xFilial("SE2")		,Nil},;
						{"AUTMOTBX"			,"BXP"				,Nil},;
						{"AUTDTBAIXA"		,dDatabase  		,Nil},;
						{"AUTDTCREDITO"		,dDatabase  		,Nil},;
						{"AUTHIST"			,cHistBaixa	 		,Nil},;
						{"AUTVLRPG"			,aTitulo[12][2] 	,Nil},;
						{"AUTVLRME"			,aTitulo[12][2]  	,Nil}}  
				
		MSExecAuto({|x,y| Fina080(x,y)}, aBaixa, 3) // Baixa	
			
		If !lMsErroAuto
		    GZG->(dbGoto(aDados[1][07]))

            Reclock("GZG", .F.)
                GZG->GZG_STATIT := cStatus
                GZG->GZG_FILTIT := SE2->E2_FILIAL
                GZG->GZG_PRETIT := SE2->E2_PREFIXO
                GZG->GZG_NUMTIT := SE2->E2_NUM
                GZG->GZG_PARTIT := SE2->E2_PARCELA
                GZG->GZG_TIPTIT := SE2->E2_TIPO
            GZG->(MsUnlock())
        Else
			lRet := .F.
			If !lJob
				cMsgErro := MostraErro()
			Else
				cMsgErro := MostraErro(cPath,cFile)
			EndIf
            GZG->(dbGoto(aDados[1][07]))
            Reclock("GZG", .F.)
                GZG->GZG_STATIT := '2'
                GZG->GZG_MOTERR := cMsgErro
            GZG->(MsUnlock())
		Endif
			
	Endif
	

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CanTitRec()

Função para geração dos títulos de receitas

@sample	GTPA700M()
 
@return	
 
@author	SIGAGTP | Flavio Martins
@since		09/12/2018
@version	P12
/*/
Static Function CanTitRec(aDados,lJob,cStatus)
Local lRet			:= .T.
Local aTitulo		:= {}
Local aBaixa		:= {}
Local cNum			:= ''
Local cHistTit		:= ''
Local cTipo			:= 'TF'
Local cParcela		:= StrZero(1,TamSx3('E1_PARCELA')[1])
Local cNatTit	  	:= GPA281PAR("NATUREZA")
Local cPrefixo		:= PadR("REC", TamSx3('E1_PREFIXO')[1])  
Local cHistBaixa	:= STR0005 //'Baixa automatica de título de receita'

Local cPath     := GetSrvProfString("StartPath","")
Local cFile     := "" 
Private lMsErroAuto	:= .F.
Default cStatus := "1"

	cNum	:= GetSxEnum('SE1', 'E1_NUM')

	cTitChave := xFilial("SE1") + cPrefixo + cNum + cParcela + cTipo
	
	cHistTit	:=  aDados[1][1] + aDados[1][2] + aDados[1][3] + aDados[1][4]  //(cAliasQry)->( G6Y_CODIGO + G6Y_CODAGE + G6Y_NUMFCH + G6Y_ITEM )
			
	SE1->(DbSetOrder(1))
	
	If !Empty(aDados[1][12]) // GI6_FILRES
	
		cFilAnt := aDados[1][13]
		
	Endif 
	SED->(DbSetOrder(1))		
	SED->(DbSeek(xFilial("SED") + cNatTit ))	
	aTitulo :=	{;
					{ "E1_PREFIXO"	, cPrefixo /*aDados[1][5]*/	, Nil },; //Prefixo 
					{ "E1_NUM"		, cNum						, Nil },; //Numero
					{ "E1_TIPO"		, cTipo						, Nil },; //Tipo
					{ "E1_PARCELA"	, cParcela					, Nil },; //Parcela
					{ "E1_NATUREZ"	, cNatTit					, Nil },; //Natureza
					{ "E1_CLIENTE"	, aDados[1][9]				, Nil },; //Cliente
					{ "E1_LOJA"		, aDados[1][10]				, Nil },; //Loja
					{ "E1_EMISSAO"	, dDataBase					, Nil },; //Data Emissão
					{ "E1_VENCTO"	, dDataBase					, Nil },; //Data Vencto
					{ "E1_VENCREA"	, dDataBase					, Nil },; //Data Vencimento Real
					{ "E1_MOEDA"	, 1							, Nil },; //Moeda
					{ "E1_VALOR"	, aDados[1][8]				, Nil },; //Valor
					{ "E1_SALDO"	, aDados[1][8]				, Nil },; //Valor
					{ "E1_HIST"		, cHistTit					, Nil },; //Historico
					{ "E1_ORIGEM"	, "GTPA421D"				, Nil };  //Origem
				}
					
	MsExecAuto( { |x,y| Fina040(x,y)}, aTitulo, 3) // 3-Inclusao,4-Alteração,5-Exclusão	
	
		
	If !lMsErroAuto
        GZG->(dbGoto(aDados[1][07]))

        Reclock("GZG", .F.)
            GZG->GZG_STATIT := cStatus
            GZG->GZG_FILTIT := SE1->E1_FILIAL
            GZG->GZG_PRETIT := SE1->E1_PREFIXO
            GZG->GZG_NUMTIT := SE1->E1_NUM
            GZG->GZG_PARTIT := SE1->E1_PARCELA
            GZG->GZG_TIPTIT := SE1->E1_TIPO
        GZG->(MsUnlock())
		CONFIRMSX8()
						
	Else
					
		lRet := .F.
		RollbackSx8()
		If !lJob
			cMsgErro := MostraErro()
		Else
			cMsgErro := MostraErro(cPath,cFile)
		Endif
        GZG->(dbGoto(aDados[1][07]))
        Reclock("GZG", .F.)
            GZG->GZG_STATIT := '2'
            GZG->GZG_MOTERR := cMsgErro
        GZG->(MsUnlock())

	Endif
						
	If lRet
					
					
		aBaixa := { {"E1_PREFIXO"	,aTitulo[1][2] 	,Nil},;
					{"E1_NUM"		,aTitulo[2][2] 	,Nil},;
					{"E1_TIPO"		,aTitulo[3][2]	,Nil},;
					{"E1_FILIAL"	,xFilial("SE1") ,Nil},;
					{"AUTMOTBX"		,"BXR"			,Nil},;
					{"AUTDTBAIXA"	,dDatabase  	,Nil},;
					{"AUTDTCREDITO"	,dDatabase  	,Nil},;
					{"AUTHIST"		,cHistBaixa	 	,Nil},;
	           		{"AUTJUROS"		,0             	,Nil,.T.},;
					{"AUTVALREC"	,aTitulo[12][2]	,Nil}}  
						
				
		MSExecAuto({|x,y| Fina070(x,y)}, aBaixa, 3) // Baixa	
			
		If !lMsErroAuto
            GZG->(dbGoto(aDados[1][07]))

            Reclock("GZG", .F.)
                GZG->GZG_STATIT := cStatus
                GZG->GZG_FILTIT := SE1->E1_FILIAL
                GZG->GZG_PRETIT := SE1->E1_PREFIXO
                GZG->GZG_NUMTIT := SE1->E1_NUM
                GZG->GZG_PARTIT := SE1->E1_PARCELA
                GZG->GZG_TIPTIT := SE1->E1_TIPO
            GZG->(MsUnlock())
        Else
			lRet := .F.
			If !lJob
                cMsgErro := MostraErro()
            Else
                cMsgErro := MostraErro(cPath,cFile)
            Endif
            GZG->(dbGoto(aDados[1][07]))
            Reclock("GZG", .F.)
                GZG->GZG_STATIT := '2'
                GZG->GZG_MOTERR := cMsgErro
            GZG->(MsUnlock())
		
		Endif
			
	Endif

Return lRet
