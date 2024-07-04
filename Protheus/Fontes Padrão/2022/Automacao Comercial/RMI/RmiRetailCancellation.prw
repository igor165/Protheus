#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIMONITOR.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiCancellation
Rotina que efetua o cancelamento de Venda ajustando o campo
L1_SITUA para 'X2'
@param cQry, nRecIni, nRecFim, cStaimp

@return Vazio
@Obs	INTM211 para RmiCancellation
@author Everson S P Junior
@since 30/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiCancellation(cQry, nRecIni, nRecFim, cStaImp)

    Local lMThread	:= .F.						//Define se importacao sera processada via Multi Thread
    Local dDtIni	:= Date()					//Data do inicio do Processamento
    Local cHrIni	:= Time()					//Hora do inicio do Processamento
    Local cLog      := ""
    Local dDtFim	:= cTod("  /  /  ")			//Data do fim do Processamento
    Local cHrFim	:= ""						//Hora do fim do Processamento
    Local lJob 	    := IsBlind()    		    //Verifica que esta sendo executado por JOB e nao pelo Menu

    Default nRecIni := 0						//Recno Inicial recebido como parametro
    Default nRecFim := 0    					//Recno Final recebido como parametro
    Default cStaImp := "' ', '4'"				//status de importacao ()
    Default cQry 	:= ""						//QUERY

    If Empty(cQry)
        cQry := "SELECT R_E_C_N_O_ as REGISTRO FROM " + RetSQLName("SLX")
        cQry += " WHERE LX_SITUA = 'IP' "
        cQry += "	AND D_E_L_E_T_	= ' '"
    EndIf

    lMThread := (nRecIni <> 0 .AND. nRecFim <> 0)

    If lMThread
        cQry += " AND R_E_C_N_O_ BETWEEN " + cValToChar(nRecIni) + " AND " + cValToChar(nRecFim)
    EndIf

    cQry += " ORDER BY R_E_C_N_O_"
    LjGrvLog("RMIRETAILCANCEL","Query a ser executada ->", cQry)
                
    If !lJob
        Processa({|lEnd| RMIProCan(cQry,lJob) })
    Else
        RMIProCan(cQry,lJob)
    Endif	
                
    dDtFim	:= Date()		//Data do fim do Processamento
    cHrFim	:= Time()		//Hora do fim do Processamento

    cLog := "RmiCancellation - MOTOR de Integracao - Processo de Cancelamento de Venda - Registros processados -> Data Inicial " + DtoC(dDtIni) +;
        " Hora Inicial " + cHrIni + " Data Final " + DtoC(dDtFim) + " Hora Final " + cHrFim + " Tempo Gasto " + ElapTime(cHrIni,cHrFim)
    ConOut( cLog )
    
    LjGrvLog("RMIRETAILCANCEL", cLog )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RMIProCan
Rotina que realiza o Processamento dos Cancelamentos

