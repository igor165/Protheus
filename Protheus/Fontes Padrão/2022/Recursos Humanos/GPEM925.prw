#INCLUDE 'Protheus.ch'
#INCLUDE "TopConn.ch"
#INCLUDE "GPEM925.ch"
/*/{Protheus.doc} GPEM925
Carga Inicial SIGAGPE x NG (AP)
@type  Function
@author rafaelalmeida
@since 08/06/2020
@version 12,1,27
/*/
Function GPEM925()

Local cUserId   := SubStr(cUsuario,7,15)
Local cMsg      := ""
Local cLog      := ""
Local cFilIni   := ""
Local cFilFin   := ""
Local cMatIni   := ""
Local cMatFin   := ""
Local cPesIni   := ""
Local cPesFin   := ""
Local cCrgIni   := ""
Local cCrgFin   := ""
Local lProcSRA  := .F.
Local lProcSRE  := .F.
Local lProcSR7  := .F.
Local lProcSRB  := .F.
Local lProcRD0  := .F.
Local lProcSQB  := .F.
Local lProcSQ3  := .F.
Local lLog      := .F.
Local aLogSra   := {}
Local aLogSre   := {}
Local aLogSr7   := {}
Local aLogSrb   := {}
Local aLogRd0   := {}
Local aLogSqb   := {}
Local aLogSq3   := {}


If !SuperGetMv("MV_RHNG",.F. ,.F.)
    MsgStop(STR0001+CRLF+;//##"A integração SIGAGPE x NG não está configurada neste ambiente."
            STR0002,STR0003)//##"Verifique se o seu ambiente está parâmetrizado corretamente!"##"Parâmetro MV_RHNG"
    Return Nil
EndIf

//"Este processamento pode levar alguns minutos."
//"O tempo de processamentop pode variar de acordo com o tamanho da sua base de dados!"
//"Tem certeza que deseja realizar o processo de carga inicial?"
If FPergunte("GPEM925") .And.MsgNoYes(STR0004 + CRLF + STR0005 + CRLF + CRLF + STR0006)
    
    cFilIni     := MV_PAR01
    cFilFin     := MV_PAR02
    lProcSRA    := MV_PAR03
    lProcSRE    := MV_PAR04
    lProcSR7    := MV_PAR05
    lProcSRB    := MV_PAR06
    cMatIni     := MV_PAR07
    cMatFin     := MV_PAR08
    lProcRD0    := MV_PAR09
    cPesIni     := MV_PAR10
    cPesFin     := MV_PAR11
    lProcSQB    := MV_PAR12
    cCrgIni     := MV_PAR13
    cCrgFin     := MV_PAR14
    lProcSQ3    := MV_PAR15
    lLog        := MV_PAR16
    
Else 
	Return Nil
EndIf

If lProcSRA
    Processa({||LoadSRA(cUserId,@cMsg,@aLogSra,cFilIni,cFilFin,cMatIni,cMatFin)}, STR0007, STR0008,.F.)//##"Aguarde..."##"Processando Cadastro de Funcionários (SRA)..."
    cLog += cMsg + CRLF
EndIf

If lProcSRE
    Processa({||LoadSRE(cUserId, @cMsg, @aLogSre, cFilIni, cFilFin, cMatIni, cMatFin)}, STR0007, STR0056, .F.) //"Aguarde..."##"Processando o Histórico de transferências (SRE)..."
    cLog += cMsg + CRLF
EndIf

If lProcSR7
    Processa({||LoadSR7(cUserId, @cMsg, @aLogSr7, cFilIni, cFilFin, cMatIni, cMatFin)}, STR0007, STR0057, .F.)//##"Aguarde..."##"Processando o Histórico Salarial (SR7)..."
    cLog += cMsg + CRLF
EndIf

If lProcSRB
    Processa({||LoadSRB(cUserId,@cMsg,@aLogSrb,cFilIni,cFilFin,cMatIni,cMatFin)}, STR0007, STR0009,.F.)//##"Aguarde..."##"Processando Cadastro de Dependentes (SRB)..."
    cLog += cMsg + CRLF
EndIf

If lProcRD0
    Processa({||LoadRD0(cUserId,@cMsg,@aLogRd0,cFilIni,cFilFin,cPesIni,cPesFin)}, STR0007, STR0010,.F.)//##"Aguarde..."##"Processando  Cadastro de Pessoas (RD0)..."
    cLog += cMsg + CRLF
EndIf

If lProcSQB
    Processa({||LoadSQB(cUserId,@cMsg,@aLogSqb,cFilIni,cFilFin)}, STR0007, STR0046,.F.)//##"Aguarde..."##"Processando Cadastro de Departamentos (SQB)..."
    cLog += cMsg + CRLF
EndIf

If lProcSQ3
    Processa({||LoadSQ3(cUserId,@cMsg,@aLogSq3,cFilIni,cFilFin, cCrgIni,cCrgFin)}, STR0007, STR0053,.F.)//##"Aguarde..."##"Processando Cadastro de Cargos (SQ3)..."
    cLog += cMsg + CRLF
EndIf

