#Include 'Protheus.ch'

#DEFINE ARQ_LOG		    "correcao_recnos.log"
#DEFINE ARQ_MOV_CSV		"recnos_movimentos.csv"
#DEFINE ARQ_CRI_CSV		"recnos_criticas.csv"

User Function CenAjustRec()

    Local aSay     := {}
    Local aButton  := {}
    Local nOpc     := 0
    Local Titulo	:= 'Central de Obrigações'
    Local cDesc1	:= 'Esta rotina fará a correção do relacionamento entre tabelas '
    Local cDesc2	:= 'da Central de Obrigações.'
    Local cDesc3	:= "Tabelas: B3K, B3X e B3F"

    aAdd( aSay, cDesc1 )
    aAdd( aSay, cDesc2 )
    aAdd( aSay, cDesc3 )

    aAdd( aButton, { 1, .T., { || nOpc := 2, FechaBatch() } } )
    aAdd( aButton, { 2, .T., { || FechaBatch() } } )

    FormBatch( Titulo, aSay, aButton, , 200, 450 )

    If nOpc == 2
        BEGIN TRANSACTION    
            PlsLogFil(CENDTHRL("I") + "[CenAjustRec] Inicio da correção dos recnos. ",ARQ_LOG)
            Processa( { || lOk := atuOperaMov() },"Correção de relacionamento B3K->B3X","Processando...",.T.)
            Processa( { || lOk := atuCriticas() },"Correção de relacionamento B3K->B3F","Processando...",.T.)
            PlsLogFil(CENDTHRL("I") + "[CenAjustRec] Fim da correção dos recnos. ",ARQ_LOG)
        END TRANSACTION
        MsgInfo("Processamento concluído!")
    EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuOperaMov()

Corrige a chave única das movimentações do SIB

@author everton.mateus
@since 09/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function atuOperaMov()
	
	Local nQtd := 0
	Local nProc:= 0

    PlsLogFil(CENDTHRL("I") + "[atuOperaMov] Inicio da correção dos recnos das movimentações B3X. ",ARQ_LOG)
    PlsLogFil("recno_b3k;recno_b3x;valo_antigo;valor_novo",ARQ_MOV_CSV)
    nQtd := carMovtoSIB(.T.)
    If nQtd > 0
        ProcRegua( int(nQtd / 1000) + 1)
        carMovtoSIB(.F.)
        Do While !TRBCOR->(Eof())
            If nProc % 1000 == 0
                cMsg := "Movimentações lidas: " +AllTrim(Str(nQtd))+ ". Movimentações processadas:" +AllTrim(Str(nProc))+ "."
                PlsLogFil(CENDTHRL("I") + "[atuOperaMov] " + cMsg,ARQ_LOG)
                IncProc(cMsg)
            EndIf
            B3X->( DbGoto(TRBCOR->RECB3X) )
            nVlrAntigo := B3X->B3X_BENEF
            RecLock('B3X',.F.)
                B3X->B3X_BENEF := TRBCOR->RECB3K
            B3X->(MsUnlock())
            PlsLogFil(Alltrim(Str(TRBCOR->RECB3K))+";"+Alltrim(Str(TRBCOR->RECB3X))+";"+Alltrim(Str(nVlrAntigo))+";"+Alltrim(Str(TRBCOR->RECB3K)),ARQ_MOV_CSV)
            nProc++
            TRBCOR->(DbSkip())
        EndDo
    Else
        PlsLogFil(CENDTHRL("W") + "[atuOperaMov] Não encontrou dados para processar. ",ARQ_LOG)
    EndIf
    TRBCOR->(DbCloseArea())	
    PlsLogFil(CENDTHRL("I") + "[atuOperaMov] Fim da correção dos recnos das movimentações B3X. ",ARQ_LOG)
Return

Static Function carMovtoSIB(lTotal)
	Local cSql := ""
	Local nQtd := 0

	Default lTotal := .F.
	
	If Select('TRBCOR') > 0
		TRBCOR->(dbCloseArea())
	EndIf

	cSql := " SELECT  "
	If lTotal
		cSql += " 	count(1) TOTAL "
	Else 
		cSql += " 	B3K.R_E_C_N_O_ RECB3K, B3X.R_E_C_N_O_ RECB3X "
	EndIf
	cSql += " FROM " + RetSqlName("B3X") + " B3X , " 
	cSql += " " + RetSqlName("B3K") + " B3K " 
	cSql += " WHERE "
	cSql += "	B3X_FILIAL = '" + xFilial('B3X') + "' "
	cSql += "	AND B3X_FILIAL = B3K_FILIAL "
    If B3X->(FieldPos("B3X_CODOPE")) > 0
	    cSql += "	AND B3X_CODOPE = B3K_CODOPE "
	EndIf
    cSql += "	AND B3X_IDEORI = B3K_MATRIC "
    cSql += "	AND B3K.R_E_C_N_O_ > 0 "
    cSql += "	AND B3X.R_E_C_N_O_ > 0 "
		
	cSql := ChangeQuery(cSql)
    PlsLogFil(CENDTHRL("I") + "[carMovtoSIB] Query de movimentações: " + cSql,ARQ_LOG)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCOR",.F.,.T.)
    PlsLogFil(CENDTHRL("I") + "[carMovtoSIB] Fim da query.",ARQ_LOG)

	If lTotal .AND. !TRBCOR->(Eof())
		nQtd := TRBCOR->TOTAL
	EndIf