@param cQry, lJob
@return Vazio
@Obs	M211Processa para RMIProCan
@author Everson S P Junior
@since 30/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RMIProCan(cQry,lJob)

    Local cAlias	:= GetNextAlias()
    Local cAliasC	:= GetNextAlias()
    Local aArea	    := GetArea()
    Local aAreaSLX	:= SLX->( GetArea() )
    Local aRetFun	:= {}
    Local cErro	    := ""
    Local cStr		:= ""
    Local nIndexSLX := 1
    Local cChaveSLX := ""
    Local lCmpUUID  := SLX->( ColumnPos("LX_UUID") ) > 0
    Local cUUID     := ""

    //Cria o Alias Temporario com todos os Cancelamentos pendentes de leitura
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAlias, .T., .F. )

    //Monta a Regua de Processamento, quando nao eh JOB
    If !lJob
        ProcRegua( (cAlias)->( RecCount() ) )
    EndIf

    //Abre os Alias
    dbSelectArea("SLX")
    dbSelectArea("SF2")
    dbSelectArea("SL1")

    While !(cAlias)->( EOF() )
        //Zera as Variaveis
        cErro	:= ""
        cStr	:= ""
        
        //Incrementa a regua de Processamento quando nao eh JOB
        If !lJob
            IncProc()
        EndIf
        
        //Posiciona no registro de Cancelamento da tabela 
        SLX->(dbGoTo((cAlias)->REGISTRO ))

        //Atualiza dados da Empresa para a filial do registro para nao ter problemas com os retornos do xFilial. ?
        RmiFilInt(SLX->LX_FILIAL, .T.)
        
        cQry := "SELECT L1_SERIE SERIE,SF2.D_E_L_E_T_ DELSF2,P1.LX_CUPOM,P1.LX_SITUA,L1_DOC,L1_SITUA,L1_NUM, SL1.R_E_C_N_O_ RECSL1, P1.R_E_C_N_O_ RECSLX, SF2.R_E_C_N_O_ RECSF2 "
        cQry += "  FROM " + RetSqlName("SLX") + " P1"
        cQry += "  LEFT JOIN " + RetSqlName("SL1") + " SL1 ON SL1.L1_FILIAL = P1.LX_FILIAL AND SL1.L1_DOC = P1.LX_CUPOM AND SL1.L1_SERIE = P1.LX_SERIE AND SL1.L1_PDV = P1.LX_PDV AND SL1.D_E_L_E_T_ = ' '"
        cQry += "  LEFT JOIN " + RetSqlName("SF2") + " SF2 ON SF2.F2_FILIAL = P1.LX_FILIAL AND SF2.F2_SERIE = P1.LX_SERIE AND SF2.F2_DOC = P1.LX_CUPOM "
        cQry += "   AND SF2.F2_PDV = P1.LX_PDV "
        cQry += " WHERE P1.LX_FILIAL = '" + Alltrim(SLX->LX_FILIAL) 	+ "'"
        cQry += "   AND P1.LX_CUPOM    = '" + Alltrim(SLX->LX_CUPOM)		+ "'"
        cQry += "   AND P1.LX_SITUA  = '" + Alltrim(SLX->LX_SITUA) 	+ "'"
        cQry += "   AND P1.LX_SERIE  = '" + Alltrim(SLX->LX_SERIE) 	+ "'"
        cQry += "   AND P1.D_E_L_E_T_ = ' '"
        cQry += "   AND SL1.L1_SITUA = 'OK'"
        LjGrvLog("RMIRETAILCANCEL","Query a ser executada ->",cQry)
        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasC, .T., .F. )

        If !(cAliasC)->( Eof() )

            DbSelectArea("SLX")
            cUUID     := IIF( lCmpUUID, SLX->LX_UUID, "")
            nIndexSLX := SLX->( IndexOrd() )
            cChaveSLX := &( SLX->( StrTran(IndexKey(), "+", "+'|'+") ) )
            
            If Empty(cErro) .And. Empty((cAliasC)->DELSF2)
                //Verifica se conseguiu encontrar a Estacao pela amarracao do PDV
                If Empty(cErro) .And. Empty((cAliasC)->SERIE)
                    cErro	:= STR0400 + SLX->LX_FILIAL + "/" + SLX->LX_PDV
                    cStr	:= "STR0400"
                EndIf
                //Procura o registro de venda para confirmar o SLX_SITUA se foi finalizado
                If Empty(cErro) .And. Empty((cAliasC)->LX_CUPOM)
                    cErro	:= STR0402 + SLX->LX_FILIAL + "/" + Alltrim(SLX->LX_CUPOM)
                    cStr	:= "STR0402"
                EndIf
            
                //Verifica o status do STAIMP da venda
                If Empty(cErro) .And. (cAliasC)->L1_SITUA = 'IP'					//Venda Nao Processada
                    cErro	:= STR0403 + SLX->LX_FILIAL + " /" + Alltrim((cAliasC)->L1_NUM)
                    cStr	:= "STR0403"
                ElseIf Empty(cErro) .And. (cAliasC)->L1_SITUA $ "IR"			//Venda com Erro na Camada
                    cErro	:= STR0404 + SLX->LX_FILIAL + "/" + Alltrim((cAliasC)->L1_NUM )
                    cStr	:= "STR0404"
                ElseIf Empty(cErro) .And. (cAliasC)->L1_SITUA == "RX"				//Venda Processada na Camada, mas ainda nao pelo LJGRVBATCH
                    cErro	:= STR0405 + SLX->LX_FILIAL + "/" + Alltrim((cAliasC)->L1_NUM)
                    cStr	:= "STR0405"
                ElseIf Empty(cErro) .And. (cAliasC)->L1_SITUA == "ER"				//Venda Processada pelo LJGRVBATCH, mas com erro
                    cErro	:= STR0406 + SLX->LX_FILIAL + "/" + Alltrim((cAliasC)->L1_NUM)
                    cStr	:= "STR0406"
                ElseIf Empty(cErro) .And. (cAliasC)->L1_SITUA $ "X"			//Venda Cancelada ou Erro no cancelamento
                    cErro	:= STR0407 + SLX->LX_FILIAL + "/" + Alltrim((cAliasC)->L1_NUM)
                    cStr	:= "STR0407"
                EndIf

                //Analiso as Informacoes do Orcamento
                If Empty(cErro) .And. Empty((cAliasC)->L1_NUM)
                    cErro := STR0408 + SLX->LX_FILIAL + "/" + Alltrim((cAliasC)->L1_NUM)
                    cStr	:= "STR0408"
                ElseIf Empty(cErro) .And. Empty((cAliasC)->L1_DOC)							//Busca o Orcamento criado a partir do registro da venda
                    cErro := STR0409 + SLX->LX_FILIAL + "/" + Alltrim((cAliasC)->L1_NUM)
                    cStr	:= "STR0409"
                ElseIf Empty(cErro) .And. SubStr(Alltrim((cAliasC)->L1_SITUA),1,1) == "X"	//Verifico se o processo de Cancelamento ja esta em andamento
                    cErro := STR0407 + SLX->LX_FILIAL + "/" + Alltrim((cAliasC)->L1_NUM)
                    cStr	:= "STR0407"
                ElseIf Empty(cErro) .And. !((cAliasC)->L1_SITUA $ "OK|FR")					//Verifico se o processo de Venda foi finalizado antes de iniciar o cancelamento
                    cErro := STR0410 + SLX->LX_FILIAL + "/" + Alltrim((cAliasC)->L1_NUM)
                    cStr	:= "STR0410"
                ElseIf Empty(cErro) .And. (cAliasC)->L1_SITUA == "ER"							//Verifico se a venda esta com erro
                    cErro := STR0411 + SLX->LX_FILIAL + "/" + Alltrim((cAliasC)->L1_NUM)
                    cStr	:= "STR0411"
                EndIf
            ElseIf Empty(cErro) .And. !Empty((cAliasC)->DELSF2)//Caso a Nota Fiscal ja esteja Deletada (DELSF2 igual a "*")
                    cErro	:= STR0401 + SLX->LX_FILIAL + "/" + SLX->LX_CUPOM + "/" + (cAliasC)->SERIE
                    cStr	:= "STR0401"
            EndIf
            
            //Caso nao ocorra nenhum erro, atualiza o L1_SITUA da tabela SL1
            If Empty(cErro)

                //Chama a Rotina para cancelamento
                SF2->( dbGoTo( (cAliasC)->RECSF2 ) )
                SL1->( dbGoTo( (cAliasC)->RECSL1 ) )

                aRetFun := EXECANRMI(cChaveSLX, SLX->LX_CUPOM, DTOS(SLX->LX_DTMOVTO), SLX->LX_HORA, SLX->LX_OPERADO)

                If aRetFun[1]

                    //Antes de atualizar o LX_SITUA, confirma se realmente a venda foi
                    //cancelada e só depois atualiza a SLX.
                    If RmiValidF2(SLX->LX_FILIAL, SLX->LX_CUPOM, SLX->LX_SERIE)
                    
                        //Atualizo a tabela SLX com o status "OK" (Cancelado)
                        RecLock("SLX", .F.)
                            SLX->LX_SITUA := ""
                        SLX->( MsUnLock() )
                    Else
                        //Atualizo a tabela SLX com o status "IP" Tentar novamente
                        RecLock("SLX", .F.)
                            SLX->LX_SITUA := "IP"
                        SLX->( MsUnLock() )    
                    EndIf
                Else

                    RMIGRVLOG(  "IR"       , "SLX"     , SLX->( Recno() ) , cStr          , "Erro Cancelamento " + aRetFun[2] + " - ExecAuto "  ,;
                                /*lRegNew*/, /*lTxt*/  , "LX_SITUA"       , /*lUpdStatus*/, nIndexSLX                                           ,;
                                cChaveSLX  , "GRVBATCH", "PROTHEUS"       , cUUID         )

                    RecLock("SLX", .F.)
                        SLX->LX_ERGRVBT := cStr + " - " + cErro
                        SLX->LX_SITUA   := "IR"
                    SLX->( MsUnLock() )				
                EndIf			
            Else

                //Caso encontr algum erro, atualiza o SLX erro por dependencia de outro processo
                RMIGRVLOG(  "IR"       , "SLX"     , SLX->( Recno() ) , cStr          , "Erro Cancelamento " + cErro + " - ExecAuto "   ,;
                            /*lRegNew*/, /*lTxt*/  , "LX_SITUA"       , /*lUpdStatus*/, nIndexSLX                                       ,;
                            cChaveSLX  , "GRVBATCH", "PROTHEUS"       , cUUID         )
                            
                RecLock("SLX", .F.)
                    SLX->LX_ERGRVBT := cStr + " - " + cErro
                    SLX->LX_SITUA   := "IR"
                SLX->( MsUnLock() )	
            EndIf
        EndIf
        (cAliasC)->( dbCloseArea() )
        (cAlias)->( dbSkip() )
    EndDo
    (cAlias)->( dbCloseArea() )
    //Restaura a Empresa e Filial.
    RmiFilInt(cFilAnt, .F.)

    RestArea(aAreaSLX)
    RestArea(aArea)    

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RMICANCEXE
Rotina chamada pelo INTM300 para executar o JOB de
Cancelamento de Venda por Multi-Thread	
@param cQry, lJob
@return Vazio
@Obs	INTM211E para RMICANCEXE
@author Everson S P Junior
@since 30/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMICANCEXE()

    Local cAlias	:= GetNextAlias()
    Local cFuncao	:= "RMICANCELLATION"
    Local cQry 	    := ""
    Local cStaImp	:= "' '"

    //---------------------------------------
    //|Efetua o processamento Staimp = ''   |
    //---------------------------------------
    cQry := "SELECT R_E_C_N_O_ as REGISTRO FROM " + RetSQLName("SLX")
    cQry += " WHERE LX_SITUA = 'IP' "
    cQry += "	AND D_E_L_E_T_	= ' '"
    cQry += "	ORDER BY REGISTRO "
    LjGrvLog("RMIRETAILCANCEL","[" + cFuncao + "] Query a ser excutada ->", cQry)
    //-----------------------------------------------
    //|Chama funcao para executar as Multis Threads |
    //-----------------------------------------------
    RMIPREPM(cAlias, cQry, cFuncao, "IN_TRHECUP", cStaImp)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} EXECANRMI