If lProcSRA .Or. lProcSRB .Or. lProcRD0 .Or. lProcSQB .Or. lProcSQ3 .or. lLog .Or. lProcSRE .Or. lProcSR7
    If lLog .And. (!Empty(aLogSRA) .Or. !Empty(aLogSRB) .Or. !Empty(aLogRd0) .Or. !Empty(aLogSqb) .Or. !Empty(aLogSq3) .Or. !Empty(aLogSRE) .Or. !Empty(aLogSR7)) 
        Processa({|| GravaLog(aLogSRA,aLogSRB,aLogRd0,aLogSqb,aLogSq3,aLogSRE,aLogSR7)}, STR0007, STR0011,.F.) //##"Aguarde..."##"Gerando arquivo de Log..."
    EndIf
    
    MsgInfo(cLog, STR0012)//##"Fim do Processamento da Carga Inicial"
Else
    // "Você marcou como não em todos os parâmetros!"
    // "Nenhum dado será processado!"
    MsgStop(STR0013 + CRLF + STR0014)
EndIf


Return Nil


/*/{Protheus.doc} LoadSRA
Realiza a carga dos registros da SRA.
@type  Static Function
@author rafaelalmeida
@since 08/06/2020
@version 12.1.27
@param cUserId, Character, Código do Usuário
@param cMsg , Character, Mensagem de processamento.
@param aLog , Character, Array contendo log de processamento
/*/
Static Function LoadSRA(cUserId,cMsg,aLog,cFilIni,cFilFin,cMatIni,cMatFin)

Local aAreOld 	:= GetArea()
Local cAlsQry   := GetNextAlias()
Local cChave    := "" 
Local cTime     := ""
Local nTotalReg := 0 

Default cUserId   := SubStr(cUsuario,7,15)
Default cMsg    := ""
Default aLog    := {}
Default cFilIni := ""
Default cFilFin := ""
Default cMatIni := ""
Default cMatFin := ""

    If !Empty(cFilIni)
        cFilIni := xFilial("SRA",cFilIni) 
    EndIf
	
	BeginSQL Alias cAlsQry
        SELECT RA_FILIAL, RA_MAT
        FROM %Table:SRA% SRA
        WHERE RA_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:cFilFin%
        AND RA_MAT BETWEEN %Exp:cMatIni% AND %Exp:cMatFin%
        AND SRA.%NotDel%
    EndSQL
	
	(cAlsQry)->(dbEval({||nTotalReg++}))
	(cAlsQry)->(dbGoTop())
	ProcRegua(nTotalReg)
	nTotalReg := 0
	
	dbSelectArea("RJP")
	dbSetOrder(6)
	
	While !(cAlsQry)->(Eof())
		IncProc()
        cChave  := cEmpAnt + "|" + (cAlsQry)->RA_FILIAL + "|" + (cAlsQry)->RA_MAT
		If RJP->(dbSeek(xFilial("RJP") + cChave))
			(cAlsQry)->(dbSkip())
    		LOOP
		Else
            cTime   := Time()
			Aadd(aLog, {cChave, dDataBase, cTime, cUserId})
			nTotalReg++

			Begin Transaction
                fSetInforRJP((cAlsQry)->RA_FILIAL, (cAlsQry)->RA_MAT, "SRA", cChave, "I",  dDataBase, cTime, cUserId)
                RJP->(dbSetOrder(6))  //RJP_FILIAL+RJP_KEY
                If RJP->(dbSeek(xFilial("RJP")+cChave))
                    RecLock("RJP",.F.)
                    RJP->RJP_CGINIC := '1'
                    RJP->(MsUnlock())
                Else 
                    DisarmTransaction()
                EndIf
            End Transaction
        Endif    
        (cAlsQry)->(dbSkip())
    EndDo
	
	If nTotalReg == 0
        cMsg := STR0015// ##"Não foram encontrados registros elegíveis para processamento no cadastro de funcionários. (SRA)"
	else
        cMsg := STR0016+cValToChar(nTotalReg)+STR0017//##"Foram processados "##" registros do cadastro de funcionários (SRA)."
	EndIf
	
	(cAlsQry)->(dbCloseArea())
	
	RestArea(aAreOld)

Return Nil