Return nQtd

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuCriticas()

Corrige a chave única das críticas de beneficiários do SIB

@author everton.mateus
@since 09/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function atuCriticas()
	
	Local nQtd := 0
	Local nProc:= 0

    B3F->(DbSetOrder(1)) //B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI+STR(B3F_CHVORI)+B3F_CODCRI+B3F_TIPO+B3F_IDEORI+B3F_DESORI                                        

    PlsLogFil(CENDTHRL("I") + "[atuCriticas] Inicio da correção dos recnos das críticas B3F. ",ARQ_LOG)
    PlsLogFil("recno_b3k;recno_b3f;valo_antigo;valor_novo",ARQ_CRI_CSV)
    nQtd := carCriticas(.T.)
    If nQtd > 0
        ProcRegua( int(nQtd / 1000) + 1)
        carCriticas(.F.)
        Do While !TRBCOR->(Eof())
            If nProc % 1000 == 0
                cMsg := "Críticas lidas: " +AllTrim(Str(nQtd))+ ". Críticas processadas:" +AllTrim(Str(nProc))+ "."
                PlsLogFil(CENDTHRL("I") + "[atuCriticas] " + cMsg,ARQ_LOG)
                IncProc(cMsg)
            EndIf
            B3F->( DbGoto(TRBCOR->RECB3F) )
            nVlrAntigo := B3F->B3F_CHVORI
            If !B3F->(MsSeek(xFilial("B3F")+TRBCOR->(B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI)+PADR(TRBCOR->RECB3K,tamSX3("B3F_CHVORI")[1])+TRBCOR->(B3F_CODCRI+B3F_TIPO+B3F_IDEORI)  ) )
                B3F->( DbGoto(TRBCOR->RECB3F) )
                RecLock('B3F',.F.)
                    B3F->B3F_CHVORI := TRBCOR->RECB3K
                B3F->(MsUnlock())
                PlsLogFil(Alltrim(Str(TRBCOR->RECB3K))+";"+Alltrim(Str(TRBCOR->RECB3F))+";"+Alltrim(Str(nVlrAntigo))+";"+Alltrim(Str(TRBCOR->RECB3K)),ARQ_CRI_CSV)
            EndIf
            nProc++
            TRBCOR->(DbSkip())
        EndDo
    Else
        PlsLogFil(CENDTHRL("W") + "[atuCriticas] Não encontrou dados para processar. ",ARQ_LOG)
    EndIf
    TRBCOR->(DbCloseArea())	
    PlsLogFil(CENDTHRL("I") + "[atuCriticas] Fim da correção dos recnos das críticas B3F. ",ARQ_LOG)
Return

Static Function carCriticas(lTotal)

	Local cSql := ""
	Local nQtd := 0

	Default lTotal := .F.
	
	If Select('TRBCOR') > 0
		TRBCOR->(dbCloseArea())
	EndIf

	cSql := " SELECT  "
	If lTotal
		cSql += " 	count(1) TOTAL "
	Else 
		cSql += " 	B3K.R_E_C_N_O_ RECB3K, B3F.R_E_C_N_O_ RECB3F "
		cSql += " 	,B3F_CODOPE,B3F_CDOBRI,B3F_ANO,B3F_CDCOMP "
		cSql += " 	,B3F_ORICRI,B3F_CODCRI,B3F_TIPO,B3F_IDEORI "
	EndIf
	cSql += " FROM " + RetSqlName("B3F") + " B3F , " 
	cSql += " " + RetSqlName("B3K") + " B3K " 
	cSql += " WHERE "
	cSql += "	B3F_FILIAL = '" + xFilial('B3F') + "' "
	cSql += "	AND B3F_FILIAL = B3K_FILIAL "
	cSql += "	AND B3F_CODOPE = B3K_CODOPE "
	cSql += "	AND B3F_ORICRI = 'B3K' "
	cSql += "	AND B3F_IDEORI = B3K_MATRIC "
    cSql += "	AND B3F_CODCRI <> '' "
    cSql += "	AND B3F.D_E_L_E_T_ = ' ' "
    cSql += "	AND B3K.D_E_L_E_T_ = ' ' "
    cSql += "	AND B3K.R_E_C_N_O_ > 0 "
    cSql += "	AND B3F.R_E_C_N_O_ > 0 "
	cSql := ChangeQuery(cSql)
    PlsLogFil(CENDTHRL("I") + "[carCriticas] Query de críticas: " + cSql,ARQ_LOG)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCOR",.F.,.T.)
    PlsLogFil(CENDTHRL("I") + "[carCriticas] Fim da query.",ARQ_LOG)

	If lTotal .AND. !TRBCOR->(Eof())
		nQtd := TRBCOR->TOTAL
	EndIf

Return nQtd

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENDTHRL

Funcao criada para retornar date e hora para log 

@author timoteo.bega
@since 
/*/
//--------------------------------------------------------------------------------------------------
Static Function CENDTHRL(cTp)
	Local cMsg := "[" + DTOS(Date()) + " " + Time() + "]"
	Default cTp	:= "I"

	If cTp == "E"
		cMsg += "[ERRO]"
	ElseIf cTp == "W"
		cMsg += "[WARN]"
	Else
		cMsg += "[INFO]"
	EndIf

Return cMsg