Executa a chamada do ExeAuto de cancelamento 
@param cInternalId, , cNumCancDoc, cDateCanc, cTimeCanc, cOperador, cProtoNfce
@return Vazio
@Obs	EXECANRMI
@author Everson S P Junior
@since 30/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EXECANRMI(cInternalId, cNumCancDoc, cDateCanc, cTimeCanc, cOperador, cProtoNfce)

    Local cValInt   := "" //Codigo interno utilizada no De/Para de codigos - Tabela XXF
    Local aDadosCup := {} //Array contendo Cupons para geracao da NF
    Local nOpcX     := 5  //Opcao de Inclusao
    Local aErroAuto := {} //Logs de erro do ExecAuto
    Local cMsgRet   := ""
    Local lRet      := .T.
    Local nI        := 0
    Local cPosSf3   := ""

    Default cDateCanc  := DtoS(dDataBase)
    Default cTimeCanc  := Time()
    Default cProtoNfce := ''
    Default cOperador  := ''

    Private lMsHelpAuto := .T. //Variavel de controle interno do ExecAuto
    Private lMsErroAuto := .F. //Variavel que informa a ocorrência de erros no ExecAuto
    Private lAutoErrNoFile := .T. //Força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário

    dDataBkp := dDataBase
    dDataBase := SToD(cDateCanc)

    //Armazena informacoes do cupom
    aAdd(aDadosCup, SL1->L1_SERIE)
    aAdd(aDadosCup, SL1->L1_DOC)
    aAdd(aDadosCup, SL1->L1_PDV)
    aAdd(aDadosCup, SL1->L1_NUM)
    aAdd(aDadosCup, cOperador)
    aAdd(aDadosCup, cTimeCanc)
    aAdd(aDadosCup, SToD(cDateCanc))
    cPosSf3 := SL1->L1_FILIAL+SL1->L1_DOC+SL1->L1_SERIE

    //Gera Log de Cancelamento - SLX
    Lj140StInD(.T.)//Força o comportamento similar ao EAI no LOJA140
    //Efetua o Cancelamento do Cupom
    MsExecAuto({|a,b,c,d,e,f,g,h,i| LJ140EXC(a,b,c,d,e,f,g,h,i)}, "SL1", /*nReg*/, nOpcX, /*aReserv*/, .T., SL1->L1_FILIAL, aDadosCup[4], cNumCancDoc,, cProtoNfce)
    //Verifica se encontrou erros no cancelamento de cupom
    If lMsErroAuto
        aErroAuto := GetAutoGrLog()

        //Armazena mensagens de erro
        For nI := 1 To Len(aErroAuto)
            cMsgRet += aErroAuto[nI] + Chr(10)
        Next nI

        //Se ExecAuto nao retornou erro, grava mensagem padrao
        If Len(aErroAuto) == 0
            cMsgRet += STR0007 + " " + AllTrim(cInternalId) //#"Erro no cancelamento do cupom: "
        EndIf       

        //ATENÇÃO - O "If At('FA040BAIXA',cMsgRet) > 0" deve ser retirado após a correção da issue DVARLOJ1-5839
        If At('FA040BAIXA',cMsgRet) > 0
            //Exclui Orcamento
            cMsgRet := ""
            DbSelectArea("SF3")
            SF3->(DbSetOrder(6)) //Gravar o codigo da SEFAZ 101
            If Sf3->(Dbseek(cPosSf3)) 
                RecLock("SF3", .F.)
                Replace SF3->F3_CODRSEF with '101' 			//Codigo do retorno da SEFAZ 
                SF3->( MsUnlock() )
            EndIf
            LjGrvLog("RMIRETAILCANCEL","Antes da função Lj140ExcOrc")
            Lj140ExcOrc()
            LjGrvLog("RMIRETAILCANCEL","Depois da função Lj140ExcOrc")
        Else
            lRet := .F.
            LjGrvLog("RMIRETAILCANCEL","Erro na ExecAuto do Lj140Exc", {cMsgRet,lRet})
            DisarmTransaction()
            MsUnLockAll()
        EndIf
    Else
        DbSelectArea("SF3")
        SF3->(DbSetOrder(6))
        If SF3->(Dbseek(cPosSf3)) 
            RecLock("SF3", .F.)
            Replace SF3->F3_CODRSEF with '101' 			//Codigo do retorno da SEFAZ 
            SF3->( MsUnlock() )
        EndIf
        //Exclui Orcamento
        LjGrvLog("RMIRETAILCANCEL","Antes da função Lj140ExcOrc")
        Lj140ExcOrc()
        LjGrvLog("RMIRETAILCANCEL","Depois da função Lj140ExcOrc")
    EndIf

    dDataBase := dDataBkp