/*/{Protheus.doc} LoadSRE
Realiza a carga dos registros da SRE.
@type Static Function
@author Cícero Alves
@since 19/03/2021
@version 12.1.27
@param cUserId, Caracter, Código do Usuário
@param cMsg, Caracter, Mensagem de processamento.
@param aLog, Array, Array contendo log de processamento
@param cFilIni, Caracter, Filial inicial para filtro dos dados
@param cFilFin, Caracter, Filial final para filtro dos dados
@param cMatIni, Caracter, Matrícula inicial para filtro dos dados
@param cMatFin, Caracter, Matrícula final para filtro dos dados
/*/
Static Function LoadSRE(cUserId, cMsg, aLog, cFilIni, cFilFin, cMatIni, cMatFin)
    
    Local aAreOld := GetArea()
    Local cAlsQry   := GetNextAlias()
    Local cChave    := "" 
    Local cTime     := ""
    Local nTotalReg := 0 
    Local aTransf   := {}
    Local nI
    
    Default cUserId   := SubStr(cUsuario, 7, 15)
    Default cMsg    := ""
    Default aLog    := {}
    Default cFilIni := ""
    Default cFilFin := ""
    Default cMatIni := ""
    Default cMatFin := ""

    If !Empty(cFilIni)
        cFilIni := xFilial("SRE",cFilIni) 
    EndIf
    
    BeginSQL Alias cAlsQry
        SELECT RA_FILIAL, RA_MAT
        FROM %Table:SRA% SRA
        WHERE RA_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:cFilFin%
        AND RA_MAT BETWEEN %Exp:cMatIni% AND %Exp:cMatFin%
        AND	RA_SITFOLH != 'D'
        AND SRA.%NotDel%
    EndSQL
    
    ProcRegua((cAlsQry)->(LastRec()))
    
    dbSelectArea("RJP")
    dbSetOrder(2) // RJP_FIL + RJP_MAT + RJP_KEY + DTOS(RJP_DATA)
    
    While !(cAlsQry)->(Eof())
        aTransf := {}
        IncProc()
        If fTransf( @aTransf,,,,,, .F., .T.,,,,, (cAlsQry)->RA_FILIAL, (cAlsQry)->RA_MAT ) // Busca todas as transferências do funcionário
            For nI := 1 To Len(aTransf)
                cChave  := cEmpAnt + "|" + aTransf[nI][8] + "|" + aTransf[nI][9] + "|" + dToS(aTransf[nI][7])
                If ! RJP->(dbSeek( aTransf[nI][8] + aTransf[nI][9] + cChave ))
                    nTotalReg++
					cTime := Time()
					Aadd(aLog, {cChave, dDataBase, cTime, cUserId})
                    Begin Transaction
                        // Gero as informações na RJP para o funcionário atual
                        fSetInforRJP((cAlsQry)->RA_FILIAL, (cAlsQry)->RA_MAT, "SRE", cChave, "I",  dDataBase, cTime, cUserId)
                        RJP->(dbSetOrder(6))//RJP_FILIAL+RJP_KEY
                        If RJP->(dbSeek(xFilial("RJP")+cChave))
                            RecLock("RJP", .F.)
                            RJP->RJP_CGINIC := '1'
                            RJP->(MsUnlock())
                        Else 
                            DisarmTransaction()
                        EndIf
                    End Transaction
                EndIf
            Next nI
        EndIf
		(cAlsQry)->(dbSkip())
    EndDo
    
    If nTotalReg == 0
        cMsg := STR0058 // "Não foram encontrados registros elegíveis para processamento no histórico de transferências. (SRE)"
    else
        cMsg := STR0016 + cValToChar(nTotalReg) + STR0059 // "Foram processados "##" registros do histórico de transferências. (SRE)"
    EndIf
    
    (cAlsQry)->(dbCloseArea())
    
    RestArea(aAreOld)
    
Return Nil

/*/{Protheus.doc} LoadSR7
Realiza a carga dos registros da SR7.
@type Static Function
@author Cícero Alves
@since 19/03/2021
@version 12.1.27
@param cUserId, Caracter, Código do Usuário
@param cMsg, Caracter, Mensagem de processamento.
@param aLog, Array, Array contendo log de processamento
@param cFilIni, Caracter, Filial inicial para filtro dos dados
@param cFilFin, Caracter, Filial final para filtro dos dados
@param cMatIni, Caracter, Matrícula inicial para filtro dos dados
@param cMatFin, Caracter, Matrícula final para filtro dos dados
/*/
Static Function LoadSR7(cUserId, cMsg, aLog, cFilIni, cFilFin, cMatIni, cMatFin)
	
	Local aAreOld 	:= GetArea()
	Local cAlsQry   := GetNextAlias()
	Local cChave    := "" 
	Local cTime     := ""
	Local nTotalReg := 0 
	Local cCargoAnt	:= ""
	Local cFuncaoAnt:= ""
	
	Default cUserId := SubStr(cUsuario, 7, 15)
	Default cMsg    := ""
	Default aLog    := {}
	Default cFilIni := ""
	Default cFilFin := ""
	Default cMatIni := ""
	Default cMatFin := ""

    If !Empty(cFilIni)
        cFilIni := xFilial("SR7",cFilIni) 
    EndIf
	
	BeginSQL Alias cAlsQry
        SELECT RA_FILIAL, RA_MAT
        FROM %Table:SRA% SRA
        WHERE RA_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:xFilial("SRA", cFilFin)%
        AND RA_MAT BETWEEN %Exp:cMatIni% AND %Exp:cMatFin%
        AND	RA_SITFOLH != 'D'
        AND SRA.%NotDel%
    EndSQL
	
	(cAlsQry)->(dbEval({||nTotalReg++}))
	(cAlsQry)->(dbGoTop())
	ProcRegua(nTotalReg)
	nTotalReg := 0
	
	dbSelectArea("RJP")
	dbSetOrder(6)
	
	dbSelectArea("SR7")
	dbSetOrder(1)
	
	While !(cAlsQry)->(Eof())
		
		IncProc()
		cCargoAnt := ""
		cFuncaoAnt := ""
		
		If SR7->(dbSeek((cAlsQry)->(RA_FILIAL + RA_MAT)))
			While SR7->( !EoF() .And. R7_FILIAL + R7_MAT ==  (cAlsQry)->(RA_FILIAL + RA_MAT))
				If !(SR7->R7_CARGO == cCargoAnt) .Or. !(SR7->R7_FUNCAO == cFuncaoAnt)
					cCargoAnt := SR7->R7_CARGO
					cFuncaoAnt := SR7->R7_FUNCAO
					cChave := SR7->(cEmpAnt + "|" + R7_FILIAL + "|" + R7_MAT + "|" + DtoS(R7_DATA) + "|" + R7_SEQ + "|" + R7_TIPO)
					If RJP->(dbSeek(xFilial("RJP") + cChave))
						SR7->(dbSkip())
						LOOP
					Else
						cTime   := Time()
						Aadd(aLog, {cChave, dDataBase, cTime, cUserId})
						nTotalReg++
						Begin Transaction
							fSetInforRJP(SR7->R7_FILIAL, SR7->R7_MAT, "SR7", cChave, "I",  dDataBase, cTime, cUserId)
							RJP->(dbSetOrder(6))
							If RJP->(dbSeek(xFilial("RJP") + cChave))
								RecLock("RJP",.F.)
								RJP->RJP_CGINIC := '1'
								RJP->(MsUnlock())
							Else 
								DisarmTransaction()
							EndIf
						End Transaction
					EndIf
				EndIf
				SR7->(dbSkip())
			EndDo
		EndIf
		(cAlsQry)->(dbSkip())
	EndDo
	
	If nTotalReg == 0
		cMsg := STR0060		// "Não foram encontrados registros elegíveis para processamento no histórico salarial. (SR7)"
	else
		cMsg := STR0016 + cValToChar(nTotalReg) + STR0061 // "Foram processados "## " registros do cadastro de histórico salarial (SR7)."
	EndIf
	
	(cAlsQry)->(dbCloseArea())
	
	RestArea(aAreOld)
    
