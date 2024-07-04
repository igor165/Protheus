#Include 'Protheus.ch'

#DEFINE ARQ_LOG		    "correcao_recnos.log"
#DEFINE ARQ_MOV_CSV		"recnos_movimentos.csv"
#DEFINE ARQ_CRI_CSV		"recnos_criticas.csv"


User Function CnAjB075()

    Local aSay    := {}
    Local aButton := {}
    Local nOpc    := 0
    Local Titulo  := 'Central de Obrigações'
    Local cDesc1  := 'Esta rotina fará a exclusão de criticas B075 para movimentações de '
    Local cDesc2  := 'retificação da Central de Obrigações.'
    Local cDesc3  := 'Tabela: B3F'

    aAdd( aSay, cDesc1 )
    aAdd( aSay, cDesc2 )
    aAdd( aSay, cDesc3 )

    aAdd( aButton, { 1, .T., { || nOpc := 2, FechaBatch() } } )
    aAdd( aButton, { 2, .T., { || FechaBatch() } } )

    FormBatch( Titulo, aSay, aButton, , 200, 450 )

    If nOpc == 2
        BEGIN TRANSACTION    
            PlsLogFil(CENDTHRL("I") + "[CenAjuB075] Inicio da deleção das criticas B075. ",ARQ_LOG)
            Processa( { || lOk := delCriB075() },"Esclusão Criticas B075 para retificações","Processando...",.T.)
            PlsLogFil(CENDTHRL("I") + "[CenAjuB075] Fim  da deleção das criticas B075. ",ARQ_LOG)
        END TRANSACTION
        MsgInfo("Processamento concluído!")
    EndIf

Return 

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} delCriB075()

Corrige a chave única das movimentações do SIB

@author everton.mateus
@since 09/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function delCriB075()
	
	Local nQtd  := 0
	Local nProc := 0

    PlsLogFil(CENDTHRL("I") + "[delCriB075] Inicio da correção dos recnos das movimentações B3X. ",ARQ_LOG)
    PlsLogFil("recno_b3k;recno_b3x;valo_antigo;valor_novo",ARQ_MOV_CSV)
    nQtd := carMovtoSIB(.T.)
    
    If nQtd > 0
        ProcRegua( int(nQtd / 1000) + 1)
        carMovtoSIB(.F.)
        Do While !TRBCOR->(Eof())
            If nProc % 200 == 0
                cMsg := "Movimentações Excluidas: " +AllTrim(Str(nQtd))+"."
                PlsLogFil(CENDTHRL("I") + "[delCriB075] " + cMsg,ARQ_LOG)
                IncProc(cMsg)
            EndIf
            B3F->( DbGoto(TRBCOR->RECB3F) )
            RecLock("B3F",.F.)
                B3F->(DbDelete())
            B3F->(msUnLock())
            PlsLogFil(Alltrim(Str(TRBCOR->RECB3F)),ARQ_MOV_CSV)
            nProc++
            TRBCOR->(DbSkip())
        EndDo
    Else
        PlsLogFil(CENDTHRL("W") + "[delCriB075] Não encontrou dados para processar. ",ARQ_LOG)
    EndIf
    TRBCOR->(DbCloseArea())	
    PlsLogFil(CENDTHRL("I") + "[delCriB075] Fim da correção dos recnos das movimentações B3X. ",ARQ_LOG)

Return

Static Function carMovtoSIB(lTotal)
	
    Local nQtd := 0
    Local cSql := ""
	
	Default lTotal := .F.
	
	If Select('TRBCOR') > 0
		TRBCOR->(dbCloseArea())
	EndIf

	cSql := " SELECT  "
	If lTotal
		cSql += " count(1) TOTAL "
	Else 
		cSql += " B3F.R_E_C_N_O_ RECB3F "
	EndIf
	
	cSql += " FROM " + RetSqlName("B3F") + " B3F "
	cSql += "   INNER JOIN " + RetSqlName("B3X") + " B3X ON (B3F_CHVORI =  B3X.R_E_C_N_O_) "
	cSql += " WHERE 1 = 1  "
	cSql += "   AND B3F_CODCRI LIKE '%B075%' "  //Critica
	cSql += "   AND B3X_OPERA = '2'          "  //Operação Retificação   
	cSql += "   AND B3F.D_E_L_E_T_ = ' '     "
	cSql += "   AND B3X.D_E_L_E_T_ = ' '     "
		
	cSql := ChangeQuery(cSql)
    PlsLogFil(CENDTHRL("I") + "[carMovtoSIB] Query de movimentações: " + cSql,ARQ_LOG)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCOR",.F.,.T.)
    PlsLogFil(CENDTHRL("I") + "[carMovtoSIB] Fim da query.",ARQ_LOG)

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