Return {lRet, cMsgRet, cValInt}

//--------------------------------------------------------
/*/{Protheus.doc} RMISLXGRV
Gera fila para processamento do cancelmanto caso a 
RetailSales seja do tipo L1_SITUA = 'X2'.
@type function
@author  	Everson S P Junior
@since   	03/10/2019
@version 	P12
@return	    lRet
/*/
//--------------------------------------------------------
Function RMISLXGRV(aAutoCab)

Local lRet 		:= .T.
Local aArea 	:= GetArea()
Local cSitua  	:= ""
Local nPos      := 0
Local cDoc		:= aAutoCab[Ascan(aAutoCab,{|x| x[1]== "L1_DOC"})][2]
Local cSerie	:= aAutoCab[Ascan(aAutoCab,{|x| x[1]== "L1_SERIE"})][2]
Local cPDV		:= aAutoCab[Ascan(aAutoCab,{|x| x[1]== "L1_PDV"})][2]
Local cOperador	:= aAutoCab[Ascan(aAutoCab,{|x| x[1]== "L1_OPERADO"})][2]
Local cProtoc   := ""
Local cChvNfce  := ""
Local cMotivo   := Iif((nPos := Ascan(aAutoCab,{|x| x[1]== "LX_MOTIVO"})) > 0, aAutoCab[nPos][2], "")
Local cDtInut   := ""
Local cRetSfz   := ""
Local cNumOrc   := ""
Local cModDoc	:= "65"
Local cUUID     := ""
Local nL1UMOV   := Ascan(aAutoCab,{|x| AllTrim(x[1])== "L1_UMOV"})