Return Nil

/*/{Protheus.doc} LoadSRB
    
    Realiza a carga dos registros da SRB.

    @type  Static Function
    @author rafaelalmeida
    @since 08/06/2020
    @version 12.1.27
    @param cUserId, Character, Código do Usuário
    @param cMsg , Character, Mensagem de processamento.
    @param aLog , Character, Array contendo log de processamento
 
    /*/
Static Function LoadSRB(cUserId,cMsg,aLog,cFilIni,cFilFin,cMatIni,cMatFin)

Local aAreOld := GetArea()

Local cAlsQry   := GetNextAlias()
Local cChave    := "" 
Local cTime     := ""

Local nTotalReg := 0 

Default cUserId := SubStr(cUsuario,7,15)
Default cMsg    := ""
Default aLog    := {}
Default cFilIni := ""
Default cFilFin := ""
Default cMatIni := ""
Default cMatFin := ""

If !Empty(cFilIni)
    cFilIni := xFilial("SRB",cFilIni) 
EndIf

BeginSQL Alias cAlsQry
    SELECT RA_FILIAL, RA_MAT
    FROM %Table:SRA% SRA
    WHERE RA_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:xFilial("SRA", cFilFin)%
    AND RA_MAT BETWEEN %Exp:cMatIni% AND %Exp:cMatFin%
    AND	RA_SITFOLH != 'D'
    AND SRA.%NotDel%
EndSQL

(cAlsQry)->(dbEval({||nTotalReg++}))
(cAlsQry)->(dbGoTop())
ProcRegua(nTotalReg)
nTotalReg := 0
	
dbSelectArea("RJP")
dbSetOrder(6)
	
dbSelectArea("SRB")
dbSetOrder(1)

While !(cAlsQry)->(Eof())
    IncProc()

    If SRB->(dbSeek((cAlsQry)->(RA_FILIAL + RA_MAT)))
        While SRB->( !EoF() .And. RB_FILIAL + RB_MAT ==  (cAlsQry)->(RA_FILIAL + RA_MAT))
            cChave    := cEmpAnt + "|" + SRB->RB_FILIAL + "|" + SRB->RB_MAT + "|" + SRB->RB_COD
            
            If RJP->(dbSeek(xFilial("RJP") + cChave))
                SRB->(dbSkip())
                LOOP
            Else
                cTime   := Time()
                Aadd(aLog,{cChave,dDataBase,cTime,cUserId})
                nTotalReg++
                Begin Transaction
                    fSetInforRJP(SRB->RB_FILIAL, SRB->RB_MAT, "SRB", cChave, "I",  dDataBase, cTime, cUserId)
                    RJP->(dbSetOrder(6))//RJP_FILIAL+RJP_KEY
                    If RJP->(dbSeek(xFilial("RJP")+cChave))
                        RecLock("RJP",.F.)
                        RJP->RJP_CGINIC := '1'
                        RJP->(MsUnlock())
                    Else 
                        DisarmTransaction()
                    EndIf
                End Transaction
            EndIf
            SRB->(dbSkip())
		EndDo
    EndIf
    (cAlsQry)->(dbSkip())
EndDo

If nTotalReg == 0
    cMsg := STR0018//##"Não foram encontrados registros elegíveis para processamento no cadastro de dependentes. (SRB)"
else
    cMsg := STR0016+cValToChar(nTotalReg)+STR0019//##"Foram processados "##" registros do cadastro de dependentes (SRB)."
EndIf

(cAlsQry)->(dbCloseArea())


RestArea(aAreOld)
    
Return Nil

/*/{Protheus.doc} LoadRD0
    
    Realiza a carga dos registros da SRB.

    @type  Static Function
    @author rafaelalmeida

    @since 08/06/2020
    @version 12.1.27
    @param cUserId, Character, Código do Usuário.
    @param cMsg , Character, Mensagem de processamento.
    @param aLog , Character, Array contendo log de processamento
    /*/
Static Function LoadRD0(cUserId,cMsg,aLog,cFilIni,cFilFin,cPesIni,cPesFin)

Local aAreOld := GetArea()

Local cAlsQry   := GetNextAlias()
Local cTime     := ""
Local cChave    := "" 

Local nTotalReg := 0 

Default cUserId   := SubStr(cUsuario,7,15)
Default cMsg    := ""
Default aLog    := {}
Default cFilIni := ""
Default cFilFin := ""
Default cPesIni := ""
Default cPesFin := ""

If !Empty(cFilIni)
    cFilIni := xFilial("RD0",cFilIni) 
EndIf

BeginSQL Alias cAlsQry
    SELECT RD0_FILIAL,RD0_CODIGO
    FROM %Table:RD0% RD0
    WHERE RD0_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:xFilial("RD0", cFilFin)%
    AND RD0_CODIGO BETWEEN %Exp:cPesIni% AND %Exp:cPesFin%
    AND RD0.%NotDel%
EndSQL

(cAlsQry)->(dbEval({||nTotalReg++}))
(cAlsQry)->(dbGoTop())
ProcRegua(nTotalReg)
nTotalReg := 0
	
dbSelectArea("RJP")
dbSetOrder(6)

While !(cAlsQry)->(Eof())
    IncProc()
	cChave    := cEmpAnt + "|" + (cAlsQry)->RD0_FILIAL + "|" + (cAlsQry)->RD0_CODIGO

    If RJP->(dbSeek(xFilial("RJP") + cChave))
		(cAlsQry)->(dbSkip())
    	LOOP
    Else
        cTime   := Time()
        Aadd(aLog,{cChave,dDataBase,cTime,cUserId})
        nTotalReg++
        Begin Transaction
            fSetInforRJP((cAlsQry)->RD0_FILIAL, (cAlsQry)->RD0_CODIGO, "RD0", cChave, "I",  dDataBase, cTime, cUserId)
            RJP->(dbSetOrder(6))//RJP_FILIAL+RJP_KEY
            If RJP->(dbSeek(xFilial("RJP")+cChave))
                RecLock("RJP",.F.)
                RJP->RJP_CGINIC := '1'
                RJP->(MsUnlock())
            Else 
                DisarmTransaction()
            EndIf
        End Transaction
    EndIf
    (cAlsQry)->(dbSkip())
EndDo

If nTotalReg == 0
    cMsg := STR0020//##"Não foram encontrados registros elegíveis para processamento no cadastro de pessoas. (RD0)"
else
    cMsg := STR0016+cValToChar(nTotalReg)+STR0021//##"Foram processados "##" registros do cadastro de pessoas (RD0)."
EndIf

(cAlsQry)->(dbCloseArea())

RestArea(aAreOld)
    
Return Nil

/*/{Protheus.doc} LoadSQ3
    
    Realiza a carga dos registros da SQ3.

    @type  Static Function
    @author brdwc0032

    @since 13/08/2020
    @version 12.1.27
    @param cUserId, Character, Código do Usuário.
    @param cMsg , Character, Mensagem de processamento.
    @param aLog , Character, Array contendo log de processamento
    @param cFilIni , Character, Filial inicial.
    @param cFilFin , Character, Filial final.
    /*/
Static Function LoadSQ3(cUserId,cMsg,aLog,cFilIni,cFilFin, cCrgIni, cCrgFin)

Local aAreOld := GetArea()

Local cAlsQry   := GetNextAlias()
Local cTime     := ""
Local cChave    := "" 

Local nTotalReg := 0 

Default cUserId   := SubStr(cUsuario,7,15)
Default cMsg    := ""
Default aLog    := {}
Default cFilIni := ""
Default cFilFin := ""

If !Empty(cFilIni)
    cFilIni := xFilial("SQ3",cFilIni) 
EndIf

dbSelectArea("SQ3")

BeginSQL Alias cAlsQry
    SELECT Q3_FILIAL,Q3_CARGO, Q3_CC, SQ3.R_E_C_N_O_ AS RECNO
    FROM %Table:SQ3% SQ3
    WHERE Q3_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:xFilial("SQ3", cFilFin)%
    AND Q3_CARGO BETWEEN %Exp:cCrgIni% AND %Exp:cCrgFin%
    AND SQ3.%NotDel%
EndSQL

(cAlsQry)->(dbEval({||nTotalReg++}))
(cAlsQry)->(dbGoTop())
ProcRegua(nTotalReg)
nTotalReg := 0
	
dbSelectArea("RJP")
dbSetOrder(6)

While !(cAlsQry)->(Eof())
    
    IncProc()
    
    // Verifica se o registro está bloqueado para uso
	SQ3->(dbGoTo( (cAlsQry)->RECNO ))
	If !RegistroOk("SQ3", .F.)
        nTotalReg--
		(cAlsQry)->(dbSkip())
		LOOP
	EndIf
    
	cChave    := cEmpAnt + "|" + (cAlsQry)->Q3_FILIAL + "|" + (cAlsQry)->Q3_CARGO + "|" + (cAlsQry)->Q3_CC

    If RJP->(dbSeek(xFilial("RJP") + cChave))
		(cAlsQry)->(dbSkip())
    	LOOP
    Else
        cTime   := Time()
        Aadd(aLog,{cChave,dDataBase,cTime,cUserId})
        nTotalReg++
        Begin Transaction
            fSetDeptoRJP((cAlsQry)->Q3_FILIAL, "SQ3", cChave, "I",  dDataBase, cTime, cUserId)
            RJP->(dbSetOrder(6))//RJP_FILIAL+RJP_KEY
            If RJP->(dbSeek(xFilial("RJP")+cChave))
                RecLock("RJP",.F.)
                RJP->RJP_CGINIC := '1'
                RJP->(MsUnlock())
            Else 
                DisarmTransaction()
            EndIf
        End Transaction
    EndIf
    (cAlsQry)->(dbSkip())
    