DbSelectArea("SLX")
SLX->( DbSetOrder(1) )	//LX_FILIAL + LX_PDV + LX_CUPOM + LX_SERIE + LX_ITEM + LX_HORA
Begin Transaction
    If nL1UMOV > 0
        cUUID := PadR(aAutoCab[nL1UMOV][2],TamSX3("MHQ_UUID")[1])  
        LjGrvLog("RMIRETAILCANCEL","Campo L1_UMOV preenchido ?", cUUID)
    EndIf

    If SLX->(ColumnPos("LX_PRINUT")) > 0
		cProtoc := Iif((nPos := Ascan(aAutoCab,{|x| x[1]== "LX_PRINUT"})) > 0, aAutoCab[nPos][2], "")
	EndIf

    If SLX->(ColumnPos("LX_CHVNFCE")) > 0
		cChvNfce := Iif((nPos := Ascan(aAutoCab,{|x| x[1]== "LX_CHVNFCE"})) > 0, aAutoCab[nPos][2], "")
	EndIf

    If SLX->(ColumnPos("LX_DTINUTI")) > 0
		cDtInut := Iif((nPos := Ascan(aAutoCab,{|x| x[1]== "LX_DTINUTI"})) > 0, aAutoCab[nPos][2], "")
	EndIf

    If SLX->(ColumnPos("LX_RETSFZ")) > 0
		cRetSfz := Iif((nPos := Ascan(aAutoCab,{|x| x[1]== "LX_RETSFZ"})) > 0, aAutoCab[nPos][2], "")
	EndIf

    LjGrvLog("RMIRETAILCANCEL","Antes de Lj7SLXDocE", {cModDoc,cDoc,cSerie,cPDV,cOperador,cSitua,cNumOrc,cUUID,cProtoc,cChvNfce,cDtInut,cRetSfz})
    //Ajuste cSitua para Inutilização não ter concorrencia com Cancelamento no GravaBatch
    cSitua := IIF(Posicione("MHQ",7,xFilial("MHQ")+cUUID,"MHQ_EVENTO") == '3','IN','IP')
    
    Lj7SLXDocE( cModDoc     , cDoc  ,  cSerie   , cPDV  ,;
                cOperador   , cSitua,  cMotivo  , /**/  ,;
                cNumOrc     , /**/  ,  /**/     , cUUID ,;
                cProtoc     , cChvNfce, cDtInut , cRetSfz)//Sempre deve gerar SLX. o Erro deve ser validado no RMI de Cancelamento.

    LjGrvLog("RMIRETAILCANCEL","Depois de Lj7SLXDocE")