EndDo

If nTotalReg == 0
    cMsg := STR0054//##"Não foram encontrados registros elegíveis para processamento no cadastro de cargos. (SQ3)"
else
    cMsg := STR0016+cValToChar(nTotalReg)+STR0055//##"Foram processados "##" registros do cadastro de cargos (SQ3)."
EndIf

(cAlsQry)->(dbCloseArea())

RestArea(aAreOld)

Return Nil

/*/{Protheus.doc} LoadSQB
Realiza a carga dos registros da SQB.
@type  Static Function
@author brdwc0032
@since 13/08/2020
@version 12.1.27
@param cUserId, Character, Código do Usuário.
@param cMsg , Character, Mensagem de processamento.
@param aLog , Character, Array contendo log de processamento
@param cFilIni , Character, Filial inicial.
@param cFilFin , Character, Filial final.
/*/
Static Function LoadSQB(cUserId,cMsg,aLog,cFilIni,cFilFin)

Local aAreOld := GetArea()

Local cAlsQry   := GetNextAlias()
Local cTime     := ""
Local cChave    := "" 

Local nTotalReg := 0 

Default cUserId   := SubStr(cUsuario,7,15)
Default cMsg    := ""
Default aLog    := {}
Default cFilIni := ""
Default cFilFin := ""

If !Empty(cFilIni)
    cFilIni := xFilial("SQB",cFilIni) 
EndIf

dbSelectArea("SQB")

BeginSQL Alias cAlsQry
    SELECT QB_FILIAL, QB_DEPTO, QB_CC, SQB.R_E_C_N_O_ AS RECNO
    FROM %Table:SQB% SQB
    WHERE QB_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:xFilial("SQB", cFilFin)%
    AND SQB.%NotDel%
EndSQL

(cAlsQry)->(dbEval({||nTotalReg++}))
(cAlsQry)->(dbGoTop())
ProcRegua(nTotalReg)
nTotalReg := 0
	
dbSelectArea("RJP")
dbSetOrder(6)

While !(cAlsQry)->(Eof())
    
    IncProc()
    
    // Verifica se o registro está bloqueado para uso
	SQB->(dbGoTo( (cAlsQry)->RECNO ))
	If !RegistroOk("SQB", .F.)
        nTotalReg--
		(cAlsQry)->(dbSkip())
		LOOP
	EndIf
    
	cChave := cEmpAnt + "|" + (cAlsQry)->QB_FILIAL + "|" + (cAlsQry)->QB_DEPTO + "|" + (cAlsQry)->QB_CC

    If RJP->(dbSeek(xFilial("RJP") + cChave))
		(cAlsQry)->(dbSkip())
    	LOOP
    Else
        cTime := Time()
        Aadd(aLog, {cChave, dDataBase, cTime, cUserId})
        nTotalReg++
        Begin Transaction
            fSetDeptoRJP((cAlsQry)->QB_FILIAL, "SQB", cChave, "I",  dDataBase, cTime, cUserId)
            RJP->(dbSetOrder(6)) //RJP_FILIAL+RJP_KEY
            If RJP->(dbSeek(xFilial("RJP") + cChave))
                RecLock("RJP", .F.)
                RJP->RJP_CGINIC := '1'
                RJP->(MsUnlock())
            Else 
                DisarmTransaction()
            EndIf
        End Transaction
        (cAlsQry)->(dbSkip())
    EndIf
    
EndDo

If nTotalReg == 0
    cMsg := STR0047//##"Não foram encontrados registros elegíveis para processamento no cadastro de departamentos. (SQB)"
else
    cMsg := STR0016+cValToChar(nTotalReg)+STR0048//##"Foram processados "##" registros do cadastro de departamentos (SQB)."
EndIf

(cAlsQry)->(dbCloseArea())

RestArea(aAreOld)

Return Nil

/*/{Protheus.doc} FPergunte
Perguntas da rotina
@type  Static Function
@author rafaelalmeida
@since 08/06/2020
@version 12.1.27
@param lView, logical, Determina se será exibida a janela de perguntas.
@param lEdit, logical, Determina o modo de edição de alguns parâmetros.
@return lRet, logical, Determina se o usuário confirmou ou cancelou a janela de perguntas.
/*/
Static Function FPergunte(cNomRot, lView, lEdit)
    
    Local aParambox	:= {}
    Local aRet 		:= {}
    Local lRet		:= .T.
    Local nX		:= 0
    
    Default cNomRot	:= "GPEM925"
    Default lView	:= .T.
    Default lEdit	:= .T.
    
    Private lWhen	:= lEdit
    
    aAdd( aParambox, {1, STR0035, CriaVar("RA_FILIAL", .F.), "@!", ".T.", "SM0",, 100, .F.})        //"Filial De: "
    aAdd( aParambox, {1, STR0036, CriaVar("RA_FILIAL", .F.), "@!", ".T.", "SM0",, 100, .F.})        //"Filial Até: "	
    aAdd( aParamBox, {4, STR0022, .F., "", 90, "", .F.})                                            //"Cadastro de Funcionários"
    aAdd( aParamBox, {4, STR0062, .F., "", 90, "", .F.})			                                //"Transferências"
    aAdd( aParamBox, {4, STR0063, .F., "", 90, "", .F.})				                            //"Alterações Salariais"
    aAdd( aParamBox, {4, STR0025, .F., "", 90, "", .F.})                                            //"Cadastro de Dependentes"
    aAdd( aParambox, {1, STR0037, CriaVar("RA_MAT", .F.), "@!", ".T.", "SRA02A", ".T.", 100, .F.})  //"Matrícula De: "
    aAdd( aParambox, {1, STR0038, CriaVar("RA_MAT", .F.), "@!", ".T.", "SRA02A", ".T.", 100, .F.})  //"Matrícula Até: "
    aAdd( aParamBox, {4, STR0026, .F., "", 90, "", .F.})                                            //"Cadastro de Dependentes"
    aAdd( aParambox, {1, STR0039, CriaVar("RD0_CODIGO", .F.), "@!", ".T.", "RD0", ".T.", 100, .F.}) //"Participante De: "
    aAdd( aParambox, {1, STR0040, CriaVar("RD0_CODIGO", .F.), "@!", ".T.", "RD0", ".T.", 100, .F.}) //"Participante Até: "
    aAdd( aParamBox, {4, STR0049, .F., "", 90, "", .F.})                                            //"Cadastro de Departamentos"
    aAdd( aParambox, {1, STR0051, CriaVar("Q3_CARGO", .F.), "@!", ".T.", "SQ3", ".T.", 100, .F.})   //"Cargo De: "
    aAdd( aParambox, {1, STR0052, CriaVar("Q3_CARGO", .F.), "@!", ".T.", "SQ3", ".T.", 100, .F.})   //"Cargo Até: "
    aAdd( aParamBox, {4, STR0050, .F., "", 90, "", .F.})                                            //"Cadastro de Cargos"
    aAdd( aParamBox, {4, STR0041, .F., "", 90, "", .F.})                                            //"Log de Processamento
    
    //Carrega o array com os valores utilizados na última tela ou valores Default de cada campo.
    For nX := 1 To Len(aParamBox)
        aParamBox[nX][3] := ParamLoad(cNomRot, aParamBox, nX, aParamBox[nX][3])
    Next nX
    
    //Define se ira apresentar tela de perguntas
    If lView
        lRet := ParamBox(aParamBox, STR0027, aRet, {|| VldPerg()}, {}, .T., Nil, Nil, Nil, cNomRot, .F., .F.) //"Parâmetros"
    Else
        For nX := 1 To Len(aParamBox)
            Aadd(aRet, aParamBox[nX][3])
        Next nX
    EndIf
    
    If lRet
    	//Carrega perguntas em variaveis usadas no programa
        If ValType(aRet) == "A" .And. Len(aRet) == Len(aParamBox)
            For nX := 1 to Len(aParamBox)
                If aParamBox[nX][1] == 2 .And. ValType(aRet[nX]) == "C"
                    &("Mv_Par" + StrZero(nX, 2)) := aScan(aParamBox[nX][4], {|x| Alltrim(x) == aRet[nX]})
                ElseIf aParamBox[nX][1] == 2 .And. ValType(aRet[nX]) == "N"
                    &("Mv_Par" + StrZero(nX, 2)) := aRet[nX]
                Else
                    &("Mv_Par" + StrZero(nX, 2)) := aRet[nX]
                Endif
            Next nX
        EndIf
        
        If lEdit
    		//Salva parametros
            ParamSave(cNomRot, aParamBox, "1")
        EndIf
    EndIf
    
Return(lRet)


/*/{Protheus.doc} nomeStaticFunction
Função de validação do preenchimento dos perguntes.
@type  Static Function
@author rafaelalmeida
@since 18/06/2020
@version 12.1.27
@return lRet, logic, Retorno lógico da validação
/*/
Static Function VldPerg()
    
    Local lRet := .T.
    
    //Integraçao SRA  ou SRB selecionada e (Matricula até) vazio.
    If (MV_PAR03 .Or. MV_PAR04 .Or. MV_PAR05 .Or. MV_PAR06) .And. Empty(MV_PAR08)
        lRet := .F.
        // "Você selecionou a integração de Funcionários, Dependentes, Transferências ou Histórico Salarial."
        // "Por favor preencha o campo de [Matricula até:] !"
        MsgStop(STR0042 + CRLF + STR0043)
    EndIf
    
    //Integraçao RD0 selecionada e (Participante até) vazio.
    If MV_PAR09 .And. Empty(MV_PAR11)
        lRet := .F.
        // "Você selecionou a integração de pessoas."
        // "Por favor preencha o campo de [Participante até:] !"
        MsgStop(STR0044 + CRLF + STR0045)
    EndIf
    
Return lRet