End Transaction

RestArea(aArea)

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} RmiValidF2
Funcao responsavel em validar se foi efetivado com sucesso o cancelamento da venda
na SF2.
@type       Function
@author  	Bruno Almeida
@since   	11/03/2020
@version 	P12
@return	    lRet
/*/
//--------------------------------------------------------
Static Function RmiValidF2(cFilVenda, cDoc, cSerie)

Local lRet      := .F. //Varivael de retorno da funcao
Local aAreaSF2	:= SF2->( GetArea() ) //Guarda a area da SF2

cFilVenda := PadR(cFilVenda,TamSx3("F2_FILIAL")[1]," ")
cDoc := PadR(cDoc,TamSx3("F2_DOC")[1]," ")
cSerie := PadR(cSerie,TamSx3("F2_SERIE")[1]," ")

SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
If SF2->(dbSeek(cFilVenda+cDoc+cSerie))
    LjGrvLog( "RMIRETAILCANCELLATION", "Nao houve sucesso no cancelamento da venda, neste caso ira manter o LX_SITUA = IP para uma proxima tentativa de cancelamento.", cFilVenda+cDoc+cSerie )
    lRet := .F.
Else
    LjGrvLog( "RMIRETAILCANCELLATION", "Sucesso no cancelamento da venda.", cFilVenda+cDoc+cSerie )
    lRet := .T.
EndIf
    
RestArea(aAreaSF2)

Return lRet