/*/{Protheus.doc} GravaLog
Grava log de processamento 
@type  Static Function
@author user
@since 09/06/2020
@version version
@param cLog, Character, Mensagem geral de processamento
@param aLogSra, Array, Log de Registros Gravados na SRA.
@param aLogSrb, Array, Log de Registros Gravados na SRB.
@param aLogRD0, Array, Log de Registros Gravados na RDO
@param aLogSqb, Array, Log de Registros Gravados na SQB
@param aLogSq3, Array, Log de Registros Gravados na SQ3
@param aLogSre, Array, Log de Registros Gravados na SRE
@param aLogSr7, Array, Log de Registros Gravados na SR7
/*/
Static Function GravaLog(aLogSra, aLogSrb, aLogRd0, aLogSqb, aLogSq3, aLogSre, aLogSr7)

Local aDados  := {}
Local aTitle  := {}


Local nTotalReg := 0
Local nXi       := 1

Default aLogSra := {}
Default aLogSrb := {}
Default aLogRd0 := {}
Default aLogSqb := {}

Aadd(aTitle, STR0029)//##Log de Processamento da Carga Inicial

Aadd(aDados, Padr(STR0030,30) +;//##Tabela
             Padr(STR0031,40) +;//##Chave
             Padr(STR0032,12) +;//##Data
             Padr(STR0033,10) +;//##Hora
             Padr(STR0034,20))//##Usuário*/

nTotalReg := Len(aLogSRA)
If nTotalReg > 0
    ProcRegua(nTotalReg)
    
    For nXi := 1 To nTotalReg
        IncProc()

        Aadd(aDados,Padr("SRA " + FWSX2UTIL():GETX2NAME("SRA"), 30) +;
            Padr(aLogSra[nXi][1], 40) +;
            Padr(DtoC(aLogSra[nXi][2]), 12) +;
            Padr(aLogSra[nXi][3],10) +;
            Padr(aLogSra[nXi][4],20))
    Next
EndIf

nTotalReg := Len(aLogSRB)
If nTotalReg > 0
    ProcRegua(nTotalReg)

    For nXi := 1 To nTotalReg
        IncProc()

        Aadd(aDados,Padr("SRB "+FWSX2UTIL():GETX2NAME("SRB"),30) +;
            Padr(aLogSRB[nXi][1],40) +;
            Padr(DtoC(aLogSRB[nXi][2]),12) +;
            Padr(aLogSRB[nXi][3],10) +;
            Padr(aLogSRB[nXi][4],20))
    Next
EndIf

nTotalReg := Len(aLogRD0)
If nTotalReg > 0
    ProcRegua(nTotalReg)

    For nXi := 1 To nTotalReg
        IncProc()

        Aadd(aDados,Padr("RD0 "+FWSX2UTIL():GETX2NAME("RD0"),30) +;
            Padr(aLogRD0[nXi][1],40) +;
            Padr(DtoC(aLogRD0[nXi][2]),12) +;
            Padr(aLogRD0[nXi][3],10) +;
            Padr(aLogRD0[nXi][4],20))
    Next
EndIf

nTotalReg := Len(aLogSqb)
If nTotalReg > 0
    ProcRegua(nTotalReg)
    
    For nXi := 1 To nTotalReg
        IncProc()
        
        Aadd(aDados, Padr("SQB " + FWSX2UTIL():GETX2NAME("SQB"), 30) +;
            Padr(aLogSqb[nXi][1],40) +;
            Padr(DtoC(aLogSqb[nXi][2]),12) +;
            Padr(aLogSqb[nXi][3],10) +;
            Padr(aLogSqb[nXi][4],20))
    Next
EndIf

nTotalReg := Len(aLogSq3)
If nTotalReg > 0
    ProcRegua(nTotalReg)

    For nXi := 1 To nTotalReg
        IncProc()

        Aadd(aDados,Padr("SQ3 "+FWSX2UTIL():GETX2NAME("SQ3"),30) +;
            Padr(aLogSq3[nXi][1],40) +;
            Padr(DtoC(aLogSq3[nXi][2]),12) +;
            Padr(aLogSq3[nXi][3],10) +;
            Padr(aLogSq3[nXi][4],20))
    Next
EndIf

nTotalReg := Len(aLogSre)
If nTotalReg > 0
    ProcRegua(nTotalReg)
	
    For nXi := 1 To nTotalReg
        IncProc()
		
        Aadd(aDados, Padr("SRE " + FWSX2UTIL():GETX2NAME("SRE"), 30) +;
            Padr(aLogSre[nXi][1], 40) +;
            Padr(DtoC(aLogSre[nXi][2]), 12) +;
            Padr(aLogSre[nXi][3], 10) +;
            Padr(aLogSre[nXi][4], 20))
    Next
EndIf

nTotalReg := Len(aLogSr7)
If nTotalReg > 0
    ProcRegua(nTotalReg)
	
    For nXi := 1 To nTotalReg
        IncProc()
		
        Aadd(aDados, Padr("SR7 " + FWSX2UTIL():GETX2NAME("SR7"), 30) +;
            Padr(aLogSr7[nXi][1], 40) +;
            Padr(DtoC(aLogSr7[nXi][2]), 12) +;
            Padr(aLogSr7[nXi][3], 10) +;
            Padr(aLogSr7[nXi][4], 20))
    Next
EndIf

fMakeLog({aDados}, aTitle, Nil, Nil, "",STR0029, "M", "P",, .F.)//##Log de Processamento da Carga Inicial


Return Nil
